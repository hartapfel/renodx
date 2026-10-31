/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <atomic>
#include <bit>
#include <cmath>
#include <cstdint>
#include <cstring>

namespace witcher3classic::lighting {
inline float player_control=1.f, player_strength=.2f, cutscene_strength=.2f, player_unify=1.f;
namespace player_fill {
struct Controls {
  bool enabled=false, unify=false;
  float strength=1.f, cutscene_strength=1.f;
};
inline bool supported=false;
// Publish one coherent set at the frame boundary. Native renderer callbacks
// must not read settings while the overlay edits them.
inline std::atomic<uint64_t> published{0};
inline void Update(bool active) {
  const float strength=std::isfinite(player_strength)?std::clamp(player_strength,0.f,1.f):1.f;
  const float cutscene=std::isfinite(cutscene_strength)?std::clamp(cutscene_strength,0.f,1.f):1.f;
  // Both nonnegative floats leave their sign bits free for the two switches.
  published.store(uint64_t(std::bit_cast<uint32_t>(strength)&0x7fffffffu)
      | (uint64_t(active && player_control!=0.f)<<31)
      | (uint64_t(std::bit_cast<uint32_t>(cutscene)&0x7fffffffu)<<32)
      | (uint64_t(player_unify!=0.f)<<63),std::memory_order_release);
}
inline Controls GetControls() {
  const auto bits=published.load(std::memory_order_acquire);
  return {bool(bits&(1ull<<31)),bool(bits&(1ull<<63)),
      std::bit_cast<float>(uint32_t(bits)&0x7fffffffu),
      std::bit_cast<float>(uint32_t(bits>>32)&0x7fffffffu)};
}
inline bool Validate(const uint8_t* image) {
  // Classic 1.32 camera builder, source pairs in its sole caller, RGB and
  // scene-endpoint stores, and native environment +404c -> common c71.x.
  // The enclosing installer also checks the PE identity and common ABI.
  constexpr uint8_t prefix[]={0x48,0x8b,0xc4,0x48,0x89,0x78,0x10,0x4c,0x89,0x60,0x18,0x55};
  constexpr uint8_t interior[]={0x4c,0x8d,0xb6,0x10,0x3f,0,0,0x4c,0x8d,0xbe,0x40,0x3e,0,0};
  constexpr uint8_t dialogue[]={0x4c,0x8d,0xb6,0x70,0x3d,0,0,0x4c,0x8d,0xbe,0xa0,0x3c,0,0};
  constexpr uint8_t gameplay[]={0x4c,0x8d,0xb6,0x30,0x3a,0,0,0x4c,0x8d,0xbe,0x60,0x39,0,0};
  constexpr uint8_t scene[]={0x48,0x8d,0x86,0xd0,0x3b,0,0};
  constexpr uint8_t scene_first[]={0x4c,0x8d,0xbe,0,0x3b,0,0};
  constexpr uint8_t evaluated[]={0x4c,0x8d,0x86,0xe8,0xb0,0,0,0x48,0x8d,0x0c,0x40,0x48,0xc1,0xe1,0x05};
  constexpr uint8_t matrix[]={0x48,0x8d,0x56,0x10};
  constexpr uint8_t rgb[]={0xf3,0x44,0x0f,0x11,0x77,0x30,0xf3,0x44,0x0f,0x11,0x67,0x34,0xf3,0x44,0x0f,0x11,0x6f,0x38};
  constexpr uint8_t endpoints[]={0xf3,0x0f,0x11,0x66,0x10,0xf3,0x0f,0x11,0x5e,0x14,0xf3,0x0f,0x11,0x56,0x18};
  constexpr uint8_t environment[]={0xf3,0x41,0x0f,0x10,0x8f,0x4c,0x40,0,0};
  constexpr uint8_t common[]={0xf3,0x41,0x0f,0x11,0x8e,0x70,0x04,0,0};
  return image && std::memcmp(image+0xc3c510,prefix,sizeof(prefix))==0
      && std::memcmp(image+0xc39d02,interior,sizeof(interior))==0
      && std::memcmp(image+0xc39d1a,dialogue,sizeof(dialogue))==0
      && std::memcmp(image+0xc39d3a,gameplay,sizeof(gameplay))==0
      && std::memcmp(image+0xc39d93,scene,sizeof(scene))==0
      && std::memcmp(image+0xc39da8,scene_first,sizeof(scene_first))==0
      && std::memcmp(image+0xc39e00,evaluated,sizeof(evaluated))==0
      && std::memcmp(image+0xc39e5a,matrix,sizeof(matrix))==0
      && std::memcmp(image+0xc3c7a6,rgb,sizeof(rgb))==0
      && std::memcmp(image+0xc3c65b,endpoints,sizeof(endpoints))==0
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
enum class CameraSource { unknown, scene, gameplay, dialogue, interior };
inline CameraSource Source(const void* matrix,const void* evaluated,const void* curves) {
  const auto origin=reinterpret_cast<uintptr_t>(matrix);
  const auto light=reinterpret_cast<uintptr_t>(evaluated)-origin;
  const auto curve=reinterpret_cast<uintptr_t>(curves)-origin;
  // Native matrix = environment +10. Require BOTH input identities; output
  // index, light flags, colour and radius cannot distinguish these sources.
  constexpr uintptr_t first_curves[]={0x3af0,0x3950,0x3c90,0x3e30};
  for(unsigned group=0;group<4;++group)for(unsigned second=0;second<2;++second)
    if(light==0xb0d8+group*0x60+second*0x30 &&curve==first_curves[group]+second*0xd0)
      return static_cast<CameraSource>(group+1);
  return CameraSource::unknown;
}
inline void ApplyCameraLight(void* output,const void* matrix,const void* evaluated,const void* curves,
    void* colors,const Controls& controls) {
  if(!controls.enabled ||!output ||!matrix ||!evaluated ||!curves)return;
  const auto source=Source(matrix,evaluated,curves);
  if(source==CameraSource::unknown ||(source==CameraSource::scene)!=(colors!=nullptr))return;
  float scale=source==CameraSource::gameplay?controls.strength:controls.cutscene_strength;
  if(controls.unify) {
    float native;
    std::memcpy(&native,static_cast<const uint8_t*>(matrix)+0x403c,sizeof(native));
    if(!std::isfinite(native))return;
    scale*=std::max(native,0.f);
  }
  if(scale==1.f)return;
  // Scene lights start with zero RGB in the bank. A later native compute
  // dispatch replaces it using these two float4 endpoints. Scale BOTH RGBs
  // before they are copied to that dispatch; preserve alpha/blend weights.
  // Other camera sources write their final linear RGB directly at +30.
  auto* rgb=colors?static_cast<uint8_t*>(colors):static_cast<uint8_t*>(output)+0x30;
  for(unsigned endpoint=0;endpoint<(colors?2u:1u);++endpoint)for(unsigned channel=0;channel<3;++channel) {
    float value;
    std::memcpy(&value,rgb+endpoint*0x10+channel*4,sizeof(value));
    value*=scale;
    std::memcpy(rgb+endpoint*0x10+channel*4,&value,sizeof(value));
  }
}
using BuildCameraLight=bool(*)(void*,const void*,const void*,const void*,const void*,float,void*);
inline BuildCameraLight build_camera_light=nullptr;
inline bool CameraLightHook(void* output,const void* matrix,const void* evaluated,const void* curves,
    const void* override_color,float blend,void* colors) {
  const bool built=build_camera_light(output,matrix,evaluated,curves,override_color,blend,colors);
  // Fresh native outputs only, never retained environment curves or an
  // existing frame's already scaled bank. Failed/disabled lights stay native.
  if(built)ApplyCameraLight(output,matrix,evaluated,curves,colors,GetControls());
  return built;
}
}  // namespace player_fill
}  // namespace witcher3classic::lighting
