// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <atomic>
#include <cmath>
#include <mutex>
#include "pipeline.hpp"
#include "motion.hpp"

namespace witcher3graphics::contact {
inline std::array<std::span<const uint8_t>, 5> code;
struct __declspec(uuid("b85e1bf5-456f-4513-a493-7f791d61b210")) DeviceData {
  std::mutex mutex;
  std::unique_ptr<Pipeline> pipeline;
  std::unique_ptr<MotionInputs> motion;
  std::vector<std::unique_ptr<std::vector<pipeline_layout_param>>> extended;
  resource neutral = {};
  resource_view neutral_view = {};
  uint64_t frame = 0;
  std::atomic_uint64_t generated = 0;
  resource_view published = {};
  command_list* producer = nullptr;
};

// Both deferred and forward receivers must always get a valid neutral root.
inline resource_view Neutral(device* dev, DeviceData* data) {
  if (!data->neutral_view.handle) {
    std::array<uint32_t, 4> zero{};
    const subresource_data initial{zero.data(), 16, 16};
    if (!data->neutral.handle && !dev->create_resource(resource_desc(uint64_t(16), memory_heap::gpu_only, resource_usage::shader_resource),
            &initial, resource_usage::shader_resource, &data->neutral)) return {};
    if (!dev->create_resource_view(data->neutral, resource_usage::shader_resource,
            resource_view_desc(format::r32_typeless, uint64_t(0), uint64_t(4)), &data->neutral_view)) return {};
  }
  return data->neutral_view;
}

inline bool OnCreateLayout(device* dev, uint32_t& count, pipeline_layout_param*& params) {
  if (dev->get_api() != device_api::d3d12 || !params) return false;
  auto* data = renodx::utils::data::Get<DeviceData>(dev);
  if (!data) return false;
  bool frame = false, light = false, native_constants = false, collision = false;
  uint32_t cost = 0;
  const auto inspect = [&](const descriptor_range& range) {
    if ((uint32_t(range.visibility) & uint32_t(shader_stage::compute | shader_stage::pixel)) == 0) return;
    collision |= range.dx_register_space == 54;
    if (range.type != descriptor_type::constant_buffer || range.dx_register_space != 0) return;
    const auto covers = [&](uint32_t index) {
      return index >= range.dx_register_index && index - range.dx_register_index < range.count;
    };
    native_constants |= ((uint32_t(range.visibility) & uint32_t(shader_stage::compute)) != 0 && covers(0))
        || ((uint32_t(range.visibility) & uint32_t(shader_stage::pixel)) != 0 && (covers(0) || covers(1)));
    frame |= covers(12); light |= covers(13);
  };
  for (uint32_t i = 0; i < count; ++i) {
    if (params[i].type == pipeline_layout_param_type::push_constants) { cost += params[i].push_constants.count; continue; }
    if (const auto* range = bindings::RootDescriptor(params[i])) {
      // Only native buffer roots have a two-DWORD root-descriptor cost.
      if (range->type != descriptor_type::constant_buffer && range->type != descriptor_type::buffer_shader_resource_view
          && range->type != descriptor_type::buffer_unordered_access_view && range->type != descriptor_type::shader_storage_buffer) return false;
      cost += 2; inspect(*range);
    } else if (params[i].type == pipeline_layout_param_type::push_descriptors_with_static_samplers) {
      // ReShade represents native static samplers as a trailing pseudo-parameter.
      // They consume no root DWORDs and are not a native resource root.
      for (uint32_t j = 0; j < params[i].descriptor_table_with_static_samplers.count; ++j) {
        const auto& range = params[i].descriptor_table_with_static_samplers.ranges[j];
        if (range.type != descriptor_type::sampler || range.static_samplers == nullptr) return false;
      }
    } else if (params[i].type == pipeline_layout_param_type::descriptor_table) {
      ++cost;
      for (uint32_t j = 0; j < params[i].descriptor_table.count; ++j) inspect(params[i].descriptor_table.ranges[j]);
    } else if (params[i].type == pipeline_layout_param_type::descriptor_table_with_static_samplers) {
      ++cost;
      for (uint32_t j = 0; j < params[i].descriptor_table_with_static_samplers.count; ++j)
        inspect(params[i].descriptor_table_with_static_samplers.ranges[j]);
    } else return false;
  }
  if (!native_constants || !frame || !light || collision || cost > 62) return false;
  std::lock_guard lock(data->mutex);
  auto extended = std::make_unique<std::vector<pipeline_layout_param>>(params, params + count);
  extended->emplace_back(descriptor_range{0, 0, 54, 1, shader_stage::compute | shader_stage::pixel, 1, descriptor_type::buffer_shader_resource_view});
  params = extended->data(); ++count; data->extended.push_back(std::move(extended));
  return true;
}

// Raster and RT/PT deferred lighting share these depth, normal, material and
// stencil inputs. Combine the result after the native directional visibility
// has been resolved; this does not feed the ray-tracing denoiser or local lights.
inline bool Bind(command_list* cmd, bool enabled, float reach) {
  auto* dev = cmd->get_device();
  auto* data = renodx::utils::data::Get<DeviceData>(dev);
  const auto* roots = renodx::utils::data::Get<bindings::CommandData>(cmd);
  if (!data || !roots) return false;
  const auto native_layout = roots->compute.layout;
  uint32_t index = UINT32_MAX;
  renodx::utils::pipeline_layout::GetPipelineLayoutData(native_layout, [&](const auto* layout) {
    for (uint32_t i = 0; i < layout->params.size(); ++i) {
      const auto* range = bindings::RootDescriptor(layout->params[i]);
      if (range && range->type == descriptor_type::buffer_shader_resource_view
          && range->dx_register_space == 54 && range->dx_register_index == 0 && range->count == 1) index = i;
    }
  });
  if (index == UINT32_MAX) return false;
  std::lock_guard lock(data->mutex);
  resource_view result = Neutral(dev,data);
  if (!result.handle) return false;
  if (enabled && std::isfinite(reach) && reach > 0.f && !roots->in_render_pass) {
    std::array<resource_view, 5> inputs{};
    constexpr std::array<uint32_t, 5> slots{0, 2, 4, 3, 1};
    for (uint32_t i = 0; i < slots.size(); ++i)
      inputs[i] = bindings::Find(cmd, true, descriptor_type::texture_shader_resource_view, slots[i]).resource_view;
    const auto depth = inputs[0].handle ? dev->get_resource_from_view(inputs[0]) : resource{};
    if (depth.handle) {
      const auto desc = dev->get_resource_desc(depth);
      const auto frame = bindings::Find(cmd, true, descriptor_type::constant_buffer, 12);
      const auto light = bindings::Find(cmd, true, descriptor_type::constant_buffer, 13);
      if (desc.type == resource_type::texture_2d && frame.type == descriptor_type::constant_buffer && light.type == descriptor_type::constant_buffer) {
        if (!data->pipeline) data->pipeline = std::make_unique<Pipeline>(dev);
        if (data->pipeline->Initialize(code)) {
          const auto motion = data->motion->Resolve(cmd, inputs[0]);
          const bool transition_motion = motion.resource.handle
              && (uint32_t(motion.state) & uint32_t(resource_usage::shader_resource_non_pixel)) == 0;
          if (transition_motion) cmd->barrier(motion.resource, motion.state, resource_usage::shader_resource_non_pixel);
          const auto generated = data->pipeline->Generate(cmd, inputs, frame.buffer_range, light.buffer_range,
              desc.texture.width, desc.texture.height, {1, 1, 0, reach}, data->frame, depth.handle, motion.views, motion.camera);
          if (transition_motion) cmd->barrier(motion.resource, resource_usage::shader_resource_non_pixel, motion.state);
          if (generated.handle) { result = generated; data->published = generated; data->producer = cmd; ++data->generated; }
        }
      }
    }
  }
  cmd->push_descriptors(shader_stage::compute, native_layout, index,
      {{0}, 0, 0, 1, descriptor_type::buffer_shader_resource_view, &result});
  return true;
}
inline bool BindForward(command_list* cmd, bool enabled) {
  auto* dev = cmd->get_device();
  auto* data = renodx::utils::data::Get<DeviceData>(dev);
  const auto* roots = renodx::utils::data::Get<bindings::CommandData>(cmd);
  if (!data || !roots) return false;
  uint32_t index = UINT32_MAX;
  renodx::utils::pipeline_layout::GetPipelineLayoutData(roots->graphics.layout, [&](const auto* layout) {
    for (uint32_t i = 0; i < layout->params.size(); ++i) {
      const auto* range = bindings::RootDescriptor(layout->params[i]);
      if (range && range->type == descriptor_type::buffer_shader_resource_view
          && range->dx_register_space == 54 && range->dx_register_index == 0 && range->count == 1) index = i;
    }
  });
  if (index == UINT32_MAX) return false;
  std::lock_guard lock(data->mutex);
  resource_view result = Neutral(dev,data);
  if (!result.handle) return false;
  // Recorded later on the same command list: the publisher's UAV->SRV barrier
  // orders the read. Never infer ordering across native queues/submissions.
  if (enabled && data->producer == cmd && data->published.handle) result = data->published;
  cmd->push_descriptors(shader_stage::pixel, roots->graphics.layout, index,
      {{0}, 0, 0, 1, descriptor_type::buffer_shader_resource_view, &result});
  return true;
}
inline void OnInit(device* dev) {
  if (dev->get_api() == device_api::d3d12) {
    renodx::utils::data::Create<DeviceData>(dev);
    renodx::utils::data::Get<DeviceData>(dev)->motion = std::make_unique<MotionInputs>(dev);
  }
}
inline void OnDestroy(device* dev) {
  auto* data = renodx::utils::data::Get<DeviceData>(dev);
  if (!data) return;
  data->pipeline.reset();
  data->motion.reset();
  if (data->neutral_view.handle) dev->destroy_resource_view(data->neutral_view);
  if (data->neutral.handle) dev->destroy_resource(data->neutral);
  renodx::utils::data::Delete<DeviceData>(dev);
}
inline void NextFrame(device* dev) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(dev)) {
    std::lock_guard lock(data->mutex); ++data->frame;
    data->published = {}; data->producer = nullptr;
    data->motion->Reset();
  }
}
inline void OnResetCommandList(command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device())) {
    std::lock_guard lock(data->mutex);
    if (data->producer == cmd) { data->published = {}; data->producer = nullptr; }
    data->motion->Reset(cmd);
  }
}
inline void ObserveMotion(command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device()); data && data->motion) data->motion->Observe(cmd);
}
inline void OnMotionBarrier(command_list* cmd, uint32_t count, const resource* resources,
    const resource_usage*, const resource_usage* states) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device()); data && data->motion) data->motion->Barrier(cmd, count, resources, states);
}
inline void OnDestroyMotionResource(device* dev, resource value) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(dev); data && data->motion) data->motion->DestroyResource(value);
}
inline void Use(DWORD reason, bool extend_layouts = true) {
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::init_device>(OnInit);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroy);
    if (extend_layouts) reshade::register_event<reshade::addon_event::create_pipeline_layout>(OnCreateLayout);
    reshade::register_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
    reshade::register_event<reshade::addon_event::destroy_command_list>(OnResetCommandList);
    reshade::register_event<reshade::addon_event::barrier>(OnMotionBarrier);
    reshade::register_event<reshade::addon_event::destroy_resource>(OnDestroyMotionResource);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::destroy_command_list>(OnResetCommandList);
    reshade::unregister_event<reshade::addon_event::barrier>(OnMotionBarrier);
    reshade::unregister_event<reshade::addon_event::destroy_resource>(OnDestroyMotionResource);
    reshade::unregister_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
    if (extend_layouts) reshade::unregister_event<reshade::addon_event::create_pipeline_layout>(OnCreateLayout);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroy);
    reshade::unregister_event<reshade::addon_event::init_device>(OnInit);
  }
}
}  // namespace witcher3graphics::contact
