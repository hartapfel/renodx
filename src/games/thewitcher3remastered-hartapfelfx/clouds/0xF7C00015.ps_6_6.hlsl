// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "native_atlas.hlsli"
#include "environment.hlsli"
Texture2D<float4> native_atlas:register(t0);
Texture2D<float4> clear_atlas:register(t1);
Texture2D<float4> clouds:register(t2);
ByteAddressBuffer atlas_metadata:register(t3);
ByteAddressBuffer environment_header:register(t4);
SamplerState clamp_sampler:register(s1);
float4 main(float4 position:SV_Position):SV_Target {
  float2 uv=position.xy/float2(256.f,256.f);
  float4 native=GraphicsNativeCloudAtlas(native_atlas,clamp_sampler,uv);
  uint4 identity=environment_header.Load4(0);
  if(any(identity.xyz!=uint3(0x57334345u,256u,128u)))return native;
  float3 center=asfloat(environment_header.Load3(16));
  float4 old_weather=asfloat(environment_header.Load4(32));
  float4 old_layers=asfloat(environment_header.Load4(48));
  float4 opacity=asfloat(environment_header.Load4(64));
  float4 environment_wind=asfloat(environment_header.Load4(128));
  if(any(!isfinite(center))||any(!isfinite(old_weather))||any(!isfinite(old_layers))
      ||any(!isfinite(opacity))||any(!isfinite(environment_wind))
      ||opacity.x<=0.f||opacity.y<=0.f)return native;
  float3 camera=asfloat(atlas_metadata.Load3(0));
  float4 weather=asfloat(atlas_metadata.Load4(32));
  float4 layers=asfloat(atlas_metadata.Load4(48));
  uint4 wind=atlas_metadata.Load4(64);
  if(any(!isfinite(camera))||any(!isfinite(weather))||any(!isfinite(layers))
      ||length(camera-center)>5.f||abs(weather.x-old_weather.x)>.01f*max(abs(weather.x),.001f)
      ||abs(weather.w-old_weather.w)>=.1f||any(layers.xy!=old_layers.xy)
      ||length(asfloat(wind).xy-environment_wind.xy)>2.f)return native;
  [unroll]for(uint face=0u;face<6u;++face) {
    uint offset=face*80u;
    if(any(atlas_metadata.Load4(offset+16u)!=uint4(0x57334341u,face,identity.w,0u))
        ||any(atlas_metadata.Load3(offset)!=asuint(camera))
        ||any(asfloat(atlas_metadata.Load4(offset+32u))!=weather)
        ||any(asfloat(atlas_metadata.Load4(offset+48u))!=layers)
        ||any(atlas_metadata.Load4(offset+64u)!=wind))return native;
  }
  float2 xy=uv*2.f-1.f;
  float3 direction=normalize(float3(xy,1.f-.5f*abs(xy.x-xy.y)-.5f*abs(xy.x+xy.y)));
  float2 location=CloudEnvironmentUV(direction)*float2(256.f,128.f)-.5f;
  int2 cell=int2(floor(location));
  float2 blend=frac(location);
  float4 c00=clouds.Load(int3((cell.x+256)&255,clamp(cell.y,0,127),0));
  float4 c10=clouds.Load(int3((cell.x+257)&255,clamp(cell.y,0,127),0));
  float4 c01=clouds.Load(int3((cell.x+256)&255,clamp(cell.y+1,0,127),0));
  float4 c11=clouds.Load(int3((cell.x+257)&255,clamp(cell.y+1,0,127),0));
  float4 cloud=lerp(lerp(c00,c10,blend.x),lerp(c01,c11,blend.x),blend.y);
  if(any(!isfinite(cloud))||any(cloud.rgb<0.f)||cloud.a<0.f||cloud.a>1.f)return native;
  float3 sky=GraphicsNativeCloudAtlas(clear_atlas,clamp_sampler,uv).rgb;
  return float4(cloud.rgb+cloud.a*sky,1.f);
}
