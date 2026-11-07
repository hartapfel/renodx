// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// View-frustum sky-air LUT: 128x64 angular cells and 32 depth planes.
// Alpha stores native foreground-air transmission T(d). RGB stores the
// disc-free native broad sky used by the small sun-footprint correction.
#include "air.hlsli"
RWTexture3D<float4> sky_air_output : register(u0);
[numthreads(8,8,8)] void main(uint3 id:SV_DispatchThreadID) {
  if(any(id>=uint3(128,64,32)))return;
  float2 uv=(id.xy+.5f)/float2(128,64);
  float depth=max(frame[42].z,0.f)*id.z/31.f;
  float3 ray=CloudRay(uv);
  float transmission=CloudAirTransmission(ray,depth);
  sky_air_output[id]=float4(CloudSky(ray),transmission);
}
