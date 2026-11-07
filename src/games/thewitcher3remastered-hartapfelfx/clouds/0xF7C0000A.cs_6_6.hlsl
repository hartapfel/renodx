// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "weather.hlsli"
[numthreads(8,8,1)] void main(uint3 id : SV_DispatchThreadID) { CloudFilterWeather(id.xy); }
