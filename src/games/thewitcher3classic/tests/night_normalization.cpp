/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <array>
#include <cassert>
#include <cmath>
#include <cstdio>
#include <vector>
#include "../night_normalization.hpp"

int main() {
  namespace norm = witcher3classic::night::normalization;
  std::vector<unsigned char> game(0xba68);
  std::array<unsigned char, 0xc0> systems{};
  std::array<unsigned char, 0x114> manager{};
  auto pointer = [](unsigned char* address, const void* value) { std::memcpy(address, &value, 8); };
  auto integer = [](unsigned char* address, uint32_t value) { std::memcpy(address, &value, 4); };
  const unsigned char* game_pointer = game.data();
  norm::game_address = &game_pointer;
  norm::supported = true;
  pointer(game.data() + 0xba58, systems.data());
  integer(game.data() + 0xba60, 26);
  pointer(systems.data() + 0xb0, manager.data());
  pointer(manager.data(), reinterpret_cast<const unsigned char*>(GetModuleHandleW(nullptr)) + 0x22edec8);
  unsigned cases = 0;
  for (const auto& region : norm::regions) {
    integer(manager.data() + 0x110, region.area_enum);
    norm::Update(true);
    const auto result = norm::GetCalibration();
    assert(!std::memcmp(&result, &region.lighting, sizeof(result)));
    // Normalize the region, preserving arbitrary authored weather/HDR ratios.
    for (auto channel : {&norm::Calibration::direct, &norm::Calibration::ambient_light,
         &norm::Calibration::ambient_shadow, &norm::Calibration::reflection_light,
         &norm::Calibration::reflection_shadow, &norm::Calibration::fog,
         &norm::Calibration::haze, &norm::Calibration::sky, &norm::Calibration::cloud}) {
      assert(std::isfinite(result.*channel) && result.*channel >= .25f && result.*channel <= 4.f);
      for (float clear : {.01f, 1.f, 1024.f}) for (float ratio : {0.f, .125f, .8f, 2.f, 16.f}) {
        const float normalized_clear = clear * result.*channel;
        const float normalized_weather = clear * ratio * result.*channel;
        assert(std::abs(normalized_weather / normalized_clear - ratio) < 2.e-6f);
        ++cases;
      }
    }
    norm::Update(false);
    assert(norm::current == 0);
    norm::enabled = 0.f;
    norm::Update(true);
    assert(norm::current == 0);
    norm::enabled = 1.f;
  }
  integer(manager.data() + 0x110, 9);
  norm::Update(true); assert(norm::current == 1); // Velen alias
  for (uint32_t area : {0u, 5u, 6u, 7u, 10u, 12u, 0xffffffffu}) {
    integer(manager.data() + 0x110, area);
    norm::Update(true); assert(norm::current == 0);
  }
  integer(manager.data() + 0x110, 2);
  for (uint32_t count : {0u, 22u, 257u, 0xffffffffu}) {
    integer(game.data() + 0xba60, count);
    norm::Update(true); assert(norm::current == 0);
  }
  integer(game.data() + 0xba60, 26);
  pointer(manager.data(), nullptr);
  norm::Update(true); assert(norm::current == 0); // unexpected system type
  game_pointer = reinterpret_cast<const unsigned char*>(1);
  norm::Update(true); assert(norm::current == 0); // torn-down world
  std::printf("PASS %u regional/weather ratio cases, native special worlds, aliases, disabled and invalid objects\n", cases);
}
