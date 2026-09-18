Texture2D<float4> source_color : register(t0);
Texture2D<float4> source_motion : register(t1);
RWTexture2D<float4> color : register(u0);
RWTexture2D<float2> motion : register(u1);
RWTexture2D<float> responsive : register(u2);
[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  uint width, height;
  source_color.GetDimensions(width, height);
  if (id.x >= width || id.y >= height) return;
  float4 c = source_color.Load(int3(id.xy, 0));
  float4 m = source_motion.Load(int3(id.xy, 0));
  color[id.xy] = float4(all(isfinite(c.rgb)) ? max(c.rgb, 0.f) : 0.f, 1.f);
  motion[id.xy] = all(isfinite(m.xy)) ? m.xy : 0.f;
  responsive[id.xy] = saturate(m.z);
}
