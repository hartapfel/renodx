/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <array>
#include <mutex>
#include <shared_mutex>
#include <unordered_set>
#include "player_fill.hpp"

namespace witcher3classic::lighting::player_fill::scene_fill {
// Story-scene point/spot lights are ordinary light proxies: their RGB, flags,
// radius and receiver channels cannot establish ownership. Record provenance
// at the dedicated story-light spawner instead, before render-thread enqueue.
struct Sources {
  std::shared_mutex mutex;
  std::unordered_set<const void*> components,proxies;
};
inline Sources* sources=new Sources;
inline thread_local unsigned spawn_depth=0;
inline thread_local const void* environment=nullptr;
inline thread_local Controls controls;

using Spawn=void*(*)(void*,const void*);
using CreateComponent=void*(*)(void*,const void*,const void*);
using CreateProxy=void*(*)(void*,const void* const*);
using Destroy=void(*)(void*);
using BuildBank=void(*)(void*,const void*,const void*,const void*,const void*,uint32_t,
    const void* const*,bool,bool,float);
using BuildPoint=void(*)(void*,const void*,const void*,bool,const void*);
using BuildSpot=void(*)(void*,const void*,const void*,const void*,bool);
inline Spawn spawn=nullptr;
inline CreateComponent create_component=nullptr;
inline CreateProxy create_proxy=nullptr;
inline Destroy destroy_component=nullptr,destroy_proxy=nullptr;
inline BuildBank build_bank=nullptr;
inline BuildPoint build_point=nullptr;
inline BuildSpot build_spot=nullptr;

struct Contract {uint32_t rva;std::array<uint8_t,16> bytes;};
inline constexpr Contract contracts[]={
  {0x78b6c0,{0x48,0x89,0x5c,0x24,0x18,0x55,0x57,0x41,0x56,0x48,0x8d,0xac,0x24,0x30,0xff,0xff}},
  {0xfb650,{0x40,0x53,0x56,0x57,0x41,0x54,0x48,0x83,0xec,0x48,0x48,0x8b,0x02,0x48,0x8b,0x1d}},
  {0xbeaca0,{0x48,0x89,0x5c,0x24,0x10,0x57,0x48,0x83,0xec,0x20,0x48,0x8b,0x42,0x18,0x48,0x8b}},
  {0x175510,{0x40,0x53,0x48,0x83,0xec,0x20,0x48,0x8d,0x05,0xab,0x57,0xcb,0x01,0x48,0x8b,0xd9}},
  {0xcc4070,{0x48,0x89,0x5c,0x24,0x08,0x48,0x89,0x74,0x24,0x10,0x57,0x48,0x83,0xec,0x40,0x48}},
  {0xc39be0,{0x4c,0x8b,0xdc,0x4d,0x89,0x4b,0x20,0x4d,0x89,0x43,0x18,0x55,0x53,0x56,0x57,0x41}},
  {0xc3c990,{0x48,0x89,0x6c,0x24,0x18,0x56,0x8b,0x02,0xf3,0x0f,0x10,0x4a,0x08,0xf3,0x0f,0x10}},
  {0xc3cbe0,{0x48,0x8b,0xc4,0x48,0x89,0x58,0x10,0x48,0x89,0x70,0x18,0x55,0x57,0x41,0x56,0x48}},
};
inline bool Validate(const uint8_t* image) {
  if(!image)return false;
  for(const auto& c:contracts)if(std::memcmp(image+c.rva,c.bytes.data(),c.bytes.size()))return false;
  return true;
}

inline void* SpawnHook(void* player,const void* name) {
  struct Scope {Scope(){++spawn_depth;} ~Scope(){--spawn_depth;}} scope;
  return spawn(player,name);
}
inline void* CreateComponentHook(void* entity,const void* type,const void* name) {
  void* component=create_component(entity,type,name);
  if(component &&spawn_depth) {
    std::unique_lock lock(sources->mutex);sources->components.insert(component);
  }
  return component;
}
inline void* CreateProxyHook(void* renderer,const void* const* description) {
  void* proxy=create_proxy(renderer,description);
  if(!proxy ||!description ||!description[0])return proxy;
  uint32_t type;std::memcpy(&type,static_cast<const uint8_t*>(proxy)+0x10,4);
  if(type!=3 &&type!=4)return proxy; // point/spot only; no dimmers or geometry
  std::unique_lock lock(sources->mutex);
  if(spawn_depth)sources->components.insert(description[0]);
  if(sources->components.contains(description[0]))sources->proxies.insert(proxy);
  return proxy;
}
inline void DestroyComponentHook(void* component) {
  {std::unique_lock lock(sources->mutex);sources->components.erase(component);}
  destroy_component(component);
}
inline void DestroyProxyHook(void* proxy) {
  {std::unique_lock lock(sources->mutex);sources->proxies.erase(proxy);}
  // Keep replaced proxies tagged until their ACTUAL destruction: old queued
  // frames may still reference them after the component creates a replacement.
  destroy_proxy(proxy);
}
inline void Apply(void* output,const void* proxy,const void* native_environment,const Controls& settings) {
  if(!settings.enabled ||!output ||!proxy ||!native_environment)return;
  {std::shared_lock lock(sources->mutex);if(!sources->proxies.contains(proxy))return;}
  float scale=settings.cutscene_strength;
  if(settings.unify) {
    float gain;std::memcpy(&gain,static_cast<const uint8_t*>(native_environment)+0x404c,4);
    if(!std::isfinite(gain))return;
    scale*=std::max(gain,0.f);
    uint32_t flags;std::memcpy(&flags,static_cast<uint8_t*>(output)+0x3c,4);
    // These proxies have no camera-fill tag, so their native shaders already
    // use unit receiver gain. Carry the environment gain once in RGB, enable
    // both receivers, and preserve the native type/shadow/volumetric flags.
    flags|=0x1800u;std::memcpy(static_cast<uint8_t*>(output)+0x3c,&flags,4);
  }
  if(scale==1.f)return;
  for(unsigned c=0;c<3;++c) {
    float value;std::memcpy(&value,static_cast<uint8_t*>(output)+0x30+c*4,4);
    value*=scale;std::memcpy(static_cast<uint8_t*>(output)+0x30+c*4,&value,4);
  }
}
inline void BuildPointHook(void* output,const void* position,const void* color,bool shadows,const void* proxy) {
  build_point(output,position,color,shadows,proxy);Apply(output,proxy,environment,controls);
}
inline void BuildSpotHook(void* output,const void* position,const void* color,const void* proxy,bool shadows) {
  build_spot(output,position,color,proxy,shadows);Apply(output,proxy,environment,controls);
}
inline void BuildBankHook(void* renderer,const void* native_environment,const void* camera,const void* evaluated,
    const void* curves,uint32_t count,const void* const* lights,bool shadows,bool secondary,float blend) {
  struct Scope {
    const void* old_environment=environment;Controls old_controls=controls;
    ~Scope(){environment=old_environment;controls=old_controls;}
  } scope;
  environment=native_environment;controls=GetControls();
  build_bank(renderer,native_environment,camera,evaluated,curves,count,lights,shadows,secondary,blend);
}
} // namespace witcher3classic::lighting::player_fill::scene_fill
