/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <detours.h>
#include <tlhelp32.h>
#include <windows.h>
#include <mutex>
#include "./runtime.hpp"
#if __has_include("../../../../bin/streamline-2.14.16/include/sl.h")
#include "./camera.hpp"
#include "./engine.hpp"
#include "./swapchain.hpp"

namespace witcher3classic::frame_generation {
// Loading SL or creating D3D devices under DllMain is explicitly forbidden.
inline const ShaderInjectData* output_constants = nullptr;
namespace factory {
using Legacy = HRESULT(STDMETHODCALLTYPE*)(IDXGIFactory*, IUnknown*, DXGI_SWAP_CHAIN_DESC*, IDXGISwapChain**);
using ForHwnd = HRESULT(STDMETHODCALLTYPE*)(IDXGIFactory2*, IUnknown*, HWND, const DXGI_SWAP_CHAIN_DESC1*,
                                            const DXGI_SWAP_CHAIN_FULLSCREEN_DESC*, IDXGIOutput*, IDXGISwapChain1**);
struct State {
  std::mutex mutex;
  Legacy legacy = nullptr;
  ForHwnd hwnd = nullptr;
  reshade::api::device* reshade_device = nullptr;
  ID3D11Device* native_device = nullptr;
  bool installed = false;
};
inline State* state = new State;
inline thread_local bool creating = false;

inline HRESULT Create(IDXGIFactory* factory, IUnknown* device, const DXGI_SWAP_CHAIN_DESC& desc, IDXGISwapChain** out) {
  if (creating || !out || presentation_device || !desc.Windowed
      || desc.BufferDesc.Format != DXGI_FORMAT_R10G10B10A2_UNORM) return DXGI_ERROR_UNSUPPORTED;
  wchar_t window_class[32] = {};
  if (!GetClassNameW(desc.OutputWindow, window_class, 32) || std::wcscmp(window_class, L"W2ViewportClass")) return DXGI_ERROR_UNSUPPORTED;
  ComPtr<ID3D11Device> d11;
  ComPtr<IDXGIFactory2> factory2;
  if (FAILED(device->QueryInterface(IID_PPV_ARGS(&d11))) || d11.Get() != state->native_device
      || FAILED(factory->QueryInterface(IID_PPV_ARGS(&factory2)))) return DXGI_ERROR_UNSUPPORTED;
  wchar_t executable[32768] = {};
  if (!GetModuleFileNameW(nullptr, executable, UINT(std::size(executable)))) return E_FAIL;
  const auto directory = std::filesystem::path(executable).parent_path();
  // Deployment keeps the signed FG runtime in its own directory, beside the
  // game. Never replace DX11 SR's nvngx_dlss.dll or another mod's interposer.
  const auto plugins = directory / L"renodx-frame-generation";
  if (!std::filesystem::exists(plugins / L"sl.interposer.dll")) {
    status = "Frame Generation runtime is not installed";
    return DXGI_ERROR_UNSUPPORTED;
  }
  std::error_code ec;
  std::filesystem::create_directories(directory / L"renodx-frame-generation-logs", ec);
  if (ec) return E_FAIL;
  creating = true;
  ComPtr<Swapchain> replacement;
  replacement.Attach(new Swapchain);
  const HRESULT hr = replacement->Initialize(d11.Get(), factory2.Get(), desc, plugins, directory / L"renodx-frame-generation-logs");
  creating = false;
  if (FAILED(hr)) {
    status = "Frame Generation initialization failed; see ReShade/Streamline logs";
    reshade::log::message(reshade::log::level::warning,
                          std::format("Classic FG: {} failed (HRESULT {:08X}, SL {}). Restoring native DX11 creation.",
                                      replacement->presenter.stage, uint32_t(hr), uint32_t(replacement->presenter.Streamline().result))
                              .c_str());
    return hr;  // replacement releases HWND ownership before the native retry.
  }
  if (!engine::Attach(&replacement->presenter.Streamline())) {
    status = "NVIDIA Reflex initialization failed";
    return DXGI_ERROR_UNSUPPORTED;
  }
  presentation_device = d11.Get();
  max_multiplier = replacement->presenter.Streamline().capabilities.max_generated + 1;
  dynamic_supported = replacement->presenter.Streamline().capabilities.dynamic;
  replacement->on_destroy = [] { engine::Detach(); presentation_device = nullptr; transport_active = false; };
  transport_active = true;
  status = mode == 0.f ? "Off" : "Waiting for a complete gameplay frame";
  replacement->capture = [](Presenter::Inputs* inputs, Request* request) {
    *request = {static_cast<Mode>(static_cast<uint32_t>(std::clamp(mode, 0.f, 3.f))),
                static_cast<uint32_t>(std::clamp(multiplier, 2.f, 6.f)), std::clamp(target_fps, 0.f, 1000.f), hud_quality != 0.f};
    inputs->token = engine::FinishRender();
    inputs->readiness.reflex_active = inputs->token != nullptr;
    inputs->readiness.transitioning = overlay_open || effects_active;
    inputs->readiness.runtime_ok = true;
    // Keep presentation and Reflex alive for live enabling, but do not encode
    // or submit stale auxiliary inputs while interpolation is explicitly Off.
    if (request->mode == Mode::Off) return;
    auto* data = renodx::utils::data::Get<temporal::DeviceData>(state->reshade_device);
    auto* captured = renodx::utils::data::Get<CaptureData>(state->reshade_device);
    if (!data || !captured || !output_constants || !data->motion_context
        || data->last_resolve == UINT64_MAX || data->last_resolve + 1 != data->frame
        || captured->capture.frame != data->last_resolve) return;
    inputs->textures[Interop::Depth] = data->prepare.textures[1].Get();
    inputs->textures[Interop::Motion] = data->prepare.textures[2].Get();
    D3D11_TEXTURE2D_DESC render{};
    inputs->textures[Interop::Depth]->GetDesc(&render);
    static sl::Constants camera;
    static uint64_t previous_frame = UINT64_MAX;
    const auto previous_position = camera.cameraPos;
    const auto previous_forward = camera.cameraFwd;
    if (captured->camera_valid && BuildCamera(captured->native_camera, render.Width, render.Height, previous_frame == UINT64_MAX || previous_frame + 1 != data->last_resolve, &camera)) {
      if (previous_frame != UINT64_MAX) {
        const float dx = camera.cameraPos.x - previous_position.x, dy = camera.cameraPos.y - previous_position.y, dz = camera.cameraPos.z - previous_position.z;
        const float facing = camera.cameraFwd.x * previous_forward.x + camera.cameraFwd.y * previous_forward.y + camera.cameraFwd.z * previous_forward.z;
        if (dx * dx + dy * dy + dz * dz > 9.f || facing < .7071f) camera.reset = sl::Boolean::eTrue;
      }
      inputs->camera = &camera;
      inputs->readiness.inputs_valid = true;
      previous_frame = data->last_resolve;
    }
    if (captured->capture.Encode(data->motion_context.Get(), output_constants)) {
      inputs->textures[Interop::Hudless] = captured->capture.hudless.Get();
      inputs->textures[Interop::UIAlpha] = captured->capture.alpha_valid ? captured->capture.alpha.Get() : nullptr;
      inputs->readiness.hud_valid = true;
    }
    if (output_constants->tone_map_type == CLASSIC_TONE_MAP_PSYCHOV31 && output_constants->peak_white_nits > 0.f
        && output_constants->chromatic_aberration_mode != 0.f && output_constants->chromatic_aberration_intensity > 0.f) {
      D3D11_TEXTURE2D_DESC output{};
      data->dlss.output->GetDesc(&output);
      if (captured->distortion.Update(data->motion_context.Get(), output.Width, output.Height,
                                      output_constants->chromatic_aberration_intensity,
                                      __swap_chain_proxy_vertex_shader, __0xF3CF0001)) {
        inputs->distortion = captured->distortion.texture.Get();
        inputs->distortion_version = captured->distortion.version;
      } else inputs->readiness.inputs_valid = false;
    }
    inputs->readiness.gameplay = true;
  };
  replacement->on_present = [](const Presenter& presenter, HRESULT hr) {
    status = FAILED(hr) ? "Frame presentation failed; see ReShade/Streamline logs" : presenter.CurrentDecision().reason;
    frames_presented = presenter.State().numFramesActuallyPresented;
    static const char* previous = nullptr;
    static uint32_t previous_count = 0;
    const auto* current = status.load();
    if (previous != current || previous_count < frames_presented) {
      reshade::log::message(reshade::log::level::info,
                            std::format("Classic FG: {} (HRESULT {:08X}, runtime status {}, presented {}).", current,
                                        uint32_t(hr), uint32_t(presenter.State().status), frames_presented.load())
                                .c_str());
      previous = current;
      previous_count = std::max(previous_count, frames_presented.load());
    }
  };
  *out = replacement.Detach();
  return S_OK;
}
inline HRESULT STDMETHODCALLTYPE LegacyHook(IDXGIFactory* factory, IUnknown* device, DXGI_SWAP_CHAIN_DESC* desc, IDXGISwapChain** out) {
  if (desc && SUCCEEDED(Create(factory, device, *desc, out))) return S_OK;
  return state->legacy(factory, device, desc, out);
}
inline HRESULT STDMETHODCALLTYPE HwndHook(IDXGIFactory2* factory, IUnknown* device, HWND window, const DXGI_SWAP_CHAIN_DESC1* desc,
                                          const DXGI_SWAP_CHAIN_FULLSCREEN_DESC* fullscreen, IDXGIOutput* output, IDXGISwapChain1** out) {
  if (desc && out && !output && (!fullscreen || fullscreen->Windowed)) {
    DXGI_SWAP_CHAIN_DESC legacy{};
    legacy.BufferDesc = {desc->Width, desc->Height, {}, desc->Format};
    legacy.SampleDesc = desc->SampleDesc;
    legacy.BufferUsage = desc->BufferUsage;
    legacy.BufferCount = desc->BufferCount;
    legacy.OutputWindow = window;
    legacy.Windowed = TRUE;
    legacy.SwapEffect = desc->SwapEffect;
    legacy.Flags = desc->Flags;
    ComPtr<IDXGISwapChain> chain;
    if (SUCCEEDED(Create(factory, device, legacy, &chain))) return chain->QueryInterface(IID_PPV_ARGS(out));
  }
  return state->hwnd(factory, device, window, desc, fullscreen, output, out);
}
inline void OnInitDevice(reshade::api::device* device) {
  reshade::log::message(reshade::log::level::info, std::format("Classic FG: device initialization, requested mode {}.", mode).c_str());
  if (device->get_api() != reshade::api::device_api::d3d11) return;
  std::lock_guard lock(state->mutex);
  auto* native = reinterpret_cast<ID3D11Device*>(device->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&native);
  if (state->installed) {
    if (!state->native_device) {
      state->native_device = native;
      state->reshade_device = device;
    }
    return;
  }
  if (!engine::Verify()) {
    status = "Frame Generation requires the supported Classic 1.32 executable";
    reshade::log::message(reshade::log::level::warning, status.load());
    return;
  }
  ComPtr<IDXGIDevice> dxgi;
  ComPtr<IDXGIAdapter> adapter;
  ComPtr<IDXGIFactory2> factory;
  if (FAILED(native->QueryInterface(IID_PPV_ARGS(&dxgi))) || FAILED(dxgi->GetAdapter(&adapter))
      || FAILED(adapter->GetParent(IID_PPV_ARGS(&factory)))) return;
  auto* native_factory = factory.Get();
  renodx::utils::directx::NativeFromReShadeProxy(&native_factory);
  const auto table = *reinterpret_cast<void***>(native_factory);
  wchar_t system_directory[MAX_PATH] = {};
  GetSystemDirectoryW(system_directory, MAX_PATH);
  const auto system_dxgi = std::filesystem::path(system_directory) / L"dxgi.dll";
  for (const auto index : {10, 15}) {
    MEMORY_BASIC_INFORMATION memory{};
    wchar_t path[32768] = {};
    if (!VirtualQuery(table[index], &memory, sizeof(memory))
        || !GetModuleFileNameW(static_cast<HMODULE>(memory.AllocationBase), path, UINT(std::size(path)))
        || _wcsicmp(path, system_dxgi.c_str())) {
      status = "Frame Generation cannot intercept this DXGI factory";
      reshade::log::message(reshade::log::level::warning, std::format("Classic FG: factory entry {} belongs to {}.", index, std::filesystem::path(path).string()).c_str());
      return;
    }
  }
  HMODULE pinned = nullptr;
  if (!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN,
                          reinterpret_cast<LPCWSTR>(&OnInitDevice), &pinned)) return;
  const HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  if (snapshot == INVALID_HANDLE_VALUE) return;
  std::vector<HANDLE> threads;
  THREADENTRY32 entry{sizeof(entry)};
  bool valid = Thread32First(snapshot, &entry) != FALSE;
  if (valid) do {
      if (entry.th32OwnerProcessID != GetCurrentProcessId() || entry.th32ThreadID == GetCurrentThreadId()) continue;
      HANDLE thread = OpenThread(THREAD_SUSPEND_RESUME | THREAD_GET_CONTEXT | THREAD_SET_CONTEXT | THREAD_QUERY_INFORMATION, FALSE, entry.th32ThreadID);
      if (!thread) {
        valid = false;
        break;
      }
      threads.push_back(thread);
    } while (Thread32Next(snapshot, &entry));
  CloseHandle(snapshot);
  state->legacy = reinterpret_cast<Legacy>(table[10]);
  state->hwnd = reinterpret_cast<ForHwnd>(table[15]);
  if (valid && DetourTransactionBegin() == NO_ERROR) {
    valid = DetourUpdateThread(GetCurrentThread()) == NO_ERROR;
    for (HANDLE thread : threads)
      if (valid) valid = DetourUpdateThread(thread) == NO_ERROR;
    if (valid) valid = DetourAttach(reinterpret_cast<void**>(&state->legacy), reinterpret_cast<void*>(&LegacyHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&state->hwnd), reinterpret_cast<void*>(&HwndHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&engine::pump), reinterpret_cast<void*>(&engine::PumpHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&engine::tick), reinterpret_cast<void*>(&engine::TickHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&engine::construct), reinterpret_cast<void*>(&engine::ConstructHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&engine::execute), reinterpret_cast<void*>(&engine::ExecuteHook)) == NO_ERROR;
    if (valid)
      state->installed = DetourTransactionCommit() == NO_ERROR;
    else
      DetourTransactionAbort();
  }
  for (HANDLE thread : threads) CloseHandle(thread);
  if (state->installed) {
    state->native_device = native;
    state->reshade_device = device;
    reshade::log::message(reshade::log::level::info, "Classic FG: native factory and simulation/render handoff hooks installed.");
  }
}
inline void OnDestroyDevice(reshade::api::device* device) {
  std::lock_guard lock(state->mutex);
  if (state->reshade_device == device) {
    state->reshade_device = nullptr;
    state->native_device = nullptr;
    presentation_device = nullptr;
  }
}
}  // namespace factory
}  // namespace witcher3classic::frame_generation
#endif
