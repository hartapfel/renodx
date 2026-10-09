/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#include <array>
#include <cassert>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <limits>

#include "../night_exposure.hpp"

int main() {
  using namespace witcher::night::exposure;
  supported = true;
  rate_caller = 0x1c147a9;
  unsigned cases = 0;
  // Compare with a separately evaluated continuous-time native response.
  // Each frame rate must advance the same wall-clock adaptation distance.
  enabled = 1.f;
  adaptation = 2.f;
  for (float up : {1.f, 25.f, 100.f, 200.f}) for (float down : {1.f, 50.f, 100.f, 200.f}) {
    brightening_speed = up;
    darkening_speed = down;
    Update(true);
    for (unsigned fps : {30u, 60u, 120u, 240u}) for (float weight : {0.f, 0.5f, 1.f}) {
      const float dt = 1.f / fps;
      const std::array<float, 4> native{-std::expm1(-0.5f * dt * 8.f),
                                       -std::expm1(-0.5f * dt * 12.f), 17.f, 23.f};
      auto adjusted = native;
      const bool changed = AdjustConstants(20, adjusted.data(), rate_caller, weight);
      if (weight == 0.f || (up == 100.f && down == 100.f)) {
        assert(!changed && adjusted == native);
      }
      assert(adjusted[2] == native[2] && adjusted[3] == native[3]);
      const float speeds[] = {8.f * (1.f + (up / 100.f - 1.f) * weight),
                              12.f * (1.f + (down / 100.f - 1.f) * weight)};
      for (unsigned i = 0; i < 2; ++i) {
        double history = 1.;
        for (unsigned frame = 0; frame < fps; ++frame) history *= 1. - adjusted[i];
        assert(std::abs(history - std::exp(-0.5 * speeds[i])) < 2e-6);
      }
      ++cases;
    }
  }
  // Native mode and every inactive/master-Off path preserve all bits.
  for (float mode : {0.f, 1.f, 2.f, 3.f, std::numeric_limits<float>::quiet_NaN()}) {
    adaptation = mode;
    for (bool active : {false, true}) {
      Update(active);
      auto values = std::array{0.128f, 0.254f, 13.f, 19.f};
      if (!active || mode == 0.f || mode == 3.f || !std::isfinite(mode)) {
        const auto native = values;
        assert(!AdjustConstants(20, values.data(), rate_caller, 1.f) && values == native);
      } else if (mode == 1.f) {
        assert(brightening_scale == 0.35f && darkening_scale == 0.05f);
      }
      ++cases;
    }
  }
  enabled = 0.f;
  // Fixed mode must ignore measured luminance in both transition states,
  // preserve native curve/metadata, and blend monotonically during clock fades.
  for (float reference : {0.001f, 0.18f, 1.f, 10.f}) {
    fixed_luminance = reference;
    Update(true);
    assert(brightening_scale == 1.f && darkening_scale == 1.f);
    for (int32_t offset : {0, -0x1620}) {
      caller_offset = offset;
      for (const auto& [slot, address] : limit_uploads) for (float weight : {0.f, 0.25f, 0.5f, 1.f}) {
        const auto caller = static_cast<uintptr_t>(int64_t(address) + offset);
        auto values = std::array{1.f, 0.f, 1.2536783f, 19.f};
        const auto native = values;
        assert(AdjustConstants(slot, values.data(), caller, weight) == (weight != 0.f));
        assert(values[0] == native[0] && values[3] == native[3] && values[1] <= values[2]);
        if (weight == 0.f) assert(values == native);
        for (float measured : {0.f, 0.0001f, 0.01f, 0.18f, 1.f, 100.f, 10000.f}) {
          const float metered = std::max(std::min(std::max(measured, values[1]), values[2]), 0.0001f);
          if (weight == 1.f) {
            assert(metered == reference);
            // Actual native exposure formula, compared with the fixed variant.
            for (float shape : {0.f, 0.3834748f, 1.f}) for (float white_scale : {0.5f, 1.0263166f, 2.f}) {
              const float dynamic_gain = white_scale / (std::exp2(std::log2(metered / (white_scale * 11.2f)) * shape) * white_scale * 11.2f);
              const float fixed_gain = white_scale / (std::exp2(std::log2(reference / (white_scale * 11.2f)) * shape) * white_scale * 11.2f);
              assert(dynamic_gain == fixed_gain);
            }
          }
        }
        ++cases;
      }
    }
  }
  // Fixed mode preserves the live adaptation history; enabling it again
  // does not resume a luminance sample frozen when Off was first selected.
  auto values = std::array{0.128f, 0.254f, 13.f, 19.f};
  const auto native = values;
  assert(!AdjustConstants(20, values.data(), rate_caller, 1.f) && values == native);
  Update(false);
  assert(fixed_reference == 0.f);
  assert(!AdjustConstants(24, values.data(), 0x34cf4c, 1.f) && values == native);
  enabled = 1.f;
  adaptation = 1.f;
  Update(true);
  assert(darkening_range == smoothed_maximum_darkening / 100.f);
  // Amount and speed are independent. Limit darkening in exposure stops
  // while preserving the response to darker-than-reference measurements.
  adaptation = 2.f;
  brightening_speed = darkening_speed = 100.f;
  for (float maximum : {0.f, 10.f, 25.f, 100.f}) {
    maximum_darkening = maximum;
    Update(true);
    assert(brightening_scale == 1.f && darkening_scale == 1.f);
    for (const auto& [slot, caller] : limit_uploads) {
      caller_offset = 0;
      for (float low : {0.f, 0.1f, 1.f}) for (float high : {0.1f, 0.18f, 0.5f, 1.25f, 10.f}) {
        if (low > high) continue;
        for (float weight : {0.f, 0.25f, 0.5f, 1.f}) {
          auto limits = std::array{1.f, low, high, 19.f};
          const auto before = limits;
          const bool changed = AdjustConstants(slot, limits.data(), caller, weight);
          if (weight == 0.f || maximum == 100.f || high <= metering_anchor) {
            assert(!changed && limits == before);
          } else {
            assert(changed && limits[0] == before[0] && limits[3] == before[3]);
            assert(limits[1] <= limits[2] && limits[2] <= high && limits[2] >= metering_anchor);
            for (float shape : {0.3834748f, 1.f}) {
              const double native_darkening_stops = shape * std::log2(double(high) / metering_anchor);
              const double limited_darkening_stops = shape * std::log2(double(limits[2]) / metering_anchor);
              assert(std::abs(limited_darkening_stops - native_darkening_stops * (1. - weight * (1. - maximum / 100.))) < 1e-6);
            }
            if (maximum == 0.f && weight == 1.f) assert(limits[2] == metering_anchor);
            for (float measured : {0.0001f, 0.01f, 0.1f, metering_anchor}) {
              if (low <= metering_anchor) {
                assert(std::min(std::max(measured, limits[1]), limits[2])
                       == std::min(std::max(measured, before[1]), before[2]));
              }
            }
          }
          ++cases;
        }
      }
    }
  }
  maximum_darkening = 10.f;
  for (bool active : {false, true}) for (float auto_enabled : {0.f, 1.f}) for (float mode : {0.f, 1.f, 2.f}) {
    enabled = auto_enabled;
    adaptation = mode;
    Update(active);
    assert(darkening_range == (active && auto_enabled == 1.f && mode == 2.f ? 0.1f : 1.f));
    ++cases;
  }
  enabled = 1.f;
  adaptation = 1.f;
  Update(true);
  assert(brightening_range == 1.f);  // Smoothed preserves normal brightening.
  adaptation = 2.f;
  // Independently bound both sides, including native zero/negative floors
  // and authored ranges lying wholly above or below the reference.
  for (float maximum_up : {0.f, 10.f, 50.f, 100.f}) for (float maximum_down : {0.f, 10.f, 100.f}) {
    maximum_brightening = maximum_up;
    maximum_darkening = maximum_down;
    Update(true);
    for (const auto& [slot, caller] : limit_uploads) {
      for (float low : {-0.01f, 0.f, 0.000001f, 0.01f, 0.1f, metering_anchor, 0.5f}) {
        for (float high : {0.1f, metering_anchor, 0.5f, 2.f}) {
          if (low > high) continue;
          for (float weight : {0.f, 0.25f, 0.5f, 1.f}) {
            auto limits = std::array{1.f, low, high, 19.f};
            const auto before = limits;
            AdjustConstants(slot, limits.data(), caller, weight);
            assert(limits[0] == before[0] && limits[3] == before[3] && limits[1] <= limits[2]);
            if (weight == 0.f || (maximum_up == 100.f && maximum_down == 100.f)) assert(limits == before);
            if (weight == 1.f && maximum_up == 0.f && maximum_down == 0.f) {
              assert(limits[1] == metering_anchor && limits[2] == metering_anchor);
            }
            if (weight != 0.f && maximum_up != 100.f && low < metering_anchor) {
              const double native_lift_stops = std::log2(double(metering_anchor) / std::max(low, 0.0001f));
              const double limited_lift_stops = std::log2(double(metering_anchor) / limits[1]);
              assert(std::abs(limited_lift_stops - native_lift_stops * (1. - weight * (1. - maximum_up / 100.))) < 2e-6);
            }
            if (low <= metering_anchor && high >= metering_anchor) {
              if (maximum_up == 100.f) assert(limits[1] == before[1]);
              if (maximum_down == 100.f) assert(limits[2] == before[2]);
            }
            ++cases;
          }
        }
      }
    }
  }
  maximum_brightening = 10.f;
  for (bool active : {false, true}) for (float auto_enabled : {0.f, 1.f}) for (float mode : {0.f, 1.f, 2.f}) {
    enabled = auto_enabled;
    adaptation = mode;
    Update(active);
    assert(brightening_range == (active && auto_enabled == 1.f && mode == 2.f ? 0.1f : 1.f));
    ++cases;
  }
  enabled = 1.f;
  adaptation = 1.f;
  Update(true);
  // Unrelated callers, unsupported builds and invalid input never change data.
  for (auto caller : {uintptr_t{0}, rate_caller - 1, rate_caller + 1}) {
    values = native;
    assert(!AdjustConstants(20, values.data(), caller, 1.f) && values == native);
    ++cases;
  }
  for (float bad : {-1.f, 2.f, std::numeric_limits<float>::quiet_NaN(), std::numeric_limits<float>::infinity()}) {
    for (unsigned i : {0u, 1u}) {
      values = native;
      values[i] = bad;
      const auto before = values;
      assert(!AdjustConstants(20, values.data(), rate_caller, 1.f));
      assert(std::memcmp(before.data(), values.data(), sizeof(values)) == 0);
      ++cases;
    }
  }
  for (float bad_weight : {-1.f, 2.f, std::numeric_limits<float>::quiet_NaN()}) {
    values = native;
    assert(!AdjustConstants(20, values.data(), rate_caller, bad_weight) && values == native);
    ++cases;
  }
  for (float endpoint : {0.f, 1.f}) {
    values = {endpoint, endpoint, 13.f, 19.f};
    const auto before = values;
    assert(!AdjustConstants(20, values.data(), rate_caller, 1.f) && values == before);
    ++cases;
  }
  supported = false;
  values = native;
  assert(!AdjustConstants(20, values.data(), rate_caller, 1.f) && values == native);
  std::printf("Passed %u exposure cases: frame-rate compensation, direction rates, independent brightening/darkening limits, native identity, fixed/transition metering and guards.\n", cases);
}
