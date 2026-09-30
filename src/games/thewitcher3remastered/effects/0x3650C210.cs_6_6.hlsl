// Custom bypass of the native sharpening dispatch; NOT a native decompile.
// addon.cpp selects this only for PsychoV + RenoDX sharpening. Native/Vanilla
// keeps the original CSO. No injected settings or compute layout changes.
// Preserve the original 128-thread, 32x32 tile traversal, center SampleLevel,
// b0.c4.xy UV scale and complete RGBA write; omit the native additive detail.
Texture2D<float4> t0 : register(t0);
RWTexture2D<float4> u0 : register(u0);
SamplerState s0 : register(s0);
cbuffer cb0 : register(b0) {
  float2 inverse_size : packoffset(c4.x);
  float native_padding : packoffset(c6.w);
};

[numthreads(128, 1, 1)]
void main(uint3 group : SV_GroupID, uint thread : SV_GroupIndex) {
  uint width, height;
  u0.GetDimensions(width, height);
  for (uint i = thread; i < 1024u; i += 128u) {
    const uint2 pixel = group.xy * 32u + uint2(i & 31u, i >> 5u);
    if (all(pixel < uint2(width, height))) {
      u0[pixel] = t0.SampleLevel(s0, (float2(pixel) + 0.5f) * inverse_size, 0.f);
    }
  }
}
