# The Witcher 3 - Remastered: Darker Nights

Standalone night, gameplay, cutscene lighting and moon-size controls for The Witcher 3
Remastered's DX12 renderer. Works with the game's SDR or native HDR output,
rasterized lighting, ray tracing and path tracing. The addon contains only
lighting/grading overrides and the RenoDX settings/shader infrastructure; it does not
require the full HDR addon, PsychoV, or Artificial Player Lights.

This is the optional lighting addon for the
[The Witcher 3 - Remastered HDR mod](../thewitcher3remastered/README.md).
Both sources belong to the same game in this repository, with separate builds
and releases. The in-game tab remains **Darker Nights - Remastered** and saved
profiles retain their `renodx-darkernights-remastered` configuration namespace.

## Installation

1. Install ReShade with full addon support for `witcher3.exe` in the DX12 binary
   folder (`bin/x64_dx12`).
2. Remove Artificial Player Lights. An HDR addon without these lighting overrides
   can remain installed. If your HDR addon already implements these native
   lighting hooks, use one implementation to avoid applying them twice.
3. Extract the release ZIP into the game installation folder, merging `bin`.
   The addon goes in `bin/x64_dx12/tw3-darkernights-remastered.addon64` beside
   `witcher3.exe`. Remove older `renodx-darkernights-remastered.addon64` or
   `renodx-thewitcher3remastered-darkernights.addon64` copies to
   avoid loading two copies. Restart and keep your native SDR/HDR display settings.
4. Open ReShade's Add-ons page and expand **Darker Nights - Remastered**.

The ZIP follows the game-root layout. Systemcluster's The Witcher 3 Mod Manager
[installer](https://github.com/Systemcluster/The-Witcher-3-Mod-manager/blob/Custom/src/core/installer.py)
does not copy native addon DLLs from archives, so this ZIP requires manual
extraction. It does not belong in `Mods` and needs no Script Merger step.

The native hooks validate the x64 executable's image bounds, renderer instruction
signatures and lighting data before installation. Different timestamps or image
sizes are accepted when the required layout matches. Incompatible layouts keep
native lighting and show unavailable controls. Camera and grading hooks are
validated independently so a missing optional hook does not disable core lighting.

The October 8 game update moves the native renderer functions and skylight
variable. Both the previous and updated address layouts are supported, with
the same instruction and data checks. Camera call targets are decoded rather
than tied to one build's relative displacement; night grading uses the matching
upload return addresses. The directional-light buffer pointer moves from
renderer offset `0x690` to `0x698`, and its native load instruction is checked
before hooking. No per-frame scanning is added.

The updated Path Tracing Photo Mode capture retains the existing moon,
cloud and Photo Mode grading shader hashes. The new executable passes all native
hook checks, including camera lighting, grading and moon padding. Raster/RT and
HairWorks shader variants still need an in-game check after rebuilding.

Rain and blizzard cloud material `0x683213A3` also blends in vertex fog colour.
Cloud Brightness now scales that material after the blend, so its weather glow
cannot remain bright at zero. This affects the cloud draw only; general scene
fog, cloud coverage and precipitation are unchanged. Native strength and Off
retain the original material output. Both weather captures use this shader;
the user confirmed the rebuilt cloud fix works.

Rain streak material `0x04251B31` has a separate Rain Brightness control.
Its additive RGB is scaled after shading; native opacity, weather simulation,
wetness and the second render target are preserved. Replacement is restricted
to the two captured rain vertex variants (`0x5653D7C9`, `0xDE079650`).
The isolated live test marked the falling streaks magenta, then removed them
at zero brightness without changing the scene or moon.

Skylight also scales the engine's evaluated `VanilaSkyWaterImpactMultiplier`
and `WaterReflectionSkyMultiplier`, using the same night schedule. Their native
weather and Photo Mode overrides remain intact. This adjusts the sky contribution
along with the water material's separate distance-blended sky fill (`b0 c14.x`),
without multiplying traced scene reflections, refraction or the final water output.

## Controls

Enable Night Lighting activates the environmental sliders. Turning it off
restores native environmental lighting and grading while preserving your slider values.
The four 24-hour times define a smooth fade in, a full-strength interval and a
smooth fade out; schedules can cross midnight. Invalid schedules keep native
environmental lighting until the times are valid.

The UI groups presets under **Night Lighting**, fade times under **Night Schedule**,
environmental light under **Night Illumination**, fog/sky/clouds under **Night
Atmosphere**, and grading under **Night Colour Grading**. **Camera Lighting** and
**Sky Appearance** contain the independent camera and moon controls. Instructions,
credits and donation buttons are under **Help & About** and **Community & Support**.

**Normalize Regional Lighting** is On by default. It balances the ordinary
outdoor night baselines of Novigrad/Velen, Skellige, Kaer Morhen, White Orchard,
winter White Orchard and Toussaint before applying your sliders. Off retains
the previous regional baselines. The choice is saved in each profile, and both
night preset buttons enable normalization.

Calibration uses the median clear-night authored values across the five main
outdoor regions, with correction gains bounded to 0.25–4. Each region keeps the
same regional correction through weather and local environment blends. Weather
normalization below can additionally balance the weather relationship; colour,
fog density and cloud coverage remain native. This balances lighting
parameters; it does not force every camera view to the same measured brightness.
Local/camera lights, moon brightness and native exposure remain separate. Vizima,
Isle of Mists, spiral/quest worlds and unknown modded worlds retain their authored
baselines. Daytime, the night master Off and Preset Off remove normalization.

The region comes from the validated native map manager, read once per present.
Renderer workers use a static calibration table. There are no asset scans,
descriptor tracking or GPU readbacks. An unsupported region-identification
layout disables only normalization and preserves the existing night controls.
The factors apply to fresh direct light, probe scales, visible sky, fog/haze and
cloud terms. PT sky radiance is normalized at its sky source; its impact multiplier
and reflected sky are not normalized again. Native tone mapping and exposure
response are not changed by this control.

**Normalize Weather Lighting** is a separate toggle, On by default and saved per
profile. Both night preset buttons enable it. It covers 40 ordinary region/weather
combinations in the installed outdoor tables: clear, light/mid/heavy/dark clouds,
grey skies, rain/storm, fog, snow and blizzard. Each weather's reference is the
median authored night relationship to clear weather across regions that provide
that state. Storm direct light and visible sky retain a reference at or below
clear weather; snow bounce and fog brightness keep their weather relationships.
States unique to one region retain their authored relationship rather than
inventing a reference. Quest, unknown and mod-added weather retain their native
weather relationship; the regional toggle still operates independently.

The native weather manager supplies both transition endpoints, remaining time,
duration and each endpoint's environment blend strength. Normalization follows
that transition and partial/zero environment overrides, using a ratio of blended
baselines rather than interpolating endpoint gains. The combined correction stays
bounded to 0.25–4 and applies before the user intensities and night fade. Missing
authored curves keep their native relationship. It uses the same direct, probe,
sky, fog/haze and cloud consumers as regional normalization, without additionally
scaling rain, moon, camera lights, real-light water reflections, grading or exposure.

Weather state is read once per present with guarded reads; renderer workers use
immutable calibration tables and one lock-free selection. No asset scans, resource
tracking, readbacks or extra GPU pass is added. A mismatched weather layout disables
only weather normalization. Turning both normalization toggles Off restores the
previous native baselines. In-game comparison of storms, snow and weather transitions
is still required; parameter calibration cannot guarantee identical screen brightness.

Light intensity sliders use **0 = off, 50 = baseline, 100 = double**. With
both normalization toggles Off, that baseline is native. Grading and
moon controls use the ranges described below:

| Control | Changes |
|---|---|
| Normalize Regional Lighting | On balances regional outdoor night baselines; Off preserves native regional differences. Weather differences remain. |
| Normalize Weather Lighting | On balances each weather's regional night relationship; Off retains its native relationship. Weather types remain distinct. |
| Skylight | Environmental illumination, outdoor probe fill and sky lighting/reflections on water. |
| Direct Light | Directional environment lighting, including grass. |
| Directional Fog | Directional/custom fog brightness, preserving density. |
| Aerial Haze | Aerial and distance-fog brightness, preserving extinction. |
| Sky Brightness | Visible sky and horizon glow, preserving moon/stars. |
| Moon Brightness | Moon disk radiance only; follows the night schedule. 0 off, 50 native, 100 double. |
| Cloud Brightness | Cloud and cloud/smoke volume brightness, preserving coverage. |
| Rain Brightness | Falling rain streak brightness; weather intensity and wetness stay native. |
| Water Lighting | Water color and ambient/diffuse fill, preserving reflected scene light/refraction/foam. |
| Brightness & Contrast | Night grade luminance curve; 0 removes it, 100 keeps native. |
| Tint & Saturation | Night grade colour filter; 0 removes it, 100 keeps native. |
| Vegetation Saturation | Green/cyan scene saturation, with gentler yellow/blue coverage; 100 is native, 0 reduces it. Matching non-foliage colours also respond. |
| Vegetation Tint Correction | Warms the same selected night hues while preserving brightness and relative chroma. 0 is off; 100 is the full correction. |
| Gameplay Camera Light | Player-following fill light throughout the day and night. |
| Cutscene Camera Light | Artificial scene and dialogue camera fill, independent of the night schedule. |
| Moon Size | Visible moon diameter from 1% to 500%; 100% is native, 50% halves it. |
| Sun Size | Visible sun diameter from 1% to 500%; 100% is native. Active at every hour. |
| Daytime Fog Intensity | Daytime atmospheric density everywhere: 0% off, 100% native, 200% double. |
| Nighttime Fog Intensity | Atmospheric density during full-darkness hours; smoothly blends with daytime density using Night Schedule. |
| Outdoor Fog Start Distance | Fog fade-in distance outside buildings and in caves; default 7 m. |
| Indoor Fog Start Distance | Fog fade-in distance in buildings; default 40 m. |
| Apply Exposure Overrides All Day | On (default) applies exposure settings at every hour. Off follows the night schedule. Requires Enable Night Lighting. |
| Auto Exposure | Enabled uses adaptation; Off uses a fixed luminance reference during the selected exposure period. Enabled is the default. |
| Adaptation | Native, Smoothed (default), or Custom. Smoothed uses 35% brightening and 5% darkening speed, with both limits at 100%. |
| Brightening / Darkening Speed | Custom only; 1-200% of each native speed, default 35% brightening and 5% darkening. 100% retains that direction's native response. |
| Maximum Brightening | Custom only; 0-100% of native brightening beyond the 0.18 metering reference, default 100%. 0 prevents lift beyond that reference; 100 retains the native range. |
| Maximum Darkening | Custom only; 0-100% of native darkening beyond the 0.18 metering reference, default 100%. 0 prevents further darkening beyond that reference; 100 retains the native range. |
| Fixed Luminance | Off only; 0.001-10, default 0.18. Lower values brighten the image; higher values darken it. |

**Daytime Fog Intensity**, **Nighttime Fog Intensity**, **Outdoor Fog Start Distance**
and **Indoor Fog Start Distance** work independently of Enable Night Lighting.
Both intensities default to 100% native and affect buildings, outdoors and caves.
Night Schedule blends between the two intensities during its evening and morning
fades; full-darkness hours use nighttime intensity, and other hours use daytime
intensity. Invalid schedules use daytime intensity. Equal values retain the old
global behavior; setting both to 0 disables native atmospheric fog at all hours.
Clouds, smoke and particles remain separate. The distance defaults are 7 m outdoors and
40 m inside buildings, each adjustable from 0 to 500 m. Caves, crypts and other
recognized underground profiles use the outdoor distance. A distance of 0
preserves the native fade for that state.

The committed camera-state detector supplies the indoor blend: native enclosure,
weather sheltering for unclassified rooms, and priority-weighted environment
profiles distinguish buildings from caves. Known regional city and swamp areas
may overlap buildings without vetoing their detection. Existing balcony,
upstairs and quest-room handling is retained. Coverage depends on authored
states/profiles; unknown local atmospheres fall back to the outdoor distance.

The captured global-only Novigrad sunset room uses the same weather profile
inside and outside, with weather visibility fixed at 1. Its exact profile now
allows the native enclosure blend to select the indoor distance without a local
area handle. The captured street returns to outdoor distance. Cave flags and
higher-priority underground/unknown local atmospheres still exclude their
contribution; other global weather profiles retain their existing shelter check.

An installed-asset audit covered 753 distinct environment profiles (base game,
expansions and installed mods). Explicit room variants include the q106 tower,
White Orchard, Novigrad, Kaer Morhen and Hearts of Stone; mine atmospheres and
Vizima's outdoor variants remain excluded. All profiles passed native outdoor
and cave-state guard checks. This is static coverage, not an in-game visit to
every location: ambiguous local profiles still need a captured enclosure state
before they can safely be treated as buildings.

Entering or leaving a building smoothly blends the effective distance-fade
parameters in both directions (about 1.5 seconds to reach 95% after a full state
change). Reversing at a doorway preserves a continuous transition; world changes
and Preset Off reset it. Native-zero endpoints blend continuously as well. Equal
distances bypass the detector. Unsupported detection uses the outdoor distance
everywhere and disables the indoor slider.

A nonzero distance is a minimum: later authored starts and wider native fades
are preserved. The fade spans at least the selected distance (minimum 10 m).
For example, 40 m normally fades in from 40 to 80 m. This controls fog for the
whole camera view, including the view through windows, without a spatial cutout.
Preset Off restores both intensities to 100% and both distances to 0 m. Soft/Dark Nights
leave these independent controls alone. Saved FogAmount values remain daytime
settings and seed FogAmountNight when it has no saved value, preserving each
profile's previous global intensity. An existing nighttime value is retained.
FogStartDistance remains outdoors; IndoorFogStartDistance defaults to 40 m.
Obsolete indoor/cave intensity values are ignored.

The existing common-constants hook modifies density (b12 c43.x/c44.x) and the
native start/reciprocal width (c48.yz). Renderer workers read coherent atomic
endpoint pairs and blend intensity with each view's current game clock;
game/profile reads and building-transition updates stay on Present. The
native fog shader remains unchanged, with no added GPU pass, mask filtering,
root binding, descriptor tracking or resource. Cloud, smoke, particles and other
effects with their own fog logic remain separate.

**Night Exposure** follows Enable Night Lighting and the same clock fades.
Apply Exposure Overrides All Day bypasses the schedule for exposure alone,
including adaptation speeds, limits and Fixed Luminance. Lighting and grading
retain their night schedule. The toggle defaults On and is saved per preset.
Native leaves exposure unchanged. Smoothed slows the native response, retaining
both native exposure ranges; Custom exposes the two
directional speeds and both limits.
The rate adjustment retains the engine's frame-time compensation. The game's
forced instant adaptation/reset events remain native.

Maximum Darkening limits the upper metering luminance in both exposure states,
including during environment transitions. The percentage scales the permitted
darkening in exposure stops relative to a 0.18 luminance reference. It leaves
automatic brightening below that reference unchanged, follows the clock fades,
and does not multiply scene RGB or clip highlights. The native lower metering
bound is reduced only when necessary to respect the darkening ceiling. Off uses
Fixed Luminance instead; Native and the night master Off restore the original
bounds exactly.

Maximum Brightening adjusts the lower metering limit independently. Its
percentage scales brightening in exposure stops relative to the same 0.18
reference, using the shader's native 0.0001 metering floor when the authored
minimum is zero or negative. Its default of 100% preserves the normal view.
Both limits at 0% converge to the 0.18 reference at full night strength; both
at 100% preserve the native metering bounds exactly. Speed remains independent
of range, and Auto Exposure Off continues to use Fixed Luminance. The shared
reference remains 0.18; a brightening limit controls scene lift, while the
darkening limit controls exposure reductions when looking at a bright sky.

With Auto Exposure Off, the first and second native metering limits converge
to Fixed Luminance, removing dependence on measured scene brightness at full
night strength, or at all hours with All Day enabled. Otherwise daylight and
clock fades retain or gradually restore automatic exposure.
Lighting, weather transitions and artistic exposure parameters can
still change the image. This is a fixed metering reference, not a frozen frame
or a fixed display luminance in nits.

The controls reuse the validated native constant-upload hook. Off keeps the
normal dynamic tone-map shader and live adaptation history; no fixed-shader
substitution, tone-map override, new bindings, readbacks, descriptor tracking
or extra GPU pass is added. This preserves the HDR addon's existing shader
routing and bloom exposure references. A foreign addon that ignores native
metering parameters can bypass this control. Preset Off and the night master Off
always restore native exposure. Daytime and invalid schedules restore native
exposure unless All Day is enabled.
Values are saved per preset; both night buttons set exposure to Enabled + Smoothed
and turns All Day on.

Torches, ordinary local lights and the separate interior camera-light group retain
their native behavior. Both camera sliders work independently of Enable Night
Lighting and the night schedule. Their defaults are 50; set either to 0 to disable
its camera fill without a separate mod. Preset Off restores environmental and camera
lighting. Presets are stored under `renodx-darkernights-remastered`, separately
from the HDR addon.
The top-level Off / Preset #1 / #2 / #3 selection is also restored on the next
launch. Missing or invalid saved selections start on Preset #1.

**Moon Brightness** is in Night Atmosphere and follows Enable Night Lighting and
its clock fades. It covers the regular and Toussaint moon materials, preserving
size, texture, phase, fog and directional moonlight. Soft Nights uses brightness
35 and Dark Nights uses 15; 50 is native. It shares the existing moon marker in native constants
and introduces no additional shader binding.

**Moon Size** is in the Sky Appearance section and works independently of Enable Night
Lighting and its clock schedule. It scales the moon mesh while preserving its
texture and phase; it does not change the directional moonlight strength. It is
saved with each preset, defaults to 50%, and returns to native size with Preset
Off. Soft Nights sets moon size to 50%; Dark Nights sets it to 30%.

Moon Size also covers Toussaint's alternate moon mesh in gameplay and Photo Mode.
Both regional variants retain their authored texture and phase shading.

**Sun Size** sits alongside Moon Size and also works independently of night
lighting and its schedule. It scales both the sun mesh and the procedural glow's angular width,
preserving its position, peak radiance, moon appearance and directional lighting.
The glow scale uses the native falloff exponent (`b12 c204.x / scale²`),
so the percentage is an approximation for the soft glow. The mesh scales around
its native bounding-box center using a tagged size in zeroed `b12 c206.w` padding.
It defaults to 100%,
is saved per preset, and restores the native size with Preset Off. The two night
preset buttons leave it unchanged. No additional shader bindings are required.

To verify, compare Sun Size at 50%, 100%, 200% and 500% in gameplay and Photo
Mode, including dawn/noon/dusk. Disable night lighting to confirm it remains
active; select Preset Off to restore the original sun. Check that Moon Size and
scene light directions remain independent. Live DevKit testing in Toussaint
confirmed the glow shrinks, and an isolated DevKit test at 1% confirmed the
separate mesh shrinks as well. The mesh replacement is restricted to vertex
shader `0xE1C4426E` paired with sun pixel shader `0xE46451D5`.

**Soft Nights** is the standalone default: night lighting enabled; fade in
18:00 to 23:00, fade out 03:30 to 06:00; skylight, direct light, fog, haze,
sky, clouds and rain 15; water 0; moon brightness 35 and moon size 50%; both
grading controls 100; vegetation saturation 75 and tint correction 100.
**Dark Nights** keeps the same schedule and grading, with skylight, direct light,
haze and sky 5; fog, clouds and rain 1; moon brightness 15, moon size 30% and
vegetation saturation 50.
Both buttons explicitly assign their recipes, enable Night Lighting and both
normalization options, and set exposure to Enabled + Smoothed with All Day on,
speeds 35/5, limits 100/100 and fixed luminance 0.18. They leave camera lighting,
Sun Size and the all-day fog controls unchanged. Existing saved settings are preserved; use Soft Nights
or Reset All Settings to adopt the defaults. Setting keys are unchanged by the UI
regrouping, so saved profiles remain compatible.

The standalone changes freshly uploaded native analytic grading parameters in
`b3`: the luminance control scales curve/output levels and the neutral brightness
of tint coefficients; chroma scales tint and saturation. The schedule fades each
control back to native strength in daytime. Gamma encoding, vignette parameters,
LUT bindings and the selected tone mapper are preserved. The game or another HDR
addon performs the rendering; no grading shader replacement is registered.
An HDR addon that bypasses the game's analytic grade also bypasses these controls.
Native display and tone mapping remain in use unless another addon changes them.

Night Vegetation Saturation uses a smooth OKLCh hue selection
(full green/cyan, weaker yellow/blue, neutral colours excluded). It follows
the master toggle and clock fades and works independently of the grading sliders.
**Vegetation Tint Correction** adds an independent warm hue adjustment using
the same original-colour selection. Full strength rotates the selected hues
up to 25 degrees toward warmer yellow/green, retaining linear luminance and
relative OKLab chroma (C/L), within half-float rounding. It does not add a complementary
RGB colour, which would desaturate, or reconstruct an exact inverse of the
game's grade. Matching non-foliage colours also respond. Vegetation saturation
defaults to 75 for Soft Nights and 50 for Dark Nights; tint correction defaults
to 100 for both.
They are saved per preset; Off restores saturation 100 and tint correction 0. Set
Vegetation Saturation to 100 to use tint correction without desaturation.
Without an HDR grading replacement, the hue arc is shortened if needed to stay
within native presentation's nonnegative RGB transport, retaining colour strength
instead of clipping channels. The audited HDR route keeps its signed wide-gamut
transport and leaves display-gamut mapping to the HDR tonemapper.

The standalone applies it to the audited signed gamma-2.2 BT.709 scene output of
the seven native post-grade variants, before UI composition and the selected
output tonemapper. The HDR addon has no separate selective saturation control; this standalone
pass supplies it when the addons are used together.

HDR grading replacements are recognized from their DXIL scene interface at
pipeline creation, rather than a list of compiled shader hashes. The matcher
requires the audited fullscreen input/output signatures, native b3, the RenoDX
b13/space50 binding, and the exact scene/sampler/vignette texture bindings.
Bloom, LUT, UI and output passes with other bindings are excluded. The result
is cached per pipeline; no compiler/reflection DLL or per-frame shader parsing
is needed. Gameplay, Toussaint and Photo Mode are covered in either addon load
order. Ordinary HDR recompilation and tuning changes retain compatibility as
long as this interface and the signed gamma-2.2 BT.709 transport remain intact.
A changed output encoding or binding contract still needs a fresh audit.

One GPU texture-to-buffer copy, root-UAV compute pass and copy back handles both
controls when either night adjustment is nonzero. At saturation 100 and tint 0,
during daytime or with the master Off, no extra GPU work is recorded. The helper
uses six constant DWORDs, including tint strength and the cached output contract;
native and HDR root layouts are unchanged. Native scene alpha bits are preserved. Brightness
is preserved within half-float rounding; saturation increases use a soft RGB
black-boundary limit, leaving highlight mapping to the downstream tonemapper.
The pass never replaces another addon's grading/output shader, changes its
root signature or switches descriptor heaps. It captures compute root values
for restoration, without descriptor heap update/copy tracking, GPU readbacks
or CPU waits. Scratch is recycled across completed command recordings (see GPU scratch lifetime). This pass adds a
small GPU cost when active; live frame-time validation remains necessary.

## Build and verification

Close Witcher 3 and double-click `build-release.cmd` to rebuild just this addon.
It sets up the installed Visual Studio C++ tools and Clang automatically, uses
the Release preset, and keeps the result visible. The scripts must remain in
this repository. For a PowerShell invocation from the repository root:

```powershell
./src/games/thewitcher3remastered-darkernights/build-release.ps1
```

From an x64 Visual Studio developer shell with Clang on PATH:

```powershell
cmake --preset clang-x64
cmake --build --preset clang-x64-release --target thewitcher3remastered-darkernights
```

Output: `build/Release/renodx-thewitcher3remastered-darkernights.addon64`.

## Release packaging

Double-click `package-release.cmd` to package the existing Release build. The
wrapper keeps the result visible and accepts the same arguments as the PowerShell
script. To rebuild before packaging, run:

```powershell
./src/games/thewitcher3remastered-darkernights/package-release.ps1 -Build
```

The script locates the repository independently of the working directory and
uses the established Clang x64 Release preset. Close Witcher 3 before using
`-Build`. Optional `-Version 1.0` and `-OutputDirectory C:/path/to/releases` control
the archive name and destination. By default, the version comes from the addon
and ZIPs go to `build/Release/packages`.

Each ZIP contains exactly:

```text
bin/x64_dx12/tw3-darkernights-remastered.addon64
README-Darker-Nights.txt
LICENSE.txt
```

The script verifies every decompressed file's SHA-256 before publishing the ZIP.
It includes installation instructions, credits and support/donation links;
ReShade, other addons and personal configuration are not bundled.

## Shader and runtime verification

The generated `build/thewitcher3remastered-darkernights.include/embed/shaders.h` should
contain the 13 lighting replacements in `lighting/`, both moon vertex variants
(`0x14AEBBFB` and `0x680C44CE`) and their brightness pixel shaders
(`0xE446F231` and `0x6D5A1EC2`) in `sky/`, and the independent helper
compute shader `effects/0xF3B20000.cs_6_6.hlsl`. The helper is removed from the
game-replacement map; seven native post-grade hashes and eleven audited HDR
replacement hashes have observation callbacks only.
Lighting replacements use native shader bindings. No tone-map, grading, output,
video or motion-blur shader replacements are included.

The lighting addon isolates its runtime state from other RenoDX DLLs and does
not inject shader constants or alter native root signatures. The selective
saturation helper owns a separate root-UAV/constant compute layout. Skylight and
cloud factors share audited, zeroed padding in the native lighting buffer
(`b12, c185.w`). Each uses 14-bit fixed-point encoding; off, native and double
are exact, with intermediate factor error below 0.000062. An HDR addon does not
need rebuilding to coexist with this addon.

Verified: Release x64 build, all 13 shaders compiled with DXC strict diagnostics
(`-Ges -WX`), and all 322 native lighting plus 283 grading cases passed. A CPU coexistence host
loaded the installed HDR DLL alongside this addon in both load orders and
verified isolated device data, preserved HDR settings bindings, teardown and
reload. The native grading upload signatures and rejection guards were checked
against the installed executable. New grading controls still require in-game
verification, both alone and alongside the other HDR addon. The user confirmed that the game scene and UI render normally with both
addons; the game log also records a clean exit.

For a runtime check, test this addon alone and alongside an HDR addon without
these lighting hooks, including a restart/device teardown in both configurations.
Confirm the addon title and native-lighting installation message in
`ReShade.log`. Check both camera sliders at 0/50/100 in gameplay and paused
dialogue; confirm each changes its own fill while torches retain their lighting.
At full night, check environmental
strength 0/50/100 in raster, RT and PT modes. Check all four time endpoints,
daytime restoration, Enable Night Lighting off and Preset Off. Check luminance
and chroma independently at 0/50/100, then both preset buttons. Confirm SDR and
native HDR output remain selectable. Check vegetation saturation at 0/50/100,
warm lights, UI, night fades, midday and master Off. Native callback tests are documented in
`tests/README.md`; a successful build does not replace these in-game checks.

## Credits and support

Game mod by Hartapfel; RenoDX framework by ShortFuse. The addon includes the same
support and donation buttons as the HDR mod:

- [RenoDX Discord](https://discord.gg/Ce9bQHQrSV)
- [HDR Den Discord](https://discord.gg/5WZXDpmbpP)
- [RenoDX GitHub](https://github.com/clshortfuse/renodx)
- [Hartapfel's Ko-Fi](https://ko-fi.com/hartapfel)
- [ShortFuse's Ko-Fi](https://ko-fi.com/shortfuse)


## HairWorks night skylight

HairWorks pixel shader 56511D80 now applies Night Skylight to its new-irradiance
ambient branch, which bypassed the native environment weights. It uses existing
b12 c185.w padding; no shader bindings or root layouts are added. Local/direct
light, reflection weights, hair coverage, normals and motion outputs are preserved.
Native/neutral tags and the legacy ambient branch retain their original behavior.

The original baseline is archived under native/lighting/. Strict compilation,
native resource/signature/CB-size checks, 160 native-baseline comparisons and
2560 synthetic ambient-delta/MRT/alpha/motion comparisons passed across both
addons' tag formats. These are synthetic checks; runtime verification requires
the rebuilt addon to register this newly identified shader. After restarting,
compare HairWorks hair/beard at Night Skylight 0/50/100, with a torch, with night
lighting disabled, and at midday. Also compare HairWorks off.

The standalone Release addon was rebuilt with this shader and its embedded CSO
was verified. The user confirmed the equivalent HDR-addon HairWorks fix in game;
standalone runtime verification remains pending.


Photo Mode's grading shader `0x6DDA5B7B` is observed before UI composition,
so Night Vegetation Saturation applies there too. Its c8-c15 night grading
constants use the existing validated upload hook for Night Color Grading
Luminance/Chroma; environmental lighting keeps the existing native hooks.
No Photo Mode HDR tonemapper or extra constant-buffer binding is introduced.
The routing test includes seven native grading hashes, with standalone-only
and both load orders against the installed HDR addon. After rebuilding
`thewitcher3remastered-darkernights` in `clang-x64-release`, compare Photo Mode and
gameplay at Night Vegetation Saturation 100/0, test the two night grading
sliders and master Off, and confirm the UI stays unchanged. HDR replacements
of this pass use the same interface recognition as the gameplay and Toussaint
variants.

The current installed HDR addon replaces Photo Mode 0x6DDA5B7B with
0x3D87EF7F at pipeline creation, recognized by its scene interface. A live
capture confirmed the RGBA16F scene output precedes separate UI composition;
its shader retains gamma-2.2 BT.709 transport and source alpha. The actual
foreign-DLL routing test reproduced the missed callback before the fix and
passes all seven routes standalone-only and in both HDR load orders afterwards.

## GPU scratch lifetime

The vegetation-colour pass uses the same fence-retired allocator as Motion Blur.
Each command recording owns its scratch buffers until reset/destruction, then
retires them behind fences on every queue that submitted that recording. The
pre-submission execute event only records queue identity. Completed buffers are
reused; at most two remain cached and expire after 120 presents without reuse.
Old resolution-sized buffers no longer accumulate until command-list destruction.

The scratch budget is 384 MiB. If it is exhausted, the optional vegetation pass
leaves the scene unchanged rather than allocating more or waiting for the GPU.
Failed queue tracking/signalling retains affected buffers within that budget.
Other lighting and grading controls are unaffected. ReShade logs current/peak
scratch MiB, allocation count, processed passes and skipped passes every 300
presents. No vegetation shader math or saved settings changed in this fix.

## Separation from the HDR addon

This folder owns all night, camera-light and moon features. The HDR addon no
longer embeds lighting replacements or installs native lighting detours. Its
30-DWORD HDR payload does not include night controls. Build targets are
`thewitcher3remastered` (HDR) and `thewitcher3remastered-darkernights` (lighting).
The packaged lighting filename remains `tw3-darkernights-remastered.addon64`.
