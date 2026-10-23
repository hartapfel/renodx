/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <array>
#include <cassert>
#include <iostream>
#include "../temporal/constant_uploads.hpp"
using Microsoft::WRL::ComPtr;
using witcher3classic::temporal::ConstantUploads;

int main(int argc, char**) {
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr, argc > 1 ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP,
      nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &context)));
  for (const UINT bytes : {128u, 256u, 288u, 352u, 480u, 784u, 1104u, 4304u}) {
    ConstantUploads uploads;
    uploads.track_writes = true;
    std::vector<uint8_t> expected(bytes);
    for (UINT i = 0; i < bytes; ++i) expected[i] = uint8_t(i * 37);
    const D3D11_BUFFER_DESC desc{bytes, D3D11_USAGE_DYNAMIC, D3D11_BIND_CONSTANT_BUFFER, D3D11_CPU_ACCESS_WRITE};
    const D3D11_SUBRESOURCE_DATA initial{expected.data()};
    ComPtr<ID3D11Buffer> source, a, b, staging;
    assert(SUCCEEDED(device->CreateBuffer(&desc, &initial, &source)));
    assert(SUCCEEDED(device->CreateBuffer(&desc, nullptr, &a)));
    assert(SUCCEEDED(device->CreateBuffer(&desc, nullptr, &b)));
    const D3D11_BUFFER_DESC readback{bytes, D3D11_USAGE_STAGING, 0, D3D11_CPU_ACCESS_READ};
    assert(SUCCEEDED(device->CreateBuffer(&readback, nullptr, &staging)));
    // Blocking readback is confined to this offline byte-equivalence fixture.
    const auto verify = [&](ID3D11Buffer* buffer) {
      context->CopyResource(staging.Get(), buffer);
      D3D11_MAPPED_SUBRESOURCE mapped;
      assert(SUCCEEDED(context->Map(staging.Get(), 0, D3D11_MAP_READ, 0, &mapped)));
      assert(std::memcmp(mapped.pData, expected.data(), bytes) == 0);
      context->Unmap(staging.Get(), 0);
    };
    uploads.Snapshot(context.Get(), a.Get(), source.Get(), 0);
    uploads.Snapshot(context.Get(), b.Get(), source.Get(), 0);
    assert(uploads.copied == 2);
    verify(a.Get()); verify(b.Get());
    uploads.Snapshot(context.Get(), a.Get(), source.Get(), 1);
    uploads.Snapshot(context.Get(), b.Get(), source.Get(), 1);
    assert(uploads.unchanged == 2 && uploads.copied == 0);

    D3D11_MAPPED_SUBRESOURCE native;
    assert(SUCCEEDED(context->Map(source.Get(), 0, D3D11_MAP_WRITE_DISCARD, 0, &native)));
    void* redirected = native.pData;
    uploads.Map(source.Get(), 0, UINT64_MAX, true, &redirected);
    assert(redirected != native.pData && uintptr_t(redirected) % 16 == 0);
    for (auto& value : expected) value ^= 0xA7;
    std::memcpy(redirected, expected.data(), bytes);
    uploads.Unmap(source.Get());
    context->Unmap(source.Get(), 0);
    verify(source.Get()); // Native game receives exactly the application's write.
    uploads.Snapshot(context.Get(), a.Get(), source.Get(), 2);
    assert(uploads.uploaded == 1 && uploads.copied == 0);
    verify(a.Get());
    // The other history slot is still the old frame, independently versioned.
    for (auto& value : expected) value ^= 0xA7;
    verify(b.Get());
    for (auto& value : expected) value ^= 0xA7;
    uploads.Snapshot(context.Get(), b.Get(), source.Get(), 2);
    verify(b.Get());

    // GPU/unknown writes invalidate both CPU contents and copy-dedup versions.
    uploads.Invalidate(source.Get());
    uploads.Snapshot(context.Get(), a.Get(), source.Get(), 3);
    assert(uploads.copied == 1 && uploads.uploaded == 0);
    verify(a.Get());
    // Unknown partial contents cannot create a complete mirror.
    uploads.Update(source.Get(), expected.data(), 0, 16);
    uploads.Snapshot(context.Get(), b.Get(), source.Get(), 4);
    assert(uploads.copied == 1 && uploads.uploaded == 0);
    verify(b.Get());
    uploads.Update(source.Get(), expected.data(), 0, UINT64_MAX);
    uploads.Snapshot(context.Get(), a.Get(), source.Get(), 5);
    assert(uploads.uploaded == 1);
    verify(a.Get());
    // A camera/pass may change the source bound to the same history target.
    // Cache identity must include the latest source, not just its local version.
    ComPtr<ID3D11Buffer> other;
    const D3D11_BUFFER_DESC default_desc{bytes, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER};
    assert(SUCCEEDED(device->CreateBuffer(&default_desc, &initial, &other)));
    uploads.Snapshot(context.Get(), a.Get(), other.Get(), 6);
    for (auto& value : expected) value ^= 0x31;
    uploads.Update(other.Get(), expected.data(), 0, UINT64_MAX);
    context->UpdateSubresource(other.Get(), 0, nullptr, expected.data(), 0, 0);
    uploads.Snapshot(context.Get(), a.Get(), other.Get(), 7);
    assert(uploads.uploaded == 1);
    verify(a.Get());
    for (auto& value : expected) value ^= 0x31;
    uploads.Snapshot(context.Get(), a.Get(), source.Get(), 8);
    assert(uploads.uploaded == 1 && uploads.unchanged == 0);
    verify(a.Get());
    // Expiring a tracked entry must not invalidate an outstanding mapped pointer.
    assert(SUCCEEDED(context->Map(source.Get(), 0, D3D11_MAP_WRITE_DISCARD, 0, &native)));
    redirected = native.pData;
    uploads.Map(source.Get(), 0, UINT64_MAX, true, &redirected);
    uploads.Finish(1000);
    std::memcpy(redirected, expected.data(), bytes);
    uploads.Unmap(source.Get());
    context->Unmap(source.Get(), 0);
    verify(source.Get());
    uploads.Finish(1000);
    uploads.Snapshot(context.Get(), a.Get(), source.Get(), 1001);
    assert(uploads.copied == 1 && uploads.uploaded == 0);
    verify(a.Get());
    std::cout << "PASS constant upload history " << bytes << " bytes\n";
  }
}
