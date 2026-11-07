// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_WIND
#define HARTAPFEL_CLOUD_WIND
// Keep every cloud field and its reprojection on one native wind clock.
static const float CloudWindSpeed = 1.2f;
float2 CloudWindOffset(float2 native_offset) { return native_offset * CloudWindSpeed; }
#endif
