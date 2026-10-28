// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_WATER_MATH
#define CLASSIC_WATER_MATH
// Air to water, unpolarized dielectric Fresnel. IOR 1.333. Unlike the legacy
// artistic reflection power, reflection and transmission share one energy budget.
float WaterFresnel(float cosine) {
  float c = saturate(cosine);
  float ct = sqrt(max(0.f, 1.f-(1.f-c*c)/(1.333f*1.333f)));
  float rs = (c-1.333f*ct)/max(c+1.333f*ct,1.e-6f);
  float rp = (1.333f*c-ct)/max(1.333f*c+ct,1.e-6f);
  return .5f*(rs*rs+rp*rp);
}
float3 WaterTransmittance(float3 extinction, float distance) {
  return exp(-max(extinction,0.f)*max(distance,0.f));
}
float3 WaterScatterIntegral(float3 extinction, float distance) {
  distance=max(distance,0.f);
  float3 optical_depth = max(extinction,0.f)*distance;
  // Stable at the shore and at vanishing extinction.
  return float3(
      optical_depth.x < 1.e-3f ? distance*(1.f-.5f*optical_depth.x) : (1.f-exp(-optical_depth.x))/max(extinction.x,1.e-20f),
      optical_depth.y < 1.e-3f ? distance*(1.f-.5f*optical_depth.y) : (1.f-exp(-optical_depth.y))/max(extinction.y,1.e-20f),
      optical_depth.z < 1.e-3f ? distance*(1.f-.5f*optical_depth.z) : (1.f-exp(-optical_depth.z))/max(extinction.z,1.e-20f));
}
// GGX NDF and height-correlated Smith visibility (Heitz / Filament).
float WaterSpecular(float3 normal, float3 view, float3 light, float alpha) {
  float3 half_vector = (view+light)*rsqrt(max(dot(view+light,view+light),1.e-10f));
  float nl=saturate(dot(normal,light)), nv=max(1.e-4f,saturate(dot(normal,view)));
  float nh=saturate(dot(normal,half_vector));
  float a2=max(alpha*alpha,1.e-4f);
  float denominator=1.f+(a2-1.f)*nh*nh;
  float distribution=a2/(3.141592654f*denominator*denominator);
  float visibility=.5f/max(1.e-6f,
      nl*sqrt(nv*nv*(1.f-a2)+a2)+nv*sqrt(nl*nl*(1.f-a2)+a2));
  return distribution*visibility*WaterFresnel(saturate(dot(view,half_vector)))*nl;
}
#endif
