## Wispy sunrise and sunset opening (9 November 2026)

The clearing keeps its 29-38 degree outer half-width and uses a narrower fully
clear core. The upper shoulder now fades over a wider, noise-varying range. A
broad Worley band varies the height and width of the arch. Existing column
noise erodes broad gaps before the detail work. After the density and edge
profile are resolved, the existing side and erosion bands vary a second taper
that leaves thin strands between those gaps. This gives the cloud shoulder
variable optical thickness and breaks up the bright contour. View rays, light
rays and reflections use the same density. The 18:00-06:00 schedule and native
weather gates still apply.

The separation of broad formation shape and finer erosion follows
[Guerrilla's Nubis presentation, pp. 36 and 40](https://advances.realtimerendering.com/s2017/Nubis%20-%20Authoring%20Realtime%20Volumetric%20Cloudscapes%20with%20the%20Decima%20Engine%20-%20Final%20.pdf).
The exact shape of the clearing is an art control. The shader reuses existing
noise samples and retains the existing buffers, passes and ray budgets.
Early coverage erosion and a small density bias taper near-empty gaps to zero
so they can skip lighting.

Strict DXIL and all 371 cloud GPU cases passed. The density fixture removed
590 occupied samples in the central band and measured 746 thin shoulder
samples with less than 35% of their original density. Terrain transmission
reached 1.0 on the tested solar path. In a matched 640x360 capture using the
cloud defaults, the three solar-disc transmission channels were unchanged
and each exceeded 99.1%.

At 1920x1080 on the Performance preset, three alternating D3D12 benchmark
runs per variant measured 1.96 ms before and 2.55 ms after with the low-Sun
opening active. Both daytime variants measured 1.18 ms. The timings are
medians of summed weather, shadow, cloud render and environment pass medians
in the standalone Mid Clouds fixture. Most of the added cost is in the cloud
render pass, where the thin shoulder sustains the low-Sun lighting path. The
benchmarks do not measure overall frame time in the game. The isolated Release
addon, benchmark log, and before/after previews are in `tmp/cloud-wisps/`.
The new preview is `trim.png`.

## Arched horizon opening and cloud shadow strength (9 November 2026)

The sunrise and sunset opening narrows from a 40-55 degree outer half-width
to 29-38 degrees. The normalized lateral coordinate also drives a parabolic
ceiling. Its crest is about 4-5 degrees above the Sun and rolls down toward
the horizon. Existing formation noise varies width and height, and smoothstep
feathers the sides and ceiling. The shared density still clears the solar
column for both the view and terrain lighting. The clock window and
rain/storm protection continue to qualify the opening.

Cloud Shadow Strength uses the existing shadow receiver blend in linear light.
A receiver mixes clear light with the light transmitted by the cloud column,
using the slider as the cloud contribution weight. At 50%, this halves the
dimming caused by the full shadow map. The map retains the Beer transmission
of the full cloud column for solar and lunar disc occlusion. The disc test
skips the terrain map when the slider is zero and uses its view column instead.
There are no additional shadow samples, resources, or passes. See
[PBRT, Transmittance](https://pbr-book.org/4ed/Volume_Scattering/Transmittance)
for the physical beam term. The receiver blend is an artistic control.

CloudShadowStrengthV1 stores 0-100% and defaults to 100%. The old CloudShadowsV2
values migrate to 0% or 100% when a preset has no saved strength. The existing
settings revision invalidates the shadow metadata when the slider moves.

The Clang x64 Release build, strict DXIL probe compilation, 371 cloud GPU
cases, and menu integration tests passed. Coverage includes the arched
ceiling, side fades, clock and wet-weather gates, 25% strength, the 0/100%
endpoints, native geometry occlusion, legacy migration, and tab reset. The
matched synthetic sky renders retained the same solar disc transmission,
with at least 99.1% of each channel reaching the camera through the opening.
For an in-game comparison, check the opening at low Sun, then try 100%, 50%,
and 0% strength under the same cloud cover. Logs, synthetic previews, and the
isolated Release addon are in `tmp/cloud-arch/`.

## Horizon clearing, native clock window and evening sunlight blend (8 November 2026)

Supersedes the earlier circular 2.5-degree clearing core and elevation-only
schedule. Existing low-sun UI control and wet/unknown-weather protection remain.
The opening now follows the horizontal solar bearing: noise-varying clear
half-width 14-22 degrees, lateral feather to 40-55 degrees, clear ceiling about
3-5 degrees above the Sun, broad irregular upper shoulder about 8-14 degrees.
It tapers at the sides; its lower feather extends about 6-15 degrees below.
The existing column noise varies the fully clear boundary as well as the outer
shoulder, avoiding both a circular hole and a straight uniform ceiling. Shape
is applied to coverage before density/profile/erosion in the shared material,
not to final opacity. View, reflections, source occlusion and shadows agree.
No new texture lookup, pass, resource or noise generator.

Requested clock schedule: 18:00-06:00, with smooth 15-minute game-time fades
inside the endpoints (18:00-18:15, 05:45-06:00). When the Sun is below the
horizon, centre the band on the horizon at its solar bearing. Time comes from
the already audited normalized evaluated-environment +0x15c0 read in native
lighting builders, not an inferred GlobalCB/Moon-phase field. A relaxed atomic
publication feeds existing immutable cloud parameter pages; no game-memory
query, readback, allocation or lock was added. Unknown native time retains the
prior elevation schedule. CPU clock schedule scales existing scattering.z;
8192 in the existing identity flags qualifies scheduled state. History duplicate
checks and both shadow caches track fade strength; smooth fade changes use
existing current-density clipping without discarding all temporal history.

Lighting > Sun & Moon Appearance > Evening Sunlight Colour (new saved key
EveningSunlightColourV1), 0-100%, default100. The actual world-light builder
blends fresh native linear RGB with the enhanced spectrum at equal native
luminance, preserving alpha. PM game time and low solar elevation gate this
artistic control; sunrise, Moon and daytime colours retain existing behavior.
Cloud/direct/ambient emission caches and visible Sun remain fully coloured,
independent of the world-light blend. Preset Off restores native and tab reset
restores100. Native retains its own authored sunset reds: zero is not white.

Source rationale: [Nubis 2017](https://www.guerrilla-games.com/read/nubis-authoring-real-time-volumetric-cloudscapes-with-the-decima-engine),
PDF pp40-45, uses spatial coverage gradients to expand/contract procedural
cloud density. [Frostbite cloud materials](https://media.contentapi.ea.com/content/dam/eacom/frostbite/files/s2016-pbs-frostbite-sky-clouds-new.pdf),
section5, separates procedural material from lighting. [PBRT Color](https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Color)
describes linear tristimulus combinations and luminance/chromaticity. The exact
horizon shape, hours and native/enhanced blend are user-directed art controls,
not a physical claim that sunset removes clouds or a spectral simulation.

Validation complete:

- PASS Clang x64 Release object/shader build; strict DXIL, fog GPU/native
  bindings, upload lifetime, UI/descriptor/family regression suite.
- PASS 360 production cloud GPU cases, including the widened/noise-varying core,
  horizontal versus vertical extent, distant-cloud retention, smooth shoulder,
  conservative density bounds and all existing rain/storm/unknown protection.
  Nine native-clock cases cover 17:59:24, 18:00, 18:07:30, 18:15, midnight, 05:45,
  05:52:30, 06:00, noon. Held animation clock and revision still update visible
  clouds and terrain sunlight together at both schedule endpoints.
- PASS actual menu/profile/tab-reset/Off and native builder composition tests.
  Native/enhanced world-light endpoints and 25%/50% linear interpolation preserve
  luminance/alpha. Morning/Moon remain independent. The production cloud
  render across 0%/100% world-light blend endpoints has relative L1 difference 0.
- PASS actual Release addon in both HDR load orders, without DevKit: 24 cloud
  frames / 75 delayed cloud recordings, both native sky variants, native clocks,
  world/local light receivers, foreign-view rejection, five native DXR libraries,
  real DispatchRays, restored native root/heap state and teardown. The established
  scratch host pins its historical SunDiameter=1.3 fixture expectation.
- Before/after 640x360 fixed-scene previews inspected: old compact round opening
  becomes a wide irregular horizontal break. These are synthetic GPU fixtures,
  not the attached gameplay scene or live gameplay acceptance.
- Static sampleLevel sites unchanged: view 46, shadow PS 7, shadow CS 9,
  directional volume 8, environment 46. One four-byte GPU copy publishes opening
  strength from the unused ambient alpha into reserved shared header byte 352;
  celestial header 304..319, GPU allocation sizes and resource counts unchanged.
  This lets shadow caches qualify clock fades without disabling their reuse.
- Balanced 1080p matched held-time-zero fixture: 3 alternating paired runs, each
  16 warmup + 16 timed frames. Median summed weather/shadow/view/environment cost
  1.657548 ms before, 1.652928 ms after (-0.28%). No consistent measured regression
  in this fixture; no universal no-cost/gameplay FPS claim. Evolved coverage can
  change existing early exits independently of the mask's arithmetic.

Release candidate: tmp/horizon-clearing/horizon-evening.addon64, 5799936 bytes.
SHA256 b4aac1be49debae8d05eb48fe3834f36f152946972024b4c1e0ebc075e3149ba.
The installed/loaded addon is preserved. Rebuild with the game closed via
./src/games/thewitcher3remastered-hartapfelfx/build-release.ps1, or use the
validated Release candidate after closing the game. The agent never starts or
closes the game.

Evidence in tmp/horizon-clearing/: final-validation.log, menu-final.log,
startup.log, benchmark.log/benchmarks.json, before/after.rgba32f and PNG previews,
link-release.ps1 and the candidate. User acceptance: compare clearing On/Off at
18:00,18:15,05:45,06:00, rain/storm transitions and photo-mode time jumps. Inspect
natural horizon edge, terrain shadows/reflections, then Evening Sunlight Colour
at 0/25/50/100% in Raster/RT/PT: terrain tint should respond while clouds retain
sunset colour. Live gameplay visual acceptance remains open.

## Gradual cloud form evolution (8 November 2026)

The density model previously used fixed .375 and .625 slices of the owned
3D shape volume for its column envelope and side displacement. Native wind
translated them unchanged. Existing 0.6 m/s vertical drift could turn over body
and edge structure but could not evolve that column envelope.

clouds/common.hlsli now traverses the column's unused Z axis by native clock
seconds / 2400 and the side warp's unused Y axis by seconds / 1200. Existing
wrap sampling and trilinear filtering make tile crossings continuous. These
are full texture traversal periods; the baked 4/8/16-cell features evolve on
shorter timescales. Slow envelope evolution and faster bounded displacement
preserve the established cloud style. Speeds are mod-specific artistic choices,
not atmospheric measurements or numbers prescribed by a paper.

The shared material feeds view, environment, fine Sun/Moon occlusion, self-light
and terrain-shadow paths. Native weather probability and its 0.35x wind remain
unchanged. Bulk vertical drift and its motion-vector reprojection remain at
0.6 m/s. Shape evolution is non-rigid: current depth/opacity/radiance clipping
handles its residual rather than reporting an invented rigid velocity. Native
clock pause freezes the new offsets; existing time-jump invalidation stays
active. This targets the lower volumetric layer; local mist and the separate
high cirrus material keep their existing animation.

No new texture lookup, noise generation, pass, ray step, descriptor, allocation,
CPU update, root binding or GPU wait. Two invocation-uniform multiply/add
expressions replace fixed coordinates. Literal zero instructions or identical
GPU time for every evolved shape is not claimed: changing occupancy can change
existing early exits. Comparison includes a held time-zero frame, where the
material exactly matches the earlier model.

Research read before implementation:

- [Schneider, Nubis, SIGGRAPH 2017](https://www.guerrilla-games.com/read/nubis-authoring-real-time-volumetric-cloudscapes-with-the-decima-engine),
  PDF page 45 and page 63: animate density-model noise independently of authored
  coverage to evolve details while retaining the cloudscape arrangement. Hidden
  axis traversal here adapts that principle to the mod's existing 3D lookups;
  Nubis's example instead offsets/skews sampling with wind. This does not copy
  its exact animation algorithm and is not a fluid simulation.
- [Hillaire, Frostbite sky/atmosphere/clouds](https://media.contentapi.ea.com/content/dam/eacom/frostbite/files/s2016-pbs-frostbite-sky-clouds-new.pdf),
  sections 5.1-5.3: procedural Perlin-Worley density, dynamic weather and unified
  lighting/material integration. Supports retaining the shared density path
  rather than applying an image-space deformation.
- [Hogfeldt, Convincing Cloud Rendering](https://odr.chalmers.se/server/api/core/bitstreams/c8634b02-1b52-40c7-a75c-d8c7a9594c2c/content),
  sections 4.3-4.5 and 6.1: separate weather/shape/detail fields and temporal
  reconstruction. Original Frostbite implementation thesis.

Validation completed:

- PASS Clang x64 Release shader/object build and strict DXIL compilation;
  fog PS/CS/HDR/local-light/interior suite, native bindings, upload lifetime,
  descriptor concurrency, menu/source layout and family selection regressions.
- PASS 342 production cloud GPU cases across six custom qualities and four
  named presets, including weather/clock/history/motion/foreground and shadow
  registration, plus existing celestial/fair/rainy HDR-disc captures.
- New fixed-camera/zero-wind density slice: 13,230 occupied samples; 10,395
  changed by more than .01 after 60 s. Coarse L1 change was .149987 over 1/60 s
  versus 1220.62 over 60 s. Paused clock equality, periodic slice boundaries
  (450/1500 s), 86400 s native time and fine <= coarse bounds pass.
- Time-zero 640x360 RGBA32F capture is byte-identical to baseline. Compiled
  sampleLevel site counts before/after: view 46/46, terrain shadow PS 7/7,
  shadow CS 9/9, directional volume 8/8, environment 46/46. Cbuffer-load counts
  also unchanged. These are static call sites, not runtime lookup totals.
- Paired held-time-zero 1920x1080 GPU timestamps: three runs per variant,
  alternating order, 16 warmup + 16 measured frames per run. Median of each
  run's summed weather/shadow/view/environment medians below. Synthetic data,
  neutral appearance, no gameplay FPS claim. Results span -1.19% to +1.15%:
  no consistent overall regression, not a proof of literally zero GPU work.

| Quality | Baseline ms | Evolving ms | Delta |
| --- | ---: | ---: | ---: |
| Custom (level 1) | 2.426764 | 2.413280 | -0.56% |
| Performance | 1.203072 | 1.216848 | +1.15% |
| Balanced | 1.645760 | 1.653504 | +0.47% |
| High | 3.212190 | 3.173852 | -1.19% |
| Ultra | 9.824706 | 9.809588 | -0.15% |

Release artifact: `tmp/cloud-evolution/cloud-evolution.addon64`, 5792768 bytes,
SHA256 `2b1f9993e6cc33290b7a581f284ddab7b1c51a4647a30a896ce06c4c81e16f28`.
The normal link could not write the existing build/Release addon (permission
error); the established isolated-link path produced this validated candidate.
The installed addon has not been replaced. Build with the game closed using
`./src/games/thewitcher3remastered-hartapfelfx/build-release.ps1`, or use this
Release artifact after closing the game. The agent never launches/closes it.

Evidence: `tmp/cloud-evolution/validation.log`, `benchmark.log`,
`benchmarks.json`, before/after DXIL and baseline CSOs. Compatibility replay passes in both HDR addon load orders without DevKit:
24 main cloud frames, 75 delayed split cloud recordings, five native DXR
libraries and real DispatchRays per order; native fog/light receivers, sky
variants, clocks, foreign-view rejection, state restoration and teardown.
The first run hit the existing fixture's hardcoded 1.3-degree SunDiameter
expectation against the addon's current 0.25 default. The scratch replay
explicitly pins SunDiameter=1.3; production settings/defaults and test source
are untouched. Reproducer: tmp/cloud-evolution/startup-pinned.ps1; successful
log: tmp/cloud-evolution/startup-pinned.log.

Gameplay visual acceptance remains open: watch a
fixed cloudy scene for 2-3 minutes, check natural shape changes, then camera
motion, photo-mode pause/resume, rain/storm transition, clouds' terrain shadows,
reflections, Raster/RT/PT and Original/Off. Settings and preset layout unchanged.

## Shared celestial lighting, wet-weather clearing and native sizes (8 November 2026)

Validated isolated Release: `tmp/hartapfelfx-validation/celestial-coherent-lighting.addon64`
SHA256 `8bf6a348f57450c1684cdef6b57fa6cfbaacf25d4b47a083b0fc5b9150c50e10`; 5792256 bytes.
This supersedes the historical size/colour/weather behavior recorded below.
Ready for user close/rebuild/restart; installed/loaded DLL and HDR addon preserved.

- Existing Lighting Sun Size / Moon Size sliders retained, including saved values
  and authored Sun100/Moon75 defaults. Removed fixed 3.63/14.3-degree references.
  100% now scales native vertex-authored geometry; source VS matrix/unpack bounds
  and camera distance determine angular radius. Sun sqrt(3)/2 footprint comes
  from original E464 N.V>.5 shader support. No cinematic/astronomical substitute.
  Safe CPU UPLOAD observation distinguishes vertex/pixel b2, accepts b3 alias;
  original celestial fallback until potentially visible geometry is known.
  Deeply sub-horizon unobserved bodies do not block cold day/night loads.
  Runtime host observed its fixture Moon1.14593/Sun0.992404-degree diameters.
- New sky/emission.hpp caches linear native light/palette/Moon chromaticities.
  Low-Sun native warm palette supplies coherent source hue; no blue daytime halo
  tint. Native view/direct/Global builders match directional RGB at preserved
  Rec709 luminance/alpha, before scattering/reflection. Common row10 is a matrix
  and is untouched. Fresh native observation avoids tint feedback. Local lights,
  native night power and Off/Original behavior retained. Enhanced Sun/Moon/glow
  and cloud direct light consume same cache; no final-scene tint. Absolute disc
  photometric calibration remains stylized, not a new spectral atmosphere.
- Cloud primary selection now uses cloud-top spherical horizon after ground
  sunset, with per-occupied-sample planetary Sun occlusion. Terrain shadow
  selection keeps original ground-horizon behavior. Existing sky reduction
  analytically integrates native narrow cos^p solar/lunar aureoles, including
  native lunar phase. No new pass/texture/ray/root, no GPU readback/wait.
  Per-sky page adds radii112 and spectra128/144; cloud pagebase256 carries them.
  HLSL private tail416 fits existing512 page; C++ Parameters256/injection48 unchanged.
- Generator classifies all active rain/drizzle/storm/blizzard/thunder, including
  light rain and Toussaint quest rain; zero strength/probability effects excluded.
  19 profiles/56 regional rows. Wet high.w ramps first2.5% native blend, uses .2s
  protection filter separately from .8s shape fade. Paused clock can acquire
  protection, retains it until resumed on exit. Unknown retains natural cover.
  Updated existing tooltip only; no new tab/preset/control.
- PASS Clang x64 Release CompileOnly and strict shaders, native bindings/upload/
  UI/descriptor/concurrency, fog PS/CS/local/interior/negative-distance/HDR suite;
  337 production cloud GPU cases and17 celestial captures. New fixed-clock GPU
  solar/lunar source-colour transport retains luminance through FP16 precision;
  light-rain, early/paused/interrupted wet transitions pass. CPU/menu integration
  exercises actual native builder hook composition, matrix/alpha/Off/no-feedback,
  native projected size/distance and saved controls. Four additional coherent
  FP16 sunset/night captures finite/nonnegative; synthetic preview/CSV in scratch.
- PASS isolated actual-addon tests in both HDR load orders WITHOUT DevKit: sky
  families with no later disc/card draws, split command lists, native clocks,
  photo-mode local light observers, Raster/RT/PT sun consumers, native five DXR
  libraries/DispatchRays, descriptor/state restoration and teardown. Toussaint
  fixture explicitly observes actual E464 Sun mesh; A0A02407 remains screen copy.
  Final logs coherence-release-final.log, coherence-clouds-final.log,
  coherence-world-menu.log, coherence-startup-final.log and coherence-link.log.
- Research rationale/source links in sky/README.md: PBRT radiometry and Hillaire
  integrated atmosphere. Palette/luminance matching is a game-specific adaptation.
  No live gameplay visual acceptance or gameplay performance claim. Next user
  test: native100% sizes vs Original, saved sliders/glow, sunset cloud colour,
  Moon/world/fog coherence, rain/storm blends, travel/meditation/photo mode and Off.

Validated isolated Release: tmp/hartapfelfx-validation/celestial-native-style.addon64
SHA256 4a1723a19e74f2e761451ee7e7f6b2828dbc1795d403c17d02e2400e6ee57e9b; bytes 5798400. Ready for user rebuild/restart.

## Native celestial style, glow control, phases and brighter stars (8 November 2026)

Added SunGlowSizeV1 in Lighting > Sun & Moon Appearance, between Sun Size and
Moon Size:25..400%, default125%, parsed as scalar. Sun Size still scales both
body and entire glow; new control changes only glow. Existing Sun100/Moon75,
all fog/cloud preferences and Star Brightness saved/default100% preserved.
Lighting reset restores125%; Nights reset preserves glow control. Source/runtime
revision includes glow size; no new tab/preset/texture/pass/root/parameter allocation.
Private settings CBV now carries Moon64, Sun80, glow size96, exposure flag100;
composite pagebase256. ShaderInjectData48 / Parameters256 remain unchanged.

Sun native E46451D5 formula derives normalized HDR colour from GlobalCB row10
and material b2[0]/b2[2]. Native normalized colour is proportional to
pow(max(L*L*material0,0),2.2)*material2.rgb*material2.a. Shader's common positive
normalization/divisor/height/fog factors cancel in RGB ratios; final shade tint
is post-gamma. CPU-visible upload sampling:light16 + material48bytes, separate
Sun cache, same safe helper as Moon. Vertex pair E1C4426E validated, finite
nonnegative values only. Callback returns immediately for Original/PresetOff.
Read-only native capture PID31980: L=(37.2318993,24.9522991,26.5398407), material0=
(38.9785233,38.6149559,37.5709763), white material2. b4 scalar/default b12 readback
rejected for submission-end aliasing; absolute native Sun intensity NOT claimed.
Existing bounded160..800 calibration and achromatic near-horizon dimming remain;
fixed warm RGB and extra solar spectral tint removed. Cache used by following
sky recording; unavailable Sun falls back to normalized current native glow colour.

Solar shoulder uses native199RGB, native203x*y gain, material.y==1 exposure203w
branch (CPU Sky-material flag transported to composite), native206x strength,
and native pow(dot(view,sun),204x) width curve. Thus weather/sunset colours and
width follow vanilla rather than independent warm filters. Radius-relative45%
core/55%disc,12%soft rim, four-power outer falloff, short smooth afterglow and
current-cloud/fine-column attenuation remain. Moon material matching unchanged.

Both native Moon shaders use phase=2pi*(GlobalCB0.y*.033863864839+GlobalCB0.w),
world light(cos,sin,0). Helper now uses that original clock-driven vector for
surface normal NoL, earthshine and centred glow. Visible Sun/Moon positions can
stay fixed while game days advance. The native approximately29.53-day cycle,
daily rotation convention, opposite waxing/waning directions and dark-disc star
occlusion are verified; NASA terrain/regolith photometry retained. No phase UI.

Stellar linear base .2 ->1.6 (8x), saved slider/default100% untouched. Filter,
atmospheric/haze/horizon/twilight/cloud attenuation unchanged. Direct GPU A/B
against native-style-before/cloud-features.cso gives ratio8 at same ray,
footprint, atmosphere,100%:previous.0758948 -> new.607159. Both actual native
sky PS under captured haze200 now yield1051 visible stellar point pixels.

PASS Release CompileOnly/strict all DXIL/fogPS-CS/local/HDR/interior/temporal and
333cloudGPUcases,17 celestial pixel fixtures; final C++ Off guard rebuilt and
isolated-linked Release again. PASS menu/profile/reset/Off integration. PASS
actual-addon + HDR both load orders WITHOUT DevKit:24actualframes/75split
recordings/both sky variants without disc-card draws/native5DXR/realDispatchRays.
HDR float captures finite/nonnegative/belowFP16 overflow; native Sun/core colour
and separate halo palette, exposure branch, zero native strength, glow-only
scaling and inherited Sun Size scaling, opaque current vs transparent history,
clock phases/month/opposite sides all covered. GPU comparison CLI argument guard
fixed and host recompiled alone; repeat full333cases/reference8 passed. No live
visual acceptance or gameplay FPS claimed; debug layer unavailable. Production
GPU Moon phase and Sun day/sunset/afterglow preview plots inspected (fixed
exposure/Reinhard; NOT gameplay/HDR display calibration). RawRGBA32F, scripts and
HDR stats CSV retained in scratch. Logs native-style-{release,link,menu,startup,
stellar-ratio}.log. Research/current limits in sky/README.md. Game/install untouched.
User owns rebuild/restart and acceptance in Toussaint + base region/HDR.

Validated isolated Release: tmp/hartapfelfx-validation/celestial-size-balance.addon64
SHA256 33c8ec4705b2f5566e4ec179d21ba9c868e5b6c37d564a3245555cbc3c2bcc40; bytes 5787136. Ready for user rebuild/restart.

## Celestial size, native Moon material and low-Sun glow (8 November 2026)

Sun reference enlarged 1.7x to approximately3.63deg diameter; Moon enlarged4.6x
to approximately14.3deg at100%. Existing authored Moon75% remains75% (about10.7deg).
No setting migration/new tab/reset of user preferences. Solar glow now overlaps
the body/rim:55% limb-darkened body +45% radius-relative Gaussian core, dim HG
shoulder,12%-radius rim and fourth-order outer falloff. A bright wide halo with
flat20..25deg cutoff made another large circle in the first GPU preview; the
final falloff fixes that. Entire profile/support scales with Sun Size. Grazing
path mixture, wavelength-dependent transmission and a fitted low aerosol layer
produce warm sunrise/sunset and a smooth short afterglow; body extinction uses
pixel elevation, preserving the upper limb after centre-set. Native sky/weather
and all current-cloud/temporal fine-column extinction remain. No full-sky LUT,
new pass/texture/root or buffer allocation. Research/approximation limits in sky/README.md.

Native Moon material capture: standard E446F231 uses b2[0].rgb*b2[2].rgb*b2[2].a;
Toussaint6D5A1EC2 uses b12[277].rgb*b2[2].rgb*b2[2].a. Live read-only standard
capture PID32536 gives b2[0]=(14.2849865,2.55107808,.82191229), white b2[2], versus
frame277=(1.07493377,.45421204,.28163663): frame277 alone is insufficient for
standard sky. ObserveMoon validates native VS pair and reads48bytes only from
CPU-visible UPLOAD memory, caches each family under existing device mutex, and
passes16bytes via existing private settings CBV at64 (composite page320).
Following sky recording consumes it; first/unavailable material falls back to
frame277. No GPU readback/wait. NASA terrain/phase retained with native colour,
Lambert2/3 mean normalization; fixed warm tint and extra lunar spectral filter
removed, centred lunar glow follows same colour. This matches native material
values/mean reference, not exact per-pixel native terrain/phase output.

PASS final Release CompileOnly: strict all DXIL, source/root/layout/Off tests,
fogPS/CS/local/interior/HDR/temporal tests,320 production cloud GPU cases,13
celestial pixel captures including both native sky PS/captured night-haze200,
both native Moon material families, clear/opaque FP16/FP32, contradictory current
opaque/history-transparent silhouettes, Sun Size/glow scaling, low-Sun warming,
upper limb and afterglow, outer halo contrast. Both actual-addon HDR load orders
without DevKit pass24frames/75 delayed split recordings/both sky variants without
disc-card draws/native5DXR libraries/real DispatchRays. Debug layer unavailable;
no gameplay FPS or live visual acceptance claimed. Logs solar-size-{release,link,startup}.log.
Fixture solar-size-preview.py/png (production GPU data, fixed2x exposure/Reinhard,
not gameplay) inspected after correcting the outer halo. Whitespace check passes.
Game and installed addons untouched; user controls rebuild/restart and visual acceptance.

Validated isolated Release: tmp/hartapfelfx-validation/celestial-glow.addon64
SHA256 91f21e29969fe522ebed22d5b16d052d0fd0cf5970a05510507f83f027b7ce67; bytes 5779456. Ready for user rebuild/restart.

## Sun/Moon glow and stellar visibility iteration (8 November 2026)

User found literal half-degree bodies too small, Sun too hard/bright and sometimes
over clouds, lunar glow below Moon, stars invisible. New 100% size references
are Sun2.13deg (4x) / Moon3.11deg (6x); authored Moon75% remains75%, yielding
2.33deg. No profile reset or new UI section. Existing size tooltip now explains
cinematic versus Original-cloud reference. Solar limb darkening remains; native
sky amplitude sets a bounded160..800-unit core rather than40000.

Added finite-source dual-HG aureoles with smooth20..25deg support. Both discs
and glows share actual celestial directions and extinction. Glow reuses cloud
optical columns rather than marching its broad area. Existing raw current-cloud
texture is bound at privateSRV14; decode its OPACITY storage before conservative
four-tap transmission comparison. Min current/resolved/fine columns prevent
celestials shining through a visible cloud or a temporal hole. This adds no
texture allocation/root parameter/full-screen production pass. Unready main
views retain native sky/discs rather than inline enhanced/unoccluded sources.

Read-only DevKit PID15532 standard sky capture found native light12deg below
visible Moon (b12[38] vs[205]). Sky-only air direction now fades to actual Moon
at night; the native azimuth-only lunar horizon hotspot is replaced by centered
aureole. World-light/shadow constants stay unchanged. Stars use .2 gain instead
of.006 and a .65-pixel Gaussian sigma. Nights brightness and resets unchanged.

PASS309 cloudGPU cases plus9 celestial capture cases: FP16/32 clear/opaque,
frozen clock, current-opaque/history-transparent silhouettes at default and
large sizes, both actual native skyPS (449D3390/3B15DAAB) RASTERIZED with captured
night/haze200 data. Each shows116 point pixels with >.003 scene RGB contrast at
100% brightness. Test VS must retain native semantic REGISTER ORDER (UV,world,
position); adapters with position first fail PSO linkage. Previous compositor
restored in scratch FAILS silhouette regression as expected: 'Celestial source
appeared in front of the current cloud silhouette'. Both HDR load orders without
DevKit, native Moon variants, reflection atlas,75 split records, no-card/disc
skies, local fog/photo-mode,5 native DXR libraries/DispatchRays, menu/reset/Off
passed. Logs sky-iteration-{release,startup,menu,negative}.log.

RTX5090, isolated FP16 Performance clear fixture,16 warmup+16 measured frames:
4K sky adapter/render medians night.1578/.4952ms, day.0616/.3914ms. Prior same
fixture .1501/.4229 and .0578/.3286ms. Render includes adapter; these are not play
FPS, incremental gameplay cost or a low-end prediction. Running game can cause
outliers. Allocation unchanged317.125MiB at4K; new glow needs no new image.

Primary research and approximation limits: sky/README.md (Hillaire2020, Bruneton,
GPU Gems2, Epic Sky Atmosphere, PBRT HG mixtures, measured solar aureoles).
Captured data, labelled synthetic native-sky previews, previous shader and
regression inputs: tmp/hartapfelfx-validation/sky-iteration*. User still controls
restarts; final live artistic acceptance is pending. Installed game unchanged.

Final validated isolated Release: tmp/hartapfelfx-validation/celestial-sky.addon64
SHA256 21fb50738ce0d6e1d34e74f9b39d1744b0edacc465e2c4883c70d785cbc93f84 (5769216 bytes). Both HDR load orders passed without DevKit.

## Enhanced celestial sky (8 November 2026)

Shared filtered stars, analytic limb-darkened Sun and phase-lit NASA Moon now
cover native sky 449D3390 and Toussaint 3B15DAAB. Direct discs are added by the
existing cloud composite AFTER Beer extinction, so FP16 quantization cannot
leave an HDR subtraction ghost. A sky post callback also handles clear recipes
without subsequent native card/disc draws. Existing native fallbacks, four UI
tabs and independent resets remain. Star Brightness is in Night Atmosphere.
See sky/README.md for primary research, asset provenance and model limits.

The cloud Parameters block is now 256 bytes (authoring still at160, celestial
row at240, fog upload still at256). Shadow metadata is240 bytes; the shared
header at304 publishes brightness/Moon-offset/haze/tag. Moon mip storage adds
174768 bytes per View plus a device-wide immutable upload, reusing space72.
A per-sky 256-byte upload uses the existing space70 CBV, with its sky-only flag
at48. No new root parameter, native padding mutation, texture binding or
production full-screen pass. Enhanced main views skip old scene-before-emitter
copies. Atlas views use the same assets with native environment transmission.
A0A02407 is a screen copy and is no longer classified as a Sun draw; native
Moon variants E446F231/6D5A1EC2 are both covered.

RTX5090 isolated host, Performance preset, FP16, clear coverage, 16 measured
frames after16 warmup; game also running, so these are fixture timings, not
play FPS or a low-end hardware guarantee. The sky adapter is a test draw;
production folds its stars into the native sky. GPU timestamp medians:

| Resolution | Day sky adapter | Night sky adapter |
|---|---:|---:|
|1920x1080|0.0168 ms|0.0435 ms|
|3840x2160|0.0578 ms|0.1501 ms|

These include the adapter raster/write cost. Moon mip reads branch to its
angular disc; fine128-step beams branch to Sun/Moon pixels; stars skip daylight
and clear cloud-correction regions. The stellar field is fictional, stable in
world directions, flux-filtered and artistically calibrated to night exposure.

Offline verification: 305 cloud GPU cases plus FP16/FP32 analytic Sun and Moon
clear/opaque tests, frozen-clock fresh-sky redraws, strict shader/C++ Release,
menu profile/tab/reset/Off, both HDR load orders without DevKit, both sky
variants with no native cards/discs, native Toussaint Moon linkage, six-face
atlas, 75 split recordings, foreign-camera rejection, local fog/photo-mode and
five native DXR libraries/real DispatchRays. Scratch logs/captures live under
tmp/hartapfelfx-validation/celestial-*. A live visual acceptance pass is pending;
the loaded game DLL was not replaced and the user controls game restarts.

# HartapfelFX performance

## Cloud recovery after travel and meditation, 8 November

Read-only inspection of the reported scene found region 1 (Novigrad/Velen),
WT_Light_Clouds -> WT_Light_Clouds, duration45/remaining-1 (settled weather).
That recipe had zero main-family strength after flat layers were removed.
Its normal GPU blend therefore faded away the complete cloud field; switching
low-sun clearing Off could not change the zero-strength family. The generator
now supplies 0.45 volumetric cumulus strength only for Light Clouds records
whose retained main layers were empty. Existing coverage, storm exceptions,
regional recipes with main layers and removed-sheet policy are preserved.
No new blanket coverage floor is introduced.

Separately, CloudAlreadyRendered now includes the visible sun and moon rows.
Meditation can change those independently of the cloud animation clock. The
shadow cache also compares its captured low-sun direction, stored in the spare
components of its existing base-height row. This handles twilight while the
primary light direction can still be lunar. Metadata/buffer sizes are unchanged.

Release CompileOnly and strict shaders pass with 291 production cloud GPU
cases. New cases cover storm-to-light weather settling, fast travel, forward/
backward meditation at the same clock address, dawn/noon and clearing On/Off.
The settled light field retains 10978 affected pixels in the 161x91 fixture.
A frozen-clock celestial-only case fails when the prior render-cache rule is
restored in scratch shaders and passes with the fix. The full fog/native-root/
profile checks and existing storm/low-sun transport cases pass as well.
Evidence: cloud-travel-native-weather.json, cloud-travel-solar-release.log and
cloud-travel-stale-cache-before.log in tmp/hartapfelfx-validation. Gameplay
visual acceptance still requires rebuilding/restarting the loaded addon.

Final actual-addon compatibility checks also pass in both HDR load orders
without DevKit, including native DXR libraries/DispatchRays, the photo-view
local-light regression and root/heap restoration. Logs: cloud-travel-host.log
and cloud-travel-link.log. The running game addon was not replaced.

## Low-sun cloud formation, 8 November

Clear Sunrises & Sunsets is a single default-On control in Cloud Appearance.
The visible solar direction b12[204].yzw drives a smooth angular coverage
opening in CloudDensity before the existing billow/profile/erosion construction.
It uses the same field for the view, environment/reflections, incoming-light
transport and terrain shadow columns. Cloud-shadow visibility is not overridden.
No new GPU pass, texture, allocation or root binding is added. The existing
scattering.z reserved float carries the setting; Parameters remains 240 bytes.

The core spans 2.5 degrees; the existing broad column noise varies its smooth
shoulder between 10 and 15 degrees. Elevation activation fades from -8 to -3
degrees, remains full until +6, and fades out by +16. Both endpoints have zero
slope. It uses the solar lobe independently of the night-time moon light fallback.
The field depends on world position relative to the primary camera, not screen
orientation. Nearby camera translation changes it continuously; all receivers
share that same anchor. Normal time progression drives the gradual formation.

Heavy precipitation keeps natural cover. The weather generator classifies
native weather/effect records using storm/blizzard names, authored thunder and
heavy/storm rain effects, including Toussaint quest rain. fakeShadow texture
indices do not identify rainfall. The severe-weather weight occupies the
existing family high.w field, follows the exact native source/target blend and
the existing 0.8-second delta-time family fade, and attenuates the opening.
An unknown weather identity disables the opening conservatively. Modded weather
outside the audited table is not guessed from its shadow texture.

This is an art-directed coverage edit using the existing procedural material.
The separation of weather coverage, height/type shaping and detail erosion
follows [Schneider/Vos 2015](https://advances.realtimerendering.com/s2015/The%20Real-time%20Volumetric%20Cloudscapes%20of%20Horizon%20-%20Zero%20Dawn%20-%20ARTR.pdf)
and [Nubis 2017](https://www.guerrilla-games.com/read/nubis-authoring-real-time-volumetric-cloudscapes-with-the-decima-engine).
The angular/elevation bands and precipitation exception are HartapfelFX look
choices. The effect preserves native terrain/building occlusion and atmosphere.

Validation: Release C++ object, strict shader compilation and the full fog
suite pass. 277 production cloud GPU cases cover all custom qualities/presets,
solar elevation endpoints, missing/off inputs, retained surrounding density,
coarse/fine bounds, shared terrain transmission, storms in multiple regions,
Toussaint quest rain, unknown weather and interrupted severe-weather fades.
The same cloudy low-sun ground column changes from 0.000001788 transmission to
1 only in eligible fair weather. Off/On density and shadow results are identical
for severe/unknown weather. A synthetic HDR emitter capture retains over 98%
of its direct contribution in the fair-weather opening and zero in the storm
capture. This is an offline shader test, not a gameplay screenshot.

The final actual-addon compatibility host passes both HDR load orders without
DevKit, including native DXR libraries/DispatchRays, foreground fog and the
photo-view local-light regression. Menu reset/profile checks pass. Existing
user-authored fog tuning was preserved; reset tests now follow its authored
snapshot, and the transport host pins neutral medium/start values explicitly.
Logs: cloud-low-sun-weather-{release,preview,menu,host,link}.log in
tmp/hartapfelfx-validation. plot_cloud_low_sun.py, CSV, RGBA32F and labeled PNG
preserve the rendered test. No gameplay FPS improvement or live appearance
acceptance is claimed. Rebuild/restart and compare fair sunrise/sunset, entering
and leaving heavy rain, moving the camera, noon, night and Off.

## Local-light view selection, 8 November

Local injection previously looked up only the native frame CBV and chose the
last allocated cached volume. Generation and compositing also matched the
viewport. Allocating a second view for the same CBV, then returning to the first,
therefore routed lamps into the unused volume indefinitely. Reloading cleared
the cache, explaining the apparent recovery.

ApplyLocal now validates its native scene-depth input and uses its dimensions
to select the same view as generation/compositing. It does not use the graphics
viewport left by intervening shadow draws. Non-depth atlas passes cannot mark
the scene's local lighting complete. Existing frame, camera, projection, quality
and duplicate-injection guards remain in force.

The actual-addon host now dispatches both native local-light hashes through
root-CBV and table-CBV signatures. A second depth/viewport uses the same native
frame buffer, then returns to the first; split recordings are deliberately
recorded ahead. RGB readback proves the colored lamp contribution reaches the
receiver, while the existing interior check excludes it indoors. The old addon
fails this regression with monochrome sunlight and local marker zero. The fixed
Release candidate passes all 14 fog-quality/HDR-order combinations without
DevKit (336 frames, 1344 delayed lists). Evidence: fog-local-photo-before.log,
fog-local-photo-after.log, fog-local-object.log and fog-local-link.log under
tmp/hartapfelfx-validation. The running game still requires a rebuild/restart
for visual acceptance.

Earlier shared host directories contained a leftover DevKit DLL. Startup checks
now use separate nodevkit directories and reject unexpected addon files. Clean
load-order tests establish independence from DevKit; its presence alone was
not the cause established by the view-selection regression. Live captures show
the native local pass still runs after the reported photo-mode failure, with
the same b12/b13 buffers. Those GPU constants could not be read safely because
DevKit rejected an aliasable submission-end capture; no native light count is
inferred from it. Capture cleared with zero pending readbacks.

## Fog and volumetric light, 8 November

The previous receiver added native weather fog colour/desaturation and directly
lit volume radiance through one effective fog opacity. Increasing Sun & Moon
Light brightened the whole lit medium. The saved Light Focus of 0.75 also gave
scattering a narrow forward lobe: shafts were faint from the side while looking
toward the light could produce a very bright peak.

Fog Amount now scales only the weather veil and desaturation. The light volume,
incoming-light transmittance, beam radiance and actual medium density remain
independent of that composition scale. Its default is 100%, retaining the full
weather veil. Sun & Moon Beams retains the FogSunlight key and existing values;
Medium Density retains FogDensity under Advanced. Local lights retain their
separate strength. Distant Sky Haze remains the separate atmosphere control.
This is an artistic veil override, not a claim that scattering and extinction
can be physically independent in a real medium. Zero physical density still
produces neither fog nor beams. Lighting stays linear HDR without a new clip,
tone curve, bloom pass or camera exposure adjustment.

The two quick-look buttons were removed at the user's request. Defaults now use
Performance quality, Fog Amount 100%, Sun & Moon Beams 45%, Light Focus 0.65,
Lamp & Fire Light 100%, Distant Sky Haze 200%, Fade With Height 200%, Smooth Fog
Lighting On and Medium Density 100%. Saved values remain unchanged until reset.

Clear Distance defaults to zero and now spans -100 to 100. Negative values
advance the native distance fade by their magnitude. The physical medium still
starts in front of the camera; the logarithmic depth range, extinction sampling
and far bound remain valid and unchanged by negative values. The shared prefix,
per-pixel integration, opaque weather reconstruction and forward receivers all
use the same signed fade start. Zero and positive distances retain their old
behavior. History already rejects changes to this setting.

Actual shafts still require spatially varying light visibility; uniform
unoccluded sunlight produces a glow rather than a shaped beam.

### Fog quality budgets

| Preset | Shared field at 16:9 | Sun shadow samples per cell | Receiver integration |
| --- | --- | ---: | --- |
| Performance | 120 x 68 x 64 | 8 | Shared prefix + reconstruction |
| Balanced | 160 x 90 x 96 | 8 | Shared prefix + reconstruction |
| High | 240 x 135 x 128 | 8 | Shared prefix + reconstruction |
| Ultra | 256 x 144 x 128 | 16 | Shared prefix + reconstruction |
| Per-Pixel Integration | 256 x 144 x 128 | 16 | Each receiver integrates resolved cells to its own depth |
| Custom | Existing 160/96 or 240/128 budget | 8 | Existing reconstruction choice |

FogQualityPresetV1 is separate from the original FogQuality key. Custom keeps the
legacy volume choice; Performance is now the default. Saved values are retained. Portrait views
fit the same 16:9 voxel budget instead of growing their allocation. The top
budget allows four native frame-buffer rotations and their history buffers
within the existing 768 MiB pool at ordinary aspect ratios. The old Custom
clamping remains unchanged. Incompatible cached budgets retire after quality
edits; recorded work still owns its allocations and immutable settings pages.
GPU header checks reject history from a different quality preset.

Ultra's 16 shadow taps use normalized antithetic quadrature over the same cell,
so increasing quality does not deliberately boost light energy. Point/spot
lights keep their native shadow/cookie paths, four longitudinal samples, and
group culling. FAST jitter, neighborhood clipping, motion/chroma/change rejection,
current-frame extinction and interior interval exclusion remain in place.

Per-Pixel Integration reads the temporally resolved local coefficients and
integrates their lighting and extinction along the receiving ray, including the
last partial radial cell. Sparse source normalization is decoded before filtering
transport coefficients, avoiding double attenuation at vacuum edges. It then
applies the native weather opacity shaping.
No per-pixel 3D volume, new resource binding, extra render pass or GPU readback
is needed. It bypasses cubic prefix interpolation and uses four positive
bilinear reads per radial cell. The native opaque surface, forward materials,
water, particles, sky and cloud foreground fog share the same sampler. Each
uses its own receiver distance. This is full per-pixel transport integration
of a shared field, not per-pixel shadow evaluation: the field and native shadow
inputs still limit the smallest resolvable beam. Cost scales with shaded pixels
and radial cells, and can be much greater than Ultra. It is an optional quality
mode, not the recommended performance setting.

Native forward materials encode fog as colour and coverage. At zero veil, an
additive beam cannot be represented with exactly zero coverage. The adapter
retains at most 1e-4 minimum coverage when radiance is present and divides the
premultiplied radiance by that coverage, preserving its energy. At Fog Amount
100% the original representation remains unchanged.

### Primary research and design

[Wronski, SIGGRAPH 2014](https://bartwronski.com/wp-content/uploads/2014/08/bwronski_volumetric_fog_siggraph2014.pdf)
describes a camera-aligned lighting volume, cumulative integration, temporal
filtering and consumers at different depths. Retaining a shared field preserves
those advantages and avoids a separate inconsistent screen-space shaft effect.

[Hillaire, SIGGRAPH 2015](https://www.advances.realtimerendering.com/s2015/index.html)
describes unified volumetric extinction, light/shadow interaction and transport.
The existing shader's analytic-segment and reciprocal-height medium remain;
this change separates an explicit art control from that physical calculation.

[Epic's volumetric fog documentation](https://dev.epicgames.com/documentation/en-us/unreal-engine/volumetric-fog-in-unreal-engine)
separates extinction, scattering direction and per-light intensity, explains the
forward lobe's viewing-angle dependence, and recommends low global fog density
or local medium for stronger shafts without a heavy scene-wide veil. It also
identifies volume resolution as a main cost and notes trails from rapidly
changing lights under temporal reprojection. Here the new composition control
reduces the broad native veil while preserving the existing shadowed medium;
the Light Focus control adjusts the angular lobe. Existing change rejection stays
active rather than increasing history weight to hide coarse samples.

The existing four-tab layout uses the same hover-only help, scoped reset and
shared Help & About. Named quality choices let users choose a performance
budget without coordinating individual sampling controls.
Density and manual volume quality sit in collapsed named Advanced sections,
following [progressive disclosure](https://www.nngroup.com/articles/progressive-disclosure/).
No renderer implementation detail is added as persistent explanatory text in
the menu.

### Verification status

The signed Clear Distance revision passed strict shader compilation, negative
shared-volume PS/CS transport and per-pixel early-fade cases (-100 and -50),
zero/positive distance coverage, menu defaults/reset/persistence checks and the
actual addon with Performance and Per-Pixel fog in both HDR load orders. Logs:
fog-negative-finalize.log, fog-negative-gpu.log, fog-negative-menu.log and
fog-negative-host.log in tmp/hartapfelfx-validation. Earlier validation follows.

Strict Release compilation, production fog PS/CS transport, local-light paths,
interior captures and temporal cases are checked by build-release.ps1. The added
GPU cases cover 0/65/100% veil, unchanged HDR beam radiance, additive energy in
forward receivers, and per-pixel integration against analytic homogeneous
transport with native weather shaping at near, middle and far receiver depths.
Menu integration checks cover authored defaults, quality selection, preserved manual
values, portrait allocation bounds and per-tab resets. The actual-addon host passed 14 combinations: both HDR load orders, both old
Custom qualities, and Performance/Balanced/High/Ultra/Per-Pixel with the accepted
Performance clouds. Native Raster receivers, local lights, five native DXR
libraries, DispatchRays, split/delayed recordings, interior exclusion and root/
heap restoration passed. The final per-pixel coefficient-decoding correction
also passed both HDR orders and a GPU vacuum-edge transport case. All final
receiver/cloud/lighting shaders compiled strictly. The separate Release
candidate is tmp/hartapfelfx-validation/fog-beams.addon64, SHA-256
60f62df563453408d41a1ff67cd3a364dfb5f6252e6524ac77bfd7fd9294e487.
The loaded normal addon was not replaced. Live visual acceptance and clean
performance comparison remain pending; no measured gameplay speedup is claimed.

Read-only live inspection found Raster sun 806C62A8 with a 1920 x 1080 depth
input, 4096-square four-layer cascade texture, native cloud and terrain shadow
textures. Captured native weather has a 7000 m far range, density about .001954,
opacity exponent .87506 and Light Focus saved at .75. The GPU-written b13 light
constants were unavailable because DevKit rejected an unprovable submission-end
read; input presence alone is not proof of numeric visibility. The one-frame
capture was cleared with no pending readbacks. No game setting or installed
file was changed by this inspection. New-mode live appearance and clean
performance measurements require the user to rebuild/restart the addon.

## Cloud quality presets, 8 November

The original six qualities all traced at full render resolution. Their view
sample counts were floors: grazing rays request more samples to keep segments
at most 160 m long, up to 512 samples. Reducing the floor alone therefore cannot
scale expensive long rays proportionally. Sample Spacing remains available in
Custom, but a single Quality Preset is the primary performance choice.

The new CloudQualityPresetV1 selector owns sampling budgets. Existing
CloudQualityV2 and CloudStepSizeV2 keys retain their values and meaning; an
absent new key initially defaulted to Custom. The current user-authored cloud
default is Performance. Appearance, lighting strengths, native wind,
weather recipes, the Cloud Shadows toggle and other tabs remain independent.
The shared numbered RenoDX presets still save all these choices normally.

| Quality Preset | Trace width/height | View sample floor | Light budget | Shadow size / steps | Visibility volume |
| --- | --- | ---: | ---: | --- | --- |
| Performance | 50% / 50% | 64 | 3 | 384 / 32 | 256 x 256 x 32 |
| Balanced | 50% / 50% | 96 | 4 | 768 / 48 | 256 x 256 x 32 |
| High | 100% / 100% | 96 | 4 | 768 / 48 | 256 x 256 x 32 |
| Ultra | 100% / 100% | 160 | 6 | 1024 / 80 | 384 x 384 x 48 |
| Custom | 100% / 100% | Existing quality / Sample Spacing | Existing | Existing | Existing |

The secondary-light setting is the inherited nominal budget. Its fallback
integrates max(2, ceil(budget/2)) two-point segments; 3 and 4 both evaluate four
density samples. View samples retain the physical step bound and opacity exit;
shadow rays retain their sun-angle adjustment. These are budgets, not guaranteed
frame rates. The 256 x 128 environment, weather and camera-air dimensions remain
unchanged; environment rays retain their 128-sample cap and no foreground air.

Performance and Balanced reduce trace, temporal resolve, history copies and
motion-field storage to roughly one quarter of the pixels. Dimensions round up
independently. Positive bilinear weights reconstruct intrinsic HDR radiance and
Beer transmission without negative-lobe ringing. Taps behind foreground surfaces
are rejected; camera air is applied afterward at opacity-weighted cloud depth.
Mountain pixels intersecting the layer use a clipped full-resolution ray, trading
some savings for correct geometry boundaries. Measured sun/moon additions keep
the full 128-sample emitter ray and terrain-beam clamp. Native motion consumers
already resample the published field using its actual dimensions.

No per-frame random phase, checkerboard cadence, additional GPU wait/readback,
diagnostic hook or resource tracker is introduced. Existing wind-aware history
and change rejection remain active. Quality edits enter the settings revision
and immutable-allocation/retirement path. Custom and High retain the direct
full-resolution texel load. Low presets soften fine detail, especially when the
game/upscaler already uses a low internal resolution. The lighting approximation
and physical optical model remain the same across all choices.

Matched 1920 x 1080 fair-weather authored captures reproduce the old Custom
image exactly (maximum absolute difference zero). Balanced mean luminance is
1.05% below that reference in this fixture; Performance is 1.21% below. These
are whole-image static checks, not perceptual equivalence or moving-image
acceptance. Performance's initial 128-wide visibility volume darkened the image
by 13.5%; 192-wide still changed it by 6.8%. Both were rejected. Performance
therefore keeps the accepted 256-wide lighting field, prioritizing the look over
that additional saving. Its smaller shadow map and 64-sample view floor still
reduce cost. The terrain/shadow representation remains an approximation and
individual pixels can differ substantially at fine silhouettes.

Offline checks passed: strict Release C++ and replacement HLSL compilation,
256 production cloud GPU cases across six Custom levels and four named presets,
odd viewport dimensions, paused convergence at both reduced budgets, terrain
clipping, native motion, shadow Off and family/weather transitions. High is
byte-identical to Custom Medium/50 in the authored static capture; Custom is
byte-identical to the pre-change shader. Additional reduced-budget HDR moon/sun
replays leave under 5e-8 of the sampled emitter channel. Menu/profile integration
checks cover missing-key compatibility, unchanged manual choices, conditional
Advanced visibility, per-tab reset isolation and Preset Off.

The actual-addon workload passed 16 combinations of both HDR load orders,
both fog qualities and cloud Custom/Performance/Balanced/Ultra, with native
DXR dispatch and root/heap restoration. The final Performance lighting grid was
retested in all four HDR/fog combinations. No clean gameplay FPS benchmark or
live acceptance of the new presets is claimed. The running game prevented clean
GPU comparison; contended exploratory timings had large scheduling outliers
and are not reported as a speedup. Release candidate is kept separately until
the user closes/rebuilds the game-linked addon.

### Research and implementation choices

[Epic's cloud documentation](https://dev.epicgames.com/documentation/en-us/unreal-engine/volumetric-cloud-component-in-unreal-engine)
separates tracing resolution, reconstruction, primary/reflection/shadow budgets
and Beer shadow maps. This change applies that separation within this mod's
existing model and terrain requirements. Inference from the implementation:
reducing traced pixels addresses costs that lowering the sample floor cannot.

[Guerrilla's Nubis Evolved](https://www.guerrilla-games.com/read/nubis-evolved)
describes detailed 1080p clouds without temporal upscaling and the difficulties
of temporal methods with fast clouds and effects. Retain a full-resolution High
path; avoid sparse multi-frame updates that can lag motion. A static image does
not establish moving-image quality, so camera/wind/history regressions remain
necessary alongside a subsequent live check.

[EA's FAST code and paper](https://github.com/electronicarts/fastnoise) relate
sampling error to reconstruction filters. FAST samples already exist here;
fresh random jitter alone would not guarantee less noise. Preserve the accepted
stable longitudinal phase, local filtering and history rejection. Lower pixel
cost permits smooth sampling without stronger temporal accumulation.

[Nubis cubed](https://www.guerrilla-games.com/read/nubis-cubed) accelerates voxel
clouds with compressed signed distance fields and light sampling. That is a
future architecture, not a drop-in change for this animated procedural density.
A conservative occupancy/distance bound must cover every weather blend and all
authoring extremes. The existing implementation tracker records that earlier
non-conservative empty-space stepping missed thin material and created speckle.
Keep that approach rejected until a true bound and matched image tests exist.
Other future candidates are time-sliced environment updates with weather and
lightning invalidation, and profiling secondary rays at low sun. Neither is
silently enabled by these presets.

The menu exposes one choice with hover help, and reveals manual sampling only
for Custom in a collapsed named Advanced section. This follows
[progressive disclosure](https://www.nngroup.com/articles/progressive-disclosure/).
The Clouds reset includes hidden manual controls and the selector; Help, other
tabs, numbered presets and appearance controls keep their established behavior.

### Validation and measurement

Use the established Release build and production GPU fixture. Benchmark/capture
suffixes accept preset1-preset4, quality0-quality5, spacing50, authored and 4k.
The authored case reproduces current source appearance defaults, including
Internal Shadows 150%. Time is fixed at 100 s, while fresh clock addresses force
each frame to render rather than timing duplicate-frame skips. Captures and
timings warm history for 16 frames. Timings report weather, shadow, render
(air/visibility/trace/resolve/composite/copies), environment, trace dimensions and
per-view allocation. Each median covers 16 frames.

Compare baseline/candidate/candidate/baseline with the game closed for clean GPU
timings. A running game competes for GPU time; fixture timings are not whole-game
FPS or measurements on lower-end hardware. After rebuilding, check changing
weather, low sun, moon, terrain silhouettes, camera motion, Preset Off and quality
switches live. The user owns every game closure and launch.

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


## Independent volumetric light, 11 November 2026

The Lighting tab now owns the beam master, quality, medium and appearance.
Fog settings no longer supply beam density/height/clear-space controls. The
existing volume pipeline evaluates two extinction profiles in one generation
pass, integrates beam radiance using Beer transport and preserves the native
weather curve for fog opacity. A four-byte-per-cell fog sidecar adds about
2.0–18.0 MiB per active field across the four light qualities; history remains
shared. The header grows from 1024 to 1280 bytes. The mod-local hard pool cap is
896 MiB (previously 768), accommodating four rotating Ultra fields and their
histories/sidecars; allocation still follows active quality. Resource ordering and native
bindings retain the existing lifetime rules.

Light quality sets 2/4/8/16 directional shadow taps per cell and requests
120/160/240/256 columns with 64/96/128/128 slices. The shared grid takes the
higher active fog/light budget. Disabling local brightness or the beam master
skips local dispatch/preparation; local-shadow Off omits shadow texture work
while retaining projected cookies. Temporal Off controls response/stability,
not a claimed performance gain. No new gameplay timing claim accompanies
these budgets.

See [fog/README.md](fog/README.md) for the source audit, transport equations,
ABI/storage layout, UI rationale, migration, and acceptance scenes.

## Small Object Shadows with atmospheric volumes, 11 November 2026

Both local lighting hashes (E6A77B56, 9A6F318E) had their local-volume
observer registered after the shader replacement callback. DrawVolume
restored the native PSO after private work, overwriting the contact/PBR
replacement already selected for the dispatch. The addon now registers only
these observers before the shader module. Sun observers stay after native
night-light edits. This correction adds no GPU pass or shadow samples.

Forward receivers also lacked contact_length: the shader settings adapter
zero-initialized the field and never filled it. The existing immutable
lighting upload now stores reach as its fifth float, which the adapter copies
into receiver settings. The 256-byte allocation and root layout stay the same.
Affected forward receivers now execute their existing shadow trace; zero reach
had disabled it. No gameplay timing claim is made.

The integration regression returned exit 60 before the scheduling fix and
checks both hash registrations. The actual-addon GPU controls probe now
includes the production HLSL adapter and checks reach (1.00 m in its profile)
as well as the original four controls. Evidence is retained under
tmp/small-shadows-20261111. Final results and installation status follow.

Final validation: the complete Clang Release compile-only workflow passed,
including settings/lifecycle, descriptor/upload lifetime, production fog/light
transport and receiver cases, native ray-root checks and 387 cloud GPU cases.
Six actual-addon startup runs passed with the installed Agility 619 runtime:
both HDR load orders at both custom fog qualities, plus both load orders with
Original fog and independent Ultra volumetric light. Each run checked the
production lighting adapter's 1.00 m reach on the GPU, native Raster/RT/PT
consumer linkage, delayed recordings, HDR private roots and real DispatchRays.
The host's D3D12 debug layer was unavailable. Gameplay appearance/frame times
remain a separate acceptance check.

Installed after the user closed the game. Candidate, build/Release addon and
the existing game-folder symlink all match SHA-256
D92455C077FA2808C472CCACEB5DFF8FC43CD59F4E783B4BDEE74CF6C2483A94
(6,178,816 bytes). The previous addon and symbols are backed up in
tmp/small-shadows-20261111. The separate HDR addon and game configuration
were preserved. No game process was launched or closed by the agent.

## Engine light-source alignment, 11 November 2026

The optional mod0000_HartapfelLightAlignment content/script companion places
verified local lights at their authored flame spawners. A generated content
patch updates 315 components in 187 effective templates (630 editable/compiled
records), preserving every other asset byte except required checksums. The
builder resolves the user's active source-mod overrides; the new folder does
not alter those mods or the HDR addon. Unsupported template edits are skipped.

A native-slot script map covers 201 fixture identities and corrects gameplay
instance overrides. New fixtures are handled at spawn. A bounded 60 m / 2048
entity sweep every five seconds covers restored and subclassed fixtures.
Per-entity caching avoids repeated slot resolution and SetPosition calls.
There is no per-frame scan, diagnostic readback or new lighting pass in the
production feature. No gameplay CPU/GPU timing claim is made.

Data verification passes all position-only byte comparisons, compiled-copy
consistency, nested checksums, bundle round trips and idempotence. The user
restarted the game, native scripts compiled and gameplay resumed. Live t18
copies show the nearby 1.8 m-radius candle source corrected about 0.61 m down
onto its emitter, within about 1.4 mm of its corresponding spot source (small
flicker remains). Unrelated window fills stay unchanged; lighting replacement
logs report zero fallbacks. Separate all-mode/location visual acceptance is
still pending. The existing Release addon hash is unchanged.

Implementation, source references, rebuild/update limitations, install hashes
and evidence are in lighting/alignment/README.md and
tmp/light-alignment-20261111. The full emissive-light replacement remains
separate research; this step aligns the native lights.

### 2026-11-11 - Standalone Light Alignment package and brazier coverage
- Public script-only mod-manager ZIP is generated with lighting/alignment/package_release.py. No addon rebuild, native plugin or GPU pass is introduced. Optional personal template bundles are excluded from distribution.
- Extended the bounded offline reader to CR2W 163/164 for flame-slot associations; byte editing remains restricted to 162. Added 62 verified brazier/fireplace fixture identities, retaining the original 201 mappings.
- The bathhouse floor-brazier complex has a source point light at local Z 3.2 m versus flame slots near 0.4 m. New mappings resolve the actual engine slot matrices, preserving light count and photometric/shadow settings.
- Package validation passed: six safe archive members, simulated installation layout, all payload hashes and all 263 unique fixture mappings. Expanded map syntax diagnostics are empty. Two independent builds produced SHA-256 1AF03636980B7E1263A45EAC744D6F6D56E2038BD044D92A1E4CE1F368E59248. The original position-only asset regression still passes (187 templates / 315 components).
- Runtime algorithm is unchanged: spawn hooks plus bounded 5-second / 60 m / 2048-entity fallback, cached per-entity slot resolution. CPU and FPS costs remain unmeasured. New brazier live acceptance awaits the user-controlled restart.

### 2026-11-11 - Hanging-bowl emission origin follow-up
- The user confirmed the floor-brazier result. Two-frame ready native t18 captures match four point sources lowered by 2.392-2.401 m and two spots lowered by about 0.532 m. Radius/type stayed equal and world XY differences were below 1.7 cm including flicker. Diagnostic collection is cleared.
- A hanging bowl exposed an additional particle-local offset. Verified torch_fx5.w2p SHA-256 A393A17150FA9250250CE613518D615C37AE533D5DA95C5D237A6B5E3B4CE86B has one cooked emitter with constant position (-0.01, 0, 0.10) and zero extra position_offset. Ten supported fixture identities now compose this with the -0.35 m effect-spawner offset.
- The composition is generated offline and changes only the native position map. Runtime script, timer frequency, scan bounds and addon remain unchanged. Particle data and game assets are not distributed in the standalone package.
- Constant-origin parser and hanging-lamp regression checks pass, including rejection of varying emitter positions. Expanded map syntax and package validation pass. Final ZIP is 9,661 bytes with SHA-256 D7CCD8BDFF6FED2BD2C281F5D5719E04A3D4B0D874E9C1C6360668CD9B05618B; an independent rebuild is identical. Hanging-bowl live acceptance awaits the user's restart.

### 2026-11-11 - Packed bathhouse bowl light and public release package
- The user's screenshot and failed hanging-lamp experiment required tracing the placed world sources. The internal particle-origin improvement is retained for ten verified lamp fixtures, but did not solve this particular bowl. Do not claim it did.
- Read-only source inspection and native captures identify a packed static point pair in levels/novigrad/novigrad/bathhouse/lights.w2l. The pair shares XY (714.008972, 2000.185913); Z is 15.738350 / 17.345688. The lower radius-14 m, brightness-10 light is 1.607338 m below the upper radius-6 m, brightness-40 source. These lights are not gameplay entities accessible to the script sweep.
- Added static_lights.py: source SHA-256 guard, bounded version-8 sector reader, lower-point render and streaming position copies moved to the upper point, existing CR2W checksums rebuilt. Validation permits only those coordinates and checksums: 18 bytes change, all light properties and every other layer object preserved. Wrong-source rejection and compressed bundle round trip pass.
- A fresh build directly from the installed stock game produces identical bundle and metadata bytes to the independently extracted-input build. The public archive now combines scripts and this native patch in one mod folder; it excludes the personalized BetterCandles content bundle.
- Public release ZIP: build/Release/packages/HartapfelFX-Light-Alignment-1.0.0-release/HartapfelFX-Light-Alignment-Remastered-1.0.0.zip; 14,293 bytes, eight members, SHA-256 B516AFC872849B0485F4F84DFB18B55FEEAFD9A3ACD214BCAB9E538AF06A8C06. Safe paths, hashes, simulated installation and a complete independent rebuild pass.
- The local personal setup retains its existing bundle and loads the byte-identical native correction through mod0000_HartapfelLightAlignmentWorld. A public-package migration should remove both old companion folders first. Other installed mods, settings and the addon are preserved. Live acceptance follows the user-controlled restart.

### 2026-11-11 - Local volumetric geometry occlusion
- After the user confirmed the packed bathhouse bowl correction, the user supplied an outside-wall example of local scattering leaking through a building and props. Ready t18 capture records show nearby unshadowed lamp records and available maps with low surface shadow blend weights. Captured allocation contents are not an authoritative active scene count.
- Added bounded, perspective-correct visible-depth intervals in fog/local_occlusion.hlsli, reusing native t0 and the verified Remastered frame/depth matrices. Native atlas/cube shadows remain the world-space source; no new GPU resources, engine shadow maps, geometry replay or CPU readbacks are introduced in production.
- The volume now preserves full native map visibility instead of restoring energy through the surface shadow fade, uses a 2 mm world receiver bias, and clamps atlas samples within the selected tile. Local injection is cropped at the column's opaque depth to avoid mixing hidden light into its terminal visible cell.
- Lamp Occlusion Quality lives in the existing advanced Lighting section: Native Shadows Only, Balanced (default, up to 8 intervals), High (16), Ultra (24). The existing shadow master disables it. It occupies a reserved float in the unchanged 48-byte light constants and invalidates volume history when changed.
- Strict shaders, standalone production PS/CS GPU tests, new wall/clear/near-plane/offscreen/radial-depth probes, and native atlas/cube fade regressions pass. The GPU host's debug layer was unavailable. C++ control/migration/ownership/callback-order/Off tests pass. Game GPU timing and all-mode visual acceptance remain outstanding; hidden/offscreen geometry without a native map remains a documented limitation.
- See fog/LOCAL_OCCLUSION.md and tmp/local-light-occlusion-20261111. Capture collection was cleared. Release build and actual-addon compatibility checks follow the user's game closure.

### 2026-11-11 - Small wooden wall-torch alignment, standalone 1.0.1
- DevKit-only scene-color and native light captures identify the current Novigrad fish-market fixture as torch_wall_wooden_small_bounce in water_channel_ns.w2l. The captured light matches its placed light_point slot within 0.1 mm; the flame slot plus authored spawner offset predicts a 0.295 m correction, including 0.166 m down.
- Added three verified small wooden wall-torch identities, bringing the standalone catalog to 266. All eleven stock/installed template occurrences agree per identity. Ten stock checksum checks pass; the installed BetterCandles copy has two pre-existing chunk checksum diagnostics. Its bounded properties match stock; no source assets are edited or distributed for this change.
- Native-slot runtime and its bounded scan/cache behavior are unchanged. Only hf_light_alignment_map.ws was replaced in the personal installation; original script, personal bundles, native bathhouse patch and addon are preserved. Installed map SHA-256: 95384FFBD66885AF2C9F25ED0C4B00C2DB6F8CAC44429412C1ACAEB581059F6B.
- Version 1.0.1 ZIP passes syntax, payload hashes, safe paths/install layout and independent byte-identical rebuild checks. Eight members, 14,383 bytes, SHA-256 ACEF0B8C19E8AA1C905C8CD4C988311F9E2015E3B3F7607D824D5FB8D682830E. All previous candle/brazier bindings and the native world correction are retained.
- Captures are cleared with zero pending readbacks. Same-view verification awaits the user-controlled restart; no manual build is needed. See lighting/alignment/README.md and tmp/torch-alignment-20261111.

### 2026-11-11 - Automated fixture discovery and Crow's Perch long torch, standalone 1.1.0
- Added lighting/alignment/catalog.py to index installed content/DLC and enabled mod bundles, examine owned point/spot components and authored flame attachments, and generate a candidate catalog/report without visiting individual scenes. The run indexed 24,663 entity paths from 64 bundles; 734 serialized candidates were reported, with 284 fixture paths passing the guards. After name-ambiguity checks, 71 identities were added for a total of 337, preserving all 266 previous bindings.
- New mappings require explicit unique native slots, stationary attachments and consistent content/active-mod associations. The scan excludes gameplay/cinematic composites and reports unsupported formats, bone/separate attachments, missing slots and ambiguous stems. No arbitrary nearest-world-flame matching is used. Packed sector lights still require separately verified world-layer associations.
- DevKit-only frame/light inspection identifies the current fence-mounted torch at Crow's Perch as torch_hand_long_complex in baron_castle/fx_lights.w2l. Its local flame attachment plus spawner gives (-0.030710, 0.001624, 0.230000). Captured point/spot pair distances match the authored fixture within 1.5 cm including flicker; expected corrections are 0.535 / 0.504 m. Runtime resolves actual tilted world positions through native matrices.
- The catalog audit re-extracts every added source and validates hashes, associations, fixture scope, ambiguity guards and preserved baseline. Map syntax and public ZIP tests pass. Independent package builds are byte-identical: eight members, 15,497 bytes, SHA-256 1E3474E80D568F463A19FF88DD09BF18A4D4A6BFD7765B1CE6FBF977F0B9BF2F.
- Only the local generated map was replaced; installed SHA-256 EEA4ECF2EAAF6680FBD568B9A74351D714BBC75D6CD35D226B3F692CD5774D84. Runtime script, personal template bundles, bathhouse native patch and both addons are preserved. No addon rebuild is required. Runtime retains the 5-second / 60 m / 2048-entity sweep and cache; increased one-time name lookup work and game CPU/FPS impact are unmeasured.
- Diagnostic captures are cleared with zero pending readbacks. A user-controlled restart and same-scene verification are pending. Sources, commands and limits are in lighting/alignment/AUTOMATION.md; evidence is in tmp/light-alignment-auto-20261111.

### 2026-11-11 - Automated catalog live position verification
- The user restarted the game with the 337-entry map. Two ready native t18 captures confirm the Crow's Perch torch point moves 0.528 / 0.528 m and the spot 0.504 / 0.504 m, with radius and type unchanged. Their separation is 3.47 / 3.50 cm including native flicker. This agrees with the authored attachment corrections, without relying on stable light-buffer indices between launches.
- The expanded script map compiled and gameplay resumed. The camera moved away from the close-up; no identical-view visual quality, all-location or all-mode visual claim is made. Source position verification is recorded in tmp/light-alignment-auto-20261111/live-verification.json and after-inputs.json.
- Both captures are cleared, zero pending readbacks. Post-install hashes confirm the original runtime script, personal content bundle, native bathhouse patch, HartapfelFX addon and separate HDR addon are preserved. The version 1.1.0 archive remains byte-identical to its independently validated rebuild.

### 2026-11-11 - Torch self-shadow halo and internal flame origin, standalone 1.1.1
- Ready native depth/t18 captures reproduce the supplied torch scene. At the point-source projection, opaque camera-view depth is 4.081004 m versus light depth 4.097690 m: the old source is about 1.7 cm inside the wrapped torch head. CPU replay of the existing depth query blocks nearly all nearby rays, including on a full candidate-hit reprojection; a broad sampling-interval change does not resolve this source-placement error.
- Exact installed torch_fx1.w2p SHA-256 0EDF0B62A621E4BC0008A640D782E859601740EA6697762996E943BE9D05B713 has six emitters. The unique Copy of new_fire_looped flame initializes at (-0.01, 0, 0.10), with identical position endpoints and zero additional position_offset. Its origin differs from the attachment root used by the previous map. Smoke/sphere/distortion/sparks are separate emitters and are not used for flame placement.
- Added explicit named-emitter support to the bounded particle reader and the verified torch profile. Re-extracted and matched all 337 source associations to their old bindings. Exactly 13 torch families now compose the measured particle displacement through native slot matrices; the other 324 bindings and every slot identity are unchanged. No shadow bias, visibility threshold, sampling budget, map or master setting is weakened.
- Both exact particle hash/origin regressions pass, including named flame selection among six emitters and rejection of ambiguous, missing or varying emitters. Hanging-lamp composition remains valid. Generated map syntax and package layout/hash checks pass. Two independent package builds match: eight members, 15,580 bytes, SHA-256 A44F30BC963A86FB5800A8ACAE6CA875EA66D5F56C5D47CA617772405BD2D8AC.
- Installed only the generated map, SHA-256 4CB26F5A2A8B7F77671317B569A3C133AAD223ED4DA3F6A368AC817E3867A6B5. Addon/runtime and native bathhouse correction are preserved. Capture collection is cleared; live depth and same-view halo verification await the user-controlled restart. No manual build is needed. Evidence: tmp/local-light-halo-20261111; method and primary format links: lighting/alignment/README.md.


## Local RT/PT volumetric visibility investigation (2026-11-11)

Raster has user acceptance and remains on native shadow maps. RT/PT now submit world-visibility ray dispatches, but visible local scattering is still absent in the user scene; this is not an accepted performance or rendering result. The exact production ray shader passes 36 synthetic GPU cases across four quality levels. Native PT/SER and local-shadow pipeline compatibility pass both HDR addon load orders. Current shader diagnostics read back a 1280-byte header at most once per 300 presents, with completion fences and no CPU wait. No gameplay frame-time improvement or cost claim is made. See fog/LOCAL_OCCLUSION.md for the captured ABI, remaining GPU acceptance checks and source references.

Follow-up: the live GPU header reports stages=3, proving rejection at the native/deferred TAA jitter equality check before tracing. World-space BVH queries now accept different ray-pass jitter/projections while preserving source epoch/depth, camera origin, viewport and exact fog-field validation. The expanded GPU regression has 48 passing cases. Live acceptance of this correction remains pending.

Live follow-up: native CameraCB b0/space1 row 8, rather than zero RT/PT SharedPixelConsts camera fields, is the correct view source. The user confirms visible PT local scattering; GPU stages=63, owner=1, 43 lights. A directional torch cutoff remains under investigation. The candidate restores the native finite emitter exclusion and passes 72 GPU cases, with visible wall blockers outside the excluded segment. Installed standalone alignment files hash-match 1.1.1. Gameplay timing and directional-shadow acceptance remain pending.

Accepted live candidate: 128c9c541ef82b6fc8dd7b274f7c2ffc85d71fd20330a0a3e466a9d0e23a2474. The user confirms the previous bad torch angle looks much better. GPU stages=63, owner=1, 15 lights; native emitter exclusions are 0.25 m default and 0.3 m fallback, with override enabled. All 72 production-ray cases pass. This records PT scene acceptance, not a measured FPS claim, whole-world coverage, or a separate hybrid-RT visual comparison.

Final validation: accepted DLL passes startup13.log in both HDR load orders and both fog quality variants, plus check-runtime13.log Release/integration checks and test-ray9.log 72 GPU cases. HDR addon hash is unchanged. Documentation-only follow-up requires no rebuild.


## Screenshot defaults and settings order (2026-11-11)

Fog and Lighting defaults now follow the user screenshots, with the subsequent Lamp Occlusion Quality override to Low (one world-visibility sample). Light Quality defaults to Balanced. Appearance, density and indoor controls use the requested values; names, keys, ranges, tooltips and renderer math are unchanged. The existing sections and controls are reordered by related task, keeping the Advanced disclosures. See fog/README.md for the complete defaults, sequence and NN/g research references. Release object compilation, existing lighting/reset/migration/Preset Off integration, and the real-ImGui five-tab regression pass. All 33 visible screenshot values were reviewed, including Low occlusion. This update does not claim measured frame-time gains.
