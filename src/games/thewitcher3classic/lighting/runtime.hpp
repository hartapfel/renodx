/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <array>
#include <cstring>
#include <span>
#include <d3d11.h>
#include <wrl/client.h>
#include "../../../utils/data.hpp"
#include "../../../utils/directx.hpp"
#include "contact.hpp"
#include "player_fill.hpp"
#include "../temporal/runtime.hpp"
namespace witcher3classic::lighting {
using Microsoft::WRL::ComPtr;
inline float shading=1.f, ambient_ao=1.f, soft_shadows=1.f, contact_shadows=1.f;
inline float contact_length=.3f, sun_diameter=.15f;
struct __declspec(uuid("89301c2f-993e-4bd4-bafe-33b6c0650305")) DeviceData {
  ComPtr<ID3D11Buffer> parameters;
  ComPtr<ID3D11ShaderResourceView> view, previous;
  ComPtr<ID3D11DeviceContext> context;
  std::array<ComPtr<ID3D11PixelShader>,6> color_only;
  ComPtr<ID3D11PixelShader> previous_shader;
  std::array<float,12> uploaded{};
  bool bound=false, compute=false;
  ContactPipeline contact;
  ComPtr<ID3D11ShaderResourceView> previous_contact;
  bool contact_bound=false;
  uint64_t frame=0;
  void Restore() {
    if(contact_bound) {
      context->PSSetShaderResources(119,1,previous_contact.GetAddressOf());
      previous_contact.Reset();contact_bound=false;
    }
    if(previous_shader) {
      context->PSSetShader(previous_shader.Get(),nullptr,0);
      previous_shader.Reset();
    }
    if(!bound)return;
    if(compute)context->CSSetShaderResources(118,1,previous.GetAddressOf());
    else context->PSSetShaderResources(118,1,previous.GetAddressOf());
    previous.Reset();bound=false;
  }
};
inline void OnInit(reshade::api::device* device) {renodx::utils::data::Create<DeviceData>(device);}
inline void OnDestroy(reshade::api::device* device) {
  auto* data=renodx::utils::data::Get<DeviceData>(device);
  if(data)data->Restore();
  renodx::utils::data::Delete<DeviceData>(device);
}
inline void OnDrawn(reshade::api::command_list* cmd) {
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if(data)data->Restore();
}
inline void OnPresent(reshade::api::command_queue*,reshade::api::swapchain* swapchain,
                      const reshade::api::rect*,const reshade::api::rect*,uint32_t,const reshade::api::rect*) {
  if(auto* data=renodx::utils::data::Get<DeviceData>(swapchain->get_device())) {
    data->Restore();++data->frame;
  }
}
inline bool Bind(reshade::api::command_list* cmd,bool compute) {
  if(cmd->get_device()->get_api()!=reshade::api::device_api::d3d11)return false;
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if(!data)return false;
  data->Restore();
  auto* native=reinterpret_cast<ID3D11DeviceContext*>(cmd->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&native);
  if(native->GetType()!=D3D11_DEVICE_CONTEXT_IMMEDIATE)return false;
  data->context=native;
  ComPtr<ID3D11Device> device;native->GetDevice(&device);
  // Contact shadows execute in the native shadow mask at its actual viewport.
  // This is render resolution under DLSS, not the allocated texture size.
  D3D11_VIEWPORT viewport{};UINT count=1;native->RSGetViewports(&count,&viewport);
  const std::array<float,12> parameters{
      shading,ambient_ao,soft_shadows,contact_shadows!=0.f?contact_length:0.f,
      0.f,0.f,0.f, // Fill light is adjusted once in the native light table.
      0.f, // Reserved; retain the lighting buffer layout.
      sun_diameter,0.f,viewport.Width,viewport.Height};
  if(!data->parameters) {
    D3D11_BUFFER_DESC desc{sizeof(parameters),D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
    D3D11_SUBRESOURCE_DATA initial{parameters.data()};
    if(FAILED(device->CreateBuffer(&desc,&initial,&data->parameters)))return false;
    if(FAILED(device->CreateShaderResourceView(data->parameters.Get(),nullptr,&data->view))) {
      data->parameters.Reset();return false;
    }
    data->uploaded=parameters;
  } else if(data->uploaded!=parameters) {
    native->UpdateSubresource(data->parameters.Get(),0,nullptr,parameters.data(),0,0);
    data->uploaded=parameters;
  }
  data->compute=compute;
  if(compute) {
    native->CSGetShaderResources(118,1,&data->previous);
    native->CSSetShaderResources(118,1,data->view.GetAddressOf());
  } else {
    native->PSGetShaderResources(118,1,&data->previous);
    native->PSSetShaderResources(118,1,data->view.GetAddressOf());
  }
  data->bound=true;
  return true;
}
inline bool OnLighting(reshade::api::command_list* cmd) {
  return (shading!=0.f||ambient_ao!=0.f)&&Bind(cmd,true);
}
inline bool OnLocalLight(reshade::api::command_list* cmd) {
  return (shading!=0.f||ambient_ao!=0.f)&&Bind(cmd,false);
}
inline bool OnShadow(reshade::api::command_list* cmd) {
  if((soft_shadows==0.f&&contact_shadows==0.f)||!Bind(cmd,false))return false;
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  ID3D11ShaderResourceView* contact=nullptr;
  ComPtr<ID3D11DeviceContext1> context;
  if(contact_shadows!=0.f && SUCCEEDED(data->context.As(&context))) {
    auto* motion=renodx::utils::data::Get<temporal::DeviceData>(cmd->get_device());
    const bool valid_motion=motion && temporal::object_motion!=0.f && motion->objects.HasFrame(motion->frame);
    contact=data->contact.Generate(context.Get(),data->view.Get(),UINT(data->uploaded[10]),UINT(data->uploaded[11]),data->frame,
        valid_motion?motion->objects.surfaces[0].Get():nullptr,valid_motion?motion->objects.surfaces[1].Get():nullptr);
  }
  data->context->PSGetShaderResources(119,1,&data->previous_contact);
  data->context->PSSetShaderResources(119,1,&contact);data->contact_bound=true;
  return true;
}
inline bool OnHair(reshade::api::command_list* cmd) {
  return (soft_shadows!=0.f||ambient_ao!=0.f)&&Bind(cmd,false);
}
inline void BindColorOnly(reshade::api::command_list* cmd,UINT index,std::span<const uint8_t> code) {
  if(!Bind(cmd,false))return;
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if(!data->color_only[index]) {
    ComPtr<ID3D11Device> device;data->context->GetDevice(&device);
    if(FAILED(device->CreatePixelShader(code.data(),code.size(),nullptr,&data->color_only[index]))) {
      data->Restore();return;
    }
  }
  data->context->PSGetShader(&data->previous_shader,nullptr,nullptr);
  data->context->PSSetShader(data->color_only[index].Get(),nullptr,0);
}
}  // namespace witcher3classic::lighting
