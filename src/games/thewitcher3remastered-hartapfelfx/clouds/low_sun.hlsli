// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_LOW_SUN
#define HARTAPFEL_CLOUD_LOW_SUN
// Use the visible solar lobe, never the primary light's night-time moon fallback.
// The native clock selects 18:00..06:00. Elevation is a fallback only when
// native time is unavailable (e.g. standalone shader validation).
float4 CloudLowSunState(float3 solar_direction, float enabled, bool scheduled=false) {
  float squared = dot(solar_direction, solar_direction);
  if (!all(isfinite(solar_direction)) || squared < .25f || enabled <= 0.f) return 0.f;
  float3 sun = solar_direction * rsqrt(squared);
  // Fully formed from -3 to +6 degrees, dissolving between -8/-3 and +6/+16.
  // Smooth endpoints keep ordinary sunrise/sunset motion free of threshold pops.
  float amount = smoothstep(-.139173101f, -.052335956f, sun.z)
      * (1.f - smoothstep(.104528463f, .275637356f, sun.z));
  // Store a horizontal solar bearing separately from elevation. A cone about
  // the full Sun direction makes an obvious round hole in a solid cloud deck.
  return float4(sun.xy * rsqrt(max(dot(sun.xy, sun.xy), 1.e-4f)),
      scheduled?max(sun.z,0.f):sun.z, saturate(enabled) * (scheduled?1.f:amount));
}
float CloudLowSunOpening(float3 from_camera, float4 solar, float variation) {
  if (solar.w <= 0.f) return 0.f;
  float3 direction = from_camera * rsqrt(max(dot(from_camera, from_camera), 1.f));
  float forward = dot(direction.xy, solar.xy);
  if (forward <= 0.f) return 0.f;
  float across = abs(direction.x * solar.y - direction.y * solar.x);
  // The existing formation noise varies the side fade between 29 and 38
  // degrees from the Sun. In tangent space, the shoulders roll off smoothly.
  float edge_noise = saturate(variation);
  float span = saturate(across / max(forward * lerp(.55430905f, .78128563f, edge_noise), 1.e-5f));
  float horizontal = 1.f - smoothstep(.20f, 1.f, span);
  // A shallow arch is highest above the Sun and curves down toward the
  // horizon at the shoulders. Vary both boundaries with the same noise so
  // cloud billows break up the edge while the solar column stays clear.
  float crown = 1.f - span * span;
  float clear_top = lerp(-.06f, lerp(.04f, .10f, edge_noise), crown);
  float feather_top = lerp(.02f, lerp(.12f, .26f, edge_noise), crown);
  float elevation = direction.z - solar.z;
  float vertical = (1.f - smoothstep(clear_top, feather_top, elevation))
      * smoothstep(-.258819045f, -.104528463f, elevation);
  return solar.w * horizontal * vertical;
}
#endif
