/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11.h>
#include <wrl/client.h>
#include "./object_engine.hpp"

namespace witcher3classic::temporal {
class RigidMotion {
 public:
  Microsoft::WRL::ComPtr<ID3D11ShaderResourceView> poses;
  Microsoft::WRL::ComPtr<ID3D11Buffer> metadata;
  HRESULT error = S_OK;

  bool Prepare(ID3D11DeviceContext* context, uint64_t frame, bool skinned = false) {
    const auto swarm = object_engine::swarm_batch;
    auto batch = object_engine::batch;
    std::array<float, 20> direct = {};
    std::array<ObjectPose, 1> direct_pose;
    if (!batch.instances && object_engine::direct_object) {
      const auto* world = reinterpret_cast<const float*>(object_engine::direct_object + 0x40);
      for (uint32_t row = 0; row < 3; ++row)
        for (uint32_t column = 0; column < 4; ++column) direct[row * 4 + column] = world[column * 4 + row];
      if (skinned) {
        const auto allocation = *reinterpret_cast<const uintptr_t*>(object_engine::direct_object + 0x180);
        if (allocation) std::copy_n(reinterpret_cast<const float*>(allocation + 0x20), 4, direct.begin() + 16);
      }
      {
        std::lock_guard lock(object_engine::state->mutex);
        WorldTransform world;
        std::copy_n(direct.begin(), 12, world.begin());
        direct_pose[0] = object_engine::state->rigid_history.Previous(frame, object_engine::direct_object, object_engine::direct_mesh, world);
      }
      batch = {direct.data(), 1, skinned ? 80u : 64u, direct_pose};
    }
    if (!swarm.empty()) {
      if (!skinned || swarm.size() > 4096) return false;
      entries_.assign(swarm.begin(), swarm.end());
    } else {
      if (!batch.instances || !batch.count || batch.count > 4096 || batch.previous.size() != batch.count
          || batch.stride != (skinned ? 80u : 64u)) return false;
      if (!skinned) {
        bool moved = false;
        for (uint32_t i = 0; !moved && i < batch.count; ++i)
          moved = batch.previous[i].valid && !std::equal(batch.previous[i].world.begin(), batch.previous[i].world.end(), batch.instances + i * (batch.stride / sizeof(float)));
        // Camera reprojection already handles stationary rigid geometry. Do
        // not add MRT writes for it, including in the object diagnostic view.
        if (!moved) return false;
      }
      entries_.assign(batch.previous.begin(), batch.previous.end());
    }
    if (!poses || !metadata) {
      Microsoft::WRL::ComPtr<ID3D11Device> device;
      context->GetDevice(&device);
      const D3D11_BUFFER_DESC desc{4096 * sizeof(ObjectPose), D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE, 0, D3D11_RESOURCE_MISC_BUFFER_STRUCTURED, sizeof(ObjectPose)};
      error = device->CreateBuffer(&desc, nullptr, &buffer_);
      if (FAILED(error)) return false;
      error = device->CreateShaderResourceView(buffer_.Get(), nullptr, &poses);
      if (FAILED(error)) return false;
      const D3D11_BUFFER_DESC constants{16, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER};
      error = device->CreateBuffer(&constants, nullptr, &metadata);
      if (FAILED(error)) return false;
    }
    const D3D11_BOX region{0, 0, 0, UINT(entries_.size() * sizeof(ObjectPose)), 1, 1};
    context->UpdateSubresource(buffer_.Get(), 0, &region, entries_.data(), 0, 0);
    const uint32_t count[] = {uint32_t(entries_.size()), uint32_t(skinned), 0, 0};
    context->UpdateSubresource(metadata.Get(), 0, nullptr, count, 0, 0);
    return true;
  }

 private:
  Microsoft::WRL::ComPtr<ID3D11Buffer> buffer_;
  std::vector<ObjectPose> entries_;
};
}  // namespace witcher3classic::temporal
