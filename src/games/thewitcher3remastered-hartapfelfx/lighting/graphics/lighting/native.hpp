/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once

#include <windows.h>

#include <detours.h>
#include <tlhelp32.h>
#include <vector>

#include "../../../../../utils/pe_image.hpp"
#include "player.hpp"

namespace witcher3graphics::native {

struct Layout {
  uint32_t camera = 0;
  uint32_t direct = 0;
  uint32_t common = 0;
  uint32_t world_gain = 0;
};
inline Layout layout;
inline bool attempted = false;
inline bool installed = false;
using BuildCamera = bool (*)(void*, const void*, const void*, const void*, const void*, float, void*);
using BuildCommon = void (*)(const void*, void*);
using WorldGain = float (*)(const void*);
inline BuildCamera build_camera = nullptr;
inline BuildCommon build_common = nullptr;
inline WorldGain world_gain = nullptr;

inline bool Validate(const unsigned char* mapped_image, Layout* result) {
  *result = {};
  const renodx::utils::pe::Image image(mapped_image);
  if (!image) return false;
  constexpr unsigned char camera_prefix[] = {0x48, 0x8b, 0xc4, 0x48, 0x89, 0x70, 0x10, 0x4c, 0x89, 0x60, 0x18, 0x55, 0x41, 0x56, 0x41, 0x57};
  constexpr unsigned char rgb[] = {0xc4, 0x41, 0x7a, 0x11, 0x77, 0x30, 0xc4, 0x41, 0x7a, 0x11, 0x6f, 0x34, 0xc4, 0x41, 0x7a, 0x11, 0x67, 0x38};
  constexpr unsigned char endpoints[] = {0xc5, 0xfa, 0x11, 0x2f, 0xc5, 0xfa, 0x11, 0x4f, 0x04, 0xc5, 0xfa, 0x11, 0x67, 0x10, 0xc5, 0xfa, 0x11, 0x5f, 0x14, 0xc5, 0xfa, 0x11, 0x57, 0x18};
  constexpr unsigned char direct_prefix[] = {0x48, 0x8b, 0xc4, 0x48, 0x89, 0x58, 0x08, 0x48, 0x89, 0x70, 0x10, 0x57};
  constexpr unsigned char direct_store[] = {0xc5, 0xf8, 0x59, 0x82, 0xe0, 0xef, 0, 0, 0xc5, 0xf8, 0x11, 0x43, 0x10};
  constexpr unsigned char gameplay[] = {0x48, 0x8d, 0x96, 0x20, 0x52, 0, 0, 0x4c, 0x8d, 0x8e, 0x50, 0x51, 0, 0};
  constexpr unsigned char scene[] = {0xba, 0xf0, 0x52, 0, 0, 0x41, 0xb8, 0xc0, 0x53, 0, 0};
  constexpr unsigned char dialogue[] = {0xba, 0x90, 0x54, 0, 0, 0x41, 0xb8, 0x60, 0x55, 0, 0};
  constexpr unsigned char interior[] = {0xba, 0x30, 0x56, 0, 0, 0x41, 0xb8, 0x00, 0x57, 0, 0};
  constexpr unsigned char source_bank[] = {0x4c, 0x8d, 0x2c, 0x40, 0x49, 0xc1, 0xe5, 0x05, 0x49, 0x8d, 0x04, 0x30, 0x49, 0x81, 0xc5, 0xb8, 0xf3, 0, 0};
  constexpr unsigned char matrix[] = {0x48, 0x8d, 0x56, 0x10};
  constexpr unsigned char common_prefix[] = {0x48, 0x8b, 0xc4, 0x48, 0x89, 0x48, 0x08, 0x55, 0x53, 0x56, 0x57, 0x41, 0x54};
  constexpr unsigned char common_output[] = {0x4c, 0x8b, 0xfa};
  constexpr unsigned char gain_input[] = {0x48, 0x8b, 0x4f, 0x08};
  constexpr unsigned char gain_store[] = {0xc4, 0xc1, 0x7a, 0x11, 0x87, 0x70, 0x04, 0, 0};
  constexpr unsigned char gain_read[] = {0xc5, 0xfa, 0x10, 0x81, 0x3c, 0x58, 0, 0};
  result->camera = image.FindUnique({{0, camera_prefix}, {0x3e2, rgb}, {0x148, endpoints}});
  result->direct = image.FindUnique({{0, direct_prefix}, {0x85, direct_store}, {0x1a51, gameplay}, {0x1bee, scene}, {0x1aac, dialogue}, {0x1a9c, interior}, {0x1c04, source_bank}, {0x1c46, matrix}});
  result->common = image.FindUnique({{0, common_prefix}, {0x25, common_output}, {0x1d4f, gain_input}, {0x1d7d, gain_store}});
  if (!result->camera || !result->direct || !result->common) return false;
  for (unsigned offset : {0x1c68u, 0x1d64u}) {
    constexpr unsigned char call[] = {0xe8};
    if (!image.Match(uint64_t(result->direct) + offset, call)
        || image.Relative(result->direct + offset, 1, 5) != result->camera) return false;
  }
  constexpr unsigned char call[] = {0xe8};
  if (!image.Match(uint64_t(result->common) + 0x1d78, call)) return false;
  result->world_gain = image.Relative(result->common + 0x1d78, 1, 5);
  // Reuse the native accessor, including RT/PT impacts and weather sentinels.
  // Never substitute Classic's raw environment field or a global cached gain.
  return result->world_gain && image.InSection(result->world_gain, 0xe7, IMAGE_SCN_MEM_EXECUTE)
         && image.Match(uint64_t(result->world_gain) + 7, gain_read);
}

inline bool CameraHook(void* output, const void* matrix, const void* evaluated,
                       const void* curves, const void* override_color, float blend, void* colors) {
  const bool built = build_camera(output, matrix, evaluated, curves, override_color, blend, colors);
  if (!built) return built;
  const auto controls = player::GetControls();
  const auto source = player::Identify(matrix, evaluated, curves);
  if (!controls.enabled || source == player::Source::unknown) return built;
  player::Apply(output, colors, source,
                controls.match_world ? world_gain(static_cast<const unsigned char*>(matrix) - 0x10) : 1.f, controls);
  return built;
}

inline void CommonHook(const void* input, void* output) {
  build_common(input, output);
  player::ApplyCommon(output, player::GetControls());
}

inline bool Prepare() {
  static const bool validated = Validate(reinterpret_cast<const unsigned char*>(GetModuleHandleW(nullptr)), &layout);
  return validated;
}

inline bool Install(bool attach_common = true) {
  if (attempted) return installed;
  attempted = true;
  const auto* image = reinterpret_cast<const unsigned char*>(GetModuleHandleW(nullptr));
  if (!Prepare()) return false;
  build_camera = reinterpret_cast<BuildCamera>(const_cast<unsigned char*>(image) + layout.camera);
  build_common = reinterpret_cast<BuildCommon>(const_cast<unsigned char*>(image) + layout.common);
  world_gain = reinterpret_cast<WorldGain>(const_cast<unsigned char*>(image) + layout.world_gain);
  HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  if (snapshot == INVALID_HANDLE_VALUE) return false;
  std::vector<HANDLE> threads;
  THREADENTRY32 entry{sizeof(entry)};
  bool valid = Thread32First(snapshot, &entry) != FALSE;
  if (valid) do {
      if (entry.th32OwnerProcessID != GetCurrentProcessId() || entry.th32ThreadID == GetCurrentThreadId()) continue;
      HANDLE thread = OpenThread(THREAD_SUSPEND_RESUME | THREAD_GET_CONTEXT | THREAD_SET_CONTEXT | THREAD_QUERY_INFORMATION,
                                 FALSE, entry.th32ThreadID);
      if (!thread) {
        valid = false;
        break;
      }
      threads.push_back(thread);
    } while (Thread32Next(snapshot, &entry));
  CloseHandle(snapshot);
  // Renderer callbacks can outlive addon unregistration. Pin their code and
  // publish Native on shutdown; never leave workers targeting an unmapped DLL.
  HMODULE pinned = nullptr;
  valid = valid && GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN, reinterpret_cast<LPCWSTR>(&Install), &pinned);
  if (valid && DetourTransactionBegin() == NO_ERROR) {
    valid = DetourUpdateThread(GetCurrentThread()) == NO_ERROR;
    for (HANDLE thread : threads)
      if (valid) valid = DetourUpdateThread(thread) == NO_ERROR;
    if (valid) valid = DetourAttach(reinterpret_cast<void**>(&build_camera), reinterpret_cast<void*>(&CameraHook)) == NO_ERROR;
    if (valid && attach_common) valid = DetourAttach(reinterpret_cast<void**>(&build_common), reinterpret_cast<void*>(&CommonHook)) == NO_ERROR;
    if (valid)
      installed = DetourTransactionCommit() == NO_ERROR;
    else
      DetourTransactionAbort();
  }
  for (HANDLE thread : threads) CloseHandle(thread);
  return installed;
}

}  // namespace witcher3graphics::native
