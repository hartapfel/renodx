// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER3_FAST_SAMPLE_HLSLI
#define WITCHER3_FAST_SAMPLE_HLSLI
float FastSample(Texture3D<float> samples,uint2 pixel,uint frame_index,uint dimension) {
  // EA FAST: preserve spatial/temporal ordering. R2 translations provide
  // approximate decorrelation between dimensions, not a vector QMC sequence.
  uint2 offset=uint2(frac(float(dimension)*float2(.754877666f,.569840296f))*128.f);
  float value=samples.Load(int4((pixel+offset)&127u,frame_index&31u,0));
  return (value*255.f+.5f)/256.f;
}
#endif
