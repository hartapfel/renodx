/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <fstream>
#include <string>
#include <string_view>
// Compile the same CPU fixture against the previous six cloud kernels. This
// checks the neutral settings against shipped GPU behavior, not copied math.
#ifdef CLASSIC_CLOUD_BASELINE
#include <embed/0xF3C60001.h>
#include <embed/0xF3C60002.h>
#include <embed/0xF3C60003.h>
#include <embed/0xF3C60004.h>
#include <embed/0xF3C60005.h>
#include <embed/0xF3C60006.h>
#include <cassert>
#include <vector>
namespace cloud_baseline {
inline std::vector<uint8_t> Read(unsigned index) {
#ifdef CLASSIC_CLOUD_MORPH_BASELINE
  std::ifstream stream("tmp/witcher3classic-investigation/cloud-morphology-20261101/before/0xF3C6000"+std::to_string(index)+".cso",std::ios::binary);
#else
  std::ifstream stream("tmp/witcher3classic-investigation/cloud-controls-20261031/baseline/0xF3C6000"+std::to_string(index)+".cso",std::ios::binary);
#endif
  assert(stream);return {std::istreambuf_iterator<char>(stream),{}};
}
inline auto noise=Read(1),trace=Read(2),resolve=Read(3),composite=Read(4),motion=Read(5),shadow=Read(6);
}
#define __0xF3C60001 cloud_baseline::noise
#define __0xF3C60002 cloud_baseline::trace
#define __0xF3C60003 cloud_baseline::resolve
#define __0xF3C60004 cloud_baseline::composite
#define __0xF3C60005 cloud_baseline::motion
#define __0xF3C60006 cloud_baseline::shadow
#endif
