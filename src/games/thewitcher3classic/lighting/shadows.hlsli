// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_CLASSIC_LIGHTING_SHADOWS
#define WITCHER_CLASSIC_LIGHTING_SHADOWS
#include "parameters.hlsli"

float2 ShadowDisk(uint i, uint count) {
  // Fixed Vogel disk directions; no trigonometry in the per-pixel tap loops.
  static const float2 disk[32] = {
    float2(0.125000000f, 0.000000000f),
    float2(-0.159645045f, 0.146247939f),
    float2(0.024436233f, -0.278438271f),
    float2(0.201222239f, 0.262458779f),
    float2(-0.369267557f, -0.065318231f),
    float2(0.349802466f, -0.222515696f),
    float2(-0.117002079f, 0.435241902f),
    float2(-0.223135654f, -0.429634123f),
    float2(0.484115115f, 0.176798064f),
    float2(-0.503641109f, 0.207895728f),
    float2(0.242788294f, -0.518824483f),
    float2(0.179414374f, 0.572001296f),
    float2(-0.540757006f, -0.313379738f),
    float2(0.634369523f, -0.139464360f),
    float2(-0.387145845f, 0.550675126f),
    float2(-0.089439655f, -0.690199644f),
    float2(0.549071757f, 0.462758258f),
    float2(-0.738878471f, 0.030554945f),
    float2(0.538955125f, -0.536332334f),
    float2(-0.036058186f, 0.779791515f),
    float2(-0.512817532f, -0.614526793f),
    float2(0.812359593f, 0.109301834f),
    float2(-0.688310641f, 0.478908616f),
    float2(0.188086057f, -0.836061382f),
    float2(0.435033266f, 0.759191055f),
    float2(-0.850448410f, -0.271316239f),
    float2(0.826102401f, -0.381680263f),
    float2(-0.357888202f, 0.855155562f),
    float2(-0.319407334f, -0.888033758f),
    float2(0.849908635f, 0.446688159f),
    float2(-0.944034646f, 0.248844503f),
    float2(0.536595808f, -0.834529771f)
  };
  return disk[i] * sqrt(32.f / float(count));
}
float FilterCascade(float3 light_position, uint cascade, uint taps, bool soft, bool vegetation) {
  uint width, height, layers;
  t8.GetDimensions(width, height, layers);
  if (cascade >= layers || width == 0 || height == 0) return 1.f;
  float2 texel = rcp(float2(width,height));
  float scale = cb13[11+cascade].z;
  float2 uv = light_position.xy * scale * float2(1,-1) + cb13[11+cascade].xy;
  // These are material-dependent engine parameters, not merely quality knobs.
  // Ignoring the SpeedTree radius/gradient makes leaf cards self-shadow as solid
  // opaque sheets. Keep the captured native contract for every cascade.
  float native_radius = max(0.f, vegetation ? cb13[19+cascade].x : cb13[11+cascade].w);
  float vegetation_gradient = vegetation ? max(0.f,cb13[19+cascade].y) : 0.f;
  float minimum_radius = max(max(texel.x,texel.y),native_radius*(soft ? .5f : 1.f));
  float radius = minimum_radius;
  // Directional PCSS: distance is orthographic light-space separation, not
  // the perspective zReceiver/zBlocker ratio used for a spot light.
  if (soft) {
    float depth_scale = length(float3(cb13[4].z,cb13[5].z,cb13[6].z));
    float xy_scale = length(float3(cb13[4].x,cb13[5].x,cb13[6].x)) * abs(scale);
    float cone = tan(clamp(RenoLighting[2].x, .01f, 2.f) * .00872664626f);
    float search = min(16.f * radius, max(radius, 20.f * cone * xy_scale));
    // Include the centre: a thin blocker between disk taps must not disappear.
    float center_depth = t8.Load(int4(int2(clamp(uv,.5f*texel,1.f-.5f*texel)*float2(width,height)),cascade,0)).x;
    float separation = max(0.f,light_position.z-center_depth);
    float blockers = separation > 2.f/16777216.f ? 1.f : 0.f;
    separation *= blockers;
    [unroll] for (uint i=0; i<16; ++i) {
      float2 offset = ShadowDisk(i,16) * search;
      float2 sample_uv = clamp(uv + offset, .5f * texel, 1.f - .5f * texel);
      // Gather all four depths: point-only searches miss thin foliage blockers.
      float4 z = t8.GatherRed(s10_s,float3(sample_uv,cascade));
      float4 delta = light_position.z-z;
      float4 blocked = delta>2.f/16777216.f;
      separation += dot(max(delta,0.f),blocked);
      blockers += dot(blocked,1.f);

    }
    if (blockers == 0.f) return 1.f;
    float penumbra = separation / blockers / max(depth_scale, 1.e-8f) * cone * xy_scale;
    radius = clamp(penumbra,minimum_radius,max(minimum_radius,16.f*max(texel.x,texel.y)));
  }
  float sum=0.f;
  [loop] for (uint i=0; i<taps; ++i) {
    float2 offset = ShadowDisk(i,taps) * radius;
    float receiver = light_position.z - 2.f / 16777216.f
        - vegetation_gradient * (16.f/27.f) * float(i)/float(taps);
    sum += t8.SampleCmpLevelZero(s9_s, float3(clamp(uv+offset,.5f*texel,1.f-.5f*texel),cascade),receiver).x;
  }
  return sum / float(taps);
}
float DirectionalVisibility(float3 world, uint taps, bool soft, bool vegetation = false) {
  float3 light_position = world.x * cb13[4].xyz + world.y * cb13[5].xyz
      + world.z * cb13[6].xyz + cb13[7].xyz;
  // The original rasterizer bias and material gradient already handle this
  // receiver. ddx/ddy inside divergent material/cascade branches fitted planes
  // across unrelated surfaces, causing missing shadow patches on armor/leaves.
  uint count = min((uint)cb13[15].z,4u);
  if (count == 0 || abs(light_position.z) >= .999f) return 1.f;
  float4 distance = max(abs(light_position.x-cb13[8]),abs(light_position.y-cb13[9]));
  uint cascade=count;
  [unroll] for(uint i=0;i<4;++i)
    if(i<count && distance[i]<cb13[10][i]) {cascade=i;break;}
  if(cascade==count)return 1.f;
  float visibility = FilterCascade(light_position,cascade,taps,soft,vegetation);
  float blend = saturate((distance[cascade]/max(cb13[10][cascade],1.e-8f)
      - (1.f-cb13[17][cascade]))/max(cb13[17][cascade],1.e-5f));
  // Blend visibility, not shadow depths. No per-frame random cascade choice.
  if(blend>0.f) visibility=lerp(visibility,cascade+1<count
      ? FilterCascade(light_position,cascade+1,taps,soft,vegetation):1.f,blend);
  return visibility;
}

#ifndef RENO_HAIR_SHADOWS
Texture2D<float2> RenoContactMask:register(t119);
float FilteredContactVisibility(float2 pixel) {
  uint width,height;RenoContactMask.GetDimensions(width,height);
  width=min(width,(uint)cb12[23].x);height=min(height,(uint)cb12[23].y);
  if(width==0||height==0||any(pixel>=float2(width,height)))return 1.f;
  // Already spatially filtered before temporal accumulation. Filtering here
  // again would widen the final shadow without stabilizing history decisions.
  return RenoContactMask.Load(int3(pixel,0)).x;
}
#endif
#endif
