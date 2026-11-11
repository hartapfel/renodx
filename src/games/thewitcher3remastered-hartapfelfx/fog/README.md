# Fog and independent volumetric light

Implementation and research, 11 November 2026.

The Fog tab owns the weather veil. The Lighting tab owns light scattered by
the air: sun/moon beams and lamp/fire volumes. Both use the existing native
Raster, RT and PT light adapters, geometry/cloud shadows, native colours,
interior intervals and camera validation. No screen-space radial blur or
additional scene-shadow renderer is introduced.

Private local-volume work runs before deferred surface shader selection. Its
native PSO restoration must never undo the Small Object Shadows/PBR replacement
on the same dispatch. The addon registers `ObserveLocal` before the shader
module; sun observers remain after the native night-light edits. This preserves
the D3D12 distinction between [pipeline state and root/resource bindings](https://learn.microsoft.com/en-us/windows/win32/direct3d12/managing-graphics-pipeline-state-in-direct3d-12).
The lighting integration regression checks this order for both native local
lighting hashes (`E6A77B56`, `9A6F318E`).

## Controls and ownership

Under **Lighting**, world and celestial controls precede these sections;
character fill follows the complete volumetric-light workflow:

| Section / control | New-profile default | Behaviour |
| --- | --- | --- |
| Volumetric Light & Performance / Volumetric Light | On | Independent master; works with Original fog and zero Fog Density. |
| Light Quality | Balanced | Changes light shadow quadrature and the minimum shared grid resolution. |
| Volumetric Light Appearance / Light Density | 100% | Weather density multiplier for scattering and incoming/view-path attenuation. Independent of Fog Density. |
| Sun & Moon Beams | 100% | Directional scattering brightness. Retains the saved `FogSunlight` key. |
| Lamp & Fire Light | 100% | Local scattering brightness. Retains `FogLocalLight`. Zero skips CPU preparation and dispatch. |
| Light Focus | 0.50 | HG asymmetry, 0–0.85. Higher values concentrate light toward its source. Retains `FogAnisotropy`. |
| Volumetric Light Placement (Advanced) / Clear Space | 0 m | Near-camera space without added scattering, 0–100 m. |
| Fade With Height | 100% | Multiplies the current weather's reciprocal height falloff, 0–300%. |
| Indoor Light Density | 100% | Scattering inside authored interior volumes, independent of indoor fog exclusion. |
| Volumetric Light Quality (Advanced) / Lamp & Fire Shadows | On | RT/PT traces world visibility; raster uses native atlas/cube maps. Off can leak through walls. |
| Lamp Occlusion Quality | Low | RT fog samples per contributing cell/light: Low (1), Balanced (2), High (3), Ultra (4). Raster follows native shadow-map quality. Disabled with Lamp & Fire Shadows. |
| Stabilize Light Over Time | On | Off rejects lighting history and uses deterministic current-frame quadrature. |

### Settings order and screenshot defaults

The 11 November 2026 defaults match the user's two screenshots, with their later
override of Lamp Occlusion Quality to Low (one visibility sample). Fog proceeds
through Fog & Performance, Fog Appearance, Fog Placement, Fog Medium (Advanced),
Fog Quality (Advanced), then Diagnostics (Advanced). The medium's physical
density is adjusted before its reconstruction filter. Fog defaults are:

| Control | Default |
| --- | --- |
| Fog Rendering / Quality Preset | Volumetric / Performance |
| Fog Amount / Distant Sky Haze | 35% / 120% |
| Clear Distance / Fade With Height | -10 / 100% |
| Fog Density / Smooth Fog Lighting | 100% / On |

Lighting proceeds through World Lighting & Shadows, Sun & Moon Appearance,
the four existing Volumetric Light sections, then Character Lighting. Inside
appearance, density comes first, the two light-source brightness controls stay
adjacent, and directional Light Focus follows them. Sun Size and its Glow Size
stay adjacent; Moon Size precedes Evening Sunlight Colour. Character Fill Light
is followed by Match the Environment, then Gameplay Brightness and Dialogue &
Cutscene Brightness. This keeps behavior switches before their strength controls.

| Other Lighting controls | Defaults |
| --- | --- |
| Surface Lighting / Sun & Moon Shadows / Small Object Shadows | Improved / Improved / Improved |
| Shadow Softness / Small Shadow Reach | 0.250 degrees / 1.00 m |
| Sun Size / Sun Glow Size / Moon Size / Evening Sunlight Colour | 75% / 125% / 75% / 50% |
| Character Fill Light / Match the Environment | Improved / On |
| Gameplay Brightness / Dialogue & Cutscene Brightness | 0.20 / 0.20 |

The order applies NN/g's [proximity principle](https://www.nngroup.com/articles/gestalt-proximity/)
by keeping related sources and dependent controls together, and
[progressive disclosure](https://www.nngroup.com/articles/progressive-disclosure/)
by retaining the existing Advanced sections and their initial collapsed state.
This is a task-based design judgment using those principles; no formal user
study or usage-frequency measurements are claimed. Labels, sections, saved
keys, tooltips, ranges, tab ownership and rendering algorithms are unchanged.
Existing saved values remain; a fresh preset or that tab's Reset All uses the
new defaults. Preset Off retains native/original values.

Changing Fog Amount, Fog Density, Fog Clear Distance or Fog Fade With Height
does not change the beam medium. Light Density zero removes beams without
removing the weather veil. Volumetric Light Off leaves fog available. Original
fog retains the original opaque/forward/water fog composition while adding
the independent beam radiance. When both renderers are native/off, the original
shader fallback remains active. Preset Off disables both and restores original
effects.

Fog Reset All preserves light settings. Lighting Reset All restores light,
world-light, celestial and character settings; it preserves Fog. Old beam
strength keys are explicitly assigned to Lighting for visibility and reset.
Migration copies missing light enable/density/height/quality values from old
fog settings without replacing existing new keys. Negative old clear distances
map to zero clear space. Strength/focus values keep their existing keys.

## Rendering and storage

Wronski's AC4 volume pipeline is already the core of this mod. The extension
separates coefficients and controls rather than duplicating the grid or
sampling the final displayed scene. Generation evaluates fog extinction and
beam extinction independently at the same cell and applies the same captured
exterior fraction to each. Authored interiors remain vacuum for fog. Light has
an independent indoor-density multiplier, defaulting to 100% to use the outdoor
light density; zero keeps interiors clear of added scattering.

The existing raw/resolved FP16 RGB + extinction cells now describe the beam
medium. A four-byte-per-cell sidecar holds current fog extinction. Integrated
prefix RGB stores beam radiance; prefix alpha stores weather-shaped fog opacity.
The header is 1280 bytes, retaining all existing offsets through byte 1023.
Bytes 1024–1055 capture immutable light controls. Interior data follows the
new sidecar. History retains the header and raw/resolved light cells; fog
extinction is never temporally accumulated.

For each segment of length `ds`, beam integration accumulates
`source * exp(-tau) * (1-exp(-sigma_t*ds))`, then advances optical depth.
Incoming sun/moon and local light still use the existing analytic height-path
attenuation and HG phase. The old nonlinear weather opacity curve affects
the fog veil only. Consequently this new independently integrated beam path
is not expected to reproduce the previous weather-shaped beam brightness.
Forward colour/coverage receivers use a minimum 0.0001 coverage only when
needed to carry additive HDR radiance through the native varying contract.
Water uses the same rule, including at zero fog coverage.

This is an art-directed separation of atmospheric appearance and added light;
it is not a claim that fog and beams are separate substances in nature. A
fully unified physical medium would necessarily couple surface extinction,
fog and scattering. Beam density still follows native weather and becomes zero
when native weather provides no participating medium. Unauthored interiors
cannot be excluded by a missing engine interval.

`ShaderInjectData` remains 64 bytes. `VolumeLightData` occupies c10–c11 in
the existing private CBV, after celestial c4–c9, with a version marker. The 48-byte structure retains that marker at byte 28. Private
generation pages upload those controls at byte 160. Receivers read captured
controls from the volume header. Empty/fallback celestial/water uploads do not
need extra constants. Legacy kernel fixtures without the marker retain the
previous coupled transport for regression comparisons.

## Quality and cost

At 16:9, light quality requests:

| Quality | Columns × rows × slices | Directional shadow taps/cell |
| --- | --- | --- |
| Performance | 120 × 68 × 64 | 2 |
| Balanced | 160 × 90 × 96 | 4 |
| High | 240 × 135 × 128 | 8 |
| Ultra | 256 × 144 × 128 | 16 |

The shared volume meets the higher active fog/light resolution. A high fog
setting can therefore limit the memory/dispatch saving from lowering Light
Quality, but directional shadow quadrature still follows Light Quality alone.
Higher light quality does not rewrite appearance values. Performance uses
linear reconstruction; higher modes use positive-weight cubic RGB filtering.
Fog opacity retains trilinear reconstruction. Fog's Per-Pixel Integration is
active only while Volumetric fog is selected and uses the same independent
transport and bilinearly sampled fog sidecar.

Extra sidecar storage is approximately 2.0/5.3/15.8/18.0 MiB per active field
for these four modes; no second light grid, history grid or pass is allocated.
The mod-local pool cap rises from 768 to 896 MiB so four rotating Ultra fields,
their histories and sidecars fit without exhausting the pool. This is a cap,
not an eager allocation; lower quality allocates smaller fields.
Turning off sun/moon brightness skips directional shadow work. Turning off
local brightness or the light master skips local preparation/dispatch. Temporal
Off is a stability/response tradeoff, not a promised speed improvement.
No gameplay FPS improvement is inferred from voxel/tap budgets.

The [world visibility correction](LOCAL_OCCLUSION.md) adds a fog ray generator
to the native local-shadow and PT/SER pipelines, preserving their material/alpha
hit processing. Camera validation uses the native ray CameraCB, whose layout
differs from deferred SharedPixelConsts. Finite rays preserve the engine's
emitter exclusion distance to avoid tracing into a torch's own housing.
The per-sample local-light pass replaces the screen-depth
supplement; it adds no second persistent volume. Additional ray work depends
on light bounds and Lamp Occlusion Quality. Source bindings match the current
frame/view and expire at reset/present. Missing RT inputs conservatively skip
local injection, with counters in Integration Status. Gameplay acceptance and
GPU timings are separate from the production-kernel tests. The user has
confirmed visible PT local lighting and improvement at the previously bad torch
angle. The 72 GPU cases include world blockers, alpha tests, source/view
selection and emitter endpoint/fallback behavior. Standalone emitter alignment
remains separate and its installed 1.1.1 files were verified by hash.

## Source audit and design decisions

Primary rendering material checked before implementation:

- [Wronski, SIGGRAPH 2014, Volumetric Fog](https://bartwronski.com/wp-content/uploads/2014/08/bwronski_volumetric_fog_siggraph2014.pdf):
  Beer transport, HG scattering, frustum volumes, light injection, integration,
  filtering and forward/deferred reuse. Retain the established shared pipeline.
- [Hillaire, SIGGRAPH 2015, Frostbite volumetric lighting](https://advances.realtimerendering.com/s2015/):
  common media/light representation and physically based transport. Reuse the
  existing homogeneous-segment integration rather than additive density steps.
- [PBRT 4e, transmittance](https://pbr-book.org/4ed/Volume_Scattering/Transmittance)
  and [phase functions](https://pbr-book.org/4ed/Volume_Scattering/Phase_Functions):
  exponential, multiplicative transmittance, vacuum identity and normalized HG.
  PBRT's away/away vector convention differs from our camera-ray/to-light
  convention; the existing HG cosine sign is retained.
- [Epic volumetric fog documentation](https://dev.epicgames.com/documentation/unreal-engine/volumetric-fog?application_version=4.27):
  density, directional distribution and per-light intensity controls; volume
  resolution cost; local shadow cost; temporal trails; translucent receivers.
  These justify quality budgets, explicit local-shadow cost and temporal choice.
  Epic's published timings are not measurements of this addon.

Alternative production approaches were also checked:

- [Intel/Yusov, Outdoor Light Scattering Sample Update](https://www.intel.com/content/dam/develop/external/us/en/documents/outdoor-light-scattering-update.pdf)
  uses epipolar refinement and precomputed atmospheric scattering. It addresses
  outdoor directional light and documents nonlinear LUT/horizon artifacts.
  Our integration choice is to retain the existing volume supporting both
  directional and local lights plus receiver-specific transparent depths;
  replacing it with an outdoor atmosphere renderer would expand this task.
- [NVIDIA Volumetric Lighting](https://developer.nvidia.com/volumetriclighting)
  uses shadow-map-extruded volumes and supports directional/omni/spot lights.
  Its published SDK is a legacy DX11 dependency. We retain the mod's proven
  DX12 volume and native shadow adapters; no SDK or external dependency is added.
- Wronski's comparison of radial-blur shafts notes the loss of rays when the
  source leaves the screen. Retaining world-space shadow evaluation avoids that
  limitation. A separate full-resolution shadow ray march would duplicate
  lighting work already amortized across the shared grid; no claim of measured
  superiority over those alternate implementations is made.

User-centred design references:

- [NN/g, progressive disclosure](https://www.nngroup.com/articles/progressive-disclosure/):
  master, quality and appearance are visible; specialised placement/temporal
  controls use the established single collapsed Advanced level.
- [NN/g, usability heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/)
  and [recognition rather than recall](https://www.nngroup.com/articles/recognition-and-recall/):
  familiar effect names, percentage/metre units, contextual hover help, a
  predictable master and scoped reset. Preserve existing tabs and numbered
  profiles instead of adding a competing preset system.

These sources inform the implementation and design rationale. No formal user
study has been performed on this menu.

## Verification

Build with `build-release.ps1`, using the established `clang-x64-release`
target `thewitcher3remastered-hartapfelfx`. Its output is
`build/Release/renodx-thewitcher3remastered-hartapfelfx.addon64`.
The user controls all game launches and closures.

Production-kernel GPU tests cover independent fog multipliers, light master
off, zero beam medium, clear space, PS/CS agreement, local/overflow light
adapters, native shadowing and analytic homogeneous transport. Indoor light
at 0%/100% is checked independently of exact indoor fog vacuum. Existing
interior/temporal/HDR tests remain required. Real ImGui tests cover master
enabling and reset ownership; actual-addon tests cover migration and Preset Off.
Validation completed on 11 November 2026:

- Strict DXC compilation and the complete Release regression script pass,
  including 1,152 production PS/CS transport cases, 282 interior cases and
  28 HDR receiver/per-pixel modes, plus the existing temporal, water, lifetime,
  descriptor and native-light checks.
- Real ImGui ownership/master/reset tests and the actual-addon migration,
  pool-budget, standalone coexistence and Preset Off test pass. The reset test
  now follows the user's authored 90% Cloud Shadow Strength default.
- All 387 cloud GPU cases and the native celestial/native-air captures pass.
- Twelve isolated startup runs pass with the installed HDR addon: four on the
  Windows system runtime and eight on the game's Agility SDK 619. Each run
  exercises 24 frames through 96 delayed split recordings, native Raster/RT
  local-light observers and rotating Raster/RT/PT sun consumers. Both addon
  load orders pass, including Original fog with independent light at Performance
  and Ultra. No driver access violations are observed.
- The tested 6,027,264-byte Release candidate was copied to the established
  `build/Release/renodx-thewitcher3remastered-hartapfelfx.addon64`; its SHA-256
  matches the tested file. The existing game-folder symlink targets this path.
  The installed HDR addon and game setup were preserved.

Build/test logs and the previous installed artifact are retained under
`tmp/volumetric-light-20261111`. The production-kernel host reports that the
D3D12 debug layer is unavailable. These are offline rendering, binding and
lifetime checks. Gameplay visual acceptance and GPU frame-time measurements
remain pending; no game was started or stopped by the agent.

In-game acceptance: compare the same sunlit forest/doorway, moonlit exterior,
lamp/fire scene, water and mist particles with Raster/RT/PT. Exercise Original
fog, Fog Density zero, both masters, light quality/placement/density extremes,
temporal/shadow toggles, photo-mode views, weather/time transitions, DLSS/FG
and preset changes. Inspect shadow stepping, light leaks and history trails.
