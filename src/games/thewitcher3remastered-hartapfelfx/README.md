# The Witcher 3 Remastered - HartapfelFX

Standalone DX12 volumetric clouds, fog and lighting, ported from the working Classic
implementation using original Remastered captures to decode the native inputs.
The Night controls and graphics support code are bundled under `night/` and
`lighting/graphics/`; building this addon does not require the standalone mods.
The overlay has two tabs. **HartapfelFX** starts with **Player Fill Lights**,
with gameplay and dialogue/cutscene strength and optional environment matching.
**Darker Nights** contains the remaster’s night presets, schedule, illumination,
atmosphere, grading, exposure, and celestial controls.

The addon imports missing values from the standalone Darker Nights and Improved
Graphics profiles into the corresponding HartapfelFX slots. Preset Off restores
native lighting across both tabs. Use HartapfelFX in place of the standalone Darker Nights and Improved Graphics
addons. It can run alongside the separate HDR addon.

The [CPU pipeline notes](PERFORMANCE.md) document the disabled-feature overhead
fix, retained native inputs, descriptor and submission lifetime rules, profiling
evidence, and validation commands. Preset Off avoids feature preparation and
unused submission locks; normal descriptor copies no longer serialize the
engine's recording workers through a device-wide exclusive lock.

Darker Nights and Player Fill Lights share the native common constants hook. The merged
lighting shaders preserve HartapfelFX’s fog and cloud bindings, including the
RT sky contributions. Cloud Brightness adjusts cloud radiance in both native
and volumetric clouds.

## Lighting & Shadows

On the **HartapfelFX** tab, below **Player Fill Lights**:

| Setting | Default | Effect |
| --- | --- | --- |
| PBR Lighting | Improved | Diffuse and specular lighting for deferred and forward materials, RT reflection and probe hits, and PT paths. |
| Sun & Moon Shadows | Improved | Distance-aware shadow filtering in Raster and adjustable light size in RT and PT. |
| Light Size | 0.35 degrees | Angular size for directional shadow softness, from 0.05 to 2 degrees. |
| Contact Shadows | Improved | Adds short directional shadows to visible geometry, including HairWorks, in Raster, RT and PT. |
| Contact Shadow Reach | 0.30 m | Maximum distance searched for nearby occluders, from 0.05 to 1 m. |

Each mode can be switched back to Native separately. Preset Off restores all
three to Native. Matching saved controls from the standalone Graphics addon
are imported into unused profile entries. HartapfelFX shares the Graphics
lighting shaders, contact pipeline and RT material records; it uses its own
cloud and Darker Nights inputs on shared passes.

CPU-side cloud uploads and atlas descriptor heaps are recycled after their
recordings retire on the GPU. Cloud storage also survives rotation of the
engine's frame constant-buffer addresses. Native root bindings use cached
hook trampolines and command-local tracking; root-signature changes invalidate
constant masks without clearing the entire constant array. RT hit-output
invalidation skips descriptor scans while no hit output is active.

Native weather textures can alternate between lighting passes. The cloud
descriptor cache retains up to eight immutable resource/view combinations,
including both weather variants, rather than recreating every descriptor heap
on each switch. Entries own their source resources and remain valid in recorded
GPU work after cache eviction. Terrain cloud visibility enters at the native
lighting shader's cloud-shadow factor; geometry shadow visibility is preserved.

Cloud rays stop at scene geometry, including mountain surfaces inside the
layer. Temporal support and the high cirrus layer respect the same occlusion.
Large oriented mist particles use a local density volume within their native
bounds. The engine still supplies their centres, sizes, material animation,
colour, fades and flow; the GPU integrates the visible column. Small particles
retain their native material. Native cloud mode restores the original material.
No particle readback, CPU simulation or extra per-frame heaps are required.

The Release build script includes upload lifetime/readback, mountain-intersection
and local particle-volume regressions.
After rebuilding, compare the same slow gameplay scene with the same camera,
renderer, mod settings and other addons. Check Raster, RT and PT lighting,
cloud temporal stability and quality changes. Allocation microbenchmarks do
not measure gameplay frame-time improvement.

## Implemented rendering

- Logarithmic camera volume with Beer transport, reciprocal height density,
  weather-driven opacity, native color overrides, desaturation and fog masks.
- Shadowed sunlight and moonlight, Henyey-Greenstein scattering and analytic
  incoming-light attenuation. Eight antithetic samples prefilter each cell's
  cascaded-shadow visibility. Native terrain and cloud shadows also modulate it.
- Point and spot lights, native distance/cone attenuation, shadow strength,
  packed shadow atlases, cube shadows and animated/projected light cookies.
  Conservative 4 x 4 x 4 group culling shares the light list. Overflow evaluates
  the complete list. Raster's inline ten-row records and RT/PT's structured
  records have separate adapters to the same lighting evaluator.
- Native interior entry/exit intervals exclude indoor medium. Analytically
  integrated two-metre boundary fades smooth doorway transitions.
- EA SEED FAST sampling, GPU-ordered history reprojection, HDR luminance
  neighborhood clipping and motion/chroma/change rejection. Extinction always
  comes from the current frame. Cold or rejected history uses deterministic
  sampling. Separate raw/resolved regions avoid neighbor read/write races.
- Opaque fog, sky haze/scattering, native cloud layers, water and the captured
  forward/particle material families sample the shared volume. Transparent
  receivers use their own world distance. GPU camera/projection/jitter checks
  reject a volume belonging to a different view.
- Optional positive-weight cubic lighting reconstruction. Its opacity uses
  the original trilinear sample, preserving the current extinction silhouette.

## Volumetric clouds

Native weather selects billowing clouds, flatter volumetric decks and high
cirrus. The catalog covers 56 regional weather states in Novigrad/Velen,
Skellige, Kaer Morhen, White Orchard, its winter variant and Toussaint,
including mapped quest weather. It derives 17 recipes (including the generic
fallback) from 27 recognized native cloud effects. Unknown weather/worlds
retain the generic fallback. The added middle sheet and altocumulus patches
were removed after visual testing; their atlas channels and shading/shadow
work are gone. Weather containing only those effects now produces clear sky.
The main volume handles billows/decks; the retained high cirrus sits near 8 km.

Native source/target weather and its blend drive the remaining families.
The existing 0.8-second GPU fade prevents recipe changes from popping.
Cloud advection uses **50% of the native broad-layer wind speed**, as requested
after live testing. Direction, changing wind strength and calm weather still
come from the game. The same scale applies to weather, formations, cirrus,
shadows, directional visibility and motion/history reconstruction.

The catalog approximates native silhouettes; it does not copy native textures
or track individual particles. Optional effect probabilities become expected
appearance weights. `clouds/family_effects.json` retains the authored effect
catalog; the offline `tools/generate_cloud_families.py` emits static tables
with the removed middle-sheet weights forced to zero.
See [the weather map](clouds/WEATHER_MAP.md) for input and fallback boundaries.

Edge shaping tightens the lower-density region, retaining dense interiors.
It reuses already sampled, mip-filtered shape detail for coherent contour
variation. The cirrus atlas uses a narrower filtered contour. No new scrolling
noise, runtime noise fetch or image-sharpening pass is added.

### Realtime cloud authoring

The new controls apply while the game is running. They are saved with the
selected addon preset. **Reset Cloud Appearance** restores these controls and
the existing appearance/shape sliders to their defaults.

| Group | Controls |
| --- | --- |
| Cloud Formation | Base Altitude, Roundness, Height Variation, Formation Gaps |
| Cloud Billows | Billow Size, Contour Warping, Vertical Shear, Density Contrast |
| Cloud Erosion | Erosion Strength, Wispy / Billowy Balance, Underside Relief, Top Relief |
| Cloud Edges | Edge Sharpness, Edge Irregularity, Base Feathering, Top Feathering |
| Cloud Lighting | Direct Light, Sky Light, Self-Shadow Strength, Forward Scattering |
| High Cirrus | Cirrus Amount, Cirrus Coverage, Cirrus Size, Cirrus Altitude |

New multiplier controls default to 100%. Roundness and the wispy/billowy bias
start at zero; base/cirrus altitudes start at 1200/8000 m and forward scattering
at 80. These defaults preserve the established appearance. Cirrus is kept above
the top of the main deck. Cirrus amount and coverage scale weather-selected
high clouds; they do not bring back the removed middle sheet.

For firmer silhouettes, start with Edge Sharpness and Base Feathering. Use
Edge Irregularity for coherent contour breakup. Roundness, Billow Size and
Formation Gaps change the larger forms; Underside Relief shapes hanging lobes.
Lighting controls change the cloud body's shading. Density and shape continue
to determine sun-disc and terrain-shadow attenuation together.

Slider edits reuse the existing cloud textures, buffers, descriptors and passes.
Geometry edits propagate to sky, reflections and native shadow receivers, and
invalidate affected history so the response is immediate. Denser, thicker or
more extensive clouds can still cost more raymarch work. The existing quality
and step-size controls determine sampling cost.

The main-view native cloud cards are replaced by a weather-driven spherical
layer. The replacement recognizes the regular, storm material, and Toussaint
sky/card/background variants; the sky cubemap's painted detail is removed or
reduced when the volumetric field matches the current camera and frame. Native
mode retains the original sky and cards. The native source and target weather
fields, blend weight, wind and
weather-selected height profile control 3D shape noise, underside relief and
erosion. Two direct-scattering phase octaves, sky light and Beer extinction
run in scene-linear HDR. A separate weather-driven 2D cirrus material sits at
8 km. Its square texture maps to a square 24 km world period; the earlier
24×8 km mapping stretched thin high-cloud features into repeated horizon
stripes. The lower view ray, directional visibility volume and ground-shadow map
use the same optical extinction.
Native b12[67] wind offsets drive weather, lower formations, cirrus, shadows
and their histories. Native DXIL uses `20 * offset` in the broad projection;
the current user-requested speed is half of that (`10 * offset`). The recorded
storm's 0.6 offset units/s therefore produces about 6 m/s of cloud advection
instead of the native broad projection's 12 m/s. Calm weather stays calm;
direction and relative weather-dependent strength remain engine-controlled.
Cloud view and shadow passes prefer the existing GPU-captured scene clock when
its camera/jitter match. A light draw can leave effect data in b0; that must not
animate terrain shadows independently of the sky. Distinct clock allocations
also no longer disable cloud rendering: source lookup prefers the exact clock
page, then the retained source for the same native view. Unrelated views remain
excluded. Duplicate-render checks compare clock and view values as well as GPU
addresses, so reusing a GlobalCB allocation cannot suppress the next frame.
Daytime cloud lighting and terrain-shadow projection use the native sky solar
direction in b12[204].yzw. b12[38] is the atmospheric attenuation direction and
can differ by several degrees; using it for cloud shadows displaced their
coverage relative to the sky. Missing solar inputs fall back to the previous
native direction, and moonlight retains the native dominant-light direction.
The RG32F weather map now stores resolved coverage and height-profile weight,
so native source/target ID rollover cannot reinterpret its history. Both follow
the existing 0.8-second delta-time fade after the native blend; image history
retains valid samples through that handoff. Half-float cloud images store
opacity rather than near-one transmission for finer low-density steps.
See the [native weather and motion map](clouds/WEATHER_MAP.md) for all installed
weather-table variants, controls, exact native projection and live-check limits.
At the default 130% coverage, the weather control preserves the game's clear
cells instead of filling every gap to at least 30%. Populated weather cells
retain a strong slider response, and the extra formation breakup fades as
Coverage approaches 200%. A wider, rotated formation column breaks the alignment between
the 10 km weather repeat and the smaller billow repeat. View, solar beams,
environment and ground shadows evaluate that same world field. Ground-shadow
filtering uses one footprint along each sun ray so receiver height cannot
select a different mip and darken a higher point below a cloud.
The ground shadow ray uses the rendered sun direction b12[38], and its Beer
optical depth uses the same low-Density direct-beam calibration as the visible
sun disc. The previous b13 light direction and uncalibrated terrain beam could
make an open sun cast a broad shadow or an occluded sun leave direct terrain light.
The user verified that the branch-merged deferred hook restored terrain cloud
shadows at the default 60% Layer Thickness. A paired Native/Volumetric barn
view then showed that this hook also erased the barn's cast shadow: the final
visibility contains native geometry occlusion. The deferred adapter now
neutralizes the two native painted-cloud terms and multiplies the procedural
cloud factor into the merged visibility, preserving geometry visibility. This
revision passes Release compilation, GPU receiver/geometry-factor probes and
isolated addon startup; the barn scene still needs a live check.
The lower and high layers reach their spherical horizon and exclude the far
side of the planet. The lower layer no longer ends at the former fixed 80 km
ray limit. Foreground-air transmission attenuates their premultiplied radiance
and opacity before blending with the Witcher's existing atmospheric sky. It
does not uncover high cirrus behind an opaque lower cloud: the high layer uses
the lower cloud's un-hazed Beer transmission for occlusion.
This air attenuation
follows the native sky shader's 16-sample rational-height attenuation over the
game's sky distance. The supplied coastal dusk scene still needs a matched
visual check for its hard horizon boundary and repeated distant rows. Separate
foreground sky in-scattering at the cloud's weighted depth remains under
development.

In the captured main view, native sun and moon draws follow the sky pass.
The cloud composite runs at the first native cloud-card draw, after both
celestial draws, then suppresses the cards. The main-view target is captured
before the moon, before the sun, and before cloud blending. The two
differences measure each disc's actual HDR addition; the composite attenuates
them through the cloud column independently. The terrain-beam clamp limits
measured native sun radiance at every pixel where the sprite contributes. Both
native sky variants retain the authored broad solar glow in Volumetric mode.
They fade narrow profiles at their authored width and position. Widening
those profiles added glare even in clear weather. To verify, compare Native
and Volumetric from the same camera at dusk and in clear weather, then check
that an overcast sun still dims without a second disc.

The production ray marcher uses a fixed spatial FAST sample for its ray-step
phase at every quality level. Temporal reconstruction uses cloud-depth
reprojection, native wind/jitter compensation, HDR-relative radiance and
transmission variance, and neighborhood clipping. Full-resolution pixel-center
rays avoid additional subpixel jitter when the camera and weather are fixed.
Positive-weight composition reconstructs valid sky samples at depth boundaries.
Foreground fog is sampled after cloud history so cloud opacity carries the
same atmospheric inscattering as the underlying sky. The resolve filters
radiance and transmission across similar depth and opacity. Thin edges can
reuse nearby valid cloud depth when a primary ray misses; empty sky exits
without history. Directional visibility uses a world-anchored, temporally
reprojected optical-depth volume with bounded secondary rays at its edge.
The primary ray uses a bounded physical step and two-point quadrature near
thin edges. The measured native sun addition receives Beer transmission from
a solar optical column calibrated for the authored 12% visual-density default,
even where foreground air fades the cloud's ordinary sky blend. A small
sun-facing region checks optical depth at finer resolution to preserve narrow
gaps missed by the reconstructed view ray.
Cloud radiance and opacity retain the regular view result; b12[204].yzw is a
broad sky lobe rather than a second hard sun disc.

| Cloud quality | Resolution | Minimum view / fallback light samples | Noise size |
|---|---|---|---|
| Low | Full | 32 / 3 | 64 cubed |
| Medium, default | Full | 48 / 4 | 64 cubed |
| High | Full | 64 / 5 | 128 cubed |
| Ultra | Full | 80 / 6 | 128 cubed |
| Cinematic | Full | 128 / 10 | 128 cubed |
| Maximum | Full | 160 / 12 | 128 cubed |

All levels render clouds at full resolution and include shadows and indirect
lighting. Step Size spans 50-200% and changes view sampling. Higher levels
also refine erosion and shadow
resolution. Cost scales with traced sky pixels, occupied ray length and
lighting samples. Native mode and Cloud Shadows Off are independent controls.

Density, coverage, formation size, thickness, surface detail and detail size
start at direct 100% multipliers. Base Softness starts at 0%. The old Classic
presentation rebases (density .18/.432, thickness 1.3, detail 4 and detail
size .8) are removed. All cloud settings have new keys so earlier saved modes,
quality choices and percentages do not override the neutral defaults.
Weather coverage transitions use an approximately 0.8-second exponential fade.
The GPU-captured native clock freezes advection/fading while paused.
The directional shadow cache compares the native weather layers, blend, wind
and clock as well as camera and sun state; a held camera cannot retain an old
terrain shadow after the cloud field moves.

A snapped world-space shadow map feeds native cloud-shadow terms in deferred,
forward, vertex, water, volumetric fog, reflection/GI and the five captured
PT/RT ray libraries. The deferred sun adapter preserves native geometry
visibility when it applies the procedural cloud factor after branch merging.
Each adapter is assembled from a SHA-verified original capture and changes
only the audited visibility scalar. The adapter
manifest and generator live in `tools/cloud_adapters.json` and
`tools/cloud_adapters.py`.
The map publishes its maximum cloud altitude; receivers above the layer remain
unshadowed, while the projected ground footprint is unchanged. Its six filtered
R16G16F levels carry Beer transmission and the presentation's transmittance-
weighted exponential blocker depth. Ground receivers use the Beer column;
receivers inside the layer use the blocker depth to recover sunlight above it.

RTGI probe and reflection shading use a compute signature with b1..b15 in a
descriptor table. HartapfelFX adds buffered material inputs to that signature
and admits it as a hit-lighting consumer. Missing material bindings previously
prevented the combined replacement from running, leaving native sunlight in
the GI probes while the visible surfaces received cloud shadows. Both hit
passes now prepare the cloud map before shading. They retain the native global
clock from the main light pass because their own b0 holds lighting controls.
Sunlight is attenuated at each hit before material color enters the indirect
light. After a Release rebuild, compare Cloud Shadows On/Off with RTGI enabled
in the same view and allow the native probe history to settle.

PT CameraCB can share a two-CBV descriptor range with the next buffer. Cloud
layout admission accepts that range and adds the shadow input used by the
native PT, SER and SHARC library adapters. Ray shadow preparation uses the
retained native clock when PT depth passes omit the material clock-capture
draw. The DXR fixture covers this layout and checks attenuated bounce light,
zero visibility through opaque geometry, the native clock and restored ray
state. After rebuilding, compare the same cloud-shadowed scene in RT and PT.

The native motion converters `0xFA11F41B` and `0x9F1C32F1` receive qualified cloud
motion for predominantly cloudy, confident sky pixels. Foreground, thin/cloud
mixtures and the native world-motion branch retain the converter's own
behavior. The cloud reconstruction handles confidence/edit responsiveness in
its own history. Remastered's native upscaler owns its downstream history and
mask inputs. The water/depth-separation mask keeps its native meaning.

Cloud assets and histories have separate ownership from fog. The view cache
allows 768 MiB of persistent storage and up to 1536 MiB while a replaced view
is still in flight. If a same-size quality edit exceeds either budget, its
previous view continues rendering until the replacement fits. Recorded
work retains its resources and immutable descriptor/parameter pages until
queue completion. Histories and publication markers follow GPU execution
order across separately recorded lists. Probe sky draws are excluded by native
stage, target-layer, format, depth and viewport checks.

Native root CBVs, partial root constants, resource and sampler heaps, both bind
points, raster state and the actual DXR state object are restored around private
work. This includes HDR constants injected through ReShade's direct API. Native
DXR graph copying retains local roots, export renames, associations and
collections. Incremental state-object additions inherit cloud integration.
[Microsoft DXR state-object and binding rules](https://microsoft.github.io/DirectX-Specs/d3d/Raytracing.html)

## Modes, defaults and cost

Custom volume fog is the default. Native is available as the comparison/off
setting. Density, sky haze, height falloff and light strengths default to the
weather baseline. Anisotropy defaults to 0.5. Quality defaults to Balanced and
cubic reconstruction defaults to Off.

| Quality | Volume | Cached storage at 16:9 |
|---|---|---|
| Balanced | 160 x aspect-adjusted height x 96 | Approximately 53.9 MiB per view |
| High | 240 x aspect-adjusted height x 128 | Approximately 159.5 MiB per view |

Both levels include shadows, local lights, FAST and temporal reconstruction.
High increases cell count and refines shafts. Cubic reconstruction increases
receiver buffer reads. Local-light cost depends on how many light bounds
intersect a group and whether their shadow/cookie paths are active. Sun cost
scales with volume cell count and shadow coverage. GPU timings in the actual
game remain to be measured by controlled scene testing.

The figures include the current field, history and interior caches. A bounded
768 MiB resource pool allocates on demand and caches up to four native views.
Large buffers follow native graphics-queue execution order. Immutable parameter
pages use approximately 65 KiB per recorded fog operation, including the pool's
allocation granularity. Recording references and queue fences protect eviction
and parameter reuse. Unknown-queue work is quarantined. Unavailable allocations
or unmatched views use native fog.

## Native and HDR integration

| Mode | Shadow consumer | Cell generation |
|---|---|---|
| Raster | `0x4A7A44D6` | Pixel shader in a cell atlas |
| RT / PT deferred sun path | `0x806C62A8` | Pixel shader in a cell atlas |

These hashes identify the available native shadow consumers. Reflection/probe
views can use different paths within one mode. Frame-buffer identity, viewport and quality select a
stable view cache. GPU frame metadata validates its actual contents. The native opaque fog composite is `0x73E21194` in the
captured Raster, RT and PT scenes. It writes scene-linear RGBA16F before HDR
output processing.

Private bindings use spaces 70, 71 and 72. The existing HDR addon uses space 50.
Only compatible common signatures containing native b12/b13 are extended, with
eight individual buffer root descriptors and a 64-DWORD budget check. Private work
preserves native descriptor heaps and restores the original PSO/raster state.
The mod owns its fog resources and settings. Tone mapping, exposure, grading,
swapchain handling and surface-light evaluation retain their existing owners.
The cloud adapters replace only native cloud-shadow factors, including the
captured ray libraries.

The previous launch failure reported DXGI_INVALID_CALL. The previous version
extended unrelated root layouts through grouped descriptor injection. Extension
is now scoped to compatible common layouts and uses heap-independent buffers.
The first flickering reference also switched texture descriptor heaps and used
Present as provenance. The current implementation uses command-list/frame
view identity, GPU execution ordering and queue-fenced resource lifetime.

## Validation and build

Run `build-release.ps1` for the Clang x64 Release target. `-CompileOnly` validates
without relinking the loaded addon. The script rejects replacing a loaded addon.
The user controls every game launch and closure.

The build validates native scalar frame aliases and active receiver hooks,
root-layout ownership/private spaces/DWORD budgets, strict HLSL 2021 compilation,
and standalone execution of the production GPU kernels. GPU cases cover
Raster/compute agreement, Raster/RT local-light parity, point-light quadrature,
group culling and 257-light overflow, atlas/cube shadows and RGB/animated cookies,
vacuum, analytic Beer transport, nonlinear weather opacity/fade, HDR radiance,
accepted/clipped/rejected temporal history, unchanged extinction, cubic and
trilinear reconstruction, weather receivers, interior fades, FAST byte addressing
and terrain/cloud shadow modulation.

`tests/lighting_integration.cpp` uses the mock ReShade host to check both tabs,
standalone profile import, scoped reset, Preset Off, and composition of the
player fill and night edits against a fresh native constants buffer.

`tests/startup_gpu.cpp` is a standalone D3D12/ReShade compatibility host. With the
actual Release fog addon and installed HDR addon staged in workspace-only test
directories, both addon load orders pass. Both orders also pass with the existing Release
DevKit addon loaded. It creates all 12 captured native receiver-stage combinations (including the
water hull/domain stages), their replacement PSOs and all private fog pipelines, along with common, near-limit, unrelated and local root
signatures. It never launches or closes a game. `tests/startup.ps1` stages and
runs this host using explicitly supplied loader, HDR addon and native-capture
paths.

The machine's D3D12 debug layer is unavailable. These checks establish offline
GPU behavior and addon/root compatibility. User-controlled in-game acceptance
is still required for launch, flicker/ghosting, camera motion, interiors,
water/particles, weather changes, resize/DLSS/FG and Raster/RT/PT visual results.
The installed game-folder symlink resolves to the Release artifact at
`build/Release/renodx-thewitcher3remastered-hartapfelfx.addon64`.

## Research and provenance

The port follows the froxel lighting/integration and temporal reconstruction
approaches described by [Wronski (2014)](https://advances.realtimerendering.com/s2014/wronski/bwronski_volumetric_fog_siggraph2014.pdf)
and [Hillaire, Frostbite volumetric lighting (2015)](https://advances.realtimerendering.com/s2015/).
FAST supplies spatiotemporal sample sequences. The copied asset retains its
BSD license in `fog/LICENSE.fastnoise`. [EA SEED FAST (2024)](https://www.ea.com/news/spatio-temporal-sampling)

Root buffers and heap preservation follow Microsoft's binding rules. The heap
switch in texture `push_descriptors` was also verified in the local ReShade
implementation. [Root descriptors](https://learn.microsoft.com/en-us/windows/win32/direct3d12/using-descriptors-directly-in-the-root-signature),
[descriptor heaps](https://learn.microsoft.com/en-us/windows/win32/direct3d12/setting-descriptor-heaps)

Native binaries and new decompilations/readbacks are preserved under
`tmp/witcher3remastered-graphics-port-20261102/original` and
`tmp/hartapfelfx-20261104`. World reconstruction uses native frame rows 211-214.
Interior normalization uses light row 33. The ten-row next-gen local-light and
packed atlas/cookie layouts were decoded independently from these originals.

## Save-load crash correction, November 4

The save-load dump `Witcher3_20261104_165011917` identifies an access violation
while retrying the replacement for cloud pixel shader `0x683213A3`. Its new
screen-position argument had been inserted before the native TEXCOORD arguments,
shifting their input registers. The native vertex shader `0xB5373B9F` writes
TEXCOORD0-5 to registers 0-5 and position to register 6. Position now follows
those native arguments in the pixel shader. The standalone host reproduced the
old pipeline creation failure and accepts the corrected pair. Direct3D requires
compatible adjacent-stage signatures. [Microsoft shader signature rules](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-signatures)

The failed initial clone left no cached subobjects. A later lazy retry indexed
that empty array. Both fog replacement callbacks now require a successfully
initialized, nonzero replacement PSO before entering the shared retry path.
A failed clone takes the native fallback. This guard is local to HartapfelFX.
The compatibility host now reflects and validates all 12 captured receiver
stage combinations against both original and replacement pixel shaders,
including the water tessellation stages, in both HDR addon load orders.

## Interior capture correction, November 4

Classic's authored-interval behavior is now connected to the Remastered input
lifetime. Captured Raster, RT and PT frames bind the RG16F interval texture at
`t24` in native `0x8BDE805B`, before the sun consumers. The sun passes do not bind
that texture. Looking for it only during sun generation silently disabled the
old adapter.

An observer of the early native consumer captures its active half-resolution
intervals into a small private buffer, using native light row 33 for distance
normalization. The later fog job copies the snapshot into its own allocation.
Camera, inverse projection and active render extent must match on the GPU.
Capture and volume recordings hold queue-fenced allocation references. The
capture uses a separate immutable upload page. Native descriptor heaps stay
bound throughout. Its fixed 240 x 256 buffer occupies 0.5 MiB after pool
rounding, with a second copy in the current field. Generation resamples it to
the selected quality's grid.

The density behavior follows Classic's `README.md` interior-fog section and
`volumetrics/interior.hlsli`. Authored interiors contain zero medium. The cubic
two-metre fade lies outside each entry/exit boundary and is analytically
integrated over every radial cell. Outdoor fog before a building and through a
doorway is preserved. Native equal-boundary sentinels, reversed intervals for a
camera indoors, and missing/invalid inputs retain their Classic interpretation.
This operates on authored interior volumes. Rooms/caves without such a native
volume have no interval to exclude.

The new production-kernel tests use an actual pooled RG16F texture. The native
texture is explicitly unbound between the early capture and later PS/CS fog
generation. Ninety-four cases cover indoor vacuum, entering/exiting volumes,
33 moving-doorway positions, poisoned pooled borders, invalid scale/boundaries,
missing textures, snapshot resampling and camera/projection/extent rejection.
Sun and local-light scattering must both preserve exact interior vacuum. Existing lighting,
weather, temporal and HDR checks also pass. The overlay's Integration Status
shows interior capture and paired-volume counts for the user's visual test.

## RT source and view isolation, November 4

A read-only DevKit snapshot of the user's running RT scene confirmed the archived
pass contract. Interior consumer `0x8BDE805B` is draw 2868 with RG16F `t24` at
960 x 540. Auxiliary compute lighting `0xD2C88922` occurs at draws 5294/5295,
with RGBA8 colour atlases at `t0` sized 1024 x 512 and 512 x 512. The main
`0x806C62A8` sun pass follows at draw 5363 with a 1920 x 1080 depth component.
All those passes reuse the same b12/b13 buffer handles and offsets.

The previous adapter accepted any 2D `t0` and deduplicated pending fog work by
frame-buffer identity. This allowed auxiliary RT atlas work to create the fog
job before the main pass. The adapter now requires a depth-component view,
rejects both captured colour atlases, and generates fresh work at every valid
sun consumer. Opaque/forward receivers also require the producing viewport.
Probe skies cannot borrow a main-view volume solely because CBV addresses match.

Interior snapshots remain available across auxiliary view processing and are
refreshed at the next native interior consumer. Their captured grid dimensions
travel in the metadata, allowing safe resampling when a later volume uses a
different grid size. GPU camera/projection/render-extent checks still guard the
actual exclusion. CPU regression checks cover the captured RT atlas/depth
formats and main/probe viewport isolation. These corrections require the user's
subsequent in-game RT test for visual acceptance.

## Continuous-rendering synchronization correction, November 4

The pause-dependent report exposed two gaps in the former single-frame tests.
Snapshot selection used a CPU-latest job and a b12 address reused across frames.
Opaque generation and publication also depended on a producer remaining on the
same command list. Pausing made stale camera/projection data match again. Full
volume allocations remained pinned until their recording was reset, so a
rotating command-list pool could exhaust the fog budget and trigger native
fallbacks.

Interior capture now writes a persistent buffer associated with the native
frame binding. Its current contents are consumed in GPU execution order. Each
native view also owns a persistent current field and history field. Before a
sun pass overwrites the current field, the preceding resolved field and header
are copied into history. Transition barriers order capture, copies, generation,
local lights, temporal filtering, integration and receivers. Stage boundaries
return private storage to a consistent shader-readable state. Native inter-pass
graphics-queue dependencies therefore carry the private work across split
command lists. These operations execute only on direct command lists.
[Microsoft command-list execution rules](https://learn.microsoft.com/en-us/windows/win32/api/d3d12/nf-d3d12-id3d12commandqueue-executecommandlists),
[Microsoft resource-barrier rules](https://learn.microsoft.com/en-us/windows/win32/direct3d12/using-resource-barriers-to-synchronize-resource-states-in-direct3d-12)

A GPU completion marker rejects unfinished history. Native temporal-jitter
metadata joins camera, projection and render extent in validating current
receivers and interval data. Weather parameters describe the medium and no
longer serve as an exact-equality frame identifier. Integration uses the
profile captured during cell generation. Local-light dispatches check frame
identity and completion state, with a GPU flag written after the dispatch to
prevent duplicate addition. Current extinction and interior vacuum remain
independent of temporal lighting history.

Only immutable parameter pages belong to individual recordings. The cache and
its history stay alive through borrowing recordings and queue fences. New view
headers are cleared before use, including when a pool allocation is recycled.
At device destruction the cache is detached before releasing roots, preventing
reentrant layout callbacks from touching a partially destroyed map. Persistent
upload mappings are released with their resources, avoiding native Unmap hooks
during device teardown. This mapping lifetime is supported by Direct3D 12.
[Microsoft persistent-mapping rules](https://learn.microsoft.com/en-us/windows/win32/api/d3d12/nf-d3d12-id3d12resource-map)

`tests/runtime_gpu.hpp` executes the actual Release addon callbacks with native
interior, Raster sun, RT/PT sun and opaque-fog shaders. Twenty-four frames use
72 separately recorded command lists. Every capture is recorded first, then
every sun pass, then every composite. Submission interleaves them in native
frame order, deliberately defeating CPU-latest snapshot pairing. Native b12 is
updated through GPU copies at its reused address. Cases alternate indoor and
outdoor intervals, exercise moving and frozen camera/jitter states, and change
weather by one ULP between sun generation and composite. Every frame must bind
the current camera field, preserve exact indoor vacuum and retain the expected
outdoor opacity. Balanced and High run in both HDR-addon load orders with the
Release DevKit loaded. Device teardown is part of the check. The existing 197
production-kernel cases and 12 native receiver-stage linkage checks also pass.

In-game PT/RT/Raster flicker and doorway appearance still require the user's
visual acceptance after loading the updated Release addon.

## Cloud port validation

The production D3D12 suite passes 98 cloud GPU cases. It covers all six quality
levels, pixel/compute weather and shadow generation, packed R16 shadow alignment
and world projection, shadow Off/native fallback, HDR direct/diffuse transport,
foreground exclusion, alpha preservation, duplicate composition, warm and
paused history, edit invalidation, cloud removal and shape extremes,
the default 60% Layer Thickness with low Density and varied Size/Coverage,
shadow-map readback and terrain receiver visibility across setting extremes,
motion confidence, both native motion converters in RGBA16F/RG16F paths, and
weather/revision guarded six-face sky-atlas replacement. The same cloud trace
feeds a low-resolution full-sphere reflection environment, while a parallel
hemispherical sky reduction supplies ambient light to the view and environment.
Converter tests compare foreground/thin/world cases against original DXIL.

The actual-addon compatibility host adds 24 cloud frames through 72 delayed
split recordings, with stages recorded in a different CPU order from submission.
It verifies cloud composition, clock/weather/light capture, HDR constants,
partial root constants, resource/sampler heaps and native state restoration.
All five original ray libraries are created together with a test ray-generation
export and an associated local root. A renamed export is added through
AddToStateObject and dispatched with the actual addon. The GPU checks both the
procedural shadow header and preserved global/local root values. The same host
retains the existing 24-frame fog/interior regression and native linkage checks.

`build-release.ps1` also runs the capture-independent cloud cases. Supplying
`-NativeCapturePath` enables all 98. `tests/startup.ps1` accepts optional
`-RayCapturePath` to include the actual cloud/DXR workload in both HDR load orders
and both fog qualities. Pass the game's `D3D12_0` directory through
`-D3D12SdkPath` to both scripts to compile the host for its bundled Agility SDK
and stage that runtime beside the isolated host. Tests execute workspace-only
D3D12 hosts.

In-game acceptance remains user-controlled. Check native/volumetric switching,
all lighting modes, cloudy sun and moon views, smooth self-shadow transitions in held
and moving views, changing weather, camera motion/cuts,
thunderstorms with lightning and Toussaint skies for residual painted cloud
layers, interiors, water/particles, DLSS/FG and resolution/quality changes. GPU timing
and visual acceptance in the user's setup remain pending.

The cloud material retains Nubis-style shape and EA FAST spatial sampling.
The lighting, weather control map, filtered cloud shadows, visibility volume
and integration are being adapted from Bauer's 2019 RDR2 procedure to the
Witcher's native frame layout and D3D12 scheduling. The feature-by-feature
status and unresolved integration work are in
`clouds/RDR2_IMPLEMENTATION_TRACKER.md`. Primary references:

- [Rockstar SIGGRAPH 2019 course](https://advances.realtimerendering.com/s2019/index.htm)
- [Guerrilla Nubis cloudscapes](https://www.guerrilla-games.com/read/nubis-authoring-real-time-volumetric-cloudscapes-with-the-decima-engine)
- [Guerrilla Nubis Evolved](https://www.guerrilla-games.com/read/nubis-evolved)
- [EA SEED FAST paper](https://media.contentapi.ea.com/content/dam/ea/seed/presentations/seed-id3-2024-spatio-temporal-sampling-paper.pdf)
- [EA FAST implementation and licensing](https://github.com/electronicarts/fastnoise)
- [Epic volumetric cloud rendering](https://dev.epicgames.com/documentation/en-us/unreal-engine/volumetric-cloud-component-in-unreal-engine)

## Cloud startup crash correction, November 4

The `Witcher3_20261104_213520839` dump identifies a driver access violation while
creating the `0x0C1350D8` / `0x4A7A44D6` replacement PSO. The lowered native
shader addresses its resources through explicit bindings. DXC library linking
retained those instructions but removed their resource declarations as unused
globals. The resulting adapter declared only the helper's resources. The
NVIDIA driver then encountered a missing native binding while compiling it.

Adapter generation now restores the complete native resource inventory, adds
only the private cloud buffer, reassembles the container and runs DXIL validation.
A separate audit compares every native register/space/range and its resource
properties, including sampler kind, structured stride, counters and CBV size.
The original broken adapter is rejected by this audit. DXIL validation alone
accepted that malformed inventory, so binding audits remain mandatory.

The isolated compatibility host now observes first-chance access violations
and fails even when the driver catches one and permits a fallback. The corrected
cloud/sun, fog and DXR workload passes in all four HDR-load-order/fog-quality
combinations with zero access violations. User-controlled
game testing remains the final startup/visual acceptance step.
[Microsoft DXIL resource metadata specification](https://github.com/microsoft/DirectXShaderCompiler/blob/main/docs/DXIL.rst)

## Cloud admission correction for Agility SDK 619

A live PT capture showed valid main sun/sky inputs with volumetric clouds
enabled, while the native binding tracker retained an empty root signature.
Consequently the state-restoration guard skipped every cloud pass. The bundled
Agility runtime changes command-list recording methods after creation and can
install driver methods during root binding. Creation-time function hooks alone
missed those calls.

Root tracking now uses native binding events plus the stable ReShade API
backend methods for addon-injected CBVs and partial root constants. Tracking
belongs to the API command-list owner. Native COM aliases are refreshed after
Reset and binding events because an interface upgrade can return a different
native pointer. The heap tracker follows those aliases and actual heap-set
methods. Native state restoration still requires a matching tracked signature
and a known heap snapshot.

The compatibility workload now creates its primary cloud list closed through
CreateCommandList1 and resets it before recording. It also supports the exact
bundled Agility runtime through the SDK exports. The missing-cloud failure
reproduced with SDK 619 and the previous tracker, while the Windows system
runtime passed the same workload. The corrected Release passes both HDR load orders and both fog qualities on
each runtime, with zero access violations. Each combination executes 24 cloud
frames and 24 fog frames through separately recorded command lists, plus native
DXR creation/dispatch and HDR binding-restoration checks. In-game visual
acceptance remains pending.
[Microsoft Agility SDK runtime selection](https://microsoft.github.io/DirectX-Specs/d3d/D3D12Redistributable.html)

### PBR/contact runtime admission

Surface-lighting controls use immutable CPU uploads retained by HartapfelFX's
command-recording fences. They do not require a published ray-material field or
its submission tracker. Lighting-only recordings retain settings without adding
cloud-resource waits between queues. The RT material tracker also refreshes
native command-list aliases at reset, admission and submission.

The actual-addon compatibility test clears the ray-material recording tracker
while dispatching native deferred lighting, then reads back its PBR/contact
controls on the GPU. Both controls must remain enabled. `tests/submission.cpp`
checks closed command-list creation, stale alias recovery and the post-submission
producer fence. The live log reports admitted lighting passes, fallbacks and
contact-field generation so neutral-mask fallback is distinguishable from an
active effect.
