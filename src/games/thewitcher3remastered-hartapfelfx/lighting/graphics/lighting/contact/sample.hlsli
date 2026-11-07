// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef REMASTERED_CONTACT_SAMPLE
#define REMASTERED_CONTACT_SAMPLE
ByteAddressBuffer GraphicsContact : register(t0, space54);
float GraphicsContactVisibility(uint2 pixel, uint2 extent) {
  uint4 header = GraphicsContact.Load4(0);
  if (header.z != 1u || any(header.xy != extent) || any(pixel >= extent)) return 1.f;
  float value = asfloat(GraphicsContact.Load(16u + (pixel.y * extent.x + pixel.x) * 4u));
  return isfinite(value) ? saturate(value) : 1.f;
}
#endif
