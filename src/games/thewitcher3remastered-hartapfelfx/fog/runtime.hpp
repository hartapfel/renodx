// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <wrl/client.h>
#include <cmath>
#include <cstring>
#include <deque>
#include "../../../utils/d3d12_resource_pool.hpp"
#include "../raster.hpp"
#include "../shared.h"
#include "bindings.hpp"
#include "settings.hpp"
#include "fast_noise.hpp"

namespace hartapfelfx::fog::runtime {
using Microsoft::WRL::ComPtr;
namespace pool = renodx::utils::d3d12_resource_pool;
inline ShaderInjectData* settings = nullptr;
struct Job;
struct Views {
  std::weak_ptr<Job> job;
  uint32_t recording_owners = 0;
  bool quarantined = false;
  std::weak_ptr<pool::Allocation> allocation;
  ComPtr<ID3D12Resource> resource;
  D3D12_RESOURCE_STATES state = D3D12_RESOURCE_STATE_UNORDERED_ACCESS;
};
struct Pipelines {
  ComPtr<ID3D12PipelineState> graphics, integrate, compute, local_rt, local_raster, temporal, interior;
};
struct __declspec(uuid("01a25de0-e89c-7864-a4f1-1790756c20d0")) DeviceData {
  std::mutex mutex;
  pool::ResourcePool<768ull << 20, 1024> allocations;
  std::unordered_map<uint64_t, Views> views;
  std::unordered_map<uint64_t, Pipelines> pipelines;
  std::vector<api::command_queue*> queues;
  std::deque<std::shared_ptr<Job>> volumes, interiors, active;
  uint64_t sequence = 0;
  ComPtr<ID3D12Resource> fast, zero;
};
struct Job {
  std::shared_ptr<pool::Allocation> allocation;
  std::shared_ptr<pool::Allocation> parameters;
  api::buffer_range frame{};
  api::viewport viewport{};
  uint32_t width = 0, height = 0, slices = 0;
  std::shared_ptr<Job> history, storage;
};
struct __declspec(uuid("01a25de1-207b-74da-8bb1-cf08fdd988c6")) CommandData {
  std::vector<std::shared_ptr<pool::Allocation>> recording;
  std::vector<std::shared_ptr<pool::Queue>> queues;
  bool untracked = false;
  std::vector<std::shared_ptr<Job>> history_refs;
};
struct __declspec(uuid("01a25de1-693c-727b-bd62-c2b9c2f56380")) QueueData {
  std::shared_ptr<pool::Queue> queue;
};
// Every private resource is a root buffer descriptor. Never switch native
// descriptor heaps, replace the application's root signature, or borrow slots.
inline int RootIndex(api::command_list* cmd, api::pipeline_layout layout, api::descriptor_type type, uint32_t slot, uint32_t space) {
  auto* data = renodx::utils::data::Get<fog::DeviceData>(cmd->get_device());
  if (!data) return -1;
  std::shared_lock lock(data->mutex);
  const auto found = data->layouts.find(layout.handle);
  if (found == data->layouts.end()) return -1;
  for (uint32_t i = 0; i < found->second.parameters.size(); ++i) {
    const auto& param = found->second.parameters[i];
    if (param.table) continue;
    for (const auto& range : param.ranges)
      if (range.type == type && range.dx_register_index == slot && range.dx_register_space == space && range.count == 1) return int(i);
  }
  return -1;
}
inline ID3D12PipelineState* Pipeline(api::command_list* cmd, DeviceData* data, api::pipeline_layout layout, bool compute, bool integrate, bool local_pass, bool raster, bool temporal, bool interior) {
  auto* device = reinterpret_cast<ID3D12Device*>(cmd->get_device()->get_native());
  auto& entry = data->pipelines[layout.handle];
  if (compute) {
    auto& target = local_pass ? (raster ? entry.local_raster : entry.local_rt) : entry.compute;
    if (!target) {
      D3D12_COMPUTE_PIPELINE_STATE_DESC desc{};
      desc.pRootSignature = reinterpret_cast<ID3D12RootSignature*>(layout.handle);
      desc.CS = {__0xF7F00003.data(), __0xF7F00003.size()};
      if (local_pass) desc.CS = raster ? D3D12_SHADER_BYTECODE{__0xF7F00006.data(), __0xF7F00006.size()} : D3D12_SHADER_BYTECODE{__0xF7F00005.data(), __0xF7F00005.size()};
      if (FAILED(device->CreateComputePipelineState(&desc, IID_PPV_ARGS(target.GetAddressOf())))) return nullptr;
    }
    return target.Get();
  }
  auto& target = interior ? entry.interior : (temporal ? entry.temporal : (integrate ? entry.integrate : entry.graphics));
  if (!target) {
    D3D12_GRAPHICS_PIPELINE_STATE_DESC desc{};
    desc.pRootSignature = reinterpret_cast<ID3D12RootSignature*>(layout.handle);
    desc.VS = {__0xF7F00001.data(), __0xF7F00001.size()};
    desc.PS = integrate ? D3D12_SHADER_BYTECODE{__0xF7F00004.data(), __0xF7F00004.size()} : D3D12_SHADER_BYTECODE{__0xF7F00002.data(), __0xF7F00002.size()};
    if (temporal) desc.PS = {__0xF7F00007.data(), __0xF7F00007.size()};
    if (interior) desc.PS = {__0xF7F00008.data(), __0xF7F00008.size()};
    desc.RasterizerState.FillMode = D3D12_FILL_MODE_SOLID;
    desc.RasterizerState.CullMode = D3D12_CULL_MODE_NONE;
    desc.RasterizerState.DepthClipEnable = TRUE;
    desc.SampleMask = UINT_MAX;
    desc.SampleDesc.Count = 1;
    desc.PrimitiveTopologyType = D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE;
    desc.DepthStencilState.DepthFunc = D3D12_COMPARISON_FUNC_ALWAYS;
    desc.DepthStencilState.FrontFace = {D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_COMPARISON_FUNC_ALWAYS};
    desc.DepthStencilState.BackFace = desc.DepthStencilState.FrontFace;
    for (auto& target : desc.BlendState.RenderTarget) {
      target.SrcBlend = target.SrcBlendAlpha = D3D12_BLEND_ONE;
      target.DestBlend = target.DestBlendAlpha = D3D12_BLEND_ZERO;
      target.BlendOp = target.BlendOpAlpha = D3D12_BLEND_OP_ADD;
      target.LogicOp = D3D12_LOGIC_OP_NOOP;
      target.RenderTargetWriteMask = D3D12_COLOR_WRITE_ENABLE_ALL;
    }
    if (FAILED(device->CreateGraphicsPipelineState(&desc, IID_PPV_ARGS(target.GetAddressOf())))) return nullptr;
  }
  return target.Get();
}
inline bool DrawVolume(api::command_list* cmd, DeviceData* device_data, Job* job, bool compute, bool integrate, bool local_pass = false, bool raster = false, bool temporal = false, bool interior = false) {
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  auto* state = hartapfelfx::raster::Get(cmd);
  auto* shaders = renodx::utils::shader::GetCurrentState(cmd);
  if (!bindings || !state || !shaders) return false;
  const auto* native_stage = (compute ? renodx::utils::shader::GetCurrentComputeState(shaders)
                                      : renodx::utils::shader::GetCurrentPixelState(shaders));
  const api::pipeline native_pipeline = native_stage->pipeline;
  if (!native_pipeline.handle) return false;
  auto layout = compute ? bindings->compute.layout : bindings->graphics.layout;
  int output = RootIndex(cmd, layout, api::descriptor_type::buffer_unordered_access_view, 0, 71);
  int parameters = RootIndex(cmd, layout, api::descriptor_type::constant_buffer, 3, 71);
  int injection = RootIndex(cmd, layout, api::descriptor_type::constant_buffer, 0, 70);
  int fast = RootIndex(cmd, layout, api::descriptor_type::buffer_shader_resource_view, 2, 71);
  int history = RootIndex(cmd, layout, api::descriptor_type::buffer_shader_resource_view, 1, 71);
  if (output < 0 || parameters < 0 || injection < 0 || fast < 0 || history < 0 || !device_data->fast || !device_data->zero) return false;
  if (!compute && (state->viewports.empty() || state->scissor_rects.empty() || state->primitive_topology == api::primitive_topology::undefined)) return false;
  auto* pipeline = Pipeline(cmd, device_data, layout, compute, integrate, local_pass, raster, temporal, interior);
  if (!pipeline) return false;
  const auto& parameters_allocation = job->parameters ? job->parameters : job->allocation;
  for (IUnknown* object : {static_cast<IUnknown*>(pipeline), reinterpret_cast<IUnknown*>(layout.handle)})
    if (std::none_of(parameters_allocation->objects.begin(), parameters_allocation->objects.end(), [object](const auto& retained) { return retained.Get() == object; }))
      parameters_allocation->objects.push_back(ComPtr<IUnknown>(object));
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  const int cloud_root = RootIndex(cmd, layout, api::descriptor_type::buffer_shader_resource_view, 0, 72);
  if (cloud_root >= 0) {
    const uint64_t cloud = fog::cloud_source ? fog::cloud_source(cmd, compute) : 0;
    if (compute) native->SetComputeRootShaderResourceView(cloud_root, cloud ? cloud : device_data->zero->GetGPUVirtualAddress());
    else native->SetGraphicsRootShaderResourceView(cloud_root, cloud ? cloud : device_data->zero->GetGPUVirtualAddress());
  }
  auto& views = device_data->views.at(job->allocation->scratch->GetGPUVirtualAddress());
  if (views.state != D3D12_RESOURCE_STATE_UNORDERED_ACCESS) {
    D3D12_RESOURCE_BARRIER barrier{};
    barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    barrier.Transition = {job->allocation->scratch.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, views.state, D3D12_RESOURCE_STATE_UNORDERED_ACCESS};
    native->ResourceBarrier(1, &barrier);
    views.state = D3D12_RESOURCE_STATE_UNORDERED_ACCESS;
  } else if (integrate || local_pass || temporal) {
    D3D12_RESOURCE_BARRIER barrier{};
    barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_UAV;
    barrier.UAV.pResource = job->allocation->scratch.Get();
    native->ResourceBarrier(1, &barrier);
  }
  native->SetPipelineState(pipeline);
  if (compute) {
    native->SetComputeRootUnorderedAccessView(output, job->allocation->scratch->GetGPUVirtualAddress());
    native->SetComputeRootConstantBufferView(parameters, parameters_allocation->constants->GetGPUVirtualAddress() + 256);
    native->SetComputeRootConstantBufferView(injection, parameters_allocation->constants->GetGPUVirtualAddress());
    native->SetComputeRootShaderResourceView(fast, device_data->fast->GetGPUVirtualAddress());
    native->SetComputeRootShaderResourceView(history, job->history ? job->history->allocation->scratch->GetGPUVirtualAddress() : device_data->zero->GetGPUVirtualAddress());
    native->Dispatch((job->width + 3) / 4, (job->height + 3) / 4, (job->slices + 3) / 4);
  } else {
    native->SetGraphicsRootUnorderedAccessView(output, job->allocation->scratch->GetGPUVirtualAddress());
    native->SetGraphicsRootConstantBufferView(parameters, parameters_allocation->constants->GetGPUVirtualAddress() + (interior ? 768 : (integrate ? 512 : 256)));
    native->SetGraphicsRootConstantBufferView(injection, parameters_allocation->constants->GetGPUVirtualAddress());
    native->SetGraphicsRootShaderResourceView(fast, device_data->fast->GetGPUVirtualAddress());
    native->SetGraphicsRootShaderResourceView(history, job->history ? job->history->allocation->scratch->GetGPUVirtualAddress() : device_data->zero->GetGPUVirtualAddress());
    const D3D12_VIEWPORT viewport{0, 0, float(job->width * ((integrate || interior) ? 1 : 8)), float(job->height * ((integrate || interior) ? 1 : (job->slices + 7) / 8)), 0, 1};
    const D3D12_RECT scissor{0, 0, LONG(viewport.Width), LONG(viewport.Height)};
    native->RSSetViewports(1, &viewport);
    native->RSSetScissorRects(1, &scissor);
    native->OMSetRenderTargets(0, nullptr, FALSE, nullptr);
    native->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    native->DrawInstanced(3, 1, 0, 0);
    cmd->bind_render_targets_and_depth_stencil(uint32_t(state->render_targets.size()), state->render_targets.data(), state->depth_stencil);
    cmd->bind_viewports(0, uint32_t(state->viewports.size()), state->viewports.data());
    cmd->bind_scissor_rects(0, uint32_t(state->scissor_rects.size()), state->scissor_rects.data());
    cmd->bind_pipeline_state(api::dynamic_state::primitive_topology, uint32_t(state->primitive_topology));
  }
  // Only private roots were touched; all native/HDR roots and heaps remain bound.
  native->SetPipelineState(reinterpret_cast<ID3D12PipelineState*>(native_pipeline.handle));
  {
    D3D12_RESOURCE_BARRIER barrier{};
    barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    barrier.Transition = {job->allocation->scratch.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE};
    native->ResourceBarrier(1, &barrier);
    views.state = D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE;
  }
  return true;
}
inline bool AllocateJob(api::command_list* cmd, DeviceData* data, const std::shared_ptr<Job>& job, uint64_t bytes, bool parameters = false) {
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  if (!command) return false;
  for (auto& [address, view] : data->views)
    if (auto allocation = view.allocation.lock()) allocation->leased = view.quarantined || view.recording_owners > 0 || !view.job.expired();
  auto& allocation = parameters ? job->parameters : job->allocation;
  allocation = data->allocations.Acquire(reinterpret_cast<ID3D12Device*>(cmd->get_device()->get_native()), bytes);
  if (!allocation) return false;
  command->recording.push_back(allocation);
  for (auto it = data->views.begin(); it != data->views.end();) {
    if (it->second.allocation.expired()) {
      it = data->views.erase(it);
    } else
      ++it;
  }
  auto& views = data->views[allocation->scratch->GetGPUVirtualAddress()];
  if (!views.resource) {
    views.allocation = allocation;
    views.resource = allocation->scratch;
  }
  views.job = job;
  ++views.recording_owners;
  return true;
}
// GPU storage is shared by a native view. Its contents follow the application's
// graphics-queue order, including when command lists are recorded ahead or split.
// Only small, immutable parameter pages belong to individual recordings.
inline void RetainStorage(api::command_list* cmd, const std::shared_ptr<Job>& job) {
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  if (std::find(command->history_refs.begin(), command->history_refs.end(), job) == command->history_refs.end())
    command->history_refs.push_back(job);
}
inline void CopyStorage(api::command_list* cmd, DeviceData* data, const std::shared_ptr<Job>& destination,
                        const std::shared_ptr<Job>& source, uint64_t bytes, uint64_t offset = 0) {
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  auto& input = data->views.at(source->allocation->scratch->GetGPUVirtualAddress());
  auto& output = data->views.at(destination->allocation->scratch->GetGPUVirtualAddress());
  D3D12_RESOURCE_BARRIER barriers[2]{};
  for (auto& barrier : barriers) barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
  barriers[0].Transition = {source->allocation->scratch.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, input.state, D3D12_RESOURCE_STATE_COPY_SOURCE};
  barriers[1].Transition = {destination->allocation->scratch.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, output.state, D3D12_RESOURCE_STATE_COPY_DEST};
  native->ResourceBarrier(2, barriers);
  native->CopyBufferRegion(destination->allocation->scratch.Get(), offset, source->allocation->scratch.Get(), 0, bytes);
  barriers[0].Transition.StateBefore = D3D12_RESOURCE_STATE_COPY_SOURCE;
  barriers[1].Transition.StateBefore = D3D12_RESOURCE_STATE_COPY_DEST;
  barriers[0].Transition.StateAfter = barriers[1].Transition.StateAfter = D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE;
  native->ResourceBarrier(2, barriers);
  input.state = output.state = D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE;
  RetainStorage(cmd, source);
  RetainStorage(cmd, destination);
}
inline std::shared_ptr<Job> FindVolume(DeviceData* data, const api::buffer_range& frame, const api::viewport* viewport) {
  for (auto it = data->volumes.rbegin(); it != data->volumes.rend(); ++it) {
    const auto grid=GridQuality(*settings,(*it)->viewport.width,(*it)->viewport.height);
    if ((*it)->frame.buffer == frame.buffer && (*it)->frame.offset == frame.offset
        && (*it)->width==grid[0] &&(*it)->height==grid[1] &&(*it)->slices==grid[2]
        && (!viewport || MatchesFogViewport(*viewport, (*it)->viewport))) return *it;
  }
  return {};
}
inline std::shared_ptr<Job> BeginWork(api::command_list* cmd, DeviceData* data, const std::shared_ptr<Job>& storage) {
  auto job = std::make_shared<Job>(*storage);
  job->storage = storage;
  job->parameters.reset();
  if (!AllocateJob(cmd, data, job, 16, true)) return {};
  RetainStorage(cmd, storage);
  RetainStorage(cmd, job->history);
  std::memcpy(job->parameters->mapped, settings, sizeof(*settings));
  const uint32_t grid[8] = {job->width, job->height, job->slices, 0, 0, uint32_t(++data->sequence & 31u), 1, 0};
  std::memcpy(job->parameters->mapped + 256, grid, sizeof(grid));
  uint32_t integration[8];
  std::memcpy(integration, grid, sizeof(grid));
  integration[3] = 1;
  std::memcpy(job->parameters->mapped + 512, integration, sizeof(integration));
  std::erase_if(data->active, [&](const auto& old) { return old->storage == storage; });
  data->active.push_back(job);
  while (data->active.size() > 4) data->active.pop_front();
  return job;
}
inline void CaptureInterior(api::command_list* cmd) {
  if (!settings || settings->enabled < .5f || cmd->get_device()->get_api() != api::device_api::d3d12) return;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  if (!data || !bindings || reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native())->GetType() != D3D12_COMMAND_LIST_TYPE_DIRECT) return;
  const auto frame = Resolve(cmd, bindings->graphics, api::descriptor_type::constant_buffer, 12);
  const auto input = Resolve(cmd, bindings->graphics, api::descriptor_type::texture_shader_resource_view, 24);
  const auto lighting = Resolve(cmd, bindings->graphics, api::descriptor_type::constant_buffer, 13);
  if (frame.type != api::descriptor_type::constant_buffer || !frame.buffer_range.buffer.handle || frame.buffer_range.size < 341u * 16u
      || !input.HasResourceView() || !input.resource_view.handle || lighting.type != api::descriptor_type::constant_buffer
      || !lighting.buffer_range.buffer.handle || lighting.buffer_range.size < 34u * 16u) return;
  const auto view = cmd->get_device()->get_resource_view_desc(input.resource_view);
  if (view.type != api::resource_view_type::texture_2d || (view.format != api::format::r16g16_float && view.format != api::format::r32g32_float)) return;
  const auto desc = cmd->get_device()->get_resource_desc(cmd->get_device()->get_resource_from_view(input.resource_view));
  if (!desc.texture.width || !desc.texture.height) return;
  std::lock_guard lock(data->mutex);
  std::shared_ptr<Job> job;
  for (const auto& cached : data->interiors)
    if (cached->frame.buffer == frame.buffer_range.buffer && cached->frame.offset == frame.buffer_range.offset) job = cached;
  if (!job) {
    job = std::make_shared<Job>();
    job->frame = frame.buffer_range;
    // Fixed capture dimensions keep its upload page immutable across frames and
    // let Balanced/High generation resample the same GPU-ordered interval cache.
    job->width = 240;
    job->height = 256;
    if (!AllocateJob(cmd, data, job, 128ull + uint64_t(job->width) * job->height * 8)) return;
    const uint32_t grid[8] = {job->width, job->height, 0, 0, 0, 0, 0, 0};
    std::memcpy(job->allocation->mapped + 768, grid, sizeof(grid));
    data->interiors.push_back(job);
    while (data->interiors.size() > 4) data->interiors.pop_front();
  }
  RetainStorage(cmd, job);
  if (DrawVolume(cmd, data, job.get(), false, false, false, false, false, true)) ++fog::interior_captures;
}
inline void Generate(api::command_list* cmd, bool compute) {
  if (!settings || settings->enabled < .5f || cmd->get_device()->get_api() != api::device_api::d3d12) return;
  if (reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native())->GetType() != D3D12_COMMAND_LIST_TYPE_DIRECT) return;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  if (!data || !command || !bindings) return;
  const auto depth = Resolve(cmd, compute ? bindings->compute : bindings->graphics, api::descriptor_type::texture_shader_resource_view, 0);
  if (!depth.HasResourceView() || !depth.resource_view.handle) return;
  const auto desc = cmd->get_device()->get_resource_desc(cmd->get_device()->get_resource_from_view(depth.resource_view));
  if (desc.type != api::resource_type::texture_2d || !desc.texture.width || !desc.texture.height) return;
  api::viewport viewport{0, 0, float(desc.texture.width), float(desc.texture.height), 0, 1};
  if (!compute) {
    auto* state = hartapfelfx::raster::Get(cmd);
    if (!state || state->viewports.empty()) return;
    viewport = state->viewports.front();
  }
  if (!(viewport.width > 0.f && viewport.height > 0.f)) return;
  std::lock_guard lock(data->mutex);
  // Retire cached budgets after a quality edit. Recordings still retain their
  // allocations; unused old budgets must not permanently fill the pool.
  const auto incompatible=[](const std::shared_ptr<Job>& job) {
    const auto grid=GridQuality(*settings,job->viewport.width,job->viewport.height);
    return job->width!=grid[0] ||job->height!=grid[1] ||job->slices!=grid[2];
  };
  std::erase_if(data->active,incompatible);
  std::erase_if(data->volumes,incompatible);
  auto storage = FindVolume(data, bindings->sun.frame, &viewport);
  if (!storage) {
    // Bound the view cache. Recordings retain immutable parameter pages and
    // references, never a full volume each.
    if (data->volumes.size() == 4) {
      std::erase_if(data->active, [&](const auto& old) { return old->storage == data->volumes.front(); });
      data->volumes.pop_front();
    }
    storage = std::make_shared<Job>();
    storage->frame = bindings->sun.frame;
    storage->viewport = viewport;
    const auto grid=GridQuality(*settings,viewport.width,viewport.height);
    storage->width=grid[0];storage->height=grid[1];storage->slices=grid[2];
    const uint64_t cells = uint64_t(storage->width) * storage->height * storage->slices;
    if (!AllocateJob(cmd, data, storage, FOG_HEADER_BYTES + (3 * cells + uint64_t(storage->width) * storage->height) * 8 + 128 + 240 * 256 * 8)) return;
    storage->history = std::make_shared<Job>();
    if (!AllocateJob(cmd, data, storage->history, FOG_HEADER_BYTES + 2 * cells * 8)) return;
    auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
    auto& view = data->views.at(storage->allocation->scratch->GetGPUVirtualAddress());
    D3D12_RESOURCE_BARRIER barrier{};
    barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    barrier.Transition = {storage->allocation->scratch.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, view.state, D3D12_RESOURCE_STATE_COPY_DEST};
    native->ResourceBarrier(1, &barrier);
    // A reused pool allocation can contain a valid marker from another view.
    native->CopyBufferRegion(storage->allocation->scratch.Get(), 0, data->zero.Get(), 0, FOG_HEADER_BYTES);
    barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_COPY_DEST;
    barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE;
    native->ResourceBarrier(1, &barrier);
    view.state = D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE;
    data->volumes.push_back(storage);
  }
  auto job = BeginWork(cmd, data, storage);
  if (!job) return;
  // Save the preceding resolved field before generation overwrites its header.
  // A GPU completion marker rejects first-use and unfinished fields.
  CopyStorage(cmd, data, job->history, storage, FOG_HEADER_BYTES + uint64_t(job->width) * job->height * job->slices * 16);
  uint32_t flags = 0;
  for (const auto& interiors : data->interiors) {
    if (interiors->frame.buffer != job->frame.buffer || interiors->frame.offset != job->frame.offset) continue;
    CopyStorage(cmd, data, storage, interiors, 128ull + uint64_t(interiors->width) * interiors->height * 8,
                FOG_HEADER_BYTES + uint64_t(job->width) * job->height * (3 * job->slices + 1) * 8);
    flags |= 4u;
    ++fog::interior_matches;
    break;
  }
  const auto& source_bindings = compute ? bindings->compute : bindings->graphics;
  for (auto [slot, flag] : {std::pair{19u, 1u}, std::pair{14u, 2u}}) {
    const auto input = Resolve(cmd, source_bindings, api::descriptor_type::texture_shader_resource_view, slot);
    if (input.HasResourceView() && input.resource_view.handle
        && cmd->get_device()->get_resource_view_desc(input.resource_view).type == api::resource_view_type::texture_2d_array) flags |= flag;
  }
  std::memcpy(job->parameters->mapped + 272, &flags, sizeof(flags));
  DrawVolume(cmd, data, job.get(), compute, false);
}
inline bool Prepare(api::command_list* cmd) {
  if (reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native())->GetType() != D3D12_COMMAND_LIST_TYPE_DIRECT) return false;
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* state = hartapfelfx::raster::Get(cmd);
  if (!data || !command || !bindings || !state || state->viewports.empty()) return false;
  const auto frame = Resolve(cmd, bindings->graphics, api::descriptor_type::constant_buffer, 12);
  if (frame.type != api::descriptor_type::constant_buffer) return false;
  std::lock_guard lock(data->mutex);
  auto storage = FindVolume(data, frame.buffer_range, &state->viewports.front());
  if (!storage) return false;
  auto job = BeginWork(cmd, data, storage);
  if (!job || !DrawVolume(cmd, data, job.get(), false, false, false, false, true)
      || !DrawVolume(cmd, data, job.get(), false, true)) return false;
  const int source = RootIndex(cmd, bindings->graphics.layout, api::descriptor_type::buffer_shader_resource_view, 0, 71);
  const int injection = RootIndex(cmd, bindings->graphics.layout, api::descriptor_type::constant_buffer, 0, 70);
  if (source < 0 || injection < 0) return false;
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  native->SetGraphicsRootShaderResourceView(source, job->allocation->scratch->GetGPUVirtualAddress());
  native->SetGraphicsRootConstantBufferView(injection, job->parameters->constants->GetGPUVirtualAddress());
  return true;
}
inline bool PrepareReceiver(api::command_list* cmd, uint64_t* address = nullptr) {
  if (reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native())->GetType() != D3D12_COMMAND_LIST_TYPE_DIRECT) return false;
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* state = hartapfelfx::raster::Get(cmd);
  if (!command || !bindings || !data || !state || state->viewports.empty()) return false;
  const auto frame = Resolve(cmd, bindings->graphics, api::descriptor_type::constant_buffer, 12);
  if (frame.type != api::descriptor_type::constant_buffer) return false;
  std::lock_guard lock(data->mutex);
  auto storage = FindVolume(data, frame.buffer_range, &state->viewports.front());
  if (!storage) return false;
  std::shared_ptr<Job> job;
  for (const auto& work : data->active) if (work->storage == storage) job = work;
  if (!job) return false;
  const int source = RootIndex(cmd, bindings->graphics.layout, api::descriptor_type::buffer_shader_resource_view, 0, 71);
  const int injection = RootIndex(cmd, bindings->graphics.layout, api::descriptor_type::constant_buffer, 0, 70);
  if (source < 0 || injection < 0) return false;
  RetainStorage(cmd, storage);
  // Keep the exact upload allocation alive through this receiver recording.
  if (std::find(command->history_refs.begin(), command->history_refs.end(), job) == command->history_refs.end()) command->history_refs.push_back(job);
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  native->SetGraphicsRootShaderResourceView(source, job->allocation->scratch->GetGPUVirtualAddress());
  native->SetGraphicsRootConstantBufferView(injection, job->parameters->constants->GetGPUVirtualAddress());
  if (address) *address = job->allocation->scratch->GetGPUVirtualAddress();
  return true;
}
inline void ApplyLocal(api::command_list* cmd, bool raster) {
  if (reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native())->GetType() != D3D12_COMMAND_LIST_TYPE_DIRECT) return;
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if (!bindings || !data || !settings || settings->enabled < .5f) return;
  const auto frame = Resolve(cmd, bindings->compute, api::descriptor_type::constant_buffer, 12);
  if (frame.type != api::descriptor_type::constant_buffer) return;
  const auto depth = Resolve(cmd, bindings->compute, api::descriptor_type::texture_shader_resource_view, 0);
  if (!depth.HasResourceView() || !depth.resource_view.handle) return;
  const auto desc = cmd->get_device()->get_resource_desc(cmd->get_device()->get_resource_from_view(depth.resource_view));
  if (!IsFogDepthInput(desc, cmd->get_device()->get_resource_view_desc(depth.resource_view))) return;
  // Photo mode can allocate another volume for the same frame CBV. Cache order
  // does not identify the current view, and the graphics viewport may still
  // belong to an intervening shadow pass. Use the native scene depth instead.
  const api::viewport viewport{0, 0, float(desc.texture.width), float(desc.texture.height), 0, 1};
  std::lock_guard lock(data->mutex);
  auto storage = FindVolume(data, frame.buffer_range, &viewport);
  if (!storage) return;
  auto job = BeginWork(cmd, data, storage);
  if (!job || !DrawVolume(cmd, data, job.get(), true, false, true, raster)) return;
  // Mark after the whole dispatch. Every cell sees the same pre-dispatch flag.
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  D3D12_RESOURCE_BARRIER barrier{};
  barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
  barrier.Transition = {job->allocation->scratch.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE, D3D12_RESOURCE_STATE_COPY_DEST};
  native->ResourceBarrier(1, &barrier);
  native->CopyBufferRegion(job->allocation->scratch.Get(), 1012, job->parameters->constants.Get(), 0, 4);
  std::swap(barrier.Transition.StateBefore, barrier.Transition.StateAfter);
  native->ResourceBarrier(1, &barrier);
}
inline ComPtr<ID3D12Resource> UploadData(ID3D12Device* device, const void* bytes, uint64_t size) {
  D3D12_HEAP_PROPERTIES heap{};
  heap.Type = D3D12_HEAP_TYPE_UPLOAD;
  D3D12_RESOURCE_DESC desc{};
  desc.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
  desc.Width = size;
  desc.Height = desc.DepthOrArraySize = desc.MipLevels = desc.SampleDesc.Count = 1;
  desc.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
  ComPtr<ID3D12Resource> buffer;
  if (FAILED(device->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_NONE, &desc, D3D12_RESOURCE_STATE_GENERIC_READ, nullptr, IID_PPV_ARGS(&buffer)))) return {};
  void* mapped = nullptr;
  const D3D12_RANGE empty{0, 0};
  if (FAILED(buffer->Map(0, &empty, &mapped))) return {};
  std::memcpy(mapped, bytes, size);
  buffer->Unmap(0, nullptr);
  return buffer;
}
inline void OnInitDevice(api::device* device) {
  auto* data = renodx::utils::data::Create<DeviceData>(device);
  if (device->get_api() != api::device_api::d3d12) return;
  auto* native = reinterpret_cast<ID3D12Device*>(device->get_native());
  data->fast = UploadData(native, witcher3classic::clouds::fast_noise, sizeof(witcher3classic::clouds::fast_noise));
  const std::array<uint8_t, FOG_HEADER_BYTES> zero{};
  data->zero = UploadData(native, zero.data(), zero.size());
}
inline void OnDestroyDevice(api::device* device) {
  auto* data = renodx::utils::data::Get<DeviceData>(device);
  if (data) {
    std::lock_guard lock(data->mutex);
    for (auto* queue : data->queues) queue->wait_idle();
    // Persistent upload mappings may last until resource release. Avoid calling
    // back into native Map/Unmap hooks during the device-destruction callback.
    for (const auto& allocation : data->allocations.allocations) allocation->mapped = nullptr;
  }
  // Releasing cached roots can synchronously invoke destroy_pipeline_layout.
  // Detach first so those callbacks cannot enter a partly destroyed cache.
  device->set_private_data(reinterpret_cast<const uint8_t*>(&renodx::utils::data::GetUuid<DeviceData>()), 0);
  delete data;
}
inline void OnInitCommandList(api::command_list* cmd) { renodx::utils::data::Create<CommandData>(cmd); }
inline void OnResetCommandList(api::command_list* cmd) {
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  if (!command || (command->recording.empty() && command->history_refs.empty())) return;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if (!data || !command) return;
  std::lock_guard lock(data->mutex);
  ++data->allocations.frame;
  std::vector<pool::Completion> completion;
  for (const auto& queue : command->queues) {
    uint64_t serial = queue->serial;
    if (queue->native) {
      serial = ++queue->serial;
      if (FAILED(queue->native->Signal(queue->fence.Get(), serial))) serial = UINT64_MAX;
    }
    completion.push_back({queue->fence, serial});
  }
  auto retire = [&](const std::shared_ptr<pool::Allocation>& allocation, bool owner) {
    auto& view = data->views.at(allocation->scratch->GetGPUVirtualAddress());
    std::erase_if(allocation->completion, [](const auto& point) { return point.value != UINT64_MAX && point.fence->GetCompletedValue() >= point.value; });
    allocation->completion.insert(allocation->completion.end(), completion.begin(), completion.end());
    view.quarantined |= command->untracked;
    if (owner && view.recording_owners > 0) --view.recording_owners;
    allocation->idle_frame = data->allocations.frame;
  };
  for (const auto& allocation : command->recording) retire(allocation, true);
  for (const auto& previous : command->history_refs) {
    retire(previous->allocation, false);
    if (previous->parameters) retire(previous->parameters, false);
  }
  command->recording.clear();
  command->history_refs.clear();
  command->queues.clear();
  for (auto& [address, view] : data->views)
    if (auto allocation = view.allocation.lock()) allocation->leased = view.quarantined || view.recording_owners > 0 || !view.job.expired();
  data->allocations.Collect();
  command->untracked = false;
}
inline void OnDestroyCommandList(api::command_list* cmd) {
  OnResetCommandList(cmd);
  renodx::utils::data::Delete<CommandData>(cmd);
}
inline void OnInitQueue(api::command_queue* queue) {
  auto* data = renodx::utils::data::Create<QueueData>(queue);
  if (queue->get_device()->get_api() != api::device_api::d3d12) return;
  data->queue = std::make_shared<pool::Queue>();
  data->queue->native = reinterpret_cast<ID3D12CommandQueue*>(queue->get_native());
  if (FAILED(reinterpret_cast<ID3D12Device*>(queue->get_device()->get_native())->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&data->queue->fence)))) data->queue.reset();
  if (auto* device = renodx::utils::data::Get<DeviceData>(queue->get_device()); device && data->queue) {
    std::lock_guard lock(device->mutex);
    device->queues.push_back(queue);
  }
}
inline void OnDestroyQueue(api::command_queue* queue) {
  auto* data = renodx::utils::data::Get<DeviceData>(queue->get_device());
  auto* q = renodx::utils::data::Get<QueueData>(queue);
  if (data && q && q->queue) {
    std::lock_guard lock(data->mutex);
    queue->wait_idle();
    if (FAILED(q->queue->native->Signal(q->queue->fence.Get(), ++q->queue->serial))) q->queue->serial = UINT64_MAX;
    q->queue->native = nullptr;
    std::erase(data->queues, queue);
  }
  renodx::utils::data::Delete<QueueData>(queue);
}
inline void OnExecute(api::command_queue* queue, api::command_list* cmd) {
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  if (!command || (command->recording.empty() && command->history_refs.empty())) return;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* q = renodx::utils::data::Get<QueueData>(queue);
  if (!data || !command) return;
  std::lock_guard lock(data->mutex);
  if (!q || !q->queue) {
    if (!command->recording.empty() || !command->history_refs.empty()) command->untracked = true;
    return;
  }
  if ((!command->recording.empty() || !command->history_refs.empty()) && std::find(command->queues.begin(), command->queues.end(), q->queue) == command->queues.end()) command->queues.push_back(q->queue);
}
inline void OnDestroyLayout(api::device* device, api::pipeline_layout layout) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(device)) {
    std::lock_guard lock(data->mutex);
    data->pipelines.erase(layout.handle);
  }
}
inline void Use(DWORD reason, ShaderInjectData* injection) {
  settings = injection;
  raster::Use(reason);
  if (reason == DLL_PROCESS_ATTACH) {
    on_sun = Generate;
    sun_enabled = &injection->enabled;
    on_interior = CaptureInterior;
    on_local = ApplyLocal;
    reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::register_event<reshade::addon_event::init_command_list>(OnInitCommandList);
    reshade::register_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
    reshade::register_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
    reshade::register_event<reshade::addon_event::init_command_queue>(OnInitQueue);
    reshade::register_event<reshade::addon_event::destroy_command_queue>(OnDestroyQueue);
    reshade::register_event<reshade::addon_event::execute_command_list>(OnExecute);
    reshade::register_event<reshade::addon_event::destroy_pipeline_layout>(OnDestroyLayout);
  } else if (reason == DLL_PROCESS_DETACH) {
    on_sun = nullptr;
    sun_enabled = nullptr;
    on_interior = nullptr;
    on_local = nullptr;
    reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::unregister_event<reshade::addon_event::init_command_list>(OnInitCommandList);
    reshade::unregister_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
    reshade::unregister_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
    reshade::unregister_event<reshade::addon_event::init_command_queue>(OnInitQueue);
    reshade::unregister_event<reshade::addon_event::destroy_command_queue>(OnDestroyQueue);
    reshade::unregister_event<reshade::addon_event::execute_command_list>(OnExecute);
    reshade::unregister_event<reshade::addon_event::destroy_pipeline_layout>(OnDestroyLayout);
  }
}
}  // namespace hartapfelfx::fog::runtime
