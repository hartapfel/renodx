# Cloud structure and evolution, 2026-11-01

## Findings and primary references

Increasing Coverage and Size changes distribution and scale, but cannot add the
missing intermediate structures. The previous shader packed a biased formation
scalar and fine erosion into two channels, applied one height fade after the
coverage threshold, and lit the surface using uneroded secondary samples. These
choices explain both smooth silhouettes and weak relief. The 130% Coverage and
200% Size defaults remain the user's choices; the model changes independently.

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
