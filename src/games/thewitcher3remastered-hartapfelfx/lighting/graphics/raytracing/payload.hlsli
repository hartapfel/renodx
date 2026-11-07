// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_NATIVE_RAY_PAYLOAD
#define WITCHER_GRAPHICS_NATIVE_RAY_PAYLOAD
// Native PT ABI. Linking merges these symbols with the preserved libraries.
struct GbufferPayload { uint4 data; uint flags; };
RaytracingAccelerationStructure SceneBVH : register(t0, space1);
#endif
