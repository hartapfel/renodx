// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Native next-gen E6A77B56 / 9A6F318E layouts, independently decoded from captures.
struct FogLocalLight {
  float4 data[10];
};
#ifndef FOG_RASTER_LIGHTS
StructuredBuffer<FogLocalLight> FogLocalLights : register(t18);
#endif
Texture2DArray<float> FogLocalAtlas : register(t9);
TextureCubeArray<float> FogLocalCubes : register(t10);
Texture2DArray<float4> FogLocalCookies : register(t42);
SamplerState FogLocalSampler : register(s10);
groupshared uint FogGroupLightCount;
groupshared uint FogGroupLights[256];

FogLocalLight ReadFogLight(uint index) {
#ifdef FOG_RASTER_LIGHTS
  FogLocalLight light;
  [unroll] for (uint row = 0; row < 10; ++row) light.data[row] = fog_light[68 + 10 * index + row];
  return light;
#else
  return FogLocalLights[index];
#endif
}
uint FogLightCount() {
  uint count = asuint(fog_light[67].y);
#ifdef FOG_RASTER_LIGHTS
  return min(count, 256u);
#else
  uint available, stride;
  FogLocalLights.GetDimensions(available, stride);
  return stride == 160u ? min(count, available) : 0u;
#endif
}
void CullFogLightGroup(uint3 group, uint thread) {
  if (thread == 0) FogGroupLightCount = 0;
  GroupMemoryBarrierWithGroupSync();
  float2 lower = float2(group.xy * 4u), upper = min(lower + 4.f, float2(dimensions.xy));
  float2 ndc = ((lower + upper) * .5f) / dimensions.xy * float2(2, -2) + float2(-1, 1);
  float4 homogeneous = ndc.x * fog_frame[17] + ndc.y * fog_frame[18] + .5f * fog_frame[19] + fog_frame[20];
  float3 ray = normalize(homogeneous.xyz / homogeneous.w - fog_frame[0].xyz);
  float far_distance = max(1000.f, fog_frame[42].z + max(fx.start_distance, fog_frame[22].z));
  float begin = SliceDistance(min(group.z * 4u, dimensions.z), dimensions.z, .1f, far_distance);
  float end = SliceDistance(min(group.z * 4u + 4u, dimensions.z), dimensions.z, .1f, far_distance);
  float3 center = fog_frame[0].xyz + ray * (.5f * (begin + end));
  // Conservative normalization bound encloses the whole perspective group.
  float radius = .5f * (end - begin) + 2.f * end * length((upper - lower) / dimensions.xy * abs(fog_frame[21].zw));
  uint count = FogLightCount();
  [loop] for (uint i = thread; i < count; i += 64u) {
    FogLocalLight light = ReadFogLight(i);
    if (light.data[0].w <= 0.f || !any(light.data[3].rgb > 0.f) || asuint(light.data[3].w) == 0x80001800u) continue;
    float3 relative = light.data[0].xyz - center;
    float combined = radius + light.data[0].w;
    if (dot(relative, relative) > combined * combined) continue;
    uint entry;
    InterlockedAdd(FogGroupLightCount, 1u, entry);
    if (entry < 256u) FogGroupLights[entry] = i;
  }
  GroupMemoryBarrierWithGroupSync();
}
float3 LocalProjection(FogLocalLight light, float3 to_light, bool spot, out float packed, out uint cookie) {
  uint flags = asuint(light.data[9].x);
  float3 from_light = -to_light;
  if (spot) {
    packed = light.data[7].x;
    cookie = asuint(light.data[9].z);
    return float3(dot(cross(light.data[2].xyz, light.data[7].yzw), from_light),
                  dot(light.data[7].yzw, from_light), dot(light.data[2].xyz, from_light));
  }
  if ((flags & 1u) != 0) {
    to_light = -float3(dot(cross(light.data[2].xyz, light.data[4].yzw), from_light),
                       dot(light.data[2].xyz, from_light), dot(light.data[4].yzw, from_light));
    from_light = -to_light;
  }
  float3 projection;
  uint face;
  float3 magnitude = abs(to_light);
  if (magnitude.x > max(magnitude.y, magnitude.z)) {
    face = to_light.x > 0.f ? 0u : 1u;
    projection = float3(face == 0 ? from_light.y : -from_light.y, from_light.z, abs(to_light.x));
  } else if (magnitude.y > max(magnitude.x, magnitude.z)) {
    face = to_light.y > 0.f ? 2u : 3u;
    projection = float3(face == 2 ? -from_light.x : from_light.x, from_light.z, abs(to_light.y));
  } else {
    face = to_light.z > 0.f ? 4u : 5u;
    projection = float3(from_light.x, face == 4 ? from_light.y : -from_light.y, abs(to_light.z));
  }
  packed = face < 4 ? light.data[7][face] : light.data[8][face - 4];
  uint bits = asuint(face < 3 ? light.data[9].z : light.data[9].w);
  cookie = (flags & 4u) != 0 ? asuint(light.data[9].z) : bits >> ((face % 3) * 10);
  return projection;
}
float3 LocalVisibility(FogLocalLight light, float3 to_light, float distance, bool spot) {
  float visibility = 1.f;
  float3 color = 1.f;
  uint cookie_flags = asuint(light.data[9].x);
  if (light.data[5].z > 0.f || (cookie_flags & 1u) != 0) {
    float packed;
    uint cookie;
    float3 projection = LocalProjection(light, to_light, spot, packed, cookie);
    float2 uv = projection.xy * light.data[5].y / max(projection.z, 1.e-6f) * float2(.5f, -.5f) + .5f;
    if (light.data[5].z > 0.f) {
      uint bits = asuint(packed);
      float size = float((bits >> 18) & 4092u);
      if (size > 0.f) {
        uint width, height, layers;
        FogLocalAtlas.GetDimensions(width, height, layers);
        uint layer = bits >> 30;
        if (width == 0 || height == 0 || layer >= layers) return 0.f;
        float2 origin = float2((bits << 2) & 4092u, (bits >> 8) & 4092u);
        float stored = FogLocalAtlas.SampleLevel(FogLocalSampler, float3((origin + uv * size) * fog_light[67].x, layer), 0);
        visibility = exp2(min(0.f, 144.269501f * (stored - .99f * distance / light.data[0].w)));
      }
    }
    if ((cookie_flags & 1u) != 0) {
      bool rgb = (cookie_flags & 2u) != 0;
      uint index = rgb ? cookie & 1023u : cookie & 255u;
      uint channel = (cookie >> 8) & 3u;
      float animation = light.data[9].y;
      float layer = floor(animation) + index;
      float4 value = FogLocalCookies.SampleLevel(FogLocalSampler, float3(uv, layer), 0);
      if ((cookie_flags & 8u) != 0) value = lerp(value, FogLocalCookies.SampleLevel(FogLocalSampler, float3(uv, layer + 1.f), 0), frac(animation));
      color = rgb ? value.rgb : value[channel];
    }
  }
  if (light.data[6].x > 0.f) {
    uint width, height, cubes;
    FogLocalCubes.GetDimensions(width, height, cubes);
    if (width == 0 || light.data[6].y < 0.f || light.data[6].y >= cubes) return 0.f;
    float stored = FogLocalCubes.SampleLevel(FogLocalSampler, float4(to_light, light.data[6].y), 0);
    visibility *= exp2(min(0.f, 144.269501f * (stored - .99f * distance / light.data[0].w)));
  }
  // This weighted form preserves small ESM visibility in HDR. Subtracting
  // visibility from one first cancels dim shadowed contributions in FP32.
  float shadow_strength = saturate(light.data[5].w);
  return color * ((1.f - shadow_strength) + visibility * shadow_strength);
}
float3 LocalRadiance(FogLocalLight light, float3 world, float3 ray, float falloff) {
  float3 to_light = light.data[0].xyz - world;
  float squared = dot(to_light, to_light);
  float radius = light.data[0].w;
  if (radius <= 0.f || squared >= radius * radius) return 0.f;
  float distance = sqrt(max(squared, 1.e-12f));
  float3 direction = to_light / distance;
  float ratio = squared / (radius * radius);
  float attenuation = pow(saturate(1.f - ratio * ratio), 2.f) / max(1.f + squared * light.data[5].x, 1.e-6f);
  bool spot = (asuint(light.data[3].w) & 1u) != 0;
  if (spot) attenuation *= pow(saturate(dot(-direction, light.data[2].xyz) * light.data[4].y + light.data[4].z), max(light.data[4].w, 0.f));
  if (attenuation <= 0.f) return 0.f;
  float transmittance = FogLightTransmittance(world.z + fog_frame[42].y, direction.z, max(fog_frame[43].x, 0.f) * fx.density, falloff, distance);
  return max(light.data[3].rgb, 0.f) * LocalVisibility(light, to_light, distance, spot)
         * (attenuation * transmittance * PhaseHG(dot(ray, direction), fx.anisotropy) * fx.local_strength);
}
void AddLocalCell(uint3 id) {
  if (any(id >= dimensions.xyz) || fx.local_strength <= 0.f) return;
  if (volume.Load(1016) != FOG_FRAME_VALID || volume.Load(1008) != 0 || volume.Load(1012) != 0
      || any(volume.Load4(912) != asuint(fog_frame[286]))
      || any(asfloat(volume.Load4(64)) != fog_frame[0])
      || any(asfloat(volume.Load4(64 + 17 * 16)) != fog_frame[17])
      || any(asfloat(volume.Load4(64 + 18 * 16)) != fog_frame[18])
      || any(asfloat(volume.Load4(64 + 23 * 16)) != fog_frame[23])) return;
  float4 cell = UnpackVolume(volume.Load2(FOG_HEADER_BYTES + CellIndex(id) * 8));
  if (cell.a <= 0.f) return;
  float2 ndc = (id.xy + .5f) / dimensions.xy * float2(2, -2) + float2(-1, 1);
  float4 position = ndc.x * fog_frame[17] + ndc.y * fog_frame[18] + .5f * fog_frame[19] + fog_frame[20];
  float3 ray = normalize(position.xyz / position.w - fog_frame[0].xyz);
  float directional = saturate((fog_frame[42].x + dot(ray, fog_frame[38].xyz)) / max(1.f + fog_frame[42].x, .0001f));
  float falloff = max(0.f, lerp(fog_frame[43].z, fog_frame[43].y, directional)) * fx.height_falloff;
  float far_distance = max(1000.f, fog_frame[42].z + max(fx.start_distance, fog_frame[22].z));
  float begin = SliceDistance(id.z, dimensions.z, .1f, far_distance);
  float end = SliceDistance(id.z + 1.f, dimensions.z, .1f, far_distance);
  bool overflow = FogGroupLightCount > 256u;
  uint count = overflow ? FogLightCount() : FogGroupLightCount;
  float3 source = 0.f;
  [loop] for (uint i = 0; i < count; ++i) {
    FogLocalLight light = ReadFogLight(overflow ? i : FogGroupLights[i]);
    if (asuint(light.data[3].w) == 0x80001800u || light.data[0].w <= 0.f || !any(light.data[3].rgb > 0.f)) continue;
    float3 relative = light.data[0].xyz - fog_frame[0].xyz;
    float3 closest = relative - ray * clamp(dot(relative, ray), begin, end);
    if (dot(closest, closest) > light.data[0].w * light.data[0].w) continue;
    [unroll] for (uint sample = 0; sample < 4; ++sample)
        source += .25f * LocalRadiance(light, fog_frame[0].xyz + ray * lerp(begin, end, (sample + .5f) / 4.f), ray, falloff);
  }
  cell.rgb = min(cell.rgb + source * max(cell.a, FogSourceFloor), 60000.f);
  volume.Store2(FOG_HEADER_BYTES + CellIndex(id) * 8, PackVolume(cell));
}
