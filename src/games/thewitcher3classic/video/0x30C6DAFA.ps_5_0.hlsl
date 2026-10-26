#include "common.hlsli"

float4 main(float2 uv : TEXCOORD0) : SV_Target0 {
  return float4(VideoAutoHDR(SampleVideo(uv)), 1.f);
}
