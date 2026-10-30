// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Separate opaque scattering from full-resolution native weather composition.
// Own compute samplers avoid collisions with forward material bindings.
#define CLASSIC_FOG_COMPUTE
#include "sample.hlsli"
Texture2D<float> SceneDepth : register(t0);
RWTexture2D<float4> Scattering : register(u0);
RWTexture2D<float> Endpoint : register(u1);
[numthreads(8,8,1)]
void main(uint3 id : SV_DispatchThreadID) {
  uint width,height;Scattering.GetDimensions(width,height);
  if(any(id.xy>=uint2(width,height)))return;
  uint2 pixel=id.xy;
  float depth=SceneDepth.Load(int3(pixel,0));
  [branch]if(depth*PixelFogFrame[22].x+PixelFogFrame[22].y>=1.f) {
    Scattering[pixel]=0.f;Endpoint[pixel]=-1.f;return;
  }
  float4 world=PixelFogFrame[210]*pixel.x+PixelFogFrame[211]*pixel.y
      +PixelFogFrame[212]*depth+PixelFogFrame[213];
  [branch]if(abs(world.w)<1.e-10f) {Scattering[pixel]=0.f;Endpoint[pixel]=-1.f;return;}
  float distance=length(world.xyz/world.w-PixelFogFrame[0].xyz);
  float2 uv=(float2(pixel)+.5f)*ClassicFogParameters[3].xy;
  Scattering[pixel]=float4(SampleClassicPixelFog(uv,distance).rgb,0.f);
  Endpoint[pixel]=distance;
}
