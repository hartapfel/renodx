// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include "../shared.h"
namespace hartapfelfx::fog {
// The old two-level key remains Custom. The last mode integrates the resolved
// lighting field along each receiver ray instead of interpolating its prefix.
inline std::array<uint32_t,3> GridQuality(const ShaderInjectData& settings,float width,float height) {
  constexpr std::array<std::array<uint32_t,2>,6> levels{{
      {0,0},{120,64},{160,96},{240,128},{256,128},{256,128}}};
  const auto level=std::clamp(std::lround(settings.quality_preset),0L,5L);
  uint32_t columns=level?levels[level][0]:settings.quality<1.5f?160u:240u;
  const double aspect=std::max(double(height)/std::max(width,1.f),.001);
  // Keep portrait views within the same voxel budget as 16:9. Four native
  // frame-CBV rotations must fit the existing pool, including history pages.
  if(level)columns=std::min(columns,std::max(1u,uint32_t(std::sqrt(columns*std::ceil(columns*9.0/16.0)/aspect))));
  return {columns,std::clamp(uint32_t(std::ceil(columns*aspect)),45u,level?320u:256u),
      level?levels[level][1]:settings.quality<1.5f?96u:128u};
}
}
