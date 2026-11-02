# Volume-grid fog sampling

The Volume grid fog renderer uses the same embedded EA SEED FAST scalar mask
as the clouds. [Asset provenance, reproduction and BSD license](../clouds/sampling.md)
remain centralized there. No new download, preset migration or user control is
required. Per-pixel fog keeps its existing sampling; its compute shader is
byte-identical to the previous build.

## Research and implementation

- [Donnelly et al., FAST, I3D 2024](https://www.ea.com/news/spatio-temporal-sampling)
  designs samples for spatial/temporal reconstruction and demonstrates volumetric
  rendering. We reuse the Gaussian/EMA scalar mask, preserving its 128x128 spatial
  ordering and 32-frame sequence. The mask's time axis is time, not froxel depth.
- [Wronski, Volumetric Fog and Lighting, SIGGRAPH 2014](https://advances.realtimerendering.com/s2014/wronski/bwronski_volumetric_fog_siggraph2014.pdf),
  slides 55–59, describes varying samples inside volume cells and accumulating
  them using world-space reprojection to reduce structured aliasing.
- [Yang, Liu and Salvi, A Survey of Temporal Antialiasing Techniques, 2020](https://diglib.eg.org/bitstreams/53732e70-b64d-46f4-bbae-865eb7673a35/download)
  discusses neighborhood validation and HDR history filtering. We use relative
  luminance statistics for validation and linear RGB for accumulation.

These motivate the method; the cell layout, sample counts and rejection
thresholds below are implementation choices validated against this mod's inputs.
The reused mask is an approximate filter match, not a newly optimized 3D mask.

`0xF3C30001` retains the existing number of directional shadow samples and
mirrored, stratified radial coverage. FAST translates the XY pattern and varies
the position within each radial stratum each frame. Each depth slice uses R2
spatial translations for its three sample dimensions; this decorrelates slices
approximately and does not constitute a high-dimensional QMC construction.
Local lamps use four stratified, antithetic radial samples within a cell. Screen
coordinates stay at the cell center so native tiled-light membership is valid.
Terrain and cloud attenuation retain their existing evaluations.

`0xF3C30004` reprojects the unjittered cell center into the previous view and
logarithmic radial grid, then filters **source lighting before integration**.
History starts at weight 0.9 (EMA alpha 0.1) and responds to motion, relative
luminance change and chromatic change. Six adjacent cells plus the current cell
provide luminance bounds and variance. Luminance clipping scales history RGB
together, preserving its chromaticity; accumulation remains linear. Sampling
positions do not depend on brightness. No display-space noise is added.

History is rejected outside the previous grid, across camera jumps, incompatible
medium density, sunlight/weather/night-setting changes, skipped frames, long
pauses, renderer/context changes and grid/quality/setting changes. Extinction
always comes from the current frame: density, interior exclusion, weather opacity
and fog start distance are not temporally blurred. Moving local shadows still
rely on neighborhood validation; this is not a motion-vector solution for every
moving occluder, and disocclusions cannot be guaranteed noise-free.

Sparse-fog lighting formerly entered FP16 as `source * extinction`, making dim
light subnormal before integration. The matched storage scale is now
`max(extinction, 0.25)`, decoded before transport, leaving opacity untouched.
This is a precision change, not a fog-strength multiplier. Existing FP16 guards
remain: encoded components and integrated radiance are capped at 60000. For
extinction below 0.25, the source-storage ceiling is 240000 in scene-linear units.
The cloud/fog composition test budgets combined source/extinction/integrated
FP16 rounding relatively (0.2% plus 0.002), rather than using an absolute error
smaller than one half-float ULP at HDR radiance 37.

Two reusable RGBA16F history grids and one 512 KiB immutable FAST texture are
added. At 16:9, history costs about 63.3 MiB for medium (240x135x128), and
324 MiB for maximum detail (384x216x256). History volumes are released when the
per-pixel renderer is selected. Resources and bindings stay inside the fog's
isolated D3D11 context; no new native-material resource slots are reserved.

## Verification — 2026-11-02

The Release-embedded shaders and production C++ pipeline pass WARP and hardware
tests in `tests/volumetrics.cpp`: Beer transport, authored weather, all grid
qualities, interior vacuum, local lights/shadows, unchanged transmittance,
native-state restoration, and the new temporal cases. The latter exercise valid
perspective reprojection, 0.001/1/1000 lighting scales, chromaticity, stable energy,
frame/setting/camera rejection and sudden removal of sunlight. A 32-frame average
checks stochastic dim-lamp lighting against dense independent cell quadrature.

In the stationary shadow test, filtered variance is at most 12% of unfiltered
FAST variance; some results quantize to zero variance in the final FP16 field.
Mean radiance changes by less than 0.1%. This does not prove zero noise in motion.
The D3D debug layer is unavailable locally; numerical and explicit context-state
checks pass, but debug-layer validation is not claimed.

A separate GPU comparison sweeps an analytic radial shadow edge from 140 to
160 metres in quarter-metre increments at low shadow sample quality. Each pose
uses 32 settling frames and a 32-frame average. Relative to the prior Release
scatter/integration shaders:

| Metric | Previous grid | FAST grid |
|---|---:|---:|
| Normalized radiance RMSE | 0.000712584 | 0.000474785 |
| Excess second-difference RMS (layer steps) | 0.000983680 | 0.000246186 |
| Medium grid GPU time, sun only | 0.093 ms | 0.151 ms |
| Medium grid GPU time, sun + four point lights | 0.128 ms | 0.306 ms |

These are bounded synthetic GPU measurements on the development machine, not
gameplay FPS. Per-pixel fog cache tests and cloud lighting/composition/motion/
sun-occultation regressions also pass. Ground cloud-shadow bytecode is unchanged.
Evidence and reproducible comparison runners:
`tmp/witcher3classic-investigation/fog-fast-20261102/`.

Clang x64 Release build passed and the game-folder addon symlink resolves to the
verified build. Addon SHA256:
`9CD090A8E420A828724596574BA0E672E91E3B86EDF303755003A98DD5716F02`.

Live acceptance still needs the originally affected scene with Atmospheric Fog
set to Custom and Fog Lighting Method set to Volume grid. Compare stationary
light shafts, slow pans, moving torch/occluder shadows, dark interiors, weather
changes and DLSS/FG. Volume Smoothing retains its existing spatial reconstruction;
FAST and temporal filtering remain active with either smoothing setting.
