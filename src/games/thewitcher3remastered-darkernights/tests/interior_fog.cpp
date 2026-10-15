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
  std::array<unsigned char, 0x630> weather{};
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
  put(environment.data() + 0x92270, weather.data());
  put(alternate.data() + 0x92454, 1.f);
  fog::game_address = &game_pointer;
  fog::supported = true;
  constexpr char building[] = "environment\\definitions\\env_nomansland\\crossroads_inn\\env_nml_crossroads_inn_v2.env";
  constexpr char cave[] = "environment\\definitions\\env_novigrad\\env_novigrad_cave.env";
  // The captured exposed Kaer Trolde balcony uses global Skellige weather.
  // Keep that visibility-based fixture separate from the newly captured
  // Novigrad global-only room, whose native enclosure has a verified boundary.
  constexpr char generic[] = "environment\\definitions\\env_skellige\\env_skellige_brown.env";
  const auto profile = [&](unsigned index, const char* name, float weight) {
    put(records.data() + index * 0x15dd0 + 0x15da8, weight);
    put(records.data() + index * 0x15dd0 + 0x15dac, name);
    put(records.data() + index * 0x15dd0 + 0x15db4, uint32_t(std::strlen(name) + 1));
    for (unsigned i = 0; i < 8; ++i) {
      uint32_t mapped;
      std::memcpy(&mapped, environment.data() + 0x1d2dc + i * 24 + 20, sizeof(mapped));
      if (mapped == index) put(environment.data() + 0x2c040 + i * 0xe970, weight);
    }
  };
  const auto select = [&](std::initializer_list<unsigned> indices) {
    put(environment.data() + 0x1d39c, uint32_t(indices.size()));
    put(environment.data() + 0x92260, uint32_t(indices.size()));
    unsigned i = 0;
    for (unsigned index : indices) {
      put(environment.data() + 0x1d2dc + i * 24, int32_t(100 - i));
      put(environment.data() + 0x1d2dc + i * 24 + 20, uint32_t(index));
      float weight;
      std::memcpy(&weight, records.data() + index * 0x15dd0 + 0x15da8, sizeof(weight));
      put(environment.data() + 0x2c040 + i * 0xe970, weight);
      ++i;
    }
  };
  profile(0, building, 1.f);
  profile(1, generic, 1.f);
  select({0, 1});
  unsigned cases = 0;
  // Captured Kaer Trolde balcony: indoor blend is 1, but native weather
  // visibility is 1. The room suppresses weather even in the same storm.
  for (float visibility : {0.f, .25f, .5f, 1.f, -.16866850852966309f, -1.f, 2.f,
                           std::numeric_limits<float>::quiet_NaN(), std::numeric_limits<float>::infinity()}) {
    put(weather.data() + 0x5d0, visibility);
    assert(fog::BuildingWeight() == (std::isfinite(visibility) ? 1.f - std::clamp(visibility, 0.f, 1.f) : 0.f));
    ++cases;
  }
  put(weather.data() + 0x5d0, 0.f);
  for (float rain : {0.f, .5f, 1.f}) {
    put(weather.data() + 0x5e0, rain);
    assert(fog::BuildingWeight() == 1.f); // Actual weather intensity is not enclosure.
    ++cases;
  }
  put(environment.data() + 0x92270, static_cast<const unsigned char*>(nullptr));
  assert(fog::BuildingWeight() == 0.f);
  put(environment.data() + 0x92270, weather.data());
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
  select({3, 2, 1, 0});
  for (unsigned i : {1u, 2u}) put(records.data() + i * 0x15dd0 + 0x15d80, reinterpret_cast<const unsigned char*>(1));
  assert(fog::BuildingWeight() == 1.f);
  // Captured room regression: both Dandelion layers fully weighted at
  // priorities 301/300, city 200, global weather 0. Native curve undershoots.
  profile(3, "environment\\definitions\\env_novigrad\\interiors\\dandelion\\wip\\env_interior_1.env", 1.f);
  put(records.data() + 3 * 0x15dd0 + 0x15d80, reinterpret_cast<const unsigned char*>(1));
  select({3, 2, 1, 0});
  put(weather.data() + 0x5d0, -.16866850852966309f);
  assert(fog::BuildingWeight() == 1.f);
  ++cases;
  put(weather.data() + 0x5d0, 0.f);
  put(records.data() + 3 * 0x15dd0 + 0x15d80, static_cast<const unsigned char*>(nullptr));
  profile(3, cave, 0.f);
  // Other Novigrad buildings use the shared interior profile rather than
  // Dandelion's named profile. Keep the same city overlap and cave guards.
  profile(2, "environment\\definitions\\env_novigrad\\env_novigrad_int.env", 1.f);
  assert(fog::BuildingWeight() == 1.f);
  // Captured storm room: global dark clouds override the weather visibility
  // curve at priority 254, above the local interior at 210 and city at 200.
  // Explicit building contribution must survive that unrelated weather layer.
  profile(3, "environment\\definitions\\env_novigrad\\env_novigrad_dark_clouds.env", 1.f);
  select({3, 2, 1, 0});
  for (float visibility : {0.f, .5f, 1.f, 2.f}) {
    put(weather.data() + 0x5d0, visibility);
    assert(fog::BuildingWeight() == 1.f);
    ++cases;
  }
  profile(2, "environment\\definitions\\env_novigrad\\env_novigrad_int.env", .25f);
  put(weather.data() + 0x5d0, 1.f);
  assert(fog::BuildingWeight() == 1.f); // City fallback covers the ordinary residual room.
  put(records.data() + 0x15dd0 + 0x15d80, static_cast<const unsigned char*>(nullptr));
  assert(fog::BuildingWeight() == .25f); // Only the known building fraction overrides weather.
  put(weather.data() + 0x5d0, 0.f);
  assert(fog::BuildingWeight() == 1.f); // Sheltered residual remains covered.
  put(records.data() + 0x15dd0 + 0x15d80, reinterpret_cast<const unsigned char*>(1));
  profile(2, "environment\\definitions\\env_novigrad\\env_novigrad_int.env", 1.f);
  profile(3, cave, .25f);
  put(weather.data() + 0x5d0, 1.f);
  assert(fog::BuildingWeight() == .75f); // Higher-priority cave atmosphere still wins its fraction.
  profile(3, cave, 1.f);
  assert(fog::BuildingWeight() == 0.f);
  profile(3, cave, 0.f);
  put(weather.data() + 0x5d0, 0.f);
  cases += 5;
  put(environment.data() + 0x92454, .25f);
  assert(fog::BuildingWeight() == .75f);
  put(environment.data() + 0x92454, 1.f);
  assert(fog::BuildingWeight() == 0.f); // City classification never enables fog outdoors.
  put(environment.data() + 0x92454, 0.f);
  profile(3, cave, .01f);
  assert(std::abs(fog::BuildingWeight() - .99f) < 1e-6f); // Preserve the cave's effective blend fraction.
  profile(3, cave, 1.f);
  assert(fog::BuildingWeight() == 0.f);
  // Upstairs: fully weighted sewer at lower priority is overridden by the room.
  select({2, 1, 0, 3});
  assert(fog::BuildingWeight() == 1.f);
  select({3, 2, 1, 0});
  profile(3, cave, 0.f);
  profile(1, generic, 1.f);
  select({1, 2, 3, 0});
  assert(fog::BuildingWeight() == 0.f); // Unidentified local profiles remain protected.
  cases += 8;
  // Captured locked quest room: storm weight 1 above city lighting .43166414
  // and global sunset, without a dedicated interior profile. The city area's
  // lighting blend must not attenuate building coverage from the indoor state.
  profile(0, generic, 1.f);
  profile(1, city, .43166414f);
  profile(2, "environment\\definitions\\env_novigrad\\env_novigrad_dark_clouds.env", 1.f);
  profile(3, cave, 0.f);
  put(records.data() + 2 * 0x15dd0 + 0x15d80, static_cast<const unsigned char*>(nullptr));
  select({2, 1, 0, 3});
  put(weather.data() + 0x5d0, 1.f);
  for (float outside : {0.f, .25f, .5f, 1.f}) {
    put(environment.data() + 0x92454, outside);
    assert(fog::BuildingWeight() == 1.f - outside);
    ++cases;
  }
  put(environment.data() + 0x92454, 0.f);
  profile(3, cave, .25f);
  select({3, 2, 1, 0});
  assert(fog::BuildingWeight() == .75f);
  profile(3, cave, 1.f);
  assert(fog::BuildingWeight() == 0.f);
  profile(3, generic, .5f);
  put(records.data() + 3 * 0x15dd0 + 0x15d80, reinterpret_cast<const unsigned char*>(1));
  assert(fog::BuildingWeight() == .5f); // Unknown local atmosphere keeps its effective contribution.
  profile(3, cave, 0.f);
  put(records.data() + 3 * 0x15dd0 + 0x15d80, static_cast<const unsigned char*>(nullptr));
  profile(1, city, 0.f);
  assert(fog::BuildingWeight() == 0.f); // Inactive regional records cannot identify a room.
  profile(1, city, .43166414f);
  put(records.data() + 0x15dd0 + 0x15d80, static_cast<const unsigned char*>(nullptr));
  assert(fog::BuildingWeight() == 0.f); // Global city use alone keeps the weather fallback.
  put(weather.data() + 0x5d0, 0.f);
  cases += 5;
  for (unsigned i : {1u, 2u}) put(records.data() + i * 0x15dd0 + 0x15d80, static_cast<const unsigned char*>(nullptr));
  put(environment.data() + 0x1d2d8, uint32_t{2});
  profile(0, building, 1.f);
  profile(1, generic, 1.f);
  select({0, 1});
  // Second captured Novigrad room: only a local shared dark-sunset area over
  // global weather, visibility 1 both inside and outside. Native indoor blend
  // is 1 in the room and 0 on the street; the profile itself spans both.
  profile(0, "environment\\definitions\\env_nomansland\\env_nml_global_dark_sunset.env", 1.f);
  put(records.data() + 0x15d80, reinterpret_cast<const unsigned char*>(1));
  put(weather.data() + 0x5d0, 1.f);
  for (float outside : {0.f, .25f, .5f, 1.f}) {
    put(environment.data() + 0x92454, outside);
    assert(fog::BuildingWeight() == 1.f - outside);
    ++cases;
  }
  put(environment.data() + 0x92454, 0.f);
  profile(1, cave, 1.f);
  select({1, 0});
  assert(fog::BuildingWeight() == 0.f); // A shared lighting area cannot override a higher cave layer.
  ++cases;
  select({0, 1});
  profile(1, generic, 1.f);
  put(records.data() + 0x15d80, static_cast<const unsigned char*>(nullptr));
  assert(fog::BuildingWeight() == 0.f); // Global use alone does not prove a room.
  ++cases;
  profile(0, building, 1.f);
  put(weather.data() + 0x5d0, 0.f);
  for (std::string_view name : {cave, "environment\\definitions\\env_skellige\\interiors\\cave\\env_cave_fog_in_v1.env",
                               "environment\\definitions\\env_novigrad\\novigrad_sewers\\novigrad_sewers_03.env",
                               "dlc\\bob\\data\\environment\\definitions\\cave\\cave_catacombs.env",
                               "environment\\definitions\\env_skellige\\interiors\\kt_castle\\env_skellige_kt_castle_tunnel.env"}) {
    profile(1, name.data(), .01f);
    assert(std::abs(fog::BuildingWeight() - .99f) < 1e-6f); // Cave flag unset; preserve authored cave contribution.
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
  select({0});
  // Captured global-only Novigrad room: inactive cutscene layer, sunset
  // weather with no area handle, visibility 1 on both sides of the doorway.
  constexpr char global_room[] = "environment\\definitions\\env_novigrad\\env_novigrad_sunset.env";
  put(environment.data() + 0x1d2d8, uint32_t{2});
  profile(0, global_room, 1.f);
  profile(1, "environment\\definitions\\cutscenes_definition\\cutscen_definition_global.env", 0.f);
  select({1, 0});
  for (float visibility : {0.f, .5f, 1.f}) {
    put(weather.data() + 0x5d0, visibility);
    for (float outside : {0.f, .25f, .5f, 1.f}) {
      put(environment.data() + 0x92454, outside);
      assert(fog::BuildingWeight() == 1.f - outside);
      environment[0x92448] = 1;
      assert(fog::BuildingWeight() == 0.f);
      environment[0x92448] = 0;
      cases += 2;
    }
  }
  put(environment.data() + 0x92454, 0.f);
  put(weather.data() + 0x5d0, 1.f);
  for (const char* protected_profile : {cave, "quests\\special\\unknown_local_atmosphere.env"}) {
    profile(1, protected_profile, 1.f);
    put(records.data() + 0x15dd0 + 0x15d80, reinterpret_cast<const unsigned char*>(1));
    for (float amount : {0.f, .25f, .5f, 1.f}) {
      profile(1, protected_profile, amount);
      assert(fog::BuildingWeight() == 1.f - amount);
      ++cases;
    }
  }
  // A registered but inactive sunset profile cannot enable the fallback.
  put(records.data() + 0x15dd0 + 0x15d80, static_cast<const unsigned char*>(nullptr));
  profile(0, global_room, 0.f);
  profile(1, generic, 1.f);
  assert(fog::BuildingWeight() == 0.f);
  ++cases;
  // Restore the existing invalid-weight fixture.
  put(environment.data() + 0x1d2d8, uint32_t{1});
  select({0});
  for (float weight : {-1.f, std::numeric_limits<float>::quiet_NaN(), std::numeric_limits<float>::infinity()}) {
    profile(0, building, weight);
    assert(fog::BuildingWeight() == 0.f);
    ++cases;
  }
  profile(0, building, 1.f);
  // Regional swamp + dark-sunset room: the regional area must not veto
  // camera enclosure, and must still permit a higher-priority cave exclusion.
  constexpr char swamp[] = "environment\\definitions\\env_nomansland\\nml_global\\env_nml_swamps_v1_a_ps4_flat24.env";
  put(environment.data() + 0x1d2d8, uint32_t{3});
  profile(0, swamp, 1.f);
  profile(1, "environment\\definitions\\env_nomansland\\env_nml_global_dark_sunset.env", 1.f);
  profile(2, cave, 0.f);
  for (unsigned index : {0u, 1u}) put(records.data() + index * 0x15dd0 + 0x15d80, reinterpret_cast<const unsigned char*>(1));
  select({2, 0, 1});
  put(weather.data() + 0x5d0, 1.f);
  for (float outside : {0.f, .5f, 1.f}) {
    put(environment.data() + 0x92454, outside);
    assert(fog::BuildingWeight() == 1.f - outside);
    ++cases;
  }
  put(environment.data() + 0x92454, 0.f);
  profile(2, cave, 1.f);
  assert(fog::BuildingWeight() == 0.f);
  // Captured q106 tower: an explicit room at priority 1024 overrides island
  // mist at 999 and shared dark-sunset lighting at 100. The mist must remain
  // outdoor when the room layer is absent, even inside a broad indoor volume.
  constexpr char tower[] = "quests\\part_2\\quest_files\\q106_tower\\entities\\q106_temp_island_env_int.env";
  profile(0, tower, 1.f);
  profile(1, "quests\\part_2\\quest_files\\q106_tower\\entities\\env_mist_q106.env", 1.f);
  profile(2, "environment\\definitions\\env_nomansland\\env_nml_global_dark_sunset.env", 1.f);
  put(records.data() + 2 * 0x15dd0 + 0x15d80, reinterpret_cast<const unsigned char*>(1));
  select({0, 1, 2});
  for (float outside : {0.f, .5f, 1.f}) {
    put(environment.data() + 0x92454, outside);
    assert(fog::BuildingWeight() == 1.f - outside);
    ++cases;
  }
  put(environment.data() + 0x92454, 0.f);
  for (float weight : {0.f, .25f, .5f, 1.f}) {
    profile(0, tower, weight);
    assert(fog::BuildingWeight() == weight);
    ++cases;
  }
  environment[0x92448] = 1;
  assert(fog::BuildingWeight() == 0.f);
  environment[0x92448] = 0;
  profile(2, cave, 1.f);
  select({2, 0, 1});
  assert(fog::BuildingWeight() == 0.f);
  cases += 2;
  put(environment.data() + 0x1d2d8, uint32_t{1});
  put(records.data() + 0x15d80, static_cast<const unsigned char*>(nullptr));
  profile(0, building, 1.f);
  select({0});
  put(weather.data() + 0x5d0, 0.f);
  // Asset-audited room variants must work even when storm weather reports
  // full visibility. Native outdoor/cave states always retain outdoor distance.
  for (const char* name : {
           "environment\\definitions\\env_nomansland\\env_nml_global_dark_sunset_interior.env",
           "environment\\definitions\\env_novigrad\\env_interior.env",
           "environment\\definitions\\novigrad\\env_global_clear_interior.env",
           "environment\\definitions\\env_prologue\\env_prolog_colors_interior.env",
           "environment\\definitions\\env_prologue\\env_prolog_global\\env_prolog_global_raw_v1_a_interior.env",
           "environment\\definitions\\env_prologue\\env_prolog_global\\env_prolog_global_raw_v2_a_interior.env",
           "environment\\definitions\\kaer_morhen\\kaer_morhen_global\\env_kaer_morhen_v09_hdr_int.env",
           "environment\\definitions\\kaer_morhen\\kaer_morhen_global\\env_kaer_morhen_v09_int.env",
           "dlc\\ep1\\data\\environment\\definitions\\in_progress\\q604\\q604_blizzard_interior.env",
           "dlc\\ep1\\data\\environment\\definitions\\in_progress\\q604\\q604_blizzard_interior_cs.env",
           "dlc\\ep1\\data\\environment\\definitions\\in_progress\\q604\\q604_creepy_interior.env",
           "dlc\\ep1\\data\\environment\\definitions\\in_progress\\q604\\q604_painting_interior.env",
           "dlc\\ep1\\data\\environment\\definitions\\in_progress\\q604\\q604_painting_interior_cs.env",
           "environment\\definitions\\cutscenes_definition\\envs_for_cutscenes\\q106_temp_island_env_int_cs.env",
           tower,
       }) {
    profile(0, name, 1.f);
    put(records.data() + 0x15d80, reinterpret_cast<const unsigned char*>(1));
    for (float visibility : {0.f, .5f, 1.f}) {
      put(weather.data() + 0x5d0, visibility);
      for (float outside : {0.f, .25f, .5f, 1.f}) {
        put(environment.data() + 0x92454, outside);
        assert(fog::BuildingWeight() == 1.f - outside);
        environment[0x92448] = 1;
        assert(fog::BuildingWeight() == 0.f);
        environment[0x92448] = 0;
        cases += 2;
      }
    }
    put(environment.data() + 0x92454, 0.f);
    put(records.data() + 0x15d80, static_cast<const unsigned char*>(nullptr));
    assert(fog::BuildingWeight() == 0.f); // A global/cutscene profile alone is not a room volume.
    ++cases;
  }
  for (const char* name : {
           "environment\\definitions\\wyzima\\global\\wip\\env_outdoor_wyzima_01.env",
           "environment\\definitions\\wyzima\\global\\wip\\env_outdoor_wyzima_02.env",
           "dlc\\bob\\data\\environment\\definitions\\sunny\\dof_interior.env",
           "dlc\\bob\\data\\environment\\definitions\\quests\\q704\\temp\\q704_detlaff_arena_prod_room.env",
           "quests\\part_2\\quest_files\\q106_tower\\entities\\env_mist_q106.env",
           "quests\\part_2\\quest_files\\q106_tower\\entities\\q106_temp_island_env.env",
       }) {
    profile(0, name, 1.f);
    put(records.data() + 0x15d80, reinterpret_cast<const unsigned char*>(1));
    put(weather.data() + 0x5d0, 0.f);
    assert(fog::BuildingWeight() == 0.f); // Enclosure alone cannot reclassify a protected local atmosphere.
    ++cases;
  }
  for (const char* name : {
           "environment\\definitions\\env_nomansland\\salt_mines\\wip\\env_nml_salt_mines_main_chamber.env",
           "environment\\definitions\\camera_lights_set_up\\env_salt_mine.env",
           "environment\\definitions\\skellige\\env_abandoned_mine.env",
       }) {
    profile(0, name, 1.f);
    for (const unsigned char* area : {static_cast<const unsigned char*>(nullptr), reinterpret_cast<const unsigned char*>(1)}) {
      put(records.data() + 0x15d80, area);
      assert(fog::BuildingWeight() == 0.f); // Also preserve scripted/global mine atmosphere with no cave flag.
      ++cases;
    }
  }
  put(records.data() + 0x15d80, static_cast<const unsigned char*>(nullptr));
  profile(0, building, 1.f);
  put(weather.data() + 0x5d0, 0.f);
  // Timed fades use wall time, independent of presentation rate. Both
  // directions follow the same damped response across presentation rates.
  for (unsigned fps : {30u, 60u, 144u}) {
    fog::Update(false, 1000);
    put(environment.data() + 0x92454, 1.f);
    assert(fog::Update(true, 1000) == 0.f);
    put(environment.data() + 0x92454, 0.f);
    float previous = 0.f;
    for (unsigned frame = 1; frame <= fps * 8; ++frame) {
      const float value = fog::Update(true, 1000 + uint64_t(frame) * 1000 / fps);
      assert(value >= previous && value <= 1.f);
      const float seconds = float(uint64_t(frame) * 1000 / fps) / 1000.f;
      assert(std::abs(value - (1.f - (1.f + 3.2f * seconds) * std::exp(-3.2f * seconds))) < 1e-5f);
      if (frame == fps / 2) assert(value > .47f && value < .48f);
      if (frame == fps * 3 / 2) assert(value > .95f && value < .96f);
      previous = value;
    }
    assert(previous > .98f);
    fog::Update(false, 9000);
    assert(fog::Update(true, 9000) == 1.f);
    previous = 1.f;
    put(environment.data() + 0x92454, 1.f);
    for (unsigned frame = 1; frame <= fps * 8; ++frame) {
      const float value = fog::Update(true, 9000 + uint64_t(frame) * 1000 / fps);
      assert(value <= previous && value >= 0.f);
      const float seconds = float(uint64_t(frame) * 1000 / fps) / 1000.f;
      assert(std::abs(value - (1.f + 3.2f * seconds) * std::exp(-3.2f * seconds)) < 1e-5f);
      previous = value;
    }
    assert(previous < .02f);
  }
  put(environment.data() + 0x92454, 0.f);
  fog::Update(false, 1000);
  assert(fog::Update(true, 1000) == 1.f); // Startup uses the current scene.
  put(environment.data() + 0x92454, 1.f);
  assert(std::abs(fog::Update(true, 1125) - 1.4f * std::exp(-.4f)) < 1e-6f);
  assert(std::abs(fog::Update(true, 10000) - 2.2f * std::exp(-1.2f)) < 1e-6f); // Long pauses do not jump the fade.
  // Reversing at a doorway preserves position and velocity, then smoothly
  // turns around. No overshoot of the valid density interval is permitted.
  put(environment.data() + 0x92454, 0.f);
  const float reversing_weight = fog::fade_weight;
  const float reversing_velocity = fog::fade_velocity;
  assert(fog::Update(true, 10000) == reversing_weight);
  assert(fog::fade_velocity == reversing_velocity);
  assert(fog::Update(true, 10001) < reversing_weight);
  for (uint64_t milliseconds = 10002; milliseconds < 20000; milliseconds += 16) {
    assert(fog::Update(true, milliseconds) >= 0.f && fog::fade_weight <= 1.f);
  }
  assert(fog::fade_weight > .99f);
  // Boundary chatter must be absorbed rather than reproduced as flicker.
  // Alternate fully outside/inside every frame, starting from a mixed state.
  fog::Update(false, 20000);
  put(environment.data() + 0x92454, .5f);
  assert(fog::Update(true, 20000) == .5f);
  for (unsigned frame = 1; frame <= 180; ++frame) {
    put(environment.data() + 0x92454, frame % 2 ? 1.f : 0.f);
    const float previous = fog::fade_weight;
    const float value = fog::Update(true, 20000 + uint64_t(frame) * 1000 / 60);
    assert(std::abs(value - previous) < .001f);
    assert(value > .49f && value < .51f);
  }
  assert(fog::Update(false, 10001) == 0.f); // Off restores native immediately.
  assert(fog::fade_velocity == 0.f);
  put(environment.data() + 0x92454, 0.f);
  assert(fog::Update(true, 10002) == 1.f);
  put(selector.data() + 0x7c, uint32_t{1});
  assert(fog::Update(true, 10003) == 0.f); // World changes discard the previous room's fade.
  put(selector.data() + 0x7c, uint32_t{0});
  assert(fog::Update(true, 10004) == 1.f);
  fog::Update(false);
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
  std::printf("Building fog: %u profile/priority/underground/invalid-input cases plus timed fades at 30/60/144 FPS, world selection and teardown guards passed.\n", cases);
}
