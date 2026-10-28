/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <d3d12.h>
#include <include/reshade.hpp>
#include <algorithm>
#include <array>
#include <atomic>
#include <chrono>
#include <cstdio>
#include <cstring>
#include <memory>
#include "motion_resources.hpp"
#include "motion_plan.hpp"
#include <mutex>
#include <shared_mutex>
#include <span>
#include <unordered_map>
#include <vector>
#include "../../utils/hash.hpp"
#include "motion_blur_config.h"

namespace witcher::motion {
using namespace reshade::api;
inline float mode = 1.f, motion_mode = 0.f, strength = 1.f;
inline std::array<std::span<const uint8_t>, 3> code;
constexpr uint32_t PRIVATE_SPACE = 57;
inline const sampler_desc linear_sampler = {};
inline const descriptor_range_with_static_samplers linear_range = {
    {0, 0, PRIVATE_SPACE, 1, shader_stage::compute, 1, descriptor_type::sampler}, &linear_sampler};
enum class Pass { none, depth, resolve };
struct Layout {
  pipeline_layout handle = {};
  uint32_t scratch = UINT32_MAX, settings = UINT32_MAX;
  bool projection = false;
  std::array<pipeline, 3> pipelines = {};
};
struct __declspec(uuid("3152e019-2795-40a4-814c-3d038cd51de2")) CommandData {
  std::shared_ptr<Layout> compute, graphics;
  pipeline_layout compute_handle = {}, graphics_handle = {};
  pipeline native_pipeline = {};
  Pass pass = Pass::none;
  uint32_t topology = 0;
  bool depth_encoded = false;
  resource scratch = {};
  D3D12_GPU_VIRTUAL_ADDRESS scratch_address = 0;
  uint64_t scratch_bytes = 0;
  uint32_t motion_width = 0, motion_height = 0;
  Settings frame_settings;
  std::shared_ptr<Allocation> allocation;
  std::vector<std::shared_ptr<Allocation>> recording;
  std::vector<std::shared_ptr<Queue>> queues;
  bool untracked_queue = false;
  std::array<Settings, 12> stages;
  D3D12_GPU_VIRTUAL_ADDRESS settings_address = 0;

};
struct __declspec(uuid("3da22c95-ff07-43af-9de5-5869dddd462c")) DeviceData {
  std::shared_mutex mutex;
  std::unordered_map<uint64_t, Pass> native_pipelines;
  std::unordered_map<uint64_t, std::shared_ptr<Layout>> layouts;
  ResourcePool pool;
  std::unordered_map<command_queue*, std::shared_ptr<Queue>> queues;
  bool logged_active = false;
  uint32_t logged_fallbacks = 0;
  std::chrono::steady_clock::time_point last_conversion;
  float interval = 0;
  uint64_t conversion_frame = UINT64_MAX, resolved = 0;

};

// Visit dynamic bindings in all ReShade representations. Other addons may
// wrap a native root CBV in *_with_static_samplers with a null sampler pointer;
// the wrapper name alone does not mean that the parameter is a static sampler.
template <typename F>
inline uint32_t InspectLayoutParameter(const pipeline_layout_param& p, F&& inspect) {
  if (p.type == pipeline_layout_param_type::push_constants) return p.push_constants.count;
  if (p.type == pipeline_layout_param_type::push_descriptors) {
    inspect(p.push_descriptors);
    return 2;
  }
  uint32_t dynamic_count = 0;
  bool direct_buffer = false;
  const auto range = [&](const descriptor_range& r) {
    if (!r.count) return;
    inspect(r);
    ++dynamic_count;
    direct_buffer = r.count == 1 && r.binding == 0
                    && (r.type == descriptor_type::constant_buffer
                        || r.type == descriptor_type::buffer_shader_resource_view
                        || r.type == descriptor_type::buffer_unordered_access_view
                        || r.type == descriptor_type::acceleration_structure);
  };
  if (p.type == pipeline_layout_param_type::descriptor_table
      || p.type == pipeline_layout_param_type::push_descriptors_with_ranges) {
    for (uint32_t i = 0; i < p.descriptor_table.count; ++i) range(p.descriptor_table.ranges[i]);
  } else if (p.type == pipeline_layout_param_type::descriptor_table_with_static_samplers
             || p.type == pipeline_layout_param_type::push_descriptors_with_static_samplers) {
    for (uint32_t i = 0; i < p.descriptor_table_with_static_samplers.count; ++i) {
      const auto& r = p.descriptor_table_with_static_samplers.ranges[i];
      if (r.static_samplers == nullptr) range(r);
    }
  } else {
    return UINT32_MAX;
  }
  if (!dynamic_count) return 0;
  return dynamic_count == 1 && direct_buffer
                 && (p.type == pipeline_layout_param_type::push_descriptors_with_ranges
                     || p.type == pipeline_layout_param_type::push_descriptors_with_static_samplers)
             ? 2 : 1;
}
inline bool OnCreateLayout(device* dev, uint32_t& count, pipeline_layout_param*& params) {
  if (dev->get_api() != device_api::d3d12 || !count || count > 64) return false;
  uint32_t cost = 0, static_index = count, compute_inputs = 0;
  bool native_camera = false, compute_constants = false, compute_output = false, occupied = false;
  for (uint32_t i = 0; i < count; ++i) {
    const auto& p = params[i];
    if (p.type == pipeline_layout_param_type::push_constants
        && p.push_constants.dx_register_space == PRIVATE_SPACE) return false;
    const auto parameter_cost = InspectLayoutParameter(p, [&](const descriptor_range& r) {
      occupied |= r.dx_register_space == PRIVATE_SPACE;
      if (r.dx_register_space != 0) return;
      native_camera |= r.type == descriptor_type::constant_buffer
                       && r.dx_register_index <= 12 && r.count > 12 - r.dx_register_index
                       && (r.visibility & shader_stage::vertex) != shader_stage{0};
      if ((r.visibility & shader_stage::compute) == shader_stage{0}) return;
      compute_constants |= r.type == descriptor_type::constant_buffer
                           && r.dx_register_index <= 10 && r.count > 10 - r.dx_register_index;
      if (r.type == descriptor_type::texture_shader_resource_view) {
        for (uint32_t slot = 0; slot < 3; ++slot)
          if (r.dx_register_index <= slot && r.count > slot - r.dx_register_index) compute_inputs |= 1u << slot;
      }
      compute_output |= r.type == descriptor_type::texture_unordered_access_view
                        && r.dx_register_index == 0 && r.count != 0;
    });
    if (occupied || parameter_cost == UINT32_MAX) return false;
    if (!parameter_cost) {
      static_index = std::min(static_index, i);
      continue;
    }
    if (static_index != count) return false;
    cost += parameter_cost;
  }
  // Graphics b12 supplies projection, including when it is in a CBV table.
  // The independent compute signature supplies b10, t0..t2 and u0.
  if ((!native_camera && !(compute_constants && compute_inputs == 7 && compute_output))
      || cost + 4 > 64 || count + 3 > 64) return false;
  thread_local std::vector<pipeline_layout_param> extended;
  extended.assign(params, params + static_index);
  extended.emplace_back(descriptor_range{0, 0, PRIVATE_SPACE, 1, shader_stage::all, 1, descriptor_type::buffer_unordered_access_view});
  extended.emplace_back(descriptor_range{0, 0, PRIVATE_SPACE, 1, shader_stage::compute, 1, descriptor_type::constant_buffer});
  extended.insert(extended.end(), params + static_index, params + count);
  extended.emplace_back(linear_range);
  count = static_cast<uint32_t>(extended.size());
  params = extended.data();
  return true;
}
inline void OnInitLayout(device* dev, uint32_t count, const pipeline_layout_param* params, pipeline_layout handle) {
  auto* data = dev->get_private_data<DeviceData>();
  if (!data) return;
  auto layout = std::make_shared<Layout>();
  layout->handle = handle;
  for (uint32_t i = 0; i < count; ++i) {
    InspectLayoutParameter(params[i], [&](const descriptor_range& r) {
      if (r.dx_register_space == PRIVATE_SPACE && r.dx_register_index == 0
          && r.type == descriptor_type::constant_buffer) layout->settings = i;
      if (r.dx_register_space == PRIVATE_SPACE && r.dx_register_index == 0
          && r.type == descriptor_type::buffer_unordered_access_view) layout->scratch = i;
      if (r.dx_register_space == 0 && r.dx_register_index <= 12 && r.count > 12 - r.dx_register_index
          && r.type == descriptor_type::constant_buffer
          && (r.visibility & shader_stage::vertex) != shader_stage{0}) layout->projection = true;
    });
  }
  if (layout->scratch == UINT32_MAX || layout->settings == UINT32_MAX) return;
  const std::unique_lock lock(data->mutex);
  data->layouts[handle.handle] = std::move(layout);
}
inline void OnDestroyLayout(device* dev, pipeline_layout handle) {
  auto* data = dev->get_private_data<DeviceData>();
  if (!data) return;
  const std::unique_lock lock(data->mutex);
  if (auto it = data->layouts.find(handle.handle); it != data->layouts.end()) {
    for (auto pso : it->second->pipelines) if (pso.handle) dev->destroy_pipeline(pso);
    it->second->pipelines = {};
    data->layouts.erase(it);
  }
}
inline void OnBindTables(command_list* cmd, shader_stage stages, pipeline_layout layout, uint32_t, uint32_t count, const descriptor_table*) {
  // D3D12 emits a count-zero notification for Set*RootSignature. Ordinary
  // descriptor-table updates need no work, lookup, allocation or mirroring.
  if (count != 0 || mode != 1.f) return;
  auto* state = cmd->get_private_data<CommandData>();
  if (!state) return;
  const bool compute = (stages & shader_stage::compute) != shader_stage{0};
  const bool graphics = (stages & shader_stage::all_graphics) != shader_stage{0};
  if ((!compute || state->compute_handle == layout) && (!graphics || state->graphics_handle == layout)) return;
  auto* data = cmd->get_device()->get_private_data<DeviceData>();
  if (!data) return;
  const std::shared_lock lock(data->mutex);
  auto it = data->layouts.find(layout.handle);
  auto found = it == data->layouts.end() ? nullptr : it->second;
  if (compute) { state->compute = found; state->compute_handle = layout; }
  if (graphics) { state->graphics = found; state->graphics_handle = layout; }
}
inline void OnStates(command_list* cmd, uint32_t count, const dynamic_state* states, const uint32_t* values) {
  if (mode != 1.f) return;
  for (uint32_t i = 0; i < count; ++i) {
    if (states[i] == dynamic_state::primitive_topology) {
      if (auto* state = cmd->get_private_data<CommandData>()) state->topology = values[i];
    }
  }
}
inline void OnInitPipeline(device* dev, pipeline_layout layout, uint32_t count, const pipeline_subobject* subobjects, pipeline value) {
  auto* data = dev->get_private_data<DeviceData>();
  if (!data) return;
  for (uint32_t i = 0; i < count; ++i) {
    if (subobjects[i].type != pipeline_subobject_type::compute_shader || !subobjects[i].data) continue;
    const auto& shader = *static_cast<const shader_desc*>(subobjects[i].data);
    if (!shader.code || !shader.code_size) continue;
    const auto hash = renodx::utils::hash::ComputeCRC32(static_cast<const uint8_t*>(shader.code), shader.code_size);
    const auto pass = hash == 0x9F1C32F1 ? Pass::depth
                      : (hash == 0x866E78BC || hash == 0x2B7AF9F0) ? Pass::resolve : Pass::none;
    if (pass != Pass::none) {
      const std::unique_lock lock(data->mutex);
      data->native_pipelines[value.handle] = pass;
      char message[160];
      std::snprintf(message, sizeof(message), "Motion Blur: detected native %08X, layout %llX, private bindings %s.",
                    hash, static_cast<unsigned long long>(layout.handle), data->layouts.contains(layout.handle) ? "available" : "missing");
      reshade::log::message(reshade::log::level::info, message);
    }
  }
}
inline void OnDestroyPipeline(device* dev, pipeline value) {
  if (auto* data = dev->get_private_data<DeviceData>()) {
    const std::unique_lock lock(data->mutex);
    data->native_pipelines.erase(value.handle);
  }
}
inline void OnBindPipeline(command_list* cmd, pipeline_stage stages, pipeline value) {
  if (mode != 1.f
      || (stages & pipeline_stage::compute_shader) == pipeline_stage{0}) return;
  auto* state = cmd->get_private_data<CommandData>();
  if (!state) return;
  state->native_pipeline = value;
  state->pass = Pass::none;
  auto* data = cmd->get_device()->get_private_data<DeviceData>();
  const std::shared_lock lock(data->mutex);
  if (auto it = data->native_pipelines.find(value.handle); it != data->native_pipelines.end()) state->pass = it->second;
}
inline bool Prepare(device* dev, Layout* layout, uint32_t index) {
  if (layout->pipelines[index].handle) return true;
  shader_desc shader = {code[index].data(), code[index].size()};
  if (index != 2) {
    const pipeline_subobject subobject = {pipeline_subobject_type::compute_shader, 1, &shader};
    return dev->create_pipeline(layout->handle, 1, &subobject, &layout->pipelines[index]);
  }
  // A clipped vertex invocation reads the already-bound graphics b12. There
  // are no descriptor copies, camera-buffer CPU reads or render-target writes.
  primitive_topology topology = primitive_topology::point_list;
  depth_stencil_desc depth;
  depth.depth_enable = false;
  depth.depth_write_mask = false;
  const pipeline_subobject subobjects[] = {
      {pipeline_subobject_type::vertex_shader, 1, &shader},
      {pipeline_subobject_type::primitive_topology, 1, &topology},
      {pipeline_subobject_type::depth_stencil_state, 1, &depth}};
  return dev->create_pipeline(layout->handle, static_cast<uint32_t>(std::size(subobjects)), subobjects, &layout->pipelines[index]);
}
// Each recording owns every allocation it references. Growth copies only the
// camera header; the old allocation retires with the same recording fence.
inline bool EnsureScratch(command_list* cmd, DeviceData* data, CommandData* state, uint64_t bytes) {
  if (state->scratch_bytes >= bytes) return true;
  auto allocation = data->pool.Acquire(reinterpret_cast<ID3D12Device*>(cmd->get_device()->get_native()), bytes);
  if (!allocation) return false;
  const resource buffer{reinterpret_cast<uint64_t>(allocation->scratch.Get())};
  if (state->scratch.handle) {
    cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::copy_source);
    cmd->barrier(buffer, resource_usage::unordered_access, resource_usage::copy_dest);
    cmd->copy_buffer_region(state->scratch, 0, buffer, 0, WITCHER_MOTION_HEADER * 16u);
    cmd->barrier(state->scratch, resource_usage::copy_source, resource_usage::unordered_access);
    cmd->barrier(buffer, resource_usage::copy_dest, resource_usage::unordered_access);
  }
  state->allocation = allocation;
  state->recording.push_back(allocation);
  state->scratch = buffer;
  state->scratch_bytes = allocation->bytes;
  state->scratch_address = allocation->scratch->GetGPUVirtualAddress();
  return true;
}
inline bool PrepareFrame(command_list* cmd, DeviceData* data, CommandData* state, uint32_t x, uint32_t y) {
  auto* dev = cmd->get_device();
  if (!state->compute || !state->depth_encoded || !state->graphics || !state->graphics->projection
      || !state->topology || x > 512 || y > 512) return false;
  if (!Prepare(dev, state->compute.get(), 0) || !Prepare(dev, state->graphics.get(), 2)) return false;
  Settings settings{};
  settings.interval = state->frame_settings.interval;
  settings.strength = std::clamp(strength, 0.f, 2.f);
  settings.mode = static_cast<uint32_t>(std::clamp(motion_mode, 0.f, 2.f));
  settings.output_width = x * 16u; settings.output_height = y * 16u;
  settings.motion_width = state->motion_width; settings.motion_height = state->motion_height;
  const Plan plan(settings);
  state->stages = plan.stages;
  if (!EnsureScratch(cmd, data, state, plan.bytes)) return false;
  if (state->allocation->used + 12u * 256u > 65536u) return false;
  state->settings_address = state->allocation->constants->GetGPUVirtualAddress() + state->allocation->used;
  for (const auto& record : state->stages) {
    std::memcpy(state->allocation->mapped + state->allocation->used, &record, sizeof(record));
    state->allocation->used += 256;
  }
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::unordered_access);
  native->SetGraphicsRootUnorderedAccessView(state->graphics->scratch, state->scratch_address);
  native->SetPipelineState(reinterpret_cast<ID3D12PipelineState*>(state->graphics->pipelines[2].handle));
  native->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_POINTLIST);
  cmd->draw(1, 1, 0, 0);
  const dynamic_state topology = dynamic_state::primitive_topology;
  cmd->bind_pipeline_states(1, &topology, &state->topology);
  cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::unordered_access);
  native->SetPipelineState(reinterpret_cast<ID3D12PipelineState*>(state->native_pipeline.handle));
  state->frame_settings = settings;
  state->allocation->objects.emplace_back(reinterpret_cast<IUnknown*>(state->graphics->pipelines[2].handle));
  state->allocation->objects.emplace_back(reinterpret_cast<IUnknown*>(state->graphics->handle.handle));
  state->allocation->objects.emplace_back(reinterpret_cast<IUnknown*>(state->compute->pipelines[0].handle));
  state->allocation->objects.emplace_back(reinterpret_cast<IUnknown*>(state->compute->handle.handle));
  return true;
}
inline bool OnDispatch(command_list* cmd, uint32_t x, uint32_t y, uint32_t z) {
  if (mode != 1.f || !x || !y || z != 1) return false;
  auto* state = cmd->get_private_data<CommandData>();
  if (!state || state->pass == Pass::none) return false;
  auto* dev = cmd->get_device();
  auto* data = dev->get_private_data<DeviceData>();
  const std::unique_lock lock(data->mutex);
  const auto fallback = [&](uint32_t bit, const char* reason) {
    if ((data->logged_fallbacks & bit) == 0) {
      reshade::log::message(reshade::log::level::warning, reason);
      data->logged_fallbacks |= bit;
    }
    return false;
  };
  if (!state->compute) return fallback(1, "Motion Blur: native fallback; compute layout has no private bindings.");
  if (state->pass == Pass::depth) {
    state->depth_encoded = false;
    if (!Prepare(dev, state->compute.get(), 1)) return fallback(2, "Motion Blur: native fallback; depth conversion pipeline creation failed.");
    state->allocation.reset(); state->scratch = {}; state->scratch_bytes = 0;
    if (x > 1024 || y > 1024 || !EnsureScratch(cmd, data, state, WITCHER_MOTION_HEADER * 16u)) return false;
    // The game converts motion twice in some frames. Time the first conversion
    // of each presented scene, never the microseconds between those two passes.
    if (data->conversion_frame != data->pool.frame) {
      const auto now = std::chrono::steady_clock::now();
      const float elapsed = std::chrono::duration<float>(now - data->last_conversion).count();
      data->interval = elapsed >= .001f && elapsed <= .25f ? elapsed : 0.f;
      data->last_conversion = now;
      data->conversion_frame = data->pool.frame;
    }
    state->frame_settings.interval = data->interval;
    state->allocation->objects.emplace_back(reinterpret_cast<IUnknown*>(state->compute->pipelines[1].handle));
    state->allocation->objects.emplace_back(reinterpret_cast<IUnknown*>(state->compute->handle.handle));
    state->motion_width = x * 8u;
    state->motion_height = y * 8u;
    cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::unordered_access);
    reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native())->SetComputeRootUnorderedAccessView(state->compute->scratch, state->scratch_address);
    cmd->bind_pipeline(pipeline_stage::compute_shader, state->compute->pipelines[1]);
    cmd->dispatch(x, y, z);
    cmd->bind_pipeline(pipeline_stage::compute_shader, state->native_pipeline);
    state->depth_encoded = true;
    return true;
  }
  if (!PrepareFrame(cmd, data, state, x, y))
    return fallback(4, "Motion Blur: native fallback; reconstruction preflight unavailable.");
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  native->SetComputeRootUnorderedAccessView(state->compute->scratch, state->scratch_address);
  cmd->bind_pipeline(pipeline_stage::compute_shader, state->compute->pipelines[0]);
  for (uint32_t stage = 0; stage < state->stages.size(); ++stage) {
    const auto& record = state->stages[stage];
    cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::unordered_access);
    native->SetComputeRootConstantBufferView(state->compute->settings, state->settings_address + stage * 256u);
    cmd->dispatch((record.target_width + 7u) / 8u, (record.target_height + 7u) / 8u, 1);
  }
  cmd->bind_pipeline(pipeline_stage::compute_shader, state->native_pipeline);
  state->depth_encoded = false;
  ++data->resolved;
  if (!data->logged_active) {
    reshade::log::message(reshade::log::level::info,
                         "Motion Blur: Classic optical reconstruction active; five reductions, two gathers, fence-retired bounded scratch.");
    data->logged_active = true;
  }
  return true;
}
inline void OnInitDevice(device* dev) {
  if (dev->get_api() == device_api::d3d12) dev->create_private_data<DeviceData>();
}
inline void OnDestroyDevice(device* dev) {
  auto* data = dev->get_private_data<DeviceData>();
  if (!data) return;
  for (auto& [key, layout] : data->layouts) for (auto pso : layout->pipelines) if (pso.handle) dev->destroy_pipeline(pso);
  dev->destroy_private_data<DeviceData>();
}
inline void OnInitCommand(command_list* cmd) {
  if (cmd->get_device()->get_api() == device_api::d3d12) cmd->create_private_data<CommandData>();
}
inline void OnResetCommand(command_list* cmd) {
  auto* state = cmd->get_private_data<CommandData>();
  auto* data = cmd->get_device()->get_private_data<DeviceData>();
  if (!state || !data) return;
  const std::unique_lock lock(data->mutex);
  data->pool.Retire(&state->recording, &state->queues, state->untracked_queue);
  *state = CommandData{};
}
inline void OnDestroyCommand(command_list* cmd) {
  OnResetCommand(cmd);
  cmd->destroy_private_data<CommandData>();
}
inline void OnInitQueue(command_queue* queue) {
  auto* data = queue->get_device()->get_private_data<DeviceData>();
  if (!data) return;
  auto q = std::make_shared<Queue>();
  q->native = reinterpret_cast<ID3D12CommandQueue*>(queue->get_native());
  if (FAILED(reinterpret_cast<ID3D12Device*>(queue->get_device()->get_native())->CreateFence(
          0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&q->fence)))) return;
  const std::unique_lock lock(data->mutex);
  data->queues[queue] = std::move(q);
}
inline void OnExecute(command_queue* queue, command_list* cmd) {
  auto* state = cmd->get_private_data<CommandData>();
  if (!state || state->recording.empty()) return;
  auto* data = cmd->get_device()->get_private_data<DeviceData>();
  const std::unique_lock lock(data->mutex);
  if (auto it = data->queues.find(queue); it != data->queues.end()) {
    if (std::find(state->queues.begin(), state->queues.end(), it->second) == state->queues.end()) state->queues.push_back(it->second);
  } else state->untracked_queue = true;
}
inline void OnDestroyQueue(command_queue* queue) {
  auto* data = queue->get_device()->get_private_data<DeviceData>();
  if (!data) return;
  const std::unique_lock lock(data->mutex);
  if (auto it = data->queues.find(queue); it != data->queues.end()) {
    auto& q = *it->second;
    if (FAILED(q.native->Signal(q.fence.Get(), ++q.serial))) q.serial = UINT64_MAX;
    q.native = nullptr;
    data->queues.erase(it);
  }
}
inline void OnPresent(command_queue* queue, swapchain*, const rect*, const rect*, uint32_t, const rect*) {
  auto* data = queue->get_device()->get_private_data<DeviceData>();
  if (!data) return;
  const std::unique_lock lock(data->mutex);
  ++data->pool.frame;
  data->pool.Collect();
  if (data->pool.frame % 300 == 0) {
    char message[256];
    std::snprintf(message, sizeof(message), "Motion Blur: scratch %.2f MiB, peak %.2f MiB, %zu allocations, %llu resolves, interval %.3f ms.",
                  data->pool.bytes / 1048576., data->pool.peak_bytes / 1048576., data->pool.allocations.size(),
                  static_cast<unsigned long long>(data->resolved), data->interval * 1000.f);
    reshade::log::message(reshade::log::level::info, message);
  }
}
inline void Use(DWORD reason) {
#define WITCHER_MOTION_EVENT(event, callback) \
  if (reason == DLL_PROCESS_ATTACH) reshade::register_event<reshade::addon_event::event>(callback); \
  else if (reason == DLL_PROCESS_DETACH) reshade::unregister_event<reshade::addon_event::event>(callback)
  WITCHER_MOTION_EVENT(init_device, OnInitDevice);
  WITCHER_MOTION_EVENT(init_command_queue, OnInitQueue);
  WITCHER_MOTION_EVENT(destroy_command_queue, OnDestroyQueue);
  WITCHER_MOTION_EVENT(execute_command_list, OnExecute);
  WITCHER_MOTION_EVENT(present, OnPresent);
  WITCHER_MOTION_EVENT(destroy_device, OnDestroyDevice);
  WITCHER_MOTION_EVENT(init_command_list, OnInitCommand);
  WITCHER_MOTION_EVENT(destroy_command_list, OnDestroyCommand);
  WITCHER_MOTION_EVENT(reset_command_list, OnResetCommand);
  WITCHER_MOTION_EVENT(create_pipeline_layout, OnCreateLayout);
  WITCHER_MOTION_EVENT(init_pipeline_layout, OnInitLayout);
  WITCHER_MOTION_EVENT(destroy_pipeline_layout, OnDestroyLayout);
  WITCHER_MOTION_EVENT(init_pipeline, OnInitPipeline);
  WITCHER_MOTION_EVENT(destroy_pipeline, OnDestroyPipeline);
  WITCHER_MOTION_EVENT(bind_pipeline, OnBindPipeline);
  WITCHER_MOTION_EVENT(bind_descriptor_tables, OnBindTables);
  WITCHER_MOTION_EVENT(bind_pipeline_states, OnStates);
  WITCHER_MOTION_EVENT(dispatch, OnDispatch);
#undef WITCHER_MOTION_EVENT
}
}  // namespace witcher::motion
