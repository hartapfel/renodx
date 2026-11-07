// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "controls.hpp"

namespace witcher3graphics::raytracing::hits {
enum class LayoutRole { none, producer, consumer };
inline constexpr descriptor_range path_cloud_frame_range{0, 0, 55, 1, shader_stage::all_ray_tracing, 1, descriptor_type::constant_buffer};
struct HitRoots {
  LayoutRole role = LayoutRole::none;
  uint32_t context = UINT32_MAX, buffer = UINT32_MAX;
  uint32_t identifiers = UINT32_MAX, raygen = UINT32_MAX;
  uint32_t cloud = UINT32_MAX;
  uint32_t cloud_frame = UINT32_MAX;
  uint32_t water = UINT32_MAX;
};
struct __declspec(uuid("93486174-2ba0-401c-b26e-9e153dd26b32")) LayoutData {
  std::mutex mutex;
  std::vector<std::unique_ptr<std::vector<pipeline_layout_param>>> extended;
  std::unordered_map<uint64_t, HitRoots> layouts;
  resource inactive{};
  resource_view inactive_uav{};
  resource neutral{};
  resource_view neutral_srv{};
};

// Match the native global ray layout or the reflection compute register family.
// This is layout admission only; shader hashes and publication still decide
// whether a particular dispatch can use material records.
inline LayoutRole AdmitLayout(uint32_t count, const pipeline_layout_param* params) {
  if (!params || count > 64) return LayoutRole::none;
  uint64_t cost = 0;
  uint32_t camera = 0, inputs = 0, probe_camera = 0, probe_inputs = 0;
  bool output = false, probe_output = false, collision = false, water_collision = false, hdr = false, graphics = false;
  const auto inspect = [&](const descriptor_range& range, bool native_root = false) {
    collision |= range.dx_register_space == 59 || range.dx_register_space == 55;
    water_collision |= range.dx_register_space == 58;
    if (range.type == descriptor_type::constant_buffer) {
      hdr |= range.dx_register_space == 50 && range.dx_register_index == 13;
      graphics |= range.dx_register_space == 51 && range.dx_register_index == 13;
    }
    if (range.dx_register_space != 0 || (uint32_t(range.visibility) & uint32_t(shader_stage::compute)) == 0) return;
    const auto covers = [&](uint32_t slot) {
      return slot >= range.dx_register_index && slot - range.dx_register_index < range.count;
    };
    if (range.type == descriptor_type::constant_buffer) {
      // Reflection/probe lighting binds its camera buffers as individual root
      // CBVs. The general compute layout exposes b1..b15 in a table and also
      // covers these register numbers, but is used by postprocessing/NIS.
      // Extending that layout with constants prevents the HDR/settings CBVs
      // from being appended and makes unrelated replacement PSOs fail.
      if (!native_root || range.count != 1) return;
      constexpr std::array<uint32_t, 7> registers{0, 7, 9, 10, 12, 13, 14};
      for (uint32_t i = 0; i < registers.size(); ++i) if (covers(registers[i])) camera |= 1u << i;
      constexpr std::array<uint32_t, 6> probe_registers{0, 7, 8, 9, 12, 13};
      for (uint32_t i = 0; i < probe_registers.size(); ++i) if (covers(probe_registers[i])) probe_camera |= 1u << i;
    } else if (range.type == descriptor_type::texture_shader_resource_view) {
      constexpr std::array<uint32_t, 4> registers{5, 11, 12, 13};
      for (uint32_t i = 0; i < registers.size(); ++i) if (covers(registers[i])) inputs |= 1u << i;
      for (uint32_t i = 0; i < 3; ++i) if (covers(i)) probe_inputs |= 1u << i;
    } else if (range.type == descriptor_type::texture_unordered_access_view) { output |= covers(5); probe_output |= covers(4); }
  };
  for (uint32_t i = 0; i < count; ++i) {
    const auto& param = params[i];
    if (param.type == pipeline_layout_param_type::push_constants) {
      cost += param.push_constants.count;
      collision |= param.push_constants.dx_register_space == 59 || param.push_constants.dx_register_space == 55;
      water_collision |= param.push_constants.dx_register_space == 58;
    } else if (const auto* range = bindings::RootDescriptor(param)) {
      if (range->count > 1 || range->type == descriptor_type::texture_shader_resource_view
          || range->type == descriptor_type::texture_unordered_access_view || range->type == descriptor_type::sampler) ++cost;
      else if (range->type == descriptor_type::constant_buffer || range->type == descriptor_type::buffer_shader_resource_view
          || range->type == descriptor_type::buffer_unordered_access_view || range->type == descriptor_type::shader_storage_buffer) cost += 2;
      else return LayoutRole::none;
      inspect(*range, true);
    } else if (param.type == pipeline_layout_param_type::descriptor_table) {
      ++cost;
      for (uint32_t j = 0; j < param.descriptor_table.count; ++j) inspect(param.descriptor_table.ranges[j]);
    } else if (param.type == pipeline_layout_param_type::descriptor_table_with_static_samplers
        || param.type == pipeline_layout_param_type::push_descriptors_with_static_samplers) {
      // ReShade preserves API parameter indices. Appending after a static-only
      // pseudo-parameter makes create_pipeline_layout insert a one-DWORD dummy
      // constant at that index (space255), even though samplers cost no roots.
      ++cost;
      for (uint32_t j = 0; j < param.descriptor_table_with_static_samplers.count; ++j) {
        const auto& range = param.descriptor_table_with_static_samplers.ranges[j];
        if (param.type == pipeline_layout_param_type::push_descriptors_with_static_samplers
            && (range.type != descriptor_type::sampler || !range.static_samplers)) return LayoutRole::none;
        inspect(range);
      }
    } else return LayoutRole::none;
  }
  if (collision) return LayoutRole::none;
  // Controls must precede the hit extension. No extra register spaces are
  // accepted on this global root until they have been explicitly accounted for.
  if (count == 5 && IsGlobalLayout(count, params)
      && params[4].type == pipeline_layout_param_type::push_constants
      && params[4].push_constants.dx_register_space == 56
      && params[4].push_constants.dx_register_index == 0 && params[4].push_constants.count == 4)
    return !water_collision && cost + 27 <= 64 ? LayoutRole::producer : LayoutRole::none;
  // Reserve the two CBV settings roots even when the other addon loads later.
  if (((camera == 127 && inputs == 15 && output) || (probe_camera == 63 && probe_inputs == 7 && probe_output))
      && cost + 6 + (hdr ? 0 : 2) + (graphics ? 0 : 2) <= 64)
    return LayoutRole::consumer;
  return LayoutRole::none;
}
inline bool OnCreateHitLayout(device* dev, uint32_t& count, pipeline_layout_param*& params) {
  auto* data = renodx::utils::data::Get<LayoutData>(dev);
  if (!data) return false;
  const auto role = AdmitLayout(count, params);
  if (role == LayoutRole::none || (role == LayoutRole::producer && !data->inactive_uav.handle)) return false;
  std::lock_guard lock(data->mutex);
  auto copy = std::make_unique<std::vector<pipeline_layout_param>>(params, params + count);
  const auto stage = role == LayoutRole::producer ? shader_stage::all_ray_tracing : shader_stage::compute;
  for (uint32_t slot = 0; slot < (role == LayoutRole::producer ? 3u : 1u); ++slot) {
    if (role == LayoutRole::producer) copy->emplace_back(constant_range{0, slot, 59, 4, stage});
    else copy->emplace_back(descriptor_range{0, slot, 59, 1, stage, 1, descriptor_type::constant_buffer});
    copy->emplace_back(descriptor_range{0, slot, 59, 1, stage, 1, role == LayoutRole::producer
        ? descriptor_type::buffer_unordered_access_view : descriptor_type::buffer_shader_resource_view});
  }
  if (role == LayoutRole::producer) {
    copy->emplace_back(descriptor_range{0, 3, 59, 1, shader_stage::compute, 1, descriptor_type::constant_buffer});
    copy->emplace_back(descriptor_range{0, 1, 59, 1, shader_stage::compute, 1, descriptor_type::buffer_shader_resource_view});
    copy->emplace_back(descriptor_range{0, 0, 55, 1, shader_stage::all_ray_tracing, 1, descriptor_type::buffer_shader_resource_view});
    copy->emplace_back(1, &path_cloud_frame_range);
    copy->emplace_back(descriptor_range{0, 0, 58, 1, shader_stage::all_ray_tracing, 1, descriptor_type::buffer_shader_resource_view});
  } else {
    copy->emplace_back(descriptor_range{0, 0, 55, 1, shader_stage::compute, 1, descriptor_type::buffer_shader_resource_view});
  }
  params = copy->data(); count = uint32_t(copy->size()); data->extended.push_back(std::move(copy));
  return true;
}
inline void OnHitLayout(device* dev, uint32_t count, const pipeline_layout_param* params, pipeline_layout layout) {
  count = NativeControlCount(count, params);
  auto* data = renodx::utils::data::Get<LayoutData>(dev);
  if (!data || count < 2) return;
  HitRoots roots;
  // Locate the extension independently of later settings injection. Re-check
  // its native prefix and both exact private root types before storing indices.
  for (uint32_t i = 0; i + 1 < count; ++i) {
    const auto& context = params[i];
    const auto* context_buffer = bindings::RootDescriptor(context);
    const auto* buffer = bindings::RootDescriptor(params[i + 1]);
    const bool inline_context = context.type == pipeline_layout_param_type::push_constants
        && context.push_constants.dx_register_space == 59 && context.push_constants.dx_register_index == 0
        && context.push_constants.count == 4;
    const bool buffered_context = context_buffer && context_buffer->type == descriptor_type::constant_buffer
        && context_buffer->dx_register_space == 59 && context_buffer->dx_register_index == 0 && context_buffer->count == 1;
    if ((!inline_context && !buffered_context) || !buffer || buffer->dx_register_space != 59
        || buffer->dx_register_index != 0 || buffer->count != 1) continue;
    roots.role = AdmitLayout(i, params);
    if (roots.role == LayoutRole::none) return;
    const auto stage = roots.role == LayoutRole::producer ? shader_stage::all_ray_tracing : shader_stage::compute;
    if ((roots.role == LayoutRole::producer ? !inline_context : !buffered_context)
        || (uint32_t(inline_context ? context.push_constants.visibility : context_buffer->visibility) & uint32_t(stage)) != uint32_t(stage)
        || (uint32_t(buffer->visibility) & uint32_t(stage)) != uint32_t(stage)
        || buffer->type != (roots.role == LayoutRole::producer ? descriptor_type::buffer_unordered_access_view
                                                             : descriptor_type::buffer_shader_resource_view)) return;
    roots.context = i; roots.buffer = i + 1;
    if (roots.role == LayoutRole::producer) {
      if (count != i + 11) return;
      for (uint32_t slot = 1; slot < 3; ++slot) {
        const auto& extra = params[i + slot * 2];
        const auto* output = bindings::RootDescriptor(params[i + slot * 2 + 1]);
        if (extra.type != pipeline_layout_param_type::push_constants || extra.push_constants.dx_register_space != 59
            || extra.push_constants.dx_register_index != slot || extra.push_constants.count != 4
            || !output || output->dx_register_space != 59 || output->dx_register_index != slot || output->count != 1
            || output->type != descriptor_type::buffer_unordered_access_view
            || (uint32_t(extra.push_constants.visibility) & uint32_t(stage)) != uint32_t(stage)
            || (uint32_t(output->visibility) & uint32_t(stage)) != uint32_t(stage)) return;
      }
      for (uint32_t offset = 6; offset < 8; ++offset) {
        const auto* range = bindings::RootDescriptor(params[i + offset]);
        if (!range || range->dx_register_space != 59 || range->dx_register_index != (offset == 6 ? 3u : 1u)
            || range->count != 1 || (uint32_t(range->visibility) & uint32_t(shader_stage::compute)) == 0
            || range->type != (offset == 6 ? descriptor_type::constant_buffer : descriptor_type::buffer_shader_resource_view)) return;
      }
      roots.identifiers = i + 6; roots.raygen = i + 7;
      for (uint32_t offset = 8; offset < 10; ++offset) {
        const auto& parameter = params[i + offset];
        const auto* range = offset == 8 ? bindings::RootDescriptor(parameter)
            : parameter.type == pipeline_layout_param_type::descriptor_table && parameter.descriptor_table.count == 1
                ? parameter.descriptor_table.ranges : nullptr;
        if (!range || range->dx_register_space != 55 || range->dx_register_index != 0 || range->count != 1
            || range->binding != 0 || (uint32_t(range->visibility) & uint32_t(stage)) != uint32_t(stage)
            || range->type != (offset == 8 ? descriptor_type::buffer_shader_resource_view : descriptor_type::constant_buffer)) return;
      }
      roots.cloud = i + 8; roots.cloud_frame = i + 9;
      const auto* water = bindings::RootDescriptor(params[i + 10]);
      if (!water || water->dx_register_space != 58 || water->dx_register_index != 0 || water->count != 1
          || water->binding != 0 || water->type != descriptor_type::buffer_shader_resource_view
          || (uint32_t(water->visibility) & uint32_t(stage)) != uint32_t(stage)) return;
      roots.water = i + 10;
    } else {
      if (i + 2 >= count) return;
      const auto* cloud = bindings::RootDescriptor(params[i + 2]);
      if (!cloud || cloud->type != descriptor_type::buffer_shader_resource_view || cloud->dx_register_space != 55
          || cloud->dx_register_index != 0 || cloud->count != 1 || cloud->binding != 0
          || (uint32_t(cloud->visibility) & uint32_t(shader_stage::compute)) == 0) return;
      roots.cloud = i + 2;
    }
    std::lock_guard lock(data->mutex); data->layouts[layout.handle] = roots;
    return;
  }
}
inline HitRoots FindHitRoots(device* dev, pipeline_layout layout) {
  if (auto* data = renodx::utils::data::Get<LayoutData>(dev)) {
    std::lock_guard lock(data->mutex);
    if (const auto found = data->layouts.find(layout.handle); found != data->layouts.end()) return found->second;
  }
  return {};
}
inline void OnHitLayoutDestroy(device* dev, pipeline_layout layout) {
  if (auto* data = renodx::utils::data::Get<LayoutData>(dev)) {
    std::lock_guard lock(data->mutex); data->layouts.erase(layout.handle);
  }
}
inline void OnLayoutDevice(device* dev) {
  if (dev->get_api() != device_api::d3d12) return;
  auto* data = renodx::utils::data::Create<LayoutData>(dev);
  // Invalid context suppresses every Store in the writer. Keep a real, bounded
  // UAV bound even when inputs/allocation/controls decline a material producer.
  if (dev->create_resource(resource_desc(uint64_t(64), memory_heap::gpu_only, resource_usage::unordered_access),
          nullptr, resource_usage::unordered_access, &data->inactive))
    dev->create_resource_view(data->inactive, resource_usage::unordered_access,
        resource_view_desc(format::r32_typeless, uint64_t(0), uint64_t(16)), &data->inactive_uav);
  // Water receivers can run without an admitted PBR material producer. Bind a
  // zero context and real read-only storage, never a stale producer address.
  if (dev->create_resource(resource_desc(uint64_t(256), memory_heap::cpu_to_gpu,
          resource_usage::shader_resource | resource_usage::constant_buffer),
          nullptr, resource_usage::general, &data->neutral)) {
    void* mapped = nullptr;
    if (dev->map_buffer_region(data->neutral, 0, 256, map_access::write_only, &mapped)) {
      std::memset(mapped, 0, 256); dev->unmap_buffer_region(data->neutral);
      dev->create_resource_view(data->neutral, resource_usage::shader_resource,
          resource_view_desc(format::r32_typeless, uint64_t(0), uint64_t(20)), &data->neutral_srv);
    }
  }
}
inline void OnLayoutDeviceDestroy(device* dev) {
  auto* data = renodx::utils::data::Get<LayoutData>(dev);
  if (!data) return;
  if (data->inactive_uav.handle) dev->destroy_resource_view(data->inactive_uav);
  if (data->inactive.handle) dev->destroy_resource(data->inactive);
  if (data->neutral_srv.handle) dev->destroy_resource_view(data->neutral_srv);
  if (data->neutral.handle) dev->destroy_resource(data->neutral);
  renodx::utils::data::Delete<LayoutData>(dev);
}
inline bool BindInactive(command_list* cmd, pipeline_layout layout, const HitRoots& roots) {
  const auto* data = renodx::utils::data::Get<LayoutData>(cmd->get_device());
  if (!data || !data->inactive_uav.handle || roots.role != LayoutRole::producer) return false;
  const std::array<uint32_t, 4> context{};
  for (uint32_t slot = 0; slot < 3; ++slot) {
    cmd->push_constants(shader_stage::all_ray_tracing, layout, roots.context + slot * 2, 0, 4, context.data());
    cmd->push_descriptors(shader_stage::all_ray_tracing, layout, roots.buffer + slot * 2,
        {{}, 0, 0, 1, descriptor_type::buffer_unordered_access_view, &data->inactive_uav});
  }
  return true;
}
inline void UseLayouts(DWORD reason) {
#define W3_HIT_LAYOUT_EVENT(event, callback) \
  if (reason == DLL_PROCESS_ATTACH) reshade::register_event<reshade::addon_event::event>(callback); \
  else if (reason == DLL_PROCESS_DETACH) reshade::unregister_event<reshade::addon_event::event>(callback)
  W3_HIT_LAYOUT_EVENT(init_device, OnLayoutDevice);
  W3_HIT_LAYOUT_EVENT(destroy_device, OnLayoutDeviceDestroy);
  W3_HIT_LAYOUT_EVENT(create_pipeline_layout, OnCreateHitLayout);
  W3_HIT_LAYOUT_EVENT(init_pipeline_layout, OnHitLayout);
  W3_HIT_LAYOUT_EVENT(destroy_pipeline_layout, OnHitLayoutDestroy);
#undef W3_HIT_LAYOUT_EVENT
}
}  // namespace witcher3graphics::raytracing::hits
