// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_ENVIRONMENT
#define HARTAPFEL_CLOUD_ENVIRONMENT
// Full-sphere longitude/latitude map. Longitude wraps, while texel centers
// exclude the poles so latitude can clamp without an undefined pole direction.
float3 CloudEnvironmentDirection(float2 uv) {
  float longitude=uv.x*6.28318530718f;
  float latitude=uv.y*3.14159265359f;
  float sine=sin(latitude);
  return float3(cos(longitude)*sine,sin(longitude)*sine,cos(latitude));
}
float2 CloudEnvironmentUV(float3 direction) {
  direction=normalize(direction);
  return float2(frac(atan2(direction.y,direction.x)*.15915494309f),
      acos(clamp(direction.z,-1.f,1.f))*.31830988618f);
}
#endif
