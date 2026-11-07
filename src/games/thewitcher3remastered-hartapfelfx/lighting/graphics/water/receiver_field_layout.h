// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#define W3_WATER_FIELD_MAGIC 0x57334644u
#define W3_WATER_FIELD_VERSION 1u
#define W3_WATER_FIELD_GRID 129u
#define W3_WATER_FIELD_EXTENT 64.f
#define W3_WATER_FIELD_HEADER 128u
#define W3_WATER_FIELD_BYTES (W3_WATER_FIELD_HEADER + W3_WATER_FIELD_GRID * W3_WATER_FIELD_GRID * 16u)
// Keep the v1 column/header contract intact for existing raster and DXR readers.
// The optional geometry extension has a separate header at byte 80. A zero
// extension header means no displaced surface was captured in this recording.
#define W3_WATER_SURFACE_MAGIC 0x57335346u
#define W3_WATER_SURFACE_VERSION 2u
#define W3_WATER_CAUSTIC_GRID 256u
#define W3_WATER_CAUSTIC_VERTICES (W3_WATER_CAUSTIC_GRID + 1u)
// A one-vertex border supplies centered geometric derivatives at every photon.
#define W3_WATER_SURFACE_GRID (W3_WATER_CAUSTIC_VERTICES + 2u)
#define W3_WATER_SURFACE_OFFSET W3_WATER_FIELD_BYTES
#define W3_WATER_SURFACE_BYTES (W3_WATER_SURFACE_OFFSET + W3_WATER_SURFACE_GRID * W3_WATER_SURFACE_GRID * 4u * 16u)
#define W3_WATER_PHOTON_BOUNDS W3_WATER_SURFACE_BYTES
#define W3_WATER_PHOTON_OFFSET (W3_WATER_PHOTON_BOUNDS + 128u)
// Four displaced-surface layers followed by the same four regional-mean layers.
#define W3_WATER_PHOTON_BYTES (W3_WATER_PHOTON_OFFSET + W3_WATER_CAUSTIC_VERTICES * W3_WATER_CAUSTIC_VERTICES * 8u * 16u)
#define W3_WATER_CAUSTIC_TILE (W3_WATER_CAUSTIC_GRID * 2u)
#define W3_WATER_CAUSTIC_ATLAS (W3_WATER_CAUSTIC_TILE * 2u)
#define W3_WATER_CAUSTIC_MAGIC 0x57334341u
#define W3_WATER_CAUSTIC_VERSION 3u
#define W3_WATER_CAUSTIC_OFFSET W3_WATER_PHOTON_BYTES
#define W3_WATER_COVERAGE_OFFSET (W3_WATER_CAUSTIC_OFFSET + W3_WATER_CAUSTIC_ATLAS * W3_WATER_CAUSTIC_ATLAS * 16u)
// Levels 1..9 of a minimum pyramid, ending at one texel per depth tile.
#define W3_WATER_COVERAGE_LEVELS 9u
#define W3_WATER_COVERAGE_LEVEL_OFFSET(level) (W3_WATER_COVERAGE_OFFSET + ((W3_WATER_CAUSTIC_ATLAS * W3_WATER_CAUSTIC_ATLAS \
    - (W3_WATER_CAUSTIC_ATLAS >> ((level) - 1u)) * (W3_WATER_CAUSTIC_ATLAS >> ((level) - 1u))) / 3u) * 8u)
#define W3_WATER_CAUSTIC_BYTES (W3_WATER_COVERAGE_OFFSET + ((W3_WATER_CAUSTIC_ATLAS * W3_WATER_CAUSTIC_ATLAS - 4u) / 3u) * 8u)
