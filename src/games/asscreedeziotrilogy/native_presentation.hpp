/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <d3d9.h>
#include <wrl/client.h>

#include <mutex>
#include <unordered_map>
#include <unordered_set>

#include "../../utils/device_proxy.hpp"

namespace ac2::native_presentation {

// ReShade's present event cannot cancel the native Present that follows it.
// Replace only Present slots: D3D9 also uses private entries beyond its public
// COM interface. Keep those tables intact and leave ReShade's wrapper running.
struct Hook {
  void* original = nullptr;
  void* replacement = nullptr;
  std::unordered_set<void*> owners;
  bool installed = false;
};
inline std::mutex mutex;
inline std::unordered_map<void**, Hook> hooks;
inline std::unordered_map<void*, uint32_t> sync_intervals;
inline thread_local IDirect3DDevice9* presented_device = nullptr;
inline thread_local IDirect3DSwapChain9* presented_swapchain = nullptr;

template <typename Function>
Function Original(void* object, size_t slot) {
  const std::lock_guard lock(mutex);
  return reinterpret_cast<Function>(hooks.at(*reinterpret_cast<void***>(object) + slot).original);
}

inline bool ConsumePresent(void* object) {
  if (object != presented_device && object != presented_swapchain) return false;
  presented_device = nullptr;
  presented_swapchain = nullptr;
  return true;
}

inline HRESULT STDMETHODCALLTYPE Present(IDirect3DDevice9* device, const RECT* source, const RECT* dest,
                                         HWND window, const RGNDATA* dirty) {
  if (ConsumePresent(device)) return device->TestCooperativeLevel();
  return Original<decltype(&Present)>(device, 17)(device, source, dest, window, dirty);
}

inline HRESULT STDMETHODCALLTYPE PresentEx(IDirect3DDevice9Ex* device, const RECT* source, const RECT* dest,
                                           HWND window, const RGNDATA* dirty, DWORD flags) {
  if (ConsumePresent(device)) return device->TestCooperativeLevel();
  return Original<decltype(&PresentEx)>(device, 121)(device, source, dest, window, dirty, flags);
}

inline HRESULT STDMETHODCALLTYPE PresentSwapchain(IDirect3DSwapChain9* swapchain, const RECT* source, const RECT* dest,
                                                  HWND window, const RGNDATA* dirty, DWORD flags) {
  if (ConsumePresent(swapchain)) {
    Microsoft::WRL::ComPtr<IDirect3DDevice9> device;
    const HRESULT result = swapchain->GetDevice(&device);
    return SUCCEEDED(result) ? device->TestCooperativeLevel() : result;
  }
  return Original<decltype(&PresentSwapchain)>(swapchain, 3)(swapchain, source, dest, window, dirty, flags);
}

inline bool Install(void* object, size_t index, void* replacement) {
  const std::lock_guard lock(mutex);
  auto** address = *reinterpret_cast<void***>(object) + index;
  auto& hook = hooks[address];
  if (hook.installed) {
    hook.owners.insert(object);
    return true;
  }
  DWORD protection;
  if (!VirtualProtect(address, sizeof(void*), PAGE_READWRITE, &protection)) return false;
  hook.original = *address;
  hook.replacement = replacement;
  hook.owners.insert(object);
  hook.installed = true;
  InterlockedExchangePointer(reinterpret_cast<void* volatile*>(address), replacement);
  DWORD ignored;
  VirtualProtect(address, sizeof(void*), protection, &ignored);
  if (index == 17) {
    reshade::log::message(reshade::log::level::info, "Ezio: successful HDR proxy frames suppress the duplicate native DX9 Present.");
  }
  return true;
}

// Device tables may live inside the device allocation; restore them before
// destruction. Swapchain slots may instead be shared between several objects.
inline void Uninstall(void* object = nullptr) {
  const std::lock_guard lock(mutex);
  for (auto& [address, hook] : hooks) {
    if (!hook.installed) continue;
    if (object != nullptr && (hook.owners.erase(object) == 0 || !hook.owners.empty())) continue;
    DWORD protection;
    if (!VirtualProtect(address, sizeof(void*), PAGE_READWRITE, &protection)) continue;
    InterlockedCompareExchangePointer(reinterpret_cast<void* volatile*>(address), hook.original, hook.replacement);
    DWORD ignored;
    VirtualProtect(address, sizeof(void*), protection, &ignored);
    hook.installed = false;
    hook.owners.clear();
    // Retain the original for calls already entering this hook on another thread.
  }
}

inline void OnProxyPresent(reshade::api::swapchain* swapchain, HRESULT result) {
  if (swapchain->get_device()->get_api() != reshade::api::device_api::d3d9 || FAILED(result)) return;
  auto* device = reinterpret_cast<IDirect3DDevice9*>(swapchain->get_device()->get_native());
  auto* native_swapchain = reinterpret_cast<IDirect3DSwapChain9*>(swapchain->get_native());
  if (!Install(device, 17, reinterpret_cast<void*>(&Present))) return;
  Microsoft::WRL::ComPtr<IDirect3DDevice9Ex> device_ex;
  if (SUCCEEDED(device->QueryInterface(IID_PPV_ARGS(&device_ex)))
      && device_ex.Get() == device
      && !Install(device, 121, reinterpret_cast<void*>(&PresentEx))) return;
  if (!Install(native_swapchain, 3, reinterpret_cast<void*>(&PresentSwapchain))) return;
  // Only a completed proxy frame permits skipping this native presentation.
  // Other devices and unsuccessful/skipped proxy frames retain their Present.
  presented_device = device;
  presented_swapchain = native_swapchain;
}

inline void OnFinishPresent(reshade::api::command_queue*, reshade::api::swapchain* swapchain) {
  if (swapchain->get_device()->get_api() != reshade::api::device_api::d3d9) return;
  presented_device = nullptr;
  presented_swapchain = nullptr;
}

inline void OnBeginPresent(reshade::api::command_queue* queue, reshade::api::swapchain* swapchain,
                           const reshade::api::rect*, const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  OnFinishPresent(queue, swapchain);
}

inline void OnDestroySwapchain(reshade::api::swapchain* swapchain, bool) {
  if (swapchain->get_device()->get_api() != reshade::api::device_api::d3d9) return;
  OnFinishPresent(nullptr, swapchain);
  Uninstall(reinterpret_cast<void*>(swapchain->get_native()));
  // Reset can replace the device's Present dispatch entries, too.
  Uninstall(reinterpret_cast<void*>(swapchain->get_device()->get_native()));
}

inline void OnDestroyDevice(reshade::api::device* device) {
  if (device->get_api() == reshade::api::device_api::d3d9) Uninstall(reinterpret_cast<void*>(device->get_native()));
}

inline bool OnCreateSwapchain(reshade::api::device_api api, reshade::api::swapchain_desc& desc, void* window) {
  const std::lock_guard lock(mutex);
  if (api == reshade::api::device_api::d3d9) {
    // Capture the request before the native driver/overlays can alter it.
    sync_intervals[window] = desc.sync_interval <= 4 ? desc.sync_interval : 1;
  } else if (api == reshade::api::device_api::d3d11
             && renodx::utils::device_proxy::IsCreatingProxySwapchain()) {
    if (const auto found = sync_intervals.find(window); found != sync_intervals.end()) {
      desc.sync_interval = found->second;
      return true;
    }
  }
  return false;
}

inline void Use(DWORD reason) {
  if (reason == DLL_PROCESS_ATTACH) {
    renodx::utils::device_proxy::allow_tearing = false;
    // DX9 shared textures have no keyed mutex. Complete the producer write and
    // consumer copy before transferring ownership to the other device.
    renodx::utils::device_proxy::device_proxy_wait_idle_source = true;
    renodx::utils::device_proxy::device_proxy_wait_idle_destination = true;
    renodx::utils::device_proxy::on_proxy_present = &OnProxyPresent;
    // Register before device_proxy::Use so old tokens clear before its Present.
    reshade::register_event<reshade::addon_event::present>(OnBeginPresent);
    reshade::register_event<reshade::addon_event::finish_present>(OnFinishPresent);
    reshade::register_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::register_event<reshade::addon_event::create_swapchain>(OnCreateSwapchain);
  } else if (reason == DLL_PROCESS_DETACH) {
    renodx::utils::device_proxy::on_proxy_present = nullptr;
    reshade::unregister_event<reshade::addon_event::present>(OnBeginPresent);
    reshade::unregister_event<reshade::addon_event::finish_present>(OnFinishPresent);
    reshade::unregister_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::unregister_event<reshade::addon_event::create_swapchain>(OnCreateSwapchain);
    Uninstall();
  }
}

}  // namespace ac2::native_presentation
