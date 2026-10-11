/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#include <array>
#include <cassert>
#include <cstdio>
#include <limits>
#include <vector>
#include "../night_normalization.hpp"

int main() {
  namespace norm = witcher::night::normalization;
  std::vector<unsigned char> game(0x16070), environment(0x92278), alternate(0x92278);
  std::array<unsigned char, 0xc0> systems{};
  std::array<unsigned char, 0x114> manager{};
  std::array<unsigned char, 16> handle{}, holder{}, world_handle{}, selector_handle{};
  std::array<unsigned char, 0x238> world{};
  std::array<unsigned char, 0x80> selector{};
  std::array<unsigned char, 0x350> weather{}, other_weather{};
  auto pointer = [](unsigned char* address, const unsigned char* value) { std::memcpy(address, &value, 8); };
  auto integer = [](unsigned char* address, uint32_t value) { std::memcpy(address, &value, 4); };
  auto scalar = [](unsigned char* address, float value) { std::memcpy(address, &value, 4); };
  const unsigned char* game_pointer = game.data();
  norm::game_address = &game_pointer;
  pointer(game.data() + 0xfdb8, systems.data());
  integer(game.data() + 0xfdc0, 27);
  pointer(systems.data() + 0xb8, handle.data());
  pointer(handle.data() + 8, holder.data());
  pointer(holder.data() + 8, manager.data());
  pointer(game.data() + 0xf0, world_handle.data());
  pointer(world_handle.data() + 8, world.data());
  pointer(game.data() + 0x16068, selector_handle.data());
  pointer(selector_handle.data() + 8, selector.data());
  pointer(world.data() + 0x228, environment.data());
  pointer(world.data() + 0x230, alternate.data());
  pointer(environment.data() + 0x92270, weather.data());
  pointer(alternate.data() + 0x92270, other_weather.data());
  game[0xfd3a] = 1;
  norm::supported = norm::weather_supported = true;
  norm::names_initialized = norm::weather_names_initialized = false;
  norm::area_name = [](uint32_t* out, uint32_t index) -> uint32_t* { *out = 100 + index; return out; };
  void* name_manager = reinterpret_cast<void*>(1234);
  norm::name_manager = &name_manager;
  norm::intern_name = [](void* manager, const char* name) -> uint32_t {
    assert(manager == reinterpret_cast<void*>(1234));
    for (unsigned i = 0; i < std::size(norm::weather_names); ++i)
      if (!std::strcmp(name, norm::weather_names[i].text)) return 200 + i;
    assert(false); return 0;
  };
  unsigned cases = 0;
  for (const auto& state : norm::weather_profiles) {
    const uint32_t name = 200 + state.name;
    integer(manager.data() + 0x110, 100 + state.region);
    integer(weather.data() + 0x128, 201); // WT_Clear: native base.
    integer(weather.data() + 0x238, name);
    integer(weather.data() + 0x18, name);
    for (float amount : {0.f, .5f, 1.f}) for (float blend : {0.f, .25f, .5f, .75f, 1.f}) {
      scalar(weather.data() + 0x348, 120.f);
      scalar(weather.data() + 0x34c, 120.f * (1.f - blend));
      for (unsigned offset : {0x40u, 0x150u, 0x260u}) scalar(weather.data() + offset, amount);
      for (float regional : {0.f, 1.f}) {
        norm::enabled = regional;
        norm::weather_enabled = 1.f;
        norm::Update(true);
        const auto actual = norm::GetCalibration();
        const auto& region = *std::find_if(std::begin(norm::regions), std::end(norm::regions),
                                         [&](const auto& r) { return r.area_enum == state.region; });
        const float quantized = std::round(amount * 255.f) / 255.f;
        for (auto channel : {&norm::Calibration::direct, &norm::Calibration::ambient_light, &norm::Calibration::ambient_shadow,
                            &norm::Calibration::reflection_light, &norm::Calibration::reflection_shadow, &norm::Calibration::sky,
                            &norm::Calibration::fog, &norm::Calibration::haze, &norm::Calibration::cloud}) {
          const float original = 1.f + (state.ratio.*channel - 1.f) * quantized * blend;
          const float corrected = 1.f + (state.target.*channel - 1.f) * quantized * blend;
          assert(std::abs(actual.*channel - std::clamp((regional ? region.lighting.*channel : 1.f)
              * (original > 1e-8f ? corrected / original : 1.f), .25f, 4.f)) < 2e-5f);
        }
        norm::weather_enabled = 0.f;
        norm::Update(true);
        const auto region_only = norm::GetCalibration();
        const auto expected = regional ? region.lighting : norm::native;
        assert(!std::memcmp(&region_only, &expected, sizeof(expected)));
        norm::Update(false);
        assert(norm::current.load() == 0);
        ++cases;
      }
    }
  }
  // Active-world selector follows the engine, not whichever pointer is non-null.
  uint32_t from = 0, to = 0; float blend = 0; uint64_t amounts = 0;
  integer(selector.data() + 0x7c, 1);
  assert(norm::ReadWeather(&from, &to, &blend, &amounts) && from == 0 && to == 0);
  scalar(other_weather.data() + 0x348, std::numeric_limits<float>::quiet_NaN());
  assert(!norm::ReadWeather(&from, &to, &blend, &amounts));
  pointer(alternate.data() + 0x92270, reinterpret_cast<const unsigned char*>(1));
  assert(!norm::ReadWeather(&from, &to, &blend, &amounts));
  norm::enabled = norm::weather_enabled = 1.f;
  norm::Update(true);
  assert((norm::current.load() & 0xfff0u) == 0); // Reader failure keeps region only.
  integer(selector.data() + 0x7c, 0);
  integer(weather.data() + 0x18, 9999);
  scalar(weather.data() + 0x34c, -1.f);
  norm::Update(true);
  assert((norm::current.load() & 0xfff0u) == 0); // Unknown/quest state is transparent.
  game_pointer = reinterpret_cast<const unsigned char*>(1);
  norm::Update(true);
  assert(norm::current.load() == 0);
  std::printf("PASS: %u weather/region toggle, partial environment, blend endpoint and master cases; alternate-world, unknown-state and teardown guards.\n", cases);
}
