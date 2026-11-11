// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../lighting/graphics/raytracing/payload.hlsli"
#ifndef FOG_TEST_NATIVE_LIB
[shader("raygeneration")] void LocalShadowsRGS() {}
#endif
[shader("miss")] void LocalShadowMS(inout GbufferPayload payload) {
  payload.data.w = asuint(-1.f);
}
[shader("anyhit")] void LocalShadowAH(inout GbufferPayload payload, BuiltInTriangleIntersectionAttributes attributes) {
  // Fixture for the audited native shadow ABI and alpha/caster rejection.
  if (InstanceID() == 0u) { IgnoreHit(); return; }
  if (payload.data.x == (1u << 24) && payload.flags == 0u) {
    payload.data.w = asuint(RayTCurrent());
    AcceptHitAndEndSearch();
  }
}
