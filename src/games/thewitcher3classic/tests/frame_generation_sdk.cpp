/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
// Standalone SDK probe. Does not change the game, driver profile or desktop.
#include <dxgi1_4.h>
#include <wrl/client.h>
#include <cassert>
#include <cstdio>
#include <limits>
#include "../frame_generation/streamline.hpp"
using namespace witcher3classic::frame_generation;
using Microsoft::WRL::ComPtr;

int wmain(int argc, wchar_t** argv) {
  std::setvbuf(stdout, nullptr, _IONBF, 0);
  Frame frame{true, true, true, true, false, true, true, true, 3840, 2160};
  Capabilities caps{true, true, true, 5, 512};
  for (uint32_t multiplier = 2; multiplier <= 6; ++multiplier) {
    const auto decision = Resolve({Mode::Fixed, multiplier}, caps, frame);
    assert(decision.generated == multiplier - 1);
    const auto options = Session::Options(decision);
    assert(options.numFramesToGenerate == multiplier - 1 && options.mode == sl::DLSSGMode::eOn);
  }
  assert(Resolve({Mode::Fixed, 7}, caps, frame).mode == Mode::Off);
  caps.max_generated = 1;
  assert(Resolve({Mode::Fixed, 3}, caps, frame).mode == Mode::Off);
  assert(Resolve({Mode::Fixed, 2}, caps, frame).generated == 1);
  caps.dynamic = false;
  assert(Resolve({Mode::Dynamic}, caps, frame).mode == Mode::Off);
  caps.dynamic = true;
  const auto dynamic = Session::Options(Resolve({Mode::Dynamic, 99, 144, true}, caps, frame));
  assert(dynamic.mode == sl::DLSSGMode::eDynamic && dynamic.dynamicTargetFrameRate == 144
         && dynamic.enableUserInterfaceRecomposition == sl::Boolean::eTrue);
  assert(Resolve({Mode::Dynamic, 2, std::numeric_limits<float>::quiet_NaN()}, caps, frame).mode == Mode::Off);
  assert(Resolve({Mode::Auto, 2}, caps, frame).mode == Mode::Auto);
  for (int i = 0; i < 8; ++i) {
    auto invalid = frame;
    switch (i) {
      case 0: invalid.presenter_ready = false; break;
      case 1: invalid.hdr10 = false; break;
      case 2: invalid.inputs_valid = false; break;
      case 3: invalid.gameplay = false; break;
      case 4: invalid.transitioning = true; break;
      case 5: invalid.hud_valid = false; break;
      case 6: invalid.reflex_active = false; break;
      case 7: invalid.runtime_ok = false; break;
    }
    assert(Resolve({Mode::Fixed}, caps, invalid).mode == Mode::Off);
  }
  caps.reflex_available = false;
  assert(Resolve({Mode::Fixed}, caps, frame).mode == Mode::Off);
  std::puts("PASS: capability/multiplier/dynamic/HDR/Reflex/lifecycle policy and official 2.14.16 options mapping.");
  if (argc != 2) {
    std::puts("Pass the absolute official SDK bin/x64 directory for the runtime probe.");
    return 0;
  }
  Session session;  // Must outlive every proxy interface below.
  const auto logs = std::filesystem::absolute(L"tmp/witcher3classic-fg/sdk-logs");
  std::filesystem::create_directories(logs);
  if (!session.Load(std::filesystem::absolute(argv[1]), logs)) {
    std::printf("Streamline load failed: Win32=0x%08X SL=%u\n", unsigned(session.loader_error), unsigned(session.result));
    return 1;
  }
  ComPtr<IDXGIFactory4> factory;
  assert(SUCCEEDED(CreateDXGIFactory1(IID_PPV_ARGS(&factory))));
  ComPtr<IDXGIAdapter1> adapter;
  for (UINT i = 0; SUCCEEDED(factory->EnumAdapters1(i, &adapter)); ++i) {
    DXGI_ADAPTER_DESC1 desc{};
    adapter->GetDesc1(&desc);
    if (desc.VendorId == 0x10de && !(desc.Flags & DXGI_ADAPTER_FLAG_SOFTWARE)) break;
    adapter.Reset();
  }
  assert(adapter);
  ComPtr<ID3D12Device> device;
  assert(SUCCEEDED(D3D12CreateDevice(adapter.Get(), D3D_FEATURE_LEVEL_11_0, IID_PPV_ARGS(&device))));
  const bool attached = session.Attach(device.Get());
  std::printf("Streamline SDK %d.%d.%d: attached=%d result=%u, generatedMax=%u, Dynamic=%d, Reflex=%d, minimum=%u\n",
              SL_VERSION_MAJOR, SL_VERSION_MINOR, SL_VERSION_PATCH, attached, unsigned(session.result),
              session.capabilities.max_generated, session.capabilities.dynamic, session.capabilities.reflex_available, session.capabilities.min_dimension);
  session.Shutdown();
  return attached ? 0 : 1;
}
