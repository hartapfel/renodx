/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3d11sdklayers.h>
#include <cassert>
#include <cmath>
#include <iostream>
#include <chrono>
#include <thread>
#include <vector>
#include "../../../utils/float16.hpp"
#include "../volumetrics/pipeline.hpp"
using namespace witcher3classic;
using Microsoft::WRL::ComPtr;
struct Fixture {
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext1> context;
  ComPtr<ID3D11Buffer> frame,lighting;
  ComPtr<ID3D11ShaderResourceView> lit,shadowed,interiors;
  std::array<std::array<float,4>,269> f{};
  std::array<std::array<float,4>,3323> l{};
  volumetrics::Pipeline pipeline;
  volumetrics::Parameters p{{17,9,96,1000},{1,0,0,.5f},{1,.1f,0,0}};
  uint64_t id=0;
  ComPtr<ID3D11Buffer> Buffer(UINT size,const void* data) {
    D3D11_BUFFER_DESC desc{size,D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
    D3D11_SUBRESOURCE_DATA initial{data}; ComPtr<ID3D11Buffer> result;
    assert(SUCCEEDED(device->CreateBuffer(&desc,&initial,&result))); return result;
  }
  ComPtr<ID3D11ShaderResourceView> Shadows(float depth) {
    const std::vector<float> pixels(64,depth);
    std::array<D3D11_SUBRESOURCE_DATA,4> initial;
    for (auto& s:initial) s={pixels.data(),32,0};
    const D3D11_TEXTURE2D_DESC desc{8,8,1,4,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
    ComPtr<ID3D11Texture2D> texture; ComPtr<ID3D11ShaderResourceView> view;
    assert(SUCCEEDED(device->CreateTexture2D(&desc,initial.data(),&texture)));
    assert(SUCCEEDED(device->CreateShaderResourceView(texture.Get(),nullptr,&view))); return view;
  }
  std::vector<float> Run(bool occluded=false, bool center_only=false) {
    context->UpdateSubresource(frame.Get(),0,nullptr,f.data(),0,0);
    context->UpdateSubresource(lighting.Get(),0,nullptr,l.data(),0,0);
    context->CSSetConstantBuffers(4,1,frame.GetAddressOf());
    context->CSSetShaderResources(3,1,lit.GetAddressOf());
    assert(pipeline.Generate(context.Get(),frame.Get(),lighting.Get(),occluded?shadowed.Get():lit.Get(),nullptr,nullptr,p,++id,nullptr,interiors.Get()));
    ComPtr<ID3D11ShaderResourceView> restored_interior;
    context->CSGetShaderResources(3,1,&restored_interior); assert(restored_interior.Get()==lit.Get());
    ComPtr<ID3D11Buffer> restored;
    context->CSGetConstantBuffers(4,1,&restored); assert(restored.Get()==frame.Get());
    ComPtr<ID3D11Resource> resource; ComPtr<ID3D11Texture3D> texture,readback;
    pipeline.View()->GetResource(&resource); assert(SUCCEEDED(resource.As(&texture)));
    D3D11_TEXTURE3D_DESC desc; texture->GetDesc(&desc);
    assert(desc.Width==UINT(p.grid[0]) && desc.Height==UINT(p.grid[1]) && desc.Depth==UINT(p.grid[2])+1);
    const D3D11_BOX center{desc.Width/2,desc.Height/2,desc.Depth-1,desc.Width/2+1,desc.Height/2+1,desc.Depth};
    if(center_only)desc.Width=desc.Height=desc.Depth=1;
    desc.Usage=D3D11_USAGE_STAGING; desc.BindFlags=0; desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
    assert(SUCCEEDED(device->CreateTexture3D(&desc,nullptr,&readback)));
    if(center_only)context->CopySubresourceRegion(readback.Get(),0,0,0,0,texture.Get(),0,&center);
    else context->CopyResource(readback.Get(),texture.Get());
    D3D11_MAPPED_SUBRESOURCE mapped; assert(SUCCEEDED(context->Map(readback.Get(),0,D3D11_MAP_READ,0,&mapped)));
    std::vector<float> values(desc.Width*desc.Height*desc.Depth*4);
    for (UINT z=0; z<desc.Depth; ++z) for (UINT y=0;y<desc.Height;++y) for (UINT x=0;x<desc.Width*4;++x) {
      float value=renodx::utils::float16::Decode(reinterpret_cast<const uint16_t*>(static_cast<const uint8_t*>(mapped.pData)+z*mapped.DepthPitch+y*mapped.RowPitch)[x]);
      assert(std::isfinite(value)); values[((z*desc.Height+y)*desc.Width)*4+x]=value;
    }
    context->Unmap(readback.Get(),0); return values;
  }
  std::array<float,4> CenterEnd(const std::vector<float>& values) const {
    size_t offset=((size_t(p.grid[2])*size_t(p.grid[1])+size_t(p.grid[1])/2)*size_t(p.grid[0])+size_t(p.grid[0])/2)*4;
    return {values[offset],values[offset+1],values[offset+2],values[offset+3]};
  }
};
int main(int argc,char**) {
  Fixture a;
  ComPtr<ID3D11DeviceContext> base;
  HRESULT created=D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,nullptr,
      D3D11_CREATE_DEVICE_DEBUG,nullptr,0,D3D11_SDK_VERSION,&a.device,nullptr,&base);
  if (created==DXGI_ERROR_SDK_COMPONENT_MISSING) {
    std::cout<<"D3D11 debug layer unavailable; running numerical and state checks without it\n";
    created=D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,nullptr,
        0,nullptr,0,D3D11_SDK_VERSION,&a.device,nullptr,&base);
  }
  assert(SUCCEEDED(created));
  assert(SUCCEEDED(base.As(&a.context)));
  a.f[17]={1,0,0,0}; a.f[18]={0,1,0,0}; a.f[20]={0,0,1,1};
  a.f[21]={0,0,1,1}; a.f[22][2]=.2f; a.f[40]={2,4,8,0};
  a.f[42][1]=-10000; a.f[43]={.002f,.02f,.02f,0};
  a.f[42][3]=1.f; a.f[48]={1,-1,1,0}; // Identity authored opacity curve.
  a.l[0]={0,0,1,0}; a.l[1]={10,10,10,0}; a.l[7]={0,0,.5f,1};
  a.l[10]={1,2,3,4}; a.l[11]={.5f,.5f,.5f,0}; a.l[15][2]=4;
  a.l[16][1]=.125f; a.l[17]={.05f,.05f,.05f,.05f};
  a.frame=a.Buffer(sizeof(a.f),a.f.data()); a.lighting=a.Buffer(sizeof(a.l),a.l.data());
  a.lit=a.Shadows(1); a.shadowed=a.Shadows(0);
  auto result=a.CenterEnd(a.Run());
  // Independent closed form for constant fog, including the two-metre cubic
  // start fade (its integral is exactly one metre).
  const double expected=std::exp(-.002*(1000.-.2-1.));
  assert(std::abs(result[3]-expected)<.001);
  for (int c=0;c<3;++c) assert(std::abs(result[c]-(1.-expected)*a.f[40][c])<.01);
  // Actual half-float native interval input, in the top-left quarter of a
  // pooled texture. The stale remainder deliberately describes open air.
  // Expected optical lengths are analytic integrals of two-metre cubic ramps.
  ComPtr<ID3D11Texture2D> interior_texture;
  D3D11_TEXTURE2D_DESC interior_desc{8,8,1,1,DXGI_FORMAT_R16G16_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
  assert(SUCCEEDED(a.device->CreateTexture2D(&interior_desc,nullptr,&interior_texture)));
  assert(SUCCEEDED(a.device->CreateShaderResourceView(interior_texture.Get(),nullptr,&a.interiors)));
  a.p.sampling={1.f/8,1.f/8,0,0}; a.l[34][2]=128.f;
  std::vector<std::array<float,3>> intervals{
      {120000,10,989},     // Starts indoors, then exits into outdoor fog.
      {10,20,986.8f},      // Crosses an interior from outside, both boundary ramps.
      {120000,120000,998.8f}, // Native equal-boundary sentinel: no interior.
      {2000,3000,998.8f},  // Entry beyond the fog volume.
      {120000,2000,0}};    // Camera remains indoors throughout the fog volume.
  // Move the doorway through slice boundaries. The integrated optical length
  // must change continuously, rather than switching an entire cell's density.
  for (int i=0;i<=32;++i) intervals.push_back({120000,8.f+i*.125f,991.f-i*.125f});
  for (const auto& interval:intervals) {
    std::array<std::array<uint16_t,2>,64> pixels{};
    for (UINT y=0;y<4;++y) for (UINT x=0;x<4;++x)
      pixels[y*8+x]={renodx::utils::float16::Encode(interval[0]/128.f),renodx::utils::float16::Encode(interval[1]/128.f)};
    a.context->UpdateSubresource(interior_texture.Get(),0,nullptr,pixels.data(),8*4,0);
    auto volume=a.Run();
    // Check all rays, so incorrect full-allocation UVs cannot pass at center.
    for (size_t i=(volume.size()-size_t(a.p.grid[0]*a.p.grid[1])*4);i<volume.size();i+=4)
      assert(std::abs(volume[i+3]-std::exp(-.002*interval[2]))<.001);
    if (interval[0]>interval[1]) {
      // Every boundary before the exit must be an exact vacuum, including
      // scattering. Suppressing only final composite color cannot pass this.
      for (UINT z=0; z<=96 && .1*std::pow(10000.,double(z)/96.)<=interval[1];++z)
        for (UINT i=0;i<17*9;++i) {
          size_t offset=(size_t(z)*17*9+i)*4;
          assert(volume[offset]==0 && volume[offset+1]==0 && volume[offset+2]==0 && volume[offset+3]==1);
        }
    }
  }
  a.l[34][2]=0;
  auto invalid_scale=a.CenterEnd(a.Run());
  for(int c=0;c<4;++c) assert(invalid_scale[c]==result[c]);
  a.l[34][2]=128.f; a.interiors.Reset();
  auto absent=a.CenterEnd(a.Run());
  for(int c=0;c<4;++c) assert(absent[c]==result[c]);
  a.l[34][2]=0;
  a.p.medium[0]=0; auto vacuum=a.Run();
  for (size_t i=0;i<vacuum.size();i+=4) assert(vacuum[i]==0 && vacuum[i+1]==0 && vacuum[i+2]==0 && vacuum[i+3]==1);
  a.p.medium={1,100,1,.5f};
  auto lit=a.CenterEnd(a.Run()); auto shadow=a.CenterEnd(a.Run(true));
  // The fixture stays below the height transition along the entire light ray:
  // its incoming optical depth is density * 1000 m, independently of the
  // camera start fade. Check energy, not merely a brighter unshadowed sample.
  const double sun_phase=(1.-.5*.5)/(4.*3.141592653589793*std::pow(1.+.5*.5-2.*.5,1.5));
  const double expected_sun=10.*sun_phase*std::exp(-.002*1000.)*(1.-std::exp(-.002*(1000.-100.-1.)));
  for(int c=0;c<3;++c) assert(std::abs(lit[c]-shadow[c]-expected_sun)<.02);
  assert(lit[3]==shadow[3]);
  a.p.medium[2]=0; auto ambient=a.CenterEnd(a.Run());
  for (int c=0;c<4;++c) assert(std::abs(ambient[c]-shadow[c])<.001);
  assert(ambient[3]>result[3]);
  a.f[42][1]=0; auto height=a.CenterEnd(a.Run()); assert(height[3]>ambient[3]);
  a.p.options[0]=0; auto no_height=a.CenterEnd(a.Run()); assert(std::abs(no_height[3]-ambient[3])<.001);
  a.p.medium[0]=4; a.f[43][0]=100; auto dense=a.CenterEnd(a.Run()); assert(dense[3]==0);
  a.p.grid={13,7,64,500}; a.f[43][0]=.002f; a.p.medium={1,0,0,.5f}; a.Run();
  // Captured Toussaint weather: a large authored height offset must not turn
  // its reciprocal profile into an almost empty exponential atmosphere.
  const auto saved_frame=a.f;
  a.p.grid={17,9,96,1000};a.p.options[0]=1;
  a.f[0]={0,0,3.009872675f,0};a.f[20]={1,0,3.009872675f,1};
  a.f[42][1]=2185.518554688f;
  a.f[43]={.000253701f,.00018396393f,.00429215003f,0};
  auto toussaint=a.Run(false,true);
  const double toussaint_transmission=std::exp(-.000253701*(1000.-.2-1.)/
      (1.+(2185.518554688+3.009872675)*.5*(.00018396393+.00429215003)));
  assert(std::abs(toussaint[3]-toussaint_transmission)<.001);
  for(int c=0;c<3;++c)assert(std::abs(toussaint[c]-(1.-toussaint_transmission)*a.f[40][c])<.002);
  std::cout<<"PASS captured Toussaint height profile and reference scattering/transmittance\n";
  // The same sparse weather must keep accumulating past the old 1 km limit.
  // Read the published range too: forward sampling must use the same mapping
  // as both compute passes, otherwise a correct volume is sampled incorrectly.
  a.f[42][2]=16707.900390625f;
  auto distant=a.Run();
  const double local_extinction=.000253701/
      (1.+(2185.518554688+3.009872675)*.5*(.00018396393+.00429215003));
  const double distant_transmission=std::exp(-local_extinction*(a.f[42][2]-.2-1.));
  auto far_value=a.CenterEnd(distant);
  assert(std::abs(far_value[3]-distant_transmission)<.001);
  for(int c=0;c<3;++c)assert(std::abs(far_value[c]-(1.-distant_transmission)*a.f[40][c])<.005);
  const double near_slice=std::log(100./a.p.options[1])/std::log(a.f[42][2]/a.p.options[1])*a.p.grid[2];
  const size_t lower=size_t(near_slice),center=4*(size_t(a.p.grid[1])/2*size_t(a.p.grid[0])+size_t(a.p.grid[0])/2);
  const size_t stride=size_t(a.p.grid[0]*a.p.grid[1])*4;
  const double near_transmission=std::lerp(double(distant[lower*stride+center+3]),
      double(distant[(lower+1)*stride+center+3]),near_slice-lower);
  assert(std::abs(near_transmission-std::exp(-local_extinction*(100.-.2-1.)))<.001);
  ComPtr<ID3D11Resource> parameter_resource;
  a.pipeline.ParametersView()->GetResource(&parameter_resource);
  const D3D11_BUFFER_DESC parameter_desc{sizeof(a.p),D3D11_USAGE_STAGING,0,D3D11_CPU_ACCESS_READ};
  ComPtr<ID3D11Buffer> parameter_readback;
  assert(SUCCEEDED(a.device->CreateBuffer(&parameter_desc,nullptr,&parameter_readback)));
  a.context->CopyResource(parameter_readback.Get(),parameter_resource.Get());
  D3D11_MAPPED_SUBRESOURCE parameter_map{};
  assert(SUCCEEDED(a.context->Map(parameter_readback.Get(),0,D3D11_MAP_READ,0,&parameter_map)));
  assert(static_cast<const float*>(parameter_map.pData)[3]==a.f[42][2]);
  a.context->Unmap(parameter_readback.Get(),0);
  // An interior beyond the old cutoff still removes exactly its optical length.
  std::array<std::array<uint16_t,2>,64> far_interiors;
  far_interiors.fill({renodx::utils::float16::Encode(1000.f/128.f),renodx::utils::float16::Encode(4000.f/128.f)});
  a.context->UpdateSubresource(interior_texture.Get(),0,nullptr,far_interiors.data(),8*4,0);
  assert(SUCCEEDED(a.device->CreateShaderResourceView(interior_texture.Get(),nullptr,&a.interiors)));
  a.l[34][2]=128.f;
  auto far_interior=a.Run(false,true);
  assert(std::abs(far_interior[3]-std::exp(-local_extinction*(a.f[42][2]-.2-1.-3002.)))<.001);
  a.interiors.Reset();a.l[34][2]=0;
  std::cout<<"PASS weather-distance haze, near-field preservation, published sampling range and distant interior exclusion\n";
  // Two live weather captures exercise opposite sides of exponent 1: the
  // former lost fog; the latter added too much. Horizontal rays provide an
  // independent homogeneous solution at EVERY boundary and fade transition.
  for(const auto& weather:std::array<std::array<float,8>,2>{{
      {48.2502822876f,-39.4299964905f,.000422194716521f,.507544338703f,7.15733957291f,.00529972510412f,.02335376665f,.023230597377f},
      {2.00425338745f,-39.4300003052f,.000992203480564f,1.2030134201f,1.f,.0151364393532f,.0233537703753f,.0232305992395f}}}) {
    a.f[0]={0,0,weather[0],0};a.f[20]={1,0,weather[0],1};
    a.f[42]={1,weather[1],16707.900390625f,weather[3]};
    a.f[43]={weather[2],weather[6],weather[7],0};
    a.f[48]={1,weather[4],weather[5],0};
    a.p.medium={1,0,0,.5f};
    auto velen=a.Run();
    const double velen_sigma=double(a.f[43][0])/(1.+std::max(0.,double(a.f[0][2])+a.f[42][1])*.5*(double(a.f[43][1])+a.f[43][2]));
    const size_t velen_center=(size_t(a.p.grid[1])/2*size_t(a.p.grid[0])+size_t(a.p.grid[0])/2)*4;
    float last_opacity=0;
    for(size_t z=0;z<=size_t(a.p.grid[2]);++z) {
      const double distance=double(a.p.options[1])*std::pow(double(a.f[42][2])/a.p.options[1],double(z)/a.p.grid[2]);
      const double length=std::max(0.,distance-a.f[22][2]);
      // Integral of the two-metre smoothstep start ramp, then constant density.
      const double t=std::clamp(length/2.,0.,1.);
      const double optical_length=std::max(0.,length-2.)+2.*t*t*t*(1.-.5*t);
      const double expected_opacity=std::pow(-std::expm1(-velen_sigma*optical_length),double(a.f[42][3]))
          *std::clamp((length-a.f[48][1])*a.f[48][2],0.,1.);
      const size_t offset=z*stride+velen_center;
      const float opacity=1.f-velen[offset+3];
      if(std::abs(opacity-expected_opacity)>=.002)
        std::cerr<<"Weather exponent="<<weather[3]<<" boundary="<<z<<" distance="<<distance<<" opacity="<<opacity<<" expected="<<expected_opacity<<'\n';
      assert(std::abs(opacity-expected_opacity)<.002);
      assert(opacity>=last_opacity);last_opacity=opacity;
      for(int c=0;c<3;++c)assert(std::abs(velen[offset+c]-expected_opacity*a.f[40][c])<.02);
    }
    a.p.medium[2]=1;
    auto velen_lit=a.Run(false,true),velen_shadow=a.Run(true,true);
    const auto velen_ambient=a.CenterEnd(velen);
    for(int c=0;c<3;++c) {
      assert(std::abs(velen_shadow[c]-velen_ambient[c])<.002);
      assert(velen_lit[c]>velen_shadow[c]);
    }
    assert(velen_lit[3]==velen_shadow[3] && velen_lit[3]==velen_ambient[3]);
    a.p.medium[2]=0;
    a.p.medium[0]=0;
    auto velen_vacuum=a.Run();
    for(size_t i=0;i<velen_vacuum.size();i+=4)
      assert(velen_vacuum[i]==0 && velen_vacuum[i+1]==0 && velen_vacuum[i+2]==0 && velen_vacuum[i+3]==1);
    // Advancing the weather fade through an actual interior must not create
    // extinction or scattering in that empty segment of the volume.
    a.p.medium[0]=1;a.l[34][2]=128.f;
    std::array<std::array<uint16_t,2>,64> velen_interiors;
    velen_interiors.fill({renodx::utils::float16::Encode(20.f/128.f),renodx::utils::float16::Encode(100.f/128.f)});
    a.context->UpdateSubresource(interior_texture.Get(),0,nullptr,velen_interiors.data(),8*4,0);
    assert(SUCCEEDED(a.device->CreateShaderResourceView(interior_texture.Get(),nullptr,&a.interiors)));
    auto velen_interior=a.Run();size_t empty_segments=0;
    for(size_t z=1;z<=size_t(a.p.grid[2]);++z) {
      const double begin=double(a.p.options[1])*std::pow(double(a.f[42][2])/a.p.options[1],double(z-1)/a.p.grid[2]);
      const double end=double(a.p.options[1])*std::pow(double(a.f[42][2])/a.p.options[1],double(z)/a.p.grid[2]);
      if(begin>=20 && end<=100) {
        ++empty_segments;
        for(int c=0;c<4;++c)assert(velen_interior[z*stride+velen_center+c]==velen_interior[(z-1)*stride+velen_center+c]);
      }
    }
    assert(empty_segments>2);a.interiors.Reset();a.l[34][2]=0;
  }
  std::cout<<"PASS both captured weather opacity exponents/distance fades, all integration boundaries, radiance consistency and exact vacuum\n";
  a.f=saved_frame;a.p.options[0]=0;
  a.p.medium={1,0,0,.5f};
  // Exercise actual quality allocations and up/down resize, reading only the
  // last center cell so Ultra does not allocate a second full CPU/GPU volume.
  for(float quality:{1.f,4.f,2.f,3.f,1.f}) {
    a.p.grid=volumetrics::VolumeGrid(quality,9.f/16.f);
    auto value=a.Run(false,true);
    assert(std::abs(value[3]-expected)<.001);
    for(int c=0;c<3;++c)assert(std::abs(value[c]-(1.-expected)*a.f[40][c])<.01);
  }
  assert(volumetrics::VolumeGrid(0,9.f/16.f)==volumetrics::VolumeGrid(1,9.f/16.f));
  assert(volumetrics::VolumeGrid(5,9.f/16.f)==volumetrics::VolumeGrid(4,9.f/16.f));
  assert(volumetrics::VolumeGrid(4,4.f)[1]==512.f);
  a.p.grid={17,9,96,1000};a.p.medium={1,100,1,.5f};a.f[42][1]=-10000;
  for(float quality:{1.f,2.f,3.f,4.f}) {
    a.p.sampling[2]=quality;
    auto light=a.Run(false,true),dark=a.Run(true,true);
    assert(light[3]==dark[3]);
    for(int c=0;c<3;++c)assert(std::abs(light[c]-dark[c]-expected_sun)<.02);
  }
  a.l[11][0]=.525f; // The .025-capped filter starts at the texture's .5 edge.
  std::array<float,4096> edge{};
  for(UINT y=0;y<64;++y)for(UINT x=32;x<64;++x)edge[y*64+x]=1.f;
  std::array<D3D11_SUBRESOURCE_DATA,4> edge_data;
  for(auto& data:edge_data)data={edge.data(),256,0};
  const D3D11_TEXTURE2D_DESC edge_desc{64,64,1,4,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
  ComPtr<ID3D11Texture2D> edge_texture;
  assert(SUCCEEDED(a.device->CreateTexture2D(&edge_desc,edge_data.data(),&edge_texture)));
  a.lit.Reset();assert(SUCCEEDED(a.device->CreateShaderResourceView(edge_texture.Get(),nullptr,&a.lit)));
  for(int quality=1;quality<=4;++quality) {
    a.p.sampling[2]=float(quality);
    auto light=a.Run(false,true),dark=a.Run(true,true);
    // The first column lies halfway across the PCF edge; all later columns
    // are lit. The exact integral of each 2/3/4/5-column rule is 1-.5/side.
    for(int c=0;c<3;++c)assert(std::abs(light[c]-dark[c]-expected_sun*(1.-.5/(quality+1)))<.02);
  }
  std::cout<<"PASS: all fog quality allocations, up/down resize, aspect/quality bounds, and shadow-sample energy preservation\n";
  // Private bindings are restored and stale-frame use is rejected.
  a.context->PSSetShaderResources(116,1,a.lit.GetAddressOf());
  assert(!a.pipeline.Bind(a.context.Get(),false,a.id+1));
  assert(a.pipeline.Bind(a.context.Get(),false,a.id));
  a.pipeline.Restore(a.context.Get());
  ComPtr<ID3D11ShaderResourceView> restored; a.context->PSGetShaderResources(116,1,&restored); assert(restored.Get()==a.lit.Get());
  ComPtr<ID3D11InfoQueue> queue; a.device.As(&queue);
  for (UINT64 i=0;queue && i<queue->GetNumStoredMessages();++i) {
    SIZE_T size=0; queue->GetMessage(i,nullptr,&size); std::vector<uint8_t> bytes(size);
    auto* message=reinterpret_cast<D3D11_MESSAGE*>(bytes.data()); queue->GetMessage(i,message,&size);
    if (message->Severity<=D3D11_MESSAGE_SEVERITY_WARNING) { std::cerr<<message->pDescription<<'\n'; assert(false); }
  }
  std::cout<<"PASS: interior vacuum, entry/exit fades, moving doorway optical length, pooled interval bounds, missing/invalid interior fallback; Beer-Lambert/reference radiance, shadow visibility, start distance, height falloff, odd grid resize, context and binding restoration\n";
  if (argc>2) {
    // Bounded production-grid microbenchmark, not an in-game FPS estimate.
    a.p.grid={160,90,96,1000}; a.p.medium={1,0,1,.5f}; a.p.sampling={1.f/2560,1.f/1440,0,0};
    a.Run();
    ComPtr<ID3D11Query> disjoint,begin,end;
    D3D11_QUERY_DESC q{D3D11_QUERY_TIMESTAMP_DISJOINT,0};
    assert(SUCCEEDED(a.device->CreateQuery(&q,&disjoint)));
    q.Query=D3D11_QUERY_TIMESTAMP;
    assert(SUCCEEDED(a.device->CreateQuery(&q,&begin)));
    assert(SUCCEEDED(a.device->CreateQuery(&q,&end)));
    a.context->Begin(disjoint.Get()); a.context->End(begin.Get());
    const auto start=std::chrono::steady_clock::now();
    constexpr int iterations=120;
    for(int i=0;i<iterations;++i)
      assert(a.pipeline.Generate(a.context.Get(),a.frame.Get(),a.lighting.Get(),a.lit.Get(),nullptr,nullptr,a.p,++a.id));
    const double cpu_ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count()/iterations;
    a.context->End(end.Get()); a.context->End(disjoint.Get()); a.context->Flush();
    D3D11_QUERY_DATA_TIMESTAMP_DISJOINT timing{};
    for(int i=0; a.context->GetData(disjoint.Get(),&timing,sizeof(timing),D3D11_ASYNC_GETDATA_DONOTFLUSH)==S_FALSE; ++i) {
      assert(i<10000); std::this_thread::sleep_for(std::chrono::milliseconds(1));
    }
    UINT64 first=0,last=0;
    assert(a.context->GetData(begin.Get(),&first,sizeof(first),0)==S_OK);
    assert(a.context->GetData(end.Get(),&last,sizeof(last),0)==S_OK);
    assert(!timing.Disjoint && timing.Frequency);
    std::cout<<"Production-grid microbenchmark (160x90x96, synthetic shadow map, no cloud/terrain): "
             <<double(last-first)*1000./timing.Frequency/iterations<<" ms GPU; "<<cpu_ms<<" ms CPU submission\n";
  }
}
