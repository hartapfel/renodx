// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <d3d12.h>
#include <d3d12sdklayers.h>
#include <d3dcompiler.h>
#include <wrl/client.h>
#include <cassert>
#include <cstring>
#include <fstream>
#include <iostream>
#include <source_location>
#include <vector>
using Microsoft::WRL::ComPtr;
inline void Check(HRESULT hr, const std::source_location& location = std::source_location::current()) {
  if (FAILED(hr)) { std::cerr << "D3D12 failure at line " << location.line() << ": " << std::hex << hr << '\n'; std::exit(1); }
}
inline std::vector<char> Read(const char* path) {
  std::ifstream input(path, std::ios::binary); assert(input);
  return {std::istreambuf_iterator<char>(input), {}};
}
struct GpuFixture {
  ComPtr<ID3D12Device> device;
  ComPtr<ID3D12InfoQueue> messages;
  ComPtr<ID3D12CommandQueue> queue;
  ComPtr<ID3D12CommandAllocator> allocator;
  ComPtr<ID3D12GraphicsCommandList> cmd;
  ComPtr<ID3D12Fence> fence;
  HANDLE event = nullptr;
  UINT64 sequence = 0;
  GpuFixture() {
    ComPtr<ID3D12Debug> debug;
    if (SUCCEEDED(D3D12GetDebugInterface(IID_PPV_ARGS(&debug)))) debug->EnableDebugLayer();
    Check(D3D12CreateDevice(nullptr, D3D_FEATURE_LEVEL_12_0, IID_PPV_ARGS(&device)));
    device.As(&messages);
    D3D12_COMMAND_QUEUE_DESC desc{};
    Check(device->CreateCommandQueue(&desc, IID_PPV_ARGS(&queue)));
    Check(device->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&allocator)));
    Check(device->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, allocator.Get(), nullptr, IID_PPV_ARGS(&cmd)));
    Check(device->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&fence)));
    event = CreateEventW(nullptr, FALSE, FALSE, nullptr); assert(event);
  }
  ~GpuFixture() { CloseHandle(event); }
  void Submit() {
    Check(cmd->Close()); ID3D12CommandList* lists[]{cmd.Get()};
    queue->ExecuteCommandLists(1, lists); Check(queue->Signal(fence.Get(), ++sequence));
    Check(fence->SetEventOnCompletion(sequence, event)); assert(WaitForSingleObject(event, 10000) == WAIT_OBJECT_0);
    Check(allocator->Reset()); Check(cmd->Reset(allocator.Get(), nullptr));
  }
  ComPtr<ID3D12Resource> Buffer(UINT64 bytes, D3D12_HEAP_TYPE type) {
    ComPtr<ID3D12Resource> result; D3D12_HEAP_PROPERTIES heap{type};
    D3D12_RESOURCE_DESC desc{D3D12_RESOURCE_DIMENSION_BUFFER, 0, bytes, 1, 1, 1, DXGI_FORMAT_UNKNOWN, {1, 0}, D3D12_TEXTURE_LAYOUT_ROW_MAJOR};
    Check(device->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_NONE, &desc,
        type == D3D12_HEAP_TYPE_UPLOAD ? D3D12_RESOURCE_STATE_GENERIC_READ : D3D12_RESOURCE_STATE_COPY_DEST,
        nullptr, IID_PPV_ARGS(&result))); return result;
  }
  void Upload(ID3D12Resource* resource, const void* data, size_t bytes) {
    void* mapped = nullptr; const D3D12_RANGE read{0, 0};
    Check(resource->Map(0, &read, &mapped)); std::memcpy(mapped, data, bytes);
    const D3D12_RANGE written{0, bytes}; resource->Unmap(0, &written);
  }
  void Transition(ID3D12Resource* resource, D3D12_RESOURCE_STATES before, D3D12_RESOURCE_STATES after) {
    D3D12_RESOURCE_BARRIER barrier{}; barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    barrier.Transition = {resource, D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, before, after}; cmd->ResourceBarrier(1, &barrier);
  }
  ComPtr<ID3D12PipelineState> Graphics(ID3D12RootSignature* root, const std::vector<char>& vertex,
                                     const std::vector<char>& pixel, DXGI_FORMAT format = DXGI_FORMAT_R32G32B32A32_FLOAT,
                                     UINT target_count = 1) {
    assert(target_count <= 8);
    D3D12_GRAPHICS_PIPELINE_STATE_DESC desc{}; desc.pRootSignature = root;
    desc.VS = {vertex.data(), vertex.size()}; desc.PS = {pixel.data(), pixel.size()};
    auto& blend = desc.BlendState.RenderTarget[0]; blend.RenderTargetWriteMask = D3D12_COLOR_WRITE_ENABLE_ALL;
    blend.SrcBlend = blend.SrcBlendAlpha = D3D12_BLEND_ONE; blend.DestBlend = blend.DestBlendAlpha = D3D12_BLEND_ZERO;
    blend.BlendOp = blend.BlendOpAlpha = D3D12_BLEND_OP_ADD; blend.LogicOp = D3D12_LOGIC_OP_NOOP;
    desc.DepthStencilState.DepthFunc = D3D12_COMPARISON_FUNC_ALWAYS;
    desc.DepthStencilState.FrontFace = desc.DepthStencilState.BackFace = {D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_COMPARISON_FUNC_ALWAYS};
    desc.SampleMask = UINT_MAX; desc.RasterizerState.FillMode = D3D12_FILL_MODE_SOLID;
    desc.RasterizerState.CullMode = D3D12_CULL_MODE_NONE; desc.RasterizerState.DepthClipEnable = TRUE;
    desc.PrimitiveTopologyType = D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE; desc.NumRenderTargets = target_count;
    for (UINT i = 0; i < target_count; ++i) desc.RTVFormats[i] = format;
    desc.SampleDesc.Count = 1;
    ComPtr<ID3D12PipelineState> result;
    const HRESULT status=device->CreateGraphicsPipelineState(&desc, IID_PPV_ARGS(&result));
    if(FAILED(status))CheckMessages();
    Check(status); return result;
  }
  void CheckMessages() {
    if (!messages) return;
    for (UINT64 i = 0; i < messages->GetNumStoredMessagesAllowedByRetrievalFilter(); ++i) {
      SIZE_T size = 0; messages->GetMessage(i, nullptr, &size); std::vector<uint8_t> bytes(size);
      auto* message = reinterpret_cast<D3D12_MESSAGE*>(bytes.data()); Check(messages->GetMessage(i, message, &size));
      if (message->Severity <= D3D12_MESSAGE_SEVERITY_ERROR) { std::cerr << message->pDescription << '\n'; std::exit(1); }
    }
  }
};
