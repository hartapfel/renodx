// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_WATER_TRANSPORT
#define CLASSIC_WATER_TRANSPORT
#include "../water/math.hlsli"

// Regional/weather material color interpreted at the same 10 m reference path
// on both sides of the interface. Density scales absorption AND scattering.
void WaterMaterialCoefficients(float3 color,float density,out float3 scattering,out float3 extinction) {
  color=clamp(color,.02f,.98f);
  scattering=max(density,0.f)*color/max(color.r,max(color.g,color.b));
  extinction=-log(color)*.1f*(max(density,0.f)/.03f)+scattering;
}

// PBRT 4, Specular Reflection and Transmission. eta is n_incident/n_transmitted;
// the cosine is positive on the incident side. Supports both sides of water,
// including total internal reflection (the edge of Snell's window).
float WaterInterfaceFresnel(float cosine, float eta) {
  float ci=saturate(cosine);
  float st2=eta*eta*max(0.f,1.f-ci*ci);
  if(st2>=1.f) return 1.f;
  float ct=sqrt(max(0.f,1.f-st2));
  float rs=(eta*ci-ct)/max(eta*ci+ct,1.e-7f);
  float rp=(ci-eta*ct)/max(ci+eta*ct,1.e-7f);
  return .5f*(rs*rs+rp*rp);
}

// Both vectors describe propagation: incident light toward a scattering event,
// outgoing light toward the camera. Positive g has its peak FORWARD, not back
// toward the source. PBRT's both-away convention requires the opposite sign.
float WaterPhase(float propagation_cosine, float g) {
  g=clamp(g,-.95f,.95f);
  float denominator=max(1.e-4f,1.f+g*g-2.f*g*clamp(propagation_cosine,-1.f,1.f));
  return (1.f-g*g)/(12.56637061436f*denominator*sqrt(denominator));
}

// Integral of exp(-tau(s)) over a cell whose optical depth varies linearly.
// Evaluate from the smaller endpoint to avoid overflow when the sunlight path
// gets SHORTER along an upward view ray. This includes the cancellation limit
// where eye-path and light-path extinction exactly balance (tau0 == tau1).
// Unlike multiplying midpoint transmission by cell length, this preserves the
// analytic homogeneous-medium solution even with very few integration cells.
float3 WaterOpticalCell(float3 tau0,float3 tau1,float length) {
  float3 difference=abs(tau1-tau0);
  return exp(-max(min(tau0,tau1),0.f))
      *WaterScatterIntegral(difference,1.f)*max(length,0.f);
}

// Sunlight reaches a sample along a refracted ray from the surface. Extinction
// acts on BOTH legs, before and after scattering. The caller splits the view
// segment at the actual water interface and supplies nonnegative water paths.
float3 WaterSunCell(float3 extinction,float eye_start,float eye_end,
                   float sun_start,float sun_end) {
  return WaterOpticalCell(extinction*(max(eye_start,0.f)+max(sun_start,0.f)),
      extinction*(max(eye_end,0.f)+max(sun_end,0.f)),max(eye_end-eye_start,0.f));
}

#endif
