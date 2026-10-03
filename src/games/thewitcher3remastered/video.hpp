/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <map>
#include <memory>
#include <mutex>
#include "./motion_blur.hpp"

// Keep the SDR movie separate from Scaleform UI. Expand it only at HDR output,
// after its last UNORM write and before subtitles, so neither UI white nor
// scene tone mapping can change its display mapping.
namespace witcher::video {
using namespace reshade::api;
inline ShaderInjectData* settings = nullptr;

struct Target {
  resource texture = {};
  resource_view srv = {}, rtv = {};
  uint64_t frame = 0;
  bool Create(device* dev, uint32_t width, uint32_t height) {
    return dev->create_resource(
               resource_desc(width, height, 1, 1, format::r8g8b8a8_unorm, 1,
                             memory_heap::gpu_only, resource_usage::render_target | resource_usage::shader_resource),
               nullptr, resource_usage::shader_resource_pixel, &texture)
           && dev->create_resource_view(texture, resource_usage::render_target,
                                        resource_view_desc(format::r8g8b8a8_unorm), &rtv)
           && dev->create_resource_view(texture, resource_usage::shader_resource,
                                        resource_view_desc(format::r8g8b8a8_unorm), &srv);
  }
  void Destroy(device* dev) {
    if (srv.handle) dev->destroy_resource_view(srv);
    if (rtv.handle) dev->destroy_resource_view(rtv);
    if (texture.handle) dev->destroy_resource(texture);
  }
};
struct __declspec(uuid("54b58f8e-4194-4778-97af-96029fdc33cc")) DeviceData {
  std::recursive_mutex mutex;
  std::map<uint64_t, std::unique_ptr<Target>> targets;
  Target empty;
  uint64_t frame = 1;
};
struct __declspec(uuid("1d7b2925-a40b-4543-a65b-321ae33f0d6a")) CommandData {
  Target* target = nullptr;
  resource_view original_rtv = {}, original_dsv = {};
};

inline void OnInitDevice(device* dev) {
  if (dev->get_api() == device_api::d3d12) dev->create_private_data<DeviceData>();
}

// Called with DeviceData::mutex held, after the game's queues exist.
inline bool PrepareEmpty(command_list* cmd, DeviceData* data) {
  if (data->empty.srv.handle) return true;
  if (!data->empty.Create(cmd->get_device(), 1, 1)) {
    data->empty.Destroy(cmd->get_device());
    data->empty = {};
    return false;
  }
  const float transparent[4] = {};
  cmd->barrier(data->empty.texture, resource_usage::shader_resource_pixel, resource_usage::render_target);
  cmd->clear_render_target_view(data->empty.rtv, transparent);
  cmd->barrier(data->empty.texture, resource_usage::render_target, resource_usage::shader_resource_pixel);
  return true;
}

inline bool OnDraw(command_list* cmd) {
  if (!settings || settings->tone_map_type != 1.f) return true;
  auto* dev = cmd->get_device();
  auto* data = dev->get_private_data<DeviceData>();
  auto* command = cmd->get_private_data<CommandData>();
  const auto* state = renodx::utils::swapchain::GetCurrentState(cmd);
  const auto* shader_state = renodx::utils::shader::GetCurrentState(cmd);
  if (!data || !command || !state || !shader_state
      || command->target || state->current_render_targets.size() != 1) return true;
  const auto* pipeline = shader_state->stage_states[renodx::utils::shader::PIXEL_INDEX].pipeline_details;
  // Redirect only when this native layout also supports the output's movie SRV.
  if (!pipeline || !pipeline->injection_layout.handle
      || !pipeline->descriptor_push_locations.contains({descriptor_type::shader_resource_view, 0u, 51u})) return true;
  const auto source = renodx::utils::resource::GetResourceFromView(dev, state->current_render_targets[0]);
  if (!source.handle) return true;
  const auto desc = dev->get_resource_desc(source);
  if (desc.type != resource_type::texture_2d || desc.texture.samples != 1
      || desc.texture.format != format::r8g8b8a8_unorm) return true;
  const std::lock_guard lock(data->mutex);
  if (!PrepareEmpty(cmd, data)) return true;
  auto found = data->targets.find(source.handle);
  if (found == data->targets.end()) {
    auto target = std::make_unique<Target>();
    if (!target->Create(dev, desc.texture.width, desc.texture.height)) {
      target->Destroy(dev);
      return true;
    }
    found = data->targets.emplace(source.handle, std::move(target)).first;
  }
  command->target = found->second.get();
  command->original_rtv = state->current_render_targets[0];
  command->original_dsv = state->current_depth_stencil;
  cmd->barrier(command->target->texture, resource_usage::shader_resource_pixel, resource_usage::render_target);
  if (command->target->frame != data->frame) {
    const float transparent[4] = {};
    cmd->clear_render_target_view(command->target->rtv, transparent);
  }
  // Same format, dimensions, viewport, vertex data, samplers and blend state.
  // The shared shader callback performs the actual native video draw.
  cmd->bind_render_targets_and_depth_stencil(1, &command->target->rtv, command->original_dsv);
  return true;
}

inline void OnDrawn(command_list* cmd) {
  auto* data = cmd->get_device()->get_private_data<DeviceData>();
  auto* command = cmd->get_private_data<CommandData>();
  if (!data || !command || !command->target) return;
  const std::lock_guard lock(data->mutex);
  cmd->barrier(command->target->texture, resource_usage::render_target, resource_usage::shader_resource_pixel);
  cmd->bind_render_targets_and_depth_stencil(1, &command->original_rtv, command->original_dsv);
  command->target->frame = data->frame;
  *command = {};
}

inline resource_view GetView(command_list* cmd) {
  auto* dev = cmd->get_device();
  auto* data = dev->get_private_data<DeviceData>();
  auto* bindings = dev->get_private_data<witcher::motion::DeviceData>();
  const auto* roots = cmd->get_private_data<witcher::motion::CommandData>();
  if (!data) return {};
  {
    const std::lock_guard lock(data->mutex);
    if (!PrepareEmpty(cmd, data)) return {};
  }
  if (!bindings || !roots) return data->empty.srv;
  const std::scoped_lock lock(data->mutex, bindings->mutex);
  const auto ui = witcher::motion::FindBinding(dev, *bindings, roots->graphics, descriptor_type::shader_resource_view, 1);
  if (!ui || !ui->resource_view.handle) return data->empty.srv;
  const auto source = renodx::utils::resource::GetResourceFromView(dev, ui->resource_view);
  const auto found = data->targets.find(source.handle);
  return found != data->targets.end() && found->second->frame == data->frame
             ? found->second->srv : data->empty.srv;
}

inline void OnPresent(command_queue* queue, swapchain*, const rect*, const rect*, uint32_t, const rect*) {
  if (auto* data = queue->get_device()->get_private_data<DeviceData>()) {
    const std::lock_guard lock(data->mutex);
    ++data->frame;
  }
}
inline void OnDestroyResource(device* dev, resource source) {
  if (auto* data = dev->get_private_data<DeviceData>()) {
    const std::lock_guard lock(data->mutex);
    const auto found = data->targets.find(source.handle);
    if (found != data->targets.end()) {
      found->second->Destroy(dev);
      data->targets.erase(found);
    }
  }
}
inline void OnDestroyDevice(device* dev) {
  if (auto* data = dev->get_private_data<DeviceData>()) {
    for (auto& [source, target] : data->targets) target->Destroy(dev);
    data->empty.Destroy(dev);
    dev->destroy_private_data<DeviceData>();
  }
}
inline void OnInitCommand(command_list* cmd) {
  if (cmd->get_device()->get_api() == device_api::d3d12) cmd->create_private_data<CommandData>();
}
inline void OnDestroyCommand(command_list* cmd) { cmd->destroy_private_data<CommandData>(); }
inline void OnResetCommand(command_list* cmd) {
  if (auto* data = cmd->get_private_data<CommandData>()) *data = {};
}
inline void Use(DWORD reason) {
#define WITCHER_VIDEO_EVENT(event, callback)                       \
  if (reason == DLL_PROCESS_ATTACH)                               \
    reshade::register_event<reshade::addon_event::event>(callback); \
  else if (reason == DLL_PROCESS_DETACH)                           \
    reshade::unregister_event<reshade::addon_event::event>(callback)
  WITCHER_VIDEO_EVENT(init_device, OnInitDevice);
  WITCHER_VIDEO_EVENT(destroy_device, OnDestroyDevice);
  WITCHER_VIDEO_EVENT(init_command_list, OnInitCommand);
  WITCHER_VIDEO_EVENT(destroy_command_list, OnDestroyCommand);
  WITCHER_VIDEO_EVENT(reset_command_list, OnResetCommand);
  WITCHER_VIDEO_EVENT(destroy_resource, OnDestroyResource);
  WITCHER_VIDEO_EVENT(present, OnPresent);
#undef WITCHER_VIDEO_EVENT
}
}  // namespace witcher::video
