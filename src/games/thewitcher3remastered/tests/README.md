# Motion blur validation

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
