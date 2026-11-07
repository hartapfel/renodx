// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef REMASTERED_CLOUD_ALTITUDE
#define REMASTERED_CLOUD_ALTITUDE
static const float PlanetRadius = 6371000.f;
float CloudAltitude(float3 p) {
  // Stable evaluation of length(p + planet_center) - planet_radius.
  float z=PlanetRadius+p.z;
  float r=sqrt(dot(p.xy,p.xy)+z*z);
  return (dot(p.xy,p.xy)+p.z*(2.f*PlanetRadius+p.z))/(r+PlanetRadius);
}
#endif
