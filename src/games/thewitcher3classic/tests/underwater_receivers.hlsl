// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../water/underwater_inputs.hlsli"
float4 main(float4 position:SV_Position):SV_Target {
  uint row=(uint)position.y;
  float3 world=float3(position.x*.25f-8.f,0.f,row==0u?-2.f:row==1u?-11.f:row==2u?1.f:-.05f);
  return float4(UnderwaterReceiverWeight(world),UnderwaterSunFactor(world));
}
