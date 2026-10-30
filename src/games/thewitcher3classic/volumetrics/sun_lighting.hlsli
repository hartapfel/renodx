// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_CLASSIC_SUN_LIGHTING
#define WITCHER_CLASSIC_SUN_LIGHTING
// Classic's cascades share one world-to-light matrix. cb13[8:10] select
// bounds; [11:14] map those bounds to each array slice. See native 5CC0DB95.
float FilterFogCascade(float3 p, float3 dx, float3 dy, float3 dz, uint cascade) {
#ifdef CLASSIC_FOG_PER_PIXEL
  float2 uv = p.xy*light[11+cascade].z*float2(1,-1)+light[11+cascade].xy;
  uint width,height,layers;shadows.GetDimensions(width,height,layers);
  if(width==0 ||height==0 ||cascade>=layers)return 1.f;
#ifdef CLASSIC_FOG_COMPUTE
  return shadows.SampleCmpLevelZero(PixelFogShadowSampler,float3(uv,cascade),p.z);
#else
  float2 texel=saturate(uv)*float2(width,height)-.5f;
  int2 cell=int2(floor(texel));float2 blend=frac(texel);
  int2 limit=int2(width,height)-1;
  float a=p.z<=shadows.Load(int4(clamp(cell,0,limit),cascade,0));
  float b=p.z<=shadows.Load(int4(clamp(cell+int2(1,0),0,limit),cascade,0));
  float c=p.z<=shadows.Load(int4(clamp(cell+int2(0,1),0,limit),cascade,0));
  float d=p.z<=shadows.Load(int4(clamp(cell+1,0,limit),cascade,0));
  // Bilinear visibility, never interpolation of raw shadow depths. Loads
  // avoid borrowing a material sampler slot in forward/BlitzFX permutations.
  return lerp(lerp(a,b,blend.x),lerp(c,d,blend.x),blend.y);
#endif
#else
  // Mirrored Hammersley samples: stratify the full radial cell interval and
  // distribute the other two coordinates without a regular planar PCF grid.
  // Spatial prefiltering of the source visibility prevents depth-slice aliasing
  // before integration. No frame-varying noise or history is introduced.
  static const float2 pattern[16] = {
    float2(0,0),float2(.5f,1.f/3.f),float2(.25f,2.f/3.f),float2(.75f,1.f/9.f),
    float2(.125f,4.f/9.f),float2(.625f,7.f/9.f),float2(.375f,2.f/9.f),float2(.875f,5.f/9.f),
    float2(.0625f,8.f/9.f),float2(.5625f,1.f/27.f),float2(.3125f,10.f/27.f),float2(.8125f,19.f/27.f),
    float2(.1875f,4.f/27.f),float2(.6875f,13.f/27.f),float2(.4375f,22.f/27.f),float2(.9375f,7.f/27.f)
  };
  uint pairs = 4u*clamp((uint)round(max(sampling.z,1.f)),1u,4u);
  uint width,height,layers;
  shadows.GetDimensions(width,height,layers);
  if (width == 0 || height == 0 || cascade >= layers) return 1.f;
  float2 half_texel = .5f/float2(width,height);
  float scale = light[11+cascade].z;
  float2 minimum = max(light[16].y-.5f*abs(scale)*(abs(dx.xy)+abs(dy.xy)+abs(dz.xy)),0.f);
  float visibility = 0.f;
  [loop] for (uint i=0; i<pairs; ++i) {
    float3 offset = float3(pattern[i]-.5f,.5f*(i+.5f)/pairs);
    float3 delta = dx*offset.x+dy*offset.y+dz*offset.z;
    [unroll] for (uint side=0; side<2; ++side) {
      float sign = side == 0 ? 1.f : -1.f;
      float3 sample_position = p+sign*delta;
      float2 uv = sample_position.xy*scale*float2(1,-1)+light[11+cascade].xy
          +sign*offset.xy*(2.f*minimum);
      visibility += abs(sample_position.z) >= .999f ? 1.f
          : shadows.SampleCmpLevelZero(shadow_sampler,
              float3(clamp(uv,half_texel,1.f-half_texel),cascade),sample_position.z);
    }
  }
  return visibility/(2u*pairs);
#endif
}
float CascadeShadow(float3 world, float3 world_dx, float3 world_dy, float3 world_dz) {
  float3 p = world.x * light[4].xyz + world.y * light[5].xyz
           + world.z * light[6].xyz + light[7].xyz;
  uint count = min((uint)light[15].z, 4u);
  if (abs(p.z) >= .999f || count == 0) return 1.f;
  float4 bounds = max(abs(p.x - light[8]), abs(p.y - light[9]));
  uint cascade = count;
  [unroll] for (uint i = 0; i < 4; ++i) {
    if (i < count && bounds[i] < light[10][i]) { cascade = i; break; }
  }
  if (cascade == count) return 1.f;
  float3 dx = world_dx.x*light[4].xyz+world_dx.y*light[5].xyz+world_dx.z*light[6].xyz;
  float3 dy = world_dy.x*light[4].xyz+world_dy.y*light[5].xyz+world_dy.z*light[6].xyz;
  float3 dz = world_dz.x*light[4].xyz+world_dz.y*light[5].xyz+world_dz.z*light[6].xyz;
  float visibility = FilterFogCascade(p,dx,dy,dz,cascade);
  // Match native continuous cascade transitions instead of changing shadow
  // resolution abruptly at the first two cascade boundaries.
  float fade = saturate((bounds[cascade]/max(light[10][cascade],1.e-8f)
      -(1.f-light[17][cascade]))/max(light[17][cascade],.0001f));
  if (fade > 0.f)
    visibility = lerp(visibility,cascade+1<count ? FilterFogCascade(p,dx,dy,dz,cascade+1) : 1.f,fade);
  return visibility;
}
float TerrainShadow(float3 world) {
  if (options.w == 0.f) return 1.f;
  // Native terrain-height shadow distance, softness and fade (5CC0DB95).
  float distance = length(world.xy-frame[0].xy);
  if (distance >= light[36].y) return 1.f;
  float softness = min(1.f,light[36].x/max(1.f,light[37].z*distance));
  float fade = saturate((light[36].z+distance)*light[36].w);
  uint count = min(asuint(light[35].x), 5u);
  [loop] for (uint i=0; i<count; ++i) {
    float2 uv = (world.xy-light[39+i].xy)*light[39+i].zw;
    if (all(uv >= 0.f) && all(uv <= 1.f)) {
      float height = terrain.SampleLevel(clamp_sampler,float3(uv.x,1.f-uv.y,i),0) * light[38].x + light[38].y;
      float visibility = 1.f-saturate((height-world.z-.1f)*softness);
      return lerp(visibility,1.f,fade);
    }
  }
  return 1.f;
}
#ifdef CLASSIC_FOG_PER_PIXEL
float WrappedFogCloud(float2 uv, float layer) {
  uint width,height,layers,levels;
  clouds.GetDimensions(0,width,height,layers,levels);
  if(width==0 ||height==0 ||layer<0.f ||layer>=float(layers))return 0.f;
  uint mip=min(1u,levels-1u);
#ifdef CLASSIC_FOG_COMPUTE
  return clouds.SampleLevel(PixelFogWrapSampler,float3(uv,layer),mip);
#else
  width=max(1u,width>>mip);height=max(1u,height>>mip);
  float2 texel=frac(uv)*float2(width,height)-.5f;
  int2 cell=int2(floor(texel)),size=int2(width,height);
  float2 blend=frac(texel);
  uint2 a=uint2(cell+size)%uint2(size),b=uint2(cell+1+size)%uint2(size);
  return lerp(lerp(clouds.Load(int4(a,layer,mip)),clouds.Load(int4(b.x,a.y,layer,mip)),blend.x),
      lerp(clouds.Load(int4(a.x,b.y,layer,mip)),clouds.Load(int4(b,layer,mip)),blend.x),blend.y);
#endif
}
#endif
float CloudShadow(float3 world, float distance) {
  if (options.z == 0.f || frame[66].x <= 0.f || light[0].z <= .25f) return 1.f;
  float2 projection = world.xy - world.z * light[0].xy / light[0].z;
  float2 uv_near = (projection + frame[67].xy)*(.01f/frame[66].x);
  float2 uv_far = (projection + 20.f*frame[67].xy)*(.0005f/frame[66].x);
  float2 layer = trunc(frame[68].xy);
#ifdef CLASSIC_FOG_PER_PIXEL
  // Preserve native wrap filtering without borrowing material sampler slots.
  float a = lerp(WrappedFogCloud(uv_near,layer.x),WrappedFogCloud(uv_near,layer.y),frame[66].w);
  float b = lerp(WrappedFogCloud(uv_far,layer.x),WrappedFogCloud(uv_far,layer.y),frame[66].w);
#else
  float a = lerp(clouds.SampleLevel(wrap_sampler,float3(uv_near,layer.x),1), clouds.SampleLevel(wrap_sampler,float3(uv_near,layer.y),1),frame[66].w);
  float b = lerp(clouds.SampleLevel(wrap_sampler,float3(uv_far,layer.x),1), clouds.SampleLevel(wrap_sampler,float3(uv_far,layer.y),1),frame[66].w);
#endif
  return saturate(1.f-saturate((light[0].z-.25f)*10.f)*lerp(a,b,saturate((distance-100.f)/150.f)));
}
#endif
