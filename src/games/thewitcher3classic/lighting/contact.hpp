/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <embed/0xF3C40020.h>
#include <embed/0xF3C40021.h>
#include <embed/0xF3C40022.h>
#include <embed/0xF3C40023.h>
#include "../temporal/context.hpp"
#include <array>
namespace witcher3classic::lighting {
using Microsoft::WRL::ComPtr;
// Packed data, trace and optional motion-reprojected history at render resolution.
// Spatial filtering precedes history clipping, as in BlitzFX; no CPU readback.
class ContactPipeline {
 public:
  ComPtr<ID3D11ShaderResourceView> albedo;
  ComPtr<ID3D11Resource> albedo_resource;
  ID3D11ShaderResourceView* Generate(ID3D11DeviceContext1* context,
      ID3D11ShaderResourceView* parameters,UINT width,UINT height,
      uint64_t frame=UINT64_MAX,ID3D11ShaderResourceView* motion=nullptr,
      ID3D11ShaderResourceView* motion_depth=nullptr) {
    bool consecutive=last_frame_!=UINT64_MAX && last_frame_+1==frame;
    last_frame_=UINT64_MAX;
    if(!parameters||!width||!height||width>8192||height>8192)return nullptr;
    ComPtr<ID3D11Device> device;context->GetDevice(&device);
    if(!state_) {
      if(FAILED(device->CreateComputeShader(__0xF3C40020.data(),__0xF3C40020.size(),nullptr,&pack_))
          ||FAILED(device->CreateComputeShader(__0xF3C40021.data(),__0xF3C40021.size(),nullptr,&trace_))
          ||FAILED(temporal::CreateIsolatedState(device.Get(),&state_)))return nullptr;
    }
    std::array<ComPtr<ID3D11ShaderResourceView>,3> input;
    for(UINT i=0;i<3;++i)context->PSGetShaderResources(i,1,&input[i]);
    if(!input[0]||!input[1]||!input[2])return nullptr;
    ComPtr<ID3D11Resource> depth;input[0]->GetResource(&depth);
    if(depth!=depth_) {
      consecutive=false;
      stencil_.Reset();depth_.Reset();
      ComPtr<ID3D11Texture2D> texture;if(FAILED(depth.As(&texture)))return nullptr;
      D3D11_TEXTURE2D_DESC desc;texture->GetDesc(&desc);
      if(desc.Format!=DXGI_FORMAT_R24G8_TYPELESS||desc.SampleDesc.Count!=1)return nullptr;
      D3D11_SHADER_RESOURCE_VIEW_DESC view{};view.Format=DXGI_FORMAT_X24_TYPELESS_G8_UINT;
      view.ViewDimension=D3D11_SRV_DIMENSION_TEXTURE2D;view.Texture2D.MipLevels=1;
      if(FAILED(device->CreateShaderResourceView(depth.Get(),&view,&stencil_)))return nullptr;
      depth_=depth;
      depth_width_=desc.Width;depth_height_=desc.Height;
    }
    if(width>depth_width_||height>depth_height_)return nullptr;
    if(width_!=width||height_!=height||!output_view_) {
      consecutive=false;
      for(auto& v:history_view_)v.Reset();
      for(auto& v:history_uav_)v.Reset();
      for(auto& v:history_)v.Reset();
      packed_.Reset();packed_view_.Reset();packed_output_.Reset();
      output_.Reset();output_view_.Reset();output_uav_.Reset();
      D3D11_TEXTURE2D_DESC desc{width,height,1,1,DXGI_FORMAT_R32G32_FLOAT,{1,0},
          D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_UNORDERED_ACCESS};
      if(FAILED(device->CreateTexture2D(&desc,nullptr,&packed_))
          ||FAILED(device->CreateShaderResourceView(packed_.Get(),nullptr,&packed_view_))
          ||FAILED(device->CreateUnorderedAccessView(packed_.Get(),nullptr,&packed_output_)))return nullptr;
      desc.Format=DXGI_FORMAT_R16G16_FLOAT;
      if(FAILED(device->CreateTexture2D(&desc,nullptr,&output_))
          ||FAILED(device->CreateShaderResourceView(output_.Get(),nullptr,&output_view_))
          ||FAILED(device->CreateUnorderedAccessView(output_.Get(),nullptr,&output_uav_))) {
        output_view_.Reset();return nullptr;
      }
      width_=width;height_=height;
    }
    std::array<ComPtr<ID3D11Buffer>,2> buffers;
    UINT first[2]{},count[2]{};
    for(UINT i=0;i<2;++i)context->PSGetConstantBuffers1(12+i,1,&buffers[i],&first[i],&count[i]);
    if(!buffers[0]||!buffers[1])return nullptr;
    if(frame!=UINT64_MAX) {
      if(!history_constants_view_) {
        history_constants_.Reset();history_control_.Reset();filter_.Reset();spatial_.Reset();
        D3D11_BUFFER_DESC desc{218*16,D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
        if(FAILED(device->CreateBuffer(&desc,nullptr,&history_constants_))
            ||FAILED(device->CreateShaderResourceView(history_constants_.Get(),nullptr,&history_constants_view_)))return nullptr;
        desc={16,D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
        if(FAILED(device->CreateBuffer(&desc,nullptr,&history_control_))
            ||FAILED(device->CreateComputeShader(__0xF3C40022.data(),__0xF3C40022.size(),nullptr,&filter_))
            ||FAILED(device->CreateComputeShader(__0xF3C40023.data(),__0xF3C40023.size(),nullptr,&spatial_))) {
          history_constants_view_.Reset();return nullptr;
        }
      }
      if(!history_view_[0]||!history_view_[1]) {
        consecutive=false;
        const D3D11_TEXTURE2D_DESC desc{width,height,1,1,DXGI_FORMAT_R16G16_FLOAT,{1,0},
            D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_UNORDERED_ACCESS};
        for(UINT i=0;i<2;++i) {
          history_[i].Reset();history_view_[i].Reset();history_uav_[i].Reset();
          if(FAILED(device->CreateTexture2D(&desc,nullptr,&history_[i]))
              ||FAILED(device->CreateShaderResourceView(history_[i].Get(),nullptr,&history_view_[i]))
              ||FAILED(device->CreateUnorderedAccessView(history_[i].Get(),nullptr,&history_uav_[i])))return nullptr;
        }
      }
      // A ranged native CB must contain every copied row; never read outside it.
      for(UINT i=0;i<2;++i) {
        D3D11_BUFFER_DESC desc;buffers[i]->GetDesc(&desc);
        const UINT rows=i==0?214:1;
        if(count[i]<rows || uint64_t(first[i]+rows)*16>desc.ByteWidth)return nullptr;
      }
    }
    temporal::ContextScope restore(context,state_.Get());
    ID3D11Buffer* native_buffers[]={buffers[0].Get(),buffers[1].Get()};
    context->CSSetConstantBuffers1(12,2,native_buffers,first,count);
    ID3D11ShaderResourceView* inputs[]={input[0].Get(),input[1].Get(),input[2].Get(),stencil_.Get(),albedo.Get()};
    context->CSSetShaderResources(0,5,inputs);
    context->CSSetShaderResources(118,1,&parameters);
    context->CSSetUnorderedAccessViews(0,1,packed_output_.GetAddressOf(),nullptr);
    context->CSSetShader(pack_.Get(),nullptr,0);context->Dispatch((width+7)/8,(height+7)/8,1);
    ID3D11UnorderedAccessView* none=nullptr;context->CSSetUnorderedAccessViews(0,1,&none,nullptr);
    context->CSSetShaderResources(1,1,packed_view_.GetAddressOf());
    context->CSSetUnorderedAccessViews(0,1,output_uav_.GetAddressOf(),nullptr);
    context->CSSetShader(trace_.Get(),nullptr,0);context->Dispatch((width+7)/8,(height+7)/8,1);
    context->CSSetUnorderedAccessViews(0,1,&none,nullptr);
    if(frame!=UINT64_MAX) {
      // Packing is no longer needed after tracing. Reuse that RG32F surface
      // for the spatial result, replacing its SRV binding before writing it.
      context->CSSetShaderResources(1,1,input[1].GetAddressOf());
      context->CSSetShaderResources(4,1,output_view_.GetAddressOf());
      context->CSSetUnorderedAccessViews(0,1,packed_output_.GetAddressOf(),nullptr);
      context->CSSetShader(spatial_.Get(),nullptr,0);context->Dispatch((width+7)/8,(height+7)/8,1);
      context->CSSetUnorderedAccessViews(0,1,&none,nullptr);
      const std::array<float,4> control{consecutive?1.f:0.f,0,0,0};
      context->UpdateSubresource(history_control_.Get(),0,nullptr,control.data(),0,0);
      context->CSSetConstantBuffers(11,1,history_control_.GetAddressOf());
      const UINT next=history_index_^1u;
      ID3D11ShaderResourceView* history_inputs[]={packed_view_.Get(),history_view_[history_index_].Get(),history_constants_view_.Get(),motion,motion_depth};
      context->CSSetShaderResources(4,5,history_inputs);
      context->CSSetUnorderedAccessViews(0,1,history_uav_[next].GetAddressOf(),nullptr);
      context->CSSetShader(filter_.Get(),nullptr,0);context->Dispatch((width+7)/8,(height+7)/8,1);
      context->CSSetUnorderedAccessViews(0,1,&none,nullptr);
      ID3D11ShaderResourceView* no_history[5]{};context->CSSetShaderResources(4,5,no_history);
      for(UINT i=0;i<2;++i) {
        const D3D11_BOX box{first[i]*16,0,0,(first[i]+(i==0?214:1))*16,1,1};
        context->CopySubresourceRegion(history_constants_.Get(),0,i==0?0:214*16,0,0,buffers[i].Get(),0,&box);
      }
      ComPtr<ID3D11Resource> parameter_resource;parameters->GetResource(&parameter_resource);
      const D3D11_BOX box{0,0,0,48,1,1};
      context->CopySubresourceRegion(history_constants_.Get(),0,215*16,0,0,parameter_resource.Get(),0,&box);
      history_index_=next;last_frame_=frame;
      return history_view_[history_index_].Get();
    }
    return output_view_.Get();
  }
 private:
  UINT width_=0,height_=0,depth_width_=0,depth_height_=0;
  ComPtr<ID3DDeviceContextState> state_;
  ComPtr<ID3D11ComputeShader> pack_,trace_;
  ComPtr<ID3D11Resource> depth_;
  ComPtr<ID3D11ShaderResourceView> stencil_,packed_view_,output_view_;
  ComPtr<ID3D11Texture2D> packed_,output_;
  ComPtr<ID3D11UnorderedAccessView> packed_output_,output_uav_;
  uint64_t last_frame_=UINT64_MAX;
  UINT history_index_=0;
  ComPtr<ID3D11ComputeShader> filter_,spatial_;
  ComPtr<ID3D11Buffer> history_constants_,history_control_;
  ComPtr<ID3D11ShaderResourceView> history_constants_view_;
  std::array<ComPtr<ID3D11Texture2D>,2> history_;
  std::array<ComPtr<ID3D11ShaderResourceView>,2> history_view_;
  std::array<ComPtr<ID3D11UnorderedAccessView>,2> history_uav_;
};
} // namespace witcher3classic::lighting
