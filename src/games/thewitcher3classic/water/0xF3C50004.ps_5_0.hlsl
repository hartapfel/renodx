// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Normalized tent-kernel CDF. Exact pixel integrals retain
// photon energy under subpixel motion, including completely collapsed caustics.
float2 PhotonIntegral(float2 x,float2 radius) {
  x=clamp(x/radius,-1.f,1.f);
  return float2(x.x<0.f ? .5f*(1.f+x.x)*(1.f+x.x):1.f-.5f*(1.f-x.x)*(1.f-x.x),
      x.y<0.f ? .5f*(1.f+x.y)*(1.f+x.y):1.f-.5f*(1.f-x.y)*(1.f-x.y));
}
float main(float4 position:SV_Position,nointerpolation float3 photon:TEXCOORD0,
    nointerpolation float2 radius:TEXCOORD1):SV_Target {
  float2 offset=position.xy-photon.xy;
  float2 weight=PhotonIntegral(offset+.5f,radius)-PhotonIntegral(offset-.5f,radius);
  return photon.z*weight.x*weight.y;
}
