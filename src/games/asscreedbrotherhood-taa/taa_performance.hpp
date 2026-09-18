/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <array>
#include <d3d9.h>
#include <wrl/client.h>

namespace acbrotherhood::taa {

// Optional diagnostics: CPU submission includes driver time, while timestamps
// measure GPU timeline intervals (including submission gaps). Query results
// are polled without flushing or waiting; this is not a GPU-busy percentage.
struct Performance {
  enum CpuStage { CAPTURE, JITTER, CAMERA, MOTION, RESOLVE, CPU_STAGE_COUNT };
  std::array<LONGLONG, CPU_STAGE_COUNT> cpu_ticks = {};
  unsigned frames = 0, gpu_frames = 0;
  double motion_gpu_ms = 0., resolve_gpu_ms = 0.;
  struct GpuFrame {
    std::array<Microsoft::WRL::ComPtr<IDirect3DQuery9>, 3> timestamps;
    Microsoft::WRL::ComPtr<IDirect3DQuery9> frequency, disjoint;
    bool pending = false;
  };
  std::array<GpuFrame, 4> gpu;
  int active = -1;
  bool gpu_failed = false;

  struct CpuScope {
    LONGLONG* total;
    LARGE_INTEGER start = {};
    explicit CpuScope(LONGLONG* total) : total(total) { if (total) QueryPerformanceCounter(&start); }
    ~CpuScope() {
      if (!total) return;
      LARGE_INTEGER end;
      QueryPerformanceCounter(&end);
      *total += end.QuadPart - start.QuadPart;
    }
  };

  double CpuMilliseconds(CpuStage stage) const {
    LARGE_INTEGER frequency;
    QueryPerformanceFrequency(&frequency);
    return frames ? double(cpu_ticks[stage]) * 1000. / frequency.QuadPart / frames : 0.;
  }

  void BeginGpu(IDirect3DDevice9* native) {
    active = -1;
    if (gpu_failed) return;
    for (auto& frame : gpu) {
      if (!frame.pending) continue;
      std::array<UINT64, 3> ticks;
      UINT64 frequency;
      BOOL disjoint;
      HRESULT status = frame.disjoint->GetData(&disjoint, sizeof(disjoint), 0);
      if (status == S_OK) status = frame.frequency->GetData(&frequency, sizeof(frequency), 0);
      for (unsigned i = 0; i < ticks.size() && status == S_OK; ++i)
        status = frame.timestamps[i]->GetData(&ticks[i], sizeof(ticks[i]), 0);
      if (status == S_FALSE) continue;
      frame.pending = false;
      if (FAILED(status)) { gpu_failed = true; return; }
      if (!disjoint && frequency != 0 && ticks[0] <= ticks[1] && ticks[1] <= ticks[2]) {
        motion_gpu_ms += double(ticks[1] - ticks[0]) * 1000. / frequency;
        resolve_gpu_ms += double(ticks[2] - ticks[1]) * 1000. / frequency;
        ++gpu_frames;
      }
    }
    for (unsigned index = 0; index < gpu.size(); ++index) {
      auto& frame = gpu[index];
      if (frame.pending) continue;
      if (!frame.frequency) {
        HRESULT status = native->CreateQuery(D3DQUERYTYPE_TIMESTAMPFREQ, &frame.frequency);
        if (SUCCEEDED(status)) status = native->CreateQuery(D3DQUERYTYPE_TIMESTAMPDISJOINT, &frame.disjoint);
        for (auto& timestamp : frame.timestamps) if (SUCCEEDED(status)) status = native->CreateQuery(D3DQUERYTYPE_TIMESTAMP, &timestamp);
        if (FAILED(status)) { frame = {}; gpu_failed = true; return; }
      }
      if (FAILED(frame.disjoint->Issue(D3DISSUE_BEGIN)) || FAILED(frame.timestamps[0]->Issue(D3DISSUE_END))) {
        gpu_failed = true;
        return;
      }
      active = int(index);
      return;
    }
    // All query slots still in flight: skip this sample rather than synchronize.
  }

  void EndMotionGpu() {
    if (active >= 0 && FAILED(gpu[active].timestamps[1]->Issue(D3DISSUE_END))) gpu_failed = true;
  }

  void EndGpu() {
    if (active < 0) return;
    auto& frame = gpu[active];
    if (FAILED(frame.timestamps[2]->Issue(D3DISSUE_END)) || FAILED(frame.frequency->Issue(D3DISSUE_END))
        || FAILED(frame.disjoint->Issue(D3DISSUE_END))) gpu_failed = true;
    frame.pending = !gpu_failed;
    active = -1;
  }

  void ResetTotals() {
    cpu_ticks = {};
    frames = gpu_frames = 0;
    motion_gpu_ms = resolve_gpu_ms = 0.;
  }
};
}  // namespace acbrotherhood::taa
