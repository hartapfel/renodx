# Classic temporal reconstruction regression fixtures

Start with the [DLSS integration playbook](../../../../docs/DLSS_INTEGRATION_PLAYBOOK.md).
These fixtures exercise game-local CPU logic and actual D3D11 shaders. They do
not certify every game scene or replace live capture/visual acceptance.

## Prerequisites and build

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
```

## Inputs and execution

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

`temporal-dev/` abbreviates `tmp/witcher3classic-investigation/temporal-dev/`.
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
