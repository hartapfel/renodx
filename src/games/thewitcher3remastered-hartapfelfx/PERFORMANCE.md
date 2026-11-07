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
