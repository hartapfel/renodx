/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <d3d12.h>
#include <include/reshade.hpp>
#include <algorithm>
#include <array>
#include <atomic>
#include <bit>
#include <cstdio>
#include <cstring>
#include <memory>
#include <map>
#include <mutex>
#include <shared_mutex>
#include <span>
#include <unordered_map>
#include <vector>
#include "../../utils/hash.hpp"
#include "motion_blur_config.h"

namespace witcher::motion {
using namespace reshade::api;
inline float mode = 1.f, shutter_angle = 180.f, object_shutter_angle = 180.f, sample_count = 16.f;
inline float camera_motion = 1.f, object_motion = 1.f;
inline float half_resolution = 0.f;
inline std::atomic_uint32_t active_chains = 0;
inline std::array<std::span<const uint8_t>, 9> code;
constexpr uint32_t PRIVATE_SPACE = 57;
inline const sampler_desc linear_sampler = {};
inline const descriptor_range_with_static_samplers linear_range = {
    {0, 0, PRIVATE_SPACE, 1, shader_stage::compute, 1, descriptor_type::sampler}, &linear_sampler};
// Camera data plus two grids at D3D12's maximum 2D texture size.
constexpr uint64_t SCRATCH_BYTES = (WITCHER_MOTION_HEADER + 2ull * (16384 / WITCHER_MOTION_TILE) * (16384 / WITCHER_MOTION_TILE)) * 16ull;
enum class Pass { none, depth, prefilter, blur, resolve };
struct Settings {
  float angle;
  uint32_t samples, diagnostic = 0;
  float seconds = 0;
  uint32_t components = WITCHER_MOTION_CAMERA | WITCHER_MOTION_OBJECT;
  float object_angle = 180.f;
  uint32_t cache_enabled = 1, half_resolution = 0;
  uint32_t cache_width = 0, cache_height = 0, half_width = 0, half_height = 0;
};
struct SettingsPage { resource buffer; void* mapped; D3D12_GPU_VIRTUAL_ADDRESS address; uint32_t used = 0; };
struct Layout {
  pipeline_layout handle = {};
  uint32_t scratch = UINT32_MAX, settings = UINT32_MAX;
  bool projection = false, native_blur = false, native_resolve = false;
  std::array<pipeline, 9> pipelines = {};
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
  std::shared_ptr<Layout> prepared;
  Settings frame_settings;
  D3D12_GPU_VIRTUAL_ADDRESS settings_address = 0;
  uint32_t skipped_stages = 0;
};
// A mode change takes effect at the next chain boundary. Once native work was
// skipped, finish the prepared replacement even if the UI changes meanwhile.
inline void EndChain(CommandData* state) {
  if (state->skipped_stages) active_chains.fetch_sub(1, std::memory_order_relaxed);
  state->skipped_stages = 0;
  state->prepared.reset();
}
struct __declspec(uuid("3da22c95-ff07-43af-9de5-5869dddd462c")) DeviceData {
  std::shared_mutex mutex;
  std::unordered_map<uint64_t, Pass> native_pipelines;
  std::unordered_map<uint64_t, std::shared_ptr<Layout>> layouts;
  // Command-list destruction is not a GPU completion signal. Keep scratch
  // allocations alive until device teardown, without a fence/readback/wait.
  std::vector<resource> scratch_buffers;
  bool logged_active = false, logged_skip = false;
  uint32_t logged_fallbacks = 0;
  std::vector<SettingsPage> settings_pages;
  std::map<std::array<uint32_t, 7>, D3D12_GPU_VIRTUAL_ADDRESS> settings_cache;
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
  if (count != 0 || (mode != 1.f && active_chains.load(std::memory_order_relaxed) == 0)) return;
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
                      : hash == 0x5388164E ? Pass::prefilter
                      : hash == 0x47C602BB ? Pass::blur
                      : (hash == 0x866E78BC || hash == 0x2B7AF9F0) ? Pass::resolve : Pass::none;
    if (pass != Pass::none) {
      const std::unique_lock lock(data->mutex);
      data->native_pipelines[value.handle] = pass;
      if (auto it = data->layouts.find(layout.handle); it != data->layouts.end()) {
        it->second->native_blur |= pass == Pass::blur;
        it->second->native_resolve |= pass == Pass::resolve;
      }
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
  if ((mode != 1.f && active_chains.load(std::memory_order_relaxed) == 0)
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
  if (index != 4) {
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
// Grow only on a resolution/mode change. Retain retired buffers until device
// teardown because command-list reset/destruction does not imply GPU completion.
inline bool EnsureScratch(command_list* cmd, DeviceData* data, CommandData* state, uint64_t bytes) {
  if (state->scratch_bytes >= bytes) return true;
  bytes = (bytes + 65535ull) & ~65535ull;
  auto* dev = cmd->get_device();
  resource buffer;
  const bool copy = state->scratch.handle != 0;
  if (!dev->create_resource(resource_desc(bytes, memory_heap::gpu_only, resource_usage::unordered_access | resource_usage::copy_source | resource_usage::copy_dest),
                            nullptr, copy ? resource_usage::copy_dest : resource_usage::unordered_access, &buffer)) return false;
  if (copy) {
    cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::copy_source);
    cmd->copy_buffer_region(state->scratch, 0, buffer, 0, WITCHER_MOTION_HEADER * 16u);
    cmd->barrier(state->scratch, resource_usage::copy_source, resource_usage::unordered_access);
    cmd->barrier(buffer, resource_usage::copy_dest, resource_usage::unordered_access);
  }
  data->scratch_buffers.push_back(buffer);
  state->scratch = buffer;
  state->scratch_bytes = bytes;
  state->scratch_address = reinterpret_cast<ID3D12Resource*>(buffer.handle)->GetGPUVirtualAddress();
  return true;
}
// Prepare every fallible resource/PSO/CBV operation before suppressing a native
// stage. The recognized prefilter -> blur -> resolve chain shares one layout;
// its only intermediate consumers are the two following stages. Freeze the
// settings and transfer the camera now, leaving no allocation at final resolve.
inline bool PrepareFrame(command_list* cmd, DeviceData* data, CommandData* state, uint32_t x, uint32_t y) {
  auto* dev = cmd->get_device();
  if (!state->compute) return false;
  if (!state->depth_encoded) return false;
  if (!state->graphics || !state->graphics->projection) return false;
  if (state->topology == 0) return false;
  // Native resolves use 16x16 groups. Bound textures provide exact dimensions
  // in the shader; ceil-dividing these counts preserves partial edge groups.
  if (x > 1024 || y > 1024) return false;
  for (uint32_t i = 0; i < 3; ++i) if (!Prepare(dev, state->compute.get(), i)) return false;
  if (!Prepare(dev, state->compute.get(), 5) || !Prepare(dev, state->compute.get(), 6) || !Prepare(dev, state->compute.get(), 7) || !Prepare(dev, state->compute.get(), 8)) return false;
  Settings settings = {std::clamp(shutter_angle, 0.f, 360.f),
                       static_cast<uint32_t>(std::clamp(sample_count, 16.f, 128.f)), 0, 0.f,
                       (camera_motion != 0.f ? WITCHER_MOTION_CAMERA : 0u)
                           | (object_motion != 0.f ? WITCHER_MOTION_OBJECT : 0u),
                       std::clamp(object_shutter_angle, 0.f, 360.f), 1, half_resolution != 0.f ? 1u : 0u};
  // Equal effective shutters already bypass camera separation. At full
  // resolution the original FP16 fetch is cheaper than caching FP32 vectors.
  settings.cache_enabled = settings.half_resolution
                           || ((settings.components & WITCHER_MOTION_CAMERA) ? settings.angle : 0.f)
                                  != ((settings.components & WITCHER_MOTION_OBJECT) ? settings.object_angle : 0.f);
  settings.cache_width = settings.cache_enabled ? state->motion_width : 0u;
  settings.cache_height = settings.cache_enabled ? state->motion_height : 0u;
  settings.half_width = settings.half_resolution ? x * 8u : 0u;
  settings.half_height = settings.half_resolution ? y * 8u : 0u;
  // Dispatch dimensions bound these allocations, not the bound texture sizes.
  // Menus can use a smaller active viewport in a larger pooled texture. Give
  // shaders the actual capacities so they can fall back without root-UAV OOBs.
  if (!EnsureScratch(cmd, data, state, SCRATCH_BYTES + uint64_t(settings.cache_width) * settings.cache_height * 16ull
                          + uint64_t(settings.half_width) * settings.half_height * 16ull)) return false;
  if (!Prepare(dev, state->graphics.get(), 4)) return false;
  // Immutable 256-byte CBV records: changing a slider appends a record, never
  // overwrites memory the GPU might still be reading. Pages are mapped once;
  // ordinary frames just reuse an address. Root CBVs also coexist with HDR's
  // injector, which rejects layouts already containing unrelated root constants.
  const std::array<uint32_t, 7> settings_key = {std::bit_cast<uint32_t>(settings.angle),
                                              std::bit_cast<uint32_t>(settings.object_angle),
                                              settings.samples | (settings.components << 8) | (settings.half_resolution << 16),
                                              settings.cache_width, settings.cache_height, settings.half_width, settings.half_height};
  auto cached = data->settings_cache.find(settings_key);
  if (cached == data->settings_cache.end()) {
    if (data->settings_pages.empty() || data->settings_pages.back().used == 65536) {
      SettingsPage page = {};
      if (!dev->create_resource(resource_desc(65536, memory_heap::cpu_to_gpu, resource_usage::constant_buffer),
                                nullptr, resource_usage::constant_buffer, &page.buffer)) return false;
      if (!dev->map_buffer_region(page.buffer, 0, 65536, map_access::write_only, &page.mapped)) {
        dev->destroy_resource(page.buffer);
        return false;
      }
      page.address = reinterpret_cast<ID3D12Resource*>(page.buffer.handle)->GetGPUVirtualAddress();
      data->settings_pages.push_back(page);
    }
    auto& page = data->settings_pages.back();
    std::memcpy(static_cast<uint8_t*>(page.mapped) + page.used, &settings, sizeof(settings));
    cached = data->settings_cache.emplace(settings_key, page.address + page.used).first;
    page.used += 256;
  }
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  // Do not change either root signature or any game-owned argument. Direct
  // root UAVs avoid allocating/switching descriptor heaps altogether.
  cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::unordered_access);
  native->SetGraphicsRootUnorderedAccessView(state->graphics->scratch, state->scratch_address);
  native->SetPipelineState(reinterpret_cast<ID3D12PipelineState*>(state->graphics->pipelines[4].handle));
  native->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_POINTLIST);
  cmd->draw(1, 1, 0, 0);
  const dynamic_state topology = dynamic_state::primitive_topology;
  cmd->bind_pipeline_states(1, &topology, &state->topology);
  cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::unordered_access);
  native->SetPipelineState(reinterpret_cast<ID3D12PipelineState*>(state->native_pipeline.handle));
  state->prepared = state->compute;
  state->frame_settings = settings;
  state->settings_address = cached->second;
  return true;
}
inline bool OnDispatch(command_list* cmd, uint32_t x, uint32_t y, uint32_t z) {
  if ((mode != 1.f && active_chains.load(std::memory_order_relaxed) == 0) || !x || !y || z != 1) return false;
  auto* state = cmd->get_private_data<CommandData>();
  if (!state || state->pass == Pass::none || (mode != 1.f && !state->skipped_stages)) return false;
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
    EndChain(state);
    state->depth_encoded = false;
    if (!Prepare(dev, state->compute.get(), 3)) return fallback(2, "Motion Blur: native fallback; depth conversion pipeline creation failed.");
    if (!EnsureScratch(cmd, data, state, SCRATCH_BYTES)) return false;
    state->motion_width = x * 8u;
    state->motion_height = y * 8u;
    cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::unordered_access);
    reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native())->SetComputeRootUnorderedAccessView(state->compute->scratch, state->scratch_address);
    cmd->bind_pipeline(pipeline_stage::compute_shader, state->compute->pipelines[3]);
    cmd->dispatch(x, y, z);
    cmd->bind_pipeline(pipeline_stage::compute_shader, state->native_pipeline);
    state->depth_encoded = true;
    return true;
  }
  if (state->pass == Pass::prefilter) {
    EndChain(state);
    // This 8x8 prefilter can run at QUARTER output resolution (confirmed
    // by native b0 and resource captures); motion-input size is independent.
    // Reserve for that upper bound now. Actual resolve groups/texture sizes
    // still drive reconstruction, including partial edges and lower ratios.
    if (!state->compute->native_blur || !state->compute->native_resolve
        || x > 512 || y > 512
        || !PrepareFrame(cmd, data, state, x * 2u, y * 2u)) return false;
    active_chains.fetch_add(1, std::memory_order_relaxed);
    state->skipped_stages = 1;
    return true;
  }
  if (state->pass == Pass::blur) {
    if (state->skipped_stages != 1 || state->prepared != state->compute) return false;
    state->skipped_stages = 2;
    return true;
  }
  if (!state->prepared && !PrepareFrame(cmd, data, state, x, y))
    return fallback(4, "Motion Blur: native fallback; reconstruction preflight unavailable.");
  const auto settings = state->frame_settings;
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::unordered_access);
  native->SetComputeRootUnorderedAccessView(state->compute->scratch, state->scratch_address);
  native->SetComputeRootConstantBufferView(state->compute->settings, state->settings_address);
  if (settings.cache_enabled) {
    cmd->bind_pipeline(pipeline_stage::compute_shader, state->compute->pipelines[5]);
    cmd->dispatch((state->motion_width + 7u) / 8u, (state->motion_height + 7u) / 8u, 1);
    cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::unordered_access);
  }
  cmd->bind_pipeline(pipeline_stage::compute_shader, state->compute->pipelines[0]);
  cmd->dispatch((x + 7u) / 8u, (y + 7u) / 8u, 1);
  cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::unordered_access);
  cmd->bind_pipeline(pipeline_stage::compute_shader, state->compute->pipelines[1]);
  cmd->dispatch((x + 63u) / 64u, (y + 63u) / 64u, 1);
  cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::unordered_access);
  cmd->bind_pipeline(pipeline_stage::compute_shader, state->compute->pipelines[settings.half_resolution ? 7 : settings.cache_enabled ? 8 : 2]);
  cmd->dispatch(settings.half_resolution ? x : x * 2u, settings.half_resolution ? y : y * 2u, 1);
  if (settings.half_resolution) {
    cmd->barrier(state->scratch, resource_usage::unordered_access, resource_usage::unordered_access);
    cmd->bind_pipeline(pipeline_stage::compute_shader, state->compute->pipelines[6]);
    cmd->dispatch(x * 2u, y * 2u, 1);
  }
  cmd->bind_pipeline(pipeline_stage::compute_shader, state->native_pipeline);
  if (state->skipped_stages == 2 && !data->logged_skip) {
    reshade::log::message(reshade::log::level::info,
                         "Motion Blur: redundant native prefilter and blur skipped; replacement preflight completed before suppression.");
    data->logged_skip = true;
  }
  EndChain(state);
  state->depth_encoded = false;
  if (!data->logged_active) {
    reshade::log::message(reshade::log::level::info,
                         "Motion Blur: native-binding reconstruction active; cached separated motion, optional half-resolution reconstruction, no descriptor/CBV tracking.");
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
  for (const auto& page : data->settings_pages) {
    dev->unmap_buffer_region(page.buffer);
    dev->destroy_resource(page.buffer);
  }
  for (auto buffer : data->scratch_buffers) dev->destroy_resource(buffer);
  dev->destroy_private_data<DeviceData>();
}
inline void OnInitCommand(command_list* cmd) {
  if (cmd->get_device()->get_api() == device_api::d3d12) cmd->create_private_data<CommandData>();
}
inline void OnDestroyCommand(command_list* cmd) {
  if (auto* state = cmd->get_private_data<CommandData>()) EndChain(state);
  cmd->destroy_private_data<CommandData>();
}
inline void OnResetCommand(command_list* cmd) {
  if (auto* state = cmd->get_private_data<CommandData>()) {
    state->compute.reset();
    state->graphics.reset();
    state->compute_handle = {};
    state->graphics_handle = {};
    state->native_pipeline = {};
    state->pass = Pass::none;
    state->topology = 0;
    state->depth_encoded = false;
    EndChain(state);
  }
}
inline void Use(DWORD reason) {
#define WITCHER_MOTION_EVENT(event, callback) \
  if (reason == DLL_PROCESS_ATTACH) reshade::register_event<reshade::addon_event::event>(callback); \
  else if (reason == DLL_PROCESS_DETACH) reshade::unregister_event<reshade::addon_event::event>(callback)
  WITCHER_MOTION_EVENT(init_device, OnInitDevice);
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
