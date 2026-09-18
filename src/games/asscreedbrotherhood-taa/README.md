# Assassin's Creed Brotherhood — native DX9 TAA

Experimental temporal anti-aliasing, extracted from `asscreedeziotrilogy` into
its own optional **32-bit addon**. It includes camera jitter/reprojection,
temporal accumulation and the audited object, skeletal, cloth and vegetation
motion paths. **TAA and Object Motion are enabled by default**; debug views are off.

## Install

Use 32-bit ReShade with addon support in the directory containing `ACBSP.exe`.
Keep an existing working ReShade installation. Native MSAA is optional.

| Configuration | Addon files beside `ACBSP.exe` |
| --- | --- |
| RenoDX HDR + TAA | Updated `renodx-asscreedeziotrilogy.addon32` and `renodx-asscreedbrotherhood-taa.addon32` |
| Native SDR + TAA | `renodx-asscreedbrotherhood-taa.addon32` only |

Close the game before replacing either file. The matching Ezio Trilogy build
has embedded TAA removed. **Do not combine this addon with an older experimental
Ezio build that still contains TAA.** Both would jitter and resolve the same frame.
The two current addons work in either load order. DevKit is optional.

In the ReShade addon settings, open **Assassin's Creed Brotherhood TAA**:

The panel starts with a quick-start guide covering the default settings,
motion-quality/performance choice and optional native MSAA. The footer contains
compatibility and update instructions, reporting guidance, RenoDX/HDR Den
Discord links, GitHub, Hartapfel/ShortFuse Ko-Fi links, credits and the build
timestamp. Include that timestamp when reporting an issue. The current addon
remains experimental.

| Section | Control | Options | Default |
| --- | --- | --- | --- |
| TAA | Anti-Aliasing | Off / TAA / DLAA | TAA |
| TAA | DLSS Preset (DLAA only) | DLL Default / F (Legacy) / J / K / L / M | DLL Default |
| TAA | Motion Vectors | Camera Motion / Object Motion | Object Motion |
| Sharpening | Lilium RCAS | 0-100 (0 = Off) | 0 |
| Debug | Debug View | Off / Depth / Motion Vectors / History Confidence / History Rejection | Off |

Object Motion includes camera movement and supported object/animation movement.
Camera Motion costs less CPU time but can leave trails on moving objects.
TAA Off disables accumulation, jitter and debug rendering. The selected debug
view is remembered for the next time TAA is enabled. Depth does not accumulate
history. Motion Vectors, History Confidence and History Rejection keep normal
TAA running underneath. **Motion Vectors** is the only motion preview and follows
the selected motion source. It shows the combined vectors selected by the real
resolve: object vectors where required, otherwise camera reprojection from depth.
Neutral gray means still, red/green channels encode horizontal/vertical movement,
and magenta marks invalid reprojection. Intentional jitter is removed from the
displayed vector, yielding the displacement from an output pixel to its history
sample. Correct vectors can point outside the old image; history is still
rejected there. The extra display pass runs only while a diagnostic is selected.

Static buildings with reliable depth can use camera motion. Object vectors are
needed for independent movement and deformation; they also supply depth for
some late materials. Replay now omits confirmed unchanged rigid draws that
write native scene depth. New/ambiguous instances, changed transforms or buffers,
deformation, and late materials retain replay. Capture and classification still
cost CPU time; this is not a claim that all static-scene overhead is eliminated.
Sky uses camera rotation/FOV without translation parallax or finite-depth checks.

The resolve retains cubic history sampling and motion-responsive weighting.
If a character part briefly loses its previous pose, other directly tracked
parts can supply that character's body/camera motion. This conservative estimate
uses at most four samples of history until full animation tracking resumes.
Ambiguous matches and newly visible whole characters still reset history.

### Sharpening

**Sharpening -> Lilium RCAS** adds optional luminance-based sharpening with
noise suppression to the completed TAA image. The 0-100 slider defaults to 0
(Off); 100 is full strength. It runs before the native/HDR LUT and HUD, works
with either motion source and optional MSAA, and leaves debug views unsharpened.
The sharpened image is never fed back into TAA history. At nonzero strength it
adds one five-tap GPU pass using an existing scratch texture; it allocates no
additional full-resolution buffer. Later game effects such as depth of field
still run normally. TAA Off also disables sharpening.

### Combining TAA with native MSAA

Enable the desired MSAA level in the game and leave TAA On. The addon detects
the multisampled scene and applies TAA after the game's color resolve, before
color grading. **Matching projection jitter is applied to the MSAA color pass
and its separate depth prepass.** An eight-phase pattern uses half the normal
TAA offset (less than a quarter pixel per axis), since MSAA already supplies
spatial coverage. Bounded cubic reconstruction preserves more resolved detail
than bilinear resampling. History confidence varies from 4 to 64 samples with
motion, and rejection can shorten it further. With MSAA off, the existing
full-footprint jitter and history policy are used.

MSAA supplies the geometric edge coverage and TAA accumulates temporal samples
after the native resolve. The temporal filter reads the game's resolved texture;
individual MSAA samples are not available to it. Optional RCAS runs afterward.

Camera motion uses the game's separate R32F depth prepass. Object Motion keeps
the existing animation capture, batched uploads and static-scenery omission;
its replay tests that depth at pixel centers and uses one private single-sample
depth buffer. Motion vectors are never averaged across different MSAA samples.
Materials requiring native stencil clipping are excluded from MSAA replay;
partial coverage at silhouettes and transparency still needs in-game checking.
The same Debug views show the inputs and decisions of either path.

Changing MSAA resets temporal history. Missing or inconsistently jittered depth
and color passes discard history and retain the native scene while reacquiring
the targets. The addon also supplies reset-safe uploads for native immediate
draws, keeping fullscreen LUT/UI geometry valid after graphics changes.
Native MSAA itself adds GPU and memory cost; the
hybrid path does not allocate another multisampled color or velocity buffer.

Settings are independent of HDR and stored in
`[asscreedbrotherhood-taa-preset1]`. The rename starts fresh settings; old
`[acbrotherhood-taa-preset1]` entries are not loaded. Replace the old
`renodx-acbrotherhood-taa.addon32` file rather than installing both names.
The simplified debug slider uses `TAADebugViewV2` and starts at Off, avoiding
reinterpretation of the old eight-choice slider's saved index.
Developer-only configuration keys `TAAInputCapture=1` (timing/capture logs) and
`TAADumpResolve=1` (one resolve-frame dump) remain supported but hidden from the UI.
Leave both at 0 for normal gameplay. A frame dump temporarily stalls rendering
and writes about 316 MiB at 4K into `renodx-dev/taa-capture`.

The motion preview passes through the game's LUT and, when installed, RenoDX
grading, so neutral gray can be tinted. Magenta can still identify a captured
animated surface without a trusted previous pose.

### Optional NVIDIA DLAA

DLAA replaces the custom temporal resolve at native resolution. It reuses the
same scene hook, jitter, camera and object motion capture. It is experimental;
TAA remains the default. **Requires an NVIDIA RTX GPU and native MSAA Off.**
With MSAA enabled, the selection falls back to the existing TAA/MSAA path.

Install this directory beside `renodx-asscreedbrotherhood-taa.addon32`:

```text
renodx-asscreedbrotherhood-dlaa/
  renodx-asscreedbrotherhood-dlaa.exe
  nvngx_dlss.dll
  NVIDIA-DLSS-LICENSE.txt
```

Restart after installing the helper, then select **Anti-Aliasing → DLAA**.
**DLAA Status** must say **DLAA active at native resolution**. Startup runs
asynchronously with TAA temporarily active. Missing files, unsupported hardware,
sharing errors or a stopped helper return to TAA with a visible reason/error.
Active status is green; initialization/runtime failure status is red. Startup
and deliberate TAA fallbacks (MSAA or diagnostic views) retain neutral text.
Switch to TAA and back to DLAA to retry. The helper log is
`renodx-asscreedbrotherhood-dlaa/renodx-dlaa-helper.log`.

**DLSS Preset** is a dropdown shown when DLAA is selected. **DLL Default**
leaves the preset hint unset, so the installed runtime chooses its own default.
Other options request F (legacy), J, K, L or M; availability depends on the DLL,
and NVIDIA driver overrides may take precedence. Changing the selection restarts
DLAA with fresh history and temporarily uses TAA. The selection is remembered
as `DLAAPreset`; fresh installs and settings reset use DLL Default. Update both
the addon and helper together, since their versioned protocol must match.

The optional helper is a hidden x64 process because Brotherhood is x86 and
NVIDIA's runtime is x64. GPU images cross through shared textures, without CPU
image readback. Installing the helper requests DX9Ex through ReShade at device
creation; the HDR addon already requests this. Standalone TAA without the helper
does not request this change. The helper creates no window or swapchain and
does not present frames. Keep its **64-bit** NVIDIA DLL inside the helper folder.

Object Motion's capture optimizations are shared with TAA. DLAA does not remove
that CPU cost; the helper adds GPU work and synchronization. It is not a promised
performance improvement. Resource dimensions are capped at 8,388,608 pixels.
DX9 shared working textures cost 28 bytes per pixel (about 221.5 MiB at 4K),
plus object capture; the x64 helper owns its additional working/model memory.
TAA history is released once DLAA starts successfully.

RCAS runs after either AA method, before the LUT/HUD, without sharpening history.
The Motion Vectors view displays the dense raw vectors sent to DLAA while it is
active. Depth and History Confidence/Rejection temporarily use the custom TAA
diagnostics; they do not expose NVIDIA's internal history decisions.

## Scope

This addon does not upgrade game resources, unclamp lighting, replace the LUT,
tone map, enable HDR, create a presentation proxy, or change presentation/VSync. Its
floating-point textures are private temporal working buffers. Native SDR scene
formats and sampling are preserved; with RenoDX it consumes the existing FP16
scene before the HDR LUT replacement.

Only Brotherhood is supported. Water, some transparency and ambiguous animated
instances remain incomplete; occasional magenta flashes and temporal artifacts
remain. See the limitations in [IMPLEMENTATION.md](./IMPLEMENTATION.md).
At 4K, temporal surfaces use about **158 MiB**, or **221 MiB with object motion**,
and **253 MiB with object motion plus native MSAA**,
plus bounded geometry storage, an animation atlas of up to 4 MiB and other
bookkeeping. This matters in a 32-bit game.

## Build and files

From the repository's configured Clang x86 build environment:

```powershell
cmake --build --preset clang-x86-release --target asscreedbrotherhood-taa asscreedeziotrilogy
```

The independently distributable files are:

```text
build32/Release/renodx-asscreedbrotherhood-taa.addon32
build32/Release/renodx-asscreedeziotrilogy.addon32
```

The new folder is discovered through `addon.cpp`; no global build or CI changes
are required. Shader headers are generated under
`build32/asscreedbrotherhood-taa.include/embed/`. No GitHub snapshot/download URL is
established by this extraction; publishing is a separate step.

Build the optional helper separately using its game-local Release preset:

```powershell
& src/games/asscreedbrotherhood-taa/dlaa_helper/build.ps1
```

Output: `build64-brotherhood-dlaa/Release/`. Distribute the executable, NVIDIA
runtime and license together in the directory shown above. The ordinary addon
target remains x86; no global presets or CI workflows are changed. The helper
uses the repository's existing `external/DLSS` SDK.

## Packaging a release

Build the x86 addon and x64 helper in Release, then copy these four files;
do not archive the entire build or game directory:

| Build output | Destination inside the release ZIP |
| --- | --- |
| `build32/Release/renodx-asscreedbrotherhood-taa.addon32` | `renodx-asscreedbrotherhood-taa.addon32` |
| `build64-brotherhood-dlaa/Release/renodx-asscreedbrotherhood-dlaa.exe` | `renodx-asscreedbrotherhood-dlaa/renodx-asscreedbrotherhood-dlaa.exe` |
| `build64-brotherhood-dlaa/Release/nvngx_dlss.dll` | `renodx-asscreedbrotherhood-dlaa/nvngx_dlss.dll` |
| `build64-brotherhood-dlaa/Release/NVIDIA-DLSS-LICENSE.txt` | `renodx-asscreedbrotherhood-dlaa/NVIDIA-DLSS-LICENSE.txt` |

Include installation instructions, the repository MIT license, the mod and RCAS
copyright/license notices, and the source commit/build identification. Copy real
file contents into a clean staging directory; development symlinks and junctions
are not release files. Zip the **contents** of that directory so extracting into
the game folder produces this layout directly:

```text
ACBSP.exe                                      (already installed)
renodx-asscreedbrotherhood-taa.addon32
renodx-asscreedbrotherhood-dlaa/
  renodx-asscreedbrotherhood-dlaa.exe
  nvngx_dlss.dll
  NVIDIA-DLSS-LICENSE.txt
```

Installation instructions should tell users to close the game, install 32-bit
ReShade with addon support for DirectX 9, and extract beside `ACBSP.exe`. An
existing working ReShade installation can be kept. TAA and Object Motion start
enabled; sharpening starts Off. DLAA additionally requires an RTX GPU, native
MSAA Off and a restart after installing the helper. Select DLAA in the addon
panel and check for green active status; DLL Default is the default preset.

A TAA-only download can omit the helper directory. For HDR, users install the
current Ezio Trilogy addon separately. Replace older TAA addon files instead of
leaving duplicate renamed addons installed. For DLAA updates, replace the addon
and helper together. Keep the x64 NVIDIA DLL inside its helper directory.

Exclude game files, ReShade loader/configuration, DevKit, captures, shader dumps,
logs, PDB/LIB/OBJ files and private settings from the mod ZIP. The compiled addon
already embeds its shaders; users do not need HLSL files or the SDK/build tools.

## Verification

The extraction passes native DX9 GPU resolve/motion tests and an isolated
ReShade integration fixture: standalone SDR and HDR integration in both addon
load orders, original resource formats, input decode/restoration, camera jitter,
five matched partial-upload/late/LOD draws, and ResetEx. Immediate fullscreen
draws now pass the 8x -> 4x -> Off -> 8x reset sequence with HDR, standalone
camera-only TAA, and TAA Off. See section 30 of the implementation guide for the
ReShade upload workaround and its regression coverage.

In-game verification after installing the pair:

1. Confirm both addon names in `ReShade.log`; TAA controls appear only in the new
   addon, and HDR controls remain in Ezio Trilogy.
2. With MSAA off, compare TAA Off/On while stationary and panning. Move
   Ezio through a crowd; inspect cloth, hair, trees, bushes, rooftops and sky in Motion Vectors.
3. For developer checks, enable `TAAInputCapture=1` in the configuration. Look for `Brotherhood TAA input capture`, `current=1`,
   `consecutivePair=1`, nonzero `jitterDraws` and `resolve=1` with TAA On and Debug Off.
   `resolve=0` is expected in Depth; motion/history views still accumulate.
   `cameraOnlyDraws` counts confirmed static draws omitted from object replay.
4. Change resolution/fullscreen and MSAA (8x -> 4x -> Off -> 8x), return to
   gameplay, then toggle TAA Off/On.
   Verify output and matching recover. Check menus, cutscenes, loading and HUD.
5. For standalone verification, close the game and temporarily move the HDR
   addon outside the addon search path. Repeat the checks in native SDR. Restore
   the HDR addon while closed to return to the combined configuration.
6. With TAA On and Debug Off, compare Lilium RCAS at 0, 50 and 100. Check fine
   scene detail while stationary and moving, bright highlights and dark areas;
   the HUD should remain unchanged. Check that debug views bypass sharpening
   and that the chosen strength survives a graphics reset.

## Developer documentation

For DLAA testing, set MSAA Off and verify the active status before comparing
stationary roofs, thin geometry, crowd/cloth motion, water and bright HDR colors.
Check Off/TAA/DLAA transitions, RCAS, cuts/loading, focus changes and graphics
resets. Repeat in standalone SDR. NVIDIA feature execution and synthetic GPU
checks alone do not establish moving-scene image quality or performance.

- [IMPLEMENTATION.md](./IMPLEMENTATION.md): current design, formulas, file map,
  shader contracts, motion capture, matching, lifecycle, tests and a porting guide.
- [DEVELOPMENT_HISTORY.md](./DEVELOPMENT_HISTORY.md): preserved investigation
  notes, failed approaches and successive fixes from the embedded prototype.
