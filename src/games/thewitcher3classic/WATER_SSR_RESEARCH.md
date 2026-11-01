# Classic water SSR — 2026-11-01

## Evidence and scope

The water view captured through DevKit on process 12536 renders at 3840×2160.
Its native SSR input, trace, and history run at 960×540. The water mask and
post-water depth remain full resolution. The active standalone chain is
406B9233 → 47CC9FA1 → mip/fill passes → BDAA334B → 35624BD6. The history shader
is **BDAA334B**, not the separate BlitzFX history variant 4E0137BC targeted by
earlier, removed experiments. Inputs are floating point before tonemapping.

## Sources and application

- [AMD FidelityFX SSSR](https://gpuopen.com/manuals/fidelityfx_sdk/techniques/stochastic-screen-space-reflections/)
  separates reflection intersection, radiance and denoising; SSR cannot recover
  off-screen geometry. Increasing the final texture alone does not add rays.
- [AMD FidelityFX Denoiser](https://gpuopen.com/manuals/fidelityfx_sdk/techniques/denoiser/)
  describes reflection history reprojection, disocclusion detection and local
  statistics. Reflected-hit motion can differ from receiver-surface motion.
- [Stochastic SSR, Tomasz Stachowiak](https://h3.gd/stochastic-ssr/)
  documents reflection reconstruction and temporal filtering tradeoffs.

These motivate a game-specific Shader Model 5 implementation, rather than a
claim that the DX12/Vulkan FidelityFX SDK was integrated into this DX11 mod.
This is still deterministic screen-space tracing using Classic's audited ray
intersection and native environment fallback, not a planar scene render or RR.

## Implementation

- Private textures follow the active primary render view, including DLSS's
  smaller top-left viewport inside output-sized game allocations. No pooled
  resource is resized. Full resolution is optional and defaults Off.
- Solid-object radiance comes from the **current** pre-water HDR scene. Only
  validated late emissive particles use the existing reprojected prior color.
  This avoids accumulating two layers of scene-color history.
- Opaque depth is copied before water changes it. Full-resolution tracing uses
  that full-resolution opaque depth and the original post-water depth/mask.
  Each active render pixel gets its own ray and reflection output. DDA stride
  scales with resolution, retaining approximately the native ray-step spacing
  rather than multiplying per-ray work by four as well as tracing sixteen
  times as many rays at 4K.
- The shared original trace compiles unchanged for its original shader hash.
  The private variant exports optical path length and reflecting-water height.
  Camera reprojection uses the virtual reflected hit at that optical distance.
  Environment fallback uses rotation only. History taps must agree on hit
  class, depth and water height. Frame gaps, resizing, mode changes and camera
  cuts reject history. Local variance clipping and adaptive history reduce
  shimmer without retaining obsolete geometry or clamping HDR to SDR.
- The original final compositor, water mask/Fresnel, normal offsets, additive
  blending and render target remain in charge. Native filled reflections supply
  non-water padding under those offsets. This avoids adding reflection color
  to characters, sky or unrelated scene pixels. Explicitly disable shader
  settings injection on this hook-only compositor registration.
- The native chain continues in parallel for immediate fallback and fresh
  history when both options are switched Off. This has a cost, but avoids pool
  aliasing and stale original history. Stabilization defaults On; Vanilla
  explicitly switches both options Off. No primary motion vectors, FG tags,
  HUD composition, underwater effects or output encoding are changed.

## Verification and remaining limits

`water_reflection_trace.cpp` compares the original shader bytecode to the shared
native variant and exercises the real private resource path at quarter/full
resolution, cropped and odd render dimensions, resizing and toggling. It checks
finite HDR output and exact native resource/constant restoration.
`water_reflection_history.cpp` checks alternating HDR noise, reflected-hit
disocclusion, changing lighting, camera cuts, a moving reflected edge and native
shoreline padding. Both run on WARP and NVIDIA. `presets.cpp --water-ssr` checks
the two settings and explicit presets without unrelated rendering tests.

Gameplay acceptance is required after rebuilding: compare both resolutions
while still and moving, with DLAA and a DLSS upscaling mode. Check shoreline and
Geralt silhouettes for added haze; verify HDR highlights and FG on/off. SSR's
screen-edge loss and hidden geometry remain limitations. Full resolution costs
more GPU time and memory and is not enabled automatically. Synthetic noise
tests establish filter behavior, not a promise that every live reflection is
free of shimmer. Deforming reflected geometry has no separate reflection-hit
object velocity; history clipping/disocclusion are the current safeguards.
