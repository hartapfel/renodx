/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11_4.h>
#include <d3d12.h>
#include <dxgi1_4.h>
#include <wrl/client.h>
#include <array>
#include <cstdint>
#include <exception>
#include <functional>

namespace witcher3classic::frame_generation {
using Microsoft::WRL::ComPtr;

// Same-adapter transport only. The presenter owns device/queue creation so it
// can initialize Streamline and upgrade interfaces BEFORE creating its queue.
// Microsoft: Direct3D 12 interop; ResourceHeaps (sharing with older runtimes).
// No keyed mutex, cross-adapter/system-memory heap, or production CPU readback.
class Interop {
 public:
  static constexpr size_t kSlotCount = 3;
  enum Input : size_t { Color,
                        Hudless,
                        Depth,
                        Motion,
                        UIAlpha,
                        InputCount };
  struct Layout {
    uint32_t output_width = 0, output_height = 0;
    uint32_t render_width = 0, render_height = 0;
  };
  struct Texture {
    ComPtr<ID3D12Resource> d12;
    ComPtr<ID3D11Texture2D> d11;
  };
  struct Slot {
    std::array<Texture, InputCount> textures;
    uint64_t produced = 0, consumed = 0;
    enum class State { Free,
                       Writing,
                       Published,
                       Reading,
                       Retiring } state = State::Free;
  };

  Interop() = default;
  Interop(const Interop&) = delete;
  Interop& operator=(const Interop&) = delete;
  ~Interop() {
    // A Reading slot can still be owned by Streamline's asynchronous queue.
    // Silently releasing it would be GPU use-after-free. This is a caller
    // contract violation, distinct from a recoverable removed-device result.
    if (Drain() == E_PENDING) std::terminate();
  }

  // All methods run on the immediate-context/present thread. Only initialize
  // a fresh transport. Resize builds a new transport after draining the old one.
  HRESULT Initialize(ID3D11Device* d11, ID3D12Device* d12, ID3D12CommandQueue* queue, const Layout& layout,
                     const std::function<bool(ID3D12Device*, ID3D12Device*)>& same_device = {}) {
    if (device12_ || !d11 || !d12 || !queue || !layout.output_width || !layout.output_height
        || !layout.render_width || !layout.render_height || layout.output_width > 16384
        || layout.output_height > 16384 || layout.render_width > layout.output_width
        || layout.render_height > layout.output_height) return E_INVALIDARG;
    ComPtr<IDXGIDevice> dxgi;
    ComPtr<IDXGIAdapter> adapter;
    DXGI_ADAPTER_DESC desc{};
    HRESULT hr = d11->QueryInterface(IID_PPV_ARGS(&dxgi));
    if (FAILED(hr)) return hr;
    if (FAILED(hr = dxgi->GetAdapter(&adapter)) || FAILED(hr = adapter->GetDesc(&desc))) return hr;
    const auto luid = d12->GetAdapterLuid();
    if (luid.HighPart != desc.AdapterLuid.HighPart || luid.LowPart != desc.AdapterLuid.LowPart
        || queue->GetDesc().Type != D3D12_COMMAND_LIST_TYPE_DIRECT) return E_INVALIDARG;
    ComPtr<ID3D12Device> queue_device;
    ComPtr<IUnknown> device_identity, queue_identity;
    if (FAILED(hr = queue->GetDevice(IID_PPV_ARGS(&queue_device)))
        || FAILED(hr = d12->QueryInterface(IID_PPV_ARGS(&device_identity)))
        || FAILED(hr = queue_device.As(&queue_identity))) return hr;
    if (device_identity != queue_identity && (!same_device || !same_device(d12, queue_device.Get()))) return E_INVALIDARG;
    ComPtr<ID3D11Device5> device11;
    ComPtr<ID3D11DeviceContext> context;
    if (FAILED(hr = d11->QueryInterface(IID_PPV_ARGS(&device11)))) return hr;
    d11->GetImmediateContext(&context);
    if (FAILED(hr = context.As(&context_))) return hr;
    device12_ = d12;
    queue_ = queue;
    for (size_t i = 0; i < 2; ++i) {
      if (FAILED(hr = d12->CreateFence(0, D3D12_FENCE_FLAG_SHARED, IID_PPV_ARGS(&fences12_[i])))) return hr;
      HANDLE shared = nullptr;
      if (FAILED(hr = d12->CreateSharedHandle(fences12_[i].Get(), nullptr, GENERIC_ALL, nullptr, &shared))) return hr;
      hr = device11->OpenSharedFence(shared, IID_PPV_ARGS(&fences11_[i]));
      CloseHandle(shared);
      if (FAILED(hr)) return hr;
    }
    constexpr DXGI_FORMAT formats[] = {DXGI_FORMAT_R10G10B10A2_UNORM, DXGI_FORMAT_R10G10B10A2_UNORM,
                                       DXGI_FORMAT_R32_FLOAT, DXGI_FORMAT_R16G16_FLOAT, DXGI_FORMAT_R8_UNORM};
    for (auto& slot : slots_) {
      for (size_t i = 0; i < InputCount; ++i) {
        if (FAILED(hr = CreateSharedTexture(device11.Get(), i == Depth || i == Motion ? layout.render_width : layout.output_width,
                                             i == Depth || i == Motion ? layout.render_height : layout.output_height,
                                             formats[i], &slot.textures[i]))) return hr;
      }
    }
    ready_ = true;
    return S_OK;
  }

  // The lens field is immutable between settings changes. Share one cached
  // texture, not three per-frame copies. Drain only when replacing its content.
  HRESULT SetDistortion(ID3D11Texture2D* source, uint64_t version) {
    if (!source || !version) return E_INVALIDARG;
    if (distortion_.d12 && distortion_version_ == version) return S_OK;
    D3D11_TEXTURE2D_DESC desc{};
    source->GetDesc(&desc);
    if (desc.Format != DXGI_FORMAT_R16G16B16A16_FLOAT || desc.SampleDesc.Count != 1
        || desc.MipLevels != 1 || desc.ArraySize != 1) return E_INVALIDARG;
    HRESULT hr = Drain();
    if (FAILED(hr)) return hr;
    if (!distortion_.d12 || distortion_.d12->GetDesc().Width != desc.Width || distortion_.d12->GetDesc().Height != desc.Height) {
      distortion_ = {};
      ComPtr<ID3D11Device> device;
      ComPtr<ID3D11Device5> device5;
      context_->GetDevice(&device);
      if (FAILED(hr = device.As(&device5))
          || FAILED(hr = CreateSharedTexture(device5.Get(), desc.Width, desc.Height, desc.Format, &distortion_))) return hr;
    }
    context_->CopyResource(distortion_.d11.Get(), source);
    // Publish's producer Signal/Flush also orders this copy before DX12 reads.
    distortion_version_ = version;
    return S_OK;
  }
  ID3D12Resource* Distortion() const { return distortion_.d12.Get(); }

  // No CPU wait or GPU overwrite when all slots are busy. The caller can return
  // WAS_STILL_DRAWING or apply bounded backpressure via WaitForAvailable.
  // Do not acquire another slot before publishing/cancelling.
  Slot* TryAcquire() {
    if (!ready_ || writing_) return nullptr;
    const uint64_t complete = fences12_[1]->GetCompletedValue();
    if (complete == UINT64_MAX) {
      ready_ = false;
      return nullptr;
    }
    for (auto& slot : slots_) {
      if (slot.state == Slot::State::Retiring && slot.consumed <= complete) slot.state = Slot::State::Free;
      if (slot.state != Slot::State::Free) continue;
      slot.state = Slot::State::Writing;
      writing_ = &slot;
      return &slot;
    }
    return nullptr;
  }

  // Exact, full active extents only: reject pool padding and format conversion.
  // Color/Hudless must ALREADY be PQ/BT.2020 from the existing RenoDX output
  // encoding. An FP16 scene buffer is not a legal substitute for either input.
  HRESULT Publish(Slot* slot, const std::array<ID3D11Texture2D*, InputCount>& sources, bool color_only = false) {
    if (!ready_ || !slot || slot != writing_) return E_INVALIDARG;
    for (size_t i = 0; i < InputCount; ++i) {
      if (color_only && i != Color) continue;
      if (i == UIAlpha && !sources[i]) continue;  // Optional; presenter clears its tag.
      if (!sources[i]) return E_INVALIDARG;
      D3D11_TEXTURE2D_DESC source{}, target{};
      sources[i]->GetDesc(&source);
      slot->textures[i].d11->GetDesc(&target);
      ComPtr<ID3D11Device> source_device, target_device;
      sources[i]->GetDevice(&source_device);
      slot->textures[i].d11->GetDevice(&target_device);
      if (source.Width != target.Width || source.Height != target.Height || source.Format != target.Format
          || source.SampleDesc.Count != 1 || source.MipLevels != 1 || source.ArraySize != 1
          || source_device != target_device || sources[i] == slot->textures[i].d11.Get()) return E_INVALIDARG;
    }
    for (size_t i = 0; i < InputCount; ++i) {
      if ((!color_only || i == Color) && sources[i]) context_->CopyResource(slot->textures[i].d11.Get(), sources[i]);
    }
    const HRESULT hr = context_->Signal(fences11_[0].Get(), produced_ + 1);
    // Signal is queued in D3D11's immediate context. Submit BEFORE D3D12 Wait;
    // relying on the game's later Present here can deadlock the two APIs.
    context_->Flush();
    if (FAILED(hr)) {
      ready_ = false;
      return hr;
    }
    slot->produced = ++produced_;
    slot->state = Slot::State::Published;
    writing_ = nullptr;
    return S_OK;
  }

  // Command allocators are indexed by the same retirement domain as inputs.
  // TryAcquire only returns a slot after its copy AND FG consumption finish.
  size_t Index(const Slot* slot) const { return static_cast<size_t>(slot - slots_.data()); }

  // Backpressure only when all three frames are in flight. No polling/Sleep,
  // and no wait on the ordinary path; DO_NOT_WAIT callers never call this.
  HRESULT WaitForAvailable() {
    if (!ready_) return DXGI_ERROR_DEVICE_REMOVED;
    uint64_t oldest = UINT64_MAX;
    for (const auto& slot : slots_) {
      if (slot.state == Slot::State::Free) return S_OK;
      if (slot.state == Slot::State::Retiring && slot.consumed < oldest) oldest = slot.consumed;
    }
    if (oldest == UINT64_MAX) return E_PENDING;
    if (fences12_[1]->GetCompletedValue() >= oldest) return device12_->GetDeviceRemovedReason();
    HANDLE event = CreateEventW(nullptr, FALSE, FALSE, nullptr);
    if (!event) return HRESULT_FROM_WIN32(GetLastError());
    HRESULT hr = fences12_[1]->SetEventOnCompletion(oldest, event);
    if (SUCCEEDED(hr) && WaitForSingleObject(event, INFINITE) != WAIT_OBJECT_0) hr = HRESULT_FROM_WIN32(GetLastError());
    CloseHandle(event);
    return FAILED(device12_->GetDeviceRemovedReason()) ? device12_->GetDeviceRemovedReason() : hr;
  }

  void Cancel(Slot* slot) {
    if (slot && slot == writing_) {
      slot->state = Slot::State::Free;
      writing_ = nullptr;
    }
  }

  HRESULT BeginRead(Slot* slot) {
    if (!ready_ || !Owns(slot) || slot->state != Slot::State::Published) return E_INVALIDARG;
    const HRESULT hr = queue_->Wait(fences12_[0].Get(), slot->produced);
    if (FAILED(hr)) {
      ready_ = false;
      return hr;
    }
    slot->state = Slot::State::Reading;
    return S_OK;
  }

  // Call AFTER Present and GetState on the presenting thread. GPU queue waits
  // for Streamline's INPUT completion, not merely our copy/list completion.
  // Caller returns textures to COMMON first. Null is for transport-only tests;
  // an active FG presenter must supply the fence returned by DLSSGGetState.
  HRESULT EndRead(Slot* slot, ID3D12Fence* input_completion, uint64_t input_value) {
    if (!Owns(slot) || slot->state != Slot::State::Reading || (!input_completion && input_value)) return E_INVALIDARG;
    HRESULT hr = input_completion ? queue_->Wait(input_completion, input_value) : S_OK;
    if (SUCCEEDED(hr)) hr = queue_->Signal(fences12_[1].Get(), ++consumed_);
    if (FAILED(hr)) {
      ready_ = false;
      return hr;
    }
    slot->consumed = consumed_;
    slot->state = Slot::State::Retiring;
    return S_OK;
  }

  // Full queue drain is restricted to teardown/resize/test verification.
  // The owner must retire all Reading slots (including the SL completion wait)
  // before destruction. Otherwise releasing tagged inputs would be unsafe.
  HRESULT Drain() {
    if (!queue_ || !fences12_[0] || !fences12_[1]) return S_OK;
    if (FAILED(device12_->GetDeviceRemovedReason())) return device12_->GetDeviceRemovedReason();
    for (const auto& slot : slots_)
      if (slot.state == Slot::State::Reading) return E_PENDING;
    // Covers a failed Publish Signal after CopyResource as well. Never enqueue
    // a wait for a value whose producer Signal did not succeed.
    HRESULT hr = context_->Signal(fences11_[0].Get(), produced_ + 1);
    context_->Flush();
    if (FAILED(hr)) return hr;
    ++produced_;
    hr = queue_->Wait(fences12_[0].Get(), produced_);
    if (FAILED(hr)) return hr;
    if (FAILED(hr = queue_->Signal(fences12_[1].Get(), ++consumed_))) return hr;
    HANDLE event = CreateEventW(nullptr, FALSE, FALSE, nullptr);
    if (!event) return HRESULT_FROM_WIN32(GetLastError());
    hr = fences12_[1]->SetEventOnCompletion(consumed_, event);
    if (SUCCEEDED(hr) && WaitForSingleObject(event, INFINITE) != WAIT_OBJECT_0) hr = HRESULT_FROM_WIN32(GetLastError());
    CloseHandle(event);
    return FAILED(device12_->GetDeviceRemovedReason()) ? device12_->GetDeviceRemovedReason() : hr;
  }

 private:
  HRESULT CreateSharedTexture(ID3D11Device5* device11, UINT width, UINT height, DXGI_FORMAT format, Texture* texture) {
    D3D12_RESOURCE_DESC resource{};
    resource.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D;
    resource.Width = width; resource.Height = height;
    resource.DepthOrArraySize = resource.MipLevels = 1;
    resource.Format = format;
    resource.SampleDesc.Count = 1;
    resource.Flags = D3D12_RESOURCE_FLAG_ALLOW_SIMULTANEOUS_ACCESS | D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET;
    const D3D12_HEAP_PROPERTIES heap{D3D12_HEAP_TYPE_DEFAULT};
    HRESULT hr = device12_->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_SHARED, &resource,
                                                     D3D12_RESOURCE_STATE_COMMON, nullptr, IID_PPV_ARGS(&texture->d12));
    if (FAILED(hr)) return hr;
    HANDLE shared = nullptr;
    if (FAILED(hr = device12_->CreateSharedHandle(texture->d12.Get(), nullptr, GENERIC_ALL, nullptr, &shared))) return hr;
    hr = device11->OpenSharedResource1(shared, IID_PPV_ARGS(&texture->d11));
    CloseHandle(shared);
    return hr;
  }
  bool Owns(const Slot* slot) const {
    for (const auto& candidate : slots_)
      if (slot == &candidate) return true;
    return false;
  }
  ComPtr<ID3D12Device> device12_;
  ComPtr<ID3D12CommandQueue> queue_;
  ComPtr<ID3D11DeviceContext4> context_;
  std::array<ComPtr<ID3D12Fence>, 2> fences12_;
  std::array<ComPtr<ID3D11Fence>, 2> fences11_;
  std::array<Slot, kSlotCount> slots_;
  Slot* writing_ = nullptr;
  uint64_t produced_ = 0, consumed_ = 0;
  Texture distortion_;
  uint64_t distortion_version_ = 0;
  bool ready_ = false;
};
}  // namespace witcher3classic::frame_generation
