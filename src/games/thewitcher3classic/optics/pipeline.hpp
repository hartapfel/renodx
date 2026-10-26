/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <embed/0xF3C10002.h>
#include <embed/0xF3C20001.h>
#include <algorithm>
#include <array>
#include <cmath>
#include <span>
#include "../temporal/context.hpp"
#include "./settings.hpp"

namespace witcher3classic::optics {
using Microsoft::WRL::ComPtr;
// Dedicated optical scratch. Never overwrite NGX output/history, native scene
// pools or object history. All passes run on the immediate context without readback.
class Pipeline {
 public:
  HRESULT error = S_OK;
  uint64_t captured_frame = UINT64_MAX, applied_frame = UINT64_MAX;
  ComPtr<ID3D11ShaderResourceView> saved_scene;
  float saved_sharpening = -1.f;
  bool Capture(ID3D11DeviceContext1* context, ID3D11ShaderResourceView* depth,
               ID3D11ShaderResourceView* motion, ID3D11ShaderResourceView* object_vectors,
               ID3D11ShaderResourceView* object_depth, ID3D11Buffer* frame_constants,
               uint32_t width, uint32_t height, float jitter_x, float jitter_y, float elapsed, bool history, uint64_t frame_id) {
    if (!depth || !frame_constants || !width || !height) return false;
    if (!Initialize(context)) return false;
    D3D11_BUFFER_DESC desc;
    frame_constants->GetDesc(&desc);
    if (desc.ByteWidth < 4304) return false;
    if (!frame_ || frame_bytes_ != desc.ByteWidth) {
      frame_.Reset();
      const D3D11_BUFFER_DESC buffer{desc.ByteWidth, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER};
      error = device_->CreateBuffer(&buffer, nullptr, &frame_);
      if (FAILED(error)) return false;
      frame_bytes_ = desc.ByteWidth;
    }
    // D3D11 constant buffers must be copied as a whole resource.
    context->CopyResource(frame_.Get(), frame_constants);
    depth_ = depth;
    motion_ = motion;
    objects_ = object_vectors;
    object_depth_ = object_depth;
    render_width_ = width;
    render_height_ = height;
    jitter_ = {jitter_x / width, jitter_y / height};
    interval_ = std::clamp(elapsed * .001f, .0001f, 1.f);
    history_ = history;
    captured_frame = frame_id;
    return true;
  }

  ID3D11ShaderResourceView* Run(ID3D11DeviceContext1* context, ID3D11ShaderResourceView* scene,
                                uint32_t width, uint32_t height, uint64_t frame_id, float sharpening = 0.f) {
    if (!custom || !scene || applied_frame == frame_id || captured_frame != frame_id
        || !width || !height || width > 8192 || height > 8192 || !Initialize(context)) return nullptr;
    const bool bloom = bloom_mode == 1.f && bloom_strength > 0.f;
    const bool dof = dof_mode == 1.f && dof_strength > 0.f;
    const bool motion = MotionActive() && history_ && motion_ && (!ObjectOnly() || (objects_ && object_depth_));
    if (!bloom && !dof && !motion && sharpening <= 0.f) return nullptr;
    if (!full_[0].Ensure(device_.Get(), width, height) || !full_[1].Ensure(device_.Get(), width, height)) return nullptr;
    temporal::ContextScope restore(context, state_.Get());
    context_ = context;
    Parameters params{};
    params.f1 = {float(width), float(height), 0, 0};
    params.f2 = {jitter_[0], jitter_[1], float(render_width_), float(render_height_)};
    ID3D11ShaderResourceView* current = scene;
    size_t next = 0;
    const uint32_t half_width = (width + 1) / 2, half_height = (height + 1) / 2;
    if (bloom) {
      for (auto& target : bloom_)
        if (!target.Ensure(device_.Get(), (width + 3) / 4, (height + 3) / 4)) return nullptr;
      params.f0 = {std::clamp(bloom_extraction, 1.f, 4.f), 0, 0, 0};
      if (!Pass(1, bloom_[0], current, nullptr, nullptr, params)) return nullptr;
      const int passes = std::clamp(int(std::floor(bloom_size * 10.f)), 1, 64);
      const float gain = bloom_size >= .1f && bloom_size < .2f ? 1.f : 1.728f;
      const float clear[4] = {};
      context->ClearRenderTargetView(bloom_[2].target.Get(), clear);
      for (int i = 0; i < passes; ++i) {
        const float radius = std::max(.5f, (i + .5f) * .5f);
        params.f0 = {radius, 0, 0, 0};
        Pass(2, bloom_[1], bloom_[0].view.Get(), nullptr, nullptr, params);
        params.f0 = {0, radius, 0, 0};
        Pass(2, bloom_[0], bloom_[1].view.Get(), nullptr, nullptr, params);
        params.f0 = {gain / passes, 0, 0, 0};
        Pass(3, bloom_[2], bloom_[0].view.Get(), nullptr, nullptr, params, true);
      }
      params.f0 = {bloom_strength, 0, 0, 0};
      Pass(4, full_[next], current, bloom_[2].view.Get(), nullptr, params);
      current = full_[next].view.Get();
      next = 1 - next;
    }
    if (dof) {
      for (auto& target : half_)
        if (!target.Ensure(device_.Get(), half_width, half_height)) return nullptr;
      const float focal = std::clamp(focal_length, 1.f, 300.f) * .001f;
      const float focus = std::max(focus_distance, focal + .001f);
      const float s = focal * focal / std::max(aperture, .1f) / std::max(focus - focal, 1e-5f) * 26666.666f * dof_strength;
      const float near_limit = std::min(99.f * s, 20.f);
      const float far_radius = std::min(s, 10.f) * .4330127f * height / 1080.f;
      const float near_radius = near_limit * .3464102f * height / 1080.f;
      params.f0 = {focus, near_limit > 0.f ? std::min(s / near_limit, 1.f) : 0.f, 0, 0};
      Pass(5, full_[next], current, nullptr, nullptr, params);
      auto* sharp = full_[next].view.Get();
      next = 1 - next;
      params.f0 = {far_radius, 0, 0, 0};
      Pass(6, half_[0], sharp, nullptr, nullptr, params);
      Pass(8, half_[1], half_[0].view.Get(), nullptr, nullptr, params);
      params.f0 = {near_radius, 0, 0, 0};
      Pass(7, half_[2], sharp, nullptr, nullptr, params);
      Pass(9, half_[3], half_[2].view.Get(), nullptr, nullptr, params);
      params.f0 = {far_radius * 2.f, near_strength, 0, 0};
      Pass(10, full_[next], sharp, half_[3].view.Get(), half_[1].view.Get(), params);
      current = full_[next].view.Get();
      next = 1 - next;
    }
    if (motion) {
      if (!velocity_.Ensure(device_.Get(), render_width_, render_height_)) return nullptr;
      uint32_t tile_width = render_width_, tile_height = render_height_;
      for (size_t i = 0; i < tiles_.size(); ++i) {
        if (i < 5) {
          tile_width = (tile_width + 1) / 2;
          tile_height = (tile_height + 1) / 2;
        }
        if (!tiles_[i].Ensure(device_.Get(), tile_width, tile_height)) return nullptr;
      }
      for (size_t i = 0; i < 3; ++i)
        if (!half_[i].Ensure(device_.Get(), half_width, half_height)) return nullptr;
      params.f0 = {std::min(1.f, interval_ * 30.f), ObjectOnly() ? 1.f : 0.f, history_ ? 1.f : 0.f, 0};
      // Velocity is in the jittered render grid; de-jitter only when resampling
      // it to output coordinates in the bake, not a second time here.
      const auto jitter = params.f2;
      params.f2[0] = params.f2[1] = 0;
      Pass(11, velocity_, nullptr, nullptr, nullptr, params);
      params.f2 = jitter;
      auto* tile = velocity_.view.Get();
      for (size_t i = 0; i < tiles_.size(); ++i) {
        Pass(i == 5 ? 13 : 12, tiles_[i], tile, nullptr, nullptr, params);
        tile = tiles_[i].view.Get();
      }
      // Custom half-shutter convention; 50 strength = 1/60 second exposure.
      const float scale = .5f * (motion_strength / 60.f) / interval_;
      params.f0 = {scale, 0, 0, 0};
      Pass(14, half_[2], velocity_.view.Get(), tile, nullptr, params);
      Pass(0, half_[1], current, nullptr, nullptr, params);
      params.f0 = {scale, 1, 0, 0};
      Pass(15, half_[0], half_[1].view.Get(), half_[2].view.Get(), nullptr, params);
      params.f0 = {scale, 1.f / 6.f, 0, 0};
      Pass(15, half_[1], half_[0].view.Get(), half_[2].view.Get(), nullptr, params);
      Pass(16, full_[next], current, half_[1].view.Get(), nullptr, params);
      current = full_[next].view.Get();
      next = 1 - next;
    }
    if (sharpening > 0.f) {
      // Sharpen once before the Custom cubic lens gather, not at every lens tap.
      params.f0 = {sharpening, 0, 0, 0};
      Pass(17, full_[next], current, nullptr, nullptr, params);
      current = full_[next].view.Get();
    }
    applied_frame = frame_id;
    return current;
  }

 private:
  struct Target {
    ComPtr<ID3D11Texture2D> texture;
    ComPtr<ID3D11ShaderResourceView> view;
    ComPtr<ID3D11RenderTargetView> target;
    uint32_t width = 0, height = 0;
    bool Ensure(ID3D11Device* device, uint32_t w, uint32_t h) {
      if (width == w && height == h && view && target) return true;
      texture.Reset();
      view.Reset();
      target.Reset();
      width = height = 0;
      const D3D11_TEXTURE2D_DESC desc{w, h, 1, 1, DXGI_FORMAT_R16G16B16A16_FLOAT, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE};
      if (FAILED(device->CreateTexture2D(&desc, nullptr, &texture))
          || FAILED(device->CreateShaderResourceView(texture.Get(), nullptr, &view))
          || FAILED(device->CreateRenderTargetView(texture.Get(), nullptr, &target))) return false;
      width = w;
      height = h;
      return true;
    }
  };
  struct Parameters {
    std::array<float, 4> dimensions{}, f0{}, f1{}, f2{};
    uint32_t stage = 0;
    std::array<float, 3> padding{};
  };
  bool Initialize(ID3D11DeviceContext1* context) {
    if (pixel_ && constants_ && additive_) return true;
    context->GetDevice(&device_);
    if (FAILED(error = temporal::CreateIsolatedState(device_.Get(), &state_))
        || FAILED(error = device_->CreateVertexShader(__0xF3C10002.data(), __0xF3C10002.size(), nullptr, &vertex_))
        || FAILED(error = device_->CreatePixelShader(__0xF3C20001.data(), __0xF3C20001.size(), nullptr, &pixel_))) return false;
    const D3D11_BUFFER_DESC buffer{sizeof(Parameters), D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER};
    if (FAILED(error = device_->CreateBuffer(&buffer, nullptr, &constants_))) return false;
    D3D11_SAMPLER_DESC sampler = CD3D11_SAMPLER_DESC(D3D11_DEFAULT);
    sampler.AddressU = sampler.AddressV = sampler.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
    sampler.Filter = D3D11_FILTER_MIN_MAG_LINEAR_MIP_POINT;
    if (FAILED(error = device_->CreateSamplerState(&sampler, &linear_))) return false;
    sampler.Filter = D3D11_FILTER_MIN_MAG_MIP_POINT;
    if (FAILED(error = device_->CreateSamplerState(&sampler, &point_))) return false;
    D3D11_BLEND_DESC blend = CD3D11_BLEND_DESC(D3D11_DEFAULT);
    blend.RenderTarget[0].BlendEnable = true;
    blend.RenderTarget[0].SrcBlend = blend.RenderTarget[0].DestBlend = D3D11_BLEND_ONE;
    return SUCCEEDED(error = device_->CreateBlendState(&blend, &additive_));
  }
  bool Pass(uint32_t stage, Target& target, ID3D11ShaderResourceView* first, ID3D11ShaderResourceView* second,
            ID3D11ShaderResourceView* third, Parameters params, bool add = false) {
    if (!target.view || !target.target) return false;
    ID3D11ShaderResourceView* clear[6] = {};
    context_->PSSetShaderResources(0, 6, clear);
    context_->OMSetRenderTargets(0, nullptr, nullptr);
    params.stage = stage;
    params.dimensions = {float(target.width), float(target.height), float(target.width), float(target.height)};
    if (first) {
      ComPtr<ID3D11Resource> resource;
      ComPtr<ID3D11Texture2D> texture;
      first->GetResource(&resource);
      if (FAILED(resource.As(&texture))) return false;
      D3D11_TEXTURE2D_DESC desc;
      texture->GetDesc(&desc);
      params.dimensions[2] = float(desc.Width);
      params.dimensions[3] = float(desc.Height);
    }
    context_->UpdateSubresource(constants_.Get(), 0, nullptr, &params, 0, 0);
    ID3D11Buffer* constants = constants_.Get();
    ID3D11Buffer* frame = frame_.Get();
    context_->PSSetConstantBuffers(0, 1, &constants);
    context_->PSSetConstantBuffers(12, 1, &frame);
    ID3D11ShaderResourceView* inputs[] = {first, second, third, depth_.Get(), ObjectOnly() ? objects_.Get() : motion_.Get(), object_depth_.Get()};
    context_->PSSetShaderResources(0, 6, inputs);
    ID3D11SamplerState* samplers[] = {linear_.Get(), point_.Get()};
    context_->PSSetSamplers(0, 2, samplers);
    context_->VSSetShader(vertex_.Get(), nullptr, 0);
    context_->PSSetShader(pixel_.Get(), nullptr, 0);
    auto* output = target.target.Get();
    context_->OMSetRenderTargets(1, &output, nullptr);
    context_->OMSetBlendState(add ? additive_.Get() : nullptr, nullptr, UINT_MAX);
    const D3D11_VIEWPORT viewport{0, 0, float(target.width), float(target.height), 0, 1};
    context_->RSSetViewports(1, &viewport);
    context_->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    context_->Draw(3, 0);
    return true;
  }
  ComPtr<ID3D11Device> device_;
  ComPtr<ID3DDeviceContextState> state_;
  ComPtr<ID3D11VertexShader> vertex_;
  ComPtr<ID3D11PixelShader> pixel_;
  ComPtr<ID3D11SamplerState> linear_, point_;
  ComPtr<ID3D11BlendState> additive_;
  ComPtr<ID3D11Buffer> constants_, frame_;
  ComPtr<ID3D11ShaderResourceView> depth_, motion_, objects_, object_depth_;
  std::array<Target, 2> full_;
  std::array<Target, 4> half_;
  std::array<Target, 3> bloom_;
  std::array<Target, 6> tiles_;
  Target velocity_;
  ID3D11DeviceContext1* context_ = nullptr;
  uint32_t render_width_ = 0, render_height_ = 0;
  uint32_t frame_bytes_ = 0;
  std::array<float, 2> jitter_{};
  float interval_ = 1.f / 60.f;
  bool history_ = false;
};
}  // namespace witcher3classic::optics
