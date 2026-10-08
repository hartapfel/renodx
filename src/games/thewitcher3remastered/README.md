# The Witcher 3 - Remastered

Experimental DX12 HDR replacement for the updated Witcher 3 renderer. The native AgX/Hable stages are bypassed while their exposure and transition blending are retained. Exposed HDR survives scene effects and grading; PsychoV-30 then maps it once before UI composition and BT.2020 PQ encoding. Native luminance-driven highlight expansion is bypassed. Use the game's native HDR output. SDR output variants have not been integrated.

## Optional Darker Nights addon

The HDR addon handles tone mapping, colour grading, HDR output and presentation
controls. Night illumination, night grading, camera lights and moon size live in
[The Witcher 3 - Remastered: Darker Nights](../thewitcher3remastered-darkernights/README.md).
It builds and installs independently and can be used alone or alongside this HDR
addon. Existing HDR lighting keys are ignored; configure the standalone addon.

## Controls

- Tone mapper: Vanilla or PsychoV-30 (default).
- Enhanced motion blur and Video AutoHDR have been removed to avoid rendering-worker overhead. Motion blur and movie composition use the game's native path; there is no CPU Performance Mode setting.
- BT.709 Video Colors: restores the committed limited-range video decoding correction (default On). Off uses native BT.601 decoding. It uses only the native video textures/samplers and preserves opacity; AutoHDR remains removed.
- Brightness Compensation: Off, On (default), or Darken Only. Evaluates the current native Hable/AgX/bypass curve at 18% grey and applies its luminance gain to the exposed HDR scene. Darken Only caps that gain at 1Ã—, retaining compensation that reduces overexposure without applying compensation that brightens nights or dark weather. Each environment's gain is capped before transition blending. The game's separate exposure/adaptation remains active; this mode prevents additional brightening from the compensation itself. PsychoV remains the final tone mapper and UI white stays independent. Existing saved Off/On values remain unchanged.
- Automatic HDR display peak detection, manual peak override, game/reference white, and independent UI white. Detection follows Ghost of Tsushima: it updates the startup default, preserves a saved nondefault override, and makes Reset restore the detected peak (clamped to 400â€“4000 nits).
- PsychoV-30: hue shift, cone response exponent, adaptation/background anchors, gamut compression strength and BT.709/BT.2020 target, automatic/manual compression.
- Colour grading: exposure, gamma, highlights, shadows, overall contrast, Highlight Contrast and Shadow Contrast, saturation, highlight saturation, blowout, and flare.
- Scene Grading (PsychoV-30): LUT Grading Strength and Color Grading Strength control the native LUT and analytic grade independently (0–100, default 100). LUT Scaling (0–100, default 100) restores black/white range using black, midgray and white samples. All three LUT paths, including environment/night blends, and the subsequent day/night grade preserve signed wide-gamut colours. The reversible LUT lookup proxy bounds sampling coordinates, then restores scene range and gamut. No scene/LUT gamut projection occurs before PsychoV; its selected BT.709/BT.2020 target and Gamut Compression slider control display mapping. Native LUT gains/blends, alpha and independent vignette controls are retained.
- Chromatic Aberration: Native (default) or RenoDX, with Ghost of Tsushima's CA Intensity and Start Offset controls. RenoDX replaces native CA and also works when the game's CA setting is off. These controls apply in PsychoV-30 mode.
- Sharpening: Native (default) or Lilium RCAS, with the same 0â€“100 strength mapping as Ghost of Tsushima. Selecting RCAS bypasses the native sharpening dispatch, including at strength 0. RCAS also works when native sharpening is off.
- Perceptual Film Grain: Ghost of Tsushima's luminance-adaptive grain, 0â€“100, default 0. No native grain pass was identified in the captured scene; this is a standalone slider. Both new effects require PsychoV-30.
- Bloom Strength: 0â€“200, default 100. Scales the native additive bloom/dirt composite; requires PsychoV-30 and native Bloom enabled.
- Blur, Sunshafts Strength, and Lens Dirt use the original Witcher mod's 0–100 mapping: 0 disables, 50 is unit strength, 100 doubles the effect. Blur controls the non-sky depth-blur radius and restores the old mod's accumulated-alpha blend weight; it is not Motion Blur or Witcher Senses. A zero setting also discards the sky blur branch. Lens Dirt scales only the dirt term; Sunshafts scales the masked sky input once. Keep the relevant native effects enabled. The previous Depth of Field slider has been removed.
- Vignette Strength: 0-100, default 50. 0 removes the effect; 50 retains native strength. In Native black-floor mode, 100 doubles blend opacity, bounded at fully opaque. Perfect Black preserves the existing response through 50, then increases optical density: 100 squares the remaining light without turning partial masks fully opaque. Covers radial and texture masks. Requires PsychoV-30.
- Vignette Black Floor: Native or Perfect Black (default), independent of Vignette Strength. Perfect Black applies pure linear HDR darkening after grade reconstruction, preserving the native mask and existing zero-black signal. Partial masks retain scene detail even at maximum strength; a genuinely opaque native mask can still reach zero. Requires PsychoV-30 and a native vignette stage.
- Simple/Advanced UI, Reset All, and Preset Off. Vanilla bypasses all custom processing; Off also resets the saved controls to neutral.

Defaults are unit grades/cone response, 0.18 anchors, zero hue shift/blowout/flare, full BT.2020 gamut projection, automatic compression, detected peak (1000-nit fallback), and 203-nit game/UI white. CA Intensity and Start Offset both default to 0.7 when RenoDX CA is selected.

## Integration

### Shader folders

| Folder | Responsibility |
|---|---|
| [tonemappers](./tonemappers/) | Native exposure/AgX/Hable stages, including environment transitions; custom mode preserves exposed HDR for final mapping. |
| [luts](./luts/) | Packed colour-LUT sampling: single LUT, blended LUTs, and independently graded LUTs. These are LUT consumers, not builders. |
| [postprocess](./postprocess/) | Scene colour grade, vignette, chromatic aberration, and RCAS integration, including the cutscene variant. |
| [effects](./effects/) | Bloom/lens dirt, light-shaft input, depth-blur resolve, interior glow, lens-flare composite, and native sharpening bypass. |
| [output](./output/) | Final PsychoV/grain, UI composition, and HDR encoding for normal and frame-generation output. |
| [native](./native/) | Unmodified decompiles grouped by the same responsibilities; `blur/` contains the two native DOF baselines. |

Shared helpers and the C++ settings/injection code stay at the mod root. The final PsychoV evaluation lives in the shared output helper, not in the early native tone-map replacements. Shader filenames retain their CRC/profile names. CMake and DevKit discover shaders recursively; keep the live shader path pointed at this mod's root.

| Replacement | Custom path |
|---|---|
| [tonemappers/0x382CDBDB.ps_6_6.hlsl](./tonemappers/0x382CDBDB.ps_6_6.hlsl) | Keeps exposure/adaptation and pre-curve alpha luminance; bypasses the native curve and transports exposed HDR. |
| [tonemappers/0x724E225F.ps_6_6.hlsl](./tonemappers/0x724E225F.ps_6_6.hlsl) | Transition variant: blends the two exposed HDR states and their native alpha luminance without applying a display curve. |
| [effects/0xDFD5C392.ps_6_6.hlsl](./effects/0xDFD5C392.ps_6_6.hlsl) | Spatial tint/highlight composite: removes the native RGB ceiling of 1.1 only in PsychoV mode, retaining depth-based tint, mask glow and alpha. |
| [effects/0xFB1B4062.ps_6_6.hlsl](./effects/0xFB1B4062.ps_6_6.hlsl) | Applies the native screen blend in bounded proxy space, then restores HDR. |
| [effects/0x7DC213EE.ps_6_6.hlsl](./effects/0x7DC213EE.ps_6_6.hlsl) | Independently scales the lens-dirt term and combined bloom contribution before exposure; leaves zero alpha unchanged. |
| [effects/0x5E320F6F.ps_6_6.hlsl](./effects/0x5E320F6F.ps_6_6.hlsl) | Bloom-only variant when native Camera Lens Effects is off; retains Bloom Strength control. |
| [effects/0x1132ADF9.ps_6_6.hlsl](./effects/0x1132ADF9.ps_6_6.hlsl) | Scales the depth-masked sky contribution feeding native light shafts once; retains alpha. |
| [effects/0x4B0ABFCA.ps_6_6.hlsl](./effects/0x4B0ABFCA.ps_6_6.hlsl) | Ports the old depth-blur radius control and blend weight; zero discards the pass. Vanilla retains the remaster output. |
| [luts/0x2F2D0992.ps_6_6.hlsl](./luts/0x2F2D0992.ps_6_6.hlsl) | Keeps exact packed LUT addressing, strength and gain; uses a luminance-axis gamut and N2 max-channel proxy with reconstruction. |
| [luts/0x90AD6BBC.ps_6_6.hlsl](./luts/0x90AD6BBC.ps_6_6.hlsl) | Two-LUT variant: preserves both packed LUT lookups and their native linear blend using the same HDR proxy/reconstruction. |
| [luts/0x0F6A9050.ps_6_6.hlsl](./luts/0x0F6A9050.ps_6_6.hlsl) | Independently graded two-LUT variant captured with frame generation: preserves each LUT's strength/gain and the final grade blend using the HDR proxy. |
| [effects/0x3650C210.cs_6_6.hlsl](./effects/0x3650C210.cs_6_6.hlsl) | Custom copy replacing the native sharpening dispatch only when Lilium RCAS is selected. Retains native sampling coordinates and alpha. No injected compute constants or layout changes. |
| [postprocess/0x16967617.ps_6_6.hlsl](./postprocess/0x16967617.ps_6_6.hlsl) | Post-grade variant without native CA sampling; adds optional RenoDX CA and preserves grade, vignette, levels and signed gamma-shaped HDR transport. |
| [postprocess/0x9600E32A.ps_6_6.hlsl](./postprocess/0x9600E32A.ps_6_6.hlsl) | Cutscene variant with native CA and no vignette. Applies RCAS before native/RenoDX CA, then the shared HDR-safe grade; preserves alpha. |
| [postprocess/0xF961D049.ps_6_6.hlsl](./postprocess/0xF961D049.ps_6_6.hlsl) | Cutscene post-grade variant without native CA or vignette. Adds the same RCAS/CA processing and HDR-preserving grade/transport; retains native alpha and levels. |
| [postprocess/0xC5AB358E.ps_6_6.hlsl](./postprocess/0xC5AB358E.ps_6_6.hlsl) | Texture-vignette variant of the same post grade. Preserves the native t2/s2 vignette lookup and adds the same HDR transport, RCAS and CA handling. |
| [postprocess/0xAD02BAB3.ps_6_6.hlsl](./postprocess/0xAD02BAB3.ps_6_6.hlsl) | Selects native or RenoDX CA sampling, preserves grade, vignette and levels, reconstructs the graded HDR signal and preserves signed gamma-shaped transport. |
| [output/0x8F5737B5.ps_6_6.hlsl](./output/0x8F5737B5.ps_6_6.hlsl) | Retains native display adjustment, overlay dimming, regional input, and secondary SDR composite. Restores scene HDR, retains the regional scene contribution and native colour matrix, applies PsychoV once, then scales/composites UI separately and writes PQ. |
| [output/0x496222DA.ps_6_6.hlsl](./output/0x496222DA.ps_6_6.hlsl) | Four-target frame-generation compositor: applies the same processing to presentation and separately maps the scene-only HDR output. Preserves the secondary composite and UI mask. |
| [output/0x9F54CB3F.ps_6_6.hlsl](./output/0x9F54CB3F.ps_6_6.hlsl) | Three-target FSR Frame Generation compositor: shares the same HDR processing, secondary composite and HUD-less output, without a fourth UI mask target. |

`common.hlsli` holds the tone mapper, grading extensions, and reversible proxy helpers. Regular and highlight saturation operate after PsychoV in its selected display gamut, preserving linear luminance and chroma direction. Positive saturation boosts approach the available chroma headroom smoothly; Blowout shares the bounded desaturation path. PsychoV receives neutral LMS purity so raising regular Saturation cannot push its response onto a hard gamut boundary. PsychoV receives the preserved exposed scene after grading, before UI composition; it does not reconstruct HDR from final SDR. Its BT.2020 result is represented in linear BT.709 and can contain negative channels. The LUT/presentation proxies accommodate those channels without raw SDR clipping.

`chromatic_aberration.hlsli` ports Ghost of Tsushima's exact axis-wise start mask, wavelength offsets, bilinear tap order and red/green delta composition. `lilium_rcas.hlsli` ports its luminance RCAS, including the 125-scene-white normalization, 0.99 overshoot limiter, noise attenuation and guarded luminance-ratio resolve. The texture adapter reads Witcher's already-linear BT.709 scene; GoT's intermediate decoding is not needed here. Every bilinear CA tap samples the sharpened image, including when native CA is selected.

The effect order matches Ghost of Tsushima: **RCAS -> CA -> perceptual grain**. RCAS and CA run at Witcher's full-resolution native post-process stage before final PsychoV mapping, so their scene highlights still roll off through PsychoV. Grain runs after PsychoV in display-linear BT.2020 at destination UVs, with scene white = 1, the same 0â€“0.03 strength and per-present random seed as GoT. UI is composed afterward. This uses Witcher's existing stages rather than GoT's separate post-upscale pass; sharpening and CA never sample grained pixels.

`test30.hlsl` is the game-local Ghost of Tsushima PsychoV-30 core. `output.hlsli` shares PsychoV and perceptual grain between regular presentation and both frame-generation HDR outputs. `lutsampling.hlsli` retains the native tiled LUT addressing and shares the original mod's range restoration across all three LUT variants. `postgrade.hlsli` shares signed grading and vignette handling across all five post-grade variants. `shared.h` is the 116-byte C++/HLSL payload at `b13, space50`; native resources remain in space0. CMake embeds twenty CRC-addressed replacements automatically. No swapchain/resource upgrades were added: the inspected scene targets are RGBA16F and output is already HDR10.

Settings injection is restricted to DX12 layouts exposing pixel-visible native `b3` and `b12` in space0 with room for the full 29-DWORD payload. Native push-constant layouts and incompatible layouts are left alone. Pixel replacement is deferred until draw time and requires a valid injection layout; the compute copy explicitly disables injection. Layout cloning is disabled after it caused a level-loading crash. Boolean controls and the three-way brightness-compensation selector use the settings framework's packed flags, freeing space for LUT/grade contribution controls. The native 33-DWORD layout plus 29 settings DWORDs and two native-bloom root-UAV DWORDs uses the full 64-DWORD budget. The Vanilla/PsychoV selector shares flag bit 5; its saved values remain 0/1. The three effect percentages share one packed DWORD, with seven bits per integer percentage. Preserve this budget when extending settings; the packed flags use bitwise float storage, not numeric float conversion.

## Native baselines

[native/README.md](./native/README.md) documents twenty-two regenerated native HLSL baselines, their SHA-256 manifest, restoration, and validation. They use `.hlsl.original` archive suffixes so CMake/DevKit do not discover them as replacements. Original CSOs and disassemblies remain under `tmp/thewitcher3remastered/`, outside the mod source folder.

See [SHADER_MAP.md](./SHADER_MAP.md) for resource/register contracts, supporting passes, and the original live investigation.

## Build and verification

From an x64 Visual Studio developer shell with Clang on PATH:

```powershell
cmake --preset clang-x64
cmake --build --preset clang-x64-release --target thewitcher3remastered
```

Output: `build/Release/renodx-thewitcher3remastered.addon64`. `build/thewitcher3remastered.include/embed/shaders.h` must contain the 35 active shader hashes, including video decoder 0x7EF4001F and FSR compositor 0x9F54CB3F; removed motion reconstruction passes must remain absent. Do not rebuild while this addon is loaded by the game.

Completed verification:

- Wide-gamut preservation (2026-10-06): removed the hidden negative-BT.709 clamp from all five analytic day/night grades, signed source projection from PsychoV, and channel/gamut limits from all three LUT-scaling paths. LUT lookup coordinates remain bounded through a reversible proxy; scene colours are reconstructed before tonemapping. Saturation increases follow PsychoV’s selected target and compression strength. Gamut Compression 0 skips projection, intermediate values blend, and 1 fully maps to BT.709 or BT.2020. Final BT.2020 HDR10 encoding still enforces nonnegative values and the selected peak. The retired gamut flag/setting is removed without shifting other flags or changing the 120-byte payload. All 32 production shaders pass strict DXC compilation, and Release builds successfully. WARP tests pass 4,098 grading/core configurations, exact Vanilla and nonnegative-source tone-map parity, zero/half/full grading contribution, signed LUT output, proxy restoration and selected-target/peak containment. Normal/FG wide-colour/UI checks pass 324 configurations. The real Release addon callback-cleanup test passes. See `tests/README.md` and scratch evidence `tmp/thewitcher3remastered/gamut-unclamped-20261006/`. After restarting, compare BT.709/BT.2020 at compression 0/0.5/1 in daylight, night foliage and candle scenes; check LUT blends, UI and frame generation. Live appearance remains to be verified.

- Second cutscene variant (`0x9600E32A`, 2026-10-01): the captured final scene pass was unregistered, so its native CA/grade bypassed custom sharpening and CA while final-pass grain remained active. Native baseline and forced-Vanilla replacement each match original DXIL exactly over 360 cases; signatures, bindings, buffer extent and intrinsic counts match. WARP execution of the new and existing native-CA variants over 24 configurations / 12,288 pixels shows exact effect parity with vignette disabled, finite output, preserved alpha, and independent measurable RCAS/CA response. All sixteen production shaders compile strictly. Addon rebuild/restart and visual verification remain pending. Evidence: `tmp/thewitcher3remastered/cutscene-oct01/`.

- Interior highlight clamp: native `0xDFD5C392` unconditionally limits each RGB channel to 1.1 before upscaling/LUT grading, including at zero effect strength. The native baseline passes strict compilation, exact signature/resource/intrinsic checks, and 360 differential cases. Another 720 cases verify exact Vanilla parity, unchanged alpha and removal of only the RGB upper ceiling. All fifteen production shaders compile strictly. The new hash requires an addon rebuild/restart for draw-time registration; DevKit marking it activated does not mean this addon executes an unregistered replacement. Integrated visual validation remains pending. Evidence: `tmp/thewitcher3remastered/dim-scene/`.

- Darken Only compensation: all fourteen shaders compile strictly. Differential execution covers 1,620 mode cases and 1,620 Vanilla comparisons across both scene shaders, Hable/AgX/bypass, both AgX responses and environment blends. Darkening, brightening and mixed-gain transitions are covered; the new mode never adds exposure relative to Off. Largest normalized reference error is below 7e-7. Payload size remains 120 bytes. Evidence: `tmp/thewitcher3remastered/darken-only/`. After relaunch, compare all three modes in Toussaint, at night and during weather transitions; Darken Only should match On when compensation darkens and match Off when it would brighten.

- LUT/gamut controls: all fourteen production shaders pass strict DXC compilation; the targeted Clang x64 Release addon builds successfully. WARP execution covers seven before/after shader pairs over 168 default/Vanilla configurations (largest normalized linear-domain difference below 5.6e-5), zero-contribution identity, half-contribution blending, lifted-black reduction in all three LUT variants, finite neutral/lifted/constant LUT scaling, signed wide-gamut output and independent vignette darkening. Thirteen root-layout checks and all 64 packed-flag combinations pass. Scratch evidence: `tmp/thewitcher3remastered/lut-controls/`. Integrated visual validation remains pending: in PsychoV compare both contribution sliders at 100/50/0, LUT Scaling at 0/100 in a lifted-black scene, and PsychoV’s compression strength/targets on saturated lights; also check existing packed controls, cutscenes, frame generation and Vanilla after relaunch.

- Current Release addon builds successfully and embeds all fourteen replacements, including the cutscene path, independent vignette controls and Native Brightness Compensation. The game-folder symlink points to this build.

- Native brightness compensation: a live Toussaint probe identified covered shader `0x382CDBDB`, AgX selector 1 and alternate response enabled. The original curve maps reference grey 0.18 to approximately 0.05498 (gain 0.30542, about -1.71 stops). Sentinel-checked alpha readbacks from two scene resources agree; EXR half precision limits the quoted values. The probe was unloaded and the prior live path restored. This confirms a discarded native brightness adjustment, but integrated visual validation of the optional correction remains pending. The user closed the game before the planned preview.
- All fourteen replacements compile strictly. Against the original/native reference curves, 324 cases verify compensation and per-state transition blending across Hable, both AgX response paths and bypass. Another 648 cases verify toggle-Off parity, and 324 verify Vanilla parity. Largest compensation error is below 7e-7 relative to max(1, reference). Twelve injection checks pass for the 30-DWORD payload, including exact root-budget boundary acceptance/rejection. Evidence: `tmp/thewitcher3remastered/native-brightness/`. After relaunch, enable Native Brightness Compensation in Toussaint and compare On/Off at fixed game/peak brightness; also verify environment transitions and UI brightness.

- Vignette black-floor revision: all fourteen replacements pass strict DXC compilation. With the toggle off, executable instructions match the prior shaders; with strength zero, both toggle settings compile identically. A WARP harness runs all three full post-grade shaders over 24 configurations / 12,288 pixels, testing finite output, monotonic darkening, black/alpha preservation and zero output at full texture-mask opacity even with native output-level lift. Twelve injection eligibility checks pass with the 30-DWORD payload, including the 64-DWORD root limit. Scratch evidence: `tmp/thewitcher3remastered/vignette-black/`. The Release addon includes this revision; live verification remains pending. Test Native/0 nits at several strengths in a dark vignetted scene after relaunch.

- Folder reorganization: all fourteen replacements compile with strict DXC settings before and after relocation and retain identical executable instructions. All fifteen native archives retain their SHA-256 hashes; `native/manifest.json` includes their relative paths. No shader behavior or injection layout changed. Evidence: `tmp/thewitcher3remastered/reorganize/validation.json`.

- Cutscene revision: the new `0xF961D049` native baseline passes strict compilation, signature/resource/400-byte extent and intrinsic-count checks, and 360 differential cases with exact agreement. The custom shader compiles strictly, and its forced-Vanilla instructions match that audited baseline exactly. Native RCAS bypass and final HDR/grain shaders are already covered in this capture. After rebuilding/relaunching, compare Native/RenoDX CA and RCAS strengths in this cutscene. No native vignette exists in this variant, so Vignette Strength has no effect here. Evidence: `tmp/thewitcher3remastered/cutscene/`.

- Vignette control revision: all thirteen shaders pass strict DXC compilation. At strength 100, all three post-grade variants retain their previous executable DXIL; removing flare scaling matches its previous strength-100 executable DXIL. The injection payload remains 116 bytes. The Release addon includes this revision; for live verification, compare Vignette Strength 100/0/50 with PsychoV, confirm Vanilla ignores the control, and check both frame-generation modes. Scratch evidence: `tmp/thewitcher3remastered/vignette/validation.json`.

- Frame-generation revision: all thirteen replacements pass strict DXC compilation, and the Release addon embeds all thirteen hashes. The two new native baselines and forced-Vanilla branches each pass 360 differential cases. Extracting the shared output helper leaves the normal compositor's executable DXIL unchanged.
- A WARP harness executing the normal and frame-generation compositor HLSL checks 108 configurations / 55,296 pixels across peak, grain, regional-view and UI settings. The first two targets match normal presentation exactly; the scene-only PQ output is finite, bounded and independent of UI brightness/alpha; the UI mask remains exact. Evidence is in `tmp/thewitcher3remastered/framegen/`. Integrated frame-generation validation remains pending relaunch: select PsychoV, test Saturation 50/0/50 with frame generation on, then compare on/off, peak response and independent UI brightness.

- Ten regenerated baselines pass DXC `ps_6_6`, HLSL 2021, `-Ges -WX`; signatures, resource bindings and cbuffer sizes match the originals.
- Differential execution of original and recompiled DXIL with synthetic texture/constant inputs passes 360 cases per baseline. This covers all main-tone-map blocks, but does not cover every output-shader branch or emulate GPU texture filtering.
- Forced-Vanilla versions of all eight edited shaders pass the same differential check against the original DXIL. Custom injection references disappear when this branch is folded off.
- The grading helper round-trips black, midgray, HDR and signed wide-gamut examples with small floating-point error.
- All eight replacements pass strict compilation with `-enable-16bit-types`; the Clang Release addon builds and embeds all eight.

Live testing exposed missing hair and broken scene rendering even with the five original CSOs active as temporary overrides. A subsequent layout-cloning build crashed during level loading and was withdrawn. With injection restricted to compatible post-process layouts, the user confirmed successful level loading and expected scene/hair rendering on 2026-09-29. The runtime log shows two extended layouts with complete 20-DWORD injection and no oversized-injection warning; DevKit captured 2273 draws and now exposes texture bindings. Twelve offline eligibility checks also cover missing/wrong-stage bindings, native constants, truncated payloads and the root-signature budget boundary. The broader HDR checks below remain outstanding.

The daytime/environment transition variant `0x724E225F` is covered alongside `0x382CDBDB`; the user confirmed the previously inactive grading controls respond. Both native baselines and their forced-Vanilla replacements pass 360 differential cases, including all 133 original blocks in the transition variant.

Highlight ordering was verified live on 2026-09-29. The native bloom composite `0x7DC213EE` uses additive blending into RGBA16F immediately before the exposure/tone-map stage. The original custom implementation applied PsychoV too early: later screen blending and grading could raise its mapped highlights into the final peak clamp. Keeping HDR through those stages and mapping only at final scene composition removed the observed plateau. At the 1000-nit setting, separate live captures changed from 16,345 pixels at the output cap (8,064 white-clipped) to zero, with the brightest channel around 936 nits. The user confirmed substantially better highlight detail. These were live readbacks, not a frozen temporal A/B; EXR half conversion also limits numerical precision. The final clamp remains a safety bound rather than the intended scene tone curve.

The candle-scene capture additionally uses `0x90AD6BBC` (two blended LUTs) and `0x16967617` (post-grade without CA sampling). Both were uncovered native paths; the LUT variant independently clamps HDR channels into its SDR lookup domain. Applying the existing proxy/reconstruction around both stages improved the flame bands in a temporary forced-custom capture. That diagnostic did not isolate every cause: subsequent testing reproduced a separate saturation-control failure with these variants already covered. The unchanged baselines and forced-Vanilla edits each pass 360 differential cases with exact agreement. The initial guarded live overrides did not change the image: these hashes need registration in the addon to receive settings injection. Temporary forced/probe overrides were unloaded. Both variants are now embedded in the Release addon; the integrated runtime check after relaunch remains pending. The original candle ROI had no pixels at the final peak cap, so this color artifact is distinct from the earlier outdoor peak-clamp plateau.

The game-local PsychoV core also stops a nonpositive shadow grade at black before restoring LMS signs. Previously, strong shadow darkening could make the scalar grade negative; `CopySign` then reflected its magnitude into visible light, producing inverted/lifted shadows. A scalar grading sweep across 424,907 combinations of input brightness, shadow darkening and adaptation anchor verifies nonnegative, monotonic darkening. All eight shaders pass strict compilation. The neutral grading branch is unchanged; the in-game shadow-slider check remains pending relaunch.

Saturation was checked independently after the user reproduced candle clipping with Highlight Saturation at 50. Raising regular Saturation previously extrapolated LMS purity before PsychoV's hard target projection, pinning additional bright colors to the gamut hull. Highlight Saturation separately modified OkLab chroma after projection and could drive channels beyond the peak or below zero. Both now use a luminance-preserving display-gamut grade, with a rational shoulder on the additional chroma. A D3D11 WARP harness executing the HLSL tested 294,912 samples across 12 color ramps, both gamuts, 400/1000/4000-nit peaks and independent saturation combinations. At full gamut compression, output remained within the target cube to 1e-5 relative tolerance; neutral outputs were bit-identical, and luminance/chroma-direction errors were below 5e-7 of peak. All eight DX12 shaders passed strict compilation. The user confirmed the live revision works; the Release addon includes the fix.

Earlier readbacks of the shared RGBA16F post-process target are not isolated tone-map outputs: that resource is reused later in the frame. Do not use those statistics to assign a change to a specific earlier pass.

The CA revision passes strict compilation for all eight shaders. A WARP test compares the port against GoT's source with both texture adapters set to linear BT.709 and sharpening disabled: 120 configurations and 245,760 pixels match exactly, including edge sampling, disabled settings and blue-channel preservation. With Native CA forced, the two edited post shaders retain their previous executable DXIL instructions apart from cbuffer extent and branch hints. Twelve injection eligibility checks pass with the enlarged payload; the two observed native root layouts would use 56 and 33 DWORDs, below the 64-DWORD limit. Evidence is under `tmp/thewitcher3remastered/ca-peak/`. Automatic peak detection and CA still need an integrated runtime check after relaunch.

After relaunch, check the detected Peak Brightness and Reset behavior, then compare Native/RenoDX CA in PsychoV-30 mode. Test Intensity 0 and 5, move Start Offset from 0 toward 0.95, and repeat with the game's CA setting on/off. RenoDX should replace native fringing, preserve the center according to Start Offset, and leave UI edges unaffected. Vanilla should retain the game's own CA behavior. Restart when updating this revision: its 92-byte settings buffer is incompatible with live overrides running against the previous 80-byte addon.

The user confirmed peak detection and CA work in game. The subsequent RCAS/grain revision passes strict compilation for all nine shaders. WARP execution matches GoT's RCAS/CA code exactly across 486 configurations and 248,832 pixels with matching linear BT.709 adapters. Black/flat neighborhoods remain stable, grain is finite and leaves black unchanged, and zero grain is exact passthrough. The custom native-sharpen bypass preserves signed HDR and all four channels across 20 dispatch sizes, including partial tiles. Twelve layout eligibility checks pass with 27 DWORDs; the observed root budgets become 60 and 37 DWORDs. Effects-off final-output instructions match the preceding shader after normalizing cbuffer extent; the two post shaders add redundant integer tap clamps through the RCAS loader, with numerical equivalence covered by the reference test. Evidence: `tmp/thewitcher3remastered/fx/`.

For the RCAS/grain runtime check, relaunch with the new 108-byte addon, select Lilium RCAS, and sweep Strength from 0 to 100 with both native and RenoDX CA. Toggle the game's sharpening setting to check that it no longer stacks. Then sweep Perceptual Film Grain with sharpening/CA enabled: grain should animate without colored fringing, while UI remains clean. Check Vanilla, native sharpening, black, bright candles and motion with the chosen upscaler. Those integrated checks remain pending.

The subsequent bloom/flare capture uncovered `0xC5AB358E`, a texture-vignette post variant that was still processing exposed HDR through native grading. It now receives the same grade proxy/reconstruction and RCAS/CA path as `0x16967617`. Bloom and Sun Flare strength are independent gains at their respective native composites, before final PsychoV; the existing Color Grading Flare setting is unrelated. A zero sun-flare setting returns the unmodified scene sample, avoiding even a proxy roundtrip.

Both new native baselines pass strict compilation, binding/signature/400-byte cbuffer audits and 360 differential cases with exact agreement. Forced-Vanilla edits retain the native executable instructions, and forced-100 bloom/flare retain their preceding instructions. All eleven shaders compile strictly; twelve injection checks pass with the larger 29-DWORD payload (observed root totals: 62 and 39). Evidence: `tmp/thewitcher3remastered/bloom-flare/`. Temporary live flare/bloom bypasses were restored. The user saw little change from flare removal and a slight improvement from bloom removal, but the uncovered post variant prevents attributing the objectionable glow to either effect alone. After relaunch with the 116-byte addon, verify HDR grading/RCAS/CA in that scene, then compare each slider at 0/100/200 independently with a fixed camera. Default/Reset/Vanilla equivalence and the final visual result remain to be checked in game.

For live testing, first load the archived unchanged baselines from a separate scratch live folder and compare against native. Then test the addon with native HDR enabled, verifying Vanilla/Off, PsychoV, black/midgray, highlight gradients, saturated emissives, LUT transitions, CA/vignette, menu/UI white, and peak controls. Check photo/regional views, menus/video and frame-generation on/off separately. Verify `b13, space50` injection and the secondary output's consumer if any of these paths differ.

### Native effect controls (2026-10-01)

Live setting comparisons identified both DOF passes in gameplay, the sky-mask/light-shaft chain, and the bloom+dirt/bloom-only pair. Archived frame-generation captures use the same DOF, shaft and bloom hashes; both archived cutscene captures use the same bloom+dirt hash. These effects run before final post grading/output, so repeating their strength in each grading variant would apply it twice. Similarity review of 526 archived binaries found no additional matching effect variant. Uncaptured cutscene-specific DOF remains a runtime coverage limit.

All 20 production shaders and 19 archived native baselines pass strict DXC compilation. Five edited passes pass 360 differential cases each against original DXIL at default strength and in Vanilla; zero/half-strength checks cover removal/scaling, including lens dirt retaining base bloom. Settings tests cover 30,603 packed percentage transitions and 12 injection-layout checks, including the 64-DWORD boundary. Addon C++ syntax validation passes with existing shared-header warnings. Evidence: `tmp/thewitcher3remastered/effect-controls/`.

Build `thewitcher3remastered` with `clang-x64-release` after closing the game, then verify each slider at 100, 50 and 0 in gameplay and cutscenes, with native effects enabled and PsychoV-30 selected. Also verify Bloom Strength while Camera Lens Effects is disabled. The user is handling the addon rebuild; these changes have not yet been validated in the rebuilt addon.

### Original-mod effect parity correction

The old `depth_blur_0x0C19D45C` corresponds to remaster `0x4B0ABFCA`. It scales only the non-sky radius and outputs `saturate(accumulated_alpha * 25)`. The captured remaster shader instead outputs zero alpha, while the captured blend state uses source alpha; changing radius alone therefore cannot expose its RGB. PsychoV now restores the original-mod blend weight and radius behavior. The preparation shader `0x29754CAF` is left native, as in the old mod. Zero Blur explicitly discards both depth branches. This intentionally differs from remaster native behavior; Vanilla is unchanged.

Old lens dirt `0xB2EC52E3` maps to `0x7DC213EE`; the dirt-texture multiplier matches. Old sunshafts `0x0B6D0F0A` and remaster `0x1132ADF9` both multiply the masked source RGB, although the old mask also contains a sun-disc term absent from this remaster variant. No separate active sun-flare slider was found in the old mod: its control is Sunshafts Strength. The old bloom control scales a Gaussian filtering pass and consequently also affects shafts. The remaster retains its existing final additive Bloom Strength control rather than multiplying shared filtering passes repeatedly.

The replacement Blur passes 360 synthetic comparisons against the old mod's shader at unit strength (with its moved `b12` field remapped), and forced Vanilla still matches original remaster DXIL. All 19 production shaders compile strictly; packed-setting and layout checks pass. Evidence: `tmp/thewitcher3remastered/legacy-effects/`. Runtime responsiveness of sunshafts/lens dirt still needs a connected DevKit session; source equivalence alone does not prove that the game executes these replacements.

### Split contrast controls (2026-10-02)

Highlight Contrast and Shadow Contrast appear in Advanced Color Grading with PsychoV-30 selected. Each uses 0–100, default/reset 50, mapped to an exponent multiplier of 0–2. The appropriate multiplier above/below gamma-adjusted 18% scene luminance multiplies overall Contrast, matching the split-contrast math in `re9requiem` and `007firstlight`. Grading scales RGB by a luminance ratio before PsychoV's finite response, keeping the grey pivot, signed colour ratios, and final peak rolloff. Exposure, existing Highlights/Shadows, and the PsychoV response retain their current order. Both controls at 50 preserve previous rendering.

The percentages occupy bits 7–13 and 14–20 of `mode_flags`. Existing flags and the effect percentages retain their fields; payload/root-layout size is 116 bytes/29 DWORDs. Preset Off resets both to 50. Regular and both frame-generation HDR branches use the same helper, with UI composed afterward.

The `clang-x64-release` build of `thewitcher3remastered` passes and produces `build/Release/renodx-thewitcher3remastered.addon64`. All 19 production shaders also pass strict DXC compilation and addon C++ syntax validation. WARP tests cover 882 configurations/451,584 samples across BT.709/BT.2020 targets, 400/1000/4000-nit peaks, both full slider ranges and three overall contrast settings: independent regions, fixed grey/black, monotonic greys, signed colour/reference agreement, and bounded display gamut/peak. All 18 neutral comparisons preserve previous shader output exactly. Maximum normalized reference error is below 4.2e-6. Packing checks cover 232,704 contrast transitions and 3,257,856 flag writes; 12 layout checks still pass. Evidence: `tmp/thewitcher3remastered/split-contrast/`. After rebuilding, verify the controls separately in a bright outdoor scene and a dark interior, then reset both to 50.


### Perfect Black vignette strength (2026-10-03)

The original Witcher mod blends toward zero with at most 1x native opacity.
The remaster's 2x control previously saturated that opacity, erasing partially
vignetted corners. Perfect Black now retains the previous 0-50 response and
uses transmittance^(strength/50) above 50. At 100, twice the optical density
darkens progressively without prematurely reaching zero. Native-colored mode,
strength-zero behavior, default-strength appearance, and alpha are unchanged.

All five post-grade shaders compile strictly. WARP checks cover 2,800 settings /
2,867,200 before/after pixels, including native and perfect-black modes, radial
and texture masks, output-level lift, grading contribution and signed gamut.
Unchanged paths match exactly; black stays black, darkening is monotonic and
partial masks retain detail. Reference error is below 4.5e-7 normalized.
Scratch evidence: tmp/thewitcher3remastered/vignette-soft/. Build target:
thewitcher3remastered, clang-x64-release. After relaunch, compare Perfect Black
at strength 50/75/100 in the affected scene; visual validation remains pending.

PsychoV candle highlights: signed cone coordinates now use the continuous odd
extension of the existing finite response. Switching to a separate curve at
zero caused internal flame bands after wide-gamut grading. Positive-cone
contrast, adaptation anchors and selected-gamut projection are preserved.
After restarting, compare the paused candle scene at Cone Response Exponent
1.0 and Hue Shift 0/100, then check other emissive colours and both gamut targets.


Photo Mode uses the same unclamped HDR grading
controls as gameplay. Its exposure, contrast, white balance, saturation,
grain and vignette remain available; HDR highlights and signed colours reach
PsychoV before the separate Photo Mode UI is composited. The game's HDR
Saturation setting is ignored under PsychoV, including UI and Frame Generation
outputs. Vanilla retains the game's saturation adjustment.

After rebuilding `thewitcher3remastered` in `clang-x64-release`, compare gameplay
and Photo Mode with the UI visible, then check Photo Mode exposure/filter controls.
Changing the game's HDR Saturation must have no effect under PsychoV.




Bloom extraction uses the active native exposure and tone curve as its
reference, including both environment states and their transition blend.
The exposure pass captures those parameters in a small GPU buffer; extraction
evaluates the four source taps through the native curve before averaging.
There is no fixed ceiling at 1. Native thresholds, knee, caps and filters remain
unchanged, while the main HDR scene reaches PsychoV without that tone curve.
Masked sunshafts use the same reference and retain their mask/strength control.
Missing captures or zero exposure gain retain the previous safe bounded fallback.
No CPU readback or descriptor heap tracking is added.

This reconstructs the native curve at extraction: intervening DOF has already
filtered the HDR source, so nonlinear native tonemapping and DOF are not exactly
commutative. It is not a duplicated native DOF render chain. After rebuilding,
check bloom/sunshafts at 0/50/100, environment transitions, saturated emissives,
Photo Mode DOF, and Vanilla. Native curve and GPU handoff checks pass; visual
validation of the rebuilt addon remains pending.


The textured-vignette/chromatic-aberration post-grade variant `0x2BF760E2`
now follows Color Grading Strength and preserves signed HDR colour through
the final tonemapper. After a Release rebuild, compare the affected scene at
grade strength 0/50/100 with LUT Grading Strength held fixed, then check
vignette, native/custom CA, sharpening and Vanilla. GPU and native-baseline
checks pass; rebuilt visual confirmation remains pending.
