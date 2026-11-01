// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Previous raw-HDR input to native SSR, following BlitzFX PreSSRDownsamplePS.
// See THIRD_PARTY.md. Native reflection history and composition stay in charge.
// A second scalar output supplies emissive depth to the existing native trace.
Texture2D<float4> native_scene : register(t0);
cbuffer cb3 : register(b3) { float4 cb3[2]; }
Texture2D<float> current_depth : register(t108);
Texture2D<float> history_depth : register(t109);
Texture2D<float4> history_color : register(t110);
StructuredBuffer<float4> previous_frame : register(t111);
StructuredBuffer<float4> current_frame : register(t112);
StructuredBuffer<float4> parameters : register(t113);
Texture2D<float> particle_depth : register(t114);
SamplerState history_linear : register(s12);
#ifdef CLASSIC_SSR_PREPARE
cbuffer SSRPrepare : register(b4) { float4 ssr_extent; }
RWTexture2D<float4> prepared_color : register(u0);
RWTexture2D<float> prepared_emission : register(u1);
float4 SampleCurrentOpaque(float2 pixel) {
  uint w,h;native_scene.GetDimensions(w,h);
  return native_scene.SampleLevel(history_linear,
      clamp(pixel,.5f,ssr_extent.zw-.5f)/float2(w,h),0);
}
#endif

float4 ResolveReflectionInput(float4 position, out float trace_depth) {
  float2 extent=parameters[0].xy;
  float2 uv=(floor(position.xy)+.5f)/cb3[0].xy;
#ifdef CLASSIC_SSR_PREPARE
  extent=ssr_extent.zw;
  uv=(floor(position.xy)+.5f)/ssr_extent.xy;
#endif
  int2 pixel=clamp(int2(uv*extent),0,int2(extent)-1);
  float raw=current_depth.Load(int3(pixel,0));
  trace_depth=current_frame[22].x<0.f?0.f:1.f;
  // Exact original fallback, including alpha. Startup, discontinuity and
  // disocclusion must not sample stale/uninitialized history.
  uint2 native_pixel=uint2(cb3[1].zw*floor(position.xy));
  float4 fallback=native_scene.Load(int3(native_pixel,0));
#ifdef CLASSIC_SSR_PREPARE
  // Current-frame opaque radiance avoids an extra frame of lag before the
  // reflection history even starts. Only late emission needs old-frame color.
  float2 source_pixel=uv*extent;
  float2 radius=.25f*extent/ssr_extent.xy;
  fallback=.25f*(SampleCurrentOpaque(source_pixel-radius)
      +SampleCurrentOpaque(source_pixel+radius*float2(-1,1))
      +SampleCurrentOpaque(source_pixel+radius*float2(1,-1))
      +SampleCurrentOpaque(source_pixel+radius));
  if(all(ssr_extent.xy==extent))fallback=native_scene.Load(int3(pixel,0));
#else
  float luma=dot(float3(.333330005f,.333330005f,.333330005f),fallback.rgb);
  fallback.rgb*=min(10.f,luma)/max(.0001f,luma);
#endif
  if(parameters[0].z==0.f)return fallback;

  float2 ndc=uv*float2(2,-2)+float2(-1,1);
  float4 world=current_frame[206]*ndc.x+current_frame[207]*ndc.y
      +current_frame[208]*raw+current_frame[209];
  if(abs(world.w)<1.e-7f)return fallback;
  world/=world.w;
  float4 view=world.x*previous_frame[1]+world.y*previous_frame[2]
      +world.z*previous_frame[3]+previous_frame[4];
  float4 clip=view.x*previous_frame[13]+view.y*previous_frame[14]
      +view.z*previous_frame[15]+previous_frame[16];
  if(clip.w<=.001f)return fallback;
  float2 history_uv=clip.xy/clip.w*float2(.5f,-.5f)+.5f;
  // Reject camera cuts on the GPU; no synchronous constant readback.
  float3 camera_delta=current_frame[0].xyz-previous_frame[0].xyz;
  float3 forward_now=float3(current_frame[1].z,current_frame[2].z,current_frame[3].z);
  float3 forward_before=float3(previous_frame[1].z,previous_frame[2].z,previous_frame[3].z);
  if(dot(camera_delta,camera_delta)>4.f || dot(forward_now,forward_before)<.9f
      || any(history_uv<.5f/extent) || any(history_uv>1.f-.5f/extent))return fallback;
  float old_raw=history_depth.Load(int3(min(int2(history_uv*extent),int2(extent)-1),0));
  float old_z=rcp(max(1.e-7f,(old_raw*previous_frame[22].x+previous_frame[22].y)
      *previous_frame[21].x+previous_frame[21].y));
  if(abs(old_z-clip.w)>max(.1f,.02f*clip.w))return fallback;

  if(parameters[0].w!=0.f) {
    // Match the color prefilter footprint. Empty/transparent texels retain the
    // far sentinel; MIN blending captures the nearest visible emissive layer.
    int2 center=int2(history_uv*extent);
    int2 offset=max(int2(.25f*extent/cb3[0].xy),1);
    float z=65504.f;
    [unroll] for(int y=-1;y<=1;y+=2) [unroll] for(int x=-1;x<=1;x+=2)
      z=min(z,particle_depth.Load(int3(clamp(center+int2(x,y)*offset,0,int2(extent)-1),0)));
    if(z>0.f && z<65504.f) {
      float particle_raw=((rcp(z)-previous_frame[21].y)/previous_frame[21].x
          -previous_frame[22].y)/previous_frame[22].x;
      float2 previous_ndc=history_uv*float2(2,-2)+float2(-1,1);
      float4 particle_world=previous_frame[206]*previous_ndc.x+previous_frame[207]*previous_ndc.y
          +previous_frame[208]*particle_raw+previous_frame[209];
      particle_world/=particle_world.w;
      float4 particle_view=particle_world.x*current_frame[1]+particle_world.y*current_frame[2]
          +particle_world.z*current_frame[3]+current_frame[4];
      float4 particle_clip=particle_view.x*current_frame[13]+particle_view.y*current_frame[14]
          +particle_view.z*current_frame[15]+current_frame[16];
      // Projection stores conventional Z; the native depth texture may reverse it.
      float current_raw=(particle_clip.z/particle_clip.w-current_frame[22].y)/current_frame[22].x;
      if(particle_clip.w>.001f && isfinite(current_raw) && current_raw>0.f && current_raw<1.f)
        trace_depth=current_raw;
    }
  }

#ifdef CLASSIC_SSR_PREPARE
  if(trace_depth==(current_frame[22].x<0.f?0.f:1.f))return fallback;
#endif
  // Four bilinear taps prefilter the color at the native quarter-resolution
  // input stage. Preserve scene-linear HDR; do not apply the native luma cap.
  float2 history_radius=.5f/cb3[0].xy;
#ifdef CLASSIC_SSR_PREPARE
  history_radius=.5f/ssr_extent.xy;
#endif
  float3 color=history_color.SampleLevel(history_linear,history_uv-history_radius,0).rgb;
  color+=history_color.SampleLevel(history_linear,history_uv+history_radius*float2(-1,1),0).rgb;
  color+=history_color.SampleLevel(history_linear,history_uv+history_radius*float2(1,-1),0).rgb;
  color+=history_color.SampleLevel(history_linear,history_uv+history_radius,0).rgb;
  if(any(!isfinite(color)))return fallback;
  return float4(max(color*.25f,0.f),0.f);
}

#ifdef CLASSIC_SSR_PREPARE
[numthreads(8,8,1)]
void main(uint3 id:SV_DispatchThreadID) {
  if(any(id.xy>=uint2(ssr_extent.xy)))return;
  float depth;
  prepared_color[id.xy]=ResolveReflectionInput(float4(float2(id.xy)+.5f,0,1),depth);
  prepared_emission[id.xy]=depth;
}
#else
void main(float4 position : SV_Position,out float4 color : SV_Target0,out float depth : SV_Target1) {
  color=ResolveReflectionInput(position,depth);
}
#endif
