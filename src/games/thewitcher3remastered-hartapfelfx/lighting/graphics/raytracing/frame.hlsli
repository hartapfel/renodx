// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_PATH_FRAME
#define WITCHER_GRAPHICS_PATH_FRAME
// Descriptor-table alias of native SharedPixelConsts b12/space2. CameraCB has
// a different layout and must never supply these fields.
cbuffer GraphicsPathCloudFrame : register(b0, space55) {
  float4 graphics_path_cloud_frame[75];
}
#endif
