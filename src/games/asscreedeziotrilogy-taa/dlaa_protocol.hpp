/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <array>
#include <cstddef>
#include <cstdint>

namespace acbrotherhood::dlaa {
constexpr uint32_t kProtocol = 4;
constexpr uint32_t kMagic = 0x41414C44;
// NGX render-preset values: DLL default (no hint), F, J, K, L, M.
constexpr std::array<uint32_t, 6> kRenderPresets = {0, 6, 10, 11, 12, 13};
enum class WorkerState : int32_t { starting, ready, complete, failed };
enum class Stage : uint32_t { none, protocol, device, shared_textures, shader, ngx_init, ngx_capability, ngx_create, evaluate, gpu_wait };
enum class Command : uint32_t { evaluate, stop };
// Fixed-width fields only: shared by an x86 addon and an x64 executable.
// Events publish complete packets. Neither side edits a packet while in flight.
struct alignas(8) Frame {
  uint64_t id = 0;
  float jitter_x = 0, jitter_y = 0;
  float time_ms = 16.666667f;
  uint32_t reset = 1;
};
struct alignas(8) Packet {
  uint32_t magic = kMagic, version = kProtocol;
  uint32_t width = 0, height = 0;
  uint32_t adapter_low = 0;
  int32_t adapter_high = 0;
  uint64_t color = 0, motion = 0, depth = 0, output = 0;
  Frame frame;
  uint64_t completed_id = 0;
  Command command = Command::evaluate;
  volatile WorkerState state = WorkerState::starting;
  Stage stage = Stage::none;
  uint32_t error = 0;
  uint32_t render_preset = 0;
  uint32_t backend = 0; // Helper acknowledgement: D3D12 = 12.
  uint64_t generation = 0; // Distinguishes reused DX9 handles after reset.
  float current_camera[16] = {}, clip_to_previous[16] = {};
};
static_assert(sizeof(Frame) == 24 && sizeof(Packet) == 248);
static_assert(offsetof(Packet, frame) == 56 && offsetof(Packet, state) == 92);
static_assert(offsetof(Packet, render_preset) == 104);
}  // namespace acbrotherhood::dlaa
