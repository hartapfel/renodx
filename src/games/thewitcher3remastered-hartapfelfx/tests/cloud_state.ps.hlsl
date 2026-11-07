// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
cbuffer HDR : register(b13, space50) { float4 hdr; }
cbuffer Words : register(b0, space99) { float4 words; }
Texture2D<float4> image : register(t9);
SamplerState image_sampler : register(s0);
float4 main(float4 position : SV_Position) : SV_Target {
  return hdr + words + image.SampleLevel(image_sampler, .5f, 0);
}
