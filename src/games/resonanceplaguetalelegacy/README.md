# Resonance: A Plague Tale Legacy

This module keeps Ritsu's original Resonance implementation as its tonemapping baseline and adds optional controls and effects at explicit extension points.

## Active shader layout

- `test30.hlsl` is the author's local PsychoV-30 implementation.
- `lutbuilders/` preserves the complete native LUT construction, then applies the PsychoV-30 replacement at the same final LUT-builder extension point used by APTLegacy.
- `tonemappers/` keeps the author's four original post-process variants at the root and groups the additional verified variants by CA/native-effect permutation. Every added variant follows the same author contract: preserve the complete native path for Vanilla, capture the post-LUT signal before the native HDR curve for PsychoV, and replace only the final RGB assignment with `RenderIntermediatePass`.
- `output/` contains the HDR output transform plus the optional HDR RCAS hook.
- `common.hlsli` owns only the additional game-specific grading and effect helpers.

## Pipeline contract

- Vanilla leaves the game's native HDR, grading, film grain, chromatic aberration, and sharpening paths unchanged.
- The LUT builder decodes the native LUT input and output into the same scene-linear domain. The advanced LUT Luminance Curve control scales only the native LUT's luminance delta while retaining its hue and tint; the resulting artistically graded scene signal is then mapped by PsychoV-30. This matches the proven APTLegacy control semantics and avoids changing peak brightness in the postprocess shaders.
- Grading controls supported directly by PsychoV-30 are passed into the author's call. Additional controls run at adjacent LUT-building extension points.
- The postprocess shaders do not call a second tonemapper. All 102 known variants skip the native curve only for PsychoV and carry its post-LUT BT.709 signal with `RenderIntermediatePass`. The custom assignment restores the native intermediate's R11G11B10-style stochastic rounding so LUT luminance curves remain smooth. Scene and HUD retain one consistent gamut interpretation before the game's native BT.709-to-BT.2020 HDR output conversion.
- Custom film grain and chromatic aberration replace their native counterparts only when explicitly selected.
- HDR RCAS is applied in the output pass and is bounded by black and peak-brightness guards.

## Verification

- Build with `cmake --build --preset vs-x64-release --target resonanceplaguetalelegacy` and confirm `embed/shaders.h` registers 105 shaders: two LUT builders, 102 postprocess variants, and one output transform.
- With all replacements set to Native, compare Vanilla against the addon disabled; color, native HDR, CA, film grain, and sharpening should remain unchanged.
- Select PsychoV-30 and verify peak brightness, paper white, LUT luminance, exposure, gamma, highlights, shadows, contrast, saturation, highlight saturation, blowout, flare, and hue controls independently.
- Test native CA both enabled and disabled in the game, then switch the RenoDX CA replacement on and verify that neither state restores the native HDR curve.
- Check perceptual film grain and HDR RCAS separately at zero and maximum strength, including menus, dark gradients, and highlights near the configured peak.
