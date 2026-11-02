/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include "../presets.hpp"
namespace witcher3classic::water {
inline float underwater_density=1.f,underwater_quality=presets::Default(presets::graphics,"GfxUnderwaterDetail"),caustics=1.f;
inline float camera_blur=.15f,camera_ca=1.f;
inline float mode = 1.f;
inline float surface_ripples = presets::Default(presets::graphics,"GfxWaterSurfaceRipples");
inline float ripple_pattern = presets::Default(presets::graphics,"GfxWaterRipplePattern");
// Native, half-resolution Balanced, full-resolution High. Preserve High as
// the default until the new Balanced path passes the live scene matrix.
inline float ssr_quality = presets::Default(presets::graphics,"GfxWaterSSRQuality"), ssr_stabilization = 1.f;
constexpr float LegacySSRQuality(float full_resolution) { return full_resolution != 0.f ? 2.f : 0.f; }
}  // namespace witcher3classic::water
