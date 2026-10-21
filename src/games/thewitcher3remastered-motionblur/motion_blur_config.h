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
// Fixed grid reservation keeps the per-input-pixel motion cache independent
// of viewport/tile dimensions. The optional half-resolution image follows it.
#define WITCHER_MOTION_CACHE (WITCHER_MOTION_HEADER + 2u * (16384u / WITCHER_MOTION_TILE) * (16384u / WITCHER_MOTION_TILE))
#define WITCHER_MOTION_CAMERA 1u
#define WITCHER_MOTION_OBJECT 2u

#endif
