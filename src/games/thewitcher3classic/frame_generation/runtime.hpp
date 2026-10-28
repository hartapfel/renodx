/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <embed/shaders.h>
#include <atomic>
#include <include/reshade.hpp>
#include "../../../utils/data.hpp"
#include "../../../utils/shader.hpp"
#include "../shared.h"
#include "../temporal/runtime.hpp"
#include "./capture.hpp"
#include "./ui_shaders.hpp"
#include "./diagnostics.hpp"
#include "./distortion.hpp"

namespace witcher3classic::frame_generation {
inline float mode = 0.f, multiplier = 2.f, target_fps = 0.f, hud_quality = 0.f;
// Only set while a DX12 presentation owner is attached to this DX11 device.
// The DX12 presentation bridge starts independently of the saved FG mode.
// Off skips scene/HUD capture; the bridge remains ready for live enabling.
inline ID3D11Device* presentation_device = nullptr;
inline std::atomic<const char*> status = "Initializing Frame Generation presentation";
inline std::atomic<bool> transport_active = false, dynamic_supported = false, overlay_open = false, effects_active = false;
inline std::atomic<uint32_t> max_multiplier = 6, frames_presented = 0;
struct __declspec(uuid("4cde2fc7-0d65-48cb-9e4a-9bda2d827370")) CaptureData {
  Capture capture;
  Distortion distortion;
  std::array<float, 720> native_camera{};
  bool camera_valid = false;
  bool attempted = false, ready = false;
};

inline CaptureData* PrepareCapture(reshade::api::command_list* cmd) {
  if (!presentation_device || mode == 0.f || cmd->get_device()->get_api() != reshade::api::device_api::d3d11) return nullptr;
  auto* data = renodx::utils::data::Get<temporal::DeviceData>(cmd->get_device());
  if (!data || data->last_resolve != data->frame || !data->motion_context || cmd->get_native() != data->motion_native_handle) return nullptr;
  if (!temporal::IsSameDevice(data->motion_context.Get(), presentation_device)) return nullptr;
  auto* capture = renodx::utils::data::Get<CaptureData>(cmd->get_device());
  if (!capture) capture = renodx::utils::data::Create<CaptureData>(cmd->get_device());
  if (!capture->attempted) {
    capture->attempted = true;
    capture->ready = capture->capture.Initialize(presentation_device, __swap_chain_proxy_vertex_shader,
                                                 __swap_chain_proxy_pixel_shader, sizeof(ShaderInjectData));
  }
  if (!capture->ready) return nullptr;
  if (capture->capture.frame != data->frame) {
    capture->capture.Reset(data->frame);
    capture->camera_valid = data->camera.Snapshot(&capture->native_camera);
  }
  return capture;
}
inline bool OnUI(reshade::api::command_list* cmd) {
  auto* capture = PrepareCapture(cmd);
  if (!capture) return false;
  const auto* data = renodx::utils::data::Get<temporal::DeviceData>(cmd->get_device());
  D3D11_TEXTURE2D_DESC desc{};
  data->dlss.output->GetDesc(&desc);
  return capture->capture.BeginUI(data->motion_context.Get(), data->frame, desc.Width, desc.Height);
}
inline constexpr auto OnSceneCopy = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  if (!PrepareCapture(context.cmd_list)) return {};
  return {.post_callback = [](Context& completed, const void*) {
    auto* capture = renodx::utils::data::Get<CaptureData>(completed.cmd_list->get_device());
    const auto* data = renodx::utils::data::Get<temporal::DeviceData>(completed.cmd_list->get_device());
    D3D11_TEXTURE2D_DESC desc{};
    data->dlss.output->GetDesc(&desc);
    capture->capture.BeginScene(data->motion_context.Get(), data->frame, desc.Width, desc.Height);
  }};
};
inline void OnUIDrawn(reshade::api::command_list* cmd) {
  const auto* data = renodx::utils::data::Get<temporal::DeviceData>(cmd->get_device());
  auto* capture = renodx::utils::data::Get<CaptureData>(cmd->get_device());
  if (capture && data && data->motion_context && cmd->get_native() == data->motion_native_handle)
    capture->capture.EndUI(data->motion_context.Get());
}
inline constexpr auto ObserveDraw = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  if (!presentation_device || mode == 0.f) return {};
  auto* capture = renodx::utils::data::Get<CaptureData>(context.cmd_list->get_device());
  const auto* data = renodx::utils::data::Get<temporal::DeviceData>(context.cmd_list->get_device());
  if (!capture || !data || !data->motion_context || capture->capture.frame != data->frame
      || context.cmd_list->get_native() != data->motion_native_handle) return {};
  auto* shaders = renodx::utils::shader::GetCurrentState(context.cmd_list);
  const auto hash = shaders ? renodx::utils::shader::GetCurrentPixelShaderHash(shaders) : 0;
  const auto* ui = std::lower_bound(std::begin(ui_shaders), std::end(ui_shaders), hash,
                                   [](const auto& shader, uint32_t value) { return shader.first < value; });
  capture->capture.ObserveDraw(data->motion_context.Get(), ui != std::end(ui_shaders) && ui->first == hash);
  return {};
};
inline void OnDestroyDevice(reshade::api::device* device) {
  if (renodx::utils::data::Get<CaptureData>(device)) renodx::utils::data::Delete<CaptureData>(device);
}
inline bool OnOverlay(reshade::api::effect_runtime*, bool open, reshade::api::input_source) {
  overlay_open = open;
  return false;
}
inline void OnEffects(reshade::api::effect_runtime* runtime) {
  // Effects/overlay alter the final output after the game's HUD capture. Do
  // not interpolate mismatched HUD-less color or unrepresented overlay alpha.
  bool active = false;
  if (transport_active && runtime->get_effects_state())
    runtime->enumerate_techniques(nullptr, [&active](auto* current, auto technique) { active |= current->get_technique_state(technique); });
  effects_active = active;
}
inline bool OnCreateSwapchain(reshade::api::device_api api, reshade::api::swapchain_desc& desc, void* window) {
  if (!transport_active || api != reshade::api::device_api::d3d11) return false;
  wchar_t name[32]{};
  if (!GetClassNameW(static_cast<HWND>(window), name, 32) || std::wcscmp(name, L"W2ViewportClass")) return false;
  // Run after RenoDX's ordinary flip upgrade. The DX11 facade deliberately
  // exposes one stable surface; its DX12 presenter owns the three flip buffers.
  // Without this, the generic upgrade requests two DX11 buffers on resize.
  desc.back_buffer_count = 1;
  desc.present_mode = DXGI_SWAP_EFFECT_DISCARD;
  return true;
}
inline void Use(DWORD reason) {
  if (reason == DLL_PROCESS_ATTACH) {
    // Live HUD-on/off snapshots: this fullscreen copy follows final grading
    // and precedes all HUD draws. Earlier copies precede the current SR resolve;
    // the final output copy cannot replace an already captured scene.
    renodx::utils::command_action::Register(OnSceneCopy, {.shader_hash = 0xB13D3F21,
                                                        .command_types = renodx::utils::command_action::COMMAND_TYPE_DRAW});
    renodx::utils::command_action::Register(ObserveDraw, {.command_types = renodx::utils::command_action::COMMAND_TYPE_DIRECT_DRAW
                                                                           | renodx::utils::command_action::COMMAND_TYPE_INDIRECT});
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::register_event<reshade::addon_event::reshade_open_overlay>(OnOverlay);
    reshade::register_event<reshade::addon_event::reshade_present>(OnEffects);
    reshade::register_event<reshade::addon_event::create_swapchain>(OnCreateSwapchain);
  } else if (reason == DLL_PROCESS_DETACH) {
    renodx::utils::command_action::Unregister(OnSceneCopy);
    renodx::utils::command_action::Unregister(ObserveDraw);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::unregister_event<reshade::addon_event::reshade_open_overlay>(OnOverlay);
    reshade::unregister_event<reshade::addon_event::reshade_present>(OnEffects);
    reshade::unregister_event<reshade::addon_event::create_swapchain>(OnCreateSwapchain);
  }
}
}  // namespace witcher3classic::frame_generation
