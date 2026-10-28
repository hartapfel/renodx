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
  float optical_depth = 0.f;
  float weather_opacity = 0.f;
  integrated[uint3(id,0)] = float4(0,0,0,1);
  float previous = options.y;
  float far_distance = max(grid.w, frame[42].z);
  [loop] for (uint z=0; z<(uint)grid.z; ++z) {
    float end = SliceDistance(z+1.f,grid.z,options.y,far_distance);
    float4 cell = cells.Load(int4(id,z,0));
    optical_depth += cell.w*(end-previous);
    // Native C8C78997 shapes 1-T with the weather's opacity exponent and
    // distance fade. Captured Velen weather uses an exponent near .5: omitting it makes
    // sparse fog several times too transparent. Apply the authored curve to
    // cumulative optical depth, then integrate each segment's opacity gain.
    // This preserves shadowed source weights and L/T consistency, rather
    // than changing only the final composite or scaling all fog radiance.
    float distance = max(0.f,end-max(medium.y,frame[22].z));
    float opacity = optical_depth > 0.f
        ? pow(SegmentOpacity(optical_depth),max(frame[42].w,.0001f))
            * saturate((distance-frame[48].y)*frame[48].z)
        : 0.f;
    // A vacuum/interior segment cannot add effective extinction merely
    // because the distance fade advances along it.
    float contribution = cell.w > 0.f ? max(0.f,opacity-weather_opacity) : 0.f;
    scattering += cell.w > 0.f ? cell.xyz*(contribution/cell.w) : 0.f;
    weather_opacity += contribution;
    transmittance = 1.f-weather_opacity;
    integrated[uint3(id,z+1)] = float4(min(scattering,60000.f),transmittance);
    previous = end;
  }
}
