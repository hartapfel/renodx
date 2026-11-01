// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "common.hlsli"
#include "reconstruction.hlsli"
Texture2D<float4> current_cloud : register(t3);
Texture2D<float> current_depth : register(t4);
Texture2D<float4> history_cloud : register(t5);
Texture2D<float> history_depth : register(t6);
RWTexture2D<float4> resolved : register(u0);
RWTexture2D<float> resolved_depth : register(u1);
RWTexture2D<float4> cloud_motion : register(u2);
[numthreads(8,8,1)]
void main(uint3 id:SV_DispatchThreadID) {
  if(any(id.xy>=uint2(dimensions.xy)))return;
  float4 current=current_cloud.Load(int3(id.xy,0));
  float depth=current_depth.Load(int3(id.xy,0));
  cloud_motion[id.xy]=float4(0,0,1.f-current.a,0);
  resolved_depth[id.xy]=depth;
  if(depth<=0.f ||integration.w==0.f) {resolved[id.xy]=current;return;}
  float3 p=frame[0].xyz+CloudRay((id.xy+.5f)/dimensions.xy)*depth;
  // The macro weather field and shape noise share this native wind advection.
  p.xy+=20.f*(frame[67].xy-previous[67].xy);
  float elapsed=cloud_clock.x-previous_cloud_clock.x;
  p.z+=elapsed*.6f;
  float4 view=p.x*previous[1]+p.y*previous[2]+p.z*previous[3]+previous[4];
  float4 clip=view.x*previous[13]+view.y*previous[14]+view.z*previous[15]+view.w*previous[16];
  float2 uv=clip.xy/max(clip.w,1.e-6f)*float2(.5f,-.5f)+.5f;
  bool valid=all(isfinite(clip)) &&clip.w>0.f &&all(uv>0.f)&&all(uv<1.f)
      &&length(frame[0].xyz-previous[0].xyz)<100.f
      &&distance(frame[68].xy,previous[68].xy)<.1f
      &&abs(frame[66].w-previous[66].w)<.1f
      &&length(frame[67].xy-previous[67].xy)<10.f;
  valid=valid &&isfinite(elapsed) &&elapsed>=0.f &&elapsed<1.f;
  float old_depth=history_depth.SampleLevel(clamp_sampler,uv,0);
  valid=valid &&old_depth>0.f &&abs(old_depth-length(p-previous[0].xyz))<max(100.f,depth*.15f);
  float4 lower=current,upper=current;
  const float3 luminance=float3(.2126f,.7152f,.0722f);
  float mean=0.f,second_moment=0.f,count=0.f;
  [unroll]for(int y=-1;y<=1;++y)[unroll]for(int x=-1;x<=1;++x) {
    int2 pixel=clamp(int2(id.xy)+int2(x,y),0,int2(dimensions.xy)-1);
    if(current_depth.Load(int3(pixel,0))>0.f) {
      float4 value=current_cloud.Load(int3(pixel,0));lower=min(lower,value);upper=max(upper,value);
      float luma=dot(max(value.rgb,0.f),luminance);
      mean+=luma;second_moment+=luma*luma;count+=1.f;
    }
  }
  float4 old=ReconstructCloud(history_cloud,clamp_sampler,uv,dimensions.xy);
  old=clamp(old,lower,upper);
  // Lighting/weather and Darker Nights changes invalidate only their history.
  valid=valid &&asuint(frame[184].w)==asuint(previous[184].w);
  // Opacity alone cannot detect changing detail inside an opaque cloud. Keep
  // stable history, but respond to radiance changes and camera/wind motion
  // instead of dragging a soft colour patch across the evolving density.
  float difference=abs(current.a-old.a);
  mean/=max(count,1.f);
  float deviation=sqrt(max(0.f,second_moment/max(count,1.f)-mean*mean));
  // Judge changes relative to the local HDR signal, allowing the neighborhood's
  // sampling variation to converge. A fixed RGB threshold rejected dark noise
  // and bright noise differently. Keep accumulation linear and hue preserving;
  // reciprocal-luminance weighting would bias steady cloud energy downward.
  float smooth_region=1.f-saturate(deviation/max(mean,1.e-4f)*10.f);
  float change=max(0.f,abs(dot(current.rgb-old.rgb,luminance))-2.f*deviation*smooth_region)/max(mean,1.e-4f);
  float2 motion=uv-(id.xy+.5f)/dimensions.xy
      -(previous[15].xy-frame[15].xy)*float2(.5f,-.5f);
  float history_weight=lerp(.8f,.9f,smooth_region)*(1.f-saturate(difference*8.f))
      /((1.f+2.f*change)*(1.f+.25f*length(motion*dimensions.xy)));
  resolved[id.xy]=lerp(current,old,valid?history_weight:0.f);
  cloud_motion[id.xy]=float4(valid ? motion : 0.f,1.f-current.a,valid &&difference<.025f ? 1.f : 0.f);
}
