/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#include <cassert>
#include <cstdio>
#include <limits>
#include <vector>
#include "../interior_fog.hpp"

int main() {
  namespace fog = witcher::night::interior_fog;
  std::vector<unsigned char> game(0x16100), world(0x240), environment(0x92460), alternate(0x92460);
  std::vector<unsigned char> records(8 * 0x15dd0), selector(0x80);
  std::array<unsigned char, 16> world_handle{}, selector_handle{};
  const auto put = [](unsigned char* output, const auto& value) { std::memcpy(output, &value, sizeof(value)); };
  const unsigned char* game_pointer = game.data();
  put(game.data() + 0xf0, world_handle.data());
  put(world_handle.data() + 8, world.data());
  put(world.data() + 0x228, environment.data());
  put(world.data() + 0x230, alternate.data());
  put(game.data() + 0x16068, selector_handle.data());
  put(selector_handle.data() + 8, selector.data());
  put(environment.data() + 0x1d2d0, records.data());
  put(environment.data() + 0x1d2d8, uint32_t{2});
  put(environment.data() + 0x92454, 0.f);
  put(alternate.data() + 0x92454, 1.f);
  fog::game_address = &game_pointer;
  fog::supported = true;
  constexpr char building[] = "environment\\definitions\\env_nomansland\\crossroads_inn\\env_nml_crossroads_inn_v2.env";
  constexpr char cave[] = "environment\\definitions\\env_novigrad\\env_novigrad_cave.env";
  constexpr char generic[] = "environment\\definitions\\env_novigrad\\env_novigrad_sunset.env";
  const auto profile = [&](unsigned index, const char* name, float weight) {
    put(records.data() + index * 0x15dd0 + 0x15da8, weight);
    put(records.data() + index * 0x15dd0 + 0x15dac, name);
    put(records.data() + index * 0x15dd0 + 0x15db4, uint32_t(std::strlen(name) + 1));
  };
  profile(0, building, 1.f);
  profile(1, generic, 1.f);
  unsigned cases = 0;
  for (float outside : {0.f, .1f, .5f, 1.f, -1.f, 2.f, std::numeric_limits<float>::quiet_NaN()}) {
    put(environment.data() + 0x92454, outside);
    assert(fog::BuildingWeight() == (std::isfinite(outside) && outside >= 0.f && outside < 1.f ? 1.f - outside : 0.f));
    ++cases;
  }
  put(environment.data() + 0x92454, 0.f);
  // Live Novigrad building: global weather, city area and Dandelion interior
  // all overlap. The city's area handle must not veto the recognized interior.
  constexpr char city[] = "environment\\definitions\\env_novigrad\\env_novigrad_global\\env_novigrad_city.env";
  constexpr char dandelion[] = "environment\\definitions\\env_novigrad\\interiors\\dandelion\\env_dandelion.env";
  put(environment.data() + 0x1d2d8, uint32_t{4});
  profile(0, generic, 1.f);
  profile(1, city, .715f);
  profile(2, dandelion, 1.f);
  profile(3, cave, 0.f);
  for (unsigned i : {1u, 2u}) put(records.data() + i * 0x15dd0 + 0x15d80, reinterpret_cast<const unsigned char*>(1));
  assert(fog::BuildingWeight() == 1.f);
  put(environment.data() + 0x92454, .25f);
  assert(fog::BuildingWeight() == .75f);
  put(environment.data() + 0x92454, 1.f);
  assert(fog::BuildingWeight() == 0.f); // City classification never enables fog outdoors.
  put(environment.data() + 0x92454, 0.f);
  profile(3, cave, .01f);
  assert(fog::BuildingWeight() == 0.f); // Underground still vetoes city + building.
  profile(3, cave, 0.f);
  profile(1, generic, .715f);
  assert(fog::BuildingWeight() == 0.f); // Unidentified local profiles remain protected.
  cases += 5;
  for (unsigned i : {1u, 2u}) put(records.data() + i * 0x15dd0 + 0x15d80, static_cast<const unsigned char*>(nullptr));
  put(environment.data() + 0x1d2d8, uint32_t{2});
  profile(0, building, 1.f);
  profile(1, generic, 1.f);
  for (std::string_view name : {cave, "environment\\definitions\\env_skellige\\interiors\\cave\\env_cave_fog_in_v1.env",
                               "environment\\definitions\\env_novigrad\\novigrad_sewers\\novigrad_sewers_03.env",
                               "dlc\\bob\\data\\environment\\definitions\\cave\\cave_catacombs.env",
                               "environment\\definitions\\env_skellige\\interiors\\kt_castle\\env_skellige_kt_castle_tunnel.env"}) {
    profile(1, name.data(), .01f);
    assert(fog::BuildingWeight() == 0.f); // Cave flag unset; authored underground layer still vetoes a building.
    profile(1, name.data(), 0.f);
    assert(fog::BuildingWeight() == 1.f); // Registered but inactive caves do not suppress a building.
    ++cases;
  }
  profile(0, generic, 1.f);
  assert(fog::BuildingWeight() == 1.f); // Ordinary huts/inns can retain global weather only.
  put(records.data() + 0x15d80, reinterpret_cast<const unsigned char*>(1));
  assert(fog::BuildingWeight() == 0.f); // Unknown local atmospheres are preserved, without dereferencing the area.
  profile(0, building, 1.f);
  assert(fog::BuildingWeight() == 1.f); // A recognized building may have its own area.
  put(records.data() + 0x15d80, static_cast<const unsigned char*>(nullptr));
  profile(0, cave, 1.f);
  assert(fog::BuildingWeight() == 0.f); // Underground exclusion also covers non-area/scripted profiles.
  profile(0, building, 1.f);
  environment[0x92448] = 1;
  assert(fog::BuildingWeight() == 0.f);
  environment[0x92448] = 0;
  game[0xfd3a] = 1;
  put(selector.data() + 0x7c, uint32_t{1});
  assert(fog::BuildingWeight() == 0.f); // Alternate/loading world selection.
  put(selector.data() + 0x7c, uint32_t{0});
  assert(fog::BuildingWeight() == 1.f);
  for (uint32_t count : {0u, 9u, 0xffffffffu}) {
    put(environment.data() + 0x1d2d8, count);
    assert(fog::BuildingWeight() == 0.f);
    ++cases;
  }
  put(environment.data() + 0x1d2d8, uint32_t{1});
  for (float weight : {-1.f, std::numeric_limits<float>::quiet_NaN(), std::numeric_limits<float>::infinity()}) {
    profile(0, building, weight);
    assert(fog::BuildingWeight() == 0.f);
    ++cases;
  }
  profile(0, building, 1.f);
  put(records.data() + 0x15db4, uint32_t{513});
  assert(fog::BuildingWeight() == 0.f);
  profile(0, building, 1.f);
  put(records.data() + 0x15dac, reinterpret_cast<const char*>(1));
  assert(fog::BuildingWeight() == 0.f);
  game_pointer = nullptr;
  assert(fog::BuildingWeight() == 0.f);
  game_pointer = reinterpret_cast<const unsigned char*>(1);
  assert(fog::BuildingWeight() == 0.f); // Concurrent teardown/freed objects.
  game_pointer = game.data();
  fog::supported = false;
  assert(fog::BuildingWeight() == 0.f);
  std::printf("Building fog: %u fade/profile/underground/invalid-input cases plus world selection and teardown guards passed.\n", cases);
}
