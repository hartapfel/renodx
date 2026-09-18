# Native DX9 TAA implementation and porting guide

Current implementation as extracted on 2026-09-17. This describes the code in
this folder; [DEVELOPMENT_HISTORY.md](./DEVELOPMENT_HISTORY.md) preserves earlier
observations, including superseded limitations. It is an experimental,
Brotherhood-specific implementation, not a general solution for every DX9 game.

## 1. Ownership and source map

| File | Responsibility |
| --- | --- |
| `addon.cpp` | Registration, independent settings and lifecycle entry point |
| `native_taa.hpp` | ReShade events, camera/draw capture, jitter, scene hook, frame/reset lifecycle |
| `native_draw.hpp` | Indexed-draw ranges and reset-safe immediate uploads |
| `taa_camera.hpp` | Matrix conventions, double-precision inverse/multiply and camera agreement |
| `taa_jitter.hpp` | Eight Halton samples and safe SM3 constant-table recognition |
| `taa_geometry.hpp` | Sparse CPU upload cache and immutable changing-vertex snapshots |
| `taa_motion.hpp` | Audited shader profiles, opacity parsing, pose identity/matching and native replay |
| `taa_motion_vs.vs_3_0.hlsl` | Rigid/packed positions and two-oscillator wind |
| `taa_motion_skin.vs_3_0.hlsl` | Current/previous bones, changing positions, normal displacement |
| `taa_motion_tree.vs_3_0.hlsl` | Native trunk/leaf morphing and wind |
| `taa_motion_ps.ps_3_0.hlsl` | Opacity tests and motion/depth output |
| `taa_resolve.hpp` | Private temporal resources, fullscreen draw and state restoration |
| `taa_resolve.ps_3_0.hlsl` | Reprojection, rejection, clipping, accumulation and previews |
| `taa_rcas.ps_3_0.hlsl` | Optional Lilium luminance RCAS on completed TAA, outside history |
| `taa_reprojection.hlsli` | Clip-depth camera reprojection in explicit matrix rows |
| `taa_performance.hpp` | Optional CPU scopes and nonblocking GPU timestamp diagnostics |

Procedural helper shaders use descriptive names; they are not replacements for
CRC-named original shaders. The addon registers **no replacement game shaders**.
It uses existing `utils::shader`, `utils::command_action`, `utils::data` and
`utils::settings`; it does not activate `mods::shader` or `mods::swapchain`.

The Ezio Trilogy addon retains all HDR, resource-format, lighting, LUT, video,
alpha/blending and presentation behavior. The TAA addon owns none of that work.
Its device GUID is separate from the old embedded prototype, and its settings
prefix is `asscreedbrotherhood-taa`. Do not use both TAA implementations together.

## 2. Prove the insertion point before writing a resolve

The original audited Brotherhood frame was 3840×2160, MSAA off, 2,913 draws
(the later native MSAA path is documented in section 28):

```text
Opaque/material passes -> bloom composition -> TAA resolve -> optional RCAS -> LUT / color grade
  MRT0: scene color        (native DX9)          PS 0x48DCE479
  MRT1: clip z/w                                 VS 0x9CB80815
    -> white gradient -> blur/DOF -> scene copy -> HUD -> presentation
```

Material draw 1600 used VS `0x4B000956`, PS `0x276A3376`. MRT0 was FP16 under
RenoDX; MRT1 was full-resolution R32F. Native SDR scene formats are also accepted.
LUT draw 2878 sampled scene RGB at s0 and a 16³ volume LUT at s1. s8 retained the
material R32 texture but was not read by that shader. The code verifies s8's
**resource identity** against the current captured MRT1. A stale binding alone
is not proof of usable depth. DOF `0xDCF074DF` used another R32 texture; it is not
substituted for this one.

This insertion leaves HUD/text outside accumulation and gives the LUT either
native or temporally resolved scene RGB. Bloom is already composed. Some
animated shading therefore still needs a reactive rejection mechanism; motion
of the underlying mesh alone is insufficient.

### Cooperation with RenoDX

`OnLut` is a vertex-stage `command_action` callback for `0x9CB80815`, additionally
requiring pixel hash `0x48DCE479`. The shared dispatcher runs wildcard callbacks,
then vertex callbacks, then pixel callbacks. Thus TAA temporarily binds resolved
s0 before the HDR addon's pixel-stage replacement callback, independent of DLL
load order. The dispatcher draws the original or HDR LUT once, then invokes
post-callbacks. `OnSceneDrawn` restores s0 and its sRGB flag. No duplicate LUT
shader, constant injection, shared TAA device data or HDR dependency is needed.

Raw native device calls inside resolve/replay avoid recursively re-entering
ReShade capture. Draw*UP requires special handling: ReShade announces a temporary
uploaded vertex buffer without binding it. The legacy callback binds that buffer
before replay. The reset-safe path in section 30 now supplies private immediate
upload buffers and restores native stream/index unbinding afterward. Ordinary indexed geometry
has an additional range requirement described in section 7.

## 3. Depth and camera recovery

MRT1 contains **D3D clip z/w in [0,1]**, proved from the original material
instructions. It is already sampleable, so no INTZ conversion or depth-resource
upgrade is needed. Hardware depth/stencil is separately retained for replay
visibility. DOF's `c2.y / (depth + c2.x)` reconstructs view distance and must not
be applied to the reprojection input.

The material vertex contract is `dp4(position, cN)`:

- c0–c3: world-view-projection rows.
- c8–c11: world rows.
- Column-vector convention: `clip = WVP * position`.
- `VP = WVP * inverse(World)`.
- `current_to_previous_clip = previousVP * inverse(currentVP)`.

At least two camera-anchor draws must agree. Check finite/invertible matrices,
same MRT/depth identity, dimensions, no MSAA, and reject deconstruction (`b15`).
`SameCamera` allows a relative tolerance of 0.002 per element. Multiple conflicting
cameras or a second scene pass invalidate the frame. Replay/jitter additionally
check the main hardware depth, scene/viewport conditions and supported state.

**Keep the inverse and its following product in double precision**, converting
only the final matrix to float. Rounding the inverse first produced nearly a
pixel of error at 4K for an unmoving camera hundreds of units from the origin.
Singular and nonfinite inputs are rejected, not replaced with an identity guess.

For current UV/depth:

```text
unjitteredUV = sampledUV - currentJitterPixels / renderSize
clip = (2*u - 1, 1 - 2*v, depth, 1)
oldClip = previousVP * inverse(currentVP) * clip
oldUV = (oldClip.xy / oldClip.w) * (0.5, -0.5) + 0.5
motion = oldUV - sampledUV
```

The resolve stores history on an **unjittered output grid**, so previous-history
jitter is zero. The generic reprojection helper can express previous jitter;
this path intentionally passes zero. Reject nonpositive w, invalid depth and
history coordinates outside the half-pixel inset. Camera preview displays large
out-of-bounds motion even when that motion cannot safely sample history.

## 4. Jitter and frame sequencing

Eight samples use Halton bases 2 and 3, index `frame % 8 + 1`, minus 0.5 pixels.
To offset clip position by a subpixel amount, update the projection rows:

```text
row0 += ( 2*jitterX / width ) * row3
row1 += (-2*jitterY / height) * row3
```

Jitter is a wildcard pre-draw callback, ahead of hash-specific camera/motion
capture. It saves the four original rows and restores them after that draw.
Camera recovery uses the saved **unjittered** matrix. Motion capture keeps both
jittered clip rows for identical raster coverage and unjittered rows for velocity.
The current color sample is taken at `outputUV + jitter / renderSize`.

Do not infer projection constants from arbitrary instructions. `HasProjection`
parses bounded SM3 CTAB records and requires compiler-authored `g_WorldViewProj`
at float c0–c3. It rejects truncated bytecode, missing/stripped contracts and
local DEF instructions overwriting those rows. 264/277 dumped vertex shaders
passed that contract. A bounded 512-shader cache retains shader references.
This is broader than the 19 audited motion profiles; it does not prove that
every particle or transparency path is temporally correct.

Jitter requires Experimental mode, a preceding valid frame, matching main depth
and viewport, depth enabled, and non-UP geometry. Preview modes do not jitter.
First frames and invalid histories seed without blending. Present advances the
frame, swaps current/previous object lists and selects the next jitter. Mode
changes reset temporal resources and validity. Camera gaps over 250 ms, size
changes, or projected cut probes displaced by over 1.5 NDC invalidate history.

## 5. Resolve, precision and color transport

Two RGBA16F textures ping-pong scene RGB and **1-z in alpha**. Two R16F textures
ping-pong sample confidence. Storing z directly in half precision destroyed
distant depth distinctions; storing its complement retains useful precision.
The LUT consumes only RGB, so this never alters game scene alpha. History is
bound as s0 for one draw, never copied over the game's scene render target.

Use a native XYZRHW fullscreen quad with the DX9 half-pixel offset and no vertex
shader. The first POSITION-based path rendered a small region/white screen.
Bind all relevant sampler, render, texture-coordinate and viewport state.
Restore the captured state block plus explicit render targets, depth/stencil
and viewport; state blocks do not restore every one of those bindings.

Per-pixel sequence:

1. Gather the nearest valid depth in a 3×3 neighborhood and take its motion
   identity. Keep color at the original pixel; do not smear neighboring RGB.
2. Prefer hardware-depth-validated object depth when late material passes left
   stale R32 depth. Retain native R32 precision when both depths agree within
   `max(2e-6, (1-z)*0.005)`.
3. Use covered, trusted object motion; otherwise use camera reprojection.
   A covered **unmatched** object rejects history instead of pretending static.
4. Reject previous UV outside the image and incompatible history depth.
   The complement-depth tolerance is `max(2e-6, expected*0.005)` plus local
   slope, capped at `expected*0.02`. Coherent linear three-tap depth runs may
   extend this allowance to twice the summed axis slopes, capped at
   `expected*0.04`; depth steps retain the original allowance (section 15).
5. Compute 3×3 RGB min/max, mean and variance. Intersect min/max with
   `mean ± 1.25*sigma`. Reconstruct history RGB with nine-tap Catmull-Rom,
   then clip along its direction from the box center. Keep depth/count point
   sampled; cubic interpolation never invents a surface depth or validity.
6. Accumulate confidence up to `clamp(1/(1/128 + 0.5*speed), 8, 128)`, where
   speed is unjittered screen motion in pixels/frame. Still pixels keep 128;
   slow motion reduces history immediately. Rejected color can further reduce
   this to 2. Invalid/disoccluded samples restart at one. Remove known raster
   jitter from the motion used to choose this confidence.
7. Blend with `historyWeight = 1 - 1/sampleCount`, then store RGB/depth/count.

A fixed 10% current contribution made the eight-phase edge pattern repeat
forever, including while stationary. Confidence accumulation allows stable
edges to converge. Explicit nearest-half quantization counters the observed
GPU FP16 truncation bias, which otherwise darkened long-running histories.

### Standalone SDR versus HDR input

Accepted scene storage: A8R8G8B8, X8R8G8B8, A8B8G8R8, X8B8G8R8 and
A16B16G16R16F. Unsupported device formats still fail native allocation normally.
TAA never changes these descriptions or presentation color space.

- Preserve s0's original `D3DSAMP_SRGBTEXTURE` while reading native input.
- Encoded scene transport uses the existing gamma-2.2 radiometric blend and
  re-encodes before storing. RGB bounds remain in the sampled transport space.
- If native 8-bit sampling already requests hardware sRGB decoding, blend those
  linear samples directly; applying a second gamma curve would be wrong.
- Bind resolved FP16 with sampler sRGB decode off, because it already contains
  the values the LUT should see. Restore the original texture and flag afterward.
- Changing format/decode contract invalidates history.

The FP16 HDR contract remains the audited encoded RenoDX path. This is not an
automatic detector for arbitrary linear FP16 games; a port must prove encoding.

## 6. Object, bone and procedural motion

Captured material draws are replayed to a private RGBA16F motion target before
the LUT. They use the main hardware depth/stencil for visibility. Output layout:

| Channel | Meaning |
| --- | --- |
| R,G | Previous UV minus current UV, both unjittered |
| B | 1 minus previous clip depth |
| A | Signed 1 minus current depth; positive = trusted pair, negative = unmatched |

Zero alpha means uncovered. A tiny nonzero floor distinguishes far-plane
covered geometry from uncovered pixels. Previews map motion in pixels / 32
around neutral 0.5; missing previous poses are magenta, uncovered pixels black.

### Audited native vertex profiles

`MOTION_SHADERS` is the authoritative layout/semantic table:

| Family | Original vertex hashes |
| --- | --- |
| Rigid float | `4B000956`, `CFF33597` |
| Skeletal | `6ADF3971`, `73550BE7`, `91F6EBFA` |
| Packed rigid / cutout variants | `7B3AA462`, `CBFA98A8`, `490226E1`, `CF25236F`, `6810707F`, `160DC1A8`, `72582374`, `967139C2`, `37DFB300`, `FC8CBBF0` |
| Two-oscillator wind | `BDF4BDE9` |
| Skeletal normal displacement | `89CCF177` |
| Tree trunk / leaves | `F53BF32F`, `9E55FEF3` |

Packed positions use the native `abs(position.w * 3.81481368e-6)` scale. Skeletal
positions scale by 10, use four unnormalized weights and up to 42 bone matrices
(three float4 rows per bone at c120–c245). The current palette stays in native
constants. Previous palettes use a point-sampled RGBA32F vertex texture,
128 texels wide with one row per skeletal/tree draw. All rows are uploaded
once before replay; c24.x selects the row center. This fits SM3 constant limits
without locking a texture for every animated draw. Bone order, packed indices and MUL/MAD
evaluation order must match the original shader.

`89CCF177` applies normal displacement before bones; both previous displacement
and previous normal are retained. `BDF4BDE9` uses two position-seeded oscillators
with c100–c105 and origin c13. The tree paths reproduce native sparse table,
morph and wind constants in c95–c219, including input and UV semantic differences.
Small changes to native sine constants or arithmetic order changed coverage
under strict depth equality. Do not replace them with an approximately similar
formula. Weighted wind `926CF8E3` is not implemented.

### Visibility and opacity

Opaque replay uses hardware depth **EQUAL**, original cull/depth bias, viewport
depth range and clip-plane behavior. Relaxing equality globally leaks vectors
onto foreground surfaces. Capture late RGB-only material passes even after
MRT1 is detached if the exact main color and hardware depth still match; native
depth writes may be disabled in those passes.

Support the audited LOD cross-fade: depth-writing ADD with BLENDFACTOR and its
inverse, optionally read-only stencil (KEEP operations / zero write mask).
Stencil-writing or unfamiliar blend contracts are rejected.

Hair uses SRCALPHA/INVSRCALPHA ADD with depth writes off. Replay uses the native
LESS/LESSEQUAL visibility test and only opacity ≥ 0.5, selecting the dominant
layer. A single motion vector cannot describe all translucent layers.

The conservative pixel-bytecode parser recognizes texture alpha, material
constants, vertex alpha, saturation and multiplication order, with audited
UV0/UV1 and scale variants. Foliage `43C46BC2` also multiplies final alpha by
c30.x; omitting that factor caused missing bushes. Unknown discard or complex
opacity expressions are rejected. Always compare original pixel-shader alpha
coverage against the motion pass; matching vertex silhouettes is insufficient.

## 7. Changing vertex geometry: cloth and split streams

The original skinning-only approach missed CPU-deformed cloth. A later full
buffer snapshot approach also failed because the game rotates large buffers,
uploads small ranges and draws with nonzero base/min vertices.

Capture ReShade map/unmap callbacks and copy bytes **before Unlock**, while the
CPU mapping is valid. Never read a WRITEONLY GPU buffer or retain a mapped
pointer. The sparse cache handles DYNAMIC stream-0 buffers up to 4 MiB, 128
tracked buffers, 4 KiB pages and at most 512 valid ranges. DISCARD invalidates
old bytes; NOOVERWRITE adds valid ranges. Uncaptured uploads invalidate stale
ranges, and buffers untouched for more than three frames retire.

ReShade's generic indexed-draw event omits MinVertexIndex and NumVertices.
`native_draw.hpp` wraps **only DrawIndexedPrimitive, vtable slot 82**, recording
those arguments in thread-local state around the wrapper call. The wrapper is
obtained through ReShade's resource private-data GUID, not guessed engine
offsets. No Present/Reset or game-engine function is hooked. The hook is restored
on device destruction/addon detach, not while other owners still use its table.

Validate the actual native range, base vertex and stream offset against captured
bytes; retain an immutable GPU snapshot plus exact CPU bytes for pose comparison.
Do not assume index values are simply 0…vertexCount-1. Dynamic index buffers are
unsupported. Retain COM references so recycled object addresses cannot impersonate
last frame's mesh.

The game often stores current position/normal in stream 0 and static UV/color
in stream 1. Filter the declaration to required original inputs; keep stream 1,
and use stream 2 for previous deformation. Preserve previous weights, indices,
normal/binormal where the skin/displacement shader requires them. Assuming all
attributes occupied stream 0 caused the missing clothing and pink flashes.

## 8. Stable identity and matching

Draw order is not an object ID. Mesh keys include topology buffers/declaration,
layout, offsets/ranges and shader identity. Mutable stream-0 pointer/ring offset
is replaced with its validated immutable range identity so rotating uploads can
match. Static auxiliary inputs and topology still distinguish meshes.

Within a mesh group:

1. Collapse only duplicate submissions with identical world, camera, bones,
   procedural state and geometry bytes. Multipass cloth can be uploaded twice.
2. For a native mesh without mutable geometry, a single pose group in each
   frame is already unambiguous and can pair directly. The replay teleport
   guard still applies. This fast path does not impose the crowd step limit.
3. Otherwise prefer a uniquely matching unchanged world pose, or a
   **mutually unique** movement candidate within 0.25
   world units and rotation-element difference ≤ 0.35.
4. Reject overlap/ambiguity, missing meshes and jumps. Never assign by draw
   index or unconditionally pick the nearest member of a crowd.

Rigid shaders use only the first three world rows; unused c11 data must not
invalidate identity. CPU-deformed NPC clothes can have identical world matrices
because their positions are already world-space. A captured geometry centroid
supplies their spatial anchor; use double precision while accumulating it.
Large per-axis world changes over 16 units are rejected during replay as well.

Unmatched geometry writes the negative-depth marker. This deliberately resets
history for that surface and appears pink in the preview. Loosening identity
checks to suppress pink can silently apply another character's animation.
The last centroid correction passed synthetic reorder/ambiguity tests but did
not greatly reduce the user's remaining occasional flashes.

## 9. Resource budgets, failure and reset

| Allocation | At 3840×2160 | Guard |
| --- | --- | --- |
| Two RGBA16F histories + two R16F counts (20 bytes/pixel) | 158.2 MiB | 160 MiB |
| Above plus RGBA16F motion (28 bytes/pixel) | 221.5 MiB | 224 MiB |
| Previous-pose atlas | 2 KiB per allocated row | Power-of-two height, at most 2048 rows / 4 MiB |
| Geometry CPU pages + retained GPU snapshot bytes | Scene dependent | Combined 8 MiB accounting guard |

The geometry path also has a 16 MiB snapshot allocation guard; the combined
guard is normally tighter. CPU copies of retained geometry, vectors/containers,
shader caches and retained game-resource references are additional memory.
These guards do not make total process memory equal to the texture table.
The atlas is additional to the screen-sized texture guard, allocated only when
skeletal/tree draws exist and retained at its high-water size until reset/disable.

The resolver requires FP16 render targets, two MRTs with independent bit depths,
and the other native capabilities used by motion replay. Allocation/capability
failure retains the native scene or camera-only path; it must not force resource
upgrades. Failed resolve allocations stop jitter until reset/toggle recovery.

On swapchain destruction before native Reset, release all TAA default-pool
references, even if a draw occurred without a following Present. Preserve only
the wrapper hook identity and primitive topology needed after reset. Device
destruction releases data and restores hooks. Turning Object Motion off clears
its history/cache; a TAA mode change clears temporal resources/validity. These
paths must be tested with the **actual ReShade addon**, not only a native shader
unit test.

## 10. Diagnostics and failure signatures

Enable TAA Input Capture to see logs every 120 native frames. With Object Motion
Preview it also includes per-shader stages and bounded unmatched examples.

| Symptom / field | Interpretation / next check |
| --- | --- |
| `current=0` / `cameraConflict=1` | Camera anchor, depth identity, viewport or multiple scene passes |
| `jitterDraws=0` in settled Experimental | Previous valid frame, mode, failed resources, projection contract, main depth |
| `resolve=0` in a preview | Expected: previews are not valid accumulation history |
| Black object preview | No replay coverage: profile, opacity, state, uploads, occlusion or unsupported water |
| Pink object preview | Captured surface lacks a trusted previous pose; inspect matching, not just hash coverage |
| `motionStages` / `motionProfile[VS]` | First falling counter locates the capture rejection stage |
| `motionMatchMiss` | Missing mesh versus ambiguous pose counts |
| `mutableDraws`, `mutableMiss`, `geometryBytes` | Changing-vertex capture success and retained snapshot memory |
| `motionShaderCache`, `shaderParses` | Cached classifiers and parses during the reported frame |
| `paletteRows` | Allocated atlas height; only skeletal/tree draws consume rows |
| `cpuMs(capture,jitter,camera,motion,resolve)` | Mean CPU submission time per scene frame in the logging interval |
| `gpuSamples`, `gpuMs(motion,resolve)` | Completed asynchronous GPU timeline intervals; no flush or wait |
| `unmatched[VS]` | Current/previous mesh and same-world candidate counts |
| Static camera appears to move | Matrix precision/convention, jitter double subtraction, frame pairing |
| Distant edges pulse | Depth precision, edge depth ownership, rejection threshold or confidence reset |
| Cloth alternates black/pink | Partial upload ranges, ring identity, secondary streams, ambiguous instances |

Stage order: shader candidate → topology/instances → non-UP → hardware depth →
scene color → viewport/deconstruction → render state → pixel shader → opacity →
stream/buffer → filtered declaration → index/range → completed capture.

## 11. Verification evidence and limits

Local fixtures and capture artifacts live under
`tmp/asscreedeziotrilogy/taa/`; game dumps live in Brotherhood's `renodx-dev/dump`.
These scratch artifacts are not a portable test dependency or shipped binaries.
To reproduce on another machine, obtain original shader dumps and rebuild the
described native DX9 fixtures; do not use hand-reconstructed originals as an oracle.

Existing implementation verification:

- CPU camera tests: 100 transforms, singular/NaN rejection; double precision
  reduced stationary reprojection error from roughly 4.37e-4 to below 1e-12.
- Strict SM3 compilation; 264/277 CTAB projection contracts, truncation rejection
  and bounded jitter samples.
- Resolve GPU tests: preserve HDR 4.0, disocclusion/camera/viewport handling,
  previews, sampler/RT state restoration, late object depth and ResetEx.
- Static diagonal over 256 frames: settled oscillation 0.00195312, sample
  confidence about 127.94; mean error to the eight-phase reference about -0.00226.
  This is a synthetic edge, not a promise of perfect static in-game pixels.
- All 19 motion profiles compared to original CSOs: exact tested coverage,
  four-bone XYZ movement including high palette indices, both packed scales,
  mutable vertices, split streams, missing-pose behavior and state restoration.
- Wind/tree fixtures: 48 animated phases, native opacity over seven alpha
  thresholds, translucent dominant-layer coverage, stencil/LOD and occlusion.
- 392 previously captured real-pose/sloped-depth cases: 207,203 tested pixels,
  zero coverage mismatch in those fixtures. Sparse partial uploads and rotating
  4 MiB buffers validate bounded allocation/retirement.
- User testing of the embedded prototype confirmed substantial AA improvement
  and broad scene/cloth/hair/vegetation coverage, with occasional residual pink
  flashes. Water and the boat interior gap remain unresolved.

Extraction verification uses `test-split-resolve`, `test-split-motion` and
`test-split-capture` in that local scratch directory:

- New addon-only SDR A8R8G8B8 remains format 21; native X8R8G8B8 also passes the
  direct resolve test. Encoded and hardware-sRGB-decoded temporal blends and
  sampler restoration pass. This GPU does not support A8B8G8R8/X8B8G8R8 textures;
  those allocations are skipped rather than claimed tested.
- Actual ReShade loads only the TAA addon for the standalone test. Object
  Preview and Experimental work; settled Experimental logs five jittered draws,
  five matched mutable/late/LOD submissions, zero misses and valid history.
- Actual HDR+TAA addons pass in both load orders with the HDR LUT replacement
  registered. Both produce the same reference output, while standalone uses
  the original LUT. Native buffer and nonindexed UP draws agree.
- TAA Off with the HDR addon produces the same fixture readback as HDR alone.
- Native ResetEx passes with ordinary draws and partial uploads. UP draws are
  exercised after that reset, not across it: the installed ReShade's
  `resize_primitive_up_buffers` destroys a temporary buffer without clearing
  its handle on reset. A stress run using UP before/after reset hit that freed
  handle inside ReShade. This dependency issue was not patched by extraction;
  do not claim full UP/reset coverage. Indexed-UP also has a separate temporary
  index-buffer assignment defect in the inspected ReShade source. Section 30
  supersedes this extraction-time limitation with an addon-local workaround and
  tests that exercise UP draws both before and after reset.
- The user confirmed the split HDR+TAA pair works in Brotherhood gameplay.
  Performance remains under investigation; neither that report nor synthetic
  cooperation tests establish every scene or long-session behavior.

## 12. Remaining coverage and reuse in other games

Water VS `265E7205` / PS `659AB3BD` is outside the motion profiles. Its rigid mesh
does not describe animated normal-map reflections/highlights; opacity depends
on scene depth and vertex alpha. It needs audited coverage plus reactive history
weighting. Black water in Object Preview means absent object vectors, while
normal TAA still attempts camera reprojection. The rectangular boat-interior
gap has not been tied to a proven draw/visibility cause.

Other incomplete cases: dynamic indices, unknown/complex opacity, unsupported
wind, layered transparency/particles, ambiguous repeated meshes, LOD changes,
disocclusion, and jittered surfaces whose animation has no motion profile.
There is no general reactive mask, sharpening or temporal upscaler. The initial
native MSAA hybrid path is described in section 28. AC2/Revelations need their
own shader/layout audit.

For a new game, work in this order:

1. **Capture the pipeline.** Locate scene-before-UI/grade, prove its encoding,
   dimensions and producer/consumer identity. Include bloom, DOF, transparency,
   camera cuts, menus and dynamic resolution. Pick a stable pre/post hook.
2. **Prove depth and camera.** Disassemble/decompile original shaders. Identify
   matrix orientation, world packing and clip-depth convention; test known
   transforms and camera-only motion at large world coordinates before jitter.
3. **Implement lifecycle and identity resolve.** Allocate private bounded
   history, restore all state, test Off/native equivalence and graphics reset.
   Support multiple addons without replacing another addon's scene shader.
4. **Add camera-only accumulation and previews.** Confirm stationary zero
   motion, correct pan direction/scale, depth rejection and cut behavior.
5. **Add jitter separately.** Prove each projection contract and raster phase;
   keep it out of HUD/shadows/reflections. Audit matrix restore and double-jitter
   errors. Test a full phase cycle, not a single attractive screenshot.
6. **Validate convergence.** Test high-contrast near/far silhouettes, subpixel
   depth changes, brightness preservation, transport conversion and confidence.
7. **Start object replay with rigid opaque geometry.** Preserve exact native
   visibility. Build stable identity before skinning. Never infer identity from
   draw order or a broad nearest-neighbor guess.
8. **Port animation families one at a time.** Match original bytecode's positions
   and opacity on the GPU: bones, displacement, wind/morph, then mutable geometry.
   Audit palettes, weights, streams, min/base indices and upload lifetimes.
9. **Expand material coverage carefully.** Audit cutouts, stencil, LOD, late
   passes and dominant transparency independently. Add reactive rejection for
   shading motion that geometric vectors cannot express.
10. **Test real integration.** Both addon load orders, current defaults, standalone
    SDR, settings persistence, reset, long sessions, budgets and fallback paths.
    Record unsupported cases explicitly instead of turning all pink pixels gray.

Reusable ideas are the ordering, precision, explicit jitter convention, bounded
geometry retention and validation strategy. Hashes, constants, vertex packing,
opacity parser rules, insertion passes and matching thresholds are engine-specific
evidence and must be re-established for a different game.

## 13. CPU submission optimization — 2026-09-17

After confirming the split HDR+TAA addons worked together, the user measured
about 169 FPS with TAA off and roughly 70 FPS with it enabled: approximately
5.9 ms versus 14.3 ms per frame. FPS alone does not identify CPU/GPU ownership.
The resolve, skinning and motion-vector math already execute on the GPU; CPU
capture collects game draw state and identifies previous poses.

A native DX9 benchmark used 1,000 unique submissions at 64×32, 16 warmup frames
and 64 measured frames, with GPU completion outside the CPU timing window:

| Workload | Before | Batched upload |
| --- | --- | --- |
| 1,000 rigid draws, median CPU submission | 0.5695 ms | 0.5200 ms |
| 1,000 skeletal draws, median CPU submission | 8.2859 ms | 1.1411 ms |
| Skeletal submission p95 | 23.2384 ms | 2.0020 ms |
| Pose matching alone | About 0.21–0.24 ms | About 0.21 ms |

These synthetic numbers do not predict in-game FPS. The old per-draw
`LockRect(DISCARD)`/upload/Unlock sequence incurred substantial driver cost.
The optimization reduces measured skeletal submission time by about 86%:

1. **Batch previous palettes.** Validate matching and teleports first. Write
   previous palettes to separate atlas rows using the native pitch; unlock
   once per replay pass. Missing history uploads current bones and retains
   the negative validity marker. The vertex shader selects its row with c24.x;
   rigid draws do not advance this index. Skinning and visibility math stay intact.
2. **Set invariant replay state once.** Stream frequencies and stencil KEEP/
   write-mask state are shared. Material-dependent tests, culling, depth,
   viewport and opacity still apply per draw.
3. **Keep material classification cached.** Instead of clearing all 256 entries
   when full, retain up to 2048 and evict the least recently used entry. A
   300-material regression parses each shader once across repeated frames;
   the capacity test verifies hot entries survive individual eviction.
4. **Measure without synchronization.** TAA Input Capture enables CPU scopes
   and a four-slot GPU query ring. Poll without `D3DGETDATA_FLUSH`, spin loops
   or waits. Skip a sample if all slots are pending. Query failure disables
   GPU timing independently of TAA. Diagnostics Off releases its queries.

CPU timings include driver time inside the scopes. GPU timestamps measure
timeline intervals, including possible CPU submission gaps, not a GPU-busy
percentage. CPU/GPU work overlaps; do not add them to predict frame time.
Capture timing includes draw-triggered immutable geometry snapshots. Map/unmap
callbacks and work outside these scopes are not a complete process profile.

Validation: strict SM3 compilation, final Release original-shader coverage for
all 19 profiles, distinct atlas rows with mixed rigid/animation draws, 3/17/65
row workloads, growth and reuse, missing/teleported poses, both tree families,
pitched upload, state restoration, cache limits and reset pass. Actual Release
HDR+TAA integration captures/matches all five partial-upload/late/LOD submissions
after ResetEx, with zero warm shader parses and asynchronous GPU samples.
Local evidence under the existing scratch directory: `performance-before.log`,
`performance-after-atlas.log`, `atlas-release-validation.log`,
`performance-metrics.log`, and `split-integration/performance-release.log`.
The first rebuilt atlas/cache version still measured about **140 FPS Off versus
74 FPS with Experimental TAA and Object Motion** in the user's gameplay test.
The synthetic skeletal improvement did not solve the full-frame bottleneck.

With Input Capture enabled, a stationary 3840×2160 gameplay sample contained
1,017 captured draws (946 rigid, 71 skeletal), no unmatched poses, and 1,058
jittered draws. Average instrumented CPU times were capture 1.10 ms, jitter
0.54 ms, camera 0.003 ms, motion submission 1.18 ms and resolve submission
0.031 ms. GPU timeline intervals were about 0.77 ms for motion and 1.34–1.47 ms
for resolve. The 46-entry material cache was warm with zero parses, so cache
thrashing was not the bottleneck in this particular view. These intervals
overlap and exclude parts of the game/driver/proxy; do not sum them as frame cost.

The next optimization reduces calls inside motion replay without changing draw
order, visibility or matching:

- Upload contiguous VS c18–c24 and PS c0–c7 controls together.
- Retain the last submitted vertex shader, declaration, streams, index buffer,
  world matrix, viewport, alpha texture/sampler and raster values within this
  pass. Submit only changed values. The first draw always sets its state, and
  the captured game state is still restored after the pass.
- Skip camera reprojection for covered object pixels during the resolve;
  preserve camera reconstruction for uncovered pixels and Camera Motion Preview.
  Depth derivatives remain outside the branch. Invalid object history still
  rejects accumulation, and no sample/quality settings change.

All 19 original-shader motion/coverage regressions, batched palette equivalence
and resolve convergence tests pass with these changes. A paired 4K old/new
resolve comparison produces **identical full-frame FP16 readbacks** for camera
only, fully covered objects and mixed valid/invalid/uncovered tiles. Its isolated
GPU medians are roughly 0.17–0.18 ms for both versions; this does not establish
a meaningful GPU speedup or predict the live 4K scene's cost. Evidence:
`performance-state-cache.log`, `atlas-state-cache.log`,
`resolve-reprojection-fastpath.log` and `resolve-performance.log`.
Release SHA-256 `F2B6F44CBD8B408DD70B7AE83C1B9DCB22E178B99BEA9AC2270DB62BD425DE28`
is built and linked to Brotherhood. Its final shader embeds pass the atlas/
coverage regressions, and the real HDR+TAA addon fixture retains five matched
draws, jitter/history and identical buffer/UP output after ResetEx. Evidence:
`atlas-state-cache-release.log` and
`split-integration/performance-state-cache-release.log`.
The user reported a small gameplay performance improvement, then deferred
further FPS optimization to prioritize motion smearing. No controlled final
FPS comparison was supplied.

## 14. Motion clarity without losing stationary convergence — 2026-09-17

Object vectors correct where history is fetched, but the old resolve still
bilinearly resampled that already-filtered history every frame. This repeatedly
removed moving texture detail. Its linear interpolation from 128 to 10 samples
also retained about 104 samples at 0.1 pixel/frame, delaying fresh information
even during visible slow motion.

`taa_resolve.ps_3_0.hlsl` now applies two changes:

- **Cubic history reconstruction.** `SampleHistory` evaluates a separable
  Catmull-Rom kernel. It combines the two positive middle weights on each axis
  into bilinear taps, evaluating the full 4×4 support with nine texture reads.
  Existing min/max/variance directional clipping bounds the reconstructed RGB
  and rejects overshoot. Only RGB uses this filter: depth and sample count
  retain point sampling, and invalid history never reaches this reconstruction.
- **Motion-responsive confidence.** The reciprocal formula in section 5
  caps history at about 30.5 samples at 0.05 px/frame, 17.3 at 0.1, and 14.2 at
  0.125. It floors the motion cap at 8; variance disagreement can still reduce
  it further. Exactly stationary surfaces keep the 128-sample cap. There is
  no sharpening pass, jitter-sequence change or relaxed depth/matching test.

The moving-detail regression compares the prior Release shader with the new
shader on native DX9. It renders an analytic textured surface and repeating
diagonal edges for 192 frames, with the real eight-phase jitter, at 0, 0.05,
0.125 and 0.5 pixels/frame. Both camera-only and valid object-vector paths are
tested. Measurements exclude the first 64 frames and image borders.

| Speed (px/frame) | Detail RMSE old → new | Moving-edge temporal error old → new |
| --- | --- | --- |
| 0 | 0.01076 → 0.01076 | 0.000333 → 0.000333 |
| 0.05 | 0.10007 → 0.04075 | 0.00769 → 0.00617 |
| 0.125 | 0.10927 → 0.03337 | 0.01774 → 0.01388 |
| 0.5 | 0.08424 → 0.02927 | 0.05440 → 0.04592 |

Temporal error measures frame-to-frame changes of the residual relative to a
moving antialiased reference, so expected scene movement is not counted as
flicker. All values are synthetic test results, not gameplay measurements.
Stationary outputs match the old shader; the previous distant-edge regression
also retains its 0.001953 settled swing and ~127.94 sample confidence. Native
SDR/HDR behavior, invalid motion, depth rejection, previews, state restoration
and reset tests pass. Evidence: scratch `test-smearing.cpp`,
`smearing-validation.log` and `resolve-smearing-regression.log`.

The cubic filter adds eight history texture reads for accepted history; it adds
no texture allocation or CPU capture work. Further performance tuning is
deferred at the user's request. Real gameplay smearing/edge quality still needs
verification after deployment; this does not solve unsupported water/shading
motion or ambiguous object identity.

Release SHA-256 `005830373F56E9B51062BFE0ACD5926931ACE23FF9556CA366754248D0904EE1`
is built and linked. Repeating the motion tests using the exact Release embeds
preserves the results above (`smearing-release-validation.log`). The final
resolve rejection/SDR/state tests pass (`resolve-smearing-release.log`), and
the actual HDR+TAA fixture preserves five matched draws, jitter, history and
buffer/UP equivalence through its ResetEx check (`split-integration/smearing-release.log`).

Background references: [Intel TAA resolve](https://github.com/GameTechDev/TAA/blob/main/MiniEngine/Core/Shaders/TAAResolve.hlsl)
and [A Survey of Temporal Antialiasing Techniques](https://diglib.eg.org/server/api/core/bitstreams/53732e70-b64d-46f4-bbae-865eb7673a35/content)
discuss sharper history reconstruction to counter repeated resampling blur.

## 15. Stationary sloped edges and AC3 Remastered comparison — 2026-09-17

The user confirmed improved motion clarity, but some distant building edges
still flickered while stationary. Disabling object motion improved this only
slightly and increased ghosting elsewhere; keep object motion enabled.

A native DX9 regression reproduces history resets when jitter and nearest-depth
selection sample different points on a sloped surface. Derivatives of the
selected minimum can flatten into plateaus, underestimating the original
surface slope. On the synthetic roof edge, history averaged only 4.5 samples.

The resolve now retains the already-fetched 3x3 depth neighborhood and checks
its three rows and columns for linear depth runs. A run is accepted only when
all three depths are below sky depth and its second difference is at most
`max(2e-7, abs(endpointDifference)*0.1)`. Half the endpoint difference estimates
axis slope. Twice the summed axis slopes, capped at 4% of expected complement
depth, can extend the existing depth tolerance. A discontinuous depth step
fails this check. No jitter, motion-confidence, history filter or RGB clipping
settings change.

Broadly doubling the old depth allowance was rejected: it improved the roof
but worsened moving, closely spaced foreground/background boundaries. The
qualified version preserves identical regression metrics on depth gaps of
1%, 3%, 6% and 20%, at 0.125 and 0.5 px/frame, with camera and object vectors.
On the stationary sloped diagonal, mean confidence rises to ~112 over frames
64–191 and temporal residual error falls from 0.01888 to 0.00876 (camera) and
0.01871 to 0.00849 (object). Isolated subpixel stripes without a coherent
three-tap run remain unresolved. These are synthetic results, not proof that
all reported gameplay edges are corrected.

The previous motion-clarity, stationary convergence, depth rejection, SDR/HDR,
preview, state-restoration and ResetEx fixtures pass. Scratch evidence:
`flicker-planar.log`, `flicker-planar-disocclusion.log`,
`flicker-planar-regression.log`, and `flicker-planar-smearing.log`.
FXC reports 709 slots versus 611 for the preceding resolve, with the same 38
texture instructions. Native GPU shader creation succeeds; no CPU capture work
or texture allocations are added. Gameplay performance and appearance still
need verification after the Release rebuild.

### AC3 Remastered reference

The local `asscreed3remastered/dlss.hpp` motion prepass implements a special
neighborhood selection, documented there as matching native TAA behavior. It
compares motion at minimum and maximum depth in a 3x3 footprint. If their
separation exceeds two pixels, it selects motion from a 2x2 quadrant directed
by jitter sign instead. Otherwise it uses the minimum-depth neighborhood
vector (described there as far depth). This is a useful reference for moving
foreground/background boundaries, but its motion-disagreement trigger does
not address stationary near-zero-vector roof history resets. Brotherhood's
depth convention must also be respected before porting it. No AC3 code was
changed or blindly copied, and native AC3 shader bytecode was not independently
audited in this investigation.

Release deployment: SHA-256
`CBB9AE3149CC228A5D9BBE98E3BA9B8E1AA92C021E32D70E0A77D0F0BE779FD8`
was built with `clang-x86-release` / `asscreedbrotherhood-taa` after Brotherhood
closed; its existing game-folder link points to this artifact. Exact Release
embeds reproduce the measurements above and pass motion clarity, disocclusion,
resolve/state and HDR+TAA ResetEx integration checks. Evidence:
`flicker-release-{flicker,smearing,disocclusion,regression}.log` and
`split-integration/flicker-release.log`. Gameplay comparison is pending.

## 16. Remaining stationary silhouettes: confidence diagnostic — 2026-09-17

After section 15 the user still reports stationary roof/chimney silhouette
flicker. Live logs show identical camera matrices, valid consecutive history,
zero unmatched poses and no unsupported jitter draws. This rules out the
observed global failure counters, but does not prove per-pixel history reuse.
Do not treat the synthetic roof improvement as a complete gameplay fix.

Diagnostics → History Confidence Preview is an independent, default-off toggle
used with Experimental TAA. The regular resolve still runs with its original
motion, jitter, depth and color decisions. A second diagnostic draw reads the
completed sample-count texture: red <1.5 (reset), yellow <8, cyan <32, green
otherwise. Display colors still pass through the game's LUT/color grade.

The second draw reuses the now-dead previous history texture as display scratch.
All sampler aliases are unbound before it becomes a render target. Current RGB,
depth and counts remain intact; the next frame overwrites the scratch texture
while reading that untouched current history. This adds no texture allocation
or readback and only adds a fullscreen draw while enabled. Failure to render the
preview falls back to displaying the completed normal resolve.

Native GPU tests toggle the preview throughout stationary and moving camera and
object-vector cases and assert exact equality of resolved RGB and counts against
normal mode. They also verify the selected display texture, state restoration,
depth rejection, supported SDR formats and ResetEx. Scratch evidence:
`confidence-validation.log` and `confidence-state.log`. This is diagnostic
instrumentation, not yet a fix for the remaining reported silhouettes.

The diagnostic Release is built and linked, SHA-256
`DEB50CCFB9BB81EE52069519D16B8B02ED87AEC1E26A0FC04B2D3C3BBF7D8DB4`.
Exact Release validation and state checks pass (`confidence-release-validation.log`,
`confidence-release-state.log`), as does normal-mode HDR+TAA replay/reset
integration (`split-integration/confidence-release.log`). Live confidence
inspection at the reported silhouettes remains pending.

## 17. Stationary silhouette color bounds — 2026-09-17

The user observed yellow confidence on the flickering roof/chimney edges.
Yellow proves fewer than eight retained samples, but by itself does not
separate recent depth resets from variance-driven confidence loss.

A separate regression with constant depth isolates color rejection: a stationary
half-pixel bright line, rasterized with the real eight-phase jitter, flickers
with the previous shader despite valid depth and motion. The 3x3 variance bounds
were measured from bilinearly reconstructed taps. Their variance shrinks with
jitter phase and clips valid accumulated coverage. Sampling those bounds at
raster texel centers reduces temporal residual error from 0.006931 to 0.000309
and RMSE from 0.024699 to 0.018738 in this test. These are synthetic measurements;
live verification at the reported edges is still required.

Unconditionally using raster-centered bounds was rejected because it increased
flicker on one slowly moving diagonal test. The final candidate removes jitter
from motion first, then interpolates the bounds sampling coordinate from the
raster texel center at rest back to the previous reconstruction coordinate at
0.05 pixel/frame. There are no depth-tolerance, history-weight or jitter changes. FXC emits
40 texture instructions versus 39 for the diagnostic baseline: the new bounds
center no longer shares the current-color tap. No textures are allocated. Current color remains reconstructed
on the unjittered output grid. Existing moving bounds apply at and above the
threshold, retaining the prior anti-smearing behavior.

Evidence: `raw-bounds.log`, the rejected `raw-motion-validation.log`, and the
qualified direct-current-Release comparison `raw-motion-qualified.log`.


Release SHA-256 `338D2F97BEC38C1C25BCFA24BF97B7341DBBD73B3E3AF7B142F36C73522320D7`
is built and linked after Brotherhood closed. Exact Release regressions pass
for three patterns at 0, 0.005, 0.01, 0.025, 0.05, 0.125 and 0.5 px/frame with
camera/object vectors, and for foreground/background depth gaps of 1/3/6/20%.
Evidence: `raw-release-raw-motion.log`, `raw-release-disocclusion.log`,
`raw-release-state.log` and `split-integration/raw-bounds-release.log`.
Gameplay comparison remains pending; yellow confidence alone was not treated
as proof that the live issue has this single cause.

## 18. Reject the raw-bounds experiment; isolate rejection causes — 2026-09-17

The user reports section 17 did not help and looked worse overall. The raw-bounds
change is reverted completely, including its motion transition. Synthetic
improvement was not predictive of this gameplay scene. Current bounds, confidence
weighting and jitter again match the pre-experiment diagnostic Release.

History Confidence Preview now offers Off / Confidence / Rejection (old saved
On=1 remains Confidence). Rejection shows blue for depth rejection, red for
other resets, magenta for color clipping above `signal*1e-4`, and green for
accepted history. Colors describe this frame, not a persistent diagnosis: watch
whether they alternate. Color clipping can coexist with high confidence; this
view identifies clipping, not necessarily the dominant cause of instability.

The sign of the existing R16F count stores diagnostic information: -1 for depth
reset, +1 for other reset, negative accumulated counts for color clipping.
All temporal count reads use the absolute value, preserving exact magnitude,
weights and precision. The second display pass reads the sign; no new resource
or readback is added. Section 16's buffer reuse still applies.

Exact Release comparisons against the pre-raw-bounds shader match RGB and count
magnitudes across stationary and moving camera/object tests while toggling both
previews. Native tests verify all four reason colors, state restoration and
ResetEx; HDR+TAA integration passes. Evidence: `rejection-release-validation.log`,
`rejection-release-state.log`, `split-integration/rejection-release.log`.
Built and linked Release SHA-256:
`2B55D8AC9EC9F3177E30E1B8E9BE7A532A383DF7F0F0D854551C24F81B01F176`.
Remaining roof/chimney flicker is unresolved; live Rejection preview is the next
step before changing acceptance rules again.

## 19. Capture actual resolve inputs before more rejection changes — 2026-09-17

The user confirms the same blue/magenta edge behavior with object motion on and
off. This directs investigation toward the shared resolve, not exclusively the
object-motion depth path. No new acceptance/filtering fix is introduced here.

Diagnostics → Capture Resolve Frame → Capture Once saves one Experimental frame
under the game's `renodx-dev/taa-capture/<pid-counter>/` and returns to Idle.
It explicitly stalls for readback and disk writes; at 4K with FP16 scene and
object motion it writes about 316 MiB. One temporary system-memory surface is
allocated at a time (largest ~63 MiB at 4K), then released. Normal input logging
never activates it. It can run with either confidence or rejection preview:
capture occurs after the real resolve, before the second display draw overwrites
old history. All capture failures leave normal rendering active and log a warning.

`capture.txt` version 1 records source sRGB state, the 24 floats in c0–c5, and
width/height/D3DFORMAT/bytes-per-pixel per texture. `.bin` files contain native
little-endian tightly packed rows, excluding driver pitch: scene, native depth,
previous color/depth history, previous signed counts, optional object motion,
resolved color/depth and resolved counts. `resolve.cso` preserves the actual
bound authored shader. Only manifests ending in `complete` are valid captures.

The isolated capture and replay fixtures reproduce exact RGB/depth and signed
count output, including a nonzero-jitter silhouette against sky. They verify
render-state restoration and ResetEx after capture. Successive captures use
process id plus QueryPerformanceCounter timestamps to avoid tick-resolution
folder collisions. Scratch tools: `test-capture.cpp`, `test-capture-replay.cpp`;
results in `capture-validation.log`. The real failing frame remains to capture.

Release SHA-256 `ACF2AEA4BB39244B17B031190F314C562126E512FE80DDD7702E4975AF8C3AB5`
is built and linked after the game closed. The actual HDR+TAA Release fixture
completed the one-shot capture and passed replay/state/ResetEx integration
(`split-integration/capture-release.log`). Its saved buffers also replay exactly
against the saved output and signed counts. The bound shader dump matches the
compiled shader. Awaiting capture of the user's real failing scene.

## 20. Real-frame stationary boundary depth validation — 2026-09-17

Capture `37792-559155837566` is 3840x2160 with an effectively identity camera
reprojection. Baseline native replay reproduces every output byte and signed
count byte exactly. It contains 67,067 depth-reset pixels. Inspection of roof
and chimney samples finds depth differences of tens to hundreds of percent:
jitter swaps the dilated nearest surface between adjacent foreground/background
surfaces, while a matching historical depth exists one pixel away. These are
not small same-plane errors; simply enlarging slope tolerance is inappropriate.

After the usual depth check fails, an additional stationary-boundary path now
requires all of the following:

- Valid object motion is available and the camera reprojection matrix is within
  1e-6 per element of identity (c5.x=2; c5.x=1 still means moving-camera motion).
- The old center depth exists in the current 3x3 depth footprint, within the
  original base tolerance `max(2e-6, complementDepth*0.005)`.
- The expected current depth exists in the historical 3x3 depth footprint using
  the same base tolerance.
- Every current footprint sample has a valid matched pose or is native sky, and
  every motion magnitude is below 0.001 pixel/frame. Uncovered non-sky and
  invalid poses fail closed. Camera-only mode keeps the original rejection.

Only then does it reuse the center history color and count through the unchanged
color-clipping and confidence logic. It does not borrow adjacent history color,
change stored depth, relax depth tolerance globally or change jitter. A 0.01 px
stationarity threshold was rejected because a 0.005 px animated-boundary test
showed excess history retention. At 0.001 the tested moving cases are unchanged.

On the captured frame the final candidate reduces depth resets from 67,067 to
55,348 (11,719 accepted). In rows 400–1150 they decrease from 32,865 to 25,787.
Every pixel that previously passed depth validation remains byte-identical;
stored depth is unchanged everywhere. This is a single-frame acceptance result,
not a measured gameplay flicker reduction or proof that all edges are solved.

Native tests cover stationary-camera animated boundaries with 1/3/6/20% depth
gaps at 0, 0.005, 0.02 and 0.125 px/frame, plus moving-camera cases, seed/history,
invalid motion, SDR formats, state restoration and ResetEx. Scratch evidence:
`live-replay.log`, `inspect-depth-rejects.py`, `compare-footprint.py`,
`footprint-performance-metrics.log`, `footprint-disocclusion.log`,
`static-camera-boundary.log`. Shader Model 3 register pressure required bounded
loops and explicit-LOD reads in the exceptional path instead of fully unrolling
all checks. Extra depth/motion/history reads run only on eligible rejected
pixels; no new textures or capture work are added to normal rendering.

Final Release SHA-256
`573E9F2AB12A2D4E17AE508107124F30E2D20192242532BA50C818C92A6F5E27`
is built and linked. Exact Release replay preserves the 11,719-pixel result;
state/invalid-motion/reset checks pass (`footprint-release-state.log`), as does
HDR+TAA integration (`split-integration/footprint-release.log`). The stationary
moving-boundary fixture passes (`footprint-release-boundary.log`). Invalid
covered poses are excluded even when native depth behind them is sky. Live
appearance and performance remain to verify; unsupported/ambiguous and other
rejected edges deliberately retain the original fallback.

## 21. Object-motion CPU submission optimization

The reported 138 FPS with object motion off versus 84 FPS on corresponds to
about 4.66 ms additional frame time. A live diagnostic sample measured roughly
1.18–1.30 ms capture, 0.69–0.72 ms motion submission and 0.29–0.33 ms GPU motion
pass time. These scopes do not explain the entire frame-time difference, and
GPU timings include submission gaps rather than measuring GPU utilization.

This iteration retains draw coverage, replay order, eligibility, shader math,
jitter and temporal weights. Capture reads c0–c18 in one native call instead of
three separate clip/world/clip-plane reads (two fewer driver calls per draw).
Replay skips unchanged clip matrices, vertex/pixel controls and bone palettes;
all caches start empty each pass. Wind writes invalidate the bone cache because
c100/c140 overlap palette registers; switching tree/skin layouts also uploads.
Pose matching groups entries in a reserved unordered_multimap, eliminating the
separate per-mesh index-vector allocations while retaining duplicate-pose and
mutual-match rules.

Native 1,000-draw CPU submission microbenchmarks, including matching, decreased
from 0.3574 to 0.2444 ms for repeated rigid draws and from 0.9671 to 0.6565 ms
for repeated skinned draws (median, 64 measured frames after 16 warmup frames).
These synthetic repeated-state workloads demonstrate reduced submission cost;
they do not predict a 32% whole-game FPS gain. Randomized matching agrees with
the previous implementation for 3,000 pose sets. Native coverage/vector/state/
reset regressions pass, including palette → wind → palette sequences with exact
output equality. Scratch evidence: constants-before.log, constants-final.log,
constants-mixed.log and test-match-equivalence.cpp under tmp/asscreedeziotrilogy/taa.

Release SHA-256
`8550371C46E6C6CCE435DA37F9A635FAC74D3551E52359D0A130F09988C1D6E5`
is built with clang-x86-release and linked to Brotherhood. Exact Release shader
regressions and the actual HDR+TAA addon integration fixture pass, including
native capture/replay and ResetEx (constants-release.log in the scratch root
and split-integration). Same-scene gameplay FPS comparison remains pending.


## 22. Avoid reading discard upload mappings

User retest of section 21: about 144 FPS object motion off, 88 on, and 166 with
TAA entirely off. Process-only instruction samples identified memcpy inside
GeometryCache::Unmap as a large render-thread hotspot that the earlier capture
scopes omitted. Of 500 render-thread samples, 151 were in this addon, 127 at
one memcpy instruction. A second stack sample and disassembly located its
caller in the page-copy loop (return RVA 0xE0A6 in section 21's Release).
These are wall-time samples including waits, not CPU utilization percentages.
System WPR sampling was unavailable due to a profiling-privilege failure.

For dynamic WRITEONLY DISCARD vertex-buffer locks, the map callback now returns
a cached CPU shadow pointer. Before the native Unlock, the addon copies those
application-written bytes forward to the original driver mapping; animation
pages are captured from the CPU shadow instead of reading the driver mapping.
Old contents are undefined on DISCARD. Non-discard and non-WRITEONLY locks keep
their original pointers and semantics. The ReShade DX9 map callback exposes the
actual returned pointer, and its unmap callback runs before native Unlock.

Shadows are retained per buffer, charged to a separate global 4 MiB cache cap,
and freed on retirement/reset. If the cap is exceeded, the existing direct
capture path remains. This does not drop draws, alter motion matching, jitter,
resolve weights or formats. Diagnostic cumulative uploadBytes(redirected,direct)
and retained uploadShadowBytes identify whether real gameplay takes the fast path.

A native 1 MiB DISCARD game-write plus capture microbenchmark (32 samples after
8 warmup frames) decreased from 3.4518 ms to 0.4691 ms median. This isolates
upload memory handling and is not a whole-game FPS claim. Rotating-buffer tests
verify exact bytes in both the original driver mapping and motion snapshots,
partial-range validity, shadow retirement and allocation accounting. Existing
native material/vector/state/reset tests also pass. Evidence lives in scratch
sample-cpu.ps1, sample-stacks.ps1, cpu-samples.csv, cpu-stacks.csv and
upload-shadow-tests.log. Release deployment and live performance remain pending.

Release SHA-256
`5A4459F2521B97BE42E94492C4945D81E3207BFDC916D70B4A649B6F9C254CC9`
is built with clang-x86-release and linked to Brotherhood. HDR+TAA integration,
partial uploads and ResetEx pass (split-integration/upload-shadow-release.log).
The integration log confirms both redirected and direct upload paths execute.
An initial integration failure exposed ReShade's UP emulation map events: they
supply pre-existing CPU vertex data instead of a native Lock mapping. Redirection
is therefore limited to application-created buffers carrying ReShade's device
wrapper private-data marker. Both DrawPrimitive and DrawPrimitiveUP now produce
the expected RGB 0.503418. Live gameplay FPS and appearance remain to verify.

## 23. Preserve and stage known non-discard ranges

Live retest still reported roughly 140 FPS TAA off, 120 object motion off and
79 object motion on. The section 22 optimization was active but covered only
about 8% of captured bytes (59,572,224 redirected versus 684,984,656 direct in
one cumulative sample). A fresh 200-sample render-thread capture contained
58 addon samples, 49 at the memcpy hotspot. Optimizing DISCARD alone therefore
left most expensive reads intact.

Map now also redirects non-discard application mappings when the complete
locked range is already in valid_ranges. It initializes the CPU shadow from
those cached pages before returning it, preserving application reads and bytes
left untouched by partial writes. Unlock copies the full locked shadow to the
original mapping and updates the cache. Unknown/gapped ranges, non-WRITEONLY
resources, UP emulation buffers and exhausted budgets retain the original path.
No buffers are assumed valid merely because pages exist. DISCARD still clears
valid_ranges, and existing reset/resource-retirement logic removes stale data.

Native tests exercise an unaligned range crossing a page boundary, two-byte
edits with unchanged prefix/suffix, byte equality in the driver mapping,
immutable prior snapshots, and fallback when even one byte was never captured.
Motion/vector/coverage/reset tests and addon syntax compilation pass. In a
1 MiB repeated normal-lock upload microbenchmark, median game-write plus capture
fell from 2.9293 to 0.0703 ms after warmup; DISCARD measured 3.2094 versus 0.3397 ms.
These are isolated tests, not gameplay FPS predictions. Scratch evidence:
upload-known-range-tests.log and the current cpu-stacks.csv. Release deployment
and gameplay validation remain pending.

Release SHA-256
`B938B7DF3E082DA226D4F4757C916E585177CE10A2A0BAED0219F4CC4B4D05F0`
is built with clang-x86-release and linked to Brotherhood. Actual HDR+TAA addon
integration passes partial-upload ResetEx and DrawPrimitive/DrawPrimitiveUP
scene equivalence, both RGB 0.503418. Evidence:
split-integration/upload-known-range-release.log. Gameplay performance remains
to verify in the same scene with Object Motion off/on.


## 24. Addon rename and user controls (2026-09-18)

The folder, CMake target, metadata id and configuration prefix are now
asscreedbrotherhood-taa. The distributed file is
renodx-asscreedbrotherhood-taa.addon32. Remove the former
renodx-acbrotherhood-taa.addon32 when installing it, to avoid two TAA instances.
The old configuration namespace is deliberately not imported: new defaults are
TAA on, object motion, debug off. Historical build hashes above remain unchanged.

Visible controls are TAA/TAA (Off, On), TAA/Motion Vectors (Camera Motion,
Object Motion) and Debug/Debug View. The six debug choices map as follows:

| Debug index | Label | Internal resolve mode | Confidence preview |
| --- | --- | --- | --- |
| 0 | Off | 1 (accumulation) | 0 |
| 1 | Depth | 2 | 0 |
| 2 | Camera Motion Vectors | 3 | 0 |
| 3 | Object Motion Vectors | 4 | 0 |
| 4 | History Confidence | 1 | 1 |
| 5 | History Rejection | 1 | 2 |

TAAEnabled=0 overrides every debug choice with mode 0. TAAMotionSource=0 uses
camera motion; 1 includes object motion. TAADebugView selects the table above.
Settings map to internal modes at Present, preserving frame-boundary history
reset and jitter behavior. Object Motion Vectors forces capture for that view
without changing the saved motion-source preference. History diagnostics keep
normal accumulation active; depth/vector modes retain the existing non-jittered
preview behavior. No temporal math, shader code or upload optimization changed.
TAAInputCapture and TAADumpResolve remain hidden developer configuration keys.

Release SHA-256
`36141AF9F1CA61880FEF91A8A3A8B8262C7CBD4F1BE944E31DBCC0037E6F37DC`
is built and the game folder has only the renamed TAA symlink. The three
HDR+TAA integration runs pass native ResetEx and immediate/buffered draw output
checks: defaults (5 object draws, 5 jittered draws, resolve=1), camera-only
(0 object draws, 5 jittered draws, resolve=1), and TAA disabled with debug index 5
(0 object draws, 0 jittered draws, resolve=0). Scratch logs are
split-integration/rename-{defaults,camera,disabled}.log and corresponding
-reshade.log files. Metadata parses successfully. Overlay appearance and all
six slider positions remain to inspect in live gameplay.

## 25. Combined motion diagnostics and the rooftop scene (2026-09-18)

A 1,703-draw DevKit snapshot and live resource readbacks showed black chimney
bases in Object Motion Vectors but complete chimney geometry in native Depth.
The sky was likewise absent from raw object coverage. These surfaces already
reach the resolver's camera/depth fallback; raw object texture coverage alone
cannot diagnose missing final motion. Captures: tmp/asscreedbrotherhood/
sky-scene.png, sky-native-depth.png and sky-current/preview analysis files.
The original motion-only readback was overwritten when the user selected Depth;
the native-depth and normal scene images remain separate.

Appended debug choices 6/7 are Combined Motion Vectors and Motion Source. Their
internal display modes are 7/8. Both use the real resolver's native/object depth
selection, nearest-depth dilation, object validity and camera fallback, including
current jitter. Only display velocity removes intentional raster jitter. Green
source = object replay, cyan = native geometry camera fallback, blue = native
sky camera fallback, magenta = no valid reprojection. The colors identify a
source/validity decision, not guaranteed correctness on unsupported animation.

The normal resolve runs first and retains its history/count output. A separate
SM3 diagnostic shader renders into dead previous-history storage; no new full
resolution texture is allocated. The additional shader is created lazily, and
the second draw exists only when a diagnostic is selected. Its source includes
taa_resolve.ps_3_0.hlsl with TAA_MOTION_PREVIEW so selection math is shared.
Putting both diagnostic branches directly in the accumulation shader exceeded
SM3 temporary registers. Splitting compilation keeps normal resolve disassembly
identical (resolve-before.asm versus resolve-after.asm) and avoids extra normal
rendering branches. All upload staging and replay optimizations are unchanged.

Native GPU tests cover static geometry, sky, eight-pixel object movement,
invalid covered poses and eight-pixel camera motion at nonzero raster jitter.
They compare actual history and counts with diagnostics off over consecutive
frames and verify source/vector colors and ResetEx. All pass in
motion-preview-tests.log. Original shaders B47DA314, EA5C66F8, 2153CA7C,
39782D3C and 65014F8B were inspected/decompiled in scratch; no new replay profiles
were added just to fill black pixels when native depth already covers them.

Static replay elision remains future work. A conservative classifier must prove
an immutable mesh, unchanged world pose, matching scene camera/projection,
no bones/cloth/wind/displacement, valid native MRT depth coverage and compatible
viewport/depth-write/raster rules. Late depthless materials, newly seen or
ambiguous instances and independent movement must retain replay/fallback guards.
Skipping draws also changes the coverage/validity mask used by stationary edge
history acceptance, so both depth and rejection behavior need regression checks.
A shader hash or a material that merely looks like a building is insufficient.

Release SHA-256
`3363168BBCED78E76CBD8999E9D9D6A665B86FB3A10538A56FD079274D2CBC47`
is built with clang-x86-release and verified through the existing game-folder
symlink. The HDR+TAA integration fixture passes ResetEx and buffered/immediate
draw equivalence (split-integration/combined-motion-release.log). The motion
diagnostic fixture also passes using the exact Release shader embeds, including
unchanged history/counts and reset (motion-preview-release-tests.log). The two
new views remain to inspect in live gameplay; no FPS improvement is claimed for
this diagnostic-only change.

## 26. Static replay filtering, sky motion and one preview (2026-09-18)

This supersedes section 25's deferred static-replay work and eight debug choices.
Object Motion now combines camera reprojection with replay only where the draw
cannot be confirmed static. Capture and pose matching still run for rigid draws;
the saving is in native replay submissions and their shader/state/geometry
bindings. No in-game FPS gain has been measured yet. Existing animation atlas,
shader cache, constant batching and redirected cloth uploads remain in place.

### Static eligibility and transitions

Capture records a candidate only when all of these hold:

- An audited rigid position profile, no bones, wind, tree deformation,
  displacement, mutable vertex snapshot or translucent coverage.
- The actual native R32 scene-depth texture is attached as MRT1, red writes
  and hardware depth writes are enabled, blending is disabled, depth bias is
  zero. The existing viewport-validity guards remain, but native clip depth in
  MRT1 precedes viewport depth mapping: MaxZ does not need to equal 1.
- Pixel bytecode proves COLOR1.r receives clip z/w from the matching vertex
  color semantic. The existing cached SM3 interpreter now tracks that ratio;
  merely declaring an MRT output or binding a texture is insufficient.
- Unjittered WVP agrees with the captured scene camera times the affine world
  transform. The rigid c11 normal-plane row is not treated as an affine row.

Replay skips a candidate only after an unambiguous previous-frame match with
the same world pose and buffer-write counters. Native map callbacks track
vertex, secondary-stream and index buffer writes; counters are bounded to 4096
resources and retired on resource destruction/reset. Writes after capture are
checked again before replay. New instances, camera cuts, changed transforms or
buffers, unsupported profiles and late depthless materials keep the existing
replay path. A motion-capable tree remains in replay even when its animation is
subtle. The filter does not assume all foliage is static.

`cameraOnlyDraws` reports skipped submissions; `objectDraws` still counts captured
draws. The object texture stays clear at omitted surfaces, selecting native-depth
camera motion in the resolve. The stationary-footprint exception now also accepts
uncovered valid native depth. Its two-frame neighborhood/depth checks remain;
invalid covered poses and measured object movement still veto the exception.
Unsupported animated surfaces without object coverage remain a limitation of
camera fallback, including in this stationary test.

### Sky and debug validity

Sky depth 1 uses a separate rotation/FOV reprojection. `SkyReprojection` finds
the homogeneous camera center from inverse(current VP)'s third column, removes
that center from reconstructed world rays, then projects directions through the
previous VP. Computation stays in double precision until the final rows are
uploaded to c6-c9. Translation cannot move an infinitely distant sky. Its stored
previous depth is exactly 1; even w * rcp(w) can round above 1 and must not decide
whether sky motion exists. Non-perspective diagnostic cameras use the existing
matrix fallback. Resolve capture format version 2 records all ten constant rows.

Vector validity is separate from history availability. Off-screen UV or previous
depth outside 0..1 resets accumulation, but a finite, forward-facing vector still
appears in the motion preview. This removes misleading pink flashes from the
old bounds test without clamping or accepting unavailable history.

The live water snapshot contains VS 265E7205 / PS 659AB3BD at draws 1131/1132
with only the color RT attached. Although its pixel shader declares a depth
output, no scene-depth MRT receives it. It remains outside motion capture and
the static filter. The bounds correction applies to its camera fallback; it
does not create water-surface vectors or solve animated reflections/opacity.

The slider now exposes Off, Depth, Motion Vectors, History Confidence and History
Rejection. `TAADebugViewV2` starts at Off to avoid reinterpreting old indices.
Motion Vectors selects internal preview 3 while real TAA continues and respects
the user's Camera/Object setting. It displays the final history-sampling
displacement on the unjittered output grid, combining object and camera paths.
Raw object/camera and source-color views are no longer exposed in the UI.

### Verification

- FXC /WX /O3 for all six SM3 shaders and full addon compilation pass.
- Native parser audit: 347 of 617 original pixel shaders prove depth output.
- GPU tests pass static omission, changed world/buffer fallback, late/deforming
  exclusion, camera cuts, sky translation invariance, +/-0.4-radian yaw, nonzero
  jitter, and valid off-screen/far-plane vectors with history count reset.
- Stationary synthetic roof boundaries retain reference RMSE within 1% and
  temporal RMS below 0.001. Camera fallback is not bit-identical to FP16 object
  depth: temporal RMS was 0.000585-0.000702 versus 0.000407-0.000575 for replay.
- Existing skin/cloth/tree/wind/alpha/palette/native-coverage and reset tests pass.
- The rebuilt HDR+TAA fixture skips both static MRT draws, retaining all three
  late passes. The mutable-upload fixture skips zero draws and preserves its
  optimized uploads. Both pass buffered/immediate output and ResetEx checks.
- Scratch evidence: hybrid-tests.log, hybrid-boundary-tests.log,
  hybrid-motion-tests.log, hybrid-integration/hybrid-release.log and
  split-integration/hybrid-partial-upload-release.log under the established
  tmp/asscreedeziotrilogy/taa directory.

Release SHA-256
`45BA5BC05A5C5D94ABDD8808FA2F5CAF22638985768AE31B20CEE2E6723F1024`.
Live inspection of that build found zero static omissions: the initial filter
required MaxZ=1 but every captured native draw used MaxZ=0.9998999834. Removed
this unnecessary condition; the R32 shader output is clip z/w before viewport
mapping. Read-only runtime inspection also confirmed all 760 sampled draw WVPs
passed the scene-camera consistency test, and sampled main materials had MRT1
red writes, depth writes and no blending. The integration fixture now reproduces
MaxZ=0.9999. Evidence: hybrid-live-eligibility.json and hybrid-live-raster.json.
Live roof/water behavior and same-scene FPS remain to verify after the correction.

Corrected Release SHA-256
`09FB31C1B8FF2206C21D8192B09A707D8527E50220BA7C8EBCCB08AD036A16FC`
is rebuilt and linked. `hybrid-integration/hybrid-viewport-release.log` passes
native-range buffered/immediate output and ResetEx, with `cameraOnlyDraws=2`
and all three late draws retained. The simplified Motion Vectors UI mapping also
passed integration with normal accumulation active in the preceding build;
that mapping and the shaders are unchanged by the viewport correction.

## 27. Returning character parts: bounded body-motion recovery

The user reported persistent pink flashes, including with a still camera, and
slight normal-gameplay flicker. The occasional log entries often showed zero
unmatched draws, but read-only frame sampling found 672 of 1451 moving-camera
frames with at least one missing match. A separate stationary sample found 40
of 1220 frames with missing matches. Successful overall capture does not prove
every part has previous-frame history.

A one-shot GPU capture isolated 2841 negative-alpha pixels on an NPC part while
its neighboring parts remained tracked. Its mesh key existed in the preceding
frame only on a different NPC, so rejecting that mesh match was correct. The
affected actor's other materials still supplied an unambiguous body transform.
A control capture with zero unmatched draws contained zero negative-alpha
pixels. These samples establish a real missing-part path; they do not prove
that every possible pink flash has the same cause.

### Recovery contract

`MatchMotionRoots` runs after direct matching and teleport/camera-cut rejection.
For an unmatched skeletal draw without a mutable geometry snapshot, it examines
only directly matched skeletal parts with the exact same current world and
unjittered clip matrices. Every such part must agree on its previous root and
clip matrices and satisfy the existing bounded world-space movement test. Any
conflict rejects recovery. Estimates never become evidence for another estimate.
CPU-deformed cloth, wind/tree profiles, ambiguous crowds and wholly new actors
retain the missing-pose path.

The recovered index supplies **only the previous WVP**. The returning mesh keeps
its current bone palette, geometry and displacement as its estimated previous
local pose. Bone indices/palettes can differ across meshes of one character;
copying a neighboring material's palette would produce incorrect animation.
Thus this is body/camera motion with frozen local articulation for one missing
pose, not reconstructed exact skeletal motion. Direct matching resumes normally
as soon as that part exists in consecutive frames.

The private motion texture keeps signed current complementary depth in A:
zero is uncovered, negative is invalid, positive is usable. B now stores signed
previous complementary depth: positive for full motion, negative for a root
estimate. Its magnitude still encodes depth. Estimated far-plane values retain
a nonzero FP16 sign. `motion_info.z` is 0 (missing), 1 (full), or 2 (root-only).
The resolver and its shared combined preview decode the same vectors/depth.

Root estimates retain the ordinary UV bounds, depth and color rejection tests.
They cannot use the stationary-boundary depth exception, and accumulation is
capped at four samples (at most 75% history weight). This avoids treating absent
articulation as high-confidence stationary history. Exact motion can rebuild
confidence on subsequent frames. Debug magenta still means no usable estimate;
it is not suppressed by the preview alone.

### Performance and verification

No additional textures, readbacks, draw submissions or per-frame allocations.
The scan applies only to unmatched skin parts; the existing static replay filter,
batched palette upload and differential state binding remain. `rootMotion`
reports recovered draws separately from full matches and `unmatchedMotion`.

- Saved stationary CPU samples: 25 of 58 missing draws recovered; unproven
  remaining draws stay rejected. Mean root matching was about 4 microseconds
  across those 24 sampled frames; this is not an in-game FPS measurement.
- Native GPU fixture verifies the expected root vector, the returning mesh's
  own palette, signed depth/quality, and camera-cut reset.
- Resolve readback verifies a four-sample cap, normal confidence recovery,
  disocclusion/missing-pose resets, and identical history with preview on/off.
- Existing original-vs-replay skin/cloth/alpha/foliage coverage, mixed palette
  batching, sparse uploads, shader cache, state restoration and reset tests pass.
- All six FXC /WX /O3 shaders and full addon syntax checks pass.

Scratch evidence is under `tmp/asscreedeziotrilogy/taa`: `pink-stationary`,
`pink-gpu`, `test-motion-roots.cpp`, `test-root-confidence.cpp` and
`root-existing-motion-tests.log`. Game captures are in the game's existing
`renodx-dev/taa-capture` directory. Normal gameplay and repeated pink flashes
still require user verification with this rebuilt addon.

Release SHA-256
`DB429006A3237043CC9B2E25F9FF9CA5076B98EE4FE1A6261F7235D4317A167B`
is built and linked to Brotherhood. The HDR integration fixtures pass buffered
and immediate draws plus native ResetEx: static coverage still skips two draws
and retains three late passes, while mutable coverage retains all five draws
and its optimized uploads. Logs: `hybrid-integration/root-release.log` and
`split-integration/root-release.log`.


## 28. Native MSAA plus temporal stabilization (2026-09-18)

### Captured pipeline and failure mode

An 8x MSAA Brotherhood capture with the HDR addon at 3840x2160 contained 3,434
submissions. Draws 2220-2630 included a **single-sample R32F depth prepass**.
Draws 2635-3362 wrote an **8x RGBA16F surface**, with no second color target.
Camera-anchor VS `0x4B000956` appeared repeatedly in that multisampled pass.
The native resolve and bloom/composite precede LUT PS `0x48DCE479` at draw 3385:
s0 is already a single-sample RGBA16F texture and s8 retains the R32F prepass.
The original depth PS `0x65A612BE` explicitly writes interpolated clip.z/clip.w
to COLOR0.xyz. It is also used for shadows; the hash alone is insufficient.

The old camera capture required single-sample scene color with R32F at MRT1.
It rejected all MSAA anchors. In the restarted live game, capture logs showed
zero camera draws, zero jitter draws and no resolve; the native color readback
was finite and normal. The user clarified that the blank/blurry result occurred
when changing MSAA during gameplay; a restart restored output but left TAA
inactive. The correction also prevents old surface identities from enabling
jitter while a new MSAA pipeline has no validated temporal pair.

### Capture, identity and lifecycle

`CaptureMsaaDepth` observes the audited depth PS on R32F RT0, requiring a
matching single-sample hardware DSV, full viewport and enabled depth writes.
It retains only this frame's texture, draw count and bounded position/index
ranges with their clip matrices and buffer-write generations. Two prepass draws
and two camera anchors are required. The multisampled anchor must bind that
exact texture at s8, as must the later LUT; dimensions must match scene color.
Clearing the associated prepass DSV invalidates the captured evidence.

Camera extraction remains `WVP * inverse(world)` with double intermediates,
consistent anchors and the existing temporal camera-cut checks. A sample-type
or scene-target identity change invalidates history, previous motion and jitter.
Reset releases all private and retained default-pool resources. Missing evidence
leaves the native scene in place. Jitter now also checks exact scene-color identity
and rejects multisampled color, including before a new camera anchor is available.

### Initial hybrid sampling policy (superseded by section 29)

With MSAA enabled, projection jitter is zero for both scene and depth. Use the
native MSAA coverage pattern and temporally stabilize its resolved color before
the existing game/HDR LUT. This is deliberately an **unjittered temporal MSAA
hybrid**, not temporal supersampling of the shader or a sharpening pass. With
MSAA disabled, the existing Halton jitter and convergence policy remain.

Resolve c5.z retains 0 = invalid and 1 = ordinary valid history, and adds
2 = valid native-MSAA history. The capture format already records c0-c9 and
therefore preserves this distinction without a version change. Hybrid sample
confidence is `clamp(1 / (1/8 + 0.5 * motion_pixels), 2, 8)` instead of retaining
the eight-phase jitter cycle and up to 128 stationary frames. Root-only motion
still caps at four; depth, color and disocclusion rejection remain active.
The single combined Motion Vectors preview shares the same selection as TAA.

### Motion replay and performance

DX9 requires matching multisample type/quality on a render target and DSV.
Also, a depth buffer created with Discard may lose its contents when unbound
([Microsoft's depth-surface contract](https://learn.microsoft.com/en-us/windows/win32/api/d3d9/nf-d3d9-idirect3ddevice9-createdepthstencilsurface)).
Do not reuse the prepass DSV after unbinding or bind the game's 8x DSV to a 1x
velocity target. Do not average motion/depth samples across surface boundaries.

Instead, MSAA object replay uses the existing 1x RGBA16F motion texture and one
private 1x D24S8 buffer, cleared before each replay. The motion PS point-samples
the game's R32F depth at `(VPOS + 0.5) / resolution`; fragments behind that depth
are rejected with a 2e-7 clip-depth roundoff allowance. Private depth orders
replayed geometry with LESSEQUAL; opaque draws write it, translucent draws use
read-only depth and the established dominant-alpha cutoff. Depth at the pixel
center selects a surface even when MSAA color contains partial coverage.
Materials needing native stencil clipping are conservatively excluded because
that stencil has no single-sample equivalent in this path.

Static replay omission remains conditional on unchanged geometry/world/camera
and audited depth semantics. Under MSAA, the exact position/index range, clip
matrix and unchanged upload generations must additionally occur in the current
R32F prepass. Merely having a prepass texture is insufficient: later color-only
geometry still replays to supply its otherwise missing depth. Skin, cloth, wind,
foliage, palette batching, sparse geometry snapshots, root recovery and shader
caches retain the existing implementation. Prepass identities are bounded to
2,048 entries and discarded each frame, with references preventing COM address
reuse. No CPU readbacks or additional DX9/DX11 transfers occur in normal use.

The extra D24S8 buffer costs 31.6 MiB at 4K. Private temporal/motion/depth
surfaces total about 253.1 MiB in MSAA Object Motion mode, subject to a 256 MiB
surface budget, plus the existing bounded geometry and palette storage. Native
MSAA allocations are additional; no second 8x RGBA16F motion surface is created
(which alone would require about 506 MiB at 4K).

### Verification and remaining scope

- Native GPU tests at 2x, 4x and 8x: color resolve preserves the source; visible
  and closer late surfaces produce the expected motion; occluded surfaces are
  rejected; incompatible multisampled depth never poisons normal replay.
- Readback verifies the hybrid eight-sample confidence cap and unchanged
  ordinary history accumulation and constant-color output.
- Existing original-vs-replay skin/cloth/alpha/tree coverage, palette batching,
  mutable uploads, shader-cache and reset regressions pass.
- All six shaders compile with FXC /WX /O3; addon syntax checks pass.
- Final Release integration fixtures pass with the HDR addon at 2x/4x/8x and
  standalone SDR at 8x. Each run switches MSAA -> none -> MSAA and exercises
  native ResetEx. Buffered/UP scene output agrees; logs show valid cameras,
  history and object replay, zero MSAA jitter and restored non-MSAA jitter.
- Prepass identity tests retain late geometry while omitting only the matching
  static prepass draw; the existing non-MSAA static omission still operates.

Release SHA-256:
`E2A71173D06E6A5AC2848D7FFC0786D715D97FFAC160E62119848BF0F2C21B0A`.
The game-folder symlink points to this rebuilt Release addon. Integration logs
are `msaa-integration/release{2,4,8}.log` and `msaa-sdr/release8.log` beneath the
scratch TAA directory.

Live 4K/8x validation after restart (PID 28164) confirms 5-6 valid camera anchors,
137-223 depth-prepass anchors, `current=1`, `consecutivePair=1`, `resolve=1`,
`historyPair=1`, `motionReady=1` and zero jitter draws. Samples captured 379-508
object draws with 40-64 static omissions; full rigid/skin matches were active
and the sampled records had zero missing poses. The combined motion preview
shows moving characters against camera-reprojected scenery. All 8,294,400
output pixels in the readback were finite, with no black pixels. This validates
activation and the displayed diagnostic, not subjective temporal quality or
real-game MSAA switching; those checks still await user feedback.

Scratch evidence: `tmp/asscreedbrotherhood/msaa-*` for the native capture and
shader disassemblies; `tmp/asscreedeziotrilogy/taa/test-msaa.cpp` and
`test-msaa-capture.cpp` for GPU and HDR integration tests. In-game visual checks
must still cover MSAA toggles, panning, silhouettes, transparency and motion
coverage. The single-sample depth prepass cannot describe every surface in a
partially covered MSAA pixel; this first implementation does not claim per-sample
motion, perfect transparent coverage or independent shader supersampling.

## 29. Synchronized MSAA jitter and reconstruction (2026-09-18)

This supersedes section 28's unjittered sampling policy. The user confirmed
that the initial hybrid works but reported shimmering on thin edges in motion.
The current pipeline is:

1. Apply the same frame-latched projection offset to the native single-sample
   R32F prepass and multisampled scene-color draws.
2. Let the game resolve its MSAA color normally.
3. Reconstruct color on the unjittered output grid, reproject temporal history
   using camera/object motion, then reject and blend history.
4. Feed that result into the existing native or HDR LUT pass.

### Pass synchronization and lifecycle

`OnPresent` retains the previous verified prepass target and DSV identities,
separately from current-frame depth evidence. This lets `ApplyJitter` cover the
first prepass draw next frame. References prove identity only: no discarded
hardware-depth contents are reused. Reset releases these references along with
the other default-pool resources.

The same audited CTAB `g_WorldViewProj` contract is used for both passes.
Only exact verified target/DSV pairs and full-size depth-enabled viewports
qualify. The existing shader cache is reused. Non-scene DSVs return before the
additional render-target query, preserving the early-out optimization.
The original c0-c3 rows are restored after each draw.

Color jitter requires current-frame prepass evidence and no unjittered audited
prepass anchors. At the LUT, a partially jittered pair cannot resolve or reuse
history. Graphics changes reacquire targets through an unjittered warm-up frame.
An offset already applied to depth is never silently relabeled as zero when a
new color target is discovered. If neither pass was jittered, replay/resolve
receive zero even if the previous frame had scheduled a nonzero offset.

The static-draw optimization still compares **unjittered** prepass and material
clip matrices, exact position/index ranges and upload generations. Applying
jitter must not invalidate those physical-transform comparisons. Batched
palette uploads, sparse geometry capture, root recovery and state caches remain.

Log fields `jitterDraws` and `depthJitter` count color and prepass applications
separately. Stable MSAA TAA should show both nonzero, `depthUnjittered=0`,
`current=1`, `resolve=1` and `historyPair=1`. Depth preview intentionally does not
jitter; the combined motion preview still removes raster jitter from physical
velocity exactly as the resolver does.

### Sampling and confidence

MSAA uses `0.5 * Jitter(frame)`: eight distinct Halton phases with an offset
smaller than 0.25 pixels per axis. Both native passes and motion replay consume
that exact frame value. The existing non-MSAA footprint is unchanged.

With valid MSAA history, current color uses the same nine-tap Catmull-Rom kernel
as history, clamped to its source neighborhood before blending. This avoids an
extra bilinear tent filter on already resolved MSAA coverage. Rejected or
unavailable history retains the conservative existing current-sample path.
The current reconstruction adds GPU texture taps; it adds no CPU readback,
geometry replay, per-sample motion buffer or surface allocation.

MSAA confidence is now
`clamp(1 / (1/64 + motion_pixels), 4, 64)` before color rejection and the existing
four-sample root-only cap. The longer stationary history integrates the jitter
phases; moving history responds faster than the ordinary non-MSAA policy.
Sample counts are exponential-blend confidence, not a stored FIFO of that many
frames. Depth/disocclusion rejection and reactive color clipping remain active.

FP16 color rounding now runs once at the shader output boundary, after the
resolve/preview decision. Duplicating the same rounding expression at every
early return exceeded the SM3 temporary-register limit with the new policy.
The quantization formula and all returned depth/count values are preserved.

### Verification and limits

- All six shaders pass FXC `/WX /O3`; Release target
  `asscreedbrotherhood-taa` builds using `clang-x86-release`.
- HDR integration at 2x/4x/8x and standalone SDR at 8x passes. The fixture uses
  original native camera/LUT shaders, the installed ReShade, and the real addon.
  All eight captured depth/color phases match independently jittered GPU
  reference draws; both passes restore c0-c3. Repeated phases match as well.
- The fixture switches MSAA -> none -> MSAA, calls native ResetEx, skips one
  prepass, and recreates color and depth targets. It recovers normal scene output
  and history; buffered and DrawPrimitiveUP LUT draws agree.
- GPU motion visibility/occlusion tests pass at 2x/4x/8x. MSAA stationary
  confidence approaches 64 (63.9688 with FP16 truncation), moving confidence
  caps at four, and ordinary history still accumulates independently.
- Existing non-MSAA edge convergence, transfer-function handling, state
  restoration, uncertain-pose confidence, missing-pose rejection and motion
  preview/resolve agreement pass after the output-rounding refactor.
- Synthetic thin-feature measurements favored the smaller footprint and
  shorter moving history over the first full-jitter/8-sample-minimum candidate.
  They do **not** show uniform improvement over the previous unjittered hybrid:
  already well-sampled geometric lines can lose detail with temporal
  reconstruction. Single-shaded detail at one pixel/frame improved substantially
  in the fixture (temporal residual RMS 0.117 to 0.042), but other speeds/patterns
  remain mixed. These measurements are not a substitute for real scene review.

The R32F prepass still supplies one depth per pixel, while native MSAA color can
mix several surfaces. This implementation does not expose individual MSAA
samples, provide per-sample velocities, or guarantee removal of all silhouette,
transparency or animated-shading flicker.

Live restart verification at 3840x2160/8x (PID 30496) confirms synchronized
color/prepass jitter: sampled records show 510-561 color draws, 295-319 depth
draws, zero unjittered depth anchors, valid cameras/history and active object
replay. Static omission remains active (107-117 draws in those records), with
zero unmatched poses in the sampled frames. The normal scene readback contains
8,294,400 finite pixels, no NaN/Inf and no all-zero RGB pixels. The user checked
panning in-game and reported that it "works quite well". This validates this
scene and configuration, not every material or future gameplay situation.

Release SHA-256:
`34AA7367E81E4EF49590B0EDA016DC9E4B444DB56C0BDFB49796B36483D7B1E6`.
Scratch evidence: `test-msaa.cpp`, `test-msaa-capture.cpp`, `test-msaa-thin.cpp`,
`msaa-integration/jitter{2,4,8}.log` and `msaa-sdr/jitter8.log` under
`tmp/asscreedeziotrilogy/taa/`; live capture files are
`tmp/asscreedbrotherhood/msaa-jitter-*`. The game-folder link targets this
Release build.

## 30. Immediate fullscreen draws across graphics resets (2026-09-18)

The user reported a blank scene when changing MSAA during gameplay, despite
successful restart tests. A live 8x -> 4x transition still reported valid
camera/depth, jitter, resolve and motion capture, but the LUT output was
uniform `(1,1,1,1)`. This was downstream of valid TAA capture, not evidence that
the jitter amplitude or history policy needed changing.

The installed ReShade's `resize_primitive_up_buffers` releases its temporary
UP buffers at reset without clearing their handles. Its indexed-UP path also
assigns the index allocation to the vertex-buffer handle. An integration test
using UP draws **before and after** ResetEx reproduces heap corruption with the
old addon. Earlier tests deliberately reset before beginning UP draws and
therefore missed this real gameplay sequence.

### Addon-local workaround

`native_draw.hpp` intercepts the ReShade wrapper's `DrawPrimitiveUP` and
`DrawIndexedPrimitiveUP` slots (83/84), using the same wrapper discovery and
hook ownership used for indexed ranges. It uploads CPU vertices/indices into
private native dynamic buffers, then calls the wrapper's ordinary buffered
draw entry point. Both HDR and TAA shader callbacks still run exactly once.
The dependency source and installed ReShade DLL are unchanged.

- Buffers use DISCARD writes and grow in 4 KiB steps, capped at 16 MiB each.
  Native creation/upload avoids geometry-shadow interception and CPU readback.
- Indexed draws preserve MinVertexIndex/NumVertices, 16/32-bit indices and
  topology. Vertex data starts at `minimum * stride`; a negative base vertex
  maps the original indices into the compact uploaded range.
- Stream zero is cleared after either UP call; the index binding is also
  cleared after indexed-UP. Wrapper setters keep ReShade tracking consistent.
  Stream frequency is restored. These are the relevant native
  [DrawIndexedPrimitiveUP postconditions](https://learn.microsoft.com/en-us/windows/win32/api/d3d9/nf-d3d9-idirect3ddevice9-drawindexedprimitiveup).
- A thread-local guard prevents immediate geometry from entering camera
  jitter, object capture or static-depth mesh classification. The LUT callback
  remains active.
- `destroy_swapchain` releases the default-pool upload buffers before native
  reset. Wrapper identity survives reset and TAA Off; device destruction
  restores owned hooks. Installation also works with camera-only TAA or TAA
  Off, since fullscreen shader dispatch still needs valid geometry.
- No presentation hook, resource upgrade, output policy or FPS limit is added
  to the TAA addon.

### Verification

Release target `asscreedbrotherhood-taa` passes compilation and the actual
ReShade integration regression. The 520-frame test cycles 8x -> 4x -> Off ->
8x, resetting after prior UP calls and alternating buffered, nonindexed-UP and
indexed-UP LUT draws. Indexed cases include nonzero minimum vertices and both
index widths. All paths preserve reference scene output after reset, with the
existing depth/color jitter phase checks intact. HDR+object-motion TAA,
standalone SDR+camera-motion TAA, and standalone TAA Off pass.

The user repeated the graphics changes in Brotherhood and confirmed recovery.
A live 3840x2160/8x readback after multiple real resets contains 8,294,400 finite
pixels, no NaN/Inf and no all-zero RGB pixels. Capture logs retain synchronized
jitter, valid history and object replay. This validates the tested reset path;
it is not a guarantee for every overlay or future ReShade version.

Release SHA-256:
`8C6F4C2BF4F4B4426075867CF9F044DCDF096A95F92B8259A2329F134D6D760A`.
Evidence: scratch `test-msaa-reset.cpp`, `msaa-reset/transitions-indexed.*`,
`msaa-reset-sdr/{camera,off}-reset.*` under `tmp/asscreedeziotrilogy/taa/`, and
`tmp/asscreedbrotherhood/msaa-reset-live-*`.

## 31. Lilium RCAS on the completed TAA image (2026-09-18)

The Sharpening section exposes **Lilium RCAS**, 0-100, default 0 (Off).
`RCASSharpening` is stored in the existing TAA settings section and parsed to
0-1. It is active only with TAA On and Debug View Off, for either motion source
and native MSAA or single-sample rendering. AMD and Lilium are credited in the
overlay and shader. RCAS is optional; adding it does not change TAA defaults.

### Placement and history ownership

Sharpen after the complete temporal resolve and before its texture is bound to
the native/HDR LUT. The audited pass order in section 2 puts this before the
HUD. This also leaves the addon independent of the HDR tonemapper, brightness
settings and LUT implementation. Native gradient/DOF/blur passes still follow
the LUT; this is sharpening of TAA's output, not a replacement for those effects.

RCAS must not modify the color stored as next-frame history. Sharpening inside
`StoreHistory` would repeatedly accumulate overshoot and change temporal
rejection. Instead, `Resolve` renders unmodified color/depth and sample counts
first. It then reuses the now-dead **previous** RGBA16F history texture for a
separate display pass, as the diagnostics already do. All aliases are unbound
before changing render targets. The next frame overwrites that scratch texture
while reading the untouched current history. TAA frame dumps remain captures
of the unsharpened temporal inputs/output.

The shader is created lazily and released by the existing reset/resize/device
lifecycle. No new full-resolution texture, CPU readback, geometry replay or
GPU wait is added. Strength 0 skips creation and the draw. Debug views take
priority and bypass sharpening. A shader/draw failure leaves the resolved
image available; a shader creation failure is not retried every frame.
The normal state block plus explicit render-target/depth restoration covers
the extra pass. `RestoreScene` still restores the game's s0 and sRGB flag.

### Filter and transfer handling

Reference ports inspected: `alienisolation/common.hlsl` and its final TAA pass,
`black-desert-online/lilium_rcas.hlsl`, and the AC3 original/remastered RCAS
implementations. The primary [Lilium RCAS source](https://github.com/EndlesslyFlowering/ReShade_HDR_shaders/blob/master/Shaders/lilium__include/rcas.fxh)
also documents the five-tap cross and luminance/noise modes.

The local SM3 adaptation uses linear BT.709 luminance, the 0.1875 negative-lobe
limit, 0.99 normalized-maximum limiter, noise suppression and common RGB gain
limited to 0-4. It uses the fixed 125 normalization found in the existing RenoDX
HDR ports; this pre-LUT signal is relative scene light, so display peak is not
used as a sharpening parameter. No SDR-white clamp is introduced.

Encoded resolve output is sign-safely decoded/encoded with gamma 2.2, matching
TAA's existing working-light convention. If the original SDR texture was
already hardware-sRGB-decoded, the resolve contains linear values and RCAS
does not decode again. It returns the same transport expected by the LUT and
preserves alpha/history depth. Signed RGB is scaled together. Black/flat
regions and the normalized-white singularity are guarded; output is bounded
only by FP16's finite numeric range. This does not change the HDR addon's LUT
or SDR EOTF emulation.

### Verification

The authored pass compiles as `ps_3_0` with FXC `/WX /O3`: five texture reads,
146 total instruction slots. Native DX9 GPU tests compare 442,368 output
pixels against an independent double-precision reference at strengths 0, 50
and 100. Cases cover black/flat patches, detailed color, signed HDR, highlights,
the normalization boundary, large finite FP16 values, native 8-bit encoded
sampling and hardware-sRGB decoding.

Across repeated frames, sharpening leaves history color/depth and sample
counts bit-identical to the unsharpened resolve. Debug/depth views bypass it,
render targets/constants/samplers are restored, shader-creation failure falls
back to normal TAA, and releasing private resources permits ResetEx. The test
also exercises the resolve's MSAA history policy. Scratch evidence:
`tmp/asscreedeziotrilogy/taa/test-rcas.cpp`, `rcas-tests.log` and `taa_rcas.asm`.

The `clang-x86-release` addon build succeeds and embeds `taa_rcas.cso`.
With the rebuilt HDR and TAA addons loaded through actual ReShade, a 520-frame
integration fixture at RCAS 50 passes 8x -> 4x -> Off -> 8x MSAA and ResetEx.
Buffered, nonindexed-UP and indexed-UP LUT draws preserve the reference flat
scene output; the existing color/depth jitter checks also pass. Evidence:
`tmp/asscreedeziotrilogy/taa/rcas-integration/rcas-integration.{txt,log}`.
The game-folder symlink targets the rebuilt Release addon. SHA-256:
`1034EC8508838AFD08F37C58F0825EDC3F6575930CD4D3543E7D47185D36410C`.
Visual sharpening strength and scene-specific ringing remain an in-game check.

## 32. DLAA feasibility investigation (2026-09-18)

**Initial feasibility result; implementation follows in section 33.** At this
stage the released TAA addon and settings were unchanged. The local AC3 Remastered and Unity
`dlss.hpp` implementations provide examples of direct NGX D3D11 integration;
their in-process approach cannot be copied unchanged into Brotherhood.

### API and process architecture

Brotherhood and this addon are x86/DX9. Inspecting the installed SDK's PE/COFF
headers identifies both `nvngx_dlss.dll` builds and the NGX static libraries as
AMD64 (`0x8664`), versus the addon's x86 (`0x14c`). Even the libraries directly
under `vs2012` are AMD64. NVIDIA's current [SDK distribution](https://github.com/NVIDIA/DLSS/tree/main/lib/Windows_x86_64)
and [integration guide](https://github.com/NVIDIA-RTX/Streamline/blob/main/docs/ProgrammingGuideDLSS.md)
provide the D3D11 route; there is no NGX DX9 entry point. An in-process DX11
device does not change the game's CPU architecture, so the existing HDR proxy
cannot load the x64 feature DLL for us.

The viable candidate is a separate x64 executable using direct NGX and D3D11:

```text
x86 DX9 addon: capture scene, depth, camera and object poses; apply jitter
  -> GPU preparation and shared input textures
x64 DX11 helper on the same adapter: DLAA at native input/output resolution
  -> shared result texture
x86 DX9 addon: restore scene transport -> optional RCAS -> LUT -> HUD
```

The helper processes images and does not present frames or own the game window.
NVIDIA's [Remix bridge](https://github.com/NVIDIAGameWorks/dxvk-remix/blob/main/bridge/README.md)
is a precedent for separating a 32-bit client from a 64-bit renderer, though
replacing the whole game renderer is not necessary for this proposed route.

### Isolated proof on the local GPU

Scratch source/build/logs are in
`tmp/asscreedeziotrilogy/taa/dlaa-feasibility/` (`probe.cpp`, `build.ps1`,
`probe.log`, `helper.log`). Both executables were compiled with Clang Release
optimization without modifying CMake, SDK files or the installed addons.

- A hidden x86 DX9Ex process creates two RGBA16F shared textures. Its x64
  D3D11 child selects the identical adapter by LUID and opens both handles.
- 120 frames make the DX9 -> DX11 -> DX9 round trip bit-exactly, including
  negative RGB, values above one, changing frame markers and alpha. Image
  transport stays on the GPU; CPU readback is used only to assert test output.
  GPU event queries establish completion before the process handoffs.
- The x64 helper initializes NGX successfully (`0x1`) and reports
  `SuperSampling_Available=1`. Creating a 1280x720 -> 1280x720 DLAA feature
  succeeds, and evaluating eight synthetic linear-HDR frames succeeds.
- Synthetic output center RGB is `0.500488, 1, 3.99414`, against input
  `0.5, 1, 4`. This proves execution and HDR range, not moving-scene quality.

Texture transport and DLAA evaluation are separate parts of this probe. It
does not yet run Brotherhood's captured images through DLAA, test resets or
measure real-resolution performance. Shared transport is tested at 64x32;
DLAA evaluation is tested at 1280x720. No 4K cost can be inferred from this.

### Inputs to reuse and adapt

- Reuse the pre-LUT scene hook, verified camera matrices, projection jitter,
  object/cloth/skinning capture, static-draw omission and reset detection.
  DLAA replaces temporal accumulation; it must consume the current jittered
  scene rather than an already accumulated TAA image.
- Produce a dense raw two-channel motion texture, combining object motion
  with camera/sky reprojection. The debug image is color-coded and unusable
  as input. Preserve current-to-previous direction, remove jitter from the
  vectors and supply it separately in pixel units. Direct NGX MV scaling
  differs from Streamline's normalized constants; audit against the chosen API.
- Carry ordinary clip z/w depth with its R32 precision, including late visible
  surfaces. Do not treat signed complementary depth/validity in the current
  object texture as NGX depth. Invalid poses need a deliberate fallback and
  disocclusion policy; magenta diagnostic colors are not a data contract.
- Decode the current scene into the chosen linear HDR working representation,
  handle exposure explicitly and restore the original transport before the
  native/HDR LUT. Keep UI, tone mapping and presentation in their existing paths.

[Microsoft's DX9/DX11 sharing restrictions](https://learn.microsoft.com/en-us/windows/win32/api/d3d11/nf-d3d11-id3d11device-opensharedresource)
include single-sample, single-mip textures and a limited format set. RGBA16F
is proven here; portable R32 depth transfer still needs a precision-preserving
packing/conversion path or separately validated interop. Simply reducing scene
depth to half precision would reintroduce the distant-edge failures documented
earlier. Resolve native MSAA before sharing.

### Suggested implementation sequence

1. Add a game-local helper/protocol prototype with a versioned frame ID,
   adapter identity, dimensions, shared handles, completion signaling and
   bounded failure handling. A stale or failed worker must not stall gameplay.
2. Export the real combined vectors/depth and scene at the current insertion
   point. Validate them independently of DLAA and avoid CPU image transfers.
3. Start with native-resolution DLAA and MSAA Off, then verify image quality,
   camera cuts, focus changes and graphics resets. Keep the existing TAA/MSAA
   path available. Free/replace shared resources only after both consumers finish.
4. Measure synchronization, GPU time and memory at gameplay resolutions before
   deciding whether it is suitable for release. Object capture remains CPU work;
   DLAA does not remove its cost, and cross-process waits could increase it.
5. Expose Off / TAA / DLAA with capability detection and an explicit TAA fallback.
   Packaging would require the x86 addon, an x64 helper and NVIDIA's runtime.
   Build/CI changes and redistribution details remain separate implementation work.

## 33. Optional DLAA backend (2026-09-18)

### Integration and file map

The persistent `TAAEnabled` key retains `0=Off` and `1=TAA`; `2=DLAA` adds the
new backend without reinterpreting existing presets. TAA/Object Motion remain
the defaults. The existing pre-LUT `OnScene` hook selects exactly one successful
resolve. DLAA consumes the current jittered scene, never TAA history. Once DLAA
becomes active, the custom TAA history/count textures are freed. Failure,
startup, native MSAA or a TAA-specific diagnostic uses the existing resolver.

| File | Responsibility |
| --- | --- |
| `dlaa.hpp` | DX9 working resources, frame export/import, bounded IPC, fallback and state restoration |
| `dlaa_protocol.hpp` | Fixed-width x86/x64 packet, frame ID, lifecycle/error states |
| `dlaa_handles.hpp` | Move-only kernel-handle ownership; excludes legacy GPU handles |
| `dlaa_inputs.ps_3_0.hlsl` | Current linear color, combined raw motion/mask and R32 depth export |
| `dlaa_output.ps_3_0.hlsl` | Restore signed color/transport, or preview actual NGX vectors |
| `dlaa_helper/main.cpp` | Hidden x64 same-adapter D3D11/NGX worker; no presentation |
| `dlaa_helper/prepare.hlsl` | Nonnegative color, RG16 motion and R8 responsive-mask conversion |
| `dlaa_helper/CMakeLists.txt`, presets, `build.ps1` | Isolated Clang x64 Release target and runtime/license packaging |

No global CMake/CI or SDK files change. Build the normal x86 addon target and
the game-local helper separately. The helper and the existing SDK's Release
`nvngx_dlss.dll`/license belong in `renodx-asscreedbrotherhood-dlaa/` beside the
addon. Never put this 64-bit DLL in the x86 game's DLL search directory.

### API capability and textures

Ordinary DX9 cannot create/open the required shared resources in the local
driver probes. DX9Ex succeeds. The Ezio HDR addon already requests ReShade's
DX9Ex device upgrade. When the optional helper executable is installed, the
standalone addon requests the same capability through the existing cross-addon
`utils::device_upgrade` module. Installing the helper therefore requires a game
restart. With no helper, standalone TAA preserves its previous device-creation
behavior. This enables resource sharing, not HDR formats or presentation.

The addon obtains the DX9Ex adapter LUID. The helper enumerates DXGI adapters
and requires that exact LUID and NVIDIA vendor, then checks NGX feature
availability. No implicit selection of a different GPU is allowed.

Four single-mip, single-sample render-target textures are created by DX9Ex and
opened on the helper's D3D11 device. Their shared handles are legacy GPU handles,
not kernel handles to close. The driver probes verified RGBA16F, RG16F and
R32F sharing on this machine. R32F sharing is capability checked, not assumed
portable: failure returns to TAA rather than quantizing distant depth.

| Shared resource | Format | Meaning |
| --- | --- | --- |
| Color | RGBA16F | Current signed linear scene; later reused for returned display conversion |
| Motion/mask | RGBA16F | Unjittered previous-current normalized UV, responsive mask, validity |
| Depth | R32F | Current ordinary D3D clip z/w, near 0 / far 1 |
| Output | RGBA16F | Completed linear DLAA; later reusable as RCAS display scratch |

Shared storage costs 28 bytes/pixel, 221.5 MiB at 3840x2160. The pixel budget is
8,388,608; the helper also rejects dimensions above 8192. The x64 process owns
additional RGBA16F color/output, RG16F motion, R8 mask and NVIDIA model/history
memory. TAA may temporarily coexist during asynchronous startup. No game
resource description is changed.

### Exact signal contract

1. Export the jittered current scene at pixel centers. Preserve the original
   sRGB sampler state. Gamma-encoded transport uses sign-preserving power 2.2;
   an 8-bit source already decoded by native sRGB sampling stays linear.
2. `CurrentMotionDepth`, shared with TAA in `taa_reprojection.hlsli`, keeps the
   native R32 sample when replay depth agrees. Late visible surfaces contribute
   their signed complementary object-depth value converted back to clip z/w.
3. Valid object vectors are already unjittered `previousUV-currentUV`. Otherwise
   reconstruct camera motion using the existing double-precision CPU camera
   matrix product and sky rotation/FOV path. Add back the current jitter offset
   removed by `AC2ReprojectCamera`, yielding raw unjittered vectors. Do not pass
   TAA's selected/dilated history-sampling vectors or debug colors to NGX.
4. Unknown poses use camera motion plus a white bias-current-color mask. Root
   motion estimates also set that mask. Invalid/unbounded reprojection becomes
   zero motion plus a white mask. The helper sanitizes nonfinite color/motion.
5. On the GPU, convert RGBA16F motion/mask into the NGX-supported RG16F vector
   texture and R8 mask. Clamp linear NGX input color to nonnegative values.
6. Create a native-resolution DLAA feature with HDR, AutoExposure and MVLowRes
   flags. MVLowRes denotes undilated render-resolution vectors, even when input
   and output dimensions are equal. MVJittered/DepthInverted are unset. Scale
   normalized UV vectors by render width/height. Supply pixel jitter (right/down
   positive) separately, pre-exposure/exposure scale 1 and measured frame time.
7. Reconstruct the original signed color contract by adding the current negative
   residual at `outputUV + currentJitter/size`; the residual itself is not
   temporally reconstructed by NVIDIA. Re-encode sign-preserving power 1/2.2
   only for encoded transport. Preserve current scene alpha and disable a second
   sRGB decode at the LUT sampler, exactly as in the custom TAA integration.
8. Optional Lilium RCAS processes this completed result before the LUT and HUD.
   Neither sharpening nor debug colors enter NGX history. All subsequent game
   grading, effects, HUD and HDR presentation remain in their existing paths.

### Synchronization, reset and fallback

The x86 addon starts the x64 helper hidden and suspended, passes only mapping,
request/reply events and a parent synchronization handle through an explicit
`STARTUPINFOEX` handle allowlist, assigns it to a kill-on-close job, then resumes
it. No globally named IPC or unrelated inheritable game handles are used.

Startup is polled without blocking frames (30-second deadline), with TAA used
meanwhile. For each DLAA frame, a DX9 event query must complete all producer
draws before the request event publishes the packet. The helper prepares/evaluates
the image, copies output, completes a D3D11 event query, then publishes the exact
completed frame ID. Only then may DX9 read the result or reuse input storage.
There are no CPU image readbacks in production. This serialized GPU handoff
adds synchronization cost; it is not a performance claim.

GPU query deadlines are two seconds; first evaluation allows five seconds and
subsequent evaluations 250 ms. A timeout/worker exit/NGX failure terminates only
the addon's child, frees its private resources and latches TAA fallback instead
of restarting the helper every frame. The UI and ReShade log show status and
stage/error. Switching to TAA and back explicitly retries. A reset/size/backend
change destroys the helper and all default-pool references before recreation.
Frame gaps, cuts, camera validation failure and source encoding changes reset
NGX history. Requests and results are never overlapped or allowed to reuse an
in-flight image.

Every private draw restores native RTs, DSV, viewport and a full state block,
including failure exits. Only completed output replaces LUT sampler 0; its
original texture and sRGB flag are restored after the LUT draw. No worker
swapchain, Present call, VSync override or frame limiter is introduced.

### Debugging and current limits

Motion Vectors with active DLAA displays the same dense undilated vector texture
used by NGX. It continues evaluating DLAA underneath. Depth and custom History
Confidence/Rejection explicitly run the TAA diagnostics; they are not NVIDIA
internal history views. Status makes this fallback visible.

DLAA currently requires MSAA Off. MSAA levels continue to use the validated
custom TAA/MSAA path with its synchronized half-footprint jitter. The object
capture, batched animation upload, matching, static-draw omission and all CPU
optimizations are unchanged. Water, transparency, unknown poses and imperfect
animation matches retain their existing input limitations. DLAA cannot invent
correct object motion when those inputs are missing.

The initial integration test exposed a large stack allocation in `DllMain`
on a driver's small-stack thread; module-path storage now uses the heap.
Repeated color checks also identified NVIDIA's enabled global DLSS indicator:
its black diagnostic text was present in NGX output. The indicator was left
unchanged. Tests exclude only its bottom text area from constant-color checks;
motion/depth/finite checks still cover every pixel. Do not mistake this overlay
for invalid scene color.

Validation uses native DX9 GPU fixtures in
`tmp/asscreedeziotrilogy/taa/dlaa-feasibility/`, plus ReShade scene/reset fixtures
in `dlaa-integration/` and `dlaa-standalone/`. The 1280x720 and 640x360 tests cover
signed HDR, SDR encoded/decoded inputs, exact R32 depth, known object/camera
vectors and masks, restored state, RCAS, preview, missing-helper/worker-exit
fallback and reset cleanup. The final production-shader run also passes
3840x2160 signed HDR, totaling 11,750,400 pixel checks across all seven cases.
The ReShade fixture creates ordinary DX9, confirms
the upgrade to DX9Ex, executes real scene shaders, reaches active DLAA and passes
8x -> 4x -> Off -> 8x with HDR (both addon load orders) and native SDR.

Live Brotherhood validation then confirmed DX9Ex, MSAA Off and active DLAA at
3840x2160 alongside the HDR addon. The user reported that it works and looks
good. DevKit's current post-LUT FP16 readback contains 8,294,400 finite pixels,
zero NaN/Inf and zero all-RGB-zero pixels; 382,410 pixels exceed 1 in at least
one RGB channel. This is a live resource readback, not a frozen historical draw.
The captured alpha is zero, so PNG previews need their alpha ignored to inspect
RGB. Longer gameplay, additional scenes and performance comparisons remain
useful; this one scene is not exhaustive quality validation.

### DLSS preset selection and status

`DLAAPreset` stores dropdown indices 0-5 for DLL Default / F / J / K / L / M.
The settings parser maps them to NGX values 0 / 6 / 10 / 11 / 12 / 13; invalid
indices use 0. A hidden integer setting retains the normal config/reset path,
while a custom ImGui combo supplies the dropdown UI. The default is always 0.

Protocol 2 appends the requested NGX preset to the fixed-width packet (112 bytes
on both x86 and x64). The helper validates the protocol and preset before using
resources. For nonzero selections only, it sets
`NVSDK_NGX_Parameter_DLSS_Hint_Render_Preset_DLAA` before feature creation.
Default leaves that parameter untouched; it does not hardcode a current model
or invoke optimal-settings helpers to choose one. Logs describe the requested
hint, since the runtime or a driver override can choose differently.

The client snapshots the preset when creating its state and destroys that state
when the selection changes. A fresh helper, NGX parameter block and feature
ensure both old history and old hints are discarded, including explicit-preset
to Default transitions. This also permits retrying a failed preset by selecting
another; startup continues to use TAA. No scene, motion or sharpening shaders
change. Status text is green only while DLAA is active and red on failed startup
or evaluation; starting and deliberate fallback states retain neutral text.

The focused `dlaa-feasibility/preset-test.cpp` GPU fixture passes the sequence
Default -> F -> J -> K -> L -> M -> Default through the production client and
Release helper. Each change creates a new worker, resets the first evaluated
frame, then keeps the worker/history stable; all returned pixels are finite.
It also verifies the requested-preset log, worker-failure latching, retry on a
new selection and clean DX9 device reset. These checks validate the requested
NGX hints and lifecycle, not whether a driver override honors a particular model.

## 34. Standalone exclusive-fullscreen startup

The first standalone live launch exposed a gap in the earlier windowed fixture:
ReShade 6.8's ordinary `IDirect3D9::CreateDevice` upgrade to DX9Ex invokes
`CreateDeviceEx` with a null `D3DDISPLAYMODEEX`, even when the game requests
exclusive fullscreen. Native DX9Ex rejects this with `D3DERR_INVALIDCALL`.
Brotherhood repeatedly retries device creation and exits before AA can render.
The Ezio HDR presentation proxy had masked this by requesting windowed DX9.

`native_device.hpp` installs a game-local compatibility hook from `create_device`,
after addon loading and before the shared DX9Ex upgrade enters the runtime.
It uses the existing `native_draw` vtable hook/owner tracking and keeps a DX9Ex
factory alive until the hook is removed. Only a missing fullscreen descriptor
is filled from the already-requested presentation parameters. Existing valid
descriptors, windowed calls and unsupported adapter-group requests pass through.
There is no forced borderless/windowed mode, format upgrade, Present interception
or VSync change. The hook is enabled only when the optional helper requests
DX9Ex. Registration, hook removal and factory release are paired on detach.

The `fullscreen-startup` fixture uses the same ReShade binary as the game and
only the TAA addon. The released build reproduces the exact `INVALIDCALL`;
the correction passes exclusive startup, native `Reset` to windowed and back,
device/addon unload and recreation, with both VSync On and immediate presentation
at 3840x2160/240 Hz. It verifies actual swapchain parameters and unchanged SDR
format. This extends the previous windowed startup/AA-input tests.
The existing SDR and HDR scene fixtures also pass with this hook, including
active DLAA, MSAA 8x -> 4x -> Off -> 8x, immediate fullscreen draws, ResetEx and
both HDR/TAA addon load orders.

API contract: [IDirect3D9Ex::CreateDeviceEx](https://learn.microsoft.com/en-us/windows/win32/api/d3d9/nf-d3d9-idirect3d9ex-createdeviceex).

### Overlay texture locking after successful device creation

The next live startup confirmed successful fullscreen device creation, then
crashed separately while RTSS locked its overlay texture. The dump showed a
null trampoline call in ReShade's `IDirect3DSurface9_LockRect`, reached through
`IDirect3DTexture9_LockRect`. ReShade shares a texture-vtable hook across native
textures, but calls its surface hook directly; a texture created through the
unwrapped device can expose a surface vtable it has never hooked. Merely
registering a texture-map callback and mixing a tracked system-memory texture
with a native default-pool texture reproduces the crash without RTSS itself.

The game-local `native_device` compatibility path replaces texture LockRect and
UnlockRect after ReShade's `init_resource` setup. It obtains the mip surface and
calls its virtual LockRect/UnlockRect instead of assuming a surface trampoline
exists. Native surfaces use their native methods; hooked surfaces still deliver
ReShade mapping callbacks and pointer/stride substitutions. HRESULTs are
preserved. No ReShade binary, RTSS setting or presentation code is changed.
Hooks are installed once per runtime texture vtable and owned by the compatibility
module, independent of the first texture's lifetime. They retain no textures,
so default-pool allocations do not obstruct Reset, and are restored on detach.

The `native-textures` regression first reproduces the same missing-trampoline
failure with the previous build. The corrected build passes raw/tracked texture
and surface locking, dynamic DISCARD uploads, written-byte readback, exact map
and unmap callback counts, expected invalid locks and repeated device resets.
The earlier fullscreen-only test did not exercise this path. The subsequent
live standalone launch on 2026-09-18 loaded TAA and DevKit with the HDR addon
disabled, activated both compatibility hooks and reached active native-resolution
DLAA. The log records active DLAA again later in the session and a clean exit.
This verifies the observed startup failure; it is not exhaustive gameplay testing.

## 35. Optional x64 DX12 presentation prototype

The first frame-generation milestone adds **presentation only**. The game and
AA remain native DX9, the existing Ezio addon performs its HDR/postprocessing
and DX11 output conversion, and a new x64 helper displays the finished image
through DX12. The shipped frame-generation libraries are not integrated yet.
`DX12Output` defaults to 0, and missing helpers never enable it automatically.
Standalone DX9 presentation is not connected; this integration currently needs
the Ezio HDR addon's DX11 output. No shared utility, global preset, CI or vendored
dependency is changed.

### Capture and presentation ownership

`presentation.hpp` tracks DX11 swapchains whose HWND belongs to the game process.
It intercepts their native Present/Present1 methods using the existing vtable
hook ownership mechanism. Capturing at the native boundary includes the proxy
output shader, ReShade effects and overlay, which execute after the public
ReShade `present` event. The source backbuffer is copied without retaining it
across a call, so ResizeBuffers can release its references normally.

One successful helper acknowledgement replaces one native DX11 Present; the
existing HDR addon then suppresses duplicate DX9 presentation as before. TEST
presents pass through. Failure tears down the child output before calling the
original DX11 method for the current frame. A failed session is latched until
Off/On or swapchain recreation, avoiding repeated startup stalls.

An HWND can own only one flip-model swapchain. The helper therefore creates a
disabled, nonactivating child canvas, matched to the game HWND's DPI-awareness
context and client size, and owns a separate DX12 flip-discard swapchain there.
The game keeps keyboard/mouse focus. The client services synchronous sent
window messages while waiting on IPC; without this, child creation can deadlock
when the producer is also the window thread. Queued game input is left alone.
Session/client ownership survives reentrant swapchain destruction during these
sent messages; teardown restores hooks and closes the worker's job.

### GPU transport and synchronization

`presentation_client.hpp` creates one DX11 legacy shared texture in the source
format and a shared DX11 fence. It copies the completed backbuffer, signals the
frame ID on that fence and flushes submission. `presentation_protocol.hpp` is a
versioned, pointer-free x86/x64 packet (104 bytes in v1; 392 bytes in v2 with
auxiliary frame inputs). Mapping, request/reply events,
parent process and the NT source-fence handle use an explicit inheritance list.
The legacy texture handle is a driver token, not a CloseHandle-owned NT handle.

The helper imports the source into a DX11 device on the same adapter LUID.
It creates a DX12 shared simultaneous-access texture and opens its NT handle
on DX11. The worker's DX11 context waits for the source fence, copies to that
texture, then signals an internal shared fence's odd value. The DX12 queue
waits for it, transitions/copies the image into the current backbuffer, restores
resource states and signals the even value. Present and GPU completion precede
the acknowledgement; only then may the producer overwrite its shared texture.
One frame is in flight, with bounded startup/frame waits. There is no production
CPU pixel readback; the GPU fixture alone requests readback checksums.

The helper accepts RGBA8/BGRA8 SDR, RGB10A2 HDR10/PQ and RGBA16F scRGB, using the
source color space unchanged. It copies rather than re-tonemaps or re-encodes.
The native Present sync interval and supported tearing/restart flags are passed
through. Driver-per-executable policy and actual G-Sync/limiter behavior are
separate live-validation requirements. Resolution/format/color-space changes
and graphics resets rebuild the transport and output session. Unexpected parent
exit kills the helper through its job, and helper failure restores native output.

`helper_process.hpp` shares restricted child launch/job ownership with DLAA;
the DLAA packet, GPU path and display ownership remain unchanged.

### Build, verification and next milestones

Build `asscreedbrotherhood-taa` with its established x86 Release preset and
`presentation_helper/build.ps1` with the game-local x64 Release preset. The helper
output is `build64-brotherhood-dx12/Release/renodx-asscreedbrotherhood-dx12.exe`.
Install it in the matching directory beside the addon, separately from DLAA.

The x86 `test-dx12-present` fixture passes exact-pixel checks across all four
formats, changing dimensions, VSync/immediate requests, cross-process child
ownership/cleanup and worker-failure detection. It also passes native DX9 shared
texture -> DX11 -> x64 DX12 pixel equivalence. D3D12 debug-layer errors fail the
validation when the debug layer is available. The HDR/DLAA scene fixture reaches
active DX12 output through 8x -> 4x -> Off -> 8x and native ResetEx in both addon
load orders. Terminating the fixture's own worker restores DX11 output, and the
next reset recreates DX12 output. The default-off standalone and HDR fixtures
still pass with DLAA active. A 40-frame 3840x2160 HDR10 transport run also passes
without validation readback; its timing includes Present/IPC and is not an
in-game overhead measurement.

Live Brotherhood verification on 2026-09-18 reached 3840x2160 HDR10 output.
The user confirmed the image, input and ReShade overlay worked, followed by
successful Off/On switching and an MSAA change. A 12-second PresentMon capture
recorded 1,342 DX12-helper presents, zero dropped frames and no native game DX9
or DX11 presents. Mean presentation/display intervals were both 8.936 ms
(about 112 FPS), with sync interval 1 and Hardware Composed: Independent Flip.
After the toggle/reset check, another capture recorded 823 helper presents,
zero dropped frames and no native game presents, still at sync interval 1.
Mean presentation interval was 9.683 ms (about 103 FPS). These are different
live samples, not a controlled performance comparison. They establish single
presentation ownership before and after the tested change; they do not prove
every driver-profile limit, G-Sync behavior or a performance improvement.
Captures and summaries are in `tmp/asscreedbrotherhood-taa/dx12-live*.csv/json`.

Next: measure overhead against DX11 in a fixed scene, extend validation to focus,
menus, fullscreen changes and helper failure in-game, then export aligned depth/motion,
camera constants and **postprocessed HUD-less color** with UI alpha/color.
The existing DLAA input is earlier than the finished output and cannot simply
serve as frame generation's HUD-less image. Only after that should Streamline
DLSS-G/Reflex and generated-frame scheduling be added. Additional buffering and
fence-based pipelining must retain the measured presentation and reset behavior.

## 36. Frame-generation input transport (no interpolation yet)

`FGInputCapture` is an additional developer opt-in, default Off. It requires
DX12 output, TAA/DLAA with Debug Off, and the updated HDR addon. It does not load
Streamline or generate frames. The purpose is to validate the inputs and their
lifetimes before adding interpolation/pacing.

### Capture points and color contract

The live Brotherhood snapshot on 2026-09-18 contained 2,577 draws. LUT draw
2538 (`0x48DCE479`) was followed by white-gradient/downsample/postprocess passes;
draw 2543 (`PS 0xC9F2C59B`, `VS 0x3E4AE466`) copied the finished scene to the
FP16 swapchain clone. HUD draws began at 2544 and continued through the end.
The original final pixel shader is a plain `texld oC0, v0, s0`. This proves why
the earlier DLAA input cannot substitute for the postprocessed HUD-less image.

`OnFinalScene` runs after that verified composite and copies its output with a
point-sampled native DX9 shader, before the HUD. It checks full viewport size,
FP16 format, matching dimensions and single-sample output. It deliberately does
not guess alternate final-composite hashes. Missing variants produce no HUD-less
flag. Copying through a shader works inside BeginScene; using StretchRect there
would violate the native DX9 contract. `SavedDraw` restores the entire DX9 state,
including separately saved render targets, depth surface and viewport.

The raw capture is still in the HDR addon's working color domain. `fg_encode.hpp`
opens its shared texture on the native DX11 device and encodes it to HDR10 with
`fg_hudless.ps_5_0.hlsl`, which includes the actual Ezio presentation shader.
Its compiled bytecode matches the HDR addon's output shader exactly. The optional
read-only `RenodxEzioReadOutputParameters` ABI returns that frame's 28 injection
floats, with version/size checks. There is no duplicate color math or separate
brightness setting. A private DX11 context-state object isolates the encoding
draw and restores all stages/bindings afterward. An old/missing HDR addon leaves
depth/motion available but does not claim correctly encoded HUD-less color.
The context-state creation flags must match the source device's single-threaded
flag. The HDR proxy uses a single-threaded DX11 device; omitting the matching
flag produces `E_INVALIDARG` even though the same code works on an ordinary
multithreaded test device.

### Motion, depth and frame identity

`taa_dense_motion.hlsli` holds the existing DLAA camera/object selection math.
DLAA continues to use it on its jittered input grid. `fg_inputs.ps_3_0.hlsl`
samples matching native depth and motion at `outputUV + jitter / size` and emits
them on the unjittered output grid. XY is previous-minus-current UV, including
camera and object motion but excluding jitter. Z marks estimated/invalid poses;
W marks valid vectors. R32F depth preserves native D3D z/w, near 0 and far/sky 1.
Depth is point sampled, not averaged across silhouettes or temporally filtered.
MSAA uses the same verified single-sample depth prepass as TAA.

`fg_protocol.hpp` defines a 272-byte, pointer-free input record with a unique
native capture ID, resource generation, dimensions, window identity, three
shared handles, validity/reset flags, timing, actual jitter and unjittered
current/previous camera and clip-reprojection matrices. Matrices retain the
game's column-vector convention; the Streamline adapter in section 38 transposes
for its row-vector convention and derives/validates the remaining camera fields.
Frame intervals use QueryPerformanceCounter rather than coarse system ticks.
Camera discontinuities use the existing TAA continuity tests. A capture ID is
consumed once; an unchanged old capture is never resent during menus/loading.
Reset releases the capture with the rest of the DX9 device data.

The DX9 event query completes the exported writes before the presenter can
read them. The final HDR encoding shares the presenter's DX11 source fence.
The x64 worker imports motion/depth and encoded color, copies them into its own
DX12 shared resources, and acknowledges them under the same frame/fence protocol
as final color. It rejects duplicate IDs, wrong dimensions/window, unsupported
flags and mismatched textures; missing inputs preserve ordinary presentation.
Generation IDs protect against reused driver handles after reset. Resources
remain stable through the Present acknowledgement. Normal operation performs
no CPU pixel readback. At 4K the three native capture textures add about 158 MiB,
the encoded DX11 image 32 MiB, and the helper's DX12 inputs 127 MiB; these are
additional allocations, so capture remains opt-in during development.

### Diagnostics and remaining work

The status reports which inputs the DX12 worker actually accepted, not just
which textures were allocated in DX9. `Save Captured Inputs` performs a one-shot
readback to `renodx-dev/fg-capture/<pid>-<frame>/`: packed RGBA16F motion, R32F
depth, raw working-color RGBA16F HUD-less scene and a manifest with matrices and
conventions. A `complete` marker is required before analyzing a capture. This
explicit diagnostic stalls; it is never part of the ordinary timing path.

The GPU fixture passes at 64x32 and 96x32: stationary jitter cancellation,
camera/object selection, reset validity, exact signed/>1 FP16 scene capture,
R32 precision, DX9/DX11 state restoration, exact DX12 checksums, stale/missing
and wrong-size input rejection, positive high-resolution frame intervals,
one-shot readback, and unchanged base output. Both single-threaded and ordinary
DX11 source devices pass. The real ReShade fixture receives all three inputs
(`accepted=7`, native `captured=3`, `encodeError=0`) in both addon load orders
through 8x -> 4x -> Off -> 8x and ResetEx. Worker termination still restores
ordinary output; the next reset recreates the worker and complete inputs.
Standalone SDR TAA/DLAA also passes with DX12/capture disabled, including DLAA
activation during the MSAA-Off phase.

Live Brotherhood validation on 2026-09-18 used DLAA at 3840x2160. The user
confirmed the output looked correct, and both logs reported all three inputs
accepted with no encoding error. Two complete one-shot captures were inspected:

- Stationary camera, animated horse/rider and nearby characters (`7944-1616`):
  all depth/motion/color values finite, normalized depth 0.957828..0.994903,
  valid vectors across the image and no uncertain-pose flags in this frame.
  Static scenery had zero motion while the horse/rider had independent vectors.
  Motion magnitude reached about 12.34 pixels in the sampled grid.
- Moving camera on the rooftops (`7944-9251`): all values finite, depth
  0.954600..1, 5.86% sky pixels and valid vectors throughout. Comparing every
  fourth pixel with double-precision camera reprojection, 93.52% of non-sky
  samples were within 0.1 pixel (median error 0.00357 pixel). This includes
  independently moving meshes, which should differ from camera-only vectors;
  it is not a per-object correctness score. For sky samples, the rotation-only
  calculation matched within 0.01494 pixel maximum. Median motion magnitude
  was about 12.21 pixels, proving this was a moving-camera capture.

Scene/depth silhouettes were visually aligned in both captures. Game HUD and
ReShade overlay were absent from the captured scene; HDR working values above
one and small negative channels survived. NVIDIA's enabled DLSS diagnostic
indicator was still visible at the lower left: it is baked into the earlier
DLAA result, so a clean frame-generation evaluation must disable that external
indicator. These two frames establish live input transport and sampled
alignment, not scene-wide motion correctness, generated-frame quality or pacing.
Inspection results are under `tmp/asscreedbrotherhood-taa/fg-live-inspection`
and `fg-live-camera`; raw captures remain in the game's `renodx-dev/fg-capture`.

This stage established the inputs. Section 38 adds Streamline, camera conversion,
Reflex scheduling and explicit gates for later ReShade effects/overlay. Game UI
alpha/color remains unimplemented; do not advertise full UI recomposition.
See NVIDIA's
[DLSS-G input requirements](https://github.com/NVIDIA-RTX/Streamline/blob/main/docs/ProgrammingGuideDLSS_G.md#51-required-and-optional-resources)
for postprocessed color, dense motion, depth and UI semantics.

## 37. DX12 startup handoff and intermittent foreign-frame investigation

The user reported brief images resembling another window every few seconds
when starting Brotherhood with DX12 already enabled. Disabling input capture
did not remove the flashes; disabling DX12 did. Enabling DX12 during gameplay
also avoided the issue. A 20-second PresentMon trace contained 2,398 helper
presentations and no native game presentations, so that sample did not show
the earlier duplicate-Present bug. This narrowed the investigation to startup
display ownership/composition rather than frame-generation input capture.

`Session::native_ready` now gates takeover until the underlying DX11 swapchain
returns `S_OK` from a real presentation with a visible, non-minimized parent.
TEST, occluded and failed calls do not prime it. Both Present entry points
record the result; reset creates a fresh session. The initial native frame is
the sole presentation for that frame, and later successful helper frames still
suppress native output. This gives launch-enabled DX12 the same prerequisite
as enabling it after normal output is already running.

The helper also waits for the first backbuffer copy before showing its child
canvas. It no longer calls `SetWindowPos(HWND_TOP)` every frame: resize is
conditional on changed client dimensions and preserves z-order and focus.
The normal per-frame texture/fence protocol is unchanged. Validation readback
now checks the actual DX12 backbuffer after the copy, rather than the intermediate
input texture, so checksum tests cover the final GPU copy as well.

The previous Release fails the added hidden-parent startup regression at frame
zero: a helper child already exists before any visible native presentation.
The regression also requires a first visible native frame before the helper
appears. The corrected Release passes that startup sequence, 8x -> 4x -> Off ->
8x, native ResetEx and worker-failure fallback in both addon load orders. All
three frame-generation inputs recover after reset. The standalone transport
fixture passes actual-backbuffer pixel checks in RGBA8/BGRA8 SDR, HDR10 and
scRGB at changing dimensions, including 360 changing HDR10 frames, first-frame
visibility, native DX9 shared input and worker teardown. With the matching
protocol-3 pair installed, a fresh launch with DX12 enabled reached gameplay
and the user reported that the startup flicker appeared resolved. The log
confirms native priming followed by active DX12 output without failure. This
is one successful live retest of an intermittent compositor symptom.

The first attempted gameplay retest during the next development stage loaded
the protocol-2 addon alongside an already rebuilt protocol-3 helper. ReShade
logged stage 1 / error 13 and correctly fell back to DX11. This was an installation
mismatch, not evidence for or against the startup flicker correction. Protocol
incompatibility now logs received/expected versions and returns
`ERROR_REVISION_MISMATCH`; update the linked addon/helper as a pair while closed.

## 38. Experimental Streamline DLSS-G, UI gates and Reflex (2026-09-18)

### Scope and dependencies

This is an opt-in first integration, with one interpolated frame per real frame.
`DLSSFrameGeneration=0` remains the default. It requires the HDR addon's HDR10
DX11 output, the DX12 presenter, valid TAA/DLAA inputs and Debug Off. Standalone
SDR frame generation is not implemented. A user request enables input capture
automatically, independently of the developer `FGInputCapture` toggle.

`presentation_helper/streamline.hpp` dynamically loads the official signed
Streamline interposer in the x64 helper only. It uses the existing 2.8.0 headers
and matching production runtime: sl.interposer, sl.common, sl.dlss_g, sl.reflex,
sl.pcl and nvngx_dlssg. No SDK DLL is injected into the DX9 game or DLAA helper.
The game-local installer checks the SDK version and NVIDIA signatures and
preserves the Streamline, DLSS and Reflex licenses. Official SDK archive SHA256:
`313669F8CF886F823EA0518A50712EFA5E2E8623689ED2A6BD0D9353E475BC47`.
Vendor headers/submodules, global CMake and CI are unchanged.

Initialize before graphics calls; the helper delay-loads system graphics DLLs.
Use the interposer's factory/device exports, DXGI factory proxy and frame-based
resource tags. Request DLSS-G, Reflex and PCL, check adapter support using the
actual source LUID, and retain the existing mod's own project GUID/custom-engine
identity. Do not borrow another game's application ID. NVIDIA's production
runtime currently warns about an unregistered application ID while allowing the
custom-project initialization; a public release should resolve that with NVIDIA
and review the runtime licenses. This is not a claim of NVIDIA certification.

Missing runtime or unsupported hardware preserves original-frame DX12 output.
Changing the FG user toggle recreates the helper/swapchain so Off unloads the
interposer and its overhead. Worker/protocol/GPU failures use the existing DX11
fallback. Shutdown happens while swapchain, tagged resources and device remain
alive; retained proxy interfaces are released before unloading the DLL.

### Camera and resources

`fg_camera.hpp` factors the verified centered-perspective VP in double precision.
Normalize rows 0/1 to obtain right/up, row 3 to obtain forward; their lengths give
the projection X/Y scales. Require finite, mutually orthogonal axes, unit forward,
matching aspect, a depth row proportional to row 3 and valid near/far planes.
For `row2 = A * row3 + (0,0,0,B)`, near is `-B/A` and far is `-B/(A-1)`.
Camera position comes from inverse(VP)'s third column divided by its W. Vertical
FOV is `2*atan(1/yScale)`. Reject unsupported/singular/asymmetric projections.

Transpose the projection, its inverse, clip-to-previous and its inverse for
Streamline's row-vector matrices. Use UV motion scale (1,1), camera motion
included, ordinary depth, 2D unjittered vectors, no dilation and no orthographic
projection. Capture already resampled depth/motion onto the final unjittered
pixel grid, so **SDK jitterOffset is zero**; the native raster jitter remains in
the capture manifest for diagnostics. Applying it again would misalign inputs.
Reset on native discontinuity and on the first resumed frame after any pause.

For each matching frame token/viewport, tag depth R32F, dense motion RGBA16F and
the encoded HDR10 HUD-less image with `eValidUntilPresent`, full extents and
actual COMMON resource state. The final backbuffer is intercepted by Streamline.
Missing/paused frames clear tags and set mode Off; no stale native capture may
be reused. `slDLSSGGetState` checks runtime status and actual presentation count.
Green active status requires observed interpolated presentations, not merely
successful DLL loading or allocated inputs.

### HUD and ReShade

The existing verified postprocess composite supplies the scene before game HUD,
encoded through the same HDR output function/settings as final color. Tagging
that scene gives DLSS-G its supported HUD-less path. There is no invented
final-minus-scene alpha estimate. A separate game UI RGBA/alpha texture and full
UI recomposition are still future work, with HUD artifacts requiring live checks.

Observe `reshade_open_overlay`, `destroy_effect_runtime` and
`reshade_render_technique` for both native/proxy runtimes. Opening any overlay
pauses interpolation; any actually rendered technique also pauses it because
the earlier HUD-less image does not include those arbitrary effects. The native
DX9 `finish_present` clears the per-frame effect flag after final presentation.
Do not disable or alter user ReShade effects automatically. Overlay/effects still
appear on original frames. Closing the overlay or disabling effects resumes with
a reset. Likewise pause when the game root window is not foreground, while
minimized, and across helper child-size changes. The disabled child keeps native
game focus/input; focus is never stolen by production code.

### Reflex and cross-process timing

Protocol 3 is a fixed 416-byte packet, preserving the original header and 272-byte
input record. It adds generation request/pause flags, status/error, presentation
count and Reflex status. Two bounded control requests carry real frame boundaries:

1. At the game's DX9 `finish_present`, send `begin_frame` for N+1. The helper
   obtains that frame token, calls `slReflexSleep`, marks SimulationStart and
   acknowledges before the game starts its next tick.
2. Hook the application's ReShade DX9 wrapper `BeginScene` (slot 41), alongside
   the existing reset-safe draw hooks. Only the first call after the above
   boundary sends `render_begin`: SimulationEnd then RenderSubmitStart for N+1.
   Subsequent BeginScene calls cost one pending-flag check; addon-internal scenes
   on the native device do not create extra markers.
3. Use the same token for constants, tags, RenderSubmitEnd and PresentStart/End
   around the DX12 submission/presentation. An unmeasured bootstrap frame does
   not interpolate. Do not fabricate back-to-back simulation markers and claim
   engine integration; no engine input-sampling hook or Reflex latency measurement
   is provided. Present-return to first BeginScene is an explicit approximation.

Reflex Low Latency is enabled with FG, boost Off and frameLimitUs=0. Existing
driver/VSync/RTSS settings are untouched. Waiting services only sent Win32
messages as in the original helper client; map iterators/references must not
survive a reentrant wait that could destroy the swapchain. Session/client shared
ownership protects those waits. The same frame cannot be started/marked twice.

### Shared input lifetime

The helper's DX11 bridge writes FG inputs on a **non-presenting queue**. The old
pre-Present completion fence is insufficient once NVIDIA reads inputs after
Present. The internal shared fence now allocates four values per frame:

- `4*N-3`: DX11 source/input copies ready for the DX12 queue.
- `4*N-2`: base image copy complete; used before first showing the child.
- After Present, query DLSS-G's `inputsProcessingCompletionFence` and value on
  the present thread and enqueue a wait on the DX12 queue.
- `4*N`: signal after that wait, wait on CPU, then acknowledge the packet.
  Only now may the game produce the next frame and the bridge overwrite inputs.

The acknowledgement also protects the command allocator, source image and
resource destruction across resets. Failed lifetime queries terminate the helper
instead of allowing unsafe reuse. There is still one frame in flight and no
production CPU pixel readback. Performance/pipelining is a later task.

### Validation and remaining live checks

The captured-rooftop camera regression in `presentation_helper/tests/camera.cpp`
checks near/far, aspect, camera center, SDK transpose/inverses and rejection of
NaN, shear, mismatched aspect, singular reprojection and invalid depth planes.
The isolated 1280x720 moving-checkerboard test uses matching motion/depth and
HDR10 color, real cross-process timing commands and DX12 debug-layer validation.
It confirms actual SDK presentation count 2 while active, count 1 during overlay,
effects and missing-input pauses, and successful reset/resume. Native parent
focus remains unchanged. A background fixture initially returned only original
frames; a newer SDK's diagnostic identified window focus, and foreground testing
then confirmed 2x with the pinned 2.8 production runtime. No window-focus workaround
or new SDK dependency was needed in the addon.

Ordinary transport checks still cover SDR/HDR/scRGB exact pixels, changing sizes,
first visibility, native DX9 shared input and worker failure. The matching
protocol-3 Release addon/helper pair passes both real-ReShade load orders,
8x/4x/Off MSAA transitions, ResetEx, and worker-failure fallback/recovery.
The integration fixture runs with generation Off and input capture On; it proves
transport/reset behavior, not live game Reflex timing or interpolation quality.
The first live 3840x2160 HDR10 run confirms Reflex initialization, all three
accepted inputs (`accepted=7`), and DLSS-G status Active with two presentations
per rendered frame. That status also requires the game's present-return and
BeginScene timing commands; the late bootstrap path cannot activate generation.
The user reported correct gameplay after initialization and successful recovery
from Alt-Tab, DX12 Off/On, and changing/restoring the game resolution with
generation still enabled. Resolution resets recreate the native swapchain and
helper; the live log confirms native priming, `accepted=7`, and two presentations
again afterward. Logs show overlay,
effects, background and missing-input pauses returning to active generation.
A 20-second PresentMon trace records hardware-composed independent flip, VSync
requested and no dropped presentations. It is not a controlled performance or
latency comparison. Scratch evidence is under
`tmp/asscreedbrotherhood-taa/fg-live-20260918` and `fg-gameplay-first.csv`.

Broader gameplay checks remain necessary for HUD interpolation, transparent
objects, camera cuts, reset recovery and display pacing across configurations.
No input-to-photon latency improvement has been measured. Synthetic GPU success
and this short live session are not comprehensive gameplay-quality validation.

## 39. DX12 DLAA and 2x–6x frame generation (2026-09-18)

### Processing and presentation are separate

The old DLAA helper evaluated NGX on DX11 without presenting. The presenter
already owned the only final presentation when DX12 output was enabled.
DLAA preparation and NGX create/evaluate/release now use DX12 too. The two
x64 helpers remain separate processes/devices; this change does not merge them
into one queue or remove all bridge copies. DX11 only transports DX9 legacy
shared textures and supplies the HDR addon's existing output.

```text
DX9 scene + native jitter + dense motion + R32 depth
 -> DX11 legacy sharing bridge -> DX12 preparation -> DX12 NGX DLAA
 -> completed shared result -> DX9 output reconstruction -> RCAS -> LUT/HUD
 -> HDR output -> DX12 presenter -> DLSS-G/Reflex -> display
```

Moving DLAA to final presentation would give it already graded color/HUD instead
of its validated scene inputs. Keeping its pre-LUT insertion also preserves
standalone SDR, signed-color reconstruction, native alpha, user preset defaults
and debug fallback behavior. TAA remains the fallback if DLAA fails.

### DLAA resources and synchronization

`dlaa_helper/main.cpp` reuses the presenter's `ImportedImage` transport for four
private legacy resources. The DX11 bridge performs copies only; the existing
8x8 preparation compute shader runs through a DX12 PSO with two SRVs and three
UAVs. It prepares positive linear FP16 color, RG16F motion and R8 responsiveness.
NGX uses native-resolution DLAA, HDR/auto-exposure/undilated-motion flags, the
unchanged jitter signs, pixel-scaled vectors, R32 near=0/far=1 depth and the same
reset conditions. DLL Default still omits the NGX preset hint.

Inputs transition COMMON -> NON_PIXEL_SHADER_RESOURCE. Preparation UAVs
transition to shader reads before evaluation; NGX output is UAV, then COPY_SOURCE
for the return copy. Shared images return to COMMON for cross-API access.
The next command-list reset occurs only after the preceding frame completes.
One shared DX11/DX12 fence serializes:

1. DX11 input copies and signal; DX12 queue waits.
2. DX12 prepare/evaluate/output copy and signal; DX11 queue waits.
3. DX11 copy into the game's output and signal; the helper waits on an event
   before publishing completion. There is no production CPU image readback.

Feature creation is submitted and completed before reporting Ready. Cleanup
waits for submitted work before releasing NGX/resources. This adds four DX12
bridge images (28 bytes/pixel, about 221.5 MiB at 4K) in the x64 helper; native
x86 image allocation is unchanged. No performance improvement is assumed.
DLAA protocol 3 uses the previous 112-byte packet's padding for a backend
acknowledgement; the addon checks `backend=12` before declaring DLAA active.

### Multi-frame generation and UI

The persisted `DLSSFrameGeneration` setting remains 0=Off and 1=2x, extending
indices 2..5 to 3x..6x. The dropdown lives in the Frame Generation section.
The value sent to `numFramesToGenerate` is **multiplier minus one**. Query
`DLSSGState::numFramesToGenerateMax` before enabling interpolation. Unsupported
selections render original frames with an explicit status; they are never
silently represented as a successful lower multiplier. Once support is known,
the dropdown disables unavailable choices. Capability discovery uses the first
ordinary presentation; no guessed maximum enables a mode.

Presenter protocol 4 is 424 bytes, with supported maximum/configured generated
counts in its acknowledgement. Changing 2x..6x keeps the presenter alive and
resets interpolation; toggling Off still destroys/recreates the helper without
Streamline. Temporary overlay/effect/input/focus pauses retain model resources,
clear tags and present originals. Final shutdown releases those resources.
The source/input-consumption fences from section 38 still protect all generated
frames. The log records requested, configured, actual and maximum counts.
The panel keeps the last confirmed gameplay count visible while the overlay
pauses interpolation; it is cleared on selecting a new mode. A multiplier is
not a claim of proportional measured FPS, simulation rate or latency reduction.

### Pinned SDK and validation

The game-local presenter CMake fetches the official Streamline **2.14.1** archive
with SHA-256 `92c4d954631a1710da86ca3fa8d5034f2b9503838c95fc4ae977ae149319781b`.
`SOURCE_SUBDIR include` imports headers without running the SDK's deployment
CMake. `build.ps1 -StreamlineSdkDirectory <absolute path>` can reuse an unpacked
copy. The signed production-runtime installer checks the same version. No
repository-wide presets, vendored SDK or external submodule changes are needed.
Keep the addon, DLAA helper, presenter and presenter runtime matched.

On the local RTX 5090, the 600-frame GPU test confirms exact 2, 3, 4, 5, 6, then
2 presentations per application frame across six phases, with 74–75 confirmed
frames per phase and 120 overlay/effect pauses. It also pauses for missing inputs.
The sequence passes with SyncInterval 0 and 1. The runtime reports maximum 6x
and VSync support with host SDK 2.14.1. Existing NVIDIA App overrides load some
2.14.0 plugins; these settings are left untouched, and support comes from the
loaded runtime rather than the installed DLL filename alone.

DX12 DLAA passes 11,750,400 pixel checks over 1280x720, 640x360 and 3840x2160:
SDR/sRGB/HDR transport, signed-color/alpha reconstruction, R32 depth, vectors,
state restoration, RCAS/preview, helper-exit/missing-helper fallback and reset.
Ordinary presentation still passes exact SDR/HDR10/scRGB transport, resizing,
child ownership, native DX9 sharing and worker teardown. The optional Windows
DX12 debug layer is unavailable (`DXGI_ERROR_SDK_COMPONENT_MISSING`), so these
are pixel/API/fence tests, not a successful debug-layer validation run.
Scratch logs: `tmp/asscreedbrotherhood-taa/dlaa-dx12-gpu-tests.log`,
`mfg-modes-tests.log`, `mfg-modes-vsync-tests.log`, `mfg-transport-tests.log`.
Both real-ReShade addon load orders also pass startup, 8x -> 4x -> Off -> 8x
MSAA, ResetEx and helper-failure fallback with protocol 4. These fixtures select
DLAA (falling back to TAA for MSAA) and input capture with generation Off; actual generation/reset behavior is a
separate live check. The captured-camera regression passes against 2.14.1
headers (`brotherhood-fg-camera-test`, Release with assertions enabled).
Live visual and reset checks of this new combined version remain required.

## 40. Reflex controls, a base-frame limiter and display headroom

### User contract and timing boundary

`ReflexMode` persists Off / On / On + Boost (default On). `ReflexRenderFPS`
is a rendered-frame cap, before interpolation; zero means no manual cap.
`ReflexDisplayFPS` supplies an optional lower display ceiling; zero selects
the current monitor refresh minus 3 FPS. `DX12VSync` selects Follow Game / On /
Off, default On. All apply only to the DX12 output path. No driver profile or
external limiter is edited, and the normal DX11 output path is unchanged.

Reflex/PCL load independently of DLSS-G, so the limiter also works with FG Off.
Low-latency mode Off still calls Reflex Sleep and supplies the cap. FG requests
at least On without rewriting the saved setting. Off/On FG transitions recreate
the helper with the appropriate feature set; caps/modes/multipliers otherwise
change in place. Failures show the limiter as unavailable, never as an active
cap. Missing Streamline still allows ordinary DX12 presentation.

The existing `finish_present` hook on the native DX9 game now sends timing with
DX12 enabled even without FG. It waits for Reflex in the helper before returning
to the next game tick. `begin_frame` applies mode/cap before `slReflexSleep`, then
marks SimulationStart. The first native BeginScene sends SimulationEnd and
RenderSubmitStart. The helper supplies render-end/present markers at the final
DX12 boundary, including when FG is Off or paused. Mode changes always retain
the limiter value; there is no additional busy wait, timer loop or native Present.
The input sampling boundary remains inferred from the game's present return,
not an engine-owned simulation callback; input-to-photon latency is unmeasured.

### Conversion verified on the driver

The initial GPU experiment proved that the driver's Reflex limiter includes
generated frames. Passing 16,667 us unchanged with 3x generated only 20 rendered
frames/sec; with 6x it divided the base rate again. Do **not** equate the raw
`frameLimitUs` field with a simulation cap in this integration.

`presentation_pacing.hpp` computes a minimum base-frame interval:

```text
ceiling = min(manual display ceiling if nonzero, detected refresh - 3)
multiplier = max(supported selected multiplier, last confirmed actual multiplier)
base interval = max(1 / manual rendered cap if nonzero, multiplier / ceiling)
driver frameLimitUs = ceil(base interval in microseconds / confirmed actual multiplier)
```

All rates use integers (FPS settings, millihertz/milli-FPS telemetry), with
64-bit intermediates and upward rounding of minimum intervals. Fractional
refresh is preserved. An unavailable refresh does not invent a monitor rate;
the explicit display/base caps still work and the UI requests a manual ceiling.
Unsupported selected FG falls back to a 1x ceiling. A larger confirmed driver
multiplier also reduces the base cap, so an override cannot bypass the ceiling.

The driver conversion uses the last completed Present's
`numFramesActuallyPresented`, clamped to 1..6, rather than the UI selection.
An overlay/effect/missing-input pause returns to 1x and therefore to the full
base interval. Resuming FG restores the division. The selected multiplier still
constrains display headroom during a temporary pause to avoid a simulation-rate
jump when opening the overlay. Mode changes may have a conservative transition
frame; fixed-rate measurements exclude transitions and startup.

Mode/interval are cached so `slReflexSetOptions` is called only when either
changes. Display changes are checked on the frame-boundary request and final
Present; `DisplayTiming` caches the monitor query for a second, invalidating on
monitor changes. It matches the HWND's GDI display name to the active
`QueryDisplayConfig` path and uses its rational refresh rate. Path-count races
retry, clone paths use the lowest refresh, and `EnumDisplaySettings` is the
fallback. No per-frame display enumeration is performed.

### VSync, VRR and lifecycle

VSync On requests interval 1 at the actual DX12 swapchain and removes the
tearing flag. Follow Game preserves its interval, including 2..4 when presenting
originals. FG only starts with a supported interval and the runtime's
`bIsVsyncSupportAvailable` confirmation; otherwise it pauses and preserves the
original synchronized output. Driver settings retain their precedence.

G-SYNC cannot be enabled or proven through this control. A per-game NVIDIA
profile for `ACBSP.exe` does not automatically describe the separate presenter;
the UI/README explain configuring `renodx-asscreedbrotherhood-dx12.exe` and the
appropriate windowed/fullscreen G-SYNC mode. The explicit display ceiling lets
the user express a lower limit such as 225. Avoid stacking a second RTSS/driver
limiter. A 180 FPS output on fixed 240 Hz necessarily has uneven scanout
intervals; the rendered-frame pacing test is not proof of active VRR.

Protocol **5**, `Packet` **480 bytes**, carries four settings plus applied
mode, base/driver intervals, capability/error, detected refresh, ceiling,
selected/confirmed multipliers and requested sync interval. Settings are
validated at startup and each request. Addon UI status is mutex-protected and
cleared on reset/failure/disable. Settings reapply to newly created sessions.
Timing/present IPC deadlines include both the old and new base intervals for
unusually low caps. Allow up to a 6x transition while the driver finishes its
old schedule, plus the existing 2-second failure allowance. Compute the deadline
before handing the packet to the helper. Existing source and NVIDIA
input-consumption fences remain required; pacing does not weaken ownership.

### Validation and limits (RTX 5090, 240 Hz display)

- Persistent `brotherhood-reflex-pacing-test` tests 60 x 3, 225 / 6, fractional
  refresh, lower ceilings, mode/interval passthrough, FG pauses, unsupported
  multipliers and driver overrides. Build Release with assertions enabled.
- The 1,350-frame GPU fixture exercises Reflex Off, On and Boost, manual and
  automatic limits, 2x/3x/6x, VSync Off/On/Follow, and unsupported interval 2.
  All six active phases confirm the exact multiplier in 120 frames each.
  It verifies 120 overlay/effect pauses plus missing-input pauses and recovery.
- Representative base measurements: 60 -> 59.995 FPS at 3x; 45 -> 44.996 FPS
  at 3x; 60 with 225 ceiling at 6x -> 37.495 FPS; 60 with 120 ceiling at 3x
  -> 39.997 FPS. Reflex Off/FG Off holds 60; Boost/FG Off holds 80. Steady-state
  median base intervals are 16.668, 22.224, 26.670 and 25.002 ms respectively.
- Additional 4x/5x phases measure 56.243/44.958 base FPS at a 225 ceiling,
  with the exact presentation counts and pause recovery. An extreme 1 FPS
  display ceiling at 6x verifies long Reflex waits and recovery to 225 without
  an IPC timeout. The driver may finish one old interval after raising the cap.
- PresentMon records synchronized independent-flip output, including stable
  180 and 225 FPS segments. Four dropped frames occurred over the full startup/
  transition trace; no blanket zero-drop or uniform-VRR claim is made. The
  trace shows fixed 240 Hz scanout quantization, not confirmation of G-SYNC.
- Ordinary transport passes exact SDR/HDR10/scRGB pixels, resizing, child HWND
  ownership, native DX9 shared textures and worker-failure cleanup. Gameplay
  quality, input latency and the user's actual G-SYNC configuration remain live
  checks. The optional D3D12 debug layer is still unavailable on this host.
- Both real-ReShade addon load orders pass hidden startup, 8x -> 4x -> Off ->
  8x MSAA, ResetEx, scene/jitter comparisons and injected helper-failure fallback
  with Reflex On, a 60 base cap and 225 display ceiling. These fixtures have FG
  Off; gameplay resets with generation enabled remain a separate live check.

Scratch evidence: `tmp/asscreedbrotherhood-taa/reflex-pacing-first.log` (the
incorrect unconverted limit), `reflex-pacing-final.log`, `reflex-presentmon.csv`
and `reflex-transport-tests.log`. `test-reflex.cpp` in that directory records
QPC frame-start intervals and asserts a 3.5% rate tolerance after warmup.
`reflex-extra-final.log` covers 4x/5x and the low-cap transition regression;
`reflex-integration-hdr-first.log` and `reflex-integration-taa-first.log` record
the reset/load-order checks.
API references: [Reflex guide](https://github.com/NVIDIA-RTX/Streamline/blob/v2.14.1/docs/ProgrammingGuideReflex.md)
and [DLSS-G VSync guide](https://github.com/NVIDIA-RTX/Streamline/blob/v2.14.1/docs/ProgrammingGuideDLSS_G.md#220-vsync-with-frame-generation).

## 41. Release-oriented controls and live frame pacing (2026-09-18)

This section supersedes the menu, display-ceiling and overlay-pause policy in
sections 35–40. AA and reconstruction algorithms are unchanged.

- Menu order: Anti-Aliasing, Frame Generation, Reflex and Frame Pacing,
  Sharpening, Debug, Setup and Information, Links, About. AA, DLSS preset,
  FG multiplier and Reflex use dropdowns. DLSS preset is visible only for DLAA.
- Object-motion selection is removed from persisted settings; the existing
  optimized automatic object/static-camera classification always runs.
- DX12 starts automatically when the HDR output bridge and presenter are present.
  There is no DX12 toggle. Native-first startup handoff, graphics-reset recovery
  and failure fallback remain. Retry DX12 Output is available after failure.
  Standalone AA still uses native output; this is not a new standalone wrapper.
- FG input capture is automatic only while FG is selected. Developer export
  internals remain available in code, with no release-menu capture toggle.
- Reflex is forced exactly On both in the disabled UI dropdown and in the packet
  while FG is selected. The stored Off/On/Boost preference is not overwritten,
  and returns when FG is disabled. The sole limiter is Reflex Framerate cap
  (Before FG). Zero means no manual limit; there is no hidden display ceiling.
- The source Present sync interval passes through unchanged. Driver overrides
  still apply; this code neither configures nor detects G-SYNC. App profiles need
  to include the presenter executable. The confirmed-count Reflex interval
  conversion from section 40 remains essential, including during FG pauses.
- The overlay-open gate is removed. FG uses the existing HUD-less input plus
  final output containing HUD/overlay; no separate UI alpha layer is added.
  ReShade shader effects, invalid inputs, inactive window, resizing and unsupported
  VSync combinations still pause FG. Overlay appearance in gameplay needs live
  visual review; a successful generated-frame count alone is not visual proof.

### Telemetry and protocol

`frame_metrics.hpp` stores 240 completed-render intervals in a fixed ring under
presentation's existing mutex. No image readback, GPU waits or allocations are
added per frame. QPC timestamps are taken after successful output completion.
The overlay copies the ring under the lock and computes statistics after unlocking.
Before-FG FPS = sample count / elapsed seconds; after-FG FPS = summed confirmed
runtime presentations / the same duration. Samples cover up to roughly one second
(or the ring capacity at very high FPS). The plot shows rendered-frame intervals,
with average and P95 summaries, not individual generated-frame scanout timing.
Non-FG output counts one successful presentation; occlusion counts zero. Native
fallback samples are only recorded while DX12 output is inactive. Invalid/long
intervals and session restarts reset the ring; stale readings are hidden.

Presentation protocol **6**, packet **464 bytes**, removes display/VSync fields.
Update addon and presenter together. Removed legacy configuration keys are
ignored rather than rewritten: DX12Output, TAAMotionSource, ReflexDisplayFPS,
DX12VSync and FGInputCapture. AA/preset/FG/Reflex/base-cap/RCAS choices remain.

### Verification

- Clang syntax checks and linked Release addon/helper builds passed.
- Reflex policy tests cover forced On, restoring Boost with FG Off, unchanged
  source synchronization, no automatic ceiling, and confirmed-count interval
  conversion. Telemetry tests cover 60 rendered / 180 confirmed FPS, irregular
  intervals, missing outputs, wraparound, stale samples and reset behavior.
- Isolated actual DLSS-G GPU test passed 2x–6x and return to 2x: 509 active frames,
  including all 60 overlay-flag frames with synthetic UI in final color only.
  All 60 ReShade-effects pauses worked; missing inputs paused and resumed.
  The fixture required a Windows message pump to establish foreground correctly;
  earlier background runs correctly paused and are not FG success evidence.
- Both actual ReShade addon load orders passed native-first startup, 8x -> 4x ->
  Off -> 8x MSAA, ResetEx, scene/jitter equivalence and injected helper-exit
  fallback. The reversed-order fixture additionally set removed legacy options
  to conflicting values, including DX12Output=0; automatic DX12 still started.
- Game-specific menu appearance and overlay interpolation remain a live user
  check; these tests do not establish physical scanout timing or G-SYNC state.


## 42. FG resource audit, UI opacity and native-grid jitter (2026-09-18)

A synchronized live readback of the actual encoded HUD-less and final shared
images showed exact RGB equality throughout the scene, including Ezio and walls;
only HUD pixels differed. Earlier sequential live reads differed on animation
and foliage and were discarded as cross-frame evidence. The native source is
3840x2160 FP16 with finite signed HDR values. The final helper receives RGB10A2
PQ/BT.2020, matching final output. NVIDIA's Streamline 2.14.1 guide requires the
same color space/postprocessing for HUD-less and final color; FP16/scRGB is not
the supported final-output path. Do not convert only HUD-less to linear FP16.

### Depth, motion and jitter

The previous exporter point-sampled at UV + raster jitter but reported zero
jitter to Streamline. Point sampling does not actually remove fractional-pixel
jitter at surface boundaries. Export now uses the native raster grid, matching
DLAA's depth/motion preparation, and supplies actual pixel jitter separately in
`sl::Constants::jitterOffset`. Motion vector values remain previous-minus-current
normalized UV with jitter excluded, and camera matrices remain unjittered.
`motionVectorsJittered` and `motionVectorsDilated` are explicitly false.
Depth remains R32F D3D z/w, near zero/far one. Both inputs use the same visible
surface depth selection, including late object replay. Non-finite jitter rejects
the frame instead of reaching the SDK. This corrects the input contract; it is
not proof that all moving-surface artifacts disappear.

### Actual HUD opacity

After the verified final scene copy, clear a private DX9 R32F transmittance
texture to one. For known game HUD pixel shaders (7258C5E9, 5E3A6B72, FB5A6594,
AFDE4E3D) with standard source-alpha/premultiplied source-over blending, replay
the draw into this target using source ZERO, destination INVSRCALPHA and ADD.
Its red channel becomes product(1 - source alpha), preserving transparent holes
and overlapping opacity. Original UI shader alpha, textures, geometry, viewport,
scissor and alpha test are retained. Full state restoration leaves original RGB,
alpha, render targets and shader bindings untouched. No UI draws are replayed
until HUD-less capture succeeds, or while FG is Off.

Unknown shaders/blends, active depth/stencil, unsupported instancing, or capture
failures invalidate the optional mask for the frame. Do not infer opacity from
final-minus-HUD-less color. A DX11 MRT pass runs the existing HDR output function
for scene color and writes saturate(1 - transmittance) to a separate R32F texture.
The mask is exported as `kBufferTypeUIAlpha`; UI recomposition is enabled only
when that exact frame's mask was imported. The mask is zero outside HUD.
ReShade's open overlay disables only this optional mask, not FG: its own UI is
not in the game mask, so that path retains HUD-less inference. Arbitrary ReShade
shader effects still pause FG as before.

### Resource ownership and limits

Presentation protocol 7: Inputs 280 bytes, Packet 480 bytes; update addon/helper
together. Optional input bit 8 is UI alpha; required bits 1/2/4 remain unchanged.
DX12 imports motion RGBA16F, depth R32F, encoded HUD-less RGB10A2 and optional UI
R32F at full output resolution. Each resource is tagged in actual COMMON state
with eValidUntilPresent. Producer-copy fences precede DX12 use; the Streamline
input-consumption fence precedes acknowledgement and producer reuse. Capture
completion now includes the later UI draws. No production CPU image readback.
At 4K the extra DX9 mask, DX11 encoded mask and DX12 shared bridge each consume
about 31.6 MiB of GPU surface storage; UI replay adds draw/state overhead only
while FG is selected. Standalone AA/HDR upgrade rules are unchanged.

### Validation

Release builds passed. Camera tests verify actual jitter propagation and reject
NaN jitter. DX9 GPU tests verify zero-alpha coverage, overlapping alpha 0.75,
exact untouched original RGB, and render-target/blend restoration. Full transport
tests cover native depth/motion, signed FP16 scene copying, encoded zero HUD
alpha, DX12 checksums, state restoration, resize and stale-frame rejection. The
MRT encoder matches the unchanged HDR output shader pixel-for-pixel. Actual
DLSS-G GPU tests accepted the optional R32F mask, recomposition and mask/no-mask
transitions across 2x�6x; missing-input/effects pauses and overlay-active generation
also passed. ReShade reset/fallback tests passed. Gameplay improvement and actual
HUD coverage still require live confirmation; input validation is not a visual
quality guarantee.

### HUD-input isolation test result (2026-09-19)

A temporary Final Image Only mode omitted HUD-less color and UI alpha while
keeping depth, motion and pacing unchanged. Actual GPU tests passed 2x-6x,
including switching input modes. The user confirmed that this did not improve
the building artifacts, so the option and its helper bypass were removed.
HUD-less input is required again. Artifacts worsen with distance on decorative
building bands. A stationary live capture contained finite vectors with no
invalid/uncertain pixels and continuous wall depth; moving-frame correspondence
still needs verification. The optional UI-alpha coverage rejection is a separate
unresolved issue.

The subsequent moving capture at 3840x2160 contained no invalid motion pixels.
Across the visible decorative-band crop, exported FP16 motion agreed with CPU
camera reprojection (using the same captured R32 depth and camera constants)
within 0.015 output pixels. Depth ranged approximately 0.9952-0.9972 rather than
being clamped to 1. This validates export arithmetic, not correspondence with
the temporally resolved final color or DLSS-G's optical flow. Do not treat this
as proof that frame-generation input alignment is correct.

## 43. Standalone SDR frame generation and automatic VRR pacing (2026-09-19)

This supersedes the HDR-only presentation and no-automatic-ceiling limitations
in sections 40-42. It does not resolve the separate decorative-building motion
artifact investigation above.

### Native SDR presentation ownership

`standalone_present.hpp` selects its route once at swapchain creation, after
addons have loaded. It requires the installed DX12 presenter and declines when
any loaded module exports `RenodxEzioReadOutputParameters`. Detection uses the
HDR bridge export, not addon filename or load order. With HDR installed, the
existing DX11 path calls the same `presentation::PresentFrame` implementation.

Standalone creation requests DX9Ex and windowed presentation for the helper's
child flip-model window; it preserves the game's requested sync interval and
does not upgrade any game render target. Native device Present/PresentEx and
swapchain Present dispatch hooks run after ReShade finishes its scene and
overlay. They copy/resolve the completed X8R8G8B8/A8R8G8B8 backbuffer to a private
shared A8R8G8B8 texture. A DX9 event query completes before a matching-adapter
DX11 bridge opens the source. The common DX12 client submits BGRA8/sRGB output.
Existing source/consumer fences and acknowledgement prevent reuse while FG
still reads the frame. There is no CPU image transfer or SDR-to-HDR conversion.

Only a successful helper presentation suppresses native Present. Hidden startup
first permits a successful visible native frame, avoiding the earlier wrong-
window flicker. A helper failure destroys the child and resumes native output.
Reset destroys the client before releasing shared GPU resources and reselects
the new backbuffer. Known original dispatch slots are rearmed after driver
resets; unfamiliar hooks are not overwritten. A missing helper retains native
TAA presentation. Graphics resets and Retry DX12 Output can start a new session.

The first live standalone launch exposed a missing fullscreen-window step:
forcing `Windowed=TRUE` skips DX9's normal expansion of Brotherhood's tiny startup
HWND. Merely creating a valid 4K backbuffer and child swapchain leaves audio with
an unusable window. Preserve the original fullscreen request, queue borderless
sizing at initialization/reset, and call the existing windowing utility once the
game is visible and foreground. Size to the actual monitor under per-monitor
DPI awareness before allowing the DX12 handoff. Clear the pending flag before
resizing because window messages can reset the device. Genuine windowed requests
retain their window size. A new regression starts with a 1x1 fullscreen HWND and
shrinks it again before ResetEx; both recover to exact monitor bounds.

On normal swapchain destruction/unload, resources are released explicitly.
At `ExitProcess` (`DllMain` detach with non-null reserved), remaining output
owners are abandoned to process cleanup: releasing DX9 shared resources under
the loader lock can wait forever for driver workers Windows already terminated.
This path is used only during process termination; Windows reclaims allocations
and closes job handles, terminating the helper. The exit regression must check
actual process completion, not just the fixture's final PASS message.

### SDR scene and UI inputs

The native standalone final scene can be the swapchain backbuffer, which is a
surface without an `IDirect3DTexture9` container. `CaptureHudless` copies it to a
private matching-format render-target texture outside BeginScene, then restores
the scene boundary before running the existing capture pass. Private FP16 stores
the original SDR code values; it does not imply a linear-light conversion.

`fg_sdr.ps_5_0.hlsl` copies those values to BGRA8 and converts the existing R32F
HUD transmittance to opacity in a separate MRT. The final and HUD-less color now
share format, color space and postprocessing without the HDR addon. With HDR,
`fg_hudless.ps_5_0.hlsl` still uses the existing HDR output function. The helper
accepts native BGRA8/RGBA8 SDR or RGB10A2 HDR10 for FG; ordinary scRGB presentation
remains supported but scRGB frame generation remains unsupported. Protocol 7,
optional UI-alpha rules, depth/motion conventions and input lifetimes are
unchanged. Unknown HUD draws can still reject the optional mask.

### Effective driver policy and Reflex limit

The separate presentation process must honor the game's effective driver
preferences. `presentation_helper/display_policy.hpp` reads the parent game's
executable name, resolves its NVIDIA DRS application profile (falling back to
the base profile), and reads VSync and VRR settings. It does not modify profiles.
Forced VSync On/Off controls the helper Present interval; other settings retain
the game's source interval. VRR also requires the actual window's monitor to
report VRR capability. Fullscreen-only G-SYNC additionally requires a monitor-
covering client rectangle; per-monitor DPI awareness keeps this test correct.

With VRR permitted, VSync active and Reflex On, apply an automatic displayed-
frame interval of `ceil(1,000,000 / refresh_hz) + 300` microseconds. The 0.3 ms
headroom is an explicit integration policy, not a driver-reported 225 FPS value.
At 240 Hz it produces about 223.86 FPS. Take the larger of this interval and the
user's base interval divided by the previously confirmed FG presentation count.
Do not divide the automatic interval by the FG multiplier again. This preserves
60-before-FG / 180-after-FG at 3x, while cap 0 still respects VRR headroom. If
VSync/VRR/Reflex is disabled, no automatic headroom is imposed. Runtime FG pauses
continue to use confirmed, not selected, multipliers for the manual cap.

Read the driver/display state once at startup and then on a background worker
every five seconds. Per-frame Apply copies only a small mutex-protected snapshot.
DRS polling on the render thread caused measurable periodic stalls and was
removed. The driver can report VRR Requested=0 for the child/background helper
even when the display reports InVRRMode=1. The game's profile supplies the user's
request; the monitor query supplies capability. This does not prove physical
VRR scanout or input-to-photon latency. No separate sleep limiter is introduced.

### Verification

- Release addon and presenter compile with Clang. Persistent pacing regressions
  cover 240/144 Hz, 2x/3x/6x, manual cap precedence, forced VSync Off, follow-game
  VSync Off, VRR unavailable and Reflex Off, without changing driver settings.
- Actual SDR DLSS-G GPU execution passes 2x-6x, with 509 active frames including
  60 overlay-active frames; missing inputs and ReShade effects pause and resume.
- Foreground Reflex GPU test on this RTX 5090 / 240 Hz display measures 223.86-
  223.89 output FPS with cap 0 at 2x/3x/6x. At 3x, manual 60 measures 59.996
  rendered FPS, and manual 45 measures 44.996. All 1,019 active frames complete
  without a feature failure. These are throughput measurements.
- Native SDR non-texture backbuffer capture preserves every tested BGRA8 pixel
  exactly through HUD-less capture, encoding and DX12 import; EndScene still
  succeeds afterward. HDR MRT output still matches the original output shader
  pixel-for-pixel. Depth/motion, state restoration, resize and stale rejection
  tests also pass.
- Real ReShade integration passes standalone SDR and both HDR addon load orders:
  native-first startup, 8x -> 4x -> Off -> 8x MSAA, ResetEx, scene/jitter
  equivalence, injected helper-exit fallback and actual clean process exit.
  These reset fixtures use FG Off; they do not replace gameplay FG tests.
- Live standalone SDR at 3840x2160 confirms 3x FG with the HDR addon disabled:
  a 60 base cap measures 59.93 rendered FPS (about 179.8 output); cap 0 measures
  73.96 rendered FPS (about 221.9 output), below the automatic 223.86 ceiling.
  The helper reports native BGRA8/sRGB, accepted scene/depth/motion, three
  confirmed presentations, VSync On from the driver despite source interval 0,
  VRR enabled and no FG error. The optional alpha mask is accepted only on
  covered UI frames, as designed. Focus/reset and HDR gameplay checks follow.

Live HDR10 also confirms the same 3x route: 60.01 rendered / about 180 output FPS,
with accepted inputs, three confirmed presentations and no reported FG error.
The user reports normal output and the expected automatic ceiling after Alt-Tab.
The subsequent sampled interval had the manual cap restored to 60, so the numeric
HDR measurement above is for that cap. Native reset logs show HDR ownership and
suppression of duplicate native DX9 presentation. Standalone resolution changes
also resume FG with the automatic 4467-us output interval still active.

## 44. Restore static geometry motion for frame generation (2026-09-19)

The user requested fuller object-motion coverage to test the remaining distant
decorative-building artifacts. The previous optimization recorded static draws
but omitted their GPU motion replay when matching poses, unchanged buffers and
native depth established that camera reprojection should suffice. In one live
frame this omitted 619 of 876 captured draws. This is a separate investigation
from the standalone and pacing corrections in section 43.

`RenderObjectMotion` now accepts `replay_static`. The native resolve enables it
while FG is selected and DX12 output is available, including for the motion
preview. It suppresses only the `camera_only` draw-omission decision. Supported
rigid geometry, building LODs, cutouts, characters, cloth and vegetation use the
same verified original-position replay as before, including opacity, clipping,
depth/stencil and viewport rules. Per-pixel geometry motion and complementary
depth feed the existing dense-motion exporter; uncovered pixels and sky retain
camera fallback. Missing/ambiguous history remains marked rather than invented.

No extra replay pass, velocity target or palette allocation is added. Existing
shader/declaration caches, redundant-state suppression, batched bone atlas,
immutable partial-upload snapshots and bounded geometry storage remain. More
draws enter the replay, so CPU/GPU cost can increase. FG Off returns immediately
to static-camera omission without discarding captured pose history. No new
motion-source setting is exposed in the release UI.

GPU regression covers the same stationary mesh with a moving camera under both
native depth and MSAA-prepass visibility: full replay produces the expected
horizontal motion and actual complementary depth; AA-only mode omits the draw;
repeated policy changes preserve both results. Existing static/moving/buffer-
mutation/late-geometry/camera-cut gates, sky rotation and out-of-frustum vector
checks also pass.

Live HDR10 gameplay with DLAA and 3x FG confirms `fgGeometryMotion=1` and
`cameraOnlyDraws=0`. A sampled frame replays all 695 captured draws (529 rigid,
166 skinned, no unmatched history) with `motionReady=1` and `shaderParses=0`.
The helper accepts scene/depth/motion and reports three presentations with no
FG error; cap 0 retains the 4467-us automatic interval. The packet timing sample
was taken while frame progression had stopped, so it provides no live FPS
measurement for this build. The user reports no improvement in the decorative-
building artifacts, but requested retaining the expanded geometry path. It
remains enabled for FG; the static-camera optimization still applies with FG Off.
This experiment does not resolve the building artifact.
