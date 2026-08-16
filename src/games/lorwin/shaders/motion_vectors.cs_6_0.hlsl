#pragma pack_matrix(row_major)

Texture2D<float4> DepthTexture : register(t0);
RWTexture2D<float2> MotionVectors : register(u0);
SamplerState LinearClampSampler : register(s0);

cbuffer Globals : register(b0) {
  float4 g_DOFBlurVals : packoffset(c002.x);
  float4x4 g_MotionBlurXform : packoffset(c006.x);
};

cbuffer MotionVectorDilationConstants : register(b1) {
  // xy: current camera jitter in pixels, z: inverted depth, w: dilation enabled.
  float4 g_MotionVectorDilation;
};

int2 ClampCoord(int2 coord, uint2 size) {
  return clamp(coord, int2(0, 0), int2(size) - int2(1, 1));
}

float2 GetCurrentPosition(int2 coord, uint2 size) {
  return ((float2(ClampCoord(coord, size)) + 0.5f) / float2(size)) * g_DOFBlurVals.w;
}

float LoadDepth(int2 coord, uint2 size, uint2 depth_size) {
  const float2 current_position = GetCurrentPosition(coord, size);
  const int2 depth_coord = clamp(
      int2(current_position * float2(depth_size)),
      int2(0, 0),
      int2(depth_size) - int2(1, 1));
  return DepthTexture.Load(int3(depth_coord, 0)).r;
}

float2 ReconstructMotionVector(int2 coord, float depth, uint2 size) {
  const float2 current_position = GetCurrentPosition(coord, size);
  float4 previous_position = mul(g_MotionBlurXform, float4(current_position, depth, 1.f));
  if (abs(previous_position.w) < 1e-6f) return 0.f.xx;

  previous_position.xyz /= previous_position.w;
  return current_position - previous_position.xy;
}

bool IsFarther(float candidate, float current) {
  return g_MotionVectorDilation.z != 0.f ? candidate < current : candidate > current;
}

[numthreads(8, 8, 1)]
void main(uint3 dispatch_id : SV_DispatchThreadID) {
  uint width;
  uint height;
  MotionVectors.GetDimensions(width, height);
  if (dispatch_id.x >= width || dispatch_id.y >= height) return;

  const uint2 size = uint2(width, height);
  uint depth_width;
  uint depth_height;
  DepthTexture.GetDimensions(depth_width, depth_height);
  const uint2 depth_size = uint2(depth_width, depth_height);
  const int2 base_coord = int2(dispatch_id.xy);
  const float center_depth = LoadDepth(base_coord, size, depth_size);
  if (g_MotionVectorDilation.w == 0.f) {
    MotionVectors[dispatch_id.xy] = ReconstructMotionVector(base_coord, center_depth, size);
    return;
  }

  float near_depth = center_depth;
  float far_depth = center_depth;
  int2 near_offset = int2(0, 0);
  int2 far_offset = int2(0, 0);

  [unroll]
  for (int y = -1; y <= 1; ++y) {
    [unroll]
    for (int x = -1; x <= 1; ++x) {
      const int2 offset = int2(x, y);
      const float depth = LoadDepth(base_coord + offset, size, depth_size);
      if (IsFarther(depth, far_depth)) {
        far_depth = depth;
        far_offset = offset;
      }
      if (IsFarther(near_depth, depth)) {
        near_depth = depth;
        near_offset = offset;
      }
    }
  }

  const float2 near_motion = ReconstructMotionVector(base_coord + near_offset, near_depth, size);
  const float2 far_motion = ReconstructMotionVector(base_coord + far_offset, far_depth, size);
  const float2 disagreement_pixels = (far_motion - near_motion) * float2(size);
  const bool disocclusion_edge = dot(disagreement_pixels, disagreement_pixels) > 4.f;

  const int jitter_x = g_MotionVectorDilation.x < 0.f ? -1 : 1;
  const int jitter_y = g_MotionVectorDilation.y < 0.f ? -1 : 1;
  int2 jitter_far_offset = int2(0, 0);
  float jitter_far_depth = center_depth;

  [unroll]
  for (int y_candidate = 0; y_candidate <= 1; ++y_candidate) {
    [unroll]
    for (int x_candidate = 0; x_candidate <= 1; ++x_candidate) {
      const int2 offset = int2(x_candidate * jitter_x, y_candidate * jitter_y);
      const float depth = LoadDepth(base_coord + offset, size, depth_size);
      if (IsFarther(depth, jitter_far_depth)) {
        jitter_far_depth = depth;
        jitter_far_offset = offset;
      }
    }
  }

  const float2 jitter_far_motion = ReconstructMotionVector(
      base_coord + jitter_far_offset,
      jitter_far_depth,
      size);

  // AC3R-style conditioning: dilate the far-surface vector over ordinary
  // silhouettes and use the current jitter quadrant at disocclusion edges.
  MotionVectors[dispatch_id.xy] = disocclusion_edge ? jitter_far_motion : far_motion;
}
