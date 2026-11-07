// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <array>
#include <memory>
#include <optional>
#include <d3d12.h>
#include <wrl/client.h>
#include <include/reshade.hpp>
#include "../../../utils/data.hpp"
#include "hooks.hpp"
namespace hartapfelfx::clouds::heaps {
namespace api = reshade::api;
using Heaps = std::array<Microsoft::WRL::ComPtr<ID3D12DescriptorHeap>, 2>;
struct Arguments {
  ID3D12RootSignature* signature = nullptr;
  std::array<uint64_t, 64> cbvs{};
  std::array<std::array<uint32_t, 64>, 64> words{};
  std::array<uint64_t, 64> valid_words{};
};
struct __declspec(uuid("c945bc78-30a0-4f2c-b127-2784d4b0f750")) State {
  std::mutex mutex;
  Heaps heaps;
  bool known = false;
  void* native = nullptr;
  void* heap_method = nullptr;
  Arguments graphics, compute;
};
inline std::mutex mutex;
inline std::map<api::command_list*, std::shared_ptr<State>> commands;
inline std::map<void*, std::shared_ptr<State>> native_commands;
inline State* Find(api::command_list* command) {
  return renodx::utils::data::Get<State>(command);
}
inline void STDMETHODCALLTYPE Set(ID3D12GraphicsCommandList* command, UINT count, ID3D12DescriptorHeap* const* values) {
  using Call = void(STDMETHODCALLTYPE*)(ID3D12GraphicsCommandList*, UINT, ID3D12DescriptorHeap* const*);
  void* target = (*reinterpret_cast<void***>(command))[28];
  static thread_local void* cached_target = nullptr;
  static thread_local Call original = nullptr;
  if (cached_target != target) {
    original = reinterpret_cast<Call>(hooks::Original(target));
    cached_target = target;
  }
  std::shared_ptr<State> state;
  {
    std::lock_guard lock(mutex);
    if (const auto found = native_commands.find(command); found != native_commands.end()) state = found->second;
  }
  if (state) {
    std::lock_guard lock(state->mutex);
    state->heaps = {};
    for (UINT index = 0; index < count; ++index) {
      const auto type = values[index]->GetDesc().Type;
      if (type == D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV) state->heaps[0] = values[index];
      if (type == D3D12_DESCRIPTOR_HEAP_TYPE_SAMPLER) state->heaps[1] = values[index];
    }
    state->known = true;
  }
  original(command, count, values);
}
inline void Refresh(api::command_list* command) {
  auto* state = Find(command);
  if (!state) return;
  auto* native = reinterpret_cast<void*>(command->get_native());
  void* method = (*reinterpret_cast<void***>(native))[28];
  if (state->native == native && state->heap_method == method) return;
  // Only creation/reset/interface upgrades need the global alias and hook maps.
  {
    std::lock_guard lock(mutex);
    if (const auto found = commands.find(command); found != commands.end()) native_commands[native] = found->second;
  }
  if (hooks::Attach(method, reinterpret_cast<void*>(&Set))) {
    state->native = native;
    state->heap_method = method;
  }
}
inline void TrackLayout(api::command_list* command, api::shader_stage stages, api::pipeline_layout layout) {
  if (command->get_device()->get_api() != api::device_api::d3d12) return;
  Refresh(command);
  if (auto state = Find(command)) {
    std::lock_guard lock(state->mutex);
    for (auto [mask, arguments] : {std::pair{api::shader_stage::all_graphics, &state->graphics},
                                  std::pair{api::shader_stage::all_compute | api::shader_stage::all_ray_tracing, &state->compute}}) {
      if ((stages & mask) == api::shader_stage(0)) continue;
      auto* signature = reinterpret_cast<ID3D12RootSignature*>(layout.handle);
      if (arguments->signature != signature) {
        arguments->signature = signature;
        arguments->cbvs.fill(0);
        arguments->valid_words.fill(0);
      }
    }
  }
}
inline void OnTables(api::command_list* command, api::shader_stage stages, api::pipeline_layout layout, uint32_t, uint32_t, const api::descriptor_table*) {
  TrackLayout(command, stages, layout);
}
inline void OnDescriptors(api::command_list* command, api::shader_stage stages, api::pipeline_layout layout, uint32_t index, const api::descriptor_table_update& update) {
  if (command->get_device()->get_api() != api::device_api::d3d12) return;
  TrackLayout(command, stages, layout);
  if (index >= 64 || update.type != api::descriptor_type::constant_buffer || update.count != 1 || !update.descriptors) return;
  const auto& range = *static_cast<const api::buffer_range*>(update.descriptors);
  const uint64_t address = range.buffer.handle ? reinterpret_cast<ID3D12Resource*>(range.buffer.handle)->GetGPUVirtualAddress() + range.offset : 0;
  if (auto state = Find(command)) {
    std::lock_guard lock(state->mutex);
    if ((stages & api::shader_stage::all_graphics) != api::shader_stage(0)) state->graphics.cbvs[index] = address;
    if ((stages & (api::shader_stage::all_compute | api::shader_stage::all_ray_tracing)) != api::shader_stage(0)) state->compute.cbvs[index] = address;
  }
}
inline void OnConstants(api::command_list* command, api::shader_stage stages, api::pipeline_layout layout, uint32_t index, uint32_t offset, uint32_t count, const void* values) {
  TrackLayout(command, stages, layout);
  if (index >= 64 || offset >= 64 || count > 64 - offset || !values) return;
  if (auto state = Find(command)) {
    std::lock_guard lock(state->mutex);
    for (auto [mask, arguments] : {std::pair{api::shader_stage::all_graphics, &state->graphics},
                                  std::pair{api::shader_stage::all_compute | api::shader_stage::all_ray_tracing, &state->compute}}) {
      if ((stages & mask) == api::shader_stage(0)) continue;
      for (uint32_t word = 0; word < count; ++word) {
        arguments->words[index][offset + word] = static_cast<const uint32_t*>(values)[word];
        arguments->valid_words[index] |= uint64_t(1) << (offset + word);
      }
    }
  }
}
// ReShade's API backend bypasses native binding events. Intercept these two
// stable API methods to include HDR-addon constants without patching Agility's
// mutable native root-method tables. Slots follow reshade_api_device.hpp.
inline void ApiDescriptors(api::command_list* command, api::shader_stage stages, api::pipeline_layout layout, uint32_t index, const api::descriptor_table_update& update) {
  using Call = void(*)(api::command_list*, api::shader_stage, api::pipeline_layout, uint32_t, const api::descriptor_table_update&);
  void* target = (*reinterpret_cast<void***>(command))[13];
  static thread_local void* cached_target = nullptr;
  static thread_local Call original = nullptr;
  if (cached_target != target) {
    original = reinterpret_cast<Call>(hooks::Original(target));
    cached_target = target;
  }
  original(command, stages, layout, index, update);
  OnDescriptors(command, stages, layout, index, update);
}
inline void ApiConstants(api::command_list* command, api::shader_stage stages, api::pipeline_layout layout, uint32_t index, uint32_t offset, uint32_t count, const void* values) {
  using Call = void(*)(api::command_list*, api::shader_stage, api::pipeline_layout, uint32_t, uint32_t, uint32_t, const void*);
  void* target = (*reinterpret_cast<void***>(command))[12];
  static thread_local void* cached_target = nullptr;
  static thread_local Call original = nullptr;
  if (cached_target != target) {
    original = reinterpret_cast<Call>(hooks::Original(target));
    cached_target = target;
  }
  original(command, stages, layout, index, offset, count, values);
  OnConstants(command, stages, layout, index, offset, count, values);
}
inline void Initialize(api::command_list* command) {
  if (command->get_device()->get_api() != api::device_api::d3d12) return;
  if (!hooks::Attach((*reinterpret_cast<void***>(command))[12], reinterpret_cast<void*>(&ApiConstants))
      || !hooks::Attach((*reinterpret_cast<void***>(command))[13], reinterpret_cast<void*>(&ApiDescriptors))) return;
  {
    std::lock_guard lock(mutex);
    auto state = std::make_shared<State>();
    command->set_private_data(reinterpret_cast<const uint8_t*>(&renodx::utils::data::GetUuid<State>()),
                              reinterpret_cast<uint64_t>(state.get()));
    commands[command] = std::move(state);
  }
  Refresh(command);
}
inline void Reset(api::command_list* command) {
  if (command->get_device()->get_api() != api::device_api::d3d12) return;
  Refresh(command);
  if (auto state = Find(command)) {
    std::lock_guard lock(state->mutex);
    state->heaps = {}; state->known = false;
    for (auto* arguments : {&state->graphics, &state->compute}) {
      arguments->signature = nullptr;
      arguments->cbvs.fill(0);
      arguments->valid_words.fill(0);
    }
  }
}
inline Arguments GetArguments(api::command_list* command, bool compute) {
  if (auto state = Find(command)) {
    std::lock_guard lock(state->mutex);
    return compute ? state->compute : state->graphics;
  }
  return {};
}
inline void Destroy(api::command_list* command) {
  command->set_private_data(reinterpret_cast<const uint8_t*>(&renodx::utils::data::GetUuid<State>()), 0);
  std::lock_guard lock(mutex);
  if (const auto found = commands.find(command); found != commands.end()) {
    std::erase_if(native_commands, [&](const auto& item) { return item.second == found->second; });
    commands.erase(found);
  }
}
inline std::optional<Heaps> Get(api::command_list* command) {
  if (auto state = Find(command)) {
    std::lock_guard lock(state->mutex);
    if (state->known) return state->heaps;
  }
  return {};
}
}  // namespace hartapfelfx::clouds::heaps
