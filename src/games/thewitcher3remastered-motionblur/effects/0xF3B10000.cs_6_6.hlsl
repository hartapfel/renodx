// Classic optical motion filter, adapted to native Remastered DX12 bindings.
// Copyright (c) 2026 LoreanXavier / Hartapfel. MIT: LICENSE.optics.
#include "motion_depth.hlsli"
#ifdef WITCHER_MOTION_TEST
#define PRIVATE
#else
#define PRIVATE , space57
#endif
cbuffer Settings : register(b0 PRIVATE) {
  float interval, strength; uint mode, stage;
  uint2 output_bound, motion_bound;
  uint source_offset, target_offset, second_offset, bake_offset;
  uint2 source_bound, target_bound;
  uint velocity_offset, neighbor_offset; uint2 reserved;
};
#ifndef WITCHER_MOTION_TEST
// Both native resolve variants bound their writes using c5.xy + 1. Use the
// active viewport, never the larger pooled allocation or rounded group count.
cbuffer NativeResolve : register(b0) { float2 native_last_pixel : packoffset(c5.x); };
#endif
Texture2D<float4> Color : register(t1);
Texture2D<float4> Motion : register(t2);
SamplerState LinearClamp : register(s0 PRIVATE);
RWTexture2D<float4> Result : register(u0);
#ifdef WITCHER_MOTION_TEST
RWStructuredBuffer<float4> Scratch : register(u1);
#else
RWStructuredBuffer<float4> Scratch : register(u0, space57);
#endif
float3 Finite(float3 c) { return clamp(float3(isfinite(c.x) ? c.x : 0.f, isfinite(c.y) ? c.y : 0.f, isfinite(c.z) ? c.z : 0.f), -65504.f, 65504.f); }
float Inverse(float x) { return x != 0.f ? rcp(x) : 1e30f; }
// Classic's intermediate render targets are RGBA16F. Preserve that rounding.
float4 Half(float4 c) { return f16tof32(f32tof16(c)); }
float4 Load(uint offset, uint2 size, int2 p) {
  p=clamp(p,0,int2(size)-1);
  return Scratch[offset+uint(p.y)*size.x+uint(p.x)];
}
float4 Point(uint offset,uint2 size,float2 uv) { return Load(offset,size,int2(floor(uv*size))); }
float4 Linear(uint offset,uint2 size,float2 uv) {
  float2 p=uv*size-.5f,f=frac(p); int2 base=int2(floor(p));
  return lerp(lerp(Load(offset,size,base),Load(offset,size,base+int2(1,0)),f.x),
              lerp(Load(offset,size,base+int2(0,1)),Load(offset,size,base+1),f.x),f.y);
}
[numthreads(8,8,1)]
void main(uint3 dispatch : SV_DispatchThreadID) {
  uint2 pixel=dispatch.xy, output_size, motion_size=uint2(Scratch[1].xy);
  Result.GetDimensions(output_size.x,output_size.y);
  output_size=min(output_size,output_bound);
#ifndef WITCHER_MOTION_TEST
  output_size=min(output_size,uint2(native_last_pixel+1.f));
#endif
  uint2 color_size; Color.GetDimensions(color_size.x,color_size.y);
  output_size=min(output_size,color_size);
  uint2 native_motion_size; Motion.GetDimensions(native_motion_size.x,native_motion_size.y);
  motion_size=min(motion_size,native_motion_size);
  if(any(motion_size==0u)||any(motion_size>motion_bound)) return;
  uint2 half_size=(output_size+1u)/2u;
  uint2 target_size=stage==0u?motion_size:stage<=5u?(motion_size+(1u<<stage)-1u)>>stage:
                    stage==6u?(motion_size+31u)/32u:stage==11u?output_size:half_size;
  if(any(pixel>=target_size)) return;
  float2 uv=(float2(pixel)+.5f)/target_size;
  float scale=.5f*(strength/60.f)/max(interval,.0001f);
  float4 value=0.f;
  if(stage==0u) {
    float2 sample_uv=clamp(uv,.5f/motion_size,1.f-.5f/motion_size);
    float4 motion=Motion.Load(int3(int2(sample_uv*motion_size),0));
    float2 velocity=motion.xy;
    if(mode==1u) {
      // Remastered supplies the combined field and current->previous camera
      // reprojection, not Classic's previous object positions. Preserve the
      // validated native camera subtraction and visible-trajectory partition.
      float2 ndc=float2(uv.x*2.f-1.f,1.f-uv.y*2.f);
      float depth=UnpackMotionDepth(motion.zw);
      float3 previous=Scratch[2].xyw*ndc.x;
      previous=mad(Scratch[3].xyw,ndc.y,previous);
      previous=mad(Scratch[4].xyw,depth,previous)+Scratch[5].xyw;
      if(abs(previous.z)>1e-8f && all(isfinite(previous))) {
        float2 camera=-(uv-.5f-previous.xy*float2(.5f,-.5f)/previous.z);
        camera=f16tof32(f32tof16(camera));
        float screen_speed=length(velocity*output_size);
        float object_speed=length((velocity-camera)*output_size);
        velocity*=saturate(object_speed/max(screen_speed,1e-8f));
      } else velocity=0.f;
    }
    velocity*=float2(1920.f,1080.f)/128.f;
    float len=length(velocity);
    velocity*=len>0.f?min(1.f,min(1.f,interval*30.f)/max(len,1e-8f)):0.f;
    if(mode==2u || interval<=0.f || !all(isfinite(velocity))) velocity=0.f;
    value=float4(0,0,velocity);
  } else if(stage<=6u) {
    uint2 source_size=stage==6u?target_size:(motion_size+(1u<<(stage-1u))-1u)>>(stage-1u);
    float2 best=0; float best_len=0;
    int2 base=stage==6u?int2(pixel):int2(pixel)*2;
    [loop] for(int y=stage==6u?-1:0;y<2;++y) [loop] for(int x=stage==6u?-1:0;x<2;++x) {
      float2 v=Load(source_offset,source_size,base+int2(x,y)).zw;
      if(dot(v,v)>best_len) {best_len=dot(v,v);best=v;}
    }
    value=float4(0,0,best);
  } else if(stage==7u) {
    // Native converted vectors and depth share the same grid. Their existing
    // reprojection already includes the game's jitter convention.
    float2 velocity=Point(velocity_offset,motion_size,uv).zw;
    float2 tile=Point(neighbor_offset,(motion_size+31u)/32u,uv).zw;
    float2 scaled=64.f*velocity*scale;
    float raw=UnpackMotionDepth(Motion.Load(int3(min(uint2(uv*motion_size),motion_size-1u),0)).zw);
    float4 projection=Scratch[0];
    float z=min(65000.f,rcp(max((raw*projection.z+projection.w)*projection.x+projection.y,1e-5f)));
    value=float4(.015625f*sqrt(1e-7f+dot(scaled,scaled)),z,dot(tile,tile)>=dot(velocity,velocity)?tile:velocity);
  } else if(stage==8u) {
    value=float4(Finite(Color.SampleLevel(LinearClamp,uv*float2(output_size)/color_size,0).rgb),1);
  } else if(stage==9u || stage==10u) {
    float pass_scale=stage==9u?1.f:1.f/6.f;
    float4 center_vd=Point(bake_offset,half_size,uv);
    float2 dir=float2(.033333335f,.05925926f)*scale*center_vd.zw*pass_scale;
    const float switch_on=1.0623588e-3f;
    float full=length(dir)/max(pass_scale,1e-6f);
    float kept=full*smoothstep(.5f*switch_on,1.5f*switch_on,full);
    dir*=full>0.f?kept/full:0.f;
    float4 center=Point(source_offset,half_size,uv);
    if(kept<=0.f) value=float4(center.rgb,stage==9u?0.f:center.a);
    else {
      int taps=2*int(clamp(ceil(length(dir*half_size)*.5f),8.f,24.f))+1;
      int middle=taps/2;
      float2 position=float2(pixel)+.5f;
      float jitter=frac(52.9829189f*frac(.06711056f*position.x+.00583715f*position.y))-.5f;
      float2 step=dir/(taps-1),start=step*(jitter-middle)+uv;
      float zc=center_vd.y,inv_c=Inverse(center_vd.x);
      float weight=4.f*(taps-1)/6.f;
      float3 sum=weight*center.rgb;
      [loop] for(int k=0;k<taps;++k) if(k!=middle) {
        float2 suv=k*step+start;
        float4 s_vd=Point(bake_offset,half_size,suv);
        float3 s=Linear(source_offset,half_size,suv).rgb;
        float d=.015625f*length((suv-uv)*float2(1920.f,1080.f));
        float zs=s_vd.y;
        float cone_s=1.f-d*Inverse(s_vd.x),cone_c=1.f-d*inv_c;
        float front=saturate(1.f+(zc-zs)/max(.01f*min(zc,zs),1e-4f));
        float back=saturate(1.f+(zs-zc)/max(.01f*min(zc,zs),1e-4f));
        float w=2.f*saturate(cone_s+.95f)*saturate(cone_c+.95f)+front*saturate(cone_s)+back*saturate(cone_c);
        sum+=s*w;weight+=w;
      }
      float alpha=saturate(.25f*weight*6.f/(taps-1)-1.2f);
      value=float4(Finite(sum/weight),stage==9u?alpha:center.a);
    }
  } else {
    float4 sharp=Color.Load(int3(pixel,0));
    float4 blur=Linear(source_offset,half_size,uv);
    Result[pixel]=float4(Finite(lerp(sharp.rgb,blur.rgb,saturate(blur.a))),sharp.a);
    return;
  }
  Scratch[target_offset+pixel.y*target_size.x+pixel.x]=Half(value);
}
