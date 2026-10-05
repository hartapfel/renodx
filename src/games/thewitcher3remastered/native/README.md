# Archived native HLSL

These twenty-two files are unmodified decompiler output from the original dumped DXIL, regenerated after repairing the repository decompiler. `.hlsl.original` prevents the recursive game shader build and live loader from treating archived baselines as active replacements. Copy a file into a separate scratch/live directory and remove only `.original` to reuse it.

`manifest.json` records each original CSO SHA-256 and the exact generated HLSL SHA-256. The original eight binary copies were byte-length/SHA-256 checked against the game dump; the two candle-scene variants were dumped directly from DevKit and hashed before decompilation. They remain in `tmp/thewitcher3remastered/original`; do not copy CSOs into the game source/live folder.

Archives are grouped into `tonemappers/`, `luts/`, `postprocess/`, `effects/`, and `output/`, matching the active shader folders. `blur/` contains the supporting `0x29754CAF` and `0x4B0ABFCA` baselines, with only the resolve (`0x4B0ABFCA`) replaced in `../effects/`; preparation stays native. Each manifest entry's `path` is relative to this directory. Moving the archives preserved their exact bytes and hashes.

## Validation

The second cutscene post-grade baseline `0x9600E32A` contains native CA and no vignette. Its original and recompiled resource/signature contracts and intrinsic counts match, with exact differential agreement over 360 cases covering all three blocks. The forced-Vanilla replacement passes the same checks. Evidence: `tmp/thewitcher3remastered/cutscene-oct01/`.

The spatial tint/highlight composite `0xDFD5C392` was captured in the dim interior scene. Its unmodified baseline passes strict compilation, signature/resource/buffer-size and intrinsic-count checks, and 360 differential cases with exact agreement. The original contains an unconditional 1.1 RGB ceiling. Original CSO and validation evidence are in `tmp/thewitcher3remastered/original/` and `dim-scene/`.

The cutscene post-grade baseline `0xF961D049` was dumped directly from the live capture and decompiled with the standalone tool. Strict compilation, input/output signatures, bindings, 400-byte buffer extent, and intrinsic counts pass; 360 differential cases match exactly. No unresolved artifacts remain. The replacement's forced-Vanilla executable instructions equal the audited baseline. Original binary, disassemblies, and audit evidence remain under `tmp/thewitcher3remastered/cutscene/` and `original/`.

Every archived file passed:

```powershell
bin/dxc.exe -T ps_6_6 -E main -HV 2021 -Ges -WX -Fo <scratch-output.cso> <archived-file.hlsl.original>
```

- Input/output signature tables, resource binding tables, and buffer extents match. The shared native buffer remains 5456 bytes, including when only a few members are used.
- No unresolved `TODO`, `FIXME`, `unsupported`, `unknown`, `undef` or `goto` artifacts remain.
- Texture sample/load counts and output-store counts match. All DXIL intrinsic counts match except extra cbuffer loads in `382CDBDB` (6 -> 9), `724E225F` (13 -> 17), and `8F5737B5` (20 -> 24), caused by reconstructed HLSL scopes. Their register accesses retain native offsets.
- Those three shaders each lose three redundant branch trampolines during compilation. Arithmetic also folds negative multiplies/adds into subtraction. Native Hable/AgX/bypass selection, AgX response branches, final luminance expansion, and both output paths remain in the baselines.
- A scratch DXIL interpreter compared 360 synthetic inputs per shader against the original binary's disassembly. Results agree within the configured tolerance (largest scaled absolute error below 7e-6). The fixtures include selectors, alternative AgX response, LUT strengths, overlay opacity, regional masks and display adjustment. Some deliberately arbitrary native constant combinations produce nonfinite results in both versions; this is not a finite-output certification for arbitrary constants. All main-tone-map blocks were visited; some output and blur blocks remain uncovered.

Scratch evidence: `baseline-contracts.json`, `baseline-differential.json`, `vanilla-differential.json`, `audit_baselines.py`, and `decompiler-fixes.diff` under `tmp/thewitcher3remastered`. These tests supplement structural review; live original-versus-baseline comparison is still required.

## Decompiler repairs

`src/utils/shader_decompiler_dxc.hpp` now recovers opaque typed resources from `annotateHandle` properties, emits sampler types from metadata, accepts metadata after a switch closing bracket, and preserves sparse cbuffer extents. Debug level remains zero. No generated HLSL was hand-patched to conceal a lowering failure.

The separate supporting compute shader `0x3650C210` still reports `Unexpected goto` in the standalone decompiler, so no generated native HLSL baseline is claimed for it. Its original CSO and disassembly remain preserved in scratch. Inspection shows it adds a scalar sharpening correction to RGB and preserves source alpha. The RCAS revision registers a deliberately new copy shader under that hash, selected only for PsychoV + Lilium RCAS; Native/Vanilla continues executing the original game binary. This is a custom effect bypass, not a repaired native decompile. It retains the original 128-thread/32x32 tile traversal, b0.c4.xy sample scale, sampler, RGBA center sampling and write coordinates. It omits only the native additive sharpening work and guards partial output tiles. The compute shader uses no injection; RCAS itself runs later in the existing pixel post-process paths.

The candle-scene variants `0x90AD6BBC` and `0x16967617` needed no additional decompiler repair. Their signatures, interpolation, bindings, 400-byte cbuffer extents and all intrinsic counts match. Both native baselines and forced-Vanilla replacements give exact agreement across 360 synthetic cases each. Scratch evidence: `candles-baseline-audit.json`, `candles-baseline-differential.json`, `candles-vanilla-differential.json`. Native and baseline live captures remain subject to temporal variation.

The bloom/flare revision adds unchanged native archives for `0x7DC213EE` (additive bloom composite) and `0xC5AB358E` (post grade with a sampled vignette). Both standalone decompiles contain no unresolved artifacts and pass strict compilation, signature/resource/400-byte extent audits, identical intrinsic counts, and 360-case differential execution with exact agreement. The edited forced-Vanilla shaders retain those native executable instructions; the manifest records original CSO and archived HLSL hashes. Evidence is under `tmp/thewitcher3remastered/bloom-flare/`. The archive now contains twelve baselines.

The frame-generation capture adds `0x0F6A9050` (independently graded LUT pair) and `0x496222DA` (four-output HDR compositor), bringing the archive to fourteen baselines. Both standalone decompiles pass strict compilation and signature/resource/buffer-extent audits without unresolved artifacts. The LUT intrinsic counts match; the compositor has 32 cbuffer loads versus 21 in the original due to reconstructed scopes. Native baselines and forced-Vanilla replacements each pass 360 differential cases against the original binaries, with largest scaled error below 7e-6. The compositor fixtures visit 154 of 225 original blocks, so this is not exhaustive branch coverage. Evidence: `tmp/thewitcher3remastered/framegen/baseline-audit.json` and `vanilla-audit.json`.

The light-shaft input `0x1132ADF9` and bloom-only composite `0x5E320F6F` were added with the native effect controls. Both pass strict compilation, matching input/output/resource contracts and DXIL intrinsic counts; their default/Vanilla paths match original DXIL over 360 cases each. Existing DOF and bloom+dirt baselines are reused unchanged. Evidence: `tmp/thewitcher3remastered/effect-controls/`.


The three `motionblur/` archives are unchanged cs_6_6 decompiler output. All pass
strict cs_6_6 compilation, matching input/output/binding/resource-property checks,
116-byte b0 extent, NumThreads (8x8 / 8x8 / 16x16), and exact intrinsic counts.
The final resolve (`0x866E78BC`) additionally matches original DXIL exactly over
600 differential cases covering all seven blocks. The preparation/filter stages
were structurally audited, including the filter loop and WaveActiveMax; no GPU
differential or live baseline-equivalence result is claimed for them. Only the
final resolve receives an enhanced replacement; Native still runs original DXIL.
Evidence: `tmp/thewitcher3remastered/motion-blur/baseline-audit.json`.


## SM5.1 video baseline

`video/0x7EF4001F.ps_5_1.hlsl.original` is unmodified cmd_Decompiler output.
The original is DXBC, not DXIL. cmd_Decompiler 1.3.16 cannot directly decode
its SM5.1 descriptor arrays. For this shader's three statically indexed space0
textures/samplers, the disassembly declarations were mechanically expanded to
SM5.0 registers, with the original signatures copied during assembly. No
executable operation or literal changed. That bytecode decompiled successfully;
the generated HLSL then passed strict ps_5_1 compilation. All 11 recompiled
executable instructions match the original after normalizing descriptor-range
IDs. D3D11 WARP also gives exact agreement over 196,608 pixels between the
transcoded native bytecode and compiled baseline. Original DXBC and conversion
artifacts remain in tmp/thewitcher3remastered/video/ and original/.


## Alternate night-cloud materials

`lighting/` preserves unchanged decompiler baselines for B7D286D5 and 683213A3,
with original binary and HLSL SHA-256 hashes in its manifest. Both pass strict
ps_6_6 compilation, preserved signatures/bindings, and 360 differential cases
each with finite, nontrivial output. B7D286D5 retains all intrinsic counts;
683213A3 has one additional cbuffer load from a repeated reconstructed read.
The production edits match the original with only the intended cloud input
scaled over 720 cases each (including neutral/daytime and missing-injection
guards). Scratch evidence: tmp/thewitcher3remastered/night/storm/.

The cloud/smoke extension adds unmodified pixel baselines 093DCC92 and CEE2035A.
Both strictly compile as ps_6_6 and retain all input/output signatures, resource
bindings and DXIL intrinsic counts. Each passes 360 original/baseline cases.
Edited shaders pass 720 cases each, including exact coverage preservation and
retained native lighting above the smoke floor. The complex paired vertex
shaders fail decompilation and are neither replaced nor archived as valid HLSL.
Evidence: tmp/thewitcher3remastered/night/volumes/.

95CC19A8 is the additional coverage-output variant of 093DCC92. Its unchanged
baseline passes strict ps_6_6 compilation, identical signatures/bindings/intrinsic
counts and 360 finite differential cases. Bypassing this shader removes the
reported chimney smoke. The production cloud and smoke variants share one
implementation and pass 720 cases each for complete material-radiance scaling
before fog, with both opacity outputs unchanged and neutral/daytime identity.
Evidence: tmp/thewitcher3remastered/night/volumes/recheck/.


E6A77B56.cs_6_6 adds the deferred Raster/RT lighting baseline. The original
CSO hash and unchanged generated HLSL hash are in lighting/manifest.json.
Its decompilation required nearest postdominator joins rather than partial
reachability, correct unsigned groupshared min/max destinations, raw CB
aliases and byte-address buffer stores. The old do/while fallback compiled
but failed differential execution; it is not used. The corrected baseline
passes strict cs_6_6 and 360 synthetic comparisons. Thread dimensions,
resource bindings/buffer sizes, groupshared storage and three barriers
remain native. Structured control flow duplicates some mutually exclusive
lighting tails; 2880 edited comparisons cover only the intended ambient
scaling, with neutral/invalid-tag identity and unchanged light-list writes.
These are single-lane checks, not complete GPU execution coverage.
Evidence: tmp/thewitcher3remastered/night/raster/residual/.


8DBF022F.ps_6_6 and EAAAC84D.ps_6_6 archive the forward-material baselines.
Both preserve every binding and signature, including EAAAC84D's five MRTs.
The first retains sample/load/store counts. EAAAC84D folds two identical t17
loads into one; reconstructed shadow branches duplicate mutually exclusive
samples (26 sampleLevel operations become 78). 160 synthetic native/baseline
cases per shader agree exactly, including a point-light case family; this
does not cover every shadow permutation. Each edited shader passes 1280
comparisons for ambient-only scaling and identity for untagged/invalid data.
Evidence: tmp/thewitcher3remastered/night/raster/residual/forward-structural.json
and check-forward.py. The user rebuilt and confirmed the environment improvement; hair required
a separate transparent-material addition.


1C12BED7.cs_6_6 is the environment/sky fallback plus screen-space reflection
baseline. Opaque scalar structured-buffer resources required a decompiler
fix: read the annotated 4-byte element as uint bits instead of walking the
opaque handle's i8 pointer as a reflected member tree. The baseline preserves
both 4-byte structured buffers, all 16 resources and 8x8x1 threads. Control-flow
reconstruction duplicates two mutually exclusive refraction/material tails;
static sample/load/store counts increase accordingly. 180 baseline cases
match exactly; 1440 edited comparisons preserve full/partial scene-hit terms
while scaling only fallback radiance. These synthetic checks do not validate
all ray-march geometry or GPU temporal history.
Evidence: tmp/thewitcher3remastered/night/raster/residual/check-reflection.py
and reflection-structural.json. The user rebuilt and confirmed removal of the residual environment sheen
in the tested view.


1B63829B.ps_6_6 archives the user-identified transparent hair baseline.
Its opaque t20 resource requires RawBuffer metadata to emit ByteAddressBuffer;
inferring the type from a reflected pointer name incorrectly emitted a typed
buffer. The corrected decompiler preserves byte addressing. All 18 bindings,
cbuffer sizes, signatures and sample/load/output/discard counts agree with
native DXIL. 160 synthetic baseline cases match exactly; 1280 edited cases
check ambient-only scaling through tint/fog and 36 checks preserve alpha and
discard. This does not cover every shadow/material permutation or GPU behavior.
Evidence: tmp/thewitcher3remastered/night/raster/residual/check-transparent.py
and hair-search/structural.json. The user rebuilt and confirmed the hair correction and preserved torch
lighting in the tested Raster view. RT-specific coverage remains outstanding.

D2C88922.cs_6_6 and 02320E1A.cs_6_6 archive the RT GI-ray lighting and
reflection-ray lighting baselines captured on 2026-10-05. The original
bindings, CB sizes and thread dimensions survive strict recompilation.
360 synthetic baseline and 2880 sky/fill-only edited comparisons pass for
each shader, including sampled coordinates and unchanged lit scene hits.
Dynamic binding-range indices and overlapping raw/reflected CB declarations
required generic decompiler fixes; archived Raster baselines regenerate
identically with consistent flatten options. Evidence: night/rt/check-rt.py
and structural.json under tmp/thewitcher3remastered/. The user rebuilt and
confirmed the current all-zero night RT scene works perfectly.
