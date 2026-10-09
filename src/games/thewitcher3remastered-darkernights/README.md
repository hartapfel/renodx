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

Light intensity sliders use **0 = off, 50 = native, 100 = double**. Grading and
moon controls use the ranges described below:

| Control | Changes |
|---|---|
| Skylight | Environmental illumination, outdoor probe fill and sky lighting/reflections on water. |
| Direct Light | Directional environment lighting, including grass. |
| Directional Fog | Directional/custom fog brightness, preserving density. |
| Aerial Haze | Aerial and distance-fog brightness, preserving extinction. |
| Sky Brightness | Visible sky and horizon glow, preserving moon/stars. |
| Cloud Brightness | Cloud and cloud/smoke volume brightness, preserving coverage. |
| Rain Brightness | Falling rain streak brightness; weather intensity and wetness stay native. |
| Water Lighting | Water color and ambient/diffuse fill, preserving reflected scene light/refraction/foam. |
| Brightness & Contrast | Night grade luminance curve; 0 removes it, 100 keeps native. |
| Tint & Saturation | Night grade colour filter; 0 removes it, 100 keeps native. |
| Vegetation Saturation | Green/cyan scene saturation, with gentler yellow/blue coverage; 100 is native, 0 reduces it. Matching non-foliage colours also respond. |
| Gameplay Camera Light | Player-following fill light throughout the day and night. |
| Cutscene Camera Light | Artificial scene and dialogue camera fill, independent of the night schedule. |
| Moon Size | Visible moon diameter from 1% to 500%; 100% is native, 50% halves it. |
| Sun Size | Visible sun diameter from 1% to 500%; 100% is native. Active at every hour. |
| Auto Exposure | Enabled uses adaptation; Off uses a fixed luminance reference during the night hours. Enabled is the default. |
| Adaptation | Native (default), Smoothed, or Custom. Smoothed uses 35% brightening and 5% darkening speed, with both limits at 100%. |
| Brightening / Darkening Speed | Custom only; 1-200% of each native speed, default 35% brightening and 5% darkening. 100% retains that direction's native response. |
| Maximum Brightening | Custom only; 0-100% of native brightening beyond the 0.18 metering reference, default 100%. 0 prevents lift beyond that reference; 100 retains the native range. |
| Maximum Darkening | Custom only; 0-100% of native darkening beyond the 0.18 metering reference, default 100%. 0 prevents further darkening beyond that reference; 100 retains the native range. |
| Fixed Luminance | Off only; 0.001-10, default 0.18. Lower values brighten the image; higher values darken it. |

**Night Exposure** follows Enable Night Lighting and the same clock fades.
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
night strength. Daylight and clock fades retain or gradually restore automatic
exposure. Lighting, weather transitions and artistic exposure parameters can
still change the image. This is a fixed metering reference, not a frozen frame
or a fixed display luminance in nits.

The controls reuse the validated native constant-upload hook. Off keeps the
normal dynamic tone-map shader and live adaptation history; no fixed-shader
substitution, tone-map override, new bindings, readbacks, descriptor tracking
or extra GPU pass is added. This preserves the HDR addon's existing shader
routing and bloom exposure references. A foreign addon that ignores native
metering parameters can bypass this control. Preset Off, the night master Off,
daytime and invalid schedules restore native exposure. Values are saved per
preset; Soft Nights resets exposure to Enabled + Native.

Torches, ordinary local lights and the separate interior camera-light group retain
their native behavior. Both camera sliders work independently of Enable Night
Lighting and the night schedule. Their defaults are 50; set either to 0 to disable
its camera fill without a separate mod. Preset Off restores environmental and camera
lighting. Presets are stored under `renodx-darkernights-remastered`, separately
from the HDR addon.
The top-level Off / Preset #1 / #2 / #3 selection is also restored on the next
launch. Missing or invalid saved selections start on Preset #1.

**Moon Size** is in the Sky Appearance section and works independently of Enable Night
Lighting and its clock schedule. It scales the moon mesh while preserving its
texture and phase; it does not change the directional moonlight strength. It is
saved with each preset, defaults to 100%, and returns to native size with Preset
Off. The two night preset buttons leave moon size unchanged.

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
20:00 to 23:00, fade out 03:30 to 06:00; skylight 15, direct 15, fog 15, haze 5,
sky 5, clouds 15, rain 15, water 0, both grading controls 100 and vegetation saturation
50. Its button restores these
night defaults. **Dark Nights** keeps the same schedule and grading, with skylight
5, direct 5, fog 5, clouds 10 and rain 10. Both buttons enable Night Lighting and leave both camera
sliders unchanged. Existing saved settings are preserved; use Soft Nights
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
The standalone applies it to the audited signed gamma-2.2 BT.709 scene output of
the six native post-grade variants, before UI composition and the selected
output tonemapper. The HDR addon has no separate selective saturation control; this standalone
pass supplies it when the addons are used together.

The observation list also recognizes the four compiled grading replacements
in HDR v0.2026.1003.311 and six in v0.2026.1006.1950. DevKit confirmed the
updated active `0xAD02BAB3` variant appears as `0xE22E8A08` (previously
`0x2957BB38`), with the same gamma-2.2 transport
and RGBA16F scene target. This restores the saturation control when that addon
replaces shaders during pipeline creation. These aliases observe its output;
they do not replace its shaders or share its internal C++ state. Other HDR
builds with different bytecode hashes need their grading passes audited too.

Toussaint's texture-vignette grading variant `0x2BF760E2` is observed too,
including its updated HDR replacement `0xFF89140C`. Its scene output uses the
same gamma-2.2 transport; native vignette and alpha metadata remain intact.

One GPU texture-to-buffer copy, root-UAV compute pass and copy back is recorded
when the night delta is nonzero. At 100, during daytime or with the master Off,
no extra GPU work is recorded. Native scene alpha bits are preserved. Brightness
is preserved within half-float rounding; saturation increases use a soft RGB
black-boundary limit, leaving highlight mapping to the downstream tonemapper.
The pass never replaces another addon's grading/output shader, changes its
root signature or switches descriptor heaps. It captures compute root values
for restoration, without descriptor heap update/copy tracking, GPU readbacks
or CPU waits. Scratch buffers are reused per command list. This pass adds a
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
(`0x14AEBBFB` and `0x680C44CE`) in `sky/`, and the independent helper
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
sliders and master Off, and confirm the UI stays unchanged. A foreign HDR
addon that replaces this pass with a new bytecode hash needs an audited
observation alias, as with the other grading variants.

The installed HDR v0.2026.1006.1950 replaces Photo Mode 0x6DDA5B7B with
0xE715845F at pipeline creation. This alias is now observed too. A live
capture confirmed the RGBA16F scene output precedes separate UI composition;
its shader retains gamma-2.2 BT.709 transport and source alpha. The actual
foreign-DLL routing test reproduced the missed callback before the fix and
passes all seven routes standalone-only and in both HDR load orders afterwards.

## Separation from the HDR addon

This folder owns all night, camera-light and moon features. The HDR addon no
longer embeds lighting replacements or installs native lighting detours. Its
30-DWORD HDR payload does not include night controls. Build targets are
`thewitcher3remastered` (HDR) and `thewitcher3remastered-darkernights` (lighting).
The packaged lighting filename remains `tw3-darkernights-remastered.addon64`.
