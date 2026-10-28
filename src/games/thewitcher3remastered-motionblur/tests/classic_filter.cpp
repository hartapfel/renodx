/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
// Compare the production compute filter to the actual Classic optical pipeline.
#define main classic_optics_test_main
#include "../../thewitcher3classic/tests/optics.cpp"
#undef main
#include <d3dcompiler.h>
#include <bit>
#include "../motion_plan.hpp"

int main(int argc, char**) {
  std::cout << std::unitbuf;
  Fixture f;
  ComPtr<ID3D11DeviceContext> base;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr, argc > 1 ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP,
      nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &f.device, nullptr, &base)));
  assert(SUCCEEDED(base.As(&f.context)));
  std::array<float, 1076> frame{};
  frame[22 * 4] = frame[21 * 4] = 1;
  f.frame = f.Constants(frame.data(), sizeof(frame));
  optics::custom = true; optics::dof_mode = optics::bloom_mode = 0;
  ComPtr<ID3DBlob> blob, error;
  const D3D_SHADER_MACRO defines[] = {{"WITCHER_MOTION_TEST", "1"}, {nullptr, nullptr}};
  auto hr = D3DCompileFromFile(L"src/games/thewitcher3remastered-motionblur/effects/0xF3B10000.cs_6_6.hlsl",
      defines, D3D_COMPILE_STANDARD_FILE_INCLUDE, "main", "cs_5_0", D3DCOMPILE_OPTIMIZATION_LEVEL3, 0, &blob, &error);
  if (error) std::cerr << static_cast<const char*>(error->GetBufferPointer());
  assert(SUCCEEDED(hr));
  ComPtr<ID3D11ComputeShader> shader;
  assert(SUCCEEDED(f.device->CreateComputeShader(blob->GetBufferPointer(), blob->GetBufferSize(), nullptr, &shader)));
  D3D11_SAMPLER_DESC sd{}; sd.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
  sd.AddressU = sd.AddressV = sd.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP; sd.MaxLOD = D3D11_FLOAT32_MAX;
  ComPtr<ID3D11SamplerState> sampler;
  assert(SUCCEEDED(f.device->CreateSamplerState(&sd, &sampler)));
  double maximum = 0, total_error = 0; uint64_t pixels = 0; unsigned cases = 0; double tie_peak=0;
  for (unsigned width : {64u, 127u, 320u}) for (unsigned divisor : {1u, 2u})
  for (unsigned scenario = 0; scenario < 8; ++scenario) for (float fps : {30.f, 60.f, 120.f, 240.f}) {
    const unsigned height = width == 127 ? 73 : 96, mw = (width + divisor - 1) / divisor, mh = (height + divisor - 1) / divisor;
    const float strength = scenario == 0 ? 0.f : scenario == 7 ? 2.f : 1.f;
    const unsigned mode = scenario == 3 || scenario == 4 || scenario == 5 ? 1 : 0;
    const float raw_camera = scenario == 3 || scenario == 5 ? .025f * 60.f / fps : 0.f;
    const float camera = renodx::utils::float16::Decode(renodx::utils::float16::Encode(raw_camera));
    std::vector<float> color(width * height * 4), depth(mw * mh), vectors(mw * mh * 4), encoded(mw * mh * 4);
    for (unsigned y = 0; y < height; ++y) for (unsigned x = 0; x < width; ++x) {
      const unsigned i = (y * width + x) * 4;
      color[i] = x % 23 == 0 ? 16.f : .125f * (x % 7);
      color[i+1] = (x / 8 + y / 8) % 2 ? 2.f : -.25f;
      color[i+2] = x > width / 2 ? 8.f : -.125f; color[i+3] = 1.f;
    }
    for (unsigned y = 0; y < mh; ++y) for (unsigned x = 0; x < mw; ++x) {
      const unsigned i = (y * mw + x) * 4;
      depth[y*mw+x] = scenario == 6 && x > mw/2 ? .5f : .1f;
      float vx = scenario == 1 || scenario == 4 ? 0.f : .025f * 60.f / fps;
      float vy = scenario == 6 && x > mw/2 ? -.01f * 60.f / fps : 0.f;
      if (scenario == 5 && x > mw/2) vx += .003f * 60.f / fps;
      vx = renodx::utils::float16::Decode(renodx::utils::float16::Encode(vx));
      vy = renodx::utils::float16::Decode(renodx::utils::float16::Encode(vy));
      vectors[i] = encoded[i] = vx; vectors[i+1] = encoded[i+1] = vy;
      vectors[i+2] = vx - camera; vectors[i+3] = vy;
      const unsigned bits = std::bit_cast<unsigned>(depth[y*mw+x]);
      for (unsigned c = 0; c < 2; ++c) {
        const unsigned chunk = (bits >> (15*c)) & 0x7fff;
        encoded[i+2+c] = renodx::utils::float16::Decode(((chunk & 0x3fff)+0x400) | ((chunk & 0x4000)<<1));
      }
    }
    auto scene = f.Texture(width,height,DXGI_FORMAT_R32G32B32A32_FLOAT,color.data(),16);
    auto depths = f.Texture(mw,mh,DXGI_FORMAT_R32_FLOAT,depth.data(),4);
    auto motion = f.Texture(mw,mh,DXGI_FORMAT_R32G32B32A32_FLOAT,vectors.data(),16);
    auto native = f.Texture(mw,mh,DXGI_FORMAT_R32G32B32A32_FLOAT,encoded.data(),16);
    optics::motion_mode = float(mode); optics::motion_strength = strength;
    assert(f.pipeline.Capture(f.context.Get(),depths.Get(),motion.Get(),motion.Get(),depths.Get(),f.frame.Get(),mw,mh,0,0,1000.f/fps,true,++f.id));
    auto reference_view = f.pipeline.Run(f.context.Get(),scene.Get(),width,height,f.id);
    auto reference = reference_view ? f.Read(reference_view) : color;
    witcher::motion::Settings settings{};
    settings.interval=1.f/fps; settings.strength=strength; settings.mode=mode;
    settings.output_width=width; settings.output_height=height; settings.motion_width=mw; settings.motion_height=mh;
    const witcher::motion::Plan plan(settings);
    std::vector<float> scratch(plan.bytes/4);
    scratch[0]=scratch[2]=1; scratch[4]=float(mw); scratch[5]=float(mh);
    scratch[8]=scratch[13]=scratch[18]=scratch[23]=1;
    scratch[20]=2.f*camera;
    ComPtr<ID3D11Buffer> buffer;
    D3D11_BUFFER_DESC bd{UINT(plan.bytes),D3D11_USAGE_DEFAULT,D3D11_BIND_UNORDERED_ACCESS,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
    D3D11_SUBRESOURCE_DATA initial{scratch.data()};
    assert(SUCCEEDED(f.device->CreateBuffer(&bd,&initial,&buffer)));
    ComPtr<ID3D11UnorderedAccessView> scratch_uav,output_uav;
    assert(SUCCEEDED(f.device->CreateUnorderedAccessView(buffer.Get(),nullptr,&scratch_uav)));
    ComPtr<ID3D11Texture2D> output;
    D3D11_TEXTURE2D_DESC td{width,height,1,1,DXGI_FORMAT_R16G16B16A16_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_UNORDERED_ACCESS|D3D11_BIND_SHADER_RESOURCE};
    assert(SUCCEEDED(f.device->CreateTexture2D(&td,nullptr,&output)));
    assert(SUCCEEDED(f.device->CreateUnorderedAccessView(output.Get(),nullptr,&output_uav)));
    ComPtr<ID3D11ShaderResourceView> output_view;
    assert(SUCCEEDED(f.device->CreateShaderResourceView(output.Get(),nullptr,&output_view)));
    ID3D11ShaderResourceView* inputs[] = {scene.Get(),native.Get()};
    ID3D11UnorderedAccessView* uavs[] = {output_uav.Get(),scratch_uav.Get()};
    f.context->CSSetShaderResources(1,2,inputs); f.context->CSSetUnorderedAccessViews(0,2,uavs,nullptr);
    f.context->CSSetSamplers(0,1,sampler.GetAddressOf()); f.context->CSSetShader(shader.Get(),nullptr,0);
    for (const auto& stage : plan.stages) {
      auto cb=f.Constants(&stage,sizeof(stage)); f.context->CSSetConstantBuffers(0,1,cb.GetAddressOf());
      f.context->Dispatch((stage.target_width+7)/8,(stage.target_height+7)/8,1);
    }
    ID3D11UnorderedAccessView* empty[] = {nullptr,nullptr}; f.context->CSSetUnorderedAccessViews(0,2,empty,nullptr);
    const auto candidate=f.Read(output_view.Get());
    double case_max=0,case_error=0; double boundary_max=0; size_t max_i=0;
    for (size_t i=0;i<candidate.size();++i) {
      const double delta=std::abs(candidate[i]-reference[i]);
      // Native point sampling can choose the other side of an exact boundary
      // tie. Keep that narrow discontinuity in the mean; report its peak apart.
      if(scenario==5 && std::abs(int(i/4%width)-int(width/2))<=2) boundary_max=std::max(boundary_max,delta);
      else if(delta>case_max) {case_max=delta;max_i=i;}
      case_error+=delta;
    }
    tie_peak=std::max(tie_peak,boundary_max);
    maximum=std::max(maximum,case_max); total_error+=case_error; pixels+=width*height; ++cases;
    // Hardware texture filtering has implementation-specific subtexel precision;
    // the buffer implementation uses float interpolation. Bound both peak/mean.
    if(case_max>.10 || case_error/candidate.size()>(scenario==5?.025:.005)) {
      std::cerr<<"FAIL w="<<width<<" divisor="<<divisor<<" scenario="<<scenario<<" fps="<<fps<<" max="<<case_max<<" mean="<<case_error/candidate.size()<<" pixel="<<max_i/4%width<<","<<max_i/4/width<<" channel="<<max_i%4<<" values="<<candidate[max_i]<<","<<reference[max_i]<<"\n";return 1;
    }
  }
  std::cout<<"PASS "<<cases<<" Classic comparisons, "<<pixels<<" pixels; max="<<maximum<<" tie-boundary peak="<<tie_peak<<" mean="<<total_error/(pixels*4)<<"\n";
}
