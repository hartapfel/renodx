// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
Texture2D<float4> ClassicFogScattering : register(t108);
Texture2D<float> ClassicFogEndpoint : register(t109);
bool SampleClassicOpaqueScattering(float2 uv,float distance,out float3 result) {
  result=0.f;
  uint width,height;ClassicFogScattering.GetDimensions(width,height);
  float2 render_size=round(rcp(ClassicFogParameters[3].xy));
  if(width==0 ||height==0 ||any(float2(width,height)!=render_size))return false;
  int2 pixel=clamp(int2(uv*render_size),0,int2(width,height)-1);
  float endpoint=ClassicFogEndpoint.Load(int3(pixel,0));
  if(endpoint<0.f ||abs(endpoint-distance)>max(.05f,distance*.005f))return false;
  result=ClassicFogScattering.Load(int3(pixel,0)).rgb;return true;
}
