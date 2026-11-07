// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Publish history through shader reads, preserving every native CBV state.
#include "common.hlsli"
RWByteAddressBuffer published : register(u3);
RWByteAddressBuffer shared_data : register(u2);
void main(float4 position : SV_Position) {
  uint row = uint(position.x);
  if (row < 341) published.Store4(row * 16, asuint(frame[row]));
  if (row != 0) return;
  uint3 old_identity = published.Load3(5888 + 80);
  if (any(old_identity != CloudIdentity())) published.Store(6144, published.Load(6144) + 1);
  published.Store4(5632, asuint(cloud_clock));
  published.Store4(5888, asuint(dimensions));
  published.Store4(5904, asuint(integration));
  published.Store4(5920, asuint(appearance));
  published.Store4(5936, asuint(atmosphere));
  published.Store4(5952, asuint(scattering));
  published.Store4(5968, uint4(CloudIdentity(), identity.w & 255u));
  published.Store4(5984, storage);
  if ((identity.w & 255u) == 0) {
    shared_data.Store4(96, uint4(uint2(dimensions.xy), storage.xy));
    shared_data.Store4(112, asuint(frame[0]));
    shared_data.Store4(128, asuint(frame[286]));
    shared_data.Store4(144, asuint(frame[23]));
    shared_data.Store4(160, identity);
    shared_data.Store4(176, asuint(cloud_clock));
    shared_data.Store4(192, asuint(frame[17]));
    shared_data.Store4(208, asuint(frame[18]));
  }
}
