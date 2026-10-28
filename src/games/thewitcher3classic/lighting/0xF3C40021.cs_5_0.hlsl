// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
Texture2D<float> depth_texture:register(t0);
Texture2D<float2> packed_texture:register(t1);
Texture2D<float4> material_texture:register(t2);
Texture2D<uint2> stencil_texture:register(t3);
cbuffer Frame:register(b12){float4 cb12[214];}
cbuffer Light:register(b13){float4 cb13[49];}
#include "contact.hlsli"
RWTexture2D<float2> contact_output:register(u0);
[numthreads(8,8,1)]
void main(uint3 id:SV_DispatchThreadID) {
  float2 size=min(RenoLighting[2].zw,cb12[23].xy);
  if(any(id.xy>=uint2(size)))return;
  float2 packed=packed_texture.Load(int3(id.xy,0));
  contact_output[id.xy]=float2(1.f,min(packed.x,65504.f));
  uint material=(uint)(saturate(material_texture.Load(int3(id.xy,0)).w)*255.f+.5f);
  float raw=depth_texture.Load(int3(id.xy,0));
  if(!ContactReceiver(material)||raw*cb12[22].x+cb12[22].y>=1.f)return;
  uint stencil=stencil_texture.Load(int3(id.xy,0)).y;
  float3 normal=float3((asuint(packed.y)>>uint3(8,16,24))&255u)/255.f-.5f;
  normal*=rsqrt(max(dot(normal,normal),1.e-8f));
  float no_l=dot(normal,cb13[0].xyz);
  bool character=(stencil&2u)!=0u,grass=(material&1u)!=0u,tree=(material&8u)!=0u;
  if(no_l<0.f && !character && !grass && !tree && (asuint(packed.y)&255u)!=0u)return;
  float4 world=cb12[210]*id.x+cb12[211]*id.y+cb12[212]*raw+cb12[213];
  world.xyz/=world.w;
  if(grass)world.xyz+=cb13[0].xyz*.07f;
  if(tree) {
    float3 to_camera=normalize(cb12[0].xyz-world.xyz);
    world.xyz+=to_camera*max(0.f,dot(-to_camera.xy,cb13[0].xy)*2.f-1.f)*3.f;
  }
  float3 view=world.x*cb12[1].xyz+world.y*cb12[2].xyz+world.z*cb12[3].xyz+cb12[4].xyz;
  float3 direction=cb13[0].x*cb12[1].xyz+cb13[0].y*cb12[2].xyz+cb13[0].z*cb12[3].xyz;
  float reach=CONTACT_LENGTH;
  if(direction.z<0.f)reach=min(reach,max(0.f,(view.z-.01f)/-direction.z));
  float3 end=view+direction*reach;
  float4 a=view.x*cb12[13]+view.y*cb12[14]+view.z*cb12[15]+cb12[16];
  float4 b=end.x*cb12[13]+end.y*cb12[14]+end.z*cb12[15]+cb12[16];
  if(a.w<=.01f||b.w<=.01f)return;
  float2 start=(a.xy/a.w*float2(.5f,-.5f)+.5f)*size;
  float2 finish=(b.xy/b.w*float2(.5f,-.5f)+.5f)*size;
  float2 ray_uv=(finish-start)/size;
  float extent=length(ray_uv);
  if(extent<1.e-6f)return;
  // BlitzFX uses 16 taps at a fixed normalized screen-space spacing. Never
  // stretch a fixed tap count over the requested world reach: that produces
  // regularly repeated silhouettes, especially in close-up camera shots.
  float step_t=(6.f*size.y/(1920.f*size.x))/extent;
  // Static spatial decorrelation, as in BlitzFX (no frame rotation/history).
  // IGN avoids an extra texture binding and distributes offsets in a 3x3 area.
  float noise=frac(52.9829189f*frac(dot(float2(id.xy),float2(.06711056f,.00583715f))));
  float offset=noise+(tree?-.5f:.5f);
  float bias_scale=character?.1f:.2f+.8f*(1.f-saturate(no_l));
  float bias=(tree?.0005f:.003f)*bias_scale;
  float visibility=1.f;
  [unroll]for(uint i=0;i<16u;++i) {
    float t=(float(i)+offset)*step_t;
    if(t>1.f)break;
    if(t<=0.f)continue;
    float2 position=lerp(start,finish,t);
    if(any(position<0.f)||any(position>=size))break;
    if(all(int2(position)==int2(id.xy)))continue;
    float z=rcp(lerp(rcp(view.z),rcp(end.z),t));
    float2 sample_data=packed_texture.Load(int3(int2(position),0));
    float opacity=float(asuint(sample_data.y)&255u)/255.f;
    float delta=z*(1.f-bias)-sample_data.x;
    float thickness=min(.04f+z*.008f,character?.1f:4.f);
    float hit=saturate(delta*400.f)*saturate((thickness-delta)*400.f)*opacity;
    float edge=saturate(min(min(position.x,position.y),min(size.x-position.x,size.y-position.y))/8.f);
    visibility=min(visibility,1.f-hit*edge*(1.f-smoothstep(.85f,1.f,t)));
  }
  contact_output[id.xy]=float2(visibility,min(packed.x,65504.f));
}
