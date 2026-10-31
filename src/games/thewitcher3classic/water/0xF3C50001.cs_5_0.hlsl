// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "native_surface.hlsli"
#include "caustics_config.h"
#include "../night_sky.hlsli"
#include "transport.hlsli"
cbuffer CurrentFrame : register(b0) { float4 frame[269]; }
cbuffer CurrentLight : register(b1) { float4 light[49]; }
cbuffer Controls : register(b2) { float4 medium; float4 quality; }
StructuredBuffer<float4> PreviousWaterFrame : register(t89);
StructuredBuffer<float4> WaterMaterial : register(t98);
RWStructuredBuffer<float4> State : register(u0);
RWByteAddressBuffer Arguments : register(u1);
[numthreads(1,1,1)]
void main(uint3 id:SV_DispatchThreadID) {
  float elevation=NativeWaterElevation(frame[0].xy);
  float bottom=NativeWaterBottom(frame[0].xy,WaterRanges[0].xy);
  float surface=NativeWaterWaveHeight(frame[0].xy,elevation,bottom);
  // Fully submerged cameras use the same optics all the way to the interface.
  // The native near-plane mask owns pixel coverage across the meniscus. Keep
  // preparation available just above it as well (its feather extends ~0.42 m),
  // rather than fading in native underwater tint/blur over the first metre.
  // A stale resource snapshot still cannot switch off native air fog.
  float weight=smoothstep(-.5f,0.f,surface-frame[0].z);
  float valid=length(frame[0].xyz-PreviousWaterFrame[0].xyz)<5.f ? 1.f:0.f;
  weight*=valid;
  float3 sun=normalize(light[0].xyz);
  // Use the region/weather-authored water color as a material input, not a
  // display tint. Beer-Lambert inversion interprets it at a 10-m reference
  // path; this is an explicit artistic calibration, not measured water data.
  float3 scattering,extinction;
  WaterMaterialCoefficients(WaterMaterial[13].yzw,medium.x,scattering,extinction);
  State[0]=float4(frame[0].xyz,weight*medium.z);
  State[1]=float4(sun,elevation);
  State[2]=float4(extinction,clamp(medium.y,0.f,.9f));
  State[3]=float4(scattering,valid);
  // Surface receivers are enabled independently of the camera immersion.
  State[4]=float4(max(WaterMaterial[11].rgb,0.f)*ClassicWaterAmbient(asuint(frame[38].w)),quality.z*valid*(1.f-weight));
  // Camera postprocessing starts only below the regional mean surface; leave
  // the meniscus itself to native per-pixel coverage.
  float camera_weight=weight*saturate(medium.z)*smoothstep(.05f,.4f,elevation-frame[0].z);
  State[5]=float4(floor(frame[0].xy/4.f)*4.f-32.f,64.f,camera_weight);
  State[6]=float4(.25f,2.f,8.f,32.f);
  State[7]=float4(0,0,quality.x,quality.y);
  bool active=(weight>0.f ||quality.z*valid>0.f) && sun.z>0.f;
  Arguments.Store3(0,active ? uint3((CLASSIC_CAUSTIC_VERTICES+7)/8,(CLASSIC_CAUSTIC_VERTICES+7)/8,4):uint3(0,0,0));
  Arguments.Store4(12,uint4(CLASSIC_CAUSTIC_GRID*CLASSIC_CAUSTIC_GRID*6,active?4u:0u,0,0));
}
