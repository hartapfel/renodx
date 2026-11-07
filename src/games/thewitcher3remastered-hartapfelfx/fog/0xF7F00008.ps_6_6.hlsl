// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Capture the native interior intervals while 8BDE805B has t24 bound.
#define FOG_INTEGRATE_ONLY
#include "grid.hlsli"
cbuffer NativeInteriorLight : register(b13) { float4 interior_light[3589]; }
Texture2D<float2> native_interiors : register(t24);
void main(float4 position : SV_Position) {
  uint2 id = uint2(position.xy);
  if (any(id >= dimensions.xy)) return;
  uint width, height;
  native_interiors.GetDimensions(width, height);
  float scale = interior_light[33].z;
  bool valid = width > 0 && height > 0 && isfinite(scale) && scale > 0.f
               && all(isfinite(fog_frame[23].xy)) && all(fog_frame[23].xy > 0.f);
  if (all(id == 0)) {
    volume.Store4(0, asuint(float4(valid ? scale : 0.f, 0, 0, 0)));
    volume.Store4(16, asuint(fog_frame[0]));
    volume.Store4(32, asuint(fog_frame[17]));
    volume.Store4(48, asuint(fog_frame[18]));
    volume.Store4(64, asuint(fog_frame[23]));
    volume.Store4(80, uint4(dimensions.xy, 0, 0));
    volume.Store4(96, asuint(fog_frame[286]));
  }
  float2 boundaries = 0.f;
  if (valid) {
    uint2 pixel = min(uint2((id + .5f) / dimensions.xy * fog_frame[23].xy * .5f), uint2(width, height) - 1);
    boundaries = native_interiors.Load(int3(pixel, 0)) * scale;
    if (any(!isfinite(boundaries)) || any(boundaries < 0.f)) boundaries = 0.f;
  }
  volume.Store2(128 + (id.y * dimensions.x + id.x) * 8, asuint(boundaries));
}
