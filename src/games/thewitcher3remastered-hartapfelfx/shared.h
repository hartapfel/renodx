// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFELFX_SHARED_H
#define HARTAPFELFX_SHARED_H
#define FOG_HEADER_BYTES 1024u
#define FOG_FRAME_VALID 0xF7F00002u
#define FOG_HISTORY_VALID 0xF7F00004u
struct ShaderInjectData {
  float enabled;
  float density;
  float sunlight;
  float anisotropy;
  float start_distance;
  float height_falloff;
  float quality;
  float local_strength;
  float sky_density;
  float reconstruction;
  float reserved0;
  float reserved1;
};
#ifndef __cplusplus
cbuffer HartapfelFX : register(b0, space70) { ShaderInjectData fx; }
#endif
#endif
