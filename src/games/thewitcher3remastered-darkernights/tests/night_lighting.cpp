/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#include <array>
#include <cassert>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <limits>

#include "../night_lighting.hpp"

namespace {
void VerifyPackedFactors(const unsigned char* constants, float sky, float cloud) {
  uint32_t packed;
  std::memcpy(&packed, constants + 0xb9c, sizeof(packed));
  if (sky == 1.f && cloud == 1.f) {
    assert(packed == 0);
    return;
  }
  assert((packed & 0xf0000000u) == 0xd0000000u);
  const float decoded_sky = float((packed >> 14) & 0x3fffu) / 8191.f;
  const float decoded_cloud = float(packed & 0x3fffu) / 8191.f;
  assert(std::abs(decoded_sky - sky) <= 0.5f / 8191.f + 1e-6f);
  assert(std::abs(decoded_cloud - cloud) <= 0.5f / 8191.f + 1e-6f);
  if (sky == 0.f || sky == 1.f || sky == 2.f) assert(decoded_sky == sky);
  if (cloud == 0.f || cloud == 1.f || cloud == 2.f) assert(decoded_cloud == cloud);
}

float day;
std::array<unsigned char, 0xf700> environment;
std::array<unsigned char, 0x590> output;
std::array<unsigned char, 0x18> input;
std::array<unsigned char, 0x1550> common_output;
float sun_exponent = 1024.f;
std::array<unsigned char, 0x430> direct_output;
std::array<unsigned char, 0x6a0> renderer;
std::array<unsigned char, 0x10> common_context;
std::array<unsigned char, 0x100> global_output;
bool camera_built = true;
std::array<unsigned char, 0xa0> camera_output;

bool NativeCameraBuilder(void* result, const void*, const void*, const void*, const void* override_color,
                         float blend, void* colors) {
  assert(override_color == input.data() && blend == 0.25f);
  (void)colors;
  std::memset(result, 0x5a, camera_output.size());
  // Original 35CE42/48/4E stores; +3C is a light bitfield, not alpha.
  const std::array<float, 3> rgb{2.f, 4.f, 8.f};
  std::memcpy(static_cast<unsigned char*>(result) + 0x30, rgb.data(), sizeof(rgb));
  return camera_built;
}

// Audited per-view directional colors; all other native fields are sentinels.
void NativeBuilder(void* result, const void*) {
  std::memset(result, 0x5a, output.size());
  std::memcpy(static_cast<unsigned char*>(result) + 0x3b4, &day, sizeof(day));
  for (unsigned i = 0; i < 3; ++i) {
    std::memcpy(static_cast<unsigned char*>(result) + 0x280 + i * 16,
                environment.data() + 0xefe0 + i * 16, 16);
  }
}

void NativeDirectBuilder(void*, const void*) {
  direct_output.fill(0x5a);
  // Independent reference: audited native stores at RVA 0x1c68ac5.
  std::memcpy(direct_output.data() + 0x10, environment.data() + 0xefe0, 16);
  std::memcpy(direct_output.data() + 0x3d0, environment.data() + 0xeff0, 16);
  std::memcpy(direct_output.data() + 0x3e0, environment.data() + 0xf000, 16);
}

void NativeCommonBuilder(const void*, void*) {
  // Captured directional fog colors; other native fields are sentinels to
  // detect any edits to density, projection matrices, alpha or other effects.
  common_output.fill(0x5a);
  std::memcpy(common_output.data() + 0xcc0, &sun_exponent, sizeof(sun_exponent));
  std::memset(common_output.data() + 0xce8, 0, sizeof(uint64_t)); // Native c206.zw clear.
  // Native zeroed c37.w padding; moon transport must preserve every other byte.
  std::memset(common_output.data() + 0x25c, 0, sizeof(uint32_t));
  // Audited native stores at 1BE00AE/1BE00CA/1BE0162/1BE017F.
  // Distinct enable/distance sentinels expose accidental full-vector edits.
  const float probes[8] = {1.3f, 0.7f, 1.f, 0.f, 0.9f, 0.4f, 2.5f, 0.f};
  std::memcpy(common_output.data() + 0xb80, probes, sizeof(probes));
  const float colors[][4] = {{0.0439758f, 0.3125f, 0.434326f, 1.f},
                            {0.0285645f, 0.248657f, 0.351807f, 1.f},
                            {0.0190582f, 0.192261f, 0.273438f, 1.f}};
  std::memcpy(common_output.data() + 0x270, colors, sizeof(colors));
  // Captured storm custom-fog color, supplied separately from front/back fog.
  const float custom_fog[4] = {0.0000445843f, 0.0508423f, 0.0681152f, 2.f};
  std::memcpy(common_output.data() + 0xbd0, custom_fog, sizeof(custom_fog));
  std::memcpy(common_output.data() + 0xbf0, custom_fog, sizeof(custom_fog));
  // Audited native common layout: atmosphere and material color groups.
  for (unsigned offset : {0x2d0u, 0x2e0u, 0x2f0u, 0xc20u, 0xc30u, 0xc40u,
                          0xc50u, 0xc60u, 0xc70u, 0xc80u, 0xc90u, 0xca0u,
                          0xf40u, 0xf50u, 0xf60u, 0xf70u, 0xf80u, 0xf90u, 0x1150u, 0x1160u}) {
    const float color[4] = {0.1f, 0.3f, 1.4f, 0.7f};
    std::memcpy(common_output.data() + offset, color, sizeof(color));
  }
}

void NativeGlobalBuilder(const void*, void* result) {
  std::memset(result, 0x5a, global_output.size());
  // Audited native stores at 1C75EA3..1C75F00. The live harbor capture
  // has RGB 0/.0745098/.1176471, ambient .316403, diffuse .74181.
  std::memcpy(static_cast<unsigned char*>(result) + 0xb0, environment.data() + 0xd70, 0x20);
  // Updated builder 1C7D430/43E: independent distance-blended sky fill.
  std::memcpy(static_cast<unsigned char*>(result) + 0xe0, environment.data() + 0xda4, sizeof(float));
  std::memset(static_cast<unsigned char*>(result) + 0xe8, 0, 8);
}

void* NativeSkyBuilder(void* result, const void* source) {
  std::memset(result, 0x5a, 0xe0);
  // Independently audited native stores: evaluated environment F1E4/F1DC
  // become sky water impact +40 and sky reflection intensity +54.
  std::memcpy(static_cast<unsigned char*>(result) + 0x40, static_cast<const unsigned char*>(source) + 0xf1e4, sizeof(float));
  std::memcpy(static_cast<unsigned char*>(result) + 0x54, static_cast<const unsigned char*>(source) + 0xf1dc, sizeof(float));
  return result;
}
}  // namespace

int main() {
  witcher::night::build_environment = NativeBuilder;
  const auto* pointer = environment.data();
  std::memcpy(input.data() + 0x10, &pointer, sizeof(pointer));
  witcher::night::build_direct_constants = NativeDirectBuilder;
  witcher::night::build_common_constants = NativeCommonBuilder;
  witcher::night::build_global_constants = NativeGlobalBuilder;
  const float water[] = {0.f, 0.074509807f, 0.117647067f, 0.6f,
                         0.111908004f, 0.583404005f, 0.316403002f, 0.741810024f};
  std::memcpy(environment.data() + 0xd70, water, sizeof(water));
  const float water_sky = 2.5f;
  std::memcpy(environment.data() + 0xda4, &water_sky, sizeof(water_sky));
  auto* direct_pointer = direct_output.data();
  std::memcpy(renderer.data() + 0x690, &direct_pointer, sizeof(direct_pointer));
  std::memcpy(common_context.data() + 8, &pointer, sizeof(pointer));
  const float light[4] = {9.909359f, 14.8059435f, 22.1802921f, 1.f};
  for (unsigned offset : {0xefe0u, 0xeff0u, 0xf000u}) {
    std::memcpy(environment.data() + offset, light, sizeof(light));
  }
  unsigned constants_cases = 0;
  float skylight = 1.7f;
  witcher::night::NativeImpact weather_skylight;
  weather_skylight.Initialize(&skylight);
  for (const auto& layout : witcher::night::native_layouts) {
    witcher::night::direct_constants_offset = layout.direct_buffer_offset;
    renderer.fill(0xa5);
    std::memcpy(renderer.data() + layout.direct_buffer_offset, &direct_pointer, sizeof(direct_pointer));
    for (const auto& [hour, weight] : {std::pair{0.f, 1.f}, std::pair{4.f, 1.f}, std::pair{5.f, 0.5f},
             std::pair{6.f, 0.f}, std::pair{12.f, 0.f}, std::pair{18.f, 0.f},
             std::pair{19.f, 0.5f}, std::pair{20.f, 1.f}, std::pair{24.f, 1.f}}) {
      const float time = hour / 24.f;
      std::memcpy(environment.data() + 0x15c0, &time, sizeof(time));
      assert(std::abs(witcher::night::ClockNightWeight(environment.data()) - weight) < 1e-6f);
      for (float weather_day : {0.f, 0.06610274f, 0.5f, 1.f})
        for (float intensity : {0.f, 0.25f, 1.f, 1.5f, 2.f}) {
          day = weather_day;
          witcher::night::sky_multiplier.store(intensity);
          witcher::night::direct_multiplier.store(intensity);
          witcher::night::fog_multiplier.store(intensity);
          witcher::night::haze_multiplier.store(intensity);
          witcher::night::visible_sky_multiplier.store(intensity);
          witcher::night::cloud_multiplier.store(intensity);
          witcher::night::water_multiplier.store(intensity);
          NativeBuilder(output.data(), input.data());
          const auto original_view = output;
          NativeDirectBuilder(renderer.data(), environment.data());
          const auto original_direct = direct_output;
          NativeCommonBuilder(common_context.data(), common_output.data());
          const auto original_common = common_output;
          NativeGlobalBuilder(&pointer, global_output.data());
          const auto original_global = global_output;
          witcher::night::BuildHook(output.data(), input.data());
          witcher::night::DirectConstantsHook(renderer.data(), environment.data());
          // Simulate starting/switching to Raster without another PT builder call.
          witcher::night::night_weight.store(1.f - weight);
          witcher::night::CommonConstantsHook(common_context.data(), common_output.data());
          assert(std::abs(witcher::night::night_weight.load() - weight) < 1e-6f);
          witcher::night::GlobalConstantsHook(&pointer, global_output.data());
          const float expected_factor = 1.f - weight + weight * intensity;
          auto verify = [&](auto& edited, const auto& original, std::initializer_list<unsigned> offsets) {
            auto restored = edited;
            for (unsigned offset : offsets) {
              float old[4], actual[4];
              std::memcpy(old, original.data() + offset, sizeof(old));
              std::memcpy(actual, edited.data() + offset, sizeof(actual));
              for (unsigned c = 0; c < 3; ++c) {
                assert(std::abs(actual[c] - old[c] * expected_factor) < 1e-5f * std::max(1.f, std::abs(old[c])));
              }
              assert(actual[3] == old[3]);
              std::memcpy(restored.data() + offset, original.data() + offset, 12);
            }
            assert(restored == original);
            if (intensity == 1.f || weight == 0.f) assert(edited == original);
          };
          verify(output, original_view, {0x280, 0x290, 0x2a0});
          verify(direct_output, original_direct, {0x10, 0x3d0, 0x3e0});
          auto common_without_probe_edits = common_output;
          for (unsigned offset : {0xb80u, 0xb84u, 0xb90u, 0xb94u}) {
            float actual, original;
            std::memcpy(&actual, common_output.data() + offset, sizeof(actual));
            std::memcpy(&original, original_common.data() + offset, sizeof(original));
            assert(std::abs(actual - original * expected_factor) < 1e-6f);
            std::memcpy(common_without_probe_edits.data() + offset, &original, sizeof(original));
          }
          VerifyPackedFactors(common_output.data(), expected_factor, expected_factor);
          std::memcpy(common_without_probe_edits.data() + 0xb9c, original_common.data() + 0xb9c, sizeof(float));
          verify(common_without_probe_edits, original_common, {0x270, 0x280, 0x290, 0xbd0, 0xbf0, 0x2d0, 0x2e0, 0x2f0,
                0xc20, 0xc30, 0xc40, 0xc50, 0xc60, 0xc70, 0xc80, 0xc90, 0xca0,
                0xf40, 0xf50, 0xf60, 0xf70, 0xf80, 0xf90, 0x1160});
          auto restored_global = global_output;
          for (unsigned offset : {0xb0u, 0xb4u, 0xb8u, 0xc8u, 0xccu, 0xe0u}) {
            float actual, original;
            std::memcpy(&actual, global_output.data() + offset, sizeof(actual));
            std::memcpy(&original, original_global.data() + offset, sizeof(original));
            assert(std::abs(actual - original * expected_factor) < 1e-6f);
            std::memcpy(restored_global.data() + offset, &original, sizeof(original));
          }
          assert(restored_global == original_global); // Refraction/foam/other constants untouched.
          if (intensity == 1.f || weight == 0.f) assert(global_output == original_global);
          assert(std::abs(witcher::night::night_weight.load() - weight) < 1e-6f);
          // The captured storm left 0.112375 of native 1.7 skylight at slider 0.
          // Exercise the complete clock -> cached weight -> native impact path:
          // zero at full night, original at daytime, independent of weather.
          weather_skylight.Update(intensity, witcher::night::night_weight.load());
          assert(std::abs(skylight - 1.7f * expected_factor) < 1e-6f);
          if (intensity == 0.f && weight == 1.f) assert(skylight == 0.f);
          if (intensity == 1.f || weight == 0.f) assert(skylight == 1.7f);
          ++constants_cases;
        }
    }
  }
  witcher::night::direct_constants_offset = 0x690;
  std::memcpy(renderer.data() + 0x690, &direct_pointer, sizeof(direct_pointer));

  // Rain-only transport: full night, smooth fades, day and unsupported layout.
  witcher::night::sky_multiplier = 1.f;
  witcher::night::water_multiplier = 1.f;
  for (bool available : {false, true}) {
    witcher::night::rain_supported = available;
    for (float hour : {0.f, 5.f, 12.f}) {
      const float time = hour / 24.f;
      std::memcpy(environment.data() + 0x15c0, &time, sizeof(time));
      const float weight = witcher::night::ClockNightWeight(environment.data());
      for (float intensity : {0.f, 0.3f, 1.f, 2.f}) {
        witcher::night::rain_multiplier = intensity;
        NativeGlobalBuilder(&pointer, global_output.data());
        const auto original = global_output;
        witcher::night::GlobalConstantsHook(&pointer, global_output.data());
        uint32_t packed;
        std::memcpy(&packed, global_output.data() + 0xec, sizeof(packed));
        if (available && intensity != 1.f && weight != 0.f) {
          assert((packed & WITCHER_RAIN_TAG_MASK) == WITCHER_RAIN_TAG);
          assert(std::abs(float(packed & WITCHER_RAIN_FACTOR_MASK) / WITCHER_RAIN_FACTOR_SCALE
                          - (1.f + (intensity - 1.f) * weight)) <= 0.5f / WITCHER_RAIN_FACTOR_SCALE);
          std::memcpy(global_output.data() + 0xec, original.data() + 0xec, sizeof(packed));
        } else assert(packed == 0);
        assert(global_output == original);
      }
    }
  }
  witcher::night::rain_multiplier = 1.f;

  // Sky-only water edits preserve the native return pointer and every other
  // byte. Fresh weather values must never accumulate last frame's multiplier;
  // Water Lighting is independent, and daytime/native strength is exact.
  witcher::night::build_sky_constants = NativeSkyBuilder;
  std::array<unsigned char, 0xe0> sky_output;
  unsigned water_sky_cases = 0;
  for (float hour : {0.f, 5.f, 12.f}) {
    const float time = hour / 24.f;
    std::memcpy(environment.data() + 0x15c0, &time, sizeof(time));
    const float weight = witcher::night::ClockNightWeight(environment.data());
    for (float intensity : {0.f, 0.3f, 1.f, 2.f}) {
      witcher::night::sky_multiplier = intensity;
      for (float water_intensity : {0.f, 2.f}) {
        witcher::night::water_multiplier = water_intensity;
        for (float native : {0.f, 0.35f, 2.5f}) {
          std::memcpy(environment.data() + 0xf1e4, &native, sizeof(native));
          const float reflection = native * 0.7f;
          std::memcpy(environment.data() + 0xf1dc, &reflection, sizeof(reflection));
          const auto original_environment = environment;
          NativeGlobalBuilder(&pointer, global_output.data());
          const auto original_global = global_output;
          witcher::night::GlobalConstantsHook(&pointer, global_output.data());
          float actual_fill;
          std::memcpy(&actual_fill, global_output.data() + 0xe0, sizeof(actual_fill));
          assert(std::abs(actual_fill - water_sky * (1.f + (intensity - 1.f) * weight)) < 1e-6f);
          // Restoring just the existing Water Lighting fields and the sky
          // scalar must recover every global byte, including refraction data.
          auto restored_global = global_output;
          for (unsigned offset : {0xb0u, 0xb4u, 0xb8u, 0xc8u, 0xccu, 0xe0u}) {
            std::memcpy(restored_global.data() + offset, original_global.data() + offset, sizeof(float));
          }
          assert(restored_global == original_global);
          NativeSkyBuilder(sky_output.data(), environment.data());
          const auto original = sky_output;
          for (unsigned frame = 0; frame < 2; ++frame) {
            assert(witcher::night::SkyConstantsHook(sky_output.data(), environment.data()) == sky_output.data());
            auto restored = sky_output;
            for (unsigned offset : {0x40u, 0x54u}) {
              float actual, baseline;
              std::memcpy(&actual, sky_output.data() + offset, sizeof(actual));
              std::memcpy(&baseline, original.data() + offset, sizeof(baseline));
              assert(std::abs(actual - baseline * (1.f + (intensity - 1.f) * weight)) < 1e-6f);
              std::memcpy(restored.data() + offset, &baseline, sizeof(baseline));
            }
            assert(restored == original && environment == original_environment);
            if (intensity == 1.f || weight == 0.f) assert(sky_output == original);
          }
          ++water_sky_cases;
        }
      }
    }
  }
  witcher::night::sky_multiplier = witcher::night::water_multiplier = 1.f;
  std::printf("Water sky contribution: %u weather/fade/independence cases passed.\n", water_sky_cases);

  unsigned schedule_cases = 0;
  const auto verify_schedule = [&](std::array<float, 4> hours,
                                   std::initializer_list<std::pair<float, float>> samples) {
    witcher::night::darkening_start = hours[0];
    witcher::night::full_darkness_start = hours[1];
    witcher::night::fade_out_start = hours[2];
    witcher::night::darkening_end = hours[3];
    witcher::night::night_schedule = witcher::night::NightSchedule();
    witcher::night::direct_multiplier = 0.f;
    for (const auto& [hour, weight] : samples) {
      const float time = hour / 24.f;
      std::memcpy(environment.data() + 0x15c0, &time, sizeof(time));
      assert(std::abs(witcher::night::ClockNightWeight(environment.data()) - weight) < 1e-6f);
      NativeBuilder(output.data(), input.data());
      auto expected = output;
      for (unsigned offset : {0x280u, 0x290u, 0x2a0u}) {
        for (unsigned channel = 0; channel < 3; ++channel) {
          float value;
          std::memcpy(&value, expected.data() + offset + channel * 4, sizeof(value));
          value *= 1.f - weight;
          std::memcpy(expected.data() + offset + channel * 4, &value, sizeof(value));
        }
      }
      witcher::night::BuildHook(output.data(), input.data());
      for (unsigned offset : {0x280u, 0x290u, 0x2a0u}) {
        for (unsigned channel = 0; channel < 3; ++channel) {
          float actual, reference;
          std::memcpy(&actual, output.data() + offset + channel * 4, sizeof(actual));
          std::memcpy(&reference, expected.data() + offset + channel * 4, sizeof(reference));
          assert(std::abs(actual - reference) < 4e-5f);
        }
        std::memcpy(output.data() + offset, expected.data() + offset, 12);
      }
      assert(output == expected); // Includes unchanged alpha/other view fields.
      assert(std::abs(witcher::night::night_weight.load() - weight) < 1e-6f);
      weather_skylight.Update(0.f, witcher::night::night_weight.load());
      assert(std::abs(skylight - 1.7f * (1.f - weight)) < 1e-6f);
      ++schedule_cases;
    }
  };
  verify_schedule({21.f, 23.f, 5.f, 7.f}, {{20.f, 0.f}, {21.f, 0.f}, {22.f, .5f},
      {23.f, 1.f}, {0.f, 1.f}, {5.f, 1.f}, {6.f, .5f}, {7.f, 0.f}, {8.f, 0.f}});
  // Both fades can cross midnight, independently of the full-strength period.
  verify_schedule({22.f, 1.f, 4.f, 8.f}, {{22.f, 0.f}, {23.5f, .5f}, {0.f, 20.f / 27.f},
      {24.f, 20.f / 27.f}, {1.f, 1.f}, {4.f, 1.f}, {6.f, .5f}, {8.f, 0.f}});
  verify_schedule({18.f, 20.f, 23.f, 2.f}, {{19.f, .5f}, {23.f, 1.f}, {0.f, 20.f / 27.f},
      {0.5f, .5f}, {2.f, 0.f}});
  verify_schedule({8.f, 10.f, 14.f, 16.f}, {{0.f, 0.f}, {8.f, 0.f}, {9.f, .5f},
      {10.f, 1.f}, {12.f, 1.f}, {15.f, .5f}, {16.f, 0.f}});
  verify_schedule({0.f, 2.f, 4.f, 6.f}, {{0.f, 0.f}, {1.f, .5f}, {3.f, 1.f}, {5.f, .5f}, {6.f, 0.f}});
  verify_schedule({24.f, 2.f, 4.f, 6.f}, {{0.f, 0.f}, {24.f, 0.f}, {1.f, .5f}, {5.f, .5f}});
  verify_schedule({18.f, 18.f, 4.f, 4.f}, {{17.9f, 0.f}, {18.f, 1.f}, {0.f, 1.f}, {4.f, 0.f}});
  verify_schedule({18.f, 20.f, 20.f, 22.f}, {{19.f, .5f}, {20.f, 1.f}, {21.f, .5f}, {22.f, 0.f}});
  verify_schedule({18.5f, 20.5f, 4.5f, 6.5f}, {{18.5f, 0.f}, {19.5f, .5f}, {20.5f, 1.f}, {5.5f, .5f}, {6.5f, 0.f}});
  for (const auto& hours : {std::array{18.f, 4.f, 20.f, 6.f}, std::array{18.f, 20.f, 4.f, 18.f},
                            std::array{0.f, 0.f, 0.f, 0.f}, std::array{-1.f, 20.f, 4.f, 6.f},
                            std::array{18.f, 25.f, 4.f, 6.f},
                            std::array{18.f, std::numeric_limits<float>::quiet_NaN(), 4.f, 6.f}}) {
    verify_schedule(hours, {{0.f, 0.f}, {5.f, 0.f}, {12.f, 0.f}, {19.f, 0.f}});
    assert(witcher::night::NightSchedule() == 0);
  }
  verify_schedule({18.f, 20.f, 4.f, 6.f}, {{0.f, 1.f}, {19.f, .5f}, {5.f, .5f}});

  // Skylight-only edits preserve direct lighting enables, distance fade, fog,
  // material colors and every other common constant, without a PT frame.
  witcher::night::direct_multiplier = witcher::night::fog_multiplier = 1.f;
  witcher::night::haze_multiplier = witcher::night::visible_sky_multiplier = 1.f;
  witcher::night::cloud_multiplier = witcher::night::water_multiplier = 1.f;
  witcher::night::sky_multiplier = 0.f;
  for (float hour : {0.f, 12.f}) {
    const float time = hour / 24.f;
    std::memcpy(environment.data() + 0x15c0, &time, sizeof(time));
    NativeCommonBuilder(common_context.data(), common_output.data());
    auto expected = common_output;
    if (hour == 0.f) {
      for (unsigned offset : {0xb80u, 0xb84u, 0xb90u, 0xb94u}) {
        std::memset(expected.data() + offset, 0, sizeof(float));
      }
    }
    if (hour == 0.f) {
      const uint32_t tag = 0xd0000000u | 8191u;
      std::memcpy(expected.data() + 0xb9c, &tag, sizeof(tag));
    }
    witcher::night::night_weight = hour == 0.f ? 0.f : 1.f;
    witcher::night::CommonConstantsHook(common_context.data(), common_output.data());
    assert(common_output == expected);
    assert(witcher::night::night_weight.load() == (hour == 0.f ? 1.f : 0.f));
  }

  // Cloud-only edits must preserve moon/star colors, alpha, atmosphere and
  // every other byte of SharedPixelConsts, including at midday.
  witcher::night::fog_multiplier = witcher::night::haze_multiplier = 1.f;
  witcher::night::visible_sky_multiplier = 1.f;
  witcher::night::sky_multiplier = 1.f;
  witcher::night::cloud_multiplier = 0.f;
  for (float hour : {0.f, 12.f}) {
    const float time = hour / 24.f;
    std::memcpy(environment.data() + 0x15c0, &time, sizeof(time));
    NativeCommonBuilder(common_context.data(), common_output.data());
    auto expected = common_output;
    if (hour == 0.f) {
      for (unsigned offset : {0xf40u, 0xf50u, 0xf60u, 0xf70u, 0xf80u}) {
        std::memset(expected.data() + offset, 0, 12);
      }
      const uint32_t tag = 0xd0000000u | (8191u << 14);
      std::memcpy(expected.data() + 0xb9c, &tag, sizeof(tag));
    }
    witcher::night::CommonConstantsHook(common_context.data(), common_output.data());
    assert(common_output == expected);
  }
  // Sky-only control covers the added horizon gradient without changing
  // the moon color, cloud base colors, alpha, fog or any other constants.
  witcher::night::cloud_multiplier = 1.f;
  witcher::night::visible_sky_multiplier = 0.f;
  for (float hour : {0.f, 12.f}) {
    const float time = hour / 24.f;
    std::memcpy(environment.data() + 0x15c0, &time, sizeof(time));
    NativeCommonBuilder(common_context.data(), common_output.data());
    auto expected = common_output;
    if (hour == 0.f) {
      for (unsigned offset : {0xc30u, 0xc40u, 0xc50u, 0xc60u, 0xc70u,
                              0xc80u, 0xc90u, 0xca0u, 0xf90u, 0x1160u}) {
        std::memset(expected.data() + offset, 0, 12);
      }
    }
    witcher::night::CommonConstantsHook(common_context.data(), common_output.data());
    assert(common_output == expected);
  }
  for (float time : {-1.f, 1.1f, std::numeric_limits<float>::quiet_NaN()}) {
    std::memcpy(environment.data() + 0x15c0, &time, sizeof(time));
    assert(witcher::night::ClockNightWeight(environment.data()) == 0.f);
    NativeBuilder(output.data(), input.data());
    const auto original_view = output;
    witcher::night::BuildHook(output.data(), input.data());
    assert(output == original_view && witcher::night::night_weight.load() == 0.f);
    NativeCommonBuilder(common_context.data(), common_output.data());
    const auto original = common_output;
    witcher::night::CommonConstantsHook(common_context.data(), common_output.data());
    assert(common_output == original);
    NativeGlobalBuilder(&pointer, global_output.data());
    const auto original_global = global_output;
    witcher::night::GlobalConstantsHook(&pointer, global_output.data());
    assert(global_output == original_global);
  }

  float sky = 1.7f;
  witcher::night::NativeImpact impact;
  impact.Initialize(&sky);
  for (unsigned i = 0; i < 1000; ++i) impact.Update(0.5f, 1.f);
  assert(sky == 0.85f); // No repeated/compounded darkening.
  impact.Update(0.f, 0.f);
  assert(sky == 1.7f); // Full daytime lighting even at zero night intensity.
  sky = 2.4f; // A game setting or another native configuration update.
  impact.Update(0.f, 0.5f);
  assert(sky == 1.2f);
  impact.Update(1.f, 1.f);
  assert(sky == 2.4f); // Vanilla/reset restores the new native baseline.

  // Weather's day weight does not control our clock-based skylight fade.
  const float midnight = 0.f;
  std::memcpy(environment.data() + 0x15c0, &midnight, sizeof(midnight));
  witcher::night::direct_multiplier = 1.f;
  day = std::numeric_limits<float>::quiet_NaN();
  NativeBuilder(output.data(), input.data());
  const auto invalid_day_output = output;
  witcher::night::BuildHook(output.data(), input.data());
  assert(output == invalid_day_output && witcher::night::night_weight.load() == 1.f);
  // Updates/reset must restore all active native impacts and callback scales.
  witcher::night::installed = witcher::night::attempted = true;
  witcher::night::lighting_enabled = 1.f;
  witcher::night::sky_impact.Initialize(&sky);
  witcher::night::sky_strength = 0.f;
  witcher::night::direct_strength = witcher::night::fog_strength = witcher::night::haze_strength
      = witcher::night::visible_sky_strength = witcher::night::cloud_strength
      = witcher::night::water_strength = witcher::night::rain_strength = 0.f;
  witcher::night::night_weight.store(1.f);
  witcher::night::Update(true);
  assert(sky == 0.f);
  assert(witcher::night::cloud_multiplier.load() == 0.f);
  assert(witcher::night::water_multiplier.load() == 0.f);
  assert(witcher::night::rain_multiplier.load() == 0.f);
  assert(witcher::night::sky_multiplier.load() == 0.f);
  witcher::night::Update(false);
  assert(sky == 2.4f);
  assert(witcher::night::direct_multiplier.load() == 1.f && witcher::night::fog_multiplier.load() == 1.f
      && witcher::night::haze_multiplier.load() == 1.f && witcher::night::visible_sky_multiplier.load() == 1.f);
  assert(witcher::night::cloud_multiplier.load() == 1.f);
  assert(witcher::night::water_multiplier.load() == 1.f);
  assert(witcher::night::rain_multiplier.load() == 1.f);
  assert(witcher::night::sky_multiplier.load() == 1.f);
  // Master Off restores fresh native view/CB data and the PT skylight CVar,
  // even at midnight with every stored slider at zero. Camera fill is separate.
  witcher::night::camera_strength = 0.f;
  witcher::night::lighting_enabled = 0.f;
  witcher::night::Update(true);
  assert(sky == 2.4f && witcher::night::camera_multiplier.load() == 0.f);
  for (const auto* multiplier : {&witcher::night::sky_multiplier, &witcher::night::direct_multiplier,
                                &witcher::night::fog_multiplier, &witcher::night::haze_multiplier,
                                &witcher::night::visible_sky_multiplier, &witcher::night::cloud_multiplier,
                                &witcher::night::water_multiplier, &witcher::night::rain_multiplier}) {
    assert(multiplier->load() == 1.f);
  }
  NativeBuilder(output.data(), input.data());
  const auto native_view = output;
  witcher::night::BuildHook(output.data(), input.data());
  assert(output == native_view);
  NativeDirectBuilder(renderer.data(), environment.data());
  const auto native_direct = direct_output;
  witcher::night::DirectConstantsHook(renderer.data(), environment.data());
  assert(direct_output == native_direct);
  NativeCommonBuilder(common_context.data(), common_output.data());
  const auto native_common = common_output;
  witcher::night::CommonConstantsHook(common_context.data(), common_output.data());
  assert(common_output == native_common); // Includes untagged RT skylight and native clouds.
  NativeGlobalBuilder(&pointer, global_output.data());
  const auto native_global = global_output;
  witcher::night::GlobalConstantsHook(&pointer, global_output.data());
  assert(global_output == native_global);
  assert(witcher::night::sky_strength == 0.f && witcher::night::direct_strength == 0.f
      && witcher::night::fog_strength == 0.f && witcher::night::haze_strength == 0.f
      && witcher::night::visible_sky_strength == 0.f && witcher::night::cloud_strength == 0.f
      && witcher::night::water_strength == 0.f);
  witcher::night::lighting_enabled = 1.f;
  witcher::night::Update(true);
  assert(sky == 0.f && witcher::night::sky_multiplier.load() == 0.f);
  witcher::night::full_darkness_start = 5.f; // Full strength would follow fade-out.
  witcher::night::Update(true);
  assert(sky == 2.4f && witcher::night::sky_multiplier.load() == 1.f);
  assert(witcher::night::night_schedule.load() == 0 && witcher::night::camera_multiplier.load() == 0.f);
  witcher::night::full_darkness_start = 20.f;
  witcher::night::Update(true);
  assert(sky == 0.f && witcher::night::night_schedule.load() != 0);
  witcher::night::Update(false);
  assert(sky == 2.4f && witcher::night::camera_multiplier.load() == 1.f);
  // Exercise independent gameplay and cutscene intensities against all four
  // native enum groups, both lights, failed builds and fresh repeated outputs.
  witcher::night::build_camera_light = NativeCameraBuilder;
  unsigned camera_cases = 0;
  for (float gameplay : {0.f, 0.5f, 1.f, 2.f}) {
    for (float cutscene : {0.f, 0.5f, 1.f, 2.f}) {
      witcher::night::camera_multiplier = gameplay;
      witcher::night::cutscene_multiplier = cutscene;
      for (bool supported : {false, true}) {
        witcher::night::cutscene_supported = supported;
        for (unsigned type = 0; type < 4; ++type) {
          for (unsigned light = 0; light < 2; ++light) {
            for (bool success : {false, true}) {
              camera_built = success;
              const auto* matrix = environment.data() + 0x10;
              const auto* evaluated = environment.data() + 0xf3b8 + type * 0x60 + light * 0x30;
              const auto* curves = environment.data() + (type == 0 ? 0x52f0 : type == 1 ? 0x5150 : type == 2 ? 0x5490 : 0x5630)
                                   + light * 0xd0;
              NativeCameraBuilder(camera_output.data(), matrix, evaluated, curves, input.data(), 0.25f, nullptr);
              auto expected = camera_output;
              const float scale = type == 1 ? gameplay : supported && (type == 0 || type == 2) ? cutscene : 1.f;
              if (success) {
                const std::array<float, 3> rgb{2.f * scale, 4.f * scale, 8.f * scale};
                std::memcpy(expected.data() + 0x30, rgb.data(), sizeof(rgb));
              }
              for (unsigned repeat = 0; repeat < 3; ++repeat) {
                assert(witcher::night::CameraLightHook(camera_output.data(), matrix, evaluated, curves,
                                                      input.data(), 0.25f, nullptr) == success);
                assert(camera_output == expected); // Full buffer, no compounding.
              }
              ++camera_cases;
            }
          }
        }
      }
    }
  }
  camera_built = true;
  witcher::night::cutscene_supported = true;
  witcher::night::camera_multiplier = witcher::night::cutscene_multiplier = 0.f;
  // A matching evaluated pointer alone must never identify a camera light.
  // Also exclude the builder's unrelated color-list path.
  for (unsigned index = 0; index < 8; ++index) {
    const auto* matrix = environment.data() + 0x10;
    const auto* evaluated = environment.data() + 0xf3b8 + index * 0x30;
    for (const void* curves : {static_cast<const void*>(environment.data()),
                               static_cast<const void*>(environment.data() + 0x5151)}) {
      NativeCameraBuilder(camera_output.data(), matrix, evaluated, curves, input.data(), 0.25f, nullptr);
      const auto expected = camera_output;
      assert(witcher::night::CameraLightHook(camera_output.data(), matrix, evaluated, curves,
                                            input.data(), 0.25f, nullptr));
      assert(camera_output == expected);
      ++camera_cases;
    }
    const auto* curves = environment.data() + (index / 2 == 0 ? 0x52f0 : index / 2 == 1 ? 0x5150 : index / 2 == 2 ? 0x5490 : 0x5630)
                         + (index % 2) * 0xd0;
    NativeCameraBuilder(camera_output.data(), matrix, evaluated, curves, input.data(), 0.25f, input.data());
    const auto expected = camera_output;
    assert(witcher::night::CameraLightHook(camera_output.data(), matrix, evaluated, curves,
                                          input.data(), 0.25f, input.data()));
    assert(camera_output == expected);
    ++camera_cases;
  }
  witcher::night::camera_strength = 50.f;
  witcher::night::lighting_enabled = 0.f;
  witcher::night::night_weight = 0.f;
  for (const auto& [strength, expected] : {
           std::pair{0.f, 0.f}, std::pair{25.f, 0.5f}, std::pair{50.f, 1.f},
           std::pair{100.f, 2.f}, std::pair{-1.f, 0.f}, std::pair{101.f, 2.f},
           std::pair{std::numeric_limits<float>::quiet_NaN(), 1.f},
           std::pair{std::numeric_limits<float>::infinity(), 1.f}}) {
    witcher::night::cutscene_strength = strength;
    witcher::night::Update(true);
    assert(witcher::night::cutscene_multiplier.load() == expected);
    assert(witcher::night::camera_multiplier.load() == 1.f);
    witcher::night::Update(false);
    assert(witcher::night::cutscene_multiplier.load() == 1.f);
  }
  witcher::night::cutscene_strength = 50.f;
  witcher::night::camera_strength = 0.f;
  witcher::night::Update(true);
  assert(witcher::night::camera_multiplier.load() == 0.f); // Also daytime.
  assert(witcher::night::cutscene_multiplier.load() == 1.f);
  witcher::night::Update(false);
  assert(witcher::night::camera_multiplier.load() == 1.f); // Vanilla/unload.
  witcher::night::camera_strength = std::numeric_limits<float>::quiet_NaN();
  witcher::night::Update(true);
  assert(witcher::night::camera_multiplier.load() == 1.f);
  unsigned sun_cases = 0;
  witcher::night::sun_supported = true;
  for (float hour : {0.f, 6.f, 12.f, 18.f}) {
    const float time = hour / 24.f;
    std::memcpy(environment.data() + 0x15c0, &time, sizeof(time));
    for (float size : {1.f, 50.f, 100.f, 200.f, 500.f, -1.f, 501.f,
                       std::numeric_limits<float>::quiet_NaN(), std::numeric_limits<float>::infinity()}) {
      witcher::night::sun_size = size;
      witcher::night::Update(true); // Night master remains Off.
      const float expected = std::isfinite(size) ? std::clamp(size / 100.f, 0.01f, 5.f) : 1.f;
      assert(witcher::night::sun_multiplier.load() == expected);
      NativeCommonBuilder(common_context.data(), common_output.data());
      const auto original = common_output;
      witcher::night::CommonConstantsHook(common_context.data(), common_output.data());
      float exponent;
      std::memcpy(&exponent, common_output.data() + 0xcc0, sizeof(exponent));
      assert(exponent == sun_exponent / (expected * expected));
      uint32_t bits;
      std::memcpy(&bits, common_output.data() + 0xcec, sizeof(bits));
      if (expected == 1.f) assert(bits == 0);
      else {
        assert((bits & 0xffff0000u) == 0x53550000u);
        assert(std::abs(float(bits & 0xffffu) / 8192.f - expected) <= 0.5f / 8192.f);
      }
      std::memcpy(common_output.data() + 0xcc0, original.data() + 0xcc0, sizeof(exponent));
      std::memcpy(common_output.data() + 0xcec, original.data() + 0xcec, sizeof(bits));
      assert(common_output == original); // Moon, directions, lighting, fog and alpha survive.
      witcher::night::Update(false);
      assert(witcher::night::sun_multiplier.load() == 1.f);
      witcher::night::CommonConstantsHook(common_context.data(), common_output.data());
      assert(common_output == original);
      ++sun_cases;
    }
  }
  witcher::night::sun_size = 50.f;
  witcher::night::Update(true);
  for (float invalid : {0.f, -1.f, std::numeric_limits<float>::quiet_NaN(),
                         std::numeric_limits<float>::infinity(), std::numeric_limits<float>::max()}) {
    sun_exponent = invalid;
    NativeCommonBuilder(common_context.data(), common_output.data());
    const auto original = common_output;
    witcher::night::CommonConstantsHook(common_context.data(), common_output.data());
    uint32_t bits;
    std::memcpy(&bits, common_output.data() + 0xcec, sizeof(bits));
    assert(bits == (0x53550000u | 4096u)); // Mesh still scales if glow data is invalid.
    std::memcpy(common_output.data() + 0xcec, original.data() + 0xcec, sizeof(bits));
    assert(common_output == original);
    ++sun_cases;
  }
  sun_exponent = 1024.f;
  witcher::night::sun_supported = false;
  witcher::night::Update(true);
  assert(witcher::night::sun_multiplier.load() == 1.f);
  witcher::night::sun_size = 100.f;
  unsigned moon_cases = 0;
  witcher::night::moon_supported = true;
  for (float hour : {0.f, 12.f}) {
    const float time = hour / 24.f;
    std::memcpy(environment.data() + 0x15c0, &time, sizeof(time));
    for (const auto& [size, expected] : {
             std::pair{1.f, 0.01f}, std::pair{50.f, 0.5f}, std::pair{100.f, 1.f},
             std::pair{200.f, 2.f}, std::pair{500.f, 5.f},
             std::pair{-1.f, 0.01f}, std::pair{501.f, 5.f},
             std::pair{std::numeric_limits<float>::quiet_NaN(), 1.f},
             std::pair{std::numeric_limits<float>::infinity(), 1.f}}) {
      witcher::night::moon_size = size;
      witcher::night::Update(true); // Night master remains Off.
      assert(witcher::night::moon_multiplier.load() == expected);
      NativeCommonBuilder(common_context.data(), common_output.data());
      const auto original = common_output;
      witcher::night::CommonConstantsHook(common_context.data(), common_output.data());
      uint32_t bits;
      std::memcpy(&bits, common_output.data() + 0x25c, sizeof(bits));
      if (expected == 1.f) assert(bits == 0);
      else {
        assert((bits & 0xffff0000u) == 0x4d4f0000u);
        assert(std::abs(float(bits & 0xffffu) / 8192.f - expected) <= 0.5f / 8192.f);
      }
      std::memcpy(common_output.data() + 0x25c, original.data() + 0x25c, sizeof(bits));
      assert(common_output == original); // Lighting, fog, camera and other padding survive.
      witcher::night::Update(false);
      assert(witcher::night::moon_multiplier.load() == 1.f);
      witcher::night::CommonConstantsHook(common_context.data(), common_output.data());
      assert(common_output == original);
      ++moon_cases;
    }
  }
  witcher::night::moon_supported = false;
  witcher::night::moon_size = 50.f;
  witcher::night::Update(true);
  assert(witcher::night::moon_multiplier.load() == 1.f);
  witcher::night::moon_size = 100.f;
  // A cutscene-only change must request hook installation even with neutral
  // gameplay and disabled night lighting. Fail safely before touching threads.
  witcher::night::installed = false;
  witcher::night::attempted = false;
  witcher::night::checked = true;
  witcher::night::supported = false;
  witcher::night::camera_strength = 50.f;
  witcher::night::cutscene_strength = 0.f;
  witcher::night::Update(true);
  assert(witcher::night::attempted && !witcher::night::installed);
  // Moon-only edits also install the common builder with all lighting neutral.
  witcher::night::attempted = false;
  witcher::night::cutscene_strength = 50.f;
  witcher::night::moon_size = 50.f;
  witcher::night::Update(true);
  assert(witcher::night::attempted && !witcher::night::installed);
  std::printf("Moon size: %u day/night transport, isolation and restore cases passed.\n", moon_cases);
  witcher::night::attempted = false;
  witcher::night::moon_size = 100.f;
  witcher::night::sun_size = 50.f;
  witcher::night::Update(true);
  assert(witcher::night::attempted && !witcher::night::installed);
  std::printf("Sun size: %u all-hour width, isolation, invalid-input and restore cases passed.\n", sun_cases);
  std::printf("Camera lighting: %u gameplay/cutscene isolation and failed-build cases; independent controls and restore checks passed.\n", camera_cases);
  std::printf("Night schedule: %u custom-hour/cross-midnight/invalid/instant-fade cases passed.\n", schedule_cases);
  std::printf("Night lighting: %u renderer/water/skylight cases; master toggle, camera independence, restore/rebase checks passed.\n",
              constants_cases);
}
