/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#define NOMINMAX
#include <cassert>
#include <cstdio>
#include <limits>
#include "../taa_camera.hpp"

int main() {
  using namespace acbrotherhood::taa;
  Matrix camera, world;
  DirectX::XMStoreFloat4x4(&camera, DirectX::XMMatrixTranspose(DirectX::XMMatrixMultiply(
      DirectX::XMMatrixLookAtLH(DirectX::XMVectorSet(800, 12, -600, 1), DirectX::XMVectorSet(801, 12, -599, 1),
                              DirectX::XMVectorSet(0, 1, 0, 0)),
      DirectX::XMMatrixPerspectiveFovLH(1.1f, 16.f / 9.f, .1f, 2000.f))));
  DirectX::XMStoreFloat4x4(&world, DirectX::XMMatrixTranspose(DirectX::XMMatrixMultiply(
      DirectX::XMMatrixScaling(-2.f, 3.f, .5f), DirectX::XMMatrixTranslation(810, 14, -598))));
  const Matrix clip = Multiply(camera, world);
  Matrix result;
  assert(RecoverSceneCamera(clip, world, &camera, &result) && SameCamera(result, camera));
  assert(RecoverSceneCamera(clip, world, nullptr, &result) && SameCamera(result, camera));
  // Packed rigid materials can carry unrelated c11 values. They do not change
  // affine position or the camera and must not contaminate reconstruction.
  world.m[3][0] = 700; world.m[3][1] = -21; world.m[3][2] = 3; world.m[3][3] = 0;
  assert(RecoverSceneCamera(clip, world, &camera, &result) && SameCamera(result, camera));
  assert(RecoverSceneCamera(clip, world, nullptr, &result) && SameCamera(result, camera));
  Matrix other = camera;
  other.m[0][3] += 20.f;
  assert(!RecoverSceneCamera(clip, world, &other, &result));
  other = clip; other.m[2][0] = std::numeric_limits<float>::quiet_NaN();
  assert(!RecoverSceneCamera(other, world, &camera, &result));
  assert(!RecoverSceneCamera(other, world, nullptr, &result));
  assert(!RecoverSceneCamera(Matrix{}, world, nullptr, &result));
  world.m[0][0] = world.m[0][1] = world.m[0][2] = 0;
  assert(!RecoverSceneCamera(clip, world, nullptr, &result));
  std::puts("PASS engine/GPU camera agreement, packed-material c11, fallback and invalid-camera rejection");
}
