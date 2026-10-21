# Motion Blur - Remastered

Standalone DX12/x64 motion blur with full-resolution and optional half-resolution reconstruction.
Enhanced activates motion blur automatically. Native follows the game's
Motion Blur On/Off setting. No HDR addon or DevKit is required.
Installation and controls are described in [packaging/README.txt](packaging/README.txt).

## Source

Restored from `eb4fe16e`, the final revision before `df786e54` removed motion
blur from the HDR addon. This includes the initial `8a5a0f91` implementation,
the camera-pan edge correction in `a4ad7a3d`, and the unclamped long-trail
revision in `02509e3d`. The full-resolution reconstruction, swept-neighbor
coverage, shutter response and depth-aware filter math are retained.

The standalone addon removes the PsychoV-only activation condition and HDR
settings dependency. It uses its own settings section, device-state namespace
and motion-state UUIDs. It does not modify the swapchain.

## Pipeline

`0x9F1C32F1` retains the native XY motion-vector conversion and losslessly
encodes hardware depth in its otherwise unused ZW channels. The native blur
consumers read XY only. At `0x866E78BC` or `0x2B7AF9F0`, TileMax, swept
NeighborMax and reconstruction reuse the native full-resolution colour, motion
and output bindings directly. A clipped vertex invocation copies the already
bound camera projection into the private scratch buffer, entirely on the GPU.
Before the recognized `0x5388164E` prefilter, the addon prepares every required
pipeline, scratch allocation, settings record and camera transfer. Only after
that succeeds does it skip that prefilter and `0x47C602BB` blur. Fresh gameplay
captures verified their intermediates have no consumers outside this chain.
The settings are frozen through resolve, including an intervening mode change.
Failed preflight preserves the native stages; compatible resolve-only paths can
still replace the resolve without suppressing earlier work.
Cache and half-resolution capacities are passed explicitly to the shaders.
When pooled menu textures exceed the prepared allocation or cache dispatch,
reconstruction falls back to direct full-resolution sampling. Root UAV writes
never rely on texture dimensions as an allocation bound. Encoded depth is
consumed once per chain rather than reused by a later menu resolve.

Camera and object blur have independent toggles and intensity sliders in
Enhanced mode. Each intensity uses 0-100 (50 = a 180-degree shutter); disabled
sources contribute no blur. Existing shared intensity values seed both new
controls once, without replacing values already saved independently. The
conversion pass copies the native reprojection matrix into the same scratch
buffer; reconstruction derives camera motion from depth and subtracts it from
combined motion to identify object motion. Object-only blur follows the actual
screen-space trajectory, limited to the smaller of the visible and object
speeds. Camera-followed subjects therefore stay sharp instead of inheriting
the large camera-subtracted vector. Camera motion is rounded to the native
FP16 velocity precision before subtraction to avoid residual camera noise.
The visible trajectory is partitioned between the object contribution and the
remaining camera contribution before scaling each intensity. This preserves
camera-follow cancellation with unequal strengths. Both sources default to on;
camera and object intensity both default to 50. Equal strengths
retain combined native motion.
Neither toggle changes the native motion texture or requires CPU buffer reads.

The split is a screen-space artistic control, not two independent physical
exposures. If T is the native screen displacement and C is camera reprojection,
the object share is `min(1, length(T-C) / length(T))` (zero motion is guarded).
Both shares follow T. With camera blur off, the object's shutter displacement
is therefore bounded by both its visible movement and its camera-relative
movement. Panning cannot add camera speed to that magnitude, but can change
the visible trail's direction. A tracked subject with T = 0 remains sharp.
Correct separation still depends on correct native vectors and matching depth;
transparent layers and disoccluded surfaces cannot be recovered from a single
motion/depth sample. Full-resolution mode reconstructs color at output resolution, but motion and
depth retain the game's input resolution, including its silhouette limitations.

The camera and compute layouts gain a private root UAV, settings CBV and static linear
clamp sampler in space 57. Existing root indices and the HDR settings injection
are preserved. No game-wide descriptor-copy/update, root-CBV or root-constant
tracking is registered, and neither descriptor heap nor root signature is
switched at the replacement point. Native mode bypasses rendering callbacks
before any device lookup and submits no additional GPU commands.

Settings use immutable, cached CBV records in persistently mapped upload pages;
slider changes never overwrite a record still in GPU use. Scratch buffers stay
on the game's command list with UAV ordering barriers. There is no CPU fence
wait, queue flush, native-buffer readback or separate full-resolution depth copy.
The addon still uses the game's motion-conversion/resolve passes and therefore
requests the native motion-blur chain, enabled automatically in Enhanced mode;
it does not require DLSS.

## Build and validation

From the configured x64 Clang developer environment:

```powershell
cmake --build --preset clang-x64-release --target thewitcher3remastered-motionblur
```

Output: `build/Release/renodx-thewitcher3remastered-motionblur.addon64`.
Expected embedded shaders: `0x9F1C32F1`, the three `0xF3B10000`–`02`
compute passes, `0xF3B10005`–`08` cache/reconstruction passes, and the `0xF3B10004` vertex transfer.

`tests/motion_blur.cpp` covers 132 cases / 39,080,580 output pixels per reconstruction path on D3D11 WARP:
zero shutter, 25/100 intensity response, signed HDR, subpixel detail, frame-rate response, long trails and
foreground/edge handling. For the SM5 harness only, remap private `b0, space57`
to `b0`, `u0, space57` to `u1`, and `s0, space57` to `s0`; the filter math is
identical to the shipping SM6 shaders. It checks all four sample budgets under
extreme motion, reversed panning and different shutter angles, plus thin-light
mean energy and coverage. Optional additional baseline binaries run the original
numerical-equivalence check; use this only for changes intended to
preserve the same sampling, not comparisons against the old expanding budget.
Every full-resolution case also compares cached and uncached output (exact in
the WARP test). Half-resolution cases cover odd dimensions, unchanged stationary
detail/alpha, signed HDR, thin-emitter energy and foreground rejection. Pass the
seven CSOs in order `00, 01, 02, 05, 06, 07, 08`, optionally followed by three
baseline binaries.

`tests/motion_depth.cpp` compares the original decompiled conversion against
the replacement, including actual FP16 UAV storage. It requires exact native XY
and exact 32-bit depth for 49,601 pixels and checks every 15-bit packing chunk.
It also compares all four camera/object combinations to a camera-only field
generated by the original game shader, including static and moving pixels.
An additional 26 static-scene cases cover fast translation, yaw, pitch, roll,
zoom, depth-dependent translation and jitter, using both the native static
sentinel and explicit FP16 camera vectors. All produced zero object-only radius
with camera blur disabled and object intensity 100 in the offline GPU test.
`tests/motion_runtime.cpp` rejects registration of the expensive global tracking
callbacks and checks clean attach/detach without DevKit.

The shipping DXIL PSOs and GPU-only projection transfer are also exercised on
D3D12. An offline addon host checks all six loading orders and both unloading
orders with HDR and Darker Nights, including preservation of native root indices
and both addons' settings bindings. These checks do not measure in-game FPS.
Compare addon-disabled, Native and Enhanced in the same CPU-limited scene with
DevKit disabled; also check resolution changes, save loading and silhouettes.
The log confirms activation with `Motion Blur: native-binding reconstruction active`.



## GPU performance

Motion/depth share a single native texture load, and invariant camera data is
loaded outside the gather loop. Tile reductions conservatively bound motion
variation over the entire gather region, including stochastic neighboring tiles.
Within a one-percent motion bound, reconstruction uses common-motion weights
without repeated per-tap motion/depth evaluation. Other regions retain the full
feature-aware filter. Shutter response and output resolution are preserved;
the coherent-motion shortcut adds no CPU tracking.

Sample Quality is a hard maximum of 16/32/64/128 reconstruction taps per pixel.
The old density-based budget increased with trail length up to 1,024 taps, which
could create a feedback loop during sustained panning: longer GPU frames produce
longer motion vectors and request still more work. Intensity now changes the
trajectory length without increasing the sample budget. Short trails still skip
unnecessary samples. Long trails at low quality can be noisier; spatially
stratified sampling preserves their extent and mean light energy. No temporal
history or velocity clamp is used. Resolution reduction is controlled by Half-Resolution Blur.

Separated motion and linear depth are computed once per native motion texel
and reused from a GPU buffer. Equal effective camera/object strengths at full
resolution retain the cheaper direct-input path. No per-frame buffer allocation,
CPU readback or descriptor tracking is introduced. The cache uses 16 bytes per
native motion texel (about 32 MiB at 4K output with 1080p motion).

**Half-Resolution Blur**, on by default, reconstructs at half width/height and
upsamples using depth and motion agreement. Stationary pixels and incompatible
edges use full-resolution reconstruction, preserving static detail and avoiding
foreground bleed. It adds another 16 bytes per half-resolution output pixel.
Moving fine detail can soften; performance gains depend on scene coverage and
edge rejection. Scratch capacity grows only as needed, retaining old allocations
until device teardown so in-flight GPU work remains safe.

`tests/motion_performance.cpp` times the actual SM6 DXIL paths on the
hardware GPU at 4K with native half-resolution FP16 motion/depth. Pass baseline
and candidate CSO folders (candidate includes `00`–`02` and `05`–`08`), optionally
a motion scale and `rotation` for a perspective camera with a moving object.
A final batch-count argument repeats the same workload with persistent resources
to check sustained cost (seven dispatch chains per batch, two warmup chains).
It compares the prior full-resolution path, optimized full resolution and half
resolution, with separate cache, tile, neighbor, reconstruction and upsample timings.
These synthetic timings are not a measurement of the game's complete frame.

Compared with the native reduced-resolution prefilter/gather/resolve, this
filter retains full-resolution color detail orthogonal to motion and adds
per-sample motion/depth weighting plus separate source strengths. It is not
uniformly better or cheaper: low fixed sample counts can reveal grain on long
trails, coarse dominant-motion tiles approximate overlapping trajectories, and
the one-percent coherent-motion shortcut approximates nearly matching weights.
Native prefilter/blur suppression applies only to the recognized, preflighted
same-layout chain described above. Native mode continues to use the original
passes and the game's own setting.

## Automatic activation

Enhanced requests the native motion-blur passes even if the game's Motion Blur
setting is Off. Native follows that setting without changing the saved preference.
A validated hook changes only the fresh per-view motion-blur bit (0x800), after
the native builder runs. It preserves the builder's four scene/postprocessing
guards and every other flag. No global CVar, config file or rendering callback
per draw is changed. The hook follows Darker Nights' module lifetime and worker
thread enlistment strategy. If signature/CVar validation fails, the menu asks
users to enable the game's Motion Blur setting manually.

`tests/motion_activation.cpp <path-to-witcher3.exe>` maps the actual executable
privately and executes its native flag builder through the real Detours hook.
It checks Enhanced/Native transitions with game Motion Blur On and Off, all four
native guards, unchanged config and view bytes, and rejection of changed code.
In game, leave Motion Blur Off and switch Enhanced -> Native -> Enhanced while
panning: custom blur should return in Enhanced and disappear in Native. Repeat
with the game setting On; Native should now retain the original game blur.

## Release builds and Nexus packaging

Close Witcher 3 before building. The scripts use Visual Studio C++ Build Tools,
LLVM/Clang, CMake and Ninja with the existing `clang-x64-release` preset. Only
the `thewitcher3remastered-motionblur` addon target is built.

- Double-click `build-release.cmd` to configure and build Release.
- Double-click `package-release.cmd` to package the existing Release addon.
- To build and package a named release in one step, run from this folder:

```powershell
.\package-release.ps1 -Build -Version 1.0.0
```

The `.cmd` packaging launcher accepts the same arguments and pauses to show
success or errors. From a regular command prompt:

```bat
package-release.cmd -Build -Version 1.0.0
```

Packages are written to `build/Release/packages/tw3-motionblur-remastered-<version>.zip`
with a companion `.zip.sha256` checksum. Omit `-Version` to use the DLL's file
version, falling back to its build timestamp. Use `-OutputDirectory <path>` to
choose another output folder. Reusing a version replaces that package.

The ZIP contains exactly:

```text
bin/x64_dx12/renodx-thewitcher3remastered-motionblur.addon64
README-Motion-Blur.txt
LICENSE.txt
```

The packager verifies each entry against its source with SHA-256 before publishing
the ZIP. It includes no settings, debug symbols, DevKit, shader sources or ReShade
installer. Upload the ZIP to Nexus Mods; users extract it into the game root.
The package-only command does not rebuild and can run while the game is open.
