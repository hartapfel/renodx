/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <cassert>
#include <cstdio>
#include <thread>
#include <vector>
#include "../frame_generation/engine.hpp"
namespace fg = witcher3classic::frame_generation;
struct Token : sl::FrameToken {
  uint32_t id = 0;
  operator uint32_t() const override { return id; }
};
std::array<Token, 16> tokens;
uint32_t issued = 0;
std::vector<std::pair<sl::PCLMarker, uint32_t>> markers;
alignas(uintptr_t) std::array<uint8_t, 0xb430> view{};
uintptr_t next_command = 1;
sl::Result NewFrame(sl::FrameToken*& out, const uint32_t*) {
  tokens[issued].id = issued + 1;
  out = &tokens[issued++];
  return sl::Result::eOk;
}
sl::Result Marker(sl::PCLMarker marker, const sl::FrameToken& token) {
  markers.emplace_back(marker, uint32_t(token));
  return sl::Result::eOk;
}
uintptr_t Tick(uintptr_t, uintptr_t) {
  fg::engine::ConstructHook(next_command++, reinterpret_cast<uintptr_t>(view.data()), 1);
  return 7;
}
int main() {
  fg::Session session;
  session.new_frame = NewFrame;
  session.sleep = [](const sl::FrameToken&) { return sl::Result::eOk; };
  session.marker = Marker;
  session.reflex_options = [](const sl::ReflexOptions&) { return sl::Result::eOk; };
  session.pcl_state = [](sl::PCLState& state) { state.statsWindowMessage = WM_APP + 100; return sl::Result::eOk; };
  session.pcl_options = [](const sl::PCLOptions& options) {
    assert(options.idThread == GetCurrentThreadId());
    return sl::Result::eOk;
  };
  fg::engine::pump = [] {};
  fg::engine::tick = Tick;
  fg::engine::construct = [](uintptr_t command, uintptr_t, uintptr_t) { return command; };
  fg::engine::execute = [](uintptr_t) {};
  *reinterpret_cast<uintptr_t*>(view.data() + 0x10) = 1;
  view[0x824] = 1;
  assert(fg::engine::Attach(&session));
  for (int i = 0; i < 2; ++i) {
    fg::engine::PumpHook();
    assert(fg::engine::TickHook(0, 0) == 7);
  }
  // Both simulations are complete before the worker executes the first.
  // The rendered token must still identify command 1, not latest simulation 2.
  std::thread worker([] {
    fg::engine::ExecuteHook(1);
    assert(uint32_t(*fg::engine::FinishRender()) == 1);
    assert(!fg::engine::FinishRender());
    fg::engine::ExecuteHook(999);
    assert(!fg::engine::FinishRender());
    fg::engine::ExecuteHook(2);
    assert(uint32_t(*fg::engine::FinishRender()) == 2);
  });
  worker.join();
  assert(markers.size() == 8);
  assert(markers[0] == std::make_pair(sl::PCLMarker::eSimulationStart, 1u));
  assert(markers[1] == std::make_pair(sl::PCLMarker::eSimulationEnd, 1u));
  assert(markers[4] == std::make_pair(sl::PCLMarker::eRenderSubmitStart, 1u));
  assert(markers[5] == std::make_pair(sl::PCLMarker::eRenderSubmitEnd, 1u));
  fg::engine::PumpHook();
  fg::engine::TickHook(0, 0);
  fg::engine::Detach();
  assert(fg::engine::Attach(&session));
  fg::engine::ExecuteHook(3);
  assert(!fg::engine::FinishRender());  // Prior session's queued token invalidated.
  fg::engine::PumpHook();
  fg::engine::TickHook(0, 0);
  ++tokens[3].id;  // Simulate SL recycling a queued token before Execute.
  fg::engine::ExecuteHook(4);
  assert(!fg::engine::FinishRender());
  fg::engine::PumpHook();
  fg::engine::TickHook(0, 0);
  fg::engine::ExecuteHook(5);
  ++tokens[4].id;  // Also reject recycling between Execute and Present.
  assert(!fg::engine::FinishRender());
  assert(PostThreadMessageW(GetCurrentThreadId(), WM_APP + 100, 0, 0));
  fg::engine::PumpHook();
  assert(markers.back() == std::make_pair(sl::PCLMarker::ePCLatencyPing, issued));
  fg::engine::Detach();
  std::puts("PASS: simulation handoff, worker identity, one-shot Present, unknown commands, session lifetime, recycled tokens");
}
