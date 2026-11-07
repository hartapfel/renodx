// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "families.hpp"
#include "../night/night_normalization.hpp"
namespace hartapfelfx::clouds::families {
// Present-thread native values only. No draw/resource observation, retained game
// objects, descriptor work, worker locks, GPU readbacks or simulation clock.
inline void Update(bool active) {
  namespace native = witcher::night::normalization;
  if(!active || !native::supported || !native::weather_supported) {
    current.store(0,std::memory_order_relaxed);
    return;
  }
  const uint32_t area=native::ReadArea();
  uint32_t from=0,to=0;
  float blend=0;
  uint64_t amounts=0;
  if(area==0 || !native::ReadWeather(&from,&to,&blend,&amounts)) {
    current.store(0,std::memory_order_relaxed);
    return;
  }
  static bool initialized=false;
  if(!initialized) {
    void* manager=nullptr;
    if(!native::Read(native::name_manager,&manager) || !manager)return;
    for(auto& name:names)name.native=native::intern_name(manager,name.text);
    if(!native::names_initialized) {
      for(auto& region:native::regions)native::area_name(&region.name,region.area_enum);
      native::names_initialized=true;
    }
    initialized=true;
  }
  uint32_t region=0;
  for(const auto& candidate:native::regions)if(candidate.name==area)region=candidate.area_enum;
  static uint32_t velen=0;
  if(velen==0)native::area_name(&velen,9);
  if(velen==area)region=1;
  current.store(uint64_t(Find(region,from)) | (uint64_t(Find(region,to))<<8)
      | (uint64_t(std::bit_cast<uint32_t>(blend))<<16),std::memory_order_relaxed);
}
} // namespace hartapfelfx::clouds::families
