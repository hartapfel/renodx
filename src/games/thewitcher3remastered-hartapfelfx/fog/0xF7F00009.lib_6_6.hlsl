// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#define FOG_LOCAL_PASS
#define FOG_RAY_LOCAL_PASS
#include "grid.hlsli"
// CameraCB is b0,space1 in both audited native ray libraries. SharedPixelConsts
// b12,space2 need not populate its deferred camera fields in RT/PT.
cbuffer FogNativeRayCamera : register(b4, space61) { float4 native_ray_camera[102]; }
#include "local_lights.hlsli"
ByteAddressBuffer FogNativeRayRecord : register(t1, space61);
[shader("raygeneration")]
void HartapfelVolumeLocalRGS() {
  bool diagnostic = all(DispatchRaysIndex() == 0u);
  if (diagnostic) volume.InterlockedOr(1072, 1u);
  // Select an audited native local-shadow or PT generator on the GPU. States can contain
  // multiple ray generators; neither export presence nor the CPU callback
  // identifies the actual native record.
  if (any(FogNativeRayRecord.Load4(0) != local_ray_identifier[0])
      || any(FogNativeRayRecord.Load4(16) != local_ray_identifier[1])) return;
  if (diagnostic) volume.InterlockedOr(1072, 2u);
  if (diagnostic) {
    volume.Store4(1088, asuint(native_ray_camera[8]));
    volume.Store4(1104, asuint(fog_frame[0]));
    volume.Store(1076, FogLightCount());
    volume.Store4(1120, asuint(native_ray_camera[78]));
    volume.Store4(1136, asuint(native_ray_camera[79]));
  }
  // The BVH is queried in world space using the fog pass's reconstruction.
  // Native PT and deferred passes can use different TAA jitter and inverse
  // projections. Those values do not identify a different world-space scene.
  // CPU epoch/depth matching plus camera origin reject foreign views;
  // LocalFieldReady separately validates the fog field's exact current frame.
  if (diagnostic) volume.InterlockedOr(1072, 4u);
  if (any(asuint(native_ray_camera[8].xyz) != asuint(fog_frame[0].xyz))) return;
  if (diagnostic) volume.InterlockedOr(1072, 8u);
  if (!LocalFieldReady() || local_ray_inputs.y == 0u) return;
  if (diagnostic) { volume.InterlockedOr(1072, 16u); volume.Store(1076, FogLightCount()); }
  // Several generators/aliases can share a state and frame. A successful
  // candidate owns the whole dispatch, while later candidates cannot add the
  // same energy again. Zero or this token admits every lane of its owner;
  // only the following dispatch observes a different token after a UAV barrier.
  uint owner = volume.Load(1064);
  if (owner != 0u && owner != local_ray_inputs.y) return;
  if (diagnostic) volume.InterlockedOr(1072, 32u);
  if (all(DispatchRaysIndex() == 0u)) {
    uint previous;
    volume.InterlockedCompareExchange(1064, 0u, local_ray_inputs.y, previous);
  }
  AddLocalCell(DispatchRaysIndex());
}
