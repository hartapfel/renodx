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
inline const unsigned char* fade_environment = nullptr;
inline uint64_t fade_time = 0;
inline float fade_weight = 0.f;
inline float fade_velocity = 0.f;

// Names of authored environment profiles, not object names or lighting colours.
// The indoor blend includes caves. Ordinary buildings can retain only global
// weather profiles; caves instead commonly add authored underground profiles.
// Underground and unknown local profiles exclude their effective contribution.
// Follow native priority/blending: an overridden layer must not veto a room.
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
  for (std::string_view name : {"\\env_castle_interiors.env", "\\env_bathouse_v01.env", "\\env_novigrad_int.env",
                               "\\env_winter_epilog_white_grass_hendriks_house.env"}) {
    if (path.ends_with(name)) return 1;
  }
  // Captured over an enclosed Novigrad room and the street outside it. This
  // shared lighting area is not an underground atmosphere; allow the building
  // override only through the native indoor blend, never from this name alone.
  if (path == "environment\\definitions\\env_nomansland\\env_nml_global_dark_sunset.env") return 1;
  // Captured over Dandelion and a quest room with no dedicated interior layer.
  // This city-wide lighting area does not identify a separate atmosphere;
  // allow native indoor detection rather than its storm-overridden rain curve.
  if (path == "environment\\definitions\\env_novigrad\\env_novigrad_global\\env_novigrad_city.env") return 2;
  return 0;
}

// Present-thread reads only. Renderer workers consume the combined atomic fog
// multiplier and never dereference world, profile or string heap pointers.
inline float BuildingWeight(const unsigned char** active_environment = nullptr) {
  const unsigned char* environment = nullptr;
  if (!supported || !normalization::ReadEnvironment(game_address, &environment)) return 0.f;
  if (active_environment) *active_environment = environment;
  std::array<unsigned char, 0x58> state;
  if (!normalization::Read(environment + 0x92400, &state) || state[0x48] != 0) return 0.f;
  float outside;
  std::memcpy(&outside, state.data() + 0x54, sizeof(outside));
  if (!std::isfinite(outside) || outside < 0.f || outside >= 1.f) return 0.f;
  // The broad indoor volume can include exposed balconies. Use native weather
  // suppression for unclassified interiors only: higher-priority storm layers
  // can override this signal even when a known building profile is active.
  const unsigned char* weather = nullptr;
  float weather_visibility;
  if (!normalization::Read(environment + 0x92270, &weather) || !weather
      || !normalization::Read(weather + 0x5d0, &weather_visibility)
      || !std::isfinite(weather_visibility)) return 0.f;
  // Authored curves can overshoot (Dandelion room: -0.169). Saturate the
  // classification weight rather than rejecting a valid building state.
  weather_visibility = std::clamp(weather_visibility, 0.f, 1.f);
  struct Records {
    const unsigned char* items;
    uint32_t count;
  } records;
  if (!normalization::Read(environment + 0x1d2d0, &records)
      || !records.items || records.count == 0 || records.count > 8) return 0.f;
  std::array<unsigned char, 8 * 24> order;
  uint32_t count, layers;
  if (!normalization::Read(environment + 0x1d39c, &count) || count == 0 || count > records.count
      || !normalization::Read(environment + 0x92260, &layers) || layers != count
      || !normalization::Read(environment + 0x1d2dc, &order)) return 0.f;
  float remaining = 1.f, building = 0.f;
  bool active = false, city_area = false;
  int32_t previous_priority = INT32_MAX;
  for (unsigned i = 0; i < count && remaining > 0.f; ++i) {
    int32_t priority;
    uint32_t index;
    std::memcpy(&priority, order.data() + i * 24, sizeof(priority));
    std::memcpy(&index, order.data() + i * 24 + 20, sizeof(index));
    if (priority > previous_priority || index >= records.count) return 0.f;
    previous_priority = priority;
    float weight;
    if (!normalization::Read(environment + 0x2c040 + i * 0xe970, &weight)
        || !std::isfinite(weight) || weight < 0.f || weight > 1.f) return 0.f;
    if (weight == 0.f) continue;
    std::array<unsigned char, 0x50> record;
    if (!normalization::Read(records.items + index * 0x15dd0 + 0x15d80, &record)) return 0.f;
    const char* name = nullptr;
    uint32_t length;
    std::memcpy(&name, record.data() + 0x2c, sizeof(name));
    std::memcpy(&length, record.data() + 0x34, sizeof(length));
    std::array<char, 512> path;
    SIZE_T read = 0;
    if (!name || length == 0 || length > path.size()
        || !ReadProcessMemory(GetCurrentProcess(), name, path.data(), length, &read) || read != length) return 0.f;
    const int type = Classify(std::string_view(path.data(), path[length - 1] == '\0' ? length - 1 : length));
    const unsigned char* area = nullptr;
    std::memcpy(&area, record.data(), sizeof(area));
    active = true;
    // The audited city area can cover ordinary rooms without a dedicated
    // interior profile. Its lighting blend is not a building coverage weight.
    if (type == 2) {
      city_area |= area != nullptr;
      continue;
    }
    // Ordinary global weather layers do not identify the kind of interior.
    if (!area && type >= 0) continue;
    if (type == 1) building += remaining * weight;
    remaining *= 1.f - weight;
  }
  return active ? (building + remaining * (city_area ? 1.f : 1.f - weather_visibility)) * (1.f - outside) : 0.f;
}

// Critically damp both directions: about 1.5 seconds to complete 95% of an
// abrupt change, with continuous velocity when crossing back through a door.
// Reset immediately for Off, invalid worlds and world transitions.
// Environment addresses are compared only, never dereferenced across frames.
inline float Update(bool active, uint64_t milliseconds = GetTickCount64()) {
  const unsigned char* environment = nullptr;
  const float target = active ? BuildingWeight(&environment) : 0.f;
  if (!active || !environment) {
    fade_environment = nullptr;
    fade_time = 0;
    fade_velocity = 0.f;
    return fade_weight = 0.f;
  }
  if (environment != fade_environment || milliseconds < fade_time) {
    fade_weight = target;
    fade_velocity = 0.f;
  } else {
    // Exact constant-target solution, independent of presentation rate.
    // Cap elapsed time after stalls so resuming does not jump the fog amount.
    constexpr float response = 3.2f;
    const float seconds = float(std::min<uint64_t>(milliseconds - fade_time, 250)) / 1000.f;
    const float decay = std::exp(-response * seconds);
    const float displacement = fade_weight - target;
    const float change = fade_velocity + response * displacement;
    fade_weight = target + (displacement + change * seconds) * decay;
    fade_velocity = (fade_velocity - response * change * seconds) * decay;
    if (fade_weight < 0.f || fade_weight > 1.f) {
      fade_weight = std::clamp(fade_weight, 0.f, 1.f);
      fade_velocity = 0.f;
    }
  }
  fade_environment = environment;
  fade_time = milliseconds;
  return fade_weight;
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
  constexpr unsigned char order_count[] = {0x44,0x8b,0x93,0x9c,0xd3,0x01,0};
  constexpr unsigned char order_priority[] = {0x39,0x84,0xcb,0xdc,0xd2,0x01,0};
  constexpr unsigned char order_index[] = {0x48,0x63,0x84,0xcb,0xf0,0xd2,0x01,0};
  constexpr unsigned char layer_count[] = {0x4c,0x8d,0xb1,0x60,0x22,0x09,0};
  constexpr unsigned char layer_stride[] = {0x48,0x69,0xf0,0x70,0xe9,0,0};
  constexpr unsigned char layer_weight[] = {0x48,0x81,0xc6,0x40,0xc0,0x02,0};
  constexpr unsigned char weather_source[] = {0x48,0x8b,0x87,0x70,0x22,0x09,0};
  constexpr unsigned char weather_store[] = {0xc5,0xfa,0x11,0x80,0xd0,0x05,0,0};
  constexpr unsigned char weather_default[] = {0xc7,0x80,0xd0,0x05,0,0,0,0,0x80,0x3f};
  if (!image || size < 0x5a5b930
      || std::memcmp(image + 0x22b02e5, world_selector, sizeof(world_selector))
      || std::memcmp(image + 0x22b1fce, state_store, sizeof(state_store))
      || std::memcmp(image + 0x22b4adc, blend_store, sizeof(blend_store))
      || std::memcmp(image + 0x22b9582, profile_limit, sizeof(profile_limit))
      || std::memcmp(image + 0x22b959c, profile_stride, sizeof(profile_stride))
      || std::memcmp(image + 0x22b95c6, profile_path, sizeof(profile_path))
      || std::memcmp(image + 0x22b9631, profile_area, sizeof(profile_area))
      || std::memcmp(image + 0x22b546f, order_count, sizeof(order_count))
      || std::memcmp(image + 0x22b545a, order_priority, sizeof(order_priority))
      || std::memcmp(image + 0x22b5518, order_index, sizeof(order_index))
      || std::memcmp(image + 0x22b53e8, layer_count, sizeof(layer_count))
      || std::memcmp(image + 0x22b58d4, layer_stride, sizeof(layer_stride))
      || std::memcmp(image + 0x22b58de, layer_weight, sizeof(layer_weight))
      || std::memcmp(image + 0x22b4f87, weather_source, sizeof(weather_source))
      || std::memcmp(image + 0x22b4f93, weather_store, sizeof(weather_store))
      || std::memcmp(image + 0x22b4fab, weather_default, sizeof(weather_default))
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
