/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <array>
#include <vector>
#include "../../utils/resource.hpp"
#include "../../utils/swapchain.hpp"

namespace witcher3classic {
// The native weather pass writes UNORM material data into pooled scratch,
// then copies it back to the G-buffer. The SAME pool can carry HDR color
// later, so suppress its clone routing only until those copies have executed.
class WeatherMaterials {
 public:
  bool Begin(reshade::api::command_list* cmd, uint32_t width, uint32_t height,
             const std::array<reshade::api::resource, 2>& destinations) {
    auto* state = renodx::utils::swapchain::GetCurrentState(cmd);
    if (!state || state->current_render_targets.size() != 2 || !width || !height) return false;
    const std::array<reshade::api::resource_view, 2> targets{
        state->current_render_targets[0], state->current_render_targets[1]};
    std::array<reshade::api::resource, 2> resources{};
    for (size_t i = 0; i < resources.size(); ++i) {
      renodx::utils::resource::GetResourceViewInfo(targets[i], [&](const auto& view) {
        if (!view.is_clone && view.desc.format == reshade::api::format::r8g8b8a8_unorm)
          resources[i] = view.original_resource;
      });
      if (!resources[i].handle) return false;
      bool material = false;
      renodx::utils::resource::GetResourceInfo(resources[i], [&](const auto& info) {
        material = !info.is_clone && !info.is_swap_chain
            && ((!info.clone_target && !info.clone_enabled)
                || (info.clone_target && info.clone_target->name == "Classic scene color"))
            && info.desc.type == reshade::api::resource_type::texture_2d
            && info.desc.texture.format == reshade::api::format::r8g8b8a8_unorm
            && info.desc.texture.width == width && info.desc.texture.height == height
            && info.desc.texture.depth_or_layers == 1 && info.desc.texture.samples == 1;
      });
      if (!material) return false;
    }
    resource_routes_.clear();
    view_routes_.clear();
    destinations_ = destinations;
    copied_ = 0;
    for (const auto resource : resources) {
      std::vector<uint64_t> views;
      renodx::utils::resource::UpdateResourceInfo(resource, [&](auto* info) {
        resource_routes_.push_back({resource.handle, info->clone_enabled, info->clone_can_deactivate, info->clone_target});
        info->clone_enabled = false;
        info->clone_can_deactivate = false;
        info->clone_target = nullptr;
        views.assign(info->resource_view_handles.begin(), info->resource_view_handles.end());
      });
      for (const auto handle : views) {
        renodx::utils::resource::UpdateResourceViewInfo({handle}, [&](auto* view) {
          view_routes_.push_back({handle, view->clone_enabled, view->clone_can_deactivate, view->clone_target});
          view->clone_enabled = false;
          view->clone_can_deactivate = false;
          view->clone_target = nullptr;
        });
      }
    }
    // Undo an earlier automatic FP16 bind using the application's own views.
    // Material copies immediately following this draw also use native storage.
    cmd->bind_render_targets_and_depth_stencil(2, targets.data(), state->current_depth_stencil);
    return true;
  }

  bool Pending() const { return !resource_routes_.empty(); }

  // ReShade command-list API calls execute the supplied native copy without
  // redispatching addon events. Match only the observed weather scratch ->
  // specular/normal pairs, and restore HDR routing immediately after both.
  template <typename Copy>
  bool CopyMaterial(reshade::api::command_list* cmd, reshade::api::resource source,
                    reshade::api::resource dest, const Copy& copy) {
    for (size_t i = 0; i < resource_routes_.size(); ++i) {
      if (source.handle != resource_routes_[i].handle || dest != destinations_[i]) continue;
      copy();
      copied_ |= 1u << i;
      if (copied_ == 3u) {
        Restore(cmd);
        if (!logged_) {
          logged_ = true;
          reshade::log::message(reshade::log::level::info,
              "Witcher Classic: native UNORM weather material copies completed; HDR pool routing restored.");
        }
      }
      return true;
    }
    return false;
  }

  void Restore(reshade::api::command_list* cmd = nullptr) {
    if (resource_routes_.empty()) return;
    for (const auto& route : resource_routes_)
      renodx::utils::resource::UpdateResourceInfo({route.handle}, [&](auto* info) {
        info->clone_enabled = route.enabled;
        info->clone_can_deactivate = route.can_deactivate;
        info->clone_target = route.target;
      });
    for (const auto& route : view_routes_)
      renodx::utils::resource::UpdateResourceViewInfo({route.handle}, [&](auto* view) {
        view->clone_enabled = route.enabled;
        view->clone_can_deactivate = route.can_deactivate;
        view->clone_target = route.target;
      });
    resource_routes_.clear();
    view_routes_.clear();
    if (cmd) {
      if (auto* state = renodx::utils::swapchain::GetCurrentState(cmd)) {
        std::array<reshade::api::resource_view, 8> targets{};
        std::copy(state->current_render_targets.begin(), state->current_render_targets.end(), targets.begin());
        cmd->bind_render_targets_and_depth_stencil(uint32_t(state->current_render_targets.size()),
            targets.data(), state->current_depth_stencil);
      }
    }
  }

 private:
  struct Route {
    uint64_t handle;
    bool enabled, can_deactivate;
    renodx::utils::resource::ResourceUpgradeInfo* target;
  };
  std::vector<Route> resource_routes_, view_routes_;
  std::array<reshade::api::resource, 2> destinations_{};
  uint32_t copied_ = 0;
  bool logged_ = false;
};
}  // namespace witcher3classic
