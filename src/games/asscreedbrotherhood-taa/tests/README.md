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
