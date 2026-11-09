// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#define FOG_RECEIVER_FRAME
cbuffer NativeFrame : register(b12) { float4 receiver_frame[341]; }
#include "../fog/receivers.hlsli"
float4 main(float4 position : SV_Position) : SV_Target {
  bool valid = ReceiverFrameMatches();
  if(position.x>1.f) return float4(SampleFogVolume(receiver_frame[23].xy*.5f,1000.f).rgb,asfloat(FogVolume.Load(1012)));
  return float4(valid ? 1.f : 0.f, valid ? SampleFogVolume(receiver_frame[23].xy * .5f, 1000.f).a : -1.f,
                asfloat(FogVolume.Load(0)), valid ? asfloat(FogVolume.Load(64)) : 0.f);
}
