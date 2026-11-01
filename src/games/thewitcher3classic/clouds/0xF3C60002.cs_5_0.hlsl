// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "common.hlsli"
RWTexture2D<float4> result : register(u0);
RWTexture2D<float> cloud_depth : register(u1);
[numthreads(8,8,1)]
void main(uint3 id:SV_DispatchThreadID) {
  if(any(id.xy>=uint2(dimensions.xy)))return;
  result[id.xy]=float4(0,0,0,1);cloud_depth[id.xy]=0;
  if(appearance.x==0.f ||appearance.y==0.f)return;
  float2 uv=(id.xy+.5f)/dimensions.xy;
  float3 ray=CloudRay(uv);
  if(ray.z<-.02f)return;
  float2 interval=CloudInterval(frame[0].xyz,ray);
  if(interval.y<=interval.x)return;
  // Conservative depth cull: every pixel covered by this cloud texel must be
  // in front of the layer. Mixed silhouettes still trace an unobscured sky.
  float maximum_distance=0.f;
  uint2 lo=uint2(id.xy*dimensions.zw/dimensions.xy);
  uint2 hi=uint2(ceil((id.xy+1)*dimensions.zw/dimensions.xy));
  [loop]for(uint y=lo.y;y<hi.y;++y)[loop]for(uint x=lo.x;x<hi.x;++x)
    maximum_distance=max(maximum_distance,CloudSceneDistance(float2(x,y)+.5f,ray));
  if(maximum_distance<interval.x)return;
  float step=(interval.y-interval.x)/integration.x;
  float cone=max(length(CloudRay(uv+float2(1.f/dimensions.x,0))-ray),
      length(CloudRay(uv+float2(0,1.f/dimensions.y))-ray));
  float random=frac(52.9829189f*frac(dot(float2(id.xy),float2(.06711056f,.00583715f)))+integration.z*.61803398875f);
  float3 direction=normalize(light[0].xyz+1.e-8f);
  float phase=.9f*PhaseHG(dot(ray,direction),.7f)+.1f*PhaseHG(dot(ray,direction),-.2f);
  float4 phases=float4(phase,0,0,0);
  float eccentricity=1.f,contribution=1.f;
  // Wrenninge/Hillaire octave approximation: successive scattering orders
  // lose energy, travel through lower effective extinction and become more
  // isotropic. This redistributes actual incident light, not emissive color.
  [unroll]for(uint octave=1;octave<4;++octave) {
    eccentricity*=.5f;contribution*=.5f*.98f;
    phases[octave]=contribution*(.9f*PhaseHG(dot(ray,direction),.7f*eccentricity)
        +.1f*PhaseHG(dot(ray,direction),-.2f*eccentricity));
  }
  float3 ambient=(CloudSky(float3(0,0,1))+CloudSky(normalize(float3(1,0,1)))
      +CloudSky(normalize(float3(-1,0,1)))+CloudSky(normalize(float3(0,1,1)))
      +CloudSky(normalize(float3(0,-1,1))))*.1f; // upper hemisphere / 4pi
  float3 radiance=0.f;
  float transmission=1.f,weighted_depth=0.f,weight=0.f;
  float t=interval.x;
  [loop]for(uint i=0;i<(uint)integration.x &&t<interval.y &&transmission>.005f;++i) {
    float3 p=frame[0].xyz+ray*(t+random*step);
    // Filter the transverse pixel footprint. The quadrature interval is along
    // the ray; using it as an isotropic texture footprint blurred cloud shapes
    // even when the image resolution increased. Depth jitter handles sampling
    // along the ray, with Step Size providing explicit integration control.
    float footprint=max((t+random*step)*cone,1.f);
    float lod=clamp(log2(max(footprint*scattering.w/min(CloudFormationScale*appearance.z,2800.f),1.f)),0.f,4.f);
    float sample_density=CloudDensity(p,(uint)scattering.y,lod,footprint);
    float sigma=Extinction*sample_density;
    if(sigma>0.f) {
      float tau=0.f;
      float2 light_interval=CloudInterval(p,direction);
      bool enhanced=scattering.w>64.f;
      float light_distance=max(light_interval.y,0.f);
      float light_scale=log2(1.f+light_distance/24.f);
      [loop]for(uint j=0;j<(uint)integration.y;++j) {
        // Resolve the first two nearby segments against eroded density so
        // billows can shade their neighbours. The coarse field alone hides
        // that relief. Exponential intervals still reach the actual layer exit;
        // distant light samples retain the cheaper filtered broad density.
        float begin=24.f*(exp2(light_scale*j/integration.y)-1.f);
        float end=24.f*(exp2(light_scale*(j+1.f)/integration.y)-1.f);
        float beam=max(footprint,(end-begin)*.35f);
        float light_lod=clamp(log2(max(beam*scattering.w/min(CloudFormationScale*appearance.z,2800.f),1.f)),0.f,4.f);
        tau+=CloudDensity(p+direction*((begin+end)*.5f),j<2u?1u:0u,light_lod,beam)*Extinction*(end-begin);
      }
      float opacity=SegmentOpacity(sigma*step);
      float contribution=transmission*opacity;
      float direct=phases.x*exp(-tau),attenuation=1.f;
      [unroll]for(uint octave=1;octave<4;++octave) {
        attenuation*=.5f;
        if(octave<=(uint)scattering.x)direct+=phases[octave]*exp(-tau*attenuation);
      }
      // High and above evaluate heterogeneous skylight occlusion rather than
      // assuming this point's density fills the entire upward column.
      float sky_tau=Extinction*sample_density*(CloudBase+CloudThickness()-CloudAltitude(p));
      if(enhanced) {
        float sky_distance=CloudInterval(p,float3(0,0,1)).y;
        sky_tau=0.f;
        [unroll]for(uint k=0;k<3;++k)
          sky_tau+=Extinction*CloudDensity(p+float3(0,0,sky_distance*(k+.5f)/3.f),0u,2.f)*(sky_distance/3.f);
      }
      float3 source=.98f*(max(light[1].rgb,0.f)*direct
          +ambient*exp(-max(0.f,sky_tau)*.5f));
      radiance+=contribution*source;
      weighted_depth+=contribution*(t+random*step);weight+=contribution;
      transmission*=1.f-opacity;
    }
    t+=step;
  }
  float depth=weight>1.e-5f ? weighted_depth/weight : .5f*(interval.x+interval.y);
  radiance*=ClassicCloudBrightness(asuint(frame[184].w));
  // Aerial perspective uses the native sky as the distant incident radiance.
  // This is path attenuation, not an extra additive cloud-brightness term.
  float directional=saturate((frame[42].x+dot(ray,frame[38].xyz))/max(1.f+frame[42].x,.0001f));
  float falloff=max(0.f,lerp(frame[44].z,frame[44].y,directional));
  float air_transmission=FogLightTransmittance(frame[0].z+frame[42].y,ray.z,max(frame[44].x,0.f)*atmosphere.x,falloff,depth);
  float cosine=dot(ray,frame[38].xyz);
  float3 air=lerp(frame[40].rgb,cosine>0.f ? frame[39].rgb : frame[41].rgb,
      cosine*cosine*saturate(frame[42].z*.002f-.3f));
  radiance=lerp(max(air,0.f)*(1.f-transmission),radiance,air_transmission);
  // Foreground fog lighting is composed after cloud temporal reconstruction.
  // It belongs to the camera/world, not to the animated cloud history.
  result[id.xy]=float4(radiance,transmission);
  cloud_depth[id.xy]=depth;
}
