# Brotherhood projection jitter audit

## Result (2026-09-19)

The existing `native_taa.hpp::ApplyJitter` operation is projection jitter.
It modifies the composed world-view-projection (WVP) registers on the CPU before
the draw. Moving the same multiplication into the standalone projection matrix
does not inherently change the rasterized positions.

The addon now hooks the engine's projection setter before VP/WVP composition on
the audited Brotherhood executable. Main-view identity and the worker/render
handoff have been verified in live gameplay, including DLAA, TAA with 8x MSAA,
AA Off and graphics resets. Each queued camera carries its own jitter sample;
the existing draw callback does not apply a second offset. The draw-time path
remains the fallback for unrecognized executables. See **Engine projection hook**
below for the current implementation; the earlier audit and fallback validation
are retained to explain the progression.

## Coordinate convention and equivalence

SM3 `dp4(position, cN)` treats c0-c3 as rows of a column-vector transform. Let
`M = P * V * W`. For a jitter offset `(jx, jy)` measured in pixels:

```text
J = identity
J[0][3] =  2 * jx / width
J[1][3] = -2 * jy / height

M_jittered = J * M = (J * P) * V * W
```

Consequently `clip.x += 2*jx/width * clip.w` and
`clip.y -= 2*jy/height * clip.w`. After the perspective divide and viewport
mapping, the displacement is exactly `(jx, jy)` pixels. Clip z and w remain
unchanged. This applies to transformed/animated geometry as well as static
geometry. Adding an offset without multiplying by clip w would be incorrect.

The CPU engine matrix is transposed before upload. Its row-vector storage must
not be patched using the shader-register row indices without accounting for
that transpose. For a conventional row-vector perspective matrix, projection
jitter instead changes its `[2][0]` and `[2][1]` terms.

## Ghidra evidence

Executable SHA-256:
`72fe53eb40cae0f17d8ea457a6e12694b32a3b41d0d88b8bf79169750556c174`.
These are **RVAs relative to ACBSP.exe**, not portable hook signatures. The
observed load base was `0x009F0000`; the file's preferred base is `0x00400000`.

The on-disk image did not expose the render functions observed in the debugger.
Importing it alone produced no functions at those locations. A read-only copy
of the loaded `.text` region was applied to the local Ghidra project after
rebasing it to the observed load address. The runtime code then decompiled and
matched the captured call stacks. No game executable was rewritten.

| RVA | Observed operation |
| --- | --- |
| `0x70C150` | Execute a queued vertex-float-constant upload through D3D9 vtable offset `0x178`. Packet contains 16-bit start register/count followed by float4 values. |
| `0x70B390` | Write that command packet and copy `count * 16` bytes into the render-command buffer. |
| `0x6A76A0` | Compare CPU constant-cache rows and emit changed spans. Uploads are not necessarily four registers long. |
| `0x6A5F40` | Bounds-checked vertex-constant update, maximum 256 float4 registers. |
| `0x6B24C0` | Transpose a full 4x4 matrix before shader upload. |
| `0x732230` | Transpose a matrix and submit four vertex constant rows. Seen in a live upload call stack. |
| `0x715A50` | Copy a matrix into render-context offset `0x230`, then rebuild the composed caches. |
| `0x715AD0` | Copy a matrix into offset `0x270`, then rebuild the composed caches. |
| `0x715B50` | Copy the per-draw matrix into offset `0x2B0`, then rebuild offset `0x2F0` from it and offset `0x330`. |
| `0x715A10` | Rebuild offset `0x330` from `0x230`/`0x270`, then offset `0x2F0` from `0x330`/`0x2B0`. |

The setters' callers indicate `0x230` is projection and `0x270` is view:
callers pass camera `+0xE0` to the first setter, and an axis-converted/inverted
camera transform to the second. Offsets `0x330` and `0x2F0` are consistent with
VP and WVP respectively. These semantic names are inferred from composition
and callers. The later non-debugger runtime checks below establish the main-view
ownership used by the hook; other views are not automatically authorized.

The live producer and consumer stacks ran on different worker/render threads.
An early engine hook cannot safely read a mutable global Present jitter and
assume it belongs to the command buffer being constructed. It must associate
the selected jitter with the rendered frame and preserve the corresponding
unjittered camera for reconstruction and motion vectors.

## Validation

A Clang x86 optimized CPU regression used the actual production jitter loop
extracted from `native_taa.hpp`. Its independent reference inserted jitter into
DirectXMath's standalone row-vector perspective matrix **before** view/world
composition. It checked:

- All eight Halton phases, full footprint and the half footprint used with MSAA.
- 1920x1080, 3840x2160 and 3440x1440.
- 100 rotated/translated objects, three vertices each, and a translated camera.
- Expected pixel displacement and unchanged clip z/w.

14,400 vertex comparisons passed. Maximum early/late difference was below the
printed six-decimal pixel precision; maximum displacement error was 0.000053
pixels. This establishes numerical equivalence for those cases, not universal
pass coverage or visual quality.

Live diagnostics reported valid consecutive camera pairs, approximately
1,200-1,500 jittered draws in the observed moving scene, and zero unsupported
projection contracts among the eligible draws. Excluded passes are not counted
as unsupported; this does not prove every visible surface receives jitter.

The debugger captures caused crashes following brief pauses/detaches, confirmed
by the user. Further debugger attachment was stopped. This is a limitation of
the capture session, not evidence of a projection-math bug. No CPU-address hook
was added; the follow-up below uses the existing render callbacks.

## Draw-time fallback coverage and synchronization (2026-09-19)

`JitterFrame` belongs to the native render stream. The first eligible scene draw
latches the dimensions, sample count, history eligibility and Halton offset.
That offset remains immutable until the primary swapchain presents. Camera
acquisition cannot turn jitter on halfway through a warm-up scene or select
another sample partway through the draws. The MSAA depth prepass and color pass
share the same half-footprint offset. TAA, DLAA, motion replay and FG inputs use
the offset actually applied to that scene, including zero for warm-up frames.

Only a valid completed scene that used jitter advances the sample sequence.
Empty/auxiliary presentations do not consume a phase. Mode/backend changes and
native reset clear the sample state. Incompatible dimensions/sample counts,
target replacement after jitter started, or a failed constant update/restore
invalidate the temporal input. Additional swapchain presentations and destruction
do not advance or destroy the primary scene's temporal state.

The existing native DrawPrimitiveUP/DrawIndexedPrimitiveUP wrapper converts
immediate geometry to buffered draws. Those draws now receive jitter when they
meet the same projection and scene-resource checks as ordinary geometry. The
old blanket immediate-draw exclusion is gone. Unverified raw ReShade UP replay
and the addon's own replay/resolve remain excluded.

Depth-disabled geometry can also qualify, but only with compiler-authored
`g_WorldViewProj` at c0-c3 and `g_World` at c8-c10/c11, two agreeing camera anchors,
and an affine world/WVP composition that matches the current main camera. The
shader cache records this contract once; local DEF overrides of the world rows
disqualify it. Matching color/depth identity and viewport alone do not authorize
an unknown-camera effect. This does not claim coverage of every sky/particle
variant, separate reflection target or post-resolve draw.

The optimized static-object motion policy is preserved. Its camera/world
comparison now shares the same finite, double-precision validation used by the
new depth-disabled gate; static buildings are not reintroduced into motion replay.

### Verification of the follow-up

- Release x86 addon build and C++ checks pass. No helper or game-executable
  change is needed.
- CPU regression checks 24 phases, immutable eligibility, empty/warm-up frames,
  MSAA/size mismatch rejection, reset, nonfinite/other-camera rejection and
  truncated CTAB handling. The expanded local dump has 268 accepted projection
  contracts, of which 191 also expose the required world contract.
- Native DX9 GPU tests compare actual depth/color coverage against separately
  drawn, explicitly jittered reference geometry for all eight phases. They
  exercise buffered and both UP draw types with depth disabled, and verify
  restoration of the original projection constants.
- HDR tests pass at 2x, 4x and 8x MSAA, including native ResetEx and
  MSAA -> Off -> MSAA resource transitions. An 8x standalone SDR run also passes.
- An extra swapchain presents and is destroyed between main-scene draws; the
  following independent phase/coverage comparison still passes in HDR and SDR.

The rebuilt addon was then verified in live 3840x2160 HDR gameplay with TAA and
DX12 DLAA. Across 43 periodic diagnostic samples there were zero invalid jitter
frames and zero conflicting cameras. The user checked stationary and moving
views and reported that the result looks good. The new immediate/depth-disabled
coverage counters stayed zero in this scene, so those additional branches are
GPU-fixture verified, not visually proven by this particular gameplay check.
These results do not establish universal pass coverage or removal of the game's
unrelated stutters.

## Engine projection hook (2026-09-19)

`engine_camera.hpp` installs seven x86 Detours hooks only after verifying the
loaded PE machine (`0x14c`), timestamp (`0x635a87c1`), image size (`0x2e02000`)
and the audited instruction prefixes. Addresses use the actual module base plus
RVA, so relocation is supported. Unknown versions keep the draw-time fallback.
The executable on disk is untouched. Hook callbacks pin the addon until process
exit; restart the game to replace/unload this build.

| RVA | Hook responsibility |
| --- | --- |
| `0x744860` | Start a prepared view; assign a frame ID and immutable configuration/sample to the renderer's master context (`renderer+0xaa8`). |
| `0x715A50` | Apply jitter to the selected main projection before the engine rebuilds VP/WVP. |
| `0x74FCA0` | Carry camera metadata when the master context is copied into a worker context; read the copied VP and retain its unjittered form. |
| `0x749250` | Collect camera stamps while a worker builds a draw-command batch; associate them with the completed descriptor at `job+0x18`. |
| `0x70B390` | Stamp the exact constant packet when c0-c3 overlap an upload and the camera identity changes. Partial updates retain the same sample. |
| `0x70AED0` | Retrieve the batch using descriptor identity and its begin/end bounds before the render thread executes it. |
| `0x70C150` | Activate that packet's camera/sample immediately before the native VS constant upload. |

### Main-view selection and projection math

The initial unmodified frames recover VP from known camera-anchor draws and
match it against engine contexts. This learns the renderer and camera object.
Modification then requires that renderer, the exact camera object, the audited
camera projection source (`camera+0xe0`) and a viewport at `camera+0x84` equal to
`{0,0,scene_width,scene_height}`. Observed projection call sites include
`0x76e7a2` in gameplay and `0x76e8a5` during loading; `0x76f92e` is also an
audited setup caller. A renderer's `+0xfe8` field is a view/subpass index, **not**
a frame number. It must not be used to choose the Halton phase.

For the engine's row-vector P, each row is changed as follows:

```text
Pj[row][0] = P[row][0] + 2*jx/width  * P[row][3]
Pj[row][1] = P[row][1] - 2*jy/height * P[row][3]
Pj[row][2:3] = P[row][2:3]
```

The original camera P remains unchanged. The setter receives an aligned local
copy (its audited implementation uses aligned SIMD loads). It then performs
the game's normal composition and constant-cache updates. This covers consumers
of that engine projection before command recording, including passes that do
not reach the old per-draw jitter gate. Unrelated camera setters are unchanged.

### Worker/render synchronization and temporal consumers

The prepared view owns the full configuration: renderer/camera, dimensions,
sample count, epoch, frame ID, phase and pixel jitter. MSAA keeps the existing
half-footprint sequence. Context copies and command stamps carry that snapshot;
workers never read a mutable Present phase or render-thread `DeviceData`.
Configuration changes start a new epoch and reset the phase. A queued older
batch still uses its own original sample after the CPU prepares a newer view.

On the render thread, `AdoptEngineSample` supplies the actual sample to TAA,
DLAA, MSAA depth handling and the existing motion/FG input path. Epoch changes
invalidate history; mixed frame IDs or dimensions invalidate the scene input.
An unjittered copy of WVP/VP is used for camera reconstruction and motion replay.
The engine's jittered shader constants stay resident: restoring an unjittered
matrix after every draw would corrupt the engine's changed-register cache.
The existing static-surface camera-motion optimization remains enabled.

Batch/context maps are bounded and protected by an SRW lock. Render metadata
is thread-local. Stamps are added per camera transition, not per draw, and are
moved from producer to consumer. No debugger is attached during installation
or gameplay verification.

### Verification

- Release x86 addon build passed; the linked game addon is this build.
- [Engine fixture](tests/engine_projection.cpp) checks actual production hooks
  with x86 stack/alignment conventions, unchanged source P and clip z/w,
  copied contexts, full/partial constant uploads, and two queued CPU frames
  consumed on another thread. It checks all eight phases with and without MSAA,
  AA Off, and rejection of an unknown executable. See the compile command in
  [tests/README.md](tests/README.md).
- The new Release addon passed native DX9 GPU fallback tests in HDR and standalone
  SDR at 8x MSAA: reference color/depth coverage, MSAA -> Off -> MSAA, ResetEx,
  buffered/UP draws and a secondary swapchain presenting/destroying mid-scene.
- Live 3840x2160 HDR gameplay verified DLAA -> Off -> TAA + 8x MSAA -> DLAA with
  MSAA Off. In 68 periodic samples (39 non-MSAA, 29 MSAA), all camera anchors
  matched, every counted jitter draw used the engine sample, batch and stamp
  production/consumption counts matched, and there were zero invalid jitter
  frames, conflicting cameras or unjittered MSAA prepass draws.
- The user confirmed stable stationary/moving views, successful graphics-change
  recovery and improved edge handling after returning to DLAA.

This confirms the hook on the audited executable and tested views. It does not
prove every shadow/reflection/effect variant, another executable revision, or
fix the unrelated base-game stutters. The synthetic GPU tests exercise fallback;
the actual engine path is covered by the CPU fixture and live game verification.

## Checklist for another game or executable version

1. Observe the engine setters without stopping the game. Validate executable
   version/signatures and fail closed on unfamiliar code.
2. Identify main-camera versus shadow, reflection, UI and other view contexts.
   Check non-MSAA color/depth and the separate MSAA depth prepass.
3. Associate CPU command generation with the exact render-frame jitter; retain
   an unjittered camera snapshot. Do not double-jitter existing draw callbacks.
4. Validate temporal input registration, cut/reset/resize behavior, static and
   animated geometry, and MSAA transitions before enabling the replacement.
5. Compare against the existing implementation with the same sample sequence.
   Changing injection location alone is not an image-quality improvement.

Local working files are under
`tmp/asscreedbrotherhood-taa/ghidra-audit/`: Ghidra project, Java audit scripts,
decompilation notes, bounded capture scripts and the CPU regression fixture.
Runtime game code and decompiled game functions stay in local scratch and are
not distributed with the addon.
