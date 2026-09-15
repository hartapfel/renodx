# Native Ezio Trilogy shader port

Behavior reference: [the AC2 DX11 implementation guide](../asscreed2/IMPLEMENTATION.md).
This port keeps native D3D9 rendering and uses RenoDX's DX11 device proxy only for
HDR10 presentation. AC2 and Brotherhood have native mappings; their validation
coverage and remaining runtime checks are recorded below.

## Shader mapping and decompilation proof

The native dump contains 393 `ps_3_0` and 206 `vs_3_0` shaders. All 393 pixel
shaders decompiled with the register-preserving mode of HlslDecompiler at
`D:\Downloads\HlslDecompiler-master\HlslDecompiler-master`. The AST simplifier
was not used. The initial AC2 port replaces the six matching pixel shaders below;
Brotherhood adds two variants described in its section below.

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
  PsychoV-30 and user grading. Automatic compression retains the 4000-nit working
  range followed by the display shoulder. Manual compression, Color Filter,
  shadow correction, anchor ceiling and scalar contrast follow the DX11 source.
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
  replace only the final RGB ceiling with the reference display-headroom shoulder.
  The already-tonemapped scene is not tone-mapped a second time. Vanilla retains
  the original saturation.
- **HUD:** inspect actual D3D9 `COLORWRITEENABLE`, `ALPHABLENDENABLE`, `SRCBLEND`,
  `DESTBLEND` and `BLENDOP`. Exclude alpha-only/no-color, multiplicative, and
  pre-LUT additive `ONE + ONE` draws. Eligible draws decode, scale by
  `UIWhite / GameWhite`, and re-encode; premultiplied alpha is handled explicitly.
  The HUD shaders' original alpha values are preserved.
- **Output:** version 30 enables the port. PsychoV composes in gamma 2.2;
  Vanilla/Off uses sRGB. `SwapChainPass` still owns HDR10 output encoding.
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
Brotherhood's additional evidence follows below. Revelations remains unmapped.

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
Build `asscreedeziotrilogy` with `clang-x86-release` while both games are closed. The game
folder's addon symlink points to `build32/Release/renodx-asscreedeziotrilogy.addon32`.
The earlier AC2 overlay-description build is recorded in `final-build.json`.
The latest Brotherhood build and both game-folder links are recorded separately
in `brotherhood/release-build.json`.
