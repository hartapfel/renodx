/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <windows.h>
#include <atomic>
#include <cstdint>
#include <cstring>
#include <mutex>

namespace witcher3classic::blitzfx {
inline int* runtime_aa = nullptr;
inline std::atomic<bool> temporal_enabled = false;

// Audited BlitzFX 1.1.0 only. A filename is not sufficient evidence: d3d11.dll
// may be Microsoft's implementation, ReShade, or another injector.
inline bool Initialize() {
  static std::once_flag once;
  std::call_once(once, [] {
    for (const auto* name : {L"d3d11.dll", L"blitz-fx.asi"}) {
      const auto* image = reinterpret_cast<const uint8_t*>(GetModuleHandleW(name));
      if (!image) continue;
      const auto* dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(image);
      if (dos->e_magic != IMAGE_DOS_SIGNATURE || dos->e_lfanew < 0 || dos->e_lfanew > 4096) continue;
      const auto* nt = reinterpret_cast<const IMAGE_NT_HEADERS64*>(image + dos->e_lfanew);
      if (nt->Signature != IMAGE_NT_SIGNATURE || nt->FileHeader.Machine != IMAGE_FILE_MACHINE_AMD64
          || nt->FileHeader.TimeDateStamp != 0x67410424 || nt->OptionalHeader.SizeOfImage != 0x9e000) continue;
      constexpr uint8_t jitter[] = {0x4c,0x8b,0xdc,0x48,0x81,0xec,0x88,0,0,0,0x48,0x8b,0x05,0xcf,0xd2,0x03,0,0x48,0x33,0xc4,0x48,0x89,0x04,0x24,0x8b,0x81,0xf4,0x09,0,0,0xff,0xc8};
      constexpr uint8_t shader[] = {0x48,0x89,0x5c,0x24,0x10,0x55,0x56,0x57,0x41,0x54,0x41,0x55,0x41,0x56,0x41,0x57,0x48,0x8d,0x6c,0x24,0xd9,0x48,0x81,0xec,0xd0,0,0,0};
      constexpr uint8_t draw[] = {0x48,0x89,0x5c,0x24,0x10,0x55,0x56,0x57,0x41,0x54,0x41,0x55,0x41,0x56,0x41,0x57,0x48,0x8d,0x6c,0x24,0xe1,0x48,0x81,0xec,0x90,0,0,0};
      if (std::memcmp(image + 0x51d40, jitter, sizeof(jitter))
          || std::memcmp(image + 0x52090, shader, sizeof(shader))
          || std::memcmp(image + 0x52f40, draw, sizeof(draw))) continue;
      MEMORY_BASIC_INFORMATION memory;
      if (!VirtualQuery(image + 0x9166c, &memory, sizeof(memory)) || memory.State != MEM_COMMIT
          || (memory.Protect & (PAGE_GUARD | PAGE_NOACCESS)) != 0
          || (memory.Protect & (PAGE_READWRITE | PAGE_EXECUTE_READWRITE)) == 0) continue;
      HMODULE pinned = nullptr;
      if (!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN,
                              reinterpret_cast<LPCWSTR>(image), &pinned)) continue;
      // Renderer singleton +0x288 owns its config at +0x940. The AA member is
      // +0xb4. Restore it before Present, where BlitzFX draws/saves its settings.
      runtime_aa = reinterpret_cast<int*>(const_cast<uint8_t*>(image) + 0x9166c);
      break;
    }
  });
  return runtime_aa != nullptr;
}

// Scope the override to the render thread's world render. Vanilla (0) keeps
// the game's AA draw, camera/depth inputs and our existing reconstruction
// boundary. BlitzFX jitter mutation requires mode 1/2; its compute TAA uses 2.
// Never run a second temporal filter on the DLSS output or edit blitz.settings.
struct ScopedTemporalOwner {
  int* setting = nullptr;
  int saved = 0;
  explicit ScopedTemporalOwner(bool main_world) {
    if (!main_world || !temporal_enabled.load(std::memory_order_relaxed) || !runtime_aa
        || *runtime_aa < 0 || *runtime_aa > 2) return;
    setting = runtime_aa;
    saved = *setting;
    *setting = 0;
  }
  ~ScopedTemporalOwner() { if (setting) *setting = saved; }
  ScopedTemporalOwner(const ScopedTemporalOwner&) = delete;
  ScopedTemporalOwner& operator=(const ScopedTemporalOwner&) = delete;
};
}  // namespace witcher3classic::blitzfx
