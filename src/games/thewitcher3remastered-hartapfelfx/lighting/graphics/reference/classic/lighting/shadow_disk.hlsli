// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_SHADOW_DISK
#define WITCHER_SHADOW_DISK
float2 ShadowDisk(uint i, uint count) {
  // Fixed Vogel disk directions; no trigonometry in the per-pixel tap loops.
  static const float2 disk[32] = {
    float2(0.125000000f, 0.000000000f),
    float2(-0.159645045f, 0.146247939f),
    float2(0.024436233f, -0.278438271f),
    float2(0.201222239f, 0.262458779f),
    float2(-0.369267557f, -0.065318231f),
    float2(0.349802466f, -0.222515696f),
    float2(-0.117002079f, 0.435241902f),
    float2(-0.223135654f, -0.429634123f),
    float2(0.484115115f, 0.176798064f),
    float2(-0.503641109f, 0.207895728f),
    float2(0.242788294f, -0.518824483f),
    float2(0.179414374f, 0.572001296f),
    float2(-0.540757006f, -0.313379738f),
    float2(0.634369523f, -0.139464360f),
    float2(-0.387145845f, 0.550675126f),
    float2(-0.089439655f, -0.690199644f),
    float2(0.549071757f, 0.462758258f),
    float2(-0.738878471f, 0.030554945f),
    float2(0.538955125f, -0.536332334f),
    float2(-0.036058186f, 0.779791515f),
    float2(-0.512817532f, -0.614526793f),
    float2(0.812359593f, 0.109301834f),
    float2(-0.688310641f, 0.478908616f),
    float2(0.188086057f, -0.836061382f),
    float2(0.435033266f, 0.759191055f),
    float2(-0.850448410f, -0.271316239f),
    float2(0.826102401f, -0.381680263f),
    float2(-0.357888202f, 0.855155562f),
    float2(-0.319407334f, -0.888033758f),
    float2(0.849908635f, 0.446688159f),
    float2(-0.944034646f, 0.248844503f),
    float2(0.536595808f, -0.834529771f)
  };
  return disk[i] * sqrt(32.f / float(count));
}
#endif
