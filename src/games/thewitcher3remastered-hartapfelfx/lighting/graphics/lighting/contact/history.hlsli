// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Remastered adapter of the Classic contact pipeline; see THIRD_PARTY.md.
Texture2D<float> depth_texture:register(t0);
Texture2D<float4> material_texture:register(t2);
Texture2D<uint2> stencil_texture:register(t3);
Texture2D<float2> current_mask:register(t4);
Texture2D<float2> history_mask:register(t5);
ByteAddressBuffer previous:register(t6);
float4 ContactPrevious(uint row) { return asfloat(previous.Load4(row * 16u)); }
Texture2D<float4> object_motion:register(t7);
Texture2D<float> object_depth:register(t8);
cbuffer MotionCamera:register(b9){float4 motion_camera[54];}
cbuffer History:register(b11){float4 history_control;}
cbuffer Frame:register(b12){float4 cb12[341];}
cbuffer Light:register(b13){float4 cb13[3589];}
#include "material.hlsli"
#include "native_motion.hlsli"
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
  if(dot(cb12[0].xyz-ContactPrevious(0u).xyz,cb12[0].xyz-ContactPrevious(0u).xyz)>9.f
      ||dot(float3(cb12[1].z,cb12[2].z,cb12[3].z),float3(ContactPrevious(1u).z,ContactPrevious(2u).z,ContactPrevious(3u).z))<.7071f
      ||abs(cb12[13].x-ContactPrevious(13u).x)>max(.01f,abs(cb12[13].x)*.05f)
      ||abs(cb12[14].y-ContactPrevious(14u).y)>max(.01f,abs(cb12[14].y)*.05f)
      ||any(cb12[23].xy!=ContactPrevious(23u).xy)
      ||dot(cb13[0].xyz,ContactPrevious(341u).xyz)<.999f
      ||any(RenoLighting[0]!=ContactPrevious(342u)))return;
  float raw=depth_texture.Load(int3(id.xy,0));
  uint material=(uint)(saturate(material_texture.Load(int3(id.xy,0)).w)*255.f+.5f);
  if(!ContactReceiver(material)||raw*cb12[22].x+cb12[22].y>=1.f)return;
  float4 world=cb12[211]*id.x+cb12[212]*id.y+cb12[213]*raw+cb12[214];
  if(!all(isfinite(world))||abs(world.w)<1.e-7f)return;
  world.xyz/=world.w;
  float3 view=world.x*ContactPrevious(1u).xyz+world.y*ContactPrevious(2u).xyz+world.z*ContactPrevious(3u).xyz+ContactPrevious(4u).xyz;
  float4 clip=view.x*ContactPrevious(13u)+view.y*ContactPrevious(14u)+view.z*ContactPrevious(15u)+ContactPrevious(16u);
  if(!all(isfinite(clip))||clip.w<=.01f)return;
  float2 history_uv=clip.xy/clip.w*float2(.5f,-.5f)+.5f;
  uint2 motion_size;object_depth.GetDimensions(motion_size.x,motion_size.y);
  float motion_z=all(motion_size>=size)?object_depth.Load(int3(id.xy,0)):-2.f;
  bool object_hit=abs(motion_z)<=1.f && abs(abs(motion_z)-raw)<=2.e-7f;
  float4 encoded_motion=object_hit?object_motion.Load(int3(id.xy,0)):0.f;
  if(history_control.y!=0.f) {
    float4x4 expected=transpose(mul(float4x4(cb12[1],cb12[2],cb12[3],float4(0,0,0,1)),
        float4x4(cb12[13],cb12[14],cb12[15],cb12[16])));
    if(abs(cb12[22].x)<1.e-7f)return;
    expected[2]=(expected[2]-cb12[22].y*expected[3])/cb12[22].x;
    bool matching=all(isfinite(motion_camera[36].xyz)) && all(abs(motion_camera[36].xyz-cb12[0].xyz)<.002f);
    [unroll]for(uint row=0;row<4;++row)
      matching=matching && all(isfinite(motion_camera[45+row]))
          && all(abs(motion_camera[45+row]-expected[row])<1.e-5f*max(1.f,abs(expected[row])));
    object_hit=object_hit && matching && encoded_motion.w==1.f;
  }
  float previous_depth=view.z;
  if(object_hit) {
    // The native-motion adapter supplies previous-minus-current UV motion,
    // excluding jitter, and a signed raw-depth validity record. No geometry
    // replay is used; unproven/missing native vectors must invalidate this input.
    float2 motion=encoded_motion.xy;
    if(history_control.y!=0.f) {
      float3 decoded=ContactNativeMotion(encoded_motion,raw,cb12[21].xy,cb12[22].xy);
      if(decoded.z<=0.f)return;
      motion=decoded.xy;previous_depth=decoded.z;
    }
    if((asuint(motion_z)&0x80000000u)!=0u||!all(isfinite(motion))||any(abs(motion)>1.f))return;
    history_uv=(id.xy+.5f)/size+motion+(ContactPrevious(15u).xy-cb12[15].xy)*float2(.5f,-.5f);
  } else if((stencil_texture.Load(int3(id.xy,0)).y&66u)!=0u || (material&1u)!=0u) {
    // Without validated native vectors, do not reuse camera-only history on
    // characters or vegetation. That would drag faces or wind-animated foliage
    // through old shadows. Spatially filtered current visibility remains valid.
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
    w*=saturate(1.f-abs(sample.y-previous_depth)/max(.01f,.01f*previous_depth));
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
