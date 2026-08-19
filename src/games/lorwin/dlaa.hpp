/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <array>
#include <atomic>
#include <cmath>
#include <cstdint>
#include <limits>
#include <mutex>
#include <shared_mutex>
#include <sstream>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

#include <d3d12.h>
#include <dxgi1_6.h>
#include <embed/shaders.h>
#include <Windows.h>
#include <include/reshade.hpp>
#include <nvsdk_ngx.h>
#include <nvsdk_ngx_helpers.h>
#include <wrl/client.h>

#include "../../mods/shader.hpp"
#include "../../utils/bitwise.hpp"
#include "../../utils/descriptor.hpp"
#include "../../utils/directx.hpp"
#include "../../utils/pipeline_layout.hpp"
#include "../../utils/resource.hpp"
#include "../../utils/state.hpp"
#include "jitter.hpp"
#include "resource_logger.hpp"
#include "shared.h"

namespace lorwin::dlaa {

struct Resources {
  reshade::api::device* device = nullptr;
  reshade::api::resource motion_vectors = {0u};
  reshade::api::resource_view motion_vectors_srv = {0u};
  reshade::api::resource_view motion_vectors_uav = {0u};
  uint32_t width = 0u;
  uint32_t height = 0u;
  reshade::api::pipeline_layout compute_layout = {0u};
  reshade::api::pipeline compute_pipeline = {0u};
  reshade::api::sampler linear_clamp_sampler = {0u};
  reshade::api::resource dlaa_input = {0u};
  reshade::api::resource_view dlaa_input_srv = {0u};
  reshade::api::resource dlaa_output = {0u};
  reshade::api::resource_view dlaa_output_srv = {0u};
  reshade::api::resource previous_color = {0u};
  reshade::api::resource_view previous_color_srv = {0u};
  reshade::api::resource bias_current_color_mask = {0u};
  reshade::api::resource_view bias_current_color_mask_srv = {0u};
  reshade::api::resource_view bias_current_color_mask_uav = {0u};
  reshade::api::pipeline_layout bias_mask_layout = {0u};
  reshade::api::pipeline bias_mask_pipeline = {0u};
  reshade::api::sampler bias_mask_sampler = {0u};
  uint32_t dlaa_width = 0u;
  uint32_t dlaa_height = 0u;
  reshade::api::format dlaa_format = reshade::api::format::unknown;
  reshade::api::resource_usage dlaa_input_state = reshade::api::resource_usage::undefined;
  reshade::api::resource_usage dlaa_output_state = reshade::api::resource_usage::undefined;
  reshade::api::resource_usage previous_color_state = reshade::api::resource_usage::undefined;
  reshade::api::resource_usage bias_mask_state = reshade::api::resource_usage::undefined;
  std::array<float, 2> previous_color_jitter = {};
  bool previous_color_valid = false;
};

struct __declspec(uuid("50df9126-a507-4d94-ac3e-af0d214388e5")) CommandListData {
  reshade::api::buffer_range pixel_cb_b0 = {};
  reshade::api::pipeline_layout pixel_cb_b0_layout = {0u};
};

struct PreviousComputeState {
  std::array<std::pair<reshade::api::pipeline_stage, reshade::api::pipeline>, 4> pipelines = {};
  uint32_t pipeline_count = 0u;
  reshade::api::pipeline_layout layout = {0u};
  std::vector<reshade::api::descriptor_table> descriptor_tables;
};

struct PreviousPipelineState {
  std::array<std::pair<reshade::api::pipeline_stage, reshade::api::pipeline>, 12> pipelines = {};
  uint32_t pipeline_count = 0u;
  reshade::api::pipeline_layout graphics_layout = {0u};
  reshade::api::pipeline_layout compute_layout = {0u};
  std::vector<reshade::api::descriptor_table> graphics_descriptor_tables;
  std::vector<reshade::api::descriptor_table> compute_descriptor_tables;
};

struct NgxRuntime {
  Microsoft::WRL::ComPtr<ID3D12Device> device;
  NVSDK_NGX_Parameter* parameters = nullptr;
  NVSDK_NGX_Handle* feature = nullptr;
  uint32_t width = 0u;
  uint32_t height = 0u;
  int render_preset = -1;
  int feature_flags = 0;
  bool initialized = false;
  bool init_failed = false;
  bool create_failed = false;
  bool eval_failed = false;
  bool logged_success = false;
};

inline Resources resources;
inline NgxRuntime ngx;
inline ShaderInjectData* shader_injection = nullptr;
inline std::mutex runtime_mutex;
inline std::shared_mutex resource_state_mutex;
inline std::unordered_map<uint64_t, reshade::api::resource_usage> resource_states;
inline uint64_t last_dispatch_frame = std::numeric_limits<uint64_t>::max();
inline uint64_t last_evaluation_frame = std::numeric_limits<uint64_t>::max();
inline uint64_t last_missing_input_log = std::numeric_limits<uint64_t>::max();
inline uint64_t last_failure_log = std::numeric_limits<uint64_t>::max();
inline reshade::api::resource last_source_resource = {0u};
inline std::atomic_bool reset_history = true;
inline float enabled = 0.f;
inline float render_preset = 0.f;
inline float motion_vector_axes = 3.f;
inline float motion_vector_scale = 1.f;
inline float motion_vector_dilation = 1.f;
inline float bias_current_color_mask = 1.f;
inline float bias_current_color_strength = 1.f;
inline float jitter_axes = 0.f;
inline float jitter_scale = 1.f;
inline float force_history_reset = 0.f;
inline bool is_nvidia_device = false;
inline reshade::api::device* detected_d3d12_device = nullptr;
inline int last_motion_vector_axes = -1;
inline int last_motion_vector_dilation = -1;
inline int last_bias_current_color_mask = -1;
inline int last_jitter_axes = -1;
inline int last_camera_jitter_pattern = -1;
inline float last_motion_vector_scale = std::numeric_limits<float>::quiet_NaN();
inline float last_bias_current_color_strength = std::numeric_limits<float>::quiet_NaN();
inline float last_camera_jitter_scale = std::numeric_limits<float>::quiet_NaN();
inline float last_jitter_scale = std::numeric_limits<float>::quiet_NaN();
inline bool installed_callbacks = false;
inline bool installed_events = false;

inline std::wstring GetProcessDirectory() {
  std::array<wchar_t, MAX_PATH> path = {};
  const DWORD length = GetModuleFileNameW(nullptr, path.data(), static_cast<DWORD>(path.size()));
  if (length == 0u || length >= path.size()) return L".";
  std::wstring result(path.data(), length);
  const auto separator = result.find_last_of(L"\\/");
  return separator == std::wstring::npos ? L"." : result.substr(0u, separator);
}

inline const char* ResultToString(NVSDK_NGX_Result result) {
  switch (result) {
    case NVSDK_NGX_Result_Success: return "Success";
    case NVSDK_NGX_Result_FAIL_FeatureNotSupported: return "FeatureNotSupported";
    case NVSDK_NGX_Result_FAIL_PlatformError: return "PlatformError";
    case NVSDK_NGX_Result_FAIL_FeatureAlreadyExists: return "FeatureAlreadyExists";
    case NVSDK_NGX_Result_FAIL_FeatureNotFound: return "FeatureNotFound";
    case NVSDK_NGX_Result_FAIL_InvalidParameter: return "InvalidParameter";
    case NVSDK_NGX_Result_FAIL_ScratchBufferTooSmall: return "ScratchBufferTooSmall";
    case NVSDK_NGX_Result_FAIL_NotInitialized: return "NotInitialized";
    case NVSDK_NGX_Result_FAIL_UnsupportedInputFormat: return "UnsupportedInputFormat";
    case NVSDK_NGX_Result_FAIL_RWFlagMissing: return "RWFlagMissing";
    case NVSDK_NGX_Result_FAIL_MissingInput: return "MissingInput";
    case NVSDK_NGX_Result_FAIL_UnableToInitializeFeature: return "UnableToInitializeFeature";
    case NVSDK_NGX_Result_FAIL_OutOfDate: return "OutOfDate";
    case NVSDK_NGX_Result_FAIL_OutOfGPUMemory: return "OutOfGPUMemory";
    case NVSDK_NGX_Result_FAIL_UnsupportedFormat: return "UnsupportedFormat";
    case NVSDK_NGX_Result_FAIL_UnableToWriteToAppDataPath: return "UnableToWriteToAppDataPath";
    case NVSDK_NGX_Result_FAIL_UnsupportedParameter: return "UnsupportedParameter";
    case NVSDK_NGX_Result_FAIL_Denied: return "Denied";
    case NVSDK_NGX_Result_FAIL_NotImplemented: return "NotImplemented";
    default: return "Unknown";
  }
}

inline int GetRenderPresetValue() {
  switch (static_cast<int>(render_preset)) {
    case 1: return static_cast<int>(NVSDK_NGX_DLSS_Hint_Render_Preset_J);
    case 2: return static_cast<int>(NVSDK_NGX_DLSS_Hint_Render_Preset_F);
    case 3: return static_cast<int>(NVSDK_NGX_DLSS_Hint_Render_Preset_L);
    case 4: return static_cast<int>(NVSDK_NGX_DLSS_Hint_Render_Preset_M);
    default: return static_cast<int>(NVSDK_NGX_DLSS_Hint_Render_Preset_K);
  }
}

inline const char* GetRenderPresetName(int preset) {
  switch (preset) {
    case static_cast<int>(NVSDK_NGX_DLSS_Hint_Render_Preset_J): return "J";
    case static_cast<int>(NVSDK_NGX_DLSS_Hint_Render_Preset_F): return "F";
    case static_cast<int>(NVSDK_NGX_DLSS_Hint_Render_Preset_L): return "L";
    case static_cast<int>(NVSDK_NGX_DLSS_Hint_Render_Preset_M): return "M";
    default: return "K";
  }
}

inline int GetFeatureFlags() {
  // Validated fixed configuration: standard depth, LDR color, camera vectors
  // without viewport jitter, and NGX auto exposure (no exposure texture).
  return NVSDK_NGX_DLSS_Feature_Flags_AutoExposure;
}

inline std::array<float, 2> GetAxisSigns(float axes) {
  switch (static_cast<int>(std::round(axes))) {
    case 1: return {-1.f, 1.f};
    case 2: return {1.f, -1.f};
    case 3: return {-1.f, -1.f};
    default: return {1.f, 1.f};
  }
}

inline std::string GetFeatureFlagsName(int flags) {
  std::string result;
  const auto append = [&](const char* name) {
    if (!result.empty()) result += '|';
    result += name;
  };
  if ((flags & NVSDK_NGX_DLSS_Feature_Flags_DepthInverted) != 0) append("DepthInverted");
  if ((flags & NVSDK_NGX_DLSS_Feature_Flags_MVJittered) != 0) append("MVJittered");
  if ((flags & NVSDK_NGX_DLSS_Feature_Flags_IsHDR) != 0) append("IsHDR");
  if ((flags & NVSDK_NGX_DLSS_Feature_Flags_AutoExposure) != 0) append("AutoExposure");
  return result.empty() ? "None" : result;
}

inline void DetectD3D12Adapter(reshade::api::device* device) {
  if (device == nullptr || device->get_api() != reshade::api::device_api::d3d12) return;
  if (detected_d3d12_device == device) return;

  int vendor_id = 0;
  bool retrieved = device->get_property(reshade::api::device_properties::vendor_id, &vendor_id);
  if (!retrieved || vendor_id == 0) {
    auto* native_device = reinterpret_cast<ID3D12Device*>(device->get_native());
    Microsoft::WRL::ComPtr<IDXGIFactory4> factory;
    Microsoft::WRL::ComPtr<IDXGIAdapter1> adapter;
    if (native_device != nullptr
        && SUCCEEDED(CreateDXGIFactory1(IID_PPV_ARGS(factory.ReleaseAndGetAddressOf())))
        && SUCCEEDED(factory->EnumAdapterByLuid(
            native_device->GetAdapterLuid(),
            IID_PPV_ARGS(adapter.ReleaseAndGetAddressOf())))) {
      DXGI_ADAPTER_DESC1 desc = {};
      if (SUCCEEDED(adapter->GetDesc1(&desc))) {
        vendor_id = static_cast<int>(desc.VendorId);
        retrieved = true;
      }
    }
  }

  detected_d3d12_device = device;
  is_nvidia_device = retrieved && vendor_id == 0x10de;
  std::stringstream s;
  s << "LORWIN DLAA: D3D12 adapter vendor=0x" << std::hex << static_cast<uint32_t>(vendor_id)
    << " NVIDIA=" << (is_nvidia_device ? "yes" : "no");
  reshade::log::message(reshade::log::level::info, s.str().c_str());
}

inline bool ShouldLog(uint64_t& last_frame, uint64_t interval = 120u) {
  const uint64_t current_frame = resource_logger::frame_index.load();
  if (last_frame != std::numeric_limits<uint64_t>::max() && current_frame - last_frame < interval) return false;
  last_frame = current_frame;
  return true;
}

inline CommandListData* Get(reshade::api::command_list* cmd_list) {
  if (cmd_list == nullptr) return nullptr;
  auto* data = cmd_list->get_private_data<CommandListData>();
  return data != nullptr ? data : cmd_list->create_private_data<CommandListData>();
}

inline bool ResolveRegister(
    reshade::api::pipeline_layout layout,
    uint32_t layout_param,
    const reshade::api::descriptor_table_update& update,
    uint32_t descriptor_index,
    uint32_t& register_index,
    uint32_t& register_space) {
  bool resolved = false;
  renodx::utils::pipeline_layout::GetPipelineLayoutData(
      layout,
      [&](const renodx::utils::pipeline_layout::PipelineLayoutData* layout_data) {
        if (layout_param >= layout_data->params.size()) return;

        const auto& param = layout_data->params[layout_param];
        const uint32_t binding = update.binding + descriptor_index;
        switch (param.type) {
          case reshade::api::pipeline_layout_param_type::push_descriptors:
            register_index = param.push_descriptors.dx_register_index + binding;
            register_space = param.push_descriptors.dx_register_space;
            resolved = true;
            return;
          case reshade::api::pipeline_layout_param_type::descriptor_table:
          case reshade::api::pipeline_layout_param_type::push_descriptors_with_ranges:
          case reshade::api::pipeline_layout_param_type::push_descriptors_with_static_samplers:
          case reshade::api::pipeline_layout_param_type::descriptor_table_with_static_samplers:
            break;
          default:
            return;
        }

        if (layout_param >= layout_data->ranges.size()) return;
        for (const auto& range : layout_data->ranges[layout_param]) {
          if (range.type != update.type) continue;
          const bool in_range = binding >= range.binding
                                && (range.count == UINT32_MAX || binding < range.binding + range.count);
          if (!in_range) continue;

          register_index = range.dx_register_index + (binding - range.binding);
          register_space = range.dx_register_space;
          resolved = true;
          return;
        }
      });
  return resolved;
}

inline reshade::api::buffer_range ReadPixelConstantBufferFromTables(
    reshade::api::command_list* cmd_list,
    bool table_relative_zero) {
  reshade::api::buffer_range result = {};
  auto* device = cmd_list != nullptr ? cmd_list->get_device() : nullptr;
  auto* state = cmd_list != nullptr ? renodx::utils::state::GetCurrentState(cmd_list) : nullptr;
  if (device == nullptr || state == nullptr || state->graphics_pipeline_layout.handle == 0u) return result;

  auto* descriptor_data = renodx::utils::data::Get<renodx::utils::descriptor::DeviceData>(device);
  if (descriptor_data == nullptr) return result;

  const std::shared_lock descriptor_lock(descriptor_data->mutex);
  renodx::utils::pipeline_layout::GetPipelineLayoutData(
      state->graphics_pipeline_layout,
      [&](const renodx::utils::pipeline_layout::PipelineLayoutData* layout_data) {
        for (uint32_t layout_param = 0u; layout_param < layout_data->ranges.size() && result.buffer.handle == 0u; ++layout_param) {
          if (layout_param >= state->graphics_descriptor_tables.size()) continue;

          const auto table = state->graphics_descriptor_tables[layout_param];
          if (table.handle == 0u) continue;

          for (const auto& range : layout_data->ranges[layout_param]) {
            if (range.type != reshade::api::descriptor_type::constant_buffer
                || range.dx_register_space != 0u
                || range.dx_register_index > 0u
                || range.count == 0u
                || !renodx::utils::bitwise::HasFlag(range.visibility, reshade::api::shader_stage::pixel)) {
              continue;
            }

            const uint32_t descriptor_offset = 0u - range.dx_register_index;
            reshade::api::descriptor_heap heap = {0u};
            uint32_t base_heap_index = 0u;
            device->get_descriptor_heap_offset(
                table,
                table_relative_zero ? 0u : range.binding,
                0u,
                &heap,
                &base_heap_index);
            if (heap.handle == 0u) continue;

            const auto heap_pair = descriptor_data->heaps.find(heap.handle);
            if (heap_pair == descriptor_data->heaps.end()) continue;

            const uint32_t heap_index = base_heap_index + descriptor_offset;
            if (heap_index >= heap_pair->second.size()) continue;

            const auto& descriptor = heap_pair->second[heap_index];
            if (descriptor.type != reshade::api::descriptor_type::constant_buffer) continue;
            result = descriptor.buffer_range;
            return;
          }
        }
      });
  return result;
}

inline reshade::api::buffer_range GetPixelConstantBuffer(reshade::api::command_list* cmd_list) {
  const auto* state = cmd_list != nullptr ? renodx::utils::state::GetCurrentState(cmd_list) : nullptr;
  const auto* data = Get(cmd_list);
  if (state != nullptr
      && data != nullptr
      && data->pixel_cb_b0.buffer.handle != 0u
      && data->pixel_cb_b0_layout == state->graphics_pipeline_layout) {
    return data->pixel_cb_b0;
  }

  auto result = ReadPixelConstantBufferFromTables(cmd_list, false);
  if (result.buffer.handle == 0u) result = ReadPixelConstantBufferFromTables(cmd_list, true);
  return result;
}

inline bool IsComputePipelineStage(reshade::api::pipeline_stage stage) {
  return (static_cast<uint32_t>(stage) & static_cast<uint32_t>(reshade::api::pipeline_stage::all_compute)) != 0u;
}

inline PreviousComputeState CaptureComputeState(reshade::api::command_list* cmd_list) {
  PreviousComputeState result = {};
  const auto* state = renodx::utils::state::GetCurrentState(cmd_list);
  if (state == nullptr) return result;

  for (const auto& [stage, pipeline] : state->pipelines) {
    if (!IsComputePipelineStage(stage) || result.pipeline_count >= result.pipelines.size()) continue;
    result.pipelines[result.pipeline_count++] = {stage, pipeline};
  }
  result.layout = state->compute_pipeline_layout;
  result.descriptor_tables = state->compute_descriptor_tables;
  return result;
}

inline void RestoreComputeState(reshade::api::command_list* cmd_list, const PreviousComputeState& state) {
  for (uint32_t i = 0u; i < state.pipeline_count; ++i) {
    cmd_list->bind_pipeline(state.pipelines[i].first, state.pipelines[i].second);
  }
  if (state.layout.handle != 0u) {
    cmd_list->bind_descriptor_tables(
        reshade::api::shader_stage::all_compute,
        state.layout,
        0u,
        static_cast<uint32_t>(state.descriptor_tables.size()),
        state.descriptor_tables.data());
  }
}

inline reshade::api::resource_usage GetResourceState(
    reshade::api::resource resource,
    reshade::api::resource_usage fallback) {
  const std::shared_lock lock(resource_state_mutex);
  const auto found = resource_states.find(resource.handle);
  return found == resource_states.end() || found->second == reshade::api::resource_usage::undefined
             ? fallback
             : found->second;
}

inline void SetResourceState(reshade::api::resource resource, reshade::api::resource_usage state) {
  if (resource.handle == 0u) return;
  const std::unique_lock lock(resource_state_mutex);
  resource_states[resource.handle] = state;
}

inline reshade::api::resource_usage TransitionResource(
    reshade::api::command_list* cmd_list,
    reshade::api::resource resource,
    reshade::api::resource_usage desired_state,
    reshade::api::resource_usage fallback_state) {
  const auto current_state = GetResourceState(resource, fallback_state);
  if (current_state != desired_state) {
    cmd_list->barrier(resource, current_state, desired_state);
    SetResourceState(resource, desired_state);
  }
  return current_state;
}

inline void ReleaseFeature() {
  if (ngx.feature != nullptr) {
    NVSDK_NGX_D3D12_ReleaseFeature(ngx.feature);
    ngx.feature = nullptr;
  }
  ngx.width = 0u;
  ngx.height = 0u;
  ngx.render_preset = -1;
  ngx.feature_flags = 0;
  ngx.create_failed = false;
  ngx.eval_failed = false;
  ngx.logged_success = false;
  last_evaluation_frame = std::numeric_limits<uint64_t>::max();
  last_source_resource = {0u};
  reset_history = true;
}

inline void DestroyDlaaTextures(reshade::api::device* device) {
  if (device == nullptr) return;
  ReleaseFeature();
  if (resources.bias_current_color_mask_srv.handle != 0u) device->destroy_resource_view(resources.bias_current_color_mask_srv);
  if (resources.bias_current_color_mask_uav.handle != 0u) device->destroy_resource_view(resources.bias_current_color_mask_uav);
  if (resources.previous_color_srv.handle != 0u) device->destroy_resource_view(resources.previous_color_srv);
  if (resources.dlaa_input_srv.handle != 0u) device->destroy_resource_view(resources.dlaa_input_srv);
  if (resources.dlaa_output_srv.handle != 0u) device->destroy_resource_view(resources.dlaa_output_srv);
  if (resources.bias_current_color_mask.handle != 0u) device->destroy_resource(resources.bias_current_color_mask);
  if (resources.previous_color.handle != 0u) device->destroy_resource(resources.previous_color);
  if (resources.dlaa_input.handle != 0u) device->destroy_resource(resources.dlaa_input);
  if (resources.dlaa_output.handle != 0u) device->destroy_resource(resources.dlaa_output);
  resources.dlaa_input = {0u};
  resources.dlaa_input_srv = {0u};
  resources.dlaa_output = {0u};
  resources.dlaa_output_srv = {0u};
  resources.previous_color = {0u};
  resources.previous_color_srv = {0u};
  resources.bias_current_color_mask = {0u};
  resources.bias_current_color_mask_srv = {0u};
  resources.bias_current_color_mask_uav = {0u};
  resources.dlaa_width = 0u;
  resources.dlaa_height = 0u;
  resources.dlaa_format = reshade::api::format::unknown;
  resources.dlaa_input_state = reshade::api::resource_usage::undefined;
  resources.dlaa_output_state = reshade::api::resource_usage::undefined;
  resources.previous_color_state = reshade::api::resource_usage::undefined;
  resources.bias_mask_state = reshade::api::resource_usage::undefined;
  resources.previous_color_jitter = {};
  resources.previous_color_valid = false;
}

inline void ReleaseNgx() {
  ReleaseFeature();
  if (ngx.parameters != nullptr) {
    NVSDK_NGX_D3D12_DestroyParameters(ngx.parameters);
    ngx.parameters = nullptr;
  }
  if (ngx.initialized && ngx.device != nullptr) NVSDK_NGX_D3D12_Shutdown1(ngx.device.Get());
  ngx.device.Reset();
  ngx.initialized = false;
  ngx.init_failed = false;
}

inline bool EnsureNgxInitialized(reshade::api::device* device) {
  if (ngx.initialized) return true;
  if (ngx.init_failed || device == nullptr || !is_nvidia_device) return false;

  auto* native_device = reinterpret_cast<ID3D12Device*>(device->get_native());
  if (native_device == nullptr) return false;
  auto* exposed_device = native_device;
  const bool unwrapped_device = renodx::utils::directx::NativeFromReShadeProxy(&native_device);

  {
    std::stringstream s;
    s << "LORWIN DLAA: NGX D3D12 device exposed=" << exposed_device
      << " native=" << native_device
      << " reshade_proxy_unwrapped=" << (unwrapped_device ? "yes" : "no");
    reshade::log::message(reshade::log::level::info, s.str().c_str());
  }

  const std::wstring process_directory = GetProcessDirectory();
  wchar_t* feature_paths[] = {const_cast<wchar_t*>(process_directory.c_str())};
  NVSDK_NGX_FeatureCommonInfo feature_info = {};
  feature_info.PathListInfo.Length = 1u;
  feature_info.PathListInfo.Path = feature_paths;

  const NVSDK_NGX_Result init_result = NVSDK_NGX_D3D12_Init_with_ProjectID(
      "2bce07a2-a7da-4c76-9a65-52d9c9819a0e",
      NVSDK_NGX_ENGINE_TYPE_CUSTOM,
      "1.0",
      process_directory.c_str(),
      native_device,
      &feature_info,
      NVSDK_NGX_Version_API);
  if (NVSDK_NGX_FAILED(init_result)) {
    ngx.init_failed = true;
    enabled = 0.f;
    std::stringstream s;
    s << "LORWIN DLAA: NGX init failed: " << ResultToString(init_result)
      << " (0x" << std::hex << static_cast<uint32_t>(init_result) << ")";
    reshade::log::message(reshade::log::level::error, s.str().c_str());
    return false;
  }

  const NVSDK_NGX_Result params_result = NVSDK_NGX_D3D12_GetCapabilityParameters(&ngx.parameters);
  if (NVSDK_NGX_FAILED(params_result) || ngx.parameters == nullptr) {
    ngx.init_failed = true;
    enabled = 0.f;
    std::stringstream s;
    s << "LORWIN DLAA: capability parameters failed: " << ResultToString(params_result)
      << " (0x" << std::hex << static_cast<uint32_t>(params_result) << ")";
    reshade::log::message(reshade::log::level::error, s.str().c_str());
    NVSDK_NGX_D3D12_Shutdown1(native_device);
    return false;
  }

  ngx.device = native_device;
  ngx.initialized = true;
  int available = 0;
  ngx.parameters->Get(NVSDK_NGX_Parameter_SuperSampling_Available, &available);
  std::stringstream s;
  s << "LORWIN DLAA: NGX initialized, SuperSampling_Available=" << available;
  reshade::log::message(reshade::log::level::info, s.str().c_str());
  return true;
}

inline bool EnsureDlaaTextures(
    reshade::api::device* device,
    uint32_t width,
    uint32_t height,
    reshade::api::format format) {
  if (device == nullptr || width == 0u || height == 0u) return false;
  if (resources.dlaa_input.handle != 0u
      && resources.dlaa_input_srv.handle != 0u
      && resources.dlaa_output.handle != 0u
      && resources.previous_color.handle != 0u
      && resources.previous_color_srv.handle != 0u
      && resources.bias_current_color_mask.handle != 0u
      && resources.bias_current_color_mask_srv.handle != 0u
      && resources.bias_current_color_mask_uav.handle != 0u
      && resources.dlaa_width == width
      && resources.dlaa_height == height
      && resources.dlaa_format == format) {
    return true;
  }
  DestroyDlaaTextures(device);

  reshade::api::resource_desc desc = {};
  desc.type = reshade::api::resource_type::texture_2d;
  desc.texture = {width, height, 1u, 1u, format, 1u};
  desc.heap = reshade::api::memory_heap::gpu_only;
  desc.usage = reshade::api::resource_usage::shader_resource
               | reshade::api::resource_usage::unordered_access
               | reshade::api::resource_usage::copy_source
               | reshade::api::resource_usage::copy_dest;
  desc.flags = reshade::api::resource_flags::none;

  const auto srv_desc = reshade::api::resource_view_desc(
      reshade::api::resource_view_type::texture_2d, format, 0u, 1u, 0u, 1u);
  reshade::api::resource_desc mask_desc = desc;
  mask_desc.texture.format = reshade::api::format::r8_unorm;
  mask_desc.usage = reshade::api::resource_usage::shader_resource | reshade::api::resource_usage::unordered_access;
  const auto mask_view_desc = reshade::api::resource_view_desc(
      reshade::api::resource_view_type::texture_2d,
      reshade::api::format::r8_unorm,
      0u,
      1u,
      0u,
      1u);
  if (!device->create_resource(
          desc, nullptr, reshade::api::resource_usage::copy_dest, &resources.dlaa_input)
      || !device->create_resource_view(
          resources.dlaa_input,
          reshade::api::resource_usage::shader_resource,
          srv_desc,
          &resources.dlaa_input_srv)
      || !device->create_resource(
          desc, nullptr, reshade::api::resource_usage::unordered_access, &resources.dlaa_output)
      || !device->create_resource_view(
          resources.dlaa_output,
          reshade::api::resource_usage::shader_resource,
          srv_desc,
          &resources.dlaa_output_srv)
      || !device->create_resource(
          desc, nullptr, reshade::api::resource_usage::copy_dest, &resources.previous_color)
      || !device->create_resource_view(
          resources.previous_color,
          reshade::api::resource_usage::shader_resource,
          srv_desc,
          &resources.previous_color_srv)
      || !device->create_resource(
          mask_desc,
          nullptr,
          reshade::api::resource_usage::shader_resource,
          &resources.bias_current_color_mask)
      || !device->create_resource_view(
          resources.bias_current_color_mask,
          reshade::api::resource_usage::shader_resource,
          mask_view_desc,
          &resources.bias_current_color_mask_srv)
      || !device->create_resource_view(
          resources.bias_current_color_mask,
          reshade::api::resource_usage::unordered_access,
          mask_view_desc,
          &resources.bias_current_color_mask_uav)) {
    reshade::log::message(
        reshade::log::level::error,
        "LORWIN DLAA: failed to create typed input/output, color-history, or bias-mask textures.");
    DestroyDlaaTextures(device);
    enabled = 0.f;
    return false;
  }

  resources.dlaa_width = width;
  resources.dlaa_height = height;
  resources.dlaa_format = format;
  resources.dlaa_input_state = reshade::api::resource_usage::copy_dest;
  resources.dlaa_output_state = reshade::api::resource_usage::unordered_access;
  resources.previous_color_state = reshade::api::resource_usage::copy_dest;
  resources.bias_mask_state = reshade::api::resource_usage::shader_resource;
  resources.previous_color_valid = false;
  SetResourceState(resources.dlaa_input, resources.dlaa_input_state);
  SetResourceState(resources.dlaa_output, resources.dlaa_output_state);
  SetResourceState(resources.previous_color, resources.previous_color_state);
  SetResourceState(resources.bias_current_color_mask, resources.bias_mask_state);
  std::stringstream s;
  s << "LORWIN DLAA: created typed staging/output, color-history, and R8 bias-mask textures "
    << width << "x" << height << " color_format=" << static_cast<uint32_t>(format);
  reshade::log::message(reshade::log::level::info, s.str().c_str());
  return true;
}

inline bool EnsureFeature(ID3D12GraphicsCommandList* command_list, uint32_t width, uint32_t height) {
  if (command_list == nullptr || ngx.parameters == nullptr || resources.dlaa_output.handle == 0u) return false;
  const int preset = GetRenderPresetValue();
  const int flags = GetFeatureFlags();
  if (ngx.feature != nullptr
      && ngx.width == width
      && ngx.height == height
      && ngx.render_preset == preset
      && ngx.feature_flags == flags) {
    return true;
  }
  ReleaseFeature();

  NVSDK_NGX_DLSS_Create_Params params = {};
  params.Feature.InWidth = width;
  params.Feature.InHeight = height;
  params.Feature.InTargetWidth = width;
  params.Feature.InTargetHeight = height;
  params.Feature.InPerfQualityValue = NVSDK_NGX_PerfQuality_Value_DLAA;
  params.InFeatureCreateFlags = flags;
  params.InEnableOutputSubrects = false;
  NVSDK_NGX_Parameter_SetI(ngx.parameters, NVSDK_NGX_Parameter_DLSS_Hint_Render_Preset_DLAA, preset);

  {
    std::stringstream s;
    s << "LORWIN DLAA: beginning NGX feature creation at " << width << "x" << height
      << " command_list=" << command_list
      << " flags=" << GetFeatureFlagsName(flags)
      << " preset=" << GetRenderPresetName(preset);
    reshade::log::message(reshade::log::level::info, s.str().c_str());
  }
  const NVSDK_NGX_Result result = NGX_D3D12_CREATE_DLSS_EXT(
      command_list, 1u, 1u, &ngx.feature, ngx.parameters, &params);
  if (NVSDK_NGX_FAILED(result) || ngx.feature == nullptr) {
    ngx.create_failed = true;
    enabled = 0.f;
    std::stringstream s;
    s << "LORWIN DLAA: feature creation failed: " << ResultToString(result)
      << " (0x" << std::hex << static_cast<uint32_t>(result) << ")";
    reshade::log::message(reshade::log::level::error, s.str().c_str());
    return false;
  }

  ngx.width = width;
  ngx.height = height;
  ngx.render_preset = preset;
  ngx.feature_flags = flags;
  std::stringstream s;
  s << "LORWIN DLAA: feature created at " << width << "x" << height
    << " flags=" << GetFeatureFlagsName(flags)
    << " preset=" << GetRenderPresetName(preset);
  reshade::log::message(reshade::log::level::info, s.str().c_str());
  return true;
}

inline void DestroyMotionVectorTexture(reshade::api::device* device) {
  if (device == nullptr) return;
  if (resources.motion_vectors_srv.handle != 0u) device->destroy_resource_view(resources.motion_vectors_srv);
  if (resources.motion_vectors_uav.handle != 0u) device->destroy_resource_view(resources.motion_vectors_uav);
  if (resources.motion_vectors.handle != 0u) device->destroy_resource(resources.motion_vectors);
  resources.motion_vectors = {0u};
  resources.motion_vectors_srv = {0u};
  resources.motion_vectors_uav = {0u};
  resources.width = 0u;
  resources.height = 0u;
}

inline void DestroyComputePipeline(reshade::api::device* device) {
  if (device == nullptr) return;
  if (resources.compute_pipeline.handle != 0u) device->destroy_pipeline(resources.compute_pipeline);
  if (resources.compute_layout.handle != 0u) device->destroy_pipeline_layout(resources.compute_layout);
  if (resources.linear_clamp_sampler.handle != 0u) device->destroy_sampler(resources.linear_clamp_sampler);
  resources.compute_pipeline = {0u};
  resources.compute_layout = {0u};
  resources.linear_clamp_sampler = {0u};
}

inline void DestroyBiasMaskPipeline(reshade::api::device* device) {
  if (device == nullptr) return;
  if (resources.bias_mask_pipeline.handle != 0u) device->destroy_pipeline(resources.bias_mask_pipeline);
  if (resources.bias_mask_layout.handle != 0u) device->destroy_pipeline_layout(resources.bias_mask_layout);
  if (resources.bias_mask_sampler.handle != 0u) device->destroy_sampler(resources.bias_mask_sampler);
  resources.bias_mask_pipeline = {0u};
  resources.bias_mask_layout = {0u};
  resources.bias_mask_sampler = {0u};
}

inline void Destroy(reshade::api::device* device) {
  if (device == nullptr || resources.device != device) return;
  ReleaseNgx();
  DestroyDlaaTextures(device);
  DestroyMotionVectorTexture(device);
  DestroyBiasMaskPipeline(device);
  DestroyComputePipeline(device);
  resources = {};
  last_dispatch_frame = std::numeric_limits<uint64_t>::max();
}

inline bool EnsureComputePipeline(reshade::api::device* device) {
  if (device == nullptr || device->get_api() != reshade::api::device_api::d3d12) return false;
  DetectD3D12Adapter(device);
  if (resources.device != nullptr && resources.device != device) Destroy(resources.device);
  resources.device = device;

  if (resources.compute_layout.handle != 0u
      && resources.compute_pipeline.handle != 0u
      && resources.linear_clamp_sampler.handle != 0u) {
    return true;
  }
  DestroyComputePipeline(device);

  std::array<reshade::api::pipeline_layout_param, 5> params = {};
  params[0].type = reshade::api::pipeline_layout_param_type::push_descriptors;
  params[0].push_descriptors.count = 1u;
  params[0].push_descriptors.type = reshade::api::descriptor_type::sampler;
  params[0].push_descriptors.dx_register_index = 0u;
  params[0].push_descriptors.dx_register_space = 0u;
  params[0].push_descriptors.visibility = reshade::api::shader_stage::compute;

  params[1].type = reshade::api::pipeline_layout_param_type::push_descriptors;
  params[1].push_descriptors.count = 1u;
  params[1].push_descriptors.type = reshade::api::descriptor_type::constant_buffer;
  params[1].push_descriptors.dx_register_index = 0u;
  params[1].push_descriptors.dx_register_space = 0u;
  params[1].push_descriptors.visibility = reshade::api::shader_stage::compute;

  params[2].type = reshade::api::pipeline_layout_param_type::push_descriptors;
  params[2].push_descriptors.count = 1u;
  params[2].push_descriptors.type = reshade::api::descriptor_type::texture_shader_resource_view;
  params[2].push_descriptors.dx_register_index = 0u;
  params[2].push_descriptors.dx_register_space = 0u;
  params[2].push_descriptors.visibility = reshade::api::shader_stage::compute;

  params[3].type = reshade::api::pipeline_layout_param_type::push_descriptors;
  params[3].push_descriptors.count = 1u;
  params[3].push_descriptors.type = reshade::api::descriptor_type::texture_unordered_access_view;
  params[3].push_descriptors.dx_register_index = 0u;
  params[3].push_descriptors.dx_register_space = 0u;
  params[3].push_descriptors.visibility = reshade::api::shader_stage::compute;

  params[4].type = reshade::api::pipeline_layout_param_type::push_constants;
  params[4].push_constants.count = 4u;
  params[4].push_constants.dx_register_index = 1u;
  params[4].push_constants.dx_register_space = 0u;
  params[4].push_constants.visibility = reshade::api::shader_stage::compute;

  if (!device->create_pipeline_layout(static_cast<uint32_t>(params.size()), params.data(), &resources.compute_layout)
      || !device->create_sampler({}, &resources.linear_clamp_sampler)) {
    if (ShouldLog(last_failure_log)) {
      reshade::log::message(reshade::log::level::warning, "LORWIN DLAA: failed to create the motion-vector compute layout or sampler.");
    }
    DestroyComputePipeline(device);
    return false;
  }

  reshade::api::shader_desc shader_desc = {
      .code = __motion_vectors.data(),
      .code_size = __motion_vectors.size(),
  };
  const reshade::api::pipeline_subobject shader = {
      .type = reshade::api::pipeline_subobject_type::compute_shader,
      .count = 1u,
      .data = &shader_desc,
  };
  if (!device->create_pipeline(resources.compute_layout, 1u, &shader, &resources.compute_pipeline)) {
    if (ShouldLog(last_failure_log)) {
      reshade::log::message(reshade::log::level::warning, "LORWIN DLAA: failed to create the motion-vector compute pipeline.");
    }
    DestroyComputePipeline(device);
    return false;
  }

  reshade::log::message(
      reshade::log::level::info,
      "LORWIN DLAA: created the AC3R-style depth-neighborhood motion-vector compute pipeline.");
  return true;
}

inline bool EnsureBiasMaskPipeline(reshade::api::device* device) {
  if (device == nullptr || device->get_api() != reshade::api::device_api::d3d12) return false;
  if (resources.bias_mask_layout.handle != 0u
      && resources.bias_mask_pipeline.handle != 0u
      && resources.bias_mask_sampler.handle != 0u) {
    return true;
  }
  DestroyBiasMaskPipeline(device);

  std::array<reshade::api::pipeline_layout_param, 4> params = {};
  params[0].type = reshade::api::pipeline_layout_param_type::push_descriptors;
  params[0].push_descriptors.count = 1u;
  params[0].push_descriptors.type = reshade::api::descriptor_type::sampler;
  params[0].push_descriptors.dx_register_index = 0u;
  params[0].push_descriptors.dx_register_space = 0u;
  params[0].push_descriptors.visibility = reshade::api::shader_stage::compute;

  params[1].type = reshade::api::pipeline_layout_param_type::push_descriptors;
  params[1].push_descriptors.count = 4u;
  params[1].push_descriptors.type = reshade::api::descriptor_type::texture_shader_resource_view;
  params[1].push_descriptors.dx_register_index = 0u;
  params[1].push_descriptors.dx_register_space = 0u;
  params[1].push_descriptors.visibility = reshade::api::shader_stage::compute;

  params[2].type = reshade::api::pipeline_layout_param_type::push_descriptors;
  params[2].push_descriptors.count = 1u;
  params[2].push_descriptors.type = reshade::api::descriptor_type::texture_unordered_access_view;
  params[2].push_descriptors.dx_register_index = 0u;
  params[2].push_descriptors.dx_register_space = 0u;
  params[2].push_descriptors.visibility = reshade::api::shader_stage::compute;

  params[3].type = reshade::api::pipeline_layout_param_type::push_constants;
  params[3].push_constants.count = 8u;
  params[3].push_constants.dx_register_index = 0u;
  params[3].push_constants.dx_register_space = 0u;
  params[3].push_constants.visibility = reshade::api::shader_stage::compute;

  if (!device->create_pipeline_layout(static_cast<uint32_t>(params.size()), params.data(), &resources.bias_mask_layout)
      || !device->create_sampler({}, &resources.bias_mask_sampler)) {
    if (ShouldLog(last_failure_log)) {
      reshade::log::message(
          reshade::log::level::warning,
          "LORWIN DLAA: failed to create the synthetic bias-mask compute layout or sampler.");
    }
    DestroyBiasMaskPipeline(device);
    return false;
  }

  reshade::api::shader_desc shader_desc = {
      .code = __bias_current_color_mask.data(),
      .code_size = __bias_current_color_mask.size(),
  };
  const reshade::api::pipeline_subobject shader = {
      .type = reshade::api::pipeline_subobject_type::compute_shader,
      .count = 1u,
      .data = &shader_desc,
  };
  if (!device->create_pipeline(resources.bias_mask_layout, 1u, &shader, &resources.bias_mask_pipeline)) {
    if (ShouldLog(last_failure_log)) {
      reshade::log::message(
          reshade::log::level::warning,
          "LORWIN DLAA: failed to create the synthetic bias-mask compute pipeline.");
    }
    DestroyBiasMaskPipeline(device);
    return false;
  }

  reshade::log::message(
      reshade::log::level::info,
      "LORWIN DLAA: created synthetic BiasCurrentColorMask compute pipeline.");
  return true;
}

inline bool EnsureMotionVectorTexture(reshade::api::device* device, uint32_t width, uint32_t height) {
  if (device == nullptr || width == 0u || height == 0u) return false;
  if (resources.motion_vectors.handle != 0u && resources.width == width && resources.height == height) return true;
  DestroyMotionVectorTexture(device);

  reshade::api::resource_desc desc = {};
  desc.type = reshade::api::resource_type::texture_2d;
  desc.texture = {
      width,
      height,
      1u,
      1u,
      reshade::api::format::r16g16_float,
      1u,
  };
  desc.heap = reshade::api::memory_heap::gpu_only;
  desc.usage = reshade::api::resource_usage::shader_resource | reshade::api::resource_usage::unordered_access;
  desc.flags = reshade::api::resource_flags::none;

  const auto view_desc = reshade::api::resource_view_desc(
      reshade::api::resource_view_type::texture_2d,
      reshade::api::format::r16g16_float,
      0u,
      1u,
      0u,
      1u);
  if (!device->create_resource(desc, nullptr, reshade::api::resource_usage::shader_resource, &resources.motion_vectors)
      || !device->create_resource_view(
          resources.motion_vectors,
          reshade::api::resource_usage::shader_resource,
          view_desc,
          &resources.motion_vectors_srv)
      || !device->create_resource_view(
          resources.motion_vectors,
          reshade::api::resource_usage::unordered_access,
          view_desc,
          &resources.motion_vectors_uav)) {
    if (ShouldLog(last_failure_log)) {
      reshade::log::message(reshade::log::level::warning, "LORWIN DLAA: failed to create the motion-vector texture or views.");
    }
    DestroyMotionVectorTexture(device);
    return false;
  }

  resources.width = width;
  resources.height = height;
  std::stringstream s;
  s << "LORWIN DLAA: created motion-vector texture " << width << "x" << height
    << " format=R16G16_FLOAT resource=0x" << std::hex << resources.motion_vectors.handle
    << " srv=0x" << resources.motion_vectors_srv.handle
    << " uav=0x" << resources.motion_vectors_uav.handle;
  reshade::log::message(reshade::log::level::info, s.str().c_str());
  return true;
}

inline bool RunMotionVectorPrepass(reshade::api::command_list* cmd_list) {
  if (shader_injection == nullptr || cmd_list == nullptr) return true;
  std::scoped_lock lock(runtime_mutex);

  const uint64_t current_frame = resource_logger::frame_index.load();
  if (last_dispatch_frame == current_frame) return true;

  auto* device = cmd_list->get_device();
  const auto srvs = resource_logger::ReadPixelSrvs(cmd_list, false);
  const auto depth_srv = srvs[3].view;
  const auto globals = GetPixelConstantBuffer(cmd_list);
  if (device == nullptr || depth_srv.handle == 0u || globals.buffer.handle == 0u) {
    if (ShouldLog(last_missing_input_log)) {
      std::stringstream s;
      s << "LORWIN DLAA: motion-vector prepass missing inputs depth_srv=0x" << std::hex << depth_srv.handle
        << " globals_b0=0x" << globals.buffer.handle << std::dec;
      reshade::log::message(reshade::log::level::warning, s.str().c_str());
    }
    return true;
  }

  const auto depth_resource = renodx::utils::resource::GetResourceFromView(device, depth_srv);
  if (depth_resource.handle == 0u) return true;
  const auto depth_desc = renodx::utils::resource::GetResourceDesc(device, depth_resource);
  if (!EnsureComputePipeline(device)
      || !EnsureMotionVectorTexture(device, depth_desc.texture.width, depth_desc.texture.height)) {
    return true;
  }

  const PreviousComputeState previous_compute_state = CaptureComputeState(cmd_list);
  const std::array<reshade::api::descriptor_table_update, 4> updates = {
      reshade::api::descriptor_table_update{
          .table = {},
          .binding = 0u,
          .array_offset = 0u,
          .count = 1u,
          .type = reshade::api::descriptor_type::sampler,
          .descriptors = &resources.linear_clamp_sampler,
      },
      reshade::api::descriptor_table_update{
          .table = {},
          .binding = 0u,
          .array_offset = 0u,
          .count = 1u,
          .type = reshade::api::descriptor_type::constant_buffer,
          .descriptors = &globals,
      },
      reshade::api::descriptor_table_update{
          .table = {},
          .binding = 0u,
          .array_offset = 0u,
          .count = 1u,
          .type = reshade::api::descriptor_type::texture_shader_resource_view,
          .descriptors = &depth_srv,
      },
      reshade::api::descriptor_table_update{
          .table = {},
          .binding = 0u,
          .array_offset = 0u,
          .count = 1u,
          .type = reshade::api::descriptor_type::texture_unordered_access_view,
          .descriptors = &resources.motion_vectors_uav,
      },
  };

  cmd_list->barrier(
      resources.motion_vectors,
      reshade::api::resource_usage::shader_resource,
      reshade::api::resource_usage::unordered_access);
  for (uint32_t i = 0u; i < updates.size(); ++i) {
    cmd_list->push_descriptors(
        reshade::api::shader_stage::all_compute,
        resources.compute_layout,
        i,
        updates[i]);
  }
  const auto pixel_jitter = jitter::GetEvaluationPixelJitter();
  const std::array<float, 4> dilation_constants = {
      pixel_jitter[0],
      pixel_jitter[1],
      0.f,
      motion_vector_dilation,
  };
  cmd_list->push_constants(
      reshade::api::shader_stage::all_compute,
      resources.compute_layout,
      4u,
      0u,
      static_cast<uint32_t>(dilation_constants.size()),
      dilation_constants.data());
  cmd_list->bind_pipeline(reshade::api::pipeline_stage::all_compute, resources.compute_pipeline);
  cmd_list->dispatch((resources.width + 7u) / 8u, (resources.height + 7u) / 8u, 1u);
  cmd_list->barrier(
      resources.motion_vectors,
      reshade::api::resource_usage::unordered_access,
      reshade::api::resource_usage::shader_resource);
  RestoreComputeState(cmd_list, previous_compute_state);

  last_dispatch_frame = current_frame;
  return true;
}

inline void CopyCurrentColorToHistory(reshade::api::command_list* cmd_list) {
  TransitionResource(
      cmd_list,
      resources.dlaa_input,
      reshade::api::resource_usage::copy_source,
      resources.dlaa_input_state);
  TransitionResource(
      cmd_list,
      resources.previous_color,
      reshade::api::resource_usage::copy_dest,
      resources.previous_color_state);
  cmd_list->copy_resource(resources.dlaa_input, resources.previous_color);
  TransitionResource(
      cmd_list,
      resources.dlaa_input,
      reshade::api::resource_usage::shader_resource,
      reshade::api::resource_usage::copy_source);
  TransitionResource(
      cmd_list,
      resources.previous_color,
      reshade::api::resource_usage::shader_resource,
      reshade::api::resource_usage::copy_dest);
  resources.dlaa_input_state = reshade::api::resource_usage::shader_resource;
  resources.previous_color_state = reshade::api::resource_usage::shader_resource;
}

inline bool RunBiasCurrentColorMaskPrepass(
    reshade::api::command_list* cmd_list,
    reshade::api::resource_view depth_srv,
    const std::array<float, 2>& pixel_jitter,
    bool reset_color_history) {
  if (bias_current_color_mask == 0.f) {
    resources.previous_color_valid = false;
    return false;
  }
  if (cmd_list == nullptr
      || depth_srv.handle == 0u
      || resources.dlaa_input_srv.handle == 0u
      || resources.previous_color_srv.handle == 0u
      || resources.motion_vectors_srv.handle == 0u
      || resources.bias_current_color_mask_uav.handle == 0u
      || !EnsureBiasMaskPipeline(cmd_list->get_device())) {
    resources.previous_color_valid = false;
    return false;
  }

  const bool history_available = resources.previous_color_valid && !reset_color_history;
  if (!history_available) CopyCurrentColorToHistory(cmd_list);

  const PreviousComputeState previous_compute_state = CaptureComputeState(cmd_list);
  const std::array<reshade::api::resource_view, 4> input_srvs = {
      resources.dlaa_input_srv,
      resources.previous_color_srv,
      depth_srv,
      resources.motion_vectors_srv,
  };
  const std::array<reshade::api::descriptor_table_update, 3> updates = {
      reshade::api::descriptor_table_update{
          .table = {},
          .binding = 0u,
          .array_offset = 0u,
          .count = 1u,
          .type = reshade::api::descriptor_type::sampler,
          .descriptors = &resources.bias_mask_sampler,
      },
      reshade::api::descriptor_table_update{
          .table = {},
          .binding = 0u,
          .array_offset = 0u,
          .count = static_cast<uint32_t>(input_srvs.size()),
          .type = reshade::api::descriptor_type::texture_shader_resource_view,
          .descriptors = input_srvs.data(),
      },
      reshade::api::descriptor_table_update{
          .table = {},
          .binding = 0u,
          .array_offset = 0u,
          .count = 1u,
          .type = reshade::api::descriptor_type::texture_unordered_access_view,
          .descriptors = &resources.bias_current_color_mask_uav,
      },
  };
  const std::array<float, 8> constants = {
      history_available ? 1.f : 0.f,
      bias_current_color_strength,
      0.04f,
      0.001f,
      (resources.previous_color_jitter[0] - pixel_jitter[0]) / static_cast<float>(resources.dlaa_width),
      (resources.previous_color_jitter[1] - pixel_jitter[1]) / static_cast<float>(resources.dlaa_height),
      0.f,
      0.f,
  };

  TransitionResource(
      cmd_list,
      resources.bias_current_color_mask,
      reshade::api::resource_usage::unordered_access,
      resources.bias_mask_state);
  resources.bias_mask_state = reshade::api::resource_usage::unordered_access;
  for (uint32_t i = 0u; i < updates.size(); ++i) {
    cmd_list->push_descriptors(
        reshade::api::shader_stage::all_compute,
        resources.bias_mask_layout,
        i,
        updates[i]);
  }
  cmd_list->push_constants(
      reshade::api::shader_stage::all_compute,
      resources.bias_mask_layout,
      3u,
      0u,
      static_cast<uint32_t>(constants.size()),
      constants.data());
  cmd_list->bind_pipeline(reshade::api::pipeline_stage::all_compute, resources.bias_mask_pipeline);
  cmd_list->dispatch((resources.dlaa_width + 7u) / 8u, (resources.dlaa_height + 7u) / 8u, 1u);
  TransitionResource(
      cmd_list,
      resources.bias_current_color_mask,
      reshade::api::resource_usage::shader_resource,
      reshade::api::resource_usage::unordered_access);
  resources.bias_mask_state = reshade::api::resource_usage::shader_resource;

  if (history_available) CopyCurrentColorToHistory(cmd_list);
  resources.previous_color_jitter = pixel_jitter;
  resources.previous_color_valid = true;
  RestoreComputeState(cmd_list, previous_compute_state);
  return true;
}

inline bool RunDlaa(reshade::api::command_list* cmd_list) {
  if (shader_injection != nullptr) shader_injection->dlaa_enabled = 0.f;
  if (cmd_list == nullptr) return true;
  std::scoped_lock lock(runtime_mutex);

  auto* device = cmd_list->get_device();
  auto* state = renodx::utils::state::GetCurrentState(cmd_list);
  if (device == nullptr || state == nullptr || state->render_targets.empty()) return true;

  const auto target = renodx::utils::resource::GetResourceFromView(device, state->render_targets[0]);
  if (target.handle == 0u) return true;
  const auto target_desc = renodx::utils::resource::GetResourceDesc(device, target);
  const auto binding_srvs = resource_logger::ReadPixelSrvs(cmd_list, false);
  const auto relative_srvs = resource_logger::ReadPixelSrvs(cmd_list, true);
  const auto& srvs = resource_logger::ScoreSrvMapping(
                         device, relative_srvs, target_desc.texture.width, target_desc.texture.height)
                         > resource_logger::ScoreSrvMapping(
                             device, binding_srvs, target_desc.texture.width, target_desc.texture.height)
                     ? relative_srvs
                     : binding_srvs;
  const auto& scene_srv = srvs[0];
  const auto& depth_srv = srvs[3];
  const auto source = renodx::utils::resource::GetResourceFromView(device, scene_srv.view);
  const auto depth = renodx::utils::resource::GetResourceFromView(device, depth_srv.view);
  if (source.handle != 0u) jitter::SetPostprocessSceneColorResource(source);
  if (depth.handle != 0u) jitter::SetPostprocessDepthResource(depth);
  if (enabled == 0.f || !is_nvidia_device) return true;
  if (scene_srv.view.handle == 0u
      || depth_srv.view.handle == 0u
      || resources.motion_vectors.handle == 0u
      || resources.motion_vectors_srv.handle == 0u) {
    if (ShouldLog(last_missing_input_log)) {
      std::stringstream s;
      s << "LORWIN DLAA: missing evaluation inputs scene=0x" << std::hex << scene_srv.view.handle
        << " depth=0x" << depth_srv.view.handle
        << " motion_vectors=0x" << resources.motion_vectors.handle;
      reshade::log::message(reshade::log::level::warning, s.str().c_str());
    }
    return true;
  }

  if (source.handle == 0u || depth.handle == 0u) return true;
  const auto source_desc = renodx::utils::resource::GetResourceDesc(device, source);
  const auto source_view_desc = renodx::utils::resource::GetResourceViewDesc(device, scene_srv.view);
  const auto input_format = source_view_desc.format == reshade::api::format::unknown
                                ? reshade::api::format_to_default_typed(source_desc.texture.format)
                                : source_view_desc.format;
  if (source_desc.texture.width == 0u
      || source_desc.texture.height == 0u
      || (input_format != reshade::api::format::r8g8b8a8_unorm
          && input_format != reshade::api::format::r8g8b8a8_unorm_srgb)) {
    if (ShouldLog(last_failure_log)) {
      std::stringstream s;
      s << "LORWIN DLAA: unsupported scene input format=" << static_cast<uint32_t>(input_format)
        << " size=" << source_desc.texture.width << "x" << source_desc.texture.height;
      reshade::log::message(reshade::log::level::warning, s.str().c_str());
    }
    return true;
  }

  const auto typed_format = input_format == reshade::api::format::r8g8b8a8_unorm_srgb
                                ? reshade::api::format::r8g8b8a8_unorm
                                : input_format;
  if (!EnsureNgxInitialized(device)
      || !EnsureDlaaTextures(device, source_desc.texture.width, source_desc.texture.height, typed_format)) {
    return true;
  }
  const uint64_t current_frame = resource_logger::frame_index.load();
  if (last_evaluation_frame == current_frame && last_source_resource == source) {
    if (shader_injection != nullptr) shader_injection->dlaa_enabled = 1.f;
    return true;
  }
  auto* command_list = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd_list->get_native());
  if (command_list == nullptr) {
    enabled = 0.f;
    return true;
  }
  renodx::utils::directx::NativeFromReShadeProxy(&command_list);

  const auto previous_state = *state;
  const auto source_state = TransitionResource(
      cmd_list, source, reshade::api::resource_usage::copy_source, reshade::api::resource_usage::shader_resource);
  TransitionResource(
      cmd_list, resources.dlaa_input, reshade::api::resource_usage::copy_dest, resources.dlaa_input_state);
  cmd_list->copy_resource(source, resources.dlaa_input);
  TransitionResource(
      cmd_list, resources.dlaa_input, reshade::api::resource_usage::shader_resource, reshade::api::resource_usage::copy_dest);
  resources.dlaa_input_state = reshade::api::resource_usage::shader_resource;
  TransitionResource(cmd_list, source, source_state, reshade::api::resource_usage::copy_source);

  const auto depth_state = TransitionResource(
      cmd_list, depth, reshade::api::resource_usage::shader_resource, reshade::api::resource_usage::shader_resource);
  TransitionResource(
      cmd_list, resources.dlaa_output, reshade::api::resource_usage::unordered_access, resources.dlaa_output_state);
  resources.dlaa_output_state = reshade::api::resource_usage::unordered_access;

  if (!EnsureFeature(command_list, source_desc.texture.width, source_desc.texture.height)) {
    previous_state.Apply(cmd_list);
    TransitionResource(cmd_list, depth, depth_state, reshade::api::resource_usage::shader_resource);
    return true;
  }

  const bool source_changed = last_source_resource.handle != 0u && last_source_resource != source;
  const bool discontinuous = last_evaluation_frame == std::numeric_limits<uint64_t>::max()
                             || current_frame != last_evaluation_frame + 1u;
  const auto pixel_jitter = jitter::GetEvaluationPixelJitter();
  const int selected_motion_vector_axes = static_cast<int>(std::round(motion_vector_axes));
  const int selected_motion_vector_dilation = motion_vector_dilation != 0.f ? 1 : 0;
  const int selected_bias_current_color_mask = bias_current_color_mask != 0.f ? 1 : 0;
  const int selected_jitter_axes = static_cast<int>(std::round(jitter_axes));
  const int selected_camera_jitter_pattern = jitter::WasMainSceneJitteredThisFrame()
                                                 ? jitter::GetSelectedPattern()
                                                 : 0;
  const auto motion_vector_signs = GetAxisSigns(motion_vector_axes);
  const auto jitter_signs = GetAxisSigns(jitter_axes);
  const bool tuning_changed = selected_motion_vector_axes != last_motion_vector_axes
                              || selected_motion_vector_dilation != last_motion_vector_dilation
                              || selected_bias_current_color_mask != last_bias_current_color_mask
                              || selected_jitter_axes != last_jitter_axes
                              || selected_camera_jitter_pattern != last_camera_jitter_pattern
                              || motion_vector_scale != last_motion_vector_scale
                              || bias_current_color_strength != last_bias_current_color_strength
                              || jitter::camera_jitter_scale != last_camera_jitter_scale
                              || jitter_scale != last_jitter_scale;
  if (tuning_changed) {
    last_motion_vector_axes = selected_motion_vector_axes;
    last_motion_vector_dilation = selected_motion_vector_dilation;
    last_bias_current_color_mask = selected_bias_current_color_mask;
    last_jitter_axes = selected_jitter_axes;
    last_camera_jitter_pattern = selected_camera_jitter_pattern;
    last_motion_vector_scale = motion_vector_scale;
    last_bias_current_color_strength = bias_current_color_strength;
    last_camera_jitter_scale = jitter::camera_jitter_scale;
    last_jitter_scale = jitter_scale;
    reset_history = true;

    std::stringstream s;
    s << "LORWIN DLAA: live input tuning mv_axes=" << selected_motion_vector_axes
      << " mv_scale=" << motion_vector_scale
      << " mv_dilation=" << (selected_motion_vector_dilation != 0 ? "on" : "off")
      << " bias_mask=" << (selected_bias_current_color_mask != 0 ? "on" : "off")
      << " bias_mask_strength=" << bias_current_color_strength
      << " camera_jitter_pattern=" << selected_camera_jitter_pattern
      << " camera_jitter_scale=" << jitter::camera_jitter_scale
      << " jitter_raw=(" << pixel_jitter[0] << ", " << pixel_jitter[1] << ")"
      << " jitter_axes=" << selected_jitter_axes
      << " ngx_jitter_scale=" << jitter_scale;
    reshade::log::message(reshade::log::level::info, s.str().c_str());
  }
  const float requested_ngx_jitter_x = pixel_jitter[0] * jitter_signs[0] * jitter_scale;
  const float requested_ngx_jitter_y = pixel_jitter[1] * jitter_signs[1] * jitter_scale;
  const bool camera_jitter_overdriven = jitter::camera_jitter_scale > 1.f;
  const bool ngx_jitter_out_of_range = std::abs(requested_ngx_jitter_x) > 0.5f
                                       || std::abs(requested_ngx_jitter_y) > 0.5f;
  // Camera overdrive is a coverage-only test, so keep NGX isolated from it.
  // Do not silently replace an independently scaled NGX sample with zero: that
  // made the largest Halton sample reset history once every eight frames above
  // roughly 114%, invalidating the scale diagnostic and introducing a periodic
  // shake of its own. Out-of-range NGX values remain visible in the log and are
  // intentionally passed through for debugging.
  const bool suppress_ngx_jitter = camera_jitter_overdriven;
  const bool evaluation_reset = reset_history.exchange(false)
                                || source_changed
                                || discontinuous
                                || suppress_ngx_jitter
                                || force_history_reset != 0.f;
  const bool bias_mask_ready = RunBiasCurrentColorMaskPrepass(
      cmd_list,
      depth_srv.view,
      pixel_jitter,
      evaluation_reset);
  NVSDK_NGX_D3D12_DLSS_Eval_Params eval = {};
  eval.Feature.pInColor = reinterpret_cast<ID3D12Resource*>(resources.dlaa_input.handle);
  eval.Feature.pInOutput = reinterpret_cast<ID3D12Resource*>(resources.dlaa_output.handle);
  eval.pInDepth = reinterpret_cast<ID3D12Resource*>(depth.handle);
  eval.pInMotionVectors = reinterpret_cast<ID3D12Resource*>(resources.motion_vectors.handle);
  eval.pInBiasCurrentColorMask = bias_mask_ready
                                     ? reinterpret_cast<ID3D12Resource*>(resources.bias_current_color_mask.handle)
                                     : nullptr;
  eval.InJitterOffsetX = suppress_ngx_jitter ? 0.f : requested_ngx_jitter_x;
  eval.InJitterOffsetY = suppress_ngx_jitter ? 0.f : requested_ngx_jitter_y;
  eval.InRenderSubrectDimensions.Width = source_desc.texture.width;
  eval.InRenderSubrectDimensions.Height = source_desc.texture.height;
  eval.InReset = evaluation_reset ? 1 : 0;
  eval.InMVScaleX = static_cast<float>(source_desc.texture.width) * motion_vector_signs[0] * motion_vector_scale;
  eval.InMVScaleY = static_cast<float>(source_desc.texture.height) * motion_vector_signs[1] * motion_vector_scale;
  eval.InPreExposure = 1.f;
  eval.InExposureScale = 1.f;

  const NVSDK_NGX_Result result = NGX_D3D12_EVALUATE_DLSS_EXT(
      command_list, ngx.feature, ngx.parameters, &eval);
  previous_state.Apply(cmd_list);
  TransitionResource(cmd_list, depth, depth_state, reshade::api::resource_usage::shader_resource);
  if (NVSDK_NGX_FAILED(result)) {
    ngx.eval_failed = true;
    enabled = 0.f;
    reset_history = true;
    std::stringstream s;
    s << "LORWIN DLAA: evaluation failed: " << ResultToString(result)
      << " (0x" << std::hex << static_cast<uint32_t>(result) << ")";
    reshade::log::message(reshade::log::level::error, s.str().c_str());
    return true;
  }

  TransitionResource(
      cmd_list, resources.dlaa_output, reshade::api::resource_usage::shader_resource, reshade::api::resource_usage::unordered_access);
  resources.dlaa_output_state = reshade::api::resource_usage::shader_resource;
  last_evaluation_frame = current_frame;
  last_source_resource = source;
  if (shader_injection != nullptr) shader_injection->dlaa_enabled = 1.f;

  if (!ngx.logged_success) {
    ngx.logged_success = true;
    std::stringstream s;
    s << "LORWIN DLAA: evaluation active at " << source_desc.texture.width << "x" << source_desc.texture.height
      << " jitter_raw=(" << pixel_jitter[0] << ", " << pixel_jitter[1] << ")"
      << " jitter_ngx=(" << eval.InJitterOffsetX << ", " << eval.InJitterOffsetY << ")"
      << " jitter_suppressed=" << (suppress_ngx_jitter ? "yes" : "no")
      << " jitter_out_of_range=" << (ngx_jitter_out_of_range ? "yes" : "no")
      << " mv_scale=(" << eval.InMVScaleX << ", " << eval.InMVScaleY << ")"
      << " bias_mask=" << (bias_mask_ready ? "on" : "off")
      << " flags=" << GetFeatureFlagsName(ngx.feature_flags)
      << " preset=" << GetRenderPresetName(ngx.render_preset);
    reshade::log::message(reshade::log::level::info, s.str().c_str());
  }
  return true;
}

inline reshade::api::resource_view GetMotionVectorSrv(reshade::api::command_list*) {
  std::scoped_lock lock(runtime_mutex);
  return resources.motion_vectors_srv;
}

inline reshade::api::resource_view GetDlaaOutputSrv(reshade::api::command_list*) {
  std::scoped_lock lock(runtime_mutex);
  return resources.dlaa_output_srv;
}

inline reshade::api::resource_view GetBiasCurrentColorMaskSrv(reshade::api::command_list*) {
  std::scoped_lock lock(runtime_mutex);
  return resources.bias_current_color_mask_srv;
}

inline void InstallCallbacks(
    renodx::mods::shader::CustomShaders& shaders,
    ShaderInjectData* data) {
  shader_injection = data;
  jitter::SetDlaaEnabledBinding(&enabled);
  if (installed_callbacks) return;

  for (const uint32_t shader_hash : resource_logger::kPostProcessShaders) {
    const auto shader = shaders.find(shader_hash);
    if (shader == shaders.end()) continue;

    const auto previous_on_draw = shader->second.on_draw;
    shader->second.on_draw = [previous_on_draw](reshade::api::command_list* cmd_list) {
      if (previous_on_draw != nullptr && !previous_on_draw(cmd_list)) return false;
      if (!RunMotionVectorPrepass(cmd_list)) return false;
      return RunDlaa(cmd_list);
    };
    shader->second.views.push_back({
        .type = reshade::api::descriptor_type::texture_shader_resource_view,
        .slot = 0u,
        .space = 50u,
        .get_view = GetMotionVectorSrv,
    });
    shader->second.views.push_back({
        .type = reshade::api::descriptor_type::texture_shader_resource_view,
        .slot = 1u,
        .space = 50u,
        .get_view = GetDlaaOutputSrv,
    });
    shader->second.views.push_back({
        .type = reshade::api::descriptor_type::texture_shader_resource_view,
        .slot = 2u,
        .space = 50u,
        .get_view = GetBiasCurrentColorMaskSrv,
    });
  }
  installed_callbacks = true;
}

inline void OnInitCommandList(reshade::api::command_list* cmd_list) {
  cmd_list->create_private_data<CommandListData>();
}

inline void OnDestroyCommandList(reshade::api::command_list* cmd_list) {
  cmd_list->destroy_private_data<CommandListData>();
}

inline void OnResetCommandList(reshade::api::command_list* cmd_list) {
  auto* data = Get(cmd_list);
  if (data != nullptr) *data = {};
}

inline void OnPushDescriptors(
    reshade::api::command_list* cmd_list,
    reshade::api::shader_stage stages,
    reshade::api::pipeline_layout layout,
    uint32_t layout_param,
    const reshade::api::descriptor_table_update& update) {
  if (update.type != reshade::api::descriptor_type::constant_buffer
      || !renodx::utils::bitwise::HasFlag(stages, reshade::api::shader_stage::pixel)) {
    return;
  }

  auto* data = Get(cmd_list);
  if (data == nullptr) return;
  for (uint32_t i = 0u; i < update.count; ++i) {
    uint32_t register_index = 0u;
    uint32_t register_space = 0u;
    if (!ResolveRegister(layout, layout_param, update, i, register_index, register_space)
        || register_index != 0u
        || register_space != 0u) {
      continue;
    }

    data->pixel_cb_b0 = static_cast<const reshade::api::buffer_range*>(update.descriptors)[i];
    data->pixel_cb_b0_layout = layout;
  }
}

inline void OnInitResource(
    reshade::api::device*,
    const reshade::api::resource_desc&,
    const reshade::api::subresource_data*,
    reshade::api::resource_usage initial_state,
    reshade::api::resource resource) {
  SetResourceState(resource, initial_state);
}

inline void OnBarrier(
    reshade::api::command_list*,
    uint32_t count,
    const reshade::api::resource* barrier_resources,
    const reshade::api::resource_usage*,
    const reshade::api::resource_usage* new_states) {
  if (barrier_resources == nullptr || new_states == nullptr) return;
  const std::unique_lock lock(resource_state_mutex);
  for (uint32_t i = 0u; i < count; ++i) {
    if (barrier_resources[i].handle != 0u) resource_states[barrier_resources[i].handle] = new_states[i];
  }
}

inline void OnDestroyResource(reshade::api::device*, reshade::api::resource resource) {
  jitter::ForgetResource(resource);
  const std::unique_lock lock(resource_state_mutex);
  resource_states.erase(resource.handle);
}

inline void OnInitDevice(reshade::api::device* device) {
  DetectD3D12Adapter(device);
}

inline void OnDestroyDevice(reshade::api::device* device) {
  std::scoped_lock lock(runtime_mutex);
  Destroy(device);
  if (device == detected_d3d12_device) {
    detected_d3d12_device = nullptr;
    is_nvidia_device = false;
    const std::unique_lock state_lock(resource_state_mutex);
    resource_states.clear();
  }
}

inline void Use(DWORD fdw_reason) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!installed_events) {
        installed_events = true;
        reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
        reshade::register_event<reshade::addon_event::init_resource>(OnInitResource);
        reshade::register_event<reshade::addon_event::destroy_resource>(OnDestroyResource);
        reshade::register_event<reshade::addon_event::barrier>(OnBarrier);
        reshade::register_event<reshade::addon_event::init_command_list>(OnInitCommandList);
        reshade::register_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
        reshade::register_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
        reshade::register_event<reshade::addon_event::push_descriptors>(OnPushDescriptors);
        reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
      }
      break;
    case DLL_PROCESS_DETACH:
      if (installed_events) {
        installed_events = false;
        reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
        reshade::unregister_event<reshade::addon_event::init_resource>(OnInitResource);
        reshade::unregister_event<reshade::addon_event::destroy_resource>(OnDestroyResource);
        reshade::unregister_event<reshade::addon_event::barrier>(OnBarrier);
        reshade::unregister_event<reshade::addon_event::init_command_list>(OnInitCommandList);
        reshade::unregister_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
        reshade::unregister_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
        reshade::unregister_event<reshade::addon_event::push_descriptors>(OnPushDescriptors);
        reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
      }
      break;
  }
}

}  // namespace lorwin::dlaa
