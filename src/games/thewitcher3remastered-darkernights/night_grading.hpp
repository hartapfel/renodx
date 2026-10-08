/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <algorithm>
#include <atomic>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <intrin.h>
#include <utility>

namespace witcher::night::grading {

inline float luminance_strength = 100.f, chroma_strength = 100.f;
inline float saturation_strength = 100.f;
inline std::atomic<float> luminance = 1.f, chroma = 1.f;
inline bool supported = false;
inline uintptr_t image_base = 0;
inline int32_t caller_rva_offset = 0;
using SetPixelConstants = void (*)(uint32_t, const float*, uint32_t);
inline SetPixelConstants set_pixel_constants = nullptr;

// Exact return addresses in the native post-processing builder. Logical slot
// 20 begins CustomPixelConsts: 29=c9, 31-33=c11-13, 34=c14, 35=c15.
// Other passes reuse these slots, so the register number alone is insufficient.
inline constexpr std::pair<uint32_t, uint32_t> grade_uploads[] = {
    {29, 0x34b775}, {31, 0x34bd61}, {32, 0x34bd75},
    {33, 0x34bd8a}, {34, 0x34bdd9}, {35, 0x34b7bf},
};

// Work on a fresh float4 copy. Native gamma, vignette, tonal selectors, LUT
// bindings and presentation constants remain untouched. This controls native
// curve/filter parameters, rather than replacing another addon's graded pixels.
inline bool AdjustConstants(uint32_t first, float* values, uintptr_t caller_rva,
                            float weight, float luminance_amount, float chroma_amount) {
  bool matched = false;
  for (const auto& [slot, caller] : grade_uploads) {
    if (first == slot && caller_rva == static_cast<uintptr_t>(int64_t(caller) + caller_rva_offset)) matched = true;
  }
  if (!matched || weight == 0.f || (luminance_amount == 1.f && chroma_amount == 1.f)) return false;
  for (unsigned i = 0; i < 4; ++i) if (!std::isfinite(values[i])) return false;
  const float l = 1.f + (luminance_amount - 1.f) * weight;
  const float c = 1.f + (chroma_amount - 1.f) * weight;
  if (first == 34 || first == 35) {
    const float neutral[] = {first == 34 ? 1.f : 0.f, first == 34 ? 0.f : 1.f, 1.f};
    for (unsigned i = 0; i < (first == 34 ? 3u : 2u); ++i) {
      values[i] = neutral[i] + (values[i] - neutral[i]) * l;
    }
    return true;
  }
  if (values[0] < 0.f || values[1] < 0.f || values[2] < 0.f) return false;
  // c9 multiplies gamma-encoded RGB; the three tonal tints multiply linear
  // RGB. Separate neutral brightness from chromatic tint in linear space.
  float linear[3];
  for (unsigned i = 0; i < 3; ++i) linear[i] = first == 29 ? std::pow(values[i], 2.2f) : values[i];
  const float y = linear[0] * 0.2126f + linear[1] * 0.7152f + linear[2] * 0.0722f;
  if (!std::isfinite(y) || y <= 0.f) return false;
  const float brightness = 1.f + (y - 1.f) * l;
  for (unsigned i = 0; i < 3; ++i) {
    const float result = brightness * (1.f + (linear[i] / y - 1.f) * c);
    values[i] = first == 29 ? std::pow(result, 1.f / 2.2f) : result;
  }
  if (first != 29) values[3] = 1.f + (values[3] - 1.f) * c;
  return true;
}

inline bool Validate(unsigned char* image, uint32_t constants_rva = 0x1ed9a30, int32_t caller_offset = 0) {
  constexpr unsigned char prefix[] = {
      0x48,0x89,0x5c,0x24,0x08,0x48,0x89,0x6c,0x24,0x10,
      0x48,0x89,0x74,0x24,0x18,0x48,0x89,0x7c,0x24,0x20};
  if (std::memcmp(image + constants_rva, prefix, sizeof(prefix))) return false;
  for (const auto& [slot, caller] : grade_uploads) {
    const uintptr_t upload_rva = static_cast<uintptr_t>(int64_t(caller) + caller_offset);
    int32_t displacement;
    std::memcpy(&displacement, image + upload_rva - 4, sizeof(displacement));
    if (image[upload_rva - 5] != 0xe8 || int64_t(upload_rva) + displacement != constants_rva) return false;
    // Confirm the caller's immediate slot assignment as well as its target.
    bool slot_found = false;
    for (unsigned offset = 5; offset <= 40; ++offset) {
      uint32_t value;
      std::memcpy(&value, image + upload_rva - offset + 1, sizeof(value));
      if (image[upload_rva - offset] == 0xb9 && value == slot) slot_found = true;
    }
    if (!slot_found) return false;
  }
  image_base = reinterpret_cast<uintptr_t>(image);
  caller_rva_offset = caller_offset;
  set_pixel_constants = reinterpret_cast<SetPixelConstants>(image + constants_rva);
  return true;
}
}  // namespace witcher::night::grading
