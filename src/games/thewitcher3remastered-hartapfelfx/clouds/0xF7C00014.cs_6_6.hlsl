// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
cbuffer NativeFrame:register(b0) {float4 frame[75];}
cbuffer Face:register(b0,space73) {uint face_revision;}
RWByteAddressBuffer metadata:register(u0);
[numthreads(1,1,1)] void main() {
  uint face=face_revision&7u;
  uint offset=face*80u;
  metadata.Store4(offset,asuint(frame[0]));
  metadata.Store4(offset+16u,uint4(0x57334341u,face,face_revision>>3u,0u));
  metadata.Store4(offset+32u,asuint(frame[66]));
  metadata.Store4(offset+48u,asuint(frame[68]));
  metadata.Store4(offset+64u,asuint(frame[67]));
}
