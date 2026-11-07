// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_SKY_GLOW
#define HARTAPFEL_CLOUD_SKY_GLOW

float CloudSolarGlowScale(float power, float dot_bias) {
  // Near the center, a biased cosine lobe behaves like a cosine raised
  // to power / (1 + dot_bias). Keep broad glows and fade disc-like lobes
  // in place so they cannot brighten the sky around the native profile.
  const float effective_power = power / (1.f + max(dot_bias, 0.f));
  return 1.f - smoothstep(24.f, 64.f, effective_power);
}

#endif
