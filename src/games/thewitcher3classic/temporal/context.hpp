/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11_1.h>
#include <wrl/client.h>
#include "../../../utils/directx.hpp"

namespace witcher3classic::temporal {
// ReShade hooks resource GetDevice to return its proxy, even when the resource
// was created through the native device. Compare the underlying device instead.
inline bool IsSameDevice(ID3D11DeviceChild* child, ID3D11Device* expected) {
  Microsoft::WRL::ComPtr<ID3D11Device> owner;
  child->GetDevice(&owner);
  auto* native = owner.Get();
  renodx::utils::directx::NativeFromReShadeProxy(&native);
  return native == expected;
}

inline HRESULT CreateIsolatedState(ID3D11Device* device, ID3DDeviceContextState** state) {
  Microsoft::WRL::ComPtr<ID3D11Device1> device1;
  if (FAILED(device->QueryInterface(IID_PPV_ARGS(&device1)))) return E_NOINTERFACE;
  const auto level = device->GetFeatureLevel();
  return device1->CreateDeviceContextState(
      (device->GetCreationFlags() & D3D11_CREATE_DEVICE_SINGLETHREADED) ? D3D11_1_CREATE_DEVICE_CONTEXT_STATE_SINGLETHREADED : 0,
      &level, 1, D3D11_SDK_VERSION, __uuidof(ID3D11Device), nullptr, state);
}

// Native context state stays outside ReShade's tracking and is restored whole.
struct ContextScope {
  ID3D11DeviceContext1* context;
  Microsoft::WRL::ComPtr<ID3DDeviceContextState> saved;
  ContextScope(ID3D11DeviceContext1* native, ID3DDeviceContextState* isolated) : context(native) {
    context->SwapDeviceContextState(isolated, &saved);
    context->ClearState();
  }
  ContextScope(const ContextScope&) = delete;
  ContextScope& operator=(const ContextScope&) = delete;
  ~ContextScope() { context->SwapDeviceContextState(saved.Get(), nullptr); }
};
}  // namespace witcher3classic::temporal
