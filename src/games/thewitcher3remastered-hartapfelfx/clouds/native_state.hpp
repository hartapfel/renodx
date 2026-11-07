// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <d3d12.h>
#include <wrl/client.h>
#include "../fog/bindings.hpp"
#include "../../../utils/state.hpp"
#include "heaps.hpp"

namespace hartapfelfx::clouds {
namespace api = reshade::api;
// A private texture pipeline needs its own heap. Restore native root arguments
// as well as heaps, since SetDescriptorHeaps invalidates descriptor tables at
// both bind points and a different graphics signature invalidates its roots.
class NativeState {
 public:
  NativeState(api::command_list* command, api::pipeline pipeline, bool compute, api::pipeline ray_pipeline = {})
      : command_(command), native_(reinterpret_cast<ID3D12GraphicsCommandList*>(command->get_native())), pipeline_(pipeline), ray_pipeline_(ray_pipeline), active_compute_(compute) {
    const auto* bindings = renodx::utils::data::Get<fog::CommandData>(command);
    auto* layouts = renodx::utils::data::Get<fog::DeviceData>(command->get_device());
    const auto* state = renodx::utils::state::GetCurrentState(command);
    if (!bindings || !layouts || !state) return;
    graphics_ = bindings->graphics;
    compute_ = bindings->compute;
    raster_ = *state;
    graphics_arguments_ = heaps::GetArguments(command, false);
    compute_arguments_ = heaps::GetArguments(command, true);
    std::shared_lock lock(layouts->mutex);
    if (const auto found = layouts->layouts.find(graphics_.layout.handle); found != layouts->layouts.end()) graphics_layout_ = found->second;
    if (const auto found = layouts->layouts.find(compute_.layout.handle); found != layouts->layouts.end()) compute_layout_ = found->second;
    if (const auto actual = heaps::Get(command)) {
      resource_heap_ = (*actual)[0]; sampler_heap_ = (*actual)[1];
    } else return;
    const auto& active = compute ? compute_ : graphics_;
    const auto& arguments = compute ? compute_arguments_ : graphics_arguments_;
    valid_ = resource_heap_ && active.layout.handle && active.layout.handle == reinterpret_cast<uint64_t>(arguments.signature);
  }
  NativeState(const NativeState&) = delete;
  NativeState& operator=(const NativeState&) = delete;
  bool Valid() const { return valid_; }
  void Changed(bool heaps = true) { changed_ = true; heaps_changed_ = heaps; }
  ~NativeState() { Restore(); }
  void Restore() {
    if (!changed_) return;
    changed_ = false;
    ID3D12DescriptorHeap* heaps[2] = {resource_heap_.Get(), sampler_heap_.Get()};
    if (heaps_changed_) native_->SetDescriptorHeaps(sampler_heap_ ? 2 : 1, heaps);
    // Some cloud passes use compute filters while restoring a graphics draw.
    // Both bind points must regain their native signatures before root values.
    if (graphics_.layout.handle) native_->SetGraphicsRootSignature(reinterpret_cast<ID3D12RootSignature*>(graphics_.layout.handle));
    if (compute_.layout.handle) native_->SetComputeRootSignature(reinterpret_cast<ID3D12RootSignature*>(compute_.layout.handle));
    RestoreRoots(graphics_, graphics_layout_, false);
    RestoreRoots(compute_, compute_layout_, true);
    if (ray_pipeline_.handle) command_->bind_pipeline(api::pipeline_stage::all_ray_tracing, ray_pipeline_);
    else if (pipeline_.handle) native_->SetPipelineState(reinterpret_cast<ID3D12PipelineState*>(pipeline_.handle));
    command_->bind_render_targets_and_depth_stencil(uint32_t(raster_.render_targets.size()), raster_.render_targets.data(), raster_.depth_stencil);
    if (!raster_.viewports.empty()) command_->bind_viewports(0, uint32_t(raster_.viewports.size()), raster_.viewports.data());
    if (!raster_.scissor_rects.empty()) command_->bind_scissor_rects(0, uint32_t(raster_.scissor_rects.size()), raster_.scissor_rects.data());
    if (raster_.primitive_topology != api::primitive_topology::undefined)
      command_->bind_pipeline_state(api::dynamic_state::primitive_topology, uint32_t(raster_.primitive_topology));
  }

 private:
  void RestoreRoots(const fog::BindingState& bindings, const fog::BindingLayout& layout, bool compute) {
    const auto& arguments = compute ? compute_arguments_ : graphics_arguments_;
    const bool native_arguments = reinterpret_cast<uint64_t>(arguments.signature) == bindings.layout.handle;
    for (uint32_t index = 0; index < layout.parameters.size() && index < 64; ++index) {
      const auto& parameter = layout.parameters[index];
      if (parameter.table) {
        if (!bindings.tables[index].handle) continue;
        api::descriptor_heap heap{};
        uint32_t offset = 0;
        command_->get_device()->get_descriptor_heap_offset(bindings.tables[index], 0, 0, &heap, &offset);
        auto* descriptor_heap = reinterpret_cast<ID3D12DescriptorHeap*>(heap.handle);
        if (!descriptor_heap || (descriptor_heap != resource_heap_.Get() && descriptor_heap != sampler_heap_.Get())) continue;
        auto address = descriptor_heap->GetGPUDescriptorHandleForHeapStart();
        address.ptr += uint64_t(offset) * reinterpret_cast<ID3D12Device*>(command_->get_device()->get_native())->GetDescriptorHandleIncrementSize(descriptor_heap->GetDesc().Type);
        if (compute) native_->SetComputeRootDescriptorTable(index, address);
        else native_->SetGraphicsRootDescriptorTable(index, address);
      } else if (parameter.constant_count) {
        for (uint32_t word = 0; word < parameter.constant_count && word < 64; ++word) {
          const bool actual = native_arguments && (arguments.valid_words[index] & (uint64_t(1) << word));
          if (!actual && (word >= bindings.constants[index].size() || !bindings.constants[index][word].has_value())) continue;
          const uint32_t value = actual ? arguments.words[index][word] : *bindings.constants[index][word];
          if (compute) native_->SetComputeRoot32BitConstant(index, value, word);
          else native_->SetGraphicsRoot32BitConstant(index, value, word);
        }
      } else if (!parameter.ranges.empty()) {
        const auto& buffer = bindings.buffers[index];
        switch (parameter.ranges.front().type) {
          case api::descriptor_type::constant_buffer:
            if (native_arguments && arguments.cbvs[index]) {
              if (compute) native_->SetComputeRootConstantBufferView(index, arguments.cbvs[index]);
              else native_->SetGraphicsRootConstantBufferView(index, arguments.cbvs[index]);
            } else if (buffer.buffer.handle) {
              if (compute) native_->SetComputeRootConstantBufferView(index, reinterpret_cast<ID3D12Resource*>(buffer.buffer.handle)->GetGPUVirtualAddress() + buffer.offset);
              else native_->SetGraphicsRootConstantBufferView(index, reinterpret_cast<ID3D12Resource*>(buffer.buffer.handle)->GetGPUVirtualAddress() + buffer.offset);
            }
            break;
          case api::descriptor_type::buffer_shader_resource_view:
          case api::descriptor_type::acceleration_structure:
            if (compute) native_->SetComputeRootShaderResourceView(index, bindings.addresses[index]);
            else native_->SetGraphicsRootShaderResourceView(index, bindings.addresses[index]);
            break;
          case api::descriptor_type::buffer_unordered_access_view:
            if (compute) native_->SetComputeRootUnorderedAccessView(index, bindings.addresses[index]);
            else native_->SetGraphicsRootUnorderedAccessView(index, bindings.addresses[index]);
            break;
          default: break;
        }
      }
    }
  }
  api::command_list* command_;
  ID3D12GraphicsCommandList* native_;
  api::pipeline pipeline_;
  api::pipeline ray_pipeline_;
  fog::BindingState graphics_, compute_;
  heaps::Arguments graphics_arguments_, compute_arguments_;
  fog::BindingLayout graphics_layout_, compute_layout_;
  renodx::utils::state::CommandListState raster_;
  Microsoft::WRL::ComPtr<ID3D12DescriptorHeap> resource_heap_, sampler_heap_;
  bool valid_ = false, changed_ = false, active_compute_ = false;
  bool heaps_changed_ = false;
};
}  // namespace hartapfelfx::clouds
