/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <embed/0xF3C20002.h>
#include <map>
#include <tuple>
#include "../temporal/context.hpp"
namespace witcher3classic::optics {
class MotionCamera {
 public:
  ID3D11ShaderResourceView* Prepare(ID3D11DeviceContext1* context, ID3D11Buffer* current,
                                    ID3D11Buffer* previous, ID3D11Buffer* current_frame, ID3D11Buffer* previous_frame, uint64_t frame) {
    if (!current || !previous || !current_frame || !previous_frame) return nullptr;
    Microsoft::WRL::ComPtr<ID3D11Device> device;
    context->GetDevice(&device);
    if (!shader_) {
      if (FAILED(device->CreateComputeShader(__0xF3C20002.data(), __0xF3C20002.size(), nullptr, &shader_))
          || FAILED(temporal::CreateIsolatedState(device.Get(), &state_))) return nullptr;
    }
    if (entries_.size() > 32) entries_.clear();
    auto& entry = entries_[{current, previous}];
    if (!entry.view) {
      entry.current = current;
      entry.previous = previous;
      const D3D11_BUFFER_DESC desc{64, D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_UNORDERED_ACCESS,
                                   0, D3D11_RESOURCE_MISC_BUFFER_STRUCTURED, 16};
      if (FAILED(device->CreateBuffer(&desc, nullptr, &entry.buffer))
          || FAILED(device->CreateShaderResourceView(entry.buffer.Get(), nullptr, &entry.view))
          || FAILED(device->CreateUnorderedAccessView(entry.buffer.Get(), nullptr, &entry.output))) return nullptr;
    }
    if (entry.frame != frame) {
      temporal::ContextScope restore(context, state_.Get());
      ID3D11Buffer* constants[] = {current, previous, current_frame, previous_frame};
      ID3D11UnorderedAccessView* output = entry.output.Get();
      context->CSSetShader(shader_.Get(), nullptr, 0);
      context->CSSetConstantBuffers(0, 4, constants);
      context->CSSetUnorderedAccessViews(0, 1, &output, nullptr);
      context->Dispatch(1, 1, 1);
      entry.frame = frame;
    }
    return entry.view.Get();
  }

 private:
  struct Entry {
    Microsoft::WRL::ComPtr<ID3D11Buffer> current, previous, buffer;
    Microsoft::WRL::ComPtr<ID3D11ShaderResourceView> view;
    Microsoft::WRL::ComPtr<ID3D11UnorderedAccessView> output;
    uint64_t frame = UINT64_MAX;
  };
  std::map<std::pair<ID3D11Buffer*, ID3D11Buffer*>, Entry> entries_;
  Microsoft::WRL::ComPtr<ID3D11ComputeShader> shader_;
  Microsoft::WRL::ComPtr<ID3DDeviceContextState> state_;
};
}  // namespace witcher3classic::optics
