/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#include <bit>
#include <cstdio>
#include <span>
#include <vector>
#include <cstdlib>
#include "../../../utils/settings.hpp"
#include "../shared.h"

extern "C" __declspec(dllexport) const char* const NAME = "Witcher layout test";
#include "postprocess-layout.h"

int main() {
  using namespace reshade::api;
  const auto check = [](bool success) {
    if (!success) { std::puts("FAIL: post-process layout or packed setting"); std::exit(1); }
  };
  // Captured main post-process layout: ten root CBVs and thirteen tables.
  // ReShade exposes these as ranges with static sampler support, even when
  // there is no static sampler. The previous fixture missed the last DWORD.
  descriptor_range_with_static_samplers ranges[23]{};
  std::vector<pipeline_layout_param> params;
  for (unsigned i = 0; i < 23; ++i) {
    ranges[i].dx_register_index = i == 9 ? 12 : i;
    ranges[i].count = 1;
    ranges[i].visibility = shader_stage::pixel;
    ranges[i].type = i < 10 ? descriptor_type::constant_buffer : descriptor_type::texture_shader_resource_view;
    if (i < 10) params.emplace_back(ranges[i]);
    else params.emplace_back(1, &ranges[i]);
  }
  check(sizeof(ShaderInjectData) / sizeof(float) + 33 + 2 == 64);
  check(ShouldInjectPostProcessLayout(params));
  params.emplace_back(1, &ranges[22]);
  check(!ShouldInjectPostProcessLayout(params));
  params.pop_back();
  params.emplace_back(constant_range{.dx_register_index = 13, .dx_register_space = 50, .count = 29});
  descriptor_range uav{.dx_register_space = 50, .count = 1, .visibility = shader_stage::pixel, .type = descriptor_type::buffer_unordered_access_view};
  params.emplace_back(uav);
  check(ShouldInjectPostProcessLayout(params));
  params[23].push_constants.count = 30;
  check(!ShouldInjectPostProcessLayout(params));
  params[23].push_constants.count = 29;
  ranges[3].visibility = shader_stage::vertex;
  check(!ShouldInjectPostProcessLayout(params));
  ranges[3].visibility = shader_stage::pixel;
  ranges[9].dx_register_space = 1;
  check(!ShouldInjectPostProcessLayout(params));
  ranges[9].dx_register_space = 0;
  check(ShouldInjectPostProcessLayout(params));

  ShaderInjectData shader_injection{};
  // Use the production setting, preserving the INI/UI selector values 0/1.
  renodx::utils::settings::Setting tone_map{
#include "tone-map-setting.h"
  };
  for (unsigned flags = 0; flags < 128; ++flags) {
    for (unsigned highlight : {0u, 50u, 100u}) {
      for (unsigned shadow : {0u, 50u, 100u}) {
        uint32_t original = flags | (highlight << WITCHER_CONTRAST_HIGHLIGHTS_SHIFT)
                            | (shadow << WITCHER_CONTRAST_SHADOWS_SHIFT);
        shader_injection.mode_flags = std::bit_cast<float>(original);
        for (float mode : {0.f, 1.f, 0.f, 1.f}) {
          tone_map.Set(mode)->Write();
          check(tone_map.GetValue() == mode);
          check(std::bit_cast<uint32_t>(shader_injection.mode_flags)
                == ((original & ~WITCHER_FLAG_PSYCHOV) | (mode == 1.f ? WITCHER_FLAG_PSYCHOV : 0u)));
        }
      }
    }
  }
  std::puts("PASS: captured 33-DWORD layout, injection boundary, and 4608 packed selector writes");
}
