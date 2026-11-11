# Cloud GPU measurements, 11 November 2026

The largest cloud pass is the visible-volume ray march. A matched live comparison
measured about 4.24 ms more GPU busy time with High volumetric clouds than with
Original clouds. Performance reduced that net increase to 2.19 ms.

The baseline measurements below used an NVIDIA GeForce RTX 5090 with driver 621.14 and source commit
`a79890a2`. Appearance controls matched the latest defaults, including Coverage
200%, Density 30%, Formation Size 189%, Layer Thickness 62% and the new shape
controls. The game displayed at 3840x2160 with DLSS enabled. The exact live
cloud render-target resolution was unavailable from the capture.

## Running game

PresentMon 2.6.0 recorded four 12-second samples in the user's held scene. Each
sample used the same swapchain. Analysis discarded the first and last 20 frames.
The user changed the cloud controls and restored High before closing the game.

| Setting | Frames analyzed | GPU busy median | CPU busy median | Present interval median |
| --- | ---: | ---: | ---: | ---: |
| High, first sample | 739 | 15.00 ms | 15.11 ms | 15.33 ms |
| Original | 764 | 10.66 ms | 14.46 ms | 14.68 ms |
| Performance | 753 | 12.84 ms | 14.69 ms | 14.89 ms |
| High, repeat | 741 | 14.79 ms | 14.96 ms | 15.18 ms |

The average of the two High GPU-busy medians is 14.90 ms. Relative to Original,
High adds 4.24 ms and Performance adds 2.19 ms. The small change in presentation
interval is consistent with a CPU limit. This GPU comparison leaves the CPU
cost attributable to DevKit unmeasured.

PresentMon defines GPU busy as time during which at least one GPU engine
executes work for the target process. GPU time also includes GPU wait, which
grew when the cloud GPU workload was reduced. These measurements use GPU busy
to expose the changed GPU work. [PresentMon metric definitions](https://github.com/GameTechDev/PresentMon/blob/main/README-ConsoleApplication.md#csv-columns)

The live differences include the replacement's sky, reflection and shadow
effects. They measure the net scene cost relative to Original clouds.

## Individual GPU passes

An independent Release D3D12 host ran the production shader bytecode with
hardware timestamps around each pass. A compiler VFS overlay added query
markers to a scratch copy of `clouds/pipeline.hpp`. The benchmark disabled the
D3D12 debug layer and used 16 warmup frames followed by 32 measured frames,
advancing the cloud clock at 1/60 second per frame. The user closed the game
first to free the GPU for these runs.

The fixture used a previously captured Kaer Morhen camera and sky constants,
FP16 scene targets, a saturated controlled native weather texture and the
current Medium recipe. Scene depth initially contained empty sky. A new live
capture was attempted, but its native b12/b13 resources were marked
`later_write_or_untracked_command_list` and were excluded. The per-pass timings
therefore describe a controlled replay. PresentMon measured the loaded scene.

At a 1920x1080 internal target, High produced these medians.

| Pass | GPU time |
| --- | ---: |
| Visible-cloud ray march | 3.967 ms |
| Terrain shadow trace | 0.438 ms |
| Reflection environment | 0.385 ms |
| Directional lighting volume | 0.150 ms |
| Temporal resolve | 0.056 ms |
| Sky composite | 0.046 ms |
| History copies and publication | 0.026 ms |
| Weather filter and publication | 0.021 ms |
| Shadow filtering and packing | 0.031 ms |
| Scene copy | 0.012 ms |
| Aerial-perspective volume | 0.004 ms |
| Complete workload, median of frame totals | 5.139 ms |

The visible-cloud march accounts for about 77% of the measured workload.
A repeat measured 5.138 ms overall. The shader samples procedural density at
every ray segment, adds samples at thin edges, integrates optical depth and
evaluates in-scattering. High traces every internal target pixel each frame
before temporal reconstruction.

## Preset and resolution scaling

These runs held the camera, weather and appearance controls constant.

| Internal target | Performance | Balanced | High | Ultra |
| --- | ---: | ---: | ---: | ---: |
| 1920x1080 | 2.10 ms | 2.63 ms | 5.14 ms | 14.20 ms |
| 3840x2160 | 4.20 ms | 5.37 ms | 14.39 ms | 38.90 ms |

High at 2560x1440 measured 7.55 ms. Internal target resolution differs from
display resolution when an upscaler is active. High and Ultra trace at the
internal target's full width and height. Performance and Balanced trace at
half its width and height. Ultra also increases sample counts, the lighting
volume and the shadow map.

High at 1080p measured 0.21 ms for Clear, 4.79 ms for Light, 5.14 ms for Medium,
5.15 ms for Heavy and 4.81 ms for Storm. Dense rays can terminate sooner, so
greater cloud cover does not produce a strictly increasing cost.

## Low sunlight

Reducing solar elevation to about four degrees raised High at 1080p from
5.14 ms to 7.64 ms. The visible-cloud trace increased from 3.97 ms to 5.93 ms.
Terrain shadow tracing increased from 0.44 ms to 0.90 ms.

`TraceCloud` samples the directional visibility volume when the light is high
enough and the sample lies within its valid footprint. At light direction
z <= 0.15, or outside that footprint, it traces secondary rays toward the light
through the procedural density field. Low sunlight therefore adds density
evaluations at many visible-cloud samples.

A scratch shader variant disabled only that secondary light-ray fallback.
The complete workload fell to 4.04 ms in the ordinary fixture and 4.64 ms in
the low-sun fixture. This variant changes lighting outside the visibility
volume and measures the contribution of that work.

## Reduced tracing resolution

A scratch host retained High's material, sampling budgets, lighting volume and
terrain shadows while tracing the main volume at one quarter of the internal
target's width and height.

| Internal target | Main tracing buffer | Complete workload |
| --- | --- | ---: |
| 1920x1080 | 480x270 | 2.01 ms |
| 3840x2160 | 960x540 | 2.84 ms |

Visual acceptance, motion, disocclusion, fine outlines and temporal stability
require separate testing before introducing such a mode.

The reconstruction path also has a foreground cost. `0xF7C00004` traces an
exact full-resolution ray for geometry intersecting the cloud layer when the
primary tracing buffer is smaller. A synthetic foreground rectangle at a
3.5 km view depth raised Balanced's composite from 0.050 ms to 0.806 ms.
High with quarter-size tracing measured 2.78 ms overall in that fixture.
This matters for mountainous views where terrain intersects the low cloud layer.

## Implementation direction

The measurements favor retaining volumetric clouds and reducing repeated
view and lighting work. The first candidate is lower-resolution tracing with
temporal reconstruction and selective refinement for disocclusion and terrain
intersections. Existing High already resolves history after tracing the entire
image, leaving scope for reconstructing samples across frames.

The second candidate is a sun-aligned or cascaded light-transmission cache that
remains useful near the horizon, with bounded secondary rays where necessary.
Epic documents Beer shadow maps as a faster alternative to secondary cloud
shadow rays, with less nearby shadow detail. Its cloud renderer also supports
tracing below the reconstruction and final screen resolutions.
[Epic cloud rendering and shadowing](https://dev.epicgames.com/documentation/en-us/unreal-engine/volumetric-clouds?application_version=4.27),
[Epic cloud scalability](https://dev.epicgames.com/documentation/unreal-engine/volumetric-cloud-component-in-unreal-engine)

Guerrilla's Nubis production work establishes that dynamic volumetric skyboxes
can fit a small GPU budget through rendering and reconstruction choices.
Its published platform timings use different hardware and scenes and serve
as architectural references. [Nubis, Evolved](https://www.guerrilla-games.com/read/nubis-evolved)

A sky dome or layered cards would reduce volume integration but would require
rebuilding depth, parallax, mountain intersections and light response around
that representation. The measured lower-resolution volumetric path provides
a more direct candidate to evaluate for this mod.

## Local artifacts

`tmp/cloud-gpu-profile/` contains the live CSVs, `live-summary.json`,
`frame-samples.csv`, `pass-summary.csv`, per-case logs, `prepare.py`,
`overlay.json`, `build.ps1`, and the temporary shader variants.
The initial profiling work left production shaders and the installed addon
unchanged. The following implementation was measured separately.

## Implemented optimization, 11 November 2026

The accepted cloud density, weather families, height transitions, authored
defaults, scattering model and terrain-shadow budgets are retained. The primary
optimization reduces the number of view rays and reconstructs their results
across frames. It follows the separation of tracing and reconstruction sizes
documented by [Epic's volumetric cloud renderer](https://dev.epicgames.com/documentation/en-us/unreal-engine/volumetric-clouds?application_version=4.27)
and the sparse sampling/temporal reconstruction approaches described by
[Toft, Bowles and Zimmermann, 2016](https://arxiv.org/abs/1609.05344).
These are architectural sources; the integration with REDengine's buffers and
the thresholds below are specific to this mod.

| Preset | Primary trace, relative to internal render dimensions | History / cloud motion |
| --- | --- | --- |
| Performance, Balanced | quarter width and height | half width and height |
| High | half width and height | full width and height |
| Ultra, Custom | full width and height | full width and height |

Each reduced tracing grid uses four spatial phases that visit the centres of
the corresponding reconstruction pixels. The phase advances once when native
time advances, rather than quantizing time at 60 Hz: a stable 30 FPS must still
visit all four positions. Frozen native time holds the phase, including photo
mode and repeated native draws. A reserved GPU-history word stores the phase;
the history resource and injected game constant-buffer layout are unchanged.

The resolve uses positive bilinear weights for current low-resolution samples,
rejects cloud depths behind each foreground pixel, and reprojects history with
native camera, wind and cloud-base motion. Existing depth, colour, opacity,
revision and camera-jump rejection remain active. Unsampled pixels retain more
stable history; current low-resolution denoising is reduced to avoid blurring
away the detail being reconstructed. The full-resolution composite retains
exact ray repair where terrain intersects the cloud layer. Cloud motion is
published at reconstruction resolution, with matching row pitch and metadata.

Hardware timestamps in the same standalone fixture gave:

| Fixture | Baseline | Optimized, experimental cache Off | Reduction |
| --- | ---: | ---: | ---: |
| High, 1920x1080 | 5.14 ms | 2.73 ms | 47% |
| High, 3840x2160 | 14.39 ms | 5.66 ms | 61% |
| High, 1920x1080, low Sun | 7.64 ms | 3.75 ms | 51% |
| Performance, 1920x1080 | 2.10 ms | 1.70 ms | 19% |

High's ordinary 1080p view trace fell from 3.97 ms to about 1.56 ms; temporal
resolve remained about 0.06 ms. Terrain shadows, reflection lighting and the
lighting volume still contribute their existing fixed costs. These are cloud
pipeline timings, not whole-game frame times or predicted gameplay FPS. The
original live game comparison above predates this implementation.

### Experimental low-sun lighting cache

The user requested the second optimization remain available for testing.
**Clouds → Clouds & Performance → Low Sun Lighting Cache (Experimental)** is
Off by default, saved per preset, and independent of the quality preset.
Switching it changes the cloud settings revision and invalidates old lighting
history. Clouds-tab reset returns it to Off.

On extends the existing directional optical-depth volume to light elevations
with `0.02 < direction.z <= 0.15`. The volume is sheared toward the dominant
Sun/Moon direction so grazing rays stay within a useful cache footprint.
Each low-sun voxel evaluates the existing sparse light-ray quadrature; the
normal high-sun slice recurrence remains in use above that range. Consumers
transform into the same sheared coordinates, blend at the valid footprint
edge and retain the original secondary ray outside it. Below the minimum
elevation the original fallback remains active. Previous light direction and
wind are accounted for when reusing the experimental volume.

The shared `light_ray.hlsli` contains the original fallback quadrature, used
by both the cache and its fallback. This avoids replacing the accepted light
transport with a denser, darker quadrature. The first denser-cache experiment
was rejected after captures showed a substantial brightness change.

Reusing directional visibility instead of repeating secondary rays follows the
performance tradeoff documented in [Epic's cloud shadowing overview](https://dev.epicgames.com/documentation/en-us/unreal-engine/volumetric-clouds?application_version=4.27).
The sheared coordinate mapping and exact cache thresholds are our implementation,
not a claim to reproduce Epic's cascaded Beer shadow maps.

| Optimized High, low Sun | Cache Off | Cache On |
| --- | ---: | ---: |
| 1920x1080 | 3.75 ms | 3.78–3.89 ms across two runs |
| 3840x2160 | 8.21 ms | 6.64 ms |

The cache adds about 0.35 ms to the lighting-volume pass in this fixture and
reduces repeated light work in the primary trace and reflection. At 1080p its
fixed cost and timing variability offset those savings. At 4K it reduced the
measured total about 19%. It is an optional experiment, with no universal speed
claim. Cached lighting can soften internal shadows or alter brightness.

### Appearance and validation

Matched 1920x1080 linear-HDR captures, after 64 advancing frames at the archived
Kaer Morhen view, compared accepted defaults before/after the High tracing
change: Light relative RGB L1 0.225%, Medium 0.447%, Heavy 0.431%. Aggregate
radiance ratios were 0.9992, 0.9987 and 0.9987. Visual comparisons retained the
large cloud forms and internal detail, with small changes at fine edges.
These aggregate metrics do not prove equivalence during gameplay motion.

An isolated full-resolution Custom comparison of the experimental cache at
about four degrees Sun elevation measured relative RGB L1 3.69% and aggregate
radiance ratio 0.9717. This is why the lighting cache is labelled experimental
and defaults to Off. Its visible result needs the user's in-game evaluation.

GPU regressions cover odd-sized render targets, all four phases at 30 Hz,
paused phase stability, foreground rejection, reconstruction/motion resource
dimensions, all presets, weather transitions, HDR celestial occlusion, and
the cache toggle's reversible low-sun and unchanged ordinary-daylight paths.
Scratch captures, timestamp logs and appearance metrics are in
`tmp/cloud-optimize/`; `tmp/cloud-gpu-profile/` retains the profiling host.

The normal `build-release.ps1` target completed with 387 production cloud GPU
cases, UI/reset integration, native receiver replays and the full mod-local
regression suite. The built Release addon also passed isolated ReShade/HDR
startup checks for Performance and High in both addon load orders and both
fog-quality paths. The test host, rather than Witcher 3, performed these checks;
gameplay motion and user visual acceptance remain to be tested in game.
