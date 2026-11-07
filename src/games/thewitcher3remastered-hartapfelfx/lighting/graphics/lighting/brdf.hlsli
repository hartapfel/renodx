// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_REMASTERED_LIGHTING_BRDF
#define WITCHER_REMASTERED_LIGHTING_BRDF

// Classic's direct-light roughness filter, using Remastered's native depth and
// normal buffers. Apply only to direct BRDF evaluation, not material exports or
// the roughness used by native reflection reconstruction.
float GraphicsDirectRoughness(Texture2D<float> depth_texture, Texture2D<float4> normal_texture,
                              int2 pixel, float4 material, uint2 viewport_size,
                              float2 depth_scale, float2 projection) {
  uint width, height;
  normal_texture.GetDimensions(width, height);
  uint2 size = min(uint2(width, height), viewport_size);
  if (any(size == 0)) return saturate(material.w);
  float3 normal = material.xyz - .5f;
  normal *= rsqrt(max(dot(normal, normal), 1.e-8f));
  float depth = depth_texture.Load(int3(pixel, 0));
  float center_z = rcp(max(1.e-7f, (depth * depth_scale.x + depth_scale.y) * projection.x + projection.y));
  float variance = 0.f;
  [unroll] for (uint axis = 0; axis < 2; ++axis) {
    int2 adjacent = clamp(pixel ^ (axis == 0 ? int2(1, 0) : int2(0, 1)), 0, int2(size) - 1);
    float neighbor_depth = depth_texture.Load(int3(adjacent, 0));
    float z = rcp(max(1.e-7f, (neighbor_depth * depth_scale.x + depth_scale.y) * projection.x + projection.y));
    float3 neighbor = normal_texture.Load(int3(adjacent, 0)).xyz - .5f;
    neighbor *= rsqrt(max(dot(neighbor, neighbor), 1.e-8f));
    float3 delta = normal - neighbor;
    if (abs(z - center_z) < max(.01f, .01f * center_z)) variance += dot(delta, delta);
  }
  return sqrt(saturate(material.w * material.w + min(.5f * variance, .18f)));
}

// D * correlated Smith visibility. The caller owns NoL, attenuation, visibility
// and the game's material-specific Fresnel/energy compensation.
float GraphicsDirectGGX(float no_h, float no_v, float no_l, float roughness) {
  no_h = saturate(no_h); no_v = saturate(abs(no_v)); no_l = saturate(no_l);
  float alpha = max(roughness * roughness, .002025f);
  float a2 = alpha * alpha;
  float denominator = (1.f - no_h * no_h) + no_h * no_h * a2;
  float visibility = no_l * sqrt(a2 + (1.f - a2) * no_v * no_v)
      + no_v * sqrt(a2 + (1.f - a2) * no_l * no_l);
  return a2 / max(6.28318530718f * denominator * denominator * visibility, 1.e-20f);
}

// Energy-normalized Burley response for native Lambert diffuse. Keep native
// transmission separate and preserve material paths with their own response.
float GraphicsDirectDiffuse(float no_v, float no_l, float lo_h, float roughness) {
  float linear_roughness = saturate(roughness * roughness);
  float fd90 = (.5f + 2.f * saturate(lo_h) * saturate(lo_h)) * linear_roughness;
  float2 grazing = 1.f - saturate(float2(abs(no_v), no_l));
  float2 power5 = grazing * grazing;
  power5 *= power5 * grazing;
  float2 scatter = 1.f + (fd90 - 1.f) * power5;
  return scatter.x * scatter.y * lerp(1.f, 1.f / 1.51f, linear_roughness);
}

// Native Lambert delays albedo and 1/pi until later; the alternate diffuse
// model has already applied both. Preserve that contract at each call site.
float3 GraphicsDiffuseResponse(float3 normal, float3 view, float3 light_direction,
                               float roughness, float3 albedo, int native_model, float native_no_l) {
  float3 half_direction = light_direction + view;
  half_direction *= rsqrt(max(dot(half_direction, half_direction), 1.e-8f));
  float no_l = dot(normal, light_direction);
  float response = (native_model == 0 ? native_no_l : saturate(no_l))
      * GraphicsDirectDiffuse(dot(normal, view), no_l, dot(light_direction, half_direction), roughness);
  return native_model == 0 ? response.xxx : albedo * (response * .3183098861837907f);
}

// Forward surfaces have their own interpolated/normal-mapped normal. Evaluate
// derivatives before divergent lighting branches; do not borrow opaque G-buffer
// normals for these receivers or modify their exported/IBL roughness.
float GraphicsForwardRoughness(float3 normal, float roughness) {
  float3 dx = ddx_coarse(normal), dy = ddy_coarse(normal);
  return sqrt(saturate(roughness * roughness + min(.5f * (dot(dx, dx) + dot(dy, dy)), .18f)));
}

// Native Lambert adds authored wrap before the separate transmission term;
// the alternate diffuse model uses unwrapped NoL. Preserve that distinction.
float3 GraphicsForwardDiffuse(float3 normal, float3 view, float3 light_direction,
                              float roughness, float3 albedo, int native_model, float wrapped_no_l) {
  float no_l = saturate(dot(normal, light_direction));
  float wrap = native_model == 0 ? max(0.f, wrapped_no_l - no_l) : 0.f;
  return GraphicsDiffuseResponse(normal, view, light_direction, roughness, albedo, native_model, no_l)
      + wrap.xxx;
}

// Skin's direct lobe has authored RGB normal/shape controls and a separate
// transmission term. Preserve those controls and the alternate model's wrap
// convention; the caller retains native transmission and environment outputs.
float3 GraphicsSkinDiffuse(float3 normal, float3 view, float3 light_direction,
                          float roughness, float3 albedo, int native_model,
                          float3 native_shape) {
  float3 half_direction = light_direction + view;
  half_direction *= rsqrt(max(dot(half_direction, half_direction), 1.e-8f));
  float no_l = saturate(dot(normal, light_direction));
  float response = GraphicsDirectDiffuse(dot(normal, view), no_l,
      dot(light_direction, half_direction), roughness);
  return native_model == 0 ? native_shape * response
      : albedo * ((no_l * response + max(0.f, native_shape.x - no_l)) * .3183098861837907f);
}
#endif
