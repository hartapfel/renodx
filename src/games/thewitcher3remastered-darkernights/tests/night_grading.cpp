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
#include <fstream>
#include <iterator>
#include <vector>
#include <windows.h>

#include "../night_grading.hpp"

int main(int argc, char** argv) {
  using namespace witcher::night::grading;
  unsigned cases = 0;
  for (const auto& [slot, caller] : grade_uploads) {
    const std::array<float, 4> native = slot == 34 ? std::array{1.4f, -0.08f, 0.8f, 17.f}
                                      : slot == 35 ? std::array{0.02f, 0.96f, 19.f, 23.f}
                                                   : std::array{0.8f, 1.2f, 1.1f, 1.5f};
    for (float weight : {0.f, 0.25f, 0.5f, 1.f}) {
      for (float l : {0.f, 0.3f, 1.f}) for (float c : {0.f, 0.7f, 1.f}) {
        auto value = native;
        const bool changed = AdjustConstants(slot, value.data(), caller, weight, l, c);
        if (weight == 0.f || (l == 1.f && c == 1.f)) {
          assert(!changed && std::memcmp(value.data(), native.data(), sizeof(native)) == 0);
        } else {
          assert(changed);
          for (float channel : value) assert(std::isfinite(channel));
          if (slot == 34 || slot == 35) {
            auto other_chroma = native;
            assert(AdjustConstants(slot, other_chroma.data(), caller, weight, l, 0.4f));
            assert(value == other_chroma);
            if (weight == 1.f && l == 0.f) {
              assert(value[0] == (slot == 34 ? 1.f : 0.f));
              assert(value[1] == (slot == 34 ? 0.f : 1.f));
              if (slot == 34) assert(value[2] == 1.f);
            }
            assert(value[3] == native[3]);
            if (slot == 35) assert(value[2] == native[2]);
          } else {
            float y = 0.f, native_y = 0.f;
            constexpr float coefficients[] = {0.2126f, 0.7152f, 0.0722f};
            for (unsigned i = 0; i < 3; ++i) {
              y += coefficients[i] * (slot == 29 ? std::pow(value[i], 2.2f) : value[i]);
              native_y += coefficients[i] * (slot == 29 ? std::pow(native[i], 2.2f) : native[i]);
            }
            assert(std::abs(y - (1.f + (native_y - 1.f) * (1.f + (l - 1.f) * weight))) < 1e-5f);
            if (weight == 1.f && c == 0.f) assert(value[0] == value[1] && value[1] == value[2]);
            if (slot == 29) assert(value[3] == native[3]);
            else assert(std::abs(value[3] - (1.f + (native[3] - 1.f) * (1.f + (c - 1.f) * weight))) < 1e-6f);
          }
        }
        ++cases;
      }
    }
    for (auto bad_caller : {uintptr_t{0}, uintptr_t{caller - 1}, uintptr_t{caller + 1}}) {
      auto value = native;
      assert(!AdjustConstants(slot, value.data(), bad_caller, 1.f, 0.f, 0.f));
      assert(value == native);
      ++cases;
    }
    for (unsigned channel = 0; channel < 4; ++channel) {
      auto value = native;
      value[channel] = std::numeric_limits<float>::quiet_NaN();
      const auto original = value;
      assert(!AdjustConstants(slot, value.data(), caller, 1.f, 0.f, 0.f));
      assert(std::memcmp(value.data(), original.data(), sizeof(value)) == 0);
      ++cases;
    }
  }
  // Gamma, vignette, selectors and other passes' same-numbered slots are native.
  for (unsigned slot = 20; slot <= 44; ++slot) {
    auto value = std::array{0.5f, 2.2f, 0.4f, 0.8f};
    const auto original = value;
    assert(!AdjustConstants(slot, value.data(), 0x1c1ed39, 1.f, 0.f, 0.f));
    assert(value == original);
    ++cases;
  }
  std::printf("Passed %u native grading cases.\n", cases);
  if (argc == 2) {
    std::ifstream stream(argv[1], std::ios::binary);
    assert(stream);
    const std::vector<unsigned char> file{std::istreambuf_iterator<char>(stream), {}};
    const auto* dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(file.data());
    const auto* pe = reinterpret_cast<const IMAGE_NT_HEADERS64*>(file.data() + dos->e_lfanew);
    assert(pe->FileHeader.TimeDateStamp == 0x6abd8695 && pe->OptionalHeader.SizeOfImage == 0x63f8000);
    std::vector<unsigned char> image(pe->OptionalHeader.SizeOfImage);
    const auto* sections = IMAGE_FIRST_SECTION(pe);
    for (unsigned i = 0; i < pe->FileHeader.NumberOfSections; ++i) {
      std::memcpy(image.data() + sections[i].VirtualAddress,
                  file.data() + sections[i].PointerToRawData, sections[i].SizeOfRawData);
    }
    assert(Validate(image.data()));
    for (const auto& [slot, caller] : grade_uploads) {
      image[caller - 5] ^= 1;
      assert(!Validate(image.data()));
      image[caller - 5] ^= 1;
    }
    image[0x1ed9a30] ^= 1;
    assert(!Validate(image.data()));
    std::puts("Executable upload signatures and rejection guards passed.");
  }
}
