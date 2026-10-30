/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include "darker_nights.hpp"
#include <d3d11.h>
#include <wrl/client.h>
#include "../../utils/data.hpp"
#include "../../utils/directx.hpp"

namespace witcher3classic::night {
using Microsoft::WRL::ComPtr;
struct __declspec(uuid("8a4ad657-642f-4438-9eb6-89a4aa38239d")) DeviceData {
  ComPtr<ID3D11DeviceContext> context;
  ComPtr<ID3D11Buffer> previous;
  bool bound = false;
  void Restore() {
    if (!bound) return;
    context->PSSetConstantBuffers(12, 1, previous.GetAddressOf());
    previous.Reset(); bound = false;
  }
};
inline void OnInit(reshade::api::device* device) { renodx::utils::data::Create<DeviceData>(device); }
inline void OnDestroy(reshade::api::device* device) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(device)) data->Restore();
  renodx::utils::data::Delete<DeviceData>(device);
}
inline void OnMoonPixel(reshade::api::command_list* cmd) {
  // The primary native moon pixel shader has no b12 declaration. Its paired
  // VS already has the correct view's common buffer; borrow it for the tag.
  if (enabled != 1.f || !installed || moon_brightness == 100.f
      || cmd->get_device()->get_api() != reshade::api::device_api::d3d11) return;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if (!data) return;
  data->Restore();
  auto* context = reinterpret_cast<ID3D11DeviceContext*>(cmd->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&context);
  if (context->GetType() != D3D11_DEVICE_CONTEXT_IMMEDIATE) return;
  ComPtr<ID3D11Buffer> common;
  context->VSGetConstantBuffers(12, 1, &common);
  if (!common) return;
  D3D11_BUFFER_DESC desc{}; common->GetDesc(&desc);
  if (desc.ByteWidth != 4304) return;
  data->context = context;
  context->PSGetConstantBuffers(12, 1, &data->previous);
  context->PSSetConstantBuffers(12, 1, common.GetAddressOf());
  data->bound = true;
}
inline void OnMoonDrawn(reshade::api::command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device())) data->Restore();
}
}  // namespace witcher3classic::night
