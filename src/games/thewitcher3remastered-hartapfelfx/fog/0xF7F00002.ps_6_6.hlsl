// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "grid.hlsli"
void main(float4 position : SV_Position) {
  uint2 pixel = uint2(position.xy);
  GenerateCell(uint3(pixel % dimensions.xy, pixel.x / dimensions.x + 8 * (pixel.y / dimensions.y)));
}
