// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_WATER_VOLUME_SAMPLING
#define CLASSIC_WATER_VOLUME_SAMPLING
// Invert the normalized integral of exp(-rate*t) over a finite segment.
// Both eye and refracted sunlight paths contribute to rate. A negative rate
// places more samples near the far end (looking up toward the interface).
// Reflect that case to avoid exponent overflow; keep the cancellation limit.
// PBRT, Sampling Volume Scattering: exponential transmittance sampling.
float WaterOpticalDistance(float rate, float length, float mass, float u) {
  if(u<=0.f)return 0.f;
  if(u>=1.f)return length;
  float optical=abs(rate)*length;
  if(optical<.001f)return length*u;
  float quantile=-log(max(1.f-(rate<0.f?1.f-u:u)*mass,1.e-7f))/abs(rate);
  return clamp(rate<0.f?length-quantile:quantile,0.f,length);
}
#endif
