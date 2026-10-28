/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <array>
#include <cmath>
#include <cstring>
#include <span>
#include "./streamline.hpp"

namespace witcher3classic::frame_generation {
using Matrix = std::array<std::array<double, 4>, 4>;
// Partial pivoting avoids unstable inversions of the perspective depth rows.
inline bool Invert(const Matrix& matrix, Matrix* result) {
  double rows[4][8] = {};
  for (size_t r = 0; r < 4; ++r)
    for (size_t c = 0; c < 4; ++c) {
      rows[r][c] = matrix[r][c];
      rows[r][c + 4] = r == c;
    }
  for (size_t c = 0; c < 4; ++c) {
    size_t pivot = c;
    for (size_t r = c + 1; r < 4; ++r)
      if (std::abs(rows[r][c]) > std::abs(rows[pivot][c])) pivot = r;
    if (!std::isfinite(rows[pivot][c]) || std::abs(rows[pivot][c]) < 1e-10) return false;
    for (size_t i = 0; i < 8; ++i) std::swap(rows[c][i], rows[pivot][i]);
    const double divisor = rows[c][c];
    for (double& v : rows[c]) v /= divisor;
    for (size_t r = 0; r < 4; ++r)
      if (r != c) {
        const double factor = rows[r][c];
        for (size_t i = 0; i < 8; ++i) rows[r][i] -= factor * rows[c][i];
      }
  }
  for (size_t r = 0; r < 4; ++r)
    for (size_t c = 0; c < 4; ++c) {
      (*result)[r][c] = rows[r][c + 4];
      if (!std::isfinite((*result)[r][c])) return false;
    }
  return true;
}

// Captured native b10 contract (Classic 1.32): unjittered VP rows 5..8,
// inverse VP 13..16, unjittered projection 21..24, reprojection 78..81.
// Storage is the row-vector convention expected by SL. Native TAA uses
// z_game=1-z_hardware (b12[22].xy); FG receives raw reversed hardware depth.
// Therefore Praw=Pgame*Zflip, reprojectionRaw=Zflip*Rgame*Zflip. Never transpose
// just one matrix or send the standard-Z projection alongside reversed depth.
inline bool BuildCamera(std::span<const float, 720> native, UINT width, UINT height, bool reset, sl::Constants* output) {
  if (!output || !width || !height || !std::isfinite(native[0]) || !std::isfinite(native[1])
      || std::abs(native[0]) > .5f || std::abs(native[1]) > .5f) return false;
  Matrix projection{}, reprojection{}, inverse_projection{}, inverse_reprojection{};
  double axes[3][3] = {};
  for (size_t r = 0; r < 4; ++r)
    for (size_t c = 0; c < 4; ++c) {
      projection[r][c] = native[84 + r * 4 + c];
      reprojection[r][c] = native[312 + r * 4 + c];
      if (!std::isfinite(projection[r][c]) || !std::isfinite(reprojection[r][c]) || !std::isfinite(native[20 + r * 4 + c])) return false;
    }
  // Centered LH perspective only. Unknown orthographic/off-axis cameras suspend
  // FG instead of being approximated as a plausible gameplay projection.
  for (size_t r = 0; r < 4; ++r)
    for (size_t c = 0; c < 4; ++c)
      if (!((r == c && r < 3) || (r == 2 && c == 3) || (r == 3 && c == 2)) && std::abs(projection[r][c]) > 1e-5) return false;
  const double sx = projection[0][0], sy = projection[1][1], a = projection[2][2], b = projection[3][2];
  const double near_plane = -b / a, far_plane = -b / (a - 1), aspect = sy / sx;
  if (!(sx > 0 && sy > 0 && a > 1 && b < 0 && near_plane > .001 && far_plane > near_plane && far_plane < 1e7)
      || std::abs(projection[2][3] - 1) > 1e-5 || std::abs(aspect - double(width) / height) > .02) return false;
  for (size_t i = 0; i < 3; ++i) {
    axes[0][i] = native[20 + i * 4] / sx;
    axes[1][i] = native[21 + i * 4] / sy;
    axes[2][i] = native[23 + i * 4];
  }
  for (size_t row = 0; row < 3; ++row)
    for (size_t col = 0; col < 3; ++col) {
      double dot = 0;
      for (size_t i = 0; i < 3; ++i) dot += axes[row][i] * axes[col][i];
      if (std::abs(dot - double(row == col)) > .001) return false;
    }
  if (!std::isfinite(native[63]) || std::abs(native[63]) < 1e-8) return false;
  double eye[3];
  for (size_t i = 0; i < 3; ++i) {
    eye[i] = double(native[60 + i]) / native[63];
    if (!std::isfinite(eye[i])) return false;
  }
  // Cross-check the independent inverse-VP origin against the VP translation.
  for (size_t c = 0; c < 3; ++c) {
    double residual = native[32 + (c == 2 ? 3 : c)];
    for (size_t i = 0; i < 3; ++i) residual += eye[i] * native[20 + i * 4 + (c == 2 ? 3 : c)];
    if (std::abs(residual) > .02) return false;
  }
  for (size_t r = 0; r < 4; ++r) projection[r][2] = projection[r][3] - projection[r][2];
  // Left multiply flips input z and contributes z-row to the homogeneous row.
  for (size_t c = 0; c < 4; ++c) {
    reprojection[3][c] += reprojection[2][c];
    reprojection[2][c] = -reprojection[2][c];
  }
  for (size_t r = 0; r < 4; ++r) reprojection[r][2] = reprojection[r][3] - reprojection[r][2];
  if (!Invert(projection, &inverse_projection) || !Invert(reprojection, &inverse_reprojection)) return false;
  *output = sl::Constants{};
  for (size_t r = 0; r < 4; ++r) {
    output->cameraViewToClip[UINT(r)] = {float(projection[r][0]), float(projection[r][1]), float(projection[r][2]), float(projection[r][3])};
    output->clipToCameraView[UINT(r)] = {float(inverse_projection[r][0]), float(inverse_projection[r][1]), float(inverse_projection[r][2]), float(inverse_projection[r][3])};
    output->clipToPrevClip[UINT(r)] = {float(reprojection[r][0]), float(reprojection[r][1]), float(reprojection[r][2]), float(reprojection[r][3])};
    output->prevClipToClip[UINT(r)] = {float(inverse_reprojection[r][0]), float(inverse_reprojection[r][1]), float(inverse_reprojection[r][2]), float(inverse_reprojection[r][3])};
    output->clipToLensClip[UINT(r)] = {float(r == 0), float(r == 1), float(r == 2), float(r == 3)};
  }
  output->cameraPos = {float(eye[0]), float(eye[1]), float(eye[2])};
  output->cameraRight = {float(axes[0][0]), float(axes[0][1]), float(axes[0][2])};
  output->cameraUp = {float(axes[1][0]), float(axes[1][1]), float(axes[1][2])};
  output->cameraFwd = {float(axes[2][0]), float(axes[2][1]), float(axes[2][2])};
  output->cameraNear = float(near_plane);
  output->cameraFar = float(far_plane);
  output->cameraFOV = float(2 * std::atan(1 / sy));
  output->cameraAspectRatio = float(aspect);
  output->jitterOffset = {-native[0], -native[1]};
  output->mvecScale = {1, 1};
  output->cameraPinholeOffset = {0, 0};
  output->depthInverted = sl::Boolean::eTrue;
  output->cameraMotionIncluded = sl::Boolean::eTrue;
  output->motionVectors3D = sl::Boolean::eFalse;
  output->motionVectorsDilated = sl::Boolean::eFalse;
  output->motionVectorsJittered = sl::Boolean::eFalse;
  output->reset = reset ? sl::Boolean::eTrue : sl::Boolean::eFalse;
  return true;
}
}  // namespace witcher3classic::frame_generation
