// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "math.hlsli"
#include "interior.hlsli"
cbuffer Frame : register(b0) { float4 frame[269]; }
cbuffer Lighting : register(b1) { float4 light[3323]; }
cbuffer Parameters : register(b2) {
  float4 grid;        // width, height, slices, far distance
  float4 medium;      // density multiplier, start, sun strength, anisotropy
  float4 options;     // height falloff, near distance, cloud available, terrain available
  float4 sampling;    // inverse render width/height, shadow quality, reserved
}
Texture2DArray<float> shadows : register(t0);
Texture2DArray<float> clouds : register(t1);
Texture2DArray<float> terrain : register(t2);
Texture2D<float2> interiors : register(t3);
SamplerComparisonState shadow_sampler : register(s0);
SamplerState wrap_sampler : register(s1);
SamplerState clamp_sampler : register(s2);
RWTexture3D<float4> cells : register(u0);
RWStructuredBuffer<float4> sample_parameters : register(u1);

// Classic's cascades share one world-to-light matrix. cb13[8:10] select
// bounds; [11:14] map those bounds to each array slice. See native 5CC0DB95.
float CascadeShadow(float3 world, float footprint) {
  float3 p = world.x * light[4].xyz + world.y * light[5].xyz
           + world.z * light[6].xyz + light[7].xyz;
  uint count = min((uint)light[15].z, 4u);
  if (abs(p.z) >= .999f || count == 0) return 1.f;
  float4 bounds = max(abs(p.x - light[8]), abs(p.y - light[9]));
  uint cascade = count;
  [unroll] for (uint i = 0; i < 4; ++i) {
    if (i < count && bounds[i] < light[10][i]) { cascade = i; break; }
  }
  if (cascade == count) return 1.f;
  float2 uv = p.xy * light[11 + cascade].zz * float2(1,-1) + light[11 + cascade].xy;
  // Filter over a froxel footprint instead of point-sampling a high-frequency
  // shadow map. Quality selects 4/9/16/25 hardware PCF taps over the same
  // footprint. Fixed positions avoid introducing temporal sampling noise.
  float radius = max(light[16].y, footprint * length(light[4].xy) * light[11+cascade].z * .35f);
  radius = min(radius, .025f);
  float visibility = 0.f;
  uint side = clamp((uint)round(max(sampling.z,1.f)),1u,4u) + 1u;
  [loop] for (uint y = 0; y < side; ++y)
    [loop] for (uint x = 0; x < side; ++x)
      visibility += shadows.SampleCmpLevelZero(shadow_sampler,
          float3(uv + (float2(x,y) * (2.f / (side-1u)) - 1.f) * radius, cascade), p.z);
  visibility /= float(side * side);
  if (cascade + 1 == count) {
    float fade = saturate((bounds[cascade] / light[10][cascade] - (1.f-light[17][cascade])) / max(light[17][cascade], .0001f));
    visibility = lerp(visibility, 1.f, fade);
  }
  return visibility;
}
float TerrainShadow(float3 world) {
  if (options.w == 0.f) return 1.f;
  // Native terrain-height shadow distance, softness and fade (5CC0DB95).
  float distance = length(world.xy-frame[0].xy);
  if (distance >= light[36].y) return 1.f;
  float softness = min(1.f,light[36].x/max(1.f,light[37].z*distance));
  float fade = saturate((light[36].z+distance)*light[36].w);
  uint count = min(asuint(light[35].x), 5u);
  [loop] for (uint i=0; i<count; ++i) {
    float2 uv = (world.xy-light[39+i].xy)*light[39+i].zw;
    if (all(uv >= 0.f) && all(uv <= 1.f)) {
      float height = terrain.SampleLevel(clamp_sampler,float3(uv.x,1.f-uv.y,i),0) * light[38].x + light[38].y;
      float visibility = 1.f-saturate((height-world.z-.1f)*softness);
      return lerp(visibility,1.f,fade);
    }
  }
  return 1.f;
}
float CloudShadow(float3 world, float distance) {
  if (options.z == 0.f || frame[66].x <= 0.f || light[0].z <= .25f) return 1.f;
  float2 projection = world.xy - world.z * light[0].xy / light[0].z;
  float2 uv_near = (projection + frame[67].xy)*(.01f/frame[66].x);
  float2 uv_far = (projection + 20.f*frame[67].xy)*(.0005f/frame[66].x);
  float2 layer = trunc(frame[68].xy);
  float a = lerp(clouds.SampleLevel(wrap_sampler,float3(uv_near,layer.x),1), clouds.SampleLevel(wrap_sampler,float3(uv_near,layer.y),1),frame[66].w);
  float b = lerp(clouds.SampleLevel(wrap_sampler,float3(uv_far,layer.x),1), clouds.SampleLevel(wrap_sampler,float3(uv_far,layer.y),1),frame[66].w);
  return saturate(1.f-saturate((light[0].z-.25f)*10.f)*lerp(a,b,saturate((distance-100.f)/150.f)));
}
[numthreads(4,4,4)]
void main(uint3 id : SV_DispatchThreadID) {
  if (any(id >= (uint3)grid.xyz)) return;
  // Sparse clear-weather haze can accumulate over many kilometres. Retain the
  // local grid's minimum range, but cover the weather-authored far distance.
  float far_distance = max(grid.w, frame[42].z);
  if (all(id == 0)) {
    sample_parameters[0] = float4(grid.xyz, far_distance);
    sample_parameters[1] = medium;
    sample_parameters[2] = options;
    sample_parameters[3] = float4(sampling.xy, frame[21].zw);
  }
  float2 uv = (id.xy+.5f)/grid.xy;
  float2 ndc = uv * float2(2,-2)+float2(-1,1);
  float4 world_h = ndc.x*frame[17]+ndc.y*frame[18]+.5f*frame[19]+frame[20];
  float3 ray = normalize(world_h.xyz/world_h.w-frame[0].xyz);
  float distance = SliceDistance(id.z+.5f,grid.z,options.y,far_distance);
  float3 world = frame[0].xyz+ray*distance;
  // Weather-authored base density, ground height and vertical gradient. Unlike
  // the old 16-step linear-opacity product, extinction is integrated exponentially.
  float falloff = max(0.f,.5f*(frame[43].y+frame[43].z))*options.x;
  float extinction = max(0.f,frame[43].x)*medium.x * FogHeightDensity(world.z+frame[42].y,falloff);
  uint interior_width, interior_height;
  interiors.GetDimensions(interior_width, interior_height);
  if (interior_width > 0 && interior_height > 0 && light[34].z > 0.f
      && all(sampling.xy > 0.f)) {
    // t24 is a half-resolution pooled allocation. Use the active render extent,
    // not normalized allocation UVs (DLSS leaves the rest of the pool stale).
    uint2 pixel = min(uint2(uv / sampling.xy * .5f), uint2(interior_width, interior_height) - 1);
    float2 boundaries = interiors.Load(int3(pixel, 0)) * light[34].z;
    extinction *= FogExteriorFraction(boundaries,
        SliceDistance(id.z, grid.z, options.y, far_distance),
        SliceDistance(id.z + 1.f, grid.z, options.y, far_distance));
  }
  float start = max(medium.y,frame[22].z);
  extinction *= smoothstep(start,start+2.f,distance);
  float3 ambient = max(frame[40].xyz,0.f);
  float3 source = ambient;
  if (extinction > 0.f && medium.z > 0.f) {
    float footprint = distance * 2.f * max(frame[21].z/grid.x,frame[21].w/grid.y);
    float visibility = CascadeShadow(world,footprint)*TerrainShadow(world)*CloudShadow(world,distance);
    visibility *= FogLightTransmittance(world.z+frame[42].y,normalize(light[0].xyz).z,
        max(frame[43].x,0.f)*medium.x,falloff,grid.w);
    source += max(light[1].xyz,0.f)*PhaseHG(dot(ray,normalize(light[0].xyz)),medium.w)*visibility*medium.z;
  }
  // Albedo is one for the water droplets represented by the atmospheric fog.
  cells[id] = float4(min(source*extinction,60000.f),min(extinction,100.f));
}
