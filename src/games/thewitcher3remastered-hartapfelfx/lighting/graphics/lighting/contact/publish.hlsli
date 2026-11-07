// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Publish visibility and save ranged native CB contents without copying or
// transitioning the game's buffers. The private outputs are the only writes.
#include "parameters.hlsli"
Texture2D<float2> current_mask : register(t4);
cbuffer Frame : register(b12) { float4 cb12[341]; }
cbuffer Light : register(b13) { float4 cb13[3589]; }
RWByteAddressBuffer visibility : register(u1);
RWByteAddressBuffer metadata : register(u2);
[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  uint2 size = uint2(min(RenoLighting[2].zw, cb12[23].xy));
  if (any(id.xy >= size)) return;
  uint pixel = id.y * size.x + id.x;
  if (pixel == 0u) visibility.Store4(0, uint4(size, 1, 2));
  visibility.Store(16u + pixel * 4u, asuint(current_mask.Load(int3(id.xy, 0)).x));
  // A strided loop also initializes all metadata for small auxiliary/test views.
  for (uint row = pixel; row < 345u; row += size.x * size.y) {
    uint4 value = row < 341u ? asuint(cb12[min(row,340u)])
        : row == 341u ? asuint(cb13[0]) : asuint(RenoLighting[min(row-342u,2u)]);
    metadata.Store4(row * 16u, value);
    visibility.Store4(16u+size.x*size.y*12u+row*16u,value);
  }
}
