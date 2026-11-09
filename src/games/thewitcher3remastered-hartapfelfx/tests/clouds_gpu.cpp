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
#include "../sky/native_size.hpp"
#include "cloud_camera.hpp"
#include "sky_night.hpp"
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
    const bool celestial_probe=operation.find("celestial")!=std::string_view::npos;
    const bool clear_sky_probe=operation.find("clear")!=std::string_view::npos
        &&operation.find("noclearing")==std::string_view::npos;
    const bool sun_probe=!celestial_probe &&(benchmark || capture) && operation.find("sun")!=std::string_view::npos;
    const bool moon_probe=!celestial_probe &&(benchmark || capture) && operation.find("moon")!=std::string_view::npos;
    const bool sparse_probe=(benchmark || capture) && operation.find("sparse")!=std::string_view::npos;
    const bool soft_probe=(benchmark || capture) && operation.find("soft")!=std::string_view::npos;
    const float sky_density=operation.find("haze200")!=std::string_view::npos ? 2.f : 1.f;
    Require(argc==2 || benchmark || capture ||(argc==4&&operation=="reference-stars"),
        "Expected compiled shader directory, optional benchmark/capture or reference-stars plus reference CSO");
    Require(clouds::Appearance()==std::array<float,4>{1.f,1.f,1.f,1.f},
        "Cloud appearance defaults must be neutral multipliers");
    Require(clouds::Atmosphere(1.f)==std::array<float,4>{1.f,1.f,1.f,0.f},
        "Cloud detail defaults must be neutral multipliers");
    if(operation.find("noclearing")!=std::string_view::npos)clouds::clear_low_sun=0.f;
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
        shader("0xF7C0000A.cso"), shader("0xF7C0000B.cso"), shader("0xF7C0000C.cso"), shader("0xF7C0000E.cso"), shader("0xF7C0000F.cso"), shader("0xF7C00010.cso"), shader("0xF7C00013.cso"), shader("0xF7C00014.cso"), shader("0xF7C00015.cso"), shader("0xF7C00016.cso")});
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
    auto* selected_feature=feature_pipeline.Get();
    auto feature_output = gpu::Buffer(device.Get(), 256, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    auto feature_readback = gpu::Buffer(device.Get(), 256, D3D12_RESOURCE_STATE_COPY_DEST, D3D12_HEAP_TYPE_READBACK);
    const uint32_t width = operation.find("preview")!=std::string_view::npos?640u:benchmark || capture ? (operation.find("4k")!=std::string_view::npos?3840u:1920u) : 161u;
    const uint32_t height = operation.find("preview")!=std::string_view::npos?360u:benchmark || capture ? (operation.find("4k")!=std::string_view::npos?2160u:1080u) : 91u;
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
    frame[199]={1.f,.96f,.9f,120.f};
    frame[203] = {1, 1, 1, 1}; frame[204] = {1, 0, 1, 1};
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
    frame[277]={.6971766f,.6685617f,.7664835f,1.f};
    const std::array<std::array<float, 4>, 16> light{{{sun_probe ? 0.f : .1f,
        sun_probe ? .8944272f : .4f,sun_probe ? .4472136f : .91f,1}, {30, 20, 10, 0}}};
    if(operation.find("lowsun")!=std::string_view::npos) {
      frame[204]={1,0,.99756405f,.06975647f};
      frame[2]=frame[18]={0,-.06975647f,.99756405f,0};
      frame[3]={0,.99756405f,.06975647f,0};
      frame[20]={0,.99756405f,.06975647f,5};
    }
    if(celestial_probe) {
      frame[13][0]=float(height)/float(width);
      frame[204]={120,0,.8944272f,.4472136f};frame[205]={1,0,-.8944272f,-.4472136f};
      if(operation.find("sunset")!=std::string_view::npos||operation.find("twilight")!=std::string_view::npos) {
        const float elevation=operation.find("twilight")!=std::string_view::npos?-.02f:.025f;
        const float horizontal=std::sqrt(1.f-elevation*elevation);
        frame[204]={40,0,horizontal,elevation};frame[205]={1,0,-horizontal,-elevation};
        frame[199]={27.3672714f,1.07121313f,.00014030948f,46.2497368f};
        frame[2]=frame[18]={0,-elevation,horizontal,0};frame[3]={0,horizontal,elevation,0};
        frame[20]={0,horizontal,elevation,5};
      }
      if(operation.find("night")!=std::string_view::npos)std::swap(frame[204],frame[205]);
      if(clear_sky_probe)clouds::coverage=0.f;
      if(operation.find("zoom")!=std::string_view::npos) {frame[13][0]*=20.f;frame[14][1]*=20.f;}
      if(operation.find("largebody")!=std::string_view::npos) {
        frame[206][3]=std::bit_cast<float>(0x80000000u|(2047u<<16u)|32768u);
        frame[37][3]=std::bit_cast<float>(0x4C000000u|(511u<<16u)|32768u);
      }
      if(operation.find("captured-night")!=std::string_view::npos) {
        for(unsigned i=0;i<std::size(sky_night_rows);++i)frame[sky_night_rows[i]]=sky_night_values[i];
        frame[0][2]=sky_night_camera_height;frame[340][2]=1.f;
      }
    }
    auto frame_buffer = gpu::Upload(device.Get(), frame.data(), sizeof(frame));
    if(operation.find("coherent")!=std::string_view::npos) {
      hartapfelfx::sky::emission::enabled=true;
      const float native_light[3]={30,20,10};
      hartapfelfx::sky::emission::ObservePrimary(native_light);
      hartapfelfx::sky::emission::ObserveMoon(frame[277].data(),false);
      hartapfelfx::sky::emission::ObserveFrame(frame.data());
    }
    auto probe = [&](ID3D12Resource* field, const std::array<float, 24>& values, uint64_t sky_frame = 0) {
      std::array<float, 64> parameters{};
      std::copy(values.begin(), values.end(), parameters.begin());
      const auto page = gpu::Upload(device.Get(), parameters.data(), sizeof(parameters));
      begin();
      cmd->SetComputeRootSignature(feature_root.Get()); cmd->SetPipelineState(selected_feature);
      cmd->SetComputeRootShaderResourceView(0, field->GetGPUVirtualAddress());
      cmd->SetComputeRootConstantBufferView(1, sky_frame ? sky_frame : frame_buffer.object->GetGPUVirtualAddress());
      cmd->SetComputeRootConstantBufferView(2, page.object->GetGPUVirtualAddress());
      cmd->SetComputeRootUnorderedAccessView(3, feature_output.object->GetGPUVirtualAddress());
      cmd->Dispatch(1, 1, 1);
      gpu::Transition(cmd.Get(), &feature_output, D3D12_RESOURCE_STATE_COPY_SOURCE);
      cmd->CopyResource(feature_readback.object.Get(), feature_output.object.Get());
      gpu::Transition(cmd.Get(), &feature_output, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
      submit();
      void* mapped = nullptr;
      gpu::Check(feature_readback.object->Map(0, nullptr, &mapped));
      std::array<float, 64> result{};
      std::memcpy(result.data(), mapped, sizeof(result));
      feature_readback.object->Unmap(0, nullptr);
      return result;
    };
    auto light_buffer = gpu::Upload(device.Get(), light.data(), sizeof(light));
    auto depth = gpu::Image(device.Get(), width, height, DXGI_FORMAT_R32_FLOAT);
    auto weather = gpu::Image(device.Get(), 8, 8, DXGI_FORMAT_R32_FLOAT, 16);
    auto target_desc = depth.object->GetDesc();
    const bool half_target=operation.find("fp16")!=std::string_view::npos;
    target_desc.Format = half_target ? DXGI_FORMAT_R16G16B16A16_FLOAT : DXGI_FORMAT_R32G32B32A32_FLOAT;
    target_desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET;
    auto target = gpu::Create(device.Get(), target_desc, D3D12_RESOURCE_STATE_RENDER_TARGET);
    ComPtr<ID3D12DescriptorHeap> rtv;
    const D3D12_DESCRIPTOR_HEAP_DESC rtv_desc{D3D12_DESCRIPTOR_HEAP_TYPE_RTV, 1};
    gpu::Check(device->CreateDescriptorHeap(&rtv_desc, IID_PPV_ARGS(&rtv)));
    device->CreateRenderTargetView(target.object.Get(), nullptr, rtv->GetCPUDescriptorHandleForHeapStart());
    clouds::Inputs inputs;
    // Explicit native-mesh fixture angles, never production fallback sizes.
    inputs.native_radius={.0316336f,.124752f};
    if(operation.find("native-solar-material")!=std::string_view::npos)inputs.sun_material={1.f,.25f,.5f,1.f};
    if(operation.find("native-material")!=std::string_view::npos)
      inputs.moon_material=operation.find("toussaint")!=std::string_view::npos
          ?std::array<float,4>{.5f,.75f,1.25f,2.f}:std::array<float,4>{14.2849865f,2.55107808f,.82191229f,1.f};
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
    inputs.weather_view.Texture2DArray = {0, 1, 0, 16};
    auto family_selection=[](uint32_t region,std::string_view name) -> uint64_t {
      for(const auto& row:clouds::families::weather)
        if(row.region==region &&name==clouds::families::names[row.name].text)
          return uint64_t(row.profile)|(uint64_t(row.profile)<<8);
      throw std::runtime_error("Unknown cloud-family fixture");
    };
    if(operation.find("family-clear")!=std::string_view::npos)inputs.family=family_selection(1,"WT_Clear");
    if(operation.find("family-light")!=std::string_view::npos)inputs.family=family_selection(1,"WT_Light_Clouds");
    if(operation.find("family-mid")!=std::string_view::npos)inputs.family=family_selection(1,"WT_Mid_Clouds");
    if(operation.find("family-storm")!=std::string_view::npos)inputs.family=family_selection(1,"WT_Rain_Storm");
    if(operation.find("family-bob")!=std::string_view::npos)inputs.family=family_selection(11,"WT_Mid_Clouds");
    if (!benchmark && !capture) {
      clouds::View cached_view(&assets, 64, 64, 0);
      clouds::BindingCache cache;
      auto alternate_weather = gpu::Image(device.Get(), 8, 8, DXGI_FORMAT_R32_FLOAT, 16);
      auto alternate = inputs;
      alternate.weather = alternate_weather.object.Get();
      const auto first = cache.Acquire(cached_view, inputs, 64);
      const auto second = cache.Acquire(cached_view, alternate, 64);
      auto family_only=inputs;
      family_only.family=family_selection(1,"WT_Light_Clouds");
      Require(cache.Acquire(cached_view,family_only,64)==first,
          "A family change allocated a new descriptor binding set");
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
        replacements.push_back(gpu::Image(device.Get(), 8, 8, DXGI_FORMAT_R32_FLOAT, 16));
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
    weather_uav.Texture2DArray.ArraySize=15;
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
    double weather_ms = 0, shadow_ms = 0, render_ms = 0, environment_ms = 0, sky_ms = 0;
    if (benchmark) {
      const D3D12_QUERY_HEAP_DESC description{D3D12_QUERY_HEAP_TYPE_TIMESTAMP, 7};
      gpu::Check(device->CreateQueryHeap(&description, IID_PPV_ARGS(&timestamps)));
      timestamp_readback = gpu::Buffer(device.Get(), 56, D3D12_RESOURCE_STATE_COPY_DEST, D3D12_HEAP_TYPE_READBACK);
      gpu::Check(queue->GetTimestampFrequency(&frequency));
    }
    const float background[4] = {.2f, .3f, .4f, .75f};
    ComPtr<ID3D12PipelineState> depth_probe_pipeline;
    if (!benchmark && !capture) {
      const auto probe=Read(directory/"cloud-depth.cso");
      depth_probe_pipeline=gpu::Graphics(device.Get(),assets.root.Get(),{code.front().data(),code.front().size()},
          {probe.data(),probe.size()},target_desc.Format);
    }
    ComPtr<ID3D12PipelineState> sky_pipeline;
    const bool native_sky_probe=operation.find("native-sky")!=std::string_view::npos;
    ComPtr<ID3D12RootSignature> native_sky_root;
    std::shared_ptr<gpu::Bank> native_sky_bank;
    gpu::Resource native_sky_material,native_sky_camera,native_sky_settings,native_sky_global;
    if(celestial_probe) {
      if(native_sky_probe) {
        std::array<D3D12_ROOT_PARAMETER,8> roots{};
        for(unsigned i=0;i<5;++i)roots[i].ParameterType=D3D12_ROOT_PARAMETER_TYPE_CBV;
        roots[0].Descriptor={0,0};roots[1].Descriptor={1,0};roots[2].Descriptor={2,0};
        roots[3].Descriptor={12,0};roots[4].Descriptor={0,70};
        roots[5].ParameterType=roots[6].ParameterType=D3D12_ROOT_PARAMETER_TYPE_SRV;
        roots[5].Descriptor={0,71};roots[6].Descriptor={0,72};
        D3D12_DESCRIPTOR_RANGE range{D3D12_DESCRIPTOR_RANGE_TYPE_SRV,2,0,0,0};
        roots[7].ParameterType=D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;
        roots[7].DescriptorTable={1,&range};
        D3D12_STATIC_SAMPLER_DESC sampler{};
        sampler.Filter=D3D12_FILTER_MIN_MAG_MIP_LINEAR;
        sampler.AddressU=sampler.AddressV=sampler.AddressW=D3D12_TEXTURE_ADDRESS_MODE_WRAP;
        sampler.MaxLOD=D3D12_FLOAT32_MAX;
        sampler.ComparisonFunc=D3D12_COMPARISON_FUNC_ALWAYS;
        const D3D12_ROOT_SIGNATURE_DESC desc{unsigned(roots.size()),roots.data(),1,&sampler};
        ComPtr<ID3DBlob> blob,errors;
        gpu::Check(D3D12SerializeRootSignature(&desc,D3D_ROOT_SIGNATURE_VERSION_1,&blob,&errors));
        gpu::Check(device->CreateRootSignature(0,blob->GetBufferPointer(),blob->GetBufferSize(),IID_PPV_ARGS(&native_sky_root)));
        const auto vertex=Read(directory/"sky-vs.cso");
        const auto pixel=Read(directory/(operation.find("toussaint")!=std::string_view::npos?"3B15DAAB.cso":"449D3390.cso"));
        sky_pipeline=gpu::Graphics(device.Get(),native_sky_root.Get(),{vertex.data(),vertex.size()},
            {pixel.data(),pixel.size()},target_desc.Format);
        std::array<float,64> settings{};
        ShaderInjectData disabled{};disabled.sky_density=sky_density;
        std::memcpy(settings.data(),&disabled,sizeof(disabled));
        const uint32_t deferred=0x534B5943u;std::memcpy(settings.data()+12,&deferred,4);
        std::memcpy(settings.data()+16,inputs.moon_material.data(),16);
        std::memcpy(settings.data()+20,inputs.sun_material.data(),16);
        settings[24]=hartapfelfx::sky::sun_glow_size;
        std::memcpy(settings.data()+28,inputs.native_radius.data(),sizeof(inputs.native_radius));
        native_sky_settings=gpu::Upload(device.Get(),settings.data(),sizeof(settings));
        std::array<std::array<float,4>,64> material{},camera{};
        material[0]={0,1,0,0};camera[36]=frame[0];
        native_sky_material=gpu::Upload(device.Get(),material.data(),sizeof(material));
        native_sky_camera=gpu::Upload(device.Get(),camera.data(),sizeof(camera));
        std::array<std::array<float,4>,16> global{};global[9][0]=1.f;global[0][3]=.75f;
        native_sky_global=gpu::Upload(device.Get(),global.data(),sizeof(global));
        native_sky_bank=std::make_shared<gpu::Bank>(device.Get());
        D3D12_SHADER_RESOURCE_VIEW_DESC cube{};
        cube.Format=DXGI_FORMAT_R8G8B8A8_UNORM;cube.ViewDimension=D3D12_SRV_DIMENSION_TEXTURECUBE;
        cube.Shader4ComponentMapping=D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;cube.TextureCube.MipLevels=1;
        for(unsigned i=0;i<2;++i)device->CreateShaderResourceView(nullptr,&cube,native_sky_bank->Cpu(i));
      } else {
        const auto sky=Read(directory/"sky.cso");
        sky_pipeline=gpu::Graphics(device.Get(),assets.root.Get(),{code.front().data(),code.front().size()},
            {sky.data(),sky.size()},target_desc.Format);
      }
    }
    std::vector<gpu::Resource> clocks;
    gpu::Resource occlusion_mask;
    std::shared_ptr<gpu::Bank> mask_bank;
    bool disc_enabled=operation.find("nodisc")==std::string_view::npos;
    auto render = [&](clouds::View& view, bool duplicate = false, bool compute_weather = false,
                      float clock_seconds = -1.f, bool retain_clock = false, bool depth_probe = false) {
      inputs.light=light_buffer.object->GetGPUVirtualAddress();
      std::array<float, 64> clock{};
      clock[0] = clock_seconds >= 0.f ? clock_seconds : float(serial) * 2.f;
      clock[3] = .75f;
      if(operation.find("phase-waxing")!=std::string_view::npos)clock[3]=0.f;
      if(operation.find("phase-waning")!=std::string_view::npos)clock[3]=.5f;
      if(operation.find("phase-new")!=std::string_view::npos)clock[3]=.25f;
      if(!retain_clock || clocks.empty())clocks.push_back(gpu::Upload(device.Get(), clock.data(), sizeof(clock)));
      inputs.clock = clocks.back().object->GetGPUVirtualAddress();
      inputs.enhanced_sky=celestial_probe&&disc_enabled;
      inputs.captured_sun = sun_probe;
      inputs.captured_moon = moon_probe;
      const auto bindings = view.PrepareBindings(inputs, uint32_t(clouds::QualityLighting(clouds::quality)[3]));
      if(operation.find("occlusion-mask")!=std::string_view::npos) {
        if(!occlusion_mask.object) {
          occlusion_mask=gpu::Image(device.Get(),view.LowWidth(),view.LowHeight(),DXGI_FORMAT_R16G16B16A16_FLOAT);
          mask_bank=std::make_shared<gpu::Bank>(device.Get());
          gpu::Uav(device.Get(),*mask_bank,0,occlusion_mask.object.Get());
        }
        gpu::Srv(device.Get(),*bindings.composite,14,occlusion_mask.object.Get(),D3D12_SRV_DIMENSION_TEXTURE2D);
      }
      const auto page = view.ParameterPage(inputs, sky_density);
      const auto weather_page = view.ParameterPage(inputs, sky_density, 1);
      const auto shadow_page = view.ParameterPage(inputs, sky_density, 2);
      begin();
      if(mask_bank) {
        ID3D12DescriptorHeap* heaps[]={mask_bank->heap.Get()};cmd->SetDescriptorHeaps(1,heaps);
        gpu::Transition(cmd.Get(),&occlusion_mask,D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
        // The production half-float storage encodes opacity, not transmission.
        const float transparent[4]={0,0,0,0},opaque[4]={0,0,0,1};
        cmd->ClearUnorderedAccessViewFloat(mask_bank->Gpu(16),mask_bank->Cpu(16),occlusion_mask.object.Get(),transparent,0,nullptr);
        const D3D12_RECT left{0,0,LONG(view.LowWidth()/2u),LONG(view.LowHeight())};
        cmd->ClearUnorderedAccessViewFloat(mask_bank->Gpu(16),mask_bank->Cpu(16),occlusion_mask.object.Get(),opaque,1,&left);
        gpu::Transition(cmd.Get(),&occlusion_mask,gpu::TextureRead);
      }
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
      if(benchmark)cmd->EndQuery(timestamps.Get(),D3D12_QUERY_TYPE_TIMESTAMP,5);
      if(celestial_probe) {
        if(native_sky_probe) {
          cmd->SetGraphicsRootSignature(native_sky_root.Get());
          cmd->SetGraphicsRootConstantBufferView(0,native_sky_global.object->GetGPUVirtualAddress());
          cmd->SetGraphicsRootConstantBufferView(1,native_sky_camera.object->GetGPUVirtualAddress());
          cmd->SetGraphicsRootConstantBufferView(2,native_sky_material.object->GetGPUVirtualAddress());
          cmd->SetGraphicsRootConstantBufferView(3,inputs.frame);
          cmd->SetGraphicsRootConstantBufferView(4,native_sky_settings.object->GetGPUVirtualAddress());
          cmd->SetGraphicsRootShaderResourceView(5,assets.zero.object->GetGPUVirtualAddress());
          cmd->SetGraphicsRootShaderResourceView(6,view.Shared()->GetGPUVirtualAddress());
          ID3D12DescriptorHeap* heaps[]={native_sky_bank->heap.Get()};cmd->SetDescriptorHeaps(1,heaps);
          cmd->SetGraphicsRootDescriptorTable(7,native_sky_bank->Gpu());
        } else {
          cmd->SetGraphicsRootSignature(assets.root.Get());
          cmd->SetGraphicsRootConstantBufferView(0,inputs.frame);
          cmd->SetGraphicsRootConstantBufferView(2,page.object->GetGPUVirtualAddress());
          ID3D12DescriptorHeap* heaps[]={bindings.composite->heap.Get()};cmd->SetDescriptorHeaps(1,heaps);
          cmd->SetGraphicsRootDescriptorTable(7,bindings.composite->Gpu());
        }
        cmd->SetPipelineState(sky_pipeline.Get());
        const D3D12_VIEWPORT viewport{0,0,float(width),float(height),0,1};
        const D3D12_RECT scissor{0,0,LONG(width),LONG(height)};
        cmd->RSSetViewports(1,&viewport);cmd->RSSetScissorRects(1,&scissor);
        cmd->OMSetRenderTargets(1,&inputs.target,FALSE,nullptr);
        cmd->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);cmd->DrawInstanced(3,1,0,0);
      }
      if(benchmark)cmd->EndQuery(timestamps.Get(),D3D12_QUERY_TYPE_TIMESTAMP,6);
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
        cmd->ResolveQueryData(timestamps.Get(), D3D12_QUERY_TYPE_TIMESTAMP, 0, 7, timestamp_readback.object.Get(), 0);
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
        sky_ms = 1000.0 * double(ticks[6] - ticks[5]) / double(frequency);
        timestamp_readback.object->Unmap(0, nullptr);
      }
      auto pixels = [&]() {
        void* data = nullptr;
        gpu::Check(readback.object->Map(0, nullptr, &data));
        std::vector<float> result(width * height * 4);
        for (uint32_t y = 0; y < height; ++y) {
          const auto* row=static_cast<const uint8_t*>(data)+y*footprint.Footprint.RowPitch;
          if(half_target)for(uint32_t x=0;x<width*4u;++x) {
            uint16_t word;std::memcpy(&word,row+x*2u,2);
            result[(size_t(y)*width*4u)+x]=DirectX::PackedVector::XMConvertHalfToFloat(word);
          } else std::memcpy(result.data()+y*width*4u,row,width*16u);
        }
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
      if(const auto index=operation.find("preset");index!=std::string_view::npos)
        clouds::quality_preset=float(operation.at(index+6)-'0');
      if(const auto index=operation.find("quality");index!=std::string_view::npos)
        clouds::quality=float(operation.at(index+7)-'0');
      if(operation.find("spacing50")!=std::string_view::npos)clouds::step_size=.5f;
      if(operation.find("authored")!=std::string_view::npos) {
        clouds::coverage=1.f;clouds::density=.2f;clouds::size=1.f;clouds::thickness=1.f;
        clouds::detail=1.3f;clouds::detail_size=.6f;
        clouds::base_height=1650.f;clouds::roundness=.87f;clouds::height_variation=1.74f;
        clouds::billow_size=1.58f;clouds::erosion=1.6f;clouds::wisp_bias=.55f;
        clouds::base_relief=.41f;clouds::top_relief=1.71f;clouds::edge_sharpness=.56f;
        clouds::base_feather=4.f;clouds::top_feather=.31f;
        clouds::sunlight=2.f;clouds::self_shadow=1.5f;clouds::forward_scattering=.6f;
      }
      clouds::base_softness=soft_probe?1.f:0.f;
      clouds::View view(&assets, width, height, clouds::quality, target_desc.Format);
      const float capture_time=operation.find("-time")!=std::string_view::npos
          ?std::stof(std::string(operation.substr(operation.find("-time")+5u))):100.f;
      for (uint32_t index = 0; index < 16; ++index) render(view,false,false,capture_time);
      if(capture) {
        const auto image=render(view,false,false,capture_time);
        if(operation.find("native-solar-material")!=std::string_view::npos) {
          const size_t center=(size_t(height/2u)*width+width/2u)*4u;
          const auto material=inputs.sun_material;
          inputs.sun_material={0,0,0,1};++inputs.revision;
          const auto halo_only=render(view,false,false,100.f);
          const float red=image[center]-halo_only[center],green=image[center+1]-halo_only[center+1];
          Require(red>20.f&&std::abs(red/green-material[0]/material[1])<.02f,
              "FP16 solar body/core lost the native HDR material colour ratios");
          inputs.sun_material=material;++inputs.revision;
          std::cout<<"PASS actual FP16 solar native HDR colour, separate native halo and positive source composition\n";
        }
        if(operation.find("native-material")!=std::string_view::npos) {
          const size_t center=(size_t(height/2u)*width+width/2u)*4u;
          const float expected=inputs.moon_material[0]/inputs.moon_material[1]
              *(inputs.moon_material[3]==2.f?frame[277][0]/frame[277][1]:1.f);
          Require(image[center]>.01f&&std::abs(image[center]/image[center+1]/expected-1.f)<.005f,
              "Production composite did not preserve native Moon material colour/radiance");
          std::cout<<"PASS actual FP16 composite native Moon material family="<<inputs.moon_material[3]<<"\n";
        }
        if(mask_bank) {
          // An opaque current cloud and a transparent history are deliberately
          // contradictory. Neither a disc, halo nor star may leak into it.
          for(uint32_t y=0;y<height;++y)for(uint32_t x=0;x+2u<width/2u;++x)
            for(unsigned c=0;c<3u;++c)
              Require(std::abs(image[(size_t(y)*width+x)*4u+c])<.0001f,"Celestial source appeared in front of the current cloud silhouette");
          float visible=0;
          for(uint32_t y=0;y<height;++y)for(uint32_t x=width/2u+4u;x<width;++x)
            visible=std::max(visible,image[(size_t(y)*width+x)*4u]);
          Require(visible>.01f,"Occlusion erased the unobstructed side of the celestial sky");
          std::cout<<"PASS current-cloud/transparent-history silhouette occludes discs, aureoles and stars\n";
        }
        if(operation.find("captured-night")!=std::string_view::npos) {
          hartapfelfx::sky::star_brightness=0.f;++inputs.revision;
          const auto no_stars=render(view,false,false,100.f);
          uint32_t visible=0;
          for(size_t i=0;i<image.size();i+=4u)
            visible+=std::max({image[i]-no_stars[i],image[i+1]-no_stars[i+1],image[i+2]-no_stars[i+2]})>.003f;
          Require(visible>=10u,"Stars vanished into the captured native night sky and haze at default brightness");
          hartapfelfx::sky::star_brightness=1.f;++inputs.revision;
          std::cout<<"PASS captured-night default stellar contrast: "<<visible<<" visible point pixels\n";
        }
        if(celestial_probe&&!clear_sky_probe) {
          const auto frozen=render(view,false,false,100.f,true);
          for(size_t i=0;i<image.size();++i)
            Require(std::abs(frozen[i]-image[i])<.001f,"A fresh sky lost clouds/celestials while photo mode froze the GPU clock");
          const size_t center=(size_t(height/2u)*width+width/2u)*4u;
          disc_enabled=false;++inputs.revision;
          const auto obscured_without_source=render(view,false,false,100.f);
          disc_enabled=true;clouds::coverage=0.f;++inputs.revision;
          const auto clear=render(view,false,false,100.f);
          Require(clear[center]>(operation.find("night")!=std::string_view::npos?.01f:20.f),
              "Analytic celestial source disappeared in a clear sky");
          for(uint32_t channel=0;channel<3;++channel)
            Require(std::abs(image[center+channel]-obscured_without_source[center+channel])
                <std::max(clear[center+channel]*.0001f,.0001f),
                "Direct celestial radiance leaked through an opaque cloud");
          for(size_t i=0;i<image.size();++i)
            if(i%4u!=3u)Require(image[i]>=-.001f,"Celestial compositing produced negative radiance");
          std::cout<<"PASS analytic celestial clear/opaque integration, target="<<(half_target?"FP16":"FP32")<<"\n";
        }
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
          if(operation.find("rainair")!=std::string_view::npos || screenshot_settings || moon_probe ||operation.find("lowsun")!=std::string_view::npos) {
            disc_enabled=false;
            const auto no_disc=render(view,false,false,100.f);
            disc_enabled=true;
            const float disc_rgb[3]={moon_probe ? 20.f : 80.f,
                moon_probe ? 17.f : 65.f,
                moon_probe ? 14.f : 48.f};
            for(uint32_t channel=0;channel<3;++channel) {
              const float remaining=(image[center+channel]-no_disc[center+channel])/disc_rgb[channel];
              std::cout<<"HDR disc channel "<<channel<<" remaining="<<remaining<<"\n";
              if(operation.find("lowsun")!=std::string_view::npos &&clouds::clear_low_sun>0.f &&operation.find("family-storm")==std::string_view::npos)
                Require(remaining>.98f,"Low-sun material opening failed to reveal the HDR disc");
              else Require(remaining<.02f,"Cloud leaked more than 2% of the HDR emitter disc");
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
      std::vector<double> timings, weather_timings, shadow_timings, environment_timings, sky_timings;
      for (uint32_t index = 0; index < 16; ++index) {
        render(view,false,false,capture_time);
        timings.push_back(render_ms);
        weather_timings.push_back(weather_ms);
        shadow_timings.push_back(shadow_ms);
        environment_timings.push_back(environment_ms);
        sky_timings.push_back(sky_ms);
      }
      std::sort(timings.begin(), timings.end());
      std::sort(weather_timings.begin(), weather_timings.end());
      std::sort(shadow_timings.begin(), shadow_timings.end());
      std::sort(environment_timings.begin(), environment_timings.end());
      std::sort(sky_timings.begin(),sky_timings.end());
      if(celestial_probe)std::cout<<"Celestial sky adapter GPU median ms="<<.5*(sky_timings[7]+sky_timings[8])<<" (test draw; production uses native sky)\n";
      std::cout << "Cloud weather/shadow/render/environment GPU median ms=" << .5 * (weather_timings[7] + weather_timings[8])
                << "/" << .5 * (shadow_timings[7] + shadow_timings[8]) << "/" << .5 * (timings[7] + timings[8])
                << "/" << .5 * (environment_timings[7] + environment_timings[8]) << " min=" << timings.front()
                << " max=" << timings.back() << " at " << width << "x" << height
                << " preset=" << clouds::quality_preset << " quality=" << clouds::quality
                << " trace=" << view.LowWidth() << "x" << view.LowHeight()
                << " allocationMiB=" << double(view.Bytes())/(1024.0*1024.0) << "\n";
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
    {
      // Fixed weather/wind/camera: clouds must evolve without a weather
      // transition, stay continuous at gameplay frame intervals, and freeze
      // exactly with the native clock. Probe the production shared material.
      auto state=frame;state[340][0]=5.f;state[67]={0,0,0,0};
      const auto evolution_frame=gpu::Upload(device.Get(),state.data(),sizeof(state));
      inputs.frame=evolution_frame.object->GetGPUVirtualAddress();++inputs.revision;
      clouds::View evolving(&assets,width,height,clouds::quality,target_desc.Format);
      const auto first=render(evolving,false,false,0.f,false,true);
      const auto next=render(evolving,false,true,1.f/60.f,false,true);
      const auto minute=render(evolving,false,false,60.f,false,true);
      const auto paused=render(evolving,false,true,60.f,false,true);
      double short_change=0,minute_change=0;
      uint32_t occupied=0,changed=0;
      for(size_t i=0;i<first.size();i+=4u) {
        occupied+=first[i]>0.f;
        changed+=std::abs(first[i]-minute[i])>.01f;
        short_change+=std::abs(first[i]-next[i]);
        minute_change+=std::abs(first[i]-minute[i]);
        for(const auto* image:{&first,&next,&minute,&paused}) {
          Require(std::isfinite((*image)[i])&&std::isfinite((*image)[i+1u])
              &&(*image)[i+1u]>=0.f&&(*image)[i+1u]<=(*image)[i]+.00001f,
              "Evolving cloud erosion escaped its conservative density bound");
          Require(std::abs((*image)[i+2u]-first[i+2u])<.00001f,
              "Material evolution moved the native weather probability field");
        }
        Require(std::abs(minute[i]-paused[i])<.00001f
            &&std::abs(minute[i+1u]-paused[i+1u])<.00001f,
            "Cloud form evolved while the native animation clock was paused");
      }
      Require(occupied>100u&&changed>100u&&minute_change>short_change*100.f,
          "Cloud form failed to evolve gradually at fixed weather and zero wind");
      // Cross the periodic column/side sample boundaries without a reset.
      std::vector<float> before_wrap;
      for(float seconds:{449.99f,450.01f,1499.99f,1500.01f,86400.f}) {
        const auto image=render(evolving,false,false,seconds,false,true);
        for(size_t i=0;i<image.size();i+=4u) {
          Require(std::isfinite(image[i])&&image[i+1u]>=0.f&&image[i+1u]<=image[i]+.00001f,
              "Noise tile traversal or long native time corrupted cloud density");
          if(seconds==450.01f||seconds==1500.01f)
            Require(std::abs(image[i]-before_wrap[i])<.01f
                &&std::abs(image[i+1u]-before_wrap[i+1u])<.01f,
                "Evolving cloud shape popped across a periodic noise boundary");
        }
        before_wrap=image;
      }
      std::cout<<"Cloud evolution: occupied="<<occupied<<" changed after 60s="<<changed
          <<" coarse L1 frame/minute="<<short_change<<"/"<<minute_change<<"\n";
      inputs.frame=frame_buffer.object->GetGPUVirtualAddress();++inputs.revision;
      cases+=5;
    }
    {
      // Project production GPU rays back through the captured native camera.
      // A stationary camera must close to the pixel even as TAA jitter changes.
      const auto saved_frame=frame;
      const auto saved_address=inputs.frame;
      clouds::View camera_probe(&assets,width,height,clouds::quality,target_desc.Format);
      double worst=0;
      for(const auto& captured:cloud_camera_frames) {
        for(uint32_t row=0;row<std::size(cloud_camera_rows);++row)
          std::copy_n(captured[row],4,frame[cloud_camera_rows[row]].begin());
        frame[340][0]=3.f;
        const auto camera_upload=gpu::Upload(device.Get(),frame.data(),sizeof(frame));
        inputs.frame=camera_upload.object->GetGPUVirtualAddress();
        const auto rays=render(camera_probe,false,false,-1.f,false,true);
        for(uint32_t y=0;y<height;++y)for(uint32_t x=0;x<width;++x) {
          double view[3]{};
          for(uint32_t axis=0;axis<3;++axis)for(uint32_t world=0;world<3;++world)
            view[axis]+=double(rays[(y*width+x)*4+world])*frame[1+world][axis];
          const double px=(view[0]/view[2]*frame[13][0]+frame[15][0])*.5+.5;
          const double py=(view[1]/view[2]*frame[14][1]+frame[15][1])*-.5+.5;
          worst=std::max({worst,std::abs(px*width-(x+.5)),std::abs(py*height-(y+.5))});
        }
        ++cases;
      }
      frame=saved_frame;inputs.frame=saved_address;
      std::cout<<"Native jitter camera ray closure worst="<<worst<<" pixels\n";
      Require(worst<.002,"Cloud rays shake relative to the native jittered camera");
    }
    for (uint32_t level = 0; level < 10; ++level) {
      clouds::quality_preset=level<6u?0.f:float(level-5u);
      clouds::quality = float(std::min(level,5u));
      clouds::View view(&assets, width, height, clouds::quality, target_desc.Format);
      const auto sampling=clouds::Quality(clouds::quality);
      Require(view.LowWidth() == (width+sampling[0]-1)/sampling[0]
          && view.LowHeight() == (height+sampling[0]-1)/sampling[0], "Cloud quality has incorrect rounded trace dimensions");
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
      const std::array<float, 24> full_shadow_probe{0, 0, 0, .37f, 0, 0, 0, 0, 0, 0, 1, 10};
      render(view,false,false,800.f);
      const auto full = probe(view.Shared(), full_shadow_probe);
      Require(full[0]<.98f,"Shadow strength fixture did not contain a cloudy column");
      clouds::shadows = .25f;
      ++inputs.revision;
      render(view,false,false,800.f);
      const auto reduced = probe(view.Shared(), full_shadow_probe);
      Require(std::abs(reduced[0]-std::lerp(1.f,full[0],.25f))<.0001f,
          "Partial cloud shadow strength did not transmit the expected light");
      Require(std::abs(reduced[13]-.37f*reduced[0])<.0001f&&reduced[14]==0.f,
          "Partial cloud shadow strength changed native geometry occlusion");
      clouds::shadows = 0;
      ++inputs.revision;
      render(view,false,false,800.f);
      const auto off = probe(view.Shared(), full_shadow_probe);
      Require(off[0] == 1, "Cloud-shadow Off retained native/procedural shadows");
      Require(off[12] == 1.f && std::abs(off[13] - .37f) < .0001f && off[14] == 0.f,
          "Cloud-shadow Off removed native geometry occlusion");
      clouds::shadows = 1;
      ++inputs.revision;
      cases += 10;
    }
    clouds::quality_preset=0.f;
    // Same camera, sun, jitter and clock address: changing native wind must
    // invalidate the shadow cache and move the world-space shadow texture.
    clocks.clear();
    clouds::quality=1.f;
    clouds::View moving_shadow(&assets,width,height,clouds::quality,target_desc.Format);
    render(moving_shadow,false,false,500.f,true);
    auto moving_readback=gpu::Buffer(device.Get(),moving_shadow.Shared()->GetDesc().Width,
        D3D12_RESOURCE_STATE_COPY_DEST,D3D12_HEAP_TYPE_READBACK);
    std::array<float,3> captured_shadow_sun{};
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
      std::copy_n(values+4,3,captured_shadow_sun.begin());
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
    moving_frame[67][0]=108.f;
    const auto moving_upload=gpu::Upload(device.Get(),moving_frame.data(),sizeof(moving_frame));
    inputs.frame=moving_upload.object->GetGPUVirtualAddress();
    render(moving_shadow,false,false,500.f,true);
    const auto after_wind=shadow_snapshot();
    Require(before_wind.first==0.f && after_wind.first==108.f,
        "Native wind change reused stale shadow metadata");
    uint32_t changed=0;
    for(size_t i=0;i<before_wind.second.size();++i)changed+=before_wind.second[i]!=after_wind.second[i];
    Require(changed>100,"Native wind change did not move cloud shadows");
    // The same wind translates the cloud material toward negative world X.
    // Compare the captured shadow field against that expected displacement,
    // rather than accepting any change (including a misplaced new pattern).
    const uint32_t sampled_size=(moving_shadow.ShadowSize()+7)/8;
    const uint32_t expected_shift=uint32_t(std::round(108.f*7.f/32000.f*sampled_size));
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
    disc_frame[38]={-.814229548f,-.314729363f,.487827599f,1.f};
    disc_frame[204]={120.f,-.847278476f,-.327503979f,.418163061f};
    const auto disc_upload=gpu::Upload(device.Get(),disc_frame.data(),sizeof(disc_frame));
    inputs.frame=disc_upload.object->GetGPUVirtualAddress();
    render(moving_shadow,false,false,500.f,true);
    const auto disc_shadow=shadow_snapshot();
    const float solar_length=std::sqrt(disc_frame[204][1]*disc_frame[204][1]
        +disc_frame[204][2]*disc_frame[204][2]+disc_frame[204][3]*disc_frame[204][3]);
    for(uint32_t channel=0;channel<3u;++channel)
      Require(std::abs(captured_shadow_sun[channel]-disc_frame[204][channel+1u]/solar_length)<.00001f,
          "Terrain shadow used the atmospheric vector instead of the native solar direction");
    uint32_t disc_changed=0;
    for(size_t i=0;i<before_wind.second.size();++i)
      disc_changed+=before_wind.second[i]!=disc_shadow.second[i];
    Require(disc_changed>100,"Terrain cloud shadow ignored the visible solar direction");
    // Captured night scene: the solar lobe is below the horizon while
    // the visible moon is above it. Both weather paths must retain the
    // same lunar shadow/glow field and the daytime alignment above.
    auto night_frame=frame;
    night_frame[38]={-.962336f,.043840f,.268303f,1.f};
    night_frame[204]={119.496605f,-.986885f,.044957f,-.155038f};
    night_frame[205]={34.322464f,-.928320f,.042291f,.369369f};
    const auto night_upload=gpu::Upload(device.Get(),night_frame.data(),sizeof(night_frame));
    inputs.frame=night_upload.object->GetGPUVirtualAddress();++inputs.revision;
    for(bool compute:{false,true}) {
      ++inputs.revision;
      render(moving_shadow,false,compute,501.f);
      shadow_snapshot();
      const float moon_length=std::sqrt(.928320f*.928320f+.042291f*.042291f+.369369f*.369369f);
      for(uint32_t channel=0;channel<3u;++channel)
        Require(std::abs(captured_shadow_sun[channel]-night_frame[205][channel+1u]/moon_length)<.00001f,
            "Night cloud shadows did not use the visible lunar direction");
      const auto lunar=probe(moving_shadow.Shared(),{0,0,0,1,-.928320f,.042291f,.369369f,0,0,0,1,10});
      Require(lunar[0]<.99f &&std::abs(lunar[15]-lunar[0])<.00001f,
          "Moon glow and ground moonlight did not share cloud attenuation");
      const auto unrelated=probe(moving_shadow.Shared(),{0,0,0,1,0,0,1,0,0,0,1,10});
      Require(unrelated[15]==1.f,"An unrelated emitter inherited the moon shadow map");
      ++cases;
    }
    inputs.frame=frame_buffer.object->GetGPUVirtualAddress();
    cases+=3;
    {
      // Ordinary time progression, including both horizon transitions. The
      // source is the visible sun rather than the active sun/moon light.
      for(float elevation:{-10.f,-8.f,-5.5f,-3.f,0.f,6.f,11.f,16.f,25.f}) {
        const float radians=elevation*.01745329252f;
        const float y=std::cos(radians),z=std::sin(radians);
        const auto state=probe(moving_shadow.Shared(),{0,y*10000.f,z*10000.f,1,0,y,z,1,0,0,1,10});
        const float expected=(elevation<=-8.f ||elevation>=16.f)?0.f
            :(elevation==-5.5f ||elevation==11.f)?.5f:1.f;
        Require(std::abs(state[19]-expected)<.02f &&std::abs(state[20]-state[19])<.00001f
            &&std::abs(state[21]-state[19])<.00001f &&state[22]==0.f,
            "Low-sun opening popped at an elevation boundary or cleared the opposite sky");
        ++cases;
      }
      const auto disabled=probe(moving_shadow.Shared(),{0,10000,700,1,0,1,.07f,0,0,0,1,10});
      const auto invalid=probe(moving_shadow.Shared(),{0,10000,700,1,0,0,0,1,0,0,1,10});
      Require(disabled[19]==0.f &&disabled[20]==0.f &&invalid[19]==0.f &&invalid[20]==0.f,
          "Disabled or missing solar direction cleared clouds");
      auto opening_at=[&](float azimuth,float elevation) {
        const float a=azimuth*.01745329252f,e=elevation*.01745329252f;
        return probe(moving_shadow.Shared(),{10000.f*std::sin(a)*std::cos(e),
            10000.f*std::cos(a)*std::cos(e),10000.f*std::sin(e),1,
            0,1,0,1,0,0,1,10});
      };
      for(float side:{-5.f,0.f,5.f}) {
        const auto core=opening_at(side,2.f);
        Require(core[20]>.999f&&core[21]>.999f,
            "Low-sun arch did not leave a clear solar core");
      }
      const auto horizontal=opening_at(17.f,0.f),vertical=opening_at(0.f,17.f);
      Require(horizontal[20]>.5f&&vertical[21]==0.f,
          "Low-sun arch lost its horizontal spread");
      const auto noisy_top=opening_at(0.f,10.f),noisy_side=opening_at(32.f,0.f);
      Require(noisy_top[20]==0.f&&noisy_top[21]>.1f
          &&noisy_side[20]==0.f&&noisy_side[21]>.1f,
          "Cloud formation noise did not vary the opening ceiling and shoulders");
      const auto shoulder_top=opening_at(24.f,11.f),shoulder_base=opening_at(24.f,-2.f);
      Require(shoulder_top[21]==0.f&&shoulder_base[21]>.3f,
          "Low-sun arch did not descend toward its shoulders");
      for(const auto angles:{std::array<float,2>{39.f,0.f},std::array<float,2>{0.f,25.f},
          std::array<float,2>{0.f,-20.f}}) {
        const auto outside=opening_at(angles[0],angles[1]);
        Require(outside[20]==0.f&&outside[21]==0.f,
            "Horizon opening removed unrelated cloud formations");
      }
      const auto left_edge=opening_at(28.99f,0.f),right_edge=opening_at(29.01f,0.f);
      Require(std::abs(left_edge[20]-right_edge[20])<.002f
          &&std::abs(left_edge[21]-right_edge[21])<.002f,
          "Horizon clearing has a hard lateral boundary");
      cases+=9;
      auto low_frame=frame;
      low_frame[204]={1,0,.99756405f,.06975647f}; // visible sun at four degrees
      low_frame[340][0]=4.f;
      const auto low_upload=gpu::Upload(device.Get(),low_frame.data(),sizeof(low_frame));
      inputs.frame=low_upload.object->GetGPUVirtualAddress();
      inputs.family=family_selection(1,"WT_Mid_Clouds");
      clouds::clear_low_sun=0.f;++inputs.revision;
      const auto closed=render(moving_shadow,false,false,501.f,false,true);
      const auto closed_shadow=probe(moving_shadow.Shared(),{0,0,0,1,0,0,0,0,0,0,1,10});
      clouds::clear_low_sun=1.f;++inputs.revision;
      const auto opened=render(moving_shadow,false,true,501.f,false,true);
      const auto opened_shadow=probe(moving_shadow.Shared(),{0,0,0,1,0,0,0,0,0,0,1,10});
      for(const auto clock_case:{std::array<float,2>{17.99f,0.f},std::array<float,2>{18.f,0.f},
          std::array<float,2>{18.125f,.5f},std::array<float,2>{18.25f,1.f},
          std::array<float,2>{0.f,1.f},std::array<float,2>{5.75f,1.f},
          std::array<float,2>{5.875f,.5f},std::array<float,2>{6.f,0.f},std::array<float,2>{12.f,0.f}}) {
        hartapfelfx::sky::emission::daytime=clock_case[0]/24.f;
        const auto parameters=moving_shadow.MakeParameters(inputs,1.f);
        Require(std::abs(parameters.scattering[2]-clock_case[1])<.0001f&&(parameters.identity[3]&8192u),
            "Cloud clearing missed its native 18:00..06:00 schedule or smooth fades");
        const auto scheduled=render(moving_shadow,false,true,501.f,false,true);
        const auto scheduled_shadow=probe(moving_shadow.Shared(),{0,0,0,1,0,0,0,0,0,0,1,10});
        if(clock_case[1]==0.f)Require(scheduled==closed&&std::abs(scheduled_shadow[0]-closed_shadow[0])<.00001f,
            "Clock-disabled clearing changed clouds or reused stale open terrain shadows");
        if(clock_case[1]==1.f)Require(scheduled==opened&&std::abs(scheduled_shadow[0]-opened_shadow[0])<.00001f,
            "Scheduled clearing did not match the visible cloud opening and terrain light");
        ++cases;
      }
      hartapfelfx::sky::emission::daytime=-1.f;
      uint32_t removed=0,retained=0,thin=0;
      for(uint32_t y=0;y<height;++y)for(uint32_t x=0;x<width;++x) {
        const size_t i=(size_t(y)*width+x)*4;
        Require(opened[i+1]<=opened[i]+.00001f,"Opening broke the conservative coarse/fine density bound");
        Require(opened[i]<=closed[i]+.00001f &&opened[i+1]<=closed[i+1]+.00001f,
            "Low-sun erosion added density to the original cloud");
        thin+=closed[i]>.01f && opened[i]>.0001f && opened[i]<closed[i]*.35f;
        if(std::abs(float(x)+.5f-width*.5f)<width/28.f) {
          Require(opened[i]==0.f &&opened[i+1]==0.f,"Low sun still intersects volumetric material");
          removed+=closed[i]>.001f;
        }
        if(x<width/10u ||x>=width*9u/10u) {
          Require(opened[i]==closed[i] &&opened[i+1]==closed[i+1],"Opening changed distant cloud formations");
          retained+=opened[i]>.001f;
        }
      }
      Require(removed>10u &&retained>10u &&closed_shadow[0]<.98f &&opened_shadow[0]>.999f,
          "Cloud shape and terrain sunlight did not share the same low-sun gap");
      Require(thin>removed/8u,"Low-sun clearing left too little thin material along the shoulder");
      for(const auto family:{uint64_t(0),family_selection(1,"WT_Rain_Storm"),
          family_selection(4,"WT_Light_Rain"),
          family_selection(2,"WT_Rain_Storm"),family_selection(11,"WT_Rain_Storm"),
          family_selection(11,"q704_Cloud_Rain")}) {
        inputs.family=family;clouds::clear_low_sun=0.f;++inputs.revision;
        const auto natural=render(moving_shadow,false,false,502.f,false,true);
        const auto natural_shadow=probe(moving_shadow.Shared(),{0,0,0,1,0,0,0,0,0,0,1,10});
        clouds::clear_low_sun=1.f;++inputs.revision;
        const auto protected_weather=render(moving_shadow,false,true,502.f,false,true);
        const auto protected_shadow=probe(moving_shadow.Shared(),{0,0,0,1,0,0,0,0,0,0,1,10});
        Require(natural==protected_weather &&natural_shadow[0]==protected_shadow[0],
            "Low-sun opening overrode rain/storms or unidentified weather");
        if(family)Require(protected_shadow[27]==1.f,"Native rain lost wet-weather classification");
        ++cases;
      }
      inputs.family=family_selection(1,"WT_Mid_Clouds");++inputs.revision;
      render(moving_shadow,false,false,6000.f);
      const auto fair=uint8_t(inputs.family),storm=uint8_t(family_selection(1,"WT_Rain_Storm"));
      inputs.family=uint64_t(fair)|(uint64_t(storm)<<8)|(uint64_t(std::bit_cast<uint32_t>(.5f))<<16);
      render(moving_shadow,false,true,6000.f+1.f/60.f);
      const float building=probe(moving_shadow.Shared(),{0,0,0,1,0,0,0,0,0,0,1,10})[27];
      inputs.family=family_selection(1,"WT_Mid_Clouds");
      render(moving_shadow,false,false,6000.f+2.f/60.f);
      const float receding=probe(moving_shadow.Shared(),{0,0,0,1,0,0,0,0,0,0,1,10})[27];
      Require(building>0.f &&building<.5f &&receding>0.f &&receding<building,
          "Interrupted severe-weather transition snapped the low-sun opening");
      std::cout<<"Weather-aware clearing: severe blend "<<building<<" -> "<<receding<<" on interruption\n";
      // Rain protection must arrive early in the native weather blend, even
      // when photo mode pauses the clock. Shape interpolation can stay slow.
      inputs.family=uint64_t(fair)|(uint64_t(storm)<<8)|(uint64_t(std::bit_cast<uint32_t>(.025f))<<16);
      render(moving_shadow,false,true,6000.f+2.f/60.f);
      Require(probe(moving_shadow.Shared(),{0,0,0,1,0,0,0,0,0,0,1,10})[27]==1.f,
          "Paused early rain retained the low-sun opening");
      inputs.family=family_selection(1,"WT_Mid_Clouds");
      render(moving_shadow,false,true,6000.f+2.f/60.f);
      Require(probe(moving_shadow.Shared(),{0,0,0,1,0,0,0,0,0,0,1,10})[27]==1.f,
          "Paused rain exit abruptly uncovered the sun");
      inputs.family=0;inputs.frame=frame_buffer.object->GetGPUVirtualAddress();++inputs.revision;
      std::cout<<"Low-sun shared density opening: core samples removed="<<removed
          <<" thin shoulder samples="<<thin<<" surrounding material="<<retained
          <<" terrain transmission "<<closed_shadow[0]<<" -> "<<opened_shadow[0]<<"\n";
      cases+=5;
    }
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
    {
      // Read the production weather texture through the existing GPU probe.
      // Cover all authored fakeShadow IDs, their pairings, graphics/compute
      // parity, and the ID exchange when the native transition completes.
      clear_inputs(0.f,0.f,1.f);
      std::vector<gpu::Resource> weather_frames;
      auto weather_sample=[&](clouds::View& view, const std::array<std::array<float,4>,352>& state,
                              float seconds, bool compute) {
        weather_frames.push_back(gpu::Upload(device.Get(),state.data(),sizeof(state)));
        inputs.frame=weather_frames.back().object->GetGPUVirtualAddress();
        return render(view,false,compute,seconds,false,true);
      };
      const float alpha=1.f-std::exp(-1.f/(60.f*.8f));
      for(uint32_t from=0;from<5u;++from)for(uint32_t to=0;to<5u;++to) {
        clouds::View graphics(&assets,width,height,clouds::quality,target_desc.Format);
        clouds::View compute(&assets,width,height,clouds::quality,target_desc.Format);
        auto state=frame;
        state[340][0]=1.f;
        state[67]={.37f,-.21f,0,0};
        state[68]={float(from),float(to),0,0};
        float expected_cover=from==0u?0.f:1.f;
        float expected_profile=from==4u?1.f:0.f;
        for(uint32_t tick=0;tick<=5u;++tick) {
          const float blend=std::min(float(tick)/4.f,1.f);
          state[66][3]=blend;
          if(tick==5u) { state[68]={float(to),float(from),0,0};state[66][3]=0.f; }
          const float authored_cover=(from==0u?0.f:1.f)*(1.f-blend)+(to==0u?0.f:1.f)*blend;
          const float authored_profile=(from==4u?1.f:0.f)*(1.f-blend)+(to==4u?1.f:0.f)*blend;
          if(tick!=0u) {
            expected_cover+=(authored_cover-expected_cover)*alpha;
            expected_profile+=(authored_profile-expected_profile)*alpha;
          }
          const auto a=weather_sample(graphics,state,100.f+tick/60.f,false);
          const auto b=weather_sample(compute,state,100.f+tick/60.f,true);
          if(std::abs(a[0]-expected_cover)>=.0001f ||std::abs(a[1]-expected_profile)>=.0001f)
            std::cerr<<"Weather "<<from<<"->"<<to<<" tick "<<tick<<" coverage/profile "<<a[0]<<"/"<<a[1]
                <<" expected "<<expected_cover<<"/"<<expected_profile<<"\n";
          Require(std::abs(a[0]-expected_cover)<.0001f &&std::abs(a[1]-expected_profile)<.0001f,
              "Native weather blend/profile popped or reinterpreted history at ID rollover");
          for(uint32_t channel=0;channel<4u;++channel)
            Require(std::abs(a[channel]-b[channel])<.00001f,"Graphics and compute weather disagree");
          Require(std::abs(a[2]-2.59f)<.0001f &&std::abs(a[6]+1.47f)<.0001f,
              "Weather identity changed the requested 35% native wind conversion");
        }
        cases+=1;
      }
      // Replacing a target halfway through a blend must fade from the actual
      // visible field, including its profile, even while paused or interrupted.
      clouds::View interrupted(&assets,width,height,clouds::quality,target_desc.Format);
      auto state=frame;state[340][0]=1.f;state[68]={0,4,0,0};state[66][3]=.5f;
      const auto first=weather_sample(interrupted,state,200.f,false);
      state[68]={0,0,0,0};state[66][3]=0.f;
      const auto paused_weather=weather_sample(interrupted,state,200.f,true);
      const auto changed_weather=weather_sample(interrupted,state,200.f+1.f/60.f,false);
      Require(std::abs(first[0]-.5f)<.0001f &&std::abs(first[1]-.5f)<.0001f,
          "Native partial weather blend is incorrect");
      Require(std::abs(paused_weather[0]-first[0])<.00001f &&std::abs(paused_weather[1]-first[1])<.00001f,
          "Paused weather advanced its fade");
      Require(std::abs(changed_weather[0]-.5f*(1.f-alpha))<.0001f
          &&std::abs(changed_weather[1]-.5f*(1.f-alpha))<.0001f,
          "Interrupted native transition did not fade from its visible coverage/profile");
      state[67]={0,0,0,0};
      const auto still=weather_sample(interrupted,state,201.1f,true);
      Require(still[2]==0.f &&still[6]==0.f,"Calm native weather gained artificial wind");
      cases+=2;
      std::cout<<"PASS 25 native weather-layer pairs: blend ramps, ID rollover, profile continuity, graphics/compute parity; interrupted/paused/calm weather\n";
      inputs.frame=frame_buffer.object->GetGPUVirtualAddress(); ++inputs.revision;
      clear_inputs(1.f,0.f);
    }
    {
      clouds::quality=1;
      clear_inputs(1.f,0.f);
      auto family_state=[&](const clouds::View& view) {
        begin();
        D3D12_RESOURCE_BARRIER barrier{};
        barrier.Type=D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
        barrier.Transition={view.Shared(),D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,gpu::TextureRead,D3D12_RESOURCE_STATE_COPY_SOURCE};
        cmd->ResourceBarrier(1,&barrier);
        cmd->CopyBufferRegion(feature_readback.object.Get(),0,view.Shared(),320,32);
        std::swap(barrier.Transition.StateBefore,barrier.Transition.StateAfter);
        cmd->ResourceBarrier(1,&barrier);submit();
        void* mapped=nullptr;gpu::Check(feature_readback.object->Map(0,nullptr,&mapped));
        std::array<float,8> result{};std::memcpy(result.data(),mapped,sizeof(result));
        feature_readback.object->Unmap(0,nullptr);
        return result;
      };
      for(uint32_t id=1;id<std::size(clouds::families::profiles);++id) {
        inputs.family=id|(uint64_t(id)<<8);
        clouds::View view(&assets,width,height,clouds::quality,target_desc.Format);
        const auto image=render(view,false,(id&1u)!=0u,500.f);
        const auto state=family_state(view);
        const auto& expected=clouds::families::profiles[id];
        for(uint32_t channel=0;channel<4u;++channel) {
          Require(state[channel]==expected.low[channel] &&state[channel+4]==expected.high[channel],
              "GPU family publication lost the native weather recipe");
        }
        uint32_t occupied=0;
        for(size_t pixel=0;pixel<image.size();pixel+=4)
          occupied+=std::abs(image[pixel]-background[0])>.001f;
        if(expected.low[0]>0.f ||expected.low[1]>0.f ||expected.high[0]>0.f)
          Require(occupied>10u,"An active native cloud-family recipe produced an empty sky");
        else
          for(size_t channel=0;channel<image.size();++channel)
            Require(std::abs(image[channel]-background[channel%4u])<.00001f,
                "A removed middle-sheet recipe still rendered clouds");
        ++cases;
      }
      const uint64_t light_family=family_selection(1,"WT_Light_Clouds");
      const uint64_t storm_family=family_selection(1,"WT_Rain_Storm");
      clouds::View transition(&assets,width,height,clouds::quality,target_desc.Format);
      inputs.family=storm_family;
      render(transition,false,false,1000.f);
      const auto storm=family_state(transition);
      inputs.family=light_family;
      render(transition,false,true,1000.f);
      Require(storm==family_state(transition),"Paused native time advanced cloud-family blending");
      render(transition,false,false,1000.f+1.f/60.f);
      const auto blended=family_state(transition);
      const auto& light_profile=clouds::families::profiles[uint8_t(light_family)];
      const float fade=1.f-std::exp(-(float(1000.f+1.f/60.f)-1000.f)/.8f);
      for(uint32_t channel=0;channel<8u;++channel) {
        const float target_value=channel<4u ? light_profile.low[channel] : light_profile.high[channel-4u];
        const float channel_fade=channel==7u?1.f-std::exp(-(float(1000.f+1.f/60.f)-1000.f)/.2f):fade;
        Require(std::abs(blended[channel]-(storm[channel]+(target_value-storm[channel])*channel_fade))<.00001f,
            "Interrupted family transition popped or used a different animation clock");
      }
      std::vector<float> settled_image;
      for(uint32_t tick=1;tick<=48u;++tick)
        settled_image=render(transition,false,(tick&1u)!=0u,1000.f+1.f/60.f+tick*.25f);
      const auto settled=family_state(transition);
      uint32_t light_pixels=0;
      for(size_t i=0;i<settled_image.size();i+=4)
        light_pixels+=std::abs(settled_image[i]-background[0])>.001f;
      Require(settled[0]==light_profile.low[0] &&settled[1]==light_profile.low[1]
          &&settled[0]>0.f &&light_pixels>10u,
          "Light-cloud weather faded the complete volumetric sky away");
      // Same GlobalCB address across fast travel and forward/backward meditation
      // jumps. Light-cloud material must survive with low-sun clearing On or Off.
      for(float clearing:{0.f,1.f}) {
        clouds::clear_low_sun=clearing;++inputs.revision;
        clouds::View travel(&assets,width,height,clouds::quality,target_desc.Format);
        clocks.clear();
        for(uint32_t tick=0;tick<6u;++tick) {
          const float seconds[]={100.f,50000.f,200.f,43200.f,101.f,60000.f};
          if(tick) {
            void* mapped=nullptr;gpu::Check(clocks.back().object->Map(0,nullptr,&mapped));
            std::memcpy(mapped,&seconds[tick],4);clocks.back().object->Unmap(0,nullptr);
          }
          auto travel_frame=frame;
          travel_frame[0][0]=tick%2u?20000.f:-30000.f;
          travel_frame[20][0]+=travel_frame[0][0]*travel_frame[20][3];
          travel_frame[204]=tick%2u?std::array<float,4>{1,0,.70710678f,.70710678f}
              :std::array<float,4>{1,0,.99756405f,.06975647f};
          travel_frame[286][0]=float(100u+tick);
          const auto travel_upload=gpu::Upload(device.Get(),travel_frame.data(),sizeof(travel_frame));
          inputs.frame=travel_upload.object->GetGPUVirtualAddress();
          const auto travelled=render(travel,false,(tick&1u)!=0u,seconds[tick],tick!=0u);
          const auto state=family_state(travel);
          uint32_t occupied=0;
          for(size_t i=0;i<travelled.size();i+=4)occupied+=std::abs(travelled[i]-background[0])>.001f;
          Require(state[0]==light_profile.low[0] &&state[1]==light_profile.low[1] &&occupied>10u,
              "Fast travel/meditation erased light clouds at dawn or noon");
          ++cases;
        }
      }
      clouds::clear_low_sun=1.f;++inputs.revision;
      for(uint32_t row:{204u,205u}) {
        clouds::View frozen(&assets,width,height,clouds::quality,target_desc.Format);
        clocks.clear();
        auto celestial_frame=frame;
        celestial_frame[204]={1,0,.99756405f,.06975647f};
        const auto before=gpu::Upload(device.Get(),celestial_frame.data(),sizeof(celestial_frame));
        inputs.frame=before.object->GetGPUVirtualAddress();
        render(frozen,false,false,777.f,true);
        // New scene target with the same clock address/value, camera, weather
        // and jitter: a celestial change is not a duplicate native card draw.
        celestial_frame[row]=row==204u?std::array<float,4>{1,0,.70710678f,.70710678f}
            :std::array<float,4>{1,.2f,-.7f,.68556546f};
        const auto after=gpu::Upload(device.Get(),celestial_frame.data(),sizeof(celestial_frame));
        inputs.frame=after.object->GetGPUVirtualAddress();
        const auto advanced_sky=render(frozen,false,true,777.f,true);
        uint32_t occupied=0;
        for(size_t i=0;i<advanced_sky.size();i+=4)occupied+=std::abs(advanced_sky[i]-background[0])>.001f;
        Require(occupied>10u,"Celestial-only meditation change was mistaken for an already rendered sky");
        ++cases;
      }
      inputs.frame=frame_buffer.object->GetGPUVirtualAddress();++inputs.revision;
      std::cout<<"Light-cloud transition retained "<<light_pixels
          <<" pixels; fast travel and same-address meditation jumps pass with clearing On/Off\n";
      ++cases;
      cases+=2;
      // Former high-sheet-only weather must remain completely clear in the
      // view and native receivers, including when fakeShadow is zero.
      clouds::View thin(&assets,width,height,clouds::quality,target_desc.Format);
      inputs.family=family_selection(1,"WT_Clear");
      clear_inputs(0.f,0.f);
      const auto thin_sky=render(thin,false,false,2000.f);
      for(size_t channel=0;channel<thin_sky.size();++channel)
        Require(std::abs(thin_sky[channel]-background[channel%4u])<.00001f,
            "Removed high sheet still contributed sky radiance or opacity");
      for(float x:{-2500.f,0.f,2500.f})for(float y:{-2500.f,0.f,2500.f})
        for(float altitude:{0.f,9000.f})
          Require(probe(thin.Shared(),{x,y,altitude,1,0,0,0,0,0,0,1,10})[0]>.999f,
              "Removed high sheet retained a native terrain shadow");
      clouds::coverage=0.f;++inputs.revision;
      const auto coverage_off=render(thin,false,true,2000.5f);
      for(size_t channel=0;channel<coverage_off.size();++channel)
        Require(std::abs(coverage_off[channel]-background[channel%4u])<.00001f,
            "Coverage zero retained a removed cloud sheet");
      clouds::coverage=1.f;++inputs.revision;
      ++cases;
      clear_inputs(0.f,.5f);++inputs.revision;
      const auto foreground=render(thin,false,true,2001.f);
      for(size_t channel=0;channel<foreground.size();++channel)
        Require(std::abs(foreground[channel]-background[channel%4u])<.00001f,
            "Removed cloud sheets drew through foreground terrain");
      cases+=3;
      inputs.family=0;inputs.frame=frame_buffer.object->GetGPUVirtualAddress();++inputs.revision;
      clear_inputs(1.f,0.f);
      std::cout<<"PASS all native family recipes, removed middle/high sheets, GPU publication, paused/interrupted blending, clear former-sheet sky, foreground clipping and terrain shadows\n";
    }
    clouds::quality = 1;
    {
      struct Control { float* value; float minimum, maximum; const char* name; };
      const Control controls[]={
          {&clouds::base_height,300,5000,"altitude"},{&clouds::roundness,-1,1,"roundness"},
          {&clouds::height_variation,0,2,"height variation"},{&clouds::coverage_breakup,0,2,"formation gaps"},
          {&clouds::billow_size,.25f,3,"billow size"},{&clouds::warp,0,3,"warp"},
          {&clouds::shear,0,3,"shear"},{&clouds::density_contrast,.25f,3,"density contrast"},
          {&clouds::erosion,0,3,"erosion"},{&clouds::wisp_bias,-1,1,"wisp balance"},
          {&clouds::base_relief,0,3,"base relief"},{&clouds::top_relief,0,3,"top relief"},
          {&clouds::edge_sharpness,0,4,"edge sharpness"},{&clouds::edge_roughness,0,3,"edge irregularity"},
          {&clouds::base_feather,.2f,4,"base feather"},{&clouds::top_feather,.25f,4,"top feather"},
          {&clouds::sunlight,0,3,"direct light"},{&clouds::skylight,0,3,"sky light"},
          {&clouds::self_shadow,0,3,"self shadow"},{&clouds::forward_scattering,0,.95f,"forward scattering"}};
      std::array<float,20> defaults{};
      for(uint32_t i=0;i<std::size(controls);++i) {
        defaults[i]=*controls[i].value;
        *controls[i].value=controls[i].minimum+(controls[i].maximum-controls[i].minimum)*(i+1.f)/21.f;
      }
      clouds::View authoring(&assets,width,height,clouds::quality,target_desc.Format);
      auto authoring_frame=frame;authoring_frame[340][0]=2.f;
      const auto authoring_upload=gpu::Upload(device.Get(),authoring_frame.data(),sizeof(authoring_frame));
      inputs.frame=authoring_upload.object->GetGPUVirtualAddress();++inputs.revision;
      const auto packed=render(authoring,false,false,6000.f,false,true);
      const auto snapshot=clouds::Authoring();std::array<float,20> expected{};
      std::memcpy(expected.data(),&snapshot,sizeof(snapshot));
      for(uint32_t i=0;i<expected.size();++i)
        Require(std::abs(packed[i*4]-expected[i])<.00001f,"Authoring GPU parameter layout differs from its CPU snapshot");
      for(uint32_t i=0;i<std::size(controls);++i)*controls[i].value=defaults[i];
      inputs.frame=frame_buffer.object->GetGPUVirtualAddress();++inputs.revision;
      ++cases;
      const auto reference=render(authoring,false,false,6001.f);
      for(uint32_t i=0;i<std::size(controls);++i) {
        inputs.family=0;
        double maximum_change=0;
        for(float endpoint:{controls[i].minimum,controls[i].maximum}) {
          *controls[i].value=endpoint;++inputs.revision;
          const auto image=render(authoring,false,false,6001.f);
          double difference=0;
          for(size_t pixel=0;pixel<image.size();pixel+=4)
            for(uint32_t channel=0;channel<3u;++channel)difference+=std::abs(image[pixel+channel]-reference[pixel+channel]);
          maximum_change=std::max(maximum_change,difference);
          ++cases;
        }
        if(maximum_change<=.01)std::cerr<<"No visible authoring response: "<<controls[i].name<<" difference="<<maximum_change<<'\n';
        Require(maximum_change>.01,"An exposed cloud control did not change its production image");
        *controls[i].value=defaults[i];++inputs.revision;
      }
      // Coupled endpoint edits must remain finite and retire through the same
      // resources/descriptor bank, not allocate a material for each slider.
      for(uint32_t corner=0;corner<2u;++corner) {
        for(uint32_t i=0;i<std::size(controls);++i)
          *controls[i].value=corner ? controls[i].maximum : controls[i].minimum;
        ++inputs.revision;render(authoring,false,false,6002.f);++cases;
      }
      for(uint32_t i=0;i<std::size(controls);++i)*controls[i].value=defaults[i];
      inputs.family=0;++inputs.revision;
      for(float altitude:{300.f,5000.f}) {
        clouds::base_height=altitude;++inputs.revision;
        render(authoring,false,false,6003.f);
        begin();
        D3D12_RESOURCE_BARRIER barrier{};barrier.Type=D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
        barrier.Transition={authoring.Shared(),D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,gpu::TextureRead,D3D12_RESOURCE_STATE_COPY_SOURCE};
        cmd->ResourceBarrier(1,&barrier);
        cmd->CopyBufferRegion(feature_readback.object.Get(),0,authoring.Shared(),288,4);
        std::swap(barrier.Transition.StateBefore,barrier.Transition.StateAfter);cmd->ResourceBarrier(1,&barrier);submit();
        void* mapped=nullptr;gpu::Check(feature_readback.object->Map(0,nullptr,&mapped));
        float stored_base=0;std::memcpy(&stored_base,mapped,4);feature_readback.object->Unmap(0,nullptr);
        Require(stored_base==altitude,"Native cloud receiver lost the authored base altitude");
        Require(probe(authoring.Shared(),{0,0,altitude+1200.f*clouds::thickness+100.f,1,0,0,0,0,0,0,1,10})[0]>.999f,
            "Authored cloud altitude shadowed a receiver above the layer");
        ++cases;
      }
      clouds::base_height=defaults[0];++inputs.revision;
      std::cout<<"PASS 20 authoring controls: GPU layout, both endpoints, visible response and coupled extremes\n";
    }
    {
      // A persistent GlobalCB address can hold a new native time next frame.
      // Address equality must not classify that frame as an already drawn one.
      clouds::View reused_clock(&assets,width,height,clouds::quality,target_desc.Format);
      render(reused_clock,false,false,3000.f);
      void* mapped=nullptr;gpu::Check(clocks.back().object->Map(0,nullptr,&mapped));
      const float next_time=3000.f+1.f/60.f;
      std::memcpy(mapped,&next_time,sizeof(next_time));clocks.back().object->Unmap(0,nullptr);
      const auto next=render(reused_clock,false,false,next_time,true);
      uint32_t occupied=0;
      for(size_t pixel=0;pixel<next.size();pixel+=4)
        occupied+=std::abs(next[pixel]-background[0])>.001f;
      Require(occupied>100u,"Reused native clock storage suppressed a new cloud frame");
      ++cases;
    }
    for(unsigned choice:{0u,1u,2u}) {
      clouds::quality_preset=float(choice);
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
      // With fixed camera, clock and stable ray phase, the history must settle
      // without flicker. Fresh clock allocations still force each render.
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
    }
    clouds::quality_preset=0.f;
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
    {
      // Production shared-buffer publication includes the immutable mip chain.
      const auto published=probe(moving_shadow.Shared(),{0,0,1,-1234,0,0,0,0,0,0,0,.0005f});
      Require(published[41]>.1f &&published[41]<2.f,"Moon mip chain was not published into production sky storage");
      std::vector<uint8_t> sky_data(512+sizeof(hartapfelfx::sky::moon_albedo));
      const std::array<uint32_t,4> header{std::bit_cast<uint32_t>(1.f),512u,std::bit_cast<uint32_t>(1.f),0x534B5931u};
      std::memcpy(sky_data.data()+304,header.data(),16);
      std::memcpy(sky_data.data()+512,hartapfelfx::sky::moon_albedo.data(),sizeof(hartapfelfx::sky::moon_albedo));
      auto sky_field=gpu::Upload(device.Get(),sky_data.data(),sky_data.size());
      auto sky_frame=frame;
      sky_frame[42]={};sky_frame[48]={};sky_frame[199]={1,.96f,.9f,0};
      sky_frame[203]={1,1,1,1};sky_frame[204]={120,0,0,1};sky_frame[205]={1,0,0,-1};
      auto sky_probe=[&](std::array<float,3> ray,float footprint=.0003f,std::array<float,4> material={},
                         std::array<float,4> clock={0,0,0,.75f},std::array<float,4> solar={},float glow_size=1.25f,uint32_t exposure=0) {
        const auto upload=gpu::Upload(device.Get(),sky_frame.data(),sizeof(sky_frame));
        return probe(sky_field.object.Get(),{ray[0],ray[1],ray[2],-1234,material[0],material[1],material[2],material[3],
            0,0,0,footprint,clock[0],clock[1],clock[2],clock[3],solar[0],solar[1],solar[2],solar[3],glow_size,std::bit_cast<float>(exposure),.0316336f,.124752f},
            upload.object->GetGPUVirtualAddress());
      };
      const auto center=sky_probe({0,0,1});
      const auto limb=sky_probe({.0285f,0,1});
      const auto exterior=sky_probe({.045f,0,1});
      Require(center[28]>limb[28]&&limb[28]>0.f&&exterior[28]==0.f,"Solar limb darkening/disc edge failed");
      Require(center[28]<1000.f&&center[28]>center[30],"Solar HDR radiance/extinction is invalid");
      Require(std::abs(center[52]-std::sin(.0316336f))<.00001f&&std::abs(center[53]-std::sin(.124752f))<.00001f,
          "Sun/Moon did not use the supplied native mesh size");
      Require(exterior[44]>0.f&&exterior[44]<center[44],"The Sun has no continuous glow outside its disc");
      Require(limb[44]>limb[28]*.2f,"Solar glow does not overlap the body/rim at visible radiance");
      Require(sky_probe({std::sin(.55f),0,std::cos(.55f)})[44]<center[44]*.0001f,
          "The outer solar halo became a large bright disc after exposure");
      const auto shoulder=sky_probe({std::sin(.08f),0,std::cos(.08f)});
      Require(center[63]==1.25f,"Sun Glow Size lost its wider default");
      const auto wider=sky_probe({std::sin(.16f),0,std::cos(.16f)},.0003f,{}, {0,0,0,.75f},{},2.5f);
      Require(std::abs(wider[44]/shoulder[44]-1.f)<.02f&&wider[52]==center[52],
          "Independent Sun Glow Size did not scale only the glow");
      sky_frame[206][3]=std::bit_cast<float>(0x80000000u|16384u);
      sky_frame[204][0]*=.25f; // native common builder's Sun Size exponent update
      Require(sky_probe({.045f,0,1})[28]>0.f,"Existing Sun Size did not resize the replacement");
      Require(std::abs(sky_probe({std::sin(.16f),0,std::cos(.16f)})[44]/shoulder[44]-1.f)<.02f,
          "Solar glow did not continue to follow Sun Size");
      sky_frame[206][3]=0.f;
      sky_frame[204][0]*=4.f;
      const auto solar_material=sky_probe({0,0,1},.0003f,{}, {0,0,0,.75f},{1,.25f,.5f,1});
      Require(std::abs(solar_material[28]/solar_material[29]-4.f)<.0001f&&solar_material[60]==1.f,
          "Sun did not preserve the normalized native HDR material colour");
      const auto native_halo=sky_probe({std::sin(.2f),0,std::cos(.2f)},.0003f,{}, {0,0,0,.75f},{1,.25f,.5f,1});
      Require(std::abs(native_halo[44]/native_halo[45]-1.f/.96f)<.0001f,
          "Solar atmosphere did not retain its separate native sky-glow palette");
      sky_frame[203][3]=2.f;
      const auto exposed_halo=sky_probe({std::sin(.2f),0,std::cos(.2f)},.0003f,{}, {0,0,0,.75f},{1,.25f,.5f,1});
      const auto reflection_halo=sky_probe({std::sin(.2f),0,std::cos(.2f)},.0003f,{}, {0,0,0,.75f},{1,.25f,.5f,1},1.25f,2u);
      Require(std::abs(exposed_halo[44]/native_halo[44]-2.f)<.0001f&&std::abs(reflection_halo[44]/native_halo[44]-1.f)<.0001f,
          "Solar halo lost the native main/reflection sky exposure branch");
      sky_frame[203][3]=1.f;sky_frame[206][0]=0.f;
      Require(sky_probe({std::sin(.2f),0,std::cos(.2f)})[44]<.000001f,"Solar sky glow ignored native weather strength zero");
      sky_frame[206][0]=1.f;
      const float elevation=.05f,horizontal=std::sqrt(1.f-elevation*elevation);
      sky_frame[204]={40,0,horizontal,elevation};
      Require(sky_probe({0,horizontal,elevation})[28]<center[28],"Low Sun lost its achromatic atmospheric attenuation");
      sky_frame[199]={27.3672714f,1.07121313f,.00014030948f,46.2497368f};
      const auto sunset=sky_probe({0,horizontal,elevation});
      const auto sunset_shoulder=sky_probe({std::sin(.08f),horizontal*std::cos(.08f),elevation*std::cos(.08f)});
      Require(std::abs(sunset[28]/sunset[29]-sky_frame[199][0]/sky_frame[199][1])<.001f,
          "Sunset received a second colour filter instead of the vanilla palette");
      Require(sunset_shoulder[44]/sunset[44]>shoulder[44]/center[44],"Native low-Sun exponent did not broaden the glow");
      sky_frame[204]={40,0,std::sqrt(1.f-.02f*.02f),-.02f};
      Require(sky_probe({0,1,.01f})[28]>0.f&&sky_probe({0,1,-.02f})[28]==0.f,"Solar upper limb vanished after centre-set");
      const auto twilight=sky_probe({0,1,.025f});
      Require(twilight[28]==0.f&&twilight[44]>0.f&&std::abs(twilight[44]/twilight[45]-sky_frame[199][0]/sky_frame[199][1])<.001f,
          "Afterglow disappeared abruptly or lost the native sunset colour");
      sky_frame[204]={120,0,std::sqrt(1.f-.08f*.08f),-.08f};
      Require(sky_probe({0,1,.01f})[44]==0.f,"Solar glow survived deep twilight");
      sky_frame[204]={120,0,0,-1};sky_frame[205]={1,0,.8f,.6f};
      const std::array<float,3> moon_ray{0,.8f,.6f};
      const auto full=sky_probe(moon_ray);
      Require(std::abs(full[32]/full[34]-sky_frame[277][0]/sky_frame[277][2])<.0001f,"Moon lost the vanilla palette");
      sky_frame[277][0]*=2.f;
      Require(std::abs(sky_probe(moon_ray)[32]/full[32]-2.f)<.0001f,"Moon lost linear native material intensity");
      sky_frame[277][0]*=.5f;
      const auto native_moon=sky_probe(moon_ray,.0003f,{14.2849865f,2.55107808f,.82191229f,1.f});
      Require(std::abs(native_moon[32]/full[32]-14.2849865f/sky_frame[277][0])<.0001f,"Standard Moon lost native material radiance");
      const auto toussaint_moon=sky_probe(moon_ray,.0003f,{.5f,.75f,1.25f,2.f});
      Require(std::abs(toussaint_moon[32]/full[32]-.5f)<.0001f&&std::abs(toussaint_moon[34]/full[34]-1.25f)<.0001f,
          "Toussaint Moon lost the native environment/material colour product");
      sky_frame[205]={1,0,0,1};sky_frame[38]={0,.6f,.8f,1};
      const auto centered=sky_probe({0,0,1}),up=sky_probe({0,.07f,1}),down=sky_probe({0,-.07f,1});
      Require(centered[50]>.999f&&std::abs(centered[49])<.0001f,"Sky retained the offset native Moon light");
      Require(centered[44]>0.f&&centered[44]>up[44]&&std::abs(up[44]-down[44])<.00001f,"Lunar glow is not centred/symmetric");
      sky_frame[205]={1,0,.8f,.6f};
      const auto quarter=sky_probe(moon_ray,.0003f,{}, {0,0,0,0});
      const auto crescent=sky_probe(moon_ray,.0003f,{}, {0,0,0,.25f});
      Require(full[32]>.01f&&full[32]>quarter[32]*20.f&&crescent[32]<full[32]*.01f,"Moon phase did not follow vanilla game time");
      Require(full[35]==1.f&&crescent[35]==1.f,"Dark Moon must still occult stars");
      const auto left=sky_probe({-.07f,.8f,.6f},.0003f,{}, {0,0,0,0});
      const auto right=sky_probe({.07f,.8f,.6f},.0003f,{}, {0,0,0,0});
      const auto waning_left=sky_probe({-.07f,.8f,.6f},.0003f,{}, {0,0,0,.5f});
      const auto waning_right=sky_probe({.07f,.8f,.6f},.0003f,{}, {0,0,0,.5f});
      Require(right[32]>waning_right[32]*10.f&&waning_left[32]>left[32]*10.f,"Waxing/waning did not reverse the crescent direction");
      const auto cycle=sky_probe(moon_ray,.0003f,{}, {0,29.530588f,0,.75f});
      const auto opposite=sky_probe(moon_ray,.0003f,{}, {0,14.765294f,0,.75f});
      Require(std::abs(cycle[32]/full[32]-1.f)<.001f&&opposite[32]<full[32]*.01f,"Native lunar month failed to cycle with fixed sky positions");
      const auto captured_phase=sky_probe(moon_ray,.0003f,{}, {0,873,0,.531537056f});
      const float native_phase=(873.f*.033863864839076996f+.531537056f)*6.28318530718f;
      Require(std::abs(captured_phase[56]-std::cos(native_phase))<.0001f&&std::abs(captured_phase[57]-std::sin(native_phase))<.0001f,
          "Phase direction differs from the original Moon pixel shader");
      sky_frame[37][3]=std::bit_cast<float>(0x4C000000u|(256u<<16u)|8192u);
      Require(std::abs(sky_probe(moon_ray)[32]/full[32]-256.f/511.f)<.001f,"Moon Brightness lost its existing scale");
      sky_frame[37][3]=0.f;sky_frame[205]={1,0,0,-1};
      // Pick one deterministic shell star on the CPU, then evaluate the real
      // GPU filter at multiple resolutions, near a cell edge, and in daylight.
      auto hash=[](uint32_t value) {value^=value>>16;value*=0x7FEB352Du;value^=value>>15;value*=0x846CA68Bu;return value^(value>>16);};
      std::array<float,3> star{};
      for(int z=30;z<96 &&star[2]==0.f;++z)for(int y=-96;y<96 &&star[2]==0.f;++y)for(int x=-96;x<96;++x) {
        const uint32_t h=hash(uint32_t(x)*73856093u^uint32_t(y)*19349663u^uint32_t(z)*83492791u);
        if((h&65535u)>=2294u)continue;
        const uint32_t a=hash(h),b=hash(a),c=hash(b);
        const std::array<float,3> p{float(x)+float(a&65535u)/65536.f,float(y)+float(b&65535u)/65536.f,float(z)+float(c&65535u)/65536.f};
        const float r=std::sqrt(p[0]*p[0]+p[1]*p[1]+p[2]*p[2]);
        if(std::abs(r-96.f)<.5f) {for(unsigned i=0;i<3;++i)star[i]=p[i]/r;break;}
      }
      Require(star[2]>0.f,"Star fixture not found");
      const auto bright=sky_probe(star,.0005f),filtered=sky_probe(star,.001f);
      Require(bright[36]>0.f &&std::abs(bright[36]/filtered[36]-4.f)<.02f,"Point-star filter failed flux normalization across resolutions");
      if(operation=="reference-stars"&&argc>3) {
        const auto reference_code=Read(argv[3]);
        const auto reference_pipeline=gpu::Compute(device.Get(),feature_root.Get(),{reference_code.data(),reference_code.size()});
        selected_feature=reference_pipeline.Get();
        const auto reference_star=sky_probe(star,.0005f);
        selected_feature=feature_pipeline.Get();
        Require(std::abs(bright[36]/reference_star[36]-8.f)<.001f,"Stellar base radiance is not eight times the previous production shader");
        std::cout<<"PASS actual GPU stellar base radiance ratio="<<bright[36]/reference_star[36]<<" at unchanged 100% brightness\n";
      }
      std::cout<<"Celestial probe Sun="<<center[28]<<", full Moon="<<full[32]<<", star="<<bright[36]<<"\n";
      sky_frame[204]={1,0,0,1};Require(sky_probe(star)[36]==0.f,"Stars remain visible in daylight");
      sky_frame[204]={1,0,0,-1};
      const float zero=0.f;std::memcpy(sky_data.data()+304,&zero,4);
      sky_field=gpu::Upload(device.Get(),sky_data.data(),sky_data.size());
      Require(sky_probe(star)[36]==0.f,"Star Brightness zero did not hide stars");
      const float one=1.f;std::memcpy(sky_data.data()+304,&one,4);
      sky_field=gpu::Upload(device.Get(),sky_data.data(),sky_data.size());
      sky_frame[42]={1,0,7000,1};sky_frame[44]={.1f,0,0,0};sky_frame[48]={0,0,1,0};
      sky_frame[189][3]=1;sky_frame[190]={0,0,1,-1};
      sky_frame[205]={1,0,0,1};
      const auto obscured=sky_probe({0,0,1});
      Require(obscured[40]==0.f &&obscured[32]==0.f,"Moon escaped an opaque native atmospheric veil");
      cases+=42;
      std::cout<<"PASS celestial shared asset, limb darkening, angular sizes, atmosphere, lunar phase/material, brightness, filtered stars and day/night gates\n";
    }
    {
      // Replay the production marcher with identical geometry, native power
      // and background. Only the cached emitter spectrum may change the RGB.
      namespace emission=hartapfelfx::sky::emission;
      clear_inputs(1.f,0.f);clouds::skylight=0.f;clouds::sunlight=1.f;
      clouds::density=1.f;clouds::clear_low_sun=0.f;
      auto colour_frame=frame;colour_frame[42]={};colour_frame[48]={};
      const float native_sun[3]={1.f,.1f,.01f},native_moon[3]={.05f,.2f,1.f};
      for(bool lunar:{false,true}) {
        colour_frame[204]={120,0,0,lunar?-1.f:1.f};
        colour_frame[205]={120,0,0,lunar?1.f:-1.f};
        const auto colour_upload=gpu::Upload(device.Get(),colour_frame.data(),sizeof(colour_frame));
        inputs.frame=colour_upload.object->GetGPUVirtualAddress();
        emission::enabled=false;++inputs.revision;
        clouds::View original(&assets,width,height,clouds::quality,target_desc.Format);
        const auto before=render(original,false,false,9000.f);
        emission::enabled=true;emission::ObservePrimary(native_sun);emission::ObserveMoon(native_moon,false);
        emission::ObserveFrame(colour_frame.data());++inputs.revision;
        clouds::View matched(&assets,width,height,clouds::quality,target_desc.Format);
        const auto after=render(matched,false,false,9000.f);
        double red=0,blue=0,luma_error=0;unsigned changed=0;
        for(size_t i=0;i<after.size();i+=4) {
          const double r=after[i]-before[i],g=after[i+1]-before[i+1],b=after[i+2]-before[i+2];
          red+=r;blue+=b;luma_error+=std::abs(.2126*r+.7152*g+.0722*b);
          changed+=std::abs(r)+std::abs(g)+std::abs(b)>.001;
        }
        Require(changed>100 &&(lunar?(blue>0&&red<0):(red>0&&blue<0)),
            "Clouds did not scatter the cached Sun/Moon colour");
        std::cout<<"Cloud colour "<<(lunar?"Moon":"Sun")<<" delta R/B="<<red<<"/"<<blue<<" luma error="<<luma_error<<"\n";
        Require(luma_error<.001*(std::abs(red)+std::abs(blue)),
            "Matching cloud light colour changed native luminance");
        ++cases;
      }
      colour_frame[204]={120,0,.9987492f,.05f};
      const auto evening_frame=gpu::Upload(device.Get(),colour_frame.data(),sizeof(colour_frame));
      inputs.frame=evening_frame.object->GetGPUVirtualAddress();
      emission::ObserveTime(19.f/24.f);emission::ObserveFrame(colour_frame.data());
      std::vector<float> native_blend;
      for(float blend:{0.f,1.f}) {
        emission::evening_blend=blend;
        auto world_light=light;emission::Apply(world_light[1].data());
        void* mapped=nullptr;gpu::Check(light_buffer.object->Map(0,nullptr,&mapped));
        std::memcpy(mapped,world_light.data(),sizeof(world_light));light_buffer.object->Unmap(0,nullptr);
        ++inputs.revision;
        clouds::View evening(&assets,width,height,clouds::quality,target_desc.Format);
        const auto image=render(evening,false,false,9001.f);
        if(blend==0.f)native_blend=image;
        else {
          double difference=0,energy=0;
          for(size_t i=0;i<image.size();i+=4u)for(unsigned c=0;c<3u;++c) {
            difference+=std::abs(image[i+c]-native_blend[i+c]);energy+=std::abs(image[i+c]);
          }
          Require(energy>1.f&&difference<energy*.001,
              "Evening world sunlight blend changed the independent cloud sunset colour");
          std::cout<<"Cloud colour independence across world sunlight endpoints: relative L1="<<difference/energy<<"\n";
        }
      }
      void* restored_light=nullptr;gpu::Check(light_buffer.object->Map(0,nullptr,&restored_light));
      std::memcpy(restored_light,light.data(),sizeof(light));light_buffer.object->Unmap(0,nullptr);
      emission::evening_blend=1.f;emission::daytime=-1.f;emission::enabled=false;
      ++cases;
      std::cout<<"PASS production cloud source-colour transport: solar/lunar hue and native luminance\n";
    }
    CloseHandle(event);
    std::cout << "PASS " << cases << " production cloud GPU cases, six custom qualities and four presets, packed-shadow alignment/projection/Off, HDR transport, motion signs/confidence/foreground, duplicate lists and native fallback\n";
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
