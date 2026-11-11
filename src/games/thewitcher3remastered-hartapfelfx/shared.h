// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFELFX_SHARED_H
#define HARTAPFELFX_SHARED_H
#define FOG_HEADER_BYTES 1024u
#define FOG_FRAME_VALID 0xF7F00002u
#define FOG_HISTORY_VALID 0xF7F00004u
struct ShaderInjectData {
  float enabled;
  float density;
  float sunlight;
  float anisotropy;
  float start_distance;
  float height_falloff;
  float quality;
  float local_strength;
  float sky_density;
  float reconstruction;
  float haze_reduction;
  float quality_preset;
  unsigned int sky_deferred;
  float water_enabled;
  float water_murk;
  float padding;
};
#ifndef __cplusplus
cbuffer HartapfelFX : register(b0, space70) {
  ShaderInjectData fx : packoffset(c0);
#ifdef HARTAPFEL_SKY_VIEW
  float4 sky_moon_material : packoffset(c4);
  float4 sky_sun_material : packoffset(c5);
  float sky_sun_glow_size : packoffset(c6);
  uint sky_glow_exposure : packoffset(c6.y);
  float2 sky_native_radius : packoffset(c7);
  float4 sky_sun_emission : packoffset(c8);
  float4 sky_moon_emission : packoffset(c9);
#endif
}
float FogAmount() { return 1.f-saturate(fx.haze_reduction); }
// Negative clear distance advances the native fade without integrating medium
// behind the camera. Nonnegative values retain the original clear-space rule.
float FogFadeStart(float native_near) {
  return max(fx.start_distance, native_near) + min(fx.start_distance, 0.f);
}
#else
static_assert(sizeof(ShaderInjectData)==64);
#endif
#endif
