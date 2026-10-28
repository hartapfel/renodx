/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d12.h>
#include <wrl/client.h>
#include <algorithm>
#include <cstdint>
#include <memory>
#include <vector>

namespace renodx::utils::d3d12_resource_pool {
using Microsoft::WRL::ComPtr;
// A recording owns its allocations until reset/destruction. Only then can we
// signal AFTER every execution of that recording. Signalling in ReShade's
// execute_command_list callback would be too early (it precedes ExecuteCommandLists).
struct Completion {
  ComPtr<ID3D12Fence> fence;
  uint64_t value = 0;
};
struct Queue {
  ID3D12CommandQueue* native = nullptr;
  ComPtr<ID3D12Fence> fence;
  uint64_t serial = 0;
};
struct Allocation {
  ComPtr<ID3D12Resource> scratch, constants;
  uint8_t* mapped = nullptr;
  uint64_t bytes = 0, idle_frame = 0;
  uint32_t used = 0;
  bool leased = false;
  std::vector<Completion> completion;
  std::vector<ComPtr<IUnknown>> objects;
  ~Allocation() { if (mapped) constants->Unmap(0, nullptr); }
  bool Ready() const {
    return !leased && std::all_of(completion.begin(), completion.end(), [](const auto& c) {
      return c.value != UINT64_MAX && c.fence->GetCompletedValue() >= c.value;
    });
  }
};
// Callers serialize pool/queue operations and retire a recording only after its
// last submission. UploadBytes is zero for passes using root constants.
template <uint64_t Budget, uint64_t UploadBytes = 0>
class ResourcePool {
 public:
  // Includes upload pages. Exhaustion preserves native rendering; never wait for the
  // GPU or keep allocating when the GPU falls behind or command lists linger.
  static constexpr uint64_t LIMIT = Budget;
  static constexpr uint64_t UPLOAD_BYTES = UploadBytes;
  uint64_t bytes = 0, peak_bytes = 0, frame = 0;
  std::vector<std::shared_ptr<Allocation>> allocations;

  void Collect(bool trim = false) {
    uint32_t idle = 0;
    std::erase_if(allocations, [&](const auto& a) {
      if (!a->Ready()) return false;
      a->completion.clear();
      if (!trim && ++idle <= 2 && frame - a->idle_frame < 120) return false;
      bytes -= a->bytes + UploadBytes;
      return true;
    });
  }
  std::shared_ptr<Allocation> Acquire(ID3D12Device* dev, uint64_t size) {
    if (size == 0 || size > Budget || UploadBytes > Budget - size) return nullptr;
    size = (size + 65535) & ~65535ull;
    Collect();
    for (auto& a : allocations) {
      if (a->Ready() && a->bytes >= size && a->bytes < size + (16ull << 20)) {
        a->leased = true;
        a->used = 0;
        a->objects.clear();
        return a;
      }
    }
    if (bytes + size + UploadBytes > LIMIT) Collect(true);
    if (bytes + size + UploadBytes > LIMIT) return nullptr;
    auto a = std::make_shared<Allocation>();
    D3D12_HEAP_PROPERTIES heap{};
    heap.Type = D3D12_HEAP_TYPE_DEFAULT;
    D3D12_RESOURCE_DESC desc{};
    desc.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
    desc.Width = size;
    desc.Height = desc.DepthOrArraySize = desc.MipLevels = desc.SampleDesc.Count = 1;
    desc.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
    desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS;
    if (FAILED(dev->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_NONE, &desc,
                                           D3D12_RESOURCE_STATE_UNORDERED_ACCESS, nullptr, IID_PPV_ARGS(&a->scratch)))) return nullptr;
    if constexpr (UploadBytes != 0) {
      heap.Type = D3D12_HEAP_TYPE_UPLOAD;
      desc.Width = UploadBytes;
      desc.Flags = D3D12_RESOURCE_FLAG_NONE;
      if (FAILED(dev->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_NONE, &desc,
                                             D3D12_RESOURCE_STATE_GENERIC_READ, nullptr, IID_PPV_ARGS(&a->constants)))) return nullptr;
      const D3D12_RANGE empty{0, 0};
      if (FAILED(a->constants->Map(0, &empty, reinterpret_cast<void**>(&a->mapped)))) return nullptr;
    }
    a->bytes = size;
    a->leased = true;
    bytes += size + UploadBytes;
    peak_bytes = std::max(peak_bytes, bytes);
    allocations.push_back(a);
    return a;
  }
  void Retire(std::vector<std::shared_ptr<Allocation>>* recording,
              std::vector<std::shared_ptr<Queue>>* queues, bool untracked = false) {
    if (recording->empty()) { queues->clear(); return; }
    std::vector<Completion> completion;
    for (const auto& q : *queues) {
      if (!q->native) { completion.push_back({q->fence, q->serial}); continue; }
      const uint64_t serial = ++q->serial;
      // A failed signal quarantines the allocation within the hard budget.
      completion.push_back({q->fence, SUCCEEDED(q->native->Signal(q->fence.Get(), serial)) ? serial : UINT64_MAX});
    }
    for (auto& a : *recording) {
      a->completion = completion;
      a->leased = untracked;
      a->idle_frame = frame;
    }
    recording->clear();
    queues->clear();
    Collect();
  }
};
}  // namespace renodx::utils::d3d12_resource_pool
