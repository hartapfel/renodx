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
  auto* image = static_cast<unsigned char*>(VirtualAlloc(nullptr, pe->OptionalHeader.SizeOfImage + 0x3000, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE));
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
  // Prove address-only updates are accepted without executing the relocated
  // fixture. Its flag builder, game pointer and CVar descriptor move separately.
  auto* mapped_header = reinterpret_cast<IMAGE_NT_HEADERS64*>(image + dos->e_lfanew);
  auto* mapped_sections = IMAGE_FIRST_SECTION(mapped_header);
  const unsigned old_count = mapped_header->FileHeader.NumberOfSections;
  const uint32_t old_size = mapped_header->OptionalHeader.SizeOfImage;
  Require(reinterpret_cast<unsigned char*>(mapped_sections + old_count + 2)
              <= image + mapped_header->OptionalHeader.SizeOfHeaders, "No spare test section headers");
  mapped_sections[old_count] = {};
  mapped_sections[old_count].VirtualAddress = old_size;
  mapped_sections[old_count].Misc.VirtualSize = 0x1000;
  mapped_sections[old_count].Characteristics = IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_EXECUTE;
  mapped_sections[old_count + 1] = {};
  mapped_sections[old_count + 1].VirtualAddress = old_size + 0x1000;
  mapped_sections[old_count + 1].Misc.VirtualSize = 0x1000;
  mapped_sections[old_count + 1].Characteristics = IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_WRITE;
  mapped_header->FileHeader.NumberOfSections += 2;
  mapped_header->OptionalHeader.SizeOfImage += 0x2000;
  const renodx::utils::pe::Image fixture(image);
  const uint32_t original = static_cast<uint32_t>(code - image);
  const uint32_t allow_rva = fixture.Relative(original + 0x146, 3, 7, IMAGE_SCN_MEM_WRITE);
  const uint32_t game_rva = fixture.Relative(original + 0xa, 3, 7, IMAGE_SCN_MEM_WRITE);
  std::array<unsigned char, 0x1bb> saved_code;
  std::array<unsigned char, 36> saved_cvar;
  std::memcpy(saved_code.data(), code, saved_code.size());
  std::memcpy(saved_cvar.data(), image + allow_rva - 32, saved_cvar.size());
  std::memcpy(image + old_size, code, saved_code.size());
  Require(!ValidateImage(image), "Ambiguous flag builder was accepted");
  std::memset(code, 0, saved_code.size());
  const uint32_t new_cvar = old_size + 0x1000;
  const uintptr_t new_value = reinterpret_cast<uintptr_t>(image + new_cvar + 32);
  std::memcpy(image + new_cvar, saved_cvar.data(), saved_cvar.size());
  std::memcpy(image + new_cvar + 16, &new_value, sizeof(new_value));
  std::memset(image + allow_rva - 32, 0, saved_cvar.size());
  std::memcpy(image + new_cvar + 0x80, image + game_rva, sizeof(void*));
  const int32_t new_allow = int64_t(new_cvar + 32) - (int64_t(old_size) + 0x14d);
  const int32_t new_game = int64_t(new_cvar + 0x80) - (int64_t(old_size) + 0x11);
  std::memcpy(image + old_size + 0x149, &new_allow, 4);
  std::memcpy(image + old_size + 0xd, &new_game, 4);
  Require(ValidateImage(image) && reinterpret_cast<unsigned char*>(build_flags) == image + old_size
              && reinterpret_cast<unsigned char*>(world_slot) == image + new_cvar + 0x80,
          "Relocated builder/globals/CVar did not validate");
  std::memcpy(code, saved_code.data(), saved_code.size());
  std::memcpy(image + allow_rva - 32, saved_cvar.data(), saved_cvar.size());
  mapped_header->FileHeader.NumberOfSections = old_count;
  mapped_header->OptionalHeader.SizeOfImage = old_size;
  Require(ValidateImage(image), "Original builder not restored after fixture");
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
