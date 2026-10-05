#ifndef WITCHER_NIGHT_SKYLIGHT_HLSLI
#define WITCHER_NIGHT_SKYLIGHT_HLSLI

// CommonConstantsHook transports the clock-faded skylight multiplier in
// native b12 c185.w padding. Untagged/native data must remain neutral.
float WitcherNightSkylight(float tag) {
  return (tag >= -3.f && tag <= -1.f) ? -tag - 1.f : 1.f;
}

#endif
