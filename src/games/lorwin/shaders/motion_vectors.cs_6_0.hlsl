#pragma pack_matrix(row_major)

Texture2D<float4> DepthTexture : register(t0);
RWTexture2D<float2> MotionVectors : register(u0);
SamplerState LinearClampSampler : register(s0);

cbuffer Globals : register(b0) {
  float4 g_DOFBlurVals : packoffset(c002.x);
  float4x4 g_MotionBlurXform : packoffset(c006.x);
};

[numthreads(8, 8, 1)]
void main(uint3 dispatch_id : SV_DispatchThreadID) {
  uint width;
  uint height;
  MotionVectors.GetDimensions(width, height);
  if (dispatch_id.x >= width || dispatch_id.y >= height) return;

  const float2 uv = (float2(dispatch_id.xy) + 0.5f) / float2(width, height);
  const float2 current_position = uv * g_DOFBlurVals.w;
  const float depth = DepthTexture.SampleLevel(LinearClampSampler, current_position, 0.f).r;

  float4 previous_position = mul(g_MotionBlurXform, float4(current_position, depth, 1.f));
  if (abs(previous_position.w) < 1e-6f) {
    MotionVectors[dispatch_id.xy] = 0.f.xx;
    return;
  }

  previous_position.xyz /= previous_position.w;
  MotionVectors[dispatch_id.xy] = current_position - previous_position.xy;
}
