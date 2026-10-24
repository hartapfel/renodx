# Witcher 3 Classic: BlitzFX compatibility

## Cutscene grade family and dump audit — 2026-10-24

PID 36924's cutscene uses **`A123EB15`** after `201C53B4` reconstruction, instead
of the already replaced `114D8828`. Exact preserved t0 input at this final
grade is signed FP16, 3840×2160, with maximum RGB **(16.25,13.984375,10.046875)**
and maximum luminance 14.10843125. Native `A123EB15` then applies SDR analytic
grading and saturated levels. Thus this scene has an upstream HDR source and
an uncovered final shader clamp; no additional swapchain/resource upgrade or
global exposure change is required.

An offline scan of the current game dump and the extracted BlitzFX 1.1.0
embedded set found **1,179 distinct DXBC programs**, deduplicated by SHEX/SHDR
bytes rather than container CRC. Embedded-container names differ from live
hashes, so `dump-audit.json` records all paths for each program. DevKit handled
live shader inspection/dumping first. Inactive variants not tracked in this
process were decompiled from their saved original dumps using local
`cmd_Decompiler.exe -D`; these are offline candidates, not falsely labeled live
captures. The complete identified BlitzFX final-grade family is now covered:

| Live/dumped hash | Native differences preserved |
| --- | --- |
| `114D8828` | Existing analytic vignette + native CA |
| `A123EB15` | Current cutscene: native CA, no vignette |
| `399CBE16` | Texture vignette, no native CA |
| `445EB59C` | Texture vignette + native CA |
| `4FC8DAEB` | Analytic vignette, no native CA |
| `E276DFB3` | No vignette or native CA |

The five additions use the same reversible HDR/wide-gamut grade/PsychoV path
as `114D8828`. Native color-grading enable bits, dither, fades, borders and
diagnostic outputs are preserved. Correct 16/18-float4 grade arrays and absent
vignette parameters are explicit; never read cb1[44] in a 44-entry variant.
`blitzfx/final_effects.hlsli` shares the existing post-reconstruction RCAS/CA
sampling across all six, followed by native grade/vignette, PsychoV and grain.
Native CA is skipped only when its replacement owns it. Vanilla/debug branches
retain the original shader, including packed flag semantics and graphics-white
normalization. Existing intentional hair/material clamps are unchanged.

The audit also found **`249DA2F1` CS**, an alternate BlitzFX camera motion-blur
pass. Its depth and center-color integer loads already address the render
rectangle, but normalized t51 mask and t52 color samples/gathers traverse the
output-sized pool. The new replacement converts those at the texture boundary
and joins the recognized-BlitzFX + active-world + upscaling gate. It keeps
reprojection, temporal jitter, blur length, parity dither and its 16 native mask
gathers; no pass, resource, geometry replay or production readback is added.

For mask gathers, moving UVs inward by one pixel changes the native mask near
edges. `BlitzGatherScenePoolRed` keeps a hardware gather for interior taps and
loads/clamps its four texels only when the footprint crosses the active border.
Its border index accounts for sampler subtexel rounding, which matters for odd
sizes and reciprocal roundoff at texel centers. See Microsoft's
[D3D11 texture addressing specification](https://microsoft.github.io/DirectX-Specs/d3d/archive/D3D11_3_FunctionalSpec.htm)
for normalized-to-texel conversion and fixed-point sampling precision. The
implementation is validated on WARP and NVIDIA; do not assume a simple floating
`floor` reproduces the sampler at those boundaries.

Other reviewed matches are deliberately retained:

- `343C1933`/`914513D5` produce bounded scalar exposure/luminance analysis maps,
  not scene RGB. Their saturates are intentional. `002F0E8C`/`9BF1C914` compare
  reconstructed curves and return diagnostic colors; they are not scene curves.
- Captured legacy cutscene DoF `258D4DFA`/`FA395B8E` uses distinct allocation UVs
  for color and depth. Quality's upper limits correspond to 1280/1920 color
  and 2560/3840 depth, with native half-texel margins. Do not scale them again.
- Bloom-pyramid CSs use explicit allocation dimensions. Additional active-edge
  filtering remains a separate investigation if an artifact is observed.
- Broad grade-constant matches also include skin/material shaders. They are not
  final-grade candidates; preserve their material constraints.
- Underwater distortion `F8A88CDD` was not live here. Its mixed b0 domains need
  an underwater input capture before a safe edit. This audit covers the saved
  corpus, not every future game permutation or every possible effect setting.

Validation: the expanded effects suite passes on **WARP and NVIDIA RTX 5090**.
Each of six final grades passes 64 native/debug permutations (384 total), HDR
range, disabled-grade isolation, RCAS and zero replacement-CA checks. Existing
exposure, blended weather curves, LUTs, bloom, shadows and effects regressions
pass. The postprocess fixture now adds 12 camera-motion cases to the 48 DoF
cases, including no-motion/full-size and odd dimensions with poisoned unused
pixels. Maximum motion-blur difference is **4.76837e-7 NVIDIA**, **0.00170135
WARP**; WARP accumulates filter-weight rounding and uses the same .002 absolute
tolerance as native material comparisons. The faulty original pool path fails
measurably. The isolated Release links and the normal Release object/embeds
compile. Isolated addon SHA256:
`8C21D087ADE2E203571DCA1D1F63BDBA87F395608AD0DBF71F7A05C7B05560EF`.

Evidence: `tmp/witcher3classic-investigation/blitzfx-20261024/cutscene-permutations/`
contains `scan.py`, `dump-audit.json`, `audit-decisions.json`, original shaders,
`final-grade-inputs.json`, `cutscene-pre-grade.png`, `legacy-blur-inputs.json`,
grade cbuffers and WARP/NVIDIA/build logs. During documentation the user rebuilt
the normal Release addon (02:09:05 local), SHA256
`156EFC84721C4F79EAE0943FC54011A0FEC72AB5FC000E1E7FA10EE1ED18183B`, and restarted
as PID 27468. Addon loading and `A123EB15` registration are confirmed; all seven
changed shader blobs match the tested isolated checkout (`tested-embeds.json`).
The follow-up one-frame constants capture completed on `A123EB15` at 3840×2160
(`rebuilt-cutscene-inputs.json`), confirming the cutscene draw occurred in the
rebuilt process. Corrected output-range/visual acceptance still requires the
user's comparison; this capture preserves inputs, not post-draw color. Verify
this exact cutscene, the HDR/Vanilla toggle, RCAS/CA,
texture/analytic vignette scenes and motion blur in Quality/Performance/DLAA.

## Depth of field at reduced render sizes — 2026-10-24

DevKit PID 7964 captured BlitzFX gameplay DoF at **Quality 2560×1440** within
3840×2160 scene/CoC allocations. The half-resolution color and max-CoC textures
remain 1920×1080, with an active 1280×720 region. The chain executes after
`5AA6AFFF` filmic mapping and before the game's LUT/TAA boundary:

| Shader | Role and correction |
| --- | --- |
| `312A3BFB` PS | Color/depth setup uses integer loads; retained unchanged. |
| `C648D20B` CS | Full-resolution circle of confusion uses integer raw-depth loads and native focus parameters; retained unchanged. |
| `B018A95A` CS | CoC-weighted color reduction and max-CoC. Its normalized UVs sampled the full scene/CoC allocation. Convert both inputs separately at the gather boundary; preserve native red, green and blue gather channels. |
| `48885E0D` CS | 49-tap half-resolution bokeh. Convert the complete center-plus-kernel UV into the half-resolution allocation and clamp filtering to the active rectangle. Integer center/max-CoC reads remain unchanged. |
| `B73522BB` CS | Nine-tap unpremultiplied color dilation. Apply the same half-resolution conversion, preserving zero-alpha rejection and maximum-color math. |
| `AE334616` PS | Nine-tap full-resolution composite samples the half-resolution blurred color. Convert that sample's UV, while leaving full-resolution integer CoC loads, alpha ramp and depth output intact. |

The four replacements use the existing gate in `addon.cpp`: recognized BlitzFX,
an active main world frame and reduced resolution. They disable HDR b13 injection and
add no passes, resources, readbacks or geometry replays. DLAA and standalone
without BlitzFX keep the original shaders. The native 49-entry bokeh table is
shared in `blitzfx/dof_kernel.hlsli`; the nine-tap stages use its first ring.
Do not scale only the blur center: the kernel offsets must undergo the same
render-to-allocation conversion. Half extents use integer truncation for odd
render dimensions. Focus distances, bokeh strength and the native pass order
remain unchanged; this is not a focus/exposure retune.

Decompiler repairs also matter here: `B018A95A` emits `.Gather` for all three
color channels, but original DXBC uses sampler-channel x/y/z. Use explicit
GatherRed/Green/Blue. The cinematic-focus selector is a packed nonzero flag;
test `asuint(cb1[52].z) != 0u`, not a float comparison that can flush its small
bit-pattern value to zero. Native CS UAV declarations/stores and thread IDs
were restored explicitly from disassembly.

`tests/blitzfx_dof.cpp` compares the exact embedded replacements with original
DXBC operating on physically smaller textures. Unused larger-pool pixels are
poisoned with distinct RGB values. It checks all pixels/channels (both reduction
UAVs), six render sizes including odd 43×31, gameplay and packed cinematic flags,
zero/nonzero CoC/alpha, blur/filter edges and the final alpha ramp. **48 cases
pass on WARP and NVIDIA RTX 5090**. Maximum corrected error is 0.000318468 on
WARP and 0.0000297427 on NVIDIA; reduction matches exactly. Differently sized
textures can quantize filter weights differently. The fixture additionally
requires every original larger-pool shader to fail measurably under poison.
Those poison errors are diagnostic values, not measured scene brightness.

Evidence: `tmp/witcher3classic-investigation/blitzfx-20261024/depth-of-field/`
contains the six original shaders/disassembly, `late-draws.json`, per-pass draw
details, exact reduction/blur/composite input captures and previews, test logs
and Release build logs. The isolated Release addon links, and normal Release
object/embeds compile; the loaded root DLL has not been overwritten. Isolated
addon SHA256 `B4782016E8DBF9142549EA8D665B696414EFA6E0427148263195A237C0D38085`.
During documentation, a user rebuild of the normal Release DLL was observed at
01:51:01 local: SHA256 `C408FA42B49CEA20A056C929172AAD2E94B2A9AF6F30EDC5CC5DBB21E320D267`.
Startup completed: PID 36924 reached gameplay and DevKit confirmed all four
replacements registered as Add-on shaders (`rebuilt-shader-status.json`).
Visual acceptance is still pending. Compare the same near/far
scene in Quality, Performance and DLAA; also check a cinematic focus transition
and Balanced's odd render dimensions. Keep motion blur, HDR grading and focus
settings fixed during comparisons.

## Geralt brown face after Igni — 2026-10-24

The user paused a scene with Geralt's face tinted brown after casting Igni.
DevKit PID 37460 preserved the tint in `114D8828` t0 **before final HDR grading**.
Disabling Object Motion immediately restored the normal face in the same paused
scene, confirmed by the user and another exact pre-draw capture. The fault is
in the replacement skin material, not a global PsychoV/LUT adjustment.

BlitzFX hero-face PS **`90BFECE8`** was decompiled incorrectly: after the tiled
local-light loop, eight fixed reads of **`cb13[0].xyz`** (the sun direction)
became **`cb13[r22.y+0].xyz`**. The register is temporary loop state and can hold
the last local-light index or a computed color afterward. Temporary Igni lights
therefore corrupt later directional skin lighting until the light list changes
again. Original DXBC explicitly uses the fixed index at instructions 516, 527,
542, 545, 547 and the other directional-light uses.

The fix restores those eight static reads in
`blitzfx/0x90BFECE8.ps_5_0.hlsl`; dynamic reads **inside** the local-light loop
remain intact. Motion outputs, material clamps, sun intensity and HDR grading
are unchanged. An ordered cbuffer-access audit of all nine BlitzFX material
replacements found this static-to-relative error only in the hero skin shader;
the hair shader's accesses already match its original DXBC.

`tests/hero_lighting.cpp` uses captured skin cbuffers, controlled textures and a
raw tile list with zero/one/three lights, final index zero/five, and an in-range
or outside-radius last light. The last case matters: an active light's small
computed specular color can incidentally truncate to index zero and hide the
bug. The test compares the actual original DXBC, pre-fix shipped blob and new
Release blob; it requires finite native/replacement RGB, <.002 error and a
measurable pre-fix failure. All 12 cases pass on **WARP and NVIDIA RTX 5090**
with maximum corrected error **0**; pre-fix error reaches **0.320312** in this
constructed fixture. This reproduces the indexing fault, not a pixel-exact
replay of the complete live face draw.

Evidence: `tmp/witcher3classic-investigation/blitzfx-20261024/igni-face/` holds
`head-inputs.json`, byte-preserving `head-bSLOT.bin`, `head.asm`, brown/normal
pre-grade previews, `constant-index-audit.json`, old shader/blob and GPU/build
logs. The isolated Release addon links and the normal Release object/embeds
compile. Isolated DLL SHA256:
`11725F79D9185EAD0C80E94F4316E39B74975C09A086016ADE35AE12A9D5671A`.
The user rebuilt/restarted during documentation (new PID 7964). Root Release
DLL SHA256 `3B46473BFE2EAEEFD62B1757C19E0A7D99C72582F25343E41CE8C84C64490C73`,
written 01:38:10 local, loaded after restart; the generated hero shader matches
the tested isolated blob. Re-enable Object Motion and cast Igni repeatedly,
including while its light fades; corrected in-game facial shading and retained
face-vector coverage still require user verification.

## Reflection depth preparation — third 2026-10-24 revision

The user rebuilt the second correction below (PID 11068; loaded root addon
SHA256 `865A4F96CFD05C80FD97C9EB8FEE3CCC6CB8B756F70092C5D1BAFD7973DE9DDC`).
They report that other rendering now looks okay, but water reflections still
differ in upscaling versus DLAA. Their earlier reduced-resolution comparison
was **Performance**, not Quality. Capture filenames alone are not mode proof:
inspect the viewport and b3 dimensions, especially while the user changes modes.

The remaining proven mismatch is native PS **`657A6576`**, which prepares
quarter-resolution raw depth before reflection ray marching (`0C3371A9`). In
the confirmed Performance capture, its viewport/b3[0].xy are **480×270**, the
scene renders at **1920×1080**, and t0 remains **3840×2160**. Its original
normalized UV traverses the entire depth allocation. This shrinks/misregisters
the scene depth inside the active reflection rectangle and reads unused depth.
The ray marcher consequently receives the wrong depth despite already handling
its own active/allocation ratios correctly.

`blitzfx/0x657A6576.ps_5_0.hlsl` uses the captured second native b3 float4
(.25/.25/4/4) to recover the scene extent, then converts render UV to allocation
UV through `scene_pool.hlsli`. It keeps the existing sampler and raw depth
channel. Registration disables HDR constant injection and joins the same
recognized-BlitzFX + active-world + reduced-resolution gate as the four previous
corrections. No additional pass, copy, allocation, hook or readback is added.
DLAA and standalone continue using their original shader.

Follow-up inspection avoids two misleading fixes:

- `35624BD6` composite b3[0] is [480,270,960,540] in Performance and
  [960,540,960,540] in DLAA; it already addresses the active reflection rectangle.
  `88367C34` mip generation and `50944A49` hole filling also carry active and
  allocated dimensions. Performance hole filling starts at mip 8; the captured
  final mip source has active 3×2 versus allocated 7×4 and a 1×1 destination.
  Do not multiply these coordinates by another render scale.
- Reflection prep `CA115962` previous-color t2 is black in both captured DLAA
  and upscaling. That is not evidence of an upscaling-only format/copy failure.
  Its lifecycle remains a separate audit if needed; do not compensate by
  changing exposure or globally enabling resource auto-cloning.

The new regression uses the actual original `scene-shaders/0x657A6576.cso`
alongside the exact shipped replacement blob. Compare native physically cropped
depth with a larger allocation containing poisoned unused pixels at 64×64,
44×36, 32×28 and 20×20 render sizes. Use the native point sampler and constant
4×4 depth cells: quarter sampling lies on a point-filter texel boundary, so
reciprocal roundoff must not masquerade as an addressing failure. The fixture
also asserts that the original larger-pool shader fails at reduced sizes.
The full effects suite passes on WARP and NVIDIA RTX 5090; this depth check has
maximum error **0** on both, while the original poisoned-pool error reaches
0.974. CPU upscale scope/menu/jitter tests pass. The isolated Release addon
links successfully and the normal Release object compiles; both checkouts
produce identical `657A6576` blobs. Isolated addon SHA256:
`953DF596ECB939F7700DBD7DFE3B584DE622DB9098FA0B535D259F4D96E6C5AD`.

Evidence is under `tmp/witcher3classic-investigation/blitzfx-20261024/reflection-followup/`:
`capture-modes.json` corrects historical filenames; `performance-depth.json`,
`performance-ssr.json`, `performance-holefill.json`, `performance-mip7.json`
contain exact pre-draw inputs/constants. Matching previews and test/build logs
are alongside them. The isolated Release build is available; the normal loaded
DLL has not been overwritten. New in-game reflection acceptance is pending a
rebuild/restart. Hold Performance long enough for reflection history to settle,
then compare DLAA at the same camera; check Quality and camera motion afterward.

## Water history and doubled shadows — second 2026-10-24 revision

The user rebuilt/restarted the first correction below (PID 27988; root DLL
SHA256 `D1483C2F54494CDF6AF02821EB1571E92804D8591EC49597458B84235E589AF5`).
DevKit confirmed its four corrected shader registrations. **Water was still
broken in Quality/upscaling; DLAA looked good.** The user also reported doubled
shadows. Do not describe the first water UV correction as complete acceptance.

The next revision adds four replacements, gated together in `addon.cpp`:
recognized BlitzFX (`runtime_aa` established by PE/code guards), an active main
world frame, and render width smaller than output width. Thus **DLAA and
standalone without BlitzFX keep their previous native passes**. Each disables
HDR b13 injection and uses the original pass, without extra GPU copies/replays.

| Live shader | Proven conflict and correction |
| --- | --- |
| `4E0137BC` PS | Native water temporal reflection history is stored in an output-sized scratch texture. Quality b3[0] is 640×360 but the fixed b3[8].xy=.25 samples 960×540 pixels of a 3840×2160 allocation. Untouched pixels contain the exact yellow clear **(1000,1000,0)**. Compute history UVs from active history extent / actual t2 allocation; adapt current t0 water-mask and t3 depth samples from render to allocation UVs. Keep world reprojection and current integer loads unchanged. |
| `CA115962` PS | Reflection preparation mixes current raw depth and previous scene color. Only depth needs render-pool scaling; keep previous color addressing in its existing domain. The captured b3 buffer has two float4s: active quarter dimensions at [0], .25/.25/4/4 factors at [1]. Extend the declaration to [2] to read those captured factors. Do not scale both textures together. |
| `4708B025` CS | Shadow temporal reuse computes render-normalized reprojection, then gathers t42 shadow history and t44 linear-depth history from output-sized textures. Convert those gathers at the sample boundary, preserving render-domain interpolation fractions, disocclusion tests, neighborhood clamp and temporal weight. |
| `58959EAD` CS | Contact-shadow rays project into render-normalized coordinates but sample an output-sized packed ray buffer t43. Convert its 16 samples. Its **point-border** sampler must return empty data when a ray leaves the active viewport; clamping would invent edge occluders. Preserve the border test explicitly. |

`58959EAD` decompilation also needs a faithful packed-normal repair: t43.y
contains **integer bits in a float channel**, not a numeric float-to-int
conversion. Use `asuint`, extract all lanes before overwriting the packed source
(the initial DXBC ubfe writes overlapping lanes simultaneously), and retain
the original following math. Sixteen sampled decodes plus the initial load
were repaired. Native equivalence with actual occlusion is required; an all-one
shadow mask is an ineffective test. Do not modify cascade filtering, light
intensity, hair constraints or the engine's shadow maps to compensate for this
screen-space addressing problem.

Resource-identity tracing established the chain: `0C3371A9` writes current
reflection/history into full-sized scratch surfaces; `88367C34` builds the
quarter allocation's mip chain; `4E0137BC` reprojects history into that chain;
`35624BD6` composites it. The previous decision that every native SSR pass
already handled subrects was too broad: the first pass had explicit
render/allocation dimensions, but the history pass retained a fixed .25 scale.

New offline results: full effects suite passes on **WARP and NVIDIA RTX 5090**.
The actual original water-history shader reproduces the poisoned-history
failure (maximum error about 967); the correction matches physically smaller
render pools at four sizes (NVIDIA error 0, WARP at most 0.000114). The prep
test independently varies current depth allocation while keeping color output
full size. Shadow history passes at five sizes, including a test that the
uncorrected shader measurably fails. Contact shadows match native output at
three ray-buffer sizes with varied packed normals/material flags and real
occlusion (native minimum 0, maximum difference 0). Existing HDR, bloom, LUT,
grading and effects regressions pass. The outer Gather footprint uses a
conservative inward margin; history comparisons exclude that one-pixel rim.

Build status: isolated **Release addon built**, normal Release object/embeds
compiled; the running root DLL is not replaced while loaded. New in-game
acceptance is pending another rebuild/restart. Verify river/reflections and
shadows in Quality, then Performance, camera pans, menu recovery and DLAA.
Both skin motion and HDR standalone regression checks remain separate.

Additional evidence in the same `blitzfx-20261024` archive:
`rebuilt-water-draw-details.json`, `rebuilt-resource-chain.json`,
`rebuild-water-composite.json`, `rebuild-composite-analysis.json`,
`rebuilt-reflection-preparation.json`, `shadow-history-quality.json`,
`contact-shadow-quality-inputs.json`, matching previews/original shaders and
GPU logs. Reflection preparation's preserved previous-color t2 was black in
this capture; verify its lifecycle/copy destination if reflections remain
missing after this fix. Do not silently enable global auto-cloning or assume
that black input proves a specific format-copy failure without tracing it.

## Exposure and reduced-resolution correction — 2026-10-24

The first combined build reached NGX but failed visual acceptance: the user
reported extreme brightness and a distorted scene. Do not confuse successful
NGX initialization with a correct integration. This revision is built and
tested offline; its new in-game visual acceptance is still pending.

### Evidence from the running game

DevKit connected to `renodx-devkit-mcp-5772`. Quality rendered at
**2560×1440 inside 3840×2160 pool textures**. At `201C53B4`, the actual viewport
and b12 screen dimensions were 2560×1440, and b10 contained the managed jitter.
BlitzFX's compute TAA passes were absent. The existing reconstruction boundary
and scoped TAA bypass therefore worked in this capture. Full-size DLAA showed
coherent water, while Quality showed yellow water and displaced screen effects
before final grading. These were separate captures, not a pixel-aligned A/B.

The water draw `2825099C` preserved scene t2/t6 and depth t15 before drawing:
all were 3840×2160. Its b0[1] held allocation dimensions, b0[2] held active
dimensions and ratios, and b2[23] held render dimensions/reciprocals. Exact
pre-draw previews showed the top-left rendered rectangle and unused/stale data
outside it. Early native-water addressing already used allocation UVs; the
later BlitzFX refraction instead used render-normalized UVs to sample these
same textures. Do not multiply every coordinate by a resolution ratio.

At bloom composite `BF3EF83C`, b0[23] described the 2560×1440 render size,
but b1[0] and t51 described a **1920×1080** bloom allocation. The preserved
bloom preview occupied the corresponding top-left subrect. Sampling it using
render reciprocals stretched/misregistered bloom relative to t52's scene loads.

The scene subsequently drew blended filmic permutation `0E583BCD`, previously
uncovered. It has two exposures, two Hable curves and an environment blend.
Its final saturate could lose HDR during an environment/weather transition.
Both single and blended permutations must be supported; the later attempt to
capture the transient blend's constants timed out, so its regression constants
are constructed from the captured single-curve fixture, not falsely labeled a
live blend capture.

### Changes and invariants

- **`5AA6AFFF`: fix the exposure regression.** A previous broad text replacement
  inserted vignette strength at two identical multiplies. The first was the
  exposure white-reference denominator. Clamping that value to 1 incorrectly
  multiplied exposure by `11.2 * cb3[16].x`: **19.9435× (4.32 stops)** for the
  captured value 1.78067. Remove that insertion; apply strength only at the
  actual vignette transmission. Do not compensate with a new arbitrary
  exposure/midgray multiplier. The original exposure, contrast pivot, color
  filter, saturation and curve toe remain the reference.
- **`0E583BCD`: extend both environment curves.** Preserve independent exposure,
  white references and normalization, apply the same vignette transmission to
  both, extend each shoulder, and blend using native b3[13].x. Vanilla retains
  the original bounded path. Use `asuint` for the modify-tonemap flag here too.
- **`2825099C`: correct screen-pool sampling.** Keep projection, refraction
  displacement and pixel-based LOD calculations in render coordinates. Convert
  only normalized scene/depth texture samples to allocation coordinates. The
  earlier allocation-based depth samples are clamped without scaling twice;
  integer depth loads stay unchanged. Gather uses a conservative one-pixel
  margin; bilinear samples use half a pixel. Lighting b13 remains native.
- **`BF3EF83C`: align bloom to the scene pool.** Derive bloom UVs from twice
  its allocation size, retaining native blur offsets and bloom/scattering
  weights. Clamp filter taps to the active bloom rectangle. The compute shader
  retains its original 8×8 group and UAV store.
- **`blitzfx/scene_pool.hlsli`: shared boundary conversion.** At full-size
  rendering the helpers return native UVs and preserve sampler behavior.
  No per-frame texture copies, readbacks, additional fullscreen passes or
  geometry replay are introduced. The new shaders are registered by exact
  live bytecode hashes with their embedded code; water/bloom disable HDR b13
  injection. Without BlitzFX these hashes are absent and standalone rendering
  follows its previous path.

The inspected native SSR chain already carries render/allocation dimensions
separately, e.g. `0C3371A9` used viewport 640×360 in a 960×540 allocation.
It was not blanket-scaled. `FD1D6FBF` t2 is a fallback paraboloid and t3 is a
3D water-depth volume, not interchangeable screen/depth buffers. Resource
names from cached reflection and live input evidence are necessary before
applying a subrect fix.

### Validation and handoff

`effects.cpp --blitzfx` passed on WARP and RTX 5090 hardware using the actual
Release FXC blobs: 64 final-grade/native-debug cases, **48 single-curve HDR
exposure/toe cases**, 16 blended-curve native/toe/highlight cases, refraction
sampling at five sizes with poisoned unused pixels, and actual bloom-CS
comparison against the original shader using physically cropped textures.
Refraction allows 0.0002 absolute error for finite sampler subtexel precision;
the poisoned region is 10000, so stale-region reads cannot hide in that tolerance.
The existing native grading/LUT/blur/sharpening cases pass too. These bounded
tests do not certify the complete water material, every BlitzFX effect or an
identical final PsychoV/SDR image.

Build: `clang-x64-release`, target `thewitcher3classic`, isolated
`tmp/classic-publish-check` while the normal DLL was loaded. Root object-only
compilation also passed; linking/deployment requires the game closed. Local
evidence is under `tmp/witcher3classic-investigation/blitzfx-20261024/`:
`current-draws.json`, `water-quality-inputs.json`, `water-quality-analysis.json`,
`bloom-quality-inputs.json`, `bloom-quality-textures.json`, previews, shader
dumps, Ghidra resolution audit, build logs and `effects-{warp,nvidia}.log`.
Cache reflection matches: `94E8DA78` → live `2825099C`, `BE5A368F` → live
`0E583BCD`; register the live stripped hashes, not cache hashes.

After deployment, first verify the same river scene in Quality and DLAA:
water/refraction, sky seams, bloom placement, exposure and midtones. Then test
Performance/Ultra Performance, quality switches, Map/Inventory recovery,
weather/environment blends, DLSS off with BlitzFX TAA restored, and standalone
without BlitzFX. Capture before/after filmic and at the AA boundary if artifacts
remain. The upstream bloom pyramid, motion blur, volumetrics, private resource
allocation cost and unobserved permutations are not certified by the composite
test; investigate only against captured contracts. Keep the working ReShade
startup patch unchanged.

## Rendering compatibility revision — 2026-10-23

The pre-compatibility Classic checkpoint was committed and pushed to `main` as
`26075fbb68d0cdec0ae43909953cb48bc4a9778e` before these changes. New work is
scoped to Classic; it does not change the shared shader framework or ReShade
submodule. The separate ReShade startup patch below remains required.

### Captured conflicts and fixes

With BlitzFX TAA selected, the live scene runs compute passes `B8F9ED1E`,
`E8E49413` and `FCAC1AA0` before bloom/filmic/LUT. Its native AA draw
`201C53B4` is suppressed, so RenoDX's existing DLSS boundary never initializes.
Do not register the final grading shader as a substitute AA draw: it has a
different input/CB contract and arrives after reconstruction should occur.

Temporarily selecting BlitzFX Vanilla AA restored `201C53B4`; the live log
confirmed successful NGX initialization, Quality **2560×1440 → 3840×2160**, and
existing skinned/deformed/foliage history. This establishes that the existing
native boundary can be retained. It is not proof of the automatic switch.

The new `blitzfx/compatibility.hpp` recognizes the audited **BlitzFX 1.1.0** PE
(timestamp `67410424`, image size `9e000`) and verifies the code at RVAs
`51d40`, `52090`, `52f40`. These consume the same AA member for matrix jitter,
shader selection and draw interception. The member is at module RVA `9166c`:
renderer singleton `909f0` + embedded renderer `288` + config `940` + AA `b4`.
Ghidra decompilation and a read-only live process check confirmed its value 2
in TAA mode and 0 after the user's Vanilla selection.

When DLSS is enabled, the existing native render hook temporarily sets that
member to **Vanilla (0)** for the primary world-render scope and restores its
previous value on every return, before BlitzFX's Present/UI/config save.
This bypasses **both BlitzFX TAA and BlitzFX's projection-jitter mutation**;
RenoDX retains its native camera setter, Halton jitter, NGX input preparation,
object histories and final resolve. The game’s own AA option must stay enabled.
There is no second TAA applied to reconstructed output. Disabling DLSS stops
the override, so BlitzFX uses the AA mode selected in its menu. Failed NGX
initialization also releases ownership. No settings file is rewritten.

The existing hooks normally initialize from the native AA draw. Since BlitzFX
TAA suppresses that draw, only an identified BlitzFX module bootstraps those
hooks from Present on Classic's `W2ViewportClass` window, excluding BlitzFX's
temporary hook-discovery swapchain. Without BlitzFX, initialization and rendering remain on
the previous path. Unknown binaries fail the PE/code guards and receive no
memory override; support must be audited rather than guessing new offsets.

| Shader / source | Change |
| --- | --- |
| `5AA6AFFF` / `blitzfx/0x5AA6AFFF.ps_5_0.hlsl` | Preserve BlitzFX exposure, white balance, contrast, saturation and pre-curve vignette; extend its bounded filmic shoulder using the existing native-curve helper. Remove its output color saturate only in PsychoV mode. RenoDX vignette strength scales its pre-curve optical attenuation. |
| `114D8828` / corresponding BlitzFX PS | Use the shared signed grade/gamut/PsychoV path, honoring BlitzFX's parametric-grade flag and its vignette ownership. RCAS/CA precede final grading; grain stays after reconstruction and before HUD. Preserve cinematic borders, blue-noise dither and BlitzFX debug views. |
| `FBF141A1` / corresponding BlitzFX PS | Bypass BlitzFX's extra sharpening only when RenoDX RCAS replacement is selected. |
| `blitzfx/object_materials.inc` | Nine captured BlitzFX material PS permutations gain motion/depth MRT outputs while retaining their shading and discard paths. Match the captured native VS families rather than treating them as a generic postprocess. |

The nine material hashes/groups are `E9D2E491`/4, `DB6465A7`/5,
`E501A17A`/5, `8E158EDE`/5, `2920E76E`/4, `4CCA5588`/4,
`E1AD6AE5`/13, `90BFECE8`/11, `C2F7B0B1`/12. Group 12 retains the
hair ABI's TEXCOORD12/13 history; the other families use TEXCOORD10/11.
Forward materials use the existing forward motion attachment path. Their
native b13 lighting data is not overwritten by HDR injection. Raw t20 loads in
the two forward decompilations use the established ByteAddressBuffer repair.
BlitzFX's extra reactive-mask MRT in its TAA mode is avoided by the same AA
handoff; do not overwrite an independently owned fourth MRT.

All new shader registrations activate by exact bytecode hash, so an installation
without BlitzFX retains the existing shaders. Existing resource upgrade rules,
menus, defaults and settings keys are unchanged. No extra fullscreen pass,
per-frame readback, runtime shader scan or separate geometry replay is added.

### Validation and remaining live checks

- Clang `clang-x64-release`, target `thewitcher3classic`, builds in the isolated
  checkpoint checkout while the game holds the normal addon open.
- CPU fixture covers no-module behavior, AA modes 0/1/2, invalid mode rejection,
  disabled DLSS and scope restoration, plus existing viewport/jitter/menu cases.
- WARP and NVIDIA effects fixtures pass 64 native/debug flag permutations,
  disabled parametric-grade isolation, RCAS, zero replacement-CA isolation,
  filmic native equivalence and finite values above SDR range. Existing six
  final-grade and six LUT/effects regression cases pass too.
- WARP and NVIDIA object-motion suites pass with the nine original BlitzFX PS
  fixtures: native color/material comparisons, alpha/discard coverage, motion,
  state restoration and existing clip-position invariance. These are bounded
  synthetic inputs, not full scene acceptance.
  The group-12 hair PS additionally passes the focused native-color,
  TEXCOORD12/13 motion and alpha-cutout case on both devices. Hardware testing
  used the RTX 5090, driver 617.42; see `compatibility-evidence-manifest.json`
  in the local evidence archive for fixture hashes and exact deployment status.
- The original scene's exact pre-curve input contained values up to **3.3125**;
  after the old filmic/LUT/final chain no channel exceeded **0.94825**. The fix
  extends the proven upstream curve; it does not invert completed SDR output.

After installing the new Release addon, select **BlitzFX TAA** and enable DLSS.
Verify automatic native-boundary restoration, one managed jitter sequence,
selected-quality scene viewport/full-resolution output, full motion coverage,
HDR highlights, LUT grading, bloom, borders, sharpening and debug views. Turn
DLSS off and verify BlitzFX TAA returns; turn it back on and repeat a Map /
Inventory round trip. Test without BlitzFX as a separate regression. Check
BlitzFX water, shadows, motion blur and private reduced-resolution buffers for
subrect sampling artifacts at each quality; the native AA handoff alone does
not establish those effects' quality/performance. Other unobserved BlitzFX
filmic/grade permutations remain an explicit follow-up for new scenes.

Local evidence: `tmp/witcher3classic-investigation/blitzfx-20261023/` contains
scene/Vanilla-AA snapshots, exact input JSON/binary fixtures, original CSOs,
EXR/range evidence, Ghidra scripts/projects/decompilations, build runners and
WARP/NVIDIA logs. `scene-shaders/` contains the live **stripped** DXBC hashes;
`shaders/index.json` describes the on-disk cache with reflection. Identical
instruction chunks can have different whole-container CRCs after stripping:
for example cache `584D2BE2` → live `5AA6AFFF`, `13739229` → `114D8828`.
Do not register cache CRCs without verifying the live shader identity.

HLSL boolean/int constants in BlitzFX occupy raw integer bits (e.g. bool true
is word `1`, not float `1.0`). Use `asuint` for its grade/debug/tonemap flags;
a floating `!= 0` can flush word 1 as a denormal and silently change branches.
Native/debug GPU equivalence tests caught and verified this repair.

NVIDIA's [DLSS integration guidance](https://developer.nvidia.com/blog/how-to-integrate-nvidia-dlss-4-into-your-game-with-nvidia-streamline/)
and [programming guide](https://github.com/NVIDIA/DLSS/blob/main/doc/DLSS_Programming_Guide_Release.pdf)
remain the reconstruction/input reference. Classic/BlitzFX offsets above are
local audited contracts, not portable NVIDIA APIs.

## Startup result — 2026-10-23

The user confirmed that the patched ReShade passes the startup crash with
BlitzFX installed. This validates startup of the injector pair, not complete
HDR/DLSS compatibility. No Classic addon or BlitzFX shader code was changed for
that earlier startup fix. The rendering revision above is subsequent work.
No executable or NVIDIA driver binary was patched. The repository's ReShade
submodule was left unchanged; development used an isolated clone.

## Patch and active configuration

Source patch: [reshade-6.8-blitzfx.patch](patches/witcher3classic/reshade-6.8-blitzfx.patch).
Apply it to official ReShade `v6.8.0`, commit
`18deaa52de0c425a78b329e9cb3c497281cd00ec`.

The working build adds an opt-in `ReShade.ini` setting:

```ini
[DX11]
ForceMultithreadProtection=1
```

In `D3D11CreateDeviceAndSwapChain`, before creating the device, this removes
`D3D11_CREATE_DEVICE_SINGLETHREADED` if set. After successful device creation,
before returning it to the application, it obtains the immediate context's
`ID3D11Multithread` interface and calls `SetMultithreadProtected(TRUE)`.
Protection stays enabled instead of being enabled only inside ReShade's
swapchain operations. Existing guards consequently observe protection already
enabled and restore that enabled state when leaving their scope.

The flag defaults to false. It is read at device creation, so a game restart is
required after changing it. This is synchronization of existing CPU-side D3D11
context calls; it adds no rendering or texture-copy pass. Its CPU performance
cost has not been benchmarked.

The patch also backports ReShade upstream
[2796147](https://github.com/crosire/reshade/commit/2796147): effect-runtime
creation/destruction moves inside the swapchain's existing device lock and
multithread protection. **That backport alone did not fix this crash.** The
successful build includes both changes; do not describe the startup backport
alone as the verified solution.

Microsoft documents that shared immediate-context use requires synchronization:
[D3D11 threading](https://learn.microsoft.com/en-us/windows/win32/direct3d11/overviews-direct3d-11-render-multi-thread-intro),
[SetMultithreadProtected](https://learn.microsoft.com/en-us/windows/win32/api/d3d11_4/nf-d3d11_4-id3d11multithread-setmultithreadprotected).

## Exact working artifact

Game folder:
`C:/Program Files/GOG Galaxy/Games/The Witcher 3 Wild Hunt/bin/x64`.

- Installed loader: `dxgi.dll`, custom Release x64 ReShade **6.8.0.2**.
- Size: **5,590,528 bytes**.
- SHA256: `B4694CBEB67CD4CE5977B820F474B756D68F64AF92BD3B25754B1B3553251871`.
- GPU/driver: RTX 5090, NVIDIA **617.42**, Windows 11.
- Last verified startup used BlitzFX **1.1.0**, loaded as `blitz-fx.asi` through
  the user's 64-bit ASI loader, with ReShade addons disabled.
- Original BlitzFX DLL/ASI SHA256:
  `8B75B893234CAAB21DB09FB1F486C850790FBC35C43290AD5E5F40CC12BDC3DE`.

The user may subsequently change the loader arrangement while restoring their
setup. Check actual files before assuming that the ASI arrangement is still in
use. Do not rename their files automatically.

The local build and evidence root is
`tmp/witcher3classic-investigation/blitzfx-20261023/`:

- `reshade-patch/`: isolated release source, dependencies and build outputs.
- `reshade-patch/bin/x64/Release/ReShade64.dll`: working build, hash above.
- `build-reshade.cmd`: exact local MSBuild invocation.
- `build-reshade-multithread.log`: successful working-build log.
- `dxgi-original-6.8.0.dll`: original installed ReShade backup, SHA256
  `0CEE63F9C9F13F3AC909C5B4903F4DBB4B719A7AB3B4F13B0DEAF83C814B94F7`.
- `ReShade-before-multithread.ini`: configuration immediately before adding
  `[DX11] ForceMultithreadProtection=1` and `[INSTALL] Logging=1`.
- `blitz-audit.txt`, `blitz-interfaces.txt`, `project/`: Ghidra analysis of the
  installed BlitzFX binary. Its preferred image base is `0x180000000`.
- `shaders/index.json`: reflection/resource index of 103 DXBC containers
  extracted from the installed BlitzFX cache for private analysis.

Scratch artifacts are not the durable source distribution. Keep the patch and
this document when cleaning scratch folders. Do not commit DLLs, crash dumps or
third-party shader caches.

## Rebuilding

1. Clone official ReShade at `v6.8.0` with recursive submodules into a separate
   directory. Apply the saved patch there with `git apply`.
2. Use the project's Release x64 build, VS 2022 v143 and an installed Windows
   SDK. The verified local SDK was `10.0.28000.0`.
3. Use a dedicated Python virtual environment with the requirements from
   `deps/glad/requirements.txt`. Put that environment's `Scripts` directory on
   the build shell's PATH. GLAD generates graphics headers and may need network
   access on its first run. Do not install build requirements into system Python.
4. From an x64 VS developer shell, run:

```powershell
msbuild ReShade.vcxproj /m:4 /p:Configuration=Release /p:Platform=x64 /p:PlatformToolset=v143 /p:WindowsTargetPlatformVersion=10.0.28000.0 /p:SolutionDir=C:\absolute\path\to\reshade\ /p:MultiProcessorCompilation=false /v:minimal
```

5. Close the game, back up the current loader, then copy
   `bin/x64/Release/ReShade64.dll` into the game folder as `dxgi.dll`.
   Preserve `ReShade.ini` and merge the flag above into an existing `[DX11]`
   section if present. Do not duplicate sections or replace the user's presets.
6. Restart. With logging enabled, verify:
   `Enabled persistent D3D11 multithread protection for injector compatibility.`

Rebuilding increments ReShade's build number and changes its binary hash.
`GenerateDebugInformation=true` passed as an MSBuild property did not produce
a PDB with this project's explicit Release linker metadata. Do not assume one
exists. A separate symbol-link experiment produced a map/PDB but changed code
layout; those offsets cannot be applied blindly to the deployed binary.

## Crash evidence and discarded explanations

The user reproduced the failure with **only BlitzFX and ReShade**, without
RenoDX, DevKit or other addons. The documented ASI-loading workaround also
failed. Do not ask them to repeat those isolation tests as though untested.

Windows dumps report `0xC00000FD` in `witcher3.exe + 0xE7C107`. This is a
secondary failure: the game's exception handler probes a large stack allocation
on an NVIDIA worker thread. Recovering its original exception/context from
the dump shows a **read access violation at address 0x10** in
`nvwgf2umx.dll + 0x3044A3`. The faulting instruction reads `[rsi+0x10]` with
`rsi=0`. Do not label this graphics-hook recursion based solely on the final
stack-overflow code.

- `witcher3.exe.26560.dmp`: initial RenoDX-enabled failure; original exception
  details in `original-exception.txt`.
- `witcher3.exe.22408.dmp`: clean ReShade/BlitzFX failure; `clean-crash.txt` and
  `clean-threads.txt` contain analysis.
- `witcher3.exe.22144.dmp`: same original driver fault after the upstream
  runtime-creation backport alone; `patched-crash.txt` contains analysis.
- Dump source: `C:/Users/Vik/AppData/Local/CrashDumps/`.
- Successful persistent-protection startup: PID 38740, launched 21:26 CEST;
  the user confirmed it worked. Do not keep following that PID after a restart.

The result strongly points to a context-synchronization problem in the combined
injector setup. It does not prove which specific pair of native context calls
overlapped or identify an internal NVIDIA driver defect. No fault suppression,
exception swallowing, driver machine-code patch or disabled rendering effect
was needed for the successful startup.

An earlier per-game Ansel-usage override did not fix startup. Its effective
values were restored: `ANSEL_ENABLE_ID` has no explicit value and
`ANSEL_ALLOW_ID` is 1. The latter is now stored as an explicit user value rather
than its previous predefined entry; `ANSEL_ALLOWLISTED_ID` remains predefined 1.
`nvidia-before.txt` is the original NVAPI settings export. NVAPI file import
merges settings and did not by itself remove the test override; do not call
that an exact database rollback. Do not change driver profiles further unless
the user asks or a new, supported diagnostic requires it.

## Follow-up if the user reports another issue

First verify the deployed DLL hash/version and the opt-in flag. Then capture
the new failure with matching symbols or source mapping; distinguish a startup
regression from an HDR/DLSS rendering incompatibility.

BlitzFX is not a pure shader-replacement pack: Ghidra shows device/context and
presentation interception, buffer allocation and custom rendering; the cache
contains compute passes for TAA, bloom, water, shadows and motion blur. Its
documentation also exposes its own TAA jitter/history and tonemapping controls.
If gameplay loads but HDR/DLSS fails, trace ownership/order of those passes.
Preserve a single reconstruction/jitter owner and a single final tone-mapping
owner. Do not transplant cached shaders alone and claim full integration.

The user subsequently restored addons and requested the rendering compatibility
revision above. Combined-gameplay acceptance and performance measurements remain
pending; preserve the working startup DLL while testing the game addon.

## Rollback

With the game closed, restore the saved original DLL as `bin/x64/dxgi.dll`.
Remove `ForceMultithreadProtection=1` if returning to stock ReShade; stock
ReShade ignores this custom flag. Remove the diagnostic `[INSTALL] Logging=1`
only if desired. Avoid restoring the entire old INI over newer user changes.
Stock ReShade plus BlitzFX is the previously failing combination, so DLL
rollback alone should not be presented as a working BlitzFX configuration.
