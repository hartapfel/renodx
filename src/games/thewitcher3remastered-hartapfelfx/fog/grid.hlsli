// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../shared.h"
#include "../water/light_layout.h"
#include "interior.hlsli"
#include "math.hlsli"
#ifdef FOG_RAY_LOCAL_PASS
cbuffer NativeFrame : register(b0, space61) { float4 fog_frame[341]; }
#else
cbuffer NativeFrame : register(b12) { float4 fog_frame[341]; }
#endif
#ifndef FOG_INTEGRATE_ONLY
#ifdef FOG_RAY_LOCAL_PASS
cbuffer NativeLight : register(b1, space61) { float4 fog_light[3589]; }
#else
cbuffer NativeLight : register(b13) { float4 fog_light[3589]; }
#endif
#ifndef FOG_LOCAL_PASS
Texture2DArray<float> fog_cascades : register(t8);
Texture2DArray<float4> fog_clouds : register(t14);
Texture2DArray<float> fog_terrain : register(t19);
SamplerState fog_wrap_sampler : register(s14);
SamplerState fog_clamp_sampler : register(s10);
#include "sun.hlsli"
#endif
#endif
#ifdef FOG_RAY_LOCAL_PASS
cbuffer Grid : register(b3, space61) {
#else
cbuffer Grid : register(b3, space71) {
#endif
  uint4 dimensions;
  uint4 sampling;
#ifdef FOG_RAY_LOCAL_PASS
  uint4 local_ray_identifier[2];
  uint4 local_ray_inputs;
#endif
}
#ifdef FOG_RAY_LOCAL_PASS
RWByteAddressBuffer volume : register(u0, space61);
#else
RWByteAddressBuffer volume : register(u0, space71);
#endif
ByteAddressBuffer FogFast : register(t2, space71);
ByteAddressBuffer history_volume : register(t1, space71);
float4 CapturedFrame(uint row) { return asfloat(volume.Load4(64 + row * 16)); }
float4 PreviousFrame(uint row) { return asfloat(history_volume.Load4(64 + row * 16)); }
bool IndependentLight() { return beam.version == FOG_LIGHT_VALID; }
bool LightEnabled() { return !IndependentLight() || beam.enabled > .5f; }
float LightDensity() { return IndependentLight() ? beam.density : fx.density; }
float LightHeight() { return IndependentLight() ? beam.height_falloff : fx.height_falloff; }
float LightStart() { return IndependentLight() ? beam.start_distance : fx.start_distance; }
float VolumeFarDistance() {
  return max(1000.f, fog_frame[42].z + max(fx.start_distance, fog_frame[22].z));
}
uint FogExtinctionOffset() {
  return FOG_HEADER_BYTES + dimensions.x * dimensions.y * (3u * dimensions.z + 1u) * 8u;
}
bool GridHistoryCompatible(float4 sun, float4 radiance) {
  if (IndependentLight() && (beam.temporal < .5f
      || any(asuint(float4(beam.enabled, beam.density, beam.start_distance, beam.height_falloff)) != history_volume.Load4(1024))
      || any(asuint(float4(beam.quality, beam.local_shadows, beam.temporal, asfloat(beam.version))) != history_volume.Load4(1040))
      || any(asuint(float2(beam.indoor, beam.occlusion_quality)) != history_volume.Load2(1056)))) return false;
  if (sampling.z == 0 || history_volume.Load(1008) != FOG_HISTORY_VALID) return false;
  float4 old_grid = asfloat(history_volume.Load4(0));
  float far_distance = VolumeFarDistance();
  if (any(old_grid.xyz != float3(dimensions.xyz)) || abs(old_grid.w - far_distance) > .02f * max(far_distance, .001f)) return false;
  if (length(fog_frame[0].xyz - PreviousFrame(0).xyz) >= 10.f) return false;
  if (any(abs(fog_frame[42] - PreviousFrame(42)) > .02f * max(abs(fog_frame[42]), .001f))
      || any(abs(fog_frame[43] - PreviousFrame(43)) > .02f * max(abs(fog_frame[43]), .001f))) return false;
  if (any(abs(fog_frame[48] - asfloat(history_volume.Load4(32))) > .02f * max(abs(fog_frame[48]), .001f))) return false;
  if (any(asuint(fog_frame[287]) != history_volume.Load4(864))) return false;
  if (any(abs(sun - asfloat(history_volume.Load4(832))) > .02f)
      || any(abs(radiance - asfloat(history_volume.Load4(848))) > .05f * max(abs(radiance), 1.e-5f))) return false;
  if (any(asuint(float4(fx.enabled, fx.density, fx.sunlight, fx.anisotropy)) != history_volume.Load4(880))
      || any(asuint(float4(fx.start_distance, fx.height_falloff, fx.quality, fx.local_strength)) != history_volume.Load4(896))) return false;
  if(asuint(fx.quality_preset)!=history_volume.Load(52))return false;
  return true;
}
float GridFastSample(uint2 pixel, uint dimension) {
  uint2 offset = uint2(frac(float(dimension) * float2(.754877666f, .569840296f)) * 128.f);
  uint2 coordinate = (pixel + offset) & 127u;
  uint index = ((sampling.y & 31u) * 128u + coordinate.y) * 128u + coordinate.x;
  uint packed = FogFast.Load(index & ~3u);
  return (float((packed >> ((index & 3u) * 8u)) & 255u) + .5f) / 256.f;
}
uint CellIndex(uint3 id) { return (id.z * dimensions.y + id.y) * dimensions.x + id.x; }
uint2 PackVolume(float4 value) {
  uint4 bits = f32tof16(value);
  return bits.xy | (bits.zw << 16);
}
float4 UnpackVolume(uint2 value) { return f16tof32(uint4(value & 65535u, value >> 16)); }
#if !defined(FOG_INTEGRATE_ONLY) && !defined(FOG_LOCAL_PASS)
void GenerateCell(uint3 id) {
  if (any(id >= dimensions.xyz)) return;
  if ((sampling.x & WATER_LIGHT_CAPTURE) != 0u) {
    const float3 origin = floor(fog_frame[0].xyz / WATER_LIGHT_CELL) * WATER_LIGHT_CELL;
    const float3 world = origin + (float3(id) + .5f - .5f * dimensions.xyz) * WATER_LIGHT_CELL;
    if (all(id == 0u)) {
      volume.Store4(0, uint4(WATER_LIGHT_VALID, asuint(origin)));
      volume.Store4(16, asuint(fog_frame[0]));
      volume.Store4(32, asuint(fog_frame[15]));
      volume.Store4(48, asuint(fog_frame[286]));
      volume.Store4(64, asuint(fog_light[0]));
      volume.Store4(80, asuint(fog_light[1]));
      volume.Store4(96, asuint(fog_frame[17]));
    }
    float distance = length(world - fog_frame[0].xyz);
    float visibility = FogSunVisibility(world) * FogTerrainVisibility(world, sampling.x)
                     * FogCloudVisibility(world, distance, sampling.x);
    volume.Store(WATER_LIGHT_HEADER + 4u * CellIndex(id), asuint(visibility));
    return;
  }
  if (all(id == 0)) {
    float far_distance = VolumeFarDistance();
    volume.Store4(0, asuint(float4(dimensions.xyz, far_distance)));
    volume.Store4(16, asuint(float4(fog_frame[23].zw, .1f, FOG_HEADER_BYTES + 2 * dimensions.x * dimensions.y * dimensions.z * 8)));
    volume.Store4(32, asuint(fog_frame[48]));
    volume.Store4(48,asuint(float4(fx.haze_reduction,fx.quality_preset,fx.reconstruction,0.f)));
    [unroll] for (uint row = 0; row < 48; ++row) volume.Store4(64 + row * 16, asuint(fog_frame[row]));
    volume.Store4(832, asuint(fog_light[0]));
    volume.Store4(848, asuint(fog_light[1]));
    volume.Store4(864, asuint(fog_frame[287]));
    volume.Store4(880, asuint(float4(fx.enabled, fx.density, fx.sunlight, fx.anisotropy)));
    volume.Store4(896, asuint(float4(fx.start_distance, fx.height_falloff, fx.quality, fx.local_strength)));
    volume.Store4(912, asuint(fog_frame[286]));
    [unroll] for (uint row = 0; row < 5; ++row) volume.Store4(928 + row * 16, asuint(fog_frame[189 + row]));
    volume.Store4(1008, uint4(0, 0, FOG_FRAME_VALID, 0));
    volume.Store4(1024, asuint(float4(beam.enabled, beam.density, beam.start_distance, beam.height_falloff)));
    volume.Store4(1040, asuint(float4(beam.quality, beam.local_shadows, beam.temporal, asfloat(beam.version))));
    volume.Store4(1056, asuint(float4(beam.indoor,beam.occlusion_quality,0.f,0.f)));
    volume.Store4(1072, uint4(0, 0, 0, 0));
  }
  float2 ndc = (id.xy + .5f) / dimensions.xy * float2(2, -2) + float2(-1, 1);
  float4 world_h = ndc.x * fog_frame[17] + ndc.y * fog_frame[18] + .5f * fog_frame[19] + fog_frame[20];
  float3 ray = normalize(world_h.xyz / world_h.w - fog_frame[0].xyz);
  float start = max(LightStart(), fog_frame[22].z);
  float far_distance = VolumeFarDistance();
  float begin = SliceDistance(id.z, dimensions.z, .1f, far_distance);
  float end = SliceDistance(id.z + 1.f, dimensions.z, .1f, far_distance);
  float distance = .5f * (begin + end);
  float3 world = fog_frame[0].xyz + ray * distance;
  float directional = saturate((fog_frame[42].x + dot(ray, fog_frame[38].xyz)) / max(1.f + fog_frame[42].x, .0001f));
  float native_falloff = max(0.f, lerp(fog_frame[43].z, fog_frame[43].y, directional));
  float falloff = native_falloff * LightHeight();
  float density = max(fog_frame[43].x, 0.f) * LightDensity();
  float extinction = density * FogHeightDensity(world.z + fog_frame[42].y, falloff)
                     * saturate((end - max(begin, start)) / max(end - begin, 1.e-6f));
  if (!LightEnabled()) extinction = 0.f;
  float fog_extinction = max(fog_frame[43].x, 0.f) * fx.density
      * FogHeightDensity(world.z + fog_frame[42].y, native_falloff * fx.height_falloff)
      * saturate((end - max(begin, max(fx.start_distance, fog_frame[22].z))) / max(end - begin, 1.e-6f));
  float exterior = 1.f;
  if ((sampling.x & 4u) != 0) {
    uint interior_offset = FogExtinctionOffset() + (IndependentLight() ? dimensions.x * dimensions.y * dimensions.z * 4u : 0u);
    // The early native consumer owns t24. Its snapshot travels with the volume
    // instead of assuming that texture remains bound at the later sun pass.
    uint2 interior_size = volume.Load2(interior_offset + 80);
    bool compatible = asfloat(volume.Load(interior_offset)) > 0.f && all(interior_size > 0)
                      && all(asfloat(volume.Load4(interior_offset + 16)) == fog_frame[0])
                      && all(asfloat(volume.Load4(interior_offset + 32)) == fog_frame[17])
                      && all(asfloat(volume.Load4(interior_offset + 48)) == fog_frame[18])
                      && all(asfloat(volume.Load4(interior_offset + 64)) == fog_frame[23])
                      && all(volume.Load4(interior_offset + 96) == asuint(fog_frame[286]));
    if (compatible) {
      uint2 pixel = min(uint2((id.xy + .5f) / dimensions.xy * interior_size), interior_size - 1);
      float2 boundaries = asfloat(volume.Load2(interior_offset + 128 + (pixel.y * interior_size.x + pixel.x) * 8));
      exterior = FogExteriorFraction(boundaries, begin, end);
    }
  }
  extinction *= IndependentLight() ? lerp(exterior,1.f,saturate(beam.indoor)) : exterior;
  if (IndependentLight()) volume.Store(FogExtinctionOffset() + CellIndex(id) * 4u, asuint(fog_extinction * exterior));
  float3 source = 0.f;
  if (extinction > 0.f && fx.sunlight > 0.f) {
    float3 relative = world_h.xyz - fog_frame[0].xyz * world_h.w;
    float inverse_length = rsqrt(max(dot(relative, relative), 1.e-12f));
    float3 xb = (fog_frame[17].xyz - fog_frame[0].xyz * fog_frame[17].w) * (2.f / dimensions.x);
    float3 yb = (fog_frame[18].xyz - fog_frame[0].xyz * fog_frame[18].w) * (-2.f / dimensions.y);
    float3 dx = (xb - ray * dot(ray, xb)) * (distance * inverse_length);
    float3 dy = (yb - ray * dot(ray, yb)) * (distance * inverse_length);
    float3 dz = ray * (end - begin);
    // Antithetic quadrature covers the physical cell, including radial depth.
    // Deterministic until a validated temporal history is available.
    static const float2 pattern[8] = {float2(0, 0), float2(.5f, 1.f / 3.f), float2(.25f, 2.f / 3.f), float2(.75f, 1.f / 9.f),
        float2(.125f,4.f/9.f),float2(.625f,7.f/9.f),float2(.375f,2.f/9.f),float2(.875f,5.f/9.f)};
    uint pairs=IndependentLight() ? (beam.quality>=3.5f?8u:beam.quality<1.5f?1u:beam.quality<2.5f?2u:4u) : fx.quality_preset>=3.5f?8u:4u;
    float visibility = 0.f;
    bool history_valid = GridHistoryCompatible(fog_light[0], fog_light[1]);
    float3 jitter = history_valid ? float3(GridFastSample(id.xy, id.z * 3), GridFastSample(id.xy, id.z * 3 + 1), GridFastSample(id.xy, id.z * 3 + 2)) : .5f;
    [loop] for (uint i = 0; i < pairs; ++i) {
      float3 offset = float3(pattern[i] - .5f, .5f * (i + .5f) / pairs);
      if (history_valid) offset = float3(frac(pattern[i] + jitter.xy) - .5f, .5f * (i + jitter.z) / pairs);
      float3 delta = dx * offset.x + dy * offset.y + dz * offset.z;
      visibility += FogSunVisibility(world + delta) + FogSunVisibility(world - delta);
    }
    float3 sun = fog_light[0].xyz * rsqrt(max(dot(fog_light[0].xyz, fog_light[0].xyz), 1.e-12f));
    source = max(fog_light[1].xyz, 0.f) * fx.sunlight * PhaseHG(dot(ray, sun), fx.anisotropy)
             * (visibility / (2.f*pairs)) * FogTerrainVisibility(world, sampling.x) * FogCloudVisibility(world, distance, sampling.x)
             * FogLightTransmittance(world.z + fog_frame[42].y, sun.z, density, falloff, 1000.f);
  }
  volume.Store2(FOG_HEADER_BYTES + CellIndex(id) * 8, PackVolume(float4(min(source * max(extinction, FogSourceFloor), 60000.f), min(extinction, 100.f))));
}
#endif
void IntegrateColumn(uint2 id) {
  if (any(id >= dimensions.xy)) return;
  uint resolved = FOG_HEADER_BYTES + dimensions.x * dimensions.y * dimensions.z * 8;
  uint offset = resolved + dimensions.x * dimensions.y * dimensions.z * 8;
  float4 profile = CapturedFrame(42);
  float4 curve = asfloat(volume.Load4(32));
  float far_distance = asfloat(volume.Load(12));
  if (all(id == 0)) {
    volume.Store4(0, asuint(float4(dimensions.xyz, far_distance)));
    volume.Store4(16, asuint(float4(CapturedFrame(23).zw, .1f, offset)));
    volume.Store(1008, FOG_HISTORY_VALID);
  }
  float tau = 0.f, light_tau = 0.f, previous = .1f, weather_opacity = 0.f;
  float3 scattering = 0.f;
  volume.Store2(offset + CellIndex(uint3(id, 0)) * 8, PackVolume(0.f));
  [loop] for (uint z = 0; z < dimensions.z; ++z) {
    float end = SliceDistance(z + 1.f, dimensions.z, .1f, far_distance);
    float4 cell = UnpackVolume(volume.Load2(resolved + CellIndex(uint3(id, z)) * 8));
    float fog_extinction = IndependentLight() ? asfloat(volume.Load(FogExtinctionOffset() + CellIndex(uint3(id,z)) * 4u)) : cell.a;
    tau += fog_extinction * (end - previous);
    float raw = SegmentOpacity(tau);
    float opacity = pow(max(raw, 0.f), max(profile.w, .0001f))
                    * saturate((max(end - FogFadeStart(CapturedFrame(22).z), 0.f) - curve.y) * curve.z);
    float gain = cell.a > 0.f ? max(0.f, opacity - weather_opacity) : 0.f;
    if (IndependentLight()) {
      gain = exp(-light_tau) * SegmentOpacity(cell.a * (end - previous));
      light_tau += cell.a * (end - previous);
    }
    scattering += cell.rgb * (gain / max(cell.a, FogSourceFloor));
    weather_opacity = IndependentLight() ? opacity : weather_opacity + gain;
    volume.Store2(offset + CellIndex(uint3(id, z + 1)) * 8, PackVolume(float4(min(scattering, 60000.f), weather_opacity)));
    previous = end;
  }
}
