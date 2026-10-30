// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_CLASSIC_MOON
#define WITCHER_CLASSIC_MOON
bool ClassicMoonTag(uint bits) { return (bits & 0xff000000u) == 0xd5000000u; }
float ClassicMoonBrightness(uint bits) {
  return ClassicMoonTag(bits) ? float((bits >> 13) & 2047u) / 1023.f : 1.f;
}
float3 ClassicMoonPosition(float3 position, float3 extent, float3 minimum, uint bits) {
  if (!ClassicMoonTag(bits)) return position;
  float3 center = minimum + .5f * extent;
  return center + (position - center) * (float(bits & 8191u) / 1024.f);
}
#endif
