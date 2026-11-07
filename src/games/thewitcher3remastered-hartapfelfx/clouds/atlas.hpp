// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "pipeline.hpp"

namespace hartapfelfx::clouds {
// A six-face native sky transaction. The game keeps drawing its atlas cards;
// their clear-sky antecedent is saved per face and used only if every face and
// a matching cloud environment are available at the conversion draw.
class AtlasStorage {
 public:
  AtlasStorage(Assets* assets, DXGI_FORMAT format):assets_(assets),format_(format) {
    D3D12_RESOURCE_DESC description{};
    description.Dimension=D3D12_RESOURCE_DIMENSION_TEXTURE2D;
    description.Width=768;description.Height=512;
    description.DepthOrArraySize=description.MipLevels=description.SampleDesc.Count=1;
    description.Format=format;
    clear_=gpu::Create(assets->Device(),description,gpu::TextureRead);
    metadata_=gpu::Buffer(assets->Device(),512,gpu::TextureRead);
    capture_bank_=std::make_shared<gpu::Bank>(assets->Device());
    gpu::Uav(assets->Device(),*capture_bank_,0,metadata_.object.Get());
  }
  DXGI_FORMAT Format() const {return format_;}
  void CaptureFrame(ID3D12GraphicsCommandList* command,D3D12_GPU_VIRTUAL_ADDRESS frame,uint32_t face,uint32_t revision) {
    gpu::Transition(command,&metadata_,D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    ID3D12DescriptorHeap* heaps[]={capture_bank_->heap.Get()};
    command->SetDescriptorHeaps(1,heaps);
    command->SetComputeRootSignature(assets_->root.Get());
    command->SetComputeRootConstantBufferView(0,frame);
    command->SetComputeRoot32BitConstant(11,(revision<<3u)|face,0);
    command->SetComputeRootDescriptorTable(8,capture_bank_->Gpu(16));
    command->SetPipelineState(assets_->atlas_capture_pipeline.Get());
    command->Dispatch(1,1,1);
    gpu::Transition(command,&metadata_,gpu::TextureRead);
  }
  void CaptureClear(ID3D12GraphicsCommandList* command,ID3D12Resource* native,uint32_t face) {
    D3D12_RESOURCE_BARRIER barrier{};
    barrier.Type=D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    barrier.Transition={native,D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
        D3D12_RESOURCE_STATE_RENDER_TARGET,D3D12_RESOURCE_STATE_COPY_SOURCE};
    command->ResourceBarrier(1,&barrier);
    gpu::Transition(command,&clear_,D3D12_RESOURCE_STATE_COPY_DEST);
    const uint32_t x=(face%3u)*256u,y=(face/3u)*256u;
    const D3D12_BOX box{x,y,0u,x+256u,y+256u,1u};
    D3D12_TEXTURE_COPY_LOCATION source{native,D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
    D3D12_TEXTURE_COPY_LOCATION destination{clear_.object.Get(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
    command->CopyTextureRegion(&destination,x,y,0,&source,&box);
    gpu::Transition(command,&clear_,gpu::TextureRead);
    std::swap(barrier.Transition.StateBefore,barrier.Transition.StateAfter);
    command->ResourceBarrier(1,&barrier);
  }
  std::shared_ptr<gpu::Bank> Convert(ID3D12GraphicsCommandList* command,
      ID3D12Resource* native,const D3D12_SHADER_RESOURCE_VIEW_DESC& native_view,
      ID3D12Resource* cloud,ID3D12Resource* cloud_header,
      D3D12_CPU_DESCRIPTOR_HANDLE target,DXGI_FORMAT target_format) {
    std::shared_ptr<gpu::Bank> bank;
    for (const auto& candidate : convert_banks_) if (candidate.use_count() == 1) { bank = candidate; break; }
    if (!bank) {
      bank = std::make_shared<gpu::Bank>(assets_->Device());
      convert_banks_.push_back(bank);
    }
    assets_->Device()->CreateShaderResourceView(native,&native_view,bank->Cpu(0));
    gpu::Srv(assets_->Device(),*bank,1,clear_.object.Get(),D3D12_SRV_DIMENSION_TEXTURE2D);
    gpu::Srv(assets_->Device(),*bank,2,cloud,D3D12_SRV_DIMENSION_TEXTURE2D);
    gpu::Srv(assets_->Device(),*bank,3,metadata_.object.Get(),D3D12_SRV_DIMENSION_BUFFER);
    gpu::Srv(assets_->Device(),*bank,4,cloud_header,D3D12_SRV_DIMENSION_BUFFER);
    ID3D12DescriptorHeap* heaps[]={bank->heap.Get()};
    command->SetDescriptorHeaps(1,heaps);
    command->SetGraphicsRootSignature(assets_->root.Get());
    command->SetGraphicsRootDescriptorTable(7,bank->Gpu());
    command->SetPipelineState(target_format==DXGI_FORMAT_R11G11B10_FLOAT?assets_->atlas_convert11.Get():
        target_format==DXGI_FORMAT_R32G32B32A32_FLOAT?assets_->atlas_convert32.Get():assets_->atlas_convert16.Get());
    command->OMSetRenderTargets(1,&target,FALSE,nullptr);
    const D3D12_VIEWPORT viewport{0,0,256,256,0,1};
    const D3D12_RECT scissor{0,0,256,256};
    command->RSSetViewports(1,&viewport);
    command->RSSetScissorRects(1,&scissor);
    command->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    command->DrawInstanced(3,1,0,0);
    return bank;
  }
 private:
  Assets* assets_;
  DXGI_FORMAT format_;
  gpu::Resource clear_,metadata_;
  std::shared_ptr<gpu::Bank> capture_bank_;
  std::vector<std::shared_ptr<gpu::Bank>> convert_banks_;
};
}  // namespace hartapfelfx::clouds
