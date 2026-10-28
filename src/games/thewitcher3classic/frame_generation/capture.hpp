/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <cstdint>
#include <span>
#include <vector>
#include "../temporal/context.hpp"

namespace witcher3classic::frame_generation {
using Microsoft::WRL::ComPtr;

// Single-pass UI coverage: target 0 retains the native color blend; target 1
// accumulates source-over opacity A + (1-A)*previousA in R8. No replay, depth
// readback, image-difference opacity estimate, or second set of UI draw calls.
class Capture {
 public:
  HRESULT error = S_OK;
  uint64_t frame = UINT64_MAX;
  bool valid = false, alpha_valid = false;
  ComPtr<ID3D11Texture2D> hudless, alpha;

  bool Initialize(ID3D11Device* device, std::span<const uint8_t> vertex, std::span<const uint8_t> pixel, UINT constant_size) {
    device_ = device;
    error = temporal::CreateIsolatedState(device, &isolated_);
    if (FAILED(error)) return false;
    if (FAILED(error = device->CreateVertexShader(vertex.data(), vertex.size(), nullptr, &vertex_))
        || FAILED(error = device->CreatePixelShader(pixel.data(), pixel.size(), nullptr, &pixel_))) return false;
    const D3D11_BUFFER_DESC buffer{constant_size, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER};
    if (FAILED(error = device->CreateBuffer(&buffer, nullptr, &constants_))) return false;
    D3D11_SAMPLER_DESC sampler = CD3D11_SAMPLER_DESC(D3D11_DEFAULT);
    sampler.Filter = D3D11_FILTER_MIN_MAG_MIP_POINT;
    sampler.AddressU = sampler.AddressV = sampler.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
    return SUCCEEDED(error = device->CreateSamplerState(&sampler, &sampler_));
  }

  void Reset(uint64_t next_frame) {
    frame = next_frame;
    valid = alpha_valid = false;
    captured_ = rejected_ = false;
    target_.Reset();
  }

  // The completed scene copy is present even when the game hides all HUD
  // draws. Capture its destination once; a frame with no UI keeps zero alpha.
  bool BeginScene(ID3D11DeviceContext1* context, uint64_t current_frame, UINT width, UINT height) {
    if (active_ || captured_ || rejected_ || !pixel_ || frame != current_frame) return false;
    ComPtr<ID3D11RenderTargetView> view;
    ComPtr<ID3D11Resource> resource;
    ComPtr<ID3D11Texture2D> texture;
    context->OMGetRenderTargets(1, &view, nullptr);
    if (!view) return false;
    view->GetResource(&resource);
    if (FAILED(resource.As(&texture))) return false;
    D3D11_TEXTURE2D_DESC desc{};
    texture->GetDesc(&desc);
    if (desc.Width != width || desc.Height != height || desc.SampleDesc.Count != 1 || desc.MipLevels != 1 || desc.ArraySize != 1
        || desc.Format != DXGI_FORMAT_R16G16B16A16_FLOAT || !temporal::IsSameDevice(texture.Get(), device_.Get())) return false;
    if (!Allocate(desc)) return false;
    // Preserve all native state, including bindings not tracked by ReShade.
    temporal::ContextScope scope(context, isolated_.Get());
    context->CopyResource(scene_.Get(), texture.Get());
    const float zero[4] = {};
    context->ClearRenderTargetView(alpha_rtv_.Get(), zero);
    target_ = texture;
    captured_ = valid = alpha_valid = true;
    return true;
  }

  // Call immediately before the first known HUD draw, AFTER the final scene
  // copy. Capture the actual destination, avoiding guesses about post-FX order.
  bool BeginUI(ID3D11DeviceContext1* context, uint64_t current_frame, UINT width, UINT height) {
    if (active_ || rejected_ || !pixel_ || frame != current_frame) return false;
    context->OMGetRenderTargets(8, saved_targets_, &saved_depth_);
    if (!saved_targets_[0]) {
      Restore(context);
      return false;
    }
    ComPtr<ID3D11Resource> resource;
    saved_targets_[0]->GetResource(&resource);
    ComPtr<ID3D11Texture2D> texture;
    if (FAILED(resource.As(&texture))) {
      Restore(context);
      return false;
    }
    D3D11_TEXTURE2D_DESC desc{};
    texture->GetDesc(&desc);
    // Scaleform builds icons/blur/filter surfaces between main-HUD draws using
    // the same shaders. They are not writes to the captured destination and
    // must not poison its coverage, even if their dimensions happen to match.
    if ((captured_ && texture != target_) || desc.Width != width || desc.Height != height) {
      Restore(context);
      return false;
    }
    for (size_t i = 1; i < std::size(saved_targets_); ++i)
      if (saved_targets_[i]) rejected_ = true;
    if (desc.SampleDesc.Count != 1 || desc.MipLevels != 1 || desc.ArraySize != 1
        || desc.Format != DXGI_FORMAT_R16G16B16A16_FLOAT || !temporal::IsSameDevice(texture.Get(), device_.Get()) || rejected_) {
      rejected_ = true;
      valid = false;
      Restore(context);
      return false;
    }
    context->OMGetBlendState(&saved_blend_, blend_factor_, &sample_mask_);
    D3D11_BLEND_DESC blend = CD3D11_BLEND_DESC(D3D11_DEFAULT);
    if (saved_blend_) saved_blend_->GetDesc(&blend);
    const auto& color = blend.RenderTarget[0];
    // Scaleform stencil construction uses the same UI target without writing
    // its color. Leave the native draw intact and do not accumulate coverage.
    if (!color.RenderTargetWriteMask) {
      Restore(context);
      return false;
    }
    // All recognized UI leaves the pre-UI scene valid. Capture it before even
    // an additive first draw; a later source-over draw must not recapture UI.
    if (!captured_) {
      if (!BeginScene(context, current_frame, width, height)) {
        rejected_ = true;
        Restore(context);
        return false;
      }
    }
    // Additive/multiply UI cannot be represented by source-over alpha alone.
    // Keep the accurate HUD-less scene and omit this frame's optional alpha
    // tag. Never submit a partial mask or disable FG merely for a UI blend.
    if (!color.BlendEnable || color.BlendOp != D3D11_BLEND_OP_ADD
        || (color.SrcBlend != D3D11_BLEND_SRC_ALPHA && color.SrcBlend != D3D11_BLEND_ONE)
        || color.DestBlend != D3D11_BLEND_INV_SRC_ALPHA || blend.AlphaToCoverageEnable) {
      alpha_valid = false;
      Restore(context);
      return false;
    }
    if (!alpha_valid) {
      Restore(context);
      return false;
    }
    blend.IndependentBlendEnable = TRUE;
    blend.RenderTarget[1] = {TRUE, D3D11_BLEND_ONE, D3D11_BLEND_INV_SRC_ALPHA, D3D11_BLEND_OP_ADD,
                             D3D11_BLEND_ONE, D3D11_BLEND_INV_SRC_ALPHA, D3D11_BLEND_OP_ADD, D3D11_COLOR_WRITE_ENABLE_RED};
    ID3D11BlendState* coverage_blend = nullptr;
    for (const auto& entry : blends_)
      if (entry.original.Get() == saved_blend_) coverage_blend = entry.coverage.Get();
    if (!coverage_blend) {
      Blend entry;
      entry.original = saved_blend_;
      if (FAILED(error = device_->CreateBlendState(&blend, &entry.coverage))) {
        rejected_ = true;
        valid = false;
        Restore(context);
        return false;
      }
      coverage_blend = entry.coverage.Get();
      blends_.push_back(std::move(entry));
    }
    ID3D11RenderTargetView* targets[] = {saved_targets_[0], alpha_rtv_.Get()};
    context->OMSetRenderTargets(2, targets, saved_depth_);
    context->OMSetBlendState(coverage_blend, blend_factor_, sample_mask_);
    active_ = true;
    return true;
  }

  // Restore immediately after the injected draw, including failure/skip paths.
  void EndUI(ID3D11DeviceContext1* context) {
    if (active_) Restore(context);
  }

  // An unrecognized draw to this UI destination invalidates this frame. Call
  // before every game draw after capture has begun, using the shader hash.
  void ObserveDraw(ID3D11DeviceContext1* context, bool known_ui) {
    if (!captured_ || !valid || known_ui) return;
    ComPtr<ID3D11RenderTargetView> view;
    context->OMGetRenderTargets(1, &view, nullptr);
    ComPtr<ID3D11Resource> resource;
    if (view) view->GetResource(&resource);
    if (resource.Get() != target_.Get()) return;
    ComPtr<ID3D11BlendState> blend;
    context->OMGetBlendState(&blend, nullptr, nullptr);
    if (blend) {
      D3D11_BLEND_DESC desc{};
      blend->GetDesc(&desc);
      // Stencil-only UI draws do not modify either the scene or its coverage.
      // Check the actual write mask, not a shader allowlist: the same shader
      // can also draw visible color with another blend state.
      if (!desc.RenderTarget[0].RenderTargetWriteMask) return;
    }
    valid = false;
  }

  bool Encode(ID3D11DeviceContext1* context, const void* shader_constants) {
    if (!valid || !captured_ || active_ || !shader_constants) return false;
    temporal::ContextScope scope(context, isolated_.Get());
    context->UpdateSubresource(constants_.Get(), 0, nullptr, shader_constants, 0, 0);
    ID3D11Buffer* constants = constants_.Get();
    context->PSSetConstantBuffers(13, 1, &constants);
    context->VSSetShader(vertex_.Get(), nullptr, 0);
    context->PSSetShader(pixel_.Get(), nullptr, 0);
    ID3D11ShaderResourceView* source = scene_srv_.Get();
    context->PSSetShaderResources(0, 1, &source);
    ID3D11SamplerState* sampler = sampler_.Get();
    context->PSSetSamplers(0, 1, &sampler);
    ID3D11RenderTargetView* target = hudless_rtv_.Get();
    context->OMSetRenderTargets(1, &target, nullptr);
    const D3D11_VIEWPORT viewport{0, 0, float(width_), float(height_), 0, 1};
    context->RSSetViewports(1, &viewport);
    context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    context->Draw(3, 0);
    return true;
  }

 private:
  bool Allocate(D3D11_TEXTURE2D_DESC desc) {
    if (width_ == desc.Width && height_ == desc.Height && hudless && alpha && scene_) return true;
    scene_srv_.Reset();
    alpha_rtv_.Reset();
    hudless_rtv_.Reset();
    scene_.Reset();
    alpha.Reset();
    hudless.Reset();
    desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
    desc.MiscFlags = desc.CPUAccessFlags = 0;
    desc.Usage = D3D11_USAGE_DEFAULT;
    if (FAILED(error = device_->CreateTexture2D(&desc, nullptr, &scene_))
        || FAILED(error = device_->CreateShaderResourceView(scene_.Get(), nullptr, &scene_srv_))) return false;
    desc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
    desc.Format = DXGI_FORMAT_R10G10B10A2_UNORM;
    if (FAILED(error = device_->CreateTexture2D(&desc, nullptr, &hudless))
        || FAILED(error = device_->CreateRenderTargetView(hudless.Get(), nullptr, &hudless_rtv_))) return false;
    desc.Format = DXGI_FORMAT_R8_UNORM;
    if (FAILED(error = device_->CreateTexture2D(&desc, nullptr, &alpha))
        || FAILED(error = device_->CreateRenderTargetView(alpha.Get(), nullptr, &alpha_rtv_))) return false;
    width_ = desc.Width;
    height_ = desc.Height;
    return true;
  }
  void Restore(ID3D11DeviceContext1* context) {
    // BeginUI may fail before changing state. Setting the saved targets is
    // harmless; only restore blend state if it was actually changed.
    context->OMSetRenderTargets(8, saved_targets_, saved_depth_);
    if (active_) context->OMSetBlendState(saved_blend_, blend_factor_, sample_mask_);
    for (auto*& target : saved_targets_) {
      if (target) target->Release();
      target = nullptr;
    }
    if (saved_depth_) saved_depth_->Release();
    saved_depth_ = nullptr;
    if (saved_blend_) saved_blend_->Release();
    saved_blend_ = nullptr;
    active_ = false;
  }
  ComPtr<ID3D11Device> device_;
  ComPtr<ID3DDeviceContextState> isolated_;
  ComPtr<ID3D11Texture2D> scene_, target_;
  ComPtr<ID3D11ShaderResourceView> scene_srv_;
  ComPtr<ID3D11RenderTargetView> hudless_rtv_, alpha_rtv_;
  ComPtr<ID3D11VertexShader> vertex_;
  ComPtr<ID3D11PixelShader> pixel_;
  ComPtr<ID3D11Buffer> constants_;
  ComPtr<ID3D11SamplerState> sampler_;
  struct Blend {
    ComPtr<ID3D11BlendState> original, coverage;
  };
  std::vector<Blend> blends_;
  ID3D11RenderTargetView* saved_targets_[8] = {};
  ID3D11DepthStencilView* saved_depth_ = nullptr;
  ID3D11BlendState* saved_blend_ = nullptr;
  float blend_factor_[4] = {};
  UINT sample_mask_ = UINT_MAX;
  UINT width_ = 0, height_ = 0;
  bool active_ = false, captured_ = false, rejected_ = false;
};
}  // namespace witcher3classic::frame_generation
