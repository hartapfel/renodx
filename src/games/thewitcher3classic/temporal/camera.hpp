/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <windows.h>
#include <array>
#include <cmath>
#include <cstdint>
#include <cstring>

namespace witcher3classic::temporal {
class Camera {
 public:
  // Read-only contract for the audited GOG Classic executable SHA-256
  // 5112253787FBD927ECB979207EFB91B99BCC9C7B041106B51285136BAB41E1F7.
  // FUN_140c48810 assembles 4 x 0x2d0 bytes here and uploads 0xb40 bytes
  // before binding b10. Live CPU/GPU comparison matched all 720 words.
  bool Initialize() {
    const auto* image = reinterpret_cast<const uint8_t*>(GetModuleHandleW(nullptr));
    const auto* dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(image);
    if (!image || dos->e_magic != IMAGE_DOS_SIGNATURE || dos->e_lfanew < 0 || dos->e_lfanew > 4096) return false;
    const auto* nt = reinterpret_cast<const IMAGE_NT_HEADERS64*>(image + dos->e_lfanew);
    if (nt->Signature != IMAGE_NT_SIGNATURE || nt->FileHeader.Machine != IMAGE_FILE_MACHINE_AMD64
        || nt->FileHeader.TimeDateStamp != 0x5bdf65b7 || nt->OptionalHeader.SizeOfImage != 0x3673000) return false;
    constexpr std::array<uint8_t, 24> render = {76,137,76,36,32,76,137,68,36,24,72,137,84,36,16,72,137,76,36,8,85,83,86,65};
    constexpr std::array<uint8_t, 24> copy = {139,2,137,1,139,66,4,137,65,4,139,66,8,137,65,8,139,66,12,137,65,12,139,66};
    if (std::memcmp(image + 0xc48810, render.data(), render.size()) != 0
        || std::memcmp(image + 0xc51af0, copy.data(), copy.size()) != 0) return false;
    MEMORY_BASIC_INFORMATION memory;
    if (!VirtualQuery(image + 0x2ccb750, &memory, sizeof(memory)) || memory.State != MEM_COMMIT
        || (memory.Protect & (PAGE_GUARD | PAGE_NOACCESS)) != 0
        || static_cast<const uint8_t*>(memory.BaseAddress) + memory.RegionSize < image + 0x2ccb750 + 2880) return false;
    constants_ = reinterpret_cast<const float*>(image + 0x2ccb750);
    return true;
  }

  bool Jitter(std::array<float, 2>* pixels) const {
    if (!constants_) return false;
    // Native camera[0] has opposite sign to raster displacement. NGX wants
    // the actual pixel displacement, matching Ezio's right/down convention.
    (*pixels)[0] = -constants_[0];
    (*pixels)[1] = -constants_[1];
    return std::isfinite((*pixels)[0]) && std::isfinite((*pixels)[1])
           && std::abs((*pixels)[0]) <= 0.5f && std::abs((*pixels)[1]) <= 0.5f;
  }

 private:
  const float* constants_ = nullptr;
};
}  // namespace witcher3classic::temporal
