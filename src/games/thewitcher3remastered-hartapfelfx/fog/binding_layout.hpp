// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <include/reshade_api.hpp>
#include <span>
#include <tuple>
#include <vector>

namespace hartapfelfx::fog {
struct LayoutParameter {
  bool table = false;
  uint32_t constant_count = 0;
  std::vector<reshade::api::descriptor_range> ranges;
};
struct BindingLayout {
  std::vector<LayoutParameter> parameters;
  BindingLayout() = default;
  BindingLayout(uint32_t count, const reshade::api::pipeline_layout_param* params) : parameters(count) {
    // ReShade's parameter/range pointers belong to the init callback. Retain
    // values, including the newer static-sampler forms of root CBV parameters.
    for (uint32_t i = 0; i < count; ++i) {
      auto& output = parameters[i];
      const auto& input = params[i];
      switch (input.type) {
        case reshade::api::pipeline_layout_param_type::push_constants:
          output.constant_count = input.push_constants.count;
          break;
        case reshade::api::pipeline_layout_param_type::push_descriptors:
          output.ranges.push_back(input.push_descriptors);
          break;
        case reshade::api::pipeline_layout_param_type::descriptor_table:
        case reshade::api::pipeline_layout_param_type::push_descriptors_with_ranges:
          output.table = input.type == reshade::api::pipeline_layout_param_type::descriptor_table;
          output.ranges.assign(input.descriptor_table.ranges, input.descriptor_table.ranges + input.descriptor_table.count);
          break;
        case reshade::api::pipeline_layout_param_type::descriptor_table_with_static_samplers:
        case reshade::api::pipeline_layout_param_type::push_descriptors_with_static_samplers:
          output.table = input.type == reshade::api::pipeline_layout_param_type::descriptor_table_with_static_samplers;
          for (uint32_t j = 0; j < input.descriptor_table_with_static_samplers.count; ++j)
            output.ranges.push_back(input.descriptor_table_with_static_samplers.ranges[j]);
          break;
        default: break;
      }
    }
  }
};
namespace api = reshade::api;
// Native RT colour-atlas lighting reuses the sun hash and frame-buffer address.
// A scene fog job requires an actual depth component, not just a 2D texture.
inline bool IsFogDepthInput(const api::resource_desc& resource, const api::resource_view_desc& view) {
  if (resource.type != api::resource_type::texture_2d || view.type != api::resource_view_type::texture_2d
      || !resource.texture.width || !resource.texture.height || resource.texture.samples != 1) return false;
  if (view.format == api::format::r32_float_x8_uint || view.format == api::format::r24_unorm_x8_uint) return true;
  return (resource.usage & api::resource_usage::depth_stencil) != api::resource_usage::undefined
         && (view.format == api::format::r32_float || view.format == api::format::r16_unorm);
}
inline bool MatchesFogViewport(const api::viewport& current, const api::viewport& source) {
  return source.width > 0.f && source.height > 0.f && current.x == source.x && current.y == source.y
         && current.width == source.width && current.height == source.height;
}
inline bool ExtendFogLayout(std::span<const api::pipeline_layout_param> parameters, std::vector<api::pipeline_layout_param>* extended) {
  const BindingLayout native(uint32_t(parameters.size()), parameters.data());
  bool frame = false, light = false, lighting_collision = false, hit_collision = false, compute_constants = false;
  uint32_t cost = 0;
  for (uint32_t i = 0; i < parameters.size(); ++i) {
    const auto& parameter = parameters[i];
    if (parameter.type == api::pipeline_layout_param_type::push_constants) {
      cost += parameter.push_constants.count;
      lighting_collision |= parameter.push_constants.dx_register_space == 73;
      hit_collision |= parameter.push_constants.dx_register_space == 55 || parameter.push_constants.dx_register_space == 59;
    }
    else
      cost += native.parameters[i].table ? 1u : 2u;
    for (const auto& range : native.parameters[i].ranges) {
      lighting_collision |= range.dx_register_space == 54 || range.dx_register_space == 73;
      hit_collision |= range.dx_register_space == 55 || range.dx_register_space == 59;
      if (range.dx_register_space >= 70 && range.dx_register_space <= 72) return false;
      if (range.type != api::descriptor_type::constant_buffer || range.dx_register_space != 0) continue;
      frame |= range.dx_register_index <= 12 && 12 - range.dx_register_index < range.count;
      light |= range.dx_register_index <= 13 && 13 - range.dx_register_index < range.count;
      compute_constants |= native.parameters[i].table && range.dx_register_index <= 7
          && 14 - range.dx_register_index < range.count
          && (uint32_t(range.visibility) & uint32_t(api::shader_stage::compute)) != 0;
    }
  }
  if (!frame || !light || cost > 48) return false;
  extended->assign(parameters.begin(), parameters.end());
  for (auto [type, slot, space] : {
           std::tuple{api::descriptor_type::constant_buffer, 0u, 70u},
           std::tuple{api::descriptor_type::constant_buffer, 3u, 71u},
           std::tuple{api::descriptor_type::buffer_shader_resource_view, 0u, 71u},
           std::tuple{api::descriptor_type::buffer_unordered_access_view, 0u, 71u},
           std::tuple{api::descriptor_type::buffer_shader_resource_view, 1u, 71u},
           std::tuple{api::descriptor_type::buffer_shader_resource_view, 2u, 71u},
           std::tuple{api::descriptor_type::buffer_shader_resource_view, 0u, 72u},
           std::tuple{api::descriptor_type::buffer_unordered_access_view, 0u, 72u}}) {
    extended->emplace_back(api::descriptor_range{.binding = 0, .dx_register_index = slot, .dx_register_space = space, .count = 1, .visibility = api::shader_stage::all, .array_size = 1, .type = type});
  }
  // Keep the fog/cloud layout on signatures without room for lighting.
  if (!lighting_collision && cost <= 44) {
    constexpr auto stages = api::shader_stage::all;
    extended->emplace_back(api::descriptor_range{0, 0, 73, 1, stages, 1, api::descriptor_type::constant_buffer});
    extended->emplace_back(api::descriptor_range{0, 0, 54, 1, stages, 1, api::descriptor_type::buffer_shader_resource_view});
  }
  // The RTGI/reflection compute signature stores b1..b15 in a table. The
  // shared material-layout admission intentionally excludes that general
  // signature. HartapfelFX already owns its fog/cloud extension, so provide
  // buffered material roots without adding inline settings constants.
  if (compute_constants && !hit_collision && cost <= 36) {
    constexpr auto stage = api::shader_stage::compute;
    extended->emplace_back(api::descriptor_range{0, 0, 59, 1, stage, 1, api::descriptor_type::constant_buffer});
    extended->emplace_back(api::descriptor_range{0, 0, 59, 1, stage, 1, api::descriptor_type::buffer_shader_resource_view});
    extended->emplace_back(api::descriptor_range{0, 0, 55, 1, stage, 1, api::descriptor_type::buffer_shader_resource_view});
  }
  return true;
}
}  // namespace hartapfelfx::fog
