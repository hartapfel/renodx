// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef REMASTERED_CONTACT_PARAMETERS
#define REMASTERED_CONTACT_PARAMETERS
// Private pass parameters, not the native game or graphics settings buffers.
// Row 0 is the feature/settings fingerprint; w is world-space reach.
// Row 2.zw is the active output extent. Preserve the Classic pass contract.
cbuffer ContactParameters : register(b10) { float4 RenoLighting[3]; }
#define CONTACT_LENGTH RenoLighting[0].w
#endif
