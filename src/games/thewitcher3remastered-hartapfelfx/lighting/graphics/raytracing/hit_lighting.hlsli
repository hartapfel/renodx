// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_HIT_LIGHTING
#define WITCHER_GRAPHICS_HIT_LIGHTING
#include "../lighting/brdf.hlsli"
#include "hit_material.hlsli"
ByteAddressBuffer graphics_hit_material : register(t0, space59);
cbuffer GraphicsHitContext : register(b0, space59) { uint4 graphics_hit_context; }

// The native RT pass postpones diffuse albedo/pi until after direct + ambient
// accumulation. Return diffuse in that convention and specular as a complete
// radiance factor; the receiver adds specular before its existing fog stage.
void GraphicsHitBRDF(float3 normal, float3 view, float3 light, float4 material,
    out float3 diffuse, out float3 specular) {
  normal *= rsqrt(max(dot(normal, normal), 1.e-12f));
  view *= rsqrt(max(dot(view, view), 1.e-12f));
  light *= rsqrt(max(dot(light, light), 1.e-12f));
  float no_v = saturate(abs(dot(normal, view))), no_l = saturate(dot(normal, light));
  float3 half_vector = view + light;
  float length2 = dot(half_vector, half_vector);
  float3 half_direction = half_vector * rsqrt(max(length2, 1.e-12f));
  float lo_h = saturate(dot(light, half_direction));
  float grazing = 1.f - lo_h;
  float grazing2 = grazing * grazing;
  float3 fresnel = material.xyz + (1.f - material.xyz) * (grazing2 * grazing2 * grazing);
  diffuse = (1.f - fresnel) * (no_l * GraphicsDirectDiffuse(no_v, no_l, lo_h, material.w));
  float alpha = max(material.w * material.w, .002025f), a2 = alpha * alpha;
  float3 perpendicular = cross(normal, half_direction);
  float sine2 = saturate(dot(perpendicular, perpendicular));
  float denominator = sine2 + (1.f - sine2) * a2;
  float visibility = no_l * sqrt(a2 + (1.f - a2) * no_v * no_v)
      + no_v * sqrt(a2 + (1.f - a2) * no_l * no_l);
  specular = (no_l > 0.f && length2 > 1.e-12f)
      ? fresnel * (no_l * a2 / max(6.28318530718f * denominator * denominator * visibility, 1.e-20f)) : 0.f;
}
#endif
