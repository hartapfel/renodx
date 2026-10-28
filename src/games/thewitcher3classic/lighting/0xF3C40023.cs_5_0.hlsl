// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
Texture2D<float4> normal_texture:register(t1);
Texture2D<float2> current_mask:register(t4);
cbuffer Frame:register(b12){float4 cb12[214];}
#include "parameters.hlsli"
RWTexture2D<float2> filtered_mask:register(u0);
[numthreads(8,8,1)]
void main(uint3 id:SV_DispatchThreadID) {
  uint2 size=min(RenoLighting[2].zw,cb12[23].xy);
  if(any(id.xy>=size))return;
  float2 center=current_mask.Load(int3(id.xy,0));
  float3 normal=normal_texture.Load(int3(id.xy,0)).xyz-.5f;
  normal*=rsqrt(max(dot(normal,normal),1.e-8f));
  float total=0.f,weight=0.f;
  [unroll]for(int y=-1;y<=1;++y)[unroll]for(int x=-1;x<=1;++x) {
    int2 position=int2(id.xy)+int2(x,y);
    if(any(position<0)||any(position>=int2(size)))continue;
    float2 neighbor=current_mask.Load(int3(position,0));
    float3 neighbor_normal=normal_texture.Load(int3(position,0)).xyz-.5f;
    neighbor_normal*=rsqrt(max(dot(neighbor_normal,neighbor_normal),1.e-8f));
    float w=exp2(-abs(neighbor.y-center.y)/max(.01f,.01f*center.y))
        *pow(saturate(dot(normal,neighbor_normal)),8.f);
    w*=float((x==0?2:1)*(y==0?2:1));
    total+=neighbor.x*w;weight+=w;
  }
  // Filter the current observations before temporal reprojection and clamping.
  // Keep center depth intact so silhouettes retain their history rejection.
  filtered_mask[id.xy]=float2(weight>0.f?total/weight:center.x,center.y);
}
