// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#define FOG_LOCAL_PASS
#define FOG_RASTER_LIGHTS
#include "grid.hlsli"
#include "local_lights.hlsli"
[numthreads(4, 4, 4)] void main(uint3 id : SV_DispatchThreadID, uint3 group : SV_GroupID, uint thread : SV_GroupIndex) {
  if (fx.local_strength <= 0.f) return;
  CullFogLightGroup(group, thread);
  AddLocalCell(id);
}
