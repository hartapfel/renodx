// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "../rendering/bindings.hpp"

namespace witcher3graphics::volumetrics::rays {
struct ProducerRoots {
  uint32_t camera=UINT32_MAX,context=UINT32_MAX,output=UINT32_MAX;
  bool Valid() const { return camera!=UINT32_MAX &&context!=UINT32_MAX &&output!=UINT32_MAX; }
};

// A recognized suffix may follow the existing, independently audited ray
// controls/material prefix. Never relax those owners' native-prefix matching.
inline ProducerRoots FindProducerRootSuffix(uint32_t count,const reshade::api::pipeline_layout_param* params) {
  using namespace reshade::api;
  if(!params ||count<3)return {};
  for(uint32_t slot=0;slot<3;++slot) {
    const auto* range=bindings::RootDescriptor(params[count-3+slot]);
    if(!range ||range->binding!=0 ||range->count!=1 ||range->visibility!=shader_stage::all
        ||range->dx_register_space!=61 ||range->dx_register_index!=(slot==1?1u:0u)
        ||range->type!=(slot==2?descriptor_type::buffer_unordered_access_view:descriptor_type::constant_buffer))return {};
  }
  return {count-3,count-2,count-1};
}
} // namespace witcher3graphics::volumetrics::rays
