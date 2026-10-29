// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "math.hlsli"
#include "interior.hlsli"
cbuffer Frame : register(b0) { float4 frame[269]; }
cbuffer Lighting : register(b1) { float4 light[3323]; }
cbuffer Parameters : register(b2) {
  float4 grid;        // width, height, slices, far distance
  float4 medium;      // density multiplier, start, sun strength, anisotropy
  float4 options;     // height falloff, near distance, cloud available, terrain available
  float4 sampling;    // inverse render width/height, shadow quality, local light strength
  float4 sky_options; // native sky-haze density multiplier, smooth lighting reconstruction, reserved
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
#include "local_lights.hlsli"

#include "sun_lighting.hlsli"
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
    sample_parameters[4] = frame[42];
    sample_parameters[5] = float4(frame[48].xyz,frame[22].z);
    sample_parameters[6] = frame[38];
    sample_parameters[7] = frame[39];
    sample_parameters[8] = frame[40];
    sample_parameters[9] = frame[41];
    sample_parameters[10] = frame[45];
    sample_parameters[11] = frame[46];
    sample_parameters[12] = frame[47];
    sample_parameters[13] = frame[188];
    sample_parameters[14] = frame[189];
    sample_parameters[15] = frame[190];
    sample_parameters[16] = frame[191];
    sample_parameters[17] = float4(frame[192].x,sky_options.x,frame[192].zw);
    // Camera-relative inverse-projection basis, before perspective division.
    sample_parameters[18] = float4(frame[17].xyz-frame[0].xyz*frame[17].w,0);
    sample_parameters[19] = float4(frame[18].xyz-frame[0].xyz*frame[18].w,0);
    sample_parameters[20] = float4(.5f*frame[19].xyz+frame[20].xyz
        -frame[0].xyz*(.5f*frame[19].w+frame[20].w),0);
    sample_parameters[21] = float4(sky_options.y,sky_options.z,sky_options.w,sampling.w);
  }
  float2 uv = (id.xy+.5f)/grid.xy;
  float2 ndc = uv * float2(2,-2)+float2(-1,1);
  float4 world_h = ndc.x*frame[17]+ndc.y*frame[18]+.5f*frame[19]+frame[20];
  float3 ray = normalize(world_h.xyz/world_h.w-frame[0].xyz);
  float distance = SliceDistance(id.z+.5f,grid.z,options.y,far_distance);
  float3 world = frame[0].xyz+ray*distance;
  // Weather-authored base density, ground height and vertical gradient. Unlike
  // the old 16-step linear-opacity product, extinction is integrated exponentially.
  float directional = saturate((frame[42].x+dot(ray,frame[38].xyz))/max(1.f+frame[42].x,.0001f));
  float falloff = max(0.f,lerp(frame[43].z,frame[43].y,directional))*options.x;
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
  // Keep direct scattering separate from weather ambient. Combining a dim
  // lamp with bright ambient before FP16 storage loses the lamp's precision;
  // subtracting that ambient later cannot recover it. Native weather color
  // is composed in sample.hlsli at full shader precision.
  float3 source = 0.f;
  if (extinction > 0.f && medium.z > 0.f && sky_options.z < .5f) {
    float3 relative = world_h.xyz-frame[0].xyz*world_h.w;
    float inverse_length = rsqrt(max(dot(relative,relative),1.e-12f));
    float3 x_basis = (frame[17].xyz-frame[0].xyz*frame[17].w)*(2.f/grid.x);
    float3 y_basis = (frame[18].xyz-frame[0].xyz*frame[18].w)*(-2.f/grid.y);
    float3 dx = (x_basis-ray*dot(ray,x_basis))*(distance*inverse_length);
    float3 dy = (y_basis-ray*dot(ray,y_basis))*(distance*inverse_length);
    float begin = SliceDistance(id.z,grid.z,options.y,far_distance);
    float end = SliceDistance(id.z+1.f,grid.z,options.y,far_distance);
    float3 center = frame[0].xyz+ray*((begin+end)*.5f);
    float visibility = CascadeShadow(center,dx,dy,ray*(end-begin))*TerrainShadow(world)*CloudShadow(world,distance);
    visibility *= FogLightTransmittance(world.z+frame[42].y,normalize(light[0].xyz).z,
        max(frame[43].x,0.f)*medium.x,falloff,grid.w);
    source += max(light[1].xyz,0.f)*PhaseHG(dot(ray,normalize(light[0].xyz)),medium.w)*visibility*medium.z;
  }
  if (extinction > 0.f && sampling.w > 0.f && sky_options.z < .5f)
    source += LocalScattering(uv,world,ray,falloff);
  // Albedo is one for the water droplets represented by the atmospheric fog.
  cells[id] = float4(min(source*extinction,60000.f),min(extinction,100.f));
}
