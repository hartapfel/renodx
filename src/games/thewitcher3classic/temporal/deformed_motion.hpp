/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11.h>
#include <wrl/client.h>
#include <array>
#include <map>
#include <tuple>
#include "./object_engine.hpp"
#include "./constant_uploads.hpp"

namespace witcher3classic::temporal {
// CPU-deformed faces and cloth rotate native position/index buffers. Vertex
// identity comes from the native owner and immutable UV stream, not that ring.
class DeformedMotion {
 public:
  ID3D11ShaderResourceView* vertices = nullptr;
  ID3D11Buffer* world = nullptr;
  ID3D11Buffer* metadata = nullptr;
  HRESULT error = S_OK;

  bool Prepare(ID3D11DeviceContext* context, uint64_t frame, ConstantUploads* uploads) {
    vertices = nullptr;
    world = metadata = nullptr;
    if (!object_engine::deformed_owner) return false;
    std::array<ID3D11Buffer*, 2> buffers = {};
    std::array<UINT, 2> strides = {}, offsets = {};
    context->IAGetVertexBuffers(0, 2, buffers.data(), strides.data(), offsets.data());
    Microsoft::WRL::ComPtr<ID3D11Buffer> uv, positions, indices, current_world;
    uv.Attach(buffers[0]);
    positions.Attach(buffers[1]);
    DXGI_FORMAT index_format;
    UINT index_offset;
    context->IAGetIndexBuffer(&indices, &index_format, &index_offset);
    context->VSGetConstantBuffers(2, 1, &current_world);
    if (!uv || !positions || !indices || !current_world || strides[0] != 8 || strides[1] != 40
        || offsets[0] || offsets[1] || index_offset || index_format != DXGI_FORMAT_R32_UINT) return false;
    D3D11_BUFFER_DESC position_desc, world_desc, uv_desc;
    positions->GetDesc(&position_desc);
    current_world->GetDesc(&world_desc);
    uv->GetDesc(&uv_desc);
    if (!position_desc.ByteWidth || position_desc.ByteWidth % 40 || position_desc.ByteWidth > 1024 * 1024
        || uv_desc.ByteWidth / 8 != position_desc.ByteWidth / 40 || uv_desc.ByteWidth % 8
        || world_desc.ByteWidth != 128) return false;
    const auto key = std::tuple{object_engine::deformed_owner, object_engine::deformed_generation, uv.Get()};
    if (!history_.contains(key) && (history_.size() >= 128 || bytes_ + 2 * position_desc.ByteWidth > 32 * 1024 * 1024)) return false;
    auto& history = history_[key];
    if (history.bytes && history.bytes != position_desc.ByteWidth) return false;
    Microsoft::WRL::ComPtr<ID3D11Device> device;
    context->GetDevice(&device);
    if (!history.views[0] || !history.views[1] || !history.constants) {
      if (!history.bytes) {
        history.bytes = position_desc.ByteWidth;
        bytes_ += 2 * history.bytes;
      }
      history.uv = uv;
      position_desc.Usage = D3D11_USAGE_DEFAULT;
      position_desc.CPUAccessFlags = 0;
      position_desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
      position_desc.MiscFlags = D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS;
      position_desc.StructureByteStride = 0;
      world_desc.Usage = D3D11_USAGE_DYNAMIC;
      world_desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
      world_desc.MiscFlags = 0;
      for (size_t i = 0; i < 2; ++i) {
        error = device->CreateBuffer(&position_desc, nullptr, &history.positions[i]);
        if (FAILED(error)) return false;
        D3D11_SHADER_RESOURCE_VIEW_DESC view = {};
        view.Format = DXGI_FORMAT_R32_TYPELESS;
        view.ViewDimension = D3D11_SRV_DIMENSION_BUFFEREX;
        view.BufferEx.NumElements = history.bytes / 4;
        view.BufferEx.Flags = D3D11_BUFFEREX_SRV_FLAG_RAW;
        error = device->CreateShaderResourceView(history.positions[i].Get(), &view, &history.views[i]);
        if (FAILED(error)) return false;
        error = device->CreateBuffer(&world_desc, nullptr, &history.worlds[i]);
        if (FAILED(error)) return false;
      }
      const D3D11_BUFFER_DESC desc{16, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER};
      error = device->CreateBuffer(&desc, nullptr, &history.constants);
      if (FAILED(error)) return false;
      history.committed = UINT64_MAX;
    }
    if (history.observed != frame) {
      context->CopyResource(history.positions[1].Get(), positions.Get());
      uploads->Snapshot(context, history.worlds[1].Get(), current_world.Get(), frame);
      history.observed = frame;
      const uint32_t constants[] = {history.bytes, strides[1], 0, uint32_t(history.committed != UINT64_MAX && history.committed + 1 == frame)};
      context->UpdateSubresource(history.constants.Get(), 0, nullptr, constants, 0, 0);
    }
    vertices = history.views[0].Get();
    world = history.worlds[0].Get();
    metadata = history.constants.Get();
    return true;
  }

  void Finish(uint64_t frame) {
    for (auto it = history_.begin(); it != history_.end();) {
      auto& history = it->second;
      if (history.observed == frame) {
        history.positions[0].Swap(history.positions[1]);
        history.views[0].Swap(history.views[1]);
        history.worlds[0].Swap(history.worlds[1]);
        history.committed = frame;
      }
      if (history.observed != UINT64_MAX && frame > history.observed + 120) {
        bytes_ -= 2 * history.bytes;
        it = history_.erase(it);
      } else
        ++it;
    }
  }
  void Clear() {
    history_.clear();
    bytes_ = 0;
  }

 private:
  struct History {
    Microsoft::WRL::ComPtr<ID3D11Buffer> uv, constants;
    std::array<Microsoft::WRL::ComPtr<ID3D11Buffer>, 2> positions, worlds;
    std::array<Microsoft::WRL::ComPtr<ID3D11ShaderResourceView>, 2> views;
    uint64_t observed = UINT64_MAX, committed = UINT64_MAX;
    uint32_t bytes = 0;
  };
  std::map<std::tuple<uintptr_t, uint64_t, ID3D11Buffer*>, History> history_;
  uint32_t bytes_ = 0;
};
}  // namespace witcher3classic::temporal
