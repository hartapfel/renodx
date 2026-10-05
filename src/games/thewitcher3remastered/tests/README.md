# Mod validation

## Native night lighting

`night_lighting.cpp` exercises the native view and constant callbacks against
independent references of the audited renderer stores. Its 180 cases cover
raster/shared directional colors, fog, haze, sky, clouds and native water
color/ambient/diffuse constants across clock fade
endpoints and weather weights, including the captured storm's residual skylight.
It checks RGB-only edits, exact neutral/daytime identity, invalid time, weather
independence and skylight baseline restoration/rebasing. Zero skylight must reach
exactly zero at full night even when weather retains a nonzero day weight.
Two whole-buffer comparisons verify cloud isolation, untouched moon/star colors
and alpha, and midday identity. Water checks preserve all other global-buffer
bytes, including Fresnel/caustics/foam fields. Removed grass/moon/grading controls have no runtime
backing state. The harness does not establish the live hook ABI, engine time
semantics, or broad scene coverage.

From an x64 Visual Studio developer shell:

```powershell
clang-cl /std:c++20 /EHsc /O2 /MT /DNOMINMAX /Iexternal/Detours/include src/games/thewitcher3remastered/tests/night_lighting.cpp /Fe:tmp/witcher-night-test.exe /Fo:tmp/witcher-night-test.obj /link external/Detours/lib.X64/detours.lib
./tmp/witcher-night-test.exe
```

## Motion blur

The four `0xF3B1000*` shaders are private compute passes, not game shader hashes.
`motion_blur.hpp` captures depth at `0x9F1C32F1` and runs TileMax, NeighborMax and
full-resolution reconstruction at `0x866E78BC` or intensity-10 `0x2B7AF9F0`.
Missing inputs fall back to the native dispatch. Gameplay loading, the 0/180-degree
shutter response, stationary-character protection and unchanged blur at native
intensity 1 versus 10 were confirmed after the resource-tracker initialization
fix. Earlier visual FPS comparisons were inconclusive after further testing.
A measured 30 versus CPU-limited 40-45 FPS comparison is consistent with
per-frame motion scaling; a strong-pan capture separately found 84.2% of sampled
pixels hitting the fixed 32-pixel radius ceiling. See the mod README for the
measurements and their limitations. GPU usage was reported roughly unchanged at
a 30 FPS cap; isolated GPU timing and broader scene coverage remain untested.

`motion_blur.cpp` runs the same HLSL on D3D11 WARP (compiled as `cs_5_0`) to check
stationary identity, signed HDR preservation, full-resolution one-pixel detail,
30/60/120/240 FPS shutter response, static-foreground occlusion, and moving-edge
coverage against an analytical temporal reference. The camera-pan regression
gives separate surfaces identical screen motion, then varies their depths:
their output must match the equal-depth reconstruction. Before the correction,
this produced up to 0.351 error and an artificially sharp foreground edge;
motion-aware occlusion weighting eliminates that difference without changing
the stationary-foreground test. All 26 cases / 7,697,690 pixels pass. The user
confirmed the earlier camera-edge correction and the improved unclamped
revision in-game after rebuilding. Isolated GPU timing remains unmeasured. Shipping compilation uses
`cs_6_6` with strict diagnostics. These tests do not establish game velocity
units, resource lifetime safety, native-intensity independence, or GPU cost.

From an x64 Visual Studio developer shell at the repository root:

```powershell
foreach ($id in 'F3B10000','F3B10001','F3B10002') {
  ./bin/fxc.exe /nologo /T cs_5_0 /E main /Ges /WX /O3 /Fo "tmp/$id.cso" "src/games/thewitcher3remastered/effects/0x$id.cs_6_6.hlsl"
}
clang-cl /std:c++20 /EHsc /O2 /MT src/games/thewitcher3remastered/tests/motion_blur.cpp /Fe:tmp/witcher-motion-test.exe /Fo:tmp/witcher-motion-test.obj /link d3d11.lib
./tmp/witcher-motion-test.exe tmp/F3B10000.cso tmp/F3B10001.cso tmp/F3B10002.cso
```

`motion_runtime.cpp` checks the real module attach/detach path with a minimal
ReShade event host. It verifies that resource tracking is initialized before
the lookup used by the compute replacement, then checks detach and reattach.
This reproduces the missing-dependency condition behind the loading/enabling
crashes without launching the game. It does not simulate D3D12 execution.

```powershell
clang-cl /std:c++20 /EHsc /O2 /MT /DNOMINMAX /DWIN32=1 /Iexternal/reshade /Iexternal/gtl/include /Iexternal/Detours/include /Iexternal/json/include /Iexternal/frozen/include src/games/thewitcher3remastered/tests/motion_runtime.cpp /Fe:tmp/witcher-motion-runtime-test.exe /Fo:tmp/witcher-motion-runtime-test.obj
./tmp/witcher-motion-runtime-test.exe
```

Algorithm references:

- [McGuire et al., A Reconstruction Filter for Plausible Motion Blur (2012)](https://casual-effects.com/research/McGuire2012Blur/index.html): full-resolution color/depth/velocity, TileMax/NeighborMax and depth-aware reconstruction.
- [Guertin et al., A Fast and Stable Feature-Aware Motion Blur Filter (2013 report)](https://research.nvidia.com/sites/default/files/pubs/2013-11_A-Fast-and/Guertin2013MotionBlur-small.pdf): local and dominant directions, relative depth weighting, feature alignment and tile-boundary treatment.

For true per-frame UV displacement, a 180-degree shutter has half-width
`0.25 * velocityUV * outputSize`. Frame-rate dependence is already in displacement;
multiplying by frame duration again would incorrectly apply it twice. The game
input must be measured before this convention is used at runtime.


The long-trail regression uses 240/120/40-pixel shutter radii for fixed movement
at 30/60/180 FPS: all exceeded the former 32-pixel ceiling. It compares impulse
spread with an analytical box shutter and requires continuous one-pixel HDR
trails. Additional cases check a moving silhouette reaching beyond a 3x3 tile
neighborhood, stationary foreground protection during long background motion,
axis-parallel/diagonal viewport clipping, HDR constants, and zero shutter.
Mutation checks in tmp/thewitcher3remastered/motion-blur/ceiling-regression/
confirm separate failures when restoring either the clamp or the limited
neighbor search. These synthetic tests establish filter behavior, not live
engine timing or hardware performance.


## Video color decoding

`video.cpp` accepts three ps_5_0 binaries: the mechanically transcoded original
SM5.1 video decoder, its compiled decompiler baseline, and the production
BT.709 replacement. The shader's static t0-t2/s0-s2 binding ranges and executable
operations survive this profile conversion; the native archive README records
the decompilation workaround. The harness uses a matching vertex signature and
D3D11 WARP to compare 589,824 pixels across three opacity values, full code-range
YCbCr combinations, and independently encoded black/white/grey/color bars.
It checks the baseline against native bytecode and BT.709 against the coding
equations in ITU-R BT.709-6, sections 3.2-3.4. Maximum errors are 0, 3.36e-7 and
1.20e-7 respectively; alpha matches exactly. Shipping compilation is ps_5_1.

Build the harness from an x64 Visual Studio developer shell:

```powershell
bin/fxc.exe /nologo /T ps_5_0 /E main /Ges /WX /O3 /Fo tmp/video-baseline.cso src/games/thewitcher3remastered/native/video/0x7EF4001F.ps_5_1.hlsl.original
bin/fxc.exe /nologo /T ps_5_0 /E main /Ges /WX /O3 /Fo tmp/video-bt709.cso src/games/thewitcher3remastered/video/0x7EF4001F.ps_5_1.hlsl
clang-cl /std:c++20 /EHsc /O2 /MT src/games/thewitcher3remastered/tests/video.cpp /Fe:tmp/video-test.exe /Fo:tmp/video-test.obj /link d3d11.lib d3dcompiler.lib
./tmp/video-test.exe tmp/thewitcher3remastered/video/video-sm50.shdr tmp/video-baseline.cso tmp/video-bt709.cso
```


## Video brightness and AutoHDR

`prepare_video_hdr.py` copies the production shaders into a scratch directory,
remaps b13/space50 to b13 and t0/space51 to t3 for D3D11, and wraps the actual
normal/FG pixel entry points as compute shaders. `video_hdr.cpp` exercises the
whole output pipeline, including PQ encoding and both secondary outputs.
No production arithmetic is replaced by a test model.

The 972 configurations cover three peak/game/UI brightness values, both video
modes and gamut targets, grayscale/color ramps, and transparent/partial/opaque
video and UI. Checks include independent video/UI brightness, black/white
endpoints, linear fades, gray ordering (within 0.02-nit native PQ roundoff),
normal/FG primary and secondary parity, scene-only isolation and the combined
FG video/UI coverage mask. 995,328 pixel outputs pass; maximum endpoint error
is 0.236 nit, with exact output parity. These are software-GPU checks, not a
substitute for verifying playback, callbacks, resource lifetime and gameplay.

From an x64 Visual Studio developer shell:

```powershell
python src/games/thewitcher3remastered/tests/prepare_video_hdr.py tmp/witcher-video-hdr
bin/fxc.exe /nologo /T cs_5_0 /E main /Ges /WX /O3 /Fo tmp/witcher-video-hdr/normal.cso tmp/witcher-video-hdr/output/0x8F5737B5.ps_6_6.hlsl
bin/fxc.exe /nologo /T cs_5_0 /E main /Ges /WX /O3 /Fo tmp/witcher-video-hdr/fg.cso tmp/witcher-video-hdr/output/0x496222DA.ps_6_6.hlsl
clang-cl /std:c++20 /EHsc /O2 /MT src/games/thewitcher3remastered/tests/video_hdr.cpp /Fe:tmp/witcher-video-hdr/check.exe /Fo:tmp/witcher-video-hdr/check.obj /link d3d11.lib
./tmp/witcher-video-hdr/check.exe tmp/witcher-video-hdr/normal.cso tmp/witcher-video-hdr/fg.cso
```

Night Sky Brightness also covers b12 c249/c278, the two native colors added
by 3B15DAAB after its main sky/fog calculation. The night-lighting harness
includes them in the 180 clock/intensity/weather cases and checks whole-buffer
sky-only isolation at midnight and midday, preserving alpha, moon colors, fog
and cloud base colors. The shared c278 distant-cloud tint intentionally follows
the sky control. Runtime horizon verification remains necessary after rebuilding.
