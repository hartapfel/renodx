// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#define FOG_INTEGRATE_ONLY
#include "grid.hlsli"
void main(float4 position : SV_Position) { IntegrateColumn(uint2(position.xy)); }
