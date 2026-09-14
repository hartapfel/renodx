# Gameplay pipeline evidence — 2026-09-14

This is a chronological development record. Statements about missing upgrades,
SDR/output toggles, pending work and earlier builds describe their respective
capture stages, not the final mod. See [IMPLEMENTATION.md](IMPLEMENTATION.md)
for the completed design, troubleshooting explanations and Brotherhood/Revelations
handoff, and [README.md](README.md) for current usage and build instructions.

Captured through the running 32-bit DevKit on dgVoodoo's D3D11 device at
3840×2160. The snapshot contains 3,944 draws, 142 shaders and 411 resources.
All 142 tracked shaders have original bytecode and decompiled references in
the preserved 354-shader baseline. All report `Original`, with no addon or
disk replacements. The addon-owned presentation proxy is separate.

Evidence files are in the local workspace at
`tmp/asscreed2/live-20260914/`: `draw3884-result.json` through
`draw3943-result.json`, `tail-resource-chain.json`,
`all-shaders-result.json`, `shader880A17D3-result.json`, and
`readback-final-result.json`. Draw numbers and resource handles below belong
to this snapshot; they are not stable identifiers for addon rules.

## Output and format bottlenecks

The public swapchain is `r10g10b10a2_unorm`; the runtime log reports
HDR10/ST2084. The final game draw targets an enabled `r16g16b16a16_float`
swapchain clone. This verifies the scaffold's presentation path in gameplay.
SDR/HDR switching, original-output decoding, menus, videos, and recreation
compatibility still need separate visual validation.

The traced scene, bloom, LUT output, and HUD targets are still
`r8g8b8a8_typeless` resources with `r8g8b8a8_unorm` views. They have no
intermediate upgrades or clones. These writes restrict color to [0,1]
before it reaches the FP16 presentation proxy.

## Captured resource chain

All pixel shaders below are `ps_5_0` except the final `ps_4_0` copy.
Handles are abbreviated to their nonzero hexadecimal digits.

| Draw | Pixel shader / operation | Inputs → output | Interpretation |
|---|---|---|---|
| 3884 | `0xA0D80D49` | → `FC159A4` | Scene-tail draw, max blending, full color writes |
| 3885 | Copy | `FC159A4` → `779AA824` | Scene copy; include both endpoints in upgrade analysis |
| 3886 | `0x6B413C5D` | `779AABE4` → `779AAA24` | Full-resolution copy |
| 3888–3908 | `0x8FA72580`, `0xC1CCD6E4`, `0x82B8F12E`, copy passes | Multiple UNORM intermediates | Filter/downsample chain feeding bloom |
| 3910 | `0x7405432A` | Five filtered inputs → `7796D1A4` (960×540) | Five-input additive bloom combination |
| 3912 | `0x35D82084` | `779AAA24` + `7796D1A4` → `7796D724` | Scene/bloom sum, 3840×2160 |
| 3913 | `0x61888319` | `t0=7796D724`, `t33=779A9D24` → `7796D364` | 3D LUT application before the HUD |
| 3915–3916 | `0x8FA72580`, `0x13DD44CF` | LUT output → `7796CBE4` → `7796F0E4` | Filtered graded scene |
| 3918 | `0xC8769384` | LUT output + filtered output + `t2=779A4A24` → `7796D724` | Depth-dependent blend, likely depth of field |
| 3919 | `0x6B413C5D` | `7796D724` → `FC159A4` | Scene transfer to target subsequently receiving HUD |
| 3920–3942 | `0x0DA2DE91`, `0x12BA0F50`, `0x2EAA46EB` | UI textures → `FC159A4` | HUD/UI candidates after scene processing |
| 3943 | `0x880A17D3` | `FC159A4` → swapchain clone | Integer-coordinate `Texture2D.Load` copy; no tonemap or gamma conversion |

The interleaved `0xFF904AEA.ps_4_0` draws have no color RTV and copy `t5.x`
to `SV_DEPTH`; they are depth transfers, not scene color transforms.

The LUT at draw 3913 is a 16×16×16 texture, with an RGBA8 UNORM sampling
view. The shader forms coordinates from scene RGB using `cb4[8].xyz` and
`cb4[9].xyz`, then samples `t33/s1`; blending is disabled. Its upstream
input is already UNORM. No LUT builder or standalone filmic tonemapper has
been established. This capture does not establish how the LUT was populated.

HUD draws reuse shaders with different write masks. For example,
`0x12BA0F50` has mask 0 at draws 3921/3931 and mask 7 (RGB) at
3927/3935–3937/3940/3942. `0x0DA2DE91` uses masks 15 and 7. Draw 3923
uses `0x2EAA46EB` with source-alpha / one-minus-source-alpha blending.
Preserve alpha, discard, and mask-related behavior when adding UI scaling;
shader identity alone does not prove that every invocation writes HUD color.

## Readback and HDR source status

A live readback of `FC159A4` shows normal outdoor gameplay with the health,
controls, money and minimap HUD. Its 8,294,400 pixels have no RGB values
above 1.0; channel maxima are approximately (1.0, 0.9922, 0.9725).
The image is an SDR intermediate preview, not a screenshot of HDR output.

Resource readback is current-frame data, not a frozen snapshot attachment.
The successful final-target readback resolved to the expected resource.
A separate attempted LUT readback resolved to a different 240×135 2D
resource after resource recreation; that result is rejected as stale.
Refresh the snapshot and check dimensions/type/handles for future readbacks.

No surviving above-white scene signal is proven in these intermediates.
The scene/bloom sum before the LUT is a useful transformation location only
after upstream resource upgrades preserve its range. The final copy receives
the completed, clamped scene and HUD and is only an output-transfer target.

## Implementation handoff

1. Repair and verify native replacements for the selected shaders against
   their original assembly before applying HDR math. The decompiled baseline
   compiles, but dgVoodoo sample-mask numeric casts require bit-reinterpretation
   repairs; successful compilation alone does not establish equivalence.
2. Trace earlier scene producers and the `779AABE4` input, then upgrade the
   connected scene/copy/bloom/LUT/postprocess/HUD render targets to FP16.
   Match creation properties and compatible views/copies, not these transient
   handles or a blanket rule for all RGBA8 textures. Preserve LUT, depth,
   ordinary sampled textures, and alpha semantics.
3. Confirm the upgraded scene/bloom input actually carries values above 1.0.
   Keep an unmodified reference capture and validate aliases, copies, and
   resource recreation before treating the resource rules as complete.
4. Use `0x61888319` as the proven LUT/scene-tone transformation candidate.
   Establish its input color domain and preserve the vanilla LUT grade as an
   SDR reference; use the preserved upstream signal for the HDR path.
   Validate the following depth-dependent blend with that extended signal.
5. Handle HUD brightness in the later UI shaders while preserving their
   alpha/mask uses. Keep the final copy and proxy focused on presentation.
6. Capture Eagle Vision separately for `0x5574B6B8`, plus menus, fades,
   loading screens and video. The static clamp/video candidates have not
   been validated by this normal-gameplay frame.

No captured game shader or intermediate resource rule was changed during
the original investigation. The protected native baseline remains the reference.

## First implementation

`0x61888319.ps_5_0` now has an addon replacement that repairs only four
decompiler bit-cast errors. FXC `/Ges /WX` passes; assembly preserves the
sample/AND/OR/MAD/sample/AND/OR sequence and zero output alpha. No custom
tone transformation has been introduced yet.

The first runtime trial used direct FP16 format replacement and rules set
at swapchain initialization. It exposed two issues: dgVoodoo also creates
`r8g8b8a8_uint` views, which are incompatible with a directly replaced FP16
resource, and the main scene target had already been created before the
final swapchain dimensions became available. The trial capture did not
contain the expected bloom/LUT chain and is not accepted as validation.

The correction uses the shared resource-cloning path with rules installed
at device creation. Match RGBA8 typeless color RTs with a 16:9 aspect ratio
and 0.1 tolerance to include rounded bloom levels; exclude depth/stencil,
UAVs, and sample-only textures. This covers the original capture's 23 color
RT dimensions and excludes its 16³ LUT. Other aspect ratios, copy aliases,
integer-view consumers, and recreation remain additional runtime checks.

The corrected clone build was then tested in normal gameplay. The captured
tail contains 24 distinct RGBA8 color targets with active FP16 clones,
including scene/bloom combination, LUT output, depth-dependent postprocess,
HUD composition, and the scene input to the final copy. The five bloom
levels also have FP16 sampling views; the LUT and depth input are unchanged.
The expected bloom/LUT chain is present again, and the runtime log has none
of the earlier missing-view-remap warnings. `0x61888319` reports source
`Add-on`, with no disk override.

A readback of the full-resolution `t0` input to `0x35D82084` resolves to the
expected clone and contains RGB maxima (2.4668, 2.1230, 1.6514). 92,158 of
8,294,400 pixels exceed 1.0, five contain a negative channel, and none have
NaN or infinity. This is an upstream scene input before the bloom sum and
LUT, providing evidence of range preserved by the resource clones. Readback
is live data, not an exact historical draw capture. The final graded scene
with HUD still has RGB maxima of 1.0, so the native LUT remains the next
range-limiting transformation to replace/bridge.

The bloom-combination readback has zero RGB in this scene (and alpha up to
4.996); do not interpret its alpha as HDR luminance. Scene headroom is proven
by the separate full-resolution color input. Before comparing native and
custom tone paths, use stable scenes and avoid interpreting resource data
after alt-tab recreation; an earlier loading-screen readback was rejected
because its handles had become stale.

Evidence: `tmp/asscreed2/implementation-20260914/clone-chain.json`,
`tail-resource-chain.json`, `clone-scene-input0-readback.json`,
`clone-scene-input1-readback.json`, `clone-final-readback.json`,
`clone-lut-shader.json`, and `clone-gameplay-preview.png`.

The original scaffold addon/source are saved locally under
`tmp/asscreed2/implementation-20260914/`. Shader references in the protected
game-local baseline have not been modified.

## PsychoV-30 and HUD implementation

The scene/LUT shader now bridges the original grade through an HDR range
reconstruction and applies Ghost of Tsushima's local PsychoV-30 implementation.
The custom LUT path uses shader-precision trilinear weights; the Vanilla path
retains hardware sampling. The original LUT coordinates and channel masks
remain intact. The protected shader references remain unchanged.

The subsequent gameplay readback preserved above-white values through final
HUD composition: 235,579 pixels exceeded 1.0 in the encoded FP16 intermediate,
with no NaN or infinity. This verifies intermediate range, not display luminance.
The scene/LUT and three HUD shaders report Add-on replacements.

HUD replacement selection now reads the native D3D11 output-merger blend state.
The initial pipeline-subobject guard rejected HUD draws on this DX11 path and
made the slider ineffective. After correction, the user tested UI Brightness at
80 and 500 nits in normal gameplay and confirmed that the HUD changes while the
scene stays the same. Native alpha and mask/multiply handling are retained.

The Release x86 addon builds successfully. A D3D11 WARP fixture tested the real
HLSL over 40 control cases with 256 inputs each: all results were finite,
identity-LUT relative error was below 0.06%, UI scaling error below 0.0002%, and
UI setting changes produced identical scene results. The GoT tonemapping and
color-grading controls are present; no effect controls were added.

Evidence and the preceding source/addon backup are under
`tmp/asscreed2/psychov30-20260914/`, including `audit.json`, `validation.log`,
`final-build.log`, and the gameplay resource readbacks.

## Excess bloom investigation

The user reported large, peak-white discs around glowing street objects.
The live scene confirmed two such discs. Before experimental reloads, the
separate full-resolution scene input reached 2.416 while the 960×540 bloom
combination reached 327 in the game's encoded domain. The upstream glow mask
contained identical RGBA channels reaching 799. These are intermediate values,
not nits. Expected clone handles and dimensions matched the readbacks.

The mask is copied from the effect target, downsampled by `0x8FA72580`, then
multiplied by downsampled scene color using `0x6B413C5D` with destination-color
blending. Five filtered levels feed the additive `0x7405432A` combination,
which is added to the separate scene by `0x35D82084`. This identifies a common
bloom-input path rather than requiring a replacement for each glowing object.

A final-combination live experiment was inconclusive: DevKit reported a file
replacement but the FP16 clone did not show its bounded output. Unloading live
shaders also invalidated the active tone replacement until the four existing
game replacements were reloaded. Those results are not accepted as a visual
comparison. The existing HDR path was restored before closing the game.

The prepared addon correction uses the pre-LUT `0x8FA72580` draws. Each of its
16 samples keeps values up to 1 and smoothly rolls higher RGB maxima toward 2,
before spatial filtering and the mask/scene multiplication. Alpha remains native.
The LUT draw marks the end of bloom preparation so the post-LUT depth-of-field
calls use the original shader. The marker resets at the upgraded swapchain's
presentation. No FP16 resource rule or tonemapper setting changes.

The Release x86 addon builds. D3D11 WARP tests cover 256 gray, saturated and
signed inputs plus Vanilla/missing-injection bypasses. All tests pass. A
799-valued impulse among 16 samples contributes 0.124922 after input correction,
versus 49.9375 without correction, demonstrating control before blur spreading.
The user verified the rebuilt addon in the same street and reported that the
correction worked. The captured preview shows the two glowing objects with
localized halos instead of large white discs. Both the downsample and LUT
shaders report Add-on replacements with no disk overrides. The final FP16
scene/HUD resource retains 19,641 pixels above 1, reaches an encoded RGB maximum
of 1.853, and has no NaN or infinity. This is a different animated frame, not a
pixel-exact before/after comparison. A subsequent attempt to inspect individual
bloom intermediates encountered recreated/untracked views and was rejected.

Evidence and the previous working addon/source are in
`tmp/asscreed2/bloom-20260914/`. Initial `readback.log`, `inspect.log`, resource
JSONs and `preview.png` record the diagnosis; `build.log` and `validation.log`
record the prepared correction. Live resource reads are from different frames.

## Eagle Vision investigation and correction

An active Eagle Vision capture contained 2,111 draws. The existing scene LUT
replacement runs at draw 2078. Eagle Vision then produces and filters signed
effect buffers, composes them with the scene at draw 2102 (`0x5574B6B8`), and
performs radial blur (`0xEDF7F8F2`) and depth-dependent postprocessing before
the final copy. All color resources in this tail have instantiated FP16 clones.
The original final readback has no RGB above 1.0.

The composition shader decodes both effect inputs with `2*x-1`, applies the
native `cb4[8].x` / `cb4[9].x` weights, adds them to the scene, and executes
`add_sat` on RGB. Alpha is fixed at 1. This is the remaining explicit SDR color
ceiling in the captured effect tail. The signed soft-filter input reached
1.192, and the streak-filter input reached 2.301, before their bias removal.
The separately retained scene source also contains above-white values. Resource
handles and clone dimensions matched each accepted readback; these are live
contents, not frozen attachments to historical draw calls. The scene/LUT target
is reused later, so its live contents cannot establish the earlier LUT output.

The new replacement repairs six decompiler sample-mask bit casts and replaces
only the final RGB clamp with `AC2CompositeEagleVision`. It preserves native
black, effect remapping/weights, and output alpha. In HDR/PsychoV mode, positive
effect additions above the scene/reference-white anchor roll smoothly toward
the selected display peak using uniform linear RGB scaling. Zero effect keeps
the existing scene level exactly; the scene does not receive a second PsychoV
pass. SDR, Vanilla and invalid injection use the original `saturate` path.

The other observed saturates are distance/opacity factors or blur geometry,
not color-output ceilings, and remain native. No new resource rules or controls
are required. The existing pre-LUT bloom guard already excludes the Eagle Vision
filters that execute after the scene LUT.

FXC compiles the repaired native baseline with `/Ges /WX` and the replacement
with `/Ges` (the existing shared ACES warning remains). D3D11 WARP tests evaluate
256 dark/HDR scene and signed-effect combinations across 12 output, peak,
reference-white, gamut and encoding cases. They pass finite-value, peak-bound,
color-ratio, zero-effect identity and native-bypass checks. The Release x86
addon was rebuilt and verified in active Eagle Vision. The user reported that
the result looks correct. `0x5574B6B8` reports source Add-on with no disk override.
The final FP16 readback contains 138,550 pixels above 1.0 and no NaN/Inf, where
the original Eagle Vision capture contained none above 1.0. Encoded RGB maxima
are (2.365, 1.974, 1.999); individual BT.709 channels are not display luminance
measurements or BT.2020 peak bounds. The camera/animation changed between
captures, so these are pipeline range checks, not pixel-exact comparisons.

Evidence and the preceding source/addon backup are in
`tmp/asscreed2/eagle-20260914/`: `tail-details.json`, `original-final.json`,
`original-preview.png`, the accepted source/filter readbacks, `validation.log`,
`build.log`, `fixed-final.json`, `fixed-preview.png`, and `audit.json`.

## Video playback state correction

The startup-video capture contains three draws: packed BGRA decoding through
`0x471059BE.ps_5_0` into a 1280×720 target, scaling through
`0x915F8B01.ps_5_0` into the 3840×2160 main target, and the final
`0x880A17D3.ps_4_0` copy into the swapchain clone. Both sizes are 16:9 and
the decoded movie, main target and swapchain already have active FP16 clones.
The original capture shows triangular missing regions: main-target alpha
coverage is approximately one half and swapchain-clone coverage one quarter.

The presentation proxy binds triangle-list topology and its own viewport and
bindings. dgVoodoo reuses graphics state across video frames. Enabling
`swapchain_proxy_revert_state` restores the preceding state after that pass.
The triangle-list state leaking into subsequent quad draws is consistent with
the observed missing triangles; the capture API does not expose actual input
assembler topology, so that individual state was not measured directly.
No video shader, sampling coordinate, resource rule or brightness control changes.

The Release x86 `asscreed2` target builds successfully. A subsequent capture
of the same three-pass video path shows no triangular cutouts. Both 4K FP16
targets have alpha min/mean/max of 1, zero entirely black RGB pixels in the
captured animation frame, and no NaN/Inf. The resource handles resolve to the
expected active clones. These are different animated frames and live resource
reads, not a pixel-exact before/after comparison. The six native video vertex
and pixel shaders remain covered by the protected shader baseline.

Evidence and the preceding addon/source backup are in
`tmp/asscreed2/video-20260914/`. The original capture is
`capture-1789390024870183700`; the corrected capture is
`capture-1789390316745211600`. Each contains draw metadata, resource analyses
and PNG previews. `build.log` records the Release build.

The user confirmed normal video framing but reported a consistent crash during
playback, including before the cropping fix. An attached debugger caught an
unhandled `std::bad_alloc` in DevKit's `resource::replace::RecordObservation`,
called by `OnUpdateTextureRegion`. The existing observation cache retains a
3,686,400-byte sample for every distinct 1280×720 video frame without a total
budget. The faulting allocation requested another sample of that size.
This is independent of video geometry and tone mapping.

The shared texture-observation fix caps samples at 64 MiB per device and caps
metadata at 4,096 records. Existing observations still update hit/replacement
counters; new records after the byte budget retain metadata without a sample.
Clearing observations restores capture capacity. Capture allocation failure
returns without aborting the application's upload. The data layout and texture
replacement path are unchanged. An x86 test processes 512 full video frames,
retains 18 samples (66,355,200 bytes), and passes record-limit, repeated-hit,
partial-update, injected-allocation-failure and clear/recovery checks.
After rebuilding DevKit, live observations reach exactly 67,108,864 retained
sample bytes; further video uploads retain metadata without samples. The user
verified that playback completes normally after both crash corrections.

Separate earlier startup dumps contain an alignment fault while constructing
`shader::SharedData` from process-heap storage. They are not the captured
playback exception. This fault recurred during the video-cache verification
launches, before DevKit loaded. The faulting `movaps` wrote to an address ending
in `0x08`; the actual shared type requires 64-byte alignment. The process heap
only guarantees 8-byte alignment on x86 (16 on x64).

The process allocator and shared-object factory now overallocate for types
whose alignment exceeds the heap guarantee, preserve the original heap pointer,
and release it through the matching process-heap path. Normal-alignment types
retain their existing allocation layout. Throwing constructors release their
storage. x86/x64 tests cover 8/16/64/256-byte alignment, zero/multiple counts,
overflow, zero initialization, constructor exceptions and heap validation.
Both also construct/free the actual 6,208-byte, 64-byte-aligned shader shared
data 128 times. Rebuild participating addons together for the aligned allocator.

The AC2 game addon remains linked to `build32/Release`. DevKit is now installed
as a copy of `build32/Release/renodx-devkit.addon32`; recreating its former
`build32.vs/Release` symlink required administrator privileges. Copy subsequent
DevKit builds explicitly while the game is closed. The preceding DevKit binary
is preserved with the video investigation artifacts.

The final run passed the previous playback failure point and the user confirmed
the result. Private memory remained approximately 0.9 GB during the later part
of the run instead of growing with every captured video frame. The active
device remained DX11 with the 3840×2160 RGB10A2 swapchain. `final-memory.csv`,
`fixed-cache-all.json`, the cache-state/runtime JSONs, `final-build.log` and
`audit.json` preserve the verification evidence. Earlier startup and playback
failures have separate captured causes and fixes; this run verifies both.

## Final controls and shadow grading

Display Output and its OutputMode/SwapChainDecoding settings were removed.
The swapchain color space and shader output preset are fixed to HDR10; input
decoding/encoding is fixed to gamma 2.2 across the scene/LUT, HUD, Eagle Vision
and proxy paths. The legacy injection slots remain to preserve the 112-byte
layout, but saved settings cannot override the shader constants. Preset Off
now selects native shader behavior and neutral grading within HDR10 transport.

The original PsychoV-30 shadow scalar could become negative below the gray
anchor at low control values. Later CopySign restored the source signs to
its absolute magnitude, turning the negative grade into raised brightness.
At the upper endpoint the zero power introduced a nonzero black offset.
The AC2-local scalar now grades distance below the anchor in stops:
`d' = d * (1 + (2^(1-shadows)-1) * d/(d+4))`. It preserves exact neutral,
black and the anchor, has unit slope at the anchor, and remains monotone in
both luminance and slider position across the complete 0..2 internal range.
The rest of the copied PsychoV-30 source and Ghost of Tsushima remain unchanged.

The footer copies Ghost's Reset All, RenoDX/HDR Den Discord, GitHub, both
Ko-Fi links, credits and build timestamp. Instructions describe Windows HDR,
dgVoodoo DX11 and brightness setup without asking for native game HDR.
Copyright attribution follows Ghost's Carlos Lopez/Hartapfel header and the
metadata maintainer is `hartapfel`.

The Release x86 addon builds successfully. D3D11 WARP evaluates 101 slider
positions across six anchors and 256 input levels/colors per case: all 606
cases pass finiteness, monotonicity, black/anchor/neutral identity, and fixed
encoding/output checks. The full LUT/HUD fixture passes 40 control cases,
with identity-LUT relative error 0.000511169, UI error 0.00000117448, and zero
scene difference from UI settings. A dedicated runtime slider/footer check was
not recorded at this stage. Evidence and the preceding source/addon are preserved in
`tmp/asscreed2/final-controls-20260914/`.

## Automatic peak detection and documentation handoff

The final addition copies Ghost of Tsushima's swapchain-initialization peak
detection, also used in the Resonance mod. The first successful `GetPeakNits`
query sets Peak Brightness's reset default within 400–4000 nits. It changes
and persists the current value only when that value equals the previous
default, preserving other manual choices. Failed queries leave the 1000-nit
fallback and may retry on a later initialization; successful detection runs
once per addon session. Reset All uses the detected default, while Preset Off
retains its explicit 1000-nit assignment and fixed HDR10 transport.

The x86 Release build passed, and its hash matched the installed addon.
`tmp/asscreed2/auto-peak-20260914/` holds the source comparison, build log,
previous addon and audit. No measured per-monitor runtime peak was recorded.
The user subsequently accepted the implementation as complete and requested
the consolidated [implementation and porting guide](IMPLEMENTATION.md).

## Shared sun/flare and HUD shader follow-up

A subsequent sun-facing capture contains 1,449 draws. `0x0DA2DE91` with vertex
shader `0xB1B3AE89` serves both additive sun/flare draws before the scene LUT
and alpha-blended HUD draws afterward. Draws 932, 935, 1265 and 1389 use
ONE+ONE additive color writes; the LUT is draw 1418. Readbacks of the 128×128
sun and 64×64 flare textures establish the scene use. Applying the UI multiplier
to all RGB-writing uses of this hash caused the reported sun-brightness coupling.

The selection callback now leaves pre-LUT ADD/ONE/ONE draws native, while
retaining post-LUT additive HUD scaling and ordinary alpha/opaque menu handling.
The x86 WARP fixture passes 42 actual DX11 blend-state cases. Running the same
fixture with the preceding callback fails exactly the four scene-effect draws.
Capture, previews, source/addon backups and fixture logs are saved under
`tmp/asscreed2/sun-ui-20260914/`. The x86 Release build passed and matched the
installed linked addon (`audit.json`). After restarting, the user confirmed the
requested 80/500-nit UI sweep with the sun visible and pause-menu check worked
correctly. Sun/flare brightness is now independent of the UI slider.
