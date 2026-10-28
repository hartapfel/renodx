# Effect comparison and water seam repair (2026-10-28)

## Confirmed water repair

Standalone water pixel shader `volumetrics/0x28D7BDFE.ps_5_0.hlsl` had the same
metadata-row decompilation error previously repaired in BlitzFX water
`blitzfx/0x2825099C.ps_5_0.hlsl`. See the water-line investigation in
`docs/WITCHER3_CLASSIC_BLITZFX_COMPATIBILITY.md`.

Original 28D7BDFE DXBC instructions 63-65 set integer row 1, then load `t17`
row 0 for world bounds and row 1 for atlas UV bounds. The decompiler expressed
the integer bit pattern as float `1.40129846e-045`. Converting that float to
the integer texture Load coordinate selects row 0 instead. World bounds were
therefore used as UV bounds. The resulting terrain-height lookup corrupted
water normal blending and produced straight diagonal seams.

The repair is numeric `r9.yzw = float3(1,0,0)`. It restores the original
metadata contract; it does not reduce reflection, refraction, direct sunlight,
foam or custom fog. Do not globally replace denormals: some shader constants
really contain integer bits and require `asuint`, whereas this decompilation
uses numeric floats followed by casts to texture coordinates.

Evidence and acceptance:

- Captured Native/Native, Custom-fog-only, Custom-water-only and both-Custom
  combinations at the same paused river view.
- Removing SSR did not remove the seams (user confirmed). Refraction, foam,
  normal variance and water-fog comparisons did not isolate their cause.
- Removing direct sun made them much less visible but did not eliminate them.
  Do not retain that diagnostic as a fix.
- A normal-output diagnostic showed the seams upstream of reflection lighting.
- The corrected complete water shader was loaded live with all contributions
  restored. The user confirmed: "yes, it looks perfect now".
- `tests/water.cpp` executes the actual production metadata-load statements on
  a synthetic 64-tile table with distinct world and atlas rows. It verifies
  every channel selects the correct rows. WARP and NVIDIA pass, alongside the
  existing refraction, fog, Fresnel and resource-lifetime checks. This focused
  regression is not a full original-versus-modified water shader comparison.

Local evidence: `tmp/witcher3classic-investigation/effect-audit-20261028/`,
including `water-original.asm`, `water-normal-t0.exr`, `water-row-fixed-t0.exr`,
the four comparison captures, `test-water-row.log` and `water-live/`.
The live folder contains only the corrected 28D7BDFE shader. Never globally
unload live replacements: that can also remove embedded addon replacements.

Packaging: source and live shader are corrected. Full Release addon linking
must wait until Classic exits. A live result does not establish that the
installed DLL contains the fix.

## Broader comparison: findings and unfinished work

Follow-up: the subsequent direct lighting/shadow revision is documented in
`LIGHTING.md` under **Direct BlitzFX comparison revision (2026-10-28)**.
It supersedes the initial lighting/contact-filtering findings in the table
below: material-aware contact packing/tracing/filtering, standalone UNORM
material protection, specular normal filtering, gather blocker search and
local shadow-atlas decoding are now implemented and GPU-tested. The bloom,
DOF, volumetric and remaining shader-selector notes below are still open.

Reference source is the local BlitzFX checkout at
`tmp/witcher3classic-investigation/volumetrics-20261027/blitz-source`, commit
`659e239cfcba9cf0362621486ecdb241b0eee168`. Compare its
`resources/shaders_v2` shaders and `source/rendering/rendering_engine.cpp`.
These are implementation comparisons, not proof of superior visual quality.

| Feature | Finding / current status |
| --- | --- |
| Soft shadows | BlitzFX preserves material-specific filter radius and vegetation gradient and filters temporally rotated sampling. Our source now restores those material parameters and includes a centre blocker tap. Our fixed sampling still lacks equivalent temporal filtering. |
| Contact shadows | BlitzFX uses material/depth/normal information and spatial/temporal filtering. Our source now rejects unsupported hair/translucency/tree materials and uses depth-continuous neighbours for normals. Filtering remains a quality gap. |
| PBR | Our correlated-Smith specular model is intentional. Source now adds the missing energy-normalized Burley diffuse response. Specular normal-variance filtering still needs audit and validation. |
| HairWorks | BlitzFX evaluates shadows per vertex/domain shader; our per-pixel filtering may cost more. Native linkage and color equivalence are tested; performance and visual parity are not established. |
| Atmospheric fog | Our froxel integration differs from BlitzFX's authored weather/fog treatment. Weather colors, environment-specific fog, intermediate cascade transitions and temporal stability remain to compare. Do not change the validated clip-W distance convention to reciprocal-W. |
| Water | Metadata seams fixed and accepted above. Preserve the previously accepted refraction, shoreline and sunlight-through-fog corrections. |
| Bloom | BlitzFX uses a multiresolution pyramid with Karis downsampling. Our quarter-resolution box/Gaussian approach has a size-dependent gain discontinuity and coarse radius changes to investigate. No repair claimed yet. |
| Depth of field | Our signed near/far gather lacks a comparable hole-fill stage. Needs visual comparison at foreground silhouettes and large blur radii. |
| Motion blur | Our camera/object modes and tile/neighbor-max reconstruction intentionally differ from BlitzFX's camera-only treatment. Preserve the camera-follow character fix. |
| CA, grain, vignette, sharpening | Full comparison remains pending. Preserve accepted controls and DLSS ordering. |

The lighting source changes above pass the WARP/NVIDIA lighting fixture
(`test-lighting.log` in the audit directory), but are not yet visually accepted
or linked into the running addon. Do not describe the whole audit as finished.

Additional proven decompiler candidates, not yet changed in this batch:

- `water/0x47CC9FA1.ps_5_0.hlsl`: seven hemisphere selectors rendered as
  `condition ? 0.000000 : 0`; original DXBC uses integer `and ..., l(1)`.
  Extend the original-bytecode comparison to exercise both atlas hemispheres
  before changing them. Evidence: audit `0x47CC9FA1.asm`.
- `volumetrics/0xFD1D6FBF.ps_5_0.hlsl`: shadow cascade increment similarly
  rendered as zero. Original instructions 282-285 compare, mask integer 1,
  add to cascade, then clamp. Evidence: volumetrics scratch
  `FD1D6FBF.disassembly.txt`. Validate both sides of the cascade boundary.

Next: package the accepted water repair after shutdown; finish those native
equivalence regressions; then evaluate the lighting changes independently and
address the filtering/bloom/DOF gaps with measured captures. Maintain Native
fallbacks and repeat without BlitzFX as well as with it.
