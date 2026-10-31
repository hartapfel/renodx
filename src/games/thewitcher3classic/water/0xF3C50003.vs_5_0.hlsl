// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "underwater_inputs.hlsli"
StructuredBuffer<float4> Photons : register(t86);
struct Output {
  float4 position:SV_Position;
  nointerpolation float3 photon:TEXCOORD0;
  nointerpolation float2 radius:TEXCOORD1;
  float4 clip:SV_ClipDistance;
};
Output main(uint vertex:SV_VertexID,uint layer:SV_InstanceID) {
  uint cell=vertex/6u,corner=vertex%6u;
  uint index=layer*CLASSIC_CAUSTIC_VERTICES*CLASSIC_CAUSTIC_VERTICES+(cell/CLASSIC_CAUSTIC_GRID)*CLASSIC_CAUSTIC_VERTICES+cell%CLASSIC_CAUSTIC_GRID;
  float4 a=Photons[index],b=Photons[index+1u];
  float4 c=Photons[index+CLASSIC_CAUSTIC_VERTICES],d=Photons[index+(CLASSIC_CAUSTIC_VERTICES+1u)];
  float4 photon=(a+b+c+d)*.25f;
  float2 center=(photon.xy-UnderwaterState[5].xy)/UnderwaterState[5].z*float(CLASSIC_CAUSTIC_TILE);
  const float2 corners[6]={float2(-1,-1),float2(1,-1),float2(-1,1),float2(-1,1),float2(1,-1),float2(1,1)};
  // A finite photon footprint is integrated over every destination pixel. A
  // focused beam cannot disappear when a triangle misses all pixel centers.
  // Radius matches the source grid spacing; no intensity clamp loses flux.
  float2 dx=(b.xy-a.xy+d.xy-c.xy)*(.5f*float(CLASSIC_CAUSTIC_TILE)/UnderwaterState[5].z);
  float2 dy=(c.xy-a.xy+d.xy-b.xy)*(.5f*float(CLASSIC_CAUSTIC_TILE)/UnderwaterState[5].z);
  // Projected source-cell differentials widen stretched footprints, preventing
  // holes between sparse photons at depth. The minimum resolves focused beams.
  float2 radius=max(2.f,abs(dx)+abs(dy));
  float2 uv=(center+corners[corner]*(radius+.5f))/float(CLASSIC_CAUSTIC_TILE);
  float2 tile=float2(layer&1u,layer>>1u);
  Output result;
  result.position=float4((uv+tile)*float2(1,-1)+float2(-1,1),0,1);
  result.clip=float4(uv,1.f-uv);
  result.photon=float3(center+tile*float(CLASSIC_CAUSTIC_TILE),photon.z*4.f);
  result.radius=radius;
  return result;
}
