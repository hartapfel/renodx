// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "math.hlsli"
cbuffer Frame : register(b0) { float4 frame[269]; }
cbuffer Lighting : register(b1) { float4 light[3323]; }
cbuffer Parameters : register(b2) {
  float4 grid,medium,options,sampling,sky_options,temporal;
}
Texture3D<float4> current_cells : register(t0);
Texture3D<float4> history_cells : register(t8);
StructuredBuffer<float4> previous : register(t9);
StructuredBuffer<float4> previous_light : register(t10);
SamplerState clamp_sampler : register(s2);
RWTexture3D<float4> resolved : register(u0);

[numthreads(4,4,4)]
void main(uint3 id:SV_DispatchThreadID) {
  if(any(id>=(uint3)grid.xyz))return;
  float4 current=current_cells.Load(int4(id,0));
  resolved[id]=current;
  // Extinction is never accumulated: keep authored opacity/interiors current.
  if(temporal.y==0.f ||current.a<=0.f)return;
  float2 uv=(id.xy+.5f)/grid.xy;
  float2 ndc=uv*float2(2,-2)+float2(-1,1);
  float4 world_h=ndc.x*frame[17]+ndc.y*frame[18]+.5f*frame[19]+frame[20];
  float3 ray=normalize(world_h.xyz/world_h.w-frame[0].xyz);
  float distance=SliceDistance(id.z+.5f,grid.z,options.y,max(grid.w,frame[42].z));
  float3 world=frame[0].xyz+ray*distance;
  float4 view=world.x*previous[1]+world.y*previous[2]+world.z*previous[3]+previous[4];
  float4 clip=view.x*previous[13]+view.y*previous[14]+view.z*previous[15]+view.w*previous[16];
  float3 coordinate;
  coordinate.xy=clip.xy/max(clip.w,1.e-6f)*float2(.5f,-.5f)+.5f;
  float old_distance=length(world-previous[0].xyz);
  coordinate.z=log(max(old_distance,options.y)/options.y)/log(max(grid.w,previous[42].z)/options.y);
  // No edge-clamped history: newly visible cells need fresh lighting.
  float3 border=.5f/grid.xyz;
  bool valid=clip.w>0.f &&all(isfinite(coordinate)) &&all(coordinate>=border) &&all(coordinate<=1.f-border)
      &&length(frame[0].xyz-previous[0].xyz)<10.f
      &&dot(ray,normalize(world-previous[0].xyz))>.98f
      &&asuint(frame[184].w)==asuint(previous[184].w)
      &&all(abs(frame[42]-previous[42])<=.02f*max(abs(frame[42]),.001f))
      &&all(abs(frame[43]-previous[43])<=.02f*max(abs(frame[43]),.001f))
      &&all(abs(light[0].xyz-previous_light[0].xyz)<.02f)
      &&all(abs(light[1].xyz-previous_light[1].xyz)<=.05f*max(abs(light[1].xyz),1.e-5f));
  if(!valid)return;
  float4 old=history_cells.SampleLevel(clamp_sampler,coordinate,0);
  if(!all(isfinite(old)) ||old.a<=0.f ||abs(old.a-current.a)>.1f*max(old.a,current.a))return;

  // Compare source radiance, independent of density. Relative luminance bounds
  // work in dim fog and HDR shafts; blend RGB linearly, with no tonemapping or
  // inverse-luminance weighting. Seven neighboring cells bound dynamic lights.
  const float3 luma=float3(.2126f,.7152f,.0722f);
  float3 source=current.rgb/max(current.a,FogSourceFloor);
  float3 history=old.rgb/max(old.a,FogSourceFloor);
  float center=dot(source,luma),lower=center,upper=center,mean=center,second=center*center;
  float count=1.f;
  static const int3 offsets[6]={int3(-1,0,0),int3(1,0,0),int3(0,-1,0),int3(0,1,0),int3(0,0,-1),int3(0,0,1)};
  [unroll]for(uint i=0;i<6;++i) {
    int3 position=clamp(int3(id)+offsets[i],0,int3(grid.xyz)-1);
    float4 cell=current_cells.Load(int4(position,0));
    if(cell.a>0.f) {
      float value=dot(cell.rgb/max(cell.a,FogSourceFloor),luma);
      lower=min(lower,value);upper=max(upper,value);
      mean+=value;second+=value*value;count+=1.f;
    }
  }
  mean/=count;
  float deviation=sqrt(max(0.f,second/count-mean*mean));
  float old_luma=dot(history,luma);
  // Preserve chromaticity when limiting history. A newly dark neighborhood
  // clears old light immediately, including rapidly switched torches.
  history*=old_luma>0.f ? clamp(old_luma,lower,upper)/old_luma:0.f;
  float change=max(0.f,abs(center-old_luma)-2.f*deviation)/max(mean,1.e-6f);
  float chroma_change=length(source/max(center,1.e-6f)-history/max(dot(history,luma),1.e-6f));
  float3 motion=(coordinate-(id+.5f)/grid.xyz)*grid.xyz;
  float weight=.9f/((1.f+4.f*change+chroma_change)*(1.f+.25f*length(motion)));
  resolved[id]=float4(lerp(source,history,weight)*max(current.a,FogSourceFloor),current.a);
}
