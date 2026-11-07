// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "../raytracing/controls.hpp"
#include "ray_layout.hpp"

namespace witcher3graphics::volumetrics::rays {
using namespace reshade::api;

// Extend only the audited native DXR global. Generic graphics/compute layouts
// must never receive these bindings: their settings injection has other rules.
// Both camera and controls are CBVs; the owner leases immutable controls with
// the written field instead of changing upload memory referenced by old work.
inline bool AppendProducerRoots(uint32_t count, const pipeline_layout_param* params,
    std::vector<pipeline_layout_param>* output) {
  if (!raytracing::IsGlobalLayout(count, params)) return false;
  uint32_t cost = 0;
  bool conflict = false;
  const auto inspect = [&](const descriptor_range& range) { conflict |= range.dx_register_space == 61; };
  for (uint32_t i = 0; i < count; ++i) {
    const auto& param = params[i];
    if (param.type == pipeline_layout_param_type::push_constants) {
      if (param.push_constants.count > 64 - cost) return false;
      cost += param.push_constants.count;
      conflict |= param.push_constants.dx_register_space == 61;
    } else if (param.type == pipeline_layout_param_type::descriptor_table) {
      if (cost == 64) return false;
      ++cost;
      for (uint32_t j = 0; j < param.descriptor_table.count; ++j) inspect(param.descriptor_table.ranges[j]);
    } else if (const auto* range = bindings::RootDescriptor(param)) {
      inspect(*range);
      // RootDescriptor also returns single-range push tables. D3D12 promotes
      // only one buffer descriptor at binding zero to a two-DWORD root view.
      const bool root = range->count == 1 && range->binding == 0 &&
          (range->type == descriptor_type::constant_buffer || range->type == descriptor_type::buffer_shader_resource_view
              || range->type == descriptor_type::buffer_unordered_access_view || range->type == descriptor_type::shader_storage_buffer);
      if (cost > 64 - (root ? 2u : 1u)) return false;
      cost += root ? 2 : 1;
    } else if (param.type == pipeline_layout_param_type::descriptor_table_with_static_samplers
        || param.type == pipeline_layout_param_type::push_descriptors_with_static_samplers) {
      const bool table = param.type == pipeline_layout_param_type::descriptor_table_with_static_samplers;
      // ReShade preserves a static-only pseudo-parameter's index with a dummy
      // DWORD when our appended roots follow it.
      if (cost == 64) return false;
      ++cost;
      for (uint32_t j = 0; j < param.descriptor_table_with_static_samplers.count; ++j) {
        const auto& range = param.descriptor_table_with_static_samplers.ranges[j];
        if (!table && (range.type != descriptor_type::sampler || !range.static_samplers)) return false;
        inspect(range);
      }
    } else return false;
  }
  if (conflict || cost > 58) return false;
  std::vector<pipeline_layout_param> extended(params, params + count);
  extended.emplace_back(descriptor_range{0, 0, 61, 1, shader_stage::all, 1, descriptor_type::constant_buffer});
  extended.emplace_back(descriptor_range{0, 1, 61, 1, shader_stage::all, 1, descriptor_type::constant_buffer});
  extended.emplace_back(descriptor_range{0, 0, 61, 1, shader_stage::all, 1, descriptor_type::buffer_unordered_access_view});
  *output = std::move(extended);
  return true;
}

inline ProducerRoots FindProducerRoots(pipeline_layout value) {
  ProducerRoots result;
  renodx::utils::pipeline_layout::GetPipelineLayoutData(value, [&](const auto* layout) {
    result=FindProducerRootSuffix(uint32_t(layout->params.size()),layout->params.data());
  });
  return result;
}
}  // namespace witcher3graphics::volumetrics::rays
