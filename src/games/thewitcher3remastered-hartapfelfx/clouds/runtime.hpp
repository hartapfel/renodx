// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <deque>
#include <map>
#include <set>
#include <tuple>
#include "pipeline.hpp"
#include "atlas.hpp"
#include "native_state.hpp"
#include "native.hpp"
#include "family_runtime.hpp"
#include "ray_hooks.hpp"
#include "../fog/runtime.hpp"
#include "../sky/native_size.hpp"

namespace hartapfelfx::clouds::runtime {
namespace api = reshade::api;
namespace pool = renodx::utils::d3d12_resource_pool;
inline ShaderInjectData* fog_settings = nullptr;
inline std::atomic_uint64_t rendered = 0, native_fallbacks = 0, shadow_updates = 0;
struct Source {
  api::buffer_range frame{}, light{}, clock{};
  api::resource_view weather{}, depth{};
  gpu::ComPtr<ID3D12Resource> frame_resource, light_resource, clock_resource, weather_resource, depth_resource;
  D3D12_SHADER_RESOURCE_VIEW_DESC weather_desc{}, depth_desc{};
};
struct Admission {
  uint64_t frame = 0, clock = 0;
  Source source;
};
struct Entry {
  std::shared_ptr<View> view;
  Source source;
  gpu::Resource clock;
  BindingCache bindings;
  std::array<unsigned, 3> samples{};
  uint32_t quality = 0;
  DXGI_FORMAT target_format = DXGI_FORMAT_UNKNOWN;
  uint64_t used = 0;
};
struct Recording {
  std::vector<std::shared_ptr<Entry>> views;
  std::vector<std::shared_ptr<AtlasStorage>> atlases;
  std::vector<std::shared_ptr<Bindings>> bindings;
  std::vector<std::shared_ptr<gpu::Bank>> atlas_banks;
  std::vector<gpu::Resource> pages;
  std::vector<gpu::ComPtr<ID3D12Resource>> lighting;
  std::vector<gpu::ComPtr<IUnknown>> native_inputs;
  std::vector<pool::Completion> completion;
};
struct __declspec(uuid("66374d6d-8560-48fd-a617-75cf842e2649")) DeviceData {
  std::mutex mutex;
  std::mutex ray_mutex;
  std::mutex clock_mutex;
  Assets assets;
  gpu::UploadPool uploads;
  std::map<std::pair<uint64_t, uint64_t>, std::shared_ptr<Entry>> views;
  std::vector<std::shared_ptr<Entry>> allocated;
  std::vector<std::shared_ptr<AtlasStorage>> atlas_allocations;
  std::shared_ptr<Entry> latest_environment;
  std::array<std::array<float,4>,2> moon_material{};
  std::array<float,4> sun_material{};
  float native_sun_radius=0.f;
  std::array<float,2> native_moon_radius{};
  std::deque<Recording> retired;
  std::atomic_bool retirement_pending{false};
  std::deque<Admission> admissions;
  std::map<uint64_t, gpu::ComPtr<ID3D12PipelineState>> clock_pipelines;
  std::set<uint64_t> ray_pipelines;
  std::vector<api::command_queue*> queues;
  std::array<float, 16> configuration{};
  AuthoringParameters authoring_configuration{};
  uint32_t revision = 1;
  uint64_t view_serial = 0;
  std::shared_ptr<pool::Queue> previous_queue;
  bool ready = false;
};
struct __declspec(uuid("1081dc05-ccbf-439a-b246-183511d53683")) CommandData {
  struct AtlasTransaction {
    std::shared_ptr<AtlasStorage> storage;
    api::resource source{};
    api::resource_view target{};
    api::buffer_range frame{}, camera{};
    uint64_t clock = 0;
    uint32_t faces = 0, pending = UINT32_MAX;
    bool converted = false;
  } atlas;
  api::buffer_range sky_frame{}, sky_camera{}, sky_clock{};
  api::resource_view sky_target{};
  api::resource_view celestial_target{};
  api::viewport celestial_viewport{};
  bool enhanced_sky = false;
  bool toussaint_sky = false;
  uint32_t sky_glow_exposure=0;
  bool deferred_sky = false, sky_composited = false;
  Recording recording;
  std::vector<std::shared_ptr<pool::Queue>> queues;
  std::set<std::tuple<uint64_t, uint64_t, uint64_t>> rendered;
  std::set<std::tuple<uint64_t, uint64_t, uint64_t>> sun_captured;
  std::set<std::tuple<uint64_t, uint64_t, uint64_t>> moon_captured;
  std::set<std::pair<uint64_t, uint64_t>> clocks;
  api::pipeline regular_pipeline{};
  api::pipeline ray_pipeline{};
  bool ray_ready = false;
  bool replacement_bound = false;
  bool untracked = false;
};
struct __declspec(uuid("e2f08e7a-3152-4a9b-9c38-1aa3dd317f8e")) QueueData {
  std::shared_ptr<pool::Queue> queue;
  bool assets_waited = false;
};
inline uint64_t Address(const api::buffer_range& buffer) {
  return buffer.buffer.handle ? reinterpret_cast<ID3D12Resource*>(buffer.buffer.handle)->GetGPUVirtualAddress() + buffer.offset : 0;
}
inline bool Buffer(const api::buffer_range& buffer, uint64_t minimum) {
  if (!buffer.buffer.handle) return false;
  const auto desc = reinterpret_cast<ID3D12Resource*>(buffer.buffer.handle)->GetDesc();
  return desc.Dimension == D3D12_RESOURCE_DIMENSION_BUFFER && buffer.offset <= desc.Width && minimum <= desc.Width - buffer.offset
      && buffer.size >= minimum && (Address(buffer) & 255u) == 0;
}
// Native material/GlobalCB upload memory is CPU-written before its draw. Read
// only that heap type: no GPU readback, resource transition or queue wait.
inline bool ReadNativeUpload(const api::buffer_range& buffer,uint64_t offset,void* output,size_t bytes) {
  if(offset>UINT64_MAX-bytes||!Buffer(buffer,offset+bytes))return false;
  auto* resource=reinterpret_cast<ID3D12Resource*>(buffer.buffer.handle);
  D3D12_HEAP_PROPERTIES heap{};
  if(FAILED(resource->GetHeapProperties(&heap,nullptr))||heap.Type!=D3D12_HEAP_TYPE_UPLOAD)return false;
  void* mapped=nullptr;
  const D3D12_RANGE read{SIZE_T(buffer.offset+offset),SIZE_T(buffer.offset+offset+bytes)};
  if(FAILED(resource->Map(0,&read,&mapped)))return false;
  std::memcpy(output,static_cast<const uint8_t*>(mapped)+buffer.offset+offset,bytes);
  const D3D12_RANGE written{0,0};resource->Unmap(0,&written);
  return true;
}
inline void CaptureNativeSize(api::command_list* cmd,DeviceData* data,const fog::BindingState& state,bool lunar,bool toussaint=false) {
  std::array<float,3> camera{};
  if(!ReadNativeUpload(fog::Resolve(cmd,state,api::descriptor_type::constant_buffer,1,0,api::shader_stage::vertex).buffer_range,
      36*16,camera.data(),sizeof(camera)))return;
  for(uint32_t slot:{2u,3u}) {
    std::array<float,40> vertex{};
    if(!ReadNativeUpload(fog::Resolve(cmd,state,api::descriptor_type::constant_buffer,slot,0,api::shader_stage::vertex).buffer_range,
        0,vertex.data(),sizeof(vertex)))continue;
    const float radius=sky::NativeRadius(vertex,camera,!lunar);
    if(radius<=0.f)continue;
    std::lock_guard lock(data->mutex);
    if((lunar?data->native_moon_radius[toussaint]:data->native_sun_radius)==0.f)
      renodx::utils::log::i(lunar?"HartapfelFX native Moon diameter: ":"HartapfelFX native Sun diameter: ",radius*114.591559f," degrees");
    if(lunar)data->native_moon_radius[toussaint]=radius;
    else data->native_sun_radius=radius;
    return;
  }
}
inline uint32_t Revision(DeviceData* data) {
  const std::array<float, 16> current{mode, quality, step_size, shadows, coverage, density, size, thickness, detail,
                                      detail_size, base_softness, fog_settings ? fog_settings->sky_density : 1.f, quality_preset, clear_low_sun, sky::star_brightness,sky::sun_glow_size};
  const auto authoring=Authoring();
  if (current != data->configuration ||authoring!=data->authoring_configuration) {
    data->configuration = current;
    data->authoring_configuration=authoring;
    ++data->revision;
  }
  return data->revision;
}
inline D3D12_SHADER_RESOURCE_VIEW_DESC TextureView(api::device* device, api::resource_view view) {
  const auto input = device->get_resource_view_desc(view);
  D3D12_SHADER_RESOURCE_VIEW_DESC result{};
  result.Format = DXGI_FORMAT(input.format);
  result.Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
  if (input.type == api::resource_view_type::texture_2d) {
    result.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2D;
    result.Texture2D = {input.texture.first_level, input.texture.level_count, 0, 0};
  } else if (input.type == api::resource_view_type::texture_2d_array) {
    result.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2DARRAY;
    result.Texture2DArray = {input.texture.first_level, input.texture.level_count, input.texture.first_layer, input.texture.layer_count, 0, 0};
  }
  return result;
}
inline void Retain(api::command_list* cmd, const std::shared_ptr<Entry>& entry) {
  auto& recording = renodx::utils::data::Get<CommandData>(cmd)->recording;
  if (std::find(recording.views.begin(), recording.views.end(), entry) == recording.views.end()) recording.views.push_back(entry);
  for (IUnknown* input : {static_cast<IUnknown*>(entry->source.frame_resource.Get()), static_cast<IUnknown*>(entry->source.light_resource.Get()),
                         static_cast<IUnknown*>(entry->source.clock_resource.Get()),
                         static_cast<IUnknown*>(entry->source.weather_resource.Get()), static_cast<IUnknown*>(entry->source.depth_resource.Get())})
    if (input && std::none_of(recording.native_inputs.begin(), recording.native_inputs.end(), [input](const auto& item) { return item.Get() == input; })) recording.native_inputs.emplace_back(input);
}
inline std::shared_ptr<Entry> GetView(api::command_list* cmd, DeviceData* data, const api::buffer_range& frame, uint32_t width, uint32_t height,
                                      DXGI_FORMAT target_format = DXGI_FORMAT_UNKNOWN) {
  const auto key = std::pair{frame.buffer.handle, frame.offset};
  if (!data->views.contains(key) && data->views.size() >= 4) {
    const auto oldest = std::min_element(data->views.begin(), data->views.end(), [](const auto& left, const auto& right) {
      return (left.second ? left.second->used : 0) < (right.second ? right.second->used : 0);
    });
    data->views.erase(oldest);
  }
  auto& entry = data->views[key];
  if (entry) entry->used = ++data->view_serial;
  const auto samples = Quality(quality);
  const uint32_t level = QualityLevel(quality);
  // Receiver/clock hooks run before the cloud target is known. The captured
  // main sky target is RGBA16F; prepare its scene copy now so Render can reuse
  // this view instead of allocating a second full-resolution view each frame.
  const DXGI_FORMAT view_format = target_format == DXGI_FORMAT_UNKNOWN ? DXGI_FORMAT_R16G16B16A16_FLOAT : target_format;
  if (entry && entry->view->Width() == width && entry->view->Height() == height && entry->samples == samples && entry->quality == level
      && (target_format == DXGI_FORMAT_UNKNOWN || entry->target_format == target_format)) return entry;
  if (!entry) {
    for (const auto& candidate : data->allocated) {
      if (candidate.use_count() != 1 || candidate->view->Width() != width || candidate->view->Height() != height
          || candidate->samples != samples || candidate->quality != level || candidate->target_format != view_format) continue;
      // GPU completion has released every recording reference. Rebind this
      // storage to the engine's rotated frame CBV instead of recreating it.
      entry = candidate;
      entry->source.frame = frame;
      entry->source.frame_resource = reinterpret_cast<ID3D12Resource*>(frame.buffer.handle);
      entry->used = ++data->view_serial;
      Retain(cmd, entry);
      return entry;
    }
  }
  std::erase_if(data->allocated, [](const auto& item) { return item.use_count() == 1; });
  uint64_t bytes = 0;
  for (const auto& existing : data->allocated) bytes += existing->view->Bytes();
  // The previous view can still be in flight when a quality edit creates its
  // replacement. Budget that short overlap separately from persistent views;
  // otherwise a 4K edit falls back to native clouds until the old GPU work retires.
  const uint64_t pixels = uint64_t((width + samples[0] - 1) / samples[0]) * ((height + samples[0] - 1) / samples[0]);
  const uint64_t scene_bytes=view_format==DXGI_FORMAT_R32G32B32A32_FLOAT ? uint64_t(width)*height*16u
      : uint64_t(width)*height*8u;
  const uint64_t estimate = pixels * 44u + scene_bytes * 2u + (128ull << 20);
  const uint64_t old_bytes = entry ? entry->view->Bytes() : 0u;
  const auto fallback = entry && entry->view->Width() == width && entry->view->Height() == height
      && (target_format == DXGI_FORMAT_UNKNOWN || entry->target_format == target_format) ? entry : std::shared_ptr<Entry>{};
  if (width > 16384 || height > 16384 || estimate + bytes - old_bytes > (768ull << 20)
      || estimate + bytes > (1536ull << 20)) return fallback;
  auto replacement = std::make_shared<Entry>();
  replacement->view = std::make_shared<View>(&data->assets, width, height, quality, view_format,
      entry ? entry->view->LightingStorage() : nullptr);
  if (replacement->view->Bytes() + bytes - old_bytes > (768ull << 20)
      || replacement->view->Bytes() + bytes > (1536ull << 20)) return fallback;
  replacement->clock = entry ? entry->clock : gpu::Buffer(data->assets.Device(), 256, gpu::HistoryRead);
  replacement->samples = samples;
  replacement->quality = level;
  replacement->target_format = view_format;
  replacement->used = ++data->view_serial;
  if (entry) replacement->source = entry->source;
  replacement->source.frame = frame;
  replacement->source.frame_resource = reinterpret_cast<ID3D12Resource*>(frame.buffer.handle);
  data->allocated.push_back(replacement);
  entry = std::move(replacement);
  Retain(cmd, entry);
  return entry;
}
inline Inputs MakeInputs(api::command_list* cmd, DeviceData* data, const std::shared_ptr<Entry>& entry, uint64_t clock, bool captured = false) {
  Inputs result;
  result.frame = Address(entry->source.frame); result.light = Address(entry->source.light); result.clock = clock;
  result.clock_capture=entry->clock.object->GetGPUVirtualAddress();
  result.weather = entry->source.weather_resource.Get(); result.depth = entry->source.depth_resource.Get();
  result.weather_view = entry->source.weather_desc;
  result.depth_view = entry->source.depth_desc;
  result.width = entry->view->Width(); result.height = entry->view->Height();
  result.revision = Revision(data); result.captured_clock = captured;
  result.family = families::current.load(std::memory_order_relaxed);
  if (fog_settings) result.fog_settings = *fog_settings;
  return result;
}
inline std::shared_ptr<Bindings> GetBindings(api::command_list* cmd, const std::shared_ptr<Entry>& entry, const Inputs& inputs) {
  auto bank = entry->bindings.Acquire(*entry->view, inputs, uint32_t(QualityLighting(quality)[3]));
  auto& retained = renodx::utils::data::Get<CommandData>(cmd)->recording.bindings;
  if (std::find(retained.begin(), retained.end(), bank) == retained.end()) retained.push_back(bank);
  // Evicted immutable heaps remain owned by their recordings through completion.
  return bank;
}
inline bool MainCommand(api::command_list* cmd) {
  return cmd->get_device()->get_api() == api::device_api::d3d12
      && reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native())->GetType() == D3D12_COMMAND_LIST_TYPE_DIRECT;
}
inline void CaptureClock(api::command_list* cmd) {
  if (!MainCommand(cmd) || mode < .5f) return;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  const auto* state = hartapfelfx::raster::Get(cmd);
  if (!data || !data->ready || !command || !bindings || !state || state->viewports.size() != 1) return;
  const auto viewport = state->viewports.front();
  if (viewport.x != 0 || viewport.y != 0 || viewport.width < 320 || viewport.height < 180) return;
  const auto frame = fog::Resolve(cmd, bindings->graphics, api::descriptor_type::constant_buffer, 12).buffer_range;
  const auto clock = fog::Resolve(cmd, bindings->graphics, api::descriptor_type::constant_buffer, 0).buffer_range;
  if (!Buffer(frame, 341 * 16) || !Buffer(clock, 16) || command->clocks.contains({Address(frame), Address(clock)})) return;
  const int output = fog::runtime::RootIndex(cmd, bindings->graphics.layout, api::descriptor_type::buffer_unordered_access_view, 0, 72);
  const int token = fog::runtime::RootIndex(cmd, bindings->graphics.layout, api::descriptor_type::constant_buffer, 3, 71);
  if (output < 0 || token < 0) return;
  NativeState restore(cmd, command->regular_pipeline, false);
  if (!restore.Valid()) return;
  std::lock_guard lock(data->mutex);
  try {
    const auto entry = GetView(cmd, data, frame, uint32_t(viewport.width), uint32_t(viewport.height));
    if (!entry) return;
    std::lock_guard clock_lock(data->clock_mutex);
    auto& pipeline = data->clock_pipelines[bindings->graphics.layout.handle];
    if (!pipeline) pipeline = gpu::Graphics(data->assets.Device(), reinterpret_cast<ID3D12RootSignature*>(bindings->graphics.layout.handle),
        {__0xF7F00001.data(), __0xF7F00001.size()}, {__0xF7C0000D.data(), __0xF7C0000D.size()});
    std::array<uint32_t, 64> address{};
    address[0] = uint32_t(Address(clock)); address[1] = uint32_t(Address(clock) >> 32);
    command->recording.pages.push_back(data->uploads.Upload(data->assets.Device(), address.data(), sizeof(address)));
    command->recording.native_inputs.emplace_back(reinterpret_cast<ID3D12Resource*>(clock.buffer.handle));
    command->recording.native_inputs.emplace_back(reinterpret_cast<ID3D12RootSignature*>(bindings->graphics.layout.handle));
    command->recording.native_inputs.emplace_back(pipeline.Get());
    Retain(cmd, entry);
    auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
    restore.Changed(false);
    gpu::Transition(native, &entry->clock, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    native->SetPipelineState(pipeline.Get());
    native->SetGraphicsRootUnorderedAccessView(output, entry->clock.object->GetGPUVirtualAddress());
    native->SetGraphicsRootConstantBufferView(token, command->recording.pages.back().object->GetGPUVirtualAddress());
    const D3D12_VIEWPORT pixel{0, 0, 1, 1, 0, 1};
    const D3D12_RECT scissor{0, 0, 1, 1};
    native->RSSetViewports(1, &pixel); native->RSSetScissorRects(1, &scissor);
    native->OMSetRenderTargets(0, nullptr, FALSE, nullptr);
    native->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    native->DrawInstanced(3, 1, 0, 0);
    gpu::Transition(native, &entry->clock, gpu::HistoryRead);
    command->clocks.insert({Address(frame), Address(clock)});
  } catch (const std::exception& error) {
    renodx::utils::log::e("HartapfelFX cloud clock capture: ", error.what());
  }
}
inline void BindShadow(api::command_list* cmd, const std::shared_ptr<Entry>& entry, bool compute) {
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  const auto layout = compute ? bindings->compute.layout : bindings->graphics.layout;
  const int index = fog::runtime::RootIndex(cmd, layout, api::descriptor_type::buffer_shader_resource_view, 0, 72);
  if (index < 0) return;
  Retain(cmd, entry);
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  if (compute) native->SetComputeRootShaderResourceView(index, entry->view->Shared()->GetGPUVirtualAddress());
  else native->SetGraphicsRootShaderResourceView(index, entry->view->Shared()->GetGPUVirtualAddress());
}
inline bool PrepareReceiver(api::command_list* cmd, bool fog_ready, bool allow_neutral = false) {
  if (!MainCommand(cmd)) return false;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  if (!data || !data->ready || !bindings) return false;
  const int root = fog::runtime::RootIndex(cmd, bindings->graphics.layout, api::descriptor_type::buffer_shader_resource_view, 0, 72);
  if (root < 0) return false;
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  native->SetGraphicsRootShaderResourceView(root, data->assets.zero.object->GetGPUVirtualAddress());
  const auto frame = fog::Resolve(cmd, bindings->graphics, api::descriptor_type::constant_buffer, 12).buffer_range;
  std::lock_guard lock(data->mutex);
  Revision(data);
  const auto found = data->views.find({frame.buffer.handle, frame.offset});
  const bool cloud_ready = mode > .5f && found != data->views.end() && found->second;
  if (!cloud_ready && !allow_neutral) return false;
  if (cloud_ready) BindShadow(cmd, found->second, false);
  if (!fog_ready) {
    const int volume = fog::runtime::RootIndex(cmd, bindings->graphics.layout, api::descriptor_type::buffer_shader_resource_view, 0, 71);
    const int settings = fog::runtime::RootIndex(cmd, bindings->graphics.layout, api::descriptor_type::constant_buffer, 0, 70);
    if (volume < 0 || settings < 0) return false;
    native->SetGraphicsRootShaderResourceView(volume, data->assets.zero.object->GetGPUVirtualAddress());
    native->SetGraphicsRootConstantBufferView(settings, data->assets.zero.object->GetGPUVirtualAddress());
  }
  return true;
}
inline uint64_t ShadowAddress(api::command_list* cmd, bool compute) {
  if (!MainCommand(cmd)) return 0;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  if (!data || !data->ready || !bindings) return 0;
  const auto& state = compute ? bindings->compute : bindings->graphics;
  const auto frame = fog::Resolve(cmd, state, api::descriptor_type::constant_buffer, 12).buffer_range;
  std::lock_guard lock(data->mutex);
  Revision(data);
  if (mode > .5f) {
    const auto found = data->views.find({frame.buffer.handle, frame.offset});
    if (found != data->views.end() && found->second) {
      Retain(cmd, found->second);
      return found->second->view->Shared()->GetGPUVirtualAddress();
    }
  }
  return 0;
}
inline bool PrepareShadowReceiver(api::command_list* cmd, bool compute) {
  if (!MainCommand(cmd)) return false;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  if (!data || !data->ready || !bindings) return false;
  const int root = fog::runtime::RootIndex(cmd, compute ? bindings->compute.layout : bindings->graphics.layout, api::descriptor_type::buffer_shader_resource_view, 0, 72);
  if (root < 0) return false;
  const uint64_t address = ShadowAddress(cmd, compute);
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  if (compute) native->SetComputeRootShaderResourceView(root, address ? address : data->assets.zero.object->GetGPUVirtualAddress());
  else native->SetGraphicsRootShaderResourceView(root, address ? address : data->assets.zero.object->GetGPUVirtualAddress());
  return true;
}
// A cubemap face has its own b12 camera, but celestial assets/settings are
// view-independent. Retain the latest main-view storage for those faces.
inline void PrepareCelestialSky(api::command_list* cmd, bool replacement_ready) {
  auto* command=renodx::utils::data::Get<CommandData>(cmd);
  if(!command)return;
  command->enhanced_sky=false;
  command->deferred_sky=false;
  command->sky_composited=false;
  if(!replacement_ready ||mode<.5f ||!MainCommand(cmd))return;
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* bindings=renodx::utils::data::Get<fog::CommandData>(cmd);
  const auto* state=hartapfelfx::raster::Get(cmd);
  if(!data||!data->ready||!bindings||!state||state->render_targets.size()!=1||state->viewports.size()!=1)return;
  command->toussaint_sky=renodx::utils::shader::GetCurrentShaderHash(
      renodx::utils::shader::GetCurrentPixelState(renodx::utils::shader::GetCurrentState(cmd)))==0x3B15DAABu;
  const int root=fog::runtime::RootIndex(cmd,bindings->graphics.layout,api::descriptor_type::buffer_shader_resource_view,0,72);
  const int settings_root=fog::runtime::RootIndex(cmd,bindings->graphics.layout,api::descriptor_type::constant_buffer,0,70);
  if(root<0||settings_root<0)return;
  uint64_t address=ShadowAddress(cmd,false);
  if(!address) {
    std::lock_guard lock(data->mutex);
    if(data->latest_environment) {
      Retain(cmd,data->latest_environment);
      address=data->latest_environment->view->Shared()->GetGPUVirtualAddress();
    }
  }
  if(!address)return;
  const auto& area=state->viewports.front();
  const auto frame=fog::Resolve(cmd,bindings->graphics,api::descriptor_type::constant_buffer,12).buffer_range;
  const auto clock=fog::Resolve(cmd,bindings->graphics,api::descriptor_type::constant_buffer,0).buffer_range;
  std::array<float,8> native_directions{};
  const bool directions_ready=ReadNativeUpload(frame,204*16,native_directions.data(),sizeof(native_directions));
  std::array<float,4> sky_material{};
  command->sky_glow_exposure=ReadNativeUpload(fog::Resolve(cmd,bindings->graphics,api::descriptor_type::constant_buffer,2,0,api::shader_stage::pixel).buffer_range,
      0,sky_material.data(),sizeof(sky_material))&&sky_material[1]!=1.f?2u:1u;
  const auto target=cmd->get_device()->get_resource_from_view(state->render_targets.front());
  const auto description=cmd->get_device()->get_resource_desc(target);
  const auto format=DXGI_FORMAT(cmd->get_device()->get_resource_view_desc(state->render_targets.front()).format);
  std::array<uint8_t,256> page{};
  bool native_geometry_ready=false;
  if(fog_settings)std::memcpy(page.data(),fog_settings,sizeof(*fog_settings));
  {
    std::lock_guard lock(data->mutex);
    const auto found=data->views.find({frame.buffer.handle,frame.offset});
    const bool admitted=std::any_of(data->admissions.begin(),data->admissions.end(),[&](const auto& item) {return item.frame==Address(frame);});
    command->deferred_sky=admitted &&found!=data->views.end()&&found->second
        &&found->second->target_format==format &&area.x==0.f&&area.y==0.f&&area.width>=320.f&&area.height>=180.f
        &&area.width==found->second->view->Width()&&area.height==found->second->view->Height()
        &&description.type==api::resource_type::texture_2d&&description.texture.samples==1
        &&description.texture.depth_or_layers==1&&area.width<=description.texture.width&&area.height<=description.texture.height
        &&Buffer(frame,341*16)&&Buffer(clock,16);
    const uint32_t deferred=command->deferred_sky?0x534B5943u:0u;
    std::memcpy(page.data()+sizeof(ShaderInjectData),&deferred,4);
    std::memcpy(page.data()+64,data->moon_material[command->toussaint_sky].data(),16);
    std::memcpy(page.data()+80,data->sun_material.data(),16);
    const float glow_size=std::clamp(sky::sun_glow_size,.25f,4.f);
    std::memcpy(page.data()+96,&glow_size,sizeof(glow_size));
    std::memcpy(page.data()+100,&command->sky_glow_exposure,sizeof(command->sky_glow_exposure));
    const std::array<float,2> radii{data->native_sun_radius,data->native_moon_radius[command->toussaint_sky]};
    // A night load may never submit the Sun mesh, and vice versa. Do not wait
    // for an invisible body far below the horizon before enhancing this sky.
    const auto below_horizon=[&](unsigned offset,float limit) {
      const float length=std::sqrt(native_directions[offset+1]*native_directions[offset+1]
          +native_directions[offset+2]*native_directions[offset+2]+native_directions[offset+3]*native_directions[offset+3]);
      return directions_ready&&std::isfinite(length)&&length>.5f&&native_directions[offset+3]<limit*length;
    };
    native_geometry_ready=(radii[0]>0.f||below_horizon(0,-.1f))
        &&(radii[1]>0.f||below_horizon(4,-.25f));
    std::memcpy(page.data()+112,radii.data(),sizeof(radii));
    const bool coherent=sky::emission::enabled.load(std::memory_order_relaxed);
    const auto solar=coherent?sky::emission::Unpack(sky::emission::sun.load(std::memory_order_relaxed)):std::array<float,4>{};
    const auto lunar=coherent?sky::emission::Unpack(sky::emission::moon.load(std::memory_order_relaxed)):std::array<float,4>{};
    std::memcpy(page.data()+128,solar.data(),sizeof(solar));
    std::memcpy(page.data()+144,lunar.data(),sizeof(lunar));
    command->recording.pages.push_back(data->uploads.Upload(data->assets.Device(),page.data(),page.size()));
  }
  auto* native=reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  // Keep the actual native bodies until their authored geometry is observed.
  // There is no hard-coded cinematic or astronomical substitute size.
  if(!native_geometry_ready) {
    command->deferred_sky=false;
    native->SetGraphicsRootShaderResourceView(root,data->assets.zero.object->GetGPUVirtualAddress());
    return;
  }
  native->SetGraphicsRootShaderResourceView(root,address);
  native->SetGraphicsRootConstantBufferView(settings_root,command->recording.pages.back().object->GetGPUVirtualAddress());
  // Inline celestial sources belong to reflection faces. If a main view
  // cannot run the cloud composite yet, retain its native sky/disc pipeline
  // rather than painting enhanced emitters in front of later cloud draws.
  if(area.x==0.f&&area.y==0.f&&area.width>=320.f&&area.height>=180.f&&!command->deferred_sky) {
    native->SetGraphicsRootShaderResourceView(root,data->assets.zero.object->GetGPUVirtualAddress());
    return;
  }
  command->celestial_target=state->render_targets.front();
  command->celestial_viewport=state->viewports.front();
  command->enhanced_sky=true;
}
inline bool EnhancedSkyMatches(api::command_list* cmd) {
  const auto* command=renodx::utils::data::Get<CommandData>(cmd);
  const auto* state=hartapfelfx::raster::Get(cmd);
  if(mode<.5f||!command||!command->enhanced_sky||!state
      ||state->render_targets.size()!=1||state->viewports.size()!=1)return false;
  const auto& a=command->celestial_viewport;
  const auto& b=state->viewports.front();
  return command->celestial_target==state->render_targets.front()
      &&a.x==b.x&&a.y==b.y&&a.width==b.width&&a.height==b.height;
}
inline bool PrepareMotion(api::command_list* cmd) {
  if (!MainCommand(cmd)) return false;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  if (!data || !data->ready || !bindings) return false;
  const int source = fog::runtime::RootIndex(cmd, bindings->compute.layout, api::descriptor_type::buffer_shader_resource_view, 0, 72);
  const int frame_root = fog::runtime::RootIndex(cmd, bindings->compute.layout, api::descriptor_type::constant_buffer, 12, 0);
  if (source < 0 || frame_root < 0) return false;
  const auto depth = fog::Resolve(cmd, bindings->compute, api::descriptor_type::texture_shader_resource_view, 0).resource_view;
  if (!depth.handle) return false;
  const auto resource = cmd->get_device()->get_resource_from_view(depth);
  if (!fog::IsFogDepthInput(cmd->get_device()->get_resource_desc(resource), cmd->get_device()->get_resource_view_desc(depth))) return false;
  std::lock_guard lock(data->mutex);
  auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  native->SetComputeRootShaderResourceView(source, data->assets.zero.object->GetGPUVirtualAddress());
  Revision(data);
  if (mode < .5f) return false;
  const auto frame = fog::Resolve(cmd, bindings->compute, api::descriptor_type::constant_buffer, 12).buffer_range;
  const auto found = data->views.find({frame.buffer.handle, frame.offset});
  std::shared_ptr<Entry> entry;
  if (found != data->views.end() && found->second && found->second->source.depth_resource.Get() == reinterpret_cast<ID3D12Resource*>(resource.handle)) entry = found->second;
  if (!entry) {
    for (const auto& [key, candidate] : data->views) {
      if (!candidate || candidate->source.depth_resource.Get() != reinterpret_cast<ID3D12Resource*>(resource.handle)) continue;
      // Ambiguous views retain the native conversion.
      if (entry) return false;
      entry = candidate;
    }
  }
  if (!entry) return false;
  Retain(cmd, entry);
  native->SetComputeRootConstantBufferView(frame_root, Address(entry->source.frame));
  native->SetComputeRootShaderResourceView(source, entry->view->Shared()->GetGPUVirtualAddress());
  return true;
}
inline void PrepareShadow(api::command_list* cmd, bool compute) {
  if (mode < .5f || !MainCommand(cmd)) return;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  if (!data || !data->ready || !bindings || !command) return;
  const auto layout = compute ? bindings->compute.layout : bindings->graphics.layout;
  const int shadow_root = fog::runtime::RootIndex(cmd, layout, api::descriptor_type::buffer_shader_resource_view, 0, 72);
  if (shadow_root >= 0) {
    auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
    if (compute) native->SetComputeRootShaderResourceView(shadow_root, data->assets.zero.object->GetGPUVirtualAddress());
    else native->SetGraphicsRootShaderResourceView(shadow_root, data->assets.zero.object->GetGPUVirtualAddress());
  }
  const auto& native_bindings = compute ? bindings->compute : bindings->graphics;
  const auto frame = fog::Resolve(cmd, native_bindings, api::descriptor_type::constant_buffer, 12).buffer_range;
  const auto light = fog::Resolve(cmd, native_bindings, api::descriptor_type::constant_buffer, 13).buffer_range;
  auto clock = fog::Resolve(cmd, native_bindings, api::descriptor_type::constant_buffer, 0).buffer_range;
  const auto weather = fog::Resolve(cmd, native_bindings, api::descriptor_type::texture_shader_resource_view, 14).resource_view;
  const auto depth = fog::Resolve(cmd, native_bindings, api::descriptor_type::texture_shader_resource_view, 0).resource_view;
  if (!Buffer(frame, 341 * 16) || !Buffer(light, 32) || !Buffer(clock, 16) || !weather.handle) return;
  const auto depth_resource = depth.handle ? cmd->get_device()->get_resource_from_view(depth) : api::resource{};
  const auto depth_desc = depth_resource.handle ? cmd->get_device()->get_resource_desc(depth_resource) : api::resource_desc{};
  const bool main_depth = depth.handle && fog::IsFogDepthInput(depth_desc, cmd->get_device()->get_resource_view_desc(depth));
  if (cmd->get_device()->get_resource_view_desc(weather).type != api::resource_view_type::texture_2d_array) return;
  NativeState restore(cmd, command->regular_pipeline, compute);
  if (!restore.Valid()) return;
  std::lock_guard lock(data->mutex);
  try {
    auto previous = data->views.find({frame.buffer.handle, frame.offset});
    if (!main_depth && (previous == data->views.end() || !previous->second)) return;
    const auto entry = main_depth ? GetView(cmd, data, frame, depth_desc.texture.width, depth_desc.texture.height) : previous->second;
    if (!entry) return;
    // RT reflection/probe b0 contains lighting controls, not the global clock.
    // Reuse the retained native clock until the main light pass publishes its
    // next one. Current weather, camera and jitter still come from this pass.
    if (compute) {
      clock = entry->source.clock;
      if (!Buffer(clock, 16)) return;
    } else {
      entry->source.clock = clock;
      entry->source.clock_resource = reinterpret_cast<ID3D12Resource*>(clock.buffer.handle);
    }
    const auto weather_desc = TextureView(cmd->get_device(), weather);
    const auto depth_view = main_depth ? TextureView(cmd->get_device(), depth) : entry->source.depth_desc;
    entry->source.light = light; entry->source.weather = weather;
    entry->source.light_resource = reinterpret_cast<ID3D12Resource*>(light.buffer.handle);
    entry->source.weather_resource = reinterpret_cast<ID3D12Resource*>(cmd->get_device()->get_resource_from_view(weather).handle);
    if (main_depth) {
      entry->source.depth = depth;
      entry->source.depth_resource = reinterpret_cast<ID3D12Resource*>(depth_resource.handle);
    }
    entry->source.weather_desc = weather_desc; entry->source.depth_desc = depth_view;
    if (main_depth) {
      const uint64_t frame_address = Address(frame), clock_address = Address(clock);
      std::erase_if(data->admissions, [&](const auto& item) { return item.frame == frame_address && item.clock == clock_address; });
      data->admissions.push_back({frame_address, clock_address, entry->source});
      while (data->admissions.size() > 64) data->admissions.pop_front();
    }
    Retain(cmd, entry);
    Revision(data);
    if (mode < .5f) return;
    const auto inputs = MakeInputs(cmd, data, entry, Address(clock));
    const auto bank = GetBindings(cmd, entry, inputs);
    auto& pages = command->recording.pages;
    pages.push_back(entry->view->ParameterPage(inputs, fog_settings->sky_density, 1, &data->uploads));
    pages.push_back(entry->view->ParameterPage(inputs, fog_settings->sky_density, 2, &data->uploads));
    command->recording.native_inputs.emplace_back(reinterpret_cast<ID3D12Resource*>(clock.buffer.handle));
    restore.Changed();
    auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
    entry->view->Weather(native, inputs, *bank, pages[pages.size() - 2], compute);
    entry->view->Shadow(native, inputs, *bank, pages.back());
    restore.Restore();
    BindShadow(cmd, entry, compute);
    ++shadow_updates;
  } catch (const std::exception& error) {
    renodx::utils::log::e("HartapfelFX cloud shadow: ", error.what());
  }
}
inline void RestoreSunPipeline(api::command_list* cmd, bool compute) {
  if (mode < .5f || !MainCommand(cmd)) return;
  auto* shaders = renodx::utils::shader::GetCurrentState(cmd);
  if (!shaders) return;
  auto* stage = compute ? renodx::utils::shader::GetCurrentComputeState(shaders) : renodx::utils::shader::GetCurrentPixelState(shaders);
  if (stage->pipeline_details && stage->pipeline_details->initialized_replacement && stage->pipeline_details->replacement_pipeline.handle)
    cmd->bind_pipeline(stage->applied_stage, stage->pipeline_details->replacement_pipeline);
}
inline void CaptureDisc(api::command_list* cmd, bool moon) {
  if (!MainCommand(cmd) || mode < .5f) return;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  const auto* state = hartapfelfx::raster::Get(cmd);
  if (!data || !data->ready || !command || !bindings || !state
      || state->render_targets.size() != 1 || state->viewports.size() != 1) return;
  const auto viewport = state->viewports.front();
  const auto target_view = state->render_targets.front();
  auto frame = fog::Resolve(cmd, bindings->graphics, api::descriptor_type::constant_buffer, 12).buffer_range;
  auto clock = fog::Resolve(cmd, bindings->graphics, api::descriptor_type::constant_buffer, 0).buffer_range;
  if (moon && command->sky_clock.buffer.handle) clock = command->sky_clock;
  // Native disc shaders can omit b12. Their preceding sky draw binds it.
  if (frame.buffer != command->sky_frame.buffer || frame.offset != command->sky_frame.offset)
    frame = command->sky_frame;
  if (target_view != command->sky_target || frame.buffer != command->sky_frame.buffer
      || frame.offset != command->sky_frame.offset || viewport.x != 0 || viewport.y != 0
      || viewport.width < 320 || viewport.height < 180 || !Buffer(frame, 341 * 16) || !Buffer(clock, 16)) return;
  const auto target = cmd->get_device()->get_resource_from_view(target_view);
  const auto desc = cmd->get_device()->get_resource_desc(target);
  const auto format = cmd->get_device()->get_resource_view_desc(target_view).format;
  if (desc.type != api::resource_type::texture_2d || desc.texture.samples != 1 || desc.texture.depth_or_layers != 1
      || viewport.width > desc.texture.width || viewport.height > desc.texture.height
      || (format != api::format::r16g16b16a16_float && format != api::format::r32g32b32a32_float)) return;
  std::lock_guard lock(data->mutex);
  const auto key = std::tuple{Address(clock), target.handle, uint64_t(Revision(data))};
  auto& captured = moon ? command->moon_captured : command->sun_captured;
  if (captured.contains(key)) return;
  try {
    const auto entry = GetView(cmd, data, frame, uint32_t(viewport.width), uint32_t(viewport.height), DXGI_FORMAT(format));
    if (!entry) return;
    auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
    auto* resource = reinterpret_cast<ID3D12Resource*>(target.handle);
    if (moon) entry->view->CaptureMoon(native, resource);
    else entry->view->CaptureSun(native, resource);
    Retain(cmd, entry);
    captured.insert(key);
  } catch (const std::exception& error) {
    renodx::utils::log::e(moon ? "HartapfelFX moon capture: " : "HartapfelFX sun capture: ", error.what());
  }
}
inline bool CardVertexMatches(uint32_t pixel, uint32_t vertex) {
  switch (pixel) {
    case 0x683213A3u: return vertex == 0xB5373B9Fu;
    case 0xBF0CA052u: return vertex == 0xF20F0978u;
    case 0xB7D286D5u: return vertex == 0xC4CBD1E4u;
    case 0xA35EA14Du: return vertex == 0x6AB84A91u || vertex == 0x96276053u;
    case 0x2AF34748u: return vertex == 0xB38E970Fu;
    case 0x093DCC92u: return vertex == 0x62612355u;
    default: return false;
  }
}
inline bool Render(api::command_list* cmd, uint32_t card_hash) {
  if (!MainCommand(cmd) || mode < .5f) return false;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  const auto* state = hartapfelfx::raster::Get(cmd);
  auto* shader = renodx::utils::shader::GetCurrentState(cmd);
  if (!data || !data->ready || !command || !bindings || !state || !shader || state->render_targets.size() != 1 || state->viewports.size() != 1) return false;
  if(EnhancedSkyMatches(cmd)&&command->sky_composited)return true;
  const bool sky_pass=card_hash==0x449D3390u||card_hash==0x3B15DAABu;
  const uint32_t vertex=renodx::utils::shader::GetCurrentShaderHash(renodx::utils::shader::GetCurrentVertexState(shader));
  if(sky_pass ? vertex!=(card_hash==0x3B15DAABu?0x979EED1Bu:0xCCD2CA86u) : !CardVertexMatches(card_hash,vertex))return false;
  const auto viewport = state->viewports.front();
  if (viewport.x != 0 || viewport.y != 0 || viewport.width < 320 || viewport.height < 180) return false;
  const bool animated=card_hash==0x683213A3u;
  const auto card_frame=fog::Resolve(cmd,bindings->graphics,api::descriptor_type::constant_buffer,
      animated?1u:12u).buffer_range;
  const auto frame=animated?command->sky_frame:card_frame;
  const auto clock = fog::Resolve(cmd, bindings->graphics, api::descriptor_type::constant_buffer, 0).buffer_range;
  if (!Buffer(frame, 341 * 16) || !Buffer(clock, 16)) return false;
  const auto target_view = state->render_targets.front();
  if(animated&&(command->sky_target!=target_view ||!command->sky_camera.buffer.handle
      ||card_frame.buffer!=command->sky_camera.buffer
      ||card_frame.offset!=command->sky_camera.offset))return false;
  const auto target_resource = cmd->get_device()->get_resource_from_view(target_view);
  const auto target_desc = cmd->get_device()->get_resource_desc(target_resource);
  const auto target_format = cmd->get_device()->get_resource_view_desc(target_view).format;
  if (target_desc.type != api::resource_type::texture_2d || target_desc.texture.samples != 1 || target_desc.texture.depth_or_layers != 1
      || (target_format != api::format::r16g16b16a16_float && target_format != api::format::r32g32b32a32_float)) return false;
  uint64_t fog_address = 0;
  if (fog_settings && fog_settings->enabled > .5f) fog::runtime::PrepareReceiver(cmd, &fog_address);
  NativeState restore(cmd, command->regular_pipeline, false);
  if (!restore.Valid()) return false;
  std::lock_guard lock(data->mutex);
  auto admission = std::find_if(data->admissions.rbegin(), data->admissions.rend(), [&](const auto& item) { return item.frame == Address(frame) && item.clock == Address(clock); });
  if (admission == data->admissions.rend()) {
    // Native effects can reallocate GlobalCB between the sunlight and sky
    // draws. A b0 address is not a frame identity: keep the exact match for
    // delayed recordings when available, otherwise use the retained source
    // for this same b12 view. Render still reads the cloud draw's own native
    // clock; never substitute the light pass's potentially unrelated b0.
    admission = std::find_if(data->admissions.rbegin(), data->admissions.rend(), [&](const auto& item) { return item.frame == Address(frame); });
  }
  if (admission == data->admissions.rend()) return false;
  const auto main_depth = admission->source.depth_resource->GetDesc();
  if (target_desc.texture.width != main_depth.Width || target_desc.texture.height != main_depth.Height
      || viewport.width > target_desc.texture.width || viewport.height > target_desc.texture.height) return false;
  try {
    const auto entry = GetView(cmd, data, frame, uint32_t(viewport.width), uint32_t(viewport.height),DXGI_FORMAT(target_format));
    if (!entry) return false;
    entry->source = admission->source;
    const auto key = std::tuple{Address(clock), target_resource.handle, uint64_t(Revision(data))};
    if (command->rendered.contains(key)) return true;
    auto inputs = MakeInputs(cmd, data, entry, Address(clock));
    inputs.captured_sun = command->sun_captured.contains(key);
    inputs.captured_moon = command->moon_captured.contains(key);
    inputs.enhanced_sky = command->deferred_sky &&EnhancedSkyMatches(cmd);
    inputs.moon_material=data->moon_material[command->toussaint_sky];
    inputs.sun_material=data->sun_material;
    inputs.sky_glow_exposure=command->sky_glow_exposure;
    inputs.native_radius={data->native_sun_radius,data->native_moon_radius[command->toussaint_sky]};
    inputs.fog = fog_address;
    inputs.target = {SIZE_T(target_view.handle)};
    inputs.target_resource = reinterpret_cast<ID3D12Resource*>(target_resource.handle);
    inputs.target_format = DXGI_FORMAT(target_format);
    const auto bank = GetBindings(cmd, entry, inputs);
    auto& pages = command->recording.pages;
    pages.push_back(entry->view->ParameterPage(inputs, fog_settings->sky_density, 1, &data->uploads));
    pages.push_back(entry->view->ParameterPage(inputs, fog_settings->sky_density, 2, &data->uploads));
    pages.push_back(entry->view->ParameterPage(inputs, fog_settings->sky_density, 0, &data->uploads));
    Retain(cmd, entry);
    command->recording.native_inputs.emplace_back(reinterpret_cast<ID3D12Resource*>(clock.buffer.handle));
    command->recording.native_inputs.emplace_back(reinterpret_cast<ID3D12Resource*>(target_resource.handle));
    restore.Changed();
    auto* native = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
    entry->view->Weather(native, inputs, *bank, pages[pages.size() - 3]);
    entry->view->Shadow(native, inputs, *bank, pages[pages.size() - 2]);
    inputs.light = entry->view->LightingStorage()->object->GetGPUVirtualAddress();
    entry->view->Render(native, inputs, *bank, pages.back());
    pages.push_back(entry->view->ParameterPage(inputs, fog_settings->sky_density, 3, &data->uploads));
    entry->view->Environment(native, inputs, *bank, pages.back());
    data->latest_environment = entry;
    command->rendered.insert(key);
    ++rendered;
    return true;
  } catch (const std::exception& error) {
    ++native_fallbacks;
    renodx::utils::log::e("HartapfelFX cloud render: ", error.what());
    return false;
  }
}
inline bool SuppressCard(api::command_list* cmd, uint32_t hash) {
  if (mode < .5f || !MainCommand(cmd)) return false;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  const auto* state = hartapfelfx::raster::Get(cmd);
  auto* shaders = renodx::utils::shader::GetCurrentState(cmd);
  if (!data || !command || !bindings || !state || !shaders || state->render_targets.size() != 1) return false;
  if (!CardVertexMatches(hash, renodx::utils::shader::GetCurrentShaderHash(renodx::utils::shader::GetCurrentVertexState(shaders)))) return false;
  if(EnhancedSkyMatches(cmd)&&command->sky_composited)return true;
  const auto clock = fog::Resolve(cmd, bindings->graphics, api::descriptor_type::constant_buffer, 0).buffer_range;
  const auto target = cmd->get_device()->get_resource_from_view(state->render_targets.front());
  std::lock_guard lock(data->mutex);
  return command->rendered.contains({Address(clock), target.handle, uint64_t(Revision(data))});
}
inline uint32_t AtlasFace(const api::viewport& area) {
  if(area.width!=256.f ||area.height!=256.f ||area.x<0.f ||area.y<0.f
      ||(area.x!=0.f&&area.x!=256.f&&area.x!=512.f)
      ||(area.y!=0.f&&area.y!=256.f))return UINT32_MAX;
  return uint32_t(area.y/256.f)*3u+uint32_t(area.x/256.f);
}
inline void BeginAtlasFace(api::command_list* cmd, uint32_t sky_hash) {
  if(mode<.5f ||!MainCommand(cmd))return;
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* command=renodx::utils::data::Get<CommandData>(cmd);
  auto* bindings=renodx::utils::data::Get<fog::CommandData>(cmd);
  const auto* state=hartapfelfx::raster::Get(cmd);
  auto* shaders=renodx::utils::shader::GetCurrentState(cmd);
  if(!data||!data->ready||!command||!bindings||!state||!shaders
      ||state->viewports.size()!=1||state->render_targets.size()!=1
      ||renodx::utils::shader::GetCurrentShaderHash(renodx::utils::shader::GetCurrentVertexState(shaders))
          != (sky_hash==0x3B15DAABu ? 0x979EED1Bu : 0xCCD2CA86u))return;
  const uint32_t face=AtlasFace(state->viewports.front());
  const auto frame=fog::Resolve(cmd,bindings->graphics,api::descriptor_type::constant_buffer,12).buffer_range;
  const auto camera=fog::Resolve(cmd,bindings->graphics,api::descriptor_type::constant_buffer,1).buffer_range;
  const auto clock=fog::Resolve(cmd,bindings->graphics,api::descriptor_type::constant_buffer,0).buffer_range;
  if(face==UINT32_MAX) {
    const auto viewport=state->viewports.front();
    if(viewport.x==0.f&&viewport.y==0.f&&viewport.width>=320.f&&viewport.height>=180.f
        &&Buffer(frame,1280)&&camera.buffer.handle) {
      command->sky_frame=frame;
      command->sky_camera=camera;
      command->sky_clock=clock;
      command->sky_target=state->render_targets.front();
    }
    return;
  }
  const auto target=state->render_targets.front();
  const auto resource=cmd->get_device()->get_resource_from_view(target);
  const auto description=cmd->get_device()->get_resource_desc(resource);
  const auto view=cmd->get_device()->get_resource_view_desc(target);
  const auto format=DXGI_FORMAT(view.format);
  if(description.type!=api::resource_type::texture_2d ||description.texture.width!=768
      ||description.texture.height!=512||description.texture.depth_or_layers!=1
      ||description.texture.samples!=1||view.type!=api::resource_view_type::texture_2d
      ||format!=DXGI_FORMAT_R11G11B10_FLOAT&&format!=DXGI_FORMAT_R16G16B16A16_FLOAT
          &&format!=DXGI_FORMAT_R32G32B32A32_FLOAT)return;
  if(!Buffer(frame,1280))return;
  NativeState restore(cmd,command->regular_pipeline,false);
  if(!restore.Valid())return;
  std::lock_guard lock(data->mutex);
  try {
    auto& transaction=command->atlas;
    if(!transaction.storage||transaction.source!=resource||(transaction.faces&(1u<<face))!=0u
        ||transaction.pending!=UINT32_MAX) {
      transaction={};
      for(const auto& item:data->atlas_allocations)if(item.use_count()==1&&item->Format()==format) {
        transaction.storage=item;break;
      }
      if(!transaction.storage&&data->atlas_allocations.size()<8u) {
        transaction.storage=std::make_shared<AtlasStorage>(&data->assets,format);
        data->atlas_allocations.push_back(transaction.storage);
      }
      if(!transaction.storage)return;
      transaction.source=resource;
      command->recording.atlases.push_back(transaction.storage);
    }
    transaction.target=target;
    transaction.frame=frame;
    transaction.camera=camera;
    transaction.pending=face;
    restore.Changed();
    transaction.storage->CaptureFrame(reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native()),
        Address(frame),face,Revision(data));
    command->recording.native_inputs.emplace_back(reinterpret_cast<ID3D12Resource*>(resource.handle));
    command->recording.native_inputs.emplace_back(reinterpret_cast<ID3D12Resource*>(frame.buffer.handle));
  } catch(const std::exception& error) {
    command->atlas={};
    renodx::utils::log::e("HartapfelFX atlas face: ",error.what());
  }
}
inline void CaptureAtlasClear(api::command_list* cmd,uint32_t hash) {
  if(mode<.5f||!MainCommand(cmd))return;
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* command=renodx::utils::data::Get<CommandData>(cmd);
  auto* bindings=renodx::utils::data::Get<fog::CommandData>(cmd);
  const auto* state=hartapfelfx::raster::Get(cmd);
  auto* shaders=renodx::utils::shader::GetCurrentState(cmd);
  if(!data||!command||!bindings||!state||!shaders||state->viewports.size()!=1
      ||state->render_targets.size()!=1)return;
  if(!CardVertexMatches(hash,renodx::utils::shader::GetCurrentShaderHash(renodx::utils::shader::GetCurrentVertexState(shaders))))return;
  auto& transaction=command->atlas;
  if(!transaction.storage||transaction.pending==UINT32_MAX
      ||AtlasFace(state->viewports.front())!=transaction.pending
      ||state->render_targets.front()!=transaction.target)return;
  const auto frame=fog::Resolve(cmd,bindings->graphics,api::descriptor_type::constant_buffer,
      hash==0x683213A3u?1u:12u).buffer_range;
  const auto expected_frame=hash==0x683213A3u?transaction.camera:transaction.frame;
  if(!expected_frame.buffer.handle ||frame.buffer!=expected_frame.buffer||frame.offset!=expected_frame.offset)return;
  NativeState restore(cmd,command->regular_pipeline,false);
  if(!restore.Valid())return;
  std::lock_guard lock(data->mutex);
  try {
    restore.Changed();
    transaction.storage->CaptureClear(reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native()),
        reinterpret_cast<ID3D12Resource*>(transaction.source.handle),transaction.pending);
    transaction.faces|=1u<<transaction.pending;
    transaction.pending=UINT32_MAX;
  } catch(const std::exception& error) {
    transaction={};
    renodx::utils::log::e("HartapfelFX atlas clear: ",error.what());
  }
}
inline bool ConvertAtlas(api::command_list* cmd) {
  if(mode<.5f||!MainCommand(cmd))return false;
  auto* data=renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* command=renodx::utils::data::Get<CommandData>(cmd);
  auto* bindings=renodx::utils::data::Get<fog::CommandData>(cmd);
  const auto* state=hartapfelfx::raster::Get(cmd);
  auto* shaders=renodx::utils::shader::GetCurrentState(cmd);
  if(!data||!data->ready||!command||!bindings||!state||!shaders
      ||state->viewports.size()!=1||state->render_targets.size()!=1
      ||renodx::utils::shader::GetCurrentShaderHash(renodx::utils::shader::GetCurrentVertexState(shaders))!=0xE561350Au)return false;
  auto& transaction=command->atlas;
  if(transaction.converted)return true;
  if(!transaction.storage||transaction.faces!=63u||transaction.pending!=UINT32_MAX
      ||state->viewports.front().x!=0.f||state->viewports.front().y!=0.f
      ||state->viewports.front().width!=256.f||state->viewports.front().height!=256.f)return false;
  const auto source=fog::Resolve(cmd,bindings->graphics,api::descriptor_type::texture_shader_resource_view,0).resource_view;
  if(!source.handle||cmd->get_device()->get_resource_from_view(source)!=transaction.source)return false;
  const auto input_view=cmd->get_device()->get_resource_view_desc(source);
  if(input_view.type!=api::resource_view_type::texture_2d||input_view.texture.first_level!=0
      ||DXGI_FORMAT(input_view.format)!=transaction.storage->Format())return false;
  const auto target=state->render_targets.front();
  const auto output=cmd->get_device()->get_resource_from_view(target);
  const auto output_desc=cmd->get_device()->get_resource_desc(output);
  const auto output_view=cmd->get_device()->get_resource_view_desc(target);
  if(output_desc.type!=api::resource_type::texture_2d||output_desc.texture.width!=256
      ||output_desc.texture.height!=256||output_desc.texture.depth_or_layers!=1
      ||output_desc.texture.samples!=1||output_view.type!=api::resource_view_type::texture_2d)return false;
  const auto format=DXGI_FORMAT(output_view.format);
  if(format!=DXGI_FORMAT_R11G11B10_FLOAT&&format!=DXGI_FORMAT_R16G16B16A16_FLOAT
      &&format!=DXGI_FORMAT_R32G32B32A32_FLOAT)return false;
  NativeState restore(cmd,command->regular_pipeline,false);
  if(!restore.Valid())return false;
  std::lock_guard lock(data->mutex);
  const auto environment=data->latest_environment;
  if(!environment)return false;
  try {
    Retain(cmd,environment);
    command->recording.native_inputs.emplace_back(reinterpret_cast<ID3D12Resource*>(output.handle));
    restore.Changed();
    auto bank=transaction.storage->Convert(reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native()),
        reinterpret_cast<ID3D12Resource*>(transaction.source.handle),TextureView(cmd->get_device(),source),
        environment->view->EnvironmentRadiance(),environment->view->EnvironmentHeader(),
        {SIZE_T(target.handle)},format);
    command->recording.atlas_banks.push_back(std::move(bank));
    transaction.converted=true;
    return true;
  } catch(const std::exception& error) {
    renodx::utils::log::e("HartapfelFX atlas convert: ",error.what());
    return false;
  }
}
inline constexpr auto ObserveClock = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  CaptureClock(context.cmd_list);
  return {};
};
inline constexpr auto ObserveSun = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  if(mode<.5f)return {};
  auto* data=renodx::utils::data::Get<DeviceData>(context.cmd_list->get_device());
  auto* bindings=renodx::utils::data::Get<fog::CommandData>(context.cmd_list);
  auto* shaders=renodx::utils::shader::GetCurrentState(context.cmd_list);
  if(data&&bindings&&shaders&&renodx::utils::shader::GetCurrentShaderHash(
      renodx::utils::shader::GetCurrentVertexState(shaders))==0xE1C4426Eu) {
    CaptureNativeSize(context.cmd_list,data,bindings->graphics,false);
    std::array<float,4> light{};
    std::array<float,12> material{};
    if(ReadNativeUpload(fog::Resolve(context.cmd_list,bindings->graphics,api::descriptor_type::constant_buffer,0,0,api::shader_stage::pixel).buffer_range,
            160,light.data(),sizeof(light))
        &&ReadNativeUpload(fog::Resolve(context.cmd_list,bindings->graphics,api::descriptor_type::constant_buffer,2,0,api::shader_stage::pixel).buffer_range,
            0,material.data(),sizeof(material))) {
      // E46451D5: pow(L * normalize(L) / dot(L, scalar) * material0,2.2)
      // times material2. The unknown GPU-only b4 scalar, height and native fog
      // are achromatic, so cancel in the normalized HDR colour ratios.
      std::array<float,4> colour{};
      for(unsigned i=0;i<3;++i)
        colour[i]=std::pow(std::max(light[i]*light[i]*material[i],0.f),2.2f)*material[8+i]*material[11];
      if(std::all_of(colour.begin(),colour.end(),[](float value){return std::isfinite(value)&&value>=0.f;})) {
        const float peak=std::max({colour[0],colour[1],colour[2]});
        for(unsigned i=0;i<3;++i)colour[i]/=std::max(peak,1.e-20f);
        colour[3]=1.f;
        std::lock_guard lock(data->mutex);
        data->sun_material=colour;
      }
    }
  }
  const auto* command=renodx::utils::data::Get<CommandData>(context.cmd_list);
  if(EnhancedSkyMatches(context.cmd_list)&&(!command->deferred_sky||command->sky_composited))return {.bypass=true};
  CaptureDisc(context.cmd_list, false);
  return {};
};
inline constexpr auto ObserveMoon = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  if(mode<.5f)return {};
  // Native Moon material is already CPU-written in an upload heap. Reading
  // its 48 bytes here needs no GPU readback, queue wait or extra render pass.
  // The next sky recording uses this family-specific material; frame[277]
  // supplies the fallback before a native Moon draw has been seen.
  auto* data=renodx::utils::data::Get<DeviceData>(context.cmd_list->get_device());
  auto* bindings=renodx::utils::data::Get<fog::CommandData>(context.cmd_list);
  auto* shaders=renodx::utils::shader::GetCurrentState(context.cmd_list);
  const bool toussaint=context.matched_shader_hash==0x6D5A1EC2u;
  if(data&&bindings&&shaders&&renodx::utils::shader::GetCurrentShaderHash(
      renodx::utils::shader::GetCurrentVertexState(shaders))==(toussaint?0x680C44CEu:0x14AEBBFBu)) {
    CaptureNativeSize(context.cmd_list,data,bindings->graphics,true,toussaint);
    const auto material=fog::Resolve(context.cmd_list,bindings->graphics,api::descriptor_type::constant_buffer,2,0,api::shader_stage::pixel).buffer_range;
    std::array<float,12> constants{};
    if(ReadNativeUpload(material,0,constants.data(),sizeof(constants))) {
      std::array<float,4> colour{};
      for(unsigned i=0;i<3;++i)colour[i]=constants[8+i]*constants[11]*(toussaint?1.f:constants[i]);
      colour[3]=toussaint?2.f:1.f;
      if(std::all_of(colour.begin(),colour.end(),[](float value){return std::isfinite(value)&&value>=0.f;})) {
        sky::emission::ObserveMoon(colour.data(),toussaint);
        std::lock_guard lock(data->mutex);
        data->moon_material[toussaint]=colour;
      }
    }
  }
  const auto* command=renodx::utils::data::Get<CommandData>(context.cmd_list);
  if(EnhancedSkyMatches(context.cmd_list)&&(!command->deferred_sky||command->sky_composited))return {.bypass=true};
  CaptureDisc(context.cmd_list, true);
  return {};
};
inline constexpr auto ObserveCard = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  // Native sun and moon draws follow the sky draw. Composite at the first
  // cloud card so both discs are behind the volume's Beer transmission.
  CaptureAtlasClear(context.cmd_list,context.matched_shader_hash);
  Render(context.cmd_list, context.matched_shader_hash);
  return {.bypass = SuppressCard(context.cmd_list, context.matched_shader_hash)};
};
inline constexpr auto ObserveSkyAtlas = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  if(mode<.5f)return {};
  BeginAtlasFace(context.cmd_list, context.matched_shader_hash);
  // Replay the native sky first. The main-view composite then adds direct
  // celestial radiance only after cloud extinction, before any FP16 store.
  return {.post_callback=+[](Context& after,const void*) {
    auto* command=renodx::utils::data::Get<CommandData>(after.cmd_list);
    if(command&&command->deferred_sky&&EnhancedSkyMatches(after.cmd_list))
      command->sky_composited=Render(after.cmd_list,after.matched_shader_hash);
  }};
};
inline constexpr auto ObserveAtlasConvert = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  return {.bypass=ConvertAtlas(context.cmd_list)};
};
inline void (*bind_path_materials)(api::command_list*) = nullptr;
inline bool OnCreateRayLayout(api::device* device, uint32_t& count, api::pipeline_layout_param*& parameters) {
  if (device->get_api() != api::device_api::d3d12) return false;
  const fog::BindingLayout layout(count, parameters);
  bool camera = false, frame = false, weather = false, controls = false;
  uint32_t cost = 0;
  for (uint32_t index = 0; index < count; ++index) {
    const auto& parameter = layout.parameters[index];
    cost += parameter.constant_count ? parameter.constant_count : parameter.table ? 1u : 2u;
    controls |= parameter.constant_count && parameters[index].push_constants.dx_register_space == 56;
    for (const auto& range : parameter.ranges) {
      if (range.dx_register_space == 72) return false;
      controls |= range.dx_register_space == 56;
      if (range.type == api::descriptor_type::constant_buffer) {
        camera |= range.dx_register_space == 1 && range.dx_register_index == 0 && range.count > 0;
        frame |= range.dx_register_space == 2 && range.dx_register_index <= 12 && 12 - range.dx_register_index < range.count;
      }
      weather |= range.type == api::descriptor_type::texture_shader_resource_view && range.dx_register_space == 1
          && range.dx_register_index <= 25 && 25 - range.dx_register_index < range.count;
    }
  }
  if (!camera || !frame || !weather || cost > 62) return false;
  static thread_local std::vector<api::pipeline_layout_param> extended;
  extended.assign(parameters, parameters + count);
  if (!controls && cost <= 58) extended.emplace_back(api::constant_range{0, 0, 56, 4, api::shader_stage::all_ray_tracing});
  extended.emplace_back(api::descriptor_range{.binding = 0, .dx_register_index = 0, .dx_register_space = 72, .count = 1,
      .visibility = api::shader_stage::all, .array_size = 1, .type = api::descriptor_type::buffer_shader_resource_view});
  parameters = extended.data(); count = uint32_t(extended.size());
  return true;
}
inline void OnDestroyPipeline(api::device* device, api::pipeline pipeline) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(device)) {
    std::lock_guard lock(data->ray_mutex);
    data->ray_pipelines.erase(pipeline.handle);
  }
}
inline void OnDestroyLayout(api::device* device, api::pipeline_layout layout) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(device)) {
    std::lock_guard lock(data->clock_mutex);
    data->clock_pipelines.erase(layout.handle);
  }
}
inline void PrepareRayShadow(api::command_list* cmd) {
  if (!MainCommand(cmd)) return;
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* bindings = renodx::utils::data::Get<fog::CommandData>(cmd);
  if (!data || !data->ready || !command || !command->ray_ready || !bindings) return;
  const int root = fog::runtime::RootIndex(cmd, bindings->compute.layout, api::descriptor_type::buffer_shader_resource_view, 0, 72);
  if (root < 0) return;
  auto* native_command = reinterpret_cast<ID3D12GraphicsCommandList*>(cmd->get_native());
  native_command->SetComputeRootShaderResourceView(root, data->assets.zero.object->GetGPUVirtualAddress());
  if (mode < .5f) return;
  const auto camera = fog::Resolve(cmd, bindings->compute, api::descriptor_type::constant_buffer, 0, 1).buffer_range;
  const auto frame = fog::Resolve(cmd, bindings->compute, api::descriptor_type::constant_buffer, 12, 2).buffer_range;
  const auto weather = fog::Resolve(cmd, bindings->compute, api::descriptor_type::texture_shader_resource_view, 25, 1).resource_view;
  if (!Buffer(camera, 288) || !weather.handle || cmd->get_device()->get_resource_view_desc(weather).type != api::resource_view_type::texture_2d_array) return;
  NativeState restore(cmd, {}, true, command->ray_pipeline);
  if (!restore.Valid()) return;
  std::lock_guard lock(data->mutex);
  Revision(data);
  if (mode < .5f) return;
  auto found = data->views.find({frame.buffer.handle, frame.offset});
  if (found == data->views.end()) return;
  const auto entry = found->second;
  if (!entry) return;
  try {
    const auto weather_desc = TextureView(cmd->get_device(), weather);
    auto* weather_resource = reinterpret_cast<ID3D12Resource*>(cmd->get_device()->get_resource_from_view(weather).handle);
    entry->source.weather = weather; entry->source.weather_resource = weather_resource; entry->source.weather_desc = weather_desc;
    // PT depth passes do not necessarily run the material draw that captures
    // the clock. The main light pass retains the native global clock too.
    const bool native_clock = Buffer(entry->source.clock, 16);
    auto inputs = MakeInputs(cmd, data, entry,
        native_clock ? Address(entry->source.clock) : entry->clock.object->GetGPUVirtualAddress(), !native_clock);
    // Native CameraCB row16 is the same world-space directional light used by
    // these ray libraries. Its 256-byte offset is a valid private root CBV.
    inputs.light = Address(camera) + 256;
    const auto bank = GetBindings(cmd, entry, inputs);
    auto& pages = command->recording.pages;
    pages.push_back(entry->view->ParameterPage(inputs, fog_settings->sky_density, 1, &data->uploads));
    pages.push_back(entry->view->ParameterPage(inputs, fog_settings->sky_density, 2, &data->uploads));
    Retain(cmd, entry);
    command->recording.native_inputs.emplace_back(reinterpret_cast<ID3D12Resource*>(camera.buffer.handle));
    command->recording.native_inputs.emplace_back(reinterpret_cast<ID3D12StateObject*>(command->ray_pipeline.handle));
    restore.Changed();
    entry->view->Weather(native_command, inputs, *bank, pages[pages.size() - 2], true);
    entry->view->Shadow(native_command, inputs, *bank, pages.back());
    restore.Restore();
    BindShadow(cmd, entry, true);
    ++shadow_updates;
  } catch (const std::exception& error) {
    renodx::utils::log::e("HartapfelFX ray cloud shadows: ", error.what());
  }
}
inline bool OnDispatchRays(api::command_list* cmd, api::resource, uint64_t, uint64_t, api::resource, uint64_t, uint64_t, uint64_t,
                           api::resource, uint64_t, uint64_t, uint64_t, api::resource, uint64_t, uint64_t, uint64_t, uint32_t, uint32_t, uint32_t) {
  PrepareRayShadow(cmd);
  if (bind_path_materials) bind_path_materials(cmd);
  return false;
}
inline void OnInitDevice(api::device* device) {
  auto* data = renodx::utils::data::Create<DeviceData>(device);
  if (device->get_api() != api::device_api::d3d12) return;
  try {
    auto code = [](const auto& shader) { return D3D12_SHADER_BYTECODE{shader.data(), shader.size()}; };
    data->assets.Initialize(reinterpret_cast<ID3D12Device*>(device->get_native()), {
        code(__0xF7F00001), code(__0xF7C00001), code(__0xF7C00008), code(__0xF7C00002), code(__0xF7C00003), code(__0xF7C00004),
        code(__0xF7C00007), code(__0xF7C00006), code(__0xF7C00009), code(__0xF7C0000A), code(__0xF7C0000B), code(__0xF7C0000C), code(__0xF7C0000E), code(__0xF7C0000F), code(__0xF7C00010), code(__0xF7C00013), code(__0xF7C00014), code(__0xF7C00015), code(__0xF7C00016)});
    data->ready = true;
    ray_hooks::Attach(device);
  } catch (const std::exception& error) {
    renodx::utils::log::e("HartapfelFX cloud initialization: ", error.what());
  }
}
inline void OnDestroyDevice(api::device* device) {
  auto* data = renodx::utils::data::Get<DeviceData>(device);
  if (!data) return;
  ray_hooks::RemoveDevice(device);
  for (auto* queue : data->queues) queue->wait_idle();
  device->set_private_data(reinterpret_cast<const uint8_t*>(&renodx::utils::data::GetUuid<DeviceData>()), 0);
  delete data;
}
inline void OnInitCommand(api::command_list* cmd) {
  renodx::utils::data::Create<CommandData>(cmd);
  heaps::Initialize(cmd);
}
inline void OnBindPipeline(api::command_list* cmd, api::pipeline_stage stages, api::pipeline pipeline) {
  if (auto* command = renodx::utils::data::Get<CommandData>(cmd)) {
    command->replacement_bound = false;
  }
  if (stages == api::pipeline_stage::all_ray_tracing) {
    auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
    if (auto* command = renodx::utils::data::Get<CommandData>(cmd); data && command) {
      std::lock_guard lock(data->ray_mutex);
      command->ray_ready = data->ray_pipelines.contains(pipeline.handle);
      command->ray_pipeline = pipeline;
    }
    return;
  }
  if ((stages & (api::pipeline_stage::all_graphics | api::pipeline_stage::compute_shader)) == api::pipeline_stage(0)) return;
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) {
    data->regular_pipeline = pipeline;
    data->ray_pipeline = {};
    data->ray_ready = false;
  }
}
inline void OnResetCommand(api::command_list* cmd) {
  heaps::Reset(cmd);
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  if (!data || !command) return;
  if (command->recording.views.empty() && command->recording.atlases.empty() && command->recording.lighting.empty()
      && !data->retirement_pending.load(std::memory_order_relaxed)) {
    *command = {};
    return;
  }
  std::lock_guard lock(data->mutex);
  if (!command->recording.views.empty() || !command->recording.atlases.empty() || !command->recording.lighting.empty()) {
    for (const auto& queue : command->queues) {
      uint64_t serial = queue->serial;
      if (queue->native && FAILED(queue->native->Signal(queue->fence.Get(), serial = ++queue->serial))) serial = UINT64_MAX;
      command->recording.completion.push_back({queue->fence, serial});
    }
    if (command->untracked) command->recording.completion.push_back({{}, UINT64_MAX});
    data->retired.push_back(std::move(command->recording));
  }
  *command = {};
  std::erase_if(data->retired, [](const auto& item) {
    return std::all_of(item.completion.begin(), item.completion.end(), [](const auto& point) { return point.fence && point.value != UINT64_MAX && point.fence->GetCompletedValue() >= point.value; });
  });
  data->retirement_pending.store(!data->retired.empty(), std::memory_order_relaxed);
}
inline void OnDestroyCommand(api::command_list* cmd) {
  OnResetCommand(cmd);
  heaps::Destroy(cmd);
  renodx::utils::data::Delete<CommandData>(cmd);
}
inline void OnInitQueue(api::command_queue* queue) {
  auto* entry = renodx::utils::data::Create<QueueData>(queue);
  if (queue->get_device()->get_api() != api::device_api::d3d12) return;
  auto* data = renodx::utils::data::Get<DeviceData>(queue->get_device());
  if (!data || !data->ready) return;
  std::lock_guard lock(data->mutex);
  entry->queue = std::make_shared<pool::Queue>();
  entry->queue->native = reinterpret_cast<ID3D12CommandQueue*>(queue->get_native());
  if (FAILED(data->assets.Device()->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&entry->queue->fence)))) entry->queue.reset();
  else data->queues.push_back(queue);
}
inline void OnExecute(api::command_queue* queue, api::command_list* cmd) {
  auto* command = renodx::utils::data::Get<CommandData>(cmd);
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  auto* q = renodx::utils::data::Get<QueueData>(queue);
  if (!command || !data || (command->recording.views.empty() && command->recording.atlases.empty() && command->recording.lighting.empty())) return;
  std::lock_guard lock(data->mutex);
  if (!q || !q->queue) { command->untracked = true; return; }
  if (std::find(command->queues.begin(), command->queues.end(), q->queue) == command->queues.end()) command->queues.push_back(q->queue);
  // CPU-uploaded lighting pages need retirement fences, not cloud-resource
  // dependencies or cross-queue serialization.
  if (command->recording.views.empty() && command->recording.atlases.empty()) return;
  if (data->ready && !q->assets_waited) {
    if (SUCCEEDED(q->queue->native->Wait(data->assets.ready.Get(), 1))) q->assets_waited = true;
    else command->untracked = true;
  }
  if (data->previous_queue && data->previous_queue != q->queue && data->previous_queue->native) {
    const auto& prior = data->previous_queue;
    const auto serial = ++prior->serial;
    if (SUCCEEDED(prior->native->Signal(prior->fence.Get(), serial))) q->queue->native->Wait(prior->fence.Get(), serial);
  }
  data->previous_queue = q->queue;
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
inline void Use(DWORD reason, ShaderInjectData* settings) {
  fog_settings = settings;
  if (reason == DLL_PROCESS_ATTACH) {
    fog::before_sun = [](api::command_list* cmd, bool compute) {
      if (!compute) PrepareShadow(cmd, false);
    };
    fog::after_sun = RestoreSunPipeline;
    fog::cloud_source = ShadowAddress;
    ray_hooks::known = [](api::device* device, ID3D12StateObject* pipeline) {
      auto* data = renodx::utils::data::Get<DeviceData>(device);
      if (!data) return false;
      std::lock_guard lock(data->ray_mutex);
      return data->ray_pipelines.contains(reinterpret_cast<uint64_t>(pipeline));
    };
    ray_hooks::created = [](api::device* device, ID3D12StateObject* pipeline) {
      if (auto* data = renodx::utils::data::Get<DeviceData>(device)) {
        std::lock_guard lock(data->ray_mutex);
        data->ray_pipelines.insert(reinterpret_cast<uint64_t>(pipeline));
      }
    };
    reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::register_event<reshade::addon_event::init_command_list>(OnInitCommand);
    reshade::register_event<reshade::addon_event::bind_descriptor_tables>(heaps::OnTables);
    reshade::register_event<reshade::addon_event::push_descriptors>(heaps::OnDescriptors);
    reshade::register_event<reshade::addon_event::push_constants>(heaps::OnConstants);
    reshade::register_event<reshade::addon_event::reset_command_list>(OnResetCommand);
    reshade::register_event<reshade::addon_event::destroy_command_list>(OnDestroyCommand);
    reshade::register_event<reshade::addon_event::bind_pipeline>(OnBindPipeline);
    reshade::register_event<reshade::addon_event::init_command_queue>(OnInitQueue);
    reshade::register_event<reshade::addon_event::destroy_command_queue>(OnDestroyQueue);
    reshade::register_event<reshade::addon_event::execute_command_list>(OnExecute);
    reshade::register_event<reshade::addon_event::create_pipeline_layout>(OnCreateRayLayout);
    reshade::register_event<reshade::addon_event::destroy_pipeline>(OnDestroyPipeline);
    reshade::register_event<reshade::addon_event::destroy_pipeline_layout>(OnDestroyLayout);
    reshade::register_event<reshade::addon_event::dispatch_rays>(OnDispatchRays);
    renodx::utils::command_action::RegisterCallback(ObserveClock, {.shader_hash = 0x30DE6E02u});
    for (uint32_t hash : {0x449D3390u, 0x3B15DAABu}) renodx::utils::command_action::RegisterCallback(ObserveSkyAtlas, {.shader_hash = hash});
    // A0A02407 is an unmodified screen copy, not a solar emitter.
    renodx::utils::command_action::RegisterCallback(ObserveSun, {.shader_hash = 0xE46451D5u});
    for(uint32_t hash:{0xE446F231u,0x6D5A1EC2u})
      renodx::utils::command_action::RegisterCallback(ObserveMoon, {.shader_hash = hash});
    renodx::utils::command_action::RegisterCallback(ObserveAtlasConvert, {.shader_hash = 0xF716B319u});
    for (uint32_t hash : {0x683213A3u, 0xBF0CA052u, 0xB7D286D5u, 0xA35EA14Du, 0x2AF34748u, 0x093DCC92u})
      renodx::utils::command_action::RegisterCallback(ObserveCard, {.shader_hash = hash});
  } else if (reason == DLL_PROCESS_DETACH) {
    fog::before_sun = nullptr;
    fog::after_sun = nullptr;
    fog::cloud_source = nullptr;
    ray_hooks::Detach();
    hooks::Detach();
    ray_hooks::known = nullptr;
    ray_hooks::created = nullptr;
    renodx::utils::command_action::Unregister(ObserveClock);
    renodx::utils::command_action::Unregister(ObserveSkyAtlas);
    renodx::utils::command_action::Unregister(ObserveSun);
    renodx::utils::command_action::Unregister(ObserveMoon);
    renodx::utils::command_action::Unregister(ObserveAtlasConvert);
    renodx::utils::command_action::Unregister(ObserveCard);
    reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::unregister_event<reshade::addon_event::init_command_list>(OnInitCommand);
    reshade::unregister_event<reshade::addon_event::bind_descriptor_tables>(heaps::OnTables);
    reshade::unregister_event<reshade::addon_event::push_descriptors>(heaps::OnDescriptors);
    reshade::unregister_event<reshade::addon_event::push_constants>(heaps::OnConstants);
    reshade::unregister_event<reshade::addon_event::reset_command_list>(OnResetCommand);
    reshade::unregister_event<reshade::addon_event::destroy_command_list>(OnDestroyCommand);
    reshade::unregister_event<reshade::addon_event::bind_pipeline>(OnBindPipeline);
    reshade::unregister_event<reshade::addon_event::init_command_queue>(OnInitQueue);
    reshade::unregister_event<reshade::addon_event::destroy_command_queue>(OnDestroyQueue);
    reshade::unregister_event<reshade::addon_event::execute_command_list>(OnExecute);
    reshade::unregister_event<reshade::addon_event::create_pipeline_layout>(OnCreateRayLayout);
    reshade::unregister_event<reshade::addon_event::destroy_pipeline>(OnDestroyPipeline);
    reshade::unregister_event<reshade::addon_event::destroy_pipeline_layout>(OnDestroyLayout);
    reshade::unregister_event<reshade::addon_event::dispatch_rays>(OnDispatchRays);
  }
}
}  // namespace hartapfelfx::clouds::runtime
