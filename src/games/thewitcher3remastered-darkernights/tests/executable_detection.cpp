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
  std::vector<unsigned char> image(pe->OptionalHeader.SizeOfImage + 0x1000);
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
  // Rebase CVar descriptor pointers for either audited image. An unrelated
  // value at the other profile's RVA must never be treated as a pointer.
  for (const auto& profile : witcher::night::native_layouts) {
    if (profile.sky_impact + sizeof(float) > pe->OptionalHeader.SizeOfImage) continue;
    std::vector<unsigned> cvars{profile.sky_impact};
    if (image[profile.environment + 0xd19] == 0xe8) {
      int32_t displacement;
      std::memcpy(&displacement, image.data() + profile.environment + 0xd1a, sizeof(displacement));
      const int64_t target = int64_t(profile.environment) + 0xd1e + displacement;
      if (target >= 0 && uint64_t(target) + 0x443 <= image.size()) {
        for (unsigned load : {0x2eau, 0x3d6u}) {
          std::memcpy(&displacement, image.data() + target + load + 4, sizeof(displacement));
          const int64_t value = target + load + 8 + displacement;
          if (value >= 32 && uint64_t(value) + 4 <= image.size()) cvars.push_back(static_cast<unsigned>(value));
        }
      }
    }
    for (unsigned rva : cvars) for (unsigned offset : {rva - 32u, rva - 16u}) {
      uintptr_t pointer;
      std::memcpy(&pointer, image.data() + offset, sizeof(pointer));
      if (pointer < pe->OptionalHeader.ImageBase
          || pointer - pe->OptionalHeader.ImageBase >= pe->OptionalHeader.SizeOfImage) continue;
      pointer = reinterpret_cast<uintptr_t>(image.data()) + pointer - pe->OptionalHeader.ImageBase;
      std::memcpy(image.data() + offset, &pointer, sizeof(pointer));
    }
  }
  auto* header = reinterpret_cast<IMAGE_NT_HEADERS64*>(image.data() + dos->e_lfanew);
  unsigned cases = 0;
  assert(witcher::night::ValidateImage(image.data()));
  assert(witcher::night::camera_supported && witcher::night::cutscene_supported && witcher::night::grading::supported);
  assert(witcher::night::moon_supported);
  assert(witcher::night::sun_supported);
  assert(witcher::night::rain_supported);
  assert(witcher::night::water_sky_supported && witcher::night::build_sky_constants);
  const unsigned sky_builder = static_cast<unsigned>(reinterpret_cast<uintptr_t>(witcher::night::build_sky_constants)
                                                    - reinterpret_cast<uintptr_t>(image.data()));
  const auto layout = *witcher::night::active_layout;
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
  if (layout.grade_caller_offset == -0x1620) {
    assert(witcher::night::exposure::supported && witcher::night::exposure::rate_caller == 0x1c147a9);
    std::vector<uintptr_t> exposure_stores{witcher::night::exposure::rate_caller - 0x22,
                                         witcher::night::exposure::rate_caller - 4};
    for (unsigned i = 0; i < 3; ++i) {
      const uintptr_t caller = int64_t(witcher::night::exposure::limit_uploads[i].second) + layout.grade_caller_offset;
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
  assert(!witcher::night::ValidateImage(nullptr));
  ++cases;
  std::printf("Passed %u executable detection cases (environment RVA %X): metadata flexibility, bounds, signatures, CVar and optional hooks.\n", cases, layout.environment);
}
