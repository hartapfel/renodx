// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "../rendering/bindings.hpp"

namespace witcher3graphics::volumetrics::rays {
struct ProducerRoots {
  uint32_t frame=UINT32_MAX,light=UINT32_MAX,injection=UINT32_MAX,grid=UINT32_MAX,output=UINT32_MAX,lights=UINT32_MAX,record=UINT32_MAX,source_camera=UINT32_MAX;
  bool Valid() const { return source_camera!=UINT32_MAX; }
};

// A recognized suffix may follow the existing, independently audited ray
// controls/material prefix. Never relax those owners' native-prefix matching.
inline ProducerRoots FindProducerRootSuffix(uint32_t count,const reshade::api::pipeline_layout_param* params) {
  using namespace reshade::api;
  if(!params ||count<8)return {};
  for(uint32_t slot=0;slot<8;++slot) {
    const auto* range=bindings::RootDescriptor(params[count-8+slot]);
    if(!range ||range->binding!=0 ||range->count!=1 ||range->visibility!=shader_stage::all
        ||range->dx_register_space!=61 ||range->dx_register_index!=(slot<4?slot:slot==7?4u:slot==6?1u:0u)
        ||range->type!=((slot<4||slot==7)?descriptor_type::constant_buffer:slot==4?descriptor_type::buffer_unordered_access_view:descriptor_type::buffer_shader_resource_view))return {};
  }
  return {count-8,count-7,count-6,count-5,count-4,count-3,count-2,count-1};
}
} // namespace witcher3graphics::volumetrics::rays
