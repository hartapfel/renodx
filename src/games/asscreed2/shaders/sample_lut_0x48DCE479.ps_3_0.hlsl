#include "../common.hlsli"

float3 g_PreLutScale : register(c0);
float3 g_PreLutOffset : register(c1);
sampler2D s0;
sampler3D s1;

float4 main(float2 texcoord : TEXCOORD) : COLOR
{
  float4 o;

  float3 input = tex2D(s0, texcoord.xy).rgb;

  // Vanilla rendered into SDR UNORM targets before this pass. When the scene is
  // upgraded, preset-off needs to reintroduce that clamp before LUT sampling.
  if (RENODX_TONE_MAP_TYPE == 0.f) {
    input = saturate(input);
  }

  // The game combines pre-LUT scale/offset with the normalized 16^3 LUT range.
  float3 untonemapped_gamma = (((input * g_PreLutScale.xyz + g_PreLutOffset.xyz) - 0.03125f) / 0.9375f);

  if (RENODX_TONE_MAP_TYPE == 0.f) {
    float3 graded_gamma = AC2SampleLUTGamma(s1, untonemapped_gamma);
    float3 untonemapped = renodx::color::gamma::DecodeSafe(max(0.f, untonemapped_gamma), 2.2f);
    float3 graded = renodx::color::gamma::DecodeSafe(max(0.f, graded_gamma), 2.2f);
    float3 vanilla = lerp(untonemapped, graded, RENODX_COLOR_GRADE_STRENGTH);
    o.rgb = renodx::color::gamma::EncodeSafe(saturate(max(0.f, vanilla)), 2.2f);
  } else {
    float3 untonemapped = renodx::color::gamma::DecodeSafe(max(0.f, untonemapped_gamma), 2.2f);
    float compression_scale = ComputeMaxChCompressionScale(untonemapped);

    float3 color_sdr = untonemapped * compression_scale;
    float3 color_sdr_graded = AC2SampleToneMappedLUT(s1, color_sdr);
    float3 color_final = color_sdr_graded / max(compression_scale, 1e-4f);

    o.rgb = renodx::color::gamma::EncodeSafe(max(0.f, color_final), 2.2f);
    o.rgb = ToneMapAndRenderIntermediatePass(o.rgb, texcoord.xy);
  }

  o.w = 0.f;
  return o;
}
