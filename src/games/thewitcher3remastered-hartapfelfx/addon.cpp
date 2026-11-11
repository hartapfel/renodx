// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Generic addon entry-point pattern, with no HDR/swapchain module ownership.
#define ImTextureID                   ImU64
#define RENODX_PRIVATE_DATA_NAMESPACE 0x57484658u
#include <deps/imgui/imgui.h>
#include <embed/shaders.h>
#include "../../mods/shader.hpp"
#include "../../utils/settings.hpp"
#include "fog/bindings.hpp"
#include "fog/runtime.hpp"
#include "clouds/runtime.hpp"
#include "shared.h"
#include "night/settings.hpp"
#include "settings_ui.hpp"
#include "lighting/graphics/lighting/native.hpp"
#include "lighting/runtime.hpp"

namespace {
ShaderInjectData injection = {1.f, 1.f, 1.f, .5f, 0.f, 1.f, 1.f, 1.f, 1.f, 0.f, 0.f, 0.f};
namespace fog = hartapfelfx::fog;
namespace clouds = hartapfelfx::clouds;
namespace nights = witcher::night;
namespace fill_native = witcher3graphics::native;
namespace player_fill = witcher3graphics::player;
namespace lighting = hartapfelfx::lighting;
float player_lighting = 1.f;
float gameplay_strength = .2f;
float cutscene_strength = .2f;
float match_world = 1.f;
using Setting = renodx::utils::settings::Setting;
renodx::utils::settings::Settings settings = {
    new Setting{
        .key = "WaterEnabledV1",
        .binding = &injection.water_enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Improved Water",
        .section = "Water",
        .tooltip = "Enables improved surface and underwater rendering together, including refraction, caustics and fog."},
    new Setting{
        .key = "WaterMurkV1",
        .binding = &injection.water_murk,
        .default_value = 150.f,
        .label = "Water Murk",
        .section = "Water",
        .tooltip = "Controls how quickly visibility falls through water, both from the surface and while submerged. Zero clears the added murk.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "PlayerLighting",
        .binding = &player_lighting,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Character Fill Light",
        .section = "Character Lighting",
        .tooltip = "Adds gentle light to characters during play and dialogue.",
        .labels = {"Original", "Improved"},
    },
    new Setting{
        .key = "GameplayLightStrength",
        .binding = &gameplay_strength,
        .default_value = .2f,
        .label = "Gameplay Brightness",
        .section = "Character Lighting",
        .tooltip = "Raises the brightness of the light following your camera.",
        .min = 0.f,
        .max = 1.f,
        .format = "%.2f",
        .is_enabled = [] { return player_lighting != 0.f; },
    },
    new Setting{
        .key = "CutsceneLightStrength",
        .binding = &cutscene_strength,
        .default_value = .2f,
        .label = "Dialogue & Cutscene Brightness",
        .section = "Character Lighting",
        .tooltip = "Raises character fill light during conversations and cutscenes.",
        .min = 0.f,
        .max = 1.f,
        .format = "%.2f",
        .is_enabled = [] { return player_lighting != 0.f; },
    },
    new Setting{
        .key = "MatchPlayerLighting",
        .binding = &match_world,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Match the Environment",
        .section = "Character Lighting",
        .tooltip = "Makes character fill light respond to the surrounding light.",
        .labels = {"Off", "On"},
        .is_enabled = [] { return player_lighting != 0.f; },
    },
    new Setting{
        .key = "PBRLighting",
        .binding = &lighting::pbr,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Surface Lighting",
        .section = "World Lighting & Shadows",
        .tooltip = "Improves how world surfaces reflect sunlight and lamps.",
        .labels = {"Original", "Improved"},
    },

    new Setting{
        .key = "SoftShadows",
        .binding = &lighting::soft,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Sun & Moon Shadows",
        .section = "World Lighting & Shadows",
        .tooltip = "Improves the softness of shadows from the sun and moon.",
        .labels = {"Original", "Improved"},
    },

    new Setting{
        .key = "SunDiameter",
        .binding = &lighting::diameter,
        .default_value = 0.25f,
        .label = "Shadow Softness",
        .section = "World Lighting & Shadows",
        .tooltip = "Larger values soften shadows from the sun and moon.",
        .min = .05f, .max = 2.f, .format = "%.3f degrees",
        .is_enabled = [] { return lighting::soft != 0.f; },
    },

    new Setting{
        .key = "ContactShadows",
        .binding = &lighting::contact_shadows,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Small Object Shadows",
        .section = "World Lighting & Shadows",
        .tooltip = "Adds nearby shadows around feet, grass and small objects.",
        .labels = {"Original", "Improved"},
    },

    new Setting{
        .key = "ContactShadowLength",
        .binding = &lighting::reach,
        .default_value = 1.f,
        .label = "Small Shadow Reach",
        .section = "World Lighting & Shadows",
        .tooltip = "Extends how far nearby objects can cast these shadows.",
        .min = .05f, .max = 1.f, .format = "%.2f m",
        .is_enabled = [] { return lighting::contact_shadows != 0.f; },
    },

    new Setting{
        .key = "CloudModeV2", .binding = &clouds::mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f, .label = "Cloud Rendering", .section = "Clouds & Performance", .tooltip = "Choose the original clouds or HartapfelFX volumetric clouds.",
        .labels = {"Original", "Volumetric"}},
    new Setting{
        .key = "CloudQualityPresetV1", .binding = &clouds::quality_preset,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 3.f, .label = "Quality Preset", .section = "Clouds & Performance",
        .tooltip = "Performance is fastest. Balanced keeps smoother clouds at a lower cost. High keeps full detail; Ultra refines it further. Custom keeps your saved quality and sample spacing. Cloud shape and lighting controls stay the same.",
        .labels = {"Custom", "Performance", "Balanced", "High", "Ultra"}},
    new Setting{
        .key = "CloudQualityV2", .binding = &clouds::quality,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f, .label = "Detail Quality", .section = "Cloud Quality (Advanced)",
        .tooltip = "Higher quality improves cloud detail and costs more performance.",
        .labels = {"Low", "Medium", "High", "Ultra", "Cinematic", "Maximum"},
        .is_visible = [] { return clouds::quality_preset < .5f; }},
    new Setting{
        .key = "CloudStepSizeV2", .binding = &clouds::step_size,
        .default_value = 50.f, .label = "Sample Spacing", .section = "Cloud Quality (Advanced)", .tooltip = "Lower values smooth clouds; higher values improve performance. Used with Custom quality.",
        .min = 50.f, .max = 200.f,
        .parse = [](float value) { return value * .01f; },
        .is_visible = [] { return clouds::quality_preset < .5f; }},
    new Setting{
        .key = "CloudShadowStrengthV1", .binding = &clouds::shadows,
        .default_value = 90.f, .label = "Cloud Shadow Strength", .section = "Clouds & Performance",
        .tooltip = "Lower values let more sunlight and moonlight reach the world through clouds. 0% turns cloud shadows off.",
        .min = 0.f, .max = 100.f, .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudCoverageV2", .binding = &clouds::coverage,
        .default_value = 200.f, .label = "Coverage", .section = "Cloud Appearance",
        .tooltip = "Fills more or less of the sky with clouds.",
        .min = 0.f, .max = 200.f, .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudClearLowSunV1", .binding = &clouds::clear_low_sun,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f, .label = "Clear Sunrises & Sunsets", .section = "Cloud Appearance",
        .tooltip = "Opens an irregular band of sky along the Sun's horizon from 6 pm to 6 am, with gradual fades. Rain and storms keep natural cover. Cloud shadows follow the opening.",
        .labels = {"Off", "On"},
        .is_enabled = [] { return clouds::mode > .5f; }},
    new Setting{
        .key = "CloudDensityV3", .binding = &clouds::density,
        .default_value = 30.f, .label = "Density", .section = "Cloud Appearance",
        .tooltip = "Makes cloud bodies more opaque and solid-looking.",
        .min = 0.f, .max = 400.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudSizeV2", .binding = &clouds::size,
        .default_value = 189.f, .label = "Formation Size", .section = "Cloud Appearance",
        .tooltip = "Makes whole cloud formations larger or smaller.",
        .min = 25.f, .max = 400.f, .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudThicknessV2", .binding = &clouds::thickness,
        .default_value = 62.f, .label = "Layer Thickness", .section = "Cloud Appearance",
        .tooltip = "Makes the main cloud layer deeper from base to top.",
        .min = 50.f, .max = 300.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudDetailV2", .binding = &clouds::detail,
        .default_value = 51.f, .label = "Surface Detail", .section = "Cloud Detail (Advanced)",
        .tooltip = "Adds smaller structures and irregularity inside cloud formations.",
        .min = 0.f, .max = 800.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudDetailSizeV2", .binding = &clouds::detail_size,
        .default_value = 62.f, .label = "Detail Size", .section = "Cloud Detail (Advanced)",
        .tooltip = "Sets the size of the smaller surface features.",
        .min = 20.f, .max = 200.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudBaseSoftnessV2", .binding = &clouds::base_softness,
        .default_value = 80.f, .label = "Underside Softness", .section = "Cloud Detail (Advanced)", .tooltip = "Softens the density transition along the cloud underside.",
        .min = 0.f, .max = 100.f, .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudRoundnessV1", .binding = &clouds::roundness,
        .default_value = 23.f, .label = "Roundness", .section = "Cloud Formation",
        .tooltip = "Higher values make taller clouds; lower values flatten them.",
        .min = -100.f, .max = 100.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudHeightVariationV1", .binding = &clouds::height_variation,
        .default_value = 172.f, .label = "Height Variation", .section = "Cloud Formation",
        .tooltip = "Varies the heights of neighbouring cloud tops.",
        .min = 0.f, .max = 200.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudCoverageBreakupV1", .binding = &clouds::coverage_breakup,
        .default_value = 200.f, .label = "Gaps Between Formations", .section = "Cloud Formation",
        .tooltip = "Opens coherent gaps within otherwise cloudy weather.",
        .min = 0.f, .max = 200.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudBillowSizeV1", .binding = &clouds::billow_size,
        .default_value = 300.f, .label = "Billow Size", .section = "Cloud Structure (Advanced)",
        .tooltip = "Changes the size of rounded shapes within each formation.",
        .min = 25.f, .max = 300.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudWarpV1", .binding = &clouds::warp,
        .default_value = 38.f, .label = "Shape Irregularity", .section = "Cloud Structure (Advanced)",
        .tooltip = "Bends regular rounded shapes into more varied cloud forms.",
        .min = 0.f, .max = 300.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudShearV1", .binding = &clouds::shear,
        .default_value = 117.f, .label = "Upper Cloud Lean", .section = "Cloud Structure (Advanced)",
        .tooltip = "Bends upper cloud material sideways relative to its base.",
        .min = 0.f, .max = 300.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudDensityContrastV1", .binding = &clouds::density_contrast,
        .default_value = 87.f, .label = "Core Contrast", .section = "Cloud Structure (Advanced)",
        .tooltip = "Concentrates material into dense cores with thinner edges.",
        .min = 25.f, .max = 300.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudErosionV1", .binding = &clouds::erosion,
        .default_value = 236.f, .label = "Erosion Strength", .section = "Cloud Erosion (Advanced)",
        .tooltip = "Carves small gaps and wisps into the cloud body.",
        .min = 0.f, .max = 300.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudWispBiasV1", .binding = &clouds::wisp_bias,
        .default_value = 17.f, .label = "Wispy / Rounded Balance", .section = "Cloud Erosion (Advanced)",
        .tooltip = "Higher values favour wisps; lower values favour rounded billows.",
        .min = -100.f, .max = 100.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudBaseReliefV1", .binding = &clouds::base_relief,
        .default_value = 39.f, .label = "Underside Relief", .section = "Cloud Erosion (Advanced)",
        .tooltip = "Adds hanging lobes and cavities along the cloud base.",
        .min = 0.f, .max = 300.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudTopReliefV1", .binding = &clouds::top_relief,
        .default_value = 171.f, .label = "Top Relief", .section = "Cloud Erosion (Advanced)",
        .tooltip = "Adds smaller rounded structures along cloud tops.",
        .min = 0.f, .max = 300.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudEdgeSharpnessV1", .binding = &clouds::edge_sharpness,
        .default_value = 93.f, .label = "Edge Sharpness", .section = "Cloud Edges",
        .tooltip = "Tightens soft outlines while keeping the dense cloud cores.",
        .min = 0.f, .max = 400.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudEdgeRoughnessV1", .binding = &clouds::edge_roughness,
        .default_value = 100.f, .label = "Edge Irregularity", .section = "Cloud Edges",
        .tooltip = "Breaks smooth outlines into more varied cloud contours.",
        .min = 0.f, .max = 300.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudBaseFeatherV1", .binding = &clouds::base_feather,
        .default_value = 290.f, .label = "Base Fade Width", .section = "Cloud Edges",
        .tooltip = "Higher values soften the transition along cloud bases.",
        .min = 20.f, .max = 400.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudTopFeatherV1", .binding = &clouds::top_feather,
        .default_value = 74.f, .label = "Top Fade", .section = "Cloud Edges",
        .tooltip = "Higher values thin out the upper cloud cap.",
        .min = 25.f, .max = 400.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudDirectLightV1", .binding = &clouds::sunlight,
        .default_value = 300.f, .label = "Sun & Moon Brightness", .section = "Cloud Lighting",
        .tooltip = "Brightens the cloud faces lit by the sun or moon.",
        .min = 0.f, .max = 300.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudSkyLightV1", .binding = &clouds::skylight,
        .default_value = 53.f, .label = "Ambient Brightness", .section = "Cloud Lighting",
        .tooltip = "Brightens cloud areas lit by the surrounding sky.",
        .min = 0.f, .max = 300.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudSelfShadowV1", .binding = &clouds::self_shadow,
        .default_value = 88.f, .label = "Internal Shadows", .section = "Cloud Lighting",
        .tooltip = "Deepens shadows inside the cloud body.",
        .min = 0.f, .max = 300.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudForwardScatteringV1", .binding = &clouds::forward_scattering,
        .default_value = 42.f, .label = "Bright Rim Strength", .section = "Cloud Lighting",
        .tooltip = "Concentrates brighter cloud lighting toward the sun or moon.",
        .min = 0.f, .max = 95.f,
        .is_enabled = [] { return clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "FogEnabled",
        .binding = &injection.enabled,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Fog Rendering",
        .section = "Fog & Performance",
        .tooltip = "Choose the original fog or HartapfelFX volumetric fog.",
        .labels = {"Original", "Volumetric"}},
    new Setting{
        .key = "FogQualityPresetV1", .binding = &injection.quality_preset,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f, .label = "Quality Preset", .section = "Fog & Performance",
        .tooltip = "Performance is fastest. Balanced and High improve light detail; Ultra refines smaller beams. Per-Pixel integrates lighting at each surface depth and is very expensive. Custom keeps your saved volume detail.",
        .labels = {"Custom", "Performance", "Balanced", "High", "Ultra", "Per-Pixel Integration"}},
    new Setting{
        .key = "FogQuality",
        .binding = &injection.quality,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Volume Detail",
        .section = "Fog Quality (Advanced)", .tooltip = "Sets the shared lighting detail when using Custom quality.",
        .labels = {"Balanced", "High"},
        .parse = [](float value) { return value + 1.f; },
        .is_visible = [] { return injection.quality_preset < .5f; }},
    new Setting{
        .key = "FogAmountV1", .binding = &injection.haze_reduction,
        .default_value = 100.f, .label = "Fog Amount", .section = "Fog Appearance",
        .tooltip = "Reduces the scene-wide fog veil without dimming light beams. 100% restores the previous fog amount.",
        .min = 0.f, .max = 100.f, .parse = [](float value) { return 1.f-value*.01f; }},
    new Setting{
        .key = "FogDensity",
        .binding = &injection.density,
        .default_value = 50.f,
        .label = "Medium Density",
        .section = "Fog Medium (Advanced)", .tooltip = "Changes the physical medium for both fog and beams. Use Fog Amount to clear the veil while keeping beams.",
        .min = 0.f,
        .max = 300.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "FogSunlight",
        .binding = &injection.sunlight,
        .default_value = 35.f,
        .label = "Sun & Moon Beams",
        .section = "Volumetric Light", .tooltip = "Brightens shadowed sunlight and moonlight in the air, independently of Fog Amount.",
        .min = 0.f,
        .max = 400.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "FogAnisotropy",
        .binding = &injection.anisotropy,
        .default_value = 0.65f,
        .label = "Light Focus",
        .section = "Volumetric Light", .tooltip = "Lower values show beams from more viewing angles. Higher values concentrate brightness toward the light and can create a strong glare.",
        .min = 0.f,
        .max = .85f,
        .format = "%.2f"},
    new Setting{
        .key = "FogLocalLight",
        .binding = &injection.local_strength,
        .default_value = 100.f,
        .label = "Lamp & Fire Light",
        .section = "Volumetric Light", .tooltip = "Brightens lamps and fire in the air, independently of Fog Amount.",
        .min = 0.f,
        .max = 200.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "FogStart",
        .binding = &injection.start_distance,
        .default_value = -40.f,
        .label = "Clear Distance",
        .section = "Fog Placement", .tooltip = "Negative values bring fog and beams closer by starting the game's fade earlier. Positive values leave clearer space around the camera.",
        .min = -100.f,
        .max = 100.f},
    new Setting{
        .key = "FogHeight",
        .binding = &injection.height_falloff,
        .default_value = 200.f,
        .label = "Fade With Height",
        .section = "Fog Placement", .tooltip = "Higher values keep more fog near the ground.",
        .min = 0.f,
        .max = 300.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "FogSkyDensity",
        .binding = &injection.sky_density,
        .default_value = 150.f,
        .label = "Distant Sky Haze",
        .section = "Fog Appearance", .tooltip = "Fades distant clouds and sky into the atmosphere.",
        .min = 0.f,
        .max = 300.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "FogSmoothReconstruction",
        .binding = &injection.reconstruction,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Smooth Fog Lighting",
        .section = "Fog Quality (Advanced)",
        .tooltip = "Softens shared lighting transitions. Per-Pixel Integration integrates the field directly and does not use this filter.",
        .labels = {"Off", "On"},
        .is_enabled = [] { return injection.quality_preset < 4.5f; }},
    new Setting{
        .key = "FogStatus",
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .label = "Integration Status",
        .section = "Diagnostics (Advanced)",
        .on_draw = []() {
          ImGui::Text("Sun inputs: %llu | Fog matches: %llu | Native fallbacks: %llu",
                      static_cast<unsigned long long>(fog::sun_captures.load()),
                      static_cast<unsigned long long>(fog::fog_matches.load()),
                      static_cast<unsigned long long>(fog::fog_fallbacks.load()));
          return false;
        }},

};
bool BindReceiver(reshade::api::command_list* cmd, bool night = false, bool water = false) {
  auto* state = renodx::utils::shader::GetCurrentPixelState(renodx::utils::shader::GetCurrentState(cmd));
  // A failed initial PSO clone has no retained subobjects for a lazy retry.
  // Gate every replacement before the shared shader module can attempt one.
  if (state->pipeline_details
      && state->pipeline_details->initialized_replacement
      && state->pipeline_details->replacement_pipeline.handle != 0) {
    const bool fog_ready = injection.enabled > .5f && fog::runtime::PrepareReceiver(cmd);
    const bool cloud_ready = clouds::runtime::PrepareReceiver(cmd, fog_ready, night || water);
    if (water && !fog_ready)
      return cloud_ready && clouds::runtime::BindWaterControls(cmd, injection.water_enabled, injection.water_murk);
    if (fog_ready || cloud_ready) return true;
  }
  return false;
}
bool BindCloudShadow(reshade::api::command_list* cmd, const renodx::utils::shader::StageState& state, bool compute, bool night = false) {
  if ((clouds::mode > .5f || night) && state.pipeline_details && state.pipeline_details->initialized_replacement
      && state.pipeline_details->replacement_pipeline.handle != 0 && clouds::runtime::PrepareShadowReceiver(cmd, compute)) return true;
  return false;
}
bool BindCloudGraphics(reshade::api::command_list* cmd) {
  return BindCloudShadow(cmd, *renodx::utils::shader::GetCurrentPixelState(renodx::utils::shader::GetCurrentState(cmd)), false);
}
bool BindCelestialSky(reshade::api::command_list* cmd, bool toussaint) {
  const bool ready=toussaint ? BindCloudGraphics(cmd) : BindReceiver(cmd);
  clouds::runtime::PrepareCelestialSky(cmd,ready);
  return ready;
}
bool BindCloudVertex(reshade::api::command_list* cmd) {
  return BindCloudShadow(cmd, *renodx::utils::shader::GetCurrentVertexState(renodx::utils::shader::GetCurrentState(cmd)), false);
}
bool BindCloudMotion(reshade::api::command_list* cmd) {
  auto* state = renodx::utils::shader::GetCurrentComputeState(renodx::utils::shader::GetCurrentState(cmd));
  if (state->pipeline_details && state->pipeline_details->initialized_replacement
      && state->pipeline_details->replacement_pipeline.handle != 0 && clouds::runtime::PrepareMotion(cmd)) return true;
  return false;
}
renodx::mods::shader::CustomShaders shaders = {
    {0x6350BBBF, {.crc32 = 0x6350BBBF, .code = __0x6350BBBF,
                  .on_replace = [](auto* cmd) {
                    return clouds::mode > .5f && renodx::utils::shader::GetCurrentPixelShaderHash(renodx::utils::shader::GetCurrentState(cmd)) == 0x093DCC92u;
                  },
                  .on_inject = [](auto*) { return false; }}},
    {0xFA11F41B, {.crc32 = 0xFA11F41B, .code = __0xFA11F41B, .on_replace = &BindCloudMotion}},
    {0x9F1C32F1, {.crc32 = 0x9F1C32F1, .code = __0x9F1C32F1, .on_replace = &BindCloudMotion}},
    {0x35E6FF87, {.crc32 = 0x35E6FF87, .code = clouds::native::shader_35E6FF87, .on_replace = &BindCloudVertex}},
    {0x365A4FCA, {.crc32 = 0x365A4FCA, .code = clouds::native::shader_365A4FCA, .on_replace = &BindCloudGraphics}},
    {0x52A112DE, {.crc32 = 0x52A112DE, .code = clouds::native::shader_52A112DE, .on_replace = &BindCloudVertex}},
    {0x806C62A8, {.crc32 = 0x806C62A8, .code = clouds::native::shader_806C62A8, .on_replace = &BindCloudGraphics}},
    {0x9DF5AF93, {.crc32 = 0x9DF5AF93, .code = clouds::native::shader_9DF5AF93, .on_replace = &BindCloudGraphics}},
    {0x683213A3, {.crc32 = 0x683213A3, .code = __0x683213A3, .on_replace = [](auto* cmd) { return BindReceiver(cmd); }}},
    {0xBF0CA052, {.crc32 = 0xBF0CA052, .code = __0xBF0CA052, .on_replace = [](auto* cmd) { return BindReceiver(cmd); }}},
    {0xB7D286D5, {.crc32 = 0xB7D286D5, .code = __0xB7D286D5, .on_replace = [](auto* cmd) { return BindReceiver(cmd); }}},
    {0xCEE2035A, {.crc32 = 0xCEE2035A, .code = __0xCEE2035A, .on_replace = [](auto* cmd) { return BindReceiver(cmd); }}},
    {0x95CC19A8, {.crc32 = 0x95CC19A8, .code = __0x95CC19A8, .on_replace = [](auto* cmd) { return BindReceiver(cmd); }}},
    {0x57F658BC, {.crc32 = 0x57F658BC, .code = __0x57F658BC, .on_replace = [](auto* cmd) { return BindReceiver(cmd); }}},
    {0x9550E75E, {.crc32 = 0x9550E75E, .code = __0x9550E75E, .on_replace = [](auto* cmd) { return BindReceiver(cmd); }}},
    {0x6208DA88, {.crc32 = 0x6208DA88, .code = __0x6208DA88, .on_replace = [](auto* cmd) { return BindReceiver(cmd); }}},
    {0x449D3390, {.crc32 = 0x449D3390, .code = __0x449D3390, .on_replace = [](auto* cmd) { return BindCelestialSky(cmd,false); }}},
    {0x3B15DAAB, {.crc32 = 0x3B15DAAB, .code = __0x3B15DAAB, .on_replace = [](auto* cmd) { return BindCelestialSky(cmd,true); }}},
    {0xC60F2B46, {.crc32 = 0xC60F2B46, .code = __0xC60F2B46,
                  .on_replace = [](auto* cmd) { return BindReceiver(cmd, false, injection.water_enabled > .5f); }}},
    {0xECE2CD5B, {.crc32 = 0xECE2CD5B, .code = __0xECE2CD5B,
                  .on_replace = [](auto* cmd) {
                    if (!(injection.water_enabled > .5f)) return false;
                    auto* state = renodx::utils::shader::GetCurrentPixelState(renodx::utils::shader::GetCurrentState(cmd));
                    return state && state->pipeline_details && state->pipeline_details->initialized_replacement
                        && state->pipeline_details->replacement_pipeline.handle
                        && clouds::runtime::BindWaterControls(cmd, injection.water_enabled, injection.water_murk)
                        && fog::runtime::BindWaterLight(cmd);
                  }}},
    {0x73E21194, {
                     .crc32 = 0x73E21194,
                     .code = __0x73E21194,
                     .on_replace = [](auto* cmd) {
                       auto* state = renodx::utils::shader::GetCurrentPixelState(renodx::utils::shader::GetCurrentState(cmd));
                       const bool ready = injection.enabled > .5f && state->pipeline_details
                                          && state->pipeline_details->initialized_replacement
                                          && state->pipeline_details->replacement_pipeline.handle != 0
                                          && fog::runtime::Prepare(cmd);
                       ++(ready ? fog::fog_matches : fog::fog_fallbacks);
                       if (injection.enabled <= .5f || !ready) {
                         // The engine may omit a redundant SetPipelineState between repeated
                         // fog draws. Explicitly undo any preceding replacement on fallback.
                         return false;
                       }
                       return injection.enabled > .5f && ready;
                     },
                 }},
};
void ConfigureNightShaders() {
  const renodx::mods::shader::CustomShaders night_shaders = {
      {0x04251B31u, {.crc32 = 0x04251B31u, .code = __0x04251B31}},
      {0x093DCC92u, {.crc32 = 0x093DCC92u, .code = __0x093DCC92}},
      {0x1B63829Bu, {.crc32 = 0x1B63829Bu, .code = __0x1B63829B}},
      {0x1C12BED7u, {.crc32 = 0x1C12BED7u, .code = __0x1C12BED7}},
      {0x14AEBBFBu, {.crc32 = 0x14AEBBFBu, .code = __0x14AEBBFB}},
      {0x680C44CEu, {.crc32 = 0x680C44CEu, .code = __0x680C44CE}},
      {0x6D5A1EC2u, {.crc32 = 0x6D5A1EC2u, .code = __0x6D5A1EC2}},
      {0xE1C4426Eu, {.crc32 = 0xE1C4426Eu, .code = __0xE1C4426E}},
      {0xE446F231u, {.crc32 = 0xE446F231u, .code = __0xE446F231}},
  };
  for (const auto& [hash, shader] : night_shaders) {
    auto& entry = shaders.emplace(hash, shader).first->second;
    nights::ui::ConfigureShader(hash, &entry);
    if (hash == 0x093DCC92u) {
      entry.on_replace = [night = std::move(entry.on_replace)](auto* cmd) {
        const bool use_night = night(cmd);
        return BindCloudShadow(cmd, *renodx::utils::shader::GetCurrentPixelState(renodx::utils::shader::GetCurrentState(cmd)), false, use_night);
      };
    }
  }
  for (const uint32_t hash : {0x683213A3u, 0xB7D286D5u, 0xCEE2035Au, 0x95CC19A8u,
                              0x3B15DAABu}) {
    auto& entry = shaders.at(hash);
    auto existing = std::move(entry.on_replace);
    nights::ui::ConfigureShader(hash, &entry);
    entry.on_replace = [hash, existing = std::move(existing), night = std::move(entry.on_replace)](auto* cmd) {
      if(hash==0x3B15DAABu &&clouds::mode>.5f)return existing(cmd);
      if (!night(cmd)) return existing(cmd);
      if (hash == 0x3B15DAABu) {
        clouds::runtime::PrepareCelestialSky(cmd,false);
        return BindReceiver(cmd,true);
      }
      return BindReceiver(cmd, true);
    };
  }
}

void OnPresent(reshade::api::command_queue* queue, reshade::api::swapchain* swapchain,
               const reshade::api::rect* source, const reshade::api::rect* dest,
               uint32_t count, const reshade::api::rect* dirty) {
  // Cache both pristine layouts before either feature can detour the common builder.
  const bool fill_supported = fill_native::Prepare();
  const bool share_common = fill_supported && nights::Supported()
                            && fill_native::layout.common == nights::detected_layout.common;
  if (!nights::attempted && nights::Supported()
      && (clouds::mode > .5f || (player_lighting != 0.f && share_common))) nights::Install();
  nights::ui::OnPresent(queue, swapchain, source, dest, count, dirty);
  hartapfelfx::sky::emission::enabled.store(clouds::mode>.5f&&nights::Supported(),std::memory_order_relaxed);
  hartapfelfx::sky::emission::evening_blend.store(std::clamp(hartapfelfx::sky::evening_sunlight,0.f,1.f),std::memory_order_relaxed);
  clouds::families::Update(clouds::mode>.5f && nights::Supported());
  lighting::OnPresent(swapchain->get_device());
  if (player_lighting != 0.f && !fill_native::attempted) {
    const bool installed = fill_native::Install(!(share_common && nights::installed));
    reshade::log::message(installed ? reshade::log::level::info : reshade::log::level::warning,
                          installed ? "[HartapfelFX] Player fill light hooks installed."
                                    : "[HartapfelFX] Player fill lights are unavailable for this executable.");
  }
  player_fill::Publish(player_lighting != 0.f && fill_native::installed,
                       match_world != 0.f, gameplay_strength, cutscene_strength);
}

void DrawAddon(reshade::api::effect_runtime* runtime) {
  hartapfelfx::ui::Draw(settings,runtime);
  if(hartapfelfx::ui::selected==hartapfelfx::ui::Tab::Lighting) {
    if(lighting::soft!=0.f &&lighting::sun::attempted &&!lighting::sun::native_value)
      ImGui::TextWrapped("Shadow softness is unavailable for this game version.");
    if(fill_native::attempted &&!fill_native::installed)
      ImGui::TextWrapped("Character fill light is unavailable for this game version.");
  }
  if(hartapfelfx::ui::selected==hartapfelfx::ui::Tab::Nights &&!nights::Supported())
    ImGui::TextWrapped("Night lighting is unavailable for this game version.");
}

void ImportStandaloneSettings() {
  constexpr char night_config[] = "renodx-darkernights-remastered";
  constexpr char fill_config[] = "renodx-witcher3remastered-graphics";
  nights::ui::MigrateProfiles(night_config);
  for (unsigned slot = 1; slot <= 3; ++slot) {
    const auto suffix = "-preset" + std::to_string(slot);
    const auto target = renodx::utils::settings::global_name + suffix;
    int water_enabled = 0;
    if (!reshade::get_config_value(nullptr, target.c_str(), "WaterEnabledV1", water_enabled)) {
      int old_surface = 0;
      float old_murk = 0.f;
      const bool has_surface = reshade::get_config_value(nullptr, target.c_str(), "WaterSurfaceV1", old_surface);
      const bool has_murk = reshade::get_config_value(nullptr, target.c_str(), "WaterMurkV1", old_murk);
      if (has_surface || has_murk) {
        reshade::set_config_value(nullptr, target.c_str(), "WaterEnabledV1", int(old_surface > 0 || old_murk > 0.f));
      }
    }
    float shadow_strength = 0.f;
    int old_shadows = 0;
    if (!reshade::get_config_value(nullptr, target.c_str(), "CloudShadowStrengthV1", shadow_strength)
        && reshade::get_config_value(nullptr, target.c_str(), "CloudShadowsV2", old_shadows)) {
      reshade::set_config_value(nullptr, target.c_str(), "CloudShadowStrengthV1", old_shadows != 0 ? 100.f : 0.f);
    }
    const auto legacy_nights = night_config + suffix;
    const auto legacy_fill = fill_config + suffix;
    for (auto* setting : settings) {
      if (setting->key.empty() || !setting->binding || setting->is_global) continue;
      const bool night = std::find(nights::ui::settings.begin(), nights::ui::settings.end(), setting) != nights::ui::settings.end();
      const bool graphics = !night &&hartapfelfx::ui::TabForKey(setting->key)==hartapfelfx::ui::Tab::Lighting;
      if (!graphics && !night) continue;
      const char* key = setting->key.c_str();
      char value[64]{};
      size_t length = sizeof(value);
      if (reshade::get_config_value(nullptr, target.c_str(), key, value, &length)) continue;
      length = sizeof(value);
      const auto& source = graphics ? legacy_fill : legacy_nights;
      if (reshade::get_config_value(nullptr, source.c_str(), key, value, &length) && length <= sizeof(value)) {
        reshade::set_config_value(nullptr, target.c_str(), key, static_cast<const char*>(value));
      }
    }
  }
}

void OnPresetOff() {
  hartapfelfx::sky::emission::enabled.store(false,std::memory_order_relaxed);
  renodx::utils::settings::UpdateSetting("FogEnabled", 0.f);
  renodx::utils::settings::UpdateSetting("WaterEnabledV1", 0.f);
  renodx::utils::settings::UpdateSetting("CloudModeV2", 0.f);
  renodx::utils::settings::UpdateSetting("PlayerLighting", 0.f);
  renodx::utils::settings::UpdateSetting("GameplayLightStrength", 1.f);
  renodx::utils::settings::UpdateSetting("CutsceneLightStrength", 1.f);
  renodx::utils::settings::UpdateSetting("MatchPlayerLighting", 0.f);
  player_fill::Publish(false, false, 1.f, 1.f);
  renodx::utils::settings::UpdateSetting("PBRLighting", 0.f);
  renodx::utils::settings::UpdateSetting("SoftShadows", 0.f);
  renodx::utils::settings::UpdateSetting("ContactShadows", 0.f);
  renodx::utils::settings::UpdateSetting("EveningSunlightColourV1", 0.f);
  lighting::sun::diameter.Apply(lighting::sun::native_value, false, 0.f);
  nights::ui::OnPresetOff();
}
}  // namespace
extern "C" __declspec(dllexport) constexpr const char* NAME = "HartapfelFX - The Witcher 3 Remastered";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "Volumetric clouds, fog, PBR lighting, shadows, player fill lights and Darker Nights for DX12 Raster, RT and PT.";
BOOL APIENTRY DllMain(HMODULE module, DWORD reason, LPVOID) {
  if (reason == DLL_PROCESS_ATTACH) {
    if (!reshade::register_addon(module)) return FALSE;
    renodx::utils::settings::global_name = "thewitcher3remastered-hartapfelfx";
    settings.insert(settings.end(),nights::ui::settings.begin(),nights::ui::settings.end());
    ImportStandaloneSettings();
    hartapfelfx::ui::Configure(&settings);
    nights::observe_native_primary=hartapfelfx::sky::emission::ObservePrimary;
    nights::observe_celestial_frame=hartapfelfx::sky::emission::ObserveFrame;
    nights::observe_game_time=hartapfelfx::sky::emission::ObserveTime;
    nights::edit_celestial_light=hartapfelfx::sky::emission::Apply;
    nights::edit_shared_common_constants = [](void* output) {
      const auto controls = player_fill::GetControls();
      if (controls.enabled && fill_native::layout.common == nights::detected_layout.common) {
        player_fill::ApplyCommon(output, controls);
      }
    };
    ConfigureNightShaders();
    lighting::ConfigureShaders(&shaders);
    for (auto& [hash, shader] : shaders) {
      if (!shader.on_replace) continue;
      shader.on_replace = [replace = std::move(shader.on_replace)](auto* cmd) {
        const bool active = replace(cmd);
        auto* command = renodx::utils::data::Get<clouds::runtime::CommandData>(cmd);
        if (!command) return active;
        if (active) {
          command->replacement_bound = true;
        } else if (command->replacement_bound) {
          // Native draws often omit a redundant PSO bind. Restore once when
          // leaving a replacement; inactive draws need no driver call.
          if (const auto* native = renodx::utils::data::Get<lighting::bindings::CommandData>(cmd);
              native && native->last_pipeline.handle) {
            cmd->bind_pipeline(native->last_stages, native->last_pipeline);
          }
          command->replacement_bound = false;
        }
        return active;
      };
    }
    reshade::register_event<reshade::addon_event::present>(OnPresent);
    renodx::mods::shader::use_root_signature_cbv = false;
    renodx::mods::shader::force_pipeline_cloning = true;
    renodx::utils::descriptor::trace_descriptor_tables = false;
  }
  if (reason == DLL_PROCESS_DETACH) {
    hartapfelfx::sky::emission::enabled.store(false,std::memory_order_relaxed);
    reshade::unregister_event<reshade::addon_event::present>(OnPresent);
    reshade::unregister_overlay(renodx::utils::settings::overlay_title.c_str(), DrawAddon);
    player_fill::Publish(false, false, 1.f, 1.f);
    lighting::sun::diameter.Apply(lighting::sun::native_value, false, 0.f);
    nights::vegetation::adjustments.store(0, std::memory_order_relaxed);
    if (nights::installed) nights::Update(false);
  }
  renodx::utils::settings::Use(reason, &settings, &OnPresetOff);
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::unregister_overlay(renodx::utils::settings::overlay_title.c_str(), renodx::utils::settings::OnRegisterOverlay);
    reshade::register_overlay(renodx::utils::settings::overlay_title.c_str(), DrawAddon);
    renodx::utils::settings::on_preset_changed_callbacks.emplace_back([] {
      reshade::set_config_value(nullptr, renodx::utils::settings::global_name.c_str(),
                               "SelectedPreset", renodx::utils::settings::preset_index);
    });
    int slot = 1;
    if (reshade::get_config_value(nullptr, renodx::utils::settings::global_name.c_str(), "SelectedPreset", slot)
        && slot >= 0 && slot <= 3) {
      renodx::utils::settings::preset_index = slot;
      if (slot == 0) OnPresetOff();
      else if (slot != 1) renodx::utils::settings::LoadSettings(renodx::utils::settings::GetCurrentPresetName());
    }
  }
  renodx::mods::shader::Use(reason, shaders);
  hartapfelfx::descriptors::Use(reason);
  fog::Use(reason);
  fog::runtime::Use(reason, &injection);
  lighting::Use(reason);
  clouds::runtime::Use(reason, &injection);
  lighting::ray::hits::UseDispatch(reason);
  nights::vegetation::Use(reason);
  if (reason == DLL_PROCESS_DETACH) reshade::unregister_addon(module);
  return TRUE;
}
