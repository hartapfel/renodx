# Ghost of Tsushima

Enable native HDR in the game. With PsychoV selected, **UI Brightness** controls
HUD/menu white independently of Game Brightness, overriding the native HUD
brightness multiplier. Its default is 203 nits and its range is 80–500 nits.
Vanilla and Preset Off restore native HUD behavior.

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

The 16 HUD replacements use `ui.hlsli`. Ordinary color draws bypass
`b12.c8.w`, or `b0.c16.z` for the straight-alpha `0x9D97A7C7` variant.
Premultiplied colors are unpremultiplied before the color transform and
premultiplied again afterward. The helper decodes SDR UI colors, applies the
same forward SDR Gamma Emulation operation as the scene, converts BT.709 to
BT.2020 in linear light, and encodes PQ at the selected UI white. None uses the
sRGB response; 2.2 and BT.1886 use the scene's 2.2 and 2.4 emulation modes.

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
pipeline blend state for all 16 hashes and leaves color-factor blends on the
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

Output: `build.vs/Release/renodx-ghostoftsushima.addon64`. Confirm the 16 HUD hashes
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
