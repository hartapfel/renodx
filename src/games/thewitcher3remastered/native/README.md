# Archived native HLSL

These fifteen files are unmodified decompiler output from the original dumped DXIL, regenerated after repairing the repository decompiler. `.hlsl.original` prevents the recursive game shader build and live loader from treating archived baselines as active replacements. Copy a file into a separate scratch/live directory and remove only `.original` to reuse it.

`manifest.json` records each original CSO SHA-256 and the exact generated HLSL SHA-256. The original eight binary copies were byte-length/SHA-256 checked against the game dump; the two candle-scene variants were dumped directly from DevKit and hashed before decompilation. They remain in `tmp/thewitcher3remastered/original`; do not copy CSOs into the game source/live folder.

Archives are grouped into `tonemappers/`, `luts/`, `postprocess/`, `effects/`, and `output/`, matching the active shader folders. `blur/` contains the supporting `0x29754CAF` and `0x4B0ABFCA` baselines, which have no active replacements. Each manifest entry's `path` is relative to this directory. Moving the archives preserved their exact bytes and hashes.

## Validation

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
