// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <algorithm>
#include <atomic>
#include <cmath>
#include <mutex>
#include "../../../../../utils/pe_image.hpp"

namespace witcher3graphics::sun {

// Both native camera builders convert this degree-valued setting to
// tan(diameter / 2). CameraCB c16.w is consumed by ShadowsRGS and the PT
// direct-light/miss sampling paths. Keep their common source consistent.
inline uint32_t Validate(const unsigned char* mapped) {
  const renodx::utils::pe::Image image(mapped);
  if (!image) return 0;
  const uint32_t value = image.FindCvar("SunAngularDiameter");
  if (!value || (value & 3u) || !image.InSection(value, 4, IMAGE_SCN_MEM_WRITE)) return 0;
  constexpr unsigned char load[] = {0xc5,0xfa,0x10,0x05};
  constexpr unsigned char half[] = {0xc5,0xfa,0x59,0x0d};
  constexpr unsigned char degrees[] = {0xc5,0xf2,0x59,0x05};
  constexpr unsigned char call[] = {0xc5,0xf8,0x77,0xe8};
  constexpr unsigned char store[] = {0xc5,0xfa,0x11,0x83,0x0c,0x01,0,0};
  const uint32_t camera = image.FindUnique({{0,load},{8,half},{16,degrees},{24,call},{32,store}});
  constexpr unsigned char other_load[] = {0xc5,0xca,0x59,0x0d};
  constexpr unsigned char other_flags[] = {0x41,0x0f,0xb6,0x45,0x0f};
  constexpr unsigned char other_store[] = {0xc5,0xfa,0x11,0x85,0x70,0x01,0,0};
  const uint32_t other = image.FindUnique({{0,other_load},{8,other_flags},{13,degrees},{27,call},{68,other_store}});
  const uint32_t tangent = camera ? image.Relative(camera+27,1,5) : 0;
  if (!camera || !other || image.Relative(camera,4,8,IMAGE_SCN_MEM_WRITE)!=value
      || image.Relative(other,4,8,IMAGE_SCN_MEM_WRITE)!=value
      || !tangent || tangent!=image.Relative(other+30,1,5)) return 0;
  float half_value, radians, native;
  uint32_t type;
  if (!image.Read(image.Relative(camera+8,4,8,IMAGE_SCN_MEM_READ),&half_value) || half_value!=.5f
      || !image.Read(image.Relative(camera+16,4,8,IMAGE_SCN_MEM_READ),&radians)
      || radians!=.01745329424738884f
      || !image.Read(value-24,&type) || type!=0x202u
      || !image.Read(value,&native) || !std::isfinite(native) || native<0.f || native>180.f) return 0;
  return value;
}

class Diameter {
 public:
  // A validated native float, never an executable instruction or saved config.
  void Apply(float* value, bool enabled, float degrees) {
    if (!value) return;
    std::lock_guard lock(mutex_);
    std::atomic_ref<float> setting(*value);
    if (!enabled || !std::isfinite(degrees)) {
      if (owned_) {
        float expected = written_;
        setting.compare_exchange_strong(expected,native_);
        owned_=false;
      }
      return;
    }
    degrees=std::clamp(degrees,.05f,2.f);
    float observed=setting.load();
    if (!std::isfinite(observed) || observed<0.f || observed>180.f) return;
    // Preserve an external/native update instead of restoring a stale snapshot.
    if (!owned_ || observed!=written_) native_=observed;
    if (setting.compare_exchange_strong(observed,degrees)) {
      written_=degrees;owned_=true;
    }
  }
 private:
  std::mutex mutex_;
  float native_=0.f,written_=0.f;
  bool owned_=false;
};
inline Diameter diameter;
inline float* native_value=nullptr;
inline bool attempted=false;
}  // namespace witcher3graphics::sun
