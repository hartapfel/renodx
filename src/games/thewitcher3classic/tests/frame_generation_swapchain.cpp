/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <cassert>
#include <cstdio>
#include "../frame_generation/swapchain.hpp"
using namespace witcher3classic::frame_generation;
int wmain(int argc, wchar_t** argv) {
  std::setvbuf(stdout, nullptr, _IONBF, 0);
  if (argc != 2) return 2;
  WNDCLASSW wc{};
  wc.lpfnWndProc = DefWindowProcW;
  wc.hInstance = GetModuleHandleW(nullptr);
  wc.lpszClassName = L"ClassicFGFacadeTest";
  assert(RegisterClassW(&wc));
  HWND window = CreateWindowExW(WS_EX_NOACTIVATE, wc.lpszClassName, L"Classic DX11 facade test", WS_OVERLAPPEDWINDOW, 0, 0, 640, 360, nullptr, nullptr, wc.hInstance, nullptr);
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
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(adapter.Get(), D3D_DRIVER_TYPE_UNKNOWN, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &context)));
  ComPtr<Swapchain> facade;
  facade.Attach(new Swapchain);
  DXGI_SWAP_CHAIN_DESC desc{};
  desc.OutputWindow = window;
  desc.Windowed = TRUE;
  desc.BufferDesc.Width = 640;
  desc.BufferDesc.Height = 360;
  desc.BufferDesc.Format = DXGI_FORMAT_R10G10B10A2_UNORM;
  desc.SampleDesc.Count = 1;
  desc.BufferCount = 3;
  desc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
  desc.SwapEffect = DXGI_SWAP_EFFECT_FLIP_DISCARD;
  const auto logs = std::filesystem::absolute(L"tmp/witcher3classic-fg/facade-logs");
  std::filesystem::create_directories(logs);
  const HRESULT initialized = facade->Initialize(device.Get(), factory.Get(), desc, std::filesystem::absolute(argv[1]), logs);
  std::printf("Facade initialization: %08X (%s)\n", unsigned(initialized), facade->presenter.stage);
  assert(SUCCEEDED(initialized));
  ComPtr<ID3D11Device> identity;
  assert(SUCCEEDED(facade->GetDevice(IID_PPV_ARGS(&identity))) && identity == device);
  ComPtr<ID3D12Device> incompatible;
  assert(FAILED(facade->GetDevice(IID_PPV_ARGS(&incompatible))));
  assert(SUCCEEDED(facade->GetDesc(&desc)) && desc.BufferCount == 1 && desc.OutputWindow == window);
  ComPtr<ID3D11Texture2D> buffer;
  assert(SUCCEEDED(facade->GetBuffer(0, IID_PPV_ARGS(&buffer))));
  ComPtr<ID3D11Texture2D> invalid;
  assert(facade->GetBuffer(1, IID_PPV_ARGS(&invalid)) == DXGI_ERROR_INVALID_CALL);
  assert(facade->GetCurrentBackBufferIndex() == 0);
  assert(facade->SetFullscreenState(TRUE, nullptr) == DXGI_ERROR_UNSUPPORTED);
  assert(facade->ResizeBuffers(1, 800, 450, DXGI_FORMAT_UNKNOWN, 0) == DXGI_ERROR_INVALID_CALL);
  ComPtr<ID3D11RenderTargetView> rtv;
  assert(SUCCEEDED(device->CreateRenderTargetView(buffer.Get(), nullptr, &rtv)));
  const GUID key = {0x018b57e4, 0x1493, 0x4953, {0xad, 0xf2, 0xde, 0x6d, 0x99, 0xcc, 0x05, 0xe5}};
  const UINT value = DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020;
  UINT read = 0, size = sizeof(read);
  assert(SUCCEEDED(facade->SetPrivateData(key, sizeof(value), &value)));
  assert(SUCCEEDED(facade->GetPrivateData(key, &size, &read)) && read == value);
  ShowWindow(window, SW_SHOWNOACTIVATE);
  for (UINT i = 0; i < 12; ++i) {
    const float color[] = {.3f, .2f, .2f, 1.f};
    context->ClearRenderTargetView(rtv.Get(), color);
    assert(SUCCEEDED(facade->Present(1, 0)));
  }
  rtv.Reset();
  buffer.Reset();
  context->ClearState();
  context->Flush();
  assert(SUCCEEDED(facade->ResizeBuffers(1, 800, 450, DXGI_FORMAT_UNKNOWN, 0)));
  assert(SUCCEEDED(facade->GetBuffer(0, IID_PPV_ARGS(&buffer))));
  D3D11_TEXTURE2D_DESC resized{};
  buffer->GetDesc(&resized);
  assert(resized.Width == 800 && resized.Height == 450);
  buffer.Reset();
  identity.Reset();
  facade.Reset();
  DestroyWindow(window);
  std::puts("PASS: DX11 facade identity/backbuffer, HDR metadata storage, single HWND presentation, outstanding-reference rejection and resize.");
}
