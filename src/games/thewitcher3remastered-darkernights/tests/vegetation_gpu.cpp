/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// Executes the actual production shader and texture/buffer copy path on D3D12 WARP.
#define NOMINMAX
#include <d3d12.h>
#include <dxgi1_6.h>
#include <wrl/client.h>
#include <DirectXPackedVector.h>
#include <algorithm>
#include <array>
#include <bit>
#include <cmath>
#include <fstream>
#include <iostream>
#include <iterator>
#include <stdexcept>
#include <string>
#include <vector>
using Microsoft::WRL::ComPtr;
using namespace DirectX::PackedVector;
void Check(HRESULT h) { if (FAILED(h)) throw std::runtime_error("D3D12 failure " + std::to_string(h)); }
void Require(bool p, const char* s) { if (!p) throw std::runtime_error(s); }
void Barrier(ID3D12GraphicsCommandList* c, ID3D12Resource* r, D3D12_RESOURCE_STATES before, D3D12_RESOURCE_STATES after) {
  D3D12_RESOURCE_BARRIER b = {}; b.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
  b.Transition = {r, D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, before, after}; c->ResourceBarrier(1, &b);
}
int main(int argc, char** argv) { try {
  Require(argc == 2, "Expected production CSO");
  ComPtr<IDXGIFactory4> factory; Check(CreateDXGIFactory1(IID_PPV_ARGS(&factory)));
  ComPtr<IDXGIAdapter> adapter; Check(factory->EnumWarpAdapter(IID_PPV_ARGS(&adapter)));
  ComPtr<ID3D12Device> d; Check(D3D12CreateDevice(adapter.Get(), D3D_FEATURE_LEVEL_12_0, IID_PPV_ARGS(&d)));
  ComPtr<ID3D12CommandQueue> queue; D3D12_COMMAND_QUEUE_DESC qd = {}; Check(d->CreateCommandQueue(&qd, IID_PPV_ARGS(&queue)));
  ComPtr<ID3D12CommandAllocator> allocator; Check(d->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&allocator)));
  ComPtr<ID3D12GraphicsCommandList> cmd; Check(d->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, allocator.Get(), nullptr, IID_PPV_ARGS(&cmd))); Check(cmd->Close());
  ComPtr<ID3D12Fence> fence; Check(d->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&fence)));
  HANDLE event = CreateEventW(nullptr, FALSE, FALSE, nullptr); Require(event != nullptr, "Fence event failed");
  D3D12_ROOT_PARAMETER roots[2] = {};
  roots[0].ParameterType = D3D12_ROOT_PARAMETER_TYPE_UAV;
  roots[1].ParameterType = D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS; roots[1].Constants.Num32BitValues = 4;
  D3D12_ROOT_SIGNATURE_DESC rd = {2, roots};
  ComPtr<ID3DBlob> signature, errors; Check(D3D12SerializeRootSignature(&rd, D3D_ROOT_SIGNATURE_VERSION_1, &signature, &errors));
  ComPtr<ID3D12RootSignature> layout; Check(d->CreateRootSignature(0, signature->GetBufferPointer(), signature->GetBufferSize(), IID_PPV_ARGS(&layout)));
  std::ifstream f(argv[1], std::ios::binary); std::vector<char> code((std::istreambuf_iterator<char>(f)), {});
  D3D12_COMPUTE_PIPELINE_STATE_DESC pd = {}; pd.pRootSignature = layout.Get(); pd.CS = {code.data(), code.size()};
  ComPtr<ID3D12PipelineState> pipeline; Check(d->CreateComputePipelineState(&pd, IID_PPV_ARGS(&pipeline)));
  unsigned cases = 0; double worst_y = 0;
  for (unsigned width : {1u, 33u, 65u, 1024u}) for (float delta : {0.f, -.5f, -1.f, .5f, 1.f}) {
    const unsigned height = 9, pitch = (width * 8 + 255) & ~255u, bytes = pitch * height;
    D3D12_RESOURCE_DESC texture_desc = {}; texture_desc.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D;
    texture_desc.Width = width; texture_desc.Height = height; texture_desc.DepthOrArraySize = texture_desc.MipLevels = 1;
    texture_desc.Format = DXGI_FORMAT_R16G16B16A16_FLOAT; texture_desc.SampleDesc.Count = 1;
    D3D12_RESOURCE_DESC buffer_desc = {}; buffer_desc.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
    buffer_desc.Width = bytes; buffer_desc.Height = buffer_desc.DepthOrArraySize = buffer_desc.MipLevels = buffer_desc.SampleDesc.Count = 1;
    buffer_desc.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
    D3D12_HEAP_PROPERTIES gpu = {}; gpu.Type = D3D12_HEAP_TYPE_DEFAULT;
    D3D12_HEAP_PROPERTIES cpu = {}; cpu.Type = D3D12_HEAP_TYPE_UPLOAD;
    D3D12_HEAP_PROPERTIES read = {}; read.Type = D3D12_HEAP_TYPE_READBACK;
    ComPtr<ID3D12Resource> texture, scratch, upload, readback;
    Check(d->CreateCommittedResource(&gpu, D3D12_HEAP_FLAG_NONE, &texture_desc, D3D12_RESOURCE_STATE_COPY_DEST, nullptr, IID_PPV_ARGS(&texture)));
    Check(d->CreateCommittedResource(&cpu, D3D12_HEAP_FLAG_NONE, &buffer_desc, D3D12_RESOURCE_STATE_GENERIC_READ, nullptr, IID_PPV_ARGS(&upload)));
    Check(d->CreateCommittedResource(&read, D3D12_HEAP_FLAG_NONE, &buffer_desc, D3D12_RESOURCE_STATE_COPY_DEST, nullptr, IID_PPV_ARGS(&readback)));
    buffer_desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS;
    Check(d->CreateCommittedResource(&gpu, D3D12_HEAP_FLAG_NONE, &buffer_desc, D3D12_RESOURCE_STATE_COPY_DEST, nullptr, IID_PPV_ARGS(&scratch)));
    std::vector<uint16_t> data(bytes / 2, 0xCDCD);
    const std::array<std::array<float, 3>, 8> chips = {{{.5f,0,0},{.5f,.15f,0},{.5f,0,.25f},{.5f,.5f,.5f},{0,.5f,0},{0,.5f,.5f},{.5f,.5f,0},{0,0,.5f}}};
    for (unsigned y = 0; y < height; ++y) for (unsigned x = 0; x < width; ++x) {
      auto rgb = chips[x % 8];
      const float exposure = std::pow(2.f, float(y) - 4);
      for (auto& v : rgb) v *= exposure;
      if (y == 8) rgb = {-.1f * rgb[1], rgb[1], rgb[2]}; // Signed wide-gamut transport.
      const unsigned offset = y * pitch / 2 + x * 4;
      for (unsigned c = 0; c < 3; ++c) data[offset + c] = XMConvertFloatToHalf(rgb[c]);
      data[offset + 3] = uint16_t(0x3000u + ((x + y * width) % 4096));
    }
    void* memory; Check(upload->Map(0, nullptr, &memory)); std::memcpy(memory, data.data(), bytes); upload->Unmap(0, nullptr);
    Check(allocator->Reset()); Check(cmd->Reset(allocator.Get(), nullptr));
    D3D12_TEXTURE_COPY_LOCATION t = {}; t.pResource = texture.Get(); t.Type = D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX;
    D3D12_TEXTURE_COPY_LOCATION u = {}; u.pResource = upload.Get(); u.Type = D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT;
    u.PlacedFootprint.Footprint = {DXGI_FORMAT_R16G16B16A16_FLOAT, width, height, 1, pitch};
    cmd->CopyTextureRegion(&t, 0, 0, 0, &u, nullptr);
    Barrier(cmd.Get(), texture.Get(), D3D12_RESOURCE_STATE_COPY_DEST, D3D12_RESOURCE_STATE_COPY_SOURCE);
    D3D12_TEXTURE_COPY_LOCATION s = u; s.pResource = scratch.Get(); cmd->CopyTextureRegion(&s, 0, 0, 0, &t, nullptr);
    Barrier(cmd.Get(), scratch.Get(), D3D12_RESOURCE_STATE_COPY_DEST, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    cmd->SetPipelineState(pipeline.Get()); cmd->SetComputeRootSignature(layout.Get());
    cmd->SetComputeRootUnorderedAccessView(0, scratch->GetGPUVirtualAddress());
    const uint32_t constants[] = {width, height, pitch, std::bit_cast<uint32_t>(delta)};
    cmd->SetComputeRoot32BitConstants(1, 4, constants, 0); cmd->Dispatch((width + 7) / 8, (height + 7) / 8, 1);
    Barrier(cmd.Get(), scratch.Get(), D3D12_RESOURCE_STATE_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_COPY_SOURCE);
    Barrier(cmd.Get(), texture.Get(), D3D12_RESOURCE_STATE_COPY_SOURCE, D3D12_RESOURCE_STATE_COPY_DEST);
    cmd->CopyTextureRegion(&t, 0, 0, 0, &s, nullptr);
    Barrier(cmd.Get(), texture.Get(), D3D12_RESOURCE_STATE_COPY_DEST, D3D12_RESOURCE_STATE_COPY_SOURCE);
    D3D12_TEXTURE_COPY_LOCATION r = u; r.pResource = readback.Get(); cmd->CopyTextureRegion(&r, 0, 0, 0, &t, nullptr);
    Check(cmd->Close()); ID3D12CommandList* lists[] = {cmd.Get()}; queue->ExecuteCommandLists(1, lists);
    Check(queue->Signal(fence.Get(), ++cases)); Check(fence->SetEventOnCompletion(cases, event));
    Require(WaitForSingleObject(event, 10000) == WAIT_OBJECT_0, "GPU fence timed out");
    Check(readback->Map(0, nullptr, &memory)); const auto* result = static_cast<const uint16_t*>(memory);
    for (unsigned y = 0; y < height; ++y) for (unsigned x = 0; x < width; ++x) {
      const unsigned offset = y * pitch / 2 + x * 4;
      Require(result[offset + 3] == data[offset + 3], "Alpha metadata changed");
      double old_y = 0, new_y = 0; const double weights[] = {.2126390059,.7151686788,.0721923154};
      for (unsigned c = 0; c < 3; ++c) {
        const double old = XMConvertHalfToFloat(data[offset + c]), value = XMConvertHalfToFloat(result[offset + c]);
        Require(std::isfinite(value), "Nonfinite scene output");
        if (delta == 0 || (y != 8 && x % 8 < 4)) Require(result[offset + c] == data[offset + c], "Neutral/warm/pink pixels changed");
        old_y += weights[c] * std::copysign(std::pow(std::abs(old),2.2),old);
        new_y += weights[c] * std::copysign(std::pow(std::abs(value),2.2),value);
        if (delta == -1 && y != 8 && (x % 8 == 4 || x % 8 == 5)) Require(std::abs(value-XMConvertHalfToFloat(result[offset])) < .001, "Green/cyan coverage failed");
      }
      const double error = std::abs(old_y - new_y); worst_y = std::max(worst_y, error);
      Require(error < std::max(1e-6, std::abs(old_y) * .003), "Luminance changed beyond half-float rounding");
    }
    readback->Unmap(0, nullptr);
  }
  CloseHandle(event);
  std::cout << "PASS " << cases << " D3D12 texture-copy/compute cases; row padding, dispatch bounds, alpha bits, neutral/warm/pink isolation, green/cyan coverage, signed HDR and luminance; worst Y error=" << worst_y << '\n';
} catch (const std::exception& e) { std::cerr << "FAIL " << e.what() << '\n'; return 1; } }
