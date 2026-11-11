// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once

#include "graphics/lighting/contact/integration.hpp"
#include "graphics/lighting/sun.hpp"
#include "graphics/raytracing/hit_runtime.hpp"
#include "graphics/raytracing/runtime.hpp"
#include "graphics/raytracing/hit_shaders.generated.hpp"
#include "graphics/raytracing/probe_global.generated.hpp"
#include "graphics/raytracing/probe_local.generated.hpp"
#include "../night/settings.hpp"
#include "../clouds/runtime.hpp"
#include "../fog/ray_local.generated.hpp"

namespace hartapfelfx::lighting {
namespace api = reshade::api;
namespace sun = witcher3graphics::sun;
namespace contact = witcher3graphics::contact;
namespace bindings = witcher3graphics::bindings;
namespace ray = witcher3graphics::raytracing;

inline float pbr = 1.f;
inline float soft = 1.f;
inline float diameter = .35f;
inline float contact_shadows = 1.f;
inline float reach = .3f;
// Counters distinguish inactive passes from missing bindings in live logs.
inline std::atomic_uint64_t surface_calls = 0, surface_replacements = 0, surface_fallbacks = 0;
inline std::atomic_uint32_t last_fallback_hash = 0;
inline uint32_t diagnostic_frames = 0;

struct __declspec(uuid("e8afdb27-1b29-493e-a869-bf47c0996e9b")) ControlsData {
  std::mutex mutex;
  std::array<float, 5> values{};
  Microsoft::WRL::ComPtr<ID3D12Resource> buffer;
};

inline void OnInitDevice(api::device* device) {
  if (device->get_api() == api::device_api::d3d12) renodx::utils::data::Create<ControlsData>(device);
}
inline void OnDestroyDevice(api::device* device) {
  if (renodx::utils::data::Get<ControlsData>(device)) renodx::utils::data::Delete<ControlsData>(device);
}

inline bool BindSurfaceMaterials(api::command_list* cmd, api::pipeline_layout layout, uint32_t index, bool compute) {
  auto* data = renodx::utils::data::Get<ControlsData>(cmd->get_device());
  if (!data) return false;
  const std::array values{pbr, contact_shadows, soft, diameter, reach};
  std::lock_guard lock(data->mutex);
  auto* command = renodx::utils::data::Get<clouds::runtime::CommandData>(cmd);
  if (!command) return false;
  if (!data->buffer || data->values != values) {
    // Controls are CPU uploads, independent of ray-hit producer publication.
    // Never overwrite a page already referenced by a GPU command recording.
    std::array<float, 64> aligned{};
    std::ranges::copy(values, aligned.begin());
    auto buffer = fog::runtime::UploadData(reinterpret_cast<ID3D12Device*>(cmd->get_device()->get_native()),
                                           aligned.data(), sizeof(aligned));
    if (!buffer) return false;
    data->buffer = std::move(buffer);
    data->values = values;
  }
  auto& pages = command->recording.lighting;
  if (pages.empty() || pages.back().Get() != data->buffer.Get()) pages.push_back(data->buffer);
  const api::buffer_range buffer{{reinterpret_cast<uint64_t>(data->buffer.Get())}, 0, 256};
  cmd->push_descriptors(compute ? api::shader_stage::compute : api::shader_stage::pixel, layout, index,
                        {{}, 0, 0, 1, api::descriptor_type::constant_buffer, &buffer});
  return true;
}

inline void OnPresent(api::device* device) {
  if (!sun::attempted && soft != 0.f) {
    sun::attempted = true;
    auto* image = reinterpret_cast<unsigned char*>(GetModuleHandleW(nullptr));
    if (const auto offset = sun::Validate(image)) sun::native_value = reinterpret_cast<float*>(image + offset);
    reshade::log::message(sun::native_value ? reshade::log::level::info : reshade::log::level::warning,
        sun::native_value ? "[HartapfelFX] Native traced light size validated."
                          : "[HartapfelFX] Traced light size unavailable; retaining native value.");
  }
  sun::diameter.Apply(sun::native_value, soft != 0.f, diameter);
  contact::NextFrame(device);
  if (++diagnostic_frames % 600 == 0) {
    const auto* contact_data = renodx::utils::data::Get<contact::DeviceData>(device);
    renodx::utils::log::d("HartapfelFX lighting: ", surface_calls.exchange(0), " active passes, ",
                        surface_replacements.exchange(0), " replacements, ", surface_fallbacks.exchange(0),
                        " fallbacks; ", contact_data ? contact_data->generated.load() : 0,
                        " contact fields generated; last fallback hash ", last_fallback_hash.load());
  }
}

enum ShaderFeature : uint32_t {
  Pbr = 1 << 0,
  Contact = 1 << 1,
  Soft = 1 << 2,
  Cloud = 1 << 3,
  Night = 1 << 4,
  Deferred = 1 << 5,
  HitMaterial = 1 << 6,
};

inline void OnInitHitLayout(api::device* device, uint32_t count, const api::pipeline_layout_param* parameters,
                            api::pipeline_layout layout) {
  auto* data = renodx::utils::data::Get<ray::hits::LayoutData>(device);
  if (!data || ray::hits::FindHitRoots(device, layout).role != ray::hits::LayoutRole::none) return;
  const fog::BindingLayout decoded(count, parameters);
  ray::hits::HitRoots roots;
  bool cloud = false, lighting = false;
  for (uint32_t index = 0; index < count; ++index) {
    if (decoded.parameters[index].table) continue;
    for (const auto& range : decoded.parameters[index].ranges) {
      if (range.count != 1 || range.dx_register_index != 0) continue;
      cloud |= range.dx_register_space == 72 && range.type == api::descriptor_type::buffer_shader_resource_view;
      lighting |= range.dx_register_space == 73 && range.type == api::descriptor_type::constant_buffer;
      if ((uint32_t(range.visibility) & uint32_t(api::shader_stage::compute)) == 0) continue;
      if (range.dx_register_space == 59 && range.type == api::descriptor_type::constant_buffer) roots.context = index;
      if (range.dx_register_space == 59 && range.type == api::descriptor_type::buffer_shader_resource_view) roots.buffer = index;
      if (range.dx_register_space == 55 && range.type == api::descriptor_type::buffer_shader_resource_view) roots.cloud = index;
    }
  }
  if (!cloud || !lighting || roots.context == UINT32_MAX || roots.buffer == UINT32_MAX || roots.cloud == UINT32_MAX) return;
  roots.role = ray::hits::LayoutRole::consumer;
  std::lock_guard lock(data->mutex);
  data->layouts.emplace(layout.handle, roots);
}

inline void ConfigureShaders(renodx::mods::shader::CustomShaders* shaders) {
  struct Shader {
    uint32_t hash, features;
    std::span<const uint8_t> code;
  };
  for (const auto& shader : {
           Shader{0xE6A77B56, Deferred | Pbr | Contact | Night, __0xE6A77B56},
           Shader{0x9A6F318E, Deferred | Pbr | Contact, __0x9A6F318E},
           Shader{0x8DBF022F, Pbr | Contact | Night, __0x8DBF022F},
           Shader{0x1015C01E, Pbr | Contact, __0x1015C01E},
           Shader{0xEAAAC84D, Pbr | Contact | Cloud | Night, __0xEAAAC84D},
           Shader{0xF751BDFE, Pbr | Contact | Cloud, __0xF751BDFE},
           Shader{0x36B38E59, Pbr | Contact, __0x36B38E59},
           Shader{0x8A2F5447, Pbr | Contact, __0x8A2F5447},
           Shader{0x448AD46F, Contact, __0x448AD46F},
           Shader{0x976455AC, Contact, __0x976455AC},
           Shader{0x56511D80, Contact | Night, __0x56511D80},
           Shader{0xF6DB9973, Contact, __0xF6DB9973},
           Shader{0x37E5D663, Contact, __0x37E5D663},
           Shader{0xCAD25EBF, Contact, __0xCAD25EBF},
           Shader{0x222E9D16, Contact, __0x222E9D16},
           Shader{0x3C73DFD9, Contact, __0x3C73DFD9},
           Shader{0x4A7A44D6, Soft | Cloud, __0x4A7A44D6},
           Shader{0x02320E1A, Deferred | Pbr | Cloud | Night | HitMaterial, __0x02320E1A},
           Shader{0xD2C88922, Deferred | Pbr | Cloud | Night | HitMaterial, __0xD2C88922},
       }) {
    auto& entry = (*shaders)[shader.hash];
    entry.crc32 = shader.hash;
    entry.code = shader.code;
    entry.on_inject = [](auto*) { return false; };
    entry.on_replace = [features = shader.features, hash = shader.hash](api::command_list* cmd) {
      const bool compute = (features & Deferred) != 0;
      auto* command = renodx::utils::shader::GetCurrentState(cmd);
      auto* state = compute ? renodx::utils::shader::GetCurrentComputeState(command)
                            : renodx::utils::shader::GetCurrentPixelState(command);
      if (!state) return false;
      const bool use_pbr = (features & Pbr) && pbr != 0.f;
      const bool use_contact = (features & Contact) && contact_shadows != 0.f;
      const bool use_soft = (features & Soft) && soft != 0.f;
      const bool use_clouds = (features & Cloud) && clouds::mode > .5f;
      const bool use_night = (features & Night) && witcher::night::installed
          && witcher::night::sky_multiplier.load(std::memory_order_relaxed) != 1.f
          && witcher::night::night_weight.load(std::memory_order_relaxed) > 0.f;
      if (use_pbr || use_contact || use_soft) ++surface_calls;
      // Probe shading precedes the main sun draw, and reflection shading has
      // no sun observer. Publish the current cloud column before either hit
      // shader samples it, then bind its material and lighting inputs.
      if (use_clouds && (features & HitMaterial)) clouds::runtime::PrepareShadow(cmd, true);
      if ((use_pbr || use_contact || use_soft || use_clouds || use_night) && state->pipeline_details
          && state->pipeline_details->initialized_replacement && state->pipeline_details->replacement_pipeline.handle) {
        const auto* roots = renodx::utils::data::Get<bindings::CommandData>(cmd);
        if (roots) {
          const auto layout = compute ? roots->compute.layout : roots->graphics.layout;
          const int index = fog::runtime::RootIndex(cmd, layout, api::descriptor_type::constant_buffer, 0, 73);
          const bool contact_bound = index >= 0 && (!(features & Contact)
              || (compute ? contact::Bind(cmd, use_contact, reach) : contact::BindForward(cmd, use_contact)));
          const bool material_bound = contact_bound && (!(features & HitMaterial)
              || ray::hits::BindConsumer(cmd, use_pbr, hash == 0xD2C88922, true));
          if (material_bound && (!(features & Cloud) || clouds::runtime::PrepareShadowReceiver(cmd, compute))
              && BindSurfaceMaterials(cmd, layout, uint32_t(index), compute)) {
            if (use_pbr || use_contact || use_soft) ++surface_replacements;
            return true;
          }
        }
      }
      if (use_pbr || use_contact || use_soft) {
        ++surface_fallbacks;
        last_fallback_hash.store(hash);
      }
      return false;
    };
  }
  contact::code = {__0xF3D40020, __0xF3D40021, __0xF3D40022, __0xF3D40023, __0xF3D40024};
  ray::hits::clear_code = __0xF3D90001;
  ray::hits::probe_clear_code = {__0xF3D90002, __0xF3D90003};
  using namespace ray::bytecode;
  const auto bytes = [](const auto& code) {
    return std::span(reinterpret_cast<const uint8_t*>(code), sizeof(code));
  };
  static constexpr const wchar_t* pt_exports[] = {L"PTRGSFinal", L"PTRGSWithSERFinal"};
  const auto pt_cloud = clouds::native::RayLibrary(0x47BC87E1u);
  ray::replacements = {
      {0xCD37BD3Fu, native_size_CD37BD3F, bytes(shader_CD37BD3F), ray::LibraryPurpose::reflection},
      {0xB6F9CABDu, native_size_B6F9CABD, bytes(shader_B6F9CABD), ray::LibraryPurpose::global_probe},
      {0xCC3F1F1Cu, native_size_CC3F1F1C, bytes(shader_CC3F1F1C), ray::LibraryPurpose::local_probe},
      {0x25AB4BF4u, 10616u, fog::rays::local_code, ray::LibraryPurpose::fog},
      {0x47BC87E1u, 231144u, fog::rays::local_code, ray::LibraryPurpose::fog, pt_exports},
      {renodx::utils::hash::ComputeCRC32(pt_cloud.data(), pt_cloud.size()), pt_cloud.size(), fog::rays::local_code,
       ray::LibraryPurpose::fog, pt_exports},
  };
}

inline void BindPathMaterials(api::command_list* cmd) {
  ray::controls.store(pbr != 0.f ? 5u : 1u, std::memory_order_release);
  const auto* roots = renodx::utils::data::Get<bindings::CommandData>(cmd);
  if (!roots) return;
  renodx::utils::pipeline_layout::GetPipelineLayoutData(roots->compute.layout, [&](const auto* layout) {
    for (uint32_t index = 0; index < layout->params.size(); ++index) {
      const auto& parameter = layout->params[index];
      if (parameter.type != api::pipeline_layout_param_type::push_constants) continue;
      const auto& range = parameter.push_constants;
      if (range.dx_register_space != 56 || range.dx_register_index != 0 || range.count != 4) continue;
      const std::array values{1.f, 1.f, 0.f, float(pbr != 0.f)};
      cmd->push_constants(api::shader_stage::all_ray_tracing, roots->compute.layout,
                          index, 0, uint32_t(values.size()), values.data());
      break;
    }
  });
}

inline bool OnIndirect(api::command_list* cmd, api::indirect_command type, api::resource, uint64_t, uint32_t, uint32_t) {
  if (type == api::indirect_command::dispatch_rays) {
    clouds::runtime::PrepareRayShadow(cmd);
    BindPathMaterials(cmd);
  }
  return false;
}

inline HRESULT AdaptRayState(api::device* device, const D3D12_STATE_OBJECT_DESC* descriptor, ID3D12StateObject* existing,
                             REFIID iid, void** output, const clouds::ray_hooks::NativeCall& call) {
  return ray::CreateOnDevice(device, descriptor, existing, iid, output,
      [&](const auto* adapted, REFIID, void**) { return call(adapted); });
}

inline void Use(DWORD reason) {
  if (reason != DLL_PROCESS_ATTACH && reason != DLL_PROCESS_DETACH) return;
  contact::active = (reason == DLL_PROCESS_ATTACH ? &contact_shadows : nullptr);
  clouds::runtime::bind_path_materials = reason == DLL_PROCESS_ATTACH ? &BindPathMaterials : nullptr;
  clouds::ray_hooks::adapt_lighting = reason == DLL_PROCESS_ATTACH ? &AdaptRayState : nullptr;
  bindings::Use(reason, false);  // The shader module already owns the shared caches.
  ray::UseControls(reason, false);
  ray::hits::UseLayouts(reason);
  if (reason == DLL_PROCESS_ATTACH)
    reshade::register_event<reshade::addon_event::init_pipeline_layout>(OnInitHitLayout);
  else
    reshade::unregister_event<reshade::addon_event::init_pipeline_layout>(OnInitHitLayout);
  ray::hits::UseLifetime(reason);
  witcher3graphics::water::submission::UseRuntime(reason);
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::register_event<reshade::addon_event::init_device>(ray::PopulateLibraryMasks);
    reshade::register_event<reshade::addon_event::draw_or_dispatch_indirect>(OnIndirect);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::unregister_event<reshade::addon_event::init_device>(ray::PopulateLibraryMasks);
    reshade::unregister_event<reshade::addon_event::draw_or_dispatch_indirect>(OnIndirect);
  }
  contact::Use(reason, false);  // HartapfelFX extends the shared layout once.
}
}  // namespace hartapfelfx::lighting
