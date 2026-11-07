// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "hit_layout.h"
#include "hit_selection.hlsli"
#if W3_HIT_FIELD_INDEX == 0
RWByteAddressBuffer records : register(u0, space59);
cbuffer Context : register(b0, space59) { uint4 context; }
#elif W3_HIT_FIELD_INDEX == 1
RWByteAddressBuffer records : register(u1, space59);
cbuffer Context : register(b1, space59) { uint4 context; }
#elif W3_HIT_FIELD_INDEX == 2
RWByteAddressBuffer records : register(u2, space59);
cbuffer Context : register(b2, space59) { uint4 context; }
#else
#error Invalid material field index
#endif
cbuffer NativeCamera : register(b0, space1) { float4 native_camera[8]; }
[numthreads(256, 1, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  // A new allocation always clears. Reused fields retain data belonging to a
  // different known producer; an unknown raygen invalidates every field.
  uint selected = GraphicsSelectedHitKind();
  if (context.x == 0x57334D41u && selected != 3u && selected != W3_HIT_FIELD_INDEX) return;
  if (all(id.xy == 0)) {
    [unroll] for (uint row = 0; row < 4; ++row) records.Store4(row * 16u, asuint(native_camera[4 + row]));
  }
  if (all(id.xy < context.yz)) records.Store4(W3_HIT_HEADER_BYTES + (id.y * context.y + id.x) * W3_HIT_STRIDE, 0u);
}
