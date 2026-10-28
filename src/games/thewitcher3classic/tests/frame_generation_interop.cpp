/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
// Assertions must remain enabled. CPU readbacks below are test-only.
#include <cassert>
#include <cstdio>
#include <cstring>
#include <string_view>
#include <vector>
#include "../frame_generation/interop.hpp"

using namespace witcher3classic::frame_generation;

int main(int argc, char** argv) {
  const bool warp = argc > 1 && std::string_view(argv[1]) == "--warp";
  ComPtr<IDXGIFactory4> factory;
  assert(SUCCEEDED(CreateDXGIFactory1(IID_PPV_ARGS(&factory))));
  ComPtr<IDXGIAdapter1> adapter;
  if (warp)
    assert(SUCCEEDED(factory->EnumWarpAdapter(IID_PPV_ARGS(&adapter))));
  else {
    for (UINT i = 0; SUCCEEDED(factory->EnumAdapters1(i, &adapter)); ++i) {
      DXGI_ADAPTER_DESC1 desc{};
      adapter->GetDesc1(&desc);
      if (desc.VendorId == 0x10de && !(desc.Flags & DXGI_ADAPTER_FLAG_SOFTWARE)) break;
      adapter.Reset();
    }
  }
  assert(adapter);
  DXGI_ADAPTER_DESC1 adapter_desc{};
  adapter->GetDesc1(&adapter_desc);
  std::printf("Adapter: %ls\n", adapter_desc.Description);
  ComPtr<ID3D11Device> d11;
  ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(adapter.Get(), D3D_DRIVER_TYPE_UNKNOWN, nullptr, 0,
                                     nullptr, 0, D3D11_SDK_VERSION, &d11, nullptr, &context)));
  ComPtr<ID3D12Device> d12;
  assert(SUCCEEDED(D3D12CreateDevice(adapter.Get(), D3D_FEATURE_LEVEL_11_0, IID_PPV_ARGS(&d12))));
  ComPtr<ID3D12CommandQueue> queue;
  const D3D12_COMMAND_QUEUE_DESC queue_desc{D3D12_COMMAND_LIST_TYPE_DIRECT};
  assert(SUCCEEDED(d12->CreateCommandQueue(&queue_desc, IID_PPV_ARGS(&queue))));
  Interop bridge;
  assert(bridge.Initialize(d11.Get(), d12.Get(), queue.Get(), {}) == E_INVALIDARG);
  const HRESULT initialized = bridge.Initialize(d11.Get(), d12.Get(), queue.Get(), {64, 48, 32, 24});
  std::printf("Shared transport initialization: 0x%08X\n", unsigned(initialized));
  assert(SUCCEEDED(initialized));
  assert(bridge.Initialize(d11.Get(), d12.Get(), queue.Get(), {64, 48, 32, 24}) == E_INVALIDARG);
  constexpr DXGI_FORMAT formats[] = {DXGI_FORMAT_R10G10B10A2_UNORM, DXGI_FORMAT_R10G10B10A2_UNORM,
                                     DXGI_FORMAT_R32_FLOAT, DXGI_FORMAT_R16G16_FLOAT, DXGI_FORMAT_R8_UNORM};
  constexpr uint32_t bytes[] = {4, 4, 4, 4, 1};
  std::array<ComPtr<ID3D11Texture2D>, Interop::InputCount> sources;
  std::array<ID3D11Texture2D*, Interop::InputCount> inputs{};
  for (size_t i = 0; i < sources.size(); ++i) {
    const bool render = i == Interop::Depth || i == Interop::Motion;
    const D3D11_TEXTURE2D_DESC desc{render ? 32u : 64u, render ? 24u : 48u, 1, 1, formats[i], {1, 0}, D3D11_USAGE_DEFAULT};
    assert(SUCCEEDED(d11->CreateTexture2D(&desc, nullptr, &sources[i])));
    inputs[i] = sources[i].Get();
  }
  struct Readback {
    ComPtr<ID3D12Resource> resource;
    D3D12_PLACED_SUBRESOURCE_FOOTPRINT footprint{};
    std::vector<uint8_t> expected;
  };
  std::array<std::array<Readback, Interop::InputCount>, Interop::kSlotCount> results;
  std::array<ComPtr<ID3D12CommandAllocator>, Interop::kSlotCount> allocators;
  std::array<ComPtr<ID3D12GraphicsCommandList>, Interop::kSlotCount> lists;
  ComPtr<ID3D12Fence> simulated_fg_completion;
  assert(SUCCEEDED(d12->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&simulated_fg_completion))));
  Interop::Slot foreign;
  assert(bridge.BeginRead(&foreign) == E_INVALIDARG);
  assert(bridge.EndRead(&foreign, nullptr, 0) == E_INVALIDARG);
  auto* cancelled = bridge.TryAcquire();
  assert(cancelled);
  assert(!bridge.TryAcquire());
  assert(bridge.Publish(cancelled, {}) == E_INVALIDARG);
  bridge.Cancel(cancelled);
  for (size_t frame = 0; frame < Interop::kSlotCount; ++frame) {
    auto* slot = bridge.TryAcquire();
    assert(slot);
    assert(bridge.BeginRead(slot) == E_INVALIDARG);
    for (size_t i = 0; i < sources.size(); ++i) {
      auto& result = results[frame][i];
      D3D11_TEXTURE2D_DESC desc{};
      sources[i]->GetDesc(&desc);
      result.expected.resize(size_t(desc.Width) * desc.Height * bytes[i]);
      for (size_t pixel = 0; pixel < size_t(desc.Width) * desc.Height; ++pixel) {
        if (i == Interop::Depth) {
          const float depth = float(pixel % 257) / 256.f;
          std::memcpy(result.expected.data() + pixel * 4, &depth, 4);
        } else if (i == Interop::Motion) {
          // Half-float +1/-1, +0/-0, subnormal and fractional motion bits.
          constexpr uint32_t vectors[] = {0xbc003c00, 0x80000000, 0x00010001, 0xb8003800};
          std::memcpy(result.expected.data() + pixel * 4, &vectors[(pixel + frame) % 4], 4);
        } else if (i == Interop::UIAlpha)
          result.expected[pixel] = uint8_t(pixel + frame * 53);
        else {
          // Exhaust the full 10-bit PQ code range, including near-black and
          // highlight codes. Alpha is not repurposed as a UI-opacity mask.
          const uint32_t pq = uint32_t((pixel + frame * 173) % 1024);
          const uint32_t packed = pq | (((pq + 341) % 1024) << 10) | (((pq + 683) % 1024) << 20) | 0xc0000000;
          std::memcpy(result.expected.data() + pixel * 4, &packed, 4);
        }
      }
      context->UpdateSubresource(sources[i].Get(), 0, nullptr, result.expected.data(), desc.Width * bytes[i], 0);
    }
    auto invalid = inputs;
    invalid[Interop::Depth] = inputs[Interop::Color];
    assert(bridge.Publish(slot, invalid) == E_INVALIDARG);
    assert(SUCCEEDED(bridge.Publish(slot, inputs)));
    assert(bridge.Publish(slot, inputs) == E_INVALIDARG);
    assert(SUCCEEDED(bridge.BeginRead(slot)));
    assert(bridge.BeginRead(slot) == E_INVALIDARG);
    assert(SUCCEEDED(d12->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&allocators[frame]))));
    assert(SUCCEEDED(d12->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, allocators[frame].Get(), nullptr, IID_PPV_ARGS(&lists[frame]))));
    for (size_t i = 0; i < sources.size(); ++i) {
      auto& result = results[frame][i];
      const auto desc = slot->textures[i].d12->GetDesc();
      UINT64 size = 0;
      d12->GetCopyableFootprints(&desc, 0, 1, 0, &result.footprint, nullptr, nullptr, &size);
      const D3D12_HEAP_PROPERTIES heap{D3D12_HEAP_TYPE_READBACK};
      D3D12_RESOURCE_DESC buffer{};
      buffer.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
      buffer.Width = size;
      buffer.Height = buffer.DepthOrArraySize = buffer.MipLevels = buffer.SampleDesc.Count = 1;
      buffer.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
      assert(SUCCEEDED(d12->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_NONE, &buffer,
                                                    D3D12_RESOURCE_STATE_COPY_DEST, nullptr, IID_PPV_ARGS(&result.resource))));
      D3D12_RESOURCE_BARRIER barrier{};
      barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
      barrier.Transition = {slot->textures[i].d12.Get(), 0, D3D12_RESOURCE_STATE_COMMON, D3D12_RESOURCE_STATE_COPY_SOURCE};
      lists[frame]->ResourceBarrier(1, &barrier);
      D3D12_TEXTURE_COPY_LOCATION source{};
      source.pResource = slot->textures[i].d12.Get();
      source.Type = D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX;
      D3D12_TEXTURE_COPY_LOCATION destination{};
      destination.pResource = result.resource.Get();
      destination.Type = D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT;
      destination.PlacedFootprint = result.footprint;
      lists[frame]->CopyTextureRegion(&destination, 0, 0, 0, &source, nullptr);
      std::swap(barrier.Transition.StateBefore, barrier.Transition.StateAfter);
      lists[frame]->ResourceBarrier(1, &barrier);
    }
    assert(SUCCEEDED(lists[frame]->Close()));
    ID3D12CommandList* commands[] = {lists[frame].Get()};
    queue->ExecuteCommandLists(1, commands);
    assert(bridge.EndRead(slot, nullptr, 1) == E_INVALIDARG);
    assert(SUCCEEDED(bridge.EndRead(slot, simulated_fg_completion.Get(), 1)));
  }
  // All three slots are held by an unsignaled FG fence. Reuse must fail fast.
  assert(!bridge.TryAcquire());
  assert(SUCCEEDED(simulated_fg_completion->Signal(1)));
  assert(SUCCEEDED(bridge.Drain()));
  for (const auto& frame : results)
    for (size_t i = 0; i < frame.size(); ++i) {
      const auto& result = frame[i];
      const uint32_t pitch = result.footprint.Footprint.Width * bytes[i];
      const D3D12_RANGE range{0, size_t(result.resource->GetDesc().Width)};
      void* mapped = nullptr;
      assert(SUCCEEDED(result.resource->Map(0, &range, &mapped)));
      for (size_t y = 0; y < result.footprint.Footprint.Height; ++y)
        assert(std::memcmp(static_cast<uint8_t*>(mapped) + result.footprint.Offset + y * result.footprint.Footprint.RowPitch,
                           result.expected.data() + y * pitch, pitch)
               == 0);
      const D3D12_RANGE written{0, 0};
      result.resource->Unmap(0, &written);
    }
  auto* reused = bridge.TryAcquire();
  assert(reused);
  bridge.Cancel(reused);
  {
    // Resize uses new allocations after retirement, including odd extents.
    Interop resized;
    assert(SUCCEEDED(resized.Initialize(d11.Get(), d12.Get(), queue.Get(), {127, 73, 85, 49})));
    auto* slot = resized.TryAcquire();
    assert(slot);
    assert(slot->textures[Interop::Color].d12->GetDesc().Width == 127);
    assert(slot->textures[Interop::Motion].d12->GetDesc().Width == 85);
    assert(resized.Publish(slot, inputs) == E_INVALIDARG);
    resized.Cancel(slot);
  }
  std::puts("PASS: 3 queued frames, 5 exact formats, PQ codes, signed motion, reverse depth, UI alpha, delayed consumer, backpressure and reuse.");
}
