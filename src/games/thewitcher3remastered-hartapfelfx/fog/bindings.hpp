// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <array>
#include <atomic>
#include <optional>
#include "../../../utils/command_action.hpp"
#include "../../../utils/descriptor.hpp"
#include "binding_layout.hpp"
#include "../descriptor_cache.hpp"

namespace hartapfelfx::fog {
namespace api = reshade::api;
inline std::atomic_uint64_t sun_captures = 0, fog_matches = 0, fog_fallbacks = 0;
inline std::atomic_uint64_t interior_captures = 0, interior_matches = 0;
inline std::function<void(api::command_list*, bool)> on_sun;
inline const float* sun_enabled = nullptr;
inline std::function<void(api::command_list*, bool)> before_sun;
inline std::function<void(api::command_list*, bool)> after_sun;
inline std::function<uint64_t(api::command_list*, bool)> cloud_source;
inline std::function<void(api::command_list*)> on_interior;
inline std::function<void(api::command_list*, bool)> on_local;
struct __declspec(uuid("01a25d9c-c9d3-7c34-8523-c9cfd2dff618")) DeviceData {
  std::shared_mutex mutex;
  std::unordered_map<uint64_t, BindingLayout> layouts;
};
struct BindingState {
  api::pipeline_layout layout{};
  std::array<api::descriptor_table, 64> tables{};
  std::array<api::buffer_range, 64> buffers{};
  std::array<uint64_t, 64> addresses{};
  void SetLayout(api::pipeline_layout value) {
    if (layout == value) return;
    layout = value;
    tables = {};
    buffers = {};
    addresses = {};
  }
};
struct Inputs {
  api::buffer_range frame{}, light{};
  api::resource_view cascades{};
};
struct __declspec(uuid("01a25c4d-6745-7b34-8e4d-c26dc34f3593")) CommandData {
  BindingState graphics, compute;
  Inputs sun;
};
inline bool OnCreateLayout(api::device* device, uint32_t& parameter_count, api::pipeline_layout_param*& parameter_data) {
  if (device->get_api() != api::device_api::d3d12) return false;
  static thread_local std::vector<api::pipeline_layout_param> extended;
  if (!ExtendFogLayout({parameter_data, parameter_count}, &extended)) return false;
  parameter_count = uint32_t(extended.size());
  parameter_data = extended.data();
  return true;
}

// Resolve the native register through its actual root signature. Root CBVs and
// tables have different representations, and compute/graphics state is separate.
inline renodx::utils::descriptor::DescriptorHeapSlot Resolve(
    api::command_list* cmd, const BindingState& state, api::descriptor_type type, uint32_t slot, uint32_t space = 0) {
  renodx::utils::descriptor::DescriptorHeapSlot result;
  auto* device = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if (!device) return result;
  std::shared_lock layout_lock(device->mutex);
  const auto layout = device->layouts.find(state.layout.handle);
  if (layout == device->layouts.end()) return result;
  for (uint32_t p = 0; p < layout->second.parameters.size() && p < 64; ++p) {
    const auto& param = layout->second.parameters[p];
    for (const auto& range : param.ranges) {
      if (range.type != type || range.dx_register_space != space || slot < range.dx_register_index
          || slot - range.dx_register_index >= range.count) continue;
      if (!param.table) {
        if (type != api::descriptor_type::constant_buffer || range.count != 1) continue;
        result.type = type;
        result.buffer_range = state.buffers[p];
        return result;
      }
      if (!state.tables[p].handle) continue;
      return descriptors::Read(cmd->get_device(), state.tables[p], range.binding + slot - range.dx_register_index);
    }
  }
  return result;
}
inline void OnInitDevice(api::device* device) { renodx::utils::data::Create<DeviceData>(device); }
inline void OnDestroyDevice(api::device* device) { renodx::utils::data::Delete<DeviceData>(device); }
inline void OnInitLayout(api::device* device, uint32_t count, const api::pipeline_layout_param* params, api::pipeline_layout layout) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(device)) {
    std::unique_lock lock(data->mutex);
    data->layouts.insert_or_assign(layout.handle, BindingLayout(count, params));
  }
}
inline void OnDestroyLayout(api::device* device, api::pipeline_layout layout) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(device)) {
    std::unique_lock lock(data->mutex);
    data->layouts.erase(layout.handle);
  }
}
inline void OnInitCommandList(api::command_list* cmd) { renodx::utils::data::Create<CommandData>(cmd); }
inline void OnDestroyCommandList(api::command_list* cmd) { renodx::utils::data::Delete<CommandData>(cmd); }
inline void OnResetCommandList(api::command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) *data = {};
}
inline void OnBindTables(api::command_list* cmd, api::shader_stage stages, api::pipeline_layout layout,
                         uint32_t first, uint32_t count, const api::descriptor_table* tables) {
  auto* data = renodx::utils::data::Get<CommandData>(cmd);
  if (!data || first >= 64 || count > 64 - first) return;
  for (auto [flag, state] : {std::pair{api::shader_stage::all_graphics, &data->graphics},
                             std::pair{api::shader_stage::all_compute | api::shader_stage::all_ray_tracing, &data->compute}}) {
    if ((stages & flag) == static_cast<api::shader_stage>(0)) continue;
    state->SetLayout(layout);
    std::copy_n(tables, count, state->tables.begin() + first);
  }
}
inline void OnPushDescriptors(api::command_list* cmd, api::shader_stage stages, api::pipeline_layout layout,
                              uint32_t parameter, const api::descriptor_table_update& update) {
  auto* data = renodx::utils::data::Get<CommandData>(cmd);
  if (!data || parameter >= 64) return;
  for (auto [flag, state] : {std::pair{api::shader_stage::all_graphics, &data->graphics},
                             std::pair{api::shader_stage::all_compute | api::shader_stage::all_ray_tracing, &data->compute}}) {
    if ((stages & flag) == static_cast<api::shader_stage>(0)) continue;
    state->SetLayout(layout);
    if (update.type == api::descriptor_type::constant_buffer && update.count == 1 && update.descriptors)
      state->buffers[parameter] = *static_cast<const api::buffer_range*>(update.descriptors);
    if ((update.type == api::descriptor_type::buffer_shader_resource_view || update.type == api::descriptor_type::buffer_unordered_access_view
         || update.type == api::descriptor_type::acceleration_structure) && update.count == 1 && update.descriptors)
      state->addresses[parameter] = cmd->get_device()->get_resource_view_gpu_address(*static_cast<const api::resource_view*>(update.descriptors));
  }
}
inline bool CaptureSun(api::command_list* cmd, bool compute) {
  auto* data = renodx::utils::data::Get<CommandData>(cmd);
  if (!data) return false;
  const auto& state = compute ? data->compute : data->graphics;
  const auto frame = Resolve(cmd, state, api::descriptor_type::constant_buffer, 12);
  const auto light = Resolve(cmd, state, api::descriptor_type::constant_buffer, 13);
  const auto shadows = Resolve(cmd, state, api::descriptor_type::texture_shader_resource_view, 8);
  if (frame.type != api::descriptor_type::constant_buffer || light.type != api::descriptor_type::constant_buffer
      || !frame.buffer_range.buffer.handle || !light.buffer_range.buffer.handle
      || !shadows.HasResourceView() || !shadows.resource_view.handle) return false;
  if (frame.buffer_range.size < 341u * 16u || light.buffer_range.size < 3589u * 16u) return false;
  const auto desc = cmd->get_device()->get_resource_desc(cmd->get_device()->get_resource_from_view(shadows.resource_view));
  if (desc.type != api::resource_type::texture_2d || desc.texture.depth_or_layers != 4) return false;
  const auto depth = Resolve(cmd, state, api::descriptor_type::texture_shader_resource_view, 0);
  if (!depth.HasResourceView() || !depth.resource_view.handle) return false;
  if (!IsFogDepthInput(cmd->get_device()->get_resource_desc(cmd->get_device()->get_resource_from_view(depth.resource_view)),
                       cmd->get_device()->get_resource_view_desc(depth.resource_view))) return false;
  data->sun = {frame.buffer_range, light.buffer_range, shadows.resource_view};
  ++sun_captures;
  return true;
}
inline void OnBarrier(api::command_list* cmd, uint32_t count, const api::resource* resources,
                      const api::resource_usage*, const api::resource_usage* after) {
  auto* data = renodx::utils::data::Get<CommandData>(cmd);
  if (!data || !data->sun.cascades.handle) return;
  const auto shadow = cmd->get_device()->get_resource_from_view(data->sun.cascades);
  for (uint32_t i = 0; i < count; ++i) {
    if ((resources[i] == shadow && (after[i] & api::resource_usage::shader_resource_pixel) == api::resource_usage::undefined)
        || ((resources[i] == data->sun.light.buffer || resources[i] == data->sun.frame.buffer)
            && (after[i] & api::resource_usage::constant_buffer) == api::resource_usage::undefined))
      data->sun = {};
  }
}
inline constexpr auto ObserveSun = []<typename Context>(Context& context)
    -> renodx::utils::command_action::CallbackResult<Context> {
  if (before_sun) before_sun(context.cmd_list, context.IsDispatch());
  if (sun_enabled && *sun_enabled > .5f && CaptureSun(context.cmd_list, context.IsDispatch())) {
    if (on_sun) on_sun(context.cmd_list, context.IsDispatch());
  }
  if (after_sun) after_sun(context.cmd_list, context.IsDispatch());
  return {};
};
inline constexpr auto ObserveInterior = []<typename Context>(Context& context)
    -> renodx::utils::command_action::CallbackResult<Context> {
  if (on_interior) on_interior(context.cmd_list);
  return {};
};
inline constexpr auto ObserveLocal = []<typename Context>(Context& context)
    -> renodx::utils::command_action::CallbackResult<Context> {
  if (on_local) on_local(context.cmd_list, context.matched_shader_hash == 0xE6A77B56u);
  return {};
};
inline void Use(DWORD reason) {
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::create_pipeline_layout>(OnCreateLayout);
    reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::register_event<reshade::addon_event::init_pipeline_layout>(OnInitLayout);
    reshade::register_event<reshade::addon_event::destroy_pipeline_layout>(OnDestroyLayout);
    reshade::register_event<reshade::addon_event::init_command_list>(OnInitCommandList);
    reshade::register_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
    reshade::register_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
    reshade::register_event<reshade::addon_event::bind_descriptor_tables>(OnBindTables);
    reshade::register_event<reshade::addon_event::push_descriptors>(OnPushDescriptors);
    reshade::register_event<reshade::addon_event::barrier>(OnBarrier);
    renodx::utils::command_action::RegisterCallback(ObserveInterior, {.shader_hash = 0x8BDE805Bu});
    // Observers must not participate in settings injection or replacement PSOs.
    for (auto hash : {0x806C62A8u, 0x4A7A44D6u, 0xD2C88922u})
      renodx::utils::command_action::RegisterCallback(ObserveSun, {.shader_hash = hash});
    for (auto hash : {0xE6A77B56u, 0x9A6F318Eu})
      renodx::utils::command_action::RegisterCallback(ObserveLocal, {.shader_hash = hash});
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::create_pipeline_layout>(OnCreateLayout);
    renodx::utils::command_action::Unregister(ObserveSun);
    renodx::utils::command_action::Unregister(ObserveInterior);
    renodx::utils::command_action::Unregister(ObserveLocal);
    reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::unregister_event<reshade::addon_event::init_pipeline_layout>(OnInitLayout);
    reshade::unregister_event<reshade::addon_event::destroy_pipeline_layout>(OnDestroyLayout);
    reshade::unregister_event<reshade::addon_event::init_command_list>(OnInitCommandList);
    reshade::unregister_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
    reshade::unregister_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
    reshade::unregister_event<reshade::addon_event::bind_descriptor_tables>(OnBindTables);
    reshade::unregister_event<reshade::addon_event::push_descriptors>(OnPushDescriptors);
    reshade::unregister_event<reshade::addon_event::barrier>(OnBarrier);
  }
}
}  // namespace hartapfelfx::fog
