# Native Ezio Trilogy shader port

Behavior reference: [the AC2 DX11 implementation guide](../asscreed2/IMPLEMENTATION.md).
This port keeps native D3D9 rendering and uses RenoDX's DX11 device proxy only for
HDR10 presentation. All three games have native mappings; their validation
coverage and remaining runtime checks are recorded below.

## Graphics-reset and presentation lifetime

Brotherhood's September 16 log shows a successful native `Reset`, followed by
creation/destruction of a 232x29 `Kiero` helper device on a different thread.
`mods::swapchain::OnInitDevice` previously published proxy settings for every
device. The helper's DX9 shader set is empty, so it overwrote the DX11 output
shaders and marked the proxy dirty. The next frame recreated presentation with
that empty shader set. An isolated test with the previous Release binary
reproduced failure on the first reset/helper cycle, including a DX11
`DXGI_ERROR_DEVICE_HUNG` removal reason.

The correction is in the shared presentation infrastructure used by this addon:

- `swapchain_v2.hpp` publishes settings only for `IsProxyDevice(device)`.
  Proxy swapchains do not enter the host swapchain/window bookkeeping; releasing
  them no longer removes the host window hook or leaves a stale flip-chain entry.
- `device_proxy.hpp` clears context state and flushes after releasing the old flip
  swapchain, balances `GetSurfaceLevel` references with scoped ownership, and
  returns before publishing a failed native copy.
- `resource_upgrade.hpp` preserves multisampled DX9 surfaces when cloning.
  DX9 cannot create multisampled textures. The shared handoff texture remains
  single-sample and the existing `StretchRect` performs the resolve.

Validation uses the actual x86 addon and ReShade DLL in an isolated directory,
without the game. The fixture changes resolution, resets, creates/destroys a
`Kiero` device on a worker thread, and reads back the DX11 HDR10 output. Twelve
resolution cycles and twelve alternating non-MSAA/4x-MSAA cycles pass, including
updated red frames between reference-gray checks. The twelve-cycle MSAA sequence
also passes with the installed Release DevKit enabled. No device removal, failed
clone/copy or stale flip-swapchain warning appears in the fixed run. The user
subsequently confirmed flawless recovery during Brotherhood graphics changes.
The game log records two settings resets, helper-device recreation, and continued
native rendering without the prior helper-triggered proxy reconfiguration.
This is a short regression check, not a long-session or all-games stability proof.
Evidence: `tmp/asscreedeziotrilogy/reset/` (fixture source, prior/fixed binaries,
logs and readback results). Build with `clang-x86-release`, target
`asscreedeziotrilogy`; no shaders or controls changed for this correction.

## Shader mapping and decompilation proof

The native dump contains 393 `ps_3_0` and 206 `vs_3_0` shaders. All 393 pixel
shaders decompiled with the register-preserving mode of HlslDecompiler at
`D:\Downloads\HlslDecompiler-master\HlslDecompiler-master`. The AST simplifier
was not used. The initial AC2 port replaces the six matching pixel shaders below;
Brotherhood adds two variants described in its section below.
The shared video shader is covered in the Video AutoHDR section at the end.

| Native SM3 hash | DX11 reference hash | Native behavior / binding |
|---|---|---|
| `0x48DCE479` | `0x61888319` | Scene `s0`, volume LUT `s1`; scale `c0.xyz`, offset `c1.xyz`; alpha 0 |
| `0xB4D7A117` | `0x8FA72580` | 16 sequential RGBA samples from `s0`, offsets `c0`–`c15`, average 1/16 |
| `0xA6A34F63` | `0x5574B6B8` | Scene `s0`; signed bloom/star `s1`/`s2`, weights `c0.x`/`c1.x`; final RGB saturation, alpha 1 |
| `0x7258C5E9` | `0x0DA2DE91` | `s0 * vertex color * c128 + c129` |
| `0x5E3A6B72` | `0x12BA0F50` | `s0 * c128 + c129` |
| `0xFB5A6594` | `0x2EAA46EB` | `s0 * vertex color * c128`; alpha additionally multiplied by `s1.a` |

The original `.cso` files were independently disassembled with Microsoft FXC.
All six raw HLSL baselines compiled using `fxc /T ps_3_0 /E main /O3 /WX`.
After stripping shader comment tokens (compiler metadata and constant-table
names), **every instruction DWORD is identical to the original bytecode**.
This includes declarations, register numbers, immediates, component writes,
swizzles, saturation, texture instructions and operation order. No decompiler
repair was needed for these six. This proof does not cover the other 387 pixel
decompilations or any vertex shader.

The native shaders do not contain dgVoodoo's synthetic channel AND/OR masks or
DX11 constant-buffer shifts. Those wrapper operations were not copied. The
native `COLOR`/`TEXCOORD` declarations and alpha calculations remain intact.

## Ported behavior

- **Scene:** reversible Adaptive D65 gamut fit and max-channel N2 LUT-domain
  compression, native grade, range/gamut reconstruction, measured gray anchors,
  PsychoV-30 and user grading. Auto and manual compression use a working range
  independent of Game Brightness. A soft upper gamut boundary and the final
  presentation shoulder preserve highlight variation; see the September 16
  highlight-fit section below. Color Filter operates in that working range.
- **LUT precision:** SM3 has no `Texture3D.Load`. Eight `tex3Dlod` calls fetch the
  16³ LUT's vertex texels at `(index + 0.5) / 16`, LOD 0, followed by the same
  explicit trilinear interpolation. These binary-exact texel centers avoid
  hardware interpolation-weight quantization even with the game's linear sampler.
  Vanilla/invalid injection keeps the original hardware `tex3D` path. The native
  gameplay capture confirms a single-level 16×16×16 `b8g8r8a8_unorm` LUT at `s1`.
- **Bloom:** `AC2BloomSeed` runs on each source RGB before the original sum and
  1/16 average. Above `m = max(R,G,B) = 1`, RGB is uniformly scaled by
  `(2 - 1/m) / m`. Alpha and inputs at/below one remain unchanged. This is enabled
  in both Vanilla and PsychoV because FP16 exposes the same excessive mask gains.
- **Pass selection:** the LUT draw sets `scene_tonemapped`; only native DX9 Present
  clears it. DX11 proxy presents do not disturb it. The common downsampler is
  replaced only before the LUT, preserving later DOF/Eagle Vision filtering.
- **Eagle Vision:** preserve `2*x-1`, effect weights, black floor and alpha 1;
  retain HDR composition for the proxy's final shoulder. The scene is not run
  through PsychoV a second time. Vanilla retains the original saturation.
- **HUD:** inspect actual D3D9 `COLORWRITEENABLE`, `ALPHABLENDENABLE`, `SRCBLEND`,
  `DESTBLEND` and `BLENDOP`. Exclude alpha-only/no-color, multiplicative, and
  pre-LUT additive `ONE + ONE` draws. Eligible draws decode, scale by
  `UIWhite / GameWhite`, compensate for the final display shoulder, and re-encode;
  premultiplied alpha is handled explicitly.
  The HUD shaders' original alpha values are preserved.
- **Output:** version 30 enables the port. PsychoV composes in gamma 2.2;
  Vanilla/Off uses sRGB and restores the original SDR range before LUT lookup
  and at final presentation. The proxy fits the complete PsychoV composition
  before `SwapChainPass`, which still owns HDR10 output encoding.
  Preset Off keeps FP16 resources, bloom protection and HDR10 transport.

`psychov30.hlsli` is the AC2 reference copy, including its corrected shadow scalar.
The port changes its surrounding texture API and injection access, not the
PsychoV algorithm. The 112-byte settings structure stays compatible: SM3 uses
`c50`–`c56`, which none of the eight selected originals accesses; the DX11 proxy uses `b13`.
FXC's literal constants also avoid the injected registers.

The BC sub-block texture padding, deferred borderless resize, native backbuffer
copy redirection and presentation-state restoration remain enabled. No video
shader was replaced. The earlier shared cache/alignment fixes remain prerequisites
for compatible DevKit and addon builds; this shader port changes no shared utility.

## Highlight fit and Vanilla range — 2026-09-16

FP16 removes the implicit UNORM clamp both before the LUT and after later
effects. The native Vanilla LUT path was already bounded, but later additions
could still reach HDR values. Vanilla now saturates the encoded scene before
the original LUT transform and saturates the final encoded composition before
sRGB decoding. Material lighting retains its existing Vanilla clamp policy.
Bloom protection remains enabled, so Preset Off is not a bit-exact recreation
of every original intermediate UNORM rounding operation.

Previously, Game Brightness changed PsychoV's working gamut volume as well as
the final physical brightness. That could change its hue/gamut projection enough
to dim highlights when the slider rose. Individual projected channels could also
reach the working ceiling early, and late effects encountered `SwapChainPass`'s
hard peak clamp. The new path separates these operations:

1. Both compression modes use `W = max(4000 / 203, PeakBrightness / 80)`.
   The 80-nit term covers the minimum supported Game Brightness. Game Brightness
   no longer changes this response. The PsychoV implementation itself is unchanged.
2. Above 80% of the remaining upper-gamut chroma headroom, a rational shoulder
   softens the projected channel ceiling while preserving luminance. The peak
   channel can keep rising as the highlight approaches white. The selected
   BT.709/BT.2020 gamut is used consistently. Color Filter and calibration-anchor
   limits use the same working volume.
3. `presentation.hlsli` expands the finite working response into the native
   gamma-2.2 FP16 composition buffer. Later additions, Eagle Vision, filtering
   and HUD draws operate there. The HUD compensates for the presentation shoulder
   before encoding; its original alpha and premultiplication policy remain intact.
4. The DX11 proxy decodes the complete composition. It repairs negative BT.2020
   gamut-boundary error in linear light, then applies one smooth display fit.
   Passing linear BT.2020 to `SwapChainPass` avoids repeating gamma-domain gamut
   compression, which amplified tiny FP16 errors in signed BT.709 colors.

For `P = PeakBrightness / GameBrightness`, the knee is `k = min(1, P / 2)`.
Above it, the proxy maps maximum channel `x` to
`k + (x-k) * (P-k) / (P-k + x-k)`, scaling RGB uniformly. Values below the knee
are unchanged. For the scene alone, expansion from W followed by this fit is
equivalent to the anchored finite-range curve
`k + (x-k) / (1 + (x-k) * (1/(P-k) - 1/(W-k)))`.
It has unit slope at the knee and maps the working endpoint to the display peak.
The expansion denominator has a finite `1e-4` floor for safe FP16 transport.
At normal settings, ordinary white stays at Game Brightness; HDR highlights
approach Peak Brightness. If Game Brightness approaches or exceeds the display
peak, the lower knee necessarily compresses that reference white too.

Evidence in `tmp/asscreedeziotrilogy/highlights/`:

- `sweep.cpp` renders the actual SM3 shader on D3D9 across nine neutral/colored/
  signed rays from `2^-16` to `2^20`, three synthetic 16-cubed LUTs, peaks
  400/1000/4000, Game Brightness 80/150/203/300/500, Auto/manual compression and
  both gamut modes: 180 configurations, 414,720 pixels.
- `proxy-test.cpp` rounds those results to FP16, then runs the actual DX11
  proxy. A second pass adds an encoded 0.5 effect before FP16 transport.
  All outputs remain finite; maximum encoded transport magnitude is 385.995.
  Neither pass has an early hard peak plateau in the tested source range up to
  256. The physical BT.2020 endpoint excess from GPU/PQ numerical error is at
  most 0.012/0.071/0.319 nits for the three tested peaks.
- The previous response had 119 sampled Game Brightness reversals, up to
  7.11 nits. The revised response before transport has none above 0.05 nits.
  FP16/PQ transport still produces small extreme-tail differences (below one
  10-bit PQ code step). This does not establish strict monotonicity for every
  colored input ramp: PsychoV's hue/gamut response can still change luminance
  along such ramps independently of the Game Brightness setting.
- 432 separate proxy component checks pass against independent gamma/sRGB,
  shoulder and PQ equations, including Vanilla and invalid injection; maximum
  PQ-code error is `6.303e-6`.
- The Vanilla scene sweep and original native bytecode produce identical output
  bytes with the game's normal LUT transform, across the tested rays and LUTs.
- Three additional HUD sweeps verify white settings 80/203/500 through the same
  FP16/proxy path. Maximum white error is 0.259 nits; shader alpha stays exactly
  0.75. Transparent blending over different backgrounds remains a runtime check.

These are synthetic GPU checks, not an in-game visual comparison. Restart and
check Animus lighting, Vanilla/Preset Off, Game Brightness 203 through 500,
Eagle Vision, HUD edges and nondefault creative controls. Historical DX11
equivalence results below describe the initial port, before this revised fit.

## Validation — 2026-09-15

### Compile and GPU comparisons

All six modified shaders compiled as SM3 and were created on an actual D3D9 HAL
device on the RTX 5090. That device reports 4,096 pixel-shader instruction slots.
FXC reports 2,975 for the full scene shader, 194 for bloom, 143 for Eagle Vision,
and 88–90 for HUD. SM3's guaranteed minimum is lower; support depends on the
device's [MaxPixelShader30InstructionSlots](https://learn.microsoft.com/en-us/windows/win32/api/d3d9caps/ns-d3d9caps-d3dcaps9).
The Release build's six embedded shader instruction streams match the shader
binaries used by the offscreen fixture.

An x86 offscreen fixture renders the actual six native replacements to RGBA32F
and compares them with the unchanged DX11 helpers on the same GPU, using the
same synthetic 16³ RGBA8 grade. It covers 18 configurations × 1,024 pixels × six
shaders: black, gray/color ramps, signed inputs, values beyond white, alpha,
Vanilla/invalid injection, UI 80/500, premultiplication, Color Filter, contrast,
shadows 0/2, gamut mode, compression, saturation, exposure, highlights, low-peak/
high-white, gamma, flare and blowout.

Results and limits:

- No nonfinite output in any case. Scene/Eagle alpha stays exactly 0/1. HUD alpha
  differences against the DX11 fixture are at most one float rounding step
  (`2.98e-8`) from vertex-color arithmetic.
- Bloom and vanilla scene match exactly. Eagle Vision and HUD differences remain
  at floating-point scale. The separate eight-tap LUT sampling comparison is exact.
- The complete PsychoV port is **not bit-identical across shader models**. The
  initial test's `0.003 * (1 + abs(reference))` encoded-channel tolerance flagged
  768 component comparisons, concentrated near black. The maximum final scene
  channel difference after gamma-2.2 decoding and white scaling is **0.0354 nits**.
  The source still uses the same tone-mapper math; these differences were not
  hidden by changing the algorithm or loosening that initial test's logged result.
- Isolation tests reproduce near-black variation in PsychoV without any LUT.
  The gray/colored branch behavior in the tiny-radius target solve is sensitive
  to floating-point differences. HDR grade reconstruction also amplifies small
  rounding into near-zero channels at extreme source values (~26,000 linear),
  while the dominant channel agrees closely. These are numerical limits of the
  cross-model comparison, separate from the exact native decompilation proof.

### Gameplay capture

The user loaded gameplay and reported that it looks very good. DevKit captured
4,838 native draws with the embedded addon running:

- Downsampler `0xB4D7A117` at draws 4791 and 4792 precedes LUT draw 4810; another
  invocation at 4811 follows it. This confirms why the before-LUT guard is needed.
- Five-level bloom sum `0x78060AE4` at 4808 and scene addition `0x63A83B57` at 4809
  precede the LUT. They correspond to DX11 `0x7405432A` and `0x35D82084`; their
  native code is retained.
- The LUT reads a 3840×2160 FP16 scene and writes another FP16 target. Its native
  volume texture is 16³ BGRA8. All three HUD variants occur after the scene and
  report embedded Add-on replacements. Eagle Vision is registered but was not
  invoked in this ordinary gameplay capture.
- Live reads of the connected scene resources retain signed/above-one values.
  Their RGB maxima were 1.72754 and 1.92480, with 14,975 and 43,603 above-one
  pixels and zero NaN/Inf. **These resources can be reused later in the frame:**
  the readbacks are current contents, not frozen pre/post-LUT comparison images.
- Private process memory was approximately 769 MiB before readback. This confirms
  continued gameplay with upgrades and the port, not a long-session memory test.
- The user subsequently confirmed Eagle Vision and the 80/500-nit independent
  HUD brightness check were working.

Broader daylight/interior/fire scenes, sun/flare isolation, menus, video, device
resets, graphics settings and operation without DevKit still need manual coverage.
Brotherhood and Revelations evidence follows below.

## Brotherhood variants — 2026-09-16

The native Brotherhood dump contains 326 pixel and 179 vertex SM3 shaders.
All 505 decompiled successfully with HlslDecompiler's register-preserving mode.
This establishes availability of editable baselines, not semantic proof for
every dumped shader. The two selected additions received the separate audit below.

The scene LUT `0x48DCE479`, bloom downsampler `0xB4D7A117`, Eagle Vision
`0xA6A34F63` and basic HUD `0x7258C5E9` / `0x5E3A6B72` are byte-identical to
AC2's originals, including metadata. Their existing replacements are reused.
AC2's masked HUD `0xFB5A6594` is absent from this Brotherhood dump.

| Native SM3 hash | Brotherhood DX11 reference | Addition |
|---|---|---|
| `0xFDE9A5D3` | `0x788AFF56` | Post-LUT white gradient: scene `s0`, flipped gradient `s1`, strength `c0.x`, top/bottom colors `c1`/`c2` |
| `0xAFDE4E3D` | `0x8B4B475C` | Masked HUD: base `s0`, alpha mask `s1`, color `c128`, mask UV scale/offset `c129`/`c130` |

The 1,631-draw native gameplay capture establishes this order:

- Bloom seed downsampling at 1573/1574, then five-level sum and scene addition.
- Scene LUT at 1592, reading the native 16³ BGRA8 LUT and writing 4K FP16.
- White gradient at 1593, consuming that LUT output and a 32×16 BGRA8 gradient,
  then writing another 4K FP16 target.
- Post-LUT downsample at 1594, blur at 1595 and DOF `0xDCF074DF` at 1596.
  DOF bounds its interpolation factor, not the scene color, so its clamp stays.
- Basic HUD and four transformed-mask HUD draws (1600–1603) follow the scene.
  These masked draws bind a 256² BC3 base and a 256² A8 mask.

The gradient change removes only the intermediate RGB ceiling when version 30
and PsychoV are active. Its black floor, alpha saturation, flipped UVs, sign
selection, strength, top/bottom tint, saturated absolute blend weight and final
addition are retained. Vanilla/invalid injection keeps the original saturation.
It consumes the already-tonemapped gamma-space scene and adds no second tonemapper.

The Brotherhood-only **Effects / White Gradient Intensity** control defaults to
0 (scene passthrough), with 100 retaining the port's original effect strength.
Values between them interpolate the full RGBA effect result with the scene;
the 0 and 100 endpoints retain exact passthrough/full-strength paths. Invalid
injection still uses the original effect. The control works in both tonemapper
modes; Reset All restores 0 and Preset Off restores vanilla strength (100).
Visibility uses a case-insensitive `ACBSP.exe` process-name check at addon startup,
so neither the control nor its otherwise-empty section appears in AC2.
The intensity occupies the previously unused `c56.y` / `padding_0` slot; the
112-byte injection layout and all other register offsets remain unchanged.

The existing native DX9 fixture was extended to 576 cases across intensity
0/25/50/100, invalid injection, Vanilla and PsychoV. It checks signed/HDR inputs,
the gradient sign boundary and both tints, with the HUD shader as a layout
regression. All cases pass; zero intensity reproduces source RGBA exactly,
full strength preserves original alpha, and maximum normalized equation error
is `1.056e-6` (HUD; gradient below `1e-7`). Evidence is in
`tmp/asscreedeziotrilogy/brotherhood/gradient-intensity/validation.log`.

The HUD change preserves its Y-flip followed by scale/offset, base sampling,
vertex/constant tint and alpha-mask product. Only the RGB output calls the existing
`AC2ScaleUI`; its hash uses the same `IsUIColorDraw` selection as the other HUD
variants. Both new hashes also participate in the existing native alpha guard.

No wrapper-era water, footwear, reflection, Animus or view-angle material fixes
were added. The user confirmed the general native alpha guard handles those
reported artifacts in Brotherhood. The other 16-tap shader `0xCDB19B26` performs
scalar log-luminance averaging/exp and exposure bounds, not RGBA bloom seeding;
it does not receive the bloom shoulder. No other matching LUT, RGBA bloom-seed,
Eagle Vision or gradient variant was found in this dump. This does not establish
coverage for shaders absent from the dump or every possible HUD effect.

### Baseline and port verification

Both unmodified baselines compile with `/O3 /WX`. FXC independently disassembled
the originals. Unlike the six AC2 baselines, their instruction streams differ:
literal packing/sign, irrelevant unused swizzle components and commuted multiply
operands. Symbolic per-component output graphs, declarations and texture accesses
match exactly after normalizing those equivalent forms. No decompiler logic repair
was needed; no synthetic dgVoodoo masks or shifted cbuffers were copied.

A native D3D9 HAL fixture on RTX 5090 rendered the original bytecode, unmodified
HLSL recompilation and edited replacement into RGBA32F for 24 configurations ×
1,024 pixels × two shaders. It covers signed/HDR scene channels, gradient values
around the 0.5 sign boundary, negative/zero/positive strength, nonwhite tints,
alpha, nonidentity and negative mask scales, UV offsets, Vanilla/invalid injection,
UI 80/203/500 and premultiplication.

- Original versus recompiled baseline: zero difference on all tested components.
- Edited versus independent reference equations: maximum normalized error
  `1.056e-6`; no NaN/Inf or failed comparisons.
- Edited alpha versus original: zero difference in all 48 cases.
- Vanilla/invalid-injection fallback matches the originals; the PsychoV gradient
  retains above-one RGB. Both modified shaders create successfully on native DX9.
- Modified compilation retains the existing shared ACES loop-variable warning;
  the standalone unmodified baselines pass warnings-as-errors. The x86 Release
  addon builds with the existing 31 shared-code warnings. Both new embedded
  instruction streams match the GPU-tested binaries, and both game-folder addon
  links match the Release SHA-256 (`brotherhood/release-build.json`).

Evidence is in `tmp/asscreedeziotrilogy/brotherhood/`: `native-baselines.zip`,
`dump-manifest.json`, `pixel-inventory.json`, `baseline-audit.json`,
`semantic-audit.json`, `post-details.json`, `validate.cpp` and `validation.log`.
The user subsequently reported that the Brotherhood changes were working well.
Control extremes and broader scene coverage remain manual checks.

## Local evidence and reproduction

### General native alpha-blending guard — Minerva investigation

Minerva's cinematic exposed strongly negative scene RGB and alpha ranging from
`-204` to `567.5` before the scene copy/downsample chain. The glow mask reached
66. Both readbacks were finite. This is a separate problem from excessive bloom
seed energy: source alpha outside `[0,1]` makes `SRCALPHA / INVSRCALPHA` blending
extrapolate instead of interpolate after the scene targets become FP16.

An actual D3D9 HAL test confirms that A8R8G8B8 clamps source alpha for blending,
whereas A16B16G16R16F preserves it. Blending source red 0.2 over destination red
0.8 with alpha 24 produced approximately -13.6 in FP16, versus 0.2 in UNORM.
Saturating only shader output alpha gives 0.2 in FP16 too.

`native_alpha.hpp` adds a draw-time guard for native SM3 shaders, including hashes
that have never been captured. It runs when RT0 is FP16, RGB writes and blending
are enabled, and the active color blend uses source alpha. Opaque, alpha-only,
pure additive ONE/ONE, MIN/MAX and non-FP16 draws keep their original shader.
Pure modulation now has the separate RGB-mask rule described below. This
protects this class of alpha extrapolation across
the trilogy; it does not establish that every future color artifact has this cause.

`native_alpha_patch.hpp` modifies the **actual bound shader bytecode**, including
an existing RenoDX replacement when applicable. It adds saturation only to
COLOR0 alpha destinations for source-alpha blends. Combined RGB/alpha instructions become two disjoint
output writes. RGB arithmetic, samplers, constants, discard, flow control, depth
and other MRT outputs are retained. No game constant or occupied temporary is
borrowed. Direct texture outputs use an unused temporary as described below.
Unsupported/predicated bytecode or a rejected native shader variant
falls back to the original. This path does not depend on HLSL decompilation.

The existing command-action pre/post mechanism executes each guarded draw once
and restores the original pixel shader immediately afterward. Native Draw*UP
temporary vertex/index buffers are bound for replay and then unbound. Explicit
callbacks run after existing scene/HUD replacement selection; other shaders use
the wildcard callback. Cached originals with alpha/RGB variants are bounded to 256 per
device and released at device destruction. Cache misses log the observed shader
hash and native blend factors for runtime diagnosis.

Validation in `tmp/asscreedeziotrilogy/animus/`:

- All 456 dumped native pixel shaders created successfully on the GPU. All 446
  variants requiring an alpha-output change also created successfully.
- 28 rendered UNORM/FP16 alpha comparisons and 18 actual draw-state selection
  checks passed (46 total). Full-addon Release syntax checking passed with the
  same 31 pre-existing shared-code warnings.
- The inspected `0xF2B09CC8` and `0xCF7E488A` HLSL baselines have equivalent
  output/discard expression graphs after accounting for register allocation,
  literal packing and commuted arithmetic. Unlike the original six ports, their
  recompiled instruction streams are not byte-identical. They are not shipped
  as new HLSL replacements.
- Initial live-file alpha experiments were inconclusive: the current addon
  scheduler only applies registered replacement hashes. A DevKit File label
  did not establish execution. The general addon guard requires a restart.

The user subsequently confirmed that the fix resolved the reported AC2 artifacts
and also worked in native Brotherhood. This is not exhaustive scene or lifecycle
coverage; video, device resets and longer sessions still need testing.
The x86 Release addon built successfully at 23:31 on September 15 and matches
the installed link (`animus/release-build.json`). The live path was restored to
the normal mod directory; no experimental per-material HLSL was added there.

### Multiplicative bloom feedback — Brotherhood, September 16

The affected scene showed large colored/black rectangles. EXR readbacks found
finite scene and glow inputs, but positive RGB infinities in the 960x540 glow
seed and nearly half of the summed bloom buffer. These are live resource reads,
not frozen per-draw captures. Native draw tracing confirmed this sequence:

1. `0xB4D7A117` downsamples scene and glow using `SRCALPHA / INVSRCALPHA`.
   The existing alpha guard is active.
2. `0xC9F2C59B` samples the scene seed and multiplies the persistent glow target
   using `DESTCOLOR / ZERO`, ADD, with RGBA writes.
3. Gaussian/downsample passes spread the invalid values through the bloom chain.

The recurrence is `history = scene * lerp(history, glow, alpha)`. Its feedback
gain is `scene * (1-alpha)`, which can exceed one even with alpha in `[0,1]`.
For scene 1.25 and alpha 0.1, the gain is 1.125. A 512-frame native GPU test
overflows FP16 to infinity; the UNORM reference remains bounded.

The general native guard now saturates **source RGB only** for pure modulation:
ADD with `DESTCOLOR / ZERO`, `ZERO / SRCCOLOR`, or `ZERO / INVSRCCOLOR`. This
restores the original mask range while leaving destination HDR and shader alpha
intact. It operates on blend state, not a list of affected materials or scenes.
Opaque, additive, alpha-only, MIN/MAX and non-FP16 draws retain their previous
policy. Source-alpha blends retain the alpha-only guard. This intentionally
disallows above-one amplification by a multiplicative source mask; it does not
clamp scene color globally or change the scene tonemapper/bloom shoulder.

The captured copy shader uses `texld oC0`. SM3 texture instructions reject a
saturation modifier, so `native_alpha_patch.hpp` redirects the same sample into
a temporary unused anywhere in the original bytecode, then writes the original
alpha and saturated RGB. Texture count, coordinates, sampler and control flow
are unchanged. ALU writes still use disjoint output masks without a temporary.
If all 32 temporaries are occupied, the texture-output variant is skipped.

Validation in `tmp/asscreedeziotrilogy/brotherhood/artifacts-20260916/`:

- Native creation succeeds for 995 dumped pixel shaders across both games and
  1,979 applicable alpha/RGB variants.
- 246 GPU blend/policy/channel checks pass, including the actual copy shader.
  RGB saturation leaves its alpha exactly 3; alpha saturation retains RGB
  `(2, -4, 0.5)` exactly. A destination HDR value of 4 times mask 0.25 stays 1.
- The 512-frame feedback test stays finite at 0.199219 with the fix, versus
  infinity without it. The 8-bit reference settles at 0.180392 due to rounding.
- `trace-both-safe.log` records the native blend states. `copy-rgb.cso` independently
  disassembles to one `texld`, an unchanged alpha MOV and a saturated RGB MOV.

The user restarted with this fix and confirmed it worked flawlessly. A restart
was needed because already infinite history cannot be repaired by multiplying
it by a bounded value. Broader gameplay and other multiplicative effects remain
manual regression checks.

### Material lighting ceiling — Brotherhood daylight courtyard

The courtyard capture contains 2,792 records, including 476 scene draws using
20 variants of the same material-lighting/fog sequence. The raw scene is FP16
(8x MSAA, resolved into FP16); its sunlit floor ROI has red exactly 1.0 in 58.48%
of pixels, while a candle reaches RGB `(2.285, 1.877, 1.010)`. The scene contains
no NaN/Inf. The material ceiling precedes the LUT/PsychoV pass and is separate
from the now-fixed bloom feedback.

Native material `0x7B2FB2FD` computes textured directional sunlight plus ambient
cube/world-lightmap lighting, then applies `mad_sat r0.xyz` before fog. Other
variants include detail/specular contributions at the same ceiling. Fog then
uses `c16`/`c17`, ending with `fog_weight * (fog_color - lighting) + lighting`.
The relevant decompilations were checked against the native assembly; this fix
transforms the original bytecode rather than recompiling those complex materials.

`native_lighting_patch.hpp` requires the full, exact five-instruction fog sequence
and its register dataflow after a saturated RGB arithmetic write. Only that
lighting saturation becomes an unclamped write followed by `max(lighting, 0)`.
An existing shader-defined zero supplies the black floor. No constants or
temporaries are occupied, no samples are changed, and the fog-weight saturation,
normals, attenuation, shadow tests, alpha and other MRT outputs remain intact.
This matters because these materials use `c52` for sunlight: the existing
postprocess injection range at `c50` must not be inserted into them.

The existing native draw guard selects the lighting variant only in PsychoV mode
for RGB writes into FP16, composing it with the alpha guard when needed. Pure
multiplicative masks retain the RGB-mask policy. Vanilla selects the original
material clamp. Shader variants are cached under the existing 256-original limit;
there is no per-material hash list or global removal of saturation modifiers.
Unrecognized instruction sequences are left unchanged.

Evidence in `tmp/asscreedeziotrilogy/brotherhood/lighting-20260916/`:

- `scene-raw.exr`, `scene-output.exr`, `ranges.txt` and draw/resource records
  document the ceiling. Readbacks are current live contents, not frozen snapshots.
- All 1,056 dumped AC2/Brotherhood pixel shaders, 2,101 applicable blend variants,
  and 138 matching lighting variants create successfully on native DX9.
- The actual original and patched `0x7B2FB2FD` material render under seven light
  levels (including negative/SDR/HDR), three fog weights and both shader variants.
  RGB matches independent lighting/fog equations; alpha and MRT1 remain unchanged.
  The resulting 336 component checks plus 246 blend checks all pass (582 total).
- Independent FXC disassembly confirms the original lighting `mad_sat` becomes
  `mad; max` using `c8.w = 0`; the complete fog and MRT tail is retained.

The user confirmed the restarted material-lighting correction works perfectly
in gameplay. A post-restart resource readback was not completed. Other material
families without this exact fog sequence may still have separate color ceilings.

### Revelations material lighting and volume fog — 2026-09-16

The native Revelations capture contains 4,168 draws. Of these, 1,157 material
draws use 35 variants with an explicit saturated lighting sum immediately before
fog. Representative `0x9E111D58` appears in 366 draws, including draw 2848 into
a 3840x2160 FP16 target with 8x MSAA. `0xD3A9EC63` appears in another 237 draws.
The scene/LUT shader is the already supported `0x48DCE479`; its input is FP16
and the LUT is 16-cubed BGRA8. A live pre-LUT readback is finite but has RGB
maxima `(1.0390625, 0.9765625, 0.9609375)`. This readback is current resource
content, not a frozen image of a particular draw or a per-material range test.

All 439 dumped pixel shaders were independently disassembled with FXC. The SM3
decompiler produced HLSL for 437; `0x12F30F2D` and `0xAAEB9005` failed and are
outside the matched material family. In `0x9E111D58`, a malformed nine-component
`float3` constructor was repaired to `g_WorldLightmapUVParameters.yyy`, as proven
by the original instruction swizzle. The baseline compiles with `/O3 /WX` and
passes native GPU comparisons against the original for the tested lighting and
fog configurations. Other decompilations are analysis evidence, not replacements.

Revelations retains the completed-lighting `mad_sat`, but its fog differs from
Brotherhood: boolean `b3` controls volume fog, `s7` supplies two packed fog samples,
and `c200` holds the distance-fog color/opacity. The final composition is
`(1 - opacity) * lighting + fog`, with saturated opacity. Some material variants
pack the final RGB into different temporary lanes or use a different arithmetic
opcode for the lighting ceiling.

`HasVolumeFogLightingTail` recognizes this family by its branches, sampler,
constants and register dataflow. It proves that the clamped material RGB is not
read or overwritten during fog construction, and that all three channels feed
the final fog composition with the computed `1 - opacity` weight. The matcher
requires a shader-defined literal one for that weight. It rejects other control
flow, relative addressing and unexpected RGB use rather than unclamping a broad
set of saturation instructions.

As with Brotherhood, the patch edits the original bytecode: remove only the
lighting saturation, then add `max(lighting, 0)` using an existing literal zero.
The material's constants, samples, fog opacity, shadow math, alpha and depth
outputs remain intact. No postprocess constants are injected into materials;
`c52` remains available for sunlight. The existing PsychoV/FP16 draw policy and
cache apply unchanged. Vanilla uses the original material shader.

Evidence in `tmp/asscreedeziotrilogy/revelations/`:

- `frame.json`, `material-matches.json` and `material-draw.json` identify the
  affected draws. `raw/`, `asm/` and `decompile-manifest.json` retain decompilation
  and independent assembly. `material-baseline.hlsl` is the repaired baseline.
- The matcher covers all 113 matching Revelations variants in the dump. The
  combined three-game scan creates 1,495 originals, 2,970 applicable blend
  variants and 251 lighting variants on native DX9, including 138 from Brotherhood.
- The actual original, recompiled baseline and patched `0x9E111D58` render at
  seven light levels, three distance-fog weights and with volume fog on/off.
  RGB matches independent lighting/fog equations within `1e-5`; alpha and the
  secondary depth output also pass. These 1,008 component checks plus 246 blend
  checks give 1,254 passes with zero failures. The separate Brotherhood material
  regression suite still passes all 582 checks with the extended matcher.
- `material-patched.asm` independently disassembles the edited original shader.

After a Release rebuild/restart, logs confirm `lighting=1` for `0x9E111D58` and
`0xD3A9EC63`, including `0x9E111D58` draws with the alpha guard. A subsequent
3,062-draw gameplay capture uses `0x9E111D58` in 219 draws. Its live pre-LUT
resource reaches RGB `(1.76171875, 1.794921875, 1.9697265625)` with all 8,294,400
pixels finite and no NaN/Inf. See `restart-gameplay-lut.json`,
`restart-pre-lut.exr`, `restart-pre-lut-stats.json` and `restart-reshade.log`.
This is a different capture from the original and is not a controlled visual
before/after comparison. Visual confirmation, other material families and
shaders absent from the dump remain outside this validation.

### Depth-faded wind/smoke color — Revelations, 2026-09-16

The affected 824-draw frame contains blue windtrails near Ezio and the translucent
figure on the cliff platform. They are already blue in the finite FP16 input to
LUT draw 775. Switching to Vanilla restores white in that input and the user
confirmed the visible change. These are live readbacks of animated effects, not
pixel-aligned before/after snapshots.

Soft-particle shader `0xF7FE7888` appears in draws 740 and 752 and receives the
general lighting correction with SRCALPHA/INVSRCALPHA blending. Its layered,
vertex-tinted color is added to ambient/world-lightmap lighting, saturated, then
fogged. It reconstructs scene depth from s8/c0, bounds a depth-intersection fade,
and multiplies that into opacity. Removing its RGB saturation exposes an authored
effect color beyond the original range; preserving only alpha does not preserve
the wind's original white appearance.

`HasDepthFadedOpacity` follows the sampled-depth, projection-offset, reciprocal,
depth-difference and saturated-fade dependency through temporary channels into
COLOR0 alpha. `UnclampMaterialLighting` leaves the original color instructions
intact for that effect family. The existing alpha guard remains active. This
does not exclude all transparency or all depth readers, and uses no shader hash
list. The current dumps identify six such previously expanded variants in
Revelations; Brotherhood's existing matches remain unchanged.

Evidence in `tmp/asscreedeziotrilogy/windtrails/`:

- The original F7FE7888 bytecode is independently disassembled with FXC and
  decompiled with HlslDecompiler. Its malformed nine-component c88.y constructor
  is repaired using the original swizzle. The baseline compiles with `/O3 /WX`.
  Its instruction allocation differs, so equivalence is established for the
  rendered cases rather than claimed byte-identical.
- 6,912 native GPU component checks compare original, decompiled, previously
  unclamped and corrected variants across colored lighting, depth fades,
  opacity, distance fog and the volume-fog branch. Original and baseline agree
  exactly in these cases. The corrected RGB matches the original while COLOR0
  alpha is bounded; the secondary output remains unchanged. Four near-match
  mutations reject missing depth sampling, projection, bounded fade or alpha use.
- All 1,621 current dumped pixel shaders, 3,221 applicable blend variants and
  284 remaining lighting variants create successfully on native DX9. The
  Revelations suite passes 1,254 checks and Brotherhood passes 582, including
  material HDR, fog, alpha, secondary outputs and prior blend regressions.
- The `clang-x86-release` addon builds successfully, and all three game-folder
  links match its SHA-256 (`release-build.json`). Restart logs show F7FE7888 and
  E07A26BE using `lighting=0, bound=alpha` while surface shaders retain lighting
  expansion. F7FE7888 appears in three draws in the new 587-draw capture. Both
  pre/post-LUT readbacks have all 8,294,400 pixels finite. The camera has moved;
  this is not an aligned visual comparison. The user subsequently reported that
  the correction is working very well so far.
  The final highlight/LUT/UI shaders are unchanged.

### AC2 material-clamp audit — 2026-09-16

Independently disassembled all 456 native AC2 pixel shaders in the current dump
with FXC and ran the shipping `UnclampMaterialLighting` matcher against their
original bytecode: **zero matches**. The 138 matches from the earlier combined
AC2/Brotherhood scan belong to Brotherhood. The patch is available in both games,
but no AC2-specific extension or shader replacement is justified by this dump.

The AC2 scan found 195 shaders with the distance-based `c16`/`c17` fog path.
Representative normal-mapped material `0x6C45A091` already computes its completed
lighting with `mad r0.xyz, r2, r0, r1`, followed by the fog subtraction and output
`mad`, without RGB saturation. The more complex `0x03D0540C` likewise adds its
direct, ambient/world-lightmap and specular terms without a final color ceiling.
This differs from Brotherhood's completed-lighting `mad_sat`.

Reviewed RGB saturation sites include projected shadow coordinates, diffuse
texture/mask shaping and animated effect masks; scalar sites also bound normal
dot products, attenuation, fog and lightmap interpolation. These are not the
completed-lighting ceiling and remain unchanged. Direct output saturations belong
to Eagle Vision (already replaced), a mask-color pass, a normal-dot-light pass,
and previous-frame blending (`0xE32AD74E`); the latter is a separate postprocess
candidate, not an established material-lighting fix.

Evidence: `tmp/asscreedeziotrilogy/ac2-lighting/asm/`, `audit.json`,
`rgb-clamps.txt` and `match.log`. This is a shader-dump audit, not a new in-game
HDR readback or proof about shaders absent from the dump. No rendering code or
Release binary changed for this audit.

Original dump: `E:\SteamLibrary\steamapps\common\Assassin's Creed 2\renodx-dev\dump`.
Workspace evidence: `tmp/asscreedeziotrilogy/shader-audit/`:

- `raw/`: all pixel decompilations and decompiler disassembly.
- `native-baselines.zip`, `baseline/`, `baseline-manifest.json`: original binaries,
  independent FXC assembly, recompilation,
  SHA-256 identities and exact instruction-token comparison for the six targets.
- `ported/`, `validate.cpp`, `reference.cs_5_0.hlsl`, `results/`: SM3 compilation
  and cross-API rendered comparisons. `validation.log` retains the strict
  encoded-tolerance failures; diagnostic comparison logs isolate their source.
- `runtime/`: saved native draw/resource evidence and live EXR readbacks.
- `build.log`: the x86 Release addon build.

Scratch files and original binaries are not required to build the mod. Keep
`.cso` files out of the source/live directory so they cannot shadow editable HLSL.
Build `asscreedeziotrilogy` with `clang-x86-release` while all three games are closed. The game
folder's addon symlink points to `build32/Release/renodx-asscreedeziotrilogy.addon32`.
The earlier AC2 overlay-description build is recorded in `final-build.json`.
The earlier Brotherhood build and its game-folder links are recorded separately
in `brotherhood/release-build.json`. The highlight-fit Release build, matching
GPU-tested shader instruction streams and all three game-folder links are
recorded in `highlights/release-build.json`.

## Native presentation pacing and synchronization — 2026-09-16

`native_presentation.hpp` makes the DX11 HDR proxy the presentation owner for
successfully submitted frames. A per-thread, single-use token suppresses the
following native device Present, PresentEx or swapchain Present. ReShade still
executes its normal wrapper/events. Failed or skipped proxy frames fall through
to the original native method; suppressed calls check native cooperative state.
Tokens clear at frame boundaries. Hooks replace individual Present slots because
D3D9 uses additional private vtable entries beyond its public COM interface.
Device slots are restored on host swapchain destruction as well as device teardown,
since Reset can replace their dispatch entries. Shared slot ownership is tracked.

The shared proxy utility adds an opt-in tearing policy and a post-Present result
callback; defaults preserve other mods' behavior. Ezio disables forced tearing.
The game captures native `create_swapchain` VSync requests by window and assigns
that interval to its DX11 proxy's creation descriptor. ReShade then applies that
interval at presentation. This avoids relying on native presentation parameters
after driver/overlay changes and keeps temporary helper windows separate.

The two existing device-proxy wait-idle options are enabled for this mod. The
DX9 producer must finish writing the shared texture before the DX11 consumer
copies it; that copy must finish before the producer reuses the shared storage.
These DX9 shared resources have no keyed mutex. Merely submitting commands did
not establish that ownership transfer: an alternating-color test observed 20
stale images in 240 frames. Both waits reduce that result to zero stale images,
with no readback failures.

Verification artifacts are in `tmp/asscreedeziotrilogy/pacing/`:

- `brotherhood-baseline.csv`: stable original addon, RTSS cap 60, about 30 HDR
  DXGI presents/sec and 30 discarded native DX9 presents/sec. Forced tearing
  was enabled and DXGI synchronization interval was zero.
- `brotherhood-latest-rtss60.csv`: final synchronized Release, capped relaunch,
  479 HDR frames at 60.0085 FPS, no native DX9 presents, no dropped frames,
  median 16.6667 ms and p99 16.6889 ms. The user subsequently confirmed smooth
  motion and described the result as working perfectly.
- `fixed/frame-identity-synced.txt`: 240 alternating frames, zero stale images.
- `fixed/pacing-synced.txt`: all three native Present APIs, four resolution/MSAA
  cycles, interval 0/1 forwarding, single presentation and injected-failure
  native fallback/recovery pass.
- `fixed/reset-synchronized.txt` and `fixed/reset-synchronized-devkit.txt`:
  12 resolution/MSAA cycles each, helper-device creation on another thread,
  identical gray HDR readbacks and updated red readbacks, with/without DevKit.

Limits: an earlier in-game reset capture still showed 30 HDR FPS, including a
capture before the final capped relaunch. The last requested reset was followed
by a game crash/restart that the user attributed to another cause, so no clean
post-reset frame-time capture completed. Automated reset tests pass and the
user confirms smooth motion, but repeat the capped in-game reset measurement
before claiming comprehensive reset/driver-limiter coverage. The isolated RTSS
fixture also differs from the game: it limits the original native path while
failing to limit the candidate's proxy. It is useful for handoff/entry-point
checks, not proof of every external limiter's interception behavior. NVIDIA's
separate FPS limiter and AC2/Revelations pacing still need explicit runtime checks.

The linked x86 Release artifact verified for pacing, before Video AutoHDR, was
`build32/Release/renodx-asscreedeziotrilogy.addon32`, SHA-256
`094F39572FF262DB3E44890BB8B4297DB3691994A131B432ADDF7D6441DCE898`.
Only the task-specific temporary RTSS fixture profile was created and removed.
Game/global RTSS profiles and NVIDIA settings were not modified by the addon.

## Video AutoHDR — 2026-09-16

The user identified native video shader `0x947F8B85`. The AC2, Brotherhood and
Revelations dumps are byte-identical (252 bytes, SHA-256
`6A7974F0A97B2AE89B2354FC7939CD0B6D0F28A356CAF0EB248AC3C2AB264A53`). Its
register-preserving HlslDecompiler baseline compiles to exactly the original
instruction DWORDs after comment removal: sample `s0` at `v0.xy`, write sample
RGB, write `c0.w` alpha. Texture alpha is unused. The only original constant is
`c0`; injection at `c50`–`c56` is safe.

`Video → Video AutoHDR` uses the shared BT.2446A inverse also used by
`asscreed3original`, adapted to the trilogy's output domain. It defaults to
BT2446A, is enabled with PsychoV, and is available in both settings modes for
all three games. Off/Vanilla bypass the conversion; Preset Off selects Off and
Reset All restores BT2446A. The setting uses the former padding float at `c56.z`,
so the injection remains 112 bytes. No resources or video-observation caches are
added.

The sampled SDR video is decoded with gamma 2.4 for the BT.1886 reference expected
by BT.2446A. The inverse target is `Peak Brightness * 203 / Game Brightness`;
its result is normalized to `Peak Brightness / Game Brightness`. This lets Game
Brightness adjust the curve while retaining the display endpoint. The selected
BT.709/BT.2020 gamut is respected; signed BT.709 coordinates can carry BT.2020
colors. The shader removes the existing display shoulder, then writes gamma-2.2
FP16 for native composition. The unchanged DX11 proxy reapplies that shoulder
once and calls `SwapChainPass` for HDR10. The original fade alpha remains `c0.w`,
with the existing native blend guard applied after shader selection. As with
other gamma-space native draws, visual fade behavior still needs game testing.

Verification:

- FXC SM3 build: 160 instruction slots, one texture sample. The embedded shader
  matches the GPU-tested instruction stream; scene/HUD/proxy streams are unchanged.
- 216 native DX9 configurations cover Off/On, Vanilla/PsychoV, 400/1000/4000-nit
  peaks, 80/203/500-nit Game Brightness, both gamut targets and alpha 0/0.25/1.
  Their 497,664 pixels are passed through FP16 quantization and the actual DX11
  HDR10 shader. All outputs are finite and peak-bounded; Off/Vanilla RGB and alpha
  are exact. Gray ramps are monotonic. Maximum white-endpoint error is 0.47 nit;
  maximum deviation from an independent scalar BT.2446A reference is 1.09 nits
  at the tested peaks. Game Brightness changes only exhibit sub-nit endpoint
  rounding, with no substantial brightness reversal.
- An isolated x86 fixture loads the Release addon and installed ReShade without
  DevKit, submits the original hash into the cloned backbuffer and reads HDR10.
  At Peak 1000/Game 203, white reads PQ code 769/1023 (about 1000 nits), compared
  with 594/1023 for the preceding addon. Vertex-buffer playback passes two
  resolution/MSAA reset cycles with helper-device creation and updated colors.
- A synthetic `DrawPrimitiveUP` version crashes inside ReShade on its first
  post-reset draw with both the preceding pacing addon and the video addon.
  That fixture limitation predates this change; it is not a successful UP/reset
  verification. No shared runtime changes were made for video.

Evidence and fixtures: `tmp/asscreedeziotrilogy/video/`. Build target:
`asscreedeziotrilogy`, preset `clang-x86-release`. In-game video/fade/subtitle
checks remain pending across the trilogy; verify Off/BT2446A, Vanilla, Preset
Off and return to gameplay. The shader identity alone does not prove every
video's resource path, particularly letterboxed playback at other aspect ratios.
The user subsequently confirmed flawless video playback.

## Brotherhood cutscene material variants — 2026-09-16

A 566-draw capture of the vault cutscene exposed more final material-lighting
clamps; the user identified Ezio's armor/face as the affected area. The render
target for the inspected material is 3840x2160, 8x MSAA, RGBA16F. This is a shader
ceiling, not an SDR render-target format. The earlier matcher assumed lighting
in `rN.xyz` followed immediately by a fog calculation in `rN.w`.

Examples of the missing layouts:

- `0xCAF7D4D0`, `0xCFFCA65D`, `0x377A2FE6`: completed lighting occupies `r0.yzw`,
  while fog uses `r0.x` before RGB is written to the output.
- `0x0AFC541E`, `0xFF81F1B0`: the shader computes fog before completing lighting;
  only the final interpolation follows the color clamp.
- `0x557C83EA`, `0x712A66C5`: an interpolated vertex value supplies fog strength.

`HasDistanceFogLightingTail` now follows the three clamped lanes into
`fog_weight * (c16.rgb - lighting) + lighting`, permitting a separate scalar
fog register, earlier fog arithmetic and interpolated fog. It verifies the
material's subsequent `z/w` output to MRT1, rejects coefficient/color/delta
aliasing, and rejects shader-defined literals at the game's fog registers.
RGB lane packing is derived from the destination write mask and checked at both
reads in the fog interpolation. Only the final color saturation is removed;
a MAX with an existing zero keeps the black floor in those same lanes. No
extra constants or temporary registers are used. Volume fog retains its former
checks, depth-faded particles retain their authored clamp, and Vanilla still
selects the original shader through the existing native runtime policy.

All 60 pixel shaders captured in this frame decompiled successfully. The five
selected GPU baselines required one syntax repair each: HlslDecompiler emitted
a `float3` containing three copies of an already replicated `.yyy` vector;
the repair uses that vector directly. FXC `/O3 /WX` builds those baselines, and
their outputs match the original shaders exactly in the tested lighting, fog
and opacity cases. The shipping correction patches the original bytecode, so
it does not depend on recompiling these decompilations.

Validation:

- 19 previously missed variants account for 143 captured draws. Across all
  current dumps, 151 additional Brotherhood variants match; no previous matches
  are lost, and AC2/Revelations classification is unchanged.
- Five real material shaders pass 7,560 native GPU component checks for original,
  baseline and patched RGB, fog interpolation, alpha and MRT depth. Above-one
  lighting is exercised for each shader. Twenty near-match mutations are rejected.
- All 1,623 dumped pixel shaders, 3,225 bounded variants and 435 lighting variants
  create successfully. Existing volume-fog/blend tests pass 1,254 checks; the
  windtrail test passes 6,912 checks with unchanged baseline output.
- Brotherhood closed before the live baseline/replacement comparison. No live
  replacement or path change was applied. The Release addon was rebuilt for the
  next launch; visual confirmation of the cutscene remains pending.

Evidence: `tmp/asscreedeziotrilogy/brotherhood/cutscene-20260916/`. Build target:
`asscreedeziotrilogy`, preset `clang-x86-release`. Check the affected armor and
face in PsychoV/Vanilla, including fog, transparent edges and the return to
gameplay. The new matcher is shared across scenes, without new hash entries.

### Brotherhood building lighting: independent fog packing — 2026-09-16

The next captured outdoor frame contains 2,492 draws and 53 pixel shaders.
The user identified the window surrounds and curved structure on the right as
the remaining flat-looking surfaces. Three material variants in this frame
contain additional compiler allocations of the same final lighting clamp:

- `0xBA9071B6` (46 draws): lighting occupies `r0.xyw`; fog delta occupies
  `r1.yzw`, with the fog coefficient in `r1.x`.
- `0x4017670D` (one draw): lighting occupies `r0.yzw`; fog delta occupies
  `r1.yzw`, and fog distance is read from `r2.x` into `r1.x`.
- `0x010297B9` (five draws, window/cubemap material): lighting occupies
  `r0.xyz`, while fog distance is read from `r1.w` into `r0.w`.

`HasDistanceFogLightingTail` now derives both lighting and delta lane mappings
from their write masks, verifies c16 RGB and both lighting/delta reads in order,
and rejects any fog coefficient overlapping the written delta lanes. The first
fog instruction may read distance from a different plain temporary/input lane;
that lane must not depend on the clamped lighting. Fog constants, all fog
arithmetic, the secondary depth output, authored particle exclusions and
Vanilla selection retain their prior checks and behavior.

Validation:

- All 53 captured shaders decompile. The three selected baselines need only
  the previously documented replicated-vector constructor repair; FXC `/O3
  /WX` compiles them. Native GPU output matches the originals exactly across
  the tested light, fog and alpha values.
- 4,536 component checks pass for the original, baseline and patched shaders,
  with above-one lighting exercised in every shader. Twelve deliberately
  broken near-matches are rejected.
- Across the same dump corpus, 47 additional Brotherhood shaders match; no
  old matches are lost and AC2/Revelations matching is unchanged. All 1,639
  original shaders, 3,257 bounded variants and 486 lighting variants create.
- Existing cutscene (7,560), volume-fog/blend (1,254) and windtrail (6,912)
  GPU checks pass, including their existing rejection tests.
- The pre-LUT and LUT resources are RGBA16F. Live readbacks are finite, but
  capture changing live contents, not a frozen before/after comparison.
  DevKit reported all three live shaders active; a subsequent 30-material
  diagnostic-color test did not reach the visible material draws. Consequently
  no visual success or live baseline equivalence is claimed from that attempt.
  Temporary shaders were unloaded and the original empty live path restored.
- The Release target rebuilt successfully. On relaunch, the runtime logged
  `lighting=1, bound=none` for all three identified hashes. A subsequent street
  scene has finite pre-LUT and graded RGBA16F readbacks (no NaN/Inf). The user
  confirmed the windows and right-hand structure are corrected after restart.

Evidence: `tmp/asscreedeziotrilogy/brotherhood/building-20260916/`. Release SHA256:
`A0949CE2659ADEDC0EB281EF6453FD3AC14166F77D41A4A6BF993F280601B9C6`.
No additional hash-addressed shipping shaders are needed for these variants.

## LUT encoding correction on the GitHub baseline — 2026-09-16

Restored this mod from `hartapfel/renodx` main at
`85f887d89a3a96f91808b9a54fe67bbe4c262220`, then applied only the requested
LUT encoding correction. The original LUT-first PsychoV pipeline and controls
are retained; the local LUT Contrast/color-transfer experiments are removed.

`AC2SampleLUTLinear` encodes bounded linear lookup values to sRGB, samples the
native LUT, decodes its sRGB output, then applies
`renodx::color::correct::GammaSafe(graded_linear, false, 2.2f)` once to emulate
the SDR display EOTF. The HDR bridge and direct gray-anchor measurement share
this helper. Scene transport, Vanilla, HUD/video and presentation remain unchanged.
With no intervening processing, sRGB decode plus this emulation is algebraically
equivalent to decoding the sampled code values with gamma 2.2.

Verification: `tmp/asscreedeziotrilogy/restore-github/`. The native 2,962-slot
scene shader creates successfully. Seven synthetic LUTs and 420 configurations
per sweep cover both gamut targets, multiple peak/Game Brightness values and
auto/manual compression. The isolated LUT boundary agrees with an independent
sRGB/power-2.2 reference within `1e-6` linear RGB. Color Filter 0/50/100 passes
native DX9 and actual DX11 HDR10 presentation checks with finite output, zero
scene alpha and peak rounding below 0.05 PQ10 code steps. Vanilla matches the
GitHub-era baseline exactly in the tested cases. In-game visual checks remain
pending. Build target: `asscreedeziotrilogy`, preset `clang-x86-release`.
The Release build succeeded; its embedded scene instructions match the GPU-tested
shader, all other shader instructions are unchanged, and all three game links
resolve to the verified addon, SHA-256
`198AFE002D3AC8DA8D39C8858F6E72DA7DFA92A274B95B807DBF80E6F81E8A9E`.
