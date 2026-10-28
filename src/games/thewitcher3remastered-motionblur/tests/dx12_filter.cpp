/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// Hardware GPU timestamps for the actual shipping DXIL, with half-resolution
// FP16 native motion/depth and a full-resolution FP16 HDR scene and output.
// Run from the repository root after building the Release compute embed.
#define NOMINMAX
#include <d3d12.h>
#include <dxgi1_6.h>
#include <DirectXPackedVector.h>
#include <wrl/client.h>
#include <algorithm>
#include <array>
#include <bit>
#include <cmath>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iterator>
#include <stdexcept>
#include <string>
#include <vector>
#include "../motion_plan.hpp"
using Microsoft::WRL::ComPtr;
using namespace DirectX::PackedVector;
void Check(HRESULT hr) { if (FAILED(hr)) throw std::runtime_error("D3D12 failure: " + std::to_string(unsigned(hr))); }
int main(int argc, char** argv) { try {
  constexpr unsigned W=3840,H=2160,MW=W/2,MH=H/2;
  const float motion_scale=1.f, angle=.025f;
  const bool rotation=true;
  witcher::motion::Settings settings{};
  settings.interval=1.f/60.f;settings.strength=1.f;settings.mode=1;
  settings.output_width=W;settings.output_height=H;settings.motion_width=MW;settings.motion_height=MH;
  const witcher::motion::Plan plan(settings);
  ComPtr<ID3D12Device> dev; Check(D3D12CreateDevice(nullptr, D3D_FEATURE_LEVEL_12_0, IID_PPV_ARGS(&dev)));
  ComPtr<IDXGIFactory4> factory; Check(CreateDXGIFactory2(0, IID_PPV_ARGS(&factory)));
  ComPtr<IDXGIAdapter1> adapter; Check(factory->EnumAdapterByLuid(dev->GetAdapterLuid(), IID_PPV_ARGS(&adapter)));
  DXGI_ADAPTER_DESC1 adapter_desc; Check(adapter->GetDesc1(&adapter_desc));
  std::wcout << L"GPU: " << adapter_desc.Description << L"\n";
  if (adapter_desc.Flags & DXGI_ADAPTER_FLAG_SOFTWARE) throw std::runtime_error("Hardware adapter required");
  ComPtr<ID3D12CommandQueue> queue; D3D12_COMMAND_QUEUE_DESC qd{}; Check(dev->CreateCommandQueue(&qd, IID_PPV_ARGS(&queue)));
  ComPtr<ID3D12CommandAllocator> allocator; Check(dev->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&allocator)));
  ComPtr<ID3D12GraphicsCommandList> cmd; Check(dev->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, allocator.Get(), nullptr, IID_PPV_ARGS(&cmd)));
  ComPtr<ID3D12Fence> fence; Check(dev->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&fence)));
  HANDLE event = CreateEvent(nullptr, FALSE, FALSE, nullptr); UINT64 serial = 0, frequency = 0; Check(queue->GetTimestampFrequency(&frequency));
  const auto submit = [&] {
    Check(cmd->Close()); ID3D12CommandList* lists[] = {cmd.Get()}; queue->ExecuteCommandLists(1, lists);
    Check(queue->Signal(fence.Get(), ++serial)); Check(fence->SetEventOnCompletion(serial, event));
    WaitForSingleObject(event, INFINITE); Check(allocator->Reset()); Check(cmd->Reset(allocator.Get(), nullptr));
  };
  const auto buffer = [&](UINT64 size, D3D12_HEAP_TYPE heap, D3D12_RESOURCE_STATES state, D3D12_RESOURCE_FLAGS flags) {
    D3D12_HEAP_PROPERTIES hp{}; hp.Type = heap;
    D3D12_RESOURCE_DESC rd{}; rd.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER; rd.Width = size; rd.Height = 1;
    rd.DepthOrArraySize = 1; rd.MipLevels = 1; rd.SampleDesc.Count = 1; rd.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR; rd.Flags = flags;
    ComPtr<ID3D12Resource> result; Check(dev->CreateCommittedResource(&hp, D3D12_HEAP_FLAG_NONE, &rd, state, nullptr, IID_PPV_ARGS(&result))); return result;
  };
  const auto transition = [&](ID3D12Resource* resource, D3D12_RESOURCE_STATES before, D3D12_RESOURCE_STATES after) {
    D3D12_RESOURCE_BARRIER barrier{}; barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    barrier.Transition = {resource, D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, before, after}; cmd->ResourceBarrier(1, &barrier);
  };
  const auto uav_barrier = [&] { D3D12_RESOURCE_BARRIER barrier{}; barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_UAV; cmd->ResourceBarrier(1, &barrier); };
  ComPtr<ID3D12Resource> textures[3], uploads[2];
  for (unsigned i = 0; i < 3; ++i) {
    D3D12_HEAP_PROPERTIES hp{}; hp.Type = D3D12_HEAP_TYPE_DEFAULT;
    D3D12_RESOURCE_DESC rd{}; rd.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D; rd.Width = i == 1 ? MW : W; rd.Height = i == 1 ? MH : H;
    rd.DepthOrArraySize = 1; rd.MipLevels = 1; rd.Format = DXGI_FORMAT_R16G16B16A16_FLOAT; rd.SampleDesc.Count = 1;
    rd.Flags = i == 2 ? D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS : D3D12_RESOURCE_FLAG_NONE;
    Check(dev->CreateCommittedResource(&hp, D3D12_HEAP_FLAG_NONE, &rd, i == 2 ? D3D12_RESOURCE_STATE_UNORDERED_ACCESS : D3D12_RESOURCE_STATE_COPY_DEST, nullptr, IID_PPV_ARGS(&textures[i])));
    if (i == 2) continue;
    D3D12_PLACED_SUBRESOURCE_FOOTPRINT footprint; UINT64 size; dev->GetCopyableFootprints(&rd, 0, 1, 0, &footprint, nullptr, nullptr, &size);
    uploads[i] = buffer(size, D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, D3D12_RESOURCE_FLAG_NONE);
    unsigned char* mapped; Check(uploads[i]->Map(0, nullptr, reinterpret_cast<void**>(&mapped)));
    for (unsigned y = 0; y < rd.Height; ++y) for (unsigned x = 0; x < rd.Width; ++x) {
      std::array<float, 4> pixel;
      if (i == 0) pixel = {float((x * 7 + y * 13) % 67) / 64.f, float((x / 8 + y / 8) % 2), float((x / 64) % 4) / 3.f, 1.f};
      else {
        const unsigned depth = std::bit_cast<unsigned>(.1f + float(x % 100) * .001f);
        pixel = {XMConvertHalfToFloat(XMConvertFloatToHalf(.025f * motion_scale)), XMConvertHalfToFloat(XMConvertFloatToHalf(.003f * motion_scale)), 0, 0};
        if (rotation) {
          float u = (x + .5f) / MW, v = (y + .5f) / MH;
          float px = 2.f * u - 1.f, py = 1.f - 2.f * v;
          float w = -std::sin(angle) * px + std::cos(angle);
          pixel[0] = -(u - .5f - (std::cos(angle) * px + std::sin(angle)) * .5f / w);
          pixel[1] = -(v - .5f + py * .5f / w);
          // A foreground object has a different trajectory, forcing the full
          // silhouette filter around it rather than timing only an ideal pan.
          if (x > MW * .45f && x < MW * .55f && y > MH * .4f && y < MH * .7f) pixel[0] += .035f;
        }
        for (unsigned c = 0; c < 2; ++c) { const unsigned chunk = (depth >> (15 * c)) & 0x7fff; pixel[c + 2] = XMConvertHalfToFloat(((chunk & 0x3fff) + 0x400) | ((chunk & 0x4000) << 1)); }
      }
      auto* destination = reinterpret_cast<uint16_t*>(mapped + footprint.Offset + y * footprint.Footprint.RowPitch) + x * 4;
      for (unsigned c = 0; c < 4; ++c) destination[c] = XMConvertFloatToHalf(pixel[c]);
    }
    uploads[i]->Unmap(0, nullptr);
    D3D12_TEXTURE_COPY_LOCATION source{}; source.pResource = uploads[i].Get(); source.Type = D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT; source.PlacedFootprint = footprint;
    D3D12_TEXTURE_COPY_LOCATION destination{}; destination.pResource = textures[i].Get(); destination.Type = D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX;
    cmd->CopyTextureRegion(&destination, 0, 0, 0, &source, nullptr);
    transition(textures[i].Get(), D3D12_RESOURCE_STATE_COPY_DEST, D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE);
  }
  std::vector<std::array<float, 4>> initial(plan.bytes/16);
  initial[0] = {1, 0, 1, 0}; initial[1] = {MW, MH, 1.f / MW, 1.f / MH};
  initial[2] = {1, 0, 0, 0}; initial[3] = {0, 1, 0, 0}; initial[4] = {0, 0, 1, 0}; initial[5] = {.05f * motion_scale, -.006f * motion_scale, 0, 1};
  if (rotation) {
    initial[2] = {std::cos(angle), 0, 0, -std::sin(angle)};
    initial[5] = {std::sin(angle), 0, 0, std::cos(angle)};
  }
  auto scratch = buffer(initial.size() * 16, D3D12_HEAP_TYPE_DEFAULT, D3D12_RESOURCE_STATE_COPY_DEST, D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS);
  auto scratch_upload = buffer(initial.size() * 16, D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, D3D12_RESOURCE_FLAG_NONE);
  void* mapped; Check(scratch_upload->Map(0, nullptr, &mapped)); std::memcpy(mapped, initial.data(), initial.size() * 16); scratch_upload->Unmap(0, nullptr);
  cmd->CopyBufferRegion(scratch.Get(), 0, scratch_upload.Get(), 0, initial.size() * 16);
  transition(scratch.Get(), D3D12_RESOURCE_STATE_COPY_DEST, D3D12_RESOURCE_STATE_UNORDERED_ACCESS); submit();
  D3D12_DESCRIPTOR_RANGE ranges[] = {{D3D12_DESCRIPTOR_RANGE_TYPE_SRV, 3, 0, 0, 0}, {D3D12_DESCRIPTOR_RANGE_TYPE_UAV, 1, 0, 0, 0}};
  D3D12_ROOT_PARAMETER parameters[5]{};
  for (unsigned i = 0; i < 2; ++i) { parameters[i].ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE; parameters[i].DescriptorTable = {1, &ranges[i]}; }
  parameters[2].ParameterType = D3D12_ROOT_PARAMETER_TYPE_UAV; parameters[2].Descriptor = {0, 57};
  parameters[3].ParameterType = D3D12_ROOT_PARAMETER_TYPE_CBV; parameters[3].Descriptor = {0, 57};
  parameters[4].ParameterType=D3D12_ROOT_PARAMETER_TYPE_CBV; parameters[4].Descriptor={0,0};
  D3D12_STATIC_SAMPLER_DESC sampler{}; sampler.Filter = D3D12_FILTER_MIN_MAG_MIP_LINEAR;
  sampler.AddressU = sampler.AddressV = sampler.AddressW = D3D12_TEXTURE_ADDRESS_MODE_CLAMP;
  sampler.MaxLOD = D3D12_FLOAT32_MAX; sampler.RegisterSpace = 57; sampler.ComparisonFunc = D3D12_COMPARISON_FUNC_NEVER;
  D3D12_ROOT_SIGNATURE_DESC root_desc{5, parameters, 1, &sampler, D3D12_ROOT_SIGNATURE_FLAG_NONE};
  ComPtr<ID3DBlob> blob, error; Check(D3D12SerializeRootSignature(&root_desc, D3D_ROOT_SIGNATURE_VERSION_1, &blob, &error));
  ComPtr<ID3D12RootSignature> root; Check(dev->CreateRootSignature(0, blob->GetBufferPointer(), blob->GetBufferSize(), IID_PPV_ARGS(&root)));
  ComPtr<ID3D12DescriptorHeap> heap; D3D12_DESCRIPTOR_HEAP_DESC hd{D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV, 4, D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE, 0};
  Check(dev->CreateDescriptorHeap(&hd, IID_PPV_ARGS(&heap))); const unsigned stride = dev->GetDescriptorHandleIncrementSize(hd.Type);
  for (unsigned i = 0; i < 3; ++i) {
    D3D12_SHADER_RESOURCE_VIEW_DESC desc{}; desc.Format = DXGI_FORMAT_R16G16B16A16_FLOAT; desc.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2D;
    desc.Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING; desc.Texture2D.MipLevels = 1;
    auto handle = heap->GetCPUDescriptorHandleForHeapStart(); handle.ptr += i * stride; dev->CreateShaderResourceView(i ? textures[i - 1].Get() : nullptr, &desc, handle);
  }
  auto output_handle = heap->GetCPUDescriptorHandleForHeapStart(); output_handle.ptr += 3 * stride;
  D3D12_UNORDERED_ACCESS_VIEW_DESC ud{}; ud.Format = DXGI_FORMAT_R16G16B16A16_FLOAT; ud.ViewDimension = D3D12_UAV_DIMENSION_TEXTURE2D;
  dev->CreateUnorderedAccessView(textures[2].Get(), nullptr, &ud, output_handle);
  std::ifstream file("build/thewitcher3remastered-motionblur.include/embed/0xF3B10000.cso",std::ios::binary);
  std::vector<char> shader{std::istreambuf_iterator<char>(file),{}};
  D3D12_COMPUTE_PIPELINE_STATE_DESC pd{};pd.pRootSignature=root.Get();pd.CS={shader.data(),shader.size()};
  ComPtr<ID3D12PipelineState> pipeline;Check(dev->CreateComputePipelineState(&pd,IID_PPV_ARGS(&pipeline)));
  auto constants=buffer(13*256,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ,D3D12_RESOURCE_FLAG_NONE);
  Check(constants->Map(0,nullptr,&mapped));
  for(unsigned stage=0;stage<12;++stage) std::memcpy(static_cast<char*>(mapped)+stage*256,&plan.stages[stage],sizeof(settings));
  float native[64]{};native[20]=W-1.f;native[21]=H-1.f;
  std::memcpy(static_cast<char*>(mapped)+12*256,native,sizeof(native));constants->Unmap(0,nullptr);
  ComPtr<ID3D12QueryHeap> query;D3D12_QUERY_HEAP_DESC qh{D3D12_QUERY_HEAP_TYPE_TIMESTAMP,2,0};Check(dev->CreateQueryHeap(&qh,IID_PPV_ARGS(&query)));
  auto times=buffer(16,D3D12_HEAP_TYPE_READBACK,D3D12_RESOURCE_STATE_COPY_DEST,D3D12_RESOURCE_FLAG_NONE);
  std::vector<double> elapsed;
  for(unsigned run=0;run<24;++run) {
    ID3D12DescriptorHeap* heaps[]={heap.Get()};cmd->SetDescriptorHeaps(1,heaps);cmd->SetComputeRootSignature(root.Get());
    cmd->SetComputeRootDescriptorTable(0,heap->GetGPUDescriptorHandleForHeapStart());
    auto output=heap->GetGPUDescriptorHandleForHeapStart();output.ptr+=3*stride;cmd->SetComputeRootDescriptorTable(1,output);
    cmd->SetComputeRootUnorderedAccessView(2,scratch->GetGPUVirtualAddress());
    cmd->SetComputeRootConstantBufferView(4,constants->GetGPUVirtualAddress()+12*256);
    cmd->SetPipelineState(pipeline.Get());cmd->EndQuery(query.Get(),D3D12_QUERY_TYPE_TIMESTAMP,0);
    for(unsigned stage=0;stage<12;++stage) {
      const auto& record=plan.stages[stage];
      cmd->SetComputeRootConstantBufferView(3,constants->GetGPUVirtualAddress()+stage*256);
      cmd->Dispatch((record.target_width+7)/8,(record.target_height+7)/8,1);uav_barrier();
    }
    cmd->EndQuery(query.Get(),D3D12_QUERY_TYPE_TIMESTAMP,1);cmd->ResolveQueryData(query.Get(),D3D12_QUERY_TYPE_TIMESTAMP,0,2,times.Get(),0);submit();
    UINT64* stamps;Check(times->Map(0,nullptr,reinterpret_cast<void**>(&stamps)));
    if(run>=4) elapsed.push_back(double(stamps[1]-stamps[0])*1000/frequency);times->Unmap(0,nullptr);
  }
  D3D12_PLACED_SUBRESOURCE_FOOTPRINT footprint;UINT64 output_bytes;
  auto rd=textures[2]->GetDesc();dev->GetCopyableFootprints(&rd,0,1,0,&footprint,nullptr,nullptr,&output_bytes);
  auto readback=buffer(output_bytes,D3D12_HEAP_TYPE_READBACK,D3D12_RESOURCE_STATE_COPY_DEST,D3D12_RESOURCE_FLAG_NONE);
  transition(textures[2].Get(),D3D12_RESOURCE_STATE_UNORDERED_ACCESS,D3D12_RESOURCE_STATE_COPY_SOURCE);
  D3D12_TEXTURE_COPY_LOCATION dest{readback.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};dest.PlacedFootprint=footprint;
  D3D12_TEXTURE_COPY_LOCATION source{textures[2].Get(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
  cmd->CopyTextureRegion(&dest,0,0,0,&source,nullptr);submit();
  Check(readback->Map(0,nullptr,&mapped));double sum=0;
  for(unsigned y=0;y<H;++y)for(unsigned x=0;x<W;++x) {
    const auto* pixel=reinterpret_cast<const HALF*>(static_cast<const char*>(mapped)+y*footprint.Footprint.RowPitch)+4*x;
    for(unsigned c=0;c<4;++c) {float v=XMConvertHalfToFloat(pixel[c]);if(!std::isfinite(v))throw std::runtime_error("nonfinite output");sum+=v;}
    if(XMConvertHalfToFloat(pixel[3])!=1.f)throw std::runtime_error("alpha changed");
  }
  readback->Unmap(0,nullptr);if(sum<1)throw std::runtime_error("empty output");
  std::sort(elapsed.begin(),elapsed.end());
  std::cout<<"PASS production SM6 DX12 filter: 24 frames, 4K finite output/alpha; median "<<elapsed[elapsed.size()/2]<<" ms; scratch "<<plan.bytes/1048576.<<" MiB\n";
  Check(cmd->Close());CloseHandle(event);
} catch(const std::exception& e) {std::cerr<<"FAIL: "<<e.what()<<'\n';return 1;}}
