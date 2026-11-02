/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <array>
#include <cmath>
#include "../presets.hpp"
namespace witcher3classic::volumetrics {
inline float mode = 1.f;
inline float density = 1.f;
inline float sky_density = 1.f;
inline float reconstruction = 1.f;
inline float renderer = presets::Default(presets::graphics,"GfxFogRenderer");
inline float start_distance = 0.f;
inline float light_strength = 1.f;
inline float local_light_strength = presets::Default(presets::graphics,"GfxFogLocalLight");
inline float anisotropy = presets::Default(presets::graphics,"GfxFogAnisotropy");
inline float height_falloff = 1.f;
inline float resolution_quality = presets::Default(presets::graphics,"GfxFogResolutionQuality");
inline float shadow_quality = presets::Default(presets::graphics,"GfxFogShadowQuality");

// Shared runtime/test contract. The depth dimension is bounded by Pipeline's
// 256-cell limit; rows follow the camera aspect rather than the DLSS scale.
inline std::array<float,4> VolumeGrid(float quality, float aspect) {
  constexpr std::array<std::array<float,2>,4> sizes{{{160,96},{240,128},{320,192},{384,256}}};
  const auto& size=sizes[std::clamp(std::lround(quality),1L,4L)-1];
  return {size[0],std::clamp(std::ceil(size[0]*aspect),45.f,512.f),size[1],1000.f};
}
}  // namespace witcher3classic::volumetrics
