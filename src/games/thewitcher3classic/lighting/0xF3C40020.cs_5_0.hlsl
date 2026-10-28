// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
Texture2D<float> depth_texture:register(t0);
Texture2D<float4> normal_texture:register(t1);
Texture2D<float4> material_texture:register(t2);
Texture2D<uint2> stencil_texture:register(t3);
Texture2D<float4> albedo_texture:register(t4);
cbuffer Frame:register(b12){float4 cb12[214];}
#include "contact.hlsli"
RWTexture2D<float2> packed_output:register(u0);
[numthreads(8,8,1)]
void main(uint3 id:SV_DispatchThreadID) {
  if(any(id.xy>=uint2(min(RenoLighting[2].zw,cb12[23].xy))))return;
  float raw=depth_texture.Load(int3(id.xy,0));
  uint material=(uint)(saturate(material_texture.Load(int3(id.xy,0)).w)*255.f+.5f);
  float depth=ContactSceneDepth(raw);
  float opacity=raw*cb12[22].x+cb12[22].y>=1.f ? 0.f
      : ContactOpacity(material,stencil_texture.Load(int3(id.xy,0)).y,depth,albedo_texture.Load(int3(id.xy,0)).w);
  uint3 normal=(uint3)round(saturate(normal_texture.Load(int3(id.xy,0)).xyz)*255.f);
  uint packed=(normal.x<<8)|(normal.y<<16)|(normal.z<<24)|(uint)round(opacity*255.f);
  packed_output[id.xy]=float2(depth,asfloat(packed));
}
