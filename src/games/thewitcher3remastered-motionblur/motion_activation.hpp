/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <windows.h>

#include <detours.h>
#include <tlhelp32.h>
#include <atomic>
#include <cstdint>
#include <cstring>
#include <vector>

#include "../../utils/pe_image.hpp"

namespace witcher::motion::activation {
inline std::atomic<bool> enhanced = false;
inline bool attempted = false, installed = false;
using BuildFlags = void (*)(void*);
inline BuildFlags build_flags = nullptr;
inline unsigned char** world_slot = nullptr;
constexpr unsigned VIEW_FLAGS = 0xf738;
constexpr uint32_t MOTION_BLUR = 0x800;

inline void BuildFlagsHook(void* view) {
  build_flags(view);
  if (!enhanced.load(std::memory_order_relaxed)) return;
  // Preserve all four native scene/postprocessing guards. The original builder
  // intentionally emits only minimal flags for loading, menus or disabled views.
  const auto* world = *world_slot;
  if (!world || !static_cast<const unsigned char*>(view)[0xf5e9]) return;
  const unsigned char* scene = nullptr;
  std::memcpy(&scene, world + 0xf0, sizeof(scene));
  if (!scene) return;
  uintptr_t scene_data = 0;
  std::memcpy(&scene_data, scene + 8, sizeof(scene_data));
  if (!scene_data) return;
  auto* flags = reinterpret_cast<uint32_t*>(static_cast<unsigned char*>(view) + VIEW_FLAGS);
  *flags |= MOTION_BLUR;
  // Never change AllowMotionBlur or the game's config: Native simply gets the
  // original flags on the next view update, including a user preference of Off.
}

inline bool ValidateImage(const unsigned char* image) {
  build_flags = nullptr;
  world_slot = nullptr;
  const renodx::utils::pe::Image executable(image);
  if (!executable) return false;
  // Exact native builder anchors, rather than a fixed RVA or a broad patch.
  // RIP-relative globals may move between builds; the AllowMotionBlur CVar
  // descriptor must independently confirm what the 0x800 bit represents.
  constexpr unsigned char prefix[] = {0x48, 0x89, 0x5c, 0x24, 0x10, 0x57, 0x48, 0x83, 0xec, 0x20, 0x48, 0x8b, 0x05};
  constexpr unsigned char guards[] = {
      0x33, 0xdb, 0x48, 0x8b, 0xf9, 0x48, 0x85, 0xc0, 0x0f, 0x84, 0x78, 0x01, 0x00, 0x00,
      0x48, 0x8b, 0x88, 0xf0, 0x00, 0x00, 0x00, 0x48, 0x85, 0xc9, 0x0f, 0x84, 0x68, 0x01, 0x00, 0x00,
      0x48, 0x39, 0x59, 0x08, 0x0f, 0x84, 0x5e, 0x01, 0x00, 0x00,
      0x38, 0x9f, 0xe9, 0xf5, 0x00, 0x00, 0x0f, 0x84, 0x52, 0x01, 0x00, 0x00};
  constexpr unsigned char load[] = {0x0f, 0xb6, 0x05};
  constexpr unsigned char mask[] = {0x1b, 0xd2, 0x81, 0xe2, 0x00, 0x10, 0x00, 0x00, 0xf6, 0xd8, 0x1b, 0xc9, 0x81, 0xe1, 0x00, 0x08, 0x00, 0x00};
  constexpr unsigned char store[] = {0x83, 0xca, 0x01, 0x89, 0x97, 0x38, 0xf7, 0x00, 0x00, 0x48, 0x83, 0xc4, 0x20, 0x5f, 0xc3};
  const uint32_t offset = executable.FindUnique({{0x14d, mask}, {0, prefix}, {0x11, guards}, {0x146, load}, {0x1ac, store}});
  if (!offset || !executable.InSection(offset, 0x1bb, IMAGE_SCN_MEM_EXECUTE)) return false;
  const uint32_t allow = executable.Relative(offset + 0x146, 3, 7, IMAGE_SCN_MEM_WRITE);
  const uint32_t world = executable.Relative(offset + 0xa, 3, 7, IMAGE_SCN_MEM_WRITE);
  if (!allow || allow != executable.FindCvar("AllowMotionBlur")
      || !world || !executable.InSection(world, sizeof(void*), IMAGE_SCN_MEM_WRITE)) return false;
  build_flags = reinterpret_cast<BuildFlags>(const_cast<unsigned char*>(image) + offset);
  world_slot = reinterpret_cast<unsigned char**>(const_cast<unsigned char*>(image) + world);
  return true;
}

inline bool Install(const unsigned char* image) {
  if (attempted) return installed;
  attempted = true;
  if (!ValidateImage(image)) return false;
  // Follow the existing Darker Nights native-hook lifetime and worker-thread
  // enlistment strategy. The hook runs once per view, never once per draw.
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
  HMODULE pinned = nullptr;
  valid = valid && GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN, reinterpret_cast<LPCWSTR>(&BuildFlagsHook), &pinned);
  if (valid && DetourTransactionBegin() == NO_ERROR) {
    valid = DetourUpdateThread(GetCurrentThread()) == NO_ERROR;
    for (HANDLE thread : threads)
      if (valid) valid = DetourUpdateThread(thread) == NO_ERROR;
    if (valid) valid = DetourAttach(reinterpret_cast<void**>(&build_flags), reinterpret_cast<void*>(&BuildFlagsHook)) == NO_ERROR;
    if (valid)
      installed = DetourTransactionCommit() == NO_ERROR;
    else
      DetourTransactionAbort();
  }
  for (HANDLE thread : threads) CloseHandle(thread);
  return installed;
}
}  // namespace witcher::motion::activation
