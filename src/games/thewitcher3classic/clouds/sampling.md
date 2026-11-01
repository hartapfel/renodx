# Cloud sampling provenance and implementation

The scalar mask in `fast_noise.hpp` comes from Electronic Arts SEED's
[FAST repository](https://github.com/electronicarts/fastnoise), commit
`2cf53e4bb510d07511fe63a312556d2a2e108c70`. It is licensed under the adjacent
`LICENSE.fastnoise`, which the Release packager includes in `renodx-licenses`.
The addon embeds the mask; there is no runtime image loader or extra install step.

The original archive is available from
[EA's pinned noise.zip](https://media.githubusercontent.com/media/electronicarts/fastnoise/2cf53e4bb510d07511fe63a312556d2a2e108c70/noise.zip).
Archive SHA256: `35fe2ce496a837186931acc5afedcdf53ef22d1aaf6d01ad1dcd416c5ff68cea`.
Import with `python src/games/thewitcher3classic/clouds/import-fast-noise.py PATH_TO_noise.zip`.
The script verifies both archive and decoded byte hashes, requires only Python's
standard library, and extracts the original R channel without resizing or cropping.

Selected files: `noise/real/temporal/exp/real_uniform_gauss1_0_exp0101_separate05_N.png`,
N = 0..31. All 128x128 pixels and 32 time slices are retained. GPU format is
immutable R8_UNORM, 512 KiB, no mip chain. Frame-major decoded SHA256:
`76471f8e2659ca0ff1e85173835a818c23c9a05d9dc89410c37934782bfb87a5`.

## Research basis

- [FAST, EA SEED, I3D 2024](https://www.ea.com/news/spatio-temporal-sampling)
  optimizes sampling patterns for spatial and temporal filters. The repository's
  [design guide](https://github.com/electronicarts/fastnoise/blob/2cf53e4bb510d07511fe63a312556d2a2e108c70/FastNoiseDesign.md)
  explains separate space/time objectives, Gaussian perceptual spatial filtering,
  EMA temporal filtering, and additional dimensions through spatial R2 offsets.
- [Spatiotemporal Blue Noise Masks, NVIDIA/EA, EGSR 2022](https://research.nvidia.com/publication/2022-07_spatiotemporal-blue-noise-masks)
  demonstrates improved filtered convergence, including volumetric rendering.
  [NVIDIA's implementation notes](https://developer.nvidia.com/blog/rendering-in-real-time-with-spatiotemporal-blue-noise-textures-part-2/)
  explain point reads, periodic addressing, and the limitations under motion.
- [A Survey of Temporal Antialiasing Techniques, Yang/Liu/Salvi, 2020](https://diglib.eg.org/bitstreams/53732e70-b64d-46f4-bbae-865eb7673a35/download)
  covers neighborhood/variance history validation and HDR filtering tradeoffs.
  [AMD's reversible resolve discussion](https://gpuopen.com/learn/optimized-reversible-tonemapper-for-resolve/)
  explicitly identifies brightness bias from nonlinear HDR weighting.

These establish the techniques, not a uniquely correct set of Witcher-specific
constants. The implementation is an adaptation, not EA's complete renderer.

## Mod-specific choices and limits

`sampling.hlsli` point-loads `(pixel + R2 offset) mod 128`, `frame mod 32`, converts
8-bit values to open-interval bin centers, and never interpolates the mask.
Dimension zero jitters the primary march; separate dimensions jitter the two
uniform strata of each sun/sky interval. Each primary step has 128 dimension
indices; sun starts at 1, sky at 65. R2 offsets approximate decorrelation and
do not provide a proven high-dimensional low-discrepancy distribution.

The visible-cloud sun march uses `ceil(1.5 * light_budget)` intervals with two
strata each. Skylight uses 8 samples at Low and 12 at Medium and above. The
old 6-sample Medium budget combined with stochastic positions leaked excessive
light after exponential attenuation; increasing samples was necessary. The
finite-sample exponential remains biased; this is not an exact transport solver.
Density-footprint filtering and multiple scattering remain approximations.

The temporal resolve computes BT.709 linear luminance mean/variance over the
valid 3x3 neighborhood. Relative variation below 10% allows more accumulation
and a noise allowance up to two standard deviations. High-contrast regions
retain the earlier response to moving detail. History weights range from 0.8
to 0.9 before opacity, radiance-change and motion rejection. The selected mask
targets an EMA with alpha 0.1; adaptive weights and reprojection mean this is
only an approximate filter match. RGB stays linear with scalar blend weights;
no inverse-luminance energy bias, display noise, HDR cap, or sun-disc blur is added.
Existing depth, camera-cut, clock and weather history rejection remains active.

HDR awareness belongs to history validation, not the random sample distribution:
biasing ray positions by brightness would change the lighting integral. Dithering
can distribute integration error and reduce fixed terraces; it cannot repair a
wrong density/light model or guarantee noise-free disocclusions. Live acceptance
must include slow pans, changing weather, dark clouds, bright rims and DLSS/FG.
