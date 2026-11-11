// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../shared.h"
#include "caustics.hlsli"
#include "lighting.hlsli"

Texture2D<float4> scene : register(t0);
Texture2D<float2> water_mask : register(t2);
Texture2D<float> opaque_depth : register(t3);
Texture2D<float> depth_with_water : register(t15);
SamplerState scene_sampler : register(s0);
SamplerState mask_sampler : register(s2);
SamplerState opaque_depth_sampler : register(s3);
SamplerState water_depth_sampler : register(s15);

cbuffer WaterMaterial : register(b0) {
  float4 water_time : packoffset(c0);
  float4 viewport_scale : packoffset(c2);
  float4 directional_light : packoffset(c9);
  float4 shallow_colour : packoffset(c11);
  float4 medium_colour : packoffset(c13);
  float4 medium_strength : packoffset(c14);
};
cbuffer WaterFrame : register(b12) {
  float4 frame[341];
};

float WaterDepth(float raw_depth) {
  const float divisor = (raw_depth * frame[22].x + frame[22].y) * frame[21].x + frame[21].y;
  // Zero reciprocal depth represents the far plane of an infinite projection.
  return isfinite(divisor) && divisor >= 0.f ? rcp(max(divisor, .005f)) : -1.f;
}

float2 WaterDepths(float2 uv) {
  return float2(WaterDepth(opaque_depth.SampleLevel(opaque_depth_sampler, uv, 0.f)),
                WaterDepth(depth_with_water.SampleLevel(water_depth_sampler, uv, 0.f)));
}

float3 WaterViewRay(float2 uv) {
  const float2 ndc = uv * float2(2.f, -2.f) + float2(-1.f, 1.f);
  const float3 view = float3((ndc - frame[15].xy) / float2(frame[13].x, frame[14].y), 1.f);
  return normalize(float3(dot(view, frame[1].xyz), dot(view, frame[2].xyz), dot(view, frame[3].xyz)));
}

float4 main(noperspective float4 position : SV_Position, linear float2 uv : TEXCOORD) : SV_Target {
  const float4 original = scene.SampleLevel(scene_sampler, uv, 0.f);
  if (!(fx.water_enabled > .5f) || any(viewport_scale.zw <= 0.f)) return original;
  const float coverage = saturate(water_mask.SampleLevel(mask_sampler, uv / viewport_scale.zw, 0.f).x);
  if (coverage < .001f) return original;

  const float2 depths = WaterDepths(uv);
  if (any(depths < 0.f)) return original;
  const float2 pixel_size = frame[23].zw;
  const float2 projection_scale = float2(frame[13].x, frame[14].y);
  if (any(pixel_size <= 0.f) || any(abs(projection_scale) < 1e-6f)) return original;
  const float3 ray = WaterViewRay(position.xy * pixel_size);
  const float3 forward = float3(frame[1].z, frame[2].z, frame[3].z);
  const float forward_cosine = dot(ray, forward);
  if (!isfinite(forward_cosine) || forward_cosine <= 0.f) return original;

  const float opaque_distance = depths.x / max(forward_cosine, .125f);
  const float raster_distance = depths.y / max(forward_cosine, .125f);
  const float3 camera = frame[0].xyz;
  const float3 tint = max(medium_colour.yzw, 0.f);
  const float3 ambient = WaterMediumRadiance(shallow_colour.rgb, tint, medium_strength.x);
  const float density = WaterMediumDensity(fx.water_murk, medium_strength.y);
  const float exit_coverage = smoothstep(.025f, .075f, depths.x - depths.y);
  // Preserve the actual near interface. Fade its contribution at long range
  // where the native mesh ends and the two depth buffers become identical.
  const float distant_exit = smoothstep(24.f, 52.f, raster_distance) * smoothstep(.5f, 1.8f, density * raster_distance);
  const float distance = min(200.f, lerp(opaque_distance, raster_distance, exit_coverage * (1.f - distant_exit)));
  const float3 transmission = WaterTransmittance(distance, density, tint);
  float3 background = original.rgb;
  float3 direct = 0.f;

  const bool has_light = WaterLightMatches(frame[0], frame[15], asuint(frame[286]), frame[17]);
  const float3 native_direction = has_light ? asfloat(water_light.Load3(64)) : directional_light.xyz;
  const float3 sun = native_direction * rsqrt(max(dot(native_direction, native_direction), 1e-8f));
  const float3 origin = has_light ? asfloat(water_light.Load3(4)) : 0.f;
  if (sun.z > .015f) {
    const float3 toward_sun = -refract(-sun, float3(0.f, 0.f, 1.f), rcp(WaterIor));
    const float entry_transmission = (1.f - WaterFresnel(sun.z, WaterIor)) * smoothstep(.015f, .13f, sun.z);
    if (has_light) {
      const float3 light_rgb = max(asfloat(water_light.Load3(80)), 0.f);
      // The engine's HDR light values are calibrated for its deferred BRDF.
      // Use their hue and a bounded intensity for the regional volume source.
      const float3 light_response = light_rgb / (8.f + max(light_rgb.r, max(light_rgb.g, light_rgb.b)));
      direct = min(ambient, .35f) * light_response * (6.f * entry_transmission)
               * IntegrateWaterSun(camera, ray, distance, toward_sun, density, tint, origin);
    }
    if (exit_coverage < 1.f && opaque_distance < 55.f) {
      const float3 receiver = camera + ray * opaque_distance;
      const float depth = WaterLocalDepth - ray.z * opaque_distance;
      const float incoming = max(depth, 0.f) / max(toward_sun.z, .1f);
      // The owned field is authoritative when present. The scene-lit fallback
      // only redistributes existing receiver radiance and follows native sun.
      const float visibility = has_light ? WaterVisibility(receiver, origin) : .65f;
      if (visibility > .001f) {
        const float3 focus = WaterCaustics(receiver.xy, depth, opaque_distance, sun, water_time.x);
        background *= 1.f + 1.65f * (1.f - exit_coverage) * visibility * entry_transmission * focus
                            * WaterTransmittance(incoming, density, tint);
      }
    }
  }
  return float4(lerp(original.rgb, lerp(ambient, background, transmission) + direct, coverage), 0.f);
}
