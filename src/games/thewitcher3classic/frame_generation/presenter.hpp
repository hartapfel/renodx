/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <dxgi1_6.h>
#include <memory>
#include "./interop.hpp"
#include "./streamline.hpp"
#include "./diagnostics.hpp"

#pragma comment(lib, "d3d12.lib")

namespace witcher3classic::frame_generation {

// Only the presenting thread calls this object. The DX11 renderer supplies
// already encoded PQ color and actual simulation-frame metadata. This class
// never fabricates camera constants, HUD alpha or Reflex simulation markers.
class Presenter {
 public:
  struct Inputs {
    std::array<ID3D11Texture2D*, Interop::InputCount> textures{};
    sl::FrameToken* token = nullptr;
    const sl::Constants* camera = nullptr;
    Frame readiness{};
    ID3D11Texture2D* distortion = nullptr;
    uint64_t distortion_version = 0;
  };

  Presenter() = default;
  Presenter(const Presenter&) = delete;
  Presenter& operator=(const Presenter&) = delete;
  ~Presenter() { Close(); }

  // One display swapchain owns the game's HWND. The factory/device supplied
  // here are native interfaces, below ReShade's DX11 swapchain wrapper.
  HRESULT Initialize(ID3D11Device* device11, IDXGIFactory2* factory, HWND window,
                     const DXGI_SWAP_CHAIN_DESC1& requested, const Interop::Layout& layout,
                     const std::filesystem::path& plugins, const std::filesystem::path& logs) {
    if (device11_ || !device11 || !factory || !window || requested.SampleDesc.Count != 1
        || requested.Format != DXGI_FORMAT_R10G10B10A2_UNORM
        || layout.output_width != requested.Width || layout.output_height != requested.Height) return E_INVALIDARG;
    device11_ = device11;
    stage = "Streamline load";
    if (!session_.Load(plugins, logs)) return E_FAIL;
    ComPtr<IDXGIDevice> dxgi;
    ComPtr<IDXGIAdapter> adapter;
    HRESULT hr = device11->QueryInterface(IID_PPV_ARGS(&dxgi));
    if (FAILED(hr) || FAILED(hr = dxgi->GetAdapter(&adapter))) return hr;
    if (FAILED(hr = D3D12CreateDevice(adapter.Get(), D3D_FEATURE_LEVEL_12_0, IID_PPV_ARGS(&device12_)))) return hr;
    if (!session_.Attach(device12_.Get())) return DXGI_ERROR_UNSUPPORTED;
    stage = "Streamline proxies";

    // Upgrade owned references. slUpgradeInterface transfers the caller's
    // reference to its proxy; never attach a borrowed interface here.
    device_proxy_ = device12_;
    factory_proxy_ = factory;
    if (!session_.Accept(session_.upgrade(reinterpret_cast<void**>(device_proxy_.GetAddressOf())))
        || !session_.Accept(session_.upgrade(reinterpret_cast<void**>(factory_proxy_.GetAddressOf())))) return E_FAIL;
    const D3D12_COMMAND_QUEUE_DESC queue_desc{D3D12_COMMAND_LIST_TYPE_DIRECT};
    stage = "DX12 queue";
    if (FAILED(hr = device_proxy_->CreateCommandQueue(&queue_desc, IID_PPV_ARGS(&queue_)))) return hr;

    auto desc = requested;
    desc.BufferCount = 3;
    desc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    desc.SwapEffect = DXGI_SWAP_EFFECT_FLIP_DISCARD;
    desc.Scaling = DXGI_SCALING_STRETCH;
    desc.AlphaMode = DXGI_ALPHA_MODE_IGNORE;
    // The facade does not expose a native latency handle with DX11 semantics.
    desc.Flags &= DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING | DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH;
    ComPtr<IDXGISwapChain1> created;
    stage = "HDR10 swapchain";
    if (FAILED(hr = factory_proxy_->CreateSwapChainForHwnd(queue_.Get(), window, &desc, nullptr, nullptr, &created))
        || FAILED(hr = created.As(&swapchain_))) return hr;
    stage = "HDR10 color space";
    if (FAILED(hr = swapchain_->SetColorSpace1(DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020))) return hr;
    layout_ = layout;
    if (FAILED(hr = CreateFrames())) return hr;
    ready_ = true;
    stage = "Ready";
    return S_OK;
  }

  HRESULT Present(const Inputs& inputs, const Request& request, UINT interval, UINT flags) {
    if (!ready_) return DXGI_ERROR_INVALID_CALL;
    if (flags & DXGI_PRESENT_TEST) return swapchain_->Present(interval, flags);
    if (!inputs.textures[Interop::Color]) return E_INVALIDARG;
    Frame frame = inputs.readiness;
    frame.presenter_ready = true;
    frame.hdr10 = color_space_ == DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020;
    frame.width = layout_.output_width;
    frame.height = layout_.output_height;
    frame.inputs_valid &= inputs.camera && inputs.token;
    frame.runtime_ok &= runtime_ok_;
    decision_ = Resolve(request, session_.capabilities, frame);
    // UI recomposition requires BOTH HUD-less color and complete UI alpha.
    // Standard FG can use the current HUD-less scene without an alpha tag.
    decision_.recompose_ui &= inputs.textures[Interop::UIAlpha] != nullptr;
    if (decision_.mode != Mode::Off && inputs.textures[Interop::Depth]) {
      D3D11_TEXTURE2D_DESC depth{};
      inputs.textures[Interop::Depth]->GetDesc(&depth);
      if (depth.Width != layout_.render_width || depth.Height != layout_.render_height) {
        const HRESULT changed = ResizeInputs(depth.Width, depth.Height);
        if (FAILED(changed)) return changed;
      }
    }
    if (decision_.mode != Mode::Off && inputs.distortion) {
      const HRESULT updated = transport_->SetDistortion(inputs.distortion, inputs.distortion_version);
      if (FAILED(updated)) return updated;
    }
    auto* slot = transport_->TryAcquire();
    if (!slot) return DXGI_ERROR_WAS_STILL_DRAWING;
    sl::FrameToken* token = inputs.token;
    if (!token && !session_.Accept(session_.new_frame(token, nullptr))) {
      transport_->Cancel(slot);
      return E_FAIL;
    }
    auto options = Session::Options(decision_);
    options.numBackBuffers = 3;
    options.colorWidth = layout_.output_width;
    options.colorHeight = layout_.output_height;
    options.mvecDepthWidth = layout_.render_width;
    options.mvecDepthHeight = layout_.render_height;
    options.colorBufferFormat = options.hudLessBufferFormat = DXGI_FORMAT_R10G10B10A2_UNORM;
    options.depthBufferFormat = DXGI_FORMAT_R32_FLOAT;
    options.mvecBufferFormat = DXGI_FORMAT_R16G16_FLOAT;
    if (!options_valid_ || applied_.mode != decision_.mode || applied_.generated != decision_.generated
        || applied_.target_fps != decision_.target_fps || applied_.recompose_ui != decision_.recompose_ui) {
      if (!session_.Accept(session_.options(session_.viewport, options))) {
        transport_->Cancel(slot);
        return E_FAIL;
      }
      applied_ = decision_;
      options_valid_ = true;
    }
    const bool generate = decision_.mode != Mode::Off;
    if (generate && diagnostics::remaining.load()) {
      ComPtr<ID3D11DeviceContext> context;
      ComPtr<ID3D11DeviceContext1> context1;
      device11_->GetImmediateContext(&context);
      if (SUCCEEDED(context.As(&context1))) {
        std::array<ID3D11Texture2D*, Interop::InputCount + 1> diagnostic_textures{};
        std::copy(inputs.textures.begin(), inputs.textures.end(), diagnostic_textures.begin());
        diagnostic_textures.back() = inputs.distortion;
        diagnostics::Capture(context1.Get(), diagnostic_textures, inputs.camera, sizeof(*inputs.camera));
      }
    }

    // Never reset an allocator or write an input that FG is still reading.
    // The facade may retry after waiting for the oldest retirement event. A
    // DO_NOT_WAIT caller receives the usual DXGI result without a CPU stall.
    HRESULT hr = transport_->Publish(slot, inputs.textures, !generate);
    if (FAILED(hr)) {
      transport_->Cancel(slot);
      return hr;
    }
    if (FAILED(hr = transport_->BeginRead(slot))) return hr;
    auto& work = commands_[transport_->Index(slot)];
    if (FAILED(hr = work.allocator->Reset()) || FAILED(hr = work.list->Reset(work.allocator.Get(), nullptr))) {
      transport_->EndRead(slot, nullptr, 0);
      return hr;
    }
    // Mandatory SL proxy call: its index can differ from the native chain's.
    const UINT index = swapchain_->GetCurrentBackBufferIndex();
    ComPtr<ID3D12Resource> backbuffer;
    if (FAILED(hr = swapchain_->GetBuffer(index, IID_PPV_ARGS(&backbuffer)))) {
      work.list->Close();
      transport_->EndRead(slot, nullptr, 0);
      return hr;
    }
    D3D12_RESOURCE_BARRIER barrier{};
    barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    barrier.Transition = {backbuffer.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
                          D3D12_RESOURCE_STATE_PRESENT, D3D12_RESOURCE_STATE_COPY_DEST};
    work.list->ResourceBarrier(1, &barrier);
    // Shared simultaneous-access source promotes from COMMON for the copy and
    // decays at ExecuteCommandLists completion (Microsoft resource barriers).
    work.list->CopyResource(backbuffer.Get(), slot->textures[Interop::Color].d12.Get());
    std::swap(barrier.Transition.StateBefore, barrier.Transition.StateAfter);
    work.list->ResourceBarrier(1, &barrier);

    // Even an Off frame clears the frame tags. This prevents an earlier valid
    // gameplay frame from being reused after a menu, resize or missing capture.
    const sl::Extent full{0, 0, layout_.output_width, layout_.output_height};
    const sl::Extent render{0, 0, layout_.render_width, layout_.render_height};
    sl::Resource depth{sl::ResourceType::eTex2d, slot->textures[Interop::Depth].d12.Get(), nullptr, nullptr, D3D12_RESOURCE_STATE_COMMON};
    sl::Resource motion{sl::ResourceType::eTex2d, slot->textures[Interop::Motion].d12.Get(), nullptr, nullptr, D3D12_RESOURCE_STATE_COMMON};
    sl::Resource hudless{sl::ResourceType::eTex2d, slot->textures[Interop::Hudless].d12.Get(), nullptr, nullptr, D3D12_RESOURCE_STATE_COMMON};
    sl::Resource alpha{sl::ResourceType::eTex2d, slot->textures[Interop::UIAlpha].d12.Get(), nullptr, nullptr, D3D12_RESOURCE_STATE_COMMON};
    sl::Resource distortion{sl::ResourceType::eTex2d, transport_->Distortion(), nullptr, nullptr, D3D12_RESOURCE_STATE_COMMON};
    const sl::Extent lens{0, 0, (layout_.output_width+1)/2, (layout_.output_height+1)/2};
    const sl::ResourceTag tags[] = {
        {generate ? &depth : nullptr, sl::kBufferTypeDepth, sl::ResourceLifecycle::eValidUntilPresent, &render},
        {generate ? &motion : nullptr, sl::kBufferTypeMotionVectors, sl::ResourceLifecycle::eValidUntilPresent, &render},
        {generate ? &hudless : nullptr, sl::kBufferTypeHUDLessColor, sl::ResourceLifecycle::eValidUntilPresent, &full},
        {generate && inputs.textures[Interop::UIAlpha] ? &alpha : nullptr, sl::kBufferTypeUIAlpha, sl::ResourceLifecycle::eValidUntilPresent, &full},
        {generate && inputs.distortion ? &distortion : nullptr, sl::kBufferTypeBidirectionalDistortionField, sl::ResourceLifecycle::eValidUntilPresent, &lens},
        {nullptr, sl::kBufferTypeBackbuffer, sl::ResourceLifecycle::eValidUntilPresent, &full}};
    if ((generate && !session_.Accept(session_.constants(*inputs.camera, *token, session_.viewport)))
        || !session_.Accept(session_.tags(*token, session_.viewport, tags, UINT(std::size(tags)), work.list.Get()))) {
      work.list->Close();
      transport_->EndRead(slot, nullptr, 0);
      return E_FAIL;
    }
    if (FAILED(hr = work.list->Close())) {
      transport_->EndRead(slot, nullptr, 0);
      return hr;
    }
    ID3D12CommandList* lists[] = {work.list.Get()};
    queue_->ExecuteCommandLists(1, lists);
    if (inputs.readiness.reflex_active) session_.marker(sl::PCLMarker::ePresentStart, *token);
    hr = swapchain_->Present(interval, flags);
    if (inputs.readiness.reflex_active) session_.marker(sl::PCLMarker::ePresentEnd, *token);
    // Query on this presenting thread, AFTER Present, including failed/occluded
    // Presents. DX11 is a different queue: a copy-completion fence is not enough.
    if (!session_.Accept(session_.state(session_.viewport, state_, nullptr))) {
      ready_ = false;
      pending_ = slot;  // Close shuts SL down before releasing these inputs.
      return E_FAIL;
    }
    runtime_ok_ = state_.status == sl::DLSSGStatus::eOk;
    const HRESULT retired = transport_->EndRead(slot,
                                                static_cast<ID3D12Fence*>(state_.inputsProcessingCompletionFence),
                                                state_.lastPresentInputsProcessingCompletionFenceValue);
    if (FAILED(retired)) {
      ready_ = false;
      pending_ = slot;
      return retired;
    }
    return hr;
  }

  HRESULT Resize(UINT width, UINT height, UINT render_width, UINT render_height, UINT flags) {
    if (!ready_ || !width || !height || !render_width || !render_height) return E_INVALIDARG;
    const auto off = Session::Options({});
    options_valid_ = false;
    if (!session_.Accept(session_.options(session_.viewport, off))) return E_FAIL;
    HRESULT hr = transport_->Drain();
    if (FAILED(hr)) return hr;
    if (!session_.Accept(session_.free_resources(sl::kFeatureDLSS_G, session_.viewport))) return E_FAIL;
    transport_.reset();
    for (auto& work : commands_) {
      work.list.Reset();
      work.allocator.Reset();
    }
    ready_ = false;
    // No cached references to display buffers survive the resize.
    if (FAILED(hr = swapchain_->ResizeBuffers(3, width, height, DXGI_FORMAT_R10G10B10A2_UNORM,
                                              flags & (DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING | DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH)))) return hr;
    if (FAILED(hr = swapchain_->SetColorSpace1(DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020))) return hr;
    layout_ = {width, height, render_width, render_height};
    if (FAILED(hr = CreateFrames())) return hr;
    runtime_ok_ = ready_ = true;
    return S_OK;
  }

  void Close() {
    ready_ = false;
    if (session_.initialized) {
      if (session_.options) session_.options(session_.viewport, Session::Options({}));
      if (transport_ && !pending_) transport_->Drain();
      // SL must finish its workers while the queues/devices are still alive.
      session_.Shutdown();
      if (pending_) {
        transport_->EndRead(pending_, nullptr, 0);
        pending_ = nullptr;
      }
    }
    transport_.reset();
    for (auto& work : commands_) {
      work.list.Reset();
      work.allocator.Reset();
    }
    swapchain_.Reset();
    factory_proxy_.Reset();
    queue_.Reset();
    device_proxy_.Reset();
    device12_.Reset();
    device11_.Reset();
  }

  IDXGISwapChain4* Swapchain() const { return swapchain_.Get(); }
  HRESULT WaitForAvailable() { return transport_ ? transport_->WaitForAvailable() : DXGI_ERROR_INVALID_CALL; }
  Session& Streamline() { return session_; }
  const char* stage = "Not initialized";
  const Decision& CurrentDecision() const { return decision_; }
  const sl::DLSSGState& State() const { return state_; }
  HRESULT SetColorSpace(DXGI_COLOR_SPACE_TYPE space) {
    // HDR10 only for the FG route. No silent scRGB reinterpretation.
    if (space != DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020) return DXGI_ERROR_UNSUPPORTED;
    const HRESULT hr = swapchain_->SetColorSpace1(space);
    if (SUCCEEDED(hr)) color_space_ = space;
    return hr;
  }

 private:
  HRESULT ResizeInputs(UINT width, UINT height) {
    if (!width || !height || width > layout_.output_width || height > layout_.output_height) return E_INVALIDARG;
    if (!session_.Accept(session_.options(session_.viewport, Session::Options({})))) return E_FAIL;
    options_valid_ = false;
    HRESULT hr = transport_->Drain();
    if (FAILED(hr)) return hr;
    if (!session_.Accept(session_.free_resources(sl::kFeatureDLSS_G, session_.viewport))) return E_FAIL;
    transport_.reset();
    for (auto& work : commands_) {
      work.list.Reset();
      work.allocator.Reset();
    }
    ready_ = false;
    layout_.render_width = width;
    layout_.render_height = height;
    if (FAILED(hr = CreateFrames())) return hr;
    ready_ = true;
    return S_OK;
  }
  HRESULT CreateFrames() {
    stage = "Shared frame inputs";
    transport_ = std::make_unique<Interop>();
    HRESULT hr = transport_->Initialize(device11_.Get(), device12_.Get(), queue_.Get(), layout_,
                                        [this](ID3D12Device* expected, ID3D12Device* reported) {
                                          ComPtr<ID3D12Device> native;
                                          return session_.Accept(session_.native(reported, reinterpret_cast<void**>(native.GetAddressOf())))
                                                 && native.Get() == expected;
                                        });
    if (FAILED(hr)) return hr;
    stage = "Frame commands";
    for (auto& work : commands_) {
      if (FAILED(hr = device12_->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&work.allocator)))
          || FAILED(hr = device12_->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, work.allocator.Get(), nullptr, IID_PPV_ARGS(&work.list)))
          || FAILED(hr = work.list->Close())) return hr;
    }
    return S_OK;
  }
  Session session_;  // Unload the interposer LAST, after every proxy is released.
  ComPtr<ID3D11Device> device11_;
  ComPtr<ID3D12Device> device12_, device_proxy_;
  ComPtr<IDXGIFactory2> factory_proxy_;
  ComPtr<ID3D12CommandQueue> queue_;
  ComPtr<IDXGISwapChain4> swapchain_;
  struct Commands {
    ComPtr<ID3D12CommandAllocator> allocator;
    ComPtr<ID3D12GraphicsCommandList> list;
  };
  std::array<Commands, Interop::kSlotCount> commands_;
  std::unique_ptr<Interop> transport_;
  Interop::Slot* pending_ = nullptr;
  Interop::Layout layout_{};
  Decision decision_{};
  Decision applied_{};
  sl::DLSSGState state_{};
  DXGI_COLOR_SPACE_TYPE color_space_ = DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020;
  bool ready_ = false, runtime_ok_ = true, options_valid_ = false;
};
}  // namespace witcher3classic::frame_generation
