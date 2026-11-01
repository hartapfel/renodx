/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <embed/0xF3C10002.h>
#include <embed/0xF3C60001.h>
#include <embed/0xF3C60002.h>
#include <embed/0xF3C60003.h>
#include <embed/0xF3C60004.h>
#include <embed/0xF3C60005.h>
#include <embed/0xF3C60006.h>
#include <array>
#include <cstdint>
#include "settings.hpp"
#include "../volumetrics/pipeline.hpp"
#include "../temporal/context.hpp"
namespace witcher3classic::clouds {
template<class T> using ComPtr=Microsoft::WRL::ComPtr<T>;
class Pipeline {
  struct Parameters {
    std::array<float,4> dimensions{},integration{},appearance{1,1,1,1},atmosphere{},scattering{};
  };
  static_assert(sizeof(Parameters)==80);
 public:
  void Invalidate() { history_frame_=UINT64_MAX; }
  std::array<ID3D11ShaderResourceView*,2> ShadowViews() const {return {shadow_view_.Get(),shadow_data_view_.Get()};}
  bool PrepareShadow(ID3D11DeviceContext1* context,ID3D11Buffer* frame,ID3D11Buffer* lighting,
      ID3D11ShaderResourceView* weather,uint64_t serial,float quality,bool cast) {
    if(shadow_frame_==serial)return true;
    if(!frame ||!lighting ||!weather)return false;
    D3D11_BUFFER_DESC buffer{};frame->GetDesc(&buffer);if(buffer.ByteWidth!=4304)return false;
    lighting->GetDesc(&buffer);if(buffer.ByteWidth<32)return false;
    D3D11_SHADER_RESOURCE_VIEW_DESC view{};weather->GetDesc(&view);
    if(view.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2DARRAY ||!view.Texture2DArray.ArraySize)return false;
    ComPtr<ID3D11Device> device;context->GetDevice(&device);
    if(!Initialize(device.Get()))return false;
    constexpr std::array<std::array<UINT,2>,6> sizes{{{256,32},{384,48},{512,64},{768,80},{1024,112},{1536,160}}};
    const auto& size=sizes[std::clamp(std::lround(quality),0L,5L)];
    if(shadow_size_!=size[0]) {
      shadow_size_=0;shadow_texture_.Reset();shadow_view_.Reset();shadow_output_.Reset();
      const D3D11_TEXTURE2D_DESC desc{size[0],size[0],1,1,DXGI_FORMAT_R16_FLOAT,{1,0},D3D11_USAGE_DEFAULT,
          D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_UNORDERED_ACCESS};
      if(FAILED(device->CreateTexture2D(&desc,nullptr,&shadow_texture_))
          ||FAILED(device->CreateShaderResourceView(shadow_texture_.Get(),nullptr,&shadow_view_))
          ||FAILED(device->CreateUnorderedAccessView(shadow_texture_.Get(),nullptr,&shadow_output_)))return false;
      shadow_size_=size[0];
    }
    const auto clock=Clock(context);
    temporal::ContextScope restore(context,state_.Get());
    auto lighting_quality=QualityLighting(quality);
    lighting_quality[1]=1.f; // filtered shadows do not resolve view-ray micro-erosion
    if(!PrepareNoise(context,UINT(lighting_quality[3])))return false;
    const Parameters parameters{{float(size[0]),float(size[0]),16000.f,float(size[1])},
        {cast ? 1.f : 0.f,0,0,0},Appearance(),{},lighting_quality};
    context->UpdateSubresource(parameters_.Get(),0,nullptr,&parameters,0,0);
    ID3D11Buffer* constants[]{frame,lighting,parameters_.Get()};
    ID3D11ShaderResourceView* inputs[]{noise_view_.Get(),weather};
    ID3D11UnorderedAccessView* outputs[]{shadow_output_.Get(),shadow_data_output_.Get()};
    auto* sampler=wrap_.Get();context->CSSetSamplers(0,1,&sampler);
    context->CSSetConstantBuffers(0,3,constants);context->CSSetShaderResources(0,2,inputs);
    context->CSSetConstantBuffers(5,1,clock.GetAddressOf());
    context->CSSetUnorderedAccessViews(0,2,outputs,nullptr);context->CSSetShader(shadow_.Get(),nullptr,0);
    context->Dispatch(cast ? (size[0]+7)/8 : 1,cast ? (size[0]+7)/8 : 1,1);
    shadow_frame_=serial;return true;
  }
  bool Render(ID3D11DeviceContext1* context,ID3D11Buffer* frame,ID3D11Buffer* lighting,
      ID3D11ShaderResourceView* weather,ID3D11ShaderResourceView* depth,
      ID3D11RenderTargetView* target,UINT width,UINT height,uint64_t serial,float quality,
      const volumetrics::Pipeline* fog=nullptr) {
    if(!frame ||!lighting ||!weather ||!depth ||!target ||!width ||!height)return false;
    D3D11_BUFFER_DESC buffer_desc{};frame->GetDesc(&buffer_desc);
    if(buffer_desc.ByteWidth!=4304)return false;
    lighting->GetDesc(&buffer_desc);if(buffer_desc.ByteWidth<32)return false;
    D3D11_SHADER_RESOURCE_VIEW_DESC srv_desc{};weather->GetDesc(&srv_desc);
    if(srv_desc.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2DARRAY ||srv_desc.Texture2DArray.ArraySize==0)return false;
    depth->GetDesc(&srv_desc);
    if(srv_desc.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2D ||srv_desc.Texture2D.MostDetailedMip!=0)return false;
    ComPtr<ID3D11Resource> resource;ComPtr<ID3D11Texture2D> texture;
    depth->GetResource(&resource);if(FAILED(resource.As(&texture)))return false;
    D3D11_TEXTURE2D_DESC texture_desc{};texture->GetDesc(&texture_desc);
    if(texture_desc.Width<width ||texture_desc.Height<height ||texture_desc.SampleDesc.Count!=1)return false;
    target->GetResource(&resource);texture.Reset();if(FAILED(resource.As(&texture)))return false;
    texture->GetDesc(&texture_desc);
    // Cloud radiance must retain the native scene's HDR range.
    if(texture_desc.Width<width ||texture_desc.Height<height ||texture_desc.SampleDesc.Count!=1
        ||(texture_desc.Format!=DXGI_FORMAT_R16G16B16A16_FLOAT &&texture_desc.Format!=DXGI_FORMAT_R32G32B32A32_FLOAT))return false;
    const auto samples=Quality(quality);
    const auto appearance=Appearance();
    const std::array<float,4> atmosphere{std::clamp(volumetrics::sky_density,0.f,4.f),0,0,0};
    if(appearance_!=appearance ||atmosphere_!=atmosphere) {
      Invalidate();cut_frame_=serial;appearance_=appearance;atmosphere_=atmosphere;
    }
    UINT low_width=(width+samples[0]-1)/samples[0],low_height=(height+samples[0]-1)/samples[0];
    ComPtr<ID3D11Device> device;context->GetDevice(&device);
    if(!Initialize(device.Get()))return false;
    if(quality_!=samples) {Invalidate();cut_frame_=serial;}
    if(width_!=low_width ||height_!=low_height ||render_width_!=width ||render_height_!=height) {
      Invalidate();cut_frame_=serial;width_=height_=0;
      for(auto& item:buffers_)item={};
      for(UINT i=0;i<buffers_.size();++i) {
        D3D11_TEXTURE2D_DESC desc{low_width,low_height,1,1,
            i%2==0 ? DXGI_FORMAT_R16G16B16A16_FLOAT : DXGI_FORMAT_R32_FLOAT,
            {1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_UNORDERED_ACCESS};
        if(FAILED(device->CreateTexture2D(&desc,nullptr,&buffers_[i].texture))
            ||FAILED(device->CreateShaderResourceView(buffers_[i].texture.Get(),nullptr,&buffers_[i].view))
            ||FAILED(device->CreateUnorderedAccessView(buffers_[i].texture.Get(),nullptr,&buffers_[i].uav)))return false;
      }
      width_=low_width;height_=low_height;render_width_=width;render_height_=height;
    }
    quality_=samples;
    ComPtr<ID3D11ShaderResourceView> shadow_map,shadow_data;
    context->CSGetShaderResources(126,1,&shadow_map);context->CSGetShaderResources(127,1,&shadow_data);
    const auto clock=Clock(context);
    temporal::ContextScope restore(context,state_.Get());
    ID3D11ShaderResourceView* shadow_inputs[]{shadow_map.Get(),shadow_data.Get()};
    context->CSSetShaderResources(126,2,shadow_inputs);
    const auto lighting_quality=QualityLighting(quality);
    if(!PrepareNoise(context,UINT(lighting_quality[3])))return false;
    const bool history=history_frame_!=UINT64_MAX &&serial==history_frame_+1;
    const Parameters parameters{{float(low_width),float(low_height),float(width),float(height)},
        {float(samples[1]),float(samples[2]),float(serial%1024),history?1.f:0.f},appearance,atmosphere,lighting_quality};
    context->UpdateSubresource(parameters_.Get(),0,nullptr,&parameters,0,0);
    // Bind the native lighting buffer directly. The shader reads only its first
    // two rows; partial copies of D3D11 constant buffers are not portable.
    ID3D11Buffer* constants[]{frame,lighting,parameters_.Get(),previous_.Get()};
    ID3D11SamplerState* samplers[]{wrap_.Get(),clamp_.Get()};
    context->CSSetConstantBuffers(0,4,constants);context->CSSetSamplers(0,2,samplers);
    ID3D11Buffer* clocks[]{clock.Get(),previous_clock_.Get()};
    context->CSSetConstantBuffers(5,2,clocks);
    ID3D11ShaderResourceView* inputs[]{noise_view_.Get(),weather,depth};
    context->CSSetShaderResources(0,3,inputs);
    ID3D11UnorderedAccessView* outputs[]{buffers_[0].uav.Get(),buffers_[1].uav.Get(),nullptr};
    context->CSSetUnorderedAccessViews(0,2,outputs,nullptr);
    context->CSSetShader(trace_.Get(),nullptr,0);context->Dispatch((low_width+7)/8,(low_height+7)/8,1);
    outputs[0]=outputs[1]=nullptr;context->CSSetUnorderedAccessViews(0,2,outputs,nullptr);
    UINT write=history_index_==2 ? 4 : 2;
    ID3D11ShaderResourceView* temporal_inputs[]{buffers_[0].view.Get(),buffers_[1].view.Get(),
        buffers_[history_index_].view.Get(),buffers_[history_index_+1].view.Get()};
    context->CSSetShaderResources(3,4,temporal_inputs);
    outputs[0]=buffers_[write].uav.Get();outputs[1]=buffers_[write+1].uav.Get();
    outputs[2]=buffers_[6].uav.Get();
    context->CSSetUnorderedAccessViews(0,3,outputs,nullptr);
    context->CSSetShader(resolve_.Get(),nullptr,0);context->Dispatch((low_width+7)/8,(low_height+7)/8,1);
    outputs[0]=outputs[1]=outputs[2]=nullptr;context->CSSetUnorderedAccessViews(0,3,outputs,nullptr);
    std::array<ID3D11ShaderResourceView*,7> empty{};context->CSSetShaderResources(0,7,empty.data());
    context->CSSetShader(nullptr,nullptr,0);
    context->PSSetConstantBuffers(0,4,constants);context->PSSetSamplers(0,2,samplers);
    if(fog)fog->BindIsolated(context,serial);
    context->PSSetShaderResources(2,1,&depth);
    ID3D11ShaderResourceView* composite[]{buffers_[write].view.Get(),buffers_[write+1].view.Get()};
    context->PSSetShaderResources(3,2,composite);
    context->OMSetRenderTargets(1,&target,nullptr);
    context->OMSetBlendState(blend_.Get(),nullptr,UINT_MAX);
    context->OMSetDepthStencilState(depth_state_.Get(),0);
    context->RSSetState(raster_.Get());
    const D3D11_VIEWPORT viewport{0,0,float(width),float(height),0,1};context->RSSetViewports(1,&viewport);
    context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    context->VSSetShader(vertex_.Get(),nullptr,0);context->PSSetShader(composite_.Get(),nullptr,0);
    context->Draw(3,0);
    context->CopyResource(previous_.Get(),frame);
    context->CopyResource(previous_clock_.Get(),clock.Get());
    history_index_=write;history_frame_=serial;
    return true;
  }
  bool ApplyMotion(ID3D11DeviceContext1* context,ID3D11ShaderResourceView* depth,ID3D11Buffer* frame,
      ID3D11Texture2D* motion,ID3D11Texture2D* responsive,UINT width,UINT height,uint64_t serial) {
    if(!ready_ ||history_frame_!=serial ||!depth ||!frame ||!motion ||!responsive
        ||width!=render_width_ ||height!=render_height_)return false;
    if(motion_texture_.Get()!=motion ||responsive_texture_.Get()!=responsive) {
      motion_texture_.Reset();responsive_texture_.Reset();motion_uav_.Reset();responsive_uav_.Reset();
      ComPtr<ID3D11Device> device;context->GetDevice(&device);
      if(FAILED(device->CreateUnorderedAccessView(motion,nullptr,&motion_uav_))
          ||FAILED(device->CreateUnorderedAccessView(responsive,nullptr,&responsive_uav_)))return false;
      motion_texture_=motion;responsive_texture_=responsive;
    }
    temporal::ContextScope restore(context,state_.Get());
    const Parameters packet{{float(width),float(height),cut_frame_==serial ? 1.f : 0.f,0}};
    context->UpdateSubresource(parameters_.Get(),0,nullptr,&packet,0,0);
    ID3D11Buffer* parameters=parameters_.Get();
    context->CSSetConstantBuffers(0,1,&parameters);context->CSSetConstantBuffers(12,1,&frame);
    ID3D11ShaderResourceView* inputs[]{buffers_[6].view.Get(),depth};
    ID3D11UnorderedAccessView* outputs[]{motion_uav_.Get(),responsive_uav_.Get()};
    auto* sampler=clamp_.Get();context->CSSetSamplers(0,1,&sampler);
    context->CSSetShaderResources(0,2,inputs);context->CSSetUnorderedAccessViews(0,2,outputs,nullptr);
    context->CSSetShader(motion_.Get(),nullptr,0);context->Dispatch((width+7)/8,(height+7)/8,1);
    return true;
  }
 private:
  ComPtr<ID3D11Buffer> Clock(ID3D11DeviceContext1* context) const {
    ComPtr<ID3D11Buffer> clock;UINT offset=0,count=0;
    context->PSGetConstantBuffers1(0,1,&clock,&offset,&count);
    if(clock &&offset==0) {
      D3D11_BUFFER_DESC desc{};clock->GetDesc(&desc);
      if(desc.ByteWidth==256)return clock;
    }
    return zero_clock_;
  }
  bool PrepareNoise(ID3D11DeviceContext1* context,UINT size) {
    if(noise_ready_ &&noise_size_==size)return true;
    if(noise_size_!=size ||!noise_uav_) {
      Invalidate();noise_ready_=false;noise_size_=0;
      noise_uav_.Reset();noise_view_.Reset();noise_.Reset();
      ComPtr<ID3D11Device> device;context->GetDevice(&device);
      D3D11_TEXTURE3D_DESC volume{size,size,size,0,DXGI_FORMAT_R8G8B8A8_UNORM,D3D11_USAGE_DEFAULT,
          D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_UNORDERED_ACCESS|D3D11_BIND_RENDER_TARGET,0,D3D11_RESOURCE_MISC_GENERATE_MIPS};
      if(FAILED(device->CreateTexture3D(&volume,nullptr,&noise_))
          ||FAILED(device->CreateShaderResourceView(noise_.Get(),nullptr,&noise_view_)))return false;
      D3D11_UNORDERED_ACCESS_VIEW_DESC uav{};uav.Format=volume.Format;uav.ViewDimension=D3D11_UAV_DIMENSION_TEXTURE3D;
      uav.Texture3D.WSize=size;
      if(FAILED(device->CreateUnorderedAccessView(noise_.Get(),&uav,&noise_uav_)))return false;
      noise_size_=size;
    }
    auto* output=noise_uav_.Get();
    context->CSSetShader(noise_shader_.Get(),nullptr,0);context->CSSetUnorderedAccessViews(0,1,&output,nullptr);
    context->Dispatch((size+3)/4,(size+3)/4,(size+3)/4);
    output=nullptr;context->CSSetUnorderedAccessViews(0,1,&output,nullptr);
    context->GenerateMips(noise_view_.Get());noise_ready_=true;return true;
  }
  bool Initialize(ID3D11Device* device) {
    if(ready_)return true;
    // Retry initialization as a unit. A partially created state never means
    // the native clouds can be skipped.
    if(FAILED(temporal::CreateIsolatedState(device,&state_))
        ||FAILED(device->CreateComputeShader(__0xF3C60001.data(),__0xF3C60001.size(),nullptr,&noise_shader_))
        ||FAILED(device->CreateComputeShader(__0xF3C60002.data(),__0xF3C60002.size(),nullptr,&trace_))
        ||FAILED(device->CreateComputeShader(__0xF3C60003.data(),__0xF3C60003.size(),nullptr,&resolve_))
        ||FAILED(device->CreateComputeShader(__0xF3C60005.data(),__0xF3C60005.size(),nullptr,&motion_))
        ||FAILED(device->CreateComputeShader(__0xF3C60006.data(),__0xF3C60006.size(),nullptr,&shadow_))
        ||FAILED(device->CreateVertexShader(__0xF3C10002.data(),__0xF3C10002.size(),nullptr,&vertex_))
        ||FAILED(device->CreatePixelShader(__0xF3C60004.data(),__0xF3C60004.size(),nullptr,&composite_)))return false;
    D3D11_BUFFER_DESC desc{sizeof(Parameters),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
    if(FAILED(device->CreateBuffer(&desc,nullptr,&parameters_)))return false;
    desc.ByteWidth=4304;if(FAILED(device->CreateBuffer(&desc,nullptr,&previous_)))return false;
    const std::array<float,64> zero{};D3D11_SUBRESOURCE_DATA initial{zero.data()};
    desc.ByteWidth=256;
    if(FAILED(device->CreateBuffer(&desc,&initial,&zero_clock_))
        ||FAILED(device->CreateBuffer(&desc,&initial,&previous_clock_)))return false;
    desc={64,D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_UNORDERED_ACCESS,
        0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
    if(FAILED(device->CreateBuffer(&desc,nullptr,&shadow_data_))
        ||FAILED(device->CreateShaderResourceView(shadow_data_.Get(),nullptr,&shadow_data_view_))
        ||FAILED(device->CreateUnorderedAccessView(shadow_data_.Get(),nullptr,&shadow_data_output_)))return false;
    D3D11_SAMPLER_DESC sampler{};sampler.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    sampler.AddressU=sampler.AddressV=sampler.AddressW=D3D11_TEXTURE_ADDRESS_WRAP;sampler.MaxLOD=D3D11_FLOAT32_MAX;
    if(FAILED(device->CreateSamplerState(&sampler,&wrap_)))return false;
    sampler.AddressU=sampler.AddressV=sampler.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;
    if(FAILED(device->CreateSamplerState(&sampler,&clamp_)))return false;
    D3D11_BLEND_DESC blend{};
    blend.RenderTarget[0]={TRUE,D3D11_BLEND_ONE,D3D11_BLEND_INV_SRC_ALPHA,D3D11_BLEND_OP_ADD,
        D3D11_BLEND_ZERO,D3D11_BLEND_ONE,D3D11_BLEND_OP_ADD,D3D11_COLOR_WRITE_ENABLE_RED|D3D11_COLOR_WRITE_ENABLE_GREEN|D3D11_COLOR_WRITE_ENABLE_BLUE};
    if(FAILED(device->CreateBlendState(&blend,&blend_)))return false;
    D3D11_DEPTH_STENCIL_DESC depth{};depth.DepthEnable=FALSE;depth.StencilEnable=FALSE;
    if(FAILED(device->CreateDepthStencilState(&depth,&depth_state_)))return false;
    D3D11_RASTERIZER_DESC raster{};raster.FillMode=D3D11_FILL_SOLID;raster.CullMode=D3D11_CULL_NONE;raster.DepthClipEnable=TRUE;
    if(FAILED(device->CreateRasterizerState(&raster,&raster_)))return false;
    ready_=true;return true;
  }
  struct Buffer {
    ComPtr<ID3D11Texture2D> texture;
    ComPtr<ID3D11ShaderResourceView> view;
    ComPtr<ID3D11UnorderedAccessView> uav;
  };
  std::array<Buffer,7> buffers_;
  ComPtr<ID3DDeviceContextState> state_;
  ComPtr<ID3D11ComputeShader> noise_shader_,trace_,resolve_,motion_,shadow_;
  ComPtr<ID3D11VertexShader> vertex_;
  ComPtr<ID3D11PixelShader> composite_;
  ComPtr<ID3D11Buffer> parameters_,previous_,zero_clock_,previous_clock_;
  ComPtr<ID3D11SamplerState> wrap_,clamp_;
  ComPtr<ID3D11Texture3D> noise_;
  ComPtr<ID3D11ShaderResourceView> noise_view_;
  ComPtr<ID3D11UnorderedAccessView> noise_uav_;
  ComPtr<ID3D11BlendState> blend_;
  ComPtr<ID3D11DepthStencilState> depth_state_;
  ComPtr<ID3D11RasterizerState> raster_;
  ComPtr<ID3D11Texture2D> motion_texture_,responsive_texture_;
  ComPtr<ID3D11UnorderedAccessView> motion_uav_,responsive_uav_;
  ComPtr<ID3D11Texture2D> shadow_texture_;
  ComPtr<ID3D11ShaderResourceView> shadow_view_,shadow_data_view_;
  ComPtr<ID3D11UnorderedAccessView> shadow_output_,shadow_data_output_;
  ComPtr<ID3D11Buffer> shadow_data_;
  UINT shadow_size_=0;
  uint64_t shadow_frame_=UINT64_MAX;
  bool ready_=false,noise_ready_=false;
  UINT noise_size_=0;
  UINT width_=0,height_=0,render_width_=0,render_height_=0,history_index_=2;
  std::array<unsigned,3> quality_{};
  std::array<float,4> appearance_{},atmosphere_{};
  uint64_t history_frame_=UINT64_MAX;
  uint64_t cut_frame_=UINT64_MAX;
};
}
