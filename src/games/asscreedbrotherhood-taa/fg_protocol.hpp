/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <cstdint>
#include <cstddef>
namespace acbrotherhood::frame_generation {
enum InputFlags : uint32_t { motion_depth = 1, hudless = 2, hdr_encoded = 4, ui_alpha = 8 };
enum class Status : uint32_t { off, waiting, active, overlay, effects, inputs, camera, timing, unsupported, failed, inactive, resizing, multiplier_unsupported, vsync };
enum PauseFlags : uint32_t { overlay_open = 1, effects_rendered = 2, window_inactive = 4, window_resizing = 8 };
// Matrices retain the game's column-vector convention. Convert explicitly when
// building Streamline's row-vector Constants; these are all UNJITTERED.
// Motion XY is previous-current UV (scale 1), Z is uncertain pose, W validity.
// Depth is ordinary D3D z/w: near 0, far/sky 1. All images use the output grid.
struct alignas(8) Inputs {
  uint64_t id = 0, generation = 0, window = 0;
  uint64_t textures[4] = {}; // motion RGBA16F, depth R32F, HUD-less output, UI alpha (native transmittance before encoding)
  uint32_t width = 0, height = 0, flags = 0, reset = 1;
  float jitter[2] = {}, delta_ms = 0.f;
  uint32_t hudless_format = 0;
  float current_camera[16] = {}, previous_camera[16] = {}, clip_to_previous[16] = {};
};
static_assert(sizeof(Inputs) == 280 && offsetof(Inputs, current_camera) == 88);
}
