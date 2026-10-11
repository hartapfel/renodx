/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <array>
#include <string_view>

#include "./night_normalization.hpp"

namespace witcher::night::interior_fog {

inline float amount = 100.f;
inline bool supported = false;
inline const unsigned char* const* game_address = nullptr;

// Names of authored environment profiles, not object names or lighting colours.
// The indoor blend includes caves. Ordinary buildings can retain only global
// weather profiles; caves instead commonly add authored underground profiles.
// Any underground profile vetoes the override, even during a transition.
// Unidentified local environment areas also keep their atmosphere. Audited
// regional outdoor layers may have an area handle while overlapping a building.
inline int Classify(std::string_view path) {
  for (std::string_view name : {"cave", "sewer", "crypt", "catacomb", "grotto", "dungeon", "underground", "tunnel", "ruin"}) {
    if (path.find(name) != std::string_view::npos) return -1;
  }
  for (std::string_view name : {"\\crossroads_inn\\", "\\barons_lair\\", "\\interiors\\dandelion\\",
                               "\\tavern\\", "\\interiors\\kt_castle\\", "\\kaer_trolde_inn\\",
                               "\\kaer_morhen\\interior\\", "\\wyzima\\global\\"}) {
    if (path.find(name) != std::string_view::npos) return 1;
  }
  // Individually authored building profiles outside those directory groups.
  for (std::string_view name : {"\\env_castle_interiors.env", "\\env_bathouse_v01.env",
                               "\\env_winter_epilog_white_grass_hendriks_house.env"}) {
    if (path.ends_with(name)) return 1;
  }
  // Captured over the Dandelion interior: an ordinary city-wide environment,
  // not a separate interior atmosphere. The indoor blend still gates the fog.
  if (path == "environment\\definitions\\env_novigrad\\env_novigrad_global\\env_novigrad_city.env") return 1;
  return 0;
}

// Present-thread reads only. Renderer workers consume the combined atomic fog
// multiplier and never dereference world, profile or string heap pointers.
inline float BuildingWeight() {
  const unsigned char* environment = nullptr;
  if (!supported || !normalization::ReadEnvironment(game_address, &environment)) return 0.f;
  std::array<unsigned char, 0x58> state;
  if (!normalization::Read(environment + 0x92400, &state) || state[0x48] != 0) return 0.f;
  float outside;
  std::memcpy(&outside, state.data() + 0x54, sizeof(outside));
  if (!std::isfinite(outside) || outside < 0.f || outside >= 1.f) return 0.f;
  struct Records {
    const unsigned char* items;
    uint32_t count;
  } records;
  if (!normalization::Read(environment + 0x1d2d0, &records)
      || !records.items || records.count == 0 || records.count > 8) return 0.f;
  bool active = false;
  for (unsigned i = 0; i < records.count; ++i) {
    std::array<unsigned char, 0x50> record;
    if (!normalization::Read(records.items + i * 0x15dd0 + 0x15d80, &record)) return 0.f;
    float weight;
    std::memcpy(&weight, record.data() + 0x28, sizeof(weight));
    if (!std::isfinite(weight) || weight < 0.f) return 0.f;
    if (weight == 0.f) continue;
    const char* name = nullptr;
    uint32_t length;
    std::memcpy(&name, record.data() + 0x2c, sizeof(name));
    std::memcpy(&length, record.data() + 0x34, sizeof(length));
    std::array<char, 512> path;
    SIZE_T read = 0;
    if (!name || length == 0 || length > path.size()
        || !ReadProcessMemory(GetCurrentProcess(), name, path.data(), length, &read) || read != length) return 0.f;
    const int type = Classify(std::string_view(path.data(), path[length - 1] == '\0' ? length - 1 : length));
    if (type < 0) return 0.f;
    const unsigned char* area = nullptr;
    std::memcpy(&area, record.data(), sizeof(area));
    if (area && type == 0) return 0.f;
    active = true;
  }
  return active ? 1.f - outside : 0.f;
}

inline bool Validate(const unsigned char* image, uint32_t size) {
  supported = false;
  game_address = nullptr;
  // The same active-world selection used by the engine and weather reader.
  constexpr unsigned char world_selector[] = {0x80,0xb9,0x3a,0xfd,0,0,0,0x74};
  constexpr unsigned char state_store[] = {0x88,0x88,0x48,0x24,0x09,0,0x88,0x90,0x49,0x24,0x09,0};
  constexpr unsigned char blend_store[] = {0xc5,0xfa,0x11,0x89,0x54,0x24,0x09,0};
  constexpr unsigned char profile_limit[] = {0x41,0x83,0xfb,0x08};
  constexpr unsigned char profile_stride[] = {0x48,0x69,0xf8,0xd0,0x5d,0x01,0};
  constexpr unsigned char profile_path[] = {0x48,0x8b,0x8f,0xac,0x5d,0x01,0};
  constexpr unsigned char profile_weight[] = {0x89,0x87,0xa8,0x5d,0x01,0};
  constexpr unsigned char profile_area[] = {0x48,0x8b,0x8f,0x80,0x5d,0x01,0};
  if (!image || size < 0x5a5b930
      || std::memcmp(image + 0x22b02e5, world_selector, sizeof(world_selector))
      || std::memcmp(image + 0x22b1fce, state_store, sizeof(state_store))
      || std::memcmp(image + 0x22b4adc, blend_store, sizeof(blend_store))
      || std::memcmp(image + 0x22b9582, profile_limit, sizeof(profile_limit))
      || std::memcmp(image + 0x22b959c, profile_stride, sizeof(profile_stride))
      || std::memcmp(image + 0x22b95c6, profile_path, sizeof(profile_path))
      || std::memcmp(image + 0x22b9631, profile_area, sizeof(profile_area))
      || std::memcmp(image + 0x22b5701, profile_weight, sizeof(profile_weight))) return false;
  constexpr unsigned char global[] = {0x48,0x8b,0x05};
  int32_t displacement;
  std::memcpy(&displacement, image + 0x22b1f80, sizeof(displacement));
  if (std::memcmp(image + 0x22b1f7d, global, sizeof(global))
      || int64_t(0x22b1f84) + displacement != 0x5a5b928) return false;
  game_address = reinterpret_cast<const unsigned char* const*>(image + 0x5a5b928);
  return supported = true;
}
}  // namespace witcher::night::interior_fog
