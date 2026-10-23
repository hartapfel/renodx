# Witcher 3 Classic: motion-vector implementation research

**Historical research with a current-state correction (2026-10-23):** start with
the [DLSS integration playbook](DLSS_INTEGRATION_PLAYBOOK.md). The early text below
predates the shader-family fix, real upscaling, coherent jitter, accepted
tail/foliage coverage and the successful cache-invalidation performance fix.
Statements that these are unimplemented or that no timings exist are historical.
The user reports broad motion coverage and substantially improved performance;
explicit cut handling, wider acceptance and soft-transparent layers remain open.
Use the top of the [current handoff](WITCHER3_CLASSIC_HDR_HANDOFF.md) for deployment
status, rather than an old checkpoint's PID or pending-link instruction.

Research date: 2026-10-23. Scope: native DX11 NGX DLAA/DLSS integration in
Classic 1.32. This is an implementation audit, not a claim of completed motion
coverage or measured production performance. The current camera-triggered NPC
coverage failure remains a live acceptance test.

The source-linked implementation reference, including the exact identity,
deformation, native clip precision and shader-family work needed for reuse in
other games, is [OBJECT_MOTION_VECTOR_INTEGRATION.md](OBJECT_MOTION_VECTOR_INTEGRATION.md).
The latest installed artifact and pending live checks are at the top of the
[Classic handoff](WITCHER3_CLASSIC_HDR_HANDOFF.md).

## Primary sources and implications

| Source | Finding relevant to this implementation | Decision |
|---|---|---|
| [NVIDIA DLSS programming guide, sections 3.6–3.7](https://raw.githubusercontent.com/NVIDIA/DLSS/main/doc/DLSS_Programming_Guide_Release.pdf) | Motion maps current pixels to previous locations; float RG16/RG32 is accepted. Standard low-resolution vectors match input color resolution; DLSS performs their dilation internally. Jitter and motion flags/scales must agree. | Keep render-resolution RG16 vectors with the existing direct-NGX UV-to-pixel scale. Do not interpret MVLowRes as an arbitrary half-resolution option. |
| [NVIDIA Streamline DLSS integration guide](https://github.com/NVIDIA-RTX/Streamline/blob/main/docs/ProgrammingGuideDLSS.md) | Required inputs include color, depth and vectors; frame/viewport inputs must be coherent and graphics state restored after evaluation. | Use the existing isolated DX11 context state and native TAA replacement point. Streamline is a reference, not a new wrapper dependency. |
| [Unity URP object-motion shader](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.universal/ShaderLibrary/ObjectMotionVectors.hlsl) | Separates current raster position from unjittered current/previous positions, consumes old deformed positions, and preserves alpha-test/LOD-fade behavior. | Track deformation as well as instance worlds; keep native material discards. Test all active character permutations. |
| [Unity skinned-motion documentation](https://docs.unity.com/en-us/engine/6000.7/script-reference/unityengine/skinnedmeshrenderer/skinnedmotionvectors) | Animated motion uses current and previous skinning data; previous deformed vertices require storage. | A still root transform does not mean a character can use camera-only vectors. Keep previous palettes or previous CPU-deformed vertices. |
| [Unity HDRP motion-vector stages](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.high-definition/Documentation~/Motion-Vectors.md) | Object vectors are followed by camera vectors for remaining pixels. | Static buildings need camera reprojection, not extra object-motion MRT writes. |
| [Epic TSR documentation: parallax, vertex animation and translucency](https://dev.epicgames.com/documentation/en-us/unreal-engine/temporal-super-resolution-in-unreal-engine) | Reprojection/depth diagnostics matter; animated vertex effects need previous parameters. Additional velocity draws have a cost. Translucent motion/depth cannot be blended like color. | Reuse the original opaque/alpha-tested draw. Do not add indiscriminate velocity passes or treat transparent layers as opaque. |
| [AMD FSR temporal integration documentation](https://gpuopen.com/manuals/fidelityfx_sdk/techniques/super-resolution-temporal/) | Render-resolution vectors are standard. Its dilation follows foreground depth in a neighborhood. | Useful cross-check of depth/edge handling; do not copy FSR's internal dilation into DLSS, which already handles standard input vectors. |
| [Microsoft SM5 precise modifier](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/precise) | Floating-point refactoring can affect invariance. | Compare original and replacement clip positions on actual hardware before blaming a native depth-prepass mismatch or changing depth tests. |
| [CDPR REDkit overview](https://www.thewitcher.com/us/en/redkit/modding) | Provides mesh/animation and world/scene authoring tools. | Potential asset/LOD inspection and controlled-scene aid; no verified public Classic 1.32 runtime-vector interface was established. It is not required to debug the injected DX11 path. |

## Resolution and performance

Half **precision** RG16 and half **resolution** are different choices. The addon
already uses two 16-bit floating-point channels for vectors. At native-resolution
DLAA, rendered color and output are both 3840×2160 in the user's current session.
An arbitrarily 1920×1080 motion field would not match the current input contract.
Making it usable would require reconstruction/edge handling and validation; it
would not repair missing object identity, shader coverage or previous poses.

For future DLSS upscaling, a genuinely lower-resolution game render can supply
vectors at that same lower input resolution while DLSS produces a larger output.
That requires integrating lower-resolution scene rendering, which is not yet
implemented. Downsampling the already completed native-resolution scene is not
a rendering-performance solution.

Current decisions based on the code audit:

- Preserve camera reprojection for stationary rigid scenery. The first stability
  test expanded that scenery only in the vector view; the user reported the
  distraction/cost, and that expansion is removed in the next revision.
- Retain the existing motion MRTs on native geometry draws. No second geometry
  traversal or geometry draw is introduced for the new material variants.
- Reuse bounded CPU sidecar storage and the existing GPU pose table. Ordinary
  skinned instances use exact native proxy/packing identity rather than a map
  keyed by shared world transforms or transient GPU ring offsets.
- Skip stationary rigid batches before pose copying/upload. Animated skinning
  does not perform the stationary rigid comparison loop.
- Keep previous palette GPU copy once per rendered frame and previous deformed
  mesh copies once per observed mesh/frame. There are no production readbacks.
- Arm DevKit captures only for bounded investigations and release preserved GPU
  textures immediately after saving them. Exact captures affect timing and must
  be disabled during performance measurements.

These choices reduce avoidable work, but **no matched-scene CPU/GPU timing result
has yet been recorded**. Do not describe them as zero overhead or a proven
performance improvement. Measure with object vectors on/off under the same
camera path, DLAA settings and scene; keep the diagnostic view/capture off.

## Reliability and the camera-only failure

The user's clarification is decisive: at a fixed camera angle the NPC can have
complete coverage; moving the camera makes individual parts disappear. Keep the
NPC stationary while testing this. Do not substitute a test of moving NPCs with
a static camera and call the reported problem fixed.

Observed facts on 2026-10-23:

1. The first identity-based Release build loaded successfully, but the user
   explicitly reported the NPC flicker remained. Its expanded building coverage
   was not the requested result.
2. Read-only CPU observations of that running build found 792 recently observed
   proxies in one sample, four invalid rigid histories and **zero invalid skinned
   proxy histories**. This is concurrent CPU data, not an atomic GPU result; it
   does not prove every shader, palette or pixel was valid.
3. The exact NPC scene has additional unhandled material pairs, including known
   head VS 4B5AEE17 paired with PS 035DA93A, body VS 9BA913EE paired with PS
   E76C261A, and reference-skin VS 8E6AB350 paired with the existing head PS.
   Adding coverage is necessary, but is not yet proven to resolve the complete
   camera-only failure.
4. Added native-equivalence cases for those six shaders. The fixture compares
   original G-buffer color, expected motion/depth and restores native targets.
   A separate clip-position test varies camera/instance transforms and all four
   bone influences across 24 cases for each of 21 non-deformed G-buffer vertex
   shaders: **6,048 component comparisons, all bit-identical**, on WARP and the
   actual hardware device. This did not reproduce a depth-position mismatch;
   it is a regression, not proof of all real scene inputs or coverage.
5. The next build logs actual native depth-state settings once per bounded shader
   acceptance/rejection diagnostic. It also logs native object-motion/depth SRV
   handles once per allocation so DevKit can inspect the real surfaces.
   Prepared-motion/responsive addresses in that log are explicitly **texture**
   addresses, not SRV handles; never pass them as resource-view handles.

For the next live test, distinguish:

- **Dark:** object-motion MRT was not written at that pixel, or was overwritten
  by another surface. Identify shader/material/depth coverage.
- **Amber:** the surface wrote a rejected-history marker. Trace palette, exact
  instance identity, previous reference/deformed vertices, frame gap or clipping.
- **Valid motion color:** check the actual final prepared vector and reprojection;
  changes in hue alone are not missing coverage.

The optional view shows raw object MRTs. DLAA receives the merged camera/object
field after the separate final-depth test. These are distinct diagnostics.

## Native renderer patching

Renderer patching is already part of this integration: eight fingerprinted
native hooks expose instance submission, palette lifetime, CPU deformation,
proxy destruction, packing and flock submission. Persistent engine ownership
supplies identity; normal ReShade texture snapshots cannot replace it.

Earlier live inspection of the native motion-blur shader C3F99418 established
camera/depth reprojection, not an existing dense animated-object vector field.
There is no proven dormant complete object-vector buffer to enable with a flag.

A deeper patch can retain previous transforms/deformation closer to the native
update stage or extend common native shader-generation/submission code. Such a
patch still must preserve the previous **rendered** pose, not merely the previous
simulation update, and cover materials/LOD changes and destruction. Native CPU
buffers rotating between updates are not automatically previous-frame history.
Do not add another native hook or assume a field's meaning without Ghidra and
live-capture evidence. Do not bypass depth/alpha/lifetime checks to conceal holes.

## Acceptance work still required

- Same stationary NPC, camera still versus slow/fast rotation and translation;
  prove continuous visible head/body/gear coverage across affected angles.
- Root motion plus bone animation, facial changes, cloth, shared instances,
  birds, disocclusion, LOD transitions, return after culling and owner reuse.
- Correct scale/sign, jitter convention and presented-frame alignment in the
  final NGX motion field; no recurrent reset during normal panning.
- Image reprojection and DLAA output checks in addition to a colored vector view.
- Matched-scene CPU/GPU measurements with diagnostics off, and resource/resize/
  scene-cut tests. Wind vegetation, soft transparent layers and broader jitter
  integration remain unfinished.

Keep the feature marked as development/coverage under validation. No source or
synthetic test establishes a universal “100% reliable” guarantee.

## Offline shader-family coverage (2026-10-23)

The game caches contain native DXBC containers. Their bounded parsing and
signature inventory follow the [LLVM DirectX container description](https://llvm.org/docs/DirectX/DXContainer.html).
The installed content/DLC scan found 8,368 unique shaders, including 2,188
skinned vertex shaders in 80 output-layout families. A full SV_Position
expression match plus the native interface is stricter than matching a shader
name or BLENDINDICES signature. Unsupported control flow/deformation stays
unclassified. Material variants also require the native pixel input layout
and declaration order; original alpha/LOD math is retained before MRT output.

This is offline discovery and source generation. Runtime matching remains a
sorted hash lookup, and no native geometry is replayed. It addresses missing
permutations without adding runtime analysis, but cannot establish complete
object history, shader semantics, final reprojection or measured performance.
The current implementation/evidence and exclusions are in the latest Classic
handoff checkpoint. DevKit currently rejects the unregistered private native
MV/depth SRVs; only the tracked debug-output resource was used for long images.

## Opaque hair precision result (2026-10-23)

The B0B4EB6F opaque hair pass uses native depth EQUAL. With all varyings and
motion outputs consumed, the replacement's original position differed at the
bit level in 10/96 WARP cases. `precise` alone removed the WARP differences
but left 27/96 on NVIDIA hardware. Retaining 27 native fused `mad` operations
in the position-producing prefix together with a precise position output
produced zero differences on both devices. The native depth test is unchanged.
This follows the optimization constraints documented for Microsoft's
[`precise` modifier](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/precise),
but the actual equivalence result is from the local GPU tests. The hair fade
still requires live verification. Test hardware as well as WARP; approximate
varying equality cannot establish depth-EQUAL coverage.
