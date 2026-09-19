/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <cstddef>
#include <cstdint>
#include "./fg_protocol.hpp"
#include "./presentation_pacing.hpp"
#include "./dlaa_protocol.hpp"

namespace acbrotherhood::presentation {
constexpr uint32_t kMagic = 0x32315844, kProtocol = 8;
enum class State : int32_t { starting, ready, complete, failed };
enum class Command : uint32_t { present, stop, begin_frame, render_begin, dlaa_evaluate, dlaa_release };
enum class Stage : uint32_t { none, protocol, adapter, device, sharing, window, swapchain, copy, gpu_wait, present };
// The producer owns the packet until request is signaled; the consumer owns it
// until reply. GPU ownership additionally follows the shared source fence and
// the consumer completion acknowledgement. Exactly one frame can be in flight.
struct alignas(8) Packet {
  uint32_t magic = kMagic, version = kProtocol;
  uint32_t width = 0, height = 0, format = 0, color_space = 0;
  uint32_t adapter_low = 0;
  int32_t adapter_high = 0;
  uint64_t window = 0, source_texture = 0;
  uint64_t frame = 0, completed = 0;
  uint32_t sync_interval = 0, present_flags = 0;
  Command command = Command::present;
  volatile State state = State::starting;
  Stage stage = Stage::none;
  uint32_t error = 0;
  uint64_t output_window = 0;
  uint32_t validation = 0, checksum = 0;  // Readback only in the GPU fixture.
  frame_generation::Inputs inputs;
  uint32_t accepted_inputs = 0, input_checksums[4] = {};
  uint32_t generation_requested = 0, pause_flags = 0; // 0 Off, otherwise generated frames (1..5).
  frame_generation::Status generation_status = frame_generation::Status::off;
  uint32_t generation_error = 0, generated_present_count = 0, reflex_active = 0;
  uint32_t generation_max = 0, generation_configured = 0;
  PacingSettings pacing;
  PacingState pacing_state;
  dlaa::Packet dlaa;
};
static_assert(sizeof(Packet) == 728 && offsetof(Packet, frame) == 48 && offsetof(Packet, output_window) == 88);
struct Failure { Stage stage; uint32_t code; };
inline void Check(long result, Stage stage) {
  if (result < 0) throw Failure{stage, uint32_t(result)};
}
}  // namespace acbrotherhood::presentation
