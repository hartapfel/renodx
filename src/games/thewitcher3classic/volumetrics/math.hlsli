// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_CLASSIC_VOLUME_MATH
#define WITCHER_CLASSIC_VOLUME_MATH
// Analytic homogeneous-segment solution of the single-scattering equation.
// Accumulate scattering before updating transmittance (Hillaire, SIGGRAPH 2015).
float SegmentOpacity(float optical_depth) {
  // Avoid cancellation near a vacuum; the Taylor branch is continuous to FP32.
  return optical_depth < .001f
      ? optical_depth * (1.f - optical_depth * (.5f - optical_depth / 6.f))
      : 1.f - exp(-optical_depth);
}
float PhaseHG(float cosine, float g) {
  float denominator = max(1.f + g * g - 2.f * g * cosine, .0001f);
  return (1.f - g * g) / (12.566370614359f * denominator * sqrt(denominator));
}
// Logarithmic radial slices: distance is along the ray, not camera Z.
float SliceDistance(float slice, float count, float near_distance, float far_distance) {
  return near_distance * pow(far_distance / near_distance, slice / count);
}
// Native weather coefficients describe reciprocal height density, not an
// exponential height profile (Toussaint uses a particularly large offset).
float FogHeightDensity(float height, float falloff) {
  return rcp(1.f + max(height, 0.f) * falloff);
}
float FogLog1pOverX(float x) {
  bool small=abs(x)<.001f;
  return small ? 1.f-x*(.5f-x/3.f) : log(1.f+x)/(small ? 1.f : x);
}
// Integral of the reciprocal height profile along a directional-light ray.
// Incoming sunlight uses a finite local-medium path (1000 m in production),
// separate from the global atmosphere already represented by weather lighting.
float FogHeightPrimitive(float height, float falloff) {
  return min(height,0.f)+max(height,0.f)*FogLog1pOverX(max(height,0.f)*falloff);
}
float FogLightTransmittance(float height,float light_z,float density,float falloff,float distance) {
  density=max(density,0.f);falloff=max(falloff,0.f);distance=max(distance,0.f);
  float column;
  float end_height=height+light_z*distance;
  if(max(height,end_height)<=0.f || falloff==0.f) column=distance;
  else if(min(height,end_height)>=0.f) {
    // Evaluate the logarithmic ratio directly: subtracting two large
    // primitives loses precision for near-horizontal rays at high altitude.
    float local_density=FogHeightDensity(height,falloff);
    column=distance*local_density*FogLog1pOverX(light_z*distance*falloff*local_density);
  } else column=(FogHeightPrimitive(end_height,falloff)-FogHeightPrimitive(height,falloff))/(light_z==0.f ? 1.f : light_z);
  return exp(-density*clamp(column,0.f,distance));
}
#endif
