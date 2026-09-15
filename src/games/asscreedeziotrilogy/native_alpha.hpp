/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <d3d9.h>
#include <wrl/client.h>

#include <array>
#include <sstream>
#include <unordered_map>
#include <unordered_set>

#include "../../utils/command_action.hpp"
#include "../../utils/data.hpp"
#include "./native_alpha_patch.hpp"
#include "./native_lighting_patch.hpp"

namespace ac2::native_alpha {

using Microsoft::WRL::ComPtr;

inline std::unordered_set<uint32_t> scheduled_shaders;
inline bool expand_lighting = false;

struct ShaderVariants {
  ComPtr<IDirect3DPixelShader9> original;
  // Bits: 1 = bounded alpha, 2 = bounded RGB mask, 4 = expanded lighting.
  std::array<ComPtr<IDirect3DPixelShader9>, 8> variants;
  DWORD attempted_variants = 0;
};

struct __declspec(uuid("1b90484e-39ca-4b24-b155-ae287c735ae8")) DeviceData {
  std::unordered_map<IDirect3DPixelShader9*, ShaderVariants> shaders;
  // ReShade exposes Draw*UP data as temporary buffer bindings. Replaying a
  // guarded draw must bind those buffers and reproduce the native UP unbind.
  IDirect3DVertexBuffer9* up_vertices = nullptr;
  UINT up_stride = 0;
  IDirect3DIndexBuffer9* up_indices = nullptr;
};

inline bool UsesSourceAlpha(DWORD factor) {
  return factor == D3DBLEND_SRCALPHA || factor == D3DBLEND_INVSRCALPHA
         || factor == D3DBLEND_SRCALPHASAT || factor == D3DBLEND_BOTHSRCALPHA
         || factor == D3DBLEND_BOTHINVSRCALPHA;
}

inline DWORD GetOutputSaturation(IDirect3DDevice9* device) {
  DWORD enabled = 0, writes = 0, source = 0, dest = 0, operation = 0;
  if (FAILED(device->GetRenderState(D3DRS_ALPHABLENDENABLE, &enabled)) || !enabled
      || FAILED(device->GetRenderState(D3DRS_COLORWRITEENABLE, &writes)) || (writes & 7u) == 0
      || FAILED(device->GetRenderState(D3DRS_SRCBLEND, &source))
      || FAILED(device->GetRenderState(D3DRS_DESTBLEND, &dest))
      || FAILED(device->GetRenderState(D3DRS_BLENDOP, &operation))
      || operation == D3DBLENDOP_MIN || operation == D3DBLENDOP_MAX) return 0;

  DWORD mask = 0;
  if (UsesSourceAlpha(source) || UsesSourceAlpha(dest)) {
    mask = D3DSP_WRITEMASK_3;
  } else if (operation == D3DBLENDOP_ADD
             && ((source == D3DBLEND_DESTCOLOR && dest == D3DBLEND_ZERO)
                 || (source == D3DBLEND_ZERO && (dest == D3DBLEND_SRCCOLOR || dest == D3DBLEND_INVSRCCOLOR)))) {
    // Pure modulation treats source RGB as a mask over destination scene RGB.
    // In Brotherhood the persistent glow mask is multiplied by scene brightness
    // each frame. Values above one turn this into unbounded feedback, even with
    // bounded source alpha. Restore the UNORM mask domain, keeping destination
    // HDR, shader alpha, and ordinary additive/opaque draws untouched.
    mask = D3DSP_WRITEMASK_0 | D3DSP_WRITEMASK_1 | D3DSP_WRITEMASK_2;
  }
  if (mask == 0) return 0;

  ComPtr<IDirect3DSurface9> target;
  D3DSURFACE_DESC desc;
  return SUCCEEDED(device->GetRenderTarget(0, &target)) && target != nullptr
                 && SUCCEEDED(target->GetDesc(&desc)) && desc.Format == D3DFMT_A16B16G16R16F
             ? mask : 0;
}

inline void OnInitDevice(reshade::api::device* device) {
  if (device->get_api() == reshade::api::device_api::d3d9) renodx::utils::data::Create<DeviceData>(device);
}

inline void OnDestroyDevice(reshade::api::device* device) {
  if (device->get_api() == reshade::api::device_api::d3d9) renodx::utils::data::Delete<DeviceData>(device);
}

inline void OnBindVertexBuffers(reshade::api::command_list* cmd_list, uint32_t first, uint32_t count,
                                const reshade::api::resource* buffers, const uint64_t*, const uint32_t* strides) {
  if (cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9 || first != 0 || count == 0) return;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd_list->get_device());
  if (data == nullptr) return;
  data->up_vertices = nullptr;
  ComPtr<IDirect3DVertexBuffer9> current;
  UINT offset = 0, stride = 0;
  auto* native = reinterpret_cast<IDirect3DDevice9*>(cmd_list->get_native());
  if (buffers[0].handle != 0 && strides != nullptr && SUCCEEDED(native->GetStreamSource(0, &current, &offset, &stride))
      && reinterpret_cast<uintptr_t>(current.Get()) != buffers[0].handle) {
    data->up_vertices = reinterpret_cast<IDirect3DVertexBuffer9*>(buffers[0].handle);
    data->up_stride = strides[0];
  }
}

inline void OnBindIndexBuffer(reshade::api::command_list* cmd_list, reshade::api::resource buffer, uint64_t, uint32_t) {
  if (cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9) return;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd_list->get_device());
  if (data == nullptr) return;
  data->up_indices = nullptr;
  ComPtr<IDirect3DIndexBuffer9> current;
  auto* native = reinterpret_cast<IDirect3DDevice9*>(cmd_list->get_native());
  if (buffer.handle != 0 && SUCCEEDED(native->GetIndices(&current))
      && reinterpret_cast<uintptr_t>(current.Get()) != buffer.handle) {
    data->up_indices = reinterpret_cast<IDirect3DIndexBuffer9*>(buffer.handle);
  }
}

inline constexpr auto OnCommand = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  if (context.cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9) return {};
  // The wildcard callback runs before the mod's shader callbacks. Their explicit
  // registrations below run afterwards, so the guard patches the actual bound
  // replacement and cannot be overwritten by scene/UI shader selection.
  if (context.matched_shader_hash == 0) {
    if (renodx::utils::command_action::GetShaderState(&context) == nullptr) return {};
    const auto hash = renodx::utils::shader::GetCurrentPixelShaderHash(
        renodx::utils::command_action::GetShaderState(&context));
    if (scheduled_shaders.contains(hash)) return {};
  }
  auto* native = reinterpret_cast<IDirect3DDevice9*>(context.cmd_list->get_native());
  const DWORD mask = GetOutputSaturation(native);
  bool lighting = expand_lighting && (mask == 0 || mask == D3DSP_WRITEMASK_3);
  if (lighting && mask == 0) {
    // Alpha-guarded draws already passed these format/write checks. Only color
    // rendering into FP16 can use the HDR material variant; depth/mask passes
    // retain their original bytecode.
    DWORD writes = 0;
    ComPtr<IDirect3DSurface9> target;
    D3DSURFACE_DESC desc;
    lighting = SUCCEEDED(native->GetRenderState(D3DRS_COLORWRITEENABLE, &writes)) && (writes & 7u) != 0
               && SUCCEEDED(native->GetRenderTarget(0, &target)) && target != nullptr
               && SUCCEEDED(target->GetDesc(&desc)) && desc.Format == D3DFMT_A16B16G16R16F;
  }
  if (mask == 0 && !lighting) return {};
  const unsigned variant = (lighting ? 4u : 0u) | (mask == D3DSP_WRITEMASK_3 ? 1u : mask != 0 ? 2u : 0u);
  auto* data = renodx::utils::data::Get<DeviceData>(context.cmd_list->get_device());
  if (data == nullptr) return {};
  ComPtr<IDirect3DPixelShader9> original;
  if (FAILED(native->GetPixelShader(&original)) || original == nullptr) return {};
  auto found = data->shaders.find(original.Get());
  if (found == data->shaders.end()) {
    // Bound retained shader memory even if a future game streams many unique
    // effects. Originals are retained with variants to prevent pointer reuse.
    if (data->shaders.size() >= 256) data->shaders.erase(data->shaders.begin());
    found = data->shaders.emplace(original.Get(), ShaderVariants{.original = original}).first;
  }
  auto& replacement = found->second.variants[variant];
  if ((found->second.attempted_variants & (1u << variant)) == 0) {
    found->second.attempted_variants |= 1u << variant;
    UINT size = 0;
    if (FAILED(original->GetFunction(nullptr, &size)) || size == 0 || size % sizeof(DWORD) != 0) return {};
    std::vector<DWORD> bytes(size / sizeof(DWORD));
    if (FAILED(original->GetFunction(bytes.data(), &size))) return {};
    auto patched = lighting ? UnclampMaterialLighting(bytes) : std::vector<DWORD>{};
    const bool unclamped = !patched.empty();
    if (mask != 0) {
      auto bounded = SaturateOutput(unclamped ? std::span<const DWORD>(patched) : std::span<const DWORD>(bytes), mask);
      if (!bounded.empty()) patched = std::move(bounded);
    }
    if (!patched.empty()) {
      const HRESULT result = native->CreatePixelShader(patched.data(), replacement.ReleaseAndGetAddressOf());
      if (FAILED(result)) reshade::log::message(reshade::log::level::warning, "AC2: native blend variant rejected; keeping original shader.");
      if (SUCCEEDED(result)) {
        DWORD source = 0, dest = 0, operation = 0;
        native->GetRenderState(D3DRS_SRCBLEND, &source);
        native->GetRenderState(D3DRS_DESTBLEND, &dest);
        native->GetRenderState(D3DRS_BLENDOP, &operation);
        std::stringstream message;
        message << "AC2: native shader fix (lighting=" << unclamped << ", bound="
                << (mask == D3DSP_WRITEMASK_3 ? "alpha" : mask != 0 ? "RGB mask" : "none") << ") for shader 0x" << std::hex
                << renodx::utils::shader::GetCurrentPixelShaderHash(renodx::utils::command_action::GetShaderState(&context))
                << std::dec << " (src=" << source << ", dst=" << dest << ", op=" << operation << ")";
        reshade::log::message(reshade::log::level::info, message.str().c_str());
      }
    }
  }
  if (replacement == nullptr) return {};
  if (FAILED(native->SetPixelShader(replacement.Get()))) return {};

  if (data->up_vertices != nullptr) native->SetStreamSource(0, data->up_vertices, 0, data->up_stride);
  if constexpr (std::is_same_v<typename Context::ArgumentType, renodx::utils::command_action::DrawIndexedArguments>) {
    if (data->up_indices != nullptr) native->SetIndices(data->up_indices);
  }
  return {
      .post_callback = [](Context& context, const void* saved) {
        auto* native = reinterpret_cast<IDirect3DDevice9*>(context.cmd_list->get_native());
        auto* original = static_cast<IDirect3DPixelShader9*>(const_cast<void*>(saved));
        native->SetPixelShader(original);
        original->Release();
        auto* data = renodx::utils::data::Get<DeviceData>(context.cmd_list->get_device());
        if (data->up_vertices != nullptr) {
          native->SetStreamSource(0, nullptr, 0, 0);
          data->up_vertices = nullptr;
        }
        if constexpr (std::is_same_v<typename Context::ArgumentType, renodx::utils::command_action::DrawIndexedArguments>) {
          if (data->up_indices != nullptr) {
            native->SetIndices(nullptr);
            data->up_indices = nullptr;
          }
        }
      },
      .post_data = original.Detach(),
  };
};

// Call after mods::shader::Use so the explicit callbacks follow its shader
// replacement callbacks. All other native SM3 hashes use the wildcard guard.
template <typename Shaders>
inline void Use(DWORD reason, const Shaders& shaders) {
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::register_event<reshade::addon_event::bind_vertex_buffers>(OnBindVertexBuffers);
    reshade::register_event<reshade::addon_event::bind_index_buffer>(OnBindIndexBuffer);
    scheduled_shaders.clear();
    for (const auto& [hash, shader] : shaders) scheduled_shaders.insert(hash);
    renodx::utils::command_action::Register(OnCommand, {.command_types = renodx::utils::command_action::COMMAND_TYPE_DIRECT_DRAW});
    for (const auto hash : scheduled_shaders) {
      renodx::utils::command_action::Register(OnCommand, {.shader_hash = hash, .command_types = renodx::utils::command_action::COMMAND_TYPE_DIRECT_DRAW});
    }
    renodx::utils::command_action::Use(reason);
  } else if (reason == DLL_PROCESS_DETACH) {
    renodx::utils::command_action::Unregister(OnCommand);
    scheduled_shaders.clear();
    reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::unregister_event<reshade::addon_event::bind_vertex_buffers>(OnBindVertexBuffers);
    reshade::unregister_event<reshade::addon_event::bind_index_buffer>(OnBindIndexBuffer);
  }
}

}  // namespace ac2::native_alpha
