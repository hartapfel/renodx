/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#ifndef WITCHER_REMASTERED_GRAPHICS_SHARED_H
#define WITCHER_REMASTERED_GRAPHICS_SHARED_H

// Allows a recovery build without the additional pass or root-slot extension.
#ifndef WITCHER_GRAPHICS_VOLUMETRICS
#define WITCHER_GRAPHICS_VOLUMETRICS 1
#endif

struct ShaderInjectData {
  float graphics_mode;
  float fog_mode;
  float fog_density;
  float fog_height_falloff;
  float fog_start;
  float layout_version;
  float soft_shadows;
  float sun_diameter;
  float fog_scattering;
  float fog_sun_strength;
  float fog_anisotropy;
  float fog_sky_density;
  float pbr_mode;
  float fog_shadow_quality;
  float fog_temporal;
  // Per-pass FAST frame + 1: positive admits history, negative resets it.
  // Zero is an uninitialized pass. Never exposed as a user setting.
  float fog_history_frame;
  float water_refraction;
  float water_ripples;
  float contact_shadows;
  float contact_length;
  // Runtime capability: 0 native, 1 Raster optics, 2 Raster and traced optics.
  // This is not a saved setting; all water consumers share the same decision.
  float water_optics;
  // Appended: preserve every existing shader/control offset.
  float water_ripple_pattern;
  float water_caustics;
};

#if !defined(__cplusplus) && !defined(WITCHER_GRAPHICS_CUSTOM_LIGHTING)
// The separate HDR addon uses space50. Graphics owns a distinct contract.
cbuffer graphics_injection : register(b13, space51) {
  ShaderInjectData graphics_injection : packoffset(c0);
}
#endif
#endif
