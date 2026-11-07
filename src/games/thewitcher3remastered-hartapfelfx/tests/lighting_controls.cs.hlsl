// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
cbuffer Lighting : register(b0, space73) { float4 lighting; }
RWTexture2D<float4> output : register(u4);
[numthreads(1, 1, 1)] void main() { output[uint2(0, 0)] = lighting; }
