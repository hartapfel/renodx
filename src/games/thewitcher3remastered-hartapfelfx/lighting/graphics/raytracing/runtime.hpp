// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <Windows.h>
#include "../rendering/native_hooks.hpp"
#include <wrl/client.h>
#include "controls.hpp"
#include "hit_bindings.hpp"
#include "state.hpp"
#include "../volumetrics/ray_bindings.hpp"
#include "../../../../../utils/directx.hpp"

namespace witcher3graphics::raytracing {
// Filled from immutable embedded libraries before registering device callbacks.
inline std::vector<LibraryReplacement> replacements;
using CreateState = HRESULT(STDMETHODCALLTYPE*)(ID3D12Device5*, const D3D12_STATE_OBJECT_DESC*, REFIID, void**);
using AddState = HRESULT(STDMETHODCALLTYPE*)(ID3D12Device7*, const D3D12_STATE_OBJECT_DESC*, ID3D12StateObject*, REFIID, void**);
inline CreateState create_state = nullptr;
inline AddState add_state = nullptr;
inline void* create_target = nullptr;
inline void* add_target = nullptr;
inline std::mutex install_mutex, devices_mutex;
inline bool installed = false;
inline std::unordered_map<ID3D12Device*, device*> native_devices;

// Resolve only roots extended by this addon. Native collections can contribute
// unchanged hit groups; only tracked libraries contribute feature availability.
inline ControlData::State ResolveState(ControlData* data, const D3D12_STATE_OBJECT_DESC& desc, ID3D12StateObject* parent) {
  std::lock_guard lock(data->mutex);
  ControlData::State result{};
  if (!desc.pSubobjects || desc.NumSubobjects > 4096) return {};
  if (parent) {
    const auto found = data->states.find(reinterpret_cast<uint64_t>(parent));
    if (found == data->states.end()) return {};
    result = found->second;
  }
  for (UINT i = 0; i < desc.NumSubobjects; ++i) {
    const auto& object = desc.pSubobjects[i];
    if (!object.pDesc) return {};
    uint64_t root = 0;
    if (object.Type == D3D12_STATE_SUBOBJECT_TYPE_GLOBAL_ROOT_SIGNATURE)
      root = reinterpret_cast<uint64_t>(static_cast<const D3D12_GLOBAL_ROOT_SIGNATURE*>(object.pDesc)->pGlobalRootSignature);
    else if (object.Type == D3D12_STATE_SUBOBJECT_TYPE_EXISTING_COLLECTION) {
      const auto* collection = static_cast<const D3D12_EXISTING_COLLECTION_DESC*>(object.pDesc);
      const auto found = data->states.find(reinterpret_cast<uint64_t>(collection->pExistingCollection));
      if (found != data->states.end()) { root = found->second.root; result.libraries |= found->second.libraries; }
    }
    if (root) {
      if (result.root && result.root != root) return {};
      result.root = root;
    }
  }
  if (!data->layouts.contains(result.root)) return {};
  return result;
}

// One path for CreateStateObject and AddToStateObject so library ownership and
// native fallback cannot diverge. No shader table or identifier is rewritten.
template <typename Call>
HRESULT CreateOnDevice(device* api_device, const D3D12_STATE_OBJECT_DESC* desc, ID3D12StateObject* parent,
    REFIID iid, void** output, Call&& call) {
  auto* data = api_device ? renodx::utils::data::Get<ControlData>(api_device) : nullptr;
  if (!data || !desc || !output) return call(desc, iid, output);
  StateDescription modified;
  ControlData::State state{};
  bool changed = false;
  uint32_t required = 0, reflection = 0, fog = 0;
  for (uint32_t i = 0; i < replacements.size() && i < 32; ++i) {
    if (replacements[i].purpose == LibraryPurpose::water) required |= 1u << i;
    else if (replacements[i].purpose == LibraryPurpose::fog) fog |= 1u << i;
    else reflection |= 1u << i;
  }
  try {
    state = ResolveState(data, *desc, parent);
    const bool hit_output = state.root && hits::FindHitRoots(api_device, {state.root}).role == hits::LayoutRole::producer;
    const bool fog_output = state.root && volumetrics::rays::FindProducerRoots({state.root}).Valid();
    const bool matched = modified.Replace(*desc, replacements,
        required | (hit_output ? reflection : 0u) | (fog_output ? fog : 0u));
    changed = matched && state.root;
    if (matched && !state.root && (modified.Mask() & required) != 0) {
      std::lock_guard lock(data->mutex);
      data->water_failed = true;
    }
  } catch (...) {
    // Allocation or unsupported descriptors leave the original call intact.
    { std::lock_guard lock(data->mutex); data->water_failed |= required != 0; }
    state = {}; changed = false;
  }
  HRESULT result = call(changed ? modified.Get() : desc, iid, output);
  // Fog is optional independently of water and material lighting. Remove only
  // its replacements first; preserve valid required/material libraries on retry.
  if (changed && FAILED(result) && (modified.Mask() & fog) != 0) {
    const uint32_t retained = modified.Mask() & ~fog;
    try {
      changed = modified.Replace(*desc, replacements, retained);
    } catch (...) {
      changed = false;
      std::lock_guard lock(data->mutex); data->water_failed |= (retained & required) != 0;
    }
    result = call(changed ? modified.Get() : desc, iid, output);
  }
  // A failed optional RT library must not disable otherwise valid PT water.
  // Retry only the required replacements when a state contains both families.
  if (changed && FAILED(result) && (modified.Mask() & reflection) != 0) {
    try {
      changed = modified.Replace(*desc, replacements, required);
    } catch (...) {
      changed = false;
      std::lock_guard lock(data->mutex); data->water_failed |= required != 0;
    }
    result = call(changed ? modified.Get() : desc, iid, output);
  }
  if (changed && FAILED(result)) {
    // Inherited collections/parent libraries survive a native addition retry.
    { std::lock_guard lock(data->mutex); data->water_failed |= (modified.Mask() & required) != 0; }
    result = call(desc, iid, output);
  } else if (changed) state.libraries |= modified.Mask();
  if (SUCCEEDED(result) && *output && state.root) {
    Microsoft::WRL::ComPtr<ID3D12StateObject> object;
    if (SUCCEEDED(static_cast<IUnknown*>(*output)->QueryInterface(IID_PPV_ARGS(&object)))) {
      try {
        std::lock_guard lock(data->mutex);
        state.selection.reset(); // Shader identifiers belong to this new state, not its parent.
        data->states[reinterpret_cast<uint64_t>(object.Get())] = state;
      } catch (...) {
        std::lock_guard lock(data->mutex);
        data->water_failed |= (state.libraries & required) != 0;
      }
    }
  }
  return result;
}
template <typename Call>
HRESULT CreateNative(ID3D12Device* native, const D3D12_STATE_OBJECT_DESC* desc, ID3D12StateObject* parent,
    REFIID iid, void** output, Call&& call) {
  device* api_device = nullptr;
  {
    std::lock_guard lock(devices_mutex);
    const auto found = native_devices.find(native);
    if (found != native_devices.end()) api_device = found->second;
  }
  return CreateOnDevice(api_device, desc, parent, iid, output, std::forward<Call>(call));
}
inline HRESULT STDMETHODCALLTYPE CreateHook(ID3D12Device5* dev, const D3D12_STATE_OBJECT_DESC* desc, REFIID iid, void** output) {
  return CreateNative(dev, desc, nullptr, iid, output,
      [dev](const auto* value, REFIID requested, void** result) { return create_state(dev, value, requested, result); });
}
inline HRESULT STDMETHODCALLTYPE AddHook(ID3D12Device7* dev, const D3D12_STATE_OBJECT_DESC* desc,
    ID3D12StateObject* parent, REFIID iid, void** output) {
  return CreateNative(dev, desc, parent, iid, output,
      [dev,parent](const auto* value, REFIID requested, void** result) { return add_state(dev, value, parent, requested, result); });
}

inline bool Install(ID3D12Device* device) {
  std::lock_guard lock(install_mutex);
  Microsoft::WRL::ComPtr<ID3D12Device5> device5;
  Microsoft::WRL::ComPtr<ID3D12Device7> device7;
  if (FAILED(device->QueryInterface(IID_PPV_ARGS(&device5))) || FAILED(device->QueryInterface(IID_PPV_ARGS(&device7)))) return false;
  void* create_address = (*reinterpret_cast<void***>(device5.Get()))[62];
  void* add_address = (*reinterpret_cast<void***>(device7.Get()))[66];
  if (installed) return create_address == create_target && add_address == add_target;
  create_state = reinterpret_cast<CreateState>(create_address);
  add_state = reinterpret_cast<AddState>(add_address);
  const std::array hooks{
      NativeHook{reinterpret_cast<void**>(&create_state), reinterpret_cast<void*>(&CreateHook)},
      NativeHook{reinterpret_cast<void**>(&add_state), reinterpret_cast<void*>(&AddHook)}};
  installed = AttachNativeHooks(hooks, reinterpret_cast<const void*>(&Install));
  if (installed) { create_target = create_address; add_target = add_address; }
  return installed;
}
inline void PopulateLibraryMasks(device* dev) {
  if (replacements.size() > 32) return;
  if (auto* data = renodx::utils::data::Get<ControlData>(dev)) {
    std::lock_guard lock(data->mutex);
    data->required_libraries = data->reflection_libraries = data->fog_libraries = 0;
    data->hit_libraries = {};
    for (uint32_t i = 0; i < replacements.size(); ++i) {
      if (replacements[i].purpose == LibraryPurpose::water) data->required_libraries |= 1u << i;
      else if (replacements[i].purpose == LibraryPurpose::fog) data->fog_libraries |= 1u << i;
      else {
        data->reflection_libraries |= 1u << i;
        data->hit_libraries[uint32_t(replacements[i].purpose) - 1u] |= 1u << i;
      }
    }
  }
}
inline void OnQueue(command_queue* queue) {
  if (queue->get_device()->get_api() != device_api::d3d12 || replacements.empty() || replacements.size() > 32) return;
  PopulateLibraryMasks(queue->get_device());
  auto* native_queue = reinterpret_cast<ID3D12CommandQueue*>(queue->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&native_queue);
  Microsoft::WRL::ComPtr<ID3D12Device> native;
  if (FAILED(native_queue->GetDevice(IID_PPV_ARGS(&native))) || !Install(native.Get())) return;
  {
    std::lock_guard lock(devices_mutex); native_devices[native.Get()] = queue->get_device();
  }
}
inline void OnDestroyNative(device* dev) {
  std::lock_guard lock(devices_mutex);
  std::erase_if(native_devices, [dev](const auto& entry) { return entry.second == dev; });
}
inline void UseRuntime(DWORD reason) {
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::init_command_queue>(OnQueue);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyNative);
  } else if (reason == DLL_PROCESS_DETACH) {
    controls.store(0, std::memory_order_release);
    reshade::unregister_event<reshade::addon_event::init_command_queue>(OnQueue);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyNative);
    std::lock_guard lock(devices_mutex); native_devices.clear();
  }
}
}  // namespace witcher3graphics::raytracing
