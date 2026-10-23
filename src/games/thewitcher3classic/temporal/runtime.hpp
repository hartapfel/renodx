/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <chrono>
#include <filesystem>
#include <format>
#include <include/reshade.hpp>
#include <embed/shaders.h>
#include "../../../utils/data.hpp"
#include "../../../utils/directx.hpp"
#include "./camera.hpp"
#include "./dlss.hpp"
#include "./prepare.hpp"
#include "./object_motion.hpp"
#include "./object_shaders.hpp"

namespace witcher3classic::temporal {
inline float mode = 1.f;
inline float model = 3.f;  // M; unsupported DLLs retain the existing fallback.
inline float quality = 1.f;  // Quality.
inline float object_motion = 1.f;
inline float exclude_vegetation = 0.f;
inline float show_object_vectors = 0.f;
inline std::string status = "Native TAA";
inline std::string resolution_status;

struct __declspec(uuid("1cfb3c5d-f210-40c2-93e9-f765c9541cd4")) MotionCapabilities {
  std::atomic<bool> deferred = false;
};

struct __declspec(uuid("fdb6913b-a729-490b-b0f3-46ba64e4b346")) DeviceData {
  DeviceData() { objects.uploads.track_writes = true; }
  Dlss dlss;
  Prepare prepare;
  Camera camera;
  ObjectMotion objects;
  ComPtr<ID3D11DeviceContext1> motion_context;
  uint64_t motion_native_handle = 0;
  ComPtr<ID3D11ShaderResourceView> resolved;
  std::chrono::steady_clock::time_point last_time;
  reshade::api::swapchain* swapchain = nullptr;
  uint64_t frame = 0, last_resolve = UINT64_MAX;
  bool attempted = false, ready = false, logged = false, logged_objects = false;
  bool hooks_attempted = false;
  bool logged_deformed = false, logged_rigid = false, logged_hair = false;
  bool logged_target_reuse = false;
  uint32_t constant_profile_frames = 0;
  std::array<std::array<const char*, 16>, OBJECT_VERTEX_SHADERS.size()> object_rejections = {};
  std::array<bool, OBJECT_VERTEX_SHADERS.size()> object_acceptances = {};
  bool logged_head = false, logged_head_rejection = false;
  std::array<uintptr_t, 2> logged_vector_views = {};
  std::array<RenderResolution, 5> render_resolutions = {};
  uint32_t planned_output_width = 0, planned_output_height = 0;
  upscale_engine::Plan logged_resolution;
};

inline ConstantUploads* GetConstantUploads(reshade::api::device* device) {
  auto* data = renodx::utils::data::Get<DeviceData>(device);
  return data ? &data->objects.uploads : nullptr;
}
inline void OnMotionCommandList(reshade::api::command_list* cmd) {
  if (cmd->get_device()->get_api() != reshade::api::device_api::d3d11) return;
  ComPtr<ID3D11DeviceContext> context;
  if (SUCCEEDED(reinterpret_cast<IUnknown*>(cmd->get_native())->QueryInterface(IID_PPV_ARGS(&context)))
      && context->GetType() == D3D11_DEVICE_CONTEXT_IMMEDIATE) return;
  // Map events do not identify their context. Deferred Map uploads may precede
  // execution, so CPU mirrors cannot safely stand in for the current GPU data.
  auto* capability = renodx::utils::data::Get<MotionCapabilities>(cmd->get_device());
  if (!capability) capability = renodx::utils::data::Create<MotionCapabilities>(cmd->get_device());
  if (!capability->deferred.exchange(true))
    reshade::log::message(reshade::log::level::info, "Witcher Classic: deferred context detected; retaining GPU constant history copies.");
  if (auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device())) data->objects.uploads.track_writes.store(false);
}
inline void OnMotionMap(reshade::api::device* device, reshade::api::resource resource, uint64_t offset, uint64_t size,
                        reshade::api::map_access access, void** data) {
  if (access == reshade::api::map_access::read_only) return;
  if (auto* uploads = GetConstantUploads(device))
    uploads->Map(reinterpret_cast<ID3D11Buffer*>(resource.handle), offset, size, access == reshade::api::map_access::write_discard, data);
}
inline void OnMotionUnmap(reshade::api::device* device, reshade::api::resource resource) {
  if (auto* uploads = GetConstantUploads(device)) uploads->Unmap(reinterpret_cast<ID3D11Buffer*>(resource.handle));
}
inline bool OnMotionUpdate(reshade::api::device* device, const void* source, reshade::api::resource destination, uint64_t offset, uint64_t size) {
  if (auto* uploads = GetConstantUploads(device)) uploads->Update(reinterpret_cast<ID3D11Buffer*>(destination.handle), source, offset, size);
  return false;
}
inline bool OnMotionDeferredUpdate(reshade::api::command_list* cmd, const void*, reshade::api::resource destination, uint64_t, uint64_t) {
  if (auto* uploads = GetConstantUploads(cmd->get_device())) uploads->Invalidate(reinterpret_cast<ID3D11Buffer*>(destination.handle));
  return false;
}
inline bool OnMotionCopy(reshade::api::command_list* cmd, reshade::api::resource, reshade::api::resource destination) {
  if (auto* uploads = GetConstantUploads(cmd->get_device())) uploads->Invalidate(reinterpret_cast<ID3D11Buffer*>(destination.handle));
  return false;
}
inline bool OnMotionBufferCopy(reshade::api::command_list* cmd, reshade::api::resource, uint64_t, reshade::api::resource destination, uint64_t, uint64_t) {
  if (auto* uploads = GetConstantUploads(cmd->get_device())) uploads->Invalidate(reinterpret_cast<ID3D11Buffer*>(destination.handle));
  return false;
}
inline void OnMotionExecute(reshade::api::command_list* cmd, reshade::api::command_list*) {
  // On D3D11, execute_command_list also fires on every Present/Flush. Those
  // submit already-observed writes and must not invalidate unchanged history.
  // Only deferred command-list execution can introduce unobserved GPU writes.
  if (auto* uploads = GetConstantUploads(cmd->get_device())) uploads->Invalidate();
}

inline bool OnObjectVertex(reshade::api::command_list* cmd) {
  if (mode == 0.f || object_motion == 0.f) return false;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if (!data || !data->ready || !object_engine::state->enabled.load(std::memory_order_relaxed)) return false;
  auto* shader_state = renodx::utils::shader::GetCurrentState(cmd);
  if (!shader_state) return false;
  const auto* vertex = FindObjectShader(OBJECT_VERTEX_SHADERS, renodx::utils::shader::GetCurrentVertexShaderHash(shader_state));
  const auto* pixel = FindObjectShader(OBJECT_PIXEL_SHADERS, renodx::utils::shader::GetCurrentPixelShaderHash(shader_state));
  if (!vertex || !pixel || vertex->signature != pixel->signature) return false;
  if (!data->motion_context || cmd->get_native() != data->motion_native_handle) return false;
  const auto& context = data->motion_context;
  if (vertex->foliage && exclude_vegetation != 0.f) {
    data->objects.ClosePass(context.Get());
    return false;
  }
  const bool accepted = data->objects.Begin(context.Get(), data->frame, vertex->reference, vertex->deformed, vertex->rigid, vertex->forward || pixel->forward, vertex->foliage);
  if (!accepted) data->objects.ClosePass(context.Get());
  if ((vertex->hash == 0x4B5AEE17 || vertex->forward) && ((accepted && !data->logged_head) || (!accepted && !data->logged_head_rejection))) {
    if (accepted) data->logged_head = true;
    else data->logged_head_rejection = true;
    reshade::log::message(reshade::log::level::info,
        std::format("Witcher Classic: hero head motion draw 0x{:08X} {}: {} (0x{:08X}).", vertex->hash, accepted ? "accepted" : "rejected", data->objects.rejection, uint32_t(data->objects.error)).c_str());
  }
  if (vertex->hash == 0xAB3E8304 && !data->logged_hair) {
    data->logged_hair = true;
    reshade::log::message(reshade::log::level::info,
        std::format("Witcher Classic: opaque hair motion {}: {} (0x{:08X}).", accepted ? "accepted" : "rejected", data->objects.rejection, uint32_t(data->objects.error)).c_str());
  }
  if (show_object_vectors != 0.f) {
    const auto index = size_t(vertex - OBJECT_VERTEX_SHADERS.data());
    bool log = false;
    if (accepted) {
      log = !data->object_acceptances[index];
      data->object_acceptances[index] = true;
    } else {
      auto& reasons = data->object_rejections[index];
      if (std::ranges::find(reasons, data->objects.rejection) == reasons.end()) {
        const auto empty = std::ranges::find(reasons, nullptr);
        if (empty != reasons.end()) { *empty = data->objects.rejection; log = true; }
      }
    }
    if (log) {
      Microsoft::WRL::ComPtr<ID3D11DepthStencilState> depth;
      context->OMGetDepthStencilState(&depth, nullptr);
      D3D11_DEPTH_STENCIL_DESC desc = CD3D11_DEPTH_STENCIL_DESC(D3D11_DEFAULT);
      if (depth) depth->GetDesc(&desc);
      reshade::log::message(reshade::log::level::info,
          std::format("Witcher Classic: motion VS 0x{:08X} / PS 0x{:08X} {}: {} (0x{:08X}), depth enable={} func={} write={} stencil={}", vertex->hash, pixel->hash,
                      accepted ? "accepted" : "rejected", data->objects.rejection, uint32_t(data->objects.error), desc.DepthEnable, uint32_t(desc.DepthFunc), uint32_t(desc.DepthWriteMask), desc.StencilEnable).c_str());
    }
  }
  return accepted;
}
inline bool OnObjectPixel(reshade::api::command_list* cmd) {
  if (mode == 0.f || object_motion == 0.f) return false;
  const auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  return data && data->objects.active_draw;
}
inline void OnObjectDrawn(reshade::api::command_list* cmd) {
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if (!data || !data->objects.active_draw) return;
  if (data->motion_context && cmd->get_native() == data->motion_native_handle)
    data->objects.End(data->motion_context.Get(), true);
}
inline constexpr auto ObjectDrawBoundary = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  auto* data = renodx::utils::data::Get<DeviceData>(context.cmd_list->get_device());
  if (!data || !data->objects.HasPendingPass() || !data->motion_context
      || context.cmd_list->get_native() != data->motion_native_handle) return {};
  bool keep = mode != 0.f && object_motion != 0.f && data->ready && !context.IsDispatch()
              && object_engine::state->enabled.load(std::memory_order_relaxed);
  if (keep) {
    auto* state = renodx::utils::shader::GetCurrentState(context.cmd_list);
    if (!state) keep = false;
    else {
      const auto* vertex = FindObjectShader(OBJECT_VERTEX_SHADERS, renodx::utils::shader::GetCurrentVertexShaderHash(state));
      const auto* pixel = FindObjectShader(OBJECT_PIXEL_SHADERS, renodx::utils::shader::GetCurrentPixelShaderHash(state));
      keep = exclude_vegetation == 0.f && vertex && pixel && vertex->foliage && vertex->signature == pixel->signature;
    }
  }
  if (!keep) data->objects.ClosePass(data->motion_context.Get());
  return {};
};
inline constexpr auto ObjectDrawPost = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  if (mode == 0.f || object_motion == 0.f) return {};
  const auto* data = renodx::utils::data::Get<DeviceData>(context.cmd_list->get_device());
  if (!data || !data->objects.active_draw) return {};
  return {.post_callback = [](Context& context, const void*) { OnObjectDrawn(context.cmd_list); }, .replay = true};
};

inline bool OnTemporalDraw(reshade::api::command_list* cmd) {
  if (mode == 0.f || cmd->get_device()->get_api() != reshade::api::device_api::d3d11) return true;
  if (upscale_engine::active) upscale_engine::active->temporal_seen = true;
  auto* device = cmd->get_device();
  auto* data = renodx::utils::data::Get<DeviceData>(device);
  if (!data) {
    data = renodx::utils::data::Create<DeviceData>(device);
    if (const auto* capability = renodx::utils::data::Get<MotionCapabilities>(device); capability && capability->deferred.load())
      data->objects.uploads.track_writes.store(false);
  }
  auto* native = reinterpret_cast<ID3D11Device*>(device->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&native);
  auto* base_context = reinterpret_cast<ID3D11DeviceContext*>(cmd->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&base_context);
  if (base_context->GetType() != D3D11_DEVICE_CONTEXT_IMMEDIATE) return true;
  ComPtr<ID3D11DeviceContext1> context;
  if (FAILED(base_context->QueryInterface(IID_PPV_ARGS(&context)))) return true;
  data->motion_context = context;
  data->motion_native_handle = cmd->get_native();
  data->objects.ClosePass(context.Get());
  if (!data->attempted) {
    data->attempted = true;
    wchar_t executable[32768];
    const DWORD length = GetModuleFileNameW(nullptr, executable, DWORD(std::size(executable)));
    if (!length || length == std::size(executable) || !data->camera.Initialize()) {
      status = "Native TAA: unrecognized Classic executable/camera contract";
      return true;
    }
    if (!data->prepare.Initialize(native, __0xF3C10001, __0xF3C10002, __0xF3C10003, __0xF3C10004)) {
      status = std::format("Native TAA: GPU preparation failed (0x{:08X})", uint32_t(data->prepare.error));
      return true;
    }
    if (!data->dlss.Initialize(native, std::filesystem::path(executable).parent_path() / L"renodx-witcher3classic-dlss")) {
      status = std::format("Native TAA: {} (0x{:08X})", data->dlss.status, data->dlss.error);
      reshade::log::message(reshade::log::level::warning, status.c_str());
      return true;
    }
    data->ready = true;
  }
  if (!data->ready || data->last_resolve == data->frame) return true;
  std::array<float, 2> jitter;
  if (!data->camera.Jitter(&jitter)) { status = "Native TAA: invalid camera jitter"; return true; }
  ComPtr<ID3D11ShaderResourceView> scene, depth;
  ComPtr<ID3D11Buffer> camera, frame;
  ComPtr<ID3D11RenderTargetView> target;
  context->PSGetShaderResources(0, 1, &scene);
  context->PSGetShaderResources(4, 1, &depth);
  context->PSGetConstantBuffers(10, 1, &camera);
  context->PSGetConstantBuffers(12, 1, &frame);
  context->OMGetRenderTargets(1, &target, nullptr);
  if (!scene || !depth || !camera || !frame || !target) return true;
  ComPtr<ID3D11Resource> source_resource, target_resource;
  ComPtr<ID3D11Texture2D> source_texture, target_texture;
  scene->GetResource(&source_resource);
  target->GetResource(&target_resource);
  if (FAILED(source_resource.As(&source_texture)) || FAILED(target_resource.As(&target_texture))) return true;
  D3D11_TEXTURE2D_DESC source_desc, target_desc;
  source_texture->GetDesc(&source_desc);
  target_texture->GetDesc(&target_desc);
  // The native pool remains output-sized. Reconstruction consumes only the
  // main view's rendered subrectangle, never a downsampled full-resolution frame.
  if (data->planned_output_width != target_desc.Width || data->planned_output_height != target_desc.Height) {
    data->planned_output_width = target_desc.Width;
    data->planned_output_height = target_desc.Height;
    resolution_status = std::format("Output: {} x {}", target_desc.Width, target_desc.Height);
    constexpr const char* labels[] = {"DLAA", "Quality", "Balanced", "Performance", "Ultra Performance"};
    for (size_t i = 0; i < std::size(QUALITY_MODES); ++i) {
      if (data->dlss.GetRenderResolution(target_desc.Width, target_desc.Height, QUALITY_MODES[i], &data->render_resolutions[i]))
        resolution_status += std::format("\n{} input: {} x {}", labels[i], data->render_resolutions[i].width, data->render_resolutions[i].height);
      else resolution_status += std::format("\n{}: resolution query unavailable", labels[i]);
    }
    reshade::log::message(reshade::log::level::info, resolution_status.c_str());
  }
  if (source_desc.Width != target_desc.Width || source_desc.Height != target_desc.Height
      || source_desc.SampleDesc.Count != 1 || target_desc.SampleDesc.Count != 1
      || (source_desc.Format != DXGI_FORMAT_R11G11B10_FLOAT && source_desc.Format != DXGI_FORMAT_R16G16B16A16_FLOAT)) return true;
  const auto* upscale = upscale_engine::active;
  const uint32_t render_width = upscale ? upscale->plan.width : source_desc.Width;
  const uint32_t render_height = upscale ? upscale->plan.height : source_desc.Height;
  D3D11_VIEWPORT viewport;
  UINT viewport_count = 1;
  context->RSGetViewports(&viewport_count, &viewport);
  if (viewport_count != 1 || viewport.TopLeftX != 0 || viewport.TopLeftY != 0
      || viewport.Width != float(render_width) || viewport.Height != float(render_height)
      || render_width > source_desc.Width || render_height > source_desc.Height
      || (upscale && (target_desc.Width != upscale->plan.output_width || target_desc.Height != upscale->plan.output_height))) {
    status = "Native TAA: scene viewport does not match the DLSS plan";
    return true;
  }
  ComPtr<ID3D11Resource> depth_resource;
  depth->GetResource(&depth_resource);
  data->objects.Configure(depth_resource.Get(), source_desc.Width, source_desc.Height, render_width, render_height);
  if (!data->hooks_attempted) {
    data->hooks_attempted = true;
    if (!object_engine::Install()) {
      reshade::log::message(reshade::log::level::warning, "Witcher Classic: native history/resolution hooks unavailable; retaining camera DLAA test.");
      object_motion = 0.f;
    }
  }
  object_engine::state->enabled.store(object_motion != 0.f, std::memory_order_relaxed);
  const bool objects = object_motion != 0.f && data->objects.HasFrame(data->frame);
  if (!data->prepare.Run(context.Get(), scene.Get(), depth.Get(), objects ? data->objects.surfaces[0].Get() : nullptr,
                         camera.Get(), frame.Get(), render_width, render_height,
                         objects ? data->objects.surfaces[1].Get() : nullptr)) return true;
  data->objects.Finish(context.Get(), data->frame);
  const auto now = std::chrono::steady_clock::now();
  const bool gap = data->last_resolve == UINT64_MAX || data->frame != data->last_resolve + 1;
  const float elapsed = gap ? 16.667f : std::chrono::duration<float, std::milli>(now - data->last_time).count();
  const DlssInputs inputs{
      .color = data->prepare.textures[0].Get(), .depth = data->prepare.textures[1].Get(),
      .motion = data->prepare.textures[2].Get(), .responsive = data->prepare.textures[3].Get(),
      .width = render_width, .height = render_height,
      .output_width = target_desc.Width, .output_height = target_desc.Height,
      .jitter_x = jitter[0], .jitter_y = jitter[1], .frame_ms = std::clamp(elapsed, 0.1f, 1000.f),
      .frame_id = data->frame, .reset = gap, .depth_inverted = true,
      .motion_validated = false, .development_inputs = true,
      .render_preset = MODEL_PRESETS[static_cast<size_t>(std::clamp(model, 0.f, 4.f))],
      .quality = QUALITY_MODES[upscale ? upscale->plan.quality : 0],
  };
  if (!data->dlss.Evaluate(context.Get(), inputs)) {
    status = std::format("Native TAA: {} (0x{:08X})", data->dlss.status, data->dlss.error);
    data->ready = false;
    object_engine::Disable();
    upscale_engine::Disable();
    reshade::log::message(reshade::log::level::warning, status.c_str());
    return true;
  }
  // Feature recreation changes the FP16 output texture. Retain its SRV only
  // while that texture is current; the final draw converts to native R11.
  ComPtr<ID3D11Resource> resolved_resource;
  if (data->resolved) data->resolved->GetResource(&resolved_resource);
  if (resolved_resource.Get() != data->dlss.output.Get()) {
    data->resolved.Reset();
    if (FAILED(native->CreateShaderResourceView(data->dlss.output.Get(), nullptr, &data->resolved))) return true;
  }
  const auto debug_view = static_cast<uint32_t>(std::clamp(show_object_vectors, 0.f, 5.f));
  const bool debug_vectors = debug_view == 1;
  if (debug_vectors && objects) {
    const std::array<uintptr_t, 2> views = {reinterpret_cast<uintptr_t>(data->objects.surfaces[0].Get()), reinterpret_cast<uintptr_t>(data->objects.surfaces[1].Get())};
    if (data->logged_vector_views != views) {
      data->logged_vector_views = views;
      reshade::log::message(reshade::log::level::info,
          std::format("Witcher Classic: diagnostic SRVs object vectors=0x{:X}, signed object depth=0x{:X}; native TEXTURES prepared motion=0x{:X}, responsive=0x{:X}.", views[0], views[1],
                      reinterpret_cast<uintptr_t>(data->prepare.textures[2].Get()), reinterpret_cast<uintptr_t>(data->prepare.textures[3].Get())).c_str());
    }
  }
  ID3D11ShaderResourceView* display = data->resolved.Get();
  if (debug_view == 1) display = data->objects.surfaces[0].Get();
  else if (debug_view == 2) display = data->prepare.views[2].Get();
  else if (debug_view == 3) display = data->prepare.views[1].Get();
  else if (debug_view == 4) display = data->prepare.views[3].Get();
  else if (debug_view == 5) display = data->prepare.views[0].Get();
  if (!display) display = data->resolved.Get();
  if (!data->prepare.Blit(context.Get(), display,
                          target.Get(), target_desc.Width, target_desc.Height,
                          debug_vectors ? data->objects.surfaces[1].Get() : nullptr, debug_vectors, debug_view)) return true;
  data->last_resolve = data->frame;
  data->last_time = now;
  if (upscale_engine::active) upscale_engine::active->reconstructed = true;
  if (upscale && data->logged_resolution != upscale->plan) {
    data->logged_resolution = upscale->plan;
    reshade::log::message(reshade::log::level::info,
        std::format("Witcher Classic: DLSS quality {} rendered subrect {}x{} in {}x{} native pool; reconstructed {}x{} before final grading.",
                    upscale->plan.quality, render_width, render_height, source_desc.Width, source_desc.Height,
                    target_desc.Width, target_desc.Height).c_str());
  }
  status = data->dlss.status;
  if (objects) status = std::format("DLAA: {} skinned, {} face, {} rigid, {} foliage draws; {} previous poses", data->objects.skinned_draws, data->objects.deformed_draws, data->objects.rigid_draws, data->objects.foliage_draws, data->objects.matched_allocations);
  else if (object_motion != 0.f) status = std::format("DLAA: 0 object draws ({}, HRESULT 0x{:08X})", data->objects.rejection, uint32_t(data->objects.error));
  if (data->dlss.preset_fallback) status += "; requested model unavailable, using runtime default";
  if (upscale) status = std::format("DLSS {} x {} -> {} x {}; {} object draws{}", render_width, render_height,
      target_desc.Width, target_desc.Height, data->objects.draws,
      data->dlss.preset_fallback ? "; runtime default model" : "");
  if (objects && data->objects.matched_allocations && !data->logged_objects) {
    data->logged_objects = true;
    reshade::log::message(reshade::log::level::info,
        std::format("Witcher Classic: skinned object motion active: {} G-buffer draws, {} previous allocation poses.", data->objects.draws, data->objects.matched_allocations).c_str());
  }
  if (objects && data->objects.target_reuses > 10 && !data->logged_target_reuse) {
    data->logged_target_reuse = true;
    reshade::log::message(reshade::log::level::info,
        std::format("Witcher Classic: retained motion attachments across {} of {} foliage draws.", data->objects.target_reuses, data->objects.foliage_draws).c_str());
  }
  if (objects && data->constant_profile_frames < 64 && ++data->constant_profile_frames == 64) {
    reshade::log::message(reshade::log::level::info,
        std::format("Witcher Classic: constant history uploads={}, unchanged={}, GPU fallback copies={}.",
                    data->objects.uploads.uploaded, data->objects.uploads.unchanged, data->objects.uploads.copied).c_str());
  }
  if (!data->logged) {
    data->logged = true;
    reshade::log::message(reshade::log::level::info,
        std::format("Witcher Classic: native DX11 DLAA active at {}x{}, first jitter=({}, {}). Object motion {} (coverage under validation).", source_desc.Width, source_desc.Height, jitter[0], jitter[1], object_motion != 0.f ? "enabled" : "disabled").c_str());
  }
  if (objects && data->objects.deformed_draws && !data->logged_deformed) {
    data->logged_deformed = true;
    reshade::log::message(reshade::log::level::info, "Witcher Classic: CPU-deformed face motion draws active; coverage under validation.");
  }
  if (objects && data->objects.rigid_draws && !data->logged_rigid) {
    data->logged_rigid = true;
    reshade::log::message(reshade::log::level::info, "Witcher Classic: moving rigid-instance motion draws active; coverage and lifetime under validation.");
  }
  return false;
}

inline void OnPresent(reshade::api::command_queue*, reshade::api::swapchain* swapchain,
                      const reshade::api::rect*, const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  auto* device = swapchain->get_device();
  auto* data = renodx::utils::data::Get<DeviceData>(device);
  if (!data) return;
  if (data->motion_context) data->objects.ClosePass(data->motion_context.Get());
  if (mode == 0.f) {
    upscale_engine::Disable(true);
    object_engine::Disable();
    renodx::utils::data::Delete<DeviceData>(device);
    status = "Native TAA";
    resolution_status.clear();
    return;
  }
  if (!data->swapchain) data->swapchain = swapchain;
  if (data->swapchain == swapchain) {
    const auto selected_quality = static_cast<size_t>(std::clamp(quality, 0.f, 4.f));
    if (data->ready && data->last_resolve == data->frame && object_engine::state->installed) {
      const auto& resolution = data->render_resolutions[selected_quality];
      upscale_engine::Publish({resolution.width, resolution.height, data->planned_output_width,
                              data->planned_output_height, static_cast<uint32_t>(selected_quality)});
    } else upscale_engine::Disable(selected_quality == 0);
    {
      std::lock_guard lock(upscale_engine::state->mutex);
      if (upscale_engine::state->failed)
        status = "Upscaling stopped: scene/TAA boundary failed validation. Select DLAA, then turn DLSS off and on to retry.";
    }
    ++data->frame;
    object_engine::state->frame.store(data->frame, std::memory_order_relaxed);
  }
}
inline void OnDestroySwapchain(reshade::api::swapchain* swapchain, bool) {
  upscale_engine::Disable();
  auto* data = renodx::utils::data::Get<DeviceData>(swapchain->get_device());
  if (data && data->swapchain == swapchain) {
    data->swapchain = nullptr;
    data->last_resolve = UINT64_MAX;
  }
}
inline void OnDestroyDevice(reshade::api::device* device) {
  upscale_engine::Disable();
  object_engine::Disable();
  if (renodx::utils::data::Get<DeviceData>(device)) renodx::utils::data::Delete<DeviceData>(device);
  if (renodx::utils::data::Get<MotionCapabilities>(device)) renodx::utils::data::Delete<MotionCapabilities>(device);
}
inline void Use(DWORD reason) {
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::init_command_list>(OnMotionCommandList);
    reshade::register_event<reshade::addon_event::map_buffer_region>(OnMotionMap);
    reshade::register_event<reshade::addon_event::unmap_buffer_region>(OnMotionUnmap);
    reshade::register_event<reshade::addon_event::update_buffer_region>(OnMotionUpdate);
    reshade::register_event<reshade::addon_event::update_buffer_region_command>(OnMotionDeferredUpdate);
    reshade::register_event<reshade::addon_event::copy_resource>(OnMotionCopy);
    reshade::register_event<reshade::addon_event::copy_buffer_region>(OnMotionBufferCopy);
    reshade::register_event<reshade::addon_event::execute_secondary_command_list>(OnMotionExecute);
    renodx::utils::command_action::Register(ObjectDrawBoundary, {.command_types = renodx::utils::command_action::COMMAND_TYPE_DIRECT_DRAW
        | renodx::utils::command_action::COMMAND_TYPE_DISPATCH | renodx::utils::command_action::COMMAND_TYPE_INDIRECT});
    for (const auto& shader : OBJECT_VERTEX_SHADERS) {
      renodx::utils::command_action::Register(ObjectDrawPost, {.shader_hash = shader.hash, .command_types = renodx::utils::command_action::COMMAND_TYPE_DIRECT_DRAW | renodx::utils::command_action::COMMAND_TYPE_INDIRECT});
    }
    reshade::register_event<reshade::addon_event::present>(OnPresent);
    reshade::register_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::init_command_list>(OnMotionCommandList);
    reshade::unregister_event<reshade::addon_event::map_buffer_region>(OnMotionMap);
    reshade::unregister_event<reshade::addon_event::unmap_buffer_region>(OnMotionUnmap);
    reshade::unregister_event<reshade::addon_event::update_buffer_region>(OnMotionUpdate);
    reshade::unregister_event<reshade::addon_event::update_buffer_region_command>(OnMotionDeferredUpdate);
    reshade::unregister_event<reshade::addon_event::copy_resource>(OnMotionCopy);
    reshade::unregister_event<reshade::addon_event::copy_buffer_region>(OnMotionBufferCopy);
    reshade::unregister_event<reshade::addon_event::execute_secondary_command_list>(OnMotionExecute);
    upscale_engine::Disable();
    renodx::utils::command_action::Unregister(ObjectDrawPost);
    renodx::utils::command_action::Unregister(ObjectDrawBoundary);
    reshade::unregister_event<reshade::addon_event::present>(OnPresent);
    reshade::unregister_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
  }
}
}  // namespace witcher3classic::temporal
