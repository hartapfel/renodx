# Cloud structure and evolution, 2026-11-01

## Findings and primary references

Increasing Coverage and Size changes distribution and scale, but cannot add the
missing intermediate structures. The previous shader packed a biased formation
scalar and fine erosion into two channels, applied one height fade after the
coverage threshold, and lit the surface using uneroded secondary samples. These
choices explain both smooth silhouettes and weak relief. The original 130% Coverage and
200% Size preferences were later superseded by the rebased appearance update below.

| Reference | Relevant finding | Application to Classic |
|---|---|---|
| [Schneider, Nubis 2017](https://advances.realtimerendering.com/s2017/) — density and authoring sections, slides 28–50 | Cloud distribution, vertical profile, billows and erosion serve different purposes. Height-dependent structure and evolving detail give more control than a single thresholded noise field. | Separate formation, column profile, intermediate billows and erosion. Keep weather distribution independent of user Size and animation. |
| [Schneider, Nubis Evolved 2022](https://www.guerrilla-games.com/read/nubis-evolved) — sky profile and envelope models | A low-frequency dimensional profile is refined into volume detail; cloud type can blend wispy and billowy structures. | Put the vertical profile inside the isodensity boundary. Blend edge character with relative height and a coherent profile field. |
| [Schneider, Nubis³ 2023](https://www.guerrilla-games.com/read/nubis-cubed) — PDF pages 94–103 | Unmodified Worley structures can resemble packed spheres. Layering, distinct billow/wisp fields and appropriate filtering matter. Its full voxel approach also uses simulation-derived assets and dedicated acceleration. | Use a hierarchy of feature scales and a periodic domain deformation. Full fluid/voxel modeling would require a separate content and acceleration pipeline. |
| [Hillaire, Frostbite 2016](https://media.contentapi.ea.com/content/dam/eacom/frostbite/files/s2016-pbs-frostbite-sky-clouds-new.pdf) — sections 5.2–5.7 | Shape and erosion fields, cloud profiles, high-albedo light transport and temporal integration work together. Noise is evaluated as material density, separately from lighting. | Retain analytic Beer integration and incident HDR radiance. Refine extinction/self-shadowing together, with filtered detail. The relative density field is not measured liquid-water content; its extinction remains a scene-scale calibration. |
| [Hillaire, SIGGRAPH 2020](https://blog.selfshadow.com/publications/s2020-shading-course/hillaire/s2020_pbs_hillaire_slides.pdf) — slides 26–32 | Multiple scattering is important to avoid smoky clouds. The octave approximation and analytic segment integration are practical. Powder edge tricks are not multiple scattering. | Retain the reduced-energy/eccentricity/extinction approximation, with two extra orders at Low/Medium and three at High+. Do not add an emissive brightness floor or a powder-based replacement for transport. |

[Bauer's RDR2 presentation](https://www.advances.realtimerendering.com/s2019/index.htm)
also emphasizes a coherent atmospheric solution. This revision keeps the existing
shared cloud-shadow/air-lighting integration; it does not reproduce Rockstar's
engine, its irradiance system, or Guerrilla's fluid simulations.

## W3Atmos comparison

Inspected the user-provided v0.18.88 HLSL and preset files read-only, after the
primary-source review. The supplied addon was not executed or installed.
HLSL SHA-256: `F07DA166FEE6018F6403CAE27B7399615C47402D7E32AF4F937A6C0BBEE5628A`.

| Observed in W3Atmos source | Conclusion for this implementation |
|---|---|
| `type_profile` and `layer_density`: different vertical profiles, fixed-scale fields, evolving shape/erosion, outline detail | Useful confirmation of the density-model diagnosis. Implement these principles using our own precomputed texture sampler. |
| `clouds`: detailed nearby light samples plus cheaper far density | A coarse uneroded field can hide visible billow relief. Resolve nearby shadow segments against erosion, retaining filtered broad density farther away. |
| Separate high cloud layers, weather profiles and storm structures | These are substantial additional systems, not a quality multiplier. This revision improves the existing ground-view layer; it does not claim equivalent layer/species coverage. |
| Per-pixel weather texture averaging and procedural noise/hash evaluation | Keep Classic's existing native weather field and GPU-generated volume. Avoid repeating weather reduction or expensive analytic noise inside every light sample. |
| Optional tint, phase/style boosts, highlight knees and atmospheric adjustments | Preserve our incident-light/HDR path and Darker Nights controls. Those look adjustments are not required for the density change. |

No W3Atmos code, presets, assets or binaries are included in the mod/package.

## Implemented model

`clouds/0xF3C60001.cs_5_0.hlsl` now fills all four channels with formation
potential, billows, erosion and broad variation. A tileable, divergence-free
displacement field breaks regular cellular structure during one-time generation.
This is a procedural deformation, not a fluid simulation.

`clouds/common.hlsli` combines an unchanged native weather footprint with a
column-coherent vertical profile and intermediate 3D billows. Erosion changes
from wispy lower regions toward billowy upper regions and uses three physical
scales. The profile is applied before thresholding, changing actual boundaries
instead of only fading a rounded blob. Noise filtering accounts for the view
pixel cone and integration footprint. Cloud-base height stays fixed.

The profile is a continuous procedural interpretation of coverage and a broad
field. The available shadow map does not uniquely identify meteorological cloud
species. Exact native silhouettes, native card placement and every authored
weather-specific layer are not reconstructed by this model.

`clouds/pipeline.hpp` retains the native 256-byte PS b0 clock (validated by its
native cloud-UV use), binds it in isolated compute state and copies it to the
previous-frame GPU buffer. Missing/incompatible input uses a zero clock. The CPU
does no density work or readback. Shape and erosion evolve at separate rates;
visible clouds and world shadows sample the same field and clock.

The primary ray uses one detailed density evaluation rather than evaluating the
coarse and detailed fields redundantly. Secondary intervals concentrate samples
near the scattering point, resolving erosion for the first two intervals and
using filtered broad density farther away. Temporal reprojection includes bulk
vertical evolution, rejects clock jumps, and reduces history at changing opacity;
unreliable cloud edges request responsiveness through the existing DLSS/FG path.

## Verification and remaining acceptance

Build with `cmake --build --preset clang-x64-release --target thewitcher3classic`.
Standalone fixtures are `tests/clouds.cpp`, `cloud_shadows.cpp`,
`cloud_material.cpp`, `night_sky.cpp`, `night_bindings.cpp`, `volumetrics.cpp`
and `presets.cpp`. Use the established WARP/hardware runners. The cloud fixtures
explicitly use neutral appearance values so default changes cannot silently
change the meaning of optical comparisons. Native/reset defaults are checked
separately by the preset fixture.

Checks include zero density/coverage/light, HDR headroom, retained alpha and
foreground motion, coarse-density bounds, native state restoration, paused
stability, evolving cloud shadows, clock-jump history rejection and unchanged
weather coordinates when Size changes. Shader compile success and synthetic
renders do not establish final gameplay appearance or eliminate all sampling
noise. The D3D debug layer is unavailable on this installation.

For gameplay acceptance, compare fair weather, broken cover and an overcast
transition at the saved settings. Inspect front-lit and back-lit clouds, flat
bases and upper contours, horizon stability, shadows/shafts, paused animation,
day/night fading, and camera movement with DLAA/DLSS and FG. GPU measurements and
the final package result are recorded in the main README after the build.

## Density hierarchy revision — 2026-11-01

Checkpoint before this revision: `0925f2ec63024522123ebce9e352d95ebeb58b05`
on origin/main. This section supersedes the earlier morphology description.

### Research conclusions

- [WMO International Cloud Atlas: Cumulus](https://cloudatlas.wmo.int/en/cumulus-cu.html)
  describes connected vertical mounds with cauliflower-like upper contours and
  approximately horizontal bases. Smaller lobes belong to those masses; random
  isolated fragments everywhere are not a general model of fair-weather cumulus.
- [Nubis 2017](https://www.guerrilla-games.com/read/nubis-authoring-real-time-volumetric-cloudscapes-with-the-decima-engine)
  separates weather-scale distribution, shape noise and detail erosion. A single
  higher-frequency overlay does not replace that hierarchy.
- [Nubis Evolved, 2022](https://www.guerrilla-games.com/read/nubis-evolved),
  presentation pp. 19–30, distinguishes coverage, minimum/maximum height and
  top/bottom profile. Eroding a meaningful three-dimensional envelope gives
  structure a flat, rapidly opaque lower boundary cannot show.
- [Nubis³, 2023](https://www.guerrilla-games.com/read/nubis-cubed), PDF pp. 93–123,
  discusses packed-sphere artifacts from simple Worley noise, nested frequencies,
  billows versus wisps and dimensional-profile up-rez. Its voxel/cloud-fluid
  authoring system is substantially beyond a shader substitution. These concepts
  guide this procedural approximation; it is not an implementation of Nubis³.
- [Frostbite's physically based atmosphere/cloud notes](https://media.contentapi.ea.com/content/dam/eacom/frostbite/files/s2016-pbs-frostbite-sky-clouds-new.pdf),
  sections 5.3–5.4, separate density/shape from incident lighting. Density remains
  a multiplier on extinction after structure, with Beer–Lambert transport and
  existing approximate multiple scattering. Increasing density must not be used
  as a substitute for adding spatial detail.

| Approach | Decision for Classic |
|---|---|
| More pixels or shorter ray steps alone | Preserve these controls; they resolve an existing field, but cannot add missing morphology. |
| Add a noise/color overlay after cloud rendering | Reject: it does not change occlusion, silhouette, ground shadows or shafts. |
| Live fluid simulation/full authored voxel worlds | Defer: substantially more memory, authoring and weather integration; not necessary for a ground-view improvement. |
| Layered, advected procedural density with filtered lighting | Implement within the existing GPU cloud/shadow pipeline. No CPU density work or GPU readback. |

After the primary-source review, the supplied W3Atmos v0.18.88 HLSL was inspected
again, particularly `layer_density`, puffs, erosion size, dense tops, loose bottoms
and the screenshot's style settings. Useful distinctions are formation size
versus erosion size, the vertical density profile, and smaller features changing
actual density rather than color. Its artistic sun/sky/inner-glow boosts are not
required for this task. No W3Atmos or SideFX source/assets are copied or bundled.

### Implementation

The one-time tileable noise bake now retains separate cellular scales instead of
pre-averaging them into every channel. The 32-cell octave in a 64-voxel texture
was removed: two texels per feature left too little sampling margin. Periodic
gradient-noise warping breaks the lattice before sampling. This is a procedural
deformation, not a fluid simulation; the old divergence-free claim does not apply.

The density sampler separates the weather-driven formation envelope from nested
surface lobes and erosion. Relief affects the local base/top envelope within the
fixed layer bounds. Higher quality adds finer relief as well as finer erosion.
The detail scale is independent of formation size. Erosion remains inside the
parent envelope; increasing optical density therefore preserves the modeled
boundary instead of revealing only a planar slab. Optical-density scaling remains
linear and follows all structural operations.

Three controls under **Cloud Shape** expose Surface Detail (100%), Detail Size
(100%) and Base Softness (50%). They have explicit values in both tab presets,
invalidate cloud history when changed, and affect the shared world-shadow field.
Existing quality, coverage, size, density and sampling defaults are preserved.

Near sunlight segments sample the visible density's quality level. Distant
segments keep one beam-filtered erosion band rather than an un-eroded solid
envelope. This avoids shadowing visible holes with nonexistent cloud material.
The number of view/light samples and the HDR source/phase/scattering energy
model are unchanged. Filtered ground shadows keep their existing budget.

HDR composition, cloud/foreground fog ordering, native weather coordinates,
native GPU clock, Darker Nights and DLSS/FG motion handling are retained. Synthetic
comparisons cannot prove a match to the user's exact weather or photographic
cloud microphysics; final gameplay appearance still requires visual acceptance.

Fine structures now use the same bulk vertical evolution rate as cloud motion
and temporal reprojection. The earlier extra detail scroll was incompatible with
that single motion estimate, especially once relief became visible on the opaque
boundary. Evolution still changes the density within the world-anchored profile;
no independent scrolling texture is added over the cloud surface.

### Vertical curtains and weather transitions

The close-up screenshots exposed a second defect: the old profile inferred type
and height inversely from each local shadow-mask value. Thin mask edges therefore
grew taller than their cores. A production shadow regression demonstrated this:
fading cover from 0.7 toward zero could increase occlusion at some locations.
Height/type now come from the coherent formation field, independently of local
coverage. The same regression passes with the correction: fading out cannot
darken those shadows. This is a procedural profile, not a cloud-species estimate.

The native source is a 2D cloud-shadow silhouette, rather than a complete 3D
weather description. The new `0xF3C60007` prepass converts it into broad coverage
with a symmetric world-scale binomial filter. Fine structure remains the job of
3D density; a sharp native silhouette is not extruded through the entire layer.
The 128-square field is shared by visible clouds, shadows and fog lighting. This
preserves constant inputs and the field's mean, although individual silhouettes
are deliberately smoothed. No weather readback or CPU density evaluation occurs.

The field also fades between weather states using exact exponential decay with
a 0.8-second time constant. This is an artistic transition filter, not a physical
meteorological time scale. CPU wall time supplies only the scalar interpolation
weight once per frame, including paused weather edits; each frame's elapsed time
is capped at 0.25 seconds to avoid snapping after a stall. Native layer blending
is retained before this filter. Frame discontinuities initialize fresh coverage;
ordinary consecutive-frame weather changes preserve history.

Two FP32 128-square textures avoid half-precision accumulation stalls at high
frame rates. History is remapped when weather-map scale or wind origin changes.
Continuous wind cancels algebraically in UV space, avoiding large-coordinate
subtraction and repeated resampling blur. Weather-origin resets preserve the old
field in world space while fading to the new state. Cloud bounds, density sliders
and manual coverage overrides retain their existing meanings.

`tests/cloud_weather.cpp` validates constant/mean preservation, sharp-edge
filtering, native layer blending, wind/scale/origin reprojection, bounded in/out
fades, equivalent elapsed-time subdivision and history reset on WARP/NVIDIA.
`tests/cloud_shadows.cpp` additionally exercises the actual pipeline's wall-time
fade and its monotonic shadow response; the prior height coupling fails this
check. Most pre-existing constant-weather fixtures explicitly use frame cuts to
isolate steady-state properties rather than accidentally testing a weather fade.


### Underside terraces and HDR sun occultation

The positive-only lower-envelope erosion left a global flat floor. Signed,
world-scale lower relief now forms hanging lobes and upward cavities; the ray
interval expands conservatively below the nominal base. Additional fine bands
remain subtractive, preserving the fine <= coarse density bound. Detail stays
in metres as thickness changes. At strong detail the former hard 0.92 erosion
cap created constant-valued regions; smooth compounding of retained density
replaces that plateau. The reported scene's 200% detail / 50% detail size /
150% thickness values are covered by the material fixture.

Independent synthetic comparisons at 92 view / 5 sunlight samples against
512 view or 40 sunlight samples distinguish sampling loss from morphology.
They do not justify a blanket increase to every quality level. This follow-up
keeps view/light budgets and the confirmed ground-shadow-map technique intact.

The native sun lobe is part of the sky shaders F12E637D and BC930752. Clouds
composite over that sky through their integrated transmission. The view march
previously stopped at 0.005 transmission: that is not opaque against an HDR sun.
Following the Beer-Lambert transfer model, the march now continues extinction
until 1e-8 or the existing step budget, while skipping expensive lighting below
0.005. This removes the residual background rather than drawing a black disc
or artificially boosting shadow strength. Cloud scattering still supplies the
lit cloud and its forward-scattering glow. Thin clouds may physically transmit
the sun; opaque columns can extinguish it.

The real production composite is tested over a 50000-linear-value background,
including complete occultation in opaque regions, unclamped clear gaps and
unchanged destination alpha. Substituting the former 0.005 termination fails
that regression on WARP and NVIDIA; the corrected kernel passes. No live draw
capture was used to establish every possible weather-specific draw order, so
runtime visual confirmation remains necessary. Existing HDR/fog, native state,
wind-aware DLSS/FG motion and weather-fade regressions also pass.

### Cloud optical transport and Medium lighting correction

The first paired-sample revision did not fix the user's screenshot. Medium
still estimated skylight optical depth by extending one local density sample
all the way to the nominal layer top. The prior diagnostic used High, which
already took a different lighting path. All qualities now integrate the actual
overhead column: four Gauss samples at Low, six at Medium and above. Sunlight
uses paired samples over ceil(0.75 * light_budget) exponentially spaced intervals.
Noise LOD follows the integration footprint. Density/shape generation is unchanged.

The mild view-only 1.5x opacity adjustment was also insufficient and is superseded.
The visible-cloud model now uses one coefficient for camera, incoming sunlight
and skylight optical depths: beta = 3 LWC / (2 rho_water r_eff) = 0.075 m^-1
at unit procedural density, assuming LWC 0.5 g/m^3 and effective radius 10 um.
These are selected liquid-cloud model parameters, not measured game weather.
The density field scales LWC; no angular sun mask or disc blur is used.
The water-path/optical-depth relation is documented by
[NASA MODIS](https://modis-images.gsfc.nasa.gov/_docs/C005CloudOpticalPropertiesver3.3.pdf).
Direct radiance follows [Beer transmittance](https://www.pbr-book.org/4ed/Volume_Scattering/Transmittance),
while the phase/scattering source provides angularly distributed cloud light.

`clouds/lighting.hlsli` separates direct extinction from diffuse skylight transport.
Visible liquid droplets scatter nearly conservatively; the model uses albedo
0.999, forward HG g=0.85, and the existing 90/10 forward/backward mixture.
See [Kindel et al., 2011](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2010JD015071)
for visible-water absorption and
[Coakley et al., 2000](https://journals.ametsoc.org/view/journals/atsc/57/16/1520-0469_2000_057_2607_trobcm_2.0.co_2.xml)
for droplet scattering asymmetry. Diffuse sky transmission uses the plane-parallel
two-stream Eddington solution, including reflection and absorption. This avoids
either absorbing the diffuse field like a direct beam or leaving it unaffected
inside a conservative thick cloud. Its local-column use remains an approximation;
the directional multiple-scattering octave model is also approximate, not a full
3D radiative-transfer solve. Thin cloud can retain direct solar transmission.

Ground shadows retain their existing separate filtered-map calibration (0.016),
density, sampling and receiver behavior as requested. Ground-shadow bytecode
SHA256 remains `4868D95C68662D760AE810EB6621548A70FD6C08442664D3A893E2185CEAAB59`.
This intentionally preserves that established approximation rather than claiming
one fully coupled physical solution for sky, terrain and weather.

Validation: Clang x64 Release build; WARP/NVIDIA `clouds.cpp`,
`cloud_shadows.cpp` and new `cloud_lighting.cpp` pass. The latter compares GPU
two-stream reflection/transmission against an independent double-precision
hyperbolic formulation and checks energy bounds, vacuum, monotonicity and the
persistence of diffuse illumination after direct-beam extinction. Production
checks cover zero light, HDR, alpha, clear gaps, fog and DLSS/FG motion/history.
The full-resolution comparison against the original 0.016 trace obeys
T_new = T_old^(0.075/0.016), within the propagated FP16 rounding bound at density
0.25/0.5/1/2 (largest observed absolute difference 0.00218).

The Medium sky-only fixture isolates the local-density shortcut at the final
optical parameters: normalized RGB RMSE against a 128-sample overhead reference
drops from 0.1409 to 0.0256 (82%). This isolates skylight, not all lighting error.
The combined sun/sky dense-reference comparison improves much less; sparse
directional sampling and density filtering still limit convergence. Synthetic
images do not establish elimination of every band in the user's gameplay scene.
Evidence/runners: `tmp/witcher3classic-investigation/cloud-lighting-20261101/`.

Final RTX 5090 isolated 3840x2160, 75% sky, step 100%, fog generation off:
Medium Automatic 0.585 ms, Medium Half 1.403 ms, Ultra Half 4.15-4.23 ms.
Higher extinction shortens the expensive lit portion of the view march;
measurements with the game concurrently running are excluded. These are
synthetic timings, not gameplay FPS. The D3D debug layer is unavailable.

Restart and inspect a thin cloud crossing the sun, a thicker cloud hiding the
disc while retaining scattered illumination, shaded undersides, panning and
animation with DLSS/FG, and unchanged world shadows. The final build still
requires live visual acceptance.


### Rebased appearance, FAST lighting samples and HDR history (2026-11-01)

The approved appearance is now the 100% baseline for coverage, density, formation
size, thickness, surface detail and detail size. Physical values are respectively
1, 0.15, 1, 1, 2, 0.5. Base softness defaults to 0%, which retains its literal
zero meaning. UI parsing alone rebases the units; density/shadow physics are not
rescaled again in HLSL. A per-profile `CloudAppearanceBaseline=1` migration divides
saved density/detail/detail-size percentages by 0.15/2/0.5 once, preserving the
previous physical appearance. Missing settings take the new defaults.

Surface Detail supports 0..200% of the new baseline (physical 0..4), and Detail
Size supports 50..400% (physical 0.25..2). These deliberately extend beyond the
old limits so users can increase detail and reduce detail size from the new
100%. The shader's detail-scale floor also changes from 0.5 to 0.25. Default
appearance is unaffected by this extension; the common density field continues
to drive both clouds and their world shadows at any chosen detail scale.

The research, mask provenance, importer, license, sampling dimensions, temporal
filter and limitations are documented in [clouds/sampling.md](clouds/sampling.md).
This supersedes fixed Gauss lighting positions and the previous Medium sample
counts. It uses EA FAST masks for primary/sun/sky sampling, two strata per sun
interval, roughly twice the prior lighting integration budget, and 8/12 overhead samples.
A first attempt at stochastic lighting with the old budget had excessive bright
error; that version was rejected. A first temporal-filter attempt also blurred
moving detail and was rejected before Release.

The final temporal filter preserves linear HDR radiance and uses neighborhood
luminance/variance to distinguish smooth noisy regions from high-contrast detail.
It adds no noise to the finished RGB image. The 0.8..0.9 history weights and 10%
contrast threshold are mod tuning, not universal constants supplied by the papers.
Existing direct Beer extinction, forward scattering, world-shadow integration,
compositing, fog and motion interfaces remain in place.

Validation: strict FXC cs_5_0 compilation; Clang x64 Release; WARP and hardware
cloud, shadow and reconstruction fixtures; explicit UI defaults/ranges/presets.
The reconstruction test uses the actual FAST bytes with gradients at linear
scales 0.001, 1 and 9000. Filtered/input RMS is 0.18563 at all three scales,
with relative mean drift below 0.0001, preserved colour ratios and opacity.
Moving-detail relative RMS remains 0.07613 against the existing 0.08 limit;
camera cuts and constant 9000 HDR are checked separately.

At the requested physical appearance, the 960x540 synthetic Medium fixture
compares 32-frame averages (frames 32..63) against 64 sun + 64 sky samples,
keeping 48 primary steps. Relative luminance RMS changes 0.31372 -> 0.10469
for forward lighting and 0.04011 -> 0.01289 for the opposite sun direction.
The dense reference also narrows density footprints, so this measures combined
lighting integration/filtering error, not an isolated proof about banding.
Stationary full-render temporal RGB RMS increases from 1.05% to 1.89% and
0.37% to 0.59% respectively: stochastic integration trades persistent bias for
small temporal variation. It is not noise-free, and motion/disocclusions still
require live review. Mean-image comparisons alone would hide this tradeoff.

RTX 5090, game closed, isolated 3840x2160, 75% unobscured sky, requested baseline,
step 100%, fog generation off (cloud trace + resolve + composite):

| Quality / resolution | Before | FAST + refined lighting |
| --- | ---: | ---: |
| Medium / Automatic | 1.168 ms | 2.120 ms |
| Medium / Half | 3.798 ms | 6.498 ms |
| Ultra / Half | 11.584-13.458 ms | 22.112-22.456 ms |

These are synthetic GPU times, not gameplay FPS. The lower approved density
requires longer lit rays than earlier unit-density benchmarks. The additional
samples carry a substantial cost at high settings. Asset generation is
reproducible byte-for-byte; the mask uses 512 KiB of immutable GPU storage.
The D3D debug layer was unavailable. Investigation files and comparison runners:
`tmp/witcher3classic-investigation/cloud-dither-20261101/`.

Manual acceptance: restart, confirm rebased percentages; increase surface detail
above 100% and decrease detail size below 100%; inspect shaded cloud gradients,
bright rims, thin/thick sun crossings, slow camera pans and DLSS/FG motion.
World shadows should retain the same behavior at matching physical inputs.

Range-extension audit: shadow shader disassembly differs by exactly one executable
instruction constant, the detail-scale minimum 0.5 -> 0.25. At existing physical
detail sizes >= 0.5 this max operation returns the same value; shadow integration
and receiver calculations are identical. The new smaller-size range intentionally
reshapes the common density field and therefore its matching world shadows.


### Second cloud-shape baseline (2026-11-01)

The first-rebase Surface Detail 200% and Detail Size 80% are now 100%
defaults: physical strength 4 and size 0.4. Base Softness remains 0%.
Surface Detail retains a usable 0..200% range (physical 0..8); Detail Size
supports 50..500% (physical 0.2..2), allowing smaller detail while preserving
the previous largest size. The shader floor matches the new minimum.
Density and other appearance baselines are unchanged.

CloudAppearanceBaseline=2 migrates original and version-1 profiles directly,
without double conversion. Version-1 detail percentages halve and detail-size
percentages multiply by 1.25; density is unchanged. Original percentages use
the original physical units. Already-migrated profiles are left alone. Missing
values use the new defaults. Rebuild the Classic Release addon with the game
closed, then check 100% defaults and adjustment on both sides of the baseline.

Second-rebase verification: explicit cloud preset/startup/range checks pass.
A source-extracted run of the production migration checks original, version-1
and version-2 profiles, missing values, unrelated settings and idempotence.
The production cloud fixture with the newly compiled trace passes on WARP and
hardware, including actual GPU changes above/below the new shape baseline.
Evidence: tmp/witcher3classic-investigation/cloud-rebase2-20261101/.

Second-rebase Release build completed and is reached by the existing game-folder
addon symlink. Post-build production cloud and shadow fixtures pass on WARP and
hardware. Addon SHA256:
`149E89BE90FD5E93C6F4681D7BC0DD144492D994C22F35EAD5F8A2F096C6695A`.
Live visual confirmation of the new baseline remains a gameplay check.


### Third cloud baseline: density (2026-11-01)

Previous Cloud Density 400% is now 100%, with physical density 0.6.
The 0..4 physical range is preserved (new UI range 0..approximately 667%).
The second-rebase cloud shape defaults/ranges remain unchanged.
CloudAppearanceBaseline=3 divides version-1/2 density percentages by four,
preserves version-2 shape percentages, and converts older profiles directly
from their original physical units. Missing values use defaults; version-3
profiles are not converted again. This only rebases UI units and defaults;
cloud lighting, shader density evaluation and shadow algorithms are unchanged.

Third-rebase validation: cloud settings/preset checks and the production migration
fixture pass for original, v1, v2 and v3 profiles, including missing values and
repeated loading. Clang x64 Release build passed. Cloud-trace and ground-shadow
bytecode hashes are unchanged. The game addon matches the build via its existing
link. Addon SHA256: CCB772B1A2B2B41BE47D7997AADD680076E275CAC62AF9D4BFFC7F9AF0A21406.
Evidence: tmp/witcher3classic-investigation/cloud-rebase3-20261101/.


### Fourth cloud baseline: detail size (2026-11-01)

Previous Cloud Detail Size 200% is now 100%, with physical detail size 0.8.
The physical range 0.2..2 remains available through a 25..250% slider, allowing
adjustment below and above the new default. Density, Surface Detail and Base
Softness defaults are unchanged. CloudAppearanceBaseline=4 halves version-3
detail-size percentages while preserving density and surface detail; versions
0..2 migrate directly from their own physical units. Missing settings use the
new default, and version-4 profiles are not converted twice. No shader changes.

Fourth-rebase validation: preset/default/range checks and source-extracted
production migration checks pass for versions 0..4, missing values, custom
settings and repeated loading. Clang x64 Release build passed. Cloud trace
and shadow shader bytecode remain unchanged; the game-folder addon matches
the build. SHA256: 8F879E236A96C00BF0C7213B4DA3B167E5459983E80B351EC369F3908273831D.
Evidence: tmp/witcher3classic-investigation/cloud-rebase4-20261101/.
