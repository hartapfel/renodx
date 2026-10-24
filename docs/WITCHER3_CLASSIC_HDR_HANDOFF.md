# The Witcher 3 Classic 1.32 — RenoDX HDR implementation handoff

**BlitzFX rendering compatibility (2026-10-23):** pre-change Classic state pushed
as `26075fbb`. Captured BlitzFX TAA suppressing the native DLSS boundary, plus
its clamped filmic/final-grade shaders. New dynamic, PE/code-guarded world-render
handoff bypasses BlitzFX TAA/jitter only while DLSS owns reconstruction; it
restores the selected BlitzFX mode afterward. Added its HDR curve/final grade,
RCAS ownership and nine captured material-motion permutations. Release build,
CPU ownership tests, WARP/NVIDIA effects and object suites pass. The live
manual Vanilla-AA experiment restored Quality reconstruction; the automatic
switch and full combined scene acceptance still require the new addon.
The patched ReShade startup DLL remains required. See the
[implementation, evidence and live checklist](WITCHER3_CLASSIC_BLITZFX_COMPATIBILITY.md).

**Latest menu/scene-grade revision (2026-10-23):** `addon.cpp` now uses one explicit,
ordered RenoDX `Settings` initializer. Removed the synthetic `Control` table,
settings construction loops and `settings.push_back` calls. Existing settings,
keys, defaults, hints, tabs, effect order and global/preset behavior remain;
`DllMain` retains only migrations and actual addon initialization. Hidden global
DLSS definitions are ordinary entries at the end; `DrawAddon` keeps its requested
dropdowns and diagnostics. No shared settings-framework changes.

- Advanced **Scene Color Grading** is immediately after Tone Mapping, before
  user Color Grading/PsychoV. It has **LUT Grading Strength** (`LutGradeStrength`,
  default 100), **LUT Scaling** (`LutScaling`, default 0, retained choice), and
  **Color Grading Strength** (`ColorGradeStrength`, default 100), ported from the
  Hartapfel Next Gen Scene Grading section. Brightness Compensation and Hue Shift
  are not Scene Grading controls and were not added by this request.
- LUT strength 0 returns the original signed scene and alpha before any LUT
  sampling/proxy work. Other values interpolate neutral versus fully blended
  native LUT grade in linear proxy space, then restore gamut/range once.
  Analytic grade contribution is interpolated in linear proxy space before
  vignette. The colored native vignette blend moves after output levels using
  their commuting affine transform; perfect-black attenuation stays after
  restoration. Both vignette modes remain independent of scene grade strength.
- Injection expands from 144 to **160 bytes**, with explicit padding; C++ and
  shader layout share the struct/assert. Runtime defaults and saved-setting
  defaults both initialize the two strengths to 1. Existing values are not
  reinterpreted or overwritten. Preset Off retains original native branches.
- Release object/shader compile passes (37 existing deprecation warnings).
  WARP and NVIDIA `tests/effects.cpp` pass prior tests plus native-grade bypass,
  0/50/100 contribution, independent vignette at grading 0, exact LUT bypass,
  and midpoint LUT interpolation with signed colors. Structural audit confirms
  every existing key occurs once, only the two expected keys were added, and
  the declared section order. Logs: `tmp/classic-scene-menu-compile.log`,
  `tmp/classic-scene-menu-tests.log`, `tmp/classic-scene-menu-release.log`.
- Full Release link completed with Classic closed: **4,875,776 bytes**,
  **2026-10-23 20:28:01 CEST**, SHA256
  `FE803D660F3CD4AEA980BABFBEF8BBCEA2D98EBDD44CFD55C608D21273A35BCC`.
  The existing game-folder symlink targets this ready-to-test build. After relaunch, check
  both tabs, Advanced section order and tooltips, strengths 0/50/100, independent
  vignette, saved presets and DLSS preferences. Earlier signed-format live
  capture and performance checks remain pending.


**Latest LUT/wide-gamut checkpoint (2026-10-23 20:15 CEST):** implemented and linked
in `build/Release/renodx-thewitcher3classic.addon64`, **4,849,664 bytes**, SHA256
`913101094B6DFDBB39B41789B1CA529DA2B1AADDA73F0949D83E7D3D873AA025`.
The game was closed during linking. It subsequently relaunched as PID 33732
(20:17:49 CEST); the 20:18:38 log confirms Quality 2560x1440 → 3840x2160
reconstruction and active object history. DevKit is not loaded/available in this
run, so signed-format capture, visual and performance acceptance remain pending. These changes follow the earlier published
`0526a1ed` baseline and have not been committed/pushed in this checkpoint.

- New `grading/grade_state.hlsli` ports Remastered `WitcherPrepareGrade` and
  `WitcherRestoreGrade`: temporary luminance-axis gamut contraction, N2 range
  compression, then restoration after all grade/environment blends. Six LUT
  variants take an early custom branch; original native branches remain intact.
  Native atlas addressing, per-LUT gamma decode, gains, blend order and alpha
  are checked against original DXBC. `final_grade.hlsli` uses the same proxy and
  signed level-power math, restores before perfect-black vignette/PsychoV, and
  leaves display-gamut fitting to PsychoV.
- New `grading/lut_sampling.hlsli` ports the Remastered endpoint/OkLab algorithm
  with constant-LUT guards and relative chroma darkening. **LUT Scaling** is
  under Advanced → Color Grading, 0–100. Default **0** retains native LUT levels
  pending weather/interior/cinematic comparisons; 100 applies full restoration.
  This control is separate from the always-active HDR/gamut bridge. Zero skips
  six extra atlas texture samples per LUT. `ShaderInjectData` remains 144 bytes:
  `lut_scaling` consumes one formerly reserved float.
- Added a clone rule only for backbuffer-sized R11 render targets to signed
  RGBA16F. The unsigned scene pool would otherwise discard negative restored
  channels. Reduced-size bloom/effects buffers and material/depth/alpha clamps
  remain native. Full-size allocation/bandwidth cost needs measurement; this is
  a color-preservation change, not a performance optimization.
- DLSS preparation remains finite/nonnegative for NGX. `Prepare::Blit` and
  private output shader `F3C10003` restore the current signed residual after NGX,
  following Ezio's `dlaa_output.ps_3_0.hlsl`. Sampling uses actual input/output
  sizes, current pixel jitter and active-subrect edge clamps; source pool padding
  is excluded. The existing blit carries it, with a cached sampler/32-byte CB;
  debug paths retain their own layout/state restoration. Residual negatives are
  not temporally reconstructed; saturated animated/disoccluded edges need checks.
- Release object/shader build and full link pass. Extended `tests/effects.cpp`
  passes WARP and NVIDIA: six LUT permutations × four environment blends,
  Vanilla/native-proxy equivalence, active Scaling, alpha, zero black, constant
  LUT guards and signed HDR round-trip, plus prior effects tests. Extended actual
  NGX tests pass all five quality/model request sequences, HDR/state restoration,
  signed residual checks at three output positions including poisoned subrect
  edges, jitter checks and clean shutdown. Logs: `tmp/classic-lut-compile.log`,
  `tmp/classic-lut-effects.log`, `tmp/classic-lut-dlss-unrestricted.log`,
  `tmp/classic-lut-release.log`.
- A restricted test run completed all evaluations then waited inside
  `NvTelemetryAPI64!UninitializeTelemetry` during NGX shutdown. CDB stack evidence
  is `tmp/classic-lut-dlss-shutdown-stack.log`. Only that test process was stopped;
  the unrestricted rerun completed normally. No workaround was added to runtime.
- Next: relaunch, confirm LUT/AA target and SRV formats are signed FP16 through
  DevKit (do not infer successful cloning from shader tests), test native TAA as
  well as DLSS, compare Scaling 0/50/100 through storms/cutscenes/fades, check
  wide-color edges and original effects, then measure matched-scene memory/frame
  cost with capture/debug off. No live replacement was activated.

**Publication validation (2026-10-23):** Classic was isolated on remote main
`7fa3e3e0` in `tmp/classic-publish-check/`, excluding the divergent local commits
and unrelated dirty work. The only shared build change adds `thewitcher3classic`
to the existing x64 NGX linkage condition. The game-local draw boundary now uses
`shader::GetCurrentState(context.cmd_list)`, compatible with both local and remote
APIs, instead of the command-context helper absent on remote main. Full Release
compilation/link passes there (62 dependency/deprecation warnings, no errors).
Python fingerprint (six cases), CPU history/upscale-scope, effects on WARP/NVIDIA,
and actual NVIDIA NGX quality/model evaluations pass. Publication logs:
`tmp/classic-publish-clean-build.log`, `tmp/classic-publish-tests.log`; staged
whitespace check passes. This isolated artifact was not installed over the
running game's accepted build. Patched DevKit development tooling and unrelated
shared infrastructure changes are not part of this game-source publication.


**For the next DLSS integration, start with the
[DLSS integration playbook](DLSS_INTEGRATION_PLAYBOOK.md).** It gives the ordered
workflow, source map, input contracts, acceptance gates, pitfalls, test commands
and evidence lookup. This file is the chronological Classic session record;
older “next steps” and installed PIDs/builds below are historical. The
[object-motion guide](OBJECT_MOTION_VECTOR_INTEGRATION.md) provides the detailed
deformation/identity algorithms, and the [test README](../src/games/thewitcher3classic/tests/README.md)
makes fixture execution independent of ignored scratch runners.

**Latest vignette/defaults checkpoint (2026-10-23):** Release object/shaders and
WARP/NVIDIA effects fixtures passed, then the user rebuilt and restarted. During
the documentation audit the linked Release is **4,789,248 bytes**, built
**16:13:07 CEST**, SHA256
`9524C862766A6831BF6277400F12383020AE900273C141CCBD8E457CC962A26E`.
PID **3144** started 16:17:52; ReShade logs the addon loading/registration at
16:18:27 and Quality 2560x1440 → 3840x2160 reconstruction at 16:18:44. Later log
entries also show Ultra Performance, Performance, DLAA and return to Quality.
No additional shutdown/link is needed. This confirms loading/reconstruction,
not visual acceptance of the vignette. Logs: `tmp/classic-vignette-compile.log`
and `tmp/classic-vignette-test.log`.

- Read Hartapfel Remastered `postgrade.hlsli` and its vignette settings directly.
  Classic now exposes **Vignette Strength** (0–100, default 50) and **Vignette Black
  Floor** (Native/Perfect Black, default Perfect Black) under HDR → Effects.
  Shared `grading/final_grade.hlsli` retains native luminance-dependent radial/texture
  masks. Native mode scales the original colored blend. Perfect Black multiplies
  decoded linear light after output levels, before PsychoV; above 1x it uses
  `(1 - native_mask)^strength`, preserving detail in partial masks. Two no-vignette
  variants stay unchanged. Vanilla uses original shader branches. No extra pass.
- Injection is now 144 bytes (two controls plus two padding floats). The effects
  fixture uses the shared struct and exact Release bytecode; six variants pass
  strength 0/50/100, black input, colored native floor, progressive attenuation,
  no-vignette isolation and existing RCAS/CA/grain/blur/native-sharpening checks.
- New runtime and setting defaults: DLSS enabled, Quality (index 1), model M
  (index 3 / NGX preset 13). Saved settings remain authoritative; model fallback
  is unchanged. Vegetation exclusion still defaults off.
- Peak Brightness tooltip follows the Remastered/Ezio display-peak/manual/reset
  convention, explicitly explains the HDR highlight limit in nits and matching
  monitor/TV capabilities, and documents automatic detection/1000-nit fallback.
  Bottom HDR Instructions now only mention enabling Windows HDR and setting the
  display peak, which is usually detected automatically. Other hints are retained.
- Remaining visual check: compare Vignetting on/off, strength 0/50/100 and
  Native/Perfect Black in dark scenery, verify cutscenes and HUD, then confirm
  defaults on fresh DLSS preferences without overwriting existing user choices.
  HDR Reset All continues to preserve global DLSS preferences.

Updated 2026-10-23 during the whole-system object-motion performance investigation. Earlier dated sections are historical. The reusable implementation reference is [Adding object motion vectors to an existing DX11 game](OBJECT_MOTION_VECTOR_INTEGRATION.md).

**Latest effects/menu checkpoint (2026-10-23):** implemented, GPU-tested and rebuilt/relaunched by the user. The installed Release is **4,782,080 bytes**, **2026-10-23 15:30:35 CEST**, SHA256 `664FBFBD7DB6C1F215809B0B30074F9052845890B022F712ACD6D785F9C2C591`, PID 10700. The 15:32 log confirms DLSS Quality 2560x1440 → 3840x2160 and full foliage motion active; no further shutdown is needed for this checkpoint. The following performance checkpoint is historical and remains included.

- Vegetation exclusion now defaults **off** (both runtime initialization and saved-setting default). Previously saved user choices remain respected. The 79-second profile button and runtime sweep branches are removed. DLSS explanations now use hover tooltips; HDR presets/Info stay within the main addon frame.
- Added **HDR → Effects → Blur**, **Chromatic Aberration** Native/RenoDX with Intensity and Start Offset, and **Perceptual Film Grain**. Added **DLSS → Sharpening → Replace Native Sharpening** and **Lilium RCAS Strength**. Sharpening works with native TAA too; controls require PsychoV, like the Remastered reference. Defaults are native blur 50, native CA, grain 0, replacement off/strength 0.
- Reference implementations read directly from `src/games/thewitcher3remastered-hartapfel`: `lilium_rcas.hlsli`, `chromatic_aberration.hlsli`, `output.hlsli`, depth-blur `4B0ABFCA`, native-sharpening bypass `3650C210`, and addon settings. Classic uses different DXBC shaders/bindings. No Remastered source was modified.
- Live DevKit capture with native Sharpening High proves **Classic sharpening is pre-DLSS**: draw 2452 `3EDDC379`, LUT 2454, TAA/DLSS 2455 `201C53B4`, luminance 2456 `71AFA8D1`, final grade 2457 `649AF4FA`. `71AFA8D1` is luminance extraction, not sharpening. Native depth blur is earlier, draw 2434 `6ED58557`, using source-alpha/one-minus-source-alpha blending.
- In replacement mode only, `3EDDC379` becomes its native center sample with alpha 1, preserving UVs and the ping-pong destination; C++ selects it without injecting extra constants into that pass. RCAS operates after reconstruction in the six existing final-grade permutations, then native/custom CA samples the sharpened signal. PsychoV follows the grade; luminance-adaptive grain follows PsychoV and precedes scene scaling/gamma/UI. Film grain uses RenoDX's shared random service. No added fullscreen pass or RT allocation. Shader constants expand from 96 to 128 bytes.
- `6ED58557` preserves native depth conversion, sampling weights, alpha and sky masking. The slider scales the non-sky blur radius; zero returns transparent black for both sky/non-sky. At 50 the C++ replacement is inactive, preserving original bytecode. It does not control Motion Blur/Witcher Senses. Native blur remains before reconstruction; this task does not relocate the game's existing depth pipeline.
- New `tests/effects.cpp` exercises the exact Release FXC output. WARP and NVIDIA both pass six native/Vanilla comparisons, RCAS zero/active, CA effect, animated grain seeds, Vanilla gating, blur native/off/double/sky and sharpening-copy HDR RGB/native alpha. Logs: `tmp/classic-effects-compile.log` and `tmp/classic-effects-test.log`. Compilation has 37 existing/dependency deprecation warnings, no errors. The shared random header adds six internal deprecation warnings; callers use its current API.
- Evidence/original shaders/captured constants/build-test runner: `tmp/witcher3classic-investigation/effects-20261023/`. Native originals are kept outside the game source folder. `effect-family-audit.json` records cache candidates; cache completeness is not assumed.

DevKit reconnected to PID 10700 and confirms addon replacements registered for blur,
native-sharpening bypass and final grade. A bounded final-grade capture verifies
**128 bytes at b13**, with live user values reaching the shader: Blur 1.0,
RCAS mode 1/strength 1.0, custom CA mode 1/intensity .7/start .7, film grain .5
and a populated random seed. Saved as `installed-grade-inputs.json` in the effects
scratch folder; capture is stopped, with zero pending readbacks. This verifies
bindings and control propagation, not subjective visual acceptance.

Live visual checks remain: verify the menu and hover hints, then compare native Sharpening Off/High with replacement on at strength 0 and 50. Test DLSS Quality, DLAA, native TAA, CA Native/RenoDX/zero, film grain 0/50, Blur 0/50/100, HUD, menu return, cutscenes and Preset Off. New effects still need live visual acceptance. NVIDIA's [DLSS programming guide](https://raw.githubusercontent.com/NVIDIA/DLSS/main/doc/DLSS_Programming_Guide_Release.pdf) recommends early reconstruction and subsequent post effects; this port keeps the proven native TAA boundary while placing the new RCAS/CA/grain downstream and suppressing pre-DLSS native sharpening only when requested.

**Current checkpoint:** the user confirms the cache-invalidation correction substantially improves performance. Foliage coverage is accepted. Batching and the first constant-upload revision both failed to improve live frame time; the later event correction is the first observed performance improvement. The user rebuilt the deferred-context-guard version at 14:55:21 CEST (4,524,032 bytes), running as PID 30316; its confirmed full-motion trace remains approximately 9.32 ms. Do not report either revision as a performance success.

The user explicitly requested a DLSS **Performance** section and **Exclude Vegetation from Object Motion (high performance impact)**, default enabled. This is now implemented in source as the global `ExcludeVegetationMotion` preference. It bypasses foliage preparation/replacement before history copies; native foliage rendering and camera vectors remain. Character, cloth, bird and moving-prop coverage is unchanged. Full-coverage profiling is disabled while exclusion is enabled, and changing it cancels a running sweep.

A concrete cache bug was then found: ReShade emits `execute_command_list` on D3D11 Present and Flush, not only deferred-list execution. Our handler invalidated every constant-buffer cache entry on each such notification. This explains why unchanged-target reuse was zero even after warmup (92 CPU uploads / 449 GPU fallback copies at object frame 64). The corrected handler subscribes to `execute_secondary_command_list`, preserving the conservative deferred-context fallback. Native buffer mutation invalidations remain intact. Source evidence: `external/reshade/source/dxgi/dxgi_swapchain.cpp:984` and `external/reshade/source/d3d11/d3d11_device_context.cpp:857,1125,1558`. No external/ReShade source was edited.

The Performance option and event correction pass the Release object compilation (`tmp/motion-performance-compile.log`, 31 existing warnings) and all eight constant-history byte-equivalence cases on WARP and NVIDIA (`tmp/motion-performance-uploads-test.log`). The user rebuilt and restarted before another link was needed: current Release is **4,525,568 bytes**, **2026-10-23 15:08:21 CEST**, SHA256 `C282F0E1AD95AA988ABAF821AA88EEBB2DCCC427304D0E169C5F7CFE5591BFA6`, PID 34916. The user reports that performance is now much better.

The new 20-second trace with `AAObjectMotion=1`, `ExcludeVegetationMotion=0`, debug off and Quality 2560x1440 -> 3840x2160 averaged **4.876 ms frame / 4.872 ms GPU busy / 3.009 ms CPU busy (~205 FPS)**. Earlier current-build full coverage averaged 9.32 ms (~107 FPS). These are separate runs without guaranteed identical camera/time; do not call this a controlled 91% FPS improvement. The new utilization sample averaged **99.05% GPU activity, 22.35% memory activity, 440.65 W**, system CPU 25.60%, game 3.024 core equivalents and busiest thread 90.60% of one core. Faster submission/execution now brings CPU throughput closer to a potential limit. The initial frame-64 cache log happened while exclusion was still enabled (4 uploads/0 unchanged/0 copies), so it cannot prove full-foliage cache counts. Later logs confirm 440/441 foliage draws retained attachments after exclusion was disabled. Evidence: `cache-fix-current-on.csv` and `utilization-cache-fix-on.json`. The user subsequently reports approximately **201 FPS with vegetation motion -> 223 FPS with exclusion enabled** (~4.975 -> 4.484 ms, ~0.491 ms saved / 10.95% FPS gain), and confirms the option works as expected. This is a user-observed comparison, not a separately captured ETW pair.

Requested utilization check: a 21.2-second sample on PID 30316 recorded 96–98% NVIDIA GPU activity, 11–12% memory activity, roughly 270–278 W and 2692–2700 MHz graphics clocks. Total CPU time averaged 11.59% across logical processors; the game consumed 0.946 core equivalents, and its busiest sampled thread averaged 39.88% of one core (next 28.30%). This does not suggest a saturated CPU thread. The separate current-build PresentMon trace averaged 9.32 ms frame/GPU busy and 3.24 ms CPU busy. These are activity/time counters, not SM occupancy or stall counters; a GPU dependency/front-end stall remains possible and is not proven. Evidence: `performance-20261023/utilization-current-on.json` and `upload-current-on.csv` under the temporal-dev scratch folder. NVIDIA's [counter definitions](https://docs.nvidia.com/deploy/nvidia-smi/index.html#utilization) distinguish activity time from execution-unit utilization.

The earlier installed batching Release was 4,500,480 bytes, built 2026-10-23 14:04:09 CEST, SHA256 `64C8C9EFF94A530568226129136F4350AF1154FC85F7AB07FB9B95FBA1F81984`. The accepted foliage build is backed up at `tmp/witcher3classic-investigation/temporal-dev/performance-20261023/foliage-accepted.addon64` (SHA256 `608926DBD6B9D1EDA6D993FD5340A8E4E64DBA5B0170D3AF78A2C4993FC852F1`).

Confirmed uncapped measurements, same stationary scene, Quality 2560×1440 → 3840×2160, debug off, PID 35932: Object Motion OFF mean frame 4.265 ms / GPU busy 4.264 ms / CPU busy 2.523 ms; ON 9.332 ms / 9.331 ms / 3.366 ms. Approximately 234 versus 107 FPS and +5.067 ms GPU busy. Intel PresentMon 2.6.0 captured 20 seconds per state; first 120 and last 60 rows were trimmed. The earlier 225-FPS capped comparison was a lower bound; the user subsequently disabled the cap. Do not use PID 34812's `full-motion-batched-uncapped.csv` as the confirmed matched comparison: the user restarted again and clarified gameplay readiness afterward. Confirmed traces end in `-uncapped-confirmed.csv` under the performance scratch folder.

The sweep measured GPU busy times of 4.269 ms camera-only, 4.659 skin-only, 4.314 deformed-only, 4.343 rigid-only, 8.882 foliage-only, and 8.180 all-history/native-shaders; full-motion bookends were 9.319/9.327 ms. The profiling Release was rebuilt by the user: 4,505,088 bytes, 14:19:10 CEST, SHA256 `08310D2622C93E892C8CAD89A511406D9EF62CD8E3F9ECF512D6947F78ADABC3`.

The user rebuilt the constant-upload revision at 14:38:00 CEST: 4,523,008 bytes, SHA256 `DF08788878787A7F74DB67C464601F6EDDB1D490540F5F070D217297B22F5970`, PID 10892. Its first active sample logs 82 CPU history uploads, 0 unchanged targets, 431 fallback copies; this startup sample is not a steady-state performance result.

Next: the validated source is installed; the user accepts both the major cache-fix improvement and the optional vegetation-exclusion gain. No further restart is needed for this checkpoint. Future optimization should use matched scene traces across more scenes and distinguish CPU submission from GPU execution. Obtain full-foliage cache counters after warmup if investigating residual copies (the startup log captured exclusion enabled). Keep exclusion off for full-coverage acceptance, preserve characters/cloth/props, and do not broaden this into arbitrary low-resolution motion or extra culling without correctness evidence. See [performance methodology](OBJECT_MOTION_VECTOR_INTEGRATION.md#whole-system-performance-investigation-2026-10-23).

The previous accepted baseline was the horse-tail Release: SHA256 `408D746F32A71D61A814411C087DCAE446D289A4A7852F1815C73E8D35DB267C`, 4,234,240 bytes, built 2026-10-23 12:50:10 CEST. Neck acceptance is not separately recorded.

The preceding HDR revision remains included: `AE7D5FA8` weather-blend filmic plus 11 exposure/LUT/final-grade permutations. Its 64 GPU cases passed. No live replacement was activated and no user visual acceptance of the weather change has yet been recorded. See [HDR permutations and weather audit](WITCHER3_CLASSIC_HDR_PERMUTATIONS.md).

The previous DLSS checkpoint remains valid: the user confirms upscaling persists after opening the Map and image quality improved with managed jitter. DLAA also uses the new 32-phase Halton sequence. See [menu recovery and jitter](WITCHER3_CLASSIC_UPSCALING_RESEARCH.md#menu-recovery-and-projection-jitter--2026-10-23). Scene mip bias, explicit camera-cut detection, broader cutscene/resize/UI validation and matched GPU timing remain pending.

## 1. Assignment and confirmed decisions

Build a clean, standalone RenoDX HDR addon for **The Witcher 3 Classic, version 1.32, DX11**, targeting an otherwise unmodified game. The user will begin the implementation session with the game running and DevKit enabled. Inspect that running installation before modifying it.

The user confirmed:

- Start from a clean addon scaffold, not a renamed copy of the Remastered addon.
- Use **PsychoV-31 (Custom)** from our current Remastered implementation as the only custom tonemapper, enabled by default.
- Offer exactly two tone-mapping choices initially: **Vanilla** and **PsychoV-31 (Custom)**.
- Match **Classic's native contrast and art direction** by default. Do not use Remastered's Natural curve or assume that Classic uses Remastered's AgX curve.
- Vanilla must retain original SDR rendering, tone mapping, grading, and effects. The user explicitly permits presenting that SDR-looking image through an HDR swapchain. Restoring an actual SDR swapchain is not a requirement.
- Start with three settings sections: **Tone Mapping**, **Color Grading**, and **PsychoV-31 (Custom)**.
- Native shaders have not yet been decompiled for this task. Discover, dump, decompile, validate, and then replace the necessary shaders, including LUT builders and post-processing passes where the captured pipeline requires them.
- Preserve immutable originals outside the addon source/build-discovery and live-replacement paths.

Deliver a working Release addon and concise verification results. Do not commit, push, publish a snapshot, or create a PR unless separately requested. Do not treat the old conversation's publishing requests for other mods as authorization for this new addon.

## 2. Workspace boundaries and identity

Repository: `C:\Users\Vik\Documents\RenoDX\renodx`.

Use this proposed identity unless a collision is discovered at implementation time:

| Item | Value |
|---|---|
| Source folder / CMake target | `thewitcher3classic` |
| Source path | `src/games/thewitcher3classic/` |
| Release artifact | `renodx-thewitcher3classic.addon64` |
| Display title | `The Witcher 3 — Classic RenoDX` |
| Custom tonemapper label | `PsychoV-31 (Custom)` |
| Initial mode | PsychoV |
| Primary API | D3D11; verify active device and executable architecture |

An existing `src/games/thewitcher3/` already contains another implementation, including SM6 shaders and frame-generation paths. **Do not overwrite it or assume it is the requested Classic implementation.** Also preserve `thewitcher3remastered`, `thewitcher3remastered-hartapfel`, and the standalone Darker Nights and Motion Blur mods.

The checkout was dirty with substantial unrelated work when this handoff was prepared. Inspect Git status before editing; do not reset, clean, stash, stage, or commit unrelated changes. Local HEAD alone does not identify the current working Remastered implementation. Record the exact source files used as references.

Read root and applicable nested `AGENTS.md` instructions. Start from `src/games/generic`. Keep implementation changes inside the new game folder. Do not change global CMake presets, CI, vendored dependencies, or submodules without explicit approval. If shared infrastructure genuinely needs a fix, explain the concrete issue and scope before expanding beyond the game folder.

## 3. Required references and workflow skills

Read these before their respective phases:

- [Game development setup](../.agents/skills/setup-game-mod-dev/SKILL.md): existing DevKit connection, shader dumps, addon scaffold, deployment, and validation.
- [Resource and swapchain analysis](../.agents/skills/swapchain-resource-analysis/SKILL.md): source proof, format upgrades, output conversion, UI separation.
- [Tonemap and LUT handling](../.agents/skills/handle-sdr-tonemap-lut/SKILL.md): domain analysis, native matching, grading reconstruction.
- [DevKit MCP guide](DEVKIT_MCP.md): discover the current tool schemas rather than assuming historical tool signatures.
- [Game-folder guidance](../src/games/AGENTS.md): shader names, targets, and verification.

Use the analysis-graphing and HDR test-pattern skills when producing numeric plots and synthetic tests. Use the HDR PNG skill if exporting PQ PNG comparisons.

Two task-specific overrides are essential:

1. Some shader skill examples use **PsychoV17**. This task explicitly requires the current **game-local custom PsychoV31** implementation; do not substitute a different PsychoV version or RenoDRT as the custom mapper.
2. Build and deploy **Release** using the established Clang release preset, per repository/user instructions. Do not deploy a Debug game addon merely because an older skill example uses Debug.

Classic DX11 shaders are expected to be DXBC/SM4–5; inspect the actual bytecode. Use DevKit's DXBC decompiler route and the appropriate FXC-compatible compiler target. The DXIL decompilation skill and DXC SM6 decompiler are **not** the correct route for DXBC. Do not convert Classic replacements into SM6 shaders that DX11 cannot execute.

## 4. First session: discover before editing

The user intends to leave the game running with DevKit. Initially perform read-only capture and analysis; there is no need to close the game just to inspect it.

Establish and record:

- Executable path, version 1.32, store/install location, architecture, active D3D11 device, and actual ReShade binary directory.
- Loaded ReShade/DevKit versions and addon list. Confirm the unmodified-game baseline; record any active ReShade effects separately.
- Display capabilities, Windows HDR state, current resolution, fullscreen/borderless mode, and sensible peak/reference-white values.
- DevKit connection, tools path, DXBC decompiler availability, dump path, and live path.
- Initial scene/save, camera position, time/weather, game gamma, and graphics settings needed for repeatable comparisons.

Resolve the executable from the running process or DevKit first. Do not accidentally use the Remastered installation's `bin/x64_dx12` directory. Steam app identity alone cannot distinguish the intended installation/version.

Select the device with actual game draws/resources, not an initialization-only device. Capture a baseline frame and relevant resource readbacks before replacing anything. Record both shader hashes and draw/resource relationships; a hash match or successful replacement log alone does not prove the intended draw uses the replacement or receives updated constants.

Suggested captures over the course of development: a bright outdoor scene, sun/sky, warm candle/fire interior, dark cave, inventory/character screen, dialogue, loading/video, map/pause, and Witcher senses. Begin with the currently loaded scene and ask for further scenes only when needed to verify a concrete path.

## 5. Map the real Classic pipeline

Trace backward from presentation through UI/composition, post-processing, LUT sampling/building, native tone mapping, exposure, bloom, and scene rendering. Do not assume they occur in that order or in separate shaders.

For each relevant pass, record:

| Evidence | Required detail |
|---|---|
| Shader identity | CRC32, stage, profile, entry point, original bytecode path |
| Bindings | Constant buffers, SRVs, samplers, RTVs/UAVs and slots |
| Resources | Formats and view formats, dimensions, mips, samples, flags, aliases |
| Signal | Linear/encoded/packed, primaries, exposure state, numeric range |
| Operations | Tone curve, clamps, LUT addressing, grading, blending, alpha meaning |
| Lifetime | Producers, consumers, copies, resolves, reuse, recreation |
| Coverage | Gameplay/menu/video/quality-setting variants that use the pass |

Prove where usable scene HDR exists. Read back the candidate input and demonstrate preserved range or identify the earlier limitation that must be removed. A floating format alone does not prove scene-linear HDR, and values above one may also represent an encoded signal.

Locate every destructive step relevant to the new path: `saturate`, hard clamps, bounded LUT coordinates, SDR tone mapping, UNORM writes, sRGB conversion, lower-precision copies, and output quantization. Preserve deliberate masks, alpha, fades, and non-colour data instead of removing all clamps indiscriminately.

**Do not implement HDR by stretching or inverse-tonemapping the completed SDR backbuffer.** Preserve the actual upstream scene signal and perform forward display mapping. A final presentation pass is appropriate for encoding a proven HDR intermediate, not inventing missing highlight detail.

## 6. Dump, decompile, and establish equivalent baselines

Use DevKit MCP's dump/decompile operations first. Discover the current tool schema; do not invent tool names or hand-reconstruct original shaders from screenshots.

Keep the original bytecode and decompiled baseline outside the mod folder. Recommended layout:

```text
<game binary directory>/renodx-dev/dump/          # normal DevKit dump destination
tmp/witcher3classic-investigation/<capture-id>/
  originals/                                   # immutable .cso + decompiled HLSL
  captures/                                    # resource readbacks, metadata
  validation/                                  # replay results, curves, diffs
  manifest.json                                # provenance and relationships
src/games/thewitcher3classic/
  addon.cpp
  shared.h
  metadata.json
  README.md
  tonemap/                                     # selected helpers/replacements only
  grading/
  output/
```

`tmp` is a suggested investigation location, not a committed deliverable; verify its ignore status and keep needed local evidence until testing is finished. Preserve original filenames/profile/hash and record source capture/time and checksums in the manifest. Never edit the sole original copy.

The build recursively discovers shader sources and `.cso` files. Therefore, **do not put originals in an `originals/` subfolder under `src/games/thewitcher3classic`**, and do not use that archive as DevKit's live path. A subdirectory alone does not exclude it. Keep live experimental baselines in a separate, deliberate folder before the production mod exists.

Copy only a selected editable replacement into the addon folder, using the repository's `{CRC32}.{TARGET}.hlsl` naming convention and the actual DX11-compatible profile. Include files should use `.hlsli` where appropriate so helper code is not mistaken for an entry-point shader.

For every replaced native shader:

1. Capture original input/output, constants, samplers, and render state.
2. Decompile, repair only decompiler errors, and compile for the appropriate DXBC target.
3. Replay or live-test the unmodified replacement against the original using the same inputs.
4. Check channel order, signed values, precision, matrix layout, sampling/LOD, alpha, masks, and render-target semantics. Compilation alone is not semantic verification.
5. Only after equivalence is established, add narrowly scoped custom logic while retaining a readable vanilla branch.

Do not assume live replacement works when another addon is already replacing those shaders. If it does not, use DevKit-only baseline capture and offline replay, followed by a compiled-addon restart test. Previous Remastered work encountered exactly this limitation.

## 7. DX11 resource upgrades and output

Expect to need resource upgrades, but choose them from the captured chain rather than upgrading every UNORM texture. Some native scene buffers may already be floating point.

Upgrade the minimum complete HDR-critical chain to suitable formats, commonly RGBA16F when signed colour and headroom are needed. Account for all associated SRV/RTV/UAV formats, typeless/sRGB views, blend behavior, multisampling, copies/resolves, mip levels, clears, and later consumers. A colour resource and a data/mask resource with identical dimensions must not be conflated.

DX11-specific requirements:

- There are no D3D12 root signatures or register spaces to copy from the Remastered addon. Use the repository's DX11 injection path with a **proven unused constant-buffer slot** in each affected stage/path.
- Do not blindly use `b13, space50`. Inspect native bindings, verify payload layout/alignment, and preserve/restore native bindings as required by the shared utility API.
- Verify immediate/deferred-context behavior, command-list execution, device and swapchain recreation, and actual per-frame settings updates.
- Use established resource/swapchain utilities rather than custom broad API hooks where possible. Do not add per-draw global scans, GPU readbacks, or CPU/GPU waits to the shipping path.
- Validate every upgrade's consumers. Format-changing copies and resolves cannot simply be assumed legal.
- Keep tracking and lifecycle state scoped to the correct device and addon. Do not retain stale resource handles across recreation or collide with other RenoDX addon private data.

Prefer a floating intermediate/proxy with an HDR10/PQ presentation path if supported and validated. Use the existing `SwapChainPass`/swapchain abstractions where suitable. scRGB is a compatibility alternative if there is a concrete need, not an automatic consequence of using float intermediates.

Document the working domain and scale after each pass. Encode PQ/BT.2020 only at the appropriate output boundary; do not PQ-encode an intermediate that later game shaders treat as linear or gamma RGB. Coordinate output format, DXGI colour space, metadata, and shader output preset. Avoid double gamma/sRGB conversion and double reference-white scaling.

Keep UI, subtitles, menus, and video SDR-shaped with deliberate brightness. Audit straight versus premultiplied alpha and the blending domain. Preserve post-process ordering and native bloom energy; do not silently apply PsychoV again to already mapped UI or scene output.

## 8. Vanilla mode contract

Vanilla means the game's **original SDR look without custom grading or effect overrides**, presented through the selected output transport. It is not a third custom tone curve, not PsychoV at an SDR peak, and not an inverse-tonemapped SDR image.

- Retain original tone mapping, native LUTs, native colour grading, exposure, effects, and their game-controlled parameters.
- Bypass all custom Color Grading and PsychoV controls; hide or disable them consistently. Preserve their stored values for switching back to PsychoV.
- When upgraded intermediates remove original UNORM clamps or sRGB behavior, reproduce those original boundaries only in the vanilla branch where necessary for visual fidelity. Do not reuse these clamps in the HDR reconstruction path.
- If Vanilla is displayed through HDR10, decode the game's SDR encoding correctly, map SDR reference white deliberately, and perform the final HDR transport encoding. The user allows this; do not claim the swapchain or PQ output bytes are untouched SDR.
- Verify the SDR appearance against addon-disabled captures in a common decoded domain and with matched reference white. Native quantization differences from float upgrades should be measured and disclosed rather than concealed.
- Ensure the mode switch affects LUT builders and cached outputs too. A LUT generated while PsychoV is active must not remain a custom LUT when Vanilla is selected. Determine whether native rebuild events, explicit invalidation, or mode-independent LUT construction solves this best.

Prefer runtime switching once upgrades are established. If a genuine resource-lifetime constraint requires restart, explain it and label the behavior; never show a mode as active when the underlying path has not switched.

## 9. Reuse PsychoV31 deliberately

Read the current working sources, not only Git HEAD or a historical download:

| Reference in `src/games/thewitcher3remastered/` | What to inspect/reuse |
|---|---|
| `tonemap/customtest31.hlsli` | Custom31 response implementation; distinguish `custom_psychotm_test31` from other entry points |
| `tonemap/custom31_base.hlsli` | Required math, matrices, and response helpers |
| `tonemap/psychov_tonemap.hlsli` | Production integration, anchored grading, native-contrast adapter, saturation, highlight hue, blowout |
| `tonemap/psychov_gamut.hlsli` | Game-local cone-input protection and display gamut fitting |
| `include/common.hlsl` | LUT-domain compression/reconstruction and near-zero inverse stabilization |
| `grading/lutsampling.hlsl` and grade shaders | How native grading is retained; not evidence of Classic's LUT domain |
| `tonemap/agx_tonemap.hlsli` and native tonemap shaders | Reference for matching methodology only; AgX parameters are Remastered-specific |
| `addon.cpp`, `shared.h` | Real controls, ranges, defaults, enum translation, CPU/GPU field contracts |

Port the needed implementation into the new game folder with attribution intact. Do not include the Remastered addon, import all its shader registrations, or make Classic depend on its game-specific `shared.h`. Audit transitive includes and SM5 compatibility. Keep shared library usage where it already works, but avoid a new shared-framework refactor for this task.

Remastered's production wrapper contains important fixes beyond the originally attached custom31 source. Preserve their intent:

- Apply tonal grading once in the appropriate luminance domain before the observer/display response, rather than independently driving cone channels into mismatched plateaus.
- Keep signed-colour handling finite; saturation zero must end in neutral grayscale without leftover green or other chroma.
- Use the tested display gamut fit so compression does not turn warm fire/sun highlights pink or create sharp transition bands.
- Keep smooth, monotonic highlight behavior, a finite near-black/LUT inverse, and sensible output at extreme input values.
- Preserve the intended highlight hue response and full-grayscale Blowout endpoint.

Do not blindly retain Remastered-specific Natural-curve normalization, its 1000/203 reference-peak branch, native AgX extension, shader-dependent exposure compensation, or native HDR detection. Classic has no native HDR; derive addon output state from the actual chosen presentation path.

`psychov_gamut_compression_mode` in the reference is a target-gamut selector, not the compression amount or the response-shoulder strength. The current UI maps BT.709 to 0, BT.2020 to 1, and Display P3 to internal value 3. Verify this against the copied functions. The production wrapper disables the internal mapper's gamut fit and applies its own game-local fit: do not accidentally enable both and compress twice.

## 10. Match Classic contrast without losing HDR range

The user chose Classic-native contrast, not the Remastered Natural look. First identify the actual Classic native curve, exposure application, and contribution of LUT/analytic grading. Native matching must not mean applying a fully bounded SDR curve and then applying PsychoV to that clipped result.

Measure black/toe, middle-gray response, local contrast, and shoulder using captured constants and neutral ramps. Prefer analytic derivatives if the curve is identifiable; otherwise sample the real shader. State whether the selected anchor is input middle gray, output middle gray, or an inflection point. They are not interchangeable.

A local log-slope quantity such as `x * V'(x) / V(x)` can guide matching only where the chosen response parameter genuinely represents that quantity. Do not equate it automatically with a similarly named custom31 parameter. Verify the composite Classic-to-PsychoV transfer function numerically and visually.

Use a measured, bounded-gain or unbounded native-contrast formation that preserves usable scene ratios and leaves the final display shoulder to PsychoV. Separate exposure matching, contrast matching, native grading, and display mapping so none is applied twice. Compare the whole result to Classic, not just an isolated analytic curve.

Keep exact zero input at zero in the custom mapping and retain small positive shadow differences. If Classic's native grade introduces a pedestal, distinguish that from one introduced by the addon; explain a proposed correction instead of silently forcing a creative black-floor change. No inherited Remastered Black Floor slider is required for the starter UI.

Test peak settings at 400, 1000, 4000, and 10000 nits. Sufficiently bright neutral ramps should approach the configured peak smoothly without premature internal ceilings, steps, or broad hard plateaus. A real sun pixel is not required to reach exactly peak at every exposure. Saturated target-gamut colours can also have luminance below peak legitimately; do not whiten every highlight simply to satisfy a maximum-nit reading.

## 11. LUTs and native colour grading

Discover both LUT production and LUT consumption. Preserve scene/weather/interior-dependent blending, masks, user/game strength, and cached LUT behavior. Do not assume there is exactly one LUT or that the builder contains only colour grading.

For each LUT, establish dimensions/layout, input/output encoding, shaper, sampling coordinates, edge handling, half-texel offsets, interpolation, and native clamping. Separate baked tone mapping from baked grading; otherwise replacing the scene tone curve while leaving it baked into a LUT can apply it twice.

For PsychoV, bridge bounded LUT domains using a proven neutral proxy and reconstruction around the real scene signal. Preserve intended Classic grading without sacrificing HDR range. Do not hard-clamp scene RGB to `[0,1]` and call that an HDR bridge. Preserve signed channels until a deliberate gamut operation requires otherwise.

The exact Classic pass ordering must come from capture. Prefer the reference's scene-preserving grade followed by one final display mapping when the signals support it; if a different bridge is necessary, document domains and show equivalent neutral/default behavior. Do not introduce an additional RenoDRT tone curve merely to reuse a convenience helper.

At near-zero luminance or opposing signed channels, bound inverse reconstruction and chroma amplification. Test the character/inventory screen specifically: the Remastered path previously produced white noise here that disappeared at LUT strength zero.

For this first version retain native grade at full strength by default. Do not import the Remastered selective pink/red Color Grading Hue Shift at 25, alternate saturation-method selectors, or split grading-luma/chroma controls. Those are separate artistic features, not part of a clean Classic-native baseline. PsychoV's internal **Highlight Hue** is a different control and belongs in its own section.

## 12. Initial settings contract

Use a small, clearly labeled menu. No Prism, Vanilla+, AgX selector, Natural-curve selector, developer matrix editor, unrelated effects section, or preset-tab complexity is needed. Short tooltips should explain practical effects. All defaults must be visible in code and reset consistently.

### Tone Mapping

| Control | Initial behavior |
|---|---|
| Tone Mapper | Vanilla / PsychoV-31 (Custom), PsychoV default; use new explicit mode constants rather than retaining Remastered's numeric mode 3 by accident |
| Peak Brightness | In nits; display-derived default if reliable, otherwise 1000 as a documented fallback; meaningful only for custom HDR mapping |
| Game Brightness | Diffuse/reference white in nits; start at 203 for HDR unless measured presentation requires a documented alternative |
| UI Brightness | Start at 203 nits when independent UI scaling is proven; do not expose a nonfunctional or scene-wide substitute |

Keep a deliberate SDR reference-white policy for Vanilla-in-HDR presentation. Do not let the custom peak slider stretch the vanilla image into HDR highlights.

### Color Grading

Begin with Exposure, Highlights, Highlight Contrast, Contrast, Shadow Contrast, Shadows, Saturation, Highlight Saturation, Blowout, and Flare where the actual custom31 path supports them. Reuse the reference's established ranges and UI-to-shader mappings, with neutral defaults: Exposure 1, ordinary multiplicative controls 1 internally (typically 50 in the existing UI), Blowout 0, Flare 0.

These are custom user grading controls; they do not replace the requirement to retain the game's native LUT/grade. Apply each exactly once. Disable/hide this section in Vanilla. If a control cannot be implemented meaningfully in the proven pipeline, omit it and report why rather than shipping a disconnected slider.

### PsychoV-31 (Custom)

| Control | Reference starting value / behavior |
|---|---|
| Adaptation Anchor | 0.18; reference range 0.01–0.5 |
| Background Anchor | 0.18; reference range 0.01–0.5 |
| Highlight Hue | Reference default 100/100; shoulder-weighted response/source hue blending, not a global hue rotation |
| Gamut Compression | 1.0; range 0–1 |
| Compression (0 = Auto) | 0; reference range 0–5; separate from gamut-compression amount |
| Gamma | 1; reference range 0.5–2; luminance gamma, applied once |
| HDR Gamut Target | Display P3 starting default; BT.709 / BT.2020 / Display P3 choices |

Use these as implementation starting points, then validate native matching. Do not alter defaults solely to make a test scene more vivid. Hide this section in Vanilla. If a true SDR display path is supported, fit to BT.709 there and make the HDR-only target selector inactive.

Do not resurrect removed experimental controls such as Source Boundary, Source Awareness, alternate Gamut Mapping, or SDR EOTF Emulation. Do not add an old PsychoV30 Cone Response slider unless the current custom31 implementation has a real, validated parameter for it. Keep source licenses and credits.

## 13. Validation gates

Complete each gate before declaring the next phase successful. Keep original captures and a short record of settings, code/artifact identity, and results.

| Gate | Required evidence |
|---|---|
| Original baseline | Captured native resources, constants, and SDR output; no custom replacements |
| Decompilation | Original vs recompiled output comparison at the same inputs; no semantic regressions |
| Resource chain | Actual upgraded formats/views and legal copies/resolves; preserved HDR values through all required intermediates |
| Injection | Every exposed control demonstrably changes the intended output; matching CPU/HLSL layout; no native slot collision |
| Vanilla fidelity | Original SDR look, native effects and LUTs, custom controls bypassed; repeated mode changes and cached-LUT behavior correct |
| Native matching | Captured Classic curve/grade comparison around black, middle gray, skin, and diffuse materials |
| Highlight response | Neutral and coloured exposure ramps, smooth value/derivative transitions, no fixed sub-peak ceiling or artificial hard clip |
| Gamut | Compression 0/intermediate/1; BT.709/P3/2020; warm fire/sun stay warm, no pink blowout or visible compression rings |
| Grading | Saturation 0 yields grayscale, Blowout endpoint neutral, other sliders continuous and finite, no double grading |
| LUT robustness | Neutral/strong grade, weather changes, dark/signed inputs and inventory; no white noise or unstable inverse |
| UI and lifecycle | Inventory, character, map, pause, dialogue, loading/video, senses; resize, alt-tab, reload and clean exit |
| Shipping path | Restart with only the new game addon; works without DevKit/live files; check coexistence separately afterward |
| Performance | Stable CPU/GPU cost, no shipping readbacks/stalls, no unexpected per-draw work or sustained-play regression |

Use deterministic neutral ramps, warm emissive ramps, wide-gamut/signed-colour cases, and near-black inputs for numeric checks. Inspect first derivatives around any bridge/gamut threshold as well as output values. Test the integrated native grade/LUT/PsychoV/output pipeline, not only the standalone tone curve.

Separate synthetic proof from live visual confirmation. A successful build, replacement log, or bounded RGB result alone does not prove the scene looks correct. Capture before/after at the same exposure and camera; establish luminance in decoded HDR values instead of inferring it from an SDR screenshot.

## 14. Build, deploy, and final handoff

Use the smallest target. With the repository's established build environment configured, the expected command is:

```powershell
cmake --build --preset clang-x64-release --target thewitcher3classic
```

If the new folder requires reconfiguration, use the existing `clang-x64` configure preset and toolchain setup. Confirm actual output location and shader embed contents. Do not change global presets to work around a local setup issue.

Do not rebuild the loaded game addon while the game is running. Capture inputs and do offline preparation first, then ask the user to close it when a rebuild/deployment requires that. Preserve existing loaders/addons/settings; back up any known file being replaced and never silently deploy a Remastered DLL into Classic.

Add minimal metadata for Classic, DX11, the verified executable path pattern, architecture, and deployment identity. Give it a distinct settings identity so Classic does not inherit Remastered presets. Confirm whether the current settings utility requires a dedicated configuration namespace or section in addition to the displayed addon name.

At completion provide:

- The Release `.addon64` path and checksum/build identifier.
- Installation instructions for the verified Classic binary directory.
- A concise list of replacement hashes, their roles, and required resource upgrades.
- The measured native-matching/grade strategy and output colour-space/reference-white policy.
- What was tested offline and in-game, plus any remaining limitations or untested variants.
- A short mod-local README with mode behavior and basic use, not the entire research archive.

If live testing is blocked, state exactly what remains unverified and request the smallest necessary user action. Do not claim completion based only on shader compilation, and do not compensate for a missing upstream signal with a final-SDR inverse-tonemap shortcut.

## 15. Remaining discovery items and reference provenance

The user has answered the design questions: unmodified Classic 1.32, Vanilla SDR appearance may use HDR transport, and PsychoV should match Classic's native contrast. The executable/install path, display capabilities, and current DevKit/ReShade configuration remain to be discovered from the running environment. Ask only if they cannot be inferred reliably. No further artistic decision is required before beginning capture.

Reference SHA-256 values below identify the working files inspected for this handoff. They are provenance, not instructions to discard newer fixes. If they differ at implementation time, review the differences before selecting the port baseline. All paths are under `src/games/thewitcher3remastered/tonemap/`:

```text
psychov_tonemap.hlsli
AB21C4E212C8EEABD50A2F53B7B3D9E538FDDEACC1112659AD526E55EF5A0B57
psychov_gamut.hlsli
2713C71D831AF496F8B9B37CDA97DA2FF5FA8604AD580CE978163FE0FC1C98C7
customtest31.hlsli
1C2ECBD9682AA941529FFD8AD9C25BF8C692A988009BBF1FCCF3CA21B3026FCA
custom31_base.hlsli
6C3D80855B8DA669AFCDC153271251247BACE86D6C596BD9186A342A51080AAA
```

Suggested first action for the implementation agent: read the applicable instructions and skills, inspect the existing DevKit connection, identify the Classic 1.32 device/executable, and save the original scene/output/LUT chain before creating any replacements.

## 16. Temporal-input tooling checkpoint (2026-10-22)

The HDR mod is implemented and has received user testing. The current task is
proper replacement TAA/DLSS. Keep the removed Hue Shift experiment and the
reverted reflection/sky unclamps removed. This section records investigation
evidence, not instructions to enable an unvalidated AA backend.

At the user's request, input capture now lives in DevKit instead of the game
addon. `src/addons/devkit/d3d11_capture.hpp` provides bounded, opt-in capture via
`devkit_capture_shader_inputs`. See `docs/DEVKIT_MCP.md` for the MCP schema,
limits, asynchronous readback and preserved texture analysis. The temporary
Classic capture button, shader callback and upload hooks were removed. Native
TAA is still running; no replacement TAA or DLSS is enabled.

Release `devkit`, `thewitcher3classic` and `mcp_bridge` built successfully with
`clang-x64-release`. Existing game-folder links point at those Release addons.
Native WARP regression tests passed, including source reuse, D3D11.1 CB ranges,
signed motion/depth decoding, preserved textures and bounded timeout. The
user relaunched and supplied stationary and moving-camera scenes. Live DevKit
captured 32 frames for each; every CB readback completed. Captures may skip
render frames when the bounded staging queue is full; use recorded frame IDs.

Verified native TAA shader: `0x201C53B4` (`ps_5_0`). At 3840×2160:

- b3 is 400 bytes; row 0 is `[1920,-1080,1919.5,1079.5]`.
- b10 is 2880 bytes; rows 78–81 are the native camera reprojection matrix.
  Stationary values are essentially identity; all 32 moving matrices differ.
- b10 row 0 alternates `[0.25,0.25,0,0]` / `[-0.25,-0.25,0,0]`.
  Row 45 carries the opposite previous-frame values. Projection offsets in
  b12 row 15 agree: x ±0.5/3840 and y ∓0.5/2160. Native jitter exists; do not
  implement an unrelated second camera-jitter system without tracing this one.
- b12 is 4304 bytes; row 22 is `[-1,1,0.2,5000]`, so the TAA shader remaps raw
  hardware depth as `1-depth`. Row 23 supplies dimensions and reciprocals.
- t0/t1: full-resolution R11G11B10F current color/history. t2/t3: R16F history/
  current luminance. t4: R24G8 typeless hardware depth with R24_UNORM_X8 SRV.
  All five were preserved before the draw and successfully analyzed/exported.

Raw captures, EXRs, tests/build logs and exact artifact hashes are in ignored
`tmp/witcher3classic-investigation/temporal-dev/`, including `devkit-live/`.
The existing analysis response's `snapshotExact:false`/live-resource note is
legacy metadata; for this new path, `capturePoint:before_draw` and
`preservation:copied_before_draw` identify the owned shader-input copies.
Do not confuse ordinary live handles with `preservedResourceViewHandle`.

Ghidra is installed and has decompiled native render functions. The project
and scripts are in the same scratch folder. Initial whole-program analysis
timed out, so some function boundaries/strings remain incomplete. Resolve
chained unwind entries before decompiling a stack-derived address. The
correct postprocess parent `0x140c55020` and render parent `0x140c1c910` are in
`camera-decompiled.txt`; the former selects a shader table via global
`0x142bcbb48` (not a proven camera-state pointer). Executable hash is recorded
in the investigation; never apply offsets to an unverified binary.

Next: trace the native jitter producer and geometry/skin previous transforms,
prove dense object-motion coverage and depth/jitter conventions, then integrate
replacement resolve/DLAA before upscaling. No zero-motion or camera-only
fallback should be presented as proper DLSS. Shipping AA must not use these
diagnostic CPU readbacks.

## 17. Native DX11 DLAA camera prototype (2026-10-22)

The game addon now includes `temporal/{camera,context,prepare,dlss,runtime}.hpp`
and three private GPU shaders. Advanced → Anti-Aliasing offers Native TAA
(default) and DLAA Camera Test. The latter intercepts native TAA shader
`0x201C53B4`, prepares FP16 color/raw depth/normalized camera motion/responsiveness
on the GPU, evaluates NGX directly on the existing DX11 device, and converts
the output to the native TAA target. All native context state is isolated and
restored. There is no DX wrapper, helper process, synchronous readback or CPU
geometry replay. Switching back to Native TAA releases the feature/resources.
The user explicitly approved adding Classic to the existing CMake NGX-link
condition. Runtime DLL/license live in the game's own
`bin/x64/renodx-witcher3classic-dlss` subdirectory.

This remains an explicit camera-only development test, not completed DLSS.
Animated-object vectors, broader jitter sampling, camera-cut handling and
reduced-resolution scene rendering still need implementation/validation.
The backend supports DLSS Quality dimensions in its synthetic fixture; the game
UI only exposes native-resolution DLAA. Do not downsample a completed full-size
scene and claim DLSS rendering performance.

Correction to section 16: the TAA-producing postprocess function resolves via
chained unwind entries to `0x140c48810`. Its complete Ghidra decompilation is
`taa-long.txt` in investigation scratch. The 2880-byte native b10 CPU shadow is
at preferred address `0x142ccb750` (RVA `0x2ccb750`). All 720 raw words matched
the captured bound GPU CB on two frames. Read-only access in `camera.hpp` is
guarded by PE timestamp, image size and two code fingerprints for the known
GOG executable. Native jitter is opposite raster displacement, so NGX
right/down pixel jitter is `-b10[0].xy`. The current prototype reuses it.

Motion Blur was inspected while enabled at the user's request. Its shader
`0xC3F99418` reconstructs camera motion from depth/matrices and a stencil input;
it does not expose dense animated-object velocity. The meaning/coverage of its
stencil flags is not sufficient to assume an animated-object mask. Skinned
vertex shaders include `0xF507139A`, `0xC3168D61`, `0xE4756453`: structured bone
SRV t0 (64-byte stride), instance palette base/stride, and instance transforms.
Geometry ownership/history must be traced before treating palette offsets as
persistent IDs. DevKit now optionally captures selected buffer SRVs and bound
VB prefixes plus draw/index metadata for this investigation.

Actual NVIDIA GPU fixture `tests/dlss.cpp` passed 64 evaluations across DLAA
640×360 and 1280×720, DLSS Quality 640×360→960×540, feature recreation, HDR
preservation, vector math, R11 output conversion, full state restoration and
clean shutdown. DevKit WARP tests pass buffer-SRV/VB offset/source-reuse cases.
In-game validation reported `DLSS input resource mismatch`: ReShade hooks
resource `GetDevice()` to return its proxy even for native-created resources.
`context.hpp::IsSameDevice` now unwraps the owner before comparison; the
regression fixture covers this proxy path and reference balance. Source and
object compilation pass; the corrected DLL still needs linking after game exit
and in-game verification. Release DevKit geometry-extension linking is also
pending because the game still held its DLL during the attempted builds.

## 18. Skinned object motion implementation (2026-10-22)

The user confirmed native DX11 DLAA initializes and runs correctly after the
proxy-device fix. Release DevKit geometry capture is now linked and live-tested.
The current task is proper object motion. Continue in-game validation and coverage.

Source adds temporal/object_{history,engine,motion}.hpp, HLSL helpers, three
extended native VS (F507139A, C3168D61, E4756453) and three PS (8EEE67C3,
280BDA85, 704D8556). Advanced AA now offers DLAA Development with Object Motion
on by default and a camera-only comparison toggle. Native TAA remains the
default AA mode. Source/objects compile; the object-motion DLL still needs
linking after the requested game exit and in-game verification.

Live capture proves 80-byte skinned IA slot 7 records, an 8 MiB structured bone
SRV with 64-byte matrices, and actual draw arguments. Static instances use 64
bytes. The shared 4 MiB instance ring advances/wraps; its offsets are not IDs.
Native bone packing can also move offsets. Ghidra identified:

- 140c5afa0: instance assembly; context+18 points to render object, whose +40
  contains the world matrix and +180 references the skinning allocation.
- 140c5bcb0: copies allocation+20 palette data into the instance skinning fields.
- 140c66690 / 140c66790: map/fill frame bones. Resolve chained unwind entries
  for the latter: c667c0 is an interior chunk, not a function boundary.
- 140c669c0: allocation unregister/destruction; invalidates history.
- Renderer = *(*(image+2bcbb48)+b8). Its array/count are +58/+60 and critical
  section +30. Allocation+1c = bone count, +20 = current base, +38 = pose storage.
  A diagnostic read-only snapshot saw 696 allocations. External process reads
  are investigation only, not the runtime path.

Two fingerprinted hooks observe instance worlds and allocation frees without
modifying native data. Installation enrolls process threads in Detours and pins
the module, following Ezio's engine-hook precedent. Hook state has process
lifetime with no GPU/ReShade ownership. Disable makes them inactive forwarders
and clears CPU history; device destruction also disables.

GPU copies retain previous bones and camera/frame constants. Current palette
bases index compact previous-world/palette entries matched by allocation
identity, storage, bone count and consecutive frame. Shared skeletons with
conflicting worlds reject history. E4756453 also retains reference textures.
RG16F motion and signed R32F surface depth are written beside the native G-buffer
in the same draw. Extra output/blend/input bindings are restored. The actual TAA
depth resource gates main-scene geometry, excluding shadows/offscreen targets.
Preparation merges depth-matching object vectors; missing history sets bias to
current color. Other pixels use camera motion. No runtime readbacks, waits,
helper processes or extra geometry draws.

CPU allocation/root-history tests pass. A native D3D11 WARP fixture compares
all nine extended VS/PS combinations against exported original bytecode,
preserving three G-buffer outputs and checking bone/root/camera motion, palette
repacking, reference blending and state restoration. GPU merge tests cover
occlusion and unavailable-history bias. All pass. It caught/fixed a signature
order regression: PS must retain TEX0-3, position, TEX10-11 order matching VS;
prepending new inputs misrouted normals. All 64 NVIDIA DLAA/DLSS/HDR/state
regression evaluations pass with the updated preparation shader.

After link/relaunch, expect the log 'skinned object motion active' with draw/pose
counts and matching overlay status. Check stationary-camera animation, walking,
occlusion and the Object Motion comparison toggle. Rigid moving props,
vegetation deformation, alternate geometry/material shaders and transparent
effects remain to investigate. Native two-sample jitter, camera cuts and real
reduced-resolution rendering also remain unfinished. Development inputs remain
explicitly marked; do not claim complete DLSS or validated full motion coverage.

Coverage extension before deployment: audited all 87 tracked VS and separated
shadow-only skinning from scene draws. Nine native VS families and nine PS cover
all 102 skinned G-buffer draws in the captured snapshot. The profile table is
object_shaders.hpp; registration and native signature compatibility use it.
The expanded GPU fixture passes all 21 compatible shader pairs (including the
alpha-tested families), native RGB/normal/specular equivalence and object motion.
Show Object Vectors is an optional GPU-only view, off by default; its shader
replaces the final diagnostic blit, with no extra work when disabled. Coverage
still does not establish rigid-prop, wind or transparent-effect vectors. The
first object-motion Release DLL was linked and loaded, but the user reported no
vector display or object-motion effect. Live DevKit capture on PID 43668 proved
the bone SRV uses `D3D11_SRV_DIMENSION_BUFFEREX` (11), whereas the initial runtime
gate accepted only `BUFFER` (1). This rejected all skinned draws before history
or motion output. The correction accepts either full structured view, with zero
first element and no raw flags. The GPU fixture now bootstraps with BUFFER and
runs all 21 shader pairs with BUFFEREX; all pass. The debug display no longer
silently selects normal DLAA when no object draw matched: it shows dark missing
coverage, and status includes the rejection reason/HRESULT. Its null-coverage
GPU regression passes too. Source/shader/object compilation passed; this
correction linked successfully in Release after game exit. Await relaunch/live
draw-count, previous-pose and vector-image checks before claiming it works.

Live follow-up: BUFFEREX correction produces the diagnostic image and logs
108 skinned draws, but most visible actors were amber and Geralt's head/handles
were absent. Read-only inspection of our own public `object_engine::state`
(Release PDB, no remote writes) found valid CPU histories. The older 32-frame
allocation capture shows 136/696 allocations rotate their pose-storage pointer.
`ObjectHistory::Previous` incorrectly rejected that rotation. It now relies on
persistent allocation identity, bone count, consecutive frames and destruction
invalidation. CPU/GPU regression fixtures cover rotating storage and unused
zero-weight bone indices.

Heads also use CPU-deformed geometry, not the bone SRV: VS 4B58810D, 8AF8354B,
27333F6F, 994B8494; PS 7C391002/ED00FAF7 add facial materials. Capture proves
UV slot 0 stride 8 and position/normal/tangent slot 1 stride 40; the position
buffer alternates each frame. Ghidra resolves the actual draw through
140c6f1c0 / 140c6f5c0 and the persistent actor callback 14116cdc0 (chained unwind
resolved; full decompilation in head-decompiled.txt). A third fingerprinted hook
sets thread-local actor identity only while that native callback runs.
`deformed_motion.hpp` keeps previous GPU positions/world CB under actor plus
immutable UV/index-buffer identity, bounds to 128 entries / 32 MiB, evicts unseen
entries, rejects replaced streams and uses no readback or extra geometry draw.
Native IA layout remains unchanged; SV_VertexID is appended after native inputs.
The history varying must be `nointerpolation` in VS as well as PS to prevent
packing it into native varying padding. The GPU fixture caught this and now
passes all 21 skinning plus eight CPU-deformed material combinations, native
G-buffer equivalence and previous pose/root/camera motion. Release object/shader
compilation passes; the revision is linking after the requested game exit.

User also requested sword handles, bushes, trees and other independent motion.
Those remain active work. Six captured SpeedTree VS / four PS originals and
decompilations are saved; grass capture proves per-model WindDynamicsCB b3
changes (native b0 FrameCB 784 B, b1 BaseTreeCB 480 B, b2 MaterialCB 352 B,
b3 WindDynamicsCB 288 B). Do not use camera-only vectors for wind animation or
claim those paths are already implemented. The latest rigid attachment capture
did not return before game exit; recapture its actual inputs after relaunch.

The CPU-face/body revision linked and was relaunched on PID 4056. Live log
reports 137 draws and 177 previous allocation poses; the vector image confirms
valid gray/colored body motion, replacing the previous amber actors. Geralt's
head remained dark because that scene introduced a previously uncaptured skinned
VS 4B5AEE17 / PS 9D1990B0. Its actual inputs are normal 80-byte skinned instances
and the full BUFFEREX bone view. Added that pair and skin VS 95D8CC2E / existing
C624927C; GPU equivalence and motion tests pass.

Rigid work now observes packed batches via fingerprinted 140c5a4f0, scoped in
thread-local storage around the unchanged original call. Instance assembly also
records non-skinned native object identities, mesh identity and root worlds.
`rigid_history.hpp` matches packed worlds to persistent object history and
rejects frame gaps, mesh changes, conflicting intra-frame transforms and
ambiguous coincident instances. `rigid_motion.hpp` uploads previous worlds only
for batches containing a known moving object; stationary batches keep camera
vectors and avoid the extra MRT/replacement work. Six VS are extended: 188F9E25,
9442ACB3, 13698E6A, 22EAAEDA, 55E8F3AA, 2894D9E0. Native draw capture confirms
slot 7 stride 64, indexed draw arguments and the batch call stack. GPU/CPU tests
pass, bringing total material comparisons to 45 (23 skinned, 14 rigid, eight
CPU-deformed). Frame status separates skinned/face/rigid counts; activation logs
include face and rigid paths. The user closed the game and the combined head /
rigid Release revision is linking. In-game sword/hero-head coverage is unproven.
Rigid object destruction/lifetime needs further audit; mesh/consecutive-frame
checks alone do not establish native object generations. Do not claim complete
or validated rigid coverage. Vegetation shader dumps and wind captures are saved
but wind motion implementation remains the next active task.

### 2026-10-22: forward skin, identity-palette props and motion stability audit

The forward/rigid revision linked at 21:13 and relaunched on PID 43032.
The native forward skin pair 60265FBA / 20C1C070 uses b2[7] for palette/stride
and b2[0..2] for world, rather than IA instance attributes. It renders one
opaque RGBA16F target against main scene depth. `ObjectMotion` now supports
that explicitly registered forward path, preserving one-target OM state and
UAVs starting at slot 1. Native vertex-output comparison and original G-buffer,
CPU-face, camera/object merge and state-restoration tests pass. Live logs
confirm forward skin and moving rigid draws. The debug capture shows head mesh
and long sword handles, but the user correctly reports missing hair, sword
pommels/guards, invalid mill/birds, and intermittent coverage while walking.
These observations supersede any earlier suggestion that the entire head or
sword coverage was complete.

The rotating mill was captured in F507139A with world position approximately
(66.055, 213.045, 32.685) and instance skin fields (0,0,0,1). The native bone
matrix at palette zero is identity. These are rigid objects rendered through
80-byte skin permutations, not animated bone allocations. Added previous rigid
world fallback to the skin vertex include using SV_InstanceID and t125/b8.
Only such identity instances populate the fallback GPU table. Nonmoving
64-byte rigid batches still use camera motion without replacement draws.
GPU test proves native RGB and .125 UV motion from prior root/camera, with
palette/stride zero. Bird and sword-pommel/guard fixes still require live checks.

Ghidra and native object vtable audit identify mesh render-object destructor
140cab210 (called by deleting destructor 140cae7e0). A fifth fingerprinted hook
invalidates rigid identities there; reused native addresses cannot inherit a
previous object's history. Observe only type-1 mesh render objects, including
null-allocation rigid meshes. Previously recorded non-mesh types have different
lifetimes. Allocation enumeration now skips unavailable individual palettes
rather than rejecting the whole registry; duplicate palette bases invalidate
only that match. These cases are regression-tested. Do not claim that every
reported intermittent coverage loss is already resolved.

Captured opaque hair is AB3E8304 / B18EC2FB: instanced skin, alpha discard and
one-target opaque output. Added this path with private TEXCOORD12/13 to avoid
native varying collisions, preserving native cutouts and shading. FF64C197 /
EB8C3FAE is an additional forward skin material. Decompiler raw loads t21/t20
were repaired from native DXBC. GPU stream-output comparisons pass every native
vertex varying and previous pose. F8635C4B is an observed array-texture G-buffer
material missing from group 5; added it to prevent coverage changing with that
material. These source changes are not linked yet. Soft hair F872850A /
FAB74FB3 is a separate premultiplied alpha pass and remains unimplemented.
Do not relax all blend/depth guards to label it covered.

### Documentation research and implementation consequences

Read the current [NVIDIA DLSS programming guide](https://github.com/NVIDIA/DLSS/blob/main/doc/DLSS_Programming_Guide_Release.pdf)
(revision 310.6.0, 31 March 2026), compared it with the checked-out 2025 copy,
and reviewed NVIDIA's [Streamline integration guide](https://github.com/NVIDIA-RTX/Streamline/blob/main/docs/ProgrammingGuideDLSS.md)
and [integration checklist](https://developer.nvidia.com/blog/how-to-integrate-nvidia-dlss-4-into-your-game-with-nvidia-streamline/).
Current guide PDF/text and captured evidence remain in ignored temporal-dev scratch.

- NVIDIA sections 3.6–3.8: resolve dense current-to-previous screen motion;
  keep units, jitter flag and inverted depth consistent. Our normalized UV
  vectors use NGX width/height scales, MVLowRes and unjittered vectors. DLSS
  dilates render-resolution vectors internally; do not add redundant dilation.
- Sections 2.2/3.7: the captured two-phase native jitter is below the documented
  phase coverage recommendation. A proper engine-wide jitter upgrade remains
  open; changing just NGX's supplied offsets cannot fix renderer sampling.
- Sections 3.13/3.15: scene-cut resets and per-pixel current-color bias have
  distinct roles. Avoid global resets for individual missing histories. Existing
  missing-history bias is a development fallback, not a substitute for valid
  object vectors. Actual camera-cut detection still needs integration.
- NVIDIA's Streamline guide requires correct per-frame resource lifetime and
  restoration of command state. Retain GPU histories, exact owned-resource
  identity and context isolation; no CPU readbacks or waits in the mod runtime.
- NVIDIA's checklist requires validation across materials and moving objects,
  plus unchanged native TAA-dependent setup. Keep native AA enabled and retain
  the native pass on integration failure. Do not mark motion_validated true yet.
- [Unity's motion-vector reference](https://docs.unity.com/en-us/engine/6000.6/manual/cameras/urp/motion-vectors/motion-vectors)
  distinguishes depth-based camera motion from per-object transforms and
  skeletal animation. [Godot's renderer description](https://docs.godotengine.org/en/4.5/engine_details/architecture/internal_rendering_architecture.html)
  describes evaluating previous vertex deformation in the main material pass.
  This supports our same-draw MRT design and previous-wind evaluation plan;
  camera reprojection alone cannot represent swaying vegetation.

Performance contract: one GPU bone-history copy per frame, bounded identity
and face caches, previous-world uploads for moving/identity batches, and motion
MRTs on the original draw. No extra full-scene geometry pass, optical flow,
runtime staging readbacks or GPU waits. Measure CPU/GPU costs once coverage is
stable; absence of these operations is not a measured performance claim.
Next: link/test current hair + identity/stability build; verify mill, birds,
pommels/guards, hair and walking NPCs. Implement wind deformation and explicit
soft-hair motion/depth composition, then engine jitter/camera-cut validation.


## Latest implementation and resume point: 2026-10-22 22:21 CEST

This section is the authoritative checkpoint for the next session. Preserve the
prior HDR and temporal integration; do not restart the investigation or replace
it with an external DX11 wrapper. The user requested documentation after the
next rebuilt fix so work can continue later. No commit, staging, cleanup of the
checkout, publishing or PR has been performed.

### Current artifact and user verification

- Target: `thewitcher3classic`; configure `clang-x64`, build
  `clang-x64-release`. Both game addon and installed DevKit are Release.
- Latest artifact: `build/Release/renodx-thewitcher3classic.addon64`,
  2,877,952 bytes, last written **2026-10-22 22:21:16 CEST**.
- SHA-256: `38E5FDDEE91BA6A6834C44486F6F71EBEB20B08C6EDF353DD262DA20051E73E1`.
- The game-folder `renodx-thewitcher3classic.addon64` is an existing symlink
  to this artifact. No manual copying or loader changes are needed.
- Game executable: `C:/Program Files/GOG Galaxy/Games/The Witcher 3 Wild Hunt/bin/x64/witcher3.exe`.
- The user closed Classic for this link. The artifact is ready; live verification
  of the new flock path remains the first next step. Re-discover any new PID.
- **User-confirmed before this build:** camera DLAA works; hair coverage is
  improved; mill-wheel motion is improved; nearby soldiers' faces are complete;
  sword fittings now look correct; the persistent-Apex-owner revision fixed
  the reported hanging cloth. The user said only birds remained at that point.
- **Bird distinction:** some birds already had valid motion, while others
  remained amber. Ordinary skinned birds and the instanced flock path must not
  be conflated. This build targets the latter; do not mark it user-confirmed.
- **Brief stationary motion:** the user saw Geralt show motion while apparently
  still, then saw it fade. We captured inputs and fixed a proven bone-math
  mismatch, but did not establish that mismatch as the cause of that specific
  transient event. Idle animation/camera motion and stale histories still need
  separate consideration if it recurs.

### What changed during the latest coverage work

1. **Additional material/vertex coverage.** Added rigid sword-fitting pair
   `465BBC10 / 30873571` in its own varying-signature group 13. Added reference
   forward skin `D9A50A38`, reference opaque hair `B0B4EB6F`, and forward pixel
   shader `30F033B5`. Existing forward shaders and G-buffer/face permutations
   remain registered. The complete source of truth is
   `src/games/thewitcher3classic/temporal/object_shaders.hpp`; avoid stale fixed
   counts in older notes. Per-profile acceptance/rejection logging is opt-in
   through Show Object Vectors, bounded to distinct reasons.
2. **Native bone-position convention.** The original DXBC uses element 15 for
   shading metadata, replacing it with 1 when transforming positions. The old
   previous-pose helper used the raw element as homogeneous W. Updated
   `TransformPreviousBone` to match the native position convention. A fixture
   with old metadata = 0.25 reproduced wrong vectors before the fix and passes
   afterward. This adds no geometry pass or readback.
3. **Direct sword-fitting draws.** A live capture of `465BBC10` showed a direct
   draw inside native `140c5afa0`, bypassing `140c5a4f0`/BatchHook. InstanceHook
   now scopes the native type-1 object; RigidMotion can obtain its world for the
   direct single-instance submission. Batched rigid draws retain their existing
   route. The GPU fixture exercises the fitting pair through this direct route;
   the user confirmed the swords after deployment.
4. **Rotating cloth buffers.** A temporary vector-view material diagnostic
   identified the hanging cloth as `8AF8354B / 628E4EBD`, a CPU-deformed path.
   Captured four successive draws: 8-byte immutable UV stream (6,824 bytes),
   40-byte positions/normals/tangents (34,120 bytes), R32 index buffer. Native
   positions AND indices rotated across three buffers. The old history key
   included the transient index-buffer pointer and assumed two position
   sources. Removed those addresses from identity; UV and position vertex
   cardinalities must agree. GPU copies still retain actual previous positions
   and world constants once per observed mesh/frame.
5. **Persistent cloth owner and lifetime.** Buffer identity alone did not fix
   every cloth: its PhysX render resource also rotates. Ghidra traced the
   persistent native Apex proxy through CRenderApexBatcher's renderer context.
   For the verified context vtable, DeformedHook now uses the type-9 game proxy,
   a destruction generation, and the immutable UV buffer. The common native
   render-proxy base destructor invalidates that owner generation. This avoids
   inheriting a destroyed actor's history. The user confirmed the cloth after
   this second revision. Ordinary face paths and their checks are preserved.
6. **Latest flock implementation (built, live test pending).** Added separate
   previous-world history per full native swarm slot and made palette history
   independent of a single instance world. The same shared previous bone
   palette can now serve birds with different previous worlds. Details follow.

### Flock implementation: native evidence and algorithm

Captured flock draw: VS `64BD97C5`, PS `B7B6FC64`,
`DrawIndexedInstanced(384, 9, 0, 0, 0)`. IA7 uses a separate 163,840-byte,
80-byte-stride native ring. The nine instances have different worlds but share
palette base 8,112 and stride 1. These are type-14 `CRenderProxy_Swarm` objects,
so the ordinary type-1 world observer cannot provide their history. Rejecting
one-world-per-palette ambiguity was correct; guessing a common world was not.

Ghidra/native findings:

| Native address (image base 0x140000000) | Role / proven fields |
|---|---|
| `140bc8a70` | UpdateSwarmData render command dispatch |
| `140caf0f0` | Swarm proxy stores data arrays at +0x118/+0x120 and population at +0x128 |
| `140caf250` | Full-array stride 44 bytes; visibility sort and LOD partition retain pointers into +0x118 array |
| `140c63310` | Walks linked submissions, reconstructs per-instance transforms, flushes native instanced draws |
| `1401fca80` | Native Euler-to-matrix helper, reused by observation rather than recomputed |
| `140bddc80` | Native indexed-instanced draw helper; consumes the recorded instance sequence |
| `140caf180` | Selects a bone allocation by swarm animation group/index; native return comes from `140cf43a0` |
| `140cefca0` | Common render-proxy base destructor; reached by mesh, Apex and swarm destructors |

The full raw array stores position xyz, Euler rotation xyz, uniform scale, sort
metadata and animation fields. Full slot = `(entry - data_begin) / 44`.
Visibility order and LOD indices are not persistent identity. The array pointer
itself rotates, so it is also excluded from identity.

- `SwarmHook` reads the native submission's selected LOD pointer lists before
  the function consumes them, verifies owner type/vtable, full-array bounds,
  alignment, counts and exact expected Euler-call order. Scratch vectors are
  thread-local and reused between calls. Unsupported structure/recursion fails
  closed rather than reusing another instance's history.
- `EulerHook` calls the original first, then observes its result only inside a
  verified swarm scope. Native composition is `T * R * uniform S`; the observer
  constructs its three packed rows from that existing rotation, scale and
  translation. It does not duplicate the native trig calls or hook global
  matrix multiplication/memcpy.
- `SwarmHistory` keys by native proxy + full-array slot; group and population
  changes reset that owner's cache. Repeated conflicting observations in one
  frame reject that instance. Gaps and owner destruction invalidate history.
  Limits: 256 owners, 8,192 full slots, maximum 4,096 slots/owner, with stale
  owners evicted after 120 frames when capacity is needed.
- `DrawHook` exposes the recorded prior poses only if the pending count equals
  the actual native instance count. It restores the prior scope after drawing.
  Native submissions and geometry are not replayed for motion.
- `ObjectHistory` now retains registered previous palettes even when no ordinary
  world was observed. `ObjectPose.palette_valid` is separate from `.valid`
  (ordinary world). Duplicate palette-base matches invalidate both flags.
- `RigidMotion` uploads the small per-draw swarm-world list through existing
  t125, setting b8's second word (`swarm_history`) to 1. Ordinary/identity-rigid
  batches use 0. The existing vertex helper selects per-instance previous
  worlds for swarms while using the allocation-keyed previous bones.
- No new motion render targets, geometry pass, GPU fence, CPU staging readback,
  optical-flow pass or separate dilation pass was added. CPU/GPU timing remains
  **unmeasured**. Do not present design constraints as benchmark results.

**Limits to verify:** the native full-slot contract is proven through the render
array and visibility/LOD path. Repopulation/reordering by the game-side producer
with an unchanged population is not yet audited. Test spawning/despawning and
LOD/culling transitions; add a real generation/reset source if needed. Also
verify the observer's packed rotation/scale against a live capture, not merely
synthetic matrices. Non-instanced and other bird shader families may still need
profiles. Do not globally force invalid histories valid.

### Current native-hook and GPU contracts

`object_engine.hpp` now installs **eight hooks** in one Detours transaction,
only after known-executable and entry-prefix checks. All process threads are
enrolled and the module remains pinned. Addresses listed below are RVAs:

| Hook | RVA |
|---|---:|
| Ordinary native instance observer | `0xC5AFA0` |
| Bone-allocation destruction | `0xC669C0` |
| CPU-deformed render-resource scope | `0x116CDC0` |
| Common native render-proxy destruction | `0xCEFCA0` |
| Ordinary packed-batch scope | `0xC5A4F0` |
| Swarm draw scope | `0xC63310` |
| Native Euler observer | `0x1FCA80` |
| Native indexed-instanced draw | `0xBDDC80` |

This replaces the earlier mesh-only `0xCAB210` destructor hook with its common
base destructor; do not install both accidentally. Apex context validation uses
vtable RVA `0x2151C00`, native type-9 proxy vtable `0x2153E78`, and context +0x28
as the current proxy. Swarm proxy vtable RVA is `0x2154338`. Native hooks remain
inactive forwarders when disabled; their CPU state owns no ReShade/GPU objects.

Previous-pose bindings: VS t120 previous bones, t121 current-base lookup, t122
palette/ordinary-world poses, t123 previous reference texture, t124 CPU-deformed
vertices, t125 previous rigid/swarm worlds; VS b8 metadata, b9 deformed world,
b10 previous view, b11 previous native frame; PS b12 native current frame.
Motion/depth append to MRT3/MRT4, preserving and restoring native targets,
UAVs, blend state, VS resources and CBs. The capture uses native geometry once.

Vectors are previous-minus-current normalized UV, unjittered, scaled by width
and height for NGX. Pixel jitter passed to NGX is the negative native jitter.
Main raw depth is reversed R24. Signed motion-surface depth distinguishes missing
history from uncovered pixels; the preparation pass compares final hardware
depth to reject occluded vectors and biases unavailable history toward current
color. Debug displays raw object coverage and has no final-depth merge; do not
infer that every raw debug pixel is consumed by DLAA.

### Source map

| File under `src/games/thewitcher3classic/` | Responsibility |
|---|---|
| `addon.cpp`, `shared.h`, HDR shaders | Established HDR/menu/effects integration; preserve |
| `temporal/runtime.hpp` | Shader callbacks, native TAA replacement, settings/status, draw post-callback |
| `temporal/camera.hpp` | Known-executable camera contract and read-only camera shadow |
| `temporal/context.hpp` | ReShade/native identity and full isolated D3D11 context restoration |
| `temporal/dlss.hpp` | Native DX11 NGX feature creation/evaluation/lifetime |
| `temporal/prepare.hpp`, private `F3C10001..4` shaders | Input prep, conversion and optional vector view |
| `temporal/object_engine.hpp` | Fingerprinted native hooks, CPU identity/lifetimes, swarm call scope |
| `temporal/object_history.hpp` | Allocation/palette and ordinary world history |
| `temporal/rigid_history.hpp` | Native rigid object histories and current-world batch matching |
| `temporal/swarm_history.hpp` | Native full-array swarm slot histories |
| `temporal/deformed_motion.hpp` | Stable proxy/UV/generation histories and GPU copies |
| `temporal/rigid_motion.hpp` | Existing rigid/swarm per-draw GPU table and metadata |
| `temporal/object_motion.hpp` | Draw validation, shared histories, MRT/state binding and frame commit |
| `temporal/object_vertex.hlsli`, `rigid_vertex.hlsli`, `deformed_vertex.hlsli` | Previous vertex position/clip evaluation |
| `temporal/object_pixel.hlsli` | Unjittered UV motion and signed surface depth |
| `temporal/object_shaders.hpp` | Authoritative native shader compatibility/profile table |
| `tests/object_history.cpp` | CPU identity/gaps/ambiguity/lifetime regressions |
| `tests/object_motion.cpp`, `tests/vertex_outputs.hpp` | WARP native-vs-custom geometry tests and stream-output comparisons |
| `tests/dlss.cpp` | Actual NVIDIA NGX backend/input/context regression fixture |

### Build and test results at this checkpoint

From an x64 VS developer environment with LLVM on PATH:

```powershell
cmake --preset clang-x64
cmake --build --preset clang-x64-release --target thewitcher3classic
```

Close Classic before linking this target when its loaded addon points to the
output. It is safe to compile object/shader targets while running, but do not
rename the addon to work around the DLL lock. Do not kill the active game.

Existing scratch runners, relative to the repo:

```powershell
cmd /c tmp\witcher3classic-investigation\temporal-dev\test-object-history.cmd
cmd /c tmp\witcher3classic-investigation\temporal-dev\test-object-motion.cmd
cmd /c tmp\witcher3classic-investigation\temporal-dev\deploy-object-motion.cmd
```

Tests passed with assertions enabled:

- CPU allocation/rigid/swarm histories: repacking, missing observations, gaps,
  ambiguity, count/group changes and owner destruction.
- Native G-buffer colors across registered compatible material pairs, including
  the new sword fittings and array-texture material.
- Previous root/bone/camera motion; metadata-in-bone-W regression; reference-pose
  blending; BUFFER and BUFFEREX views; identity-palette mill/attachments;
  direct rigid submission; individual inactive-allocation isolation.
- CPU-deformed face/cloth material pairs, three rotating position/index buffers,
  stable Apex owner across transient PhysX resources, generation invalidation.
- Native forward/hair **vertex varyings** and previous position via GPU stream
  output. This is not a full native forward-lighting pixel comparison.
- Two GPU bird instances sharing one palette with no ordinary world record,
  producing different correct UV vectors; native swarm-scope fixture with array
  rotation, reversed visibility order, proxy destruction and scope restoration.
- Context/MRT restoration, camera/object merge, opaque occlusion, missing-history
  responsiveness; D3D11 debug queue checked for errors by the GPU fixture.

The newest native-hook fixture uses controlled native-call substitutes; it does
not prove that the new hooks have executed correctly in the live game. The
existing actual-NVIDIA NGX fixture previously passed 64 evaluations; it was not
rerun after each coverage edit. No test fixtures/readbacks execute in-game.

Relevant logs under `tmp/witcher3classic-investigation/temporal-dev/`:
`test-palette-metadata-before.log` (expected regression failure),
`test-palette-metadata-after.log`, `test-direct-instance.log`,
`test-cloth-history.log`, `test-apex-owner.log`, `test-swarm-history.log`,
`test-swarm-motion.log`, and `deploy-swarm-motion.log` (latest Release link).
The build retains existing deprecation/tool-version warnings; these were not
addressed by changing shared utilities or updating vendored tools.

### Evidence and tooling for resumption

Scratch root: `tmp/witcher3classic-investigation/temporal-dev/`.
DevKit originals, JSON captures and EXRs: `devkit-live/dlss-audit/`.
Do not move `.cso` originals into source/live discovery folders.

Important recent evidence:

- `bird-64bd.json`: shared-palette instanced flock draw.
- `bird-instancing-decompiled.txt`, `bird-native-instructions.txt`,
  `bird-transform-helpers.txt`: actual draw/rotation/matrix composition.
- `swarm-lifetime-decompiled.txt`, `swarm-update-decompiled.txt`,
  `swarm-data-decompiled.txt`, `swarm-proxy-methods.txt`: native full array,
  visibility/LOD, proxy lifetime and group lookup.
- `proxy-destructor-instructions.txt`: common-base hook entry/prefix.
- `direct-instance-decompiled.txt`, `fitting-current0.json`: direct fittings.
- `cloth-current-output.exr/.png`, `cloth-material-ids.exr`, `cloth-vs-ids.exr`,
  `cloth-deformed-0..3.json`: material isolation and triple-buffer evidence.
- `cloth-history-flags.exr/.png`: previous history flag remained zero before
  persistent Apex proxy identity was added.
- `cloth-after-0..3.json`: stream captures after the first cloth revision.
- `still-f507-0..3.json`: captured inputs around the brief stationary-motion report.

Some text/decompilation files are in scratch root rather than `dlss-audit`.
Historical one-off Python mutation scripts append/transform files: **do not rerun
those scripts blindly**. Current source and this checkpoint supersede them.

DevKit/bridge: use `build/Release/renodx-mcp-bridge.exe` (NDJSON MCP over stdio),
`renodx_list_connections`, then `renodx_connect` with the current endpoint.
Old PIDs in scratch scripts are obsolete. The session's persistent Node helpers
`captureRpc` and `capCall` may exist only while the conversation/tool runtime
survives; recreate a bridge through the Node tool if needed, with
`child_process.spawn(..., {windowsHide:true, stdio:['pipe','pipe','pipe']})`.
Discover `tools/list` for exact schemas. No browser/computer control is needed
for shader inspection. User motion/scene changes sometimes require a short
instruction, but captures can be triggered directly through DevKit.

- `devkit_queue_snapshot` records the next rendered frame, not immediately.
- `devkit_get_draw`'s pipeline stages identify VS/PS; sorted `shaderHashes` do not.
- Capture one shader with `devkit_capture_shader_inputs`, stage `vertex` or
  `pixel`, `callStack:true`, `vertexBuffers:true`, bounded `maxBufferBytes`.
  `bufferSlots` refers to SRV buffers; native CBs are captured separately.
- Query large captures with `offset` and `limit:1`; oversized responses can
  trigger named-pipe/bridge errors. Maximum prefix 65,536 bytes is not a whole
  8 MiB bone buffer. Buffer captures begin at bound IA offsets.
- `capturedWords` preserves bit patterns; float JSON nulls may be NaN metadata.
- Texture preservation can provide exact draw-time copies; ordinary resource
  analysis reads current live contents and may see reuse.
- An absent draw/paused scene can time out. Take a fresh snapshot and identify
  the active variant instead of guessing that a specific hash is the cloth.
- Temporary material/history diagnostic live shaders were unloaded, and the
  configured live path was restored to empty/default after each capture. No
  diagnostic color replacements should remain enabled.

Ghidra: `D:/Downloads/ghidra_12.1.3_PUBLIC_20260817/ghidra_12.1.3_PUBLIC`;
project `temporal-dev/project/WitcherClassic.gpr`. Scratch `ghidra-*.cmd` runners
supply the existing JDK 21 and local APPDATA/user-home/cache. Use native
instructions and chained `.pdata` unwind entries to resolve interior stack PCs
before decompiling; do not treat an interior PC as a new function or trust an
incorrect inferred void return (e.g. `caf180` returns an allocation through its
callee). Read-only process probes were guarded against the exact executable;
none write native memory. PDB offsets/ASLR bases in old scripts must be refreshed
before reuse because this build changed CPU-state layout.

### First steps next session

1. Launch Classic with native AA enabled. In Advanced → Anti-Aliasing select
   DLAA Development, Object Motion, Show Object Vectors. Use the same outdoor
   scene with the previously invalid flock. Confirm that the new addon loads,
   DLAA initializes, and all eight hook prefixes/install succeed. A shader
   acceptance log alone does not prove valid per-instance history.
2. Inspect stationary/panning camera, flying birds, visibility/LOD transitions,
   population changes, and the already-working birds. After the first history
   frame, the affected flock should show valid vectors rather than persistent
   amber. Check wings and body motion separately. If it fails, inspect exact
   ScopeHook array bounds, Euler sequence and native flush count; do not force
   `.valid`, bypass guards or silently use one palette world for all birds.
3. Compare observed packed worlds with IA7 in a live capture and confirm the
   selected full-array index remains stable under native producer updates.
   Check that source_ / bone registry preparation remains consistent before
   the flock draw. Add a narrowly scoped diagnostic only if needed.
4. Recheck the user-confirmed cloth, sword fittings, hair, mill, faces/eyes and
   moving NPCs to catch regressions. Character idle animation can legitimately
   produce motion. If still objects jump, distinguish world/palette mismatch,
   history gap, camera jitter, view mismatch and raw debug occlusion.
5. Profile actual CPU and GPU cost with Object Motion off/on in the same scene.
   Keep per-draw copies small, once-per-frame bones, no runtime readbacks,
   no unnecessary extra geometry/dilation. Do not report performance as measured
   until timing data exists.

Broader remaining work after this checkpoint:

- **Wind-driven vegetation:** user explicitly requested it. Captured/exported
  native VS `1E1A9ECC`, `7EDF0F66`, `934C6523`, `7DB7776C`, `3672ACC1` (grass),
  `134AA93D` (bush); pixel families `602B6AA4`, `03EAC234`, `CEC6D9F4`,
  `5B57A747`. Native FrameCB b0=784 B, BaseTreeCB b1=480 B, MaterialCB b2=352 B,
  WindDynamicsCB b3=288 B. Per-model BaseTree/Wind CB objects were captured as
  distinct identities; FrameCB is shared. Plan: bounded previous GPU Frame/Wind
  copies per model, run preserved native vertex deformation with prior
  constants for previous clip, reuse original geometry MRTs. Previous-wind
  output needs meaningful GPU comparison to the original VS using previous
  captured constants. Account for the different b1 size; do not assume every
  path has the ordinary 256-byte View CB. See earlier captures/notes.
- **Soft alpha hair/transparency:** `F872850A`, reference `B6A66DCC` with
  `FAB74FB3` are separate premultiplied soft passes. Opaque core hair works;
  explicit motion/depth surface ownership/compositing is still needed. Do not
  globally relax alpha/depth checks or confuse this with NGX alpha upscaling.
- **Two-target character materials:** `48A9FBA7`, `D8E9533D`, `127FB2D1` with
  `512BF723`/`554DA7B8`/`1BDC3E57`, and `6A18DA3F`/`81010090` with `C6FC5197`
  were inspected. Their role/final-depth contribution needs proof before adding
  profiles; do not assume they are missing face albedo just from target count.
- **Sampling:** native jitter is two-phase; NVIDIA recommends at least 16
  phases (32 preferred). Upgrade actual engine sampling coherently, not only
  offsets supplied to NGX. Camera/scene-cut reset detection remains open.
- **True DLSS super-resolution:** game UI currently exposes native-resolution
  DLAA, with actual DX11 NGX evaluation. Lower-resolution native scene rendering
  and corresponding UI/input/resource sizing are not integrated. Synthetic NGX
  SR evaluations do not mean game-side SR is finished.
- Keep `motion_validated=false` / development input status until coverage,
  scene transitions and performance are actually verified.
- Preserve HDR menu/presets/Info, automatic peak detection, exposure scale,
  fractional gamut compression, cutscene HDR and effects limiter. Do not
  reintroduce the removed Hue Shift slider or reverted reflection/sky unclamps.


## Motion-history stability checkpoint: 2026-10-23 08:19 CEST

This is the current resume point. Preserve the earlier HDR, DLAA, cloth,
attachment and flock work; the older checkpoint above retains the full native
investigation and integration details. The user has now explicitly confirmed:
**“The bird fix worked!”** The new report is intermittent vector coverage on
individual parts while walking or while NPCs/objects move. Do not treat that
report as already resolved by this build; live verification remains required.

### Installed build and validation

- Release target `thewitcher3classic`, configure `clang-x64`, build preset
  `clang-x64-release`. The user closed Classic before the final link.
- Artifact: `build/Release/renodx-thewitcher3classic.addon64`, **2,878,976 bytes**,
  written **2026-10-23 08:19:21 CEST**.
- SHA-256: `5F7E89233DC770BCDAC8D617CF0A733885FDA3F09008ACCB1108E8130A682DB7`.
- The existing game-folder symlink resolves to the same hash. Release DevKit
  remains installed; no global CMake, loader, DLL-runtime or game-option changes.
- CPU history tests and the WARP motion/native-equivalence fixture pass with
  assertions enabled. Existing native G-buffer/forward output comparisons,
  motion/depth merge, unavailable-history rejection, rotating cloth and flock
  fixtures still pass. New cases cover exact batch identity, overlapping parts,
  newly visible parts, reordered visibility, reallocated CPU arrays, wrong mesh
  and array rejection, static diagnostic coverage, and ordinary skinned parts
  sharing a palette while keeping independent world transforms.
- The normal Release build succeeded. Existing FXC potential-uninitialized
  diagnostics and shared deprecated-API warnings remain; no compile/link error.
- Notification sent as soon as the addon was linked: relaunch with DLAA
  Development, Object Motion and Show Object Vectors enabled; walk near moving
  NPCs and inspect Geralt. This **new build is not yet user-confirmed stable**.

### Evidence and scope of the stability correction

The old rigid-history matcher owned per-proxy records but then matched packed
instances through a map keyed only by the **current world transform**. Multiple
native parts at the same world merged into one map entry. A new or conflicting
part could mark that entry invalid for the other objects. A deterministic CPU
regression reproduces this: two objects arrive at the same world from different
previous worlds, then a third object becomes visible there. Exact identities
must preserve the first two histories and reject only the new part.

Live read-only observations of the previous DLL found 50 groups of overlapping
worlds among 846 recently observed proxies in one sample, including character
groups with many allocations. Twelve later map samples had 0–5 invalid world
entries as rendering advanced. These are concurrent CPU observations, **not an
atomic GPU capture or proof that every reported flicker had this cause**.
No ambiguous ordinary bone-allocation world was seen in those samples.

A second, proven diagnostic issue was independent of bad history: ordinary
rigid batches were skipped whenever none of their valid entries moved. Their
raw vector-view coverage therefore changed as objects stopped/moved or batch
composition changed, even though DLAA's camera vectors could still be correct.

Evidence and test logs are retained in ignored scratch:
`tmp/witcher3classic-investigation/temporal-dev/stability-20261023/`.
It includes the saved draw snapshot, 16 before-draw F507139A geometry-input
frames, CPU observations, `compile.log`, `release-build.log`, `test-history.log`
and `test-motion.log`. The old PID was 32488; rediscover the new process.
`read_history.py` and `audit_history.py` describe the **previous DLL's MSVC
container layout** and fixed old PID/module base. Do not reuse those offsets on
the new DLL. The object-history/rigid state layout has changed.

### Implementation: exact packed-instance identity

No new native hook or geometry pass was introduced. The existing fingerprinted
`InstanceHook` at RVA C5AFA0 and `BatchHook` at C5A4F0 supply the identity/order
contract already established by Ghidra:

1. Instance context +18 is the native proxy; +8 is the native mesh and +0 is
   the renderer. Type-1 proxies own their world at +40 and allocation at +180.
2. The native renderer appends rigid 64-byte entries to pointer +4C / count +54,
   or skinned 80-byte entries to pointer +58 / count +60. CPU array pointers may
   move during allocation; the entry index is observed before/after the native
   append. These pointers are unrelated to the later rotating GPU IA offsets.
3. `object_engine.hpp` now retains bounded, reusable thread-local pose sidecars
   for those two arrays. An append must grow the matching count by exactly one,
   agree with renderer/mesh/frame and existing sidecar length, remain <=4096,
   and contain exactly the observed proxy world. Mismatched individual worlds
   get invalid poses; unknown batch sequences do not borrow another batch.
4. BatchHook exposes a sidecar only when renderer, mesh, frame, total count and
   the native CPU array pointer all agree. Direct single-instance submissions
   still use their existing scoped proxy and now also scope the exact mesh.
5. `rigid_history.hpp` removes the world-keyed map. Each proxy retains its
   current world, previous pose, mesh and frame. Exact lookups cannot collide
   with another proxy at the same world. Same-frame conflicting observations
   invalidate that proxy and the following history transition. Frame gaps,
   mesh changes, destruction/address reuse and nonfinite transforms still
   reject history; no stale-history grace period was introduced.
6. `rigid_motion.hpp` uploads the sidecar through the existing t125 pose table.
   Ordinary skinned instances now use it too: b8's second word was renamed
   from `swarm_history` to `instance_history` in `rigid_vertex.hlsli` and
   `object_vertex.hlsli`. A skeleton's previous palette remains independent of
   each instance's previous world. The previous one-world-per-allocation path
   remains a conservative fallback if an ordinary skin draw has no sidecar.
   The flock path continues supplying its own independent per-slot poses.
7. `ObjectMotion::Begin` receives the vector-view state. While the view is on,
   stationary rigid batches write valid coverage too. With it off, wholly
   stationary valid rigid batches keep the cheaper camera-vector path.
   Invalid instances retain responsive rejection; the view still displays raw
   object coverage, and DLAA preparation additionally checks final depth.

The existing MRTs, pose buffer, palette history and native draws are reused.
There is no GPU readback, synchronization wait, second geometry pass, or new
native detour in the production path. CPU sidecar arrays reuse capacity, and
the old transform-keyed map and per-instance map search are removed. Performance
of the full new build has **not yet been measured in-game**; vector-view mode
intentionally writes additional stationary rigid coverage while debugging.

### Next verification and remaining implementation

1. Obtain the user's result for **this hash**, with Show Object Vectors enabled:
   walk/stop/turn Geralt, keep moving NPCs visible, and observe individual body,
   head, face, hair and attachment parts. Also confirm cloth and both bird paths
   remain valid after the identity change. A new/returned-after-culling part may
   legitimately have one frame of unavailable history; repeated flicker on a
   continuously visible part is not accepted as normal.
2. Reconnect DevKit to the new PID. If flicker remains, identify the exact
   shader/material and distinguish amber (invalid history), dark (uncovered)
   and valid color/gray. Check exact instance-sidecar acceptance first, then
   palette/reference/CPU-deformed history and final-depth rejection. Do not
   claim every case was a debug artifact or weaken lifetime/depth guards.
3. Compare with the vector view disabled, including actual DLAA image stability
   and frame time. Keep the static production fast path. Do not leave DevKit
   input capture armed or temporary live diagnostics loaded during timing.
4. Remaining broader tasks from the previous checkpoint are unchanged: wind
   vegetation, alternate geometry and soft transparent hair/particle motion,
   stronger scene-cut/reset handling and jitter validation, engine-wide jitter
   beyond the native two-sample pattern, and lower-resolution game scene
   rendering for DLSS upscaling. Native-resolution DLAA is the integrated mode;
   do not advertise full game-side DLSS SR support yet.

Keep `motion_validated=false` / `development_inputs=true` until broader live
motion and image validation is complete. Preserve the user's removal of Hue
Shift and rollback of the reflection/sky HDR experiment. No HDR shader/menu
change, staging, commit, cleanup or publishing was performed in this revision.


## Camera-triggered NPC coverage checkpoint: 2026-10-23 08:45 CEST

This supersedes the 08:19 stability checkpoint for current status. The user
confirmed the bird fix but **rejected the first stability build as a fix for
NPC flicker**. Do not report that first identity revision as successful.

### Exact user report and current artifact

- Parts disappear when **moving the camera**, even if the NPC does not move.
  At a fixed camera angle, the whole body can be complete. Preserve this as
  the required reproduction case; a moving-NPC/static-camera test is different.
- The user objected to expanded building coverage and its overhead. Removed
  that diagnostic behavior in this revision. Static rigid batches again use
  camera reprojection and do not upload object poses/write extra motion MRTs
  solely because the optional vector view is enabled.
- Release target/presets unchanged: `thewitcher3classic`, `clang-x64`,
  `clang-x64-release`. The user closed Classic before final linking.
- Installed artifact: `build/Release/renodx-thewitcher3classic.addon64`,
  **2,929,152 bytes**, written **2026-10-23 08:45:33 CEST**.
- SHA-256: `EC2FBA6F43DD7F7081B9E6653DFC8289C17FFA92C139D7855A89EF0FBD728F59`.
  Game-folder symlink and build output hashes agree.
- User notified immediately after linking and asked to relaunch with DLAA
  Development, Object Motion and Show Object Vectors enabled, keep the same
  NPC visible, and reply Ready. **This revision has not yet been live-verified.**

### New evidence and code

The first build (previous hash 5F7E...) did load and run DLAA at 3840×2160.
Registered rigid/skin/cloth/hair/head/attachment/flock paths logged accepted
draws. The previous broad rigid-batch skip messages did not appear while that
build's expanded stationary view was on; this did not establish correct NPC
coverage. Read-only native CPU observations found no invalid skinned proxy
world histories in one sample, while the user still reported the problem.

A fresh exact capture with the NPC visible found missing material combinations
that earlier scenes had not included. Saved original DXBC and decompilations;
added these replacements to `temporal/` and `object_shaders.hpp`:

| Hash | Stage | Motion path/signature group |
|---|---|---|
| ED64E04A | VS | Reference-pose skin, group 6 |
| 8E6AB350 | VS | Reference-pose skin, group 10 |
| 68D68CC2 | VS | Rigid instance, group 10 |
| E76C261A | PS | Group 6, native alpha/LOD behavior retained |
| 035DA93A | PS | Group 10, native alpha/LOD behavior retained |
| C08941D9 | PS | Group 10, native alpha/LOD behavior retained |

Observed pairs include known body 9BA913EE / new E76C261A, known head
4B5AEE17 / new 035DA93A, new 8E6AB350 / existing 9D1990B0, and reference
skin with those new materials. Extending these pairs is necessary coverage,
**not proof that missing variants explain all camera-dependent flicker**.
The new skin shaders use the existing previous palette/reference/world path;
the rigid shader uses the exact native instance sidecar. No new geometry pass,
native hook, resource readback or NGX integration layer was introduced.

The static fast path now returns before copying/uploading rigid poses. Skinned
batches skip the stationary-comparison loop entirely. Exact proxy/mesh/batch
identity from the first revision remains; no transform-keyed matching returned.

`runtime.hpp` adds bounded diagnostics only while Show Object Vectors is on:

- When a profile's acceptance/rejection is first logged, query/log native depth
  enable, comparison function, write mask and stencil enable. This runs only
  for the bounded log event, not unconditionally on every draw.
- When motion-surface allocation changes, log the actual object vector and
  signed object-depth **SRV handles**. These can be inspected through DevKit.
- The same message labels prepared-motion/responsive pointers as native
  **TEXTURES**. They are not SRVs. Do not pass those pointers as resource views.

### Verification and investigation limits

CPU history and WARP motion/native-color/state-restoration regressions pass.
All compatible new shader pairs are included by the existing table-driven
fixture. A temporary input-signature ordering error in the new pixel shaders
was caught by compilation/GPU motion tests and corrected before linking;
native SV_Position stays before the appended varyings, SV_IsFrontFace after
them, matching the established working layout.

Added a stricter depth-prepass compatibility regression in `tests/object_motion.cpp`:
21 non-deformed G-buffer vertex shaders × 24 nontrivial camera/instance/four-bone
cases × 3 vertices × 4 clip components = **6,048 raw-bit comparisons**.
All components match the originals on both WARP and the hardware adapter.
The test now asserts zero differences. The GPU fixture accepts `--hardware`
after its original-shader-directory argument. This ruled out a mismatch in
those synthetic cases; it does not prove the live native depth test or every
real material/vertex input is correct. Do not relax depth tests based on the
camera-only symptom without evidence.

No performance timing result has been obtained yet. Earlier building coverage
added diagnostic MRT work; that is removed. Keep the view/capture off when
comparing normal rendering costs. All temporary texture captures were cleared
after saving; no live shader replacements were loaded during this revision.

Scratch evidence remains under `temporal-dev/stability-20261023/`:

- `npc-vector-frame-0..7.json/png`: exact pre-tonemap snapshots with the vector
  view enabled and the reported NPC scene visible.
- `vector-frame-0..7.json/png`: an earlier sequence had normal gameplay view
  enabled; **do not mistake that sequence for vector-coverage evidence**.
- `npc-all-geometry.json`, six native shader/decompilation JSON/HLSL files,
  `npc-ref-skin-0..3.json`.
- `new-rigid-history.json`: old running test PID 33096, fixed-address CPU
  observations; `read_new_history.py` is specific to that PID/module/layout.
- Immutable `.cso` originals are in `devkit-live/dlss-audit/` alongside earlier
  originals. They are not inside source or live-replacement directories.
- `test-npc-variants.log` (strict WARP test), `test-hardware-invariance.log`
  (hardware comparison run), `test-history.log`, `compile-npc-variants.log`
  and `release-npc-variants.log`.

### Online research and native patching direction

The user explicitly requested deep online research on stable/performance-aware
motion vectors, asked about half resolution, REDkit, and patching the engine
to deliver per-object vectors. Primary sources and concrete code implications
are in [WITCHER3_CLASSIC_MOTION_VECTOR_RESEARCH.md](WITCHER3_CLASSIC_MOTION_VECTOR_RESEARCH.md).

Decisions: keep render-resolution RG16 vectors for native DLAA; MVLowRes refers
to input/render resolution, not arbitrary half-size vectors. DLSS handles
standard input-vector dilation internally. Preserve previous deformation and
material coverage, exact frame alignment and native depth behavior. Static
scenery remains on camera reprojection. A reduced input scene for genuine DLSS
upscaling is still separate unfinished work.

Native renderer patching is already used for ownership/packing/lifetime. A
deeper previous-pose capture at the native update/submission stage is possible
but requires evidence of its timing and lifetime; previous animation buffers
are not automatically the previous rendered frame. Earlier motion-blur
inspection established camera reconstruction, not a hidden complete animated
velocity field. REDkit may help inspect assets/LOD/animations or author a test
scene, but no Classic 1.32 runtime vector interface was verified and no editor
installation is required as a prerequisite for this investigation.

### Immediate next action

Reconnect DevKit after relaunch; PID 33096 is stale once the game closes. Obtain
the user's result on this **new hash** with a stationary NPC and moving camera.
If parts still disappear, inspect the logged signed-depth surface and motion
surface at the problematic angle; distinguish dark coverage loss from amber
history rejection and from final-depth merge rejection. Use the logged native
depth settings and current shader/material pairs before changing the history
algorithm again. Keep the feature flagged as development/coverage unvalidated.
Do not claim universal reliability or measured performance until the live
coverage/reprojection/timing work has actually passed.

## Shader-family audit checkpoint: 2026-10-23

### What the longer capture established

The user clarified the key trigger: the NPC can be complete with the camera
stationary, then lose body sections while only the camera rotates. They asked
for longer sequences and systematic shader-family coverage, rather than fixes
for one NPC at a time.

Current game PID at capture was 11800, DevKit pipe renodx-devkit-mcp-11800.
The loaded addon remained the previous 08:45 Release, SHA256
EC2FBA6F43DD7F7081B9E6653DFC8289C17FFA92C139D7855A89EF0FBD728F59.
Its failure is now reproduced, not merely an untested report.

Evidence in tmp/witcher3classic-investigation/temporal-dev/stability-20261023/:

- long-npc-sequence/frame-0000.png through frame-0057.png: 58 samples over
  30.105 seconds. Timestamp gaps 483–547 ms, mean 518.8 ms. This is a long
  sampled sequence, **not** a continuous full-frame-rate video. sequence.json
  retains timestamps, statistics and CRCs; contact-sheet.png shows the torso
  dark during pans and returning while the head/limbs remain present.
- panning-205794-inputs-{0,4,...116}.json: 120 before-draw captures, native
  CB prefixes, VB prefixes, instance data and call stacks for VS 205794C4.
  There were missed frames; do not describe this as 120 consecutive presents.
- cloth-sequence-page-{0,4,...116}.json: 120 captures of 8AF8354B occurrence 0.
  This is the hanging cloth, not proven to be the NPC torso. Occurrence 1
  timed out twice. Do not infer a cloth-history cause from those rejections.
- opaque-draw-audit.json and draw-1460/1467/1508/1516.json distinguish the
  actual three-target geometry pass from two-target material passes.
- vertex-permutation-audit.json, pixel-permutation-audit.json and all-shaders.json
  inventory the live scene. A literal stage filter vertex returns zero;
  vertex_shader is the actual metadata stage string.

VS 205794C4 draws with PS 9D1990B0/035DA93A in the main three-target pass.
It uses ordinary four-weight instance skinning with palette in v12 and no
reference-pose texture. VS FCE8C0B4 draws with PS 4C84BE3F and uses reference
positions blended with saturate(v6.w). Both vertex variants lacked motion
support, while their pixel partners were already registered. They now append
PreviousObjectClip using their actual native inputs and retain the native
SV_Position calculation. This is a concrete uncovered path, but not proof
that every reported intermittent hole had this cause.

### Systematic offline discovery and source generation

The installed content and DLC directories contain 31 *shader.cache files.
The read-only scan found 8,368 unique DXBC containers: 6,534 vertex, 1,709 pixel,
69 domain, 7 hull, 6 geometry and 43 compute shaders. There are 2,188 skinned
vertex shaders across 80 exact native output-layout families. The initial
base-cache scan independently matched 67 DevKit originals byte for byte;
later archive comparisons also include originals copied from the caches.
Do not describe all later archive matches as independent live captures.

New reproducible game-local tools:

- tools/audit_motion_cache.py validates DXBC bounds/part tables, computes the
  same CRC32 as RenoDX, inventories native input/output signatures and copies
  candidate original binaries to scratch. It accepts cache files or content
  directories. It checks archived originals and rejects CRC collisions.
- tools/motion_fingerprint.py resolves straight-line decompiled HLSL into
  scalar dataflow expressions for all four SV_Position components. Temporary
  register names and unrelated material calculations do not affect the match.
  Input semantics/types, matrix/buffer addresses, weights, reference-position
  loads and arithmetic remain part of it. Unsupported math/control flow is
  rejected, not guessed. This is a conservative review aid, not a formal proof
  of shader equivalence.
- tools/audit_motion_families.py requires both a matching complete position
  expression and an unambiguous existing native output interface. The audit
  found 59 eligible vertex variants, 13 already registered and 46 new. It
  retains native shader bodies and appends the existing shared motion helper.
  It also checks native pixel input semantic/register/type/mask layouts plus
  HLSL declaration order and a single exit. Of 95 material variants, 81 new
  pixel replacements append the same motion/depth outputs after native math.
- temporal/object_skin_families.inc and object_material_families.inc are the
  reviewed generated registration lists. The generator does not alter existing
  hand-edited shaders and asserts rather than overwriting differing sources.
  Native .cso files remain in ignored scratch, never source/live folders.

Do **not** broadly patch every BLENDINDICES shader: the remaining inventory
includes shadows, other output layouts, branch-dependent deformation,
unsupported expressions and ambiguous material/forward families. Current
exclusion counts in cache-audit/family-report.json are 1,057 unresolved
positions, 580 with control flow, 488 without an unambiguous audited
position/interface pair, and four without the expected position declaration.
These are unsupported or unreviewed, not evidence that they all need vectors.

Reproduction from repository root (paths may be supplied as absolute paths):

1. Run tools/audit_motion_cache.py on the game's content and DLC directories,
   with --output tmp/.../stability-20261023/cache-audit and --originals pointing
   to temporal-dev/devkit-live/dlss-audit.
2. Run bin/cmd_Decompiler.exe -D on exported .cso files in bounded batches.
   This is SM5 DXBC; do not use the DXIL decompiler workflow.
3. Run tools/audit_motion_families.py with that directory. Inspect reports;
   --generate-vertices --generate-pixels explicitly generates reviewed source.
   --test-originals copies immutable inputs for the GPU fixture.
4. Configure clang-x64, compile the Release shader/addon object target, then
   run CPU, WARP and --hardware GPU regressions before the final DLL link.

### Runtime cost and verification

All discovery, decompilation, dataflow matching and compilation happens offline.
The addon has 78 vertex and 102 pixel registrations, sorted once; matching uses
binary search. There is no per-frame cache scan or shader compiler, no new
native hook, additional geometry draw, CPU texture readback or per-object render pass.
Vectors are appended to eligible original draws. The existing stationary rigid
fast path remains in place. Increased moving-material coverage does increase
MRT work where it was previously missing; no measured CPU/GPU cost is claimed.

The WARP GPU regression passes 722 ordinary native-color/material/motion pairs,
plus CPU-deformed, direct-forward, attachment, cloth, flock, history and state
checks. The clip-position test covers 52 G-buffer vertex variants times 24
camera/world/four-bone cases times 12 components = 14,976 raw-bit comparisons,
all identical on both WARP and the NVIDIA hardware adapter. Direct-forward
native varyings are also compared for the new non-instanced variants. Both
GPU runs completed with exit code zero and no D3D11 debug errors.

The fixture now reflects native pixel texture dimensions, supplies separate
nondegenerate material/reference data, clears material and motion outputs
between ordinary pairs, and checks that native discards leave vector MRTs
untouched. Cross-combining compatible layouts can still make original synthetic
normal/color math nonfinite. Fifteen such native channels matched the replacement
classification; they are reported separately, **not** counted as proof of finite
live material behavior. Four Python dataflow tests verify register-renaming
invariance and rejection of changed position inputs/matrices/unsupported math.
The CPU ownership/history suite also passes.

Logs: compile-families.log, test-families.log, test-hardware-families.log,
test-history-families.log and cache-audit.log. The cache inventory, source
fingerprints and exclusions remain under cache-audit/.

### Capture limitation and next verification

Correction to the preceding checkpoint: the logged native object motion/depth
SRV handles are **not tracked by DevKit's resource registry**. analyze_resource
rejects them. Logging a native pointer does not make it tool-readable; do not
bypass the registry validation. The tracked native TAA output view was used
for the saved diagnostic images. Proper lifetime-aware resource registration
or an explicit debug output path would be needed to inspect the private signed
depth/MV resources directly through DevKit.

The user closed Classic and the Release target linked successfully. Deployment
is complete through the existing game-folder symlink:

- Artifact: build/Release/renodx-thewitcher3classic.addon64
- Size: 3,859,968 bytes; last-write time 2026-10-23 09:26:50 CEST
- SHA256: 9D581FF1FB72C60B1A3A133043C61AF9F9FD207CE38ECDCCE368DF8A8046E127
- The game-folder link resolves to this artifact and its hash matches.
- The user was notified immediately that it was ready and asked to relaunch.

PID 11800 and its pipe are now stale. Discover/reconnect the new DevKit pipe
after relaunch. Then repeat a long stationary-NPC pan with
camera-only movement, then NPC/root movement, LOD/culling return and walking.
Inspect dark coverage versus amber history rejection, actual shader pairs and
bounded rejection logs. If holes persist, correlate native draw/pose history
through the affected frames instead of assuming another missing permutation.
Keep development_inputs enabled and motion_validated false. Vegetation wind,
soft transparent coverage, wider jitter/scene-cut work, final reprojection and
performance measurements remain unfinished.

## Eye and hair checkpoint: 2026-10-23

### User result and session boundary

The user tested the 09:26 shader-family revision and reported it was "much,
much stabler now in general." The remaining short head fade is the **nearby
NPC's head**, not a confirmed Geralt-head problem. Subsequent reports: Geralt's
eyes absent, Roach's tail absent, and hair briefly fading. The earlier flock
bird, cloth and sword-fitting fixes remain user-confirmed.

The game was already closed before the final link. The new Release addon is
built and installed, and the user was notified immediately. The user requested
complete documentation so work can continue later; no further live test was
performed after this build. Do not label all coverage complete.

The reusable, source-linked explanation of the whole implementation is now
[OBJECT_MOTION_VECTOR_INTEGRATION.md](OBJECT_MOTION_VECTOR_INTEGRATION.md).
It covers the native temporal contract, eight guarded hooks, persistent object
identity, bones/world/reference/cloth/flock history, original-draw MRT output,
family discovery, exact clip arithmetic, final-depth merge, diagnostic failures,
test commands, capture limits, cost and remaining transparent-layer work. Use it
as the starting reference for another game; Classic RVAs/layouts are not portable.

### Opaque forward eye-material candidate

Live inspection identified VS `48A9FBA7` with PS `12B76681` in an opaque forward
pass: one full-resolution RGBA16F scene target, main depth, blending disabled.
The VS already has an audited group-4 replacement but also serves other passes.
The new `temporal/0x12B76681.ps_5_0.hlsl` retains native PBR calculations and
appends previous clip/history inputs and MRT3/MRT4 vector/depth output. Its
native current-frame CB is `cb12`, selected through `WITCHER_MOTION_FRAME`.
Native decompiler raw load syntax was repaired to `ByteAddressBuffer Raw20`
at t20 plus `Raw20.Load`; no tonemap/exposure changes were made.

`ObjectShader` marks this pixel profile forward. Runtime passes
`vertex->forward || pixel->forward` to Begin, preserving pass selection when
one VS serves G-buffer and forward materials. Opaque forward validation still
requires the correct viewport/depth, one target, disabled blend and full write
mask. `EE3505B9/689445D9` is a separate multiplicative blended overlay and
remains native. It must not overwrite opaque motion as though it were a new
opaque surface. There are now 78 vertex and **103 pixel** profiles.

This is a credible eye-material candidate from live draw/resources, not a
user-confirmed eye fix. Test Geralt's actual eyes next session before claiming it.

### Opaque hair depth-EQUAL precision repair

Native VS `B0B4EB6F` uses depth EQUAL (comparison 3, depth writes off). A new
forward-position test consumes all native varyings plus motion outputs and
varies camera, instance world and bones across eight nontrivial cases. Each
VS has 96 raw-bit clip comparisons (8 x 3 vertices x 4 components).

The old source differed in 10/96 components on WARP despite passing the earlier
looser varying tolerance. Marking the position output `precise` alone yielded
0/96 on WARP but **27/96 on NVIDIA hardware**. The final source combines
`out precise float4 o10 : SV_Position0` with 27 explicit native `mad` operations
only in the native position-producing prefix, through the assignment to o10.w.
Native fused math is retained and reassociation prevented; the rest of the
lighting body stays intact. Native depth EQUAL is not weakened.

Final WARP and hardware both report **0/96** for each of `AB3E8304`, `FF64C197`,
`B0B4EB6F`, `D9A50A38`. This fixes a concrete equivalence defect consistent with
camera-dependent depth rejection. It is not yet live proof of the reported hair
fade's cause or of the nearby NPC-head fade.

### Current offline audit tool state

`motion_fingerprint.py` now permits unrelated control flow by poisoning lanes
written inside branches/loops. A clip dependency on an uncertain write remains
unresolved. Six Python tests pass, including unrelated-flow acceptance and
branch-dependent-position rejection. This improves discovery without guessing
deformation or moving analysis into the runtime.

A final **report-only** rerun finds 80 eligible VS, 1,409 unresolved positions,
695 without an unambiguous position/interface pair and four missing position
declarations. These replace the earlier report's counts in scratch
`cache-audit/family-report.json`. The 21 candidates beyond the earlier 59
**have not been generated/registered/deployed**. Installed generated lists still
contain 46 VS and 81 PS additions. Before generating group-12 hair variants,
teach the generator their TEXCOORD12/13 append layout; it currently assumes
TEXCOORD10/11. Inspect native arithmetic and run exact hardware clip tests.

### Capture evidence and qualifications

Scratch root: `tmp/witcher3classic-investigation/temporal-dev/stability-20261023`.
Original bytecode remains under `temporal-dev/devkit-live/dlss-audit`.

- `family-first-frame.png` is vector view and shows the previously missing
  torso. `family-long-sequence` contains 37 samples over 30.502 seconds, but
  **only frames 0-11 are vector view**. From frame 12 at 6.038 seconds, the
  reused native TAA resource contains normal gameplay. The entire sequence
  cannot establish continuous vector coverage.
- `eyes-visible.png` and `hair-fade-now.png` are normal gameplay images, not
  evidence of the raw object MRT. The user's ReShade screenshot at
  `C:/Users/Vik/Pictures/ReShade/The Witcher 3 Wild Hunt — Remastered/witcher3 2026-10-23 09-34-46_1.png`
  is actual vector view, but that instant does not establish the reported fade.
- `eye-draw-1636..1642.json` and the saved `12B76681` native decompilation,
  disassembly and CSO establish the opaque forward material and pass state.
- `eye-forward-vs-inputs.json` captured an occurrence of the same VS in a
  **two-target** material pass; it is not the one-target eye draw.
- `eye-forward-ps-inputs.json` contains a bridge connection error from an
  oversized response and is **not a valid capture**. The successful retry is
  `eye-forward-ps-inputs-bounded.json`: one frame, maxBufferBytes 8192, no vertex
  buffers; full b1/b2/b3/b4/b12, partial b13 and raw t20, resource metadata.
  It does not freeze the full native lighting resources or textures.
- Current soft-hair candidate was `F872850A/FAB74FB3`, eight one-target draws.
  The PS outputs premultiplied color/alpha. **It is not yet a proven Roach-tail
  draw.** `soft-hair-current-draw.json` is failed-tool metadata, not valid
  blend-state evidence. Do not infer the tail path from that file.

Private MV/depth SRVs still are not tracked DevKit views. Do not bypass handle
validation. Resource addresses and PID 15176/its pipe from this session are
stale after exit. Discover the new process/pipe and current tracked output
resource after relaunch. All capture arms were cleared.

### Final build and verification

- Target/preset: `thewitcher3classic`, `clang-x64-release` (configured clang-x64).
- Artifact: `build/Release/renodx-thewitcher3classic.addon64`.
- Size: **3,896,320 bytes**; last-write **2026-10-23 09:54:26 CEST**.
- SHA256: **53236C4E29CF159B345D77DCEB1C88470BCD375BC02BB25F4652059E324D1463**.
- The game-folder symlink resolves to this artifact; the installed-path hash
  matches. Release link exited zero. No new native hook or geometry pass added.
- Logs: `compile-eye-hair-final.log`, `release-eye-hair.log`,
  `test-eye-forward.log`, `test-eye-forward-hardware.log`,
  `test-hair-final-warp.log`, `test-hair-final-hardware.log`,
  `test-eye-hair-final-warp.log`. Final full WARP and focused final NVIDIA
  hardware eye/hair runs pass, with zero D3D11 debug errors. The preceding full
  family hardware run covers the unchanged 52-VS G-buffer equivalence cases.
- Native reflection fixtures handle cube/array/raw lighting bindings. Forward
  tests exercise pixel-selected one-target handling. Fifteen synthetic native
  nonfinite color channels match classification and remain reported separately.
- CPU ownership/history tests and six Python fingerprint tests pass. No
  matched-scene CPU/GPU timings or new live acceptance result are claimed.

### Resume in this order

1. Relaunch with native AA, DLAA Development, Object Motion and vector view.
   Check Geralt's eyes and opaque hair with camera still, then camera-only pan.
2. Capture a sufficiently long **nearby NPC-head** pan sequence and correlate
   actual VS/PS, pass/depth state and history at a fade. Diagnose dark coverage
   versus amber invalid history; do not assume it is another missing hash.
3. Isolate Roach's actual tail draw and separate opaque from premultiplied soft
   layers. Validate a deliberate transparent motion/depth policy; do not force
   opacity or blend UV vectors without considering opaque/background motion.
4. Review the extra offline candidates, especially head/hair permutations, before
   generating anything. Preserve exact clip math and interface linkage.
5. Validate final prepared vectors and reprojection, culling/LOD/destruction,
   scene cuts/resizes, output quality and matched-scene cost with captures off.
   Wind vegetation, broader jitter and lower-resolution scene rendering for
   true DLSS upscaling remain unfinished. Keep motion_validated false and
   development_inputs true. No further edits or deployment are pending this
   checkpoint; the next work needs the next live verification session.

## DLSS menu checkpoint: 2026-10-23

The user requested internal HDR/DLSS tabs, an enable toggle, quality/model
dropdowns and conventional DLSS input diagnostics. The game-local overlay now
wraps the existing HDR settings renderer in an ImGui tab bar; shared settings
infrastructure is unchanged. DLSS contains Image Quality, Diagnostics and Status.
Enable DLSS is at the top; Object Motion is under Advanced diagnostics.

DLSS settings are global and persist independently of HDR presets/Off. Existing
AADevelopment, AAObjectMotion and AAObjectVectors migrate from preset 1 only
when no global value exists. AAObjectVectors now selects a debug enum; old 1
still means raw object coverage. HDR settings retain their previous visibility,
presets and information sections. UI rendering is compiled but awaits live inspection.

Quality lists DLAA/Quality/Balanced/Performance/Ultra Performance. Only DLAA is
available because reduced-resolution scene rendering is not integrated. Models
list K/J/L/M/C; K/J are selectable, L/M disabled for installed DLL 310.3.0.0,
and C marked removed by NVIDIA. No runtime/vendor dependency was changed.
This is an honest menu for the currently supported backend, not completion of
the unavailable upscaling modes. Enabling those modes/models remains work.

K/J map to NGX render-preset hints before feature creation. Changing hints
recreates the feature and resets its history. Driver overrides may supersede
requested hints. Five diagnostic views use existing GPU preparation surfaces:
raw object coverage, final combined motion (direction hue/magnitude brightness),
nonlinear reverse-Z depth, bias-current-color mask and input HDR color. They
replace the existing final blit, not an extra pass/readback. SRVs are cached on
resize; the debug constant buffer is updated only in diagnostic mode. Views
still pass through later game postprocessing; the mask is not NGX internal
confidence. Off restores normal reconstruction output.

Release addon installed through the existing symlink:

- Size 3,900,928 bytes; timestamp 2026-10-23 10:17:27 CEST.
- SHA256 E37588A0BE53A7E52648C668A9441BB4A892F94071D58CEA7FCA4D0E63289A18.
- Release object/shader compile and final link pass; existing 31 warnings.
- GPU fixture switches K/J across 64 evaluations and feature resizes; all four
  DLAA/Quality cases pass HDR preservation and context restoration. Each of five
  diagnostics is read back and numerically checked per case. Final unrestricted
  run exits zero, including NGX shutdown and debug-layer checks.
- The first restricted test completed rendering but stalled in
  NvTelemetryAPI64!UninitializeTelemetry via NVSDK_NGX_D3D11_Shutdown1. A
  noninvasive CDB trace identified that wait. Only the owned test process was
  stopped; the same executable reran outside the restricted environment and
  completed successfully. No product workaround or telemetry settings changed.
- Logs: tmp/dlss-menu-compile.log, tmp/dlss-menu-release.log,
  tmp/dlss-menu-tests-unrestricted.log; restricted-run trace in
  tmp/dlss-menu-shutdown-stack.log.

Next live check: both tabs, preset independence and persistence, K/J switching,
all debug views then Off, and toggle back to native TAA. The prior eye/hair
revision is included; NPC head, Roach tail and other motion acceptance tasks
   from the preceding checkpoint still apply.


## Model compatibility and upscaling foundation: 2026-10-23

The user explicitly requested all model entries active, with runtime-default
fallback for older DLLs. K/J/L/M/C are now all selectable, mapped to NGX ABI
values 11/10/12/13/3. The prior DLL-version UI gate is removed. Feature creation
retries once with all quality preset hints set to default after an explicit
failure; silent runtime substitution remains possible and is not misreported
as an effective model selection. Changing the requested model recreates history.

Actual upscaling work has started with validated NGX render-resolution queries
for every quality mode, cached at output-size changes and shown in Advanced
diagnostics. Native renderer sizing integration remains pending; the gameplay
quality controls still allow only DLAA. The complete primary-source research,
live DevKit resource evidence, Ghidra findings and ordered implementation plan
are in [WITCHER3_CLASSIC_UPSCALING_RESEARCH.md](WITCHER3_CLASSIC_UPSCALING_RESEARCH.md).

Ghidra identified separate native scene/overlay/backbuffer overrides and the
BA82A0 view-construction path. Its 12B3C0 constructor copies the view at +0x10
and retains separate overlay dimensions at +0xB420. These are investigation
results, not an installed native sizing hook. No game setting or executable
memory was changed. DevKit snapshot from PID 35496 confirms native TAA still
receives and writes 3840x2160 resources.

Release object/shader compile passes (existing 31 warnings). The expanded
GPU fixture passes 80 evaluations spanning all quality modes and all five
model requests, including odd input widths, HDR, diagnostic values, motion,
state restoration and clean shutdown with the installed game runtime.
Older-runtime preset requests also pass. Logs and exact input sizes are in
the research document. No claim of measured in-game upscaling performance.

Deployment status: final DLL link pending Classic exit; the close request was
sent because PID 35496 still has the old addon loaded. The installed artifact
is still the preceding menu build E37588A0BE53A7E52648C668A9441BB4A892F94071D58CEA7FCA4D0E63289A18.
After the user closes, link target thewitcher3classic with clang-x64-release,
verify the game symlink hash, and record/announce the new artifact immediately.


## Native scene upscaling checkpoint: 2026-10-23

The user rebuilt/restarted the model/query foundation and requested continued
upscaling. Ghidra plus live read-only renderer inspection identified the native
main-view and post boundary. The new `temporal/upscale_engine.hpp` hooks C1C910
and C4D150 in the existing verified/pinned transaction. It reduces only the
primary scene viewport in the retained full-size resource pool, then restores
output dimensions after successful NGX reconstruction and before final grading.
No global game settings or external configuration are patched.

Quality plans are queried from NGX, atomically handed to the render-thread scope
under a mutex, and matched to scene/overlay/pool dimensions. NGX preparation
crops the actually rendered top-left region into render-size input textures;
output writes full resolution into the native TAA destination. Object motion
now distinguishes viewport dimensions from native depth/MRT allocation size.
Debug displays map input extents to output extents. Missing reconstruction/post
boundary latches a full-native-rendering fallback for following frames.

After the user closed Classic, the established clang Release target linked and
the existing game symlink was verified. Build and offline CPU/NGX/object GPU
checks passed. The user relaunched, tried Quality and Performance, and reported
Performance working very well. Exact-draw captures verify the smaller geometry
and TAA viewport and restored full-resolution final grading. The comprehensive
implementation record and precise limitations are in
[the upscaling research](WITCHER3_CLASSIC_UPSCALING_RESEARCH.md).

Continue with the engine jitter producer, scene sampler mip bias, remaining
motion coverage and reset/cutscene/resize/performance validation. Do not describe
the current native two-phase jitter as a completed DLSS sampling implementation,
or retained pool allocations as a VRAM optimization. Do not reintroduce model
version gates; all K/J/L/M/C requests and runtime-default fallback remain active.

## NPC neck/collar checkpoint: 2026-10-23

The user left the game paused with a nearby NPC's neck region missing from
object-motion coverage. The captured image confirms a dark collar/upper-chest
patch while the head, dress and arms have valid coverage. DevKit remained able
to capture the rendering scene while paused.

### Capture and diagnosis

Scratch: `tmp/witcher3classic-investigation/temporal-dev/neck-20261023`.
Process/pipe at capture: PID 16148 / `renodx-devkit-mcp-16148`; stale after exit.

- `draws.json`: 2,018 draw records.
- `coverage.png`, `grade-input.json`: preserved pre-final-grade image showing
  the actual object-coverage view, not a reused normal-color screenshot.
- `draw-1901.json`, `draw-1904.json`: unregistered VS `BC187223` paired with
  registered PS `EB8C3FAE`, one full-size RGBA16F target, blend disabled and full
  color write mask.
- `BC187223-inputs.json`, `BC187223-full-inputs.json` and
  `BC187223-occurrence1.json`: exact pre-draw constants, index/vertex streams,
  instance data, viewport and resource metadata. `occurrence:1` successfully
  captured a different instance from occurrence 0 in this session.
- The second instance world translation is approximately
  `(91.130859, 12.334143, 0.110532)`, with bone allocation base 30663. Its mesh
  decompression box has Z range approximately `1.41412..1.55866`, consistent
  with a neck/collar patch. `mesh-localization.json` records its unposed bounds
  projected near the reported region. This is supporting localization, not
  an exact skinned per-pixel proof; final verification remains in game.
- Live `devkit_get_shader` reported `BC187223` as Original with no addon shader.
  Original decompilation/disassembly are saved in `0xBC187223.json/.hlsl`.

Capture limitations: structured bone t0 remained `not_requested` even with
textureSlots 0; this capture does not contain the whole GPU bone palette.
BC1 material texture preview was unsupported, so no albedo preview was saved.
Do not describe either as successfully captured. No live replacement was used.
All bounded captures were cleared before asking the user to exit.

### Focused family extension

The generic position/interface audit matched this VS to both group 6 references
(`95D8CC2E`, `9BA913EE`) and group 11 (`FF64C197`) and conservatively rejected
the ambiguity. The observed opaque forward pixel pairing supplies the context
for selecting group 11. Runtime groups/pass checks were not relaxed.

`audit_motion_families.py --vertex-reference 0xFF64C197 --vertex-list
object_forward_skin_families.inc --generate-vertices` scans the same 2,188
decompiled skin programs against that explicit audited reference. Twelve
position/interface matches include three already hand-registered references
and these nine new variants:

`18186C6E`, `62F9496B`, `6817FC23`, `9848A290`, `A8AE1484`, `ACEE34D6`,
`BC187223`, `EC09D1C5`, `F9F54B50`.

Original native shading/current-position code is preserved. Each addition
appends `PreviousObjectClip` and the existing TEXCOORD10/11 interface. The
existing PS profiles produce MRT3/4. There are now 87 VS and 103 PS profiles.
No new PS, hook, per-frame discovery, CPU readback or geometry replay was added.
Only eligible opaque forward draws use these additions; shadow, two-target
prepass and blended-layer paths are not newly accepted.

The selected audit is saved as `forward-family-report.json`; the prior generic
report is `prior-family-report.json`. The generic scratch report was restored
with a report-only rerun (80 unambiguous eligible VS). Its ambiguous category
still includes these hashes because it deliberately lacks the selected pass
context. Group-12 generation now fails explicitly rather than emitting an
incorrect TEXCOORD10/11 recipe; its specialized generator remains future work.

### Validation, build and next test

`tests/object_motion.cpp` now includes these instanced forward VS in actual
native-versus-replacement material/motion draws and enumerates all registered
instanced forward profiles for exact clip tests. Native output masks are read
through reflection because decompiled float4 declarations can contain unwritten
W lanes; fog variants write additional lanes. Synthetic fog constants were made
finite rather than weakening native-varying checks. The fixture explicitly
restores G-buffer targets after its forward-pair loop.

Final WARP **and** NVIDIA hardware runs exited zero, each with:

- 771 material/motion pair comparisons, including native color, discard/alpha,
  vector/depth output and target restoration.
- 13 forward profiles × 96 raw-bit clip comparisons = 1,248, zero differences.
- 52 G-buffer profiles × 288 comparisons = 14,976, zero differences.
- Existing cloth, rigid, flock and history GPU checks, and no D3D11 debug errors.
- 15 unchanged native nonfinite synthetic material channels, matching the
  replacement classification, reported separately.

The six Python fingerprint tests pass. Logs: `tmp/neck-compile.log`,
`tmp/neck-test-warp.log`, `tmp/neck-test-hardware.log`, `tmp/neck-release.log`.
Release built 2026-10-23 12:31:45 CEST, 4,161,024 bytes, SHA256
`8DAEB031A972728A75C374A1F5FCC5E9CC76F65855B4800D005E5F374C9532FA`.
The game-folder linked-path hash matches. The user was notified immediately
that it is ready to relaunch. The HDR weather revision remains included.

Next: check the same NPC collar/neck in Object Motion / Coverage while paused,
then camera-only pan and normal NPC animation. Verify accepted `BC187223`
draws in the runtime log and capture the coverage image again. If the patch is
still absent, correlate its depth and history with the exact draw rather than
claiming another missing shader from appearance alone. No post-build visual
acceptance result has yet been recorded.


## Horse-tail checkpoint: 2026-10-23

- User reports missing horse-tail object coverage. Captured PID 34968 with Roach
  visible, archived 2,148 draw records and three exact vertex-input frames.
- Draw 2044 is `5CC0DB95 / 9B839F3B`: 6,360 indices, one color target, blend
  disabled. Vertex positions project onto the visible tail. Native stack runs
  through the existing Apex deformation hook (`116d237` return address).
- Tail uses UV stride 8 (18,464 bytes), deformed stride 40 (92,320 bytes),
  R32 indices, 128-byte world, 256-byte view and 4,304-byte frame constants.
  Existing owner/generation + UV history already supports this layout.
- New signature group 14 combines `deformed=true` and `forward=true`. No new
  runtime hooks, full-scene passes, readbacks or history mechanism were added.
  The original tail draw emits motion/depth MRTs using previous deformed
  vertices and world/camera transforms. Native alpha .33 discard is unchanged.
- Offline native signature scan of the existing 8,368-entry cache inventory
  identifies `AE216EAE`, with identical position fingerprint and input/output
  interfaces. Its only source difference from the live VS is a lighting
  threshold (1 versus .999000013). Both variants retain their original logic.
  The inventory cannot establish completeness for compressed/uncaptured data.
- Initial generic HLSL changed 3/96 native clip components. Both VS now retain
  all 12 native projection MADs explicitly and use precise SV_Position. Native
  depth state is unchanged. Repaired raw lighting loads at VS t21 / PS t20.
- GPU fixture adds forward CPU-deformed material/motion tests, native-varying
  comparisons, alpha-cutout rejection on scene/motion targets, one-target
  restoration and 96 exact clip comparisons per tail variant. WARP and NVIDIA
  each pass both variants with 0/192 tail clip differences, plus all prior
  regressions (771 ordinary material pairs, 1,248 forward and 14,976 G-buffer
  clip comparisons; no D3D11 error diagnostics). The 15 pre-existing native
  nonfinite synthetic material channels still match classification. Six Python
  fingerprint tests also pass.
- Evidence: `tmp/witcher3classic-investigation/temporal-dev/tail-20261023/`:
  `scene.png`, `draws.json`, `draw-details.json`, `geometry.json`, originals,
  decompilations, signature-candidate list and offline scan script.
  Logs: `tmp/tail-compile.log`, `tmp/tail-test-warp.log`,
  `tmp/tail-test-hardware.log`; final link log will be `tmp/tail-release.log`.
- The later blended `C3C96F3C / 91091ECC` hair layer remains native. This revision
  covers the opaque/alpha-tested tail core, not a new transparent-fringe policy
  or HairWorks. Do not force soft hair opaque or blend UV vectors naively.
- Next: after relaunch (Release link and file hash verified), test with
  DLSS enabled and Object Motion / Coverage selected. Check tail sway and a
  slow camera pan, then normal DLSS output for ghosting/appearance changes.
  Capture any residual fringe separately. Neck and weather visual acceptance
  remain pending; preserve both earlier fixes.

Build status: Release target `thewitcher3classic` linked successfully with
`clang-x64-release`; existing game-folder symlink and workspace output hashes
match SHA256 `408D746F32A71D61A814411C087DCAE446D289A4A7852F1815C73E8D35DB267C`.
Size 4,234,240 bytes, timestamp 2026-10-23 12:50:10 CEST. The user reported
rebuilding and starting the game; visual verification is next. The initial
restricted link attempt saw a stale process/file lock; a system-level check
found no loaded addon and the subsequent authorized link succeeded. No process
was terminated and no link/file workaround was used.

Relaunch check: connected to DevKit PID 34808. `5CC0DB95` reports
`hasAddonShader=true`, source Add-on; ReShade startup also registers
`9B839F3B`. Registration is confirmed; actual tail-motion acceptance and
visual coverage have not yet been confirmed after this restart.


## Foliage wind and contact checkpoint (2026-10-23)

The user accepted the horse tail and requested remaining wind-driven and trampled
foliage motion. Development continued against the running Classic PID 34808;
DevKit preserved 120 consecutive grass draws while the user walked through it.
The wind CB and contact CB each contained 120 different states with stable
source-buffer identities. Six active contact ellipsoids were present throughout.

| Native VS | Native PS | Role / signature group |
|---|---|---|
| `134AA93D` | `5B57A747` | Grass/contact deformation, group 23 |
| `1E1A9ECC` | `602B6AA4` | Branch material, group 20 |
| `7EDF0F66`, `934C6523`, `7DB7776C` | `03EAC234` | Other branch/frond/leaf paths, group 21 |
| `3672ACC1` | `CEC6D9F4` | Camera-facing billboards, group 22 |

`temporal/foliage_motion.hpp` owns bounded double-buffered previous constants.
The source CB identity is retained with a COM reference; shared frame/collision
CBs copy once per frame, even when many models/draws consume them. Unique model
CBs have independent history. A per-shader CB mask retains only the previous
inputs that compiled deformation actually reads: 0x2D for the four tree paths,
0x2F for billboards, 0x3F for grass (bits map to b0/b1/b2/b3/b11/b12). Trees
and billboards never depend on the grass-only b11 collision binding. Missing history or a frame gap yields invalid
object history and the existing camera fallback; it never reads an older pose as
if it were the previous frame. Old entries expire after 120 frames, including
frames with no accepted object draws, and storage is capped at 1,024 source CBs.

The production code copies only CBs, not vertex or instance buffers. Original
planted instance transforms are reused while the previous native deformation is
re-evaluated. There is no per-instance CPU identity map or GPU-to-CPU readback.
This assumes the planted instance world transform is stable: wind/contact motion
is represented by the retained native deformation inputs. Do not reuse this
approach blindly for movable, destructible or physically translated vegetation.

`tools/generate_foliage_motion.py` preserves each native vertex body once in a
`.native.hlsli` include and emits current/previous wrappers. FXC can remove unused
previous material outputs. Native textures, material branches, alpha/discard and
contact displacement clamps remain native. Motion is appended as TEXCOORD10/11
and RT3/4; current clip positions remain bit-identical in the fixture. Prior
camera orientation and wind are essential for billboard/leaf motion. Grass also
requires previous b11 collision ellipsoids: time-only wind replay misses trampling.

The other live SpeedTree VS `38A7AC06`, `3F34518C`, `5C2E9EBB`, `A9F08F55`
were inspected: their captured draws have color writes disabled and do not use
three G-buffer outputs. They are excluded from the motion pass. None of the six
new live VS appeared in the 8,368-entry readable game-cache signature inventory;
that inventory is therefore not an exhaustive SpeedTree permutation source.
Unseen biomes/materials must still be checked in-game.

Validation: new `tests/foliage_motion.cpp` passes WARP and NVIDIA for all six VS
with captured consecutive states, isolated contact motion and isolated wind
motion (18 cases per backend). Current clip-bit differences: 0. Previous-position
errors beyond 0.0002: 0. Contact motion is nonzero in grass; isolated wind is
nonzero in all five wind paths. Billboards have no isolated wind response but
respond to native camera/state changes. Four material paths pass native G-buffer,
accepted/rejected alpha or dissolve, valid/invalid history and vector/depth MRT
checks. Non-contact vertex tests explicitly unbind b11 and still pass, proving
that coverage no longer depends on stale grass state. Billboard material testing isolates alpha from grain; native grain math
is preserved and still requires in-game observation. The D3D11 debug layer is
not installed, so these are GPU assertions, not a clean debug-layer report.
Existing character/cloth/bird/tail tests and six fingerprint tests also passed.

Evidence: `tmp/witcher3classic-investigation/temporal-dev/foliage-20261023/`.
`grass-contact-walk.json` is the 120-frame moving capture. Per-VS `*-frames.json`
and `*-b*.bin` hold the native fixture constants. `side-draw-*.json` records the
excluded depth-only draws; `cache-foliage-signature-candidates.json` records the
negative cache search. Test logs: `tmp/foliage-test-warp.log`,
`tmp/foliage-test-nvidia.log`, `tmp/foliage-regression-warp.log`,
`tmp/foliage-regression-nvidia.log`, `tmp/foliage-compile-final.log`.

The user closed Classic, and the final Clang Release build/link succeeded.
Installed artifact: `build/Release/renodx-thewitcher3classic.addon64`, **4,491,776
bytes**, **2026-10-23 13:21:32 CEST**, SHA256
`608926DBD6B9D1EDA6D993FD5340A8E4E64DBA5B0170D3AF78A2C4993FC852F1`.
The game-folder addon remains the symlink to this artifact. Build log:
`tmp/foliage-release-build.log` (31 existing warnings, no errors). The user was
notified immediately that it is ready to relaunch. No live replacement was used.
The final non-contact-b11 tests and compiled CB-mask audit also pass; see
`previous-cb-mask-audit.json` in the evidence folder.

Next: verify DLSS → Diagnostics → Object Motion / Coverage with a stationary camera
in wind, while walking through grass, while panning, and across LOD transitions.
Check DLAA and an upscaling mode. First-visible model history can be invalid for
one frame; persistent or repeated invalid patches need a captured draw/CB audit.
Disable DevKit input capture before matched GPU timings. The architecture avoids
readback and redraw overhead, but no measured frame-time cost is claimed yet.
