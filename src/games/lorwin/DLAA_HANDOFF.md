# LORWIN DLAA Handoff

## Current Context

Game: The Lord of the Rings: War in the North - Legacy Edition  
RenoDX shortname: `lorwin`  
Renderer: D3D12

The normal HDR path remains intact. The implementation now includes the prerequisite motion-vector prepass, real camera jitter through the raster viewport transform, and an NVIDIA NGX DLAA evaluation immediately before the game's final postprocess draw. DLAA is off by default pending runtime validation.

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
5. Transitions the texture from SRV to UAV and back to SRV.
6. Restores the compute pipeline and descriptor-table state that was active before the prepass.

The generated texture is injected into replacement postprocess shaders as `t0, space50`. Generation is independent of the debug mode so the texture remains ready for the later DLAA evaluation pass.

The prepass itself does not alter native scene t0 or the final output. Its texture is consumed by the DLAA evaluation described below.

## Implemented DLAA Evaluation

Each wrapped postprocess variant now performs these steps immediately before its native draw when `DLAA` is enabled:

1. Resolves the verified scene t0 and depth t3 descriptors from the active graphics layout.
2. Copies the typeless RGBA8 scene resource into a dedicated typed `R8G8B8A8_UNORM` full-resolution NGX input texture.
3. Evaluates an NVIDIA NGX SuperSampling feature at a 1:1 input/output ratio using `NVSDK_NGX_PerfQuality_Value_DLAA`.
4. Supplies the typed color input, native depth, generated `R16G16_FLOAT` UV motion vectors, and current pixel-space jitter.
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
- `NGX Jitter Direction`: original or per-axis inversion; original is the recommended default.
- `NGX Jitter Scale`: 0-200%, default 100%.
- `Depth Convention`: standard or `DepthInverted`; standard is expected for this depth buffer.
- `Motion Vectors Include Jitter`: controls `MVJittered`; off is expected because the prepass uses the game's unjittered transform.
- `NGX Color Input`: controls `IsHDR`; LDR is expected for the typed RGBA8 input.
- `NGX Auto Exposure`: on is expected because no separate exposure texture is available.
- `Restore Recommended DLAA Inputs` and `Reset DLAA History` buttons.

Changing a feature flag recreates the NGX feature. Changing MV or jitter axes/scales applies on the next evaluation and resets temporal history. The log records both the feature flags and the effective signed MV/jitter scales.

## Motion-Vector Debug View

The `DLAA Investigation` section now contains `Motion Vector Debug View`:

- `Off`: normal image; the motion-vector prepass still runs.
- `Direction`: signed XY motion in red/green. Zero motion is middle gray.
- `Magnitude`: motion length in grayscale. Zero motion is black.

The visualization is applied at the end of the active postprocess replacement solely for validation. It reads the prepass texture at the current output pixel.

Expected behavior:

- A stationary scene and camera should be mostly middle gray in Direction or black in Magnitude.
- Camera rotation/translation should produce coherent signed direction across geometry.
- Magnitude should brighten as camera movement increases.
- Depth discontinuities and newly revealed regions may show expected edge/disocclusion differences.

## Camera Jitter

Two exploratory generic constant-buffer scanners caused crashes immediately after activation. The first mapped/unmapped buffers during draws; the second retained pointers from the game's map calls. Neither path identified or patched a projection candidate before the crashes. Both have been removed and must not be restored. The heap-corruption event at shutdown may be the user's Alt-F4 exit and is not being treated as evidence about the new path.

`jitter.hpp` applies jitter by offsetting the viewport for full-resolution draws with a full-resolution depth target. Under the D3D viewport transform, adding pixel jitter `(J.x, J.y)` to the viewport origin is exactly equivalent to adding `(2 * J.x / width, -2 * J.y / height)` in NDC. This avoids shader-specific projection layouts and never inspects, maps, dereferences, or modifies the game's constant-buffer memory.

The original viewport list is captured from application viewport binds. Before an eligible scene draw, a jittered copy is bound. Before any subsequent ineligible draw, the original viewports are restored. Application viewport changes and command-list resets invalidate the cached applied state, preventing jitter from leaking into post-processing passes.

The game also creates auxiliary EOS/D3D11 dummy swapchains. Jitter tracks the largest/primary swapchain explicitly so initialization or destruction of those smaller swapchains cannot overwrite the 3840x2160 render dimensions.

The `DLAA Investigation` section contains `Camera Jitter Override`:

- `Automatic`: applies Halton 8 while DLAA is enabled and restores the unjittered viewport otherwise.
- `Halton 8 (Forced)`: applies the intended eight-phase sequence independently of DLAA.
- `Four Quadrants (Debug)`: applies a deliberately obvious four-frame sequence for visual validation.

For a pixel-space jitter `J`, the injected projection offset is:

```text
projection.x =  2 * J.x / renderWidth
projection.y = -2 * J.y / renderHeight
```

The original pixel-space value is retained by `GetPixelJitter()` for the later NGX evaluation call. At DLAA's 1:1 render/output ratio, NVIDIA's recommended base phase count is eight. The generated motion vectors currently exclude our injected jitter because they are reconstructed from the game's original camera reprojection transform. Therefore the later DLAA feature must leave `NVSDK_NGX_DLSS_Feature_Flags_MVJittered` unset and pass the current pixel jitter separately.

### Jitter Validation

1. Set `Camera Jitter` to `Four Quadrants (Debug)` in a stationary scene. Fine geometry should alternate among four stable sub-pixel positions without whole-pixel jumps.
2. Switch to `Halton 8`. The offsets should follow a less repetitive eight-frame sequence and remain bounded within one pixel.
3. Switch to `Automatic` with DLAA off. The image must immediately return to the game's unjittered viewport.
4. Check HUD/post-processing elements for movement; the full-resolution-depth filter and viewport restore are intended to keep those passes unjittered.

Expected log entries are:

- `LORWIN DLAA jitter: ACTIVE viewport pattern=...; game constant-buffer memory is not read or modified.`
- One or more `eligible vertex_shader=0x... graphics_layout=0x...` entries.
- A `60-frame diagnostics` entry including `jitter_binds` and `viewport_restores`.

## DLAA Output Binding / UI Corruption Fix

The first working NGX path temporarily replaced the game's native scene-color `t0` descriptor before each postprocess draw and attempted to restore it afterward. In D3D12, that binding shares a descriptor table with the postprocess `t1`-`t7` resources. Replacing one entry through an emulated push-descriptor table did not preserve the rest of the native table reliably and could also leak the temporary table into later draws. The observed result was flickering/random colors and large rectangular UI geometry sampling scene-color fragments.

Native game descriptor tables are no longer modified. The NGX output SRV is now exposed only to the replacement postprocess shaders at private `t1, space50`; `ShaderInjectData::dlaa_enabled` selects that resource only after a successful evaluation. Motion vectors remain at private `t0, space50`. Native scene, bloom, luminance, depth, blur, noise, distortion, gamma, and subsequent UI/HUD bindings remain intact.

## Relevant Files

- `addon.cpp`: DLAA, debug, and passive resource-logging settings; callback/runtime registration.
- `dlaa.hpp`: D3D12 pre-postprocess runtime, input discovery, resource-state tracking, NGX lifecycle/evaluation, motion-vector dispatch, and private motion-vector/DLAA-output SRV binding.
- `jitter.hpp`: Halton/debug sequences, full-resolution scene filtering, viewport jitter/restoration, and diagnostics.
- `resource_logger.hpp`: passive runtime evidence collector and descriptor tracking helpers.
- `shaders/motion_vectors.cs_6_0.hlsl`: motion-vector compute shader.
- `common.hlsli`: private motion-vector/DLAA texture declarations, scene-input selection, and debug visualization helper.
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

- `LORWIN DLAA: created the motion-vector compute pipeline.`
- `LORWIN DLAA: created motion-vector texture <width>x<height> format=R16G16_FLOAT ...`
- `LORWIN DLAA: NGX initialized, SuperSampling_Available=1`
- `LORWIN DLAA: created typed staging/output textures <width>x<height> ...`
- `LORWIN DLAA: feature created at <width>x<height> flags=AutoExposure preset=K`
- `LORWIN DLAA: evaluation active at <width>x<height> jitter=(...) mv_scale=(...) preset=K`

The addon no longer forces borderless mode, screen tearing, or fullscreen prevention. Display-mode selection is left to the game/OS so those swapchain overrides cannot interfere with DLAA validation; the HDR10 swapchain path remains enabled.

The Release build completed successfully on 2026-08-16. The game-folder addon is a symbolic link to `build.vs/Release/renodx-lorwin.addon64`, and the build output had SHA-256 `23CF4B03E91A25FD1598D1E3CE8E24A0DEF58CD4EEBE99DCC3C330C08FE0000E` after adding Transformer 2 presets L and M.

## Next Task: Runtime-Validate DLAA

Start the game, enable `DLAA`, and validate the new NGX path:

1. Confirm all six expected DLAA log messages above appear and no NGX error is logged.
2. Compare stationary fine geometry with DLAA off/on. With DLAA on, the image should stabilize rather than visibly alternate through the jitter sequence.
3. Pan and rotate the camera; check for coherent temporal reconstruction, ghosting, inversion, or runaway smearing.
4. Verify bloom, film grain, UI/HUD, gamma, HDR tone mapping, and menus remain visually unchanged apart from scene anti-aliasing.
5. Toggle DLAA off; automatic jitter and private DLAA-output sampling must stop immediately.
6. If behavior differs between models, compare presets K, J, and F and retain the log for follow-up.

Do not move DLAA after postprocessing, feed it UI/final-backbuffer content, or write its result back into a resource that the same evaluation still consumes.
