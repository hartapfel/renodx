// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_CLASSIC_VOLUME_LOCAL_LIGHTS
#define WITCHER_CLASSIC_VOLUME_LOCAL_LIGHTS
#include "../lighting/parameters.hlsli" // Shared native packed-atlas decoder.
#ifndef CLASSIC_LOCAL_EXTERNAL_RESOURCES
ByteAddressBuffer local_tiles : register(t4);
Texture2DArray<float> local_atlas : register(t5);
TextureCubeArray<float> local_cubes : register(t6);
SamplerState local_sampler : register(s3);
#endif

// Native local-light shadows are exponential shadow maps, not comparison-depth
// maps. Match 3946E96C/0AB3A292 and the forward path, including shadow strength.
float LocalVisibility(uint base, float3 to_light, float distance, bool spot) {
  if (light[base+2].w <= 0.f) return 1.f;
  float visibility = 1.f;
  if (light[base+5].z > 0.f) {
    float3 from_light = -to_light;
    float3 projection = 0.f;
    float packed = 0.f;
    if (spot) {
      projection = float3(dot(cross(light[base+2].xyz,light[base+7].yzw),from_light),
          dot(light[base+7].yzw,from_light),dot(light[base+2].xyz,from_light));
      packed = light[base+7].x;
    } else {
      // Face order/signs are the native point-light atlas convention.
      float3 direction = to_light / max(distance,1.e-6f);
      if (max(abs(direction.y),abs(direction.z)) < abs(direction.x)) {
        bool positive = direction.x > 0.f;
        projection = float3(positive ? from_light.y : -from_light.y,
            from_light.z,positive ? -from_light.x : from_light.x);
        packed = positive ? light[base+7].x : light[base+7].y;
      } else if (max(abs(direction.x),abs(direction.z)) < abs(direction.y)) {
        bool positive = direction.y > 0.f;
        projection = float3(positive ? -from_light.x : from_light.x,
            from_light.z,positive ? -from_light.y : from_light.y);
        packed = positive ? light[base+7].z : light[base+7].w;
      } else {
        bool positive = direction.z > 0.f;
        projection = float3(from_light.x,positive ? from_light.y : -from_light.y,
            positive ? -from_light.z : from_light.z);
        packed = positive ? light[base+8].x : light[base+8].y;
      }
    }
    float4 tile = DecodeShadowAtlas(packed);
    if (tile.z > 0.f) {
      uint width,height,layers;
      local_atlas.GetDimensions(width,height,layers);
      // Missing shadow data must not turn a shadow-casting light into a leak.
      if (width == 0 || height == 0 || tile.w >= float(layers)) return 0.f;
      float2 uv = light[base+5].y * projection.xy / max(projection.z,1.e-6f);
      uv = (uv * float2(.5f,-.5f) + .5f) * tile.z + tile.xy;
      float stored = local_atlas.SampleLevel(local_sampler,float3(uv/1024.f,tile.w),0);
      visibility = exp2(min(0.f,144.269501f*(stored-.99f*distance/light[base].w)));
    }
  }
  if (light[base+6].x > 0.f) {
    uint width,height,cubes;
    local_cubes.GetDimensions(width,height,cubes);
    if (width == 0 || light[base+6].y < 0.f || light[base+6].y >= float(cubes)) return 0.f;
    float stored = local_cubes.SampleLevel(local_sampler,float4(to_light,light[base+6].y),0);
    visibility *= exp2(min(0.f,144.269501f*(stored-.99f*distance/light[base].w)));
  }
  return lerp(1.f,visibility,saturate(light[base+2].w));
}

float3 LocalRadiance(uint base, float3 world, float3 ray, float falloff) {
  float3 to_light = light[base].xyz-world;
  float distance_squared = dot(to_light,to_light);
  if (light[base].w <= 0.f || distance_squared >= light[base].w*light[base].w) return 0.f;
  float distance = sqrt(max(distance_squared,1.e-12f));
  float3 direction = to_light/distance;
  float ratio_squared = distance_squared/(light[base].w*light[base].w);
  float attenuation = pow(saturate(1.f-ratio_squared*ratio_squared),2.f)
      / max(1.f+distance_squared*light[base+5].x,1.e-6f);
  bool spot = (asuint(light[base+3].w) & 1u) != 0;
  if (spot) {
    float cone = saturate(dot(-direction,light[base+2].xyz)*light[base+4].y+light[base+4].z);
    if (cone <= 0.f) return 0.f;
    attenuation *= pow(cone,max(light[base+4].w,0.f));
  }
  if (attenuation <= 0.f) return 0.f;
  float visibility = LocalVisibility(base,to_light,distance,spot);
  float transmittance = FogLightTransmittance(world.z+frame[42].y,direction.z,
      max(frame[43].x,0.f)*medium.x,falloff,distance);
  return max(light[base+3].xyz,0.f) * (attenuation*visibility*transmittance
      * PhaseHG(dot(ray,direction),medium.w)*sampling.w);
}
float3 LocalScattering(float2 uv, float3 world, float3 ray, float falloff) {
  uint bytes;
  local_tiles.GetDimensions(bytes);
  if (sampling.w <= 0.f || bytes < 1024 || any(sampling.xy <= 0.f)) return 0.f;
  // Native DA094A1D culls against the tile sides, camera plane and furthest
  // opaque depth, without rejecting the empty air in front of that depth.
  // Use active viewport pixels (not allocation size) under DLSS.
  uint2 tile = uint2(uv/sampling.xy) >> 4;
  uint columns = (uint)frame[24].x;
  if (columns == 0 || tile.x >= columns) return 0.f;
  uint offset = (tile.y*columns+tile.x)*1024u;
  if (offset > bytes-1024u) return 0.f;
  uint count = min(asuint(light[57].x),256u);
  if (count == 0) return 0.f;
  float3 scattering = 0.f;
  [loop] for (uint entry=0; entry<256u; ++entry) {
    uint index = local_tiles.Load(offset+entry*4u);
    if (index >= 256u) break;
    if (index >= count) continue;
    uint base = 58u+index*9u;
    uint flags = asuint(light[base+3].w);
    // Camera/player fill is a surface-lighting aid, not a luminous scene lamp.
    if (flags == 0x80001800u || light[base].w <= 0.f) continue;
    scattering += LocalRadiance(base,world,ray,falloff);
  }
  return scattering;
}
#endif
