# Native lighting validation

## Night exposure

`night_exposure.cpp` checks 4514 cases: directional speed changes against a
separately evaluated continuous-time response at 30/60/120/240 FPS, native
identity, master/daytime restoration, clock fades, both exposure states during
environment transitions, fixed metering independence from measured luminance,
independent brightening/darkening limits in exposure stops, native zero/negative
metering floors, ranges above/below the reference, preserved native endpoints,
independence from adaptation speed, and invalid-input/caller guards. The exposure tests preserve all curve-selector
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

The preset host also checks all seven exposure values are restored from saved
profiles, Soft Nights restores Enabled + Native, and visibility follows Off /
Enabled and Native / Smoothed / Custom. These CPU tests do not verify the live
detour or final image. After rebuilding and restarting, test the Night Exposure
section standalone and with HDR: move the camera between dark and bright areas
in Native/Smoothed/Custom, check each custom rate separately at 1/100/200,
compare both limits independently at 0/10/100, then select Off and adjust
Fixed Luminance. Check daytime, schedule fades,
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
pipeline callbacks against the six original post-grade CSOs. All six routes
remain observation-only alone and in both addon load orders. The installed
HDR v0.2026.1003.311 substitutes four of them, and v0.2026.1006.1950 substitutes
six including Toussaint's `0x2BF760E2`; their bytecode hashes match the ten
compatibility aliases. The user confirmed the older rebuilt combination works
in game. DevKit identified the
updated active grading pass as `0xE22E8A08`, writing gamma-2.2 scene RGB into
RGBA16F. Toussaint uses `0xFF89140C` with the same output domain and format.
Original dumps remain outside `src/games/`.

Validated the updated DLL's actual create-time substitutions in both load
orders and the standalone's six native routes (18 cases). Each route retains
the grading shader and uses observation only, with clean device teardown.
These CPU checks do not establish rendered output after restarting the game.

`preset_persistence.cpp` uses the same host and addon source. It checks startup
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
