// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_CLASSIC_FOG_INTERIOR
#define WITCHER_CLASSIC_FOG_INTERIOR
// Integral of smoothstep(0, width, distance). Integrating the boundary fade
// over a cell avoids a whole logarithmic slice switching on at a doorway.
float FogBoundaryIntegral(float distance, float width) {
  float t = saturate(distance / width);
  return max(distance - width, 0.f) + width * t * t * t * (1.f - .5f * t);
}
// Native t24 stores radial entry/exit distances, normalized by light[34].z.
// x < y: interior between the boundaries. x > y: camera starts inside,
// exits at y and can enter another interior at x. Equal values mean no volume.
// Keep the two-metre cubic transition on the EXTERIOR side of each boundary:
// authored interiors contain no medium, while outdoor fog approaches smoothly.
float FogExteriorFraction(float2 boundaries, float begin, float end) {
  if (boundaries.x == boundaries.y) return 1.f;
  float width = min(2.f, .5f * abs(boundaries.y - boundaries.x));
  width = max(width, .0001f);
  float entry = (FogBoundaryIntegral(end - boundaries.x + width, width)
               - FogBoundaryIntegral(begin - boundaries.x + width, width)) / (end - begin);
  float exit = (FogBoundaryIntegral(end - boundaries.y, width)
              - FogBoundaryIntegral(begin - boundaries.y, width)) / (end - begin);
  return saturate((boundaries.x < boundaries.y ? 1.f : 0.f) - entry + exit);
}
#endif
