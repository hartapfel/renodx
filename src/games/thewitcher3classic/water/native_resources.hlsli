// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_NATIVE_WATER_RESOURCES
#define CLASSIC_NATIVE_WATER_RESOURCES
StructuredBuffer<float4> WaterRanges : register(t87);
StructuredBuffer<float4> WaterSurfaceConstants : register(t90);
Texture2DArray<float> WaterRegionHeights : register(t91);
Texture2D<float4> WaterWaves : register(t92);
Texture2DArray<float> WaterTerrainHeights : register(t93);
Texture2D<float4> WaterTerrainTiles : register(t94);
#endif
