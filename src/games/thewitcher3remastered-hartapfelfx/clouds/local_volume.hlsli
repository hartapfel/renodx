// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_LOCAL_CLOUD_VOLUME
#define HARTAPFEL_LOCAL_CLOUD_VOLUME
#include "../fog/math.hlsli"
static const float LocalCloudVolumeTag=1358.f;

float LocalCloudNoise(float3 p) {
  int3 cell=int3(floor(p));
  float3 f=frac(p);f=f*f*(3.f-2.f*f);
  float value=0.f;
  [unroll]for(uint z=0;z<2;++z)[unroll]for(uint y=0;y<2;++y)[unroll]for(uint x=0;x<2;++x) {
    uint3 c=asuint(cell+int3(x,y,z));
    uint h=c.x*1597334677u^c.y*3812015801u^c.z*2798796415u;
    h^=h>>16;h*=2246822519u;h^=h>>13;
    float3 w=lerp(1.f-f,f,float3(x,y,z));
    value+=(h&65535u)*(1.f/65535.f)*w.x*w.y*w.z;
  }
  return value;
}

// The native oriented particle is the volume's projected bounds. Its centre,
// dimensions, flipbook frame, colour, fade and flow remain engine-owned. No
// particle readback, CPU simulation or additional resource bindings are used.
float4 LocalCloudVolume(float4 native_color,float4 center_tag,float4 world_view_depth,
    float4 camera_scene_depth,float4 uv_frame_opacity,float3 source,float3 particle_axis,float4 atlas_flow,
    float time,Texture2D<float4> material,SamplerState filter_sampler) {
  if(abs(center_tag.w-LocalCloudVolumeTag)>.25f)return native_color;
  float2 uv=uv_frame_opacity.xy;
  float2 dx=ddx(uv),dy=ddy(uv);
  float determinant=dx.x*dy.y-dx.y*dy.x;
  if(abs(determinant)<1.e-12f)return native_color;
  // Work relative to the emitter to retain precision at large world offsets.
  float3 relative=world_view_depth.xyz-center_tag.xyz;
  float3 px=ddx(relative),py=ddy(relative);
  float3 u=(px*dy.y-py*dx.y)/determinant;
  float3 v=(py*dx.x-px*dy.x)/determinant;
  float2 radii=.5f*float2(length(u),length(v));
  // Small effects keep the native material. Large authored mist/cloud sprites
  // become volumes, without changing fire, sparks or tiny smoke particles.
  float volume_weight=smoothstep(20.f,40.f,min(radii.x,radii.y));
  if(volume_weight==0.f ||any(!isfinite(radii)))return native_color;
  u/=2.f*radii.x;v/=2.f*radii.y;
  // The native lighting normal reverses at the sprite centre. Its derivatives
  // retain the emitter axis there; canonicalize its sign across the volume.
  float3 axis_change=ddx(particle_axis)+ddy(particle_axis);
  if(dot(particle_axis,particle_axis)<1.e-8f)particle_axis=axis_change;
  if(dot(particle_axis,particle_axis)<1.e-8f)return native_color;
  particle_axis=normalize(particle_axis);
  float leading=abs(particle_axis.z)>.1f?particle_axis.z:
      abs(particle_axis.y)>abs(particle_axis.x)?particle_axis.y:particle_axis.x;
  if(leading<0.f)particle_axis=-particle_axis;
  bool vertical_v=abs(dot(v,particle_axis))>abs(dot(u,particle_axis));
  float horizontal_radius=vertical_v?radii.x:radii.y;
  float vertical_radius=vertical_v?radii.y:radii.x;
  // Native billboards turn toward the camera. A world-anchored spheroid and
  // noise basis prevent that turn from rotating the density inside the mist.
  u=normalize(cross(particle_axis,abs(particle_axis.z)<.9f?float3(0,0,1):float3(0,1,0)));
  v=particle_axis;
  float3 normal=normalize(cross(u,v));
  float3 radius=float3(horizontal_radius,vertical_radius,horizontal_radius);
  float3 delta=world_view_depth.xyz-camera_scene_depth.xyz;
  float distance=length(delta);
  float3 ray=delta/max(distance,1.e-6f);
  float3 origin=camera_scene_depth.xyz-center_tag.xyz;
  float3 o=float3(dot(origin,u),dot(origin,v),dot(origin,normal))/radius;
  float3 d=float3(dot(ray,u),dot(ray,v),dot(ray,normal))/radius;
  float a=dot(d,d),mid=-dot(o,d)/a;
  float3 closest=o+mid*d;
  float perpendicular=dot(closest,closest);
  if(perpendicular>=1.f)return lerp(native_color,0.f,volume_weight);
  float half_span=sqrt((1.f-perpendicular)/a);
  float scene_distance=camera_scene_depth.w>=1.e8f ? 1.e9f
      :camera_scene_depth.w*distance/max(world_view_depth.w,1.e-4f);
  float begin=max(0.f,mid-half_span),end=min(mid+half_span,scene_distance);
  if(end<=begin)return lerp(native_color,0.f,volume_weight);
  float step=(end-begin)/12.f;
  float transmission=1.f;
  float2 tiles=max(atlas_flow.xy,1.f);
  uint width,height;material.GetDimensions(width,height);
  float2 texel_size=float2(width,height)/tiles;
  float lod=max(0.f,log2(max(length(dx*texel_size),length(dy*texel_size))));
  float frame=uv_frame_opacity.z;
  float3 flow=float3(atlas_flow.zw,.01f)*time;
  [loop]for(uint i=0;i<12u &&transmission>1.e-4f;++i) {
    float3 p=o+d*(begin+(i+.5f)*step);
    float2 local_uv=p.xy*.5f+.5f;
    float2 first=float2(fmod(floor(frame),tiles.x),floor(floor(frame)/tiles.x));
    float2 second=float2(fmod(floor(frame+1.f),tiles.x),floor(floor(frame+1.f)/tiles.x));
    float alpha=lerp(material.SampleLevel(filter_sampler,(first+local_uv)/tiles,lod).a,
        material.SampleLevel(filter_sampler,(second+local_uv)/tiles,lod).a,frac(frame));
    float density=saturate(1.f-dot(p,p));density*=density;
    density*=lerp(.45f,1.55f,LocalCloudNoise(p*3.f+flow));
    // Integral of (1-z*z)^2 over a central chord is 16/15. This keeps the
    // authored opacity scale when the sprite becomes an ellipsoidal medium.
    float extinction=-log(max(1.f-saturate(alpha*uv_frame_opacity.w),1.e-4f))*.9375f/radius.z;
    transmission*=1.f-SegmentOpacity(extinction*density*step);
  }
  float opacity=1.f-transmission;
  return lerp(native_color,float4(source*opacity,opacity),volume_weight);
}
#endif
