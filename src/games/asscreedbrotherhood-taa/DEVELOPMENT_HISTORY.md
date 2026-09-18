# Native TAA development history

Archived notes from the TAA prototype originally embedded in
`asscreedeziotrilogy`, preserved during extraction on 2026-09-17. Entries describe
successive builds and include superseded limitations, old paths, old setting
locations and earlier log names. Use [IMPLEMENTATION.md](./IMPLEMENTATION.md)
for the current design and [README.md](./README.md) for installation. Local
scratch paths remain under `tmp/asscreedeziotrilogy/taa/` so their evidence is
still discoverable. No historical “still needs verification” statement overrides
the later results in the current guide.

## Verified Brotherhood frame (2026-09-17)

3840x2160, MSAA disabled, 2,913 draws. Capture evidence is in
`tmp/asscreedeziotrilogy/taa/` (local development artifacts).

- Material draw 1600: VS `0x4B000956`, PS `0x276A3376`, FP16 color MRT0,
  full-resolution R32_FLOAT MRT1. The vertex shader uses c0-c3 for
  world-view-projection, c8-c11 for world. Registers contain matrix rows;
  `VP = WVP * inverse(World)` under the shader's column-vector convention.
- Native material shaders write interpolated clip z/w into MRT1. It is a
  sampleable color texture, so no hardware depth-format upgrade is required.
- LUT draw 2878 (`0x48DCE479`) reads full-resolution FP16 color at s0 and
  the 16-cubed LUT at s1. s8 still binds the material R32 texture. It is not
  read by the LUT shader; the implementation checks identity against the
  depth MRT captured during this frame instead of trusting a stale slot.
- White gradient 2879, downsample/blur 2880-2881, DOF 2882 (`0xDCF074DF`),
  copy 2883, then HUD. DOF s2 binds a **different** full-resolution R32
  texture. Do not substitute it without tracing the copy/resolve.
- DOF computes view depth as `c2.y / (sampledDepth + c2.x)`. Camera
  reprojection needs the original clip depth, without this conversion.
- DevKit's current resource reader rejects R32_FLOAT; a visual depth readback
  has not yet been obtained. Current proof is shader instructions and bindings.

## Input capture

Advanced settings > Diagnostics > **TAA Input Capture** enables read-only
native capture. Default is Off. A verified static-material vertex hash reads
camera matrices and retains MRT depth only until the scene pass/present/reset.
Two consistent material draws, matching scene dimensions/format and exact depth
identity are required. Missing scenes, conflicting cameras, multiple scene passes,
MSAA and reset invalidate the capture. Consecutive valid frames produce the
current-to-previous clip transform. Diagnostics are logged every 120 native frames.
Large clip-transform changes reject history as a preliminary cut safeguard;
object motion and more complete cut/teleport detection remain necessary.

`taa_reprojection.hlsli` supplies SM3-compatible camera reprojection with explicit
pixel jitter, D3D depth conventions and previous-frame bounds rejection.
Input Capture by itself adds no GPU textures and changes no game draw state.

## Experimental resolve

**Anti-Aliasing > Temporal Anti-Aliasing** defaults to Off. Experimental enables
the native SM3 pass; Depth Preview and Camera Motion Preview inspect its inputs.

- Eight-phase Halton(2,3) jitter modifies projection rows c0/c1 using c3, then
  restores all four original rows after each draw. The CTAB contract must name
  `g_WorldViewProj` at c0-c3; local shader definitions of those registers reject
  the path. In the Brotherhood dump, 264 of 277 vertex shaders meet this contract.
- Only draws using the captured main hardware-depth surface, full-size viewport
  and depth testing are eligible. Shadow targets, fullscreen passes and HUD are
  excluded by these checks. Unknown shaders and native Draw*UP paths are skipped;
  their coverage and translucent effects still need explicit investigation.
- The resolve runs immediately before `0x48DCE479`, supplies its s0 temporarily,
  and restores the native binding after the LUT draw. White gradient, DOF and HUD
  remain downstream. Native graphics state, MRTs, depth surface and viewport are
  saved/restored. A vertex buffer avoids the prior DrawPrimitiveUP replay issue.
- Two native FP16 histories store RGB and complementary clip depth (`1-z`) in
  alpha. This avoids the poor far-depth precision of storing conventional z in
  FP16 near 1. No separate depth history or cross-API transfers are allocated.
  Two R16F confidence histories track accumulation length independently of depth.
  At 4K color/depth and confidence together cost 158.2 MiB; this prototype rejects
  allocations above 160 MiB. Unsupported MRT formats or allocation failures must
  retain the native scene.
- Motion and history validation select the closest depth in a 3x3 footprint.
  This stabilizes foreground/background identity at subpixel silhouettes. History
  alpha stores that dilated depth, while the depth preview remains unmodified.
  Far-plane/sky depth 1 is valid; actual disocclusion still rejects history.
- Current color is reconstructed on the unjittered output grid. Camera reprojection,
  bounds/depth rejection, 3x3 variance clipping and reduced weight on motion/color
  disagreement limit stale history. Bounds use native gamma transport; blending
  decodes/encodes gamma 2.2 and preserves HDR values above SDR white.
- Per-pixel sample counts grow to 128 on stable pixels and drop with camera motion
  or rejected color. Invalid history/disocclusion resets them to one. Explicit
  nearest-half quantization prevents DX9 RT truncation from darkening long history.
- Missing input, mode change, reset and size change invalidate history. Allocation
  failure retains the native scene and stops further jitter until a reset/toggle.

This is an **experimental prototype**, not finished trilogy-wide TAA. Object/bone
motion now covers the audited paths below. Other character/material variants,
particles, unsupported jitter paths,
camera cuts and native DOF using a distinct depth resource need further validation.

## Remaining integration

1. Verify camera consistency while rotating/moving and compare a depth preview
   against scene geometry. Extend the audited vertex variants for all three games.
2. Validate the pre-LUT resolve's bloom stability and compare it with an earlier
   insertion ahead of bloom. Bloom is already composed at the current insertion.
3. Measure jitter coverage across depth/color/alpha-tested/transparent geometry;
   extend unsupported paths without affecting shadow maps or the HUD.
4. Generate camera motion from depth and the previous camera. For moving objects,
   capture previous world transforms; skinned characters additionally need previous
   bone transforms or an explicitly conservative history-rejection mask. Do not
   treat camera-only vectors as full object motion.
5. Add explicit particle/transparency reactivity and improve reconstruction beyond
   the prototype's bilinear filter. Exercise cuts, menus, loads and graphics resets.
6. Measure performance and process memory at 4K before adding velocity surfaces.

## Research / local references

- Alien Isolation: `aliasisolation/runtime/taa.hpp`, `runtime/jitter.hpp` and
  `shaders/aliasisolation_taa.cs_5_0.hlsl`. Its native velocities and DX11 compute
  path cannot be transplanted into DX9. Neighborhood bounds/history filtering,
  resource lifetime and pass insertion provide useful local examples.
- [Intel TAA](https://github.com/GameTechDev/TAA) and
  [resolve source](https://raw.githubusercontent.com/GameTechDev/TAA/master/MiniEngine/Core/Shaders/TAAResolve.hlsl):
  velocity reprojection, history/depth validation and neighborhood clipping.
- [AMD temporal integration guidance](https://gpuopen.com/manuals/fidelityfx_sdk/techniques/super-resolution-upscaler/):
  jitter conventions, pre-tonemap placement, motion vectors and transparency masks.
- [Wronski's Assassin's Creed implementation notes](https://bartwronski.com/2014/03/15/temporal-supersampling-and-antialiasing/):
  camera-only motion is insufficient for cloth/skinning/vegetation; incorrect
  vectors and pause/teleport transitions create ghosting or visible jitter.

## Verification

The x86 Release build succeeds (existing shared-library deprecation warnings).
CPU checks pass for 100 object transforms, inverse/singular/non-finite handling,
camera consistency and direct-versus-reprojected clip coordinates. The HLSL
reprojection helper compiles with FXC `/WX /T ps_3_0`; its diagnostic wrapper
uses 34 slots including one depth sample. This does not establish visual
reprojection correctness; GPU readback and motion tests remain necessary.

The resolve shader compiles with `/WX /T ps_3_0` within the SM3 instruction limit.
The native DX9 GPU fixture passes HDR seed preservation (4.0), stationary history,
actual temporal blending, depth rejection, identity/translated camera motion,
depth preview, state restoration and ResetEx after resource teardown. CTAB tests
accept 264/277 dumped shaders and reject truncated inputs; jitter samples stay
inside half a pixel. Evidence: `tmp/asscreedeziotrilogy/taa/test-resolve.cpp`.

The first in-game test exposed white output/square previews. The isolated kernel
fixture had used a vertex-buffer draw and missed the native LUT's DrawPrimitiveUP
replay. Adding `on_drawn` forces command_action to replay that game draw; ReShade
announces its uploaded temporary vertices but does not bind them. The addon must
bind the existing native-alpha module's UP buffers before the LUT draw and restore
the native stream/index unbind afterward, including when TAA is Off. The separate
ReShade/addon fixture reproduced this: regular draw RGB 0.503418, UP replay RGB 0.
Evidence: `tmp/asscreedeziotrilogy/taa/test-replay.cpp`, `replay-before/`.
The corrected Release addon produces RGB 0.503418 in both paths (`replay-after/`).

The subsequent visual test confirmed scene/depth output but exposed motion-preview
flicker and black rejection on fast turns. A captured world-space camera reproduced
`VP * inverse(VP)` float error of `4.37737e-4` even at rest. Both world-camera
reconstruction and reprojection now retain double precision through inversion and
multiplication, rounding only the completed transform for GPU upload. The same
stationary test is below `1e-12`. Cut detection uses projected movement rather than
raw matrix coefficients; frame gaps over 250 ms invalidate temporal history. The
motion preview shows large/out-of-bounds vectors instead of hiding rejected history.
The corrected Release build passes the native GPU resolve/state/reset fixture and
the actual-addon non-indexed UP replay comparison. The user subsequently confirmed
a substantial reduction in shimmering, with edge flicker still present.

The next in-game test reported improved shimmering but crawling/flickering edges.
The center-color disagreement weight was rejecting valid alternating edge coverage:
a 64-frame GPU checker test settled into a 0.199951..0.716309 oscillation at constant
depth and camera. Weight now reacts to history outside the neighborhood color box,
not the center sample; known jitter is removed from the camera-speed weight.
The same test settles into 0.572266..0.605957 (93.5% smaller oscillation), with
disocclusion rejection, HDR, previews, state restoration and reset tests passing.
This synthetic test does not establish complete in-game edge stability or object
motion handling; the updated addon still needs visual validation.

The user confirmed improved edges but remaining distant flicker. A second GPU
regression alternates distant foreground z=0.9995 and sky z=1 with edge coverage:
single-tap validation loses all accumulation (0.199951..0.799805). Nearest-depth
selection reduces that range to 0.572266..0.605957. A static diagonal silhouette
rasterized with the actual eight-phase Halton jitter settles to
0.487549..0.519531. Removing foreground rejects its history; previous HDR, depth,
motion, state and reset checks still pass. These are synthetic results; the
distant-edge revision still needs in-game visual confirmation. No extra history
surfaces are allocated; the 3x3 search adds eight depth texture samples.

The following in-game test confirmed better distant edges but visible stationary
jitter. The fixed 10% current contribution never fully settles. Per-pixel R16F
sample counts now allow longer stable accumulation while preserving fast reset
on disocclusion, camera motion and changed color. A 256-frame stationary test
reduces the diagonal's settled swing from 0.0319824 to 0.00195312. Count resets,
MRT1/sampler4/write-mask restoration and ResetEx pass in the native GPU fixture.
DX9 FP16 RT writes were also proven to truncate (.5003 -> .5); explicit nearest
half quantization removes the accumulating dark bias. The settled midpoint is
within 0.00226 of the eight-phase radiometric reference. The resolve compiles to
354 SM3 instruction slots. In-game stability, moving-object trails and performance
with the confidence textures still need confirmation; object motion is still not
captured.

An additional synthetic DrawIndexedPrimitiveUP test exposed an existing ReShade
buffer-creation bug: the checked-out `resize_primitive_up_buffers` writes the new
index buffer into `_primitive_up_vertex_buffer`. This is outside the captured
non-indexed LUT draw path and has not been fixed in the external dependency.
Do not claim indexed-UP support based on the passing non-indexed replay test.

Build target `asscreedeziotrilogy`, Release preset `clang-x86-release`.
Restart Brotherhood, leave MSAA off, enable TAA Input Capture in Advanced mode,
and inspect `ReShade.log` for `Ezio TAA input capture`. Expect repeated valid
consecutive pairs while a supported material is visible; absence must fail closed.
Test camera movement, pause/menu, loading, resolution changes and MSAA toggles.
The diagnostic currently covers only the audited material variant; full trilogy
coverage and visual reprojection/accumulation tests remain pending.

After restarting Brotherhood with the Release addon, the user enabled capture
and moved/rotated the camera. The runtime log repeatedly reports 5-10 matching
material draws, `cameraConflict=0 current=1 consecutivePair=1`, at 3840x2160.
The changing camera rows remain consistent across different objects in each
captured frame. Evidence: `tmp/asscreedeziotrilogy/taa/runtime-capture.log`.
This verifies native callback ordering, matrix/depth capture and consecutive
frame bookkeeping in that scene; reset/cut tests and visual vector validation
are still pending. The current image is unchanged by this diagnostic.

## Object and skeletal motion

**Object Motion** defaults to Experimental with TAA; Off retains camera-only
reprojection. **Object Motion Preview** displays matched motion in gray/colors,
unmatched previous poses in magenta and uncovered geometry in black.

- Uncompressed rigid variants are `0x4B000956` and `0xCFF33597`. Packed scenery
  variants are `0x7B3AA462`, `0xCBFA98A8`, `0x490226E1`, `0xCF25236F`,
  `0x6810707F`, `0x160DC1A8`, `0x72582374`, `0x967139C2`, `0x37DFB300`
  and `0xFC8CBBF0`; their positions decode as
  `position.xyz * abs(position.w * 3.81481368e-6)`.
  Skinned variants are `0x6ADF3971`,
  `0x73550BE7`, `0x91F6EBFA` and `0x89CCF177`. Their native position math was audited from SM3
  assembly: positions scale by 10 for skinning, four unnormalized weights combine
  rows from the 42-bone palette at c120-c245, followed by c0-c3 projection. Native
  clip-plane distance uses c8-c11 and c18, including homogeneous division for skin.
  `0x89CCF177` also retains current/previous normal displacement at c100.x.
  Wind variant `0xBDF4BDE9` retains c13 and c100-c105 for its two position-seeded
  sine oscillators. Replay uses the original compiler's sine-reduction literals.
  Trees `0xF53BF32F` and leaves `0x9E55FEF3` have a separate replay using their
  native TEXCOORD layout, compression, stencil/equation tables, distance/LOD morph,
  wind, UVs and opacity. Previous position constants use the same vertex texture
  as skeletal palettes. Their mutable-buffer variants remain excluded.
  Position outputs use `precise` and explicit branches: flattened selects and
  reassociated wind additions can change depth and leave holes in an EQUAL replay.
- Capture retains mesh buffers/declaration, draw range, current unjittered and
  jittered WVP, world and bone transforms. Identical multipass poses share history;
  distinct repeated instances can match at a unique unchanged world transform.
  Rigid identity ignores c11, which does not contribute to its world position.
  Filtered replay declarations retain only the attributes used for position and
  opacity; unused lighting data in another vertex stream no longer rejects a mesh.
  Required attributes may span native streams 0 and 1. The latter retains its
  buffer, offset and stride as part of mesh identity: live cloth stores UV/color
  there, while tree/leaf layouts store compressed positions there. Mutable
  secondary streams remain excluded.
  Moving repeated instances can match only when each is the other's sole
  candidate within 0.25 world units and a bounded rotation/scale change. Close
  or overlapping candidates retain missing-history handling. No nearest-neighbor
  ranking or draw-order association is used. Instances with ambiguous identities, missing poses,
  teleports, dynamic index buffers, instancing, unverified shaders and deformation paths
  are not guessed from draw order. Capture is capped at 2,048 draws per frame.
- Just before the LUT, a separate velocity pass replays verified opaque geometry
  against final native depth with EQUAL and depth writes disabled. Material
  capture includes later submissions to the same scene color/depth surfaces after
  MRT1 is detached, and color passes that reuse a depth prepass without writing Z.
  The native EQUAL replay still rejects occluded geometry. Clip-plane
  discard is reproduced. Alpha-tested draws are supported when bytecode proves
  output alpha is a normalized texture alpha, optionally multiplied by a material
  constant, an audited vertex opacity, and a final LOD fade constant. Identity 0/1 MAD lanes, final saturation,
  multiplication order, TEXCOORD0/1 and pixel-stage UV scaling are tracked. Replay
  retains the texture, all sampler settings, native comparison/reference and
  audited vertex UV scaling (1, 16, or 16 times c100.xy), applied before interpolation.
  Wind's vertex opacity includes its distance/LOD fade. All eight DX9 alpha
  comparisons are reproduced in the motion shader. Skin variants `0x6ADF3971`
  and `0x89CCF177` retain native position-W opacity (`position.w * 0.99999994`);
  unknown opacity calculations
  and other shader discards remain excluded. Previous
  bones use a 128x1 RGBA32F vertex texture, avoiding SM3's 256-constant limit.
  Brotherhood enables ALWAYS/REPLACE stencil tagging on these draws; it does not
  cull pixels. Capture accepts this state and replay disables stencil writes.
  Read-only stencil comparisons are retained with KEEP operations and no writes.
  Depth-writing LOD fades using BLENDFACTOR/INVBLENDFACTOR are captured too;
  these previously vanished from the preview during distance transitions.
  Audited SRCALPHA/INVSRCALPHA surfaces with depth writes off use their native
  LESS/LESSEQUAL test. Their vectors replace the underlying surface only at
  material opacity >= 0.5, preserving background motion through transparent holes.
  This represents the dominant layer; multiple translucent layers still share
  one velocity, so thin hair fringes cannot all receive independent vectors.
  Replay preserves each draw's viewport depth range as well as its depth bias;
  assuming a 0-1 range can reject valid captures or fail the depth equality test.
- Mutable vertex uploads are copied before native Unlock, then captured as
  immutable GPU buffers. Replay stream 2 supplies the previous position,
  weights, indices and displacement inputs. Later DISCARD uploads cannot change
  the captured draw. Valid byte ranges merge across partial uploads; DISCARD
  invalidates earlier ranges. ReShade's indexed-draw wrapper supplies the native
  minimum index and vertex count omitted from the generic draw event. Capture
  requires that full declared vertex range to have been uploaded, then stores
  only that range. Missing wrapper metadata or incomplete ranges retain fallback.
  Rotating upload-buffer addresses and offsets are excluded from mesh identity;
  static index topology, layout/range and an unambiguous pose are still required.
  CPU-deformed float-position clothing may already be in world coordinates:
  different NPCs can share both topology and an identity world matrix. Its
  immutable vertices provide a world-space centroid for the same mutually
  unique 0.25-unit step test. Double-precision accumulation avoids noisy anchors
  at large map coordinates; overlapping candidates and teleports still reject.
  CPU storage uses sparse 4 KiB pages for uploaded bytes, so rotating 4 MiB
  native buffers do not each reserve their full capacity and starve consecutive
  frames. The cache is bounded to 8 MiB CPU and 16 MiB GPU storage, with 4 MiB per buffer;
  the CPU budget includes immutable snapshot bytes used to compare duplicate
  material submissions exactly. Identical uploads can share a pose despite
  distinct upload allocations; different shapes remain ambiguous.
  unused entries retire after three frames. Device reset/disable releases them.
- RGBA16F motion stores previous-minus-current unjittered UV, previous complementary
  depth, and signed current complementary depth (negative means missing history).
  Resolve selects the vector at its nearest-depth tap. Hardware-depth-tested
  motion supplies current depth where later opaque geometry left the R32 MRT
  stale; agreeing R32 values retain their full precision. Unsupported pixels
  keep camera reprojection. Opaque replay retains native hardware depth equality.
- Motion adds 63.3 MiB at 4K; total TAA GPU surfaces cost 221.5 MiB with a 224 MiB
  allocation guard. The previous-pose caches also retain buffers for two frames.
  Default-pool resources and all retained poses are released on graphics reset or
  disabling the feature. Allocation/format failures retain camera-only TAA.

The native GPU fixture compares replay coverage against the ORIGINAL nineteen vertex
shaders, not an independently reconstructed reference. Coverage matches exactly
for tested rigid and four-bone triangles, with known XYZ animation, jitter and
palette indices 0-3 / 38-41, including indexed draws, both signs of packed position
scale and non-default viewport depth ranges. Alpha coverage matches native alpha
testing for all comparisons at reference 128/255, including coplanar geometry.
Native material pixel shaders `0xA2AC17DE`, `0xBA9071B6` and `0x712A66C5` also match
replay cutout coverage at seven alpha references, including vertex opacity and
pixel UV scaling. Wind coverage matches across 48 position-seeded animation phases;
known current/previous displacement and four-bone animation produce expected vectors.
Mutable rigid, skeletal and displaced geometry preserves exact coverage and
deformation vectors across partial DISCARD / NOOVERWRITE uploads, disjoint and
merged valid ranges, and a later DISCARD that overwrites the game buffer. Native
tree/leaf coverage and opacity match across 48 wind, morph and table-index phases;
stationary vectors stay zero and previous wind/LOD changes produce finite motion.
Vector sign/depth, duplicate/reordered identities,
missing poses, native state restoration and ResetEx pass. Resolve integration
tests verify previous object depth, unmatched-pose reset, preview colors and camera
fallback; stationary convergence remains unchanged. C++ syntax and SM3 `/WX`
compilation pass. Evidence: `tmp/asscreedeziotrilogy/taa/test-motion.cpp` and
`test-resolve.cpp`. Real-game capture coverage, animation trails and performance
still need final validation for the expanded coverage. The initial live scene
captured around 96 draws / 58 matched skeletal poses after correcting the stencil
and viewport-range guards; DevKit readback was fully finite. The isolated
ReShade/addon integration scene captures and matches both rigid meshes, including
a non-default viewport depth range and ALWAYS/REPLACE stencil, across 125 frames.
The 17-variant Release also passes with both meshes uploaded through DYNAMIC /
DISCARD buffers each frame: `mutableDraws=2 mutableMiss=0 motionReady=1`, with
288 bytes of retained geometry. This verifies the actual upload callbacks and
snapshot replay in the addon; live clothing coverage remains to be checked.
The 19-variant Release also passes a partial-upload integration scene: two large
buffers rotate each frame, with partial DISCARD / NOOVERWRITE writes, nonzero
stream offsets/base vertices and a native minimum index of four. Both draws
capture and match with zero upload misses and 288 bytes of retained geometry.
The split-stream Release also passes with native position/normal in stream 0
and static UV/color in stream 1, matching the live clothing layout. Both meshes
still capture and match after ResetEx, with zero upload misses and 288 bytes
retained. Its shader fixture preserves native tree/leaf coverage with their
required inputs split across streams 0 and 1. In-game coverage remains to be
verified for this build.
The sparse-cache regression rotates three 4 MiB buffers with partial uploads.
The previous full-capacity cache missed a mesh; the sparse Release captures and
matches both with zero upload misses after ResetEx. Cross-page upload/retirement
tests retain only 24 KiB of CPU pages for three partially written buffers.
The late-pass integration fixture captures and matches four submissions after
ResetEx, including two RGB-only draws after MRT1 is detached and one with depth
writes disabled. There are no upload misses or unmatched poses. Resolve tests
verify that hardware-depth-tested motion supersedes stale R32 depth while
stationary convergence stays unchanged. Identical independently uploaded cloth
poses group together; byte-different shapes remain ambiguous.
The subsequent Brotherhood live test confirmed broader clothing/scene coverage,
with 11 mutable draws, zero upload misses and roughly 630 captured draws in one
view. Further movement testing still showed frequent black/pink transitions and
missing hair/bushes. Read-only native-state sampling identified depth-writing LOD
cross-fades with read-only stencil tests, and alpha-blended hair without depth
writes. Foliage PS `0x43C46BC2` additionally multiplies output opacity by c30.x;
the earlier parser rejected that second material factor. The corrected paths
pass native-alpha, stencil, occlusion and replay GPU tests. The subsequent live
test captured 49 stencil-tested and 20 alpha-blended submissions in one frame;
both foliage variants passed capture. The user confirmed much better stability
and apparently complete coverage, with only occasional pink flashes remaining.
Read-only cloth data identified repeated world-space meshes across NPCs with
identity transforms. Their centroid matching regression passes reordered draws,
overlap rejection and large-jump rejection. The user reported little further
improvement in the remaining occasional flashes with that build.
The subsequent 11-variant build reached roughly 205-241 draws in the test scene;
the 15-variant Release build passes both the original-shader GPU fixture and the
addon integration fixture. It captured roughly 470 draws in the subsequent live
scene and the user confirmed much broader coverage. Remaining black capes/skirts
motivated the mutable-vertex path and additional profiles. Live inspection then
proved that Brotherhood uses partial uploads to rotating buffers, so the first
full-buffer snapshot path skipped those draws. Range capture, bounded moving
instance matching and the two tree profiles still need live verification.
`motionStages` in the log counts shader candidates, eligible topology/instances,
non-UP draws, matching hardware depth, matching scene color, viewport/deconstruction,
accepted render states, pixel shaders, opacity, stream/buffer, filtered declaration,
indices/ranges and completed captures. `motionMatchMiss` separates absent meshes
from ambiguous poses. With input capture and Object Motion Preview, bounded
`unmatched[VS]` samples report current/previous mesh and same-world draw counts.
`mutableDraws`, `mutableMiss` and `geometryBytes` report changing-vertex capture
and its retained GPU memory.
`motionProfile[VS]` reports the same capture stages per vertex shader when input
capture and Object Motion Preview are enabled, separating unsupported materials
from upload or layout failures.

### Water coverage limitation

Brotherhood's river pass uses VS `0x265E7205` / PS `0x659AB3BD`, outside
the audited object-motion profiles. Its mesh position is rigid, but three
animated normal-map transforms drive reflections/highlights and opacity depends
on scene depth and vertex alpha. Black water in Object Motion Preview therefore
means missing object vectors; the normal resolve still uses camera reprojection
at uncovered pixels. Mesh vectors alone cannot track that animated shading.
Water needs separately validated depth/opacity coverage and a reactive history
weight before it can be treated as a supported temporal surface.

The river scene also exposes a rectangular coverage gap inside the boat. The
normal scene shows wooden interior there. Its exact failing draw/visibility
condition is not yet isolated; temporary live shader diagnostics were
inconclusive. Do not relax opaque depth equality or assign water vectors to the
interior based only on this preview. All temporary shader overrides were removed.
