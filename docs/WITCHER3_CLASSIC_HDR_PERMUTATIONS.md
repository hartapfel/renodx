# Classic HDR permutation audit — 2026-10-23

## Current checkpoint

The missing weather-transition filmic path and related HDR permutations are
compiled into the Release addon. No DevKit live replacement was activated.
In-game verification after restarting is pending.

- Target/preset: `thewitcher3classic`, `clang-x64-release`.
- Artifact: `build/Release/renodx-thewitcher3classic.addon64`.
- Built: 2026-10-23 12:08:09 CEST; 4,060,160 bytes.
- SHA256: `7DFC920A660424F6E9EBF316976230EBCF780A896733F6E2C252C18B1DD4C449`.
- The existing game-folder symbolic link resolves to this artifact.
- No changes to DLSS, resource upgrade rules, hair, geometry, or material shaders.

## Two distinct failures observed

The initial scene used an uncovered final analytic grade, `0x9F48B203`, when
chromatic aberration was absent. Its original shader contained RGB `min(1)` and
`saturate` operations. Its output already had an RGBA16F clone, so another
resource upgrade was unnecessary. The exact preserved input contained RGB
maxima `(12.5, 9.875, 7)` and luminance up to `10.2255`; about 29.12% of pixels
had at least one channel above 1. This was real incoming HDR being passed through
an unmodified SDR grade.

The later paused boat scene caught a separate weather-transition shader,
`0xAE7D5FA8`, replacing the covered single-environment pass `0xB4953357`.
DevKit reported `hasAddonShader=false` / `source=Original`. Unlike a literal
SDR hard clip, this pass applies two bounded native filmic curves and blends
their results. That explains why some HDR range could remain while reflected
highlights looked subdued. Do not describe this as proof of a universal 200-nit
cap or a clamp inside the boat's material shader.

The boat scene was still rendering while paused. The attempted capture of
`0xB4953357` timed out because that shader was not active; targeting the actual
`0xAE7D5FA8` draw then captured both the scene and exposure inputs successfully.

## Exact boat evidence

Process at capture: `witcher3.exe` PID 9388; DevKit pipe
`renodx-devkit-mcp-9388`. The snapshot had 2,423 records. Relevant draws:

| Draw | Shader | Role |
|---|---|---|
| 2378 | `AE7D5FA8` | Uncovered two-environment exposure/filmic blend |
| 2379 | `56EB5ABA` | DoF preparation; t0 preserves the preceding filmic output |
| 2380 | `6ED58557` | DoF composite |
| 2397 | `620431CF` | Covered bloom composite |
| 2398 | `0CB5EA21` | Covered screen effects |
| 2399 | `27EF680B` | Covered packed LUT |
| 2400 | `201C53B4` | Native temporal pass / DLSS replacement point |
| 2402 | `649AF4FA` | Covered final grade with chromatic aberration |

Input/output of the weather pass are already R11G11B10F, in an output-sized
3840×2160 allocation with an active 2560×1440 viewport. Statistics over the
whole allocation include its cleared unused region. Measurements below come
from owned input copies made **before the selected draw**, not from reused
textures read later in the frame.

| Capture point | Maximum luminance | Pixels with any RGB > 1 |
|---|---:|---:|
| Before weather filmic pass | 83.5232 | 1,890,160 |
| Before the following DoF preparation | 1.26450 | 75 |
| Before final grade, after LUT/AA | 1.20413 | 380 |

These are intermediate linear buffer values, **not display nits**. The separate
captures are from the same paused scene, not one atomically captured frame.
The preview confirms Geralt beside the boat. The pre-filmic input had 25 NaN
pixels; the two later captures had none. This revision does not alter unrelated
upstream behavior to conceal those pixels.

Captured weather constants:

- Native environment blend `cb3[13].x = 0.239534512`.
- Both curve shapes: ABC `(0.3, 0.3, 0.1)`, DEF `(0.2, 0.01, 0.3)`.
- Environment A exposure/scale/exponent `cb3[16].xyz = (1.78066993, 1.06298232, 0.5)`.
- Environment B `cb3[17].xyz = (1.40231645, 1.54014254, 0.5)`.
- Adaptation bounds approximately `(0.412631, 1.704171)` for both branches.

Each branch retains its own exposure calculation and adaptation bounds. Its
filmic shoulder now uses the same `ClassicExtendNative` helper as ordinary
gameplay. The native blend is applied **after** extending the two independently
exposed branches. Interpolating the parameters first would not be equivalent.

## Coverage and implementation

`tools/audit_hdr_cache.py` reads the existing DXBC cache inventory and supplements
it with the game dump folder and saved originals. It disassembles pixel/compute
programs and flags curve, LUT and analytic-grade candidates. Signatures only
select candidates for semantic inspection; they never authorize blanket clamp
removal or runtime shader patching.

The scan examined 2,055 unique pixel/compute shaders from the extracted cache
and available dumps. Some cache containers were not extracted, and runtime
paths not present in these sources may still exist. This is coverage of the
known shader families, not proof that every possible game shader was examined.

| Family | Existing coverage | Added coverage |
|---|---|---|
| Exposure/filmic | `B4953357` auto, single environment | `AEE0B973` manual; `AE7D5FA8` auto blend; `51F4E5FD` manual blend |
| Packed scene LUT | `27EF680B` single LUT | `63047C3C` two LUTs; `65B4CEFA` one+one environment LUTs; `E91AAC85` two+one; `7526E398` one+two; `7818760A` two+two |
| Final analytic grade | `649AF4FA` CA+analytic vignette; `5CBEC131` CA without vignette | `9F48B203` analytic vignette without CA; `1E28F70E` neither; `A1C06A7D` texture vignette without CA; `C4D2D4F6` CA+texture vignette |

The five LUT additions use the existing N2 max-channel compression and restore
range after **all** native LUT/environment blending. Packed addressing, gamma
conversion, strength, intensity, and alpha remain native. Restoring range before
the final RGB assignment is incorrect; the GPU HDR-range test caught that during
development and the generated shaders were corrected before the final build.

Final-grade additions share `ClassicGradeAndMap`. Its constant-array size is
configurable for the native 16- and 18-vector layouts. Texture-vignette variants
sample the original t2 mask and retain the existing color-dependent mask;
analytic variants retain their original polynomial. Chromatic aberration,
grade weights, fade remapping, and Vanilla/203-nit transport behavior are preserved.

Excluded candidates:

- `002F0E8C`, `9BF1C914`: native curve diagnostic graph overlays, not regular
  scene tone mappers.
- `20C1C070`, `FF88AB67`: geometry/material paths, including existing motion
  coverage; not final color grading.
- `2D1D82F3`, `A47D0EEE`: material/eye-like localized operations, not final grade.

No hair, alpha, normal, roughness, BRDF, visibility, depth or blend-weight
clamps were removed. No upstream lighting/material unclamp is justified by the
captured evidence. The demonstrated loss is in the postprocessing path.

## Validation and artifacts

Scratch root: `tmp/witcher3classic-investigation/hdr-permutations-20261023/`.

- `cache/hdr-inventory.json`, original DXBC, disassembly, decompiled candidate HLSL.
- `grade-before.json`, `grade-input-before.exr`: initial missing final-grade input.
- `boat-draws.json`: paused boat snapshot records.
- `boat-weather-blend.json`, `boat-pre-tonemap-t0.exr`, `boat-pre-tonemap-t1.exr`:
  exact weather inputs and constants.
- `boat-post-tonemap.json`, `boat-post-tonemap-t0.exr`: exact DoF input after weather curve.
- `boat-final-grade.json`, `boat-final-grade-input.exr`: final-grade input/constants.
- Matching `*-analysis.json` files preserve numeric analysis and resource identity.
- `validate.cpp`, `validate.cmd`, `validation.json`: D3D11 GPU regression fixture.

The earlier `post-grade-before.*` capture using a selected occurrence of the
reused copy shader `B13D3F21` is **not reliable stage evidence**. Its values did
not agree with the proposed stage identity. Do not use it to claim a measured
post-grade clamp; use the actual grade shader math and preserved pre-grade input.

The GPU fixture tests the actual Release CSOs from
`build/thewitcher3classic.include/embed` against original game DXBC. Sixteen
variants × four blend settings = 64 cases. It checks Vanilla equivalence, finite
HDR output, HDR range, alpha preservation, and the filmic blend's interpolation
between its endpoints. Maximum Vanilla absolute error was `1.1920929e-7`.
Inputs include captured weather/final-grade constants, a synthetic color range,
distinct packed LUTs and a spatial vignette mask. This does not replace visual
testing of every quest/cutscene or game-supplied LUT.

Release build succeeded. Existing shared shader loop-shadowing, C++ deprecation,
and local Slang-version warnings remain; no shared dependencies were changed.
The temporary `weather-live` candidate was compiled but never activated. The
user closed the game before live verification; the DevKit path was not changed.

## Next in-game checks

1. Relaunch with the new addon. Revisit the boat and the approach to cloudy/stormy
   weather. Check reflected highlights and overall exposure through the transition.
2. Capture `AE7D5FA8` and its next draw again. Confirm the addon replacement is
   active, then compare pre/post range and the final display output.
3. Disable chromatic aberration and test the previously uncovered final-grade
   path. Also check texture-vignette/cutscene variants when they occur.
4. Switch Vanilla/PsychoV and HDR presets; verify fades, bloom, hair, faces and UI.
5. If reflections remain dull, identify the specific boat/material or reflection
   draw and preserve its inputs before changing lighting math. Do not infer a
   material clamp from low brightness alone.

DLSS menu recovery and jitter changes are unchanged. Continue the remaining
upscaling work from `WITCHER3_CLASSIC_UPSCALING_RESEARCH.md` after this HDR check.
