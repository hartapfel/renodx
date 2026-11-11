// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFELFX_FOG_SAMPLE
#define HARTAPFELFX_FOG_SAMPLE
#include "../shared.h"
#include "math.hlsli"
ByteAddressBuffer FogVolume : register(t0, space71);
bool IndependentVolumeLight() { return FogVolume.Load(1052) == FOG_LIGHT_VALID; }
float SampleFogExtinction(float2 coordinate, int z, uint3 size) {
  int2 cell=int2(floor(coordinate));
  float2 f=frac(coordinate);
  uint offset=FOG_HEADER_BYTES+size.x*size.y*(3u*size.z+1u)*8u;
  float values[4];
  [unroll]for(uint i=0u;i<4u;++i) {
    int2 xy=clamp(cell+int2(i&1u,i>>1u),0,int2(size.xy)-1);
    values[i]=asfloat(FogVolume.Load(offset+((z*size.y+xy.y)*size.x+xy.x)*4u));
  }
  return lerp(lerp(values[0],values[1],f.x),lerp(values[2],values[3],f.x),f.y);
}
float4 LoadFogVolume(int3 cell, uint3 size, uint offset,bool medium=false) {
  cell = clamp(cell, 0, int3(size) - 1);
  uint2 bits = FogVolume.Load2(offset + ((cell.z * size.y + cell.y) * size.x + cell.x) * 8);
  float4 value=f16tof32(uint4(bits & 65535u, bits >> 16));
  // Decode the sparse-source normalization before filtering coefficients.
  // Filtering encoded incident light and density separately darkens vacuum edges.
  if(medium)value.rgb*=value.a/max(value.a,FogSourceFloor);
  return value;
}
float4 SampleFogLayer(float2 coordinate,int z,uint3 size,uint offset,bool medium=false) {
  int3 cell=int3(int2(floor(coordinate)),z);
  float2 f=frac(coordinate);
  float4 a = lerp(LoadFogVolume(cell, size, offset,medium), LoadFogVolume(cell + int3(1, 0, 0), size, offset,medium), f.x);
  float4 b = lerp(LoadFogVolume(cell + int3(0, 1, 0), size, offset,medium), LoadFogVolume(cell + int3(1, 1, 0), size, offset,medium), f.x);
  return lerp(a,b,f.y);
}
float4 SampleFogLinear(float3 coordinate, uint3 size, uint offset) {
  int z=int(floor(coordinate.z));
  return lerp(SampleFogLayer(coordinate.xy,z,size,offset),SampleFogLayer(coordinate.xy,z+1,size,offset),frac(coordinate.z));
}
// Integrate the resolved incident lighting along this exact receiver ray.
// Shadows remain shared: per-pixel integration does not create new shadow detail.
float4 IntegrateFogRay(float2 pixel,float distance,float4 grid,float4 sampling) {
  uint3 size=uint3(grid.xyz);
  uint resolved=FOG_HEADER_BYTES+size.x*size.y*size.z*8u;
  float2 xy=pixel*sampling.xy*grid.xy-.5f;
  float4 profile=asfloat(FogVolume.Load4(64+42*16));
  float4 curve=asfloat(FogVolume.Load4(32));
  float start=FogFadeStart(asfloat(FogVolume.Load(64+22*16+8)));
  float begin=sampling.z,tau=0.f,light_tau=0.f,opacity=0.f;
  float3 scattering=0.f;
  float ratio=pow(grid.w/sampling.z,rcp(grid.z));
  float slice_end=begin*ratio;
  [loop]for(uint z=0u;z<size.z &&begin<distance;++z) {
    float end=min(distance,slice_end);
    float4 cell=SampleFogLayer(xy,int(z),size,resolved,true);
    float fog_extinction=IndependentVolumeLight()?SampleFogExtinction(xy,int(z),size):cell.a;
    tau+=fog_extinction*(end-begin);
    float next=pow(max(SegmentOpacity(tau),0.f),max(profile.w,.0001f))
        *saturate((max(end-start,0.f)-curve.y)*curve.z);
    float gain=cell.a>0.f?max(0.f,next-opacity):0.f;
    if(IndependentVolumeLight()) {
      gain=exp(-light_tau)*SegmentOpacity(cell.a*(end-begin));
      light_tau+=cell.a*(end-begin);
    }
    scattering+=cell.rgb*(gain/max(cell.a,1.e-20f));
    opacity=IndependentVolumeLight()?next:opacity+gain;
    begin=slice_end;slice_end*=ratio;
  }
  return float4(min(scattering,60000.f),opacity);
}
float4 SampleFogVolume(float2 pixel, float distance) {
  float4 grid = asfloat(FogVolume.Load4(0));
  float4 sampling = asfloat(FogVolume.Load4(16));
  if (distance <= sampling.z) return 0.f;
  if(fx.enabled>.5f &&fx.quality_preset>4.5f)return IntegrateFogRay(pixel,min(distance,grid.w),grid,sampling);
  float3 coordinate = float3(pixel * sampling.xy * grid.xy - .5f,
                             saturate(log(max(distance, sampling.z) / sampling.z) / log(grid.w / sampling.z)) * grid.z);
  uint3 size = uint3(grid.xyz) + uint3(0, 0, 1);
  uint offset = (uint)sampling.w;
  float4 linear_sample = SampleFogLinear(coordinate, size, offset);
  if (IndependentVolumeLight() &&asfloat(FogVolume.Load(1024))>.5f ? asfloat(FogVolume.Load(1040)) < 1.5f : fx.reconstruction <= .5f) return linear_sample;
  float3 base = floor(coordinate), t = frac(coordinate);
  float3 w0 = (1.f - t) * (1.f - t) * (1.f - t) / 6.f;
  float3 w1 = (3.f * t * t * t - 6.f * t * t + 4.f) / 6.f;
  float3 w2 = (-3.f * t * t * t + 3.f * t * t + 3.f * t + 1.f) / 6.f;
  float3 w3 = t * t * t / 6.f;
  float3 first = base - 1.f + w1 / (w0 + w1);
  float3 second = base + 1.f + w3 / (w2 + w3);
  float3 weight = w2 + w3;
  float3 a = lerp(SampleFogLinear(float3(first.x, first.y, first.z), size, offset).rgb,
                  SampleFogLinear(float3(second.x, first.y, first.z), size, offset).rgb, weight.x);
  float3 b = lerp(SampleFogLinear(float3(first.x, second.y, first.z), size, offset).rgb,
                  SampleFogLinear(float3(second.x, second.y, first.z), size, offset).rgb, weight.x);
  float3 c = lerp(SampleFogLinear(float3(first.x, first.y, second.z), size, offset).rgb,
                  SampleFogLinear(float3(second.x, first.y, second.z), size, offset).rgb, weight.x);
  float3 d = lerp(SampleFogLinear(float3(first.x, second.y, second.z), size, offset).rgb,
                  SampleFogLinear(float3(second.x, second.y, second.z), size, offset).rgb, weight.x);
  return float4(lerp(lerp(a, b, weight.y), lerp(c, d, weight.y), weight.z), linear_sample.a);
}
#endif
