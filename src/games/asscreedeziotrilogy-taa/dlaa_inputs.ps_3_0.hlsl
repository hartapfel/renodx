// Current jittered inputs for DLAA; no temporal filtering or motion dilation.
#include "./taa_dense_motion.hlsli"
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
  // Unknown poses use camera motion and strongly prefer current color. Reject
  // non-finite/unbounded inputs before NGX, including behind-camera rays.
  Inputs result;
  result.color = float4(clamp(color, -65504.f, 65504.f), 1.f);
  result.motion = DenseMotion(uv, depth, object, size_jitter, previous_clip_rows, input_info.z != 0.f);
  result.depth = saturate(depth).xxxx;
  return result;
}
