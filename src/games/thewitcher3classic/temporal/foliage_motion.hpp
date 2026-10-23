/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11.h>
#include <wrl/client.h>
#include <array>
#include <unordered_map>
#include "./constant_uploads.hpp"

namespace witcher3classic::temporal {
// SpeedTree constants have stable per-model buffer identities. Frame, collision
// and main-scene constants are shared; copy each source only once per frame.
// Keep source references alive so recycled addresses cannot inherit history.
class FoliageMotion {
 public:
  std::array<ID3D11Buffer*, 6> previous = {};
  ID3D11Buffer* metadata = nullptr;
  HRESULT error = S_OK;

  bool Prepare(ID3D11DeviceContext* context, uint64_t frame, uint32_t required_constants, ID3D11Buffer* frame_constants, ConstantUploads* uploads) {
    constexpr UINT sizes[] = {784, 480, 352, 288, 1104, 4304};
    previous.fill(nullptr);
    std::array<Microsoft::WRL::ComPtr<ID3D11Buffer>, 6> sources;
    std::array<ID3D11Buffer*, 4> model = {};
    context->VSGetConstantBuffers(0, UINT(model.size()), model.data());
    for (size_t i = 0; i < model.size(); ++i) sources[i].Attach(model[i]);
    if (required_constants & 16) context->VSGetConstantBuffers(11, 1, &sources[4]);
    sources[5] = frame_constants;
    Microsoft::WRL::ComPtr<ID3D11Device> device;
    bool valid = true;
    for (size_t i = 0; i < sources.size(); ++i) {
      if (!(required_constants & (1u << i))) continue;
      if (!sources[i]) return false;
      auto found = history_.find(sources[i].Get());
      if (found == history_.end()) {
        if (history_.size() >= 1024) return false;
        D3D11_BUFFER_DESC desc;
        sources[i]->GetDesc(&desc);
        if (desc.ByteWidth != sizes[i]) return false;
        found = history_.try_emplace(sources[i].Get()).first;
        found->second.source = sources[i];
        found->second.size = desc.ByteWidth;
      }
      auto& history = found->second;
      if (history.size != sizes[i]) return false;
      if (!history.buffers[0] || !history.buffers[1]) {
        if (!device) context->GetDevice(&device);
        const D3D11_BUFFER_DESC desc{sizes[i], D3D11_USAGE_DYNAMIC, D3D11_BIND_CONSTANT_BUFFER, D3D11_CPU_ACCESS_WRITE};
        for (auto& buffer : history.buffers) {
          error = device->CreateBuffer(&desc, nullptr, &buffer);
          if (FAILED(error)) return false;
        }
        // Defined initial contents even on a new model/history gap. The shader
        // skips previous deformation until all inputs have consecutive history.
        uploads->Snapshot(context, history.buffers[0].Get(), sources[i].Get(), frame);
      }
      if (history.observed != frame) {
        uploads->Snapshot(context, history.buffers[1].Get(), sources[i].Get(), frame);
        history.observed = frame;
      }
      valid &= history.committed != UINT64_MAX && history.committed + 1 == frame;
      previous[i] = history.buffers[0].Get();
    }
    if (!validity_[valid]) {
      if (!device) context->GetDevice(&device);
      const UINT constants[] = {UINT(valid), 0, 0, 0};
      const D3D11_BUFFER_DESC desc{sizeof(constants), D3D11_USAGE_IMMUTABLE, D3D11_BIND_CONSTANT_BUFFER};
      const D3D11_SUBRESOURCE_DATA initial{constants};
      error = device->CreateBuffer(&desc, &initial, &validity_[valid]);
      if (FAILED(error)) return false;
    }
    metadata = validity_[valid].Get();
    return true;
  }

  void Finish(uint64_t frame) {
    for (auto it = history_.begin(); it != history_.end();) {
      auto& history = it->second;
      if (history.observed == frame && history.committed != frame) {
        history.buffers[0].Swap(history.buffers[1]);
        history.committed = frame;
      }
      if (history.observed != UINT64_MAX && frame > history.observed + 120)
        it = history_.erase(it);
      else
        ++it;
    }
  }

  void Clear() {
    history_.clear();
    previous.fill(nullptr);
    metadata = nullptr;
  }

 private:
  struct History {
    Microsoft::WRL::ComPtr<ID3D11Buffer> source;
    std::array<Microsoft::WRL::ComPtr<ID3D11Buffer>, 2> buffers;
    UINT size = 0;
    uint64_t observed = UINT64_MAX, committed = UINT64_MAX;
  };
  std::unordered_map<ID3D11Buffer*, History> history_;
  std::array<Microsoft::WRL::ComPtr<ID3D11Buffer>, 2> validity_;
};
}  // namespace witcher3classic::temporal
