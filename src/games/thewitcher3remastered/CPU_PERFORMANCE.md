# CPU performance

The HDR addon uses a 124-byte root-constant payload, cached replacement
PSOs and native night-lighting hooks. It does not capture or read back the
game's constant buffers or wait for the GPU each frame. Initial replacement
PSO creation can still cause first-use hitches. Release builds no longer
force debug logging.
Night Vegetation Saturation adds one scalar night delta to the existing
display-gamut grade (124-byte payload). Hue selection runs only while that
delta is nonzero. It adds no textures, descriptor tracking or event callbacks.

Enhanced motion blur and Video AutoHDR have been removed after profiling
identified descriptor-copy/update mutex contention across rendering workers.
Disabling those features at startup substantially improved the user's RT
performance. A replacement with independent heap-range locks improved a
synthetic 16-worker test from about 39 ms to 21 ms, but the user's live test
still showed substantial slowdown. That replacement was therefore removed too.

The current addon has no motion reconstruction passes, movie redirection,
extra movie SRV, root-binding history or descriptor heap update/copy callbacks.
Motion blur follows the native game setting. Movies use the native decoder and
existing UI composition path, including the Frame Generation coverage mask.
Only the BT.709 decoder correction and its VideoBT709 toggle are restored;
AutoHDR remains removed. Previously
saved motion/video/CPU-mode values are ignored; no CPU Performance Mode remains.
HDR tone mapping, grading, effects, UI brightness and night/gameplay lighting
controls remain available. Other addons can still register their own tracking.

Validation: clang-x64-release/thewitcher3remastered builds successfully. A test
loading the real Release DLL verifies absent tracking events, ignored removed
settings, retained HDR events and clean detach. D3D11 WARP runs both production
normal/FG output shaders before and after cleanup with a transparent former
movie layer. All 324 scene/UI configurations (663,552 output pixels) match
exactly across Vanilla/PsychoV, peak/game/UI brightness, gamut and UI opacity.
The Frame Generation UI mask retains native coverage. These checks do not
measure live RT frame time or verify native movie playback.

After restarting with the rebuilt addon, compare the same RT scene with the
HDR addon alone and identical game/ReShade settings. Check intro/loading
movies, subtitles, native motion blur and Frame Generation separately.
Live performance and playback validation of this cleanup are pending.

BT.709 decoding was restored from fcb3cbc9 without video.hpp/video.hlsli,
movie targets, output SRVs or AutoHDR. It uses the native decoder layout
and no injected constants. The real Release DLL callback check still passes;
the conversion reference test passes 589,824 pixels including alpha and
limited-range endpoints. These checks do not measure live frame time.
