# Assassin's Creed II — dgVoodoo DX11

This replaces the previous native DX9 mod. Build target: `asscreed2`.
The game remains 32-bit; dgVoodoo must use its DX11 output backend.

See the [implementation and porting guide](IMPLEMENTATION.md) for the complete
design, problems and solutions, including bloom, Eagle Vision, video cropping,
playback/startup crashes, and a Brotherhood/Revelations handoff. The
[pipeline evidence](PIPELINE.md) is chronological and includes superseded builds.

The mod uses an FP16 swapchain clone with RGB10A2 HDR10/PQ presentation.
Output is fixed to HDR10. PsychoV uses gamma 2.2 for scene, LUT, HUD and
final-buffer decoding; Vanilla/Preset Off uses sRGB to display the native SDR
signal in HDR10. There are no display-output or input-encoding settings. PsychoV-30
uses the HDR display's detected peak and independent 203-nit game/HUD reference
whites. Peak detection follows Ghost of Tsushima: the first successful swapchain
query sets the reset value within 400–4000 nits, and updates the current value
only if it still matches the previous default. Manual values are preserved.
If detection is unavailable, the initial 1000-nit default remains in place.
Preset Off selects Vanilla and resets user grading while retaining HDR10 output.

The mod creates FP16 clones for the captured 16:9 RGBA8
typeless render-target family, including scene, bloom, postprocess and HUD.
An aspect tolerance of 0.1 includes integer-rounded bloom sizes such as
60×33 at 2160p and 30×16 at 1080p. Rules require render-target usage and
exclude depth/stencil and UAV resources. Sample-only textures and the 16³
LUT are excluded. Other aspect ratios are not yet covered.

Rules are available at device creation because dgVoodoo creates the main
scene target before its final swapchain size is available. Original resources
and integer views remain available to the wrapper. Direct resource-format
replacement was rejected after runtime view-creation errors. Normal gameplay
now verifies active FP16 scene/bloom/postprocess/HUD clones and a scene input
above 1.0. Integer-view consumers outside this capture and other recreation
cases still need validation.

`0x61888319.ps_5_0` applies PsychoV-30 to the preserved scene signal. The
LUT bridge decodes to linear BT.709, fits signed colors with Adaptive D65,
uses max-channel N2 to enter the LUT range, samples the original 16³ grade,
and restores its linear range/gamut before tone mapping. Custom trilinear
sampling uses shader-precision weights to avoid amplifying hardware sampler
rounding during reconstruction. Native coordinates and dgVoodoo channel masks
are preserved. Vanilla and missing/incompatible injection use the original
hardware-sampled LUT path. Output alpha remains zero.

PsychoV-30 in `psychov30.hlsli` is based on Ghost of Tsushima's local
`test30.hlsl` revision (2026-09-14), with an AC2 shadow-grading correction.
Its input/output grading extensions and automatic 4000-nit working-range
shoulder follow that mod. AC2 calibrates the gray anchors through its own
LUT; it does not use Ghost's SDR curve, matrices, or square-root shaper.
The pre-LUT baseline slope is one. Background anchors are limited below
the display peak so low-peak/high-paper-white combinations remain valid.

Shadows uses a monotone curve in stops below the adaptation anchor. Values
below 50 darken and values above 50 lift shadows; 50 is exact identity. Black
and the anchor remain fixed, with unit slope at the anchor. This replaces the
original subtractive curve, whose negative results were reflected into light
by later sign restoration, and whose upper endpoint introduced a black offset.

HUD shaders `0x0DA2DE91`, `0x12BA0F50`, and `0x2EAA46EB` scale color
brightness independently of the scene and retain native alpha. The addon
reads DX11 output-merger blend state to preserve masks, multiplicative
draws and premultiplied alpha. Pre-LUT additive ONE+ONE draws retain native
scene energy: the sun and flare reuse a HUD shader and must not follow UI
Brightness. Additive HUD draws after the LUT still receive UI scaling.
The final proxy scales by game white, so
the HUD slider cannot rescale the whole scene. UI shaders outside these
captured hashes and video brightness are not separately covered yet.

The pre-LUT calls to `0x8FA72580.ps_5_0` apply a bloom-input shoulder to
each sample before downsampling. Inputs up to 1 remain exact; higher RGB
maxima follow `2 - 1/x`, preserving RGB ratios and native alpha. This retains
above-white bloom input while preventing extreme glow-mask gains from
spreading through all five bloom levels. The separate scene color remains
unchanged. A per-frame LUT-draw marker excludes this shader's later use for
depth of field. Vanilla/Preset Off retains the same bloom protection because
the FP16 upgrades remain active. This selection is based on
the captured normal-gameplay pass order; other rendering modes need testing.

Eagle Vision's `0x5574B6B8.ps_5_0` combines the tonemapped scene with two
signed color-effect textures. Its HDR path removes the final SDR upper clamp
while preserving the original black floor, effect weights and alpha. Added
highlights use a smooth shoulder within the remaining display headroom; the
base scene is not tonemapped again. Vanilla and missing injection retain
the native clamp. Its signed blur/filter intermediates already have FP16
clones, and the post-LUT Eagle Vision blur passes bypass the bloom prefilter
correction. Distance/opacity and radial-blur geometry clamps remain native.

The presentation proxy restores dgVoodoo's graphics state after drawing.
This prevents triangular cropping during video playback when the wrapper
reuses state across frames. The captured startup video now fills both the
4K movie target and swapchain clone. Native video shaders remain unchanged.
The user verified complete playback after the DevKit capture-cache and shared
allocation-alignment fixes, which address separate playback/startup crashes.

## Controls

Use `Settings Mode: Advanced` to show the complete Ghost of Tsushima control
set. No effect controls are included; Flare is its tonemapping compensation.

| Section | Controls |
|---|---|
| Tone Mapping | Vanilla/PsychoV-30, Peak Brightness, Game Brightness, UI Brightness, Hue Shift |
| Color Grading | Exposure, Gamma, Highlights, Shadows, Contrast, Saturation, Highlight Saturation, Blowout, Flare, Color Filter |
| PsychoV30 | Cone Response Exponent, Adaptation Anchor, Background Anchor, Gamut Compression, BT.709/BT.2020 Target, Compression (0 = Auto) |
| Options | Reset All |
| Links / About | RenoDX Discord, HDR Den Discord, GitHub, Hartapfel's and ShortFuse's Ko-Fi, credits and build date |

Color Filter removes native grade chroma while retaining graded luminance
and lighting. The other controls use Ghost's defaults, ranges and scaling.
The old scaffold's `PaperWhiteNits` setting is superseded by `ToneMapGameNits`.

FP16 intermediates remove original UNORM write clamps/quantization, so
Preset Off does not undo resource formats or guarantee exact vanilla SDR.
Compare native shader behavior with the saved scaffold when assessing SDR
equivalence. The bloom-input correction addresses extreme gains exposed by
resource cloning without adding effect sliders.

## Build

From an x86 Visual Studio developer environment with Clang available:

```powershell
cmake --preset clang-x86
cmake --build --preset clang-x86-release --target asscreed2
```

Output: `build32/Release/renodx-asscreed2.addon32`.
Generated proxy shader embeds: `build32/asscreed2.include/embed/`.
Scene/LUT, bloom, Eagle Vision and three HUD embeds are generated there too.
The `_5_x` proxy sources follow the generic template; only their DX11 variants
are registered. They are addon-owned shaders, not captured game hashes.

## Installation and verification

1. With the game closed, place/link the Release addon beside
   `AssassinsCreedIIGame.exe`. Keep dgVoodoo's `D3D9.dll` and use 32-bit ReShade
   as `dxgi.dll`. Load only one Assassin's Creed II game addon.
2. Use a compatible 32-bit Release DevKit. Set ToolsPath to the repository's
   `bin` and LivePath to `src/games/asscreed2`. Rebuild DevKit with the bounded
   texture-observation cache: older builds retain each video frame and can
   exhaust this 32-bit game's memory. Rebuild the game addon and DevKit together
   after the shared process-allocation alignment correction.
3. Launch the game and check `ReShade.log` for the DX11 device and
   `RenoDX for Assassin's Creed II` addon. Confirm the overlay controls work.
   Check that resetting Peak Brightness selects the detected display peak,
   and that a manually adjusted peak survives restarting the game.
4. Inspect the FP16 proxy and RGB10A2 swapchain. Confirm HDR10 color space
   and input decoding (PsychoV: gamma 2.2; Vanilla/Off: sRGB). Compare glowing
   objects in both modes to verify bloom protection. Check gameplay, menus, video,
   alt-tab, and resizing. Gameplay, Eagle Vision and the captured startup video
   have been verified; other video variants and recreation cases need validation.
5. Compare Vanilla/PsychoV-30 in a stable scene, then vary peak, exposure,
   gamut target and Color Filter. Sweep Shadows through 0/50/100 and return
   it to 50. Test UI Brightness at 80/500 nits and restore 203: HUD colors should
   change, while scene exposure and mask/multiply behavior remain stable.
6. Dump shaders to the game-local `renodx-dev/dump`, validate each unmodified
   DX11 baseline, then add `{CRC32}.{TARGET}.hlsl` replacements here and register
   their hashes in `custom_shaders`. Keep dumped `.cso` files out of this folder.

The 112-byte C++/HLSL injection block uses `b13` (space 50 for SM5.1+).
The modified game shaders use native slots b3/b4. A version marker makes
live shaders retain the original path with the older scaffold injection.

## Captured shader baseline

The 2026-09-13 dump contains 354 DXBC shaders. The game-local
`renodx-dev/shader-baseline-20260913/` holds original bytecode, disassembly,
reference HLSL, separate working copies, a backup ZIP, SHA-256 manifests,
and `ANALYSIS.md` / `INDEX.md`. The references are protected as read-only.
All 354 reference HLSL files recompile with their original profiles; 121 pass
warnings-as-errors. Compilation does not establish semantic equivalence:
183 pixel shaders need review of incorrectly decompiled dgVoodoo sample masks.

The principal traced shaders are `0x61888319.ps_5_0` (3D LUT application),
`0x5574B6B8.ps_5_0` (explicitly clamped three-texture composite), and the SM4
resampling clamps listed in the analysis. No LUT builder or standalone scene
tonemapper was established. Scene LUT, bloom prefilter, Eagle Vision composite,
and HUD replacements are registered;
repair and verify each further native baseline before adding HDR transformations.

The [historical gameplay pipeline trace](PIPELINE.md) records the initial
2026-09-14 live capture, LUT/HUD ordering, the original UNORM bottlenecks,
and successive corrections. All 142 shaders tracked in that capture are
covered by the preserved baseline. Use [IMPLEMENTATION.md](IMPLEMENTATION.md)
for the final behavior and porting guidance.

The initial clone build was verified in normal gameplay on 2026-09-14: the captured
scene input reached RGB maxima (2.467, 2.123, 1.651), with 92,158 pixels
above 1.0 and no NaN/Inf values. The LUT remained RGBA8 and the final graded
image stayed at or below 1.0. The addon LUT replacement was active. This
established upstream headroom for the tonemapper/LUT bridge.

The PsychoV build subsequently preserved above-white values through final
HUD composition: 235,579 pixels exceeded 1.0 in an encoded FP16 gameplay
readback, with no NaN/Inf values. This is an intermediate resource check,
not a measurement of the display. A D3D11 WARP test evaluated the real HLSL
over 40 control cases and 256 gray/saturated/signed inputs per case. All
values were finite; identity-LUT relative error was below 0.06%, UI scaling
error below 0.0002%, and changing UI settings left scene results identical.
After the DX11 blend-state correction, the user verified UI Brightness at
80 and 500 nits in normal gameplay: the HUD changes and the scene stays the same.

The bloom-input correction was then verified in the same street: the user
confirmed that the large white discs were resolved, and the captured preview
shows localized glows. Final FP16 output still contains above-white values
with no NaN/Inf. The rebuilt downsampler and tonemapper report Add-on sources.

Active Eagle Vision was also verified after its composite correction: the user
confirmed the colored highlights, and the final FP16 readback retains 138,550
above-white pixels with no NaN/Inf. The native composite had clipped all RGB
to at most 1.0. The Eagle Vision shader reports Add-on with no disk override.
