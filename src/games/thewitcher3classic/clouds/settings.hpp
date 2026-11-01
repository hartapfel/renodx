/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <array>
#include <cmath>
namespace witcher3classic::clouds {
inline float mode = 1.f;
inline float quality = 1.f;
inline float resolution = 0.f;
inline float step_size = 1.f;
inline float shadows = 1.f;
// Physical values remain compatible with density/shadow shaders. Only the UI
// units change: the previous Density 400% is the third baseline.
// Surface Detail and Detail Size retain their second-rebase physical values.
inline constexpr float DensityBaseline=.6f, DetailBaseline=4.f, DetailSizeBaseline=.4f;
inline float coverage = 1.f, density = DensityBaseline, size = 1.f, thickness = 1.f;
inline float detail = DetailBaseline, detail_size = DetailSizeBaseline, base_softness = 0.f;
// Packed with the independent sky-haze scale in the existing parameter row.
inline std::array<float,4> Atmosphere(float sky_density) {
  return {std::clamp(sky_density,0.f,4.f),std::clamp(detail,0.f,8.f),
      std::clamp(detail_size,.2f,2.f),std::clamp(base_softness,0.f,1.f)};
}
inline std::array<float,4> Appearance() {
  return {std::clamp(coverage,0.f,2.f),std::clamp(density,0.f,4.f),
      std::clamp(size,.25f,4.f),std::clamp(thickness,.5f,3.f)};
}
// Automatic resolution divisor, view samples, light samples. Resolution and
// step-size overrides affect view sampling only, preserving lighting quality.
inline std::array<unsigned,3> Quality(float value) {
  constexpr std::array<std::array<unsigned,3>,6> levels{{{4,32,3},{4,48,4},{4,64,5},{2,80,6},{2,128,10},{1,160,12}}};
  auto samples=levels[std::clamp(std::lround(value),0L,5L)];
  const auto selected=std::clamp(std::lround(resolution),0L,3L);
  if(selected!=0)samples[0]=1u<<(3u-unsigned(selected));
  samples[1]=unsigned(std::ceil(samples[1]/std::clamp(step_size,.5f,2.f)));
  return samples;
}
// Multiple-scattering octaves, erosion octaves, air-path samples, noise size.
// Every level includes indirect sunlight; higher levels refine transport and
// morphology instead of spending their entire budget on more primary steps.
inline std::array<float,4> QualityLighting(float value) {
  constexpr std::array<std::array<float,4>,6> levels{{
      {2,1,12,64},{2,1,16,64},{3,2,20,128},{3,3,24,128},{3,3,40,128},{3,3,48,128}}};
  return levels[std::clamp(std::lround(value),0L,5L)];
}
}
