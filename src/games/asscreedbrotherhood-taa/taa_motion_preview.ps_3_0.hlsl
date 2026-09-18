/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// Compile the resolve's input selection separately to stay within SM3's
// register budget. Normal accumulation never executes diagnostic branches.
#define TAA_MOTION_PREVIEW
#include "./taa_resolve.ps_3_0.hlsl"
