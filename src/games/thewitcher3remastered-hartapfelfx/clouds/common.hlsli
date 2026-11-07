// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_CLOUD_COMMON
#define CLASSIC_CLOUD_COMMON
#include "../fog/math.hlsli"
#include "wind.hlsli"

cbuffer Frame : register(b0) { float4 frame[341]; }
cbuffer Lighting : register(b1) { float4 light[3]; }
cbuffer Parameters : register(b2) {
  float4 dimensions; // low width/height, active render width/height
  float4 integration; // view samples, light samples, jitter index, history valid
  float4 appearance; // coverage, optical density, horizontal size, layer thickness
  float4 atmosphere; // sky-haze density, detail strength, detail size, base softness
  float4 scattering; // multiple scattering, erosion octaves, air samples, noise size
  uint4 identity; // settings revision, immutable native b0 GPU address, reserved
  uint4 storage; // packed motion row pitch/offset, shadow row pitch/offset
}
cbuffer Previous : register(b3) { float4 previous[341]; }
cbuffer PreviousParameters : register(b4) {
  float4 previous_dimensions, previous_integration, previous_appearance, previous_atmosphere, previous_scattering;
  uint4 previous_identity;
  uint4 previous_storage;
}
ByteAddressBuffer cloud_status : register(t9);
// Native b0[0].x also animates Classic's cloud material UVs. The pipeline
// retains that GPU buffer in its isolated state; no CPU readback/time guessing.
cbuffer CloudClock : register(b5) {
  float4 cloud_clock;
  uint4 clock_identity;
  float4 clock_camera;
  uint4 clock_jitter;
}
cbuffer PreviousCloudClock : register(b6) { float4 previous_cloud_clock; }
uint3 CloudIdentity() { return uint3(identity.x, (identity.w & 256u) != 0 ? clock_identity.xy : identity.yz); }
bool CloudAlreadyRendered() {
  return all(CloudIdentity() == previous_identity.xyz) && all(dimensions == previous_dimensions);
}
Texture3D<float4> shape_noise : register(t0);
Texture2DArray<float2> weather : register(t1);
Texture2DArray<float4> profile_lut : register(t11);
Texture2D<float> scene_depth : register(t2);
SamplerState wrap_sampler : register(s0);
SamplerState clamp_sampler : register(s1);
static const float PlanetRadius = 6371000.f;
static const float CloudBase = 1200.f;
// Clear-weather native cloud meshes span about 15 km in the captured scene.
// Use kilometre-scale main billows, with independent metre-scale erosion,
// rather than the small smoke-like puffs of the initial 2800 m noise tile.
static const float CloudFormationScale = 7200.f;
// The rendered solar disc uses b12[38]. The directional-light vector in b13
// can point toward the broader sky lobe a few degrees away; over a kilometre
// of cloud height that shift casts the terrain shadow through another gap.
float3 CloudShadowSun() {
  float3 native_sun=frame[38].xyz;
  return normalize(dot(native_sun,native_sun)>.25f ? native_sun : light[0].xyz+float3(0,0,1.e-8f));
}
// The native disc is much brighter than the cloud body at the user's low
// Density setting. Use one calibrated direct-beam column for the visible disc
// and the sunlight reaching terrain; otherwise one can vanish without the other.
float CloudDirectBeamScale() { return max(1.f,1.f/max(appearance.y,.125f)); }
float CloudThickness() {return 1200.f*appearance.w;}
float CloudDetailScale() {return 1200.f*max(atmosphere.z,.2f);}
float CloudBaseReliefScale() {return CloudDetailScale()*saturate(atmosphere.y)*lerp(.25f,1.f,atmosphere.w);}
float CloudMinimum() {return CloudBase-.16f*CloudBaseReliefScale();}
float3 CloudRay(float2 uv) {
  float2 ndc=uv*float2(2,-2)+float2(-1,1);
  float4 p=ndc.x*frame[17]+ndc.y*frame[18]+.5f*frame[19]+frame[20];
  return normalize(p.xyz-frame[0].xyz*p.w);
}
float CloudAltitude(float3 p) {
  // Stable evaluation of length(p + planet_center) - planet_radius.
  float z=PlanetRadius+p.z;
  float r=sqrt(dot(p.xy,p.xy)+z*z);
  return (dot(p.xy,p.xy)+p.z*(2.f*PlanetRadius+p.z))/(r+PlanetRadius);
}
float2 CloudSphere(float3 origin,float3 ray,float height) {
  float3 p=origin+float3(0,0,PlanetRadius);
  float b=dot(p,ray);
  // Avoid subtracting squared planet radii in FP32.
  float c=dot(origin.xy,origin.xy)+(origin.z-height)*(2.f*PlanetRadius+origin.z+height);
  float discriminant=b*b-c;
  if(discriminant<0.f)return float2(-1,-1);
  float root=sqrt(discriminant);
  float q=-b-(b>=0.f ? root : -root);
  float a=q, d=abs(q)>1.e-8f ? c/q : -b+root;
  return float2(min(a,d),max(a,d));
}
float2 CloudInterval(float3 origin,float3 ray) {
  float2 outer=CloudSphere(origin,ray,CloudBase+CloudThickness());
  float2 inner=CloudSphere(origin,ray,CloudMinimum());
  float altitude=CloudAltitude(origin);
  float start=altitude<CloudMinimum() ? inner.y : max(0.f,outer.x);
  float end=outer.y;
  if(altitude>=CloudMinimum() && inner.x>0.f)end=min(end,inner.x);
  if(ray.z<0.f) {
    // Reject the shell on the far side of the solid planet. The old range
    // clamp hid this intersection error for shallow downward environment rays.
    float2 ground=CloudSphere(origin,ray,0.f);
    if(ground.x>=0.f)end=min(end,ground.x);
  }
  // Ground-view clouds only. The far side of the planet is never a cloud sky.
  if(outer.y<=0.f ||start<0.f)return 0.f;
  // Follow the spherical layer through its true far intersection. A fixed
  // 80 km clamp ended grazing rays while they were still below the cloud base,
  // drawing a straight cloud boundary above the geographic horizon.
  return float2(start,end);
}
float CloudWeather(float3 p) {
  uint width,height,layers;
  weather.GetDimensions(width,height,layers);
  if(!width || !layers ||frame[66].x<=0.f)return 0.f;
  // The prefiltered native shadow field supplies broad weather coverage.
  // The source and target layers remain separate until the native blend here;
  // the shared prepass applies only the wind-aware temporal fade.
  // Appearance size changes the billows, never the weather front's position,
  // extent or wind. Scaling both fields made large clouds relocate the rain
  // cover and its scene-wide sunlight attenuation.
  // b12[67].xy is a moving world offset. The native shadow texture's separate
  // 20x UV scale is not a multiplier on cloud advection.
  float2 uv=(p.xy+CloudWindOffset(frame[67].xy))*(.0005f/frame[66].x);
  float2 weather_layers=saturate(weather.SampleLevel(wrap_sampler,float3(uv,0),0));
  float authored=lerp(weather_layers.x,weather_layers.y,saturate(frame[66].w));
  // Keep the strong original slider response on populated weather cells.
  // A zero or nearly clear native cell must not gain a blanket cloud floor.
  return appearance.x<=1.f ? authored*appearance.x
      : saturate(authored+(appearance.x-1.f)*(1.f-authored)*smoothstep(.02f,.2f,authored));
}
// Detail is the number of edge-erosion bands. Zero is a conservative coarse
// bound; one is used for nearby light/shadow rays, more for resolved view detail.
float CloudDensity(float3 p,uint detail,float lod,float footprint=0.f) {
  float height=(CloudAltitude(p)-CloudBase)/CloudThickness();
  if(height<=-.16f*CloudBaseReliefScale()/CloudThickness() ||height>=1.f)return 0.f;
  float coverage=CloudWeather(p);
  if(coverage<.002f)return 0.f;
  float3 advected=p+float3(CloudWindOffset(frame[67].xy),0);
  // A separate rotated, wider column field breaks the alignment between the
  // 10 km weather tile and the smaller 3D billow tile without moving either
  // the authored weather front or the shared view/shadow world coordinates.
  float2 column_xy=float2(.8f*advected.x-.6f*advected.y,
      .6f*advected.x+.8f*advected.y)/(CloudFormationScale*appearance.z*1.7f);
  float4 column=shape_noise.SampleLevel(wrap_sampler,
      float3(column_xy,.375f),lod);
  // Let high Coverage intentionally close these smaller formation gaps.
  float breakup=lerp(.55f,1.3f,column.r);
  coverage=saturate(coverage*lerp(breakup,1.f,saturate(appearance.x-1.f)));
  // Shadow opacity is not cloud species/height. Inferring height inversely
  // from local cover raised thin edges above their cores, producing curtains
  // and making a fading weather mask grow taller. Use a coherent formation
  // profile; coverage changes only the fill, never the vertical envelope.
  float type=.4f+.5f*column.r;
  float top=lerp(.45f,1.f,type)*lerp(.7f,1.f,saturate(column.r*1.6f));
  float relative_height=height/max(top,.01f);
  if(relative_height>=1.f)return 0.f;
  // Slow vertical evolution and column-coherent shear preserve the formation
  // while its billows turn over. All detail uses the same bulk evolution rate
  // as cloud motion/reprojection; unmatched detail scrolling causes smearing.
  advected.z+=cloud_clock.x*.6f;
  advected.xy+=(column.gb-.5f)*(140.f*height*height);
  // The second displacement plane varies across X/Z. Together with the
  // column's X/Y plane it bends the 3D Perlin-Worley material in all three
  // axes without moving the native weather front or its world-space shadow.
  float4 side=shape_noise.SampleLevel(wrap_sampler,
      float3(advected.x/(CloudFormationScale*appearance.z),.625f,advected.z/2800.f),lod);
  advected.xz+=(side.gb-.5f)*float2(100.f,60.f);
  float4 body=shape_noise.SampleLevel(wrap_sampler,
      advected/float3(CloudFormationScale*appearance.zz,2800.f),lod);
  // A dimensional envelope keeps coverage/connectivity separate from erosion.
  // Unlike the previous weighted average of three narrow-range fields, the
  // full formation range remains available for nested structures at high density.
  float scale=CloudDetailScale();
  float3 edge=advected+float3((body.ga-.5f)*100.f,0);
  float detail_lod=max(0.f,log2(max(footprint*scattering.w/scale,1.f)));
  float4 features=shape_noise.SampleLevel(wrap_sampler,edge/scale,detail_lod);
  float4 finer=0.f,finest=0.f;
  if(detail>=2u)finer=shape_noise.SampleLevel(wrap_sampler,edge/scale*2.73f+float3(.31f,.73f,.19f),detail_lod+1.4489f);
  if(detail>=3u)finest=shape_noise.SampleLevel(wrap_sampler,edge/scale*7.91f+float3(.67f,.11f,.43f),detail_lod+2.9837f);
  // The base envelope also needs substructure: with a perfectly planar base,
  // opaque clouds hide their internal noise regardless of pixel resolution.
  // Nested lobes perturb the local envelope within the fixed layer bounds.
  // Signed lower-envelope relief forms hanging billows as well as cavities.
  // The old strictly positive erosion could only eat upward into a flat floor.
  float bottom_relief=.22f*(.5f-features.g)+.1f*(.5f-features.b);
  float top_relief=.13f*(1.f-features.g)+.055f*(1.f-features.b);
  if(detail>=2u) {
    bottom_relief+=.04f*(1.f-finer.g);top_relief+=.04f*(1.f-finer.g);
  }
  if(detail>=3u) {
    bottom_relief+=.016f*(1.f-finest.g);top_relief+=.016f*(1.f-finest.g);
  }
  // Keep small structures in metres when Layer Thickness changes; otherwise
  // thick storm layers stretch the same detail into enormous rounded slabs.
  bottom_relief*=CloudBaseReliefScale()/CloudThickness();
  top_relief*=saturate(atmosphere.y)*scale/CloudThickness();
  float altitude_coordinate=saturate(relative_height+top_relief*.5f);
  float2 native_layer=clamp(trunc(frame[68].xy),0.f,15.f);
  float upper=profile_lut.SampleLevel(clamp_sampler,float3(altitude_coordinate,.5f,native_layer.x),0).g;
  if(native_layer.x!=native_layer.y)
    upper=lerp(upper,profile_lut.SampleLevel(clamp_sampler,float3(altitude_coordinate,.5f,native_layer.y),0).g,saturate(frame[66].w));
  float profile=smoothstep(bottom_relief,bottom_relief+lerp(35.f,130.f,atmosphere.w)/CloudThickness(),height)*upper;
  float potential=saturate(.3f+.9f*body.r+.2f*(column.r-.5f));
  float shape=saturate((potential*profile-(1.f-coverage))/max(coverage,.01f));
  if(detail>0 &&shape>0.f &&atmosphere.y>0.f) {
    // Detail has its own physical scale: making formations wider must not
    // inflate every small billow. Warp is coherent within a parent formation.
    // Nest fine billows in coarser ones. Upper growing regions retain rounded
    // lobes; lower/less dense regions dissipate into wisps (Nubis 2023).
    float billowy=lerp(.65f,1.f,type)*lerp(1.f-.25f*atmosphere.w,1.f,smoothstep(.04f,.45f,relative_height));
    // Use the parent potential for scale selection, so adding a finer band
    // cannot reduce an earlier band's erosion and violate the coarse bound.
    float billows=1.f-lerp(features.g,features.b,.6f+sqrt(potential)*.25f);
    float wisps=abs(2.f*features.a-1.f);
    float erosion=.85f*lerp(wisps,billows,billowy);
    if(detail>=2) {
      erosion=1.f-(1.f-erosion)*(1.f-.18f*lerp(abs(2.f*finer.a-1.f),1.f-finer.b,billowy));
    }
    if(detail>=3) {
      erosion=1.f-(1.f-erosion)*(1.f-.08f*lerp(abs(2.f*finest.a-1.f),1.f-finest.b,billowy));
    }
    // Bounded value erosion cannot add detached fragments outside the parent
    // mass. Fine<=coarse is retained for conservative bounds. Density only
    // scales optical depth after all structural detail has been formed.
    // Compose erosion as transmission. Hard-clamping a multiplied strength
    // flattened its variation at 200%, producing terraces instead of detail.
    float retained=pow(max(1.f-erosion,1.e-4f),atmosphere.y
        *lerp(1.f+.5f*atmosphere.w,1.f,smoothstep(0.f,.45f,relative_height)));
    shape=saturate((shape-(1.f-retained))/max(retained,1.e-4f));
  }
  return shape*appearance.y;
}
float3 CloudSky(float3 ray) {
  // The broad native sky lobes, before stars and sun/moon discs. These are
  // linear scene radiance, not the authored lit/shadow cloud-card colors.
  float2 horizontal=ray.xy/max(length(ray.xy),.0001f);
  float2 sun=frame[204].yz/max(length(frame[204].yz),.0001f);
  float2 moon=frame[205].yz/max(length(frame[205].yz),.0001f);
  float3 sun_horizon=lerp(frame[198].rgb,frame[197].rgb,dot(sun,horizontal)*.5f+.5f);
  float3 moon_horizon=lerp(frame[201].rgb,frame[200].rgb,dot(moon,horizontal)*.5f+.5f);
  float horizon=1.f-ray.z*ray.z;
  float3 color=lerp(frame[196].rgb,moon_horizon,horizon*saturate(frame[206].y));
  color=lerp(color,sun_horizon,horizon*saturate(frame[206].x));
  float altitude=(ray.z*1000.f+frame[0].z+710.f)*frame[203].z*.001f+.1f;
  color=lerp(color,frame[195].rgb,1.f-pow(min(1.f,rcp(max(altitude,.0001f))),2.8f));
  return max(color*frame[203].x*frame[203].y,0.f);
}
float CloudSceneDistance(float2 pixel,float3 ray) {
  uint width,height;scene_depth.GetDimensions(width,height);
  uint2 location=min(uint2(pixel),uint2(width-1,height-1));
  float z=scene_depth.Load(int3(location,0))*frame[22].x+frame[22].y;
  if(z>=.999999f)return 1.e9f;
  float4 p=(pixel/dimensions.zw*float2(2,-2)+float2(-1,1)).x*frame[17]
      +(pixel/dimensions.zw*float2(2,-2)+float2(-1,1)).y*frame[18]+z*frame[19]+frame[20];
  if(abs(p.w)<1.e-8f)return 1.e9f;
  return max(0.f,dot(p.xyz/p.w-frame[0].xyz,ray));
}
#endif
