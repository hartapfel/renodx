// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_RAY_HIT_MATERIAL
#define WITCHER_GRAPHICS_RAY_HIT_MATERIAL
#include "hit_layout.h"

// Four float4 rows of the producer's roughness curve precede one 16-byte record
// per RTGBuffer pixel: packed reflectance, payload flags /
// roughness, native stored hit distance, and recording epoch. Epoch zero is
// invalid. The owner must bind the complete allocation and match the producer's
// RTGBuffer resource, dimensions and recording when publishing it to consumers.
static const uint GRAPHICS_HIT_MATERIAL_MAGIC = 0x57334D41u;
static const uint GRAPHICS_HIT_MATERIAL_STRIDE = W3_HIT_STRIDE;

bool GraphicsHitMaterialAddress(uint4 context, uint2 pixel, out uint address) {
  address = 0;
  if (context.x != GRAPHICS_HIT_MATERIAL_MAGIC || context.w == 0
      || any(context.yz == 0) || any(context.yz > 16384u) || any(pixel >= context.yz)) return false;
  if (context.y * context.z > W3_HIT_MAX_PIXELS) return false;
  address = W3_HIT_HEADER_BYTES + (pixel.y * context.y + pixel.x) * GRAPHICS_HIT_MATERIAL_STRIDE;
  return true;
}

bool GraphicsReadHitMaterial(ByteAddressBuffer source, uint4 context, uint2 pixel,
    float native_distance, out uint2 material) {
  material = 0;
  uint address;
  if (!GraphicsHitMaterialAddress(context, pixel, address) || !isfinite(native_distance) || native_distance < 0.f) return false;
  uint4 record = source.Load4(address);
  float distance = asfloat(record.z);
  // Native targets may store FP16 distance. Do not confuse a new hit with a
  // preceding sparse-dispatch entry, even within the same recording.
  if (record.w != context.w || !isfinite(distance) || distance < 0.f
      || abs(distance - native_distance) > max(.001f, abs(distance) * .001f)) return false;
  material = record.xy;
  return true;
}

// GbufferPayload.data.z stores gamma-2.2 RGB reflectance in its low 24 bits;
// the separate fifth payload word stores roughness in bits 24..31. Bit 17
// identifies ClosestHitHair, whose native lobe must remain a separate adapter.
float4 GraphicsDecodeHitMaterial(uint2 packed) {
  float3 reflectance = float3(packed.x & 255u, (packed.x >> 8u) & 255u, (packed.x >> 16u) & 255u) / 255.f;
  return float4(pow(reflectance, 2.2f), float(packed.y >> 24u) / 255.f);
}

// Preserve the native CameraCB c4..c7 roughness remap used by ordinary PT hit
// materials. These are rows of the DXR b0/space1 buffer, NOT the reflection
// lighting pass's b14 buffer (whose c4..c7 contain a matrix). A consumer must
// receive the producer's curve values explicitly. Hair bypasses this remap.
float GraphicsHitRoughness(float roughness, uint flags, float4 curve0, float4 curve1, float4 curve2, float4 curve3) {
  if ((flags & (1u << 17u)) != 0) return roughness;
  uint segment = roughness < curve0.w ? 0u : roughness < curve1.w ? 1u : 2u;
  float mapped = dot(float4(curve0[segment], curve1[segment], curve2[segment], curve3[segment]),
      float4(roughness * roughness * roughness, roughness * roughness, roughness, 1.f));
  float edge = saturate(pow(abs(2.f * mapped - 1.f), 10.f));
  return pow(saturate(mapped) + edge * (float(mapped > .5f) - saturate(mapped)), curve2.w);
}

// Call only after GraphicsReadHitMaterial admitted this field's current record.
float GraphicsHitRoughness(ByteAddressBuffer source, float roughness, uint flags) {
  float4 curve0 = asfloat(source.Load4(0)), curve1 = asfloat(source.Load4(16));
  float4 curve2 = asfloat(source.Load4(32)), curve3 = asfloat(source.Load4(48));
  if (!all(isfinite(curve0)) || !all(isfinite(curve1)) || !all(isfinite(curve2)) || !all(isfinite(curve3))
      || curve2.w <= 0.f)
    return asfloat(0x7fc00000u);
  return GraphicsHitRoughness(roughness, flags, curve0, curve1, curve2, curve3);
}
#endif
