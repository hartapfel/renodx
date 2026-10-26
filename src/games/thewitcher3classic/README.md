# The Witcher 3 Classic HDR (experimental)

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
