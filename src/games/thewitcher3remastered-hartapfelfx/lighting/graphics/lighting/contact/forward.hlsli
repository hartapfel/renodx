// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Include after native cb12_raw/cb13_raw declarations. Retained caster data is
// private, current-frame data; forward textures are never treated as G-buffers.
#ifndef REMASTERED_FORWARD_CONTACT
#define REMASTERED_FORWARD_CONTACT
#include "sample.hlsli"
float GraphicsForwardContact(float3 world, float3 normal, float2 pixel, bool character) {
  if (graphics_injection.layout_version != 1.f || graphics_injection.graphics_mode == 0.f
      || graphics_injection.contact_shadows == 0.f) return 1.f;
  uint4 header = GraphicsContact.Load4(0);
  uint2 size = uint2(cb12_raw[23].xy);
  if (header.z != 1u || header.w != 2u || any(header.xy != size)
      || any(size == 0u) || any(size > 8192u) || any(pixel < 0.f) || any(pixel >= size)) return 1.f;
  uint metadata = 16u + size.x * size.y * 12u;
  // Reject other cameras and changed projection/jitter, even when their target
  // dimensions match. These loads are uniform across the draw.
  [unroll] for (uint row = 0; row <= 4u; ++row)
    if (any(GraphicsContact.Load4(metadata + row * 16u) != asuint(cb12_raw[row]))) return 1.f;
  [unroll] for (uint row = 13; row <= 16u; ++row)
    if (any(GraphicsContact.Load4(metadata + row * 16u) != asuint(cb12_raw[row]))) return 1.f;
  if (any(GraphicsContact.Load4(metadata + 341u * 16u) != asuint(cb13_raw[0]))) return 1.f;
  float3 view = world.x * cb12_raw[1].xyz + world.y * cb12_raw[2].xyz
      + world.z * cb12_raw[3].xyz + cb12_raw[4].xyz;
  float3 direction = cb13_raw[0].x * cb12_raw[1].xyz + cb13_raw[0].y * cb12_raw[2].xyz
      + cb13_raw[0].z * cb12_raw[3].xyz;
  float reach = graphics_injection.contact_length;
  if (!all(isfinite(view)) || !all(isfinite(direction)) || view.z <= .01f
      || !isfinite(reach) || reach <= 0.f) return 1.f;
  if (direction.z < 0.f) reach = min(reach, max(0.f, (view.z - .01f) / -direction.z));
  float3 end = view + direction * reach;
  float4 a = view.x * cb12_raw[13] + view.y * cb12_raw[14] + view.z * cb12_raw[15] + cb12_raw[16];
  float4 b = end.x * cb12_raw[13] + end.y * cb12_raw[14] + end.z * cb12_raw[15] + cb12_raw[16];
  if (!all(isfinite(a)) || !all(isfinite(b)) || a.w <= .01f || b.w <= .01f) return 1.f;
  float2 start = (a.xy / a.w * float2(.5f, -.5f) + .5f) * size;
  float2 finish = (b.xy / b.w * float2(.5f, -.5f) + .5f) * size;
  if (any(abs(start - pixel) > 2.f)) return 1.f;
  float extent = length((finish - start) / size);
  if (extent < 1.e-6f) return 1.f;
  float step_t = (6.f * size.y / (1920.f * size.x)) / extent;
  float noise = frac(52.9829189f * frac(dot(floor(pixel), float2(.06711056f, .00583715f))));
  float bias = .003f * (character ? .1f : .2f + .8f * (1.f - saturate(dot(normal, cb13_raw[0].xyz))));
  float visibility = 1.f;
  [unroll] for (uint i = 0; i < 16u; ++i) {
    float t = (float(i) + noise + .5f) * step_t;
    if (t > 1.f) break;
    float2 position = lerp(start, finish, t);
    if (any(position < 0.f) || any(position >= size)) break;
    if (all(int2(position) == int2(pixel))) continue;
    uint2 packed = GraphicsContact.Load2(16u + size.x * size.y * 4u
        + (uint(position.y) * size.x + uint(position.x)) * 8u);
    float depth = asfloat(packed.x);
    if (!isfinite(depth) || depth <= 0.f) continue;
    float z = rcp(lerp(rcp(view.z), rcp(end.z), t));
    float delta = z * (1.f - bias) - depth;
    float thickness = min(.04f + z * .008f, character ? .1f : 4.f);
    float hit = saturate(delta * 400.f) * saturate((thickness - delta) * 400.f)
        * float(packed.y & 255u) / 255.f;
    float edge = saturate(min(min(position.x, position.y), min(size.x-position.x, size.y-position.y)) / 8.f);
    visibility = min(visibility, 1.f - hit * edge * (1.f - smoothstep(.85f, 1.f, t)));
  }
  return visibility;
}
#endif
