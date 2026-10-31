/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <cmath>
#include "pipeline.hpp"
#include "../water/pipeline.hpp"
#include "../water/reflections.hpp"
#include "../water/underwater.hpp"
#include "../water/camera.hpp"
#include "../../../utils/data.hpp"
namespace witcher3classic::volumetrics {
struct __declspec(uuid("08d5a440-5e33-4e83-bd75-2cd02e204a40")) DeviceData {
  Pipeline pipeline;
  water::Pipeline water_pipeline;
  water::Reflections reflections;
  water::Underwater underwater;
  water::Camera camera;
  uint64_t underwater_composite_frame=UINT64_MAX;
  ComPtr<ID3D11DeviceContext1> context;
  uint64_t native_handle=0, frame=0;
  bool logged=false,logged_reflections=false;
};
inline void OnInit(reshade::api::device* device) { renodx::utils::data::Create<DeviceData>(device); }
inline void OnDestroy(reshade::api::device* device) {
  auto* data=renodx::utils::data::Get<DeviceData>(device);
  if (data && data->context) {
    data->reflections.Restore(data->context.Get());
    data->water_pipeline.Restore(data->context.Get());
    data->underwater.Restore(data->context.Get());
    data->pipeline.Restore(data->context.Get());
  }
  renodx::utils::data::Delete<DeviceData>(device);
}
inline void OnPresent(reshade::api::command_queue*,reshade::api::swapchain* swapchain,
                      const reshade::api::rect*,const reshade::api::rect*,uint32_t,const reshade::api::rect*) {
  auto* data=renodx::utils::data::Get<DeviceData>(swapchain->get_device());
  if (!data) return;
  if (data->context) { data->reflections.Restore(data->context.Get()); data->water_pipeline.Restore(data->context.Get()); data->pipeline.Restore(data->context.Get()); }
  if(data->context)data->underwater.Restore(data->context.Get());
  if(water::mode==0.f)data->reflections.Invalidate();
  ++data->frame;
}
inline bool OnUnderwaterPrepare(reshade::api::command_list* cmd) {
  if(water::mode==0.f ||cmd->get_device()->get_api()!=reshade::api::device_api::d3d11)return false;
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if(!data)return false;
  if(!data->context ||data->native_handle!=cmd->get_native()) {
    auto* native=reinterpret_cast<ID3D11DeviceContext*>(cmd->get_native());
    renodx::utils::directx::NativeFromReShadeProxy(&native);
    if(native->GetType()!=D3D11_DEVICE_CONTEXT_IMMEDIATE)return false;
    if(data->context) {
      data->reflections.Restore(data->context.Get());data->water_pipeline.Restore(data->context.Get());
      data->pipeline.Restore(data->context.Get());data->underwater.Restore(data->context.Get());
    }
    data->underwater.captured_frame=UINT64_MAX;
    data->underwater.prepared_frame=UINT64_MAX;
    data->context.Reset();if(FAILED(native->QueryInterface(IID_PPV_ARGS(&data->context))))return false;
    data->native_handle=cmd->get_native();
  }
  ComPtr<ID3D11Buffer> frame,lighting;ComPtr<ID3D11ShaderResourceView> shadow;
  UINT offset=0,count=0;
  data->context->PSGetConstantBuffers1(12,1,&frame,&offset,&count);if(offset)return false;
  data->context->PSGetConstantBuffers1(13,1,&lighting,&offset,&count);if(offset)return false;
  data->context->PSGetShaderResources(8,1,&shadow);
  data->underwater.Prepare(data->context.Get(),frame.Get(),lighting.Get(),shadow.Get(),data->frame,
      {{.03f*std::clamp(water::underwater_density,0.f,4.f),.5f,1.f,0},
       {std::clamp(water::underwater_quality,1.f,4.f),std::clamp(water::caustics,0.f,2.f),1.f,0}});
  return false;
}
inline bool OnUnderwaterLighting(reshade::api::command_list* cmd) {
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  return water::mode!=0.f && data && data->context &&data->native_handle==cmd->get_native()
      &&data->underwater.Bind(data->context.Get(),data->frame,true);
}
inline bool OnUnderwater(reshade::api::command_list* cmd) {
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if(water::mode!=0.f &&data &&data->context &&data->native_handle==cmd->get_native())
    data->underwater.Bind(data->context.Get(),data->frame);
  return false;
}
inline bool OnFog(reshade::api::command_list* cmd) {
  if ((mode==0.f && water::mode==0.f) || cmd->get_device()->get_api()!=reshade::api::device_api::d3d11) return false;
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if (!data) return false;
  if (!data->context || data->native_handle!=cmd->get_native()) {
    auto* native=reinterpret_cast<ID3D11DeviceContext*>(cmd->get_native());
    renodx::utils::directx::NativeFromReShadeProxy(&native);
    if (native->GetType()!=D3D11_DEVICE_CONTEXT_IMMEDIATE) return false;
    if (data->context) {
      data->water_pipeline.Restore(data->context.Get());
      data->pipeline.Restore(data->context.Get());
      data->underwater.Restore(data->context.Get());
    }
    data->underwater.captured_frame=data->underwater.prepared_frame=UINT64_MAX;
    data->reflections.Invalidate();
    data->water_pipeline.captured_frame=UINT64_MAX;
    data->pipeline.generated_frame=UINT64_MAX;
    data->context.Reset();
    if (FAILED(native->QueryInterface(IID_PPV_ARGS(&data->context)))) return false;
    data->native_handle=cmd->get_native();
  }
  auto* context=data->context.Get();
  data->water_pipeline.Restore(context);
  data->pipeline.Restore(context);
  OnUnderwater(cmd);
  // This is the audited main atmospheric fog pass. Native b12/b13 remain
  // untouched; no shader-injection cbuffer is installed for these replacements.
  D3D11_VIEWPORT viewport; UINT count=1;
  context->RSGetViewports(&count,&viewport);
  if (count!=1 || viewport.TopLeftX!=0 || viewport.TopLeftY!=0 || viewport.Width<320 || viewport.Height<180) return false;
  ComPtr<ID3D11Buffer> frame,lighting;
  UINT frame_offset=0, frame_count=0, light_offset=0, light_count=0;
  context->PSGetConstantBuffers1(12,1,&frame,&frame_offset,&frame_count);
  context->PSGetConstantBuffers1(13,1,&lighting,&light_offset,&light_count);
  if (frame_offset || light_offset) return false;
  if (!frame || !lighting) return false;
  D3D11_BUFFER_DESC frame_desc,light_desc;
  frame->GetDesc(&frame_desc); lighting->GetDesc(&light_desc);
  if (frame_desc.ByteWidth!=4304 || light_desc.ByteWidth<704) return false;
  if (water::mode!=0.f) {
    ComPtr<ID3D11ShaderResourceView> scene;
    context->PSGetShaderResources(1,1,&scene);
    data->water_pipeline.Capture(context,scene.Get(),frame.Get(),UINT(viewport.Width),UINT(viewport.Height),data->frame);
  }
  if (mode==0.f) return false;
  ComPtr<ID3D11ShaderResourceView> shadow,cloud,terrain,interiors;
  context->PSGetShaderResources(8,1,&shadow);
  context->PSGetShaderResources(14,1,&cloud);
  context->PSGetShaderResources(19,1,&terrain);
  context->PSGetShaderResources(24,1,&interiors);
  ComPtr<ID3D11SamplerState> shadow_sampler;
  context->PSGetSamplers(9,1,&shadow_sampler);
  if (!shadow || !shadow_sampler) return false;
  D3D11_SAMPLER_DESC sampler_desc;
  shadow_sampler->GetDesc(&sampler_desc);
  if ((sampler_desc.Filter & D3D11_COMPARISON_FILTERING_BIT) == 0) return false;
  D3D11_SHADER_RESOURCE_VIEW_DESC desc;
  shadow->GetDesc(&desc);
  if (desc.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2DARRAY || desc.Texture2DArray.ArraySize<3) return false;
  if (cloud) { cloud->GetDesc(&desc); if (desc.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2DARRAY) cloud.Reset(); }
  if (terrain) { terrain->GetDesc(&desc); if (desc.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2DARRAY) terrain.Reset(); }
  if (interiors) {
    interiors->GetDesc(&desc);
    if (desc.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2D || desc.Format!=DXGI_FORMAT_R16G16_FLOAT) interiors.Reset();
  }
  ComPtr<ID3D11ShaderResourceView> local_tiles,local_atlas,local_cubes;
  ComPtr<ID3D11SamplerState> local_sampler;
  if (local_light_strength > 0.f && light_desc.ByteWidth >= 2362*16) {
    context->PSGetShaderResources(20,1,&local_tiles);
    context->PSGetShaderResources(9,1,&local_atlas);
    context->PSGetShaderResources(10,1,&local_cubes);
    context->PSGetSamplers(10,1,&local_sampler);
    if (local_tiles) {
      local_tiles->GetDesc(&desc);
      if (desc.ViewDimension != D3D11_SRV_DIMENSION_BUFFEREX
          || desc.Format != DXGI_FORMAT_R32_TYPELESS
          || (desc.BufferEx.Flags & D3D11_BUFFEREX_SRV_FLAG_RAW) == 0) local_tiles.Reset();
    }
    if (local_atlas) { local_atlas->GetDesc(&desc); if (desc.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2DARRAY) local_atlas.Reset(); }
    if (local_cubes) { local_cubes->GetDesc(&desc); if (desc.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURECUBEARRAY) local_cubes.Reset(); }
  }
  const Parameters parameters{
      VolumeGrid(resolution_quality,viewport.Height/viewport.Width),
      {std::clamp(density,0.f,4.f),std::clamp(start_distance,0.f,200.f),std::clamp(light_strength,0.f,4.f),std::clamp(anisotropy,0.f,.8f)},
      {std::clamp(height_falloff,0.f,4.f),.1f,cloud?1.f:0.f,terrain?1.f:0.f},
      {1.f/viewport.Width,1.f/viewport.Height,std::clamp(shadow_quality,1.f,4.f),local_tiles?std::clamp(local_light_strength,0.f,4.f):0.f},
      {std::clamp(sky_density,0.f,4.f),reconstruction!=0.f?1.f:0.f,renderer!=0.f?1.f:0.f,std::clamp(resolution_quality,1.f,4.f)}};
  ComPtr<ID3D11ShaderResourceView> depth;
  if(renderer!=0.f)context->PSGetShaderResources(0,1,&depth);
  if (data->pipeline.generated_frame!=data->frame
      && !data->pipeline.Generate(context,frame.Get(),lighting.Get(),shadow.Get(),cloud.Get(),terrain.Get(),parameters,data->frame,shadow_sampler.Get(),interiors.Get(),
          {local_tiles.Get(),local_atlas.Get(),local_cubes.Get(),local_sampler.Get()},depth.Get())) return false;
  data->pipeline.Bind(context,false,data->frame,true);
  if (!data->logged) {
    data->logged=true;
    reshade::log::message(reshade::log::level::info,"Witcher Classic: custom volumetric fog active with sun/moon and native tiled local-light inputs.");
  }
  return false;
}
inline bool OnForward(reshade::api::command_list* cmd) {
  OnUnderwater(cmd);
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if (mode!=0.f && data && data->context && data->native_handle==cmd->get_native())
    data->pipeline.Bind(data->context.Get(),false,data->frame);
  return false;
}
inline bool OnWater(reshade::api::command_list* cmd) {
  OnForward(cmd);
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if(water::mode!=0.f &&data &&data->context &&data->native_handle==cmd->get_native())
    data->underwater.Capture(data->context.Get(),data->frame);
  if(water::mode!=0.f && data && data->context && data->native_handle==cmd->get_native())
    data->water_pipeline.Bind(data->context.Get(),data->frame);
  return false;
}
inline bool OnParticle(reshade::api::command_list* cmd) {
  OnForward(cmd);
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if(water::mode!=0.f && data && data->context && data->native_handle==cmd->get_native())
    data->reflections.BindParticle(data->context.Get(),data->frame);
  return false;
}
inline bool OnReflectionTrace(reshade::api::command_list* cmd) {
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  return water::mode!=0.f && data && data->context && data->native_handle==cmd->get_native()
      && data->reflections.BindTrace(data->context.Get(),data->frame);
}
inline bool OnReflectionInput(reshade::api::command_list* cmd) {
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if(water::mode==0.f || !data || !data->context || data->native_handle!=cmd->get_native()
      || data->water_pipeline.captured_frame!=data->frame)return false;
  return data->reflections.Bind(data->context.Get(),data->water_pipeline.FrameView(),
      data->water_pipeline.Width(),data->water_pipeline.Height(),data->frame);
}
inline void OnReflectionInputDrawn(reshade::api::command_list* cmd) {
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if(data && data->context)data->reflections.Restore(data->context.Get(),true);
}
inline bool OnReflectionCapture(reshade::api::command_list* cmd) {
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if(water::mode==0.f || !data || !data->context || data->native_handle!=cmd->get_native()
      || data->water_pipeline.captured_frame!=data->frame)return true;
  ComPtr<ID3D11ShaderResourceView> source;data->context->PSGetShaderResources(0,1,&source);
  if(data->reflections.Capture(data->context.Get(),source.Get(),data->water_pipeline.FrameView(),data->frame)
      && !data->logged_reflections) {
    data->logged_reflections=true;
    reshade::log::message(reshade::log::level::info,
        "Witcher Classic: raw HDR including late particles captured for next-frame native water SSR.");
  }
  return true;
}
inline void OnDrawn(reshade::api::command_list* cmd) {
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if (data && data->context) { data->reflections.Restore(data->context.Get()); data->water_pipeline.Restore(data->context.Get()); data->pipeline.Restore(data->context.Get()); }
  if(data &&data->context)data->underwater.Restore(data->context.Get());
}
}  // namespace witcher3classic::volumetrics
