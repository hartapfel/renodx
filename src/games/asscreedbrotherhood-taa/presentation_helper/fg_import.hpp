/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11_4.h>
#include <d3d12.h>
#include <wrl/client.h>
#include "../presentation_protocol.hpp"
#include "../dlaa_handles.hpp"
namespace acbrotherhood::frame_generation {
using Microsoft::WRL::ComPtr;
struct ImportedImage {
  ComPtr<ID3D11Texture2D> source, bridge;
  ComPtr<ID3D12Resource> texture, readback;
  D3D12_PLACED_SUBRESOURCE_FOOTPRINT footprint{};
  UINT64 readback_bytes = 0;
  uint64_t handle = 0;
  UINT width = 0, height = 0, pixel_bytes = 0;
  void Open(ID3D11Device5* device11, ID3D12Device* device12, uint64_t legacy,
            UINT w, UINT h, DXGI_FORMAT format, bool validation) {
    using presentation::Check;
    using presentation::Stage;
    Check(device11->OpenSharedResource(reinterpret_cast<HANDLE>(uintptr_t(legacy)), IID_PPV_ARGS(&source)), Stage::sharing);
    D3D11_TEXTURE2D_DESC source_desc{}; source->GetDesc(&source_desc);
    if (source_desc.Width != w || source_desc.Height != h || source_desc.Format != format
        || source_desc.SampleDesc.Count != 1 || source_desc.ArraySize != 1 || source_desc.MipLevels != 1)
      throw presentation::Failure{Stage::sharing, ERROR_INVALID_DATA};
    width = w; height = h; pixel_bytes = format == DXGI_FORMAT_R16G16B16A16_FLOAT ? 8 : 4;
    D3D12_HEAP_PROPERTIES heap{}; heap.Type = D3D12_HEAP_TYPE_DEFAULT;
    D3D12_RESOURCE_DESC desc{};
    desc.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D;
    desc.Width = w; desc.Height = h; desc.DepthOrArraySize = desc.MipLevels = 1;
    desc.Format = format; desc.SampleDesc.Count = 1;
    desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_SIMULTANEOUS_ACCESS | D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET;
    Check(device12->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_SHARED, &desc, D3D12_RESOURCE_STATE_COMMON,
                                            nullptr, IID_PPV_ARGS(&texture)), Stage::sharing);
    dlaa::Handle shared;
    Check(device12->CreateSharedHandle(texture.Get(), nullptr, GENERIC_ALL, nullptr, &shared.value), Stage::sharing);
    Check(device11->OpenSharedResource1(shared.value, IID_PPV_ARGS(&bridge)), Stage::sharing);
    if (validation) {
      device12->GetCopyableFootprints(&desc, 0, 1, 0, &footprint, nullptr, nullptr, &readback_bytes);
      D3D12_RESOURCE_DESC buffer{}; buffer.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
      buffer.Width = readback_bytes; buffer.Height = buffer.DepthOrArraySize = buffer.MipLevels = 1;
      buffer.SampleDesc.Count = 1; buffer.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
      heap.Type = D3D12_HEAP_TYPE_READBACK;
      Check(device12->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_NONE, &buffer, D3D12_RESOURCE_STATE_COPY_DEST,
                                              nullptr, IID_PPV_ARGS(&readback)), Stage::copy);
    }
    handle = legacy;
  }
  void Readback(ID3D12GraphicsCommandList* commands) {
    if (!readback) return;
    D3D12_RESOURCE_BARRIER barrier{}; barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    barrier.Transition = {texture.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_COMMON, D3D12_RESOURCE_STATE_COPY_SOURCE};
    commands->ResourceBarrier(1, &barrier);
    D3D12_TEXTURE_COPY_LOCATION from{}, to{};
    from.pResource = texture.Get(); from.Type = D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX;
    to.pResource = readback.Get(); to.Type = D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT; to.PlacedFootprint = footprint;
    commands->CopyTextureRegion(&to, 0, 0, 0, &from, nullptr);
    std::swap(barrier.Transition.StateBefore, barrier.Transition.StateAfter);
    commands->ResourceBarrier(1, &barrier);
  }
  uint32_t Checksum() {
    if (!readback) return 0;
    void* mapped = nullptr;
    D3D12_RANGE range{0, SIZE_T(readback_bytes)};
    presentation::Check(readback->Map(0, &range, &mapped), presentation::Stage::copy);
    uint32_t hash = 2166136261;
    for (UINT y = 0; y < height; ++y) for (UINT x = 0; x < width * pixel_bytes; ++x)
      hash = (hash ^ static_cast<const uint8_t*>(mapped)[y * footprint.Footprint.RowPitch + x]) * 16777619;
    const D3D12_RANGE empty{}; readback->Unmap(0, &empty);
    return hash;
  }
};
}
