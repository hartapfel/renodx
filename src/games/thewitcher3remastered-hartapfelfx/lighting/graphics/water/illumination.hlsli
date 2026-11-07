// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_REMASTERED_WATER_ILLUMINATION
#define WITCHER_REMASTERED_WATER_ILLUMINATION
#include "../reference/classic/water/transport.hlsli"

struct GraphicsWaterSun {
  float3 ray;
  float cosine;
  float flux;
};

// Sun is a unit vector toward the source. Flux is per horizontal area, relative
// to incident irradiance; radiance and solid-angle refraction Jacobians cancel.
// Keep this identical for surface transmission, underwater volume and receivers.
GraphicsWaterSun GraphicsWaterSunlight(float3 sun) {
  GraphicsWaterSun light;
  light.ray = refract(-sun, float3(0, 0, 1), 1.f / 1.333f);
  light.cosine = max(-light.ray.z, .01f);
  light.flux = saturate(sun.z) * (1.f - WaterInterfaceFresnel(sun.z, 1.f / 1.333f)) / light.cosine;
  return light;
}

struct GraphicsWaterReceiver {
  float3 sun;
  float3 direct;
  float3 ambient;
};

// Admission belongs to the caller: a point below a global height is NOT proof
// of submersion. Supply a validated body/terrain weight, depth and caustic field.
// These are incoming-light factors only; do not attenuate the eye path twice.
GraphicsWaterReceiver GraphicsWaterReceiverLight(float3 sun, float depth,
    float3 extinction, float weight, float focus) {
  GraphicsWaterReceiver result;
  result.sun = sun;
  result.direct = 1.f;
  result.ambient = 1.f;
  if (!isfinite(weight) || weight <= 0.f || !isfinite(depth) || depth < 0.f
      || any(!isfinite(sun)) || dot(sun, sun) < 1.e-12f
      || any(!isfinite(extinction)) || any(extinction < 0.f)
      || !isfinite(focus) || focus < 0.f) return result;
  weight = saturate(weight);
  sun = normalize(sun);
  GraphicsWaterSun light = GraphicsWaterSunlight(sun);
  // A below-horizon source has no incoming air-to-water path. Leave its native
  // direction intact while fading its admitted underwater irradiance to zero.
  if (sun.z > 0.f) result.sun = normalize(lerp(sun, -light.ray, weight));
  result.direct = lerp(1.f, WaterTransmittance(extinction, depth / light.cosine) * light.flux * focus, weight);
  float3 transfer = 0.f;
  [unroll] for (uint i = 0; i < 4u; ++i) {
    float air_cosine = (float(i) + .5f) * .25f;
    float water_cosine = sqrt(1.f - (1.f - air_cosine * air_cosine) / (1.333f * 1.333f));
    transfer += .5f * air_cosine * (1.f - WaterInterfaceFresnel(air_cosine, 1.f / 1.333f))
        * WaterTransmittance(extinction, depth / water_cosine);
  }
  result.ambient = lerp(1.f, transfer, weight);
  return result;
}

// Photon landing and flux for a measured geometric surface normal. The caller
// must supply the same water body and a receiver plane below the surface, then
// rasterize the photon mesh additively. A shading/ripple normal is not geometry.
// Flat-water Fresnel and absorption are applied later by ReceiverLight, so a
// horizontal surface produces unit focus instead of counting transmission twice.
bool GraphicsWaterPhoton(float3 surface, float3 normal, float3 sun,
    float receiver_height, out float3 photon) {
  photon = 0.f;
  if (any(!isfinite(surface)) || any(!isfinite(normal)) || any(!isfinite(sun))
      || !isfinite(receiver_height) || surface.z < receiver_height
      || dot(normal, normal) < 1.e-12f || dot(sun, sun) < 1.e-12f) return false;
  normal = normalize(normal);
  sun = normalize(sun);
  float cosine = dot(sun, normal);
  if (normal.z <= 1.e-4f || sun.z <= 1.e-4f || cosine <= 0.f) return false;
  float3 ray = refract(-sun, normal, 1.f / 1.333f);
  if (ray.z >= -1.e-4f) return false;
  photon.xy = surface.xy + ray.xy * ((surface.z - receiver_height) / -ray.z);
  photon.z = cosine * (1.f - WaterInterfaceFresnel(cosine, 1.f / 1.333f))
      / max(normal.z * sun.z * (1.f - WaterInterfaceFresnel(sun.z, 1.f / 1.333f)), 1.e-6f);
  if (any(!isfinite(photon))) { photon = 0.f; return false; }
  return true;
}
#endif
