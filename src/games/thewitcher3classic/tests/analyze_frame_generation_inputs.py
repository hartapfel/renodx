"""Analyze the exact inputs saved by DLSS > Advanced Diagnostics (requires numpy).

Usage: python analyze_frame_generation_inputs.py <inputs-directory>
Reports PQ code differences outside UI, alpha coverage, and motion/depth ranges.
These readback frames contain deliberate stalls and cannot measure performance.
"""
import json
import sys
from pathlib import Path

import numpy as np


def texture(path):
    raw = path.read_bytes()
    width, height, fmt, pitch = map(int, np.frombuffer(raw, '<u4', count=4))
    dtype, channels = {24: ('<u4', 1), 41: ('<f4', 1), 34: ('<f2', 2), 61: ('u1', 1)}[fmt]
    row_bytes = width * np.dtype(dtype).itemsize * channels
    rows = np.frombuffer(raw, 'u1', offset=16).reshape(height, pitch)
    values = rows[:, :row_bytes].copy().view(dtype).reshape(height, width, channels)
    if fmt == 24:
        return np.concatenate([(values >> shift) & 1023 for shift in (0, 10, 20)], axis=2).astype(np.int16)
    return values.astype(np.float32)


def analyze(directory, frame):
    color, hudless, depth, motion, alpha = [texture(directory / f'{frame}-{i}.bin') for i in range(5)]
    alpha = alpha[:, :, 0]
    difference = np.max(np.abs(color - hudless), axis=2)
    clear = alpha == 0
    height, width = alpha.shape
    center = np.zeros_like(clear)
    center[int(height * .25):int(height * .95), int(width * .35):int(width * .65)] = True
    camera = (directory / f'{frame}-constants.bin').read_bytes()
    # Streamline 2.14.16 x64 Constants: 32-byte BaseStructure, five matrices.
    matrices = np.frombuffer(camera, '<f4', count=80, offset=32).reshape(5, 4, 4)
    jitter = np.frombuffer(camera, '<f4', count=2, offset=352)
    rh, rw = depth.shape[:2]
    y, x = np.mgrid[:rh, :rw]
    u, v = (x + .5 - jitter[0]) / rw, (y + .5 - jitter[1]) / rh
    clip = np.stack((2 * u - 1, 1 - 2 * v, depth[:, :, 0], np.ones_like(u)), axis=-1)
    previous = clip @ matrices[3].astype(np.float64)
    camera_motion = previous[:, :, :2] / previous[:, :, 3:4] * [0.5, -0.5] + .5 - np.stack((u, v), axis=-1)
    camera_error = np.linalg.norm((motion - camera_motion) * [rw, rh], axis=2)
    result = {
        'frame': frame, 'output_size': [width, height], 'render_size': [rw, rh],
        'alpha_nonzero_pixels': int(np.count_nonzero(alpha)), 'alpha_max': float(alpha.max()),
        'center_alpha_nonzero_pixels': int(np.count_nonzero(alpha[center])),
        'outside_ui_rgb_difference_codes_p50_p99_max': np.percentile(difference[clear], [50, 99, 100]).tolist() if clear.any() else [],
        'outside_ui_pixels_differing_over_2_codes': int(np.count_nonzero(clear & (difference > 2))),
        'center_rgb_difference_codes_p50_p99_max': np.percentile(difference[center & clear], [50, 99, 100]).tolist() if (center & clear).any() else [],
        'depth_min_max': [float(depth.min()), float(depth.max())],
        'motion_pixels_abs_p50_p99_max': np.percentile(np.abs(motion * [rw, rh]), [50, 99, 100]).tolist(),
        'motion_nonfinite': int(np.count_nonzero(~np.isfinite(motion))),
        'motion_vs_camera_pixels_p50_p90_p99': np.nanpercentile(camera_error, [50, 90, 99]).tolist(),
        'jitter_pixels': jitter.tolist(),
    }
    # A nonzero residual can be legitimate object motion, not an automatic error.
    return result


if __name__ == '__main__':
    print(json.dumps([analyze(Path(sys.argv[1]), frame) for frame in range(2)], indent=2))
