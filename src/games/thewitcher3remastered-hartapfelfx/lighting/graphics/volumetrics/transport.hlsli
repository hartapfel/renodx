/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#ifndef WITCHER_REMASTERED_FOG_TRANSPORT
#define WITCHER_REMASTERED_FOG_TRANSPORT

// These resource-independent kernels are shared with the implemented Classic
// medium. Keep the reciprocal-height profile and small-optical-depth behavior
// consistent as the grid, clouds and water adapters are added.
#include "../reference/classic/volumetrics/math.hlsli"

// Compensate for rounding in 1+x. Dividing log(1+x) by the rounded increment
// avoids magnifying that rounding by 1/x in almost uniform height profiles.
// Callers integrate from the lower altitude, so x is always nonnegative.
float FogPositiveLog1pOverX(float x) {
  if(x<.001f)return 1.f-x*(.5f-x/3.f);
  precise float sum=1.f+x;
  precise float increment=sum-1.f;
  return log(sum)/increment;
}

float FogOpticalDepth(float height, float ray_z, float density, float falloff, float distance) {
  density = max(density, 0.f);
  falloff = max(falloff, 0.f);
  distance = max(distance, 0.f);
  float end_height = height + ray_z * distance;
  float column;
  if (max(height, end_height) <= 0.f || falloff == 0.f) {
    column = distance;
  } else if (min(height, end_height) >= 0.f) {
    float local_density = FogHeightDensity(min(height,end_height), falloff);
    column = distance * local_density * FogPositiveLog1pOverX(abs(ray_z) * distance * falloff * local_density);
  } else {
    float positive=max(height,end_height);
    column = (positive*FogPositiveLog1pOverX(positive*falloff)-min(height,end_height))/abs(ray_z);
  }
  // Work in optical depth to retain sparse fog that 1-exp(-tau) would round
  // to zero. Weather's opacity exponent and distance fade are applied later.
  return density * clamp(column, 0.f, distance);
}
float FogDensityOpacity(float height, float ray_z, float density, float falloff, float distance) {
  return saturate(SegmentOpacity(FogOpticalDepth(height, ray_z, density, falloff, distance)));
}
#endif
