# Local volumetric light occlusion

## World visibility correction, 11 November 2026

Status: the user confirms local volumetrics are visible in PT after the native
CameraCB correction and that the directional torch cutoff looks much better
after restoring the native emitter endpoint rule. Raster has prior acceptance.
Gameplay frame-time measurements and exhaustive world coverage are not claimed. The older screen-depth supplement below
did not solve the reported roof/platform leaks and torch halos. It is retired
from production light injection, including its camera-depth column crop.

### Root cause and comparison with Classic

The native Remastered `9A6F318E` shader reads `t17`, an eight-layer packed
ray-traced local-shadow texture. Nine bits identify the light; seven bits encode
visibility. When a matching RT result exists, the shader bypasses the atlas/cube
shadow lookup. The fog adapter used only `t9`/`t10`. Those resources cannot stand
in for world visibility when the engine uses its separate RT shadow path.

The working sunlight path has its own world shadow data. The Classic local-light
adapter uses the engine's world atlas/cube maps; it has no corresponding native
RT-mask dependency. This is a rendering-path difference, not evidence that a
larger screen-depth sample budget can repair the Remastered path.

The `t17` result belongs to the visible surface at a pixel. Applying it to every
fog sample in that camera column would shadow unrelated air. A single-layer
camera-depth trace also cannot see an occluder behind the first visible surface
or outside the screen. Sharing one such result over a logarithmic cell and
cropping the column introduced additional camera-dependent discontinuities.

The native spotlight projection was audited again against its scalar expression.
Its X basis is `cross(direction, up)`; it is retained unchanged.

Evidence: `tmp/local-light-root-20261111/inputs.json`, the actual
`0x25AB4BF4` local-shadow library disassembly and native `9A6F318E` source.
The existing DevKit DXR observer was left running with its existing settings.

### Implementation

- Add `HartapfelVolumeLocalRGS` as a separate library to the exact native
  `0x25AB4BF4`/10,616-byte local-shadow pipeline and the full PT/SER
  `0x47BC87E1`/231,144-byte generators (including the cloud adapter's version).
  Preserve the original library,
  exports, hit/miss shader table, local-root associations and other adapters.
- Trace finite fog-sample-to-emitter segments through the native scene BVH.
  Reuse the native 20-byte `GbufferPayload`, shadow tag, material/alpha any-hit
  behavior, instance mask and hit-group indexing. Preserve the native light's
  two-sided flag; avoid a blanket opaque inline-ray approximation.
- Match the current depth resource/present epoch and compare camera origin from
  the native 1,632-byte `CameraCB` (`b0,space1`, row 8) on the GPU. The captured
  CBV is bound directly at private `b4,space61`. Ray queries use the fog pass's world reconstruction;
  the source ray pass's TAA jitter/inverse projection need not be identical.
  HDR/night adapters can clone the same frame into a different upload resource;
  a CPU pointer comparison rejects those valid inputs. The source recording owns
  captured native bindings; cross-list replay targets the destination list.
  Captures expire at reset/destruction or the next present. The destination
  parameter allocation retains submitted native objects until its queue lease
  retires. Existing GPU frame/camera/header checks remain active.
- Compare the native ray-generation identifier on the GPU before injection.
  Preserve the native export names/renames from the state description instead
  of assuming a canonical function name. Check every matching frame/depth
  candidate; presence of a named export alone does not identify the selected
  SBT record. A per-dispatch owner token at byte 1064 rejects duplicate injection.
- Restore compute/graphics roots, heaps, HDR controls and the native pipeline
  through the existing state scope after the additional dispatch.
- Preserve the original raster world-map path and local-shadow switch. Missing
  RT inputs skip local injection instead of reusing another frame/view or
  silently producing unshadowed RT beams. Diagnostics count these skips.

### Controls, costs and limits

The existing advanced Lamp Occlusion Quality setting now selects Low, Balanced,
High or Ultra: one, two, three or four world-visibility/radiance quadrature
samples per contributing fog-cell/light pair. Its stored key and default value
are retained. The old value zero now means Low; all enabled RT quality levels
test world visibility. Raster mode still follows native shadow-map quality.
The main appearance controls and Lamp & Fire Shadows switch stay in place.

This is additional ray-tracing work. Gameplay GPU cost is not yet measured.
Raster lights without authored native shadow maps still lack world occlusion;
this change does not generate missing raster shadow maps or change emitter
positions. Geometry omitted from the native BVH or rejected by native caster
rules cannot become an RT occluder. Froxel resolution and temporal filtering
still limit fine shadow detail. Standalone Light Alignment is a separate mod.

### Verification

`tests/local_ray_gpu.cpp` runs the exact production ray-generation bytecode
against real triangle acceleration structures without a depth texture or a
surface shadow mask. It tests an opaque wall, rejected alpha/caster hits,
geometry past the emitter/sample endpoints, repeated results, the GPU export
guard and reversed winding with the two-sided light flag, at every quality.
It also checks wrong-then-correct candidates and repeated matching candidates:
the correct dispatch runs once without doubling energy. Cloned frame buffers
and independent native projections preserve the same energy; foreign or absent
native camera origins and stale fog-field contents are rejected. Native endpoint
exclusion tests distinguish a near-emitter housing from a farther wall, a zero
exclusion, and native mapped/unmapped fallback selection. All 72 production-ray
cases pass; the D3D12 debug layer was unavailable.

`tests/local_ray_startup.hpp` requires the actual native local-shadow library
and added fog export to link through the loaded addon. It must pass with both
HDR load orders. The split-recording test separately requires conservative
behavior when no DXR producer exists. Build and installation results will be
recorded after the final workflow completes.

Regenerate the owned helper with `python fog/prepare_ray.py` from the mod
directory; `build-release.ps1` checks its recursive source fingerprint.
The fingerprint normalizes CRLF/LF so a clean Git checkout is not marked stale
solely because of the platform's text line endings.
No native-library recompilation or game rebuild is required for installation.

### Live RT/PT startup follow-up

The user confirmed the raster result is working and requested that it stay.
The first RT/PT candidate produced no local beams and is not accepted. Live
read-only diagnostics confirmed a DIRECT command list and an exact match of
the fog volume's frame buffer, 1920x1080 viewport and 256x144x128 grid. Queue
type and resolution were therefore retained.

The first candidate cleared its dispatch callback on DLL thread notifications.
It also treated `pipeline_stage::all` from ordinary D3D12 PSOs as a ray state.
Cloud compute scopes restore DXR through the API, which emits no second native
bind notification. Only explicit `all_ray_tracing` notifications now update
the ray-state cache. The thread lifetime test covers actual DLL entry calls;
the native startup fixture reproduces compute work followed by API DXR restore.

The next live build reached the local callback but rejected export lookup
(zero captures, nonzero ray calls and missing-export skips). The selector now
records native export aliases and inherits their metadata through state
creation, and its real-native-library fixture deliberately renames the RGS.
Native SRV table metadata is generic texture-SRV metadata even for `t18`'s
structured buffer; the adapter now resolves the table entry before validating
the actual buffer view. Missing native/fog exports and missing frame inputs
have separate counters. Real native PT/SER states are tested independently of
the separate local-shadow generator, with both HDR addon load orders.

The installed ReShade runtime returns structured-view metadata as a byte offset
and two packed DWORDs (NumElements and StructureByteStride). Treating that field
as a byte size rejected the valid 256-element, 160-byte light buffer. The decoder
supports that layout and the older repository backend's FirstElement/NumElements
layout. An actual-runtime descriptor test verifies a nonzero FirstElement of 2
as byte offset 320 and count 4, including invalid-range rejection.

The subsequent live PT build now submits the owned ray dispatches: the captured
log records 1,170 volume dispatches with zero missing-source skips. The user
still reports no visible local scattering, so this is not gameplay acceptance.
A bounded asynchronous header readback now reports shader selection, frame,
field and ownership gates plus the GPU light count. Readbacks are fence checked
after native command submission; the recording retains their destinations for
safe replay. This diagnostic is intended to locate the remaining GPU rejection
before changing visibility behavior again.

The diagnostic build reports `stages=3`, `owner=0` and a valid fog field: the
native shader identifier matches, but the source/deferred row-286 equality
rejects every candidate. Row 286 contains TAA jitter, not a frame timestamp.
Requiring identical jitter is inappropriate for a world-space BVH query and
blocked the entire effect before any TraceRay call. Source epoch/depth,
camera-origin and viewport checks remain; the fog field still validates its
own exact current jitter/matrices. The corrected candidate requires live
verification; no visible-light success is claimed yet.

Removing jitter equality advanced the live diagnostic to `stages=7`; camera/
viewport validation still rejected injection. Read-only capture inspection
found both a 64-KiB frame clone and the exact 5,632-byte fog frame resource in
the current-epoch sources. The helper's validation had been reading the replayed
native `b12,space2` descriptor table instead of the retained captured CBV.
It now receives the captured resource/offset explicitly at `b4,space61` and
reports the source and fog camera/viewport values together. Eight private roots
cost 16 DWORDs; extension refuses native signatures above 48 DWORDs. This
removes descriptor-table aliasing from frame validation without removing its
camera/view checks. Gameplay verification is still pending.

The direct-binding diagnostic then proved `SharedPixelConsts` contains a zero
camera and zero viewport in the real RT/PT ray pass, while the deferred fog
camera is `(191.099,146.429,34.4669)` and its reciprocal viewport is
`(0.000520833,0.000925926)`. It also reports 22 native local lights. Thus a table
alias alone does not explain the rejection: the validation used the wrong
native cbuffer ABI. Both audited native generators reconstruct rays using
`CameraCB` at `b0,space1`, with origin at row 8. The source capture now retains
that CBV and the helper validates its actual origin. The native startup fixture
binds this separate camera and deliberately leaves the environment buffer's
camera fields zero. Synthetic GPU tests use a nonzero camera origin and the
distinct native camera layout. This correction still awaits live acceptance.

The subsequent live build passes every GPU gate (`stages=63`, `owner=1`, 43
lights), with identical source/fog camera `(190.015,137.661,34.9766)`. The user
confirms the fog is visible. The remaining artifact is described as an invisible
wall cutting the torch light in one direction, rather than a halo. The current
scene preview is `tmp/local-light-root-20261111/torch-angle.png`.

### Native emitter endpoint follow-up

The native LocalShadowsRGS also shortens its finite segment near the emitter:
`d - min(e, max(d-e,0))`, with nonnegative exclusion `e` from CameraCB row 78.x
or the native unmapped-light fallback at 79.z when enabled by 79.x. The fog query
had omitted that contract and stopped only 1 mm before the point-light center,
allowing a torch's own housing to block an entire direction. It now follows the
native endpoint exclusion and retains the numerical 1 mm endpoint guard.
Atlas allocation is checked for the sample-to-light direction, not the camera
direction; the choice remains independent of viewing angle. Exclusion does not
move a light or change its falloff, and no new bias control is exposed.

The 72 GPU cases include opaque geometry inside this native emitter region,
outside it, a zero exclusion, enabled/disabled fallback, and a mapped light that
must keep the default exclusion. Walls outside the excluded segment still block.
The live endpoint result remains pending. Installed alignment scripts, generated
map and both static world files hash-match standalone Light Alignment 1.1.1;
its 337 identities and measured torch particle offsets are preserved.

### Accepted live candidate

The user's rebuilt Release candidate has SHA-256
`128c9c541ef82b6fc8dd7b274f7c2ffc85d71fd20330a0a3e466a9d0e23a2474`.
The live header reports all gates accepted (`stages=63`, `owner=1`, 15 lights),
identical source/fog camera `(186.38,142.472,34.6137)`, and native endpoint
values default `0.25`, fallback `0.3`, override enabled. The user returned to
the previous bad angle and confirmed it looks much better. This is scene
acceptance for PT; native RT/PT pipeline fixtures cover both export paths,
but a separate live hybrid-RT scene comparison is not claimed.
The installed HDR addon remains byte-identical to the initial verified file.
The accepted DLL also passes the isolated actual-addon startup suite in both
HDR load orders and both fog quality variants (`startup13.log`): native PT/SER
and renamed local-shadow states, structured light-view decoding, native state
restoration, split recordings and cloud/fog integration. Release object and
lighting integration checks pass (`check-runtime13.log`); all 72 production-ray
GPU cases pass (`test-ray9.log`). The D3D12 debug layer was unavailable for the
standalone ray test. No additional rebuild is needed for these documentation
updates.

### Proven source basis

- [Microsoft DXR functional specification](https://microsoft.github.io/DirectX-Specs/d3d/Raytracing.html):
  shader tables, identifiers, any-hit processing, finite ray extents and resource
  lifetime/synchronization contracts. The implementation preserves the game's
  existing shader contract and adds its own ray generator.
- [Microsoft DXIL library descriptor](https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ns-d3d12-d3d12_dxil_library_desc):
  explicit export ownership for the added helper.
- [Microsoft descriptor heaps overview](https://learn.microsoft.com/en-us/windows/win32/direct3d12/descriptor-heaps-overview):
  descriptor-table contents have their own mutation/synchronization contract;
  retaining a table handle does not snapshot its descriptors.
- [Microsoft readback heaps](https://learn.microsoft.com/en-us/windows/win32/direct3d12/readback-data-using-heaps):
  header diagnostics use a readback buffer, resource transitions and completion
  fences before mapping, without waiting on the CPU.
- [Wronski, SIGGRAPH 2014](https://bartwronski.com/wp-content/uploads/2014/08/bwronski_volumetric_fog_siggraph2014.pdf):
  lighting-volume injection with visibility evaluated for the participating
  medium, followed by integration. The existing grid/integration stays intact.
- [NN/g progressive disclosure](https://www.nngroup.com/articles/progressive-disclosure/):
  retain familiar appearance controls and place the sample-cost choice in the
  existing advanced quality section, with concrete quality labels/tooltips.

## Historical implementation (retired)

The following records the earlier attempt and its original validation. Numerical
success of that approximation did not establish gameplay acceptance; the user's
later screenshots demonstrated its remaining leaks and instability.

11 November 2026. The standalone light-position package is separate from this
addon rendering correction. The user confirmed the native bathhouse bowl patch
works, then supplied an outside-wall example where lamp scattering leaks through
the building and nearby props.

## Evidence and implementation

A bounded two-frame `9A6F318E` capture has ready `t18` copies. Nearby lamp records
have both native shadow availability fields zero. Other records have shadow maps
but small surface-shadow blend weights (for example 0.037 or 0.483). These are
records in the captured allocation; the count constant-buffer copy is not reliable
enough to claim a total scene light count. Evidence: `before-inputs.json`,
`lights.json` and `before-cleared.json` in `tmp/local-light-occlusion-20261111`.
Diagnostic collection is stopped, with no pending allocations.

The previous volume code treated missing shadow data as fully visible. It also
reused the surface fade `(1 - shadow_strength) + visibility * shadow_strength`,
which restores unoccluded energy even when the map itself reports a blocker.
The native surface shader uses that blend intentionally; it is not geometric
visibility for the medium. Deferred surface, PBR and Small Object Shadows code
retain their existing behavior.

The volume now:

- Evaluates available native atlas/cube visibility directly, preserving dim HDR
  shadow values without subtracting them from one.
- Uses a 2 mm world-distance receiver bias instead of the surface shader's 1%
  distance bias. This prevents the volume's gap growing to centimetres/metres
  with light distance. The native ESM encoding/exponent is retained.
- Clamps atlas lookups to the selected tile's half-texel interior and checks
  its dimensions, avoiding samples from another light's allocation.
- Supplements native maps with perspective-correct camera-depth ray intervals
  from a froxel's visible portion toward each contributing local light. It
  handles coaxial rays, oblique rays, near-plane clipping and finite depth slabs.
  It does not infer geometry behind the first visible depth layer.
- Crops local-light injection at the opaque depth of each volume column. This
  prevents a logarithmic terminal cell from averaging hidden local light back
  into its visible part. Sun/cloud lighting and extinction are unchanged.

`local_occlusion.hlsli` reads the existing native `t0` depth input shared by both
`E6A77B56` and `9A6F318E`. View/projection rows and depth decoding match the native
Remastered adapter and existing contact-shadow trace. No new resource allocation,
CPU readback, geometry replay, native shadow-map generation or engine light
property change is introduced. One depth trace per light/visible cell is shared
by the four existing lighting quadrature samples.

## Controls and limits

### Torch source inside its holder, 11 November 2026

The later dark-halo report was reproduced with native depth and light-buffer
inputs. The torch's old point source lies about 1.7 cm behind the visible depth
at its screen projection. The added visibility test therefore sees the torch
head as a blocker for most nearby rays. Candidate-hit reprojection alone does
not remove this condition. Inspection of the exact `torch_fx1.w2p` resource
shows its uniquely named flame emitter initializes 10 cm above the effect's
attachment root, with a 1 cm local-X displacement. The alignment map had omitted
that internal offset for this multi-emitter particle.

Standalone Light Alignment 1.1.1 corrects all thirteen supported torch families
using this particle, through the existing native slot matrices. This repairs
the emitter placement while retaining the depth and native-map geometry tests.
Shadow bias, strength and sample budgets are unchanged. The other 324 fixture
bindings, runtime script and addon are unchanged. The exact input hash, bounded
named-emitter parser and rejection tests are documented in
[the alignment implementation](../lighting/alignment/README.md#torch-self-shadow-halo-version-111).
Evidence: `tmp/local-light-halo-20261111`. Live depth/halo acceptance follows
the user-controlled restart of the installed map.

**Lighting > Volumetric Light Quality (Advanced) > Lamp Occlusion Quality** defaults
to **Balanced**. The existing **Lamp & Fire Shadows** switch is the master for
native and supplemental visibility. Native Shadows Only omits depth tracing;
Balanced, High and Ultra allow up to 8, 16 and 24 depth intervals respectively,
with early exits. They do not increase the engine's shadow-light budget. Actual
game GPU/FPS overhead has not yet been measured.

The setting uses `VolumeLightOcclusionV1`, an existing reserved float in the
48-byte `VolumeLightData` layout. The constant-buffer size/root layout is unchanged.
The Lighting tab owns/reset/presets the control; Fog resets do not change it.
Its value is included in volume-history compatibility checks. Existing master,
appearance controls and Preset Off behavior remain intact.

This is a hybrid of native world shadows and a visible-depth supplement.
Raster, hybrid RT and PT use the same adapters. Offscreen or hidden geometry
without a native shadow map can still leak; increasing screen-depth quality
cannot manufacture that missing geometry. Alpha-tested geometry in the depth
buffer participates; ordinary transparent glass does not become an opaque slab.
Thin silhouettes and disocclusions remain limited by depth and froxel resolution,
and temporal stabilization can produce transient history artifacts. All-mode
visual acceptance and performance measurements remain distinct from numerical
GPU validation.

## Research basis

- [Wronski, SIGGRAPH 2014 volumetric fog](https://bartwronski.com/wp-content/uploads/2014/08/bwronski_volumetric_fog_siggraph2014.pdf):
  frustum lighting volumes and reuse of scene shadows. Retain the existing
  injection/integration pipeline rather than a postprocess light-shaft blur.
- [McGuire and Mara, JCGT 2014](https://jcgt.org/published/0003/04/04/):
  perspective-correct screen-space ray traversal and finite camera-depth
  intervals. The implementation is a bounded supplementary shadow query;
  single-layer and offscreen limitations are explicit.
- [Annen et al., Exponential Shadow Maps](https://www.tommertens.com/old-academic/papers/gi_08_esm.pdf):
  filtered exponential visibility. Native encoding is reused, with no invented
  exponent change or threshold advertised as exact visibility.
- [Microsoft, improving shadow depth maps](https://learn.microsoft.com/en-us/windows/win32/dxtecharts/common-techniques-to-improve-shadow-depth-maps):
  precision/bias tradeoffs and detached shadows. Volume samples are not
  surface receivers, so the inherited radius/distance-dependent surface bias
  is replaced by a small world-space offset.
- [Epic volumetric fog](https://dev.epicgames.com/documentation/en-us/unreal-engine/volumetric-fog-in-unreal-engine):
  local lights need shadow data to cast volumetric shadows; shadow casting
  has a material cost. Published Epic timings are not this addon's measurements.
- [CDPR light authoring](https://cdprojektred.atlassian.net/wiki/spaces/W3REDkit/pages/53772302/HOW-TO+Add+light+sources):
  shadow casting, fades, face masks and interior-only light usage are separate
  authored properties. A position fix alone does not provide absent shadows.
- [NN/g progressive disclosure](https://www.nngroup.com/articles/progressive-disclosure/):
  keep the main appearance controls and existing shadow switch; expose the
  supplemental quality/cost choice within the established advanced section.

## Validation

Strict `-Ges -WX` compilation passes for the production fog kernels and the new
probe. `tests/grid_gpu.cpp` runs the exact Raster and RT production kernels and
the new `tests/local_occlusion.cs.hlsl` probe. It validates:

- An interposed wall blocks coaxial/oblique rays; an unobstructed ray stays lit.
- Geometry in front of both endpoints does not become an infinite blocker.
- Near-plane clipping, disabled budgets, quality levels and deterministic jitter.
- Explicit offscreen failure to see a blocker, instead of a false guarantee.
- Opaque-depth distance and oblique camera-ray conversion.
- Atlas/cube visibility with a low native shadow fade: blocked light stays blocked.
- Existing group culling, Raster/RT parity, vacuum, captured interiors, forward
  additive energy, weather transport, temporal behavior and HDR regressions.

The standalone GPU host passed; its D3D12 debug layer was unavailable. The C++
lighting integration host passed control ownership, quality binding, master
dependency, migration, native callback ordering and Preset Off checks. The three
compiler warnings in shared descriptor/shader utilities are pre-existing.

The Release workflow compiles and runs the new probe through `build-release.ps1`.
Scratch commands/results are in `tmp/local-light-occlusion-20261111/offline.ps1`
and `gpu.log`. Release build, actual-addon HDR load-order checks and the user's
same-view scene comparison are recorded after the user-controlled game closure.
