/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <cstring>
#include <d3d12.h>
#include <include/reshade.hpp>

#include "../../utils/data.hpp"
#include "./native_bloom_shared.h"

namespace witcher::bloom {

// Private to this addon. No descriptor heap or constant-buffer history.
struct __declspec(uuid("d8c6a19b-1bba-483c-ad6d-3682c2d6a4ba")) CommandData {
  reshade::api::resource reference = {};
  reshade::api::resource zero_upload = {};
  reshade::api::resource_view view = {};
  bool initialized = false;
  bool shafts = false;
  bool attempted = false;
};

inline void OnInitCommand(reshade::api::command_list* cmd) {
  renodx::utils::data::Create<CommandData>(cmd);
}

inline void OnDestroyCommand(reshade::api::command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) {
    auto* device = cmd->get_device();
    if (data->reference.handle != 0) device->destroy_resource(data->reference);
    if (data->zero_upload.handle != 0) device->destroy_resource(data->zero_upload);
    renodx::utils::data::Delete<CommandData>(cmd);
  }
}

inline void OnResetCommand(reshade::api::command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) {
    data->initialized = false;
    data->shafts = false;
  }
}

inline reshade::api::resource_view GetReference(reshade::api::command_list* cmd) {
  using namespace reshade::api;
  auto* data = renodx::utils::data::Get<CommandData>(cmd);
  if (data == nullptr) return {};
  auto* device = cmd->get_device();
  if (!data->attempted) {
    data->attempted = true;
    void* zeros = nullptr;
    if (!device->create_resource(resource_desc(WITCHER_BLOOM_REFERENCE_BYTES, memory_heap::cpu_to_gpu,
              resource_usage::copy_source), nullptr, resource_usage::cpu_access, &data->zero_upload)
        || !device->map_buffer_region(data->zero_upload, 0, WITCHER_BLOOM_REFERENCE_BYTES,
                                      map_access::write_only, &zeros)) {
      reshade::log::message(reshade::log::level::warning, "Witcher HDR: native bloom reference initialization unavailable.");
      return {};
    }
    std::memset(zeros, 0, WITCHER_BLOOM_REFERENCE_BYTES);
    device->unmap_buffer_region(data->zero_upload);
    if (!device->create_resource(resource_desc(WITCHER_BLOOM_REFERENCE_BYTES, memory_heap::gpu_only,
              resource_usage::unordered_access | resource_usage::copy_dest), nullptr,
              resource_usage::unordered_access, &data->reference)) {
      reshade::log::message(reshade::log::level::warning, "Witcher HDR: native bloom reference buffer unavailable.");
      return {};
    }
    // DX12 buffer root views are GPU addresses, not heap descriptors. This also
    // avoids descriptor heap allocation or tracking for this buffer.
    data->view = resource_view{reinterpret_cast<ID3D12Resource*>(data->reference.handle)->GetGPUVirtualAddress()};
  }
  if (data->view.handle == 0) return {};
  if (!data->initialized) {
    cmd->barrier(data->reference, resource_usage::unordered_access, resource_usage::copy_dest);
    cmd->copy_buffer_region(data->zero_upload, 0, data->reference, 0, WITCHER_BLOOM_REFERENCE_BYTES);
    cmd->barrier(data->reference, resource_usage::copy_dest, resource_usage::unordered_access);
    data->initialized = true;
  }
  return resource_view{data->view.handle + (data->shafts ? WITCHER_BLOOM_REFERENCE_STRIDE : 0u)};
}

inline bool BeginCapture(reshade::api::command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) data->shafts = false;
  return true;
}

inline void FinishCapture(reshade::api::command_list* cmd) {
  if (const auto* data = renodx::utils::data::Get<CommandData>(cmd); data != nullptr && data->view.handle != 0) {
    cmd->barrier(data->reference, reshade::api::resource_usage::unordered_access,
                 reshade::api::resource_usage::unordered_access);
  }
}

inline void MarkShafts(reshade::api::command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) data->shafts = true;
}

inline void FinishExtraction(reshade::api::command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) data->shafts = false;
}

inline void Use(DWORD reason) {
#define WITCHER_BLOOM_EVENT(event, callback) \
  if (reason == DLL_PROCESS_ATTACH) reshade::register_event<reshade::addon_event::event>(callback); \
  else if (reason == DLL_PROCESS_DETACH) reshade::unregister_event<reshade::addon_event::event>(callback)
  WITCHER_BLOOM_EVENT(init_command_list, OnInitCommand);
  WITCHER_BLOOM_EVENT(destroy_command_list, OnDestroyCommand);
  WITCHER_BLOOM_EVENT(reset_command_list, OnResetCommand);
#undef WITCHER_BLOOM_EVENT
}

}  // namespace witcher::bloom
