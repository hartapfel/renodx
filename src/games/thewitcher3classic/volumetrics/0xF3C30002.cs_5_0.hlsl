// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "math.hlsli"
cbuffer Frame : register(b0) { float4 frame[269]; }
cbuffer Parameters : register(b2) { float4 grid; float4 medium; float4 options; }
Texture3D<float4> cells : register(t0);
RWTexture3D<float4> integrated : register(u0);
[numthreads(8,8,1)]
void main(uint2 id : SV_DispatchThreadID) {
  if (any(id >= (uint2)grid.xy)) return;
  float3 scattering = 0.f;
  float transmittance = 1.f;
  integrated[uint3(id,0)] = float4(0,0,0,1);
  float previous = options.y;
  float far_distance = max(grid.w, frame[42].z);
  [loop] for (uint z=0; z<(uint)grid.z; ++z) {
    float end = SliceDistance(z+1.f,grid.z,options.y,far_distance);
    float4 cell = cells.Load(int4(id,z,0));
    float opacity = SegmentOpacity(cell.w*(end-previous));
    scattering += transmittance*cell.xyz*(cell.w>1.e-8f ? opacity/cell.w : end-previous);
    transmittance *= 1.f-opacity;
    integrated[uint3(id,z+1)] = float4(min(scattering,60000.f),transmittance);
    previous = end;
  }
}
