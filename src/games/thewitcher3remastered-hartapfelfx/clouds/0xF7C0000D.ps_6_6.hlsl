// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Preserve the native global clock before ray dispatches whose b0 is CameraCB.
cbuffer NativeGlobal : register(b0) { float4 native_clock; }
cbuffer NativeFrame : register(b12) { float4 native_frame[341]; }
cbuffer Identity : register(b3, space71) { uint2 native_address; }
RWByteAddressBuffer captured_clock : register(u0, space72);
void main(float4 position : SV_Position) {
  captured_clock.Store4(0, asuint(native_clock));
  captured_clock.Store4(16, uint4(native_address, 0, 0xF7C0000Du));
  captured_clock.Store4(32, asuint(native_frame[0]));
  captured_clock.Store4(48, asuint(native_frame[286]));
}
