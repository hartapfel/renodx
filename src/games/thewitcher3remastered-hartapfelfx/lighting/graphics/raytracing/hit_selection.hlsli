// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_HIT_SELECTION
#define WITCHER_GRAPHICS_HIT_SELECTION
ByteAddressBuffer graphics_ray_identifier : register(t1, space59);
cbuffer GraphicsHitSelection : register(b3, space59) {
  uint4 graphics_hit_identifiers[12];
  uint graphics_hit_available;
}
// Return 0/1/2 for reflection/global/local, or 3 for an unknown producer.
// Compare all 32 bytes: their opaque contents are not stable numeric tags.
uint GraphicsSelectedHitKind() {
  uint4 first = graphics_ray_identifier.Load4(0), second = graphics_ray_identifier.Load4(16);
  uint selected = 3u;
  [unroll] for (uint entry = 0; entry < 6; ++entry) {
    if ((graphics_hit_available & (1u << entry)) != 0u
        && all(first == graphics_hit_identifiers[entry * 2u])
        && all(second == graphics_hit_identifiers[entry * 2u + 1u])) {
      // Ambiguous identifiers across different families fail closed.
      if (selected != 3u && selected != entry / 2u) return 3u;
      selected = entry / 2u;
    }
  }
  return selected;
}
#endif
