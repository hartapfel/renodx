// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../clouds/shadow_inputs.hlsli"
cbuffer NativeFrame : register(b12) { float4 frame[341]; }
cbuffer Lighting : register(b0, space73) { float4 lighting; }
RWTexture2D<float4> output : register(u4);
[numthreads(1, 1, 1)] void main() {
  output[uint2(0, 0)] = float4(
      CloudShadowMatches(frame[0].xyz, asuint(frame[286])) ? 1.f : 0.f,
      HartapfelCloudShadow(frame[0].xyz, 1.f),
      asfloat(HartapfelCloudData.Load(272)), lighting.x);
}
