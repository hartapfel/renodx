# Assassin's Creed Ezio Trilogy — native DX9

Native DX9 HDR mod for **Assassin's Creed II and Brotherhood**. Revelations is a
future target. Build target: `asscreedeziotrilogy`.

The game renders through native DX9. RenoDX's device proxy shares its FP16
backbuffer with a separate DX11 swapchain for RGB10A2 HDR10/PQ presentation.
The addon-owned DX11 pixel shader calls `renodx::draw::SwapChainPass` for output
conversion. Scene tone mapping runs in the native SM3 scene/LUT shader.

## Implemented

- Native addon/settings/shader/swapchain lifecycle with the AC2/Brotherhood
  control set: Vanilla/PsychoV-30, detected peak brightness, game/UI brightness,
  hue shift, color grading, PsychoV parameters, Reset All and Preset Off.
- Brotherhood alone shows **Effects → White Gradient Intensity** in both settings
  modes. The default, **0**, bypasses the overlay; **100** restores its original
  strength while retaining HDR range in PsychoV mode. Intermediate values blend
  the scene with the effect. Reset All restores 0; Preset Off restores 100.
- The same 112-byte injection layout as the existing mods. DX9 uses seven
  packed `float4` constants at `c50`–`c56`; the DX11 output shader uses `b13`.
  All eight original shaders were checked for conflicts with those registers.
  `injection_version` is 30; Vanilla uses sRGB and PsychoV uses gamma 2.2.
- Eight native pixel-shader replacements: the HDR LUT bridge/PsychoV-30, bloom
  protection before downsampling, Eagle Vision composition, four HUD variants
  and Brotherhood's post-LUT white-gradient overlay.
  Native DX9 blend-state checks preserve masks, multiplication, premultiplication
  and pre-LUT additive sun/flare draws. Bloom protection also stays on in Vanilla.
- FP16 presentation cloning and candidate scene/bloom/postprocess/HUD upgrades
  from native `b8g8r8a8_unorm` / `b8g8r8x8_unorm` to `r16g16b16a16_float`.
  These retain the existing 16:9 aspect filter and 0.1 tolerance for rounded bloom
  levels, require render-target usage and exclude depth/stencil and UAV usage.
  Sample-only textures and the 3D LUT are outside these rules. Intermediate
  resources use direct DX9 format upgrades; the dgVoodoo typeless/integer-view
  workaround does not transfer to this path.

The native format rules still need broader scene, MSAA and reset validation.
Game and UI Brightness are separate for supported HUD color draws. Preset Off
selects the vanilla LUT/UI/Eagle Vision behavior and sRGB decoding, while FP16
resources, bloom protection and HDR10 transport remain enabled.

See [IMPLEMENTATION.md](IMPLEMENTATION.md) for the native/DX11 hash mapping,
decompilation proof, SM3 adaptation and validation limits.

## Build and local setup

Use the x86 Visual Studio tools environment with Clang on `PATH`:

```powershell
cmake --preset clang-x86
cmake --build --preset clang-x86-release --target asscreedeziotrilogy
# Build compatible inspection tools when needed:
cmake --build --preset clang-x86-release --target devkit mcp_bridge
```

Output: `build32/Release/renodx-asscreedeziotrilogy.addon32`.
The eight native hashes and two addon-owned DX11 presentation shaders should appear
in `build32/asscreedeziotrilogy.include/embed/shaders.h`.
Use compatible Release builds of the game addon and DevKit. Close the game
before rebuilding an addon it has loaded.

The injection folder contains `AssassinsCreedIIGame.exe` (AC2, Steam app 33230)
or `ACBSP.exe` (Brotherhood, Steam app 48190). Resolve its local path before deployment.
Place/link 32-bit addon-enabled ReShade as `d3d9.dll`, the new `.addon32`, and
the compatible `renodx-devkit.addon32` there. An existing dgVoodoo `d3d9.dll`,
wrapper-era ReShade loader or older Ezio addon is a deployment conflict: preserve
that setup before switching to native DX9. Do not load both game addons together.

Set DevKit's tools path to this repository's `bin` directory and live shader
path to `src/games/asscreedeziotrilogy` using absolute local paths. Keep original
shader dumps and temporary decompilations in the game's `renodx-dev/dump` folder;
do not put `.cso` files in the mod source/live directory.

## Extending native coverage

Use [AC2's implementation guide](../asscreed2/IMPLEMENTATION.md) and
[Brotherhood's mod](../asscreedbrotherhood/README.md) as behavior references.
Their dgVoodoo hashes, register assignments and channel masks are not native
DX9 shader identities.

Select the DX9 device in DevKit; the DX11 device only presents the result.
For additional games or shader variants, dump the native shaders, decompile SM3,
recompile and compare original instruction tokens before editing. Preserve alpha,
sampling and non-color clamps. Recheck the actual LUT dimensions, constants,
blend state, resource upgrades and invocation order; the AC2 mapping is not proof
of matching behavior in Brotherhood or Revelations.

## Native compatibility fixes

- Source-alpha blends into FP16 use an automatic native SM3 alpha guard. It
  bounds opacity while retaining HDR RGB, and discovers shader variants without
  a hash list. Pure additive bloom/mask draws keep their original output. See
  [the implementation notes](IMPLEMENTATION.md) for GPU checks. The user confirmed
  this fix resolved the reported artifacts in AC2 and also worked in Brotherhood.
- Pure multiplicative blends into FP16 also bound source RGB to its mask domain.
  This prevents Brotherhood's persistent bloom mask from amplifying itself each
  frame when the scene multiplier exceeds one. Destination HDR and shader alpha
  are preserved. Selection uses native blend state, including unseen shader hashes.
- In PsychoV mode, native material variants can preserve lighting above one before
  fog. The bytecode patch requires the exact lighting/fog sequence, retains its
  black floor, and leaves fog, shadow, opacity and depth calculations intact.
  Vanilla keeps the original material clamp.
  A separate audit of all 456 dumped AC2 pixel shaders found no matching final
  material-lighting clamp; the examined AC2 material paths already preserve the
  lighting sum before fog. No additional AC2 material patch was needed.
- Native startup requires a deferred borderless resize: DX9 reports the forced
  windowed state after swapchain initialization and clears the shared fullscreen
  request. The addon retains its own request until a foreground presentation.
- Native surface copies into the backbuffer must target its FP16 clone; the
  shared texture-copy handler excludes DX9 surfaces. The addon redirects those
  copies before the DX11 presentation proxy consumes the clone.
- Save loading requests a single-level 2x16 DXT5 texture. The native runtime
  returns `D3DERR_INVALIDCALL` (`0x8876086C`), and AC2 dereferences the null result.
  The addon pads sub-block single-level BC1/BC2/BC3 dimensions to at least 4.
  Uploads already contain complete compression blocks, so the block count stays
  unchanged. Check narrow textured details during gameplay after this adjustment.
  The captured failure used approximately 442 MiB private memory, with a 1.3 GiB
  virtual-memory peak; it was not the earlier unbounded video-observation cache.

Microsoft documents the top-level block-alignment requirement in
[D3DFORMAT](https://learn.microsoft.com/en-us/windows/win32/direct3d9/d3dformat).

## Verified locally — 2026-09-15

- All six selected unmodified decompilations recompile to exactly the original
  instruction tokens, including declarations, constants and sample operations.
  Microsoft FXC independently disassembled the originals.
- All six modified shaders compile and create successfully on native DX9 on the
  RTX 5090. Cross-API GPU comparisons cover 18 configurations × 1,024 inputs for
  each shader. Explicit LUT sampling matches exactly; the largest final scene
  difference against DX11 was 0.0354 channel-nits near black. See the implementation
  notes for the stricter encoded-color comparison and its limits.
- A 4,838-draw gameplay capture confirms a native 16³ BGRA8 LUT, 4K FP16 scene
  resources and downsampler invocations before and after the LUT. The scene and
  all three HUD shader variants report Add-on replacements. The user confirmed
  that gameplay with the shader port looks very good, and subsequently confirmed
  Eagle Vision and independent HUD brightness at 80/500 nits worked.
- Live readbacks of the connected scene resources retain above-one and signed
  values with no NaN/Inf. These are current resource contents, not frozen
  before/after images from the captured draw.
- The addon and DevKit build with `clang-x86-release`; the game-folder links
  point to both Release artifacts.
- Logs confirm native DX9Ex rendering and RGB10A2/HDR10 DX11 presentation.
  The user confirmed that the tiny black window was fixed and the menu worked.
- The user loaded the previously crashing save into gameplay with the FP16
  upgrades enabled. Logs show three 2x16 textures padded to 4x16: one BC3 and
  two BC1 textures. The 38-second gameplay sample used 737–757 MiB of private
  memory, with a 1.3 GiB virtual-memory peak. This is a short loading regression
  check, not a long-session leak test.

## Brotherhood verification — 2026-09-16

- Decompiled all 505 dumped native shaders (326 pixel / 179 vertex). The five
  shared scene/bloom/Eagle Vision/basic-HUD originals are byte-identical to AC2.
- Added only the white-gradient overlay `0xFDE9A5D3` and transformed-mask HUD
  `0xAFDE4E3D`. The 1,631-draw capture places the gradient directly after the
  LUT and confirms four uses of the masked-HUD variant later in the frame.
- Both selected baselines have equivalent instruction graphs and render
  identically to the originals in 48 native DX9 GPU cases. Edited alpha remains
  exact; the RGB equations pass with maximum normalized error `1.056e-6`.
- Rebuilt `asscreedeziotrilogy` using `clang-x86-release`. Both embedded additions
  match the GPU-tested instruction streams. AC2 and Brotherhood's addon links
  resolve to the same Release binary. The general alpha guard remains in place;
  no old dgVoodoo per-material shader fixes were added.
- The user reported that the previous Brotherhood changes were working well.
- A later artifact capture traced black/colored rectangles to positive infinities
  in the persistent bloom seed. Native blend tracing and a GPU feedback test
  establish a separate multiplicative feedback problem. The general mask guard
  passes 246 GPU blend/policy checks; all 995 dumped AC2/Brotherhood pixel shaders
  and 1,979 applicable alpha/RGB variants create successfully on native DX9.
- The user confirmed the multiplicative-mask fix worked flawlessly in gameplay.
- A daylight courtyard exposed an explicit pre-fog material color clamp. The
  lighting correction matches 20 material variants used in 476 captured draws.
  Native GPU tests of the actual material verify HDR lighting, fog, alpha and
  secondary output; 582 checks pass including prior blend regressions.
- The user confirmed the rebuilt material-lighting correction works perfectly
  in gameplay. A post-restart resource readback was not completed.

## Remaining runtime checks

- Check the Brotherhood-only Effects slider at 0/50/100, Reset All and Preset Off.
- Vary Brotherhood UI Brightness through 80/203/500 nits, including the minimap's
  transformed mask, and compare Vanilla/PsychoV in the white-gradient scene.
- Check the trilogy overlay title and that peak detection preserves manual values.
- Check startup/video playback, alt-tab, resize, device reset and longer gameplay.
- Verify native scene/bloom/postprocess/HUD values and copies/resolves across
  scenes and graphics settings, including sun/flare and glowing street objects.
- Check the control extremes, Preset Off, Eagle Vision, and operation without
  DevKit. Broader scene coverage and long-session stability remain manual checks.
