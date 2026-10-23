/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once

#include <d3d11_1.h>
#include <dxgi.h>
#include <nvsdk_ngx.h>
#include <nvsdk_ngx_helpers.h>
#include <wrl/client.h>

#include <cmath>
#include <cstdint>
#include <filesystem>
#include <string>
#include "./context.hpp"

namespace witcher3classic::temporal {
using Microsoft::WRL::ComPtr;

// NGX ABI preset values. C remains a request for older runtimes; newer ones
// can select their default. Do not gate presets on DLL file-version metadata.
inline constexpr unsigned int MODEL_PRESETS[] = {11, 10, 12, 13, 3};
inline constexpr NVSDK_NGX_PerfQuality_Value QUALITY_MODES[] = {
    NVSDK_NGX_PerfQuality_Value_DLAA, NVSDK_NGX_PerfQuality_Value_MaxQuality,
    NVSDK_NGX_PerfQuality_Value_Balanced, NVSDK_NGX_PerfQuality_Value_MaxPerf,
    NVSDK_NGX_PerfQuality_Value_UltraPerformance};

struct RenderResolution {
  uint32_t width = 0, height = 0;
  uint32_t min_width = 0, min_height = 0, max_width = 0, max_height = 0;
};

// GPU resources belong to the same native device/context as the game. Motion
// is undilated, unjittered previousUV-currentUV; jitter is right/down pixels.
struct DlssInputs {
  ID3D11Texture2D* color = nullptr;
  ID3D11Texture2D* depth = nullptr;
  ID3D11Texture2D* motion = nullptr;
  ID3D11Texture2D* responsive = nullptr;
  uint32_t width = 0, height = 0;
  uint32_t output_width = 0, output_height = 0;
  float jitter_x = 0, jitter_y = 0;
  float frame_ms = 16.667f;
  uint64_t frame_id = 0;
  bool reset = true;
  bool depth_inverted = true;
  // An unverified camera-only vector field must not silently become DLSS.
  bool motion_validated = false;
  bool development_inputs = false;
  unsigned int render_preset = 0;
  NVSDK_NGX_PerfQuality_Value quality = NVSDK_NGX_PerfQuality_Value_DLAA;
};

class Dlss {
 public:
  uint32_t error = 0;
  const char* status = "Native TAA";
  ComPtr<ID3D11Texture2D> output;
  bool preset_fallback = false;

  // Call when output size or quality changes, before configuring scene rendering.
  // Query the installed runtime rather than assuming fixed scaling percentages.
  bool GetRenderResolution(uint32_t width, uint32_t height, NVSDK_NGX_PerfQuality_Value quality,
                           RenderResolution* resolution) {
    if (!parameters_ || !resolution || !width || !height || width > 8192 || height > 8192) return false;
    *resolution = {};
    float sharpness = 0;
    const auto result = NGX_DLSS_GET_OPTIMAL_SETTINGS(parameters_, width, height, quality,
        &resolution->width, &resolution->height, &resolution->max_width, &resolution->max_height,
        &resolution->min_width, &resolution->min_height, &sharpness);
    return NVSDK_NGX_SUCCEED(result) && resolution->width && resolution->height
           && resolution->width <= width && resolution->height <= height
           && resolution->min_width <= resolution->width && resolution->min_height <= resolution->height
           && resolution->max_width >= resolution->width && resolution->max_height >= resolution->height;
  }

  Dlss() = default;
  Dlss(const Dlss&) = delete;
  Dlss& operator=(const Dlss&) = delete;
  ~Dlss() { Shutdown(); }

  bool Initialize(ID3D11Device* device, const std::filesystem::path& directory) {
    if (device_.Get() == device && parameters_ && !failed_) return true;
    if (failed_) return false;
    Shutdown();
    ComPtr<IDXGIDevice> dxgi;
    ComPtr<IDXGIAdapter> adapter;
    DXGI_ADAPTER_DESC desc = {};
    if (FAILED(device->QueryInterface(IID_PPV_ARGS(&dxgi))) || FAILED(dxgi->GetAdapter(&adapter))
        || FAILED(adapter->GetDesc(&desc)) || desc.VendorId != 0x10de) {
      status = "DLSS requires a supported NVIDIA GPU";
      failed_ = true;
      return false;
    }
    const auto hr = CreateIsolatedState(device, &isolated_);
    if (FAILED(hr)) return Fail(hr, "Could not create isolated DLSS state");
    device_ = device;
    const std::wstring path = directory.wstring();
    const wchar_t* paths[] = {path.c_str()};
    NVSDK_NGX_FeatureCommonInfo info = {};
    info.PathListInfo.Length = 1;
    info.PathListInfo.Path = paths;
    auto result = NVSDK_NGX_D3D11_Init_with_ProjectID(
        "8005c254-f2a7-4f7d-9e06-ac8bdbf208f9", NVSDK_NGX_ENGINE_TYPE_CUSTOM,
        "RenoDX Witcher 3 Classic 1", path.c_str(), device, &info, NVSDK_NGX_Version_API);
    if (NVSDK_NGX_FAILED(result)) return Fail(result, "NGX initialization failed");
    initialized_ = true;
    result = NVSDK_NGX_D3D11_GetCapabilityParameters(&parameters_);
    if (NVSDK_NGX_FAILED(result) || !parameters_) return Fail(result, "NGX capability query failed");
    int available = 0;
    parameters_->Get(NVSDK_NGX_Parameter_SuperSampling_Available, &available);
    if (!available) return Fail(NVSDK_NGX_Result_FAIL_FeatureNotSupported, "DLSS is unavailable on this device/driver");
    status = "DLSS ready; waiting for validated inputs";
    return true;
  }

  // No CPU/GPU waits, resource sharing, helper process, or buffer readbacks.
  // The caller consumes output only after true, on this same ordered context.
  bool Evaluate(ID3D11DeviceContext1* context, const DlssInputs& inputs) {
    if (failed_ || !initialized_ || !parameters_) return false;
    if (!inputs.motion_validated && !inputs.development_inputs) { status = "Waiting for validated object motion"; return false; }
    if (!inputs.width || !inputs.height || !inputs.output_width || !inputs.output_height
        || inputs.width > 8192 || inputs.height > 8192 || inputs.output_width > 8192 || inputs.output_height > 8192
        || uint64_t{inputs.output_width} * inputs.output_height > 8388608
        || !std::isfinite(inputs.jitter_x) || !std::isfinite(inputs.jitter_y)
        || std::abs(inputs.jitter_x) > 1 || std::abs(inputs.jitter_y) > 1
        || !std::isfinite(inputs.frame_ms) || inputs.frame_ms <= 0 || inputs.frame_ms > 1000
        || !inputs.color || !inputs.depth || !inputs.motion) {
      status = "Invalid DLSS frame inputs";
      return false;
    }
    for (auto* resource : {inputs.color, inputs.depth, inputs.motion, inputs.responsive}) {
      if (!resource) continue;
      D3D11_TEXTURE2D_DESC desc;
      resource->GetDesc(&desc);
      if (!IsSameDevice(resource, device_.Get())) {
        status = "DLSS input belongs to a different native device";
        return false;
      }
      if (desc.Width != inputs.width || desc.Height != inputs.height
          || desc.SampleDesc.Count != 1 || desc.ArraySize != 1 || desc.MipLevels != 1
          || !(desc.BindFlags & D3D11_BIND_SHADER_RESOURCE)) {
        status = "DLSS input size, samples, mips or SRV flags mismatch";
        return false;
      }
    }
    if (!IsSameDevice(context, device_.Get()) || context->GetType() != D3D11_DEVICE_CONTEXT_IMMEDIATE) {
      status = "DLSS requires the owning immediate context";
      return false;
    }
    // Same full-context isolation used by Ezio's native DX11 encoder. Restore
    // every stage/CB/SRV/UAV/RT/IA state, including all failure exits.
    ContextScope restore(context, isolated_.Get());
    if (!feature_ || width_ != inputs.width || height_ != inputs.height
        || output_width_ != inputs.output_width || output_height_ != inputs.output_height
        || render_preset_ != inputs.render_preset || quality_ != inputs.quality || inverted_ != inputs.depth_inverted) {
      ReleaseFeature();
      D3D11_TEXTURE2D_DESC desc = {};
      desc.Width = inputs.output_width;
      desc.Height = inputs.output_height;
      desc.MipLevels = desc.ArraySize = desc.SampleDesc.Count = 1;
      desc.Format = DXGI_FORMAT_R16G16B16A16_FLOAT;
      desc.Usage = D3D11_USAGE_DEFAULT;
      desc.BindFlags = D3D11_BIND_UNORDERED_ACCESS | D3D11_BIND_SHADER_RESOURCE;
      const auto hr = device_->CreateTexture2D(&desc, nullptr, &output);
      if (FAILED(hr)) return Fail(hr, "DLSS output allocation failed");
      NVSDK_NGX_DLSS_Create_Params create = {};
      create.Feature.InWidth = inputs.width;
      create.Feature.InHeight = inputs.height;
      create.Feature.InTargetWidth = inputs.output_width;
      create.Feature.InTargetHeight = inputs.output_height;
      create.Feature.InPerfQualityValue = inputs.quality;
      create.InFeatureCreateFlags = NVSDK_NGX_DLSS_Feature_Flags_IsHDR
                                   | NVSDK_NGX_DLSS_Feature_Flags_MVLowRes
                                   | NVSDK_NGX_DLSS_Feature_Flags_AutoExposure;
      if (inputs.depth_inverted) create.InFeatureCreateFlags |= NVSDK_NGX_DLSS_Feature_Flags_DepthInverted;
      for (const auto* key : {NVSDK_NGX_Parameter_DLSS_Hint_Render_Preset_DLAA,
                              NVSDK_NGX_Parameter_DLSS_Hint_Render_Preset_Quality,
                              NVSDK_NGX_Parameter_DLSS_Hint_Render_Preset_Balanced,
                              NVSDK_NGX_Parameter_DLSS_Hint_Render_Preset_Performance,
                              NVSDK_NGX_Parameter_DLSS_Hint_Render_Preset_UltraPerformance})
        parameters_->Set(key, inputs.render_preset);
      auto result = NGX_D3D11_CREATE_DLSS_EXT(context, &feature_, parameters_, &create);
      preset_fallback = false;
      if ((NVSDK_NGX_FAILED(result) || !feature_) && inputs.render_preset != 0) {
        if (feature_) NVSDK_NGX_D3D11_ReleaseFeature(feature_);
        feature_ = nullptr;
        for (const auto* key : {NVSDK_NGX_Parameter_DLSS_Hint_Render_Preset_DLAA,
                                NVSDK_NGX_Parameter_DLSS_Hint_Render_Preset_Quality,
                                NVSDK_NGX_Parameter_DLSS_Hint_Render_Preset_Balanced,
                                NVSDK_NGX_Parameter_DLSS_Hint_Render_Preset_Performance,
                                NVSDK_NGX_Parameter_DLSS_Hint_Render_Preset_UltraPerformance})
          parameters_->Set(key, 0u);
        result = NGX_D3D11_CREATE_DLSS_EXT(context, &feature_, parameters_, &create);
        preset_fallback = NVSDK_NGX_SUCCEED(result) && feature_;
      }
      if (NVSDK_NGX_FAILED(result) || !feature_) return Fail(result, "DLSS feature creation failed");
      width_ = inputs.width; height_ = inputs.height;
      output_width_ = inputs.output_width; output_height_ = inputs.output_height;
      render_preset_ = inputs.render_preset;
      quality_ = inputs.quality; inverted_ = inputs.depth_inverted;
      history_valid_ = false;
    }
    NVSDK_NGX_D3D11_DLSS_Eval_Params eval = {};
    eval.Feature.pInColor = inputs.color;
    eval.Feature.pInOutput = output.Get();
    eval.pInDepth = inputs.depth;
    eval.pInMotionVectors = inputs.motion;
    eval.pInBiasCurrentColorMask = inputs.responsive;
    eval.InJitterOffsetX = inputs.jitter_x;
    eval.InJitterOffsetY = inputs.jitter_y;
    eval.InRenderSubrectDimensions.Width = inputs.width;
    eval.InRenderSubrectDimensions.Height = inputs.height;
    eval.InMVScaleX = static_cast<float>(inputs.width);
    eval.InMVScaleY = static_cast<float>(inputs.height);
    eval.InPreExposure = eval.InExposureScale = 1;
    eval.InFrameTimeDeltaInMsec = inputs.frame_ms;
    eval.InReset = inputs.reset || !history_valid_ || inputs.frame_id != previous_frame_ + 1;
    const auto result = NGX_D3D11_EVALUATE_DLSS_EXT(context, feature_, parameters_, &eval);
    if (NVSDK_NGX_FAILED(result)) return Fail(result, "DLSS evaluation failed");
    previous_frame_ = inputs.frame_id;
    history_valid_ = true;
    status = inputs.development_inputs ? "DLSS development; motion coverage under validation"
             : inputs.quality == NVSDK_NGX_PerfQuality_Value_DLAA ? "DLAA active" : "DLSS active";
    return true;
  }

  void Shutdown() {
    ReleaseFeature();
    if (parameters_) NVSDK_NGX_D3D11_DestroyParameters(parameters_);
    parameters_ = nullptr;
    if (initialized_) NVSDK_NGX_D3D11_Shutdown1(device_.Get());
    initialized_ = failed_ = false;
    isolated_.Reset(); device_.Reset();
    error = 0;
    status = "Native TAA";
  }

 private:
  ComPtr<ID3D11Device> device_;
  ComPtr<ID3DDeviceContextState> isolated_;
  NVSDK_NGX_Parameter* parameters_ = nullptr;
  NVSDK_NGX_Handle* feature_ = nullptr;
  uint32_t width_ = 0, height_ = 0, output_width_ = 0, output_height_ = 0;
  uint64_t previous_frame_ = 0;
  unsigned int render_preset_ = 0;
  NVSDK_NGX_PerfQuality_Value quality_ = NVSDK_NGX_PerfQuality_Value_DLAA;
  bool initialized_ = false, failed_ = false, inverted_ = true, history_valid_ = false;

  bool Fail(uint32_t code, const char* message) {
    error = code; status = message; failed_ = true;
    return false;
  }
  void ReleaseFeature() {
    if (feature_) NVSDK_NGX_D3D11_ReleaseFeature(feature_);
    feature_ = nullptr;
    output.Reset();
    width_ = height_ = output_width_ = output_height_ = 0;
    history_valid_ = false;
  }
};
}  // namespace witcher3classic::temporal
