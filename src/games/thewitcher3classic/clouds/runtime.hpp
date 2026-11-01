/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <span>
#include "pipeline.hpp"
#include "../temporal/upscale_engine.hpp"
#include "../volumetrics/runtime.hpp"
#include "../../../utils/data.hpp"
namespace witcher3classic::clouds {
struct __declspec(uuid("ac8188e1-c528-4e7d-a67b-0c722c03ca55")) DeviceData {
  Pipeline pipeline;
  ComPtr<ID3D11DeviceContext1> context;
  ComPtr<ID3D11RenderTargetView> sky_target;
  ComPtr<ID3D11Buffer> sky_frame;
  D3D11_VIEWPORT sky_viewport{};
  uint64_t frame=0,rendered_frame=UINT64_MAX,attempted_frame=UINT64_MAX;
  UINT output_width=0,output_height=0;
  uint64_t shadow_frame=UINT64_MAX;
  std::array<std::array<ComPtr<ID3D11ShaderResourceView>,2>,3> saved_shadow;
  bool shadow_bound=false;
  std::array<ComPtr<ID3D11VertexShader>,4> native_vertices;
  ComPtr<ID3D11VertexShader> previous_vertex;
  bool logged=false;
  void RestoreVertex() {
    if(!previous_vertex ||!context)return;
    context->VSSetShader(previous_vertex.Get(),nullptr,0);previous_vertex.Reset();
  }
  void RestoreShadows() {
    RestoreVertex();
    if(!context ||!shadow_bound)return;
    auto owned=pipeline.ShadowViews();
    for(UINT stage=0;stage<3;++stage) {
      ID3D11ShaderResourceView* current[2]{};
      if(stage==0)context->PSGetShaderResources(126,2,current);
      else if(stage==1)context->VSGetShaderResources(126,2,current);
      else context->CSGetShaderResources(126,2,current);
      std::array<ComPtr<ID3D11ShaderResourceView>,2> retained;
      for(UINT i=0;i<2;++i) {
        retained[i].Attach(current[i]);
        if(current[i]==owned[i])current[i]=saved_shadow[stage][i].Get();
      }
      if(stage==0)context->PSSetShaderResources(126,2,current);
      else if(stage==1)context->VSSetShaderResources(126,2,current);
      else context->CSSetShaderResources(126,2,current);
      for(auto& view:saved_shadow[stage])view.Reset();
    }
    shadow_bound=false;
  }
};
inline void OnInit(reshade::api::device* device) {renodx::utils::data::Create<DeviceData>(device);}
inline void OnDestroy(reshade::api::device* device) {
  if(auto* data=renodx::utils::data::Get<DeviceData>(device))data->RestoreShadows();
  renodx::utils::data::Delete<DeviceData>(device);
}
inline void OnPresent(reshade::api::command_queue*,reshade::api::swapchain* swapchain,
    const reshade::api::rect*,const reshade::api::rect*,uint32_t,const reshade::api::rect*) {
  if(auto* data=renodx::utils::data::Get<DeviceData>(swapchain->get_device())) {
    data->RestoreShadows();
    ++data->frame;data->sky_target.Reset();data->sky_frame.Reset();
    const auto desc=swapchain->get_device()->get_resource_desc(swapchain->get_back_buffer(0));
    data->output_width=UINT(desc.texture.width);data->output_height=desc.texture.height;
    if(mode==0.f)data->pipeline.Invalidate();
  }
}
inline bool ShadowsReady(reshade::api::command_list* cmd) {
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if(mode==0.f ||!data ||!data->shadow_bound ||data->shadow_frame!=data->frame)return false;
  auto* native=reinterpret_cast<ID3D11DeviceContext*>(cmd->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&native);
  return data->context.Get()==native;
}
inline void BindNativeVertex(reshade::api::command_list* cmd,UINT index,std::span<const uint8_t> code) {
  if(!ShadowsReady(cmd))return;
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  data->RestoreVertex();
  if(!data->native_vertices[index]) {
    ComPtr<ID3D11Device> device;data->context->GetDevice(&device);
    if(FAILED(device->CreateVertexShader(code.data(),code.size(),nullptr,&data->native_vertices[index])))return;
  }
  data->context->VSGetShader(&data->previous_vertex,nullptr,nullptr);
  data->context->VSSetShader(data->native_vertices[index].Get(),nullptr,0);
}
inline void OnVertexDrawn(reshade::api::command_list* cmd) {
  if(auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device()))data->RestoreVertex();
}
inline bool PrepareShadows(reshade::api::command_list* cmd,bool vertex=false) {
  if(mode==0.f ||cmd->get_device()->get_api()!=reshade::api::device_api::d3d11)return true;
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());if(!data)return true;
  if(data->shadow_frame==data->frame)return true;
  auto* native=reinterpret_cast<ID3D11DeviceContext*>(cmd->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&native);
  if(native->GetType()!=D3D11_DEVICE_CONTEXT_IMMEDIATE)return true;
  if(!data->context &&FAILED(native->QueryInterface(IID_PPV_ARGS(&data->context))))return true;
  if(native!=data->context.Get())return true;
  D3D11_VIEWPORT viewport{};UINT count=1;native->RSGetViewports(&count,&viewport);
  const auto* primary=temporal::upscale_engine::active;
  if(primary &&primary->material_mip_bias==0.f)return true;
  if(count!=1 ||viewport.TopLeftX!=0 ||viewport.TopLeftY!=0
      ||viewport.Width!=float(primary ? primary->plan.width : data->output_width)
      ||viewport.Height!=float(primary ? primary->plan.height : data->output_height))return true;
  ComPtr<ID3D11Buffer> frame,lighting;ComPtr<ID3D11ShaderResourceView> weather;
  UINT offset=0,range=0;
  if(vertex) {
    data->context->VSGetConstantBuffers1(12,1,&frame,&offset,&range);if(offset)return true;
    data->context->VSGetConstantBuffers1(13,1,&lighting,&offset,&range);if(offset)return true;
    native->VSGetShaderResources(14,1,&weather);
  } else {
    data->context->PSGetConstantBuffers1(12,1,&frame,&offset,&range);if(offset)return true;
    data->context->PSGetConstantBuffers1(13,1,&lighting,&offset,&range);if(offset)return true;
    native->PSGetShaderResources(14,1,&weather);
  }
  if(!data->pipeline.PrepareShadow(data->context.Get(),frame.Get(),lighting.Get(),weather.Get(),data->frame,quality,shadows!=0.f))return true;
  auto views=data->pipeline.ShadowViews();
  ID3D11ShaderResourceView* previous[2]{};
  native->PSGetShaderResources(126,2,previous);
  for(UINT i=0;i<2;++i)data->saved_shadow[0][i].Attach(previous[i]);
  native->VSGetShaderResources(126,2,previous);
  for(UINT i=0;i<2;++i)data->saved_shadow[1][i].Attach(previous[i]);
  native->CSGetShaderResources(126,2,previous);
  for(UINT i=0;i<2;++i)data->saved_shadow[2][i].Attach(previous[i]);
  native->PSSetShaderResources(126,2,views.data());native->VSSetShaderResources(126,2,views.data());
  native->CSSetShaderResources(126,2,views.data());
  data->shadow_frame=data->frame;data->shadow_bound=true;
  return true;
}
inline bool OnSky(reshade::api::command_list* cmd) {
  if(mode==0.f ||cmd->get_device()->get_api()!=reshade::api::device_api::d3d11)return true;
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());if(!data)return true;
  auto* native=reinterpret_cast<ID3D11DeviceContext*>(cmd->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&native);
  if(native->GetType()!=D3D11_DEVICE_CONTEXT_IMMEDIATE)return true;
  if(!data->context &&FAILED(native->QueryInterface(IID_PPV_ARGS(&data->context))))return true;
  if(data->context.Get()!=native)return true;
  D3D11_VIEWPORT viewport{};UINT count=1;native->RSGetViewports(&count,&viewport);
  // Tiny sky probes and auxiliary subviews must never supply main-view history.
  if(count!=1 ||viewport.TopLeftX!=0 ||viewport.TopLeftY!=0 ||viewport.Width<320 ||viewport.Height<180)return true;
  const auto* primary=temporal::upscale_engine::active;
  if(primary &&primary->material_mip_bias==0.f)return true;
  if(viewport.Width!=float(primary ? primary->plan.width : data->output_width)
      ||viewport.Height!=float(primary ? primary->plan.height : data->output_height))return true;
  if(data->sky_target &&viewport.Width<data->sky_viewport.Width)return true;
  ComPtr<ID3D11RenderTargetView> target,other;
  ID3D11RenderTargetView* targets[2]{};native->OMGetRenderTargets(2,targets,nullptr);
  target.Attach(targets[0]);other.Attach(targets[1]);
  if(!target ||other)return true;
  UINT offset=0,range=0;ComPtr<ID3D11Buffer> frame;
  data->context->PSGetConstantBuffers1(12,1,&frame,&offset,&range);
  if(!frame ||offset)return true;
  D3D11_BUFFER_DESC desc{};frame->GetDesc(&desc);if(desc.ByteWidth!=4304)return true;
  data->sky_target=target;data->sky_frame=frame;data->sky_viewport=viewport;
  return true;
}
inline bool OnCloud(reshade::api::command_list* cmd) {
  if(mode==0.f)return true;
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if(!data ||!data->context ||!data->sky_target)return true;
  auto* native=reinterpret_cast<ID3D11DeviceContext*>(cmd->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&native);
  if(native!=data->context.Get())return true;
  D3D11_VIEWPORT viewport{};UINT count=1;native->RSGetViewports(&count,&viewport);
  if(count!=1 ||viewport.TopLeftX!=0 ||viewport.TopLeftY!=0
      ||viewport.Width!=data->sky_viewport.Width ||viewport.Height!=data->sky_viewport.Height)return true;
  ComPtr<ID3D11RenderTargetView> target;native->OMGetRenderTargets(1,&target,nullptr);
  if(target!=data->sky_target)return true;
  ComPtr<ID3D11Buffer> frame,lighting;UINT offset=0,range=0;
  data->context->PSGetConstantBuffers1(12,1,&frame,&offset,&range);
  if(frame!=data->sky_frame ||offset)return true;
  if(data->rendered_frame==data->frame)return false;
  if(data->attempted_frame==data->frame)return true;
  data->attempted_frame=data->frame;
  data->context->PSGetConstantBuffers1(13,1,&lighting,&offset,&range);if(offset)return true;
  ComPtr<ID3D11ShaderResourceView> weather,depth;
  native->PSGetShaderResources(14,1,&weather);native->PSGetShaderResources(15,1,&depth);
  auto* fog=renodx::utils::data::Get<volumetrics::DeviceData>(cmd->get_device());
  if(!data->pipeline.Render(data->context.Get(),frame.Get(),lighting.Get(),weather.Get(),depth.Get(),
      target.Get(),UINT(viewport.Width),UINT(viewport.Height),data->frame,quality,
      volumetrics::mode!=0.f &&fog &&fog->context.Get()==data->context.Get()
          &&fog->frame==data->frame ? &fog->pipeline : nullptr))return true;
  data->rendered_frame=data->frame;
  if(!data->logged) {
    data->logged=true;
    reshade::log::message(reshade::log::level::info,
        "Witcher Classic: volumetric clouds active; native weather, wind, sky and sun/moon lighting, wind-aware temporal reconstruction.");
  }
  return false;
}
inline void ApplyMotion(reshade::api::device* device,ID3D11DeviceContext1* context,
    ID3D11ShaderResourceView* depth,ID3D11Buffer* frame,ID3D11Texture2D* motion,ID3D11Texture2D* responsive,
    UINT width,UINT height) {
  if(mode==0.f)return;
  auto* data=renodx::utils::data::Get<DeviceData>(device);
  if(data &&data->context.Get()==context &&data->rendered_frame==data->frame)
    data->pipeline.ApplyMotion(context,depth,frame,motion,responsive,width,height,data->frame);
}
}
