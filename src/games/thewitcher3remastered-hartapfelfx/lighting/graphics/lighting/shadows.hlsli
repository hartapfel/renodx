// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_REMASTERED_GRAPHICS_SHADOWS
#define WITCHER_REMASTERED_GRAPHICS_SHADOWS
#include "../reference/classic/lighting/shadow_disk.hlsli"

bool ImprovedSoftShadows() {
  return graphics_injection.layout_version == 1.f && graphics_injection.graphics_mode != 0.f
      && graphics_injection.soft_shadows != 0.f;
}

// Native Remastered 4A7A44D6: the CSM block starts one float4 earlier than
// Classic. Keep material radius/gradient and the native comparison sampler.
float GraphicsFilterCascade(float3 position, uint cascade, bool vegetation) {
  uint width, height, layers;
  t8.GetDimensions(width, height, layers);
  if (width == 0 || height == 0 || cascade >= layers) return 1.f;
  float2 texel = rcp(float2(width, height));
  float scale = cb13_raw[10 + cascade].z;
  float2 uv = position.xy * scale * float2(1, -1) + cb13_raw[10 + cascade].xy;
  float native_radius = max(0.f, vegetation ? cb13_raw[18 + cascade].x : cb13_raw[10 + cascade].w);
  float gradient = vegetation ? max(0.f, cb13_raw[18 + cascade].y) : 0.f;
  float minimum_radius = max(max(texel.x, texel.y), native_radius * .5f);
  float depth_scale = length(float3(cb13_raw[3].z, cb13_raw[4].z, cb13_raw[5].z));
  float xy_scale = length(float3(cb13_raw[3].x, cb13_raw[4].x, cb13_raw[5].x)) * abs(scale);
  float cone = tan(clamp(graphics_injection.sun_diameter, .01f, 2.f) * .00872664626f);
  float search_radius = min(16.f * minimum_radius, max(minimum_radius, 20.f * cone * xy_scale));
  float center_depth = t8.Load(int4(int2(clamp(uv, .5f * texel, 1.f - .5f * texel) * float2(width, height)), cascade, 0));
  float separation = max(0.f, position.z - center_depth);
  float blockers = separation > 2.f / 16777216.f ? 1.f : 0.f;
  separation *= blockers;
  [unroll] for (uint i = 0; i < 16; ++i) {
    float2 sample_uv = clamp(uv + ShadowDisk(i, 16) * search_radius, .5f * texel, 1.f - .5f * texel);
    float4 delta = position.z - t8.GatherRed(s10, float3(sample_uv, cascade));
    float4 blocked = delta > 2.f / 16777216.f;
    separation += dot(max(delta, 0.f), blocked);
    blockers += dot(blocked, 1.f);
  }
  if (blockers == 0.f) return 1.f;
  // Orthographic directional separation; a perspective depth ratio would
  // change softness with the shadow camera's arbitrary origin.
  float radius = clamp(separation / blockers / max(depth_scale, 1.e-8f) * cone * xy_scale,
      minimum_radius, max(minimum_radius, 16.f * max(texel.x, texel.y)));
  float visibility = 0.f;
  [unroll] for (uint i = 0; i < 16; ++i) {
    float receiver = position.z - 2.f / 16777216.f - gradient * (16.f / 27.f) * float(i) / 16.f;
    visibility += t8.SampleCmpLevelZero(s9,
        float3(clamp(uv + ShadowDisk(i, 16) * radius, .5f * texel, 1.f - .5f * texel), cascade), receiver);
  }
  return visibility / 16.f;
}

float GraphicsDirectionalVisibility(float3 world, bool vegetation) {
  float3 position = world.x * cb13_raw[3].xyz + world.y * cb13_raw[4].xyz
      + world.z * cb13_raw[5].xyz + cb13_raw[6].xyz;
  uint count = (uint)clamp(cb13_raw[14].z, 0.f, 4.f);
  if (count == 0 || abs(position.z) >= .999f) return 1.f;
  float4 distance = max(abs(position.x - cb13_raw[7]), abs(position.y - cb13_raw[8]));
  uint cascade = count;
  [unroll] for (uint i = 0; i < 4; ++i) {
    if (i < count && distance[i] < cb13_raw[9][i]) { cascade = i; break; }
  }
  if (cascade == count) return 1.f;
  float visibility = GraphicsFilterCascade(position, cascade, vegetation);
  float blend = saturate((distance[cascade] / max(cb13_raw[9][cascade], 1.e-8f)
      - (1.f - cb13_raw[16][cascade])) / max(cb13_raw[16][cascade], 1.e-5f));
  if (blend > 0.f) visibility = lerp(visibility, cascade + 1 < count
      ? GraphicsFilterCascade(position, cascade + 1, vegetation) : 1.f, blend);
  return visibility;
}
#endif
