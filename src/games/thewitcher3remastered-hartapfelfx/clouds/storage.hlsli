// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_STORAGE
#define HARTAPFEL_CLOUD_STORAGE
// Store opacity in the half-float cloud images. At the authored low density,
// transmission is near one and its FP16 spacing can exceed one gameplay
// frame's change. Opacity is small there and retains much finer steps.
float4 CloudEncode(float4 cloud) { cloud.a = 1.f - cloud.a; return cloud; }
float4 CloudDecode(float4 stored) { stored.a = 1.f - stored.a; return stored; }
#endif
