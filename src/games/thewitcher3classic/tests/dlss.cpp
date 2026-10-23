/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include "../temporal/dlss.hpp"
#include <d3d11sdklayers.h>
#include <cassert>
#include <fstream>
#include <iostream>
#include <vector>
#include "../../../utils/float16.hpp"
#include "../temporal/prepare.hpp"
#include "../temporal/upscale_engine.hpp"

using namespace witcher3classic::temporal;

// Model ReShade's resource GetDevice hook without loading a game: the owner
// exposes only IUnknown and the native-interface query used by our identity check.
struct ProxyOwner : IUnknown {
  ID3D11Device* native;
  ULONG references = 1;
  explicit ProxyOwner(ID3D11Device* device) : native(device) {}
  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, void** result) override {
    *result = nullptr;
    if (iid == __uuidof(renodx::utils::directx::ReShadeRetrieveBaseInterface)) {
      native->AddRef();
      *result = native;
      return S_OK;
    }
    return E_NOINTERFACE;
  }
  ULONG STDMETHODCALLTYPE AddRef() override { return ++references; }
  ULONG STDMETHODCALLTYPE Release() override { return --references; }
};

struct ProxyChild : ID3D11DeviceChild {
  ProxyOwner* owner;
  explicit ProxyChild(ProxyOwner* device) : owner(device) {}
  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID, void**) override { return E_NOINTERFACE; }
  ULONG STDMETHODCALLTYPE AddRef() override { return 1; }
  ULONG STDMETHODCALLTYPE Release() override { return 1; }
  void STDMETHODCALLTYPE GetDevice(ID3D11Device** result) override {
    owner->AddRef();
    *result = reinterpret_cast<ID3D11Device*>(owner);
  }
  HRESULT STDMETHODCALLTYPE GetPrivateData(REFGUID, UINT*, void*) override { return E_NOTIMPL; }
  HRESULT STDMETHODCALLTYPE SetPrivateData(REFGUID, UINT, const void*) override { return E_NOTIMPL; }
  HRESULT STDMETHODCALLTYPE SetPrivateDataInterface(REFGUID, const IUnknown*) override { return E_NOTIMPL; }
};

std::vector<uint8_t> Shader(const char* name) {
  std::ifstream file(std::filesystem::path("build/thewitcher3classic.include/embed") / name, std::ios::binary);
  assert(file);
  return {std::istreambuf_iterator<char>(file), std::istreambuf_iterator<char>()};
}

int main(int argc, char** argv) {
  assert(argc == 2);
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> base_context;
  auto hr = D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr, D3D11_CREATE_DEVICE_DEBUG, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &base_context);
  if (FAILED(hr)) hr = D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &base_context);
  assert(SUCCEEDED(hr));
  ProxyOwner proxy(device.Get());
  ProxyChild child(&proxy);
  assert(IsSameDevice(&child, device.Get()));
  assert(!IsSameDevice(&child, nullptr));
  assert(proxy.references == 1);
  ComPtr<ID3D11DeviceContext1> context;
  assert(SUCCEEDED(base_context.As(&context)));
  Dlss dlss;
  if (!dlss.Initialize(device.Get(), std::filesystem::path(argv[1]))) {
    std::cerr << dlss.status << " error=" << std::hex << dlss.error << '\n';
    return 1;
  }
  std::cerr << "NGX initialized on native D3D11 device\n";
  for (const auto quality : {NVSDK_NGX_PerfQuality_Value_DLAA, NVSDK_NGX_PerfQuality_Value_MaxQuality,
                             NVSDK_NGX_PerfQuality_Value_Balanced, NVSDK_NGX_PerfQuality_Value_MaxPerf,
                             NVSDK_NGX_PerfQuality_Value_UltraPerformance}) {
    RenderResolution resolution;
    assert(dlss.GetRenderResolution(1920, 1080, quality, &resolution));
    assert(quality != NVSDK_NGX_PerfQuality_Value_DLAA || (resolution.width == 1920 && resolution.height == 1080));
    std::cout << "NGX quality " << quality << ": " << resolution.width << 'x' << resolution.height
              << " -> 1920x1080; range " << resolution.min_width << 'x' << resolution.min_height
              << " .. " << resolution.max_width << 'x' << resolution.max_height << '\n';
  }
  Prepare prepare;
  assert(prepare.Initialize(device.Get(), Shader("0xF3C10001.cso"), Shader("0xF3C10002.cso"), Shader("0xF3C10003.cso"), Shader("0xF3C10004.cso")));
  for (const auto quality : QUALITY_MODES) {
    RenderResolution resolution;
    const uint32_t output_width = 1280, output_height = 720;
    assert(dlss.GetRenderResolution(output_width, output_height, quality, &resolution));
    const uint32_t width = resolution.width, height = resolution.height;
    const bool upscale = quality != NVSDK_NGX_PerfQuality_Value_DLAA;
    // Model Classic: active input occupies the top-left of an output-sized pool.
    // Poison unused pixels so accidental full-pool sampling fails validation.
    std::vector<uint16_t> pixels(size_t(output_width) * output_height * 4);
    for (size_t i = 0; i < pixels.size(); i += 4) {
      pixels[i] = renodx::utils::float16::Encode((i / 4) % output_width < width && (i / 4) / output_width < height ? 2.f : 64.f);
      pixels[i + 1] = renodx::utils::float16::Encode(0.5f);
      pixels[i + 2] = renodx::utils::float16::Encode((i / 4) % output_width < width && (i / 4) / output_width < height ? -0.25f : -16.f);
      pixels[i + 3] = renodx::utils::float16::Encode(1.f);
    }
    std::vector<uint16_t> motion(size_t(output_width) * output_height * 2, 0);
    std::vector<float> depth(size_t(output_width) * output_height, 0.5f);
    ComPtr<ID3D11Texture2D> color_texture, depth_texture, motion_texture;
    D3D11_TEXTURE2D_DESC desc{output_width, output_height, 1, 1, DXGI_FORMAT_R16G16B16A16_FLOAT, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE};
    D3D11_SUBRESOURCE_DATA initial{pixels.data(), output_width * 8};
    assert(SUCCEEDED(device->CreateTexture2D(&desc, &initial, &color_texture)));
    desc.Format = DXGI_FORMAT_R32_FLOAT;
    initial = {depth.data(), output_width * 4};
    assert(SUCCEEDED(device->CreateTexture2D(&desc, &initial, &depth_texture)));
    desc.Format = DXGI_FORMAT_R16G16_FLOAT;
    initial = {motion.data(), output_width * 4};
    assert(SUCCEEDED(device->CreateTexture2D(&desc, &initial, &motion_texture)));
    // Leave native application state bound and verify NGX never leaks changes.
    ComPtr<ID3D11ShaderResourceView> original_srv;
    assert(SUCCEEDED(device->CreateShaderResourceView(color_texture.Get(), nullptr, &original_srv)));
    ComPtr<ID3D11ShaderResourceView> depth_srv;
    assert(SUCCEEDED(device->CreateShaderResourceView(depth_texture.Get(), nullptr, &depth_srv)));
    std::array<float, 180 * 4> camera = {};
    camera[0] = camera[1] = 0.25f;
    for (uint32_t i = 0; i < 4; ++i) camera[(78 + i) * 4 + i] = 1;
    std::array<float, 269 * 4> frame_constants = {};
    frame_constants[22 * 4] = -1;
    frame_constants[22 * 4 + 1] = 1;
    frame_constants[23 * 4] = float(width);
    frame_constants[23 * 4 + 1] = float(height);
    ComPtr<ID3D11Buffer> camera_cb, frame_cb;
    D3D11_BUFFER_DESC buffer_desc{sizeof(camera), D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER};
    D3D11_SUBRESOURCE_DATA cb_initial{camera.data()};
    assert(SUCCEEDED(device->CreateBuffer(&buffer_desc, &cb_initial, &camera_cb)));
    buffer_desc.ByteWidth = sizeof(frame_constants);
    cb_initial.pSysMem = frame_constants.data();
    assert(SUCCEEDED(device->CreateBuffer(&buffer_desc, &cb_initial, &frame_cb)));
    auto* raw_srv = original_srv.Get();
    context->PSSetShaderResources(3, 1, &raw_srv);
    D3D11_VIEWPORT viewport{4, 8, 100, 90, 0, 1};
    context->RSSetViewports(1, &viewport);
    assert(prepare.Run(context.Get(), original_srv.Get(), depth_srv.Get(), nullptr, camera_cb.Get(), frame_cb.Get(), width, height));
    DlssInputs inputs{
        .color = prepare.textures[0].Get(),
        .depth = prepare.textures[1].Get(),
        .motion = prepare.textures[2].Get(),
        .responsive = prepare.textures[3].Get(),
        .width = width,
        .height = height,
        .output_width = output_width,
        .output_height = output_height,
        .reset = false,
        .motion_validated = false,
        .quality = quality,
    };
    assert(!dlss.Evaluate(context.Get(), inputs));
    inputs.motion_validated = true;  // Exact static scene; zero motion is correct.
    for (uint64_t frame = 0; frame < 16; ++frame) {
      camera[0] = upscale_engine::Halton(static_cast<uint32_t>(frame) + 1, 2);
      camera[1] = upscale_engine::Halton(static_cast<uint32_t>(frame) + 1, 3);
      context->UpdateSubresource(camera_cb.Get(), 0, nullptr, camera.data(), 0, 0);
      assert(prepare.Run(context.Get(), original_srv.Get(), depth_srv.Get(), nullptr, camera_cb.Get(), frame_cb.Get(), width, height));
      inputs.jitter_x = -camera[0];
      inputs.jitter_y = -camera[1];
      inputs.frame_id = frame;
      inputs.render_preset = MODEL_PRESETS[(frame / 3) % 5];
      if (!dlss.Evaluate(context.Get(), inputs)) {
        std::cerr << dlss.status << " error=" << std::hex << dlss.error << '\n';
        return 2;
      }
      ComPtr<ID3D11ShaderResourceView> restored;
      context->PSGetShaderResources(3, 1, &restored);
      assert(restored == original_srv);
      UINT count = 1;
      D3D11_VIEWPORT restored_viewport;
      context->RSGetViewports(&count, &restored_viewport);
      assert(count == 1 && restored_viewport.TopLeftX == viewport.TopLeftX && restored_viewport.Height == viewport.Height);
    }
    D3D11_TEXTURE2D_DESC output_desc;
    dlss.output->GetDesc(&output_desc);
    assert(output_desc.Width == output_width && output_desc.Height == output_height);
    output_desc.Usage = D3D11_USAGE_STAGING;
    output_desc.BindFlags = 0;
    output_desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    ComPtr<ID3D11Texture2D> staging;
    assert(SUCCEEDED(device->CreateTexture2D(&output_desc, nullptr, &staging)));
    context->CopyResource(staging.Get(), dlss.output.Get());
    D3D11_MAPPED_SUBRESOURCE mapped;
    assert(SUCCEEDED(context->Map(staging.Get(), 0, D3D11_MAP_READ, 0, &mapped)));
    const auto* center = reinterpret_cast<const uint16_t*>(static_cast<const uint8_t*>(mapped.pData) + (output_height / 2) * mapped.RowPitch) + (output_width / 2) * 4;
    // Confirm HDR survives the actual NVIDIA model, not merely feature creation.
    assert(std::abs(renodx::utils::float16::Decode(center[0]) - 2.f) < 0.1f);
    assert(std::abs(renodx::utils::float16::Decode(center[1]) - 0.5f) < 0.1f);
    context->Unmap(staging.Get(), 0);
    // Exercise the final FP16 -> R11 conversion used by the native TAA target.
    ComPtr<ID3D11ShaderResourceView> resolved;
    assert(SUCCEEDED(device->CreateShaderResourceView(dlss.output.Get(), nullptr, &resolved)));
    desc.Format = DXGI_FORMAT_R11G11B10_FLOAT;
    desc.Width = output_width;
    desc.Height = output_height;
    desc.BindFlags = D3D11_BIND_RENDER_TARGET;
    ComPtr<ID3D11Texture2D> target;
    ComPtr<ID3D11RenderTargetView> rtv;
    assert(SUCCEEDED(device->CreateTexture2D(&desc, nullptr, &target)));
    assert(SUCCEEDED(device->CreateRenderTargetView(target.Get(), nullptr, &rtv)));
    assert(prepare.Blit(context.Get(), resolved.Get(), rtv.Get(), output_width, output_height));
    // Check diagnostic meanings numerically before any later game color effects.
    D3D11_TEXTURE2D_DESC debug_desc{output_width, output_height, 1, 1, DXGI_FORMAT_R32G32B32A32_FLOAT, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_RENDER_TARGET};
    ComPtr<ID3D11Texture2D> debug_target, debug_readback;
    ComPtr<ID3D11RenderTargetView> debug_rtv;
    assert(SUCCEEDED(device->CreateTexture2D(&debug_desc, nullptr, &debug_target)));
    assert(SUCCEEDED(device->CreateRenderTargetView(debug_target.Get(), nullptr, &debug_rtv)));
    debug_desc.Usage = D3D11_USAGE_STAGING;
    debug_desc.BindFlags = 0;
    debug_desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    assert(SUCCEEDED(device->CreateTexture2D(&debug_desc, nullptr, &debug_readback)));
    // Signed residual is restored into a signed output after actual NGX.
    // Poisoned unused source pixels and jitter exercise active-subrect clamping.
    assert(prepare.Blit(context.Get(), resolved.Get(), debug_rtv.Get(), output_width, output_height,
                        nullptr, false, 0, original_srv.Get(), .49f, -.49f));
    context->CopyResource(debug_readback.Get(), debug_target.Get());
    assert(SUCCEEDED(context->Map(debug_readback.Get(), 0, D3D11_MAP_READ, 0, &mapped)));
    for (const auto pixel : {std::pair{0u, 0u}, std::pair{output_width / 2, output_height / 2}, std::pair{output_width - 1, output_height - 1}}) {
      const auto* value = reinterpret_cast<const float*>(static_cast<const uint8_t*>(mapped.pData) + pixel.second * mapped.RowPitch) + pixel.first * 4;
      assert(std::isfinite(value[2]) && std::abs(value[2] + .25f) < .01f);
      assert(std::abs(value[0] - 2.f) < .1f && value[3] == 1.f);
    }
    context->Unmap(debug_readback.Get(), 0);
    for (uint32_t view = 1; view <= 5; ++view) {
      const uint32_t source = view <= 2 ? 2 : view == 3 ? 1
                                          : view == 4   ? 3
                                                        : 0;
      assert(prepare.Blit(context.Get(), prepare.views[source].Get(), debug_rtv.Get(), output_width, output_height,
                          view == 1 ? depth_srv.Get() : nullptr, view == 1, view));
      context->CopyResource(debug_readback.Get(), debug_target.Get());
      assert(SUCCEEDED(context->Map(debug_readback.Get(), 0, D3D11_MAP_READ, 0, &mapped)));
      const auto* color = reinterpret_cast<const float*>(static_cast<const uint8_t*>(mapped.pData)
                                                         + (output_height - 1) * mapped.RowPitch)
                          + (output_width - 1) * 4;
      const float expected = view == 1 ? 0.18f : view == 3 ? 0.5f
                                             : view == 5   ? 2.f
                                                           : 0.f;
      assert(std::abs(color[0] - expected) < 0.002f);
      assert(std::abs(color[3] - 1.f) < 0.002f);
      context->Unmap(debug_readback.Get(), 0);
      ComPtr<ID3D11ShaderResourceView> restored;
      context->PSGetShaderResources(3, 1, &restored);
      assert(restored == original_srv);
    }
    // Compare GPU vector preparation to known identity/translated projections.
    D3D11_TEXTURE2D_DESC mv_desc;
    prepare.textures[2]->GetDesc(&mv_desc);
    mv_desc.Usage = D3D11_USAGE_STAGING;
    mv_desc.BindFlags = 0;
    mv_desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    ComPtr<ID3D11Texture2D> mv_staging;
    assert(SUCCEEDED(device->CreateTexture2D(&mv_desc, nullptr, &mv_staging)));
    for (float translation : {0.f, 0.04f, -0.08f}) {
      camera[81 * 4] = translation;
      for (uint32_t phase = 1; phase <= 32; ++phase) {
        camera[0] = upscale_engine::Halton(phase, 2);
        camera[1] = upscale_engine::Halton(phase, 3);
        context->UpdateSubresource(camera_cb.Get(), 0, nullptr, camera.data(), 0, 0);
        assert(prepare.Run(context.Get(), original_srv.Get(), depth_srv.Get(), nullptr, camera_cb.Get(), frame_cb.Get(), width, height));
        context->CopyResource(mv_staging.Get(), prepare.textures[2].Get());
        assert(SUCCEEDED(context->Map(mv_staging.Get(), 0, D3D11_MAP_READ, 0, &mapped)));
        const auto* mv = reinterpret_cast<const uint16_t*>(static_cast<const uint8_t*>(mapped.pData) + (height / 2) * mapped.RowPitch) + (width / 2) * 2;
        assert(std::abs(renodx::utils::float16::Decode(mv[0]) - translation * 0.5f) < 1e-4f);
        assert(std::abs(renodx::utils::float16::Decode(mv[1])) < 1e-4f);
        context->Unmap(mv_staging.Get(), 0);
      }
    }
    std::cout << "PASS native DX11 " << (upscale ? "DLSS " : "DLAA ") << "mode " << quality << ": " << width << 'x' << height
              << " -> " << output_width << 'x' << output_height << " HDR output/state restoration" << std::endl;
  }
  std::cerr << "Shutting down NGX\n";
  dlss.Shutdown();
  std::cerr << "NGX shutdown complete\n";
  assert(!dlss.output);
  ComPtr<ID3D11InfoQueue> info;
  if (SUCCEEDED(device.As(&info))) {
    for (UINT64 i = 0; i < info->GetNumStoredMessages(); ++i) {
      SIZE_T size = 0;
      info->GetMessage(i, nullptr, &size);
      std::vector<uint8_t> bytes(size);
      auto* message = reinterpret_cast<D3D11_MESSAGE*>(bytes.data());
      info->GetMessage(i, message, &size);
      if (message->Severity <= D3D11_MESSAGE_SEVERITY_ERROR) {
        std::cerr << message->pDescription << '\n';
        return 3;
      }
    }
  }
}
