// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_PATH_ATMOSPHERE
#define WITCHER_GRAPHICS_PATH_ATMOSPHERE
#include "../volumetrics/transport.hlsli"

struct GraphicsPathAtmosphere {
  float3 desaturation_color;
  float desaturation_opacity;
  float3 color;
  float opacity;
};

struct GraphicsPathTransfer {
  float3x3 response;
  float3 scattering;
};

static const uint GRAPHICS_PATH_FOG_ENABLED=1u;
static const uint GRAPHICS_PATH_FOG_MATERIAL_DESATURATION=2u;
static const uint GRAPHICS_PATH_FOG_INSCATTER=4u;
static const uint GRAPHICS_PATH_FOG_CONTINUOUS_DENSITY=8u;

void GraphicsAttenuatePathTransfer(inout GraphicsPathTransfer transfer,float3 attenuation) {
  // Right multiplication by a diagonal medium/interface transfer. Existing
  // foreground scattering has already reached the receiver and stays intact.
  transfer.response[0]*=attenuation;
  transfer.response[1]*=attenuation;
  transfer.response[2]*=attenuation;
}

// Native desaturation mixes channels according to luminance, so a diagonal
// RGB transmittance cannot represent it. Preserve its full affine operation.
GraphicsPathTransfer GraphicsAtmosphereTransfer(GraphicsPathAtmosphere atmosphere,
    float desaturation_strength,bool allow_scattering) {
  float desaturation=saturate(desaturation_strength)*atmosphere.desaturation_opacity;
  // These are the native PT coefficients; deliberately do not normalize them.
  const float3 luminance=float3(.333f,.555f,.222f);
  GraphicsPathTransfer result;
  result.response=float3x3(atmosphere.desaturation_color.x*luminance,
      atmosphere.desaturation_color.y*luminance,atmosphere.desaturation_color.z*luminance)*desaturation;
  result.response+=float3x3(1,0,0,0,1,0,0,0,1)*(1.f-desaturation);
  result.response*=1.f-atmosphere.opacity;
  result.scattering=allow_scattering?atmosphere.color*atmosphere.opacity:0.f;
  return result;
}

// Front maps the current point back toward the receiver; back is the next
// segment toward the light. This order matters for colored water extinction
// between two differently oriented atmospheric segments.
GraphicsPathTransfer GraphicsComposePathTransfer(GraphicsPathTransfer front,GraphicsPathTransfer back) {
  GraphicsPathTransfer result;
  result.response=mul(front.response,back.response);
  result.scattering=front.scattering+mul(front.response,back.scattering);
  return result;
}

// Compact native SharedPixelConsts rows: [0..10]=c38..48,
// [11..15]=c189..193, [16]=c287. These describe authored atmosphere, including
// directional desaturation and weather color layers, not only scalar extinction.
// The caller decides which path segments are in air and whether inscatter is
// allowed by the native material-path flags. No primary-camera fog is added here.
GraphicsPathAtmosphere GraphicsEvaluatePathAtmosphere(float origin_height,float3 delta,bool sky,
    float4 parameters[17],bool improved_density) {
  GraphicsPathAtmosphere result=(GraphicsPathAtmosphere)0;
  float ray_length=length(delta);
  if(!isfinite(origin_height) || any(!isfinite(delta)) || ray_length<=1.e-6f)return result;
  float3 direction=delta/ray_length;
  float distance=sky?parameters[4].z:min(parameters[4].z,max(0.f,ray_length));
  float3 density=sky?parameters[6].xyz:parameters[5].xyz;
  float cosine=dot(parameters[0].xyz,direction);
  float falloff=lerp(density.z,density.y,saturate((cosine+parameters[4].x)/(1.f+parameters[4].x)));
  uint phase_mode=asuint(parameters[16].z);
  bool fade_phase=phase_mode==0u || (phase_mode!=2u && cosine>0.f);
  float phase=abs(cosine)*abs(cosine)*(fade_phase?saturate(distance*.002f-.3f):1.f);
  result.color=lerp(parameters[2].xyz,cosine>0.f?parameters[1].xyz:parameters[3].xyz,phase);
  result.desaturation_color=lerp(parameters[8].xyz,cosine>0.f?parameters[7].xyz:parameters[9].xyz,phase);
  float density_opacity=1.f,fade=0.f;
  if(distance>=parameters[10].y) {
    float height=origin_height+parameters[4].y;
    if(improved_density) {
      density_opacity=FogDensityOpacity(height,direction.z,density.x,falloff,distance);
    } else {
      // Preserve native reverse-order multiplication of its sixteen samples.
      // This branch is the equivalence baseline, not the improved integrator.
      float step=distance*.0625f,step_z=step*direction.z;
      float step_density=step*density.x,height_term=falloff*height,step_term=falloff*step_z;
      float transmission=1.f;
      [unroll] for(uint sample=16u;sample>0u;--sample)
        transmission*=1.f-saturate(step_density/(1.f+max(0.f,height_term+float(sample)*step_term)));
      density_opacity=1.f-transmission;
    }
    fade=saturate((distance-parameters[10].y)*parameters[10].z);
  }
  float logarithm=log2(abs(density_opacity));
  float opacity=exp2(logarithm*parameters[4].w)*fade;
  result.desaturation_opacity=exp2(logarithm*parameters[10].x)*fade;
  float first_color=saturate(parameters[12].x*opacity+parameters[12].y);
  float first_opacity=saturate(parameters[12].z*opacity+parameters[12].w);
  float3 base_color=result.color;
  result.color=lerp(base_color,parameters[11].xyz,first_color);
  result.opacity=saturate((1.f+(parameters[11].w-1.f)*first_opacity)*opacity);
  if(parameters[15].x>0.f) {
    float second_color=saturate(parameters[14].x*opacity+parameters[14].y);
    float second_opacity=saturate(parameters[14].z*opacity+parameters[14].w);
    result.color=lerp(result.color,lerp(base_color,parameters[13].xyz,second_color),parameters[15].x);
    result.opacity=lerp(result.opacity,saturate((1.f+(parameters[13].w-1.f)*second_opacity)*opacity),parameters[15].x);
  }
  return result;
}

void GraphicsAccumulatePathAtmosphere(inout GraphicsPathTransfer transfer,float height,float3 delta,
    bool sky,float4 parameters[17],uint flags) {
  transfer=GraphicsComposePathTransfer(transfer,GraphicsAtmosphereTransfer(
      GraphicsEvaluatePathAtmosphere(height,delta,sky,parameters,(flags&GRAPHICS_PATH_FOG_CONTINUOUS_DENSITY)!=0u),
      (flags&GRAPHICS_PATH_FOG_MATERIAL_DESATURATION)!=0u?parameters[7].w:parameters[10].w,
      (flags&GRAPHICS_PATH_FOG_INSCATTER)!=0u));
}
#endif
