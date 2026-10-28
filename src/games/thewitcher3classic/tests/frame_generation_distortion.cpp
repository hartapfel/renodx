/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
// Validate the GPU map against the authored lens and its inverse, in pixels.
#include <cassert>
#include <array>
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <DirectXPackedVector.h>
#include <embed/shaders.h>
#include "../frame_generation/distortion.hpp"
using Microsoft::WRL::ComPtr;
using namespace witcher3classic::frame_generation;

int main() {
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> base;
  ComPtr<ID3D11DeviceContext1> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &base)));
  assert(SUCCEEDED(base.As(&context)));
  Distortion lens;
  for (const UINT width : {320u, 430u}) for (const float intensity : {0.f, .5f, 1.f, 3.f, 5.f}) {
    constexpr UINT height = 180;
    assert(lens.Update(context.Get(), width, height, intensity, __swap_chain_proxy_vertex_shader, __0xF3CF0001));
    const auto version = lens.version;
    const auto* texture = lens.texture.Get();
    assert(lens.Update(context.Get(), width, height, intensity, __swap_chain_proxy_vertex_shader, __0xF3CF0001));
    assert(lens.version == version && lens.texture.Get() == texture);
    D3D11_TEXTURE2D_DESC desc{};
    lens.texture->GetDesc(&desc);
    assert(desc.Width == (width+1)/2 && desc.Height == (height+1)/2 && desc.Format == DXGI_FORMAT_R16G16B16A16_FLOAT);
    desc.Usage = D3D11_USAGE_STAGING; desc.BindFlags = 0; desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    ComPtr<ID3D11Texture2D> staging;
    assert(SUCCEEDED(device->CreateTexture2D(&desc, nullptr, &staging)));
    context->CopyResource(staging.Get(), lens.texture.Get());
    D3D11_MAPPED_SUBRESOURCE mapped{};
    assert(SUCCEEDED(context->Map(staging.Get(), 0, D3D11_MAP_READ, 0, &mapped)));
    // Double-precision reference for the original green-channel sample location.
    const auto source = [&](double u, double v) {
      const double aspect = double(width)/height, x = (2*u-1)*aspect/(16./9.), y = 2*v-1;
      const double radius = std::min(1., std::sqrt(x*x+y*y)*.52240777), dome = 1-std::sin(1.5707964*radius);
      const double offset = std::pow(radius,1.75)*84/std::sqrt(std::max(x*x+y*y+dome*dome,1e-12));
      return std::array<double,2>{u+intensity*(-.1*u+.050000012+offset*x*1.275/(1080*aspect)),
                                 v+intensity*(-.1*v+.050000012+offset*y*1.275/1080)};
    };
    double forward_error = 0, inverse_error = 0;
    for (UINT y=0;y<desc.Height;++y) for (UINT x=0;x<desc.Width;++x) {
      const auto* values = reinterpret_cast<const uint16_t*>(static_cast<const uint8_t*>(mapped.pData)+y*mapped.RowPitch)+x*4;
      float f[4]; for (UINT c=0;c<4;++c) { f[c]=DirectX::PackedVector::XMConvertHalfToFloat(values[c]); assert(std::isfinite(f[c])); }
      const double u=(x+.5)/desc.Width, v=(y+.5)/desc.Height;
      const auto direct=source(u,v), inverse=source(u+f[2],v+f[3]);
      forward_error=std::max(forward_error,std::max(std::abs(u+f[0]-direct[0])*3840,std::abs(v+f[1]-direct[1])*2160));
      inverse_error=std::max(inverse_error,std::max(std::abs(inverse[0]-u)*3840,std::abs(inverse[1]-v)*2160));
    }
    context->Unmap(staging.Get(),0);
    std::printf("%ux%u intensity %.1f: forward %.4f px, inverse %.4f px at 4K\n",width,height,intensity,forward_error,inverse_error);
    assert(forward_error < 1.0 && inverse_error < 1.0);
    if (intensity <= 1.f) assert(forward_error < .25 && inverse_error < .25);
  }
  std::puts("PASS: signed FP16 bidirectional map, inverse composition and cache reuse.");
}
