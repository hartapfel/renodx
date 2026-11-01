// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_CLOUD_LIGHTING
#define CLASSIC_CLOUD_LIGHTING
// beta = 3 LWC / (2 rho_water r_eff): 0.5 g/m^3 liquid water and
// 10 micrometre effective droplets at unit procedural density.
static const float CloudOpticalExtinction=3.f*.0005f/(2.f*1000.f*1.e-5f);
static const float CloudScatteringAlbedo=.999f;
static const float CloudForwardG=.85f;

// Plane-parallel two-stream Eddington closure for diffuse incident skylight.
// Unlike direct-beam exp(-tau), this includes light scattered into the column.
// Returns reflected/transmitted fractions; the remainder is absorbed. It is
// a local-column approximation, not a full 3D multiple-scattering solution.
float2 CloudDiffuseTransport(float optical_depth) {
  float g=.9f*CloudForwardG-.1f*.2f;
  float gamma1=(7.f-CloudScatteringAlbedo*(4.f+3.f*g))*.25f;
  float gamma2=-(1.f-CloudScatteringAlbedo*(4.f-3.f*g))*.25f;
  float lambda=sqrt(max(gamma1*gamma1-gamma2*gamma2,0.f));
  float tau=max(optical_depth,0.f);
  float e=exp(-lambda*tau);
  // Stable (1-exp(-2 lambda tau))/lambda, including the conservative limit.
  float x=lambda*tau;
  float s=x<.001f ? 2.f*tau*(1.f-x+(2.f/3.f)*x*x) : (1.f-e*e)/lambda;
  float denominator=gamma1*s+1.f+e*e;
  return float2(gamma2*s,2.f*e)/denominator;
}
#endif
