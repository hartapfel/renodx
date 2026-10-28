# Motion Blur - Remastered

Standalone DX12/x64 motion blur, ported from the current Witcher 3 Classic
`optics/0xF3C20001.ps_5_0.hlsl` and `optics/pipeline.hpp` implementation.
No HDR addon or DevKit is required. See [installation and controls](packaging/README.txt).

## Filter and controls

Enhanced automatically requests the native motion chain on supported game
builds. Native follows the game's saved Motion Blur setting. Enhanced offers
Classic's Camera + Object / Object Only / Off modes and Strength:
0 is sharp, 50 is a 1/60-second exposure, 100 is 1/30 second.
New `ClassicMotionMode` and `ClassicMotionStrength` settings avoid interpreting
old shutter-angle sliders as exposure time.

The replacement uses Classic's reference velocity units and rate bound, five
2x tile-max reductions, a 3x3 neighborhood maximum, half-resolution radius/depth
bake, two McGuire gathers (1 and 1/6 scale), and coverage blend. Intermediate
values round to FP16 as in Classic. Signed RGB and the native output alpha are
preserved. Sample counts, activation curve, depth weights, and exposure scale
follow Classic; the previous expanding/filter quality paths are removed.

DX12 adaptation uses the existing native input bindings and private space 57
root UAV/settings CBV/static sampler. No descriptor heaps or native root
signatures are switched during the replacement. Original native prefilter and
blur stages remain available so a failed allocation, missing input, or unsupported
layout can retain the native resolve. The final replacement uses sharp native
`t1` color, not the already blurred intermediate.

`9F1C32F1` preserves native XY and packs depth losslessly into unused ZW.
A clipped vertex invocation copies b12 depth-projection constants to scratch.
Both native resolve variants (`2B7AF9F0`, `866E78BC`) bound output using b0 c5.xy
plus one, preserving the active viewport inside larger menu texture pools.
The first native conversion per presented frame measures the exposure interval;
additional conversions in the same frame reuse it. New/interrupted timing is sharp.

Two differences from Classic remain explicit:

- Remastered supplies combined motion plus camera reprojection, not Classic's
  previous object positions. Object Only keeps the validated native FP16 camera
  subtraction and visible-trajectory partition. Tracked subjects remain sharp.
- DX12 scratch uses buffers instead of sampled intermediate render textures.
  Float interpolation and native texture subtexel/tie rules can differ at exact
  texel boundaries. This is the Classic filter, not a claim of bit-identical output.
  Remastered also retains its native motion/depth grid and jitter convention.

## Resource lifetime

The previous device-lifetime scratch vector and unbounded immutable-settings
cache are gone. A recording owns every scratch/upload allocation it references.
At reset/destruction, completion fences are signalled on every queue that
executed that recording. ReShade's execute callback precedes submission, so it
is used only to record queue identity, never as proof of GPU completion.

Allocations are reused only after all retirement fences complete. At most two
completed allocations remain cached; idle allocations expire after 120 presents.
Scratch plus upload pages have a hard 768 MiB budget. Budget/allocation failure
keeps native rendering; no CPU fence wait or queue flush is introduced. Failed
queue tracking/signalling quarantines affected allocations within that budget.
Pipeline/root-signature references stay alive with their GPU work. Settings
records are unique per dispatch sequence and recycled with the same fences.

The log reports current/peak scratch bytes, allocation count, resolve count and
frame interval every 300 presents. A stable in-flight working set is expected;
it need not fall to zero while gameplay keeps recording work.

## Build and validation

```powershell
cmake --build --preset clang-x64-release --target thewitcher3remastered-motionblur
```

Close the game before rebuilding its loaded addon. Output:
`build/Release/renodx-thewitcher3remastered-motionblur.addon64`.
Embeds: `0xF3B10000` compute filter, `0x9F1C32F1` native conversion,
`0xF3B10004` camera transfer. Build/package launchers remain available.
The release ZIP includes the optical filter's MIT license.

See [tests/README.md](tests/README.md) for reproducible offline checks.
On 2026-10-28: Release build, 192 Classic comparisons on each of WARP/NVIDIA,
3,000 resource-retirement cycles, and 24 production DXIL frames at 4K passed.
The synthetic RTX 5090 filter median was 0.275 ms with 137.13 MiB per scratch
allocation; this excludes native intermediate work and is not a game FPS measurement.

Live gameplay logged the replacement active alongside HDR, Darker Nights,
Beardmo's Immersive World and DevKit. Scratch returned to 0 MiB in menus and
550.25 MiB during gameplay, with 687.75 MiB peak over approximately 13,560 resolves.
The user confirmed working blur and stable FPS after the menu-transition check.
Resolution changes, save loading and Object Only silhouettes remain runtime checks.

The official HDR DLL exposed a separate DevKit startup/unload failure before blur
execution. Rebuilding HDR masked it and is not the compatibility solution.
DevKit needs independent private/shared utility state when inspecting addons built
against different C++ layouts. Its device-destruction lock must also be released
before deleting the object that owns the mutex. Both fixes are in DevKit; the
official HDR binary is preserved, and the user confirmed gameplay with it. No rebase or loss of local custom work is needed.
