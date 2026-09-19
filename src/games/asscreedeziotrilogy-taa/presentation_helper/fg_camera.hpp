/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <cstring>
#include <sl_consts.h>
#include "../fg_protocol.hpp"
#include "../taa_camera.hpp"

namespace acbrotherhood::frame_generation {
// Factor the verified native, centered perspective VP. Reject unfamiliar
// projections instead of feeding plausible but incorrect camera data to FG.
inline bool CameraConstants(const Inputs& inputs, sl::Constants* result) {
  if (!std::isfinite(inputs.jitter[0]) || !std::isfinite(inputs.jitter[1])) return false;
  taa::Matrix vp, reprojection;
  std::memcpy(&vp, inputs.current_camera, sizeof(vp));
  std::memcpy(&reprojection, inputs.clip_to_previous, sizeof(reprojection));
  std::array<double, 16> inverse, reverse;
  if (!taa::InvertDouble(vp, &inverse) || !taa::InvertDouble(reprojection, &reverse)
      || std::abs(inverse[14]) < 1.e-9 || !inputs.width || !inputs.height) return false;
  double axes[3][3]{}, scales[3]{};
  for (unsigned axis = 0; axis < 3; ++axis) {
    const unsigned row = axis == 2 ? 3 : axis;
    for (unsigned i = 0; i < 3; ++i) scales[axis] += double(vp.m[row][i]) * vp.m[row][i];
    scales[axis] = std::sqrt(scales[axis]);
    if (scales[axis] < 1.e-4 || scales[axis] > 100.) return false;
    for (unsigned i = 0; i < 3; ++i) axes[axis][i] = vp.m[row][i] / scales[axis];
  }
  if (std::abs(scales[2] - 1.) > 0.002) return false;
  for (unsigned a = 0; a < 3; ++a) for (unsigned b = a + 1; b < 3; ++b) {
    double dot = 0.;
    for (unsigned i = 0; i < 3; ++i) dot += axes[a][i] * axes[b][i];
    if (std::abs(dot) > 0.0002) return false;
  }
  double depth_scale = 0.;
  for (unsigned i = 0; i < 3; ++i) depth_scale += double(vp.m[2][i]) * vp.m[3][i];
  depth_scale /= scales[2] * scales[2];
  for (unsigned i = 0; i < 3; ++i)
    if (std::abs(vp.m[2][i] - depth_scale * vp.m[3][i]) > 0.00001) return false;
  const double depth_offset = vp.m[2][3] - depth_scale * vp.m[3][3];
  const double near_plane = -depth_offset / depth_scale;
  const double far_plane = -depth_offset / (depth_scale - 1.);
  const double aspect = scales[1] / scales[0];
  if (!(depth_scale > 1. && near_plane > 0.001 && far_plane > near_plane && far_plane < 1.e7)
      || std::abs(aspect - double(inputs.width) / inputs.height) > 0.02) return false;
  *result = sl::Constants{};
  const double projection[4][4] = {{scales[0], 0, 0, 0}, {0, scales[1], 0, 0},
      {0, 0, depth_scale, depth_offset}, {0, 0, 1, 0}};
  const double inverse_projection[4][4] = {{1. / scales[0], 0, 0, 0}, {0, 1. / scales[1], 0, 0},
      {0, 0, 0, 1}, {0, 0, 1. / depth_offset, -depth_scale / depth_offset}};
  for (unsigned row = 0; row < 4; ++row) {
    result->cameraViewToClip[row] = {float(projection[0][row]), float(projection[1][row]), float(projection[2][row]), float(projection[3][row])};
    result->clipToCameraView[row] = {float(inverse_projection[0][row]), float(inverse_projection[1][row]), float(inverse_projection[2][row]), float(inverse_projection[3][row])};
    result->clipToPrevClip[row] = {reprojection.m[0][row], reprojection.m[1][row], reprojection.m[2][row], reprojection.m[3][row]};
    result->prevClipToClip[row] = {float(reverse[row]), float(reverse[4 + row]), float(reverse[8 + row]), float(reverse[12 + row])};
    result->clipToLensClip[row] = {float(row == 0), float(row == 1), float(row == 2), float(row == 3)};
  }
  result->cameraPos = {float(inverse[2] / inverse[14]), float(inverse[6] / inverse[14]), float(inverse[10] / inverse[14])};
  result->cameraRight = {float(axes[0][0]), float(axes[0][1]), float(axes[0][2])};
  result->cameraUp = {float(axes[1][0]), float(axes[1][1]), float(axes[1][2])};
  result->cameraFwd = {float(axes[2][0]), float(axes[2][1]), float(axes[2][2])};
  result->cameraNear = float(near_plane); result->cameraFar = float(far_plane);
  result->cameraFOV = float(2. * std::atan(1. / scales[1])); result->cameraAspectRatio = float(aspect);
  // Depth/motion use the native raster grid, exactly as the DLAA inputs do.
  // Vector values and matrices exclude jitter; their sample locations do not.
  result->motionVectorsJittered = sl::eFalse;
  result->motionVectorsDilated = sl::eFalse;
  result->jitterOffset = {inputs.jitter[0], inputs.jitter[1]}; result->mvecScale = {1, 1}; result->cameraPinholeOffset = {0, 0};
  result->depthInverted = sl::eFalse; result->cameraMotionIncluded = sl::eTrue;
  result->motionVectors3D = sl::eFalse; result->reset = inputs.reset ? sl::eTrue : sl::eFalse;
  return true;
}
}
