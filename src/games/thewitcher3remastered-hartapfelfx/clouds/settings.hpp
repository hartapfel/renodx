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
