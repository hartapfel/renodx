# Witcher 3 Classic: BlitzFX and ReShade startup compatibility

## Verified result — 2026-10-23

The user confirmed that the patched ReShade passes the startup crash with
BlitzFX installed. This verifies startup of the injector pair. The user is
restoring RenoDX/DevKit themselves and will report any further incompatibilities.
HDR grading, DLSS, object motion, menu recovery and extended gameplay with both
mods have **not** been accepted as compatible by this test.

No Classic addon or BlitzFX shader code was changed for this fix. No executable
or NVIDIA driver binary was patched. The repository's ReShade submodule was
left unchanged; development used an isolated clone in the investigation folder.

## Patch and active configuration

Source patch: [reshade-6.8-blitzfx.patch](patches/witcher3classic/reshade-6.8-blitzfx.patch).
Apply it to official ReShade `v6.8.0`, commit
`18deaa52de0c425a78b329e9cb3c497281cd00ec`.

The working build adds an opt-in `ReShade.ini` setting:

```ini
[DX11]
ForceMultithreadProtection=1
```

In `D3D11CreateDeviceAndSwapChain`, before creating the device, this removes
`D3D11_CREATE_DEVICE_SINGLETHREADED` if set. After successful device creation,
before returning it to the application, it obtains the immediate context's
`ID3D11Multithread` interface and calls `SetMultithreadProtected(TRUE)`.
Protection stays enabled instead of being enabled only inside ReShade's
swapchain operations. Existing guards consequently observe protection already
enabled and restore that enabled state when leaving their scope.

The flag defaults to false. It is read at device creation, so a game restart is
required after changing it. This is synchronization of existing CPU-side D3D11
context calls; it adds no rendering or texture-copy pass. Its CPU performance
cost has not been benchmarked.

The patch also backports ReShade upstream
[2796147](https://github.com/crosire/reshade/commit/2796147): effect-runtime
creation/destruction moves inside the swapchain's existing device lock and
multithread protection. **That backport alone did not fix this crash.** The
successful build includes both changes; do not describe the startup backport
alone as the verified solution.

Microsoft documents that shared immediate-context use requires synchronization:
[D3D11 threading](https://learn.microsoft.com/en-us/windows/win32/direct3d11/overviews-direct3d-11-render-multi-thread-intro),
[SetMultithreadProtected](https://learn.microsoft.com/en-us/windows/win32/api/d3d11_4/nf-d3d11_4-id3d11multithread-setmultithreadprotected).

## Exact working artifact

Game folder:
`C:/Program Files/GOG Galaxy/Games/The Witcher 3 Wild Hunt/bin/x64`.

- Installed loader: `dxgi.dll`, custom Release x64 ReShade **6.8.0.2**.
- Size: **5,590,528 bytes**.
- SHA256: `B4694CBEB67CD4CE5977B820F474B756D68F64AF92BD3B25754B1B3553251871`.
- GPU/driver: RTX 5090, NVIDIA **617.42**, Windows 11.
- Last verified startup used BlitzFX **1.1.0**, loaded as `blitz-fx.asi` through
  the user's 64-bit ASI loader, with ReShade addons disabled.
- Original BlitzFX DLL/ASI SHA256:
  `8B75B893234CAAB21DB09FB1F486C850790FBC35C43290AD5E5F40CC12BDC3DE`.

The user may subsequently change the loader arrangement while restoring their
setup. Check actual files before assuming that the ASI arrangement is still in
use. Do not rename their files automatically.

The local build and evidence root is
`tmp/witcher3classic-investigation/blitzfx-20261023/`:

- `reshade-patch/`: isolated release source, dependencies and build outputs.
- `reshade-patch/bin/x64/Release/ReShade64.dll`: working build, hash above.
- `build-reshade.cmd`: exact local MSBuild invocation.
- `build-reshade-multithread.log`: successful working-build log.
- `dxgi-original-6.8.0.dll`: original installed ReShade backup, SHA256
  `0CEE63F9C9F13F3AC909C5B4903F4DBB4B719A7AB3B4F13B0DEAF83C814B94F7`.
- `ReShade-before-multithread.ini`: configuration immediately before adding
  `[DX11] ForceMultithreadProtection=1` and `[INSTALL] Logging=1`.
- `blitz-audit.txt`, `blitz-interfaces.txt`, `project/`: Ghidra analysis of the
  installed BlitzFX binary. Its preferred image base is `0x180000000`.
- `shaders/index.json`: reflection/resource index of 103 DXBC containers
  extracted from the installed BlitzFX cache for private analysis.

Scratch artifacts are not the durable source distribution. Keep the patch and
this document when cleaning scratch folders. Do not commit DLLs, crash dumps or
third-party shader caches.

## Rebuilding

1. Clone official ReShade at `v6.8.0` with recursive submodules into a separate
   directory. Apply the saved patch there with `git apply`.
2. Use the project's Release x64 build, VS 2022 v143 and an installed Windows
   SDK. The verified local SDK was `10.0.28000.0`.
3. Use a dedicated Python virtual environment with the requirements from
   `deps/glad/requirements.txt`. Put that environment's `Scripts` directory on
   the build shell's PATH. GLAD generates graphics headers and may need network
   access on its first run. Do not install build requirements into system Python.
4. From an x64 VS developer shell, run:

```powershell
msbuild ReShade.vcxproj /m:4 /p:Configuration=Release /p:Platform=x64 /p:PlatformToolset=v143 /p:WindowsTargetPlatformVersion=10.0.28000.0 /p:SolutionDir=C:\absolute\path\to\reshade\ /p:MultiProcessorCompilation=false /v:minimal
```

5. Close the game, back up the current loader, then copy
   `bin/x64/Release/ReShade64.dll` into the game folder as `dxgi.dll`.
   Preserve `ReShade.ini` and merge the flag above into an existing `[DX11]`
   section if present. Do not duplicate sections or replace the user's presets.
6. Restart. With logging enabled, verify:
   `Enabled persistent D3D11 multithread protection for injector compatibility.`

Rebuilding increments ReShade's build number and changes its binary hash.
`GenerateDebugInformation=true` passed as an MSBuild property did not produce
a PDB with this project's explicit Release linker metadata. Do not assume one
exists. A separate symbol-link experiment produced a map/PDB but changed code
layout; those offsets cannot be applied blindly to the deployed binary.

## Crash evidence and discarded explanations

The user reproduced the failure with **only BlitzFX and ReShade**, without
RenoDX, DevKit or other addons. The documented ASI-loading workaround also
failed. Do not ask them to repeat those isolation tests as though untested.

Windows dumps report `0xC00000FD` in `witcher3.exe + 0xE7C107`. This is a
secondary failure: the game's exception handler probes a large stack allocation
on an NVIDIA worker thread. Recovering its original exception/context from
the dump shows a **read access violation at address 0x10** in
`nvwgf2umx.dll + 0x3044A3`. The faulting instruction reads `[rsi+0x10]` with
`rsi=0`. Do not label this graphics-hook recursion based solely on the final
stack-overflow code.

- `witcher3.exe.26560.dmp`: initial RenoDX-enabled failure; original exception
  details in `original-exception.txt`.
- `witcher3.exe.22408.dmp`: clean ReShade/BlitzFX failure; `clean-crash.txt` and
  `clean-threads.txt` contain analysis.
- `witcher3.exe.22144.dmp`: same original driver fault after the upstream
  runtime-creation backport alone; `patched-crash.txt` contains analysis.
- Dump source: `C:/Users/Vik/AppData/Local/CrashDumps/`.
- Successful persistent-protection startup: PID 38740, launched 21:26 CEST;
  the user confirmed it worked. Do not keep following that PID after a restart.

The result strongly points to a context-synchronization problem in the combined
injector setup. It does not prove which specific pair of native context calls
overlapped or identify an internal NVIDIA driver defect. No fault suppression,
exception swallowing, driver machine-code patch or disabled rendering effect
was needed for the successful startup.

An earlier per-game Ansel-usage override did not fix startup. Its effective
values were restored: `ANSEL_ENABLE_ID` has no explicit value and
`ANSEL_ALLOW_ID` is 1. The latter is now stored as an explicit user value rather
than its previous predefined entry; `ANSEL_ALLOWLISTED_ID` remains predefined 1.
`nvidia-before.txt` is the original NVAPI settings export. NVAPI file import
merges settings and did not by itself remove the test override; do not call
that an exact database rollback. Do not change driver profiles further unless
the user asks or a new, supported diagnostic requires it.

## Follow-up if the user reports another issue

First verify the deployed DLL hash/version and the opt-in flag. Then capture
the new failure with matching symbols or source mapping; distinguish a startup
regression from an HDR/DLSS rendering incompatibility.

BlitzFX is not a pure shader-replacement pack: Ghidra shows device/context and
presentation interception, buffer allocation and custom rendering; the cache
contains compute passes for TAA, bloom, water, shadows and motion blur. Its
documentation also exposes its own TAA jitter/history and tonemapping controls.
If gameplay loads but HDR/DLSS fails, trace ownership/order of those passes.
Preserve a single reconstruction/jitter owner and a single final tone-mapping
owner. Do not transplant cached shaders alone and claim full integration.

The user explicitly chose to restore addons themselves and report further
problems. Combined-gameplay validation and performance measurements remain
pending; do not make more installation changes on their behalf at this point.

## Rollback

With the game closed, restore the saved original DLL as `bin/x64/dxgi.dll`.
Remove `ForceMultithreadProtection=1` if returning to stock ReShade; stock
ReShade ignores this custom flag. Remove the diagnostic `[INSTALL] Logging=1`
only if desired. Avoid restoring the entire old INI over newer user changes.
Stock ReShade plus BlitzFX is the previously failing combination, so DLL
rollback alone should not be presented as a working BlitzFX configuration.
