# LORWIN DLAA Handoff

## Current Context

Game: The Lord of the Rings: War in the North - Legacy Edition  
RenoDX shortname: `lorwin`  
Renderer: D3D12

The addon can run NVIDIA DLAA immediately before the game's final postprocess draw in both HDR and SDR. It supplies real camera jitter, camera-derived motion vectors, native depth, and an optional synthetic history-confidence mask. DLAA remains off by default.

Per-object motion-vector capture and replay were removed on 2026-08-17. The replay path never became reliable enough for production and could destabilize the whole frame. The supported path is intentionally camera-only, with depth-neighborhood conditioning at silhouettes and disocclusions.

## HDR / SDR Routing

- With Windows HDR enabled, the established HDR10 swapchain proxy and RenoDX tone-mapping path remain active.
- With Windows HDR disabled, the game keeps its native SDR backbuffer and color space. HDR resource cloning is disabled and the replacement postprocess shaders force the vanilla tone-map, grade, gamma, and noise branches.
- DLAA and DLAA debugging remain available in both modes. HDR-only controls are hidden in SDR.
- A Windows HDR change takes effect after the swapchain is recreated or the game is restarted.

The selected route is logged as `LORWIN output: Windows HDR is enabled ...` or `LORWIN output: Windows HDR is disabled ...`.

## Verified Postprocess Inputs

All four wrapped postprocess variants use the same relevant `$Globals` b0 layout:

- `t0`: full-resolution RGBA8 scene color.
- `t3`: full-resolution `r24_unorm_x8_uint` depth view.
- `g_DOFBlurVals.w` at c2.w.
- `g_MotionBlurXform` at c6-c9.

The known postprocess shaders are:

- `0xCFC0C7CF`
- `0x17BBC7EE`
- `0x9805B9F6`
- `0x0C0E1BA4`

## Camera Motion-Vector Prepass

`dlaa.hpp` runs `shaders/motion_vectors.cs_6_0.hlsl` once per presented frame before the active postprocess draw:

1. Read the native depth SRV and pixel b0 constant buffer.
2. Reconstruct current-minus-previous UV motion from the game's motion-blur transform.
3. Remove the current viewport jitter from the raster coordinate before applying the game's unjittered reprojection transform. The resulting vectors therefore exclude jitter.
4. Optionally apply the AC3 Remastered-style 3x3 depth-neighborhood rule: use the far-surface vector at ordinary silhouettes and the current jitter-quadrant far sample at disocclusion edges.
5. Store the result in a private full-resolution `R16G16_FLOAT` texture and restore the previous compute state.

NGX receives that UV texture with the recommended default `MVScale=(-renderWidth, -renderHeight)`. The negative scale converts the stored current-minus-previous displacement to the convention expected by DLSS. `MVJittered` is fixed off.

This path cannot describe independent object, skeletal, particle, or animated-texture motion. Those pixels receive camera motion. The synthetic mask below is the remaining low-confidence hint for such regions.

## Camera Jitter

`jitter.hpp` applies pixel jitter through the viewport origin on full-resolution scene draws. Under the D3D viewport transform, a pixel offset `J` is equivalent to:

```text
projection.x =  2 * J.x / renderWidth
projection.y = -2 * J.y / renderHeight
```

The postprocess depth resource is traced back through copy/resolve lineage to the source DSV. Exact-depth matching is the primary eligibility rule. A conservative scene-color fallback also admits full-resolution draws that write the traced scene-color RTV and have a full-resolution depth attachment. Depthless HUD, postprocessing, ReShade overlays, and unrelated render targets remain unjittered.

Automatic DLAA jitter uses an eight-phase Halton sequence in the safe `[-0.5, +0.5]` pixel range. NGX receives the current pixel-space sample separately. If no eligible scene draw was jittered during a frame, NGX receives zero and history resets at the active/inactive transition.

The camera-vector shader explicitly subtracts this raster jitter, so the fixed NGX feature configuration is:

- Standard depth.
- LDR color input.
- Motion vectors do not include jitter.
- Auto exposure enabled because there is no exposure texture.

## DLAA Evaluation and Output Binding

For each wrapped postprocess draw with DLAA enabled, the runtime:

1. Copies native scene color to a typed full-resolution `R8G8B8A8_UNORM` input.
2. Evaluates NGX SuperSampling at a 1:1 ratio with `NVSDK_NGX_PerfQuality_Value_DLAA`.
3. Supplies typed color, native depth, camera motion vectors, current jitter, and the optional bias mask.
4. Makes the private NGX output available to the replacement postprocess shader at private `t1, space50`.
5. Leaves the game's native descriptor tables unchanged.

Motion vectors use private `t0, space50`; the mask debug view uses private `t2, space50`. Do not add separate injected t3/t4 space-50 SRVs: the ReShade D3D12 pipeline-layout utility creates overlapping SRV ranges and root-signature creation fails at startup.

NGX initialization, creation, or evaluation failures fail closed by disabling DLAA. Adapter detection is restricted to the main D3D12 device so auxiliary EOS/D3D11 devices cannot clear NVIDIA availability.

Available presets are K, J, F, L, and M. M is the current default; L and M use Transformer 2.

## Synthetic History-Rejection Mask

`shaders/bias_current_color_mask.cs_6_0.hlsl` generates a full-resolution `R8_UNORM` `BiasCurrentColorMask` before NGX evaluation. It compares current pre-DLAA color against reprojected previous pre-DLAA color and takes the maximum of:

- Relative RGB change over a five-pixel cross.
- A 3x3 relative depth-range response.
- Local motion-vector disagreement.
- Full rejection for history coordinates outside the frame.

The fixed thresholds are 4% relative color change and 0.1% relative depth range. `History-Rejection Strength` scales only this adaptive response. The abandoned global minimum-bias diagnostic was removed: runtime testing showed that even an all-white mask did not make preset K behave like `InReset=1`.

The mask is still useful as a confidence hint, but it must not be described as guaranteed local history invalidation. A reset, source change, discontinuity, or first use initializes the separate color history and writes full rejection for that evaluation.

## DLAA Debugging UI

The `DLAA Debugging` section always shows only the off-by-default `Debug` toggle until enabled. The expanded controls are grouped in this order:

### Visualization

- `Resource View`: NGX input/output, split and difference views, camera-vector direction/magnitude, native depth, depth discontinuities, history mask, invalid-value checks, and a four-view overview.

### History & Reconstruction

- `Depth-Neighborhood MV Dilation`: raw camera vectors versus the recommended conditioned camera vectors.
- `Synthetic History-Rejection Mask` and `History-Rejection Strength`.
- `Reset NGX History Every Frame`: diagnostic only. If this removes K/J ghosting, current-frame reconstruction is sound and temporal history/reprojection is responsible.

### Motion-Vector Input

- `Motion Vector Direction`: invert both axes is the validated default.
- `Motion Vector Scale`: 100% is the validated default.

### Jitter Input

- `Camera Jitter Override`: Automatic, forced Halton 8, Four Quadrants, or forced off.
- `Camera Projection Jitter Scale`: 100% is valid; larger values are a deliberate visibility test. Camera overdrive suppresses NGX jitter and resets history.
- `NGX Jitter Direction`: original axes are the validated default.
- `NGX Jitter Scale`: 100% is valid. Values above roughly 114% exceed the supported range for the largest Halton sample and are diagnostic only.

### Tools

- `Restore Recommended DLAA Inputs`.
- `Reset DLAA History`.

Known fixed creation flags are no longer exposed as UI toggles. Passive resource logging also no longer appears in the user-facing debug panel.

## Interpreting Resource Views

- Clean input but corrupt output localizes a fault to NGX inputs, conventions, or history.
- Stationary camera motion should be close to middle gray in Direction and black in Magnitude.
- Camera movement should produce coherent signed motion across scene geometry.
- The history mask should be dark on stable surfaces and brighten around temporal color changes, depth edges, and motion disagreement.
- White on a reset/first frame is expected.
- The `Invalid` views are mainly binding/format sanity checks because UNORM storage normally clamps invalid values.

## Relevant Files

- `addon.cpp`: settings, HDR/SDR routing, and runtime registration.
- `dlaa.hpp`: camera-vector prepass, NGX lifecycle/evaluation, color history, mask dispatch, and debug/output bindings.
- `jitter.hpp`: sequence generation, draw filtering, copy lineage, viewport jitter/restoration, and diagnostics.
- `resource_logger.hpp`: descriptor tracking, frame index, and optional runtime evidence collection.
- `shaders/motion_vectors.cs_6_0.hlsl`: camera-vector reconstruction and depth-neighborhood conditioning.
- `shaders/bias_current_color_mask.cs_6_0.hlsl`: adaptive history-confidence mask.
- `common.hlsli`: private DLAA textures and debug visualization.
- `shared.h`: shader injection values and SDR vanilla-tone-map gate.

There is intentionally no per-object motion runtime or object-motion shader family.

## Build and Runtime Verification

Build with:

```powershell
cmake --build --preset vs-x64-release --target LORWIN
```

Do not build while `witn.exe` is running. The game addon is normally a symbolic link to `build.vs/Release/renodx-lorwin.addon64`.

The cleanup build completed successfully on 2026-08-17. The repository artifact and deployed symbolic link both have SHA-256 `10FFF208FF01048FB5E64B40F6C1AAE6A3F98D81724E48FC884CF55CD4018A84`.

Expected DLAA log entries include:

- `LORWIN DLAA: created the AC3R-style depth-neighborhood motion-vector compute pipeline.`
- `LORWIN DLAA: created motion-vector texture <width>x<height> format=R16G16_FLOAT ...`
- `LORWIN DLAA: NGX initialized, SuperSampling_Available=1`
- `LORWIN DLAA: created typed staging/output, color-history, and R8 bias-mask textures ...`
- `LORWIN DLAA: created synthetic BiasCurrentColorMask compute pipeline.`
- `LORWIN DLAA: feature created at <width>x<height> flags=AutoExposure preset=...`
- `LORWIN DLAA: evaluation active at <width>x<height> jitter_raw=(...) jitter_ngx=(...) mv_scale=(...) ...`

No `LORWIN DLAA object motion` messages should exist.

Manual checks:

1. Verify SDR uses vanilla tone mapping while DLAA remains usable.
2. Verify HDR restores RenoDX tone-mapping controls and DLAA still works.
3. Compare camera-vector Direction/Magnitude with dilation off/on.
4. Confirm HUD, menus, postprocessing, and ReShade overlays do not jitter.
5. Compare NGX input/output and history-reset behavior across presets.
6. Leave camera and NGX jitter scales at 100% for normal use.

Do not move DLAA after postprocessing, feed it final UI/backbuffer content, or write its result into a resource still consumed by the same evaluation.
