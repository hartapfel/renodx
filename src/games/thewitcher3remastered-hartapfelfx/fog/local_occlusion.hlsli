// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Perspective-correct screen-space depth intervals: McGuire/Mara, JCGT 2014.
// Supplements native world shadows; hidden/offscreen geometry is unavailable here.
Texture2D<float> FogLocalDepth : register(t0);

float LocalViewDepth(float raw) {
  float normalized = raw * fog_frame[22].x + fog_frame[22].y;
  float reciprocal_depth = normalized * fog_frame[21].x + fog_frame[21].y;
  return isfinite(raw) && normalized < 1.f && reciprocal_depth > 1.e-7f ? rcp(reciprocal_depth) : 1.e30f;
}
float LocalOpaqueDistance(float2 uv, float3 ray) {
  uint width, height;
  FogLocalDepth.GetDimensions(width, height);
  uint2 size = min(uint2(width, height), uint2(fog_frame[23].xy));
  float view_z = ray.x * fog_frame[1].z + ray.y * fog_frame[2].z + ray.z * fog_frame[3].z;
  if (any(size == 0u) || any(uv < 0.f) || any(uv >= 1.f) || view_z <= 1.e-7f) return 1.e30f;
  float distance = LocalViewDepth(FogLocalDepth.Load(int3(min(uint2(uv * size), size - 1), 0))) / view_z;
  return min(distance, 1.e30f);
}

float LocalScreenVisibility(float3 world, float3 light_position, uint budget, float jitter) {
  if (budget == 0u) return 1.f;
  float3 view = world.x * fog_frame[1].xyz + world.y * fog_frame[2].xyz + world.z * fog_frame[3].xyz + fog_frame[4].xyz;
  float3 finish = light_position.x * fog_frame[1].xyz + light_position.y * fog_frame[2].xyz
                  + light_position.z * fog_frame[3].xyz + fog_frame[4].xyz;
  if (!all(isfinite(view)) || !all(isfinite(finish)) || view.z <= .01f) return 1.f;
  if (finish.z < .01f) finish = lerp(view, finish, (.01f - view.z) / (finish.z - view.z));
  float4 a = view.x * fog_frame[13] + view.y * fog_frame[14] + view.z * fog_frame[15] + fog_frame[16];
  float4 b = finish.x * fog_frame[13] + finish.y * fog_frame[14] + finish.z * fog_frame[15] + fog_frame[16];
  if (!all(isfinite(a)) || !all(isfinite(b)) || a.w <= 0.f || b.w <= 0.f) return 1.f;
  float2 start = a.xy / a.w * float2(.5f, -.5f) + .5f;
  float2 end = b.xy / b.w * float2(.5f, -.5f) + .5f;
  if (any(start < 0.f) || any(start >= 1.f)) return 1.f;
  uint width, height;
  FogLocalDepth.GetDimensions(width, height);
  uint2 size = min(uint2(width, height), uint2(fog_frame[23].xy));
  if (any(size == 0u)) return 1.f;
  float2 delta = end - start;
  float limit = 1.f;
  [unroll] for (uint axis = 0u; axis < 2u; ++axis) {
    if (delta[axis] > 1.e-7f) limit = min(limit, (1.f - start[axis]) / delta[axis]);
    else if (delta[axis] < -1.e-7f) limit = min(limit, -start[axis] / delta[axis]);
  }
  limit = saturate(limit);
  float extent = max(abs(delta.x) * size.x, abs(delta.y) * size.y) * limit;
  uint steps = min(budget, max(1u, uint(ceil(extent))));
  float previous = view.z;
  [loop] for (uint i = 0u; i < steps; ++i) {
    float t = (float(i) + clamp(jitter, .25f, .75f)) / float(steps) * limit;
    int2 pixel = clamp(int2((start + delta * t) * size), 0, int2(size) - 1);
    float raw = FogLocalDepth.Load(int3(pixel, 0));
    float next = rcp(lerp(rcp(view.z), rcp(finish.z), (float(i) + 1.f) / float(steps) * limit));
    float scene = LocalViewDepth(raw);
    float thickness = clamp(.03f + scene * .002f, .03f, .2f);
    // Test the traversed depth interval, not only isolated point samples.
    if (max(previous, next) >= scene + .002f && min(previous, next) <= scene + thickness) return 0.f;
    previous = next;
  }
  return 1.f;
}
