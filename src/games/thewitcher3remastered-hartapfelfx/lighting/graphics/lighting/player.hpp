/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once

#include <algorithm>
#include <atomic>
#include <bit>
#include <cmath>
#include <cstdint>
#include <cstring>

namespace witcher3graphics::player {

struct Controls {
  bool enabled = false;
  bool match_world = false;
  float gameplay = 1.f;
  float cutscene = 1.f;
};

inline std::atomic<uint64_t> published{0};

inline void Publish(bool enabled, bool match_world, float gameplay, float cutscene) {
  gameplay = std::isfinite(gameplay) ? std::clamp(gameplay, 0.f, 1.f) : 1.f;
  cutscene = std::isfinite(cutscene) ? std::clamp(cutscene, 0.f, 1.f) : 1.f;
  published.store(uint64_t(std::bit_cast<uint32_t>(gameplay) & 0x7fffffffu) | (uint64_t(enabled) << 31)
                      | (uint64_t(std::bit_cast<uint32_t>(cutscene) & 0x7fffffffu) << 32) | (uint64_t(match_world) << 63),
                  std::memory_order_release);
}

inline Controls GetControls() {
  const auto bits = published.load(std::memory_order_acquire);
  return {bool(bits & (1ull << 31)), bool(bits & (1ull << 63)),
          std::bit_cast<float>(uint32_t(bits) & 0x7fffffffu),
          std::bit_cast<float>(uint32_t(bits >> 32) & 0x7fffffffu)};
}

enum class Source { unknown,
                    scene,
                    gameplay,
                    dialogue,
                    interior };

inline Source Identify(const void* matrix, const void* evaluated, const void* curves) {
  if (!matrix || !evaluated || !curves) return Source::unknown;
  const auto light = reinterpret_cast<uintptr_t>(evaluated) - reinterpret_cast<uintptr_t>(matrix);
  const auto curve = reinterpret_cast<uintptr_t>(curves) - reinterpret_cast<uintptr_t>(matrix);
  // The matrix starts at evaluated environment +0x10. Require both independent
  // source identities; a light's color, flags or bank index is not sufficient.
  constexpr uintptr_t first_curves[] = {0x52e0, 0x5140, 0x5480, 0x5620};
  for (unsigned group = 0; group < 4; ++group) {
    for (unsigned endpoint = 0; endpoint < 2; ++endpoint) {
      if (light == 0xf3a8 + group * 0x60 + endpoint * 0x30
          && curve == first_curves[group] + endpoint * 0xd0) return static_cast<Source>(group + 1);
    }
  }
  return Source::unknown;
}

inline void Apply(void* output, void* colors, Source source, float world_gain, const Controls& controls) {
  if (!controls.enabled || !output || source == Source::unknown
      || (colors && source != Source::scene)) return;
  float scale = source == Source::gameplay ? controls.gameplay : controls.cutscene;
  if (controls.match_world) {
    if (!std::isfinite(world_gain) || world_gain < 0.f) return;
    scale *= world_gain;
  }
  if (!std::isfinite(scale) || scale == 1.f) return;
  auto* rgb = colors ? static_cast<unsigned char*>(colors) : static_cast<unsigned char*>(output) + 0x30;
  // Native Scene may defer RGB evaluation using two float4 endpoints. Preserve
  // their alpha/blend fields and every position/radius/type field in the bank.
  for (unsigned endpoint = 0; endpoint < (colors ? 2u : 1u); ++endpoint) {
    for (unsigned channel = 0; channel < 3; ++channel) {
      float value;
      std::memcpy(&value, rgb + endpoint * 16 + channel * 4, sizeof(value));
      if (!std::isfinite(value)) continue;
      value *= scale;
      std::memcpy(rgb + endpoint * 16 + channel * 4, &value, sizeof(value));
    }
  }
}

inline void ApplyCommon(void* output, const Controls& controls) {
  if (!output || !controls.enabled || !controls.match_world) return;
  float native;
  std::memcpy(&native, static_cast<unsigned char*>(output) + 0x470, sizeof(native));
  if (!std::isfinite(native) || native < 0.f) return;
  const float unified = 1.f;
  std::memcpy(static_cast<unsigned char*>(output) + 0x470, &unified, sizeof(unified));
}

}  // namespace witcher3graphics::player
