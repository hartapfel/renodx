// Custom optical filters, adapted to Classic's linear scene domain.
// Copyright (c) 2026 LoreanXavier / Hartapfel. MIT: LICENSE.optics.
#include "../effects/lilium_rcas.hlsli"
Texture2D<float4> Source : register(t0);
Texture2D<float4> Second : register(t1);
Texture2D<float4> Third : register(t2);
Texture2D<float> Depth : register(t3);
Texture2D<float4> Motion : register(t4);
Texture2D<float> Validity : register(t5);
SamplerState LinearClamp : register(s0);
SamplerState PointClamp : register(s1);
cbuffer Optics : register(b0) {
  float4 dimensions; // target.xy, source.zw
  float4 f0;
  float4 f1;
  float4 f2;
  uint stage; float3 unused;
}
cbuffer NativeFrame : register(b12) { float4 frame[269]; }
float3 Finite(float3 c) { return clamp(isfinite(c) ? c : 0.f, -65504.f, 65504.f); }
float ViewDepth(float raw) {
  return min(65000.f, rcp(max((raw * frame[22].x + frame[22].y) * frame[21].x + frame[21].y, 1e-5f)));
}
float Inverse(float x) { return x != 0.f ? rcp(x) : 1e30f; }
float4 main(float4 position : SV_Position) : SV_Target {
  const float2 uv=position.xy/dimensions.xy;
  if(stage==0) return float4(Finite(Source.SampleLevel(LinearClamp,uv,0).rgb),1);
  if(stage==1) { // Area-preserving 4x4 bloom prefilter, Custom bright.frag.
    float3 color=0;
    [unroll] for(uint y=0;y<4;++y) [unroll] for(uint x=0;x<4;++x)
      color+=max(Finite(Source.Load(int3(clamp(int2(position.xy)*4+int2(x,y),0,int2(dimensions.zw)-1),0)).rgb),0.f)/16.f;
    const float scale=max(1.f,max(color.r,max(color.g,color.b)));
    const float l=dot(color/scale,float3(.2126f,.7152f,.0722f));
    return float4(Finite(color*lerp(pow(l,floor(f0.x)),pow(l,min(4.f,floor(f0.x)+1.f)),frac(f0.x))),1);
  }
  if(stage==2) { // Custom enhanced bloom: normalized separable Gaussian.
    float2 step=f0.xy/dimensions.zw;
    float3 c=Source.SampleLevel(LinearClamp,uv,0).rgb*.2270270270f;
    c+=(Source.SampleLevel(LinearClamp,uv+step*1.3846153846f,0).rgb+Source.SampleLevel(LinearClamp,uv-step*1.3846153846f,0).rgb)*.3162162162f;
    c+=(Source.SampleLevel(LinearClamp,uv+step*3.2307692308f,0).rgb+Source.SampleLevel(LinearClamp,uv-step*3.2307692308f,0).rgb)*.0702702703f;
    return float4(Finite(c),1);
  }
  if(stage==3) return float4(Finite(Source.SampleLevel(LinearClamp,uv,0).rgb*f0.x),0); // Accumulate.
  if(stage==4) return float4(Finite(Source.Load(int3(position.xy,0)).rgb+Second.SampleLevel(LinearClamp,uv,0).rgb*f0.x),1);
  if(stage==5) { // Signed circle of confusion. Depth remains unwarped.
    const float z=ViewDepth(Depth.SampleLevel(PointClamp,clamp(uv+f2.xy,.5f/f2.zw,1.f-.5f/f2.zw),0));
    const float r=(z-f0.x)/max(z,1e-5f);
    return float4(Finite(Source.Load(int3(position.xy,0)).rgb),.5f*clamp(r*(r<0.f?f0.y:1.f),-1.f,1.f)+.5f);
  }
  if(stage==6 || stage==7) { // Select near/far before downsampling, bilateral CoC.
    bool near_layer=stage==7;
    int2 base=int2(floor(position.xy/dimensions.xy*dimensions.zw-.5f));
    float4 c[4]; float reference=near_layer?1.f:0.f;
    [unroll] for(uint i=0;i<4;++i) {
      c[i]=Source.Load(int3(clamp(base+int2(i&1,i>>1),0,int2(dimensions.zw)-1),0));
      reference=near_layer?min(reference,c[i].a):max(reference,c[i].a);
    }
    float3 sum=0; float weights=0,coc=0;
    [unroll] for(uint i=0;i<4;++i) {
      float delta=(c[i].a-reference)*2.f*f0.x;
      float w=1.f/(1.f+delta*delta);
      float amount=near_layer?saturate(1.f-2.f*c[i].a):c[i].a;
      sum+=c[i].rgb*w*(near_layer?amount:1.f); coc+=amount*w; weights+=w;
    }
    return float4(Finite(sum/weights),coc/weights);
  }
  if(stage==8 || stage==9) { // Equal-area deterministic Vogel disk.
    bool near_layer=stage==9;
    float4 center=Source.SampleLevel(PointClamp,uv,0);
    float radius=near_layer?f0.x:f0.x*saturate(2.f*center.a-1.f);
    if(radius<.25f) return center;
    int count=radius>6.f?97:49;
    float3 sum=0; float weights=0;
    [loop] for(int i=0;i<count;++i) {
      float distance=radius*sqrt((i+.5f)/count);
      float angle=i*2.39996323f;
      float4 c=Source.SampleLevel(LinearClamp,uv+distance*float2(cos(angle),sin(angle))/dimensions.zw,0);
      float amount=near_layer?c.a:saturate(2.f*c.a-1.f);
      float w;
      if(near_layer) {
        float source_radius=max(.75f,f0.x*amount);
        float coverage=1.f-smoothstep(max(0.f,source_radius-.5f),source_radius+.5f,distance);
        w=amount*coverage/(source_radius*source_radius);
      } else {
        float delta=(c.a-center.a)*2.f*f0.x;
        w=smoothstep(0.f,.25f,amount*f0.x)/(1.f+delta*delta);
      }
      sum+=c.rgb*(near_layer?w/max(amount,1e-6f):w); weights+=w;
    }
    float3 color=weights>1e-6f?sum/weights:(near_layer?0.f:center.rgb);
    float alpha=near_layer?saturate(weights*radius*radius/count):center.a;
    return float4(Finite(near_layer?color*alpha:color),alpha);
  }
  if(stage==10) { // CoC-aware full-resolution reconstruction.
    float4 sharp=Source.Load(int3(position.xy,0)), near_layer=Second.SampleLevel(LinearClamp,uv,0);
    uint w,h; Third.GetDimensions(w,h);
    float2 p=uv*float2(w,h)-.5f,f=frac(p); int2 base=int2(floor(p));
    float3 far_layer=0; float weight=0;
    [unroll] for(uint i=0;i<4;++i) {
      float4 c=Third.Load(int3(clamp(base+int2(i&1,i>>1),0,int2(w,h)-1),0));
      float delta=(c.a-sharp.a)*2.f*f0.x;
      float a=((i&1)?f.x:1.f-f.x)*((i&2)?f.y:1.f-f.y)/(1.f+delta*delta);
      far_layer+=c.rgb*a; weight+=a;
    }
    float3 color=lerp(sharp.rgb,far_layer/max(weight,1e-6f),smoothstep(0.f,1.5f,saturate(2.f*sharp.a-1.f)*f0.x));
    return float4(Finite(color*(1.f-f0.y*saturate(near_layer.a))+f0.y*near_layer.rgb),1);
  }
  if(stage==11) { // Custom velocity units, with half-shutter/rate bounds unchanged.
    float2 sample_uv=clamp(uv+f2.xy,.5f/f2.zw,1.f-.5f/f2.zw);
    int2 pixel=int2(sample_uv*f2.zw);
    float2 velocity;
    if(f0.y>0.5f) {
      float raw=Depth.Load(int3(pixel,0));
      float object_depth=Validity.Load(int3(pixel,0));
      bool hit=(asuint(object_depth)&0x80000000u)==0u && abs(object_depth-raw)<=2e-7f;
      // Object-only shutter follows the visible trajectory, as in Remastered.
      // Camera-removed motion identifies the object contribution but is not a
      // shutter displacement: a camera-followed subject can have large ZW and
      // almost zero XY. Bound the contribution by both speeds in output pixels.
      const float4 object_motion=Motion.Load(int3(pixel,0));
      const float screen_speed=length(object_motion.xy*f1.xy);
      const float object_speed=length(object_motion.zw*f1.xy);
      velocity=hit?object_motion.xy*saturate(object_speed/max(screen_speed,1e-8f)):0.f;
    } else velocity=Motion.Load(int3(pixel,0)).xy;
    velocity*=float2(1920.f,1080.f)/128.f;
    float len=length(velocity);
    velocity*=len>0.f?min(1.f,f0.x/max(len,1e-8f)):0.f;
    if(f0.z==0.f || !all(isfinite(velocity))) velocity=0.f;
    return float4(0,0,velocity);
  }
  if(stage==12 || stage==13) { // Hierarchical tile max and neighbourhood max.
    float2 best=0; float best_len=0;
    int2 base=stage==12?int2(position.xy)*2:int2(position.xy);
    [loop] for(int y=stage==12?0:-1;y<2;++y) [loop] for(int x=stage==12?0:-1;x<2;++x) {
      float2 v=Source.Load(int3(clamp(base+int2(x,y),0,int2(dimensions.zw)-1),0)).zw;
      if(dot(v,v)>best_len) {best_len=dot(v,v);best=v;}
    }
    return float4(0,0,best);
  }
  if(stage==14) { // Dominant direction + per-pixel radius / linear depth.
    const float2 sample_uv=clamp(uv+f2.xy,.5f/f2.zw,1.f-.5f/f2.zw);
    float2 velocity=Source.SampleLevel(PointClamp,sample_uv,0).zw;
    float2 tile=Second.SampleLevel(PointClamp,sample_uv,0).zw;
    float2 scaled=64.f*velocity*f0.x;
    float z=ViewDepth(Depth.SampleLevel(PointClamp,sample_uv,0));
    return float4(.015625f*sqrt(1e-7f+dot(scaled,scaled)),z,dot(tile,tile)>=dot(velocity,velocity)?tile:velocity);
  }
  if(stage==15) { // McGuire reconstruction, Custom continuous activation/taps.
    float4 center_vd=Second.SampleLevel(PointClamp,uv,0);
    float2 dir=float2(.033333335f,.05925926f)*f0.x*center_vd.zw*f0.y;
    const float switch_on=1.0623588e-3f;
    float full=length(dir)/max(f0.y,1e-6f);
    float kept=full*smoothstep(.5f*switch_on,1.5f*switch_on,full);
    dir*=full>0.f?kept/full:0.f;
    float4 center=Source.SampleLevel(PointClamp,uv,0);
    if(kept<=0.f) return float4(center.rgb,f0.y>=.99f?0.f:center.a);
    int taps=2*int(clamp(ceil(length(dir*dimensions.zw)*.5f),8.f,24.f))+1;
    int middle=taps/2;
    float jitter=frac(52.9829189f*frac(.06711056f*position.x+.00583715f*position.y))-.5f;
    float2 step=dir/(taps-1),start=step*(jitter-middle)+uv;
    float zc=center_vd.y,inv_c=Inverse(center_vd.x);
    float weight=4.f*(taps-1)/6.f;
    float3 sum=weight*center.rgb;
    [loop] for(int k=0;k<taps;++k) if(k!=middle) {
      float2 suv=k*step+start;
      float4 s_vd=Second.SampleLevel(PointClamp,suv,0);
      float3 s=Source.SampleLevel(LinearClamp,suv,0).rgb;
      float d=.015625f*length((suv-uv)*float2(1920.f,1080.f));
      float zs=s_vd.y;
      float cone_s=1.f-d*Inverse(s_vd.x),cone_c=1.f-d*inv_c;
      float front=saturate(1.f+(zc-zs)/max(.01f*min(zc,zs),1e-4f));
      float back=saturate(1.f+(zs-zc)/max(.01f*min(zc,zs),1e-4f));
      float w=2.f*saturate(cone_s+.95f)*saturate(cone_c+.95f)+front*saturate(cone_s)+back*saturate(cone_c);
      sum+=s*w;weight+=w;
    }
    float alpha=saturate(.25f*weight*6.f/(taps-1)-1.2f);
    return float4(Finite(sum/weight),f0.y>=.99f?alpha:center.a);
  }
  if(stage==16) {
    float4 blur=Second.SampleLevel(LinearClamp,uv,0);
    return float4(Finite(lerp(Source.Load(int3(position.xy,0)).rgb,blur.rgb,saturate(blur.a))),1);
  }
  if(stage==17) return float4(Finite(WitcherSharpenScene(Source,int2(position.xy),uint2(dimensions.zw),f0.x)),1);
  return 0;
}
