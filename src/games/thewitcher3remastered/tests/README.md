# Mod validation

## Addon callback cleanup

`addon_runtime.cpp` loads the real Release DLL in a minimal ReShade host. It
checks that saved CPU/motion/AutoHDR settings are ignored, descriptor heap and
motion/movie binding events are absent, the single shared HDR shader reset
callback remains, HDR events register, and detach removes all callbacks.
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

## Native night lighting

`night_lighting.cpp` exercises the native view and constant callbacks against
independent references of the audited renderer stores. Its 180 cases cover
raster/shared directional colors, fog, haze, sky, clouds and native water
color/ambient/diffuse constants across clock fade
endpoints and weather weights, including the captured storm's residual skylight.
It checks RGB-only edits, exact neutral/daytime identity, invalid time, weather
independence and skylight baseline restoration/rebasing. Zero skylight must reach
exactly zero at full night even when weather retains a nonzero day weight.
Two whole-buffer comparisons verify cloud isolation, untouched moon/star colors
and alpha, and midday identity. Water checks preserve all other global-buffer
bytes, including Fresnel/caustics/foam fields. Removed grass/moon controls have no runtime
backing state. The harness does not establish the live hook ABI, engine time
semantics, or broad scene coverage.

From an x64 Visual Studio developer shell:

```powershell
clang-cl /std:c++20 /EHsc /O2 /MT /DNOMINMAX /Iexternal/Detours/include src/games/thewitcher3remastered/tests/night_lighting.cpp /Fe:tmp/witcher-night-test.exe /Fo:tmp/witcher-night-test.obj /link external/Detours/lib.X64/detours.lib
./tmp/witcher-night-test.exe
```

Night Sky Brightness also covers b12 c249/c278, the two native colors added
by 3B15DAAB after its main sky/fog calculation. The night-lighting harness
includes them in the 180 clock/intensity/weather cases and checks whole-buffer
sky-only isolation at midnight and midday, preserving alpha, moon colors, fog
and cloud base colors. The shared c278 distant-cloud tint intentionally follows
the sky control. Runtime horizon verification remains necessary after rebuilding.

## Selective night vegetation saturation

The saved `NightSaturation` key now controls green/cyan scene hues, with
gentler yellow/blue shoulders. The shader multiplies global saturation by
`1 + night_saturation_delta * hue_weight`; the CPU delta is
`(night_saturation - 1) * night_weight`. The master/schedule/hook guards give
zero weight outside the selected hours, with the master Off, invalid times
or Vanilla. Defaults, both presets and Preset Off remain 100. UI composition
follows this scene-only operation; global saturation remains independent.
The neutral delta is zero and the C++/HLSL payload is 124 bytes (31 DWORDs).
Root-layout eligibility uses its actual size; no new binding tracker is added.

Hue selection uses OKLab from signed display-linear BT.709/D65. Its OKLCh
weights are 0 at 85 degrees, 0.35 at 110, 1 from 135 to 220, 0.35 at 250,
and 0 from 275 onward, with smoothstep transitions. Relative chroma C/L
fades the selection between 0.02 and 0.06 to avoid unstable neutral hues.
Saturation preserves linear display luminance and uses the existing soft
gamut headroom limit for increases, weighted by PsychoV’s selected gamut compression strength. This is colour selection, not a material
mask: matching water, clothing, sky and other objects can also respond.

Research: [CD Projekt's environment artist](https://80.lv/articles/world-building-of-witcher-3)
describes separate foliage libraries for Novigrad, Skellige and Toussaint;
there is no documented universal vegetation hue interval. Our saved HDR10
night capture was PQ-decoded in BT.2020 then converted to signed linear
BT.709 before measuring manually selected grass/fern regions. The 5th/50th/
95th OKLCh hue percentiles were 135/151/199 (left grass), 138/148/177 (right
grass) and 146/168/214 (ferns). These are scene-specific measurements, not
coverage proof for every biome/weather. Yellow/blue shoulders are deliberate
extensions for regional foliage and cooler night lighting.

Scratch evidence: `tmp/thewitcher3remastered/night-selective-saturation/`.
It includes ROI coordinates, EXR-domain analysis, CSV hue distributions,
graphs and actual production HLSL WARP harnesses. After restarting, compare
100/50/0 and 200 in the affected foliage scene; check warm lights, skin,
coloured UI, night fades, daylight, master Off and both display gamut targets.
Set Night Color Grading Chroma to 0 to verify independence. Live appearance
and other regions/weather require in-game verification.

Validation: all 32 CRC-addressed production shaders compile strictly and the
clang-x64-release/thewitcher3remastered build passes. Neutral output matches
the previous version exactly across 324 configurations / 663,552 pixels.
Active-slider normal/FG testing passes 1,296 configurations / 1,327,104 pixels
for luminance, UI, Vanilla, FG parity and coverage. Direct production-extension
hue sweeps pass 160 configurations / 163,840 pixels across BT.709/BT.2020,
HDR levels, global saturation and night strength. They verify finite in-gamut
output, luminance preservation, full green/cyan desaturation, weaker yellow/
blue coverage and warm/pink/neutral isolation. Maximum selection-weight slope
is 0.039 per measured OKLCh degree. The real Release DLL callback cleanup
test passes; these tests do not measure live frame time.

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
automatic/manual compression, global saturation and night vegetation saturation.
PsychoV works in signed linear BT.709 coordinates, which does not limit its
colour gamut to BT.709. The bounded LUT proxy is reversed before tonemapping.

The same scratch folder records actual normal/FG wide-colour output testing
(324 configurations / 663,552 pixels), neutral scene/UI comparisons (maximum
PQ-domain error 8.23e-6), and active night-saturation composition testing
(1,296 configurations / 1,327,104 pixels). Vanilla, opaque UI, normal/FG parity
and FG coverage remain unchanged. All 32 production shaders compile with
strict DXC flags; the Release build and real-addon callback test pass.
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
finite signed HDR, exact source alpha, linear exposure scaling and independent
chroma-only grading luminance. Compile the host with clang-cl /std:c++20 /EHsc
/O2 /MT and link d3d11.lib; pass the original/production CS5.0 bytecode paths.

`output_composition.cpp` accepts an optional fifth argument `hdr-saturation`.
It sweeps 0/0.5/1 with the display matrix captured from the game across 972
configurations / 1,990,656 output pixels. Custom normal/FG scene and UI outputs
are invariant; Vanilla matches the previous output, normal/FG composition
agrees, and the FG UI coverage remains unchanged. Before/after differences
under active native saturation are intentional. Existing invocation without
that argument retains the neutral parity test.

Live Photo Mode inspection confirmed unclamped grading and visible scene/UI.
After a Release rebuild, verify both night-grade controls and vegetation
saturation in Photo Mode, the Photo Mode filter/exposure/vignette controls,
native HDR Saturation independence, and gameplay with FG on/off.
