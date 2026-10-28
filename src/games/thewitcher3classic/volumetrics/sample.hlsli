// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_CLASSIC_VOLUME_SAMPLE
#define WITCHER_CLASSIC_VOLUME_SAMPLE
Texture3D<float4> ClassicFogVolume : register(t116);
StructuredBuffer<float4> ClassicFogParameters : register(t117);
SamplerState ClassicFogSampler : register(s11);
bool ClassicFogReady() {
  uint count, stride;
  ClassicFogParameters.GetDimensions(count,stride);
  return count == 4 && ClassicFogParameters[0].w > 0.f;
}
float4 SampleClassicFog(float2 uv, float distance) {
  float4 grid = ClassicFogParameters[0];
  float near_distance = ClassicFogParameters[2].y;
  float slice = log(max(distance,near_distance)/near_distance)/log(grid.w/near_distance)*grid.z;
  return ClassicFogVolume.SampleLevel(ClassicFogSampler,float3(saturate(uv),(clamp(slice,0.f,grid.z)+.5f)/(grid.z+1.f)),0);
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
// Disable its separate artistic desaturation and supply the same L/T integral.
void ClassicForwardFog(float4 position, inout float desaturation, inout float4 fog) {
  if (ClassicFogReady()) {
    float4 integrated = SampleClassicFogPixel(position);
    float opacity = saturate(1.f-integrated.a);
    fog = float4(opacity > 1.e-7f ? integrated.rgb/opacity : 0.f,opacity);
    desaturation = 0.f;
  }
}
#endif
