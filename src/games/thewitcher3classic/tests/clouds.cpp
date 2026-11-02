/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3d11.h>
#include <d3d11sdklayers.h>
#include <cassert>
#include <cmath>
#include <cstring>
#include <iostream>
#include <thread>
#include <vector>
#include "cloud_shader_baseline.hpp"
#include "../clouds/pipeline.hpp"
using Microsoft::WRL::ComPtr;
int main(int argc,char** argv) {
  const bool benchmark=argc>2 &&std::string_view(argv[2])=="--benchmark";
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> base;
  HRESULT creation=D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,D3D11_CREATE_DEVICE_DEBUG,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&base);
  if(creation==DXGI_ERROR_SDK_COMPONENT_MISSING)
    creation=D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
        nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&base);
  assert(SUCCEEDED(creation));
  ComPtr<ID3D11DeviceContext1> context;assert(SUCCEEDED(base.As(&context)));
#ifdef CLASSIC_CLOUD_PREVIEW
  constexpr UINT width=960,height=540;
#else
  constexpr UINT width=160,height=90;
#endif
  const auto startup_atmosphere=witcher3classic::clouds::Atmosphere(1.f);
  const auto startup_appearance=witcher3classic::clouds::Appearance();
  witcher3classic::clouds::coverage=witcher3classic::clouds::density=1.f;
  witcher3classic::clouds::size=witcher3classic::clouds::thickness=1.f;
  witcher3classic::clouds::detail=witcher3classic::clouds::detail_size=1.f;
  witcher3classic::clouds::base_softness=.5f;
  std::array<std::array<float,4>,269> frame{};
  // Ordinary perspective camera looking upward. Match Classic's independent
  // projection and reversed hardware-depth conventions rather than assuming
  // the native depth image can be multiplied by its standard inverse VP.
  frame[1]={1,0,0,0};frame[2]={0,-.4472136f,.8944272f,0};
  frame[3]={0,.8944272f,.4472136f,0};frame[4]={0,0,0,1};
  frame[13]={1,0,0,0};frame[14]={0,1,0,0};frame[15]={0,0,1.00004f,1};frame[16]={0,0,-.200008f,0};
  frame[17]={1,0,0,0};frame[18]={0,-.4472136f,.8944272f,0};
  frame[19]={0,0,0,-4.9998f};frame[20]={0,.8944272f,.4472136f,5};
  frame[22]={-1,1,.2f,5000};frame[23]={width,height,1.f/width,1.f/height};
  frame[66]={5,0,0,0};frame[68]={0,1,0,0};
  frame[194]={.1f,.2f,.4f,0};frame[195]=frame[196]=frame[197]=frame[194];
  frame[202]={1,1,1,0};frame[203]={1,0,1,1};frame[204]={1,0,-1,-1};frame[205]={1,0,0,0};
  if(argc>4 &&std::string_view(argv[2])=="--preview") {
    float altitude=std::stof(argv[4]);frame[0][2]=altitude;
    frame[19][2]-=altitude*4.9998f;frame[20][2]+=altitude*5.f;
    frame[4]={0,-altitude*.8944272f,-altitude*.4472136f,1};
  }
  if(argc>3 &&std::string_view(argv[2])=="--preview") {
    frame[202][1]=10.f; // daylight sky/sun ratio, comparable to captured native gain 9.53
    if(std::string_view(argv[1])=="--default-look") {
      witcher3classic::clouds::coverage=startup_appearance[0];witcher3classic::clouds::density=startup_appearance[1];
      witcher3classic::clouds::size=startup_appearance[2];witcher3classic::clouds::thickness=startup_appearance[3];
      witcher3classic::clouds::detail=startup_atmosphere[1];witcher3classic::clouds::detail_size=startup_atmosphere[2];
      witcher3classic::clouds::base_softness=startup_atmosphere[3];
    }
  }
  std::array<std::array<float,4>,3323> light{};light[0]={.1f,.4f,.91f,1};light[1]={30,20,10,0};
  D3D11_BUFFER_DESC bd{sizeof(frame),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
  D3D11_SUBRESOURCE_DATA initial{frame.data()};ComPtr<ID3D11Buffer> frame_buffer,light_buffer;
  assert(SUCCEEDED(device->CreateBuffer(&bd,&initial,&frame_buffer)));
  bd.ByteWidth=sizeof(light);initial.pSysMem=light.data();assert(SUCCEEDED(device->CreateBuffer(&bd,&initial,&light_buffer)));
  std::array<float,64> scene_clock{};ComPtr<ID3D11Buffer> clock_buffer;
  bd.ByteWidth=sizeof(scene_clock);initial.pSysMem=scene_clock.data();
  assert(SUCCEEDED(device->CreateBuffer(&bd,&initial,&clock_buffer)));
  D3D11_TEXTURE2D_DESC td{width,height,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,
      D3D11_BIND_RENDER_TARGET|D3D11_BIND_SHADER_RESOURCE};
  ComPtr<ID3D11Texture2D> output,readback;
  ComPtr<ID3D11RenderTargetView> target;
  assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&output)));
  assert(SUCCEEDED(device->CreateRenderTargetView(output.Get(),nullptr,&target)));
  td.Usage=D3D11_USAGE_STAGING;td.BindFlags=0;td.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
  assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&readback)));
  td={width,height,1,1,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
  std::vector<float> depth_data(width*height,0.f);initial={depth_data.data(),width*4};
  ComPtr<ID3D11Texture2D> depth,weather;ComPtr<ID3D11ShaderResourceView> depth_view,weather_view;
  assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&depth)));
  assert(SUCCEEDED(device->CreateShaderResourceView(depth.Get(),nullptr,&depth_view)));
  td={8,8,1,2,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
  std::array<float,64> weather_data{};weather_data.fill(1.f);
  D3D11_SUBRESOURCE_DATA layers[2]{{weather_data.data(),32},{weather_data.data(),32}};
  assert(SUCCEEDED(device->CreateTexture2D(&td,layers,&weather)));
  assert(SUCCEEDED(device->CreateShaderResourceView(weather.Get(),nullptr,&weather_view)));
  // Bind sentinel native state in both graphics stages. Earlier effects in this
  // mod exposed corruption from accidentally replacing native lighting b13.
  context->VSSetConstantBuffers(13,1,light_buffer.GetAddressOf());
  context->PSSetConstantBuffers(13,1,frame_buffer.GetAddressOf());
  context->PSSetConstantBuffers(0,1,clock_buffer.GetAddressOf());
  context->PSSetShaderResources(14,1,weather_view.GetAddressOf());
  context->CSSetShaderResources(7,1,weather_view.GetAddressOf());
  context->OMSetRenderTargets(1,target.GetAddressOf(),nullptr);
  const D3D11_VIEWPORT viewport{0,0,width,height,0,1};context->RSSetViewports(1,&viewport);
  witcher3classic::clouds::Pipeline pipeline;
  uint64_t serial=0;
  std::array<float,4> background{.2f,.3f,.4f,.75f};
  const witcher3classic::volumetrics::Pipeline* active_fog=nullptr;
  auto render=[&](float quality,bool invalidate=true) {
    if(invalidate)pipeline.Invalidate();
    context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
    context->UpdateSubresource(light_buffer.Get(),0,nullptr,light.data(),0,0);
    context->UpdateSubresource(clock_buffer.Get(),0,nullptr,scene_clock.data(),0,0);
    context->ClearRenderTargetView(target.Get(),background.data());
    assert(pipeline.Render(context.Get(),frame_buffer.Get(),light_buffer.Get(),weather_view.Get(),depth_view.Get(),
        target.Get(),width,height,++serial,quality,active_fog));
    ComPtr<ID3D11Buffer> restored;context->VSGetConstantBuffers(13,1,&restored);assert(restored==light_buffer);
    restored.Reset();context->PSGetConstantBuffers(13,1,&restored);assert(restored==frame_buffer);
    restored.Reset();context->PSGetConstantBuffers(0,1,&restored);assert(restored==clock_buffer);
    ComPtr<ID3D11ShaderResourceView> restored_view;context->PSGetShaderResources(14,1,&restored_view);assert(restored_view==weather_view);
    restored_view.Reset();context->CSGetShaderResources(7,1,&restored_view);assert(restored_view==weather_view);
    context->CopyResource(readback.Get(),output.Get());D3D11_MAPPED_SUBRESOURCE mapped{};
    assert(SUCCEEDED(context->Map(readback.Get(),0,D3D11_MAP_READ,0,&mapped)));
    std::vector<float> image(width*height*4);
    for(UINT y=0;y<height;++y)std::memcpy(image.data()+y*width*4,static_cast<const char*>(mapped.pData)+mapped.RowPitch*y,width*16);
    context->Unmap(readback.Get(),0);
    for(float value:image)assert(std::isfinite(value));
    for(UINT i=3;i<image.size();i+=4)assert(image[i]==.75f);
    return image;
  };
  auto image=render(1);
  if(argc>3 &&std::string_view(argv[2])=="--preview") {
    for(unsigned weather_case=0;weather_case<3;++weather_case)for(unsigned sun=0;sun<2;++sun)for(unsigned q:{1u,3u}) {
      weather_data.fill(std::array<float,3>{.45f,.7f,1.f}[weather_case]);
      for(UINT layer=0;layer<2;++layer)context->UpdateSubresource(weather.Get(),layer,nullptr,weather_data.data(),32,0);
      light[0]={.2f,sun?-.8f:.8f,.6f,1};serial=1023;
      auto pixels=render(float(q));
      std::ofstream dump(std::string(argv[3])+"-w"+std::to_string(weather_case)+"-s"+std::to_string(sun)+"-q"+std::to_string(q)+".bin",std::ios::binary);
      dump.write(reinterpret_cast<const char*>(pixels.data()),pixels.size()*sizeof(float));
    }
    return 0;
  }
  if(argc>3 &&std::string_view(argv[2])=="--dump-defaults") {
    std::ofstream dump(std::string(argv[3])+"-cloud.bin",std::ios::binary);
    dump.write(reinterpret_cast<const char*>(image.data()),image.size()*sizeof(float));
  }
  // A light-path optimization must leave the view extinction/silhouettes
  // unchanged. Zero incident radiance isolates those from internal lighting.
  if(argc>3 &&std::string_view(argv[2])=="--dump-lighting") {
    const auto saved_frame=frame;
    const auto saved_light=light;
    for(unsigned dark=0;dark<2;++dark) {
      if(dark) {
        light[1]={0,0,0,0};for(UINT i:{194u,195u,196u,197u,199u,200u})frame[i]={0,0,0,0};
      }
      for(unsigned q=0;q<6;++q) {
        serial=(q+1)*1024-1;const auto pixels=render(float(q));
        std::ofstream dump(std::string(argv[3])+"-q"+std::to_string(q)+(dark?"-extinction.bin":"-lighting.bin"),std::ios::binary);
        dump.write(reinterpret_cast<const char*>(pixels.data()),pixels.size()*sizeof(float));
      }
    }
    frame=saved_frame;light=saved_light;
  }
  UINT changed=0;float maximum=0;
  for(UINT i=0;i<image.size();i+=4){if(std::abs(image[i]-.2f)>.01f)++changed;maximum=std::max(maximum,image[i]);}
  assert(changed>100 &&maximum>1.f);
  // Empty weather must preserve the scene exactly at every quality, even after
  // an opaque/cloudy history. No dark clear-sky veil or stale cloud rectangles.
  // Isolate clear weather after a frame discontinuity; weather fades on
  // consecutive frames are covered by cloud_weather/cloud_shadows fixtures.
  serial+=1023;
  weather_data.fill(0.f);for(UINT layer=0;layer<2;++layer)context->UpdateSubresource(weather.Get(),layer,nullptr,weather_data.data(),32,0);
  for(float q:{0.f,1.f,2.f,3.f}) {
    image=render(q,false);
    for(UINT i=0;i<image.size();i+=4)assert(std::abs(image[i]-.2f)<1.e-5f &&std::abs(image[i+1]-.3f)<1.e-5f);
  }
  // Reversed-Z foreground geometry is never covered by the cloud composite.
  serial+=1023;
  weather_data.fill(1.f);for(UINT layer=0;layer<2;++layer)context->UpdateSubresource(weather.Get(),layer,nullptr,weather_data.data(),32,0);
  depth_data.assign(width*height,1.f);context->UpdateSubresource(depth.Get(),0,nullptr,depth_data.data(),width*4,0);
  image=render(1);for(UINT i=0;i<image.size();i+=4)assert(image[i]==.2f &&image[i+1]==.3f);
  depth_data.assign(width*height,0.f);context->UpdateSubresource(depth.Get(),0,nullptr,depth_data.data(),width*4,0);
  // Cloud motion augments the shared DLSS/FG inputs: remove jitter, include
  // wind, and preserve foreground motion and invalid-history responsiveness.
  ComPtr<ID3D11Texture2D> motion,responsive,motion_read;
  td={width,height,1,1,DXGI_FORMAT_R32G32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_UNORDERED_ACCESS};
  std::vector<float> sentinel(width*height*2,.125f);initial={sentinel.data(),width*8};
  assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&motion)));
  td.Format=DXGI_FORMAT_R32_FLOAT;assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&responsive)));
  td.Format=DXGI_FORMAT_R32G32_FLOAT;td.Usage=D3D11_USAGE_STAGING;td.BindFlags=0;td.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
  assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&motion_read)));
  render(1);render(1,false);
  auto motion_check=[&](bool wind) {
    assert(pipeline.ApplyMotion(context.Get(),depth_view.Get(),frame_buffer.Get(),motion.Get(),responsive.Get(),width,height,serial));
    context->CopyResource(motion_read.Get(),motion.Get());D3D11_MAPPED_SUBRESOURCE mapped{};
    assert(SUCCEEDED(context->Map(motion_read.Get(),0,D3D11_MAP_READ,0,&mapped)));
    UINT covered=0;
    for(UINT y=0;y<height;++y)for(UINT x=0;x<width;++x) {
      const auto* pixel=reinterpret_cast<const float*>(static_cast<const char*>(mapped.pData)+mapped.RowPitch*y)+x*2;
      assert(std::isfinite(pixel[0]) &&std::isfinite(pixel[1]));
      if(pixel[0]==.125f)continue;
      assert(std::abs(pixel[1])<1.e-5f);
      if(wind) {if(pixel[0]>1.e-5f &&pixel[0]<.02f)++covered;}
      else {assert(std::abs(pixel[0])<1.e-5f);++covered;}
    }
    context->Unmap(motion_read.Get(),0);assert(covered>100);
  };
  motion_check(false);
  context->UpdateSubresource(motion.Get(),0,nullptr,sentinel.data(),width*8,0);
  frame[67][0]+=.25f;render(1,false);motion_check(true);
  // Foreground pixels must keep the game's existing motion even if the cloud
  // texture behind them is opaque.
  context->UpdateSubresource(motion.Get(),0,nullptr,sentinel.data(),width*8,0);
  depth_data.assign(width*height,1.f);context->UpdateSubresource(depth.Get(),0,nullptr,depth_data.data(),width*4,0);
  assert(pipeline.ApplyMotion(context.Get(),depth_view.Get(),frame_buffer.Get(),motion.Get(),responsive.Get(),width,height,serial));
  context->CopyResource(motion_read.Get(),motion.Get());D3D11_MAPPED_SUBRESOURCE motion_map{};
  assert(SUCCEEDED(context->Map(motion_read.Get(),0,D3D11_MAP_READ,0,&motion_map)));
  for(UINT y=0;y<height;++y)for(UINT x=0;x<width*2;++x)
    assert(reinterpret_cast<const float*>(static_cast<const char*>(motion_map.pData)+motion_map.RowPitch*y)[x]==.125f);
  context->Unmap(motion_read.Get(),0);
  depth_data.assign(width*height,0.f);context->UpdateSubresource(depth.Get(),0,nullptr,depth_data.data(),width*4,0);
  // Clouds cannot emit light: with direct and environmental radiance zero they
  // only extinguish the background, including in HDR.
  light[1]={0,0,0,0};for(UINT i:{194u,195u,196u,197u,199u,200u})frame[i]={0,0,0,0};
  image=render(1);
  for(UINT i=0;i<image.size();i+=4)assert(image[i]<=.2001f &&image[i+1]<=.3001f &&image[i+2]<=.4001f);
  changed=0;for(UINT i=0;i<image.size();i+=4)if(image[i]<.1f)++changed;assert(changed>100);
#ifndef CLASSIC_CLOUD_BASELINE
  {
    // Evolution must follow the retained native clock, freeze when paused and
    // reject history across a clock jump without overwriting native b0.
    serial+=1023;
    weather_data.fill(.7f);for(UINT layer=0;layer<2;++layer)context->UpdateSubresource(weather.Get(),layer,nullptr,weather_data.data(),32,0);
    serial+=1023;auto paused=render(1);
    serial+=1023;assert(paused==render(1));
    scene_clock[0]=120.f;serial+=1023;auto evolved=render(1);float change=0;
    for(UINT i=0;i<evolved.size();i+=4)change+=std::abs(evolved[i]-paused[i]);assert(change>1.f);
    scene_clock[0]=240.f;render(1,false);
    assert(pipeline.ApplyMotion(context.Get(),depth_view.Get(),frame_buffer.Get(),motion.Get(),responsive.Get(),width,height,serial));
    D3D11_TEXTURE2D_DESC desc{};responsive->GetDesc(&desc);desc.Usage=D3D11_USAGE_STAGING;desc.BindFlags=0;desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
    ComPtr<ID3D11Texture2D> read;assert(SUCCEEDED(device->CreateTexture2D(&desc,nullptr,&read)));
    context->CopyResource(read.Get(),responsive.Get());D3D11_MAPPED_SUBRESOURCE mapped{};
    assert(SUCCEEDED(context->Map(read.Get(),0,D3D11_MAP_READ,0,&mapped)));UINT rejected=0;
    for(UINT y=0;y<height;++y)for(UINT x=0;x<width;++x)
      if(reinterpret_cast<const float*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch)[x]==1.f)++rejected;
    context->Unmap(read.Get(),0);assert(rejected>100);scene_clock[0]=0;
    std::cout<<"PASS native animation clock, paused stability, evolving density and clock-jump history rejection\n";
  }
  {
    using witcher3classic::clouds::coverage;
    using witcher3classic::clouds::density;
    using witcher3classic::clouds::size;
    using witcher3classic::clouds::thickness;
    for(float quality:{4.f,5.f,1.f}) {render(quality);render(quality,false);}
    // Independent sampling overrides must work through real GPU allocation,
    // history resets and motion preparation, including repeated up/down shifts.
    for(float resolution:{1.f,2.f,3.f,2.f,1.f,0.f})for(float step:{.5f,2.f,1.f}) {
      witcher3classic::clouds::resolution=resolution;witcher3classic::clouds::step_size=step;
      render(1,false);
      assert(pipeline.ApplyMotion(context.Get(),depth_view.Get(),frame_buffer.Get(),motion.Get(),responsive.Get(),width,height,serial));
    }
    witcher3classic::clouds::resolution=0.f;witcher3classic::clouds::step_size=1.f;
    // Hold the stochastic phase fixed for optical comparisons; changing both
    // the density and ray jitter would not be a valid monotonicity check.
    auto appearance_image=[&] {serial+=1023;return render(1,false);};
    weather_data.fill(.6f);for(UINT layer=0;layer<2;++layer)context->UpdateSubresource(weather.Get(),layer,nullptr,weather_data.data(),32,0);
    auto neutral=appearance_image();
    density=2.f;auto dense=appearance_image();float density_change=0;
    for(UINT i=0;i<dense.size();i+=4) {assert(dense[i]<=neutral[i]+.001f);density_change+=neutral[i]-dense[i];}
    assert(density_change>1.f);density=1.f;
    coverage=1.5f;auto covered=appearance_image();float coverage_change=0;
    for(UINT i=0;i<covered.size();i+=4) {assert(covered[i]<=neutral[i]+.001f);coverage_change+=neutral[i]-covered[i];}
    assert(coverage_change>1.f);coverage=1.f;
    size=2.f;auto broader=appearance_image();float size_change=0;
    for(UINT i=0;i<broader.size();i+=4)size_change+=std::abs(broader[i]-neutral[i]);
    assert(size_change>1.f);size=1.f;
    thickness=2.f;auto thicker=appearance_image();float thickness_change=0;
    for(UINT i=0;i<thicker.size();i+=4)thickness_change+=std::abs(thicker[i]-neutral[i]);
    assert(thickness_change>1.f);thickness=1.f;
    // Surface relief must remain visible when high optical density hides the
    // cloud interior. Compare extinction, not a lighting boost, at fixed jitter.
    density=4.f;witcher3classic::clouds::detail=0.f;
    auto smooth=appearance_image();witcher3classic::clouds::detail=1.f;
    auto textured=appearance_image();float relief_change=0.f;
    for(UINT i=0;i<smooth.size();i+=4)relief_change+=std::abs(smooth[i]-textured[i]);
    assert(relief_change>1.f);
    for(auto* style:{&witcher3classic::clouds::detail_size,&witcher3classic::clouds::base_softness}) {
      const float saved=*style;*style=.5f*saved;
      auto reshaped=appearance_image();float change=0.f;
      for(UINT i=0;i<reshaped.size();i+=4)change+=std::abs(reshaped[i]-textured[i]);
      assert(change>1.f);*style=saved;
    }
    // The rebased 100% must have usable controls on either side. Compare real
    // GPU extinction at fixed jitter, not only the UI's parsed numbers.
    witcher3classic::clouds::detail=4.f;witcher3classic::clouds::detail_size=.4f;
    auto baseline_detail=appearance_image();
    witcher3classic::clouds::detail=8.f;auto extra_detail=appearance_image();
    witcher3classic::clouds::detail=4.f;witcher3classic::clouds::detail_size=.2f;
    auto smaller_detail=appearance_image();
    float extra_change=0,smaller_change=0;
    for(UINT i=0;i<baseline_detail.size();i+=4) {
      extra_change+=std::abs(extra_detail[i]-baseline_detail[i]);
      smaller_change+=std::abs(smaller_detail[i]-baseline_detail[i]);
    }
    assert(extra_change>1.f &&smaller_change>1.f);
    witcher3classic::clouds::detail=witcher3classic::clouds::detail_size=1.f;
    density=1.f;
    for(UINT control=0;control<2;++control) {
      if(control==0)coverage=0.f;else {coverage=1.f;density=0.f;}
      auto clear=render(1,false);
      for(UINT i=0;i<clear.size();i+=4)assert(clear[i]==.2f &&clear[i+1]==.3f &&clear[i+2]==.4f);
    }
    coverage=density=1.f;
    weather_data.fill(0.f);for(UINT layer=0;layer<2;++layer)context->UpdateSubresource(weather.Get(),layer,nullptr,weather_data.data(),32,0);
    coverage=2.f;auto override=render(1,false);float cloud_amount=0;
    for(UINT i=0;i<override.size();i+=4)cloud_amount+=.2f-override[i];assert(cloud_amount>1.f);
    // Removing clouds must invalidate all sky history, including pixels whose
    // current opacity is now zero. Geometry motion was checked above.
    coverage=0.f;render(1,false);
    assert(pipeline.ApplyMotion(context.Get(),depth_view.Get(),frame_buffer.Get(),motion.Get(),responsive.Get(),width,height,serial));
    D3D11_TEXTURE2D_DESC rd{};responsive->GetDesc(&rd);rd.Usage=D3D11_USAGE_STAGING;rd.BindFlags=0;rd.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
    ComPtr<ID3D11Texture2D> response_read;assert(SUCCEEDED(device->CreateTexture2D(&rd,nullptr,&response_read)));
    context->CopyResource(response_read.Get(),responsive.Get());D3D11_MAPPED_SUBRESOURCE mapped{};
    assert(SUCCEEDED(context->Map(response_read.Get(),0,D3D11_MAP_READ,0,&mapped)));
    for(UINT y=0;y<height;++y)for(UINT x=0;x<width;++x)
      assert(reinterpret_cast<const float*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch)[x]==1.f);
    context->Unmap(response_read.Get(),0);coverage=1.f;
    std::cout<<"PASS appearance controls, both higher qualities, quality downshift, history rejection and sky responsiveness\n";
  }
#endif
#ifndef CLASSIC_CLOUD_BASELINE
  {
    // Production cloud composite + production Volume/Per-pixel fog. An opaque
    // cloud must retain all foreground scattering; clear gaps must not gain a
    // second copy. Isolate transport with a black cloud and an independently
    // generated HDR fog source, then compare against closed-form integration.
    const auto saved_frame=frame;const auto saved_light=light;
    frame[42]={0,0,1000,1};frame[43]={.001f,0,0,0};frame[44]={0,0,0,0};
    frame[48]={1,-1,1,0};frame[21]={0,0,1,1};
    light[0]={0,0,1,0};light[1]={0,0,0,0};light[7]={0,0,.5f,1};
    light[10]={1,2,3,4};light[11]={.5f,.5f,.5f,0};light[15][2]=4;
    light[17]={.05f,.05f,.05f,.05f};
    for(UINT i:{194u,195u,196u,197u,199u,200u})frame[i]={0,0,0,0};
    weather_data.fill(.7f);for(UINT layer=0;layer<2;++layer)context->UpdateSubresource(weather.Get(),layer,nullptr,weather_data.data(),32,0);
    serial+=1023;const auto black_cloud=render(1);
    std::array<float,64> shadow_depth{};shadow_depth.fill(1.f);
    std::array<D3D11_SUBRESOURCE_DATA,4> layers;
    for(auto& layer:layers)layer={shadow_depth.data(),32};
    D3D11_TEXTURE2D_DESC desc{8,8,1,4,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
    ComPtr<ID3D11Texture2D> shadow;ComPtr<ID3D11ShaderResourceView> shadow_view;
    assert(SUCCEEDED(device->CreateTexture2D(&desc,layers.data(),&shadow)));
    assert(SUCCEEDED(device->CreateShaderResourceView(shadow.Get(),nullptr,&shadow_view)));
    witcher3classic::volumetrics::Pipeline fog;
    witcher3classic::volumetrics::Parameters parameters{{17,9,96,1000},{1,.2f,1,0},{1,.1f,0,0},
        {1.f/width,1.f/height,1,0},{1,0,0,2}};
    // Sentinels prove the isolated binding leaves native draw bookkeeping and
    // reserved PS inputs intact, including on failed/stale-frame admission.
    context->PSSetShaderResources(116,1,weather_view.GetAddressOf());
    for(unsigned renderer:{0u,1u,2u})for(bool blocked:{false,true})for(float night_gain:{0.f,.35f,1.f}) {
      const uint32_t tag=0xdc000000u|(uint32_t(std::lround(night_gain*511.f))<<12)|2047u;
      std::memcpy(&frame[38][3],&tag,4);
      const bool per_pixel=renderer!=0;
      parameters.sky[2]=per_pixel?1.f:0.f;
      shadow_depth.fill(blocked?0.f:1.f);
      for(UINT layer=0;layer<4;++layer)context->UpdateSubresource(shadow.Get(),layer,nullptr,shadow_depth.data(),32,0);
      light[1]={2000,1000,500,0};
      context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
      context->UpdateSubresource(light_buffer.Get(),0,nullptr,light.data(),0,0);
      serial+=1023;
      assert(fog.Generate(context.Get(),frame_buffer.Get(),light_buffer.Get(),shadow_view.Get(),nullptr,nullptr,parameters,serial+1,nullptr,nullptr,{},renderer==2?depth_view.Get():nullptr));
      light[1]={0,0,0,0};active_fog=&fog;
      const auto composed=render(1);active_fog=nullptr;
      // Volume's smooth start removes one additional metre of homogeneous fog.
      const double optical_depth=.001*(1000-.2-(per_pixel?0:1));
      const double source=2000/(4*3.141592653589793)*std::exp(-1.)*(1-std::exp(-optical_depth));
      unsigned covered=0;
      for(UINT i=0;i<composed.size();i+=4) {
        const float opacity=std::clamp(1.f-black_cloud[i]/.2f,0.f,1.f);
        if(opacity>.1f)++covered;
        for(UINT c=0;c<3;++c) {
          const double expected=black_cloud[i+c]+(blocked?0:opacity*source*(std::lround(night_gain*511.f)/511.)/(1u<<c));
          // Source and extinction are stored independently in FP16, followed
          // by a second FP16 integrated field. Bound their combined rounding
          // relatively: a fixed .025 is less than one ULP at HDR radiance 37.
          assert(std::abs(composed[i+c]-expected)<.002f+.002f*std::abs(expected));
        }
      }
      assert(covered>100);
      ComPtr<ID3D11ShaderResourceView> retained;context->PSGetShaderResources(116,1,&retained);
      assert(retained==weather_view);
      // Stale fog cannot reappear after the generating frame or mode changes.
      active_fog=&fog;serial+=1023;const auto stale=render(1);active_fog=nullptr;
      for(UINT i=0;i<stale.size();++i)assert(std::abs(stale[i]-black_cloud[i])<.0001f);
    }
    ID3D11ShaderResourceView* empty=nullptr;context->PSSetShaderResources(116,1,&empty);
    frame=saved_frame;light=saved_light;
    std::cout<<"PASS cloud/fog HDR composition, opaque-cloud and clear-gap energy, terrain/object shadow inputs, both fog renderers, cached/uncached equivalence, night fog control, stale-frame rejection and isolated state restoration\n";
  }
#endif
  {
    // HDR sun-disc radiance must not leak through an optically opaque cloud.
    // The former 0.5% march cutoff left a plainly visible bright disc even at
    // high density. Keep clear-sky HDR and destination alpha unchanged.
    const auto saved_frame=frame;const auto saved_light=light;
    for(UINT i:{39u,40u,41u,44u,194u,195u,196u,197u,199u,200u})frame[i]={0,0,0,0};
    light[1]={0,0,0,0};background={50000,50000,50000,.75f};
    witcher3classic::clouds::coverage=2;witcher3classic::clouds::density=4;
    weather_data.fill(1);for(UINT layer=0;layer<2;++layer)context->UpdateSubresource(weather.Get(),layer,nullptr,weather_data.data(),32,0);
    serial+=1023;const auto occulted=render(3);UINT opaque=0;
    for(UINT y=0;y<height/4;++y)for(UINT x=width/4;x<width*3/4;++x)
      if(occulted[(y*width+x)*4]<.01f)++opaque;
    assert(opaque>20);
    witcher3classic::clouds::coverage=0;const auto clear=render(3);
    for(UINT i=0;i<clear.size();i+=4)assert(clear[i]==50000 &&clear[i+3]==.75f);
    witcher3classic::clouds::coverage=witcher3classic::clouds::density=1;
    background={.2f,.3f,.4f,.75f};frame=saved_frame;light=saved_light;
    std::cout<<"PASS opaque-cloud occultation of 50000 HDR background, clear-sky headroom and alpha preservation\n";
  }
  if(benchmark) {
    ComPtr<IDXGIDevice> dxgi_device;ComPtr<IDXGIAdapter> adapter;DXGI_ADAPTER_DESC adapter_desc{};
    if(SUCCEEDED(device.As(&dxgi_device)) &&SUCCEEDED(dxgi_device->GetAdapter(&adapter))
        &&SUCCEEDED(adapter->GetDesc(&adapter_desc)))std::wcout<<L"GPU: "<<adapter_desc.Description<<L'\n';
    // Isolated cost measurement. Deliberately separate from the correctness
    // fixture: never use wall time that includes staging reads or noise setup.
    constexpr UINT benchmark_width=3840,benchmark_height=2160;
    td={benchmark_width,benchmark_height,1,1,DXGI_FORMAT_R16G16B16A16_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_RENDER_TARGET};
    ComPtr<ID3D11Texture2D> benchmark_output,benchmark_depth;
    ComPtr<ID3D11RenderTargetView> benchmark_target;ComPtr<ID3D11ShaderResourceView> benchmark_depth_view;
    assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&benchmark_output)));
    assert(SUCCEEDED(device->CreateRenderTargetView(benchmark_output.Get(),nullptr,&benchmark_target)));
    td.Format=DXGI_FORMAT_R32_FLOAT;td.BindFlags=D3D11_BIND_SHADER_RESOURCE;
    depth_data.assign(benchmark_width*benchmark_height,0.f);
    for(UINT y=benchmark_height*3/4;y<benchmark_height;++y)
      std::fill_n(depth_data.data()+y*benchmark_width,benchmark_width,1.f);
    initial={depth_data.data(),benchmark_width*4};
    assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&benchmark_depth)));
    assert(SUCCEEDED(device->CreateShaderResourceView(benchmark_depth.Get(),nullptr,&benchmark_depth_view)));
    frame[17][0]=float(benchmark_width)/benchmark_height;frame[13][0]=1.f/frame[17][0];
    light[1]={30,20,10,0};frame[194]=frame[195]=frame[196]=frame[197]={.1f,.2f,.4f,0};
    context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
    context->UpdateSubresource(light_buffer.Get(),0,nullptr,light.data(),0,0);
    ComPtr<ID3D11Query> disjoint,start,end;
    D3D11_QUERY_DESC query{D3D11_QUERY_TIMESTAMP_DISJOINT};assert(SUCCEEDED(device->CreateQuery(&query,&disjoint)));
    query.Query=D3D11_QUERY_TIMESTAMP;
    assert(SUCCEEDED(device->CreateQuery(&query,&start)));assert(SUCCEEDED(device->CreateQuery(&query,&end)));
    for(float coverage:{0.f,.45f,1.f})for(float quality:{0.f,1.f,2.f,3.f,4.f,5.f}) {
      weather_data.fill(coverage);for(UINT layer=0;layer<2;++layer)context->UpdateSubresource(weather.Get(),layer,nullptr,weather_data.data(),32,0);
      for(UINT i=0;i<3;++i)assert(pipeline.Render(context.Get(),frame_buffer.Get(),light_buffer.Get(),weather_view.Get(),
          benchmark_depth_view.Get(),benchmark_target.Get(),benchmark_width,benchmark_height,++serial,quality));
      context->Begin(disjoint.Get());context->End(start.Get());
      for(UINT i=0;i<8;++i)assert(pipeline.Render(context.Get(),frame_buffer.Get(),light_buffer.Get(),weather_view.Get(),
          benchmark_depth_view.Get(),benchmark_target.Get(),benchmark_width,benchmark_height,++serial,quality));
      context->End(end.Get());context->End(disjoint.Get());
      D3D11_QUERY_DATA_TIMESTAMP_DISJOINT timing{};UINT64 first=0,last=0;
      while(context->GetData(disjoint.Get(),&timing,sizeof(timing),0)==S_FALSE)std::this_thread::yield();
      assert(!timing.Disjoint &&timing.Frequency);
      assert(context->GetData(start.Get(),&first,sizeof(first),0)==S_OK);
      assert(context->GetData(end.Get(),&last,sizeof(last),0)==S_OK);
      std::cout<<"GPU 3840x2160 75% unobscured sky: weather="<<coverage<<" quality="<<quality
          <<" cloud trace+resolve+composite="<<double(last-first)*1000./double(timing.Frequency)/8.<<" ms\n"<<std::flush;
    }
  }
  // Check the debug runtime's resource hazards as well as numeric output.
  ComPtr<ID3D11InfoQueue> queue;
  if(SUCCEEDED(device.As(&queue)))for(UINT64 i=0;i<queue->GetNumStoredMessages();++i) {
    SIZE_T bytes=0;queue->GetMessage(i,nullptr,&bytes);std::vector<char> storage(bytes);
    auto* message=reinterpret_cast<D3D11_MESSAGE*>(storage.data());queue->GetMessage(i,message,&bytes);
    if(message->Severity<=D3D11_MESSAGE_SEVERITY_WARNING) {
      std::cerr<<message->pDescription<<'\n';assert(false);
    }
  }
  std::cout<<"PASS cloud HDR, zero-light extinction, clear weather, reversed-Z occlusion, native b13/SRV/state restoration, wind-aware DLSS/FG motion, foreground motion isolation and qualities; HDR peak "<<maximum
      <<(queue ? "; D3D debug hazards checked" : "; D3D debug layer unavailable")<<'\n';
}
