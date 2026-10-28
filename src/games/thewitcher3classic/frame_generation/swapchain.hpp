/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <atomic>
#include <functional>
#include <mutex>
#include "./presenter.hpp"

namespace witcher3classic::frame_generation {
// DX11-facing adapter, deliberately BELOW ReShade. The game/ReShade still
// render to a DX11 backbuffer. Only Presenter owns a display chain on the HWND.
// Classic's audited path uses GetBuffer(0); this is not a general DXGI wrapper.
class Swapchain final : public IDXGISwapChain4 {
 public:
  using Capture = std::function<void(Presenter::Inputs*, Request*)>;
  Capture capture;
  std::function<void()> on_destroy;
  std::function<void(const Presenter&, HRESULT)> on_present;
  Presenter presenter;
  HRESULT Initialize(ID3D11Device* device, IDXGIFactory2* factory, const DXGI_SWAP_CHAIN_DESC& desc,
                     const std::filesystem::path& plugins, const std::filesystem::path& logs) {
    if (!device || !factory || !desc.OutputWindow || !desc.Windowed || desc.SampleDesc.Count != 1
        || desc.BufferDesc.Format != DXGI_FORMAT_R10G10B10A2_UNORM) return DXGI_ERROR_UNSUPPORTED;
    device_ = device;
    factory_ = factory;
    desc_ = desc;
    // The exposed DX11 surface is a single stable render target. The real
    // DX12 flip chain has three display buffers and its own current index.
    desc_.BufferCount = 1;
    desc_.SwapEffect = DXGI_SWAP_EFFECT_DISCARD;
    desc_.Flags &= DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH;
    HRESULT hr = CreateBuffer();
    if (FAILED(hr)) return hr;
    DXGI_SWAP_CHAIN_DESC1 native{};
    native.Width = desc_.BufferDesc.Width;
    native.Height = desc_.BufferDesc.Height;
    native.Format = desc_.BufferDesc.Format;
    native.SampleDesc = desc_.SampleDesc;
    native.Flags = desc.Flags;
    return presenter.Initialize(device, factory, desc.OutputWindow, native,
                                {native.Width, native.Height, native.Width, native.Height}, plugins, logs);
  }
  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, void** out) override {
    if (!out) return E_POINTER;
    *out = nullptr;
    if (iid == __uuidof(IUnknown) || iid == __uuidof(IDXGIObject) || iid == __uuidof(IDXGIDeviceSubObject)
        || iid == __uuidof(IDXGISwapChain) || iid == __uuidof(IDXGISwapChain1)
        || iid == __uuidof(IDXGISwapChain2) || iid == __uuidof(IDXGISwapChain3) || iid == __uuidof(IDXGISwapChain4)) {
      *out = static_cast<IDXGISwapChain4*>(this);
      AddRef();
      return S_OK;
    }
    // Never leak a native DX12 chain through an unknown interface request.
    return E_NOINTERFACE;
  }
  ULONG STDMETHODCALLTYPE AddRef() override { return ++references_; }
  ULONG STDMETHODCALLTYPE Release() override {
    const ULONG count = --references_;
    if (!count) delete this;
    return count;
  }
  HRESULT STDMETHODCALLTYPE SetPrivateData(REFGUID key, UINT size, const void* data) override { return presenter.Swapchain()->SetPrivateData(key, size, data); }
  HRESULT STDMETHODCALLTYPE SetPrivateDataInterface(REFGUID key, const IUnknown* value) override { return presenter.Swapchain()->SetPrivateDataInterface(key, value); }
  HRESULT STDMETHODCALLTYPE GetPrivateData(REFGUID key, UINT* size, void* data) override { return presenter.Swapchain()->GetPrivateData(key, size, data); }
  HRESULT STDMETHODCALLTYPE GetParent(REFIID iid, void** out) override { return factory_->QueryInterface(iid, out); }
  HRESULT STDMETHODCALLTYPE GetDevice(REFIID iid, void** out) override { return device_->QueryInterface(iid, out); }
  HRESULT STDMETHODCALLTYPE Present(UINT interval, UINT flags) override {
    std::lock_guard lock(presentation_mutex_);
    Presenter::Inputs inputs{};
    Request request{};
    if (!(flags & DXGI_PRESENT_TEST) && capture) capture(&inputs, &request);
    inputs.textures[Interop::Color] = backbuffer_.Get();
    HRESULT hr = presenter.Present(inputs, request, interval, flags);
    if (hr == DXGI_ERROR_WAS_STILL_DRAWING && !(flags & DXGI_PRESENT_DO_NOT_WAIT)) {
      if (FAILED(hr = presenter.WaitForAvailable())) return hr;
      hr = presenter.Present(inputs, request, interval, flags);
    }
    if (!(flags & DXGI_PRESENT_TEST) && on_present) on_present(presenter, hr);
    return hr;
  }
  HRESULT STDMETHODCALLTYPE GetBuffer(UINT index, REFIID iid, void** out) override {
    if (!out) return E_POINTER;
    *out = nullptr;
    return index == 0 && backbuffer_ ? backbuffer_->QueryInterface(iid, out) : DXGI_ERROR_INVALID_CALL;
  }
  HRESULT STDMETHODCALLTYPE SetFullscreenState(BOOL fullscreen, IDXGIOutput* output) override {
    // Exclusive display transitions need a separate validated lifecycle. Borderless
    // preserves the existing HWND/input ownership and is the initial supported path.
    return fullscreen ? DXGI_ERROR_UNSUPPORTED : presenter.Swapchain()->SetFullscreenState(FALSE, output);
  }
  HRESULT STDMETHODCALLTYPE GetFullscreenState(BOOL* fullscreen, IDXGIOutput** output) override { return presenter.Swapchain()->GetFullscreenState(fullscreen, output); }
  HRESULT STDMETHODCALLTYPE GetDesc(DXGI_SWAP_CHAIN_DESC* desc) override {
    if (!desc) return E_INVALIDARG;
    *desc = desc_;
    return S_OK;
  }
  HRESULT STDMETHODCALLTYPE ResizeBuffers(UINT count, UINT width, UINT height, DXGI_FORMAT format, UINT flags) override {
    std::lock_guard lock(presentation_mutex_);
    if (count > 1 || (format != DXGI_FORMAT_UNKNOWN && format != DXGI_FORMAT_R10G10B10A2_UNORM)
        || (flags & DXGI_SWAP_CHAIN_FLAG_FRAME_LATENCY_WAITABLE_OBJECT)) return DXGI_ERROR_UNSUPPORTED;
    if (backbuffer_) {
      backbuffer_->AddRef();
      if (backbuffer_->Release() != 1) return DXGI_ERROR_INVALID_CALL;
    }
    if (!width || !height) {
      RECT rect{};
      if (!GetClientRect(desc_.OutputWindow, &rect)) return HRESULT_FROM_WIN32(GetLastError());
      if (!width) width = UINT(rect.right);
      if (!height) height = UINT(rect.bottom);
    }
    const HRESULT hr = presenter.Resize(width, height, width, height, flags);
    if (FAILED(hr)) return hr;
    backbuffer_.Reset();
    desc_.BufferDesc.Width = width;
    desc_.BufferDesc.Height = height;
    return CreateBuffer();
  }
  HRESULT STDMETHODCALLTYPE ResizeTarget(const DXGI_MODE_DESC* mode) override { return presenter.Swapchain()->ResizeTarget(mode); }
  HRESULT STDMETHODCALLTYPE GetContainingOutput(IDXGIOutput** output) override { return presenter.Swapchain()->GetContainingOutput(output); }
  HRESULT STDMETHODCALLTYPE GetFrameStatistics(DXGI_FRAME_STATISTICS* stats) override { return presenter.Swapchain()->GetFrameStatistics(stats); }
  HRESULT STDMETHODCALLTYPE GetLastPresentCount(UINT* count) override { return presenter.Swapchain()->GetLastPresentCount(count); }
  HRESULT STDMETHODCALLTYPE GetDesc1(DXGI_SWAP_CHAIN_DESC1* out) override {
    if (!out) return E_INVALIDARG;
    *out = {desc_.BufferDesc.Width, desc_.BufferDesc.Height, desc_.BufferDesc.Format, FALSE, desc_.SampleDesc,
            desc_.BufferUsage, 1, DXGI_SCALING_STRETCH, DXGI_SWAP_EFFECT_DISCARD, DXGI_ALPHA_MODE_IGNORE, desc_.Flags};
    return S_OK;
  }
  HRESULT STDMETHODCALLTYPE GetFullscreenDesc(DXGI_SWAP_CHAIN_FULLSCREEN_DESC* desc) override { return presenter.Swapchain()->GetFullscreenDesc(desc); }
  HRESULT STDMETHODCALLTYPE GetHwnd(HWND* window) override {
    if (!window) return E_INVALIDARG;
    *window = desc_.OutputWindow;
    return S_OK;
  }
  HRESULT STDMETHODCALLTYPE GetCoreWindow(REFIID, void** out) override {
    if (out) *out = nullptr;
    return DXGI_ERROR_UNSUPPORTED;
  }
  HRESULT STDMETHODCALLTYPE Present1(UINT interval, UINT flags, const DXGI_PRESENT_PARAMETERS* parameters) override {
    if (parameters && (parameters->DirtyRectsCount || parameters->pScrollRect || parameters->pScrollOffset)) return DXGI_ERROR_UNSUPPORTED;
    return Present(interval, flags);
  }
  BOOL STDMETHODCALLTYPE IsTemporaryMonoSupported() override { return FALSE; }
  HRESULT STDMETHODCALLTYPE GetRestrictToOutput(IDXGIOutput** output) override { return presenter.Swapchain()->GetRestrictToOutput(output); }
  HRESULT STDMETHODCALLTYPE SetBackgroundColor(const DXGI_RGBA* color) override { return presenter.Swapchain()->SetBackgroundColor(color); }
  HRESULT STDMETHODCALLTYPE GetBackgroundColor(DXGI_RGBA* color) override { return presenter.Swapchain()->GetBackgroundColor(color); }
  HRESULT STDMETHODCALLTYPE SetRotation(DXGI_MODE_ROTATION rotation) override { return presenter.Swapchain()->SetRotation(rotation); }
  HRESULT STDMETHODCALLTYPE GetRotation(DXGI_MODE_ROTATION* rotation) override { return presenter.Swapchain()->GetRotation(rotation); }
  HRESULT STDMETHODCALLTYPE SetSourceSize(UINT width, UINT height) override { return width == desc_.BufferDesc.Width && height == desc_.BufferDesc.Height ? S_OK : DXGI_ERROR_UNSUPPORTED; }
  HRESULT STDMETHODCALLTYPE GetSourceSize(UINT* width, UINT* height) override {
    if (!width || !height) return E_INVALIDARG;
    *width = desc_.BufferDesc.Width;
    *height = desc_.BufferDesc.Height;
    return S_OK;
  }
  HRESULT STDMETHODCALLTYPE SetMaximumFrameLatency(UINT latency) override { return presenter.Swapchain()->SetMaximumFrameLatency(latency); }
  HRESULT STDMETHODCALLTYPE GetMaximumFrameLatency(UINT* latency) override { return presenter.Swapchain()->GetMaximumFrameLatency(latency); }
  HANDLE STDMETHODCALLTYPE GetFrameLatencyWaitableObject() override { return nullptr; }
  HRESULT STDMETHODCALLTYPE SetMatrixTransform(const DXGI_MATRIX_3X2_F*) override { return DXGI_ERROR_UNSUPPORTED; }
  HRESULT STDMETHODCALLTYPE GetMatrixTransform(DXGI_MATRIX_3X2_F* matrix) override {
    if (!matrix) return E_INVALIDARG;
    *matrix = {1, 0, 0, 1, 0, 0};
    return S_OK;
  }
  UINT STDMETHODCALLTYPE GetCurrentBackBufferIndex() override { return 0; }
  HRESULT STDMETHODCALLTYPE CheckColorSpaceSupport(DXGI_COLOR_SPACE_TYPE space, UINT* support) override {
    if (!support) return E_INVALIDARG;
    *support = 0;
    return space == DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020 ? presenter.Swapchain()->CheckColorSpaceSupport(space, support) : S_OK;
  }
  HRESULT STDMETHODCALLTYPE SetColorSpace1(DXGI_COLOR_SPACE_TYPE space) override { return presenter.SetColorSpace(space); }
  HRESULT STDMETHODCALLTYPE ResizeBuffers1(UINT count, UINT width, UINT height, DXGI_FORMAT format, UINT flags, const UINT* masks, IUnknown* const* queues) override {
    return masks || queues ? DXGI_ERROR_UNSUPPORTED : ResizeBuffers(count, width, height, format, flags);
  }
  HRESULT STDMETHODCALLTYPE SetHDRMetaData(DXGI_HDR_METADATA_TYPE type, UINT size, void* data) override { return presenter.Swapchain()->SetHDRMetaData(type, size, data); }

 private:
  std::mutex presentation_mutex_;
  ~Swapchain() {
    if (on_destroy) on_destroy();
    presenter.Close();
  }
  HRESULT CreateBuffer() {
    D3D11_TEXTURE2D_DESC desc{};
    desc.Width = desc_.BufferDesc.Width;
    desc.Height = desc_.BufferDesc.Height;
    desc.MipLevels = desc.ArraySize = desc.SampleDesc.Count = 1;
    desc.Format = DXGI_FORMAT_R10G10B10A2_UNORM;
    desc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
    return device_->CreateTexture2D(&desc, nullptr, &backbuffer_);
  }
  std::atomic<ULONG> references_{1};
  ComPtr<ID3D11Device> device_;
  ComPtr<IDXGIFactory2> factory_;
  ComPtr<ID3D11Texture2D> backbuffer_;
  DXGI_SWAP_CHAIN_DESC desc_{};
};
}  // namespace witcher3classic::frame_generation
