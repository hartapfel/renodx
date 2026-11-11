// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_CLOUD_COMMON
#define CLASSIC_CLOUD_COMMON
#include "../fog/math.hlsli"
#include "wind.hlsli"

cbuffer Frame : register(b0) { float4 frame[341]; }
cbuffer Lighting : register(b1) { float4 light[3]; }
cbuffer Parameters : register(b2) {
  float4 dimensions; // reconstruction width/height, active render width/height
  float4 integration; // view samples, light samples, jitter index, history valid
  float4 appearance; // coverage, optical density, horizontal size, layer thickness
  float4 atmosphere; // sky-haze density, detail strength, detail size, base softness
  float4 scattering; // multiple scattering, erosion octaves, low-sun opening, noise size
  uint4 identity; // settings revision, immutable native b0 GPU address, reserved
  uint4 storage; // packed motion row pitch/offset, shadow row pitch/offset
  float4 family_from, family_to, family_transition;
  float4 morphology, structure, microstructure, contour, illumination;
  float4 celestial; // stars, packed Moon offset, sky haze, validity tag
  float4 private_sky[8]; // existing settings/material/size page, bytes256..383
  float4 emission_sun,emission_moon; // same private page as sky/composite
  float4 family_appearance; // source clear/light weights, target clear/light weights
  float4 trace_grid; // primary trace width/height, experimental low-sun cache, reserved
}
cbuffer Previous : register(b3) { float4 previous[341]; }
cbuffer PreviousParameters : register(b4) {
  float4 previous_dimensions, previous_integration, previous_appearance, previous_atmosphere, previous_scattering;
  uint4 previous_identity;
  uint4 previous_storage;
  float4 previous_cloud_layer; // base altitude, spatial sampling phase
}
ByteAddressBuffer cloud_status : register(t9);
ByteAddressBuffer cloud_shared : register(t8);
// Uniform values published in the existing buffer's reserved header. DXC can
// hoist these invocation-invariant reads out of the density/light ray loops.
static float4 cloud_family_low=asfloat(cloud_shared.Load4(320));
static float4 cloud_family_high=asfloat(cloud_shared.Load4(336));
static float cloud_main_strength=max(cloud_family_low.x,cloud_family_low.y);
static float cloud_deck=cloud_family_low.y/max(cloud_family_low.x+cloud_family_low.y,.001f);
static float cloud_light_weather=cloud_family_low.w;
static const float CloudLowBase=433.f;
float CloudWeatherBase(float2 clear_light) {
  return lerp(CloudLowBase,1200.f,saturate(clear_light.x+clear_light.y));
}
static float CloudBase=CloudWeatherBase(cloud_family_low.zw);
#include "low_sun.hlsli"
// Severe precipitation follows the native weather blend and the same temporal
// publication as formation weights. Unknown weather is conservatively unedited.
static float4 cloud_low_sun = CloudLowSunState(frame[204].yzw,
    scattering.z * smoothstep(.975f,1.f,cloud_family_high.y)
        * (1.f-saturate(cloud_family_high.w)),(identity.w&8192u)!=0u);
#include "clock.hlsli"
// A stable clock holds the sampling pattern in photo mode. Advancing time
// visits the four reconstruction pixels within each primary trace cell.
float2 CloudTraceOffset() {
  uint phase=((uint)previous_cloud_layer.y+(cloud_clock.x!=previous_cloud_clock.x?1u:0u))&3u;
  return any(trace_grid.xy<dimensions.xy)
      ?(float2(phase&1u,phase>>1u)+.5f)*.5f-.5f:0.f;
}
#include "../sky/lighting.hlsli"
uint3 CloudIdentity() {
  return uint3(identity.x,cloud_clock_captured ? captured_clock_identity.xy
      : (identity.w&256u)!=0u ? clock_identity.xy : identity.yz);
}
bool CloudAlreadyRendered() {
  return all(CloudIdentity() == previous_identity.xyz) && all(dimensions == previous_dimensions)
      &&all(cloud_clock==previous_cloud_clock) &&all(frame[0]==previous[0])
      &&all(frame[204]==previous[204]) &&all(frame[205]==previous[205])
      &&all(frame[66]==previous[66]) &&all(frame[67]==previous[67])
      &&all(frame[68]==previous[68]) &&all(frame[286]==previous[286])
      &&scattering.z==previous_scattering.z &&CloudBase==previous_cloud_layer.x;
}
Texture3D<float4> shape_noise : register(t0);
Texture2DArray<float2> weather : register(t1);
Texture2DArray<float4> profile_lut : register(t11);
Texture2D<float> scene_depth : register(t2);
SamplerState wrap_sampler : register(s0);
SamplerState clamp_sampler : register(s1);
static const float PlanetRadius = 6371000.f;
// Restore the former horizontal scale for Light Clouds. Blend the period
// with the same filtered weather weight that drives the layer height.
static float cloud_formation_period = lerp(1550.f,3960.f,cloud_light_weather)*appearance.z;
static float cloud_vertical_period = 2800.f*lerp(1.f,.75f,cloud_light_weather);
// Native sky 0x449D3390 places its solar lobe at b12[204].yzw. b12[38]
// drives atmospheric attenuation instead; in the live scene they differ by
// 4.48 degrees (~460 m at the cloud base). Do not cast through that other gap.
float3 CloudLightingDirection(bool terrain=false) {
  float3 native_sun=frame[204].yzw;
  if(!all(isfinite(native_sun)) ||dot(native_sun,native_sun)<=.25f)native_sun=frame[38].xyz;
  // High cloud tops can still receive direct Sun after ground-level sunset.
  // Keep ground shadows on their original native primary-light convention.
  float height=max(CloudBase+1200.f*appearance.w,0.f);
  float horizon=terrain?-.015f:sqrt(saturate(1.f-pow(PlanetRadius/(PlanetRadius+height),2.f)));
  if(all(isfinite(native_sun)) &&dot(native_sun,native_sun)>.25f &&native_sun.z>-horizon)
    return normalize(native_sun);
  // The same native sky places the visible lunar lobe at b12[205].yzw.
  // Keeping the below-horizon sun here invalidated the entire night shadow
  // map even while cloud lighting used an above-horizon moon.
  float3 moon=frame[205].yzw;
  if(all(isfinite(moon)) &&dot(moon,moon)>.25f &&moon.z>.015f)return normalize(moon);
  return normalize(light[0].xyz+float3(0,0,1.e-8f));
}
// The native disc is much brighter than the cloud body at the user's low
// Density setting. Use one calibrated direct-beam column for the visible disc
// and the sunlight reaching terrain; otherwise one can vanish without the other.
float CloudDirectBeamScale() { return max(1.f,1.f/max(appearance.y,.125f)); }
// At a grazing light angle, a sun-aligned cache retains a useful footprint
// through the entire layer. Off preserves the existing vertical volume.
float2 CloudLightShear(float3 direction) {
  return trace_grid.z>.5f?direction.xy/max(direction.z,.02f)
      *(1.f-smoothstep(.10f,.15f,direction.z)):0.f;
}
float CloudThickness() {return 1200.f*appearance.w*lerp(1.f,.80f,cloud_light_weather);}
float CloudDetailScale() {return 1200.f*max(atmosphere.z,.2f)*lerp(1.f,.80f,cloud_light_weather);}
float CloudBaseReliefScale() {return CloudDetailScale()*saturate(atmosphere.y)*lerp(.25f,1.f,atmosphere.w);}
float CloudMinimum() {return CloudBase-.16f*CloudBaseReliefScale()*microstructure.z;}
float3 CloudRay(float2 uv) {
  float2 ndc=uv*float2(2,-2)+float2(-1,1);
  // The native inverse VP contains rounded camera translations. Subtracting
  // them again made a stationary ray wander with TAA jitter (~2 render pixels
  // in the captured scene). Invert the perspective and rigid rotation directly,
  // preserving native jitter without introducing world-space cancellation.
  float3 view=float3((ndc-frame[15].xy)/float2(frame[13].x,frame[14].y),1.f);
  return normalize(float3(dot(view,frame[1].xyz),dot(view,frame[2].xyz),dot(view,frame[3].xyz)));
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
float2 CloudShell(float3 origin,float3 ray,float base,float top) {
  float2 outer=CloudSphere(origin,ray,top);
  float2 inner=CloudSphere(origin,ray,base);
  float altitude=CloudAltitude(origin);
  float start=altitude<base ? inner.y : max(0.f,outer.x);
  float end=outer.y;
  if(altitude>=base && inner.x>0.f)end=min(end,inner.x);
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
float2 CloudInterval(float3 origin,float3 ray) {
  return CloudShell(origin,ray,CloudMinimum(),CloudBase+CloudThickness());
}
float CloudWeather(float3 p, out float storm_profile) {
  storm_profile=0.f;
  uint width,height,layers;
  weather.GetDimensions(width,height,layers);
  if(!width || !layers ||frame[66].x<=0.f)return 0.f;
  // The prefiltered native shadow field supplies broad weather coverage.
  // The prepass resolves native source/target coverage and the height-profile
  // weight before temporal filtering. Channels retain meaning at ID rollover.
  // Appearance size changes the billows, never the weather front's position,
  // extent or wind. Scaling both fields made large clouds relocate the rain
  // cover and its scene-wide sunlight attenuation.
  // Match the native broad weather field's world-space wind conversion.
  float2 uv=(p.xy+CloudWindOffset(frame[67].xy))*(.0005f/frame[66].x);
  float2 state=saturate(weather.SampleLevel(wrap_sampler,float3(uv,0),0));
  float authored=state.x;
  storm_profile=state.y;
  // Keep the strong original slider response on populated weather cells.
  // A zero or nearly clear native cell must not gain a blanket cloud floor.
  return appearance.x<=1.f ? authored*appearance.x
      : saturate(authored+(appearance.x-1.f)*(1.f-authored)*smoothstep(.02f,.2f,authored));
}
float CloudWeather(float3 p) {
  float storm_profile;
  return CloudWeather(p,storm_profile);
}
// Detail is the number of edge-erosion bands. Zero is a conservative coarse
// bound; one is used for nearby light/shadow rays, more for resolved view detail.
float CloudDensity(float3 p,uint detail,float lod,float footprint=0.f) {
  if(cloud_main_strength<=0.f)return 0.f;
  float height=(CloudAltitude(p)-CloudBase)/CloudThickness();
  if(height<=-.16f*CloudBaseReliefScale()*microstructure.z/CloudThickness() ||height>=1.f)return 0.f;
  float storm_profile;
  float coverage=CloudWeather(p,storm_profile);
  coverage=max(coverage,cloud_family_high.z*appearance.x);
  if(coverage<.002f)return 0.f;
  // Translate the noise with the weather-driven base. Keep the same height
  // reference for the low deck so it retains its established shape.
  float3 advected=p+float3(CloudWindOffset(frame[67].xy),CloudLowBase-CloudBase);
  // A separate rotated, wider column field breaks the alignment between the
  // 10 km weather tile and the smaller 3D billow tile without moving either
  // the authored weather front or the shared view/shadow world coordinates.
  float2 column_xy=float2(.8f*advected.x-.6f*advected.y,
      .6f*advected.x+.8f*advected.y)/(cloud_formation_period*1.7f);
  // Animate the unused noise axis, not the native weather probability field
  // (Nubis 2017, density-model animation). A 40-minute tile traversal slowly
  // grows/dissolves the column envelope while preserving its XY wind. The
  // existing periodic volume/filter makes crossings continuous, without a
  // second sample, crossfade, simulation or per-frame noise update.
  float4 column=shape_noise.SampleLevel(wrap_sampler,
      float3(column_xy,.375f+cloud_clock.x/2400.f),lod);
  // Let high Coverage intentionally close these smaller formation gaps.
  float breakup=lerp(1.f,lerp(.55f,1.3f,column.r),morphology.w);
  coverage=saturate(coverage*lerp(breakup,1.f,saturate(appearance.x-1.f)));
  // Preserve gaps by weather even when the slider saturates the native
  // mask. The same column field fills in progressively with heavier weather.
  float fill=cloud_family_high.x;
  float minimum_fill=saturate((fill-.30f)/.70f);
  float maximum_fill=saturate(fill*1.2f+.12f)*smoothstep(0.f,.13f,fill);
  coverage*=lerp(minimum_fill,maximum_fill,smoothstep(.37f,.76f,column.r));
  float opening = 0.f;
  float strand = 0.f;
  if (cloud_low_sun.w > 0.f) {
    // Use a broad Worley band alongside the formation potential so adjacent
    // columns cut into the arch at noticeably different heights.
    float edge_variation = .5f + 2.5f * (lerp(column.r, column.g, .35f) - .5f);
    opening = CloudLowSunOpening(p - frame[0].xyz, cloud_low_sun, edge_variation);
    if (opening > 0.f) {
      strand = smoothstep(.38f, .65f, column.b);
      float remaining = 1.f - opening;
      coverage *= remaining * lerp(remaining * remaining, 1.f, strand);
    }
  }
  if (coverage < .002f) return 0.f;
  // Shadow opacity is not cloud species/height. Inferring height inversely
  // from local cover raised thin edges above their cores, producing curtains
  // and making a fading weather mask grow taller. Use a coherent formation
  // profile; coverage changes only the fill, never the vertical envelope.
  float type=.4f+.5f*column.r;
  if(cloud_deck>0.f)type=lerp(type,.15f,cloud_deck*.65f);
  type=saturate(type+morphology.y*.35f);
  float top=lerp(.45f,1.f,type)*lerp(.7f,1.f,saturate(column.r*1.6f));
  top=clamp(lerp(.75f,top,morphology.z),.15f,1.f);
  float relative_height=height/max(top,.01f);
  if(relative_height>=1.f)return 0.f;
  // Retain the bulk vertical evolution used by cloud motion/reprojection.
  // Column/side shape changes are non-rigid; the existing current-frame
  // depth, transmission and radiance rejection handles their residual motion.
  advected.z+=cloud_clock.x*.6f;
  advected.xy+=(column.gb-.5f)*(140.f*height*height)*structure.z;
  // The second displacement plane varies across X/Z. Together with the
  // column's X/Y plane it bends the 3D Perlin-Worley material in all three
  // axes without moving the native weather front or its world-space shadow.
  // The second unused axis evolves twice as fast as the broad envelope. Its
  // bounded displacement turns billows over rather than translating the
  // whole cloud. All view/light/shadow/environment paths share this material.
  float4 side=shape_noise.SampleLevel(wrap_sampler,
      float3(advected.x/cloud_formation_period,.625f+cloud_clock.x/1200.f,advected.z/2800.f),lod);
  advected.xz+=(side.gb-.5f)*float2(100.f,60.f)*structure.y;
  float4 body=shape_noise.SampleLevel(wrap_sampler,
      advected/(float3(cloud_formation_period.xx,cloud_vertical_period)*structure.x),
      clamp(lod-log2(structure.x),0.f,4.f));
  // A dimensional envelope keeps coverage/connectivity separate from erosion.
  // Unlike the previous weighted average of three narrow-range fields, the
  // full formation range remains available for nested structures at high density.
  float scale=CloudDetailScale();
  float3 edge=advected+float3((body.ga-.5f)*100.f*structure.y,0);
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
  bottom_relief*=CloudBaseReliefScale()/CloudThickness()*microstructure.z;
  top_relief*=saturate(atmosphere.y)*scale/CloudThickness()*microstructure.w;
  float altitude_coordinate=saturate(relative_height+top_relief*.5f);
  // The atlas has two distinct envelopes: layer 4 and the ordinary profile.
  // Filter that weight with coverage, rather than changing height instantly
  // when the engine replaces its source/target IDs or interrupts a transition.
  float upper=profile_lut.SampleLevel(clamp_sampler,
      float3(altitude_coordinate,.5f,storm_profile>=1.f ? 4.f : 2.f),0).g;
  if(storm_profile>0.f &&storm_profile<1.f)
    upper=lerp(upper,profile_lut.SampleLevel(clamp_sampler,float3(altitude_coordinate,.5f,4),0).g,storm_profile);
  if(contour.w!=1.f)upper=pow(saturate(upper),contour.w);
  float profile=smoothstep(bottom_relief,bottom_relief+lerp(35.f,130.f,atmosphere.w)*contour.z/CloudThickness(),height)*upper;
  float potential=saturate(.3f+.9f*body.r+.2f*(column.r-.5f));
  if(cloud_deck>0.f)potential=lerp(potential,saturate(.6f+.45f*body.r),cloud_deck*.55f);
  float shape=saturate((potential*profile-(1.f-coverage))/max(coverage,.01f));
  if(detail>0 &&shape>0.f &&atmosphere.y>0.f) {
    // Detail has its own physical scale: making formations wider must not
    // inflate every small billow. Warp is coherent within a parent formation.
    // Nest fine billows in coarser ones. Upper growing regions retain rounded
    // lobes; lower/less dense regions dissipate into wisps (Nubis 2023).
    float billowy=lerp(.65f,1.f,type)*lerp(1.f-.25f*atmosphere.w,1.f,smoothstep(.04f,.45f,relative_height));
    billowy=saturate(billowy-microstructure.y*.5f);
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
    float retained=pow(max(1.f-erosion,1.e-4f),atmosphere.y*microstructure.x
        *lerp(1.f+.5f*atmosphere.w,1.f,smoothstep(0.f,.45f,relative_height)));
    shape=saturate((shape-(1.f-retained))/max(retained,1.e-4f));
  }
  if(shape>0.f &&shape<.55f &&atmosphere.y>0.f) {
    // Tighten only the feathered edge; retain dense interiors and the parent
    // formation. Reuse band-limited material detail instead of new scrolling
    // noise. The smooth monotone falloff preserves the coarse/fine bound.
    float edge=1.f-shape/.55f;
    shape=max(0.f,shape-.04f*contour.y*(features.g-features.b)
        *saturate(shape*20.f)*edge*edge*saturate(atmosphere.y));
    if(contour.x>0.f) {
      float u=saturate(shape/.55f);
      float feather=u*u*u;
      if(contour.x!=1.f)feather=pow(u,1.f+2.f*contour.x);
      shape=lerp(shape,.55f*feather*(3.f-2.f*u),saturate(atmosphere.y)*saturate(contour.x));
    }
  }
  if(structure.w!=1.f)shape=pow(saturate(shape),structure.w);
  if (opening > 0.f) {
    // Fade the resolved material as well as cutting gaps in the column.
    // The shared column noise keeps wisps and gaps coherent along each ray.
    float remaining = 1.f - opening;
    float diffuse = remaining * remaining;
    float filament = strand * lerp(.5f, 1.f, .5f * (side.a + features.a));
    shape = max(0.f, shape * lerp(diffuse * diffuse * remaining,
        remaining * lerp(.35f, 1.f, remaining), filament) - .005f * opening);
  }
  return shape*appearance.y*cloud_main_strength;
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
