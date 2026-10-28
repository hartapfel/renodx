# Motion blur verification

Build the Release addon first. Run from the repository root in the configured
x64 Clang developer environment. Do not define NDEBUG for assertion-based tests.

```powershell
clang-cl /std:c++20 /EHsc /O2 /DNOMINMAX /Ibuild/thewitcher3classic.include src/games/thewitcher3remastered-motionblur/tests/classic_filter.cpp /Fe:tmp/classic-filter.exe /Fo:tmp/classic-filter.obj /link d3d11.lib dxgi.lib d3dcompiler.lib user32.lib
./tmp/classic-filter.exe
./tmp/classic-filter.exe --hardware
clang-cl /std:c++20 /EHsc /O2 /DNOMINMAX src/games/thewitcher3remastered-motionblur/tests/resource_lifetime.cpp /Fe:tmp/motion-lifetime.exe /Fo:tmp/motion-lifetime.obj /link d3d12.lib dxgi.lib
./tmp/motion-lifetime.exe
clang-cl /std:c++20 /EHsc /O2 src/games/thewitcher3remastered-motionblur/tests/dx12_filter.cpp /Fe:tmp/motion-dx12.exe /Fo:tmp/motion-dx12.obj /link d3d12.lib dxgi.lib
./tmp/motion-dx12.exe
clang-cl /std:c++20 /EHsc /O2 /DNOMINMAX /Iexternal/reshade src/games/thewitcher3remastered-motionblur/tests/motion_runtime.cpp /Fe:tmp/motion-runtime.exe /Fo:tmp/motion-runtime.obj /link user32.lib
./tmp/motion-runtime.exe
clang-cl /std:c++20 /EHsc /O2 /DNOMINMAX /Iexternal/Detours/include src/games/thewitcher3remastered-motionblur/tests/motion_activation.cpp /Fe:tmp/motion-activation.exe /Fo:tmp/motion-activation.obj /link external/Detours/lib.X64/detours.lib
./tmp/motion-activation.exe '<path-to-witcher3.exe>'
```

`classic_filter.cpp` reuses the unchanged Classic pipeline fixture as the reference,
with its Release embeds. The candidate is compiled from the shipping HLSL with
private registers remapped for SM5. It covers 192 cases / 2,952,640 pixels per
adapter: even/odd dimensions, render/output resolution differences, signed HDR,
zero strength/motion, full/object-only motion, camera-follow cancellation, depth
edges and 30/60/120/240 FPS. The shader math is unchanged by the register remap.
Hardware texture interpolation and explicit buffer interpolation are not bitwise
identical. The narrow synthetic velocity-boundary tie region has its peak reported
separately and remains included in mean error. NVIDIA peak there was 7.27734 on a
16-unit thin emitter; away from it peak error was 0.02344, overall mean 0.000797.
WARP peak was 0.06543, overall mean 0.000322. This does not establish pixel identity.

`resource_lifetime.cpp` uses real DX12 fences/queues and the production pool:
blocked-fence retention, no early reuse, safe completed reuse, hard-budget failure,
3,000 simulated menu recording lifetimes with size changes, and zero idle bytes.
The test runs both the Motion Blur and Darker Nights allocator configurations
(3,000 lifecycles each). It waits for fences to assert results; the production
allocator never waits.

`dx12_filter.cpp` executes the shipping SM6 DXIL with native/private bindings for
24 frames at 4K, checks all output channels are finite and alpha is preserved,
and reports warmed GPU time. It requires the built compute embed and a hardware GPU.

The existing activation test privately maps the executable and exercises the
validated flag hook without launching the game. The registration test checks
balanced callbacks and absence of global descriptor/CBV/draw tracking.

Live checks: filter-active log, visual quality while moving, repeated inventory/map
transitions, stable scratch working set/FPS, resolution changes, save loading,
and coexistence with the HDR/lighting addons. Launch/restart is always performed
by the user.

## Official HDR and DevKit coexistence

`addon_coexistence.cpp` reuses the lighting addon's ReShade host and loads the
actual DLLs. It exercises two device lifecycles, unloads in registration order
(the game's probe-device behavior), checks state/callback cleanup, and reloads.
It does not launch the game. Pass paths in reverse order to test the other order.

```powershell
clang-cl /std:c++20 /EHsc /O2 /DNOMINMAX /Iexternal/reshade src/games/thewitcher3remastered-motionblur/tests/addon_coexistence.cpp /Fe:tmp/addon-coexistence.exe /Fo:tmp/addon-coexistence.obj /link user32.lib
./tmp/addon-coexistence.exe build/Release/renodx-devkit.addon64 build/Release/renodx-thewitcher3remastered-darkernights.addon64 build/Release/renodx-thewitcher3remastered-motionblur.addon64 path/to/official-hdr.addon64
```

Also run this host under CDB with its default debug heap and first-chance access
violation/heap-break handling. A normal process can conceal writes after free.
The October 22 DevKit reproduces heap corruption even alone: `OnDestroyDevice`
unlocked a mutex after deleting its owner. Fixing only that error still reproduces
an access violation in the official HDR unload path (`+0x4D6E4` in the fixture).
DevKit's private-data namespace additionally prevents incompatible shared C++
layouts from being accessed across DLLs. Motion Blur and Darker Nights already
have separate namespaces. Preserve the official binary when testing this fix.

With both DevKit fixes, the complete HDR/DevKit/Darker Nights/Motion Blur set
passed both load orders under CDB's debug heap on 2026-10-28: two lifecycles and
reloads each, no heap corruption or access violations. The official HDR fixture's
SHA-256 was `F053363C11240C3ABA340575DF56D4F1494DD860178DCB212C9B6A0ACE8CA304`.
This CPU host covers lifecycle compatibility; gameplay rendering needs the live check.
