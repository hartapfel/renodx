/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <windows.h>

#include <atomic>
#include <algorithm>
#include <bit>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <initializer_list>

namespace witcher::night::normalization {

inline float enabled = 1.f;
inline bool supported = false;
inline float weather_enabled = 1.f;
inline bool weather_supported = false;

struct Calibration {
  float direct = 1.f;
  float ambient_light = 1.f, ambient_shadow = 1.f;
  float reflection_light = 1.f, reflection_shadow = 1.f;
  float sky = 1.f, fog = 1.f, haze = 1.f, cloud = 1.f;
};
inline constexpr Calibration native;
// One lock-free publication contains region, both weather profiles and blend.
// Workers derive a local value from immutable tables; no mutable profile pointer
// or game heap object is shared with renderer threads.
inline std::atomic<uint64_t> current = 0;
static_assert(std::atomic<uint64_t>::is_always_lock_free);

// Clear-night baselines from the installed world .env assets, not from the
// currently blended weather. Reference = median of the five ordinary outdoor
// regions' 22:00-04:00 authored keys. RGB uses the native pow(rgb/255, 2.2)*W
// conversion. Gains are bounded to 1/4..4 to retain extreme authored scenes.
// Keep one gain throughout a region: rain/clear ratios and colour survive.
struct Region {
  uint32_t area_enum;
  Calibration lighting;
  uint32_t name = 0;
};
inline Region regions[] = {
    {1, {0.9358445f, 0.4073316f, 0.6464123f, 0.6651766f, 0.9648604f, 0.25f, 0.8022886f, 4.f, 0.8120155f}}, // Novigrad / Velen
    {2, {0.7220017f, 0.6248091f, 2.0722807f, 1.f, 0.9812378f, 1.f, 4.f, 0.25f, 0.4314402f}}, // Skellige
    {3, {3.1696537f, 1.0028292f, 0.8539378f, 1.1396453f, 1.f, 1.4454798f, 0.4289377f, 0.25f, 2.5423424f}}, // Kaer Morhen
    {4, {1.f, 2.8799830f, 1.f, 0.5569652f, 1.1881890f, 0.5379598f, 1.2221310f, 1.7938465f, 1.f}}, // White Orchard
    {8, {1.9064568f, 1.0910116f, 1.2882105f, 0.2827803f, 1.0172732f, 1.1028074f, 0.5185504f, 0.25f, 0.5985672f}}, // Winter White Orchard
    {11, {4.f, 1.f, 4.f, 1.0768531f, 3.7532525f, 1.0978556f, 1.f, 1.f, 1.6692019f}}, // Toussaint
};

#include "./night_weather_profiles.hpp"

using InternName = uint32_t (*)(void*, const char*);
inline InternName intern_name = nullptr;
inline void* const* name_manager = nullptr;
inline bool weather_names_initialized = false;

using AreaName = uint32_t* (*)(uint32_t*, uint32_t);
inline AreaName area_name = nullptr;
inline const unsigned char* const* game_address = nullptr;
inline bool names_initialized = false;

inline Calibration GetCalibration() {
  const uint64_t selection = current.load(std::memory_order_relaxed);
  const unsigned region = selection & 7u;
  if (region == 0 || region > std::size(regions)) return native;
  Calibration result = (selection & 8u) ? regions[region - 1].lighting : native;
  const unsigned from = (selection >> 4) & 63u, to = (selection >> 10) & 63u;
  if (from == 0 && to == 0) return result;
  if (from > std::size(weather_profiles) || to > std::size(weather_profiles)) return result;
  const float blend = std::bit_cast<float>(uint32_t(selection >> 16));
  const float from_amount = float((selection >> 48) & 255u) / 255.f;
  const float to_amount = float(selection >> 56) / 255.f;
  const Weather* a = from == 0 ? nullptr : &weather_profiles[from - 1];
  const Weather* b = to == 0 ? nullptr : &weather_profiles[to - 1];
  for (auto channel : {&Calibration::direct, &Calibration::ambient_light, &Calibration::ambient_shadow,
                       &Calibration::reflection_light, &Calibration::reflection_shadow, &Calibration::sky,
                       &Calibration::fog, &Calibration::haze, &Calibration::cloud}) {
    const float source = a ? 1.f + (a->ratio.*channel - 1.f) * from_amount : 1.f;
    const float target = b ? 1.f + (b->ratio.*channel - 1.f) * to_amount : 1.f;
    const float source_corrected = a ? 1.f + (a->target.*channel - 1.f) * from_amount : 1.f;
    const float target_corrected = b ? 1.f + (b->target.*channel - 1.f) * to_amount : 1.f;
    const float baseline = source + (target - source) * blend;
    // Normalize the blended baseline, not the blend of gains. This avoids
    // overshoot when native endpoint radiances differ substantially.
    if (baseline > 1e-8f) result.*channel *= (source_corrected + (target_corrected - source_corrected) * blend) / baseline;
    result.*channel = std::clamp(result.*channel, .25f, 4.f);
  }
  return result;
}

// Indices encode static data only; zero means an unknown/quest weather, whose
// native weather relationship is preserved. Called on the present thread.
inline unsigned FindWeather(uint32_t region, uint32_t name) {
  for (unsigned i = 0; i < std::size(weather_profiles); ++i) {
    const auto& profile = weather_profiles[i];
    if (profile.region == region && weather_names[profile.name].name == name && name != 0) return i + 1;
  }
  return 0;
}

// ReadProcessMemory also safely rejects objects released during a concurrent
// world teardown. Use this boundary instead of SEH around optimized C++ loads.
template <typename T>
inline bool Read(const void* address, T* value) {
  SIZE_T read = 0;
  return ReadProcessMemory(GetCurrentProcess(), address, value, sizeof(T), &read) && read == sizeof(T);
}

// Access only once per present, outside renderer workers. Six small reads;
// never retain heap objects across loading/world transitions. Publish only
// static profiles, without scanning resources or adding per-draw work.
inline uint32_t ReadArea() {
  const unsigned char* game = nullptr;
  struct SystemTable {
    const unsigned char* items = nullptr;
    uint32_t count = 0;
  } systems;
  const unsigned char* handle = nullptr;
  uint32_t area = 0;
  if (!Read(game_address, &game) || !game || !Read(game + 0xfdb8, &systems)
      || !systems.items || systems.count <= 23 || systems.count > 256
      || !Read(systems.items + 0xb8, &handle) || !handle
      || !Read(handle + 8, &handle) || !handle
      || !Read(handle + 8, &handle) || !handle
      || !Read(handle + 0x110, &area)) return 0;
  return area;
}

inline bool ReadEnvironment(const unsigned char* const* game_source, const unsigned char** result) {
  const unsigned char* game = nullptr;
  const unsigned char* handle = nullptr;
  const unsigned char* world = nullptr;
  const unsigned char* environment = nullptr;
  unsigned char started = 0;
  uint32_t active_world = 0;
  if (!Read(game_source, &game) || !game || !Read(game + 0xfd3a, &started)) return false;
  // Mirrors CR4Game's active-world selector. The second environment belongs
  // to a concurrently loading/alternate world; do not choose by non-nullness.
  if (started) {
    if (!Read(game + 0x16068, &handle) || !handle || !Read(handle + 8, &environment)
        || !environment || !Read(environment + 0x7c, &active_world)) return false;
  }
  if (!Read(game + 0xf0, &handle) || !handle || !Read(handle + 8, &world) || !world
      || !Read(world + (active_world ? 0x230 : 0x228), &environment) || !environment) return false;
  *result = environment;
  return true;
}

inline bool ReadWeather(uint32_t* from, uint32_t* to, float* blend, uint64_t* amounts) {
  const unsigned char* environment = nullptr;
  const unsigned char* weather = nullptr;
  if (!ReadEnvironment(game_address, &environment)
      || !Read(environment + 0x92270, &weather) || !weather) return false;
  // One bounded read for both weather records and the native remaining/duration
  // clock. Never retain its heap pointer across a world or weather transition.
  unsigned char state[0x350];
  if (!Read(weather, &state)) return false;
  float duration, remaining;
  std::memcpy(&duration, state + 0x348, 4);
  std::memcpy(&remaining, state + 0x34c, 4);
  if (!std::isfinite(duration) || !std::isfinite(remaining)) return false;
  if (remaining <= 0.f) {
    std::memcpy(from, state + 0x18, 4);
    *to = *from;
    *blend = 0.f;
  } else {
    if (duration <= 0.f) return false;
    std::memcpy(from, state + 0x128, 4);
    std::memcpy(to, state + 0x238, 4);
    *blend = std::clamp(1.f - remaining / duration, 0.f, 1.f);
  }
  float source_amount, target_amount;
  std::memcpy(&source_amount, state + (remaining <= 0.f ? 0x40 : 0x150), 4);
  std::memcpy(&target_amount, state + (remaining <= 0.f ? 0x40 : 0x260), 4);
  if (!std::isfinite(source_amount) || !std::isfinite(target_amount)) return false;
  // The authored envBlend controls how much of the separate .env is present.
  // Preserve fractional/zero overrides. Eight-bit weights keep zero/one exact
  // and the entire immutable-table selection in one lock-free atomic.
  *amounts = (uint64_t(std::round(std::clamp(source_amount, 0.f, 1.f) * 255.f)) << 48)
      | (uint64_t(std::round(std::clamp(target_amount, 0.f, 1.f) * 255.f)) << 56);
  return true;
}

inline void Update(bool active) {
  uint64_t selection = 0;
  if (active && (enabled == 1.f || (weather_enabled == 1.f && weather_supported)) && supported) {
    const uint32_t area = ReadArea();
    if (area != 0) {
      // Resolve CName IDs only after the engine and map manager exist.
      // The native enum/name converter interns six names once, not per frame.
      if (!names_initialized) {
        for (auto& region : regions) area_name(&region.name, region.area_enum);
        names_initialized = true;
      }
      for (unsigned i = 0; i < std::size(regions); ++i) {
        if (regions[i].name == area) { selection = i + 1; break; }
      }
      // AN_Velen is an alias for the Novigrad world; its usual ID is the
      // combined AN_NMLandNovigrad, but resolve the explicit alias as well.
      static uint32_t velen = 0;
      if (velen == 0) area_name(&velen, 9);
      if (area == velen) selection = 1;
      if (selection != 0) {
        if (enabled == 1.f) selection |= 8u;
        if (weather_enabled == 1.f && weather_supported) {
          if (!weather_names_initialized) {
            void* manager = nullptr;
            if (Read(name_manager, &manager) && manager) {
              for (auto& name : weather_names) name.name = intern_name(manager, name.text);
              weather_names_initialized = true;
            }
          }
          uint32_t from = 0, to = 0;
          float blend = 0.f;
          uint64_t amounts = 0;
          if (weather_names_initialized && ReadWeather(&from, &to, &blend, &amounts)) {
            const uint32_t region = regions[(selection & 7u) - 1].area_enum;
            selection |= uint64_t(FindWeather(region, from)) << 4;
            selection |= uint64_t(FindWeather(region, to)) << 10;
            selection |= uint64_t(std::bit_cast<uint32_t>(blend)) << 16;
            selection |= amounts;
          }
        }
        // With both toggles off keep the exact native path/tag precision.
        if (enabled != 1.f && (selection & 0xfff0u) == 0) selection = 0;
      }
    }
  }
  // Vizima, Isle of Mists, spiral/quest worlds and unknown modded worlds keep
  // their intentional baselines. They still obey the user's night sliders.
  current.store(selection, std::memory_order_relaxed);
}


inline bool ValidateWeather(const unsigned char* image) {
  // Current-world selection, source/target names, remaining/duration and native
  // name interning are independent optional guards. Unknown layouts retain
  // regional normalization and all other lighting controls.
  constexpr unsigned char selector[] = {0x33,0xc0,0x38,0x81,0x3a,0xfd,0x00,0x00,0x74,0x27,0x48,0x8b,0x89,0x68,0x60,0x01,0x00,0x48,0x85,0xc9,0x74,0x06,0x4c,0x8b,0x41,0x08,0xeb,0x03,0x4c,0x8b,0xc0,0x41,0x39,0x40,0x7c,0x74,0x0c,0x48,0x85,0xc9,0x74,0x04,0x48,0x8b,0x41,0x08,0x8b,0x40,0x7c,0x89,0x02,0x48,0x8b,0xc2,0xc3};
  constexpr unsigned char world_selector[] = {0x80,0xb9,0x3a,0xfd,0x00,0x00,0x00,0x74,0x20,0x48,0x8b,0x01,0x48,0x8d,0x54,0x24,0x38,0xff,0x90,0x58,0x01,0x00,0x00,0x83,0x38,0x00,0x74,0x0d,0x48,0x8b,0x83,0x30,0x02,0x00,0x00,0x48,0x83,0xc4,0x20,0x5b,0xc3,0x48,0x8b,0x83,0x28,0x02,0x00,0x00,0x48,0x83,0xc4,0x20,0x5b};
  constexpr unsigned char weather_pointer[] = {0x48,0x8b,0x80,0x70,0x22,0x09,0x00,0x48,0x85,0xc0,0x74,0x06,0x48,0x83,0xc0,0x18,0xeb,0x07};
  constexpr unsigned char weather_start[] = {0x48,0x8d,0x8f,0x38,0x02,0x00,0x00,0x48,0x8b,0xd6,0x44,0x89,0xa7,0x18,0x06,0x00,0x00,0xc5,0xfa,0x11,0x9f,0x10,0x06,0x00,0x00,0xe8,0x7a,0x26,0x5b,0xfe,0x48,0x8d,0x8f,0x28,0x01,0x00,0x00,0x48,0x8d,0x57,0x18};
  constexpr unsigned char weather_clock[] = {0xc5,0xfa,0x11,0xb7,0x4c,0x03,0x00,0x00,0xc5,0xfa,0x11,0xb7,0x48,0x03,0x00,0x00};
  constexpr unsigned char weather_finish[] = {0x48,0x8d,0x8f,0x28,0x01,0x00,0x00,0xff,0xc8,0x48,0x8d,0x57,0x18,0x83,0xe0,0x01,0x89,0x87,0x78,0x03,0x00,0x00,0xe8,0x91,0x38,0x5b,0xfe,0x48,0x8d,0x97,0x38,0x02,0x00,0x00,0x48,0x8d,0x4f,0x18,0xe8,0x81,0x38,0x5b,0xfe,0x80,0xbf,0x40,0x01,0x00};
  constexpr unsigned char weather_progress[] = {0xc5,0xfa,0x10,0x87,0x4c,0x03,0x00,0x00,0xc4,0xc1,0x78,0x2f,0xc3,0x0f,0x86,0x12,0x03,0x00,0x00,0xc4,0xc1,0x7a,0x5c,0xc6,0xc4,0xc1,0x78,0x2f,0xc3,0xc5,0xfa,0x11,0x87,0x4c,0x03,0x00,0x00,0x77};
  constexpr unsigned char weather_ratio[] = {0xc5,0xfa,0x5e,0x87,0x48,0x03,0x00,0x00,0xc5,0xfa,0x10,0x1d,0xa4,0x6e,0x71,0x01,0x8b,0x8f,0x64,0x03,0x00,0x00,0xc5,0xc2,0x5c,0xc8,0xc4,0xc1,0x72,0x5f,0xc3,0xc5,0xfa,0x5d,0xef};
  constexpr unsigned char intern[] = {0x48,0x89,0x5c,0x24,0x20,0x55,0x41,0x56,0x41,0x57,0x48,0x83,0xec,0x20,0x4c,0x8b,0xf2,0x48,0x8b,0xe9};
  constexpr unsigned char name_global[] = {0x48,0x8b,0x05,0x8d,0xb9,0x53,0x05};
  if (std::memcmp(image + 0x1d76120, selector, sizeof(selector))
      || std::memcmp(image + 0x22b02e5, world_selector, sizeof(world_selector))
      || std::memcmp(image + 0x239bd64, weather_pointer, sizeof(weather_pointer))
      || std::memcmp(image + 0x239d4e8, weather_start, sizeof(weather_start))
      || std::memcmp(image + 0x239d57f, weather_clock, sizeof(weather_clock))
      || std::memcmp(image + 0x239c2d4, weather_finish, sizeof(weather_finish))
      || std::memcmp(image + 0x23a0b0f, weather_progress, sizeof(weather_progress))
      || std::memcmp(image + 0x23a0b78, weather_ratio, sizeof(weather_ratio))
      || std::memcmp(image + 0x26b90a0, intern, sizeof(intern))
      || std::memcmp(image + 0x31c444, name_global, sizeof(name_global))) return false;
  name_manager = reinterpret_cast<void* const*>(const_cast<unsigned char*>(image) + 0x5857dd8);
  intern_name = reinterpret_cast<InternName>(const_cast<unsigned char*>(image) + 0x26b90a0);
  return true;
}

inline bool Validate(const unsigned char* image, uint32_t size) {
  supported = false;
  weather_supported = false;
  current.store(0, std::memory_order_relaxed);
  names_initialized = false;
  weather_names_initialized = false;
  name_manager = nullptr;
  intern_name = nullptr;
  game_address = nullptr;
  area_name = nullptr;
  // October renderer: GetCommonMapManager, GetCurrentArea, enum->CName and
  // GetWeatherConditionName's shared GGame load. Optional, independent of
  // the existing lighting layout; an unknown build leaves normalization off.
  constexpr unsigned char manager[] = {
      0x83,0xb9,0xc0,0xfd,0,0,0x17,0x7e,0x28,0x48,0x8b,0x81,0xb8,0xfd,0,0,
      0x48,0x8b,0x88,0xb8,0,0,0,0x33,0xc0,0x8b,0xd8,0x48,0x85,0xc9,0x74,0x15,
      0x48,0x8b,0x49,0x08,0x48,0x85,0xc9,0x74,0x0c};
  constexpr unsigned char area[] = {0x48,0xff,0x42,0x30,0x4d,0x85,0xc0,0x74,0x09,
                                  0x8b,0x81,0x10,0x01,0,0,0x41,0x89,0,0xc3};
  constexpr unsigned char converter[] = {0x40,0x53,0x48,0x83,0xec,0x20,0x48,0x8b,0xd9,
                                       0x83,0xfa,0x0b,0x0f,0x87,0x8a,0x01,0,0};
  constexpr unsigned char global[] = {0x48,0x8b,0x05};
  if (size < 0x5a5b930 || std::memcmp(image + 0x1d6f74e, manager, sizeof(manager))
      || std::memcmp(image + 0x1dd3250, area, sizeof(area))
      || std::memcmp(image + 0x1dec500, converter, sizeof(converter))
      || std::memcmp(image + 0x239bd1d, global, sizeof(global))) return false;
  int32_t displacement;
  std::memcpy(&displacement, image + 0x239bd20, sizeof(displacement));
  if (int64_t(0x239bd24) + displacement != 0x5a5b928) return false;
  // Check every calibrated enum's case, string and common intern target.
  for (uint32_t area_enum : {1u, 2u, 3u, 4u, 8u, 11u, 9u}) {
    uint32_t address;
    std::memcpy(&address, image + 0x1dec6b0 + area_enum * 4, sizeof(address));
    if (address < 0x1dec528 || address > 0x1dec67d || image[address] != 0xe8
        || std::memcmp(image + address + 5, "\x48\x8d\x15", 3)) return false;
    std::memcpy(&displacement, image + address + 1, sizeof(displacement));
    if (int64_t(address) + 5 + displacement != 0x31c440) return false;
    std::memcpy(&displacement, image + address + 8, sizeof(displacement));
    const int64_t string = int64_t(address) + 12 + displacement;
    const char* expected = area_enum == 1 ? "AN_NMLandNovigrad"
        : area_enum == 2 ? "AN_Skellige_ArdSkellig"
        : area_enum == 3 ? "AN_Kaer_Morhen"
        : area_enum == 4 ? "AN_Prologue_Village"
        : area_enum == 8 ? "AN_Prologue_Village_Winter"
        : area_enum == 9 ? "AN_Velen" : "AN_Bob";
    if (string < 0 || uint64_t(string) + std::strlen(expected) + 1 > size
        || std::memcmp(image + string, expected, std::strlen(expected) + 1)) return false;
  }
  game_address = reinterpret_cast<const unsigned char* const*>(image + 0x5a5b928);
  area_name = reinterpret_cast<AreaName>(const_cast<unsigned char*>(image) + 0x1dec500);
  supported = true;
  weather_supported = ValidateWeather(image);
  return true;
}
}  // namespace witcher::night::normalization
