// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_CLOUD_LIGHTING
#define CLASSIC_CLOUD_LIGHTING
#include "../fog/math.hlsli"
// beta = 3 LWC / (2 rho_water r_eff): 0.5 g/m^3 liquid water and
// 10 micrometre effective droplets at unit procedural density.
static const float CloudOpticalExtinction=3.f*.0005f/(2.f*1000.f*1.e-5f);
// 0.01 g/m^3 ice-water content, 30 micrometre effective crystals, 300 m
// geometric thickness: a thin high layer remains optically distinct.
static const float CirrusOpticalDepth=3.f*.00001f*300.f/(2.f*1000.f*3.e-5f);
static const float CloudScatteringAlbedo=.999f;
// Rockstar's cloud phase reference uses g = 0.8. The narrower 0.85 lobe
// turned under-sampled near-sun scattering into a conspicuous bright disc.
static const float CloudForwardG=.8f;

// Bauer 2019, slides 29-32: two phase octaves and an extinction-dependent
// backscatter floor. Both the lower volume and cirrus use this scattering
// law with their own material extinction and light optical depth.
float CloudDirectScattering(float cosine,float sigma,float tau) {
  float first=.9f*PhaseHG(cosine,CloudForwardG)+.1f*PhaseHG(cosine,-.2f);
  float second=.5f*CloudScatteringAlbedo*(.9f*PhaseHG(cosine,CloudForwardG*(2.f/3.f))
      +.1f*PhaseHG(cosine,-.2f*(2.f/3.f)));
  float backscatter=.318309886f*saturate((sigma-.03f)/.06f);
  return max(first,backscatter)*exp(-tau)
      +second*saturate(sigma/CloudOpticalExtinction)*exp(-tau*.5f);
}

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
