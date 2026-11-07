// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <algorithm>
#include <span>
#include "hit_layout.h"
#include "hit_selection.hpp"
#include "../rendering/bindings.hpp"

namespace witcher3graphics::raytracing {
using namespace reshade::api;

// A recording's material records. The pool owns their GPU and
// recording leases; neither destruction nor reuse is permitted before retirement.
// Writes finish in COMMON. Immutable reads use D3D12 buffer promotion/decay;
// no post-dispatch callback is needed if a shader replacement is declined.
class HitField {
 public:
  explicit HitField(device* dev) : device_(dev) {}
  HitField(const HitField&) = delete;
  HitField& operator=(const HitField&) = delete;
  bool Compatible(uint32_t width, uint32_t height, std::span<const uint8_t> clear_code) const {
    return initialized_ && context_[1] == width && context_[2] == height
        && std::ranges::equal(clear_code_, clear_code);
  }
  ~HitField() {
    if (srv_.handle) device_->destroy_resource_view(srv_);
    if (uav_.handle) device_->destroy_resource_view(uav_);
    if (buffer_.handle) device_->destroy_resource(buffer_);
    if (context_buffer_.handle) device_->destroy_resource(context_buffer_);
    if (clear_.handle) device_->destroy_pipeline(clear_);
  }
  bool Initialize(uint32_t width, uint32_t height, std::span<const uint8_t> clear_code) {
    if (attempted_) return Compatible(width, height, clear_code);
    attempted_ = true;
    // Bound each allocation to 256 MiB; the pool imposes its own aggregate cap.
    if (!width || !height || width > 16384 || height > 16384
        || uint64_t(width) * height > W3_HIT_MAX_PIXELS || clear_code.empty()) return false;
    context_ = {0x57334D41u, width, height, 0};
    if (!device_->create_resource(resource_desc(uint64_t(256), memory_heap::cpu_to_gpu, resource_usage::constant_buffer),
            nullptr, resource_usage::general, &context_buffer_)) return false;
    clear_code_.assign(clear_code.begin(), clear_code.end());
    if (!device_->create_resource(resource_desc(Bytes(), memory_heap::gpu_only,
            resource_usage::shader_resource | resource_usage::unordered_access),
            nullptr, resource_usage::general, &buffer_)) return false;
    const resource_view_desc view(format::r32_typeless, uint64_t(0), Bytes() / 4);
    if (!device_->create_resource_view(buffer_, resource_usage::unordered_access, view, &uav_)
        || !device_->create_resource_view(buffer_, resource_usage::shader_resource, view, &srv_)) return false;
    initialized_ = true;
    return true;
  }

  bool BeginWrite(command_list* cmd, uint32_t epoch, uint32_t context_root, uint32_t output_root,
      shader_stage stage = shader_stage::all_ray_tracing, const HitSelectionDispatch* selection = nullptr, bool reuse = false) {
    if (!initialized_ || writing_ || (reuse && (!recorded_ || !selection || writer_ != cmd))
        || (recorded_ && !reuse) || !epoch || (reuse && context_[3] != epoch) || cmd->get_device() != device_
        || (stage != shader_stage::compute && stage != shader_stage::all_ray_tracing)) return false;
    const auto* state = renodx::utils::data::Get<bindings::CommandData>(cmd);
    if (!state || state->in_render_pass || !state->compute.layout.handle || !state->last_pipeline.handle) return false;
    // Read the native CameraCB through its actual GPU descriptor. ReShade does
    // not notify descriptor listeners when CreateConstantBufferView(nullptr)
    // overwrites an existing descriptor; a CPU-resolved buffer could be stale.
    // The clear uses the producer's root layout without touching native args.
    if (!clear_.handle || layout_ != state->compute.layout) {
      if (clear_.handle) { device_->destroy_pipeline(clear_); clear_ = {}; }
      layout_ = state->compute.layout;
      shader_desc shader{clear_code_.data(), clear_code_.size()};
      const pipeline_subobject subobject{pipeline_subobject_type::compute_shader, 1, &shader};
      if (!device_->create_pipeline(layout_, 1, &subobject, &clear_)) return false;
    }
    // The pool's recording/fence lease protects this upload through all readers.
    // Selected producers reuse the same epoch; never rewrite an in-flight CBV.
    if (!reuse) {
      context_[3] = epoch;
      void* mapped = nullptr;
      if (!device_->map_buffer_region(context_buffer_, 0, sizeof(context_), map_access::write_only, &mapped)) return false;
      std::memcpy(mapped, context_.data(), sizeof(context_)); device_->unmap_buffer_region(context_buffer_);
    }
    const pipeline previous = state->last_pipeline;
    const pipeline_stage previous_stages = state->last_stages;
    if (selection) {
      if (!selection->identifiers || !selection->identifiers->Bind(cmd, layout_, selection->identifiers_root,
              selection->raygen_root, selection->raygen_address)) return false;
      // Native state destruction/replacement must not free an identifier buffer
      // referenced by this recording, including any earlier dispatch in it.
      if (std::ranges::find(selections_, selection->identifiers) == selections_.end()) selections_.push_back(selection->identifiers);
    }
    // SRV is also a legal BeforeState for a COMMON buffer. This covers replay
    // twice in one ExecuteCommandLists call, where decay has not happened yet.
    cmd->barrier(buffer_, resource_usage::shader_resource_non_pixel, resource_usage::unordered_access);
    auto preparation_context = context_;
    if (selection && !reuse) preparation_context[0] = 0; // Unconditional first clear.
    cmd->push_constants(shader_stage::compute, layout_, context_root, 0, 4, preparation_context.data());
    cmd->push_descriptors(shader_stage::compute, layout_, output_root, {{}, 0, 0, 1, descriptor_type::buffer_unordered_access_view, &uav_});
    cmd->bind_pipeline(pipeline_stage::compute_shader, clear_);
    cmd->dispatch((context_[1] + 255) / 256, context_[2], 1);
    cmd->barrier(buffer_, resource_usage::unordered_access, resource_usage::unordered_access);
    // Only the PSO changed. Native root arguments, descriptor tables and heaps
    // remain bound, including the graphics controls supplied by the addon.
    cmd->bind_pipeline(previous_stages, previous);
    if (selection) cmd->push_constants(stage, layout_, context_root, 0, 4, context_.data());
    writer_ = cmd; writing_ = recorded_ = true;
    return true;
  }
  bool EndWrite(command_list* cmd) {
    if (!writing_ || writer_ != cmd) return false;
    cmd->barrier(buffer_, resource_usage::unordered_access, resource_usage::general);
    writing_ = false;
    return true;
  }
  bool BindRead(command_list* cmd, uint32_t context_root, uint32_t input_root) {
    // Admission and leases belong to the pool. Selected producers can rewrite
    // it only in the same recording, in command order. Other recordings cannot
    // reuse it until all submissions retire. COMMON promotes to SRV on
    // access and buffers decay after ExecuteCommandLists, including replay.
    // https://learn.microsoft.com/windows/win32/direct3d12/using-resource-barriers-to-synchronize-resource-states-in-direct3d-12
    if (!recorded_ || writing_ || cmd->get_device() != device_) return false;
    const auto* state = renodx::utils::data::Get<bindings::CommandData>(cmd);
    if (!state || state->in_render_pass || !state->compute.layout.handle) return false;
    const buffer_range context{context_buffer_, 0, 256};
    cmd->push_descriptors(shader_stage::compute, state->compute.layout, context_root,
        {{}, 0, 0, 1, descriptor_type::constant_buffer, &context});
    cmd->push_descriptors(shader_stage::compute, state->compute.layout, input_root, {{}, 0, 0, 1, descriptor_type::buffer_shader_resource_view, &srv_});
    return true;
  }
  uint64_t Bytes() const { return W3_HIT_HEADER_BYTES + uint64_t(context_[1]) * context_[2] * W3_HIT_STRIDE; }

 private:
  friend class HitPool;
  void Recycle() { recorded_ = writing_ = false; writer_ = nullptr; context_[3] = 0; selections_.clear(); }
  device* device_;
  resource buffer_{};
  resource context_buffer_{};
  resource_view uav_{}, srv_{};
  pipeline_layout layout_{};
  pipeline clear_{};
  std::vector<uint8_t> clear_code_;
  std::vector<std::shared_ptr<const HitSelection>> selections_;
  std::array<uint32_t, 4> context_{};
  command_list* writer_ = nullptr;
  bool attempted_ = false, initialized_ = false, recorded_ = false, writing_ = false;
};
}  // namespace witcher3graphics::raytracing
