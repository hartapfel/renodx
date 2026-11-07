// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once

#include <array>
#include <cstdint>
#include <shared_mutex>
#include <unordered_map>
#include <vector>
#include <include/reshade.hpp>
#include "../../../../../utils/data.hpp"
#include "../../../../../utils/descriptor.hpp"
#include "../../../../../utils/pipeline_layout.hpp"
#include "../../../descriptor_cache.hpp"

namespace witcher3graphics::bindings {
using namespace reshade::api;

// ReShade 6.8 reports native root descriptors in either the inline form or
// a single extended range. Static samplers are not root descriptors.
inline const descriptor_range* RootDescriptor(const pipeline_layout_param& param) {
  if (param.type == pipeline_layout_param_type::push_descriptors) return &param.push_descriptors;
  if (param.type == pipeline_layout_param_type::push_descriptors_with_ranges
      && param.descriptor_table.count == 1) return param.descriptor_table.ranges;
  if (param.type == pipeline_layout_param_type::push_descriptors_with_static_samplers
      && param.descriptor_table_with_static_samplers.count == 1
      && param.descriptor_table_with_static_samplers.ranges[0].static_samplers == nullptr)
    return param.descriptor_table_with_static_samplers.ranges;
  return nullptr;
}

inline void OnLayout(device*, uint32_t count, const pipeline_layout_param* params, pipeline_layout layout) {
  // Normalize while callback-owned extended ranges are alive. The shared
  // cache retains inline roots by value; later binding lookups need no borrowed
  // pointers and retain the original native root indices.
  renodx::utils::pipeline_layout::UpdatePipelineLayoutData(layout, [&](auto& data) {
    for (uint32_t i = 0; i < count; ++i)
      if (const auto* range = RootDescriptor(params[i])) data.params[i] = pipeline_layout_param(*range);
  });
}

// Production pass inputs and state restoration, scoped to each recording.
// No readback, frame capture, raw resource retention or cross-frame cache.
struct RootArgument {
  descriptor_table table = {};
  std::array<uint32_t, 64> constants{};
  uint64_t constant_valid = 0;
  renodx::utils::descriptor::DescriptorHeapSlot descriptor;
  bool descriptor_valid = false;
};
struct RootState {
  pipeline_layout layout = {};
  std::array<RootArgument, 64> arguments;
  uint64_t valid_arguments = 0;

  void Select(const pipeline_layout& value) {
    if (layout != value) { valid_arguments = 0; layout = value; }
  }

  RootArgument* Argument(uint32_t index) {
    if (index >= arguments.size()) return nullptr;
    auto& argument = arguments[index];
    if (!(valid_arguments & (uint64_t(1) << index))) {
      argument.table = {};
      argument.constant_valid = 0;
      argument.descriptor_valid = false;
      valid_arguments |= uint64_t(1) << index;
    }
    return &argument;
  }

  void Restore(command_list* cmd, shader_stage stages) const {
    if (layout.handle == 0) return;
    cmd->bind_descriptor_tables(stages, layout, 0, 0, nullptr);
    for (uint32_t index = 0; index < arguments.size(); ++index) {
      if (!(valid_arguments & (uint64_t(1) << index))) continue;
      const auto& argument = arguments[index];
      if (argument.table.handle != 0) cmd->bind_descriptor_tables(stages, layout, index, 1, &argument.table);
      for (uint32_t begin = 0; begin < argument.constants.size();) {
        if (!(argument.constant_valid & (uint64_t(1) << begin))) { ++begin; continue; }
        uint32_t end = begin + 1;
        while (end < argument.constants.size() && (argument.constant_valid & (uint64_t(1) << end))) ++end;
        cmd->push_constants(stages, layout, index, begin, end - begin, argument.constants.data() + begin);
        begin = end;
      }
      if (argument.descriptor_valid) {
        const auto& descriptor = argument.descriptor;
        const void* value = descriptor.type == descriptor_type::constant_buffer
                || descriptor.type == descriptor_type::shader_storage_buffer
            ? static_cast<const void*>(&descriptor.buffer_range) : &descriptor.resource_view;
        cmd->push_descriptors(stages, layout, index, {{0}, 0, 0, 1, descriptor.type, value});
      }
    }
  }
};
struct __declspec(uuid("f907f28a-2572-4b0c-9c4c-4647ffb1ca19")) CommandData {
  RootState graphics;
  RootState compute;
  bool in_render_pass = false;
  pipeline last_pipeline = {};
  pipeline_stage last_stages = pipeline_stage::all;
};

inline void OnInit(command_list* cmd) { renodx::utils::data::Create<CommandData>(cmd); }
inline void OnDestroy(command_list* cmd) { renodx::utils::data::Delete<CommandData>(cmd); }
inline void OnReset(command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) {
    data->graphics.layout = {}; data->graphics.valid_arguments = 0;
    data->compute.layout = {}; data->compute.valid_arguments = 0;
    data->in_render_pass = false; data->last_pipeline = {}; data->last_stages = pipeline_stage::all;
  }
}
inline void OnBeginPass(command_list* cmd, uint32_t, const render_pass_render_target_desc*, const render_pass_depth_stencil_desc*) {
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) data->in_render_pass = true;
}
inline void OnEndPass(command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) data->in_render_pass = false;
}
inline void OnPipeline(command_list* cmd, pipeline_stage stages, pipeline value) {
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) {
    data->last_pipeline = value; data->last_stages = stages;
  }
}

template <typename F>
void Update(command_list* cmd, shader_stage stages, const pipeline_layout& layout, F&& update) {
  auto* data = renodx::utils::data::Get<CommandData>(cmd);
  if (data == nullptr || layout.handle == 0) return;
  if ((uint32_t(stages) & uint32_t(shader_stage::all_graphics)) != 0) {
    data->graphics.Select(layout); update(&data->graphics);
  }
  if ((uint32_t(stages) & uint32_t(shader_stage::all_compute | shader_stage::all_ray_tracing)) != 0) {
    data->compute.Select(layout); update(&data->compute);
  }
}
inline void OnTables(command_list* cmd, shader_stage stages, pipeline_layout layout,
                     uint32_t first, uint32_t count, const descriptor_table* tables) {
  if (first >= 64 || count > 64 - first) return;
  Update(cmd, stages, layout, [&](RootState* state) {
    for (uint32_t i = 0; i < count; ++i) state->Argument(first + i)->table = tables[i];
  });
}
inline void OnConstants(command_list* cmd, shader_stage stages, pipeline_layout layout,
                        uint32_t param, uint32_t first, uint32_t count, const void* values) {
  if (param >= 64 || first > 64 || count > 64 - first || (count != 0 && values == nullptr)) return;
  Update(cmd, stages, layout, [&](RootState* state) {
    auto& argument = *state->Argument(param);
    for (uint32_t i = 0; i < count; ++i) {
      argument.constants[first + i] = static_cast<const uint32_t*>(values)[i];
      argument.constant_valid |= uint64_t(1) << (first + i);
    }
  });
}
inline void OnDescriptors(command_list* cmd, shader_stage stages, pipeline_layout layout,
                          uint32_t param, const descriptor_table_update& update) {
  if (param >= 64 || update.binding != 0 || update.array_offset != 0 || update.count != 1 || update.descriptors == nullptr) return;
  const bool buffer = update.type == descriptor_type::constant_buffer || update.type == descriptor_type::shader_storage_buffer;
  if (!buffer && !renodx::utils::descriptor::DescriptorHeapSlot::HasResourceViewType(update.type)) return;
  // D3D12 root descriptors never contain combined image/sampler descriptors.
  if (update.type == descriptor_type::sampler_with_resource_view) return;
  Update(cmd, stages, layout, [&](RootState* state) {
    {
      auto* argument = state->Argument(param);
      auto& slot = argument->descriptor;
      slot.type = update.type;
      if (buffer) slot.buffer_range = *static_cast<const buffer_range*>(update.descriptors);
      else slot.resource_view = *static_cast<const resource_view*>(update.descriptors);
      argument->descriptor_valid = true;
    }
  });
}

inline renodx::utils::descriptor::DescriptorHeapSlot Find(command_list* cmd, shader_stage stage,
                                                        descriptor_type type, uint32_t reg, uint32_t space = 0) {
  renodx::utils::descriptor::DescriptorHeapSlot result;
  // Registers can name different resources in VS and PS in the same root
  // signature. Require one tracked stage rather than arbitrarily resolving a
  // multi-stage mask to whichever matching parameter happens to be last.
  const uint32_t mask = uint32_t(stage);
  if (mask == 0 || (mask & (mask - 1)) != 0
      || (mask & uint32_t(shader_stage::all_graphics | shader_stage::compute | shader_stage::all_ray_tracing)) == 0) return result;
  auto* state_data = renodx::utils::data::Get<CommandData>(cmd);
  if (state_data == nullptr) return result;
  const auto& state = (mask & uint32_t(shader_stage::all_compute | shader_stage::all_ray_tracing)) != 0
      ? state_data->compute : state_data->graphics;
  renodx::utils::pipeline_layout::GetPipelineLayoutData(state.layout, [&](const auto* layout) {
    for (uint32_t param = 0; param < layout->params.size() && param < 64; ++param) {
      if (!(state.valid_arguments & (uint64_t(1) << param))) continue;
      const auto& argument = state.arguments[param];
      const auto resolve = [&](const descriptor_range& range, bool table) {
        if ((uint32_t(range.visibility) & mask) == 0
            || range.type != type || range.dx_register_space != space || reg < range.dx_register_index
            || reg - range.dx_register_index >= range.count) return;
        const uint32_t binding = range.binding + reg - range.dx_register_index;
        if (!table) {
          if (binding == 0 && argument.descriptor_valid && argument.descriptor.type == type) result = argument.descriptor;
          return;
        }
        if (argument.table.handle == 0) return;
        const auto value = hartapfelfx::descriptors::Read(cmd->get_device(), argument.table, binding);
        if (value.type == type) result = value;
      };
      const auto& definition = layout->params[param];
      if (definition.type == pipeline_layout_param_type::push_descriptors) resolve(definition.push_descriptors, false);
      else if (definition.type == pipeline_layout_param_type::descriptor_table
          || definition.type == pipeline_layout_param_type::descriptor_table_with_static_samplers)
        for (const auto& range : layout->ranges[param]) resolve(range, true);
    }
  });
  return result;
}

inline renodx::utils::descriptor::DescriptorHeapSlot Find(command_list* cmd, bool compute,
                                                        descriptor_type type, uint32_t reg, uint32_t space = 0) {
  return Find(cmd, compute ? shader_stage::compute : shader_stage::pixel, type, reg, space);
}

inline void Use(DWORD reason, bool use_shared_utils = true) {
  if (reason == DLL_PROCESS_ATTACH) {
    renodx::utils::descriptor::trace_descriptor_tables = false;
    if (use_shared_utils) {
      renodx::utils::descriptor::Use(reason);
      renodx::utils::pipeline_layout::Use(reason);
    }
    reshade::register_event<reshade::addon_event::init_pipeline_layout>(OnLayout);
    reshade::register_event<reshade::addon_event::init_command_list>(OnInit);
    reshade::register_event<reshade::addon_event::destroy_command_list>(OnDestroy);
    reshade::register_event<reshade::addon_event::reset_command_list>(OnReset);
    reshade::register_event<reshade::addon_event::bind_descriptor_tables>(OnTables);
    reshade::register_event<reshade::addon_event::push_constants>(OnConstants);
    reshade::register_event<reshade::addon_event::push_descriptors>(OnDescriptors);
    reshade::register_event<reshade::addon_event::begin_render_pass>(OnBeginPass);
    reshade::register_event<reshade::addon_event::end_render_pass>(OnEndPass);
    reshade::register_event<reshade::addon_event::bind_pipeline>(OnPipeline);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::init_pipeline_layout>(OnLayout);
    reshade::unregister_event<reshade::addon_event::init_command_list>(OnInit);
    reshade::unregister_event<reshade::addon_event::destroy_command_list>(OnDestroy);
    reshade::unregister_event<reshade::addon_event::reset_command_list>(OnReset);
    reshade::unregister_event<reshade::addon_event::bind_descriptor_tables>(OnTables);
    reshade::unregister_event<reshade::addon_event::push_constants>(OnConstants);
    reshade::unregister_event<reshade::addon_event::push_descriptors>(OnDescriptors);
    reshade::unregister_event<reshade::addon_event::begin_render_pass>(OnBeginPass);
    reshade::unregister_event<reshade::addon_event::end_render_pass>(OnEndPass);
    reshade::unregister_event<reshade::addon_event::bind_pipeline>(OnPipeline);
    if (use_shared_utils) {
      renodx::utils::pipeline_layout::Use(reason);
      renodx::utils::descriptor::Use(reason);
    }
  }
}
}  // namespace witcher3graphics::bindings
