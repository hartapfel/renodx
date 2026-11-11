// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFELFX_WATER_OPTICS
#define HARTAPFELFX_WATER_OPTICS

float WaterMediumDensity(float murk, float regional_density) {
  // At the reference setting, typical daylight water attenuates nearby
  // characters as well as distant terrain. The regional response is retained.
  return .23f * clamp(murk, 0.f, 2.f) * lerp(.55f, 1.f, saturate(regional_density));
}

float3 WaterMediumRadiance(float3 shallow_tint, float3 medium_tint, float strength) {
  return (.14f * max(medium_tint, 0.f) + .34f * max(shallow_tint, 0.f)) * clamp(strength, 0.f, 10.f);
}

float3 WaterTransmittance(float distance, float density, float3 tint) {
  // Native RGB is an appearance input. Use its relative channel response to
  // shape the effective extinction and keep density independently adjustable.
  tint = max(tint, 0.f);
  const float peak = max(tint.r, max(tint.g, tint.b));
  const float3 relative_tint = peak > 1e-5f ? tint / peak : 1.f;
  const float3 extinction = density * (1.f + .65f * (1.f - relative_tint));
  return exp2(-1.442695f * extinction * min(max(distance, 0.f), 200.f));
}

static const float WaterIor = 1.333f;

float WaterColumnLength(float eye_depth_gap, float3 incident, float3 forward, float refracted_vertical) {
  const float vertical_depth = eye_depth_gap * saturate(-incident.z) / max(dot(incident, forward), .125f);
  return vertical_depth / max(-refracted_vertical, .125f);
}

// IOR is relative to the incident medium. Water to air uses its reciprocal.
float WaterFresnel(float cosine, float ior) {
  cosine = saturate(cosine);
  const float transmitted_cosine_sq = 1.f - (1.f - cosine * cosine) / (ior * ior);
  if (transmitted_cosine_sq <= 0.f) return 1.f;
  const float transmitted_cosine = sqrt(transmitted_cosine_sq);
  const float s = (cosine - ior * transmitted_cosine) / (cosine + ior * transmitted_cosine);
  const float p = (ior * cosine - transmitted_cosine) / (ior * cosine + transmitted_cosine);
  return .5f * (s * s + p * p);
}

static const float WaterCriticalCosine = sqrt(1.f - rcp(WaterIor * WaterIor));

// Approximate the unresolved slope distribution with a continuous critical
// transition. The same effective cosine drives Fresnel and Snell refraction.
float WaterExitCosine(float cosine, float spread) {
  const float delta = cosine - WaterCriticalCosine;
  const float x = saturate(.5f + .5f * delta / spread);
  return WaterCriticalCosine + max(delta - spread, 0.f) + spread * x * x * x * (2.f - x);
}

float WaterExitFresnel(float cosine, float spread) {
  const float coverage = smoothstep(WaterCriticalCosine - spread, WaterCriticalCosine + spread, cosine);
  return lerp(1.f, WaterFresnel(WaterExitCosine(cosine, spread), rcp(WaterIor)), coverage);
}

float3 WaterReflectionAmbient(float3 shallow_tint, float3 deep_tint, float illumination) {
  return lerp(max(shallow_tint, 0.f), max(deep_tint, 0.f), .35f) * lerp(.18f, .62f, saturate(illumination));
}

float3 ShadeWaterSurface(float3 body, float normal_view_cosine, float3 shallow_tint,
                         float illumination, float3 glint, float foam) {
  const float fresnel = WaterFresnel(normal_view_cosine, WaterIor);
  const float3 water = (1.f - fresnel) * body + glint;
  const float3 foam_lighting = max(shallow_tint, 0.f) * .3f + lerp(.04f, .45f, saturate(illumination));
  return lerp(water, foam_lighting, saturate(foam));
}
#endif
