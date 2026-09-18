// Lilium's luminance RCAS, adapted from RenoDX's Alien: Isolation and
// Black Desert Online implementations for Brotherhood's native DX9 TAA.
// Original RCAS: Copyright (C) 2024 Advanced Micro Devices, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

sampler2D resolved_texture : register(s0);
// Inverse dimensions, strength [0,1], already-linear input.
float4 sharpening_info : register(c0);

float3 DecodeResolved(float3 color) {
  // Match TAA's working-light convention, including native hardware-sRGB
  // sampling. The encoded path must round-trip before the original LUT.
  return sharpening_info.w != 0.f ? color : sign(color) * pow(abs(color), 2.2f);
}

float4 main(float2 uv : TEXCOORD0) : COLOR0 {
  float4 center = tex2D(resolved_texture, uv);
  if (sharpening_info.z <= 0.f) return center;

  // Five-tap cross: b / d e f / h, all from the completed unjittered resolve.
  float3 e = DecodeResolved(center.rgb);
  float3 b = DecodeResolved(tex2D(resolved_texture, uv + float2(0.f, -sharpening_info.y)).rgb);
  float3 d = DecodeResolved(tex2D(resolved_texture, uv + float2(-sharpening_info.x, 0.f)).rgb);
  float3 f = DecodeResolved(tex2D(resolved_texture, uv + float2(sharpening_info.x, 0.f)).rgb);
  float3 h = DecodeResolved(tex2D(resolved_texture, uv + float2(0.f, sharpening_info.y)).rgb);

  // Fixed HDR normalization used by Lilium's RenoDX ports. This pre-LUT scene
  // is relative light, not display nits; do not couple sharpness to HDR peak.
  const float3 luminance_weights = float3(0.2126f, 0.7152f, 0.0722f) / 125.f;
  float e_luma = max(dot(e, luminance_weights), 0.f);
  float4 ring = max(float4(dot(b, luminance_weights), dot(d, luminance_weights),
                          dot(f, luminance_weights), dot(h, luminance_weights)), 0.f);
  float min_ring = min(min(ring.x, ring.y), min(ring.z, ring.w));
  float max_ring = max(max(ring.x, ring.y), max(ring.z, ring.w));
  // Preserve black and avoid the hit-max singularity at normalized white.
  // Above it the reference lobe is zero, so the center is already unchanged.
  if (e_luma <= 1.e-7f || min_ring >= 1.f) return center;

  float limited_max = min(max_ring, 0.99f);
  float hit_min = min_ring / max(4.f * limited_max, 1.e-7f);
  float hit_max = (1.f - limited_max) / min(4.f * min_ring - 4.f, -1.e-7f);
  float lobe = max(-0.1875f, min(max(-hit_min, hit_max), 0.f)) * saturate(sharpening_info.z);

  // Lilium's noise suppression, with a finite denominator for flat patches.
  float noise = saturate(abs(dot(ring, 0.25f.xxxx) - e_luma)
                         / max(max(max_ring, e_luma) - min(min_ring, e_luma), 1.e-7f));
  lobe *= 1.f - 0.5f * noise;
  float sharpened_luma = (dot(ring, 1.f.xxxx) * lobe + e_luma) / (4.f * lobe + 1.f);
  float gain = clamp(sharpened_luma / e_luma, 0.f, 4.f);
  if (abs(gain - 1.f) < 1.e-6f) return center;

  // A common linear-light gain preserves chromaticity and signed HDR values.
  // Keep alpha (history depth) unchanged; this output never becomes history.
  float3 sharpened = e * gain;
  if (sharpening_info.w == 0.f) sharpened = sign(sharpened) * pow(abs(sharpened), 1.f / 2.2f);
  return float4(clamp(sharpened, -65504.f, 65504.f), center.a);
}
