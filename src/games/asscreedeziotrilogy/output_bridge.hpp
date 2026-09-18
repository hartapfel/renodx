/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <cstdint>
namespace ac2::output_bridge {
// Optional, read-only ABI for encoding auxiliary frame-generation color with
// the identical presentation shader/settings. No ownership crosses this API.
struct Parameters {
  uint32_t version = 1, size = sizeof(Parameters);
  float injection[28] = {};
};
using ReadParameters = bool(__cdecl*)(Parameters*);
static_assert(sizeof(Parameters) == 120);
}
