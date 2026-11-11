// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Standalone DX12 validation of the exact production grid kernels. No game hooks.
#include <d3d12.h>
#include <d3d12sdklayers.h>
#include <DirectXPackedVector.h>
#include <wrl/client.h>
#include <array>
#include <bit>
#include <cmath>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <vector>
#include "../fog/fast_noise.hpp"
#include "../shared.h"
#include "../water/light_layout.h"
using Microsoft::WRL::ComPtr;
void Check(HRESULT hr) {
  if (FAILED(hr)) throw std::runtime_error("D3D12 HRESULT " + std::to_string(hr));
}
std::vector<char> Read(const std::filesystem::path& path) {
  std::ifstream file(path, std::ios::binary);
  if (!file) throw std::runtime_error("Missing shader " + path.string());
  return {std::istreambuf_iterator<char>(file), {}};
}
ComPtr<ID3D12Resource> Buffer(ID3D12Device* device, uint64_t bytes, D3D12_HEAP_TYPE type, D3D12_RESOURCE_STATES state) {
  D3D12_HEAP_PROPERTIES heap{};
  heap.Type = type;
  D3D12_RESOURCE_DESC desc{};
  desc.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
  desc.Width = bytes;
  desc.Height = desc.DepthOrArraySize = desc.MipLevels = desc.SampleDesc.Count = 1;
  desc.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
  if (type == D3D12_HEAP_TYPE_DEFAULT) desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS;
  ComPtr<ID3D12Resource> result;
  Check(device->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_NONE, &desc, state, nullptr, IID_PPV_ARGS(&result)));
  return result;
}
void Upload(ID3D12Resource* resource, const void* source, size_t bytes) {
  void* data = nullptr;
  const D3D12_RANGE empty{0, 0};
  Check(resource->Map(0, &empty, &data));
  std::memcpy(data, source, bytes);
  resource->Unmap(0, nullptr);
}
float Half(uint16_t value) {
  float magnitude = (value & 1023u) / 1024.f;
  const uint32_t exponent = (value >> 10) & 31u;
  if (exponent == 31) return INFINITY;
  magnitude = exponent == 0 ? std::ldexp(magnitude, -14) : std::ldexp(1.f + magnitude, int(exponent) - 15);
  return value & 32768u ? -magnitude : magnitude;
}
ComPtr<ID3D12PipelineState> Graphics(ID3D12Device* device, ID3D12RootSignature* root, const std::vector<char>& vs, const std::vector<char>& ps) {
  D3D12_GRAPHICS_PIPELINE_STATE_DESC desc{};
  desc.pRootSignature = root;
  desc.VS = {vs.data(), vs.size()};
  desc.PS = {ps.data(), ps.size()};
  desc.RasterizerState.FillMode = D3D12_FILL_MODE_SOLID;
  desc.RasterizerState.CullMode = D3D12_CULL_MODE_NONE;
  desc.RasterizerState.DepthClipEnable = TRUE;
  desc.SampleMask = UINT_MAX;
  desc.SampleDesc.Count = 1;
  desc.PrimitiveTopologyType = D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE;
  desc.DepthStencilState.DepthFunc = D3D12_COMPARISON_FUNC_ALWAYS;
  desc.DepthStencilState.FrontFace = {D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_COMPARISON_FUNC_ALWAYS};
  desc.DepthStencilState.BackFace = desc.DepthStencilState.FrontFace;
  for (auto& target : desc.BlendState.RenderTarget) {
    target.SrcBlend = target.SrcBlendAlpha = D3D12_BLEND_ONE;
    target.DestBlend = target.DestBlendAlpha = D3D12_BLEND_ZERO;
    target.BlendOp = target.BlendOpAlpha = D3D12_BLEND_OP_ADD;
    target.LogicOp = D3D12_LOGIC_OP_NOOP;
    target.RenderTargetWriteMask = D3D12_COLOR_WRITE_ENABLE_ALL;
  }
  ComPtr<ID3D12PipelineState> pipeline;
  Check(device->CreateGraphicsPipelineState(&desc, IID_PPV_ARGS(&pipeline)));
  return pipeline;
}
int main(int argc, char** argv) {
  try {
    if (argc != 3 && argc != 4) throw std::runtime_error("Expected production shader embed directory, feature shader and optional local occlusion shader");
    ComPtr<ID3D12Debug> debug;
    if (SUCCEEDED(D3D12GetDebugInterface(IID_PPV_ARGS(&debug)))) debug->EnableDebugLayer();
    ComPtr<ID3D12Device> device;
    Check(D3D12CreateDevice(nullptr, D3D_FEATURE_LEVEL_12_0, IID_PPV_ARGS(&device)));
    ComPtr<ID3D12InfoQueue> messages;
    device.As(&messages);
    D3D12_COMMAND_QUEUE_DESC queue_desc{};
    queue_desc.Type = D3D12_COMMAND_LIST_TYPE_DIRECT;
    ComPtr<ID3D12CommandQueue> queue;
    Check(device->CreateCommandQueue(&queue_desc, IID_PPV_ARGS(&queue)));
    ComPtr<ID3D12CommandAllocator> allocator;
    Check(device->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&allocator)));
    ComPtr<ID3D12GraphicsCommandList> cmd;
    Check(device->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, allocator.Get(), nullptr, IID_PPV_ARGS(&cmd)));
    Check(cmd->Close());
    D3D12_ROOT_PARAMETER roots[11]{};
    roots[10].ParameterType = D3D12_ROOT_PARAMETER_TYPE_SRV;
    roots[10].Descriptor = {0, 72};
    roots[9].ParameterType = D3D12_ROOT_PARAMETER_TYPE_SRV;
    roots[9].Descriptor = {0, 71};
    D3D12_DESCRIPTOR_RANGE local_range{D3D12_DESCRIPTOR_RANGE_TYPE_SRV, 1, 18, 0, 0};
    roots[8].ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;
    roots[8].DescriptorTable = {1, &local_range};
    roots[6].ParameterType = roots[7].ParameterType = D3D12_ROOT_PARAMETER_TYPE_SRV;
    roots[6].Descriptor = {2, 71};
    roots[7].Descriptor = {1, 71};
    roots[0].ParameterType = roots[1].ParameterType = roots[2].ParameterType = roots[3].ParameterType = D3D12_ROOT_PARAMETER_TYPE_CBV;
    roots[0].Descriptor = {12, 0};
    roots[1].Descriptor = {13, 0};
    roots[2].Descriptor = {0, 70};
    roots[3].Descriptor = {3, 71};
    roots[4].ParameterType = D3D12_ROOT_PARAMETER_TYPE_UAV;
    roots[4].Descriptor = {0, 71};
    D3D12_DESCRIPTOR_RANGE ranges[8]{};
    const UINT registers[8] = {8, 14, 19, 24, 9, 10, 42, 0};
    for (UINT i = 0; i < 8; ++i) ranges[i] = {D3D12_DESCRIPTOR_RANGE_TYPE_SRV, 1, registers[i], 0, i};
    roots[5].ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;
    roots[5].DescriptorTable = {8, ranges};
    D3D12_STATIC_SAMPLER_DESC samplers[2]{};
    for (auto& sampler : samplers) {
      sampler.Filter = D3D12_FILTER_MIN_MAG_MIP_LINEAR;
      sampler.AddressU = sampler.AddressV = sampler.AddressW = D3D12_TEXTURE_ADDRESS_MODE_CLAMP;
      sampler.MaxLOD = D3D12_FLOAT32_MAX;
      sampler.ComparisonFunc = D3D12_COMPARISON_FUNC_ALWAYS;
    }
    samplers[0].ShaderRegister = 10;
    samplers[1].ShaderRegister = 14;
    samplers[1].AddressU = samplers[1].AddressV = D3D12_TEXTURE_ADDRESS_MODE_WRAP;
    D3D12_ROOT_SIGNATURE_DESC root_desc{11, roots, 2, samplers, D3D12_ROOT_SIGNATURE_FLAG_NONE};
    ComPtr<ID3DBlob> serialized, error;
    Check(D3D12SerializeRootSignature(&root_desc, D3D_ROOT_SIGNATURE_VERSION_1, &serialized, &error));
    ComPtr<ID3D12RootSignature> root;
    Check(device->CreateRootSignature(0, serialized->GetBufferPointer(), serialized->GetBufferSize(), IID_PPV_ARGS(&root)));
    auto vs = Read(std::filesystem::path(argv[1]) / "0xF7F00001.cso");
    auto ps = Read(std::filesystem::path(argv[1]) / "0xF7F00002.cso");
    auto integrate = Read(std::filesystem::path(argv[1]) / "0xF7F00004.cso");
    auto cs = Read(std::filesystem::path(argv[1]) / "0xF7F00003.cso");
    auto generate_ps = Graphics(device.Get(), root.Get(), vs, ps);
    auto integrate_ps = Graphics(device.Get(), root.Get(), vs, integrate);
    auto temporal = Read(std::filesystem::path(argv[1]) / "0xF7F00007.cso");
    auto temporal_ps = Graphics(device.Get(), root.Get(), vs, temporal);
    auto interior_code = Read(std::filesystem::path(argv[1]) / "0xF7F00008.cso");
    auto interior_ps = Graphics(device.Get(), root.Get(), vs, interior_code);
    D3D12_COMPUTE_PIPELINE_STATE_DESC compute_desc{};
    compute_desc.pRootSignature = root.Get();
    compute_desc.CS = {cs.data(), cs.size()};
    ComPtr<ID3D12PipelineState> generate_cs;
    Check(device->CreateComputePipelineState(&compute_desc, IID_PPV_ARGS(&generate_cs)));
    auto local_rt_code = Read(std::filesystem::path(argv[1]) / "0xF7F00005.cso");
    auto local_raster_code = Read(std::filesystem::path(argv[1]) / "0xF7F00006.cso");
    ComPtr<ID3D12PipelineState> local_rt, local_raster;
    compute_desc.CS = {local_rt_code.data(), local_rt_code.size()};
    Check(device->CreateComputePipelineState(&compute_desc, IID_PPV_ARGS(&local_rt)));
    compute_desc.CS = {local_raster_code.data(), local_raster_code.size()};
    Check(device->CreateComputePipelineState(&compute_desc, IID_PPV_ARGS(&local_raster)));
    auto local_lights = Buffer(device.Get(), 257 * 160, D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ);
    D3D12_DESCRIPTOR_HEAP_DESC heap_desc{D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV, 9, D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE, 0};
    ComPtr<ID3D12DescriptorHeap> heap;
    Check(device->CreateDescriptorHeap(&heap_desc, IID_PPV_ARGS(&heap)));
    D3D12_SHADER_RESOURCE_VIEW_DESC shadow{};
    shadow.Format = DXGI_FORMAT_R16_UNORM;
    shadow.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2DARRAY;
    shadow.Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
    shadow.Texture2DArray.MipLevels = 1;
    shadow.Texture2DArray.ArraySize = 4;
    D3D12_HEAP_PROPERTIES texture_heap{};
    texture_heap.Type = D3D12_HEAP_TYPE_DEFAULT;
    D3D12_RESOURCE_DESC texture_desc{};
    texture_desc.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D;
    texture_desc.Width = texture_desc.Height = 8;
    texture_desc.MipLevels = texture_desc.SampleDesc.Count = 1;
    texture_desc.DepthOrArraySize = 6;
    texture_desc.Format = DXGI_FORMAT_R16_UNORM;
    ComPtr<ID3D12Resource> shadow_texture;
    Check(device->CreateCommittedResource(&texture_heap, D3D12_HEAP_FLAG_NONE, &texture_desc, D3D12_RESOURCE_STATE_COPY_DEST, nullptr, IID_PPV_ARGS(&shadow_texture)));
    auto descriptor = heap->GetCPUDescriptorHandleForHeapStart();
    for (UINT i = 0; i < 4; ++i) {
      device->CreateShaderResourceView(shadow_texture.Get(), &shadow, descriptor);
      descriptor.ptr += device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
    }
    device->CreateShaderResourceView(shadow_texture.Get(), &shadow, descriptor);
    descriptor.ptr += device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
    auto cube = shadow;
    cube.ViewDimension = D3D12_SRV_DIMENSION_TEXTURECUBEARRAY;
    cube.TextureCubeArray = {0, 1, 0, 1, 0};
    device->CreateShaderResourceView(shadow_texture.Get(), &cube, descriptor);
    descriptor.ptr += device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
    device->CreateShaderResourceView(shadow_texture.Get(), &shadow, descriptor);
    descriptor.ptr += device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
    D3D12_SHADER_RESOURCE_VIEW_DESC structured{};
    D3D12_SHADER_RESOURCE_VIEW_DESC depth_view{};
    depth_view.Format = DXGI_FORMAT_R32_FLOAT;
    depth_view.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2D;
    depth_view.Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
    depth_view.Texture2D.MipLevels = 1;
    device->CreateShaderResourceView(nullptr, &depth_view, descriptor);
    descriptor.ptr += device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
    structured.ViewDimension = D3D12_SRV_DIMENSION_BUFFER;
    structured.Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
    structured.Buffer.NumElements = 257;
    structured.Buffer.StructureByteStride = 160;
    device->CreateShaderResourceView(local_lights.Get(), &structured, descriptor);
    D3D12_PLACED_SUBRESOURCE_FOOTPRINT footprints[6]{};
    UINT64 texture_bytes = 0;
    device->GetCopyableFootprints(&texture_desc, 0, 6, 0, footprints, nullptr, nullptr, &texture_bytes);
    auto shadow_upload = Buffer(device.Get(), texture_bytes, D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ);
    std::vector<char> zero_depths(size_t(texture_bytes), 0);
    Upload(shadow_upload.Get(), zero_depths.data(), zero_depths.size());
    auto frame = Buffer(device.Get(), 5632, D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ);
    auto light = Buffer(device.Get(), 57600, D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ);
    auto settings = Buffer(device.Get(), 256, D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ);
    const std::array<uint8_t,256> empty_controls{};
    Upload(settings.Get(),empty_controls.data(),empty_controls.size());
    auto grid = Buffer(device.Get(), 256, D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ);
    constexpr uint32_t width = 16, height = 9, slices = 32;
    constexpr uint32_t cell_bytes = width * height * slices * 8;
    constexpr uint32_t volume_bytes = FOG_HEADER_BYTES + width * height * (3 * slices + 1) * 8;
    constexpr uint32_t interior_bytes = 128 + width * height * 8, bytes = volume_bytes + interior_bytes + width * height * slices * 4;
    auto output = Buffer(device.Get(), bytes, D3D12_HEAP_TYPE_DEFAULT, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    auto readback = Buffer(device.Get(), bytes, D3D12_HEAP_TYPE_READBACK, D3D12_RESOURCE_STATE_COPY_DEST);
    std::array<std::array<float, 4>, 352> frame_data{};
    frame_data[1] = {1, 0, 0, 0};
    frame_data[2] = {0, 1, 0, 0};
    frame_data[3] = {0, 0, 1, 0};
    frame_data[13] = {1, 0, 0, 0};
    frame_data[14] = {0, 1, 0, 0};
    frame_data[15] = {0, 0, 1, 1};
    frame_data[17] = {1, 0, 0, 0};
    frame_data[18] = {0, 1, 0, 0};
    frame_data[20] = {0, 0, 1, 1};
    frame_data[21] = {0, 1, 1, 1};
    frame_data[22] = {-1, 1, .2f, 1000};
    frame_data[23] = {1920, 1080, 1.f / 1920, 1.f / 1080};
    frame_data[38] = {0, 0, 1, 0};
    frame_data[42] = {1, 0, 1000, 1};
    frame_data[48] = {1, 0, 1, 0};
    std::array<std::array<float, 4>, 3600> light_data{};
    light_data[0] = {0, 0, 1, 0};
    light_data[1] = {1, 1, 1, 0};
    Upload(light.Get(), light_data.data(), sizeof(light_data));
    uint32_t grid_data[8] = {width, height, slices, 0, 0, 0, 0, 0};
    Upload(grid.Get(), grid_data, sizeof(grid_data));
    ComPtr<ID3D12Fence> fence;
    Check(device->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&fence)));
    HANDLE event = CreateEvent(nullptr, FALSE, FALSE, nullptr);
    if (!event) throw std::runtime_error("Fence event failed");
    uint64_t serial = 0;
    std::vector<uint32_t> graphics_result;
    for (float clear_distance : {-100.f, 0.f})
    for (bool shaped_weather : {false, true})
      for (uint32_t local_count : {0u, 1u, 257u})
        for (bool occluded : {false, true})
          for (float density : {0.f, .001f})
            for (float strength : {1.f, 1000.f})
              for (unsigned independent : {0u,1u,2u,3u,4u,5u})
              for (bool compute : {false, true}) {
                Check(allocator->Reset());
                Check(cmd->Reset(allocator.Get(), nullptr));
                frame_data[42][3] = shaped_weather ? 1.3385415077f : 1.f;
                frame_data[48] = shaped_weather ? std::array<float, 4>{49.982872f, 1, .0005f, 0} : std::array<float, 4>{1, 0, 1, 0};
                frame_data[43] = {density, 0, 0, 0};
                Upload(frame.Get(), frame_data.data(), sizeof(frame_data));
                const bool local = local_count > 0;
                std::array<std::array<float, 4>, 10> point{};
                point[0] = {0, 0, 20, 100};
                point[3] = {strength, 2 * strength, 4 * strength, 0};
                point[5] = {.01f, 1, occluded ? 1.f : 0.f, 1};
                uint32_t tile = 4u << 18;
                float packed;
                std::memcpy(&packed, &tile, 4);
                point[7] = {packed, packed, packed, packed};
                point[8] = {packed, packed, 0, 0};
                light_data[67][0] = 1.f;
                std::vector<std::array<float, 4>> records(257 * 10);
                for (uint32_t i = 0; i < 257; ++i) std::copy(point.begin(), point.end(), records.begin() + i * 10);
                Upload(local_lights.Get(), records.data(), records.size() * sizeof(records[0]));
                std::memcpy(&light_data[68], point.data(), sizeof(point));
                uint32_t count = local_count;
                std::memcpy(&light_data[67][1], &count, sizeof(count));
                light_data[14][2] = occluded ? 1.f : 0.f;
                light_data[6][2] = .5f;
                light_data[9][0] = 1.f;
                light_data[10] = {.5f, .5f, .5f, 0};
                light_data[16][0] = .1f;
                Upload(light.Get(), light_data.data(), sizeof(light_data));
                float controls[12] = {1, 1, local ? 0.f : strength, 0, clear_distance, 1, 1, local ? 1.f : 0.f, 1, 0, 0, 0};
                Upload(settings.Get(), controls, sizeof(controls));
                VolumeLightData beams{independent==3u?0.f:1.f, independent==4u?0.f:1.f, independent==5u?100.f:0.f, 1.f, 1.f, 1.f, 1.f, independent?FOG_LIGHT_VALID:0u};
                if(independent) {
                  controls[1]=independent==1u?0.f:independent==2u?3.f:1.f;
                  Upload(settings.Get(),controls,sizeof(controls));
                }
                void* settings_data=nullptr;
                Check(settings->Map(0,nullptr,&settings_data));
                std::memcpy(static_cast<uint8_t*>(settings_data)+FOG_LIGHT_CONSTANT_OFFSET,&beams,sizeof(beams));
                settings->Unmap(0,nullptr);
                D3D12_RESOURCE_BARRIER barrier{};
                barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
                barrier.Transition = {output.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_COPY_SOURCE, D3D12_RESOURCE_STATE_UNORDERED_ACCESS};
                if (serial)
                  cmd->ResourceBarrier(1, &barrier);
                else {
                  for (UINT layer = 0; layer < 6; ++layer) {
                    D3D12_TEXTURE_COPY_LOCATION source{};
                    source.pResource = shadow_upload.Get();
                    source.Type = D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT;
                    source.PlacedFootprint = footprints[layer];
                    D3D12_TEXTURE_COPY_LOCATION destination{};
                    destination.pResource = shadow_texture.Get();
                    destination.Type = D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX;
                    destination.SubresourceIndex = layer;
                    cmd->CopyTextureRegion(&destination, 0, 0, 0, &source, nullptr);
                  }
                  barrier.Transition = {shadow_texture.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_COPY_DEST, D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE | D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE};
                  cmd->ResourceBarrier(1, &barrier);
                }
                ID3D12DescriptorHeap* heaps[] = {heap.Get()};
                cmd->SetDescriptorHeaps(1, heaps);
                cmd->SetGraphicsRootSignature(root.Get());
                cmd->SetGraphicsRootShaderResourceView(10, settings->GetGPUVirtualAddress());
                cmd->SetComputeRootSignature(root.Get());
                cmd->SetComputeRootShaderResourceView(10, settings->GetGPUVirtualAddress());
                ID3D12Resource* buffers[] = {frame.Get(), light.Get(), settings.Get(), grid.Get()};
                for (UINT i = 0; i < 4; ++i) {
                  cmd->SetGraphicsRootConstantBufferView(i, buffers[i]->GetGPUVirtualAddress());
                  cmd->SetComputeRootConstantBufferView(i, buffers[i]->GetGPUVirtualAddress());
                }
                cmd->SetGraphicsRootUnorderedAccessView(4, output->GetGPUVirtualAddress());
                cmd->SetComputeRootUnorderedAccessView(4, output->GetGPUVirtualAddress());
                cmd->SetGraphicsRootDescriptorTable(5, heap->GetGPUDescriptorHandleForHeapStart());
                cmd->SetComputeRootDescriptorTable(5, heap->GetGPUDescriptorHandleForHeapStart());
                cmd->SetGraphicsRootShaderResourceView(6, settings->GetGPUVirtualAddress());
                cmd->SetGraphicsRootShaderResourceView(7, settings->GetGPUVirtualAddress());
                cmd->SetComputeRootShaderResourceView(6, settings->GetGPUVirtualAddress());
                cmd->SetComputeRootShaderResourceView(7, settings->GetGPUVirtualAddress());
                auto local_table = heap->GetGPUDescriptorHandleForHeapStart();
                local_table.ptr += 8 * device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
                cmd->SetComputeRootDescriptorTable(8, local_table);
                cmd->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
                cmd->OMSetRenderTargets(0, nullptr, FALSE, nullptr);
                D3D12_VIEWPORT viewport{0, 0, float(width * 8), float(height * ((slices + 7) / 8)), 0, 1};
                D3D12_RECT scissor{0, 0, LONG(viewport.Width), LONG(viewport.Height)};
                cmd->RSSetViewports(1, &viewport);
                cmd->RSSetScissorRects(1, &scissor);
                if (compute) {
                  cmd->SetPipelineState(generate_cs.Get());
                  cmd->Dispatch((width + 3) / 4, (height + 3) / 4, (slices + 3) / 4);
                } else {
                  cmd->SetPipelineState(generate_ps.Get());
                  cmd->DrawInstanced(3, 1, 0, 0);
                }
                barrier = {};
                barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_UAV;
                barrier.UAV.pResource = output.Get();
                cmd->ResourceBarrier(1, &barrier);
                if (local) {
                  cmd->SetPipelineState((compute || local_count > 256) ? local_rt.Get() : local_raster.Get());
                  cmd->Dispatch((width + 3) / 4, (height + 3) / 4, (slices + 3) / 4);
                  cmd->ResourceBarrier(1, &barrier);
                }
                cmd->SetPipelineState(temporal_ps.Get());
                cmd->DrawInstanced(3, 1, 0, 0);
                cmd->ResourceBarrier(1, &barrier);
                viewport.Width = width;
                viewport.Height = height;
                scissor.right = width;
                scissor.bottom = height;
                cmd->RSSetViewports(1, &viewport);
                cmd->RSSetScissorRects(1, &scissor);
                cmd->SetPipelineState(integrate_ps.Get());
                cmd->DrawInstanced(3, 1, 0, 0);
                barrier = {};
                barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
                barrier.Transition = {output.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_COPY_SOURCE};
                cmd->ResourceBarrier(1, &barrier);
                cmd->CopyBufferRegion(readback.Get(), 0, output.Get(), 0, bytes);
                Check(cmd->Close());
                ID3D12CommandList* lists[] = {cmd.Get()};
                queue->ExecuteCommandLists(1, lists);
                Check(queue->Signal(fence.Get(), ++serial));
                Check(fence->SetEventOnCompletion(serial, event));
                if (WaitForSingleObject(event, 30000) != WAIT_OBJECT_0) throw std::runtime_error("GPU test timed out");
                void* mapped = nullptr;
                D3D12_RANGE read{0, bytes};
                Check(readback->Map(0, &read, &mapped));
                std::vector<uint32_t> result(bytes / 4);
                std::memcpy(result.data(), mapped, bytes);
                readback->Unmap(0, nullptr);
                const float fog_density=density*(independent==1u?0.f:independent==2u?3.f:1.f);
                const float expected_opacity = std::pow(1.f - std::exp(-fog_density * 1000.f), frame_data[42][3]) * (shaped_weather ? (clear_distance < 0.f ? .5495f : .4995f) : 1.f);
                const float light_opacity=independent?1.f-std::exp(-density*(independent==5u?900.f:999.9f)):expected_opacity;
                const float expected_light = occluded ||independent==3u ||independent==4u ? 0.f : light_opacity * strength * std::exp(-density * 1000.f) / (4.f * 3.141592653589793f);
                for (uint32_t i = 0; i < width * height; ++i) {
                  const uint32_t offset = (FOG_HEADER_BYTES + 2 * cell_bytes + (slices * width * height + i) * 8) / 4;
                  const float radiance = Half(uint16_t(result[offset]));
                  const float opacity = Half(uint16_t(result[offset + 1] >> 16));
                  if (!std::isfinite(radiance) || std::abs(opacity - expected_opacity) > .002f
                      || (!local && std::abs(radiance - expected_light) > std::max(.0001f, expected_light * .004f))) throw std::runtime_error("Transport differs from analytic homogeneous-medium solution");
                }
                if (local && independent<3u) {
                  for (uint32_t z = 0; z < slices; ++z)
                    for (uint32_t y = 0; y < height; ++y)
                      for (uint32_t x = 0; x < width; ++x) {
                        const double begin = .1 * std::pow(10000., double(z) / slices), end = .1 * std::pow(10000., double(z + 1) / slices);
                        double rx = (x + .5) / width * 2. - 1., ry = 1. - (y + .5) / height * 2.;
                        const double inverse = 1. / std::sqrt(rx * rx + ry * ry + 1.);
                        rx *= inverse;
                        ry *= inverse;
                        double expected = 0;
                        for (uint32_t sample = 0; sample < 4; ++sample) {
                          const double distance = begin + (end - begin) * (sample + .5) / 4.;
                          const double dx = -rx * distance, dy = -ry * distance, dz = 20 - inverse * distance;
                          const double squared = dx * dx + dy * dy + dz * dz;
                          const double ratio = squared / 10000.;
                          if (ratio < 1) expected += .25 * std::pow(1 - ratio * ratio, 2) / (1 + .01 * squared) * std::exp(-density * std::sqrt(squared)) * std::exp(occluded ? -std::max(0., std::sqrt(squared) - .002) : 0.) / (4 * 3.141592653589793) * strength;
                        }
                        const uint32_t offset = (FOG_HEADER_BYTES + ((z * height + y) * width + x) * 8) / 4;
                        const float extinction = Half(uint16_t(result[offset + 1] >> 16));
                        const float radiance = Half(uint16_t(result[offset]));
                        // Point-light quadrature, native ten-row layout and group culling.
                        const double target = extinction > 0.f ? expected * local_count * std::max(double(extinction), .25) : 0.;
                        if (std::abs(radiance - target) > std::max(2.e-7, target * .007)) {
                          std::cerr << "local cell " << x << "," << y << "," << z << " actual=" << radiance << " expected=" << target << "\n";
                          throw std::runtime_error("Local light quadrature/culling differs from point-light reference");
                        }
                      }
                }
                if (!compute)
                  graphics_result = result;
                else {
                  // Header padding is intentionally unspecified. Every actual cell and
                  // integrated boundary must agree between Raster/PT and compute/RT paths.
                  for (uint32_t i = FOG_HEADER_BYTES / 4; i < (volume_bytes + (independent?width*height*slices*4u:0u)) / 4; ++i)
                    if (result[i] != graphics_result[i]) throw std::runtime_error("Graphics/compute grid mismatch");
                }
                std::cout << (compute ? "CS" : "PS") << " independent=" << independent << " clear distance=" << clear_distance << " weather=" << shaped_weather << " local=" << local_count << " density=" << density << " sunlight=" << strength << " shadow=" << occluded << " passed\n";
              }
    Upload(settings.Get(),empty_controls.data(),empty_controls.size());
    graphics_result[1052/4]=0u;
    // Exercise the production early capture and a later PS/CS generation with
    // t24 explicitly unbound. Only the frame-matched snapshot may remove fog.
    const auto saved_frame = frame_data;
    const auto saved_light = light_data;
    auto snapshot = Buffer(device.Get(), interior_bytes, D3D12_HEAP_TYPE_DEFAULT, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    D3D12_RESOURCE_DESC interior_desc = texture_desc;
    interior_desc.Width = interior_desc.Height = 8;
    interior_desc.DepthOrArraySize = 1;
    interior_desc.Format = DXGI_FORMAT_R16G16_FLOAT;
    ComPtr<ID3D12Resource> interior_texture;
    Check(device->CreateCommittedResource(&texture_heap, D3D12_HEAP_FLAG_NONE, &interior_desc, D3D12_RESOURCE_STATE_COPY_DEST, nullptr, IID_PPV_ARGS(&interior_texture)));
    D3D12_PLACED_SUBRESOURCE_FOOTPRINT interior_footprint{};
    uint64_t interior_upload_bytes = 0;
    device->GetCopyableFootprints(&interior_desc, 0, 1, 0, &interior_footprint, nullptr, nullptr, &interior_upload_bytes);
    auto interval_upload = Buffer(device.Get(), interior_upload_bytes, D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ);
    auto interval_descriptor = heap->GetCPUDescriptorHandleForHeapStart();
    interval_descriptor.ptr += 3 * device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
    D3D12_SHADER_RESOURCE_VIEW_DESC interval_view{};
    interval_view.Format = DXGI_FORMAT_R16G16_FLOAT;
    interval_view.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2D;
    interval_view.Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
    interval_view.Texture2D.MipLevels = 1;
    auto finish_commands = [&] {
      Check(cmd->Close());
      ID3D12CommandList* lists[] = {cmd.Get()};
      queue->ExecuteCommandLists(1, lists);
      Check(queue->Signal(fence.Get(), ++serial));
      Check(fence->SetEventOnCompletion(serial, event));
      if (WaitForSingleObject(event, 30000) != WAIT_OBJECT_0) throw std::runtime_error("Interior GPU test timed out");
    };
    auto bind_inputs = [&](ID3D12Resource* target) {
      ID3D12DescriptorHeap* heaps[] = {heap.Get()};
      cmd->SetDescriptorHeaps(1, heaps);
      cmd->SetGraphicsRootSignature(root.Get());
      cmd->SetGraphicsRootShaderResourceView(10, settings->GetGPUVirtualAddress());
      cmd->SetComputeRootSignature(root.Get());
      cmd->SetComputeRootShaderResourceView(10, settings->GetGPUVirtualAddress());
      ID3D12Resource* buffers[] = {frame.Get(), light.Get(), settings.Get(), grid.Get()};
      for (UINT i = 0; i < 4; ++i) {
        cmd->SetGraphicsRootConstantBufferView(i, buffers[i]->GetGPUVirtualAddress());
        cmd->SetComputeRootConstantBufferView(i, buffers[i]->GetGPUVirtualAddress());
      }
      cmd->SetGraphicsRootUnorderedAccessView(4, target->GetGPUVirtualAddress());
      cmd->SetComputeRootUnorderedAccessView(4, target->GetGPUVirtualAddress());
      cmd->SetGraphicsRootDescriptorTable(5, heap->GetGPUDescriptorHandleForHeapStart());
      cmd->SetComputeRootDescriptorTable(5, heap->GetGPUDescriptorHandleForHeapStart());
      cmd->SetGraphicsRootShaderResourceView(6, settings->GetGPUVirtualAddress());
      cmd->SetGraphicsRootShaderResourceView(7, settings->GetGPUVirtualAddress());
      cmd->SetComputeRootShaderResourceView(6, settings->GetGPUVirtualAddress());
      cmd->SetComputeRootShaderResourceView(7, settings->GetGPUVirtualAddress());
      cmd->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
      cmd->OMSetRenderTargets(0, nullptr, FALSE, nullptr);
    };
    // The zero-depth cascade shadows z > 0 and lights z < 0. Validate the
    // water-only capture with the production Raster and compute shaders.
    frame_data[0] = {};
    light_data = {};
    light_data[0] = {0, 0, 1, 0};
    light_data[1] = {3, 2, 1, 0};
    light_data[5][2] = .025f;
    light_data[9][0] = 1.f;
    light_data[10] = {.5f, .5f, .5f, 0.f};
    light_data[14][2] = 1.f;
    Upload(frame.Get(), frame_data.data(), sizeof(frame_data));
    Upload(light.Get(), light_data.data(), sizeof(light_data));
    const uint32_t water_grid[8] = {WATER_LIGHT_GRID, WATER_LIGHT_GRID, WATER_LIGHT_SLICES, 0, WATER_LIGHT_CAPTURE, 0, 0, 0};
    Upload(grid.Get(), water_grid, sizeof(water_grid));
    constexpr uint32_t layer = WATER_LIGHT_GRID * WATER_LIGHT_GRID;
    constexpr uint32_t water_bytes = WATER_LIGHT_HEADER + layer * WATER_LIGHT_SLICES * 4;
    for (bool compute : {false, true}) {
      Check(allocator->Reset());
      Check(cmd->Reset(allocator.Get(), compute ? generate_cs.Get() : generate_ps.Get()));
      D3D12_RESOURCE_BARRIER barrier{};
      barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
      barrier.Transition = {output.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_COPY_SOURCE, D3D12_RESOURCE_STATE_UNORDERED_ACCESS};
      cmd->ResourceBarrier(1, &barrier);
      bind_inputs(output.Get());
      if (compute) cmd->Dispatch(WATER_LIGHT_GRID / 4, WATER_LIGHT_GRID / 4, WATER_LIGHT_SLICES / 4);
      else {
        const D3D12_VIEWPORT viewport{0, 0, float(WATER_LIGHT_GRID * 8), float(WATER_LIGHT_GRID * WATER_LIGHT_SLICES / 8), 0, 1};
        const D3D12_RECT scissor{0, 0, LONG(viewport.Width), LONG(viewport.Height)};
        cmd->RSSetViewports(1, &viewport);
        cmd->RSSetScissorRects(1, &scissor);
        cmd->DrawInstanced(3, 1, 0, 0);
      }
      std::swap(barrier.Transition.StateBefore, barrier.Transition.StateAfter);
      cmd->ResourceBarrier(1, &barrier);
      cmd->CopyBufferRegion(readback.Get(), 0, output.Get(), 0, water_bytes);
      finish_commands();
      void* mapped = nullptr;
      Check(readback->Map(0, nullptr, &mapped));
      auto* words = static_cast<const uint32_t*>(mapped);
      bool correct = words[0] == WATER_LIGHT_VALID && std::bit_cast<float>(words[18]) == 1.f
                     && std::bit_cast<float>(words[20]) == 3.f;
      for (uint32_t i = 0; i < layer * WATER_LIGHT_SLICES; ++i) {
        const float expected = i / layer < WATER_LIGHT_SLICES / 2 ? 1.f : 0.f;
        correct &= std::bit_cast<float>(words[WATER_LIGHT_HEADER / 4 + i]) == expected;
      }
      readback->Unmap(0, nullptr);
      if (!correct) throw std::runtime_error("Water sunlight capture did not reproduce the native cascade boundary");
    }
    std::cout << "PASS water sunlight capture: 9216 cells each in Raster and compute, native radiance and cascade boundary\n";
    struct InteriorCase {
      float entry, exit, optical_length, scale = 128;
      uint32_t rejection = 0;
    };
    std::vector<InteriorCase> intervals = {
        {120000, 10, 989.2f}, {10, 20, 988}, {120000, 120000, 1000}, {2000, 3000, 1000}, {120000, 2000, 0}, {120000, 10, 1000, 0}, {120000, 10, 1000, -1}, {120000, 10, 1000, 128, 1}, {120000, 10, 1000, 128, 2}, {120000, 10, 1000, 128, 3}, {120000, 10, 1000, 128, 4}, {NAN, 10, 1000}, {-1, 10, 1000}, {120000, 10, 989.2f, 128, 5}};
    for (uint32_t i = 0; i <= 32; ++i) intervals.push_back({120000, 8.f + i * .125f, 991.2f - i * .125f});
    bool first_snapshot = true;
    for (uint32_t test = 0; test < intervals.size(); ++test)
      for (bool independent : {false,true})
      for (unsigned indoors=0;indoors<(independent?2u:1u);++indoors)
      for (bool compute : {false, true}) {
        const auto& interval = intervals[test];
        frame_data = saved_frame;
        frame_data[23] = {8, 8, .125f, .125f};
        frame_data[42][3] = 1;
        frame_data[43] = {.002f, 0, 0, 0};
        frame_data[48] = {1, 0, 1, 0};
        light_data = saved_light;
        light_data[14][2] = 0;
        light_data[33][2] = interval.scale;
        uint32_t interior_light_count = 1;
        std::memcpy(&light_data[67][1], &interior_light_count, 4);
        light_data[73][2] = 0;  // Unshadowed point light must also respect the vacuum.
        Upload(frame.Get(), frame_data.data(), sizeof(frame_data));
        Upload(light.Get(), light_data.data(), sizeof(light_data));
        float controls[12] = {1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0};
        Upload(settings.Get(), controls, sizeof(controls));
        VolumeLightData beams{1.f,1.f,0.f,1.f,1.f,1.f,1.f,independent?FOG_LIGHT_VALID:0u,float(indoors)};
        void* settings_data=nullptr;
        Check(settings->Map(0,nullptr,&settings_data));
        std::memcpy(static_cast<uint8_t*>(settings_data)+FOG_LIGHT_CONSTANT_OFFSET,&beams,sizeof(beams));
        settings->Unmap(0,nullptr);
        grid_data[0] = interval.rejection == 5 ? width / 2 : width;
        grid_data[1] = interval.rejection == 5 ? height / 2 : height;
        grid_data[4] = 4;
        grid_data[6] = 0;
        Upload(grid.Get(), grid_data, sizeof(grid_data));
        std::vector<uint8_t> pixels(size_t(interior_upload_bytes), 0);
        for (uint32_t y = 0; y < 4; ++y)
          for (uint32_t x = 0; x < 4; ++x) {
            using DirectX::PackedVector::XMConvertFloatToHalf;
            const uint16_t boundaries[2] = {XMConvertFloatToHalf(interval.entry / 128.f), XMConvertFloatToHalf(interval.exit / 128.f)};
            std::memcpy(pixels.data() + interior_footprint.Offset + y * interior_footprint.Footprint.RowPitch + x * 4, boundaries, 4);
          }
        Upload(interval_upload.Get(), pixels.data(), pixels.size());
        device->CreateShaderResourceView(interval.rejection == 2 ? nullptr : interior_texture.Get(), &interval_view, interval_descriptor);
        Check(allocator->Reset());
        Check(cmd->Reset(allocator.Get(), interior_ps.Get()));
        D3D12_RESOURCE_BARRIER barrier{};
        barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
        if (!first_snapshot) {
          barrier.Transition = {snapshot.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_COPY_SOURCE, D3D12_RESOURCE_STATE_UNORDERED_ACCESS};
          cmd->ResourceBarrier(1, &barrier);
          barrier.Transition = {interior_texture.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE, D3D12_RESOURCE_STATE_COPY_DEST};
          cmd->ResourceBarrier(1, &barrier);
        }
        D3D12_TEXTURE_COPY_LOCATION source{};
        source.pResource = interval_upload.Get();
        source.Type = D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT;
        source.PlacedFootprint = interior_footprint;
        D3D12_TEXTURE_COPY_LOCATION destination{};
        destination.pResource = interior_texture.Get();
        destination.Type = D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX;
        cmd->CopyTextureRegion(&destination, 0, 0, 0, &source, nullptr);
        barrier.Transition = {interior_texture.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_COPY_DEST, D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE};
        cmd->ResourceBarrier(1, &barrier);
        bind_inputs(snapshot.Get());
        D3D12_VIEWPORT viewport{0, 0, float(grid_data[0]), float(grid_data[1]), 0, 1};
        D3D12_RECT scissor{0, 0, LONG(grid_data[0]), LONG(grid_data[1])};
        cmd->RSSetViewports(1, &viewport);
        cmd->RSSetScissorRects(1, &scissor);
        cmd->DrawInstanced(3, 1, 0, 0);
        barrier.Transition = {snapshot.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_COPY_SOURCE};
        cmd->ResourceBarrier(1, &barrier);
        finish_commands();
        first_snapshot = false;
        // This is the missing native binding at the real sun consumer.
        device->CreateShaderResourceView(nullptr, &interval_view, interval_descriptor);
        if (interval.rejection == 1) frame_data[0][0] += 1;
        if (interval.rejection == 3) frame_data[17][0] += 1;
        if (interval.rejection == 4) frame_data[23][0] += 1;
        Upload(frame.Get(), frame_data.data(), sizeof(frame_data));
        grid_data[0] = width;
        grid_data[1] = height;
        Upload(grid.Get(), grid_data, sizeof(grid_data));
        Check(allocator->Reset());
        Check(cmd->Reset(allocator.Get(), nullptr));
        barrier.Transition = {output.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_COPY_SOURCE, D3D12_RESOURCE_STATE_COPY_DEST};
        cmd->ResourceBarrier(1, &barrier);
        cmd->CopyBufferRegion(output.Get(), volume_bytes + (independent?width*height*slices*4u:0u), snapshot.Get(), 0, interior_bytes);
        barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_COPY_DEST;
        barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_UNORDERED_ACCESS;
        cmd->ResourceBarrier(1, &barrier);
        bind_inputs(output.Get());
        viewport.Width = width * 8;
        viewport.Height = height * ((slices + 7) / 8);
        scissor.right = LONG(viewport.Width);
        scissor.bottom = LONG(viewport.Height);
        cmd->RSSetViewports(1, &viewport);
        cmd->RSSetScissorRects(1, &scissor);
        if (compute) {
          cmd->SetPipelineState(generate_cs.Get());
          cmd->Dispatch((width + 3) / 4, (height + 3) / 4, (slices + 3) / 4);
        } else {
          cmd->SetPipelineState(generate_ps.Get());
          cmd->DrawInstanced(3, 1, 0, 0);
        }
        D3D12_RESOURCE_BARRIER uav{};
        uav.Type = D3D12_RESOURCE_BARRIER_TYPE_UAV;
        uav.UAV.pResource = output.Get();
        cmd->ResourceBarrier(1, &uav);
        cmd->SetPipelineState(local_raster.Get());
        cmd->Dispatch((width + 3) / 4, (height + 3) / 4, (slices + 3) / 4);
        cmd->ResourceBarrier(1, &uav);
        cmd->SetPipelineState(temporal_ps.Get());
        cmd->DrawInstanced(3, 1, 0, 0);
        cmd->ResourceBarrier(1, &uav);
        viewport.Width = width;
        viewport.Height = height;
        scissor.right = width;
        scissor.bottom = height;
        cmd->RSSetViewports(1, &viewport);
        cmd->RSSetScissorRects(1, &scissor);
        cmd->SetPipelineState(integrate_ps.Get());
        cmd->DrawInstanced(3, 1, 0, 0);
        barrier.Transition = {output.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_COPY_SOURCE};
        cmd->ResourceBarrier(1, &barrier);
        cmd->CopyBufferRegion(readback.Get(), 0, output.Get(), 0, bytes);
        finish_commands();
        void* mapped = nullptr;
        D3D12_RANGE range{0, bytes};
        Check(readback->Map(0, &range, &mapped));
        const auto* values = static_cast<const uint32_t*>(mapped);
        const double expected = 1 - std::exp(-.002 * interval.optical_length);
        for (uint32_t i = 0; i < width * height; ++i) {
          const uint32_t offset = (FOG_HEADER_BYTES + 2 * cell_bytes + (slices * width * height + i) * 8) / 4;
          if (std::abs(Half(uint16_t(values[offset + 1] >> 16)) - expected) > .0015) throw std::runtime_error("Captured interior optical length differs from Classic boundary integral, case " + std::to_string(test));
        }
        if (interval.scale > 0 && interval.rejection == 0 && interval.entry > interval.exit) {
          for (uint32_t z = 0; z <= slices && .1 * std::pow(10002., double(z) / slices) <= interval.exit; ++z)
            for (uint32_t i = 0; i < width * height; ++i) {
              const uint32_t offset = (FOG_HEADER_BYTES + 2 * cell_bytes + (z * width * height + i) * 8) / 4;
              if ((!indoors &&(values[offset]!=0 ||values[offset+1]!=0))
                  ||(indoors && (Half(uint16_t(values[offset+1]>>16))!=0.f ||(.1*std::pow(10002.,double(z)/slices)>.3 &&Half(uint16_t(values[offset]))<=0.f))))
                { std::cerr<<"Indoor case="<<test<<" independent="<<independent<<" indoor="<<indoors<<" z="<<z
                    <<" rgb="<<Half(uint16_t(values[offset]))<<" alpha="<<Half(uint16_t(values[offset+1]>>16))
                    <<" captured indoor="<<std::bit_cast<float>(values[1056/4])<<"\n";
                  throw std::runtime_error("Indoor light density did not remain independent of the fog vacuum"); }
            }
        }
        if (!indoors && interval.scale > 0 && interval.rejection == 0 && interval.entry >= 0 && interval.entry < interval.exit) {
          for (uint32_t z = 0; z < slices; ++z) {
            const double begin = .1 * std::pow(10002., double(z) / slices), end = .1 * std::pow(10002., double(z + 1) / slices);
            if (begin < interval.entry || end > interval.exit) continue;
            for (uint32_t i = 0; i < width * height; ++i) {
              const uint32_t offset = (FOG_HEADER_BYTES + (z * width * height + i) * 8) / 4;
              if (values[offset] != 0 || values[offset + 1] != 0) throw std::runtime_error("An entered interior contains medium or scattering");
            }
          }
        }
        readback->Unmap(0, nullptr);
        std::cout << "Interior independent=" << independent << " indoor-light=" << indoors << " capture case " << test << " " << (compute ? "CS" : "PS") << " passed\n";
      }
    frame_data = saved_frame;
    light_data = saved_light;
    Upload(frame.Get(), frame_data.data(), sizeof(frame_data));
    Upload(light.Get(), light_data.data(), sizeof(light_data));
    Upload(settings.Get(),empty_controls.data(),empty_controls.size());
    float saved_controls[12] = {1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0};
    Upload(settings.Get(), saved_controls, sizeof(saved_controls));
    grid_data[4] = 0;
    grid_data[6] = 0;
    Upload(grid.Get(), grid_data, sizeof(grid_data));
    auto current_upload = Buffer(device.Get(), bytes, D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ);
    auto history_upload = Buffer(device.Get(), bytes, D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ);
    auto pack = [](float red, float green, float blue, float alpha) {
      using DirectX::PackedVector::XMConvertFloatToHalf;
      return std::array<uint32_t, 2>{uint32_t(XMConvertFloatToHalf(red)) | (uint32_t(XMConvertFloatToHalf(blue)) << 16), uint32_t(XMConvertFloatToHalf(green)) | (uint32_t(XMConvertFloatToHalf(alpha)) << 16)};
    };
    for (uint32_t test = 0; test < 5; ++test) {
      auto current = graphics_result, history = graphics_result;
      for (uint32_t z = 0; z < slices; ++z)
        for (uint32_t y = 0; y < height; ++y)
          for (uint32_t x = 0; x < width; ++x) {
            const float luminance = (x & 1u) ? 16.f : 8.f;
            auto value = pack(luminance * .001f, luminance * .002f, luminance * .004f, .001f);
            const uint32_t index = (FOG_HEADER_BYTES + ((z * height + y) * width + x) * 8) / 4;
            current[index] = value[0];
            current[index + 1] = value[1];
            value = pack((test == 0 ? 10000.f : 12.f) * .001f, (test == 0 ? 20000.f : 24.f) * .001f, (test == 0 ? 40000.f : 48.f) * .001f, test == 3 ? .002f : .001f);
            history[index + cell_bytes / 4] = value[0];
            history[index + cell_bytes / 4 + 1] = value[1];
          }
      // Independently trigger weather, density and camera-cut rejection.
      if (test == 2) {
        float changed = 9;
        std::memcpy(&history[(64 + 42 * 16) / 4], &changed, 4);
      }
      if (test == 4) {
        float changed = 20;
        std::memcpy(&history[64 / 4], &changed, 4);
      }
      Upload(current_upload.Get(), current.data(), bytes);
      Upload(history_upload.Get(), history.data(), bytes);
      grid_data[6] = 1;
      Upload(grid.Get(), grid_data, sizeof(grid_data));
      Check(allocator->Reset());
      Check(cmd->Reset(allocator.Get(), temporal_ps.Get()));
      D3D12_RESOURCE_BARRIER barrier{};
      barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
      barrier.Transition = {output.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_COPY_SOURCE, D3D12_RESOURCE_STATE_COPY_DEST};
      cmd->ResourceBarrier(1, &barrier);
      cmd->CopyBufferRegion(output.Get(), 0, current_upload.Get(), 0, bytes);
      barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_COPY_DEST;
      barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_UNORDERED_ACCESS;
      cmd->ResourceBarrier(1, &barrier);
      cmd->SetGraphicsRootSignature(root.Get());
      cmd->SetGraphicsRootShaderResourceView(10, settings->GetGPUVirtualAddress());
      cmd->SetGraphicsRootConstantBufferView(0, frame->GetGPUVirtualAddress());
      cmd->SetGraphicsRootConstantBufferView(2, settings->GetGPUVirtualAddress());
      cmd->SetGraphicsRootConstantBufferView(3, grid->GetGPUVirtualAddress());
      cmd->SetGraphicsRootUnorderedAccessView(4, output->GetGPUVirtualAddress());
      cmd->SetGraphicsRootShaderResourceView(7, history_upload->GetGPUVirtualAddress());
      cmd->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
      cmd->OMSetRenderTargets(0, nullptr, FALSE, nullptr);
      D3D12_VIEWPORT viewport{0, 0, float(width * 8), float(height * ((slices + 7) / 8)), 0, 1};
      D3D12_RECT scissor{0, 0, LONG(viewport.Width), LONG(viewport.Height)};
      cmd->RSSetViewports(1, &viewport);
      cmd->RSSetScissorRects(1, &scissor);
      cmd->DrawInstanced(3, 1, 0, 0);
      barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_UNORDERED_ACCESS;
      barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_COPY_SOURCE;
      cmd->ResourceBarrier(1, &barrier);
      cmd->CopyBufferRegion(readback.Get(), 0, output.Get(), 0, bytes);
      Check(cmd->Close());
      ID3D12CommandList* lists[] = {cmd.Get()};
      queue->ExecuteCommandLists(1, lists);
      Check(queue->Signal(fence.Get(), ++serial));
      Check(fence->SetEventOnCompletion(serial, event));
      if (WaitForSingleObject(event, 30000) != WAIT_OBJECT_0) throw std::runtime_error("Temporal GPU test timed out");
      void* mapped = nullptr;
      D3D12_RANGE read{0, bytes};
      Check(readback->Map(0, &read, &mapped));
      auto* result = static_cast<const uint32_t*>(mapped);
      uint32_t accumulated = 0;
      for (uint32_t i = 0; i < width * height * slices; ++i) {
        uint32_t raw = FOG_HEADER_BYTES / 4 + i * 2, resolved = raw + cell_bytes / 4;
        float value = Half(uint16_t(result[resolved]));
        if (!std::isfinite(value) || value < .0079f || value > .0161f) throw std::runtime_error("Temporal history escaped HDR neighborhood bounds");
        if (uint16_t(result[resolved + 1] >> 16) != uint16_t(current[raw + 1] >> 16)) throw std::runtime_error("Temporal filter altered extinction");
        if (test >= 2 && (result[resolved] != current[raw] || result[resolved + 1] != current[raw + 1])) throw std::runtime_error("Invalid temporal history was accepted");
        if (value > .009f && value < .015f) ++accumulated;
      }
      readback->Unmap(0, nullptr);
      if (test == 1 && accumulated < width * height * slices / 2) throw std::runtime_error("Valid temporal history did not accumulate");
      std::cout << "Temporal history case " << test << " passed\n";
    }
    auto feature_code = Read(argv[2]);
    compute_desc.CS = {feature_code.data(), feature_code.size()};
    ComPtr<ID3D12PipelineState> features;
    Check(device->CreateComputePipelineState(&compute_desc, IID_PPV_ARGS(&features)));
    auto fast_upload = Buffer(device.Get(), sizeof(witcher3classic::clouds::fast_noise), D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ);
    Upload(fast_upload.Get(), witcher3classic::clouds::fast_noise, sizeof(witcher3classic::clouds::fast_noise));
    auto fixture = graphics_result;
    float base[4] = {1, 2, 3, 0};
    for (uint32_t row : {39u, 40u, 41u}) std::memcpy(&fixture[(64 + row * 16) / 4], base, 16);
    const uint32_t integrated_offset = FOG_HEADER_BYTES + 2 * cell_bytes;
    for (uint32_t i = 0; i < width * height * (slices + 1); ++i) {
      auto value = pack(1000, 2000, 4000, .5f);
      fixture[integrated_offset / 4 + 2 * i] = value[0];
      fixture[integrated_offset / 4 + 2 * i + 1] = value[1];
    }
    Upload(history_upload.Get(), fixture.data(), bytes);
    // Real native-format texture inputs exercise terrain and cloud modulation.
    std::fill(zero_depths.begin(), zero_depths.end(), char(255));
    Upload(shadow_upload.Get(), zero_depths.data(), zero_depths.size());
    for (uint32_t row : {39u, 40u, 41u}) std::memcpy(frame_data[row].data(), base, 16);
    frame_data[66] = {1, 0, 0, 0};
    Upload(frame.Get(), frame_data.data(), sizeof(frame_data));
    uint32_t terrain_count = 1;
    std::memcpy(&light_data[34][0], &terrain_count, 4);
    light_data[34][2] = 1;
    light_data[35] = {1000, 0, 0, 10};
    light_data[42] = {1, 0, 0, 1};
    Upload(light.Get(), light_data.data(), sizeof(light_data));
    for(bool independent:{false,true})
    for(const auto& mode:{std::array<float,6>{0.f,0.f,0.f,1000.f,0.f,0.f},std::array<float,6>{1.f,0.f,0.f,1000.f,0.f,0.f},
        std::array<float,6>{0.f,.35f,0.f,1000.f,0.f,0.f},std::array<float,6>{0.f,1.f,0.f,1000.f,0.f,0.f},
        std::array<float,6>{0.f,0.f,5.f,1000.f,0.f,0.f},std::array<float,6>{0.f,.35f,5.f,1000.f,0.f,0.f},std::array<float,6>{0.f,1.f,5.f,1000.f,0.f,0.f},
        std::array<float,6>{0.f,1.f,5.f,25.f,0.f,0.f},std::array<float,6>{0.f,1.f,5.f,.05f,0.f,0.f},std::array<float,6>{0.f,1.f,5.f,1000.f,1.f,0.f},
        std::array<float,6>{0.f,0.f,5.f,1.f,0.f,0.f},std::array<float,6>{0.f,0.f,5.f,1.f,0.f,-100.f},
        std::array<float,6>{0.f,0.f,5.f,25.f,0.f,-50.f},std::array<float,6>{0.f,0.f,5.f,25.f,0.f,100.f}}) {
      const float reconstruction=mode[0];
      fixture[1052/4]=independent?FOG_LIGHT_VALID:0u;
      fixture[1024/4]=std::bit_cast<uint32_t>(1.f);
      fixture[1040/4]=std::bit_cast<uint32_t>(2.f);
      if(mode[2]==5.f) {
        auto ray_fixture=fixture;
        const auto cell=pack(250.f,500.f,1000.f,.001f);
        for(uint32_t i=0;i<width*height*slices;++i) {
          ray_fixture[(FOG_HEADER_BYTES+cell_bytes)/4+2*i]=mode[4]>0.f &&i%width>=width/2?0u:cell[0];
          ray_fixture[(FOG_HEADER_BYTES+cell_bytes)/4+2*i+1]=mode[4]>0.f &&i%width>=width/2?0u:cell[1];
          ray_fixture[volume_bytes/4+i]=std::bit_cast<uint32_t>(mode[4]>0.f &&i%width>=width/2?0.f:.001f);
        }
        Upload(history_upload.Get(),ray_fixture.data(),bytes);
      } else Upload(history_upload.Get(),fixture.data(),bytes);
      frame_data[0][0] = reconstruction;
      Upload(frame.Get(), frame_data.data(), sizeof(frame_data));
      float controls[12] = {1, 1, 0, 0, mode[5], 1, 1, 1, 1, reconstruction, mode[1], mode[2]};
      Upload(settings.Get(), controls, sizeof(controls));
      grid_data[5] = 3;
      std::memcpy(&grid_data[7],&mode[3],4);
      Upload(grid.Get(), grid_data, sizeof(grid_data));
      Check(allocator->Reset());
      Check(cmd->Reset(allocator.Get(), features.Get()));
      D3D12_RESOURCE_BARRIER barrier{};
      barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
      barrier.Transition = {output.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_COPY_SOURCE, D3D12_RESOURCE_STATE_UNORDERED_ACCESS};
      cmd->ResourceBarrier(1, &barrier);
      if(mode==std::array<float,6>{0.f,0.f,0.f,1000.f,0.f,0.f}) {
        D3D12_RESOURCE_BARRIER texture_barrier{};
        texture_barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
        texture_barrier.Transition = {shadow_texture.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE, D3D12_RESOURCE_STATE_COPY_DEST};
        cmd->ResourceBarrier(1, &texture_barrier);
        for (UINT layer = 0; layer < 6; ++layer) {
          D3D12_TEXTURE_COPY_LOCATION source{};
          source.pResource = shadow_upload.Get();
          source.Type = D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT;
          source.PlacedFootprint = footprints[layer];
          D3D12_TEXTURE_COPY_LOCATION destination{};
          destination.pResource = shadow_texture.Get();
          destination.Type = D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX;
          destination.SubresourceIndex = layer;
          cmd->CopyTextureRegion(&destination, 0, 0, 0, &source, nullptr);
        }
        texture_barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_COPY_DEST;
        texture_barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE;
        cmd->ResourceBarrier(1, &texture_barrier);
      }
      ID3D12DescriptorHeap* feature_heaps[] = {heap.Get()};
      cmd->SetDescriptorHeaps(1, feature_heaps);
      cmd->SetComputeRootSignature(root.Get());
      cmd->SetComputeRootShaderResourceView(10, settings->GetGPUVirtualAddress());
      cmd->SetComputeRootConstantBufferView(0, frame->GetGPUVirtualAddress());
      cmd->SetComputeRootConstantBufferView(1, light->GetGPUVirtualAddress());
      cmd->SetComputeRootDescriptorTable(5, heap->GetGPUDescriptorHandleForHeapStart());
      cmd->SetComputeRootConstantBufferView(2, settings->GetGPUVirtualAddress());
      cmd->SetComputeRootConstantBufferView(3, grid->GetGPUVirtualAddress());
      cmd->SetComputeRootUnorderedAccessView(4, output->GetGPUVirtualAddress());
      cmd->SetComputeRootShaderResourceView(6, fast_upload->GetGPUVirtualAddress());
      cmd->SetComputeRootShaderResourceView(9, history_upload->GetGPUVirtualAddress());
      cmd->Dispatch(1, 1, 1);
      barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_UNORDERED_ACCESS;
      barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_COPY_SOURCE;
      cmd->ResourceBarrier(1, &barrier);
      cmd->CopyBufferRegion(readback.Get(), 0, output.Get(), 0, 272);
      Check(cmd->Close());
      ID3D12CommandList* lists[] = {cmd.Get()};
      queue->ExecuteCommandLists(1, lists);
      Check(queue->Signal(fence.Get(), ++serial));
      Check(fence->SetEventOnCompletion(serial, event));
      if (WaitForSingleObject(event, 30000) != WAIT_OBJECT_0) throw std::runtime_error("Feature GPU test timed out");
      void* mapped = nullptr;
      D3D12_RANGE read{0, 272};
      Check(readback->Map(0, &read, &mapped));
      std::array<float, 68> values{};
      std::memcpy(values.data(), mapped, sizeof(values));
      readback->Unmap(0, nullptr);
      const float opacity=mode[2]==5.f?std::pow(1.f-std::exp(-(independent?.001f:Half(uint16_t(pack(0,0,0,.001f)[1]>>16)))*(mode[4]>0.f?.5f:1.f)*std::max(0.f,mode[3]-.1f)),saved_frame[42][3])
          *std::clamp((mode[3]-(mode[5]>0.f?mode[5]:saved_frame[22][2]+mode[5])-saved_frame[48][1])*saved_frame[48][2],0.f,1.f):.5f;
      const float beam=mode[2]==5.f?1000.f*(independent?
          1.f-std::exp(-Half(uint16_t(pack(0,0,0,.001f)[1]>>16))*(mode[4]>0.f?.5f:1.f)*std::max(0.f,mode[3]-.1f)):opacity):1000.f;
      const float veil=opacity*(1.f-mode[1]);
      const float expected[16] = {beam,2*beam,4*beam,opacity,0,0,0,0,
          beam+veil,2*beam+2*veil,4*beam+3*veil,veil,0,1,0,1};
      for (uint32_t i = 0; i < 16; ++i)
        if (!std::isfinite(values[i]) || std::abs(values[i] - expected[i]) > std::max(.0001f, std::abs(expected[i]) * .00002f)) {
          std::cerr<<"Fog control mode "<<mode[0]<<","<<mode[1]<<","<<mode[2]<<" channel "<<i<<" got "<<values[i]<<" expected "<<expected[i]<<"\n";
          throw std::runtime_error("HDR reconstruction, independent fog/beam controls or per-pixel transport regression");
        }
      for(unsigned i=0;i<3;++i)
        if(std::abs(values[40+i]*values[43]-values[8+i])>std::max(.001f,values[8+i]*.00001f))
          throw std::runtime_error("Forward fog lost additive beam energy when clearing the veil");
      auto fast = [](uint32_t x, uint32_t y, uint32_t dimension) {
        const uint32_t ox = uint32_t(std::fmod(float(dimension) * .754877666f, 1.f) * 128), oy = uint32_t(std::fmod(float(dimension) * .569840296f, 1.f) * 128);
        return (float(witcher3classic::clouds::fast_noise[(3 * 128 + ((y + oy) & 127)) * 128 + ((x + ox) & 127)]) + .5f) / 256.f;
      };
      const float expected_fast[4] = {fast(1, 2, 0), fast(1, 2, 7), fast(127, 127, 0), fast(128, 128, 0)};
      for (uint32_t i = 0; i < 4; ++i)
        if (values[16 + i] != expected_fast[i]) throw std::runtime_error("FAST byte asset addressing differs from reference");
      if (std::abs(values[20] - std::exp(-1.f)) > 1.e-6f || std::abs(values[21] - std::exp(-.05f)) > 1.e-6f || std::abs(values[22] - 2.f / 3.f) > 1.e-5f || std::abs(values[23] - 2.f / 3.f) > 1.e-5f) throw std::runtime_error("Analytic height/interior boundary regression");
      if (values[24] != 0.f || values[25] != 1.f || values[26] != 0.f || values[27] != 1.f) throw std::runtime_error("Native terrain/cloud shadow modulation regression");
      const float expected_local[8] = {1, 0, 0, 1, 1, 0, 1, 1};
      for (uint32_t i = 0; i < 8; ++i)
        if (values[28 + i] != expected_local[i]) throw std::runtime_error("RGB/channel/animated cookie or cube-shadow regression");
      if (values[36] != (reconstruction == 0.f ? 1.f : 0.f)) throw std::runtime_error("Receiver accepted the wrong camera volume");
      const double water_distance = (mode[3] > 0.f ? mode[3] : 1000.f) * .01;
      const double transmitted = std::sqrt(1. - 1.333 * 1.333 * (1. - .8 * .8));
      const double s = (1.333 * .8 - transmitted) / (1.333 * .8 + transmitted);
      const double p = (.8 - 1.333 * transmitted) / (.8 + 1.333 * transmitted);
      const double normal_fresnel = std::pow(.333 / 2.333, 2);
      const double water_expected[] = {std::exp(-water_distance * .075 * 1.4875), std::exp(-water_distance * .075 * 1.325),
          std::exp(-water_distance * .075), normal_fresnel, 1., .5 * (s * s + p * p), 1., normal_fresnel,
          0., .45, 1., 0., 1., 1., 0., 1.};
      for (uint32_t i = 0; i < std::size(water_expected); ++i)
        if (!std::isfinite(values[44 + i]) || std::abs(values[44 + i] - water_expected[i]) > 2.e-6)
          throw std::runtime_error("Water extinction, Fresnel, caustic focusing or dispersion regression");
      if (!(values[60] > .999f && values[60] >= values[61] && values[61] > values[62]
            && values[62] > values[63] && std::abs(values[63] - values[49]) < 2.e-6f))
        throw std::runtime_error("Filtered water exit lost its monotonic critical transition or exact interior Fresnel");
      const float water_three_units = std::exp(-3.f * .23f * (.55f + .45f * .85f));
      if (!(values[64] == 1.f && values[65] == 1.f
            && std::abs(values[66] - water_three_units) < 2.e-6f
            && std::abs(values[67] - water_three_units * water_three_units) < 2.e-6f))
        throw std::runtime_error("Shared murk no longer follows the near-water optical path and slider");
      std::cout << "HDR reconstruction=" << reconstruction << " haze reduction="<<mode[1]<<" quality="<<mode[2]<<" clear distance="<<mode[5]
          << ", independent beam/veil, per-pixel transport, forward additive energy and native receivers passed\n";
    }
    if (argc == 4) {
      const auto code = Read(argv[3]);
      compute_desc.CS = {code.data(), code.size()};
      ComPtr<ID3D12PipelineState> occlusion;
      Check(device->CreateComputePipelineState(&compute_desc, IID_PPV_ARGS(&occlusion)));
      auto depth_desc = texture_desc;
      depth_desc.DepthOrArraySize = 1;
      depth_desc.Format = DXGI_FORMAT_R32_FLOAT;
      ComPtr<ID3D12Resource> local_depth;
      Check(device->CreateCommittedResource(&texture_heap, D3D12_HEAP_FLAG_NONE, &depth_desc, D3D12_RESOURCE_STATE_COPY_DEST, nullptr, IID_PPV_ARGS(&local_depth)));
      D3D12_PLACED_SUBRESOURCE_FOOTPRINT depth_footprint{};
      UINT64 depth_bytes = 0;
      device->GetCopyableFootprints(&depth_desc, 0, 1, 0, &depth_footprint, nullptr, nullptr, &depth_bytes);
      auto depth_upload = Buffer(device.Get(), depth_bytes, D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ);
      auto depth_descriptor = heap->GetCPUDescriptorHandleForHeapStart();
      depth_descriptor.ptr += 7 * device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
      device->CreateShaderResourceView(local_depth.Get(), &depth_view, depth_descriptor);
      frame_data = {};
      frame_data[1][0] = frame_data[2][1] = frame_data[3][2] = 1;
      frame_data[13][0] = frame_data[14][1] = frame_data[15][3] = frame_data[16][2] = 1;
      frame_data[21][0] = frame_data[22][0] = 1;
      frame_data[23] = {8, 8, .125f, .125f};
      Upload(frame.Get(), frame_data.data(), sizeof(frame_data));
      VolumeLightData beams{1, 1, 0, 1, 1, 1, 0, FOG_LIGHT_VALID, 0, 1};
      void* settings_data = nullptr;
      Check(settings->Map(0, nullptr, &settings_data));
      std::memcpy(static_cast<uint8_t*>(settings_data) + FOG_LIGHT_CONSTANT_OFFSET, &beams, sizeof(beams));
      settings->Unmap(0, nullptr);
      std::fill(zero_depths.begin(), zero_depths.end(), char(0));
      Upload(shadow_upload.Get(), zero_depths.data(), zero_depths.size());
      for (unsigned wall = 0; wall < 2; ++wall) {
        std::vector<char> pixels(size_t(depth_bytes), 0);
        const float raw = wall ? .2f : 1.f;  // Five-metre wall or sky.
        for (uint32_t y = 0; y < 8; ++y)
          for (uint32_t x = 0; x < 8; ++x)
            std::memcpy(pixels.data() + depth_footprint.Offset + y * depth_footprint.Footprint.RowPitch + x * 4, &raw, 4);
        Upload(depth_upload.Get(), pixels.data(), pixels.size());
        Check(allocator->Reset());
        Check(cmd->Reset(allocator.Get(), occlusion.Get()));
        D3D12_RESOURCE_BARRIER barrier{};
        barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
        if (wall) {
          barrier.Transition = {local_depth.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE, D3D12_RESOURCE_STATE_COPY_DEST};
          cmd->ResourceBarrier(1, &barrier);
        } else {
          barrier.Transition = {shadow_texture.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE, D3D12_RESOURCE_STATE_COPY_DEST};
          cmd->ResourceBarrier(1, &barrier);
          for (UINT layer = 0; layer < 6; ++layer) {
            D3D12_TEXTURE_COPY_LOCATION source{shadow_upload.Get(), D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
            source.PlacedFootprint = footprints[layer];
            D3D12_TEXTURE_COPY_LOCATION destination{shadow_texture.Get(), D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
            destination.SubresourceIndex = layer;
            cmd->CopyTextureRegion(&destination, 0, 0, 0, &source, nullptr);
          }
          std::swap(barrier.Transition.StateBefore, barrier.Transition.StateAfter);
          cmd->ResourceBarrier(1, &barrier);
        }
        D3D12_TEXTURE_COPY_LOCATION source{depth_upload.Get(), D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
        source.PlacedFootprint = depth_footprint;
        D3D12_TEXTURE_COPY_LOCATION destination{local_depth.Get(), D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
        cmd->CopyTextureRegion(&destination, 0, 0, 0, &source, nullptr);
        barrier.Transition = {local_depth.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_COPY_DEST, D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE};
        cmd->ResourceBarrier(1, &barrier);
        barrier.Transition = {output.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_COPY_SOURCE, D3D12_RESOURCE_STATE_UNORDERED_ACCESS};
        cmd->ResourceBarrier(1, &barrier);
        bind_inputs(output.Get());
        cmd->Dispatch(1, 1, 1);
        std::swap(barrier.Transition.StateBefore, barrier.Transition.StateAfter);
        cmd->ResourceBarrier(1, &barrier);
        cmd->CopyBufferRegion(readback.Get(), 0, output.Get(), 0, 80);
        finish_commands();
        void* mapped = nullptr;
        Check(readback->Map(0, nullptr, &mapped));
        std::array<float, 20> values{};
        std::memcpy(values.data(), mapped, sizeof(values));
        readback->Unmap(0, nullptr);
        const float visible = wall ? 0.f : 1.f;
        const std::array<float, 12> expected{visible, 1, 1, visible, 1, 1, 1, 1, visible, visible, visible, visible};
        for (size_t i = 0; i < expected.size(); ++i)
          if (values[i] != expected[i]) {
            std::cerr << "Occlusion wall=" << wall << " ray=" << i << " got=" << values[i] << " expected=" << expected[i] << '\n';
            throw std::runtime_error("Perspective depth interval, near plane, budget or offscreen fallback regression");
          }
        for (size_t i : {12u, 13u})
          if (std::abs(values[i] - std::exp(-9.998f)) > 1.e-7f)
            throw std::runtime_error("Native local shadow fade restored light through blocked geometry");
        const std::array<float, 4> distances{wall ? 5.f : 1.e30f, wall ? 5.f * std::sqrt(2.f) : 1.e30f, 1.e30f, 1.e30f};
        for (size_t i = 0; i < distances.size(); ++i)
          if (std::abs(values[16 + i] - distances[i]) > distances[i] * 2.e-6f)
            throw std::runtime_error("Opaque local-light integration boundary differs from the visible depth");
        std::cout << "Local occlusion wall=" << wall << ": coaxial/oblique rays, front/behind geometry, near plane, quality budgets, offscreen limits and full atlas/cube visibility passed\n";
      }
    }
    CloseHandle(event);
    if (messages)
      for (UINT64 i = 0; i < messages->GetNumStoredMessages(); ++i) {
        SIZE_T size = 0;
        Check(messages->GetMessage(i, nullptr, &size));
        std::vector<char> storage(size);
        auto* message = reinterpret_cast<D3D12_MESSAGE*>(storage.data());
        Check(messages->GetMessage(i, message, &size));
        if (message->Severity <= D3D12_MESSAGE_SEVERITY_ERROR) throw std::runtime_error(message->pDescription);
      }
    std::cout << "PASS: production PS/CS and Raster/RT local-light parity, group culling, shadows, captured interiors/doorway ramps, vacuum, analytic transport and HDR radiance; debug layer " << (debug ? "enabled" : "unavailable") << '\n';
  } catch (const std::exception& e) {
    std::cerr << e.what() << '\n';
    return 1;
  }
}
