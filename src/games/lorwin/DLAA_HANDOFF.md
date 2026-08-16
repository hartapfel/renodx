# LORWIN DLAA Handoff

## Current Context

Game: The Lord of the Rings: War in the North - Legacy Edition  
RenoDX shortname: `lorwin`  
Renderer: D3D12

The normal HDR path remains intact. The implementation now includes the prerequisite motion-vector prepass, real camera jitter through the raster viewport transform, a synthetic current-color bias mask, and an NVIDIA NGX DLAA evaluation immediately before the game's final postprocess draw. DLAA is off by default pending runtime validation.

## Runtime Evidence

The latest `logs/ReShade.log` capture identifies `0xCFC0C7CF` as the active postprocess variant. An earlier capture used `0x17BBC7EE`; both are among the four handled variants. It also confirms stable Halton 8 and Four Quadrant viewport jitter, 181 jitter binds over the 60-frame diagnostic window, 60 viewport restores, and clean addon/device shutdown. The stable full-resolution resources at 3840x2160 are:

- `t0`: scene color, `r8g8b8a8_typeless` resource with `r8g8b8a8_unorm` SRV.
- `t3`: depth, `r24_g8_typeless` resource with `r24_unorm_x8_uint` SRV.
- `rtv0`: postprocess output, `r10g10b10a2_unorm`.
- Pixel SRVs are in graphics layout parameter 2; the range begins at binding 0.
- The viewport and scissor are full resolution.

All four postprocess variants share the same `$Globals` b0 layout. The game already reconstructs camera velocity in the motion-blur variants from:

- `g_DOFBlurVals.w` at c2.w.
- `g_MotionBlurXform` at c6-c9.
- The depth texture at t3.

## Implemented Motion-Vector Prepass

`dlaa.hpp` intercepts each known postprocess draw before it executes. Once per presented frame it:

1. Resolves the native pixel b0 constant buffer and depth t3 SRV from the active draw.
2. Creates a full-resolution `R16G16_FLOAT` SRV/UAV motion-vector texture.
3. Dispatches `shaders/motion_vectors.cs_6_0.hlsl` before the postprocess draw.
4. Reuses the game's motion-blur reprojection math and writes current-minus-previous UV displacement.
5. By default, conditions those vectors with the AC3 Remastered depth-neighborhood rule: find the near/far surfaces in a 3x3 neighborhood, compare their vectors in pixel space, dilate the far-surface vector for ordinary silhouettes, and select the far vector from the current jitter quadrant where near/far disagreement exceeds two pixels.
6. Transitions the texture from SRV to UAV and back to SRV.
7. Restores the compute pipeline and descriptor-table state that was active before the prepass.

The generated texture is injected into replacement postprocess shaders as `t0, space50`. Generation is independent of the debug mode so the texture remains ready for the later DLAA evaluation pass. `Depth-Neighborhood MV Dilation` defaults on and can be disabled live to compare the original per-pixel camera vectors. The far-depth comparison follows the selected standard/inverted depth convention, and changing the dilation mode resets DLAA history.

The prepass itself does not alter native scene t0 or the final output. Its texture is consumed by the DLAA evaluation described below.

## Implemented DLAA Evaluation

Each wrapped postprocess variant now performs these steps immediately before its native draw when `DLAA` is enabled:

1. Resolves the verified scene t0 and depth t3 descriptors from the active graphics layout.
2. Copies the typeless RGBA8 scene resource into a dedicated typed `R8G8B8A8_UNORM` full-resolution NGX input texture.
3. Evaluates an NVIDIA NGX SuperSampling feature at a 1:1 input/output ratio using `NVSDK_NGX_PerfQuality_Value_DLAA`.
4. Supplies the typed color input, native depth, generated `R16G16_FLOAT` UV motion vectors, current pixel-space jitter, and optional synthetic `R8_UNORM` `BiasCurrentColorMask`.
5. Uses configurable NGX input conventions. The recommended default is `MVScale=(-renderWidth, -renderHeight)` because the generated texture stores current-minus-previous UV displacement while DLSS expects the opposite direction. `MVJittered` remains unset, auto exposure remains enabled, and history resets after gaps, source changes, feature recreation, live input-tuning changes, or first use.
6. Binds the separate typed NGX output SRV only over the native scene t0 slot for that postprocess draw.
7. Restores the original scene descriptor immediately after the draw, allowing bloom, noise, distortion, gamma, RenoDX tone mapping, and later passes to remain native.

The runtime tracks resource states from D3D12 resource initialization and barrier events. It restores the captured graphics/compute pipeline and descriptor-table state after NGX calls. NGX initialization, feature creation, and evaluation failures are fail-closed: the `DLAA` toggle is switched off so automatic jitter stops on following frames.

Adapter detection is scoped to the main D3D12 device. Auxiliary D3D11 devices created by EOS/the game are deliberately ignored so they cannot clear NVIDIA availability after the RTX adapter is detected. Detection uses ReShade's vendor property first and the native D3D12 adapter LUID through DXGI as a fallback. The runtime logs `LORWIN DLAA: D3D12 adapter vendor=0x10de NVIDIA=yes` when successful.

The DLAA UI contains:

- `DLAA`: enables the NGX path on NVIDIA D3D12 adapters.
- `DLAA Render Preset`: defaults to Transformer 1 preset K, with Transformer 1 preset J, legacy CNN preset F, and Transformer 2 presets L and M available for comparison. L and M were appended to preserve the saved numeric values of the existing K/J/F choices.

The `DLAA Investigation` panel exposes the relevant NGX inputs live:

- `Motion Vector Direction`: original, invert X, invert Y, or invert both. Invert both is the recommended default.
- `Motion Vector Scale`: 1-200%, default 100%.
- `Depth-Neighborhood MV Dilation`: AC3R-style 3x3 silhouette/disocclusion conditioning; on is the recommended default.
- `Synthetic History-Rejection Mask`: enables the generated NGX current-color bias input; on is the recommended default.
- `History-Rejection Strength`: scales that mask from 0-200%, default 100%.
- `NGX Jitter Direction`: original or per-axis inversion; original is the recommended default.
- `NGX Jitter Scale`: 0-200%, default 100%.
- `Depth Convention`: standard or `DepthInverted`; standard is expected for this depth buffer.
- `Motion Vectors Include Jitter`: controls `MVJittered`; off is expected because the prepass uses the game's unjittered transform.
- `NGX Color Input`: controls `IsHDR`; LDR is expected for the typed RGBA8 input.
- `NGX Auto Exposure`: on is expected because no separate exposure texture is available.
- `Restore Recommended DLAA Inputs` and `Reset DLAA History` buttons.

Changing a feature flag recreates the NGX feature. Changing MV, jitter, or history-rejection tuning applies on the next evaluation and resets temporal history. The log records the feature flags, effective signed MV/jitter scales, and bias-mask state.

## Synthetic BiasCurrentColorMask

`shaders/bias_current_color_mask.cs_6_0.hlsl` generates a full-resolution normalized mask immediately before each NGX evaluation. NVIDIA defines this input as a per-pixel bias between temporal history and current color: zero leaves normal history weighting in place and one completely rejects history.

The prepass keeps a dedicated copy of the previous pre-DLAA scene color. Each current pixel is reprojected into that history with the generated current-minus-previous motion vector, then corrected by `(previousJitter - currentJitter) / renderSize` because the motion vectors intentionally exclude viewport jitter. The mask takes the maximum of:

- A relative RGB change response between current color and bilinearly sampled reprojected history.
- A 3x3 relative depth-range response around silhouettes and disocclusions.
- Full rejection when the reprojected history coordinate lies outside the frame.

The fixed starting thresholds are 8% relative color change and 0.2% relative depth range. `History-Rejection Strength` scales the combined response. On first use, a discontinuous frame, a source change, or a DLAA history reset, the prepass initializes color history and writes full rejection for that evaluation. It then copies the current typed scene input into the persistent history texture after the mask dispatch. Disabling the mask passes `nullptr` to NGX and invalidates this separate color history, while DLAA itself remains enabled.

This is a confidence hint, not a substitute for true object motion vectors. It should reduce trails from particles, animated textures, and objects whose camera-only vector is wrong by making DLAA trust their current color more, at the cost of less temporal accumulation in bright mask regions.

## DLAA Input Debug View

The `DLAA Investigation` section now contains `DLAA Input Debug View`:

- `Off`: normal image; the motion-vector prepass still runs.
- `Direction`: signed XY motion in red/green. Zero motion is middle gray.
- `Magnitude`: motion length in grayscale. Zero motion is black.
- `History Rejection Mask`: the synthetic NGX bias mask in grayscale. Black keeps normal DLAA history weighting; white completely favors current color.

The visualization is applied at the end of the active postprocess replacement solely for validation. It reads the prepass texture at the current output pixel.

Expected behavior:

- A stationary scene and camera should be mostly middle gray in Direction or black in Magnitude.
- Camera rotation/translation should produce coherent signed direction across geometry.
- Magnitude should brighten as camera movement increases.
- With dilation enabled, silhouettes should visibly inherit the far-surface neighborhood vector and disocclusion edges should follow the current jitter quadrant.
- Compare dilation off/on while panning across the problematic textures. Improvement confined to edges validates the conditioning pass; motion across the body of an independently animated object still requires true per-object vectors.

## Camera Jitter

Two exploratory generic constant-buffer scanners caused crashes immediately after activation. The first mapped/unmapped buffers during draws; the second retained pointers from the game's map calls. Neither path identified or patched a projection candidate before the crashes. Both have been removed and must not be restored. The heap-corruption event at shutdown may be the user's Alt-F4 exit and is not being treated as evidence about the new path.

`jitter.hpp` applies jitter by offsetting the viewport for full-resolution draws whose depth-stencil resource belongs to the exact depth lineage consumed by the final postprocess. The sampled t3 texture is not the DSV bound while rendering this game's scene, so direct handle equality produced `eligible=0` and disabled effective jitter. Copy/texture-copy/resolve events now trace that authoritative postprocess texture back to its source DSV; only the resolved source DSV (or a direct t3 binding) is eligible. Resolution alone is not sufficient, so full-resolution auxiliary render targets remain unjittered. Under the D3D viewport transform, adding pixel jitter `(J.x, J.y)` to the viewport origin is exactly equivalent to adding `(2 * J.x / width, -2 * J.y / height)` in NDC. This avoids shader-specific projection layouts and never inspects, maps, dereferences, or modifies the game's constant-buffer memory.

The original viewport list is captured from application viewport binds. Before an eligible scene draw, a jittered copy is bound. Before any subsequent ineligible draw, the original viewports are restored. Application viewport changes and command-list resets invalidate the cached applied state, preventing jitter from leaking into post-processing passes.

The game also creates auxiliary EOS/D3D11 dummy swapchains. Jitter tracks the largest/primary swapchain explicitly so initialization or destruction of those smaller swapchains cannot overwrite the 3840x2160 render dimensions.

The `DLAA Investigation` section contains `Camera Jitter Override`:

- `Automatic`: applies Halton 8 while DLAA is enabled and restores the unjittered viewport otherwise.
- `Halton 8 (Forced)`: applies the intended eight-phase sequence independently of DLAA.
- `Four Quadrants (Debug)`: applies a deliberately obvious four-frame sequence for visual validation.
- `Off (Forced)`: keeps DLAA evaluation enabled while forcing both viewport jitter and the NGX jitter input to zero.

For a pixel-space jitter `J`, the injected projection offset is:

```text
projection.x =  2 * J.x / renderWidth
projection.y = -2 * J.y / renderHeight
```

The original pixel-space value is retained for the later NGX evaluation call only when at least one exact-depth-matched scene draw was jittered during that presented frame. Otherwise NGX receives `(0, 0)`, including the first depth-discovery frame, resource recreation, and `Off (Forced)`. The transition between zero and active camera jitter resets DLAA history. At DLAA's 1:1 render/output ratio, NVIDIA's recommended base phase count is eight. The generated motion vectors currently exclude our injected jitter because they are reconstructed from the game's original camera reprojection transform. Therefore the later DLAA feature must leave `NVSDK_NGX_DLSS_Feature_Flags_MVJittered` unset and pass the current pixel jitter separately.

### Jitter Validation

1. Set `Camera Jitter` to `Four Quadrants (Debug)` in a stationary scene. Fine geometry should alternate among four stable sub-pixel positions without whole-pixel jumps.
2. Switch to `Halton 8`. The offsets should follow a less repetitive eight-frame sequence and remain bounded within one pixel.
3. Switch to `Automatic` with DLAA off. The image must immediately return to the game's unjittered viewport.
4. Enable DLAA and select `Off (Forced)`. DLAA must remain active while scene jitter stops; the live-input-tuning log should report `camera_jitter_pattern=0 jitter_raw=(0, 0)` as history resets.
5. Check HUD, post-processing, reflections, and render-to-texture materials for movement; exact main-depth matching and viewport restoration keep auxiliary passes unjittered.

Expected log entries are:

- `LORWIN DLAA jitter: ACTIVE viewport pattern=...; game constant-buffer memory is not read or modified.`
- `LORWIN DLAA jitter: tracking postprocess depth resource=0x...`
- `LORWIN DLAA jitter: resolved exact main-scene depth source=0x... -> postprocess depth=0x... via ...` when the sampled depth is copied/resolved from a separate DSV.
- `LORWIN DLAA jitter: FORCED OFF; viewport and NGX jitter are both zero.` when selected.
- One or more `eligible vertex_shader=0x... graphics_layout=0x...` entries.
- A `60-frame diagnostics` entry including `main_depth_unknown`, `main_depth_mismatch`, `jitter_binds`, and `viewport_restores`.

## DLAA Output Binding / UI Corruption Fix

The first working NGX path temporarily replaced the game's native scene-color `t0` descriptor before each postprocess draw and attempted to restore it afterward. In D3D12, that binding shares a descriptor table with the postprocess `t1`-`t7` resources. Replacing one entry through an emulated push-descriptor table did not preserve the rest of the native table reliably and could also leak the temporary table into later draws. The observed result was flickering/random colors and large rectangular UI geometry sampling scene-color fragments.

Native game descriptor tables are no longer modified. The NGX output SRV is now exposed only to the replacement postprocess shaders at private `t1, space50`; `ShaderInjectData::dlaa_enabled` selects that resource only after a successful evaluation. Motion vectors remain at private `t0, space50`, and the bias-mask debug SRV uses private `t2, space50`. Native scene, bloom, luminance, depth, blur, noise, distortion, gamma, and subsequent UI/HUD bindings remain intact.

## Relevant Files

- `addon.cpp`: DLAA, debug, and passive resource-logging settings; callback/runtime registration.
- `dlaa.hpp`: D3D12 pre-postprocess runtime, input discovery, resource-state tracking, NGX lifecycle/evaluation, motion-vector and synthetic-bias-mask dispatches, color history, and private debug/output SRV binding.
- `jitter.hpp`: Halton/debug sequences, full-resolution scene filtering, viewport jitter/restoration, and diagnostics.
- `resource_logger.hpp`: passive runtime evidence collector and descriptor tracking helpers.
- `shaders/motion_vectors.cs_6_0.hlsl`: motion-vector compute shader.
- `shaders/bias_current_color_mask.cs_6_0.hlsl`: reprojected color-change and depth-discontinuity history-rejection mask.
- `common.hlsli`: private motion-vector/DLAA/bias-mask texture declarations, scene-input selection, and debug visualization helper.
- `shared.h`: `dlaa_debug_view` and per-draw `dlaa_enabled` shader-injection values.
- `shaders/0xCFC0C7CF.ps_6_0.hlsl`
- `shaders/0x17BBC7EE.ps_6_0.hlsl`
- `shaders/0x9805B9F6.ps_6_0.hlsl`
- `shaders/0x0C0E1BA4.ps_6_0.hlsl`

## Build and Verification

Build with the user-specified target:

```powershell
cmake --build --preset vs-x64-release --target LORWIN
```

The expected runtime log entries when the first matching postprocess draw runs with DLAA enabled are:

- `LORWIN DLAA: created the AC3R-style depth-neighborhood motion-vector compute pipeline.`
- `LORWIN DLAA: created motion-vector texture <width>x<height> format=R16G16_FLOAT ...`
- `LORWIN DLAA: NGX initialized, SuperSampling_Available=1`
- `LORWIN DLAA: created typed staging/output, color-history, and R8 bias-mask textures <width>x<height> ...`
- `LORWIN DLAA: created synthetic BiasCurrentColorMask compute pipeline.`
- `LORWIN DLAA: feature created at <width>x<height> flags=AutoExposure preset=K`
- `LORWIN DLAA: evaluation active at <width>x<height> jitter_raw=(...) jitter_ngx=(...) mv_scale=(...) bias_mask=on preset=K`

The addon no longer forces borderless mode, screen tearing, or fullscreen prevention. Display-mode selection is left to the game/OS so those swapchain overrides cannot interfere with DLAA validation; the HDR10 swapchain path remains enabled.

The Release build completed successfully on 2026-08-16. The game-folder addon is a symbolic link to `build.vs/Release/renodx-lorwin.addon64`. The current build includes exact source-DSV lineage, forced-off jitter validation, AC3R-style depth-neighborhood motion-vector dilation, and the synthetic reprojected color/depth history-rejection mask. The build and deployed addon have SHA-256 `F3B688D91F0D453F250DEF48FD0C0C07C6AD92ECBD57320CFACF959B3C720DCD`.

## Next Task: Runtime-Validate DLAA

Start the game, enable `DLAA`, and validate the new NGX path:

1. Confirm all seven expected DLAA log messages above appear and no NGX error is logged.
2. Compare stationary fine geometry with DLAA off/on. With DLAA on, the image should stabilize rather than visibly alternate through the jitter sequence.
3. Pan and rotate the camera; check for coherent temporal reconstruction, ghosting, inversion, or runaway smearing.
4. Verify bloom, film grain, UI/HUD, gamma, HDR tone mapping, and menus remain visually unchanged apart from scene anti-aliasing.
5. Toggle DLAA off; automatic jitter and private DLAA-output sampling must stop immediately.
6. Select `History Rejection Mask`: stable surfaces should remain dark, while disocclusion edges, particles, animated textures, and incorrectly tracked motion should brighten. The first/reset frame is intentionally white.
7. Compare `Synthetic History-Rejection Mask` off/on at 100% strength around the problem textures. If the mask helps but adds shimmer, lower the strength; if ghosting remains in correctly detected regions, raise it moderately.
8. If behavior differs between models, compare presets K, J, F, L, and M and retain the log for follow-up.

Do not move DLAA after postprocessing, feed it UI/final-backbuffer content, or write its result back into a resource that the same evaluation still consumes.
