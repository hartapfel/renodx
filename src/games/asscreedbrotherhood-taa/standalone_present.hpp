/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include "../../utils/windowing.hpp"
#include "./presentation.hpp"

namespace acbrotherhood::presentation::standalone {
// Reuse the addon's dispatch hooks without enabling HDR resource upgrades.
namespace hooks = native_draw;
struct Output {
  std::shared_ptr<Session> session;
  IDirect3DDevice9* native = nullptr;
  ComPtr<IDirect3DTexture9> shared;
  ComPtr<IDirect3DSurface9> surface;
  ComPtr<IDirect3DQuery9> complete;
  ComPtr<ID3D11Device> bridge;
  ComPtr<ID3D11Texture2D> source;
  HWND window = nullptr;
  uint32_t sync = 0;
  bool initialized = false;
  bool borderless_pending = false;
};
inline std::unordered_map<IDirect3DSwapChain9*, std::shared_ptr<Output>> outputs;
struct WindowRequest { uint32_t sync = 0; bool fullscreen = false; };
inline std::unordered_map<HWND, WindowRequest> requested_windows;
inline bool selected = false, checked = false;

inline bool Select() {
  if (checked) return selected;
  checked = true;
  std::wstring path(32768, L'\0');
  if (!GetModuleFileNameW(addon_module, path.data(), DWORD(path.size()))
      || !std::filesystem::exists(std::filesystem::path(path.c_str()).parent_path()
          / L"renodx-asscreedbrotherhood-dx12" / L"renodx-asscreedbrotherhood-dx12.exe")) return false;
  dlaa::Handle snapshot(CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, GetCurrentProcessId()));
  if (snapshot.value == INVALID_HANDLE_VALUE) { snapshot.value = nullptr; return false; }
  MODULEENTRY32W entry{sizeof(entry)};
  if (!Module32FirstW(snapshot.value, &entry)) return false;
  do {
    if (GetProcAddress(entry.hModule, "RenodxEzioReadOutputParameters")) return false;
  } while (Module32NextW(snapshot.value, &entry));
  return selected = true;
}

inline bool TryPresent(IDirect3DDevice9* device, IDirect3DSwapChain9* swapchain,
                       const RECT* source_rect, const RECT* destination_rect, HWND override_window,
                       const RGNDATA* dirty, DWORD flags, HRESULT* result) {
  const std::lock_guard lock(mutex);
  auto found = outputs.find(swapchain);
  if (found == outputs.end()) return false;
  const auto output = found->second;
  const auto session = output->session;
  if (retry_requested.exchange(false)) { session->failed = false; session->client.reset(); }
  frame_generation::output_enabled = !session->failed;
  // Partial/alternate-window presents are not full game frames.
  if (source_rect || destination_rect || dirty || (override_window && override_window != output->window)
      || (flags & (D3DPRESENT_DONOTWAIT | D3DPRESENT_FORCEIMMEDIATE))) return false;
  if (session->failed || !output->initialized || output->borderless_pending) return false;
  if (FAILED(device->TestCooperativeLevel())) return false;
  try {
    ComPtr<IDirect3DSurface9> backbuffer;
    Check(swapchain->GetBackBuffer(0, D3DBACKBUFFER_TYPE_MONO, &backbuffer), Stage::copy);
    D3DSURFACE_DESC desc{}; Check(backbuffer->GetDesc(&desc), Stage::copy);
    if (desc.Format != D3DFMT_X8R8G8B8 && desc.Format != D3DFMT_A8R8G8B8)
      throw Failure{Stage::copy, ERROR_NOT_SUPPORTED};
    if (!output->shared) {
      HANDLE handle = nullptr;
      Check(device->CreateTexture(desc.Width, desc.Height, 1, D3DUSAGE_RENDERTARGET,
          D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, &output->shared, &handle), Stage::sharing);
      Check(output->shared->GetSurfaceLevel(0, &output->surface), Stage::sharing);
      Check(device->CreateQuery(D3DQUERYTYPE_EVENT, &output->complete), Stage::device);
      // Match the game's adapter; never silently copy across GPUs.
      ComPtr<IDirect3D9> factory9;
      ComPtr<IDirect3D9Ex> factory9ex;
      D3DDEVICE_CREATION_PARAMETERS creation{};
      Check(device->GetDirect3D(&factory9), Stage::adapter);
      Check(factory9.As(&factory9ex), Stage::adapter);
      Check(device->GetCreationParameters(&creation), Stage::adapter);
      LUID luid{}; Check(factory9ex->GetAdapterLUID(creation.AdapterOrdinal, &luid), Stage::adapter);
      ComPtr<IDXGIFactory4> factory;
      static const auto create_factory = reinterpret_cast<decltype(&CreateDXGIFactory1)>(GetProcAddress(LoadLibraryW(L"dxgi.dll"), "CreateDXGIFactory1"));
      static const auto create_device = reinterpret_cast<decltype(&D3D11CreateDevice)>(GetProcAddress(LoadLibraryW(L"d3d11.dll"), "D3D11CreateDevice"));
      if (!create_factory || !create_device) throw Failure{Stage::device, ERROR_PROC_NOT_FOUND};
      Check(create_factory(IID_PPV_ARGS(&factory)), Stage::adapter);
      ComPtr<IDXGIAdapter> adapter;
      Check(factory->EnumAdapterByLuid(luid, IID_PPV_ARGS(&adapter)), Stage::adapter);
      Check(create_device(adapter.Get(), D3D_DRIVER_TYPE_UNKNOWN, nullptr, 0, nullptr, 0,
          D3D11_SDK_VERSION, &output->bridge, nullptr, nullptr), Stage::device);
      Check(output->bridge->OpenSharedResource(handle, IID_PPV_ARGS(&output->source)), Stage::sharing);
    }
    // This hook runs after ReShade's EndScene, including its overlay. Resolve
    // MSAA/copy native SDR pixels without changing any game render target.
    Check(device->StretchRect(backbuffer.Get(), nullptr, output->surface.Get(), nullptr, D3DTEXF_NONE), Stage::copy);
    Check(output->complete->Issue(D3DISSUE_END), Stage::gpu_wait);
    const auto deadline = GetTickCount64() + 2000;
    for (;;) {
      const HRESULT ready = output->complete->GetData(nullptr, 0, D3DGETDATA_FLUSH);
      if (ready == S_OK) break;
      Check(ready, Stage::gpu_wait);
      if (GetTickCount64() > deadline) throw Failure{Stage::gpu_wait, WAIT_TIMEOUT};
      SwitchToThread();
    }
    D3D11_TEXTURE2D_DESC source{}; output->source->GetDesc(&source);
    if (!PresentFrame(session, output->bridge.Get(), output->source.Get(), source, output->window,
          DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709, output->sync, 0, result)) return false;
    // PresentFrame waits for all consumers before this shared source is reused.
    return true;
  } catch (const Failure& failure) {
    error_stage = uint32_t(failure.stage); error_code = failure.code;
  } catch (...) { error_stage = uint32_t(Stage::protocol); error_code = ERROR_UNHANDLED_EXCEPTION; }
  return Fail(session);
}

inline HRESULT STDMETHODCALLTYPE PresentDevice(IDirect3DDevice9* device, const RECT* source, const RECT* dest, HWND window, const RGNDATA* dirty) {
  ComPtr<IDirect3DSwapChain9> chain; HRESULT result;
  if (SUCCEEDED(device->GetSwapChain(0, &chain)) && TryPresent(device, chain.Get(), source, dest, window, dirty, 0, &result)) return result;
  result = hooks::Original<decltype(&PresentDevice)>(device, 17)(device, source, dest, window, dirty);
  if (result == S_OK) { const std::lock_guard lock(mutex); if (auto it = outputs.find(chain.Get()); it != outputs.end()) it->second->initialized = IsWindowVisible(it->second->window) && !IsIconic(it->second->window); }
  return result;
}
inline HRESULT STDMETHODCALLTYPE PresentDeviceEx(IDirect3DDevice9Ex* device, const RECT* source, const RECT* dest, HWND window, const RGNDATA* dirty, DWORD flags) {
  ComPtr<IDirect3DSwapChain9> chain; HRESULT result;
  if (SUCCEEDED(device->GetSwapChain(0, &chain)) && TryPresent(device, chain.Get(), source, dest, window, dirty, flags, &result)) return result;
  result = hooks::Original<decltype(&PresentDeviceEx)>(device, 121)(device, source, dest, window, dirty, flags);
  if (result == S_OK) { const std::lock_guard lock(mutex); if (auto it = outputs.find(chain.Get()); it != outputs.end()) it->second->initialized = IsWindowVisible(it->second->window) && !IsIconic(it->second->window); }
  return result;
}
inline HRESULT STDMETHODCALLTYPE PresentSwapchain(IDirect3DSwapChain9* chain, const RECT* source, const RECT* dest, HWND window, const RGNDATA* dirty, DWORD flags) {
  ComPtr<IDirect3DDevice9> device; HRESULT result;
  if (SUCCEEDED(chain->GetDevice(&device)) && TryPresent(device.Get(), chain, source, dest, window, dirty, flags, &result)) return result;
  result = hooks::Original<decltype(&PresentSwapchain)>(chain, 3)(chain, source, dest, window, dirty, flags);
  if (result == S_OK) { const std::lock_guard lock(mutex); if (auto it = outputs.find(chain); it != outputs.end()) it->second->initialized = IsWindowVisible(it->second->window) && !IsIconic(it->second->window); }
  return result;
}
inline void OnPresent(reshade::api::command_queue*, reshade::api::swapchain* swapchain,
                      const reshade::api::rect*, const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  if (swapchain->get_device()->get_api() != reshade::api::device_api::d3d9) return;
  const std::lock_guard lock(mutex);
  auto* chain = reinterpret_cast<IDirect3DSwapChain9*>(swapchain->get_native());
  const auto found = outputs.find(chain);
  if (found == outputs.end()) return;
  const auto output = found->second; // A window resize may synchronously reset the swapchain.
  auto* device = output->native;
  // Re-arm known slots each frame: driver dispatch can refresh after Reset.
  hooks::Install(device, 17, reinterpret_cast<void*>(&PresentDevice));
  ComPtr<IDirect3DDevice9Ex> ex;
  if (SUCCEEDED(device->QueryInterface(IID_PPV_ARGS(&ex))) && ex.Get() == device)
    hooks::Install(device, 121, reinterpret_cast<void*>(&PresentDeviceEx));
  hooks::Install(chain, 3, reinterpret_cast<void*>(&PresentSwapchain));
  if (output->borderless_pending && renodx::utils::windowing::CanApplyFakeFullscreen(output->window)) {
    // Forcing DX9 windowed skips the runtime's fullscreen HWND sizing. AC's
    // startup HWND is tiny until that happens. Size it before the DX12 handoff,
    // including after resets, without stealing focus from another application.
    struct Dpi { DPI_AWARENESS_CONTEXT previous; ~Dpi() { SetThreadDpiAwarenessContext(previous); } }
        dpi{SetThreadDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)};
    RECT monitor{};
    if (renodx::utils::windowing::GetMonitorRect(output->window, &monitor)) {
      output->borderless_pending = false;
      if (!renodx::utils::windowing::ApplyFakeFullscreen(output->window,
          monitor.right - monitor.left, monitor.bottom - monitor.top)) output->borderless_pending = true;
      else reshade::log::message(reshade::log::level::info, "Brotherhood DX12: standalone borderless window restored.");
    }
  }
}
inline bool OnCreateSwapchain(reshade::api::device_api api, reshade::api::swapchain_desc& desc, void* window) {
  if (api != reshade::api::device_api::d3d9 || !Select()) return false;
  requested_windows[static_cast<HWND>(window)] = {desc.sync_interval <= 4 ? desc.sync_interval : 1, desc.fullscreen_state};
  // The helper owns a child flip-model surface; exclusive DX9 cannot own the
  // same display concurrently. This changes presentation only, never formats.
  desc.fullscreen_state = false;
  return true;
}
inline void OnInitSwapchain(reshade::api::swapchain* swapchain, bool) {
  if (swapchain->get_device()->get_api() != reshade::api::device_api::d3d9 || !Select()) return;
  const std::lock_guard lock(mutex);
  auto output = std::make_shared<Output>();
  output->session = std::make_shared<Session>(); output->session->api = swapchain;
  output->native = reinterpret_cast<IDirect3DDevice9*>(swapchain->get_device()->get_native());
  output->window = static_cast<HWND>(swapchain->get_hwnd());
  output->sync = requested_windows[output->window].sync;
  output->borderless_pending = requested_windows[output->window].fullscreen;
  auto* chain = reinterpret_cast<IDirect3DSwapChain9*>(swapchain->get_native());
  sessions[chain] = output->session; outputs[chain] = std::move(output);
  frame_generation::output_enabled = true;
}
inline void OnDestroySwapchain(reshade::api::swapchain* swapchain, bool) {
  if (swapchain->get_device()->get_api() != reshade::api::device_api::d3d9) return;
  const std::lock_guard lock(mutex);
  auto* chain = reinterpret_cast<IDirect3DSwapChain9*>(swapchain->get_native());
  const auto found = outputs.find(chain); if (found == outputs.end()) return;
  found->second->session->retired = true; found->second->session->client.reset();
  hooks::Uninstall(found->second->native); hooks::Uninstall(chain);
  sessions.erase(chain); outputs.erase(found);
  frame_generation::output_enabled = false; status = Status::waiting;
}
inline void Use(DWORD reason, bool process_terminating = false) {
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::create_swapchain>(OnCreateSwapchain);
    reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
    reshade::register_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
    reshade::register_event<reshade::addon_event::present>(OnPresent);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::create_swapchain>(OnCreateSwapchain);
    reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
    reshade::unregister_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
    reshade::unregister_event<reshade::addon_event::present>(OnPresent);
    hooks::Uninstall();
    // ExitProcess already terminated driver worker threads. Releasing shared
    // GPU surfaces under the loader lock can deadlock waiting for those threads.
    // Normal Reset/unload still destroys everything through the paths above;
    // at process termination let Windows reclaim these objects and job handles.
    if (process_terminating && !outputs.empty()) new decltype(outputs)(std::move(outputs));
    else {
      for (auto& [chain, output] : outputs) output->session->client.reset();
      outputs.clear();
    }
  }
}
}
