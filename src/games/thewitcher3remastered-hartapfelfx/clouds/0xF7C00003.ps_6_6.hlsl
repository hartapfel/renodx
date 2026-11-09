// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "common.hlsli"
#include "reconstruction.hlsli"
#include "storage.hlsli"
Texture2D<float4> current_cloud : register(t3);
Texture2D<float> current_depth : register(t4);
Texture2D<float4> history_cloud : register(t5);
Texture2D<float> history_depth : register(t6);
RWTexture2D<float4> resolved : register(u0);
RWTexture2D<float> resolved_depth : register(u1);
RWTexture2D<float4> cloud_motion : register(u2);
void main(float4 position : SV_Position) {
  uint3 id = uint3(uint2(position.xy), 0);
  if(any(id.xy>=uint2(dimensions.xy)) || CloudAlreadyRendered())return;
  float4 current=CloudDecode(current_cloud.Load(int3(id.xy,0)));
  float depth=current_depth.Load(int3(id.xy,0));
  float2 trace_uv=(float2(id.xy)+.5f)/dimensions.xy;
  float3 ray=CloudRay(trace_uv);
  float surface_distance=CloudSceneDistance(trace_uv*dimensions.zw,ray);
  cloud_motion[id.xy]=float4(0,0,1.f-current.a,0);
  resolved_depth[id.xy]=depth;
  if(integration.w==0.f) {resolved[id.xy]=CloudEncode(current);return;}
  if(depth<=0.f) {
    // A single primary ray can miss a thin edge on one frame and hit it on
    // the next. Use adjacent cloud depths to reproject that edge instead of
    // dropping its history at every miss. Empty sky exits after four reads.
    float support=0.f,count=0.f;
    [unroll]for(uint axis=0;axis<2;++axis)[unroll]for(int side=-1;side<=1;side+=2) {
      int2 offset=axis==0?int2(side,0):int2(0,side);
      int2 pixel=clamp(int2(id.xy)+offset,0,int2(dimensions.xy)-1);
      float candidate=current_depth.Load(int3(pixel,0));
      if(candidate>0.f &&candidate<surface_distance) {support+=candidate;count+=1.f;}
    }
    if(count==0.f) {resolved[id.xy]=CloudEncode(current);return;}
    depth=support/count;
    resolved_depth[id.xy]=depth;
  }
  float3 p=frame[0].xyz+ray*depth;
  // The macro weather field and shape noise share this native wind advection.
  p.xy+=CloudWindOffset(frame[67].xy-previous[67].xy);
  float elapsed=cloud_clock.x-previous_cloud_clock.x;
  p.z+=elapsed*.6f;
  float4 view=p.x*previous[1]+p.y*previous[2]+p.z*previous[3]+previous[4];
  float4 clip=view.x*previous[13]+view.y*previous[14]+view.z*previous[15]+view.w*previous[16];
  float2 projected_uv=clip.xy/max(clip.w,1.e-6f)*float2(.5f,-.5f)+.5f;
  float2 uv=projected_uv;
  bool valid=all(isfinite(clip)) &&clip.w>0.f &&all(uv>0.f)&&all(uv<1.f)
      &&length(frame[0].xyz-previous[0].xyz)<100.f
      &&length(frame[67].xy-previous[67].xy)<10.f;
  // Weather coverage/profile already fade in the shared control field. Native
  // ID rollover does not change that field's meaning and must not discard a
  // converged image. Current-depth, opacity and radiance tests reject changes.
  valid=valid &&isfinite(elapsed) &&elapsed>=0.f &&elapsed<1.f;
  float old_depth=history_depth.SampleLevel(clamp_sampler,uv,0);
  valid=valid &&old_depth>0.f &&abs(old_depth-length(p-previous[0].xyz))<max(100.f,depth*.15f);
  // A previously visible cloud must not survive a mountain disocclusion.
  float3 surface=frame[0].xyz+ray*surface_distance;
  valid=valid &&depth<surface_distance &&old_depth<length(surface-previous[0].xyz);
  valid = valid && identity.x == previous_identity.x
      && all(dimensions == previous_dimensions) && all(integration.xy == previous_integration.xy)
      && all(appearance == previous_appearance) && all(atmosphere == previous_atmosphere)
      && all(scattering.xyw == previous_scattering.xyw);
  float2 motion=projected_uv-trace_uv
      -(previous[15].xy-frame[15].xy)*float2(.5f,-.5f);
  float4 lower=current,upper=current;
  const float3 luminance=float3(.2126f,.7152f,.0722f);
  float mean=0.f,second_moment=0.f,count=0.f;
  float transmission_mean=0.f,transmission_second=0.f;
  float3 radiance_sum=0.f;
  float radiance_weight=0.f;
  float transmission_sum=0.f;
  float transmission_weight=0.f;
  [unroll]for(int y=-1;y<=1;++y)[unroll]for(int x=-1;x<=1;++x) {
    int2 pixel=clamp(int2(id.xy)+int2(x,y),0,int2(dimensions.xy)-1);
    float neighbor_depth=current_depth.Load(int3(pixel,0));
    if(neighbor_depth>0.f &&neighbor_depth<surface_distance) {
      float4 value=CloudDecode(current_cloud.Load(int3(pixel,0)));lower=min(lower,value);upper=max(upper,value);
      float luma=dot(max(value.rgb,0.f),luminance);
      mean+=luma;second_moment+=luma*luma;count+=1.f;
      transmission_mean+=value.a;transmission_second+=value.a*value.a;
      // Filter lighting within the same cloud surface. Transmission and depth
      // keep bright sky gaps and foreground silhouettes from bleeding inward.
      float spatial=(x==0?2.f:1.f)*(y==0?2.f:1.f);
      float depth_distance=abs(neighbor_depth-depth)/max(150.f,depth*.12f);
      float similarity=exp2(-12.f*abs(value.a-current.a)-depth_distance);
      float weight=spatial*similarity;
      radiance_sum+=value.rgb*weight;
      radiance_weight+=weight;
      float alpha_weight=spatial*exp2(-8.f*abs(value.a-current.a)-depth_distance);
      transmission_sum+=value.a*alpha_weight;
      transmission_weight+=alpha_weight;
    }
  }
  current.rgb=lerp(current.rgb,radiance_sum/max(radiance_weight,1.e-5f),.75f);
  // Primary-ray jitter is most visible in partially covered edge pixels.
  // Denoise transmission separately, with a tighter depth/opacity gate than
  // an ordinary blur, so the large cloud silhouette stays weather-driven.
  current.a=lerp(current.a,transmission_sum/max(transmission_weight,1.e-5f),.8f);
  float4 old=CloudDecode(ReconstructCloud(history_cloud,clamp_sampler,uv,dimensions.xy));
  old=clamp(old,lower,upper);
  // Lighting/weather and Darker Nights changes invalidate only their history.
  // Opacity alone cannot detect changing detail inside an opaque cloud. Keep
  // stable history, but respond to radiance changes and camera/wind motion
  // instead of dragging a soft colour patch across the evolving density.
  float difference=abs(current.a-old.a);
  mean/=max(count,1.f);
  float deviation=sqrt(max(0.f,second_moment/max(count,1.f)-mean*mean));
  transmission_mean/=max(count,1.f);
  float transmission_deviation=sqrt(max(0.f,transmission_second/max(count,1.f)-transmission_mean*transmission_mean));
  // Judge changes relative to the local HDR signal, allowing the neighborhood's
  // sampling variation to converge. A fixed RGB threshold rejected dark noise
  // and bright noise differently. Keep accumulation linear and hue preserving;
  // reciprocal-luminance weighting would bias steady cloud energy downward.
  float smooth_region=1.f-saturate(deviation/max(mean,1.e-4f)*10.f);
  float change=max(0.f,abs(dot(current.rgb-old.rgb,luminance))-2.f*deviation)/max(mean+deviation,1.e-4f);
  // Transmission is stochastic too. Comparing one noisy sample against the
  // converged history rejected precisely the thin gaps that expose bright HDR
  // sky. Allow measured neighborhood variance, while the existing min/max
  // clip removes stale history from genuinely opened/closed gaps immediately.
  float transmission_change=max(0.f,difference-2.5f*transmission_deviation);
  float history_weight=lerp(.88f,.94f,smooth_region)*(1.f-saturate(transmission_change*4.f))
      /((1.f+2.f*change)*(1.f+.25f*length(motion*dimensions.xy)));
  float4 filtered=lerp(current,old,valid?history_weight:0.f);
  resolved[id.xy]=CloudEncode(filtered);
  // The upscaler must see the same opacity/confidence as the resolved cloud.
  // Feeding raw noisy opacity here marked stable gaps responsive every frame,
  // discarding the downstream history that should reconstruct their detail.
  cloud_motion[id.xy]=float4(valid ? motion : 0.f,1.f-filtered.a,valid &&transmission_change<.025f ? 1.f : 0.f);
}
