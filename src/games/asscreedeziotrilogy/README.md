# Assassin's Creed Ezio Trilogy — native DX9

Native DX9 HDR mod for **Assassin's Creed II, Brotherhood and Revelations**.
Revelations coverage is experimental. Build target: `asscreedeziotrilogy`.

The game renders through native DX9. RenoDX's device proxy shares its FP16
backbuffer with a separate DX11 swapchain for RGB10A2 HDR10/PQ presentation.
Scene tone mapping runs in the native SM3 scene/LUT shader. The addon-owned DX11
pixel shader fits the complete HDR composition smoothly to Peak Brightness, then
calls `renodx::draw::SwapChainPass` for output conversion.

## Implemented

- Native addon/settings/shader/swapchain lifecycle with the AC2/Brotherhood
  control set: Vanilla/PsychoV-30, detected peak brightness, game/UI brightness,
  hue shift, color grading, PsychoV parameters, Reset All and Preset Off.
- The HDR LUT bridge uses sRGB input/output followed by gamma-2.2 SDR EOTF
  emulation. The same conversion is used for the LUT-calibrated gray anchor.
- Brotherhood alone shows **Effects → White Gradient Intensity** in both settings
  modes. The default, **0**, bypasses the overlay; **100** restores its original
  strength while retaining HDR range in PsychoV mode. Intermediate values blend
  the scene with the effect. Reset All restores 0; Preset Off restores 100.
- **Video → Video AutoHDR** defaults to **BT2446A** in all three games. It expands
  prerendered SDR video to the selected Peak Brightness, with Game Brightness
  controlling the curve. Off and Vanilla preserve the original shader colors;
  Preset Off disables it and Reset All restores it. Video alpha is unchanged.
- The same 112-byte injection layout as the existing mods. DX9 uses seven
  packed `float4` constants at `c50`–`c56`; the DX11 output shader uses `b13`.
  All nine original shaders were checked for conflicts with those registers.
  `injection_version` is 30; Vanilla uses sRGB and PsychoV uses gamma 2.2.
- Nine native pixel-shader replacements: the HDR LUT bridge/PsychoV-30, bloom
  protection before downsampling, Eagle Vision composition, four HUD variants
  Brotherhood's post-LUT white-gradient overlay, and shared video playback.
  Native DX9 blend-state checks preserve masks, multiplication, premultiplication
  and pre-LUT additive sun/flare draws. Bloom protection also stays on in Vanilla.
- PsychoV keeps ordinary white at Game Brightness and rolls HDR highlights toward
  Peak Brightness, including effects added after the LUT. Its working response
  stays independent of Game Brightness to avoid brightness-setting reversals.
  Vanilla restores the SDR range before the LUT and at presentation.
- FP16 presentation cloning and candidate scene/bloom/postprocess/HUD upgrades
  from native `b8g8r8a8_unorm` / `b8g8r8x8_unorm` to `r16g16b16a16_float`.
  These match the current backbuffer's aspect ratio, with 0.1 tolerance for
  rounded bloom levels, require render-target usage and exclude depth/stencil
  and UAV usage. The shared upgrade code refreshes the reference on swapchain
  initialization and resize, including ultrawide resolutions.
  Sample-only textures and the 3D LUT are outside these rules. Intermediate
  resources use direct DX9 format upgrades; the dgVoodoo typeless/integer-view
  workaround does not transfer to this path.

The native format rules still need broader in-game scene, MSAA and reset validation.
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
The nine native hashes and two addon-owned DX11 presentation shaders should appear
in `build32/asscreedeziotrilogy.include/embed/shaders.h`.
Use compatible Release builds of the game addon and DevKit. Close the game
before rebuilding an addon it has loaded.

The injection folder contains `AssassinsCreedIIGame.exe` (AC2, Steam app 33230),
`ACBSP.exe` (Brotherhood, Steam app 48190), or `ACRSP.exe` (Revelations, Steam app
201870). Resolve its local path before deployment.
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
  fog. The bytecode patch recognizes Brotherhood's distance fog and Revelations'
  volume-fog composition by their instruction sequence and register dataflow,
  retains the black floor, and leaves fog, shadow, opacity and depth calculations intact.
  Vanilla keeps the original material clamp.
  Brotherhood's cutscene variants are also covered when lighting uses Y/Z/W
  channels or fog is computed earlier, in another register, or by the vertex
  shader. The matcher follows RGB into the final fog blend and checks the
  material depth output; it does not depend on a list of shader hashes.
  Depth-faded particles keep their authored RGB clamp: removing it turned
  Revelations' white windtrails blue. Detection follows reconstructed scene depth
  into bounded opacity, so matching effect variants are protected without a hash
  list. Transparent surface materials still receive HDR lighting.
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

## Revelations verification — 2026-09-16

- The 4,168-draw capture contains 1,157 material draws across 35 variants with
  a completed-lighting clamp before distance/volume fog. Scene targets are FP16;
  the clamp is an explicit native shader instruction.
- Independently disassembled all 439 dumped pixel shaders. The SM3 decompiler
  produced 437 baselines; two unrelated shaders failed. The selected material's
  repaired baseline matches native GPU lighting/fog checks with volume fog on/off.
- Extended the general material matcher to cover all 113 matching Revelations
  variants in this dump. It changes only the completed-lighting ceiling, keeps
  the black floor and composes with the existing alpha/blend guards.
- All 1,495 dumped pixel shaders across the three games, 2,970 applicable blend
  variants and 251 lighting variants create on native DX9. The Revelations suite
  passes 1,254 GPU checks; the Brotherhood regression suite still passes 582.
- Restart logs confirm the affected material uses the lighting fix, including
  draws that also require alpha protection. A subsequent gameplay readback
  reaches RGB 1.97 before the LUT with no NaN/Inf. This is not a controlled
  before/after comparison; visual confirmation remains a manual check.

## Remaining runtime checks

- Play prerendered videos in each game, compare Video AutoHDR Off/BT2446A, and
  check fades, subtitles, letterboxing, return to gameplay, Vanilla and Preset Off.
- Recheck RTSS/NVIDIA caps and VSync across graphics resets, alt-tab and longer
  sessions in all three games. The capped Brotherhood relaunch is measured at
  60 actual HDR FPS; the final in-game reset has user confirmation only.
- Extend the confirmed Brotherhood graphics-change check to AC2/Revelations,
  more resolution/anti-aliasing combinations, and alt-tab with/without DevKit.
- Check scene/bloom/HUD upgrades at ultrawide resolutions and after resolution
  changes; confirm matching render targets remain FP16 and unrelated masks do not.
- Check the new highlight fit in Animus lighting at 1000-nit Peak Brightness:
  compare Vanilla/PsychoV, then raise Game Brightness from 203 to 500. Verify
  smooth highlights, SDR-bounded Vanilla, Eagle Vision and transparent HUD edges.
- Compare Revelations' affected scene in PsychoV and Vanilla, including fog,
  material highlights, transparent objects and shadows.
- Check the Brotherhood-only Effects slider at 0/50/100, Reset All and Preset Off.
- Vary Brotherhood UI Brightness through 80/203/500 nits, including the minimap's
  transformed mask, and compare Vanilla/PsychoV in the white-gradient scene.
- Check the trilogy overlay title and that peak detection preserves manual values.
- Check startup/video playback, alt-tab, resize, device reset and longer gameplay.
- Verify native scene/bloom/postprocess/HUD values and copies/resolves across
  scenes and graphics settings, including sun/flare and glowing street objects.
- Check the control extremes, Preset Off, Eagle Vision, and operation without
  DevKit. Broader scene coverage and long-session stability remain manual checks.

## Highlight-fit verification — 2026-09-16

- The user reports that the updated highlight fit is almost perfect. A subsequent
  blue windtrail report was isolated to the pre-LUT particle/material path, not
  the final highlight shoulder; see the particle-clamp notes in IMPLEMENTATION.md.
- The actual native scene shader, FP16 transport and DX11 HDR10 proxy were tested
  together across 180 configurations (414,720 pixels), then repeated with a late
  additive effect. All outputs were finite, with no early peak plateaus in the
  tested lighting range. Extreme-tail FP16/PQ rounding remains below one 10-bit
  PQ code step; this is not proof of strict monotonicity for every colored ramp.
- The Vanilla LUT sweep matches the original native shader exactly. A separate
  proxy fixture passes 432 component checks, including the final SDR clamp.
- HUD white at 80/203/500 nits remains within 0.26 nits of its requested value
  (or display peak), with unchanged shader alpha. In-game transparent blending
  and the latest highlight fit still require the runtime checks above.

## Graphics-reset stability — 2026-09-16

- Brotherhood creates a temporary `Kiero` DX9 device after a graphics reset.
  The shared swapchain module now accepts presentation shader settings only
  from the DX11 proxy device, so helper devices cannot replace them with an
  empty shader set. Proxy teardown also preserves the host's window hook and
  flushes deferred DX11 swapchain destruction before recreation.
- The native presentation copy releases its temporary surface references every
  frame and skips failed copies. MSAA backbuffer clones remain DX9 surfaces,
  then resolve to a single-sample shared texture for HDR presentation.
- An isolated x86 test with the actual Release addon and installed ReShade
  reproduced the old failure on the first reset/helper-device cycle. The fixed
  addon passed 12 resolution-reset cycles and another 12 cycles alternating
  single-sample/4x MSAA, with helper-device creation on a second thread. HDR10
  readbacks stayed identical for the reference gray and updated for red frames.
  The 12-cycle MSAA sequence also passed with Release DevKit enabled.
  The user then confirmed Brotherhood's graphics changes recover flawlessly in
  gameplay. The runtime log records two settings resets and subsequent rendering
  without the prior helper-triggered proxy reconfiguration. Broader game/setting
  coverage and long-session stability still need the manual checks above.

## Frame pacing and shared-texture handoff — 2026-09-16

- The HDR proxy now owns successful frame presentation. The native DX9 Present
  is skipped only after the proxy succeeds; failed/skipped proxy frames retain
  native presentation and device-loss handling. ReShade's events remain active.
- The proxy inherits the game's requested VSync interval, captured before native
  driver/overlay changes, and no longer forces tearing. Native presentation
  hooks are restored before swapchain resets and device destruction.
- DX9 finishes writing the shared texture before DX11 reads it, and DX11 finishes
  its copy before DX9 can reuse it. An alternating-color GPU test caught 20 stale
  images in 240 frames before synchronization and zero afterward.
- The x86 Release build passes all three DX9 Present entry points, failed-proxy
  fallback, and 12 resolution/MSAA/helper-device reset cycles both with and
  without DevKit. HDR reference readbacks remain correct.
- Live Brotherhood traces showed the original 60-FPS cap producing 30 HDR frames
  plus discarded DX9 presents. The final capped relaunch measures 60.01 HDR FPS,
  no native DX9 presents and no dropped frames (479 frames, 16.689-ms p99 interval).
  The user confirmed smooth motion with in-game VSync on and off. See
  IMPLEMENTATION.md for capture limits and remaining reset/limiter coverage.

## Video AutoHDR verification — 2026-09-16

- `0x947F8B85` is byte-identical in all three game dumps. Its decompiled baseline
  reproduces every original instruction DWORD; RGB sampling and fade alpha are
  preserved in the replacement.
- 216 native DX9 configurations (497,664 pixels) pass through FP16 transport and
  the actual DX11 HDR10 shader: finite output, exact Off/Vanilla RGB and alpha,
  monotonic gray ramps, and white within 0.5 nit of the selected peak. Scene,
  HUD and presentation shader instruction streams remain unchanged.
- The rebuilt Release addon activates the video replacement with the installed
  ReShade runtime in an isolated vertex-buffer playback test. HDR10 readbacks
  pass two resolution/MSAA resets with helper-device creation. In-game video
  playback and fades still need the visual checks above; see IMPLEMENTATION.md
  for the synthetic UP-draw reset limitation.
- The user subsequently confirmed that video playback works flawlessly.

## Brotherhood cutscene lighting — 2026-09-16

- The captured vault cutscene contains 19 additional material variants in 143
  draws with final lighting clamps missed by the former register-specific rule.
  The extended matcher covers 151 additional variants in the Brotherhood dump,
  retains every previous match, and leaves AC2/Revelations matching unchanged.
- Five selected decompiled baselines match their originals exactly in native
  GPU checks. All 7,560 lighting/fog/alpha/depth checks and 20 rejection cases
  pass, along with the existing blend, volume-fog and windtrail regression tests.
  All 1,623 dumped pixel shaders and 435 lighting variants create on native DX9.
- Rebuilt target `asscreedeziotrilogy` with `clang-x86-release`. Reopen the vault
  cutscene and compare Ezio's armor/face in PsychoV and Vanilla. The game closed
  before live shader comparison, so the visual result still needs confirmation.

## Brotherhood building lighting — 2026-09-16

- The distance-fog matcher also follows independently packed fog RGB and a
  separate source register for fog distance. This covers 47 more Brotherhood
  variants, including three shaders used in 52 draws in the captured building
  scene. All previous matches remain; AC2/Revelations coverage is unchanged.
- Three decompiled baselines match native GPU output exactly in the tested
  cases. All 4,536 lighting/fog/alpha/depth checks and 12 rejection cases pass,
  together with the existing cutscene, volume-fog, blend and windtrail tests.
- Build `asscreedeziotrilogy` with `clang-x86-release`, restart Brotherhood,
  and check the window surrounds and curved structure on the right in PsychoV
  and Vanilla. DevKit reported the temporary shaders loaded, but diagnostic
  colors did not reach the material draws; that live test is inconclusive.
- The rebuilt Release addon activates all three new native fixes after restart
  (`lighting=1` in the runtime log). Scene and graded FP16 readbacks contain no
  NaN/Inf values. The user confirmed the windows and right-hand structure are
  corrected after restarting with this build.
