# Classic temporal reconstruction regression fixtures

Start with the [DLSS integration playbook](../../../../docs/DLSS_INTEGRATION_PLAYBOOK.md).
These fixtures exercise game-local CPU logic and actual D3D11 shaders. They do
not certify every game scene or replace live capture/visual acceptance.

The CPU `upscale_engine.cpp` fixture also covers BlitzFX's missed-resize
recovery: absent/uninitialized module, 1x1 bootstrap, output resize,
renderer-only mismatch, invalid dimensions, and no repeated native resize for
an unchanged output. The repair uses the real primary output size independently
of DLSS. Live verification must include repeated save loads with DLSS off,
DLAA and upscaling; the CPU mock cannot certify BlitzFX's private GPU resources.

## Prerequisites and build

`object_motion` now uses distinct native VS/PS frame buffers. It checks that
motion draws preserve PS b12, bind the same current VS-frame bytes through PS
b11, and restore an existing b11 binding afterward. Original-bytecode reflection
checks that every non-foliage native PS leaves this slot unused. Keep these
stage-frame values independent; sharing one fixture buffer previously concealed
lighting-state replacement even when motion/material comparisons passed.

The BlitzFX `effects --blitzfx` suite additionally checks the captured overcast
filmic coefficients whose cubic has two positive inflections. An independent
double-precision bisection reference verifies the rising tangent and native toe
over a dark-to-HDR ramp; C=1 exercises the quadratic case. Shadow-history tests
compare five physical render pools with three jitter deltas against original
DXBC using independently shifted previous matrices. The CPU upscale fixture
checks first-frame zero jitter delta, subsequent phase differences, and reset
after disable/missing resolve. Run these on WARP and NVIDIA after regenerating
the exact Release embeds; shader registration alone does not prove unclamping.

Run from repository root in an **x64 Visual Studio developer command prompt**
with the installed `clang-cl` and Windows SDK on PATH. The examples below use
`cmd.exe` syntax. Use the established `clang-x64` / `clang-x64-release` presets.
Do not compile fixtures with `NDEBUG`: assertions perform both checks and some
setup calls. `/O2` does not itself disable assertions.

The shader fixtures read actual FXC output from
`build/thewitcher3classic.include/embed/`. Generate it first. If the game is
closed, build the normal addon target:

```bat
cmake --preset clang-x64
cmake --build --preset clang-x64-release --target thewitcher3classic
```

When Classic holds the addon DLL open, compile the object and its shader
dependencies without linking the loaded DLL:

```bat
cmake --build --preset clang-x64-release --target CMakeFiles/thewitcher3classic.dir/Release/src/games/thewitcher3classic/addon.cpp.obj
```

This generated object target is specific to the current Clang/Ninja multi-config
layout; use target discovery if the build generator changes. Never report an
object-only compile as a new installed addon. Rebuild DevKit/bridge only when
needed, using compatible Release configurations. Original CSOs belong in scratch
archives, never alongside editable game shaders where they can shadow replacements.

Create a scratch output directory and compile the fixtures below. Inspect every
exit code; stop on a compilation failure rather than running a stale executable.
The commands are reconstructed from the working local runners, not newly run
GPU results for this documentation update.

```bat
if not exist tmp\classic-tests mkdir tmp\classic-tests

clang-cl /std:c++20 /EHsc /O2 src/games/thewitcher3classic/tests/object_history.cpp /Fe:tmp/classic-tests/object-history.exe /Fo:tmp/classic-tests/object-history.obj
clang-cl /std:c++20 /EHsc /O2 /MT src/games/thewitcher3classic/tests/upscale_engine.cpp /Fe:tmp/classic-tests/upscale-engine.exe /Fo:tmp/classic-tests/upscale-engine.obj
clang-cl /std:c++20 /EHsc /O2 /DNOMINMAX src/games/thewitcher3classic/tests/constant_uploads.cpp /Fe:tmp/classic-tests/constant-uploads.exe /Fo:tmp/classic-tests/constant-uploads.obj /link d3d11.lib dxgi.lib
clang-cl /std:c++20 /EHsc /O2 /DNOMINMAX /Iexternal/Detours/include /Ibuild/thewitcher3classic.include src/games/thewitcher3classic/tests/object_motion.cpp /Fe:tmp/classic-tests/object-motion.exe /Fo:tmp/classic-tests/object-motion.obj /link d3d11.lib dxgi.lib user32.lib
clang-cl /std:c++20 /EHsc /O2 /DNOMINMAX /Iexternal/Detours/include /Ibuild/thewitcher3classic.include src/games/thewitcher3classic/tests/foliage_motion.cpp /Fe:tmp/classic-tests/foliage-motion.exe /Fo:tmp/classic-tests/foliage-motion.obj /link d3d11.lib dxgi.lib user32.lib
clang-cl /std:c++20 /EHsc /O2 /MT /DNOMINMAX /Iexternal/DLSS/include src/games/thewitcher3classic/tests/dlss.cpp /Fe:tmp/classic-tests/dlss.exe /Fo:tmp/classic-tests/dlss.obj /link external\DLSS\lib\Windows_x86_64\x64\nvsdk_ngx_s.lib d3d11.lib dxgi.lib user32.lib advapi32.lib shell32.lib ole32.lib
clang-cl /std:c++20 /EHsc /O2 src/games/thewitcher3classic/tests/effects.cpp /Fe:tmp/classic-tests/effects.exe /Fo:tmp/classic-tests/effects.obj /link d3d11.lib d3dcompiler.lib
clang-cl /std:c++20 /EHsc /O2 /DNOMINMAX src/games/thewitcher3classic/tests/probe_lighting.cpp /Fe:tmp/classic-tests/probe-lighting.exe /Fo:tmp/classic-tests/probe-lighting.obj /link d3d11.lib d3dcompiler.lib
```

## Inputs and execution

For Video AutoHDR, use a directory containing original `0xHASH.cso` files
for `043049C7`, `30C6DAFA`, `7542753B`, `A850FB8D`, `989EB8B2`, `DC4FAC37`
and `DCEB62A5`. These are three-plane video programs from Classic's native
shader cache/dump. Do not substitute the new embedded replacements.

```bat
tmp\classic-tests\effects.exe <original-video-CSO-directory> --video-only
tmp\classic-tests\effects.exe <original-video-CSO-directory> --video-only --hardware
```

This isolated mode needs no captured bloom/blur/BlitzFX constants. It compares
native RGB and alpha for all seven variants across neutral, chromatic and
outside-range YCbCr inputs, vertex fades and alpha-plane values. HDR checks
reject nonfinite outputs and preserve alpha/premultiplication. A further 54
configurations check black, peak, monotonic gray and independence from UI white
across three display peaks, three game whites, three UI whites and two gamut
modes. The menu's Off/Vanilla routing uses original bytecode; the fixture also
checks the shader's defensive Vanilla bypass. Live subtitle/fade and menu
acceptance is separate from these GPU results.

For the 2026-10-26 environment-hemisphere regression:

```bat
python src/games/thewitcher3classic/tools/audit_probe_hemispheres.py <original-CSO-archive> --output <scratch-audit.json>
tmp\classic-tests\probe-lighting.exe <captured-hair-directory> <original-CSO-archive>
tmp\classic-tests\probe-lighting.exe <captured-hair-directory> <original-CSO-archive> --hardware
```

The original archive needs `AB3E8304`, `B0B4EB6F`, `5CC0DB95`, `AE216EAE`,
`12B76681`, `20C1C070`, `30F033B5`, `EB8C3FAE` as `0xHASH.cso`. The audit
verifies 64 native integer-1 register/condition pairs across the eight programs.
The GPU fixture compares the four VSs; full `object_motion` also checks material
PS pairs and preservation of vector/history/clip behavior. Live eye-material
acceptance supplements those checks rather than being inferred from the VS test.

Capture `AB3E8304` at the vertex stage with `maxBufferBytes=65536` and
`vertexBuffers=true`. Export CB slots **1, 2, 3, 12, 13** to
`hair-constantBuffers-{slot}.bin` and instance stream **7** to
`hair-vertexBuffers-7.bin`, preserving `capturedWords` as little-endian uint32s.
At least the first 80 bytes of the instance stream must be present. The tested
archive is `tmp/witcher3classic-investigation/object-lighting-20261026/candidate-31524/`.
It uses captured camera/lighting/material constants with controlled bones and
spatially varying environment atlases. The tail variants translate synthetic
vertices to the decoded captured hair origin to remain inside the lighting
frustum. Assertions require 216 finite, nonzero lighting components per program;
constant textures or entirely attenuated vertices would hide the old error.
WARP and NVIDIA pass with zero native-output difference in this fixture.

For the focused refractive-raindrop check, add `--blitzfx --rain-only` to the
effects command (and optionally `--hardware`). Its archive requires original
`blitzfx-20261023/scene-shaders/0x1F3A90A1.cso` and `0x1C74D220.cso`, plus captured
`fixtures/rain-b{0,2,3,4,12,13}.bin`. Both original programs and all new Release
embeds are required. The masked permutation uses controlled layout-correct
material constants. Match the native varying registers including SV_Position;
assert nonempty alpha coverage so an invalid vertex fixture cannot pass silently.
Five physical/pool sizes test native full-size behavior, odd dimensions, HDR
color and poisoned unused regions. The UV gradient comparison allows one
documented 1/256-texel sampler-address rounding cell, not arbitrary image drift.

The following paths are current **local fixtures**, not tracked dependencies.
Check their existence first. On a fresh clone, restore an authorized capture
archive or recreate the required inputs through DevKit. A missing file is not a
test pass. Use the source's `Read`/`Constants` calls to enumerate exact files when
new permutations are added.

| Fixture | Required input | What it establishes |
| --- | --- | --- |
| `object-history` | None | Pose allocation/lifetime/rigid/deformed/swarm history logic |
| `upscale-engine` | None | Mocked native ABI: view scope, restoration, menu suspension/rearm, jitter sequence and camera isolation |
| `constant-uploads` | D3D11 WARP or hardware | Byte-preserving mirrored updates, unchanged reuse and invalidation/fallback cases |
| `object-motion` | `temporal-dev/devkit-live/dlss-audit/0xHASH.cso` originals; generated embeds | Native color/material equivalence, clip-position bits, motion/depth/history, state restoration, allocation versus viewport handling |
| `foliage-motion` | `temporal-dev/foliage-20261023/`: originals plus `0xHASH-N-bSLOT.bin` | Captured wind/contact inputs, native vertex/material outputs, cutouts, attachment reuse and motion |
| `dlss` | Actual supported NVIDIA GPU; directory containing the compatible x64 `nvngx_dlss.dll`; generated private shaders | Capability queries, quality/model evaluation, proxy identity, jitter/reprojection, HDR, subrect poison, state restoration and shutdown |
| `effects` | `effects-20261023/`: native six final-grade CSOs, `6ED58557` blur CSO, `grade-b3.bin`, `blur-b3.bin`, `blur-b12.bin` | Native/Vanilla comparison, RCAS, CA, animated grain, blur/sky, sharpening bypass, vignette black-floor/strength/permutation isolation |
| Python fingerprint | No proprietary fixtures | Expression invariance and conservative rejection |

The LUT/wide-gamut revision additionally requires the six original LUT CSOs in
the sibling `hdr-permutations-20261023/cache/` archive. `effects.cpp` checks
native-proxy/blend equivalence, black/degenerate LUT behavior and signed HDR
round-trips, LUT grading-strength bypass/midpoint, native analytic-grade
contribution at 0/50/100, and vignette independence with grading disabled.
`dlss.cpp` includes signed-residual output checks at center and
viewport edges, with unused allocation pixels poisoned and nonzero jitter.

For the BlitzFX revision, append `--blitzfx` to the effects command (after
`--hardware` when applicable). This explicitly requires the sibling local
`blitzfx-20261023/` archive: original `scene-shaders/0x114D8828.cso` and
`0x5AA6AFFF.cso`, plus `fixtures/grade-b0.bin`, `grade-b1.bin`, `grade-b3.bin`,
`curve-b1.bin`, `curve-b3.bin`. It checks native/debug flag permutations,
parametric-grade/CA isolation, RCAS, filmic equivalence and HDR extension.
The cutscene extension additionally requires originals `A123EB15`, `399CBE16`,
`445EB59C`, `4FC8DAEB`, `E276DFB3` (each `0xHASH.cso`) in `scene-shaders/`.
The same final-grade regression runs 64 native/debug combinations per shader
and checks HDR highlight range and grade/sharpening/CA isolation for all six
BlitzFX final-grade variants. Inactive variants originate from saved dumps,
not fabricated live captures.
The nine original BlitzFX material PS blobs must also be restored to the
object-motion fixture archive; the ordinary full object suite exercises them
against their matching native vertex families. The CPU upscale fixture covers
absent BlitzFX, disabled DLSS, valid/invalid AA modes and scoped restoration.
See the [BlitzFX handoff](../../../../docs/WITCHER3_CLASSIC_BLITZFX_COMPATIBILITY.md)
for capture provenance, exact hashes, ABI guards and the required live tests.

The 2026-10-24 effects extension also requires original live
`scene-shaders/0x0E583BCD.cso` and `scene-shaders/0xBF3EF83C.cso` in that
BlitzFX archive. It tests single-curve HDR exposure/toe across 48 combinations
of white reference, adaptation exponent, modify-tonemap flag and vignette;
16 blended-environment native/toe/highlight cases; five refraction pool sizes
with poisoned unused pixels; and the actual bloom composite against its
original CS operating on physically cropped resources. The scene-pool helper
is read from the current source checkout. Run from the checkout whose Release
blobs you built. A passing bloom composite test does not validate its upstream
pyramid or the entire water material. Full combined visual acceptance remains
separate.

The water/shadow follow-up additionally requires original live
`scene-shaders/0x4E0137BC.cso`, `0xCA115962.cso`, `0x4708B025.cso` and
`0x58959EAD.cso` in the same archive directory. The fixture exercises water
history with the observed yellow clear outside the valid viewport, mixed
current-depth/output-color reflection preparation, shadow temporal history,
and packed contact-shadow rays with a point-border sampler. It asserts the
original pool-addressing bug is observable and contact occlusion actually
occurs; an unchanged all-one mask cannot pass as meaningful ray validation.

The reflection-depth follow-up additionally requires the original native
`scene-shaders/0x657A6576.cso`. It compares the exact shipped blob with native
quarter-depth preparation on physically smaller, rectangular depth resources at
four sizes, using a point sampler and poisoned unused allocation pixels. Native
quarter sampling lands on texel boundaries; constant 4Ã—4 depth cells avoid
ambiguous neighboring point samples from reciprocal roundoff. The original
uncorrected larger-pool shader must measurably fail at reduced sizes.

`hero_lighting.cpp` exercises the BlitzFX hero skin shader with temporary local
lights, including an outside-radius final light. Restore `head-b1.bin`,
`head-b2.bin`, `head-b3.bin`, `head-b4.bin`, `head-b5.bin`, `head-b12.bin`,
`head-b13.bin` and the pre-fix `0x90BFECE8-before.cso` from the local
`blitzfx-20261024/igni-face/` archive, plus original `0x90BFECE8.cso` from
`blitzfx-20261023/scene-shaders/`. It uses captured constants with controlled
textures/light lists, not a complete live draw replay. The test requires the
pre-fix blob to fail measurably and the replacement to match finite native RGB
across 12 cases. A zero-light-only fixture misses the leaked sun-direction index.

```bat
clang-cl /std:c++20 /EHsc /O2 /DNOMINMAX src/games/thewitcher3classic/tests/hero_lighting.cpp /Fe:tmp/classic-tests/hero-lighting.exe /Fo:tmp/classic-tests/hero-lighting.obj /link d3d11.lib d3dcompiler.lib
tmp\classic-tests\hero-lighting.exe tmp/witcher3classic-investigation/blitzfx-20261024/igni-face tmp/witcher3classic-investigation/blitzfx-20261023/scene-shaders
tmp\classic-tests\hero-lighting.exe tmp/witcher3classic-investigation/blitzfx-20261024/igni-face tmp/witcher3classic-investigation/blitzfx-20261023/scene-shaders --hardware
```

`temporal-dev/` abbreviates `tmp/witcher3classic-investigation/temporal-dev/`.

`blitzfx_dof.cpp` requires original `0xB018A95A.cso`, `0x48885E0D.cso`,
`0xB73522BB.cso` and `0xAE334616.cso` from the local
`blitzfx-20261024/depth-of-field/` archive. It compares shipped blobs against
native passes on physically smaller textures with distinct RGB/CoC and poisoned
unused allocation pixels. It reads every output channel, including the second
reduction UAV, at six sizes (one odd) with gameplay and packed cinematic flags.
Each original larger-pool shader must reproduce an addressing failure. Native
RGB gathers and flag bits are part of equivalence, not optional shader cleanup.
The extended fixture also expects `0x249DA2F1.cso` and checks camera motion blur
at the same six sizes, both static and translated reprojection. Its per-texel
border gather must preserve the native mask; simply moving the gather inward
does not. Use the `cutscene-permutations/` archive as the argument for all five
originals after this extension (the four DoF originals are copied there).

```bat
clang-cl /std:c++20 /EHsc /O2 /DNOMINMAX src/games/thewitcher3classic/tests/blitzfx_dof.cpp /Fe:tmp/classic-tests/blitzfx-dof.exe /Fo:tmp/classic-tests/blitzfx-dof.obj /link d3d11.lib d3dcompiler.lib
tmp\classic-tests\blitzfx-dof.exe tmp/witcher3classic-investigation/blitzfx-20261024/depth-of-field
tmp\classic-tests\blitzfx-dof.exe tmp/witcher3classic-investigation/blitzfx-20261024/depth-of-field --hardware
```

The effects archive is `tmp/witcher3classic-investigation/effects-20261023/`.
The shader table/source changes over time; counts in old logs are historical.
WARP is useful for shader regression but cannot execute NVIDIA NGX. Hardware
fixtures use the default hardware adapter; verify it is the intended NVIDIA GPU
on multi-adapter systems. Do not label WARP-only clip checks as hardware proof.

```bat
tmp\classic-tests\object-history.exe
tmp\classic-tests\upscale-engine.exe
python src/games/thewitcher3classic/tests/motion_fingerprint.py

tmp\classic-tests\constant-uploads.exe
tmp\classic-tests\constant-uploads.exe --hardware

tmp\classic-tests\object-motion.exe tmp\witcher3classic-investigation\temporal-dev\devkit-live\dlss-audit
tmp\classic-tests\object-motion.exe tmp\witcher3classic-investigation\temporal-dev\devkit-live\dlss-audit --hardware

tmp\classic-tests\foliage-motion.exe tmp\witcher3classic-investigation\temporal-dev\foliage-20261023
tmp\classic-tests\foliage-motion.exe tmp\witcher3classic-investigation\temporal-dev\foliage-20261023 --hardware

tmp\classic-tests\dlss.exe tmp\witcher3classic-investigation\temporal-dev\dlss-runtime

tmp\classic-tests\effects.exe tmp\witcher3classic-investigation\effects-20261023
tmp\classic-tests\effects.exe tmp\witcher3classic-investigation\effects-20261023 --hardware
```

For focused object checks, append `--forward-only` or `--hair-clip-only` after
the optional `--hardware`. The default full suite should still run before
shipping a change that can affect other paths. FXC compilation success does not
prove native equivalence; consume all varyings in clip tests. The effects fixture
loads the actual Release blobs because a prior ad-hoc D3DCompile nested-include
path failed; do not replace it with an unverified compiler path.

## Recapture and archive

Use the [DevKit exact-input procedure](../../../../docs/DLSS_INTEGRATION_PLAYBOOK.md#exact-capture-procedure).
Dump the **original native** shader, not the replacement. For binary constant
fixtures, preserve captured words in native little-endian order, bound byte
offsets and the slot/frame naming expected by the test. Foliage requires its
actual wind/contact slots and more than one captured state; inspect the fixture
source before capture. Preserve original bytecode, not just decompiled HLSL.

Keep a manifest with relative filename, SHA256, capture provenance (executable,
shader/stage/draw/frame, settings), test command, GPU/driver and result. Store
logs and build hash with the archive. Record missing evidence explicitly. The
ignored scratch folder and an old chat session are not a durable archive.

## Live acceptance after relevant tests

Rebuild/link when the game is closed, verify the loaded binary and replacement
registration, then test the affected case. For temporal work, cover camera-only
motion, animation-only motion, both moving, disocclusion, LOD/culling, owner
destruction/reuse, menu round trips and quality/resize transitions. Compare raw
object coverage, final NGX vectors and the resulting temporal image separately.
Repeat performance measurements with capture/debug disabled and unchanged
settings. Record which checks were actually performed; never infer full scene
acceptance from these bounded fixtures.

## Custom optical pipeline

Build normal Release embeds first. Compile `optics.cpp` with C++20, `/EHsc /O2
/DNOMINMAX`, `/Ibuild/thewitcher3classic.include`, and link `d3d11.lib dxgi.lib
user32.lib`. Run without arguments for WARP or with `--hardware` for NVIDIA.
Scratch runner: `tmp/witcher3classic-investigation/pt-optics-20261026/test-optics.cmd`.
This deterministic fixture requires no captured binaries.

It exercises the production pipeline: HDR energy, signed gamut, focused plane
identity and defocus, near/far coverage, zero-motion identity, object-only
camera exclusion/actual object blur, 30/60/120/240 FPS shutter equivalence,
history reset, odd-size resize, once-per-frame execution, context restoration,
RCAS scratch execution and 32 camera transforms against independent DirectXMath
projections with distinct jitters. The debug layer is checked if available.

`object_motion.cpp` and `foliage_motion.cpp` accept `--object-only`, optionally
after `--hardware`. These exercise RGBA motion storage and transform binding
while preserving the existing lighting/coverage/clip/history assertions. Native
reflection audits PS t119. Existing geometry checks validate XY; the optical
fixture separately checks blur-only ZW selection.

The effects fixture checks native motion-blur sharp copy and transparent
BlitzFX depth-blur/DoF composites. With `--blitzfx`, it additionally checks the
compute blur bypass and replacement bloom with uniform scattering zeroed,
underwater isolation, Native mode and poisoned pool borders. CA fixtures use the reference intensity of 1. The center-offset setting was
removed; the lens curve now has a fixed reference shape. Motion tests also
cover camera-followed subjects, nearly stationary screen motion, opposite
camera/object directions and the screen-speed bound from Remastered.
Build/link only after the game releases its addon DLL and follow
the mod README's separate live acceptance checklist.


### Atmospheric fog and Custom water

`volumetrics.cpp` exercises the real production volume pipeline on WARP and
NVIDIA: constant-medium analytic radiance/transmittance, vacuum, shadowing,
independent density/light controls, start/height profiles, dense finite output,
odd sizes, frame freshness and context/SRV/sampler restoration. `--hardware`
selects NVIDIA; optional `--benchmark` measures only its synthetic volume path.

`fog_composite.cpp` takes the capture directory containing `cb3.bin`, `cb12.bin`
and `native-fog.cso`. It compares the embedded C8 shader's Native branch with
original bytecode and checks custom L/T with the captured suppression mask.
It also rasterizes a real clip-W=32 triangle to validate transparent radial
fog lookup. Do not substitute a hand-written reciprocal-W input for this test.

`water.cpp` uses the production snapshot/binding pipeline and compiles
`water_test.hlsl`, which includes the production water math/shading. It checks
Fresnel against independent dielectric equations, Beer–Lambert attenuation,
zero/near-zero extinction integrals, finite GGX, water-then-air composition,
reflection weighting, independent water ambient with a poisoned atmospheric
source, a poisoned allocation border, exact GPU frame-CB copy,
stale-frame rejection, restoration and odd resize. Run from the repo root in
a VS developer shell with LLVM available:

```bat
clang-cl /std:c++20 /EHsc /O2 /DNOMINMAX src/games/thewitcher3classic/tests/water.cpp /Fe:tmp/test-water.exe /Fo:tmp/test-water.obj /link d3d11.lib d3dcompiler.lib dxgi.lib user32.lib
tmp\test-water.exe
tmp\test-water.exe --hardware
```

Do not define NDEBUG: these fixtures use assertions. The shader test exercises
the shared material; it does not certify every native/BlitzFX geometry adapter,
all water exclusion volumes, live SSR quality or in-game cost. The complete
Release shaders must also compile and the README's live comparisons must pass.


The water fixture additionally uses a genuine perspective camera and synthetic
depth planes to check normal/oblique Snell-ray hits, foreground/empty/far-depth
rejection and screen-edge/parallel-ray fallbacks. Expected refraction coordinates
come from independent analytic plane intersections. Its local-fog light-path
test compares GPU transmittance with 10,000-step CPU quadrature across heights,
upward/downward/horizontal light and vacuum. The volume fixture checks the
unoccluded-minus-occluded sunlight energy against a homogeneous-medium closed
form including incoming-light extinction, not merely a brightness threshold.
All three fixtures pass WARP and NVIDIA for the refraction/shore/sunlight
revision. The D3D11 debug layer was unavailable; these are numerical/state tests,
not a substitute for driver validation or broader in-game weather coverage.


Particle fog/linkage: `fog_signatures.py PATH_TO_ORIGINAL_DXBC_DUMP` compares
native input/output registers and component locations with all compiled fog and
water replacements. Preserve the original position of every TEXCOORD; appending
SV_Position is allowed only at the upstream VS's matching position. The
`fog_composite.cpp` fixture additionally requires
`particle-originals/0xA7921C82.ps_5_0.cso` beneath its capture-directory argument.
It renders the actual original and replacement spark pixel shaders using a VS
with the native output layout. It checks identical native emission and exactly
T-scaled additive emission with a custom volume (no added atmospheric radiance).

`water_reflections.cpp` uses the production MRT capture/resolve class, synthetic
emissive and water planes, and compiled F3C40001. Build like water.cpp with
`/Ibuild/thewitcher3classic.include`; run on WARP and with `--hardware`. Checks:
reflected energy, native color unchanged, original MRT/blend state restored,
once-per-frame resolve, no stale/empty-particle reuse, foreground occlusion.
The tests do not certify live SSR stability, all particle materials, BlitzFX's
render order or performance. Verify those in-game after linking.


The composite fixture also requires `particle-originals/0x4EF2AAF8.ps_5_0.cso`.
It compares the glow material against original bytecode over the full UV domain,
covering the radial bit-mask-to-float selection that caused the first live Igni
blowout. Both WARP and NVIDIA report zero native difference. Reflection tests
also cover the live R11G11B10 scene source converted to RGBA16F and
ONE/INV_SRC_ALPHA blending with the shader's zero alpha; previous fixtures only
exercised RGBA float and ONE/ONE and therefore missed those runtime rejections.


The reflection fixture now exercises both F3C40001 and F3C40002, including
half-resolution tracing and the production spatial reconstruction. A separate
sparse checker-radiance test asserts average energy, reduced spatial variance,
exact land/foreground exclusion and unchanged base channels/alpha. Use the
fresh generated embeds before compiling. Two FP16 stores in the R11 conversion
case require a 0.003 error budget; do not mistake quantization for missing-ray
energy loss. The uniform-plane fixture also caught the projected segment
escaping the viewport before the first intersection; clipping must precede
the fixed-step traversal. Live moving Igni noise remains a separate check.


The earlier F3C40001/F3C40002 reflection tests above are historical: those shaders
and the rejected particle ray tracer have been removed. water_reflections.cpp
now tests production previous-raw-HDR input to the native SSR pass. It requires
particle-originals/0x406B9233.ps_5_0.cso under the session scratch directory and
the current generated embed/0x406B9233.h. The same test-water-reflections.cmd
builds and runs WARP/NVIDIA. Tests cover exact original fallback, HDR preservation,
all supported color formats, captured R24 typeless depth, camera translation and
jitter on a radiance ramp, render-pool cropping, history lifecycle and state
restoration. These are integration invariants; live Igni quality and GPU cost
must still be checked separately.


Depth-copy regression: the source MUST have both D3D11_BIND_DEPTH_STENCIL and
D3D11_BIND_SHADER_RESOURCE, with an actual D24_UNORM_S8_UINT DSV. A typeless R24
texture with only SRV binding incorrectly permits a cropped copy and failed to
reproduce the game's empty-history bug. Change depth with ClearDepthStencilView,
not UpdateSubresource. The production history must copy the full allocation,
even when the source render viewport is smaller. Color cropping remains valid.


### Transparent depth for native SSR (2026-10-27)

`water_reflection_trace.cpp` compares both outputs against original 47CC9FA1
DXBC with captured camera constants and synthetic water/depth/color inputs.
Point/linear samplers and both fallback branches match exactly on WARP/NVIDIA.
A separate intersection-depth layer must change hits without changing coverage.
Use scratch `test-water-reflection-trace.cmd`; original bytecode and captured
trace-cb3.bin/trace-cb12.bin are local fixture dependencies.

`water_reflections.cpp` now tests original-draw particle depth capture, .75/.25
conventional/reversed projection conversion, expired/transparent depths, and
native blend/RTV/SRV restoration. `fog_composite.cpp` verifies actual fire PS
color equivalence with an extra depth MRT and actual rasterized clip W=8.
The fire fixture uses nonzero radiance (1992 visible / 2104 transparent pixels),
so zero-valued output cannot accidentally pass the depth coverage assertion.
These tests do not replace the pending live visual/performance check.


### Native lighting extension (2026-10-27)

See ../LIGHTING.md for captured shader hashes, data contracts and test scope.
Compile generated embeds with the established clang-x64-release preset before
running lighting.cpp. Local test-lighting.cmd in
tmp/witcher3classic-investigation/lighting-20261027 compiles and runs WARP and
NVIDIA tests. Fixtures include originals/*.cso and lighting/shadow/hair captured
constant buffers in that same scratch folder; they are not portable bundled
fixtures. test-object-motion.cmd runs object_motion.cpp --forward-only on both
adapters. Both final runs passed. These checks establish native equivalence,
control isolation, valid shadow output and unchanged motion coverage; actual
game quality/performance and the runtime color-only binding still need checking.


### Water metadata row regression (2026-10-28)

water.cpp extracts and executes the production 28D7BDFE metadata-load block.
A 64-tile table has different world-bounds and atlas-UV rows. Reading row 0
twice (the old float-denormal-to-integer bug) returns zero and fails; the
original row 0/row 1 contract passes on WARP and NVIDIA. This is a focused
load-coordinate regression, not full water pixel-shader equivalence. Run
tmp/witcher3classic-investigation/volumetrics-20261027/test-water.cmd from
the repository root. See ../EFFECT_AUDIT.md for native-bytecode evidence.


### Direct lighting/shadow audit regression (2026-10-28)

lighting.cpp now includes nonzero packed local-light shadow atlas offsets and
layers; the old decoder fails against original DXBC, the repair matches. The
contact fixture runs production ContactPipeline with R24G8 depth/stencil,
grass, billboard trees, excluded hair/leaves/translucency, back-facing
characters, ranged constant bindings, resize and larger-pool bounds.
Scratch effect-audit-20261028/test-atlas-before.log records the reproduced old
failure. test-shadow-final.log and test-motion-final.log record the new checks.
Use the existing lighting-20261027/test-lighting.cmd and test-object-motion.cmd.


### Interior fog density (2026-10-28)

`volumetrics.cpp` binds an actual R16G16_FLOAT interior texture to production
`Pipeline::Generate`. Analytic optical lengths cover outside/inside interval
ordering, entry and exit ramps, moving boundaries, equal-boundary sentinels,
far interiors and missing/invalid data. Every integrated cell before an indoor
exit must be exactly (0,0,0,1). A poisoned larger pool checks active-rectangle
coordinates in every ray; CS t3 must be restored after injection. Run the
existing volumetrics-20261027/test.cmd after regenerating Release shader embeds.
The companion test-composite.cmd retains native fog/particle equivalence checks.
These tests do not establish coverage for caves lacking native dimmer volumes.


The lighting fixture additionally requires interior-fog-20261028/0xFAB74FB3.cso
and hair-transparent-cb1/2/4.bin captured from the original transparent-hair
draw. It checks native RGBA, tagged-fill control isolation, and original versus
replacement hair lighting across camera directions and packed shadow tiles.
It recompiles the former incorrect numeric decoder as a negative control; that
shader must differ, while the corrected shaders must match native bytecode.
The old-hair-atlas.cso artifact stays in scratch. Run lighting-20261027/
test-lighting.cmd, then test-object-motion.cmd for the shared forward bodies.


Fog quality: volumetrics.cpp now allocates every production volume level and
resizes in both directions. Only the last center cell is copied for these large
fixtures. A known PCF edge independently checks the 4/9/16/25-tap weights, while
homogeneous-medium checks ensure quality does not change density or light energy.
Use volumetrics-20261027/test.cmd after regenerating the Release shader embed.


Toussaint height profile: volumetrics.cpp replays the captured base density,
height offset and vertical coefficients on a horizontal ray and compares the
integrated radiance/transmittance with an independent reciprocal-height closed
form. water.cpp checks the shared incoming-light integral against 10000-step
quadrature for ground crossings, high altitude, horizontal/nearly horizontal
light, and tiny falloff at large height. The water fixture explicitly selects
clarity 1 for its reference medium instead of inheriting UI defaults.
Run volumetrics-20261027/test.cmd and test-water.cmd after regenerating embeds.


Distant weather haze: volumetrics.cpp checks the captured 16707.9 m Toussaint
range against constant-height Beer-Lambert radiance/transmittance, tests a 100 m
sample, reads back the published sampling range, and checks an authored interior
between 1000 and 4000 m. The previous fixed-range shader fails the new reference.
Run volumetrics-20261027/test.cmd and test-water.cmd after rebuilding embeds.

Contact-shadow sampling: lighting.cpp checks fixed sampling as reach changes,
with both axes/directions and three subpixel phases, and rejects self-shadowing
on a shallow sloped plane. Run lighting-20261027/test-lighting.cmd after rebuilding
Release embeds. Original stretched and rejected DDA traces fail the suite.
The former zero-thickness footprint fixture was not a useful visual predictor
for this heuristic and is removed. Scratch contact-blitz-20261028/reference.cmd
runs the exact BlitzFX 1.1.0 bytecode against production masks with matched static
noise; interior character-blocker cases match on WARP/NVIDIA. The binary needs to
be extracted from the user's blitz.shaders archive; it is not distributed here.
Live animation/foliage acceptance is still necessary.

Temporal contact shadows: contact_history.cpp runs the production history shader
on controlled multi-frame noise and motion/depth fixtures. It checks attenuation,
object and jitter reprojection, disocclusion, immediate blocker removal, cut/light/
settings resets and offscreen rejection. Run contact-blitz-20261028/test-history.cmd
on WARP/NVIDIA. lighting.cpp separately tests actual ContactPipeline history
resources and ranged constant copies, gaps/failure recovery, real accumulation
and immediate settings invalidation. These checks complement live animation QA.
