/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <array>
#include <map>
#include <memory>
#include <mutex>
#include <optional>
#include <vector>
#include "../../utils/descriptor.hpp"
#include "../../utils/resource.hpp"
#include "../../utils/shader.hpp"

namespace witcher::motion {
using namespace reshade::api;
inline float shutter_angle = 180.f;
inline float sample_count = 64.f;
inline std::array<std::span<const uint8_t>, 4> code;

struct Range {
  uint32_t param;
  bool table;
  descriptor_range range;
};
struct Roots {
  pipeline_layout layout = {};
  std::vector<descriptor_table> tables;
  std::map<uint32_t, buffer_range> buffers;
  std::map<uint32_t, std::pair<descriptor_type, resource_view>> views;
  std::map<uint32_t, std::vector<uint32_t>> constants;
  void SetLayout(pipeline_layout next) {
    if (layout == next) return;
    layout = next;
    tables.clear();
    buffers.clear();
    views.clear();
    constants.clear();
  }
  void Restore(command_list* cmd, shader_stage stages) const {
    auto target_layout = layout;
    renodx::utils::pipeline_layout::GetPipelineLayoutData(layout, [&](const auto* info) {
      if (info->replacement_layout.handle != 0) target_layout = info->replacement_layout;
    });
    if (target_layout.handle == 0) return;
    cmd->bind_descriptor_tables(stages, target_layout, 0, 0, nullptr);
    for (uint32_t i = 0; i < tables.size(); ++i)
      if (tables[i].handle != 0) cmd->bind_descriptor_tables(stages, target_layout, i, 1, &tables[i]);
    for (const auto& [i, buffer] : buffers)
      if (buffer.buffer.handle != 0) cmd->push_descriptors(stages, target_layout, i, {{}, 0, 0, 1, descriptor_type::constant_buffer, &buffer});
    for (const auto& [i, view] : views)
      if (view.second.handle != 0) cmd->push_descriptors(stages, target_layout, i, {{}, 0, 0, 1, view.first, &view.second});
    for (const auto& [i, values] : constants)
      cmd->push_constants(stages, target_layout, i, 0, static_cast<uint32_t>(values.size()), values.data());
  }
};
struct __declspec(uuid("9c623dd1-7217-42fa-a7cb-df1ba906706b")) CommandData {
  Roots compute, graphics;
  std::map<uint64_t, resource_view> depth_for_motion;
};
struct Parameters {
  uint32_t width, height, tiles_x, tiles_y;
  float motion_x, motion_y, radius_x, radius_y;
  float depth_x, depth_y, depth_a = 0, depth_b = 0;
  float radius = 32;
  uint32_t samples = 64, diagnostic = 0;
  float seconds = 0;
};
static_assert(sizeof(Parameters) == 64);
struct Context {
  std::array<resource, 4> inputs = {};
  std::array<resource, 2> tiles = {};
  std::array<resource_view, 2> tile_srvs = {}, tile_uavs = {};
  std::array<descriptor_table, 3> srvs = {}, uavs = {};
  Parameters parameters = {};
  void Destroy(device* dev) {
    for (uint32_t i = 0; i < 3; ++i) {
      if (srvs[i].handle) dev->free_descriptor_tables(1, &srvs[i]);
      if (uavs[i].handle) dev->free_descriptor_tables(1, &uavs[i]);
    }
    for (uint32_t i = 0; i < 2; ++i) {
      if (tile_srvs[i].handle) dev->destroy_resource_view(tile_srvs[i]);
      if (tile_uavs[i].handle) dev->destroy_resource_view(tile_uavs[i]);
      if (tiles[i].handle) dev->destroy_resource(tiles[i]);
    }
  }
};
struct DepthCopy {
  resource source = {}, motion = {}, copy = {};
  resource_view srv = {}, uav = {};
  descriptor_table inputs = {}, output = {};
  uint32_t width = 0, height = 0;
  void Destroy(device* dev) {
    if (inputs.handle) dev->free_descriptor_tables(1, &inputs);
    if (output.handle) dev->free_descriptor_tables(1, &output);
    if (srv.handle) dev->destroy_resource_view(srv);
    if (uav.handle) dev->destroy_resource_view(uav);
    if (copy.handle) dev->destroy_resource(copy);
  }
};
struct __declspec(uuid("f2161b1c-8cd9-4b34-b5c7-6c7c5b1c2ca6")) DeviceData {
  std::recursive_mutex mutex;
  std::map<uint64_t, std::vector<Range>> layouts;
  std::map<std::array<uint64_t, 4>, std::unique_ptr<Context>> contexts;
  pipeline_layout layout = {};
  std::array<pipeline, 4> pipelines = {};
  std::map<std::pair<uint64_t, uint64_t>, std::unique_ptr<DepthCopy>> depth_copies;
  sampler linear = {};
  descriptor_table sampler_table = {};
};

// Resolve native bindings from owned layout metadata. No GPU resource is queried
// until both its descriptor and resource handle have been validated.
inline std::optional<renodx::utils::descriptor::DescriptorHeapSlot> FindBinding(
    device* dev, const DeviceData& data, const Roots& roots, descriptor_type type, uint32_t slot) {
  const auto layout = data.layouts.find(roots.layout.handle);
  if (layout == data.layouts.end()) return std::nullopt;
  for (const auto& entry : layout->second) {
    const auto& r = entry.range;
    if (r.type != type || r.dx_register_space != 0 || slot < r.dx_register_index || slot - r.dx_register_index >= r.count) continue;
    if (!entry.table) {
      if (type != descriptor_type::constant_buffer) continue;
      const auto buffer = roots.buffers.find(entry.param);
      if (buffer == roots.buffers.end() || !buffer->second.buffer.handle) continue;
      renodx::utils::descriptor::DescriptorHeapSlot result;
      result.type = type;
      result.buffer_range = buffer->second;
      return result;
    }
    if (entry.param >= roots.tables.size() || !roots.tables[entry.param].handle) continue;
    auto* descriptors = renodx::utils::data::Get<renodx::utils::descriptor::DeviceData>(dev);
    if (!descriptors) return std::nullopt;
    descriptor_heap heap = {};
    uint32_t offset = 0;
    dev->get_descriptor_heap_offset(roots.tables[entry.param], r.binding + slot - r.dx_register_index, 0, &heap, &offset);
    const std::shared_lock lock(descriptors->mutex);
    const auto found = descriptors->heaps.find(heap.handle);
    if (found != descriptors->heaps.end() && offset < found->second.size() && found->second[offset].type == type) return found->second[offset];
  }
  return std::nullopt;
}

inline bool Prepare(device* dev, DeviceData* data) {
  if (data->layout.handle) return data->pipelines[3].handle != 0 && data->sampler_table.handle != 0 && data->linear.handle != 0;
  const descriptor_range ranges[] = {
      {0, 0, 0, 4, shader_stage::compute, 1, descriptor_type::shader_resource_view},
      {0, 0, 0, 1, shader_stage::compute, 1, descriptor_type::unordered_access_view},
      {0, 0, 0, 1, shader_stage::compute, 1, descriptor_type::sampler},
      {0, 1, 0, 1, shader_stage::compute, 1, descriptor_type::constant_buffer}};
  const pipeline_layout_param params[] = {pipeline_layout_param(1, &ranges[0]), pipeline_layout_param(1, &ranges[1]),
                                          pipeline_layout_param(1, &ranges[2]), pipeline_layout_param(ranges[3]),
                                          pipeline_layout_param(constant_range{0, 0, 0, sizeof(Parameters) / 4, shader_stage::compute})};
  if (!dev->create_pipeline_layout(5, params, &data->layout)) return false;
  for (uint32_t i = 0; i < 4; ++i) {
    shader_desc desc = {.code = code[i].data(), .code_size = code[i].size()};
    pipeline_subobject sub = {pipeline_subobject_type::compute_shader, 1, &desc};
    if (!dev->create_pipeline(data->layout, 1, &sub, &data->pipelines[i])) return false;
  }
  sampler_desc sampler_desc = {};
  sampler_desc.filter = filter_mode::min_mag_mip_linear;
  sampler_desc.address_u = sampler_desc.address_v = sampler_desc.address_w = texture_address_mode::clamp;
  if (!dev->create_sampler(sampler_desc, &data->linear)
      || !dev->allocate_descriptor_table(data->layout, 2, &data->sampler_table)) return false;
  descriptor_table_update update = {data->sampler_table, 0, 0, 1, descriptor_type::sampler, &data->linear};
  dev->update_descriptor_tables(1, &update);
  return true;
}

inline bool CaptureMotionDepth(command_list* cmd) {
  auto* dev = cmd->get_device();
  auto* data = dev->get_private_data<DeviceData>();
  auto* roots = cmd->get_private_data<CommandData>();
  if (!data || !roots) return true;
  const std::lock_guard lock(data->mutex);
  const auto depth = FindBinding(dev, *data, roots->compute, descriptor_type::shader_resource_view, 0);
  const auto motion = FindBinding(dev, *data, roots->compute, descriptor_type::unordered_access_view, 0);
  if (!depth || !motion || !depth->resource_view.handle || !motion->resource_view.handle) return true;
  const auto output = renodx::utils::resource::GetResourceFromView(dev, motion->resource_view);
  const auto source = renodx::utils::resource::GetResourceFromView(dev, depth->resource_view);
  if (!source.handle || !output.handle || !Prepare(dev, data)) return true;
  const auto source_desc = dev->get_resource_desc(source);
  if (source_desc.type != resource_type::texture_2d) return true;
  const auto key = std::pair{depth->resource_view.handle, output.handle};
  auto found = data->depth_copies.find(key);
  if (found == data->depth_copies.end()) {
    auto copy = std::make_unique<DepthCopy>();
    copy->source = source;
    copy->motion = output;
    copy->width = source_desc.texture.width;
    copy->height = source_desc.texture.height;
    const resource_desc desc(copy->width, copy->height, 1, 1, format::r32_float, 1, memory_heap::gpu_only, resource_usage::shader_resource | resource_usage::unordered_access);
    bool ok = dev->create_resource(desc, nullptr, resource_usage::shader_resource_non_pixel, &copy->copy)
              && dev->create_resource_view(copy->copy, resource_usage::shader_resource, resource_view_desc(format::r32_float), &copy->srv)
              && dev->create_resource_view(copy->copy, resource_usage::unordered_access, resource_view_desc(format::r32_float), &copy->uav)
              && dev->allocate_descriptor_table(data->layout, 0, &copy->inputs)
              && dev->allocate_descriptor_table(data->layout, 1, &copy->output);
    if (!ok) {
      copy->Destroy(dev);
      return true;
    }
    const resource_view inputs[] = {depth->resource_view, depth->resource_view, depth->resource_view, depth->resource_view};
    const descriptor_table_update updates[] = {{copy->inputs, 0, 0, 4, descriptor_type::shader_resource_view, inputs}, {copy->output, 0, 0, 1, descriptor_type::unordered_access_view, &copy->uav}};
    dev->update_descriptor_tables(2, updates);
    found = data->depth_copies.emplace(key, std::move(copy)).first;
  }
  const auto& copy = *found->second;
  const auto pipeline = renodx::utils::shader::GetCurrentState(cmd)->stage_states[renodx::utils::shader::COMPUTE_INDEX].pipeline;
  const Parameters p = {.width = copy.width, .height = copy.height};
  cmd->barrier(copy.copy, resource_usage::shader_resource_non_pixel, resource_usage::unordered_access);
  cmd->bind_pipeline(pipeline_stage::compute_shader, data->pipelines[3]);
  const descriptor_table tables[] = {copy.inputs, copy.output, data->sampler_table};
  cmd->bind_descriptor_tables(shader_stage::all_compute, data->layout, 0, 3, tables);
  cmd->push_constants(shader_stage::all_compute, data->layout, 4, 0, sizeof(Parameters) / 4, &p);
  cmd->dispatch((copy.width + 7) / 8, (copy.height + 7) / 8, 1);
  cmd->barrier(copy.copy, resource_usage::unordered_access, resource_usage::shader_resource_non_pixel);
  // Changing descriptor heaps invalidates graphics tables as well. Replay both
  // bind points, including root CBVs/constants, after the private compute work.
  roots->graphics.Restore(cmd, shader_stage::all_graphics);
  roots->compute.Restore(cmd, shader_stage::all_compute);
  cmd->bind_pipeline(pipeline_stage::compute_shader, pipeline);
  roots->depth_for_motion[output.handle] = copy.srv;
  return true;
}

inline bool Run(command_list* cmd) {
  auto* dev = cmd->get_device();
  auto* data = dev->get_private_data<DeviceData>();
  auto* roots = cmd->get_private_data<CommandData>();
  if (!data || !roots || dev->get_api() != device_api::d3d12) return false;
  const std::lock_guard lock(data->mutex);
  const auto scene = FindBinding(dev, *data, roots->compute, descriptor_type::shader_resource_view, 1);
  const auto motion = FindBinding(dev, *data, roots->compute, descriptor_type::shader_resource_view, 2);
  const auto output = FindBinding(dev, *data, roots->compute, descriptor_type::unordered_access_view, 0);
  const auto projection = FindBinding(dev, *data, roots->graphics, descriptor_type::constant_buffer, 12);
  if (!scene || !motion || !output || !projection || !scene->resource_view.handle || !motion->resource_view.handle || !output->resource_view.handle || !projection->buffer_range.buffer.handle) return false;
  const auto motion_resource = renodx::utils::resource::GetResourceFromView(dev, motion->resource_view);
  const auto depth = roots->depth_for_motion.find(motion_resource.handle);
  if (!motion_resource.handle || depth == roots->depth_for_motion.end()) return false;
  const std::array views = {scene->resource_view, motion->resource_view, depth->second, output->resource_view};
  std::array<resource, 4> resources;
  std::array<resource_desc, 4> descs;
  for (uint32_t i = 0; i < 4; ++i) {
    resources[i] = renodx::utils::resource::GetResourceFromView(dev, views[i]);
    if (!resources[i].handle) return false;
    descs[i] = dev->get_resource_desc(resources[i]);
    if (descs[i].type != resource_type::texture_2d) return false;
  }
  if (resources[0] == resources[3] || descs[0].texture.width != descs[3].texture.width || descs[0].texture.height != descs[3].texture.height || !Prepare(dev, data)) return false;
  const std::array<uint64_t, 4> key = {views[0].handle, views[1].handle, views[2].handle, views[3].handle};
  auto found = data->contexts.find(key);
  if (found == data->contexts.end()) {
    auto ctx = std::make_unique<Context>();
    ctx->inputs = resources;
    auto& p = ctx->parameters;
    p.width = descs[0].texture.width;
    p.height = descs[0].texture.height;
    p.tiles_x = (p.width + 31) / 32;
    p.tiles_y = (p.height + 31) / 32;
    p.motion_x = float(descs[1].texture.width) / p.width;
    p.motion_y = float(descs[1].texture.height) / p.height;
    p.depth_x = float(descs[2].texture.width) / p.width;
    p.depth_y = float(descs[2].texture.height) / p.height;
    bool ok = true;
    for (uint32_t i = 0; i < 2 && ok; ++i) {
      resource_desc desc(p.tiles_x, p.tiles_y, 1, 1, format::r16g16b16a16_float, 1, memory_heap::gpu_only, resource_usage::shader_resource | resource_usage::unordered_access);
      ok = dev->create_resource(desc, nullptr, resource_usage::shader_resource_non_pixel, &ctx->tiles[i])
           && dev->create_resource_view(ctx->tiles[i], resource_usage::shader_resource, resource_view_desc(format::r16g16b16a16_float), &ctx->tile_srvs[i])
           && dev->create_resource_view(ctx->tiles[i], resource_usage::unordered_access, resource_view_desc(format::r16g16b16a16_float), &ctx->tile_uavs[i]);
    }
    // Descriptors are immutable while referenced by submitted command lists.
    for (uint32_t i = 0; i < 3 && ok; ++i) {
      ok = dev->allocate_descriptor_table(data->layout, 0, &ctx->srvs[i]) && dev->allocate_descriptor_table(data->layout, 1, &ctx->uavs[i]);
      if (!ok) break;
      const resource_view inputs[] = {views[0], views[1], views[2], i == 0 ? views[1] : ctx->tile_srvs[i - 1]};
      const resource_view destination = i < 2 ? ctx->tile_uavs[i] : views[3];
      const descriptor_table_update updates[] = {{ctx->srvs[i], 0, 0, 4, descriptor_type::shader_resource_view, inputs}, {ctx->uavs[i], 0, 0, 1, descriptor_type::unordered_access_view, &destination}};
      dev->update_descriptor_tables(2, updates);
    }
    if (!ok) {
      ctx->Destroy(dev);
      return false;
    }
    found = data->contexts.emplace(key, std::move(ctx)).first;
  }
  auto& ctx = *found->second;
  ctx.parameters.radius_x = ctx.parameters.width * std::clamp(shutter_angle, 0.f, 360.f) / 720.f;
  ctx.parameters.radius_y = ctx.parameters.height * std::clamp(shutter_angle, 0.f, 360.f) / 720.f;
  ctx.parameters.samples = static_cast<uint32_t>(std::clamp(sample_count, 16.f, 128.f));
  const auto pipeline = renodx::utils::shader::GetCurrentState(cmd)->stage_states[renodx::utils::shader::COMPUTE_INDEX].pipeline;
  for (uint32_t i = 0; i < 3; ++i) {
    if (i < 2) cmd->barrier(ctx.tiles[i], resource_usage::shader_resource_non_pixel, resource_usage::unordered_access);
    cmd->bind_pipeline(pipeline_stage::compute_shader, data->pipelines[i]);
    const descriptor_table tables[] = {ctx.srvs[i], ctx.uavs[i], data->sampler_table};
    cmd->bind_descriptor_tables(shader_stage::all_compute, data->layout, 0, 3, tables);
    cmd->push_descriptors(shader_stage::all_compute, data->layout, 3, {{}, 0, 0, 1, descriptor_type::constant_buffer, &projection->buffer_range});
    cmd->push_constants(shader_stage::all_compute, data->layout, 4, 0, sizeof(Parameters) / 4, &ctx.parameters);
    cmd->dispatch(i == 0 ? ctx.parameters.tiles_x : i == 1 ? (ctx.parameters.tiles_x + 7) / 8
                                                           : (ctx.parameters.width + 7) / 8,
                  i == 0 ? ctx.parameters.tiles_y : i == 1 ? (ctx.parameters.tiles_y + 7) / 8
                                                           : (ctx.parameters.height + 7) / 8,
                  1);
    if (i < 2) cmd->barrier(ctx.tiles[i], resource_usage::unordered_access, resource_usage::shader_resource_non_pixel);
  }
  // Changing descriptor heaps invalidates graphics tables as well. Replay both
  // bind points, including root CBVs/constants, after the private compute work.
  roots->graphics.Restore(cmd, shader_stage::all_graphics);
  roots->compute.Restore(cmd, shader_stage::all_compute);
  cmd->bind_pipeline(pipeline_stage::compute_shader, pipeline);
  return true;
}

inline void OnInitLayout(device* dev, uint32_t count, const pipeline_layout_param* params, pipeline_layout layout) {
  auto* data = dev->get_private_data<DeviceData>();
  if (!data) return;
  const std::lock_guard lock(data->mutex);
  auto& ranges = data->layouts[layout.handle];
  ranges.clear();
  for (uint32_t i = 0; i < count; ++i) {
    const auto& p = params[i];
    if (p.type == pipeline_layout_param_type::push_descriptors)
      ranges.push_back({i, false, p.push_descriptors});
    else if (p.type == pipeline_layout_param_type::descriptor_table || p.type == pipeline_layout_param_type::push_descriptors_with_ranges) {
      for (uint32_t j = 0; j < p.descriptor_table.count; ++j) ranges.push_back({i, p.type == pipeline_layout_param_type::descriptor_table, p.descriptor_table.ranges[j]});
    } else if (p.type == pipeline_layout_param_type::descriptor_table_with_static_samplers || p.type == pipeline_layout_param_type::push_descriptors_with_static_samplers) {
      for (uint32_t j = 0; j < p.descriptor_table_with_static_samplers.count; ++j)
        if (!p.descriptor_table_with_static_samplers.ranges[j].static_samplers)
          ranges.push_back({i, p.type == pipeline_layout_param_type::descriptor_table_with_static_samplers, p.descriptor_table_with_static_samplers.ranges[j]});
    }
  }
}
inline void OnDestroyLayout(device* dev, pipeline_layout layout) {
  if (auto* data = dev->get_private_data<DeviceData>()) {
    const std::lock_guard lock(data->mutex);
    data->layouts.erase(layout.handle);
  }
}
inline void OnBindTables(command_list* cmd, shader_stage stages, pipeline_layout layout, uint32_t first, uint32_t count, const descriptor_table* tables) {
  auto* data = cmd->get_private_data<CommandData>();
  if (!data) return;
  auto& root = renodx::utils::bitwise::HasFlag(stages, shader_stage::compute) ? data->compute : data->graphics;
  root.SetLayout(layout);
  root.tables.resize(std::max(root.tables.size(), size_t(first) + count));
  std::copy_n(tables, count, root.tables.begin() + first);
}
inline void OnPushDescriptors(command_list* cmd, shader_stage stages, pipeline_layout layout, uint32_t param, const descriptor_table_update& update) {
  auto* data = cmd->get_private_data<CommandData>();
  if (!data || update.count != 1 || !update.descriptors) return;
  auto& root = renodx::utils::bitwise::HasFlag(stages, shader_stage::compute) ? data->compute : data->graphics;
  root.SetLayout(layout);
  if (update.type == descriptor_type::constant_buffer)
    root.buffers[param] = *static_cast<const buffer_range*>(update.descriptors);
  else if (renodx::utils::descriptor::DescriptorHeapSlot::HasResourceViewType(update.type))
    root.views[param] = {update.type, *static_cast<const resource_view*>(update.descriptors)};
}
inline void OnPushConstants(command_list* cmd, shader_stage stages, pipeline_layout layout, uint32_t param, uint32_t first, uint32_t count, const void* values) {
  auto* data = cmd->get_private_data<CommandData>();
  if (!data) return;
  auto& root = renodx::utils::bitwise::HasFlag(stages, shader_stage::compute) ? data->compute : data->graphics;
  root.SetLayout(layout);
  auto& stored = root.constants[param];
  stored.resize(std::max(stored.size(), size_t(first) + count));
  std::copy_n(static_cast<const uint32_t*>(values), count, stored.begin() + first);
}
inline void OnInitDevice(device* dev) {
  if (dev->get_api() == device_api::d3d12) dev->create_private_data<DeviceData>();
}
inline void OnDestroyResource(device* dev, resource res) {
  auto* data = dev->get_private_data<DeviceData>();
  if (!data) return;
  const std::lock_guard lock(data->mutex);
  std::vector<resource> depth_resources;
  for (const auto& [key, copy] : data->depth_copies)
    if (copy->source == res || copy->motion == res) depth_resources.push_back(copy->copy);
  for (auto it = data->contexts.begin(); it != data->contexts.end();) {
    if (std::find(it->second->inputs.begin(), it->second->inputs.end(), res) != it->second->inputs.end()
        || std::find(depth_resources.begin(), depth_resources.end(), it->second->inputs[2]) != depth_resources.end()) {
      it->second->Destroy(dev);
      it = data->contexts.erase(it);
    } else
      ++it;
  }
  for (auto it = data->depth_copies.begin(); it != data->depth_copies.end();) {
    if (it->second->source == res || it->second->motion == res) {
      it->second->Destroy(dev);
      it = data->depth_copies.erase(it);
    } else
      ++it;
  }
}
inline void OnDestroyDevice(device* dev) {
  auto* data = dev->get_private_data<DeviceData>();
  if (!data) return;
  for (auto& [key, ctx] : data->contexts) ctx->Destroy(dev);
  for (auto& [key, copy] : data->depth_copies) copy->Destroy(dev);
  for (auto pipeline : data->pipelines)
    if (pipeline.handle) dev->destroy_pipeline(pipeline);
  if (data->sampler_table.handle) dev->free_descriptor_tables(1, &data->sampler_table);
  if (data->linear.handle) dev->destroy_sampler(data->linear);
  if (data->layout.handle) dev->destroy_pipeline_layout(data->layout);
  dev->destroy_private_data<DeviceData>();
}
inline void OnInitCommand(command_list* cmd) {
  if (cmd->get_device()->get_api() == device_api::d3d12) cmd->create_private_data<CommandData>();
}
inline void OnDestroyCommand(command_list* cmd) { cmd->destroy_private_data<CommandData>(); }
inline void OnResetCommand(command_list* cmd) {
  if (auto* data = cmd->get_private_data<CommandData>()) *data = {};
}
inline void Use(DWORD reason) {
  // GetResourceFromView requires this module's shared resource tracker. Shader
  // injection alone does not initialize it when resource cloning is disabled.
  renodx::utils::resource::Use(reason);
#define WITCHER_MOTION_EVENT(event, callback)                       \
  if (reason == DLL_PROCESS_ATTACH)                                 \
    reshade::register_event<reshade::addon_event::event>(callback); \
  else if (reason == DLL_PROCESS_DETACH)                            \
  reshade::unregister_event<reshade::addon_event::event>(callback)
  WITCHER_MOTION_EVENT(init_device, OnInitDevice);
  WITCHER_MOTION_EVENT(destroy_device, OnDestroyDevice);
  WITCHER_MOTION_EVENT(init_command_list, OnInitCommand);
  WITCHER_MOTION_EVENT(destroy_command_list, OnDestroyCommand);
  WITCHER_MOTION_EVENT(reset_command_list, OnResetCommand);
  WITCHER_MOTION_EVENT(init_pipeline_layout, OnInitLayout);
  WITCHER_MOTION_EVENT(destroy_pipeline_layout, OnDestroyLayout);
  WITCHER_MOTION_EVENT(destroy_resource, OnDestroyResource);
  WITCHER_MOTION_EVENT(bind_descriptor_tables, OnBindTables);
  WITCHER_MOTION_EVENT(push_descriptors, OnPushDescriptors);
  WITCHER_MOTION_EVENT(push_constants, OnPushConstants);
#undef WITCHER_MOTION_EVENT
}
}  // namespace witcher::motion
