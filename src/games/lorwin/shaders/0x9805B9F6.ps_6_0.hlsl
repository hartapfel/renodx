// Reconstructed from embedded DXIL debug source for PostProcessHDR.pso.
// Active feature defines from the original compile command/source:
//   CONTRAST_SATURATION, DEPTH_OF_FIELD,
//   TONE_MAPPING_BLOOM, NOISE_EFFECT, GAMMA_CORRECTION

#pragma pack_matrix(row_major)

#define CONTRAST_SATURATION
#define DEPTH_OF_FIELD
#define TONE_MAPPING_BLOOM
#define NOISE_EFFECT
#define GAMMA_CORRECTION

Texture2D<float4> g_SceneTexture : register(t0);
Texture2D<float4> g_DepthTexture : register(t3);

#include "../common.hlsli"

Texture2D<float4> g_BloomTexture : register(t1);
Texture2D<float4> g_LuminanceTexture : register(t2);
Texture2D<float4> g_OutOfFocusTexture : register(t4);
Texture2D<float4> g_NoiseTexture : register(t5);
Texture1D<float4> g_GammaTexture : register(t7);

cbuffer $Globals : register(b0) {
  float4 g_MiddleGray : packoffset(c000.x);
  float4 g_DepthOfFieldVals : packoffset(c001.x);
  float4 g_DOFBlurVals : packoffset(c002.x);
  float4 g_DamageEffectColor : packoffset(c005.x);
  float4x4 g_MotionBlurXform : packoffset(c006.x);
  float4 g_SceneTint : packoffset(c014.x);
  float4 g_ConstantsRandA : packoffset(c015.x);
  float4 g_ConstantsRandB : packoffset(c016.x);
  float4 g_ViewPort : packoffset(c017.x);
  float4 g_Contrast : packoffset(c028.x);
  float4x4 g_InvProj : packoffset(c029.x);
  float4 g_MiscParams : packoffset(c033.x);
};

SamplerState g_SamplerPointClamp : register(s1);
SamplerState g_SamplerLinearClamp : register(s4);
SamplerState g_SamplerLinearWrap : register(s5);
SamplerState g_SamplerAniso : register(s6);

LORWIN_DEFINE_SCENE_SAMPLER()

bool IsEqualToZero(float x) {
  return abs(x) < 0.0001f;
}

float4 main(
    float4 position : SV_Position,
    float2 vScreenPosition : TEXCOORD0) : SV_Target {
  float depth = g_DepthTexture.Sample(g_SamplerLinearClamp, vScreenPosition * g_DOFBlurVals.w).r;
  float3 scene = SampleLORWINScene(vScreenPosition * g_DOFBlurVals.w);
  float3 blurry = g_OutOfFocusTexture.Sample(g_SamplerLinearClamp, vScreenPosition).rgb;
  float lum = g_LuminanceTexture.Sample(g_SamplerPointClamp, float2(0.5f, 0.5f)).r;
  float3 bloom = g_BloomTexture.Sample(g_SamplerAniso, vScreenPosition).rgb;

  float4 viewPos = mul(g_InvProj, float4(vScreenPosition.x, vScreenPosition.y, depth, 1.f));
  viewPos /= viewPos.w;
  float viewDepth = saturate((viewPos.y - g_MiscParams.x) / g_MiscParams.y);

  float3 output = scene;

#if defined(DEPTH_OF_FIELD)
  float dof_interpolant = abs(viewDepth - g_DepthOfFieldVals.x);
  dof_interpolant = saturate((dof_interpolant / g_DepthOfFieldVals.y) - g_DepthOfFieldVals.z);
  dof_interpolant *= g_DOFBlurVals.x;
  output = lerp(scene, blurry, saturate(dof_interpolant + g_DOFBlurVals.y));
#endif

#if defined(TONE_MAPPING_BLOOM)
  float hdrMin = saturate(lum - g_MiddleGray.x);
  float hdrMax = saturate(lum + g_MiddleGray.x);
  float pixelLum = dot(float3(0.2125f, 0.7154f, 0.0721f), output);
  float exposureRange = max(hdrMax - hdrMin, 1e-5f);
  float tonedLum = (pixelLum - hdrMin) / exposureRange;

  if (RENODX_TONE_MAP_TYPE == lorwin::TONE_MAP_TYPE_VANILLA) {
    tonedLum = saturate(tonedLum);
  } else {
    tonedLum = max(0.f, tonedLum);
  }

  float colorScale = 1.f;
  if (!IsEqualToZero(pixelLum)) {
    colorScale = tonedLum / pixelLum;
  }
  output *= colorScale;

  output += bloom;
#endif

#if defined(NOISE_EFFECT)
  if (lorwin::UseVanillaFilmGrain()) {
    float2 noiseUvs = float2(
        (vScreenPosition.x * g_ConstantsRandA.z) + g_ConstantsRandB.x,
        (vScreenPosition.y * g_ConstantsRandA.w) + g_ConstantsRandB.y);
    float3 noiseTint = g_NoiseTexture.Sample(g_SamplerLinearWrap, noiseUvs).rgb;
    noiseTint = (noiseTint * g_ConstantsRandA.xxx) + g_ConstantsRandA.yyy;
    output *= noiseTint;
  }
#endif

#if defined(CONTRAST_SATURATION)
  float3 ungradedOutput = output;
  output += (output - 0.5f) * g_Contrast.x;

  float rgbMin = min(output.r, min(output.g, output.b));
  float rgbMax = max(output.r, max(output.g, output.b));
  float rgbMedian = (rgbMin + rgbMax) * 0.5f;
  output += (output - rgbMedian) * g_Contrast.y;

  output *= g_SceneTint.rgb;
  output = lorwin::ApplySceneGrading(ungradedOutput, output);
#endif

#if defined(GAMMA_CORRECTION)
  if (RENODX_TONE_MAP_TYPE == lorwin::TONE_MAP_TYPE_VANILLA) {
    float3 rampCoords = (output * (1.f - (1.f / 256.f))) + (1.f / 256.f);
    output.r = g_GammaTexture.Sample(g_SamplerPointClamp, rampCoords.r).r;
    output.g = g_GammaTexture.Sample(g_SamplerPointClamp, rampCoords.g).r;
    output.b = g_GammaTexture.Sample(g_SamplerPointClamp, rampCoords.b).r;
  } else {
    output = lorwin::ToneMapAndRenderIntermediatePass(output);
  }
#endif

  output = lorwin::ApplyPerceptualFilmGrain(output, vScreenPosition);
  output = lorwin::ApplyDLAADebugView(output, position);

  return float4(output, 1.f);
}
