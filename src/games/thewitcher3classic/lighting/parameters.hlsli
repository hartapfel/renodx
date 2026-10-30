// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_CLASSIC_LIGHTING_PARAMETERS
#define WITCHER_CLASSIC_LIGHTING_PARAMETERS
// Separate from the native b12/b13 buffers and the HDR injection constants.
// An unbound view reads zero: all new features are then disabled.
StructuredBuffer<float4> RenoLighting : register(t118);
#define CUSTOM_BRDF (RenoLighting[0].x > .5f)
#define AMBIENT_ONLY_AO (RenoLighting[0].y > .5f)
#define CUSTOM_SHADOWS (RenoLighting[0].z > .5f)
#define CONTACT_LENGTH RenoLighting[0].w
float4 DecodeShadowAtlas(float packed) {
  // Native ubfe/and/ushr operate on the stored bits, not numeric float casts.
  uint bits=asuint(packed);
  return float4((bits>>20)&1023u,(bits>>10)&1023u,bits&1023u,bits>>30);
}
// Player fill is scaled at the native light-table producer, covering all
// native material, LOD, forward and compute paths without shader variants.
#endif
