/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d12.h>
#include <filesystem>
#if __has_include("../../../../bin/streamline-2.14.16/include/sl.h")
// Game-local SDK install, independent of the shared external/Streamline 2.8
// dependency. All transitive NVIDIA includes resolve inside this SDK.
#include "../../../../bin/streamline-2.14.16/include/sl.h"
#include "../../../../bin/streamline-2.14.16/include/sl_dlss_g.h"
#include "../../../../bin/streamline-2.14.16/include/sl_reflex.h"
#include "../../../../bin/streamline-2.14.16/include/sl_security.h"
#else
#include <sl.h>
#include <sl_dlss_g.h>
#include <sl_reflex.h>
#include <sl_security.h>
#endif
#include "./policy.hpp"

static_assert(SL_VERSION_MAJOR > 2 || (SL_VERSION_MAJOR == 2 && (SL_VERSION_MINOR > 14 || (SL_VERSION_MINOR == 14 && SL_VERSION_PATCH >= 16))),
              "Classic FG requires the official Streamline 2.14.16 SDK or newer, not the repository's 2.8 headers.");

namespace witcher3classic::frame_generation {
// Own one Session per process, outside DllMain. Keep it alive until AFTER all SL
// proxy interfaces have been released, and Shutdown BEFORE destroying devices.
struct Session {
  HMODULE module = nullptr;
  bool initialized = false;
  sl::Result result = sl::Result::eOk;
  DWORD loader_error = ERROR_SUCCESS;
  Capabilities capabilities{};
  const sl::ViewportHandle viewport{0};
  PFun_slInit* init = nullptr;
  PFun_slShutdown* shutdown = nullptr;
  PFun_slSetD3DDevice* set_device = nullptr;
  PFun_slIsFeatureSupported* supported = nullptr;
  PFun_slGetFeatureRequirements* requirements = nullptr;
  PFun_slGetFeatureFunction* function = nullptr;
  PFun_slUpgradeInterface* upgrade = nullptr;
  PFun_slGetNativeInterface* native = nullptr;
  PFun_slGetNewFrameToken* new_frame = nullptr;
  PFun_slSetConstants* constants = nullptr;
  PFun_slSetTagForFrame* tags = nullptr;
  PFun_slFreeResources* free_resources = nullptr;
  PFun_slDLSSGGetState* state = nullptr;
  PFun_slDLSSGSetOptions* options = nullptr;
  PFun_slReflexGetState* reflex_state = nullptr;
  PFun_slReflexSetOptions* reflex_options = nullptr;
  PFun_slReflexSleep* sleep = nullptr;
  PFun_slPCLSetMarker* marker = nullptr;
  PFun_slPCLGetState* pcl_state = nullptr;
  PFun_slPCLSetOptions* pcl_options = nullptr;

  Session() = default;
  Session(const Session&) = delete;
  Session& operator=(const Session&) = delete;
  ~Session() {
    Shutdown();
    if (module) FreeLibrary(module);
  }
  bool Accept(sl::Result value) {
    result = value;
    return value == sl::Result::eOk;
  }
  template <class F>
  bool Export(F** output, const char* name) {
    *output = reinterpret_cast<F*>(GetProcAddress(module, name));
    if (!*output) loader_error = ERROR_PROC_NOT_FOUND;
    return *output != nullptr;
  }
  template <class F>
  bool Feature(sl::Feature feature, F** output, const char* name) {
    void* address = nullptr;
    if (!Accept(function(feature, name, address)) || !address) return false;
    *output = reinterpret_cast<F*>(address);
    return true;
  }
  bool Load(const std::filesystem::path& directory, const std::filesystem::path& logs) {
    if (module || !directory.is_absolute() || !logs.is_absolute()) {
      loader_error = ERROR_INVALID_PARAMETER;
      return false;
    }
    // Never take over another mod's process-global Streamline session.
    if (GetModuleHandleW(L"sl.interposer.dll")) {
      loader_error = ERROR_ALREADY_EXISTS;
      return false;
    }
    if (!sl::security::verifyEmbeddedSignature((directory / L"sl.interposer.dll").c_str())) {
      loader_error = TRUST_E_NOSIGNATURE;
      return false;
    }
    module = LoadLibraryExW((directory / L"sl.interposer.dll").c_str(), nullptr,
                            LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR | LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
    if (!module) {
      loader_error = GetLastError();
      return false;
    }
    if (!Export(&init, "slInit") || !Export(&shutdown, "slShutdown") || !Export(&set_device, "slSetD3DDevice")
        || !Export(&supported, "slIsFeatureSupported") || !Export(&requirements, "slGetFeatureRequirements")
        || !Export(&function, "slGetFeatureFunction") || !Export(&upgrade, "slUpgradeInterface")
        || !Export(&native, "slGetNativeInterface") || !Export(&new_frame, "slGetNewFrameToken")
        || !Export(&constants, "slSetConstants") || !Export(&tags, "slSetTagForFrame")
        || !Export(&free_resources, "slFreeResources")) return false;
    const sl::Feature features[] = {sl::kFeatureDLSS_G, sl::kFeatureReflex, sl::kFeaturePCL};
    const wchar_t* paths[] = {directory.c_str()};
    sl::Preferences preferences{};
    preferences.featuresToLoad = features;
    preferences.numFeaturesToLoad = 3;
    preferences.pathsToPlugins = paths;
    preferences.numPathsToPlugins = 1;
    preferences.pathToLogsAndData = logs.c_str();
    preferences.projectId = "8005c254-f2a7-4f7d-9e06-ac8bdbf208f9";
    preferences.engine = sl::EngineType::eCustom;
    preferences.engineVersion = "RenoDX Witcher 3 Classic 1";
    preferences.renderAPI = sl::RenderAPI::eD3D12;
    preferences.flags = sl::PreferenceFlags::eUseManualHooking | sl::PreferenceFlags::eUseDXGIFactoryProxy
                        | sl::PreferenceFlags::eUseFrameBasedResourceTagging | sl::PreferenceFlags::eDisableCLStateTracking;
    initialized = Accept(init(preferences, sl::kSDKVersion));
    return initialized;
  }
  bool Attach(ID3D12Device* device) {
    if (!initialized || !device) return false;
    auto luid = device->GetAdapterLuid();
    sl::AdapterInfo adapter{};
    adapter.deviceLUID = reinterpret_cast<uint8_t*>(&luid);
    adapter.deviceLUIDSizeInBytes = sizeof(luid);
    if (!Accept(set_device(device)) || !Accept(supported(sl::kFeatureDLSS_G, adapter))
        || !Accept(supported(sl::kFeatureReflex, adapter)) || !Accept(supported(sl::kFeaturePCL, adapter))) return false;
    sl::FeatureRequirements required{};
    if (!Accept(requirements(sl::kFeatureDLSS_G, required))
        || !(required.flags & sl::FeatureRequirementFlags::eD3D12Supported)) return false;
    if (!Feature(sl::kFeatureDLSS_G, &state, "slDLSSGGetState")
        || !Feature(sl::kFeatureDLSS_G, &options, "slDLSSGSetOptions")
        || !Feature(sl::kFeatureReflex, &reflex_state, "slReflexGetState")
        || !Feature(sl::kFeatureReflex, &reflex_options, "slReflexSetOptions")
        || !Feature(sl::kFeatureReflex, &sleep, "slReflexSleep")
        || !Feature(sl::kFeaturePCL, &marker, "slPCLSetMarker")
        || !Feature(sl::kFeaturePCL, &pcl_state, "slPCLGetState")
        || !Feature(sl::kFeaturePCL, &pcl_options, "slPCLSetOptions")) return false;
    sl::DLSSGState fg{};
    sl::ReflexState reflex{};
    if (!Accept(state(viewport, fg, nullptr)) || !Accept(reflex_state(reflex))) return false;
    capabilities = {true, fg.bIsDynamicMFGSupported == sl::Boolean::eTrue, reflex.lowLatencyAvailable,
                    fg.numFramesToGenerateMax, fg.minWidthOrHeight};
    return true;
  }
  // Pure mapping for the presenter. Apply only on its Present thread, after
  // Resolve checks capabilities AND per-frame readiness. No frame multiplication
  // by guessed GPU model. Dynamic mode intentionally ignores fixed multipliers.
  static sl::DLSSGOptions Options(const Decision& decision) {
    sl::DLSSGOptions value{};
    switch (decision.mode) {
      case Mode::Off:     value.mode = sl::DLSSGMode::eOff; break;
      case Mode::Fixed:   value.mode = sl::DLSSGMode::eOn; break;
      case Mode::Auto:    value.mode = sl::DLSSGMode::eAuto; break;
      case Mode::Dynamic: value.mode = sl::DLSSGMode::eDynamic; break;
    }
    value.numFramesToGenerate = decision.generated ? decision.generated : 1;
    value.dynamicTargetFrameRate = decision.target_fps;
    value.enableUserInterfaceRecomposition = decision.recompose_ui ? sl::Boolean::eTrue : sl::Boolean::eFalse;
    value.flags = sl::DLSSGFlags::eRetainResourcesWhenOff;
    return value;
  }
  void Shutdown() {
    // Caller stops interpolation, drains queues, null-tags resources, frees FG
    // resources, then invokes this before destroying its D3D/DXGI objects.
    if (initialized) {
      Accept(shutdown());
      initialized = false;
      capabilities = {};
    }
  }
};
}  // namespace witcher3classic::frame_generation
