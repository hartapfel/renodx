# Mod validation

## Post-process root layout and packed tone mapper

The native bloom root UAV needs two DWORDs. `root_layout.cpp` reproduces the
captured main layout (ten root CBVs and thirteen descriptor tables), verifying
that the 29-DWORD settings payload fits exactly at 64 DWORDs. It checks rejection
of oversized/incompatible layouts and initialization with our own bindings.
The production selector retains its saved/UI values 0/1; 4,608 writes verify
that it preserves all neighboring mode and contrast fields.
`prepare_layout.py` extracts the actual predicate and setting instead of
maintaining a duplicate implementation.

```powershell
python src/games/thewitcher3remastered/tests/prepare_layout.py tmp/witcher-layout
clang-cl /std:c++20 /EHsc /O2 /MT /DNOMINMAX /DWIN32=1 /Iexternal/reshade /Itmp/witcher-layout src/games/thewitcher3remastered/tests/root_layout.cpp /Fe:tmp/witcher-layout/check.exe /Fo:tmp/witcher-layout/check.obj
./tmp/witcher-layout/check.exe
```

`output_composition.cpp` also accepts `legacy-injection`: before shaders receive
the former 30-DWORD payload, while after shaders receive the packed payload.
All 324 configurations / 663,552 normal/FG output pixels match exactly.
After rebuilding, the user confirmed PsychoV and its controls function again.

## Addon callback cleanup

`addon_runtime.cpp` loads the real Release DLL in a minimal ReShade host. It
checks that saved lighting/CPU/motion/AutoHDR settings are ignored, descriptor heap and
motion/movie binding events are absent, the shared HDR shader and native bloom buffer reset
callbacks remain, HDR events register, and detach removes all callbacks.
No game or GPU callbacks are invoked.

From an x64 Visual Studio developer shell at the repository root:

```powershell
clang-cl /std:c++20 /EHsc /O2 /MT /DNDEBUG /DNOMINMAX /DWIN32=1 /Iexternal/reshade src/games/thewitcher3remastered/tests/addon_runtime.cpp /Fe:tmp/addon-runtime.exe /Fo:tmp/addon-runtime.obj
./tmp/addon-runtime.exe ./build/Release/renodx-thewitcher3remastered.addon64
```

See `../CPU_PERFORMANCE.md` for the profiling findings and runtime checks.

## Native scene/UI output composition

`prepare_output.py` adapts the actual normal/FG pixel entry points to CS5.0 for
D3D11 WARP, changing register spaces and entry-point plumbing only. An optional
second argument selects a separate source checkout for before/after checks.
`output_composition.cpp` accepts four compiled shaders: before normal, before
FG, after normal and after FG. It binds a transparent texture at the former
movie slot, matching gameplay and native movie/UI composition.

The cleanup regression checks 324 configurations across Vanilla/PsychoV,
peak/game/UI brightness, gamut target, grayscale/colour scene ramps and UI
opacity. All 663,552 output pixels match exactly; primary/secondary parity and
the native FG coverage mask also pass. These checks do not verify game resource
lifetimes, native decoder playback or hardware frame time.

```powershell
python src/games/thewitcher3remastered/tests/prepare_output.py tmp/output-after
python src/games/thewitcher3remastered/tests/prepare_output.py tmp/output-before <before-source-folder>
foreach ($stage in 'before', 'after') {
  foreach ($id in '8F5737B5', '496222DA') {
    bin/fxc.exe /nologo /T cs_5_0 /E main /Ges /WX /O3 /Fo "tmp/$stage-$id.cso" "tmp/output-$stage/output/0x$id.ps_6_6.hlsl"
    if ($LASTEXITCODE) { throw 'Output compilation failed' }
  }
}
clang-cl /std:c++20 /EHsc /O2 /MT src/games/thewitcher3remastered/tests/output_composition.cpp /Fe:tmp/output-composition.exe /Fo:tmp/output-composition.obj /link d3d11.lib
./tmp/output-composition.exe tmp/before-8F5737B5.cso tmp/before-496222DA.cso tmp/after-8F5737B5.cso tmp/after-496222DA.cso
```

Night lighting, camera lights and selective saturation are owned and tested by
[Darker Nights](../../thewitcher3remastered-darkernights/tests/README.md). The HDR addon reads
none of their settings and installs none of their native hooks.

## Unclamped LUTs, day/night grading and PsychoV

`prepare_gamut.py` adapts all three actual LUT consumers and five post-grade
variants to CS5.0. Its second argument is a snapshot of the mod before the
change. `gamut.cpp` executes those before/after shaders through D3D11 WARP:

```powershell
python src/games/thewitcher3remastered/tests/prepare_gamut.py tmp/gamut-check <before-source-folder>
clang-cl /std:c++20 /EHsc /O2 /MT src/games/thewitcher3remastered/tests/gamut.cpp /Fe:tmp/gamut-check/gamut.exe /Fo:tmp/gamut-check/gamut.obj /link d3d11.lib
./tmp/gamut-check/gamut.exe tmp/gamut-check
```

The October 6 unclamping checks pass 4,098 configurations: exact Vanilla
and nonnegative-source PsychoV parity; zero/half/full grade contribution;
finite identity, lifted, constant, tinted and signed LUTs; signed wide-gamut
output through every LUT variant; independent vignette darkening; reversible
HDR proxy identity (maximum normalized error 6.34e-7); BT.2020 colours outside
BT.709 surviving PsychoV; zero/half/full gamut projection; and full selected
gamut/peak containment across both targets, hue shift, cone exponent, anchors,
automatic/manual compression and global saturation.
PsychoV works in signed linear BT.709 coordinates, which does not limit its
colour gamut to BT.709. The bounded LUT proxy is reversed before tonemapping.

The same scratch folder records actual normal/FG wide-colour output testing
(324 configurations / 663,552 pixels), neutral scene/UI comparisons (maximum
PQ-domain error 8.23e-6). Vanilla, opaque UI, normal/FG parity
and FG coverage remain unchanged.

The HDR/lighting split was checked with both Release DLLs and both load orders,
using this HDR addon and the installed third-party HDR addon. Standalone grading
pass routing, native lighting, saved presets and teardown/reload all pass. The
HDR output comparison matches the pre-split version exactly across 324 normal/FG
cases and 972 FSR cases; 972 HDR-saturation bypass cases and 162 Photo Mode cases
also pass. The 22 HDR shader replacements and both Release targets build.
These checks use synthetic inputs, not every game-authored LUT/environment.

Evidence and the pre-change snapshot:
`tmp/thewitcher3remastered/gamut-unclamped-20261006/`.
After restarting, compare daytime and night scenes, candle highlights and
foliage at each display target and gamut strength 0/0.5/1. Check LUT/environment
transitions, night luminance/chroma controls, UI and frame generation.
Projection Off still has the final HDR10 container's nonnegative/peak limits.

## Continuous signed cone response

The same gamut harness now checks triplets on either side of all three LMS
zero planes across 17 intensity levels. Use the pre-fix mod snapshot at
`tmp/thewitcher3remastered/gamut-unclamped-20261006/output-after` as the
baseline with the commands above. An additional 270 configurations cover
BT.709/BT.2020, projection 0/0.5/1, Hue Shift 0/50/100, cone exponents
0.5/0.8/1/1.2/2 and automatic/manual response compression. The maximum step
for a 1e-6 cone perturbation is 0.000311 of display peak, within the 0.001
bound; black, finite signed output and full-target containment also pass.
The existing 4,098 configurations pass, with exact positive-source parity.

The saved paused candle input and native compositor constants were replayed
through the production output shader with film grain disabled. The previous
curve reproduces the internal pink bands; the continuous response smooths
them at cone exponent 1.0 and Hue Shift 0/100. Scratch captures and the
comparison image are under `tmp/thewitcher3remastered/candles-20261006/`.
This is offline shader validation; the rebuilt addon still needs a restart
and visual confirmation in the same cutscene. All 32 production shaders
compile with strict DXC flags and the Release addon callback test passes.

## BT.709 video conversion only

`video.cpp` is restored from fcb3cbc9 and checks only the decoder shader.
The production shader compiles strictly as ps_5_1 and as ps_5_0 for WARP.
Using the archived native-equivalent SM5.0 bytecode and audited baseline,
589,824 pixels pass including code-range sweeps, limited-range black/white,
BT.709 colour bars and opacity 0/0.37/1. Maximum BT.709 reference error is
3.36e-7. Reflection shows only native t0-t2 and s0-s2, with no cbuffer.
The Release build embeds 0x7EF4001F and its callback test still verifies
absent movie/descriptor tracking. After restart, test the Video toggle on
intro/loading movies, subtitles, fades and Frame Generation; native movie
composition is retained and no AutoHDR expansion is applied.


## Photo Mode and native HDR saturation

`photomode.cpp` executes the original decompiled Photo Mode shader and the
production `0x6DDA5B7B` through WARP compute wrappers. The wrappers only change
register spaces/entry-point plumbing. It checks 162 exposure, contrast,
saturation, temperature and night-grade combinations, Vanilla preservation,
finite signed HDR, exact source alpha and linear exposure scaling. Compile the host with clang-cl /std:c++20 /EHsc
/O2 /MT and link d3d11.lib; pass the original/production CS5.0 bytecode paths.

`output_composition.cpp` accepts an optional fifth argument `hdr-saturation`.
It sweeps 0/0.5/1 with the display matrix captured from the game across 972
configurations / 1,990,656 output pixels. Custom normal/FG scene and UI outputs
are invariant; Vanilla matches the previous output, normal/FG composition
agrees, and the FG UI coverage remains unchanged. Before/after differences
under active native saturation are intentional. Existing invocation without
that argument retains the neutral parity test.

Live Photo Mode inspection confirmed unclamped grading and visible scene/UI.
After a Release rebuild, verify the Photo Mode filter/exposure/vignette controls,
native HDR Saturation independence, and gameplay with FG on/off.


## FSR Frame Generation output

`prepare_output.py` also adapts the three-target `0x9F54CB3F` compositor and
its shared include. `output_composition.cpp` accepts `fsr` to compare all
three FSR outputs against `0x496222DA`, while ignoring the absent fourth
UI-alpha target. It passes 972 configurations, including signed wide-gamut
inputs, UI opacity/white, Vanilla/PsychoV, both gamut targets, native HDR
saturation and display peaks. `fsr-native` limits the comparison to Vanilla;
486 configurations match the original decompiled shaders exactly. The
existing normal/four-target output regression passes 324 configurations with
zero difference after sharing the implementation. Both production variants
compile strictly as ps_6_6 with their correct output signatures.

Evidence: `tmp/thewitcher3remastered/fsr-20261007/`. After restarting with the
Release addon, compare the same scene with FSR Frame Generation off/on:
highlight detail and peak, white pixelation, UI and native
HDR Saturation independence. Also check DLSS Frame Generation and Vanilla.
