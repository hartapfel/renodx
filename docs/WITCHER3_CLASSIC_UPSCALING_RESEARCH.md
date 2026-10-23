# Classic 1.32: native DLSS upscaling integration

**Reading order:** start with the [DLSS integration playbook](DLSS_INTEGRATION_PLAYBOOK.md)
for the reusable procedure and current status. This file preserves the dated
investigation. Its “first stage,” “next implementation sequence,” and early
pending-link/default-DLAA paragraphs are historical. Actual scene upscaling,
coherent Halton jitter (also in DLAA) and automatic Map recovery are implemented;
the user accepted Performance, Map recovery and improved jitter quality.
Current source defaults are enabled/Quality/M with saved selections preserved.
Opaque tails and wind/contact foliage were subsequently completed and accepted;
see the top of the [handoff](WITCHER3_CLASSIC_HDR_HANDOFF.md) for deployment status.
Remaining work includes scoped mip bias, explicit camera cuts, broader transition
acceptance and residual full-pool profiling. Native sharpening was later proven
**pre-TAA** (`3EDDC379`); the RCAS replacement runs post-reconstruction. Earlier
generic wording about “final sharpening” does not establish native pass order.

Research and implementation checkpoint: 2026-10-23. Native scene-viewport
upscaling is now implemented and initially verified in Performance mode.
See the final section for the deployed build and capture evidence. Earlier
sections record the foundation and investigation that led to this integration.

## Primary-source requirements

NVIDIA's [DLSS integration guide](https://github.com/NVIDIA-RTX/Streamline/blob/main/docs/ProgrammingGuideDLSS.md)
requires querying optimal rendering dimensions, using render-resolution scene,
depth and motion inputs with a final-resolution output, and maintaining coherent
frame/viewport inputs. It describes preset requests and resource lifetimes.
We retain direct NGX/DX11; Streamline is a reference, not a new dependency.

NVIDIA's [deployment/integration guidance](https://developer.nvidia.com/blog/how-to-integrate-nvidia-dlss-4-into-your-game-with-nvidia-streamline/)
calls for placing reconstruction near the start of postprocessing, correct
object motion/jitter/exposure, mip bias and resets on camera discontinuities.
The primary main-view upscale is the appropriate integration point; shadows
and reflection passes should not be scaled indiscriminately.

The installed SDK's `NGX_DLSS_GET_OPTIMAL_SETTINGS` in
`external/DLSS/include/nvsdk_ngx_helpers.h` returns optimal and permitted min/max
dimensions for each quality mode. It initializes missing dynamic bounds to
the optimal size for older DLLs. A mode with identical min/max dimensions does
not support a variable input range. Do not invent a percentage or force a
minimum alignment without checking the returned bounds.

[Unity HDRP's implementation guidance](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.high-definition/Documentation~/deep-learning-super-sampling-in-hdrp.md)
also connects DLSS quality selection to dynamic render resolution and texture
mip bias. This is useful confirmation that texture sampling and scene sizing
must accompany reconstruction. It does not identify Classic engine offsets.

## Implemented first stage

- All K/J/L/M/C menu entries are selectable. NGX ABI values are 11/10/12/13/3.
  Presets are hints, not an effective-model report. There is no DLL-version gate.
- If feature creation rejects a requested preset, release any partial handle,
  clear all quality-specific preset hints to default and retry once. Cache the
  requested preset so a successful fallback is not recreated every frame.
  NGX may also silently substitute a model; no effective-model claim is made.
- `Dlss::GetRenderResolution` queries capability parameters and validates a
  nonzero optimal size inside min/max bounds and no larger than output.
- Runtime records plans for all five modes when target dimensions change and
  exposes them in Advanced diagnostics. This runs once per output-size change,
  not per draw/frame. These plans do not alter native scene rendering yet.
- GPU tests query all modes and evaluate all five model requests across feature
  changes. The existing isolated DX11 evaluation already supports distinct input
  and output sizes in its synthetic fixture. Gameplay still enforces equal
  dimensions until the engine and downstream consumers have been integrated.

For 1920x1080 output, the tested 310.3 runtime returns:

| Mode | Optimal input | Permitted input range |
|---|---|---|
| DLAA | 1920x1080 | 1901x1069 to 1920x1080 |
| Quality | 1280x720 | 960x540 to 1920x1080 |
| Balanced | 1114x626 | 960x540 to 1920x1080 |
| Performance | 960x540 | 960x540 to 1920x1080 |
| Ultra Performance | 640x360 | fixed 640x360 |

These are observed query results, not constants to hardcode. In-game queries
use whichever DLL the user installs. Keep render-size and output-size explicit.

## Live pipeline evidence

DevKit capture from PID 35496: native TAA draw 2487 of 2542, pixel shader
201C53B4. Current color t0, history t1, luminance/history t2/t3, hardware depth t4
and the single TAA target are all 3840x2160. Color/target are R11G11B10F,
luminance is R16F, depth is R24G8 typeless viewed as R24_UNORM_X8.
Capture: `tmp/witcher3classic-investigation/temporal-dev/resolution-taa-draw.json`.
These are resource descriptors at the native boundary, not frozen pixel data.

This proves the current TAA replacement alone cannot reduce the preceding
scene's pixel cost. Do not downsample a completed 4K frame and present that as
performance-mode rendering. The final-grade/bloom/DoF/HUD resource consumers
must be traced across the new resolution boundary as well.

## Native renderer findings from Ghidra

Executable SHA256:
5112253787FBD927ECB979207EFB91B99BCC9C7B041106B51285136BAB41E1F7.
Addresses below are image RVAs, not portable addresses for other editions.
No executable bytes or game configuration were changed during this audit.

Raw PE string scanning found settings missed by the partially analyzed Ghidra
defined-data listing. RIP-relative references plus PE unwind function ranges
identified their initializers; Ghidra decompiled the actual consumers.

| Setting | Storage RVA | Initializer RVA | Default |
|---|---|---|---|
| ForcedRendererResolution | 2BCA2A8 | 1B4FBF0 | false |
| ForcedRendererOverlayResolution | 2BCA2E0 | 1B4FB60 | false |
| ForcedRendererBackBufferResolution | 2BCA318 | 1B4FAD0 | false |
| ForcedRendererResolutionWidth | 2BCA350 | 1B4FD10 | 1920 |
| ForcedRendererResolutionHeight | 2BCA388 | 1B4FC80 | 1080 |

`BA82A0` consumes a view description at its third argument. It checks width/
height at +818/+81C and a flag at +820. In the ordinary branch, the renderer
override copies the description through `141520`, changes copied dimensions,
then constructs a render object through `12B3C0`. The separate overlay override
affects another dimensions pair passed to that constructor. This is evidence
of an existing scene/overlay sizing distinction, not yet proof of a safe hook.

The `12B3C0` constructor copies that description into the new render object at
+0x10, and stores the separate overlay dimensions at +0xB420. The copy routine
`141520` includes native owned members and helper calls; it is not a safe plain
memcpy contract. These observations narrow a future submission hook, but the
object's consumer/resource allocation still needs live tracing. Constructor
and copy decompilation are saved in `resolution-view-constructor.txt`.

`C406C0` and a fragment of the large `C1C910` function use the separate backbuffer
override. `CB4DA0`, `CB90A0`, `CB9B10` and `6E87C0` consume overlay dimensions.
Several unwind entries are function fragments: the decompiled `C1D35F` and
`6EEC8E` outputs contain unresolved incoming register/flag state. Do not infer
an ABI or install hooks from those fragments. Analyze the parent function.

Saved evidence under `tmp/witcher3classic-investigation/temporal-dev/`:
`resolution-raw-strings.txt`, `resolution-code-refs.txt`, `resolution-init.txt`,
`resolution-consumer-refs.txt`, `resolution-consumers.txt`, and their
`ghidra-resolution-*.cmd` scripts. The raw native scene switch is an investigative
lead; global writes could affect more than the intended primary view and are
not enabled in the addon.

## Next implementation sequence

1. Trace `BA82A0` call sites, the copied view descriptor and `12B3C0` constructor
   through resource allocation, camera constants and submission. Confirm actual
   live main-view ownership and distinguish menus, reflection and shadow views.
   Use guarded native hooks only after ABI, lifetime and call phase are proven.
2. Consume the queried plan before main scene resources/viewport/constants are
   built. Preserve output/backbuffer and UI dimensions. Verify color, depth,
   G-buffer, lighting, object motion and native depth comparisons use the same
   input dimensions. Native resource resizing may need a queued frame-boundary
   rebuild; do not mutate in-flight resource descriptors.
3. Establish the upscale boundary. Native TAA currently writes a render-sized
   target; provide an output-sized target and update its downstream bindings and
   constants. Audit screen-space effects that read render-sized depth after
   reconstruction. Avoid scaling the HUD or a second native upscale of DLSS output.
4. Extend the jitter sequence for the reconstruction ratio, apply it before all
   scene geometry, and remove that exact jitter in motion. Previous matrices,
   object poses and frame resets must agree. Keep normalized UV motion with the
   NGX scale set to input width/height. Do not change vectors to output pixels.
5. Apply the appropriate texture mip bias only to affected scene sampling.
   Preserve intentional material biases, UI/shadow samplers and anisotropy;
   audit native sampler reuse before cloning/replacing states.
6. Reset history on output/mode changes, invalid frame gaps and camera cuts;
   invalidate object surfaces when dimensions change. Define failure recovery
   before enabling smaller scene rendering: native TAA at low resolution cannot
   be silently treated as a full-resolution fallback.
7. Validate each quality mode with final NGX vectors and reprojection, fine
   geometry, motion/disocclusion, transparencies, cutscenes, UI, resize/alt-tab,
   toggle-off and returning to DLAA. Measure matched-scene GPU/render-thread
   costs with captures/debug views off. Lower resource dimensions and reduced
   native shading work are required evidence of actual upscaling integration.

No claim of completed gameplay upscaling is made at this checkpoint. The first
runtime query/planning stage is implemented; native sizing and the full-resolution
output transition are the next code changes requiring live validation.

## GPU verification

`tests/dlss.cpp` now evaluates all five quality modes at queried input sizes,
switching through all K/J/L/M/C requests (80 total evaluations). The installed
game-directory runtime passes HDR preservation, five diagnostic outputs,
motion scale/sign, context restoration and clean shutdown. Observed inputs for
1280x720 output: DLAA 1280x720, Quality 853x480, Balanced 742x418, Performance
640x360, Ultra Performance 427x240. This exercises odd widths and non-16:9-exact
integer dimensions; do not round these arbitrarily. The fixture's previous
center-texel readback assumed even widths and was corrected to `(width/2)*2`
half elements for an RG texel. No production vector math was changed for that.

Logs: `tmp/dlss-all-quality-tests.log` (final installed-runtime run),
`tmp/dlss-all-model-tests-unrestricted.log` (older 310.3 requests/resolution query),
`tmp/dlss-user-runtime-tests.log` (installed-runtime requests),
`tmp/dlss-model-compile.log` (Release object/shader compile).
Successful model requests do not identify which weights NGX ultimately chose.


## Native scene viewport integration — deployed 2026-10-23 11:04 CEST

Release artifact: `build/Release/renodx-thewitcher3classic.addon64`, 3,910,656 bytes,
SHA256 `4755A4F5E17499A2C988049824444FB2CE37F3869432F1DBC76CEC5620F83EC7`.
The user rebuilt/restarted the previous model/query foundation first; that older
artifact was 3,904,000 bytes, SHA256
`63F6FB054961C8C63B84E61D8090402E784EC7FA4F6842AB5E36C33F999D2D71`.
This session then built and linked the actual viewport integration after the user
closed Classic. Current game PID at verification: 33780, DevKit pipe
`renodx-devkit-mcp-33780`. The game-folder symlink targets this Release artifact.

### Proven native contracts and implementation

- Live read-only process inspection identified the renderer at image RVA
  `2BCBB48`, pool pointer at renderer +90, and virtual getter +268 -> `BA6DF0`.
  Pool +168/+16C holds output allocation dimensions. `C727F0` constructs that
  pool; `C72B50` allocates depth/full-sized surfaces. Do not rewrite its dimensions
  while resources are alive.
- `C1C910(renderer, submitted, world)` owns rendering of a submitted frame.
  `upscale_engine.hpp` hooks this entry and adjusts the owned view dimensions
  (+828/+82C in submitted, +818/+81C in view) on the render thread. It matches
  world, ordinary onscreen view, postprocessing enabled, original scene,
  overlay and pool dimensions. Offscreen/recursive/mismatched views pass through.
  No global forced-resolution settings, source descriptor copies or CPU-side
  resource readbacks are used.
- The existing full-resolution pool is retained. The smaller top-left scene
  viewport reduces raster shading work; this is the engine's existing forced
  scene-size design, not a full-resolution render followed by a downsample.
  Memory allocation/clear/copy savings are not claimed. Some screen-space
  effects may still operate on larger extents and need profiling.
- Ghidra `CDA720` proves b12[23] derives from view +818/+81C, while b12[73]
  derives from pool dimensions. These must remain distinct. Geometry vectors
  still normalize by b12[23], now the actual input viewport size.
- `C48810` finishes native TAA before `C4D150` final postprocessing.
  `OnTemporalDraw` validates the active viewport and native pool dimensions,
  prepares exact render-sized color/depth/motion/mask resources by reading the
  top-left input region, selects the frame's snapshotted quality mode, evaluates
  NGX to output size, and blits full-sized reconstruction into the native TAA
  output pool surface. No completed full-resolution scene is downsampled.
- `C4D150(post, context, view, pool, flags, color)` restores output dimensions
  only after a successful resolve and before native sharpening/final grading.
  The outer hook always restores the submitted descriptor on normal return.
  Native postprocessing produces the output-sized graded image and uses its
  existing presentation/UI path. Offscreen and other frame types remain native.
- Two new native hooks join the existing pinned Detours installation transaction,
  protected by the existing PE identity and new 24-byte function fingerprints.
  No extra per-draw native hooks or CPU readbacks. A mutex publishes one coherent
  render-size/quality plan at the frame boundary; the render-thread scope owns
  that plan until completion. Failure to resolve or reach the post boundary
  disarms smaller rendering for the next frame. The failed frame retains the
  native reduced-viewport presentation path. DLAA/off resets the failure latch.
- `ObjectMotion::Configure` separates allocation dimensions from viewport
  dimensions. Its MRTs still match native depth/target allocation, and its draw
  guard matches the reduced viewport. Size changes invalidate motion history.
  First frame after a quality change may have unavailable object history; stable
  reduced-mode frames should regain coverage. Debug views scale input pixels to
  output dimensions and report vector magnitudes in render pixels.
- `DLSSQuality` is a global setting independent of HDR presets. All five quality
  choices are selectable, DLAA remains default. Runtime queries supply sizes;
  invalid/unavailable plans never arm native viewport changes. Feature changes
  recreate/reset NGX history. Native hook installation is attempted once per
  device session, not retried/logged on every draw after an unsupported binary.

### Verification and current limits

CPU native-scope tests pass: reduced dimensions inside the render call, full
final-post dimensions, descriptor restoration, missing reconstruction/failure
latch and offscreen/world/overlay-resize guards. This models audited ABI/data
contracts; it does not replace live hook verification.

The expanded actual-NGX suite passes all 80 quality/model evaluations. Inputs
now occupy a subrectangle of larger native-like textures, with unused color
pixels poisoned to catch accidental full-pool sampling. Diagnostic views are
checked at the bottom-right output pixel, including odd-sized input modes.
HDR preservation, motion reprojection, full-context restoration and clean NGX
shutdown pass. Object-motion GPU tests pass, including smaller viewport with
full-sized depth/MRT allocation and existing native equivalence/history cases.
Logs: `tmp/upscale-engine-tests.log`, `tmp/upscale-subrect-gpu-tests.log`,
`tmp/upscale-object-gpu-tests.log`, `tmp/upscale-integration-compile.log`,
`tmp/upscale-release-build.log`. Release object compile had 31 existing warnings.

The user reports Performance mode is working very well. Live exact-draw
DevKit captures from PID 33780 independently show:

| Boundary | Shader | Viewport / constants |
|---|---|---|
| Forward character geometry | VS 60265FBA | 1920x1080 viewport; b12[23] = 1920,1080,1/1920,1/1080 |
| TAA input | PS 201C53B4 | 1920x1080 viewport in 3840x2160 native pool; same b12[23] |
| Final grading | PS 649AF4FA | 3840x2160 viewport; b3[17] = .5,.5,1/3840,1/2160 |

Eight TAA, four geometry and four final-grade frames were captured. Native
camera[0] remains alternating +/-0.25 pixels. Logs also show successful Quality
2560x1440 -> 3840x2160 and repeated Quality/Performance switching. These are
separate bounded captures, not same-frame cross-stage GPU timing measurements.
Saved evidence under `tmp/witcher3classic-investigation/temporal-dev/`:
`performance-boundary-draws.json`, `performance-taa-inputs.json`,
`performance-geometry-inputs.json`, `performance-grade-inputs.json`,
`performance-size-verification.json`. Both HUD-specific capture attempts timed out;
full-resolution grading is independently verified, broader HUD verification
must not be inferred from those failed captures. The failed retry is saved as
`upscale-hud-retry.json`; all bounded captures are inactive.

Next work:

1. Validate all modes, cutscenes/DoF/bloom/shafts, UI, resize/alt-tab, native AA
   disabled, DLSS off/on and returning to DLAA. Inspect object coverage after
   the one-frame history warmup and verify no stale rendered subrectangle leaks.
2. Trace the engine's existing jitter producer and replace its two-phase pattern
   coherently before all geometry. Current tests use native jitter; wider phase
   coverage is necessary for final reconstruction quality. Never change only
   the jitter reported to NGX or independently jitter one shader family.
3. Audit sampler ownership and introduce appropriate scene texture mip bias
   while preserving existing material biases, UI/shadows and anisotropy.
4. Strengthen camera-cut/discontinuity reset handling. Existing feature/size/gap
   resets remain, but comprehensive scene-cut detection is not complete.
5. Measure matched-scene GPU and render-thread costs with debug/capture disabled.
   Retained pool allocations, full clears/copies and screen-space pass extents
   require profiling before claiming a measured speedup or memory reduction.
6. Continue separately pending motion coverage (brief nearby NPC head fade,
   Roach tail, wind vegetation, soft transparent layers).

## Menu recovery and projection jitter — 2026-10-23

Status at 11:33 CEST: source implemented and tested; Release object compiled.
The game still holds the 11:04 Release DLL. Full link and live verification
await the user's requested game exit. Do not describe the new hook as deployed
or the menu round trip as verified until that happens.

### Menu omission is not a permanent reconstruction failure

The user reports opening Map/Inventory leaves gameplay in DLAA until manually
changing quality. The live menu snapshot has 100 draws and neither TAA
`201C53B4` nor final grading `649AF4FA`. A bounded TAA capture recorded zero
frames and 600 missed frames, then was explicitly stopped. Evidence:
`tmp/witcher3classic-investigation/temporal-dev/upscale-menu-draws.json`.

Previously every scoped render missing reconstruction/post restoration set the
permanent failure latch. `Frame::temporal_seen`, set when the TAA replacement is
encountered, now distinguishes an omitted boundary from an attempted failure.
An omitted boundary clears the plan without latching. After the first successful
native-size gameplay resolve, `OnPresent` publishes the selected quality again;
the following main frame resumes its reduced viewport. NGX's existing frame-gap
and feature-size resets remain active. An encountered but unsuccessful TAA or
missing post-restoration boundary still disarms/latches. DLAA/off clears that
latch. No timer, menu polling, input interception or recurring capture is added.

### Coherent geometry jitter, not an NGX-only offset

The native setter at RVA `1F4360` has x64 signature
`void(uint8_t* camera, float x, float y, uint32_t width, uint32_t height)`.
It stores `(x / width) * 2` at camera `+340` and `(y / height) * 2` at `+344`,
then calls matrix builder `1F43B0`. That builder writes projection X with the
opposite sign and projection Y with the same sign, rebuilding all derived
projection/inverse/view products. Main-view wrapper `16F320` calls it for the
two camera objects at view `+10` and `+410`.

The submitted render view is `submitted +10`. `RenderHook` saves both cameras'
original normalized jitter, chooses one Halton(2,3) sample, and calls the native
setter before rendering. `JitterHook` overrides subsequent native setter calls
only for those two camera addresses while that main frame is active and before
post restoration. Both cameras use the same sample and actual render dimensions.
Other cameras pass through. In particular, TAA function `C48810` makes a local
camera copy and deliberately calls the setter with zero jitter for reprojection;
that call MUST remain untouched. Postprocessing is also outside the override.
At return, the submitted dimensions and original camera jitter are restored via
the native setter (including derived matrices). Hooks are pinned and installed
in the existing Detours transaction. The PE guard plus 24-byte setter and matrix
builder fingerprints protect this extra hook. No shared infrastructure change.

`C48810` writes its current pixel jitter at CPU shadow RVA `2CCB750` from
`viewWidth * view[350] * .5`, and similarly for Y. The existing `Camera::Jitter`
continues to read the negative of those actual rendered offsets for NGX. No
independent reported-jitter substitution is introduced. Existing b12 projection
constants and object history retain the same native contract. GPU preparation
removes the exact current jitter before unjittered camera reprojection.

The cycle length is `max(32, ceil(8 * outputPixelCount / inputPixelCount))`,
bounded at 1024 for defensive input handling. At supported equal-aspect modes
this gives 32 for DLAA/Quality/Balanced/Performance and 72 for Ultra Performance
(upward rounding can add one for some optimal sizes). This uses NVIDIA's
resolution-dependent sample coverage with a 32-phase floor. Plan changes and
suspension restart the cycle. DLAA now receives a full-size active plan as well.
No additional GPU draw/dispatch/readback is needed for jitter; CPU work is a
bounded sample calculation and native camera rebuilds. Timing is not yet measured.

Evidence from Ghidra is saved in `temporal-dev/jitter-producer.txt`,
`jitter-producer-long.txt` and `jitter-camera-update.txt`. Do not rerun the
30-second decompilation of `C48810`; the saved 150-second version completed.

### Tests and next live checks

- `tests/upscale_engine.cpp`: menu suspension and automatic rearm, attempted
  failure latch, view/world/resize guards, dimensions restored for postprocessing,
  native setters called again during rendering, unjittered local-camera isolation,
  original jitter restoration, distinct/repeating 32/72-phase cycles, DLAA scope.
  Pass: `tmp/upscale-engine-tests.log`.
- `tests/dlss.cpp`: all 80 actual NVIDIA evaluations now feed changing Halton
  offsets and regenerate the input preparation for each frame. All five quality
  modes and requested K/J/L/M/C presets pass, with HDR/state/shutdown checks.
  Additional GPU assertions cover three camera translations across 32 jitter
  phases in each of five modes: 480 comparisons, including zero motion in the
  stationary case. Pass: `tmp/upscale-jitter-gpu-tests.log`.
- Release object compile passes with the same 31 pre-existing warnings:
  `tmp/upscale-integration-compile.log`. Full Release link is still pending.

After relaunch: select Performance, enter/exit Map and Inventory several times,
including inventory's 3D character view. Confirm reconstruction returns to
1920x1080 -> 3840x2160 without changing settings. Capture at least 32 consecutive
TAA frames with b10/b12 and an independent geometry capture to verify actual
projection/sample diversity. Verify final grading stays full size, stationary
object vectors remain still, and shadows/UI do not visibly jitter. Repeat in
DLAA and Ultra Performance, then off/on and a resize/cutscene. CPU mocks and
synthetic GPU tests do not replace these live checks.

### Sampler investigation and remaining optimization work

[NVIDIA's programming guide](https://raw.githubusercontent.com/NVIDIA/DLSS/main/doc/DLSS_Programming_Guide_Release.pdf)
sections 3.5 and 3.7.1 cover mip bias and jitter. The local SDK copy is dated
2025-05-31; its text is saved in `tmp/dlss-guide-text.txt`. The online indexed
revision was dated 2026-03-31. The recommended starting bias is
`nativeBias + log2(renderWidth / outputWidth) - 1 + epsilon`, with content-specific
adjustment. Preserve material bias, anisotropy and comparison behavior. Treat
quality/shimmering checks as necessary; the formula is not a universal visual
quality guarantee.

Native sampler binding function RVA `010F10` resolves 39 logical indices through
backend pointer RVA `2A5BFD8`, index-to-id table `+30`, then entries at
`+2B0158 + (id-1)*48`. Each entry starts with a D3D11 sampler pointer; the rest
is an engine descriptor, NOT a D3D11_SAMPLER_DESC to reinterpret blindly.
A bounded read-only live table is saved as `temporal-dev/sampler-native-table.json`.
Some native descriptors already carry bias -0.75. Multiple logical indices
share a D3D11 sampler, so ownership cannot be inferred from pointer identity alone.

The binder caches logical indices separately for VS and PS (`+25D9080` and
`+25D9040`). Replacing a table pointer without synchronizing that cache can leave
stale bindings. The same binder serves world geometry, shadows and screen-space
passes. Therefore this revision does NOT change mip bias globally or add
per-draw GetDesc/readback work. Next implementation must identify the material
samplers and native geometry scope, clone/cache the needed variants only on
quality/device changes, and restore/cache-synchronize at scope boundaries.
Also pending: explicit camera-cut resets, complete effect/UI/resize validation,
profiling full-pool clears/copies and postprocessing extents, and matched-scene
GPU/render-thread measurements with debug/capture disabled. Retained output-size
pool allocations mean a viewport reduction is not a claimed VRAM reduction.

### User verification after the 11:36 Release build

On 2026-10-23 the user confirms that upscaling persists after opening the Map
and that image quality is substantially improved with the new jitter. They
subjectively prefer upscaling to DLAA and asked whether DLAA received the same
fix. Source verification confirms it did: `OnPresent` publishes quality 0,
`Publish` accepts its full-size plan, and `RenderHook` generates 32 Halton phases
using native input dimensions. ReShade.log at 11:39:34, 11:40:08 and 11:41:39
records quality 0 at 3840x2160 in the managed native view. Quality 1 at 2560x1440
and quality 4 at 1280x720 are also logged, with 3840x2160 output.

Current on-disk Release: 3,911,680 bytes, 2026-10-23 11:36 CEST,
SHA256 `CD21EA4ADBA4A2615C47772731D7D51BD43D7EB15F81A90DCFE9A29FE26D171F`.
This supersedes the pending-link status above. No new exact-draw jitter capture
was performed during this confirmation. A matched DLAA/SR comparison should
hold scene, model request, sharpening and exposure constant before attributing
the preference to jitter or changing DLAA's amplitude. Jitter stays within half
an INPUT pixel in either mode; at 2x upscaling that spans twice the distance in output pixels compared with DLAA. This is expected dimensional scaling, not a
reason to double DLAA's jitter. Inventory round trips and other outstanding live
checks remain distinct from the explicitly confirmed Map test.
