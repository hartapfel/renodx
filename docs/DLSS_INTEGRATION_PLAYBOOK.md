# DLSS integration playbook for the next game

Source-audited 2026-10-23 against The Witcher 3 Classic and the Ezio Trilogy TAA/DLAA implementation. Start here when adding temporal reconstruction to another game. This is the reusable procedure; the linked investigations retain captures, exact engine findings and failed experiments. Engine addresses, shader hashes and conventions below are **Classic examples, never portable constants**.

## 1. Read in this order

| Need | Read |
| --- | --- |
| Complete implementation sequence and acceptance gates | This document |
| Current Classic source/deployment status | Top of [Classic handoff](WITCHER3_CLASSIC_HDR_HANDOFF.md), then [game README](../src/games/thewitcher3classic/README.md) |
| Previous poses, identity, coverage, deformation and performance | [Object-motion implementation guide](OBJECT_MOTION_VECTOR_INTEGRATION.md) |
| Native scene sizing, camera jitter, menu recovery, Ghidra evidence | [Classic upscaling investigation](WITCHER3_CLASSIC_UPSCALING_RESEARCH.md) |
| Exact draw-time inspection and bridge setup | [DevKit MCP guide](DEVKIT_MCP.md#live-d3d11-temporal-input-capture) |
| Build and reproduce the CPU/GPU fixtures | [Classic tests](../src/games/thewitcher3classic/tests/README.md) |
| DX9/x86 alternative, shared-device/process transport | [Ezio implementation, sections 32–33](../src/games/asscreedeziotrilogy-taa/IMPLEMENTATION.md#32-dlaa-feasibility-investigation-2026-09-18) and [projection audit](../src/games/asscreedeziotrilogy-taa/JITTER_AUDIT.md) |

Do not start from an arbitrary dated “next steps” paragraph in a session history. Read the current-state note first. Distinguish source implemented, compiled, linked, loaded, GPU fixture passed, live capture verified and user accepted. None implies all the others.

### What is established in Classic

- Native x64 DX11, direct NGX on the game's device, replacing native TAA. No graphics API wrapper or helper process is needed.
- DLAA and actual lower-resolution scene rendering for Quality/Balanced/Performance/Ultra Performance are implemented. The user accepted Performance, Map recovery and the improved coherent projection jitter. Both DLAA and SR use that jitter integration.
- Motion covers tested skin/reference skin, rigid attachments, Apex cloth, flock birds, opaque horse tails and wind/contact foliage. The user accepted the broad coverage and later performance correction. This is not universal coverage certification.
- Current source defaults: enabled, Quality, model M; saved choices persist. Vegetation exclusion defaults off. The model selection requests a preset, not a verified effective model.
- Remaining engineering work includes material-scoped mip bias, explicit camera-cut handling, wider transition/resize/multiview acceptance, translucent-layer policy and profiling remaining full-pool work. `runtime.hpp` still deliberately passes `motion_validated=false`, `development_inputs=true`.
- During this documentation audit the user had already rebuilt/restarted: the 16:13:07 CEST Release (4,789,248 bytes) is linked from the game folder, with addon registration and reconstruction in PID 3144's log. The handoff records its SHA256. Vignette visual acceptance remains distinct from successful loading.

## 2. Choose the smallest compatible architecture

Record executable SHA256, store/version, PE architecture, native graphics API, GPU/driver, ReShade/DevKit versions, NGX SDK/runtime version and existing addon ownership before coding.

| Situation | Starting reference | Decision |
| --- | --- | --- |
| Native x64 D3D11 with accessible current scene/depth | Classic `temporal/dlss.hpp`, `context.hpp`, `runtime.hpp` | Evaluate on the owning immediate context; preserve native state |
| Native DX9/x86 | Ezio `dlaa.hpp`, `dlaa_protocol.hpp`, `dlaa_helper/` | Its DX9Ex to x64 DX11 shared-resource worker addresses actual API/bitness constraints; do not transplant that overhead into native DX11 |
| Existing DX12/Streamline integration | That game's existing ownership and SDK contract | Reuse its device/queue/barrier/lifetime design; Classic DX11 state swaps are not a DX12 synchronization design |
| No usable depth/camera or no proven pre-HUD insertion point | DevKit investigation first | Do not feed a completed UI image and guessed vectors into DLSS |

The actual Ezio DLAA development reference is **`asscreedeziotrilogy-taa`**, not merely the standalone `asscreed2` HDR folder or the older Brotherhood dgVoodoo README. Ezio also has a later DX12 presentation/FG backend: its protocol, synchronization and presentation work are separate from SR/DLAA. This playbook does not implement Frame Generation or Reflex.

Classic links the existing x64 NGX library and uses existing Detours. Do not edit shared CMake/vendor dependencies reflexively: inspect existing target conditions; obtain the repository-required approval for new global build changes. Reuse architecture and invariants, not an unrelated project's ID, offsets, textures or hooks.

## 3. Establish a capture contract before writing reconstruction

Create a per-game worksheet with these fields and evidence paths:

| Item | Required observation |
| --- | --- |
| Insertion boundary | Producer, selected draw, next consumer, UI/video boundary, offscreen exclusions |
| Current color | Resource/view, format, mip/subrect, alpha use, encoding, exposure and HDR range; prove it is current input rather than accumulated TAA output |
| Depth | Resource/view and sampleable format, near/far convention, clear value, sky behavior, alignment with color |
| Camera | Current/previous matrices, row/column orientation, jittered versus unjittered forms, frame index and update/upload timing |
| Motion | Sign, units, axes, resolution, jitter convention, dynamic-object coverage, validity encoding |
| Output | Required dimensions/format, target and blend/write state, downstream sampling and history ownership |
| View ownership | Main scene versus inventory, reflection, shadow, cinematic, recursive or multi-view rendering |
| Lifetime | Last native use, mutation/reuse timing, safe copy boundary, render versus simulation update |

In Classic, native TAA PS `201C53B4` reads current scene t0, depth t4, camera b10 and frame b12. The first final-grade anchor was `649AF4FA`; additional permutations exist. Native motion-blur `C3F99418` reconstructs camera motion; enabling Motion Blur did **not** reveal a complete animated-object velocity field.

### Exact capture procedure

1. Discover the current connection with `renodx_list_connections`; connect using `renodx_connect`. Do not reuse an old PID/pipe or assume persistent JavaScript helpers survived the last session.
2. Queue a snapshot, wait for a rendered frame, inspect pipeline stages with `devkit_get_draw`. A sorted list of shader hashes does not identify which is VS or PS.
3. Inspect/dump the candidate shaders with DevKit. For Classic SM5, use the DXBC decompiler; the DXIL workflow is for SM6. Establish native-equivalent replacements before adding motion outputs.
4. Capture inputs **at the draw**, before transient buffers/textures are overwritten. A late ordinary texture readback can show a later resource use. Example for Classic:

```json
{
  "action": "start",
  "shaderHash": "0x201C53B4",
  "stage": "pixel",
  "frameCount": 32,
  "textureFrames": 1,
  "textureSlots": [0, 4],
  "callStack": true
}
```

5. Query `status` in small pages (`offset`, `limit:1`). Save raw `capturedWords`, offsets, sizes, frame/draw IDs and matrices. Float JSON nulls can represent NaNs; retain the words. Use `preservedResourceViewHandle` for owned texture snapshots, not an arbitrary native texture pointer.
6. For geometry, select `stage:"vertex"`, explicit `bufferSlots`, and `vertexBuffers:true`. CBs are captured separately; `bufferSlots` means SRV buffers. Prefixes begin at bound offsets, not necessarily resource byte zero. A 64 KiB prefix is not an entire bone buffer.
7. Capture stationary camera/object, moving camera with stationary object, stationary camera with animated object, then both moving. For intermittent loss, collect consecutive bounded captures spanning disappearance **and** reappearance; correlate images with draw hashes and history diagnostics. One good frame cannot disprove flicker.
8. Stop/clear captures after saving. If no frames arrive, inspect whether the pass is drawn; menu/paused states may omit it. Do not keep requesting a stale shader hash. Diagnostic capture must not remain active during timing.

The patched DevKit supports up to 120 frames per capture with bounded CB/texture budgets and nonblocking completion polling. Discover current tool schemas rather than guessing arguments. [DevKit source](../src/addons/devkit/d3d11_capture.hpp) and the MCP guide explain limits. A new machine needs the patched tool build, not just the game addon.

**Gate:** an independently checked input worksheet and immutable originals outside the source/live directory. If a required contract remains unknown, investigate it rather than compensating with tuning sliders.

## 4. Bring up isolated NGX, then replace one temporal resolve

Use [dlss.hpp](../src/games/thewitcher3classic/temporal/dlss.hpp) as a lifecycle example and [tests/dlss.cpp](../src/games/thewitcher3classic/tests/dlss.cpp) as the isolated GPU fixture.

1. Check adapter/vendor and NGX capabilities on the intended device. Use a deliberate runtime search/log directory and record the actual DLL. Check availability even on NVIDIA hardware.
2. Obtain the underlying device/context, including ReShade proxy unwrapping. Resources created on a native device can return a proxy from `GetDevice`; raw pointer inequality caused Classic's initial “input resource mismatch.” Normalize ownership before comparing. See `IsSameDevice` in [context.hpp](../src/games/thewitcher3classic/temporal/context.hpp).
3. Allocate input/output resources once per relevant size change, validate same-device ownership, format, dimensions, mips, samples and bind flags. Do not allocate or query capabilities per draw.
4. Preserve the entire native pipeline around preparation/evaluation/output, including failure exits. Classic uses an isolated D3D11.1 context state and RAII restoration on the immediate context. Do not mix native untracked mutations with an incomplete hand-written restore. Microsoft specifies that [context state swapping is unsupported on deferred contexts](https://learn.microsoft.com/en-us/windows/win32/api/d3d11_1/nf-d3d11_1-id3d11devicecontext1-swapdevicecontextstate).
5. First evaluate DLAA on synthetic inputs and validate state, sign/scale, reset, HDR and feature recreation. Then replace one proven native TAA draw. Skip the native draw only after replacement output is successfully written; preserve native fallback on failure. Avoid resolving twice.
6. Cache the requested model/quality and feature dimensions. On unsupported preset creation, release partial state, clear every quality-specific hint and retry default once. Cache the request even after successful fallback; otherwise recreation can occur every frame. A newer DLL can silently substitute a model; do not report the effective model from the menu selection.
7. Release the feature, parameters and NGX device state in order before releasing the device. Disable native observers before device-owned state dies.

### Classic's exact NGX input contract

| Input | Current implementation | Porting obligation |
| --- | --- | --- |
| Color | Render-sized RGBA16F, finite/nonnegative, capped at FP16 maximum, alpha 1 | Prove encoding/exposure/alpha requirements. The later LUT revision restores the current negative residual in the output pass, following Ezio; alpha remains Classic's 1 |
| Depth | Render-sized R32F raw reverse-Z | Set `DepthInverted` only for the observed convention |
| Motion | Render-sized RG16F, undilated, unjittered `previousUV - currentUV` | Set MV scale to render width/height for normalized UV; do not scale pixel vectors again |
| Bias-current-color mask | R8, 1 for rejected motion/history | This is integration-owned confidence input, not NVIDIA's internal debug confidence |
| Jitter | Actual rendered displacement, input pixels, right/down convention | Derive sign from the native projection; separate from unjittered vectors |
| Exposure | HDR + AutoExposure flags, pre-exposure/exposure scale 1 | This is Classic's choice, not permission to ignore another engine's exposure scaling |
| Output | Output-sized RGBA16F UAV/SRV; full-size blit to native TAA target | Preserve the next consumer's format/encoding contract |
| Reset | Feature recreation, frame gaps, caller reset | Add explicit cuts/discontinuities where not already covered; Classic's comprehensive cut detection remains pending |

Classic creates with `IsHDR | MVLowRes | AutoExposure` and reverse-Z flag; `MVJittered` is not set. `MVLowRes` means input/render-resolution motion, including DLAA where input equals output. **RG16F is half precision, not half spatial resolution.** Arbitrarily halving the vector texture is not a fix for identity or coverage and is not this contract.

Preparation is one compute pass (`0xF3C10001`); conversion is one fullscreen triangle (`0xF3C10002/03`); diagnostics use `0xF3C10004`. These are private addon shaders, not native hashes to discover in the game. No CPU image readback or helper synchronization is needed on this same ordered DX11 context.

**Gate:** NGX fixture passes on actual NVIDIA hardware, replacement preserves native state and downstream image, and failures leave a usable native path. Camera-only DLAA is a development milestone, not complete dynamic-scene integration.

## 5. Make jitter and frame identity coherent

Do this before judging final DLAA quality or adding upscaling. Changing only the offset supplied to NGX creates disagreement with the sampled geometry.

- Locate the engine camera producer and all derived matrices, not just a convenient VS constant. Capture call stacks, resolve RVAs against the exact executable and inspect Ghidra/disassembly. Compare CPU values to exact GPU uploads.
- Generate a single sample for the owned rendered main view. Apply it before depth/geometry and dependent screen-space work; rebuild inverse/current products with the native setter where available. Exclude shadows, auxiliary views, UI and intentionally unjittered reprojection cameras.
- Keep current and previous **rendered** state together. Multiple simulation updates, repeated submissions, culling and frame gaps must not advance history independently.
- Remove current/previous jitter from motion; send the actual current sample to NGX separately. Synthetic tests should show zero motion for a stationary scene while jitter cycles, plus known translations with correct sign/scale.

Classic proves the 2,880-byte b10 CPU shadow at RVA `2CCB750` against 720 captured words. Its native jitter was two-phase +/-0.25 pixels; current `upscale_engine.hpp` replaces it with Halton(2,3), `max(32, ceil(8 * outputPixels / inputPixels))`, bounded at 1024. The 32-sample floor is a project choice, not a universal NVIDIA mandate. DLAA uses the same machinery with full-size input. Never double DLAA jitter because an SR screenshot looks preferable: its amplitude remains within half an **input** pixel in either mode.

Native setter `1F4360` rebuilds matrices through `1F43B0`. Only the two main-view cameras are overridden. The unjittered local camera inside `C48810` is deliberately excluded. Submitted dimensions and original camera jitter are restored after the scope. See the [jitter investigation](WITCHER3_CLASSIC_UPSCALING_RESEARCH.md#coherent-geometry-jitter-not-an-ngx-only-offset) and Ezio's separate projection audit for other engine examples.

**Gate:** exact geometry and resolve captures agree across a full jitter cycle; stationary unjittered motion remains zero; UI/shadows do not move; DLAA and SR both follow the same frame/sample identity.

## 6. Recover per-object history and cover shader families

Use the [object-motion guide](OBJECT_MOTION_VECTOR_INTEGRATION.md) for algorithms and native contracts. The required order is **identify producer/owner → retain previous rendered deformation → associate exact draw → preserve native output → merge/validate motion**.

### Pick history by deformation, not by mesh appearance

| Surface | Previous state needed | Classic reference and failure avoided |
| --- | --- | --- |
| Static rigid scene | Camera/depth reprojection | Do not capture every building as animated geometry |
| Moving rigid attachment | Owner/mesh/generation and world | `rigid_history.hpp`, `rigid_motion.hpp`; identity-palette props and direct submissions still move |
| Skinned body/head | Bones, world, allocation lifetime | `object_history.hpp`, `object_engine.hpp`; shared palette or equal world matrix is not object identity |
| Reference/morph skin | Above plus previous reference positions/blend | `object_vertex.hlsli`; current reference data cannot reconstruct previous deformation |
| CPU-deformed cloth/tail | Previous deformed positions and world, persistent owner | `deformed_motion.hpp`; A/B/C rotating buffers and render-resource wrappers are not actors |
| Flock instances | Previous bone palette plus each bird's world | `swarm_history.hpp`; use full-population identity before culling/sorting, not visible-instance index |
| Procedural vegetation | Previous wind/time/contact/camera-facing inputs | `foliage_motion.hpp` and generated `0xHASH.vs_5_0.hlsl` wrappers over `0xHASH.native.hlsli`; root-transform history misses bending |
| Soft transparency | Deliberate layer/depth/opacity policy | Still limited; do not blend velocity like color or force soft hair opaque |

Observe packing before GPU upload; retain bounded per-owner sidecars and invalidate destruction/reuse/mesh changes/frame gaps. Classic's native hooks observe stable proxy/mesh identities and validate the packed array/count/frame. Avoid nearest-matrix searches, draw order, transient palette offsets and GPU ring-buffer addresses as identity.

History memory and copies are bounded. Copy a previous palette/shared constant once per relevant frame/version; use previous GPU positions for CPU-deformed geometry without production readback. Never read write-combined DISCARD mappings to “recover” old data. The constant-upload mirror intercepts complete known writes into ordinary CPU memory, copies back before Unmap, and keeps a GPU-copy fallback for unknown writes/deferred contexts.

### Attach motion to the native draw

Classic appends motion/depth MRT outputs to eligible original opaque/alpha-tested draws. Existing visibility/culling/depth tests already eliminate much work; there is no second geometry replay. Match actual main depth, viewport, targets and VS/PS interface, not just hash. Preserve native material color, alpha/LOD discard, depth/stencil, blend, UAVs and all overwritten bindings.

Preserve current clip position **bit-for-bit** for native depth EQUAL. Adding outputs can change compiler optimization. Classic opaque hair required native fused `mad` order plus `precise`; WARP success alone missed NVIDIA differences. Test with every native and new varying consumed so the compiler cannot optimize away the problematic path. Do not loosen depth tests to hide precision errors.

Coverage must include material and LOD permutations. A still NPC with a moving camera revealed missing torso/head shaders even when CPU identity was valid. Use the offline cache scanner, position-expression fingerprint and interface audit in `tools/`; keep generation explicit and reviewed. Matching BLENDINDICES or names is insufficient. Preserve unknown/control-flow-dependent candidates as unresolved. Runtime uses generated hash tables; do not scan/decompile/compile families during rendering.

### Diagnose three distinct failures

- **Dark/no raw object coverage:** shader/interface/eligibility/depth/alpha failure, or a later surface overwrote it. A static rigid surface may intentionally use camera motion.
- **Amber/rejected raw history:** owner/pose/frame/reference/mesh history unavailable; inspect producer and lifecycle.
- **Raw vectors present but final vectors wrong:** inspect depth agreement, units, jitter, frame identity and merge. Do not tune identity code from a final color image alone.

Classic writes motion plus signed native depth. Depth magnitude identifies the surface; sign marks invalid history, including negative zero via bit inspection. Preparation accepts it only when it agrees with final depth, otherwise uses camera reprojection; invalid motion becomes zero plus a white bias-current-color mask. Its `2e-7` depth tolerance is game-specific. Do not transplant that number or a reverse-Z sky policy blindly.

**Gate:** native output/clip tests, owner reuse/reordering tests and continuous camera-pan captures pass. A colorful debug view is not enough: inspect final NGX motion and temporal output on disocclusion and animation.

## 7. Implement real upscaling after DLAA inputs are reliable

1. Query optimal and permitted render dimensions from the installed NGX runtime for each quality/output size. Do not hardcode 2/3 or invent alignment outside returned bounds. Query on size/capability changes, not per draw.
2. Trace the renderer's main-view resolution owner and downstream consumers. Separate **allocation size**, **active scene viewport**, **input subrectangle** and **output size**. Identify native camera/UV constants for each.
3. Publish one coherent resolution/quality plan at a frame boundary; let the render thread own it for that entire view. Changing a menu setting mid-frame must not combine one size's matrices with another size's output.
4. Reduce actual scene rendering. Downsampling a completed full-size scene does not save scene shading. Keep other views native unless proven safe to alter.
5. Extract/prepare only the active rendered subrect; poison unused allocation pixels in tests. Reconstruct to output size and restore downstream full-size constants/viewport before final grading/UI. Restore original owned descriptors on normal/early native returns.
6. Separate “temporal pass absent” from “temporal pass attempted and failed.” Menus legitimately omit TAA. Suspend smaller rendering, then automatically rearm after a valid gameplay resolve. Preserve a failure latch for genuine broken attempts; do not require a user to toggle quality after every Map visit.
7. Test DLAA, all quality modes, odd input sizes, quality changes, repeated menu transitions, loading, cutscenes, resize/alt-tab, native AA off and DLSS off/on. Invalidate incompatible history and recreate feature/SRVs when needed.

Classic retains output-sized native pool allocations, modifies only the submitted main scene view, and restores full size at the final-post boundary. Its object MRT allocations match native depth while motion normalization follows the smaller viewport. NGX preparation textures are truly input-sized. This saves raster/shading work but does **not** establish VRAM, clear or copy savings. Some screen-space effects can still use larger extents.

Classic examples: `RenderHook` at `C1C910`, post boundary `C4D150`, view dimensions `+818/+81C`, pool dimensions `+168/+16C`; b12[23] is view size while b12[73] describes the pool. These contracts are guarded by executable identity and function fingerprints. Another engine must be traced afresh.

**Gate:** live captures prove reduced geometry and resolve input, full-size final output and correct object vectors. Check the same boundaries in menus and transitions; an NGX success code does not prove the game rendered fewer pixels.

## 8. Preserve image-processing order and sampling

Inspect the actual ordering, not a Remastered version or a shader's apparent name. Classic's captured order is depth blur → bloom/native sharpening → LUT → native TAA replacement → final grade → HUD. Native sharpening `3EDDC379` was **before** DLSS; `71AFA8D1` was luminance extraction, not sharpening. Older notes calling all sharpening post-TAA are superseded.

When replacement sharpening is enabled, bypass native sharpening with its center sample while preserving the ping-pong target, then apply Lilium RCAS after reconstruction. New CA and grain also run after reconstruction; grain follows tone mapping and stays out of temporal history/HUD. Reuse an existing final pass when possible. Do not skip a draw that must produce a downstream target, and do not relocate depth/blur effects without proving dependencies.

For another game's native pre-exposure, negative HDR channels, alpha and tonemapping, document exactly what NGX sees and how output is restored. Classic's later LUT revision now follows Ezio's negative-residual restoration: sample the signed current scene at output UV plus current jitter in input pixels, clamp to the active input region, and add its negative component after NGX. NGX still reconstructs nonnegative color. The residual itself is not temporal history. Classic additionally upgrades backbuffer-sized R11 scene targets to signed FP16; a shader-side fix alone cannot preserve negative channels in an unsigned target. Both storage/bandwidth and saturated moving-edge behavior require validation. Alpha remains 1 in Classic, whereas Ezio restores native alpha. Neither is a universal transport contract.

Material-scoped mip bias remains unfinished in Classic. The native sampler binder shares entries across world/shadow/post passes and caches logical indices; a global bias override would affect unrelated work or leave stale bindings. Inspect descriptors and ownership once, cache appropriate variants on quality/device changes, synchronize native binding caches, and measure detail/shimmering. Use the current [NVIDIA programming guide](https://github.com/NVIDIA/DLSS/blob/main/doc/DLSS_Programming_Guide_Release.pdf) for SDK-specific sampling requirements; the local pinned SDK is the build authority. Do not advertise mip-bias completion from a settings dropdown.

## 9. Measure the entire motion system before optimizing

Record the same scene/camera, quality, model, exposure/sharpening, vegetation setting, resolution, frame limiter/VSync, driver and binary hash. Warm up shaders/history. Turn off debug views and DevKit captures. Collect ON/OFF/ON samples; use milliseconds and distribution/percentiles, not one FPS reading.

Collect frame and GPU-busy times, CPU busy/wait and render-thread/core activity, GPU activity/clocks/power, and bounded workload counters (accepted draws, copies/uploads, unchanged reuse, history bytes). Low total CPU usage does not rule out one saturated thread. High GPU activity does not measure occupancy or prove arithmetic saturation. A capped OFF run is a lower bound on the cost difference. Separate CPU submission, GPU execution, synchronization and allocation pressure before choosing a fix.

Classic lessons, in the order that matters:

1. Adding static-building motion did not fix missing NPC permutations. Keep camera-only motion for stationary rigid scenery; bones and wind still require deformation even with a stationary root.
2. Retaining MRT attachments across compatible draws is valid batching, but the first batching revision produced **no observed improvement**. Do not present a plausible optimization as a measured result.
3. The serious cache failure was semantic: ReShade's D3D11 `execute_command_list` notification also fires on Present/Flush. Invalidating all constant mirrors there forced repeated copies. Use `execute_secondary_command_list` for conservative deferred-list invalidation and retain actual buffer-mutation tracking. Read backend emission sites, not only event names.
4. The corrected cache was accepted by the user. Separate recorded runs changed about 9.32 ms to 4.88 ms with full motion; camera/time differed, so this is not a controlled percentage claim. User vegetation comparison was about 201 to 223 FPS, approximately 0.49 ms saved; exclusion is a quality tradeoff, now default off.
5. Deferred contexts keep the safe GPU-copy fallback: recording time is not execution time. Never delete correctness invalidations simply to improve counters.
6. A diagnostic profiling build is a measurement tool, not a performance fix. Remove recurring capture/sweep work from the normal path after diagnosis. `motion_profile.hpp` remains historical source and is no longer wired to the shipping menu/runtime.

Keep history/resource budgets explicit; reuse buffers and versioned snapshots, avoid per-draw allocation/GetDesc/decompilation/trigonometry/readbacks, and measure full-pool clear/copy costs before redesigning allocations. Preserve a known accepted binary and the coverage tests when changing the hot path. [Detailed performance evidence](OBJECT_MOTION_VECTOR_INTEGRATION.md#whole-system-performance-investigation-2026-10-23) contains failed hypotheses and the event correction.

## 10. Failure lookup

| Symptom | Inspect first | Do not do |
| --- | --- | --- |
| NGX input mismatch on apparently identical device | Proxy/native identity, samples/mips/SRV flags, render versus allocation size | Disable validation or add a cross-device copy |
| Stationary surface has motion | Jitter subtraction, frame age, homogeneous W, previous reference inputs | Smooth vectors to hide incorrect math |
| NPC parts vanish only while camera moves | Consecutive frame images, VS/PS/LOD families, EQUAL clip bits, eligibility | Assume object identity is broken from one still capture |
| Hair fades with depth EQUAL | Hardware-tested native `mad` order and all consumed varyings | Change depth test or epsilon to conceal it |
| Cloth stays amber despite rotating-buffer history | Persistent Apex owner/generation, stream identity, previous rendered frame | Key by buffer address or assume double buffering |
| Some birds work, some fail | Individual versus shared-palette flock paths; population index before culling | Key by visible order or use one world per palette |
| Sword fittings/mill move incorrectly | Direct/identity-palette rigid path | Treat zero bone allocation as static |
| Map/Inventory permanently returns to DLAA | Missing-boundary suspension versus actual failure latch | Poll menu state or force users to toggle quality |
| SR works but image shimmers | Actual geometry jitter, input-pixel units, phase sequence, sampler bias | Change only NGX-reported jitter |
| Quality changes leave stale border/UI | Active subrect, pool size, final viewport/constants, output SRV recreation | Resize every pool resource indiscriminately |
| Motion is expensive despite one native draw | Constant copy counts/invalidation, MRT bandwidth, CPU/GPU timings | Assume “no replay” means zero cost or halve vectors blindly |
| Capture shows no draw or wrong texture | Rendering paused/variant absent, draw-time preservation and handle type | Infer absence of a shader family from a timed-out capture |
| Shutdown/crash after addon teardown | Pinned native hooks, CPU-state lifetime, outstanding GPU/COM ownership | Let engine hooks call destroyed ReShade/device state |

## 11. Reproduce tests and preserve evidence

The [test instructions](../src/games/thewitcher3classic/tests/README.md) give build commands independent of private scratch runner scripts. Use the smallest relevant tests; a docs-only update does not require game or GPU rebuilds.

| Change | Minimum meaningful checks |
| --- | --- |
| Camera/jitter/viewport scope | `upscale_engine.cpp`, `dlss.cpp`, full-cycle live geometry/resolve captures |
| NGX ownership/lifecycle/formats | `dlss.cpp`, live device/failure/resize checks |
| Native pose identity/lifetime | `object_history.cpp`, `object_motion.cpp`, reordering/destruction/culling/live pan |
| Shader family/interface | `motion_fingerprint.py`, generated bytecode compile, `object_motion.cpp` on WARP **and hardware**, live affected materials |
| Wind/contact foliage | `foliage_motion.cpp`, live contact/wind, ON/OFF cost comparison |
| Constant mirror/cache | `constant_uploads.cpp` on both devices, full-coverage warm-cache counters and timing |
| Final effects/order | `effects.cpp`, full-size output/HUD and native/custom effect transitions |

### Source and evidence index

All source links below are repository-relative. Scratch artifacts are **local, ignored and not guaranteed to survive a clone**. Save a manifest/hash and archive required captures with the project handoff before deleting scratch. Do not redistribute original game shaders/assets as source without appropriate authorization. If fixtures are absent, recapture the documented inputs or mark that validation unavailable; do not substitute synthetic data and call it the original regression.

| Subject | Durable implementation | Existing local evidence location |
| --- | --- | --- |
| Device/NGX contracts | [dlss.hpp](../src/games/thewitcher3classic/temporal/dlss.hpp), [context.hpp](../src/games/thewitcher3classic/temporal/context.hpp) | `tmp/witcher3classic-investigation/temporal-dev/dlss-runtime/`; test logs under `tmp/` |
| Resolve/color/depth/MV conversion | [runtime.hpp](../src/games/thewitcher3classic/temporal/runtime.hpp), [prepare.hpp](../src/games/thewitcher3classic/temporal/prepare.hpp), [compute shader](../src/games/thewitcher3classic/temporal/0xF3C10001.cs_5_0.hlsl) | `temporal-dev/devkit-live/dlss-audit/` originals and captures |
| Main-view sizing/jitter/menu | [upscale_engine.hpp](../src/games/thewitcher3classic/temporal/upscale_engine.hpp), [camera.hpp](../src/games/thewitcher3classic/temporal/camera.hpp) | `temporal-dev/performance-{taa,geometry,grade}-inputs.json`, `performance-size-verification.json`, `upscale-menu-draws.json`, `jitter-producer-long.txt`, `jitter-camera-update.txt` |
| Native reverse engineering | [object_engine.hpp](../src/games/thewitcher3classic/temporal/object_engine.hpp) and the upscaling investigation | `temporal-dev/project/WitcherClassic.gpr`; `ghidra-*.cmd` and saved function disassembly/decompilation |
| Skin/rigid/cloth/birds | [temporal directory](../src/games/thewitcher3classic/temporal/) and object-motion guide | `temporal-dev/devkit-live/dlss-audit/`, `bird-instancing-decompiled.txt`, `swarm-lifetime-decompiled.txt`, `cloth-history-flags.exr`, `stability-20261023/`, `tail-20261023/` |
| Offline family discovery | [tools directory](../src/games/thewitcher3classic/tools/) | Cache inventory/decompiled archives referenced by object-motion guide; originals are not generated substitutes |
| Wind/contact | [foliage_motion.hpp](../src/games/thewitcher3classic/temporal/foliage_motion.hpp) | `temporal-dev/foliage-20261023/`: originals and `0xHASH-N-bSLOT.bin` constants |
| Performance | [constant_uploads.hpp](../src/games/thewitcher3classic/temporal/constant_uploads.hpp), runtime event registrations | `temporal-dev/performance-20261023/`: PresentMon CSVs, utilization JSON, accepted binary backup |
| Sharpen/CA/grain/blur/vignette | [effects tests](../src/games/thewitcher3classic/tests/effects.cpp), final-grade include | `tmp/witcher3classic-investigation/effects-20261023/` |

`temporal-dev/` in this table abbreviates `tmp/witcher3classic-investigation/temporal-dev/`. Use `rg --files` to locate filenames that moved between its root and `devkit-live/dlss-audit`. Historical one-off mutation scripts are **not** idempotent build steps; do not rerun `add_*`, `fix_*`, `generate.py` or documentation-recovery scripts blindly.

Local Ghidra was at `D:/Downloads/ghidra_12.1.3_PUBLIC_20260817/ghidra_12.1.3_PUBLIC`; locate it again on another PC. Reuse the existing project/exported functions before reanalysis. Resolve interior stack PCs through native instructions/unwind ranges before inventing function starts; decompiler return-type guesses can be wrong. Do not hardcode a previous ASLR base or PDB layout in process probes.

Native hooks verify Classic's PE identity and function fingerprints, install transactionally with thread handling, and pin the containing module. Their CPU-only state outlives ReShade teardown; device-owned GPU state does not. Read the [native hook contract](OBJECT_MOTION_VECTOR_INTEGRATION.md#native-hook-contract-and-lifetime) before copying any hook design.

### Required next-agent handoff

At every stopping point, record:

```text
Game/executable hash/API/architecture; repo revision and dirty scoped files:
Current source changes and exact entry points:
Build preset/target; binary SHA256, timestamp, size; linked/loaded status:
NGX SDK and loaded DLL/version; GPU/driver; game AA and DLSS settings:
Input contract (color/depth/motion/jitter/exposure/subrect/frame ownership):
Native hook addresses/fingerprints/ABI evidence and lifecycle constraints:
Accepted coverage versus candidates versus unresolved/translucent paths:
Tests actually run, device, commands, results and limitations:
Live evidence and user acceptance (separate from synthetic tests):
Performance scene/settings, cap state, timing files, failed hypotheses:
Artifact manifest/archive location; missing fixtures and recapture procedure:
Outstanding steps in dependency order, with the next exact capture/test:
```

Keep normal-user menu labels separate from development confidence. Do not claim “100% reliable,” effective preset identity, completed cut handling, mip bias or universal material coverage from a finite test suite. Keep the precise unresolved items so the next agent can make progress rather than rediscover the same boundary.

## 12. Primary documentation

- [NVIDIA DLSS SDK and programming guide](https://github.com/NVIDIA/DLSS): consult the version matching the runtime/headers; local `external/DLSS/include` is the compiled ABI.
- [NVIDIA Streamline DLSS guide](https://github.com/NVIDIA-RTX/Streamline/blob/main/docs/ProgrammingGuideDLSS.md): integration/resource guidance; Classic uses direct NGX, not Streamline initialization.
- [Microsoft context-state isolation](https://learn.microsoft.com/en-us/windows/win32/api/d3d11_1/nf-d3d11_1-id3d11devicecontext1-swapdevicecontextstate) and [HLSL precise](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/precise): API/compiler constraints, followed by actual hardware tests.
- [Motion research source table](WITCHER3_CLASSIC_MOTION_VECTOR_RESEARCH.md#primary-sources-and-implications): NVIDIA, Unity, Unreal and AMD references with the decisions they informed. Cross-vendor algorithms are supporting evidence, not permission to change NGX's input contract.

Online guides can change. Recheck API/format/model claims when changing SDK/runtime; preserve the version used for any validation result. Local code and live evidence establish Classic-specific facts.
