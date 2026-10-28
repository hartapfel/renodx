/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <array>
#include <mutex>
#include "../temporal/camera.hpp"
#include "./streamline.hpp"

namespace witcher3classic::frame_generation::engine {
// Audited Classic 1.32: outer-loop message pump -> running-state tick ->
// world-render command construction -> queue -> render-worker Execute.
// Key by command identity, never by the latest simulation counter. Other
// engine states and unassociated render jobs cannot borrow a gameplay token.
struct Frame {
  sl::FrameToken* token = nullptr;
  uint64_t epoch = 0;
  uint32_t id = 0;
  bool ended = false, running = false;
};
struct State {
  std::mutex mutex;
  Session* session = nullptr;
  uint64_t epoch = 0;
  struct Pending {
    uintptr_t command = 0;
    Frame frame;
  };
  std::array<Pending, 32> pending{};
  bool healthy = true;
  UINT ping_message = 0;
  DWORD simulation_thread = 0;
};
inline State* state = new State;
inline thread_local Frame simulation, rendering;
using Pump = void (*)();
using Tick = uintptr_t (*)(uintptr_t, uintptr_t);
using Construct = uintptr_t (*)(uintptr_t, uintptr_t, uintptr_t);
using Execute = void (*)(uintptr_t);
inline Pump pump = nullptr;
inline Tick tick = nullptr;
inline Construct construct = nullptr;
inline Execute execute = nullptr;
inline void EndSimulation();

inline bool Attach(Session* session) {
  std::lock_guard lock(state->mutex);
  sl::ReflexOptions options{};
  options.mode = sl::ReflexMode::eLowLatency;
  if (!session || session->reflex_options(options) != sl::Result::eOk) return false;
  sl::PCLState pcl{};
  if (session->pcl_state(pcl) != sl::Result::eOk || !pcl.statsWindowMessage) return false;
  state->ping_message = pcl.statsWindowMessage;
  state->simulation_thread = 0;
  state->session = session;
  ++state->epoch;
  state->pending = {};
  state->healthy = true;
  return true;
}
inline void Detach() {
  // Serialize against Sleep/markers before Presenter shuts down its session.
  std::lock_guard lock(state->mutex);
  state->session = nullptr;
  ++state->epoch;
  state->pending = {};
}
inline void PumpHook() {
  EndSimulation();
  simulation = {};
  UINT ping_message = 0;
  {
    std::lock_guard lock(state->mutex);
    if (auto* session = state->session; session && state->healthy) {
      if (!state->simulation_thread) {
        sl::PCLOptions options{};
        options.idThread = GetCurrentThreadId();
        state->healthy = session->pcl_options(options) == sl::Result::eOk;
        state->simulation_thread = options.idThread;
      }
      simulation.epoch = state->epoch;
      state->healthy = state->healthy && session->new_frame(simulation.token, nullptr) == sl::Result::eOk
                       && session->sleep(*simulation.token) == sl::Result::eOk
                       && session->marker(sl::PCLMarker::eSimulationStart, *simulation.token) == sl::Result::eOk;
      if (!state->healthy)
        simulation = {};
      else
        simulation.id = uint32_t(*simulation.token);
      ping_message = state->ping_message;
    }
  }
  // Consume only NVIDIA's configured thread-message ID at the actual input
  // pump. PeekMessage may dispatch sent messages, so never hold our mutex here.
  MSG message{};
  while (ping_message && PeekMessageW(&message, reinterpret_cast<HWND>(-1), ping_message, ping_message, PM_REMOVE)) {
    std::lock_guard lock(state->mutex);
    if (state->session && state->healthy && simulation.token && simulation.epoch == state->epoch)
      state->healthy &= state->session->marker(sl::PCLMarker::ePCLatencyPing, *simulation.token) == sl::Result::eOk;
  }
  pump();  // The verified outer-loop pump precedes game input/simulation.
}
inline void EndSimulation() {
  if (!simulation.token || simulation.ended) return;
  std::lock_guard lock(state->mutex);
  if (state->session && simulation.epoch == state->epoch)
    state->healthy &= state->session->marker(sl::PCLMarker::eSimulationEnd, *simulation.token) == sl::Result::eOk;
  simulation.ended = true;
}
inline uintptr_t TickHook(uintptr_t self, uintptr_t application) {
  simulation.running = simulation.token != nullptr;
  const auto result = tick(self, application);
  EndSimulation();
  simulation.running = false;
  return result;
}
inline uintptr_t ConstructHook(uintptr_t command, uintptr_t view, uintptr_t world) {
  const auto result = construct(command, view, world);
  // The constructor has finished copying/retaining the submitted view. End
  // simulation before the caller publishes this command to the worker queue.
  if (simulation.running && simulation.token && world && view
      && *reinterpret_cast<void**>(view + 0x10)
      && *reinterpret_cast<uint8_t*>(view + 0x830) == 0
      && *reinterpret_cast<uint8_t*>(view + 0x824) != 0) {
    EndSimulation();
    std::lock_guard lock(state->mutex);
    if (state->session && simulation.epoch == state->epoch && state->healthy) {
      for (auto& pending : state->pending) {
        if (!pending.command || pending.command == command) {
          pending = {command, simulation};
          simulation.running = false;
          return result;
        }
      }
      // Bounded storage; unexpected queue growth must not reuse stale tokens.
      state->healthy = false;
    }
  }
  return result;
}
inline void ExecuteHook(uintptr_t command) {
  rendering = {};
  {
    std::lock_guard lock(state->mutex);
    for (auto& pending : state->pending) {
      if (pending.command != command) continue;
      if (state->session && state->healthy && pending.frame.epoch == state->epoch
          && pending.frame.id == uint32_t(*pending.frame.token)) {
        rendering = pending.frame;
        state->healthy &= state->session->marker(sl::PCLMarker::eRenderSubmitStart, *rendering.token) == sl::Result::eOk;
      }
      pending = {};
      break;
    }
  }
  execute(command);
  // Present follows this command, after the remaining postprocessing/UI jobs.
}
inline sl::FrameToken* FinishRender() {
  std::lock_guard lock(state->mutex);
  auto* token = rendering.token;
  rendering.token = nullptr;
  if (!state->session || !state->healthy || rendering.epoch != state->epoch || !token) return nullptr;
  // Streamline owns a bounded token pool. A stalled worker must never submit
  // an entry whose token has since been recycled for another simulation.
  if (rendering.id != uint32_t(*token)) return nullptr;
  state->healthy &= state->session->marker(sl::PCLMarker::eRenderSubmitEnd, *token) == sl::Result::eOk;
  return state->healthy ? token : nullptr;
}
inline bool Verify() {
  temporal::Camera camera;
  if (!camera.Initialize()) return false;
  const auto image = reinterpret_cast<uintptr_t>(GetModuleHandleW(nullptr));
  // Full instruction prefixes from the executable already audited for SR.
  constexpr uint8_t pump_bytes[] = {0x48, 0x8b, 0x0d, 0xb1, 0xab, 0xa6, 0x02, 0x48, 0x85, 0xc9, 0x74, 0x06, 0x48, 0x8b, 0x01, 0x48, 0xff, 0x20};
  constexpr uint8_t tick_bytes[] = {0x40, 0x53, 0x48, 0x83, 0xec, 0x20, 0x48, 0x8b, 0x0d, 0xeb, 0x39, 0xaa, 0x02, 0x48, 0x8b, 0xda, 0x48, 0x8b, 0x01, 0xff, 0x50, 0x60};
  constexpr uint8_t construct_bytes[] = {0x48, 0x89, 0x5c, 0x24, 0x08, 0x48, 0x89, 0x74, 0x24, 0x10, 0x57, 0x48, 0x83, 0xec, 0x20, 0x49, 0x8b, 0xd8, 0x48, 0x8b, 0xfa, 0x48, 0x8b, 0xf1};
  constexpr uint8_t execute_bytes[] = {0x40, 0x57, 0x48, 0x83, 0xec, 0x20, 0x48, 0x8b, 0xf9, 0x48, 0x8b, 0x0d, 0x68, 0x92, 0x10, 0x02, 0xe8, 0x6b, 0xf5, 0x09, 0x00};
  if (std::memcmp(reinterpret_cast<void*>(image + 0x36d0), pump_bytes, sizeof(pump_bytes))
      || std::memcmp(reinterpret_cast<void*>(image + 0x3050), tick_bytes, sizeof(tick_bytes))
      || std::memcmp(reinterpret_cast<void*>(image + 0x147830), construct_bytes, sizeof(construct_bytes))
      || std::memcmp(reinterpret_cast<void*>(image + 0xbc62d0), execute_bytes, sizeof(execute_bytes))) return false;
  pump = reinterpret_cast<Pump>(image + 0x36d0);
  tick = reinterpret_cast<Tick>(image + 0x3050);
  construct = reinterpret_cast<Construct>(image + 0x147830);
  execute = reinterpret_cast<Execute>(image + 0xbc62d0);
  return true;
}
}  // namespace witcher3classic::frame_generation::engine
