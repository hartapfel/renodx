# A Plague Tale: Requiem

This module ports the proven Resonance: A Plague Tale Legacy pipeline to Requiem's own LUT builder, post-process variants, and HDR output transform.

## Active shader layout

- `test30.hlsl` is the local PsychoV-30 implementation used by the Resonance reference mod.
- `lutbuilders/` preserves Requiem's complete native LUT construction, then applies PsychoV-30 at the final LUT-builder extension point.
- `tonemappers/ca_on/` and `tonemappers/ca_off/` contain every verified Requiem post-process permutation. Each variant preserves the complete native path for Vanilla, captures the post-LUT signal before the native HDR curve for PsychoV, and replaces only the final RGB assignment with `RenderIntermediatePass`.
- `hud/` contains the verified Requiem UI permutations used to apply UI brightness and SDR gamma without changing scene contrast or native alpha coverage.
- `output/` contains the HDR output transform plus the optional HDR RCAS hook.
- `common.hlsli` owns only the additional game-specific grading and effect helpers.

## Pipeline contract

- Vanilla leaves the game's native HDR, grading, film grain, chromatic aberration, and sharpening paths unchanged.
- The LUT builder decodes the native LUT input and output into the same scene-linear domain. The advanced LUT Luminance Curve control scales only the native LUT's luminance delta while retaining its hue and tint; the resulting artistically graded scene signal is then mapped by PsychoV-30. This matches the proven APTLegacy control semantics and avoids changing peak brightness in the postprocess shaders.
- PsychoV can emulate the SDR display response with None, gamma 2.2, or BT.1886 options. Gamma 2.2 is the default; the correction is applied to both the scene and verified HUD draws before their fixed sRGB intermediate encode, matching the native HDR transform's sRGB decoder without affecting Vanilla.
- Grading controls supported directly by PsychoV-30 are passed into the author's call. Additional controls run at adjacent LUT-building extension points.
- The postprocess shaders do not call a second tonemapper. All 34 known variants skip the native curve only for PsychoV and carry its post-LUT BT.709 signal with `RenderIntermediatePass`. The custom assignment restores the native intermediate's R11G11B10-style stochastic rounding so LUT luminance curves remain smooth. Scene and HUD retain one consistent gamut interpretation before the game's native BT.709-to-BT.2020 HDR output conversion.
- PsychoV keeps the scene and final HDR output transform fixed at a 203-nit intermediate reference. Verified HUD shaders scale their own sRGB-encoded RGB in linear light before native composition, preserving scene contrast beneath translucent UI while independently controlling UI brightness.
- Custom film grain and chromatic aberration replace their native counterparts only when explicitly selected.
- HDR RCAS is applied in the output pass and is bounded by black and peak-brightness guards.

## Verification

- Build with `cmake --build --preset vs-x64-release --target aptrequiem` and confirm `embed/shaders.h` registers 42 shaders: one LUT builder, 34 postprocess variants, six HUD variants, and one output transform.
- With all replacements set to Native, compare Vanilla against the addon disabled; color, native HDR, CA, film grain, and sharpening should remain unchanged.
- Select PsychoV-30 and verify peak brightness, paper white, UI brightness, SDR gamma emulation, LUT luminance, exposure, gamma, highlights, shadows, contrast, saturation, highlight saturation, blowout, flare, and hue controls independently.
- Test native CA both enabled and disabled in the game, then switch the RenoDX CA replacement on and verify that neither state restores the native HDR curve.
- Check perceptual film grain and HDR RCAS separately at zero and maximum strength, including menus, dark gradients, and highlights near the configured peak.
