/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once
#include <algorithm>
#include <atomic>
#include <bit>
#include <mutex>
#include <utility>
#include <vector>
#include "../../utils/data.hpp"
#include "../../utils/swapchain.hpp"

namespace witcher::night::vegetation {
using namespace reshade::api;
inline std::atomic<float> delta = 0.f;

struct __declspec(uuid("de38e5a3-7d83-4d7f-ae39-5db33a287076")) DeviceData {
  std::mutex mutex;
  pipeline_layout layout = {};
  pipeline shader = {};
  bool attempted = false;
};
struct RootBinding {
  descriptor_table table = {};
  std::vector<uint32_t> constants;
  descriptor_type type = descriptor_type::constant_buffer;
  buffer_range buffer = {};
  resource_view view = {};
  bool descriptor = false;
};
struct __declspec(uuid("1ae8a882-2869-4b54-8154-86ddfe49c32d")) CommandData {
  resource pending = {};
  resource scratch = {};
  uint64_t scratch_size = 0;
  std::vector<resource> buffers;
  pipeline current_pipeline = {};
  pipeline_stage current_stages = pipeline_stage::all;
  pipeline_layout compute_layout = {};
  std::vector<RootBinding> roots;

  void ClearComputeRoots() {
    compute_layout = {};
    for (auto& root : roots) {
      root.table = {};
      root.constants.clear();
      root.descriptor = false;
    }
  }
};

inline void OnInitDevice(device* d) { renodx::utils::data::Create<DeviceData>(d); }
inline void OnDestroyDevice(device* d) {
  auto* state = renodx::utils::data::Get<DeviceData>(d);
  if (!state) return;
  if (state->shader.handle) d->destroy_pipeline(state->shader);
  if (state->layout.handle) d->destroy_pipeline_layout(state->layout);
  renodx::utils::data::Delete<DeviceData>(d);
}
inline void OnInitCommand(command_list* c) { renodx::utils::data::Create<CommandData>(c); }
inline void OnDestroyCommand(command_list* c) {
  auto* state = renodx::utils::data::Get<CommandData>(c);
  if (!state) return;
  for (auto buffer : state->buffers) c->get_device()->destroy_resource(buffer);
  renodx::utils::data::Delete<CommandData>(c);
}
inline void OnResetCommand(command_list* c) {
  auto* state = renodx::utils::data::Get<CommandData>(c);
  if (!state) return;
  state->pending = {};
  state->current_pipeline = {};
  state->ClearComputeRoots();
}
inline void OnBindPipeline(command_list* c, pipeline_stage stages, pipeline p) {
  if (auto* state = renodx::utils::data::Get<CommandData>(c)) {
    state->current_pipeline = p;
    state->current_stages = stages;
  }
}
// Capture only compute root values, never descriptor heap contents/copies.
// Our root-UAV pass leaves graphics roots and descriptor heaps untouched.
inline CommandData* ComputeState(command_list* c, shader_stage stages, pipeline_layout layout) {
  if ((uint32_t(stages) & uint32_t(shader_stage::compute | shader_stage::all_ray_tracing)) == 0) return nullptr;
  auto* state = renodx::utils::data::Get<CommandData>(c);
  if (state && state->compute_layout != layout) {
    state->ClearComputeRoots();
    state->compute_layout = layout;
  }
  return state;
}
inline void OnConstants(command_list* c, shader_stage stages, pipeline_layout layout,
                        uint32_t param, uint32_t first, uint32_t count, const void* values) {
  auto* state = ComputeState(c, stages, layout);
  if (!state || !values) return;
  if (state->roots.size() <= param) state->roots.resize(param + 1);
  auto& root = state->roots[param];
  if (root.constants.size() < first + count) root.constants.resize(first + count);
  std::copy_n(static_cast<const uint32_t*>(values), count, root.constants.begin() + first);
}
inline void OnTables(command_list* c, shader_stage stages, pipeline_layout layout,
                     uint32_t first, uint32_t count, const descriptor_table* tables) {
  auto* state = ComputeState(c, stages, layout);
  if (!state || !tables) return;
  if (state->roots.size() < first + count) state->roots.resize(first + count);
  for (uint32_t i = 0; i < count; ++i) state->roots[first + i].table = tables[i];
}
inline void OnDescriptors(command_list* c, shader_stage stages, pipeline_layout layout,
                          uint32_t param, const descriptor_table_update& update) {
  auto* state = ComputeState(c, stages, layout);
  // DX12 native root descriptors contain exactly one buffer binding.
  if (!state || !update.descriptors || update.count != 1 || update.array_offset != 0) return;
  if (state->roots.size() <= param) state->roots.resize(param + 1);
  auto& root = state->roots[param];
  root.type = update.type;
  root.descriptor = true;
  if (update.type == descriptor_type::constant_buffer) root.buffer = *static_cast<const buffer_range*>(update.descriptors);
  else root.view = *static_cast<const resource_view*>(update.descriptors);
}

inline bool Arm(command_list* c) {
  if (delta.load(std::memory_order_relaxed) == 0.f) return true;
  auto* state = renodx::utils::data::Get<CommandData>(c);
  auto* targets = renodx::utils::swapchain::GetCurrentState(c);
  if (!state || !targets || targets->current_render_targets.size() != 1) return true;
  auto* d = c->get_device();
  const auto r = d->get_resource_from_view(targets->current_render_targets[0]);
  const auto desc = d->get_resource_desc(r);
  if (desc.type == resource_type::texture_2d && desc.texture.format == format::r16g16b16a16_float
      && desc.texture.samples == 1 && desc.texture.levels == 1 && desc.texture.depth_or_layers == 1) state->pending = r;
  return true;
}

inline void OnBarrier(command_list* c, uint32_t count, const resource* resources,
                      const resource_usage* old_states, const resource_usage* new_states) {
  auto* state = renodx::utils::data::Get<CommandData>(c);
  if (!state || !state->pending.handle) return;
  for (uint32_t i = 0; i < count; ++i) {
    if (resources[i] != state->pending || (uint32_t(old_states[i]) & uint32_t(resource_usage::render_target)) == 0) continue;
    const auto target = std::exchange(state->pending, resource{});
    uint32_t final_transition = i;
    for (uint32_t next = i + 1; next < count; ++next) {
      if (resources[next] == target) final_transition = next;
    }
    const float amount = delta.load(std::memory_order_relaxed);
    if (amount == 0.f) return;
    // ReShade's DX12 barrier event is AFTER the native transition. Restore
    // its destination state after the in-place scene operation.
    auto* d = c->get_device();
    auto* device_state = renodx::utils::data::Get<DeviceData>(d);
    if (!device_state || d->get_api() != device_api::d3d12) return;
    {
      std::lock_guard lock(device_state->mutex);
      if (!device_state->attempted) {
        device_state->attempted = true;
        pipeline_layout_param params[2] = {};
        params[0].type = pipeline_layout_param_type::push_descriptors;
        params[0].push_descriptors.type = descriptor_type::buffer_unordered_access_view;
        params[0].push_descriptors.count = 1;
        params[0].push_descriptors.visibility = shader_stage::compute;
        params[1].type = pipeline_layout_param_type::push_constants;
        params[1].push_constants.count = 4;
        params[1].push_constants.visibility = shader_stage::compute;
        if (d->create_pipeline_layout(2, params, &device_state->layout)) {
          shader_desc code = {__0xF3B20000.data(), __0xF3B20000.size()};
          const pipeline_subobject shader_object = {pipeline_subobject_type::compute_shader, 1, &code};
          d->create_pipeline(device_state->layout, 1, &shader_object, &device_state->shader);
        }
        if (!device_state->shader.handle) reshade::log::message(reshade::log::level::warning,
            "[Darker Nights] Vegetation saturation pass unavailable; scene preserved.");
      }
    }
    if (!device_state->shader.handle) return;
    const auto desc = d->get_resource_desc(target);
    const uint32_t pitch = (desc.texture.width * 8u + 255u) & ~255u;
    const uint64_t bytes = uint64_t(pitch) * desc.texture.height;
    if (state->scratch_size < bytes) {
      resource buffer = {};
      if (!d->create_resource(resource_desc(bytes, memory_heap::gpu_only,
          resource_usage::unordered_access | resource_usage::copy_source | resource_usage::copy_dest),
          nullptr, resource_usage::unordered_access, &buffer)) return;
      state->scratch = buffer;
      state->scratch_size = bytes;
      state->buffers.push_back(buffer);
    }
    const resource objects[] = {target, state->scratch};
    const resource_usage original[] = {new_states[final_transition], resource_usage::unordered_access};
    const resource_usage copying[] = {resource_usage::copy_source, resource_usage::copy_dest};
    c->barrier(2, objects, original, copying);
    c->copy_texture_to_buffer(target, 0, nullptr, state->scratch, 0, pitch / 8, desc.texture.height);
    c->barrier(state->scratch, resource_usage::copy_dest, resource_usage::unordered_access);
    c->bind_pipeline(pipeline_stage::all_compute, device_state->shader);
    const uint32_t constants[] = {desc.texture.width, desc.texture.height, pitch, std::bit_cast<uint32_t>(amount)};
    c->push_constants(shader_stage::compute, device_state->layout, 1, 0, 4, constants);
    // Buffer view handles encode GPU addresses for DX12 root UAV bindings.
    auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(c->get_native());
    native->SetComputeRootUnorderedAccessView(0,
        reinterpret_cast<ID3D12Resource*>(state->scratch.handle)->GetGPUVirtualAddress());
    c->dispatch((desc.texture.width + 7) / 8, (desc.texture.height + 7) / 8, 1);
    const resource_usage processed[] = {resource_usage::copy_source, resource_usage::unordered_access};
    const resource_usage writing[] = {resource_usage::copy_dest, resource_usage::copy_source};
    c->barrier(2, objects, processed, writing);
    c->copy_buffer_to_texture(state->scratch, 0, pitch / 8, desc.texture.height, target, 0);
    c->barrier(2, objects, writing, original);
    if (state->compute_layout.handle) {
      // A zero-table bind restores the signature even if it has no root values.
      c->bind_descriptor_tables(shader_stage::compute, state->compute_layout, 0, 0, nullptr);
      for (uint32_t param = 0; param < state->roots.size(); ++param) {
        const auto& root = state->roots[param];
        if (!root.constants.empty()) c->push_constants(shader_stage::compute, state->compute_layout,
            param, 0, uint32_t(root.constants.size()), root.constants.data());
        if (root.table.handle) c->bind_descriptor_tables(shader_stage::compute, state->compute_layout, param, 1, &root.table);
        if (root.descriptor) c->push_descriptors(shader_stage::compute, state->compute_layout, param,
            descriptor_table_update{.count = 1, .type = root.type,
                .descriptors = root.type == descriptor_type::constant_buffer ? static_cast<const void*>(&root.buffer) : static_cast<const void*>(&root.view)});
      }
    }
    if (state->current_pipeline.handle) c->bind_pipeline(state->current_stages, state->current_pipeline);
    return;
  }
}

inline void Use(DWORD reason) {
#define WITCHER_VEGETATION_EVENT(ev, fn) \
  if (reason == DLL_PROCESS_ATTACH) reshade::register_event<reshade::addon_event::ev>(fn); \
  else if (reason == DLL_PROCESS_DETACH) reshade::unregister_event<reshade::addon_event::ev>(fn)
  WITCHER_VEGETATION_EVENT(init_device, OnInitDevice);
  WITCHER_VEGETATION_EVENT(destroy_device, OnDestroyDevice);
  WITCHER_VEGETATION_EVENT(init_command_list, OnInitCommand);
  WITCHER_VEGETATION_EVENT(destroy_command_list, OnDestroyCommand);
  WITCHER_VEGETATION_EVENT(reset_command_list, OnResetCommand);
  WITCHER_VEGETATION_EVENT(bind_pipeline, OnBindPipeline);
  WITCHER_VEGETATION_EVENT(push_constants, OnConstants);
  WITCHER_VEGETATION_EVENT(push_descriptors, OnDescriptors);
  WITCHER_VEGETATION_EVENT(bind_descriptor_tables, OnTables);
  WITCHER_VEGETATION_EVENT(barrier, OnBarrier);
#undef WITCHER_VEGETATION_EVENT
}
}  // namespace witcher::night::vegetation
