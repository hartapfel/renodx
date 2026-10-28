/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <cassert>
#include <cstdio>
#include <fstream>
#include <limits>
#include "../frame_generation/camera.hpp"
using namespace witcher3classic::frame_generation;
int main(int argc, char** argv) {
  if (argc != 2) return 2;
  std::array<float, 720> native{};
  std::ifstream input(argv[1], std::ios::binary);
  assert(input.read(reinterpret_cast<char*>(native.data()), sizeof(native)));
  sl::Constants camera{};
  assert(BuildCamera(native, 3840, 2160, false, &camera));
  assert(std::abs(camera.cameraNear - .2f) < 1e-4f && std::abs(camera.cameraFar - 5000.f) < 15.f);
  assert(std::abs(camera.cameraPos.x - 60.5813446f) < .001f);
  assert(std::abs(camera.cameraPos.y - .72613036f) < .001f);
  assert(std::abs(camera.cameraPos.z - 3.96662092f) < .001f);
  assert(std::abs(camera.cameraFOV - 1.04719755f) < 1e-5f);
  const auto* projection = reinterpret_cast<const float*>(&camera.cameraViewToClip);
  for (const float z : {camera.cameraNear, camera.cameraFar}) {
    const float depth = (z * projection[10] + projection[14]) / (z * projection[11] + projection[15]);
    assert(std::abs(depth - (z == camera.cameraNear ? 1.f : 0.f)) < 1e-6f);
  }
  for (const auto matrices : {std::pair{&camera.cameraViewToClip, &camera.clipToCameraView},
                              std::pair{&camera.clipToPrevClip, &camera.prevClipToClip}}) {
    const auto* a = reinterpret_cast<const float*>(matrices.first);
    const auto* b = reinterpret_cast<const float*>(matrices.second);
    for (size_t r = 0; r < 4; ++r)
      for (size_t c = 0; c < 4; ++c) {
        double v = 0;
        for (size_t k = 0; k < 4; ++k) v += double(a[r * 4 + k]) * b[k * 4 + c];
        assert(std::abs(v - double(r == c)) < 1e-5);
      }
  }
  // Independent direct native reprojection agrees with raw-depth SL matrices
  // at multiple clip positions, including near/far. Add a non-identity motion
  // so a transposition/omitted Z flip cannot hide behind stationary capture.
  native[324] = .125f;
  native[325] = -.25f;
  native[326] = .025f;
  assert(BuildCamera(native, 3840, 2160, false, &camera));
  const auto* converted = reinterpret_cast<const float*>(&camera.clipToPrevClip);
  for (double x : {-.9, .3})
    for (double y : {-.6, .8})
      for (double z : {0., .3, 1.}) {
        const double raw[] = {x, y, z, 1}, game[] = {x, y, 1 - z, 1};
        double expected[4] = {}, actual[4] = {};
        for (size_t c = 0; c < 4; ++c)
          for (size_t r = 0; r < 4; ++r) {
            expected[c] += game[r] * native[312 + r * 4 + c];
            actual[c] += raw[r] * converted[r * 4 + c];
          }
        expected[2] = expected[3] - expected[2];
        for (size_t c = 0; c < 4; ++c) assert(std::abs(expected[c] - actual[c]) < 1e-6);
      }
  auto invalid = native;
  invalid[0] = std::numeric_limits<float>::quiet_NaN();
  assert(!BuildCamera(invalid, 3840, 2160, false, &camera));
  invalid = native;
  invalid[84] = 0;
  assert(!BuildCamera(invalid, 3840, 2160, false, &camera));
  invalid = native;
  invalid[92] = .1f;
  assert(!BuildCamera(invalid, 3840, 2160, false, &camera));
  assert(!BuildCamera(native, 0, 2160, false, &camera));
  std::puts("PASS: live Classic camera origin/FOV, reversed depth, inverse matrices, non-identity reprojection and invalid-camera rejection.");
}
