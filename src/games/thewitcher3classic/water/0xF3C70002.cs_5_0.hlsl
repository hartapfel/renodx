// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Reflection history belongs to the virtual reflected scene, not the water
// receiver. Keep this motion private: refraction and surface motion differ.
Texture2D<float4> current_color : register(t0);
Texture2D<float2> current_guide : register(t1);
Texture2D<float4> history_color : register(t2);
Texture2D<float2> history_guide : register(t3);
StructuredBuffer<float4> frame : register(t4);
StructuredBuffer<float4> previous_frame : register(t5);
Texture2D<float4> native_padding : register(t6);
SamplerState linear_clamp : register(s0);
RWTexture2D<float4> result : register(u0);
cbuffer Controls : register(b0) {
  float4 extent; // trace width/height, render width/height
  float4 options; // history valid, stabilization, native active/allocation UV
}

bool Compatible(float2 a,float2 b) {
  return a.x!=0.f && b.x!=0.f && ((a.x<0.f)==(b.x<0.f))
      && abs(a.y-b.y)<.25f
      && (a.x<0.f || abs(a.x-b.x)<max(.3f,.025f*a.x));
}

[numthreads(8,8,1)]
void main(uint3 id : SV_DispatchThreadID) {
  int2 pixel=int2(id.xy), size=int2(extent.xy);
  if(any(pixel>=size))return;
  float2 uv=(float2(pixel)+.5f)/extent.xy;
  float2 guide=current_guide.Load(int3(pixel,0));
  if(guide.x==0.f) {
    // Native fill extends reflections under normal-map offsets at shorelines.
    // Retain that padding, while the original compositor still masks the water.
    result[pixel]=native_padding.SampleLevel(linear_clamp,uv*options.zw,0);
    return;
  }
  float3 color=max(current_color.Load(int3(pixel,0)).rgb,0.f);
  if(any(!isfinite(color)))color=0.f;
  if(options.y==0.f) {result[pixel]=float4(color,1);return;}

  float3 low=color,high=color,mean=0.f,second=0.f;
  float count=0.f;
  [unroll] for(int y=-1;y<=1;++y) [unroll] for(int x=-1;x<=1;++x) {
    int2 p=clamp(pixel+int2(x,y),0,size-1);
    float2 g=current_guide.Load(int3(p,0));
    float3 c=max(current_color.Load(int3(p,0)).rgb,0.f);
    if(!Compatible(guide,g) || any(!isfinite(c)))continue;
    low=min(low,c);high=max(high,c);mean+=c;second+=c*c;count+=1.f;
  }
  mean/=max(count,1.f);
  float3 sigma=sqrt(max(second/max(count,1.f)-mean*mean,0.f));

  if(options.x!=0.f) {
    float2 ndc=uv*float2(2,-2)+float2(-1,1);
    float4 world=frame[206]*ndc.x+frame[207]*ndc.y+frame[208]*.5f+frame[209];
    float3 eye=normalize(world.xyz/world.w-frame[0].xyz);
    // A planar reflection's optical path is the distance to its mirrored
    // virtual hit. Reproject that point, rather than just the water surface.
    float4 virtual_point=guide.x>0.f?float4(frame[0].xyz+eye*guide.x,1):float4(eye,0);
    float4 view=virtual_point.x*previous_frame[1]+virtual_point.y*previous_frame[2]
        +virtual_point.z*previous_frame[3]+virtual_point.w*previous_frame[4];
    float4 clip=view.x*previous_frame[13]+view.y*previous_frame[14]
        +view.z*previous_frame[15]+view.w*previous_frame[16];
    float2 old_uv=clip.xy/clip.w*float2(.5f,-.5f)+.5f;
    float3 delta=frame[0].xyz-previous_frame[0].xyz;
    float3 forward=float3(frame[1].z,frame[2].z,frame[3].z);
    float3 old_forward=float3(previous_frame[1].z,previous_frame[2].z,previous_frame[3].z);
    bool valid=clip.w>.001f && all(isfinite(old_uv))
        && all(old_uv>=.5f/extent.xy) && all(old_uv<=1.f-.5f/extent.xy)
        && dot(delta,delta)<4.f && dot(forward,old_forward)>.9f;
    if(valid) {
      float2 expected=guide;
      if(guide.x>0.f)expected.x=distance(virtual_point.xyz,previous_frame[0].xyz);
      // Bilinear history only includes taps from the same reflected surface.
      float2 p=old_uv*extent.xy-.5f;
      int2 base=int2(floor(p));float2 f=frac(p);
      float3 old=0.f;float weight=0.f;
      [unroll] for(int y=0;y<2;++y) [unroll] for(int x=0;x<2;++x) {
        int2 q=clamp(base+int2(x,y),0,size-1);
        if(!Compatible(expected,history_guide.Load(int3(q,0))))continue;
        float w=(x?f.x:1.f-f.x)*(y?f.y:1.f-f.y);
        old+=history_color.Load(int3(q,0)).rgb*w;weight+=w;
      }
      if(weight>.25f) {
        old/=weight;
        // Variance limits work in scene-linear HDR without clamping highlights
        // to SDR. Reject stale lighting quickly; retain steady subpixel detail.
        float3 lo=max(low,mean-1.5f*sigma),hi=min(high,mean+1.5f*sigma);
        float3 clipped=clamp(old,lo,hi);
        float change=length(old-clipped)/max(.05f,length(mean));
        float motion=length((old_uv-uv)*extent.xy);
        float history_weight=lerp(.93f,.80f,saturate(motion/8.f));
        history_weight*=1.f-saturate(change*2.f);
        if(all(isfinite(clipped)))color=lerp(color,clipped,history_weight);
      }
    }
  }
  result[pixel]=float4(color,1);
}
