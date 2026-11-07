// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "grid.hlsli"
[numthreads(4, 4, 4)] void main(uint3 id : SV_DispatchThreadID) { GenerateCell(id); }
