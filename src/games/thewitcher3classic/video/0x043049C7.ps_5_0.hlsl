#include "common.hlsli"

float4 main(float4 color : COLOR0, float2 uv : TEXCOORD0) : SV_Target0 {
  return float4(VideoAutoHDR(SampleVideo(uv)), color.w);
}
