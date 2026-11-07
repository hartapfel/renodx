// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../lighting/graphics/tests/gpu.hpp"
#include "../clouds/gpu.hpp"
#include <array>
#include <cmath>
#include <filesystem>
int main(int argc,char** argv) {
  namespace gpu=hartapfelfx::clouds::gpu;
  assert(argc==2);
  const std::filesystem::path directory=argv[1];
  GpuFixture fixture;
  const D3D12_DESCRIPTOR_RANGE range{D3D12_DESCRIPTOR_RANGE_TYPE_SRV,1,0};
  D3D12_ROOT_PARAMETER parameters[2]{};
  parameters[0].ParameterType=D3D12_ROOT_PARAMETER_TYPE_CBV;
  parameters[1].ParameterType=D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;
  parameters[1].DescriptorTable={1,&range};
  D3D12_STATIC_SAMPLER_DESC sampler{};
  sampler.Filter=D3D12_FILTER_MIN_MAG_MIP_LINEAR;
  sampler.AddressU=sampler.AddressV=sampler.AddressW=D3D12_TEXTURE_ADDRESS_MODE_WRAP;
  sampler.MaxLOD=D3D12_FLOAT32_MAX;sampler.ComparisonFunc=D3D12_COMPARISON_FUNC_ALWAYS;
  const D3D12_ROOT_SIGNATURE_DESC signature{2,parameters,1,&sampler};
  ComPtr<ID3DBlob> blob,error;
  Check(D3D12SerializeRootSignature(&signature,D3D_ROOT_SIGNATURE_VERSION_1,&blob,&error));
  ComPtr<ID3D12RootSignature> root;
  Check(fixture.device->CreateRootSignature(0,blob->GetBufferPointer(),blob->GetBufferSize(),IID_PPV_ARGS(&root)));
  auto vertex=Read((directory/"0xF7F00001.cso").string().c_str());
  auto pixel=Read((directory/"local-cloud.cso").string().c_str());
  auto pipeline=fixture.Graphics(root.Get(),vertex,pixel,DXGI_FORMAT_R32G32B32A32_FLOAT);
  auto material=gpu::Image(fixture.device.Get(),8,4,DXGI_FORMAT_R32G32B32A32_FLOAT);
  D3D12_RESOURCE_DESC description=material.object->GetDesc();
  D3D12_PLACED_SUBRESOURCE_FOOTPRINT source_footprint{};uint64_t bytes=0;
  fixture.device->GetCopyableFootprints(&description,0,1,0,&source_footprint,nullptr,nullptr,&bytes);
  auto upload=fixture.Buffer(bytes,D3D12_HEAP_TYPE_UPLOAD);
  std::vector<uint8_t> texels(bytes);
  for(uint32_t y=0;y<4;++y)for(uint32_t x=0;x<8;++x) {
    const float value[4]={1,1,1,x<4?.25f:.75f};
    std::memcpy(texels.data()+source_footprint.Offset+y*source_footprint.Footprint.RowPitch+x*16,value,16);
  }
  fixture.Upload(upload.Get(),texels.data(),texels.size());
  gpu::Transition(fixture.cmd.Get(),&material,D3D12_RESOURCE_STATE_COPY_DEST);
  D3D12_TEXTURE_COPY_LOCATION from{upload.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};from.PlacedFootprint=source_footprint;
  D3D12_TEXTURE_COPY_LOCATION to{material.object.Get(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
  fixture.cmd->CopyTextureRegion(&to,0,0,0,&from,nullptr);
  gpu::Transition(fixture.cmd.Get(),&material,gpu::TextureRead);fixture.Submit();
  gpu::Bank bank(fixture.device.Get());
  gpu::Srv(fixture.device.Get(),bank,0,material.object.Get(),D3D12_SRV_DIMENSION_TEXTURE2D);
  description.Width=description.Height=64;description.Flags=D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET;
  auto target=gpu::Create(fixture.device.Get(),description,D3D12_RESOURCE_STATE_RENDER_TARGET);
  ComPtr<ID3D12DescriptorHeap> rtv;
  const D3D12_DESCRIPTOR_HEAP_DESC rtv_desc{D3D12_DESCRIPTOR_HEAP_TYPE_RTV,1};
  Check(fixture.device->CreateDescriptorHeap(&rtv_desc,IID_PPV_ARGS(&rtv)));
  const auto target_view=rtv->GetCPUDescriptorHandleForHeapStart();
  fixture.device->CreateRenderTargetView(target.object.Get(),nullptr,target_view);
  D3D12_PLACED_SUBRESOURCE_FOOTPRINT footprint{};
  fixture.device->GetCopyableFootprints(&description,0,1,0,&footprint,nullptr,nullptr,&bytes);
  auto readback=fixture.Buffer(bytes,D3D12_HEAP_TYPE_READBACK);
  auto constants=fixture.Buffer(256,D3D12_HEAP_TYPE_UPLOAD);
  auto render=[&](float surface,float animation,float alpha,float time,float marker=1358.f) {
    const float data[8]={surface,animation,alpha,time,0,0,100,marker};
    fixture.Upload(constants.Get(),data,sizeof(data));
    auto* cmd=fixture.cmd.Get();
    cmd->SetGraphicsRootSignature(root.Get());cmd->SetPipelineState(pipeline.Get());
    ID3D12DescriptorHeap* heaps[]={bank.heap.Get()};cmd->SetDescriptorHeaps(1,heaps);
    cmd->SetGraphicsRootConstantBufferView(0,constants->GetGPUVirtualAddress());
    cmd->SetGraphicsRootDescriptorTable(1,bank.Gpu());
    cmd->OMSetRenderTargets(1,&target_view,FALSE,nullptr);
    const D3D12_VIEWPORT viewport{0,0,64,64,0,1};const D3D12_RECT scissor{0,0,64,64};
    cmd->RSSetViewports(1,&viewport);cmd->RSSetScissorRects(1,&scissor);
    cmd->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);cmd->DrawInstanced(3,1,0,0);
    gpu::Transition(cmd,&target,D3D12_RESOURCE_STATE_COPY_SOURCE);
    D3D12_TEXTURE_COPY_LOCATION source{target.object.Get(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
    D3D12_TEXTURE_COPY_LOCATION destination{readback.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};destination.PlacedFootprint=footprint;
    cmd->CopyTextureRegion(&destination,0,0,0,&source,nullptr);gpu::Transition(cmd,&target,D3D12_RESOURCE_STATE_RENDER_TARGET);
    fixture.Submit();void* mapped=nullptr;Check(readback->Map(0,nullptr,&mapped));
    std::vector<float> image(64*64*4);
    for(uint32_t y=0;y<64;++y)std::memcpy(image.data()+y*64*4,static_cast<uint8_t*>(mapped)+y*footprint.Footprint.RowPitch,64*16);
    readback->Unmap(0,nullptr);
    for(float value:image)assert(std::isfinite(value));return image;
  };
  const auto native=render(1.e9f,0,1,0,1);
  for(size_t i=0;i<native.size();++i)assert(std::abs(native[i]-(i%4+1)*.1f)<1.e-6f);
  const auto full=render(1.e9f,0,1,0),cut=render(80,0,1,0),occluded=render(50,0,1,0);
  const size_t center=(32*64+32)*4+3;
  assert(full[center]>.05f &&cut[center]>0 &&cut[center]<full[center]);
  for(size_t i=0;i<occluded.size();++i)if(std::abs(occluded[i])>=1.e-6f) {
    std::cerr<<"Occluded pixel "<<i/4%64<<','<<i/4/64<<" channel "<<i%4<<" value "<<occluded[i]<<'\n';
    assert(false);
  }
  const auto vacuum=render(1.e9f,0,0,0),animated=render(1.e9f,1,1,0),moved=render(1.e9f,0,1,20);
  for(float value:vacuum)assert(std::abs(value)<1.e-6f);
  assert(animated[center]>full[center]);
  double change=0;
  for(size_t i=0;i<moved.size();++i)change+=std::abs(moved[i]-full[i]);
  assert(change>1);
  fixture.CheckMessages();
  std::cout<<"PASS native particle volume: finite radiance, unchanged unmarked sprites, front/inside terrain clipping, vacuum, flipbook and flow\n";
}
