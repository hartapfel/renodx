/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <array>
#include <cstring>
#include <span>
#include <vector>
#include <d3d9.h>

namespace acbrotherhood::taa {

inline std::array<float, 2> Jitter(unsigned frame) {
  std::array<float, 2> result;
  for (unsigned dimension = 0; dimension < 2; ++dimension) {
    const unsigned base = dimension + 2;
    float fraction = 1.f;
    float value = 0.f;
    for (unsigned index = frame % 8 + 1; index != 0; index /= base) {
      fraction /= base;
      value += fraction * (index % base);
    }
    result[dimension] = value - 0.5f;
  }
  return result;
}

// Owned by the immediate render stream. A scene gets one immutable sample even
// if camera acquisition changes history validity partway through its draws.
// Present without a rendered scene does not consume a Halton phase.
struct JitterFrame {
  unsigned phase = 0, width = 0, height = 0;
  D3DMULTISAMPLE_TYPE samples = D3DMULTISAMPLE_NONE;
  std::array<float, 2> offset = {};
  bool latched = false, active = false, used = false, invalid = false;

  bool Latch(unsigned draw_width, unsigned draw_height, D3DMULTISAMPLE_TYPE draw_samples, bool enabled) {
    if (!latched) {
      latched = true;
      width = draw_width;
      height = draw_height;
      samples = draw_samples;
      active = enabled && width != 0 && height != 0;
      if (active) {
        offset = Jitter(phase);
        if (samples != D3DMULTISAMPLE_NONE) for (float& value : offset) value *= 0.5f;
      }
    } else if (width != draw_width || height != draw_height || samples != draw_samples) {
      invalid = true;
    }
    return active && !invalid;
  }

  void Complete(bool valid_scene) {
    const unsigned next_phase = phase + unsigned(valid_scene && used && !invalid);
    *this = {};
    phase = next_phase;
  }
};

// Accept only the compiler-authored constant-table contract audited in the
// Brotherhood dump (264/277 VS): g_WorldViewProj occupies float c0-c3.
// Unknown or stripped shaders are left alone, never guessed from register use.
inline bool HasProjection(std::span<const DWORD> code, bool* has_world = nullptr) {
  if (has_world) *has_world = false;
  if (code.size() < 2 || code[0] != D3DVS_VERSION(3, 0)) return false;
  bool projection = false, world = false, world_defined = false;
  for (size_t offset = 1; offset < code.size();) {
    const auto instruction = code[offset];
    const auto opcode = instruction & D3DSI_OPCODE_MASK;
    if (opcode == D3DSIO_END) {
      if (!projection || offset + 1 != code.size()) return false;
      if (has_world) *has_world = world && !world_defined;
      return true;
    }
    const size_t count = 1 + (opcode == D3DSIO_COMMENT ? (instruction & D3DSI_COMMENTSIZE_MASK) >> D3DSI_COMMENTSIZE_SHIFT
                                                                    : (instruction & D3DSI_INSTLENGTH_MASK) >> D3DSI_INSTLENGTH_SHIFT);
    if (count > code.size() - offset) return false;
    if (opcode == D3DSIO_DEF && count >= 2 && (code[offset + 1] & D3DSP_REGNUM_MASK) < 4) return false;
    if (opcode == D3DSIO_DEF && count >= 2 && (code[offset + 1] & D3DSP_REGNUM_MASK) >= 8
        && (code[offset + 1] & D3DSP_REGNUM_MASK) <= 10) world_defined = true;
    if (opcode == D3DSIO_COMMENT && count >= 9 && code[offset + 1] == 0x42415443u) {
      const auto* bytes = reinterpret_cast<const unsigned char*>(code.data() + offset + 2);
      const size_t size = (count - 2) * sizeof(DWORD);
      DWORD constants, table;
      std::memcpy(&constants, bytes + 12, 4);
      std::memcpy(&table, bytes + 16, 4);
      if (table > size || constants > (size - table) / 20) return false;
      for (DWORD i = 0; i < constants; ++i) {
        DWORD name;
        WORD info[3];
        std::memcpy(&name, bytes + table + 20 * i, 4);
        std::memcpy(info, bytes + table + 20 * i + 4, sizeof(info));
        constexpr char expected[] = "g_WorldViewProj";
        if (name <= size && sizeof(expected) <= size - name && info[0] == 2 && info[1] == 0 && info[2] == 4
            && std::memcmp(bytes + name, expected, sizeof(expected)) == 0) projection = true;
        constexpr char expected_world[] = "g_World";
        if (name <= size && sizeof(expected_world) <= size - name && info[0] == 2 && info[1] == 8
            && (info[2] == 3 || info[2] == 4)
            && std::memcmp(bytes + name, expected_world, sizeof(expected_world)) == 0) world = true;
      }
    }
    offset += count;
  }
  return false;
}
}  // namespace acbrotherhood::taa
