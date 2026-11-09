// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Executes actual addon observers/replacements with split, delayed recordings.
#pragma once
#include <array>
#include <cmath>
#include <cstring>
#include <DirectXPackedVector.h>

ComPtr<ID3D12Resource> RuntimeBuffer(ID3D12Device* device, uint64_t bytes, D3D12_HEAP_TYPE type, D3D12_RESOURCE_STATES state, const void* data = nullptr) {
  D3D12_HEAP_PROPERTIES heap{};
  heap.Type = type;
  D3D12_RESOURCE_DESC desc{};
  desc.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
  desc.Width = bytes;
  desc.Height = desc.DepthOrArraySize = desc.MipLevels = desc.SampleDesc.Count = 1;
  desc.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
  if (state == D3D12_RESOURCE_STATE_UNORDERED_ACCESS) desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS;
  ComPtr<ID3D12Resource> buffer;
  Check(device->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_NONE, &desc, state, nullptr, IID_PPV_ARGS(&buffer)));
  if (data) {
    void* mapped = nullptr;
    D3D12_RANGE empty{0, 0};
    Check(buffer->Map(0, &empty, &mapped));
    std::memcpy(mapped, data, size_t(bytes));
    buffer->Unmap(0, nullptr);
  }
  return buffer;
}
void RuntimeFrames(ID3D12Device* device, ID3D12RootSignature* root, D3D12_GRAPHICS_PIPELINE_STATE_DESC desc,
                   const std::filesystem::path& originals, const std::filesystem::path& probe_path, uint32_t volume_root, uint32_t expected_width) {
  constexpr uint32_t frames = 24;
  std::array<const char*, 5> names = {"0x8BDE805B.ps_6_6.cso", "0x4A7A44D6.ps_6_6.cso", "0x806C62A8.ps_6_6.cso", "0x73E21194.ps_6_6.cso", nullptr};
  std::array<ComPtr<ID3D12PipelineState>, 5> pipelines;
  desc.NumRenderTargets = 1;
  desc.RTVFormats[0] = DXGI_FORMAT_R32G32B32A32_FLOAT;
  for (uint32_t i = 0; i < names.size(); ++i) {
    auto shader = Read(i == 4 ? probe_path : originals / names[i]);
    desc.PS = {shader.data(), shader.size()};
    Check(device->CreateGraphicsPipelineState(&desc, IID_PPV_ARGS(&pipelines[i])));
  }
  auto local_table_root=Root(device,true,0,false,0,false,true);
  std::array<ComPtr<ID3D12PipelineState>,4> local_pipelines;
  for(uint32_t i=0;i<4;++i) {
    auto shader=Read(originals/(i%2?"0x9A6F318E.cs_6_6.cso":"0xE6A77B56.cs_6_6.cso"));
    D3D12_COMPUTE_PIPELINE_STATE_DESC local_desc{};
    local_desc.pRootSignature=i<2?root:local_table_root.Get();
    local_desc.CS={shader.data(),shader.size()};
    Check(device->CreateComputePipelineState(&local_desc,IID_PPV_ARGS(&local_pipelines[i])));
  }
  D3D12_COMMAND_QUEUE_DESC queue_desc{};
  ComPtr<ID3D12CommandQueue> queue;
  Check(device->CreateCommandQueue(&queue_desc, IID_PPV_ARGS(&queue)));
  D3D12_HEAP_PROPERTIES texture_heap{};
  texture_heap.Type = D3D12_HEAP_TYPE_DEFAULT;
  D3D12_RESOURCE_DESC texture_desc{};
  texture_desc.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D;
  texture_desc.Width = 64;
  texture_desc.Height = 36;
  texture_desc.DepthOrArraySize = texture_desc.MipLevels = texture_desc.SampleDesc.Count = 1;
  texture_desc.Format = DXGI_FORMAT_R16G16_FLOAT;
  ComPtr<ID3D12Resource> intervals, depth, photo_depth, shadows, target;
  Check(device->CreateCommittedResource(&texture_heap, D3D12_HEAP_FLAG_NONE, &texture_desc, D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE, nullptr, IID_PPV_ARGS(&intervals)));
  D3D12_PLACED_SUBRESOURCE_FOOTPRINT interval_footprint{};
  uint64_t interval_bytes = 0;
  device->GetCopyableFootprints(&texture_desc, 0, 1, 0, &interval_footprint, nullptr, nullptr, &interval_bytes);
  texture_desc.Format = DXGI_FORMAT_R32G8X24_TYPELESS;
  texture_desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_DEPTH_STENCIL;
  Check(device->CreateCommittedResource(&texture_heap, D3D12_HEAP_FLAG_NONE, &texture_desc, D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE, nullptr, IID_PPV_ARGS(&depth)));
  texture_desc.Width=80;texture_desc.Height=45;
  Check(device->CreateCommittedResource(&texture_heap,D3D12_HEAP_FLAG_NONE,&texture_desc,D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE,nullptr,IID_PPV_ARGS(&photo_depth)));
  texture_desc.Width = texture_desc.Height = 1;
  texture_desc.DepthOrArraySize = 4;
  texture_desc.Format = DXGI_FORMAT_R16_TYPELESS;
  Check(device->CreateCommittedResource(&texture_heap, D3D12_HEAP_FLAG_NONE, &texture_desc, D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE, nullptr, IID_PPV_ARGS(&shadows)));
  texture_desc.DepthOrArraySize = 1;
  texture_desc.Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
  texture_desc.Width = 2;
  texture_desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET;
  Check(device->CreateCommittedResource(&texture_heap, D3D12_HEAP_FLAG_NONE, &texture_desc, D3D12_RESOURCE_STATE_RENDER_TARGET, nullptr, IID_PPV_ARGS(&target)));
  D3D12_PLACED_SUBRESOURCE_FOOTPRINT result_footprint{};
  uint64_t result_bytes = 0;
  device->GetCopyableFootprints(&texture_desc, 0, 1, 0, &result_footprint, nullptr, nullptr, &result_bytes);
  D3D12_DESCRIPTOR_HEAP_DESC heap_desc{D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV, 288, D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE, 0};
  ComPtr<ID3D12DescriptorHeap> heap, rtv_heap;
  Check(device->CreateDescriptorHeap(&heap_desc, IID_PPV_ARGS(&heap)));
  heap_desc = {D3D12_DESCRIPTOR_HEAP_TYPE_RTV, 1, D3D12_DESCRIPTOR_HEAP_FLAG_NONE, 0};
  Check(device->CreateDescriptorHeap(&heap_desc, IID_PPV_ARGS(&rtv_heap)));
  device->CreateRenderTargetView(target.Get(), nullptr, rtv_heap->GetCPUDescriptorHandleForHeapStart());
  D3D12_SHADER_RESOURCE_VIEW_DESC srv{};
  srv.Format = DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS;
  srv.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2D;
  srv.Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
  srv.Texture2D.MipLevels = 1;
  device->CreateShaderResourceView(depth.Get(), &srv, heap->GetCPUDescriptorHandleForHeapStart());
  auto descriptor = heap->GetCPUDescriptorHandleForHeapStart();
  descriptor.ptr += 8 * device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
  srv.Format = DXGI_FORMAT_R16_UNORM;
  srv.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2DARRAY;
  srv.Texture2DArray = {0, 1, 0, 4, 0};
  device->CreateShaderResourceView(shadows.Get(), &srv, descriptor);
  descriptor = heap->GetCPUDescriptorHandleForHeapStart();
  descriptor.ptr += 24 * device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
  srv.Format = DXGI_FORMAT_R16G16_FLOAT;
  srv.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2D;
  srv.Texture2D = {0, 1, 0, 0};
  device->CreateShaderResourceView(intervals.Get(), &srv, descriptor);
  std::array<std::array<float, 4>, 3600> light{};
  light[0] = {0, 0, 1, 1};
  light[1] = {1, 1, 1, 1};
  light[33][2] = 128;
  const uint32_t light_count=1;
  std::memcpy(&light[67][1],&light_count,4);
  light[68]={0,0,20,100};
  light[71]={10,20,40,0};
  light[73]={.01f,1,0,1};
  auto local_buffer=RuntimeBuffer(device,160,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ,light[68].data());
  srv={};
  srv.Format=DXGI_FORMAT_UNKNOWN;
  srv.ViewDimension=D3D12_SRV_DIMENSION_BUFFER;
  srv.Shader4ComponentMapping=D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
  srv.Buffer.NumElements=1;srv.Buffer.StructureByteStride=160;
  descriptor=heap->GetCPUDescriptorHandleForHeapStart();
  descriptor.ptr+=18*device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
  device->CreateShaderResourceView(local_buffer.Get(),&srv,descriptor);
  auto light_buffer = RuntimeBuffer(device, sizeof(light), D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, light.data());
  auto frame_buffer = RuntimeBuffer(device, 5632, D3D12_HEAP_TYPE_DEFAULT, D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER);
  for(uint32_t slot=1;slot<=15;++slot) {
    D3D12_CONSTANT_BUFFER_VIEW_DESC cbv{(slot==13?light_buffer.Get():frame_buffer.Get())->GetGPUVirtualAddress(),slot==13?uint32_t(sizeof(light)):5632u};
    descriptor=heap->GetCPUDescriptorHandleForHeapStart();
    descriptor.ptr+=(127+slot)*device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
    device->CreateConstantBufferView(&cbv,descriptor);
  }
  // Duplicate the native SRV table; photo mode changes the scene depth size.
  auto photo_cpu=heap->GetCPUDescriptorHandleForHeapStart();
  photo_cpu.ptr+=160*device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
  device->CopyDescriptorsSimple(128,photo_cpu,heap->GetCPUDescriptorHandleForHeapStart(),D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
  srv={};srv.Format=DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS;srv.ViewDimension=D3D12_SRV_DIMENSION_TEXTURE2D;
  srv.Shader4ComponentMapping=D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;srv.Texture2D.MipLevels=1;
  device->CreateShaderResourceView(photo_depth.Get(),&srv,photo_cpu);
  const std::array<uint32_t, 256> zeros{};
  auto zero_buffer = RuntimeBuffer(device, sizeof(zeros), D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, zeros.data());
  std::array<std::array<ComPtr<ID3D12CommandAllocator>, frames>, 4> allocators;
  std::array<std::array<ComPtr<ID3D12GraphicsCommandList>, frames>, 4> commands;
  std::array<ComPtr<ID3D12Resource>, frames> frame_uploads, receiver_uploads, interval_uploads, results;
  for (uint32_t frame = 0; frame < frames; ++frame) {
    std::array<std::array<float, 4>, 352> values{};
    values[0] = {std::min(frame, 16u) * .003f, 0, 0, 3};
    values[1] = values[13] = values[17] = {1, 0, 0, 0};
    values[2] = values[14] = values[18] = {0, 1, 0, 0};
    values[3] = {0, 0, 1, 0};
    values[4] = {-values[0][0], 0, 0, 1};
    values[15] = {0, 0, 1, 1};
    values[20] = {values[0][0], 0, 1, 1};
    values[22] = {-1, 1, .2f, 1000};
    values[23] = frame==1?std::array<float,4>{80,45,1.f/80,1.f/45}:std::array<float,4>{64,36,1.f/64,1.f/36};
    values[38] = {0, 0, 1, 0};
    values[42] = {1, 0, 1000, 1};
    values[43] = {.002f, 0, 0, 0};
    values[48] = {1, 0, 1, 0};
    values[286][0] = float(std::min(frame, 16u) + 1);
    frame_uploads[frame] = RuntimeBuffer(device, sizeof(values), D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, values.data());
    // Simulate a same-view weather update between sun injection and composite.
    // Weather values describe the medium, not the identity of its GPU frame.
    values[43][0] = std::nextafter(values[43][0], 1.f);
    receiver_uploads[frame] = RuntimeBuffer(device, sizeof(values), D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, values.data());
    std::vector<uint8_t> pixels(size_t(interval_bytes), 0);
    for (uint32_t y = 0; y < 18; ++y)
      for (uint32_t x = 0; x < 32; ++x) {
        using DirectX::PackedVector::XMConvertFloatToHalf;
        const uint16_t boundaries[2] = {XMConvertFloatToHalf(frame % 2 ? 120000.f / 128 : 0.f), XMConvertFloatToHalf(frame % 2 ? 2000.f / 128 : 0.f)};
        std::memcpy(pixels.data() + interval_footprint.Offset + y * interval_footprint.Footprint.RowPitch + x * 4, boundaries, 4);
      }
    interval_uploads[frame] = RuntimeBuffer(device, interval_bytes, D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, pixels.data());
    results[frame] = RuntimeBuffer(device, result_bytes, D3D12_HEAP_TYPE_READBACK, D3D12_RESOURCE_STATE_COPY_DEST);
  }
  // Record all captures first, then sun/local passes, then all composites. Submit
  // them in native frame order. CPU-latest snapshots are deliberately incorrect.
  for (uint32_t stage = 0; stage < 4; ++stage)
    for (uint32_t frame = 0; frame < frames; ++frame) {
      Check(device->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&allocators[stage][frame])));
      Check(device->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, allocators[stage][frame].Get(), nullptr, IID_PPV_ARGS(&commands[stage][frame])));
      auto* cmd = commands[stage][frame].Get();
      if (stage == 0) {
        D3D12_RESOURCE_BARRIER barrier{};
        barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
        barrier.Transition = {frame_buffer.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER, D3D12_RESOURCE_STATE_COPY_DEST};
        cmd->ResourceBarrier(1, &barrier);
        cmd->CopyBufferRegion(frame_buffer.Get(), 0, frame_uploads[frame].Get(), 0, 5632);
        std::swap(barrier.Transition.StateBefore, barrier.Transition.StateAfter);
        cmd->ResourceBarrier(1, &barrier);
        barrier.Transition = {intervals.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE, D3D12_RESOURCE_STATE_COPY_DEST};
        cmd->ResourceBarrier(1, &barrier);
        D3D12_TEXTURE_COPY_LOCATION source{interval_uploads[frame].Get(), D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
        source.PlacedFootprint = interval_footprint;
        D3D12_TEXTURE_COPY_LOCATION destination{intervals.Get(), D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
        cmd->CopyTextureRegion(&destination, 0, 0, 0, &source, nullptr);
        std::swap(barrier.Transition.StateBefore, barrier.Transition.StateAfter);
        cmd->ResourceBarrier(1, &barrier);
      }
      if (stage == 3) {
        D3D12_RESOURCE_BARRIER barrier{};
        barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
        barrier.Transition = {frame_buffer.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER, D3D12_RESOURCE_STATE_COPY_DEST};
        cmd->ResourceBarrier(1, &barrier);
        cmd->CopyBufferRegion(frame_buffer.Get(), 0, receiver_uploads[frame].Get(), 0, 5632);
        std::swap(barrier.Transition.StateBefore, barrier.Transition.StateAfter);
        cmd->ResourceBarrier(1, &barrier);
      }
      auto scene_table=heap->GetGPUDescriptorHandleForHeapStart();
      if(frame==1)scene_table.ptr+=160*device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
      if(stage==2) {
        const uint32_t variant=(frame/2)%4;
        cmd->SetComputeRootSignature(variant<2?root:local_table_root.Get());
        ID3D12DescriptorHeap* heaps[]={heap.Get()};
        cmd->SetDescriptorHeaps(1,heaps);
        if(variant<2) {
          for(uint32_t slot=0;slot<14;++slot)
            cmd->SetComputeRootConstantBufferView(slot,(slot==13?light_buffer.Get():frame_buffer.Get())->GetGPUVirtualAddress());
          cmd->SetComputeRootDescriptorTable(14,scene_table);
        } else {
          cmd->SetComputeRootConstantBufferView(0,frame_buffer->GetGPUVirtualAddress());
          auto table=heap->GetGPUDescriptorHandleForHeapStart();
          table.ptr+=128*device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
          cmd->SetComputeRootDescriptorTable(1,table);
          cmd->SetComputeRootDescriptorTable(2,scene_table);
        }
        cmd->SetPipelineState(local_pipelines[variant].Get());
        // Shadow/photo-mode work can leave an unrelated viewport at this point.
        // Local lights must use the scene volume rather than that graphics state.
        D3D12_VIEWPORT shadow_view{0,0,4096,4096,0,1};
        cmd->RSSetViewports(1,&shadow_view);
        // Zero native work still invokes the real hash-matched addon observer.
        cmd->Dispatch(0,0,0);
        Check(cmd->Close());
        continue;
      }
      cmd->SetGraphicsRootSignature(root);
      ID3D12DescriptorHeap* heaps[] = {heap.Get()};
      cmd->SetDescriptorHeaps(1, heaps);
      for (uint32_t slot = 0; slot < 14; ++slot)
        cmd->SetGraphicsRootConstantBufferView(slot, (slot == 13 ? light_buffer.Get() : frame_buffer.Get())->GetGPUVirtualAddress());
      cmd->SetGraphicsRootDescriptorTable(14, scene_table);
      cmd->SetGraphicsRootShaderResourceView(volume_root, zero_buffer->GetGPUVirtualAddress());
      D3D12_VIEWPORT viewport{0,0,frame==1?80.f:64.f,frame==1?45.f:36.f,0,1};
      D3D12_RECT scissor{0, 0, 64, 36};
      cmd->RSSetViewports(1, &viewport);
      cmd->RSSetScissorRects(1, &scissor);
      auto rtv = rtv_heap->GetCPUDescriptorHandleForHeapStart();
      cmd->OMSetRenderTargets(1, &rtv, FALSE, nullptr);
      cmd->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
      cmd->SetPipelineState(pipelines[stage == 0 ? 0 : stage == 1 ? (frame % 3 ? 2 : 1) : 3].Get());
      cmd->DrawInstanced(0, 1, 0, 0);
      if (stage == 3) {
        cmd->SetPipelineState(pipelines[4].Get());
        cmd->DrawInstanced(3, 1, 0, 0);
        D3D12_RESOURCE_BARRIER barrier{};
        barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
        barrier.Transition = {target.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_RENDER_TARGET, D3D12_RESOURCE_STATE_COPY_SOURCE};
        cmd->ResourceBarrier(1, &barrier);
        D3D12_TEXTURE_COPY_LOCATION destination{results[frame].Get(), D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
        destination.PlacedFootprint = result_footprint;
        D3D12_TEXTURE_COPY_LOCATION source{target.Get(), D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
        cmd->CopyTextureRegion(&destination, 0, 0, 0, &source, nullptr);
        std::swap(barrier.Transition.StateBefore, barrier.Transition.StateAfter);
        cmd->ResourceBarrier(1, &barrier);
      }
      Check(cmd->Close());
    }
  std::vector<ID3D12CommandList*> submission;
  for (uint32_t frame = 0; frame < frames; ++frame)
    for (uint32_t stage = 0; stage < 4; ++stage) submission.push_back(commands[stage][frame].Get());
  queue->ExecuteCommandLists(uint32_t(submission.size()), submission.data());
  ComPtr<ID3D12Fence> fence;
  Check(device->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&fence)));
  Check(queue->Signal(fence.Get(), 1));
  HANDLE event = CreateEvent(nullptr, FALSE, FALSE, nullptr);
  Check(fence->SetEventOnCompletion(1, event));
  const auto wait = WaitForSingleObject(event, 120000);
  CloseHandle(event);
  if (wait != WAIT_OBJECT_0) throw std::runtime_error("Split-frame runtime GPU test timed out");
  for (uint32_t frame = 0; frame < frames; ++frame) {
    void* mapped = nullptr;
    D3D12_RANGE range{0, 32};
    Check(results[frame]->Map(0, &range, &mapped));
    std::array<float, 8> result;
    std::memcpy(result.data(), mapped, sizeof(result));
    results[frame]->Unmap(0, nullptr);
    if(!std::isfinite(result[4]) ||!std::isfinite(result[6]) ||result[7]!=1.f
        ||(frame%2?std::abs(result[6]-result[4])>1.e-5f:result[6]-result[4]<=.0001f)) {
      std::cerr<<"Local fog frame "<<frame<<" RGB="<<result[4]<<","<<result[5]<<","<<result[6]<<" marker="<<result[7]<<"\n";
      throw std::runtime_error("Native Raster/RT local-light observer lost volumetric radiance");
    }
    std::cout << "Runtime frame " << frame << " valid=" << result[0] << " opacity=" << result[1] << " width=" << result[2] << " camera=" << result[3] << std::endl;
    if (result[0] != 1 || result[2] != expected_width || !std::isfinite(result[1]) || std::abs(result[3] - std::min(frame, 16u) * .003f) > .00001f
        || std::abs(result[1] - (frame % 2 ? 0.f : 1.f - std::exp(-.002f * 999.8f))) > .002f)
      throw std::runtime_error("Split/delayed recording mixed frames, lost interior exclusion or fell back to native fog");
  }
  std::cout << "PASS: 24 actual-addon frames, 96 delayed split recordings, native Raster/RT local-light observers, rotating Raster/RT/PT sun consumers and indoor/outdoor exclusion" << std::endl;
}
