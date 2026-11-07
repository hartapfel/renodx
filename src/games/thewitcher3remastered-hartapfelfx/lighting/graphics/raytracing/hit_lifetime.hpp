// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "../../../../../utils/state.hpp"
#include "hit_targets.hpp"
#include "../../../../../utils/shader.hpp"

namespace witcher3graphics::raytracing::hits {
inline bool manages_ray_dispatches = false;
struct __declspec(uuid("050a0678-2072-4de8-b589-b81ba1ce6cc2")) DeviceData {
  explicit DeviceData(device* dev) : pool(dev) {}
  HitTargetTracker targets;
  HitPool pool;
};
struct __declspec(uuid("039bde79-94cf-4894-b3b8-667ead2fe814")) CommandData {
  std::shared_ptr<HitRecording> recording = std::make_shared<HitRecording>();
};
inline void OnDevice(device* dev) {
  if (dev->get_api() == device_api::d3d12) renodx::utils::data::Create<DeviceData>(dev, dev);
}
inline void OnDeviceDestroy(device* dev) {
  auto* data = renodx::utils::data::Get<DeviceData>(dev);
  dev->set_private_data(reinterpret_cast<const uint8_t*>(&renodx::utils::data::GetUuid<DeviceData>()), 0);
  delete data;
}
inline void OnCommand(command_list* cmd) {
  if (renodx::utils::data::Get<DeviceData>(cmd->get_device())) renodx::utils::data::Create<CommandData>(cmd);
}
inline void OnReset(command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) data->recording = std::make_shared<HitRecording>();
}
inline void OnCommandDestroy(command_list* cmd) { renodx::utils::data::Delete<CommandData>(cmd); }
inline void OnResource(device* dev, const resource_desc& desc, const subresource_data*, resource_usage, resource object) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(dev)) data->targets.Created(object, desc);
}
inline void OnResourceDestroy(device* dev, resource object) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(dev); data && data->targets.Destroyed(object))
    data->pool.Invalidate(object.handle);
}
inline void Written(device* dev, resource object) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(dev); data && data->pool.Active() && data->targets.Contains(object))
    data->pool.Invalidate(object.handle);
}
inline void OnBarrier(command_list* cmd, uint32_t count, const resource* resources,
    const resource_usage* before, const resource_usage* after) {
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if (!data || !data->pool.Active()) return;
  for (uint32_t i = 0; i < count; ++i) {
    // ReShade reports only the AFTER resource for aliasing. A null or unrelated
    // after-resource does not prove that the preceding target survived.
    if (before[i] == resource_usage::undefined) { data->pool.Invalidate(); return; }
    constexpr auto writes = resource_usage::unordered_access | resource_usage::copy_dest | resource_usage::render_target;
    if (before[i] != after[i] && (after[i] & writes) != resource_usage::undefined)
      Written(cmd->get_device(), resources[i]);
    // UAV-to-UAV barriers order writes; they are not themselves new writes.
  }
}
inline void BoundWrites(command_list* cmd, shader_stage stage) {
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  const auto* command = renodx::utils::data::Get<bindings::CommandData>(cmd);
  if (!data || !data->pool.Active() || !command) return;
  // Copy register ranges while the layout cache is locked. Find takes that
  // cache itself, so resolving descriptors inside its callback would recurse.
  std::vector<descriptor_range> ranges;
  renodx::utils::pipeline_layout::GetPipelineLayoutData(command->compute.layout, [&](const auto* layout) {
    for (uint32_t i = 0; i < layout->params.size(); ++i) {
      const auto inspect = [&](const descriptor_range& range) {
        if (range.type == descriptor_type::texture_unordered_access_view
            && (uint32_t(range.visibility) & uint32_t(stage)) != 0) ranges.push_back(range);
      };
      if (const auto* range = bindings::RootDescriptor(layout->params[i])) inspect(*range);
      else if (layout->params[i].type == pipeline_layout_param_type::descriptor_table
          || layout->params[i].type == pipeline_layout_param_type::descriptor_table_with_static_samplers)
        for (const auto& range : layout->ranges[i]) inspect(range);
    }
  });
  for (const auto& range : ranges) {
    // Unbounded/unsupported tables fail closed instead of scanning arbitrary
    // heap addresses. Captured RT output tables contain 27 UAV descriptors.
    if (range.count > 256 || range.dx_register_index > UINT32_MAX - range.count) {
      data->pool.Invalidate(); return;
    }
    for (uint32_t i = 0; i < range.count; ++i) {
      const auto slot = bindings::Find(cmd, stage, range.type, range.dx_register_index + i, range.dx_register_space);
      if (slot.resource_view.handle) Written(cmd->get_device(), cmd->get_device()->get_resource_from_view(slot.resource_view));
    }
  }
}
inline bool OnDispatch(command_list* cmd, uint32_t, uint32_t, uint32_t) {
  const auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if (!data || !data->pool.Active()) return false;
  // Native layouts expose more UAVs than an individual shader uses. In the
  // audited reflection lighting pass only u5 is written; stale table entries
  // for the pretrace G-buffers are not writes and must not cancel publication.
  const uint32_t hash = renodx::utils::state::GetCurrentShaderHash(cmd, pipeline_stage::compute_shader);
  if (hash == 0x02320E1Au || hash == 0xD2C88922u) {
    const auto output = bindings::Find(cmd, shader_stage::compute, descriptor_type::texture_unordered_access_view, hash == 0x02320E1Au ? 5 : 4);
    if (output.resource_view.handle) Written(cmd->get_device(), cmd->get_device()->get_resource_from_view(output.resource_view));
    return false;
  }
  BoundWrites(cmd, shader_stage::compute); return false;
}
inline bool OnRays(command_list* cmd, resource, uint64_t, uint64_t, resource, uint64_t, uint64_t, uint64_t,
    resource, uint64_t, uint64_t, uint64_t, resource, uint64_t, uint64_t, uint64_t, uint32_t, uint32_t, uint32_t) {
  // The owned dispatch callback performs GPU selection and handles its own
  // fallback invalidation. Invalidating all bound UAVs here would erase the
  // other probe grid before the selected producer can preserve it.
  if (!manages_ray_dispatches) BoundWrites(cmd, shader_stage::raygen);
  return false;
}
inline void Invalidate(command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device())) data->pool.Invalidate();
}
// Graphics/indirect work between trace and lighting is not an audited path.
// Decline replacement conservatively until such a producer chain is proven.
inline bool OnDraw(command_list* cmd, uint32_t, uint32_t, uint32_t, uint32_t) { Invalidate(cmd); return false; }
inline bool OnIndexed(command_list* cmd, uint32_t, uint32_t, uint32_t, int32_t, uint32_t) { Invalidate(cmd); return false; }
inline bool OnIndirect(command_list* cmd, indirect_command, resource, uint64_t, uint32_t, uint32_t) { Invalidate(cmd); return false; }
inline bool OnClearUint(command_list* cmd, resource_view view, const uint32_t[4], uint32_t, const rect*) {
  Written(cmd->get_device(), cmd->get_device()->get_resource_from_view(view)); return false;
}
inline bool OnClearFloat(command_list* cmd, resource_view view, const float[4], uint32_t, const rect*) {
  Written(cmd->get_device(), cmd->get_device()->get_resource_from_view(view)); return false;
}
inline bool OnCopy(command_list* cmd, resource, resource dest) { Written(cmd->get_device(), dest); return false; }
inline bool OnCopyTexture(command_list* cmd, resource, uint32_t, const subresource_box*, resource dest, uint32_t,
    const subresource_box*, filter_mode) { Written(cmd->get_device(), dest); return false; }
inline bool OnCopyBufferTexture(command_list* cmd, resource, uint64_t, uint32_t, uint32_t, resource dest, uint32_t,
    const subresource_box*) { Written(cmd->get_device(), dest); return false; }
inline bool OnResolve(command_list* cmd, resource, uint32_t, const subresource_box*, resource dest, uint32_t,
    uint32_t, uint32_t, uint32_t, format) { Written(cmd->get_device(), dest); return false; }
inline void OnPresent(command_queue* queue, swapchain*, const rect*, const rect*, uint32_t, const rect*) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(queue->get_device())) data->pool.Invalidate();
}
inline void UseLifetime(DWORD reason) {
#define W3_HIT_EVENT(event, callback) \
  if (reason == DLL_PROCESS_ATTACH) reshade::register_event<reshade::addon_event::event>(callback); \
  else if (reason == DLL_PROCESS_DETACH) reshade::unregister_event<reshade::addon_event::event>(callback)
  W3_HIT_EVENT(init_device, OnDevice);
  W3_HIT_EVENT(destroy_device, OnDeviceDestroy);
  W3_HIT_EVENT(init_command_list, OnCommand);
  W3_HIT_EVENT(reset_command_list, OnReset);
  W3_HIT_EVENT(destroy_command_list, OnCommandDestroy);
  W3_HIT_EVENT(init_resource, OnResource);
  W3_HIT_EVENT(destroy_resource, OnResourceDestroy);
  W3_HIT_EVENT(barrier, OnBarrier);
  W3_HIT_EVENT(dispatch, OnDispatch);
  W3_HIT_EVENT(dispatch_rays, OnRays);
  W3_HIT_EVENT(draw, OnDraw);
  W3_HIT_EVENT(draw_indexed, OnIndexed);
  W3_HIT_EVENT(draw_or_dispatch_indirect, OnIndirect);
  W3_HIT_EVENT(clear_unordered_access_view_uint, OnClearUint);
  W3_HIT_EVENT(clear_unordered_access_view_float, OnClearFloat);
  W3_HIT_EVENT(copy_resource, OnCopy);
  W3_HIT_EVENT(copy_texture_region, OnCopyTexture);
  W3_HIT_EVENT(copy_buffer_to_texture, OnCopyBufferTexture);
  W3_HIT_EVENT(resolve_texture_region, OnResolve);
  W3_HIT_EVENT(present, OnPresent);
#undef W3_HIT_EVENT
}
}  // namespace witcher3graphics::raytracing::hits
