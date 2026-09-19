/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#define NOMINMAX
#include <cassert>
#include <iostream>
#include <limits>
#include "../fg_camera.hpp"

int main() {
  using namespace acbrotherhood;
  frame_generation::Inputs inputs;
  inputs.width = 3840; inputs.height = 2160;
  // Actual unjittered rooftop camera from the verified native capture.
  const float camera[16] = {
      1.02070498f, -0.832525312f, 7.85e-8f, 197.968322f,
      0.300665348f, 0.368626356f, 2.29280853f, 104.013984f,
      0.618899524f, 0.758792281f, -0.203153684f, 285.512298f,
      0.618876636f, 0.758764266f, -0.203146174f, 285.601745f};
  std::copy(camera, camera + 16, inputs.current_camera);
  std::copy(camera, camera + 16, inputs.previous_camera);
  for (unsigned i = 0; i < 4; ++i) inputs.clip_to_previous[5 * i] = 1.f;
  inputs.jitter[0] = .25f; inputs.jitter[1] = -.375f;
  sl::Constants constants;
  assert(frame_generation::CameraConstants(inputs, &constants));
  assert(constants.cameraNear > .09f && constants.cameraNear < .11f);
  assert(constants.cameraFar > 2000.f && constants.cameraFar < 4000.f);
  assert(std::abs(constants.cameraAspectRatio - 16.f / 9.f) < .001f);
  assert(constants.jitterOffset.x == .25f && constants.jitterOffset.y == -.375f);
  const auto* position = &constants.cameraPos.x;
  for (unsigned row : {0u, 1u, 3u}) {
    double value = camera[4 * row + 3];
    for (unsigned col = 0; col < 3; ++col) value += double(camera[4 * row + col]) * position[col];
    assert(std::abs(value) < 0.0001);
  }
  for (unsigned row = 0; row < 4; ++row) for (unsigned col = 0; col < 4; ++col) {
    double value = 0.;
    for (unsigned i = 0; i < 4; ++i)
      value += double((&constants.cameraViewToClip[row].x)[i]) * (&constants.clipToCameraView[i].x)[col];
    assert(std::abs(value - double(row == col)) < 0.00001);
  }
  // Reprojection translation must transpose into the SDK row-vector matrix.
  inputs.clip_to_previous[3] = .25f;
  inputs.clip_to_previous[7] = -.1f;
  assert(frame_generation::CameraConstants(inputs, &constants));
  assert(constants.clipToPrevClip[3].x == .25f && constants.clipToPrevClip[3].y == -.1f);
  assert(constants.prevClipToClip[3].x == -.25f && constants.prevClipToClip[3].y == .1f);
  auto invalid = inputs;
  invalid.jitter[0] = std::numeric_limits<float>::quiet_NaN();
  assert(!frame_generation::CameraConstants(invalid, &constants));
  invalid = inputs;
  invalid.current_camera[0] = std::numeric_limits<float>::quiet_NaN();
  assert(!frame_generation::CameraConstants(invalid, &constants));
  invalid = inputs; invalid.current_camera[1] += .1f;
  assert(!frame_generation::CameraConstants(invalid, &constants));
  invalid = inputs; invalid.width = 2560;
  assert(!frame_generation::CameraConstants(invalid, &constants));
  invalid = inputs; std::fill(std::begin(invalid.clip_to_previous), std::end(invalid.clip_to_previous), 0.f);
  assert(!frame_generation::CameraConstants(invalid, &constants));
  invalid = inputs; invalid.current_camera[15] += 500.f;
  assert(!frame_generation::CameraConstants(invalid, &constants));
  std::cout << "PASS captured camera: perspective factorization, camera center, SDK transpose/inverse, invalid projection rejection\n";
}
