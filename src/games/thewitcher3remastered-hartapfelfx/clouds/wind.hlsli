// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_WIND
#define HARTAPFEL_CLOUD_WIND
// Native deferred DXIL uses (world + 20 * b12[67].xy) * .01 / (20 * b12[66].x)
// for its broad weather field. The 20 multiplies world-space advection too:
// using 1.2 here made kilometre-scale formations almost stationary in storms.
// User-requested half-speed advection applies in every weather. Keep the
// native unit conversion explicit; view, shadows, cirrus, weather history
// and motion reconstruction all use the same scaled offset.
static const float CloudWindWorldScale = 20.f * .5f;
float2 CloudWindOffset(float2 native_offset) { return native_offset * CloudWindWorldScale; }
#endif
