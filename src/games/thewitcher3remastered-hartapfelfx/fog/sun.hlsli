// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Native next-gen 806C62A8: common matrix rows 3..6, cascade bounds
// 7..9, transforms 10..13 and overlap widths 16. No surface visibility input.
#include "../clouds/shadow_inputs.hlsli"
float FogTerrainVisibility(float3 world, uint flags) {
  if ((flags & 1u) == 0) return 1.f;
  float distance = length(world.xy - fog_frame[0].xy);
  if (distance >= fog_light[35].x) return 1.f;
  uint count = min(asuint(fog_light[34].x), 5u);
  [loop] for (uint i = 0; i < count; ++i) {
    float2 relative = world.xy - fog_light[37 + i].xy;
    float2 uv = float2(dot(relative, fog_light[42 + i].xy), dot(relative, fog_light[42 + i].zw));
    if (all(uv > 0.f) && all(uv < 1.f)) {
      float height = fog_terrain.SampleLevel(fog_clamp_sampler, float3(uv, i), 0) * fog_light[35].w + fog_light[36].x;
      float softness = min(1.f, fog_light[34].z / max(1.f, fog_light[34].w * distance));
      float shadow = saturate((height - world.z - .1f) * softness);
      return 1.f - shadow * (1.f - saturate((distance + fog_light[35].y) * fog_light[35].z));
    }
  }
  return 1.f;
}
float FogCloudVisibility(float3 world, float distance, uint flags) {
  if (CloudShadowMatches(fog_frame[0].xyz, asuint(fog_frame[286]))) return HartapfelCloudShadow(world, 1.f);
  if ((flags & 2u) == 0 || fog_frame[66].x <= 0.f || fog_light[0].z <= .25f) return 1.f;
  float2 projected = world.xy - world.z * fog_light[0].xy / fog_light[0].z;
  float2 near_uv = (projected + fog_frame[67].xy) * (.01f / fog_frame[66].x);
  float2 far_uv = (projected + 20.f * fog_frame[67].xy) * (.0005f / fog_frame[66].x);
  float2 layers = trunc(fog_frame[68].xy);
  float near_cloud = lerp(fog_clouds.SampleLevel(fog_wrap_sampler, float3(near_uv, layers.x), 1).x,
                          fog_clouds.SampleLevel(fog_wrap_sampler, float3(near_uv, layers.y), 1).x, fog_frame[66].w);
  float far_cloud = lerp(fog_clouds.SampleLevel(fog_wrap_sampler, float3(far_uv, layers.x), 1).x,
                         fog_clouds.SampleLevel(fog_wrap_sampler, float3(far_uv, layers.y), 1).x, fog_frame[66].w);
  return saturate(1.f - saturate((fog_light[0].z - .25f) * 10.f) * lerp(near_cloud, far_cloud, saturate((distance - 100.f) / 150.f)));
}
float FogCascadeFilter(float3 p, uint cascade) {
  uint width, height, layers;
  fog_cascades.GetDimensions(width, height, layers);
  if (cascade >= layers || width == 0 || height == 0) return 1.f;
  float2 uv = p.xy * fog_light[10 + cascade].z * float2(1, -1) + fog_light[10 + cascade].xy;
  float2 texel = uv * float2(width, height) - .5f;
  int2 cell = int2(floor(texel));
  int2 limit = int2(width, height) - 1;
  float2 f = frac(texel);
  // Filter comparison results, not depths. Loads avoid borrowing native or HDR
  // samplers and do not require a new root-signature static sampler.
  float a = p.z <= fog_cascades.Load(int4(clamp(cell, 0, limit), cascade, 0));
  float b = p.z <= fog_cascades.Load(int4(clamp(cell + int2(1, 0), 0, limit), cascade, 0));
  float c = p.z <= fog_cascades.Load(int4(clamp(cell + int2(0, 1), 0, limit), cascade, 0));
  float d = p.z <= fog_cascades.Load(int4(clamp(cell + 1, 0, limit), cascade, 0));
  return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
}
float FogSunVisibility(float3 world) {
  float3 p = world.x * fog_light[3].xyz + world.y * fog_light[4].xyz
             + world.z * fog_light[5].xyz + fog_light[6].xyz;
  uint count = min((uint)max(fog_light[14].z, 0.f), 4u);
  if (abs(p.z) >= .999f || count == 0) return 1.f;
  float4 bounds = max(abs(p.x - fog_light[7]), abs(p.y - fog_light[8]));
  uint cascade = count;
  [unroll] for (uint i = 0; i < 4; ++i) {
    if (i < count && bounds[i] < fog_light[9][i]) {
      cascade = i;
      break;
    }
  }
  if (cascade == count) return 1.f;
  float visibility = FogCascadeFilter(p, cascade);
  float fade = saturate((bounds[cascade] / max(fog_light[9][cascade], 1.e-8f)
                         - (1.f - fog_light[16][cascade]))
                        / max(fog_light[16][cascade], .0001f));
  if (fade > 0.f) visibility = lerp(visibility, cascade + 1 < count ? FogCascadeFilter(p, cascade + 1) : 1.f, fade);
  return visibility;
}
