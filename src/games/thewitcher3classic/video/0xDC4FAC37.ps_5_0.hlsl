#include "common.hlsli"
Texture2D<float4> video_alpha : register(t3);
SamplerState video_alpha_sampler : register(s3);

float4 main(float2 uv : TEXCOORD0) : SV_Target0 {
  return float4(VideoAutoHDR(SampleVideo(uv)), video_alpha.Sample(video_alpha_sampler, uv).x);
}
