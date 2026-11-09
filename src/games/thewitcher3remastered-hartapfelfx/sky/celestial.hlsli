// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CELESTIAL
#define HARTAPFEL_CELESTIAL
#include "../night/shared.h"
#include "lighting.hlsli"
#ifndef SKY_SUN_EMISSION
#define SKY_SUN_EMISSION float4(0,0,0,0)
#endif
#ifndef SKY_MOON_EMISSION
#define SKY_MOON_EMISSION float4(0,0,0,0)
#endif
// Both native sky variants and the cloud composite evaluate the same sources.
// The caller supplies its existing frame array and shared cloud buffer.
bool SkyReady() {
  return SKY_DATA.Load(316)==0x534B5931u && SKY_DATA.Load(308)>=512u;
}
float3 SkyDirection(float3 direction) {
  return direction*rsqrt(max(dot(direction,direction),1.e-12f));
}
float SkySize(bool moon) {
  uint tag=asuint(moon ? SKY_FRAME[37].w : SKY_FRAME[206].w);
  bool valid=moon ? (tag&WITCHER_MOON_TAG_MASK)==WITCHER_MOON_TAG
      : (tag&WITCHER_SKY_TAG_MASK)==WITCHER_SKY_TAG;
  return valid ? clamp(float(tag&WITCHER_CELESTIAL_FACTOR_MASK)/8192.f,.01f,5.f) : 1.f;
}
float SkyMoonBrightness() {
  uint tag=asuint(SKY_FRAME[37].w);
  return (tag&WITCHER_MOON_TAG_MASK)==WITCHER_MOON_TAG
      ? float((tag>>16u)&WITCHER_MOON_BRIGHTNESS_MASK)/511.f : 1.f;
}
// Native mesh bounds/world transform determine the base angle. Existing
// percentage sliders scale that authored angle exactly once.
float SkyRadius(bool moon) {
  return min(sin(max(moon?SKY_NATIVE_RADIUS.y:SKY_NATIVE_RADIUS.x,0.f))*SkySize(moon),.999f);
}
// Kasten-Young air mass, with wavelength-dependent Rayleigh and neutral aerosol
// extinction. Scene radiance is calibrated to the engine, not absolute cd/m2.
float SkyAirMass(float elevation) {
  float elevation_degrees=degrees(asin(clamp(elevation,-1.f,1.f)));
  return min(rcp(max(elevation,0.f)+.50572f*pow(max(elevation_degrees+6.07995f,.1f),-1.6364f)),40.f);
}
float3 SkyAtmosphere(float elevation) {
  return exp(-float3(.105f,.195f,.385f)*SkyAirMass(elevation))
      *smoothstep(-.012f,.001f,elevation);
}
float SkySolarTransmission(float elevation) {
  // Retain the established low-Sun attenuation without recolouring the
  // native Sun material, which already carries its authored warm/cool tint.
  return exp(-.105f*SkyAirMass(elevation))*smoothstep(-.012f,.001f,elevation);
}
float SkySolarRadiance() {
  float native_peak=max(max(SKY_FRAME[199].r,SKY_FRAME[199].g),SKY_FRAME[199].b)
      *max(SKY_FRAME[203].x*SKY_FRAME[203].y,1.f);
  return clamp(native_peak*32.f,160.f,800.f);
}
float3 SkySolarColour() {
#ifdef SKY_SUN_EMISSION
  if(SKY_SUN_EMISSION.w>0.f)
    return SKY_SUN_EMISSION.rgb/max(max(SKY_SUN_EMISSION.r,SKY_SUN_EMISSION.g),max(SKY_SUN_EMISSION.b,1.e-8f));
#endif
#ifdef SKY_SOLAR_MATERIAL
  float4 material=SKY_SOLAR_MATERIAL;
  if(material.w==1.f)return max(material.rgb,0.f);
#endif
  float3 colour=max(SKY_FRAME[199].rgb,0.f);
  return colour/max(max(colour.r,max(colour.g,colour.b)),1.e-20f);
}
float SkySolarGlowSize() {
#ifdef SKY_SOLAR_GLOW_SIZE
  return SKY_SOLAR_GLOW_SIZE>0.f ? clamp(SKY_SOLAR_GLOW_SIZE,.25f,4.f) : 1.25f;
#else
  return 1.25f;
#endif
}
float3 SkyMoonLight() {
  // Both native Moon pixel shaders use this independent world-space phase
  // vector. Visible sky positions can remain fixed while game days advance.
  float phase=frac(SKY_CLOCK.y*.033863864839076996f+SKY_CLOCK.w)*6.28318530718f;
  float sine,cosine;sincos(phase,sine,cosine);
  return float3(cosine,sine,0.f);
}
float3 SkyMoonColour() {
  // Standard Moon uses material b2[0]; Toussaint uses frame[277]. Both
  // multiply material b2[2]. A CPU-visible native material is sampled without
  // GPU readback; the frame colour is the safe first-frame/unavailable fallback.
#ifdef SKY_MOON_MATERIAL
  float4 material=SKY_MOON_MATERIAL;
  if(material.w==1.f)return MatchLightSpectrum(max(material.rgb,0.f),SKY_MOON_EMISSION);
  if(material.w==2.f)return MatchLightSpectrum(max(SKY_FRAME[277].rgb*material.rgb,0.f),SKY_MOON_EMISSION);
#endif
  return MatchLightSpectrum(max(SKY_FRAME[277].rgb,0.f),SKY_MOON_EMISSION);
}
// Native far-sky veil, including both weather fog colour/opacity overrides.
// This is also used by the cloud correction; no emitter can escape that veil.
float SkyFogTransmission(float3 ray) {
  float4 profile=SKY_FRAME[42], curve=SKY_FRAME[44];
  if(profile.z<SKY_FRAME[48].y)return 1.f;
  float directional=saturate((profile.x+dot(ray,SkyAtmosphereLight(SKY_FRAME[204].yzw,
      SKY_FRAME[205].yzw,SKY_FRAME[38].xyz)))/max(1.f+profile.x,.0001f));
  float falloff=max(0.f,lerp(curve.z,curve.y,directional));
  float segment=max(profile.z,0.f)/16.f;
  float height=profile.y+SKY_FRAME[0].z+ray.z*SKY_FRAME[22].z;
  float transmission=1.f;
  [unroll]for(uint i=1u;i<=16u;++i)
    transmission*=1.f-saturate(segment*max(curve.x,0.f)/(1.f+max(0.f,falloff*(height+ray.z*segment*i))));
  float density=max(asfloat(SKY_DATA.Load(312)),0.f);
  float opacity=pow(saturate(1.f-pow(saturate(transmission),density)),max(profile.w,.0001f))
      *saturate((profile.z-SKY_FRAME[48].y)*SKY_FRAME[48].z);
  float primary=saturate(lerp(1.f,SKY_FRAME[189].w,saturate(SKY_FRAME[190].z*opacity+SKY_FRAME[190].w))*opacity);
  float secondary=saturate(lerp(1.f,SKY_FRAME[191].w,saturate(SKY_FRAME[192].z*opacity+SKY_FRAME[192].w))*opacity);
  return 1.f-saturate(lerp(primary,secondary,saturate(SKY_FRAME[193].x)));
}
uint SkyHash(uint value) {
  value^=value>>16u;value*=0x7FEB352Du;value^=value>>15u;
  value*=0x846CA68Bu;return value^(value>>16u);
}
float SkyMoonTexel(int2 cell,uint2 size,uint offset) {
  cell.x=(cell.x%int(size.x)+int(size.x))%int(size.x);cell.y=clamp(cell.y,0,int(size.y)-1);
  uint address=uint(cell.y)*size.x+uint(cell.x);
  return float((SKY_DATA.Load(offset+(address&~3u))>>((address&3u)*8u))&255u)/255.f;
}
float SkyMoonLevel(float2 uv,uint mip) {
  uint offset=SKY_DATA.Load(308);uint2 size=uint2(512,256);
  [loop]for(uint i=0u;i<mip;++i) {
    offset+=(size.x*size.y+3u)&~3u;size=max(size>>1u,1u);
  }
  float2 pixel=uv*size-.5f;
  int2 cell=int2(floor(pixel));float2 f=frac(pixel);
  return lerp(lerp(SkyMoonTexel(cell,size,offset),SkyMoonTexel(cell+int2(1,0),size,offset),f.x),
      lerp(SkyMoonTexel(cell+int2(0,1),size,offset),SkyMoonTexel(cell+1,size,offset),f.x),f.y);
}
float SkyMoonAlbedo(float3 normal,float footprint) {
  // NASA map is centred on longitude zero (the familiar near side).
  float2 uv=float2(atan2(normal.x,normal.z)/6.28318530718f+.5f,
      acos(clamp(normal.y,-1.f,1.f))/3.14159265359f);
  float lod=clamp(log2(max(footprint*512.f/(6.28318530718f*max(normal.z,.08f)),1.f)),0.f,9.f);
  uint mip=uint(floor(lod));
  return lerp(SkyMoonLevel(uv,mip),SkyMoonLevel(uv,min(mip+1u,9u)),frac(lod))/.328722726f;
}
float SkyDisc(float3 ray,float3 direction,float radius,float footprint,out float radial) {
  if(radius<=0.f){radial=2.f;return 0.f;}
  // Cross product retains precision for sub-degree discs; 1-dot loses it.
  radial=length(cross(ray,direction))/max(radius,1.e-6f);
  float width=max(footprint/max(radius,1.e-6f),.001f);
  return dot(ray,direction)>0.f ? 1.f-smoothstep(1.f-width*.5f,1.f+width*.5f,radial) : 0.f;
}
void SkyDiscs(float3 ray,float footprint,float fog_transmission,
    out float3 sun,out float3 moon,out float moon_mask) {
  sun=0.f;moon=0.f;moon_mask=0.f;
  float3 solar=SkyDirection(SKY_FRAME[204].yzw),lunar=SkyDirection(SKY_FRAME[205].yzw);
  float solar_radius=SkyRadius(false),lunar_radius=SkyRadius(true);
  float radial;
  float mask=SkyDisc(ray,solar,solar_radius,max(footprint,solar_radius*.12f),radial);
  [branch]if(mask>0.f && dot(solar,solar)>.5f) {
    float mu=sqrt(saturate(1.f-radial*radial));
    // Linear limb darkening (u=.6), normalized by its disc average 1-u/3.
    // Match the engine's sky exposure range. The previous 40000-unit source
    // stayed white even after strong extinction, appearing in front of clouds.
    // Reserve 45% of the source profile for the overlapping aureole below.
    // Merely adding a tiny halo behind a saturated disc leaves a hard rim.
    sun=.55f*SkySolarRadiance()*SkySolarColour()*(.4f+.6f*mu)/.8f*mask
        *SkySolarTransmission(ray.z)*fog_transmission;
  }
  moon_mask=SkyDisc(ray,lunar,lunar_radius,footprint,radial);
  sun*=1.f-moon_mask;
  [branch]if(moon_mask>0.f && dot(lunar,lunar)>.5f) {
    float3 east=SkyDirection(cross(abs(lunar.z)>.99f ? float3(0,1,0) : float3(0,0,1),lunar));
    float3 north=cross(lunar,east);
    float2 xy=float2(dot(ray,east),dot(ray,north))/lunar_radius;
    float mu=sqrt(saturate(1.f-dot(xy,xy)));
    float3 normal=east*xy.x+north*xy.y-lunar*mu;
    float3 phase_light=SkyMoonLight();
    float incidence=max(dot(normal,phase_light),0.f);
    // Lommel-Seeliger for particulate lunar regolith, with a small Lambert term.
    float reflection=.9f*2.f*incidence/max(incidence+mu,.001f)+.1f*incidence;
    float earthshine=.0015f*saturate((1.f+dot(lunar,phase_light))*.5f);
    // Match vanilla's linear material colour and Lambert full-disc mean (2/3).
    // Keep the new terrain/regolith phase model; do not apply a second warm
    // spectral filter on top of the engine-authored lunar colour.
    moon=(.328722726f*2.f/3.f)*SkyMoonColour()*SkyMoonAlbedo(float3(xy,mu),footprint/lunar_radius)
        *(reflection+earthshine)*moon_mask*SkyMoonBrightness()
        *smoothstep(-.012f,.001f,ray.z)*fog_transmission;
  }
}
// Finite-source, forward Mie lobes: the source radius softens the HG peak,
// while a second broader lobe supplies a continuous, bounded aureole. This is
// atmospheric radiance, not an unoccluded screen-space flare or blurred disc.
float SkyAureole(float3 ray,float3 direction,float radius,float g,float angular_scale) {
  if(dot(ray,direction)<=0.f)return 0.f;
  // Scale the entire profile, including its shoulder/support, with the slider.
  float angle2=dot(ray-direction,ray-direction)/(angular_scale*angular_scale);
  float reference_radius=radius/angular_scale;
  float width=(1.f-g)*(1.f-g)+.5f*g*reference_radius*reference_radius;
  float lobe=pow(width/(width+g*angle2),1.5f);
  // Fourth-order compact falloff is already very dim before its support ends.
  // A bright flat tail followed by a 20..25-degree fade becomes a second disc
  // after tone mapping, especially when the sky behind the aureole is dark.
  float envelope=saturate(1.f-angle2/.187f);
  return lobe*envelope*envelope*envelope*envelope;
}
float3 SkyGlow(float3 ray,float fog_transmission) {
  float3 solar=SkyDirection(SKY_FRAME[204].yzw),lunar=SkyDirection(SKY_FRAME[205].yzw);
  float scale=max(SKY_FRAME[203].x*SKY_FRAME[203].y,1.f);
  float glow_size=SkySolarGlowSize();
  float sun_size=SkySize(false)*glow_size,moon_size=SkySize(true);
  float mass=SkyAirMass(solar.z);
  float grazing=1.f-exp(-.12f*max(mass-1.f,0.f));
  float solar_radius=SkyRadius(false)*glow_size;
  // The native common builder already scales exponent by 1/SunSize^2.
  // Undo that before the common angular transform, avoiding double scaling.
  float native_exponent=SKY_FRAME[204].x*SkySize(false)*SkySize(false);
  float angle2=dot(ray-solar,ray-solar)/(sun_size*sun_size);
  float envelope=saturate(1.f-angle2/.187f);
  // Native sky: pow(saturate(dot(view,sun)),frame[204].x). Its weather/time
  // curve supplies the sunrise/sunset width as well as the original style.
  float sun_phase=pow(saturate(1.f-.5f*angle2),max(native_exponent,1.f))
      *envelope*envelope*envelope*envelope;
  // Strong overlap belongs near the photosphere, not across the broad HG
  // shoulder. A radius-relative Gaussian core prevents a huge glowing disc.
  float core=solar_radius>0.f?exp(-1.183432f*dot(ray-solar,ray-solar)/max(solar_radius*solar_radius,1.e-12f)):0.f;
  // The body and atmosphere have distinct native colour inputs. Keep their
  // linear RGB ratios: applying another warm spectral filter double-tints the
  // engine's already authored weather/sunrise/sunset curves.
  float glow_exposure=SKY_FRAME[203].w;
#ifdef SKY_GLOW_EXPOSURE
  if(SKY_GLOW_EXPOSURE==2u)glow_exposure=1.f;
#endif
  float3 native_glow=max(SKY_FRAME[199].rgb,0.f)*max(SKY_FRAME[203].x*SKY_FRAME[203].y*glow_exposure,0.f)
      *saturate(SKY_FRAME[206].x);
  native_glow=MatchLightSpectrum(native_glow,SKY_SUN_EMISSION);
  float3 glow=SkySolarRadiance()*.45f*core*SkySolarColour()*SkySolarTransmission(solar.z)
      +native_glow*sun_phase*smoothstep(-.012f,.001f,solar.z);
  // A low aerosol layer still receives sunlight just after the observer's
  // sunset. Use its shorter optical path, then smoothly extinguish its light
  // as it enters Earth's shadow. No post-tonemap colour/exposure adjustment.
  float twilight=smoothstep(-.045f,-.005f,solar.z);
  glow+=native_glow*.15f*grazing*twilight*sun_phase;
  float illuminated=saturate((1.f-dot(SkyMoonLight(),lunar))*.5f);
  float lunar_peak=max(max(SKY_FRAME[202].r,SKY_FRAME[202].g),SKY_FRAME[202].b)*scale;
  float moon_phase=.85f*SkyAureole(ray,lunar,SkyRadius(true),.96f,moon_size)
      +.15f*SkyAureole(ray,lunar,SkyRadius(true),.82f,moon_size);
  glow+=(.04f+clamp(lunar_peak*.08f,0.f,.3f))*SkyMoonColour()*moon_phase
      *pow(illuminated,1.5f)*SkyMoonBrightness()*smoothstep(-.012f,.001f,lunar.z);
  return glow*fog_transmission;
}
float3 SkyStars(float3 ray,float footprint,float fog_transmission,float moon_mask) {
  float night=1.f-smoothstep(-.208f,-.05234f,SkyDirection(SKY_FRAME[204].yzw).z);
  float gain=max(asfloat(SKY_DATA.Load(304)),0.f)*night*fog_transmission*(1.f-moon_mask);
  [branch]if(gain<=1.e-6f ||ray.z<=0.f)return 0.f;
  // World-anchored spherical cells: no cube seams, camera swimming or animated
  // noise. Only a sparse shell contains stars. The field is fictional, not a catalogue.
  const float grid=96.f;
  float3 p=ray*grid;
  int3 cell=int3(floor(p));
  float sigma=max(footprint*.65f,.00018f);
  float3 radiance=0.f;
  [loop]for(int z=-1;z<=1;++z)[loop]for(int y=-1;y<=1;++y)[loop]for(int x=-1;x<=1;++x) {
    int3 c=cell+int3(x,y,z);
    uint hash=SkyHash(asuint(c.x)*73856093u^asuint(c.y)*19349663u^asuint(c.z)*83492791u);
    [branch]if((hash&65535u)<2294u) {
      uint h1=SkyHash(hash),h2=SkyHash(h1),h3=SkyHash(h2);
      float3 center=float3(c)+float3(h1&65535u,h2&65535u,h3&65535u)/65536.f;
      float radius=length(center);
      [branch]if(abs(radius-grid)<.5f) {
        float3 direction=center/max(radius,1.e-6f);
        float angle=length(cross(ray,direction));
        float kernel=exp(-.5f*angle*angle/(sigma*sigma))*.00000036f/(sigma*sigma);
        // Magnitude-to-flux conversion. Dim stars outnumber bright stars.
        float magnitude=1.f+5.f*sqrt(float(h1>>16u)/65535.f);
        float flux=pow(10.f,-.4f*(magnitude-1.f));
        float temperature=float(h2>>16u)/65535.f;
        float3 color=temperature<.35f ? lerp(float3(1.f,.57f,.32f),float3(1.f,.91f,.78f),temperature/.35f)
            :lerp(float3(1.f,.91f,.78f),float3(.60f,.75f,1.f),(temperature-.35f)/.65f);
        radiance+=color*flux*kernel;
      }
    }
  }
  // Eight times the previous .2 scene-unit base. The user's saved 100%/zero
  // brightness, filtering and atmospheric/cloud attenuation retain their roles.
  return radiance*1.6f*gain*SkyAtmosphere(ray.z);
}
#endif
