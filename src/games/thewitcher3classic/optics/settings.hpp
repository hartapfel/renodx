/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
namespace witcher3classic::optics {
inline bool custom = true;
inline float motion_mode = 0.f;  // Camera + Object, Object Only, Off.
inline float motion_strength = 1.f;
inline float dof_mode = 1.f;  // Native, Custom, Off.
inline float dof_strength = 1.f;
inline float focus_distance = 10.f;
inline float focal_length = 50.f;
inline float aperture = 2.8f;
inline float near_strength = 1.f;
inline float bloom_mode = 1.f;  // Native, Custom
inline float bloom_strength = 1.f;
inline float bloom_size = 2.f;
inline float bloom_extraction = 3.f;
inline bool MotionActive() { return custom && motion_mode < 2.f && motion_strength > 0.f; }
inline bool ObjectOnly() { return MotionActive() && motion_mode == 1.f; }
inline bool NeedsTemporalInputs() {
  return custom && (MotionActive() || (dof_mode == 1.f && dof_strength > 0.f) || (bloom_mode == 1.f && bloom_strength > 0.f));
}
}  // namespace witcher3classic::optics
