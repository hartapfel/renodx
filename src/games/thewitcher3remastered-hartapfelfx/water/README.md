# Water rendering

Open the **Water** tab. **Improved Water** enables the surface optics,
underwater fog and caustics together. **Water Murk** controls transport through
water on either side of the interface. It defaults to 150% and ranges from
0% to 200%. At 0% the replacement still runs with no added extinction.
Both values are saved per preset. **Reset All** on Water restores the toggle
to Off and Murk to 150%. Preset Off disables the replacement. When upgrading
an older preset, either enabled surface optics or positive Murk activates
the new switch and its saved Murk value is retained.

## Native pipeline evidence

Archived DevKit records `water15-draw1765.json` and `water15-draw1782.json` in
`tmp/witcher3remastered-graphics-port-20261102` show a surface draw followed by
the underwater composite. Both write RGBA16F scene targets. The surface's first
output is the underwater pass's `t0` input, and the surface's pre-water depth
copy at `t15` becomes underwater `t3`. Original DXIL supplies the depth
remap and input/output signatures. The separate Remastered attempt supplied
native evidence and examples of black submerged objects and poor frame times.

| Native stage | Inputs and output |
| --- | --- |
| `C60F2B46` surface with VS `81EAA494` | Native mesh, animated normals, foam, position and eye depth, `t6` HDR scene, `t15` opaque depth, `t5` dynamic wave texture, `b0` regional colours and directional light, `b13[1]` light radiance, native geometry/cloud visibility. Writes surface RGB in Target 0 and the filtered optical normal in Target 1's existing XY encoding. Alpha and material classification retain native behavior. |
| `ECE2CD5B` underwater with VS `D684B585` | `t0` scene, `t2` RG16F coverage/transition, `t3` opaque depth, `t15` scene depth with the surface, `b0` native medium, time and directional light, `b12` current view. Dry pixels preserve original RGBA. Covered pixels retain native zero-alpha semantics. |
| Native directional light `4A7A44D6`, `806C62A8`, `D2C88922` | The established fog observer admits a scene-depth view, frame and light constants and four shadow cascades. The water capture reads the native cascades in their producing draw's layout, with terrain and cloud inputs when available. |

The live follow-up in `tmp/hartapfelfx-water-stability` traced the PT frame
through `806C62A8` lighting, `C60F2B46` surface, `CE3B36EC` coverage,
`ECE2CD5B` underwater transport, `FE6240E2` copies, downstream compute and
post-processing, and `88D3FA12` presentation. The underwater pass's RGBA16F
output is the first copy's unmodified input. At a stationary downward camera,
median scene-linear luminance went from 0.151 before the underwater pass to
0.614 at that copy, with the bright veil already visible. The water material
reported direct-light RGB values around 71–76. The coverage mask was fully
wet and water depth was closer than opaque depth at 2.12% of pixels, all at
forward depths beyond 52 world units. The mask shader's two channels encode
coverage and a narrow surface transition. At this depth they saturate to
`(1, 0)`, so the compositor cannot recover water elevation from them.

The follow-up live DevKit capture at the reported submerged spot is under
`tmp/hartapfelfx-waterline`. Its 1920×1080 coverage mask is `(1,0)` across the
frame. Current depth is nearer than opaque depth on 12.39% of pixels, tracing
the rasterized water mesh. The dark ripple pattern already exists in the
composite's `t0`. The surface's `t6` holds continuous HDR sky. Reconstructing
the projection from captured native `b1` places three water samples 6.44–6.52
world units above the camera. The previous single height probe's 40-unit ray
limit excluded them.

The surface and submerged shaders read the game's colour and material rows
on every draw. Coefficients are tuned for the game's scene units, with spectral
ratios shaped by the regional tint. The shaders retain the game's authored wave
motion, displaced geometry and downstream reflection integration.

## Two-sided interface

The former improved colour mixed water-body tint into every pixel as Fresnel
increased. This gave the water a bright, opaque base at grazing angles, on top
of the game's own reflection contribution. The new surface path applies
`1 − F` to both transmitted scene colour and scattering below the interface.
It shades sparse native foam as separate coverage and replaces the legacy sun
glint with GGX, height-correlated Smith visibility and dielectric Fresnel.
Normal variance across the pixel quad broadens the direct lobe where fine
ripples become undersampled. The game's separate reflection term receives the
same filtered XY slopes through its native normal encoding and retains its
reflection masks and intensity channel.

The camera height relative to the displaced fragment selects the incident
medium. From above, refraction starts with the aligned lit scene and opaque
depth. The old fallback sampled an already-warped native location, which
could retain a displaced dark receiver even after the new probe rejected it.
Refraction fades to zero in the first 0.10 world units of vertical depth and
ramps up through 0.75. The displaced sample must remain below the interface
and match the local depth. The shader mixes the aligned and displaced
radiance after integrating each path's own water column. Broad slopes drive
surface transmission and the native reflection strength and displacement.
Finer waves still steer the filtered direct glint.

From below, the surface samples the pre-water HDR scene through the native
wave offset and a small projected offset from the filtered optical normal.
The candidate must be behind the interface and on the air side, or be a
far-plane sky sample. Bad hits and viewport edges converge to the aligned
scene coordinate. At grazing camera angles this broad screen-space view
preserves the outside scenery Witcher exposes during ordinary swimming.
The reflected share ranges from 12% to 36% for a well-separated exterior
hit, varying with slope and angle. These weights are an artistic
approximation for this game. A flat interface with a strict critical angle
had hidden the exterior at the same camera angles where the native game
showed it.

As the camera aims up, the reciprocal dielectric projection gradually takes
over. It projects the sky direction at infinity and can refine a nearby
object at its sampled depth. Broad slopes filter the 48.6° critical
transition. The shader blends the two **coordinates**, validates the result,
and samples the exterior once. Blending two colour samples gave duplicate
shorelines when the projections disagreed. A three-depth reflection probe
adds submerged terrain where available. Exterior objects outside the
pre-water image remain a screen-space limitation. [Epic Pixel Normal Offset](https://dev.epicgames.com/documentation/en-us/unreal-engine/refraction-using-pixel-normal-offset?application_version=4.27), [Crytek screen-space refraction](https://developer.nvidia.com/gpugems/gpugems2/part-ii-shading-lighting-and-shadows/chapter-19-generic-refraction-simulation), [PBRT dielectric BSDF](https://pbr-book.org/4ed/Reflection_Models/Dielectric_BSDF)

A 0.02–0.15 world-unit blend near the interface joins the native and improved
surface paths as the camera crosses it. With Murk active, the underwater
composite owns the camera-to-interface water segment. The surface pass
gradually removes its camera-side atmospheric veil in that case. Atmospheric
colour already in the refracted air-side scene remains visible. The composite
applies fog to submerged geometry without adding a second screen distortion.
Both sides use the same RGB extinction and regional source colour. A ray
from above integrates its surface-to-receiver segment. Underwater, the
camera-to-opaque segment starts at the eye, including the space immediately
around Geralt. At 100% the density ranges from 0.1265 to 0.23 per world unit
according to the native region. In the captured dock material, three units of
water transmit about 53% of the least-attenuated channel. Native surface
optics receive an extra transport term on the body before native foam and
atmosphere.

### Wave and ripple motion

The improved optical normal combines the game's large-wave and wake/detail
inputs with world-space travelling wave slopes. Three gravity bands use
wavelength-dependent dispersion and two short bands include surface tension.
The waves use native animation time. A pixel-footprint filter reduces each
band as it becomes unresolved and transfers the remaining high-frequency
variation to glint roughness. Refraction, the native reflection input and the
projected caustic lenses use the same gravity-wave phases. The native displaced
mesh, tessellation, flow and interactions continue to determine the actual
surface position and geometry.

### Native water interactions

The game's **Options > Video > Graphics > Water Quality** setting controls
`Rendering.UseDynamicWaterSimulation`. The installed Remastered graphics
matrix enables it at High, Ultra and Ultra+, and disables it at Low and
Medium. The game creates water displacements through its dynamic simulation.
REDkit exposes `useInWaterDisplacement` for dynamic colliders. [CD Projekt Red REDkit](https://cdprojektred.atlassian.net/wiki/spaces/W3REDkit/pages/38142289/HOW-TO%3A%2BAdd%2Bmoving%2Bentities)

The surface reads the engine's local simulation at `t1`. The captured
resource was a 1024 × 1024 RGBA16F texture over a 30-unit region centred
by `b4[4].xy`. The native shader decodes its XY channels and the
distance- and visibility-weighted ZW channels into the local normal
`_515.._517`. Before this change, the improved normal folded the disturbance
into the same distance-filtered mix as ambient waves. A smooth weight
derived from the decoded local XY now preserves the native normal where an
interaction is active. Refraction and the existing reflection output use
more of that slope locally. Thin-water refraction admits active wakes
through the same foreground and depth checks, and rejected samples use a
stable reference column.

The installed game scripts select the effects at the source. `swimming.ws`
plays water-entry and surfacing splash effects at the water level.
`aardEntity.ws` traces toward the water and selects the water-specific Aard
effect when it hits. `petard.ws` handles Water collisions, impact splashes
and water-specific bomb effects. The shader consumes the resulting native
field for any event that writes to it. Gameplay triggers and particle
effects remain engine-owned.

DevKit captures in `tmp/hartapfelfx-water-interactions` include a quiet
baseline and a mixed run of swimming, jumping, Aard and bombs. The peak
length of the XY field increased from about 0.0013 at idle to 0.33 during
the mixed run. Separate event captures still contained motion and lingering
waves, so they do not identify every impulse by source. A D3D12 normal replay
using two captured active fields measured roughly five times the previous
mean horizontal refraction slope in strongly disturbed pixels. Calm
pixels agreed to within one half-float rounding step. This replay tests
surface response to the native field.

## Shadowed underwater fog

The composite linearizes the two depths and ends the segment at the nearest
opaque surface or water interface. It converts forward depth to view-ray
distance using the native perspective and rotates the ray with the current
camera basis. RGB Beer–Lambert extinction acts on scene radiance. Regional
water colour contributes a low ambient source, while directional illumination
uses the native light colour and actual shadow visibility at points in the
water. The shader refracts the light direction at entry, attenuates the
incoming path and integrates five near-weighted segments with front-to-back
transmittance and a forward Henyey–Greenstein phase function. The phase uses
`g = 0.35`. A bounded response to native light RGB supplies hue and relative
strength, scaled by the regional scattering colour. The deferred BRDF's HDR
light units previously drove the volume directly and could wash out most of
the view. This lets light through
openings brighten the murk while a shadow can remove the direct contribution
even when the background colour is unchanged.

The capture uses the existing fog PS/CS grid pipeline in a water-only mode.
It writes a 24 × 24 × 16 world-space visibility field around the current view
at two world units per cell, plus light direction, HDR radiance and matching
camera/projection/jitter metadata. Each field is about 36 KiB. It uses native
cascaded comparison filtering and the existing terrain and cloud visibility
functions. The consumer uses trilinear visibility and fades the direct term
at the field boundary. Uploads and fields travel through existing GPU recording
retirement. The fullscreen pass binds an owned buffer or a zero header, so it
can render with regional ambient when a matching capture is unavailable.
Water lighting works independently of the atmospheric fog toggle.

The six fixed screen probes and their inferred plane were removed. A valid
rasterized exit shortens the water column. At long range, the exit depth
smoothly converges toward the opaque depth as extinction hides the mesh edge.
Shadow visibility is evaluated at the world-space scattering point regardless
of camera pitch. For the incoming light attenuation, the submerged compositor
uses a camera-relative depth reference with a 0.75-unit bias. It is a stable
approximation when the actual offscreen water height is unavailable. The
two-unit lighting cells soften small shadow details. Local lights, authored
offscreen water heights and offscreen reflection detail still require
additional native bindings.

## Caustics and fringe

The previous lens estimate depended on the dynamic wave texture being usable
at each receiver and, underwater, on a matched lighting field. The replacement
uses the same three moving gravity waves as the optical surface. It projects
their small-slope Snell mapping onto visible submerged geometry. The analytic
height Hessian gives the local area change and compression concentrates the
light. A bounded determinant response limits bright peaks. Separate refraction
angles project red, green and blue from slightly different positions, giving a
small fringe that grows with depth and collapses at normal incidence.

Caustics follow native light direction, time and scene colour. They use captured
visibility when present and fade with incoming attenuation, depth and distance.
If the shadow field is missing, a conservative fallback modulates only the
already-lit receiver. Above water, the effect falls back to validated opaque
depth if the displaced refraction probe fails. The underwater path excludes
the raster exit and fades out as the opaque receiver approaches the local
water reference. This is a
bounded single-interface projection for visible receivers. It uses no extra
water textures or photon dispatches.

## Production research

- Ubisoft and AMD's **Far Cry 5** water composite uses depth with and without
  water, separates indirect reflection from direct lighting and material
  transport, and layers foam, refraction and caustics. Epic's **Single Layer
  Water** also uses lit scene colour/depth with a separate reflection
  composite. These are close matches for Witcher's existing buffers. [Far Cry 5 GDC slides](https://media.gdcvault.com/gdc2018/presentations/Grujic_Branislav_WaterRenderingFarCry5.pdf), [Unreal Engine Single Layer Water](https://dev.epicgames.com/documentation/unreal-engine/single-layer-water-shading-model-in-unreal-engine)
- Studio Wildcard's **Atlas** talk treats water lighting and subpixel wave
  roughness explicitly. Bruneton, Neyret and Holzschuch describe transferring
  unresolved wave detail into the reflection lobe. HartapfelFX uses an
  inexpensive derivative-based roughness filter while retaining Witcher's
  geometry and normal maps. PBRT supplies the dielectric equations for both
  interface directions. [Atlas GDC slides](https://gpuopen.com/gdc-presentations/2019/gdc-2019-agtd6-interactive-water-simulation-in-atlas.pdf), [Real-time Realistic Ocean Lighting](https://morpho.inrialpes.fr/Publications/2010/BNH10/article.pdf), [PBRT dielectric BSDF](https://pbr-book.org/4ed/Reflection_Models/Dielectric_BSDF)
- Frostbite and Ubisoft's **Assassin's Creed IV: Black Flag** separate
  volumetric incident lighting from integration along the view ray. The
  same separation allows Witcher to provide shadow visibility from a native
  lighting pass and lets the underwater shader integrate only the submerged
  portion with its own extinction. The Lightspeed **Photon Water System**
  demonstrates the broader production use of an underwater volumetric pass
  with water-height information. [Frostbite SIGGRAPH course](https://advances.realtimerendering.com/s2015/), [Black Flag volumetric fog slides](https://advances.realtimerendering.com/s2014/wronski/bwronski_volumetric_fog_siggraph2014.pdf), [Photon GDC slides](https://media.gdcvault.com/gdc2023/Slides/Open-World%2BWater%2BRendering%2Band%2BReal-Time%2BSimulation_Mao_Zhenyu%26Wu_Kui.pdf)
- Guardado and Sánchez-Crespo's **GPU Gems** chapter derives water caustics
  from refracted sunlight concentrating on receivers and discusses cheaper
  projected methods. NVIDIA's real-time DXR caustics provide an example of
  full photon projection. The bounded Jacobian estimate uses the native
  waves and avoids the additional geometry and ray work of that pipeline.
  Measured dispersion constrains the RGB offset. [GPU Gems caustics](https://developer.nvidia.com/gpugems/gpugems/part-i-natural-effects/chapter-2-rendering-water-caustics), [NVIDIA DXR caustics](https://developer.nvidia.com/blog/?p=22657), [Measured visible-band indices](https://opg.optica.org/ao/abstract.cfm?uri=ao-47-10-1504)
- GPU Gems documents foreground leaks from displaced screen samples. The
  water probes check depth and interface side before contributing. PBRT's
  homogeneous Beer term supplies transmittance. Akkaynak and Treibitz show
  that real direct attenuation and backscatter can have distinct effective
  spectra, so the current regional RGB model is a game-scale approximation.
  [GPU Gems 2 refraction](https://developer.nvidia.com/gpugems/gpugems2/part-ii-shading-lighting-and-shadows/chapter-19-generic-refraction-simulation), [PBRT transmittance](https://pbr-book.org/4ed/Volume_Scattering/Transmittance), [CVPR underwater image formation](https://openaccess.thecvf.com/content_cvpr_2018/html/Akkaynak_A_Revised_Underwater_CVPR_2018_paper.html)

- Finch's real-time water implementation separates displaced geometry and
  optical ripple detail. Bruneton and colleagues filter the wave spectrum as
  waves become subpixel. The short-band phase speeds use deep-water
  gravity–capillary dispersion. Valve's Portal 2 work is a production example
  of retaining authored flow while animating optical normals. [GPU Gems wave simulation](https://developer.nvidia.com/gpugems/gpugems/part-i-natural-effects/chapter-1-effective-water-simulation-physical-models), [MIT wave dispersion](https://thales.mit.edu/bush/wp-content/uploads/2024/03/Lec-8-Waves.pdf), [Valve water flow](https://advances.realtimerendering.com/s2010/Vlachos-Waterflow%28SIGGRAPH%202010%20Advanced%20RealTime%20Rendering%20Course%29.pdf)
- Unity HDRP demonstrates explicit camera-side classification, an underwater
  surface boundary and underwater caustic projection. The Witcher adapter
  uses the native depth pair to infer the shared local boundary because it
  has no access to HDRP-style authored water volume bounds. [Unity HDRP water system](https://unity.com/blog/engine-platform/new-hdrp-water-system-in-2022-lts-and-2023-1)

## Verification

The matched live Native and Improved captures in
`tmp/hartapfelfx-water-exterior` held the same 23.6° camera and 100% Murk.
The pre-water upper-third median was 2.78 scene-linear in both captures.
Improved's median dropped to 0.11 at the surface output, then 0.10 after
the underwater composite. Native's corresponding medians were 0.92 and
0.45. This isolates the missing exterior to the previous surface blend.
The composite still applies Beer–Lambert attenuation and regional,
shadowed in-scattering over the distance to the rasterized interface.
There is no sky exemption from the Murk slider.

The revised surface and the existing underwater composite were replayed
together at 100% Murk using live colour and depth at 2.4°, 23.6°, and 29.3°
of camera pitch. The fixture substitutes procedural slopes and a synthetic
lit visibility field. The sky, dock, and tree line remain readable in the
shallow view, with visible ripple distortion and a fog fade toward the
waterline. At 2.4° the median for upper water pixels rose from 0.072 to
0.428 after fog. The revised surface produced 1.588 for those pixels before
fog. Both revisions produce identical results on rays with no
rasterized water exit in the fixture. See `submerged-angle-comparison.png`
in the capture directory.

After installing the Release candidate through the existing game link, a
second live capture confirmed Improved and 100% Murk at 8.9° camera pitch.
The native mask was fully submerged. The upper-third median was 3.80 at
the surface output and 1.65 after the underwater composite. The final
HDR-chain input preserved the sun and wave-distorted tree line, with a
continuous fog fade toward the shore and riverbed. The live trace and
`installed-hdr.png` are in the same capture directory.

The dock follow-up in `tmp/hartapfelfx-water-cohesion` includes the bank,
near-level submerged and upward submerged views prepared in game. The bank's
pre-water colour shows the uninterrupted sand, and the early post-water copy
shows dark ripple bands on the shallows. The near-level capture's camera
pitch was 2.4° above horizontal. At that angle, a 60° vertical field of view
can see very little of the Snell window, which starts about 41.4° above the
horizon for flat water. At 20.2° upward pitch, the directional replay places
the sky and distorted tree line in the upper part of the water surface,
with visible underwater reflections beyond it.

The isolated D3D12 surface replay uses the captured scene colour, depth and
camera plus procedural slopes. It excludes native foam, later reflection
passes and temporal processing. In the bank replay, changing the slider
from 0% to 100% changed 578,848 wet pixels by more than 0.01 in a
scene-linear channel. Dry replay pixels were bit-identical. The fog-only
replay compares the two composites using identical live inputs and a
synthetic lit visibility field. At 100%, the median luminance of opaque
near-level dock receivers with forward depths from 2 to 6 world units fell
from 1.68 to 0.94, including the range around Geralt. All replay colours
were finite.

Build `thewitcher3remastered-hartapfelfx` with `clang-x64-release`. Inspect
`0xC60F2B46.cso`, `0xECE2CD5B.cso`, `0xF7F00002.cso` and
`0xF7F00003.cso`. The Release GPU fixture checks the native cascade boundary
in both capture stages, RGB extinction, Fresnel on both sides, focusing and
dispersion. The isolated startup host checks the native shader pairs with
both HDR load orders. Include `0xD684B585.vs_6_3.cso` and
`0xECE2CD5B.ps_6_6.cso` in its native fixture, and set `-WaterMurk 150` to
exercise the producer alongside the atmospheric fog runtime.

The follow-up fixture replays the captured colour, coverage and depth
textures and native camera constants on D3D12. A synthetic matched visibility
field uses the captured material's sun direction and RGB. The old composite
changed 2,072,613 of 2,073,600 pixels by more than 0.01 in at least one
scene-linear channel when only the fixed probe locations were changed.
The revised composite changed 16 pixels, all inside the edited depth
patches. Median scene-linear luminance fell from 0.704 to 0.117 in the
fully lit replay, and a partial shadow field reduced it to 0.094. Output
was finite across the frame. The source colour already contains the previous
surface shader. This fixture verifies the composite, while the strict build
and Fresnel fixture exercise the revised interface code. The capture, replay
and Release candidate are under `tmp/hartapfelfx-water-stability`.

The final strict shader and Release GPU suite passed, including the 9,216-cell
shadow field in both producer stages, positive caustic focusing, spectral
separation, unresolved-ripple rejection and total internal reflection. The
isolated ReShade host passed both HDR addon orders at 100% Murk.

In game, compare shallow clear water, a murky region and open water at the
same camera and exposure. Check low views above water, submerged views
looking straight up and obliquely through the Snell window, and moving
shoreline and boat silhouettes. Swim from direct light into the shadow of a
bridge or rock while looking at the same background. Compare caustics on a
shallow floor, under that shadow, and at depth. Change Murk while submerged
and capture fixed-resolution GPU times in Raster, RT and PT. Live appearance,
capture admission and GPU frame time remain to be verified.
