/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <d3d9.h>

#include <algorithm>
#include <array>
#include <bit>
#include <span>
#include <vector>

namespace ac2::native_alpha {

// Soft particles reconstruct scene depth from s8/c0, bound the intersection
// fade, and carry it into opacity. Their pre-fog RGB clamp shapes an authored
// effect (white wind/smoke can have blue values above one), not surface lighting.
// Follow that scalar dependency instead of excluding every shader that reads
// depth, every transparent material, or a list of known particle hashes.
inline bool HasDepthFadedOpacity(std::span<const DWORD> input) {
  if (input.size() < 2 || input[0] != D3DPS_VERSION(3, 0)) return false;
  constexpr unsigned depth = 1, offset_depth = 2, reciprocal_depth = 4, distance = 8, fade = 16;
  constexpr DWORD type_mask = D3DSP_REGTYPE_MASK | D3DSP_REGTYPE_MASK2;
  std::array<std::array<unsigned, 4>, 32> dependencies = {};
  for (size_t offset = 1; offset < input.size();) {
    const DWORD instruction = input[offset];
    const DWORD opcode = instruction & D3DSI_OPCODE_MASK;
    if (opcode == D3DSIO_END) break;
    const size_t count = 1 + (opcode == D3DSIO_COMMENT ? (instruction & D3DSI_COMMENTSIZE_MASK) >> D3DSI_COMMENTSIZE_SHIFT
                                                     : (instruction & D3DSI_INSTLENGTH_MASK) >> D3DSI_INSTLENGTH_SHIFT);
    if (count > input.size() - offset) return false;
    const auto tokens = input.subspan(offset, count);
    offset += count;
    if (opcode == D3DSIO_COMMENT) continue;
    if ((instruction & (D3DSHADER_INSTRUCTION_PREDICATED | D3DSI_COISSUE)) != 0) return false;
    // c0 must be the game's projection parameters, not a shader literal.
    if (opcode == D3DSIO_DEF && count == 6 && (tokens[1] & D3DSP_REGNUM_MASK) == 0) return false;
    const bool alu = (opcode >= D3DSIO_MOV && opcode <= D3DSIO_LRP)
                     || opcode == D3DSIO_FRC || opcode == D3DSIO_POW || opcode == D3DSIO_ABS
                     || opcode == D3DSIO_NRM || opcode == D3DSIO_SINCOS || opcode == D3DSIO_CMP
                     || opcode == D3DSIO_DP2ADD || opcode == D3DSIO_DSX || opcode == D3DSIO_DSY;
    const bool texture = opcode == D3DSIO_TEX || opcode == D3DSIO_TEXLDD || opcode == D3DSIO_TEXLDL;
    if ((!alu && !texture) || count < 3) continue;
    const DWORD destination = tokens[1];
    if ((destination & D3DSHADER_ADDRESSMODE_MASK) != 0) return false;
    std::array<unsigned, 4> result = {};
    for (unsigned lane = 0; lane < 4; ++lane) {
      if ((destination & (D3DSP_WRITEMASK_0 << lane)) == 0) continue;
      std::array<unsigned, 3> sources = {};
      std::array<bool, 3> projection_z = {}, projection_w = {};
      for (size_t i = 2; i < count && i < 5 && !texture; ++i) {
        const DWORD source = tokens[i];
        if ((source & D3DSHADER_ADDRESSMODE_MASK) != 0) return false;
        const unsigned component = (source >> (16 + 2 * (opcode == D3DSIO_RCP ? 0 : lane))) & 3u;
        if ((source & type_mask) == 0 && (source & D3DSP_REGNUM_MASK) < dependencies.size()) {
          sources[i - 2] = dependencies[source & D3DSP_REGNUM_MASK][component];
        }
        if ((source & (type_mask | D3DSP_REGNUM_MASK | D3DSP_SRCMOD_MASK)) == 0x20000000u) {
          projection_z[i - 2] = component == 2;
          projection_w[i - 2] = component == 3;
        }
      }
      if (texture && count >= 4 && (tokens[3] & (type_mask | D3DSP_REGNUM_MASK)) == 0x20000808u && lane == 0) {
        result[lane] = depth;
      } else if (opcode == D3DSIO_MOV) {
        result[lane] = sources[0];
      } else if (opcode == D3DSIO_ADD
                 && ((sources[0] == depth && projection_z[1]) || (sources[1] == depth && projection_z[0]))) {
        result[lane] = offset_depth;
      } else if (opcode == D3DSIO_RCP && sources[0] == offset_depth) {
        result[lane] = reciprocal_depth;
      } else if (opcode == D3DSIO_MAD
                 && ((sources[0] == reciprocal_depth && projection_w[1]) || (sources[1] == reciprocal_depth && projection_w[0]))) {
        result[lane] = distance;
      } else if (opcode == D3DSIO_MUL && (destination & D3DSPDM_SATURATE) != 0
                 && (sources[0] == distance || sources[1] == distance)) {
        result[lane] = fade;
      } else if (opcode == D3DSIO_MUL || opcode == D3DSIO_MAD || opcode == D3DSIO_ADD || opcode == D3DSIO_LRP) {
        result[lane] = (sources[0] | sources[1] | sources[2]) & fade;
      }
      if ((destination & (type_mask | D3DSP_REGNUM_MASK)) == 0x00000800u && lane == 3 && result[lane] == fade) return true;
    }
    if ((destination & type_mask) == 0 && (destination & D3DSP_REGNUM_MASK) < dependencies.size()) {
      for (unsigned lane = 0; lane < 4; ++lane) {
        if ((destination & (D3DSP_WRITEMASK_0 << lane)) != 0) dependencies[destination & D3DSP_REGNUM_MASK][lane] = result[lane];
      }
    }
  }
  return false;
}

// Revelations composes distance and volume fog after its material color clamp.
// Prove that RGB survives the b3 branches untouched until (1 - opacity) * RGB
// + fog. Register allocation and RGB packing vary between material variants.
inline bool HasVolumeFogLightingTail(std::span<const DWORD> input, DWORD color,
                                    const std::array<DWORD, 224>& literal_ones) {
  unsigned blocks = 0, completed = 0, samples = 0, fog_constants = 0, else_blocks = 0;
  bool inside = false, saw_else = false;
  size_t previous = 0;
  constexpr DWORD register_mask = D3DSP_REGTYPE_MASK | D3DSP_REGTYPE_MASK2 | D3DSP_REGNUM_MASK;
  for (size_t offset = 0; offset < input.size() && offset < 256;) {
    const DWORD instruction = input[offset];
    const DWORD opcode = instruction & D3DSI_OPCODE_MASK;
    const size_t count = 1 + ((instruction & D3DSI_INSTLENGTH_MASK) >> D3DSI_INSTLENGTH_SHIFT);
    if (count > input.size() - offset) return false;
    if (opcode == D3DSIO_IF) {
      if (inside || blocks >= 3 || count != 2 || input[offset + 1] != 0xE0E40803u) return false;
      inside = true;
      saw_else = false;
      ++blocks;
    } else if (opcode == D3DSIO_ELSE) {
      if (!inside || saw_else || count != 1) return false;
      saw_else = true;
      ++else_blocks;
    } else if (opcode == D3DSIO_ENDIF) {
      if (!inside || count != 1) return false;
      inside = false;
      if (++completed >= 2 && !saw_else) {
        if (else_blocks != completed - 1 || samples != 2 || fog_constants < 3
            || input[previous] != 0x04000004u || input.size() - offset < 10) return false;
        const DWORD opacity = input[previous + 1];
        const DWORD opacity_mask = (opacity & D3DSP_WRITEMASK_ALL) >> 16;
        if ((opacity & ~(D3DSP_REGNUM_MASK | D3DSP_WRITEMASK_ALL)) != 0x80100000u
            || opacity_mask == 0 || (opacity_mask & (opacity_mask - 1)) != 0) return false;
        DWORD channel = 0;
        while ((opacity_mask & (1u << channel)) == 0) ++channel;
        const DWORD opacity_source = 0x81000000u | (opacity & D3DSP_REGNUM_MASK) | (channel * 0x55u << 16);
        // The last fog instruction bounds opacity; the next subtracts it from 1.
        const auto tail = input.subspan(offset + 1);
        if (input[previous + 3] != opacity_source || tail[0] != 0x03000002u || tail[2] != opacity_source
            || tail[4] != 0x04000004u) return false;
        const DWORD weight = tail[1];
        const DWORD weight_mask = (weight & D3DSP_WRITEMASK_ALL) >> 16;
        if ((weight & ~(D3DSP_REGNUM_MASK | D3DSP_WRITEMASK_ALL)) != 0x80000000u
            || weight_mask == 0 || (weight_mask & (weight_mask - 1)) != 0
            || ((weight & register_mask) == color && (weight_mask & 7u) != 0)) return false;
        channel = 0;
        while ((weight_mask & (1u << channel)) == 0) ++channel;
        const DWORD one = tail[3];
        if ((one & (D3DSP_REGTYPE_MASK | D3DSP_REGTYPE_MASK2 | D3DSP_SRCMOD_MASK | D3DSHADER_ADDRESSMODE_MASK)) != 0x20000000u
            || (one & D3DSP_REGNUM_MASK) >= literal_ones.size()
            || (literal_ones[one & D3DSP_REGNUM_MASK] & (1u << ((one >> (16 + 2 * channel)) & 3u))) == 0
            || tail[6] != (0x80000000u | (weight & D3DSP_REGNUM_MASK) | (channel * 0x55u << 16))
            || (tail[7] & (register_mask | D3DSP_SRCMOD_MASK | D3DSHADER_ADDRESSMODE_MASK)) != color
            || (tail[8] & D3DSHADER_ADDRESSMODE_MASK) != 0
            || (tail[5] & ~(D3DSP_REGNUM_MASK | D3DSP_WRITEMASK_ALL)) != 0x80000000u) return false;
        // The fog MAD must consume all three lighting channels in order.
        unsigned component = 0;
        for (unsigned lane = 0; lane < 4; ++lane) {
          if ((tail[5] & (D3DSP_WRITEMASK_0 << lane)) == 0) continue;
          if (((tail[7] >> (16 + 2 * lane)) & 3u) != component++
              || ((tail[8] & register_mask) == color && ((tail[8] >> (16 + 2 * lane)) & 3u) != 3u)) return false;
        }
        return component == 3;
      }
    } else {
      if (blocks == 0) return false;
      // These are the audited fog arithmetic/sample operations, each with a
      // destination followed by sources. Reject other control flow and layouts.
      if (opcode != D3DSIO_MOV && opcode != D3DSIO_ADD && opcode != D3DSIO_MUL
          && opcode != D3DSIO_MAD && opcode != D3DSIO_MIN && opcode != D3DSIO_DP3
          && opcode != D3DSIO_TEX && opcode != D3DSIO_RCP && opcode != D3DSIO_RSQ) return false;
      if (count < 3 || ((input[offset + 1] & register_mask) == color
                       && (input[offset + 1] & 0x00070000u) != 0)) return false;
      if (opcode == D3DSIO_TEX) {
        if (count != 4 || input[offset + 3] != 0xA0E40807u) return false;
        ++samples;
      }
      for (size_t i = offset + 2; i < offset + count; ++i) {
        const DWORD token = input[i];
        if ((token & D3DSHADER_ADDRESSMODE_MASK) != 0) return false;
        if ((token & register_mask) == 0x200000C8u) ++fog_constants;  // c200 fog color
        if ((token & register_mask) != color) continue;
        const DWORD reads = opcode == D3DSIO_DP3 ? 7u
                            : opcode == D3DSIO_TEX ? 15u
                            : opcode == D3DSIO_RCP || opcode == D3DSIO_RSQ ? 1u
                                                  : (input[offset + 1] & D3DSP_WRITEMASK_ALL) >> 16;
        for (unsigned lane = 0; lane < 4; ++lane) {
          if ((reads & (1u << lane)) != 0 && ((token >> (16 + 2 * lane)) & 3u) != 3u) return false;
        }
      }
    }
    previous = offset;
    offset += count;
  }
  return false;
}

// Distance fog can be calculated before the completed lighting, in a separate
// scalar register, or by the vertex shader. Prove the final c16 fog blend and
// material depth output instead of depending on one register allocation.
inline bool HasDistanceFogLightingTail(std::span<const DWORD> input, DWORD color, DWORD color_mask) {
  constexpr DWORD register_mask = D3DSP_REGTYPE_MASK | D3DSP_REGTYPE_MASK2 | D3DSP_REGNUM_MASK;
  // Completed RGB may occupy xyz, yzw, xyw or xzw. Follow those three lanes
  // into output RGB; the unused fourth source swizzle has no effect.
  constexpr DWORD rgb_source_mask = ~0x00C00000u;
  DWORD color_source = 0x80000000u | color;
  std::array<unsigned, 3> color_lanes = {};
  unsigned output_component = 0;
  for (unsigned lane = 0; lane < 4; ++lane) {
    if ((color_mask & (1u << lane)) != 0) {
      color_lanes[output_component] = lane;
      color_source |= lane << (16 + 2 * output_component++);
    }
  }
  for (const size_t fog : {size_t{0}, size_t{12}}) {
    if (input.size() < fog + 16 || input[fog] != 0x03000002u
        || (input[fog + 1] & ~(D3DSP_REGNUM_MASK | D3DSP_WRITEMASK_ALL)) != 0x80000000u
        || std::popcount(input[fog + 1] & D3DSP_WRITEMASK_ALL) != 3
        || (input[fog + 1] & D3DSP_REGNUM_MASK) >= 32
        || input[fog + 4] != 0x04000004u || input[fog + 5] != 0x80070800u
        || (input[fog + 8] & rgb_source_mask) != color_source) continue;
    const DWORD delta = input[fog + 1] & D3DSP_REGNUM_MASK;
    const DWORD delta_mask = (input[fog + 1] & D3DSP_WRITEMASK_ALL) >> 16;
    DWORD delta_source = 0x80000000u | delta;
    DWORD subtract_source = 0x81000000u | color;
    DWORD fog_source = 0xA0000010u;
    DWORD used_source_mask = ~D3DVS_SWIZZLE_MASK;
    unsigned component_index = 0;
    for (unsigned lane = 0; lane < 4; ++lane) {
      if ((delta_mask & (1u << lane)) == 0) continue;
      delta_source |= lane << (16 + 2 * component_index);
      subtract_source |= color_lanes[component_index] << (16 + 2 * lane);
      fog_source |= component_index++ << (16 + 2 * lane);
      used_source_mask |= 3u << (16 + 2 * lane);
    }
    // The compiler may pack the fog delta independently of the material RGB.
    if (delta == color || (input[fog + 7] & rgb_source_mask) != delta_source
        || (input[fog + 2] & used_source_mask) != subtract_source
        || (input[fog + 3] & used_source_mask) != fog_source) continue;
    const DWORD weight = input[fog + 6];
    const DWORD component = (weight >> D3DVS_SWIZZLE_SHIFT) & 3u;
    const DWORD scalar_swizzle = component * 0x55u << D3DVS_SWIZZLE_SHIFT;
    const DWORD source_register = weight & register_mask;
    if (weight != (0x80000000u | source_register | scalar_swizzle)) continue;
    const bool temporary = source_register < 32;
    const bool interpolated = (source_register & ~D3DSP_REGNUM_MASK) == 0x10000000u
                              && (source_register & D3DSP_REGNUM_MASK) < 10;
    // Modified RGB and the fog delta must not double as the fog coefficient.
    if ((!temporary && !interpolated)
        || (temporary && ((source_register == color && (color_mask & (1u << component)) != 0)
                          || (source_register == delta && (delta_mask & (1u << component)) != 0)))) continue;
    if (fog != 0) {
      if (!temporary) continue;
      const DWORD destination = 0x80000000u | source_register | (D3DSP_WRITEMASK_0 << component);
      // Distance may arrive from a different scalar register. It must not
      // depend on any RGB lane whose saturation we are about to remove.
      const DWORD distance = input[2];
      const DWORD distance_register = distance & register_mask;
      const DWORD distance_component = (distance >> (16 + 2 * component)) & 3u;
      if ((distance & ~(register_mask | D3DVS_SWIZZLE_MASK)) != 0x80000000u
          || !(distance_register < 32 || ((distance_register & ~D3DSP_REGNUM_MASK) == 0x10000000u
                                         && (distance_register & D3DSP_REGNUM_MASK) < 10))
          || (distance_register == color && (color_mask & (1u << distance_component)) != 0)) continue;
      const std::array<DWORD, 12> expected = {
          0x03000002u, destination, distance, 0xA1000011u,  // distance - fog start
          0x03000005u, destination | D3DSPDM_SATURATE, weight, 0xA0550011u,
          0x03000005u, destination, weight, 0xA0AA0011u};
      if (!std::equal(expected.begin(), expected.end(), input.begin())) continue;
    }
    // All audited variants also write z/w to MRT1. This distinguishes the
    // material fog tail from unrelated color interpolation/postprocessing.
    const auto depth = input.subspan(fog + 9);
    if (depth[0] != 0x02000006u || depth[3] != 0x03000005u || depth[4] != 0x80070801u) continue;
    const DWORD depth_mask = (depth[1] & D3DSP_WRITEMASK_ALL) >> 16;
    if ((depth[1] & ~(D3DSP_REGNUM_MASK | D3DSP_WRITEMASK_ALL)) != 0x80000000u
        || (depth[1] & D3DSP_REGNUM_MASK) >= 32
        || depth_mask == 0 || (depth_mask & (depth_mask - 1)) != 0
        || (depth[2] & ~D3DSP_REGNUM_MASK) != 0x90FF0000u
        || (depth[2] & D3DSP_REGNUM_MASK) >= 10) continue;
    unsigned depth_component = 0;
    while ((depth_mask & (1u << depth_component)) == 0) ++depth_component;
    if (depth[5] != (0x80000000u | (depth[1] & D3DSP_REGNUM_MASK) | (depth_component * 0x55u << 16))
        || depth[6] != (0x90AA0000u | (depth[2] & D3DSP_REGNUM_MASK))) continue;
    return true;
  }
  return false;
}

// Native world materials clamp completed lighting before distance/volume fog.
// Match the fog sequence and register dataflow for Brotherhood or Revelations.
// Shadow, normal, attenuation, fog weight, alpha and MRT clamps must not be
// mistaken for the final color ceiling.
inline std::vector<DWORD> UnclampMaterialLighting(std::span<const DWORD> input) {
  if (input.size() < 2 || input[0] != D3DPS_VERSION(3, 0)) return {};
  if (HasDepthFadedOpacity(input)) return {};
  DWORD zero = 0;
  bool distance_fog_constants = true;
  std::array<DWORD, 224> literal_ones = {};
  for (size_t offset = 1; offset < input.size();) {
    const DWORD instruction = input[offset];
    const DWORD opcode = instruction & D3DSI_OPCODE_MASK;
    if (opcode == D3DSIO_END) break;
    const size_t count = 1 + (opcode == D3DSIO_COMMENT ? (instruction & D3DSI_COMMENTSIZE_MASK) >> D3DSI_COMMENTSIZE_SHIFT : (instruction & D3DSI_INSTLENGTH_MASK) >> D3DSI_INSTLENGTH_SHIFT);
    if (count > input.size() - offset) return {};
    if (opcode != D3DSIO_COMMENT && (instruction & (D3DSHADER_INSTRUCTION_PREDICATED | D3DSI_COISSUE)) != 0) return {};
    if (opcode == D3DSIO_DEF && count == 6) {
      if ((input[offset + 1] & D3DSP_REGNUM_MASK) == 16
          || (input[offset + 1] & D3DSP_REGNUM_MASK) == 17) distance_fog_constants = false;
      for (DWORD channel = 0; channel < 4; ++channel) {
        if ((input[offset + 1] & D3DSP_REGNUM_MASK) < literal_ones.size() && input[offset + 2 + channel] == 0x3F800000u) {
          literal_ones[input[offset + 1] & D3DSP_REGNUM_MASK] |= 1u << channel;
        }
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
        && count >= 3 && (input[offset + 1] & ~(D3DSP_REGNUM_MASK | D3DSP_WRITEMASK_ALL)) == 0x80100000u
        && std::popcount(input[offset + 1] & D3DSP_WRITEMASK_ALL) == 3
        && (input[offset + 1] & D3DSP_REGNUM_MASK) < 32) {
      const DWORD color = input[offset + 1] & D3DSP_REGNUM_MASK;
      const DWORD color_mask = (input[offset + 1] & D3DSP_WRITEMASK_ALL) >> 16;
      bool unclamp = color_mask == 7 && HasVolumeFogLightingTail(input.subspan(fog), color, literal_ones);
      if (!unclamp && distance_fog_constants) unclamp = HasDistanceFogLightingTail(input.subspan(fog), color, color_mask);
      if (unclamp) {
        output[start + 1] &= ~D3DSPDM_SATURATE;
        // Keep the original black floor. Reuse a shader-defined zero, without
        // occupying any extra constant or temporary register (c52 is sunlight).
        output.insert(output.end(), {0x0300000Bu, 0x80000000u | (color_mask << 16) | color, 0x80E40000u | color, zero});
        changed = true;
      }
    }
    offset += count;
  }
  return {};
}

}  // namespace ac2::native_alpha
