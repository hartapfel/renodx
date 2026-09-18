// Current jittered inputs for DLAA; no temporal filtering or motion dilation.
#include "./taa_reprojection.hlsli"
sampler2D scene_texture : register(s0);
sampler2D depth_texture : register(s1);
sampler2D object_texture : register(s2);
float4 previous_clip_rows[4] : register(c0);
float4 size_jitter : register(c4);
// Object motion enabled, already-linear source, valid camera pair, unused.
float4 input_info : register(c5);

struct Inputs {
  float4 color : COLOR0;
  float4 motion : COLOR1;
  float4 depth : COLOR2;
};
Inputs main(float2 uv : TEXCOORD0) {
  float3 color = tex2D(scene_texture, uv).rgb;
  if (input_info.y == 0.f) color = sign(color) * pow(abs(color), 2.2f);
  float depth = tex2D(depth_texture, uv).r;
  float4 object = input_info.x != 0.f ? tex2D(object_texture, uv) : 0.f;
  depth = CurrentMotionDepth(depth, object.w);
  float2 motion = 0.f;
  float previous_depth;
  bool valid = input_info.z != 0.f;
  bool estimated = false;
  if (object.w > 0.f) {
    motion = object.xy;
    estimated = object.z < 0.f;
  } else {
    valid = AC2ReprojectCamera(uv, depth, size_jitter.xy, size_jitter.zw, float2(0.f, 0.f),
                              previous_clip_rows[0], previous_clip_rows[1], previous_clip_rows[2], previous_clip_rows[3],
                              motion, previous_depth) && valid;
    motion += size_jitter.zw * size_jitter.xy;
    estimated = object.w < 0.f;
  }
  // Unknown poses use camera motion and strongly prefer current color. Reject
  // non-finite/unbounded inputs before NGX, including behind-camera rays.
  valid = valid && all(abs(motion) < 2.f);
  Inputs result;
  result.color = float4(clamp(color, -65504.f, 65504.f), 1.f);
  result.motion = float4(valid ? motion : 0.f, !valid || estimated ? 1.f : 0.f, valid ? 1.f : 0.f);
  result.depth = saturate(depth).xxxx;
  return result;
}
