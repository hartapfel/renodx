/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <array>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <vector>

#include "../darker_nights.hpp"

int main(int argc, char** argv) {
  using namespace witcher3classic::night;
  try {
    auto require = [](bool valid, const char* message) {
      if (!valid) throw std::runtime_error(message);
    };
    const uint64_t schedule = NightSchedule();
    require(schedule != 0, "Default night schedule invalid");
    for (unsigned minute = 0; minute < 1440; ++minute) {
      const float time = minute / 1440.f;
      const float factor = ClockMultiplier(time, schedule, .5f);
      require(factor >= .5f && factor <= 1.f, "Night fade overshoots");
      if (minute >= 360 && minute <= 1080) require(factor == 1.f, "Daytime directional light changed");
      if (minute < 210 || minute >= 1290) require(factor == .5f, "Night plateau incorrect");
      require(ClockMultiplier(time, schedule, 1.f) == 1.f, "100% is not neutral");
    }
    for (float hour : {19.75f, 4.75f}) {
      require(std::abs(ClockMultiplier(hour / 24.f, schedule, .5f) - .75f) < 1.e-6f, "Smooth fade midpoint incorrect");
    }
    const float nan = std::numeric_limits<float>::quiet_NaN();
    for (float time : {-1.f, 1.01f, nan, std::numeric_limits<float>::infinity()}) {
      require(ClockMultiplier(time, schedule, .5f) == 1.f, "Invalid clock darkens the scene");
    }
    require(ClockMultiplier(0.f, 0, 0.f) == 1.f, "Invalid schedule darkens the scene");
    full_darkness_start = 5.f;
    require(NightSchedule() == 0, "Out-of-order schedule accepted");
    full_darkness_start = 21.5f;
    for (float value : {-1.f, 25.f, nan}) {
      darkening_start = value;
      require(NightSchedule() == 0, "Invalid schedule hour accepted");
    }
    darkening_start = full_darkness_start = 18.f;
    fade_out_start = darkening_end = 6.f;
    require(ClockMultiplier(0.f, NightSchedule(), 0.f) == 0.f, "Instant fades fail at midnight");
    require(ClockMultiplier(12.f / 24.f, NightSchedule(), 0.f) == 1.f, "Instant fades alter noon");
    darkening_start = 18.f; full_darkness_start = 21.5f; fade_out_start = 3.5f; darkening_end = 6.f;

    std::array<float, 3323 * 4> original{}, output{};
    for (size_t i = 0; i < original.size(); ++i) original[i] = .125f * (1 + i % 127);
    original[4] = 1000.f; original[5] = -2.f; original[6] = nan;
    std::array<uint8_t, 256> renderer{};
    const void* source = original.data(); void* destination = output.data();
    std::memcpy(renderer.data() + 0xf0, &source, sizeof(source));
    std::memcpy(renderer.data() + 0xf8, &destination, sizeof(destination));
    std::array<uint8_t, 0x1100> environment{};
    build_direct_constants = [](void* renderer, const void*) {
      void* destination; const void* source;
      std::memcpy(&source, static_cast<uint8_t*>(renderer) + 0xf0, sizeof(source));
      std::memcpy(&destination, static_cast<uint8_t*>(renderer) + 0xf8, sizeof(destination));
      std::memcpy(destination, source, 53168);
    };
    state->controls = {.schedule = schedule, .intensity = .5f};
    for (float hour : {0.f, 4.75f, 12.f, 20.5f, 24.f}) {
      const float time = hour / 24.f;
      std::memcpy(environment.data() + 0x1070, &time, sizeof(time));
      for (unsigned repeat = 0; repeat < 3; ++repeat) {
        DirectConstantsHook(renderer.data(), environment.data());
        for (size_t i = 0; i < original.size(); ++i) {
          const bool rgb = (i >= 4 && i < 7) || (i >= 204 && i < 207) || (i >= 208 && i < 211);
          const float expected = (rgb && std::isfinite(original[i])
              ? original[i] * ClockMultiplier(time, schedule, .5f) : original[i]);
          require(std::memcmp(&output[i], &expected, sizeof(expected)) == 0,
                  "Night upload changed unrelated data, lost HDR, or compounded its multiplier");
        }
      }
    }
    state->controls = {};
    DirectConstantsHook(renderer.data(), environment.data());
    require(std::memcmp(output.data(), original.data(), sizeof(original)) == 0, "Disabled night lighting is not byte-identical");
    std::array<float, 269 * 4> common{}, adjusted{};
    for (size_t i = 0; i < common.size(); ++i) common[i] = float(1 + i % 127) * .25f;
    common[37 * 4 + 2] = common[37 * 4 + 3] = 0.f;
    common[39 * 4] = 1000.f; common[40 * 4] = -2.f;
    const Controls ambient{
        .schedule = schedule, .ambient_light = .25f, .ambient_shadow = .5f,
        .reflection_light = .75f, .reflection_shadow = 0.f, .fog = .1f, .haze = .2f, .sky = .3f, .sky_haze = .4f,
        .moon_brightness = .5f, .moon_size = 2.f};
    for (float hour : {0.f, 4.75f, 12.f, 20.5f, 24.f}) {
      adjusted = common;
      ApplyCommon(adjusted.data(), ambient, hour / 24.f);
      for (size_t i = 0; i < common.size(); ++i) {
        const size_t row = i / 4, channel = i % 4;
        if (row == 37 && channel >= 2) continue;
        float intensity = 1.f;
        if (i == 183 * 4) intensity = .25f;
        else if (i == 183 * 4 + 1) intensity = .5f;
        else if (i == 184 * 4) intensity = .75f;
        else if (i == 184 * 4 + 1) intensity = 0.f;
        else if (channel < 3) {
          if ((row >= 39 && row <= 41) || row == 188 || row == 190) intensity = .1f;
          else if (row >= 45 && row <= 47) intensity = .2f;
          else if (row == 194) intensity = .4f;
          else if (row >= 195 && row <= 201) intensity = .3f;
        }
        const float expected = common[i] * ClockMultiplier(hour / 24.f, schedule, intensity);
        require(std::abs(adjusted[i] - expected) < .0001f * std::max(1.f, std::abs(expected)),
                "Ambient upload changed alpha, density, direct enables or another channel");
      }
      uint32_t tag; std::memcpy(&tag, &adjusted[37 * 4 + 3], 4);
      uint32_t haze_tag; std::memcpy(&haze_tag, &adjusted[37 * 4 + 2], 4);
      if (hour == 12.f) require(haze_tag == 0, "Daytime writes a sky haze override");
      else {
        require((haze_tag & 0xff000000u) == 0xd8000000u, "Missing background sky haze tag");
        require(std::abs(float(haze_tag & 0xffffffu) / 1048575.f - ClockMultiplier(hour / 24.f, schedule, .4f)) < .000001f,
                "Background sky haze gain or transition failed");
      }
      if (hour == 12.f) require(tag == 0, "Daytime writes a moon override");
      else {
        require((tag & 0xff000000u) == 0xd5000000u, "Missing moon tag");
        require(std::abs(float(tag & 8191u) / 1024.f - ClockMultiplier(hour / 24.f, schedule, 2.f, 5.f)) < .0005f,
                "Moon size quantization or transition failed");
      }
    }
    adjusted = common;
    ApplyCommon(adjusted.data(), Controls{.schedule = schedule}, 0.f);
    require(std::memcmp(adjusted.data(), common.data(), sizeof(common)) == 0, "Neutral ambient settings change native bytes");
    for (float hour : {0.f, 4.75f, 12.f, 20.5f}) {
      for (const auto gains : {std::pair{0.f, 1.f}, std::pair{1.f, 0.f}, std::pair{2.f, .5f}}) {
        adjusted = common;
        ApplyCommon(adjusted.data(), Controls{.schedule=schedule,.clouds=gains.first,.stars=gains.second}, hour/24.f);
        uint32_t tag; std::memcpy(&tag,&adjusted[184*4+3],4);
        if (hour != 12.f) {
          require((tag & 0xff000000u)==0xd6000000u,"Missing cloud/star upload tag");
          require(std::abs(float((tag>>12)&4095u)/2047.f-ClockMultiplier(hour/24.f,schedule,gains.first))<.00025f,"Cloud gain/fade failed");
          require(std::abs(float(tag&4095u)/2047.f-ClockMultiplier(hour/24.f,schedule,gains.second))<.00025f,"Star gain/fade failed");
          adjusted[184*4+3]=common[184*4+3];
        }
        require(std::memcmp(adjusted.data(),common.data(),sizeof(common))==0,"Cloud/star gain changes unrelated constants");
      }
    }
    require(CommonUpload::active == nullptr, "Unexpected native upload scope");
    for (float hour : {0.f, 4.75f, 12.f, 20.5f}) for (float gain : {0.f, .5f, 1.f, 2.f}) {
      adjusted = common;
      ApplyCommon(adjusted.data(), Controls{.schedule=schedule,.water=gain}, hour/24.f);
      uint32_t tag; std::memcpy(&tag,&adjusted[38*4+3],4);
      if (hour != 12.f && gain != 1.f) {
        require((tag&0xff000000u)==0xd9000000u,"Missing water ambient upload tag");
        require(std::abs(float(tag&0xffffffu)/1048575.f-ClockMultiplier(hour/24.f,schedule,gain))<.000001f,"Water ambient fade failed");
      }
      adjusted[38*4+3]=common[38*4+3];
      require(std::memcmp(adjusted.data(),common.data(),sizeof(common))==0,"Water ambient changes another lighting channel");
    }
    {
      CommonUpload outer(ambient, 0.f);
      require(CommonUpload::active == &outer, "Common upload scope was not published");
      { CommonUpload inner(ambient, .5f); require(CommonUpload::active == &inner, "Nested native view lost its upload scope"); }
      require(CommonUpload::active == &outer, "Nested native view did not restore its parent scope");
      std::array<float, 269 * 4> mapped{};
      auto* shadow = outer.Redirect(mapped.data(), 123);
      require(uintptr_t(shadow) % 16 == 0, "Native SSE upload lost 16-byte alignment");
      std::memcpy(shadow, common.data(), sizeof(common));
      require(mapped[39 * 4] == 0.f, "Redirected native writes touched GPU-mapped memory");
      outer.Publish();
      adjusted = common;
      ApplyCommon(adjusted.data(), ambient, 0.f);
      require(std::memcmp(mapped.data(), adjusted.data(), sizeof(mapped)) == 0, "Cached native upload differs from adjusted native bytes");
      require(outer.mapped == nullptr && outer.resource == 0, "Common upload retained an unmapped pointer");
      outer.Publish();
      require(std::memcmp(mapped.data(), adjusted.data(), sizeof(mapped)) == 0, "Repeated Unmap compounded ambient gains");
    }
    require(CommonUpload::active == nullptr, "Native upload scope leaked across calls");
    {
      std::array<uint8_t, 0x128> renderer{};
      std::array<uint8_t, 0x1100> view{};
      std::array<float,269*4> result{};
      const void* source = common.data(); void* target = result.data();
      auto expected = common;
      ApplyCommon(expected.data(), ambient, 0.f);
      const void* wanted = expected.data();
      std::memcpy(renderer.data()+0x100,&target,8);
      std::memcpy(renderer.data()+0x108,&source,8);
      std::memcpy(renderer.data()+0x110,&wanted,8);
      map_buffer = [](const void* handle, uint32_t, uint32_t, uint32_t) -> void* {
        void* target;
        std::memcpy(&target,static_cast<const uint8_t*>(handle)-0x11c+0x100,8);
        return target;
      };
      unmap_buffer = [](const void* handle) {
        const auto* renderer = static_cast<const uint8_t*>(handle)-0x11c;
        void* target; const void* expected;
        std::memcpy(&target,renderer+0x100,8);std::memcpy(&expected,renderer+0x110,8);
        if(std::memcmp(target,expected,4304)!=0)throw std::runtime_error("Native Unmap saw incomplete or unadjusted common data");
      };
      build_common_constants = [](void* renderer,const void*,uint64_t width,uint64_t height,int index,uint32_t flags) {
        if(width!=320 ||height!=180 ||index!=7 ||flags!=123)throw std::runtime_error("Native common builder arguments changed");
        auto* handle = static_cast<uint8_t*>(renderer)+0x11c;
        const void* source;std::memcpy(&source,static_cast<uint8_t*>(renderer)+0x108,8);
        std::memcpy(MapBufferHook(handle,4,0,4304),source,4304);
        UnmapBufferHook(handle);
      };
      state->controls = ambient;
      CommonConstantsHook(renderer.data(),view.data(),320,180,7,123);
      require(std::memcmp(result.data(),expected.data(),4304)==0,"Native Map-return upload route corrupted camera/constants");
      for (float gain : {0.f, .5f, 1.f, 2.f}) {
        state->controls = Controls{.schedule=schedule,.sky_haze=gain};
        expected=common;ApplyCommon(expected.data(),state->controls,0.f);
        CommonConstantsHook(renderer.data(),view.data(),320,180,7,123);
        require(std::memcmp(result.data(),expected.data(),4304)==0,"Sky haze alone fails native common upload routing");
      }
      state->controls = Controls{.schedule=schedule};
      expected=common;
      CommonConstantsHook(renderer.data(),view.data(),320,180,7,123);
      require(std::memcmp(result.data(),common.data(),4304)==0,"Neutral native Map-return route changes bytes");
      require(MapBufferHook(renderer.data()+0x11c,4,0,4304)==result.data(),"Unrelated native mapping was redirected");
      state->controls = {};
    }
    for (int n = 1; n < argc; ++n) {
      std::ifstream input(std::filesystem::path(argv[n]), std::ios::binary);
      require(bool(input), "Executable fixture missing");
      std::vector<uint8_t> file{std::istreambuf_iterator<char>(input), {}};
      const auto* dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(file.data());
      const auto* pe = reinterpret_cast<const IMAGE_NT_HEADERS64*>(file.data() + dos->e_lfanew);
      std::vector<uint8_t> image(pe->OptionalHeader.SizeOfImage);
      std::memcpy(image.data(), file.data(), pe->OptionalHeader.SizeOfHeaders);
      const auto* section = IMAGE_FIRST_SECTION(pe);
      for (unsigned i = 0; i < pe->FileHeader.NumberOfSections; ++i) {
        std::memcpy(image.data() + section[i].VirtualAddress, file.data() + section[i].PointerToRawData, section[i].SizeOfRawData);
      }
      require(ValidateImage(image.data()), "Native moonlight/clock ABI validation failed");
      require(ValidateCommonImage(image.data()), "Native common ambient/moon ABI validation failed");
      require(exposure::Validate(image.data(), uint32_t(image.size())), "Native exposure ABI validation failed");
      require(normalization::Validate(image.data(), uint32_t(image.size())), "Native regional ABI validation failed");
      for (unsigned offset : {0x19f00u, 0xc5240du, 0xc52441u, 0xc56653u, 0xc56689u, 0xc56724u, 0xc5242au}) {
        image[offset] ^= 1;
        require(!exposure::Validate(image.data(), uint32_t(image.size())), "Changed exposure instructions accepted");
        image[offset] ^= 1;
      }
      for (unsigned offset : {0x5f0804u, 0x5f0847u, 0xd727e2u, 0xd72846u}) {
        image[offset] ^= 1;
        require(!normalization::Validate(image.data(), uint32_t(image.size())), "Changed regional instructions accepted");
        image[offset] ^= 1;
      }

      for (unsigned offset : {0xcda720u, 0xcdc9acu, 0xcdca0cu, 0xcdb800u, 0xcdc9f8u, 0xeb10u, 0xee40u}) {
        image[offset] ^= 1;
        require(!ValidateCommonImage(image.data()), "Changed common buffer instructions accepted");
        require(ValidateImage(image.data()), "Optional ambient failure disables core moonlight support");
        image[offset] ^= 1;
      }
      for (unsigned offset : {0xc379a0u, 0xc379afu, 0xc379feu, 0xc37a2eu, 0x2d61ebu, 0x2d6207u}) {
        image[offset] ^= 1;
        require(!ValidateImage(image.data()), "Changed native moonlight/clock instructions accepted");
        image[offset] ^= 1;
      }
      std::cout << "PASS executable moonlight/clock contracts and changed-code rejection: " << argv[n] << '\n';
    }
    std::cout << "PASS cyclic/instant/invalid schedules, native daytime, HDR RGB-only transport, unchanged alpha/local lights, repeated fresh uploads and Off\n";
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
