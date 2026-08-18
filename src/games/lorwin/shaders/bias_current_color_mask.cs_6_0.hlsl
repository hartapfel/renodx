Texture2D<float4> CurrentColor : register(t0);
Texture2D<float4> PreviousColor : register(t1);
Texture2D<float> DepthTexture : register(t2);
Texture2D<float2> MotionVectors : register(t3);
RWTexture2D<float> BiasCurrentColorMask : register(u0);
SamplerState LinearClampSampler : register(s0);

cbuffer BiasCurrentColorConstants : register(b0) {
  // x: previous color valid, y: strength, z: relative color threshold,
  // w: relative depth threshold.
  float4 g_BiasMaskParams;

  // xy: previous-minus-current jitter in UV space, zw: reserved.
  float4 g_BiasMaskJitter;
};

float LoadDepth(int2 coord, int2 size) {
  return DepthTexture.Load(int3(clamp(coord, int2(0, 0), size - int2(1, 1)), 0));
}

float GetTemporalColorResponse(int2 coord, int2 size) {
  coord = clamp(coord, int2(0, 0), size - int2(1, 1));
  const float2 uv = (float2(coord) + 0.5f) / float2(size);
  const float2 motion_vector = MotionVectors.Load(int3(coord, 0));
  const float2 previous_uv = uv - motion_vector + g_BiasMaskJitter.xy;
  if (any(previous_uv <= 0.f.xx) || any(previous_uv >= 1.f.xx)) return 1.f;

  const float3 current_color = CurrentColor.Load(int3(coord, 0)).rgb;
  const float3 previous_color = PreviousColor.SampleLevel(LinearClampSampler, previous_uv, 0.f).rgb;
  const float3 color_delta = abs(current_color - previous_color);
  const float peak_delta = max(color_delta.r, max(color_delta.g, color_delta.b));
  const float current_luma = dot(current_color, float3(0.2126f, 0.7152f, 0.0722f));
  const float previous_luma = dot(previous_color, float3(0.2126f, 0.7152f, 0.0722f));
  const float relative_color_delta = peak_delta / max(max(current_luma, previous_luma), 0.05f);
  return saturate(
      (relative_color_delta - g_BiasMaskParams.z)
      / max(g_BiasMaskParams.z * 2.f, 1e-4f));
}

[numthreads(8, 8, 1)]
void main(uint3 dispatch_id : SV_DispatchThreadID) {
  uint width;
  uint height;
  BiasCurrentColorMask.GetDimensions(width, height);
  if (dispatch_id.x >= width || dispatch_id.y >= height) return;

  if (g_BiasMaskParams.x == 0.f) {
    BiasCurrentColorMask[dispatch_id.xy] = 1.f;
    return;
  }

  const int2 size = int2(width, height);
  const int2 coord = int2(dispatch_id.xy);
  const float2 center_motion = MotionVectors.Load(int3(coord, 0));
  float color_response = 0.f;
  float motion_disagreement_pixels = 0.f;
  static const int2 kCrossOffsets[5] = {
      int2(0, 0),
      int2(-1, 0),
      int2(1, 0),
      int2(0, -1),
      int2(0, 1),
  };
  [unroll]
  for (uint i = 0u; i < 5u; ++i) {
    const int2 sample_coord = clamp(coord + kCrossOffsets[i], int2(0, 0), size - int2(1, 1));
    color_response = max(color_response, GetTemporalColorResponse(sample_coord, size));
    const float2 sample_motion = MotionVectors.Load(int3(sample_coord, 0));
    motion_disagreement_pixels = max(
        motion_disagreement_pixels,
        length((sample_motion - center_motion) * float2(size)));
  }

  // Motion discontinuities are low-confidence history even when both surfaces
  // happen to have similar colors in the current pair of frames.
  const float motion_response = saturate((motion_disagreement_pixels - 0.5f) / 3.5f);

  float min_depth = LoadDepth(coord, size);
  float max_depth = min_depth;
  [unroll]
  for (int y = -1; y <= 1; ++y) {
    [unroll]
    for (int x = -1; x <= 1; ++x) {
      const float depth = LoadDepth(coord + int2(x, y), size);
      min_depth = min(min_depth, depth);
      max_depth = max(max_depth, depth);
    }
  }

  const float relative_depth_range = (max_depth - min_depth) / max(max(abs(min_depth), abs(max_depth)), 1e-3f);
  const float depth_response = saturate(
      (relative_depth_range - g_BiasMaskParams.w)
      / max(g_BiasMaskParams.w * 3.f, 1e-5f));

  const float rejection = max(color_response, max(depth_response, motion_response));
  BiasCurrentColorMask[dispatch_id.xy] = saturate(rejection * g_BiasMaskParams.y);
}
