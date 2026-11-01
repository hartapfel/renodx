// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER3_CLOUD_SAMPLING_HLSLI
#define WITCHER3_CLOUD_SAMPLING_HLSLI
Texture3D<float> cloud_samples : register(t7);
float CloudSample(uint2 pixel,uint dimension) {
  // EA FAST: preserve the mask's spatial/temporal ordering. R2 offsets supply
  // additional dimensions without hashing its values or filtering the mask.
  // This is a decorrelation approximation, not a high-dimensional QMC set.
  uint2 offset=uint2(frac(float(dimension)*float2(.754877666f,.569840296f))*128.f);
  float value=cloud_samples.Load(int4((pixel+offset)&127u,(uint)integration.z&31u,0));
  return (value*255.f+.5f)/256.f;
}
#endif
