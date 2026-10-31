// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Underwater postprocess: full-image softness and color fringing.
// No common geometric warp, radial/edge mask or temporal feedback.
Texture2D<float4> Scene : register(t0);
StructuredBuffer<float4> WaterState : register(t88);
SamplerState LinearClamp : register(s0);
cbuffer Camera : register(b0) {
  float2 active_size; float2 allocation_size;
  float blur_strength; float fringe_strength; float stage; float padding;
}
float4 CameraSample(float2 uv) {
  return Scene.SampleLevel(LinearClamp,
      clamp(uv * active_size, .5f, active_size - .5f) / allocation_size, 0);
}
float3 CameraColor(float2 uv, float2 fringe) {
  float3 color = CameraSample(uv).rgb;
  [branch] if (stage == 0.f && fringe_strength > 0.f) {
    color.r = CameraSample(uv + fringe).r;
    color.b = CameraSample(uv - fringe).b;
  }
  return color;
}
float4 main(float4 position : SV_Position, float2 uv : TEXCOORD0) : SV_Target {
  float weight = WaterState[5].w;
  float4 sharp = CameraSample(uv);
  [branch] if (weight <= 0.f) return sharp;
  float2 pixel = (active_size.y / 1080.f) / active_size;
  // Constant RGB separation reaches the centre as well as the edges.
  // Green and the common geometric image stay on their original coordinates.
  float2 fringe = float2(1.f, .35f) * (1.5f * fringe_strength * weight) * pixel;
  float3 color = CameraColor(uv, fringe);
  [branch] if (blur_strength > 0.f) {
    float2 step = (stage == 0.f ? float2(pixel.x,0) : float2(0,pixel.y))
        * (2.f * blur_strength * weight);
    // Normalized separable Gaussian; paired bilinear taps cover nine texels
    // at unit spacing. Both axes are filtered across the entire image.
    color *= .2270270270f;
    color += (CameraColor(uv + step * 1.3846153846f, fringe)
            + CameraColor(uv - step * 1.3846153846f, fringe)) * .3162162162f;
    color += (CameraColor(uv + step * 3.2307692308f, fringe)
            + CameraColor(uv - step * 3.2307692308f, fringe)) * .0702702703f;
  }
  return float4(color,sharp.a);
}
