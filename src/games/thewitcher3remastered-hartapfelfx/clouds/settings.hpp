/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <array>
#include <cmath>
namespace hartapfelfx::clouds {
inline float mode = 1.f;
inline float quality = 1.f;
inline float step_size = 1.f;
inline float shadows = 1.f;
// The controls are direct multipliers of the model. Historic Classic rebases
// (.18/.432 density, 4 detail, .8 detail size, 1.3 thickness) must not silently
// alter the neutral 100% presentation of this new implementation.
inline float coverage = 1.f, density = 1.f, size = 1.f, thickness = 1.f;
inline float detail = 1.f, detail_size = 1.f, base_softness = 0.f;
inline float base_height=1200.f, roundness=0.f, height_variation=1.f, coverage_breakup=1.f;
inline float billow_size=1.f, warp=1.f, shear=1.f, density_contrast=1.f;
inline float erosion=1.f, wisp_bias=0.f, base_relief=1.f, top_relief=1.f;
inline float edge_sharpness=1.f, edge_roughness=1.f, base_feather=1.f, top_feather=1.f;
inline float sunlight=1.f, skylight=1.f, self_shadow=1.f, forward_scattering=.8f;
inline float cirrus_amount=1.f, cirrus_coverage=1.f, cirrus_size=1.f, cirrus_height=8000.f;
struct AuthoringParameters {
  std::array<float,4> morphology, structure, microstructure, contour, illumination, high_layer;
  bool operator==(const AuthoringParameters&) const = default;
};
static_assert(sizeof(AuthoringParameters)==96);
// One bounded snapshot feeds the view, shadow, reflection and history paths.
inline AuthoringParameters Authoring() {
  return {
      {std::clamp(base_height,300.f,5000.f),std::clamp(roundness,-1.f,1.f),
          std::clamp(height_variation,0.f,2.f),std::clamp(coverage_breakup,0.f,2.f)},
      {std::clamp(billow_size,.25f,3.f),std::clamp(warp,0.f,3.f),
          std::clamp(shear,0.f,3.f),std::clamp(density_contrast,.25f,3.f)},
      {std::clamp(erosion,0.f,3.f),std::clamp(wisp_bias,-1.f,1.f),
          std::clamp(base_relief,0.f,3.f),std::clamp(top_relief,0.f,3.f)},
      {std::clamp(edge_sharpness,0.f,4.f),std::clamp(edge_roughness,0.f,3.f),
          std::clamp(base_feather,.2f,4.f),std::clamp(top_feather,.25f,4.f)},
      {std::clamp(sunlight,0.f,3.f),std::clamp(skylight,0.f,3.f),
          std::clamp(self_shadow,0.f,3.f),std::clamp(forward_scattering,0.f,.95f)},
      {std::clamp(cirrus_amount,0.f,3.f),std::clamp(cirrus_coverage,0.f,2.f),
          std::clamp(cirrus_size,.25f,4.f),std::clamp(cirrus_height,5000.f,16000.f)}};
}
// Packed with the independent sky-haze scale in the existing parameter row.
inline std::array<float,4> Atmosphere(float sky_density) {
  return {std::clamp(sky_density,0.f,4.f),std::clamp(detail,0.f,8.f),
      std::clamp(detail_size,.2f,2.f),std::clamp(base_softness,0.f,1.f)};
}
inline std::array<float,4> Appearance() {
  return {std::clamp(coverage,0.f,2.f),std::clamp(density,0.f,4.f),
      std::clamp(size,.25f,4.f),std::clamp(thickness,.5f,3.f)};
}
// Full resolution divisor, view samples, light samples. Step size changes
// view sampling only, preserving lighting quality.
inline std::array<unsigned,3> Quality(float value) {
  constexpr std::array<std::array<unsigned,3>,6> levels{{{1,32,3},{1,48,4},{1,64,5},{1,80,6},{1,128,10},{1,160,12}}};
  auto samples=levels[std::clamp(std::lround(value),0L,5L)];
  samples[1]=unsigned(std::ceil(samples[1]/std::clamp(step_size,.5f,2.f)));
  return samples;
}
// Two direct-scattering octaves, erosion octaves, reserved, noise size.
// The two-octave lighting model is fixed across quality levels as in Bauer's
// cloud shading model; quality refines ray sampling and morphology.
inline std::array<float,4> QualityLighting(float value) {
  constexpr std::array<std::array<float,4>,6> levels{{
      {2,1,0,64},{2,1,0,64},{2,2,0,128},{2,3,0,128},{2,3,0,128},{2,3,0,128}}};
  return levels[std::clamp(std::lround(value),0L,5L)];
}
}
