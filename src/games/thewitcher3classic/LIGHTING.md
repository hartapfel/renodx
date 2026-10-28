# Classic lighting implementation

This is a native DX11 lighting extension, independent of BlitzFX. It is not a
post-process relighting filter. The current defaults are the user-approved configuration listed below.
BlitzFX's source was inspected to identify its feature inventory, shader
signatures and engine data contracts; its lighting/shadow implementation was
not copied. The algorithms below are implemented locally.

## Feature inventory and implementation decisions

BlitzFX commit `659e239cfcba9cf0362621486ecdb241b0eee168`,
[`source/rendering/gui.cpp`](https://github.com/sven-luepke/blitz-fx/blob/659e239cfcba9cf0362621486ecdb241b0eee168/source/rendering/gui.cpp),
defines these Lighting controls: Soft Shadows, Contact Shadows, HairWorks Shadow
Quality, Physical Ambient Occlusion, Unify Player Light Influence, Player Light
Scale, and PBR Lighting. Physical Sun is a separate feature group and is not
silently included in this change.

| Control | Our implementation | Default |
|---|---|---|
| Surface Lighting | Native or Custom PBR for deferred directional and local lights | Custom PBR |
| Ambient Occlusion Influence | Native or Ambient Only; removes direct-light AO, retains indirect occlusion | Ambient Only |
| Directional Shadows | Native or blocker-dependent PCSS, including continuous cascade blending | Custom |
| Light Angular Diameter | Directional source diameter; affects penumbra size, not sun disk | 0.150 degrees |
| Contact Shadows / Reach | Short depth trace toward the directional light, world-space length | On / 0.3 m |
| Player Fill Light / Strength | Scales only engine-tagged artificial player lights | Custom / 0.20 |
| Match Character and World Fill | Removes the character-specific fill boost using the existing world scale | On |

### PBR

[Google Filament's PBR reference](https://google.github.io/filament/main/filament.html)
specifies GGX, height-correlated Smith visibility, Schlick Fresnel and Lambertian
diffuse. `lighting/brdf.hlsli` implements these direct-specular terms with
`alpha = perceptualRoughness^2`. Roughness has a small numerical floor. The
denominator avoids catastrophic cancellation near a polished highlight.
Material reflectance below 2% retains its specular-occlusion role at grazing
angles. The existing diffuse calculation already uses the Fresnel complement;
the replacement supplies the new Fresnel to that calculation.

This is deliberately a hybrid material integration. Native skin/foliage
transmission, material flags, reflection-probe blending, IBL grading, light
attenuation and weather radiance remain native. Hair's anisotropic shading is
not replaced with an isotropic surface BRDF. No material texture is reinterpreted
as metalness. The new BRDF is not a claim that Classic's artist-authored lights
and textures suddenly constitute a fully calibrated physical renderer.

### Ambient occlusion

Filament's occlusion discussion applies AO to indirect illumination. Here the
game's `cb12[69].xy` direct-light AO blend is bypassed while indirect AO and
direct-light visibility remain in place. This includes the eight deferred local
light variants and the audited forward-character paths. It does not change the
AO estimator or spread AO over the final image.

### Soft shadows

[NVIDIA's PCSS integration paper](https://developer.download.nvidia.com/whitepapers/2008/PCSS_Integration.pdf)
provides the blocker-search, penumbra-estimate and variable-radius PCF method.
Our directional-light adaptation uses orthographic light-space separation:
penumbra radius is blocker/receiver distance multiplied by the source angular
radius, then converted into the selected cascade's UV scale. Applying the
perspective spot-light depth ratio here would be incorrect.

The implementation uses 12 point-depth blocker samples and 24 hardware
comparison-filter samples in the existing shadow mask. A fixed Vogel disk
avoids animated sampling noise and per-tap trigonometry. Receiver-plane depth
gradients reduce slope acne without a large detached-shadow bias. The original
rasterizer bias remains in effect. A 16-texel kernel cap and 20 m blocker-search
range bound cost and undersampling; very broad penumbras are approximations.

[Microsoft's cascade guidance](https://learn.microsoft.com/en-us/windows/desktop/DxTechArts/cascaded-shadow-maps)
and [NVIDIA's PCF explanation](https://developer.nvidia.com/gpugems/gpugems/part-ii-lighting-and-shadows/chapter-11-shadow-map-antialiasing)
support filtering comparisons rather than averaging raw depths. Adjacent
cascade visibility is blended over the engine's transition band; the final
cascade fades to lit. Cloud and terrain visibility are retained outside the
replacement block. This is not a new shadow-map geometry pass.

HairWorks follows the Directional Shadows mode, using the same cascade/filter
infrastructure with 16 taps when Custom is selected. It preserves the native strand material, packed inputs, early-depth
flag, buffers, fog and blending. There is no separate HairWorks quality setting. Simulation, density and
transparency remain native.

### Contact shadows

[Epic's contact-shadow documentation](https://dev.epicgames.com/documentation/unreal-engine/contact-shadows-in-unreal-engine?lang=en-US)
describes per-light depth ray marching and its distance/noise tradeoff.
[Epic's light controls](https://dev.epicgames.com/documentation/fortnite/environment-light-rig-device-in-unreal-editor-for-fortnite)
also expose world-space contact length. We use metres, not a fraction of the
screen, so moving the camera does not directly scale the physical reach.

`ContactVisibility` performs 16 perspective-correct samples in the native
directional shadow-mask pass. It rejects subpixel self hits and back-facing
receivers, scales bias/thickness by the projected pixel footprint, and fades
at screen edges and the ray end. It multiplies directional visibility once;
it does not darken ambient light, emissives, the HUD or the tonemapped image.
No animated random seed, temporal history, full-size scratch target, or geometry
replay is added. Actual raster viewport size is used under DLSS.

[Bend Studio's SIGGRAPH work](https://www.bendstudio.com/blog/inside-bend-screen-space-shadows/)
was also reviewed. Its shared-sample compute approach is a possible next
optimization for longer screen-space shadows. This implementation does not
claim to be Bend's algorithm: short contact rays fit the existing pixel pass
without a new compute dispatch/history pipeline.

Only visible opaque/cutout depth is available. Offscreen and transparent
blockers cannot be recovered. Long rays, thin geometry and silhouettes remain
screen-space limitations. Contact shadows presently apply to the sun/moon,
not a new per-local-light trace.

### Player fill controls

These are artistic controls, not a physical law. The engine's camera-fill tag
is `asuint(lightColorAndFlags.w) == 0x80001800`. Other lights are untouched.
Unification scales identified character fill by the ratio of world fill to the
native recipient scale. This avoids globally mutating the shared frame buffer.
Zero lights remain zero; spell and torch lighting do not follow this control.

## Proven integration points

| Shader | Role |
|---|---|
| `FB29B4E6.cs_5_0` | Deferred sun/moon plus reflection-probe/ambient lighting |
| `05FE9FA8.ps_5_0` | Main directional shadow mask; terrain and cloud combination retained |
| `95991F6F`, `D3573BB9`, `72225972`, `3FFDA0D9` | Unshadowed point/spot and camera-light variants |
| `3946E96C`, `0AB3A292`, `3CED9DA6`, `ED6CEFE4` | Shadowed local-light variants |
| `4E4E4B53.ps_5_0` | HairWorks strand shading and directional shadow filtering |
| `FAB74FB3.ps_5_0` | Transparent hair fringes: tagged player-fill control and shared custom fog |
| `12B76681`, `20C1C070`, `30F033B5`, `9B839F3B`, `B18EC2FB`, `EB8C3FAE` | Forward character lighting; existing motion outputs retained |
| `FD1D6FBF.ps_5_0` | Audited forward material/fog path |

Native deferred inputs: t0 depth, t1 gamma-encoded albedo/translucency, t2 normal
and perceptual roughness, t3 stencil, t4 gamma-encoded specular F0/material flag,
t6/t7 probe atlases, t16 packed AO/directional shadow/interior/additional mask.
Normals decode by normalizing `rgb - 0.5`; albedo/F0 use the native exponent 2.2.
The compute shader writes the existing u0 scene output.

Frame b12 is 4304 bytes. b13 contains directional data and a local-light array
starting at float4 index 58 with nine float4s per light; +3 is color/flags.
Shadow t8 is a Texture2DArray with comparison sampler s9. b13[4..7] is the common
world-to-light transform; [8..10] are cascade bounds; [11..14] map UVs; [15].z is
the count; [17] contains blend widths. Native depth linearization is
`1 / ((raw * cb12[22].x + cb12[22].y) * cb12[21].x + cb12[21].y)`.

Runtime controls use a private three-float4 structured buffer at t118. Native
b12/b13 are never overwritten. The SRV is saved and restored around each
selected draw/dispatch. Buffer updates occur only when values/viewport change;
there is no synchronous readback. Disabled options retain native shader paths.
Existing motion pixel shaders read zero from the unbound private slot when the
new forward controls are off.

Without a motion-extended vertex shader, six `F3C40010..F3C40015` internal
color-only variants preserve the original PS input/output signatures. The
callback temporarily binds the corresponding variant and restores the native
PS after drawing. Do not force the motion PS onto a native VS: its extra inputs
and MRT outputs are not part of the native interface. When object motion is
active, the existing motion-capable PS remains responsible for all motion MRTs.

BlitzFX's replacement deferred/soft-shadow shaders have different hashes and
are not overridden by these native replacements. Use the new lighting section
without BlitzFX for its full intended behavior. Existing BlitzFX HDR/DLSS
compatibility and dynamic non-BlitzFX behavior are not removed. Ansel's alternate
shadow pass and unobserved material permutations are not claimed as covered.

## Evidence, tests and pitfalls

Session artifacts: `tmp/witcher3classic-investigation/lighting-20261027/`.
`shader-map.json` matches original DXBC signatures to BlitzFX's identifiers.
`capture-lighting.json`, `capture-shadow.json`, and `capture-hair.json` contain
exact before-draw bindings/constants. Original bytecode and decompilations are
under `originals/`; none are placed in the live shader source directory.

`tests/lighting.cpp` compares original bytecode with the new shaders using
captured constants plus deliberately varied materials, hemispheres, probe
atlases, light types and blocker/cascade positions. It checks:

- Native-disabled directional/IBL, all eight local variants, shadow mask and
  HairWorks shading equivalence on WARP and NVIDIA.
- Custom BRDF/AO finite output and nontrivial effect.
- Player controls leave world lights unchanged, halve only tagged fill lights,
  and implement the expected character/world scale.
- Contact tracing leaves a flat plane unchanged and shadows the test occluder.
- PCSS bounded visibility; all HairWorks tap options finite.
- Color-only variants preserve original shader linkage.

`tests/object_motion.cpp --forward-only` separately checks native RGB, exact
clip positions, motion history, object/camera motion and MRT restoration with
the modified forward shaders. This is necessary even for a lighting-only edit.

Decompiler pitfalls encountered here:

1. Integer `and ... l(1)` hemisphere/cascade selectors decompile as a floating
   zero. Repair using the instruction's integer meaning, then test both probe
   hemispheres and cascade edges.
2. HairWorks packs float/uint/float inputs into one register. Split HLSL semantic
   declarations must retain the exact masks/types and register linkage.
3. HairWorks cb10[26].xyz / cb10[27].y flags are integer bits, including value 1
   represented as a float denormal. Floating comparison flushes these to zero.
   Use `asuint`, also for the material-mode switch.
4. Native GPU tests need a comparison-capable shadow format. WARP accepted an
   RGBA32F test comparison that NVIDIA did not; the test now uses R32_FLOAT.
5. A compiled shader and a finite output are insufficient evidence of native
   shading equivalence. The HairWorks test caught a substantial color change
   before the new shadow option was enabled.

Build: the established `clang-x64-release` preset, target `thewitcher3classic`.
While the DLL is loaded, only shader embeds and the Release addon object are
compiled. Full linking waits for game shutdown. Scratch `test-lighting.cmd`
compiles/runs the lighting test on WARP and NVIDIA; `test-object-motion.cmd`
runs the forward regression on both.

## Direct BlitzFX comparison revision (2026-10-28)

This supersedes the initial contact-shadow and blocker-sampling descriptions
above. The user reported missing vegetation/armor contact shadows and generally
poor lighting, and requested code comparisons rather than scene-specific tweaks.
The comparison used BlitzFX's `ContactShadowsPackDataCS`, `ContactShadowsCS`,
`ContactShadowsSpatialFilterCS`, `ShadowsTemporalFilterCS`, `ShadowCommon.hlsli`,
`LightingCS`, material `FilterNDF` calls and `shadow_renderer.cpp` at the pinned
commit above. The earlier RenoDX compatibility findings were checked against
`docs/WITCHER3_CLASSIC_BLITZFX_COMPATIBILITY.md`, particularly material storage,
packed-bit decoding, active render rectangles and temporal jitter.

| Area | Concrete discrepancy | Revision |
| --- | --- | --- |
| Material storage | The proven UNORM G-buffer protection was gated on BlitzFX. Standalone materials could use the HDR scene-color clone, losing native bounds and packed-mask quantization. | Apply the existing narrowly identified three-MRT material exemption in standalone too. HDR lighting/output buffers stay floating point. |
| Contact receivers | Mask `&14` rejected tree sprites. A geometric-normal facing gate also removed grass and character receivers. | Use native normal, material and stencil fields. Exclude high-resolution tree leaves, hair and translucent receivers as BlitzFX does; retain billboard trees, grass and characters with their respective offsets and bias. |
| Contact blockers | All accepted depths were treated as opaque; omitted terrain, grass and translucency policy. | Pack linear depth and normal/opacity once. Grass opacity .75; hair/translucency zero; nearby terrain excluded as an occluder; skin and tree sprites opaque; remaining translucency from native albedo alpha. |
| Contact tracing | Equal world-distance steps skipped projected pixels, with one thickness/bias for every material. | Equal projected steps with perspective-correct depth, capped at 24 taps; preserve metre-based reach. Character thickness/bias differs from general surfaces. Explicit near-plane and active-rectangle bounds. |
| Contact filtering | No filter; multiplied contact and cascade visibility, darkening overlap twice. | Depth/normal-aware 3x3 filter fused into existing mask PS; combine with cascade using minimum visibility, then retain native terrain/cloud composition. |
| Cascade filtering | Point-only blocker search could miss thin blockers. Receiver derivatives evaluated inside divergent branches could span unrelated surfaces. Vegetation gradient did not match native scaling. | Centre plus 16 four-depth gathers; native raster bias and material gradient, no cross-surface receiver derivatives; corrected gradient scaling. Keep physical directional penumbra calculation and continuous cascade blend. |
| Local shadows | Four deferred variants numerically converted packed atlas words; HairWorks had the same decode. | Shared `DecodeShadowAtlas` uses `asuint` then integer field extraction. Preserve native atlas positions, sizes and layers. |
| Specular aliasing | BlitzFX filters normal variance in metal/chainmail and other G-buffer material shaders; ours had no equivalent. | Explicit quad-neighbour normal-variance roughness filter in Custom deferred directional/local lighting, with depth-edge rejection. Works in SM5 compute and divergent local-light shaders; no change in Native mode. |
| PBR diffuse/specular | Burley diffuse was added in the preceding source revision. Correlated Smith differs intentionally from BlitzFX's separable approximation. | Retain normalized Burley/GGX/Fresnel, native light calibration and transmission. Material storage and roughness filtering address concrete integration defects rather than changing exposure to conceal them. |
| AO and fill lights | BlitzFX changes direct AO and tagged player-light constants. | Existing ambient-only AO and tagged-light controls retained; tests still prove unrelated world lights unchanged. |

Runtime: `lighting/contact.hpp` caches an R32G32 packed input and R16G16 raw
visibility/depth target. Two compute dispatches run only when contact shadows
are enabled; the native shadow-mask draw performs filtering. No geometry replay,
CPU readback or per-object work. D3D11 isolated context state preserves all native
bindings, including CB first/count ranges. Private PS t119 is restored after the
draw. Stencil views are rebuilt on depth-resource changes; scratch textures on
size changes. Albedo SRV follows the identified native material MRT resource.
Failed input/size requests produce no contact mask, never reuse an older result.

Compatibility details retained:

- Packed normal/opacity channels use `asuint`/`asfloat`, not numeric conversion.
- Bounds use the active viewport and `cb12[23]`, not the full pool allocation.
  Out-of-screen samples terminate rather than clamp into an invented blocker.
- Current jittered projection/reconstruction matrices are used together. This
  revision has no temporal shadow history, so it does not borrow BlitzFX's
  unjittered history matrices or add a second jitter owner.
- The material exemption recognizes the same native three UNORM MRTs and D24
  depth layout; it does not affect the separate object-motion target.

Validation: `tests/lighting.cpp` compares all eight local-light variants,
directional/IBL and native shadow output with original bytecode. The new packed
atlas fixture fails the old code (max error 0.0775092) and matches exactly after
repair, with nonzero offsets, sizes and different layers that visibly affect
the fixture. Contact tests cover flat-plane rejection, actual occlusion,
grass/tree/character coverage, excluded receiver classes, ranged constants,
resource resize and active rectangles within larger pools. WARP and NVIDIA pass.
Forward object-motion tests also pass native color/clip/motion/state checks.
The previous captured BlitzFX PBR replay remains a useful storage regression:
228 nonfinite components with float materials, zero with UNORM, while retaining
scene-linear radiance above 59. These are offline checks, not live acceptance.

Remaining differences requiring further work: BlitzFX additionally performs
normal-mapped contact self-shadowing and temporal filtering of the combined
shadow mask. This revision does neither; adding temporal rotation without valid
reprojection/history rejection would reintroduce shimmer and trails. HairWorks
shadows still run per pixel, unlike BlitzFX's domain/vertex approach. Our deferred
roughness filter approximates material-stage filtering and must be checked on
fine chainmail and silhouettes. Actual frame cost and visual quality must be
measured after installing this revision; no performance or parity claim yet.

## In-game validation still required

Compare Native/Custom one feature at a time, first without BlitzFX. Check
Geralt, NPC skin/eyes/hair, horses, terrain, foliage, interiors and night lights;
walk across cascade boundaries and pan over thin geometry. Test DLAA and DLSS
Quality/Performance, camera motion, save loads, inventory and cutscenes. Repeat
with Object Motion disabled to validate the color-only path, then restore it.
Measure the same scene with debug views off and unchanged frame-limit settings.
Do not promise zero cost or universally superior quality from the offline tests.


Deployment follow-up: the lighting/shadow comparison revision was linked in
Release after Classic exited. The existing game-folder symlink resolves to
the rebuilt build/Release/renodx-thewitcher3classic.addon64 (9,204,224 bytes).
Build log and SHA-256: effect-audit-20261028/build-release-shadow.log and
release-shadow-build.json under the investigation scratch directory.
All final WARP/NVIDIA checks pass; in-game acceptance remains pending.


## Accepted Graphics defaults (2026-10-28)

The user confirmed the lighting/shadow revision looks better in-game, especially
with this configuration, and requested these defaults:

- Surface Lighting: Custom PBR; Ambient Occlusion Influence: Ambient Only.
- Directional Shadows: Custom Soft Shadows; Light Angular Diameter: 0.150 degrees.
- Contact Shadows: On; Contact Shadow Reach: 0.3 m.
- Player Fill Light: Custom; Fill Light Strength: 0.20; Match Character and World Fill: On.
- Atmospheric Fog: Custom; Fog Density: 1.00; Fog Start Distance: 0 m;
  Light Scattering: 1.00; Scattering Directionality: 0.60; Height Falloff: 1.00.
- Water Shading: Custom; Water Clarity: 0.50.

HairWorks Shadow Quality was removed from the menu, setting registration,
runtime variable/upload and shader quality-selection branch. HairWorks still
follows Custom Soft Shadows with fixed 16-tap filtering, as it previously did
when the removed control was Native and Custom Soft Shadows was selected.
The old parameter lane is reserved as zero to preserve the buffer ABI.
Saved settings remain user-owned; these are startup/reset defaults, not a
forced rewrite of existing profiles. The old unregistered INI key is ignored.

## Graphics preset buttons (2026-10-28)

The Graphics tab starts with Vanilla Graphics and Improved Graphics buttons.
Both affect only Gfx settings and save their values into the selected RenoDX
preset (#1, #2 or #3). They are disabled while the shared Preset selector is Off.
HDR, Effects, DLSS and the game's own graphics options are not changed.

Vanilla Graphics sets all Graphics mode selectors to Native/Off. Custom-only
sliders reset to the approved defaults but remain inactive. Improved Graphics
restores every Gfx setting's default_value, using the accepted values above as
the single source of truth. Graphics mode selectors must keep Native/Off at 0.
HairWorks follows the directional-shadow mode; there is no separate quality
setting.

Verification: build thewitcher3classic with clang-x64-release. In-game, select
Preset #1, change Graphics sliders, and press each button. Confirm Native/Off
versus the accepted defaults above, that other tabs retain their values, and
that selecting another preset and returning restores the saved Graphics values.
Check that both buttons are disabled with Preset Off. Runtime button testing
remains pending; the Release compilation result is recorded in the build log
at tmp/witcher3classic-investigation/effect-audit-20261028/build-graphics-presets.log.

## Hair fringe coverage and forward shadow decoding (2026-10-28)

The indoor capture uses native transparent hair `FAB74FB3` in eight late draws,
with `F872850A` as its vertex shader. It had no addon replacement, so the player
fill control affected opaque hair but left these fringes at native intensity.
BlitzFX 1.1.0 scales the tagged light colors in the shared lighting constant
buffer (`RenderingEngine::OnUpdateConstantBuffer(GameLightingData*)`), covering
transparent hair automatically. Its update interception also preserves those
modified player lights during subsequent constant-buffer copies. RenoDX keeps
native constant buffers intact and now covers the missing fragment shader.
The supplied BlitzFX 1.1.0 package contains the binary/shader archive; comparison
used the matching local source under the volumetrics-20261027/blitz-source tree.

The new shader keeps original input linkage, material/lighting math and
premultiplied alpha. It scales only flags 0x80001800 with PlayerFillScale and
uses the shared custom atmosphere when available. Its raw tiled light-list
load uses numeric indices, matching the surrounding decompiled integer math.
Native fog and disabled fill controls retain original output.

The broader audit also found numeric float-to-integer conversion of packed
shadow-atlas data in 12B76681, 20C1C070, 30F033B5, 9B839F3B, B18EC2FB,
EB8C3FAE and FD1D6FBF. These now use the existing bit-preserving decoder, as
does FAB74FB3. Native DXBC ubfe/and/ushr instructions were checked for all eight.
The six motion/color-only pairs share their corrected shader bodies. These
fixes can matter with Vanilla Graphics because object-motion shaders remain
active independently of that preset. No motion-vector calculation changed.

Validation: Release embeds and addon object compile. WARP/NVIDIA lighting
tests match original transparent-hair RGBA exactly with controls disabled,
exercise nonzero fill removal/half strength and character/world unification,
and keep world lights/alpha unchanged. Opaque and transparent hair comparisons
across three camera directions and two packed atlas layers also match original
DXBC exactly. A deliberately restored old numeric decoder differs in over
63,000 tested channel values, proving the regression exercises the defect.
The forward object-motion fixtures pass on both adapters. Evidence and native
instruction audit: tmp/witcher3classic-investigation/interior-fog-20261028.

The user's angle-dependent lighting report also occurs with fill disabled and
Vanilla Graphics. Its exact live cause is not yet established; the defects above
are proven independently and must not be described as a confirmed fix for every
native camera-dependent lighting change. Release linking completed after shutdown; the existing game-folder symlink points to the rebuilt addon.
After relaunch, compare hair fringes with fill strength 0/.2/1, rotate around
Geralt near local lights, and repeat with Vanilla Graphics and object motion off.


## Contact shadows: BlitzFX sampling restoration (2026-10-28)

The original 24-tap implementation spread evenly spaced samples over the entire
world-space reach. Close-up rays therefore sampled widely separated pixels and
created repeated silhouettes. Two subsequent repairs were rejected in-game:
continuous dense tracing filled the heuristic depth slab into broad shadows;
removing that slab and bias for exact cell/surface intersections caused faceted
self-shadowing and flicker. Their synthetic width tests were insufficient and
must not be cited as visual acceptance or proof of a physically correct result.

The current trace restores the original material rules, depth bias, thickness
and 400x hit ramps. Sampling follows BlitzFX 1.1.0 ContactShadowsCS: 16 taps,
fixed normalized screen spacing (6 * renderHeight / (1920 * renderWidth)),
and a static per-pixel phase with the tree-specific offset. Reach limits the
world distance without redistributing the taps. Default remains 0.3 m; saved
values are retained. Native near-plane protection, screen-edge fade, physical
reach fade and the existing depth/normal bilateral filter remain intact.

The exact user-supplied BlitzFX archive was extracted and disassembled to verify
these rules. The matching local source is commit
659e239cfcba9cf0362621486ecdb241b0eee168. Differences are deliberate: our static
phase uses interleaved gradient noise instead of the external blue-noise map;
we retain the existing spatial filter and do not add normal-mapped self-shadowing.
The first sampling-only build was also rejected for noise/flicker; restoring
BlitzFX's trace without its temporal stabilization was insufficient. The current
revision adds contact-mask history as described below. It does not claim parity
with BlitzFX's complete combined-shadow pipeline. Trace work is 16 samples;
actual total frame cost remains unmeasured.

Validation: Release embed and addon object compile. Production lighting tests
pass on WARP and NVIDIA, including fixed sampling at 0.08/0.16/0.3/0.6 m across
axes/directions/subpixel phases and a shallow sloped plane that must not shadow
itself. The original stretched trace and rejected DDA fail the new suite.
The former thin-surface footprint fixture is removed because its zero-thickness
assumption does not validate the chosen screen-space heuristic. Existing native
lighting, PCSS, material, hair, binding-range, resize and pooled-bound tests pass.
An additional GPU comparison executes the original BlitzFX package bytecode with
matched static offsets: character-blocker masks match exactly on both adapters
for both axes and light directions, away from our added bounds/fades. This is
limited shader evidence, not a claim of whole-scene or temporal equivalence.

Evidence: tmp/witcher3classic-investigation/contact-blitz-20261028, including
reference.cpp/reference.cmd and the extracted original shaders. Logs:
tmp/contact-blitz-tests.log, contact-blitz-reference.log,
contact-blitz-original-negative.log and contact-blitz-dda-negative.log.
The in-game screenshot confirms the rejected version's faceted forehead/neck.
DevKit accepted diagnostic shadow overrides, but they did not change the active
addon output; they were restored and the temporary file/path cleaned up.

Build target: thewitcher3classic, preset clang-x64-release; inspect generated
embed/0xF3C40021.h. After relaunch, compare contact shadows off/on in this same
close-up, inspect idle animation for flicker, then change reach and camera angle.
Also check foliage and DLSS/DLAA. Live acceptance remains pending.

Deployment: Release DLL linked after shutdown; game-folder symlink hash verified.
Build log: tmp/contact-blitz-release.log. Scene acceptance is still pending.


### Contact-shadow temporal stabilization

The pipeline is pack (0xF3C40020), trace (0xF3C40021), spatial filter
(0xF3C40023), then temporal reprojection/clamping (0xF3C40022). BlitzFX also
filters spatial observations before temporal clipping. Our first temporal build
had those operations reversed, allowing individual noisy taps to retain excessive
old darkness. The native shadow PS now consumes the filtered result directly;
there is no second spatial blur. The existing depth/normal-aware 3x3 footprint,
16-tap trace, depth slab and 0.3 m default remain unchanged.

The spatial pass reuses the RG32F packing texture after the trace has finished,
so it adds a dispatch but no texture allocation. Two render-sized R16G16
visibility/depth textures alternate as history. Native frame, light and control
constants are copied on the GPU, preserving ranged CB bindings. No CPU readback.
Maximum history weight is 80%; the trace's spatial phase stays static.

World surfaces use the previous jittered camera. Covered animated objects use
existing depth-validated object vectors and explicit projection-jitter correction.
Characters without valid object history use the spatially filtered current mask.
Offscreen/disoccluded samples, camera cuts, changed projection/light/controls or
active rectangle, frame gaps, failed inputs and resizes reject history.

Validation: Release embeds and addon object compile. contact_history.cpp passes
on WARP and NVIDIA: impulse footprint, image boundaries, depth/opposing-normal
edges, isolated noisy-tap history clipping, noise attenuation, object motion plus
jitter, depth/offscreen rejection, blocker removal and reset conditions.
lighting.cpp compares the production prefilter against an independent CPU
reference, and checks actual history resources, GPU CB ranges, state restoration,
frame gaps, input recovery, accumulation and settings reset. Existing lighting,
material, reach, hair and shadow-atlas regressions pass on both adapters.
Logs: tmp/contact-prefilter-object.log, tmp/contact-prefilter-history.log and
tmp/contact-prefilter-lighting.log. Release DLL contains the new shaders and is loaded after relaunch. The user
accepted the current appearance on 2026-10-28; exhaustive animation/frame-cost
validation remains outside this acceptance.

Scene evidence and limitations: exact D24 capture/replay reproduces repeated
silhouettes from the original stretched sparse trace and the broad ribbon from
the current depth slab. Large shadows alone do not prove an error: sunlight
angle and receiver curvature matter, and one visible depth surface does not
provide an occluder's full thickness. Surface-only/dense/sloped prototypes remove
the ribbon but expose faceted facial shadows; they were not adopted. Consecutive
installed-build captures still show variation around the strand. Runtime logs
confirm face/hair motion draws, but DevKit cannot directly capture the private
history buffer, so per-pixel history acceptance remains unverified in this scene.
Scratch evidence: tmp/witcher3classic-investigation/contact-strand-20261028.

For further regression checks, compare the same close-up with Contact Shadows on/off,
inspect idle animation for flicker/trails, then test foliage, camera motion and
DLSS/DLAA. Do not call this physically exact or visually accepted based on GPU
unit tests alone. Total frame cost still requires a live measurement.
