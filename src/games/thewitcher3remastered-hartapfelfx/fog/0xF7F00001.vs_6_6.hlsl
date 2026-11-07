// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
float4 main(uint id : SV_VertexID) : SV_Position {
  return float4(float2((id << 1) & 2, id & 2) * float2(2, -2) + float2(-1, 1), 0, 1);
}
