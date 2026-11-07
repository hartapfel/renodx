// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../clouds/common.hlsli"
Texture2D<float> cloud_depth:register(t4);
float4 main(float4 position:SV_Position):SV_Target {
  float3 ray=CloudRay(position.xy/dimensions.zw);
  return float4(cloud_depth.Load(int3(int2(position.xy),0)),CloudSceneDistance(position.xy,ray),CloudInterval(frame[0].xyz,ray).x,1);
}
