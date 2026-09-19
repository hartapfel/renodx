/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <atomic>
#include <filesystem>
#include <mutex>
#include <sl.h>
#include <sl_dlss_g.h>
#include <sl_dlss.h>
#include <sl_reflex.h>
#include <sl_security.h>
#include "./fg_camera.hpp"
#include "./fg_import.hpp"
#include "./display_policy.hpp"

namespace acbrotherhood::frame_generation {
inline std::atomic<uint32_t> api_error = 0;
inline void OnAPIError(const sl::APIError& error) {
  if (FAILED(error.hres)) api_error = uint32_t(error.hres);
}

// Streamline lives exclusively in the x64 presenter. No interposer, NVAPI
// hooks or plugin DLLs are loaded into the 32-bit game.
struct Streamline {
  HMODULE module = nullptr;
  bool initialized = false, ready = false, generating = false, render_started = false, paced = false;
  bool generation_loaded = false, generation_ready = false, vsync_supported = false;
  bool dlaa_ready = false;
  uint32_t dlaa_error = 0;
  PFun_slDLSSSetOptions* dlaa_options = nullptr;
  PFun_slEvaluateFeature* evaluate = nullptr;
  PFun_slFreeResources* free_resources = nullptr;
  uint32_t reflex_error = 0, applied_mode = UINT32_MAX, applied_limit = UINT32_MAX;
  uint32_t error = 0, frame_id = 0;
  uint32_t maximum_frames = 0, configured_frames = 0;
  uint32_t presented_multiplier = 1;
  sl::FrameToken* token = nullptr;
  const sl::ViewportHandle viewport{0};
  std::ofstream* log = nullptr;
  presentation::DisplayPolicy* display = nullptr;
  Microsoft::WRL::ComPtr<ID3D12Device> keep_device;
  Microsoft::WRL::ComPtr<IDXGIFactory4> keep_factory;
  PFun_slInit* init = nullptr;
  PFun_slShutdown* shutdown = nullptr;
  PFun_slIsFeatureSupported* supported = nullptr;
  PFun_slSetD3DDevice* set_device = nullptr;
  PFun_slGetFeatureFunction* feature_function = nullptr;
  PFun_slGetNewFrameToken* new_token = nullptr;
  PFun_slSetTagForFrame* set_tags = nullptr;
  PFun_slSetConstants* set_constants = nullptr;
  PFun_slDLSSGSetOptions* set_options = nullptr;
  PFun_slDLSSGGetState* get_state = nullptr;
  PFun_slReflexSetOptions* reflex_options = nullptr;
  PFun_slReflexSleep* sleep = nullptr;
  PFun_slReflexGetState* reflex_state = nullptr;
  PFun_slPCLSetMarker* marker = nullptr;
  decltype(&CreateDXGIFactory2) create_factory = &CreateDXGIFactory2;
  decltype(&D3D12CreateDevice) create_device = &D3D12CreateDevice;

  ~Streamline() {
    Shutdown();
    // These interfaces can have vtables owned by the interposer DLL.
    keep_device.Reset(); keep_factory.Reset();
    if (module) FreeLibrary(module);
  }
  void Pause() {
    if (!set_options) return;
    sl::DLSSGOptions off{};
    off.flags = sl::DLSSGFlags::eRetainResourcesWhenOff;
    if (!Accept(set_options(viewport, off)))
      throw presentation::Failure{presentation::Stage::present, error};
    generating = false;
    presented_multiplier = 1;
  }
  void Shutdown() {
    if (!initialized) return;
    if (set_options) { sl::DLSSGOptions off{}; set_options(viewport, off); }
    shutdown();
    initialized = ready = generating = false;
  }
  bool Accept(sl::Result result) {
    if (result == sl::Result::eOk) return true;
    error = uint32_t(result);
    if (log) *log << "Streamline error=" << error << " frame=" << frame_id << std::endl;
    return false;
  }
  template<class F> bool Export(F** target, const char* name) {
    *target = reinterpret_cast<F*>(GetProcAddress(module, name));
    if (*target) return true;
    error = ERROR_PROC_NOT_FOUND; return false;
  }
  template<class F> bool Feature(sl::Feature feature, F** target, const char* name) {
    void* address = nullptr;
    if (!Accept(feature_function(feature, name, address)) || !address) return false;
    *target = reinterpret_cast<F*>(address); return true;
  }
  void Initialize(bool requested, std::ofstream* output) {
    log = output;
    generation_loaded = requested;
    wchar_t executable[32768]{};
    if (!GetModuleFileNameW(nullptr, executable, DWORD(std::size(executable)))) { error = GetLastError(); return; }
    const auto directory = std::filesystem::path(executable).parent_path() / L"streamline";
    const auto interposer = directory / L"sl.interposer.dll";
    if (!std::filesystem::is_regular_file(interposer)) { error = ERROR_MOD_NOT_FOUND; return; }
    if (!sl::security::verifyEmbeddedSignature(interposer.c_str())) { error = TRUST_E_NOSIGNATURE; return; }
    module = LoadLibraryExW(interposer.c_str(), nullptr, LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR | LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
    if (!module) { error = GetLastError(); return; }
    if (!Export(&init, "slInit") || !Export(&shutdown, "slShutdown")
        || !Export(&supported, "slIsFeatureSupported") || !Export(&set_device, "slSetD3DDevice")
        || !Export(&feature_function, "slGetFeatureFunction") || !Export(&new_token, "slGetNewFrameToken")
        || !Export(&set_tags, "slSetTagForFrame") || !Export(&set_constants, "slSetConstants")) return;
    const wchar_t* plugins[] = {directory.c_str()};
    const sl::Feature features[] = {sl::kFeatureReflex, sl::kFeaturePCL, sl::kFeatureDLSS, sl::kFeatureDLSS_G};
    sl::Preferences preferences{};
    preferences.pathsToPlugins = plugins; preferences.numPathsToPlugins = 1;
    preferences.featuresToLoad = features; preferences.numFeaturesToLoad = requested ? 4 : 3;
    preferences.pathToLogsAndData = directory.c_str();
    preferences.engine = sl::EngineType::eCustom; preferences.engineVersion = "RenoDX Brotherhood DX12 1";
    preferences.projectId = "3ad1c215-850f-4111-bcf4-5b7a4364600e";
    preferences.flags = sl::PreferenceFlags::eDisableCLStateTracking | sl::PreferenceFlags::eUseDXGIFactoryProxy
        | sl::PreferenceFlags::eUseFrameBasedResourceTagging;
    if (!Accept(init(preferences, sl::kSDKVersion))) return;
    initialized = true;
    if (!Export(&create_factory, "CreateDXGIFactory2") || !Export(&create_device, "D3D12CreateDevice")) {
      Shutdown(); create_factory = &CreateDXGIFactory2; create_device = &D3D12CreateDevice;
    }
  }
  void Attach(ID3D12Device* device, IDXGIFactory4* factory, LUID adapter) {
    if (!initialized) return;
    keep_device = device; keep_factory = factory;
    sl::AdapterInfo info{}; info.deviceLUID = reinterpret_cast<uint8_t*>(&adapter); info.deviceLUIDSizeInBytes = sizeof(adapter);
    if (!Accept(set_device(device))) return;
    // DLAA capability is independent of Reflex/FG. Keep its optional failure
    // out of FG's error latch so unsupported AA never disables presentation.
    dlaa_ready = Accept(supported(sl::kFeatureDLSS, info))
        && Feature(sl::kFeatureDLSS, &dlaa_options, "slDLSSSetOptions")
        && Export(&evaluate, "slEvaluateFeature") && Export(&free_resources, "slFreeResources");
    dlaa_error = dlaa_ready ? 0 : error;
    error = 0;
    if (!Accept(supported(sl::kFeatureReflex, info)) || !Accept(supported(sl::kFeaturePCL, info))
        || !Feature(sl::kFeatureReflex, &reflex_options, "slReflexSetOptions")
        || !Feature(sl::kFeatureReflex, &sleep, "slReflexSleep")
        || !Feature(sl::kFeatureReflex, &reflex_state, "slReflexGetState")
        || !Feature(sl::kFeaturePCL, &marker, "slPCLSetMarker")) { reflex_error = error; return; }
    sl::ReflexState state{};
    sl::ReflexOptions options{}; options.mode = sl::ReflexMode::eLowLatency;
    ready = Accept(reflex_options(options)) && Accept(reflex_state(state)) && state.lowLatencyAvailable;
    if (!ready) { if (!error) error = ERROR_NOT_SUPPORTED; reflex_error = error; }
    if (ready && generation_loaded)
      generation_ready = Accept(supported(sl::kFeatureDLSS_G, info))
          && Feature(sl::kFeatureDLSS_G, &set_options, "slDLSSGSetOptions")
          && Feature(sl::kFeatureDLSS_G, &get_state, "slDLSSGGetState");
    *log << "Reflex initialized=" << ready << " DLSS-G initialized=" << generation_ready << " error=" << error << std::endl;
  }
  void ConfigurePacing(presentation::Packet* packet) {
    packet->pacing_state = presentation::CalculatePacing(packet->pacing, generation_ready ? packet->generation_requested : 0,
        maximum_frames, packet->sync_interval);
    packet->pacing_state.driver_multiplier = presented_multiplier;
    packet->pacing_state.driver_interval_us = presentation::ReflexInterval(packet->pacing_state.interval_us, presented_multiplier);
    if (display) display->Apply(packet);
    if (ready && (applied_mode != packet->pacing_state.mode || applied_limit != packet->pacing_state.driver_interval_us)) {
      sl::ReflexOptions options{};
      options.mode = sl::ReflexMode(packet->pacing_state.mode);
      options.frameLimitUs = packet->pacing_state.driver_interval_us;
      if (Accept(reflex_options(options))) {
        applied_mode = packet->pacing_state.mode; applied_limit = options.frameLimitUs;
        *log << "Reflex mode=" << applied_mode << " intervalUs=" << applied_limit
             << " renderCap=" << packet->pacing.render_fps << " multiplier=" << packet->pacing_state.multiplier
             << " driverMultiplier=" << presented_multiplier
             << " sync=" << packet->pacing_state.sync_interval
             << " vrr=" << (display && display->vrr) << " refresh=" << (display ? display->refresh_hz : 0) << std::endl;
      } else { reflex_error = error; Pause(); ready = false; }
    }
    packet->pacing_state.available = ready;
    packet->pacing_state.error = ready ? 0 : reflex_error ? reflex_error : error;
    packet->reflex_active = ready && packet->pacing_state.mode != 0;
  }
  void Mark(sl::PCLMarker value) {
    if (ready && token && !Accept(marker(value, *token)))
      throw presentation::Failure{presentation::Stage::present, error};
  }
  void Begin(uint32_t frame, bool before_game) {
    if (!initialized || frame == frame_id) return;
    frame_id = frame; token = nullptr; render_started = false; paced = before_game;
    if (!Accept(new_token(token, &frame_id)) || !token || (ready && !Accept(sleep(*token)))) {
      reflex_error = error; Pause(); ready = false; return;
    }
    Mark(sl::PCLMarker::eSimulationStart);
  }
  void RenderBegin() {
    if (!token || render_started) return;
    Mark(sl::PCLMarker::eSimulationEnd); Mark(sl::PCLMarker::eRenderSubmitStart);
    render_started = true;
  }
  void Prepare(presentation::Packet* packet, const std::array<ImportedImage, 3>& images) {
    packet->generation_error = error;
    packet->generated_present_count = 0;
    packet->generation_max = maximum_frames;
    packet->generation_configured = 0;
    const bool measured_frame = frame_id == packet->frame && paced && render_started;
    Begin(uint32_t(packet->frame), false); RenderBegin();
    if (!packet->generation_requested || !ready || !generation_ready) {
      if (generating) Pause();
      packet->generation_status = packet->generation_requested ? Status::unsupported : Status::off;
      Mark(sl::PCLMarker::eRenderSubmitEnd); Mark(sl::PCLMarker::ePresentStart);
      return;
    }
    Status state = Status::waiting;
    sl::Constants constants{};
    if (!maximum_frames) state = Status::waiting;
    else if (packet->generation_requested > maximum_frames) state = Status::multiplier_unsupported;
    else if (packet->pacing_state.sync_interval && (!vsync_supported || packet->pacing_state.sync_interval > 1)) state = Status::vsync;
    else if (packet->pause_flags & window_inactive) state = Status::inactive;
    else if (packet->pause_flags & window_resizing) state = Status::resizing;
    else if (packet->pause_flags & effects_rendered) state = Status::effects;
    else if ((packet->accepted_inputs & 7) != 7
             || (packet->format != DXGI_FORMAT_R10G10B10A2_UNORM
                 && packet->format != DXGI_FORMAT_B8G8R8A8_UNORM && packet->format != DXGI_FORMAT_R8G8B8A8_UNORM)) state = Status::inputs;
    else if (!CameraConstants(packet->inputs, &constants)) state = Status::camera;
    else if (!measured_frame) state = Status::timing;
    bool enable = state == Status::waiting && maximum_frames != 0;
    if (api_error.load()) { error = api_error.load(); enable = false; state = Status::failed; }
    if (enable) {
      constants.reset = packet->inputs.reset || !generating || configured_frames != packet->generation_requested
          ? sl::eTrue : sl::eFalse;
      enable = Accept(set_constants(constants, *token, viewport));
    }
    sl::Extent extent{0, 0, packet->width, packet->height};
    sl::Resource motion{sl::ResourceType::eTex2d, images[0].texture.Get(), D3D12_RESOURCE_STATE_COMMON};
    sl::Resource depth{sl::ResourceType::eTex2d, images[1].texture.Get(), D3D12_RESOURCE_STATE_COMMON};
    sl::Resource hudless{sl::ResourceType::eTex2d, images[2].texture.Get(), D3D12_RESOURCE_STATE_COMMON};
    const sl::ResourceTag tags[] = {
        {enable ? &motion : nullptr, sl::kBufferTypeMotionVectors, sl::ResourceLifecycle::eValidUntilPresent, &extent},
        {enable ? &depth : nullptr, sl::kBufferTypeDepth, sl::ResourceLifecycle::eValidUntilPresent, &extent},
        {enable ? &hudless : nullptr, sl::kBufferTypeHUDLessColor, sl::ResourceLifecycle::eValidUntilPresent, &extent},
        {nullptr, sl::kBufferTypeBackbuffer, sl::ResourceLifecycle::eValidUntilPresent, &extent}};
    if (!Accept(set_tags(*token, viewport, tags, uint32_t(std::size(tags)), nullptr))) enable = false;
    sl::DLSSGOptions options{};
    options.mode = enable ? sl::DLSSGMode::eOn : sl::DLSSGMode::eOff;
    options.numFramesToGenerate = enable ? packet->generation_requested : 1;
    options.flags = sl::DLSSGFlags::eRetainResourcesWhenOff;
    options.numBackBuffers = 2; options.colorWidth = options.mvecDepthWidth = packet->width;
    options.colorHeight = options.mvecDepthHeight = packet->height;
    options.colorBufferFormat = options.hudLessBufferFormat = packet->format;
    options.mvecBufferFormat = DXGI_FORMAT_R16G16B16A16_FLOAT; options.depthBufferFormat = DXGI_FORMAT_R32_FLOAT;
    // Use the final image and HUD-less input consistently. Partial UI masks
    // used to toggle this option during gameplay and cause pacing hitches.
    options.uiBufferFormat = DXGI_FORMAT_UNKNOWN;
    options.enableUserInterfaceRecomposition = sl::eFalse;
    options.onErrorCallback = OnAPIError;
    if (!Accept(set_options(viewport, options)))
      throw presentation::Failure{presentation::Stage::present, error};
    if (error) state = Status::failed;
    generating = enable;
    if (enable) configured_frames = packet->generation_requested;
    packet->generation_configured = enable ? configured_frames : 0;
    packet->generation_error = error; packet->generation_status = state;
    Mark(sl::PCLMarker::eRenderSubmitEnd);
    Mark(sl::PCLMarker::ePresentStart);
  }
  void AfterPresent(presentation::Packet* packet, ID3D12CommandQueue* queue) {
    Mark(sl::PCLMarker::ePresentEnd);
    if (!get_state) { packet->generated_present_count = 1; return; }
    sl::DLSSGState state{};
    if (!Accept(get_state(viewport, state, nullptr))) {
      // Cannot prove input lifetime on query failure: terminate this helper
      // instead of acknowledging reuse of textures still owned by DLSS-G.
      throw presentation::Failure{presentation::Stage::gpu_wait, error};
    }
    if (state.inputsProcessingCompletionFence && state.lastPresentInputsProcessingCompletionFenceValue)
      presentation::Check(queue->Wait(static_cast<ID3D12Fence*>(state.inputsProcessingCompletionFence),
          state.lastPresentInputsProcessingCompletionFenceValue), presentation::Stage::gpu_wait);
    packet->generated_present_count = state.numFramesActuallyPresented;
    presented_multiplier = generating ? std::clamp(state.numFramesActuallyPresented, 1u, 6u) : 1;
    maximum_frames = state.numFramesToGenerateMax;
    vsync_supported = state.bIsVsyncSupportAvailable == sl::Boolean::eTrue;
    packet->generation_max = maximum_frames;
    if (state.status != sl::DLSSGStatus::eOk) {
      error = 0x80000000u | uint32_t(state.status);
      sl::DLSSGOptions off{}; set_options(viewport, off); generating = generation_ready = false;
      packet->generation_status = Status::failed;
    } else if (generating && state.numFramesActuallyPresented > 1) packet->generation_status = Status::active;
    packet->generation_error = error;
  }
};
}
