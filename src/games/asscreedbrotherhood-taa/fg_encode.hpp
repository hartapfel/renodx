/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11_4.h>
#include <tlhelp32.h>
#include <wrl/client.h>
#include <embed/shaders.h>
#include "../asscreedeziotrilogy/output_bridge.hpp"
#include "./presentation_protocol.hpp"
#include "./dlaa_handles.hpp"

namespace acbrotherhood::frame_generation {
using Microsoft::WRL::ComPtr;
struct Encoder {
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext1> context;
  ComPtr<ID3DDeviceContextState> isolated;
  ComPtr<ID3D11VertexShader> vs;
  ComPtr<ID3D11PixelShader> ps;
  ComPtr<ID3D11Buffer> constants;
  ComPtr<ID3D11SamplerState> sampler;
  ComPtr<ID3D11Texture2D> source, encoded, mask_source, mask_encoded;
  ComPtr<ID3D11ShaderResourceView> srv, mask_srv;
  ComPtr<ID3D11RenderTargetView> rtv, mask_rtv;
  uint64_t generation = 0, shared_handle = 0, mask_handle = 0;
  std::wstring hdr_module;

  bool Encode(ID3D11Device* native, const D3D11_TEXTURE2D_DESC& output, Inputs* inputs) {
    using presentation::Check;
    using presentation::Stage;
    const bool sdr = output.Format == DXGI_FORMAT_B8G8R8A8_UNORM || output.Format == DXGI_FORMAT_R8G8B8A8_UNORM;
    if (!(inputs->flags & hudless) || (!sdr && output.Format != DXGI_FORMAT_R10G10B10A2_UNORM)) return false;
    if (!sdr && hdr_module.empty()) {
      dlaa::Handle modules(CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, GetCurrentProcessId()));
      if (modules.value == INVALID_HANDLE_VALUE) { modules.value = nullptr; return false; }
      MODULEENTRY32W entry{sizeof(entry)};
      if (Module32FirstW(modules.value, &entry)) do {
        if (GetProcAddress(entry.hModule, "RenodxEzioReadOutputParameters")) { hdr_module = entry.szModule; break; }
      } while (Module32NextW(modules.value, &entry));
    }
    const auto module = !hdr_module.empty() ? GetModuleHandleW(hdr_module.c_str()) : nullptr;
    const auto read = module ? reinterpret_cast<ac2::output_bridge::ReadParameters>(GetProcAddress(module, "RenodxEzioReadOutputParameters")) : nullptr;
    ac2::output_bridge::Parameters parameters{};
    if (!sdr && (!read || !read(&parameters))) return false;
    if (!device) {
      device = native;
      ComPtr<ID3D11Device1> device1;
      Check(device.As(&device1), Stage::device);
      ComPtr<ID3D11DeviceContext> immediate;
      device->GetImmediateContext(&immediate);
      Check(immediate.As(&context), Stage::device);
      const auto level = device->GetFeatureLevel();
      // The HDR proxy creates a single-threaded device. Context-state creation
      // must preserve that flag or the runtime returns E_INVALIDARG.
      Check(device1->CreateDeviceContextState(
          (device->GetCreationFlags() & D3D11_CREATE_DEVICE_SINGLETHREADED) ? D3D11_1_CREATE_DEVICE_CONTEXT_STATE_SINGLETHREADED : 0,
          &level, 1, D3D11_SDK_VERSION, __uuidof(ID3D11Device), nullptr, &isolated), Stage::device);
      Check(device->CreateVertexShader(__fg_fullscreen.data(), __fg_fullscreen.size(), nullptr, &vs), Stage::copy);
      Check(device->CreatePixelShader(sdr ? __fg_sdr.data() : __fg_hudless.data(),
          sdr ? __fg_sdr.size() : __fg_hudless.size(), nullptr, &ps), Stage::copy);
      D3D11_BUFFER_DESC buffer{}; buffer.ByteWidth = sizeof(parameters.injection);
      buffer.Usage = D3D11_USAGE_DEFAULT; buffer.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
      Check(device->CreateBuffer(&buffer, nullptr, &constants), Stage::copy);
      D3D11_SAMPLER_DESC sampling{}; sampling.Filter = D3D11_FILTER_MIN_MAG_MIP_POINT;
      sampling.AddressU = sampling.AddressV = sampling.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
      sampling.MaxLOD = D3D11_FLOAT32_MAX;
      Check(device->CreateSamplerState(&sampling, &sampler), Stage::copy);
      D3D11_TEXTURE2D_DESC target = output;
      target.Usage = D3D11_USAGE_DEFAULT; target.CPUAccessFlags = 0;
      target.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
      target.MiscFlags = D3D11_RESOURCE_MISC_SHARED;
      Check(device->CreateTexture2D(&target, nullptr, &encoded), Stage::sharing);
      Check(device->CreateRenderTargetView(encoded.Get(), nullptr, &rtv), Stage::sharing);
      ComPtr<IDXGIResource> resource;
      Check(encoded.As(&resource), Stage::sharing);
      HANDLE handle = nullptr;
      Check(resource->GetSharedHandle(&handle), Stage::sharing);
      shared_handle = uintptr_t(handle);
      target.Format = DXGI_FORMAT_R32_FLOAT;
      Check(device->CreateTexture2D(&target, nullptr, &mask_encoded), Stage::sharing);
      Check(device->CreateRenderTargetView(mask_encoded.Get(), nullptr, &mask_rtv), Stage::sharing);
      resource.Reset(); Check(mask_encoded.As(&resource), Stage::sharing);
      Check(resource->GetSharedHandle(&handle), Stage::sharing); mask_handle = uintptr_t(handle);
    }
    if (generation != inputs->generation) {
      srv.Reset(); source.Reset();
      Check(device->OpenSharedResource(reinterpret_cast<HANDLE>(uintptr_t(inputs->textures[2])), IID_PPV_ARGS(&source)), Stage::sharing);
      D3D11_TEXTURE2D_DESC desc{}; source->GetDesc(&desc);
      if (desc.Width != output.Width || desc.Height != output.Height || desc.Format != DXGI_FORMAT_R16G16B16A16_FLOAT
          || desc.SampleDesc.Count != 1) return false;
      Check(device->CreateShaderResourceView(source.Get(), nullptr, &srv), Stage::sharing);
      mask_srv.Reset(); mask_source.Reset();
      if (inputs->textures[3]) {
        Check(device->OpenSharedResource(reinterpret_cast<HANDLE>(uintptr_t(inputs->textures[3])), IID_PPV_ARGS(&mask_source)), Stage::sharing);
        mask_source->GetDesc(&desc);
        if (desc.Width != output.Width || desc.Height != output.Height || desc.Format != DXGI_FORMAT_R32_FLOAT || desc.SampleDesc.Count != 1) return false;
        Check(device->CreateShaderResourceView(mask_source.Get(), nullptr, &mask_srv), Stage::sharing);
      }
      generation = inputs->generation;
    }
    // Swap the complete native context state, including every shader stage,
    // UAV, sampler and render target. Never leak auxiliary state into ReShade.
    struct Restore {
      ID3D11DeviceContext1* context;
      ComPtr<ID3DDeviceContextState> saved;
      ~Restore() { context->SwapDeviceContextState(saved.Get(), nullptr); }
    } restore{context.Get()};
    context->SwapDeviceContextState(isolated.Get(), &restore.saved);
    context->ClearState();
    context->UpdateSubresource(constants.Get(), 0, nullptr, parameters.injection, 0, 0);
    context->VSSetShader(vs.Get(), nullptr, 0);
    context->PSSetShader(ps.Get(), nullptr, 0);
    ID3D11Buffer* cb = constants.Get(); context->PSSetConstantBuffers(13, 1, &cb);
    ID3D11SamplerState* sampling = sampler.Get(); context->PSSetSamplers(0, 1, &sampling);
    ID3D11ShaderResourceView* views[] = {srv.Get(), mask_srv.Get()}; context->PSSetShaderResources(0, 2, views);
    ID3D11RenderTargetView* targets[] = {rtv.Get(), mask_rtv.Get()}; context->OMSetRenderTargets(2, targets, nullptr);
    const D3D11_VIEWPORT viewport{0,0,float(output.Width),float(output.Height),0.f,1.f};
    context->RSSetViewports(1, &viewport);
    context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    context->Draw(3, 0);
    inputs->textures[2] = shared_handle;
    inputs->hudless_format = output.Format;
    inputs->textures[3] = mask_handle;
    if (!mask_srv) inputs->flags &= ~ui_alpha;
    inputs->flags |= hdr_encoded;
    return true;
  }
};
}
