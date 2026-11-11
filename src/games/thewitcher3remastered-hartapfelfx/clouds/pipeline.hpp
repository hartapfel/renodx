// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <algorithm>
#include <memory>
#include <span>
#include "gpu.hpp"
#include "settings.hpp"
#include "families.hpp"
#include "../shared.h"
#include "../sky/moon_albedo.hpp"
#include "../sky/settings.hpp"
#include "../sky/emission.hpp"
#include "../fog/fast_noise.hpp"

namespace hartapfelfx::clouds {
struct Parameters {
  std::array<float, 4> dimensions{}, integration{}, appearance{}, atmosphere{}, scattering{};
  std::array<uint32_t, 4> identity{}, storage{};
  std::array<float,4> family_from{}, family_to{}, family_transition{};
  AuthoringParameters authoring{};
  std::array<float,4> celestial{};
};
static_assert(sizeof(Parameters) == 256);
static_assert(offsetof(Parameters,authoring)==160);
struct Shaders {
  D3D12_SHADER_BYTECODE vertex, noise, mips, trace, resolve, composite, weather, shadow, publish;
  D3D12_SHADER_BYTECODE weather_compute, shadow_compute, publish_compute, shadow_filter, profile, visibility, environment, atlas_capture, atlas_convert;
  D3D12_SHADER_BYTECODE sky_air;
};
struct Inputs {
  D3D12_GPU_VIRTUAL_ADDRESS frame = 0, light = 0, clock = 0, fog = 0, clock_capture = 0;
  ID3D12Resource* weather = nullptr;
  ID3D12Resource* depth = nullptr;
  D3D12_SHADER_RESOURCE_VIEW_DESC weather_view{}, depth_view{};
  D3D12_CPU_DESCRIPTOR_HANDLE target{};
  ID3D12Resource* target_resource = nullptr;
  DXGI_FORMAT target_format = DXGI_FORMAT_UNKNOWN;
  uint32_t width = 0, height = 0, revision = 0;
  uint64_t family = 0;
  bool captured_clock = false;
  bool captured_sun = false;
  bool captured_moon = false;
  bool enhanced_sky = false;
  std::array<float,4> moon_material{};
  std::array<float,4> sun_material{};
  uint32_t sky_glow_exposure=0;
  std::array<float,2> native_radius{};
  ShaderInjectData fog_settings{};
};
class Assets {
 public:
  ~Assets() {
    if (!ready || ready->GetCompletedValue() >= 1) return;
    const HANDLE completed = CreateEvent(nullptr, FALSE, FALSE, nullptr);
    if (completed) {
      if (SUCCEEDED(ready->SetEventOnCompletion(1, completed))) WaitForSingleObject(completed, INFINITE);
      CloseHandle(completed);
    }
  }
  void Initialize(ID3D12Device* device, const Shaders& shaders) {
    device_ = device;
    root = gpu::Root(device);
    trace = gpu::Graphics(device, root.Get(), shaders.vertex, shaders.trace);
    resolve = gpu::Graphics(device, root.Get(), shaders.vertex, shaders.resolve);
    weather = gpu::Graphics(device, root.Get(), shaders.vertex, shaders.weather);
    shadow = gpu::Graphics(device, root.Get(), shaders.vertex, shaders.shadow);
    publish = gpu::Graphics(device, root.Get(), shaders.vertex, shaders.publish);
    composite16 = gpu::Graphics(device, root.Get(), shaders.vertex, shaders.composite, DXGI_FORMAT_R16G16B16A16_FLOAT);
    composite32 = gpu::Graphics(device, root.Get(), shaders.vertex, shaders.composite, DXGI_FORMAT_R32G32B32A32_FLOAT);
    weather_compute = gpu::Compute(device, root.Get(), shaders.weather_compute);
    shadow_compute = gpu::Compute(device, root.Get(), shaders.shadow_compute);
    publish_compute = gpu::Compute(device, root.Get(), shaders.publish_compute);
    shadow_filter = gpu::Compute(device, root.Get(), shaders.shadow_filter);
    visibility_pipeline = gpu::Compute(device, root.Get(), shaders.visibility);
    sky_air_pipeline = gpu::Compute(device, root.Get(), shaders.sky_air);
    environment_pipeline = gpu::Compute(device, root.Get(), shaders.environment);
    atlas_capture_pipeline = gpu::Compute(device, root.Get(), shaders.atlas_capture);
    atlas_convert11 = gpu::Graphics(device, root.Get(), shaders.vertex, shaders.atlas_convert, DXGI_FORMAT_R11G11B10_FLOAT);
    atlas_convert16 = gpu::Graphics(device, root.Get(), shaders.vertex, shaders.atlas_convert, DXGI_FORMAT_R16G16B16A16_FLOAT);
    atlas_convert32 = gpu::Graphics(device, root.Get(), shaders.vertex, shaders.atlas_convert, DXGI_FORMAT_R32G32B32A32_FLOAT);
    noise_pipeline_ = gpu::Compute(device, root.Get(), shaders.noise);
    mip_pipeline_ = gpu::Compute(device, root.Get(), shaders.mips);
    profile_pipeline_ = gpu::Compute(device, root.Get(), shaders.profile);
    const std::array<uint8_t, gpu::HistoryBytes> empty{};
    zero = gpu::Upload(device, empty.data(), empty.size());
    moon = gpu::Upload(device, sky::moon_albedo.data(), sizeof(sky::moon_albedo));
    D3D12_COMMAND_QUEUE_DESC queue_desc{};
    gpu::Check(device->CreateCommandQueue(&queue_desc, IID_PPV_ARGS(&initialization_queue_)));
    gpu::Check(device->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&initialization_allocator_)));
    gpu::Check(device->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, initialization_allocator_.Get(), nullptr, IID_PPV_ARGS(&initialization_commands_)));
    initialization_commands_->SetComputeRootSignature(root.Get());
    profile = gpu::Image(device,128,1,DXGI_FORMAT_R16G16B16A16_FLOAT,16);
    gpu::Transition(initialization_commands_.Get(),&profile,D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    {
      auto bank=std::make_shared<gpu::Bank>(device);
      gpu::Uav(device,*bank,0,profile.object.Get(),0,true);
      ID3D12DescriptorHeap* heaps[]={bank->heap.Get()};
      initialization_commands_->SetDescriptorHeaps(1,heaps);
      initialization_commands_->SetComputeRootDescriptorTable(8,bank->Gpu(16));
      initialization_commands_->SetPipelineState(profile_pipeline_.Get());
      initialization_commands_->Dispatch(16,1,16);
      initialization_banks_.push_back(std::move(bank));
    }
    gpu::Transition(initialization_commands_.Get(),&profile,gpu::TextureRead);
    for (uint32_t variant = 0; variant < 2; ++variant) {
      const uint32_t size = variant ? 128 : 64;
      const uint16_t mip_count = variant ? 8 : 7;
      noise[variant] = gpu::Image(device, size, size, DXGI_FORMAT_R8G8B8A8_UNORM, uint16_t(size), mip_count, true);
      gpu::Transition(initialization_commands_.Get(), &noise[variant], D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
      for (uint32_t mip = 0; mip < mip_count; ++mip) {
        auto bank = std::make_shared<gpu::Bank>(device);
        gpu::Uav(device, *bank, 0, noise[variant].object.Get(), mip);
        if (mip) gpu::Srv(device, *bank, 0, noise[variant].object.Get(), D3D12_SRV_DIMENSION_TEXTURE3D, mip - 1, 1);
        ID3D12DescriptorHeap* heaps[] = {bank->heap.Get()};
        initialization_commands_->SetDescriptorHeaps(1, heaps);
        initialization_commands_->SetComputeRootDescriptorTable(7, bank->Gpu());
        initialization_commands_->SetComputeRootDescriptorTable(8, bank->Gpu(16));
        initialization_commands_->SetPipelineState(mip ? mip_pipeline_.Get() : noise_pipeline_.Get());
        initialization_commands_->Dispatch(((size >> mip) + 3) / 4, ((size >> mip) + 3) / 4, ((size >> mip) + 3) / 4);
        D3D12_RESOURCE_BARRIER barrier{};
        barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
        barrier.Transition = {noise[variant].object.Get(), mip, D3D12_RESOURCE_STATE_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE};
        initialization_commands_->ResourceBarrier(1, &barrier);
        initialization_banks_.push_back(std::move(bank));
      }
      noise[variant].state = D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE;
      gpu::Transition(initialization_commands_.Get(), &noise[variant], gpu::TextureRead);
    }
    fast = gpu::Image(device, 128, 128, DXGI_FORMAT_R8_UNORM, 32, 1, true);
    D3D12_PLACED_SUBRESOURCE_FOOTPRINT footprint{};
    uint64_t bytes = 0;
    const auto fast_desc = fast.object->GetDesc();
    device->GetCopyableFootprints(&fast_desc, 0, 1, 0, &footprint, nullptr, nullptr, &bytes);
    std::vector<uint8_t> pixels(size_t(bytes), 0);
    for (uint32_t z = 0; z < 32; ++z)
      for (uint32_t y = 0; y < 128; ++y)
        std::memcpy(pixels.data() + footprint.Offset + (z * 128 + y) * footprint.Footprint.RowPitch,
                    witcher3classic::clouds::fast_noise + (z * 128 + y) * 128, 128);
    fast_upload_ = gpu::Upload(device, pixels.data(), pixels.size());
    gpu::Transition(initialization_commands_.Get(), &fast, D3D12_RESOURCE_STATE_COPY_DEST);
    D3D12_TEXTURE_COPY_LOCATION source{fast_upload_.object.Get(), D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
    source.PlacedFootprint = footprint;
    D3D12_TEXTURE_COPY_LOCATION destination{fast.object.Get(), D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
    initialization_commands_->CopyTextureRegion(&destination, 0, 0, 0, &source, nullptr);
    gpu::Transition(initialization_commands_.Get(), &fast, gpu::TextureRead);
    gpu::Check(initialization_commands_->Close());
    ID3D12CommandList* commands[] = {initialization_commands_.Get()};
    gpu::Check(device->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&ready)));
    initialization_queue_->ExecuteCommandLists(1, commands);
    gpu::Check(initialization_queue_->Signal(ready.Get(), 1));
  }
  ID3D12Device* Device() const { return device_; }
  gpu::ComPtr<ID3D12RootSignature> root;
  gpu::ComPtr<ID3D12PipelineState> trace, resolve, weather, shadow, publish, composite16, composite32;
  gpu::ComPtr<ID3D12PipelineState> weather_compute, shadow_compute, publish_compute, shadow_filter, visibility_pipeline, sky_air_pipeline, environment_pipeline, atlas_capture_pipeline;
  gpu::ComPtr<ID3D12PipelineState> atlas_convert11, atlas_convert16, atlas_convert32;
  std::array<gpu::Resource, 2> noise;
  gpu::Resource fast, zero, profile, moon;
  gpu::ComPtr<ID3D12Fence> ready;

 private:
  ID3D12Device* device_ = nullptr;
  gpu::ComPtr<ID3D12CommandQueue> initialization_queue_;
  gpu::ComPtr<ID3D12CommandAllocator> initialization_allocator_;
  gpu::ComPtr<ID3D12GraphicsCommandList> initialization_commands_;
  gpu::ComPtr<ID3D12PipelineState> noise_pipeline_, mip_pipeline_, profile_pipeline_;
  gpu::Resource fast_upload_;
  std::vector<std::shared_ptr<gpu::Bank>> initialization_banks_;
};
// All descriptors in a recording are immutable. Inputs that change their view
// or underlying resource receive a new binding set, retained until retirement.
struct Bindings {
  std::shared_ptr<gpu::Bank> weather, trace, resolve, composite, shadow, visibility, sky_air, environment, publish_weather, publish_cloud;
  std::array<std::shared_ptr<gpu::Bank>,6> shadow_filters;
  gpu::ComPtr<ID3D12Resource> weather_input, depth_input;
  D3D12_SHADER_RESOURCE_VIEW_DESC weather_view{}, depth_view{};
  uint32_t noise_size = 0;
  bool Matches(const Inputs& inputs, uint32_t noise) const {
    return weather_input.Get() == inputs.weather && depth_input.Get() == inputs.depth && noise_size == noise
        && std::memcmp(&weather_view, &inputs.weather_view, sizeof(weather_view)) == 0
        && (!inputs.depth || std::memcmp(&depth_view, &inputs.depth_view, sizeof(depth_view)) == 0);
  }
};
class View {
 public:
  View(Assets* assets, uint32_t width, uint32_t height, float quality_value, DXGI_FORMAT target_format = DXGI_FORMAT_UNKNOWN,
       std::shared_ptr<gpu::Resource> lighting = {})
      : assets_(assets), width_(width), height_(height) {
    const auto samples = Quality(quality_value);
    const auto level = QualityLevel(quality_value);
    low_width_ = (width + samples[0] - 1) / samples[0];
    low_height_ = (height + samples[0] - 1) / samples[0];
    constexpr std::array<std::array<uint32_t, 2>, 6> shadows{{{384, 32}, {768, 48}, {768, 64}, {1024, 80}, {1536, 112}, {2048, 160}}};
    shadow_size_ = shadows[level][0];
    shadow_steps_ = shadows[level][1];
    auto* device = assets->Device();
    for (uint32_t index = 0; index < images_.size(); ++index)
      images_[index] = gpu::Image(device, low_width_, low_height_, index % 2 ? DXGI_FORMAT_R32_FLOAT : DXGI_FORMAT_R16G16B16A16_FLOAT);
    environment_[0]=gpu::Image(device,256,128,DXGI_FORMAT_R16G16B16A16_FLOAT);
    environment_[1]=gpu::Image(device,256,128,DXGI_FORMAT_R32_FLOAT);
    environment_header_=gpu::Buffer(device,144,gpu::TextureRead);
    // RG stores resolved coverage and the storm-profile weight, not transient
    // source/target channel identities. Both advance only a little per frame.
    // FP16 accumulation can stall until the source change crosses an ULP.
    for (auto& image : weather_) image = gpu::Image(device, 512, 512, DXGI_FORMAT_R32G32_FLOAT);
    cloud_history_ = gpu::Buffer(device, gpu::HistoryBytes, gpu::HistoryRead);
    weather_history_ = gpu::Buffer(device, gpu::HistoryBytes, gpu::HistoryRead);
    shadow_raw_ = gpu::Image(device, shadow_size_, shadow_size_, DXGI_FORMAT_R16G16_FLOAT);
    for(uint32_t level=0;level<shadow_levels_.size();++level)
      shadow_levels_[level]=gpu::Image(device,shadow_size_>>level,shadow_size_>>level,DXGI_FORMAT_R16G16_FLOAT);
    shadow_metadata_ = gpu::Buffer(device, 240, gpu::TextureRead);
    // Coarser lighting grids changed cloud-body brightness appreciably in the
    // matched capture. Even Performance retains the accepted 256-wide field.
    volume_width_=level>=3u?384u:level>=1u ||quality_preset==1.f?256u:128u;
    volume_depth_=level>=3u?48u:32u;
    visibility_=gpu::Image(device,volume_width_,volume_width_,DXGI_FORMAT_R16_FLOAT,uint16_t(volume_depth_),1,true);
    visibility_history_=gpu::Image(device,volume_width_,volume_width_,DXGI_FORMAT_R16_FLOAT,uint16_t(volume_depth_),1,true);
    sky_air_=gpu::Image(device,128,64,DXGI_FORMAT_R16G16B16A16_FLOAT,32,1,true);
    if (target_format != DXGI_FORMAT_UNKNOWN) {
      scene_before_=gpu::Image(device,width,height,target_format);
      scene_without_sun_=gpu::Image(device,width,height,target_format);
      scene_without_moon_=gpu::Image(device,width,height,target_format);
    }
    lighting_ = lighting ? std::move(lighting) : std::make_shared<gpu::Resource>(gpu::Buffer(device, 256, gpu::HistoryRead));
    const auto motion_desc = images_[6].object->GetDesc();
    uint64_t end=512;
    for(uint32_t level=0;level<shadow_levels_.size();++level) {
      uint64_t bytes=0;
      const auto desc=shadow_levels_[level].object->GetDesc();
      device->GetCopyableFootprints(&desc,0,1,end,&shadow_footprints_[level],nullptr,nullptr,&bytes);
      end=(shadow_footprints_[level].Offset+uint64_t(shadow_footprints_[level].Footprint.RowPitch)*desc.Height+511)&~511ull;
    }
    motion_offset_=end;
    uint64_t bytes = 0;
    device->GetCopyableFootprints(&motion_desc, 0, 1, motion_offset_, &motion_footprint_, nullptr, nullptr, &bytes);
    // GetCopyableFootprints reports the required end relative to BaseOffset.
    celestial_offset_=(motion_offset_+bytes+255u)&~255ull;
    shared_ = gpu::Buffer(device, celestial_offset_+sizeof(sky::moon_albedo), gpu::TextureRead);
  }
  uint32_t Width() const { return width_; }
  uint32_t Height() const { return height_; }
  uint32_t LowWidth() const { return low_width_; }
  uint32_t LowHeight() const { return low_height_; }
  uint32_t ShadowSize() const { return shadow_size_; }
  ID3D12Resource* Shared() const { return shared_.object.Get(); }
  ID3D12Resource* Resolved() const { return images_[2].object.Get(); }
  ID3D12Resource* Motion() const { return images_[6].object.Get(); }
  ID3D12Resource* EnvironmentRadiance() const { return environment_[0].object.Get(); }
  ID3D12Resource* EnvironmentDepth() const { return environment_[1].object.Get(); }
  ID3D12Resource* EnvironmentHeader() const { return environment_header_.object.Get(); }
  ID3D12Resource* History() const { return cloud_history_.object.Get(); }
  const std::shared_ptr<gpu::Resource>& LightingStorage() const { return lighting_; }
  uint64_t Bytes() const {
    uint64_t bytes = 0;
    for (const auto& image : images_) bytes += AllocationBytes(image);
    for (const auto& image : environment_) bytes += AllocationBytes(image);
    bytes += AllocationBytes(environment_header_);
    for (const auto& image : weather_) bytes += AllocationBytes(image);
    for (const auto* resource : {&cloud_history_, &weather_history_, &shadow_raw_, &shadow_metadata_, &visibility_, &visibility_history_, &sky_air_, &shared_}) bytes += AllocationBytes(*resource);
    if (scene_before_.object) bytes += AllocationBytes(scene_before_);
    if (scene_without_sun_.object) bytes += AllocationBytes(scene_without_sun_);
    if (scene_without_moon_.object) bytes += AllocationBytes(scene_without_moon_);
    for(const auto& level:shadow_levels_)bytes+=AllocationBytes(level);
    return bytes + AllocationBytes(*lighting_);
  }
  Bindings PrepareBindings(const Inputs& inputs, uint32_t noise_size) const {
    Bindings result;
    result.weather_input = inputs.weather;
    result.depth_input = inputs.depth;
    result.weather_view = inputs.weather_view;
    result.depth_view = inputs.depth_view;
    result.noise_size = noise_size;
    auto* device = assets_->Device();
    auto base = [&](const gpu::Resource* history) {
      auto bank = std::make_shared<gpu::Bank>(device);
      gpu::Srv(device, *bank, 0, assets_->noise[noise_size > 64].object.Get(), D3D12_SRV_DIMENSION_TEXTURE3D);
      gpu::Srv(device, *bank, 1, weather_[0].object.Get(), D3D12_SRV_DIMENSION_TEXTURE2DARRAY);
      if (inputs.depth) device->CreateShaderResourceView(inputs.depth, &inputs.depth_view, bank->Cpu(2));
      gpu::Srv(device, *bank, 7, assets_->fast.object.Get(), D3D12_SRV_DIMENSION_TEXTURE3D);
      gpu::Srv(device, *bank, 8, shared_.object.Get(), D3D12_SRV_DIMENSION_BUFFER);
      gpu::Srv(device, *bank, 9, history->object.Get(), D3D12_SRV_DIMENSION_BUFFER);
      gpu::Srv(device, *bank, 11, assets_->profile.object.Get(), D3D12_SRV_DIMENSION_TEXTURE2DARRAY);
      gpu::Srv(device, *bank, 12, visibility_.object.Get(), D3D12_SRV_DIMENSION_TEXTURE3D);
      gpu::Srv(device, *bank, 13, visibility_history_.object.Get(), D3D12_SRV_DIMENSION_TEXTURE3D);
      gpu::Srv(device, *bank, 15, sky_air_.object.Get(), D3D12_SRV_DIMENSION_TEXTURE3D);
      gpu::Uav(device, *bank, 2, shared_.object.Get());
      gpu::Uav(device, *bank, 3, history->object.Get());
      return bank;
    };
    result.weather = base(&weather_history_);
    device->CreateShaderResourceView(inputs.weather, &inputs.weather_view, result.weather->Cpu(1));
    gpu::Srv(device, *result.weather, 3, weather_[1].object.Get(), D3D12_SRV_DIMENSION_TEXTURE2DARRAY);
    gpu::Uav(device, *result.weather, 0, weather_[0].object.Get(), 0, true);
    result.trace = base(&cloud_history_);
    gpu::Uav(device, *result.trace, 0, images_[0].object.Get());
    gpu::Uav(device, *result.trace, 1, images_[1].object.Get());
    result.resolve = base(&cloud_history_);
    for (uint32_t index = 0; index < 4; ++index)
      gpu::Srv(device, *result.resolve, 3 + index, images_[index < 2 ? index : index + 2].object.Get(), D3D12_SRV_DIMENSION_TEXTURE2D);
    gpu::Uav(device, *result.resolve, 0, images_[2].object.Get());
    gpu::Uav(device, *result.resolve, 1, images_[3].object.Get());
    gpu::Uav(device, *result.resolve, 2, images_[6].object.Get());
    result.composite = base(&cloud_history_);
    gpu::Srv(device,*result.composite,14,images_[0].object.Get(),D3D12_SRV_DIMENSION_TEXTURE2D);
    gpu::Srv(device, *result.composite, 3, images_[2].object.Get(), D3D12_SRV_DIMENSION_TEXTURE2D);
    gpu::Srv(device, *result.composite, 4, images_[3].object.Get(), D3D12_SRV_DIMENSION_TEXTURE2D);
    if (scene_before_.object) gpu::Srv(device,*result.composite,10,scene_before_.object.Get(),D3D12_SRV_DIMENSION_TEXTURE2D);
    if (scene_without_sun_.object) gpu::Srv(device,*result.composite,5,scene_without_sun_.object.Get(),D3D12_SRV_DIMENSION_TEXTURE2D);
    if (scene_without_moon_.object) gpu::Srv(device,*result.composite,6,scene_without_moon_.object.Get(),D3D12_SRV_DIMENSION_TEXTURE2D);
    result.shadow = base(&weather_history_);
    gpu::Uav(device, *result.shadow, 0, shadow_raw_.object.Get());
    gpu::Uav(device, *result.shadow, 1, shadow_metadata_.object.Get(), 0, false, 16);
    for(uint32_t level=0;level<shadow_levels_.size();++level) {
      auto& bank=result.shadow_filters[level]=base(&weather_history_);
      gpu::Srv(device,*bank,3,level?shadow_levels_[level-1].object.Get():shadow_raw_.object.Get(),D3D12_SRV_DIMENSION_TEXTURE2D);
      gpu::Uav(device,*bank,0,shadow_levels_[level].object.Get());
    }
    result.visibility=base(&weather_history_);
    gpu::Uav(device,*result.visibility,0,visibility_.object.Get());
    result.sky_air=std::make_shared<gpu::Bank>(device);
    gpu::Uav(device,*result.sky_air,0,sky_air_.object.Get());
    result.environment=base(&cloud_history_);
    gpu::Uav(device,*result.environment,0,environment_[0].object.Get());
    gpu::Uav(device,*result.environment,1,environment_[1].object.Get());
    gpu::Uav(device,*result.environment,2,environment_header_.object.Get());
    result.publish_weather = base(&weather_history_);
    result.publish_cloud = base(&cloud_history_);
    return result;
  }
  Parameters MakeParameters(const Inputs& inputs, float sky_density, uint32_t pass = 0) const {
    const auto samples = Quality(quality);
    Parameters result;
    result.dimensions = {float(low_width_), float(low_height_), float(width_), float(height_)};
    result.integration = {float(samples[1]), float(samples[2]), 0.f, 1.f};
    result.appearance = Appearance();
    result.atmosphere = Atmosphere(sky_density);
    result.scattering = QualityLighting(quality);
    const float daytime=sky::emission::daytime.load(std::memory_order_relaxed);
    result.scattering[2]*=LowSunSchedule(daytime);
    const auto& from=families::profiles[uint8_t(inputs.family)<std::size(families::profiles)?uint8_t(inputs.family):0];
    const auto& to=families::profiles[uint8_t(inputs.family>>8)<std::size(families::profiles)?uint8_t(inputs.family>>8):0];
    result.family_from={from.low[0],from.low[1],from.high[0],from.high[1]};
    result.family_to={to.low[0],to.low[1],to.high[0],to.high[1]};
    result.family_transition={std::bit_cast<float>(uint32_t(inputs.family>>16)),from.high[2],to.high[2],0.f};
    result.family_transition[0]=std::isfinite(result.family_transition[0])?std::clamp(result.family_transition[0],0.f,1.f):0.f;
    result.family_transition[3]=std::lerp(from.high[3],to.high[3],result.family_transition[0]);
    result.authoring=Authoring();
    result.celestial={std::clamp(sky::star_brightness,0.f,4.f),std::bit_cast<float>(uint32_t(celestial_offset_)),
        std::clamp(sky_density,0.f,4.f),std::bit_cast<float>(0x534B5931u)};
    result.identity = {inputs.revision, uint32_t(inputs.clock), uint32_t(inputs.clock >> 32),
        pass | (inputs.captured_clock ? 256u : 0u) | (inputs.captured_sun ? 512u : 0u)
            | (inputs.captured_moon ? 1024u : 0u) | (inputs.clock_capture ? 2048u : 0u) | (inputs.enhanced_sky ? 4096u : 0u)};
    if(daytime>=0.f)result.identity[3]|=8192u;
    result.storage = {motion_footprint_.Footprint.RowPitch, uint32_t(motion_footprint_.Offset), shadow_footprints_[0].Footprint.RowPitch, uint32_t(shadow_footprints_[0].Offset)};
    if (pass == 2) {
      result.dimensions = {float(shadow_size_), float(shadow_size_), 32000.f, float(shadow_steps_)};
      // The receiver blends clear and cloud-filtered sunlight with this weight.
      result.integration[0] = shadows > 0.f && density > 0.f && coverage > 0.f ? std::min(shadows, 1.f) : 0.f;
    }
    if (pass == 3) {
      result.dimensions = {256.f,128.f,256.f,128.f};
      result.scattering[1] = 0.f;
    }
    return result;
  }
  gpu::Resource ParameterPage(const Inputs& inputs, float sky_density, uint32_t pass = 0, gpu::UploadPool* pool = nullptr) const {
    std::array<uint8_t, 512> data{};
    const auto parameters = MakeParameters(inputs, sky_density, pass);
    std::memcpy(data.data(), &parameters, sizeof(parameters));
    std::memcpy(data.data() + 256, &inputs.fog_settings, sizeof(inputs.fog_settings));
    std::memcpy(data.data() + 320, inputs.moon_material.data(), sizeof(inputs.moon_material));
    std::memcpy(data.data() + 336, inputs.sun_material.data(), sizeof(inputs.sun_material));
    const float glow_size=std::clamp(sky::sun_glow_size,.25f,4.f);
    std::memcpy(data.data() + 352, &glow_size, sizeof(glow_size));
    std::memcpy(data.data() + 356, &inputs.sky_glow_exposure, sizeof(inputs.sky_glow_exposure));
    std::memcpy(data.data() + 368, inputs.native_radius.data(),sizeof(inputs.native_radius));
    const bool coherent=sky::emission::enabled.load(std::memory_order_relaxed);
    const auto solar=coherent?sky::emission::Unpack(sky::emission::sun.load(std::memory_order_relaxed)):std::array<float,4>{};
    const auto lunar=coherent?sky::emission::Unpack(sky::emission::moon.load(std::memory_order_relaxed)):std::array<float,4>{};
    std::memcpy(data.data()+384,solar.data(),sizeof(solar));
    std::memcpy(data.data()+400,lunar.data(),sizeof(lunar));
    const auto& from=families::profiles[uint8_t(inputs.family)<std::size(families::profiles)?uint8_t(inputs.family):0];
    const auto& to=families::profiles[uint8_t(inputs.family>>8)<std::size(families::profiles)?uint8_t(inputs.family>>8):0];
    const std::array<float,4> family_appearance{from.low[2],from.low[3],to.low[2],to.low[3]};
    std::memcpy(data.data()+416,family_appearance.data(),sizeof(family_appearance));
    return pool ? pool->Upload(assets_->Device(), data.data(), data.size())
                : gpu::Upload(assets_->Device(), data.data(), data.size());
  }
  // Each operation enters and leaves owned resources in their canonical read
  // state. Recorded lists can therefore execute in GPU order independently of
  // the order in which their CPU recording completed.
  void Weather(ID3D12GraphicsCommandList* cmd, const Inputs& inputs, const Bindings& banks,
               const gpu::Resource& page, bool compute = false) {
    Bind(cmd, inputs, page, weather_history_, compute);
    gpu::Transition(cmd, &weather_[0], D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    Pass(cmd, *banks.weather, compute ? assets_->weather_compute.Get() : assets_->weather.Get(), 512, 512, compute);
    gpu::Transition(cmd, &weather_[0], gpu::TextureRead);
    gpu::Copy(cmd, &weather_[1], &weather_[0]);
    Publish(cmd, weather_history_, *banks.publish_weather, compute);
  }
  void Shadow(ID3D12GraphicsCommandList* cmd, const Inputs& inputs, const Bindings& banks,
              const gpu::Resource& page) {
    Bind(cmd, inputs, page, weather_history_, true);
    gpu::Transition(cmd, &shadow_raw_, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    gpu::Transition(cmd, &shadow_metadata_, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    const uint32_t extent = shadows > 0.f && density > 0.f && coverage > 0.f ? shadow_size_ : 1u;
    Pass(cmd,*banks.shadow,assets_->shadow_compute.Get(),extent,extent,true);
    gpu::Transition(cmd, &shadow_raw_, gpu::TextureRead);
    Bind(cmd,inputs,page,weather_history_,true);
    for(uint32_t level=0;level<shadow_levels_.size();++level) {
      gpu::Transition(cmd,&shadow_levels_[level],D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
      Pass(cmd,*banks.shadow_filters[level],assets_->shadow_filter.Get(),shadow_size_>>level,shadow_size_>>level,true);
      gpu::Transition(cmd,&shadow_levels_[level],gpu::TextureRead);
    }
    gpu::Transition(cmd, &shadow_metadata_, D3D12_RESOURCE_STATE_COPY_SOURCE);
    gpu::Transition(cmd, lighting_.get(), D3D12_RESOURCE_STATE_COPY_DEST);
    cmd->CopyBufferRegion(lighting_->object.Get(), 0, shadow_metadata_.object.Get(), 96, 48);
    gpu::Transition(cmd, lighting_.get(), gpu::HistoryRead);
    gpu::Transition(cmd, &shared_, D3D12_RESOURCE_STATE_COPY_DEST);
    cmd->CopyBufferRegion(shared_.object.Get(), 0, shadow_metadata_.object.Get(), 0, 96);
    cmd->CopyBufferRegion(shared_.object.Get(), 224, shadow_metadata_.object.Get(), 144, 96);
    // Ambient alpha is unused by lighting. Cache the opening strength in an
    // existing reserved header word without disturbing the celestial header.
    cmd->CopyBufferRegion(shared_.object.Get(), 352, shadow_metadata_.object.Get(), 140, 4);
    cmd->CopyBufferRegion(shared_.object.Get(),celestial_offset_,assets_->moon.object.Get(),0,sizeof(sky::moon_albedo));
    for(uint32_t level=0;level<shadow_levels_.size();++level) {
      gpu::Transition(cmd,&shadow_levels_[level],D3D12_RESOURCE_STATE_COPY_SOURCE);
      D3D12_TEXTURE_COPY_LOCATION source{shadow_levels_[level].object.Get(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
      D3D12_TEXTURE_COPY_LOCATION destination{shared_.object.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
      destination.PlacedFootprint=shadow_footprints_[level];
      cmd->CopyTextureRegion(&destination,0,0,0,&source,nullptr);
      gpu::Transition(cmd,&shadow_levels_[level],gpu::TextureRead);
    }
    gpu::Transition(cmd, &shadow_metadata_, gpu::TextureRead);
    gpu::Transition(cmd, &shared_, gpu::TextureRead);
  }
  void CaptureSun(ID3D12GraphicsCommandList* cmd, ID3D12Resource* target) {
    CopyScene(cmd, target, &scene_without_sun_);
  }
  void CaptureMoon(ID3D12GraphicsCommandList* cmd, ID3D12Resource* target) {
    CopyScene(cmd, target, &scene_without_moon_);
  }
  void Render(ID3D12GraphicsCommandList* cmd, const Inputs& inputs, const Bindings& banks, const gpu::Resource& page) {
    Bind(cmd,inputs,page,cloud_history_,true);
    gpu::Transition(cmd,&sky_air_,D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    {
      ID3D12DescriptorHeap* heaps[]={banks.sky_air->heap.Get()};
      cmd->SetDescriptorHeaps(1,heaps);
      cmd->SetComputeRootDescriptorTable(7,banks.sky_air->Gpu());
      cmd->SetComputeRootDescriptorTable(8,banks.sky_air->Gpu(16));
      cmd->SetPipelineState(assets_->sky_air_pipeline.Get());
      cmd->Dispatch(16,8,4);
    }
    gpu::Transition(cmd,&sky_air_,gpu::TextureRead);
    gpu::Transition(cmd,&visibility_,D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    for(uint32_t slice=volume_depth_;slice>0;--slice) {
      cmd->SetComputeRoot32BitConstant(11,slice-1u,0);
      Pass(cmd,*banks.visibility,assets_->visibility_pipeline.Get(),volume_width_,volume_width_,true);
      D3D12_RESOURCE_BARRIER barrier{};
      barrier.Type=D3D12_RESOURCE_BARRIER_TYPE_UAV;
      barrier.UAV.pResource=visibility_.object.Get();
      cmd->ResourceBarrier(1,&barrier);
    }
    gpu::Transition(cmd,&visibility_,gpu::TextureRead);
    gpu::Copy(cmd,&visibility_history_,&visibility_);
    Bind(cmd, inputs, page, cloud_history_, false);
    for (uint32_t index : {0u, 1u}) gpu::Transition(cmd, &images_[index], D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    Pass(cmd, *banks.trace, assets_->trace.Get(), low_width_, low_height_, false);
    for (uint32_t index : {0u, 1u}) gpu::Transition(cmd, &images_[index], gpu::TextureRead);
    for (uint32_t index : {2u, 3u, 6u}) gpu::Transition(cmd, &images_[index], D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    Pass(cmd, *banks.resolve, assets_->resolve.Get(), low_width_, low_height_, false);
    for (uint32_t index : {2u, 3u, 6u}) gpu::Transition(cmd, &images_[index], gpu::TextureRead);
    // Keep the exact native sun addition separate from the sky. Its earlier
    // target snapshot was taken immediately before the native sun draw.
    if(!inputs.enhanced_sky)CopyScene(cmd, inputs.target_resource, &scene_before_);
    cmd->OMSetRenderTargets(1, &inputs.target, FALSE, nullptr);
    Pass(cmd, *banks.composite, inputs.target_format == DXGI_FORMAT_R32G32B32A32_FLOAT ? assets_->composite32.Get() : assets_->composite16.Get(), width_, height_, false, true);
    gpu::Copy(cmd, &images_[4], &images_[2]);
    gpu::Copy(cmd, &images_[5], &images_[3]);
    gpu::Transition(cmd, &images_[6], D3D12_RESOURCE_STATE_COPY_SOURCE);
    gpu::Transition(cmd, &shared_, D3D12_RESOURCE_STATE_COPY_DEST);
    D3D12_TEXTURE_COPY_LOCATION source{images_[6].object.Get(), D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
    D3D12_TEXTURE_COPY_LOCATION destination{shared_.object.Get(), D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
    destination.PlacedFootprint = motion_footprint_;
    cmd->CopyTextureRegion(&destination, 0, 0, 0, &source, nullptr);
    gpu::Transition(cmd, &images_[6], gpu::TextureRead);
    gpu::Transition(cmd, &shared_, gpu::TextureRead);
    Publish(cmd, cloud_history_, *banks.publish_cloud, false);
  }
  // The hemisphere/reflection atlas is built on demand from this simplified
  // full-sphere result. Main-view depth and foreground aerial perspective do
  // not belong in a ray-lighting representation.
  void Environment(ID3D12GraphicsCommandList* cmd, const Inputs& inputs, const Bindings& banks,
                   const gpu::Resource& page) {
    Bind(cmd,inputs,page,cloud_history_,true);
    for(auto& image:environment_)gpu::Transition(cmd,&image,D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    gpu::Transition(cmd,&environment_header_,D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    Pass(cmd,*banks.environment,assets_->environment_pipeline.Get(),256,128,true);
    for(auto& image:environment_)gpu::Transition(cmd,&image,gpu::TextureRead);
    gpu::Transition(cmd,&environment_header_,gpu::TextureRead);
  }

 private:
  void Bind(ID3D12GraphicsCommandList* cmd, const Inputs& inputs, const gpu::Resource& page, const gpu::Resource& history, bool compute) {
    if (compute) cmd->SetComputeRootSignature(assets_->root.Get());
    else cmd->SetGraphicsRootSignature(assets_->root.Get());
    const uint64_t address = history.object->GetGPUVirtualAddress();
    const uint64_t values[] = {inputs.frame, inputs.light, page.object->GetGPUVirtualAddress(), address,
                              address + gpu::ParametersOffset, inputs.clock, address + gpu::ClockOffset};
    for (uint32_t index = 0; index < 7; ++index) {
      if (compute) cmd->SetComputeRootConstantBufferView(index, values[index]);
      else cmd->SetGraphicsRootConstantBufferView(index, values[index]);
    }
    if(compute)cmd->SetComputeRootConstantBufferView(12,inputs.clock_capture ? inputs.clock_capture : assets_->zero.object->GetGPUVirtualAddress());
    else cmd->SetGraphicsRootConstantBufferView(12,inputs.clock_capture ? inputs.clock_capture : assets_->zero.object->GetGPUVirtualAddress());
    if (!compute) {
      cmd->SetGraphicsRootConstantBufferView(9, page.object->GetGPUVirtualAddress() + 256);
      cmd->SetGraphicsRootShaderResourceView(10, inputs.fog ? inputs.fog : assets_->zero.object->GetGPUVirtualAddress());
      cmd->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    }
  }
  void Pass(ID3D12GraphicsCommandList* cmd, const gpu::Bank& bank, ID3D12PipelineState* pipeline,
            uint32_t width, uint32_t height, bool compute, bool target = false) {
    ID3D12DescriptorHeap* heaps[] = {bank.heap.Get()};
    cmd->SetDescriptorHeaps(1, heaps);
    cmd->SetPipelineState(pipeline);
    if (compute) {
      cmd->SetComputeRootDescriptorTable(7, bank.Gpu());
      cmd->SetComputeRootDescriptorTable(8, bank.Gpu(16));
      cmd->Dispatch((width + 7) / 8, (height + 7) / 8, 1);
    } else {
      cmd->SetGraphicsRootDescriptorTable(7, bank.Gpu());
      cmd->SetGraphicsRootDescriptorTable(8, bank.Gpu(16));
      if (!target) cmd->OMSetRenderTargets(0, nullptr, FALSE, nullptr);
      const D3D12_VIEWPORT viewport{0, 0, float(width), float(height), 0, 1};
      const D3D12_RECT scissor{0, 0, LONG(width), LONG(height)};
      cmd->RSSetViewports(1, &viewport);
      cmd->RSSetScissorRects(1, &scissor);
      cmd->DrawInstanced(3, 1, 0, 0);
    }
  }
  void Publish(ID3D12GraphicsCommandList* cmd, gpu::Resource& history, const gpu::Bank& bank, bool compute) {
    gpu::Transition(cmd, &history, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    gpu::Transition(cmd, &shared_, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    if (compute) {
      ID3D12DescriptorHeap* heaps[] = {bank.heap.Get()};
      cmd->SetDescriptorHeaps(1, heaps);
      cmd->SetPipelineState(assets_->publish_compute.Get());
      cmd->SetComputeRootDescriptorTable(7, bank.Gpu());
      cmd->SetComputeRootDescriptorTable(8, bank.Gpu(16));
      cmd->Dispatch(6, 1, 1);
    } else Pass(cmd, bank, assets_->publish.Get(), 341, 1, false);
    gpu::Transition(cmd, &history, gpu::HistoryRead);
    gpu::Transition(cmd, &shared_, gpu::TextureRead);
  }
  uint64_t AllocationBytes(const gpu::Resource& resource) const {
    const auto desc = resource.object->GetDesc();
    return assets_->Device()->GetResourceAllocationInfo(0, 1, &desc).SizeInBytes;
  }
  void CopyScene(ID3D12GraphicsCommandList* cmd, ID3D12Resource* target, gpu::Resource* destination) {
    D3D12_RESOURCE_BARRIER barrier{};
    barrier.Type=D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    barrier.Transition={target,D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
        D3D12_RESOURCE_STATE_RENDER_TARGET,D3D12_RESOURCE_STATE_COPY_SOURCE};
    cmd->ResourceBarrier(1,&barrier);
    gpu::Transition(cmd,destination,D3D12_RESOURCE_STATE_COPY_DEST);
    D3D12_TEXTURE_COPY_LOCATION source{target,D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
    D3D12_TEXTURE_COPY_LOCATION copy{destination->object.Get(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
    D3D12_BOX viewport{0,0,0,width_,height_,1};
    cmd->CopyTextureRegion(&copy,0,0,0,&source,&viewport);
    gpu::Transition(cmd,destination,gpu::TextureRead);
    std::swap(barrier.Transition.StateBefore,barrier.Transition.StateAfter);
    cmd->ResourceBarrier(1,&barrier);
  }
  Assets* assets_;
  uint32_t width_, height_, low_width_, low_height_, shadow_size_, shadow_steps_, volume_width_, volume_depth_;
  std::array<gpu::Resource, 7> images_;
  std::array<gpu::Resource, 2> environment_;
  gpu::Resource environment_header_;
  std::array<gpu::Resource, 2> weather_;
  gpu::Resource cloud_history_, weather_history_, shadow_raw_, shadow_metadata_, visibility_, visibility_history_, sky_air_, scene_before_, scene_without_sun_, scene_without_moon_, shared_;
  std::array<gpu::Resource,6> shadow_levels_;
  std::shared_ptr<gpu::Resource> lighting_;
  uint64_t motion_offset_ = 0, celestial_offset_ = 0;
  std::array<D3D12_PLACED_SUBRESOURCE_FOOTPRINT,6> shadow_footprints_{};
  D3D12_PLACED_SUBRESOURCE_FOOTPRINT motion_footprint_{};
};
// The engine alternates weather resources between native passes. Keep their
// immutable bindings together, rather than rebuilding every heap on a switch.
// Native resource ownership prevents pointer recycling from matching stale SRVs.
class BindingCache {
 public:
  std::shared_ptr<Bindings> Acquire(const View& view, const Inputs& inputs, uint32_t noise_size) {
    for (const auto& item : entries_) if (item->Matches(inputs, noise_size)) return item;
    if (entries_.size() == 8) {
      const auto idle = std::find_if(entries_.begin(), entries_.end(), [](const auto& item) { return item.use_count() == 1; });
      entries_.erase(idle == entries_.end() ? entries_.begin() : idle);
    }
    return entries_.emplace_back(std::make_shared<Bindings>(view.PrepareBindings(inputs, noise_size)));
  }
  size_t Size() const { return entries_.size(); }
 private:
  std::vector<std::shared_ptr<Bindings>> entries_;
};
}  // namespace hartapfelfx::clouds
