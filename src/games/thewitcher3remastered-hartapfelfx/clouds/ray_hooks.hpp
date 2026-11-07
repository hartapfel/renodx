// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "hooks.hpp"
#include <map>
#include <mutex>
#include "native.hpp"
#include "ray_state.hpp"
#include "../fog/bindings.hpp"

namespace hartapfelfx::clouds::ray_hooks {
namespace api = reshade::api;
using Create = HRESULT(STDMETHODCALLTYPE*)(ID3D12Device5*, const D3D12_STATE_OBJECT_DESC*, REFIID, void**);
using Add = HRESULT(STDMETHODCALLTYPE*)(ID3D12Device7*, const D3D12_STATE_OBJECT_DESC*, ID3D12StateObject*, REFIID, void**);
inline std::mutex mutex;
inline std::map<void*, api::device*> devices;
inline std::function<bool(api::device*, ID3D12StateObject*)> known;
inline std::function<void(api::device*, ID3D12StateObject*)> created;
using NativeCall = std::function<HRESULT(const D3D12_STATE_OBJECT_DESC*)>;
inline HRESULT (*adapt_lighting)(api::device*, const D3D12_STATE_OBJECT_DESC*, ID3D12StateObject*, REFIID, void**,
                                 const NativeCall&) = nullptr;
inline thread_local bool inside = false;
inline bool RootCompatible(api::device* device, ID3D12RootSignature* root) {
  auto* data = renodx::utils::data::Get<fog::DeviceData>(device);
  if (!data) return false;
  std::shared_lock lock(data->mutex);
  const auto found = data->layouts.find(reinterpret_cast<uint64_t>(root));
  if (found == data->layouts.end()) return false;
  for (const auto& parameter : found->second.parameters)
    for (const auto& range : parameter.ranges)
      if (range.dx_register_space == 72 && range.dx_register_index == 0 && range.type == api::descriptor_type::buffer_shader_resource_view) return true;
  return false;
}
inline bool Compatible(api::device* device, const D3D12_STATE_OBJECT_DESC& descriptor, ID3D12StateObject* existing) {
  if (existing && known && known(device, existing)) return true;
  for (uint32_t index = 0; index < descriptor.NumSubobjects; ++index) {
    const auto& object = descriptor.pSubobjects[index];
    if (object.Type == D3D12_STATE_SUBOBJECT_TYPE_GLOBAL_ROOT_SIGNATURE
        && RootCompatible(device, static_cast<const D3D12_GLOBAL_ROOT_SIGNATURE*>(object.pDesc)->pGlobalRootSignature)) return true;
    if (object.Type == D3D12_STATE_SUBOBJECT_TYPE_EXISTING_COLLECTION && known
        && known(device, static_cast<const D3D12_EXISTING_COLLECTION_DESC*>(object.pDesc)->pExistingCollection)) return true;
  }
  // Rootless collections resolve their global bindings when linked into the
  // final pipeline. The exact native-library match still gates replacement.
  return descriptor.Type == D3D12_STATE_OBJECT_TYPE_COLLECTION;
}
template <typename NativeCall>
HRESULT Invoke(api::device* device, const D3D12_STATE_OBJECT_DESC* descriptor, ID3D12StateObject* existing,
               REFIID iid, void** output, NativeCall call) {
  if (!device || !descriptor || inside) return call(descriptor);
  const bool cloud_compatible = Compatible(device, *descriptor, existing);
  if (!cloud_compatible && !adapt_lighting) return call(descriptor);
  inside = true;
  struct Exit { ~Exit() { inside = false; } } exit;
  try {
    bool inherited = existing && known && known(device, existing);
    for (uint32_t index = 0; index < descriptor->NumSubobjects; ++index) {
      const auto& object = descriptor->pSubobjects[index];
      if (object.Type == D3D12_STATE_SUBOBJECT_TYPE_EXISTING_COLLECTION && known)
        inherited |= known(device, static_cast<const D3D12_EXISTING_COLLECTION_DESC*>(object.pDesc)->pExistingCollection);
    }
    RayState replacement(*descriptor, [cloud_compatible](std::span<const uint8_t> code) {
      return cloud_compatible ? native::RayLibrary(renodx::utils::hash::ComputeCRC32(code.data(), code.size())) : std::span<const uint8_t>{};
    });
    const auto* adapted = replacement.changed ? &replacement.descriptor : descriptor;
    HRESULT result = adapt_lighting ? adapt_lighting(device, adapted, existing, iid, output, call) : call(adapted);
    if (FAILED(result) && replacement.changed) {
      renodx::utils::log::e("HartapfelFX native ray adapter rejected, HRESULT ", result);
      return call(descriptor);
    }
    if (SUCCEEDED(result) && (replacement.changed || inherited) && output && *output && created) {
      // Query the returned interface so every requested IID has the same key.
      Microsoft::WRL::ComPtr<ID3D12StateObject> state;
      if (SUCCEEDED(static_cast<IUnknown*>(*output)->QueryInterface(IID_PPV_ARGS(&state)))) created(device, state.Get());
    }
    return result;
  } catch (const std::exception& error) {
    renodx::utils::log::e("HartapfelFX native ray adapter: ", error.what());
    return call(descriptor);
  }
}
inline HRESULT STDMETHODCALLTYPE CreateState(ID3D12Device5* native_device, const D3D12_STATE_OBJECT_DESC* descriptor, REFIID iid, void** output) {
  Create original;
  api::device* device = nullptr;
  {
    std::lock_guard lock(mutex);
    original = reinterpret_cast<Create>(hooks::Original((*reinterpret_cast<void***>(native_device))[62]));
    if (const auto found = devices.find(native_device); found != devices.end()) device = found->second;
  }
  return Invoke(device, descriptor, nullptr, iid, output, [&](const auto* state) { return original(native_device, state, iid, output); });
}
inline HRESULT STDMETHODCALLTYPE AddState(ID3D12Device7* native_device, const D3D12_STATE_OBJECT_DESC* descriptor, ID3D12StateObject* existing, REFIID iid, void** output) {
  Add original;
  api::device* device = nullptr;
  {
    std::lock_guard lock(mutex);
    original = reinterpret_cast<Add>(hooks::Original((*reinterpret_cast<void***>(native_device))[66]));
    if (const auto found = devices.find(native_device); found != devices.end()) device = found->second;
  }
  return Invoke(device, descriptor, existing, iid, output, [&](const auto* state) { return original(native_device, state, existing, iid, output); });
}
inline void Attach(api::device* device) {
  Microsoft::WRL::ComPtr<ID3D12Device5> native5;
  auto* native_device = reinterpret_cast<ID3D12Device*>(device->get_native());
  D3D12_FEATURE_DATA_D3D12_OPTIONS5 options{};
  if (FAILED(native_device->CheckFeatureSupport(D3D12_FEATURE_D3D12_OPTIONS5, &options, sizeof(options)))
      || options.RaytracingTier == D3D12_RAYTRACING_TIER_NOT_SUPPORTED) return;
  if (FAILED(native_device->QueryInterface(IID_PPV_ARGS(&native5)))) return;
  Microsoft::WRL::ComPtr<ID3D12Device7> native7;
  native_device->QueryInterface(IID_PPV_ARGS(&native7));
  if (native7 && (*reinterpret_cast<void***>(native5.Get()))[62] == (*reinterpret_cast<void***>(native7.Get()))[66]) return;
  std::lock_guard lock(mutex);
  devices[native5.Get()] = device;
  // Stable COM ABI slots from ID3D12Device5/7 in the Windows SDK.
  hooks::Attach((*reinterpret_cast<void***>(native5.Get()))[62], reinterpret_cast<void*>(&CreateState));
  if (native7) {
    devices[native7.Get()] = device;
    hooks::Attach((*reinterpret_cast<void***>(native7.Get()))[66], reinterpret_cast<void*>(&AddState));
  }
}
inline void RemoveDevice(api::device* device) {
  std::lock_guard lock(mutex);
  std::erase_if(devices, [device](const auto& entry) { return entry.second == device; });
}
inline void Detach() {
  std::lock_guard lock(mutex);
  devices.clear();
}
}  // namespace hartapfelfx::clouds::ray_hooks
