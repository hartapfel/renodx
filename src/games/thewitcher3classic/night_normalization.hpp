/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <windows.h>

#include <atomic>
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <initializer_list>
#include "presets.hpp"

namespace witcher3classic::night::normalization {

inline float enabled = presets::Default(presets::night, "NightRegionalNormalization");
inline bool supported = false;
struct Calibration {
  float direct = 1.f;
  float ambient_light = 1.f, ambient_shadow = 1.f;
  float reflection_light = 1.f, reflection_shadow = 1.f;
  float sky = 1.f, fog = 1.f, haze = 1.f, cloud = 1.f;
};
inline constexpr Calibration native;
// Published once per present. Render uploads consume only immutable calibration
// values; no game pointers or asset scans are shared with renderer workers.
inline std::atomic<unsigned> current = 0;

// Clear-night baselines from the installed world .env assets, not from the
// currently blended weather. Reference = median of the five ordinary outdoor
// regions' 22:00-04:00 authored keys. RGB uses the native pow(rgb/255, 2.2)*W
// conversion. Gains are bounded to 1/4..4 to retain extreme authored scenes.
// Keep one gain throughout a region: rain/clear ratios and colour survive.
struct Region {
  uint32_t area_enum;
  Calibration lighting;
};
inline constexpr Region regions[] = {
    {1, {0.93584451f, 0.40733162f, 0.64641232f, 0.66517656f, 0.96486043f, 0.25000000f, 0.80228860f, 4.00000000f, 0.61463528f}}, // Novigrad / Velen
    {2, {0.72200174f, 0.62480907f, 2.07228070f, 1.00000000f, 0.98123777f, 1.00000000f, 4.00000000f, 0.25000000f, 0.43144020f}}, // Skellige
    {3, {3.16965370f, 1.00282920f, 0.85393782f, 1.13964534f, 1.00000000f, 1.44547984f, 0.42893766f, 0.25000000f, 2.54234241f}}, // Kaer Morhen
    {4, {1.00000000f, 2.87998301f, 1.00000000f, 0.55696522f, 1.18818903f, 0.53795982f, 1.22213103f, 1.79384650f, 1.00000000f}}, // White Orchard
    {8, {1.90645683f, 1.09101156f, 1.28821047f, 0.28278032f, 1.01727316f, 1.10280744f, 0.51855036f, 0.25000000f, 0.59856720f}}, // Winter White Orchard
    {11, {4.00000000f, 1.00000000f, 4.00000000f, 1.07685314f, 3.75325245f, 1.09785560f, 1.00000000f, 1.00000000f, 1.66920189f}}, // Toussaint
};

inline const unsigned char* const* game_address = nullptr;

inline Calibration GetCalibration() {
  const unsigned region = current.load(std::memory_order_relaxed);
  return region != 0 && region <= std::size(regions) ? regions[region - 1].lighting : native;
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
  const unsigned char* items = nullptr;
  const unsigned char* manager = nullptr;
  uint32_t count = 0, area = 0;
  uintptr_t vtable = 0;
  if (!Read(game_address, &game) || !game || !Read(game + 0xba58, &items) || !items
      || !Read(game + 0xba60, &count) || count <= 22 || count > 256
      || !Read(items + 0xb0, &manager) || !manager || !Read(manager, &vtable)
      || vtable != reinterpret_cast<uintptr_t>(GetModuleHandleW(nullptr)) + 0x22edec8
      || !Read(manager + 0x110, &area)) return 0;
  return area == 9 ? 1 : area;
}

inline void Update(bool active) {
  unsigned selection = 0;
  if (active && enabled == 1.f && supported) {
    const uint32_t area = ReadArea();
    for (unsigned i = 0; i < std::size(regions); ++i) {
      if (regions[i].area_enum == area) { selection = i + 1; break; }
    }
  }
  // One constant regional gain preserves every weather/local-volume ratio,
  // including custom weather. Unknown and special worlds stay native.
  current.store(selection, std::memory_order_relaxed);
}

inline bool Validate(const unsigned char* image, uint32_t size) {
  supported = false;
  current.store(0, std::memory_order_relaxed);
  if (size < 0x2bc7ad8) return false;
  // Guard the native world chain, map-area producer and enum lookup independently
  // from the existing renderer. Classic stores the area enum, not a CName.
  constexpr unsigned char game[] = {0x48,0x8b,0x0d,0xc5,0x72,0x5d,0x02};
  constexpr unsigned char world[] = {0x48,0x8b,0x42,0x10,0x48,0x8b,0x80,0x20,0x02,0,0};
  constexpr unsigned char area[] = {0x89,0x81,0x10,0x01,0,0};
  constexpr unsigned char table[] = {0x48,0x8b,0x80,0x80,0x01,0,0};
  if (std::memcmp(image + 0x5f0804, game, sizeof(game))
      || std::memcmp(image + 0x5f0847, world, sizeof(world))
      || std::memcmp(image + 0xd727e2, area, sizeof(area))
      || std::memcmp(image + 0xd72846, table, sizeof(table))) return false;
  game_address = reinterpret_cast<const unsigned char* const*>(image + 0x2bc7ad0);
  supported = true;
  return true;
}
}  // namespace witcher3classic::night::normalization
