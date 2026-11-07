// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_CLOCK
#define HARTAPFEL_CLOUD_CLOCK
cbuffer CloudClock : register(b5) {
  float4 native_cloud_clock;
  uint4 clock_identity;
  float4 clock_camera;
  uint4 clock_jitter;
}
cbuffer PreviousCloudClock : register(b6) { float4 previous_cloud_clock; }
cbuffer CapturedCloudClock : register(b7) {
  float4 captured_cloud_clock;
  uint4 captured_clock_identity;
  float4 captured_clock_camera;
  uint4 captured_clock_jitter;
}
// A sunlight shader need not consume GlobalCB. Its remaining b0 binding can
// belong to an effect, even when the later sky binds the correct scene time.
// Prefer the existing material-pass capture only for this native view.
static bool cloud_clock_captured=(identity.w&2048u)!=0u
    &&captured_clock_identity.w==0xF7C0000Du
    &&all(captured_clock_camera.xyz==frame[0].xyz)
    &&all(captured_clock_jitter==asuint(frame[286]));
static float4 cloud_clock=cloud_clock_captured ? captured_cloud_clock : native_cloud_clock;
#endif
