# HartapfelFX CPU pipeline

## Disabled-feature overhead correction, 2026-11-07

The addon previously imposed substantial CPU overhead even with Preset Off.
Turning off its visual effects did not stop its descriptor mirroring, repeated
root-state allocations, native PSO rebinding, and unused submission bookkeeping.
The user rebuilt and tested the corrected addon in gameplay and reported that
the optimization "worked brilliantly". No controlled numerical before/after FPS
benchmark was recorded for this change.

Changes remain inside this mod, including its bundled `night/` and
`lighting/graphics/` support. Shared RenoDX utilities, other addons, the game
installation, global build settings, and vendored dependencies are unchanged.

## Evidence

A process-only capture of a slow gameplay scene with Preset Off collected 3,824
wall-clock thread-stack samples. Addon frames appeared in 198 samples. Repeated
stacks showed rendering workers waiting for an exclusive SRW lock in the
descriptor-copy path. The existing Release PDB lacked addon function symbols;
nearest exported names such as `std::runtime_error` are not evidence of thrown
exceptions. Source inspection and disassembly identified the descriptor-copy
loop and its device-wide lock.

These samples include sleeping and blocked threads. Their counts are not CPU
utilization percentages and do not establish the fraction of frame time saved.
They identify contention to investigate; gameplay acceptance comes from the
user's subsequent test.

## Descriptor metadata

`descriptor_cache.hpp` replaces this addon's use of the generic descriptor
mirror. Previously each update/copy held one exclusive device lock while
resolving heaps, potentially growing vectors and copying every slot. Independent
recording workers therefore serialized even when updating unrelated descriptors.

The replacement stores only descriptor type, resource/view identity, and buffer
offset/size. It does not copy game GPU resources, map their contents, read them
back, or acquire references to the underlying resources.

- Each slot has atomic payload words and a sequence counter. Copies to distinct
  slots have no common exclusive lock. Readers accept a coherent snapshot or
  return an unavailable input after a bounded number of retries.
- Heap storage is allocated on first observation. Ordinary copies do not resize
  descriptor vectors or allocate per-descriptor objects.
- A small thread-local directory cache avoids repeated directory locking.
  Directory mutations occur when a native heap is first observed or destroyed.
- A private lifetime notification belongs to the native heap. It removes the
  directory entry and invalidates cached identities on destruction, including
  native pointer reuse. It does not keep the game heap alive.
- Sampler heaps need no resource-identity shadow storage.
- Fog, clouds, surface lighting and RT hit inputs all read this same cache.
  The generic `trace_descriptor_tables` option stays disabled for HartapfelFX.

Descriptor metadata remains observable while features are off. Static native
tables may be created or copied then reused after a feature is enabled. Dropping
those updates would lose inputs or reuse stale bindings. This is small CPU
metadata maintenance, not resource cloning or a second GPU resource pipeline.
Runtime event registration is kept stable rather than changing ReShade's callback
vectors while recording threads may be using them.

## Native state and shader selection

`raster.hpp` records only targets, depth, viewports, scissors, topology and blend
factor, with command-local storage and retained vector capacity. It supports
native render-pass targets as well as ordinary target binds. This replaces the
general raster/swapchain snapshot dependency: no full snapshot opt-in, duplicate
pipeline map, input-assembler capture or extra root tracker is needed. The
exact-main runtime check caught the newer utility API's explicit snapshot
opt-in requirement; this narrow cache keeps both utility generations working
without enabling blanket capture.

The current main backend also creates its command-list handle under the raw
type UUID while its lookups use the addon's private namespace. That mismatch
prevented shader callbacks from seeing a bound pipeline. `state_namespace.hpp`
adapts only creation/destruction: it publishes the backend-owned handle under
the private key and preserves any other addon's default-namespace handle.
There is no per-draw adapter work and no shared utility edit. The exact-main
compatibility workload verifies that fog/cloud replacements execute rather
than merely compile.

Fog's temporary GPU passes copy the native PSO handle from the active graphics
or compute stage before issuing work and restore that handle afterward. They
do not use the legacy shader snapshot's `last_pipeline` field, which current
main leaves empty. This also avoids retaining a thread-local compatibility
snapshot across another lookup.

`lighting/graphics/rendering/bindings.hpp` uses fixed D3D12 root-argument storage
and validity masks. Root-signature changes invalidate masks instead of deleting
unordered-map nodes and constant vectors that the next draw must allocate again.
Partial constants and graphics/compute bind points remain independent. Native
D3D12 root descriptors contain one binding; descriptor arrays remain tables.

The Darker Nights colour pass reuses that snapshot instead of maintaining another
compute-root tracker. Fog no longer duplicates root-constant vectors already
captured by the cloud restoration path. The lighting pass borrows its immutable
recording-local snapshot for restoration instead of copying it for each pass.
ReShade API calls used by these passes bypass the native binding events, so the
borrowed snapshot remains the native state to restore.

`clouds/heaps.hpp` no longer locks command-local root state. D3D12 command lists
and ReShade's command-list API cannot be recorded concurrently. The native heap
hook caches its command alias, retains unchanged heap references, and consults
the alias registry only after an owner/interface change. Native CBVs use the
existing fog binding state; only API-injected CBVs require an overriding GPU
address. The stable ReShade API hooks still capture the HDR addon's partial root
constants and CBVs. Agility interface-alias handling remains intact.

Shader callbacks now share one fallback policy: restore the native PSO once
when leaving a replacement. A subsequent inactive draw performs no redundant
native bind. Native PSO binds and command-list resets invalidate that replacement
flag. This preserves engines that omit a redundant PSO bind between repeated
draws while avoiding a driver call for every inactive match.

## Feature and submission paths

- Fog captures sun inputs only when its volume grid is enabled. Empty fog
  recordings skip resource-pool scans and submission locks.
- Disabled clouds skip shadow input resolution and volume preparation. Adapted
  RT shaders still receive the required neutral cloud address before returning.
- Empty cloud recordings skip retirement locking when no retired allocations
  remain. Recordings that own work retain the original completion fences.
- Disabled contact shadows skip motion observation and motion-barrier locking.
- RT hit recording tokens are replaced only after a producer used the recording.
  Active UAV invalidation walks the bound layout once instead of re-resolving
  the layout separately for every UAV register.
- The native submission hook passes straight through when no recording owns a
  private producer field. Idle command lists do not enter its registry. Active
  producer recordings still refresh aliases, take leases and signal a fence
  after the real native submission.
- Darker Nights skips inactive grading-pipeline lookup and empty scratch-resource
  retirement work.
- Persistent cloud upload pages are released without a redundant destructor
  `Unmap`. The actual-addon test with DevKit present exposed teardown re-entry
  through native unmap hooks after device listeners had already been destroyed.
  D3D12 explicitly supports leaving these upload buffers mapped until their
  final resource reference is released; CPU pointers are never used afterward.
  See [Microsoft's persistent mapping contract](https://learn.microsoft.com/en-us/windows/win32/api/d3d12/nf-d3d12-id3d12resource-map).

The native weather, clock, lighting, camera, depth and motion inputs are still
borrowed from the game's passes. Player Fill Lights and night illumination
continue to use the engine's constant builders. Raster, RT and PT shader
replacements and their settings are retained.

Private volumetric/history/material fields still need allocation ownership,
invalidation, barriers and completion fences. Removing those would allow queued
GPU work to read overwritten or destroyed data. The optimization removes idle
and redundant bookkeeping while preserving these active-work requirements.

## Validation

Use the established `clang-x64-release` target. While the game has the addon
loaded, use compile-only validation; the user controls closing and launching it.

```powershell
./src/games/thewitcher3remastered-hartapfelfx/build-release.ps1 -CompileOnly `
  -D3D12SdkPath <captured-game-sdk-directory>
```

The correction passed:

- Release addon object compilation and strict replacement-shader compilation.
- `tests/descriptor_cache.cpp`: concurrent descriptor rewrite/read integrity,
  eight independent writers, native heap destruction, and root-signature
  validity reset. Its timing output is a CPU microbenchmark, not gameplay FPS.
- Existing binding/source-layout and immutable-upload lifetime/readback checks.
- Production fog PS/CS and Raster/RT local-light transport, interior boundaries,
  temporal reconstruction and HDR radiance checks.
- 98 production cloud GPU cases across six qualities, the 1,000-switch native
  weather cache test, particle volumes and terrain-depth clipping.
- Native DXR state-graph and HDR sun/moon replay checks.
- `tests/submission.cpp`: closed Agility command lists, refreshed native aliases,
  completed producer leases and idle submission bypass.

The actual-addon compatibility workload uses the existing captured native
shaders and both HDR addon load orders:

```powershell
./src/games/thewitcher3remastered-hartapfelfx/tests/startup.ps1 `
  -ReShadePath <test-reshade-dll> -HdrAddonPath <hdr-addon> `
  -NativeCapturePath <native-captures> -RayCapturePath <ray-captures> `
  -D3D12SdkPath <captured-game-sdk-directory>
```

The final clean Release candidate passed both load orders at both fog qualities
on Agility SDK 619, including real native RT dispatches, HDR root/heap
restoration and device teardown, with zero observed access violations. The
upload teardown correction also passed the local workload with DevKit loaded.

For further gameplay comparisons, keep the same scene, camera, weather,
resolution, rendering mode and HDR setup. Compare addon absent, Preset Off,
lighting only, fog only and clouds enabled. Check both cold loading with Preset
Off and toggling features after entering gameplay. Record CPU frame time, GPU
busy time and frame rate separately. Do not infer zero overhead from GPU usage
alone: shader selection and the necessary descriptor metadata callbacks remain.

## Weather-driven cloud families, 2026-11-07

Cloud-family selection adds no resource, draw, particle or descriptor tracker.
The present callback reads a bounded native area/weather snapshot using the
already validated native reader, interns the small name catalog once, and
publishes source/target recipe IDs and the exact native blend in one lock-free
64-bit word. Rendering workers read that word and immutable tables; they do not
read game memory, take a new lock, scan assets or inspect cloud resources.
The selector is inactive with Native clouds/Preset Off. Its native-memory mock
measured approximately 3.5–5.2 microseconds per active update in local runs; this
is a CPU microbenchmark, not a gameplay frame-time measurement.

The existing 512-byte parameter upload page carries 192 bytes of cloud parameters
(previously 112), with fog still starting at offset 256. Buffer counts, root
arguments, descriptor banks, cache keys and per-frame allocation behavior are
unchanged by family selection. The later sign-clock correction adds one private
root CBV, as described below. Recipe edits reuse the same immutable descriptor set; the GPU suite
explicitly checks this. The existing weather-publication pass smooths two vectors
in reserved history/header space; it adds no dispatch, synchronization point or
readback. Family weights snap to authored zero only below 1e-6 error so settled
thin-only weather can skip the 3D work completely.

The existing 512-square cirrus atlas is R16F with its original mip chain.
The rejected middle-sheet/altocumulus layer and its two extra material channels
were removed at the user's request. This removes approximately 2 MiB of fixed
atlas data per device relative to the first family implementation, along with
mid-sheet view/environment lighting, sunlight samples and shadow contribution.
There is no signed thin-depth tag or special sheet reconstruction path. Main
cloud families still share one 3D march; high cirrus retains separate atmospheric
composition and its contribution to the existing sunlight shadow paths.
Edge refinement reuses existing shape samples and the cirrus mip chain. A shared
0.5 multiplier on native wind offsets adds no resource or per-frame work.

Validation includes static recipe regeneration, native-memory selector fixtures,
all family recipes on the production GPU pipeline, paused/interrupted fades,
settled cirrus-only work removal, foreground clipping, terrain shadows and native
wind alignment. The exact live performance result must be measured with the
same renderer, weather, camera and settings; layered weather has a different
visible workload from the earlier generic deck.

Historical first-family build, before removal of the middle sheet: closed-game
paired GPU timestamps at 1920x1080 Medium, default screenshot
appearance (Coverage130/Density12/Size60/Thickness60), native clock and camera
held fixed, measured weather + shadow + render + environment work:

| Workload | Earlier generic deck | Cloud families + edge refinement |
| --- | ---: | ---: |
| Thin-only light weather | 2.705 ms | 0.278 ms |
| Cumulus plus mid sheet | 2.758 ms | 3.007 ms |
| Storm deck | 2.692 ms | 2.665 ms |
| Generic fallback control | 2.775 ms | 3.106 ms |

Values average the two per-process 16-frame medians in a baseline/candidate/
candidate/baseline ordering (`tmp/hartapfelfx-validation/families-timings-final.json`).
The mixed case adds about 0.25 ms of rendering; it is not a zero-cost feature.
The generic-control runs had more timing spread. Recipe workloads change visible
occupancy, so their savings are not an isolated shader-instruction benchmark and
do not predict whole-game FPS. There are no new GPU waits, readbacks or resource
tracking callbacks. The measured selector update is separate CPU work.

The historical timing table above includes the now-removed middle sheet and
must not be quoted as current-revision performance. Final no-sheet measurements
and validation status are recorded below when available.

The no-sheet, half-native-wind revision passes strict Release C++/HLSL checks,
148 production cloud GPU cases, all 25 native layer-pair transitions and the
native-memory selector, descriptor/lifetime and ray-configuration regressions.
The selector measured 3.56 microseconds per active update in the final mock run.
GPU shadow displacement matches the half-speed signed world-space translation,
not just an arbitrary changing pattern. Known sheet-only recipes are checked
against an exactly clear background; the removed layer has no view contribution.
HDR sun/moon replays and all four actual-addon HDR load-order/fog-quality
startup configurations pass, including native RT/PT dispatch and state restoration.
The user rebuilt and relaunched the game-linked revision; its 21 cloud shaders
and both static family tables match the validated source. Clean closed-game
timings and live visual acceptance remain pending.

## Sign effects and cloud/shadow clock selection, 7 November

The sign regression is reproduced in the actual-addon host: separate light/sky
GlobalCB pages made the former exact-address admission gate lose frame 1.
The first lookup correction passed that case, but an early-shadow probe then
proved that a light draw retaining effect b0 data animated shadows at 0.125 s
while the material/sky clock was about 100 s. Shadow inspection occurs before
the sky render, so the later correct publication cannot conceal the mismatch.

The combined revision retains the exact admission match where available and
falls back only to the retained source for the same b12 view. The existing
material-pass clock capture is bound at one additional private root CBV (b7);
uniform camera/jitter/tag checks select it for weather, shadow, view and history.
When that capture is unavailable, the existing native input remains the fallback.
No new capture pass, GPU resource, descriptor heap, tracker, readback or wait is
introduced. The owned root signature grows by two DWORDs; shader selection adds
uniform comparisons/loads, rather than another image or raymarch pass. Existing
native root/heap restoration remains required and is covered by the HDR host.
These are mechanism and allocation claims, not a gameplay FPS measurement.

The replay uses 25 frames / 75 delayed split recordings: 24 valid cloud views,
including distinct clock allocations, effect data on the sunlight b0 binding,
and one deliberately unrelated b12 view which must remain native. It checks the
early shadow time before the sky draw and retains the PT-without-material-clock
fallback case. The GPU suite separately checks reuse of a clock allocation with
a different native time. Strict Release compilation and 149 production cloud GPU cases pass. All four
actual-addon HDR load-order/fog-quality configurations pass, including all
early-shadow probes, separate clock allocations, view isolation, native RT/PT
dispatch and native root/heap restoration. The final installed build, after the solar-direction correction below, was
verified live by the user: shadows align with the sun and repeated Igni casts
leave volumetric clouds active. Artifact status is recorded in the handoff.

## Solar projection alignment, 7 November

The held live scene has atmosphere b12[38] = (-0.81422955, -0.31472936,
0.48782760) and sky-solar b12[204].yzw = (-0.84727848, -0.32750398,
0.41816306). Their angle is 4.479 degrees; their intersections with the 1200 m
cloud base differ by about 460 m. The original sun pixel DXIL uses b12[38] for
atmospheric attenuation, while native sky 0x449D3390 computes its solar lobe
from dot(view_ray, b12[204].yzw). Earlier notes claiming b12[38] is the visible
solar-position authority are superseded by this audit.

Cloud shadow projection now prefers the native solar vector, falling back when
it is unavailable. The directional visibility field, volume scattering and
cirrus use that same direction in daytime; the native dominant-light direction
remains the fallback when the sun is below the horizon. This changes no resource,
root layout, tracker, descriptor allocation, pass or sample-count setting. An
existing uniform direction lookup now selects the solar input. Ray length and
visible occupancy can still change GPU work; no gameplay FPS claim follows.
The live values form a production-GPU projection regression. Strict Release
checks and all 150 GPU cases pass, along with all four actual-addon HDR/RT/PT
startup configurations. The user rebuilt and launched the correction; all 21
cloud shaders in the game-linked addon match the tested shaders. The user confirms that shadows now align with the visible sun and that
volumetric clouds remain active after repeated Igni casts. Artifact hashes are
recorded in the handoff. This is visual/functional acceptance, not a measured
gameplay frame-time result.

## Realtime cloud authoring, 7 November

Twenty-four added controls use six float4 rows. The family transition is packed
into three rows (source cumulus/deck/cirrus/known, target equivalent, blend plus
source/target fallback coverage), freeing two previously reserved-heavy rows.
The complete cloud parameter block is exactly 256 bytes; fog still starts at
256 in the existing 512-byte upload page. Root bindings, descriptor cache keys,
texture counts, upload page size and rendering passes are unchanged. No slider
rebuilds a material or texture or starts resource tracking/readbacks. The CPU
configuration snapshot includes all 24 controls in history revision changes.

Shared-header family vectors move to 320/336. Base altitude is published at 288
for terrain, water, vertex and RT/PT receivers. The same existing metadata copy
extends by 16 bytes; its source buffer grows from 208 to 224 bytes (the same
64 KiB D3D12 allocation granularity). No extra copy command/resource is added.
Native adapters were regenerated from SHA-verified captures with the updated
receiver helper; their original writes/samples/queries/IO are audited unchanged.

Shape and erosion use existing mip-filtered samples. New controls add scalar
shader math and uniform decisions; non-neutral density/top contrast can add
power operations. Neutral values bypass those extra powers. Appearance changes
also change occupied ray lengths and early exits, so no constant or zero GPU
cost is promised across artistic settings. Sampling quality remains separate.

The new GPU checks read all 24 authoring scalars through the actual HLSL layout,
exercise every slider endpoint, require an observable image response, verify
cirrus removal also clears its shadows, test paired extremes and validate native
base-altitude metadata/above-layer exclusion at 300 and 5000 m. Together with
the previous suite, 203 production GPU cases pass. Actual-addon compatibility,
neutral-image comparison, timing and live UI status are recorded in the handoff.

## High-sheet removal, 8 November

The user rejected the remaining background streaks and explicitly selected full
removal of the high sheet. The cirrus atlas, ten startup generation/mip dispatches,
two setup PSOs, view/reflection sampling and all beam/terrain/volume shadow terms
are removed. Four high-cirrus sliders are removed; the 20 main-cloud authoring
controls remain. Authoring storage is now 80 bytes and Parameters is 240 bytes,
within the same 512-byte upload page and fog offset256. Shared receiver metadata
and native adapters retain their existing layout. No new tracking or GPU work.

Static recipes keep the authored effects as evidence, but emit zero high-sheet
strength; 16 recipes cover the same 56 regional states/30 names. Former high-only
weather is checked for clear sky and no native terrain shadow. Earlier sections
describing a retained cirrus sheet or 24 controls refer to the checkpoint state.
Final build/capture/startup results are recorded in the handoff.

Strict Release and 194 production GPU cases pass, including the 20 retained
controls. All four actual-addon HDR/RT/PT configurations pass. A 1920x1080
former-high-only capture matches clear RGBA exactly; main-only RGB mean absolute
error against the checkpoint is 4.98e-11 (maximum0.000125). No closed-game GPU
timing has been recorded for this removal; this is not a quantified FPS claim.

## Preset #1 defaults and wind, 8 November

All 81 active setting defaults match the saved mod Preset #1 snapshot; 20 numeric
defaults changed. These are initial/reset values using the existing UI parser.
The user's chosen sampling step and shapes retain their ordinary cost. No new
resource, tracking path or pass is introduced. The shared native wind conversion
is now `20 * 0.35`, retaining game direction/calm/strength across every weather
state and the same weather/body/shadow/reprojection field. Release and 194 GPU
cases pass, including all 25 weather-pair wind cases and signed shadow translation.
Earlier 0.5x/half-speed references describe the previous setting.

All four actual-addon HDR/RT/PT configurations pass with the new defaults.
The lighting-controls fixture now expects the authored1.3 light diameter; its
GPU readback confirms1/1/1/1.3 for PBR/contact/soft/diameter.

## Moon occlusion and settings layout, 8 November

Live b12 sky constants put the sun below the horizon and the moon above it.
The old terrain pass selected that below-horizon sun and invalidated night cloud
shadows, while body shading used a different fallback. One shared light selector
now chooses the visible sun/moon direction. The native lunar sky lobe receives
the same camera-to-moon cloud transmission when the map matches that emitter.
The measured moon disc also respects that field. Broad sky and the daytime solar
profile remain separate. The existing shadow map and bindings are reused; no
new GPU resource, pass, readback, tracker or per-frame allocation is introduced.
Working moon shadows necessarily perform their existing enabled shadow work.

Menu ownership, sorting and description allocation happen once at addon startup.
The overlay uses existing settings and save/load APIs; its UI work runs only when
drawn. Per-tab resets alter only typed settings owned by that tab, including
conditionally hidden values. Support links open only on a user's button click.
Release and196 cloud GPU cases pass, including two captured-night direction/
ground/glow regressions; the menu tests verify four reset scopes and filtering.
Final compatibility and live acceptance are recorded in the handoff.

## Compact menu revision after live review, 8 November

The user confirmed that clouds now correctly shadow both moonlit ground and
lunar sky glow. Their menu review requested hover-only help, the standard preset
slider, and a short shared Help & About section instead of a popup. The revision
removes all generated inline description settings and their startup allocations.
The footer uses the Classic support destinations and framework-style tinted
buttons. Four tab ownership and reset behavior are preserved. Engine shaders
and GPU bindings are unchanged; targeted menu/rendering and profile-integration
checks validate this presentation change. Previous descriptions of inline hints
and the modal Help panel refer to the superseded menu candidate.

## Cloud camera stability, 8 November

A bounded 120-frame native capture showed a stationary camera, one unchanged
frame-buffer address and steady wind (-5 native units/s, within 0.4% after FP32
quantization). The translated inverse view-projection matrices changed their
rounding with native rendering jitter. Reconstructing a world point and then
subtracting the camera amplified that rounding into visible cloud-ray movement.

CloudRay now inverts the native perspective and rigid camera rotation directly,
including the game's projection jitter. It does not subtract large translated
coordinates. Four consecutive captured cameras reproduce the defect on the GPU:
maximum ray-to-native-pixel error falls from 0.154338 to 0.0000231876 pixels at
160x90. This is a numerical accuracy measurement, not an FPS claim. The change
adds no resources, passes, tracking, readbacks or per-frame allocations. Shared
wind/body/shadow advection remains 0.35x native speed. The Release GPU suite
includes the four captured-camera regressions; live visual acceptance is separate.

Strict Release, all 200 production cloud GPU cases and HDR sun/moon capture
checks pass after rebuilding every affected shader. The previous compiled
shader set failed the new camera test before the correction.
