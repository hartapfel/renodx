/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <atomic>
#include <bit>
#include <cmath>
#include <cstdint>
#include <cstring>

namespace witcher3classic::lighting {
inline float player_control=1.f, player_strength=.2f, player_unify=1.f;
namespace player_fill {
struct Controls {
  bool enabled=false, unify=false;
  float strength=1.f;
};
inline bool supported=false;
// Publish one coherent set at the frame boundary. Native renderer callbacks
// must not read settings while the overlay edits them.
inline std::atomic<uint64_t> published{0};
inline void Update(bool active) {
  const float strength=std::isfinite(player_strength)?std::clamp(player_strength,0.f,1.f):1.f;
  published.store(uint64_t(std::bit_cast<uint32_t>(strength))
      | (uint64_t(active && player_control!=0.f)<<32)
      | (uint64_t(player_unify!=0.f)<<33),std::memory_order_release);
}
inline Controls GetControls() {
  const auto bits=published.load(std::memory_order_acquire);
  return {bool(bits&(1ull<<32)),bool(bits&(1ull<<33)),std::bit_cast<float>(uint32_t(bits))};
}
inline bool Validate(const uint8_t* image) {
  // 1.32's fresh local-light table builder, its count store, and the common
  // builder's native environment +404c -> c71.x transfer. The enclosing
  // night hook installer also validates the PE identity and common ABI.
  constexpr uint8_t prefix[]={0x4c,0x8b,0xdc,0x4d,0x89,0x4b,0x20,0x4d,0x89,0x43,0x18,0x55};
  constexpr uint8_t table[]={0x48,0x8b,0xb9,0xf8,0,0,0};
  constexpr uint8_t count[]={0x89,0x9f,0x90,0x03,0,0};
  constexpr uint8_t environment[]={0xf3,0x41,0x0f,0x10,0x8f,0x4c,0x40,0,0};
  constexpr uint8_t common[]={0xf3,0x41,0x0f,0x11,0x8e,0x70,0x04,0,0};
  return image && std::memcmp(image+0xc39be0,prefix,sizeof(prefix))==0
      && std::memcmp(image+0xc39c02,table,sizeof(table))==0
      && std::memcmp(image+0xc3a24c,count,sizeof(count))==0
      && std::memcmp(image+0xcdc901,environment,sizeof(environment))==0
      && std::memcmp(image+0xcdc912,common,sizeof(common))==0;
}
inline void ApplyCommon(void* constants,const Controls& controls) {
  if(!constants ||!controls.enabled ||!controls.unify)return;
  float native;
  std::memcpy(&native,static_cast<uint8_t*>(constants)+0x470,sizeof(native));
  if(!std::isfinite(native) ||native<0.f)return;
  // Native tagged lights multiply characters by 1 and world surfaces by
  // c71.x. Move that environment gain into their RGB instead, then use 1 for
  // both receivers. Every native material/LOD now follows the same policy.
  const float unified=1.f;
  std::memcpy(static_cast<uint8_t*>(constants)+0x470,&unified,sizeof(unified));
}
inline void ApplyLights(void* constants,const void* environment,const Controls& controls) {
  if(!constants ||!controls.enabled)return;
  float scale=controls.strength;
  if(controls.unify) {
    if(!environment)return;
    float native;
    std::memcpy(&native,static_cast<const uint8_t*>(environment)+0x404c,sizeof(native));
    if(!std::isfinite(native))return;
    scale*=std::max(native,0.f);
  }
  if(scale==1.f)return;
  auto* bytes=static_cast<uint8_t*>(constants);
  uint32_t count;
  std::memcpy(&count,bytes+0x390,sizeof(count));
  if(count>256)return;
  for(uint32_t i=0;i<count;++i) {
    uint32_t flags;
    std::memcpy(&flags,bytes+0x3dc+i*0x90,sizeof(flags));
    // Match the native recipient-gain selector, including tagged variants
    // with additional shape/shadow flags. Ordinary world lights stay native.
    if(!(flags&0x80000000u))continue;
    for(uint32_t channel=0;channel<3;++channel) {
      float color;
      std::memcpy(&color,bytes+0x3d0+i*0x90+channel*4,sizeof(color));
      color*=scale;
      std::memcpy(bytes+0x3d0+i*0x90+channel*4,&color,sizeof(color));
    }
  }
}
using BuildLocalConstants=void(*)(void*,const void*,uint64_t,uint64_t,uint64_t,
    uint32_t,const void*,uint8_t,uint8_t,float);
inline BuildLocalConstants build_local_constants=nullptr;
inline void LocalConstantsHook(void* renderer,const void* environment,uint64_t view,uint64_t camera,
    uint64_t bounds,uint32_t count,const void* lights,uint8_t shadow,uint8_t enabled,float blend) {
  build_local_constants(renderer,environment,view,camera,bounds,count,lights,shadow,enabled,blend);
  const auto controls=GetControls();
  if(!controls.enabled ||!renderer)return;
  void* constants=nullptr;
  std::memcpy(&constants,static_cast<uint8_t*>(renderer)+0xf8,sizeof(constants));
  // This native function rebuilds the records/count on every call. Scaling
  // once here cannot accumulate across frames or depend on shader coverage.
  ApplyLights(constants,environment,controls);
}
}  // namespace player_fill
}  // namespace witcher3classic::lighting
