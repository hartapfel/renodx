/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <windows.h>
#include <tlhelp32.h>
#include <detours.h>

#include <algorithm>
#include <atomic>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <utility>
#include <vector>

namespace witcher::night {

inline float lighting_enabled = 0.f;
inline float darkening_start = 18.f, full_darkness_start = 20.f;
inline float fade_out_start = 4.f, darkening_end = 6.f;
// Start minute plus three forward offsets. Publish the entire schedule at
// once so renderer workers never mix different UI edits within one fade.
inline std::atomic<uint64_t> night_schedule = uint64_t{1080} | (uint64_t{120} << 16)
                                             | (uint64_t{600} << 32) | (uint64_t{720} << 48);
inline float sky_strength = 50.f;
inline float direct_strength = 50.f;
inline float fog_strength = 50.f;
inline float haze_strength = 50.f;
inline float visible_sky_strength = 50.f;
inline float cloud_strength = 50.f;
inline float water_strength = 50.f;
// Gameplay camera fill is independent of the night clock.
inline float camera_strength = 50.f;

// The renderer constructs a per-view environment. Change that copy, never
// the shared environment asset.
using BuildEnvironment = void (*)(void*, const void*);
inline BuildEnvironment build_environment = nullptr;
// Raster global-light constants and the shared per-view constants have
// separate upload paths. Both must be edited alongside the PT view copy.
using BuildConstants = void (*)(const void*, void*);
inline BuildEnvironment build_direct_constants = nullptr;
inline BuildConstants build_common_constants = nullptr;
inline BuildConstants build_global_constants = nullptr;
using BuildCameraLight = bool (*)(void*, const void*, const void*, const void*, const void*, float, void*);
inline BuildCameraLight build_camera_light = nullptr;
inline std::atomic<float> camera_multiplier = 1.f;
inline bool camera_supported = false;
inline std::atomic<float> night_weight = 0.f;
inline std::atomic<float> sky_multiplier = 1.f;
inline std::atomic<float> direct_multiplier = 1.f, fog_multiplier = 1.f;
inline std::atomic<float> haze_multiplier = 1.f, visible_sky_multiplier = 1.f;
inline std::atomic<float> cloud_multiplier = 1.f;
inline std::atomic<float> water_multiplier = 1.f;

// Native impact CVars have independent baselines. Rebase external changes and
// restore exactly, rather than multiplying last frame's edited value again.
struct NativeImpact {
  float* value = nullptr;
  float baseline = 0.f, written = 0.f;

  void Initialize(float* address) {
    value = address;
    baseline = written = *value;
  }

  void Update(float intensity, float weight) {
    const float current = *value;
    if (current != written) baseline = current;
    if (!std::isfinite(baseline)) return;
    written = intensity == 1.f || weight == 0.f || baseline < 0.f
                  ? baseline : baseline * (1.f + (intensity - 1.f) * weight);
    if (current != written) *value = written;
  }
};
inline NativeImpact sky_impact;
inline bool checked = false, supported = false, attempted = false, installed = false;

// The four events must occur in order within one 24-hour cycle. Equal
// adjacent events allow an instant fade or no full-strength plateau.
// Invalid input is neutral, allowing the user to finish editing safely.
inline uint64_t NightSchedule() {
  uint64_t minutes[4];
  unsigned index = 0;
  for (float hour : {darkening_start, full_darkness_start, fade_out_start, darkening_end}) {
    if (!std::isfinite(hour) || hour < 0.f || hour > 24.f) return 0;
    minutes[index++] = static_cast<uint64_t>(std::round(hour * 60.f)) % 1440;
  }
  for (unsigned i = 1; i < 4; ++i) minutes[i] = (minutes[i] + 1440 - minutes[0]) % 1440;
  if (minutes[3] == 0 || minutes[1] > minutes[2] || minutes[2] > minutes[3]) return 0;
  return minutes[0] | (minutes[1] << 16) | (minutes[2] << 32) | (minutes[3] << 48);
}

// Evaluated sun-color curves cache normalized game time at +0x10, shared
// across weather blends. The authored day-weight can leave evening light.
// Apply the user's clock schedule to every native/shader night contribution.
inline float ClockNightWeight(const unsigned char* environment) {
  float time = 0.f;
  std::memcpy(&time, environment + 0x15c0, sizeof(time));
  if (!std::isfinite(time) || time < 0.f || time > 1.f) return 0.f;
  const uint64_t schedule = night_schedule.load(std::memory_order_relaxed);
  if (schedule == 0) return 0.f;
  const float full = static_cast<float>((schedule >> 16) & 0xffff);
  const float fade_out = static_cast<float>((schedule >> 32) & 0xffff);
  const float end = static_cast<float>(schedule >> 48);
  const float elapsed = std::fmod(time * 1440.f + 1440.f - static_cast<float>(schedule & 0xffff), 1440.f);
  if (elapsed >= end) return 0.f;
  const float fade = elapsed < full ? elapsed / full
                   : elapsed <= fade_out ? 1.f : (end - elapsed) / (end - fade_out);
  return fade * fade * (3.f - 2.f * fade);
}

// Modify freshly built renderer data, never shared assets or last frame's
// edited values. Alpha, extinction, light directions and local lights survive.
inline void ScaleRGB(unsigned char* color, float intensity, float weight) {
  if (intensity == 1.f || weight == 0.f) return;
  const float multiplier = 1.f + (intensity - 1.f) * weight;
  for (unsigned channel = 0; channel < 3; ++channel) {
    float value;
    std::memcpy(&value, color + channel * sizeof(float), sizeof(value));
    if (!std::isfinite(value)) continue;
    value *= multiplier;
    std::memcpy(color + channel * sizeof(float), &value, sizeof(value));
  }
}

inline void BuildHook(void* output, const void* input) {
  build_environment(output, input);
  auto* view = static_cast<unsigned char*>(output);
  const unsigned char* environment = nullptr;
  std::memcpy(&environment, static_cast<const unsigned char*>(input) + 0x10, sizeof(environment));
  const float clock_weight = ClockNightWeight(environment);
  // Native cached global-light colors EFE0/EFF0/F000 -> 280/290/2A0.
  // Darker Nights zeros EFE0; this covers the PT/shared-view consumer.
  for (unsigned offset : {0x280u, 0x290u, 0x2a0u}) {
    ScaleRGB(view + offset, direct_multiplier.load(std::memory_order_relaxed), clock_weight);
  }
  // Skylight must follow the same clock fade. The weather-authored day-weight
  // can stay above zero in deep night, leaving residual light at strength 0.
  night_weight.store(clock_weight, std::memory_order_relaxed);
}

inline void DirectConstantsHook(void* renderer, const void* environment) {
  build_direct_constants(renderer, environment);
  unsigned char* constants = nullptr;
  std::memcpy(&constants, static_cast<unsigned char*>(renderer) + 0x690, sizeof(constants));
  const float weight = ClockNightWeight(static_cast<const unsigned char*>(environment));
  const float intensity = direct_multiplier.load(std::memory_order_relaxed);
  // b13 c1/c61/c62: same native colors as the PT view, independent of its
  // constants upload. Do not touch the structured buffers of torch/local lights.
  for (unsigned offset : {0x10u, 0x3d0u, 0x3e0u}) ScaleRGB(constants + offset, intensity, weight);
}

inline void CommonConstantsHook(const void* context, void* output) {
  build_common_constants(context, output);
  const unsigned char* environment = nullptr;
  std::memcpy(&environment, static_cast<const unsigned char*>(context) + 0x8, sizeof(environment));
  const float weight = ClockNightWeight(environment);
  // This builder also runs without PT. Publish its clock so cloud/smoke
  // injection and native impacts do not retain a stale PT-frame night weight.
  night_weight.store(weight, std::memory_order_relaxed);
  auto* constants = static_cast<unsigned char*>(output);
  // b12 c184.xy/c185.xy: native environment-probe ambient/reflection
  // strength in light and shadow, from environment +1A2C/+1A4C/+1A6C/+1A8C.
  // E6A77B56 uses these for the outdoor probe contribution independently
  // of PTSkyImpact. Preserve c184.zw (direct diffuse/specular enables),
  // c185.z (distance scaling), and separate torch/point-light accumulation.
  const float sky_intensity = sky_multiplier.load(std::memory_order_relaxed);
  if (sky_intensity != 1.f && weight != 0.f) {
    const float multiplier = 1.f + (sky_intensity - 1.f) * weight;
    for (unsigned offset : {0xb80u, 0xb84u, 0xb90u, 0xb94u}) {
      float value;
      std::memcpy(&value, constants + offset, sizeof(value));
      if (!std::isfinite(value)) continue;
      value *= multiplier;
      std::memcpy(constants + offset, &value, sizeof(value));
    }
    // Native c185.w is zeroed padding (guarded store at RVA 1BE0142).
    // The new irradiance path skips c184.xy; carry its factor in this
    // existing buffer without extending the compute root signature.
    // Zero stays native; the replacement accepts only tagged [-3,-1].
    const float tagged_multiplier = -1.f - multiplier;
    std::memcpy(constants + 0xb9c, &tagged_multiplier, sizeof(tagged_multiplier));
  }
  // b12 c39-c41: directional fog front/middle/back; c189/c191: custom
  // fog color and its override. The latter blends over the directional color
  // in both scene and sky/material fog, and otherwise leaves a blue glow.
  // Keep extinction/density and c189.w/c191.w (amount), not just coverage.
  for (unsigned offset : {0x270u, 0x280u, 0x290u, 0xbd0u, 0xbf0u}) {
    ScaleRGB(constants + offset, fog_multiplier.load(std::memory_order_relaxed), weight);
  }
  // b12 c45-c47: aerial colors; c194: custom distance-fog color.
  for (unsigned offset : {0x2d0u, 0x2e0u, 0x2f0u, 0xc20u}) {
    ScaleRGB(constants + offset, haze_multiplier.load(std::memory_order_relaxed), weight);
  }
  // b12 c195-c202: base/horizon sky and sun/moon sky/horizon radiance.
  // Scale colors rather than saturated influence factors (c206) so the
  // entire sky can reach zero and 100 really doubles the native radiance.
  for (unsigned offset = 0xc30; offset <= 0xca0; offset += 0x10) {
    ScaleRGB(constants + offset, visible_sky_multiplier.load(std::memory_order_relaxed), weight);
  }
  // 3B15DAAB adds a separate directional horizon gradient after sky/fog:
  // lerp(Custom1/c278, FX_SkyRain/c249, direction) * horizon mask.
  // These native environment colors bypass c195-c202. Custom1 also tints
  // distant clouds in B7D286D5; keep that shared sky tint consistent.
  for (unsigned offset : {0xf90u, 0x1160u}) {
    ScaleRGB(constants + offset, visible_sky_multiplier.load(std::memory_order_relaxed), weight);
  }
  // Native color-group getter 231A260 -> conversion 3300C0 -> b12 c232+.
  // FX_Sky through FX_SkySunset (12-16) are the main/background cloud
  // material colors, despite the historical enum names. Darker Nights edits
  // these same environment curves. Preserve their separately authored alpha.
  // FX_SkyRain (17) and Custom1 (46) are handled by Sky Brightness above.
  for (unsigned offset = 0xf40; offset <= 0xf80; offset += 0x10) {
    ScaleRGB(constants + offset, cloud_multiplier.load(std::memory_order_relaxed), weight);
  }
}

inline void GlobalConstantsHook(const void* context, void* output) {
  build_global_constants(context, output);
  const unsigned char* environment = nullptr;
  std::memcpy(&environment, context, sizeof(environment));
  const float weight = ClockNightWeight(environment);
  const float intensity = water_multiplier.load(std::memory_order_relaxed);
  if (intensity == 1.f || weight == 0.f) return;
  auto* constants = static_cast<unsigned char*>(output);
  // GlobalShaderConsts b0: native waterColor RGB at c11.xyz; ambient and
  // diffuse scales at c12.zw. The renderer copies these from evaluated
  // environment +D70/+D88/+D8C. Darker Nights changes the same fields.
  // Preserve c11.w/c12.xy (flow, Fresnel and caustics), foam, underwater
  // parameters, light data and every reflection texture/sampler binding.
  ScaleRGB(constants + 0xb0, intensity, weight);
  const float multiplier = 1.f + (intensity - 1.f) * weight;
  for (unsigned offset : {0xc8u, 0xccu}) {
    float value;
    std::memcpy(&value, constants + offset, sizeof(value));
    if (!std::isfinite(value)) continue;
    value *= multiplier;
    std::memcpy(constants + offset, &value, sizeof(value));
  }
}

inline bool CameraLightHook(void* output, const void* matrix, const void* evaluated,
                            const void* curves, const void* override_color, float blend, void* colors) {
  const bool built = build_camera_light(output, matrix, evaluated, curves, override_color, blend, colors);
  // 1C6A2E0's gameplay pair (type 1): matrix = environment +10,
  // evaluated light = +F418/+F448, curves = +5150/+5220. Other types
  // are story-scene/Cat lights. Match both native inputs; never select by
  // radius, color or output index, which can also match ordinary lights.
  const auto origin = reinterpret_cast<uintptr_t>(matrix);
  const auto light_offset = reinterpret_cast<uintptr_t>(evaluated) - origin;
  const auto curve_offset = reinterpret_cast<uintptr_t>(curves) - origin;
  if (built && colors == nullptr
      && ((light_offset == 0xf408 && curve_offset == 0x5140)
          || (light_offset == 0xf438 && curve_offset == 0x5210))) {
    // Native 35CE42/48/4E writes linear RGB at +30/+34/+38. Native
    // fades, PT impact and disable switches still apply after this call.
    ScaleRGB(static_cast<unsigned char*>(output) + 0x30,
             camera_multiplier.load(std::memory_order_relaxed), 1.f);
  }
  return built;
}

inline bool Supported() {
  if (checked) return supported;
  checked = true;
  const auto* image = reinterpret_cast<const unsigned char*>(GetModuleHandleW(nullptr));
  const auto* dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(image);
  if (!image || dos->e_magic != IMAGE_DOS_SIGNATURE || dos->e_lfanew < 0 || dos->e_lfanew > 0x1000) return false;
  const auto* pe = reinterpret_cast<const IMAGE_NT_HEADERS64*>(image + dos->e_lfanew);
  if (pe->Signature != IMAGE_NT_SIGNATURE || pe->FileHeader.Machine != IMAGE_FILE_MACHINE_AMD64
      || pe->FileHeader.TimeDateStamp != 0x6abd8695 || pe->OptionalHeader.SizeOfImage != 0x63f8000) return false;
  constexpr unsigned char prefix[] = {0x48,0x8b,0xc4,0x48,0x89,0x58,0x10,0x48,0x89,0x70,0x18,0x48,0x89,0x78,0x20,0x55};
  constexpr unsigned char day_store[] = {0x8b,0x87,0xc4,0x0d,0x00,0x00,0x89,0x83,0xb4,0x03,0x00,0x00};
  if (std::memcmp(image + 0x1c27730, prefix, sizeof(prefix))
      || std::memcmp(image + 0x1c284bd, day_store, sizeof(day_store))) return false;
  constexpr unsigned char direct_prefix[] = {0x48,0x8b,0xc4,0x48,0x89,0x58,0x08,0x48,0x89,0x70,0x10,0x57};
  constexpr unsigned char direct_store[] = {0xc5,0xf8,0x59,0x82,0xe0,0xef,0x00,0x00,0xc5,0xf8,0x11,0x43,0x10};
  constexpr unsigned char common_prefix[] = {0x48,0x8b,0xc4,0x48,0x89,0x48,0x08,0x55,0x53,0x56,0x57,0x41,0x54};
  constexpr unsigned char fog_read[] = {0x48,0x8d,0x93,0x80,0x34,0x00,0x00};
  constexpr unsigned char custom_fog_store[] = {0xc4,0xc1,0x7a,0x11,0x8f,0xd0,0x0b,0x00,0x00};
  constexpr unsigned char custom_fog_override_store[] = {0xc4,0xc1,0x7a,0x11,0x8f,0xf0,0x0b,0x00,0x00};
  constexpr unsigned char sky_store[] = {0xc4,0xc1,0x7a,0x11,0x8f,0x30,0x0c,0x00,0x00};
  constexpr unsigned char group_base[] = {0x49,0x8d,0x9f,0x84,0x0e,0x00,0x00};
  constexpr unsigned char group_read[] = {0x48,0x81,0xc1,0xd0,0x3f,0x00,0x00};
  constexpr unsigned char ambient_store[] = {0xc4,0xc1,0x7a,0x11,0x8f,0x80,0x0b,0x00,0x00};
  constexpr unsigned char probe_padding_store[] = {0x45,0x89,0xa7,0x9c,0x0b,0x00,0x00};
  constexpr unsigned char reflection_store[] = {0xc4,0xc1,0x7a,0x11,0x8f,0x90,0x0b,0x00,0x00};
  constexpr unsigned char global_prefix[] = {0x48,0x83,0xec,0x78,0x4c,0x8b,0x01,0x4c,0x8b,0xc9};
  constexpr unsigned char water_color[] = {0x8b,0x81,0x70,0x0d,0x00,0x00,0x89,0x82,0xb0,0x00,0x00,0x00};
  constexpr unsigned char water_scales[] = {
      0x8b,0x81,0x88,0x0d,0x00,0x00,0x89,0x82,0xc8,0x00,0x00,0x00,
      0x8b,0x81,0x8c,0x0d,0x00,0x00,0x89,0x82,0xcc,0x00,0x00,0x00};
  if (std::memcmp(image + 0x1c68a40, direct_prefix, sizeof(direct_prefix))
      || std::memcmp(image + 0x1c68ac5, direct_store, sizeof(direct_store))
      || std::memcmp(image + 0x1bde2d0, common_prefix, sizeof(common_prefix))
      || std::memcmp(image + 0x1bdec60, fog_read, sizeof(fog_read))
      || std::memcmp(image + 0x1bdf26c, custom_fog_store, sizeof(custom_fog_store))
      || std::memcmp(image + 0x1bdf42f, custom_fog_override_store, sizeof(custom_fog_override_store))
      || std::memcmp(image + 0x1bdf65e, sky_store, sizeof(sky_store))
      || std::memcmp(image + 0x1bde952, group_base, sizeof(group_base))
      || std::memcmp(image + 0x1bde966, group_read, sizeof(group_read))
      || std::memcmp(image + 0x1be00ae, ambient_store, sizeof(ambient_store))
      || std::memcmp(image + 0x1be0162, reflection_store, sizeof(reflection_store))
      || std::memcmp(image + 0x1be0142, probe_padding_store, sizeof(probe_padding_store))
      || std::memcmp(image + 0x1c75c60, global_prefix, sizeof(global_prefix))
      || std::memcmp(image + 0x1c75ea3, water_color, sizeof(water_color))
      || std::memcmp(image + 0x1c75eee, water_scales, sizeof(water_scales))) return false;
  // Validate the skylight CVar descriptor, not just its writable address.
  {
    constexpr unsigned rva = 0x513f728;
    constexpr char name[] = "PTSkyImpact";
    const char* key = nullptr;
    float* value = nullptr;
    std::memcpy(&key, image + rva - 32, sizeof(key));
    std::memcpy(&value, image + rva - 16, sizeof(value));
    if (reinterpret_cast<uintptr_t>(key) < reinterpret_cast<uintptr_t>(image)
        || reinterpret_cast<uintptr_t>(key) - reinterpret_cast<uintptr_t>(image) > pe->OptionalHeader.SizeOfImage - std::strlen(name) - 1
        || std::memcmp(key, name, std::strlen(name) + 1) || value != reinterpret_cast<const float*>(image + rva)
        || !std::isfinite(*value)) return false;
  }
  build_environment = reinterpret_cast<BuildEnvironment>(const_cast<unsigned char*>(image) + 0x1c27730);
  build_direct_constants = reinterpret_cast<BuildEnvironment>(const_cast<unsigned char*>(image) + 0x1c68a40);
  build_common_constants = reinterpret_cast<BuildConstants>(const_cast<unsigned char*>(image) + 0x1bde2d0);
  build_global_constants = reinterpret_cast<BuildConstants>(const_cast<unsigned char*>(image) + 0x1c75c60);
  // Optional camera hook: a different build must not disable the existing
  // night controls just because its camera-light implementation changed.
  constexpr unsigned char camera_prefix[] = {
      0x48,0x8b,0xc4,0x48,0x89,0x70,0x10,0x4c,0x89,0x60,0x18,0x55,0x41,0x56,0x41,0x57};
  constexpr unsigned char camera_sources[] = {
      0x48,0x8d,0x96,0x20,0x52,0x00,0x00,0x4c,0x8d,0x8e,0x50,0x51,0x00,0x00};
  constexpr unsigned char camera_store[] = {
      0xc4,0x41,0x7a,0x11,0x77,0x30,0xc4,0x41,0x7a,0x11,0x6f,0x34,
      0xc4,0x41,0x7a,0x11,0x67,0x38};
  constexpr unsigned char camera_call0[] = {0xe8,0xb3,0x23,0x6f,0xfe};
  constexpr unsigned char camera_call1[] = {0xe8,0xb7,0x22,0x6f,0xfe};
  camera_supported = !std::memcmp(image + 0x35ca60, camera_prefix, sizeof(camera_prefix))
      && !std::memcmp(image + 0x1c6a491, camera_sources, sizeof(camera_sources))
      && !std::memcmp(image + 0x35ce42, camera_store, sizeof(camera_store))
      && !std::memcmp(image + 0x1c6a6a8, camera_call0, sizeof(camera_call0))
      && !std::memcmp(image + 0x1c6a7a4, camera_call1, sizeof(camera_call1));
  if (camera_supported) build_camera_light = reinterpret_cast<BuildCameraLight>(const_cast<unsigned char*>(image) + 0x35ca60);
  sky_impact.Initialize(reinterpret_cast<float*>(const_cast<unsigned char*>(image) + 0x513f728));
  supported = true;
  return true;
}

inline bool Install() {
  if (attempted) return installed;
  attempted = true;
  if (!Supported()) return false;
  HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  if (snapshot == INVALID_HANDLE_VALUE) return false;
  std::vector<HANDLE> threads;
  THREADENTRY32 entry{sizeof(entry)};
  bool valid = Thread32First(snapshot, &entry) != FALSE;
  if (valid) do {
    if (entry.th32OwnerProcessID != GetCurrentProcessId() || entry.th32ThreadID == GetCurrentThreadId()) continue;
    HANDLE thread = OpenThread(THREAD_SUSPEND_RESUME | THREAD_GET_CONTEXT | THREAD_SET_CONTEXT | THREAD_QUERY_INFORMATION,
                              FALSE, entry.th32ThreadID);
    if (!thread) { valid = false; break; }
    threads.push_back(thread);
  } while (Thread32Next(snapshot, &entry));
  CloseHandle(snapshot);
  // Native renderer callbacks may run on workers. Keep the DLL mapped while
  // those callbacks exist, including during a ReShade addon reload.
  HMODULE pinned = nullptr;
  valid = valid && GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN,
                                    reinterpret_cast<LPCWSTR>(&Install), &pinned);
  if (valid && DetourTransactionBegin() == NO_ERROR) {
    valid = DetourUpdateThread(GetCurrentThread()) == NO_ERROR;
    for (HANDLE thread : threads) if (valid) valid = DetourUpdateThread(thread) == NO_ERROR;
    if (valid) valid = DetourAttach(reinterpret_cast<void**>(&build_environment), reinterpret_cast<void*>(&BuildHook)) == NO_ERROR;
    if (valid) valid = DetourAttach(reinterpret_cast<void**>(&build_direct_constants), reinterpret_cast<void*>(&DirectConstantsHook)) == NO_ERROR;
    if (valid) valid = DetourAttach(reinterpret_cast<void**>(&build_common_constants), reinterpret_cast<void*>(&CommonConstantsHook)) == NO_ERROR;
    if (valid) valid = DetourAttach(reinterpret_cast<void**>(&build_global_constants), reinterpret_cast<void*>(&GlobalConstantsHook)) == NO_ERROR;
    if (valid && camera_supported) valid = DetourAttach(reinterpret_cast<void**>(&build_camera_light), reinterpret_cast<void*>(&CameraLightHook)) == NO_ERROR;
    if (valid) installed = DetourTransactionCommit() == NO_ERROR;
    else DetourTransactionAbort();
  }
  for (HANDLE thread : threads) CloseHandle(thread);
  if (installed) {
    sky_impact.Initialize(sky_impact.value);
  } else supported = false;
  return installed;
}

inline void Update(bool enabled, bool require_clock = false) {
  const uint64_t schedule = NightSchedule();
  night_schedule.store(schedule, std::memory_order_relaxed);
  const bool night_enabled = enabled && lighting_enabled == 1.f && schedule != 0;
  if (!installed && !(night_enabled && require_clock)
      && (!night_enabled || (sky_strength == 50.f && direct_strength == 50.f
      && fog_strength == 50.f && haze_strength == 50.f
      && visible_sky_strength == 50.f && cloud_strength == 50.f && water_strength == 50.f))
      && (!enabled || camera_strength == 50.f)) return;
  if (!Install()) return;
  camera_multiplier.store(enabled && std::isfinite(camera_strength) ? std::clamp(camera_strength / 50.f, 0.f, 2.f) : 1.f,
                          std::memory_order_relaxed);
  for (const auto& [strength, multiplier] : {
           std::pair{sky_strength, &sky_multiplier},
           std::pair{direct_strength, &direct_multiplier}, std::pair{fog_strength, &fog_multiplier},
           std::pair{haze_strength, &haze_multiplier}, std::pair{visible_sky_strength, &visible_sky_multiplier},
           std::pair{cloud_strength, &cloud_multiplier}, std::pair{water_strength, &water_multiplier}}) {
    multiplier->store(night_enabled && std::isfinite(strength) ? std::clamp(strength / 50.f, 0.f, 2.f) : 1.f,
                      std::memory_order_relaxed);
  }
  const float weight = night_weight.load(std::memory_order_relaxed);
  sky_impact.Update(sky_multiplier.load(std::memory_order_relaxed), weight);
}
}  // namespace witcher::night
