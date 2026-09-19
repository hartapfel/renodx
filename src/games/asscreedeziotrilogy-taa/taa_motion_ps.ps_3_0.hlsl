float4 previous_clip_rows[4] : register(c0);
// current jitter in UV, pose status (0 missing, 1 full, 2 root-only), reserved
float4 motion_info : register(c4);
// Native D3DCMPFUNC, reference / 255, pixel-stage UV scale.
float4 alpha_info : register(c5);
// Material multiplier, use vertex alpha, final saturation, vertex-first product.
float4 alpha_product : register(c6);
float4 alpha_final : register(c7);
sampler2D alpha_texture : register(s0);
sampler2D scene_depth_texture : register(s1);
// Inverse size, enable MSAA prepass visibility, clip-depth roundoff tolerance.
float4 depth_info : register(c8);

float4 main(float4 current_clip : TEXCOORD0, float3 previous_position : TEXCOORD1, float clip_distance : TEXCOORD2, float2 uv : TEXCOORD3, float4 color : COLOR0, float2 pixel : VPOS) : COLOR0 {
  clip(clip_distance);
  // At native MSAA boundaries select a surface at the pixel center; never
  // average velocities/depth from unrelated foreground/background samples.
  // Private hardware depth separately orders the replayed dynamic surfaces.
  if (depth_info.z != 0.f) {
    float scene_depth = tex2D(scene_depth_texture, (pixel + 0.5f) * depth_info.xy).r;
    clip(scene_depth + depth_info.w - current_clip.z / current_clip.w);
  }
  if (alpha_info.x != 8.f || alpha_final.y != 0.f) {
    precise float alpha = tex2D(alpha_texture, uv * alpha_info.zw).a;
    if (alpha_product.w != 0.f) alpha *= color.a * alpha_product.x;
    else {
      alpha *= alpha_product.x;
      if (alpha_product.y != 0.f) alpha *= color.a;
    }
    alpha *= alpha_final.x;
    if (alpha_product.z != 0.f) alpha = saturate(alpha);
    if (alpha_final.y != 0.f) clip(alpha - alpha_final.y);
    bool visible = alpha_info.x == 8.f;
    if (alpha_info.x == 2.f) visible = alpha < alpha_info.y;
    if (alpha_info.x == 3.f) visible = alpha == alpha_info.y;
    if (alpha_info.x == 4.f) visible = alpha <= alpha_info.y;
    if (alpha_info.x == 5.f) visible = alpha > alpha_info.y;
    if (alpha_info.x == 6.f) visible = alpha != alpha_info.y;
    if (alpha_info.x == 7.f) visible = alpha >= alpha_info.y;
    clip(visible ? 1.f : -1.f);
  }
  float4 local = float4(previous_position, 1.f);
  float4 previous_clip = float4(dot(previous_clip_rows[0], local), dot(previous_clip_rows[1], local),
                               dot(previous_clip_rows[2], local), dot(previous_clip_rows[3], local));
  float2 current_uv = current_clip.xy / current_clip.w * float2(0.5f, -0.5f) + 0.5f - motion_info.xy;
  float2 previous_uv = previous_clip.xy / max(previous_clip.w, 1.e-6f) * float2(0.5f, -0.5f) + 0.5f;
  float previous_depth = previous_clip.z / max(previous_clip.w, 1.e-6f);
  bool valid = motion_info.z != 0.f && previous_clip.w > 1.e-6f && previous_depth >= 0.f && previous_depth <= 1.f;
  // Alpha: signed current complementary depth. Zero is uncovered; negative
  // marks covered geometry without a trustworthy previous pose (reset history).
  // Negative B identifies a root-only estimate. Keep it separate from missing
  // motion in negative A, and retain a nonzero sign at the far plane in FP16.
  float history_depth = saturate(1.f - previous_depth);
  if (motion_info.z == 2.f) history_depth = -max(history_depth, 6.e-8f);
  return float4(previous_uv - current_uv, history_depth,
                max(1.f - current_clip.z / current_clip.w, 6.e-8f) * (valid ? 1.f : -1.f));
}
