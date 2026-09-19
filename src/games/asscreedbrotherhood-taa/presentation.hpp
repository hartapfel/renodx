/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <atomic>
#include <memory>
#include <mutex>
#include <unordered_map>
#include <include/reshade.hpp>
#include "./native_draw.hpp"
#include "./presentation_client.hpp"
#include "./fg_capture.hpp"
#include "./frame_metrics.hpp"

namespace acbrotherhood::presentation {
inline HMODULE addon_module = nullptr;
inline float reflex_mode = 1.f, render_fps = 0.f;
inline PacingState pacing_state;  // Guarded by mutex, also when drawn in the overlay.
inline FrameMetrics frame_metrics; // Same mutex; no allocation/readback per frame.
inline std::atomic<bool> retry_requested = false;
enum class Status { waiting, active, failed };
inline std::atomic<Status> status = Status::waiting;
inline std::atomic<uint32_t> error_stage = 0, error_code = 0;
inline std::atomic<bool> render_marker_pending = false;
inline bool effects_rendered = false;
inline std::unordered_set<reshade::api::effect_runtime*> open_overlays;
struct Session {
  reshade::api::swapchain* api = nullptr;
  std::shared_ptr<Client> client;
  bool failed = false, retired = false, native_ready = false;
};
inline std::unordered_map<void*, std::shared_ptr<Session>> sessions;

inline double FrameTimeSeconds() {
  static const double inverse_frequency = [] {
    LARGE_INTEGER frequency{}; QueryPerformanceFrequency(&frequency);
    return frequency.QuadPart > 0 ? 1.0 / frequency.QuadPart : 0.0;
  }();
  LARGE_INTEGER time{}; QueryPerformanceCounter(&time);
  return time.QuadPart * inverse_frequency;
}

inline PacingSettings RequestedPacing() {
  return {
      frame_generation::RequestedFrames() ? 1u : std::isfinite(reflex_mode) ? uint32_t(std::clamp(reflex_mode, 0.f, 2.f)) : 1u,
      std::isfinite(render_fps) ? uint32_t(std::clamp(render_fps, 0.f, 1000.f)) : 0u};
}

inline bool Fail(const std::shared_ptr<Session>& session) {
  // Destroy the child window before allowing native presentation to recover.
  session->client.reset(); session->failed = true; status = Status::failed;
  frame_generation::output_enabled = false;
  frame_generation::received_flags = 0;
  frame_generation::generation_status = frame_generation::Status::failed;
  frame_generation::generation_error = error_code.load();
  frame_generation::reflex_active = false;
  pacing_state = {};
  frame_metrics = {};
  const auto message = std::string("Brotherhood DX12: restoring native output, stage=")
      + std::to_string(error_stage.load()) + " error=" + std::to_string(error_code.load());
  reshade::log::message(reshade::log::level::warning, message.c_str());
  return false;
}
// Called at the native DX9/DXGI boundary, after ReShade's effects/UI and any HDR
// proxy shader have rendered the final backbuffer. Never replay the game or return DX12
// output to DX9. Success transfers presentation ownership for this one frame.
inline bool PresentFrame(const std::shared_ptr<Session>& session, ID3D11Device* device,
                         ID3D11Texture2D* backbuffer, const D3D11_TEXTURE2D_DESC& desc,
                         HWND window, DXGI_COLOR_SPACE_TYPE color_space, UINT sync, UINT flags, HRESULT* result) {
  try {
    if (session->client) {
      if (session->client->failed) throw Failure{Stage::protocol, ERROR_PROCESS_ABORTED};
      const auto* packet = session->client->packet;
      if (packet->width != desc.Width || packet->height != desc.Height || packet->format != uint32_t(desc.Format)
          || packet->color_space != uint32_t(color_space) || packet->window != uintptr_t(window)
          || (packet->generation_requested != 0) != (frame_generation::RequestedFrames() != 0))
        session->client.reset();
    }
    if (!session->client) {
      frame_metrics = {};
      session->client = std::make_shared<Client>();
      std::wstring path(32768, L'\0');
      if (!GetModuleFileNameW(addon_module, path.data(), DWORD(path.size()))) throw Failure{Stage::protocol, GetLastError()};
      status = Status::waiting;
      const auto client = session->client;  // Keep alive across sent window messages.
      client->Start(device, desc, window, color_space,
          std::filesystem::path(path.c_str()).parent_path() / L"renodx-asscreedbrotherhood-dx12" / L"renodx-asscreedbrotherhood-dx12.exe",
          false, frame_generation::RequestedFrames(), RequestedPacing());
      if (session->retired) return false;
      active_client = client;
    }
    const auto client = session->client;
    // Multiplier changes reuse the current presenter; Off releases the helper's
    // Streamline resources through the session recreation above.
    client->packet->generation_requested = frame_generation::RequestedFrames();
    client->packet->pacing = RequestedPacing();
    std::shared_ptr<frame_generation::Capture> capture;
    if (frame_generation::NeedsInputs()) {
      const std::lock_guard capture_lock(frame_generation::capture_mutex);
      capture = frame_generation::current.lock();
    }
    if (capture && (capture->inputs.width != desc.Width || capture->inputs.height != desc.Height
                    || !capture->Acquire(window))) capture.reset();
    frame_generation::Inputs inputs = capture ? capture->inputs : frame_generation::Inputs{};
    // Our alpha currently covers game UI. While ReShade draws its own overlay,
    // keep FG active using HUD-less inference instead of tagging a partial mask.
    if (!open_overlays.empty()) inputs.flags &= ~frame_generation::ui_alpha;
    *result = client->Present(backbuffer, sync, flags, capture ? &inputs : nullptr,
        effects_rendered ? frame_generation::effects_rendered : 0u);
    frame_generation::generation_status = client->packet->generation_status;
    frame_generation::generation_error = client->packet->generation_error;
    frame_generation::presented_count = client->packet->generated_present_count;
    frame_generation::reflex_active = client->packet->reflex_active != 0;
    pacing_state = client->packet->pacing_state;
    frame_generation::generation_max = client->packet->generation_max;
    frame_generation::generation_configured = client->packet->generation_configured;
    if (client->packet->generation_status == frame_generation::Status::active)
      frame_generation::last_confirmed_count = client->packet->generated_present_count;
    if (frame_generation::received_flags.exchange(client->packet->accepted_inputs) != client->packet->accepted_inputs) {
      const auto message = std::string("Brotherhood FG inputs: accepted=") + std::to_string(client->packet->accepted_inputs)
          + " captured=" + std::to_string(capture ? capture->inputs.flags : 0)
          + " hudlessStage=" + std::to_string(capture ? capture->hudless_stage : 0)
          + " nativeFormat=" + std::to_string(capture ? capture->observed_format : 0)
          + " encodeError=" + std::to_string(client->input_error);
      reshade::log::message(reshade::log::level::info, message.c_str());
    }
    if (session->retired) return false;
    frame_metrics.Add(FrameTimeSeconds(), client->packet->generated_present_count);
    if (status.exchange(Status::active) != Status::active)
      reshade::log::message(reshade::log::level::info, "Brotherhood DX12: output active; native presentation suppressed.");
    error_stage = 0; error_code = 0;
    return true;
  } catch (const Failure& failure) {
    error_stage = uint32_t(failure.stage); error_code = failure.code;
  } catch (...) {
    error_stage = uint32_t(Stage::protocol); error_code = ERROR_UNHANDLED_EXCEPTION;
  }
  return Fail(session);
}
inline bool TryPresent(IDXGISwapChain* swapchain, UINT sync, UINT flags, HRESULT* result) {
  const std::lock_guard lock(mutex);
  const auto found = sessions.find(swapchain);
  if (found == sessions.end()) return false;
  const auto session = found->second;
  if (retry_requested.exchange(false)) {
    session->client.reset(); session->failed = false; status = Status::waiting;
    frame_generation::received_flags = 0;
    frame_generation::generation_status = frame_generation::Status::off;
    frame_generation::reflex_active = false;
    frame_generation::generation_max = 0;
    frame_generation::generation_configured = 0;
    frame_generation::last_confirmed_count = 0;
    pacing_state = {};
    frame_metrics = {};
  }
  frame_generation::output_enabled = !session->failed;
  if (flags & DXGI_PRESENT_TEST) return false;
  if (session->failed) return false;
  // Starting enabled must follow the same handoff as enabling during gameplay:
  // let DXGI establish one successful, visible native presentation first.
  // A TEST/occluded/failed Present does not establish display ownership.
  if (!session->native_ready) {
    status = Status::waiting;
    frame_generation::output_enabled = false;
    return false;
  }
  try {
    ComPtr<ID3D11Texture2D> backbuffer;
    Check(swapchain->GetBuffer(0, IID_PPV_ARGS(&backbuffer)), Stage::copy);
    D3D11_TEXTURE2D_DESC desc{}; backbuffer->GetDesc(&desc);
    DXGI_SWAP_CHAIN_DESC swap_desc{};
    Check(swapchain->GetDesc(&swap_desc), Stage::swapchain);
    if (!swap_desc.Windowed) throw Failure{Stage::window, ERROR_NOT_SUPPORTED};
    DXGI_COLOR_SPACE_TYPE color_space;
    switch (session->api->get_color_space()) {
      case reshade::api::color_space::srgb: color_space = DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709; break;
      case reshade::api::color_space::scrgb: color_space = DXGI_COLOR_SPACE_RGB_FULL_G10_NONE_P709; break;
      case reshade::api::color_space::hdr10_pq: color_space = DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020; break;
      default: throw Failure{Stage::swapchain, ERROR_NOT_SUPPORTED};
    }
    return PresentFrame(session, reinterpret_cast<ID3D11Device*>(session->api->get_device()->get_native()),
                        backbuffer.Get(), desc, swap_desc.OutputWindow, color_space, sync, flags, result);
  } catch (const Failure& failure) {
    error_stage = uint32_t(failure.stage); error_code = failure.code;
  } catch (...) {
    error_stage = uint32_t(Stage::protocol); error_code = ERROR_UNHANDLED_EXCEPTION;
  }
  return Fail(session);
}
inline void OnNativePresent(IDXGISwapChain* swapchain, UINT flags, HRESULT result) {
  if (result != S_OK || (flags & DXGI_PRESENT_TEST)) return;
  const std::lock_guard lock(mutex);
  const auto found = sessions.find(swapchain);
  if (found == sessions.end() || found->second->native_ready) return;
  DXGI_SWAP_CHAIN_DESC desc{};
  if (SUCCEEDED(swapchain->GetDesc(&desc)) && IsWindowVisible(desc.OutputWindow) && !IsIconic(desc.OutputWindow)) {
    found->second->native_ready = true;
    reshade::log::message(reshade::log::level::info, "Brotherhood DX12: native display initialized; presentation handoff ready.");
  }
}
inline HRESULT STDMETHODCALLTYPE Present(IDXGISwapChain* swapchain, UINT sync, UINT flags) {
  HRESULT result;
  if (TryPresent(swapchain, sync, flags, &result)) return result;
  result = native_draw::Original<decltype(&Present)>(swapchain, 8)(swapchain, sync, flags);
  OnNativePresent(swapchain, flags, result);
  return result;
}
inline HRESULT STDMETHODCALLTYPE Present1(IDXGISwapChain1* swapchain, UINT sync, UINT flags, const DXGI_PRESENT_PARAMETERS* parameters) {
  HRESULT result;
  if (TryPresent(swapchain, sync, flags, &result)) return result;
  result = native_draw::Original<decltype(&Present1)>(swapchain, 22)(swapchain, sync, flags, parameters);
  OnNativePresent(swapchain, flags, result);
  return result;
}
inline void OnInitSwapchain(reshade::api::swapchain* swapchain, bool) {
  if (swapchain->get_device()->get_api() != reshade::api::device_api::d3d11) return;
  DWORD process = 0;
  GetWindowThreadProcessId(static_cast<HWND>(swapchain->get_hwnd()), &process);
  if (process != GetCurrentProcessId()) return;
  const std::lock_guard lock(mutex);
  auto* native = reinterpret_cast<IDXGISwapChain*>(swapchain->get_native());
  auto session = std::make_shared<Session>(); session->api = swapchain;
  sessions[native] = std::move(session);
  native_draw::Install(native, 8, reinterpret_cast<void*>(&Present));
  ComPtr<IDXGISwapChain1> swapchain1;
  if (SUCCEEDED(native->QueryInterface(IID_PPV_ARGS(&swapchain1))))
    native_draw::Install(swapchain1.Get(), 22, reinterpret_cast<void*>(&Present1), native);
}
inline void OnDestroySwapchain(reshade::api::swapchain* swapchain, bool) {
  if (swapchain->get_device()->get_api() != reshade::api::device_api::d3d11) return;
  const std::lock_guard lock(mutex);
  auto* native = reinterpret_cast<IDXGISwapChain*>(swapchain->get_native());
  const auto found = sessions.find(native);
  if (found != sessions.end()) {
    found->second->retired = true;
    found->second->client.reset();
    sessions.erase(found);
  }
  native_draw::Uninstall(native);
  frame_generation::output_enabled = false;
  frame_generation::received_flags = 0;
  frame_generation::generation_status = frame_generation::Status::waiting;
  frame_generation::reflex_active = false;
  pacing_state = {};
  frame_metrics = {};
  status = Status::waiting;
}
inline void SendTiming(Command command, HWND window) {
  const std::lock_guard lock(mutex);
  std::shared_ptr<Session> target;
  for (const auto& [native, session] : sessions) {
    if (session->client && !session->retired && !session->failed && !session->client->in_flight
        && session->client->packet->window == uintptr_t(window)) { target = session; break; }
  }
  if (!target) return;
  // Sent window messages can destroy a swapchain during an IPC wait. Retain
  // ownership and do not keep a map iterator/reference alive across that wait.
  const auto client = target->client;
  try {
    client->packet->pacing = RequestedPacing();
    if (client->Timing(command) && !target->retired && command == Command::begin_frame) render_marker_pending = true;
  } catch (const Failure& failure) {
    target->client.reset(); target->failed = true; status = Status::failed;
    error_stage = uint32_t(failure.stage); error_code = failure.code;
    frame_generation::reflex_active = false;
    pacing_state = {};
    frame_metrics = {};
    frame_generation::generation_status = frame_generation::Status::failed;
    frame_generation::generation_error = failure.code;
  }
}
inline void OnRenderBegin(IDirect3DDevice9* wrapper) {
  if (!render_marker_pending.load()) return;
  D3DDEVICE_CREATION_PARAMETERS parameters{};
  if (SUCCEEDED(wrapper->GetCreationParameters(&parameters))) {
    render_marker_pending = false;
    SendTiming(Command::render_begin, parameters.hFocusWindow);
  }
}
inline void OnFinishPresent(reshade::api::command_queue*, reshade::api::swapchain* swapchain) {
  if (swapchain->get_device()->get_api() != reshade::api::device_api::d3d9) return;
  {
    const std::lock_guard lock(mutex);
    effects_rendered = false;
    if (status.load() != Status::active) frame_metrics.Add(FrameTimeSeconds(), 1);
  }
  SendTiming(Command::begin_frame, static_cast<HWND>(swapchain->get_hwnd()));
}
inline void OnTechnique(reshade::api::effect_runtime*, reshade::api::effect_technique, reshade::api::command_list*,
                         reshade::api::resource_view, reshade::api::resource_view) {
  const std::lock_guard lock(mutex);
  effects_rendered = true;
}
inline bool OnOverlay(reshade::api::effect_runtime* runtime, bool open, reshade::api::input_source) {
  const std::lock_guard lock(mutex);
  if (open) open_overlays.insert(runtime); else open_overlays.erase(runtime);
  return false;
}
inline void OnDestroyRuntime(reshade::api::effect_runtime* runtime) {
  const std::lock_guard lock(mutex); open_overlays.erase(runtime);
}
inline void Use(DWORD reason) {
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::reshade_open_overlay>(OnOverlay);
    reshade::register_event<reshade::addon_event::destroy_effect_runtime>(OnDestroyRuntime);
    native_draw::on_begin_scene = OnRenderBegin;
    reshade::register_event<reshade::addon_event::finish_present>(OnFinishPresent);
    reshade::register_event<reshade::addon_event::reshade_render_technique>(OnTechnique);
    reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
    reshade::register_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::reshade_open_overlay>(OnOverlay);
    reshade::unregister_event<reshade::addon_event::destroy_effect_runtime>(OnDestroyRuntime);
    open_overlays.clear();
    native_draw::on_begin_scene = nullptr;
    reshade::unregister_event<reshade::addon_event::finish_present>(OnFinishPresent);
    reshade::unregister_event<reshade::addon_event::reshade_render_technique>(OnTechnique);
    reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
    reshade::unregister_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
    for (auto& [native, session] : sessions) native_draw::Uninstall(native);
    sessions.clear();
  }
}
}  // namespace acbrotherhood::presentation
