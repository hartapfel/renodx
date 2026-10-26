/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3d11sdklayers.h>
#include <DirectXMath.h>
#include <cassert>
#include <iostream>
#include <vector>
#include "../../../utils/float16.hpp"
#include "../optics/motion_camera.hpp"
#include "../optics/pipeline.hpp"
using namespace witcher3classic;
using Microsoft::WRL::ComPtr;
using namespace DirectX;

struct Fixture {
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext1> context;
  ComPtr<ID3D11Buffer> frame;
  uint64_t id = 0;
  optics::Pipeline pipeline;
  ComPtr<ID3D11ShaderResourceView> Texture(UINT w, UINT h, DXGI_FORMAT format, const void* data, UINT pixel_bytes) {
    D3D11_TEXTURE2D_DESC desc{w, h, 1, 1, format, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE};
    D3D11_SUBRESOURCE_DATA initial{data, w * pixel_bytes, 0};
    ComPtr<ID3D11Texture2D> texture;
    ComPtr<ID3D11ShaderResourceView> view;
    assert(SUCCEEDED(device->CreateTexture2D(&desc, &initial, &texture)));
    assert(SUCCEEDED(device->CreateShaderResourceView(texture.Get(), nullptr, &view)));
    return view;
  }
  ComPtr<ID3D11Buffer> Constants(const void* data, UINT size) {
    D3D11_BUFFER_DESC desc{size, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER};
    D3D11_SUBRESOURCE_DATA initial{data};
    ComPtr<ID3D11Buffer> buffer;
    assert(SUCCEEDED(device->CreateBuffer(&desc, &initial, &buffer)));
    return buffer;
  }
  std::vector<float> Read(ID3D11ShaderResourceView* view) {
    ComPtr<ID3D11Resource> resource;
    ComPtr<ID3D11Texture2D> texture, staging;
    view->GetResource(&resource);
    assert(SUCCEEDED(resource.As(&texture)));
    D3D11_TEXTURE2D_DESC desc;
    texture->GetDesc(&desc);
    assert(desc.Format == DXGI_FORMAT_R16G16B16A16_FLOAT);
    desc.Usage = D3D11_USAGE_STAGING;
    desc.BindFlags = 0;
    desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    assert(SUCCEEDED(device->CreateTexture2D(&desc, nullptr, &staging)));
    context->CopyResource(staging.Get(), texture.Get());
    D3D11_MAPPED_SUBRESOURCE mapped;
    assert(SUCCEEDED(context->Map(staging.Get(), 0, D3D11_MAP_READ, 0, &mapped)));
    std::vector<float> result(desc.Width * desc.Height * 4);
    for (UINT y = 0; y < desc.Height; ++y)
      for (UINT x = 0; x < desc.Width * 4; ++x) {
        auto value = renodx::utils::float16::Decode(reinterpret_cast<const uint16_t*>(static_cast<const uint8_t*>(mapped.pData) + y * mapped.RowPitch)[x]);
        assert(std::isfinite(value));
        result[y * desc.Width * 4 + x] = value;
      }
    context->Unmap(staging.Get(), 0);
    return result;
  }
  std::vector<float> Run(UINT w, UINT h, const std::vector<float>& color, const std::vector<float>& depths,
                         const std::vector<float>& vectors, bool history = true, float elapsed = 16.667f, float sharpening = 0.f) {
    auto scene = Texture(w, h, DXGI_FORMAT_R32G32B32A32_FLOAT, color.data(), 16);
    auto depth = Texture(w, h, DXGI_FORMAT_R32_FLOAT, depths.data(), 4);
    auto motion = Texture(w, h, DXGI_FORMAT_R32G32B32A32_FLOAT, vectors.data(), 16);
    assert(pipeline.Capture(context.Get(), depth.Get(), motion.Get(), motion.Get(), depth.Get(), frame.Get(), w, h, 0, 0, elapsed, history, ++id));
    // Check that all optical draws restore the application's actual bindings.
    ID3D11ShaderResourceView* before = scene.Get();
    context->PSSetShaderResources(0, 1, &before);
    const D3D11_VIEWPORT viewport{3, 5, 57, 59, .2f, .8f};
    context->RSSetViewports(1, &viewport);
    auto* result = pipeline.Run(context.Get(), scene.Get(), w, h, id, sharpening);
    ComPtr<ID3D11ShaderResourceView> after;
    context->PSGetShaderResources(0, 1, &after);
    assert(after.Get() == before);
    UINT count = 1;
    D3D11_VIEWPORT restored;
    context->RSGetViewports(&count, &restored);
    assert(!memcmp(&viewport, &restored, sizeof(viewport)));
    if (!result) return color;
    assert(!pipeline.Run(context.Get(), scene.Get(), w, h, id));  // Once per main scene.
    return Read(result);
  }
};

int main(int argc, char**) {
  std::cout << std::unitbuf;
  Fixture f;
  ComPtr<ID3D11DeviceContext> base;
  auto hr = D3D11CreateDevice(nullptr, argc > 1 ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP, nullptr,
                              D3D11_CREATE_DEVICE_DEBUG, nullptr, 0, D3D11_SDK_VERSION, &f.device, nullptr, &base);
  if (FAILED(hr)) hr = D3D11CreateDevice(nullptr, argc > 1 ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP, nullptr,
                                         0, nullptr, 0, D3D11_SDK_VERSION, &f.device, nullptr, &base);
  assert(SUCCEEDED(hr));
  assert(SUCCEEDED(base.As(&f.context)));
  std::array<float, 1076> frame{};
  frame[22 * 4] = 1;
  frame[21 * 4] = 1;
  f.frame = f.Constants(frame.data(), sizeof(frame));
  optics::custom = true;
  optics::motion_mode = 2;
  optics::dof_mode = 0;
  optics::bloom_mode = 1;
  for (const UINT width : {64u, 127u}) {
    const UINT height = 64;
    std::vector<float> color(width * height * 4), depth(width * height, .1f), motion(width * height * 4);
    for (size_t i = 0; i < color.size(); i += 4) {
      color[i] = 4;
      color[i + 1] = 2;
      color[i + 2] = 1;
      color[i + 3] = 1;
    }
    optics::bloom_strength = 1;
    optics::bloom_size = .5f;
    optics::bloom_extraction = 3;
    auto result = f.Run(width, height, color, depth, motion);
    float l = (4 * .2126f + 2 * .7152f + .0722f) / 4;
    for (size_t i = 0; i < result.size(); i += 4)
      for (size_t c = 0; c < 3; ++c)
        assert(std::abs(result[i + c] - color[i + c] * (1 + 1.728f * l * l * l)) < .025f);
    optics::bloom_size = .1f;
    const auto narrow_bloom = f.Run(width, height, color, depth, motion);
    for (size_t i = 0; i < narrow_bloom.size(); i += 4) for (size_t c = 0; c < 3; ++c)
      assert(std::abs(narrow_bloom[i+c] - color[i+c]*(1+l*l*l)) < .025f);
    optics::bloom_mode = 0;
    optics::dof_mode = 1;
    result = f.Run(width, height, color, depth, motion);
    for (size_t i = 0; i < result.size(); ++i) assert(std::abs(result[i] - color[i]) < .015f);
    optics::dof_mode = 0;
    optics::motion_mode = 0;
    result = f.Run(width, height, color, depth, motion);
    for (size_t i = 0; i < result.size(); ++i) assert(std::abs(result[i] - color[i]) < .015f);
    // HDR edge: camera-only movement must not enter Object Only blur.
    for (UINT y = 0; y < height; ++y)
      for (UINT x = 0; x < width; ++x) {
        for (UINT c = 0; c < 3; ++c) color[(y * width + x) * 4 + c] = (x > width / 2 ? 8.f : 0.f);
        motion[(y * width + x) * 4] = .03f;
      }
    optics::motion_mode = 1;
    result = f.Run(width, height, color, depth, motion);
    for (size_t i = 0; i < result.size(); ++i) assert(std::abs(result[i] - color[i]) < .015f);
    optics::motion_mode = 0;
    result = f.Run(width, height, color, depth, motion);
    double changed = 0;
    for (size_t i = 0; i < result.size(); ++i) changed += std::abs(result[i] - color[i]);
    assert(changed > 1);
    auto cut = f.Run(width, height, color, depth, motion, false);
    assert(cut == color);
    // Fixed exposure must not change with frame rate when vector displacement
    // follows the frame interval. The low-rate Custom velocity cap scales likewise.
    for (float milliseconds : {33.334f, 8.3335f, 4.16675f}) {
      auto scaled_motion = motion;
      for (size_t i = 0; i < scaled_motion.size(); i += 4) scaled_motion[i] *= milliseconds / 16.667f;
      const auto scaled = f.Run(width, height, color, depth, scaled_motion, true, milliseconds);
      for (size_t i = 0; i < scaled.size(); ++i) assert(std::abs(scaled[i] - result[i]) < .025f);
    }
    for (size_t i = 0; i < motion.size(); i += 4) motion[i + 2] = motion[i];
    optics::motion_mode = 1;
    const auto object_blur = f.Run(width, height, color, depth, motion);
    for (size_t i = 0; i < result.size(); ++i) assert(std::abs(object_blur[i] - result[i]) < .015f);
    // The exact camera-removed vector is not itself a shutter displacement.
    // Followed subjects (T=0, O!=0) and static backgrounds (T!=0, O=0)
    // stay sharp; partial cancellation follows T and cannot exceed its speed.
    for (const auto& sample : std::array<std::array<float,4>,5>{{
        {0.f,0.f,.08f,-.05f}, {.00001f,-.00001f,.1f,0.f},
        {.03f,0.f,-.1f,.04f}, {.03f,.01f,.003f,-.002f}, {-.02f,.01f,0.f,0.f}}}) {
      const float screen_speed=std::hypot(sample[0]*width,sample[1]*height);
      const float object_speed=std::hypot(sample[2]*width,sample[3]*height);
      const float share=std::min(1.f,object_speed/std::max(screen_speed,1e-8f));
      auto expected_motion=motion;
      for(size_t i=0;i<motion.size();i+=4) {
        std::copy(sample.begin(),sample.end(),motion.begin()+i);
        expected_motion[i]=sample[0]*share;expected_motion[i+1]=sample[1]*share;
      }
      optics::motion_mode=0;
      const auto visible_reference=f.Run(width,height,color,depth,expected_motion);
      optics::motion_mode=1;
      const auto followed=f.Run(width,height,color,depth,motion);
      for(size_t i=0;i<followed.size();++i) assert(std::abs(followed[i]-visible_reference[i])<.015f);
      if(screen_speed==0.f || object_speed==0.f)
        for(size_t i=0;i<followed.size();++i) assert(std::abs(followed[i]-color[i])<.015f);
    }
    std::cout<<"PASS camera-follow cancellation, static-background exclusion, visible direction and screen-speed bound\n";
    optics::motion_mode = 2;
    const auto sharpened = f.Run(width, height, color, depth, motion, true, 16.667f, .8f);
    assert(*std::max_element(sharpened.begin(), sharpened.end()) >= 8.f);

    // Foreground/background DoF with signed HDR colors and bright defocus.
    optics::motion_mode = 2;
    optics::dof_mode = 1;
    optics::focal_length = 100;
    optics::aperture = 1;
    for (UINT y = 0; y < height; ++y)
      for (UINT x = 0; x < width; ++x) {
        depth[y * width + x] = x < width / 2 ? .5f : .02f;
        color[(y * width + x) * 4] = (x % 8 == 0 ? 16.f : 0.f);
        color[(y * width + x) * 4 + 2] = -.1f;
      }
    result = f.Run(width, height, color, depth, motion);
    assert(*std::max_element(result.begin(), result.end()) > 1.f);
    assert(*std::min_element(result.begin(), result.end()) < 0.f);
    optics::motion_mode = 2;
    optics::dof_mode = 0;
    optics::bloom_mode = 1;
  }
  std::cout << "PASS optical chain: HDR energy, signed gamut, near/far DoF, stationary/object-only identity, camera blur, history reset, resize, state restoration\n";
  {
    constexpr UINT extent = 256;
    std::vector<float> color(extent * extent * 4), depth(extent * extent, .1f), motion(extent * extent * 4);
    for (UINT y = 0; y < extent; ++y)
      for (UINT x = 0; x < extent; ++x) {
        const UINT i = (y * extent + x) * 4;
        color[i] = color[i + 1] = color[i + 2] = ((x / 4 + y / 4) % 2) ? 8.f : 0.f;
        color[i + 3] = 1;
      }
    optics::motion_mode = 2;
    optics::bloom_mode = 0;
    optics::dof_mode = 1;
    optics::focal_length = 100;
    optics::aperture = 1;
    optics::focus_distance = 10;
    const auto focused = f.Run(extent, extent, color, depth, motion);
    for (size_t i = 0; i < color.size(); ++i) assert(std::abs(focused[i] - color[i]) < .015f);
    std::fill(depth.begin(), depth.end(), .02f);
    const auto defocused = f.Run(extent, extent, color, depth, motion);
    double difference = 0;
    for (size_t i = 0; i < color.size(); ++i) difference += std::abs(defocused[i] - color[i]);
    assert(difference > 100);
  }
  std::cout << "PASS physical focus plane, frame-rate-independent shutter, object-only blur, RCAS prepass\n";
  // Production camera transform against independent double-position projection.
  optics::MotionCamera matrices;
  for (int test = 0; test < 32; ++test) {
    XMMATRIX previous = XMMatrixRotationY(.03f * test) * XMMatrixTranslation(.01f * test, 0, 2) * XMMatrixPerspectiveFovLH(1.f, 1.77f, .1f, 1000.f);
    XMMATRIX current = XMMatrixRotationY(-.02f * test) * XMMatrixTranslation(.03f * test, .05f, 2.3f) * XMMatrixPerspectiveFovLH(.9f, 1.77f, .1f, 1000.f);
    std::array<float, 16> p, c;
    XMStoreFloat4x4(reinterpret_cast<XMFLOAT4X4*>(p.data()), XMMatrixTranspose(previous));
    XMStoreFloat4x4(reinterpret_cast<XMFLOAT4X4*>(c.data()), XMMatrixTranspose(current));
    auto current_frame = frame, previous_frame = frame;
    current_frame[60] = .001f;
    current_frame[61] = -.002f;
    previous_frame[60] = -.0015f;
    previous_frame[61] = .0005f;
    for (int r = 0; r < 2; ++r)
      for (int i = 0; i < 4; ++i) {
        c[r * 4 + i] += current_frame[60 + r] * c[12 + i];
        p[r * 4 + i] += previous_frame[60 + r] * p[12 + i];
      }
    auto cbp = f.Constants(p.data(), 64), cbc = f.Constants(c.data(), 64);
    auto cbfc = f.Constants(current_frame.data(), sizeof(current_frame)), cbfp = f.Constants(previous_frame.data(), sizeof(previous_frame));
    auto* view = matrices.Prepare(f.context.Get(), cbc.Get(), cbp.Get(), cbfc.Get(), cbfp.Get(), test);
    assert(view);
    ComPtr<ID3D11Resource> resource;
    ComPtr<ID3D11Buffer> staging;
    view->GetResource(&resource);
    D3D11_BUFFER_DESC desc{64, D3D11_USAGE_STAGING, 0, D3D11_CPU_ACCESS_READ};
    assert(SUCCEEDED(f.device->CreateBuffer(&desc, nullptr, &staging)));
    f.context->CopyResource(staging.Get(), resource.Get());
    D3D11_MAPPED_SUBRESOURCE mapped;
    assert(SUCCEEDED(f.context->Map(staging.Get(), 0, D3D11_MAP_READ, 0, &mapped)));
    XMFLOAT4 clip, expected;
    XMStoreFloat4(&clip, XMVector4Transform(XMVectorSet(.2f, .3f, 5, 1), previous));
    XMStoreFloat4(&expected, XMVector4Transform(XMVectorSet(.2f, .3f, 5, 1), current));
    const auto* matrix = static_cast<const float*>(mapped.pData);
    for (int r = 0; r < 4; ++r) {
      const float actual = matrix[r * 4] * clip.x + matrix[r * 4 + 1] * clip.y + matrix[r * 4 + 2] * clip.z + matrix[r * 4 + 3] * clip.w;
      assert(std::abs(actual - reinterpret_cast<float*>(&expected)[r]) < .001f);
    }
    f.context->Unmap(staging.Get(), 0);
  }
  std::cout << "PASS camera removal: 32 translating/rotating/projection-changing camera pairs with different jitters\n";
  ComPtr<ID3D11InfoQueue> info;
  if (SUCCEEDED(f.device.As(&info)))
    for (UINT64 i = 0; i < info->GetNumStoredMessages(); ++i) {
      SIZE_T bytes = 0;
      info->GetMessage(i, nullptr, &bytes);
      std::vector<uint8_t> storage(bytes);
      auto* message = reinterpret_cast<D3D11_MESSAGE*>(storage.data());
      info->GetMessage(i, message, &bytes);
      if (message->Severity <= D3D11_MESSAGE_SEVERITY_ERROR) {
        std::cerr << message->pDescription << '\n';
        return 1;
      }
    }
}
