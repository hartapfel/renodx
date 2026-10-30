/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <cstddef>
#include <string_view>

namespace witcher3classic::presets {
struct Value {
  std::string_view key;
  float vanilla;
  float custom;
};
// Complete assignments, independent of the current profile and reset values.
// The custom columns also define fresh-install/reset defaults.
inline constexpr Value night[] = {
    {"NightLightingEnabled", 0.f, 1.f},
    {"NightRegionalNormalization", 0.f, 1.f},
    {"NightMoonlightIntensity", 100.f, 35.f},
    {"NightMoonBrightness", 100.f, 50.f},
    {"NightMoonSize", 100.f, 50.f},
    {"NightAmbientLight", 100.f, 35.f},
    {"NightAmbientShadow", 100.f, 35.f},
    {"NightReflectionLight", 100.f, 35.f},
    {"NightReflectionShadow", 100.f, 35.f},
    {"NightWaterAmbient", 100.f, 35.f},
    {"NightFogBrightness", 100.f, 35.f},
    {"NightHazeBrightness", 100.f, 35.f},
    {"NightSkyBrightness", 100.f, 35.f},
    {"NightSkyHazeBrightness", 100.f, 35.f},
    {"NightCloudBrightness", 100.f, 35.f},
    {"NightStarBrightness", 100.f, 100.f},
    {"NightExposureAllDay", 0.f, 1.f},
    // Disabled overrides retain the game's auto exposure, not fixed exposure.
    {"NightAutoExposureEnabled", 1.f, 1.f},
    {"NightExposureAdaptation", 0.f, 1.f},
    {"NightExposureBrighteningSpeed", 100.f, 35.f},
    {"NightExposureDarkeningSpeed", 100.f, 5.f},
    {"NightExposureMaximumBrightening", 100.f, 20.f},
    {"NightExposureMaximumDarkening", 100.f, 100.f},
    {"NightExposureFixedLuminance", .18f, .18f},
    {"NightDarkeningStart", 18.f, 18.f},
    {"NightFullDarknessStart", 21.5f, 21.5f},
    {"NightFadeOutStart", 3.5f, 3.5f},
    {"NightDarkeningEnd", 6.f, 6.f},
};
inline constexpr Value graphics[] = {
    {"GfxLighting", 0.f, 1.f}, {"GfxAmbientAO", 0.f, 1.f},
    {"GfxSoftShadows", 0.f, 1.f}, {"GfxSunDiameter", .15f, .15f},
    {"GfxContactShadows", 0.f, 1.f}, {"GfxContactLength", 1.f, 1.f},
    {"GfxPlayerFill", 0.f, 1.f}, {"GfxPlayerStrength", .2f, .2f},
    {"GfxPlayerUnify", 0.f, 1.f}, {"GfxVolumetrics", 0.f, 1.f},
    {"GfxFogDensity", 1.f, 1.f}, {"GfxFogSkyDensity", 1.f, 1.f},
    {"GfxFogStart", 0.f, 0.f}, {"GfxFogLight", 1.f, 1.f},
    {"GfxFogLocalLight", 2.f, 2.f}, {"GfxFogAnisotropy", .5f, .5f},
    {"GfxFogHeight", 1.f, 1.f}, {"GfxFogRenderer", 0.f, 0.f},
    {"GfxFogResolutionQuality", 2.f, 2.f},
    {"GfxFogReconstruction", 0.f, 1.f},
    {"GfxFogShadowQuality", 4.f, 4.f}, {"GfxWater", 0.f, 1.f},
    {"GfxWaterClarity", .5f, .5f}, {"GfxRefractiveRain", 0.f, 1.f},
};

template <std::size_t N>
consteval float Default(const Value (&values)[N], std::string_view key) {
  for (const auto& value : values) if (value.key == key) return value.custom;
  throw "Setting is missing from its explicit preset table";
}
} // namespace witcher3classic::presets
