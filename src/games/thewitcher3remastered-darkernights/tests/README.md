# Native lighting validation

## All-day fog

The native lighting host checks Fog Amount independently of the night master,
at four clock values, with native/off/double density and invalid slider inputs.
Whole-buffer comparisons verify that only geometry/sky density changes and that
fresh uploads never accumulate scaling. A fog-only change requests hook
installation. Preset tests cover saved Fog Amount values, Preset Off restoration
and preservation by Soft Nights. Executable tests reject each changed density
load/store independently without disabling the other controls.

In the captured PT building, a temporary zero-density fog shader removed the
indoor blue haze and outdoor distance fog, with no non-finite pixels. The test
shader was unloaded. The actual Release native hook still needs a restart and
standalone/HDR coexistence check at 0/50/100/200%, including sky fog, raster/RT,
day/night and master Off. Authored smoke/cloud effects remain separate.

`interior_fog.cpp` checks indoor fading, active/inactive underground profiles,
ordinary buildings with global weather only, recognized building areas,
unknown local areas, native cave flags, alternate-world selection and invalid
or freed pointers. The native lighting host also checks 384 combinations of
both density multipliers, indoor blending, cave exclusion and Off/support
restoration against complete freshly built buffers. Interior-only settings
request hook installation. Preset tests save the building value per profile;
the optional executable checks independently reject all eighteen reader signatures.

The Novigrad regression covers a recognized Dandelion interior overlapped by
the regional `env_novigrad_city.env` area. This audited city layer is allowed;
cave and unknown local contributions remain excluded, and the
outdoor/doorway blend remains unchanged. The live reader changed from 0 to 1
in the affected building after this classification fix.

The shared `env_novigrad_int.env` building profile is also recognized alongside
the city layer. Its live indoor state was fully inside, but the previous reader
excluded it as unknown. The updated reader enables the override there; tests
retain doorway blending, underground priority and unknown-local-area exclusion.

Upstairs live inspection found a fully weighted Dandelion room at priority 300
over a sewer environment at priority 0. The detector now follows the native
selected-layer order and final layer weights, so the overridden sewer cannot
veto the room. Tests cover both priority orders, fractional cave blending,
unknown foreground areas and the shared Novigrad interior. The updated reader
returns 1 in the affected upstairs room.

Entry and exit use a critically damped response (3.2/s), reaching 95% of an
abrupt change in about 1.5 seconds. Timing checks at 30/60/144 FPS compare
both directions with the exact response, including doorway reversals without
position/velocity jumps, bounded output, long-pause step limits, immediate Off
restoration and resets across world changes. Runtime doorway/stair comparisons
require the rebuilt addon.
Alternating the target every frame checks that boundary chatter does not
reappear as output flicker. A live 20-second doorway trace captured transient
0/1 target changes with a constant broad indoor state and environment pointer;
the proposed damped output remained continuous in the read-only inspection tool.

The Kaer Trolde balcony and its room both reported fully indoors. Native weather
suppression differs: visibility 1 on the balcony, 0 in the room. The reader
gates unclassified interior weight with the inverse of that authored factor (weather +0x5d0),
independently of actual precipitation intensity (+0x5e0). Regression checks
cover partial suppression, invalid/missing state and density-only uploads.
This signal does not prove geometric enclosure in every authored environment;
other buildings still need runtime coverage checks.

In a captured Novigrad storm room, global dark clouds at priority 254 set weather
visibility to 1 above a fully active local `env_novigrad_int.env` at priority 210.
Recognized building contribution bypasses that weather gate. Tests cover this
stack, partial building weights, higher-priority cave exclusion, and full-buffer
density-only uploads across weather visibility values. The unclassified residual
still uses weather suppression, preserving the captured balcony behavior.

A second Novigrad room uses the local `env_nml_global_dark_sunset.env` lighting
area over global sunset weather, with visibility 1. The same area remains active
outside, but the native outside blend switches from 0 to 1 at the doorway.
This audited shared profile allows building control through the indoor blend;
its global use alone does not identify a room. Tests cover the captured inside
and outside states, partial blends, higher-priority caves and density isolation.

A locked Novigrad quest room reports fully indoors but has no dedicated interior
profile: dark clouds at priority 254 override city lighting (weight 0.43166414)
at priority 200 above global sunset. An active local city lighting area now lets
the native indoor blend cover the unclassified residual, independent of weather
visibility or city lighting strength. Tests cover that stack, outdoor/partial
indoor states, inactive/global city records and higher cave/unknown contributions.
The locked quest prevents an in-game outdoor comparison for this specific room;
exposed areas that share its indoor volume still need runtime verification.

A captured Dandelion room has native weather visibility -0.1686685 despite
fully weighted building layers. Finite visibility values now saturate to 0–1
instead of rejecting the room. Tests cover this layer stack, curve undershoot
and overshoot, nonfinite rejection, and full-buffer fog density isolation.

Read-only inspection using the shipping reader returned 1 in the PT building
and 0 in the cave. The basic indoor state alone included both; the cave was
excluded by its active `env_novigrad_cave.env` profile. A custom cave lacking
both an underground profile and the native cave flag remains indistinguishable
from a building with ordinary global weather. After restarting, test Building
Fog Amount at 0/50/100 in the building, through the doorway fade, outside and
in a cave. Outdoor fog viewed through windows is intentionally affected.

## Night exposure

`night_exposure.cpp` checks 4730 cases: directional speed changes against a
separately evaluated continuous-time response at 30/60/120/240 FPS, native
identity, master/daytime restoration, clock fades, both exposure states during
environment transitions, fixed metering independence from measured luminance,
independent brightening/darkening limits in exposure stops, native zero/negative
metering floors, ranges above/below the reference, preserved native endpoints,
independence from adaptation speed, scheduled/all-day rates and metering,
master-Off restoration, and invalid-input/caller guards. The exposure tests preserve all curve-selector
and metadata components. No shader, root layout or descriptor tracker is added.

```powershell
clang-cl /std:c++20 /EHsc /O2 /MT /DNOMINMAX src/games/thewitcher3remastered-darkernights/tests/night_exposure.cpp /Fe:tmp/darker-nights-exposure.exe /Fo:tmp/darker-nights-exposure.obj
./tmp/darker-nights-exposure.exe
```

The updated executable detection test validates the actual speed upload and
all three primary/transition metering uploads. Changed exposure instructions
disable only exposure controls; the lighting and grading validators remain
usable. The current executable passes 82 detection cases. The rate upload is
found once within the audited lighting-renderer region and its call target is
checked; nothing is scanned per frame. Existing build profiles retain their
original lighting checks.

The preset host also checks all eight exposure values are restored from saved
profiles, Soft Nights restores Enabled + Smoothed with All Day off, and visibility follows Off /
Enabled and Native / Smoothed / Custom. These CPU tests do not verify the live
detour or final image. After rebuilding and restarting, test the Night Exposure
section standalone and with HDR: move the camera between dark and bright areas
in Native/Smoothed/Custom, check each custom rate separately at 1/100/200,
compare both limits independently at 0/10/100, then select Off and adjust
Fixed Luminance. Compare All Day On/Off in daylight and during schedule fades,
invalid schedules, the night master, Preset Off, weather transitions, Photo
Mode, saved profiles, and forced camera-cut exposure resets. Smoothed/Custom
preserve native forced resets; fixed metering removes measured-luminance
dependence at full night even on those frames.

`night_lighting.cpp` exercises this addon's own native callbacks against audited
renderer stores. The 794 cases cover environmental RGB and clock fades,
midnight/daytime identity, invalid schedules, skylight restoration/rebasing,
whole-buffer isolation, water parameters and independent gameplay/cutscene-camera selection. Packed
skylight/cloud factors are checked for marker validity, independent endpoints
and fixed-point error bounds across clock fades.
They preserve other bytes, local/interior lights and alpha. They do not establish
the live executable hook ABI or actual D3D12 shader execution.

`night_weather.cpp` tests the guarded native current/alternate-world weather reader,
40 installed region/weather combinations, partial environment overrides, transition
endpoints, independent normalization toggles, master restore, unknown weather and
invalid pointers. Its 1,200 cases check calibration separately from the renderer.
`night_lighting.cpp` also exercises all weather endpoints alone and combined with
regional normalization through the actual PT, raster and common-constant hooks,
with 3,096 normalization/fade/intensity cases and whole-buffer isolation checks.
Executable rejection tests disable only weather normalization when any audited
weather signature changes; saved-profile tests include its independent toggle.

```powershell
clang-cl /std:c++20 /EHsc /O2 /MT /DNOMINMAX src/games/thewitcher3remastered-darkernights/tests/night_weather.cpp /Fe:tmp/darker-nights-weather.exe /Fo:tmp/darker-nights-weather.obj
./tmp/darker-nights-weather.exe
```

From an x64 Visual Studio developer shell at the repository root:

```powershell
clang-cl /std:c++20 /EHsc /O2 /MT /DNOMINMAX /Iexternal/Detours/include src/games/thewitcher3remastered-darkernights/tests/night_lighting.cpp /Fe:tmp/darker-nights-test.exe /Fo:tmp/darker-nights-test.obj /link external/Detours/lib.X64/detours.lib
./tmp/darker-nights-test.exe
```

Build the Release addon and perform the standalone runtime checks in the mod
README, using this addon with ReShade, both alone and alongside an HDR addon
without these lighting hooks. Remove Artificial Player Lights.

## Executable compatibility

`executable_detection.cpp` maps the supplied executable and tests the actual
native lighting validator. Its 61 cases accept changed timestamps/image sizes
with matching layouts and reject insufficient image bounds, invalid PE types,
each changed required renderer signature and invalid skylight CVar data.
It also checks that every hook binds to the selected layout, grading matches
that layout's callers, and camera calls resolve to the correct target. Optional
camera/grading failures preserve core lighting support. This does not prove
support for GOG executables with other renderer layouts.

The October 8 executable passes with environment RVA `0x1C2E400`, direct
constants `0x1C6FF10`, common constants `0x1BE4C00`, global constants `0x1C7D140`,
camera builder `0x35B500`, `PTSkyImpact` `0x5149788`, and pixel-constant setter
`0x1EDFD70`. Its six grading callers move by `-0x1620`. The previous profile
passes the same 61 cases using a loader-only relocated instruction fixture;
that fixture is never executed as a game binary. All 283 grading and 992
lighting/camera/schedule/moon cases pass.

The renderer's directional-light buffer pointer moves from `+0x690` to `+0x698`.
Validation checks both the pointer-load opcode and its displacement. The
lighting tests execute the hook for both layouts with an invalid sentinel at
the unused offset; selecting the old field in the new layout reproduces the
startup crash rather than silently passing a colour-only check.

```powershell
clang-cl /std:c++20 /EHsc /O2 /MT /DNOMINMAX /Iexternal/Detours/include src/games/thewitcher3remastered-darkernights/tests/executable_detection.cpp /Fe:tmp/darker-nights-detection.exe /Fo:tmp/darker-nights-detection.obj /link external/Detours/lib.X64/detours.lib
./tmp/darker-nights-detection.exe "E:/SteamLibrary/steamapps/common/The Witcher 3/bin/x64_dx12/witcher3.exe"
```

## Addon coexistence

`coexistence.cpp` loads the actual lighting and HDR DLLs into a minimal CPU
ReShade host. It checks device-data isolation, the HDR settings binding (root constants or CBV), unchanged
pipeline layouts, callback ownership, destruction and repeated load/unload.
Run both load orders. GPU calls are mocked; this does not verify rendered pixels.

```powershell
clang-cl /std:c++20 /EHsc /O2 /MT /DNOMINMAX /DWIN32=1 /Iexternal/reshade src/games/thewitcher3remastered-darkernights/tests/coexistence.cpp /Fe:tmp/darker-nights-coexistence.exe /Fo:tmp/darker-nights-coexistence.obj
./tmp/darker-nights-coexistence.exe build/Release/renodx-thewitcher3remastered-darkernights.addon64 path/to/hdr.addon64 lighting-first
./tmp/darker-nights-coexistence.exe build/Release/renodx-thewitcher3remastered-darkernights.addon64 path/to/hdr.addon64 hdr-first
```

## Native night grading

`night_grading.cpp` checks 283 cases for curve/filter independence, neutral
endpoints, clock fades, preserved gamma/vignette/selector slots, unrelated callers
and non-finite inputs. Passing the installed executable also validates the exact
native upload call sites and tests rejection of altered signatures. These checks
do not establish rendered appearance or live detour execution.

```powershell
clang-cl /std:c++20 /EHsc /O2 /MT /DNOMINMAX src/games/thewitcher3remastered-darkernights/tests/night_grading.cpp /Fe:tmp/darker-nights-grading.exe /Fo:tmp/darker-nights-grading.obj
./tmp/darker-nights-grading.exe "E:/SteamLibrary/steamapps/common/The Witcher 3/bin/x64_dx12/witcher3.exe"
```

## Selective vegetation saturation

`vegetation_gpu.cpp` executes the actual helper CSO on D3D12 WARP, including
RGBA16F texture-to-buffer copying, root-UAV dispatch and copying back. Its 20
cases cover aligned/padded row pitches, odd dispatch dimensions, signed HDR
transport, slider 0/50/100/150/200, neutral/warm/pink isolation, green/cyan
coverage, luminance within half-float rounding and exact alpha metadata bits.
This does not establish live callback timing or frame time with another addon.

```powershell
bin/dxc.exe -T cs_6_6 -E main -HV 2021 -Ges -WX -enable-16bit-types -Fo tmp/vegetation.cso src/games/thewitcher3remastered-darkernights/effects/0xF3B20000.cs_6_6.hlsl
clang-cl /std:c++20 /EHsc /O2 /MT src/games/thewitcher3remastered-darkernights/tests/vegetation_gpu.cpp /Fe:tmp/vegetation-gpu.exe /Fo:tmp/vegetation-gpu.obj /link d3d12.lib dxgi.lib
./tmp/vegetation-gpu.exe tmp/vegetation.cso
```

The standalone shares the HDR addon's measured OKLCh selection endpoints:
85/110/135/220/250/275 degrees, with respective weights 0/0.35/1/1/0.35/0.
Near-neutral selection fades at relative OKLab chroma C/L 0.02..0.06. It is
a hue filter, not material identification. Hue research and saved foliage
measurement evidence are in `tmp/thewitcher3remastered/night-selective-saturation/`.
The standalone grades before the downstream tonemapper, rather than after
PsychoV as the HDR addon does. Check its appearance alone and alongside the
intended other HDR addon after restarting; verify SDR/HDR and FG On/Off.

Validated: Release build; strict DXC compilation of all 14 shaders; 20 actual
D3D12 GPU copy/compute cases; all 794 lighting/camera/schedule cases and 283
native grading cases, including executable signature rejection. Actual DLL
coexistence lifecycle checks pass in both load orders with the current HDR
build and the saved older HDR DLL. These CPU checks preserve native layouts
and HDR settings bindings, but do not execute the live GPU callback path.

## Create-time HDR shader routing and preset selection

`vegetation_routing.cpp` compiles the standalone's actual registration code
into the mock host, then runs the installed HDR DLL's create/init/destroy
pipeline callbacks against all seven original post-grade CSOs. It verifies
observation-only routing alone and in both addon load orders, including the
new current HDR replacements. Pipeline destruction clears the observation
cache; device/addon teardown remains isolated and clean.

Its `--interfaces <directory>` mode checks the DXIL matcher against captured
native shaders and CSOs extracted from the two HDR addon fixtures. The native
corpus has 1,468 shaders, of which only the seven audited grading passes match.
The two HDR builds contain 51 distinct shaders, with exactly seven grading
replacements accepted per build. Other effects, truncated containers and
invalid part offsets are rejected. Changing a replacement's container identity
keeps the interface match despite its changed CRC32. These fixture hashes are
used only by tests; production recognition has no HDR-release hash list.

The current Photo Mode output `0x3D87EF7F` was inspected with DevKit and writes
the expected RGBA16F scene target. After rebuilding, compare saturation 100/0
in gameplay and Photo Mode with both addons enabled, and verify the UI remains
unchanged. CPU routing checks do not establish rendered output after restart.

`preset_persistence.cpp` uses the same host and addon source. It checks startup
restoration of the independent all-day exposure toggle and its preset reset,
restoration of selections 0..3 and their profile values, Off's native reset,
missing/invalid selection fallback, saving every selector change, and keeping
the HDR addon's separate configuration untouched. It also invokes Soft Nights
after mutating every night control to check that the regrouped sections still
reset together while both camera sliders and Moon Size remain unchanged.
It does not simulate ImGui.

Both tests include `addon.cpp`, so build the Release addon first to generate its
embedded headers, then use these options in an x64 Visual Studio developer shell:

```powershell
$testOptions = @('/nologo', '/std:c++20', '/EHsc', '/O2', '/MT', '/DNOMINMAX', '/DWIN32=1', '/Iexternal/reshade', '/Ibuild/thewitcher3remastered-darkernights.include', '/Iexternal/Detours/include', '/Iexternal/gtl/include', '/Iexternal/frozen/include', '/Iexternal/json/include', '/Iexternal/Streamline/include', '/Iexternal/DLSS/include')
clang-cl @testOptions src/games/thewitcher3remastered-darkernights/tests/vegetation_routing.cpp /Fe:tmp/vegetation-routing.exe /Fo:tmp/vegetation-routing.obj /link external/Detours/lib.X64/detours.lib shell32.lib
./tmp/vegetation-routing.exe path/to/originals path/to/hdr.addon64 lighting-first
./tmp/vegetation-routing.exe path/to/originals path/to/hdr.addon64 hdr-first
./tmp/vegetation-routing.exe path/to/originals none lighting-first
./tmp/vegetation-routing.exe --interfaces path/to/native-shader-corpus
./tmp/vegetation-routing.exe --interfaces path/to/extracted-hdr-fixtures
clang-cl @testOptions src/games/thewitcher3remastered-darkernights/tests/preset_persistence.cpp /Fe:tmp/preset-persistence.exe /Fo:tmp/preset-persistence.obj /link external/Detours/lib.X64/detours.lib shell32.lib
foreach ($selection in @('0', '1', '2', '3', 'missing', '-1', '4', 'invalid', '999999999999999999999999')) { ./tmp/preset-persistence.exe $selection; if ($LASTEXITCODE -ne 0) { throw "Failed selection: $selection" } }
```

Runtime: select Preset #2, change a slider, restart, and verify both the selected
profile and value. Repeat with Off and confirm native lighting at startup.

## Moon size

`night_lighting.cpp` also checks 18 day/night moon-size cases with the night
master disabled: finite-input bounds, native/half/double/500% factors, packed
transport error, unchanged surrounding constants and native restoration.
`executable_detection.cpp` includes optional moon-padding
signature failures. The preset test includes saved Moon Size and Off reset.

The moon vertex shaders `0x14AEBBFB` and Toussaint's `0x680C44CE` retain their original inputs/outputs and
b1/b2/b12 bindings and sizes (864/208/5456 bytes). It uses zeroed b12 c37.w
padding; the captured shader dump audit found no original consumer of that
component. Each replacement is restricted to its audited moon pixel shader
(`0xE446F231` and Toussaint's `0x6D5A1EC2`, respectively).
No extra constant-buffer binding, descriptor tracker or render pass
is added. At 100% the addon uses the original shader.

DevKit verification: hiding the paired pixel shader `0xE446F231` removed the
moon, then scaling the moon vertex positions to 50% produced the smaller disk,
confirmed by the user. After building `thewitcher3remastered-darkernights` with
`clang-x64-release`, restart with DevKit disabled and compare Moon Size 50/100/200/500
both alone and with the HDR addon. Check phase/texture, Photo Mode, water
reflections, saved presets and Off; scene moonlight should stay unchanged.

Toussaint Photo Mode: the native decompiled baseline compiled strictly and ran
live first. The production scaling math at 100% preserved the moon; at 50%, its
captured bright disk height changed from 424 to 210 pixels, retaining texture
and phase. Strict DXC compilation and signature/binding/CB-size audits passed
for both vertex variants. Test the rebuilt addon's slider in both regions,
including native/Off, gameplay and Photo Mode, with DevKit live shaders unloaded.

## Rain and blizzard clouds

`0x683213A3` applies Cloud Brightness to the final RGB, including the vertex
fog tint inside this cloud material. The previous material-only multiplication
left that fog blend unscaled. General fog and opacity remain independent.
Strict `ps_6_6` compilation passed; the replacement's input/output signatures,
interpolation, bindings and CB sizes match the previous replacement. With a
neutral factor, its compiled main exactly matches the previous neutral shader.
The original native baseline is archived under `native/lighting`.

DevKit captured the same shader in rainy and blizzard Photo Mode scenes.
After rebuilding `thewitcher3remastered-darkernights` using `clang-x64-release`,
compare Clouds 0/50/100 in both weather types, standalone and alongside HDR,
with live shaders unloaded. Check unchanged cloud silhouettes, precipitation,
moon, scene fog, UI, daytime, Night Lighting Off and Preset Off.

## Falling rain and water sky fill

Rain uses existing `b0 c14.w` padding, with guarded native zero stores for both
audited executable layouts. The shader dump audit found no original game
consumer; the reported SM5 consumers use separate effect/test buffers.
The native test checks rain-only transport at night, during fades and by day,
with unavailable padding, plus restoration through both master switches.

`0x04251B31` compiled strictly as `ps_6_6`. Its neutral compiled main is exactly
the original decompiled baseline's main; signatures, interpolation, resources
and CB sizes are unchanged. Texture operations and both MRT outputs remain;
the new factor adds one native CB load and three RGB multiplications.
The native baseline is archived under `native/lighting`.

DevKit-only live inspection identified the rain streaks using a magenta marker,
then verified zero brightness removes them. The user confirmed the Release rain
control works alongside HDR. No smoke/cloud shader was added to this control.

Skylight now scales evaluated `VanilaSkyWaterImpactMultiplier` and
`WaterReflectionSkyMultiplier` in the native sky constant builder. The validated
ABI returns the output pointer; +40/+54 resolve CVar or weather/Photo Mode values.
Tests cover fresh weather values, repeated frames, fades, daytime, native strength,
Water Lighting independence and preservation of every other output/environment
byte. A changed optional builder disables only this hook, preserving core controls.
The pre-update loader fixture exercises detection, not old-binary execution.
Temporary live CVar zero tests restored their original -1 values afterward.
The user confirmed the new engine hook removes almost all unwanted water light.
The separate `b0 c14.x` distance sky fill now also follows Skylight, as requested
after the combined-addon test. Native tests check independence from Water Lighting
and unchanged reflection/refraction constants. No replacement water material or
reflection-composite shader is shipped.

After rebuilding, check Rain Brightness 0/50/100 and the night fades with the
standalone alone and alongside HDR. Compare Water Lighting at zero with a real
local light reflected on the water, then compare Skylight 0/50/100. Check daytime, both Off switches, saved
profiles and both preset buttons. Other regions/weather variants may need
additional rain hashes if they use different materials.

Sun Size uses the native common-constant builder's `b12 c204.x` sun falloff
exponent, guarded by the audited environment `+391C` read and `+CC0` store.
The live Toussaint sky test confirmed that multiplying this exponent by four
shrinks the glow without moving it. The separate sun mesh uses vertex shader
`0xE1C4426E`, restricted to pixel shader `0xE46451D5`; it reads a tagged scale
from native `b12 c206.w` padding. All 3969 dumped shaders leave this component
unused, and the optional executable checks guard its qword clear and zero source.
Isolated live testing shrank both layers at 1% and confirmed that restoring only
the native mesh brings the bright disk back. The mesh can read the existing b12
binding at size 5456; no new root constants or descriptor uploads are introduced.
Native tests cover 41 size/range/invalid-value cases at midnight, dawn, noon and
dusk, preservation of every other common-buffer byte, Off restoration, and
sun-only hook installation. Executable tests reject changed optional sun
instructions while retaining other lighting controls. Preset tests cover saved
Sun Size, Preset Off's native size and independence from the night buttons.
The rebuilt Release addon passes both CPU coexistence load orders, and the user
confirmed the disk and glow now scale correctly with HDR and Darker Nights
loaded together at 1%.
