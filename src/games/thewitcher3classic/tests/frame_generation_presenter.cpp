/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
// Standalone real DX11 -> DX12 -> Streamline HDR10 presentation smoke test.
// Does not hook the game. Run with the absolute signed SDK bin/x64 directory.
#include <d3d12sdklayers.h>
#include <DirectXMath.h>
#include <cassert>
#include <cstdio>
#include <string_view>
#include "../frame_generation/swapchain.hpp"

using namespace witcher3classic::frame_generation;
int wmain(int argc, wchar_t** argv) {
  std::setvbuf(stdout, nullptr, _IONBF, 0);
  if (argc != 2 && !(argc == 3 && std::wstring_view(argv[2]) == L"--toggle")) return 2;
  const bool toggle = argc == 3;
  const HWND previous_window = GetForegroundWindow();
  ComPtr<ID3D12Debug> debug;
  if (SUCCEEDED(D3D12GetDebugInterface(IID_PPV_ARGS(&debug))))
    debug->EnableDebugLayer();
  else
    std::puts("D3D12 debug layer is unavailable; this run checks hardware behavior, not debug-layer validation.");
  WNDCLASSW wc{};
  wc.lpfnWndProc = DefWindowProcW;
  wc.hInstance = GetModuleHandleW(nullptr);
  wc.lpszClassName = L"ClassicFGPresenterTest";
  assert(RegisterClassW(&wc));
  HWND window = CreateWindowExW(0, wc.lpszClassName, L"Classic FG HDR10 transport test",
                                WS_OVERLAPPEDWINDOW, 0, 0, 640, 360, nullptr, nullptr, wc.hInstance, nullptr);
  assert(window);
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
  ComPtr<ID3D11Device> d11;
  ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(adapter.Get(), D3D_DRIVER_TYPE_UNKNOWN, nullptr, 0, nullptr, 0,
                                     D3D11_SDK_VERSION, &d11, nullptr, &context)));
  const auto logs = std::filesystem::absolute(L"tmp/witcher3classic-fg/presenter-logs");
  std::filesystem::create_directories(logs);
  Presenter presenter;
  DXGI_SWAP_CHAIN_DESC1 desc{};
  desc.Width = 640;
  desc.Height = 360;
  desc.Format = DXGI_FORMAT_R10G10B10A2_UNORM;
  desc.SampleDesc.Count = 1;
  HRESULT hr = presenter.Initialize(d11.Get(), factory.Get(), window, desc, {640, 360, 640, 360},
                                    std::filesystem::absolute(argv[1]), logs);
  std::printf("Initialize: 0x%08X SL=%u stage=%s\n", unsigned(hr), unsigned(presenter.Streamline().result), presenter.stage);
  if (FAILED(hr)) return 1;
  ShowWindow(window, SW_SHOWNOACTIVATE);
  assert(presenter.SetColorSpace(DXGI_COLOR_SPACE_RGB_FULL_G10_NONE_P709) == DXGI_ERROR_UNSUPPORTED);
  ComPtr<ID3D11Texture2D> source;
  ComPtr<ID3D11RenderTargetView> rtv;
  D3D11_TEXTURE2D_DESC texture{};
  texture.Width = 640;
  texture.Height = 360;
  texture.MipLevels = texture.ArraySize = texture.SampleDesc.Count = 1;
  texture.Format = DXGI_FORMAT_R10G10B10A2_UNORM;
  texture.BindFlags = D3D11_BIND_RENDER_TARGET;
  assert(SUCCEEDED(d11->CreateTexture2D(&texture, nullptr, &source)));
  assert(SUCCEEDED(d11->CreateRenderTargetView(source.Get(), nullptr, &rtv)));
  Presenter::Inputs inputs{};
  inputs.textures[Interop::Color] = source.Get();
  for (UINT i = 0; i < 24; ++i) {
    // PQ code 0.4 is a dim patch; no bright SDR values reinterpreted as HDR.
    const float clear[] = {0.4f * float(i & 1), 0.2f, 0.2f, 1.f};
    context->ClearRenderTargetView(rtv.Get(), clear);
    do {
      hr = presenter.Present(inputs, {Mode::Fixed, 2}, 1, 0);
      if (hr == DXGI_ERROR_WAS_STILL_DRAWING) Sleep(1);
    } while (hr == DXGI_ERROR_WAS_STILL_DRAWING);
    assert(SUCCEEDED(hr));
    assert(presenter.CurrentDecision().mode == Mode::Off);  // Actual Reflex/camera/HUD missing.
    MSG message;
    while (PeekMessageW(&message, nullptr, 0, 0, PM_REMOVE)) DispatchMessageW(&message);
  }
  assert(SUCCEEDED(presenter.Resize(640, 360, 320, 180, 0)));
  assert(SUCCEEDED(presenter.Present(inputs, {}, 1, 0)));
  assert(SUCCEEDED(presenter.Resize(640, 360, 640, 360, 0)));
  // A self-contained synthetic renderer supplies real simulation/render
  // boundaries for THIS test, not guessed timing for the Witcher executable.
  std::array<ComPtr<ID3D11Texture2D>, 5> textures;
  std::array<ComPtr<ID3D11RenderTargetView>, 5> views;
  constexpr DXGI_FORMAT formats[] = {DXGI_FORMAT_R10G10B10A2_UNORM, DXGI_FORMAT_R10G10B10A2_UNORM,
                                     DXGI_FORMAT_R32_FLOAT, DXGI_FORMAT_R16G16_FLOAT, DXGI_FORMAT_R8_UNORM};
  for (size_t i = 0; i < textures.size(); ++i) {
    texture.Format = formats[i];
    assert(SUCCEEDED(d11->CreateTexture2D(&texture, nullptr, &textures[i])));
    assert(SUCCEEDED(d11->CreateRenderTargetView(textures[i].Get(), nullptr, &views[i])));
    inputs.textures[i] = textures[i].Get();
  }
  sl::Constants camera{};
  DirectX::XMFLOAT4X4 matrix;
  const auto projection = DirectX::XMMatrixPerspectiveFovLH(1.0f, 640.f / 360.f, 1000.f, 0.1f);
  DirectX::XMStoreFloat4x4(&matrix, projection);
  std::memcpy(&camera.cameraViewToClip, &matrix, sizeof(matrix));
  DirectX::XMStoreFloat4x4(&matrix, DirectX::XMMatrixInverse(nullptr, projection));
  std::memcpy(&camera.clipToCameraView, &matrix, sizeof(matrix));
  DirectX::XMStoreFloat4x4(&matrix, DirectX::XMMatrixIdentity());
  std::memcpy(&camera.clipToPrevClip, &matrix, sizeof(matrix));
  camera.prevClipToClip = camera.clipToPrevClip;
  camera.jitterOffset = {0, 0};
  camera.mvecScale = {1, 1};
  camera.cameraPinholeOffset = {0, 0};
  camera.cameraPos = {0, 0, 0};
  camera.cameraUp = {0, 1, 0};
  camera.cameraRight = {1, 0, 0};
  camera.cameraFwd = {0, 0, 1};
  camera.cameraNear = 0.1f;
  camera.cameraFar = 1000.f;
  camera.cameraFOV = 1.f;
  camera.cameraAspectRatio = 640.f / 360.f;
  camera.depthInverted = sl::Boolean::eTrue;
  camera.cameraMotionIncluded = sl::Boolean::eTrue;
  camera.motionVectors3D = sl::Boolean::eFalse;
  inputs.camera = &camera;
  inputs.readiness = {true, true, true, true, false, true, true, true, 640, 360};
  ComPtr<ID3D11Texture2D> lens;
  ComPtr<ID3D11RenderTargetView> lens_view;
  const D3D11_TEXTURE2D_DESC lens_desc{320,180,1,1,DXGI_FORMAT_R16G16B16A16_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_RENDER_TARGET};
  assert(SUCCEEDED(d11->CreateTexture2D(&lens_desc,nullptr,&lens)));
  assert(SUCCEEDED(d11->CreateRenderTargetView(lens.Get(),nullptr,&lens_view)));
  const float lens_offsets[] = {.01f, -.01f, -.01f, .01f};
  context->ClearRenderTargetView(lens_view.Get(),lens_offsets);
  inputs.distortion = lens.Get();
  inputs.distortion_version = 1;
  auto& session = presenter.Streamline();
  sl::ReflexOptions reflex{};
  reflex.mode = sl::ReflexMode::eLowLatency;
  reflex.frameLimitUs = 16667;
  assert(session.Accept(session.reflex_options(reflex)));
  const DWORD foreground_thread = GetWindowThreadProcessId(GetForegroundWindow(), nullptr);
  const bool attached = foreground_thread != GetCurrentThreadId() && AttachThreadInput(GetCurrentThreadId(), foreground_thread, TRUE);
  ShowWindow(window, SW_SHOW);
  SetForegroundWindow(window);
  SetFocus(window);
  if (attached) AttachThreadInput(GetCurrentThreadId(), foreground_thread, FALSE);
  std::printf("Focus: %d\n", GetForegroundWindow() == window);
  uint32_t total_presented = 0;
  const auto* initial_swapchain = presenter.Swapchain();
  const std::vector<std::pair<Mode, uint32_t>> modes = toggle
      ? std::vector<std::pair<Mode, uint32_t>>{{Mode::Off,2}, {Mode::Fixed,2}, {Mode::Off,2}, {Mode::Fixed,3}}
      : std::vector<std::pair<Mode, uint32_t>>{{Mode::Fixed,2}, {Mode::Fixed,4}, {Mode::Fixed,6}, {Mode::Auto,2}, {Mode::Dynamic,2}};
  const uint32_t frame_count = toggle ? 60 : 90;
  for (const auto [test_mode, factor] : modes) {
    if (factor - 1 > session.capabilities.max_generated) continue;
    if (test_mode == Mode::Dynamic && !session.capabilities.dynamic) continue;
    uint32_t presented = 0;
    uint32_t without_alpha_presented = 0;
    for (uint32_t i = 0; i < frame_count; ++i) {
      // Standard generation must continue through additive UI frames, while
      // recomposition is used only when the complete alpha mask returns.
      if (toggle) inputs.textures[Interop::UIAlpha] = i >= 10 && i < 40 ? nullptr : textures[Interop::UIAlpha].Get();
      // Exercise cached field reuse, a settings update, and disabling the tag.
      inputs.distortion = i < 75 ? lens.Get() : nullptr;
      if (i == 30) {
        const float offsets[] = {-.02f, .02f, .02f, -.02f};
        context->ClearRenderTargetView(lens_view.Get(), offsets);
        ++inputs.distortion_version;
      }
      MSG message;
      while (PeekMessageW(&message, nullptr, 0, 0, PM_REMOVE)) DispatchMessageW(&message);
      assert(session.Accept(session.new_frame(inputs.token, nullptr)));
      assert(session.Accept(session.sleep(*inputs.token)));
      assert(session.Accept(session.marker(sl::PCLMarker::eSimulationStart, *inputs.token)));
      camera.reset = i == 0 ? sl::Boolean::eTrue : sl::Boolean::eFalse;
      assert(session.Accept(session.marker(sl::PCLMarker::eSimulationEnd, *inputs.token)));
      assert(session.Accept(session.marker(sl::PCLMarker::eRenderSubmitStart, *inputs.token)));
      if (test_mode == Mode::Fixed && factor == 4 && i == 45) {
        // Change SR input resolution while retaining the output swapchain.
        for (size_t index : {size_t(Interop::Depth), size_t(Interop::Motion)}) {
          views[index].Reset();
          textures[index].Reset();
          auto resized = texture;
          resized.Width = 320;
          resized.Height = 180;
          resized.Format = formats[index];
          assert(SUCCEEDED(d11->CreateTexture2D(&resized, nullptr, &textures[index])));
          assert(SUCCEEDED(d11->CreateRenderTargetView(textures[index].Get(), nullptr, &views[index])));
          inputs.textures[index] = textures[index].Get();
        }
        camera.reset = sl::Boolean::eTrue;
      }
      const float color[] = {0.25f, 0.2f, 0.2f, 1.f}, zero[] = {0, 0, 0, 0}, depth[] = {0.01f, 0, 0, 0};
      context->ClearRenderTargetView(views[0].Get(), color);
      context->ClearRenderTargetView(views[1].Get(), color);
      context->ClearRenderTargetView(views[2].Get(), depth);
      context->ClearRenderTargetView(views[3].Get(), zero);
      context->ClearRenderTargetView(views[4].Get(), zero);
      assert(session.Accept(session.marker(sl::PCLMarker::eRenderSubmitEnd, *inputs.token)));
      const Request request{test_mode, factor, 0, toggle || factor == 6};
      hr = presenter.Present(inputs, request, 0, 0);
      if (hr == DXGI_ERROR_WAS_STILL_DRAWING) {
        assert(SUCCEEDED(presenter.WaitForAvailable()));
        hr = presenter.Present(inputs, request, 0, 0);
      }
      if (FAILED(hr) || presenter.State().status != sl::DLSSGStatus::eOk) {
        std::printf("FG frame %u: hr=%08X SL=%u status=%u decision=%s\n", i, unsigned(hr), unsigned(session.result), unsigned(presenter.State().status), presenter.CurrentDecision().reason);
        return 1;
      }
      assert(presenter.Swapchain() == initial_swapchain);
      assert(presenter.CurrentDecision().mode == test_mode);
      if (toggle && test_mode != Mode::Off)
        assert(presenter.CurrentDecision().recompose_ui == (inputs.textures[Interop::UIAlpha] != nullptr));
      presented += presenter.State().numFramesActuallyPresented;
      if (toggle && !inputs.textures[Interop::UIAlpha]) without_alpha_presented += presenter.State().numFramesActuallyPresented;
    }
    std::printf("Synthetic mode %u, %ux%s: %u presents from %u rendered frames\n", unsigned(test_mode), factor, factor == 6 ? " + UI recomposition" : "", presented, frame_count);
    total_presented += presented;
    assert(presented > (test_mode == Mode::Fixed ? frame_count : 0u));
    if (toggle && test_mode == Mode::Fixed) {
      std::printf("HUD-less fallback: %u presents from 30 frames without UI alpha\n", without_alpha_presented);
      assert(without_alpha_presented > 30);
    }
  }
  ComPtr<ID3D12Device> checked_device;
  ComPtr<ID3D12InfoQueue> messages;
  if (SUCCEEDED(presenter.Swapchain()->GetDevice(IID_PPV_ARGS(&checked_device))) && SUCCEEDED(checked_device.As(&messages))) {
    uint64_t errors = 0;
    for (UINT64 i = 0; i < messages->GetNumStoredMessages(); ++i) {
      SIZE_T size = 0;
      messages->GetMessage(i, nullptr, &size);
      std::vector<uint8_t> storage(size);
      auto* message = reinterpret_cast<D3D12_MESSAGE*>(storage.data());
      if (SUCCEEDED(messages->GetMessage(i, message, &size)) && message->Severity <= D3D12_MESSAGE_SEVERITY_ERROR) {
        std::printf("D3D12 validation: %s\n", message->pDescription);
        ++errors;
      }
    }
    std::printf("D3D12 validation errors: %llu\n", static_cast<unsigned long long>(errors));
    assert(!errors);
  }
  messages.Reset();
  checked_device.Reset();
  presenter.Close();
  DestroyWindow(window);
  SetForegroundWindow(previous_window);
  assert(total_presented > 90);
  std::puts("PASS: same-adapter DX11/DX12 HDR10 presents, safe FG suspension, scRGB rejection, render-resolution resize and shutdown.");
}
