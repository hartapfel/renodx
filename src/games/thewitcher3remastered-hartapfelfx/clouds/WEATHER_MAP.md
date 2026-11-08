# Native cloud weather and motion map

8 November update: cloud wind uses 0.35x vanilla, superseding earlier 0.5x references.

Audited 7 November 2026 against the running GOG DX12 game and its installed
bundles. This is a control/resource map, not visual acceptance of every quest.
The read-only bundle audit covered 64 bundles, 14 weather CSV paths and 15
content variants. The duplicated Toussaint table is byte-identical. The
installed `modtruerain` contains a Prologue override; its seven valid records
retain the native wind, blend duration and shadow-layer selections. Trailing
NUL padding is not a weather state. Runtime mod enablement/load priority is
not inferred from bundle presence alone. Reference/default/legacy tables below are
listed separately; their presence does not establish that a current world uses them.

## Runtime controls

| Native input | Meaning and use |
| --- | --- |
| Weather CSV `windScale` | Engine weather wind strength, including zero. The addon does not substitute a weather-name-based speed or a minimum wind. |
| Weather CSV `blendTime` | Native transition duration in seconds, normally 120, 45 in templates, with scripted zero-duration exceptions. The addon retains the evaluated native blend. |
| CSV `fakeShadow` | Native weather texture-array layer, **not** a unique cloud species or weather name. Different regions map the same weather name to different layers. |
| CSV `skybox`, `backgroundThunder` | Native sky selection and background lightning; broad sky/lighting colors remain engine-controlled. |
| CSV `envPath`, `envBlend` | Optional environment override and its strength. They are distinct from the cloud-layer blend; empty overrides still have cloud effects. |
| CSV `probability`, `occurenceTime` | Engine weather selection and duration. Not a cloud animation clock. |
| Numbered effect fields | Separate authored cloud/rain/snow/lightning particles, priorities, probabilities and strengths. Main-view painted cloud cards are suppressed only after successful volumetric rendering; rain/snow and local mist retain their own paths. |
| Frame b12[66].x | Native weather spatial scale. Broad period = `2000 * scale` world metres (10 km at scale 5). Independent of user Cloud Size. |
| Frame b12[66].w | Evaluated source-to-target weather weight. Applied before the shared weather fade. |
| Frame b12[67].xy | Integrated signed native weather wind offset, not directly metres of broad-layer motion. Native broad world offset = `20 * native_offset`; the user-requested 35% cloud speed uses `7 * native_offset`. Same conversion in weather, billows, shadows, directional visibility and motion/history reprojection. |
| Frame b12[68].xy | Native source/target layer IDs. Clamped to the available array; the authored tables use 0–4. Never infer weather identity, speed or rainfall from this pair. |
| Native b0[0].x | Retained native animation clock. Drives the existing slow billow evolution and delta-time fades. Paused time does not advance fading. |
| Native b12[204].yzw | Solar direction used by the native sky lobe. Canonical daytime cloud-light/terrain-shadow projection. |
| Native b12[38].xyz | Atmospheric attenuation direction, not the solar-position authority. Used as fallback only when solar input is missing. |
| Native b13 light constants | Authored light radiance and native dominant-light fallback (including moonlight). |

The original deferred `0x806C62A8` DXIL has two weather projections:

```text
near_uv = (world_xy + native_offset) * .01 / scale
broad_uv = (world_xy + 20 * native_offset) * .01 / (20 * scale)
         = (world_xy + 20 * native_offset) * .0005 / scale
```

The mod uses the **broad** spatial period with a user-requested **0.35 speed
multiplier**: `(world_xy + 7 * native_offset) * .0005 / scale`. The old `1.2 * native_offset` kept its
10 km period but slowed its advection by 20/1.2. `20` is a native coordinate
conversion, with no additional speed boost. A native offset decreasing in X
moves cloud features toward positive world X, as required by the sampling sign.
The live storm capture measured -0.60001 offset units/s over 120 frames and
1.9934 seconds: approximately +12 m/s in the native broad projection, or +6 m/s
with the current 35%-speed setting. Later bounded
samples remained at that slope. Previous notes calling these offset units
metres, or using b12[66].z as a generally valid elapsed-time clock, are superseded.
This is a broad cloud-wind signal; local foliage/cloth gust vectors are not
proven to be the same signal and are not substituted for it.

## Transition behavior

The RG32F weather field stores resolved coverage in R and the current atlas's
storm-envelope weight in G. Native source/target textures are blended first;
both results then follow the existing 0.8-second, delta-time exponential fade.
Previously, histories stored source/target slots and were reinterpreted when
those IDs changed. That could abruptly change coverage even at a continuous
native handoff. Native ID changes also discarded image history unnecessarily.
The new layout preserves channel meaning through completed and interrupted
transitions; depth, opacity, radiance, camera and settings checks still reject
invalid image history. All consumers sample the same filtered weather field.

The existing 16-layer height atlas has two distinct envelopes: layer 4 and the
ordinary envelope shared by the other slots. Its filtered weight prevents an
instant height change when the native layer IDs change. This does not classify
all weather species; e.g. Toussaint storm uses layer 3, and Kaer Morhen storm
uses layer 0. No invented storm-speed or storm-density multiplier is added.

The fade resets on an invalid clock, large time discontinuity, invalid native
scale or settings revision. World changes/cold history initialize from current
native inputs. Existing wind-origin discontinuity handling and current-frame
shadow validity remain active. This is not a promise to interpolate arbitrary
teleports between worlds.

## Installed weather tables

Wind is the authored dimensionless scale, not an assumed m/s speed. Environment
paths are reduced to their filenames here; the game retains the full resource
paths. An em dash means no explicit environment override. Tables with the legacy
schema use `windParamsScale` and have no `fakeShadow`/`blendTime` fields.

### `engine/environments/weather_prolog.csv` — installed True Rain override

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Clear` | 0.01 | 120 | 0 | false | env_prolog_colors_v1_b_sunset_clear.env |
| `WT_Rain_Storm` | 0.6 | 120 | 4 | true | env_novigrad_storm.env |
| `WT_Light_Rain` | 0.17 | 120 | 4 | false | env_prolog_colors_cinematic_tonemapping.env |
| `WT_Light_Clouds` | 0.06 | 120 | 1 | false | — |
| `WT_Mid_Clouds` | 0.1 | 120 | 2 | false | — |
| `WT_Heavy_Clouds` | 0.15 | 120 | 3 | false | env_prolog_colors_cinematic_tonemapping.env |
| `WT_Grey_Sky` | 0.4 | 120 | 3 | false | env_grey_sky.env |

### `dlc/bob/data/fx/environment/weather/weather_bob.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Clear` | 0.3 | 120 | 1 | false | — |
| `WT_Rain_Storm` | 1.0 | 120 | 3 | true | rain_tm.env |
| `WT_Light_Clouds` | 0.3 | 120 | 1 | false | — |
| `WT_Mid_Clouds` | 0.3 | 120 | 1 | false | — |
| `WT_Fog` | 0.2 | 120 | 2 | false | fog_tm.env |
| `WT_Heavy_Distant` | 0.5 | 120 | 1 | false | — |
| `WT_Snow` | 0.6 | 120 | 3 | false | env_winter_skellige.env |
| `q704_Cloud` | 0.5 | 120 | 2 | false | — |
| `q704_Detlaff_arena` | 0.7 | 120 | 3 | false | q704_detlaff_arena_prod_room.env |
| `q704_main` | 0.3 | 120 | 3 | false | q704_main.env |
| `q704_Cloud_Rain` | 0.5 | 120 | 2 | false | 704_cloud.env |
| `q704_Cloud_Sunny` | 0.5 | 120 | 2 | false | 704_cloud_sunny.env |

### `engine/environments/weather_island_of_mist.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Heavy_Clouds` | 0.0 | 120 | 3 | false | — |

### `engine/environments/weather_kaer_morhen.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Clear` | 0.01 | 120 | 0 | false | — |
| `WT_Rain_Storm` | 0.6 | 120 | 0 | true | env_novigrad_storm.env |
| `WT_Light_Clouds` | 0.08 | 120 | 1 | false | — |
| `WT_Mid_Clouds` | 0.15 | 120 | 2 | false | — |
| `WT_Vesemir_burial_hour_3_30` | 0.3 | 120 | 2 | false | env_kaer_morhen_vesemir_v0_hour_3_30.env |
| `WT_Heavy_Clouds` | 0.3 | 120 | 3 | false | — |
| `WT_Heavy_Clouds_Dark` | 0.4 | 120 | 4 | false | — |
| `WT_Blizzard` | 0.6 | 120 | 4 | false | env_winter_epilog_white_grass.env |
| `WT_Battle` | 0.5 | 120 | 3 | false | kaer_morhen_battle_preview_01.env |
| `WT_Battle_Forest` | 0.5 | 120 | 3 | false | kaer_morhen_battle.env |

### `engine/environments/weather_novigrad.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Clear` | 0.2 | 120 | 0 | false | — |
| `WT_Rain_Storm` | 1.0 | 120 | 4 | true | env_novigrad_dark_clouds_heavy_rain_color.env |
| `WT_Light_Clouds` | 0.3 | 120 | 1 | false | — |
| `WT_Mid_Clouds` | 0.5 | 120 | 2 | false | — |
| `WT_Mid_Clouds_Dark` | 0.7 | 120 | 3 | false | env_novigrad_dark_clouds.env |
| `WT_Heavy_Clouds` | 0.9 | 120 | 3 | false | — |
| `WT_Heavy_Clouds_Dark` | 0.8 | 120 | 4 | false | env_novigrad_dark_clouds_heavy.env |
| `WT_Grey_Sky` | 0.6 | 120 | 3 | false | env_novigrad_grey_sky.env |
| `WT_Snow` | 0.3 | 120 | 3 | false | env_winter_skellige.env |
| `WT_q604_Snow` | 0.6 | 120 | 3 | false | env_winter_skellige.env |
| `WT_q605_Hell` | 0.7 | 120 | 3 | false | — |

### `engine/environments/weather_prolog.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Clear` | 0.01 | 120 | 0 | false | env_prolog_colors_v1_b_sunset_clear.env |
| `WT_Rain_Storm` | 0.6 | 120 | 4 | true | env_novigrad_storm.env |
| `WT_Light_Rain` | 0.17 | 120 | 4 | false | env_prolog_colors_cinematic_tonemapping.env |
| `WT_Light_Clouds` | 0.06 | 120 | 1 | false | — |
| `WT_Mid_Clouds` | 0.1 | 120 | 2 | false | — |
| `WT_Heavy_Clouds` | 0.15 | 120 | 3 | false | env_prolog_colors_cinematic_tonemapping.env |
| `WT_Grey_Sky` | 0.4 | 120 | 3 | false | env_grey_sky.env |

### `engine/environments/weather_skellige.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Rain_Storm` | 1.0 | 120 | 4 | true | env_skellige_rain_storm.env |
| `WT_Mid_Clouds_Dark` | 0.15 | 120 | 3 | false | env_skellige_brown_dark_clouds.env |
| `WT_Mid_Clouds_Fog` | 0.5 | 120 | 3 | false | env_winter_skellige.env |
| `WT_Mid_Clouds` | 0.7 | 120 | 2 | false | — |
| `WT_Heavy_Clouds` | 0.9 | 120 | 3 | false | — |
| `WT_Blizzard` | 0.7 | 120 | 1 | false | env_winter_epilog_white_grass.env |
| `WT_Wild_Hunt` | 0.6 | 120 | 1 | false | env_winter_epilog_white_grass.env |
| `WT_Heavy_Clouds_Dark` | 0.4 | 120 | 3 | false | env_skellige_dark_clouds.env |
| `WT_q501_Blizzard` | 0 | 0 | 4 | false | env_winter_epilog_white_grass.env |
| `WT_q501_Storm` | 0 | 0 | 4 | true | env_skellige_rain_storm_arena.env |
| `WT_Clear` | 0.15 | 120 | 2 | false | — |
| `WT_q501_Blizzard2` | 0 | 0 | 3 | false | env_skellige_dark_clouds.env |
| `WT_lessun_forest` | 0.6 | 120 | 3 | false | env_skellige_leshy_forest_v3.env |
| `WT_q501_fight_ship_18_00` | 0.1 | 120 | 3 | false | env_fight_ship.env |
| `WT_q501_storm_arena` | 1.0 | 0 | 4 | true | env_skellige_rain_storm_arena.env |

### `engine/environments/weather_template_spiral.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `Spiral_Eternal_Cold` | 0.5 | 45 | 0 | false | env_spiral_snow_hour_6_22.env |
| `Spiral_Aen_Elle` | 0.2 | 45 | 1 | false | env_elven_city_4_11.env |
| `Spiral_Desert` | 0.25 | 45 | 0 | false | env_desert_clear.env |
| `Spiral_Dark_Valley` | 0.3 | 45 | 3 | false | env_spiral_dark_valley.env |
| `Clear` | 0.01 | 45 | 1 | false | — |

### `engine/environments/weather_winter_epilog.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Heavy_Clouds` | 0.2 | 120 | 3 | false | — |
| `WT_Mid_Clouds` | 0.1 | 120 | 2 | false | — |

### `engine/environments/weather_wyzima.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Mid_Clouds` | 0.1 | 120 | 2 | false | — |

### `engine/reference_level/environment/weather/weather_level2.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Rain_Storm` | 1.0 | 120 | 4 | true | env_skellige_rain_storm.env |
| `WT_Mid_Clouds_Dark` | 0.1 | 120 | 3 | false | env_skellige_brown_dark_clouds.env |
| `WT_Mid_Clouds_Fog` | 0.6 | 120 | 3 | false | env_winter_skellige.env |
| `WT_Mid_Clouds` | 0.75 | 120 | 3 | false | — |
| `WT_Heavy_Clouds` | 0.7 | 120 | 3 | false | — |
| `WT_Blizzard` | 0.9 | 120 | 1 | false | env_winter_epilog_white_grass.env |
| `WT_Wild_Hunt` | 0.9 | 120 | 1 | false | env_winter_epilog_white_grass.env |
| `WT_Heavy_Clouds_Dark` | 1.0 | 120 | 3 | false | env_skellige_dark_clouds.env |
| `WT_q501_Blizzard` | 0 | 0 | 4 | false | env_winter_epilog_white_grass.env |
| `WT_q501_Storm` | 0 | 0 | 4 | true | env_skellige_rain_storm_arena.env |
| `WT_Clear` | 0 | 120 | 2 | false | — |
| `WT_q501_Blizzard2` | 0 | 0 | 3 | false | env_skellige_dark_clouds.env |
| `WT_lessun_forest` | 1 | 120 | 3 | false | env_skellige_leshy_forest_v3.env |
| `WT_q501_fight_ship_18_00` | 0.1 | 120 | 3 | false | env_fight_ship.env |
| `WT_q501_storm_arena` | 1.0 | 0 | 4 | true | env_skellige_rain_storm_arena.env |

### `engine/environments/default_weather_template.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Clear` | 0.01 | 45 | 0 | false | — |
| `WT_Light_Clouds` | 0.06 | 45 | 0 | false | — |
| `WT_Mid_Clouds` | 0.1 | 45 | 0 | false | — |
| `WT_Heavy_Clouds` | 0.15 | 45 | 0 | false | — |
| `WT_Light_Rain` | 0.17 | 45 | 0 | false | env_novigrad_0_storm_1.env |
| `WT_Light_Snow` | 0.3 | 45 | 0 | false | — |
| `WT_Blizzard` | 0.6 | 45 | 0 | false | — |
| `WT_Rain_Storm` | 0.6 | 45 | 0 | true | env_novigrad_0_storm_1.env |

### `engine/environments/weather_island_mist.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Heavy_Clouds` | 0.0 | 120 | 3 | — | — |

### `engine/reference_level/environment/weather/weather_level.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Clear` | 0 | 120 | 0 | false | — |
| `WT_Rain_Storm` | 1.0 | 120 | 0 | true | env_novigrad_storm.env |
| `WT_Light_Clouds` | 0.3 | 120 | 1 | false | — |
| `WT_Mid_Clouds` | 0.7 | 120 | 2 | false | — |
| `WT_Vesemir_burial_hour_3_30` | 0.6 | 120 | 2 | false | env_kaer_morhen_vesemir_v0_hour_3_30.env |
| `WT_Heavy_Clouds` | 0.8 | 120 | 3 | false | — |
| `WT_Heavy_Clouds_Dark` | 0.8 | 120 | 4 | false | — |
| `WT_Blizzard` | 0.95 | 120 | 4 | false | env_winter_epilog_white_grass.env |
| `WT_Battle` | 0.95 | 120 | 3 | false | kaer_morhen_battle_preview_01.env |
| `WT_Battle_Forest` | 1.0 | 120 | 3 | false | kaer_morhen_battle.env |

### `levels/novigrad/weather_template_novigrad_v1.csv`

| State | Wind | Blend s | Layer | Thunder | Environment override |
| --- | ---: | ---: | ---: | --- | --- |
| `WT_Clear` | 0.1 | — | — | — | — |
| `WT_Warm_Mid_Clouds` | 0.3 | — | — | — | — |
| `WT_Warm_Hi_Clouds` | 0.55 | — | — | — | — |
| `WT_Cold_Mid_Clouds` | 0.3 | — | — | — | — |
| `WT_Cold_Hi_Clouds` | 0.55 | — | — | — | — |
| `WT_Rain_Storm` | 1.0 | — | — | — | env_skellige_global_storm.env |

## Verification and remaining live check

Build `thewitcher3remastered-hartapfelfx` using the existing Clang Release wrapper.
While the game runs, `build-release.ps1 -CompileOnly` checks shaders and the C++
object without replacing the loaded addon. Generated cloud binaries are
`build/thewitcher3remastered-hartapfelfx.include/embed/0xF7C*.cso`.
The GPU suite exercises all 25 authored layer pairs, blend ramps, ID rollover,
interruption, pause, calm wind, graphics/compute parity and signed world-space
shadow translation. Offline fixtures do not prove every quest's appearance.

The user alone closes, rebuilds and relaunches the game. After rebuilding, check
storm motion in a fixed camera view, a calm/light-cloud state, a natural 120-second
weather transition and an interrupted transition. View, terrain shadows and
sunlight must travel together; cloud size and quality must not change speed.
Check Raster, RT and PT, with Native mode as the authored weather reference.

7 November validation: strict Release shader/C++ checks and 125 production cloud
GPU cases passed, including the 25 authored layer pairs and HDR sun/moon replays.
The isolated addon passed all four HDR-order/fog-quality startup combinations
with native DXR, RTGI and PT probes. The normal Release target was built after
the user's game exited; its game-folder symlink hashes identically, and the
final Release addon passed the same four startup combinations. Live visual
acceptance of motion and weather transitions remains pending.

## Cloud-family appearance catalog

`family_effects.json` maps 27 recognized native cloud-effect filenames to mixtures
of cumulus, flatter decks, broad thin sheets, altocumulus and cirrus. The offline
`tools/generate_cloud_families.py <installed-cloud-weather.json>` emits
`families.hpp`: 16 recipes including the legacy fallback, 56 regional weather
entries and 30 weather names. It includes the six main/winter worlds' mapped
quest states. Unknown names or unsupported worlds use recipe zero. Local fog,
rain, snow, lightning and other non-sky effects retain their existing paths.

These are appearance approximations inferred from the selected authored effects;
the numeric recipe strengths/heights are not claimed to be native physical
parameters. Optional effects contribute their expected probability-weighted
appearance. The addon does not discover the engine's random per-emitter choices,
read bundles at runtime, copy original textures or add a particle/resource tracker.
Installed overrides require an offline catalog update if they change known cloud
combinations. Wind uses 35% of the native broad-layer speed described above;
no family contains a speed or direction override.

The native area and actual source/target weather CNames choose recipes even when
their fakeShadow IDs coincide, and independently of envBlend or night-normalization
toggles. One present-thread snapshot feeds the existing parameter page. GPU
publication fades the complete family vectors on native time in the existing
history pass. The main volume forms billows or a flatter deck. The added
middle-sheet/altocumulus and high-cirrus sheets were removed at the user's request.
Their authored weights remain in the evidence catalog but are zero in generated
GPU recipes. Weather containing only those effects now produces clear sky and
has no synthetic sheet shadows. No high-sheet atlas or lookup remains.
