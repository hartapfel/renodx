// Validate the unmodified native XY conversion and lossless depth transport
// through an actual R16G16B16A16_FLOAT UAV. Inputs include zero, subnormals,
// far reversed-Z depths, depth one, and the native camera-motion sentinel.
#define NOMINMAX
#include <d3d11.h>
#include <DirectXPackedVector.h>
#include <wrl/client.h>
#include <array>
#include <bit>
#include <cmath>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iterator>
#include <stdexcept>
#include <vector>
using Microsoft::WRL::ComPtr;
using namespace DirectX::PackedVector;
void Check(HRESULT hr) { if (FAILED(hr)) throw std::runtime_error("D3D11 failure"); }
int main(int argc, char** argv) { try {
  if (argc != 4) throw std::runtime_error("Expected baseline, packed conversion, and reconstruction CS binaries");
  constexpr unsigned W=257,H=193;
  ComPtr<ID3D11Device> dev;ComPtr<ID3D11DeviceContext> cmd;
  Check(D3D11CreateDevice(nullptr,D3D_DRIVER_TYPE_WARP,nullptr,0,nullptr,0,D3D11_SDK_VERSION,&dev,nullptr,&cmd));
  ComPtr<ID3D11ComputeShader> shader[3];
  for (unsigned i=0;i<3;++i) {std::ifstream f(argv[i+1],std::ios::binary);std::vector<char> b{std::istreambuf_iterator<char>(f),{}};Check(dev->CreateComputeShader(b.data(),b.size(),nullptr,&shader[i]));}
  std::vector<std::array<float,4>> depth(W*H),motion(W*H);
  for(unsigned i=0;i<W*H;++i) {
    depth[i]={std::bit_cast<float>(unsigned((uint64_t(i)*104729u)%0x3f800001u)),0,0,0};
    motion[i]=i%3?std::array<float,4>{float(int(i%31)-15)*.003f,float(int(i%47)-23)*.003f,0,0}:std::array<float,4>{2,2,0,0};
  }
  depth[0][0]=0;depth[1][0]=1;depth[2][0]=std::bit_cast<float>(1u);
  ComPtr<ID3D11Texture2D> inputs[2],outputs[2],readback;
  ComPtr<ID3D11ShaderResourceView> srvs[2];ComPtr<ID3D11UnorderedAccessView> uavs[2];
  D3D11_TEXTURE2D_DESC desc={W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,0};
  for(unsigned i=0;i<2;++i) {D3D11_SUBRESOURCE_DATA data={i?motion.data():depth.data(),W*16,0};Check(dev->CreateTexture2D(&desc,&data,&inputs[i]));Check(dev->CreateShaderResourceView(inputs[i].Get(),nullptr,&srvs[i]));}
  desc.Format=DXGI_FORMAT_R16G16B16A16_FLOAT;desc.BindFlags=D3D11_BIND_UNORDERED_ACCESS|D3D11_BIND_SHADER_RESOURCE;
  for(unsigned i=0;i<2;++i) {Check(dev->CreateTexture2D(&desc,nullptr,&outputs[i]));Check(dev->CreateUnorderedAccessView(outputs[i].Get(),nullptr,&uavs[i]));}
  desc.BindFlags=0;desc.Usage=D3D11_USAGE_STAGING;desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;Check(dev->CreateTexture2D(&desc,nullptr,&readback));
  std::array<float,20> constants={W,H,1.f/W,1.f/H,1,0,0,0,0,1,0,0,.17f,-.07f,1,0,.03f,-.02f,0,1};
  D3D11_BUFFER_DESC bd={sizeof(constants),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER,0,0,0};D3D11_SUBRESOURCE_DATA initial={constants.data(),0,0};ComPtr<ID3D11Buffer> cb;Check(dev->CreateBuffer(&bd,&initial,&cb));
  cmd->CSSetConstantBuffers(10,1,cb.GetAddressOf());ID3D11ShaderResourceView* views[]={srvs[0].Get(),srvs[1].Get()};cmd->CSSetShaderResources(0,2,views);
  std::array<std::array<float,4>,6> camera_data{};camera_data[0]={1,0,1,0};
  D3D11_BUFFER_DESC scratch_desc={sizeof(camera_data),D3D11_USAGE_DEFAULT,D3D11_BIND_UNORDERED_ACCESS,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
  D3D11_SUBRESOURCE_DATA camera_initial={camera_data.data(),0,0};ComPtr<ID3D11Buffer> scratch;ComPtr<ID3D11UnorderedAccessView> scratch_uav;
  Check(dev->CreateBuffer(&scratch_desc,&camera_initial,&scratch));Check(dev->CreateUnorderedAccessView(scratch.Get(),nullptr,&scratch_uav));
  cmd->CSSetUnorderedAccessViews(1,1,scratch_uav.GetAddressOf(),nullptr);
  std::vector<std::array<uint16_t,4>> result[2];
  for(unsigned i=0;i<2;++i) {
    cmd->CSSetShader(shader[i].Get(),nullptr,0);cmd->CSSetUnorderedAccessViews(0,1,uavs[i].GetAddressOf(),nullptr);cmd->Dispatch((W+7)/8,(H+7)/8,1);
    ID3D11UnorderedAccessView* null=nullptr;cmd->CSSetUnorderedAccessViews(0,1,&null,nullptr);cmd->CopyResource(readback.Get(),outputs[i].Get());
    D3D11_MAPPED_SUBRESOURCE mapped;Check(cmd->Map(readback.Get(),0,D3D11_MAP_READ,0,&mapped));result[i].resize(W*H);
    for(unsigned y=0;y<H;++y)std::memcpy(result[i].data()+y*W,static_cast<char*>(mapped.pData)+y*mapped.RowPitch,W*8);cmd->Unmap(readback.Get(),0);
  }
  for(unsigned i=0;i<W*H;++i) {
    if(result[0][i][0]!=result[1][i][0]||result[0][i][1]!=result[1][i][1])throw std::runtime_error("Native motion XY changed");
    unsigned chunks[2];for(unsigned c=0;c<2;++c) {unsigned h=result[1][i][c+2];if((h&0x7fff)<0x400||(h&0x7fff)>0x43ff)throw std::runtime_error("Packed channel not normal finite");chunks[c]=((h&0x7fff)-0x400)|((h&0x8000)>>1);}
    if((chunks[0]|(chunks[1]<<15))!=std::bit_cast<unsigned>(depth[i][0]))throw std::runtime_error("Depth bit pattern changed");
  }
  for(unsigned chunk=0;chunk<32768;++chunk) {
    unsigned half=((chunk&0x3fff)+0x400)|((chunk&0x4000)<<1);
    half=XMConvertFloatToHalf(XMConvertHalfToFloat(half));
    if((((half&0x7fff)-0x400)|((half&0x8000)>>1))!=chunk)throw std::runtime_error("Chunk roundtrip failed");
  }
  // Derive the reference camera field using the ORIGINAL native shader with
  // every pixel marked static. This tests reprojection/sign/FP16 conventions
  // independently of the custom subtraction, including far-depth values.
  for(auto& v:motion)v={2,2,0,0};
  cmd->UpdateSubresource(inputs[1].Get(),0,nullptr,motion.data(),W*16,0);
  cmd->CSSetShader(shader[0].Get(),nullptr,0);cmd->CSSetUnorderedAccessViews(0,1,uavs[0].GetAddressOf(),nullptr);cmd->Dispatch((W+7)/8,(H+7)/8,1);
  ID3D11UnorderedAccessView* null_uav=nullptr;cmd->CSSetUnorderedAccessViews(0,1,&null_uav,nullptr);cmd->CopyResource(readback.Get(),outputs[0].Get());
  D3D11_MAPPED_SUBRESOURCE mapped;Check(cmd->Map(readback.Get(),0,D3D11_MAP_READ,0,&mapped));
  std::vector<std::array<uint16_t,4>> camera(W*H);
  for(unsigned y=0;y<H;++y)std::memcpy(camera.data()+y*W,static_cast<char*>(mapped.pData)+y*mapped.RowPitch,W*8);cmd->Unmap(readback.Get(),0);
  ComPtr<ID3D11ShaderResourceView> packed_srv;Check(dev->CreateShaderResourceView(outputs[1].Get(),nullptr,&packed_srv));
  desc.Format=DXGI_FORMAT_R32G32B32A32_FLOAT;desc.Usage=D3D11_USAGE_DEFAULT;desc.CPUAccessFlags=0;desc.BindFlags=D3D11_BIND_UNORDERED_ACCESS;
  ComPtr<ID3D11Texture2D> diagnostic,diagnostic_readback;ComPtr<ID3D11UnorderedAccessView> diagnostic_uav;
  Check(dev->CreateTexture2D(&desc,nullptr,&diagnostic));Check(dev->CreateUnorderedAccessView(diagnostic.Get(),nullptr,&diagnostic_uav));
  desc.Usage=D3D11_USAGE_STAGING;desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;desc.BindFlags=0;Check(dev->CreateTexture2D(&desc,nullptr,&diagnostic_readback));
  struct Settings {float angle=720;unsigned samples=16,diagnostic=1;float seconds=0;unsigned components=3;float object_angle=720;unsigned padding[2]={};} settings;
  bd.ByteWidth=sizeof(settings);ComPtr<ID3D11Buffer> settings_cb;Check(dev->CreateBuffer(&bd,nullptr,&settings_cb));cmd->CSSetConstantBuffers(0,1,settings_cb.GetAddressOf());
  ID3D11ShaderResourceView* inputs_for_blur[]={nullptr,srvs[0].Get(),packed_srv.Get()};cmd->CSSetShaderResources(0,3,inputs_for_blur);
  cmd->CSSetShader(shader[2].Get(),nullptr,0);
  // In addition to the original mixed field, exercise a followed subject,
  // camera-only background, slight screen drift, opposing motion and moving
  // limbs transverse to the pan. All use camera vectors from the native shader.
  const char* scenarios[]={"mixed", "tracked", "static", "slow drift", "near static", "opposing", "transverse", "fast aligned"};
  for(unsigned pass=0;pass<11;++pass) {
    unsigned flags=pass<4?pass:2;
    unsigned scenario=pass<4?0:pass-3;
    if(scenario!=0) {
      ID3D11ShaderResourceView* null_srv=nullptr;cmd->CSSetShaderResources(2,1,&null_srv);
      for(unsigned i=0;i<W*H;++i) {
        float cx=XMConvertHalfToFloat(camera[i][0]),cy=XMConvertHalfToFloat(camera[i][1]);
        std::array<float,2> v{};
        switch(scenario) {
          case 1:v={0,0};break;
          case 2:v={cx,cy};break;
          case 3:v={cx*.02f,cy*.02f};break;
          case 4:v={cx*1.02f,cy*1.02f};break;
          case 5:v={-cx,-cy};break;
          case 6:v={-cy,cx};break;
          case 7:v={cx*4,cy*4};break;
        }
        for(unsigned c=0;c<2;++c)result[1][i][c]=XMConvertFloatToHalf(v[c]);
      }
      cmd->UpdateSubresource(outputs[1].Get(),0,nullptr,result[1].data(),W*8,0);
      cmd->CSSetShaderResources(2,1,packed_srv.GetAddressOf());
    }
    settings.components=flags;cmd->UpdateSubresource(settings_cb.Get(),0,nullptr,&settings,0,0);
    cmd->CSSetUnorderedAccessViews(0,1,diagnostic_uav.GetAddressOf(),nullptr);cmd->Dispatch((W+7)/8,(H+7)/8,1);
    cmd->CSSetUnorderedAccessViews(0,1,&null_uav,nullptr);cmd->CopyResource(diagnostic_readback.Get(),diagnostic.Get());Check(cmd->Map(diagnostic_readback.Get(),0,D3D11_MAP_READ,0,&mapped));
    float max_error=0;
    for(unsigned y=0;y<H;++y)for(unsigned x=0;x<W;++x) {
      unsigned i=y*W+x;
      std::array<float,2> native={XMConvertHalfToFloat(result[1][i][0])*W,XMConvertHalfToFloat(result[1][i][1])*H};
      std::array<float,2> cam={XMConvertHalfToFloat(camera[i][0])*W,XMConvertHalfToFloat(camera[i][1])*H};
      float screen_speed=std::hypot(native[0],native[1]),object_speed=std::hypot(native[0]-cam[0],native[1]-cam[1]);
      for(unsigned c=0;c<2;++c) {
        float object_weight=std::min(1.f,object_speed/std::max(screen_speed,1e-8f));
        float expected=native[c]*((flags&1?1.f:0.f)*(1.f-object_weight)+(flags&2?1.f:0.f)*object_weight);
        float actual=reinterpret_cast<const float*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch)[x*4+c];
        max_error=std::max(max_error,std::abs(actual-expected));
        if(flags==2 && scenario<=2 && scenario!=0 && actual!=0.f)throw std::runtime_error("Tracked subject or static background blurred");
      }
    }
    cmd->Unmap(diagnostic_readback.Get(),0);
    std::cout<<"components="<<flags<<" scenario="<<scenarios[scenario]<<" max_pixel_velocity_error="<<max_error<<'\n';
    if(max_error>1e-4f)throw std::runtime_error("Camera/object separation differs from native reference");
  }
  // Independently generate static-scene vectors with the original converter
  // under fast perspective camera changes. The original test above used an
  // affine matrix; perspective division and FP16 rounding need separate proof.
  unsigned projection_cases = 0;
  for(unsigned camera_case=0;camera_case<13;++camera_case) {
    constants={W,H,1.f/W,1.f/H,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1};
    float a = camera_case%2 ? .55f : -.55f;
    if(camera_case==1||camera_case==2) { constants[16]=a; constants[17]=a*.37f; }
    if(camera_case==3||camera_case==4) {
      constants[4]=std::cos(a);constants[7]=-std::sin(a);
      constants[16]=std::sin(a);constants[19]=std::cos(a);
    }
    if(camera_case==5||camera_case==6) {
      constants[9]=std::cos(a);constants[11]=-std::sin(a);
      constants[17]=std::sin(a);constants[19]=std::cos(a);
    }
    if(camera_case==7||camera_case==8) {
      constants[4]=std::cos(a);constants[5]=std::sin(a);
      constants[8]=-std::sin(a);constants[9]=std::cos(a);
    }
    if(camera_case==9) { constants[4]=1.3f;constants[9]=1.3f; }
    if(camera_case==10) { constants[4]=.7f;constants[9]=.7f; }
    if(camera_case==11) { constants[12]=.8f;constants[13]=-.3f;constants[15]=.2f; }
    if(camera_case==12) { constants[16]=1.f/W;constants[17]=-1.f/H; }
    for(auto& v:motion)v={2,2,0,0};
    ID3D11ShaderResourceView* unbind[3]={};
    cmd->CSSetShaderResources(0,3,unbind);
    cmd->UpdateSubresource(cb.Get(),0,nullptr,constants.data(),0,0);
    cmd->UpdateSubresource(inputs[1].Get(),0,nullptr,motion.data(),W*16,0);
    // Also exercise explicit raster velocities equal to the camera field,
    // rather than testing only pixels with the native static sentinel.
    for(unsigned explicit_velocity=0;explicit_velocity<2;++explicit_velocity) {
      cmd->CSSetShaderResources(0,3,unbind);
      cmd->CSSetShaderResources(0,2,views);
      cmd->CSSetShader(shader[0].Get(),nullptr,0);
      cmd->CSSetUnorderedAccessViews(0,1,uavs[0].GetAddressOf(),nullptr);cmd->Dispatch((W+7)/8,(H+7)/8,1);
      cmd->CSSetUnorderedAccessViews(0,1,&null_uav,nullptr);
      if(explicit_velocity==0) {
        cmd->CopyResource(readback.Get(),outputs[0].Get());Check(cmd->Map(readback.Get(),0,D3D11_MAP_READ,0,&mapped));
        for(unsigned y=0;y<H;++y) {
          auto* row=reinterpret_cast<const uint16_t*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch);
          for(unsigned x=0;x<W;++x) motion[y*W+x]={-XMConvertHalfToFloat(row[x*4]),-XMConvertHalfToFloat(row[x*4+1]),0,0};
        }
        cmd->Unmap(readback.Get(),0);
      }
      cmd->CSSetShader(shader[1].Get(),nullptr,0);
      cmd->CSSetUnorderedAccessViews(0,1,uavs[1].GetAddressOf(),nullptr);cmd->Dispatch((W+7)/8,(H+7)/8,1);
      cmd->CSSetUnorderedAccessViews(0,1,&null_uav,nullptr);
      cmd->CSSetShaderResources(0,3,inputs_for_blur);
      settings.components=2;settings.angle=0;settings.object_angle=360;
      cmd->UpdateSubresource(settings_cb.Get(),0,nullptr,&settings,0,0);
      cmd->CSSetShader(shader[2].Get(),nullptr,0);
      cmd->CSSetUnorderedAccessViews(0,1,diagnostic_uav.GetAddressOf(),nullptr);cmd->Dispatch((W+7)/8,(H+7)/8,1);
      cmd->CSSetUnorderedAccessViews(0,1,&null_uav,nullptr);
      cmd->CopyResource(diagnostic_readback.Get(),diagnostic.Get());Check(cmd->Map(diagnostic_readback.Get(),0,D3D11_MAP_READ,0,&mapped));
      float maximum_radius=0;
      for(unsigned y=0;y<H;++y)for(unsigned x=0;x<W;++x) {
        auto* p=reinterpret_cast<const float*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch)+x*4;
        if(!std::isfinite(p[0])||!std::isfinite(p[1]))throw std::runtime_error("Nonfinite camera separation");
        maximum_radius=std::max(maximum_radius,std::hypot(p[0]*3840.f/W,p[1]*2160.f/H));
      }
      cmd->Unmap(diagnostic_readback.Get(),0);
      std::cout<<"static_projection="<<camera_case<<" explicit="<<explicit_velocity<<" max_4k_object_radius="<<maximum_radius<<'\n';
      if(maximum_radius>.01f)throw std::runtime_error("Camera-only movement leaked into object blur");
      ++projection_cases;
      cmd->CSSetShaderResources(0,3,unbind);
      cmd->UpdateSubresource(inputs[1].Get(),0,nullptr,motion.data(),W*16,0);
    }
  }
  std::cout<<"PASS: "<<W*H<<" GPU pixels retain exact native XY and exact 32-bit depth through FP16 storage; all 32768 packed chunks roundtrip; "<<projection_cases<<" static camera cases\n";
 }catch(const std::exception& e){std::cerr<<"FAIL "<<e.what()<<'\n';return 1;} }
