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
quarter sampling lands on texel boundaries; constant 4×4 depth cells avoid
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
