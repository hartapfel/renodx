// Optional development view. Native DLAA rendering does not execute this shader.
Texture2D<float4> Vectors : register(t0);
Texture2D<float> Surface : register(t1);
cbuffer DebugView : register(b0) { uint view; uint2 size; uint padding; uint2 render_size; uint2 padding2; }
float4 main(float4 position : SV_Position) : SV_Target {
  const int3 pixel = int3(min(uint2(position.xy * render_size / size), render_size - 1), 0);
  const float4 value = Vectors.Load(pixel);
  if (view == 5) return float4(value.rgb, 1.f);
  if (view == 3 || view == 4) return float4(saturate(value.xxx), 1.f);
  if (view == 2) {
    const float2 motion = value.xy * render_size;
    const float hue = atan2(motion.y, motion.x) / 6.2831853f + 0.5f;
    const float3 wheel = saturate(abs(frac(hue + float3(0.f, 2.f/3.f, 1.f/3.f)) * 6.f - 3.f) - 1.f);
    return float4(wheel * saturate(length(motion) / 32.f), 1.f);
  }
  uint width, height;
  Surface.GetDimensions(width, height);
  if (width == 0 || height == 0) return float4(0.02f, 0.02f, 0.02f, 1.f);
  const float depth = Surface.Load(pixel);
  if (abs(depth) > 1.f) return float4(0.02f, 0.02f, 0.02f, 1.f);
  if ((asuint(depth) & 0x80000000u) != 0) return float4(1.f, 0.35f, 0.f, 1.f);
  const float2 motion = value.xy;
  return float4(saturate(float3(0.18f + motion * 32.f, 0.18f)), 1.f);
}
