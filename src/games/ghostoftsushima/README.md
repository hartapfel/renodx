# Ghost of Tsushima

Enable native HDR in the game. With PsychoV selected, **UI Brightness** controls
HUD/menu white independently of Game Brightness, overriding the native HUD
brightness multiplier. Its default is 203 nits and its range is 80–500 nits.
Vanilla and Preset Off restore native HUD behavior.

The red **Recommended** button before **Match native** resets Color Grading
and PsychoV30 to their defaults, then applies Cone Response Exponent 1.15
and Highlights 44. Like Match native, it preserves tone mapping and brightness
settings. Check it after changing grading values or using Match native.

### Optional scene effects

The **Effects** section adds **Perceptual Film Grain** and **Lilium RCAS
Sharpening**, each ranging from 0 (off) to 100. Both default to off and are
enabled only with PsychoV. Recommended and Match native preserve these effect
settings; Reset All and Preset Off turn them off.

Both scene variants (`0x313ABA52` and `0x43D9A412`) use this order:

1. Sample the linear scene at the native distorted UV and apply Lilium RCAS.
2. Run the existing local exposure/spatial processing, LUT grade, and PsychoV.
3. Apply RenoDX perceptual grain to the linear, display-mapped BT.2020 color.
4. Apply SDR Gamma Emulation, scene-white scaling, PQ encoding, and native dither.
5. Composite HUD/UI, then run the existing final HDR10 output pass.

RCAS uses the luminance implementation from the Crimson Desert/Nioh 3 mods:
four source-texel neighbors, HDR normalization of 125, the 0.99 overshoot
limiter, noise attenuation, and a bounded luminance-ratio resolve. Black and
flat neighborhoods bypass unsafe divisions. All five samples come from the
same linear source; mixing post-PsychoV center color with pre-PsychoV
neighbors would give incorrect contrast. Sharpening precedes the added grain.

Grain uses the shared `renodx::effects::ApplyFilmGrain` density response with
BT.2020 luminance weights and scene white as its reference. The random utility
updates its seed once per present. Native dithering and any upstream game
grain/sharpening remain in place. HUD/UI shaders and the final composed-frame
shader do not apply either new effect.

These are scene-pass effects, not a new pass at swapchain resolution: RCAS's
neighborhood follows the source texture size, and grain follows the scene
output grid. The earlier capture did not establish a later scene-only pass
after all resolution changes. Check appearance with native resolution and
the selected upscaler, especially grain size and any stacked sharpening.

All 53 shaders passed strict DXC compilation and the `vs-x64-release` addon
build after the injection buffer grew to 96 bytes. Runtime verification is
pending: compare each effect at 0, 50, and 100 on a stationary scene, check
animated grain, black areas, highlights, image edges, HUD text and translucent
menus, then verify that zero strength and Vanilla restore the previous image.

The PsychoV scene path uses an anchored C-infinity shoulder on the linear
maximum channel for LUT sampling. Its peak is 1, anchor is `0.475² = 0.225625`
(the native shoulder's identity threshold converted to linear light), and
compression strength is 1.5. The square root of the compressed/original
maximum ratio scales the gamma-2.0 LUT coordinates. The same scale is divided
out after native LUT sampling and blending, before decoding to linear and
running PsychoV. This replaces the native sampling curve's finite plateau
while preserving brightness reconstruction, LUT addressing, and masks.
The complete native sampling-shoulder block runs only in the Vanilla branch;
PsychoV uses only the replacement curve. Check bright neutral and
saturated gradients and LUT transitions in game when validating this change.
The shoulder change passed strict compilation of all 19 shaders, the
`vs-x64-release` addon build, and numerical checks for monotonicity, bounds,
black/anchor behavior, and colored identity-LUT brightness reconstruction.
In-game visual validation of this shoulder is still pending.

The 51 HUD/UI replacements use `ui.hlsli`. Ordinary color draws bypass
`b12.c8.w`, or `b0.c16.z` for the bindless UI family.
Premultiplied colors are unpremultiplied before the color transform and
premultiplied again afterward. The helper decodes SDR UI colors, applies the
same forward SDR Gamma Emulation operation as the scene, converts BT.709 to
BT.2020 in linear light, and encodes PQ at the selected UI white. None uses the
sRGB response; 2.2 and BT.1886 use the scene's 2.2 and 2.4 emulation modes.
`0x6A947342` already decodes its texture to linear light, so it uses the
helper's linear-input option. Its RGB coverage is kept separate from its
destination-attenuation alpha, preserving its additive contribution.

### Additional UI shader coverage

The dump review added 34 color-output variants, including masked, clipped,
depth-faded, straight-alpha, filtered texture, and YUV video-texture paths.
Their original texture sampling, tinting, masks, discards, and output alpha
are retained. Every added hash uses the same blend-state callback as the
original HUD replacements.

Reusable vanilla HLSL is stored locally outside the live shader tree in
`tmp/ghostoftsushima/vanilla/ui/`. Its `manifest.json` records 57 baselines,
original dump paths, byte lengths, SHA-256 hashes, and baseline audit results.
Original binaries are preserved in `tmp/ghostoftsushima/original/`.
Do not copy these vanilla baselines or binaries into the live mod folder.

Six related candidates are archived but not replaced without render-target
and composition evidence:

| Hashes | Reason for separate investigation |
|---|---|
| `0x2371FE0A`, `0x7C2278BF`, `0x834EFFF9`, `0xA0F21C2B`, `0xA30D7C35` | Replicate a sum of RGB into all channels; may be mask/extraction variants rather than display colors |
| `0x14A3103E` | Procedural monochrome/noise output with a squared response |

The review used 3,523 existing SM6 pixel-shader decompilations and attempted
the remaining 2,546 SM6 pixel dumps. Some unrelated/complex shaders still
fail decompilation; this is not proof of complete UI coverage. The new 34
baselines passed strict compilation and signature, interpolation, binding,
control-flow, and sampling checks. Changes in repeated constant loads,
handle annotations, redundant initial output stores, and duplicate max
operations were reviewed as compiler differences. All 53 mod shaders passed
strict DXC compilation and the Release addon build, with all hashes embedded.
The game's addon symlink resolves to that verified Release binary.
In-game verification of the new variants is pending;
check map/menus, masked transitions, depth-faded markers, and video panels.

`0x85013553` is now also replaced following the report of oversaturated video.
Its native YUV-to-RGB coefficients, red-channel blend, UV bounds, and
straight-alpha smoothstep fade are preserved. In the PsychoV branch, the
video bypasses `cbufGlobal_264`; the constant tint, which is blended after
that multiplier in vanilla, is divided by the same scale before blending.
This preserves the native color mixture in units of UI white. At zero native
scale the tint is used directly to avoid an undefined division.
The existing UI helper then decodes SDR, applies the selected gamma response,
converts linear BT.709 to BT.2020, and encodes PQ at UI Brightness. Native
dither remains after encoding. Alpha is unchanged, and the same blend-state
callback excludes destination-color multipliers. The archived vanilla HLSL
and CSO remain unchanged. Check video colors, tint transitions, fades,
UI Brightness, and Vanilla in game; visual validation is pending.

### Composition and multiply overlays

The native pipeline is:

1. Scene postprocess/LUT output, scaled by the game's scene constant.
2. HUD texture/tint/mask draws, scaled by their native HUD constant and blended
   into the scene intermediate.
3. `0x53EBE0F3`: a scalar rational display curve, BT.709-to-BT.2020 matrix,
   approximate PQ encoding, and dithering.

HUD values before step 3 are **not PQ**. Both scene and HUD pass through the
same native display transform, so the HUD constant does not directly specify
absolute nits. Its visible brightness depends on that shared transform and
the native scene/HDR settings. The custom pipeline instead writes BT.2020 PQ
from the scene and ordinary HUD shaders and bypasses the native display curve
at step 3. The RenoDX UI slider controls HUD white in absolute nits.

A DevKit menu capture on 2026-09-09 showed:

| Draws | Shader | RGB blend |
|---|---|---|
| 593 | `0x313ABA52` | Scene output; blending disabled |
| 594–601, 603 | `0x9D97A7C7` | Source alpha / one minus source alpha |
| 602 | `0x4F8C2C1D` | One / one minus source alpha |
| 604 | `0x2128DADE` | Destination color / one minus source alpha |
| 605 | `0x53EBE0F3` | Final display transform; blending disabled |

The UI draws target a 3840×2160 RGB10A2 intermediate. The scene draw in this
capture targets a 2560×1440 RGB10A2 image; the resolution transition between
scene and HUD was not fully exposed by the snapshot bindings. Resource
readbacks report current contents, not historical images of each draw.

The destination-color blend computes `D * (S + 1 - alpha)`. Its neutral source
is `S = alpha`, not PQ-encoded white. Converting that neutral multiplier into
a 203-nit PQ color produces a dark rectangle. `IsUIColorDraw` checks the actual
pipeline blend state for all HUD/UI hashes and leaves color-factor blends on the
native shader. A hash alone cannot distinguish a HUD color from a multiplier.

The original UI fix also incorrectly treated SDR RGB as scaled PQ: at a
203-nit white, a 50% gray became about 8.87 nits. The corrected 2.2 response
produces 44.18 nits. This restores a controlled SDR response; it does not claim
to exactly reproduce every setting of the game's nonlinear HDR display curve.
Blending still occurs in the existing PQ intermediate, so translucent panels
can differ from vanilla's blend-then-display-transform behavior.

## Verification

Build from a Visual Studio developer shell, with the game closed:

```powershell
cmake --build --preset vs-x64-release --target ghostoftsushima
```

Output: `build.vs/Release/renodx-ghostoftsushima.addon64`. Confirm the 51 HUD/UI hashes
appear alongside the three scene shaders in
`build.vs/ghostoftsushima.include/embed/shaders.h` and have generated `.h` files.
Rebuild/reload the addon when changing `shared.h`; live HLSL alone does not
update its injected buffer layout.

Use matching build configurations for the game addon and DevKit. Deploying
the Clang Debug game addon beside the installed DevKit caused an access
violation during shared `command_action` callback registration, before any
draw. The crash stack is consistent with incompatible Debug/Release STL
container layouts. The VS Release addon starts correctly with this DevKit.
The local game addon is now a symlink to the VS Release binary;
rebuilding that binary with the game closed updates the deployed addon.

In-game regression checks:

1. With PsychoV selected, compare UI Brightness at 80, 203, and 500 nits.
   White HUD elements should respond without changing scene brightness.
2. Move the native HUD brightness slider through its range. HUD brightness
   should remain fixed at the RenoDX setting.
3. Switch SDR Gamma Emulation among None, 2.2, and BT.1886. HUD midtones should
   change while opaque white remains at the selected UI brightness.
4. Check colored icons, text, menus, depth-occluded markers, animated masks,
   fades, and soft edges. Colors should retain their BT.709 appearance and
   transparency should remain smooth. Check that neutral multiply overlays
   do not expose their rectangular geometry at any UI brightness.
5. Check Vanilla and Preset Off restore native brightness control and color.

All 19 shaders passed strict DXC compilation (`ps_6_6`, HLSL 2021, `-Ges -WX`,
`-enable-16bit-types`), and the Clang debug addon built successfully. Static
audits checked original signatures, interpolation, bindings, sampling, and
branch structure. Numerical checks cover white calibration, gamma responses,
and the neutral multiply identity. A live native-shader comparison removed
the reported rectangle, but the game subsequently crashed during shader
iteration. After deploying the rebuilt VS Release addon and restarting on
2026-09-09, the user confirmed that HUD gamma, brightness, and composition
look correct. DevKit also confirmed a running D3D12 device and HDR-format
swapchain after the restart. Prefer a fresh launch over bulk live shader
reloads for this verification.
