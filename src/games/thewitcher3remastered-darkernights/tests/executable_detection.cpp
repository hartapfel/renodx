/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#include <cassert>
#include <cstdio>
#include <fstream>
#include <iterator>
#include <limits>
#include "../night_lighting.hpp"

int main(int argc, char** argv) {
  if (argc != 2) return 1;
  std::ifstream stream(argv[1], std::ios::binary);
  assert(stream);
  const std::vector<unsigned char> file{std::istreambuf_iterator<char>(stream), {}};
  assert(file.size() >= sizeof(IMAGE_DOS_HEADER));
  const auto* dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(file.data());
  assert(dos->e_magic == IMAGE_DOS_SIGNATURE && dos->e_lfanew >= 0);
  assert(size_t(dos->e_lfanew) + sizeof(IMAGE_NT_HEADERS64) <= file.size());
  const auto* pe = reinterpret_cast<const IMAGE_NT_HEADERS64*>(file.data() + dos->e_lfanew);
  assert(pe->Signature == IMAGE_NT_SIGNATURE && pe->OptionalHeader.Magic == IMAGE_NT_OPTIONAL_HDR64_MAGIC);
  std::vector<unsigned char> image(pe->OptionalHeader.SizeOfImage + 0x20000);
  assert(pe->OptionalHeader.SizeOfHeaders <= file.size());
  std::memcpy(image.data(), file.data(), pe->OptionalHeader.SizeOfHeaders);
  const auto* sections = IMAGE_FIRST_SECTION(pe);
  assert(reinterpret_cast<const unsigned char*>(sections + pe->FileHeader.NumberOfSections) <= file.data() + file.size());
  for (unsigned i = 0; i < pe->FileHeader.NumberOfSections; ++i) {
    assert(uint64_t(sections[i].VirtualAddress) + sections[i].SizeOfRawData <= image.size());
    assert(uint64_t(sections[i].PointerToRawData) + sections[i].SizeOfRawData <= file.size());
    std::memcpy(image.data() + sections[i].VirtualAddress,
                file.data() + sections[i].PointerToRawData, sections[i].SizeOfRawData);
  }
  // Apply every PE relocation, as the Windows loader does. This also rebases
  // newly moved CVar descriptors without any knowledge of their addresses.
  const auto reloc = pe->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC];
  for (size_t offset = reloc.VirtualAddress; offset < uint64_t(reloc.VirtualAddress) + reloc.Size;) {
    const auto* block = reinterpret_cast<const IMAGE_BASE_RELOCATION*>(image.data() + offset);
    assert(block->SizeOfBlock >= sizeof(*block));
    const auto* entries = reinterpret_cast<const WORD*>(block + 1);
    for (unsigned i = 0; i < (block->SizeOfBlock - sizeof(*block)) / sizeof(WORD); ++i) {
      if ((entries[i] >> 12) != IMAGE_REL_BASED_DIR64) continue;
      uintptr_t pointer;
      const uint32_t address = block->VirtualAddress + (entries[i] & 0xfff);
      std::memcpy(&pointer, image.data() + address, sizeof(pointer));
      pointer += reinterpret_cast<uintptr_t>(image.data()) - pe->OptionalHeader.ImageBase;
      std::memcpy(image.data() + address, &pointer, sizeof(pointer));
    }
    offset += block->SizeOfBlock;
  }
  auto* header = reinterpret_cast<IMAGE_NT_HEADERS64*>(image.data() + dos->e_lfanew);
  unsigned cases = 0;
  assert(witcher::night::ValidateImage(image.data()));
  assert(witcher::night::fog_density_supported);
  assert(witcher::night::interior_fog::supported);
  const auto interior = witcher::night::interior_fog::addresses;
  const auto regional = witcher::night::normalization::addresses;
  const auto layout = *witcher::night::active_layout;
  for (unsigned address : {interior.world, interior.state, interior.blend, interior.profile,
                          interior.profile + 0x1a, interior.profile + 0x44, interior.profile + 0xaf,
                          interior.weight, interior.order, interior.order + 0x15, interior.order + 0xbe,
                          interior.layer, interior.layer + 0x4ec, interior.layer + 0x4f6,
                          interior.weather, interior.weather + 0xc, interior.weather + 0x24,
                          interior.state - 0x51}) {
    image[address] ^= 1;
    assert(witcher::night::ValidateImage(image.data()) && !witcher::night::interior_fog::supported);
    image[address] ^= 1;
    assert(witcher::night::ValidateImage(image.data()) && witcher::night::interior_fog::supported);
    ++cases;
  }
  assert(witcher::night::fog_distance_supported);
  for (unsigned offset : {0xd5au, 0xd6au, 0xd72u, 0xd8cu, 0xd95u}) {
    const unsigned address = witcher::night::active_layout->common + offset;
    image[address] ^= 1;
    assert(witcher::night::ValidateImage(image.data()) && !witcher::night::fog_distance_supported);
    image[address] ^= 1;
    assert(witcher::night::ValidateImage(image.data()) && witcher::night::fog_distance_supported);
    ++cases;
  }
  for (unsigned offset : {0xb4eu, 0xb5fu, 0xbe1u, 0xc1du}) {
    const unsigned address = witcher::night::active_layout->common + offset;
    image[address] ^= 1;
    assert(witcher::night::ValidateImage(image.data()) && !witcher::night::fog_density_supported);
    image[address] ^= 1;
    assert(witcher::night::ValidateImage(image.data()) && witcher::night::fog_density_supported);
    ++cases;
  }
  assert(witcher::night::camera_supported && witcher::night::cutscene_supported && witcher::night::grading::supported);
  assert(witcher::night::normalization::supported);
  assert(witcher::night::normalization::weather_supported);
  for (unsigned address : {regional.selector, regional.world, regional.weather_pointer,
                          regional.weather_start, regional.weather_start + 0x97,
                          regional.weather_finish, regional.weather_progress, regional.weather_progress + 0x69,
                          regional.intern}) {
    image[address] ^= 1;
    assert(witcher::night::ValidateImage(image.data()) && witcher::night::normalization::supported
           && !witcher::night::normalization::weather_supported);
    image[address] ^= 1;
    ++cases;
  }
  assert(witcher::night::ValidateImage(image.data()) && witcher::night::normalization::weather_supported);
  assert(witcher::night::moon_supported);
  assert(witcher::night::sun_supported);
  assert(witcher::night::rain_supported);
  assert(witcher::night::water_sky_supported && witcher::night::build_sky_constants);
  const unsigned sky_builder = static_cast<unsigned>(reinterpret_cast<uintptr_t>(witcher::night::build_sky_constants)
                                                    - reinterpret_cast<uintptr_t>(image.data()));
  assert(reinterpret_cast<uintptr_t>(witcher::night::build_environment) == reinterpret_cast<uintptr_t>(image.data()) + layout.environment);
  assert(reinterpret_cast<uintptr_t>(witcher::night::build_direct_constants) == reinterpret_cast<uintptr_t>(image.data()) + layout.direct);
  assert(reinterpret_cast<uintptr_t>(witcher::night::build_common_constants) == reinterpret_cast<uintptr_t>(image.data()) + layout.common);
  assert(reinterpret_cast<uintptr_t>(witcher::night::build_global_constants) == reinterpret_cast<uintptr_t>(image.data()) + layout.global);
  assert(reinterpret_cast<uintptr_t>(witcher::night::build_camera_light) == reinterpret_cast<uintptr_t>(image.data()) + layout.camera);
  assert(reinterpret_cast<uintptr_t>(witcher::night::grading::set_pixel_constants) == reinterpret_cast<uintptr_t>(image.data()) + layout.pixel_constants);
  assert(witcher::night::sky_impact.value == reinterpret_cast<float*>(image.data() + layout.sky_impact));
  assert(witcher::night::grading::caller_rva_offset == layout.grade_caller_offset);
  assert(witcher::night::direct_constants_offset == layout.direct_buffer_offset);
  for (const auto& [slot, caller] : witcher::night::grading::grade_uploads) {
    float value[] = {0.8f, 1.2f, 1.1f, 1.5f};
    assert(witcher::night::grading::AdjustConstants(slot, value, int64_t(caller) + layout.grade_caller_offset, 1.f, 0.f, 0.f));
    if (layout.grade_caller_offset != 0) {
      assert(!witcher::night::grading::AdjustConstants(slot, value, caller, 1.f, 0.f, 0.f));
    }
    ++cases;
  }
  ++cases;
  const auto original_timestamp = header->FileHeader.TimeDateStamp;
  const auto original_size = header->OptionalHeader.SizeOfImage;
  for (DWORD timestamp : {0ul, 1ul, 0xfffffffful}) {
    for (DWORD size : {original_size - 0x1000, original_size, original_size + 0x1000}) {
      header->FileHeader.TimeDateStamp = timestamp;
      header->OptionalHeader.SizeOfImage = size;
      assert(witcher::night::ValidateImage(image.data()));
      ++cases;
    }
  }
  header->FileHeader.TimeDateStamp = original_timestamp;
  header->OptionalHeader.SizeOfImage = layout.sky_impact + sizeof(float) - 1;
  assert(!witcher::night::ValidateImage(image.data()));
  ++cases;
  header->OptionalHeader.SizeOfImage = original_size;
  header->FileHeader.Machine = IMAGE_FILE_MACHINE_I386;
  assert(!witcher::night::ValidateImage(image.data()));
  ++cases;
  header->FileHeader.Machine = IMAGE_FILE_MACHINE_AMD64;
  header->OptionalHeader.Magic = IMAGE_NT_OPTIONAL_HDR32_MAGIC;
  assert(!witcher::night::ValidateImage(image.data()));
  ++cases;
  header->OptionalHeader.Magic = IMAGE_NT_OPTIONAL_HDR64_MAGIC;
  const auto optional_size = header->FileHeader.SizeOfOptionalHeader;
  header->FileHeader.SizeOfOptionalHeader = sizeof(IMAGE_OPTIONAL_HEADER64) - 1;
  assert(!witcher::night::ValidateImage(image.data()));
  ++cases;
  header->FileHeader.SizeOfOptionalHeader = optional_size;
  // Every required renderer signature must still reject a changed layout.
  for (unsigned offset : {layout.environment, layout.environment + 0xd8du, layout.direct, layout.direct + 0x1du,
                          layout.direct + 0x20u, layout.direct + 0x85u,
                          layout.common, layout.common + 0x990u, layout.common + 0xf9cu, layout.common + 0x115fu,
                          layout.common + 0x138eu, layout.common + 0x682u, layout.common + 0x696u, layout.common + 0x1ddeu,
                          layout.common + 0x1e92u, layout.common + 0x1e72u, layout.global, layout.global + 0x243u,
                          layout.global + 0x28eu, layout.global + 0x2f0u}) {
    image[offset] ^= 1;
    assert(!witcher::night::ValidateImage(image.data()));
    image[offset] ^= 1;
    ++cases;
  }
  // Region identification is optional: reject changed instructions without
  // disabling any previously supported lighting/exposure control.
  for (unsigned offset : {regional.manager, regional.area, regional.converter, regional.game_load + 3, regional.converter + 0x1b4}) {
    image[offset] ^= 1;
    assert(witcher::night::ValidateImage(image.data()) && !witcher::night::normalization::supported);
    image[offset] ^= 1;
    ++cases;
  }
  // Invalid CVar pointers, name and value must not pass validation.
  for (unsigned offset : {layout.sky_impact - 0x20u, layout.sky_impact - 0x10u}) {
    uintptr_t pointer;
    std::memcpy(&pointer, image.data() + offset, sizeof(pointer));
    const uintptr_t invalid = 0;
    std::memcpy(image.data() + offset, &invalid, sizeof(invalid));
    assert(!witcher::night::ValidateImage(image.data()));
    std::memcpy(image.data() + offset, &pointer, sizeof(pointer));
    ++cases;
  }
  char* name;
  std::memcpy(&name, image.data() + layout.sky_impact - 0x20u, sizeof(name));
  name[0] ^= 1;
  assert(!witcher::night::ValidateImage(image.data()));
  name[0] ^= 1;
  ++cases;
  float value;
  std::memcpy(&value, image.data() + layout.sky_impact, sizeof(value));
  const float invalid_value = std::numeric_limits<float>::quiet_NaN();
  std::memcpy(image.data() + layout.sky_impact, &invalid_value, sizeof(invalid_value));
  assert(!witcher::night::ValidateImage(image.data()));
  std::memcpy(image.data() + layout.sky_impact, &value, sizeof(value));
  ++cases;
  // Optional camera/grading differences leave core lighting available.
  for (unsigned offset : {layout.environment + 0xd0fu, layout.environment + 0xd19u, sky_builder,
                          sky_builder + 0x46u, sky_builder + 0x2eau, sky_builder + 0x2f2u,
                          sky_builder + 0x3d6u, sky_builder + 0x3deu, sky_builder + 0x40eu, sky_builder + 0x439u}) {
    image[offset] ^= 1;
    assert(witcher::night::ValidateImage(image.data()) && !witcher::night::water_sky_supported
           && !witcher::night::build_sky_constants);
    image[offset] ^= 1;
    ++cases;
  }
  for (unsigned offset : {layout.global + 0x235u, layout.global + 0x304u}) {
    image[offset] ^= 1;
    assert(witcher::night::ValidateImage(image.data()) && !witcher::night::rain_supported);
    image[offset] ^= 1;
    ++cases;
  }
  image[layout.camera] ^= 1;
  assert(witcher::night::ValidateImage(image.data()) && !witcher::night::camera_supported);
  image[layout.camera] ^= 1;
  ++cases;
  for (unsigned offset : {layout.direct + 0x1c68u, layout.direct + 0x1d64u}) {
    for (unsigned byte : {0u, 1u}) {
      image[offset + byte] ^= 1;
      assert(witcher::night::ValidateImage(image.data()) && !witcher::night::camera_supported);
      image[offset + byte] ^= 1;
      ++cases;
    }
  }
  for (unsigned offset : {layout.direct + 0x1beeu, layout.direct + 0x1aacu, layout.direct + 0x1c04u}) {
    image[offset] ^= 1;
    assert(witcher::night::ValidateImage(image.data())
        && witcher::night::camera_supported && !witcher::night::cutscene_supported);
    image[offset] ^= 1;
    ++cases;
  }
  for (unsigned offset : {layout.common + 0x979u, layout.common + 0x4d5u}) {
    image[offset] ^= 1;
    assert(witcher::night::ValidateImage(image.data()) && !witcher::night::moon_supported);
    image[offset] ^= 1;
    ++cases;
  }
  for (unsigned offset : {layout.common + 0x1725u, layout.common + 0x1746u,
                          layout.common + 0x17a8u, layout.common + 0x4d5u}) {
    image[offset] ^= 1;
    assert(witcher::night::ValidateImage(image.data()) && !witcher::night::sun_supported);
    image[offset] ^= 1;
    ++cases;
  }
  image[layout.pixel_constants] ^= 1;
  assert(witcher::night::ValidateImage(image.data()) && !witcher::night::grading::supported);
  image[layout.pixel_constants] ^= 1;
  ++cases;
  for (const auto& [slot, caller] : witcher::night::grading::grade_uploads) {
    const uintptr_t upload = static_cast<uintptr_t>(int64_t(caller) + layout.grade_caller_offset);
    image[upload - 4] ^= 1;
    assert(witcher::night::ValidateImage(image.data()) && !witcher::night::grading::supported);
    image[upload - 4] ^= 1;
    ++cases;
  }
  assert(witcher::night::ValidateImage(image.data()));
  if (witcher::night::exposure::supported) {
    std::vector<uintptr_t> exposure_stores{witcher::night::exposure::rate_caller - 0x22,
                                         witcher::night::exposure::rate_caller - 4};
    for (unsigned i = 0; i < 3; ++i) {
      const uintptr_t caller = witcher::night::exposure::resolved_limit_uploads[i];
      exposure_stores.push_back(caller - 4);
      exposure_stores.push_back(caller - (i == 0 ? 0x3b : i == 1 ? 0x38 : 0x3f));
    }
    for (auto address : exposure_stores) {
      image[address] ^= 1;
      assert(witcher::night::ValidateImage(image.data()) && !witcher::night::exposure::supported
             && witcher::night::grading::supported);
      image[address] ^= 1;
      ++cases;
    }
    assert(witcher::night::ValidateImage(image.data()) && witcher::night::exposure::supported);
    std::printf("Exposure upload validation passed: rates %llX, primary/transition metering and optional rejection guards.\n",
                static_cast<unsigned long long>(witcher::night::exposure::rate_caller));
  }
  // Simulate a link update moving each native builder, the grading uploads,
  // and the skylight descriptor independently. These copied bytes are never
  // executed. Only relative references used by validation need rebasing.
  auto* mapped_sections = IMAGE_FIRST_SECTION(header);
  const unsigned section_count = header->FileHeader.NumberOfSections;
  assert(reinterpret_cast<unsigned char*>(mapped_sections + section_count + 2)
         <= image.data() + header->OptionalHeader.SizeOfHeaders);
  const uint32_t relocated = original_size;
  mapped_sections[section_count] = {};
  mapped_sections[section_count].VirtualAddress = relocated;
  mapped_sections[section_count].Misc.VirtualSize = 0x10000;
  mapped_sections[section_count].Characteristics = IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_EXECUTE;
  mapped_sections[section_count + 1] = {};
  mapped_sections[section_count + 1].VirtualAddress = relocated + 0x10000;
  mapped_sections[section_count + 1].Misc.VirtualSize = 0x3000;
  mapped_sections[section_count + 1].Characteristics = IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_WRITE;
  header->FileHeader.NumberOfSections += 2;
  header->OptionalHeader.SizeOfImage = relocated + 0x13000;
  // A byte-for-byte code copy in writable data is not a hook candidate.
  std::memcpy(image.data() + relocated + 0x11000, image.data() + layout.environment, 0x1000);
  assert(witcher::night::ValidateImage(image.data()));
  ++cases;
  struct Move { uint32_t from, to, bytes; };
  const uint32_t grade_first = int64_t(witcher::night::grading::grade_uploads[0].second) + layout.grade_caller_offset;
  const Move moves[] = {
      {layout.environment, relocated, 0x1000},
      {layout.direct, relocated + 0x1000, 0x2000},
      {layout.common, relocated + 0x4000, 0x2000},
      {layout.global, relocated + 0x7000, 0x400},
      {layout.camera, relocated + 0x8000, 0x500},
      {grade_first - 0x40, relocated + 0x9000, 0x800},
  };
  for (const auto& move : moves) {
    std::memcpy(image.data() + move.to, image.data() + move.from, move.bytes);
  }
  assert(!witcher::night::ValidateImage(image.data())); // Duplicate candidates are ambiguous.
  ++cases;
  for (const auto& move : moves) std::memset(image.data() + move.from, 0, move.bytes);
  for (const auto& [instruction, target] : {
           std::pair{relocated + 0xd19, sky_builder},
           std::pair{relocated + 0x1000 + 0x1c68, relocated + 0x8000},
           std::pair{relocated + 0x1000 + 0x1d64, relocated + 0x8000}}) {
    const int32_t displacement = int64_t(target) - (int64_t(instruction) + 5);
    std::memcpy(image.data() + instruction + 1, &displacement, 4);
  }
  for (const auto& [slot, original_caller] : witcher::night::grading::grade_uploads) {
    const uint32_t caller = relocated + 0x9000 + (original_caller - witcher::night::grading::grade_uploads[0].second) + 0x40;
    const int32_t displacement = int64_t(layout.pixel_constants) - caller;
    std::memcpy(image.data() + caller - 4, &displacement, 4);
  }
  const uint32_t descriptor = relocated + 0x10000;
  std::memcpy(image.data() + descriptor, image.data() + layout.sky_impact - 32, 36);
  const uintptr_t relocated_value = reinterpret_cast<uintptr_t>(image.data() + descriptor + 32);
  std::memcpy(image.data() + descriptor + 16, &relocated_value, sizeof(relocated_value));
  std::memset(image.data() + layout.sky_impact - 32, 0, 36);
  assert(witcher::night::ValidateImage(image.data()));
  assert(witcher::night::active_layout->environment == relocated);
  assert(witcher::night::active_layout->direct == relocated + 0x1000);
  assert(witcher::night::active_layout->common == relocated + 0x4000);
  assert(witcher::night::active_layout->global == relocated + 0x7000);
  assert(witcher::night::sky_impact.value == reinterpret_cast<float*>(image.data() + descriptor + 32));
  assert(witcher::night::camera_supported && witcher::night::cutscene_supported && witcher::night::grading::supported);
  assert(witcher::night::exposure::supported && witcher::night::normalization::weather_supported);
  assert(witcher::night::interior_fog::supported && witcher::night::fog_density_supported && witcher::night::fog_distance_supported);
  assert(witcher::night::water_sky_supported && witcher::night::moon_supported && witcher::night::sun_supported && witcher::night::rain_supported);
  ++cases;
  // An independently registered CVar with the same name is ambiguous.
  std::memcpy(image.data() + descriptor + 0x80, image.data() + descriptor, 36);
  const uintptr_t duplicate_value = reinterpret_cast<uintptr_t>(image.data() + descriptor + 0xa0);
  std::memcpy(image.data() + descriptor + 0x90, &duplicate_value, sizeof(duplicate_value));
  assert(!witcher::night::ValidateImage(image.data()));
  ++cases;
  std::memset(image.data() + descriptor + 0x80, 0, 36);
  assert(witcher::night::ValidateImage(image.data()));
  ++cases;
  assert(!witcher::night::ValidateImage(nullptr));
  ++cases;
  std::printf("Passed %u executable detection cases (environment RVA %X): metadata flexibility, bounds, signatures, CVar and optional hooks.\n", cases, layout.environment);
}
