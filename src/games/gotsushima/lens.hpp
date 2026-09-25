/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <array>
#include <map>
#include <memory>
#include <mutex>
#include <vector>

#include "../../utils/descriptor.hpp"
#include "../../utils/render.hpp"
#include "../../utils/state.hpp"
#include "./shared.h"

namespace gotsushima::lens {

inline ShaderInjectData* settings = nullptr;

// RenderPass restores fixed-function state and descriptor tables. D3D12 also
// needs its root constants and root descriptors replayed after a different
// graphics root signature. Keep these local to this injected game pass.
struct RootDescriptorDeleter {
  void operator()(reshade::api::descriptor_table_update* value) const {
    renodx::utils::descriptor::DestroyDescriptorTableUpdates(value, 1);
  }
};
struct __declspec(uuid("21a1eefc-9d82-48eb-a515-c3a723790d94")) CommandData {
  // Output encoding can create a separate branch; it does not modify the gamma scene
  // later used for HUD composition. Continue only within this recording.
  uint64_t effects_scene = 0;
  bool effects_pending = false;
  bool output_started = false;
  float output_fallback = 0.f;
  reshade::api::pipeline_layout layout = {};
  std::map<uint32_t, std::vector<uint32_t>> constants;
  std::map<uint32_t, std::unique_ptr<reshade::api::descriptor_table_update, RootDescriptorDeleter>> descriptors;
  std::map<uint32_t, reshade::api::descriptor_table> tables;

  void SetLayout(reshade::api::pipeline_layout next) {
    if (layout == next) return;
    layout = next;
    constants.clear();
    descriptors.clear();
    tables.clear();
  }
};

struct Target {
  reshade::api::resource copy = {};
  renodx::utils::render::RenderPass pass;
};
struct __declspec(uuid("278e677b-eb36-4d2c-8543-721872723be5")) DeviceData {
  std::recursive_mutex mutex;
  std::map<uint64_t, std::unique_ptr<Target>> targets;
  uint32_t width = 0;
  uint32_t height = 0;
  uint64_t effects_scene = 0;
  reshade::api::resource scene_target = {};
  // The first scene-only output can also use a different command list. This
  // reservation is only for output encoding, never for choosing a HUD target.
  reshade::api::command_list* scene_output_owner = nullptr;
  // One additional scene-only output branch may be recorded on another list when
  // DLSS FG is active and the HUD is hidden. Never use this token for HUD draws.
  reshade::api::command_list* output_owner = nullptr;
  bool logged = false;
  bool logged_fallback = false;
  bool logged_continuation = false;
  bool logged_output_continuation = false;
  bool logged_early_ui = false;
  bool warned = false;
};

inline reshade::api::pipeline_layout ReplacementLayout(reshade::api::pipeline_layout layout) {
  renodx::utils::pipeline_layout::GetPipelineLayoutData(layout, [&layout](const auto* data) {
    if (data->replacement_layout.handle != 0) layout = data->replacement_layout;
  });
  return layout;
}

inline void OnInitCommandList(reshade::api::command_list* cmd_list) {
  cmd_list->create_private_data<CommandData>();
}
inline void OnDestroyCommandList(reshade::api::command_list* cmd_list) {
  if (auto* data = cmd_list->get_device()->get_private_data<DeviceData>()) {
    const std::lock_guard lock(data->mutex);
    if (data->scene_output_owner == cmd_list) data->scene_output_owner = nullptr;
    if (data->output_owner == cmd_list) data->output_owner = nullptr;
  }
  cmd_list->destroy_private_data<CommandData>();
}
inline void OnResetCommandList(reshade::api::command_list* cmd_list) {
  if (auto* data = cmd_list->get_device()->get_private_data<DeviceData>()) {
    const std::lock_guard lock(data->mutex);
    if (data->scene_output_owner == cmd_list) data->scene_output_owner = nullptr;
    if (data->output_owner == cmd_list) data->output_owner = nullptr;
  }
  if (auto* data = cmd_list->get_private_data<CommandData>()) {
    data->effects_pending = false;
    data->output_started = false;
    data->output_fallback = 0.f;
    data->SetLayout({});
  }
}
inline void OnPushConstants(reshade::api::command_list* cmd_list, reshade::api::shader_stage stages,
                            reshade::api::pipeline_layout layout, uint32_t param,
                            uint32_t first, uint32_t count, const void* values) {
  if ((stages & reshade::api::shader_stage::all_graphics) == reshade::api::shader_stage(0)) return;
  auto* data = cmd_list->get_private_data<CommandData>();
  if (data == nullptr) return;
  data->SetLayout(layout);
  auto& stored = data->constants[param];
  stored.resize(std::max<size_t>(stored.size(), first + count));
  std::copy_n(static_cast<const uint32_t*>(values), count, stored.begin() + first);
}
inline void OnPushDescriptors(reshade::api::command_list* cmd_list, reshade::api::shader_stage stages,
                              reshade::api::pipeline_layout layout, uint32_t param,
                              const reshade::api::descriptor_table_update& update) {
  if ((stages & reshade::api::shader_stage::all_graphics) == reshade::api::shader_stage(0)) return;
  auto* data = cmd_list->get_private_data<CommandData>();
  if (data == nullptr) return;
  data->SetLayout(layout);
  // D3D12 root descriptors contain one descriptor, with no array offset.
  data->descriptors[param].reset(renodx::utils::descriptor::CloneDescriptorTableUpdates(&update, 1));
}
inline void OnBindDescriptorTables(reshade::api::command_list* cmd_list, reshade::api::shader_stage stages,
                                   reshade::api::pipeline_layout layout, uint32_t first,
                                   uint32_t count, const reshade::api::descriptor_table* tables) {
  if ((stages & reshade::api::shader_stage::all_graphics) == reshade::api::shader_stage(0)) return;
  auto* data = cmd_list->get_private_data<CommandData>();
  if (data == nullptr) return;
  data->SetLayout(layout);
  for (uint32_t i = 0; i < count; ++i) data->tables[first + i] = tables[i];
}

inline void OnInitDevice(reshade::api::device* device) {
  device->create_private_data<DeviceData>();
}
inline void OnDestroyResource(reshade::api::device* device, reshade::api::resource resource) {
  auto* data = device->get_private_data<DeviceData>();
  if (data == nullptr) return;
  const std::lock_guard lock(data->mutex);
  if (data->scene_target == resource) data->scene_target = {};
  const auto found = data->targets.find(resource.handle);
  if (found == data->targets.end()) return;
  auto target = std::move(found->second);
  data->targets.erase(found);
  // The scratch texture follows the lifetime of the game target whose queue
  // ordering also protects its reuse. Never recycle descriptors across targets.
  target->pass.DestroyAll(device);
  device->destroy_resource(target->copy);
}
inline void OnDestroyDevice(reshade::api::device* device) {
  auto* data = device->get_private_data<DeviceData>();
  if (data == nullptr) return;
  while (!data->targets.empty()) OnDestroyResource(device, {data->targets.begin()->first});
  device->destroy_private_data<DeviceData>();
}
inline void OnInitSwapchain(reshade::api::swapchain* swapchain, bool) {
  auto* data = swapchain->get_device()->get_private_data<DeviceData>();
  if (data == nullptr) return;
  const auto desc = swapchain->get_device()->get_resource_desc(swapchain->get_back_buffer(0));
  const std::lock_guard lock(data->mutex);
  data->width = desc.texture.width;
  data->height = desc.texture.height;
  ++data->effects_scene;
  data->scene_target = {};
  data->scene_output_owner = nullptr;
  data->output_owner = nullptr;
}
inline bool EffectsActive() {
  return settings->tone_map_type == 1.f
         && (settings->sharpening > 0.f || settings->film_grain > 0.f
             || (settings->chromatic_aberration_enabled != 0.f
                 && settings->chromatic_aberration_intensity > 0.f));
}
inline bool OnScene(reshade::api::command_list* cmd_list) {
  if (auto* data = cmd_list->get_device()->get_private_data<DeviceData>()) {
    const std::lock_guard lock(data->mutex);
    ++data->effects_scene;
    data->scene_target = {};
    if (auto* state = renodx::utils::state::GetCurrentState(cmd_list);
        state != nullptr && state->render_targets.size() == 1) {
      data->scene_target = cmd_list->get_device()->get_resource_from_view(state->render_targets[0]);
    }
    data->scene_output_owner = EffectsActive() ? cmd_list : nullptr;
    data->output_owner = nullptr;
    if (auto* command = cmd_list->get_private_data<CommandData>()) {
      command->effects_scene = data->effects_scene;
      command->effects_pending = EffectsActive();
      command->output_started = false;
      command->output_fallback = 0.f;
    }
  }
  return true;
}
inline bool OnOutput(reshade::api::command_list* cmd_list) {
  auto* command = cmd_list->get_private_data<CommandData>();
  if (command == nullptr) return true;
  command->output_fallback = 0.f;
  if (auto* data = cmd_list->get_device()->get_private_data<DeviceData>()) {
    const std::lock_guard lock(data->mutex);
    // DLSS FG can encode a scene-only branch before HUD composition, then
    // encodes the visible branch afterward. The first encode must not consume
    // the untouched gamma scene's effects. The HUD continuation is local to
    // this recording; one extra scene-only output can cross command lists.
    // A new scene invalidates both forms of continuation.
    const bool initial_output = data->scene_output_owner != nullptr;
    const bool continued_output = data->output_owner != nullptr;
    const bool local_pending = command->effects_pending
                               && command->effects_scene == data->effects_scene;
    const bool pending = initial_output || continued_output || local_pending;
    command->output_fallback = pending && EffectsActive() ? 1.f : 0.f;
    data->scene_output_owner = nullptr;
    // The first encode reserves one more output for this scene. Consuming that
    // reservation must not renew it, even if the outputs use different lists.
    data->output_owner = !continued_output
                                 && (initial_output || (local_pending && !command->output_started))
                                 && command->output_fallback != 0.f
                             ? cmd_list : nullptr;
    if (continued_output && command->output_fallback != 0.f && !data->logged_output_continuation) {
      reshade::log::message(reshade::log::level::info, "[Ghost Effects] Second scene-only output received effects with no HUD composition.");
      data->logged_output_continuation = true;
    }
    command->effects_scene = data->effects_scene;
    // Consuming the cross-list output reservation does not grant permission
    // to modify a later HUD target on that otherwise unrelated recording.
    command->effects_pending = local_pending && command->output_fallback != 0.f;
    command->output_started = true;
    if (command->output_fallback != 0.f && !data->logged_fallback) {
      reshade::log::message(reshade::log::level::info, "[Ghost Effects] Scene-only output effects active after upscaling, before display encoding (HUD hidden / frame-generation branch).");
      data->logged_fallback = true;
    }
  }
  return true;
}

inline bool InjectOutput(reshade::api::command_list* cmd_list) {
  auto* command = cmd_list->get_private_data<CommandData>();
  auto* shader_state = renodx::utils::shader::GetCurrentState(cmd_list);
  if (command == nullptr || shader_state == nullptr) return true;
  auto* pixel = renodx::utils::shader::GetCurrentPixelState(shader_state);
  if (pixel == nullptr || pixel->pipeline_details == nullptr) return true;
  auto* details = pixel->pipeline_details;
  renodx::utils::shader::BuildReplacementPipeline(details);
  if (details->injection_layout == 0u || details->injection_index == -1) return true;

  // The shared user settings are read by all recording threads. Never put a
  // per-draw decision there: another output/scene callback can overwrite it
  // before mods::shader uploads the constants. Upload a local snapshot instead.
  ShaderInjectData output_settings = *settings;
  output_settings.post_effects_output_fallback = command->output_fallback;
  renodx::utils::constants::PushShaderInjections(
      cmd_list, details->injection_layout, static_cast<uint32_t>(details->injection_index), false,
      {reinterpret_cast<float*>(&output_settings), sizeof(output_settings) / sizeof(float)},
      details->injection_constant_buffer_offset);
  return false;  // This draw's constants are already uploaded.
}

inline bool BeforeHUD(reshade::api::command_list* cmd_list) {
  using namespace reshade::api;
  auto* device = cmd_list->get_device();
  auto* data = device->get_private_data<DeviceData>();
  auto* roots = cmd_list->get_private_data<CommandData>();
  auto* state = renodx::utils::state::GetCurrentState(cmd_list);
  if (data == nullptr || roots == nullptr || state == nullptr || device->get_api() != device_api::d3d12) return true;
  const std::lock_guard lock(data->mutex);
  // A same-size map layer on another recording is not necessarily the scene.
  // Only the list that recorded it (or its own output branch) may inject before HUD.
  const bool pending = roots->effects_pending && roots->effects_scene == data->effects_scene;
  const bool continued_output = pending && roots->output_started;
  if ((!pending && data->scene_output_owner == nullptr && data->output_owner == nullptr)
      || state->render_targets.size() != 1 || roots->layout.handle == 0) return true;
  const auto target_resource = device->get_resource_from_view(state->render_targets[0]);
  if (target_resource.handle == 0) return true;
  const auto desc = device->get_resource_desc(target_resource);
  // The live capture's post-upscale HUD composition target. Offscreen UI
  // textures rendered before the scene, smaller layers and final output are excluded.
  const bool expected_format = settings->sdr_output != 0.f
                                   ? desc.texture.format == format::r8g8b8a8_unorm
                                   : desc.texture.format == format::r10g10b10a2_unorm;
  if (desc.type != resource_type::texture_2d || desc.texture.width != data->width
      || desc.texture.height != data->height || !expected_format
      || desc.texture.samples != 1 || desc.texture.levels != 1 || desc.texture.depth_or_layers != 1) return true;
  // The map draws UI tiles directly into the pre-upscale scene target. There
  // is no clean post-upscale scene to process in that branch: exclude it from
  // both the in-place pass and all output fallbacks. Gameplay HUD uses a separate
  // composition target in the captured FG-on/off paths.
  if (target_resource == data->scene_target) {
    data->scene_output_owner = nullptr;
    data->output_owner = nullptr;
    ++data->effects_scene;
    roots->effects_pending = false;
    if (!data->logged_early_ui) {
      reshade::log::message(reshade::log::level::info, "[Ghost Effects] Early map/UI composition excluded from post-upscale effects and output fallbacks.");
      data->logged_early_ui = true;
    }
    return true;
  }
  // A full-resolution HUD draw means a later output can no longer assume its
  // input is scene-only, even if that HUD was recorded on a different list.
  data->scene_output_owner = nullptr;
  if (pending || data->output_owner != nullptr) ++data->effects_scene;
  data->output_owner = nullptr;
  if (!pending) return true;
  roots->effects_pending = false;
  if (!EffectsActive()) return true;

  auto& target = data->targets[target_resource.handle];
  if (!target) {
    target = std::make_unique<Target>();
    auto copy_desc = desc;
    copy_desc.usage = resource_usage::copy_dest | resource_usage::shader_resource;
    copy_desc.flags = resource_flags::none;
    copy_desc.heap = memory_heap::gpu_only;
    if (!device->create_resource(copy_desc, nullptr, resource_usage::shader_resource, &target->copy)) {
      data->targets.erase(target_resource.handle);
      if (!data->warned) {
        reshade::log::message(reshade::log::level::warning, "[Ghost Effects] Could not create scene copy; effect skipped.");
        data->warned = true;
      }
      return true;
    }
    device->set_resource_name(target->copy, "Ghost post-upscale effects scene copy");
    target->pass.pipeline_subobjects.vertex_shader = __0x7C4BC81C;
    target->pass.pipeline_subobjects.pixel_shader = __0xE4B02509;
    target->pass.render_target_slots.resources = {target_resource};
    target->pass.render_target_slots.view_descs = {resource_view_desc(resource_view_type::texture_2d, desc.texture.format, 0, 1, 0, 1)};
    target->pass.shader_resource_slots.resources = {target->copy};
    target->pass.shader_resource_slots.view_descs = target->pass.render_target_slots.view_descs;
    target->pass.use_render_pass = false;
    target->pass.revert_state_after_render = false;
  }
  auto saved = *state;
  const auto graphics_pipeline = renodx::utils::shader::GetCurrentPixelState(
      renodx::utils::shader::GetCurrentState(cmd_list))->pipeline;
  const std::array resources = {target_resource, target->copy};
  const std::array before = {resource_usage::render_target, resource_usage::shader_resource};
  const std::array copying = {resource_usage::copy_source, resource_usage::copy_dest};
  cmd_list->barrier(2, resources.data(), before.data(), copying.data());
  cmd_list->copy_resource(target_resource, target->copy);
  cmd_list->barrier(2, resources.data(), copying.data(), before.data());
  target->pass.push_constants[{13, 50}] = std::span<const float>(
      reinterpret_cast<const float*>(settings), sizeof(*settings) / sizeof(float));
  const bool rendered = target->pass.Render(cmd_list);

  // Restore the actual cloned root signatures used by mods::shader, not the
  // original signatures observed in API events. Switching to the latter would
  // invalidate the game's root values before its HUD draw.
  saved.graphics_pipeline_layout = ReplacementLayout(saved.graphics_pipeline_layout);
  saved.compute_pipeline_layout = ReplacementLayout(saved.compute_pipeline_layout);
  saved.Apply(cmd_list);
  cmd_list->bind_pipeline(pipeline_stage::all_graphics, graphics_pipeline);
  const auto layout = ReplacementLayout(roots->layout);
  for (const auto& [param, table] : roots->tables) {
    if (table.handle != 0) cmd_list->bind_descriptor_tables(shader_stage::all_graphics, layout, param, 1, &table);
  }
  for (const auto& [param, values] : roots->constants) {
    cmd_list->push_constants(shader_stage::all_graphics, layout, param, 0, static_cast<uint32_t>(values.size()), values.data());
  }
  for (const auto& [param, update] : roots->descriptors) {
    if (update && update->descriptors) cmd_list->push_descriptors(shader_stage::all_graphics, layout, param, *update);
  }
  if (rendered && continued_output && !data->logged_continuation) {
    reshade::log::message(reshade::log::level::info, "[Ghost Effects] Pre-HUD effects continued after the frame-generation output branch.");
    data->logged_continuation = true;
  }
  if (rendered && !data->logged) {
    reshade::log::message(reshade::log::level::info, "[Ghost Effects] Post-upscale scene pass active before full-resolution HUD composition.");
    data->logged = true;
  } else if (!rendered && !data->warned) {
    reshade::log::message(reshade::log::level::warning, "[Ghost Effects] Post-upscale pass failed; scene left unchanged.");
    data->warned = true;
  }
  return true;
}

inline void Use(DWORD reason, ShaderInjectData* injection) {
  settings = injection;
  renodx::utils::resource::Use(reason);
  renodx::utils::state::Use(reason);
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::register_event<reshade::addon_event::destroy_resource>(OnDestroyResource);
    reshade::register_event<reshade::addon_event::init_command_list>(OnInitCommandList);
    reshade::register_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
    reshade::register_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
    reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
    reshade::register_event<reshade::addon_event::push_constants>(OnPushConstants);
    reshade::register_event<reshade::addon_event::push_descriptors>(OnPushDescriptors);
    reshade::register_event<reshade::addon_event::bind_descriptor_tables>(OnBindDescriptorTables);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::unregister_event<reshade::addon_event::destroy_resource>(OnDestroyResource);
    reshade::unregister_event<reshade::addon_event::init_command_list>(OnInitCommandList);
    reshade::unregister_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
    reshade::unregister_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
    reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
    reshade::unregister_event<reshade::addon_event::push_constants>(OnPushConstants);
    reshade::unregister_event<reshade::addon_event::push_descriptors>(OnPushDescriptors);
    reshade::unregister_event<reshade::addon_event::bind_descriptor_tables>(OnBindDescriptorTables);
  }
}
}  // namespace gotsushima::lens
