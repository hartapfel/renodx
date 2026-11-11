// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include "../shared.h"
namespace hartapfelfx::fog {
inline VolumeLightData light{1.f, .5f, 0.f, 2.f, 1.f, 1.f, 1.f, FOG_LIGHT_VALID, 0.f, 1.f};
inline bool Active(const ShaderInjectData& settings) {
  return settings.enabled > .5f || light.enabled > .5f;
}
// The old two-level key remains Custom. The last mode integrates the resolved
// lighting field along each receiver ray instead of interpolating its prefix.
inline std::array<uint32_t,3> GridQuality(const ShaderInjectData& settings,float width,float height) {
  constexpr std::array<std::array<uint32_t,2>,6> levels{{
      {0,0},{120,64},{160,96},{240,128},{256,128},{256,128}}};
  const auto level=std::clamp(std::lround(settings.quality_preset),0L,5L);
  uint32_t columns=level?levels[level][0]:settings.quality<1.5f?160u:240u;
  uint32_t slices=level?levels[level][1]:settings.quality<1.5f?96u:128u;
  if(settings.enabled <= .5f)columns=slices=0u;
  if(light.enabled>.5f) {
    const auto beam_level=std::clamp(std::lround(light.quality),1L,4L);
    columns=std::max(columns,levels[beam_level][0]);
    slices=std::max(slices,levels[beam_level][1]);
  }
  columns=std::max(columns,1u);slices=std::max(slices,1u);
  const double aspect=std::max(double(height)/std::max(width,1.f),.001);
  // Keep portrait views within the same voxel budget as 16:9. Four native
  // frame-CBV rotations must fit the existing pool, including history pages.
  if(level ||light.enabled>.5f)columns=std::min(columns,std::max(1u,uint32_t(std::sqrt(columns*std::ceil(columns*9.0/16.0)/aspect))));
  return {columns,std::clamp(uint32_t(std::ceil(columns*aspect)),45u,level?320u:256u),
      slices};
}
}
