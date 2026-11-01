/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once

#include <windows.h>

#include <algorithm>
#include <cstdint>
#include <cstring>
#include <initializer_list>
#include <span>
#include <string_view>

namespace renodx::utils::pe {

struct Anchor {
  uint32_t offset;
  std::span<const unsigned char> bytes;
};

// Read-only view of an already mapped PE64 image. Discovery is restricted to
// declared sections; all matches must be unique and all relative targets bounded.
class Image {
 public:
  const unsigned char* data = nullptr;
  uint32_t size = 0;
  const IMAGE_NT_HEADERS64* headers = nullptr;

  explicit Image(const unsigned char* image) {
    if (!image) return;
    const auto* dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(image);
    if (dos->e_magic != IMAGE_DOS_SIGNATURE || dos->e_lfanew < 0x40 || dos->e_lfanew > 0x1000) return;
    const auto* pe = reinterpret_cast<const IMAGE_NT_HEADERS64*>(image + dos->e_lfanew);
    if (pe->Signature != IMAGE_NT_SIGNATURE || pe->FileHeader.Machine != IMAGE_FILE_MACHINE_AMD64
        || pe->FileHeader.SizeOfOptionalHeader < sizeof(IMAGE_OPTIONAL_HEADER64)
        || pe->OptionalHeader.Magic != IMAGE_NT_OPTIONAL_HDR64_MAGIC
        || pe->FileHeader.NumberOfSections == 0 || pe->FileHeader.NumberOfSections > 96) return;
    const uint64_t section_end = uint64_t(dos->e_lfanew) + 24 + pe->FileHeader.SizeOfOptionalHeader
                                 + uint64_t(pe->FileHeader.NumberOfSections) * sizeof(IMAGE_SECTION_HEADER);
    if (pe->OptionalHeader.SizeOfImage < section_end) return;
    data = image;
    size = pe->OptionalHeader.SizeOfImage;
    headers = pe;
  }

  explicit operator bool() const { return data != nullptr; }

  bool Contains(uint64_t offset, uint64_t length) const {
    return data && offset <= size && length <= size - offset;
  }

  bool InSection(uint32_t offset, size_t length, uint32_t flags) const {
    if (!Contains(offset, length)) return false;
    const auto* sections = IMAGE_FIRST_SECTION(headers);
    for (unsigned i = 0; i < headers->FileHeader.NumberOfSections; ++i) {
      const auto& section = sections[i];
      if ((section.Characteristics & flags) != flags || offset < section.VirtualAddress) continue;
      const uint64_t end = uint64_t(section.VirtualAddress) + section.Misc.VirtualSize;
      if (end <= size && uint64_t(offset) + length <= end) return true;
    }
    return false;
  }

  template <typename T>
  bool Read(uint64_t offset, T* result) const {
    if (!Contains(offset, sizeof(T))) return false;
    std::memcpy(result, data + offset, sizeof(T));
    return true;
  }

  bool Match(uint64_t offset, std::span<const unsigned char> bytes) const {
    return Contains(offset, bytes.size()) && std::memcmp(data + offset, bytes.data(), bytes.size()) == 0;
  }

  uint32_t Relative(uint32_t instruction, uint32_t displacement_offset, uint32_t instruction_size,
                    uint32_t target_flags = IMAGE_SCN_MEM_EXECUTE) const {
    int32_t displacement;
    if (!Read(uint64_t(instruction) + displacement_offset, &displacement)) return 0;
    const int64_t target = int64_t(instruction) + instruction_size + displacement;
    if (target <= 0 || uint64_t(target) >= size
        || !InSection(static_cast<uint32_t>(target), 1, target_flags)) return 0;
    return static_cast<uint32_t>(target);
  }

  // Anchors describe instructions at relative offsets, allowing relocation
  // operands between them to change without weakening the semantic checks.
  uint32_t FindUnique(std::initializer_list<Anchor> anchors, uint32_t flags = IMAGE_SCN_MEM_EXECUTE) const {
    if (!data || anchors.size() == 0 || anchors.begin()->bytes.empty()) return 0;
    const auto& first = *anchors.begin();
    uint32_t result = 0;
    const auto* sections = IMAGE_FIRST_SECTION(headers);
    for (unsigned i = 0; i < headers->FileHeader.NumberOfSections; ++i) {
      const auto& section = sections[i];
      if ((section.Characteristics & flags) != flags
          || !Contains(section.VirtualAddress, section.Misc.VirtualSize)) continue;
      const auto* cursor = data + section.VirtualAddress;
      const auto* end = cursor + section.Misc.VirtualSize;
      while (cursor < end) {
        cursor = std::search(cursor, end, first.bytes.begin(), first.bytes.end());
        if (cursor == end) break;
        const uint64_t hit = cursor++ - data;
        if (hit < first.offset) continue;
        const uint32_t candidate = static_cast<uint32_t>(hit - first.offset);
        bool matched = true;
        for (const auto& anchor : anchors) {
          const uint64_t address = uint64_t(candidate) + anchor.offset;
          if (address > UINT32_MAX || !InSection(static_cast<uint32_t>(address), anchor.bytes.size(), flags)
              || !Match(address, anchor.bytes)) {
            matched = false;
            break;
          }
        }
        if (!matched) continue;
        if (result != 0) return 0;
        result = candidate;
      }
    }
    return result;
  }

  uint32_t FindCvar(std::string_view name) const {
    if (!data) return 0;
    uint32_t result = 0;
    const auto* sections = IMAGE_FIRST_SECTION(headers);
    for (unsigned i = 0; i < headers->FileHeader.NumberOfSections; ++i) {
      const auto& section = sections[i];
      if (!(section.Characteristics & IMAGE_SCN_MEM_WRITE)
          || !Contains(section.VirtualAddress, section.Misc.VirtualSize)) continue;
      const uint64_t end = uint64_t(section.VirtualAddress) + section.Misc.VirtualSize;
      for (uint64_t address = section.VirtualAddress; address + 36 <= end; address += sizeof(void*)) {
        uintptr_t key, value;
        Read(address, &key);
        if (key < reinterpret_cast<uintptr_t>(data)) continue;
        const uint64_t key_rva = key - reinterpret_cast<uintptr_t>(data);
        if (!Contains(key_rva, name.size() + 1) || data[key_rva + name.size()] != 0
            || std::memcmp(data + key_rva, name.data(), name.size()) != 0) continue;
        Read(address + 16, &value);
        if (value != reinterpret_cast<uintptr_t>(data) + address + 32) continue;
        if (result) return 0;
        result = static_cast<uint32_t>(address + 32);
      }
    }
    return result;
  }
};

}  // namespace renodx::utils::pe
