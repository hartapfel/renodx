// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER3_CLOUD_SAMPLING_HLSLI
#define WITCHER3_CLOUD_SAMPLING_HLSLI
#include "fast_sample.hlsli"
Texture3D<float> cloud_samples : register(t7);
float CloudSample(uint2 pixel,uint dimension) {
  return FastSample(cloud_samples,pixel,(uint)integration.z,dimension);
}
#endif
