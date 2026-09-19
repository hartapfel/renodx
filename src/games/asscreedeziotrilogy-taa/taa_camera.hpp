/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <DirectXMath.h>
#include <algorithm>
#include <cmath>
#include <array>

namespace acbrotherhood::taa {

using Matrix = DirectX::XMFLOAT4X4;

// Validate an affine c8-c10 world transform against the unjittered scene VP.
// Used before extending jitter to depth-disabled geometry, where depth state
// cannot distinguish the main camera from a screen-space or auxiliary draw.
inline bool MatchesCameraProjection(const Matrix& clip, const Matrix& world, const Matrix& camera) {
  for (unsigned row = 0; row < 4; ++row) {
    for (unsigned column = 0; column < 4; ++column) {
      double expected = column == 3 ? camera.m[row][3] : 0.;
      double magnitude = std::abs(expected);
      for (unsigned i = 0; i < 3; ++i) {
        const double term = double(camera.m[row][i]) * world.m[i][column];
        expected += term;
        magnitude += std::abs(term);
      }
      if (!std::isfinite(expected) || !std::isfinite(clip.m[row][column])
          || std::abs(expected - clip.m[row][column]) > 2.e-5 * std::max(1., magnitude)) return false;
    }
  }
  return true;
}

// SM3 dp4(position, cN) uses each constant register as a matrix row.
// Keep that convention on the CPU and upload rows unchanged to HLSL.
inline bool InvertDouble(const Matrix& matrix, std::array<double, 16>* inverse) {
  double augmented[4][8] = {};
  for (unsigned row = 0; row < 4; ++row) {
    for (unsigned column = 0; column < 4; ++column) {
      if (!std::isfinite(matrix.m[row][column])) return false;
      augmented[row][column] = matrix.m[row][column];
    }
    augmented[row][row + 4] = 1.;
  }
  for (unsigned column = 0; column < 4; ++column) {
    unsigned pivot = column;
    for (unsigned row = column + 1; row < 4; ++row) {
      if (std::abs(augmented[row][column]) > std::abs(augmented[pivot][column])) pivot = row;
    }
    if (std::abs(augmented[pivot][column]) < 1.e-12) return false;
    for (unsigned i = 0; i < 8; ++i) std::swap(augmented[column][i], augmented[pivot][i]);
    const double divisor = augmented[column][column];
    for (double& value : augmented[column]) value /= divisor;
    for (unsigned row = 0; row < 4; ++row) {
      if (row == column) continue;
      const double factor = augmented[row][column];
      for (unsigned i = 0; i < 8; ++i) augmented[row][i] -= factor * augmented[column][i];
    }
  }
  for (unsigned row = 0; row < 4; ++row) {
    for (unsigned column = 0; column < 4; ++column) {
      if (!std::isfinite(augmented[row][column + 4])) return false;
      (*inverse)[4 * row + column] = augmented[row][column + 4];
    }
  }
  return true;
}

inline bool Invert(const Matrix& matrix, Matrix* inverse) {
  std::array<double, 16> precise;
  if (!InvertDouble(matrix, &precise)) return false;
  for (unsigned row = 0; row < 4; ++row) {
    for (unsigned column = 0; column < 4; ++column) {
      inverse->m[row][column] = static_cast<float>(precise[4 * row + column]);
      if (!std::isfinite(inverse->m[row][column])) return false;
    }
  }
  return true;
}

// Do NOT round the inverse to float before multiplying. With camera world
// coordinates in the hundreds, float VP * inverse(VP) was off by nearly a
// pixel at 4K even for an unchanged camera. Upload only the final float result.
inline bool MultiplyByInverse(const Matrix& left, const Matrix& right, Matrix* result) {
  std::array<double, 16> inverse;
  if (!InvertDouble(right, &inverse)) return false;
  for (unsigned row = 0; row < 4; ++row) {
    for (unsigned column = 0; column < 4; ++column) {
      double value = 0.;
      for (unsigned i = 0; i < 4; ++i) value += double(left.m[row][i]) * inverse[4 * i + column];
      result->m[row][column] = static_cast<float>(value);
      if (!std::isfinite(result->m[row][column])) return false;
    }
  }
  return true;
}

inline Matrix Multiply(const Matrix& left, const Matrix& right) {
  Matrix result;
  DirectX::XMStoreFloat4x4(&result, DirectX::XMMatrixMultiply(
      DirectX::XMLoadFloat4x4(&left), DirectX::XMLoadFloat4x4(&right)));
  return result;
}

// The rigid material families use c8-c10 for affine world position; c11 can
// hold a normal/clip-plane row. Prefer the unjittered engine VP only when it
// reproduces the GPU WVP. Without engine hooks, recover VP from the same
// shader-authored matrix contract and require an invertible finite camera.
inline bool RecoverSceneCamera(const Matrix& clip, Matrix world, const Matrix* engine, Matrix* result) {
  world.m[3][0] = world.m[3][1] = world.m[3][2] = 0.f;
  world.m[3][3] = 1.f;
  Matrix camera, inverse;
  if (engine) {
    if (!MatchesCameraProjection(clip, world, *engine)) return false;
    camera = *engine;
  } else if (!MultiplyByInverse(clip, world, &camera)) return false;
  if (!Invert(camera, &inverse)) return false;
  *result = camera;
  return true;
}

// Perspective camera center maps to (0,0,z,0), so inverse(VP)'s third
// column gives its homogeneous world position. Subtract that center before
// projecting the ray into the previous camera: sky has rotation/FOV motion,
// but no translation parallax and no finite previous-frame surface depth.
inline bool SkyReprojection(const Matrix& previous, const Matrix& current, Matrix* result) {
  std::array<double, 16> inverse;
  if (!InvertDouble(current, &inverse) || std::abs(inverse[14]) < 1.e-12) return false;
  for (unsigned row = 0; row < 4; ++row) {
    for (unsigned column = 0; column < 4; ++column) {
      double value = 0.;
      for (unsigned i = 0; i < 3; ++i)
        value += double(previous.m[row][i]) * (inverse[4 * i + column] - inverse[4 * i + 2] / inverse[14] * inverse[12 + column]);
      result->m[row][column] = float(value);
      if (!std::isfinite(result->m[row][column])) return false;
    }
  }
  return true;
}

inline bool SameCamera(const Matrix& left, const Matrix& right) {
  for (unsigned row = 0; row < 4; ++row) {
    for (unsigned column = 0; column < 4; ++column) {
      if (!std::isfinite(left.m[row][column]) || !std::isfinite(right.m[row][column])
          || std::abs(left.m[row][column] - right.m[row][column])
                 > 0.002f * std::max(1.f, std::max(std::abs(left.m[row][column]), std::abs(right.m[row][column])))) return false;
    }
  }
  return true;
}

}  // namespace acbrotherhood::taa
