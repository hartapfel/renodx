// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_CLASSIC_LIGHTING_BRDF
#define WITCHER_CLASSIC_LIGHTING_BRDF
#include "parameters.hlsli"
// Deferred equivalent of the normal-variance filtering used on BlitzFX's
// chainmail/metal G-buffer shaders (Tokuyoshi/Kaplanyan 2017). Explicit quad
// neighbours also work in SM5 compute and inside divergent local-light paths.
// Reject depth discontinuities rather than treating silhouettes as roughness.
float FilterDirectRoughness(int2 pixel,float4 material) {
  uint width,height;t2.GetDimensions(width,height);
  width=min(width,(uint)cb12[23].x);height=min(height,(uint)cb12[23].y);
  if(width==0||height==0)return saturate(material.w);
  float3 n=material.xyz-.5f;
  n*=rsqrt(max(dot(n,n),1.e-8f));
  float depth=t0.Load(int3(pixel,0)).x;
  float center_z=rcp(max(1.e-7f,(depth*cb12[22].x+cb12[22].y)*cb12[21].x+cb12[21].y));
  float variance=0.f;
  [unroll]for(uint axis=0;axis<2;++axis) {
    int2 adjacent=pixel^(axis==0?int2(1,0):int2(0,1));
    adjacent=clamp(adjacent,0,int2(width,height)-1);
    float neighbor_depth=t0.Load(int3(adjacent,0)).x;
    float z=rcp(max(1.e-7f,(neighbor_depth*cb12[22].x+cb12[22].y)*cb12[21].x+cb12[21].y));
    float3 neighbor=t2.Load(int3(adjacent,0)).xyz-.5f;
    neighbor*=rsqrt(max(dot(neighbor,neighbor),1.e-8f));
    float3 delta=n-neighbor;
    if(abs(z-center_z)<max(.01f,.01f*center_z))variance+=dot(delta,delta);
  }
  return sqrt(saturate(material.w*material.w+min(.5f*variance,.18f)));
}
// Cook-Torrance GGX with height-correlated Smith visibility (Heitz 2014).
// Perceptual roughness -> alpha = roughness^2. See LIGHTING.md for sources.
// Returns D*V*NoL; the caller supplies Fresnel and incident radiance.
float DirectGGX(float no_h, float no_v, float no_l, float roughness) {
  no_h = saturate(no_h); no_v = saturate(abs(no_v)); no_l = saturate(no_l);
  float alpha = max(roughness * roughness, .002025f);
  float a2 = alpha * alpha;
  // This form avoids subtracting nearly equal values at a polished highlight.
  float d = (1.f - no_h * no_h) + no_h * no_h * a2;
  float visibility_denominator = no_l * sqrt(a2 + (1.f - a2) * no_v * no_v)
      + no_v * sqrt(a2 + (1.f - a2) * no_l * no_l);
  return a2 * no_l / max(6.28318530718f * d * d * visibility_denominator, 1.e-20f);
}
float3 DirectFresnel(float3 f0, float one_minus_voh_pow5) {
  // Values below 2% encode material specular occlusion in Classic. Do not turn
  // those dark cavities into white grazing reflections (Filament, section 4.10).
  float f90 = saturate(50.f * dot(f0, float3(.2126f,.7152f,.0722f)));
  return f0 + (f90 - f0) * one_minus_voh_pow5;
}
// Energy-normalized Burley diffuse (Frostbite 2014). This is a multiplier for
// the existing Lambert/Fresnel-complement term, before native transmission.
// The first implementation changed specular alone, leaving rough materials
// without the angular diffuse response present in BlitzFX's PBR path.
float DirectDiffuseFactor(float no_v, float no_l, float lo_h, float roughness) {
  float linear_roughness = saturate(roughness*roughness);
  float fd90 = (.5f+2.f*saturate(lo_h)*saturate(lo_h))*linear_roughness;
  float2 grazing = 1.f-saturate(float2(abs(no_v),no_l));
  float2 power5 = grazing*grazing;
  power5 *= power5*grazing;
  float2 scatter = 1.f+(fd90-1.f)*power5;
  return scatter.x*scatter.y*lerp(1.f,1.f/1.51f,linear_roughness);
}
#endif
