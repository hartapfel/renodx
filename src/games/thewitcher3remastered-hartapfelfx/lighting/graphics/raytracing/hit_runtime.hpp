// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "hit_bindings.hpp"
#include "hit_lifetime.hpp"

namespace witcher3graphics::raytracing::hits {
inline std::span<const uint8_t> clear_code;
inline std::array<std::span<const uint8_t>, 2> probe_clear_code;

inline bool BindConsumer(command_list* cmd, bool enabled, bool probe = false, bool allow_native_material = false) {
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  const auto* command = renodx::utils::data::Get<CommandData>(cmd);
  const auto* bindings = renodx::utils::data::Get<bindings::CommandData>(cmd);
  if (!data) return false;
  if (!enabled) { data->pool.Invalidate(); if (!allow_native_material) return false; }
  if (!command || !bindings || bindings->in_render_pass) return false;
  const auto roots = FindHitRoots(cmd->get_device(), bindings->compute.layout);
  HitTargets targets;
  if (roots.role != LayoutRole::consumer) return false;
  if (enabled && data->targets.Resolve(cmd, false, &targets,
          probe ? HitKind::global_probe : HitKind::reflection)
      && data->pool.BindConsumer(cmd, command->recording, targets, roots.context, roots.buffer)) return true;
  const auto* layout = renodx::utils::data::Get<LayoutData>(cmd->get_device());
  if (!allow_native_material || !layout || !layout->neutral_srv.handle) return false;
  const buffer_range context{layout->neutral, 0, 256};
  cmd->push_descriptors(shader_stage::compute, bindings->compute.layout, roots.context,
      {{}, 0, 0, 1, descriptor_type::constant_buffer, &context});
  cmd->push_descriptors(shader_stage::compute, bindings->compute.layout, roots.buffer,
      {{}, 0, 0, 1, descriptor_type::buffer_shader_resource_view, &layout->neutral_srv});
  return true;
}

inline bool OnHitRays(command_list* cmd, resource raygen, uint64_t raygen_offset, uint64_t raygen_size,
    resource miss, uint64_t miss_offset, uint64_t miss_size, uint64_t miss_stride,
    resource hit_group, uint64_t hit_group_offset, uint64_t hit_group_size, uint64_t hit_group_stride,
    resource callable, uint64_t callable_offset, uint64_t callable_size, uint64_t callable_stride,
    uint32_t width, uint32_t height, uint32_t depth) {
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  const auto* command = renodx::utils::data::Get<CommandData>(cmd);
  const auto* bindings = renodx::utils::data::Get<bindings::CommandData>(cmd);
  auto* control_data = renodx::utils::data::Get<ControlData>(cmd->get_device());
  const auto fallback = [&] { BoundWrites(cmd, shader_stage::raygen); return false; };
  if (!data || !command || !bindings || !control_data) return fallback();
  const pipeline_layout layout = bindings->compute.layout;
  const auto roots = FindHitRoots(cmd->get_device(), layout);
  if (roots.role != LayoutRole::producer) return fallback();
  // All native fallbacks remain safe even if an adapted state is currently
  // bound. A previous field's root address must never survive into a new trace.
  if (!BindInactive(cmd, layout, roots)) return fallback();
  if (bindings->in_render_pass || (controls.load(std::memory_order_acquire) & 5u) != 5u || !width || !height || !depth
      || raygen_size < D3D12_SHADER_IDENTIFIER_SIZE_IN_BYTES) return fallback();
  uint64_t raygen_address = raygen_offset;
  if (raygen.handle) {
    const auto desc = cmd->get_device()->get_resource_desc(raygen);
    if (desc.type != resource_type::buffer || raygen_offset > desc.buffer.size || raygen_size > desc.buffer.size - raygen_offset) return fallback();
    const uint64_t base = reinterpret_cast<ID3D12Resource*>(raygen.handle)->GetGPUVirtualAddress();
    if (!base || base > UINT64_MAX - raygen_offset) return fallback();
    raygen_address += base;
  }
  if (!raygen_address || (raygen_address & 63u)) return fallback();
  std::array<bool, 3> enabled{};
  bool incomplete = false;
  std::shared_ptr<HitSelection> selector;
  {
    std::lock_guard lock(control_data->mutex);
    const auto state = control_data->states.find(bindings->last_pipeline.handle);
    if (state != control_data->states.end() && state->second.root == layout.handle) {
      for (uint32_t i = 0; i < 3; ++i) {
        enabled[i] = (state->second.libraries & control_data->hit_libraries[i]) != 0;
        incomplete |= control_data->hit_libraries[i] && !enabled[i];
      }
      selector = state->second.selection;
    }
  }
  if (!std::ranges::any_of(enabled, [](bool value) { return value; })) return fallback();
  if (!selector) {
    selector = std::make_shared<HitSelection>(cmd->get_device());
    if (!selector->Initialize(reinterpret_cast<ID3D12StateObject*>(bindings->last_pipeline.handle), enabled)) return fallback();
    std::lock_guard lock(control_data->mutex);
    if (auto state = control_data->states.find(bindings->last_pipeline.handle); state != control_data->states.end()) state->second.selection = selector;
  }
  const HitSelectionDispatch selection{selector, raygen_address, roots.identifiers, roots.raygen};
  if (incomplete) data->pool.Invalidate();
  std::array<HitTargets, 3> targets;
  for (uint32_t i = 0; i < 3; ++i)
    if (enabled[i] && !data->targets.Resolve(cmd, true, &targets[i], HitKind(i))) data->pool.Invalidate();
  // Distinct families must not alias the same native output. The native shader
  // table can select either family, so such a layout cannot own both fields.
  for (uint32_t i = 0; i < 3; ++i) for (uint32_t j = i + 1; j < 3; ++j)
    if (targets[i].Valid() && targets[j].Valid()) for (const auto resource : targets[i].resources)
      if (std::ranges::find(targets[j].resources, resource) != targets[j].resources.end()) return fallback();
  bool dispatched = false;
  const auto issue = [&](auto&& next, uint32_t kind) -> void {
    if (kind == 3) {
      BindControls(cmd);
      cmd->dispatch_rays(raygen, raygen_offset, raygen_size, miss, miss_offset, miss_size, miss_stride,
          hit_group, hit_group_offset, hit_group_size, hit_group_stride,
          callable, callable_offset, callable_size, callable_stride, width, height, depth);
      dispatched = true;
      return;
    }
    bool continued = false;
    if (targets[kind].Valid()) {
      const bool published = data->pool.Produce(cmd, command->recording, targets[kind], roots.context + kind * 2, roots.buffer + kind * 2,
          kind == 0 ? clear_code : probe_clear_code[kind - 1], shader_stage::all_ray_tracing,
          [&] { continued = true; next(next, kind + 1); }, &selection);
      if (!published) for (const auto resource : targets[kind].resources) data->pool.Invalidate(resource);
    }
    if (!continued) next(next, kind + 1);
  };
  issue(issue, 0);
  BindInactive(cmd, layout, roots);
  // Once the command has executed through the addon API, never let ReShade
  // issue a second native copy, including a failed post-dispatch publication.
  return dispatched;
}
inline bool OnHitIndirect(command_list* cmd, indirect_command, resource, uint64_t, uint32_t, uint32_t) {
  const auto* bindings = renodx::utils::data::Get<bindings::CommandData>(cmd);
  if (!bindings) return false;
  const auto roots = FindHitRoots(cmd->get_device(), bindings->compute.layout);
  if (roots.role == LayoutRole::producer) {
    BindControls(cmd);
    BindInactive(cmd, bindings->compute.layout, roots);
  }
  // Native D3D12 indirect events do not expose their command signature. The
  // lifetime observer invalidates publication; leave the native work intact.
  return false;
}
inline void UseDispatch(DWORD reason) {
  if (reason == DLL_PROCESS_ATTACH) {
    manages_ray_dispatches = true;
    reshade::register_event<reshade::addon_event::dispatch_rays>(OnHitRays);
    reshade::register_event<reshade::addon_event::draw_or_dispatch_indirect>(OnHitIndirect);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::draw_or_dispatch_indirect>(OnHitIndirect);
    reshade::unregister_event<reshade::addon_event::dispatch_rays>(OnHitRays);
    manages_ray_dispatches = false;
  }
}
}  // namespace witcher3graphics::raytracing::hits
