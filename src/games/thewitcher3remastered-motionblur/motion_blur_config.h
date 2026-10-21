/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#ifndef WITCHER_MOTION_BLUR_CONFIG_H
#define WITCHER_MOTION_BLUR_CONFIG_H

// Shared by CPU allocation, GPU reduction and the reference harness. Coarser
// velocity tiles make a full-frame swept-neighbor search practical; scene color
// and reconstruction remain at full output resolution.
#define WITCHER_MOTION_TILE 128u
// Projection, native conversion dimensions, and four reprojection matrix rows.
#define WITCHER_MOTION_HEADER 6u
#define WITCHER_MOTION_CAMERA 1u
#define WITCHER_MOTION_OBJECT 2u

#endif
