// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../lighting/inputs.hlsli"
RWTexture2D<float4> output : register(u4);
[numthreads(1, 1, 1)] void main() {
  output[uint2(0, 0)] = float4(graphics_injection.pbr_mode, graphics_injection.contact_shadows,
      graphics_injection.soft_shadows, graphics_injection.sun_diameter);
  output[uint2(1, 0)] = graphics_injection.contact_length;
}
