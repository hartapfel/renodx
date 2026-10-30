/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11.h>
#include <wrl/client.h>
#include <array>
#include <mutex>
#include <shared_mutex>
#include <unordered_set>
#include "../../../utils/data.hpp"
#include "../../../utils/directx.hpp"
#include "../../../utils/hash.hpp"

namespace witcher3classic::rain {
using Microsoft::WRL::ComPtr;
inline float enabled = 1.f;
// Rain shares its native particle shader with other effects. Identify the two
// rain atlases from their upload bytes, not shader hash or dimensions alone.
inline bool RainAtlasDescriptor(const reshade::api::resource_desc& desc) {
  return desc.type == reshade::api::resource_type::texture_2d && desc.texture.depth_or_layers == 1
         && (desc.texture.format == reshade::api::format::bc3_unorm || desc.texture.format == reshade::api::format::bc3_typeless)
         && ((desc.texture.width == 512 && desc.texture.height == 512) || (desc.texture.width == 128 && desc.texture.height == 256));
}
inline bool RainAtlas(const reshade::api::resource_desc& desc, const reshade::api::subresource_data& data) {
  if (!RainAtlasDescriptor(desc) || !data.data) return false;
  const auto width = desc.texture.width, height = desc.texture.height;
  const uint32_t bytes = width * 4, rows = height / 4, pitch = data.row_pitch ? data.row_pitch : bytes;
  if (pitch < bytes || (data.slice_pitch && data.slice_pitch < pitch * rows)) return false;
  uint32_t crc = 0xffffffffu;
  for (uint32_t row = 0; row < rows; ++row) crc = renodx::utils::hash::UpdateCRC32(crc, static_cast<const uint8_t*>(data.data) + row * pitch, bytes);
  crc = renodx::utils::hash::FinalizeCRC32(crc);
  return (width == 512 && crc == 0xA5BD17D8u) || (width == 128 && crc == 0xD429D533u);
}
class Pipeline {
 public:
  void Observe(uint64_t handle, bool rain) {
    std::unique_lock lock(mutex_);
    if (rain)
      atlases_.insert(handle);
    else
      atlases_.erase(handle);
  }
  bool Bind(ID3D11DeviceContext* context) {
    Restore();
    ComPtr<ID3D11ShaderResourceView> atlas, scene;
    context->PSGetShaderResources(0, 1, &atlas);
    context->PSGetShaderResources(6, 1, &scene);
    if (!atlas || !scene) return false;
    ComPtr<ID3D11Resource> normal;
    atlas->GetResource(&normal);
    {
      std::shared_lock lock(mutex_);
      if (!atlases_.contains(reinterpret_cast<uint64_t>(normal.Get()))) return false;
    }
    D3D11_SHADER_RESOURCE_VIEW_DESC view{};
    scene->GetDesc(&view);
    if (view.ViewDimension != D3D11_SRV_DIMENSION_TEXTURE2D || view.Texture2D.MostDetailedMip != 0
        || (view.Format != DXGI_FORMAT_R16G16B16A16_FLOAT && view.Format != DXGI_FORMAT_R32G32B32A32_FLOAT)) return false;
    ComPtr<ID3D11Resource> resource;
    scene->GetResource(&resource);
    ComPtr<ID3D11Texture2D> texture;
    if (FAILED(resource.As(&texture))) return false;
    D3D11_TEXTURE2D_DESC desc{};
    texture->GetDesc(&desc);
    D3D11_VIEWPORT viewport{};
    UINT count = 1;
    context->RSGetViewports(&count, &viewport);
    if (count != 1 || viewport.TopLeftX != 0 || viewport.TopLeftY != 0 || viewport.Width < 1 || viewport.Height < 1
        || viewport.Width > desc.Width || viewport.Height > desc.Height || desc.SampleDesc.Count != 1 || desc.ArraySize != 1) return false;
    ComPtr<ID3D11RenderTargetView> target;
    context->OMGetRenderTargets(1, &target, nullptr);
    if (!target) return false;
    ComPtr<ID3D11Resource> output;
    target->GetResource(&output);
    if (output == resource) return false;
    ComPtr<ID3D11Buffer> common;
    context->PSGetConstantBuffers(12, 1, &common);
    if (!common) return false;
    D3D11_BUFFER_DESC cb{};
    common->GetDesc(&cb);
    if (cb.ByteWidth != 4304) return false;
    ComPtr<ID3D11BlendState> blend;
    context->OMGetBlendState(&blend, nullptr, nullptr);
    if (!blend) return false;
    D3D11_BLEND_DESC blend_desc{};
    blend->GetDesc(&blend_desc);
    const auto& attachment = blend_desc.RenderTarget[0];
    if (!attachment.BlendEnable || attachment.SrcBlend != D3D11_BLEND_ONE || attachment.DestBlend != D3D11_BLEND_INV_SRC_ALPHA
        || attachment.BlendOp != D3D11_BLEND_OP_ADD) return false;
    if (!parameters_) {
      ComPtr<ID3D11Device> device;
      context->GetDevice(&device);
      const std::array<float, 4> flag{1, 0, 0, 0};
      D3D11_BUFFER_DESC buffer{16, D3D11_USAGE_IMMUTABLE, D3D11_BIND_SHADER_RESOURCE, 0, D3D11_RESOURCE_MISC_BUFFER_STRUCTURED, 16};
      D3D11_SUBRESOURCE_DATA data{flag.data()};
      ComPtr<ID3D11Buffer> storage;
      if (FAILED(device->CreateBuffer(&buffer, &data, &storage)) || FAILED(device->CreateShaderResourceView(storage.Get(), nullptr, &parameters_))) return false;
      D3D11_SAMPLER_DESC sampler{};
      sampler.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
      sampler.AddressU = sampler.AddressV = sampler.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
      sampler.MaxLOD = D3D11_FLOAT32_MAX;
      if (FAILED(device->CreateSamplerState(&sampler, &sampler_))) {
        parameters_.Reset();
        return false;
      }
    }
    context_ = context;
    context->PSGetShaderResources(110, 1, &previous_);
    context->PSGetSamplers(10, 1, &previous_sampler_);
    context->PSSetShaderResources(110, 1, parameters_.GetAddressOf());
    context->PSSetSamplers(10, 1, sampler_.GetAddressOf());
    bound_ = true;
    return true;
  }
  void Restore() {
    if (!bound_) return;
    context_->PSSetShaderResources(110, 1, previous_.GetAddressOf());
    context_->PSSetSamplers(10, 1, previous_sampler_.GetAddressOf());
    previous_.Reset();
    previous_sampler_.Reset();
    context_.Reset();
    bound_ = false;
  }

 private:
  std::shared_mutex mutex_;
  std::unordered_set<uint64_t> atlases_;
  ComPtr<ID3D11DeviceContext> context_;
  ComPtr<ID3D11ShaderResourceView> parameters_, previous_;
  ComPtr<ID3D11SamplerState> sampler_, previous_sampler_;
  bool bound_ = false;
};
struct __declspec(uuid("67c78053-f2e2-4a7c-bd4a-c8f5cab187f9")) DeviceData {
  Pipeline pipeline;
  bool logged = false;
};
inline void OnInit(reshade::api::device* device) { renodx::utils::data::Create<DeviceData>(device); }
inline void OnDestroy(reshade::api::device* device) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(device)) data->pipeline.Restore();
  renodx::utils::data::Delete<DeviceData>(device);
}
inline void OnInitResource(reshade::api::device* device, const reshade::api::resource_desc& desc, const reshade::api::subresource_data* initial, reshade::api::resource_usage, reshade::api::resource resource) {
  if (initial && RainAtlasDescriptor(desc))
    if (auto* data = renodx::utils::data::Get<DeviceData>(device)) data->pipeline.Observe(resource.handle, RainAtlas(desc, initial[0]));
}
inline bool OnUpdateTexture(reshade::api::device* device, const reshade::api::subresource_data& upload, reshade::api::resource resource, uint32_t subresource, const reshade::api::subresource_box* box) {
  if (subresource != 0) return false;
  if (auto* data = renodx::utils::data::Get<DeviceData>(device)) {
    const auto desc = device->get_resource_desc(resource);
    if (!RainAtlasDescriptor(desc)) return false;
    const bool full = !box || (box->left == 0 && box->top == 0 && box->front == 0 && box->right == desc.texture.width && box->bottom == desc.texture.height && box->back == 1);
    data->pipeline.Observe(resource.handle, full && RainAtlas(desc, upload));
  }
  return false;
}
inline void OnDestroyResource(reshade::api::device* device, reshade::api::resource resource) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(device)) data->pipeline.Observe(resource.handle, false);
}
inline void OnDraw(reshade::api::command_list* cmd) {
  if (enabled != 1.f || cmd->get_device()->get_api() != reshade::api::device_api::d3d11) return;
  if (auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device())) {
    auto* context = reinterpret_cast<ID3D11DeviceContext*>(cmd->get_native());
    renodx::utils::directx::NativeFromReShadeProxy(&context);
    if (context->GetType() == D3D11_DEVICE_CONTEXT_IMMEDIATE && data->pipeline.Bind(context) && !data->logged) {
      data->logged = true;
      reshade::log::message(reshade::log::level::info, "Witcher Classic: refractive rain active using the native HDR scene copy; no extra draw or copy.");
    }
  }
}
inline void OnDrawn(reshade::api::command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device())) data->pipeline.Restore();
}
}  // namespace witcher3classic::rain
