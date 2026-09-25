# Ghost of Tsushima DIRECTOR'S CUT — RenoDX

A Direct3D 12 mod for the PC version of **Ghost of Tsushima DIRECTOR'S CUT** in both SDR and native HDR. It replaces the game's scene tone curves with **PsychoV-30** and retains the game's LUT-based artistic grading. HDR has separate scene and UI brightness controls; SDR keeps the native HUD and its in-game brightness control.

The mod also corrects HUD and video colors for BT.2020 output, uses a fixed Rec.709 encode / gamma 2.4 decode for HUD and video without adding SDR EOTF emulation to PsychoV, and offers optional perceptual film grain, Lilium RCAS sharpening, and UE5-style chromatic aberration. These changes are implemented in the game's shaders, before the completed frame is presented.

The addon is `renodx-gotsushima.addon64`. It detects the game's SDR or HDR swapchain when the game starts.

## Getting started

1. Use an x64 ReShade installation with addon support configured for the game's D3D12 executable, `GhostOfTsushima.exe`.
2. With the game closed, place `renodx-gotsushima.addon64` in ReShade's configured addon directory. In the development installation, the addon link sits beside `GhostOfTsushima.exe`.
3. If upgrading from the former `ghostoftsushima` mod, remove `renodx-ghostoftsushima.addon64` from that directory. Load only one copy of this game addon. The displayed addon name and saved RenoDX setting keys are unchanged.
4. Start the game in SDR or native HDR, open the RenoDX panel, and select **PsychoV-30**. The red **Recommended** button applies the mod's recommended grading values.
5. In HDR, set **Peak Brightness** for your display and adjust **Game Brightness** and **UI Brightness**. In SDR, PsychoV's peak is fixed at 203 nits; adjust **Game Brightness** in RenoDX and HUD brightness in the game.

In HDR, the UI brightness override replaces the native HUD brightness multiplier on supported color draws. In SDR, HUD and video draws keep their native behavior and RenoDX's UI Brightness control is disabled. Selecting **Vanilla** restores the original scene shaders and native brightness behavior.

## Controls and presets

### Main controls

| Control | Default | Purpose |
|---|---|---|
| Tone Mapper | PsychoV-30 | Chooses Vanilla or PsychoV-30 in either output mode. |
| Peak Brightness | Detected HDR display peak when available; otherwise 1000 nits | Sets the custom HDR output ceiling. SDR fixes the shader peak at 203 nits and retains the saved HDR setting. HDR range: 400–4000 nits. |
| Game Brightness | 203 nits | Sets scene reference white. Range: 80–500 nits. |
| UI Brightness | 203 nits | Sets HUD, menu, and supported video reference white in HDR (80–500 nits). Disabled in SDR, which uses the game's HUD brightness setting. |
| Perceptual Film Grain | 0 | Adds animated, luminance-dependent scene grain. Range: 0–100; 0 disables it. |
| Lilium RCAS Sharpening | 0 | Sharpens scene detail with noise attenuation. Range: 0–100; 0 disables it. |
| Chromatic Aberration | Off | Enables UE5-style scene color fringing, before HUD composition. |
| CA Intensity | 1.00 | Red/green separation strength, from 0–5. Zero bypasses the effect. |
| CA Start Offset | 0.00 | Unaffected central region, from 0–0.95. Higher values confine fringing to the edges. |

The custom brightness, grading, and effect controls operate with PsychoV selected. **Advanced** settings expose exposure, gamma, highlights, shadows, contrast, saturation, highlight saturation, blowout, flare, hue shift, and PsychoV's response/gamut parameters. The grading **Gamma** control remains an optional creative adjustment; there is no SDR Gamma Emulation control.

**Color Filter**, at the bottom of Color Grading, controls the native matrices/LUT grade's color contribution from 0–100 (default 100). At 0, colors come from the scene before those grading stages; scene lighting, fog, and upstream local processing remain. The fully graded result still supplies luminance, so removing the filter does not remove the LUT's brightness or contrast curve. Recommended and Reset All restore 100.

In HDR, PsychoV defaults to a BT.2020 gamut target, full gamut compression, and automatic compression power. SDR uses a BT.709 gamut target and Compression 2.0 by default. Adaptation and Background Anchor default to 0.1800, which preserves the calibrated baseline. Each slider scales its corresponding input or output anchor by `value / 0.18`; it does not move the LUT calibration samples. Both sliders have four-decimal precision. Cone Response Exponent defaults to 1.0 in SDR and 1.17 in HDR, multiplying the contrast calibrated to the native SDR scene curve **before LUT grading and the native display transform**. Hue Shift defaults to 100 in HDR and 50 in SDR. In HDR, 0 retains PsychoV's baseline hue and 100 restores the native scene/LUT hue in OKLab. The reference uses the actual native HDR scene curve and both matrices, the native square-root LUT shoulder/reconstruction, and the active LUTs and per-pixel blend. It is decoded in the same linear domain as PsychoV's input; it does not replay the downstream native rational display transform, so exact final-output hue identity is not guaranteed. Restoration covers all brightness levels rather than only strong cone-response differences. It rotates hue at fixed chroma/lightness ratio and explicitly restores PsychoV's physical luminance. If the result exceeds the selected gamut/peak, only chroma is reduced at the restored hue and luminance. Nearly neutral references fade out the correction to avoid unstable hue from LUT noise. SDR retains the previous response-side A2 control and its existing 0�100 behavior.

### Native SDR output

Start the game with its HDR setting off. The addon detects the `r8g8b8a8_unorm` swapchain, fixes PsychoV's shader peak at 203 nits without overwriting the saved HDR peak, and keeps the same color grading, bloom, sharpening, chromatic aberration, and film grain controls. Restart the game after changing its HDR setting. Vanilla retains the game's original SDR shaders.

Six PsychoV controls have separate SDR defaults: Hue Shift **50**, Highlights **50**, Blowout **0**, Flare **0**, Cone Response Exponent **1.0**, and Compression **2.0**. Their HDR defaults are **100**, **42**, **10**, **60**, **1.17**, and **Auto/0**, respectively. The sliders remain adjustable, and their SDR and HDR values are saved separately for each RenoDX preset. All other defaults are shared across output modes.

The SDR scene shader `0x24A0E87E` preserves local scene processing, the two color matrices, LUT sampling, and artistic LUT blending. PsychoV bypasses the native component-wise SDR rational curve and clamp before the LUT, uses the same linear-light LUT shoulder and calibration as HDR, and maps the SDR LUT's already-linear result to the fixed SDR peak. Unlike the HDR LUT result, the SDR LUT result must not be sRGB-decoded again; that double decode caused crushed midtones and excessive saturation in the first SDR build. The PsychoV scene is adapted to the game's native BT.709 final transfer before composition. SDR HUD and video shaders retain their original output and native brightness multiplier, including translucent and multiply overlays.

The SDR output shader `0x571EE768` keeps the game's native BT.709 output transfer. Before composition, PsychoV's linear scene is encoded with the inverse of that transfer so the displayed scene has a standard sRGB response. The HUD enters the same compositor unchanged and receives the original native output transfer. Effects run after upscaling on the full-resolution scene, before gameplay HUD; with no HUD, the output shader applies the same effects to its scene-only input. Map UI drawn directly into the pre-upscale scene target is excluded, matching the HDR path.

### SDR in HDR reference

Select **SDR in HDR** in Tone Mapper while keeping native HDR enabled. This comparison mode reproduces the game's SDR shader response in a BT.2020/PQ HDR container, with fixed **203-nit white** and **gamma 2.2** for both scene and HUD. It does not extend SDR highlights or expand the SDR gamut.

All mod brightness, gamma-emulation, color-grading, PsychoV, grain, and sharpening controls are disabled and bypassed in this mode. The grading preset and reset buttons are disabled as well. Their saved values are retained; switching back to PsychoV restores their effect. The native artistic LUT grade remains part of the SDR reference.

For a comparison at matching reference white, use default Color Grading and PsychoV30 settings, set PsychoV's Game Brightness and UI Brightness to 203 nits, then switch between PsychoV-30 and SDR in HDR on the same scene. PsychoV deliberately omits the native SDR display transform's additional contrast, so its scene shadows and midtones can be brighter even at matching white. The named grading presets further change the calibrated response. The reference retains its fixed gamma 2.2 display response. It is an SDR display response, applied once before PQ encoding.

The reference restores the SDR scene curve captured from `0x24A0E87E` at RootSrt offsets 344–364. Live SDR/HDR captures confirmed that these coefficients differ between modes while the surrounding color matrices match. It clamps the curve before the second matrix, retains the square-root LUT input and native LUT blends, and bypasses both HDR LUT shoulders and the native HDR scene brightness multiplier. It also restores the SDR scene dither amplitude.

Scene and HUD stay in the SDR composition domain until final output. Ordinary UI draws bypass the native HDR brightness scale without applying the PsychoV UI conversion; multiply overlays retain their native blend behavior. After composition, the output pass reproduces `0x571EE768`'s neutral SDR transfer (sRGB decode followed by the BT.709 OETF), decodes those display codes with gamma 2.2, converts linear BT.709 to BT.2020, and encodes PQ at 203 nits.

The mode uses the captured SDR curve and neutral SDR output calibration. It retains the HDR path's 10-bit intermediate and existing upscaler, rather than recreating every 8-bit resource and rounding step of the native SDR renderer. It is therefore a color/tonal reference, not a promise of identical SDR screenshot bytes. In-game calibration changes, temporal effects, and upscaling can also affect comparisons.

### Preset buttons

Values below are the numbers shown in the UI.

| Setting | Recommended |
|---|---:|
| Cone Response Exponent | 1.15 |
| Highlights | 45 |
| Shadows | 80 |
| Blowout | 5 |

The red **Recommended** button restores the remaining Tone Mapping, Color Grading, and PsychoV30 settings to their current defaults, including Peak Brightness and Hue Shift. It preserves **Game Brightness**, **UI Brightness**, and all **Effects** settings. Tone Mapper and Settings Mode also remain selected. Peak Brightness resets to the detected display default when available, otherwise 1000 nits. Recommended is available only with PsychoV selected and is not applied automatically on startup. The former Match native preset has been removed.

**Reset All** resets the settings marked as resettable, including both effects. It retains the selected Tone Mapper and Settings Mode. **Preset Off** explicitly selects Vanilla and restores the native effects.

## Rendering pipeline

### Native pipeline

The game's scene postprocessing applies local exposure and spatial effects, color matrices, a component-wise HDR curve, and LUT grading. Its LUT lookup uses square-root-encoded RGB and a max-channel shoulder. The result is scaled into a bounded RGB10A2 intermediate, where HUD/video draws are composited.

The final shader, `0x53EBE0F3`, then applies a scalar rational display curve, a BT.709-to-BT.2020 matrix, an approximate output encoding, and dither. Scene and UI therefore share the native final display transform: the native HUD multiplier does not directly express an absolute brightness in nits.

The native rational response is not a simple, exact gamma-2.4 power function. The PsychoV route bypasses that final curve and approximate encoding, as well as the earlier component-wise HDR curve.

### PsychoV pipeline

The diagram shows the HDR branch. SDR uses the same scene and effects placement, but the SDR LUT output is already linear. Its PsychoV scene is adapted for the native BT.709 final transfer at a fixed 203-nit peak, while HUD/video shaders remain native.

```mermaid
flowchart TD
    A[Linear scene input] --> B[Native local processing and color matrices]
    B --> C[Linear LUT shoulder, native LUT grade, reconstruction]
    C --> T[sRGB LUT decode to linear]
    T --> D[Grade-calibrated PsychoV-30 and display roll-off]
    D --> CF[Optional Color Filter blend at fixed graded luminance]
    CF --> E[BT.2020 and gamma-2.2 transport]
    U[HUD and video colors] --> V[Rec.709 encode, gamma 2.4 decode, BT.2020, gamma-2.2 transport]
    E --> AA[Temporal reconstruction / upscaling]
    AA --> CA[Full-resolution Sharpening then CA then Film Grain]
    CA --> F[Existing scene and UI composition]
    V --> F
    F --> G[Peak limiting, PQ output and dither]
```

The two scene shaders, `0x313ABA52` and `0x43D9A412`, preserve the native upstream processing and both color matrices while bypassing the HDR curve between those matrices. Both retain native LUT addressing and blending; `0x43D9A412` also retains its per-pixel LUT blend mask.

**PsychoV runs after LUT grading.** The curve before the LUT controls lookup coordinates and their reconstruction; it does not replace the post-LUT display tone mapper.

Below Color Filter 100, both scene shader variants also evaluate PsychoV on an identity-grade reference before the native color matrices and LUTs. This reference retains the selected decoding, user grading, and existing calibration. HDR native-hue restoration applies to the fully filtered branch before this color blend; Color Filter 0 therefore does not reintroduce the native grade through Hue Shift. After tone mapping, its chromaticity is normalized to the fully graded output's linear luminance and blended with the graded color. Chroma is reduced toward neutral only as needed to fit the selected gamut and peak, preserving that luminance. This occurs before grain and HUD composition; HUD/video colors and Vanilla/SDR-reference modes are unaffected. Values below 100 cost an additional PsychoV evaluation but no additional LUT samples. At 100 the reference evaluation and blend are bypassed.

### Linear-light LUT shoulder

[GhostGetLUTSamplingScale](common.hlsli) replaces the entire native max-channel LUT shoulder in the PsychoV branch. The native shoulder remains available in Vanilla.

The replacement is an anchored C-infinity shoulder with these parameters:

| Parameter | Value |
|---|---:|
| Peak | 1 |
| Anchor | `0.475² = 0.225625` |
| Compression strength | 1.5 |

The anchor preserves the native identity threshold after converting it from square-root space to linear light. Below the anchor the scale is exactly 1. Above it, the maximum channel approaches the LUT boundary smoothly without the native curve's finite plateau.

For linear maximum channel `x`, anchor `a`, range `r = 1 - a`, and `x > a`:

```text
d = x - a
w = exp2(-r / (1.5 * d))
compressed_max = a + r * d / (r + d * w)
lookup_scale = sqrt(compressed_max / x)
```

The native square-root RGB coordinates are multiplied by `lookup_scale`, then passed through the game's existing LUT sampling and blending. The LUT result is divided by that same scale and clamped nonnegative. Its output encoding is distinct from the square-root input coordinates: the HDR LUT result is sRGB-decoded to linear, whereas the SDR LUT result is already linear. Neither route squares the LUT result. PsychoV omits the native SDR output's BT.709 OETF. The HDR decode does not clamp to SDR white, so reconstruction retains HDR headroom. Black and values at or below the shoulder anchor bypass the scale divisions.

This keeps the LUT's artistic grade while allowing HDR brightness reconstruction outside the LUT's bounded coordinate range. It does not invert or remove the LUT's own color grading.

The native matrices on either side of the bypassed scene curve are retained, but they are not inverses. Real scene captures confirmed that their combined output can contain negative channels before LUT sampling. PsychoV now fits these colors toward neutral at constant linear BT.709 luminance until the lowest channel reaches zero, instead of clipping individual channels. Already nonnegative colors pass through unchanged. This preserves the RGB chroma direction and pre-LUT luminance while reducing out-of-gamut saturation; it does not recover the full signed color through the bounded LUT or guarantee unchanged luminance after artistic LUT grading. The HDR-side gray calibration uses the same fit. Native and SDR-reference paths retain their original behavior.

### PsychoV, gamut, and HDR transport

The local [PsychoV-30 implementation](test30.hlsl) receives a linear LUT result: sRGB-decoded in HDR and directly from the LUT in SDR. This signal interpretation is fixed; no optional SDR display-EOTF emulation is added before or after PsychoV. PsychoV supplies the custom scene display response.

PsychoV intentionally omits the native BT.709 OETF followed by display decoding. That combination darkens shadows and midtones; preserving it is useful for an SDR reference but is no longer the custom scene's target. This is a deliberate presentation choice to soften the native contrast, not a claim that BT.709 encoding paired with a display EOTF is inherently erroneous. The original square-decode approximation is not restored. SDR in HDR and the validated HUD/video path retain their native SDR display transfer.

The baseline input anchor is measured by passing a fixed neutral scene value of 0.18 through the native matrices, reconstructable LUT shoulder, active LUT blend, and direct LUT decode. The baseline output anchor passes the same fixed scene value through the captured native SDR curve and grade instead. Both calibration routes omit the native SDR display transform, so anchor matching cannot add its contrast back. Anchor calibration includes the masked shader's local blend weight and uses luminance anchors to avoid imposing a new white balance.

Contrast calibration samples at +/- 1/64 stop around that fixed reference **without the artistic LUT**, retaining the native matrices, scene curve, and fixed sRGB decode. Their logarithmic slope ratio supplies PsychoV's baseline cone response; flat or reversed scene-curve segments fall back to unit slope. Previously this ratio used two different neighborhoods of the artistic LUT. A nearly flat HDR-side neighborhood could make the ratio enormous even for a monotonic LUT, producing excessive contrast and saturated edges. The LUT still supplies the color grade and both anchor levels, but no longer controls the contrast multiplier through that unstable division.

The anchor sliders scale those baseline anchors only after calibration. This keeps the default 0.18/0.18 appearance while preventing slider movement from crossing LUT slope changes or toggling the calibration fallback. Adaptation Anchor generally darkens the scene as it increases; Background Anchor generally brightens it. PsychoV's normal dependence of highlight/shadow shaping and automatic compression on the anchors remains. Calibration can still change with the game's active LUT, blend mask, or matrices.

This matches the gray anchors through the active SDR grade and the contrast of the native scene curve before LUT grading; it does not target the completed SDR image or reproduce every colored pixel exactly. The SDR reference remains available for comparisons across scenes and LUT transitions. Calibration now adds two grade evaluations per pixel, each sampling one or two LUTs depending on the active blend, plus four curve evaluations without texture reads.

User gamma, contrast, and flare extensions operate on luminance before PsychoV. User Contrast is kept out of PsychoV's contrast argument to avoid its purity rescaling amplifying quantization into colored bands; calibrated slope is supplied through the cone-response exponent instead. Highlight saturation and blowout are applied through the output grading extension.

PsychoV can constrain colors to BT.709 or BT.2020, but returns its result represented in linear BT.709 coordinates. A valid BT.2020 color can have negative components in that representation. The mod preserves those components until conversion to BT.2020 so that wide-gamut colors are not prematurely clipped to BT.709.

With Compression set to Auto/0, PsychoV uses an internal peak of at least 4000 nits to retain highlight gradients before fitting them to the selected display peak. An anchored finite-range Reinhard shoulder scales linear RGB uniformly using the BT.2020 maximum channel. It is identity below its knee, joins with unit slope, and maps the working peak exactly to the display peak. The knee is scene reference white, or half the display peak when that is lower. This replaces the previous finite-input endpoint stretch; the wider PsychoV response can also affect tones below the knee, even though the subsequent shoulder leaves them unchanged.

Positive Compression values retain direct PsychoV evaluation at the selected peak. At peaks of 4000 nits or higher, Auto needs no additional range compression. The result is converted to BT.2020, optionally grained, scaled by Game Brightness, and encoded for gamma-2.2 composition. No SDR display-EOTF emulation is applied at this stage.

A gamma-2.2 BT.2020 signal carries HDR through the existing bounded RGB10A2 intermediate. Scene and HUD share a transport scale equal to the larger of Peak Brightness and UI Brightness, while their physical brightness is set independently before encoding. At final output, `0x53EBE0F3` decodes this transport to nits, uniformly scales colors whose maximum channel exceeds Peak Brightness, encodes PQ, and adds native dither with a final clamp to the selected PQ peak. This encoding/decoding pair does not apply another display grade. Intermediate filtering, blending, and 10-bit quantization do depend on its encoding.

## HUD, menus, and video

The conversion described below applies to native HDR output. In SDR, the HUD/video color replacements are bypassed, the native brightness multiplier remains active, and the native SDR final transfer is kept.

### Color and brightness

All 51 HUD/video replacements share [ui.hlsli](ui.hlsli). Ordinary color draws bypass the native HUD scale (`b12.c8.w` or `b0.c16.z`, depending on the shader family) and use this sequence:

1. Recover the unpremultiplied SDR color where required.
2. Decode sRGB, unless the original shader has already produced linear RGB.
3. Apply the native SDR output's Rec.709 OETF, then decode the resulting display codes with a fixed gamma of 2.4.
4. Convert linear BT.709 to BT.2020, scale to UI Brightness in nits, and encode into the common gamma-2.2 composition domain.
5. Restore RGB coverage for premultiplied output, preserving the original output alpha.

The native SDR output shader, `0x571EE768`, includes an sRGB decode followed by the BT.709 OETF. Omitting that conversion makes midtones and weaker color channels too bright, washing out the HUD. A capture of the native SDR swapchain confirmed this transfer against the preceding UI buffer. The mod reproduces it on UI colors before composition encoding; it does not apply the native HDR rational display curve.

The linear gamut conversion retains BT.709 primaries in the BT.2020 output container. HUD and video use fixed Rec.709 encoding followed by gamma 2.4 decoding, independently of scene grading. Black and reference white remain fixed, so UI Brightness continues to control white independently of the scene.

Native texture sampling, masks, clipping, depth fades, tinting, and alpha behavior remain in the individual shaders. `0x6A947342` uses the helper's linear-input option because it already decodes its texture. Its RGB coverage is separate from its destination-attenuation alpha, preserving the shader's additive contribution.

### Multiply overlays and the dark-box fix

A shader hash can be used for ordinary UI color draws and destination-color multiply draws. [IsUIColorDraw](addon.cpp) checks the actual pipeline blend state for every registered HUD/video hash. Draws using source/destination color factors retain the native shader instead of receiving the color conversion.

For the observed destination-color blend:

```text
result = destination * (source + 1 - alpha)
```

The neutral source is `source = alpha`. Encoding that multiplier as a display color would change its neutral value and darken the entire quad, exposing a rectangle around otherwise invisible UI geometry. Keeping the native multiplier fixes the box while ordinary color draws still receive the brightness and gamut correction.

Composition uses gamma-2.2-encoded BT.2020 rather than PQ. PQ blending made partially covered dark strokes much too dark: analytically, 50% black over 203-nit white produces about 8.9 nits in PQ, versus 44.2 nits in gamma 2.2. Moving PQ encoding to final output restores a power-law blending response closer to the native encoded compositor, without changing alpha, coverage, opaque HUD colors, or the scene tone mapper. This remains an approximation to native blending, since vanilla blends in BT.709 before its display curve. The HUD uses a fixed Rec.709 encode / gamma 2.4 decode response; the gamma-2.2 composition encoding serves blending and transport independently.

### Video handling

The four [video shaders](video/) preserve the game's YUV-to-RGB coefficients and their existing masks and fades, then use the same UI color pipeline. Video colors therefore receive the BT.709-to-BT.2020 correction and follow UI Brightness.

`0x85013553` also mixes a constant tint after the native brightness scale and adds output dither. Its replacement expresses the tint in the video's unscaled domain before mixing, using the tint directly if the native scale is zero. The completed color then goes through the UI helper. Its straight-alpha smoothstep fade is unchanged, and dither stays after PQ encoding.

## Optional scene effects

**Bloom Intensity** scales the native bloom extraction output before the blur pyramid and scene tone mapping. The native threshold, limiter, blur shape, and reconstruction weights remain intact; scaling all packed color components together preserves their relative color. This controls the bloom contribution without scaling the separately generated lens flares.

Bloom Intensity ranges from 0% (disabled) to 200%, with 100% preserving native intensity. It is active only with PsychoV; Vanilla and SDR in HDR retain native bloom. Recommended preserves the selected intensity, while Reset All and Preset Off restore 100%. Lens flares use the original game shader without a replacement.

**Lilium RCAS** runs on decoded linear BT.2020 at reconstructed display resolution, after temporal AA/upscaling. It retains the 125-scene-white HDR normalization, 0.99 overshoot limiter, noise attenuation and bounded luminance-ratio resolve. The normalization is expressed relative to Game Brightness in the composition domain; luminance uses BT.2020 weights. Black and flat neighborhoods are guarded. Each texel is sharpened before CA interpolates displaced red/green samples, so the combined pass implements sharpening followed by CA rather than sharpening already interpolated fringes. See [lilium_rcas.hlsli](lilium_rcas.hlsli).

**Chromatic aberration** uses the inward red/green sampling pattern in the repo's decompiled UE5 Hellblade 2 (`0x189339AE`) and Oblivion Remastered (`0x99B126EC`) shaders, with blue undisplaced. Start Offset thresholds each centered screen-coordinate axis, matching those shaders' shape rather than using a circular mask. Red and green use wavelength differences of 147 and 85 nm relative to blue, with a 0.007 dispersion coefficient and percent intensity. This recreates UE5-style scene fringe within Ghost's pipeline; it does not reproduce UE5's entire camera/tonemapping pipeline. Epic documents the corresponding [Intensity and Start Offset controls](https://dev.epicgames.com/documentation/unreal-engine/post-process-effects-in-unreal-engine).

The effect runs in a separate full-resolution pass after temporal reconstruction/upscaling and before the first full-resolution HUD draw following a scene pass. The earlier pre-upscale implementation caused moving edges to shimmer even with DLAA: its displaced channels entered temporal reconstruction with unshifted depth and motion vectors. The new pass copies the gamma-2.2 BT.2020 composition target, reconstructs taps in linear light, disperses BT.709 red/green channels, and returns to the same composition encoding. Blue stays undisplaced and alpha is preserved. HUD draws follow the effect. RCAS precedes this sampling; perceptual film grain follows it.

With visible HUD, the effects share one full-resolution scene copy and fullscreen draw. With hidden HUD, the final output shader runs the same effects helper on its scene-only input before PQ encoding, matching the pre-HUD RGB10A2 quantization. The internal per-output flag prevents double application and is reset for the next scene/output. The pass runs when any effect is enabled: sharpening and grain work independently of the CA toggle. Vanilla, SDR in HDR, and all-effects-off bypass it. Offscreen UI layers are excluded by scene ordering, dimensions and format. Scratch textures and descriptors remain tied to the game target; native graphics state and D3D12 root bindings are restored before HUD rendering. See [post_effects.hlsli](post_effects.hlsli), [chromatic_aberration.hlsli](chromatic_aberration.hlsli) and [lens.hpp](lens.hpp).

**Perceptual Film Grain** runs last, after sharpening and CA, in linear BT.2020 at output resolution. It retains the shared film-density response, Game Brightness as reference white, the existing 0-0.03 strength mapping, and the per-present random seed. The noise is generated at the destination pixel after all displaced sampling, so it is neither sharpened nor split into color fringes. It is no longer generated in the scene tonemapper or passed through temporal reconstruction.

The effect order is **Sharpening -> CA -> Film Grain** for both HUD paths. The later HUD/video overlay draws remain unaffected. Upstream native effects and final PQ dithering remain in place. Enabling RCAS with CA adds sharpening work for each bilinear fringe tap; the combined shader avoids an additional render target and pass.

## Source layout and development

The canonical mod folder and CMake target are **`gotsushima`**.

| Path | Responsibility |
|---|---|
| [addon.cpp](addon.cpp) | Settings, presets, shader registration, blend-state guard, display-peak detection, and grain seed binding |
| [shared.h](shared.h) | 120-byte C++/HLSL injection structure at `b13, space50` and gamma composition configuration |
| [hue.hlsli](hue.hlsli) | HDR native scene/LUT hue reference and fixed-luminance hue/gamut restoration |
| [common.hlsli](common.hlsli) | LUT shoulder, PsychoV integration, display roll-off, grain, and output helpers |
| [test30.hlsl](test30.hlsl) | Local PsychoV-30 tone mapper |
| [intermediate.hlsli](intermediate.hlsli) | Shared scene/UI gamma-2.2 transport encoder |
| [ui.hlsli](ui.hlsli) | Shared HUD/video color and brightness conversion |
| [sdr.hlsli](sdr.hlsli) | Captured native SDR curve and shared SDR display transfer |
| [lilium_rcas.hlsli](lilium_rcas.hlsli) | Scene sharpening |
| [chromatic_aberration.hlsli](chromatic_aberration.hlsli) | UE5-style scene fringe and consistent RCAS sampling |
| [tonemappers/](tonemappers/) | 2 HDR scene/LUT shaders and 1 SDR scene/LUT shader |
| [output/](output/) | Final HDR10 and SDR output shaders |
| [hud/](hud/) | 47 HUD/menu shader variants |
| [video/](video/) | 4 YUV video shader variants |
| [effects/](effects/) | Native bloom extraction intensity control |

All 59 game-shader replacements retain their hash/profile filenames. CMake discovers the folders recursively and generates the embedded registration list.

### Build and live development

Close the game before building its deployed addon. Use **Release**, with compatible game-addon and DevKit configurations:

```powershell
# Configure when setting up the checkout or changing the addon target.
cmake --preset vs-x64
cmake --build --preset vs-x64-release --target gotsushima
```

The addon is written to `build.vs/Release/renodx-gotsushima.addon64`. Generated shader binaries, headers, and `shaders.h` are in `build.vs/gotsushima.include/embed/`.

Keep vanilla dumps and `.cso` archives outside the source tree to avoid duplicate hashes shadowing editable replacements. Live shader replacement has crashed this game during testing. Use Release builds loaded at game startup for shader changes, and use DevKit for read-only captures and inspection. Changes to `shared.h` also require rebuilding the C++ addon.

The local development installation uses an addon symlink to the Release binary, so a successful build updates the deployed file. The former `ghostoftsushima` source folder and deployed addon link have been replaced by `gotsushima`.

### Validation and future regression checks

The map HUD investigation found ordinary straight/premultiplied-alpha draws in the scene intermediate and full-resolution composite, plus an OptiScaler sharpening pass between them. Disabling OptiScaler sharpening did not resolve the heavy borders. The gamma-composition correction passed strict compilation of all 54 shaders and a Release build, with all forced Vanilla and SDR-reference binaries unchanged. Numerical checks verified transport roundtrips and black-over-white coverage across 15 display/UI-white combinations. Runtime validation is pending: compare map icons, text, panels, multiply overlays, UI fades, videos, scene gradients, and fire highlights; repeat with the usual upscaler and optional effects.

The Auto highlight-rolloff revision passed strict compilation for all 54 shaders and a Release build. Forced Vanilla and SDR-reference scene binaries remain unchanged. Numerical sweeps across 21 white/peak combinations verified monotonicity, bounded output, the knee, and exact endpoint mapping. Applying the shoulder offline to a 4000-nit fire capture retained gradients while reaching approximately 1000 nits after 10-bit PQ quantization. This is a simulation on an animated capture, not runtime confirmation. Retest the fire at 1000 nits and Compression Auto/0, then check ordinary scenes, saturated highlights, manual Compression, and peak settings above and below 4000 nits. The final output peak guard remains for HUD composition and effect overshoot.

In-game checks have confirmed that the UI, video colors, brightness controls, gamma response, fades, and overlay composition look correct and behave as expected with the addon. The current implementation has passed strict shader compilation and the Release build. Moving the mod to `gotsushima` preserved all 54 compiled shaders byte-for-byte.

The subsequent HUD transfer correction was checked against native SDR and PsychoV captures of the settings menu. At UI Brightness 203 nits and gamma 2.2, converting the HDR capture back to comparable SDR display codes reduced the sampled red tile's mean error from 12.4 to 0.56 on an 8-bit scale, with the white reference unchanged. The user confirmed the improved appearance in game. All 51 affected HUD/video shaders passed strict compilation, and the Release addon build passed. This comparison covers the captured menu; translucent blends and other screens still need the checks below.

For subsequent shader changes, recheck scene highlights and LUT transitions; HUD/video colors and transparency; independence of Game Brightness and UI Brightness; native HUD-slider override; gamma-emulation modes; both optional effects; and restoration of the native paths with Vanilla/Preset Off. Include the chosen upscaling mode when checking scene effects.

For direct LUT decoding, check shadows and midtones against the SDR reference at matching white, expecting a softer scene response rather than an exact SDR match. Also check highlight headroom, all gamma settings, both LUT shader variants, transitions, and HUD consistency. Synthetic neutral-LUT checks assess anchor matching, local slope, black, monotonicity, and HDR headroom; they do not establish an image match with the game's artistic LUTs.

The direct-decode revision passed strict compilation for all 54 shaders and the Release build. Only the two scene shader binaries changed; the output and all 51 HUD/video binaries remained identical to the preceding build. Fixing either scene shader to Vanilla or SDR in HDR also produced unchanged binaries. Across 27 synthetic LUT/gamma/peak cases, the gray anchor matched exactly, local slope error stayed below 0.1%, and the response retained black, monotonicity, and HDR headroom. Visual confirmation of this revision remains pending.

The independent-anchor revision passed strict compilation for all 54 shaders and the Release build. Fixing both anchors at 0.18 produced scene binaries identical to the preceding version for PsychoV, Vanilla, and SDR in HDR. Synthetic neutral-response sweeps across the full anchor range at 0.0001 increments remained finite, bounded, and monotonic. In game, compare the default 0.1800/0.1800 appearance, then adjust each anchor separately and together on a fixed scene; repeat with the Recommended preset's highlight/shadow settings. Non-default saved anchor values now scale the calibrated anchors instead of selecting different LUT calibration samples.

The user tested the independent-anchor Release build in game and confirmed that both sliders now adjust smoothly.

The pre-LUT contrast-calibration correction passed strict compilation of all 54 shaders and a Release build. Both scene shaders remain byte-identical in forced Vanilla and SDR-reference modes. A synthetic monotonic LUT reproduces an old contrast multiplier above 150 while the corrected multiplier remains approximately 1.08; this demonstrates the numerical vulnerability, not a measurement of the affected game's LUT. Runtime verification should revisit the foggy scene at Cone Response 1.0 with optional effects off, then check ordinary scenes and LUT transitions. The user confirmed that lowering Cone Response to 0.5 mitigated the original issue; visual confirmation of the correction is pending.

The post-upscale chromatic-aberration revision passed strict compilation for 55 replacement shaders and two locally authored fullscreen shaders, plus the Release addon build. CA-off, Vanilla and SDR-reference scene variants match the GitHub baseline byte-for-byte; the other original shaders are unchanged. The user confirmed that the relocated effect looks correct in motion in the reported problem scene, and the ReShade log confirms that the post-upscale pass executes. A startup resource-tracker initialization error found during the first test was corrected before this successful run. For future changes, recheck DLSS/DLAA motion at CA 0.2 / Start Offset 0.5, effect toggling, UI/map overlays, resolution changes, photo mode with HUD hidden, and other upscalers.

For SDR in HDR, verify that white remains 203 nits, all mod grading/effect controls are disabled, previously saved extreme settings do not affect the reference, and switching back restores the PsychoV settings. Compare the same scene and map/menu against native SDR at matching white and gamma 2.2. The reference shaders passed strict `ps_6_6` compilation and the `vs-x64-release` build; temporary diagnostic shaders are excluded from the finished addon.

The initial reference-mode map capture reached 202.9 nits after HDR10 quantization, with no NaN/Inf pixels. The static legend panel differed from the native SDR capture by an average of 0.44 equivalent 8-bit code values. The map projection and animated background changed between captures, so these results do not establish a scene-wide pixel match. Compiling the scene and output shaders with reference mode fixed removed all injected grading-buffer dependencies. The user confirmed that the new mode worked in game.

Reusable vanilla HLSL and audit metadata from local development remain in `tmp/ghostoftsushima/vanilla/ui/`, with original shader binaries in `tmp/ghostoftsushima/original/`. These are local development artifacts, not required installation files or guaranteed contents of a fresh checkout. The archived candidate shaders are not all registered: output masks and procedural noise passes require composition evidence before adding a color transform.

Color Filter validation: all 54 shaders passed strict `ps_6_6` compilation. With the added unused injection field excluded from the binary comparison, Filter 100 reproduces the preceding shader binaries. Numerical checks of the post-tone-map blend covered 192,000 combinations, including black, gamut boundaries, both gamut targets, and multiple peaks, retaining luminance to double-precision rounding. The addon rebuild and visual check are pending: build `cmake --build --preset vs-x64-release --target gotsushima`, then sweep Color Filter from 100 to 0 on a fixed tinted scene with grain off. Verify changing color with stable scene luminance, unchanged HUD, and reset to 100 through Recommended/Reset All. The injection layout grew to 112 bytes, so rebuild the addon rather than loading only the modified shaders.

The superseded source-direction Hue Shift revision mapped the UI's 0�100 range to a bounded 0�1 blend from PsychoV's baseline angular midpoint toward the source direction. It preserves the finite response radius and existing brightness/gamut solve; output gamut limits and subsequent Blowout grading still constrain the final color. Neutral/degenerate colors and the signed-cone fallback retain their existing handling. That Ghost-specific source-direction behavior has now been replaced by the response-side extrapolation used in Resonance Legacy. All 54 shaders passed strict compilation, and Hue Shift 0 plus Vanilla/SDR-reference binaries remain unchanged. Numerical positive-cone sweeps checked the source endpoint, monotonic movement without overshoot, and response-radius preservation. Release rebuild and runtime verification remain pending: compare Hue Shift 0/50/100 on flames and red objects with Color Filter at 100 and Blowout/Highlight Saturation neutral, then repeat with the desired grading.

## Credits

Game integration and tuning by **Hartapfel**. RenoDX framework, shared color/effect utilities, and PsychoV-30 by **Carlos Lopez / ShortFuse**. RCAS sharpening uses **Lilium's** luminance adaptation, with integration references from the Crimson Desert and Nioh 3 mods.


## Optional AMD UI diagnostic build

Compile the existing Release target with `GOTSUSHIMA_UI_DIAGNOSTICS=1` to enable `diagnostics.hpp`. It logs `[GHOST-UI-DIAG v2]` entries to ReShade.log without changing shader binaries or the existing HUD blend guard. The normal build excludes the diagnostic code.

In a dedicated PowerShell process:

```powershell
$env:CL = "$env:CL /DGOTSUSHIMA_UI_DIAGNOSTICS=1"
(Get-Item src/games/gotsushima/addon.cpp).LastWriteTime = Get-Date
cmake --build --preset vs-x64-release --target gotsushima
```

Copy the resulting addon to a separate diagnostic file. In a fresh shell without that compiler flag, touch addon.cpp again and rebuild the same Release target to restore the normal local build. MSBuild does not reliably invalidate an existing object when only the compiler environment changes. Close the game before either build.

For the AMD test, temporarily replace the regular Ghost addon with the diagnostic; load only one Ghost addon. Enable native HDR and PsychoV-30, open the affected map/menu, then hold UI Brightness at 80, 203 and 500 for at least three seconds each. Exit and return the complete ReShade.log before relaunching. No DevKit is required. Logs include GPU IDs, shader registration/creation, HUD acceptance and blend factors, injection/replacement readiness, sampled UI/parsed/CPU-bound settings and bounded draw summaries for ten minutes. CPU readiness is not proof of GPU execution. Initial replacement readiness can be false before lazy creation.

Validation: diagnostic and normal x64 Release builds passed; the diagnostic has no Debug CRT dependency; all 54 embedded shader binaries match the normal build. The user confirmed the metadata correction on AMD with diagnostic v2.


Standalone HUD metadata correction: the AMD diagnostic log matched 11 HUD/video hashes, but every observed draw was rejected with `decision=missing_blend` while injection/replacement readiness was true. UI Brightness changes also reached the CPU binding. The guard reads cached pipeline subobjects; the shader utility retains these only when shader caching or asynchronous replacement is enabled. DevKit enables caching, hiding this dependency during development. Ghost now explicitly enables `renodx::utils::shader::use_shader_cache` before attaching the shader utility. The existing multiply-draw guard is unchanged, and no shader hash or color math changes are required.

Both corrected Release builds passed and all 54 shader binaries remain identical between normal and diagnostic builds. Diagnostic v2 adds the cached subobject count. Verify without DevKit: UI Brightness should affect HUD/video, ordinary draws should report `blend_found=1` and `allowed=1`, and multiply draws should still be rejected. Check menus for the prior dark rectangles. The user confirmed that diagnostic v2 fixed the issue on AMD. The normal Release addon was then rebuilt with diagnostics disabled; all 54 shader binaries are unchanged and diagnostic markers are absent.


Bloom Intensity: the extraction shader passed strict compilation, and fixed 100% PsychoV intensity plus forced Vanilla/SDR-reference variants compile identically to the recompiled vanilla baseline. The lens-flare control and shader replacement were removed after reported artifacts, restoring native flare rendering. Runtime verification: vary Bloom Intensity through 0/100/200 on a fixed scene, check unchanged HUD and native lens flares, and confirm native bloom in Vanilla/SDR in HDR. Recommended should preserve the bloom value; Reset All should restore 100%.


Fixed transfer revision: removed SDR Gamma Emulation from the UI, presets, and injection data. PsychoV input and anchor calibration use fixed sRGB LUT decoding. HUD/video use Rec.709 encoding followed by gamma 2.4 decoding before gamut conversion, brightness scaling, and coverage restoration. The existing gamma-2.2 composition transport, multiply-draw guard, and fixed gamma-2.2 SDR reference remain unchanged. Rebuild the gotsushima Release target after the injection layout change. Runtime check: compare scene gradients and HUD/video midtones, sweep UI Brightness, and check premultiplied edges and multiply overlays. Older saved ToneMapGammaCorrection values are no longer read.

Validation: all 55 shaders passed strict compilation and the Release addon built successfully. All 55 forced Vanilla and SDR-reference shaders remain byte-identical after normalizing the removed injection field. Both PsychoV scene shaders match the previous None-emulation route with the same layout normalization. Visual confirmation of the new fixed UI response remains pending.


Response-side Hue Shift revision: restored the same 0-2 internal blend and response-direction target as Resonance Legacy/APT Requiem. All 55 shaders passed strict compilation and the gotsushima Release build. Only the two scene shader binaries changed; forced Vanilla, SDR-reference, and Hue Shift 0 scene variants remain byte-identical. Ignoring comments and whitespace, the local PsychoV-30 shader now matches Resonance Legacy. Runtime check: compare Hue Shift 0/50/100 on bright flames with Blowout neutral, then check other saturated colors and both target gamuts. Visual verification of this restored behavior is pending.

Extended Hue Shift range: 0-500, default 100, using the same 0.02 multiplier and a shader weight cap of 10. All 55 shaders passed strict compilation; only the two scene shaders changed. Forced Vanilla, SDR-reference, and Hue Shift 0/50/100 variants remain byte-identical to the preceding version. Direction sweeps through weight 10 stay finite, rotate monotonically, and preserve the normalized response radius. In game, compare 100/200/300/500 on flames and other saturated colors; gamut projection still bounds the result.

The HUD-hidden CA fallback adds one internal injection float (116 bytes total). All 57 shaders pass strict compilation. With the fallback disabled, CA disabled/zero, Vanilla, or SDR reference forced, the output shader matches the preceding output binary after removing the unused appended field. The user confirmed correct behavior while alternating visible/hidden HUD and testing motion. The runtime log confirms both the pre-HUD pass and the HUD-hidden output fallback execute. Recheck those transitions and HUD clarity after future changes.

The post-upscale effects relocation passed strict compilation of all 57 shaders and the Release build. After normalizing the internal fallback field name, only the two scene shaders, final output shader and custom effects pixel shader differ. Forcing all effects off produces binaries identical to the preceding no-effect paths. The user confirmed correct appearance for sharpening/grain with CA disabled, all three together, visible/hidden HUD, and motion with temporal upscaling; the HUD remains clean.


Post-upscale effects routing: the command list that records the scene owns pre-HUD effects eligibility, including continuation after an early PQ output. Another map/UI recording cannot consume that eligibility merely because its target has the same size and format. Separate one-use reservations cover the first scene-only PQ encode and the additional DLSS frame-generation output when these are recorded on different command lists. Consuming an output reservation never grants permission to process a later HUD target. Reservations expire on owner reset/destruction, a new scene, swapchain initialization, or full-resolution HUD composition. Sharpening -> CA -> Film Grain is unchanged.

Map/UI exclusion: the captured map path draws tiles directly into the pre-upscale scene target. That branch bypasses the post-upscale effects pass and cancels both scene-only PQ reservations. Captured gameplay HUD paths use a separate composition target and retain effects. The output fallback decision is stored per command list and uploaded with a local settings copy, so parallel recording cannot overwrite another draw's switch through the shared user settings.

Validation: twenty extracted callback branch/lifetime scenarios pass, including early map UI on another recording, returning to gameplay, and independent output decisions during interleaved scene recording. The output shader remains byte-identical to the preceding version under strict compilation. Recheck the map with frame generation off/on, then gameplay with the HUD visible and completely hidden, including an FG toggle. The Release addon was verified in game: the user confirmed stable map rendering and working gameplay effects after the map exclusion and output injection correction.


HDR native-hue restoration validation: all 59 shaders pass strict compilation. Forced SDR, Vanilla, SDR-reference, and HDR Hue Shift 0 scene variants remain byte-identical to the preceding version. A 15,000-case numerical sweep checks luminance preservation, the reference hue endpoint, both target gamuts, and bounded output, including signed BT.709 representations of BT.2020. Runtime checks: compare HDR Hue Shift 0/50/100 on fire, cloth, red banners and ordinary foliage; include masked LUT transitions, Color Filter 0/100, and both gamut targets. Recheck SDR's unchanged control. The reference costs one additional LUT sample, or two when the native blend is active, only when HDR restoration is enabled. Visual matching and GPU performance still require in-game verification.
