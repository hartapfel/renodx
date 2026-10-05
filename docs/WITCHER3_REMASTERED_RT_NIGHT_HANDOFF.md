## RT follow-up completed in the tested scene (2026-10-05)

The user rebuilt at 12:00 and reported the RT scene now works perfectly with
Darker Nights disabled and all night sliders at zero. Added native-binding-only
D2C88922 GI sky-ray and 02320E1A reflection sky-miss overrides under lighting/.
They use the existing Skylight tag in b12 c185.w, scale the separate b0 c4.y
environment fill, and preserve hit/probe/local/emissive radiance. Do not scale
whole dynamic RT probes: this would remove bounced torch light and compound
across GI updates. Source/registration and baseline archive details are in the
mod README. Synthetic evidence is tmp/thewitcher3remastered/night/rt/:
720 unchanged-baseline cases, 5760 edited comparisons, matching sampled
coordinates and native bindings/CB sizes/thread dimensions. The local DXIL
decompiler now also fixes raw/reflected CB overlap and absolute-to-relative
resource-array addressing. Previous four Raster archives regenerate identically.
The rebuilt addon contains both new embeds; DevKit in PID 10044 confirmed both
as addon shaders, hasDiskShader=false and bypassDraw=false. This PID is transient.
The live path is empty and no diagnostics are active. A constant-buffer probe
in the previous process coincided with a crash; its scratch binaries were
replaced with original/production binaries before this relaunch.
Broader slider/torch/midday/Vanilla and Raster/PT regression checks remain
useful. The historical continuation below predates this completed RT scene.

# Witcher 3 Remastered: continue RT night-lighting coverage

Handoff written 2026-10-05. Read this file as the continuation prompt for a new session.

## Follow-up: torch-shadow flicker ruled out as a RenoDX-only regression

After this handoff, the user reported intermittent missing/broken point-light
shadows in Raster near a torch. It persisted with Night Skylight at 50 and
RenoDX Vanilla selected. The user then restarted with the RenoDX addon disabled
and confirmed the same flicker still occurs: “it wasn't our mod thankfully.”
Do not revert the night-lighting work to address that symptom. This establishes
that it reproduces without RenoDX, not which game or other-mod component causes it.

An additional synthetic check, `tmp/thewitcher3remastered/night/raster/residual/check-point-shadows.py`,
compares original E6A77B56 with its unchanged decompiled baseline across 192
point-shadow cases: six cube directions and several shadow/cookie flags.
All outputs match exactly, with 456 matching shadow/cookie sample coordinates.
This remains single-lane synthetic validation, not exhaustive GPU proof.
Original shader binaries were prepared in `tmp/thewitcher3remastered/night/shadows/native-lighting/`
for a possible isolation test but **never loaded**: DevKit had disconnected
because the user restarted. No production shader changes were made for this report.
The earlier runtime PID/pipe below is therefore historical; rediscover at resume.

## Task to continue

Continue work on `src/games/thewitcher3remastered`. Make the existing night-lighting controls cover the **RT renderer** as thoroughly as the now-validated Raster scene. PT had already looked good to the user. Preserve the successful Raster/PT behavior.

Latest user message:

> yes, it works flawlessly. Now unfortunately we will have to do the same fixes for the RT version. Can you please write a handoff script for a new session to continue work on this?

This confirms the final Raster hair correction, including torch lighting. **Do not treat earlier documentation calling shaders “Raster/RT” as proof that RT is complete.** The user explicitly identifies RT as the next task. Capture its actual active shaders and bindings before choosing replacements.

The aim is to remove artificial environmental lighting at night while retaining light from torches, candles and other local sources. At minimum settings the unlit scene should be able to become dark. Keep daytime untouched, fade smoothly across dusk/dawn, and retain the established slider mapping: 0 = zero contribution, 50 = native, 100 = double. Use existing sliders rather than adding redundant ones. Do not solve this with global exposure, final-image multiplication, or another grading adjustment.

## Repository and safety

- Workspace: `C:\Users\Vik\Documents\RenoDX\renodx`, PowerShell, branch `main`.
- Read root/nested AGENTS and `.agents/skills/setup-game-mod-dev/SKILL.md`. Read `decompile-dxil-shader/SKILL.md` before decompilation.
- The worktree is heavily dirty across many unrelated mods, DevKit, decompiler and build infrastructure. Preserve all existing work. No commit/push is requested.
- Night-lighting work is largely untracked: the game-local `lighting/`, `native/lighting/`, `night_lighting.hpp`, and `tests/night_lighting.cpp`. Do not overlook untracked files.
- Build game/DevKit addons in **Release**, with established Clang presets. Do not change global CMake/CI/presets or unrelated mods.
- Do not build the game addon while the game has it loaded. The setup skill says: “Do not build a game addon while that game is running with the addon loaded; the DLL can be locked.” If closing is needed, explain this rule and link the skill. User frequently rebuilds themselves; inspect artifact/process timestamps before asking for another rebuild.
- Do not spawn subagents unless explicitly authorized by current instructions.

## Current runtime and tools

At handoff the game was running, PID **31636**, DevKit pipe `renodx-devkit-mcp-31636`. Rediscover; these are transient.

Game binary directory used throughout this work:
`E:\SteamLibrary\steamapps\common\The Witcher 3\bin\x64_dx12`.
An early user message had a different `_dx12` path; verify the actual running executable before accessing game files.

The user rebuilt the latest addon at approximately **11:16:35 local time**, then started the new process at 11:16:48. The hair shader source predates that build. Its generated embed exists and its compiled shader passed the differential checks. DevKit confirmed:

```text
0x1B63829B: hasAddonShader=true, hasDiskShader=false, bypassDraw=false
```

No diagnostic override was intentionally left active. Earlier live path was cleared to `""`; check current state before changing it. A snapshot was queued immediately before the handoff, but its results were not used. Draw indices and handles from earlier sessions are stale.

Bridge helper: `tmp/thewitcher3remastered/live.py`. It launches `build/Debug/renodx-mcp-bridge.exe` as a command-line bridge; this does not mean the installed addon is Debug.

```powershell
python tmp/thewitcher3remastered/live.py
```

This discovers connections and saves tool schemas to `tmp/thewitcher3remastered/live-discovery.json`. For calls from a scratch Python script:

```python
import sys
sys.path.insert(0, 'tmp/thewitcher3remastered')
from live import calls
results = calls([
    ('devkit_get_shader', {'shaderHash': '0x1B63829B'}),
    ('devkit_queue_snapshot', {}),
], 'night/raster/residual/hair-search/runtime.json')
```

Use fresh scratch filenames in the RT investigation. `calls` saves under `tmp/thewitcher3remastered`; create parent directories first. A snapshot is asynchronous: queue, then read on a subsequent call. Tools include list/get draws, shader dump, resource analysis/readback and live replacement. Read their discovered schemas. The API has no Draw-bypass setter: previous isolation tests asked the user to toggle Draw in DevKit and then restore it.

Process/bridge access previously required normal sandbox escalation. No automatic approval rejection occurred. Do not infer that a failed sandbox process query means the game is closed.

## Existing controls and native hooks

Read `night_lighting.hpp` and the night section of `addon.cpp`; they are authoritative.

Existing strengths: skylight, direct light, directional fog, haze, visible sky, clouds, water. User previously requested removal of Night Grass Lighting, Moonlight, Night Color Grading and Night Moon Brightness; do not reintroduce them.

The native environment-hook approach was established by comparing Darker Nights at 0% and 100%. It edits freshly constructed per-view/constants data, not shared environment assets. Keep Darker Nights at 0% or disabled while verifying our controls. Do not assume it is currently at either value without checking.

Important behavior:

- `ClockNightWeight` reads evaluated game time at environment `+0x15c0`. It is full night from 20:00–04:00, fades 18:00–20:00 and 04:00–06:00, and is zero during daytime. This deliberately avoids weather-authored day weights which previously left clear-evening or storm lighting behind.
- `BuildHook`: PT/shared-view directional colors at output `+0x280/+0x290/+0x2a0`.
- `DirectConstantsHook`: independent Raster/global-light upload at renderer `+0x690`; b13 c1/c61/c62 directional colors. Preserve torch/local-light lists.
- `CommonConstantsHook`: b12 c184.xy/c185.xy native environmental diffuse/reflection weights; c184.zw direct enables and c185.z distance factor are preserved.
- Same hook publishes the night clock even when PT is off.
- Native zero padding **b12 c185.w** transports the missing new-ambient multiplier. Guarded native zero-store RVA is `0x1BE0142`. Tag is `-1 - multiplier`; valid range `[-3,-1]`, all other values mean identity. Zero/neutral/day remain native. Helper: `lighting/night_skylight.hlsli`.
- Directional fog: c39–41, plus custom fog c189/c191. Haze: c45–47 and c194. Preserve extinction/density and alpha.
- Visible sky: c195–202 plus c249 (FX_SkyRain) and c278 (Custom1). The latter two fixed a separate directional horizon gradient in `3B15DAAB`.
- Cloud colors: c244–248 (native FX_Sky through FX_SkySunset). Additional volume/smoke replacements are in `lighting/`; `95CC19A8` was positively identified by Draw bypass as the tall smoke plumes. Scale only at night.
- `GlobalConstantsHook`: water b0 c11.xyz and c12.zw, preserving flow/Fresnel/caustics/reflection bindings.
- Native `PTSkyImpact` uses a baseline/rebase/restore wrapper; do not repeatedly multiply last frame's value.

## Validated Raster additions

All are under `lighting/`; unchanged decompilations are archived under `native/lighting/` with `.hlsl.original` suffix and hashes in `native/lighting/manifest.json`. Do not put original CSOs in the game source folder, and do not give archives a plain `.hlsl` suffix: CMake would discover duplicate shader hashes.

| Shader | Contribution changed | Evidence |
|---|---|---|
| `E6A77B56.cs_6_6` | New deferred ambient branch bypassing legacy skylight weights | 360 baseline + 2880 edited synthetic cases. User confirmed dark gear remains properly lit under a torch. |
| `8DBF022F.ps_6_6` | Forward new irradiance (`b12 c226.x`), ambient `_2976..2978` | 160 baseline + 1280 edited cases. |
| `EAAAC84D.ps_6_6` | Forward new irradiance, ambient `_4001..4003` | 160 baseline + 1280 edited; all five MRT outputs preserved. |
| `1C12BED7.cs_6_6` | Environment/sky reflection fallback only | 180 baseline + 1440 edited; preserves traced scene-hit radiance and weight. |
| `1B63829B.ps_6_6` | Transparent hair new ambient branch | User positively identified by Draw bypass; latest rebuild visually confirmed flawless. |

These hashes have special registration in `addon.cpp`: replace only in PsychoV with hook installed, non-neutral Skylight and nonzero night weight; **`on_inject=false`**. They use existing native bindings. Do not extend these pipeline layouts: earlier generic injected-layout experiments caused missing hair/crashes.

Reflection path: `1C12BED7` → temporal `8FDA5F50` → denoising/`C836CA08` → late composite `BF66A39B`. Disabling `BF66A39B` removed foliage sheen. Its secondary input measured zero in that capture. We changed the producer fallback, not the entire composite. Two mutually exclusive producer tails use `(1-hit_weight) * NightSkylight`; scene-hit contributions are unchanged. Baked probe content remains environmental, including baked local-light content. Do not claim all reflection variants are covered or every compounded downstream weight is linear.

Hair details: `1B63829B` reads ambient from vertex inputs, selects the new branch with `_469` (`b12 c226.x`), and now scales `_2175..2177` before AO/tint/fog. Existing reflection weights, direct/local light accumulation, six discard sites and alpha are preserved. It adds only named padding `night_skylight_tag : packoffset(c185.w)` inside native b12. Checks: 160 exact baseline cases, 1280 ambient-delta comparisons through tint/fog, 36 alpha/discard cases, identical 18 bindings/cbuffer sizes/signatures and intrinsic counts. The actual built embed passed the same tests.

**Ruled out:** `36B38E59` did not remove hair when bypassed. It appears to be another material (possibly eyes). No production edit was made. Do not mistake it for the hair shader. Shader hash arrays may contain unordered stages; `9E155C7A` was a VS, not a PS.

## Validation and decompiler cautions

Main scratch evidence: `tmp/thewitcher3remastered/night/raster/residual/`.

- `check-compute.py`, `check-forward.py`, `check-reflection.py`, `check-transparent.py`.
- `forward-structural.json`, `reflection-structural.json`, `hair-search/structural.json`.
- Hair native CSO, LL, baseline, strict and edited binaries: `hair-search/0x1B63829B.ps_6_6.*`.
- `compute_ir.py` is a synthetic DXIL interpreter, **not full GPU validation**. Single-lane compute/barrier simplifications, deterministic texture callbacks and limited branches mean these tests do not prove every shadow/material permutation. Do not rerun the older `extend-interpreter.py` generator over it; later fixes were manual.
- Native hook tests: `src/games/thewitcher3remastered/tests/night_lighting.cpp`, 180 cases plus cloud isolation/rebase/restoration checks.
- Strict compiler invocation: `bin/dxc.exe -T <native_profile> -E main -HV 2021 -Ges -WX ...`. Audit signatures, binding types/spaces/counts, CB sizes, thread dimensions and control flow in addition to compiling.

Shared decompiler `src/utils/shader_decompiler_dxc.hpp` has substantial pending fixes. Preserve them and unrelated edits. Current debug macro is 0. Relevant fixes include postdominator joins, unsigned groupshared atomics, raw CB aliases, raw-buffer stores, integer switch selectors, opaque scalar structured buffers, and native opaque RawBuffer declarations/addressing.

The hair shader originally compiled to a **wrong typed t20 buffer** despite successful compilation. Resource metadata identifies ByteAddressBuffer but its reflected pointer is only `%dx.types.Handle*`. The generic fix uses RawBuffer shape for native declarations and loads; preserve descriptor-heap structured stride behavior. Corrected hair baseline matches exactly. Regenerating the previous two forward shaders and reflection shader with `--flatten` produces identical archived HLSL, so this final generic fix did not change their baselines. `--flatten` affects source formatting/inlining; compare with consistent options.

Build standalone decompiler (safe while game runs):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tmp/thewitcher3remastered/night/volumes/recheck/build-decomp.ps1
```

It builds `build/Release/decomp.exe`. Do not hand-repair broken baseline HLSL; fix the generic decompiler, regenerate, audit.

Syntax and hook checks without replacing loaded addon:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tmp/thewitcher3remastered/night/lighting/check.ps1
```

Latest run passed with nine pre-existing shared-header warnings.

Targeted addon build **after game closes**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tmp/thewitcher3remastered/night/storm/build.ps1
```

This configures `clang-x64` and builds `clang-x64-release --target thewitcher3remastered`. Output `build/Release/renodx-thewitcher3remastered.addon64`. Embeds: `build/thewitcher3remastered.include/embed/`. No need to rebuild DevKit unless an actual tooling change requires it.

## Next session sequence

1. Confirm RT is enabled rather than Raster/PT, with the affected night view and a local light available. Reconnect DevKit; check controls, night time, and Darker Nights interference. Do not assume frame generation state from old conversations.
2. Capture the RT frame and inspect its active lighting/reflection/material shaders. Compare resources/constants to the validated Raster path. Check whether the common hook/tag reaches each RT constant upload and whether RT reads another environment/probe contribution.
3. Isolate residual light by contribution. Prefer upstream native environment inputs; add narrow shader changes when a branch bypasses those inputs. Keep traced local illumination, emissives, material alpha and fog extinction.
4. For new hashes, archive and validate the unchanged decompilation before the edit. Register using native-only bindings when following this ambient approach. A DevKit “activated” shader is not proof that an unregistered addon replacement executes.
5. Test each change with night slider 0/50/100, a torch/local source, and midday. Let temporal histories settle. Confirm Raster and PT regressions after RT works. A lit pause-menu background can still be inspected, but native environment updates may be cached while paused; distinguish shader execution from constant refresh rather than dismissing every paused capture.
6. Keep the user informed and use focused live tests. Do not claim all RT variants are fixed based solely on static compilation or one scene. Update the existing README with what was actually verified.

No further motion blur, video, tonemapper or unrelated effect work is requested by this handoff.
