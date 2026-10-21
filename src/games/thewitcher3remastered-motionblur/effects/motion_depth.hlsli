// Lossless packing of nonnegative hardware depth in [0, 1] into two FP16
// channels. Its IEEE float representation fits in 30 bits. Each half carries
// 15 bits using its sign and 14 low bits, biased away from zero/denormals/NaNs.
// Both stored values are exactly representable, finite normal half-floats.
#ifndef WITCHER_MOTION_DEPTH_HLSLI
#define WITCHER_MOTION_DEPTH_HLSLI
float2 PackMotionDepth(float depth) {
  uint bits = asuint(depth);
  uint2 chunks = uint2(bits & 0x7fffu, bits >> 15u);
  return f16tof32(((chunks & 0x3fffu) + 0x400u) | ((chunks & 0x4000u) << 1u));
}
float UnpackMotionDepth(float2 packed) {
  uint2 halves = f32tof16(packed);
  uint2 chunks = ((halves & 0x7fffu) - 0x400u) | ((halves & 0x8000u) >> 1u);
  return asfloat(chunks.x | (chunks.y << 15u));
}
#endif
