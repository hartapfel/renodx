// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <d3d12.h>
#pragma comment(lib, "d3d12.lib")
#include <wrl/client.h>
#include <array>
#include <cstdint>
#include <cstring>
#include <stdexcept>
#include <source_location>
#include <string>
#include <vector>
#include <memory>

namespace hartapfelfx::clouds::gpu {
using Microsoft::WRL::ComPtr;
inline constexpr D3D12_RESOURCE_STATES TextureRead = D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE;
inline constexpr D3D12_RESOURCE_STATES HistoryRead = D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE | D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE | D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER;
inline constexpr uint32_t HistoryBytes = 6400, ClockOffset = 5632, ParametersOffset = 5888, CounterOffset = 6144;
struct UploadStorage {
  ComPtr<ID3D12Resource> object;
  void* mapped = nullptr;
  uint64_t bytes = 0;
  ~UploadStorage() { if (mapped) object->Unmap(0, nullptr); }
};
struct Resource {
  ComPtr<ID3D12Resource> object;
  D3D12_RESOURCE_STATES state = D3D12_RESOURCE_STATE_COMMON;
  std::shared_ptr<UploadStorage> upload;
};
inline void Check(HRESULT result, std::source_location site = std::source_location::current()) {
  if (FAILED(result)) throw std::runtime_error("Cloud D3D12 operation failed at " + std::string(site.file_name())
      + ":" + std::to_string(site.line()) + " with HRESULT " + std::to_string(result));
}
inline Resource Create(ID3D12Device* device, const D3D12_RESOURCE_DESC& desc, D3D12_RESOURCE_STATES state,
                       D3D12_HEAP_TYPE heap_type = D3D12_HEAP_TYPE_DEFAULT) {
  Resource result;
  D3D12_HEAP_PROPERTIES heap{};
  heap.Type = heap_type;
  Check(device->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_NONE, &desc, state, nullptr, IID_PPV_ARGS(&result.object)));
  result.state = state;
  return result;
}
inline Resource Buffer(ID3D12Device* device, uint64_t size, D3D12_RESOURCE_STATES state,
                       D3D12_HEAP_TYPE heap_type = D3D12_HEAP_TYPE_DEFAULT) {
  D3D12_RESOURCE_DESC desc{};
  desc.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
  desc.Width = size;
  desc.Height = desc.DepthOrArraySize = desc.MipLevels = desc.SampleDesc.Count = 1;
  desc.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
  if (heap_type == D3D12_HEAP_TYPE_DEFAULT) desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS;
  return Create(device, desc, state, heap_type);
}
inline Resource Image(ID3D12Device* device, uint32_t width, uint32_t height, DXGI_FORMAT format,
                      uint16_t depth = 1, uint16_t mips = 1, bool volume = false) {
  D3D12_RESOURCE_DESC desc{};
  desc.Dimension = volume ? D3D12_RESOURCE_DIMENSION_TEXTURE3D : D3D12_RESOURCE_DIMENSION_TEXTURE2D;
  desc.Width = width;
  desc.Height = height;
  desc.DepthOrArraySize = depth;
  desc.MipLevels = mips;
  desc.Format = format;
  desc.SampleDesc.Count = 1;
  desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS;
  return Create(device, desc, TextureRead);
}
inline Resource Upload(ID3D12Device* device, const void* data, uint64_t bytes) {
  auto result = Buffer(device, bytes, D3D12_RESOURCE_STATE_GENERIC_READ, D3D12_HEAP_TYPE_UPLOAD);
  void* mapped = nullptr;
  const D3D12_RANGE empty{0, 0};
  Check(result.object->Map(0, &empty, &mapped));
  std::memcpy(mapped, data, size_t(bytes));
  result.object->Unmap(0, nullptr);
  return result;
}
// Recording copies hold each immutable page until their GPU fences retire.
// The owner serializes this pool; mapping and resource creation happen only
// when the maximum number of simultaneously referenced pages grows.
class UploadPool {
 public:
  Resource Upload(ID3D12Device* device, const void* data, uint64_t bytes) {
    for (auto& page : pages_) {
      if (page.upload.use_count() == 1 && page.upload->bytes >= bytes) {
        std::memcpy(page.upload->mapped, data, size_t(bytes));
        return page;
      }
    }
    auto page = Buffer(device, (bytes + 255u) & ~uint64_t(255),
                       D3D12_RESOURCE_STATE_GENERIC_READ, D3D12_HEAP_TYPE_UPLOAD);
    page.upload = std::make_shared<UploadStorage>();
    page.upload->object = page.object;
    page.upload->bytes = (bytes + 255u) & ~uint64_t(255);
    const D3D12_RANGE empty{0, 0};
    Check(page.object->Map(0, &empty, &page.upload->mapped));
    std::memcpy(page.upload->mapped, data, size_t(bytes));
    pages_.push_back(page);
    return page;
  }
  size_t Size() const { return pages_.size(); }
 private:
  std::vector<Resource> pages_;
};
inline void Transition(ID3D12GraphicsCommandList* cmd, Resource* resource, D3D12_RESOURCE_STATES state) {
  if (resource->state == state) return;
  D3D12_RESOURCE_BARRIER barrier{};
  barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
  barrier.Transition = {resource->object.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, resource->state, state};
  cmd->ResourceBarrier(1, &barrier);
  resource->state = state;
}
inline void Copy(ID3D12GraphicsCommandList* cmd, Resource* destination, Resource* source) {
  const auto input_state = source->state, output_state = destination->state;
  Transition(cmd, source, D3D12_RESOURCE_STATE_COPY_SOURCE);
  Transition(cmd, destination, D3D12_RESOURCE_STATE_COPY_DEST);
  cmd->CopyResource(destination->object.Get(), source->object.Get());
  Transition(cmd, source, input_state);
  Transition(cmd, destination, output_state);
}
struct Bank {
  ComPtr<ID3D12DescriptorHeap> heap;
  uint32_t increment = 0;
  explicit Bank(ID3D12Device* device) {
    D3D12_DESCRIPTOR_HEAP_DESC desc{D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV, 20, D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE, 0};
    Check(device->CreateDescriptorHeap(&desc, IID_PPV_ARGS(&heap)));
    increment = device->GetDescriptorHandleIncrementSize(desc.Type);
    D3D12_SHADER_RESOURCE_VIEW_DESC srv{};
    srv.Format = DXGI_FORMAT_R32_FLOAT;
    srv.Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
    srv.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2D;
    srv.Texture2D.MipLevels = 1;
    for (uint32_t index = 0; index < 16; ++index) device->CreateShaderResourceView(nullptr, &srv, Cpu(index));
    D3D12_UNORDERED_ACCESS_VIEW_DESC uav{};
    uav.Format = DXGI_FORMAT_R32_FLOAT;
    uav.ViewDimension = D3D12_UAV_DIMENSION_TEXTURE2D;
    for (uint32_t index = 16; index < 20; ++index) device->CreateUnorderedAccessView(nullptr, nullptr, &uav, Cpu(index));
  }
  D3D12_CPU_DESCRIPTOR_HANDLE Cpu(uint32_t index) const {
    auto address = heap->GetCPUDescriptorHandleForHeapStart();
    address.ptr += uint64_t(index) * increment;
    return address;
  }
  D3D12_GPU_DESCRIPTOR_HANDLE Gpu(uint32_t index = 0) const {
    auto address = heap->GetGPUDescriptorHandleForHeapStart();
    address.ptr += uint64_t(index) * increment;
    return address;
  }
};
inline void Srv(ID3D12Device* device, const Bank& bank, uint32_t index, ID3D12Resource* resource,
                 D3D12_SRV_DIMENSION dimension, uint32_t first_mip = 0, uint32_t mip_count = UINT_MAX) {
  const auto image = resource->GetDesc();
  D3D12_SHADER_RESOURCE_VIEW_DESC desc{};
  desc.Format = image.Format;
  desc.Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
  desc.ViewDimension = dimension;
  if (dimension == D3D12_SRV_DIMENSION_TEXTURE3D) desc.Texture3D = {first_mip, mip_count, 0};
  if (dimension == D3D12_SRV_DIMENSION_TEXTURE2D) desc.Texture2D = {first_mip, mip_count, 0, 0};
  if (dimension == D3D12_SRV_DIMENSION_TEXTURE2DARRAY) desc.Texture2DArray = {first_mip, mip_count, 0, image.DepthOrArraySize, 0, 0};
  if (dimension == D3D12_SRV_DIMENSION_BUFFER) {
    desc.Format = DXGI_FORMAT_R32_TYPELESS;
    desc.Buffer.NumElements = uint32_t(image.Width / 4);
    desc.Buffer.Flags = D3D12_BUFFER_SRV_FLAG_RAW;
  }
  device->CreateShaderResourceView(resource, &desc, bank.Cpu(index));
}
inline void Uav(ID3D12Device* device, const Bank& bank, uint32_t index, ID3D12Resource* resource,
                 uint32_t mip = 0, bool array = false, uint32_t stride = 0) {
  const auto image = resource->GetDesc();
  D3D12_UNORDERED_ACCESS_VIEW_DESC desc{};
  desc.Format = image.Format;
  desc.ViewDimension = D3D12_UAV_DIMENSION_TEXTURE2D;
  desc.Texture2D.MipSlice = mip;
  if (image.Dimension == D3D12_RESOURCE_DIMENSION_TEXTURE3D) {
    desc.ViewDimension = D3D12_UAV_DIMENSION_TEXTURE3D;
    desc.Texture3D = {mip, 0, uint32_t(image.DepthOrArraySize >> mip)};
  } else if (array) {
    desc.ViewDimension = D3D12_UAV_DIMENSION_TEXTURE2DARRAY;
    desc.Texture2DArray = {mip, 0, image.DepthOrArraySize, 0};
  } else if (image.Dimension == D3D12_RESOURCE_DIMENSION_BUFFER) {
    desc.ViewDimension = D3D12_UAV_DIMENSION_BUFFER;
    desc.Format = stride ? DXGI_FORMAT_UNKNOWN : DXGI_FORMAT_R32_TYPELESS;
    desc.Buffer.NumElements = uint32_t(image.Width / (stride ? stride : 4));
    desc.Buffer.StructureByteStride = stride;
    desc.Buffer.Flags = stride ? D3D12_BUFFER_UAV_FLAG_NONE : D3D12_BUFFER_UAV_FLAG_RAW;
  }
  device->CreateUnorderedAccessView(resource, nullptr, &desc, bank.Cpu(16 + index));
}
inline ComPtr<ID3D12RootSignature> Root(ID3D12Device* device) {
  std::array<D3D12_ROOT_PARAMETER, 12> parameters{};
  for (uint32_t index = 0; index < 7; ++index) {
    parameters[index].ParameterType = D3D12_ROOT_PARAMETER_TYPE_CBV;
    parameters[index].Descriptor = {index, 0};
  }
  D3D12_DESCRIPTOR_RANGE ranges[2] = {{D3D12_DESCRIPTOR_RANGE_TYPE_SRV, 16, 0, 0, 0}, {D3D12_DESCRIPTOR_RANGE_TYPE_UAV, 4, 0, 0, 0}};
  for (uint32_t index = 0; index < 2; ++index) {
    parameters[7 + index].ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;
    parameters[7 + index].DescriptorTable = {1, &ranges[index]};
  }
  parameters[9].ParameterType = D3D12_ROOT_PARAMETER_TYPE_CBV;
  parameters[9].Descriptor = {0, 70};
  parameters[10].ParameterType = D3D12_ROOT_PARAMETER_TYPE_SRV;
  parameters[10].Descriptor = {0, 71};
  parameters[11].ParameterType = D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS;
  parameters[11].Constants = {0, 73, 1};
  std::array<D3D12_STATIC_SAMPLER_DESC, 2> samplers{};
  for (uint32_t index = 0; index < samplers.size(); ++index) {
    auto& sampler = samplers[index];
    sampler.ShaderRegister = index;
    sampler.Filter = D3D12_FILTER_MIN_MAG_MIP_LINEAR;
    sampler.AddressU = sampler.AddressV = sampler.AddressW = index ? D3D12_TEXTURE_ADDRESS_MODE_CLAMP : D3D12_TEXTURE_ADDRESS_MODE_WRAP;
    sampler.MaxLOD = D3D12_FLOAT32_MAX;
    sampler.ComparisonFunc = D3D12_COMPARISON_FUNC_ALWAYS;
  }
  D3D12_ROOT_SIGNATURE_DESC desc{uint32_t(parameters.size()), parameters.data(), uint32_t(samplers.size()), samplers.data(), D3D12_ROOT_SIGNATURE_FLAG_NONE};
  ComPtr<ID3DBlob> blob, error;
  Check(D3D12SerializeRootSignature(&desc, D3D_ROOT_SIGNATURE_VERSION_1, &blob, &error));
  ComPtr<ID3D12RootSignature> root;
  Check(device->CreateRootSignature(0, blob->GetBufferPointer(), blob->GetBufferSize(), IID_PPV_ARGS(&root)));
  return root;
}
inline ComPtr<ID3D12PipelineState> Graphics(ID3D12Device* device, ID3D12RootSignature* root,
                                           D3D12_SHADER_BYTECODE vertex, D3D12_SHADER_BYTECODE pixel, DXGI_FORMAT target = DXGI_FORMAT_UNKNOWN) {
  D3D12_GRAPHICS_PIPELINE_STATE_DESC desc{};
  desc.pRootSignature = root;
  desc.VS = vertex;
  desc.PS = pixel;
  desc.RasterizerState.FillMode = D3D12_FILL_MODE_SOLID;
  desc.RasterizerState.CullMode = D3D12_CULL_MODE_NONE;
  desc.RasterizerState.DepthClipEnable = TRUE;
  desc.SampleMask = UINT_MAX;
  desc.SampleDesc.Count = 1;
  desc.PrimitiveTopologyType = D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE;
  for (auto& blend : desc.BlendState.RenderTarget) {
    blend.SrcBlend = blend.SrcBlendAlpha = D3D12_BLEND_ONE;
    blend.DestBlend = blend.DestBlendAlpha = D3D12_BLEND_ZERO;
    blend.BlendOp = blend.BlendOpAlpha = D3D12_BLEND_OP_ADD;
    blend.LogicOp = D3D12_LOGIC_OP_NOOP;
  }
  desc.DepthStencilState.DepthFunc = D3D12_COMPARISON_FUNC_ALWAYS;
  desc.DepthStencilState.FrontFace = {D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_COMPARISON_FUNC_ALWAYS};
  desc.DepthStencilState.BackFace = desc.DepthStencilState.FrontFace;
  if (target != DXGI_FORMAT_UNKNOWN) {
    desc.NumRenderTargets = 1;
    desc.RTVFormats[0] = target;
    auto& blend = desc.BlendState.RenderTarget[0];
    blend.BlendEnable = TRUE;
    blend.SrcBlend = D3D12_BLEND_ONE;
    blend.DestBlend = D3D12_BLEND_INV_SRC_ALPHA;
    blend.BlendOp = blend.BlendOpAlpha = D3D12_BLEND_OP_ADD;
    blend.SrcBlendAlpha = D3D12_BLEND_ZERO;
    blend.DestBlendAlpha = D3D12_BLEND_ONE;
    blend.RenderTargetWriteMask = D3D12_COLOR_WRITE_ENABLE_RED | D3D12_COLOR_WRITE_ENABLE_GREEN | D3D12_COLOR_WRITE_ENABLE_BLUE;
  }
  ComPtr<ID3D12PipelineState> pipeline;
  Check(device->CreateGraphicsPipelineState(&desc, IID_PPV_ARGS(&pipeline)));
  return pipeline;
}
inline ComPtr<ID3D12PipelineState> Compute(ID3D12Device* device, ID3D12RootSignature* root, D3D12_SHADER_BYTECODE shader) {
  D3D12_COMPUTE_PIPELINE_STATE_DESC desc{};
  desc.pRootSignature = root;
  desc.CS = shader;
  ComPtr<ID3D12PipelineState> pipeline;
  Check(device->CreateComputePipelineState(&desc, IID_PPV_ARGS(&pipeline)));
  return pipeline;
}
}  // namespace hartapfelfx::clouds::gpu
