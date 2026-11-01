/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3d11.h>
#include <d3dcompiler.h>
#include <wrl/client.h>
#include <array>
#include <cassert>
#include <cmath>
#include <cstring>
#include <iostream>
using Microsoft::WRL::ComPtr;
int main(int argc,char**) {
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&context)));
  const char* source=R"(
#include "lighting.hlsli"
RWStructuredBuffer<float4> output:register(u0);
[numthreads(64,1,1)] void main(uint id:SV_DispatchThreadID) {
  float tau=id==0u?0.f:pow(10.f,(id-1.f)/8.f-6.f);
  output[id]=float4(CloudDiffuseTransport(tau),exp(-tau),tau);
  if(id==0u)output[64]=float4(CloudOpticalExtinction,CloudScatteringAlbedo,
      CloudForwardG,CloudDiffuseTransport(-1.f).y);
})";
  ComPtr<ID3DBlob> code,errors;
  HRESULT compiled=D3DCompile(source,std::strlen(source),"src/games/thewitcher3classic/clouds/lighting_fixture.hlsl",
      nullptr,D3D_COMPILE_STANDARD_FILE_INCLUDE,"main","cs_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&code,&errors);
  if(errors)std::cerr<<static_cast<const char*>(errors->GetBufferPointer());assert(SUCCEEDED(compiled));
  ComPtr<ID3D11ComputeShader> shader;
  assert(SUCCEEDED(device->CreateComputeShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&shader)));
  D3D11_BUFFER_DESC desc{65*16,D3D11_USAGE_DEFAULT,D3D11_BIND_UNORDERED_ACCESS,0,
      D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
  ComPtr<ID3D11Buffer> output,read;
  assert(SUCCEEDED(device->CreateBuffer(&desc,nullptr,&output)));
  ComPtr<ID3D11UnorderedAccessView> view;
  assert(SUCCEEDED(device->CreateUnorderedAccessView(output.Get(),nullptr,&view)));
  desc.Usage=D3D11_USAGE_STAGING;desc.BindFlags=0;desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
  desc.MiscFlags=0;desc.StructureByteStride=0;
  assert(SUCCEEDED(device->CreateBuffer(&desc,nullptr,&read)));
  context->CSSetShader(shader.Get(),nullptr,0);context->CSSetUnorderedAccessViews(0,1,view.GetAddressOf(),nullptr);
  context->Dispatch(1,1,1);
  ID3D11UnorderedAccessView* empty=nullptr;context->CSSetUnorderedAccessViews(0,1,&empty,nullptr);
  context->CopyResource(read.Get(),output.Get());D3D11_MAPPED_SUBRESOURCE mapped{};
  assert(SUCCEEDED(context->Map(read.Get(),0,D3D11_MAP_READ,0,&mapped)));
  std::array<std::array<float,4>,65> values{};std::memcpy(values.data(),mapped.pData,sizeof(values));
  context->Unmap(read.Get(),0);
  assert(std::abs(values[64][0]-.075f)<1.e-7f &&values[64][3]==1.f);
  const double albedo=values[64][1],g=.9*values[64][2]-.02;
  const double a=(7-albedo*(4+3*g))/4,b=(albedo*(4-3*g)-1)/4;
  const double lambda=std::sqrt(a*a-b*b);
  for(unsigned i=0;i<64;++i) {
    const auto& v=values[i];const double tau=v[3];
    // Independent double-precision hyperbolic form of the two-stream solution.
    const double transmission=1/(std::cosh(lambda*tau)+a/lambda*std::sinh(lambda*tau));
    const double reflection=b/lambda*std::sinh(lambda*tau)*transmission;
    for(float x:v)assert(std::isfinite(x));
    assert(v[0]>=0 &&v[1]>=0 &&v[0]+v[1]<=1.000002f);
    assert(std::abs(v[1]-transmission)<2.e-5 &&std::abs(v[0]-reflection)<2.e-5);
    assert(v[1]+1.e-6f>=v[2]); // diffuse transport outlasts the unscattered beam
    if(i)assert(v[1]<=values[i-1][1]+1.e-6f &&v[2]<=values[i-1][2]+1.e-6f);
  }
  assert(values[0][0]==0 &&values[0][1]==1 &&values[0][2]==1);
  // At tau=10 the disc's direct beam is extinguished while diffuse light remains.
  assert(values[57][2]<.00005f &&values[57][1]>.1f);
  std::cout<<"PASS cloud liquid-water extinction, direct/diffuse separation, two-stream reference, energy bounds, vacuum and monotonicity\n";
}
