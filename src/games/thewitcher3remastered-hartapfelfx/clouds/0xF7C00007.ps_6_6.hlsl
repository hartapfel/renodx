// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "weather.hlsli"
void main(float4 position : SV_Position) { CloudFilterWeather(uint2(position.xy)); }
