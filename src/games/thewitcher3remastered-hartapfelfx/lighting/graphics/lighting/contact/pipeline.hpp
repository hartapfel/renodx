// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <array>
#include <bit>
#include <memory>
#include <span>
#include <vector>
#include "../../rendering/pass.hpp"

namespace witcher3graphics::contact {
using namespace reshade::api;

// Private resources only. The caller supplies current compute-readable native
// G-buffers and ranged CBVs from the deferred lighting dispatch. This class does
// not install callbacks, retain native resources or change their resource states.
class Pipeline {
 public:
  explicit Pipeline(device* dev) : dev_(dev) {}
  Pipeline(const Pipeline&) = delete;
  Pipeline& operator=(const Pipeline&) = delete;
  ~Pipeline() {
    for (auto& allocation : allocations_) {
      for (const auto& texture : allocation->textures) Destroy(texture);
      for (const auto& buffer : allocation->metadata) Destroy(buffer);
      Destroy(allocation->visibility);
    }
    Destroy(missing_motion_); Destroy(missing_motion_depth_);
    for (const auto value : passes_) if (value.handle) dev_->destroy_pipeline(value);
    if (layout_.handle) dev_->destroy_pipeline_layout(layout_);
  }

  bool Initialize(const std::array<std::span<const uint8_t>, 5>& code) {
    if (attempted_) return initialized_;
    attempted_ = true;
    const std::array<pipeline_layout_param, 11> params{
        pipeline_layout_param(constant_range{0, 10, 0, 12, shader_stage::compute}),
        pipeline_layout_param(constant_range{0, 11, 0, 4, shader_stage::compute}),
        pipeline_layout_param(descriptor_range{0, 12, 0, 1, shader_stage::compute, 1, descriptor_type::constant_buffer}),
        pipeline_layout_param(descriptor_range{0, 13, 0, 1, shader_stage::compute, 1, descriptor_type::constant_buffer}),
        pipeline_layout_param(descriptor_range{0, 0, 0, 6, shader_stage::compute, 1, descriptor_type::texture_shader_resource_view}),
        pipeline_layout_param(descriptor_range{0, 6, 0, 1, shader_stage::compute, 1, descriptor_type::buffer_shader_resource_view}),
        pipeline_layout_param(descriptor_range{0, 7, 0, 2, shader_stage::compute, 1, descriptor_type::texture_shader_resource_view}),
        pipeline_layout_param(descriptor_range{0, 0, 0, 1, shader_stage::compute, 1, descriptor_type::texture_unordered_access_view}),
        pipeline_layout_param(descriptor_range{0, 1, 0, 1, shader_stage::compute, 1, descriptor_type::buffer_unordered_access_view}),
        pipeline_layout_param(descriptor_range{0, 2, 0, 1, shader_stage::compute, 1, descriptor_type::buffer_unordered_access_view}),
        pipeline_layout_param(descriptor_range{0, 9, 0, 1, shader_stage::compute, 1, descriptor_type::constant_buffer})};
    if (!dev_->create_pipeline_layout(uint32_t(params.size()), params.data(), &layout_)) return false;
    for (uint32_t i = 0; i < passes_.size(); ++i) {
      shader_desc shader{code[i].data(), code[i].size()};
      pipeline_subobject subobject{pipeline_subobject_type::compute_shader, 1, &shader};
      if (code[i].empty() || !dev_->create_pipeline(layout_, 1, &subobject, &passes_[i])) return false;
    }
    std::array<float, 2> zero{};
    const subresource_data motion{zero.data(), 8, 8};
    float invalid = -2.f;
    const subresource_data depth{&invalid, 4, 4};
    if (!Texture(1, 1, format::r32g32_float, &missing_motion_, &motion)
        || !Texture(1, 1, format::r32_float, &missing_motion_depth_, &depth)) return false;
    initialized_ = true;
    return true;
  }

  // Native input order is depth, normal, specular/material, stencil, albedo.
  // Motion is the validated previous-minus-current UV adapter, not raw engine
  // motion. Missing motion explicitly rejects animated-character history.
  resource_view Generate(command_list* cmd, const std::array<resource_view, 5>& inputs,
                         const buffer_range& frame, const buffer_range& light,
                         uint32_t width, uint32_t height, const std::array<float, 4>& settings,
                         uint64_t frame_number, uint64_t view_identity,
                         const std::array<resource_view, 2>& motion = {}, const buffer_range& motion_camera = {}) {
    const auto* roots = renodx::utils::data::Get<bindings::CommandData>(cmd);
    const auto* state = renodx::utils::state::GetCurrentState(cmd);
    if (!initialized_ || !roots || roots->in_render_pass || roots->last_pipeline.handle == 0 || !state
        || width == 0 || height == 0 || width > 8192 || height > 8192) return {};
    // Never repeat a write into an allocation in the same frame, including an
    // auxiliary view. The integration owner must bind native fallback instead.
    if (frame_number == last_frame_) return {};
    for (const auto view : inputs) {
      if (!view.handle) return {};
      const auto resource = dev_->get_resource_from_view(view);
      if (!resource.handle) return {};
      const auto desc = dev_->get_resource_desc(resource);
      const auto vd = dev_->get_resource_view_desc(view);
      if (desc.type != resource_type::texture_2d || desc.texture.samples != 1
          || vd.type != resource_view_type::texture_2d || vd.texture.first_level != 0
          || desc.texture.width < width || desc.texture.height < height) return {};
    }
    if (motion[0].handle != 0 || motion[1].handle != 0) {
      for (const auto view : motion) {
        if (!view.handle) return {};
        const auto resource = dev_->get_resource_from_view(view);
        if (!resource.handle) return {};
        const auto desc = dev_->get_resource_desc(resource);
        const auto vd = dev_->get_resource_view_desc(view);
        if (desc.type != resource_type::texture_2d || desc.texture.samples != 1
            || vd.type != resource_view_type::texture_2d || vd.texture.first_level != 0
            || desc.texture.width < width || desc.texture.height < height) return {};
      }
    }
    const std::array<buffer_range, 2> native{frame, light};
    std::array<buffer_range, 2> ranged;
    for (uint32_t i = 0; i < native.size(); ++i) {
      if (!native[i].buffer.handle || (native[i].offset & 255u) != 0) return {};
      const auto desc = dev_->get_resource_desc(native[i].buffer);
      const uint64_t bytes = i == 0 ? 5632 : 256;
      if (desc.type != resource_type::buffer || native[i].size < (i == 0 ? 341 * 16u : 16u)
          || native[i].offset > desc.buffer.size || bytes > desc.buffer.size - native[i].offset) return {};
      ranged[i] = {native[i].buffer, native[i].offset, bytes};
    }
    if (allocations_.empty() || allocations_.back()->width < width || allocations_.back()->height < height) {
      auto allocation = std::make_unique<Allocation>();
      allocation->width = std::bit_ceil(std::max(width, allocations_.empty() ? 0u : allocations_.back()->width));
      allocation->height = std::bit_ceil(std::max(height, allocations_.empty() ? 0u : allocations_.back()->height));
      // Keep partial allocations owned on failure, and keep successful older
      // allocations alive until teardown while their command lists are in flight.
      allocations_.push_back(std::move(allocation));
      auto* created = allocations_.back().get();
      for (auto& texture : created->textures)
        if (!Texture(created->width, created->height, format::r32g32_float, &texture)) return {};
      for (auto& buffer : created->metadata)
        if (!Buffer(345 * 16, &buffer)) return {};
      if (!Buffer(16ull + uint64_t(created->width) * created->height * 12 + 345 * 16, &created->visibility)) return {};
      created->valid = true;
      last_frame_ = UINT64_MAX;
    }
    auto* allocation = allocations_.back().get();
    if (!allocation->valid) return {};
    const bool consecutive = last_frame_ != UINT64_MAX && last_frame_ + 1 == frame_number
        && width == width_ && height == height_ && view_identity == view_identity_;
    const uint32_t next = history_index_ ^ 1u;
    const std::array<float, 12> parameters{settings[0], settings[1], settings[2], settings[3],
        0, 0, 0, 0, 0, 0, float(width), float(height)};
    buffer_range camera = ranged[0];
    bool native_motion = motion[0].handle && motion[1].handle && motion_camera.buffer.handle;
    if (native_motion) {
      const auto desc = dev_->get_resource_desc(motion_camera.buffer);
      native_motion = desc.type == resource_type::buffer && !(motion_camera.offset & 255u)
          && motion_camera.size >= 54 * 16u && motion_camera.offset <= desc.buffer.size
          && 1024 <= desc.buffer.size - motion_camera.offset;
      if (native_motion) camera = {motion_camera.buffer, motion_camera.offset, 1024};
    }
    const std::array<float, 4> history_control{consecutive ? 1.f : 0.f, native_motion ? 1.f : 0.f, 0, 0};
    const std::array<resource_view, 2> motion_views = motion[0].handle && motion[1].handle && (!motion_camera.buffer.handle || native_motion)
        ? motion : std::array{missing_motion_.srv, missing_motion_depth_.srv};
    const bindings::RestorePassState restore(cmd, *state, *roots);
    cmd->push_constants(shader_stage::compute, layout_, 0, 0, 12, parameters.data());
    cmd->push_constants(shader_stage::compute, layout_, 1, 0, 4, history_control.data());
    cmd->push_descriptors(shader_stage::compute, layout_, 10,
        {{0}, 0, 0, 1, descriptor_type::constant_buffer, &camera});
    for (uint32_t i = 0; i < ranged.size(); ++i)
      cmd->push_descriptors(shader_stage::compute, layout_, 2 + i,
          {{0}, 0, 0, 1, descriptor_type::constant_buffer, &ranged[i]});
    cmd->push_descriptors(shader_stage::compute, layout_, 5,
        {{0}, 0, 0, 1, descriptor_type::buffer_shader_resource_view, &allocation->metadata[history_index_].srv});
    cmd->push_descriptors(shader_stage::compute, layout_, 6,
        {{0}, 0, 0, 2, descriptor_type::texture_shader_resource_view, motion_views.data()});
    std::array<resource_view, 6> views{inputs[0], inputs[1], inputs[2], inputs[3], inputs[4], allocation->textures[2 + history_index_].srv};
    // Pack -> trace -> spatial (reuse pack storage) -> history -> publish.
    for (uint32_t pass = 0; pass < 5; ++pass) {
      if (pass == 0) {
        cmd->barrier(allocation->visibility.resource, resource_usage::shader_resource, resource_usage::unordered_access);
        cmd->push_descriptors(shader_stage::compute, layout_, 8,
            {{0}, 0, 0, 1, descriptor_type::buffer_unordered_access_view, &allocation->visibility.uav});
      }
      if (pass == 1) views[1] = allocation->textures[0].srv;
      if (pass == 2) { views[1] = inputs[1]; views[4] = allocation->textures[1].srv; }
      if (pass == 3) views[4] = allocation->textures[0].srv;
      if (pass == 4) views[4] = allocation->textures[2 + next].srv;
      cmd->push_descriptors(shader_stage::compute, layout_, 4,
          {{0}, 0, 0, uint32_t(views.size()), descriptor_type::texture_shader_resource_view, views.data()});
      const auto& output = pass == 4 ? allocation->visibility : allocation->textures[pass == 3 ? 2 + next : pass == 1 ? 1 : 0];
      cmd->barrier(output.resource, resource_usage::shader_resource, resource_usage::unordered_access);
      cmd->push_descriptors(shader_stage::compute, layout_, pass == 4 ? 8 : 7,
          {{0}, 0, 0, 1, pass == 4 ? descriptor_type::buffer_unordered_access_view : descriptor_type::texture_unordered_access_view, &output.uav});
      if (pass == 4) {
        cmd->barrier(allocation->metadata[next].resource, resource_usage::shader_resource, resource_usage::unordered_access);
        cmd->push_descriptors(shader_stage::compute, layout_, 9,
            {{0}, 0, 0, 1, descriptor_type::buffer_unordered_access_view, &allocation->metadata[next].uav});
      }
      cmd->bind_pipeline(pipeline_stage::compute_shader, passes_[pass]);
      cmd->dispatch((width + 7) / 8, (height + 7) / 8, 1);
      cmd->barrier(output.resource, resource_usage::unordered_access, resource_usage::shader_resource);
      if (pass == 0) cmd->barrier(allocation->visibility.resource, resource_usage::unordered_access, resource_usage::shader_resource);
      if (pass == 4) cmd->barrier(allocation->metadata[next].resource, resource_usage::unordered_access, resource_usage::shader_resource);
    }
    last_frame_ = frame_number; width_ = width; height_ = height; view_identity_ = view_identity; history_index_ = next;
    return allocation->visibility.srv;
  }

 private:
  struct Surface { resource resource = {}; resource_view srv = {}, uav = {}; };
  struct Allocation {
    uint32_t width = 0, height = 0;
    bool valid = false;
    std::array<Surface, 4> textures;
    std::array<Surface, 2> metadata;
    Surface visibility;
  };
  void Destroy(const Surface& surface) {
    if (surface.srv.handle) dev_->destroy_resource_view(surface.srv);
    if (surface.uav.handle) dev_->destroy_resource_view(surface.uav);
    if (surface.resource.handle) dev_->destroy_resource(surface.resource);
  }
  bool Texture(uint32_t width, uint32_t height, format format, Surface* output, const subresource_data* initial = nullptr) {
    if (!dev_->create_resource(resource_desc(width, height, 1, 1, format, 1, memory_heap::gpu_only,
            resource_usage::shader_resource | resource_usage::unordered_access), initial, resource_usage::shader_resource, &output->resource)) return false;
    resource_view_desc view(format); view.type = resource_view_type::texture_2d; view.texture = {0, 1, 0, 1};
    return dev_->create_resource_view(output->resource, resource_usage::shader_resource, view, &output->srv)
        && dev_->create_resource_view(output->resource, resource_usage::unordered_access, view, &output->uav);
  }
  bool Buffer(uint64_t bytes, Surface* output) {
    resource_desc desc(bytes, memory_heap::gpu_only, resource_usage::shader_resource | resource_usage::unordered_access);
    if (!dev_->create_resource(desc, nullptr, resource_usage::shader_resource, &output->resource)) return false;
    const resource_view_desc view(format::r32_typeless, uint64_t(0), bytes / 4);
    return dev_->create_resource_view(output->resource, resource_usage::shader_resource, view, &output->srv)
        && dev_->create_resource_view(output->resource, resource_usage::unordered_access, view, &output->uav);
  }
  device* dev_;
  pipeline_layout layout_ = {};
  std::array<pipeline, 5> passes_ = {};
  Surface missing_motion_, missing_motion_depth_;
  std::vector<std::unique_ptr<Allocation>> allocations_;
  uint64_t last_frame_ = UINT64_MAX, view_identity_ = 0;
  uint32_t history_index_ = 0, width_ = 0, height_ = 0;
  bool attempted_ = false, initialized_ = false;
};
}  // namespace witcher3graphics::contact
