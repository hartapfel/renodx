// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <algorithm>
#include <array>
#include <atomic>
#include <bit>
#include <cmath>
#include <cstring>
#include <cstdint>
namespace hartapfelfx::sky::emission {
inline std::atomic_bool enabled=false;
inline std::atomic<float> daytime=-1.f,evening_blend=1.f,dusk_weight=0.f;
// Native evaluated environment time, not the animation clock or Moon phase.
inline void ObserveTime(float time) {
  if(enabled.load(std::memory_order_relaxed))
    daytime.store(std::isfinite(time)&&time>=0.f&&time<=1.f?time:-1.f,std::memory_order_relaxed);
}
// Two positive chromaticity coordinates plus validity/tint flags in one atomic
// word. RGB sum is one; intensity stays with the native light, not this cache.
inline std::atomic_uint64_t native_primary=0,moon_material=0,sun=0,moon=0,primary=0;
inline uint64_t Pack(const float* colour) {
  const float sum=colour[0]+colour[1]+colour[2];
  if(!std::isfinite(sum)||sum<=1.e-12f||colour[0]<0||colour[1]<0||colour[2]<0)return 0;
  return uint64_t(std::bit_cast<uint32_t>(colour[0]/sum))
      |(uint64_t(std::bit_cast<uint32_t>(colour[1]/sum))<<32)|0x8000000000000000ull;
}
inline std::array<float,4> Unpack(uint64_t word) {
  if(!(word>>63))return {};
  const float r=std::bit_cast<float>(uint32_t(word)&0x7fffffffu);
  const float g=std::bit_cast<float>(uint32_t(word>>32)&0x7fffffffu);
  return {r,g,std::max(0.f,1.f-r-g),1.f};
}
inline float Smooth(float a,float b,float value) {
  const float t=std::clamp((value-a)/(b-a),0.f,1.f);return t*t*(3.f-2.f*t);
}
inline void ObservePrimary(const void* input) {
  if(!enabled.load(std::memory_order_relaxed))return;
  std::array<float,3> colour{};std::memcpy(colour.data(),input,sizeof(colour));
  if(const auto word=Pack(colour.data()))native_primary.store(word,std::memory_order_relaxed);
}
inline void ObserveMoon(const float* colour,bool tint) {
  if(!enabled.load(std::memory_order_relaxed))return;
  moon_material.store(Pack(colour)|(tint?0x80000000ull:0ull),std::memory_order_relaxed);
}
inline void ObserveFrame(const void* input) {
  if(!enabled.load(std::memory_order_relaxed))return;
  const auto* frame=static_cast<const float*>(input);
  auto solar=Unpack(native_primary.load(std::memory_order_relaxed));
  const auto glow=Unpack(Pack(frame+199*4));
  if(solar[3]==0.f)solar={1.f/3.f,1.f/3.f,1.f/3.f,1};
  const float length=std::sqrt(frame[204*4+1]*frame[204*4+1]+frame[204*4+2]*frame[204*4+2]+frame[204*4+3]*frame[204*4+3]);
  if(!std::isfinite(length)||length<.5f)return;
  const float elevation=frame[204*4+3]/length;
  const float time=daytime.load(std::memory_order_relaxed);
  dusk_weight.store((time<0.f?1.f:Smooth(.5f,.75f,time)*(1.f-Smooth(23.f/24.f,1.f,time)))
      *(1.f-Smooth(.104528463f,.342020143f,elevation))
      *Smooth(-.104528463f,-.052335956f,elevation),std::memory_order_relaxed);
  const float warmth=(1.f-Smooth(.104528463f,.342020143f,elevation))
      *Smooth(0.f,.15f,glow[0]-glow[2])*glow[3];
  for(unsigned i=0;i<3;++i)solar[i]=std::lerp(solar[i],glow[i],warmth);
  const auto material=moon_material.load(std::memory_order_relaxed);
  auto lunar=Unpack(material);
  if(lunar[3]==0.f)lunar=Unpack(Pack(frame+277*4));
  else if(material&0x80000000ull) {
    for(unsigned i=0;i<3;++i)lunar[i]*=std::max(frame[277*4+i],0.f);
    lunar=Unpack(Pack(lunar.data()));
  }
  sun.store(Pack(solar.data()),std::memory_order_relaxed);
  moon.store(Pack(lunar.data()),std::memory_order_relaxed);
  const float day=lunar[3]>0.f?Smooth(-.104528463f,.017452406f,elevation):1.f;
  std::array<float,3> colour{};
  for(unsigned i=0;i<3;++i)colour[i]=std::lerp(lunar[i],solar[i],day);
  primary.store(Pack(colour.data()),std::memory_order_relaxed);
}
inline void Apply(void* output) {
  if(!enabled.load(std::memory_order_relaxed))return;
  const auto colour=Unpack(primary.load(std::memory_order_relaxed));
  if(colour[3]==0.f)return;
  std::array<float,3> original{};std::memcpy(original.data(),output,sizeof(original));
  const float luminance=original[0]*.2126f+original[1]*.7152f+original[2]*.0722f;
  const float target=colour[0]*.2126f+colour[1]*.7152f+colour[2]*.0722f;
  if(!std::isfinite(luminance)||luminance<=0.f||target<=1.e-8f)return;
  // Blend source irradiance in linear RGB at equal native luminance. The Sun/
  // Moon/cloud emission caches above retain their full authored sunset colour.
  const float blend=1.f-(1.f-evening_blend.load(std::memory_order_relaxed))*dusk_weight.load(std::memory_order_relaxed);
  for(unsigned i=0;i<3;++i)original[i]=std::lerp(original[i],colour[i]*(luminance/target),blend);
  std::memcpy(output,original.data(),sizeof(original));
}
} // namespace hartapfelfx::sky::emission
