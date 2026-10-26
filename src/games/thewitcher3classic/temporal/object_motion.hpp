/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11_1.h>
#include <wrl/client.h>
#include <algorithm>
#include <array>
#include <unordered_map>
#include "./context.hpp"
#include "./deformed_motion.hpp"
#include "./foliage_motion.hpp"
#include "./object_engine.hpp"
#include "./rigid_motion.hpp"

namespace witcher3classic::temporal {
class ObjectMotion {
 public:
  bool active_draw = false;
  uint32_t draws = 0, matched_allocations = 0;
  uint32_t skinned_draws = 0, deformed_draws = 0, rigid_draws = 0;
  uint32_t foliage_draws = 0;
  uint32_t target_reuses = 0;
  ConstantUploads uploads;
  const char* rejection = "No matching skinned draw";
  HRESULT error = S_OK;
  std::array<Microsoft::WRL::ComPtr<ID3D11ShaderResourceView>, 2> surfaces;

  void Configure(ID3D11Resource* depth, uint32_t width, uint32_t height, uint32_t viewport_width = 0, uint32_t viewport_height = 0) {
    if (!viewport_width) viewport_width = width;
    if (!viewport_height) viewport_height = height;
    if (depth_.Get() == depth && width_ == width && height_ == height
        && viewport_width_ == viewport_width && viewport_height_ == viewport_height) return;
    depth_ = depth;
    device_.Reset();
    if (depth) {
      depth->GetDevice(&device_);
      auto* native = device_.Get();
      renodx::utils::directx::NativeFromReShadeProxy(&native);
      device_ = native;
    }
    width_ = width;
    height_ = height;
    viewport_width_ = viewport_width;
    viewport_height_ = viewport_height;
    for (auto& surface : surfaces) surface.Reset();
    for (auto& target : targets_) target.Reset();
    prepared_frame_ = UINT64_MAX;
    bone_history_valid_ = false;
    bone_prepared_frame_ = UINT64_MAX;
    deformed_.Clear();
    foliage_.Clear();
    geometry_prepared_frame_ = UINT64_MAX;
  }

  bool Begin(ID3D11DeviceContext1* context, uint64_t frame, bool reference_pose = false, bool deformed = false, bool rigid = false, bool forward = false, uint32_t foliage = 0) {
    if (!foliage) ClosePass(context);
    rejection = "Waiting for main-scene depth";
    if (active_draw || !depth_) return false;
    rejection = "Viewport differs from main scene";
    D3D11_VIEWPORT viewport;
    UINT viewport_count = 1;
    context->RSGetViewports(&viewport_count, &viewport);
    if (viewport_count != 1 || viewport.TopLeftX != 0 || viewport.TopLeftY != 0
        || viewport.Width != float(viewport_width_) || viewport.Height != float(viewport_height_)
        || viewport.MinDepth != 0 || viewport.MaxDepth != 1) return false;
    std::array<ID3D11RenderTargetView*, 8> raw_targets = {};
    context->OMGetRenderTargets(8, raw_targets.data(), &saved_depth_);
    for (size_t i = 0; i < saved_targets_.size(); ++i) saved_targets_[i].Attach(raw_targets[i]);
    const bool retained_targets = pending_targets_ && saved_targets_[3] == targets_[0] && saved_targets_[4] == targets_[1];
    if (retained_targets) {
      saved_targets_[3].Reset();
      saved_targets_[4].Reset();
      raw_targets[3] = raw_targets[4] = nullptr;
    }
    saved_target_count_ = forward ? 1u : 3u;
    rejection = "Draw is outside the main geometry targets";
    if (!saved_depth_ || !saved_targets_[0]
        || (!forward && (!saved_targets_[1] || !saved_targets_[2]))
        || std::any_of(saved_targets_.begin() + saved_target_count_, saved_targets_.end(), [](const auto& target) { return target != nullptr; })) return false;
    if (forward) {
      // Only captured opaque forward materials are registered. Alpha-blended
      // layers need different motion compositing and must remain on camera MVs.
      Microsoft::WRL::ComPtr<ID3D11BlendState> blend;
      context->OMGetBlendState(&blend, nullptr, nullptr);
      D3D11_BLEND_DESC desc = CD3D11_BLEND_DESC(D3D11_DEFAULT);
      if (blend) blend->GetDesc(&desc);
      rejection = "Forward material is alpha blended";
      if (desc.RenderTarget[0].BlendEnable || desc.RenderTarget[0].RenderTargetWriteMask != D3D11_COLOR_WRITE_ENABLE_ALL) return false;
    }
    rejection = "Geometry depth differs from main scene";
    Microsoft::WRL::ComPtr<ID3D11Resource> depth_resource;
    saved_depth_->GetResource(&depth_resource);
    if (depth_resource != depth_) return false;
    bool rigid_history = rigid;
    if (rigid) {
      rejection = "Rigid batch stationary or native instance identities unavailable";
      if (!rigid_.Prepare(context, frame)) {
        error = rigid_.error;
        return false;
      }
    }
    if (!deformed && !rigid && !foliage) rigid_history = rigid_.Prepare(context, frame, true);
    rejection = "Unsupported bone-buffer view";
    auto* device = device_.Get();
    Microsoft::WRL::ComPtr<ID3D11Buffer> view, frame_constants;
    context->VSGetConstantBuffers(12, 1, &frame_constants);
    rejection = "Unsupported geometry constants";
    if (!frame_constants) return false;
    if (!foliage) {
      context->VSGetConstantBuffers(1, 1, &view);
      if (!view) return false;
      D3D11_BUFFER_DESC view_desc, frame_desc;
      view->GetDesc(&view_desc);
      frame_constants->GetDesc(&frame_desc);
      if (view_desc.ByteWidth != 256u || frame_desc.ByteWidth != 4304) return false;
    }
    if (foliage) {
      rejection = "Unsupported SpeedTree history constants";
      if (!foliage_.Prepare(context, frame, foliage, frame_constants.Get(), &uploads)) {
        error = foliage_.error;
        return false;
      }
    }
    Microsoft::WRL::ComPtr<ID3D11Buffer> source;
    D3D11_BUFFER_DESC bone_desc = {};
    if (!deformed && !rigid && !foliage) {
      Microsoft::WRL::ComPtr<ID3D11ShaderResourceView> bones;
      context->VSGetShaderResources(0, 1, &bones);
      if (!bones) return false;
      Microsoft::WRL::ComPtr<ID3D11Resource> bone_resource;
      bones->GetResource(&bone_resource);
      if (FAILED(bone_resource.As(&source))) return false;
      source->GetDesc(&bone_desc);
      D3D11_SHADER_RESOURCE_VIEW_DESC bone_view;
      bones->GetDesc(&bone_view);
      // Classic creates structured SRVs with BUFFEREX, despite not using raw
      // access. Both view types address the same structured matrix elements.
      if (bone_desc.StructureByteStride != 64 || bone_desc.ByteWidth > 16 * 1024 * 1024
          || (bone_view.ViewDimension != D3D11_SRV_DIMENSION_BUFFER && bone_view.ViewDimension != D3D11_SRV_DIMENSION_BUFFEREX)
          || bone_view.Buffer.FirstElement != 0 || bone_view.Buffer.NumElements != bone_desc.ByteWidth / 64
          || (bone_view.ViewDimension == D3D11_SRV_DIMENSION_BUFFEREX && bone_view.BufferEx.Flags != 0)) return false;
    }
    if (!deformed && !rigid && !foliage && bone_prepared_frame_ != frame) {
      matched_allocations = 0;
      rejection = "Skinning allocation registry unavailable";
      if (!object_engine::Allocations(bone_desc.ByteWidth / 64, &allocations_)) return false;
      rejection = "Object-history GPU resources unavailable";
      if (!previous_bones_ || previous_capacity_ != bone_desc.ByteWidth || source_ != source) {
        previous_bones_.Reset();
        previous_bones_view_.Reset();
        bone_desc.Usage = D3D11_USAGE_DEFAULT;
        bone_desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
        bone_desc.CPUAccessFlags = 0;
        bone_desc.MiscFlags = D3D11_RESOURCE_MISC_BUFFER_STRUCTURED;
        error = device->CreateBuffer(&bone_desc, nullptr, &previous_bones_);
        if (FAILED(error)) return false;
        error = device->CreateShaderResourceView(previous_bones_.Get(), nullptr, &previous_bones_view_);
        if (FAILED(error)) return false;
        previous_capacity_ = bone_desc.ByteWidth;
        bone_history_valid_ = false;
        lookup_buffer_.Reset();
        lookup_view_.Reset();
      }
      source_ = source;
      if (!lookup_view_) {
        const D3D11_BUFFER_DESC desc{bone_desc.ByteWidth / 16, D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE, 0, D3D11_RESOURCE_MISC_BUFFER_STRUCTURED, 4};
        error = device->CreateBuffer(&desc, nullptr, &lookup_buffer_);
        if (FAILED(error)) return false;
        error = device->CreateShaderResourceView(lookup_buffer_.Get(), nullptr, &lookup_view_);
        if (FAILED(error)) return false;
      }
      if (!pose_view_) {
        const D3D11_BUFFER_DESC desc{4097 * sizeof(ObjectPose), D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE, 0, D3D11_RESOURCE_MISC_BUFFER_STRUCTURED, sizeof(ObjectPose)};
        error = device->CreateBuffer(&desc, nullptr, &pose_buffer_);
        if (FAILED(error)) return false;
        error = device->CreateShaderResourceView(pose_buffer_.Get(), nullptr, &pose_view_);
        if (FAILED(error)) return false;
      }
      lookup_.assign(bone_desc.ByteWidth / 64, 0);
      poses_.clear();
      poses_.push_back({});
      {
        std::lock_guard lock(object_engine::state->mutex);
        for (const auto& allocation : allocations_) {
          poses_.push_back(bone_history_valid_ ? object_engine::state->history.Previous(frame, allocation) : ObjectPose{});
          matched_allocations += poses_.back().valid;
          if (lookup_[allocation.base]) {
            matched_allocations -= poses_[lookup_[allocation.base]].valid + poses_.back().valid;
            poses_[lookup_[allocation.base]].valid = poses_.back().valid = 0;
            poses_[lookup_[allocation.base]].palette_valid = poses_.back().palette_valid = 0;
          } else {
            lookup_[allocation.base] = static_cast<uint32_t>(poses_.size() - 1);
          }
        }
      }
      context->UpdateSubresource(lookup_buffer_.Get(), 0, nullptr, lookup_.data(), 0, 0);
      const D3D11_BOX pose_region{0, 0, 0, UINT(poses_.size() * sizeof(ObjectPose)), 1, 1};
      context->UpdateSubresource(pose_buffer_.Get(), 0, &pose_region, poses_.data(), 0, 0);
      bone_prepared_frame_ = frame;
    }
    if (!foliage && geometry_prepared_frame_ != frame) {
      for (size_t i = 0; i < 2; ++i) {
        if (!previous_constants_[i] || !pending_constants_[i]) {
          const D3D11_BUFFER_DESC desc{i == 0 ? 256u : 4304u, D3D11_USAGE_DYNAMIC, D3D11_BIND_CONSTANT_BUFFER, D3D11_CPU_ACCESS_WRITE};
          error = device->CreateBuffer(&desc, nullptr, &previous_constants_[i]);
          if (FAILED(error)) return false;
          error = device->CreateBuffer(&desc, nullptr, &pending_constants_[i]);
          if (FAILED(error)) return false;
        }
      }
      uploads.Snapshot(context, pending_constants_[0].Get(), view.Get(), frame);
      uploads.Snapshot(context, pending_constants_[1].Get(), frame_constants.Get(), frame);
      geometry_prepared_frame_ = frame;
    }
    if (prepared_frame_ != frame) {
      draws = 0;
      skinned_draws = deformed_draws = rigid_draws = foliage_draws = 0;
      target_reuses = 0;
      for (size_t i = 0; i < 2; ++i) {
        if (!targets_[i] || !surfaces[i]) {
          Microsoft::WRL::ComPtr<ID3D11Texture2D> texture;
          const D3D11_TEXTURE2D_DESC desc{width_, height_, 1, 1, i == 0 ? DXGI_FORMAT_R16G16_FLOAT : DXGI_FORMAT_R32_FLOAT, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_RENDER_TARGET};
          error = device->CreateTexture2D(&desc, nullptr, &texture);
          if (FAILED(error)) return false;
          error = device->CreateRenderTargetView(texture.Get(), nullptr, &targets_[i]);
          if (FAILED(error)) return false;
          error = device->CreateShaderResourceView(texture.Get(), nullptr, &surfaces[i]);
          if (FAILED(error)) return false;
        }
        const float clear[] = {i == 0 ? 0.f : -2.f, 0, 0, 0};
        context->ClearRenderTargetView(targets_[i].Get(), clear);
      }
      prepared_frame_ = frame;
    }
    if (deformed) {
      rejection = "CPU-deformed mesh identity or stream unavailable";
      if (!deformed_.Prepare(context, frame, &uploads)) {
        error = deformed_.error;
        return false;
      }
    }
    ID3D11ShaderResourceView* previous_reference = nullptr;
    if (reference_pose) {
      rejection = "Unsupported reference-pose texture";
      Microsoft::WRL::ComPtr<ID3D11ShaderResourceView> reference;
      Microsoft::WRL::ComPtr<ID3D11Resource> resource;
      Microsoft::WRL::ComPtr<ID3D11Texture2D> texture;
      context->VSGetShaderResources(1, 1, &reference);
      if (!reference) return false;
      reference->GetResource(&resource);
      if (FAILED(resource.As(&texture))) return false;
      D3D11_TEXTURE2D_DESC desc;
      texture->GetDesc(&desc);
      if (desc.Format != DXGI_FORMAT_R32G32B32A32_FLOAT || desc.Width > 512 || desc.Height != 1
          || desc.MipLevels != 1 || desc.ArraySize != 1 || desc.SampleDesc.Count != 1) return false;
      if (references_.size() >= 128 && !references_.contains(resource.Get())) return false;
      auto& history = references_[resource.Get()];
      if (!history.views[0] || !history.views[1]) {
        history.source = texture;
        desc.Usage = D3D11_USAGE_DEFAULT;
        desc.CPUAccessFlags = desc.MiscFlags = 0;
        desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
        for (size_t i = 0; i < 2; ++i) {
          error = device->CreateTexture2D(&desc, nullptr, &history.textures[i]);
          if (FAILED(error)) return false;
          error = device->CreateShaderResourceView(history.textures[i].Get(), nullptr, &history.views[i]);
          if (FAILED(error)) return false;
        }
      }
      if (history.observed != frame) {
        context->CopyResource(history.textures[1].Get(), texture.Get());
        history.observed = frame;
      }
      if (history.committed != UINT64_MAX && history.committed + 1 == frame) previous_reference = history.views[0].Get();
    }
    context->OMGetBlendState(&saved_blend_, blend_factor_.data(), &sample_mask_);
    const bool retained_blend = pending_targets_ && saved_blend_ == pending_motion_blend_;
    if (retained_blend) saved_blend_ = pending_native_blend_;
    rejection = "Object-motion blend state unavailable";
    auto found_blend = blends_.find(saved_blend_.Get());
    if (found_blend == blends_.end()) {
      D3D11_BLEND_DESC desc = CD3D11_BLEND_DESC(D3D11_DEFAULT);
      if (saved_blend_) saved_blend_->GetDesc(&desc);
      if (!desc.IndependentBlendEnable)
        for (size_t i = 1; i < 8; ++i) desc.RenderTarget[i] = desc.RenderTarget[0];
      desc.IndependentBlendEnable = TRUE;
      for (size_t i : {3u, 4u}) {
        desc.RenderTarget[i].BlendEnable = FALSE;
        desc.RenderTarget[i].RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL;
      }
      BlendState blend{saved_blend_, {}};
      error = device->CreateBlendState(&desc, &blend.motion);
      if (FAILED(error)) return false;
      found_blend = blends_.emplace(saved_blend_.Get(), std::move(blend)).first;
    }
    // Only these slots change around the original draw. ReShade's tracked state
    // sees the same native bindings before and after; no geometry is redrawn.
    if (!foliage) {
      std::array<ID3D11ShaderResourceView*, 6> saved_srvs = {};
      context->VSGetShaderResources(120, 6, saved_srvs.data());
      for (size_t i = 0; i < saved_srvs_.size(); ++i) saved_srvs_[i].Attach(saved_srvs[i]);
    }
    if (!foliage) {
      std::array<ID3D11Buffer*, 4> saved_constants = {};
      context->VSGetConstantBuffers(8, 4, saved_constants.data());
      for (size_t i = 0; i < saved_constants.size(); ++i) saved_constants_[i].Attach(saved_constants[i]);
      context->PSGetConstantBuffers(11, 1, &saved_constants_[4]);
    }
    std::array<ID3D11UnorderedAccessView*, 7> uavs = {};
    context->OMGetRenderTargetsAndUnorderedAccessViews(0, nullptr, nullptr, saved_target_count_, 8 - saved_target_count_, uavs.data());
    for (size_t i = 0; i < uavs.size(); ++i) saved_uavs_[i].Attach(uavs[i]);
    if (!foliage) {
      ID3D11ShaderResourceView* inputs[] = {previous_bones_view_.Get(), lookup_view_.Get(), pose_view_.Get(), previous_reference, deformed ? deformed_.vertices : nullptr, rigid_history ? rigid_.poses.Get() : nullptr};
      context->VSSetShaderResources(120, 6, inputs);
      ID3D11Buffer* constants[] = {deformed ? deformed_.metadata : rigid_history ? rigid_.metadata.Get()
                                                                          : nullptr,
                                 deformed ? deformed_.world : saved_constants_[1].Get(), previous_constants_[0].Get(), previous_constants_[1].Get()};
      context->VSSetConstantBuffers(8, 4, constants);
      // Motion uses the VS frame, while native PS b12 retains its independent
      // lighting/fog values. Sharing the slot can change character/horse shading.
      auto* current_frame = frame_constants.Get();
      context->PSSetConstantBuffers(11, 1, &current_frame);
    }
    active_foliage_ = foliage;
    if (foliage) {
      std::array<ID3D11Buffer*, 7> saved = {};
      context->VSGetConstantBuffers(4, UINT(saved.size()), saved.data());
      for (size_t i = 0; i < saved.size(); ++i) saved_foliage_constants_[i].Attach(saved[i]);
      // Native collision b11 and native PS frame b12 stay untouched. Only the
      // seven contiguous previous-state slots differ around a foliage draw.
      ID3D11Buffer* history[] = {foliage_.previous[0], foliage_.previous[1], foliage_.previous[2], foliage_.previous[3],
                                foliage_.metadata, foliage_.previous[4], foliage_.previous[5]};
      context->VSSetConstantBuffers(4, UINT(std::size(history)), history);
    }
    raw_targets[3] = targets_[0].Get();
    raw_targets[4] = targets_[1].Get();
    if (!retained_targets) context->OMSetRenderTargets(5, raw_targets.data(), saved_depth_.Get());
    else ++target_reuses;
    if (!retained_blend) context->OMSetBlendState(found_blend->second.motion.Get(), blend_factor_.data(), sample_mask_);
    active_motion_blend_ = found_blend->second.motion;
    active_draw = true;
    rejection = "Active";
    ++draws;
    if (foliage)
      ++foliage_draws;
    else if (deformed)
      ++deformed_draws;
    else if (rigid)
      ++rigid_draws;
    else
      ++skinned_draws;
    return true;
  }

  void End(ID3D11DeviceContext1* context, bool retain_foliage_targets = false) {
    if (!active_draw) return;
    const bool retain = retain_foliage_targets && active_foliage_ && saved_target_count_ == 3
                        && std::ranges::all_of(saved_uavs_, [](const auto& view) { return !view; });
    std::array<ID3D11RenderTargetView*, 8> targets;
    for (size_t i = 0; i < targets.size(); ++i) targets[i] = saved_targets_[i].Get();
    std::array<ID3D11UnorderedAccessView*, 7> uavs;
    for (size_t i = 0; i < uavs.size(); ++i) uavs[i] = saved_uavs_[i].Get();
    if (!retain) {
      context->OMSetRenderTargetsAndUnorderedAccessViews(saved_target_count_, targets.data(), saved_depth_.Get(), saved_target_count_, 8 - saved_target_count_, uavs.data(), nullptr);
      context->OMSetBlendState(saved_blend_.Get(), blend_factor_.data(), sample_mask_);
    }
    pending_targets_ = retain;
    pending_native_blend_ = retain ? saved_blend_ : nullptr;
    pending_motion_blend_ = retain ? active_motion_blend_ : nullptr;
    active_motion_blend_.Reset();
    if (!active_foliage_) {
      std::array<ID3D11ShaderResourceView*, 6> srvs;
      for (size_t i = 0; i < srvs.size(); ++i) srvs[i] = saved_srvs_[i].Get();
      context->VSSetShaderResources(120, 6, srvs.data());
    }
    if (active_foliage_) {
      std::array<ID3D11Buffer*, 7> buffers;
      for (size_t i = 0; i < buffers.size(); ++i) buffers[i] = saved_foliage_constants_[i].Get();
      context->VSSetConstantBuffers(4, UINT(buffers.size()), buffers.data());
      for (auto& buffer : saved_foliage_constants_) buffer.Reset();
      active_foliage_ = false;
    } else {
      ID3D11Buffer* constants[] = {saved_constants_[0].Get(), saved_constants_[1].Get(), saved_constants_[2].Get(), saved_constants_[3].Get()};
      context->VSSetConstantBuffers(8, 4, constants);
      auto* current_frame = saved_constants_[4].Get();
      context->PSSetConstantBuffers(11, 1, &current_frame);
    }
    for (auto& target : saved_targets_) target.Reset();
    for (auto& view : saved_srvs_) view.Reset();
    for (auto& buffer : saved_constants_) buffer.Reset();
    for (auto& uav : saved_uavs_) uav.Reset();
    saved_depth_.Reset();
    saved_blend_.Reset();
    active_draw = false;
  }

  // Retain only across consecutive approved foliage draws. Native target/blend
  // binds may have occurred since End; restore only state still owned by us.
  bool HasPendingPass() const { return pending_targets_; }
  void ClosePass(ID3D11DeviceContext1* context) {
    if (!pending_targets_) return;
    std::array<ID3D11RenderTargetView*, 5> targets = {};
    Microsoft::WRL::ComPtr<ID3D11DepthStencilView> depth;
    context->OMGetRenderTargets(UINT(targets.size()), targets.data(), &depth);
    if (targets[3] == targets_[0].Get() && targets[4] == targets_[1].Get())
      context->OMSetRenderTargets(3, targets.data(), depth.Get());
    for (auto* target : targets) if (target) target->Release();
    Microsoft::WRL::ComPtr<ID3D11BlendState> blend;
    std::array<float, 4> factor;
    UINT mask;
    context->OMGetBlendState(&blend, factor.data(), &mask);
    if (blend == pending_motion_blend_) context->OMSetBlendState(pending_native_blend_.Get(), factor.data(), mask);
    pending_targets_ = false;
    pending_native_blend_.Reset();
    pending_motion_blend_.Reset();
  }

  bool HasFrame(uint64_t frame) const { return prepared_frame_ == frame && draws != 0; }
  void Finish(ID3D11DeviceContext1* context, uint64_t frame) {
    uploads.Finish(frame);
    // Retire absent models even when no geometry produced object vectors.
    foliage_.Finish(frame);
    if (!HasFrame(frame)) {
      bone_history_valid_ = false;
      return;
    }
    if (bone_prepared_frame_ == frame) context->CopyResource(previous_bones_.Get(), source_.Get());
    if (geometry_prepared_frame_ == frame) previous_constants_.swap(pending_constants_);
    for (auto it = references_.begin(); it != references_.end();) {
      auto& reference = it->second;
      if (reference.observed == frame) {
        reference.textures[0].Swap(reference.textures[1]);
        reference.views[0].Swap(reference.views[1]);
        reference.committed = frame;
      }
      if (reference.observed != UINT64_MAX && frame > reference.observed + 120)
        it = references_.erase(it);
      else
        ++it;
    }
    {
      std::lock_guard lock(object_engine::state->mutex);
      if (bone_prepared_frame_ == frame) object_engine::state->history.Commit(frame, allocations_);
    }
    bone_history_valid_ = bone_prepared_frame_ == frame;
    deformed_.Finish(frame);
  }

 private:
  uint32_t width_ = 0, height_ = 0, previous_capacity_ = 0;
  uint32_t viewport_width_ = 0, viewport_height_ = 0;
  uint64_t prepared_frame_ = UINT64_MAX, bone_prepared_frame_ = UINT64_MAX;
  uint64_t geometry_prepared_frame_ = UINT64_MAX;
  bool active_foliage_ = false;
  bool pending_targets_ = false;
  bool bone_history_valid_ = false;
  DeformedMotion deformed_;
  FoliageMotion foliage_;
  std::array<Microsoft::WRL::ComPtr<ID3D11Buffer>, 7> saved_foliage_constants_;
  RigidMotion rigid_;
  std::vector<BoneAllocation> allocations_;
  std::vector<uint32_t> lookup_;
  std::vector<ObjectPose> poses_;
  Microsoft::WRL::ComPtr<ID3D11Resource> depth_;
  Microsoft::WRL::ComPtr<ID3D11Device> device_;
  Microsoft::WRL::ComPtr<ID3D11Buffer> source_, previous_bones_, lookup_buffer_, pose_buffer_;
  Microsoft::WRL::ComPtr<ID3D11ShaderResourceView> previous_bones_view_, lookup_view_, pose_view_;
  std::array<Microsoft::WRL::ComPtr<ID3D11RenderTargetView>, 2> targets_;
  std::array<Microsoft::WRL::ComPtr<ID3D11Buffer>, 2> previous_constants_, pending_constants_;
  std::array<Microsoft::WRL::ComPtr<ID3D11RenderTargetView>, 8> saved_targets_;
  Microsoft::WRL::ComPtr<ID3D11DepthStencilView> saved_depth_;
  std::array<Microsoft::WRL::ComPtr<ID3D11ShaderResourceView>, 6> saved_srvs_;
  std::array<Microsoft::WRL::ComPtr<ID3D11Buffer>, 5> saved_constants_;
  std::array<Microsoft::WRL::ComPtr<ID3D11UnorderedAccessView>, 7> saved_uavs_;
  struct BlendState {
    Microsoft::WRL::ComPtr<ID3D11BlendState> original, motion;
  };
  std::unordered_map<ID3D11BlendState*, BlendState> blends_;
  Microsoft::WRL::ComPtr<ID3D11BlendState> saved_blend_;
  Microsoft::WRL::ComPtr<ID3D11BlendState> active_motion_blend_, pending_native_blend_, pending_motion_blend_;
  std::array<float, 4> blend_factor_ = {};
  UINT sample_mask_ = UINT_MAX, saved_target_count_ = 3;
  struct ReferencePose {
    Microsoft::WRL::ComPtr<ID3D11Texture2D> source;
    std::array<Microsoft::WRL::ComPtr<ID3D11Texture2D>, 2> textures;
    std::array<Microsoft::WRL::ComPtr<ID3D11ShaderResourceView>, 2> views;
    uint64_t observed = UINT64_MAX, committed = UINT64_MAX;
  };
  std::unordered_map<ID3D11Resource*, ReferencePose> references_;
};
}  // namespace witcher3classic::temporal
