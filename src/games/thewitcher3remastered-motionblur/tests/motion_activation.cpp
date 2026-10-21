/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// Execute the actual native flag builder in a private mapped executable image.
// Only its two external game-service calls are stubbed; the CVar reads, scene
// guards, flag packing and Detours trampoline execute their original bytes.
#include <array>
#include <fstream>
#include <iostream>
#include <iterator>
#include <stdexcept>
#include "../motion_activation.hpp"

void Require(bool value, const char* message) { if (!value) throw std::runtime_error(message); }
int ServiceStub() { return 0; }

int main(int argc, char** argv) { try {
  using namespace witcher::motion::activation;
  Require(argc == 2, "Expected path to witcher3.exe");
  std::ifstream file(argv[1], std::ios::binary);
  std::vector<unsigned char> bytes{std::istreambuf_iterator<char>(file), {}};
  Require(bytes.size() > 4096, "Cannot read executable");
  const auto* dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(bytes.data());
  const auto* pe = reinterpret_cast<const IMAGE_NT_HEADERS64*>(bytes.data() + dos->e_lfanew);
  auto* image = static_cast<unsigned char*>(VirtualAlloc(nullptr, pe->OptionalHeader.SizeOfImage, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE));
  Require(image != nullptr, "Cannot map test image");
  std::memcpy(image, bytes.data(), pe->OptionalHeader.SizeOfHeaders);
  const auto* sections = IMAGE_FIRST_SECTION(pe);
  for (unsigned i = 0; i < pe->FileHeader.NumberOfSections; ++i)
    std::memcpy(image + sections[i].VirtualAddress, bytes.data() + sections[i].PointerToRawData, sections[i].SizeOfRawData);
  const auto reloc = pe->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC];
  for (size_t offset = reloc.VirtualAddress; offset < reloc.VirtualAddress + reloc.Size;) {
    const auto* block = reinterpret_cast<const IMAGE_BASE_RELOCATION*>(image + offset);
    Require(block->SizeOfBlock >= sizeof(*block), "Invalid relocation block");
    const auto* entries = reinterpret_cast<const WORD*>(block + 1);
    for (unsigned i = 0; i < (block->SizeOfBlock - sizeof(*block)) / sizeof(WORD); ++i) {
      if ((entries[i] >> 12) != IMAGE_REL_BASED_DIR64) continue;
      auto* pointer = reinterpret_cast<uintptr_t*>(image + block->VirtualAddress + (entries[i] & 0xfff));
      *pointer += reinterpret_cast<uintptr_t>(image) - pe->OptionalHeader.ImageBase;
    }
    offset += block->SizeOfBlock;
  }
  Require(ValidateImage(image), "Real executable signature/CVar validation failed");
  auto native = build_flags;
  auto* code = reinterpret_cast<unsigned char*>(native);
  // Altered mask/store/scene semantics must reject the override, not guess.
  for (unsigned offset : {0x11u, 0x15du, 0x1afu}) {
    code[offset] ^= 1;
    Require(!ValidateImage(image), "Altered native builder was accepted");
    code[offset] ^= 1;
  }
  Require(ValidateImage(image), "Original signature no longer validates");
  std::array<unsigned char, 0xfe00> world{}, view{};
  std::array<uintptr_t, 2> scene{0, 1};
  std::array<void*, 21> vtable{};
  vtable[20] = reinterpret_cast<void*>(&ServiceStub);
  void** renderer = vtable.data();
  int32_t displacement;
  std::memcpy(&displacement, code + 0x48, sizeof(displacement));
  *reinterpret_cast<void**>(code + 0x4c + displacement) = &renderer;
  std::memcpy(&displacement, code + 0xfd, sizeof(displacement));
  // The direct service query returns a feature flag, unrelated to motion blur.
  std::memcpy(code + 0x101 + displacement, "\x31\xc0\xc3", 3);
  std::memcpy(&displacement, code + 0x149, sizeof(displacement));
  auto* allow_motion_blur = code + 0x14d + displacement;
  Require(Install(image), "Native activation hook installation failed");
  unsigned cases = 0;
  for (unsigned guard = 0; guard < 5; ++guard) {
    *world_slot = guard == 1 ? nullptr : world.data();
    const auto* scene_pointer = guard == 2 ? nullptr : scene.data();
    std::memcpy(world.data() + 0xf0, &scene_pointer, sizeof(scene_pointer));
    scene[1] = guard == 3 ? 0 : 1;
    for (bool game_on : {false, true}) for (bool custom : {false, true, false, true, false}) {
      view.fill(0x5a);
      view[0xf5e9] = guard == 4 ? 0 : 1;
      *allow_motion_blur = game_on;
      enhanced.store(false);
      build_flags(view.data());
      auto expected = view;
      if (custom && guard == 0) *reinterpret_cast<uint32_t*>(expected.data() + VIEW_FLAGS) |= MOTION_BLUR;
      enhanced.store(custom);
      native(view.data());
      Require(view == expected, "Enhanced/Native changed unrelated view bytes or ignored a guard");
      Require(*allow_motion_blur == game_on, "Game preference was overwritten");
      ++cases;
    }
  }
  enhanced.store(false);
  Require(DetourTransactionBegin() == NO_ERROR && DetourUpdateThread(GetCurrentThread()) == NO_ERROR
              && DetourDetach(reinterpret_cast<void**>(&build_flags), reinterpret_cast<void*>(&BuildFlagsHook)) == NO_ERROR
              && DetourTransactionCommit() == NO_ERROR, "Test hook cleanup failed");
  VirtualFree(image, 0, MEM_RELEASE);
  std::cout << "PASS " << cases << " native builder cases: Enhanced forces the motion bit; Native preserves On/Off; scene guards, config and all unrelated view bytes unchanged; altered signatures rejected\n";
} catch (const std::exception& e) { std::cerr << "FAIL: " << e.what() << '\n'; return 1; } }
