# The Witcher 3 Classic HDR (experimental)

DLSS Frame Generation implementation and verification are documented in
[frame_generation/README.md](frame_generation/README.md). The Release addon now
runs DX12 FG alongside Classic's DX11 DLSS/DLAA: live 2x generation is confirmed,
with 4x/6x, Auto and Dynamic exercised by standalone hardware tests. Controls
are in the existing DLSS menu. HDR10 and windowed/borderless mode are required;
the DX12 bridge starts immediately and FG can be toggled during gameplay.
FG defaults to Off only when no saved preference exists; FG settings persist. Game performance,
complete HUD/HDR visual acceptance and normal game shutdown still need QA.

Release packaging uses `package-release.cmd` or `package-release.ps1`, matching
the standalone addons. Pass `-Build` to build the Release target first; optional
`-Version` and `-OutputDirectory` select the archive name and destination.
The default destination is `build/Release/packages`. The script takes production
NVIDIA binaries and licenses from `bin/streamline-2.14.16` (or `-StreamlineSdk`),
checks NVIDIA signatures, verifies every archived file against its source, and
writes a separate SHA256 checksum. The ZIP contains only the addon, required
NVIDIA DLLs and licenses under `bin/x64`.

For developers adding DLSS to another game, start with the
[DLSS integration playbook](../../../docs/DLSS_INTEGRATION_PLAYBOOK.md), then the
[object-motion guide](../../../docs/OBJECT_MOTION_VECTOR_INTEGRATION.md) and
[reproducible test instructions](tests/README.md). The playbook distinguishes
reusable contracts from Classic-specific offsets and records the known pitfalls.

Classic DX11 addon with Vanilla and Custom PsychoV-31 modes. The native
exposure pass extends the filmic shoulder; scene LUT and analytic grading
feed PsychoV before UI composition. Full-resolution RGBA8 and R11G11B10 scene
render targets are cloned to signed RGBA16F; the swapchain proxy encodes HDR10.

## BlitzFX compatibility

The 2026-10-26 object-lighting fix restores 64 environment-probe hemisphere
selectors across eight hair, tail and forward-material shaders. The decompiler
had rounded an integer flag to zero, sampling the wrong atlas hemisphere.
The user confirmed correct hair/eye lighting and full valid motion coverage
with the corrected shaders live. The normal Release addon includes the fix;
fresh-launch verification remains to be recorded. Directional-probe and full
motion fixtures pass on WARP/NVIDIA. See the compatibility handoff for the
shader list, native-instruction audit and reproduction steps.

The object-lighting revision isolates current motion-frame data in PS b11,
preserving native PS b12 lighting/fog constants. It retains vector math and all
coverage/history paths. Full object and foliage WARP/NVIDIA checks pass, including
distinct native stage-frame buffers and zero clip/previous-position differences.
This binding change alone did not fix the report; the hemisphere correction
above addresses the proven cause.

The 2026-10-26 PBR follow-up preserves native UNORM storage for the three material
G-buffer attachments. They hold bounded roughness/normals/material fields rather
than scene radiance; upgrading them to FP16 admits invalid PBR inputs. Native
DXBC replay on WARP/NVIDIA eliminates captured nonfinite output with UNORM inputs
while retaining HDR lighting. Scene/postprocess FP16 storage remains active.
The user confirmed the rebuilt travel-post fix works; see the handoff.

The refractive-raindrop revision maps both captured/archive particle variants'
scene-color UVs into the active half-size render rectangle. Native depth/fog
mapping and opacity are retained. WARP/NVIDIA native comparisons pass; live
and restarted Quality/Performance acceptance is pending. RTSS overlay support
was restored through a Witcher-only RTSS profile (prefer D3D11, automatic HDR),
with no overlay-specific addon change. Exact settings are in the handoff.

The 2026-10-25 ReShade discovery fix restores BlitzFX configuration and world
rendering after the black-screen startup failure (user confirmed). A corrected
integer lookup row removes the mod water seam in DLAA and Quality (user confirmed).
The latest filmic fix selects the rising shoulder inflection for weather curves
with multiple positive roots, instead of retaining a bounded/descending shoulder.
It is active in live testing; packaged visual acceptance is pending. The mild
contact-shadow follow-up corrects history UV for our jitter in both DLAA and
upscaling, with native compute constants restored after injection. See the
handoff for evidence, verification status and required live-override cleanup.

The first compatibility revision supports the captured BlitzFX 1.1.0 path;
combined in-game verification remains pending. See the
[compatibility handoff](../../../docs/WITCHER3_CLASSIC_BLITZFX_COMPATIBILITY.md)
for the required patched ReShade startup DLL and exact test checklist.
When DLSS is enabled, a guarded render scope bypasses BlitzFX TAA and its
jitter modification, then restores its selected AA mode before settings/UI
presentation. Turning DLSS off returns AA ownership to BlitzFX. Keep the
game's AA enabled. Without BlitzFX, the existing standalone path remains.
Captured BlitzFX filmic/final-grade shaders preserve HDR through PsychoV;
its extra sharpening is bypassed when RenoDX RCAS owns sharpening. Nine
BlitzFX material variants use the existing object histories and motion MRTs.
The 2026-10-24 correction fixes its exposure denominator, covers blended
environment filmic curves, and adapts water/bloom texture sampling to DLSS's
render subrect. Offline WARP/NVIDIA regression checks pass; the combined
rendering still needs in-game visual acceptance after rebuilding/restarting.
The follow-up additionally corrects water reflection history/preparation and
screen-space shadow history/contact rays. Those four native-pass replacements
run only with recognized BlitzFX during reduced-resolution DLSS; DLAA and
standalone retain their existing passes. The handoff records the remaining
in-game checks and exact capture/test evidence.
The next reflection-specific correction adapts native quarter-depth preparation
(`657A6576`) to the active scene rectangle before SSR ray marching. The confirmed
failure capture used Performance, not Quality. It uses the same BlitzFX/upscale
gate; the downstream composite and mip passes retain their existing transforms.
See the handoff for exact capture modes and pending in-game reflection checks.
The Igni follow-up repairs eight decompiled sun-direction reads in BlitzFX's
Geralt skin replacement. Temporary local lights previously leaked their loop
index into directional lighting, tinting the face brown with Object Motion on.
Native-bytecode comparisons pass on WARP/NVIDIA; the rebuilt addon still needs
an in-game Igni/fading-light check with Object Motion re-enabled.
The DoF follow-up corrects render-to-allocation sampling in BlitzFX's weighted
reduction, bokeh, dilation and composite. Its focus controls, kernel and order
are retained. Native comparisons pass on WARP/NVIDIA, including odd dimensions
and cinematic flags; rebuild/restart and compare Quality/Performance with DLAA.
The cutscene audit adds the remaining five identified BlitzFX final-grade
variants, including `A123EB15`, which clipped an HDR input in the captured scene.
All six share post-reconstruction effects and the existing wide-gamut/PsychoV
grade path. A further camera motion-blur pass receives subrect-correct samples
and per-texel mask clamping at viewport borders. The dump audit and remaining
underwater/bloom-edge follow-ups are recorded in the compatibility handoff.

## LUT levels and wide-gamut preservation

In Advanced mode, **Scene Color Grading** follows **Tone Mapping** and contains
**LUT Grading Strength** (default 100), **LUT Scaling** (default 0), and
**Color Grading Strength** (default 100), matching the Next Gen controls.
LUT Grading Strength 0 bypasses LUTs, their gains and environment blending;
intermediate values blend the grade in the reversible linear proxy. Color
Grading Strength blends the later native analytic grade in linear space, before
vignette. Its zero bypass leaves vignette independent. These are separate from
the user's exposure/contrast/saturation adjustments before PsychoV.

The 2026-10-23 LUT revision ports Hartapfel Remastered's reversible grading
proxy. Each LUT pass temporarily contracts signed BT.709 about luminance, then
uses N2 max-channel compression to enter the native atlas domain. The six native
LUT/intensity/weather blends run there; both scales are undone after the final
blend. `grading/grade_state.hlsli` shares that contract with the final analytic
grade, whose level/power math now retains signed channels. PsychoV's selected
gamut remains the final display mapping.

**HDR → Advanced → Scene Color Grading → LUT Scaling** ports the Remastered
black/midgray/white sampling and OkLab lightness restoration. Default **0**
preserves native LUT levels; **100** applies full restoration. This differs from
Remastered's default 100 deliberately, pending scene comparisons. Gamut and HDR
range preservation stay active at 0. The zero setting bypasses additional LUT
endpoint samples; enabling scaling costs up to six additional texture samples
per active LUT. Constant black/white LUTs retain their native grade safely.

Unsigned R11 scene storage cannot preserve restored negative BT.709 channels.
Only backbuffer-sized R11 render targets join the existing FP16 clone rules;
smaller effects buffers retain native formats. DLSS still consumes nonnegative
color. Its existing output pass now restores the current negative-color residual
at jitter-correct input coordinates, following Ezio's approach. The residual is
not temporally reconstructed; disoccluded saturated edges need visual checks.
No extra fullscreen pass or readback is added. The full-size storage expansion
has a memory/bandwidth cost that requires live profiling.

WARP/NVIDIA effects tests cover all six native LUT variants, blend endpoints and
intermediates, Vanilla equivalence, Scaling 0 native-proxy equivalence, restored
black, degenerate LUTs and signed HDR round-trips. Actual NVIDIA DLAA/SR tests
verify negative output after reconstruction, poisoned subrect edges, jitter,
HDR/state restoration and shutdown. See `tests/README.md` and the latest handoff.
After restart, verify signed LUT/TAA surfaces, compare Scaling 0/50/100 in daylight,
storm transitions, interiors and cutscenes, and check saturated edges, fades,
native TAA/DLSS toggles and matched-scene performance.

The 2026-10-23 HDR audit adds the native two-environment weather filmic path,
manual exposure variants, multi-LUT environment blends, and final grading with
or without chromatic aberration and analytic/texture vignette. The paused boat
capture proved highlight compression in the previously uncovered weather pass.
Hair/material clamps are unchanged. The Release addon includes these fixes;
post-restart visual verification is pending. See the
[HDR permutation audit](../../../docs/WITCHER3_CLASSIC_HDR_PERMUTATIONS.md)
for captures, all shader hashes, GPU validation, and manual checks.

The captured cutscene uses final-grade shader `0x5CBEC131`, which omits the
gameplay vignette. Its HDR replacement shares the analytic grade/PsychoV
path with `0x649AF4FA`, skips vignette, and bypasses the native RGB clamps.
The existing full-resolution RGBA8-to-RGBA16F upgrade covers its output.
Captured cutscene depth-of-field buffers already use R11G11B10F; their
depth/blur-mask clamps are preserved. The new native decompilation passes
strict compilation; this variant still needs a live HDR visual check.

Object-motion coverage includes nine additional opaque forward skin variants,
selected from the paused NPC collar/neck investigation. They reuse existing
history and original-draw MRTs; verification of that specific gap is pending.

Opaque horse-tail coverage adds the captured Apex-deformed forward path and
one position/interface-matched cache variant. It reuses cloth history, keeps
the native .33 alpha cutoff and preserves clip-position precision. The user
confirmed this tail fix works. Check
Roach's tail in DLSS → Diagnostics → Object Motion / Coverage while the tail
moves and while panning the camera. Translucent fringes and HairWorks remain
separate work. See the [motion integration reference](../../../docs/OBJECT_MOTION_VECTOR_INTEGRATION.md#cpu-deformed-opaque-horse-tails-2026-10-23).

Foliage motion adds six native SpeedTree vertex paths and four material paths.
Previous GPU constants reproduce wind, camera-facing leaves/billboards and grass
contact bending in the existing draw; shared constants copy once per frame.
Native shading, alpha cutouts and depth positions are preserved. WARP and NVIDIA
fixtures pass. The user accepts the in-game foliage coverage. Whole-system motion
cost is still too high: the first attachment-batching revision showed no material
GPU improvement. Correcting Present/Flush cache invalidation subsequently produced a substantial improvement confirmed by the user (current full-coverage trace about 4.88 ms, earlier trace 9.32 ms; separate runs). See the performance investigation in the integration reference.
Test wind with the camera still, walk through grass, then pan across foliage/LOD
boundaries using DLSS → Diagnostics → Object Motion / Coverage. See the
[foliage handoff](../../../docs/WITCHER3_CLASSIC_HDR_HANDOFF.md#foliage-wind-and-contact-checkpoint-2026-10-23)
for the exact inputs, tests, remaining limits and build status.

## Menu

All setting definitions are explicit `new Setting{...}` entries in one ordered
`Settings settings` list in `addon.cpp`. Move a complete entry to reorder its
controls. The initialization loop wraps visibility to select the HDR or Effects
tab; it does not construct/reorder settings. Existing keys, defaults, preset
storage and reset behavior are preserved. Global DLSS preferences remain in the
same list, with its separate ImGui dropdown/diagnostic UI.

The addon frame has **HDR → Effects → DLSS** tabs. HDR contains Tone Mapping,
Scene Color Grading, Color Grading, PsychoV-31, Video AutoHDR and the existing
Options/Instructions/Links/About sections. Advanced mode exposes the grading
sections and PsychoV controls. Effects has Motion Blur, Depth of Field, Bloom,
Sunshafts, Lens Dirt, Vignette, Sharpening, Chromatic Aberration and Film Grain.
Sharpening retains its global storage; the other optical effects retain their
per-preset values. HDR and Effects share the standard preset selector.
DLSS contains Enable DLSS, Image Quality, Performance, Diagnostics and Status.
Its global preferences remain independent of HDR presets/Off.

Depth of Field's Native mode shows only Native Depth Blur; Custom shows only
its strength and lens controls. Off keeps the last group visible but disabled.
Hidden per-preset `FxDepthOfFieldControls` remembers that group across restarts;
old presets without the field use their active mode, or Custom when already Off.
Changing modes never resets either group's values. Motion strength is disabled
in Off, and custom Bloom controls are disabled in Native mode. CA intensity and
RCAS strength remain disabled until their replacements are selected.

Fresh DLSS settings default to enabled with **Quality** and **model M**.
Saved user choices are preserved; unsupported models retain the DLL fallback.
The HDR instructions explain Windows HDR and display peak setup. Peak Brightness
limits HDR highlights in nits, usually detects the display at startup, preserves
manual overrides, and resets to the detected value (1000 nits if unavailable).

Performance includes **Exclude Vegetation from Object Motion (high performance
impact)**, disabled by default. Enable it to use camera vectors for vegetation;
wind/contact deformation vectors are then omitted, which can increase temporal artifacts. Character,
cloth, bird and moving-prop motion remain enabled. Leave this option disabled when checking full foliage coverage.
When enabled, the option skips foliage history preparation and replacement shaders, rather than
merely hiding their vectors. It persists independently of HDR presets.

The quality dropdown lists DLAA, Quality, Balanced, Performance and Ultra
Performance. All modes are selectable. The first native scene-viewport integration
is active; Performance at 3840x2160 output was positively tested by the user.
The shared native pool stays output-sized while scene shading uses a smaller
viewport; NGX receives render-sized inputs and reconstructs before full-size
final grading/UI. All model choices K/J/L/M/C are active.
The dropdown requests the selected NGX preset and recreates the feature/history
when changed. Unsupported presets may use the runtime default; if explicit
feature creation fails, the addon retries once with default hints. These are
requested hints, not a report of NVIDIA's effective model after overrides.
Advanced diagnostics shows runtime-recommended input sizes for every quality
mode, queried only when output size changes. The native sizing investigation
and implementation sequence are in
[`WITCHER3_CLASSIC_UPSCALING_RESEARCH.md`](../../../docs/WITCHER3_CLASSIC_UPSCALING_RESEARCH.md).

Diagnostics provides Off, raw Object Motion / Coverage, final DLSS Motion Vectors,
Depth (Reverse Z), History Rejection Mask and DLSS Input Color. Final vector hue
indicates direction and brightness indicates magnitude (32 pixels/frame reaches
full brightness). The mask is our bias-current-color input, not internal DLSS
confidence. Views pass through later game effects/color processing. Advanced
diagnostics retains the Object Motion switch for camera-only comparisons.
The profiling button and its runtime sweep have been removed. Control explanations
are concise hover tooltips rather than persistent instruction paragraphs.

## Effects and reconstruction order

The retained Remastered controls and Custom optical replacements use Classic's DXBC passes:

- **Effects → Depth of Field → Native Depth Blur** scales depth-blur radius in Native DoF mode: 0 off, 50 native,
  100 double. It preserves the native sky treatment and alpha composite, and does
  not control Motion Blur or Witcher Senses.
- **Chromatic Aberration** selects Native or Custom lens dispersion, with
  an intensity slider. Custom works when native CA is off;
  its intensity zero removes native fringing too.
- **Perceptual Film Grain** uses the shared luminance-adaptive grain algorithm,
  after tone mapping and before UI. Default 0; Remastered strength 50 is available.
- **Vignette Strength** scales native radial/texture masks: 0 off, 50 native
  strength (default), 100 double. **Vignette Black Floor** defaults to **Perfect
  Black**, ported from Remastered: attenuate linear light after native output
  levels, before PsychoV, without blending in a colored floor. Above 50, optical
  density preserves detail in partial masks. Native mode retains the original
  colored blend. No-vignette permutations remain vignette-free.
- **Effects → Sharpening → Replace Native Sharpening** bypasses Classic's pre-TAA
  sharpening and uses **Lilium RCAS Strength** after reconstruction. It works with
  native Sharpening disabled, or with native TAA when DLSS is off. Replacement
  defaults off; strength 0 means no sharpening when replacement is on.

These controls require PsychoV, matching Remastered's custom-effect gating.
Vanilla and Preset Off preserve native effects. Sharpening preferences are global
in the Effects tab; HDR effect preferences remain per preset. Existing saved vegetation
preferences are retained even though the new default is off.

Captured order: depth blur `6ED58557` → bloom/native sharpening `3EDDC379` →
LUT → native TAA/DLSS `201C53B4` → final grade. RCAS replaces the native sharpen
with a center-sampling bypass and runs in all six final-grade permutations, before
native or custom CA. Grain follows PsychoV in that same pass. No extra fullscreen
render target or pass was introduced by those original controls. The Custom
pipeline below adds optical scratch passes; HUD/video rendering follows afterward.

`tests/effects.cpp` runs the actual Release FXC bytecode on WARP and NVIDIA:
six original-DXBC Vanilla comparisons; RCAS zero/active; CA active; changing grain
seeds; Vanilla isolation; blur default/off/double/sky; sharpening bypass color and
alpha; vignette 0/50/100, black-floor preservation and no-vignette isolation.
Fixture data and runner: `tmp/witcher3classic-investigation/effects-20261023/`.
Build the Release shader target first, then run `test-effects.cmd` there.
Manual checks: compare native Sharpening Off/High with replacement enabled, then
exercise RCAS/CA/grain after DLSS Quality and DLAA. Check HUD text, cutscenes,
menu return, blur 0/50/100 and Preset Off. GPU fixtures do not replace visual acceptance.
With native Vignetting enabled, compare vignette 0/50/100 and Native/Perfect Black
over dark scenery; check partial masks retain detail at 100 and cutscenes remain
vignette-free where the game omits it. Disable native Vignetting to check bypass.

Manual menu check: switch both tabs; confirm DLSS stays enabled across HDR
presets/Off; restart to check preferences persist; switch K/J/L/M/C while rendering;
cycle every debug view and return to Off. Check all quality modes, return to DLAA,
then toggle DLSS off/on. Confirm full-resolution UI and matching scene/vector
viewports in DevKit. Keep native Anti-aliasing enabled.

The main addon frame uses the standard RenoDX Off / Preset 1-3 selector, followed
by Simple / Advanced settings mode on HDR. Simple shows Tone Mapping;
Advanced adds Color Grading and PsychoV-31. Effects has its own tab. Preset Off restores
native tone mapping and default effects while retaining HDR transport.

Exposure uses 0-100 with 50 = neutral (1x). Values saved by the initial test
build are migrated once to this scale; multipliers above the new 2x maximum
are limited to 100. Gamut Compression is continuous from 0.00 to 1.00;
anchors use four decimals, and Gamma and Compression use two.

**Highlight Hue Response** controls Custom31's source/response midpoint
weighting within the observer response.

Peak Brightness detects the HDR display's reported luminance at swapchain
initialization, using the same RenoDX helper as Ghost of Tsushima and Ezio
Trilogy. Existing non-default manual values are preserved. Reset restores
the detected default; unavailable detection falls back to 1000 nits. The
Instructions, Links, and About sections in the same frame show detection
status, build timestamp, community links, and Hartapfel/ShortFuse Ko-fi links.

## Effects

Classic runs bloom and light-shaft extraction after the native filmic pass.
Extended highlights otherwise overdrive those SDR-tuned effects. The shared
extraction shader now limits each input sample with Remastered's Neutwo
reference-intensity approach, preserving sample hue and the main scene HDR
range. The reference peak is fixed at 1 in scene-relative units: Classic's
R11G11B10F intermediates cannot carry Remastered's alpha peak metadata.
This approximates bounded native effect energy; it is not an exact replay
of the native Hable curve. Vanilla skips this limiter.

Effects sliders use 0 = off, 50 = reference strength, 100 = double:

- **Bloom Strength** controls the Custom replacement bloom. It no longer changes
  BlitzFX's Bloom Scattering setting. Custom mode removes native uniform bloom
  and BlitzFX uniform scattering; underwater scattering and lens dirt remain.
  Native mode restores original bloom controls and ignores Custom strength.
- **Lens Dirt** scales only the dirt texture contribution.
- **Sunshafts Strength** scales masked sky input before extraction. The
  native threshold makes its response nonlinear. Requires the game's Light Shafts option.

The screen-blended HDR path prevents `(1 - scene)` from subtracting bright
scene values. Vanilla at default effect settings retains native arithmetic.
Lens dirt and sunshafts require the corresponding game effects to be enabled.
Custom bloom instead requires the native Anti-aliasing render boundary.
BlitzFX routing uses a per-device flag from its executed bloom pass, reset at
Present; it does not poll DLLs, scan resources, read back GPU data or wait for
the GPU. Verify performance with DevKit and offline replay tests disabled.

## Video AutoHDR

See the custom optical effects notes below for the separate gameplay effects; video
AutoHDR does not pass through their scene-depth/motion pipeline.

**HDR → Video → Video AutoHDR** offers Off / BT2446A, defaulting to BT2446A,
as in the Ezio Trilogy HDR mods. It expands prerendered SDR video only.
Game Brightness controls the inverse curve; Peak Brightness sets its highlight
endpoint. UI Brightness does not change the resulting video luminance.
Off and the Vanilla tone mapper select original game bytecode; Preset Off
also sets Video AutoHDR to Off. Reset All restores its enabled default.

The native `0x043049C7` draw was verified through DevKit: three R8 Y/Cb/Cr
planes, straight vertex-alpha fade, and an existing full-resolution FP16 output
clone before separate menu/UI draws. `video/` also covers the matching opaque,
premultiplied and separate-alpha-plane variants: `30C6DAFA`, `7542753B`,
`A850FB8D`, `989EB8B2`, `DC4FAC37`, `DCEB62A5`. Native YCbCr conversion,
alpha and fade multiplication remain intact. Other Scaleform color-transform
and debug-video permutations are not automatically replaced by pattern matches.

`video/common.hlsli` follows Ezio's gamma-2.4 SDR decode and BT.2446A mapping
at `peak * 203 / game_white`, then normalizes the result to `peak / ui_white`
and encodes it for Classic's gamma-2.2 composition. Unlike Ezio, Classic has no
final presentation shoulder to invert. The existing proxy applies UI-white
scaling and BT.2020/PQ output once. BT.709 gamut mode compresses video into
BT.709; wide-gamut modes preserve the expanded result.

Video fixtures pass on WARP/NVIDIA: seven native RGB/alpha comparisons, fades,
premultiplication, finite HDR, and 54 black/peak/monotonic-gray/UI-white
configurations per adapter. See [tests/README.md](tests/README.md). In-game
acceptance should include the opening video, a prerendered cinematic, subtitles,
fades, and switching Off/BT2446A/Vanilla. The user confirmed startup with the
matching-runtime build; that does not establish every video's visual acceptance.

## Build and verify

Build the game addon and loaded DevKit from matching shared-runtime headers.
An isolated checkout is suitable for shader tests but its DLL must not be
deployed alongside a DevKit built from a different runtime revision. The first
Video AutoHDR package exposed this: the two builds used the same shared
pipeline-layout UUID with different map/value layouts and crashed during
device initialization, before any video draw. The replacement package was
linked from the normal workspace with AutoHDR retained. Do not substitute an
isolated test DLL for the normal build merely because its shader tests pass.

Temporal AA/DLSS input investigation uses DevKit's opt-in
`devkit_capture_shader_inputs` tool, targeting native TAA shader `0x201C53B4`.
The temporary game-specific capture button/hooks have been removed. Capture
CBs b3/b10/b12 and preserve SRVs t0–t4 to inspect camera reprojection, history,
luminance and hardware depth at the draw. See `docs/DEVKIT_MCP.md` for commands.
The DLSS tab exposes **Enable DLSS**, quality, model and diagnostics controls.
The test replaces the native TAA draw through NVIDIA NGX on the game's DX11
device. It uses verified native jitter and camera reprojection, a GPU-only input
preparation pass, and an FP16-to-native-target conversion. It restores the full
native context state and falls back to native TAA if initialization/evaluation
fails. Selecting Native TAA releases the test's resources.

**Object Motion** adds previous bone poses, world transforms and reference-pose
textures to the captured skinned, rigid, CPU-deformed and opaque forward paths.
Compatible shader families are listed in
[`temporal/object_shaders.hpp`](temporal/object_shaders.hpp). Motion and surface
depth are written alongside native geometry without a second geometry draw.
Fingerprint-checked engine hooks observe object transforms, allocation/object
destruction and CPU-deformed owner scopes; they do not modify native data.
Allocation identity maps changing bone offsets to the previous palette while
allowing rotating native pose storage. Position transforms preserve the native
shader's replacement of bone element 15 with homogeneous W = 1.

CPU-deformed history retains GPU copies of positions and world transforms under
native game-proxy/generation/immutable UV-stream identity. The PhysX render
resource itself can rotate; the persistent Apex proxy supplies actor identity.
Cloth rotates three position and index
buffers; those transient addresses are not used as mesh identity. UV and position
vertex counts must agree. Rigid history covers batched and direct single-instance
submissions. Identity-palette skin permutations use rigid transform history,
including the captured mill-wheel path. Only opaque forward materials are
registered; soft alpha hair still needs explicit motion/depth compositing.

Missing or ambiguous history biases DLAA toward current color; a depth check
rejects occluded vectors. Native TAA disables capture/work and releases GPU
resources; native hooks remain inactive forwarders in a pinned module until
process exit. **Show Object Vectors** displays covered motion in color,
stationary geometry in gray, unavailable history in amber, and uncovered pixels
dark. It is off by default. While enabled, per-shader acceptance/rejection logs
help distinguish missing profiles from invalid history. The view displays raw
object coverage; DLAA preparation additionally checks final depth. Both BUFFER
and Classic's BUFFEREX structured bone views are supported by the GPU fixture.

The camera-only DLAA path is user-confirmed working. Object-motion stability
remains under in-game validation. The user confirmed the shared-palette flock
fix. That path tracks previous worlds by full native swarm
slot before visibility sorting/LOD partitioning, observes native Euler results,
and appends vectors to the existing draw. CPU/GPU fixtures pass. The user confirmed the preceding
cloth and sword-fitting fixes, improved hair/mill coverage and nearby soldier
faces. The latest stability revision replaces world-transform matching with
exact native proxy identities carried alongside the engine's packed CPU instance
arrays. Overlapping parts, new parts and reordered batches keep separate world
histories; ordinary skinned instances also use those per-instance worlds with
their shared previous bone palette. Destruction, mesh changes, ambiguous
observations and visibility gaps still invalidate history. Wholly stationary
rigid batches retain camera vectors, including in the diagnostic view. The first
identity revision did not fix the user's camera-triggered NPC flicker. The next
Release revision adds reference-skin variants ED64E04A / 8E6AB350, rigid variant
68D68CC2, and materials E76C261A / 035DA93A / C08941D9 observed in that scene.
The subsequent shader-family revision substantially improved stability, as
confirmed by the user. Wind vegetation and soft transparent layers remain
unfinished. True DLSS upscaling, menu recovery and managed jitter are now
implemented; DLAA uses a 32-phase Halton sequence. Native AA must be enabled
so the replacement draw executes. The supported camera contract is fingerprinted
against the investigated GOG 1.32 executable; other binaries retain native TAA.
Install `external/DLSS/lib/Windows_x86_64/rel/nvngx_dlss.dll` and its
`external/DLSS/LICENSE.txt` in `bin/x64/renodx-witcher3classic-dlss`.

`tests/dlss.cpp` exercises actual NVIDIA DLAA/DLSS evaluation, HDR preservation,
feature resizing, camera-vector preparation, output conversion and full context
state restoration. It also covers ReShade proxy/native device identity. Run with
assertions enabled from an x64 VS developer shell, linking the SDK's
`nvsdk_ngx_s.lib`, `d3d11`, `dxgi`, `user32`, `advapi32`, `shell32`, and `ole32`;
pass the runtime DLL directory as its sole argument. Synthetic GPU tests pass;
in-game output remains under validation.

Object-motion regressions from an x64 VS developer shell:

```powershell
clang-cl /std:c++20 /EHsc /O2 src/games/thewitcher3classic/tests/object_history.cpp /Fe:tmp/object-history.exe /Fo:tmp/object-history.obj
./tmp/object-history.exe
clang-cl /std:c++20 /EHsc /O2 /DNOMINMAX /Iexternal/Detours/include /Ibuild/thewitcher3classic.include src/games/thewitcher3classic/tests/object_motion.cpp /Fe:tmp/object-motion.exe /Fo:tmp/object-motion.obj /link d3d11.lib dxgi.lib user32.lib
./tmp/object-motion.exe <original-shader-directory>
```

The GPU fixture requires DevKit-exported original `.cso` files for the registered
geometry shader hashes in `object_shaders.hpp` in that scratch directory, plus
the Release target's compiled embeds. It compares native G-buffer colors across
compatible material pairs and native forward vertex varyings, then verifies
pose/root/camera motion, palette repacking, reference blending, MRT restoration,
occlusion, missing-history handling, rotating pose storage, direct attachments,
bone shading metadata, three rotating cloth position/index buffers, persistent
Apex owner generations, independent flock-instance worlds sharing one palette,
overlapping native mesh parts, newly visible parts, reordered/reallocated CPU
batches, exact mesh/array validation, and the stationary rigid fast path.

Run the GPU fixture on WARP and again with `--hardware` on NVIDIA. Tail tests
also check alpha discard, one-target restoration and exact clip-position bits
while consuming every native varying and the appended motion outputs.

Build the addon in Release using the established `clang-x64-release` preset
and target `thewitcher3classic`. Close the game before linking the loaded
`build/Release/renodx-thewitcher3classic.addon64`. The existing game-folder
symlink picks up that artifact. Generated shaders are under
`build/thewitcher3classic.include/embed/`.

After restarting, verify the latest corrected area in Object Motion / Coverage,
then use the final DLSS Motion Vectors view and normal output. Test both object
motion and a stationary object with camera movement, including camera pans,
LOD changes and menu return. Disable DevKit captures and debug views for matched
CPU/GPU timing. In-game acceptance and matched timing remain separate from the
synthetic tests; see the [current handoff](../../../docs/WITCHER3_CLASSIC_HDR_HANDOFF.md)
for the exact deployed build and outstanding checks.

## Custom optical effects (2026-10-26)

The optical filters are game-local. Required copyright/license notices are
retained in `optics/LICENSE.optics`. Build `thewitcher3classic` with the normal
root `clang-x64-release` preset. Reference-source provenance and the original
implementation manifest remain in the investigation archive.

### Controls and order

The Effects tab has separate Motion Blur, Depth of Field and Bloom sections:

- Motion Blur: Camera + Object / Object Only / Off. Strength 50 is a 1/60 second
  shutter; 100 is 1/30 second. All three custom modes bypass the old native and
  BlitzFX blur composites. Invalid/new history stays sharp. Object Only follows the visible screen trajectory, bounded by both visible
  and camera-removed object speeds. Camera-followed subjects therefore stay
  sharp. Object Only requires Object Motion enabled; vegetation exclusion also excludes its individual blur.
- Depth of Field: Native / Custom / Off. Custom exposes strength, manual focus distance
  in metres, focal length in millimetres, aperture and foreground coverage. Focus
  does not follow the game's cinematic focus. Zero strength stays sharp. Native
  restores game/BlitzFX DoF and enables the existing Native Depth Blur slider.
- Bloom: Native / Custom, strength, size and highlight selection. Default Custom size
  2 / selection 3 / strength 50 matches the reference enhanced Gaussian filter.
  Larger sizes increase pass count and GPU cost. It is independent of BlitzFX's
  Bloom Scattering setting. Native mode restores the original settings.
- Chromatic Aberration: Native / Custom. Intensity 1 uses the reference lens mapping. Existing saved preferences persist. Intensity 0 removes
  both native and replacement fringing. This includes lens warp, not just an
  RGB displacement.

New modes default to Camera + Object, Custom DoF and Custom Bloom. They require
PsychoV. Vanilla/Preset Off retain native effects. Keep native Anti-aliasing
on: filters run after DLSS or native TAA. If DLSS is off but the new filters
need inputs, BlitzFX TAA is routed through Classic's native TAA boundary. With
those filters disabled and DLSS off, normal BlitzFX TAA routing returns.
The replacements do not require native Blur/Motion Blur/Bloom enabled;
disabling these native options can avoid their unused intermediate work.

Order: scene/exposure/LUT -> TAA or DLSS -> Custom bloom -> near/far DoF -> motion
blur -> RCAS -> lens warp/CA -> final analytic grade, vignette and PsychoV ->
perceptual grain -> UI. Classic's source is already linear BT.709: do not copy
an additional extended-sRGB decode into this chain. Signed color is retained, with
finite output bounded only for FP16 storage. NGX's signed residual is unchanged.

### Implementation and invariants

`optics/pipeline.hpp` owns pooled scratch and isolated D3D11 context state.
Capture retains prepared depth/vectors, copies the native frame CB as a whole
resource, and records render dimensions, raster jitter and history interval.
Run executes once per main-scene frame before all twelve final-grade variants,
substituting only a scratch PS t0 during the grade and restoring the original
binding afterward. NGX output/history and native scene textures are not modified.
Missing/current-frame-invalid inputs skip the new filter draws.

Private `F3C20001` implements signed-CoC near/far reduction, 49/97-tap Vogel
DoF disks, premultiplied foreground coverage and bilateral reconstruction.
Motion uses reference velocity units, five tile-max reductions, neighborhood
max, depth/radius bake, two half-resolution McGuire gathers and coverage blend.
The measured history interval controls half-shutter scaling and rate bounds.
Depth and velocity sample the same jittered render grid at the output position;
jitter is removed once. Missing consecutive frames or camera cuts exceeding
3 metres / 45 degrees suppress blur. Camera pose uses the existing verified,
read-only CPU camera contract, with no synchronous GPU readback.

For Object Only, `motion_camera.hpp` and `F3C20002` form
`currentUnjitteredVP * inverse(previousVP)` on the GPU. Transforming homogeneous
previous positions yields `Pcurrent(Xprevious)`, removing translation, rotation
and projection changes before perspective division. This identifies the object contribution without subtracting an approximate
camera vector at current depth. Blur then follows the visible XY trajectory,
scaled by min(1, object_speed / screen_speed), with output-pixel speed units.
That Remastered rule preserves camera-follow cancellation; ZW alone would
blur a subject that moves through the world but stays still on screen. Current/previous jitter are handled
separately; the matrix is cached per camera-buffer pair/frame.

Existing object histories and vertex outputs are unchanged. XY remains the
full DLSS vector. Only Object Only mode expands the motion attachment from
RG16F to RGBA16F; ZW stores blur-only motion. The signed object-depth validity
contract stays intact. PS t119 is audited unused and saved/restored around
covered draws; native lighting constants are untouched. Switching mode resets
only that motion attachment. No additional geometry replay is introduced.

| Effect | Native boundary | Retained behavior |
|---|---|---|
| Classic motion blur | `1A70FFE2` | Sharp t0 RGB; alpha 1 |
| BlitzFX motion blur | `249DA2F1` | Sharp t52 RGB; red-channel alpha |
| Classic depth blur | `6ED58557` | Disabled only in Custom/Off DoF |
| BlitzFX depth blur | `9A905454` | Transparent color; SV_Depth 1 |
| BlitzFX bokeh | `AE334616` | Transparent color/native depth for bypass; corrected pool sampling in Native mode |
| Native uniform bloom | `620431CF`, `0CB5EA21` | Separate dirt/sunshafts retained |
| BlitzFX bloom | `BF3EF83C` | Underwater scattering retained; early sharp copy when inactive |

The existing `blitz_bloom_active` field is per-draw routing: 0/1 for native bloom,
-1 for replacement BlitzFX bloom, -2 for the DoF bypass. Each relevant injection
callback sets it. This does not write BlitzFX configuration. Compute b13 is
restored after dispatch. Native intermediates are not globally skipped before
proving that other effects do not consume them.

Custom source map: `mb_velocity.frag`, `mb_tile.frag`, `mb_bake.frag`,
`mb_mcguire.frag`, `mb_composite.frag`; `dof_ratio.frag`, `dof_down.frag`,
`dof_blur.frag`, `dof_blend.frag`; `bright.frag`, `gaussian.frag`,
`kawase_sum.frag`; `lens_mapping.glsl`, `lens_filter.glsl`, with orchestration
in `src/engine/render/scene_post.cpp`. Classic CA lives in
`effects/chromatic_aberration.hlsli`. RCAS sharpens once before cubic lens
sampling instead of repeating a complete sharpen operation at each lens tap.

### Evidence and acceptance

Live original-shader/input evidence is under
`tmp/witcher3classic-investigation/pt-optics-20261026/`. In that scene TAA
`201C53B4` is draw 1762; final `114D8828` is draw 1764. Quality renders
2560x1440 in a 3840x2160 pool. Earlier native motion-blur captures are under
`temporal-dev/devkit-live/dlss-audit/`, with original final-composite DXBC in
`hdr-permutations-20261023/cache/`. These captures are evidence, not runtime
requirements.

WARP/NVIDIA optics tests cover HDR and signed colors, focus identity/defocus,
zero-motion identity, Object Only camera exclusion and actual object blur,
30/60/120/240 FPS shutter equivalence, history reset, odd-size resize, state
restoration and 32 camera transforms with distinct current/previous jitters.
Object/foliage regressions also exercise expanded RGBA motion output without
changing native lighting, alpha coverage, clip or previous-position results.
See `tests/README.md` for reproducible commands.

The normal Release addon was linked and installed through the existing game
symlink: SHA256 `92EC6D8C9B46305809441F1D8E598A50490B4EC6B552E8CB0EAC5C03D33721A5`,
8,395,776 bytes. The optical/native-effects tests pass on WARP/NVIDIA; full
Object Only geometry/foliage and BlitzFX regressions pass on NVIDIA. Original
two-channel geometry/foliage regressions pass on WARP. The previous installed
DLL and exact logs/manifest are archived in the evidence directory above.

The user confirmed that the new effects look correct in-game, except that
Object Only blurred camera-followed Geralt. The follow-up applies Remastered's
visible-trajectory rule: XY * min(1, length(ZW in pixels) / length(XY in pixels)).
This limits object-only blur to actual screen movement while keeping the exact
camera-removed data and DLSS XY vectors intact. Combined mode is unchanged.
The follow-up also renames effect options to Custom and removes the CA centre
offset control and its shader behavior; stale saved values are ignored. The
160-byte injection layout keeps that old field as reserved padding.

The follow-up passes WARP/NVIDIA camera-follow, optical and native-effects
regressions. It is built and installed through the normal game-folder symlink:
SHA256 `85BA3F7D068F24B189FD2E7E569FE225EF61518D26C19C55156E9BCCBD7BFE77`,
8,389,120 bytes. The earlier hash describes the original optical build. The
follow-up's restarted visual acceptance remains pending. Compare walking/running
Geralt in Object Only and Camera + Object; verify the torso remains sharp when
tracked, visible limb motion still blurs, and static backgrounds remain sharp
in Object Only. Check the Custom labels and intensity-only CA controls.
Check camera-only and animation-only movement, moving foliage, cuts, cutscenes,
near/far silhouettes, CA zero/reference, Bloom zero/reference/Native, Quality,
DLAA and native TAA, menu/video transitions and resizing. Debug vector views
skip the optical chain. Measure performance with capture/debug off; GPU fixtures
are not proof of in-game performance or visual acceptance. Eliminating unused
native intermediate work remains a measured follow-up, not an assumed saving.


Menu-only verification for the Effects-tab revision: all 53 pre-existing
explicit defaults match the preceding source, including the user's tuned focus,
focal length, foreground blur, bloom, CA and film-grain defaults. No shader or
rendering changes are included. After relaunch, verify HDR/Effects/DLSS order;
Native -> Off -> Custom -> Off depth controls; disabled Off controls; preset
switching/restart while Off; and persistent RCAS preferences in Effects.


## Atmospheric rendering and water � 2026-10-27 development checkpoint

The Graphics tab sits between Effects and DLSS. Atmospheric Fog and Water
Shading each default to **Native**, independently. Custom fog exposes density,
start distance (metres), directional-light scattering, anisotropy and height
falloff. Custom water exposes clarity. Existing HDR, optical and DLSS defaults
and the 160-byte shader injection ABI are unchanged.

### Research and implemented model

The fog architecture follows the frustum-volume approach described by
[Wronski, SIGGRAPH 2014](https://www.realtimerendering.com/advances/s2014/wronski/bwronski_volumetric_fog_siggraph2014.pdf):
store coefficients in a camera-aligned volume, then integrate scattering and
transmittance along its rays. The implementation uses logarithmic **radial**
distance, 160 columns, aspect-dependent rows (90 at 16:9), 96 cells and 97
integration boundaries over 0.1�1000 m. This is not a depth-linear texture.
`volumetrics/math.hlsli` implements Beer�Lambert extinction and normalized HG;
`0xF3C30001` injects weather ambient plus sun/moon lighting and native cascade,
terrain and cloud visibility; `0xF3C30002` integrates with the incoming segment
transmittance before updating it. See also
[Unity's volume math](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.core/ShaderLibrary/VolumeRendering.hlsl)
and [PBRT transmittance](https://pbr-book.org/4ed/Volume_Scattering/Transmittance).

Water is a single-layer, homogeneous optical material, using the game's waves,
water-exclusion volumes and existing SSR/fallback reflection chain. Its design
is informed by [Epic's Single Layer Water model](https://dev.epicgames.com/documentation/unreal-engine/single-layer-water-shading-model-in-unreal-engine),
[PBRT dielectric Fresnel](https://www.pbr-book.org/4ed/Reflection_Models/Specular_Reflection_and_Transmission)
and [Filament's GGX/Smith BRDF](https://google.github.io/filament/main/filament.html).
The material uses IOR 1.333, complementary reflection/transmission, depth-based
Beer�Lambert absorption, homogeneous single scattering and direct sun/moon
specular. Normal derivatives broaden unresolved direct-light highlights.
Refraction traces a Snell ray through the opaque depth buffer using
perspective-correct reciprocal-W interpolation. At most 16 coarse steps and
five refinements find a depth crossing; a final plane solve refines its optical
length. This bounded traversal is based on
[McGuire and Mara's screen-space ray tracing](https://jcgt.org/published/0003/04/04/paper.pdf),
not a full-resolution DDA or geometry ray tracer. Foreground/depth-error and
screen-edge checks reject unreliable hits. Missing geometry falls back to the
unshifted background with its measured submerged path, not an opaque deep-water
color. A 5 cm intersection-coverage fade removes full-interface shading over
foreground terrain. The user accepted both looking-down refraction and shores.

Absorption at 650/550/450 nm is approximated as RGB
(0.3594, 0.0654, 0.0110) m^-1; molecular scattering is
(0.0007, 0.0014, 0.0033) m^-1. Source:
[NASA Ocean Optics Protocols, Volume IV, Table 1.1](https://oceancolor.gsfc.nasa.gov/docs/protocols/Protocols_Ver4_VolIV.pdf),
which attributes absorption to Pope/Fry and the selected scattering values to
Buitveld. This three-wavelength RGB approximation is **not** spectral integration
or a measurement of any in-game river. Neutral suspended scattering defaults to
0.5 m^-1 (a 2 m scattering mean free path), an authored river-material choice.
Clarity scales that scattering distance; molecular absorption stays fixed.
It does not tint the final image to match the sky. The first test used only
0.015 m^-1 suspended scattering and was visibly too clear.
Native water uses its own authored ambient input cb0[11].rgb; BlitzFX uses
its dedicated water-sky ambient texture t7. Do not use frame[40] here: that
is the atmospheric in-scattering source, not water illumination. Direct sunlight uses
the captured lighting constants and the native water shadow calculations.

### Native integration and binding contracts

- `C8C78997` is the atmospheric composite: reverse depth t0, unfogged HDR scene
  t1, AO mask t2, native frame b12 (4304 bytes), lighting b13.
  The original sky-black branch and AO influence remain. Custom applies
  `scene * T + L`. Missing/invalid private resources fall back to native math.
- `volumetrics/runtime.hpp` runs at that pass once per frame. Compute uses a
  separate D3D11 context state; native constant buffers are never overwritten.
  Forward sampling uses PS t116/t117 and s11, restored after each draw. The native
  comparison sampler is reused rather than assuming its comparison direction.
- Sky `BC930752`, native water `28D7BDFE`, BlitzFX water `2825099C` and the
  registered forward material families consume the same integrated atmosphere.
  Additive materials use transmittance; ordinary forward fog receives L/(1-T)
  and opacity 1-T, preserving the native lerp contract.
- Custom water snapshots only the active render rectangle of **pre-fog t1** into
  a private floating-point texture at C8. It also copies the native frame CB on
  the GPU. This avoids fogging the river bed through air before applying water,
  or attempting unstable inverse-fog division. No CPU readback or geometry
  replay is involved. Native water mode makes no such copy.
- Water uses PS t113 (frame snapshot), t114 (unfogged color), t115 (one float4
  of extent/clarity/validity), s12. All are scoped and restored. Captures must
  match the current frame/context and active extent. Resizes recreate only the
  affected texture. The copied frame's rows 210�213 reconstruct world position
  from **integer** pixels and reverse depth. View rows 1�4 / projection 13�16
  project it back to pixel centers; the captured corner/center round trip was
  within 0.001 pixel. Depth loads use active pixel coordinates, not allocation UV.
- `water/shading.hlsli` returns base RGB with air fog already applied and a linear
  reflection weight F*T. Native reflection composite `35624BD6` **squares** the
  water-mask alpha, so both water adapters encode sqrt(weight). Native normal
  packing, exclusions and BlitzFX's third output remain. Underwater branches
  remain native; this is an above-water material replacement.
- The registered water shaders do not use RenoDX's ordinary b13 injection;
  b13 belongs to native lighting. Keep this invariant when adding variants.

### Proven transparent-distance error and live feedback

The original new `SampleClassicFogPixel` incorrectly divided by SV_Position.w.
An actual D3D11 perspective rasterizer test proves that this pipeline supplies
clip W/view Z there (not GLSL's reciprocal gl_FragCoord.w). At the river,
raw diagnostic output before tonemapping measured a surface 11.2266 m away,
while the old helper sampled at 0.0928 m. The corrected expression multiplies
abs(W) by the view-ray length. It fixes the shared transparent helper, not a
water-specific brightness multiplier. The user reports the live native-water
correction **looks better**; that is not full acceptance of the later Custom
water material.

Fog was visually accepted with BlitzFX and reported working without it. The
standalone river then exposed the distance error. Evidence/captures/build tools
are under `tmp/witcher3classic-investigation/volumetrics-20261027/`: Native/Custom
river references, `water-distance-values.exr`, original shader decompilations,
constant captures, numerical tests and build logs. Temporary diagnostic colors
have been removed from the live native-water shader.

### Validation and remaining work

WARP and NVIDIA pass the volumetric, native-fog composite and water fixtures;
see tests/README.md. The fog's native branch is exactly equal to captured
original bytecode in that fixture; custom masked composition differs by at most
1.90735e-6. An actual rasterizer test catches the W-versus-reciprocal mistake.
The production-resolution synthetic volume benchmark measured ~0.02245 ms GPU
and ~0.00115 ms CPU submission on RTX 5090, **not an in-game performance result**.
It excludes water, transparent sampling, cloud/terrain textures and capture cost.
The D3D debug layer was unavailable, so numerical/state tests ran without it.

The water Release build is installed through the game-folder symlink (8,610,816
bytes, SHA256 `5AC3F036EB596EA78DAD2C2BD70FE329C4E6AF56D575D45D06508CA19EE817AB`).
Its shared shading/resource tests pass. The user rejected this initial water
build as too bright, patchy and too clear underwater. The corrected live
revision described below has been accepted; its replacement DLL is pending. First test
the same river without BlitzFX, Custom water with both fog modes, clarity,
shoreline/boats and grazing reflections. Then test DLAA, Quality and Performance,
underwater transitions, weather/time changes, cuts and save/menu recovery.
Restore BlitzFX for a separate comparison only while the game is closed.

Known limits: no local torch/spot volumetric injection or volume temporal
reprojection yet; the distant volume clamps to its last integrated boundary.
SSR still has its existing screen-edge/history/occlusion limitations. Water
retains the native water ambient input and environmental reflections; it
does not implement spectral optics, caustics, full rough refraction or a new
underwater renderer. Standalone forward variants FAB74FB3 and 2472CF83 were
identified in the dump but remain an audited-coverage follow-up; do not claim
all transparent permutations or all weather states are validated.

Session state: BlitzFX was temporarily disabled for the standalone comparison
by renaming `blitz-fx.asi` to `blitz-fx.asi.volumetrics-disabled`. Confirm actual
files before restoring. The previous live override used the scratch `water-live` folder. The game was
closed before linking; ReShade.ini has no persisted LivePath and the default
live directory is empty, so restart clears that override. **Do not
use DevKit's global unload-live-shaders command as cleanup:** it removes all
runtime replacements, including other addon shaders. Restore production content
or restart instead.


Water visual follow-up: diagnostic RGB separated foam, shadow visibility and
reflection weight; another shader output the actual submerged path length.
The latter reached 15�28 m at sampled river pixels, confirming the clear-water
coefficients could retain too much green/blue background contrast. Fog-source
frame[40] was approximately (4.93,5.94,7.24) and was incorrectly used as surface
ambient. The corrected adapters pass native cb0[11] / BlitzFX t7 instead.
The river default now uses a 2 m particle-scattering mean free path, adjustable
through Water Clarity. Both changes preserve Fresnel, specular highlights and
the complete reflection pass. All temporary diagnostic/no-SSR changes were
removed. The user reports **�yes, waaay better�** with this live revision.

Evidence: `water-components.exr`, `water-depth-values.exr`,
`water-new-inputs.json`, `water-lighting-medium-fixed.exr` and corresponding
analysis JSON under the existing scratch directory. The final capture has only
finite pixels. Preview PNGs are reduced-exposure SDR inspection aids, not
colorimetric HDR comparisons. The test now poisons atmospheric frame[40] while
checking independently supplied water ambient, preventing this input-confusion
regression. Broader weather/water-body and BlitzFX acceptance is still pending.


Water sunlight transport: with Custom fog, an analytic exponential-height-medium
integral attenuates incoming sunlight before it reaches water. Camera-path
transmittance still applies once at final composition. The same incoming-light
integral is used in the custom fog injection shader. This follows the distinction
between opaque visibility and medium transmittance in
[PBRT's direct-light integration](https://pbr-book.org/4ed/Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators).
It is not a fixed highlight multiplier or another cloud shadow: native weather
light color and cloud/terrain/cascade visibility remain inputs. Vacuum leaves
light unchanged; density, height and sun elevation determine the loss.

This remains a local single-scattering approximation: the light integral is
bounded to the fog volume's 1000 m range, treats the height medium as continuous,
and does not model the camera-relative start-distance cutout on the incoming
light ray. It does not rescale native opaque surfaces' lighting or solve new
sky/SSR transport. Global atmospheric attenuation already authored into the
weather light is retained, not reconstructed. Do not claim a calibrated physical
match for every weather state or water body.

Looking-down follow-up replaced the single estimated-bottom-plane projection
with the bounded depth traversal described above. The first traversal fixed
the displaced riverbed/plants but exposed invalid-hit shoreline fallbacks;
preserving the unshifted background and fading contact coverage fixed those.
Evidence: `water-refraction-trace.exr`, `water-shore-fallback.exr`.
The next water-only live update added incoming local-fog sunlight attenuation;
the user reported **"much better!"**. `water-sun-before.exr` and
`water-sun-after.exr` record that comparison. Both output captures are finite.
These are live native-water checks without BlitzFX. The matching fog-injection
change is compiled/tested but requires the next DLL restart to run in-game;
the installed initial-water DLL does not yet contain these follow-ups.
The current live path remains the scratch `water-live` directory, containing
only the native water hash. No diagnostic color or reflection-disable branch
is active. Rebuild/link the Release addon after the game closes, then verify
the combined fog/water result without relying on this live override.


### Igni/particle fog regression and late emissive water reflections (2026-10-27)

The live paused Igni comparison exposed missing sparks in Custom fog. Four
replacements (A7921C82, 8C9C55EC, 5F9AE754, 22FD7485) had prepended a new
SV_Position parameter, moving their native TEXCOORD inputs to different
registers. D3D11 consumes the register layout, not just semantic names. Move
SV_Position after the existing native inputs. The user confirmed sparks returned
with the corrected live shaders. Do not fix this by boosting particle brightness
or bypassing fog. The actual A792 spark PS now has a GPU regression test using
the native VS output layout and exact unfogged-emission comparison.
[Microsoft signature/linkage contract](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-signatures).

Active fire variants 4EF2AAF8 (additive) and 44ECC136 (premultiplied alpha) now
consume the custom volume at the particle fragment while retaining native
soft-depth, texture, animation, color and lifetime terms. Additive particles
receive T only; alpha particles retain their native premultiplied-alpha contract
with L/T. The 2472CF83 additive variant applies custom transmittance after its
native gamma decode, so transmittance stays linear. A compiled signature audit
checks all 16 fog/water replacements against captured original DXBC.
FAB74FB3 remains a separate forward-skin follow-up: its decompilation contains
an unresolved raw-buffer instruction; no speculative skin replacement was kept.

Snapshot `igni-draws1.json` shows water at draw 1225, SSR/composition 1227-1239,
and Igni particle families at 1271-1287. These effects cannot appear in that
same-frame native reflection source because they have not yet been drawn.
The new `water/reflections.hpp` captures the missing late additive layer during
its original draws and adds a bounded screen-space reflection before the
scene tonemap/optical effects, and hence before Classic's reconstruction pass.
There is no geometry replay or CPU texture readback.

- Water writes world normal XY, view depth and linear F*T coverage to private
  MRT4. Both native and BlitzFX water adapters retain their original MRTs.
- Late additive A7921C82 / 02A34C28 / 4EF2AAF8 / 105478E1 also write MRT4,
  this time to emission RGB + nearest emitting view depth. Only native ONE/ONE
  additive draws are accepted. Original RGB/alpha/depth and native blending are
  untouched. Derived independent blend states are cached; private blending adds
  emission and takes MIN depth. Render targets/blend state restore after draws.
- Capture runs only with Custom water and a valid current-frame water capture.
  Pre-water particles are left to the original path. Resizes invalidate captures;
  menu/stale frames and frames without emissive draws do not compose old data.
- Compute shader F3C40001 projects a reflected ray and traverses a separate
  transparent depth layer (up to 64 steps, 60 m), with opaque-depth occlusion,
  screen-edge/distance fade and the water's existing Fresnel/camera-fog weight.
  Custom fog also attenuates the particle-to-water path. Native-fog mode retains
  the particle's native camera-fog approximation. The resolved scene feeds the
  existing optics chain; all temporary SRV substitutions restore afterward.

This is an experimental single-layer screen-space extension, not ray tracing.
It cannot reflect hidden/off-screen emitters. Thin sparks can fall between
bounded samples; overlapping emitters share their nearest depth and summed
radiance. Native environment/SSR still supplies the other reflections. The
approach follows the perspective-correct screen-space traversal cited above;
[Godot's SSR documentation](https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html)
explains why ordinary opaque-depth SSR misses transparent objects. This explicit
particle layer supplies the missing depth, with the limitations just described.
There are two render-sized FP16 capture targets plus a scene resolve texture;
in-game cost has not yet been measured. No claim of free reflections is made.

Validation: original spark output/fog composition pass WARP and NVIDIA. The
reflection fixture checks a reflected emissive plane against expected Fresnel
energy, unchanged native color, MRT/blend restoration, frame freshness and
foreground occlusion. Initial reflection implementation still requires linking
and the paused in-game Igni comparison; do not report reflection acceptance from
the earlier spark-fix feedback. Source/build/capture logs remain under the
existing `volumetrics-20261027` scratch folder. BlitzFX remains temporarily
renamed to `.volumetrics-disabled` for this standalone test.


Deployment update: Release linked successfully on 2026-10-27 after Classic
closed. Installed game-folder symlink points to
`build/Release/renodx-thewitcher3classic.addon64`, 8,679,424 bytes, SHA256
`2DF7E477A56D77EDB96016761ABC497A476675FCDBF3D68CCAE8487C9E76F292`.
This supersedes the earlier initial-water build status above: the embedded
shaders now include the accepted refraction/shore/sunlight fixes, the four
particle linkage fixes, added active particle fog variants and the first late
emissive reflection path. WARP/NVIDIA reflection and actual-spark tests pass,
as does the 16-shader native-signature audit. Live spark restoration was accepted
before linking; in-game reflection appearance/performance and the matching
volumetric incoming-sunlight update still require the requested restart check.
BlitzFX is still `blitz-fx.asi.volumetrics-disabled`. Do not mistake that standalone
result for a combined BlitzFX acceptance. Build log: `particle-release.log`.


First reflection build follow-up: the user's initial Igni test exposed two
separate issues. The scene blowout was NOT reflection energy: native water and
zero reflection emission did not fix it, but restoring original 4EF2AAF8 did.
The decompiler translated DXBC `and mask, 0x3f800000` into numeric 1065353216
instead of selecting float 1.0. Replace that line with `mask ? 1.f : 0.f`.
The full UV/radial-domain original-bytecode test now matches exactly on WARP and
NVIDIA, with custom transmittance checked separately. The corrected live fire
was accepted as normal. Earlier signature/math tests did not detect this
material-code error; do not rely on compilation or signatures alone.

Reflections were absent because runtime guards rejected the actual game inputs:
A792 uses ONE/INV_SRC_ALPHA with output alpha zero (therefore additive), and the
pre-tonemap scene is R11G11B10_FLOAT. The capture now accepts that exact blend
contract only for the audited zero-alpha shaders. Resolve accepts R11 input and
writes an RGBA16F result, converting through the compute shader rather than an
invalid cross-format CopyResource. Partial-pool padding is cleared; original
compatible float formats retain their existing copy path. The reflection GPU
fixture now exercises these captured blend/format contracts on WARP and NVIDIA.
A one-time log confirms actual reflection composition, instead of inferring it
from shader registration. These changes require another Release link/restart;
water reflection appearance/performance remains pending until verified live.
Evidence: `igni-broken.exr`, `igni-neutral.exr`, `igni-native4ef.exr`,
`igni-glow-fixed.exr`, `igni-particle-draw.json`, `igni-tonemap-draw.json`,
`igni-glow-test.log`, `igni-contract-test.log` in the existing scratch directory.
Temporary native CSO comparisons and zero-emission overrides were removed;
all nine current live HLSL overrides contain production code.


Corrected Release installed after shutdown: 8,679,424 bytes, SHA256
`76FD647A8758A5AAE4A65C931118F80A809C0AA528DBF2815EBA06643C10592B`.
This includes the exact-bytecode glow fix and captured blend/format support.
It supersedes the rejected `2DF7E477...` build. Log: `igni-corrected-release.log`.
Post-restart reflection verification is pending.


### 2026-10-27: emissive reflection noise follow-up

The 76FD647A build composed reflections successfully, but the user reported
moving bright speckles across the water during Igni. The fresh captured frame
`igni-current-noise.exr` agrees. Earlier `igni-noisy.exr` and
`igni-noisy-custom.exr` were stale resources left from a Native-water state;
always queue a fresh snapshot and resolve the current final draw/RTV before
comparing live images. A valid old resource handle is not proof of freshness.

F3C40001 now traces at half width and height into a separate RGBA16F radiance
texture (alpha holds surface view depth). Projected ray segments are clipped
to the viewport before selecting the 64 traversal steps. Without clipping,
near-camera rays could cross the whole visible region in their first step,
missing valid emitters. Intersection travel uses perspective-correct depth.
Valid water misses retain zero radiance and valid depth for normalization.

F3C40002 reconstructs only reflected radiance with 17 spatial taps in a 7x7
half-resolution footprint, weighted by distance, water depth and normal.
It rejects opaque foreground/land and preserves the original scene channels
and alpha. Sample locations match the tracer's even full-resolution pixels.
The sharp scene is added only after filtering. There is no temporal history,
so ended effects cannot leave old reflected emission through history reuse.
This is a spatial stabilization step, not a complete temporal denoiser or a
claim of physically complete reflections. Screen-space visibility, single
particle-depth layer, additive overlap and missing off-screen emitters remain
limitations. Moving-scene stability and performance still need live testing.

Design reference: AMD FidelityFX reflection denoiser spatial reconstruction:
https://gpuopen.com/manuals/fidelityfx_sdk/techniques/denoiser/
This implementation does not port its temporal reprojection/history stages.
Perspective-correct screen-space traversal reference:
https://jcgt.org/published/0003/04/04/paper.pdf

The production capture/trace/filter fixture passes on WARP and NVIDIA. Uniform
plane energy is preserved within two FP16-store quantization error bounds;
the R11-to-RGBA16F case allows 0.003 absolute error (WARP measured 2.59766
against expected 2.6). Sparse checker emission has mean 4 before/after and
variance 1.80434 after filtering versus 16 before, with exact land exclusion,
unchanged base G/B and alpha. This controlled spatial test does not establish
temporal noise elimination in the game. Logs: `igni-filter-final-build.log`,
`igni-filter-final-test.log`, `igni-filter-release.log` in the session scratch
directory. Accepted refraction, shoreline, fog/sun attenuation and particle
material/linkage fixes remain intact. BlitzFX is still temporarily disabled.

Reflection-noise Release linked after shutdown: 8,684,544 bytes, SHA256
44E6FF5ED453982033DE3A62EA90AA4F7187B950B0588ED814C813B1ED0765AE.
The game addon symlink points to this Release file. In-game noise acceptance
is pending; do not describe the controlled filter test as live confirmation.


### 2026-10-27: replace rejected particle SSR with native history input

The user rejected the 44E6FF5E reflection-filter build: Igni reflections still
looked poor. Its spatial test results did not predict acceptable live quality.
That implementation is superseded, not an accepted optional mode.

Primary reference is now the actual MIT-licensed BlitzFX source:
https://github.com/sven-luepke/blitz-fx/tree/659e239cfcba9cf0362621486ecdb241b0eee168
See water/THIRD_PARTY.md for the relevant files and full license. The local
read-only reference is under the session scratch directory's blitz-source/.
PreSSRDownsamplePS samples a reprojected previous raw HDR scene with four linear
taps; post_processing_renderer.cpp saves that scene before postprocessing.
WaterSSRCompositePS uses reprojection and neighborhood-clamped temporal history.
BlitzFX does NOT implement our rejected additional particle-depth ray tracer.

The standalone addon now replaces native pre-SSR downsample 406B9233. Its source
and DXBC were freshly captured through DevKit; the original checksum matches
BlitzFX's source shader mapping (4dfdf166-8c757f04-342c4883-d999a91d).
Capture ordering in native-ssr-draws.json: atmospheric fog 1182, SSR preparation
1193, water 1197, SSR history 1210, water composition 1211, late Igni 1234-1250,
raw exposure/curve 1258, final analytic grade 1288. Draw indices are snapshot-
specific. The old extra reflection overlay ran at the final grade, AFTER
temporal reconstruction, despite an earlier log describing it as pre-tonemap.
Do not reuse that incorrect earlier timing description.

Implementation:
- water/reflections.hpp saves raw scene color at the four native exposure-curve
  permutations B4953357/AEE0B973/AE7D5FA8/51F4E5FD, before tone mapping.
- It requests capture only when this frame's native SSR preparation ran with
  Custom water. The color includes the late particle draws naturally; no
  particle shader whitelist or additional particle MRT is needed.
- One reusable opaque-depth history is copied immediately AFTER SSR input
  preparation, BEFORE water writes depth. The previous depth has already been
  consumed by that draw. One raw-color copy and one 4304-byte camera copy follow
  at exposure. No CPU readback, replay, new draw or compute dispatch.
- Private PS t108..t113 carry current depth, previous depth, previous raw color,
  previous/current camera data and parameters; s12 is linear-clamp. All bindings
  are saved and restored. Native b0/b3/b12 are untouched.
- Both histories are cropped to the actual render extent, preserving DLSS
  render-to-pool semantics. RGBA32F/RGBA16F/R11G11B10 color and native typeless
  R24 depth are supported without cross-format copies.
- 406B9233 reconstructs world position with the current inverse VP, projects with
  the previous view/projection (including its actual jitter), validates previous
  opaque depth, and averages four bilinear HDR samples. It removes the native
  luma-10 limit only on the valid history path.
- Exact native fallback applies for startup, skipped frames, resize, disocclusion,
  off-screen/behind-camera reprojection, large camera displacement/rotation or
  invalid data. Custom-water disable invalidates history. No radiance history
  accumulation is added; a vanished effect disappears from the input next frame.
- The existing native SSR trace, temporal clamp and water composition remain
  responsible for reflection placement/stabilization and the accepted water
  Fresnel/fog weighting. Native water mode remains native.
- With BlitzFX active its different pre-SSR shader remains in control; our
  native-only callback does not capture or add another reflection. Existing
  BlitzFX render-subrect fixes stay registered.

Removed the F3C40001/F3C40002 compute shaders, extra water/particle MRT outputs,
blend-state capture machinery and final-grade reflection overlay. The particle
fog linkage and 4EF2AAF8 material bit-mask correction remain. Old raytracer tests
are archived in scratch, not treated as proof of the new integration.

Validation: current Release shader embeds and addon object compile. The rewritten
water_reflections.cpp runs the production history scope and 406B9233 shader
against original DXBC fallback. WARP and NVIDIA pass all three color formats,
native R24 depth, HDR values above the native limit, one-frame effect expiration,
frame gaps, camera cuts, depth disocclusion, resizing, exact private binding
restoration and unchanged native targets. A spatial radiance ramp checks camera
translation and previous-frame projection jitter, including poisoned oversized
pool margins. Jitter sampling allows the D3D11 minimum 8-bit subtexel precision.
The existing native glow/spark/fog equivalence tests, 16-shader linkage audit,
water refraction/shore/fog-attenuation tests also pass.
Logs: ssr-history-build.log, ssr-history-test.log,
ssr-history-fog-regression.log, ssr-history-water-regression.log,
ssr-history-release.log in tmp/witcher3classic-investigation/volumetrics-20261027/.

Limits and next verification: this follows BlitzFX's screen-space approximation,
not complete particle geometry reflection. Transparent objects reuse opaque
depth for reprojection, off-screen information is unavailable, and there is one
frame of source latency. Check paused and moving Igni, then cessation, camera pans,
DLAA/Quality/Performance, Native/Custom water, menu/save loads, and performance.
BlitzFX remains temporarily disabled for the first standalone test; combined
BlitzFX behavior has not been verified live with this build. No performance
numbers or visual acceptance are claimed from the synthetic tests.

Native-SSR Release linked after shutdown: 8,668,672 bytes; SHA256
BA8294D1CEA927A24D130C410415C0762800FF8526D734AC3497AD259E9267FE.
Game-folder symlink deploys this file. Live appearance/performance acceptance
is pending. This supersedes the rejected 44E6FF5E reflection-filter build.


### Native-SSR follow-up: empty depth history (2026-10-27)

The user reported no reflections in BA8294D1. Live diagnostics proved the addon
was capturing HDR and replacing 406B9233, but the depth-validation branch rejected
383,965 of 518,400 input pixels (the geometry region). A separate numeric output
showed current raw depth and projected reciprocal Z were consistent while old
raw depth was exactly zero. The exact B4953357 input capture contains the paused
Igni sparks/fire, so this was not an absent particle source.

Root cause: CopySubresourceRegion used a non-null crop box on the game's
D3D11_BIND_DEPTH_STENCIL resource. D3D11 only permits whole-subresource copies
for depth-stencil sources. The first fixture had the correct R24 typeless format
but ONLY BIND_SHADER_RESOURCE, hiding this distinction. Adding the actual depth-
stencil bind flag reproduces the missing reflections on both WARP and NVIDIA.
The corrected fixture uses a real D24 depth-stencil view and ClearDepthStencilView
for changes (UpdateSubresource is also inappropriate for a depth-stencil target).

The history depth now retains the full native allocation and uses CopyResource.
Only color remains cropped to the actual render extent; shader Load coordinates
for depth already address that top-left extent and do not sample pool padding.
Allocation-size changes are checked independently of render-size changes.
This supersedes the claim above that both history textures are cropped.
The depth rejection remains enabled; there is no permanent validation bypass.

Source/API evidence:
https://learn.microsoft.com/en-us/windows/win32/api/d3d11/nf-d3d11-id3d11devicecontext-copysubresourceregion

Evidence under the same session scratch directory: ssr-missing-inputs.json,
ssr-rejections.exr (red channel 5 = depth rejection), ssr-depth-debug.exr
(R=current raw depth, G=previous raw depth, B=projected reciprocal view Z),
ssr-raw-hdr-input.exr, ssr-depth-copy-before.log, ssr-depth-copy-after.log,
ssr-depth-copy-build.log. Before test fails both devices; after passes all color
formats, history lifecycle, disocclusion, camera/jitter and state checks.

Temporary diagnostic 406B9233 shaders were replaced by the normal production
shader in ssr-live/ before requesting shutdown. No global live-unload was used.
The runtime depth-copy correction requires a Release link/restart. Live visual
acceptance is still pending; capture success alone is not enough.


## 2026-10-27: native SSR needs transparent intersection depth

Status: user rebuilt 018D635A3AE4D09A28EFE14DB16F61B7218EF8CEC7DCBEF90BEAB7DC35BC16AB
(depth-copy repair), but still reported no Igni reflection. The new particle-depth
revision below is compiled and GPU-tested; in-game appearance is NOT yet verified.
Do not describe the prior depth-copy repair as the complete reflection fix.

Evidence from PID 24720, paused river/Igni, BlitzFX disabled:
- Exact input to native trace 47CC9FA1 contains the late sparks in t1. The whole
  depth-copy repair is working; this is no longer an empty-history problem.
- Capture the FIRST 88367C34 occurrence to preserve trace output immediately.
  BDAA334B occurs after 50944A49 fills non-water pixels, so its t1 contains more
  than the raw trace. These textures are full-size pooled allocations: inspect
  only the current 960x540 viewport, not their stale 3840x2160 remainder.
- Native trace hits opaque scenery under/behind the transparent particles.
  A few sparks appear near the far bank instead of beneath their actual location.
  A late HDR color copy alone cannot provide the missing transparent intersections.
- Scratch evidence under tmp/witcher3classic-investigation/volumetrics-20261027:
  ssr-second-inputs.json, ssr-second-color.exr, ssr-direct-inputs.json,
  ssr-direct.exr, ssr-water-mask.exr, native-ssr-trace-full.*, trace-draw.json.

Implementation:
- water/particle_depth.hpp appends one R16_FLOAT scalar MRT at slot 4 to the
  ORIGINAL four audited additive particle draws (A7921C82, 02A34C28, 4EF2AAF8,
  105478E1). MIN blending retains nearest linear view Z. Native blend targets,
  DSV, sample mask and blend constants are preserved/restored. There is no
  geometry replay and no separate particle ray tracer or full-screen overlay.
- The PS writes clip W/view Z only for emitted luminance above 0.001 in native
  scene units; empty billboard texels write the 65504 sentinel. Critically,
  D3D11 SV_Position.w here is view Z, NOT reciprocal view Z. Native color and
  fog transmittance are unchanged. Existing fire glow bit-select repair remains.
- 406B9233 reads last frame's particle depth at private t114. Four depth taps
  cover its color prefilter footprint. The previous/current camera transforms
  convert it to current device depth, with the existing cut/disocclusion gates.
  Projection Z and the reversed native depth texture are different conventions:
  deviceZ = (clip.z/clip.w - frame[22].y) / frame[22].x.
- Its additional R32_FLOAT output at MRT1 is quarter resolution and contains
  ONLY emissive depth, with a far sentinel elsewhere. This avoids changing the
  native opaque downsample footprint in frames/pixels with no emission.
- 47CC9FA1 uses private t114 ONLY for its four ray-intersection SampleLevel
  reads, taking nearer(native opaque, emissive). Its t2.Load ray-origin depth
  MUST stay native, or the water ray begins on the particle instead of water.
  The 719-line decompiled original was checked against original DXBC on GPU;
  both MRT outputs match exactly when intersection depth is identical.
- Empty frames use the original trace directly: no extra per-step depth fetch.
  Captured depth is valid for exactly the corresponding previous HDR frame;
  gaps, mode changes, resize and missing particles cannot retain stale surfaces.
- Native SSR history/clamping, mip filtering, Fresnel mask and composition remain
  in use. No second tracing dispatch or new temporal accumulation is introduced.
- BlitzFX active: its replacement pre-SSR shader does not request this history;
  the standalone particle capture/trace remains inactive. Verify separately if
  BlitzFX is re-enabled. Accepted refraction, shoreline and sun/fog fixes remain.

Validation (WARP and NVIDIA):
- test-water-reflection-trace.cmd / trace-equivalence.log: original 47CC9FA1 vs
  modified trace max error 0 on both targets, point/linear sampling, both native
  fallback branches; adding nearer intersection depths changes hits, preserving
  the native water mask.
- test-water-reflections.cmd / particle-depth-history.log: actual R16 MRT path,
  4 m -> .75 conventional / .25 reversed depth; transparent holes; no stale
  particle frame; native target/blend/private SRV restoration; prior HDR format,
  cropped-pool, jitter, camera cut, disocclusion and resize regressions.
- test-composite.cmd / particle-depth-color.log: actual Igni glow PS with extra
  MRT keeps original RGB; 1992 emitting pixels store 8 m and 2104 transparent
  pixels store the sentinel. Original spark/glow and custom fog checks pass.
- build-object.cmd compiles Release source/embeds without linking the loaded DLL.
  Full Release link and user visual acceptance are still pending at this entry.

Research/context: this is a deliberate extension beyond BlitzFX's color-history
approach. Opaque-only SSR cannot reliably locate transparent effects; see
https://docs.godotengine.org/en/latest/tutorials/3d/environment_and_post_processing.html
and Unity HDRP's documented transparent-depth limitation:
https://docs.unity.cn/Packages/com.unity.render-pipelines.high-definition%4012.1/manual/Override-Screen-Space-Reflection.html
The method still has screen-space/off-screen limits, one-frame history latency,
and a single nearest transparent layer. Camera reprojection uses the opaque
correspondence shared with the HDR input; fast camera/effect motion needs visual
validation rather than a claim of exact multi-layer transparency.

Next verification: rebuild only when Classic is closed; Custom fog + Custom
water, paused Igni first, then animated casting and camera movement, DLAA and
DLSS Quality. Confirm sparks/color unchanged, correctly located reflection,
absence of old moving noise, clean disappearance after fire ends, Native water
unchanged, and acceptable frame cost. Use exact before-draw captures, not stale
pooled resources. Do not globally unload DevKit live replacements.


## Lighting extension and reflection confirmation (2026-10-27)

The user confirmed the repaired native-SSR Igni reflections work after rebuilding.
The lighting extension is documented in [LIGHTING.md](LIGHTING.md), including
primary research, captured engine contracts, implementation and limitations.
Graphics now includes native-pass PBR, ambient-only AO influence, PCSS soft
shadows, contact shadows, HairWorks shadow quality and player-fill controls.
All new modes default Native/Off. Release shader embeds and addon object compile;
final lighting and forward object-motion tests pass on WARP and NVIDIA.
Full Release linking and in-game lighting acceptance are pending at this entry.
Existing fog, water, refraction and reflection fixes are retained.

Deployment follow-up: the addon was linked at 23:49:15 and Classic restarted
at 23:49:22. No implementation source is newer than that DLL. DevKit confirms
embedded addon replacements for FB29B4E6 (directional/IBL), 05FE9FA8 (shadow
mask) and 4E4E4B53 (HairWorks), with no disk override for those shaders. Thus
Release linking is complete; visual acceptance of the new modes remains pending.


## Standalone water seam repair (2026-10-28)

See [EFFECT_AUDIT.md](EFFECT_AUDIT.md) for the confirmed metadata-row repair,
live acceptance, regression coverage and remaining BlitzFX comparison work.
The corrected 28D7BDFE shader restores integer row 1 in the terrain atlas
metadata lookup, matching the earlier BlitzFX 2825099C compatibility fix.
All sunlight/reflection/refraction/fog contributions are restored. WARP and
NVIDIA water tests pass; the user confirmed the live scene is correct.
Full Release DLL linking is still pending game shutdown at this entry.


## Lighting/shadow comparison revision (2026-10-28)

See LIGHTING.md, Direct BlitzFX comparison revision, for the source comparison,
material-aware filtered contact shadows, native material storage in standalone,
local shadow-atlas bit-decode fixes and specular anti-aliasing. Release embeds
and object compile; GPU tests pass on WARP/NVIDIA. Full DLL linking and live
acceptance are pending game shutdown at this entry. Keep the accepted water fix.


Deployment follow-up: the lighting/shadow comparison revision was linked in
Release after Classic exited. The existing game-folder symlink resolves to
the rebuilt build/Release/renodx-thewitcher3classic.addon64 (9,204,224 bytes).
Build log and SHA-256: effect-audit-20261028/build-release-shadow.log and
release-shadow-build.json under the investigation scratch directory.
All final WARP/NVIDIA checks pass; in-game acceptance remains pending.


Graphics default follow-up: the user accepted the lighting/shadow improvements
and requested the screenshot configuration as defaults. See LIGHTING.md,
Accepted Graphics defaults, for exact values and the clean removal of the
HairWorks Shadow Quality setting. Existing saved profiles are not overwritten.


## Interior fog exclusion (2026-10-28)

Custom atmospheric fog now uses the game's authored interior entry/exit texture
at native PS t24 (R16G16_FLOAT, half-resolution pooled allocation). Its channels
are radial distances normalized by lighting b13[34].z. This is independent of
the AO texture t2, previously mislabeled as an indoor mask in these notes.
The current building capture has a 2560x1440 render viewport, a 1920x1080
pooled interior texture and distance scale 120 m. Native water's t24 handling
and the local BlitzFX source independently establish the distance/order contract.

Fog density is zero inside these volumes. A two-metre cubic fade lies on the
outdoor side of each boundary, preserving darkness inside without abruptly
turning the outdoor medium on. The fade is integrated over each logarithmic
radial cell to avoid whole-slice pops when crossing a doorway. Reversed entry/
exit order covers the camera starting indoors and subsequent re-entry; equal
values denote open air. Active half-resolution pixel coordinates avoid stale
pool contents in DLSS modes. Missing/unsupported interior data retains the
previous fog behavior. Native fog mode is unchanged.

The shared integrated volume supplies opaque surfaces, forward materials,
particles and water. Fog seen through a doorway resumes outside the interior;
outdoor fog in front of an interior still contributes along that outdoor path.
This uses authored interior volumes, not inferred wall/roof geometry, so spaces
without a native dimmer volume are not automatically classified as interiors.
Native distance-based dimmer weakening is deliberately not applied to density.

Validation: Release shader embeds and addon object compile. volumetrics.cpp
passes on WARP and NVIDIA: exact interior vacuum, entering/exiting intervals,
moving doorway optical lengths, no-volume sentinels, missing/invalid data,
poisoned pooled borders, and existing lighting/density/state regressions.
Native fog/particle composite tests also pass; native fallback has zero error.
The D3D debug layer was unavailable. Evidence is in
tmp/witcher3classic-investigation/interior-fog-20261028.

Release DLL linking completed after game shutdown. Live visual acceptance remains pending.
Build target: thewitcher3classic, preset clang-x64-release; generated shader
embed: build/thewitcher3classic.include/embed/0xF3C30001.h. After relaunch, check
the current building, walk slowly through its doorway, look outside from inside,
then check a cave mouth and a fully enclosed cave. Repeat in DLAA and DLSS
Quality, including transparent particles/water, and compare Native fog mode.
No temporary live overrides were installed for this revision.


## Fog quality controls (2026-10-28)

Graphics -> Fog Quality provides two independent integer sliders, enabled in
Custom Atmospheric Fog mode and saved per preset. Both default to 2/4.

| Level | Volume Resolution at 16:9 | Lighting Shadow Quality |
|---|---|---|
| 1 | 160x90x96 (previous resolution) | 4 PCF taps (previous sampling) |
| 2 | 240x135x128 | 9 PCF taps |
| 3 | 320x180x192 | 16 PCF taps |
| 4 | 384x216x256 | 25 PCF taps |

Volume rows follow camera aspect, independently of DLSS render scale. Higher
resolution improves both screen detail and radial integration, at additional
GPU and video-memory cost. The two FP16 volume textures use approximately
21/64/169/325 MiB at these 16:9 settings. Lighting quality samples the same
shadow footprint more densely, increasing GPU work without extra volume memory.
It controls sunlight/moonlight visibility in the fog, not surface-lighting
quality. Sampling positions are deterministic; no temporal jitter is added.
Existing fog density, light strength, interior exclusion and 1000 m range remain.

Changes apply on the next atmospheric pass; volumes reallocate only when their
dimensions change. Graphics preset buttons reset quality to the new defaults;
Vanilla Graphics disables Custom fog rather than setting these sliders to zero.
No HDR injection ABI or private forward-sampling layout changed.

Validation: Release shader/object build and WARP/NVIDIA volumetrics tests pass.
Tests cover all actual quality allocations, increasing/decreasing resolution,
parameter/aspect bounds, homogeneous extinction and lighting energy, analytic
PCF edge weights for all four sample counts, and the existing interior/pooled
resource/state regressions. The D3D debug layer was unavailable. Live visual
quality and frame cost remain to be checked in the user's noisy scene.
Evidence: tmp/witcher3classic-investigation/fog-quality-20261028.

Build thewitcher3classic with clang-x64-release after closing the game. Inspect
embed/0xF3C30001.h, then restart and compare 1/1, 2/2 and 4/4 in a fixed scene.
Move the camera across shafts/foliage and an interior boundary; check DLAA and
DLSS, preset persistence, immediate quality changes and Native fog bypass.


## Toussaint fog height correction (2026-10-28)

The captured Toussaint scene used the registered C8C78997 atmospheric pass,
valid shadows, and an all-outdoor t24 interior sentinel. Custom fog was active.
Its weather height offset was 2185.51855 m, camera Z 3.00987 m, base density
0.000253701, and mean vertical coefficient 0.002238057. The custom exponential
height profile reduced local density roughly 23 times more than the native
reciprocal profile 1/(1 + max(height,0)*coefficient).

Use that reciprocal weather profile in volume extinction and the analytic
incoming-light integral shared with water. Beer-Lambert path integration remains
exponential. The existing mean of directional weather coefficients, 1000 m fog
range, quality controls and native interior exclusion remain in use. This
corrects the previously documented exponential height model, and is not an exact
reproduction of the native directional 16-step atmospheric integrator.

Validation: Release shader embeds/addon object compile; volumetrics and water
tests pass on WARP and NVIDIA. The captured weather regression checks absolute
scattering/transmittance; sunlight is checked against numerical quadrature at
high altitude, near-horizontal directions, ground crossings, and tiny falloff.
The D3D debug layer was unavailable. Live visual acceptance remains pending.
Evidence: tmp/witcher3classic-investigation/toussaint-fog-20261028.
Build target thewitcher3classic with clang-x64-release after game shutdown;
inspect embeds 0xF3C30001.h and 0x28D7BDFE.h. After restart compare this Toussaint
view, another region, and a doorway with Custom Atmospheric Fog on/off.

Release DLL linking completed after game shutdown; the game-folder symlink resolves to the updated build. Visual acceptance after relaunch remains pending.


## Toussaint distant haze follow-up (2026-10-28)

The height-profile correction alone did not resolve the reported appearance.
Live diagnostics confirmed ClassicFogReady and nonzero volumetric scattering.
Matched native/custom atmospheric-pass views show clear nearby weather in both,
but significantly reduced mountain haze in Custom mode. The replacement stopped
accumulating at 1000 m while this weather specifies 16707.9 m. A captured depth
sample places 2.1% of opaque pixels beyond the old cutoff (distant mountains).
Evidence images: toussaint-fog-20261028/custom-scene.png and native-scene.png,
using identical preview exposure; these are pre-final-grading scene buffers.

Both scatter and integration now use max(local grid range, native weather range)
and publish the same range to opaque/forward sampling. This supersedes the fixed
1000 m camera-ray limit documented above. Local density is not boosted. Grid
allocation and dispatch counts are unchanged; covering a longer distance spreads
the logarithmic slices more widely, so Volume Resolution still controls detail.
Incoming sunlight retains its previous finite local-medium attenuation path,
including water; weather lighting already represents the global atmosphere.

Validation: the old shader fails the new distant-transmittance regression; the
updated shaders pass it on WARP and NVIDIA, together with reference radiance,
100 m transmittance, published sampling range, and interior intervals beyond
1000 m. Existing quality, interior and water tests also pass. The Release shader
embeds and addon object compile. The D3D debug layer was unavailable.
Diagnostic overrides were replaced with production shader code, their scratch
file removed, and the original live path restored before game shutdown.
After relaunch, verify mountain haze in the same Toussaint view, nearby clarity,
doorway darkness, and another region. This change does not reproduce the native
artistic desaturation/opacity curve or directional weather blending exactly.


## Contact shadows: BlitzFX sampling restoration (2026-10-28)

The original 24-tap implementation spread evenly spaced samples over the entire
world-space reach. Close-up rays therefore sampled widely separated pixels and
created repeated silhouettes. Two subsequent repairs were rejected in-game:
continuous dense tracing filled the heuristic depth slab into broad shadows;
removing that slab and bias for exact cell/surface intersections caused faceted
self-shadowing and flicker. Their synthetic width tests were insufficient and
must not be cited as visual acceptance or proof of a physically correct result.

The current trace restores the original material rules, depth bias, thickness
and 400x hit ramps. Sampling follows BlitzFX 1.1.0 ContactShadowsCS: 16 taps,
fixed normalized screen spacing (6 * renderHeight / (1920 * renderWidth)),
and a static per-pixel phase with the tree-specific offset. Reach limits the
world distance without redistributing the taps. Default remains 0.3 m; saved
values are retained. Native near-plane protection, screen-edge fade, physical
reach fade and the existing depth/normal bilateral filter remain intact.

The exact user-supplied BlitzFX archive was extracted and disassembled to verify
these rules. The matching local source is commit
659e239cfcba9cf0362621486ecdb241b0eee168. Differences are deliberate: our static
phase uses interleaved gradient noise instead of the external blue-noise map;
we retain the existing spatial filter and do not add normal-mapped self-shadowing.
The first sampling-only build was also rejected for noise/flicker; restoring
BlitzFX's trace without its temporal stabilization was insufficient. The current
revision adds contact-mask history as described below. It does not claim parity
with BlitzFX's complete combined-shadow pipeline. Trace work is 16 samples;
actual total frame cost remains unmeasured.

Validation: Release embed and addon object compile. Production lighting tests
pass on WARP and NVIDIA, including fixed sampling at 0.08/0.16/0.3/0.6 m across
axes/directions/subpixel phases and a shallow sloped plane that must not shadow
itself. The original stretched trace and rejected DDA fail the new suite.
The former thin-surface footprint fixture is removed because its zero-thickness
assumption does not validate the chosen screen-space heuristic. Existing native
lighting, PCSS, material, hair, binding-range, resize and pooled-bound tests pass.
An additional GPU comparison executes the original BlitzFX package bytecode with
matched static offsets: character-blocker masks match exactly on both adapters
for both axes and light directions, away from our added bounds/fades. This is
limited shader evidence, not a claim of whole-scene or temporal equivalence.

Evidence: tmp/witcher3classic-investigation/contact-blitz-20261028, including
reference.cpp/reference.cmd and the extracted original shaders. Logs:
tmp/contact-blitz-tests.log, contact-blitz-reference.log,
contact-blitz-original-negative.log and contact-blitz-dda-negative.log.
The in-game screenshot confirms the rejected version's faceted forehead/neck.
DevKit accepted diagnostic shadow overrides, but they did not change the active
addon output; they were restored and the temporary file/path cleaned up.

Build target: thewitcher3classic, preset clang-x64-release; inspect generated
embed/0xF3C40021.h. After relaunch, compare contact shadows off/on in this same
close-up, inspect idle animation for flicker, then change reach and camera angle.
Also check foliage and DLSS/DLAA. Live acceptance remains pending.

Deployment: Release DLL linked after shutdown; game-folder symlink hash verified.
Build log: tmp/contact-blitz-release.log. Scene acceptance is still pending.


### Contact-shadow temporal stabilization

Contact shadows now filter current observations spatially before temporal
reprojection and history clipping, matching BlitzFX's ordering. The same 3x3
filter reuses an existing GPU texture; the final shadow draw does not blur again.
The 16-tap trace and 0.3 m default remain unchanged. Motion-aware history rejects
invalid or uncovered animated surfaces rather than dragging old shadows.

Release embeds/object and WARP/NVIDIA regression tests pass. The Release DLL was verified after relaunch, and the user accepted the current
appearance on 2026-10-28. Broader animation/performance validation remains open.
Large shadow size alone is not evidence of an error. See [LIGHTING.md](LIGHTING.md)
for the algorithm, rejected scene experiments, validation and remaining limits.


### Velen weather opacity preservation (2026-10-28)

Live Velen capture showed the custom volume discarded native C8C78997's
weather opacity exponent frame[42].w and distance fade frame[48].yz. The
captured exponent is 0.50754434, start 7.15734 m and fade slope 0.005299725/m.
The native shader applies these to 1-T, not to density. At one captured
368 m terrain point, native opacity is about 0.365 versus 0.136 from the
unshaped custom integral. The t24 outdoor entry/exit values are equal, so
interior exclusion is not responsible for that loss.

The integration shader now accumulates weather-density optical depth tau and
evaluates authored opacity A=(1-exp(-tau))^exponent * distance_fade at each
radial boundary. It integrates source radiance using the increase in A and
stores T=1-A. This preserves L/T consistency and the existing additive,
shadowed sun/moon lighting. It does not restore the rejected shadow-budget
experiment. Empty interior segments keep their previous L/T; advancing the
distance fade alone cannot create medium there. Zero density is exact vacuum.
The near-distance/user start is subtracted before the authored fade, matching
native weather distance when the user start is zero. Native color overrides,
desaturation and the small directional difference in height falloff remain
outside this change; it does not claim complete native-fog image equivalence.

The standard transport framework remains the existing Beer-Lambert density
integral and shadowed source injection. The nonlinear opacity/fade is an
authored Classic control, proven by original shader bytecode, rather than a
claim of physically measured atmospheric coefficients. The effective segment
opacity gain weights local scattering, so no final-screen color adjustment or
inverse tonemap is involved. There are no new passes, textures, allocations,
shadow taps, CPU readbacks or settings. Integration adds a per-boundary power.

Validation: Release shaders compile. WARP/NVIDIA volume fixtures pass captured
Velen opacity/fade at every radial boundary, analytic radiance consistency,
lit/shadowed sources with identical extinction, exact vacuum, interior gaps,
existing Toussaint distance/height cases and all quality levels. The original
DXBC replay on the captured Velen camera/weather uses white fog on black to
isolate opacity and compares 6,366 channel values over 8-1000 m. Corrected max
error is about 0.0114, mean about 0.0015; the previous integration fails with
max 0.2484 and mean 0.0943. Differences include native 16-step end-point opacity
products versus analytic Beer-Lambert segments and volume filtering. Native
fallback, AO composite, transparent radial lookup and additive particles pass.
The optional D3D debug layer was unavailable. These tests do not establish
complete in-game appearance or total GPU cost.

Evidence stays under tmp/witcher3classic-investigation/velen-fog-20261028:
captured b3/b12/b13, preserved depth/interior inputs, original native-fog.cso,
inspect.py, test-weather.cmd and negative-control.py. Build thewitcher3classic
with clang-x64-release; inspect embed/0xF3C30002.h. After relaunch, compare
Native/Custom fog in this Velen view with Fog Density/Height Falloff both 1,
then check nearby terrain, distant hills, interiors and sun/cloud shafts.
Live visual acceptance remains pending.


Second scene: a later live capture has exponent 1.20301342, start 1 m and
fade slope 0.015136439/m. Ignoring these reduces fog in the first capture but
increases it in this one. At a 156 m point, native opacity is about 0.097 versus
0.144 unshaped; at roughly 9-11 m, the missing fade makes the difference much
larger. Original-DXBC replay passes on WARP/NVIDIA: max error under 0.0158 and
mean under 0.0025 across 6,366 channel values, including an identity-exponent
control. The previous integration fails with max 0.0811 and mean 0.0369.
The analytic volume fixture includes both weather captures and exact interior
vacuum checks. Evidence: tmp/witcher3classic-investigation/fog-scene2-20261028.
These comparisons isolate fog opacity. Custom sunlight scattering remains
additive and can still make fog brighter than native when facing the light;
this patch does not claim matching native in-scattered color or sun glare.

Deployment: corrected Release addon linked after shutdown; installed symlink
hash verified. The 2026.10.28 package was rebuilt and its addon bytes checked.
Both captured scenes still need visual acceptance after restarting.

## Storm material routing and HDR preservation (2026-10-29)

The Skellige/bog storm corruption originated in native weather material pass
0x5D7114F1 (VS 0xA723997B), which writes two RGBA8 UNORM scratch targets and
copies them to the normal/specular G-buffers. The broad Classic scene-color
upgrade also matched this scratch pool. Mixing upgraded floating-point scratch
with native UNORM material copies corrupted the later lighting inputs. FG,
chromatic aberration, motion-vector settings and reconstruction were excluded
by live comparisons. Realistic Weather activates the native storm path; the
repair changes addon resource routing, not weather assets or merged scripts.

weather_materials.hpp temporarily saves and disables the scratch resource/view
HDR routes for this specific shader. Its two observed material copies execute
through the command-list API with native resources. After both copies, exact
prior routing is restored immediately, so subsequent uses of the same pool can
carry HDR color. A later draw/dispatch, present or device teardown also clears
an incomplete sequence. The three main material targets remain native UNORM.
There are no additional GPU passes, textures or copies. Routing bookkeeping is
limited to the matching weather draw/copies; inactive boundaries check a null
device pointer.

Do not permanently exclude the two-target scratch pool: an initial broad
exclusion removed the corruption but clamped HDR because the engine reuses
those allocations for color. The final scoped repair supersedes that attempt.
Microsoft's D3D11 CopyResource specification requires identical or compatible
format families; RGBA8 UNORM and RGBA16F are not a converting copy pair:
https://learn.microsoft.com/en-us/windows/win32/api/d3d11/nf-d3d11-id3d11devicecontext-copyresource

Acceptance: the user confirmed both no blue/white storm corruption and normal
HDR highlight range after restart. The log confirms both native material
copies completed and HDR pool routing was restored. The preserved pre-fog
RGBA16F scene has RGB maxima 35.5/32.875/29.828125, 909801 pixels above 1,
and no NaN/Inf pixels. DevKit's before-draw capture can precede the corrective
bind; that capture alone does not establish the final weather RTV format.

Fog strength was checked again using this clean storm camera/weather against
original C8C78997 bytecode, isolating opacity with white fog over black. On
NVIDIA, exponent 1.18319178 gives maximum absolute opacity error 0.0212807
and mean 0.00427048 across 6330 channel samples over 8-1000 m. WARP gives
0.0212082 maximum and 0.00426984 mean; an identity-exponent control also passes.
The user accepted this strength tolerance. This is opacity coverage, not exact
fog-color equivalence: additive sunlight scattering, native color overrides,
desaturation and sky-profile differences retain the previously documented
limitations. No additional fog-art changes were made in the storm repair.

Release volume, native fallback, signed HDR/AO composition, interior, transparent
radial sampling and particle checks pass on WARP and NVIDIA. Native fallback
matches original bytecode exactly in the fixture. The optional D3D debug layer
was unavailable. Evidence: tmp/witcher3classic-investigation/skellige-20261029
and storm-clean-20261029. The Release package is
build/Release/packages/renodx-witcher3-classic-2026.10.29.zip; it contains the
corrected addon, production NVIDIA runtimes and licenses, without a loader or
installation instructions. Its addon hash matches the deployed build.

## Volumetric local lights (2026-10-29)

Custom atmospheric fog now scatters scene point and spot lights in the existing
HDR volume, alongside ambient weather and sun/moon illumination. Graphics has
a Volumetric Lighting and Fog section, with separate Sun and Moon Scattering
(existing GfxFogLight key) and Local Light Scattering (GfxFogLocalLight, default
1, range 0-4). Zero disables only that source contribution. The existing phase
directionality applies to both. Settings use the usual persistent mod settings.

The implementation follows Wronski's unified compute volume: accumulate the
light sources at each participating-medium sample, then integrate once for all
opaque/forward consumers. Reuse tiled light culling and existing shadow maps
rather than ray marching every light over the full screen. Primary reference:
https://bartwronski.com/wp-content/uploads/2014/08/bwronski_volumetric_fog_siggraph2014.pdf
(lighting/storage, slide 37; tiled/clustered optimization, slide 63).
The game-specific attenuation/shadow data contract is proven by the original
DA094A1D, 3946E96C, 0AB3A292 and forward 12B76681 bytecode/decompilation.

At C8C78997, reuse native PS t20 raw forward-light indices, b13[57].x integer
live count (bounded to 256), and nine-float4 records starting at b13[58]. The
native list has 256 uint entries per 16x16 tile, with sentinel 256 and column
stride frame[24].x. DA094A1D tests the tile side planes, camera plane and furthest
opaque depth; it does not use the opaque minimum depth, so the list retains
lights affecting the visible air before a surface. Address it with the active
viewport under DLSS, not the allocation extent. Reject out-of-range list reads,
stale indices beyond the live count and camera/player fill tag 0x80001800.
The scene captured for this change contains 24 active local lights.

Preserve native finite-radius attenuation, spot cones, linear HDR radiance,
shadow strength, packed point/spot atlas faces and optional cube-array ESM.
Local shadows use ordinary sampling of the engine's R16 exponential-depth data
(PS t9/t10, sampler s10), not the sun's depth-comparison sampler. The shared
packed-atlas decoder keeps integer fields intact. Missing required shadow views
suppress that shadowed contribution instead of illuminating through blockers.
Lights authored without shadows retain the engine's unshadowed behavior; this
does not generate new geometry shadow maps for those lights.

Apply the existing normalized HG phase and analytic medium transmittance along
the finite lamp-to-sample path. Keep light units artist-authored, rather than
claiming calibrated lumens. Local lights change RGB source only: weather opacity,
extinction, density, interior exclusion, start fade and integration are unchanged.
No medium is invented indoors where the existing interior mask excludes fog.
Existing water/transparent consumers receive the same integrated lighting;
additive emission still uses transmittance only. No new temporal history is
introduced, avoiding a separate light-history ghosting path for FG.

There are no added GPU passes, allocations, copies, CPU readbacks, per-light
dispatches or geometry replays. The scatter pass binds three existing SRVs and
one sampler inside its isolated context state; the native bindings are restored.
Native fog and a zero Local Light Scattering setting bypass local lighting.
Runtime validates the native full light buffer and raw-list view before enabling
the feature; unavailable contracts retain the existing directional/ambient fog.

Validation: Release shader/object compilation and WARP/NVIDIA numerical tests
pass. New tests cover HDR/scalar transport, unchanged transmittance, strength,
live count/sentinel guards, fill exclusion, exact vacuum, spot cones, all six
point-atlas faces, spot/cube ESM and missing-shadow rejection. Existing interior,
volume quality, native-bytecode fog fallback, signed HDR/AO, particle and weather
opacity tests pass. The clean storm opacity bound is unchanged (max 0.0212807).
The optional D3D debug layer was unavailable. The user confirmed the live
local-light 0/1 comparison looks correct after restart, including HDR/shadows.

GPU timestamp microbenchmark, complete production scatter+integration with
synthetic shadows and all lights overlapping every tile: Low 0/4/24 lights
0.0296/0.0417/0.1075 ms; Ultra 0.3164/0.4630/1.1807 ms. These are bounded
synthetic measurements on this NVIDIA device, not an in-game FPS guarantee;
shadow complexity, weather and actual tile occupancy change cost. Evidence:
tmp/witcher3classic-investigation/local-volumetrics-20261029. Build the established
Release target and repackage with package-release.ps1. After restart, compare
Local Light Scattering 0/1 near a lantern or torch in fog, move around a blocker,
then check spot cone boundaries, indoor exclusion and FG/HDR highlights.

Deployment: Release addon linked and package-release.ps1 rebuilt/verified
renodx-witcher3-classic-2026.10.29.zip (15 addon/runtime/license entries).
Addon SHA256: 8b8f1fb6bcf9762f4edfca10134e6aedf3f406d41966c7694b8f235af8253ea3.
The live log confirms the new volumetric path loaded and the storm material
copy routing still restores HDR. New CS input slots 4-6 restoration also passes
on WARP/NVIDIA. The user accepted the live lamp/fog and shadow/HDR result.

## Native weather fog baseline and separate sky haze (2026-10-29)

The fog-parity-20261029 capture exposed a color mismatch hidden by the earlier
white-fog opacity tests. Native frame[188..191] applies a near-black fog-color
override here; constant frame[40] ambient in the custom volume ignored it.
At sampled 25.7-41.1 m scene points, that old ambient term was 5.1-16.4 times
the native fog-source luminance. This is a source-term comparison, not a claim
that the entire final frame was that much brighter.

The shared fog sampler now retains native directional weather colors, both
local color/opacity overrides and their blend, and background desaturation.
The latter is recovered from the volume opacity and native opacity/fade curves;
opaque fog retains native AO influence and forward materials retain their
native desaturation tint. The weather ambient reference is removed from the
integral before applying native color, preserving the extra shadowed direct
sun/moon/local-light contribution. Native directional height falloff also
replaces the previous average of its two coefficients. This supersedes the
older notes that local fog color/desaturation remain outside custom fog.

Sky retains its distinct native frame[44] analytic profile and color controls,
instead of using the opaque frame[43] volume as a replacement. A new persistent
GfxFogSkyDensity / Sky Haze Density slider scales only that native sky density:
0 removes it, 1 is native, up to 4 increases it. It is independent of Fog Density
and the existing sun/moon/local-light scattering controls. Direct scattering
can still appear against the sky when sky haze is zero; it belongs to the
scene medium and has its own controls. Native atmospheric mode remains native.

The GPU-published fog parameter buffer grows from 4 to 21 float4s, carrying
weather colors/curves, overrides, sky density and a camera-relative ray basis.
No image resources, render passes or CPU readbacks are added. Old four-element
live-shader buffers keep their prior behavior. The same L/T sampler supplies
water, transparents and additive transmittance. The direct-light residual is
limited by the existing half-float volume precision; do not claim exact final
native image identity or calibrated physical weather units.

Validation: Release build/package and WARP/NVIDIA volume/local-light, native
fallback, HDR/AO, particle, weather RGB and sky checks pass. Original C8C78997
bytecode comparison for this weather: fog-source RGB max error 0.01012; signed
HDR scene mean error 0.01464 over 6366 channels (sun/local scattering isolated
off). Earlier Velen, second-scene and clean-storm captures also pass RGB/HDR
checks. Sky matches original BC930752 with independently scaled native density
at 0/.5/1/2, for actual and unsaturated density cases, max error below 0.00025.
The optional D3D debug layer was unavailable. Volume integration/filtering still
differs from the native 16-step end-point product; these are bounded tests.

Synthetic 2560x1440 RGBA32F GPU composite benchmark: corrected 0.06660 ms,
previous 0.06535 ms, native 0.06211 ms in the final run. The previous custom
shader is a negative control (max native RGB error 0.89803, corrected 0.15892
over the full signed-HDR chart). This is not gameplay FPS or a total-mod timing.
Evidence and commands: tmp/witcher3classic-investigation/fog-parity-20261029.
Release addon/package rebuilt; the user confirmed the same-scene fog strength
and independent sky-haze control both look correct after restart. Compare Native/Custom with both density sliders at 1, then vary
Sky Haze Density while retaining scene density and direct-light settings.

Additional validation: a two-override blend with different colors and alpha
strengths passes original-bytecode RGB/HDR comparisons on WARP and NVIDIA.
Deployed/package addon SHA256:
05ec2184db1420e7db674d8d38d556e4dce122a8ea419e66b3f8ce1a5ee3ff39.

## Full-cell sunlight shadow filtering (2026-10-29)

Visible moving shaft steps at Ultra exposed an undersampled direction: the
previous planar PCF kernel covered screen width but not radial cell depth.
Captured weather range is 16707.9 m; even 256 logarithmic slices make cells
about 4.81 m deep at 100 m and 12.02 m at 250 m. Inner cascade boundaries also
switched without the native visibility blend.

Sun/moon shadow filtering now projects the complete cell into light space,
including radial extent and receiver depth. Mirrored low-discrepancy samples
span that volume before scattering/integration; depth samples are stratified
across the physical cell interval. Lighting Shadow Quality 1-4 uses 8/16/24/32
comparisons. Native cascade transition widths blend adjacent visibility, with
the existing final-cascade fade to lit. Fully lit/shadowed energy is retained.
The grid, weather density/color/sky controls, local lights and HDR composition
are unchanged. There are no new passes, allocations, temporal history or
frame-varying sample noise. This supersedes the earlier planar 4/9/16/25 taps.

Primary rationale: Wronski SIGGRAPH 2014, source shadow prefiltering and spatial
jitter/filtering (slides 29-32 and 58):
https://bartwronski.com/wp-content/uploads/2014/08/bwronski_volumetric_fog_siggraph2014.pdf
The exact footprint sampler is this mod's implementation, validated against a
closed-form moving shadow-edge integral; it is not a claim to use that talk's
prefiltered ESM representation. High-frequency shadows still have finite sample
limits; no geometry or new shadow maps are generated.

WARP/NVIDIA pass: moving radial edge reference error 0.0004972 and largest
quarter-metre camera step 0.0005667, normalized by incident source. The previous
shader fails at 0.0103149/0.0056673 (about 21x error/10x step reduction). Native
cascade blend error is 0.0006377 versus the previous hard-switch 0.8211 in the
deliberately disagreeing-layer test. Weather, HDR/sky, interior, local-light,
binding and quality-allocation checks pass. Optional debug layer unavailable.

Idle-device synthetic Ultra scatter+integration GPU times, old/new with 0/4/24
overlapping lights: 0.3419/0.4023, 0.4723/0.5714, 1.1781/1.1610 ms. Last case is
within timing variation. These are synthetic shadow-map timings, not gameplay
FPS. Evidence: tmp/witcher3classic-investigation/fog-quality-20261029. Release
addon and package rebuilt; live moving-shaft acceptance pending.


## Per-pixel volumetric lighting (2026-10-29)

Live feedback after the full-cell shadow filter was "some improvement, steps
remain". Direct-only FP16 storage and Smooth cubic reconstruction then improved
edges but did not remove the local-light bands. FG was off and the user also
reproduced this with DLAA. Those changes do not establish a complete live fix.

Fog Rendering (GfxFogRenderer) now defaults to Per-pixel. It evaluates lighting
along each fragment's camera ray instead of reconstructing an integrated 3D
lighting grid. Volume remains available as the faster alternative. Sampling
Quality retains GfxFogResolutionQuality and selects 1..4 ray-sampling levels
in Per-pixel mode; Volume retains the existing grid sizes. Lighting Shadow
Quality and Lighting Reconstruction apply only to Volume and are disabled in
Per-pixel mode. Settings use the existing persistence/preset infrastructure.

The transport follows shadow-map ray integration, as described by Toth and
Umenhoffer, Eurographics 2009, Real-time Volumetric Lighting in Participating
Media: https://cg.iit.bme.hu/~szirmay/lightshaft.pdf . Our spatial stratification
is an adaptation, not their periodic block reconstruction algorithm. Near sun
shadow integration uses 8*quality samples to 96 m plus eight logarithmic far
samples. Native tiled light candidates are intersected analytically with the
view ray and clipped to the fragment depth. A light receives 2*(quality+1)
unshadowed or 4*(quality+1) shadowed samples only within that interval. Static
per-pixel phases decorrelate sample planes; no new animated noise or persistent
fog history is introduced. Existing game reconstruction still processes fog.

The final opacity follows the native 16 end-point density products and weather
exponent/fade. Native directional colors, both local color/alpha overrides,
desaturation, AO, independent Sky Haze Density, and interval-based interior
exclusion remain. Scattering uses FP32 shader arithmetic and the existing HDR
output path. Source evaluation shares the Volume path's native CSM/cascade,
terrain, cloud, local packed atlas and cube ESM decoders. Pixel CSM visibility
uses four depth comparisons and bilinear visibility filtering; cloud wrapping
is reconstructed explicitly to avoid borrowing native material sampler slots.
The common sampler also supplies forward materials, water and particles at
actual fragment depth; additive emission still receives transmittance only.

Two native constant buffers are snapshotted GPU-to-GPU into structured SRVs;
there is no CPU readback or per-fragment allocation. Native texture SRVs are
retained for the frame, not copied. Private pixel SRV slots 99..107 are saved
and restored on each participating draw. Per-pixel mode dispatches a 1x1x1
parameter-only volume and skips the full lighting grid. Unsupported/short
snapshot inputs retain the complete Volume fallback instead of publishing an
unusable per-pixel flag. Volume direct light remains separate from weather
ambient so weak lamps are not lost when FP16 stores a bright ambient term.

Validation: exact Release FXC shader embeds and Clang Release addon object
compile. Volume regressions pass on WARP/NVIDIA. Pixel point-light transport
matches a 4096-step scalar reference: max/mean red error 0.00007131/0.00000249;
with an ESM shadow transition, 0.0016683/0.00003053 on NVIDIA. Front-surface
clipping, native light-buffer reuse, all nine private bindings and short-buffer
fallback pass. Captured native-bytecode RGB/HDR comparisons cover this archway,
Velen, the second weather scene, clean storm and two authored overrides. Native
pixel-coordinate matrices are rescaled about pixel centers in the fixture.
The per-pixel normalized HDR bound is 0.001 (Volume retains 0.05); archway
NVIDIA/WARP maxima are 0.0001692/0.0002377. Native sky comparisons at density
multipliers 0/.5/1/2 are exact in the tested profiles. Native fallback, signed
HDR/AO, clip W, sparks, Igni and particle-depth regressions also pass.

Idle RTX 5090 synthetic 2560x1440 RGBA32F composite timings at Ultra: native
0.0390 ms, per-pixel sunlight 0.986/1.047 ms. A separate local-only fixture with
one unshadowed/shadowed light costs 0.225/0.406 ms with a surface beyond the
light, or 0.132/0.145 ms when that surface is in front. These are separate
fixtures, not additive measurements or gameplay FPS; cloud/terrain complexity,
resolution, transparent overdraw and the number of visible lamps affect cost.
Evidence: tmp/witcher3classic-investigation/fog-reconstruction-20261029.

Build target: thewitcher3classic, clang-x64-release; inspect generated embeds
0xF3C30001, 0xF3C30002, 0xC8C78997, 0xBC930752 and participating forward shaders.
Live acceptance: after restarting at the archway with Per-pixel and Ultra,
the user reported "Absolutely perfect, banding is gone completely and fog looks
much cleaner." This confirms the reported archway banding is resolved. It is
not a claim that every other scene, weather or performance case was checked.
For broader verification, compare stationary/moving sunlight, blockers,
doorways, transparent particles/water and GPU cost against Volume while keeping
weather and light-strength controls fixed.

Release addon SHA256:
FC8479F94CA2E3F46071AD4F133384B3F0BABD9C9A00782CC67002E9283128F2.
The existing game-folder symlink resolves to that Release addon. Rebuilt
renodx-witcher3-classic-2026.10.29.zip is 38,395,183 bytes with 15 verified
entries: addon, production NVIDIA runtimes and licenses, no loader/instructions.
