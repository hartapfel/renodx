# Classic temporal reconstruction regression fixtures

## HDR10 presenter, HUD capture and camera fixtures

The implementation checkpoint and known limits are in
[frame_generation/README.md](../frame_generation/README.md).
Install the official SDK with `../frame_generation/install-sdk.ps1` first.
From an x64 VS developer command prompt at the repository root:

```bat
clang-cl /nologo /std:c++20 /EHsc /O2 /DNOMINMAX src/games/thewitcher3classic/tests/frame_generation_presenter.cpp /Fe:tmp/witcher3classic-fg/presenter.exe /Fo:tmp/witcher3classic-fg/presenter.obj /link d3d11.lib d3d12.lib dxgi.lib user32.lib
clang-cl /nologo /std:c++20 /EHsc /O2 /DNOMINMAX src/games/thewitcher3classic/tests/frame_generation_swapchain.cpp /Fe:tmp/witcher3classic-fg/facade.exe /Fo:tmp/witcher3classic-fg/facade.obj /link d3d11.lib d3d12.lib dxgi.lib user32.lib
clang-cl /nologo /std:c++20 /EHsc /O2 /DNOMINMAX /Iexternal/Detours/include /Ibuild/thewitcher3classic.include src/games/thewitcher3classic/tests/frame_generation_hud.cpp /Fe:tmp/witcher3classic-fg/hud.exe /Fo:tmp/witcher3classic-fg/hud.obj /link d3d11.lib d3dcompiler.lib dxgi.lib user32.lib
clang-cl /nologo /std:c++20 /EHsc /O2 /DNOMINMAX src/games/thewitcher3classic/tests/frame_generation_camera.cpp /Fe:tmp/witcher3classic-fg/camera.exe /Fo:tmp/witcher3classic-fg/camera.obj /link user32.lib
```

Stop on any compiler failure. Run `presenter.exe` and `facade.exe` with the
absolute installed SDK `bin/x64` directory as their argument. The presenter
briefly focuses its test window (NVIDIA disables interpolation without focus),
then restores the prior foreground window. It checks real 2x/4x/6x presents,
6x with UI recomposition requested, missing-input suspension, resize and
shutdown. It attempts to enable the optional D3D12 debug layer and explicitly
reports if unavailable. Run outside the process sandbox if NGX shutdown stalls;
do not remove signature verification.

Run `hud.exe <absolute-original-shader-dump-directory>` after building the
Classic shader target. It compares all three new UI shaders against original
`0xC38B68F9.ps_5_0.cso`, `0xD7880DBE.ps_5_0.cso`, and `0x7560E408.ps_5_0.cso`.
WARP must preserve target-0 color bit-for-bit and accumulate R8 alpha correctly.
It also exercises unknown-write and unsupported-blend rejection.

Run `camera.exe tmp/witcher3classic-fg/camera.bin`. This fixture is the 720-word
b10 upload captured on 2026-10-28, exported from `camera-capture.json` using
`struct.pack('<720I', *capturedWords)`. It checks the independently captured
camera position/FOV and raw-depth reprojection; its expected pose belongs to
that capture. All capture artifacts remain in ignored scratch storage.

These fixtures do not hook the game and do not establish Classic image quality,
latency, UI coverage, or performance. Keep assertions enabled.

## Frame Generation foundation

See [research, contracts and live verification](../frame_generation/README.md).
These are standalone tests. They do not inject FG into the running game.

From an x64 VS developer command prompt, with assertions enabled:

```bat
if not exist tmp\witcher3classic-fg mkdir tmp\witcher3classic-fg
clang-cl /nologo /std:c++20 /EHsc /O2 /DNOMINMAX src/games/thewitcher3classic/tests/frame_generation_interop.cpp /Fe:tmp/witcher3classic-fg/interop.exe /Fo:tmp/witcher3classic-fg/interop.obj /link d3d11.lib d3d12.lib dxgi.lib
if errorlevel 1 exit /b 1
tmp\witcher3classic-fg\interop.exe
if errorlevel 1 exit /b 1
tmp\witcher3classic-fg\interop.exe --warp
```

Hardware mode selects NVIDIA; WARP verifies API behavior separately. The fixture
checks all bytes of RGB10A2 color, R32 depth, signed RG16F motion and R8 alpha
across three queued frames, delayed consumption, backpressure/reuse, invalid
formats/extents and different-size allocations. CPU readback is test-only.

Extract the official Streamline 2.14.16 x64 release into
`tmp/witcher3classic-fg/sdk`, or substitute your SDK path below. The repository's
2.8 headers are deliberately rejected; no global build/dependency update is
needed for the standalone probe:

```bat
clang-cl /nologo /std:c++20 /EHsc /O2 /DNOMINMAX /Itmp/witcher3classic-fg/sdk/include src/games/thewitcher3classic/tests/frame_generation_sdk.cpp /Fe:tmp/witcher3classic-fg/sdk-probe.exe /Fo:tmp/witcher3classic-fg/sdk-probe.obj /link d3d12.lib dxgi.lib user32.lib
if errorlevel 1 exit /b 1
rem No argument: only policy and official options mapping assertions.
tmp\witcher3classic-fg\sdk-probe.exe
rem SDK bin/x64 argument: also initialize/query/shut down the signed runtime.
tmp\witcher3classic-fg\sdk-probe.exe "%CD%\tmp\witcher3classic-fg\sdk\bin\x64"
```

Policy checks include multiplier limits, Dynamic versus Auto, invalid targets,
and refusal without complete HDR/Reflex/presentation/HUD/gameplay prerequisites.
The runtime probe reports capabilities, not frame interpolation. It creates no
display swapchain and changes no driver profile. Logs are under
`tmp/witcher3classic-fg/sdk-logs`. The sandboxed NGX shutdown stalled on this
machine; the unrestricted standalone run completed. Never bypass signature
verification to work around a probe failure.

The integrated addon exposes FG controls and has generated frames in Classic.
Build the full Release target with the game closed; object-only compilation
does not replace the installed addon. Live evidence and remaining acceptance
checks are recorded in the FG README.

The native timing fixture uses mocked SDK callbacks and an actual worker
thread/message queue. It verifies matching command tokens when simulation runs
ahead, marker ordering, one-shot consumption, unknown commands, old-session
and recycled-token rejection, and PCL ping dispatch at the pump. It does not
prove native hook addresses or game input latency.

```bat
clang-cl /nologo /std:c++20 /EHsc /O2 /DNOMINMAX /Itmp/witcher3classic-fg/sdk/include src/games/thewitcher3classic/tests/frame_generation_engine.cpp /Fe:tmp/witcher3classic-fg/engine.exe /Fo:tmp/witcher3classic-fg/engine.obj /link d3d11.lib d3d12.lib dxgi.lib user32.lib
if errorlevel 1 exit /b 1
tmp\witcher3classic-fg\engine.exe
```

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


### Frame Generation lens mapping regression

`frame_generation_distortion.cpp` uses the Release embedded `0xF3CF0001`
shader. Build like `frame_generation_hud.cpp` (same include/link arguments),
then run without arguments. It checks signed FP16 forward/inverse mapping at
16:9 and ultrawide across CA intensity 0..5 and verifies cached texture reuse.
`frame_generation_presenter.cpp` also exercises the optional distortion tag,
field updates and null-tag removal. Its visible window must retain focus;
NVIDIA intentionally stops interpolation if it loses focus.

For captured gameplay inputs, run
`python analyze_frame_generation_inputs.py <inputs-directory>` with NumPy.
The capture causes deliberate stalls and is not a performance benchmark.

### Live Frame Generation switching

Run `frame_generation_presenter.exe <production-SDK-bin/x64> --toggle`
with its window focused. It starts Off and switches through 2x, Off, then 3x
on the same swapchain. It asserts live mode changes and actual generated
presents. The 2026-10-28 hardware run passed: 60/115/60/180 displayed frames
for four batches of 60 rendered frames, including resize and clean shutdown.
The D3D12 debug layer was unavailable; this is hardware validation only.
After the Release rebuild, verify in game: start with no saved DLSSFGMode
(Off), enable FG during gameplay, change its settings, restart and confirm
those choices persist. Existing user preferences must not be reset.

### Radial-menu and post-menu HUD coverage

`frame_generation_hud.cpp` now requires seven original DXBC files in its
input directory: C38B68F9, D7880DBE, 7560E408, F1A79FBF, 72826F5B,
CC0C2DF3 and D98FBA78, named `0xHASH.ps_5_0.cso`. The new originals were
dumped through DevKit from the radial menu and subsequent gameplay.
WARP verifies unchanged FP16 color, accumulated R8 alpha, native-state
restoration, stencil-only write-mask handling and next-frame recovery.
Rebuild `thewitcher3classic` in Release, restart, open/close the signs/items
radial menu repeatedly, and confirm FG stays active while valid gameplay
inputs remain available; inspect icons, text and clipped menu elements.

`frame_generation_ui.cpp` covers the full 198-entry `ui_shaders.hpp` family.
Compile with the same flags/libraries as the HUD fixture and run with a
directory containing original `0xHASH.ps_5_0.cso` files. WARP compares all
color channels and emitted coverage against original DXBC using three
patterned texture/constant cases. The 2026-10-28 run passed all 594 cases
with zero FP32 color error. It also checks sorted registration order.
The HUD fixture tests smaller/equal-size offscreen UI targets between
main-HUD draws. Live vanilla-HUD, minimap/filter and radial-menu visual
acceptance remains necessary; absent shader permutations are not certified.

Additive HUD: the HUD fixture verifies native SRC_ALPHA/ONE blending keeps
the pre-UI scene valid, latches only optional alpha invalidity, does not
recapture later UI, and restores alpha on the next frame. The presenter
`--toggle` run removes/restores UIAlpha for 30 frames per mode and checks
actual generation plus conditional UI recomposition. Hardware passed
60/90 displayed frames for 30 alpha-less frames at 2x/3x, respectively.


Velen weather opacity: volumetrics.cpp checks captured exponent 0.50754434 and
7.15734 m start / 0.005299725 per-metre fade at every integration boundary,
with an independent homogeneous optical-depth integral. Radiance, monotone
opacity, sun/shadow consistency, exact vacuum and empty interior segments are
checked on WARP and hardware alongside the existing Toussaint cases.

fog_composite.cpp supports an additional --weather mode. Provide a capture
directory with cb3.bin, cb12.bin, cb13.bin and original native-fog.cso. White
fog source on black background isolates the original DXBC's opacity while
retaining the captured camera/weather. The real production volume and opaque
composite must agree within 0.025 over 8-1000 m, allowing the native 16-step
opacity product versus analytic Beer-Lambert integration and volume filtering.
The captured Velen and identity-exponent cases pass on WARP/NVIDIA with max
error below 0.0114; the prior integration fails (max 0.2484).

Build with /Ibuild/thewitcher3classic.include after regenerating the Release
shader embeds; link d3dcompiler.lib d3d11.lib dxgi.lib user32.lib. Run the
executable with CAPTURE_DIR --weather, then CAPTURE_DIR --weather --hardware.
Without --weather the existing native fallback, AO, forward and particle
regressions still run. Captures and standalone build scripts are scratch data,
not shipped binaries. In-game fog appearance remains a separate acceptance.


The second live weather capture (exponent 1.20301342, 1 m start, fade slope
0.015136439/m) is included in the same analytic volume test. Original DXBC
replay also passes for that captured camera/profile and identity exponent:
max under 0.0158, mean under 0.0025. Prior integration fails with max 0.0811.
This specifically tests the opposite regression: too much fog when exponent
exceeds one, versus too little in the first Velen capture below one. It
compares opacity, not complete authored color or additional sun scattering.

### Clean storm regression and live acceptance (2026-10-29)

storm-clean-20261029 contains the post-repair C8C78997 input capture and
cb3/cb12/cb13 binaries. Run fog_composite with this folder and --weather on
WARP and --hardware. Captured exponent 1.18319178: 6330 compared channels,
maximum/mean absolute opacity error 0.0212807/0.00427048 on NVIDIA and
0.0212082/0.00426984 on WARP. Both the authored and identity exponents pass
the existing 0.025 bound. The user accepted the fog-strength tolerance.
This isolates opacity; it does not measure full native/custom fog RGB parity.

The weather-material fix has live acceptance for corruption-free storms and
preserved HDR range. ReShade.log reports both material copies completed and
HDR pool routing restored. source-analysis.json reads the owned pre-fog input:
RGBA16F, RGB maxima 35.5/32.875/29.828125, 909801 pixels above 1, zero NaN/Inf.
Before-draw DevKit RTV metadata can precede the addon corrective bind and must
not be mistaken for evidence of its final binding. The initial permanent
two-MRT exclusion clamped HDR and was replaced by scoped save/restore routing.

Existing test-volumetrics and fog_composite (normal mode) pass on WARP/NVIDIA:
native bytecode fallback max error 0, HDR/AO composition max 1.90735e-6,
volume/interior cases, perspective-W lookup, and particle color/depth cases.
No optional D3D debug layer was available. Release build and package byte
verification passed. No new GPU workload or synthetic benchmark claim is made.

### Volumetric local lights (2026-10-29)

tests/volumetrics.cpp exercises the production scatter/integration shaders with
native-format raw forward tile lists and synthetic point/spot records. It checks
an independent scalar transport integral, colored values above SDR white, exact
unchanged volume alpha, strength scaling, live count/sentinel guards, artificial
fill exclusion, exact vacuum and outside-spot-cone rejection. Distinct lit/dark
atlas layers verify all six native point faces and spot atlas selection. A
two-cube array checks cube ESM; absent required maps reject shadowed light.
Existing weather/interior tests remain active. WARP and NVIDIA both pass.

The --hardware --benchmark path also timestamps complete production volume
generation at Low/Ultra with 0, 4 and 24 synthetic overlapping point lights.
Measured total GPU times are 0.0296/0.0417/0.1075 ms Low and
0.3164/0.4630/1.1807 ms Ultra. This is not total gameplay GPU time and does not
bound all shadow/scene costs. The optional D3D debug layer is unavailable.
Native fallback remains exact against original C8C78997 bytecode; HDR/AO error
is 1.90735e-6; captured Velen and clean-storm opacity fixtures still pass.

Evidence in local-volumetrics-20261029 includes the original tile-cull shaders,
native fog/lamp bindings/constants, build/test logs, timestamp results and the
Release package log. Use test.cmd for WARP/NVIDIA. Live verification: compare
Local Light Scattering 0/1 near real lights, test blockers and cone boundaries,
verify fog strength/interior behavior is unchanged, then enable FG and check HDR.

Live acceptance: user confirmed the local-light 0/1 comparison looks correct
after the Release restart. Package bytes match the linked addon. New compute
SRV slots 4-6 restoration passes on WARP/NVIDIA. Storm routing remains active.

### Native fog color and independent sky density (2026-10-29)

fog_composite supports --weather-color (captured directional/local source color
over black) and --weather-scene (captured weather/desaturation over signed HDR).
Both compare original C8C78997 bytecode with the production volume/sampler.
--weather-color includes an identity opacity-exponent control; --weather-scene
uses the captured exponent. The normalized error bound is 0.05 using
abs(delta)/(1+abs(native)); the existing white opacity bound remains 0.025.
The current, Velen, second-scene and clean-storm RGB/HDR cases pass on NVIDIA;
the current RGB/HDR and existing volume/fallback cases also pass on WARP.

--sky requires native-sky.cso and sky-cb0/sky-cb1.bin alongside the usual capture
constants. It compares original BC930752 against the custom sky with direct
scattering off, at density multipliers 0/.5/1/2 for actual and reduced-density
profiles. WARP/NVIDIA maximum error is below 0.00025 (bound 0.002). This detects
accidental substitution of the opaque density profile for the native sky.

--weather-scene --hardware --benchmark tests 2560x1440 GPU composite timing and
requires old-opaque.cso for a previous-custom negative control. Final run:
native/previous/corrected 0.06211/0.06535/0.06660 ms; old/corrected maximum RGB
errors 0.89803/0.15892. Measurements are synthetic RGBA32F, not gameplay FPS.
Fixtures/logs stay in tmp/witcher3classic-investigation/fog-parity-20261029.
The volume fixture validates the expanded 21-float4 GPU parameter output and
uses the native directional-height blend (symmetric fixture has bias 1).

Live acceptance: user confirmed the corrected same-scene fog strength and
independent Sky Haze Density control. A synthetic two-override blend (second
color .3/.7/1.1, alpha .35, environment blend .37) also passes RGB/HDR tests
against original bytecode on WARP/NVIDIA. Package bytes match the deployed DLL.

### Moving sunlight shaft continuity (2026-10-29)

volumetrics.cpp tests a 150 m shadow edge projected entirely along cell depth,
at 65 quarter-metre camera positions. Compare the production integrated HDR
source with an independent closed-form illuminated-medium integral; alpha must
remain unchanged. Bounds: normalized reference error <0.0015, largest motion
step <0.002. WARP/NVIDIA produce 0.0004972/0.0005667. A disagreeing cascade pair
must follow native blend widths (error 0.0006377, bound 0.001). These replace
the old planar-grid PCF tap-count-specific edge expectation.

The saved previous scatter header is a negative control: error 0.0103149 and
motion step 0.0056673 fail the new assertions; cascade error is 0.8211. The
scratch old-report build bypasses only those expected failures to time the old
kernel, not to certify it. All ordinary regressions run with assertions active.
Idle-device Ultra old/new GPU times for 0/4/24 lights are 0.3419/0.4023,
0.4723/0.5714 and 1.1781/1.1610 ms; not an in-game cost guarantee. Logs/fixtures:
tmp/witcher3classic-investigation/fog-quality-20261029. Debug layer unavailable.


### Direct-light precision, cubic reconstruction and per-pixel fog (2026-10-29)

volumetrics.cpp now proves dim lamp precision independently of bright weather
ambient: integrated red 0.000858307 versus scalar 0.000859315. The volume stores
direct light rather than mixing ambient into FP16 and subtracting it later.
fog_composite's cubic impulse test checks a continuous CPU B-spline response,
constant/HDR bounds, nonnegative reconstruction and bit-identical linear alpha.
The GPU's finite texture-filter weights explain the 0.0202/0.0253 WARP/NVIDIA
error on a 16-unit impulse; bound is one 1/256 weight step (16/256). Both changes
passed but the user reported remaining bands in gameplay.

--pixel enables the production per-pixel path in --weather, --weather-color,
--weather-scene and --sky cases. The resized native integer-pixel reconstruction
matrix must preserve pixel-center offsets as well as rescale its two basis
vectors. Pixel weather comparisons have a 0.001 absolute opacity or normalized
RGB/HDR error bound; existing Volume bounds remain 0.025/0.05. Archway, Velen,
second weather, clean storm and two-override captured bytecodes pass NVIDIA
HDR replay; current archway and point cases also pass WARP. Sky is exact at
0/.5/1/2 density for both tested native profiles with direct lighting disabled.

--pixel-local compares the production ray integrator against independent
4096-step scalar transport, both unshadowed and with native exponential cube
shadow attenuation. It checks a surface behind the lamp and a surface in front
(no in-scattering), then reuses/clears the native b13 buffer after capture to
prove snapshot independence. All PS slots 99..107 must restore, and an
unsupported short light buffer must allocate the full fallback grid instead of
a tiny parameter-only volume. Max point/shadowed red error is
0.00007131/0.0016683 on NVIDIA, versus bounds 0.004 max/0.0005 mean.

--pixel --weather-scene --hardware --benchmark times sunlight fog; --pixel-local
--hardware --benchmark times the separate single-lamp cases and skips the CPU
reference at 2560x1440. Both print adapter identity. Idle RTX 5090 Ultra results:
native 0.0390 ms, sunlight pixel 0.986/1.047 ms; local-only unshadowed/shadowed
0.225/0.406 ms (surface behind light), 0.132/0.145 ms (surface in front). These
are RGBA32F synthetic draw timings, not real-scene or combined GPU timings.
Logs/captures: tmp/witcher3classic-investigation/fog-reconstruction-20261029.
Full Clang Release shader/addon build and package verification pass. After
restarting, the user confirmed the archway banding was completely gone and the
fog looked cleaner. This is live acceptance of the reported local-light issue;
it does not replace broader scene/performance checks.


### Darker Nights clock and native directional RGB (2026-10-29)

darker_nights.cpp exercises the actual game-local schedule and upload callback.
Compile with Clang C++20, /EHsc /O2 /DNOMINMAX, /Iexternal/Detours/src, and link
external/Detours/lib.X64/detours.lib. An optional executable path replays the
PE/instruction validation against a mapped image; no game process is modified.

The default 18:00/23:00/03:30/06:00 schedule is checked at all 1440 minutes.
Daytime and 100% must be exactly neutral; dawn/dusk half-fades have the expected
smoothstep value. Out-of-order, nonfinite and out-of-range hours are inactive;
equal adjacent endpoints support immediate transitions without division by
zero. Nonfinite/out-of-range native clock values must be neutral.

The fake original builder writes a full 53168-byte b13 buffer before the real
post-builder callback runs. Only c1/c51/c52 RGB may differ, with HDR values
above 1 and signed channels retained. Alpha, NaN payloads, directions and every
other byte (including local lights) are compared exactly. Repeating the native
build verifies that intensity does not compound. Disabling the controls must
restore the complete original buffer. The installed Classic executable passes
all six ABI guards; changing each guarded code region must reject it.

Full Clang Release link and verified packaging pass. After restart, the user
confirmed moonlight responds correctly and the displayed game time matches
native game time, following the requested surface/fog-versus-torch comparison.
Live dawn/dusk, master Off and preset persistence remain broader manual checks.
Fixtures, native RTTI/disassembly/decompilation and build logs are under
 tmp/witcher3classic-investigation/darker-nights-20261029.


### Night ambient/common upload and moon geometry (2026-10-29)

The extended darker_nights.cpp checks c183.xy/c184.xy probe gains, fog/haze/
sky RGB and moon tags at midnight, both half-fades and noon. Every unrelated
float, alpha, direct-light enable and density stays unchanged. Neutral controls
are byte-identical. Nested upload scopes must restore the parent; aligned CPU
shadow writes must leave the target untouched until Publish and publish once.
The actual CommonConstantsHook -> MapBufferHook -> fake original writer ->
UnmapBufferHook sequence checks all forwarded arguments and complete adjusted
bytes before original Unmap; neutral and unrelated mappings must pass through.
Six optional common/map/unmap instruction guards reject mutations without
invalidating the independently supported directional-light hook.

night_moon.cpp uses D3D11 WARP or hardware and the exact Release shader embeds.
Pass the native CSO dump directory as its first argument; a second argument
selects hardware. Compile with /Iexternal/Detours/src and link d3d11.lib,
dxgi.lib, external/Detours/lib.X64/detours.lib. The test also performs a real
WRITE_DISCARD upload, publishes its CPU shadow, copies to staging and compares
all HDR/alpha/tag bytes. Both moon VS/PS pairs replay native versus production:
neutral error 0, peaks4.83898/4.6188, brightness0/100/200 and 50% diameter's
quarter area pass on WARP/NVIDIA. Existing volume regressions still pass.

Startup review must include explicit Classic custom_shaders table entries,
not only successful embeds: the missing three new entries caused a launch
exception despite shader tests passing. Both moon pairs are now registered.
The API-event upload attempt passed standalone tests but blacked out the live
view, so publication now surrounds the native helper's final pointer instead.
The user confirmed the corrected engine route and all new controls work correctly. No new
player-fill control was retained; the existing Graphics implementation matches
the preceding accepted source.


### Cloud/star brightness GPU regression (2026-10-29)

`night_sky.cpp <capture-directory> <original-cso-directory> [--hardware]`
replays the production 22D1E925, 6F0FF708, BC930752 and F12E637D shaders against
native DXBC. Capture-directory fixtures are cloud1/cloud2/stars-cbN.bin from
DevKit. The harness keeps captured weather/material constants, sets explicit
HDR cloud colors and uses deterministic textures and matching VS signatures.
Checks cover neutral equivalence, independent 0/100/200% gains, unchanged alpha
and linear brightness relative to the retained atmospheric baseline. WARP and
NVIDIA pass, with maximum neutral error 4.77e-7 and cloud peak 35.07.
`darker_nights.cpp` additionally tests independent gains and night fades in the
common upload, byte preservation outside c184.w and rejection of a modified
native zero-store instruction.

Manual: with Darker Nights enabled at night, compare each slider at 0/100/200%,
leaving the other at 100%. Check cloud coverage, stars, the moon and native sky
brightness independently; verify Off restores the original scene.


### Cloud/sky registration and downstream lighting (2026-10-29)

night_bindings.cpp includes the production addon.cpp registration table.
Build with the Classic Release include/library paths, D3DCompiler and the
normal addon libraries. Run without arguments for WARP, or --hardware.
For both 6F0FF708 and F12E637D, test master Off/On and gains 0/50/100/200%.
Apply the shader module's default/explicit injection decision, then execute
a GPU draw consuming native b13 in both vertex and pixel stages. Check the
original buffer identities and exact HDR RGB=(2,4,8), alpha=1. Both devices
pass. Missing on_inject callbacks would take the default all-graphics
injection path and fail native binding preservation.

The live failure capture showed F872850A vertex b13 bound to the 160-byte
RenoDX settings payload although its original DXBC requires 3323 float4s.
This is separate from cloud brightness arithmetic and cannot be detected
by replaying only the cloud pixel shader. The two new entries now explicitly
return false from on_inject, matching their native-b12-only shader inputs.


### Native sky haze control (2026-10-29)

darker_nights.cpp tests RGB-only c194 scaling, native alpha/profile preservation,
night transitions and native Map/Unmap routing when sky haze is the only active
adjustment. night_sky.cpp also uses a live haze-cb12.bin weather capture: the
remaining c194 contribution is present after the other sky/fog RGB colors were
zeroed. Replay BC930752 and F12E637D at 0/100/200% and compare production
output with original DXBC consuming the same adjusted native constants.
Check unchanged alpha and linear gain relative to untouched sky contributions;
repeat with 4096x source haze RGB to exercise HDR. WARP and NVIDIA pass.

Manual: at night, lower Sky Haze Brightness independently of Sky Brightness,
Distance Haze Brightness, Cloud Brightness and Star Brightness. Check the
remaining height/horizon glow, unchanged density/coverage and master Off.


### Standalone refractive rain (2026-10-29)

rain.cpp <fixture-directory> [--hardware] uses the current captured cb0/cb1/cb2/
cb4/cb12/cb13.bin constants, native PS105478E1 from the game dump and archived
BlitzFX 1F3A90A1 DXBC. It executes the production embedded shader and real
rain::Pipeline on D3D11. Checks cover native Off RGB/alpha, equivalence to
native-pass then BlitzFX-pass premultiplied composition, five active/pool
sizes with poisoned unused edges, zero/partial/full coverage, signed HDR,
non-rain rejection, sampler/SRV restoration and untouched VS/PS b13. WARP
and NVIDIA pass. Signature tests use synthetic CRC-patched buffers to exercise
both recorded rain atlas signatures, padded rows and rejection of another
particle upload, without redistributing game textures.

Manual: restart in the captured rainy scene; toggle Graphics / Rain /
Refractive Rain Off/On under DLAA and a reduced DLSS mode. Check falling rain
and nearby splashes against bright/dark HDR background, depth/fog fades and
unchanged other particles. Repeat after resize. The first accepted draw logs
that native HDR scene reuse is active, with no extra draw/copy.


Manual preset-button check (2026-10-29): with an active RenoDX profile, change
several Darker Nights sliders and schedule times, then click Darker. Verify
moonlight 5%, moon brightness/size 50%, the four ambient and five atmosphere
brightness controls 35%, stars 100%, master On, schedule 18/23/3.5/6. Click
Vanilla and verify master Off, native 100% sliders and default schedule.
Other tabs must retain their values. Restart and confirm the selected profile
retains the applied values. Buttons are disabled with the overall preset Off.
Validation for this UI-only change: the Classic Release addon object builds.


### Regional normalization / standalone exposure (2026-10-29)

night_exposure.cpp independently integrates native continuous-time adaptation
at 30/60/120/240 FPS, validates separate stop-space brightening/darkening limits,
fixed and blended metering, native identity, endpoints and rejected inputs:
4682 cases. night_normalization.cpp uses simulated Classic game/system/map
objects to check all six regions, Velen alias, special worlds, disabled states,
wrong system type and torn-down objects; 810 weather/HDR ratio cases. No weather
state enters regional gain selection. darker_nights.cpp also loads the real
Steam executable image and rejects mutations of the optional exposure/region
ABI fingerprints independently of the core moonlight ABI.

night_sky.cpp additionally checks 3/4/8x normalized cloud gains against the
native fog baseline and linear HDR result, preserving alpha. night_bindings.cpp
covers normalization Off/On at neutral and changed cloud/star sliders using the
real registration callbacks; native VS/PS b13 and downstream HDR stay intact.
Both GPU tests pass on WARP and NVIDIA. Build the Classic Release target and
repeat the manual checks listed in the regional normalization README section.

Toussaint sky coverage: night_sky.cpp replays C6178ADC/F4B551EC cloud shaders and the F12E637D background glow against original DXBC, including zero/native/2x gains, normalized cloud gains to 8x, HDR, alpha and an all-zero sky test. Use separate height-haze-cb12.bin and Toussaint haze-cb12.bin fixtures. night_bindings.cpp checks all four native-b13 sky/cloud registrations.

Night water: darker_nights.cpp checks isolated gain transport and time fades; water.cpp/water_test.hlsl check 0/50/100/200% ambient scattering and foam with independent direct lighting/refraction, unchanged reflection weight and fog-once composition on WARP/NVIDIA. night_bindings.cpp verifies activation with native water and fog.

presets.cpp includes the real addon settings and applies all four explicit preset tables after poisoning reset defaults. It checks complete setting coverage, slider bounds, Darker startup/reset values, tab isolation, Vanilla/Off exposure bypass and Presets-section placement after the profile slider.


## Opaque per-pixel fog cache

Build fog_composite.cpp with /Ibuild/thewitcher3classic.include after the Classic Release shader/object target. Run with the existing native-fog fixture directory and --cache, then --cache --hardware. The production 0xF3C30003 compute shader and 0xC8C78997 composite cover full-resolution HDR, odd active dimensions in pooled depth, thin/lit foreground, sky, missing/stale fallback, forward isolation and private-state restoration. Half-resolution fixtures and dispatch tests were removed with that implementation. Run --pixel-local and --weather --pixel / --weather-color --pixel separately for scalar transport and captured weather comparisons.

Exposure tests cover Smoothed defaults35/5/100/100 and native/custom/logarithmic limits, including100% default maximum brightening. Preset coverage verifies default Fog Detail2/4, removed fog controls, method-specific visibility and exposure preset isolation. Gameplay validation remains necessary.

## Shared player-fill producer

player_fill.cpp checks live-count bounds and stale records, every-byte RGB-only changes, high-bit shape/shadow variants, world-light identity, HDR gains, receiver normalization including zero weather gain, repeated fresh native builds, all ten ABI arguments and daytime CommonUpload. Compile with assertions enabled, /Iexternal/Detours/include and user32.lib. An optional Classic witcher3.exe argument validates the actual PE/code anchors and rejection of modified instructions.

player_fill_gpu.cpp intentionally runs original uncovered F1FB6FB1.ps_5_0.cso without a replacement. Pass the captured native skin-constant directory (skin-b1/b2/b3/b4/b12/b13.bin) and original game dump directory, then repeat with --hardware. The fixture uses a valid reoriented detail normal, tiled raw indices and HDR incident light, and checks native identity, 20%/50%/100% scaling, world-light/alpha preservation, matching across native receiver branches and additional spot flags. It fails if the native skin result stays unscaled or loses HDR. Scratch capture used: object-lighting-20261026. No runtime readbacks or fixtures ship in the package.

lighting.cpp applies the same CPU producer to its captured constants before GPU replay. It also compares reordered light indices 1/7/31/255 against native bytecode. object_motion.cpp's G-buffer sweep now checks all reflected native varyings as well as bit-identical clip positions under changing camera, bone and instance transforms.


## Underwater optics

water.cpp/water_test.hlsl cover Fresnel/TIR, phase normalization and direction,
RGB two-leg transport against numerical quadrature, vacuum and HDR.
underwater.cpp executes the production GPU runtime and embedded shaders. Pass
the original 0x128133E9.ps_5_0.cso path, optionally --hardware. It validates
original fallback, light redistribution/flat-water unity, atlas tile isolation,
PS/CS restoration, stale input rejection, above-water indirect suppression,
nonzero lake elevations, complete HDR attenuation/scattering and air-fog bypass.
lighting.cpp also binds underwater state and verifies ambient/reflection identity
while direct sunlight changes. Compile assertions enabled and use
/Ibuild/thewitcher3classic.include after the Release object/shader build.
Add --benchmark after --hardware for timestamp-query caustic preparation and
3840x2160 native/custom composite measurements. Synthetic coherent inputs are
not a substitute for gameplay timing, shadow/waterline checks or visual approval.

Underwater revision: underwater.cpp now exercises pixel-integrated adaptive
photon footprints under folded waves and subpixel phase motion, authored water
optical coefficients and native brightness gain. lighting.cpp checks incoming
ambient attenuation against independent angular integration. presets.cpp guards
the integer Sunlight Detail format. --hardware --scene <fixture-directory>
replays revision-waves.bin and revision-cb0/4/5/12.bin, exporting the atlas;
terrain/region arrays remain synthetic. Geometry occlusion, forward-material
coverage, motion quality and final scene appearance still require gameplay.

underwater_forward.cpp takes the native fixture directory containing
skin-forward-cb1/2/3/4/12/13.bin, then the original shader dump directory, and
optionally --hardware. It compares original 20C1C070 DXBC with the native-signature
F3C40011 variant, then verifies incoming underwater skin attenuation and exact
restoration without motion vectors. lighting.cpp covers submerged transparent
hair and alpha identity. underwater.cpp additionally asserts that sampler s12
remains the native comparison sampler while bound, zero density returns clear
HDR, and submerged CSM blockers cannot cast false air-path shafts while actual
above-water blockers still do at low/default/high Sunlight Detail.

Underwater waterline regression: underwater.cpp sweeps shallow camera depths
through the former native-rendering handoff, checks fractional mask coverage
against independent transport, excludes the air segment for surface entry, and
preserves above-water receiver RGBA. Live wave/meniscus continuity is still a
visual acceptance check; the transport boundary uses a regional mean plane.

Above-water consistency: water.cpp binds prepared optics and verifies shared
coefficients, zero/half/full density, two-leg scatter integration and unchanged
Fresnel/air-fog composition against independent equations. underwater.cpp uses
underwater_receivers.hlsl with the production capture/preparation/bind path to
check caustics above water, dry land and below-terrain rejection, and analytic
receiver sunlight attenuation. Missing/other water regions are conservative
fallbacks; geometry exclusions and live shoreline continuity need gameplay.

water_camera.cpp: compile with /std:c++20 /DNOMINMAX and
/Ibuild/thewitcher3classic.include; link d3d11.lib d3dcompiler.lib dxgi.lib user32.lib.
No arguments runs WARP; --hardware runs NVIDIA. A second argument enables isolated
4K GPU timestamps. Tests full-screen blur/CA (including centre), unchanged green
coordinates, unchanged HDR color, black, alpha, pooled borders, underwater
fade/zero controls and binding restoration. frame_generation_distortion.cpp now
checks the original CA-only map: underwater radial distortion was removed.
underwater.cpp checks physical water regressions and immersion/scattering state.
Live FG/HDR swimming and waterline acceptance is required after restart.

Underwater shadow regression: underwater.cpp tests a thin above-water blocker
against 16,384-step double-precision volume integration at detail 1/2/4. Optional
arguments after the native shader path are --hardware --compare-shadow <old.cso>
for a numerical old/new comparison, or --hardware --benchmark <old.cso> for
isolated 4K timestamps. Old bytecode belongs in scratch, never the mod source.
Keep the existing below-interface blocker and waterline checks: native air CSMs
must not be reused as refracted underwater shadow maps. Live dock/panning tests
are required to assess residual sampling noise and motion stability.
