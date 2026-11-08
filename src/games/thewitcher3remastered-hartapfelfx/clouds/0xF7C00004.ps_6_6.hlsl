
// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "integration.hlsli"
#include "storage.hlsli"
#include "../fog/volume_sample.hlsli"
bool CloudFogReady() {
  return fx.enabled > .5f && FogVolume.Load(1008) == FOG_HISTORY_VALID
      && all(asfloat(FogVolume.Load4(64)).xyz == frame[0].xyz)
      && all(FogVolume.Load4(912) == asuint(frame[286]));
}
Texture2D<float4> cloud : register(t3);
Texture2D<float> cloud_depth : register(t4);
Texture2D<float4> scene_before : register(t10);
Texture2D<float4> scene_without_sun : register(t5);
Texture2D<float4> scene_without_moon : register(t6);
float4 main(float4 position:SV_Position):SV_Target {
  if (CloudAlreadyRendered()) discard;
  float2 uv=position.xy/dimensions.zw;
  float3 ray=CloudRay(uv);
  float2 interval=CloudInterval(frame[0].xyz,ray);
  float surface_distance=CloudSceneDistance(position.xy,ray);
  interval.y=min(interval.y,surface_distance);
  // Full-resolution tracing places one resolved cloud sample at this exact
  // output pixel. The former 2x2 upscale performed four depth/colour reads
  // and bilinear arithmetic that reduced to this single sample.
  int2 pixel=int2(position.xy);
  float distance=cloud_depth.Load(int3(pixel,0));
  // The native sky uses b12[204].yzw for a separate solar lobe. Correcting
  // that sky image with offset pixel taps printed colored rings and a halo.
  // The separately captured sun and moon additions have exact pixel masks;
  // trace their own view rays without an angular mask around b12[38].
  float3 sun_excess=(identity.w&512u)!=0u
      ?max(scene_before.Load(int3(pixel,0)).rgb-scene_without_sun.Load(int3(pixel,0)).rgb,0.f)
      :0.f;
  float3 moon_excess=(identity.w&1024u)!=0u
      ?max(((identity.w&512u)!=0u ? scene_without_sun.Load(int3(pixel,0)).rgb
          : scene_before.Load(int3(pixel,0)).rgb)-scene_without_moon.Load(int3(pixel,0)).rgb,0.f)
      :0.f;
  float4 value=distance>0.f?CloudDecode(cloud.Load(int3(pixel,0))):float4(0,0,0,1);
  // Resolve the native emitter through the cloud column independently of the
  // temporally reconstructed view ray. Correct only measured disc radiance:
  // changing cloud opacity inside the sun's angular mask prints a circular edge.
  float beam_transmission=1.f;
  if((any(sun_excess>0.f)||any(moon_excess>0.f))
      &&appearance.x>0.f &&appearance.y>0.f &&interval.y>interval.x
      &&any(cloud_family_low.xy>0.f)) {
    const uint samples=128u;
    float length_step=(interval.y-interval.x)/samples;
    float optical_depth=0.f;
    float cone=max(length(CloudRay(uv+float2(1.f/dimensions.z,0.f))-ray),
        length(CloudRay(uv+float2(0.f,1.f/dimensions.w))-ray));
    [loop]for(uint i=0u;i<samples &&optical_depth<14.f;++i) {
      float sample_distance=interval.x+(i+.5f)*length_step;
      float footprint=max(sample_distance*cone,1.f);
      float lod=clamp(log2(max(footprint*scattering.w/min(CloudFormationScale*appearance.z,2800.f),1.f)),0.f,4.f);
      optical_depth+=CloudOpticalExtinction*CloudDensity(frame[0].xyz+ray*sample_distance,
          (uint)scattering.y,lod,footprint)*length_step;
    }
    beam_transmission=exp(-optical_depth);
  }
  // Merge foreground air only after cloud history and the disc beam are
  // resolved, using the volume's weighted depth.
  if(distance>0.f)value=CloudAerialPerspective(uv,distance,value);
  // Aerial perspective fades cloud opacity, which would let the native discs
  // appear in front of dense distant clouds. Density is also a visual
  // control: at its authored 12% default the very bright HDR emitter needs
  // the unit-density optical column while cloud scattering keeps that look.
  // This remains Beer attenuation, exp(-tau), with calibrated emitter tau.
  // The measured emitter uses the finer beam at every pixel it contributes.
  float emitter_scale=CloudDirectBeamScale();
  float native_sun_transmission=pow(saturate(beam_transmission),emitter_scale);
  float native_moon_transmission=native_sun_transmission;
  // The terrain receiver uses a world-anchored, finite-beam solar column.
  // A bright native disc must not remain visible through the same column
  // while the ground below has lost direct light.
  if((any(sun_excess>0.f)||any(moon_excess>0.f)) &&asfloat(cloud_status.Load(44))==1357.f
      &&all(asfloat(cloud_status.Load3(48))==frame[0].xyz)
      &&all(cloud_status.Load4(80)==asuint(frame[286]))) {
    float4 region=asfloat(cloud_status.Load4(0));
    float4 sun=asfloat(cloud_status.Load4(16));
    uint2 size=uint2(asfloat(cloud_status.Load2(32)));
    uint offset=cloud_status.Load(60),pitch=cloud_status.Load(64);
    if(sun.w==1.f &&sun.z>.015f &&region.w>0.f &&all(size>0u)
        &&pitch>=size.x*4u &&offset>=240u) {
      float2 shadow_uv=(frame[0].xy-frame[0].z*sun.xy/sun.z-region.xy)/region.w+.5f;
      if(all(shadow_uv>0.f)&&all(shadow_uv<1.f)) {
        float2 pixel=shadow_uv*size-.5f;
        int2 cell=int2(floor(pixel));
        float2 weight=frac(pixel);
        float4 beam;
        [unroll]for(uint y=0u;y<2u;++y)[unroll]for(uint x=0u;x<2u;++x) {
          int2 position=clamp(cell+int2(x,y),0,int2(size)-1);
          beam[y*2u+x]=f16tof32(cloud_status.Load(offset+uint(position.y)*pitch+uint(position.x)*4u)&65535u);
        }
        float terrain_beam=lerp(lerp(beam.x,beam.y,weight.x),
            lerp(beam.z,beam.w,weight.x),weight.y);
        native_sun_transmission=min(native_sun_transmission,saturate(terrain_beam));
        if(dot(frame[205].yzw,frame[205].yzw)>.25f
            &&dot(sun.xyz,normalize(frame[205].yzw))>.999f)
          native_moon_transmission=min(native_moon_transmission,saturate(terrain_beam));
      }
    }
  }
  float3 disc_correction=(value.a-native_sun_transmission)*sun_excess
      +(value.a-native_moon_transmission)*moon_excess;
  if(distance<=0.f &&all(disc_correction==0.f))discard;
  value.rgb-=disc_correction;
  float opacity=saturate(1.f-value.a);
  // Premultiplied over: C + (1-opacity)*background. The background sky
  // already contains foreground fog S, so the cloud must carry opacity*S.
  // Sampling the same field at the same distance preserves that lighting even
  // under an opaque cloud, without double-counting it through cloud gaps.
  if(opacity>0.f &&CloudFogReady())
    value.rgb+=opacity*SampleFogVolume(position.xy, min(distance, asfloat(FogVolume.Load(12)))).rgb;
  return float4(value.rgb,opacity);
}
