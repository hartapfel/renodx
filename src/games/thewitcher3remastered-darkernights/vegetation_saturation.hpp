/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once
#include <algorithm>
#include <atomic>
#include <bit>
#include <cstring>
#include <mutex>
#include <shared_mutex>
#include <span>
#include <string_view>
#include <unordered_set>
#include <utility>
#include <vector>
#include "../../utils/data.hpp"
#include "../../utils/hash.hpp"
#include "../../utils/swapchain.hpp"

namespace witcher::night::vegetation {
using namespace reshade::api;
inline std::atomic<float> delta = 0.f;

// Only the seven audited native grades are recognized without an HDR binding.
// Foreign RenoDX grades can change bytecode on every rebuild. Recognize their
// fixed scene interface instead, including the injected b13,space50 binding.
inline bool IsGradingShader(std::span<const uint8_t> code) {
  switch (renodx::utils::hash::ComputeCRC32(code.data(), code.size())) {
    case 0x16967617: case 0x9600E32A: case 0xAD02BAB3: case 0xC5AB358E:
    case 0xF961D049: case 0x2BF760E2: case 0x6DDA5B7B: return true;
  }
  // Read container metadata only; no compiler, reflection DLL, disassembly or
  // descriptor tracking is needed at runtime. All parsing happens at creation.
  if (code.size() < 32 || std::memcmp(code.data(), "DXBC", 4) != 0) return false;
  const auto word = [](std::span<const uint8_t> bytes, size_t offset) {
    uint32_t value = 0;
    std::memcpy(&value, bytes.data() + offset, sizeof(value));
    return value;
  };
  if (word(code, 24) != code.size() || word(code, 28) > (code.size() - 32) / 4) return false;
  std::span<const uint8_t> input, output, validation;
  for (uint32_t i = 0; i < word(code, 28); ++i) {
    const size_t offset = word(code, 32 + i * 4);
    if (offset > code.size() - 8 || word(code, offset + 4) > code.size() - offset - 8) return false;
    const auto part = code.subspan(offset + 8, word(code, offset + 4));
    if (std::memcmp(code.data() + offset, "ISG1", 4) == 0) input = part;
    else if (std::memcmp(code.data() + offset, "OSG1", 4) == 0) output = part;
    else if (std::memcmp(code.data() + offset, "PSV0", 4) == 0) validation = part;
  }
  const auto signature_matches = [&word](std::span<const uint8_t> signature, bool is_output) {
    if (signature.size() < 8 || word(signature, 4) != 8) return false;
    const uint32_t count = word(signature, 0);
    if ((is_output ? count != 1 : count != 2 && count != 3)
        || count > (signature.size() - 8) / 32) return false;
    for (uint32_t i = 0; i < count; ++i) {
      const size_t offset = 8 + i * 32;
      const size_t name_offset = word(signature, offset + 4);
      const std::string_view name = is_output ? "SV_Target" : i == 0 ? "SV_Position" : "TEXCOORD";
      if (name_offset >= signature.size() || name.size() >= signature.size() - name_offset
          || std::memcmp(signature.data() + name_offset, name.data(), name.size()) != 0
          || signature[name_offset + name.size()] != 0
          || word(signature, offset) != 0  // stream
          || word(signature, offset + 8) != (i == 2 ? 2u : 0u) // semantic index
          || word(signature, offset + 12) != (is_output ? 64u : i == 0 ? 1u : 0u) // system value
          || word(signature, offset + 16) != 3 // float32
          || word(signature, offset + 20) != (is_output || i == 0 ? 0u : 1u) // register
          || signature[offset + 24] != (is_output || i == 0 ? 15u : i == 1 ? 3u : 12u)
          || word(signature, offset + 28) != 0) return false;
      // Used-component masks are deliberately ignored: optimization changes
      // their values without changing the scene transport or binding contract.
    }
    return true;
  };
  if (!signature_matches(input, false) || !signature_matches(output, true) || validation.size() < 4) return false;
  const size_t runtime_size = word(validation, 0);
  if (runtime_size < 36 || runtime_size > validation.size() - 4
      || validation.size() - 4 - runtime_size < 8) return false;
  // PSVRuntimeInfo1::ShaderStage: pixel, and no depth/sample-frequency outputs.
  if (validation[4 + 24] != 0 || word(validation, 4) != 0 || word(validation, 8) != 0) return false;
  const uint32_t count = word(validation, 4 + runtime_size);
  const size_t stride = word(validation, 8 + runtime_size);
  const size_t begin = 12 + runtime_size;
  if ((count != 4 && count != 6) || stride < 24 || count > (validation.size() - begin) / stride) return false;
  uint32_t bindings = 0;
  for (uint32_t i = 0; i < count; ++i) {
    const size_t offset = begin + i * stride;
    const uint32_t type = word(validation, offset);
    const uint32_t space = word(validation, offset + 4);
    const uint32_t slot = word(validation, offset + 8);
    const uint32_t kind = word(validation, offset + 16);
    if (word(validation, offset + 12) != slot || word(validation, offset + 20) != 0) return false;
    uint32_t bit = 0;
    if (type == 2 && kind == 13 && space == 0 && slot == 3) bit = 1;
    else if (type == 2 && kind == 13 && space == 50 && slot == 13) bit = 2;
    else if (type == 1 && kind == 14 && space == 0 && slot <= 1) bit = 4;
    else if (type == 3 && kind == 2 && space == 0 && slot == 0) bit = 8;
    else if (type == 1 && kind == 14 && space == 0 && slot == 2) bit = 16;
    else if (type == 3 && kind == 2 && space == 0 && slot == 2) bit = 32;
    else return false;
    if (bindings & bit) return false;
    bindings |= bit;
  }
  // Reject bloom, LUT, output, UI and other passes (including t1 variants).
  return bindings == (count == 4 ? 15u : 63u);
}

struct __declspec(uuid("de38e5a3-7d83-4d7f-ae39-5db33a287076")) DeviceData {
  std::mutex mutex;
  pipeline_layout layout = {};
  pipeline shader = {};
  bool attempted = false;
  std::shared_mutex grading_mutex;
  std::unordered_set<uint64_t> grading_pipelines;
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
  bool grading_pipeline = false;
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
  state->grading_pipeline = false;
  state->ClearComputeRoots();
}
inline void OnBindPipeline(command_list* c, pipeline_stage stages, pipeline p) {
  if (auto* state = renodx::utils::data::Get<CommandData>(c)) {
    state->current_pipeline = p;
    state->current_stages = stages;
    state->grading_pipeline = false;
    if ((uint32_t(stages) & uint32_t(pipeline_stage::pixel_shader)) == 0) return;
    auto* device_state = renodx::utils::data::Get<DeviceData>(c->get_device());
    if (device_state) {
      std::shared_lock lock(device_state->grading_mutex);
      state->grading_pipeline = device_state->grading_pipelines.contains(p.handle);
    }
  }
}
inline void OnInitPipeline(device* d, pipeline_layout, uint32_t count,
                           const pipeline_subobject* subobjects, pipeline p) {
  auto* state = renodx::utils::data::Get<DeviceData>(d);
  if (!state || d->get_api() != device_api::d3d12) return;
  for (uint32_t i = 0; i < count; ++i) {
    if (subobjects[i].type != pipeline_subobject_type::pixel_shader || subobjects[i].count != 1) continue;
    const auto& code = *static_cast<const shader_desc*>(subobjects[i].data);
    if (!code.code || !IsGradingShader({static_cast<const uint8_t*>(code.code), code.code_size})) continue;
    std::unique_lock lock(state->grading_mutex);
    state->grading_pipelines.insert(p.handle);
    return;
  }
}
inline void OnDestroyPipeline(device* d, pipeline p) {
  if (auto* state = renodx::utils::data::Get<DeviceData>(d)) {
    std::unique_lock lock(state->grading_mutex);
    state->grading_pipelines.erase(p.handle);
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
  if (!state || !state->grading_pipeline || !targets || targets->current_render_targets.size() != 1) return true;
  auto* d = c->get_device();
  const auto r = d->get_resource_from_view(targets->current_render_targets[0]);
  const auto desc = d->get_resource_desc(r);
  if (desc.type == resource_type::texture_2d && desc.texture.format == format::r16g16b16a16_float
      && desc.texture.samples == 1 && desc.texture.levels == 1 && desc.texture.depth_or_layers == 1) state->pending = r;
  return true;
}
inline bool OnDraw(command_list* c, uint32_t, uint32_t, uint32_t, uint32_t) { return !Arm(c); }
inline bool OnDrawIndexed(command_list* c, uint32_t, uint32_t, uint32_t, int32_t, uint32_t) { return !Arm(c); }

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
  WITCHER_VEGETATION_EVENT(init_pipeline, OnInitPipeline);
  WITCHER_VEGETATION_EVENT(destroy_pipeline, OnDestroyPipeline);
  WITCHER_VEGETATION_EVENT(bind_pipeline, OnBindPipeline);
  WITCHER_VEGETATION_EVENT(draw, OnDraw);
  WITCHER_VEGETATION_EVENT(draw_indexed, OnDrawIndexed);
  WITCHER_VEGETATION_EVENT(push_constants, OnConstants);
  WITCHER_VEGETATION_EVENT(push_descriptors, OnDescriptors);
  WITCHER_VEGETATION_EVENT(bind_descriptor_tables, OnTables);
  WITCHER_VEGETATION_EVENT(barrier, OnBarrier);
#undef WITCHER_VEGETATION_EVENT
}
}  // namespace witcher::night::vegetation
