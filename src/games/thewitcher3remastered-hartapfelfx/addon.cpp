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
bool draw_nights = false;
using Setting = renodx::utils::settings::Setting;
renodx::utils::settings::Settings settings = {
    new Setting{
        .key = "PlayerLighting",
        .binding = &player_lighting,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Player Fill Light",
        .section = "Player Fill Lights",
        .tooltip = "Controls the extra light that follows the camera during gameplay, dialogue and cutscenes.",
        .labels = {"Native", "Improved"},
    },
    new Setting{
        .key = "GameplayLightStrength",
        .binding = &gameplay_strength,
        .default_value = .2f,
        .label = "Gameplay Strength",
        .section = "Player Fill Lights",
        .tooltip = "Brightness of the camera-following light during gameplay. 0 removes it; 1 keeps its original strength before environment matching.",
        .min = 0.f,
        .max = 1.f,
        .format = "%.2f",
        .is_enabled = [] { return player_lighting != 0.f; },
    },
    new Setting{
        .key = "CutsceneLightStrength",
        .binding = &cutscene_strength,
        .default_value = .2f,
        .label = "Dialogue & Cutscene Strength",
        .section = "Player Fill Lights",
        .tooltip = "Brightness of camera fill during dialogue, cutscenes and interior scenes. Ordinary lamps are unaffected.",
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
        .label = "Match Environment Lighting",
        .section = "Player Fill Lights",
        .tooltip = "Makes player fill respond to the environment lighting, helping characters blend into their surroundings.",
        .labels = {"Off", "On"},
        .is_enabled = [] { return player_lighting != 0.f; },
    },
    new Setting{
        .key = "PBRLighting",
        .binding = &lighting::pbr,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "PBR Lighting",
        .section = "Lighting & Shadows",
        .tooltip = "Improves sunlight, lamp shading and rough highlights. Also improves reflected and bounced lighting in RT and PT.",
        .labels = {"Native", "Improved"},
    },

    new Setting{
        .key = "SoftShadows",
        .binding = &lighting::soft,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Sun & Moon Shadows",
        .section = "Lighting & Shadows",
        .tooltip = "Improves directional shadow softness. Raster uses distance-aware filtering; RT and PT use the native light size for traced lighting.",
        .labels = {"Native", "Improved"},
    },

    new Setting{
        .key = "SunDiameter",
        .binding = &lighting::diameter,
        .default_value = .35f,
        .label = "Light Size",
        .section = "Lighting & Shadows",
        .tooltip = "Larger values produce softer shadows. Measured in degrees. RT and PT also use this size when sampling the light in reflections. The main sky's sun and moon artwork is unchanged.",
        .min = .05f, .max = 2.f, .format = "%.3f degrees",
        .is_enabled = [] { return lighting::soft != 0.f; },
    },

    new Setting{
        .key = "ContactShadows",
        .binding = &lighting::contact_shadows,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Contact Shadows",
        .section = "Lighting & Shadows",
        .tooltip = "Adds short sun and moon shadows around visible geometry in Raster, RT and PT. Supplements native shadows; off-screen casters still use the game's visibility.",
        .labels = {"Native", "Improved"},
    },

    new Setting{
        .key = "ContactShadowLength",
        .binding = &lighting::reach,
        .default_value = .3f,
        .label = "Contact Shadow Reach",
        .section = "Lighting & Shadows",
        .tooltip = "Maximum distance searched for nearby sun and moon shadow casters. Longer distances can reveal missing off-screen geometry.",
        .min = .05f, .max = 1.f, .format = "%.2f m",
        .is_enabled = [] { return lighting::contact_shadows != 0.f; },
    },

    new Setting{
        .key = "CloudModeV2", .binding = &clouds::mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f, .label = "Clouds", .section = "Volumetric Clouds",
        .labels = {"Native", "Volumetric"}},
    new Setting{
        .key = "CloudQualityV2", .binding = &clouds::quality,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f, .label = "Cloud Quality", .section = "Volumetric Clouds",
        .tooltip = "Controls ray steps, lighting, erosion, atmospheric integration and shadow-map quality.",
        .labels = {"Low", "Medium", "High", "Ultra", "Cinematic", "Maximum"}},
    new Setting{
        .key = "CloudStepSizeV2", .binding = &clouds::step_size,
        .default_value = 75.f, .label = "Cloud Step Size", .section = "Volumetric Clouds",
        .min = 50.f, .max = 200.f, .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudShadowsV2", .binding = &clouds::shadows,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f, .label = "Cloud Shadows", .section = "Volumetric Clouds",
        .labels = {"Off", "On"}},
    new Setting{
        .key = "CloudCoverageV2", .binding = &clouds::coverage,
        .default_value = 100.f, .label = "Cloud Coverage", .section = "Cloud Appearance",
        .tooltip = "100% uses the game's weather coverage without scaling it.",
        .min = 0.f, .max = 200.f, .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudDensityV3", .binding = &clouds::density,
        .default_value = 20.f, .label = "Cloud Density", .section = "Cloud Appearance",
        .tooltip = "100% uses the cloud material's optical density.",
        .min = 0.f, .max = 400.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudSizeV2", .binding = &clouds::size,
        .default_value = 100.f, .label = "Cloud Size", .section = "Cloud Appearance",
        .tooltip = "Changes formation scale without moving the game's weather fronts.",
        .min = 25.f, .max = 400.f, .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudThicknessV2", .binding = &clouds::thickness,
        .default_value = 100.f, .label = "Cloud Layer Thickness", .section = "Cloud Appearance",
        .tooltip = "100% uses the cloud material's layer thickness.",
        .min = 50.f, .max = 300.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudDetailV2", .binding = &clouds::detail,
        .default_value = 130.f, .label = "Cloud Surface Detail", .section = "Cloud Shape",
        .tooltip = "100% uses the cloud material's surface detail strength.",
        .min = 0.f, .max = 800.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudDetailSizeV2", .binding = &clouds::detail_size,
        .default_value = 45.f, .label = "Cloud Detail Size", .section = "Cloud Shape",
        .tooltip = "100% uses the cloud material's detail size.",
        .min = 20.f, .max = 200.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "CloudBaseSoftnessV2", .binding = &clouds::base_softness,
        .default_value = 0.f, .label = "Cloud Base Softness", .section = "Cloud Shape",
        .min = 0.f, .max = 100.f, .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "FogEnabled",
        .binding = &injection.enabled,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Atmospheric Fog",
        .section = "HartapfelFX",
        .tooltip = "Weather-driven fog with shadowed sunlight, moonlight and local lights. FAST sampling and temporal reconstruction run at both quality levels.",
        .labels = {"Native", "Volume Grid"}},
    new Setting{
        .key = "FogQuality",
        .binding = &injection.quality,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Fog Quality",
        .section = "HartapfelFX",
        .labels = {"Balanced", "High"},
        .parse = [](float value) { return value + 1.f; }},
    new Setting{
        .key = "FogDensity",
        .binding = &injection.density,
        .default_value = 100.f,
        .label = "Fog Density",
        .section = "HartapfelFX",
        .min = 0.f,
        .max = 300.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "FogSunlight",
        .binding = &injection.sunlight,
        .default_value = 35.f,
        .label = "Sun and Moon Scattering",
        .section = "HartapfelFX",
        .min = 0.f,
        .max = 200.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "FogAnisotropy",
        .binding = &injection.anisotropy,
        .default_value = 0.75f,
        .label = "Scattering Anisotropy",
        .section = "HartapfelFX",
        .min = 0.f,
        .max = .85f,
        .format = "%.2f"},
    new Setting{
        .key = "FogLocalLight",
        .binding = &injection.local_strength,
        .default_value = 100.f,
        .label = "Local Light Scattering",
        .section = "HartapfelFX",
        .min = 0.f,
        .max = 200.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "FogStart",
        .binding = &injection.start_distance,
        .default_value = 0.f,
        .label = "Fog Start Distance",
        .section = "HartapfelFX",
        .min = 0.f,
        .max = 100.f},
    new Setting{
        .key = "FogHeight",
        .binding = &injection.height_falloff,
        .default_value = 100.f,
        .label = "Height Falloff",
        .section = "HartapfelFX",
        .min = 0.f,
        .max = 300.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "FogSkyDensity",
        .binding = &injection.sky_density,
        .default_value = 200.f,
        .label = "Sky Haze Density",
        .section = "HartapfelFX",
        .min = 0.f,
        .max = 300.f,
        .parse = [](float value) { return value * .01f; }},
    new Setting{
        .key = "FogSmoothReconstruction",
        .binding = &injection.reconstruction,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Smooth Lighting Reconstruction",
        .section = "HartapfelFX",
        .tooltip = "Cubic filtering softens lighting transitions with additional buffer reads. Opacity retains the current trilinear result.",
        .labels = {"Off", "On"}},
    new Setting{
        .key = "FogStatus",
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .label = "Integration Status",
        .section = "HartapfelFX",
        .on_draw = []() {
          ImGui::Text("Sun inputs: %llu | Fog matches: %llu | Native fallbacks: %llu",
                      static_cast<unsigned long long>(fog::sun_captures.load()),
                      static_cast<unsigned long long>(fog::fog_matches.load()),
                      static_cast<unsigned long long>(fog::fog_fallbacks.load()));
          return false;
        }},

};
bool BindReceiver(reshade::api::command_list* cmd, bool night = false) {
  auto* state = renodx::utils::shader::GetCurrentPixelState(renodx::utils::shader::GetCurrentState(cmd));
  // A failed initial PSO clone has no retained subobjects for a lazy retry.
  // Gate every replacement before the shared shader module can attempt one.
  if (state->pipeline_details
      && state->pipeline_details->initialized_replacement
      && state->pipeline_details->replacement_pipeline.handle != 0) {
    const bool fog_ready = injection.enabled > .5f && fog::runtime::PrepareReceiver(cmd);
    const bool cloud_ready = clouds::runtime::PrepareReceiver(cmd, fog_ready, night);
    if (fog_ready || cloud_ready) return true;
  }
  cmd->bind_pipeline(state->applied_stage, state->pipeline);
  return false;
}
bool BindCloudShadow(reshade::api::command_list* cmd, const renodx::utils::shader::StageState& state, bool compute, bool night = false) {
  if ((clouds::mode > .5f || night) && state.pipeline_details && state.pipeline_details->initialized_replacement
      && state.pipeline_details->replacement_pipeline.handle != 0 && clouds::runtime::PrepareShadowReceiver(cmd, compute)) return true;
  cmd->bind_pipeline(state.applied_stage, state.pipeline);
  return false;
}
bool BindCloudGraphics(reshade::api::command_list* cmd) {
  return BindCloudShadow(cmd, *renodx::utils::shader::GetCurrentPixelState(renodx::utils::shader::GetCurrentState(cmd)), false);
}
bool BindCloudVertex(reshade::api::command_list* cmd) {
  return BindCloudShadow(cmd, *renodx::utils::shader::GetCurrentVertexState(renodx::utils::shader::GetCurrentState(cmd)), false);
}
bool BindCloudMotion(reshade::api::command_list* cmd) {
  auto* state = renodx::utils::shader::GetCurrentComputeState(renodx::utils::shader::GetCurrentState(cmd));
  if (state->pipeline_details && state->pipeline_details->initialized_replacement
      && state->pipeline_details->replacement_pipeline.handle != 0 && clouds::runtime::PrepareMotion(cmd)) return true;
  cmd->bind_pipeline(state->applied_stage, state->pipeline);
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
    {0x449D3390, {.crc32 = 0x449D3390, .code = __0x449D3390, .on_replace = [](auto* cmd) { return BindReceiver(cmd); }}},
    {0x3B15DAAB, {.crc32 = 0x3B15DAAB, .code = __0x3B15DAAB, .on_replace = &BindCloudGraphics}},
    {0xC60F2B46, {.crc32 = 0xC60F2B46, .code = __0xC60F2B46, .on_replace = [](auto* cmd) { return BindReceiver(cmd); }}},
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
                         cmd->bind_pipeline(state->applied_stage, state->pipeline);
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
      if (!night(cmd)) return existing(cmd);
      if (hash == 0x3B15DAABu) {
        return BindCloudShadow(cmd, *renodx::utils::shader::GetCurrentPixelState(renodx::utils::shader::GetCurrentState(cmd)), false, true);
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
  if (player_lighting != 0.f && share_common && !nights::attempted) nights::Install();
  nights::ui::OnPresent(queue, swapchain, source, dest, count, dirty);
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
  if (!ImGui::BeginTabBar("HartapfelFXTabs")) return;
  if (ImGui::BeginTabItem("HartapfelFX")) {
    draw_nights = false;
    renodx::utils::settings::OnRegisterOverlay(runtime);
    if (lighting::soft != 0.f && lighting::sun::attempted && !lighting::sun::native_value)
      ImGui::TextDisabled("Traced light size is unavailable for this game version.");
    if (fill_native::attempted && !fill_native::installed) ImGui::TextDisabled("Player Fill Lights are unavailable for this game version.");
    ImGui::EndTabItem();
  }
  if (ImGui::BeginTabItem("Darker Nights")) {
    draw_nights = true;
    renodx::utils::settings::OnRegisterOverlay(runtime);
    if (!nights::Supported()) ImGui::TextDisabled("Darker Nights is unavailable for this game version.");
    ImGui::EndTabItem();
  }
  ImGui::EndTabBar();
}

void ImportStandaloneSettings() {
  constexpr char night_config[] = "renodx-darkernights-remastered";
  constexpr char fill_config[] = "renodx-witcher3remastered-graphics";
  nights::ui::MigrateProfiles(night_config);
  for (unsigned slot = 1; slot <= 3; ++slot) {
    const auto suffix = "-preset" + std::to_string(slot);
    const auto target = renodx::utils::settings::global_name + suffix;
    const auto legacy_nights = night_config + suffix;
    const auto legacy_fill = fill_config + suffix;
    for (auto* setting : settings) {
      if (setting->key.empty() || !setting->binding || setting->is_global) continue;
      const bool graphics = setting->section == "Player Fill Lights" || setting->section == "Lighting & Shadows";
      const bool night = std::find(nights::ui::settings.begin(), nights::ui::settings.end(), setting) != nights::ui::settings.end();
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
  renodx::utils::settings::UpdateSetting("FogEnabled", 0.f);
  renodx::utils::settings::UpdateSetting("CloudModeV2", 0.f);
  renodx::utils::settings::UpdateSetting("PlayerLighting", 0.f);
  renodx::utils::settings::UpdateSetting("GameplayLightStrength", 1.f);
  renodx::utils::settings::UpdateSetting("CutsceneLightStrength", 1.f);
  renodx::utils::settings::UpdateSetting("MatchPlayerLighting", 0.f);
  player_fill::Publish(false, false, 1.f, 1.f);
  renodx::utils::settings::UpdateSetting("PBRLighting", 0.f);
  renodx::utils::settings::UpdateSetting("SoftShadows", 0.f);
  renodx::utils::settings::UpdateSetting("ContactShadows", 0.f);
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
    for (auto* setting : settings) setting->is_visible = [] { return !draw_nights; };
    for (auto* setting : nights::ui::settings) {
      setting->is_visible = [visible = std::move(setting->is_visible)] {
        return draw_nights && (!visible || visible());
      };
      settings.push_back(setting);
    }
    ImportStandaloneSettings();
    nights::edit_shared_common_constants = [](void* output) {
      const auto controls = player_fill::GetControls();
      if (controls.enabled && fill_native::layout.common == nights::detected_layout.common) {
        player_fill::ApplyCommon(output, controls);
      }
    };
    ConfigureNightShaders();
    lighting::ConfigureShaders(&shaders);
    reshade::register_event<reshade::addon_event::present>(OnPresent);
    renodx::mods::shader::use_root_signature_cbv = false;
    renodx::mods::shader::force_pipeline_cloning = true;
    renodx::utils::descriptor::trace_descriptor_tables = true;
  }
  if (reason == DLL_PROCESS_DETACH) {
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
  fog::Use(reason);
  fog::runtime::Use(reason, &injection);
  lighting::Use(reason);
  clouds::runtime::Use(reason, &injection);
  lighting::ray::hits::UseDispatch(reason);
  renodx::utils::swapchain::Use(reason);
  nights::vegetation::Use(reason);
  if (reason == DLL_PROCESS_DETACH) reshade::unregister_addon(module);
  return TRUE;
}
