// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_SKY_LIGHTING
#define HARTAPFEL_SKY_LIGHTING
// Change a source spectrum without changing native luminance or alpha. Used
// before scattering/reflection, never as a tint of the finished HDR scene.
float3 MatchLightSpectrum(float3 radiance,float4 spectrum) {
  if(spectrum.w<=0.f)return radiance;
  float luminance=dot(max(radiance,0.f),float3(.2126f,.7152f,.0722f));
  return max(spectrum.rgb,0.f)*(luminance/max(dot(spectrum.rgb,float3(.2126f,.7152f,.0722f)),1.e-8f));
}
// Native night light and the visible Moon can differ substantially in altitude.
// Use the visible lunar direction for sky air, with a continuous twilight fade.
// This changes sky rendering only; the game's world-light constants stay intact.
float3 SkyAtmosphereLight(float3 solar,float3 lunar,float3 native_light) {
  if(!all(isfinite(lunar))||dot(lunar,lunar)<.25f)return native_light;
  float weight=(1.f-smoothstep(-.105f,.015f,solar.z))*smoothstep(-.015f,.035f,lunar.z);
  if(weight<=0.f)return native_light;
  lunar=normalize(lunar);
  if(dot(native_light,native_light)<.25f)return lunar;
  return normalize(lerp(normalize(native_light),lunar,weight));
}
#endif
