// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
Texture2D<float> depth_texture:register(t0);
Texture2D<float4> material_texture:register(t2);
Texture2D<uint2> stencil_texture:register(t3);
Texture2D<float2> current_mask:register(t4);
Texture2D<float2> history_mask:register(t5);
StructuredBuffer<float4> previous:register(t6);
Texture2D<float2> object_motion:register(t7);
Texture2D<float> object_depth:register(t8);
cbuffer History:register(b11){float4 history_control;}
cbuffer Frame:register(b12){float4 cb12[214];}
cbuffer Light:register(b13){float4 cb13[49];}
#include "contact.hlsli"
RWTexture2D<float2> output_mask:register(u0);
[numthreads(8,8,1)]
void main(uint3 id:SV_DispatchThreadID) {
  uint2 size=min(RenoLighting[2].zw,cb12[23].xy);
  if(any(id.xy>=size))return;
  float2 current=current_mask.Load(int3(id.xy,0));
  output_mask[id.xy]=current;
  if(history_control.x==0.f)return;
  // Reject camera cuts, changed projection, lighting or settings before using
  // history. All state stays on the GPU, including ranged native CB copies.
  if(dot(cb12[0].xyz-previous[0].xyz,cb12[0].xyz-previous[0].xyz)>9.f
      ||dot(float3(cb12[1].z,cb12[2].z,cb12[3].z),float3(previous[1].z,previous[2].z,previous[3].z))<.7071f
      ||abs(cb12[13].x-previous[13].x)>max(.01f,abs(cb12[13].x)*.05f)
      ||abs(cb12[14].y-previous[14].y)>max(.01f,abs(cb12[14].y)*.05f)
      ||any(cb12[23].xy!=previous[23].xy)
      ||dot(cb13[0].xyz,previous[214].xyz)<.999f
      ||any(RenoLighting[0]!=previous[215]))return;
  float raw=depth_texture.Load(int3(id.xy,0));
  uint material=(uint)(saturate(material_texture.Load(int3(id.xy,0)).w)*255.f+.5f);
  if(!ContactReceiver(material)||raw*cb12[22].x+cb12[22].y>=1.f)return;
  float4 world=cb12[210]*id.x+cb12[211]*id.y+cb12[212]*raw+cb12[213];
  if(!all(isfinite(world))||abs(world.w)<1.e-7f)return;
  world.xyz/=world.w;
  float3 view=world.x*previous[1].xyz+world.y*previous[2].xyz+world.z*previous[3].xyz+previous[4].xyz;
  float4 clip=view.x*previous[13]+view.y*previous[14]+view.z*previous[15]+previous[16];
  if(!all(isfinite(clip))||clip.w<=.01f)return;
  float2 history_uv=clip.xy/clip.w*float2(.5f,-.5f)+.5f;
  uint2 motion_size;object_depth.GetDimensions(motion_size.x,motion_size.y);
  float motion_z=all(motion_size>=size)?object_depth.Load(int3(id.xy,0)):-2.f;
  bool object_hit=abs(motion_z)<=1.f && abs(abs(motion_z)-raw)<=2.e-7f;
  if(object_hit) {
    // Object vectors include camera motion but omit projection jitter.
    float2 motion=object_motion.Load(int3(id.xy,0));
    if((asuint(motion_z)&0x80000000u)!=0u||!all(isfinite(motion))||any(abs(motion)>1.f))return;
    history_uv=(id.xy+.5f)/size+motion+(previous[15].xy-cb12[15].xy)*float2(.5f,-.5f);
  } else if((stencil_texture.Load(int3(id.xy,0)).y&2u)!=0u) {
    // Camera-only history would drag animated faces across their old shadows.
    return;
  }
  if(any(history_uv<0.f)||any(history_uv>=1.f))return;
  // Reproject with depth-aware bilinear weights. A newly exposed surface must
  // not borrow the visibility of the foreground that covered it last frame.
  float2 position=history_uv*size-.5f;
  int2 base=int2(floor(position));float2 fraction=frac(position);
  float total=0.f,weight=0.f;
  [unroll]for(int y=0;y<2;++y)[unroll]for(int x=0;x<2;++x) {
    int2 p=base+int2(x,y);
    if(any(p<0)||any(p>=int2(size)))continue;
    float2 sample=history_mask.Load(int3(p,0));
    float w=(x?fraction.x:1.f-fraction.x)*(y?fraction.y:1.f-fraction.y);
    w*=saturate(1.f-abs(sample.y-view.z)/max(.01f,.01f*view.z));
    total+=sample.x*w;weight+=w;
  }
  if(weight<.05f)return;
  // Clamp history to current nearby visibility, following BlitzFX's shadow
  // filter. This sheds old shadows immediately when a blocker moves away.
  float low=current.x,high=current.x;
  [unroll]for(int y=-1;y<=1;++y)[unroll]for(int x=-1;x<=1;++x) {
    int2 p=int2(id.xy)+int2(x,y);
    if(any(p<0)||any(p>=int2(size)))continue;
    float2 sample=current_mask.Load(int3(p,0));
    if(abs(sample.y-current.y)>max(.01f,.01f*current.y))continue;
    low=min(low,sample.x);high=max(high,sample.x);
  }
  output_mask[id.xy]=float2(lerp(current.x,clamp(total/weight,low,high),.8f*weight),current.y);
}
