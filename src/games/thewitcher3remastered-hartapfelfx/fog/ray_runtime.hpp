// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "../clouds/native_state.hpp"
#include "../lighting/graphics/raytracing/runtime.hpp"
#include "runtime.hpp"
#include "light_range.hpp"

namespace hartapfelfx::fog::rays {
namespace ray = witcher3graphics::raytracing;
using Roots = witcher3graphics::volumetrics::rays::ProducerRoots;
// A bounded header readback distinguishes CPU submission from GPU acceptance.
// The recording retains its destination even after reporting, so replay cannot
// write a freed resource. Queue fences are signalled after ExecuteCommandLists.
struct Diagnostic {
  Microsoft::WRL::ComPtr<ID3D12Resource> buffer;
  Microsoft::WRL::ComPtr<ID3D12Fence> fence;
  Microsoft::WRL::ComPtr<ID3D12CommandQueue> submitted;
  uint64_t serial = 0;
};
struct Capture {
  uint64_t epoch = 0;
  std::unique_ptr<clouds::NativeState> bindings;
  api::buffer_range camera{};
  api::resource depth{};
  api::pipeline pipeline{};
  Roots roots;
  D3D12_DISPATCH_RAYS_DESC dispatch{};
  uint64_t record = 0;
  std::array<uint32_t, 8> native_identifier{}, volume_identifier{};
  std::vector<Microsoft::WRL::ComPtr<IUnknown>> objects;
};
struct __declspec(uuid("fe1ce642-a9f5-4c2c-a685-71e2fa37bdbf")) CommandData {
  api::pipeline pipeline{};
  std::vector<std::shared_ptr<Capture>> captures;
  std::vector<std::shared_ptr<Diagnostic>> diagnostics;
};
struct __declspec(uuid("36535cb6-e2f7-4f46-a8ae-d97c53fe8cd1")) DeviceData {
  std::mutex mutex;
  uint64_t epoch = 0;
  // The source recording owns validity; the destination allocation leases the
  // objects it actually submits. Never reuse a previous present's inputs.
  std::vector<std::weak_ptr<Capture>> captures;
  std::vector<std::shared_ptr<Diagnostic>> diagnostics;
  uint64_t sampled_epoch = UINT64_MAX;
};
inline std::atomic_uint64_t captures = 0, dispatches = 0, unavailable = 0;
inline std::atomic_uint64_t observed = 0, missing_exports = 0, missing_frames = 0;
inline std::atomic_uint64_t missing_volume_export = 0;
inline std::atomic<const char*> last_rejection{"none"};
inline thread_local bool issuing = false;
inline void OnInitDevice(api::device* device) { renodx::utils::data::Create<DeviceData>(device); }
inline void OnDestroyDevice(api::device* device) { renodx::utils::data::Delete<DeviceData>(device); }
inline void OnPresent(api::command_queue* queue, api::swapchain*, const api::rect*, const api::rect*, uint32_t, const api::rect*) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(queue->get_device())) {
    std::lock_guard lock(data->mutex);
    std::erase_if(data->diagnostics, [](const auto& sample) {
      if (sample->submitted) {
        if (SUCCEEDED(sample->submitted->Signal(sample->fence.Get(), ++sample->serial))) sample->submitted.Reset();
        return false;
      }
      if (!sample->serial || sample->fence->GetCompletedValue() < sample->serial) return false;
      const D3D12_RANGE range{0, FOG_HEADER_BYTES};
      void* mapped = nullptr;
      if (SUCCEEDED(sample->buffer->Map(0, &range, &mapped))) {
        const auto* words = static_cast<const uint32_t*>(mapped);
        renodx::utils::log::i("HartapfelFX local ray GPU: stages=", words[1072 / 4],
                              " lights=", words[1076 / 4], " owner=", words[1064 / 4],
                              " field=", words[1016 / 4], " local=", words[1012 / 4]);
        const auto* values = static_cast<const float*>(mapped);
        renodx::utils::log::i("HartapfelFX local ray view: source=", values[1088 / 4], ",", values[1088 / 4 + 1], ",", values[1088 / 4 + 2],
                              " fog=", values[1104 / 4], ",", values[1104 / 4 + 1], ",", values[1104 / 4 + 2]);
        renodx::utils::log::i("HartapfelFX local ray native endpoints: default=", values[1120 / 4],
                              " fallback=", values[1136 / 4 + 2], " override=", words[1136 / 4]);
        const D3D12_RANGE written{0, 0};
        sample->buffer->Unmap(0, &written);
      }
      return true;
    });
    ++data->epoch;
    data->captures.clear();
    if (data->epoch % 300u == 0u)
      renodx::utils::log::i("HartapfelFX local world shadows: ", captures.load(), " native captures, ",
                            dispatches.load(), " volume dispatches, ", unavailable.load(), " missing-source skips; ",
                            observed.load(), " ray calls, ", missing_exports.load(), " missing native exports, ",
                            missing_volume_export.load(), " missing fog exports, ", missing_frames.load(), " missing frames; ", last_rejection.load());
  }
}
inline bool OnCreateLayout(api::device* device, uint32_t& count, api::pipeline_layout_param*& parameters) {
  if (device->get_api() != api::device_api::d3d12) return false;
  static thread_local std::vector<api::pipeline_layout_param> extended;
  if (!witcher3graphics::volumetrics::rays::AppendProducerRoots(count, parameters, &extended)) return false;
  parameters = extended.data();
  count = uint32_t(extended.size());
  return true;
}
inline void OnInitCommand(api::command_list* cmd) { renodx::utils::data::Create<CommandData>(cmd); }
inline void OnDestroyCommand(api::command_list* cmd) { renodx::utils::data::Delete<CommandData>(cmd); }
inline void OnResetCommand(api::command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) *data = {};
}
inline void OnExecute(api::command_queue* queue, api::command_list* cmd) {
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  auto* data = renodx::utils::data::Get<DeviceData>(queue->get_device());
  if (!command || !data || command->diagnostics.empty()) return;
  std::lock_guard lock(data->mutex);
  for (const auto& sample : command->diagnostics)
    sample->submitted = reinterpret_cast<ID3D12CommandQueue*>(queue->get_native());
}
inline void RecordDiagnostic(api::command_list* cmd, ID3D12Resource* field) {
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  std::lock_guard lock(data->mutex);
  if (data->epoch % 300u || data->sampled_epoch == data->epoch || data->diagnostics.size() >= 4) return;
  data->sampled_epoch = data->epoch;
  auto sample = std::make_shared<Diagnostic>();
  auto* device = reinterpret_cast<ID3D12Device*>(cmd->get_device()->get_native());
  D3D12_HEAP_PROPERTIES heap{};
  heap.Type = D3D12_HEAP_TYPE_READBACK;
  D3D12_RESOURCE_DESC desc{};
  desc.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
  desc.Width = FOG_HEADER_BYTES;
  desc.Height = desc.DepthOrArraySize = desc.MipLevels = desc.SampleDesc.Count = 1;
  desc.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
  if (FAILED(device->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&sample->fence)))
      || FAILED(device->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_NONE, &desc,
                                                D3D12_RESOURCE_STATE_COPY_DEST, nullptr, IID_PPV_ARGS(&sample->buffer)))) return;
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  D3D12_RESOURCE_BARRIER barrier{};
  barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
  barrier.Transition = {field, D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_COPY_SOURCE};
  native->ResourceBarrier(1, &barrier);
  native->CopyBufferRegion(sample->buffer.Get(), 0, field, 0, FOG_HEADER_BYTES);
  std::swap(barrier.Transition.StateBefore, barrier.Transition.StateAfter);
  native->ResourceBarrier(1, &barrier);
  command->diagnostics.push_back(sample);
  data->diagnostics.push_back(std::move(sample));
}
inline void OnBindPipeline(api::command_list* cmd, api::pipeline_stage stages, api::pipeline pipeline) {
  // D3D12 SetPipelineState reports pipeline_stage::all for ordinary PSOs.
  // Private cloud compute work restores DXR through the API without another
  // native event, so only an explicit SetPipelineState1 updates this cache.
  if (stages != api::pipeline_stage::all_ray_tracing) return;
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) data->pipeline = pipeline;
}
// A native SBT can arrive as a resource plus offset or an absolute GPU address.
// Retain every available backing resource through the fog submission lease.
inline bool TableAddress(api::command_list* cmd, Capture* capture, api::resource resource, uint64_t offset,
                         uint64_t bytes, uint64_t* address) {
  if (resource.handle) {
    const auto desc = cmd->get_device()->get_resource_desc(resource);
    if (desc.type != api::resource_type::buffer || offset > desc.buffer.size || bytes > desc.buffer.size - offset) return false;
    auto* native = reinterpret_cast<ID3D12Resource*>(resource.handle);
    if (native->GetGPUVirtualAddress() > UINT64_MAX - offset) return false;
    offset += native->GetGPUVirtualAddress();
    capture->objects.emplace_back(native);
  }
  *address = offset;
  return bytes == 0 || (offset && (offset & 63u) == 0);
}
inline bool OnRays(api::command_list* cmd, api::resource raygen, uint64_t raygen_offset, uint64_t raygen_size,
                   api::resource miss, uint64_t miss_offset, uint64_t miss_size, uint64_t miss_stride,
                   api::resource hit, uint64_t hit_offset, uint64_t hit_size, uint64_t hit_stride,
                   api::resource callable, uint64_t callable_offset, uint64_t callable_size, uint64_t callable_stride,
                   uint32_t, uint32_t, uint32_t) {
  if (issuing) return false;
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  const auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  auto* device = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  ++observed;
  if (!command || !bindings || !device || !command->pipeline.handle || raygen_size < 32
      || reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native())->GetType() != D3D12_COMMAND_LIST_TYPE_DIRECT) return false;
  const auto roots = witcher3graphics::volumetrics::rays::FindProducerRoots(bindings->compute.layout);
  if (!roots.Valid()) return false;
  Microsoft::WRL::ComPtr<ID3D12StateObjectProperties> properties;
  if (FAILED(reinterpret_cast<ID3D12StateObject*>(command->pipeline.handle)->QueryInterface(IID_PPV_ARGS(&properties)))) return false;
  const auto* volume_id = properties->GetShaderIdentifier(L"HartapfelVolumeLocalRGS");
  // The owned export and audited roots validate the bound state. The GPU
  // still selects the exact native ray-generation record.
  if (!volume_id) {
    ++missing_volume_export;
    return false;
  }
  std::vector<std::wstring> aliases;
  if (auto* control = renodx::utils::data::Get<ray::ControlData>(cmd->get_device())) {
    Microsoft::WRL::ComPtr<ID3D12StateObject> canonical;
    properties.As(&canonical);
    std::lock_guard lock(control->mutex);
    auto state = control->states.find(command->pipeline.handle);
    if (state == control->states.end() && canonical) state = control->states.find(reinterpret_cast<uint64_t>(canonical.Get()));
    if (state != control->states.end() && state->second.root == bindings->compute.layout.handle) aliases = state->second.fog_exports;
  }
  std::sort(aliases.begin(), aliases.end());
  aliases.erase(std::unique(aliases.begin(), aliases.end()), aliases.end());
  if (aliases.empty() || aliases.size() > 8) {
    ++missing_exports;
    return false;
  }
  const auto camera = Resolve(cmd, bindings->compute, api::descriptor_type::constant_buffer, 0, 1);
  const auto depth = Resolve(cmd, bindings->compute, api::descriptor_type::texture_shader_resource_view, 5, 1);
  if (camera.type != api::descriptor_type::constant_buffer || !camera.buffer_range.buffer.handle
      || camera.buffer_range.size < 1632u || !depth.HasResourceView() || !depth.resource_view.handle) {
    ++missing_frames;
    return false;
  }
  bool captured = false;
  for (const auto& alias : aliases) {
    const auto* native_id = properties->GetShaderIdentifier(alias.c_str());
    if (!native_id) continue;
    auto capture = std::make_shared<Capture>();
    capture->bindings = std::make_unique<clouds::NativeState>(cmd, api::pipeline{}, true, command->pipeline);
    if (!capture->bindings->Valid()) return false;
    std::memcpy(capture->native_identifier.data(), native_id, 32);
    std::memcpy(capture->volume_identifier.data(), volume_id, 32);
    capture->camera = camera.buffer_range;
    capture->roots = roots;
    capture->depth = cmd->get_device()->get_resource_from_view(depth.resource_view);
    capture->pipeline = command->pipeline;
    auto& dispatch = capture->dispatch;
    dispatch.MissShaderTable = {0, miss_size, miss_stride};
    dispatch.HitGroupTable = {0, hit_size, hit_stride};
    dispatch.CallableShaderTable = {0, callable_size, callable_stride};
    if (!TableAddress(cmd, capture.get(), raygen, raygen_offset, 32, &capture->record)
        || !TableAddress(cmd, capture.get(), miss, miss_offset, miss_size, &dispatch.MissShaderTable.StartAddress)
        || !TableAddress(cmd, capture.get(), hit, hit_offset, hit_size, &dispatch.HitGroupTable.StartAddress)
        || !TableAddress(cmd, capture.get(), callable, callable_offset, callable_size, &dispatch.CallableShaderTable.StartAddress)) return false;
    capture->bindings->RetainCompute(&capture->objects);
    capture->objects.emplace_back(reinterpret_cast<ID3D12Resource*>(capture->camera.buffer.handle));
    {
      std::lock_guard lock(device->mutex);
      capture->epoch = device->epoch;
      std::erase_if(device->captures, [](const auto& previous) { return previous.expired(); });
      device->captures.push_back(capture);
    }
    command->captures.push_back(std::move(capture));
    if (command->captures.size() > 32) command->captures.erase(command->captures.begin());
    ++captures;
    captured = true;
  }
  if (!captured) ++missing_exports;
  return false;
}

inline bool Draw(api::command_list* cmd, runtime::Job* job) {
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  const auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  auto* data = renodx::utils::data::Get<runtime::DeviceData>(cmd->get_device());
  auto* device = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if (!command || !bindings || !data || !device || !job->parameters) { last_rejection = "recording inputs"; return false; }
  const auto depth = Resolve(cmd, bindings->compute, api::descriptor_type::texture_shader_resource_view, 0);
  if (!depth.HasResourceView() || !depth.resource_view.handle) { last_rejection = "scene depth"; return false; }
  const auto depth_resource = cmd->get_device()->get_resource_from_view(depth.resource_view);
  std::vector<std::shared_ptr<Capture>> selected;
  {
    std::lock_guard lock(device->mutex);
    for (auto it = device->captures.rbegin(); it != device->captures.rend(); ++it)
      if (auto source = it->lock(); source && source->epoch == device->epoch && source->depth == depth_resource
                                    && std::none_of(selected.begin(), selected.end(), [&](const auto& previous) {
                                         return previous->record == source->record && previous->pipeline == source->pipeline
                                                && previous->native_identifier == source->native_identifier;
                                       })) selected.push_back(std::move(source));
  }
  if (selected.empty() || selected.size() > 32) {
    ++unavailable;
    last_rejection = "native ray source";
    return false;
  }
  const auto light = Resolve(cmd, bindings->compute, api::descriptor_type::constant_buffer, 13);
  // D3D12 native SRV table ranges are reflected as texture SRV ranges even
  // when an individual entry is a structured buffer. Validate the view below.
  const auto lights = Resolve(cmd, bindings->compute, api::descriptor_type::texture_shader_resource_view, 18);
  if (light.type != api::descriptor_type::constant_buffer || !light.buffer_range.buffer.handle
      || light.buffer_range.size < 68u * 16u || !lights.resource_view.handle) { last_rejection = "local light bindings"; return false; }
  const auto lights_resource = cmd->get_device()->get_resource_from_view(lights.resource_view);
  const auto lights_view = cmd->get_device()->get_resource_view_desc(lights.resource_view);
  const auto lights_desc = cmd->get_device()->get_resource_desc(lights_resource);
  if (lights_desc.type != api::resource_type::buffer) { last_rejection = "light resource type"; return false; }
  const auto light_range = DecodeLocalLightRange(lights_view, lights_desc.buffer.size);
  if (!light_range.count) { last_rejection = "structured light range"; return false; }
  auto* shader_state = renodx::utils::shader::GetCurrentState(cmd);
  const auto* compute = renodx::utils::shader::GetCurrentComputeState(shader_state);
  if (!compute || !compute->pipeline.handle) { last_rejection = "compute pipeline"; return false; }
  clouds::NativeState restore(cmd, compute->pipeline, true);
  if (!restore.Valid()) { last_rejection = "native state scope"; return false; }
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  Microsoft::WRL::ComPtr<ID3D12GraphicsCommandList4> rays;
  if (FAILED(native->QueryInterface(IID_PPV_ARGS(&rays)))) { last_rejection = "DXR command interface"; return false; }
  // A state can contain many RGS exports. Keep immutable parameters for every
  // candidate and let its native shader identifier select on the GPU. Picking
  // the last CPU callback can instead pick radiance/reflection work.
  std::vector<std::shared_ptr<runtime::pool::Allocation>> pages{job->parameters};
  for (size_t index = 1; index < selected.size(); ++index) {
    auto extra = std::make_shared<runtime::Job>(*job);
    extra->parameters.reset();
    if (!runtime::AllocateJob(cmd, data, extra, 16, true)) { last_rejection = "candidate upload budget"; return false; }
    std::memcpy(extra->parameters->mapped, job->parameters->mapped, 1024);
    pages.push_back(extra->parameters);
  }
  const uint32_t available = light_range.count;
  for (size_t index = 0; index < selected.size(); ++index) {
    auto& parameters = *pages[index];
    const auto& capture = selected[index];
    std::memcpy(parameters.mapped + 288, capture->native_identifier.data(), 32);
    const uint32_t inputs[4] = {available, uint32_t(index + 1), 0, 0};
    std::memcpy(parameters.mapped + 320, inputs, sizeof(inputs));
    std::memcpy(parameters.mapped + 768, capture->volume_identifier.data(), 32);
    parameters.objects.insert(parameters.objects.end(), capture->objects.begin(), capture->objects.end());
    parameters.objects.emplace_back(reinterpret_cast<ID3D12Resource*>(lights_resource.handle));
    parameters.objects.emplace_back(reinterpret_cast<ID3D12Resource*>(light.buffer_range.buffer.handle));
  }
  auto& views = data->views.at(job->allocation->scratch->GetGPUVirtualAddress());
  D3D12_RESOURCE_BARRIER barrier{};
  barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
  barrier.Transition = {job->allocation->scratch.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, views.state, D3D12_RESOURCE_STATE_UNORDERED_ACCESS};
  if (views.state != D3D12_RESOURCE_STATE_UNORDERED_ACCESS)
    native->ResourceBarrier(1, &barrier);
  else {
    D3D12_RESOURCE_BARRIER order{};
    order.Type = D3D12_RESOURCE_BARRIER_TYPE_UAV;
    order.UAV.pResource = job->allocation->scratch.Get();
    native->ResourceBarrier(1, &order);
  }
  restore.Changed();
  issuing = true;
  struct EndIssuing {
    ~EndIssuing() { issuing = false; }
  } end_issuing;
  for (size_t index = 0; index < selected.size(); ++index) {
    const auto& capture = selected[index];
    const auto& roots = capture->roots;
    const auto& parameters = *pages[index];
    if (index) {
      D3D12_RESOURCE_BARRIER order{};
      order.Type = D3D12_RESOURCE_BARRIER_TYPE_UAV;
      order.UAV.pResource = job->allocation->scratch.Get();
      native->ResourceBarrier(1, &order);
    }
    capture->bindings->BindCompute(cmd);
    native->SetComputeRootConstantBufferView(roots.frame, reinterpret_cast<ID3D12Resource*>(job->frame.buffer.handle)->GetGPUVirtualAddress() + job->frame.offset);
    // Bind the captured CBV explicitly. A saved descriptor-table handle is not
    // an immutable snapshot of the descriptors the engine can subsequently edit.
    native->SetComputeRootConstantBufferView(roots.source_camera, reinterpret_cast<ID3D12Resource*>(capture->camera.buffer.handle)->GetGPUVirtualAddress() + capture->camera.offset);
    native->SetComputeRootConstantBufferView(roots.light, reinterpret_cast<ID3D12Resource*>(light.buffer_range.buffer.handle)->GetGPUVirtualAddress() + light.buffer_range.offset);
    native->SetComputeRootConstantBufferView(roots.injection, parameters.constants->GetGPUVirtualAddress());
    native->SetComputeRootConstantBufferView(roots.grid, parameters.constants->GetGPUVirtualAddress() + 256);
    native->SetComputeRootUnorderedAccessView(roots.output, job->allocation->scratch->GetGPUVirtualAddress());
    native->SetComputeRootShaderResourceView(roots.lights, reinterpret_cast<ID3D12Resource*>(lights_resource.handle)->GetGPUVirtualAddress() + light_range.byte_offset);
    native->SetComputeRootShaderResourceView(roots.record, capture->record);
    auto dispatch = capture->dispatch;
    dispatch.RayGenerationShaderRecord = {parameters.constants->GetGPUVirtualAddress() + 768, 32};
    dispatch.Width = job->width;
    dispatch.Height = job->height;
    dispatch.Depth = job->slices;
    rays->DispatchRays(&dispatch);
  }
  RecordDiagnostic(cmd, job->allocation->scratch.Get());
  barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_UNORDERED_ACCESS;
  barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE;
  native->ResourceBarrier(1, &barrier);
  views.state = D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE;
  ++dispatches;
  last_rejection = "none";
  return true;
}
inline void Use(DWORD reason) {
  if (reason != DLL_PROCESS_ATTACH && reason != DLL_PROCESS_DETACH) return;
  runtime::draw_ray_local = reason == DLL_PROCESS_ATTACH ? Draw : nullptr;
#define HARTAPFEL_FOG_RAY_EVENT(event, callback)                    \
  if (reason == DLL_PROCESS_ATTACH)                                 \
    reshade::register_event<reshade::addon_event::event>(callback); \
  else if (reason == DLL_PROCESS_DETACH)                            \
  reshade::unregister_event<reshade::addon_event::event>(callback)
  HARTAPFEL_FOG_RAY_EVENT(create_pipeline_layout, OnCreateLayout);
  HARTAPFEL_FOG_RAY_EVENT(init_device, OnInitDevice);
  HARTAPFEL_FOG_RAY_EVENT(destroy_device, OnDestroyDevice);
  HARTAPFEL_FOG_RAY_EVENT(init_command_list, OnInitCommand);
  HARTAPFEL_FOG_RAY_EVENT(destroy_command_list, OnDestroyCommand);
  HARTAPFEL_FOG_RAY_EVENT(reset_command_list, OnResetCommand);
  HARTAPFEL_FOG_RAY_EVENT(bind_pipeline, OnBindPipeline);
  HARTAPFEL_FOG_RAY_EVENT(dispatch_rays, OnRays);
  HARTAPFEL_FOG_RAY_EVENT(execute_command_list, OnExecute);
  HARTAPFEL_FOG_RAY_EVENT(present, OnPresent);
#undef HARTAPFEL_FOG_RAY_EVENT
}
}  // namespace hartapfelfx::fog::rays
