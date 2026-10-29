// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_CLASSIC_VOLUME_SAMPLE
#define WITCHER_CLASSIC_VOLUME_SAMPLE
Texture3D<float4> ClassicFogVolume : register(t116);
StructuredBuffer<float4> ClassicFogParameters : register(t117);
SamplerState ClassicFogSampler : register(s11);
#include "per_pixel.hlsli"
bool ClassicFogReady() {
  uint count, stride;
  ClassicFogParameters.GetDimensions(count,stride);
  // Retain old live-shader parameter buffers during addon/shader iteration.
  return (count == 4 || count == 21 || count == 22) && ClassicFogParameters[0].w > 0.f;
}
float4 SampleClassicFogRaw(float2 uv, float distance) {
  if (ClassicPixelFogReady()) {
    return SampleClassicPixelFog(uv,distance);
  } else {
    float4 grid = ClassicFogParameters[0];
    float near_distance = ClassicFogParameters[2].y;
    float slice = log(max(distance,near_distance)/near_distance)/log(grid.w/near_distance)*grid.z;
    float3 size = float3(grid.xy,grid.z+1.f);
    float3 coordinate = float3(saturate(uv),(clamp(slice,0.f,grid.z)+.5f)/size.z);
    float4 linear_sample = ClassicFogVolume.SampleLevel(ClassicFogSampler,coordinate,0);
    uint count,stride;
    ClassicFogParameters.GetDimensions(count,stride);
    if (count != 22) return linear_sample;
    if (ClassicFogParameters[21].x < .5f) return linear_sample;
    // Sigg/Hadwiger, GPU Gems 2 chapter 20: nonnegative cubic B-spline
    // reconstruction using eight trilinear fetches. Smooth the direct-light
    // field, retaining the original linear opacity and native weather strength.
    float3 pixel = coordinate*size-.5f;
    float3 fraction = frac(pixel);
    float3 f2 = fraction*fraction, f3 = f2*fraction;
    float3 w0 = (1.f-3.f*fraction+3.f*f2-f3)/6.f;
    float3 w1 = (4.f-6.f*f2+3.f*f3)/6.f;
    float3 w2 = (1.f+3.f*fraction+3.f*f2-3.f*f3)/6.f;
    float3 w3 = f3/6.f;
    float3 first = w0+w1, second = w2+w3;
    float3 p0 = (floor(pixel)-.5f+w1/first)/size;
    float3 p1 = (floor(pixel)+1.5f+w3/second)/size;
    float3 a = lerp(ClassicFogVolume.SampleLevel(ClassicFogSampler,float3(p0.x,p0.y,p0.z),0).rgb,
        ClassicFogVolume.SampleLevel(ClassicFogSampler,float3(p1.x,p0.y,p0.z),0).rgb,second.x);
    float3 b = lerp(ClassicFogVolume.SampleLevel(ClassicFogSampler,float3(p0.x,p1.y,p0.z),0).rgb,
        ClassicFogVolume.SampleLevel(ClassicFogSampler,float3(p1.x,p1.y,p0.z),0).rgb,second.x);
    float3 c = lerp(ClassicFogVolume.SampleLevel(ClassicFogSampler,float3(p0.x,p0.y,p1.z),0).rgb,
        ClassicFogVolume.SampleLevel(ClassicFogSampler,float3(p1.x,p0.y,p1.z),0).rgb,second.x);
    float3 d = lerp(ClassicFogVolume.SampleLevel(ClassicFogSampler,float3(p0.x,p1.y,p1.z),0).rgb,
        ClassicFogVolume.SampleLevel(ClassicFogSampler,float3(p1.x,p1.y,p1.z),0).rgb,second.x);
    return float4(lerp(lerp(a,b,second.y),lerp(c,d,second.y),second.z),linear_sample.a);
  }
}
float3 ClassicFogDirect(float4 fog) {
  uint count,stride;
  ClassicFogParameters.GetDimensions(count,stride);
  if (count == 22) return max(fog.rgb,0.f);
  return max(fog.rgb-max(ClassicFogParameters[8].rgb,0.f)*saturate(1.f-fog.a),0.f);
}
// Native C8C78997/forward weather controls shape fog color independently of
// extinction. Preserve their endpoint color, two local overrides and background
// desaturation, while keeping the volume's shadowed direct-light contribution.
float4 SampleClassicFog(float2 uv, float distance, out float4 desaturation) {
  float4 fog = SampleClassicFogRaw(uv,distance);
  desaturation = 0.f;
  uint count,stride;
  ClassicFogParameters.GetDimensions(count,stride);
  if (count != 21 && count != 22) return fog;
  float opacity = saturate(1.f-fog.a);
  float4 profile = ClassicFogParameters[4];
  float4 curve = ClassicFogParameters[5];
  float path = max(0.f,distance-max(ClassicFogParameters[1].y,curve.w));
  if (profile.z > 0.f) path = min(path,profile.z);
  float fade = saturate((path-curve.y)*curve.z);
  float density_opacity = fade > 1.e-7f
      ? pow(saturate(opacity/fade),rcp(max(profile.w,.0001f))) : 0.f;
  desaturation.w = density_opacity > 0.f ? pow(density_opacity,max(curve.x,0.f))*fade : 0.f;
  float2 ndc = saturate(uv)*float2(2,-2)+float2(-1,1);
  float3 ray = normalize(ndc.x*ClassicFogParameters[18].xyz
      +ndc.y*ClassicFogParameters[19].xyz+ClassicFogParameters[20].xyz);
  float cosine = dot(ray,ClassicFogParameters[6].xyz);
  float angular = cosine*cosine*saturate(path*.002f-.3f);
  float3 base = lerp(ClassicFogParameters[8].rgb,
      cosine > 0.f ? ClassicFogParameters[7].rgb : ClassicFogParameters[9].rgb,angular);
  desaturation.rgb = lerp(ClassicFogParameters[11].rgb,
      cosine > 0.f ? ClassicFogParameters[10].rgb : ClassicFogParameters[12].rgb,angular);
  float2 weights = saturate(opacity*ClassicFogParameters[14].xz+ClassicFogParameters[14].yw);
  float4 weather = float4(lerp(base,ClassicFogParameters[13].rgb,weights.x),
      saturate(opacity*lerp(1.f,ClassicFogParameters[13].w,weights.y)));
  if (ClassicFogParameters[17].x > 0.f) {
    weights = saturate(opacity*ClassicFogParameters[16].xz+ClassicFogParameters[16].yw);
    float4 second = float4(lerp(base,ClassicFogParameters[15].rgb,weights.x),
        saturate(opacity*lerp(1.f,ClassicFogParameters[15].w,weights.y)));
    weather = lerp(weather,second,ClassicFogParameters[17].x);
  }
  float3 direct = ClassicFogDirect(fog);
  return float4(weather.rgb*weather.a+direct*(opacity > 1.e-7f ? weather.a/opacity : 0.f),1.f-weather.a);
}
float4 SampleClassicFog(float2 uv, float distance) {
  float4 desaturation;
  return SampleClassicFog(uv,distance,desaturation);
}
// D3D11 pixel-shader SV_Position.w is interpolated clip W (unlike GLSL's
// gl_FragCoord.w). Classic uses view Z for clip W. Confirmed against native
// world-position varyings: 11.2266 m must not become 0.0928 m.
// This samples at the transparent fragment, never at opaque depth behind it.
float4 SampleClassicFogPixel(float4 position) {
  float4 sampling = ClassicFogParameters[3];
  float2 uv = position.xy * sampling.xy;
  float2 ndc = uv * float2(2,-2) + float2(-1,1);
  float distance = length(float3(ndc*sampling.zw,1.f)) * abs(position.w);
  return SampleClassicFog(uv,distance);
}
// The native forward material performs lerp(surface, fog.rgb, fog.a).
// Retain native artistic desaturation at the sampled medium opacity.
void ClassicForwardFog(float4 position, inout float desaturation, inout float4 fog) {
  if (ClassicFogReady()) {
    float4 sampling = ClassicFogParameters[3];
    float2 uv = position.xy*sampling.xy;
    float2 ndc = uv*float2(2,-2)+float2(-1,1);
    float distance = length(float3(ndc*sampling.zw,1.f))*abs(position.w);
    float4 weather_desaturation;
    float4 integrated = SampleClassicFog(uv,distance,weather_desaturation);
    float opacity = saturate(1.f-integrated.a);
    fog = float4(opacity > 1.e-7f ? integrated.rgb/opacity : 0.f,opacity);
    desaturation = weather_desaturation.w;
  }
}
#endif
