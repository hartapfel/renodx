/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <array>
#include <span>
#include <embed/shaders.h>

namespace witcher3classic::temporal {
struct ObjectShader {
  uint32_t hash;
  std::span<const uint8_t> code;
  uint32_t signature;
  bool reference = false;
  bool deformed = false;
  bool rigid = false;
  bool forward = false;
  bool direct = false;
  // Required previous foliage CBs: b0, b1, b2, b3, b11, b12 (bits 0..5).
  uint32_t foliage = 0;
};
// Signature groups retain the native varying/register layout. The two group-6
// material families differ in TEXCOORD5's width and are kept separate (6/7).
inline const auto OBJECT_VERTEX_SHADERS = [] {
  auto shaders = std::array{
    ObjectShader{0xF507139A, __0xF507139A, 4},
    ObjectShader{0xC3168D61, __0xC3168D61, 4},
    ObjectShader{0xE4756453, __0xE4756453, 4, true},
    ObjectShader{0x327CBAFA, __0x327CBAFA, 5},
    ObjectShader{0xB7D718E2, __0xB7D718E2, 5},
    ObjectShader{0x76365CDC, __0x76365CDC, 5, true},
    ObjectShader{0x64BD97C5, __0x64BD97C5, 2},
    ObjectShader{0x9BA913EE, __0x9BA913EE, 6},
    ObjectShader{0xF98C7327, __0xF98C7327, 7},
    ObjectShader{0xFCE8C0B4, __0xFCE8C0B4, 7, true},
    ObjectShader{0x4B58810D, __0x4B58810D, 4, false, true},
    ObjectShader{0x8AF8354B, __0x8AF8354B, 5, false, true},
    ObjectShader{0x27333F6F, __0x27333F6F, 8, false, true},
    ObjectShader{0x994B8494, __0x994B8494, 9, false, true},
    ObjectShader{0x95D8CC2E, __0x95D8CC2E, 6},
    ObjectShader{0xED64E04A, __0xED64E04A, 6, true},
    ObjectShader{0x4B5AEE17, __0x4B5AEE17, 10},
    ObjectShader{0x205794C4, __0x205794C4, 10},
    ObjectShader{0x8E6AB350, __0x8E6AB350, 10, true},
    ObjectShader{0x68D68CC2, __0x68D68CC2, 10, false, false, true},
    ObjectShader{0x465BBC10, __0x465BBC10, 13, false, false, true},
    ObjectShader{0x188F9E25, __0x188F9E25, 4, false, false, true},
    ObjectShader{0x9442ACB3, __0x9442ACB3, 4, false, false, true},
    ObjectShader{0x13698E6A, __0x13698E6A, 5, false, false, true},
    ObjectShader{0x22EAAEDA, __0x22EAAEDA, 5, false, false, true},
    ObjectShader{0x55E8F3AA, __0x55E8F3AA, 6, false, false, true},
    ObjectShader{0x2894D9E0, __0x2894D9E0, 6, false, false, true},
    ObjectShader{0xB0B4EB6F, __0xB0B4EB6F, 12, true, false, false, true},
    ObjectShader{0xD9A50A38, __0xD9A50A38, 11, true, false, false, true},
    ObjectShader{0xAB3E8304, __0xAB3E8304, 12, false, false, false, true},
    ObjectShader{0xFF64C197, __0xFF64C197, 11, false, false, false, true},
    ObjectShader{0x60265FBA, __0x60265FBA, 11, false, false, false, true, true},
    // Apex-deformed opaque tail hair; same persistent owner/UV history as cloth.
    ObjectShader{0x5CC0DB95, __0x5CC0DB95, 14, false, true, false, true},
    ObjectShader{0xAE216EAE, __0xAE216EAE, 14, false, true, false, true},
#include "./object_skin_families.inc"
#include "./object_forward_skin_families.inc"
    ObjectShader{0x1E1A9ECC, __0x1E1A9ECC, 20, false, false, false, false, false, 0x2D},
    ObjectShader{0x7EDF0F66, __0x7EDF0F66, 21, false, false, false, false, false, 0x2D},
    ObjectShader{0x934C6523, __0x934C6523, 21, false, false, false, false, false, 0x2D},
    ObjectShader{0x7DB7776C, __0x7DB7776C, 21, false, false, false, false, false, 0x2D},
    ObjectShader{0x3672ACC1, __0x3672ACC1, 22, false, false, false, false, false, 0x2F},
    ObjectShader{0x134AA93D, __0x134AA93D, 23, false, false, false, false, false, 0x3F},
  };
  std::ranges::sort(shaders, {}, &ObjectShader::hash);
  return shaders;
}();
inline const auto OBJECT_PIXEL_SHADERS = [] {
  auto shaders = std::array{
    ObjectShader{0x12B76681, __0x12B76681, 4, false, false, false, true},
    ObjectShader{0x8EEE67C3, __0x8EEE67C3, 4},
    ObjectShader{0x280BDA85, __0x280BDA85, 4},
    ObjectShader{0x704D8556, __0x704D8556, 4},
    ObjectShader{0xF8635C4B, __0xF8635C4B, 5},
    ObjectShader{0x5D696632, __0x5D696632, 5},
    ObjectShader{0x5DE5C7F3, __0x5DE5C7F3, 5},
    ObjectShader{0x628E4EBD, __0x628E4EBD, 5},
    ObjectShader{0x30873571, __0x30873571, 13},
    ObjectShader{0xB7B6FC64, __0xB7B6FC64, 2},
    ObjectShader{0xC624927C, __0xC624927C, 6},
    ObjectShader{0xE76C261A, __0xE76C261A, 6},
    ObjectShader{0x4C84BE3F, __0x4C84BE3F, 7},
    ObjectShader{0x7C391002, __0x7C391002, 8},
    ObjectShader{0xED00FAF7, __0xED00FAF7, 9},
    ObjectShader{0x9D1990B0, __0x9D1990B0, 10},
    ObjectShader{0x035DA93A, __0x035DA93A, 10},
    ObjectShader{0xC08941D9, __0xC08941D9, 10},
    ObjectShader{0xB18EC2FB, __0xB18EC2FB, 12},
    ObjectShader{0xEB8C3FAE, __0xEB8C3FAE, 11},
    ObjectShader{0x30F033B5, __0x30F033B5, 11},
    ObjectShader{0x20C1C070, __0x20C1C070, 11},
    ObjectShader{0x9B839F3B, __0x9B839F3B, 14, false, false, false, true},
#include "./object_material_families.inc"
#include "../blitzfx/object_materials.inc"
    ObjectShader{0x602B6AA4, __0x602B6AA4, 20},
    ObjectShader{0x03EAC234, __0x03EAC234, 21},
    ObjectShader{0xCEC6D9F4, __0xCEC6D9F4, 22},
    ObjectShader{0x5B57A747, __0x5B57A747, 23},
  };
  std::ranges::sort(shaders, {}, &ObjectShader::hash);
  return shaders;
}();

inline const ObjectShader* FindObjectShader(std::span<const ObjectShader> shaders, uint32_t hash) {
  const auto found = std::ranges::lower_bound(shaders, hash, {}, &ObjectShader::hash);
  return found != shaders.end() && found->hash == hash ? &*found : nullptr;
}
}  // namespace witcher3classic::temporal
