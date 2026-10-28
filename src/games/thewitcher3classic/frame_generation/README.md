# Classic DX11 to DX12 DLSS Frame Generation

Implementation and verification, 2026-10-28. **The integrated Release addon runs
DLSS Frame Generation in Classic gameplay alongside DX11 DLAA.** The live RTX
5090 run reported two displayed frames per rendered frame, DLSSG status 0, and
NVIDIA's interpolation-enabled event. Standalone hardware tests also exercise
4x, 6x, Auto and Dynamic. This establishes execution, not a measured game
performance improvement or complete HDR/HUD visual acceptance.

## Installation and controls

Build the `thewitcher3classic` target with the established `clang-x64-release`
preset. Install the official matching SDK using
`frame_generation/install-sdk.ps1 -SdkDirectory <absolute-SDK-directory>`.
This verifies signatures and installs into ignored `bin/streamline-2.14.16`;
it does not update shared dependencies or global CMake settings.

With the game closed, run
`frame_generation/deploy-runtime.ps1 -GameDirectory <game-bin/x64-directory>`.
It verifies and deploys six NVIDIA DLLs into `renodx-frame-generation` beside
`witcher3.exe`. It leaves the existing SR `nvngx_dlss.dll` untouched. The local
game is at `E:/SteamLibrary/steamapps/common/The Witcher 3/bin/x64`; its addon
link targets this workspace's `build/Release`.

The existing DLSS menu contains Frame Generation mode (Off/Fixed/Auto/Dynamic),
total multiplier, Dynamic target rate, and Standard/Enhanced HUD recomposition.
Factors are bounded by runtime capabilities, up to 6x in this version. Dynamic
uses its target rather than the fixed multiplier. The displayed status reports
suspension and the last runtime-reported displayed-frame count. NVIDIA driver
overrides may change effective behavior.

The DX12 presentation bridge initializes at startup independently of the FG
setting. First-run/default FG mode is Off; saved mode, multiplier, target rate
and HUD quality are restored on subsequent launches. With DLSS/DLAA, HDR10 and
windowed/borderless mode active, FG can be enabled or disabled during gameplay
without restarting. Off skips scene/HUD capture and copies only final color;
the presentation bridge and Reflex remain active for live enabling. Retained
resources are released on shutdown. scRGB and exclusive fullscreen are unsupported. Missing
inputs, unrecognized HUD writes, ReShade overlay or active ReShade techniques
suspend generation while real frames continue. Capture now starts at the
completed scene copy after SR/final grading, even when the in-game HUD is hidden;
frames without HUD draws retain zero UI alpha. The user verified that FG stays
active with the in-game HUD hidden.

There is no public A/B/C FG model-preset enum in the pinned SDK. HUD quality
controls the documented recomposition option; it does not pretend to select an
FG model. Model selection remains an NVIDIA App/driver override. This distinction
is shown in the menu.

## Implemented pipeline

```text
DX11 scene -> existing DLSS/DLAA -> effects/final grade -> pre-HUD capture
                    |                                      |
             retain depth/motion                      original UI draws
                                                           |
                             matching RenoDX PQ encode + R8 coverage
                                                           |
                           same-adapter shared textures + producer fence
                                                           |
                  DX12 direct queue -> Streamline flip swapchain -> HDR10
                                                           |
                       SDK input-completion fence -> reusable input slot
```

- `factory.hpp` intercepts verified system DXGI factory methods below ReShade,
  outside DllMain, for Classic's `W2ViewportClass` only. Initialization failure
  releases display ownership before native fallback. Direct-NGX DX11 SR and
  the isolated DX12 FG session have run together in the live game.
- `swapchain.hpp` exposes the stable single DX11 backbuffer and DX11 device the
  game expects. The sole native display swapchain belongs to DX12. Present and
  resize are serialized. `runtime.hpp` preserves this logical single-buffer
  contract after RenoDX's generic create/resize callback; otherwise that
  callback requests a second DX11 buffer that the facade cannot expose.
- `presenter.hpp` uses the same adapter, manual Streamline device/factory
  upgrade, direct queue, three flip buffers, per-slot command allocators and
  frame-based tags. It handles render-resolution changes, real-frame fallback,
  input retirement, null tagging/freeing, resize and shutdown. HDR10 color
  space is explicitly restored after ResizeBuffers.
- `interop.hpp` has three reusable shared-input slots: RGB10A2 final color,
  RGB10A2 HUD-less color, R32 depth, signed RG16F motion and R8 UI alpha. DX11
  copies and signals once, followed by one Flush; DX12 queues a GPU wait.
  Resources return to COMMON and retire behind Streamline's input-completion
  fence, not merely the application's copy fence. Normal acquire does not
  block the CPU; ring exhaustion uses bounded fence backpressure. Off/suspended
  frames copy only final color. No per-frame GPU readback is used.
- `capture.hpp` and three UI replacements preserve target-0 output and add
  source-over coverage to an independent R8 target without replaying draws.
  The completed scene copy captures the actual pre-HUD destination; the first
  recognized UI draw remains a fallback capture boundary. The
  same RenoDX output shader encodes HUD-less and final scene color. Unknown
  writes, blends or destination changes invalidate the capture.
- **Diagnostics > Advanced Diagnostics > Capture Frame Generation Inputs**
  saves two complete FG input sets after closing the ReShade overlay. Files go
  to `renodx-frame-generation-logs/inputs-<tick>` beside the executable. Each
  texture starts with four little-endian uint32 values (width, height, DXGI
  format, row pitch), followed by pitched rows. Texture indices are final
  color, HUDless color, depth, motion, UI alpha; constants use the pinned x64
  `sl::Constants` layout. Run `tests/analyze_frame_generation_inputs.py` on the
  directory to check alpha coverage and PQ differences outside UI. Readbacks
  deliberately stall those two frames; they are disabled during normal play.
- `distortion.hpp` supplies NVIDIA's optional bidirectional distortion field
  for Custom CA. The effect includes geometric zoom/warping, not only color
  fringing: its post-effect color silhouette no longer matches undistorted
  depth/motion without this field. RG maps distorted UV to undistorted UV;
  BA supplies the inverse, in the same normalized units as motion. The shared
  `effects/lens_mapping.hlsli` keeps the authored color and FG geometry identical.
  Green defines the geometric map; channel-specific red/blue dispersion remains
  part of the color effect because the SDK accepts one geometric mapping.
  The field is signed RGBA16F at half output width/height, per NVIDIA's guide.
  It is generated and copied only on lens-setting/resolution changes, with input
  retirement before rewriting. A single shared field is reused across frames;
  no per-frame distortion calculation/copy or three-slot field duplication.
  CA-off submits a null distortion tag. At 4K this adds about 31.6 MiB for the
  DX11 field and its shared DX12 copy, allocated only after the effect is used.
- `camera.hpp` converts verified native unjittered matrices/pose/jitter to SL
  reversed-depth conventions. It does not use the earlier pre-grade SR color
  as HUD-less input. Discontinuous frame history, large position/orientation
  changes and invalid matrices reset or suspend temporal generation.

The observed live capture has grade at draw 2776, scene copy at 2777, UI at
2778..2803 and output at 2804. UI shaders are `C38B68F9` (glyph), `D7880DBE`
(textured), and `7560E408` (vertex alpha). The radial-menu capture extends
coverage with `F1A79FBF` (solid color/vertex opacity), `72826F5B` (transformed
vertex color/opacity), and `CC0C2DF3` (texture/vertex opacity). Gameplay icons
after closing the menu additionally use `D98FBA78` (texture color/alpha).
The subsequent full-dump audit covers 198 Scaleform UI pixel shaders, including
solid, texture, vertex-opacity, multi-texture, blur/filter and shadow variants.
Registration and recognition share a sorted table in `ui_shaders.hpp`. Seven
existing video HDR adaptations retain their separate path; video frames without
valid gameplay inputs still suspend FG. Shaders absent from the dump remain
outside this verified coverage.
Matrices use b10 VP[5..8], inverse VP[13..16], projection[21..24], reprojection
[78..81], with b12[22].xy=(-1,1). For row vectors,
`Praw=Pgame*Zflip`, `Rraw=Zflip*Rgame*Zflip`.

## Native simulation and Reflex integration

`engine.hpp` fingerprints the supported 1.32 executable and each hook's
instruction prefix before installing all hooks in one Detours transaction:

| Boundary | RVA | Role |
| --- | --- | --- |
| Outer-loop message pump | `0x36D0` | New SL token, Reflex sleep, simulation start, PCL ping processing before native input pump |
| Running-state tick | `0x3050` | Identify gameplay simulation and close unfinished simulation markers |
| World-render command constructor | `0x147830` | End simulation before queue publication; associate token with the actual command |
| World-render command Execute | `0xBC62D0` | Consume matching command token and begin render submission on the worker |
| Facade Present capture | addon | End render submission, then bracket presentation using that same token |

These addresses come from local native-code analysis, not vendor documentation.
Executable SHA-256:
`5112253787FBD927ECB979207EFB91B99BCC9C7B041106B51285136BAB41E1F7`,
PE timestamp `0x5BDF65B7`, image size `0x3673000`.
The outer state loop at `0x446A0` pumps messages before the running-state tick;
the render command's enqueue method is `0x145D60`. Command identity, not the
latest simulation number, carries the token across the worker queue. Bounded
storage, session epochs, one-shot consumption and token-ID checks reject
unknown, old or recycled tokens. Session detach serializes against sleep and
markers before the presenter shuts down Streamline.

PCL options target the actual pump thread. Only the configured NVIDIA ping
message is removed and marked for the current simulation; unrelated input
stays with the game's pump. The removed/deprecated InputSample marker is not
used. Reflex is enabled while the FG presentation session exists. Cross-device
latency/pacing still needs NVIDIA validation and measurements.

The native camera upload spans adjacent readable VirtualQuery regions with
different page attributes in the live process. `temporal/camera.hpp` now checks
each covered region instead of incorrectly requiring one region for the whole
object. This corrected the false executable-verification failure seen during
initial live startup.

## Research and API contracts

The pinned public release is [Streamline 2.14.16](https://github.com/NVIDIA-RTX/Streamline/releases/tag/v2.14.16)
(2026-10-16), with FG DLL **310.9.16.0**. Matching headers/runtime are required.
The RTX 5090 reported five maximum generated frames (six total), Dynamic
support, Reflex availability and minimum dimension 100. Limits are queried,
not inferred from GPU names. Signed installed NVIDIA overrides were used.

Primary implementation sources:

- [NVIDIA FG guide](https://github.com/NVIDIA-RTX/Streamline/blob/v2.14.16/docs/ProgrammingGuideDLSS_G.md)
  and [public FG header](https://github.com/NVIDIA-RTX/Streamline/blob/v2.14.16/include/sl_dlss_g.h):
  HDR10/PQ inputs, tags/lifetimes, options v5, state v4, MFG modes and completion fences.
- [Manual hooking](https://github.com/NVIDIA-RTX/Streamline/blob/v2.14.16/docs/ProgrammingGuideManualHooking.md)
  and [native-interface implementation](https://github.com/NVIDIA-RTX/Streamline/blob/v2.14.16/source/core/sl.api/sl.cpp):
  dedicated proxy device/factory and owned native interface references.
- [Reflex](https://github.com/NVIDIA-RTX/Streamline/blob/v2.14.16/docs/ProgrammingGuideReflex.md)
  and [PCL](https://github.com/NVIDIA-RTX/Streamline/blob/v2.14.16/docs/ProgrammingGuidePCL.md):
  sleep, real simulation/render/present boundaries and matching input-ping tokens.
- [Microsoft DX12 interop](https://learn.microsoft.com/en-us/windows/win32/direct3d12/direct3d-12-with-direct3d-11--direct-2d-and-gdi),
  [resource heaps](https://microsoft.github.io/DirectX-Specs/d3d/ResourceHeaps.html),
  and [DX11 Signal](https://learn.microsoft.com/en-us/windows/win32/api/d3d11_3/nf-d3d11_3-id3d11devicecontext4-signal):
  same-adapter shared textures and explicit producer/consumer synchronization.
- [CreateSwapChainForHwnd](https://learn.microsoft.com/en-us/windows/win32/api/dxgi1_2/nf-dxgi1_2-idxgifactory2-createswapchainforhwnd):
  DX12 direct queue and sole flip-swapchain ownership per HWND.
- [Microsoft HDR](https://learn.microsoft.com/en-us/windows/win32/direct3darticles/high-dynamic-range):
  RGB10A2 paired with `RGB_FULL_G2084_NONE_P2020`; no scRGB reinterpretation.
- [Independent blending](https://learn.microsoft.com/en-us/windows/win32/direct3d11/d3d10-graphics-programming-guide-blend-state):
  actual UI source-over coverage `A+(1-A)*previousA`, not color-difference alpha.
- [VirtualQuery](https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualquery):
  region boundaries describe page attributes, not the extent of an application object.

This is a custom DX11/DX12 interop integration, not NVIDIA certification.
The two earlier Classic threads and existing HDR, temporal and lighting
handoffs were reconciled before implementation; accepted lighting work remains.

## Verification and remaining acceptance

### Ghosting correction, 2026-10-28

The live two-frame input capture `inputs-30720843` showed zero UI alpha with
the HUD hidden and bit-identical final/HUDless PQ color around Geralt. Camera
motion agreed with the submitted reprojection; dynamic object vectors contained
Geralt's silhouette. Overlaying depth on color revealed the Custom CA lens
displacement. Disabling CA removed the ghosting in the user's A/B check.
After deploying the distortion-field correction, the user re-enabled Custom CA
and reported **"Ghosting is gone"** in the same scene.

The WARP distortion fixture checks forward mapping, inverse composition,
finite signed FP16 output and cache reuse at 16:9 and ultrawide, intensity 0..5.
At intensity 0.5, maximum error is below 0.06 output pixels at 4K; the full tested
range remains below 0.5 pixels. Hardware/WARP interop regressions pass.
The signed-SDK presenter generated frames with the field and exercised changing
and removing it. Window focus was lost during the extended multiplier test;
the new run is **not** a completed all-multiplier regression. Live game FG runs
with the correction. The original standalone factor tests remain documented below.

Effect-input audit: final grading, bloom, sharpening, grain, DOF and motion blur
are included in both the pre-HUD scene and final output; they have no separate
mandatory FG tags. Custom CA's geometric mapping is now explicitly tagged,
while depth/motion remain undistorted as NVIDIA requires. This is not exhaustive
visual acceptance for native screen warps, strong blur, transparent particles
or water/refraction. NVIDIA also recommends reducing motion-blur distance when
FG is enabled; automatic shutter reduction is not implemented by this fix.

- Full `thewitcher3classic` Release target builds and links; 37 existing
  deprecation warnings. Signed runtime deployed separately from SR.
- Live Classic/RTX 5090: native DX11 DLAA at 3840x2160, FG Fixed 2x active,
  two displayed frames reported, runtime status 0. Initial game startup resize
  works after the logical-buffer correction. Evidence is in
  `tmp/witcher3classic-fg/live-active-first*.log`. The final Release build repeats
  this result at 16:48:04 in `live-final.log` and `live-final-sl.log`, including
  PCL ping integration and the HDR resize fix. The game was left closed with
  Fixed 2x saved; the original configuration backup is
  `tmp/witcher3classic-fg/ReShade-before-live-test.ini`.
- Engine fixture: two queued simulations retain their own worker tokens,
  marker ordering, unknown commands, one-shot consumption, session invalidation,
  recycled-token rejection and actual queued PCL ping dispatch.
- Hardware and WARP transport fixtures: every byte of all five formats across
  three queued frames, full 10-bit range, negative motion, invalid resources,
  delayed consumption, backpressure and safe reuse.
- Signed-SDK presenter: 90 synthetic rendered frames produced 179/360/540
  displayed frames at 2x/4x/6x, 180 in Auto and 100 in Dynamic; render-resolution
  change succeeds. Counts prove generation, not Classic speed or latency.
- DX11 facade: COM/device identity, stable backbuffer, same HWND, HDR private
  data, outstanding-reference resize rejection, successful resize and orderly
  standalone shutdown. Final regression is `facade-final.log`.
- Original-DXBC HUD comparison: target-0 bit exact for all three shaders,
  overlapping alpha code 168, independent PQ reference within two RGB10 codes,
  state restoration and unsupported-draw rejection.
- Camera fixture: pose/FOV, reversed-depth mapping, inverses, reprojection and
  invalid-camera rejection. Native projection quantization yields far plane
  near 4993 versus nominal 5000; original matrices are retained.

The D3D12 debug layer was unavailable. Startup SDK logs include generic
present-thread, zero-extent fallback and runtime-owned clone-alignment warnings;
this is not a warning-free NVIDIA validation run. The automated live run could
not reliably invoke pause/quit through injected keys and was stopped after
capturing logs; orderly **game** shutdown and interactive menu acceptance remain
unverified, even though standalone shutdown passes.

Remaining QA: moving cameras/cuts, combat, transparency, all HUD/menu/cutscene
families, UI-less scenes, BlitzFX coexistence, enhanced HUD, overlay/effects,
alt-tab/display changes, HDR luminance comparison and normal game exit. Measure
native baseline, bridge-only, fixed factors and Dynamic in matched CPU/GPU-bound
scenes, including rendered/presented FPS, 1% lows, latency, VRAM and fence stalls.
DevKit is enabled, so current live observations are not clean performance data.

Three input slots cost approximately 298 MiB at 4K output/1440p rendering or
403 MiB at native 4K, before alignment and NVIDIA allocations. The five-input
copy payload is about 99 MiB per rendered Quality frame, before read/write
bandwidth and presentation copy. Direct capture into shared textures is a
possible measured optimization; current implementation prioritizes proven
format/state/lifetime contracts. See [fixture instructions](../tests/README.md#frame-generation-foundation).

## Radial-menu UI coverage correction (2026-10-28)

The live failure log reported `Waiting for a complete scene and HUD frame`,
with Streamline status 0 and valid simulation/render handoff. The radial
capture had final grade at draw 2825, UI at 2827..2889, and output at 2890.
All visible UI draws used source-alpha / inverse-source-alpha blending.
Three previously unsupported UI shaders rejected the capture. Stencil draws
2833/2834 used `B95A4E01` with render-target write mask 0; rejecting those
was also incorrect. The post-menu capture showed `D98FBA78` icon draws
interspersed with glyphs, explaining rejection after the radial menu closed.
Raw captures and original bytecode are in `tmp/witcher3classic-fg/radial/`
and `radial-after-draws.jsonl` (local evidence, not distributed).

The full UI family preserves native target-0 output and emits source alpha
to the existing R8 coverage attachment in the same draw. Unknown draws
still invalidate capture if they write its destination; zero-write-mask draws
leave the frame valid. Known UI shaders with zero write mask also skip coverage.
The restored vanilla-HUD capture additionally showed filtered UI (`625AF8B9`,
`2C49003F`, `335B9229`), including a 416-pixel offscreen filter surface. Known
UI draws on other destinations now leave the main capture untouched, even if
their dimensions match. Depth/stencil state remains native, so clipping applies
equally to color and coverage. Recognition uses binary search over the sorted
shader table. There is no extra draw, per-frame texture allocation, or readback.
Simulation, camera/depth/motion, menu/loading and display-transition safeguards
remain in effect; a valid subsequent frame can resume generation immediately.

This follows [NVIDIA's FG input contract, sections 5.1/5.2](https://github.com/NVIDIA-RTX/Streamline/blob/v2.14.16/docs/ProgrammingGuideDLSS_G.md)
(pre-UI scene plus accurate UI alpha; invalid inputs must not be submitted),
and the [D3D11 render-target write-mask contract](https://learn.microsoft.com/en-us/windows/win32/api/d3d11/ns-d3d11-d3d11_render_target_blend_desc).
The WARP UI-family fixture compares all 198 shader replacements against original
game DXBC across three patterned texture/constant cases: all passed, with zero
FP32 color error and exact source-alpha coverage. The separate HUD integration
fixture verifies accumulated R8 alpha (243), HDR10/PQ encoding, zero-write-mask
preservation, equal-size/smaller offscreen target isolation, unknown-color-write
rejection and next-frame recovery. The family source is derived from the local
700-pixel-shader dump, not inferred from UI element names. Release shader/object
compilation passed. Live open/close and visual confirmation with the new DLL
are still required.

### Additive HUD fallback

The first expanded build still rejected HUD-on frames. A one-shot hardware
watchpoint on `Capture::rejected_` proved the native draw used
`SRC_ALPHA, ONE, ADD` (additive color); this was the unsupported-blend branch,
not missing camera or NVIDIA runtime failure. The reference capture and trace
are `tmp/witcher3classic-fg/hud-rejection-watch.log` and
`full-ui-live-draws.jsonl`. The initial broad-family tests checked shader
outputs but did not exercise this blend, which the added HUD regression does.

Scene validity and optional alpha validity are now separate. Capture the
pre-UI scene before the first recognized color-writing UI draw, including an
additive draw. A non-source-over blend marks only that frame's alpha incomplete;
later UI must not recapture the already composited scene. At Present, submit
the valid scene/depth/motion/camera, explicitly null the UIAlpha tag, and disable
UI recomposition for that frame. Skip the unused alpha interop copy. Source-over
alpha/recomposition resume automatically on the next complete frame. Unknown
writes that could invalidate the scene still suspend generation. This uses
NVIDIA section 5.1's optional UI input contract; it does not fabricate opacity
for additive pixels. UI interpolation quality on fallback frames remains a
live visual acceptance item.

WARP verifies the additive first-draw case, preserved pre-UI HDR10 output,
no later recapture, and next-frame alpha recovery. The real NVIDIA presenter
fixture passed Off/2x/Off/3x on one swapchain with UI alpha removed/restored
mid-run: 60 and 90 displayed frames from 30 rendered fallback frames at 2x and
3x respectively. It asserts recomposition disables without alpha and restores
with alpha. The debug layer was unavailable; this was hardware validation.

Live acceptance: after the additive-HUD Release build was linked and packaged,
the user toggled the full vanilla HUD off/on and opened/closed the radial
menu. They confirmed FG remained active and Geralt/HUD visuals looked
correct ("yes, perfect", 2026-10-28). This supersedes the pending live
acceptance above for those scenarios; other unseen UI paths are not certified.
