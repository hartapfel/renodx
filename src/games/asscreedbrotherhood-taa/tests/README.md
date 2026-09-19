# Engine projection regression

`engine_projection.cpp` runs the production engine hooks against a small synthetic
camera/command stream. It needs Windows x86, the Windows SDK/DirectXMath headers,
Clang and the repository's existing x86 Detours library. It does not launch,
modify or attach to the game and can run while gameplay is open.

From an x86 Visual Studio developer command prompt at the repository root:

```bat
mkdir tmp\brotherhood-engine-test
clang-cl --target=i686-pc-windows-msvc /nologo /std:c++20 /EHsc /O2 /MT /UNDEBUG /Iexternal/Detours/include src/games/asscreedbrotherhood-taa/tests/engine_projection.cpp /Fetmp/brotherhood-engine-test/engine_projection.exe /Fotmp/brotherhood-engine-test/engine_projection.obj /link external/Detours/lib.X86/detours.lib
tmp\brotherhood-engine-test\engine_projection.exe
```

Keep assertions enabled (`/UNDEBUG`). The test checks projection source integrity,
clip z/w, x86 calling convention and 16-byte alignment, copied contexts, partial
uploads, queued older frames, Halton phase ownership, MSAA footprint, AA Off and
unknown-executable rejection. Its tiny executable call stub models the audited
projection caller; it contains no dumped game code. This is a CPU handoff test;
actual pass coverage and graphics resets also require the live checks in
[JITTER_AUDIT.md](../JITTER_AUDIT.md).

## DLAA synchronization and GPU handoff

The optional x64 `brotherhood-dlaa-handoff-test` target lives in the helper's
CMake project. Build the x86 addon first for its generated shader headers, then
build the matching helper and fixture from an x64 developer command prompt:

```bat
cmake --build build64-brotherhood-dx12 --config Release --target renodx-asscreedbrotherhood-dx12 brotherhood-dlaa-handoff-test brotherhood-unified-gpu-test
build64-brotherhood-dx12\Release\brotherhood-dlaa-handoff-test.exe
build64-brotherhood-dx12\Release\brotherhood-dlaa-handoff-test.exe build64-brotherhood-dx12/Release/renodx-asscreedbrotherhood-dx12.exe validation
build64-brotherhood-dx12\Release\brotherhood-unified-gpu-test.exe validation
```

Run from the repository root, with the game closed and the matching signed
Streamline runtime installed beside the helper. The handoff fixture accepts an
optional helper executable path; a second argument enables DX12 validation and
delayed-input/cancellation checks. Use a helper without third-party injection
for comparable timings, and preserve/restore any installed OptiScaler setup.

The handoff fixture creates native DX9Ex shared inputs and validates current-frame
output colors at 720p and 4K. Delayed requests must not read textures or acknowledge
completion before producer readiness. Cancellation must stop the worker before
resources are freed. Reported median/p95 times include DX9 input submission and
the DLAA return wait after warm-up, but exclude readback and presentation. They
are synthetic handoff costs, not whole-game performance numbers. No benchmark
instrumentation is enabled in the Release addon.

The unified fixture additionally covers HDR/SDR, DLAA + 3x FG, changing presets,
feature release, helper restarts and optional-DLAA failure. In gameplay, compare
TAA and DLAA at an unchanged camera position with FG Off and no manual cap, then
check DLAA + FG, Alt-Tab and a graphics reset. Verify image stability and recovery
alongside frame times; a higher counter alone does not prove correct ownership.

## Animated-geometry buffer ownership

From an x86 Visual Studio developer command prompt, with assertions enabled:

```bat
clang-cl --target=i686-pc-windows-msvc /nologo /std:c++20 /EHsc /O2 /MT /UNDEBUG src/games/asscreedbrotherhood-taa/tests/geometry_upload.cpp /Fetmp/geometry_upload.exe /Fotmp/geometry_upload.obj /link d3d9.lib user32.lib
tmp\geometry_upload.exe
```

This uses actual DX9Ex dynamic buffers. It checks that live current/previous
snapshots remain distinct, that 64 queued draws survive immediate DISCARD reuse
without a CPU completion wait, that the cache stays within 64 entries / 4 MiB,
and that releasing it permits reset. It does not load the game or its addons.

## Scene-camera acquisition

```bat
clang-cl --target=i686-pc-windows-msvc /nologo /std:c++20 /EHsc /O2 /MT /UNDEBUG src/games/asscreedbrotherhood-taa/tests/camera_acquisition.cpp /Fetmp/camera_acquisition.exe /Fotmp/camera_acquisition.obj
tmp\camera_acquisition.exe
```

This checks agreement between engine VP and material WVP/world, affine c8-c10
reconstruction with unrelated c11 data, large coordinates, negative/nonuniform
scale, and rejection of mismatched, singular or nonfinite matrices. It does not
prove draw selection. Live verification must include modern-day gameplay where
VS `0x4B000956` is absent, then an Animus transition and return. Check DLAA/FG
input acceptance and advancing frame IDs as well as the visible image.
