/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <d3d9.h>

#include <algorithm>
#include <array>
#include <span>
#include <vector>

namespace ac2::native_alpha {

// Native world materials clamp the completed lighting immediately before this
// fog sequence. Match the whole sequence, including register dataflow and the
// game's c16 fog color / c17 fog parameters. Shadow, normal, attenuation, fog
// weight, alpha and MRT clamps must not be mistaken for the final color ceiling.
inline std::vector<DWORD> UnclampMaterialLighting(std::span<const DWORD> input) {
  if (input.size() < 2 || input[0] != D3DPS_VERSION(3, 0)) return {};
  DWORD zero = 0;
  for (size_t offset = 1; offset < input.size();) {
    const DWORD instruction = input[offset];
    const DWORD opcode = instruction & D3DSI_OPCODE_MASK;
    if (opcode == D3DSIO_END) break;
    const size_t count = 1 + (opcode == D3DSIO_COMMENT ? (instruction & D3DSI_COMMENTSIZE_MASK) >> D3DSI_COMMENTSIZE_SHIFT : (instruction & D3DSI_INSTLENGTH_MASK) >> D3DSI_INSTLENGTH_SHIFT);
    if (count > input.size() - offset) return {};
    if (opcode != D3DSIO_COMMENT && (instruction & (D3DSHADER_INSTRUCTION_PREDICATED | D3DSI_COISSUE)) != 0) return {};
    if (opcode == D3DSIO_DEF && count == 6) {
      for (DWORD channel = 0; channel < 4; ++channel) {
        if ((input[offset + 2 + channel] & 0x7FFFFFFFu) == 0) {
          zero = 0xA0000000u | (input[offset + 1] & D3DSP_REGNUM_MASK) | (channel * 0x55u << D3DVS_SWIZZLE_SHIFT);
        }
      }
    }
    offset += count;
  }
  if (zero == 0) return {};

  std::vector<DWORD> output{input[0]};
  bool changed = false;
  for (size_t offset = 1; offset < input.size();) {
    const DWORD instruction = input[offset];
    const DWORD opcode = instruction & D3DSI_OPCODE_MASK;
    if (opcode == D3DSIO_END) {
      if (offset + 1 != input.size() || !changed) return {};
      output.push_back(instruction);
      return output;
    }
    const size_t count = 1 + (opcode == D3DSIO_COMMENT ? (instruction & D3DSI_COMMENTSIZE_MASK) >> D3DSI_COMMENTSIZE_SHIFT : (instruction & D3DSI_INSTLENGTH_MASK) >> D3DSI_INSTLENGTH_SHIFT);
    if (count > input.size() - offset) return {};
    const size_t start = output.size();
    output.insert(output.end(), input.begin() + offset, input.begin() + offset + count);
    const size_t fog = offset + count;
    if ((opcode == D3DSIO_MOV || opcode == D3DSIO_ADD || opcode == D3DSIO_MUL || opcode == D3DSIO_MAD)
        && count >= 3 && input.size() - fog >= 21
        && (input[offset + 1] & ~D3DSP_REGNUM_MASK) == 0x80170000u
        && (input[offset + 1] & D3DSP_REGNUM_MASK) < 32
        && (input[fog + 13] & ~D3DSP_REGNUM_MASK) == 0x80070000u
        && (input[fog + 13] & D3DSP_REGNUM_MASK) < 32) {
      const DWORD color = input[offset + 1] & D3DSP_REGNUM_MASK;
      const DWORD delta = input[fog + 13] & D3DSP_REGNUM_MASK;
      const std::array<DWORD, 21> expected = {
          0x03000002u, 0x80080000u | color, 0x80FF0000u | color, 0xA1000011u,  // distance - fog start
          0x03000005u, 0x80180000u | color, 0x80FF0000u | color, 0xA0550011u,  // saturate(distance * scale)
          0x03000005u, 0x80080000u | color, 0x80FF0000u | color, 0xA0AA0011u,  // fog strength
          0x03000002u, 0x80070000u | delta, 0x81E40000u | color, 0xA0E40010u,  // fog color - lighting
          0x04000004u, 0x80070800u, 0x80FF0000u | color, 0x80E40000u | delta, 0x80E40000u | color};
      if (std::equal(expected.begin(), expected.end(), input.begin() + fog)) {
        output[start + 1] &= ~D3DSPDM_SATURATE;
        // Keep the original black floor. Reuse a shader-defined zero, without
        // occupying any extra constant or temporary register (c52 is sunlight).
        output.insert(output.end(), {0x0300000Bu, 0x80070000u | color, 0x80E40000u | color, zero});
        changed = true;
      }
    }
    offset += count;
  }
  return {};
}

}  // namespace ac2::native_alpha
