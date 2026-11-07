// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <array>
#include <cstring>
#include <memory>
#include <d3d12.h>
#include <wrl/client.h>
#include "../rendering/bindings.hpp"

namespace witcher3graphics::raytracing {
// Immutable shader identifiers, owned independently of the native state object.
// A field retains every selector used by its recording until submission leases
// retire. No shader table readback or CPU guess about the selected export.
class HitSelection {
 public:
  using Identifier = std::array<uint32_t, 8>;
  struct alignas(256) Constants {
    std::array<Identifier, 6> identifiers{};
    uint32_t available = 0;
  };
  explicit HitSelection(reshade::api::device* dev) : device_(dev) {}
  ~HitSelection() { if (buffer_.handle) device_->destroy_resource(buffer_); }
  HitSelection(const HitSelection&) = delete;
  HitSelection& operator=(const HitSelection&) = delete;
  bool Initialize(ID3D12StateObject* state, const std::array<bool, 3>& enabled) {
    if (buffer_.handle || !state) return false;
    Microsoft::WRL::ComPtr<ID3D12StateObjectProperties> properties;
    if (FAILED(state->QueryInterface(IID_PPV_ARGS(&properties)))) return false;
    Constants constants;
    constexpr std::array names{L"RadianceRGS", L"RadianceRGSWithSER", L"GlobalGridProbeRGS",
        L"GlobalGridProbeRGSWithSER", L"LocalGridProbeRGS", L"LocalGridProbeRGSWithSER"};
    for (uint32_t i = 0; i < names.size(); ++i) {
      if (!enabled[i / 2]) continue;
      if (const auto* identifier = properties->GetShaderIdentifier(names[i])) {
        std::memcpy(constants.identifiers[i].data(), identifier, D3D12_SHADER_IDENTIFIER_SIZE_IN_BYTES);
        constants.available |= 1u << i;
      }
    }
    if (!constants.available) return false;
    using namespace reshade::api;
    if (!device_->create_resource(resource_desc(uint64_t(sizeof(Constants)), memory_heap::cpu_to_gpu, resource_usage::constant_buffer),
            nullptr, resource_usage::general, &buffer_)) return false;
    void* mapped = nullptr;
    if (!device_->map_buffer_region(buffer_, 0, sizeof(Constants), map_access::write_only, &mapped)) return false;
    std::memcpy(mapped, &constants, sizeof(constants)); device_->unmap_buffer_region(buffer_);
    return true;
  }
  bool Bind(reshade::api::command_list* cmd, reshade::api::pipeline_layout layout,
      uint32_t identifiers_root, uint32_t raygen_root, uint64_t raygen_address) const {
    using namespace reshade::api;
    if (!buffer_.handle || cmd->get_device() != device_ || !raygen_address || (raygen_address & 63u)) return false;
    const buffer_range range{buffer_, 0, sizeof(Constants)};
    cmd->push_descriptors(shader_stage::compute, layout, identifiers_root,
        {{}, 0, 0, 1, descriptor_type::constant_buffer, &range});
    // The ray record is already in NON_PIXEL_SHADER_RESOURCE for DispatchRays.
    // ReShade may supply its raw GPU VA with a null resource handle. A root SRV
    // reads exactly the identifier's 32 bytes, preserving the native SBT.
    reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native())->SetComputeRootShaderResourceView(raygen_root, raygen_address);
    return true;
  }
 private:
  reshade::api::device* device_;
  reshade::api::resource buffer_{};
};
static_assert(sizeof(HitSelection::Constants) == 256);
static_assert(offsetof(HitSelection::Constants, available) == 192);
struct HitSelectionDispatch {
  std::shared_ptr<const HitSelection> identifiers;
  uint64_t raygen_address = 0;
  uint32_t identifiers_root = UINT32_MAX, raygen_root = UINT32_MAX;
};
}  // namespace witcher3graphics::raytracing
