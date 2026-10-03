/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#ifndef WITCHER_MOTION_BLUR_CONFIG_H
#define WITCHER_MOTION_BLUR_CONFIG_H

// Shared by CPU allocation, GPU reduction and the reference harness. Coarser
// velocity tiles make a full-frame swept-neighbor search practical; scene color
// and reconstruction remain at full output resolution.
#define WITCHER_MOTION_TILE 128u

#endif
