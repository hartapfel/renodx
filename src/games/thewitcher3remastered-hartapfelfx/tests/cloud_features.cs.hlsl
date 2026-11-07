// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../clouds/motion.hlsli"
#include "../clouds/lighting.hlsli"
cbuffer Probe : register(b0, space73) {
  float4 point_native;
  float4 native_motion;
  float4 pixel_depth_tau;
}
RWStructuredBuffer<float4> output : register(u0, space73);
[numthreads(1, 1, 1)] void main() {
  output[0] = float4(HartapfelCloudShadow(point_native.xyz, point_native.w),
      CloudShadowMatches(cloud_motion_frame[0].xyz, asuint(cloud_motion_frame[286])) ? 1.f : 0.f, 0, 0);
  output[1] = CloudNativeMotion(native_motion, pixel_depth_tau.z, int2(pixel_depth_tau.xy));
  output[2] = float4(CloudDiffuseTransport(pixel_depth_tau.w), exp(-pixel_depth_tau.w), CloudOpticalExtinction);
  output[3] = float4(HartapfelCloudNeutralize(point_native.w),
      HartapfelCloudShadowMultiply(point_native.xyz, point_native.w),
      HartapfelCloudShadowMultiply(point_native.xyz, 0.f), 0.f);
}
