sampler2D resolved_texture : register(s0);
sampler2D original_texture : register(s1);
sampler2D motion_texture : register(s2);
float4 size_jitter : register(c0);
// Already-linear transport, raw motion preview, unused, unused.
float4 output_info : register(c1);
float4 main(float2 uv : TEXCOORD0) : COLOR0 {
  float2 jittered_uv = uv + size_jitter.zw * size_jitter.xy;
  if (output_info.y != 0.f) {
    float4 motion = tex2D(motion_texture, jittered_uv);
    return float4(motion.w == 0.f ? float3(1.f, 0.f, 1.f)
                  : float3(saturate(0.5f + motion.xy / size_jitter.xy / 32.f), 0.5f), 1.f);
  }
  float4 original = tex2D(original_texture, jittered_uv);
  float3 original_linear = output_info.x != 0.f ? original.rgb : sign(original.rgb) * pow(abs(original.rgb), 2.2f);
  // NGX receives nonnegative linear light. Restore signed scene residuals at
  // the current unjittered location, preserving the native/HDR color contract.
  float3 color = tex2D(resolved_texture, uv).rgb + min(original_linear, 0.f);
  if (output_info.x == 0.f) color = sign(color) * pow(abs(color), 1.f / 2.2f);
  return float4(clamp(color, -65504.f, 65504.f), original.a);
}
