/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <d3d9.h>

#include <span>
#include <vector>

namespace ac2::native_alpha {

// Keep native SM3 arithmetic, constants and control flow intact. Only selected
// COLOR0 components receive saturation. Split mixed ALU writes into disjoint
// output writes. Texture writes use a proven unused temporary, since SM3 texture
// instructions cannot carry saturation. No game constant/register is overwritten.
inline std::vector<DWORD> SaturateOutput(std::span<const DWORD> input, DWORD mask) {
  if (input.size() < 2 || input[0] != D3DPS_VERSION(3, 0)
      || mask == 0 || (mask & ~D3DSP_WRITEMASK_ALL) != 0) return {};
  DWORD used_temps = 0;
  for (size_t offset = 1; offset < input.size();) {
    const DWORD opcode = input[offset] & D3DSI_OPCODE_MASK;
    if (opcode == D3DSIO_END) break;
    const size_t count = 1 + (opcode == D3DSIO_COMMENT ? (input[offset] & D3DSI_COMMENTSIZE_MASK) >> D3DSI_COMMENTSIZE_SHIFT : (input[offset] & D3DSI_INSTLENGTH_MASK) >> D3DSI_INSTLENGTH_SHIFT);
    if (count > input.size() - offset) return {};
    if (opcode != D3DSIO_COMMENT && opcode != D3DSIO_DEF && opcode != D3DSIO_DEFI && opcode != D3DSIO_DEFB) {
      for (size_t index = offset + 1; index < offset + count; ++index) {
        const DWORD token = input[index];
        const DWORD type = ((token & D3DSP_REGTYPE_MASK) >> D3DSP_REGTYPE_SHIFT)
                           | ((token & D3DSP_REGTYPE_MASK2) >> D3DSP_REGTYPE_SHIFT2);
        if ((token & 0x80000000u) != 0 && type == D3DSPR_TEMP && (token & D3DSP_REGNUM_MASK) < 32) {
          used_temps |= 1u << (token & D3DSP_REGNUM_MASK);
        }
      }
    }
    offset += count;
  }
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
    // Predicate operand layouts and legacy coissue need a separate audit.
    if (opcode != D3DSIO_COMMENT && (instruction & (D3DSHADER_INSTRUCTION_PREDICATED | D3DSI_COISSUE)) != 0) return {};
    const size_t start = output.size();
    output.insert(output.end(), input.begin() + offset, input.begin() + offset + count);

    // These SM3 instructions have a destination followed by sources.
    // Declarations, immediates and control instructions cannot be mistaken
    // for COLOR0 writes by inspecting arbitrary operands.
    const bool alu = (opcode >= D3DSIO_MOV && opcode <= D3DSIO_LRP)
                     || opcode == D3DSIO_FRC || opcode == D3DSIO_POW
                     || opcode == D3DSIO_ABS || opcode == D3DSIO_NRM
                     || opcode == D3DSIO_SINCOS || opcode == D3DSIO_CMP
                     || opcode == D3DSIO_DP2ADD || opcode == D3DSIO_DSX
                     || opcode == D3DSIO_DSY;
    const bool texture = opcode == D3DSIO_TEX || opcode == D3DSIO_TEXLDD || opcode == D3DSIO_TEXLDL;
    if ((alu || texture) && count >= 2) {
      const DWORD destination = input[offset + 1];
      const DWORD type = ((destination & D3DSP_REGTYPE_MASK) >> D3DSP_REGTYPE_SHIFT)
                         | ((destination & D3DSP_REGTYPE_MASK2) >> D3DSP_REGTYPE_SHIFT2);
      if (type == D3DSPR_COLOROUT && (destination & D3DSP_REGNUM_MASK) == 0
          && (destination & mask) != 0 && (destination & D3DSPDM_SATURATE) == 0) {
        if (texture) {
          DWORD temp = 0;
          while (temp < 32 && (used_temps & (1u << temp)) != 0) ++temp;
          if (temp == 32 || (destination & (D3DSP_DSTMOD_MASK | D3DSP_DSTSHIFT_MASK)) != 0) return {};
          output[start + 1] = (destination & ~(D3DSP_REGTYPE_MASK | D3DSP_REGTYPE_MASK2 | D3DSP_REGNUM_MASK)) | temp;
          constexpr DWORD mov = D3DSIO_MOV | (2u << D3DSI_INSTLENGTH_SHIFT);
          const DWORD source = 0x80000000u | D3DSP_NOSWIZZLE | temp;
          if ((destination & D3DSP_WRITEMASK_ALL & ~mask) != 0) {
            output.insert(output.end(), {mov, destination & ~mask, source});
          }
          output.insert(output.end(), {mov, (destination & ~D3DSP_WRITEMASK_ALL) | (destination & mask) | D3DSPDM_SATURATE, source});
        } else {
          if ((destination & D3DSP_WRITEMASK_ALL & ~mask) != 0) {
            output[start + 1] &= ~mask;
            output.insert(output.end(), input.begin() + offset, input.begin() + offset + count);
          }
          output[output.size() - count + 1] = (destination & ~D3DSP_WRITEMASK_ALL) | (destination & mask) | D3DSPDM_SATURATE;
        }
        changed = true;
      }
    }
    offset += count;
  }
  return {};
}

}  // namespace ac2::native_alpha
