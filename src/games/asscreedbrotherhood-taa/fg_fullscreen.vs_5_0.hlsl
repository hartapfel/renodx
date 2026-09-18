/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
void main(uint id : SV_VertexID, out float4 position : SV_Position, out float2 uv : TEXCOORD0) {
  uv = float2((id << 1) & 2, id & 2);
  position = float4(uv * float2(2.f, -2.f) + float2(-1.f, 1.f), 0.f, 1.f);
}
