/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once

#include <algorithm>
#include <sstream>
#include <include/reshade.hpp>
#include "../../utils/device_upgrade.hpp"
#include "./native_draw.hpp"

namespace acbrotherhood::native_device {
inline Microsoft::WRL::ComPtr<IDirect3D9Ex> factory;
inline std::mutex initialization_mutex;
// D3D9 resource vtables belong to the runtime, not the individual resource.
// Install once per table and leave it protected until addon unload, including
// when only untracked overlay textures remain. Never retain default-pool
// textures here: retaining them would prevent an ordinary device Reset.
inline std::unordered_set<void**> texture_vtables;

inline bool OnCreateResource(reshade::api::device* device, reshade::api::resource_desc& desc,
                             reshade::api::subresource_data*, reshade::api::resource_usage) {
  if (device->get_api() != reshade::api::device_api::d3d9
      || desc.type != reshade::api::resource_type::texture_2d || desc.texture.levels != 1
      || desc.texture.width == 0 || desc.texture.height == 0
      || (desc.texture.width >= 4 && desc.texture.height >= 4)) return false;
  switch (desc.texture.format) {
    case reshade::api::format::bc1_unorm:
    case reshade::api::format::bc2_unorm:
    case reshade::api::format::bc3_unorm: break;
    default: return false;
  }
  // AC2 ignores a failed 2x16 DXT5 CreateTexture during loading and calls
  // AddRef on null. Its upload already contains complete compression blocks.
  // Keep this native compatibility fix independent of the optional HDR addon;
  // if that addon padded the same request first, the guard above is a no-op.
  std::ostringstream message;
  message << "AC2: padding sub-block DX9 texture " << desc.texture.width << 'x' << desc.texture.height;
  desc.texture.width = std::max(4u, desc.texture.width);
  desc.texture.height = std::max(4u, desc.texture.height);
  message << " to " << desc.texture.width << 'x' << desc.texture.height;
  reshade::log::message(reshade::log::level::info, message.str().c_str());
  return true;
}

inline HRESULT STDMETHODCALLTYPE LockTexture(IDirect3DTexture9* texture, UINT level,
                                            D3DLOCKED_RECT* locked, const RECT* rect, DWORD flags) {
  Microsoft::WRL::ComPtr<IDirect3DSurface9> surface;
  const HRESULT result = texture->GetSurfaceLevel(level, &surface);
  if (FAILED(result)) return result;
  // ReShade's texture hook calls its surface hook directly. An untracked
  // texture (e.g. RTSS's overlay) can share the texture vtable yet have a
  // surface vtable with no registered ReShade trampoline, causing a null call.
  // Virtual dispatch uses either that surface's native method or its installed
  // hook. Tracked resources still emit ReShade's mapping callbacks normally.
  return surface->LockRect(locked, rect, flags);
}

inline HRESULT STDMETHODCALLTYPE UnlockTexture(IDirect3DTexture9* texture, UINT level) {
  Microsoft::WRL::ComPtr<IDirect3DSurface9> surface;
  const HRESULT result = texture->GetSurfaceLevel(level, &surface);
  if (FAILED(result)) return result;
  return surface->UnlockRect();
}

inline void OnInitResource(reshade::api::device* device, const reshade::api::resource_desc& desc,
                           const reshade::api::subresource_data*, reshade::api::resource_usage,
                           reshade::api::resource resource) {
  if (device->get_api() != reshade::api::device_api::d3d9 || desc.type != reshade::api::resource_type::texture_2d) return;
  auto* texture = reinterpret_cast<IDirect3DTexture9*>(resource.handle);
  if (texture->GetType() != D3DRTYPE_TEXTURE) return;
  const std::lock_guard lock(initialization_mutex);
  auto** vtable = *reinterpret_cast<void***>(texture);
  if (texture_vtables.contains(vtable)) return;
  // init_resource runs after ReShade installs its texture and surface hooks.
  if (native_draw::Install(texture, 19, reinterpret_cast<void*>(&LockTexture), &texture_vtables)
      && native_draw::Install(texture, 20, reinterpret_cast<void*>(&UnlockTexture), &texture_vtables)) {
    texture_vtables.insert(vtable);
    reshade::log::message(reshade::log::level::info, "Brotherhood TAA: native texture-lock compatibility installed.");
  }
}

inline HRESULT STDMETHODCALLTYPE CreateDeviceEx(IDirect3D9Ex* api, UINT adapter, D3DDEVTYPE type,
                                                HWND window, DWORD behavior, D3DPRESENT_PARAMETERS* parameters,
                                                D3DDISPLAYMODEEX* fullscreen, IDirect3DDevice9Ex** device) {
  D3DDISPLAYMODEEX mode{sizeof(D3DDISPLAYMODEEX)};
  // ReShade's ordinary DX9 -> DX9Ex upgrade passes a null fullscreen descriptor.
  // Native DX9Ex requires it in exclusive fullscreen. HDR's windowed proxy hid
  // this startup failure. Supply only the missing descriptor; preserve the
  // requested dimensions, refresh, format, MSAA and presentation interval.
  if (parameters && !parameters->Windowed && !fullscreen && !(behavior & D3DCREATE_ADAPTERGROUP_DEVICE)) {
    mode.Width = parameters->BackBufferWidth;
    mode.Height = parameters->BackBufferHeight;
    mode.RefreshRate = parameters->FullScreen_RefreshRateInHz;
    mode.Format = parameters->BackBufferFormat;
    fullscreen = &mode;
    reshade::log::message(reshade::log::level::info, "Brotherhood TAA: supplied missing DX9Ex fullscreen display mode.");
  }
  return native_draw::Original<decltype(&CreateDeviceEx)>(api, 20)(api, adapter, type, window, behavior, parameters, fullscreen, device);
}

inline bool OnCreateDevice(reshade::api::device_api api, uint32_t&) {
  if (api != reshade::api::device_api::d3d9 || !renodx::utils::device_upgrade::use_dx9ex_upgrade) return false;
  const std::lock_guard lock(initialization_mutex);
  if (factory) return false;
  // Run after DllMain, before ReShade enters the DX9 runtime for device creation.
  // Keep one factory alive so its shared vtable remains valid until unhooked.
  const auto create = reinterpret_cast<HRESULT(WINAPI*)(UINT, IDirect3D9Ex**)>(
      GetProcAddress(GetModuleHandleW(L"d3d9.dll"), "Direct3DCreate9Ex"));
  if (!create || FAILED(create(D3D_SDK_VERSION, &factory))) return false;
  if (!native_draw::Install(factory.Get(), 20, reinterpret_cast<void*>(&CreateDeviceEx))) {
    factory.Reset();
    reshade::log::message(reshade::log::level::warning, "Brotherhood TAA: could not install DX9Ex fullscreen compatibility hook.");
  }
  return false;  // The shared device-upgrade utility owns the API request.
}

inline void Use(DWORD reason) {
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::create_device>(OnCreateDevice);
    reshade::register_event<reshade::addon_event::create_resource>(OnCreateResource);
    reshade::register_event<reshade::addon_event::init_resource>(OnInitResource);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::create_device>(OnCreateDevice);
    reshade::unregister_event<reshade::addon_event::create_resource>(OnCreateResource);
    reshade::unregister_event<reshade::addon_event::init_resource>(OnInitResource);
    native_draw::Uninstall(&texture_vtables);
    texture_vtables.clear();
    if (factory) native_draw::Uninstall(factory.Get());
    factory.Reset();
  }
}
}  // namespace acbrotherhood::native_device
