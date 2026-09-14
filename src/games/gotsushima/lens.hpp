/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <array>
#include <map>
#include <memory>
#include <mutex>
#include <vector>

#include "../../utils/descriptor.hpp"
#include "../../utils/render.hpp"
#include "../../utils/state.hpp"
#include "./shared.h"

namespace gotsushima::lens {

inline ShaderInjectData* settings = nullptr;

// RenderPass restores fixed-function state and descriptor tables. D3D12 also
// needs its root constants and root descriptors replayed after a different
// graphics root signature. Keep these local to this injected game pass.
struct RootDescriptorDeleter {
  void operator()(reshade::api::descriptor_table_update* value) const {
    renodx::utils::descriptor::DestroyDescriptorTableUpdates(value, 1);
  }
};
struct __declspec(uuid("21a1eefc-9d82-48eb-a515-c3a723790d94")) CommandData {
  reshade::api::pipeline_layout layout = {};
  std::map<uint32_t, std::vector<uint32_t>> constants;
  std::map<uint32_t, std::unique_ptr<reshade::api::descriptor_table_update, RootDescriptorDeleter>> descriptors;
  std::map<uint32_t, reshade::api::descriptor_table> tables;

  void SetLayout(reshade::api::pipeline_layout next) {
    if (layout == next) return;
    layout = next;
    constants.clear();
    descriptors.clear();
    tables.clear();
  }
};

struct Target {
  reshade::api::resource copy = {};
  renodx::utils::render::RenderPass pass;
};
struct __declspec(uuid("278e677b-eb36-4d2c-8543-721872723be5")) DeviceData {
  std::recursive_mutex mutex;
  std::map<uint64_t, std::unique_ptr<Target>> targets;
  uint32_t width = 0;
  uint32_t height = 0;
  bool scene_pending = false;
  bool logged = false;
  bool logged_fallback = false;
  bool warned = false;
};

inline reshade::api::pipeline_layout ReplacementLayout(reshade::api::pipeline_layout layout) {
  renodx::utils::pipeline_layout::GetPipelineLayoutData(layout, [&layout](const auto* data) {
    if (data->replacement_layout.handle != 0) layout = data->replacement_layout;
  });
  return layout;
}

inline void OnInitCommandList(reshade::api::command_list* cmd_list) {
  cmd_list->create_private_data<CommandData>();
}
inline void OnDestroyCommandList(reshade::api::command_list* cmd_list) {
  cmd_list->destroy_private_data<CommandData>();
}
inline void OnResetCommandList(reshade::api::command_list* cmd_list) {
  if (auto* data = cmd_list->get_private_data<CommandData>()) data->SetLayout({});
}
inline void OnPushConstants(reshade::api::command_list* cmd_list, reshade::api::shader_stage stages,
                            reshade::api::pipeline_layout layout, uint32_t param,
                            uint32_t first, uint32_t count, const void* values) {
  if ((stages & reshade::api::shader_stage::all_graphics) == reshade::api::shader_stage(0)) return;
  auto* data = cmd_list->get_private_data<CommandData>();
  if (data == nullptr) return;
  data->SetLayout(layout);
  auto& stored = data->constants[param];
  stored.resize(std::max<size_t>(stored.size(), first + count));
  std::copy_n(static_cast<const uint32_t*>(values), count, stored.begin() + first);
}
inline void OnPushDescriptors(reshade::api::command_list* cmd_list, reshade::api::shader_stage stages,
                              reshade::api::pipeline_layout layout, uint32_t param,
                              const reshade::api::descriptor_table_update& update) {
  if ((stages & reshade::api::shader_stage::all_graphics) == reshade::api::shader_stage(0)) return;
  auto* data = cmd_list->get_private_data<CommandData>();
  if (data == nullptr) return;
  data->SetLayout(layout);
  // D3D12 root descriptors contain one descriptor, with no array offset.
  data->descriptors[param].reset(renodx::utils::descriptor::CloneDescriptorTableUpdates(&update, 1));
}
inline void OnBindDescriptorTables(reshade::api::command_list* cmd_list, reshade::api::shader_stage stages,
                                   reshade::api::pipeline_layout layout, uint32_t first,
                                   uint32_t count, const reshade::api::descriptor_table* tables) {
  if ((stages & reshade::api::shader_stage::all_graphics) == reshade::api::shader_stage(0)) return;
  auto* data = cmd_list->get_private_data<CommandData>();
  if (data == nullptr) return;
  data->SetLayout(layout);
  for (uint32_t i = 0; i < count; ++i) data->tables[first + i] = tables[i];
}

inline void OnInitDevice(reshade::api::device* device) {
  device->create_private_data<DeviceData>();
}
inline void OnDestroyResource(reshade::api::device* device, reshade::api::resource resource) {
  auto* data = device->get_private_data<DeviceData>();
  if (data == nullptr) return;
  const std::lock_guard lock(data->mutex);
  const auto found = data->targets.find(resource.handle);
  if (found == data->targets.end()) return;
  auto target = std::move(found->second);
  data->targets.erase(found);
  // The scratch texture follows the lifetime of the game target whose queue
  // ordering also protects its reuse. Never recycle descriptors across targets.
  target->pass.DestroyAll(device);
  device->destroy_resource(target->copy);
}
inline void OnDestroyDevice(reshade::api::device* device) {
  auto* data = device->get_private_data<DeviceData>();
  if (data == nullptr) return;
  while (!data->targets.empty()) OnDestroyResource(device, {data->targets.begin()->first});
  device->destroy_private_data<DeviceData>();
}
inline void OnInitSwapchain(reshade::api::swapchain* swapchain, bool) {
  auto* data = swapchain->get_device()->get_private_data<DeviceData>();
  if (data == nullptr) return;
  const auto desc = swapchain->get_device()->get_resource_desc(swapchain->get_back_buffer(0));
  const std::lock_guard lock(data->mutex);
  data->width = desc.texture.width;
  data->height = desc.texture.height;
  data->scene_pending = false;
  settings->post_effects_output_fallback = 0.f;
}
inline bool EffectsActive() {
  return settings->tone_map_type == 1.f
         && (settings->sharpening > 0.f || settings->film_grain > 0.f
             || (settings->chromatic_aberration_enabled != 0.f
                 && settings->chromatic_aberration_intensity > 0.f));
}
inline bool OnScene(reshade::api::command_list* cmd_list) {
  settings->post_effects_output_fallback = 0.f;
  if (auto* data = cmd_list->get_device()->get_private_data<DeviceData>()) {
    const std::lock_guard lock(data->mutex);
    data->scene_pending = EffectsActive();
  }
  return true;
}
inline bool OnOutput(reshade::api::command_list* cmd_list) {
  settings->post_effects_output_fallback = 0.f;
  if (auto* data = cmd_list->get_device()->get_private_data<DeviceData>()) {
    const std::lock_guard lock(data->mutex);
    // With no HUD draw, the final shader's input is still scene-only. Apply
    // the same post-upscale effects there, before PQ encoding. This callback runs
    // before mods::shader copies the injection data for this output draw.
    settings->post_effects_output_fallback = data->scene_pending && EffectsActive() ? 1.f : 0.f;
    if (settings->post_effects_output_fallback != 0.f && !data->logged_fallback) {
      reshade::log::message(reshade::log::level::info, "[Ghost Effects] HUD-hidden output fallback active after upscaling, before PQ encoding.");
      data->logged_fallback = true;
    }
    // Do not carry a scene marker into a later menu/loading frame.
    data->scene_pending = false;
  }
  return true;
}

inline bool BeforeHUD(reshade::api::command_list* cmd_list) {
  using namespace reshade::api;
  auto* device = cmd_list->get_device();
  auto* data = device->get_private_data<DeviceData>();
  auto* roots = cmd_list->get_private_data<CommandData>();
  auto* state = renodx::utils::state::GetCurrentState(cmd_list);
  if (data == nullptr || roots == nullptr || state == nullptr || device->get_api() != device_api::d3d12) return true;
  const std::lock_guard lock(data->mutex);
  if (!data->scene_pending || state->render_targets.size() != 1 || roots->layout.handle == 0) return true;
  const auto target_resource = device->get_resource_from_view(state->render_targets[0]);
  if (target_resource.handle == 0) return true;
  const auto desc = device->get_resource_desc(target_resource);
  // The live capture's post-upscale HUD composition target. Offscreen UI
  // textures rendered before the scene, smaller layers and PQ output are excluded.
  if (desc.type != resource_type::texture_2d || desc.texture.width != data->width
      || desc.texture.height != data->height || desc.texture.format != format::r10g10b10a2_unorm
      || desc.texture.samples != 1 || desc.texture.levels != 1 || desc.texture.depth_or_layers != 1) return true;
  data->scene_pending = false;
  if (!EffectsActive()) return true;

  auto& target = data->targets[target_resource.handle];
  if (!target) {
    target = std::make_unique<Target>();
    auto copy_desc = desc;
    copy_desc.usage = resource_usage::copy_dest | resource_usage::shader_resource;
    copy_desc.flags = resource_flags::none;
    copy_desc.heap = memory_heap::gpu_only;
    if (!device->create_resource(copy_desc, nullptr, resource_usage::shader_resource, &target->copy)) {
      data->targets.erase(target_resource.handle);
      if (!data->warned) {
        reshade::log::message(reshade::log::level::warning, "[Ghost Effects] Could not create scene copy; effect skipped.");
        data->warned = true;
      }
      return true;
    }
    device->set_resource_name(target->copy, "Ghost post-upscale effects scene copy");
    target->pass.pipeline_subobjects.vertex_shader = __0x7C4BC81C;
    target->pass.pipeline_subobjects.pixel_shader = __0xE4B02509;
    target->pass.render_target_slots.resources = {target_resource};
    target->pass.render_target_slots.view_descs = {resource_view_desc(resource_view_type::texture_2d, desc.texture.format, 0, 1, 0, 1)};
    target->pass.shader_resource_slots.resources = {target->copy};
    target->pass.shader_resource_slots.view_descs = target->pass.render_target_slots.view_descs;
    target->pass.use_render_pass = false;
    target->pass.revert_state_after_render = false;
  }
  auto saved = *state;
  const auto graphics_pipeline = renodx::utils::shader::GetCurrentPixelState(
      renodx::utils::shader::GetCurrentState(cmd_list))->pipeline;
  const std::array resources = {target_resource, target->copy};
  const std::array before = {resource_usage::render_target, resource_usage::shader_resource};
  const std::array copying = {resource_usage::copy_source, resource_usage::copy_dest};
  cmd_list->barrier(2, resources.data(), before.data(), copying.data());
  cmd_list->copy_resource(target_resource, target->copy);
  cmd_list->barrier(2, resources.data(), copying.data(), before.data());
  target->pass.push_constants[{13, 50}] = std::span<const float>(
      reinterpret_cast<const float*>(settings), sizeof(*settings) / sizeof(float));
  const bool rendered = target->pass.Render(cmd_list);

  // Restore the actual cloned root signatures used by mods::shader, not the
  // original signatures observed in API events. Switching to the latter would
  // invalidate the game's root values before its HUD draw.
  saved.graphics_pipeline_layout = ReplacementLayout(saved.graphics_pipeline_layout);
  saved.compute_pipeline_layout = ReplacementLayout(saved.compute_pipeline_layout);
  saved.Apply(cmd_list);
  cmd_list->bind_pipeline(pipeline_stage::all_graphics, graphics_pipeline);
  const auto layout = ReplacementLayout(roots->layout);
  for (const auto& [param, table] : roots->tables) {
    if (table.handle != 0) cmd_list->bind_descriptor_tables(shader_stage::all_graphics, layout, param, 1, &table);
  }
  for (const auto& [param, values] : roots->constants) {
    cmd_list->push_constants(shader_stage::all_graphics, layout, param, 0, static_cast<uint32_t>(values.size()), values.data());
  }
  for (const auto& [param, update] : roots->descriptors) {
    if (update && update->descriptors) cmd_list->push_descriptors(shader_stage::all_graphics, layout, param, *update);
  }
  if (rendered && !data->logged) {
    reshade::log::message(reshade::log::level::info, "[Ghost Effects] Post-upscale scene pass active before full-resolution HUD composition.");
    data->logged = true;
  } else if (!rendered && !data->warned) {
    reshade::log::message(reshade::log::level::warning, "[Ghost Effects] Post-upscale pass failed; scene left unchanged.");
    data->warned = true;
  }
  return true;
}

inline void Use(DWORD reason, ShaderInjectData* injection) {
  settings = injection;
  renodx::utils::resource::Use(reason);
  renodx::utils::state::Use(reason);
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::register_event<reshade::addon_event::destroy_resource>(OnDestroyResource);
    reshade::register_event<reshade::addon_event::init_command_list>(OnInitCommandList);
    reshade::register_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
    reshade::register_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
    reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
    reshade::register_event<reshade::addon_event::push_constants>(OnPushConstants);
    reshade::register_event<reshade::addon_event::push_descriptors>(OnPushDescriptors);
    reshade::register_event<reshade::addon_event::bind_descriptor_tables>(OnBindDescriptorTables);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::unregister_event<reshade::addon_event::destroy_resource>(OnDestroyResource);
    reshade::unregister_event<reshade::addon_event::init_command_list>(OnInitCommandList);
    reshade::unregister_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
    reshade::unregister_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
    reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
    reshade::unregister_event<reshade::addon_event::push_constants>(OnPushConstants);
    reshade::unregister_event<reshade::addon_event::push_descriptors>(OnPushDescriptors);
    reshade::unregister_event<reshade::addon_event::bind_descriptor_tables>(OnBindDescriptorTables);
  }
}
}  // namespace gotsushima::lens
