// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../clouds/shadow_inputs.hlsli"
RWByteAddressBuffer output : register(u0, space73);
cbuffer Camera : register(b0, space1) { float4 camera[102]; }
cbuffer Sentinel : register(b0, space96) { float4 sentinel; }
cbuffer Words : register(b0, space97) { uint4 words; }
cbuffer PathMaterials : register(b0, space56) { float4 path_materials; }
cbuffer Local : register(b0, space95) { uint4 local_words; }
Texture2D<float4> image : register(t0, space96);
SamplerState image_sampler : register(s0, space96);
[shader("raygeneration")] void CloudProbeRGS() {
  output.Store4(0, HartapfelCloudData.Load4(32));
  output.Store4(16, words);
  output.Store4(32, local_words);
  output.Store4(48, asuint(sentinel));
  output.Store4(64, asuint(image.SampleLevel(image_sampler, .5f, 0)));
  output.Store4(80, asuint(camera[16]));
  output.Store4(96, asuint(path_materials));
  output.Store4(112, asuint(float4(HartapfelCloudShadow(float3(0, 0, 0), 1.f),
      HartapfelCloudShadowMultiply(float3(0, 0, 0), 0.f),
      asfloat(HartapfelCloudData.Load(272)), CloudShadowReady() ? 1.f : 0.f)));
}
