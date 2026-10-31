/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once

#include <windows.h>
#include <tlhelp32.h>
#include <detours.h>

#include <algorithm>
#include <array>
#include <atomic>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <mutex>
#include <shared_mutex>
#include <utility>
#include <vector>
#include <intrin.h>

#include "./night_exposure.hpp"
#include "./lighting/player_fill.hpp"
#include "./night_normalization.hpp"

namespace witcher3classic::night {

inline float enabled = presets::Default(presets::night, "NightLightingEnabled");
inline float moonlight = presets::Default(presets::night, "NightMoonlightIntensity");
inline float ambient_light = presets::Default(presets::night, "NightAmbientLight");
inline float ambient_shadow = presets::Default(presets::night, "NightAmbientShadow");
inline float reflection_light = presets::Default(presets::night, "NightReflectionLight");
inline float reflection_shadow = presets::Default(presets::night, "NightReflectionShadow");
inline float fog_brightness = presets::Default(presets::night, "NightFogBrightness");
inline float haze_brightness = presets::Default(presets::night, "NightHazeBrightness");
inline float sky_brightness = presets::Default(presets::night, "NightSkyBrightness");
inline float moon_brightness = presets::Default(presets::night, "NightMoonBrightness");
inline float moon_size = presets::Default(presets::night, "NightMoonSize");
inline float cloud_brightness = presets::Default(presets::night, "NightCloudBrightness");
inline float star_brightness = presets::Default(presets::night, "NightStarBrightness");
inline float sky_haze_brightness = presets::Default(presets::night, "NightSkyHazeBrightness");
inline float water_ambient = presets::Default(presets::night, "NightWaterAmbient");
inline float darkening_start = presets::Default(presets::night, "NightDarkeningStart");
inline float full_darkness_start = presets::Default(presets::night, "NightFullDarknessStart");
inline float fade_out_start = presets::Default(presets::night, "NightFadeOutStart");
inline float darkening_end = presets::Default(presets::night, "NightDarkeningEnd");

// Same cyclic schedule as the standalone Remastered addon: start minute and
// three forward offsets. Equal adjacent events permit instantaneous fades.
inline uint64_t NightSchedule() {
  uint64_t minutes[4]{};
  unsigned index = 0;
  for (float hour : {darkening_start, full_darkness_start, fade_out_start, darkening_end}) {
    if (!std::isfinite(hour) || hour < 0.f || hour > 24.f) return 0;
    minutes[index++] = static_cast<uint64_t>(std::round(hour * 60.f)) % 1440;
  }
  for (unsigned i = 1; i < 4; ++i) {
    minutes[i] = (minutes[i] + 1440 - minutes[0]) % 1440;
  }
  if (minutes[3] == 0 || minutes[1] > minutes[2] || minutes[2] > minutes[3]) return 0;
  return minutes[0] | (minutes[1] << 16) | (minutes[2] << 32) | (minutes[3] << 48);
}

inline float ClockMultiplier(float time, uint64_t schedule, float intensity, float maximum = 2.f) {
  if (schedule == 0 || !std::isfinite(time) || time < 0.f || time > 1.f
      || !std::isfinite(intensity) || intensity == 1.f) return 1.f;
  const float full = static_cast<float>((schedule >> 16) & 0xffff);
  const float fade_out = static_cast<float>((schedule >> 32) & 0xffff);
  const float end = static_cast<float>(schedule >> 48);
  const float elapsed = std::fmod(time * 1440.f + 1440.f - static_cast<float>(schedule & 0xffff), 1440.f);
  if (elapsed >= end) return 1.f;
  const float fade = (elapsed < full ? (elapsed / full)
                     : elapsed <= fade_out ? 1.f : ((end - elapsed) / (end - fade_out)));
  return 1.f + (std::clamp(intensity, 0.f, maximum) - 1.f) * fade * fade * (3.f - 2.f * fade);
}

struct Controls {
  uint64_t schedule = 0;
  float intensity = 1.f;
  float ambient_light = 1.f, ambient_shadow = 1.f;
  float reflection_light = 1.f, reflection_shadow = 1.f;
  float fog = 1.f, haze = 1.f, sky = 1.f;
  float sky_haze = 1.f;
  float moon_brightness = 1.f, moon_size = 1.f;
  float clouds = 1.f, stars = 1.f;
  float water = 1.f;
};
struct State {
  std::shared_mutex mutex;
  Controls controls;
  std::atomic<float> hour{-1.f};
  std::atomic<uint64_t> common_uploads{0};
};
// Native renderer callbacks can outlive a ReShade addon registration. Keep
// their data alive alongside the pinned module, including during teardown.
inline auto* state = new State;
using BuildDirectConstants = void (*)(void*, const void*);
inline BuildDirectConstants build_direct_constants = nullptr;
using BuildCommonConstants = void (*)(void*, const void*, uint64_t, uint64_t, int, uint32_t);
inline BuildCommonConstants build_common_constants = nullptr;
using MapBuffer = void* (*)(const void*, uint32_t, uint32_t, uint32_t);
using UnmapBuffer = void (*)(const void*);
inline MapBuffer map_buffer = nullptr;
inline UnmapBuffer unmap_buffer = nullptr;
inline bool checked = false, supported = false, attempted = false, installed = false;
inline bool common_supported = false;
using SetPixelConstants = void (*)(uint32_t, const float*, uint32_t);
inline SetPixelConstants set_pixel_constants = nullptr;
inline uintptr_t constants_image_base = 0;
inline std::atomic<float> night_weight = 0.f;

inline void ExposureConstantsHook(uint32_t first, const float* values, uint32_t count) {
  if (count == 1 && values && (first == 20 || first == 24 || first == 29)) {
    const uintptr_t caller = reinterpret_cast<uintptr_t>(_ReturnAddress()) - constants_image_base;
    if ((first == 20 && caller == exposure::rate_caller)
        || ((first == 24 || first == 29) && (caller == 0xc56684 || caller == 0xc5675b))) {
      float adjusted[4];
      std::memcpy(adjusted, values, sizeof(adjusted));
      if (exposure::AdjustConstants(first, adjusted, caller, night_weight.load(std::memory_order_relaxed))) {
        set_pixel_constants(first, adjusted, count);
        return;
      }
    }
  }
  set_pixel_constants(first, values, count);
}

inline bool ValidateCommonImage(const uint8_t* image) {
  constexpr uint8_t prefix[] = {0x48,0x89,0x5c,0x24,0x18,0x48,0x89,0x74,0x24,0x20,0x55,0x57,0x41,0x55,0x41,0x56};
  constexpr uint8_t ambient[] = {0xf3,0x41,0x0f,0x11,0x86,0x70,0x0b,0x00,0x00};
  constexpr uint8_t reflection[] = {0xf3,0x41,0x0f,0x11,0x86,0x80,0x0b,0x00,0x00};
  constexpr uint8_t padding[] = {0x4d,0x89,0xa6,0x58,0x02,0x00,0x00};
  constexpr uint8_t sky_padding[] = {0x41,0x89,0x96,0x8c,0x0b,0x00,0x00};
  constexpr uint8_t map_prefix[] = {0x48,0x89,0x6c,0x24,0x20,0x56,0x41,0x54,0x41,0x57,0x48,0x83,0xec,0x40};
  constexpr uint8_t unmap_prefix[] = {0x40,0x57,0x48,0x83,0xec,0x60,0x8b,0x09};
  return std::memcmp(image + 0xcda720, prefix, sizeof(prefix)) == 0
      && std::memcmp(image + 0xcdc9ac, ambient, sizeof(ambient)) == 0
      && std::memcmp(image + 0xcdca0c, reflection, sizeof(reflection)) == 0
      && std::memcmp(image + 0xcdb800, padding, sizeof(padding)) == 0
      && std::memcmp(image + 0xcdc9f8, sky_padding, sizeof(sky_padding)) == 0
      && std::memcmp(image + 0xeb10, map_prefix, sizeof(map_prefix)) == 0
      && std::memcmp(image + 0xee40, unmap_prefix, sizeof(unmap_prefix)) == 0;
}

inline bool ValidateImage(const uint8_t* image) {
  if (!image) return false;
  const auto* dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(image);
  if (dos->e_magic != IMAGE_DOS_SIGNATURE || dos->e_lfanew < 0 || dos->e_lfanew > 4096) return false;
  const auto* pe = reinterpret_cast<const IMAGE_NT_HEADERS64*>(image + dos->e_lfanew);
  if (pe->Signature != IMAGE_NT_SIGNATURE || pe->FileHeader.Machine != IMAGE_FILE_MACHINE_AMD64
      || pe->OptionalHeader.Magic != IMAGE_NT_OPTIONAL_HDR64_MAGIC
      || pe->FileHeader.TimeDateStamp != 0x5bdf65b7 || pe->OptionalHeader.SizeOfImage != 0x3673000) return false;
  constexpr uint8_t prefix[] = {0x48,0x89,0x5c,0x24,0x08,0x48,0x89,0x74,0x24,0x10,0x57,0x48,0x83,0xec,0x70};
  constexpr uint8_t color[] = {0x8b,0x82,0xc0,0xaf,0x00,0x00,0x48,0x8b,0x99,0xf8,0x00,0x00,0x00};
  constexpr uint8_t sides[] = {0x8b,0x82,0xd0,0xaf,0x00,0x00,0x89,0x83,0x30,0x03,0x00,0x00};
  constexpr uint8_t opposite[] = {0x8b,0x82,0xe0,0xaf,0x00,0x00,0x89,0x83,0x40,0x03,0x00,0x00};
  // Static m_globalLight +0x8e0 resolves to cached parameters +0x640. The
  // per-view parameters begin at +0xa10; first color's time is +0x20.
  constexpr uint8_t clock_cache[] = {0xf3,0x0f,0x10,0x43,0x10,0x8b,0x08,0x89,0x4f,0x10};
  constexpr uint8_t clock_store[] = {0xf3,0x0f,0x11,0x47,0x20};
  return std::memcmp(image + 0xc379a0, prefix, sizeof(prefix)) == 0
      && std::memcmp(image + 0xc379af, color, sizeof(color)) == 0
      && std::memcmp(image + 0xc379fe, sides, sizeof(sides)) == 0
      && std::memcmp(image + 0xc37a2e, opposite, sizeof(opposite)) == 0
      && std::memcmp(image + 0x2d61eb, clock_cache, sizeof(clock_cache)) == 0
      && std::memcmp(image + 0x2d6207, clock_store, sizeof(clock_store)) == 0;
}

inline bool Supported() {
  if (!checked) {
    checked = true;
    supported = ValidateImage(reinterpret_cast<const uint8_t*>(GetModuleHandleW(nullptr)));
    common_supported = supported && ValidateCommonImage(reinterpret_cast<const uint8_t*>(GetModuleHandleW(nullptr)));
    lighting::player_fill::supported = common_supported
        && lighting::player_fill::Validate(reinterpret_cast<const uint8_t*>(GetModuleHandleW(nullptr)));
    if (supported) {
      const auto* image = reinterpret_cast<const uint8_t*>(GetModuleHandleW(nullptr));
      exposure::Validate(image, 0x3673000);
      normalization::Validate(image, 0x3673000);
    }
  }
  return supported;
}

inline void ScaleRGB(void* constants, unsigned offset, float multiplier) {
  if (!constants || multiplier == 1.f || !std::isfinite(multiplier)) return;
  auto* bytes = static_cast<uint8_t*>(constants);
  for (unsigned channel = 0; channel < 3; ++channel) {
    float value;
    std::memcpy(&value, bytes + offset + channel * sizeof(float), sizeof(value));
    if (!std::isfinite(value)) continue;
    value *= multiplier;
    std::memcpy(bytes + offset + channel * sizeof(float), &value, sizeof(value));
  }
}

inline void ApplyMoonlight(void* constants, float multiplier) {
  // Native directional RGB c1/c51/c52, including forward side colors. Alpha,
  // direction, ambient probes and the tiled local-light records stay native.
  for (unsigned offset : {0x10u, 0x330u, 0x340u}) {
    ScaleRGB(constants, offset, multiplier);
  }
}

inline void ApplyCommon(void* constants, const Controls& controls, float time) {
  const float weight = 1.f - ClockMultiplier(time, controls.schedule, 0.f);
  if (!constants || weight <= 0.f) return;
  auto* bytes = static_cast<uint8_t*>(constants);
  // Native c183.xy diffuse and c184.xy specular probe gains. Preserve direct
  // diffuse/specular enables, distance scaling and the probe data itself.
  for (const auto& [offset, intensity] : {
           std::pair{0xb70u, controls.ambient_light}, std::pair{0xb74u, controls.ambient_shadow},
           std::pair{0xb80u, controls.reflection_light}, std::pair{0xb84u, controls.reflection_shadow}}) {
    float value;
    std::memcpy(&value, bytes + offset, sizeof(value));
    if (!std::isfinite(value) || intensity == 1.f) continue;
    value *= 1.f + (intensity - 1.f) * weight;
    std::memcpy(bytes + offset, &value, sizeof(value));
  }
  for (unsigned offset : {0x270u, 0x280u, 0x290u, 0xbc0u, 0xbe0u}) {
    ScaleRGB(constants, offset, 1.f + (controls.fog - 1.f) * weight);
  }
  for (unsigned offset : {0x2d0u, 0x2e0u, 0x2f0u}) {
    ScaleRGB(constants, offset, 1.f + (controls.haze - 1.f) * weight);
  }
  // Native c194 is the sky's separate height/horizon haze color. Scale RGB
  // before native sky blending; alpha and the c202.z haze profile stay native.
  ScaleRGB(constants, 0xc20, 1.f + (controls.sky_haze - 1.f) * weight);
  const float water = 1.f + (controls.water - 1.f) * weight;
  if (water != 1.f) {
    // Native fog direction c38 uses xyz only. No dumped shader reads w;
    // keep this gain independent of sky haze, moon and cloud precision.
    const uint32_t tag = 0xd9000000u | uint32_t(std::lround(std::clamp(water, 0.f, 2.f) * 1048575.f));
    std::memcpy(bytes + 0x26c, &tag, sizeof(tag));
  }
  const float sky_haze = 1.f + (controls.sky_haze - 1.f) * weight;
  if (sky_haze != 1.f) {
    // Toussaint's sky adds a separate colour-group background glow after the
    // native height haze. Its shared colours also light clouds, so transport a
    // gain for the sky shader instead of changing those global colour groups.
    const uint32_t tag = 0xd8000000u | uint32_t(std::lround(std::clamp(sky_haze, 0.f, 8.f) * 1048575.f));
    std::memcpy(bytes + 0x258, &tag, sizeof(tag));
  }
  for (unsigned offset = 0xc30; offset <= 0xc90; offset += 16) {
    ScaleRGB(constants, offset, 1.f + (controls.sky - 1.f) * weight);
  }
  const float clouds = 1.f + (controls.clouds - 1.f) * weight;
  const float stars = 1.f + (controls.stars - 1.f) * weight;
  if (clouds != 1.f || stars != 1.f) {
    // Native c184.w is zero and unused by all 1240 dumped shaders. Two
    // independent 12-bit gains, decoded only by the cloud and sky replacements.
    // A separate tag extends only the normalized cloud range to 8x; the
    // original 0..2x encoding and star precision remain unchanged otherwise.
    const bool normalized = clouds > 2.f;
    const uint32_t tag = (normalized ? 0xd7000000u : 0xd6000000u)
        | (uint32_t(std::lround(clouds * (normalized ? 511.f : 2047.f))) << 12)
        | uint32_t(std::lround(stars * 2047.f));
    std::memcpy(bytes + 0xb8c, &tag, sizeof(tag));
  }
  const float brightness = 1.f + (controls.moon_brightness - 1.f) * weight;
  const float size = 1.f + (controls.moon_size - 1.f) * weight;
  if (brightness != 1.f || size != 1.f) {
    // Native c37.zw is cleared by the guarded builder. No dumped native
    // shader reads c37.w (1240-shader audit). Only paired moon shaders decode.
    const uint32_t tag = 0xd5000000u | (uint32_t(std::lround(brightness * 1023.f)) << 13)
        | uint32_t(std::lround(size * 1024.f));
    std::memcpy(bytes + 0x25c, &tag, sizeof(tag));
  }
}

struct CommonUpload {
  static inline thread_local CommonUpload* active = nullptr;
  CommonUpload* previous = active;
  Controls controls;
  float time;
  lighting::player_fill::Controls player_controls = lighting::player_fill::GetControls();
  void* mapped = nullptr;
  uint64_t resource = 0;
  const void* native_handle = nullptr;
  alignas(16) std::array<uint8_t, 4304> shadow{};
  CommonUpload(const Controls& controls, float time) : controls(controls), time(time) { active = this; }
  ~CommonUpload() { active = previous; }
  void* Redirect(void* target, uint64_t identity) {
    mapped = target;
    resource = identity;
    return shadow.data();
  }
  void Publish() {
    if (!mapped) return;
    ApplyCommon(shadow.data(), controls, time);
    lighting::player_fill::ApplyCommon(shadow.data(),player_controls);
    std::memcpy(mapped, shadow.data(), shadow.size());
    mapped = nullptr;
    resource = 0;
  }
};

inline void* MapBufferHook(const void* handle, uint32_t flags, uint32_t offset, uint32_t size) {
  void* target = map_buffer(handle, flags, offset, size);
  auto* upload = CommonUpload::active;
  if (!target || !upload || handle != upload->native_handle || flags != 4 || offset != 0 || size != 4304) return target;
  state->common_uploads.fetch_add(1, std::memory_order_relaxed);
  const auto& controls = upload->controls;
  if (!(upload->player_controls.enabled && upload->player_controls.unify)
      && (ClockMultiplier(upload->time, controls.schedule, 0.f) == 1.f
      || (controls.ambient_light == 1.f && controls.ambient_shadow == 1.f
          && controls.reflection_light == 1.f && controls.reflection_shadow == 1.f
          && controls.fog == 1.f && controls.haze == 1.f && controls.sky == 1.f && controls.sky_haze == 1.f
          && controls.moon_brightness == 1.f && controls.moon_size == 1.f
          && controls.clouds == 1.f && controls.stars == 1.f && controls.water == 1.f))) return target;
  // Capture the native helper's final pointer, after all API interception.
  // Publish to that exact destination before its native Unmap helper runs.
  return upload->Redirect(target, reinterpret_cast<uintptr_t>(handle));
}

inline void UnmapBufferHook(const void* handle) {
  auto* upload = CommonUpload::active;
  if (upload && upload->mapped && handle == upload->native_handle) upload->Publish();
  unmap_buffer(handle);
}

inline void CommonConstantsHook(void* renderer, const void* environment, uint64_t width, uint64_t height, int index, uint32_t flags) {
  Controls controls;
  {
    std::shared_lock lock(state->mutex);
    controls = state->controls;
  }
  const auto player_controls=lighting::player_fill::GetControls();
  if ((controls.schedule == 0 && !(player_controls.enabled && player_controls.unify)) || !environment) {
    build_common_constants(renderer, environment, width, height, index, flags);
    return;
  }
  float time;
  std::memcpy(&time, static_cast<const uint8_t*>(environment) + 0x1070, sizeof(time));
  night_weight.store(1.f - ClockMultiplier(time, controls.schedule, 0.f), std::memory_order_relaxed);
  CommonUpload upload(controls, time);
  upload.native_handle = static_cast<uint8_t*>(renderer) + 0x11c;
  build_common_constants(renderer, environment, width, height, index, flags);
}

inline void DirectConstantsHook(void* renderer, const void* environment) {
  build_direct_constants(renderer, environment);
  Controls controls;
  {
    std::shared_lock lock(state->mutex);
    controls = state->controls;
  }
  if (controls.schedule == 0 || !environment) return;
  float time;
  std::memcpy(&time, static_cast<const uint8_t*>(environment) + 0x1070, sizeof(time));
  state->hour.store(std::isfinite(time) && time >= 0.f && time <= 1.f ? time * 24.f : -1.f, std::memory_order_relaxed);
  void* constants = nullptr;
  std::memcpy(&constants, static_cast<uint8_t*>(renderer) + 0xf8, sizeof(constants));
  night_weight.store(1.f - ClockMultiplier(time, controls.schedule, 0.f), std::memory_order_relaxed);
  ApplyMoonlight(constants, ClockMultiplier(time, controls.schedule, controls.intensity, 8.f));
}

inline bool Install() {
  if (attempted) return installed;
  attempted = true;
  if (!Supported()) return false;
  HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  if (snapshot == INVALID_HANDLE_VALUE) return false;
  std::vector<HANDLE> threads;
  THREADENTRY32 entry{sizeof(entry)};
  bool valid = Thread32First(snapshot, &entry) != FALSE;
  if (valid) {
    do {
      if (entry.th32OwnerProcessID != GetCurrentProcessId() || entry.th32ThreadID == GetCurrentThreadId()) continue;
      HANDLE thread = OpenThread(THREAD_SUSPEND_RESUME | THREAD_GET_CONTEXT | THREAD_SET_CONTEXT | THREAD_QUERY_INFORMATION,
                                FALSE, entry.th32ThreadID);
      if (!thread) { valid = false; break; }
      threads.push_back(thread);
    } while (Thread32Next(snapshot, &entry));
  }
  CloseHandle(snapshot);
  HMODULE pinned = nullptr;
  valid = valid && GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN,
                                    reinterpret_cast<LPCWSTR>(&DirectConstantsHook), &pinned);
  if (valid && DetourTransactionBegin() == NO_ERROR) {
    valid = DetourUpdateThread(GetCurrentThread()) == NO_ERROR;
    for (HANDLE thread : threads) {
      if (valid) valid = DetourUpdateThread(thread) == NO_ERROR;
    }
    build_direct_constants = reinterpret_cast<BuildDirectConstants>(reinterpret_cast<uintptr_t>(GetModuleHandleW(nullptr)) + 0xc379a0);
    if (valid) valid = DetourAttach(reinterpret_cast<void**>(&build_direct_constants), reinterpret_cast<void*>(&DirectConstantsHook)) == NO_ERROR;
    if (valid && common_supported) {
      build_common_constants = reinterpret_cast<BuildCommonConstants>(reinterpret_cast<uintptr_t>(GetModuleHandleW(nullptr)) + 0xcda720);
      map_buffer = reinterpret_cast<MapBuffer>(reinterpret_cast<uintptr_t>(GetModuleHandleW(nullptr)) + 0xeb10);
      unmap_buffer = reinterpret_cast<UnmapBuffer>(reinterpret_cast<uintptr_t>(GetModuleHandleW(nullptr)) + 0xee40);
      valid = DetourAttach(reinterpret_cast<void**>(&build_common_constants), reinterpret_cast<void*>(&CommonConstantsHook)) == NO_ERROR
          && DetourAttach(reinterpret_cast<void**>(&map_buffer), reinterpret_cast<void*>(&MapBufferHook)) == NO_ERROR
          && DetourAttach(reinterpret_cast<void**>(&unmap_buffer), reinterpret_cast<void*>(&UnmapBufferHook)) == NO_ERROR;
    }
    if(valid && lighting::player_fill::supported) {
      lighting::player_fill::build_camera_light = reinterpret_cast<lighting::player_fill::BuildCameraLight>(
          reinterpret_cast<uintptr_t>(GetModuleHandleW(nullptr))+0xc3c510);
      valid=DetourAttach(reinterpret_cast<void**>(&lighting::player_fill::build_camera_light),
          reinterpret_cast<void*>(&lighting::player_fill::CameraLightHook))==NO_ERROR;
    }
    if (valid && exposure::supported) {
      constants_image_base = reinterpret_cast<uintptr_t>(GetModuleHandleW(nullptr));
      set_pixel_constants = reinterpret_cast<SetPixelConstants>(constants_image_base + 0x19f00);
      valid = DetourAttach(reinterpret_cast<void**>(&set_pixel_constants), reinterpret_cast<void*>(&ExposureConstantsHook)) == NO_ERROR;
    }
    if (valid) installed = DetourTransactionCommit() == NO_ERROR;
    else DetourTransactionAbort();
  }
  for (HANDLE thread : threads) CloseHandle(thread);
  return installed;
}

inline void Update(bool preset_enabled) {
  if(preset_enabled && lighting::player_control!=0.f && Supported())Install();
  lighting::player_fill::Update(preset_enabled && installed && lighting::player_fill::supported);
  Controls controls;
  const bool active = preset_enabled && enabled == 1.f && Supported();
  normalization::Update(active);
  if (active && std::isfinite(moonlight)) {
    controls.schedule = NightSchedule();
    controls.intensity = std::clamp(moonlight / 100.f, 0.f, 2.f);
    for (const auto& [value, target] : {
             std::pair{ambient_light, &controls.ambient_light}, std::pair{ambient_shadow, &controls.ambient_shadow},
             std::pair{reflection_light, &controls.reflection_light}, std::pair{reflection_shadow, &controls.reflection_shadow},
             std::pair{fog_brightness, &controls.fog}, std::pair{haze_brightness, &controls.haze},
             std::pair{sky_brightness, &controls.sky}, std::pair{sky_haze_brightness, &controls.sky_haze},
             std::pair{cloud_brightness, &controls.clouds}, std::pair{star_brightness, &controls.stars},
             std::pair{moon_brightness, &controls.moon_brightness}, std::pair{water_ambient, &controls.water}}) {
      *target = (std::isfinite(value) ? std::clamp(value / 100.f, 0.f, 2.f) : 1.f);
    }
    controls.moon_size = (std::isfinite(moon_size) ? std::clamp(moon_size / 100.f, .01f, 5.f) : 1.f);
    const auto calibration = normalization::GetCalibration();
    controls.intensity *= calibration.direct;
    controls.ambient_light *= calibration.ambient_light;
    controls.ambient_shadow *= calibration.ambient_shadow;
    controls.reflection_light *= calibration.reflection_light;
    controls.reflection_shadow *= calibration.reflection_shadow;
    controls.fog *= calibration.fog;
    controls.haze *= calibration.haze;
    controls.sky *= calibration.sky;
    controls.sky_haze *= calibration.sky;
    controls.clouds *= calibration.cloud;
    if ((controls.schedule != 0 || exposure::all_day == 1.f) && !Install()) controls.schedule = 0;
  }
  exposure::Update(active && installed && (controls.schedule != 0 || exposure::all_day == 1.f));
  if (!active || controls.schedule == 0) night_weight.store(0.f, std::memory_order_relaxed);
  std::unique_lock lock(state->mutex);
  state->controls = controls;
}

}  // namespace witcher3classic::night
