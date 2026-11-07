// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Exercises the production D3D12 cloud pipeline without a game process.
#include <d3d12sdklayers.h>
#include <DirectXPackedVector.h>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <cmath>
#include <string_view>
#include "../clouds/pipeline.hpp"
#include "../clouds/atlas.hpp"
namespace clouds = hartapfelfx::clouds;
namespace gpu = clouds::gpu;
using gpu::ComPtr;
void Require(bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}
std::vector<char> Read(const std::filesystem::path& path) {
  std::ifstream stream(path, std::ios::binary);
  if (!stream) throw std::runtime_error("Missing shader " + path.string());
  return {std::istreambuf_iterator<char>(stream), {}};
}
int main(int argc, char** argv) {
  try {
    const std::string_view operation=argc>=3?std::string_view(argv[2]):std::string_view{};
    const bool benchmark=argc==3 && operation.starts_with("benchmark");
    const bool capture=argc==4 && operation.starts_with("capture");
    const bool sun_probe=(benchmark || capture) && operation.find("sun")!=std::string_view::npos;
    const bool moon_probe=(benchmark || capture) && operation.find("moon")!=std::string_view::npos;
    const bool sparse_probe=(benchmark || capture) && operation.find("sparse")!=std::string_view::npos;
    const bool soft_probe=(benchmark || capture) && operation.find("soft")!=std::string_view::npos;
    const float sky_density=operation.find("haze200")!=std::string_view::npos ? 2.f : 1.f;
    Require(argc==2 || benchmark || capture,"Expected compiled shader directory, optional benchmark/capture with sun or sparse suffix");
    Require(clouds::Appearance()==std::array<float,4>{1.f,1.f,1.f,1.f},
        "Cloud appearance defaults must be neutral multipliers");
    Require(clouds::Atmosphere(1.f)==std::array<float,4>{1.f,1.f,1.f,0.f},
        "Cloud detail defaults must be neutral multipliers");
    const bool screenshot_settings=operation.find("user")!=std::string_view::npos;
    if(screenshot_settings) {
      clouds::coverage=1.3f; clouds::density=.12f; clouds::size=.6f;
      clouds::thickness=.6f; clouds::detail=1.f; clouds::detail_size=.5f;
      clouds::base_softness=0.f;
      if(operation.find("cover000")!=std::string_view::npos)clouds::coverage=0.f;
      if(operation.find("cover100")!=std::string_view::npos)clouds::coverage=1.f;
      if(operation.find("cover200")!=std::string_view::npos)clouds::coverage=2.f;
      if(operation.find("size100")!=std::string_view::npos)clouds::size=1.f;
      if(operation.find("size200")!=std::string_view::npos)clouds::size=2.f;
      if(operation.find("density100")!=std::string_view::npos)clouds::density=1.f;
    }
    ComPtr<ID3D12Debug> debug;
    if (SUCCEEDED(D3D12GetDebugInterface(IID_PPV_ARGS(&debug)))) debug->EnableDebugLayer();
    ComPtr<ID3D12Device> device;
    gpu::Check(D3D12CreateDevice(nullptr, D3D_FEATURE_LEVEL_12_0, IID_PPV_ARGS(&device)));
    std::vector<std::vector<char>> code;
    const std::filesystem::path directory(argv[1]);
    auto shader = [&](const char* name) {
      code.push_back(Read(directory / name));
      return D3D12_SHADER_BYTECODE{code.back().data(), code.back().size()};
    };
    clouds::Assets assets;
    assets.Initialize(device.Get(), {
        shader("0xF7F00001.cso"), shader("0xF7C00001.cso"), shader("0xF7C00008.cso"),
        shader("0xF7C00002.cso"), shader("0xF7C00003.cso"), shader("0xF7C00004.cso"),
        shader("0xF7C00007.cso"), shader("0xF7C00006.cso"), shader("0xF7C00009.cso"),
        shader("0xF7C0000A.cso"), shader("0xF7C0000B.cso"), shader("0xF7C0000C.cso"), shader("0xF7C0000E.cso"), shader("0xF7C0000F.cso"), shader("0xF7C00010.cso"), shader("0xF7C00011.cso"), shader("0xF7C00012.cso"), shader("0xF7C00013.cso"), shader("0xF7C00014.cso"), shader("0xF7C00015.cso"), shader("0xF7C00016.cso")});
    ComPtr<ID3D12CommandQueue> queue;
    const D3D12_COMMAND_QUEUE_DESC queue_desc{};
    gpu::Check(device->CreateCommandQueue(&queue_desc, IID_PPV_ARGS(&queue)));
    gpu::Check(queue->Wait(assets.ready.Get(), 1));
    ComPtr<ID3D12CommandAllocator> allocator;
    ComPtr<ID3D12GraphicsCommandList> cmd;
    gpu::Check(device->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&allocator)));
    gpu::Check(device->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, allocator.Get(), nullptr, IID_PPV_ARGS(&cmd)));
    gpu::Check(cmd->Close());
    ComPtr<ID3D12Fence> fence;
    gpu::Check(device->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&fence)));
    const HANDLE event = CreateEvent(nullptr, FALSE, FALSE, nullptr);
    Require(event != nullptr, "Fence event creation failed");
    uint64_t serial = 0;
    auto begin = [&]() {
      gpu::Check(allocator->Reset());
      gpu::Check(cmd->Reset(allocator.Get(), nullptr));
    };
    auto submit = [&]() {
      gpu::Check(cmd->Close());
      ID3D12CommandList* lists[] = {cmd.Get()};
      queue->ExecuteCommandLists(1, lists);
      gpu::Check(queue->Signal(fence.Get(), ++serial));
      gpu::Check(fence->SetEventOnCompletion(serial, event));
      Require(WaitForSingleObject(event, 60000) == WAIT_OBJECT_0, "Cloud GPU timeout");
      gpu::Check(device->GetDeviceRemovedReason());
    };
    const auto feature_code = Read(directory / "cloud-features.cso");
    std::array<D3D12_ROOT_PARAMETER, 4> feature_parameters{};
    feature_parameters[0].ParameterType = D3D12_ROOT_PARAMETER_TYPE_SRV;
    feature_parameters[0].Descriptor = {0, 72};
    feature_parameters[1].ParameterType = feature_parameters[2].ParameterType = D3D12_ROOT_PARAMETER_TYPE_CBV;
    feature_parameters[1].Descriptor = {12, 0}; feature_parameters[2].Descriptor = {0, 73};
    feature_parameters[3].ParameterType = D3D12_ROOT_PARAMETER_TYPE_UAV;
    feature_parameters[3].Descriptor = {0, 73};
    const D3D12_ROOT_SIGNATURE_DESC feature_desc{4, feature_parameters.data()};
    ComPtr<ID3DBlob> feature_blob, feature_errors;
    gpu::Check(D3D12SerializeRootSignature(&feature_desc, D3D_ROOT_SIGNATURE_VERSION_1, &feature_blob, &feature_errors));
    ComPtr<ID3D12RootSignature> feature_root;
    gpu::Check(device->CreateRootSignature(0, feature_blob->GetBufferPointer(), feature_blob->GetBufferSize(), IID_PPV_ARGS(&feature_root)));
    const auto feature_pipeline = gpu::Compute(device.Get(), feature_root.Get(), {feature_code.data(), feature_code.size()});
    auto feature_output = gpu::Buffer(device.Get(), 256, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    auto feature_readback = gpu::Buffer(device.Get(), 256, D3D12_RESOURCE_STATE_COPY_DEST, D3D12_HEAP_TYPE_READBACK);
    const uint32_t width = benchmark || capture ? 1920u : 160u, height = benchmark || capture ? 1080u : 90u;
    std::array<std::array<float, 4>, 352> frame{};
    frame[1] = {1, 0, 0, 0}; frame[2] = {0, -.4472136f, .8944272f, 0};
    frame[3] = {0, .8944272f, .4472136f, 0}; frame[4] = {0, 0, 0, 1};
    frame[13] = {1, 0, 0, 0}; frame[14] = {0, 1, 0, 0};
    frame[15] = {0, 0, 1.00004f, 1}; frame[16] = {0, 0, -.200008f, 0};
    frame[17] = {1, 0, 0, 0}; frame[18] = frame[2];
    frame[19] = {0, 0, 0, -4.9998f}; frame[20] = {0, .8944272f, .4472136f, 5};
    frame[22] = {-1, 1, .2f, 5000}; frame[23] = {float(width), float(height), 1.f / width, 1.f / height};
    frame[66] = {5, 0, 0, 0}; frame[68] = {0, 1, 0, 0};
    for (uint32_t index : {195u, 196u, 197u, 198u}) frame[index] = {.1f, .2f, .4f, 0};
    frame[203] = {1, 1, 1, 0}; frame[204] = {1, 0, 1, 1};
    frame[205] = {1, 0, -1, -1}; frame[206] = {1, 0, 0, 0};
    if(operation.find("mountain")!=std::string_view::npos) {
      // Keep the view direction unchanged while lifting the camera above
      // the cloud shell. Rays below the local horizontal can hit valid clouds.
      frame[0][2]=3000.f;
      frame[20][2]+=3000.f*2.5001f;
    }
    if(operation.find("horizon")!=std::string_view::npos) {
      // Archived native sky/fog values from the Witcher card draw, held fixed
      // so the horizon candidate can be compared without weather variation.
      frame[38]={.738275f,-.3932367f,.54801f,1.f};
      frame[39]={6.242582f,8.950297f,11.62129f,0.f};
      frame[40]={1.987138f,5.049555f,8.774604f,0.f};
      frame[41]={3.038936f,7.911013f,13.97275f,0.f};
      frame[42]={1.f,-39.11129f,6500.f,.7010639f};
      frame[44]={.0005149137f,.007702333f,.009379172f,0.f};
    }
    if(operation.find("nativeair")!=std::string_view::npos) {
      // One complete sky-air colour/weight state from the archived fair
      // weather b12 draw; a row-44-only fixture cannot exercise A(d).
      frame[38]={.31340495f,.803666f,.50586396f,1.f};
      frame[39]={3.8929381f,5.4128404f,6.5574446f,0.f};
      frame[40]={1.4416378f,2.6091237f,3.7860167f,0.f};
      frame[41]={1.584022f,2.7929676f,4.1314144f,0.f};
      frame[42]={1.f,-39.430004f,7000.f,1.1336342f};
      frame[44]={.0006865265f,.014535417f,.029400177f,0.f};
      frame[48]={33.12154f,1.f,.015136439f,0.f};
      frame[189]={4.242852f,4.0740724f,3.343817f,1.f};
      frame[190]={.5256118f,-.15825853f,1.f,-1.f};
      frame[191]=frame[189];frame[192]=frame[190];
      frame[193]={0.f,1.f,0.f,0.f};
      frame[195]={.000330371695f,.0752099901f,.200628698f,1.f};
      frame[196]={.0189004242f,.0209378507f,.0242372006f,1.f};
      frame[197]={.827476978f,.891605556f,1.f,1.f};
      frame[198]={.136865512f,.309490651f,.585973203f,1.f};
      frame[199]={.902134657f,1.28700888f,1.66059458f,7.56620693f};
      frame[200]={1.f,.487765223f,.124740966f,1.f};
      frame[201]={.36360392f,.306634784f,.297652662f,1.f};
      frame[202]={0.f,0.f,0.f,0.f};
      frame[203]={1.f,8.05089283f,1.81470275f,2.40367627f};
      frame[204]={120.055695f,.313979983f,.805139661f,.503156781f};
      frame[205]={34.322464f,.306988895f,.787216902f,-.534834087f};
      frame[206]={1.f,0.f,0.f};
    }
    if(operation.find("rainair")!=std::string_view::npos) {
      // Archived rainy native frame 1224: source layer 3, target layer 4.
      // The rainy scene has different ambient radiance, so compare the HDR
      // emitter's contribution with and without its target clear rectangle.
      frame[38]={-.40844f,.876065f,.256295f,1.f};
      frame[39]={4.123114f,2.968604f,1.225833f,0.f};
      frame[40]={1.092713f,1.972034f,2.779737f,0.f};
      frame[41]={1.458758f,2.547093f,3.746032f,0.f};
      frame[42]={1.f,-38.690338f,7000.f,1.092297f};
      frame[44]={.001567f,.026044f,.024355f,0.f};
      frame[66]={5.f,1.f,1522.861572f,1.f};
      frame[67]={9.834519f,48.918064f,1522.861572f,1.019439f};
      frame[68]={3.f,4.f,1.f,1.f};
      frame[195]={.00018f,.079963f,.206328f,1.f};
      frame[196]={.018695f,.020841f,.02423f,1.f};
      frame[197]={.905118f,.822205f,.614117f,1.f};
      frame[198]={.163328f,.322018f,.565276f,1.f};
      frame[200]={.958989f,.467761f,.119625f,1.f};
      frame[201]={.348692f,.294059f,.285446f,1.f};
      frame[203]={1.f,7.972577f,1.196943f,2.184094f};
      frame[204]={120.629112f,-.40357f,.86562f,.296366f};
      frame[205]={33.841206f,-.420951f,.902905f,-.086962f};
      frame[206]={1.f,0.f,0.f,0.f};
    }
    const std::array<std::array<float, 4>, 16> light{{{sun_probe ? 0.f : .1f,
        sun_probe ? .8944272f : .4f,sun_probe ? .4472136f : .91f,1}, {30, 20, 10, 0}}};
    auto frame_buffer = gpu::Upload(device.Get(), frame.data(), sizeof(frame));
    auto probe = [&](ID3D12Resource* field, const std::array<float, 12>& values) {
      std::array<float, 64> parameters{};
      std::copy(values.begin(), values.end(), parameters.begin());
      const auto page = gpu::Upload(device.Get(), parameters.data(), sizeof(parameters));
      begin();
      cmd->SetComputeRootSignature(feature_root.Get()); cmd->SetPipelineState(feature_pipeline.Get());
      cmd->SetComputeRootShaderResourceView(0, field->GetGPUVirtualAddress());
      cmd->SetComputeRootConstantBufferView(1, frame_buffer.object->GetGPUVirtualAddress());
      cmd->SetComputeRootConstantBufferView(2, page.object->GetGPUVirtualAddress());
      cmd->SetComputeRootUnorderedAccessView(3, feature_output.object->GetGPUVirtualAddress());
      cmd->Dispatch(1, 1, 1);
      gpu::Transition(cmd.Get(), &feature_output, D3D12_RESOURCE_STATE_COPY_SOURCE);
      cmd->CopyResource(feature_readback.object.Get(), feature_output.object.Get());
      gpu::Transition(cmd.Get(), &feature_output, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
      submit();
      void* mapped = nullptr;
      gpu::Check(feature_readback.object->Map(0, nullptr, &mapped));
      std::array<float, 16> result{};
      std::memcpy(result.data(), mapped, sizeof(result));
      feature_readback.object->Unmap(0, nullptr);
      return result;
    };
    auto light_buffer = gpu::Upload(device.Get(), light.data(), sizeof(light));
    auto depth = gpu::Image(device.Get(), width, height, DXGI_FORMAT_R32_FLOAT);
    auto weather = gpu::Image(device.Get(), 8, 8, DXGI_FORMAT_R32_FLOAT, 2);
    auto target_desc = depth.object->GetDesc();
    target_desc.Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
    target_desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET;
    auto target = gpu::Create(device.Get(), target_desc, D3D12_RESOURCE_STATE_RENDER_TARGET);
    ComPtr<ID3D12DescriptorHeap> rtv;
    const D3D12_DESCRIPTOR_HEAP_DESC rtv_desc{D3D12_DESCRIPTOR_HEAP_TYPE_RTV, 1};
    gpu::Check(device->CreateDescriptorHeap(&rtv_desc, IID_PPV_ARGS(&rtv)));
    device->CreateRenderTargetView(target.object.Get(), nullptr, rtv->GetCPUDescriptorHandleForHeapStart());
    clouds::Inputs inputs;
    inputs.frame = frame_buffer.object->GetGPUVirtualAddress();
    inputs.light = light_buffer.object->GetGPUVirtualAddress();
    inputs.weather = weather.object.Get(); inputs.depth = depth.object.Get();
    inputs.width = width; inputs.height = height; inputs.revision = 1;
    inputs.target = rtv->GetCPUDescriptorHandleForHeapStart();
    inputs.target_resource = target.object.Get();
    inputs.target_format = target_desc.Format;
    inputs.depth_view = {.Format = DXGI_FORMAT_R32_FLOAT, .ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2D, .Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING};
    inputs.depth_view.Texture2D.MipLevels = 1;
    inputs.weather_view = {.Format = DXGI_FORMAT_R32_FLOAT, .ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2DARRAY, .Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING};
    inputs.weather_view.Texture2DArray = {0, 1, 0, 2};
    if (!benchmark && !capture) {
      clouds::View cached_view(&assets, 64, 64, 0);
      clouds::BindingCache cache;
      auto alternate_weather = gpu::Image(device.Get(), 8, 8, DXGI_FORMAT_R32_FLOAT, 2);
      auto alternate = inputs;
      alternate.weather = alternate_weather.object.Get();
      const auto first = cache.Acquire(cached_view, inputs, 64);
      const auto second = cache.Acquire(cached_view, alternate, 64);
      for (uint32_t tick = 0; tick < 1000; ++tick)
        Require(cache.Acquire(cached_view, tick % 2 ? inputs : alternate, 64) == (tick % 2 ? first : second),
            "Alternating native weather must reuse immutable descriptor heaps");
      Require(cache.Size() == 2, "Native weather ping-pong grew the binding cache");
      alternate.weather_view.Texture2DArray.FirstArraySlice = 1;
      alternate.weather_view.Texture2DArray.ArraySize = 1;
      Require(cache.Acquire(cached_view, alternate, 64) != second, "Changed SRV range reused stale descriptors");
      Require(cache.Acquire(cached_view, inputs, 128) != first, "Changed noise quality reused stale descriptors");
      std::vector<gpu::Resource> replacements;
      for (uint32_t tick = 0; tick < 12; ++tick) {
        replacements.push_back(gpu::Image(device.Get(), 8, 8, DXGI_FORMAT_R32_FLOAT, 2));
        alternate.weather = replacements.back().object.Get();
        cache.Acquire(cached_view, alternate, 64);
      }
      Require(cache.Size() == 8 && first->Matches(inputs, 64),
          "Cache eviction changed a retained recording or exceeded its bound");
      Require(second->weather_input.Get() == alternate_weather.object.Get(), "Retained weather descriptor lost its input");
      std::cout << "PASS native weather ping-pong: 1000 switches, two immutable binding sets; SRV/quality invalidation and bounded eviction" << std::endl;
    }
    auto clears = std::make_shared<gpu::Bank>(device.Get());
    gpu::Uav(device.Get(), *clears, 0, depth.object.Get());
    D3D12_UNORDERED_ACCESS_VIEW_DESC weather_uav{};
    weather_uav.Format=DXGI_FORMAT_R32_FLOAT;
    weather_uav.ViewDimension=D3D12_UAV_DIMENSION_TEXTURE2DARRAY;
    weather_uav.Texture2DArray.ArraySize=1;
    device->CreateUnorderedAccessView(weather.object.Get(),nullptr,&weather_uav,clears->Cpu(17));
    weather_uav.Texture2DArray.FirstArraySlice=1;
    device->CreateUnorderedAccessView(weather.object.Get(),nullptr,&weather_uav,clears->Cpu(18));
    auto clear_inputs = [&](float cover, float geometry, float next_cover = -1.f) {
      begin();
      ID3D12DescriptorHeap* heaps[] = {clears->heap.Get()};
      cmd->SetDescriptorHeaps(1, heaps);
      gpu::Transition(cmd.Get(), &depth, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
      gpu::Transition(cmd.Get(), &weather, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
      const float d[4] = {geometry, geometry, geometry, geometry}, w[4] = {cover, cover, cover, cover};
      const float second[4]={next_cover<0.f?cover:next_cover,next_cover<0.f?cover:next_cover,
          next_cover<0.f?cover:next_cover,next_cover<0.f?cover:next_cover};
      cmd->ClearUnorderedAccessViewFloat(clears->Gpu(16), clears->Cpu(16), depth.object.Get(), d, 0, nullptr);
      cmd->ClearUnorderedAccessViewFloat(clears->Gpu(17), clears->Cpu(17), weather.object.Get(), w, 0, nullptr);
      cmd->ClearUnorderedAccessViewFloat(clears->Gpu(18), clears->Cpu(18), weather.object.Get(), second, 0, nullptr);
      if(operation.find("weatherpattern")!=std::string_view::npos &&cover>0.f) {
        // Periodic authored coverage exposes repetition in distant rays; the
        // usual uniform test texture cannot distinguish weather-map mappings.
        for(uint32_t y=0;y<8;++y)for(uint32_t x=0;x<8;++x) {
          const float angle_x=6.283185307f*(x+.5f)/8.f;
          const float angle_y=6.283185307f*(y+.5f)/8.f;
          const float value=std::clamp(.55f+.25f*std::sin(angle_x)+.18f*std::cos(angle_y)
              +.12f*std::sin(angle_x+2.f*angle_y),.02f,.98f);
          const float cell[4]={value,value,value,value};
          const D3D12_RECT rect{LONG(x),LONG(y),LONG(x+1),LONG(y+1)};
          cmd->ClearUnorderedAccessViewFloat(clears->Gpu(17),clears->Cpu(17),weather.object.Get(),cell,1,&rect);
          cmd->ClearUnorderedAccessViewFloat(clears->Gpu(18),clears->Cpu(18),weather.object.Get(),cell,1,&rect);
        }
      }
      gpu::Transition(cmd.Get(), &depth, gpu::TextureRead);
      gpu::Transition(cmd.Get(), &weather, gpu::TextureRead);
      submit();
    };
    D3D12_PLACED_SUBRESOURCE_FOOTPRINT footprint{};
    uint64_t bytes = 0;
    device->GetCopyableFootprints(&target_desc, 0, 1, 0, &footprint, nullptr, nullptr, &bytes);
    auto readback = gpu::Buffer(device.Get(), bytes, D3D12_RESOURCE_STATE_COPY_DEST, D3D12_HEAP_TYPE_READBACK);
    ComPtr<ID3D12QueryHeap> timestamps;
    gpu::Resource timestamp_readback;
    uint64_t frequency = 0;
    double weather_ms = 0, shadow_ms = 0, render_ms = 0, environment_ms = 0;
    if (benchmark) {
      const D3D12_QUERY_HEAP_DESC description{D3D12_QUERY_HEAP_TYPE_TIMESTAMP, 5};
      gpu::Check(device->CreateQueryHeap(&description, IID_PPV_ARGS(&timestamps)));
      timestamp_readback = gpu::Buffer(device.Get(), 40, D3D12_RESOURCE_STATE_COPY_DEST, D3D12_HEAP_TYPE_READBACK);
      gpu::Check(queue->GetTimestampFrequency(&frequency));
    }
    const float background[4] = {.2f, .3f, .4f, .75f};
    ComPtr<ID3D12PipelineState> depth_probe_pipeline;
    if (!benchmark && !capture) {
      const auto probe=Read(directory/"cloud-depth.cso");
      depth_probe_pipeline=gpu::Graphics(device.Get(),assets.root.Get(),{code.front().data(),code.front().size()},
          {probe.data(),probe.size()},target_desc.Format);
    }
    std::vector<gpu::Resource> clocks;
    bool disc_enabled=operation.find("nodisc")==std::string_view::npos;
    auto render = [&](clouds::View& view, bool duplicate = false, bool compute_weather = false,
                      float clock_seconds = -1.f, bool retain_clock = false, bool depth_probe = false) {
      inputs.light=light_buffer.object->GetGPUVirtualAddress();
      std::array<float, 64> clock{};
      clock[0] = clock_seconds >= 0.f ? clock_seconds : float(serial) * 2.f;
      if(!retain_clock || clocks.empty())clocks.push_back(gpu::Upload(device.Get(), clock.data(), sizeof(clock)));
      inputs.clock = clocks.back().object->GetGPUVirtualAddress();
      inputs.captured_sun = sun_probe;
      inputs.captured_moon = moon_probe;
      const auto bindings = view.PrepareBindings(inputs, uint32_t(clouds::QualityLighting(clouds::quality)[3]));
      const auto page = view.ParameterPage(inputs, sky_density);
      const auto weather_page = view.ParameterPage(inputs, sky_density, 1);
      const auto shadow_page = view.ParameterPage(inputs, sky_density, 2);
      begin();
      cmd->ClearRenderTargetView(inputs.target, background, 0, nullptr);
      if (moon_probe) view.CaptureMoon(cmd.Get(), target.object.Get());
      if(moon_probe && disc_enabled) {
        const float disc[4]={20.f,17.f,14.f,background[3]};
        const D3D12_RECT rect{LONG(width/2-14),LONG(height/2-14),LONG(width/2+14),LONG(height/2+14)};
        cmd->ClearRenderTargetView(inputs.target,disc,1,&rect);
      }
      if (sun_probe) view.CaptureSun(cmd.Get(), target.object.Get());
      if(sun_probe && disc_enabled) {
        const float disc[4]={80.f,65.f,48.f,background[3]};
        const LONG center_x=LONG(moon_probe ? width/4 : width/2);
        const D3D12_RECT rect{center_x-14,LONG(height/2-14),center_x+14,LONG(height/2+14)};
        cmd->ClearRenderTargetView(inputs.target,disc,1,&rect);
      }
      if (benchmark) cmd->EndQuery(timestamps.Get(), D3D12_QUERY_TYPE_TIMESTAMP, 0);
      view.Weather(cmd.Get(), inputs, bindings, weather_page, compute_weather);
      if (benchmark) cmd->EndQuery(timestamps.Get(), D3D12_QUERY_TYPE_TIMESTAMP, 1);
      view.Shadow(cmd.Get(), inputs, bindings, shadow_page);
      if (benchmark) cmd->EndQuery(timestamps.Get(), D3D12_QUERY_TYPE_TIMESTAMP, 2);
      inputs.light=view.LightingStorage()->object->GetGPUVirtualAddress();
      view.Render(cmd.Get(), inputs, bindings, page);
      if(depth_probe) {
        ID3D12DescriptorHeap* heaps[]={bindings.composite->heap.Get()};
        cmd->SetDescriptorHeaps(1,heaps);
        cmd->SetGraphicsRootDescriptorTable(7,bindings.composite->Gpu());
        cmd->SetPipelineState(depth_probe_pipeline.Get());
        cmd->OMSetRenderTargets(1,&inputs.target,FALSE,nullptr);
        const D3D12_VIEWPORT viewport{0,0,float(width),float(height),0,1};
        const D3D12_RECT scissor{0,0,LONG(width),LONG(height)};
        cmd->RSSetViewports(1,&viewport);cmd->RSSetScissorRects(1,&scissor);
        cmd->DrawInstanced(3,1,0,0);
      }
      if (benchmark) {
        cmd->EndQuery(timestamps.Get(), D3D12_QUERY_TYPE_TIMESTAMP, 3);
        view.Environment(cmd.Get(), inputs, bindings, page);
        cmd->EndQuery(timestamps.Get(), D3D12_QUERY_TYPE_TIMESTAMP, 4);
        cmd->ResolveQueryData(timestamps.Get(), D3D12_QUERY_TYPE_TIMESTAMP, 0, 5, timestamp_readback.object.Get(), 0);
      }
      gpu::Transition(cmd.Get(), &target, D3D12_RESOURCE_STATE_COPY_SOURCE);
      D3D12_TEXTURE_COPY_LOCATION source{target.object.Get(), D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
      D3D12_TEXTURE_COPY_LOCATION destination{readback.object.Get(), D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
      destination.PlacedFootprint = footprint;
      cmd->CopyTextureRegion(&destination, 0, 0, 0, &source, nullptr);
      gpu::Transition(cmd.Get(), &target, D3D12_RESOURCE_STATE_RENDER_TARGET);
      submit();
      if (benchmark) {
        void* mapped = nullptr;
        gpu::Check(timestamp_readback.object->Map(0, nullptr, &mapped));
        const auto* ticks = static_cast<const uint64_t*>(mapped);
        weather_ms = 1000.0 * double(ticks[1] - ticks[0]) / double(frequency);
        shadow_ms = 1000.0 * double(ticks[2] - ticks[1]) / double(frequency);
        render_ms = 1000.0 * double(ticks[3] - ticks[2]) / double(frequency);
        environment_ms = 1000.0 * double(ticks[4] - ticks[3]) / double(frequency);
        timestamp_readback.object->Unmap(0, nullptr);
      }
      auto pixels = [&]() {
        void* data = nullptr;
        gpu::Check(readback.object->Map(0, nullptr, &data));
        std::vector<float> result(width * height * 4);
        for (uint32_t y = 0; y < height; ++y) std::memcpy(result.data() + y * width * 4, static_cast<uint8_t*>(data) + y * footprint.Footprint.RowPitch, width * 16);
        readback.object->Unmap(0, nullptr);
        return result;
      };
      const auto result = pixels();
      for (size_t index = 0; index < result.size(); ++index) {
        Require(std::isfinite(result[index]), "Non-finite cloud radiance");
        if (index % 4 == 3) Require(result[index] == background[3], "Cloud changed native alpha");
      }
      if (duplicate) {
        begin();
        view.Render(cmd.Get(), inputs, bindings, page);
        gpu::Transition(cmd.Get(), &target, D3D12_RESOURCE_STATE_COPY_SOURCE);
        cmd->CopyTextureRegion(&destination, 0, 0, 0, &source, nullptr);
        gpu::Transition(cmd.Get(), &target, D3D12_RESOURCE_STATE_RENDER_TARGET);
        submit();
        Require(result == pixels(), "Repeated native card draw composited clouds twice");
      }
      return result;
    };
    if (benchmark || capture) {
      clear_inputs(sparse_probe?.5f:1.f, 0.f);
      clouds::quality = 1.f;
      clouds::base_softness=soft_probe?1.f:0.f;
      clouds::View view(&assets, width, height, clouds::quality, target_desc.Format);
      for (uint32_t index = 0; index < 4; ++index) render(view);
      if(capture) {
        const auto image=render(view);
        if(operation.find("mountain")!=std::string_view::npos) {
          uint32_t below_horizon=0;
          for(uint32_t y=850u;y<height;++y)for(uint32_t x=0;x<width;++x) {
            const size_t index=(size_t(y)*width+x)*4u;
            below_horizon+=std::abs(image[index]-background[0])>.01f;
          }
          Require(below_horizon>width*20u,
              "Clouds above the camera were cut off at a fixed screen-space horizon");
        }
        if((sun_probe || moon_probe) && disc_enabled && !sparse_probe) {
          const size_t center=(size_t(height/2)*width+width/2)*4;
          if(operation.find("rainair")!=std::string_view::npos || screenshot_settings || moon_probe) {
            disc_enabled=false;
            const auto no_disc=render(view,false,false,0.f);
            disc_enabled=true;
            const float disc_rgb[3]={moon_probe ? 20.f : 80.f,
                moon_probe ? 17.f : 65.f,
                moon_probe ? 14.f : 48.f};
            for(uint32_t channel=0;channel<3;++channel) {
              const float remaining=(image[center+channel]-no_disc[center+channel])/disc_rgb[channel];
              std::cout<<"HDR disc channel "<<channel<<" remaining="<<remaining<<"\n";
              Require(remaining<.02f,
                  "Cloud leaked more than 2% of the HDR emitter disc");
            }
          } else {
            Require(image[center]<1.f &&image[center+1]<1.f &&image[center+2]<1.f,
                "Dense cloud failed to obscure the synthetic HDR sun disc");
          }
          clouds::coverage=0.f; ++inputs.revision;
          const auto clear=render(view);
          const float clear_rgb[3]={moon_probe ? 20.f : 80.f, moon_probe ? 17.f : 65.f,
              moon_probe ? 14.f : 48.f};
          Require(std::abs(clear[center]-clear_rgb[0])<.01f &&std::abs(clear[center+1]-clear_rgb[1])<.01f
              &&std::abs(clear[center+2]-clear_rgb[2])<.01f,
              "Cloud Off changed the synthetic HDR emitter disc");
        }
        std::ofstream output(argv[3],std::ios::binary);
        Require(bool(output),"Cannot write cloud capture");
        output.write(reinterpret_cast<const char*>(image.data()),std::streamsize(image.size()*sizeof(float)));
        Require(bool(output),"Cloud capture write failed");
        std::cout<<"Captured "<<width<<"x"<<height<<" linear RGBA32F cloud composite to "<<argv[3]<<"\n";
        return 0;
      }
      std::vector<double> timings, weather_timings, shadow_timings, environment_timings;
      for (uint32_t index = 0; index < 16; ++index) {
        render(view);
        timings.push_back(render_ms);
        weather_timings.push_back(weather_ms);
        shadow_timings.push_back(shadow_ms);
        environment_timings.push_back(environment_ms);
      }
      std::sort(timings.begin(), timings.end());
      std::sort(weather_timings.begin(), weather_timings.end());
      std::sort(shadow_timings.begin(), shadow_timings.end());
      std::sort(environment_timings.begin(), environment_timings.end());
      std::cout << "Cloud weather/shadow/render/environment GPU median ms=" << .5 * (weather_timings[7] + weather_timings[8])
                << "/" << .5 * (shadow_timings[7] + shadow_timings[8]) << "/" << .5 * (timings[7] + timings[8])
                << "/" << .5 * (environment_timings[7] + environment_timings[8]) << " min=" << timings.front()
                << " max=" << timings.back() << " at " << width << "x" << height << " Medium\n";
      if(screenshot_settings) {
        auto shadow_readback=gpu::Buffer(device.Get(),view.Shared()->GetDesc().Width,
            D3D12_RESOURCE_STATE_COPY_DEST,D3D12_HEAP_TYPE_READBACK);
        begin();
        D3D12_RESOURCE_BARRIER barrier{};
        barrier.Type=D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
        barrier.Transition={view.Shared(),D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
            gpu::TextureRead,D3D12_RESOURCE_STATE_COPY_SOURCE};
        cmd->ResourceBarrier(1,&barrier);
        cmd->CopyResource(shadow_readback.object.Get(),view.Shared());
        std::swap(barrier.Transition.StateBefore,barrier.Transition.StateAfter);
        cmd->ResourceBarrier(1,&barrier);
        submit();
        void* data=nullptr;
        gpu::Check(shadow_readback.object->Map(0,nullptr,&data));
        const auto* words=static_cast<const uint32_t*>(data);
        const uint32_t offset=words[15],pitch=words[16],size=uint32_t(static_cast<const float*>(data)[8]);
        float minimum=1.f,maximum=0.f;
        double average=0.0;
        uint32_t dark=0,count=0;
        for(uint32_t y=0;y<size;y+=4)for(uint32_t x=0;x<size;x+=4) {
          uint16_t packed=0;
          std::memcpy(&packed,static_cast<const uint8_t*>(data)+offset+uint64_t(y)*pitch+x*4,2);
          const float transmission=DirectX::PackedVector::XMConvertHalfToFloat(packed);
          minimum=std::min(minimum,transmission);
          maximum=std::max(maximum,transmission);
          average+=transmission;
          dark+=transmission<.9f;
          ++count;
        }
        shadow_readback.object->Unmap(0,nullptr);
        std::cout<<"Screenshot-setting shadow Beer min/mean/max="<<minimum<<"/"<<average/count
                 <<"/"<<maximum<<" texels below .9="<<dark<<"/"<<count<<"\n";
        if(sun_probe) {
          const auto resolved_desc=view.Resolved()->GetDesc();
          D3D12_PLACED_SUBRESOURCE_FOOTPRINT resolved_layout{};
          uint64_t resolved_bytes=0;
          device->GetCopyableFootprints(&resolved_desc,0,1,0,&resolved_layout,nullptr,nullptr,&resolved_bytes);
          auto resolved_readback=gpu::Buffer(device.Get(),resolved_bytes,
              D3D12_RESOURCE_STATE_COPY_DEST,D3D12_HEAP_TYPE_READBACK);
          begin();
          barrier.Transition.pResource=view.Resolved();
          barrier.Transition.StateBefore=gpu::TextureRead;
          barrier.Transition.StateAfter=D3D12_RESOURCE_STATE_COPY_SOURCE;
          cmd->ResourceBarrier(1,&barrier);
          D3D12_TEXTURE_COPY_LOCATION source{view.Resolved(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
          D3D12_TEXTURE_COPY_LOCATION destination{resolved_readback.object.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
          destination.PlacedFootprint=resolved_layout;
          cmd->CopyTextureRegion(&destination,0,0,0,&source,nullptr);
          std::swap(barrier.Transition.StateBefore,barrier.Transition.StateAfter);
          cmd->ResourceBarrier(1,&barrier);
          submit();
          void* pixels=nullptr;
          gpu::Check(resolved_readback.object->Map(0,nullptr,&pixels));
          uint16_t packed=0;
          std::memcpy(&packed,static_cast<const uint8_t*>(pixels)+resolved_layout.Offset
              +uint64_t(height/2)*resolved_layout.Footprint.RowPitch+(width/2)*8+6,2);
          const float sky_transmission=1.f-DirectX::PackedVector::XMConvertHalfToFloat(packed);
          resolved_readback.object->Unmap(0,nullptr);
          const auto ground=probe(view.Shared(),{0,0,0,.37f,0,0,0,0,0,0,1,10});
          std::cout<<"Camera sun-ray transmission="<<sky_transmission
                   <<" same-ray terrain shadow="<<ground[0]<<"\n";
        }
      }
      return 0;
    }
    clear_inputs(1, 0);
    uint32_t cases = 0;
    for (uint32_t level = 0; level < 6; ++level) {
      clouds::quality = float(level);
      clouds::View view(&assets, width, height, clouds::quality, target_desc.Format);
      Require(view.LowWidth() == width && view.LowHeight() == height, "Cloud quality must trace at full resolution");
      const auto image = render(view, true, level % 2);
      auto shared_readback = gpu::Buffer(device.Get(), view.Shared()->GetDesc().Width, D3D12_RESOURCE_STATE_COPY_DEST, D3D12_HEAP_TYPE_READBACK);
      begin();
      D3D12_RESOURCE_BARRIER shared_barrier{};
      shared_barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
      shared_barrier.Transition = {view.Shared(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, gpu::TextureRead, D3D12_RESOURCE_STATE_COPY_SOURCE};
      cmd->ResourceBarrier(1, &shared_barrier);
      cmd->CopyResource(shared_readback.object.Get(), view.Shared());
      std::swap(shared_barrier.Transition.StateBefore, shared_barrier.Transition.StateAfter);
      cmd->ResourceBarrier(1, &shared_barrier);
      submit();
      void* mapped = nullptr;
      gpu::Check(shared_readback.object->Map(0, nullptr, &mapped));
      const auto* words = static_cast<const uint32_t*>(mapped);
      const auto* floats = static_cast<const float*>(mapped);
      const uint32_t offset = words[15], pitch = words[16], size = uint32_t(floats[8]);
      Require(floats[11] == 1357 && size == view.ShadowSize() && offset % 512 == 0, "Shadow footprint metadata is invalid");
      Require(uint64_t(offset) + uint64_t(pitch) * (size - 1) + size * 4 <= view.Shared()->GetDesc().Width, "Shadow footprint exceeds packed storage");
      auto shadow_texel = [&](uint32_t x, uint32_t y, uint32_t channel = 0) {
        uint16_t value;
        std::memcpy(&value, static_cast<const uint8_t*>(mapped) + offset + uint64_t(y) * pitch + x * 4 + channel * 2, 2);
        return DirectX::PackedVector::XMConvertHalfToFloat(value);
      };
      const float center = .25f * (shadow_texel(size / 2 - 1, size / 2 - 1) + shadow_texel(size / 2, size / 2 - 1)
                                   + shadow_texel(size / 2 - 1, size / 2) + shadow_texel(size / 2, size / 2));
      Require(center<.99f,"Synthetic shadow probe has no cloudy receiver column");
      uint32_t mip_offset=offset,mip_pitch=pitch,mip_size=size;
      for(uint32_t level=0;level<6;++level) {
        Require(mip_offset%512u==0u &&mip_pitch>=mip_size*4u
            &&uint64_t(mip_offset)+uint64_t(mip_pitch)*(mip_size-1u)+mip_size*4u<=view.Shared()->GetDesc().Width,
            "Packed cloud-shadow mip footprint is invalid");
        for(uint32_t channel=0;channel<2;++channel) {
          uint16_t packed=0;
          std::memcpy(&packed,static_cast<const uint8_t*>(mapped)+mip_offset
              +uint64_t(mip_size/2u)*mip_pitch+(mip_size/2u)*4u+channel*2u,2);
          const float sample=DirectX::PackedVector::XMConvertHalfToFloat(packed);
          Require(std::isfinite(sample)&&sample>=0.f&&sample<=1.f,
              "Packed cloud-shadow mip contains invalid transmission or exponential depth");
        }
        mip_offset=(mip_offset+mip_pitch*mip_size+511u)&~511u;
        mip_size=std::max(mip_size>>1u,1u);
        mip_pitch=(mip_size*4u+255u)&~255u;
      }
      const std::array<float, 3> origin{floats[0], floats[1], 0.f};
      const float cloud_top=floats[2];
      const std::array<float, 3> sun{floats[4], floats[5], floats[6]};
      shared_readback.object->Unmap(0, nullptr);
      const auto at_ground = probe(view.Shared(), {origin[0], origin[1], origin[2], .37f, 0, 0, 0, 0, 0, 0, 1, 10});
      const auto at_height = probe(view.Shared(), {origin[0] + 100 * sun[0] / sun[2], origin[1] + 100 * sun[1] / sun[2], origin[2] + 100, .37f, 0, 0, 0, 0, 0, 0, 1, 10});
      Require(std::abs(at_ground[0] - center) < .0001f && std::abs(at_height[0] - center) < .0001f, "Packed cloud-shadow filtering or world projection differs from texture");
      Require(at_ground[12] == 1.f && std::abs(at_ground[13] - .37f * center) < .0001f
          && at_ground[14] == 0.f,
          "Deferred sunlight lost geometry visibility or applied the cloud factor twice");
      const float layer_height=cloud_top-1200.f;
      const auto within_lower = probe(view.Shared(), {origin[0] + (1200.f+.1f*layer_height)*sun[0]/sun[2],
          origin[1] + (1200.f+.1f*layer_height)*sun[1]/sun[2], 1200.f+.1f*layer_height,
          .37f,0,0,0,0,0,0,1,10});
      const auto within_upper = probe(view.Shared(), {origin[0] + (1200.f+.9f*layer_height)*sun[0]/sun[2],
          origin[1] + (1200.f+.9f*layer_height)*sun[1]/sun[2], 1200.f+.9f*layer_height,
          .37f,0,0,0,0,0,0,1,10});
      if(!(within_lower[0]+.0001f>=at_ground[0] && within_upper[0]+.0001f>=within_lower[0]))
        std::cerr<<"Shadow receiver ground/lower/upper="<<at_ground[0]<<"/"<<within_lower[0]
                 <<"/"<<within_upper[0]<<" at quality "<<level<<"\n";
      Require(within_lower[0]+.0001f>=at_ground[0] && within_upper[0]+.0001f>=within_lower[0],
          "Weighted-depth shadow did not lighten monotonically toward the sun");
      Require(within_upper[0]>at_ground[0]+.01f,
          "Weighted-depth receiver did not reveal a cloud-lit upper layer");
      const float above_height=cloud_top+100.f;
      const auto above_cloud = probe(view.Shared(), {origin[0] + above_height * sun[0] / sun[2],
          origin[1] + above_height * sun[1] / sun[2], above_height, .37f, 0, 0, 0, 0, 0, 0, 1, 10});
      Require(above_cloud[0] == 1.f, "Receiver above cloud layer inherited ground-level shadow");
      Require(at_ground[1] == 1, "Current shadow failed GPU frame qualification");
      const auto outside = probe(view.Shared(), {origin[0] + 17000, origin[1], 0, .37f, 0, 0, 0, 0, 0, 0, 1, 10});
      Require(outside[0] == 1, "Cloud-shadow region edge did not fade to clear");
      Require(at_ground[10] < .00005f && at_ground[9] > .1f && std::abs(at_ground[11] - .075f) < 1.e-7f, "HDR sun direct/diffuse transport regressed");
      uint32_t changed = 0;
      for (size_t index = 0; index < image.size(); index += 4) changed += std::abs(image[index] - background[0]) > .005f;
      Require(changed > 100, "Cloudy view remained native background");
      if(level==1u) {
        const auto color_desc=view.EnvironmentRadiance()->GetDesc();
        const auto distance_desc=view.EnvironmentDepth()->GetDesc();
        D3D12_PLACED_SUBRESOURCE_FOOTPRINT color_layout{},distance_layout{};
        uint64_t color_bytes=0,distance_bytes=0;
        device->GetCopyableFootprints(&color_desc,0,1,0,&color_layout,nullptr,nullptr,&color_bytes);
        device->GetCopyableFootprints(&distance_desc,0,1,0,&distance_layout,nullptr,nullptr,&distance_bytes);
        auto color_readback=gpu::Buffer(device.Get(),color_bytes,D3D12_RESOURCE_STATE_COPY_DEST,D3D12_HEAP_TYPE_READBACK);
        auto distance_readback=gpu::Buffer(device.Get(),distance_bytes,D3D12_RESOURCE_STATE_COPY_DEST,D3D12_HEAP_TYPE_READBACK);
        auto capture_environment=[&]() {
          const auto bank=view.PrepareBindings(inputs,uint32_t(clouds::QualityLighting(clouds::quality)[3]));
          const auto page=view.ParameterPage(inputs,1.f,3);
          begin();view.Environment(cmd.Get(),inputs,bank,page);
          for(ID3D12Resource* resource:{view.EnvironmentRadiance(),view.EnvironmentDepth()}) {
            D3D12_RESOURCE_BARRIER barrier{};
            barrier.Type=D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
            barrier.Transition={resource,D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,gpu::TextureRead,D3D12_RESOURCE_STATE_COPY_SOURCE};
            cmd->ResourceBarrier(1,&barrier);
          }
          D3D12_TEXTURE_COPY_LOCATION color_source{view.EnvironmentRadiance(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
          D3D12_TEXTURE_COPY_LOCATION color_destination{color_readback.object.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
          color_destination.PlacedFootprint=color_layout;
          cmd->CopyTextureRegion(&color_destination,0,0,0,&color_source,nullptr);
          D3D12_TEXTURE_COPY_LOCATION distance_source{view.EnvironmentDepth(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
          D3D12_TEXTURE_COPY_LOCATION distance_destination{distance_readback.object.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
          distance_destination.PlacedFootprint=distance_layout;
          cmd->CopyTextureRegion(&distance_destination,0,0,0,&distance_source,nullptr);
          for(ID3D12Resource* resource:{view.EnvironmentRadiance(),view.EnvironmentDepth()}) {
            D3D12_RESOURCE_BARRIER barrier{};
            barrier.Type=D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
            barrier.Transition={resource,D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,D3D12_RESOURCE_STATE_COPY_SOURCE,gpu::TextureRead};
            cmd->ResourceBarrier(1,&barrier);
          }
          submit();
          void* colors=nullptr;void* distances=nullptr;
          gpu::Check(color_readback.object->Map(0,nullptr,&colors));
          gpu::Check(distance_readback.object->Map(0,nullptr,&distances));
          std::vector<std::array<float,5>> values(256u*128u);
          for(uint32_t y=0;y<128u;++y)for(uint32_t x=0;x<256u;++x) {
            const auto* color=static_cast<const uint8_t*>(colors)+y*color_layout.Footprint.RowPitch+x*8u;
            for(uint32_t channel=0;channel<4u;++channel) {
              uint16_t packed=0;std::memcpy(&packed,color+channel*2u,2);
              values[y*256u+x][channel]=DirectX::PackedVector::XMConvertHalfToFloat(packed);
            }
            std::memcpy(&values[y*256u+x][4],static_cast<const uint8_t*>(distances)
                +y*distance_layout.Footprint.RowPitch+x*4u,4);
          }
          color_readback.object->Unmap(0,nullptr);
          distance_readback.object->Unmap(0,nullptr);
          return values;
        };
        const auto cloudy=capture_environment();
        uint32_t occupied=0;
        for(uint32_t y=0;y<128u;++y)for(uint32_t x=0;x<256u;++x) {
          const auto& sample=cloudy[y*256u+x];
          for(float value:sample)Require(std::isfinite(value),"Environment trace produced non-finite data");
          Require(sample[3]>=0.f&&sample[3]<=1.f,"Environment transmission is out of range");
          if(y<64u)occupied+=sample[3]<.99f;
          else Require(sample[3]==1.f&&sample[4]==0.f,"Lower hemisphere acquired cloud opacity");
        }
        Require(occupied>100u,"Weather-driven environment map remained clear");
        clouds::AtlasStorage atlas(&assets,DXGI_FORMAT_R16G16B16A16_FLOAT);
        auto atlas_desc=color_desc;
        atlas_desc.Width=768;atlas_desc.Height=512;
        atlas_desc.Flags=D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET;
        auto native_atlas=gpu::Create(device.Get(),atlas_desc,D3D12_RESOURCE_STATE_RENDER_TARGET);
        auto projection_desc=atlas_desc;
        projection_desc.Width=projection_desc.Height=256;
        auto projection=gpu::Create(device.Get(),projection_desc,D3D12_RESOURCE_STATE_RENDER_TARGET);
        ComPtr<ID3D12DescriptorHeap> atlas_rtvs;
        const D3D12_DESCRIPTOR_HEAP_DESC atlas_rtv_desc{D3D12_DESCRIPTOR_HEAP_TYPE_RTV,2};
        gpu::Check(device->CreateDescriptorHeap(&atlas_rtv_desc,IID_PPV_ARGS(&atlas_rtvs)));
        const auto atlas_rtv=atlas_rtvs->GetCPUDescriptorHandleForHeapStart();
        auto projection_rtv=atlas_rtv;
        projection_rtv.ptr+=device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_RTV);
        device->CreateRenderTargetView(native_atlas.object.Get(),nullptr,atlas_rtv);
        device->CreateRenderTargetView(projection.object.Get(),nullptr,projection_rtv);
        D3D12_SHADER_RESOURCE_VIEW_DESC atlas_view{};
        atlas_view.Format=DXGI_FORMAT_R16G16B16A16_FLOAT;
        atlas_view.ViewDimension=D3D12_SRV_DIMENSION_TEXTURE2D;
        atlas_view.Shader4ComponentMapping=D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
        atlas_view.Texture2D.MipLevels=1;
        const float clear_sky[4]={.2f,.3f,.4f,1.f},native_clouds[4]={.8f,.8f,.8f,1.f};
        begin();
        cmd->ClearRenderTargetView(atlas_rtv,clear_sky,0,nullptr);
        for(uint32_t face=0;face<6u;++face) {
          atlas.CaptureFrame(cmd.Get(),frame_buffer.object->GetGPUVirtualAddress(),face,inputs.revision);
          atlas.CaptureClear(cmd.Get(),native_atlas.object.Get(),face);
        }
        cmd->ClearRenderTargetView(atlas_rtv,native_clouds,0,nullptr);
        gpu::Transition(cmd.Get(),&native_atlas,gpu::TextureRead);
        auto atlas_bank=atlas.Convert(cmd.Get(),native_atlas.object.Get(),atlas_view,
            view.EnvironmentRadiance(),view.EnvironmentHeader(),projection_rtv,DXGI_FORMAT_R16G16B16A16_FLOAT);
        gpu::Transition(cmd.Get(),&projection,D3D12_RESOURCE_STATE_COPY_SOURCE);
        D3D12_PLACED_SUBRESOURCE_FOOTPRINT projection_layout{};
        uint64_t projection_bytes=0;
        device->GetCopyableFootprints(&projection_desc,0,1,0,&projection_layout,nullptr,nullptr,&projection_bytes);
        auto projection_readback=gpu::Buffer(device.Get(),projection_bytes,D3D12_RESOURCE_STATE_COPY_DEST,D3D12_HEAP_TYPE_READBACK);
        D3D12_TEXTURE_COPY_LOCATION projection_source{projection.object.Get(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
        D3D12_TEXTURE_COPY_LOCATION projection_destination{projection_readback.object.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
        projection_destination.PlacedFootprint=projection_layout;
        cmd->CopyTextureRegion(&projection_destination,0,0,0,&projection_source,nullptr);
        gpu::Transition(cmd.Get(),&projection,D3D12_RESOURCE_STATE_RENDER_TARGET);
        submit();
        auto projected_color=[&]() {
          void* mapped=nullptr;gpu::Check(projection_readback.object->Map(0,nullptr,&mapped));
          std::array<float,3> color{};
          for(uint32_t channel=0;channel<3u;++channel) {
            uint16_t packed=0;
            std::memcpy(&packed,static_cast<const uint8_t*>(mapped)
                +128u*projection_layout.Footprint.RowPitch+128u*8u+channel*2u,2);
            color[channel]=DirectX::PackedVector::XMConvertHalfToFloat(packed);
          }
          projection_readback.object->Unmap(0,nullptr);
          return color;
        };
        const auto improved=projected_color();
        Require(std::isfinite(improved[0])&&std::isfinite(improved[1])&&std::isfinite(improved[2])
            &&std::abs(improved[0]-.8f)>.03f,"Complete atlas did not use cloud environment");
        auto stale_frame=frame;stale_frame[66][3]=.5f;
        const auto stale_upload=gpu::Upload(device.Get(),stale_frame.data(),sizeof(stale_frame));
        begin();
        atlas.CaptureFrame(cmd.Get(),stale_upload.object->GetGPUVirtualAddress(),5u,inputs.revision);
        auto stale_atlas_bank=atlas.Convert(cmd.Get(),native_atlas.object.Get(),atlas_view,view.EnvironmentRadiance(),
            view.EnvironmentHeader(),projection_rtv,DXGI_FORMAT_R16G16B16A16_FLOAT);
        gpu::Transition(cmd.Get(),&projection,D3D12_RESOURCE_STATE_COPY_SOURCE);
        cmd->CopyTextureRegion(&projection_destination,0,0,0,&projection_source,nullptr);
        gpu::Transition(cmd.Get(),&projection,D3D12_RESOURCE_STATE_RENDER_TARGET);
        submit();
        const auto fallback=projected_color();
        for(float value:fallback)Require(std::abs(value-.8f)<.002f,
            "Mismatched atlas weather did not retain native conversion");
        begin();
        atlas.CaptureFrame(cmd.Get(),frame_buffer.object->GetGPUVirtualAddress(),5u,inputs.revision+1u);
        auto version_bank=atlas.Convert(cmd.Get(),native_atlas.object.Get(),atlas_view,view.EnvironmentRadiance(),
            view.EnvironmentHeader(),projection_rtv,DXGI_FORMAT_R16G16B16A16_FLOAT);
        gpu::Transition(cmd.Get(),&projection,D3D12_RESOURCE_STATE_COPY_SOURCE);
        cmd->CopyTextureRegion(&projection_destination,0,0,0,&projection_source,nullptr);
        gpu::Transition(cmd.Get(),&projection,D3D12_RESOURCE_STATE_RENDER_TARGET);
        submit();
        for(float value:projected_color())Require(std::abs(value-.8f)<.002f,
            "Stale cloud settings did not retain native atlas conversion");
        cases+=3;
        clouds::coverage=0.f;++inputs.revision;
        const auto clear=capture_environment();
        for(const auto& sample:clear)Require(sample[0]==0.f&&sample[1]==0.f&&sample[2]==0.f
            &&sample[3]==1.f&&sample[4]==0.f,"Clouds Off altered the environment map");
        clouds::coverage=1.f;++inputs.revision;
        cases+=2;
      }
      clouds::density = 0;
      ++inputs.revision;
      const auto empty = render(view);
      for (size_t index = 0; index < empty.size(); ++index) Require(std::abs(empty[index] - background[index % 4]) < 1.e-6f, "Zero density altered clear sky");
      clouds::density = 1.f;
      ++inputs.revision;
      clear_inputs(1, 1);
      const auto foreground = render(view);
      for (size_t index = 0; index < foreground.size(); ++index) Require(std::abs(foreground[index] - background[index % 4]) < 1.e-6f, "Cloud covered foreground geometry");
      // A mountain can end inside the cloud layer. Test the actual resolved
      // cloud depth, including its previous full-sky temporal history.
      clear_inputs(1.f,(1.f/3500.f-.0002f)/4.9998f);
      const auto clipped=render(view,false,false,-1.f,false,true);
      uint32_t visible_columns=0;
      for(size_t index=0;index<clipped.size();index+=4)if(clipped[index]>0.f) {
        ++visible_columns;
        Require(clipped[index]<=clipped[index+1]+.5f,"Cloud history/integration extends behind an intersecting mountain");
      }
      Require(visible_columns>20,"Mountain intersection fixture did not contain a visible cloud column");
      clear_inputs(1, 0);
      clouds::shadows = 0;
      ++inputs.revision;
      render(view);
      const auto off = probe(view.Shared(), {0, 0, 0, .37f, 0, 0, 0, 0, 0, 0, 1, 10});
      Require(off[0] == 1, "Cloud-shadow Off retained native/procedural shadows");
      Require(off[12] == 1.f && std::abs(off[13] - .37f) < .0001f && off[14] == 0.f,
          "Cloud-shadow Off removed native geometry occlusion");
      clouds::shadows = 1;
      ++inputs.revision;
      cases += 9;
    }
    // Same camera, sun, jitter and clock address: changing native wind must
    // invalidate the shadow cache and move the world-space shadow texture.
    clocks.clear();
    clouds::quality=1.f;
    clouds::View moving_shadow(&assets,width,height,clouds::quality,target_desc.Format);
    render(moving_shadow,false,false,500.f,true);
    auto moving_readback=gpu::Buffer(device.Get(),moving_shadow.Shared()->GetDesc().Width,
        D3D12_RESOURCE_STATE_COPY_DEST,D3D12_HEAP_TYPE_READBACK);
    auto shadow_snapshot=[&]() {
      begin();
      D3D12_RESOURCE_BARRIER barrier{};
      barrier.Type=D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
      barrier.Transition={moving_shadow.Shared(),D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
          gpu::TextureRead,D3D12_RESOURCE_STATE_COPY_SOURCE};
      cmd->ResourceBarrier(1,&barrier);
      cmd->CopyResource(moving_readback.object.Get(),moving_shadow.Shared());
      std::swap(barrier.Transition.StateBefore,barrier.Transition.StateAfter);
      cmd->ResourceBarrier(1,&barrier);
      submit();
      void* mapped=nullptr;
      gpu::Check(moving_readback.object->Map(0,nullptr,&mapped));
      const auto* words=static_cast<const uint32_t*>(mapped);
      const auto* values=static_cast<const float*>(mapped);
      Require(words[15]>=512 && words[16]>=moving_shadow.ShadowSize()*4,
          "Moving shadow footprint is invalid");
      const uint32_t offset=words[15],pitch=words[16],size=moving_shadow.ShadowSize();
      std::vector<uint16_t> samples;
      for(uint32_t y=0;y<size;y+=8)for(uint32_t x=0;x<size;x+=8) {
        uint16_t packed=0;
        std::memcpy(&packed,static_cast<const uint8_t*>(mapped)+offset+uint64_t(y)*pitch+x*4,2);
        samples.push_back(packed);
      }
      const float stored_wind=values[60];
      moving_readback.object->Unmap(0,nullptr);
      return std::pair{stored_wind,std::move(samples)};
    };
    const auto before_wind=shadow_snapshot();
    // Layer Thickness defaults to 60% in the menu. Exercise the same shadow
    // map that the terrain receiver reads, including the other appearance
    // controls that can change its optical column.
    for(const auto& settings : {std::array<float,4>{.6f,.12f,.6f,1.3f},
            {1.f,.12f,.6f,1.3f}, {.5f,.12f,.25f,.5f},
            {3.f,.12f,4.f,2.f}, {.6f,1.f,.6f,1.3f}}) {
      clouds::thickness=settings[0]; clouds::density=settings[1];
      clouds::size=settings[2]; clouds::coverage=settings[3]; ++inputs.revision;
      render(moving_shadow,false,false,500.f,true);
      const auto sample=shadow_snapshot();
      uint32_t blocked=0;
      for(uint16_t packed:sample.second)
        blocked+=DirectX::PackedVector::XMConvertHalfToFloat(packed)<.98f;
      const auto ground=probe(moving_shadow.Shared(),{0,0,0,.37f,0,0,0,0,0,0,1,10});
      std::cout<<"Shadow settings thickness/density/size/coverage="
          <<settings[0]<<"/"<<settings[1]<<"/"<<settings[2]<<"/"<<settings[3]
          <<" blocked="<<blocked<<" of "<<sample.second.size()
          <<" receiver="<<ground[0]<<'\n';
      Require(blocked>100,"Visible cloud settings produced no terrain shadow");
      Require(ground[0]<.98f,"Terrain receiver ignored a cloud shadow at an enabled setting");
      ++cases;
    }
    clouds::thickness=1.f; clouds::density=1.f; clouds::size=1.f;
    clouds::coverage=1.f; ++inputs.revision;
    render(moving_shadow,false,false,500.f,true);
    // The low visual-density calibration reaches unit direct-beam extinction
    // at 12.5%. The terrain map must follow that same optical column.
    clouds::density=.125f;
    ++inputs.revision;
    render(moving_shadow,false,false,500.f,true);
    const auto low_density=shadow_snapshot();
    uint64_t beam_difference=0;
    for(size_t i=0;i<before_wind.second.size();++i)
      beam_difference+=std::abs(int(before_wind.second[i])-int(low_density.second[i]));
    Require(beam_difference<before_wind.second.size()*4u,
        "Terrain sunlight no longer matches the calibrated sun-disc beam at low Density");
    clouds::density=1.f;
    ++inputs.revision;
    render(moving_shadow,false,false,500.f,true);
    auto moving_frame=frame;
    moving_frame[67][0]=1800.f;
    const auto moving_upload=gpu::Upload(device.Get(),moving_frame.data(),sizeof(moving_frame));
    inputs.frame=moving_upload.object->GetGPUVirtualAddress();
    render(moving_shadow,false,false,500.f,true);
    const auto after_wind=shadow_snapshot();
    Require(before_wind.first==0.f && after_wind.first==1800.f,
        "Native wind change reused stale shadow metadata");
    uint32_t changed=0;
    for(size_t i=0;i<before_wind.second.size();++i)changed+=before_wind.second[i]!=after_wind.second[i];
    Require(changed>100,"Native wind change did not move cloud shadows");
    // The same wind translates the cloud material toward negative world X.
    // Compare the captured shadow field against that expected displacement,
    // rather than accepting any change (including a misplaced new pattern).
    const uint32_t sampled_size=(moving_shadow.ShadowSize()+7)/8;
    const uint32_t expected_shift=uint32_t(std::round(1800.f*1.2f/32000.f*sampled_size));
    uint64_t stationary_error=0,advected_error=0,reverse_error=0;
    for(uint32_t y=0;y<sampled_size;++y)for(uint32_t x=expected_shift;x+expected_shift<sampled_size;++x) {
      const size_t index=size_t(y)*sampled_size+x;
      stationary_error+=std::abs(int(after_wind.second[index])-int(before_wind.second[index]));
      advected_error+=std::abs(int(after_wind.second[index])
          -int(before_wind.second[index+expected_shift]));
      reverse_error+=std::abs(int(after_wind.second[index])
          -int(before_wind.second[index-expected_shift]));
    }
    std::cout<<"Native-wind shadow stationary/advected/reverse error="<<stationary_error
             <<"/"<<advected_error<<"/"<<reverse_error<<" at "<<expected_shift<<" sampled cells\n";
    Require(advected_error<stationary_error &&advected_error<reverse_error,
        "Cloud shadow pattern did not follow native wind in world space");
    // The visible disc can differ from the directional-light lobe. A fixed
    // weather field must cast a different terrain pattern when that actual
    // solar direction changes, even if b13's broad lighting stays fixed.
    auto disc_frame=frame;
    disc_frame[38]={-.4f,-.64f,.65f,1.f};
    const auto disc_upload=gpu::Upload(device.Get(),disc_frame.data(),sizeof(disc_frame));
    inputs.frame=disc_upload.object->GetGPUVirtualAddress();
    render(moving_shadow,false,false,500.f,true);
    const auto disc_shadow=shadow_snapshot();
    uint32_t disc_changed=0;
    for(size_t i=0;i<before_wind.second.size();++i)
      disc_changed+=before_wind.second[i]!=disc_shadow.second[i];
    Require(disc_changed>100,"Terrain cloud shadow ignored the visible solar direction");
    inputs.frame=frame_buffer.object->GetGPUVirtualAddress();
    cases+=2;
    clear_inputs(0.f,0.f,1.f);
    clouds::quality=1.f;
    clouds::coverage=1.3f;
    ++inputs.revision;
    clouds::View weather_blend(&assets,width,height,clouds::quality,target_desc.Format);
    const auto source_layer=render(weather_blend);
    double source_change=0;
    for(size_t index=0;index<source_layer.size();++index)
      source_change+=std::abs(source_layer[index]-background[index%4]);
    Require(source_change<1.f,"Clear native weather cast clouds at 130% coverage");
    Require(probe(weather_blend.Shared(),{0,0,0,.37f,0,0,0,0,0,0,1,10})[0]>.999f,
        "Clear native weather blocked direct sunlight at 130% coverage");
    clouds::coverage=1.f;
    ++inputs.revision;
    auto target_frame=frame;
    target_frame[66][3]=1.f;
    const auto target_upload=gpu::Upload(device.Get(),target_frame.data(),sizeof(target_frame));
    inputs.frame=target_upload.object->GetGPUVirtualAddress(); ++inputs.revision;
    const auto target_layer=render(weather_blend,false,true);
    uint32_t weather_pixels=0;
    for(size_t index=0;index<target_layer.size();index+=4)
      weather_pixels+=std::abs(target_layer[index]-background[0])>.005f;
    Require(weather_pixels>100,"Native target weather layer failed to drive clouds");
    inputs.frame=frame_buffer.object->GetGPUVirtualAddress(); ++inputs.revision;
    clear_inputs(1.f,0.f);
    clouds::quality = 1;
    clouds::View temporal(&assets,width,height,clouds::quality,target_desc.Format);
    auto packed_readback = gpu::Buffer(device.Get(),temporal.Shared()->GetDesc().Width,D3D12_RESOURCE_STATE_COPY_DEST,D3D12_HEAP_TYPE_READBACK);
    auto confidence_count = [&]() {
      begin();
      D3D12_RESOURCE_BARRIER barrier{};
      barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
      barrier.Transition = {temporal.Shared(),D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,gpu::TextureRead,D3D12_RESOURCE_STATE_COPY_SOURCE};
      cmd->ResourceBarrier(1,&barrier); cmd->CopyResource(packed_readback.object.Get(),temporal.Shared());
      std::swap(barrier.Transition.StateBefore,barrier.Transition.StateAfter); cmd->ResourceBarrier(1,&barrier); submit();
      void* mapped = nullptr; gpu::Check(packed_readback.object->Map(0,nullptr,&mapped));
      const auto* words = static_cast<const uint32_t*>(mapped);
      uint32_t confident = 0;
      for (uint32_t y = 0; y < words[25]; ++y) for (uint32_t x = 0; x < words[24]; ++x) {
        uint16_t half;
        std::memcpy(&half,static_cast<const uint8_t*>(mapped)+words[27]+y*words[26]+x*8+6,2);
        confident += DirectX::PackedVector::XMConvertHalfToFloat(half) > .9f;
      }
      packed_readback.object->Unmap(0,nullptr); return confident;
    };
    render(temporal,false,false,100);
    Require(confidence_count() == 0,"Cold cloud history unexpectedly accepted");
    for (uint32_t tick = 1; tick <= 12; ++tick) render(temporal,false,false,100 + tick / 60.f);
    Require(confidence_count() > 20,"Warm cloud reconstruction never converged");
    const auto paused = render(temporal,false,false,100.2f);
    const auto paused_again = render(temporal,false,false,100.2f);
    Require(confidence_count() > 20,"Paused clock rejected valid cloud history");
    // A fixed camera and clock still advance the renderer's sample sequence.
    // Measure whether temporal reconstruction settles those changing samples.
    auto previous_paused = paused_again;
    double early_change = 0, late_change = 0;
    for (uint32_t tick = 0; tick < 32; ++tick) {
      const auto next = render(temporal,false,false,100.2f);
      double change = 0;
      for (size_t index = 0; index < next.size(); index += 4)
        change += std::abs(next[index] - previous_paused[index]);
      if (tick < 8) early_change += change;
      if (tick >= 24) late_change += change;
      previous_paused = next;
    }
    std::cout << "Paused cloud frame change early=" << early_change << " late=" << late_change
              << " confident=" << confidence_count() << " of " << temporal.LowWidth() * temporal.LowHeight() << '\n';
    Require(late_change < early_change * .95, "Paused cloud samples did not converge");
    ++inputs.revision;
    render(temporal,false,false,100.2167f);
    Require(confidence_count() == 0,"Cloud control edit retained stale history");
    clouds::density = 0; ++inputs.revision;
    const auto edited_clear = render(temporal,false,false,100.2333f);
    for (size_t index = 0; index < edited_clear.size(); ++index) Require(std::abs(edited_clear[index]-background[index%4]) < 1.e-6f,"Cloud removal dragged warm history into clear sky");
    clouds::density = 1.f; ++inputs.revision;
    for (const auto& values : {std::array<float,4>{0,.2f,.5f,0}, std::array<float,4>{8,2,3,1}}) {
      clouds::detail = values[0]; clouds::detail_size = values[1]; clouds::thickness = values[2]; clouds::base_softness = values[3]; ++inputs.revision;
      render(temporal);
    }
    clouds::detail = 1.f; clouds::detail_size = 1.f;
    clouds::thickness = 1.f; clouds::base_softness = 0; ++inputs.revision;
    cases += 10;
    std::vector<uint8_t> synthetic(1024, 0);
    auto store = [&](uint32_t offset, const void* data, size_t bytes) { std::memcpy(synthetic.data() + offset, data, bytes); };
    const uint32_t layout[4] = {2, 2, 256, 512}, valid = 1;
    store(96, layout, sizeof(layout)); store(112, frame[0].data(), 16); store(128, frame[286].data(), 16);
    store(144, frame[23].data(), 16); store(160, &valid, 4); store(192, frame[17].data(), 16); store(208, frame[18].data(), 16);
    const float native_motion[4] = {.03125f, -.0625f, .75f, 0.f};
    auto motion_probe = [&](std::array<float, 4> flow, float geometry) {
      uint16_t packed[4];
      for (uint32_t index = 0; index < 4; ++index) packed[index] = DirectX::PackedVector::XMConvertFloatToHalf(flow[index]);
      for (uint32_t y = 0; y < 2; ++y) for (uint32_t x = 0; x < 2; ++x) store(512 + 256 * y + 8 * x, packed, sizeof(packed));
      const auto field = gpu::Upload(device.Get(), synthetic.data(), synthetic.size());
      return probe(field.object.Get(), {0, 0, 0, .37f, native_motion[0], native_motion[1], native_motion[2], native_motion[3], 80, 45, geometry, 10});
    };
    const auto moving = motion_probe({.125f, -.25f, .75f, 1}, 0);
    Require(moving[4] == -.125f && moving[5] == .25f && moving[6] == 0 && moving[7] == 1, "Cloud motion sign or native validity encoding is incorrect");
    for (const auto& result : {motion_probe({.125f, -.25f, .75f, 1}, 1), motion_probe({.125f, -.25f, .25f, 1}, 0), motion_probe({.125f, -.25f, .75f, 0}, 0)})
      for (uint32_t index = 0; index < 4; ++index) Require(result[4 + index] == native_motion[index], "Cloud motion replaced foreground/thin/low-confidence native motion");
    synthetic[128] ^= 1;
    const auto stale = motion_probe({.125f, -.25f, .75f, 1}, 0);
    for (uint32_t index = 0; index < 4; ++index) Require(stale[4 + index] == native_motion[index], "Cloud motion accepted another frame's jitter");
    const auto fallback = probe(assets.zero.object.Get(), {0, 0, 0, .37f, 0, 0, 0, 0, 0, 0, 1, 10});
    Require(fallback[0] == .37f, "Unavailable cloud map did not preserve native visibility");
    cases += 6;
    // Run both production native converters, preserving their distinct UV
    // units and their native world-motion branch. Exercise both native formats.
    synthetic[128] ^= 1;
    std::array<D3D12_ROOT_PARAMETER,5> motion_roots{};
    motion_roots[0].ParameterType = motion_roots[1].ParameterType = D3D12_ROOT_PARAMETER_TYPE_CBV;
    motion_roots[0].Descriptor = {10,0}; motion_roots[1].Descriptor = {12,0};
    motion_roots[2].ParameterType = D3D12_ROOT_PARAMETER_TYPE_SRV; motion_roots[2].Descriptor = {0,72};
    D3D12_DESCRIPTOR_RANGE motion_ranges[2] = {{D3D12_DESCRIPTOR_RANGE_TYPE_SRV,7,0,0,0},{D3D12_DESCRIPTOR_RANGE_TYPE_UAV,5,0,0,0}};
    for (uint32_t index = 0; index < 2; ++index) { motion_roots[3+index].ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE; motion_roots[3+index].DescriptorTable = {1,&motion_ranges[index]}; }
    const D3D12_ROOT_SIGNATURE_DESC motion_root_desc{5,motion_roots.data()};
    ComPtr<ID3DBlob> motion_blob;
    gpu::Check(D3D12SerializeRootSignature(&motion_root_desc,D3D_ROOT_SIGNATURE_VERSION_1,&motion_blob,&feature_errors));
    ComPtr<ID3D12RootSignature> motion_root;
    gpu::Check(device->CreateRootSignature(0,motion_blob->GetBufferPointer(),motion_blob->GetBufferSize(),IID_PPV_ARGS(&motion_root)));
    if (std::filesystem::exists(directory / "native-9f.cso") && std::filesystem::exists(directory / "native-fa.cso"))
    for (const auto format : {DXGI_FORMAT_R16G16B16A16_FLOAT,DXGI_FORMAT_R16G16_FLOAT}) {
      auto native_texture = gpu::Image(device.Get(),width,height,format);
      gpu::Bank motion_bank(device.Get());
      gpu::Srv(device.Get(),motion_bank,0,depth.object.Get(),D3D12_SRV_DIMENSION_TEXTURE2D);
      for (uint32_t index = 1; index < 7; ++index) gpu::Srv(device.Get(),motion_bank,index,native_texture.object.Get(),D3D12_SRV_DIMENSION_TEXTURE2D);
      std::array<gpu::Resource,5> outputs;
      for (uint32_t index = 0; index < 5; ++index) {
        outputs[index] = gpu::Image(device.Get(),width,height,index == 2 || index == 3 ? DXGI_FORMAT_R32_FLOAT : DXGI_FORMAT_R32G32B32A32_FLOAT);
        D3D12_UNORDERED_ACCESS_VIEW_DESC desc{}; desc.Format = outputs[index].object->GetDesc().Format; desc.ViewDimension = D3D12_UAV_DIMENSION_TEXTURE2D;
        device->CreateUnorderedAccessView(outputs[index].object.Get(),nullptr,&desc,motion_bank.Cpu(8+index));
      }
      gpu::Uav(device.Get(),motion_bank,0,native_texture.object.Get());
      begin(); ID3D12DescriptorHeap* heaps[] = {motion_bank.heap.Get()}; cmd->SetDescriptorHeaps(1,heaps);
      gpu::Transition(cmd.Get(),&native_texture,D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
      const float encoded[4] = {.03125f,-.0625f,.25f,1};
      cmd->ClearUnorderedAccessViewFloat(motion_bank.Gpu(16),motion_bank.Cpu(16),native_texture.object.Get(),encoded,0,nullptr);
      gpu::Transition(cmd.Get(),&native_texture,gpu::TextureRead); submit();
      D3D12_PLACED_SUBRESOURCE_FOOTPRINT output_footprint{}; uint64_t output_bytes = 0;
      const auto output_desc = outputs[0].object->GetDesc();
      device->GetCopyableFootprints(&output_desc,0,1,0,&output_footprint,nullptr,nullptr,&output_bytes);
      auto output_readback = gpu::Buffer(device.Get(),output_bytes,D3D12_RESOURCE_STATE_COPY_DEST,D3D12_HEAP_TYPE_READBACK);
      for (uint32_t converter = 0; converter < 2; ++converter) {
        const auto production_code = Read(directory / (converter ? "motion-fa.cso" : "motion-9f.cso"));
        const auto original_code = Read(directory / (converter ? "native-fa.cso" : "native-9f.cso"));
        const auto production = gpu::Compute(device.Get(),motion_root.Get(),{production_code.data(),production_code.size()});
        const auto original = gpu::Compute(device.Get(),motion_root.Get(),{original_code.data(),original_code.size()});
        for (uint32_t scenario = 0; scenario < 4; ++scenario) {
          clear_inputs(1,scenario == 1 ? 1.f : 0.f);
          const float opacity = scenario == 2 ? .25f : .75f;
          const float flow[4] = {.125f,-.25f,opacity,1}; uint16_t packed[4];
          for (uint32_t channel = 0; channel < 4; ++channel) packed[channel] = DirectX::PackedVector::XMConvertFloatToHalf(flow[channel]);
          for (uint32_t y = 0; y < 2; ++y) for (uint32_t x = 0; x < 2; ++x) store(512+y*256+x*8,packed,sizeof(packed));
          const auto field = gpu::Upload(device.Get(),synthetic.data(),synthetic.size());
          std::array<float,128> parameters{};
          if (converter) {
            for (uint32_t matrix = 0; matrix < 6; ++matrix) for (uint32_t diagonal = 0; diagonal < 4; ++diagonal) parameters[matrix*16+diagonal*5] = 1;
            parameters[96] = width; parameters[97] = height; parameters[98] = 1.f/width; parameters[99] = 1.f/height;
            const uint32_t full_width = 1, world = scenario == 3;
            std::memcpy(&parameters[110],&full_width,4); std::memcpy(&parameters[111],&world,4);
          } else {
            parameters[0] = width; parameters[1] = height; parameters[2] = 1.f/width; parameters[3] = 1.f/height;
            for (uint32_t diagonal = 0; diagonal < 4; ++diagonal) parameters[4+diagonal*5] = 1;
          }
          const auto constants = gpu::Upload(device.Get(),parameters.data(),sizeof(parameters));
          auto convert = [&](ID3D12PipelineState* pipeline) {
            begin(); cmd->SetDescriptorHeaps(1,heaps); cmd->SetComputeRootSignature(motion_root.Get()); cmd->SetPipelineState(pipeline);
            cmd->SetComputeRootConstantBufferView(0,constants.object->GetGPUVirtualAddress()); cmd->SetComputeRootConstantBufferView(1,frame_buffer.object->GetGPUVirtualAddress());
            cmd->SetComputeRootShaderResourceView(2,field.object->GetGPUVirtualAddress()); cmd->SetComputeRootDescriptorTable(3,motion_bank.Gpu()); cmd->SetComputeRootDescriptorTable(4,motion_bank.Gpu(8));
            for (auto& output : outputs) gpu::Transition(cmd.Get(),&output,D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
            cmd->Dispatch((width+7)/8,(height+7)/8,1);
            gpu::Transition(cmd.Get(),&outputs[0],D3D12_RESOURCE_STATE_COPY_SOURCE);
            D3D12_TEXTURE_COPY_LOCATION source{outputs[0].object.Get(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX}, destination{output_readback.object.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT}; destination.PlacedFootprint = output_footprint;
            cmd->CopyTextureRegion(&destination,0,0,0,&source,nullptr); submit();
            void* mapped = nullptr; gpu::Check(output_readback.object->Map(0,nullptr,&mapped));
            std::array<float,4> result; std::memcpy(result.data(),mapped,16); output_readback.object->Unmap(0,nullptr); return result;
          };
          const auto reference = convert(original.Get()), converted = convert(production.Get());
          if (scenario == 1 || scenario == 2 || (scenario == 3 && converter)) Require(reference == converted,"Native converter foreground/thin/world path changed");
          else Require(std::abs(converted[0]-.125f*(converter ? width : 1)) < .0001f && std::abs(converted[1]+.25f*(converter ? height : 1)) < .0001f,"Native converter cloud motion units/sign changed");
          for (float value : converted) Require(std::isfinite(value),"Native converter produced non-finite cloud motion");
          ++cases;
        }
      }
    }
    CloseHandle(event);
    std::cout << "PASS " << cases << " production cloud GPU cases, six qualities, packed-shadow alignment/projection/Off, HDR transport, motion signs/confidence/foreground, duplicate lists and native fallback\n";
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
