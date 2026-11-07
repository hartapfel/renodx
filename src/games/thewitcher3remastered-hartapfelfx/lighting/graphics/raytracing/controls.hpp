// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <atomic>
#include <memory>
#include <mutex>
#include "../rendering/bindings.hpp"
#include "../volumetrics/ray_layout.hpp"

namespace witcher3graphics::raytracing {
using namespace reshade::api;
inline std::atomic_uint32_t controls{0};
inline bool (*bind_path_inputs)(command_list*) = nullptr;
class HitSelection;
struct __declspec(uuid("32a29010-615e-42de-a6e8-e63cb3f8c409")) ControlData {
  struct State { uint64_t root; uint32_t libraries; std::shared_ptr<HitSelection> selection; };
  std::mutex mutex;
  std::vector<std::unique_ptr<std::vector<pipeline_layout_param>>> extended;
  std::unordered_map<uint64_t, uint32_t> layouts;
  std::unordered_map<uint64_t, State> states;
  uint32_t required_libraries = 0;
  uint32_t reflection_libraries = 0;
  uint32_t fog_libraries = 0;
  std::array<uint32_t, 3> hit_libraries{};
  bool water_failed = false;
};

// All audited consumers must have been admitted before any traced water path
// switches models. Libraries may live in separate states/collections.
inline bool WaterReady(const ControlData& data) {
  if (data.water_failed || !data.required_libraries) return false;
  uint32_t available = 0;
  for (const auto& [handle, state] : data.states)
    if (data.layouts.contains(state.root)) available |= state.libraries;
  return (available & data.required_libraries) == data.required_libraries;
}
inline bool WaterReady(device* dev) {
  if (auto* data = renodx::utils::data::Get<ControlData>(dev)) {
    std::lock_guard lock(data->mutex);
    return WaterReady(*data);
  }
  return false;
}

// Captured global DXR layout F553EDBA. Other globals and all local roots remain
// unchanged. Match semantic register ranges instead of borrowed blob addresses.
inline bool IsGlobalLayout(uint32_t count, const pipeline_layout_param* params) {
  if (!params || count < 4) return false;
  const auto* acceleration = bindings::RootDescriptor(params[0]);
  if (!acceleration || acceleration->type != descriptor_type::buffer_shader_resource_view
      || acceleration->dx_register_index != 0 || acceleration->dx_register_space != 1 || acceleration->count != 1) return false;
  if (params[3].type != pipeline_layout_param_type::push_constants
      || params[3].push_constants.dx_register_index != 2 || params[3].push_constants.dx_register_space != 1
      || params[3].push_constants.count != 1) return false;
  const std::array<descriptor_type, 6> types{descriptor_type::constant_buffer, descriptor_type::constant_buffer,
      descriptor_type::constant_buffer, descriptor_type::texture_unordered_access_view,
      descriptor_type::texture_shader_resource_view, descriptor_type::texture_shader_resource_view};
  constexpr std::array<uint32_t, 6> slots{12,0,1,0,4,0}, spaces{2,1,0,1,1,2}, counts{1,2,1,27,40,64}, offsets{0,1,3,4,31,71};
  const auto matches = [&](const auto& table) {
    if (table.count != 6) return false;
    for (uint32_t i = 0; i < 6; ++i) {
      const auto& range = table.ranges[i];
      if (range.type != types[i] || range.dx_register_index != slots[i] || range.dx_register_space != spaces[i]
          || range.count != counts[i] || range.binding != offsets[i]) return false;
    }
    return true;
  };
  bool resources = false;
  if (params[1].type == pipeline_layout_param_type::descriptor_table) resources = matches(params[1].descriptor_table);
  else if (params[1].type == pipeline_layout_param_type::descriptor_table_with_static_samplers)
    resources = matches(params[1].descriptor_table_with_static_samplers);
  if (!resources) return false;
  const descriptor_range* sampler = nullptr;
  if (params[2].type == pipeline_layout_param_type::descriptor_table && params[2].descriptor_table.count == 1)
    sampler = params[2].descriptor_table.ranges;
  else if (params[2].type == pipeline_layout_param_type::descriptor_table_with_static_samplers
      && params[2].descriptor_table_with_static_samplers.count == 1
      && params[2].descriptor_table_with_static_samplers.ranges[0].static_samplers == nullptr)
    sampler = params[2].descriptor_table_with_static_samplers.ranges;
  return sampler && sampler->type == descriptor_type::sampler && sampler->dx_register_index == 0
      && sampler->dx_register_space == 1 && sampler->count == 3 && sampler->binding == 0;
}
inline bool OnCreateLayout(device* dev, uint32_t& count, pipeline_layout_param*& params) {
  if (dev->get_api() != device_api::d3d12 || count != 4 || !IsGlobalLayout(count, params)) return false;
  auto* data = renodx::utils::data::Get<ControlData>(dev);
  if (!data) return false;
  std::lock_guard lock(data->mutex);
  auto copy = std::make_unique<std::vector<pipeline_layout_param>>(params, params + count);
  copy->emplace_back(constant_range{0,0,56,4,shader_stage::all_ray_tracing});
  params = copy->data(); ++count; data->extended.push_back(std::move(copy));
  return true;
}
// HartapfelFX appends its cloud visibility buffer after the shared ray roots.
inline uint32_t NativeControlCount(uint32_t count, const pipeline_layout_param* params) {
  if (volumetrics::rays::FindProducerRootSuffix(count, params).Valid()) count -= 3;
  if ((count == 6 || count == 17) && IsGlobalLayout(count, params)) {
    const auto* root = bindings::RootDescriptor(params[count - 1]);
    if (root && root->type == descriptor_type::buffer_shader_resource_view && root->dx_register_space == 72
        && root->dx_register_index == 0 && root->count == 1) --count;
  }
  return count;
}
inline void OnLayout(device* dev, uint32_t count, const pipeline_layout_param* params, pipeline_layout layout) {
  count = NativeControlCount(count, params);
  if ((count != 5 && count != 7 && count != 16) || !IsGlobalLayout(count, params) || params[4].type != pipeline_layout_param_type::push_constants) return;
  if (count != 5) {
    for (uint32_t slot = 0; slot < (count == 16 ? 3u : 1u); ++slot) {
      const auto& context = params[5 + slot * 2];
      const auto* output = bindings::RootDescriptor(params[6 + slot * 2]);
      if (context.type != pipeline_layout_param_type::push_constants
          || context.push_constants.dx_register_space != 59 || context.push_constants.dx_register_index != slot
          || context.push_constants.count != 4 || !output || output->dx_register_space != 59
          || output->dx_register_index != slot || output->count != 1
          || output->type != descriptor_type::buffer_unordered_access_view) return;
    }
    if (count == 16) for (uint32_t i = 11; i < 13; ++i) {
      const auto* range = bindings::RootDescriptor(params[i]);
      if (!range || range->dx_register_space != 59 || range->dx_register_index != (i == 11 ? 3u : 1u) || range->count != 1
          || range->type != (i == 11 ? descriptor_type::constant_buffer : descriptor_type::buffer_shader_resource_view)) return;
    }
    if (count == 16) for (uint32_t i = 13; i < 15; ++i) {
      const auto* range = i == 13 ? bindings::RootDescriptor(params[i])
          : params[i].type == pipeline_layout_param_type::descriptor_table && params[i].descriptor_table.count == 1
              ? params[i].descriptor_table.ranges : nullptr;
      if (!range || range->dx_register_space != 55 || range->dx_register_index != 0 || range->count != 1
          || range->binding != 0 || (uint32_t(range->visibility) & uint32_t(shader_stage::all_ray_tracing)) != uint32_t(shader_stage::all_ray_tracing)
          || range->type != (i == 13 ? descriptor_type::buffer_shader_resource_view : descriptor_type::constant_buffer)) return;
    }
    if (count == 16) {
      const auto* water = bindings::RootDescriptor(params[15]);
      if (!water || water->dx_register_space != 58 || water->dx_register_index != 0 || water->count != 1
          || water->binding != 0 || water->type != descriptor_type::buffer_shader_resource_view
          || (uint32_t(water->visibility) & uint32_t(shader_stage::all_ray_tracing)) != uint32_t(shader_stage::all_ray_tracing)) return;
    }
  }
  const auto& range = params[4].push_constants;
  if (range.dx_register_index != 0 || range.dx_register_space != 56 || range.count != 4) return;
  if (auto* data = renodx::utils::data::Get<ControlData>(dev)) {
    std::lock_guard lock(data->mutex); data->layouts[layout.handle] = 4;
  }
}
inline void OnDestroyLayout(device* dev, pipeline_layout layout) {
  if (auto* data = renodx::utils::data::Get<ControlData>(dev)) {
    std::lock_guard lock(data->mutex); data->layouts.erase(layout.handle);
  }
}
inline bool BindControls(command_list* cmd) {
  auto* data = renodx::utils::data::Get<ControlData>(cmd->get_device());
  const auto* roots = renodx::utils::data::Get<bindings::CommandData>(cmd);
  if (!data || !roots) return false;
  const bool inputs_bound = !bind_path_inputs || bind_path_inputs(cmd);
  std::lock_guard lock(data->mutex);
  const auto found = data->layouts.find(roots->compute.layout.handle);
  if (found == data->layouts.end()) return false;
  const auto state = data->states.find(roots->last_pipeline.handle);
  const bool available = !data->water_failed && ((data->required_libraries == 0 && data->reflection_libraries == 0) || (state != data->states.end()
      && state->second.root == roots->compute.layout.handle
      && (state->second.libraries & data->required_libraries) != 0 && WaterReady(*data)));
  const bool reflection = state != data->states.end() && state->second.root == roots->compute.layout.handle
      && (state->second.libraries & data->reflection_libraries) != 0;
  // RT hit materials do not require PT's three water libraries to be loaded.
  // The water bit remains governed by their complete, independently valid set.
  const uint32_t enabled = inputs_bound ? controls.load(std::memory_order_acquire) & (available ? 7u : reflection ? 5u : 0u) : 0u;
  const std::array<float, 4> values{1.f, (enabled & 1u) ? 1.f : 0.f,
      (enabled & 2u) ? 1.f : 0.f, (enabled & 4u) ? 1.f : 0.f};
  cmd->push_constants(shader_stage::all_ray_tracing, roots->compute.layout, found->second, 0, 4, values.data());
  return true;
}
inline bool OnDispatch(command_list* cmd, resource, uint64_t, uint64_t, resource, uint64_t, uint64_t, uint64_t,
    resource, uint64_t, uint64_t, uint64_t, resource, uint64_t, uint64_t, uint64_t, uint32_t, uint32_t, uint32_t) {
  BindControls(cmd); return false;
}
inline void OnInit(device* dev) { if (dev->get_api() == device_api::d3d12) renodx::utils::data::Create<ControlData>(dev); }
inline void OnDestroy(device* dev) { renodx::utils::data::Delete<ControlData>(dev); }
inline void OnDestroyState(device* dev, pipeline state) {
  if (auto* data = renodx::utils::data::Get<ControlData>(dev)) {
    std::lock_guard lock(data->mutex); data->states.erase(state.handle);
  }
}
inline void UseControls(DWORD reason, bool bind_dispatch = true) {
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::init_device>(OnInit);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroy);
    reshade::register_event<reshade::addon_event::create_pipeline_layout>(OnCreateLayout);
    reshade::register_event<reshade::addon_event::init_pipeline_layout>(OnLayout);
    reshade::register_event<reshade::addon_event::destroy_pipeline_layout>(OnDestroyLayout);
    if (bind_dispatch) reshade::register_event<reshade::addon_event::dispatch_rays>(OnDispatch);
    reshade::register_event<reshade::addon_event::destroy_pipeline>(OnDestroyState);
  } else if (reason == DLL_PROCESS_DETACH) {
    controls.store(0, std::memory_order_release);
    reshade::unregister_event<reshade::addon_event::destroy_pipeline>(OnDestroyState);
    if (bind_dispatch) reshade::unregister_event<reshade::addon_event::dispatch_rays>(OnDispatch);
    reshade::unregister_event<reshade::addon_event::destroy_pipeline_layout>(OnDestroyLayout);
    reshade::unregister_event<reshade::addon_event::init_pipeline_layout>(OnLayout);
    reshade::unregister_event<reshade::addon_event::create_pipeline_layout>(OnCreateLayout);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroy);
    reshade::unregister_event<reshade::addon_event::init_device>(OnInit);
  }
}
}  // namespace witcher3graphics::raytracing
