# Adding object motion vectors to an existing DX11 game

**Start with the [DLSS integration playbook](DLSS_INTEGRATION_PLAYBOOK.md)** for
the complete implementation order, acceptance gates, failure lookup and evidence
index. This document is the detailed object-history/coverage companion.

**Current-state correction (2026-10-23):** coherent Halton jitter, real scene
upscaling, Map recovery, opaque horse tails and foliage wind/contact are now
implemented. The user accepts broad moving-object coverage and the later
constant-cache performance correction. Vegetation exclusion currently defaults
off; the profiling button/runtime sweep was removed. Older dated counts,
two-phase jitter descriptions, default-enabled exclusion and pending-work notes
below describe earlier checkpoints, not the current configuration. Explicit
camera-cut handling, scoped mip bias, soft-transparency policy and wider scene
acceptance remain open. See the playbook and top of the handoff for current status.

Implementation reference from The Witcher 3 Classic 1.32, updated 2026-10-23.
This describes the implemented code, evidence, failures and remaining limits;
it is not a claim of complete coverage or a portable patch for another engine.
The current installed binary and next live tests are in the
[Classic handoff](WITCHER3_CLASSIC_HDR_HANDOFF.md).
Primary-source guidance is collected in the
[research notes](WITCHER3_CLASSIC_MOTION_VECTOR_RESEARCH.md).

## Integration and source map

### Preserve native pixel-stage frame constants

The 2026-10-26 Classic lighting audit found a general integration trap: motion
draws rebound PS b12 to the current VS b12 frame buffer. The two may share a
layout and size while carrying different lighting/fog values. Native material
color can then change even if all decompiled material math is equivalent.
Keep native stage bindings intact and supply motion-only data through a separately
audited slot. Classic now uses **PS b11** for the same current VS-frame bytes,
saving/restoring that slot around non-foliage draws; native PS b12 is untouched.
VS b11 is still previous-frame history. The four foliage material paths retain
their native frame macros. There is no change to vector math or coverage.

Regression fixtures must use **different native VS and PS frame buffers**,
verify both identity and material output, and check restoration of the motion
slot. A fixture sharing one frame buffer between stages masks this class of bug.
Reflect every native shader before reserving a slot: Classic's 113 non-foliage
PSs leave b11 unused, but this is not a portable assumption. Full object and
foliage checks pass WARP/NVIDIA. In the reported Geralt scene the native buffers
actually matched, and this isolation alone did not resolve the lighting report.
The proven cause was the shader-decompilation issue below. See the
[BlitzFX handoff](WITCHER3_CLASSIC_BLITZFX_COMPATIBILITY.md).

### Preserve integer flags and test directional environment lighting

Appending motion outputs must preserve every original shading output, including
vertex-stage lighting. Classic's hair shaders calculate environment lighting in
the VS, so testing only PS color math or exact clip positions missed the defect.
An original shader comparison must preserve other addon replacements: DevKit's
current global live-unload removes addon runtime replacements too. Restore only
the shader under comparison, or restore the full embedded set before continuing.

The legacy decompiler printed native `and r3.x, r2.w, l(1)` as
`r3.x = r2.w ? 0.000000 : 0`. It interpreted integer bit-pattern 1 as a float
subnormal and rounded it to zero. The native program subsequently converts the
integer to float for an environment-atlas hemisphere offset. Correct HLSL uses
the numeric flag `r2.w ? 1.f : 0.f` in this decompiler's float register model.
Audit the native producer **and consumer** before changing a literal: an integer
flag, an actual float subnormal and a packed float bit pattern have different
semantics. Do not replace every small number or zero by pattern alone.

The Classic audit proved 64 such sites in eight hair/tail/forward-material
programs. `tools/audit_probe_hemispheres.py` compares exact register/condition
pairs against original DXBC. `tests/probe_lighting.cpp` compares all native VS
varyings using captured frame/lighting constants, gradients across both atlas
hemispheres, varied normal/tangent directions and explicit nonzero finite-lighting
assertions. Constant-color atlas samples conceal wrong-coordinate bugs. Also put
synthetic geometry **inside the native lighting frustum**: otherwise attenuation
can zero both shaders and create a false pass. The captured skinned hair origin
includes mesh decode scale/offset; a deformed tail consumes positions directly.

The old controlled hair fixture differed by up to .199998 in linear lighting.
Corrected hair, reference hair and both deformed tail VSs match native outputs
exactly on WARP/NVIDIA. Full motion tests retain native positions, cutouts and
history; the user confirmed correct hair/eye lighting and valid vectors live.
The correction changes coordinate selection, adding no draw, replay or resource.
Reproduction and fixture files are specified in the game test README and the
BlitzFX compatibility handoff; fresh-launch packaged acceptance is separate from
live shader acceptance.

### Native reconstruction boundary

Classic already uses DX11. The addon evaluates NVIDIA NGX directly on the game's
device at native TAA pixel shader `201C53B4`; it needs no DXVK or API wrapper.
Native AA must remain enabled so that draw exists. The camera-only replacement
works in-game. Native motion-blur shader `C3F99418` reconstructs camera motion
from depth; inspection did not find a complete animated-object motion field.
Previous object state therefore had to be recovered and retained separately.

All paths below are under `src/games/thewitcher3classic/temporal/`:

| Responsibility | Implementation |
|---|---|
| Native camera contract, executable guards | [camera.hpp](../src/games/thewitcher3classic/temporal/camera.hpp) |
| Draw interception, pass selection, TAA replacement | [runtime.hpp](../src/games/thewitcher3classic/temporal/runtime.hpp) |
| Native identity/lifetime/submission hooks | [object_engine.hpp](../src/games/thewitcher3classic/temporal/object_engine.hpp) |
| Bone allocation and previous pose history | [object_history.hpp](../src/games/thewitcher3classic/temporal/object_history.hpp) |
| Per-proxy worlds and exact batch association | [rigid_history.hpp](../src/games/thewitcher3classic/temporal/rigid_history.hpp), [rigid_motion.hpp](../src/games/thewitcher3classic/temporal/rigid_motion.hpp) |
| CPU-deformed cloth GPU history | [deformed_motion.hpp](../src/games/thewitcher3classic/temporal/deformed_motion.hpp) |
| Full-population flock identity | [swarm_history.hpp](../src/games/thewitcher3classic/temporal/swarm_history.hpp) |
| Wind/contact inputs and shared constant history | [foliage_motion.hpp](../src/games/thewitcher3classic/temporal/foliage_motion.hpp), [constant_uploads.hpp](../src/games/thewitcher3classic/temporal/constant_uploads.hpp) |
| Main-view sizing, coherent jitter, menu recovery | [upscale_engine.hpp](../src/games/thewitcher3classic/temporal/upscale_engine.hpp) |
| MRT allocation, binding and restoration | [object_motion.hpp](../src/games/thewitcher3classic/temporal/object_motion.hpp) |
| Previous-position math | [object_vertex.hlsli](../src/games/thewitcher3classic/temporal/object_vertex.hlsli), [rigid_vertex.hlsli](../src/games/thewitcher3classic/temporal/rigid_vertex.hlsli), [deformed_vertex.hlsli](../src/games/thewitcher3classic/temporal/deformed_vertex.hlsli) |
| Vector/depth output | [object_pixel.hlsli](../src/games/thewitcher3classic/temporal/object_pixel.hlsli) |
| Camera/object merge and NGX inputs | [prepare.hpp](../src/games/thewitcher3classic/temporal/prepare.hpp), [dlss.hpp](../src/games/thewitcher3classic/temporal/dlss.hpp) |
| Reviewed native shader interfaces | [object_shaders.hpp](../src/games/thewitcher3classic/temporal/object_shaders.hpp) |
| GPU and CPU regressions | [tests/object_motion.cpp](../src/games/thewitcher3classic/tests/object_motion.cpp), [tests/object_history.cpp](../src/games/thewitcher3classic/tests/object_history.cpp) |

## Resolving an ambiguous forward-skin family (2026-10-23)

A paused NPC capture exposed a collar/upper-chest coverage hole. The active
unregistered VS `BC187223` used the already supported opaque forward PS
`EB8C3FAE`, one RGBA16F scene target and disabled blending. Its second captured
occurrence supplied the nearby NPC's separate mesh/instance data. The exact
post-AA coverage image and bounded geometry captures are saved under
`tmp/witcher3classic-investigation/temporal-dev/neck-20261023`.

The offline position fingerprint matched `95D8CC2E`, `9BA913EE` and `FF64C197`,
but those references belong to groups 6 and 11. The generic scan correctly
refused an ambiguous group assignment. The observed forward pairing justifies
a **targeted** group-11 audit using `FF64C197`; it does not justify accepting
all ambiguous shaders or weakening runtime pass validation.

`audit_motion_families.py` now supports `--vertex-reference` and a separate
`--vertex-list`. The focused scan of 2,188 skin VS found 12 matching candidates:
three existing hand-audited entries and nine additions. Those additions are in
`object_forward_skin_families.inc`. Their original shader bodies retain native
lighting/fog and current position; the existing previous-bone/world helper is
appended. Main depth, viewport, opaque blending and matching PS checks remain.
There is no new runtime scan, readback, hook or geometry replay.

```powershell
python src/games/thewitcher3classic/tools/audit_motion_families.py tmp/witcher3classic-investigation/temporal-dev/stability-20261023/cache-audit --vertex-reference 0xFF64C197 --vertex-list object_forward_skin_families.inc --generate-vertices --test-originals tmp/witcher3classic-investigation/temporal-dev/devkit-live/dlss-audit
```

Review the generated sources and run the GPU fixture before linking. A generic
report-only run still reports these hashes as ambiguous; the focused report
records the specific resolution, and is saved separately in `neck-20261023`.
The generic generator now rejects group 12 rather than emitting its wrong
TEXCOORD10/11 layout. Its group-12 recipe remains pending.

Two validation lessons from this family:

- Reflect native DXBC output masks for stream-output comparisons. Decompiled
  `float4` declarations may include unwritten W lanes, while sibling fog
  variants genuinely write those lanes. Assuming one width for both either
  misses outputs or fails stream-output creation.
- Populate valid fog constants in synthetic fixtures. All-zero exponents can
  produce `0 * log2(0)` in otherwise unchanged native fog varyings. Fix the
  fixture rather than altering game shading or relaxing finite-value checks.

The expanded fixture compares forward native color/alpha, vector/depth outputs,
and target restoration as well as all written VS varyings and raw clip bits.
Post-restart visual verification remains necessary; unposed mesh bounds and
shader-family matches alone do not prove that the reported hole is fixed.

## Establish the temporal contract first

Capture the actual TAA draw before replacing it: shader, CB contents, texture
dimensions/formats, subresources, viewport and input/output use. Inspect camera
stillness, camera motion, root motion and animation separately. A texture named
velocity or a plausible matrix is not evidence of the correct frame or units.

Classic's camera shadow is 2,880 bytes at executable RVA `2CCB750`, matching all
720 live constant words. Ghidra analysis of `C48810` and `C51AF0` established its
assembly/copy path. The original native jitter was two-phase, +/-0.25 pixels;
`upscale_engine.hpp` now supplies coherent Halton jitter before rendering.
NGX still receives the negative actual camera-shadow jitter. These findings
are game-specific; see the playbook for the current phase and scope contract.

The shader contract is UV displacement **previous minus current**, without
camera jitter. In Classic's native frame layout:

```text
current_uv = SV_Position.xy / current_frame[23].xy
             - current_frame[15].xy * (0.5, -0.5)
previous_clip.xy -= previous_frame[15].xy * previous_clip.w
previous_uv = previous_clip.xy / previous_clip.w * (0.5, -0.5) + 0.5
motion_uv = previous_uv - current_uv
NGX motion scale = (input_width, input_height)
```

Use the exact previous rendered pose and camera, not the previous simulation
tick or whichever CPU buffer happens to contain old data. Check sign, scale,
Y orientation, jitter and previous-frame alignment with known synthetic motion
and real reprojection. Reverse-Z hardware depth is supplied with the matching
NGX depth convention. Motion is `RG16_FLOAT`; signed object depth is `R32_FLOAT`.

`RG16_FLOAT` means half precision, not half spatial resolution. NVIDIA's
low-resolution-motion flag refers to render/input-resolution vectors when
upscaling. It is not permission to halve a native-resolution DLAA vector field.
Retain input-resolution coverage until a documented alternative is validated.
See the [NVIDIA DLSS programming guide](https://raw.githubusercontent.com/NVIDIA/DLSS/main/doc/DLSS_Programming_Guide_Release.pdf).

## Append outputs to the original visible draw

The implementation adds previous clip position and a history-valid marker to
the native VS interface, then writes motion to MRT3 and signed surface depth
to MRT4 in the native PS. It does not replay geometry or introduce a per-object
render pass. The original material and native current-position calculations
remain in place. Native alpha tests and LOD discards execute before new output.

Runtime eligibility checks include the actual main depth resource, full scene
viewport, native target layout and matching VS/PS interface group. Shadow,
auxiliary and unrelated passes cannot be selected merely by shader hash.
Opaque forward passes additionally require one scene target, disabled blending
and a full color write mask. A VS may serve both G-buffer and forward materials:
the current implementation selects forward handling from `vertex.forward ||
pixel.forward`, rather than assuming the VS alone determines the pass.

Preserve native depth, stencil, rasterizer, alpha/LOD behavior, UAVs and resource
bindings. Restore modified CB/SRV bindings after each augmented draw; target
attachments can stay across a compatible native batch and must be restored at
its boundary (see `ClosePass`). Restore the full native context around NGX preparation,
evaluation and conversion. Tests explicitly exercise restoration.

Some native material families need different varying widths or register order.
They have separate signature groups even where semantic names look alike.
Most motion varyings use TEXCOORD10/11; group 12 uses TEXCOORD12/13. Never append
an occupied semantic or assume HLSL declaration order is irrelevant to compiled
DXBC register linkage.

## Preserve current clip position exactly

A replacement can compile, look correct and still fail native depth EQUAL.
Appending outputs can change optimization and floating-point evaluation of the
original position. A loose color/varying tolerance will not detect that failure.

For opaque hair VS `B0B4EB6F`, the new test consumes all original varyings and
motion outputs. With the earlier source, 10 of 96 clip components differed on
WARP. Adding `precise` alone produced zero WARP differences but 27 on NVIDIA
hardware. The final source marks the native position output precise and retains
27 explicit native `mad` operations in the position-producing prefix. This
preserves native fused arithmetic while preventing reassociation. Both devices
then report zero differences in the tested cases. Native depth EQUAL stays intact.

The broader G-buffer regression compares raw position bits across camera/world/
bone cases; the forward test must also consume all outputs so optimization
resembles the actual replacement. Test both WARP and the real GPU. These cases
guard known inputs; they do not prove every possible material or scene.
Microsoft documents the optimization constraints of
[`precise`](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/precise).
Inspect compiled arithmetic as well as source when repairing native equivalence.

Decompilation can also corrupt constant-buffer addressing without preventing
compilation. BlitzFX hero skin `90BFECE8` retained a local-light loop register
in eight later sun-direction reads that original DXBC encodes as `cb13[0]`.
This turned Geralt's face brown after Igni with Object Motion enabled; disabling
motion restored the original material immediately. Audit fixed versus relative
cbuffer operands against disassembly, including after dynamic loops. Exercise
zero, multiple, fading/outside-radius lights and different final list indices:
zero-light or contributing-light-only tests can accidentally leave/truncate
the register to zero and hide the defect. See
[hero_lighting.cpp](../src/games/thewitcher3classic/tests/hero_lighting.cpp) and
the [BlitzFX handoff](WITCHER3_CLASSIC_BLITZFX_COMPATIBILITY.md) for provenance.

## Identity and history by deformation path

The central rule is to identify a persistent native owner and its generation,
then map the current draw back to it. Draw order, world-matrix equality, palette
offset, GPU ring-buffer address and visible-instance index are not object IDs.

| Path | Previous data | Stable association | Important failure fixed |
|---|---|---|---|
| Ordinary skinned mesh | Bones plus per-instance world | Bone allocation identity plus exact proxy/mesh submission | Shared palettes and changing offsets cannot identify each world |
| Reference-pose skin | Bones, world, previous reference-position texture | Same owner history plus native reference blend | Reusing current reference data loses deformation motion |
| Rigid attachment/identity-palette prop | Previous world | Native proxy and validated mesh, including direct submissions | Palette zero can still be a moving mill or sword fitting |
| CPU-deformed Apex cloth | Previous GPU vertex positions and world | Persistent Apex owner/generation plus retained UV stream | Rotating render resources and A/B/C position/index buffers are not actors |
| Flock bird | Shared previous bones plus independent previous world | Swarm owner and full-population slot before visibility sorting | Visible-instance order changes when the camera moves |

### Bones, worlds and reference positions

Bone allocation history maps the current palette base to the previous allocation
base. Native pose GPU storage may rotate without changing allocation identity.
Allocation destruction erases history; size changes, missing previous frames
and ambiguous world observations invalidate it. Palette validity is separate
from world validity so shared-palette flock instances can supply their own world.

Native bone records contain 16 floats, but element 15 is shading metadata.
The native position path substitutes homogeneous W = 1. Multiplying by that
metadata caused false motion on stationary characters. Preserve the native
four-influence normalization and reference-position blend. Ignore unused
out-of-range indices only when their weights are zero; validate used indices.
Reference-position textures are single-row RGBA32F and bounded by the audited
layout; history retains the previous texture, not merely its transient address.

Rigid history is per native proxy with a validated mesh. Overlapping parts and
newly visible parts retain independent validity; a new part must not invalidate
existing valid parts. Destruction, owner reuse, mesh change and frame gaps reject
stale state rather than matching a nearby transform.

The instance hook observes native packing before and after an append, checks
that exactly one instance was added, and records identity in reusable TLS CPU
sidecars for the engine's 64/80-byte packing arrays. Renderer, mesh, frame, count
and CPU-array checks associate the later batch with those identities. Array
reallocation preserves indexed sidecar entries. No approximate matrix search is
needed. A wholly stationary 64-byte rigid batch takes the camera-vector fast
path even in the diagnostic view; a stationary 80-byte skinned batch still needs
bone deformation motion.

### CPU deformation and flocks

Cloth captures GPU copies of the deformed positions and the native world CB.
The persistent Apex owner scope survives render-resource rotation. Owner
generation and the retained immutable UV buffer distinguish lifetime/mesh.
The audited layout checks include 40-byte position stride, 8-byte UV stride,
matching vertex counts, R32 indices, expected offsets and a 128-byte world CB.
The implementation uses at most 128 histories/32 MiB and only the immediately
previous frame; stale entries are reclaimed after 120 frames. No production
CPU texture or vertex staging readback is required.

Flock type 14 (`CRenderProxy_Swarm`) shares a bone palette across independently
moving birds. Hook the full 44-byte instance array before culling/sorting and
retain worlds by full-array slot. Observe the result of the original native
Euler calculation rather than calculating extra trigonometry per bird. Native
array pointer rotation and visible-order changes no longer change identity.
Producer-side population reorder with unchanged size is not fully audited and
remains a limitation to investigate if that symptom appears.

## Native hook contract and lifetime

These are RVAs for the investigated GOG Classic binary only, not signatures or
offsets to transplant into another game:

| RVA | Observed purpose |
|---|---|
| `C5AFA0` | Instance append/submission |
| `C669C0` | Bone allocation destruction |
| `116CDC0` | CPU-deformed owner scope |
| `CEFCA0` | Native proxy destruction |
| `C5A4F0` | Packed batch submission |
| `C63310` | Swarm submission |
| `1FCA80` | Native Euler result observation |
| `BDDC80` | Direct draw owner scope |
| `2BCBB48` | Bone allocation registry data |

Investigated executable SHA256:
`5112253787FBD927ECB979207EFB91B99BCC9C7B041106B51285136BAB41E1F7`.
The camera guard checks PE timestamp `5BDF65B7`, image size `3673000` and native
function prefixes. Each hook prefix is checked before Detours attachment.
Unrecognized executables retain the safe native path. Verify both disassembly
and live data before adding another hook.

Hook state contains CPU history, not ReShade/GPU objects. Hooks can still run
during native teardown after ReShade device destruction; the module/state have
process lifetime. When disabled they forward to the original functions without
capture work. Native TAA releases test GPU resources. Nested owner/batch scopes
restore their previous TLS state; tests cover scope restoration and destruction.

Current extra bindings are VS t120 previous bones, t121 palette lookup, t122
pose entries, t123 previous reference positions, t124 previous CPU-deformed
positions and t125 previous instance worlds; b8 metadata, b9 deformed world,
b10 previous camera and b11 previous frame. PS b11 supplies non-foliage motion
frame data while PS b12 retains native lighting/fog state. These slots are
audited Classic choices, not universally free registers.
ObjectPose is 64 bytes. Allocation history is bounded at 4,096, rigid history at
8,192; packed batches are bounded at 4,096. Flock history is bounded at 256
owners/8,192 total slots, at most 4,096 per owner.

## Find whole shader families offline

Camera movement changes visibility, LOD and material permutations. Correct
history cannot repair a draw whose VS or PS replacement is absent. The user
confirmed a large stability improvement after the family revision.

The [tools](../src/games/thewitcher3classic/tools/) provide a reproducible audit:

1. `audit_motion_cache.py` scans installed content/DLC caches read-only, validates
   DXBC headers/part bounds, hashes bytecode with RenoDX CRC32, detects collisions,
   inventories signatures and exports immutable originals to ignored scratch.
2. Decompile SM5 DXBC with `bin/cmd_Decompiler.exe -D` in bounded batches. Keep
   original CSOs outside game source/live-replacement directories.
3. `motion_fingerprint.py` resolves all four native position outputs into scalar
   expression graphs. It ignores temporary register naming and unrelated
   material calculations, but retains semantic/type, buffer/matrix addressing,
   weights, reference loads and arithmetic dependencies.
4. `audit_motion_families.py` requires a matching complete position expression
   and an unambiguous audited native interface. Pixel matching also checks
   semantic/index/component/register/mask, declaration order and a single exit.
   Generation appends shared motion logic to the native body, never a generic
   replacement of native position or material math.
5. Review generated source, compile, compare native outputs and inspect actual
   draw coverage. A fingerprint match is a conservative discovery aid, not a
   formal equivalence proof or permission to patch every BLENDINDICES shader.

At the initial family checkpoint, the installed 31 caches contained 8,368 unique shaders, including 2,188 skinned
VS across 80 output layouts. The deployed family lists contain 46 generated
VS and 81 generated PS additions. Including hand-reviewed profiles, the current
addon had 78 VS and 103 PS registrations. Later neck/tail/foliage work expands
those counts; inspect current tables rather than treating this as the final inventory.
Sorted tables are built once and
queried with binary search; no cache scan, decompiler or compiler runs in-game.

The latest fingerprint tool poisons branch/loop-written register lanes rather
than rejecting unrelated control flow. Dependencies on uncertain writes remain
unresolved. Its latest report-only run finds 80 eligible VS, including 21 extra
candidates beyond the earlier 59. **Those 21 have not been generated or deployed.**
The generator still needs explicit semantic selection before extending to
group-12 opaque-hair interfaces. Never conflate a later report with installed
source. Six Python tests cover expression invariance and conservative rejection.

Example commands from repository root; replace scratch and installation paths:

```powershell
python src/games/thewitcher3classic/tools/audit_motion_cache.py <content> <DLC> --output <scratch> --originals <native-CSO-archive>
python src/games/thewitcher3classic/tools/audit_motion_families.py <decompiled-scratch>
# Review first; generation is explicit and can change game-local sources:
python src/games/thewitcher3classic/tools/audit_motion_families.py <decompiled-scratch> --generate-vertices --generate-pixels --test-originals <native-CSO-archive>
python src/games/thewitcher3classic/tests/motion_fingerprint.py
cmake --build --preset clang-x64-release --target thewitcher3classic
```

## Merge depth and diagnose the right failure

The object MRT stores signed depth: negative marks unavailable history; -2 is
uncovered. Preparation compares absolute object depth against final native depth
with the audited 2e-7 tolerance, rejecting occluded surfaces. Uncovered pixels
use camera motion. Invalid/nonfinite or excessive vectors are rejected rather
than clamped into apparently valid motion. Missing history sets current-color
responsive bias. It must not become a blanket substitute for missing opaque
geometry vectors.

The raw diagnostic view shows valid zero motion in gray, motion in color,
invalid history in amber and no coverage dark. It is before the final depth
merge. Dark gaps require shader/material/depth/overwrite investigation; amber
requires identity/palette/reference/deformation/frame investigation. Stable
colors alone do not prove correct final reprojection or DLAA image quality.

DevKit snapshots and readbacks have limits. A live resource read after a draw
can see a reused texture, not its contents at that draw. Exact before-draw
captures must preserve resources and constants with bounded lifetime. Private
addon MV/depth SRVs are not currently registered in DevKit; logged pointers
cannot be passed as tracked resource-view handles. Do not bypass validation.
Use an explicit debug output or proper lifetime-aware registration if needed.

Long captures are essential for intermittent failure. Record sample timestamps,
diagnostic mode, camera action, shader pair, frame identity and history reason.
The original 58-image/30-second NPC trace was sampled at about 2 FPS, not a
full-rate video. In the later family sequence only samples 0-11 are vector
view; the resource switches to normal gameplay from sample 12. Do not report
the whole 30-second sequence as proof of continuous vector coverage.

## Validation and cost

Compile fixtures from an x64 VS developer shell using the README commands with
assertions enabled. Run the GPU fixture against immutable native CSOs both on
WARP and with `--hardware`. Its normal run covers material colors/discards,
bone/root/camera motion, reference poses, rotating cloth buffers, direct props,
flocks, exact batch ownership, MRT restoration and final-depth merge. Focused
`--forward-only` and `--hair-clip-only` runs isolate these latest paths.

The current regressions include 14,976 exact G-buffer clip-component comparisons
(52 VS x 24 cases x 12 components), plus 96 comparisons each for four forward VS
with all varyings/motion consumed. They pass on WARP and NVIDIA hardware in the
documented runs. The final full WARP run and focused final hardware eye/hair
runs pass. Fifteen nonfinite native color channels in synthetic mixed-material
fixtures match classification; they are reported separately, not proof of
finite live material behavior. The CPU fixture tests ownership/lifetime and
ambiguous/new/reordered/overlapping parts. Tests are offline, not game overhead.

Production work uses once-per-frame previous bone copies/lookup uploads,
bounded history, reusable sidecars and the original geometry draws. Stationary
rigid geometry stays on camera reprojection. Extra moving coverage still costs
MRT bandwidth and history handling. No matched-scene CPU/GPU timing has been
recorded. Measure diagnostic/capture-off gameplay with identical camera paths,
resolution and DLAA settings; report render-thread and GPU costs separately.

For another game, reproduce the evidence chain: temporal contract, exact native
position, persistent owner/lifetime, previous deformation, complete visible
material families, depth-correct merge, final reprojection and measured cost.
Do not copy Classic offsets, layouts, resource slots or tolerances blindly.

## CPU-deformed opaque horse tails (2026-10-23)

Roach's tail demonstrates why a skin-only family scan is insufficient. The
live `5CC0DB95 / 9B839F3B` draw uses no blend indices, weights or bone SRV.
It runs inside the already hooked Apex deformation function (`116cdc0`, return
address `116d237`) with a stable UV stream (stride 8, 18,464 bytes), deforming
position/normal/tangent stream (stride 40, 92,320 bytes), 32-bit indices and
128-byte world constants. The captured 6,360-index mesh projects onto the
visible tail: x 1236–1386, y 905–1470 at 3840×2160. That identifies the actual
mesh rather than guessing from a hair pixel shader's name or signature.

The draw has one color target and blending disabled. Its alpha-tested material
rejects alpha below .33. Register it as `deformed=true, forward=true`, group 14,
and append `PreviousDeformedClip(SV_VertexID)` through TEXCOORD10/11. Reuse the
existing persistent Apex owner/generation + immutable UV-buffer identity,
previous position/world ping-pong buffers and primary-view guards. The native
draw writes the existing motion/depth MRTs. No new hook, readback, redraw or
runtime family scan is needed; this mesh adds two 92,320-byte GPU history
buffers and one position-buffer copy per observed frame, plus existing world
and metadata operations. This is a resource estimate, not a timing result.

The offline scan compared native DXBC input/output signatures against all
8,368 entries in the existing readable cache inventory. One further VS,
`AE216EAE`, matches the full position fingerprint and interface. Its source
diff only changes a lighting comparison from 1 to .999000013; preserve each
variant's original comparison. Both pair with the captured `9B839F3B` PS.
The live `5CC0DB95` variant itself was absent from that cache inventory. This
scan is not proof that compressed caches or uncaptured permutations contain
no other variants. Native raw-light loads at VS t21 and PS t20 require the
same explicit ByteAddressBuffer repair as the earlier forward materials.

Appending motion initially changed 3/96 native clip components on WARP.
Preserve the 12 native projection MADs explicitly and declare SV_Position
`precise`; do not weaken the game's depth test. The GPU fixture now exercises
the forward-deformed combination, native color, native varyings, previous
vertex/root/camera motion, low-alpha discard on all MRTs, and one-target
restoration. WARP and NVIDIA each passed both variants with 0/192 clip-bit
differences, plus the existing full fixture. The linked Release hash and
pending in-game acceptance are recorded in the main HDR handoff.

The later `C3C96F3C / 91091ECC` premultiplied hair layer remains native. This
revision covers the opaque/alpha-tested tail core; it does not invent a motion
policy for translucent fringes or extend coverage to HairWorks. Verify the
actual tail after restarting, while swaying and while moving the camera.
Capture a remaining fringe separately if visible in the diagnostic view.
Scratch evidence: `tmp/witcher3classic-investigation/temporal-dev/tail-20261023/`;
GPU logs: `tmp/tail-test-warp.log`, `tmp/tail-test-hardware.log`.

## Coverage limits and acceptance status

The user confirmed cloth, sword fittings, flock birds and much improved overall
coverage after the family build. A nearby NPC head can still briefly fade;
Geralt's eyes, occasional hair loss and Roach's tail were subsequently reported.
The new opaque eye PS `12B76681` and hair precision revision are rebuilt but
await live verification. The tail is now identified and its opaque Apex
path is implemented as described above; the user confirmed it works on 2026-10-23.
Soft premultiplied hair VS/PS `F872850A/FAB74FB3` remains a captured
candidate for other hair, not the identified tail draw. Blended eye overlay
`EE3505B9/689445D9` remains native.

Transparent layers need an intentional depth/motion policy: naive alpha blending
of UV vectors or overwriting the opaque depth does not solve multilayer motion.
Do not force soft hair opaque. Isolate any remaining tail fringe and relevant
visible NPC-head material during a sufficiently long camera-pan capture.
Then validate compositing against the installed NGX contract. Vegetation wind/contact
motion is implemented and user accepted (see below). Coherent jitter, true
upscaling and Map recovery are implemented; performance improved after the
constant-cache event correction. Explicit scene-cut handling, wider image-quality
and transition testing, and soft-layer policy remain open. The earlier individual
eye/head acceptance was not recorded separately from the later broad coverage
acceptance. See the current HDR handoff for evidence. `motion_validated` stays false and
`development_inputs` stays true until those acceptance checks justify promotion.

## GPU procedural foliage: wind and contact deformation (2026-10-23)

The user confirmed the opaque horse-tail revision and requested remaining wind
and trampled foliage. This is a different history domain from skeletal palettes,
CPU-deformed cloth or movable rigid instances. Use the native deformation inputs
at two times, with the same persistent planted instance transform. Copying the
current world matrix or subtracting camera motion cannot recover leaf sway or
collision bending.

### Establish the native contract before implementing

Classic's SpeedTree draws expose semantic CB names in DXBC. Six live vertex paths
cover branch/frond/leaf wind, grass contact deformation and billboards; four
material paths keep native alpha/dissolve and G-buffer shading. The exact hashes
are in the [foliage checkpoint](WITCHER3_CLASSIC_HDR_HANDOFF.md#foliage-wind-and-contact-checkpoint-2026-10-23).

A 120-frame capture while the user walked through grass proved changing wind and
collision matrices, with stable CB identities. A single still frame is inadequate
for this distinction. Compare more than one draw occurrence: frame and collision
CBs were shared, while model/material/wind CB identities distinguished models.
Do not key history by draw order, draw index, camera-dependent instance-list
position or the offset into a transient instance vertex buffer.

| Original VS slot | Size | Purpose | Previous-state slot |
|---|---:|---|---|
| b0 | 784 | SpeedTree frame, camera position/direction, MVP | b4 |
| b1 | 480 | Model/base-tree configuration, LOD/collision flags | b5 |
| b2 | 352 | Material wind/deformation flags | b6 |
| b3 | 288 | Global/branch/leaf wind dynamics | b7 |
| b11 | 1,104 | Pigment/terrain parameters and 16 contact ellipsoids | b9 |
| b12 | 4,304 | Main frame, including projection jitter | b10 |

Only compiled previous inputs are retained: mask 0x2D for the four tree paths,
0x2F for billboards and 0x3F for grass, with bits ordered as this table. Native
b1 still remains bound for current tree shading, but its previous copy is unused
by the four tree deformation paths. Require b11 only for grass: an unused stale
collision binding must never control tree history validity. The fixture unbinds
b11 on non-contact draws to catch this draw-order dependency.

b8 contains a 16-byte immutable history-valid flag. All borrowed slots are unused
by these native shaders and restored after the original draw. Native b11 must
remain bound during current-position evaluation: treating it as the ordinary
skinning previous-frame slot would silently disable or corrupt trampling.

### Preserve native deformation and evaluate previous state

`tools/generate_foliage_motion.py` creates a single native body per VS and includes
it twice with renamed constants. Current evaluation writes the native outputs.
Previous evaluation consumes retained previous CBs; only its clip position is
used, so FXC can remove dead previous material work. The prior camera is required
for camera-facing leaf cards and billboards, even where wind itself does not move
the billboard. Native grass first bends around contact ellipsoids, then projects
relative to the camera; replay that same math and preserve its displacement clamps.

Appending output padding can expose uninitialized HLSL helper outputs. Read the
native OSGN masks and narrow only genuinely unwritten padding lanes (e.g. float4
that actually emits xyz). Do not change the semantic order or the written lanes.
Tests must compare every native varying as well as exact SV_Position bits; merely
recompiling successfully is insufficient. These six paths needed no native MAD
repair, unlike the earlier hair shaders, but that is a tested result rather than
a general guarantee.

Previous clip.xy has previous projection jitter removed using native b12 c15.xy.
The material extension subtracts current jitter from raster UV, then writes
`previous_uv - current_uv` in the established normalized input-UV convention.
The existing preparation stage converts to DLSS input pixels. Keep input-resolution
motion and the existing dilation contract; do not introduce a second half-resolution
buffer or dilation pass without evidence. NVIDIA recommends input-resolution MVs
and requires a consistent jitter convention:
[DLSS Programming Guide](https://raw.githubusercontent.com/NVIDIA/DLSS/main/doc/DLSS_Programming_Guide_Release.pdf).

Native pixel shaders retain their alpha/dissolve decisions before writing RT3
motion and RT4 signed surface depth. This keeps leaf holes and discarded LOD pixels
out of both outputs. Native named `SharedPixelConsts` uses the same b12 layout as
existing raw-array motion helpers; `WITCHER_MOTION_DIMENSIONS` and
`WITCHER_MOTION_JITTER` let the shared writer address either representation without
declaring overlapping CBs.

### Bound history and CPU/GPU work

`FoliageMotion` uses two GPU CB copies per source identity. Holding a COM reference
to the source prevents pointer recycling from inheriting a different model's
history. Copy a source once per observed frame, not once per instance or draw.
Shared frame/collision buffers therefore cost one copy each. Commit by swapping
buffers at the frame boundary. Require consecutive committed frames for all inputs;
new/gapped history produces the established invalid-history marker and fallback.
Evict unused CB entries after 120 frames; enforce the 1,024-source bound. History
cleanup runs even when no geometry supplied vectors, preventing an inactive forest
from occupying the table indefinitely.

This implementation performs no production Map/readback, vertex-buffer copies,
CPU per-leaf traversal or additional draw. It evaluates previous deformation in
the original vertex invocation and appends MRTs to the original material draw.
Foliage does not bind/save the unrelated skinning SRVs at t120–125. The six captures
show a 36-index, 9,525-instance grass draw, making per-instance CPU state especially
unnecessary. These are architectural costs; matched GPU/CPU timing is still needed
before claiming a measured overhead.

Only main-scene depth, exact scene viewport and the native three G-buffer targets
are accepted. Four other live SpeedTree VS were depth-only/color-write-disabled
passes and are deliberately excluded. The readable 8,368-shader game cache had
none of the six live VS signatures, so a negative cache scan cannot establish
complete coverage. Check loaded shaders and draw targets in other biomes/LODs.

### Tests and transfer limits

`tests/foliage_motion.cpp` loads captured CBs and original CSOs from scratch. It
runs native vs replacement on WARP and NVIDIA, checking all varyings, exact current
clip bits, previous clip against native evaluation from the previous state, native
CB restoration and frame-gap invalidation. Eighteen deformation cases per backend
passed: captured consecutive states, isolated contact motion and isolated wind
motion for each VS. Grass has measurable isolated contact/wind motion; all five
wind paths have measurable wind motion; billboard wind-only motion is zero as
expected. Current clip-bit mismatches and prior-position errors above 0.0002 are 0.

Four pixel families separately pass accepted/rejected alpha or dissolve, native
G-buffer equality, valid/invalid history, motion magnitude and depth MRT checks.
Billboard alpha is isolated from stochastic grain in that synthetic test; grain
math stays native and live appearance still needs inspection. The debug layer is
unavailable on this PC, so the report does not claim a clean D3D11 debug log.
The old object-motion fixture still passes; common GPU readback/material helpers
are shared in `tests/motion_gpu.hpp` rather than copied into the new fixture.

Transferring this technique requires proving stable planted instance world poses.
It cannot invent previous instance transforms for vegetation that is uprooted,
translated, destroyed, streamed with changed transforms, or animated by a separate
texture/simulation buffer. Such inputs need their own stable identity and previous
GPU state. New visible instances of an already-visible model are evaluated at the
previous procedural state; actual disocclusion remains the depth/DLSS history
responsibility. Review LOD transitions and visibility-list changes with a long
camera pan instead of assuming the current instance buffer is persistent.

Next verification: camera still in wind, walking through grass, panning through
near/far LOD changes, and both DLAA and reduced-resolution DLSS. Watch for repeated
amber coverage, ghosting and cutout changes; keep capture disabled for timing.
The handoff records the exact linked Release artifact and whether the user has
accepted the live revision. Scratch fixtures/captures are under
`tmp/witcher3classic-investigation/temporal-dev/foliage-20261023/`.


## Whole-system performance investigation (2026-10-23)

Coverage was accepted by the user, including foliage, but performance was not.
Do not assume original-draw MRT integration is inexpensive just because it avoids
a second draw. Previous deformation consumes vertex work, added varyings consume
interpolator bandwidth, extra targets consume pixel/export bandwidth, and GPU
history copies/state transitions can disrupt scheduling. Character, cloth, rigid
and foliage costs must all be measured.

### Established measurements and failed hypothesis

The stationary scene uses Quality input 2560×1440 in the native 3840×2160 pool.
Debug views and live input capture were disabled. Official Intel PresentMon 2.6.0
provided ETW frame, CPU busy and GPU busy measurements (20 seconds/state, trimming
120 leading and 60 trailing frames). Initial ON/OFF/ON traces reproduced about
9.37/4.45/9.36 ms, with OFF capped at 225 FPS. That frame-time difference was a
lower bound. The user then disabled VSync/frame limiting and confirmed a new
matched scene on PID 35932:

| Mode | Mean frame ms | Mean GPU busy ms | Mean CPU busy ms |
|---|---:|---:|---:|
| Object Motion OFF | 4.265 | 4.264 | 2.523 |
| Object Motion ON, batching revision | 9.332 | 9.331 | 3.366 |

That is approximately 234 versus 107 FPS and +5.067 ms GPU busy. These measurements
establish a major total cost; they do not yet assign it to one shader family or
hardware unit. Scratch CSVs are in `tmp/witcher3classic-investigation/temporal-dev/performance-20261023/`.
Use only the `*-uncapped-confirmed.csv` pair for this matched uncapped comparison.

The first optimization retained MRT slots 3/4 and the motion blend state across
consecutive compatible foliage draws. The live log confirmed 354/355 attachments
were reused. Native target/blend changes remain authoritative; restoration only
removes bindings still owned by the addon. CB reads/binds were batched, redundant
GetDevice/GetDesc calls were removed, and the unwrapped immediate context cached.
WARP/NVIDIA fixtures check current/prior positions, material/cutout results,
repeated draws, native state changes and restoration. However, the user observed
no improvement and measured GPU time agrees. This is a tested state-management
cleanup, **not a demonstrated GPU optimization**. Do not repeat the same hypothesis
or promise a frame-rate gain from it.

### Controlled whole-system sweep

`temporal/motion_profile.hpp` adds an opt-in, unsaved diagnostic under DLSS →
Diagnostics → Advanced diagnostics. It waits 15 seconds for the overlay to close,
then runs eight 8-second stages: full, camera-only, skin-only, deformed-only,
rigid-only, foliage-only, all histories with native shaders, full again. It restores
full coverage automatically and supports cancellation. DLSS disable, debug-view
activation, quality/model/output-size changes or loss of the resolve boundary abort
it. These are deliberately incomplete-motion experiments, not selectable quality
optimizations. Do not assess ghosting or coverage during them.

The history-only stage runs the existing accepted geometry preparation, restores
all native state before the original draw, and rejects both shader replacements.
It measures preparation/state overhead without previous-deformation shaders or
motion writes. It still uses native material shaders and never adds a geometry
draw. Its immediate restoration differs from full-mode foliage batching, so treat
the comparison as isolation evidence rather than an exactly additive decomposition.
The other stages use complete motion for the selected family. No shader math,
visibility threshold or motion resolution changes for this experiment.

Run PresentMon with `--qpc_time_ms`, join its CPU submission clock with logged
`motion profile: boundary ... qpc_ms=...` markers, and discard at least one second
on both sides of every boundary. Log draw counts alongside the measurements to
check workload changes. Compare full stages at both ends; moving NPCs, weather,
streaming, GPU clocks and changing visibility can invalidate an apparent gain.
Avoid readbacks, snapshots and overlay interaction during measurement. Per-draw
GPU timestamps are deliberately not inserted into this sweep because they may
alter the scheduling under investigation. If finer timings are needed, use
asynchronous buffered queries with no spin waits/forced flush and reject disjoint
intervals. Frame/GPU timeline duration and GPU busy time are different metrics.

### Research constraints and next decisions

- [NVIDIA DLSS Programming Guide](https://raw.githubusercontent.com/NVIDIA/DLSS/main/doc/DLSS_Programming_Guide_Release.pdf): input-resolution motion is the normal integration contract. Do not confuse the low-resolution flag with permission to halve motion below the render grid. Output-resolution vectors have different dilation requirements. Thin foliage needs accurate coverage.
- [NVIDIA API performance: shaders](https://developer.nvidia.com/blog/?p=70243): profile shader register/output pressure, preserve early-depth opportunities and evaluate branch choices using the actual workload. Native alpha/discard and depth semantics must survive optimization.
- [NVIDIA API performance: overlap](https://developer.nvidia.com/blog/?p=33048): state changes and interleaved copy/draw work can impede overlap. That motivated the first experiment; its lack of measured GPU benefit prevents treating this as the established bottleneck.
- [Microsoft D3D11 timestamp validity](https://learn.microsoft.com/en-us/windows/win32/api/d3d11/ns-d3d11-d3d11_query_data_timestamp_disjoint): timestamp deltas require a valid non-disjoint interval and its frequency.
- [Epic previous-frame deformation](https://dev.epicgames.com/documentation/en-us/unreal-engine/utility-expressions?application_version=4.27) and [AMD FSR2 integration](https://gpuopen.com/learn/ue-fsr2/): time alone does not recover parameter-driven deformation; missing previous animation/WPO motion can cause temporal artifacts. Removing those vectors is not an equivalent optimization.

Native scene visibility/LOD culling already determines which geometry reaches
our callbacks. A second CPU culling system is not justified without evidence and
could cause missing vectors or extra overhead. Motion rasterization shares the
native depth and target extents; an arbitrary smaller MRT is not a drop-in DX11
replacement. The next change must follow the measured whole-system sweep, retain
accepted coverage and pass the existing exact-position/material tests. Profiling
implementation is compiled; live sweep results remain pending at this checkpoint.


### Whole-system sweep results and constant upload revision

The sweep completed on PID 34292 with the same uncapped Quality scene. QPC-aligned
PresentMon intervals exclude one second at both ends of each phase. Full-motion
bookends agree (9.319 and 9.327 ms GPU busy):

| Active work | GPU busy ms | CPU busy ms |
|---|---:|---:|
| Full motion | 9.319 | 3.322 |
| Camera only (identity hooks remain enabled) | 4.269 | 2.532 |
| Skin only, 40 draws/frame | 4.659 | 2.722 |
| Deformed only, 2 draws/frame | 4.314 | 2.578 |
| Rigid only, 5 draws/frame | 4.343 | 2.550 |
| Foliage only, 433 draws/frame | 8.882 | 3.205 |
| All history preparation, native shaders | 8.180 | 3.404 |
| Full motion repeated | 9.327 | 3.278 |

Most incremental cost in this scene is associated with foliage, but the separate
history-only result demonstrates that previous-deformation shader arithmetic is
not the whole explanation. It retains about 3.91 ms over the camera baseline.
State restoration differs in that stage, so it does not prove that every one of
those milliseconds is a buffer copy. These experiments guide a shared history
optimization; they do not justify removing foliage or ignoring other families.

`temporal/constant_uploads.hpp` now provides tracked constant snapshots for foliage,
shared previous camera/frame constants and deformed-object world constants:

- Track only native CBs requested by history (maximum 2048 source records, 64 KiB
  per CB). Keep strong source/target identities and retire unused entries after
  120 frames. Destination stamps are global to the cache and include the source
  identity; switching a source for the same history destination must force a new
  snapshot. A per-source destination cache would incorrectly reuse old contents
  when switching cameras/passes back and forth.
- ReShade Map/Unmap callbacks redirect **full WRITE_DISCARD** uploads to a stable,
  normally cached CPU allocation, then copy the bytes to the native mapped
  pointer before Unmap. This avoids reading write-combined memory. Native data
  and upload order are preserved. Unsupported maps invalidate the mirror and do
  not redirect the pointer. Mapped entries cannot expire before Unmap.
- Full UpdateSubresource uploads populate the mirror; partial uploads preserve
  completeness only when a complete mirror already exists. Deferred updates,
  GPU copies and command-list execution invalidate potentially stale contents.
- History CBs use DYNAMIC/CPU_WRITE and MAP_WRITE_DISCARD uploads when complete
  CPU bytes exist. Both history slots retain their own contents. When source
  version and destination/source identity are unchanged, no GPU operation is
  submitted. Unknown contents keep the previous CopyResource path. This fallback
  also passes the GPU tests with dynamic destinations.
- Mutation tracking must be explicitly enabled only with all callbacks installed.
  Offline fixtures without the callbacks retain unconditional GPU copies. The
  optimization never reads the GPU back, waits for a query or changes shader math.
  Bone/vertex GPU histories and reference textures keep their established paths.

[Microsoft's UpdateSubresource documentation](https://learn.microsoft.com/en-us/windows/win32/api/d3d11/nf-d3d11-id3d11devicecontext-updatesubresource)
explains contention-dependent copies; the [DirectX CPU efficiency specification](https://github.com/microsoft/DirectX-Specs/blob/master/d3d/CPUEfficiency.md)
explains DISCARD resource renaming. This revision applies those mechanisms to the
measured history workload; its live performance benefit is still unmeasured.

The new `tests/constant_uploads.cpp` verifies exact bytes on WARP and NVIDIA for
all eight CB sizes, native mapped output, unchanged snapshots, alternating history
slots, source changes on the same target, full/partial CPU updates, invalidation,
fallback and expiry while mapped. The foliage fixture now drives real tracked
CPU updates and verifies exact current clip positions, previous deformation,
native material/cutout results and state restoration. Full object fixtures cover
the unchanged GPU-copy fallback. Compile/test logs are `tmp/motion-upload-*` and
`tmp/motion-constant-uploads-test.log`. Release linking and live A/B remain pending.


Additional correctness boundary: ReShade Map callbacks do not expose the recording
context. Deferred Map data may be recorded before execution and must not be treated
as the current immediate-context GPU contents. The final source detects deferred
contexts/recorded lists at creation and conservatively disables CPU history caching
for that device, retaining unconditional GPU copies. The capability survives DLSS
off/on and is cleared only on device destruction. An outstanding redirected map
still copies back at Unmap even after the fast path is disabled. The user-built
14:38:00 artifact predates this final guard; relink before calling the final source
fully deployed. The captured Classic geometry path is immediate-context.


### D3D11 submission notifications are not buffer mutations (2026-10-23)

The first constant-upload build showed no live gain. Even with the deferred-context
guard installed, the frame-64 sample had 92 uploads, zero unchanged targets and
449 fallback GPU copies. Code inspection found that ReShade sends
`execute_command_list` for D3D11 Present, Flush and Flush1. Invalidating all mirror
versions on that event defeats persistent snapshot reuse even when no native
buffer data changed. Subscribe to `execute_secondary_command_list` for the
conservative deferred-list invalidation instead. Keep Map/Unmap, CPU updates and
GPU-copy mutation tracking; do not remove invalidation merely to improve timings.
Deferred contexts still disable CPU substitution because recording time is not
execution time. This is a reusable integration lesson: audit the backend's actual
event emission sites, not just the generic event name. WARP/NVIDIA byte tests and
Release object compilation pass; corrected live performance remains unmeasured.

At this performance checkpoint, `ExcludeVegetationMotion` initially defaulted
to enabled; the user subsequently requested default **off**, now implemented.
It skips foliage preparation and shader replacement when enabled, leaving
camera vectors and native rendering. This is an explicit quality/performance
tradeoff, not a full-coverage optimization. It does not remove other object motion.
The historical full-family profiling sweep required exclusion off; its button
and runtime wiring have since been removed after diagnosis.

The requested live utilization sample found 96–98% GPU activity, about 11.59%
system CPU usage, and game threads at at most 39.88% of one core on average.
The game's total CPU usage was 0.946 core equivalents. GPU busy/frame time remained
about 9.32 ms. These do not indicate a saturated CPU execution thread, but cannot
exclude synchronization or GPU-internal stalls. NVIDIA GPU/memory utilization
report activity duration, not occupied shader lanes or percentage of bandwidth;
see [NVIDIA's definitions](https://docs.nvidia.com/deploy/nvidia-smi/index.html#utilization).
Do not equate 98% activity with efficient GPU execution. After linking, first verify
the cache counters with full coverage, then collect matched exclusion on/off
frame times before choosing further changes. Keep the accepted coverage tests.


Post-rebuild evidence: the user accepts the performance improvement. Artifact
`C282F0E1AD95AA988ABAF821AA88EEBB2DCCC427304D0E169C5F7CFE5591BFA6`
(4,525,568 bytes, 15:08:21 CEST) runs as PID 34916. Full object motion, including
foliage, measured 4.876 ms/frame and 4.872 ms GPU busy (~205 FPS), versus the
previous run's 9.32 ms (~107 FPS). Camera/time were not controlled across these
runs, so retain the raw figures rather than attributing an exact percentage gain.
GPU activity averaged 99.05%, power 440.65 W, and the busiest CPU thread 90.60%
of one core. This is consistent with substantially less wasted GPU time and
higher CPU throughput, but not a hardware-counter proof of the original stall.
The initial cache log was recorded with default vegetation exclusion enabled,
then full foliage was enabled; do not mislabel its zero-copy count as full coverage.
The user subsequently reports ~201 FPS with vegetation motion and ~223 FPS with exclusion enabled, and accepts the result. That is ~0.49 ms saved / ~11% FPS gain, reported by the user rather than a separate ETW pair. The source/build checkpoint is complete; further optimization requires new profiling evidence.
