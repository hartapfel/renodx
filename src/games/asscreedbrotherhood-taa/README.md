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
| DLAA / Frame Generation / Reflex, with either configuration | Also install the matching `renodx-asscreedbrotherhood-dx12` helper folder; see the runtime installation below |

Close the game before replacing either file. The matching Ezio Trilogy build
has embedded TAA removed. **Do not combine this addon with an older experimental
Ezio build that still contains TAA.** Both would jitter and resolve the same frame.
The two current addons work in either load order. DevKit is optional.

In the ReShade addon settings, open **Assassin's Creed Brotherhood TAA**:

The menu puts gameplay controls first, followed by sharpening, diagnostics,
setup notes, support links and the build timestamp. Include the timestamp when
reporting an issue.

| Section | Control | Default |
| --- | --- | --- |
| Anti-Aliasing | Off / TAA / DLAA dropdown | TAA |
| Anti-Aliasing | DLSS Preset (DLAA only) | DLL Default |
| Frame Generation | Off / 2x / 3x / 4x / 5x / 6x dropdown | Off |
| Reflex and Frame Pacing | NVIDIA Reflex dropdown | On; locked On with FG |
| Reflex and Frame Pacing | Reflex Framerate cap (Before FG) | 0 (no manual cap) |
| Reflex and Frame Pacing | Before/after FG FPS and rendered-frametime graph | Live |
| Sharpening | Lilium RCAS, 0–100 | 0 |
| Debug | Off / Depth / Motion Vectors / History Confidence / History Rejection | Off |

Object motion is automatic; static surfaces use camera reprojection where valid.
There is no motion-source selector. DX12 output starts automatically with the
installed presenter, with or without the HDR addon. Input capture for FG is
automatic and has no toggle.

TAA Off disables accumulation, jitter and debug rendering. The selected debug
view is remembered for the next time TAA is enabled. Depth does not accumulate
history. Motion Vectors, History Confidence and History Rejection keep normal
TAA running underneath. **Motion Vectors** is the only motion preview and follows
the active AA method. It shows the combined vectors selected by the real
resolve: object vectors where required, otherwise camera reprojection from depth.
Neutral gray means still, red/green channels encode horizontal/vertical movement,
and magenta marks invalid reprojection. Intentional jitter is removed from the
displayed vector, yielding the displacement from an output pixel to its history
sample. Correct vectors can point outside the old image; history is still
rejected there. The extra display pass runs only while a diagnostic is selected.

Static buildings with reliable depth can use camera motion. Object vectors are
needed for independent movement and deformation; they also supply depth for
some late materials. For TAA, DLAA and Frame Generation, replay omits confirmed unchanged rigid draws that
write native scene depth. New/ambiguous instances, changed transforms or buffers,
deformation, and late materials retain replay. Capture and classification still
cost CPU time; this is not a claim that all static-scene overhead is eliminated.
Sky uses camera rotation/FOV without translation parallax or finite-depth checks.

Frame Generation receives the same combined camera/object motion as AA. The
experiment replaying all static buildings did not improve the known distant-
building FG artifacts, so its extra replay work has been removed. Existing upload
batching and shader/state caches remain enabled. Those artifacts remain unresolved.

The resolve retains cubic history sampling and motion-responsive weighting.
If a character part briefly loses its previous pose, other directly tracked
parts can supply that character's body/camera motion. This conservative estimate
uses at most four samples of history until full animation tracking resumes.
Ambiguous matches and newly visible whole characters still reset history.

### Sharpening

**Sharpening -> Lilium RCAS** adds optional luminance-based sharpening with
noise suppression to the completed TAA image. The 0-100 slider defaults to 0
(Off); 100 is full strength. It runs before the native/HDR LUT and HUD, works
with automatic motion and optional MSAA, and leaves debug views unsharpened.
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

Install the **unified DX12 helper** beside the addon:

```text
renodx-asscreedbrotherhood-dx12/
  renodx-asscreedbrotherhood-dx12.exe
  streamline/
    sl.interposer.dll
    sl.common.dll
    sl.dlss.dll
    sl.dlss_g.dll
    sl.reflex.dll
    sl.pcl.dll
    nvngx_dlss.dll
    nvngx_dlssg.dll
    (included NVIDIA licenses)
```

Restart after installing, select **Anti-Aliasing → DLAA**, and check for the
green **DLAA active at native resolution (DX12)** status. TAA covers startup
and unavailable DLAA. Failures show red status; switch to TAA and back to retry.
If output itself failed, use Retry DX12 Output. Log: the unified helper's
`renodx-dx12-present.log` (Streamline writes its own log under `streamline/`).

**DLSS Preset** appears when DLAA is selected. **Default** lets NVIDIA choose;
F (legacy), J, K, L and M request explicit presets, subject to runtime/driver
support. A change releases only DLAA resources and resets its history. The
presenter, FG and Reflex keep running. Motion vectors remain automatic.

One hidden x64 process handles DLAA, FG, Reflex and presentation because the
game is x86 and NVIDIA's runtime is x64. They share one DX12 device, direct
queue, DX11 sharing bridge and Streamline initialization. Images stay on the
GPU. The DX11 bridge only transports legacy DX9 textures; reconstruction and
presentation use DX12. The two processing points remain:

```text
DX9 scene/depth/motion → unified helper: DX12 DLAA
  → DX9 RCAS/color grading/HUD → native SDR or RenoDX HDR output
  → same helper/device/queue: DX12 FG, Reflex and presentation
```

DLAA runs before the game's LUT and HUD. FG consumes the completed scene and
HUD information at presentation. Separate Streamline viewport tags prevent
these different color/depth/motion lifetimes from overwriting each other.
DX9Ex is requested when the unified helper is installed. Keep all x64 runtime
DLLs in its `streamline/` directory, never beside the 32-bit game executable.
The old `renodx-asscreedbrotherhood-dlaa` folder is no longer used and can be
removed with the game closed. Update addon and helper together: presentation
protocol 8 carries DLAA requests (payload version 4) on the same IPC channel.

Without the DX12 presenter, standalone exclusive fullscreen supplies the missing
fullscreen display-mode descriptor in ReShade's DX9-to-DX9Ex creation path;
resolution, refresh rate, SDR backbuffer format and VSync remain as requested
by the game. Texture-lock compatibility also handles overlay textures created
outside ReShade's resource tracking, avoiding a null-hook startup crash observed
with RTSS. Both corrections are included in the TAA addon without requiring HDR.

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
tone map or enable HDR. DX12 replaces presentation automatically when its helper
is installed, including standalone SDR. Without that helper, TAA retains native output; DLAA and FG are unavailable. Its
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

## Automatic DX12 output

The matching 64-bit presenter enables DX12 output automatically:

- **Standalone SDR:** the addon copies the completed native DX9 backbuffer,
  including HUD and ReShade overlay, through a private shared BGRA8 texture.
  Game render targets and SDR pixel values stay unchanged.
- **With Ezio Trilogy HDR:** the existing DX11 HDR output feeds the same DX12
  presenter. The standalone path stays inactive in either addon load order.

The game retains DX9 rendering and its input window. Standalone DX12 presentation
uses windowed/borderless output because the child swapchain cannot share display
ownership with an exclusive-fullscreen DX9 swapchain. This is an output bridge,
not a replacement for the game's renderer.

Build the helper with `presentation_helper/build.ps1`. Its game-local CMake
fetches the pinned official Streamline 2.14.1 SDK; pass
`-StreamlineSdkDirectory <absolute-unpacked-sdk-path>` to reuse an existing SDK.
The repository's vendored Streamline is unchanged. Put
`build64-brotherhood-dx12/Release/renodx-asscreedbrotherhood-dx12.exe` inside a folder
named `renodx-asscreedbrotherhood-dx12` beside the addon. It uses Windows' DX11/DX12
runtime and needs no NVIDIA SDK DLLs for ordinary presentation. DLAA, FG and
Reflex use the signed Streamline runtime in this same helper directory.

Check Output Status under Setup and Information. A disabled
child window displays DX12 output while the game retains its input window.
The presenter copies the existing SDR, scRGB or HDR10 pixels and color space;
it applies no tone mapping. The effective VSync request follows the game and
the game's NVIDIA driver profile; see Reflex and frame pacing below. The initial
3840x2160 HDR10 gameplay check passed picture/input/ReShade overlay, Off/On and
an MSAA change. Before/after timing captures showed only helper presentations,
zero dropped frames and sync interval 1; they do not establish limiter or
performance equivalence to DX11.

Successful helper presentation suppresses that frame's native DX9 or DX11 Present.
When DX12 is enabled at launch, the addon first allows a successful visible
native presentation before transferring output ownership. The helper stays
hidden until its first image has completed on the GPU, and updates its child
window size only when the parent's client size changes.
Missing helper, unsupported output, timeout or helper exit closes the child
and restores native output. Use Retry DX12 Output to retry; graphics resets recreate the
session. Logs are in the helper folder's `renodx-dx12-present.log` and ReShade.log.
The prototype adds GPU copies and a synchronous completion acknowledgement;
it is not expected to improve performance by itself.

Frame-generation depth, motion and HUD-less inputs are captured automatically
when FG is selected. Developer input-dump details remain in implementation
section 36; those controls are no longer exposed in the release menu.
Update the addon and presenter together (presentation protocol 8).

### Experimental DLSS Frame Generation and Reflex

**Frame Generation -> DLSS Frame Generation** offers **Off, 2x, 3x, 4x, 5x, 6x**
and defaults to **Off**. The multiplier includes the real frame: 2x generates one,
6x generates five. It queries the runtime's supported maximum, disables unsupported
choices, and reports a persisted unsupported selection without silently downgrading.
Status reports observed presentations. The ReShade overlay can stay open while FG runs.
Modes switch without restarting the helper. FG locks Reflex to On;
frame pacing is controlled in the section below. Required: automatic DX12 output,
native SDR or RenoDX HDR10 output, TAA/DLAA On, Debug Off, supported NVIDIA RTX hardware,
hardware-accelerated GPU scheduling and the optional runtime below. The input
capture needed by FG runs automatically; no capture toggle is required.

Download and unpack NVIDIA's official
[Streamline 2.14.1 SDK](https://github.com/NVIDIA-RTX/Streamline/releases/tag/v2.14.1).
Use `presentation_helper/install-streamline.ps1 -SdkDirectory <unpacked-sdk>`
while the game is closed. It checks the SDK version and production DLL signatures
and copies the runtime and licenses into the helper's `streamline` subdirectory.
Distribute the whole subdirectory with the DX12 helper; do not put these x64 DLLs
beside the 32-bit game executable. The stable TAA/DLAA ZIP remains unchanged.

The HUD-less scene uses the same encoding as final color: unchanged SDR code
values without the HDR addon, or the existing HDR10 conversion with it. Supported game
HUD draws also supply a separate R32F opacity mask for DLSS-G UI recomposition.
The mask accumulates shader alpha on the GPU, independently of game RGB. Unknown
UI shaders/blends or depth/stencil cases fall back to HUD-less inference.
The ReShade overlay remains supported with FG running, but currently uses the
HUD-less inference path because the explicit mask covers only game HUD. It pauses
FG while any ReShade technique renders, when
the game is in the background, or when matching scene/camera inputs are missing.
Original frames continue to display. Keep the overlay open to inspect the live performance panel;
status is green only after the SDK confirms interpolated presentations. Temporary
pauses retain model resources to reduce reactivation stalls; Off releases them.
ReShade effects are left untouched; disable them explicitly if testing FG.

Reflex waits at the native present-return boundary before the next game tick.
The first native BeginScene marks the approximate simulation/render boundary;
this is a retrofit, not an engine-level input or simulation instrumentation.
No measured input-to-photon latency claim is made. The helper retains shared
inputs until NVIDIA's consumption fence completes before allowing reuse.

The original isolated GPU test confirms 2x presentations, pause/resume and valid
camera constants. Initial 4K HDR10 gameplay also confirms
2x generation with Reflex, successful startup, and recovery from Alt-Tab,
DX12 Off/On and a resolution change/restore. The startup flicker was not observed
in that retest. Higher multipliers and DX12 DLAA require their own validation;
see implementation section 39. Broader HUD, motion, reset and frame-pacing
validation is still needed before a public release.
Missing runtime/support preserves original-frame presentation; a worker failure
falls back to native output. Replace the addon and helper together. A protocol mismatch
now reports an explicit version error instead of a generic DX12 failure.

### Reflex and frame pacing

Reflex requires DX12 output and the signed Streamline runtime, and works with
FG Off. The dropdown offers Off, On and On + Boost. Selecting FG locks it to
exactly On; disabling FG restores the saved preference.

**Reflex Framerate cap (Before FG)** limits rendered game frames. A cap of 60
with 3x FG targets 180 output FPS, subject to performance and synchronization.
Ctrl-click to enter an exact value; 0 removes the manual cap. The helper converts
the base interval using the runtime's confirmed presentation count, so paused
FG does not divide the rendered frame rate. There is no second sleep limiter.

There is no user display-ceiling or VSync setting in the addon. The presenter
reads the **game's** effective NVIDIA profile without changing it. Forced driver
VSync On/Off takes precedence; otherwise it follows the game's request.

When that profile allows G-SYNC, the actual display supports VRR, VSync is active
and Reflex is On, the helper automatically reserves 0.3 ms below the monitor's
refresh interval. On 240 Hz this targets about **224 FPS after FG**, including
when the manual cap is 0. The same Reflex limiter applies both limits; whichever
is lower wins. For example, 60 with 3x FG remains about 180 output FPS, while an
uncapped 3x mode targets about 74.6 rendered / 223.9 output FPS on 240 Hz.
The panel shows the automatic ceiling when it is the limiting setting.

Fullscreen-only G-SYNC requires the game window to cover the monitor; windowed
G-SYNC can also use the automatic limit. Driver/display checks run in the
background every five seconds, so they do not stall rendering. The addon does
not enable G-SYNC or change driver settings. This reproduces the expected Reflex
headroom for the separate presenter; a working limit alone does not prove that
the monitor has entered VRR mode. Avoid stacking it with RTSS/NVIDIA FPS caps.

The performance panel shows rendered-frame intervals and average/P95 frametime.
Before FG FPS counts completed game frames over elapsed time. After FG FPS sums
runtime-confirmed presentations over that same interval; it does not multiply
by the selected mode. These are throughput measurements, not measured monitor
scanout or generated-frame timing. Stale samples disappear after a pause; the
history clears on output restart. Native fallback and FG Off show equal rates.

Replace the addon and presenter together: presentation protocol 8 also replaces the separate DLAA worker. It retains removal of the
old display/VSync settings. Old `DX12Output`, `TAAMotionSource`, `ReflexDisplayFPS`,
`DX12VSync` and `FGInputCapture` configuration entries are ignored. Existing AA,
preset, FG, Reflex, cap and sharpening preferences remain intact.

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

Build the unified helper separately using its game-local Release preset:

```powershell
& src/games/asscreedbrotherhood-taa/presentation_helper/build.ps1 -StreamlineSdkDirectory <Streamline-2.14.1-SDK>
& src/games/asscreedbrotherhood-taa/presentation_helper/install-streamline.ps1 -SdkDirectory <Streamline-2.14.1-SDK>
```

Output: `build64-brotherhood-dx12/Release/`. The helper build no longer links
the separate repository DLSS SDK; Streamline owns DLAA and FG together. Its
installer checks NVIDIA production signatures and copies the matching eight
runtime DLLs and licenses. Version 2.14.1 includes DLSS/DLSS-G 310.9.1.

## Third-party helper overlays

The helper renders through a disabled child window while the game retains input
focus. For overlays that subclass this child window, the helper mirrors keyboard
transitions and mouse position/buttons while the game is foreground. It does not
activate the helper window or block the game's controls. Pause the game while
using such a menu; use keyboard navigation for wheel/text operations.

OptiScaler 0.9.4's manual polling requires its exact window to be foreground,
which excludes this child canvas. In its helper-folder `OptiScaler.ini`, use
`OverlayMenu=true` under `[Menu]` and `ManualInputPolling=false` under `[Hotfix]`.
The default menu shortcut is Insert. OptiScaler is optional and not bundled.
This input compatibility does not validate every alternative upscaler/FG backend.

## Packaging a release

Build the addon and unified helper in Release. Stage real file contents:

| Build output | Destination inside the ZIP |
| --- | --- |
| `build32/Release/renodx-asscreedbrotherhood-taa.addon32` | ZIP root |
| `build64-brotherhood-dx12/Release/renodx-asscreedbrotherhood-dx12.exe` | `renodx-asscreedbrotherhood-dx12/` |
| The eight DLLs and three license files installed under `build64-brotherhood-dx12/Release/streamline/` | `renodx-asscreedbrotherhood-dx12/streamline/` |

Include installation instructions, MIT and RCAS notices, source/build identity,
and checksums. Do not archive the build directory: exclude logs, PDB/LIB/OBJ,
test executables, captures, SDK files, ReShade and personal configuration.
Do not package the obsolete DLAA executable or its old helper directory.

Users close the game, install 32-bit ReShade with full addon support for DirectX
9, and extract beside `ACBSP.exe`. Keep an existing working ReShade installation.
Replace addon and unified helper together; remove duplicate renamed addons.
The old `renodx-asscreedbrotherhood-dlaa` folder may be removed after updating.
TAA defaults On; sharpening and Debug default Off. DLAA requires RTX and MSAA
Off; FG requires supported NVIDIA hardware/runtime, TAA or DLAA and Debug Off.
ReShade shader effects pause FG; the settings overlay can remain open.

The current Ezio Trilogy HDR addon is optional and distributed separately.
A TAA-only package may omit the helper, leaving native output and no DLAA/FG.

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
7. With the presenter/runtime installed, test standalone SDR and HDR10 with
   2x/3x FG, Debug Off and no ReShade shader effects. Check active status and
   before/after FPS. On a 240 Hz G-SYNC/VSync display, cap 0 should stay near
   224 output FPS when performance permits. Cap 60 with 3x should stay near 180.
   Repeat after Alt-Tab, a graphics reset and a fresh launch; verify HUD, overlay,
   input and normal process exit.

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
