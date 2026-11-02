/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <cassert>
#include <iostream>
#include <thread>
#include "../graphics_profile.hpp"
using Microsoft::WRL::ComPtr;
using namespace witcher3classic::profiling;
int main(int argc, char**) {
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> base;
  ComPtr<ID3D11DeviceContext1> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr, argc > 1 ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP,
      nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &base)));
  assert(SUCCEEDED(base.As(&context)));
  { Scope disabled(nullptr, "disabled"); }
  assert(!capture.Active() && capture.samples.empty());
  const D3D11_BUFFER_DESC desc{4096, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER};
  ComPtr<ID3D11Buffer> buffer;
  assert(SUCCEEDED(device->CreateBuffer(&desc, nullptr, &buffer)));
  std::array<float,1024> data{};
  capture.requested = true;
  capture.Frame(context.Get());
  for (unsigned i = 0; i < 1000 && capture.Active(); ++i) {
    {
      Scope outer(context.Get(), "outer", 64, 64);
      Scope inner(context.Get(), "upload", 64, 64);
      context->UpdateSubresource(buffer.Get(), 0, nullptr, data.data(), 0, 0);
    }
    // The headless fixture has no Present to submit work. Production capture
    // never flushes or sleeps; this simulates submission and frame pacing.
    context->Flush();
    std::this_thread::sleep_for(std::chrono::milliseconds(2));
    capture.Frame(context.Get());
  }
  assert(!capture.Active() && !capture.report.empty());
  assert(capture.samples.size() == 600);
  for (const auto& sample : capture.samples) {
    assert(sample.frame < 300 && sample.width == 64 && sample.height == 64);
    assert(sample.gpu_ms >= 0 && sample.cpu_ms >= 0);
  }
  std::cout << capture.report << "\nPASS bounded asynchronous capture, nested ranges, warmup exclusion and disabled path\n";
}
