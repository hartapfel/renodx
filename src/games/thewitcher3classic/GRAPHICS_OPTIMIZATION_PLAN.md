# Classic graphics optimization and quality plan

Date: 2026-11-02. Status: execution in progress; see section 7 for implemented changes, measurements and remaining gates.

## 1. Objective and decision rules

Make the normal Custom preset efficient enough for regular gameplay while retaining the mod's improved lighting, atmosphere, water and HDR presentation. Optimize repeated work and sampling allocation before reducing visible quality. Offer additional quality only where it produces a clear improvement in motion at a reasonable measured cost.

The first implementation priorities are **bloom scheduling, cloud lighting, water reflections, and motion-vector overhead**. Fog has useful optimization opportunities, but the existing measurements do not justify treating it as the largest bottleneck. Actual gameplay profiling must establish the order within the expensive group.

Rules for the work:

- Preserve the approved cloud appearance baselines: physical density 0.6, surface detail 4, detail size 0.8 and layer thickness 1.3, each represented by its current UI baseline. Preserve the independent, working ground cloud shadows.
- Preserve physical extinction, HDR sun occlusion, local-light visibility, weather composition, transparent receivers and correct motion. A cheaper image that leaks the sun, bands, trails, or loses foliage shadows does not qualify.
- Use one good implementation for inexpensive features. Do not add Low/Medium/High to every checkbox or artistic slider.
- Keep compatibility/native modes and diagnostic reference modes available, but separate them from recommended gameplay quality.
- Treat all proposed defaults below as candidates until they pass the scene matrix. Do not silently replace saved user settings.
- Stay within Classic's D3D11/SM5 integration. Research provides algorithms, not permission to replace the engine or import a modern SDK wholesale.

There is no single industry-standard setting count or sample budget. The relevant production principles are multiresolution filtering, conservative work rejection, amortized lighting, temporally validated reconstruction, and profiling on the actual target workload.

## 2. Audit basis and limits

Current behavior was audited in [presets.hpp](presets.hpp), [addon.cpp](addon.cpp), and the implementation files linked below. The Custom columns in `presets.hpp` define fresh-install/reset graphics defaults. Some startup values in subsystem headers and older README sections disagree with those defaults; they must not be used as the performance baseline.

In particular, the current defaults are **Medium clouds at Automatic resolution, grid fog at detail 1 with smoothing, and full-resolution stabilized water SSR**. Fog detail 2 and SSR full resolution Off appear elsewhere in the repository but are not the current preset defaults.

This plan combines code-derived work counts with existing recorded GPU measurements. **No new live gameplay timing was collected for this document.** A work count identifies a scaling problem; it does not establish milliseconds. Historical fixtures have different inputs, revisions and included passes, and their numbers must not be added into a fictional total frame time.

### Recorded evidence

| Feature / workload | Recorded GPU cost | What the evidence establishes |
| --- | --- | --- |
| Clouds, RTX 5090, isolated 4K output, 75% visible sky, Medium/Auto | 2.120 ms after FAST plus refined lighting; previously 1.168 ms | Secondary lighting refinement was expensive. This predates the latest density/shape rebases and is not today's default gameplay cost. |
| Same cloud fixture, Medium/Half | 6.498 ms; previously 3.798 ms | Resolution multiplies expensive ray work. |
| Same cloud fixture, Ultra/Half | 22.112–22.456 ms; previously 11.584–13.458 ms | This configuration is unsuitable as a normal performance-friendly recommendation without substantial optimization. |
| FAST fog, synthetic medium grid, sun only | 0.151 ms; previously 0.093 ms | Current scatter/history/integration has a measurable cost; this is detail 2, not the current detail-1 default or the entire fog rendering path. |
| Same fog fixture, sun plus four point lights | 0.306 ms; previously 0.128 ms | Local-light integration is a useful target. FAST also reduced the fixture's layer-step metric by about 75%; do not discard that improvement. |
| Underwater integration, isolated 4K fixture | About 1.01 / 1.30 / 2.90 ms at detail 1 / 2 / 4 | Higher sample tiers are not free. These are historical integration measurements, not the whole underwater/caustics pipeline. |
| Water ripple evaluation, isolated full-screen 4K fixture | Original 0.0355 ms; Surface Waves 1.1664 ms | Optional wave construction can be expensive when covering the screen. This is not an incremental cost for every gameplay scene. |
| SSR, PCSS, contact shadows, bloom, DOF, motion blur, rain, grading | No matched current end-to-end timing established in this audit | Profile rather than assign invented millisecond figures. |

Evidence and fixture conditions: [cloud research](CLOUD_RENDERING_RESEARCH.md), [FAST fog sampling and verification](volumetrics/sampling.md), [water SSR research](WATER_SSR_RESEARCH.md), and the underwater/ripple verification entries in [README.md](README.md). Prior motion-vector optimization is documented in [the integration notes](../../../docs/OBJECT_MOTION_VECTOR_INTEGRATION.md); its older live traces are not a current matched A/B result.

## 3. Main settings: cost drivers and intended treatment

“Small” below means a small structural increment such as arithmetic in an existing pass, not a measured guarantee of zero cost.

| Main settings | Current Custom/default behavior | Principal GPU cost driver | Proposed treatment |
| --- | --- | --- | --- |
| Cloud mode, quality, resolution, step size | Volumetric; Medium; Auto; 100% step | Traced pixels × occupied view samples × secondary density evaluations; reconstruction and composition add bandwidth | Balanced default and High upgrade after optimization. Keep technical overrides advanced. |
| Cloud coverage, density, size, thickness | Current rebased 100% values | Change occupied pixels, path length and early termination; density cost is not monotonic | Artistic controls; preserve appearance. Do not market lower density as a performance setting. |
| Cloud surface detail, detail size, base softness | Rebased 100%, 100%, 0% | Noise evaluations, footprint/mip behavior and fine geometry; some scalar changes retain identical instruction counts | Artistic controls with correct ranges. No additional quality tiers for individual sliders. |
| Ground cloud shadows | On | Separate world-space density integration and shadow-map updates | Keep On and retain current result. Optimize scheduling only after a measured need. |
| Surface lighting / ambient AO influence | Custom PBR / Ambient Only | Modified material lighting arithmetic; AO influence changes application, not the native AO generator | One good default; no quality tiers. Profile representative material families. |
| Directional soft shadows / sun diameter | Custom soft, 0.35 degrees | Blocker search, PCF taps and cascade overlap | Keep good custom softness. Optimize internally; diameter is physical appearance, not a sample-count slider. |
| Contact shadows / reach | On, 1 m | Four screen-sized compute stages; 16-step trace, spatial and temporal filtering | One robust On implementation. Add a higher tier only if a validated reconstruction tradeoff emerges. |
| Player/cutscene fill / unify | Custom, 0.2 / 0.2, unified | Existing light inputs and shading; mostly scalar changes | Preserve. No performance presets for fill strengths. |
| Fog method / detail / smoothing | Volume grid, detail 1, smoothing On | Grid cell count, local-light overlap, shadow sampling, history and receiver filtering | Balanced = existing low grid plus FAST and smoothing; High = medium grid if beneficial. Per-pixel remains advanced. |
| Fog density, haze, distance, height, anisotropy, strengths | Current authored overrides; local-light strength 2 | Mostly parameters; zero values can reject work, but small nonzero values generally do not | Artistic controls. Preserve weather and medium transport. |
| Fog shadow quality | 1 | Directional shadow sample count per active cell | Tie to fog quality internally unless independent control proves useful; retain advanced override. |
| Water rendering / ripple pattern / strength | Custom, Original, 0.3 | Visible water area; optional Surface Waves adds substantial normal/gradient work | Keep Original default. Surface Waves remains an optional appearance choice. |
| Water SSR resolution / stabilization | Full resolution / On | Ray starts, DDA traversal, history, filtering, mips, copies and retained native chain | Develop half-resolution stabilized Balanced; full-resolution High. Do not ship a blurrier default before reconstruction passes review. |
| Underwater density / detail / caustics | 1 / 1 / 1 | Sun-shadow integration, water classification, caustic preparation and visible receiver area | Keep detail 1; offer detail 2 as High only if the difference is visible. Keep caustics at good fixed quality. |
| Underwater camera blur / CA | 0.15 / 1 | Screen distortion/filtering and waterline coverage | Preserve intended look; optimize inactive/covered regions. These are style controls, not quality tiers. |
| Refractive rain | On | Extra sampling and particle overdraw; reuses native draw/scene-copy path | Keep On, one quality. Measure storm fill rate before spending development time here. |
| Bloom mode / size / selection / strength | Custom; 2 / 3 / UI 5 | Current size drives repeated blur/add passes; nonzero strength barely changes work | Replace with efficient multiscale bloom, keeping appearance controls. No bloom quality menu. |
| Motion blur / strength | Object Only; UI 50 | Velocity preparation, six reductions, half-resolution filtering and composition: 12 draws when active | Proposed fresh default Off; Object Only remains the immersive option. Optimize it, rather than introduce noisy Low blur. |
| DOF / lens parameters | Native; Custom inactive, foreground strength 0 | Custom path has six passes plus large-radius sampling; native cost follows the game | Keep Native to preserve authored cutscenes; Custom remains optional lens control. No new generic quality slider. |
| Chromatic aberration | Native; Custom optional | Custom cubic reconstruction can require 16 scene taps per color channel before other branches | Keep Native/game preference; optimize optional Custom only after profiling. |
| Sharpening / grain | Replacement enabled but strength 0; grain 0 | Sharpening may add a full-image pass; grain is final-image arithmetic | Preserve neutral defaults. Single strength controls. |
| Sun shafts / lens dirt / vignette | UI strengths 50; perfect-black vignette enabled | Shafts can be a separate native effect; dirt/vignette often integrated sampling/arithmetic | Preserve appearance initially. Audit shaft overlap with real volumetrics; no extra quality tiers. |
| HDR tone mapping / grading / gamut / peak brightness | Custom tone mapper and user display calibration | Full-image ALU/sampling, resource formats and pass placement | Retain color correctness. Optimize neutral paths and duplicated work, not HDR precision by default. |
| Darker nights / exposure / moon / ambient controls | Enabled with current preset values and adaptation | Mostly existing light/exposure operations; verify adaptation dispatches and copies | Preserve style and exposure behavior. No quality menu. |
| Video AutoHDR | BT2446A | Video-only conversion/shading | Preserve; no gameplay quality tier. |
| DLSS / object and vegetation motion | Quality; full object motion; vegetation included | Upscaler plus vector output, state handling, depth/resource copies; reduces upstream pixel work | Keep Quality as starting point on supported hardware; validate by output resolution. Preserve vegetation vectors. |
| Frame generation / HUD quality | Off / Standard | Bridge synchronization, copies, HUD separation and interpolation | Keep Off by default. Existing opt-in choices suffice; generated FPS is not a rendering optimization metric. |

## 4. Execution sequence

### Phase 0 — establish a reproducible frame budget

**Deliverable:** a checked-in benchmark protocol and result table tied to source/addon hashes, plus optional developer-only timing instrumentation. This is the prerequisite for approving changed defaults.

1. Add asynchronous D3D11 timestamp ranges around cloud preparation/trace/resolve/composition/shadows, fog scatter/history/integration/consumers, SSR copy/trace/history/mips, contact stages, optics stages, underwater preparation/integration, motion-vector support, grading and bridge copies. Capture CPU hook/state-management time separately. Retrieve queries several frames later without forcing a flush; reject disjoint samples. Microsoft's [query documentation](https://learn.microsoft.com/en-us/windows/win32/api/d3d11/ne-d3d11-d3d11_query) describes timestamp frequency and validity requirements.
2. For features embedded in native material shaders, use matched replacement/native A/B measurements over the affected draws. Do not label the entire native draw as mod overhead. Record shared costs once and distinguish exclusive pass timings from total frame delta.
3. Record output and internal resolution, native game options, profile, weather, camera/save, exposure, driver/GPU, VRAM, frame generation state, draw/dispatch counts and resource sizes. Warm histories, then collect at least three 300-frame runs per comparison; report median, p95, p99 and run-to-run spread. Include a separate camera-cut/transient run.
4. Start at 1440p and 4K on the development GPU, FG Off, with native/DLAA and DLSS Quality measured separately. Before broad default claims, repeat on an available representative midrange GPU with less VRAM. Do not extrapolate RTX 5090 milliseconds to every card.
5. Scenes: clear sky; broken clouds crossing the sun; dense overcast; foggy forest shafts; indoor/outdoor boundaries; night with overlapping lamps; Novigrad crowds and windy foliage; grazing-angle water and shorelines; underwater/waterline; heavy rain; bright cutscene bokeh and bloom.
6. Measure both one-feature changes and the complete recommended preset. Optimizations may move the bottleneck or duplicate another feature's preparation. Rank by actual frame-time savings and quality, not shader length.

Agree a default-preset overhead budget from these captures. As an initial product target, test whether the mod's incremental GPU work can stay within roughly 20% of the chosen real-frame budget: 3.3 ms at 60 Hz or 1.7 ms at 120 Hz. These are planning targets, not measured feasibility or promises, and upscaling savings must be reported separately.

### Phase 1 — remove excessive post-processing and inactive work

**Primary files:** [optics/pipeline.hpp](optics/pipeline.hpp), [optics shaders/settings](optics/), [chromatic aberration](effects/chromatic_aberration.hlsli).

**Bloom is the clearest structural win.** At size 2, the current code performs one prefilter, 20 iterations of horizontal blur + vertical blur + accumulation, and one final composite: **62 draws**, mostly at quarter width/height. Size 3 reaches 92 draws. Lowering nonzero intensity does not remove these passes.

Replace this with a small downsample/upsample pyramid and a fitted combination of scales. Target roughly 10–14 draws including composition for the normal range; size should alter scale weights/radii rather than add three draws per iteration. Fit the existing radial glow profile and total energy using point, line and extended HDR sources. Suppress subpixel highlight flicker in the prefilter without clipping bright color or flattening stars. Multiresolution wide blurs are established production practice; [Epic's bloom documentation](https://dev.epicgames.com/documentation/en-us/unreal-engine/bloom-in-unreal-engine) explicitly places wider filters at lower resolutions.

Also skip Custom DOF's near-field preparation/filtering when foreground strength is zero, supplying a valid neutral input to composition. Gate unused optical captures and allocations where lifetimes permit; preserve existing zero-effect early exits. Fuse composition with an adjacent pass only when color space, ordering, alpha, HUD separation and resource ownership match. Keep the existing sharpen-once optimization ahead of Custom CA; do not reintroduce sharpening inside every lens tap.

**Acceptance:** matched bloom energy and radius, stable moving highlights, no HDR clipping/color shift, no HUD blur, measured GPU and CPU improvement at 1440p/4K. Draw-count reduction alone is insufficient. Retain one quality implementation.

### Phase 2 — reduce cloud density evaluations without losing the lighting model

**Primary files:** [cloud settings](clouds/settings.hpp), [trace shader](clouds/0xF3C60002.cs_5_0.hlsl), [density functions](clouds/common.hlsli), [pipeline](clouds/pipeline.hpp).

The current quality ladder combines several multipliers:

| Tier | Auto divisor per axis | Base view samples | Sun density samples per lit view sample | Sky density samples per lit view sample |
| --- | ---: | ---: | ---: | ---: |
| Low | 4 | 32 | 10 | 8 |
| Medium | 4 | 48 | 12 | 12 |
| High | 4 | 64 | 16 | 12 |
| Ultra | 2 | 80 | 18 | 12 |
| Cinematic | 2 | 128 | 30 | 12 |
| Maximum | 1 | 160 | 36 | 12 |

View sample count is divided by the step-size multiplier. Quarter/half/full resolution means 1/16, 1/4 and all source pixels. A fully occupied, still-lit Medium ray can therefore approach `48 × (1 + 12 + 12) = 1,200` density evaluations before other work. Actual rays often do less through empty regions and attenuation. Each density evaluation can fetch several noise/weather textures; higher tiers also change erosion and filtering. Multiple-scattering octaves reuse optical depth and are not the main nested-ray cost.

Implement in separately measured stages:

1. Add counters in a diagnostic variant for primary samples, occupied samples, sun/sky density queries and rejected pixels. Identify dominant scenes and validate the model above.
2. Prototype amortized sky-column optical depth, then coarse sun-light optical depth, in a bounded cloud-space cache. Retain accurate near-field density integration and interpolate only the smoother distant contribution. Invalidate or advect consistently with wind, weather, layer geometry, sun direction and appearance changes. Include cache update cost and memory in comparisons. Reject the prototype if cache resolution causes the same internal terraces we are trying to remove.
3. Add conservative empty-space rejection. First use the cheap macro envelope to avoid fine erosion evaluation where it proves emptiness. Prototype a coarse occupancy hierarchy only if savings exceed construction cost. Use conservative maximum bounds/dilation; average-density mips cannot prove a cell empty. Retain fine steps near boundaries and thin wisps.
4. Improve temporal reconstruction confidence at moving cloud edges, depth discontinuities and disocclusions. Allocate extra work to unstable regions rather than globally increasing resolution. Evaluate filtered density LODs against silhouette/detail references; do not hide bands by blurring the entire cloud.
5. Re-tune sample counts only after the structural changes. Preserve sun and overhead sky integration at every normal tier. Test current FAST distribution with the actual reconstruction filter rather than replacing it with visible final-image noise.

Guerrilla's [Nubis publication overview](https://www.schneidervfx.com/) identifies ray-march and light-sampling acceleration as production techniques. Its voxel/SDF architecture is not a drop-in replacement for this procedural layer; the proposed cache and conservative hierarchy are adaptations that require local proof. [EA's FAST research](https://www.ea.com/news/spatio-temporal-sampling) optimizes samples for reconstruction filters; it does not make additional samples free or repair biased transport automatically.

**Critical invariant:** the trace currently stops expensive lighting at transmission 0.005 but continues extinction toward 1e-8. Preserve that distinction. Truncating total transmission at 0.005 can reveal a recognizable HDR sun disc. Keep direct sun attenuation separate from broad in-scattered glow, and do not use the differently calibrated ground-shadow map as internal cloud illumination.

**Acceptance:** reduced density-query work and total cloud time, including new caches; unchanged approved morphology and ground shadows; no reappearing disc through optically thick clouds; no terrace contours, wind trails or excessive temporal shimmer. Compare both instantaneous frames and moving sequences against a dense reference. Static accumulated means alone are inadequate.

### Phase 3 — make water SSR proportional to useful reflection work

**Primary files:** [screen_reflections.hpp](water/screen_reflections.hpp), associated water trace/history shaders, [SSR research](WATER_SSR_RESEARCH.md).

Full resolution starts 16 times as many rays as native quarter width/height. The current DDA stride adapts, so this is not a claim of 16 times the total frame cost. The private path also retains the native chain for fallback/padding. At a 4K trace extent, its eight main images occupy approximately 517 MiB including history mips, before the opaque-depth copy and native resources; actual allocation depends on active dimensions.

1. Add half width/height as an intermediate trace extent. Reconstruct using receiver depth/normal and reflection-hit history, with full-resolution refinement for unstable edges. Keep stabilization enabled.
2. Classify reflective water tiles before expensive tracing. Preserve shoreline padding and water-surface discovery when the camera is above water. Do not assume a zero-water classification from an unavailable mask.
3. Prototype hierarchical depth traversal with correct inverted-depth bounds and thin-intersection handling. Compare depth-pyramid construction plus traversal with current DDA, especially when little water is visible.
4. Remove redundant native tracing only after every needed fallback, mip and padding input has an explicit replacement. Keep the opaque depth snapshot until its lifetime before water modifies depth is proven unnecessary. Resource lifetime is part of correctness.
5. Audit history/guide copies and formats; reuse allocations safely across stages, but do not alias resources read and written simultaneously. Address moving reflected objects before extending history retention.

AMD's [SSSR algorithm](https://gpuopen.com/manuals/fidelityfx_sdk/techniques/stochastic-screen-space-reflections/) provides relevant examples of depth hierarchy, tile classification, variable ray allocation and denoising. Adapt those ideas to the existing D3D11 water path; direct SDK adoption is outside this plan.

**Acceptance:** proposed Balanced is visibly stable at shorelines, grazing angles, camera motion and disocclusions, with lower total GPU time and memory than current full resolution. High must show a real detail benefit. Preserve environment fallback; screen-space methods cannot recover unseen geometry.

### Phase 4 — optimize fog and shadows while retaining smooth transport

**Primary files:** [fog pipeline](volumetrics/pipeline.hpp), [scatter](volumetrics/0xF3C30001.cs_5_0.hlsl), fog common/sample/per-pixel includes, [shadow helpers](lighting/shadows.hlsli), [contact pipeline](lighting/contact.hpp).

Grid cost scales strongly with dimensions, independently of DLSS render scale:

| Detail at 16:9 | Grid | Cells | Cell-count ratio | Four principal RGBA16F volumes, including extra integration slice |
| --- | --- | ---: | ---: | ---: |
| 1 | 160 × 90 × 96 | 1.38 million | 1× | 42.3 MiB |
| 2 | 240 × 135 × 128 | 4.15 million | 3× | 126.8 MiB |
| 3 | 320 × 180 × 192 | 11.06 million | 8× | 337.9 MiB |
| 4 | 384 × 216 × 256 | 21.23 million | 15.36× | 648.6 MiB |

These are allocation estimates, not measured bandwidth or total fog memory. They exclude native inputs, constant buffers and the FAST asset.

**Fog work:**

- Traverse the local-light list once per cell, evaluate all four existing antithetic radial samples inside the light loop, and share invariant light data. Currently four `LocalScattering` evaluations repeat list traversal. Preserve sample positions and weighting; check register pressure before declaring a win.
- Add conservative light-versus-cell depth bounds before expensive shadow evaluation. Consider compact 3D light lists only if construction amortizes over enough overlapping lights; the existing 2D tile list may remain faster in simple scenes.
- Avoid inactive sun/local-light work and unnecessary snapshots without breaking forward-material consumers. Keep density/extinction deterministic, the FP16 source scaling, and current temporal rejection rules.
- Profile history and integration bandwidth. Investigate resource lifetimes or fusion only if it removes measured traffic; temporal neighborhood reads prohibit a naive in-place overwrite.
- If long weather distances stretch the log grid enough to damage nearby shafts, prototype a near grid plus correctly integrated far atmosphere. Do not shorten weather range or substitute a flat far sample.
- Preserve per-pixel fog as an advanced alternative/reference. Its opaque cache already avoids repeating much full-screen work; transparent receivers still need integration to their own depth.

The grid/reprojection direction is consistent with [Wronski's production volumetric-fog presentation](https://advances.realtimerendering.com/s2014/wronski/bwronski_volumetric_fog_siggraph2014.pdf). The existing [FAST validation](volumetrics/sampling.md) remains the regression baseline, including dim HDR lamps and motion rejection. Increasing history weight until bands disappear is not an acceptable substitute for correct sampling.

**Shadow work:** PCSS currently uses a center depth plus 16 four-depth gathers for blocker search, then 16 or 24 comparison-filtered samples; cascade blending can repeat it. Prototype coherent lit/occluded classification and adaptive filtering, retaining a robust thin-foliage blocker test. A few clear test taps do not prove absence of a narrow occluder. Preserve material-specific bias and cascade behavior. [NVIDIA's PCSS reference](https://developer.download.nvidia.com/whitepapers/2008/PCSS_Integration.pdf) separates blocker search, penumbra estimation and filtering, which should also be profiled separately here.

For contact shadows, reject empty/invalid receiver tiles before ray tracing and share nearby depth loads when profitable. Evaluate half-resolution tracing only with full-resolution thin-edge refinement and reliable reconstruction. Keep the existing full-resolution path if the alternative loses grass, feet, weapons or small creases. Do not add a knowingly noisy Low mode.

**Acceptance:** preserve authored opacity/interior exclusion, moving lamp and occluder behavior, colored dim-light energy and shadow detail; reduce total time in the relevant scenes. Higher fog grids must demonstrate a motion-quality benefit sufficient to justify their memory.

### Phase 5 — targeted water, optics and temporal improvements

**Underwater:** reuse water tile/height/bottom classification within a frame where possible; the inputs can traverse up to 44 tiles. Bound sun integration to contributing segments while preserving the existing analytic RGB weights and surface-entry shadow behavior. Reuse caustic preparation across receivers; inactive indirect-dispatch rejection already exists, so measure further opportunities rather than claiming that optimization anew. Above-water views can still see underwater caustics. Do not gate all preparation solely on camera submersion.

**Optional Surface Waves:** profile coordinate derivatives and repeated normal construction. Prototype a filtered world-space derivative field only if its update, sampling and memory cost beats direct evaluation and it preserves animation, crest shape and water boundaries. Original remains the default regardless of this experiment.

**DOF and motion blur:** add tile bounds for circle of confusion or velocity, bypassing in-focus/static regions and allocating samples by actual filter radius. [AMD's DOF documentation](https://gpuopen.com/manuals/fidelityfx_sdk/techniques/depth-of-field/) describes half-resolution processing, CoC bounds and mip-based large-radius filtering. Placement relative to upscaling is integration-specific: test depth availability, disocclusions and foreground edges before moving passes. Current output-resolution effects do not automatically become cheaper when DLSS lowers the internal resolution.

**Custom CA:** profile cubic scene sampling and minification branches. Investigate equivalent filtered gathers and shared work; do not switch to a visibly softer bilinear path just to reduce tap count. Keep correct underwater distortion/HUD mapping.

**Motion vectors and DLSS:** profile MRT output bandwidth, native depth copies, per-draw state handling and constant snapshots separately. Build on existing once-per-frame caches and original-draw vector integration; do not reintroduce geometry replay. Retain vegetation and skinned-object motion. Test grass, hair, particles and disocclusion at 1080p/1440p/4K before changing DLSS recommendations; Quality is a starting point, not a universal proof of equivalence to native rendering.

**FG bridge:** measure the remaining bridge copy/fence work even when generation is Off. Consider a lazy initialization or bypass only if meaningful, with swapchain/HDR/live-toggle tests. This is higher-risk integration work, not the first optimization. Frame generation stays excluded from base rendering performance claims.

**Small features:** keep rain, PBR, AO application, night controls, grading, vignette and video processing at one good quality. Optimize measured redundant passes, neutral branches or resource copies. Do not strip color management, turn off correct AO behavior, or add new settings for tiny arithmetic savings.

## 5. Proposed quality menu after the implementation gates

| Feature | Normal default | Meaningful optional upgrade | Advanced/compatibility only |
| --- | --- | --- | --- |
| Clouds | Balanced: optimized Medium-class transport, quarter-axis tracing, good temporal reconstruction | High: more accurate integration/detail allocation; remain quarter-axis if it passes, use half only if the improvement justifies measured cost | Native; manual resolution/step controls; existing expensive reference tiers |
| Fog | Balanced: detail-1 grid, FAST, smoothing, shadow quality 1 | High: detail-2 grid and, where useful, shadow quality 2 | Per-pixel method, detail 3–4, independent sampling controls |
| Water reflections | Balanced: new half-axis trace with stabilization and edge refinement | High: full-axis trace with the same stability features | Native; diagnostic history controls |
| Underwater sunlight | Current detail 1 | Detail 2 if moving shafts visibly improve | Detail 3–4 for reference/capture |
| Soft/contact/cloud-ground shadows | One validated custom quality, On | No extra tier initially | Native/Off compatibility and physical appearance controls |
| Water ripples | Original, strength 0.3 | Surface Waves as an optional style | Existing artistic controls |
| Bloom / rain / surface lighting / HDR | One efficient, good-quality implementation | None | Native/Off where already supported |
| Motion blur / DOF | Proposed blur Off; DOF Native | Object Only blur; Custom DOF for chosen lens behavior | Existing advanced lens controls |
| DLSS / FG | DLSS Quality where supported and validated; FG Off | Existing DLSS choices and opt-in FG | Existing diagnostics |

Do not add another six-level global preset ladder. Offer a recommended reset and independent upgrades for the few expensive features. If Balanced clouds or half-resolution SSR fail quality acceptance, retain the current good-quality default until the implementation improves; do not ship the label ahead of the result.

Consolidate preset, runtime initialization, tooltip and documentation defaults. Version any menu remapping so existing quality choices retain their intended behavior. Never rebase cloud appearance again as a side effect of a performance preset. Keep valid minimum/maximum ranges on both sides of each rebased baseline.

## 6. Validation, shipping gates and deliverables

Every implementation batch must include:

1. A narrow code change and before/after pass/work/memory accounting. Build `renodx-thewitcher3classic` with the established Clang Release script; inspect generated shaders and record the addon hash. Follow the game's closed-before-build workflow when replacing its loaded addon.
2. Relevant existing standalone tests, extended only for changed numerical or lifetime invariants. Clouds need sun-occultation, lighting/reconstruction/motion and composition checks; fog needs transport, local-light and temporal checks; water needs reflection trace/history and caustic/underwater checks; optics needs impulse/radius and edge coverage checks.
3. Matched hardware captures for the scene matrix. Report isolated GPU timings and complete-preset real-frame times. Improvements must exceed observed measurement variability and must not cause p95 regressions in other common scenes without an explicitly documented tradeoff.
4. SDR and HDR review at controlled exposure, including bright sun, dim interiors, colored lamps and changing exposure. Inspect thin geometry, screen edges, waterlines, cutscenes, pause/resume, resolution changes, DLSS changes and feature toggles. Review moving video as well as still images.
5. Resource checks: bounded VRAM, no allocations every frame, valid context restoration, no stale pooled texture regions, no history reuse after incompatible changes, and no unexpected CPU waits. Use the D3D debug layer when available; do not claim it ran if unavailable.

Quantitative objectives are **targets to test**, not promised speedups: reduce normal bloom from 62 draws toward 10–14; substantially reduce cloud secondary density queries including cache overhead; reduce SSR ray starts and allocation with half-resolution reconstruction; eliminate repeated fog light-list traversal. Retain a change only when end-to-end measurements and visual comparisons support it.

Expected execution deliverables, in order:

1. Current-default timing/memory ledger and reproducible captures.
2. Efficient bloom plus verified inactive-work removal.
3. Independently benchmarked cloud acceleration and water-reflection prototypes; promote successful ones separately.
4. Fog/local-light and shadow improvements justified by the ledger.
5. Optional-effect and temporal/bridge improvements where remaining cost warrants them.
6. Final recommended defaults, restrained quality menu, safe profile migration, updated documentation and a complete-preset acceptance report.

Avoid blanket noise injection, global sample cuts, indiscriminate history smoothing, low-precision format swaps, disabling vegetation motion, or using generated FPS to conceal slow real frames. Those approaches can produce a lower timing number while undoing the quality this mod was built to add.

## 7. Execution record — 2026-11-02

This is an intermediate implementation record, not complete-plan acceptance.

### Implemented

- Wide bloom uses overlapping 13-tap pyramid reductions and tent reconstruction, with weights fitted to the previous Gaussian kernels' second moments. Default size now uses 14 draws instead of 62. Weights are cached until size changes; unused old scratch targets are not allocated. Narrow kernels retain the original path.
- Custom DOF skips foreground preparation/filtering and their allocations when foreground strength is zero; composition avoids reading that absent input.
- Grid fog traverses the local-light list once for its same four antithetic samples, with conservative segment/sphere rejection and zero-radiance rejection. Grid mode avoids snapshots used only by per-pixel fog. FAST, shadowing and authored extinction are preserved.
- Water SSR adds half-axis tracing with the preserved full-depth origin. Guide buffers exchange roles instead of copying into a third guide, saving one RG32F image (63.3 MiB at a 4K trace extent) and its per-frame copy. Old saved full-resolution On maps to quality 2, Off to 0; existing new selections are retained. Full remains the default pending half-mode acceptance.
- Fresh/reset motion blur is Off; saved choices remain. Fog and water runtime initialization now uses the existing authoritative preset values. Cloud appearance baselines and ground shadows are unchanged.
- About → Capture GPU Performance adds an opt-in asynchronous eight-frame timestamp ring: 120 warmup frames and 300 requested measured frames. CSV records frame, range, extent, GPU and CPU submission milliseconds; the log reports percentiles, dropped/disjoint frames and CSV location. Production capture never flushes or waits. Disabled capture allocates no queries. Nested inclusive ranges must not be summed.

### Measured isolated costs

RTX 5090, D3D11, game closed. These are standalone pass measurements, not gameplay FPS claims. Optics/SSR numbers are medians of nine batches of 16 frames. The scratch CSV column called `p95_ms` contains the worst of those nine batch averages, **not a per-frame p95**.

| Fixture | Before ms | After ms |
| --- | ---: | ---: |
| Bloom, 2560x1440 | 0.1966 | 0.0767 |
| Bloom, 3840x2160 | 0.4263 | 0.1978 |
| Custom DOF, foreground zero, 1440p | 0.1916 | 0.0580 |
| Same DOF, 4K | 0.3920 | 0.1542 |
| Unchanged object blur, 4K | 0.3748 | 0.3740 |
| Fog detail 1, four local lights | 0.1082 | 0.0962 |
| Fog detail 1, 24 local lights | 0.3053 | 0.2597 |
| Fog detail 4, 24 local lights | 4.2034 | 3.6801 |
| Full SSR, 2560x1440 active render | 0.7584 | 0.8912 |
| Half SSR, same active render | — | 0.4223 |
| Full SSR, 3840x2160 active render | 2.5456 | 2.5310 |
| Half SSR, same active render | — | 1.3455 |

Three repeated matched pairs put full SSR at 0.754–0.755 ms before versus 0.793–0.795 ms after at 1440p (about 0.04 ms slower), and 2.485–2.489 ms before versus 2.441–2.589 ms after at 4K. This is a memory-saving tradeoff, not a demonstrated full-mode GPU-time win. Half mode measured about 0.422 ms / 1.233–1.235 ms at those extents, but has not passed the shoreline/motion quality gate.

Optics uses RGBA32F inputs/RGBA16F intermediates; bloom size 2, extraction 3 and strength 1. DOF uses 50 mm, 10 m focus and foreground strength zero. These are fixture conditions, not all actual UI defaults. SSR uses synthetic depth/water masks and captured frame constants, not a shoreline-quality reference. Fog uses the existing production-volume fixture. Never add unrelated fixture times into a total frame time.

The 1024-square bloom impulse retained energy within 0.6% (7024.05 → 7064.69) and RMS radius within 0.2% (125.230 → 125.037 pixels). Inner 16-pixel energy fraction changed from 0.1801 to 0.1937. Moving-highlight gameplay acceptance remains open.

### Rejected cloud experiments

A 128x128x64 sky/sun optical-depth cache reduced high-tier time but altered internal sunlight too much. At Medium, relative RGB RMS error against the same dense reference was 0.0688 for direct integration, 0.4067 at 256 m cache spacing and 1.0834 at 64 m spacing. Extinction was unchanged, which does not make the lighting acceptable. A sky-only cache did not establish a worthwhile Medium gain. Conservative macro-envelope rejection also failed its performance comparison at the approved dense baseline.

These prototypes were removed from the shipping path; sources/dumps remain in the scratch evidence folder. No cloud sample cuts or new cloud-quality default were promoted.

### Bright-gap noise follow-up

The user reported moving noise especially where bright sky shows through cloud gaps, and confirmed it remains with FG Off. The old temporal resolve compared raw stochastic transmission against history with a fixed rejection threshold; the DLSS motion/responsiveness input also used raw opacity and that same noisy difference. The existing reconstruction test covered noisy RGB with constant transmission and missed this case.

The follow-up computes transmission variance in the existing 3x3 neighborhood, allows sampling variation when evaluating history, and exports resolved opacity plus consistent variance-aware confidence to the upscaler. It preserves RGB detail response, min/max clipping, depth/weather/clock/camera rejection, primary extinction, sample counts and ground shadows. No new textures or ray samples are added.

Research and exact adaptation are documented in [cloud sampling](clouds/sampling.md), including Salvi/NVIDIA's temporal-validation work and EA FAST. The change does not claim to eliminate every source of cloud noise; primary integration and disocclusions can still expose sampling error.

A final isolated cost pair at 4K/75% sky, weather input 1, measured Medium at 1.1618 → 1.2581 ms and High at 2.3623 → 2.1027 ms. The opposite directions indicate that this pair alone cannot establish the small resolve change's performance cost; it is not evidence of a cloud speedup. Sample counts and allocations are unchanged. Resolve-only repeated timings and gameplay captures remain required.

WARP reconstruction fixture: transmission RMS relative to raw input fell from 0.967915 to 0.085535 (about 91% lower than the old output); mean transmission bias is -0.0000401. Moving-gap transmission RMS is 0.006081. Newly clear/opaque regions replace stale history immediately. Existing subpixel RGB RMS remains 0.076133, and dim/bright HDR gradient tests retain their energy/hue bounds. These isolate the filtering defect; actual-scene noise removal still needs live confirmation.

A separate 96-frame production-cloud fixture uses the approved appearance baselines, fixed camera/weather, a 1000-unit background, and 32 warmup frames. On RTX 5090, bright-gap temporal RMS fell from 9.67279 to 7.34916 at Medium (24%) and 14.4972 to 10.7612 at High (26%). Mean gap brightness changed by less than 0.15%. WARP measured 20% / 35% reduction. Gap masks are selected from each run's time-averaged 1–99% transmission region; the mask sizes differ by at most two pixels. These production-fixture numbers are more representative than the isolated transmission result, but do not include DLSS. The upscaler-confidence correction needs gameplay review.

### Verification and remaining gates

Initial batch built with `build-release.ps1`, target `thewitcher3classic`, SHA256 `320EE9FE6C223A780C5CB6E55F52DDEE92581FCC92BE9E0CC07B642779766172`. Game-folder symlink points to this Release addon. Startup and actual saved-profile SSR migration (1→2, 0→0, 0→0) were observed. This is a load/migration smoke test, not a controlled gameplay performance capture. The bright-gap follow-up also built successfully; its Release addon SHA256 is `292E3D1E98C04CB32F71CCF4241BB264DAC2DDC4807B9C8EB44A6E523D75833D`. The rebuilt cloud and reconstruction tests passed on hardware and WARP. The ground-shadow bytecode hash remains unchanged.

Hardware and WARP tests passed for initial-batch clouds, fog, optics, water reflection tracing/history and bounded profiling. Complete Graphics/Night presets plus cloud/SSR-specific checks passed. Stale ripple test expectations were corrected to the already-existing Original/0.3 preset. HDR cloud regression includes occultation of a 50000-unit background, clear gaps and wind-aware motion. D3D debug-layer validation was unavailable.

Evidence: `tmp/witcher3classic-investigation/optimization-20261102/`, including pre-edit source/addon/embedded-shader snapshots and hash manifest, benchmark scripts/CSVs, impulse dumps, cloud reference/prototype dumps, and `*-final-{gpu,warp}.log`. Keep the game closed for GPU benchmarks. The user is currently testing the game; automated input and competing GPU benchmarks were stopped when they confirmed that.

Remaining work:

1. Validate the built bright-gap follow-up in the reported gameplay scene, including motion and DLSS. Standalone sun-occultation and reconstruction tests passed.
2. Review half-mode shoreline detail, moving reflected objects and disocclusions, and confirm full SSR behavior in gameplay. Edge refinement, tile classification and hierarchical traversal remain unimplemented. The optional Balanced label is provisional; full remains the default.
3. Collect fixed-scene real-frame timings with FG Off: PresentMon for whole-frame GPU/CPU and the new capture for pass attribution. Record output/render extents, weather, exposure, DLSS model, driver and saved settings.
4. Profile PCSS/contact shadows, underwater, optional waves, Custom CA, object motion and the FG bridge before changing them. Receiver rejection, velocity tile bounds and inactive caustics dispatch already exist; do not count them as new optimizations.
5. Complete SDR/HDR moving-scene, resource-lifetime and whole-preset acceptance before promoting cloud/reflection defaults or declaring the plan complete. No result yet establishes midrange-GPU performance.


### Cloud cache re-evaluation after density baseline v6 (2026-11-02)

The user allowed acceleration at any tier only if it does not introduce noise or artifacts. Re-testing does **not** justify enabling the earlier cache at higher tiers. The prior high-tier assessment was provisional; error relative to the old noisy integration alone is insufficient evidence of correct lighting. No cloud rendering changes from this investigation were promoted, and no new addon was built.

The current physical appearance baseline is density 0.18, thickness 1.3, detail 4, detail size 0.8 and base softness 0. The original dual sun/sky prefix cache remains rejected. The new experiments cached only skylight; primary extinction, direct sunlight and ground cloud shadows were preserved. This follows the general production pattern of amortizing volumetric lighting in spatial fields ([Guerrilla, Nubis Evolved](https://www.guerrilla-games.com/read/nubis-evolved)), but the local sky-transport cache is our adaptation, not a claim to reproduce Guerrilla's implementation.

A revised cache independently integrates 24 midpoint density samples at every grid point, then stores the diffuse sky transport rather than interpolating accumulated optical depth. A 128x128x64 R32F grid at 64 m horizontal spacing substantially reduced the earlier lighting error. At 960x540, six weather/sun cases and all six quality levels, 32-frame means differed from a 64-sky-sample reference by less than 1% relative RGB RMS for sky-only lighting and less than 0.3% with sunlight. The reference keeps the same primary/sun samples and sky-density footprint; it is a denser sky integral, not ground truth for full cloud transport. These means do not establish artifact-free motion.

A mixed cached/direct shader was slower in repeated tests. Splitting the two ray paths into separate dispatches, classifying whole rays and blending across the grid boundary, recovered some performance. The final split prototype uses a 256x256x64 R32F field (16 MiB), rebuilt every frame with no stale temporal cache. On RTX 5090 at 2560x1440, weather input 0.7 and the baseline appearance:

| Tier | Direct cloud pipeline | Split cache pipeline | Decision |
| --- | --- | --- | --- |
| Ultra | 6.10 / 6.05 ms | 6.37 / 6.43 ms | Slower; reject |
| Maximum | 45.93 / 45.41 ms | 43.27 / 42.92 ms | About 5.5-5.8% faster, but fails broader quality gate |

Each entry is a separate run's median of five eight-frame timestamp batches, after 16 warmup frames. Timings include cache rebuild, cloud tracing, reconstruction and composition. The synthetic upward camera has native depth entirely clear; this is not whole-game performance or an FPS claim. Do not compare absolute timings across the other experiment batches: jitter phase, warmup history, GPU clocks and shader strategy differ. No midrange GPU was tested.

The split cache's additional 640x360 stress suite used Medium, Ultra and Maximum, 24 matching sample phases, individual density/detail/detail-size/thickness/formation-size extremes, slow motion across a 64 m grid snap, and faster camera/wind motion. At Maximum, sky-only relative RGB RMS against the dense reference was 0.88% at baseline versus 0.38% for direct integration. At physical density 4, it rose to 16.84% versus 13.87% direct, with a -2.24% mean change relative to direct and visible changes in internal cloud lighting. Physical formation size 0.25 produced 2.18% error versus 0.35% direct. Temporal variation decreased in the motion fixtures, but that does not excuse the spatial lighting changes. The 24-frame means and selected image inspections are not a full gameplay/DLSS/HDR acceptance test. Consequently, even Maximum is not enabled automatically, and no extra user toggle was added for this rejected prototype.

Compile-time specialization was also tested for Ultra/Cinematic/Maximum while keeping the same sample counts and math, following [Microsoft's HLSL optimization guidance](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-optimize) and [Unity's shader-variant guidance](https://unity.com/blog/engine-platform/shader-variants-optimization-troubleshooting-tips). Fewer shader instructions/register temporaries did not yield a consistent GPU gain in paired measurements; no variants were added to the addon. A narrower overhead-shell intersection substitution likewise did not establish a useful repeatable gain.

Evidence: `tmp/witcher3classic-investigation/cache-retest-20261102/`. `wide-metrics.json` records the first transport-field comparison; `split256.csv` contains the paired timing results above; `stress-metrics.json`, `stress-*.csv`, frame dumps and `comparison-*.png` cover the split-field stress suite. `specialized.csv` and `analytic.csv` record the rejected exact-math alternatives. `unchanged-runtime-sha256.json` verifies the cloud subtree against the pre-experiment snapshot. Keep cached-lighting acceleration unpromoted until both the dense-reference/appearance/motion gates and complete-pipeline timing gate pass; a higher quality label alone is not an acceptance criterion.
