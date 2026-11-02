/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11_1.h>
#include <wrl/client.h>
#include <algorithm>
#include <array>
#include <atomic>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

namespace witcher3classic::profiling {
// Opt-in, bounded capture. No queries, allocations, readbacks or clocks in a
// disabled Scope. Poll only at Present with DONOTFLUSH; never wait for the GPU.
class Capture {
  using Clock = std::chrono::steady_clock;
  template<class T> using ComPtr = Microsoft::WRL::ComPtr<T>;
  struct Event {
    ComPtr<ID3D11Query> begin, end;
    const char* name = nullptr;
    UINT width = 0, height = 0;
    Clock::time_point submitted;
    double cpu_ms = 0;
  };
  struct FrameQueries {
    ComPtr<ID3D11Query> disjoint;
    std::array<Event, 48> events;
    UINT count = 0, frame = 0;
    bool pending = false;
  };
 public:
  struct Sample {
    const char* name;
    UINT frame, width, height;
    double gpu_ms, cpu_ms;
  };
  std::atomic<bool> requested = false;
  std::string report;
  std::vector<Sample> samples;

  size_t Begin(ID3D11DeviceContext1* context, const char* name, UINT width, UINT height) {
    if (!current_ || context != context_.Get() || current_->count == current_->events.size()) return SIZE_MAX;
    const size_t index = current_->count++;
    auto& event = current_->events[index];
    event.name = name; event.width = width; event.height = height;
    event.submitted = Clock::now();
    context->End(event.begin.Get());
    return index;
  }
  void End(size_t index) {
    if (index == SIZE_MAX || !current_ || index >= current_->count) return;
    auto& event = current_->events[index];
    context_->End(event.end.Get());
    event.cpu_ms = std::chrono::duration<double, std::milli>(Clock::now() - event.submitted).count();
  }
  bool Active() const { return context_ != nullptr; }
  void Reset() {
    if (current_ && context_) context_->End(current_->disjoint.Get());
    current_ = nullptr; context_.Reset();
    for (auto& frame : ring_) frame = {};
  }
  void Frame(ID3D11DeviceContext1* context) {
    if (requested.exchange(false) && !Active()) {
      Reset(); report.clear(); samples.clear(); samples.reserve(300 * 48);
      frame_ = dropped_ = invalid_ = 0;
      if (!context || context->GetType() != D3D11_DEVICE_CONTEXT_IMMEDIATE) return;
      context_ = context;
      ComPtr<ID3D11Device> device; context->GetDevice(&device);
      for (auto& frame : ring_) {
        D3D11_QUERY_DESC desc{D3D11_QUERY_TIMESTAMP_DISJOINT};
        if (FAILED(device->CreateQuery(&desc, &frame.disjoint))) { Reset(); report = "GPU capture: query creation failed"; return; }
        desc.Query = D3D11_QUERY_TIMESTAMP;
        for (auto& event : frame.events) {
          if (FAILED(device->CreateQuery(&desc, &event.begin)) || FAILED(device->CreateQuery(&desc, &event.end))) {
            Reset(); report = "GPU capture: timestamp creation failed"; return;
          }
        }
      }
    }
    if (!context_ || context != context_.Get()) return;
    if (current_) {
      context->End(current_->disjoint.Get());
      current_->pending = true;
      current_ = nullptr;
    }
    bool pending = false;
    for (auto& frame : ring_) {
      if (!frame.pending) continue;
      D3D11_QUERY_DATA_TIMESTAMP_DISJOINT timing{};
      const auto ready = context->GetData(frame.disjoint.Get(), &timing, sizeof(timing), D3D11_ASYNC_GETDATA_DONOTFLUSH);
      if (ready == S_FALSE) { pending = true; continue; }
      if (FAILED(ready) || timing.Disjoint || !timing.Frequency) { frame.pending = false; ++invalid_; continue; }
      std::array<std::array<UINT64, 2>, 48> ticks{};
      bool complete = true, failed = false;
      for (UINT i = 0; i < frame.count; ++i) {
        const auto first = context->GetData(frame.events[i].begin.Get(), &ticks[i][0], sizeof(UINT64), D3D11_ASYNC_GETDATA_DONOTFLUSH);
        const auto last = context->GetData(frame.events[i].end.Get(), &ticks[i][1], sizeof(UINT64), D3D11_ASYNC_GETDATA_DONOTFLUSH);
        failed |= FAILED(first) || FAILED(last);
        complete &= first == S_OK && last == S_OK;
      }
      if (failed) { frame.pending = false; ++invalid_; continue; }
      if (!complete) { pending = true; continue; }
      if (frame.frame >= 120) for (UINT i = 0; i < frame.count; ++i) {
        const auto& event = frame.events[i];
        if (ticks[i][1] >= ticks[i][0]) samples.push_back({event.name, frame.frame - 120, event.width, event.height,
            double(ticks[i][1] - ticks[i][0]) * 1000. / double(timing.Frequency), event.cpu_ms});
      }
      frame.pending = false;
    }
    if (frame_ < 420) {
      auto& next = ring_[frame_ % ring_.size()];
      if (!next.pending) {
        next.count = 0; next.frame = frame_; current_ = &next;
        context->Begin(next.disjoint.Get());
      } else ++dropped_;
      ++frame_;
    } else if (!pending) {
      std::ostringstream summary;
      summary << "Classic GPU capture: 120 warmup + 300 requested frames, dropped=" << dropped_ << ", invalid=" << invalid_;
      try {
        const auto path = std::filesystem::temp_directory_path() / ("renodx-classic-gpu-" + std::to_string(GetTickCount64()) + ".csv");
        std::ofstream csv(path);
        csv << "frame,range,width,height,gpu_ms,cpu_submit_ms\n";
        for (const auto& sample : samples) csv << sample.frame << ',' << sample.name << ',' << sample.width << ',' << sample.height << ',' << sample.gpu_ms << ',' << sample.cpu_ms << '\n';
        if (csv.good()) summary << "; CSV=" << path.string();
        else summary << "; CSV write failed";
      } catch (...) { summary << "; CSV unavailable"; }
      // Ranges can be inclusive/nested. Never sum them into total frame time.
      std::vector<const char*> names;
      for (const auto& sample : samples) if (std::find(names.begin(), names.end(), sample.name) == names.end()) names.push_back(sample.name);
      for (const auto* name : names) {
        std::vector<double> times;
        for (const auto& sample : samples) if (sample.name == name) times.push_back(sample.gpu_ms);
        std::sort(times.begin(), times.end());
        summary << "\n" << name << " n=" << times.size() << " GPU p50/p95/p99 ms="
                << times[(times.size() - 1) / 2] << '/' << times[(times.size() - 1) * 95 / 100] << '/' << times[(times.size() - 1) * 99 / 100];
      }
      report = summary.str(); Reset();
    }
  }
 private:
  ComPtr<ID3D11DeviceContext1> context_;
  std::array<FrameQueries, 8> ring_;
  FrameQueries* current_ = nullptr;
  UINT frame_ = 0, dropped_ = 0, invalid_ = 0;
};
inline Capture capture;
class Scope {
 public:
  Scope(ID3D11DeviceContext1* context, const char* name, UINT width = 0, UINT height = 0)
      : index_(capture.Begin(context, name, width, height)) {}
  ~Scope() { capture.End(index_); }
  Scope(const Scope&) = delete;
  Scope& operator=(const Scope&) = delete;
 private:
  size_t index_;
};
} // namespace witcher3classic::profiling
