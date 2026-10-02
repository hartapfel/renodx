# Native HDR shader map

Inspected 2026-09-29 from `E:\SteamLibrary\steamapps\common\The Witcher 3\bin\x64_dx12\renodx-dev\dump`, plus live DevKit snapshots. All 463 original CSOs were copied and SHA-256 verified under `tmp/thewitcher3remastered/original`. The manifest and disassemblies are in the same scratch directory. No replacement shaders were registered or loaded during the initial investigation. The subsequent implementation is described in [README.md](./README.md); nineteen replacement shaders are now in the source in the addon. Scene rendering, grading controls and highlight rolloff were checked live before the frame-generation revision; its integrated runtime check remains pending.

## Frame-generation capture

Repeated snapshots were needed because generated-frame submissions often expose only a small part of the scene frame. Capture 7 contains 152 draws: additive bloom at 67, transition exposure at 68, flare at 72, previously uncovered LUT `0x0F6A9050` at 73, post grade `0x16967617` at 74, and previously uncovered HDR compositor `0x496222DA` at 149. Draw indices are capture-local. Evidence: `tmp/thewitcher3remastered/framegen-capture-7.json` and `framegen-targets.json`.

`0x0F6A9050` reads scene `t0` and LUTs `t1`/`t3`, with samplers `s0`/`s1`/`s3` and a 400-byte `b3`. Each LUT grade has its own strength/gain (`c1.yz` and `c2.yz`); `c2.w` blends the independently graded results. The replacement preserves that native math and alpha, bracketing the grade with the existing HDR proxy/reconstruction.

`0x496222DA` reads `t0`/`t1`/`t2`, `s1`, native `b3` (400 bytes), and `b12` (5456 bytes). Its first two targets match the normal compositor contract. Target 2 is an additional scene-only PQ output (RGB10A2), intentionally excluding UI, overlay dimming, and the optional regional view. Target 3 is the original UI alpha replicated to all channels (observed R8_UNORM target). The replacement applies PsychoV and perceptual grain separately to both HDR scene branches, using the same reference white and peak, and disables native highlight expansion in both. It retains the secondary gamma-shaped composite and exact UI mask. No resource format or root-layout changes were needed.

## Main replacement targets

The later cutscene capture (`cutscene-tail.json`, 2020 draws) uses `0xF961D049` at draw 1999 after native sharpening `0x3650C210` and flare `0xFB1B4062`, followed by the already covered HDR compositor `0x8F5737B5` at draw 2018. This post-grade variant reads scene `t0` with `s0` and a 400-byte `b3`, outputs RGBA16F, and performs the same power/colour/levels grade as the other post variants but has neither CA sampling nor a vignette mask. It preserves scene alpha. The added replacement applies the shared RCAS/CA sampling before the HDR proxy grade, then reconstructs signed HDR transport. Grain remains in the final compositor. This capture did not expose SRV bindings, so it is not a complete resource-binding trace. All fourteen replacements are included in the Release addon; the cutscene variant still needs integrated visual confirmation.

All four primary targets are **pixel shader model 6.6**. Register names below describe the original shaders, not the RenoDX injection buffer. Draw indices refer to the final inspected snapshot after the game restart; they are not stable identifiers.

| Shader | Live draw | Confirmed shader behaviour | Required work |
|---|---:|---|---|
| `0x382CDBDB` | 2389 | Loads scene RGB from `t0` and a scalar exposure/adaptation value from `t1(0,0)`. Applies exposure, selects Hable/AgX/bypass, and writes pre-curve luminance to alpha. | Main scene tone-map replacement. Bypass the native curve and carry exposed scene RGB to the final PsychoV pass; retain native processing for Vanilla. |
| `0x724E225F` | 3128 (later daytime capture) | Loads the same scene/adaptation inputs, evaluates two exposure/curve states, then blends RGB and pre-curve luminance with `b3.c13.x`. | Bypass both curves, retain the exposed-HDR transition blend, and map the result once at final scene composition. Absent from the first dump; original saved from the later dump. |
| `0x2F2D0992` | 2394 | Samples scene `t0`, converts `abs(RGB)` with gamma 1/2.2, clamps LUT coordinates, samples a packed colour LUT at `t1`, interpolates two blue slices, decodes with gamma 2.2, and blends the grade. Preserves source alpha. | Replace the bounded LUT path with a reconstructable grade bridge. Preserve the actual lookup layout, grade strength/gain, and alpha. |
| `0xAD02BAB3` | 2395 | Native post-processing: CA sampling, configurable power transform, lift/gain/power-like grade, luminance-dependent tint/saturation, gamma conversions, vignette, and output-level remapping. Preserves source alpha. | Adapt its colour domain and negative-channel handling for HDR. Select native or requested RenoDX CA while preserving the remaining effects. |
| `0x8F5737B5` | 2564 | Scene/UI composition, optional regional third-texture branch, BT.709-to-BT.2020 conversion, native HDR highlight expansion, peak limiting, and PQ encoding. Writes a second, gamma-shaped composite output. | Apply PsychoV after scene grading and before UI composition, bypass native HDR expansion, scale UI separately and retain the secondary output contract. |

Authoritative assembly: [scene tone mapper](../../../tmp/thewitcher3remastered/disassembly/0x382CDBDB.ps_6_6.txt), [LUT sampling](../../../tmp/thewitcher3remastered/disassembly/0x2F2D0992.ps_6_6.txt), [post-processing](../../../tmp/thewitcher3remastered/disassembly/0xAD02BAB3.ps_6_6.txt), [HDR output](../../../tmp/thewitcher3remastered/disassembly/0x8F5737B5.ps_6_6.txt).

## What the native HDR path actually retains

The native path is more specific than a blind expansion of a finished SDR frame. In `0x382CDBDB`, the scene is exposed **before** the tone-map switch. Its alpha output is `abs(dot(exposed_rgb, BT709_luminance_weights))`, independent of which native curve was selected. Later grading passes preserve this alpha. The final HDR shader uses scene alpha to control a highlight expansion after the RGB tone map/grade.

This preserves a scalar scene-brightness signal, but does not preserve the original RGB through the AgX/gamut/LUT operations. The replacement should preserve the original exposed scene RGB from `0x382CDBDB`/`0x724E225F` through grading, apply PsychoV before UI composition, and remove the native expansion in `0x8F5737B5`. Do not mistake the alpha channel for opacity or overwrite it casually while establishing the baseline.

### Scene tone mapper: `0x382CDBDB`

- Resources: `t0`, `t1`, `b3` (400 bytes), `b12` (5456 bytes); no sampler required for its texture loads.
- `b3.c4.x`: curve selector, converted to uint. `1` selects AgX; `2` bypasses the curve; the default branch evaluates the Hable-style rational curve.
- `t1.Load(0,0).x`: adaptation input, clamped with `b3.c4.yz` and a positive floor.
- `b3.c16.x/z`: participate in exposure normalization. The exposed scene is available immediately before the curve switch (original DXIL `%53..%55`).
- `b3.c7`, `b3.c8`, and `b3.c19`: curve/look parameters. `b3.c8.w` sets the AgX log-range anchor; the bounds are anchor/1024 and anchor*90.509666, spanning 16.5 stops.
- `b12.c221.w`: selects an alternative response inside the AgX branch. Both alternatives must survive in Vanilla.
- AgX is identified by its inset/outset matrices, log-domain normalization, polynomial coefficients including 15.5, -40.14 and 31.96, and gamma-2.2-shaped output conversion.
- RGB output is followed by pre-curve luminance in alpha. The live output is RGBA16F, 3840x2160.

### Transition tone mapper: `0x724E225F`

This daytime/environment variant replaces `0x382CDBDB` in the later capture. It shares `t0`, `t1`, `b3` (400 bytes), and `b12` (5456 bytes). Its two native curve selectors are `b3.c4.x` and `b3.c9.x`; adaptation limits and exposure use `c4.yz/c16.xz` and `c9.yz/c17.xz`. `b3.c13.x` blends the two RGB outputs and their pre-curve luminance in alpha. The custom path preserves each exposed scene and blends them before the single final PsychoV evaluation. The updated dump yielded 51 additional archived CSOs plus this separately saved variant; similarity scanning found no additional matching scene tone-map variants.

### Colour LUT: `0x2F2D0992`

This is a **LUT consumer, not a LUT builder**. The shader uses two `Texture2D` resources and `s0/s1`, with `b3` holding the viewport/grade controls.

Its lookup addresses 64 blue slices in an 8x8 atlas. The distinctive constants are 63.75, 0.99609375, 0.0078125, 0.015625 and 0.984375. Preserve this game's exact addressing instead of substituting a generic strip sampler. The underlying texture dimensions/format remain to be read from working SRV capture.

The input is converted from linear RGB to gamma 2.2 before lookup; the sampled grade is decoded back to linear. `b3.c1.y` controls grade strength and `b3.c1.z` scales the decoded LUT result. Scene alpha passes through unchanged.

The clamps and `abs` in this path are explicit shader limitations even though its render target is floating point. A float target alone does not make this LUT HDR-safe. Use a bounded, reconstructable LUT proxy and account for signed BT.709 representations of BT.2020 colours.

**No dedicated colour-LUT builder was identified in this dump or inspected frame.** All 463 binaries were disassembled; only this shader matched the game's packed colour-LUT lookup, and none declared a 3D texture binding. This does not exclude an initialization-only builder or an uncaptured variant. The LUT may be an uploaded/preauthored asset; confirm its resource upload history and producer before deciding to add a builder replacement. Environment/probe and exposure lookup passes are not colour-LUT builders.

### Post-processing: `0xAD02BAB3`

This pass follows LUT grading and writes RGBA16F. It reads only scene `t0` with `s1`, plus `b3`.

- `b3.c8.x`: initial RGB power transform.
- `b3.c14.xyz`: gain/offset/power-like transform.
- `b3.c10..c13`: luminance-dependent tint/saturation controls.
- `b3.c9.rgb`: RGB scaling.
- `b3.c6..c7`: vignette-related parameters.
- `b3.c15.xy`: final black/white-level remapping.
- `b3.c16..c17`: CA sampling controls.

These native operations are preserved and made compatible with the chosen HDR transport. The subsequently requested Native/RenoDX CA selector replaces only the CA sampling; the remaining native effect controls are retained. In particular, `abs`, lower clamps, gamma-shaped intermediate values, and saturation calculations need deliberate treatment if PsychoV emits signed wide-gamut RGB.

### HDR output: `0x8F5737B5`

- `t0.SampleLevel(s1, uv)`: scene-side input, including luminance metadata in alpha.
- `t1.Load(pixel-offset)`: overlay input; its alpha controls composition. Shader math and the separate live UI pass sequence identify its intended role; the exact bound resource is still unobserved.
- `t2`: optional regional input controlled by `b3.c1.z` and rectangle `b3.c3`. It is tone-mapped inside this branch. Determine its purpose in a dedicated capture before changing it; photo-mode/comparison use is only a hypothesis.
- `b3.c2.x`: input RGB decoding power; `b3.c2.z`: secondary-output encoding power. Read actual runtime values before assuming an exact transfer function.
- `b3.c0.x`: output luminance scale; `b3.c0.w`: final peak limit. Their usage is consistent with native paper white and peak nits.
- `b3.c7.x > 0` and scene alpha above `b3.c2.w`: enable the HDR-expansion branch. `b3.c7.w` selects the reference curve, `b3.c7.z` sets the high reference point, and `b3.c8` shapes the expansion.
- The shader evaluates the selected native curve at the reference point, derives a gain from peak/scale, and applies a scalar expansion to the already graded RGB. This is the native stage to bypass after PsychoV has mapped the scene.
- The final BT.2020 values are scaled, limited per channel to peak, divided by 10000, and PQ encoded using m1=0.1593017578125, m2=78.84375, c1=0.8359375, c2=18.8515625, c3=18.6875.
- `SV_Target0` writes the RGB10A2 swapchain. `SV_Target1` writes the separate gamma-shaped composite; the capture exposes an RGBA8 view but no resolved resource. Do not assume it is disposable or definitively assign it to frame generation without another trace.

## Supporting passes to preserve/audit

| Shader | Profile | Role and initial treatment |
|---|---|---|
| `0xBFD0F692` | `cs_6_6` | Builds a 256-bin luminance histogram from scene `t0`, with depth-dependent handling through `t1`. Keep native exposure metering. |
| `0x0703E06D` | `cs_6_6` | Reduces histogram bins over percentile bounds into a scalar luminance texture. Keep. |
| `0x020F162A` | `ps_6_6` | Temporally blends two scalar adaptation inputs using separate rise/fall rates; live output is R32F, 1x1. Keep. |
| `0x4BA8F638` | `cs_6_6` | Writes reciprocal of a scalar texture value into a 1x1 UAV. Exposure-related support; exact consumer still needs SRV tracing. |
| `0x0BF2A7DC` | `ps_6_6` | Bloom extraction with threshold and luminance limits. Do not confuse these bloom-only limits with the main scene tone map. |
| `0x7DC213EE` | `ps_6_6` | Bloom/dirt-style composite immediately before tone mapping: samples two textures and modulates RGB; live blend is additive (one/one). Preserve. |
| `0xC2169982`, `0x6DB9B38D`, `0x1520248A`, `0xE769EB46` | `ps_6_6` | Repeated pre-tone-map filtering/resampling passes in the bloom/post chain. Inspect only if transport/range changes require it. |
| `0x29754CAF`, `0x4B0ABFCA` | `ps_6_6` | Depth-dependent blur preparation/composite after scene tone mapping. Preserve effects and audit alpha/range compatibility. |
| `0x3650C210` | `cs_6_6` | Compute filtering/sharpening pass: reads `t0`, adds a scalar correction to RGB, preserves alpha, and writes `u0` without clamping the final RGB store. Left native. Exact resource connections still require tracing. |
| `0xFB1B4062` | `ps_6_6` | Post-tone-map screen blend: `1-(1-saturate(effect))*(1-scene)`, preserving scene alpha. Audit for HDR brightness distortion; preserve the native effect. |
| `0xFE6240E2` | `ps_6_6` | Simple sample/copy shader, used at several sizes including a small post-process output. Not itself a tone mapper. |

The live UI section contains SM5.1 pixel shaders such as `0x0001B1CA`, `0x09AED0EC`, `0x28CA1CD9`, `0x31B9774E`, `0x46DE79BA`, `0x98186149`, `0xA19CB895`, `0xBFA08BBA`, `0x1EDC7947`, and `0xD1A2F37B`. They draw after scene post-processing into separate RGBA8 targets. Initially scale/composite their completed overlay in the final HDR shader instead of replacing every UI shader. Check menu/video paths separately.

## Live resource evidence and limits

The running renderer is D3D12 with a 3840x2160, six-buffer RGB10A2 swapchain. ReShade.log records `SetColorSpace1(ColorSpace = 12)`, the full-range PQ/BT.2020 colour space. The final output shader's PQ/BT.2020 math agrees with this HDR10 path.

The scene tone-map, depth blur, LUT and final scene post targets observed in the frame are RGBA16F. The bloom chain also uses R11G11B10F. The RGBA8 targets in the late section belong to UI/small outputs; no full-resolution scene RGBA8 bottleneck was established. Start by keeping the native swapchain and scene resources; add upgrades only if a complete binding/copy trace proves they are needed.

Several scene textures are reused. For example, the resource written by the pre-tone-map additive pass is later overwritten by the LUT pass. `devkit_analyze_resource` explicitly reads **current live contents**, not a frozen copy at the selected draw. The observed mostly sub-1 RGB with alpha above 1 therefore cannot establish the range at the original tone-map input. Raw pre-tone-map HDR RGB still needs a per-draw capture/readback.

Descriptor and constant tracing were enabled and the game restarted, but the current DevKit still returns empty SRV/UAV binding lists and only one constant-buffer binding at slot 0 for these shaders, despite reflecting their actual b3/b12 and texture registers. Render targets, shader hashes, draw order and blend state are available. This is an inspection limitation, not evidence that the shaders have no inputs. Exact producer/consumer resource links, LUT format/upload history, and runtime cbuffer values remain unproven.

Evidence files under `tmp/thewitcher3remastered`:

- `manifest.json`, `index.json`: original hashes, profiles, resource declarations and static scan results.
- `live-draws.json`, `live-nonindexed-details.json`: first-frame order, render targets and blends.
- `live-resource-analysis.json`: live readback statistics, explicitly marked `snapshotExact: false`.
- `live-final-targets.json`, `live-final-details.json`: post-restart target checks; 2566 captured draws and 238 tracked shaders.
- `decompile-log.json`, `strict-validation.json`: decompiler/compile outcomes.

## Implementation status and remaining captures

The four main targets and `0xFB1B4062` are now implemented as editable replacements. Exposed scene RGB is transported through native LUT/screen-blend operations using a reconstructable luminance-axis gamut/N2 proxy, analytic post-processing retains its native encoding, and final output applies PsychoV after all scene grading, bypasses native highlight expansion, and independently scales UI. The optional regional input joins the scene before that same PsychoV pass; the secondary SDR composite remains populated.

The initial decompiler failures are resolved for all replacement targets. Ten strictly compiling native HLSL baselines are archived in [native/](./native/README.md). General fixes recover opaque typed resources and samplers, accept switch-ending metadata, and preserve sparse cbuffer sizes. The original broken analysis outputs under `tmp/.../decompiled` are superseded by `tmp/.../baselines` and the archived files.

The standalone compute shader `0x3650C210` still has a control-flow decompilation failure. Native/Vanilla retains its original binary; the later RCAS integration uses an explicitly custom copy bypass rather than a decompiled baseline (see below).

Remaining runtime work:

1. Compare archived unchanged baselines against native before visual evaluation of the custom path. The game was closed during implementation; compile and synthetic differential checks do not substitute for that capture.
2. Capture exact scene/LUT/UI resource bindings and runtime constants when DevKit binding tracking is available. Preserve upstream RGB before resource reuse. The shader code identifies the signal and register contracts, but not the actual current texture objects.
3. Check native HDR, photo/regional views, menus/video and frame-generation on/off. Verify the secondary output's consumer. SDR output variants were not captured or integrated.
4. Check neutral grading, highlights, signed saturated colours, LUT transitions, native effects, UI white, peak control and Vanilla/Off equivalence. Validate injection at b13/space50 and measure GPU cost of the custom path.

See the main README and native archive notes for completed strict compilation, binding/signature audits, differential checks and Release build evidence.

## Bloom and highlight roll-off audit (2026-09-29)

In the inspected transition frame, bloom extraction runs at draws 2998/3001, its filtered/dirt-modulated additive composite `0x7DC213EE` at 3021, and scene exposure/transition `0x724E225F` at 3022. The composite adds RGB with ONE/ONE blending into RGBA16F and outputs zero alpha; its RGB output is not saturated. The later `0xFB1B4062` screen blend runs at 3026. Disabling Bloom leaves these passes scheduled, so pass presence alone does not identify which parameter-controlled contributions remain. A temporary alpha-only constant probe was inconclusive and removed.

The important clipping issue was downstream amplification after early PsychoV mapping. The revised custom pipeline preserves exposed HDR across blur/filtering, screen blending, LUTs and display grading, then applies PsychoV to the combined scene just before UI composition/PQ. This covers both scene variants and the regional branch. Live output-cap occupancy fell from 16,345 pixels to zero at a 1000-nit peak, and the user confirmed improved detail. See the README for measurement limits; producer/consumer SRV tracking remains incomplete.

## Candle scene variants (2026-09-29)

In the 2534-draw indoor capture, `0x382CDBDB` runs at 2507, `0xFB1B4062` at 2511, the previously uncovered two-LUT blend `0x90AD6BBC` at 2512, post-grade variant `0x16967617` at 2513, and final HDR/UI `0x8F5737B5` at 2532. Both additional scene passes write full-resolution RGBA16F; `0xFE6240E2` instead produces a 228x128 RGBA8 auxiliary image. Do not confuse paired vertex shaders `0xA83070BA` and `0x5237FE3A` with those pixel hashes.

`0x90AD6BBC` shares the single-LUT addressing but reads t1 and t2, decodes both, blends by b3.c1.x, then applies gain c1.z and strength c1.y. Unmodified, it hard-clips HDR RGB at lookup addressing. Its replacement grades the bounded proxy and restores HDR afterward. `0x16967617` uses the same post-grade/vignette/levels chain as `0xAD02BAB3` without CA sampling; the same signed gamma transport is retained. Native baselines are archived. Both pass strict compilation, signature/binding/extent audits and 360-case differential comparisons, as do their forced-Vanilla paths.

A paused candle-scene readback shows yellow-green bands in flame gradients. The forced-custom two-pass diagnostic removed these bands. The original candle ROI contained no pixels at the final 1000-nit cap; a few elsewhere were capped, and the corrected bright flames can approach that cap, so global cap occupancy alone is not a measure of this artifact. The final pass probe confirmed PsychoV mode 1, peak 1000 and white 203. Guarded live replacements for unregistered hashes had no meaningful effect; both hashes are now registered in the Release addon, with runtime injection verification pending relaunch. All temporary forced and settings-probe overrides were unloaded. Files `candles-*.json`, EXRs and preview crops under `tmp/thewitcher3remastered` preserve the evidence. These are current-resource readbacks rather than a frozen A/B.

## Saturation controls (2026-09-29)

The missing LUT variants did not fully explain the reported candle artifacts. The user independently reproduced clipping by increasing regular Saturation with Highlight Saturation neutral. A WARP HLSL ramp test confirmed more gamut-boundary plateaus from pre-response LMS purity; the separate post-response OkLab highlight-saturation grade also exceeded target RGB bounds. The game-local wrapper now keeps PsychoV purity neutral and applies regular/highlight saturation and Blowout together in the selected display RGB gamut. Luminance and chroma direction are retained; positive chroma gain uses `1 + headroom * boost / (headroom + boost)` so it approaches the available gamut/peak headroom smoothly. Neutral controls return the existing PsychoV result directly.

The user confirmed the live output-shader revision works. Strict DX12 compilation passes all eight replacements; WARP tests cover 294,912 samples with no nonfinite or out-of-range output beyond 1e-5 relative tolerance at full gamut compression, and bit-identical neutral output. Other PsychoV gamut-compression strengths intentionally alter the core containment guarantee. The game exited before the attempted after-readback, so the live result is user-verified rather than a measured before/after resource comparison. Evidence is under `tmp/thewitcher3remastered/saturation/`.

## Peak detection and selectable CA (2026-09-29)

The addon now queries display peak luminance through the same `GetPeakNits` utility and startup-default policy as Ghost of Tsushima. Successful detection updates the reset value, preserves a nondefault manual setting, and runs once; unavailable detection leaves the 1000-nit fallback and allows retry on a later swapchain initialization.

Both post-grade variants now support Ghost of Tsushima's CA dispersion with the same axis-wise start mask, red/green offsets and bilinear sampling. `0xAD02BAB3` replaces its native CA branch when RenoDX is selected; `0x16967617` adds that same optional sampling when the game's native CA is absent. The local adapter samples exposed linear BT.709 directly, before the existing grade/encoding and final PsychoV stage. Alpha and UI are unaffected. No additional resource bindings or shader hashes are required. The settings payload grows from 20 to 23 DWORDs; the compatibility filter budgets its full size. See the main README for offline validation and pending runtime checks.

## RCAS and perceptual grain (2026-09-29)

The user confirmed the peak/CA revision works. The next capture contains native sharpening `0x3650C210` at dispatch 2160, screen blend at 2161, two-LUT grade at 2162, post-grade/CA at 2163 and final HDR/UI at 2183. Selecting Lilium RCAS substitutes a native-binding-only copy for that compute pass; Native/Vanilla retains the original binary. Its native decompile still fails, so the replacement is explicitly a new bypass shader, with the verified sample/write contract documented in `native/README.md`.

RCAS now feeds each center/fringe sample in both post variants. The math and effect order match GoT: RCAS, then CA, then perceptual grain. Grain uses the mapped linear BT.2020 scene in `0x8F5737B5` before UI composition, with the same perceptual density function and per-present seed. No native grain pass was identified; the user requested a standalone slider in that case. There are now nine registered hashes and 27 injected DWORDs. Compute layouts remain untouched. Strict compilation, WARP reference/copy tests and root budget checks pass; integrated RCAS/grain testing remains pending relaunch.

## Bloom/flare controls and texture-vignette variant (2026-09-29)

The 5891-draw capture contains additive bloom `0x7DC213EE` at 5817, main exposure at 5818, native sharpening at 5821, three `0xD1E7F080` sprite draws at 5822â€“5824, screen blend `0xFB1B4062` at 5825, LUT at 5826, uncovered post variant `0xC5AB358E` at 5827, and HDR/UI at 5889. The sprite target is 1920x1080 R11G11B10F; its live readback contains circular lens ghosts. This and the immediately following screen blend support identifying the latter as the lens-flare composite, although DevKit still does not expose its actual SRV bindings.

Bloom Strength scales `0x7DC213EE` RGB immediately before ONE/ONE blending; alpha remains zero. Sun Flare Strength scales the flare contribution before the screen-blend saturation, with exact scene passthrough at zero. Both default to 100 and operate before final PsychoV. They do not scale the scene, UI, sun disc or atmospheric scattering. Temporary bypasses did not explain the whole reported glow: the user saw little flare change and slight bloom improvement, and suspected native HDR was active.

`0xC5AB358E` explains an actual uncovered HDR path: it is the `0x16967617` post grade with the analytic vignette replaced by a t2/s2 texture lookup. The replacement preserves that lookup, brackets grading with the existing HDR proxy/reconstruction, and adds the same RCAS -> CA sampling. Grain still runs later in the final HDR shader. Both new originals are archived and audited. Eleven replacements compile strictly, the expanded payload is 29 DWORDs, and the existing root-layout restriction remains unchanged. Live appearance/injection checks are pending relaunch; probes were unloaded and the live path restored to the mod folder.

## Interior spatial tint/highlight composite: `0xDFD5C392`

The 2026-09-30 interior capture runs this pixel shader directly after the covered exposure transition pass and a material-mask helper (`0x19A9F88E`), before upscaling, LUTs and final PsychoV mapping. It reads scene `t0/s0`, depth `t1/s1`, and a five-tap mask `t2/s2`, with native `b3` (400 bytes) and `b12` (5456 bytes). It reconstructs position from depth, computes distance-dependent luminance tint, adds mask-based colour and then unconditionally applies `min(rgb, 1.1)`. The clamp remains even when the effect strength is zero. The precise game-facing name of this effect has not been verified.

The initial live exposure target retained RGB values above 1000 while the composite target stopped at 1.099609375 (half-float 1.1); later LUT output remained around 1.7. These readbacks are live and not frame-frozen. This proves a shader ceiling before final display mapping, rather than a display-peak setting or compensation gain alone. The replacement bypasses only that upper clamp in valid PsychoV mode and preserves native alpha and effect math. Vanilla retains the original cap. No resource upgrade is needed for its RGBA16F target.

The supporting mask shader is not modified or claimed as a validated baseline: its standalone decompile failed strict compilation, and its original binary remains archived in scratch. The actual clipping shader decompiled successfully and passed structural/differential checks.

DevKit live unload also removed the currently active addon runtime replacements during inspection; loading the covered pixel set restored HDR exposure. The new hash remains inactive until included in the addon, because this mod defers replacement to draw time and looks up its registered custom shader table. Do not treat an MCP activation flag as proof of execution for a newly added hash.

## Cutscene CA without vignette: `0x9600E32A`

The 2026-10-01 capture (1,354 draws) uses `0x382CDBDB` at draw 1339, native sharpening `0x3650C210` at 1346, screen blend `0xFB1B4062` at 1347, this previously unregistered post-process at 1348, and covered output/grain `0x8F5737B5` at 1352. This explains why grain works while the RCAS and CA controls are absent. The pass reads scene `t0/s1`, has a 400-byte `b3`, and writes 3840x2160 RGBA16F. It has native radial CA using `c16/c17` and the same analytic grade as `0xF961D049`, with neither a vignette nor a second UV semantic.

The replacement preserves original Vanilla code and native CA selection. In PsychoV it sharpens the center and displaced samples before native/RenoDX CA, then calls the shared HDR-safe grade with a zero vignette mask. Native alpha passes through. Grain stays in the final compositor after these effects. No layout, setting, or payload changes are needed; CMake discovers the additional hash automatically. Baseline and effect validation are recorded in `tmp/thewitcher3remastered/cutscene-oct01/`; integrated execution requires rebuilding the registered addon table. No live shader overrides were loaded during this capture.

## Native effect intensity controls (2026-10-01)

| Native option | Proven passes | Control location |
|---|---|---|
| Depth of Field | `0x29754CAF`, `0x4B0ABFCA`; both disappear when disabled | Scale the native depth blur factor before preparation quantization and resolve radius/discard. |
| Light Shafts | `0x1132ADF9` plus two `0x6DB9B38D` draws disappear when disabled | Scale RGB once in the depth-masked sky input, leaving the shared radial filter and alpha unchanged. |
| Camera Lens Effects | `0x7DC213EE` swaps to `0x5E320F6F` when disabled | Scale only the texture-modulated lens-dirt term before adding base bloom; retain Bloom Strength in both variants. |

These stages precede the scene grade/final HDR compositor and therefore cover downstream regular/frame-generation post-process variants without repeated attenuation. The archived frame-generation draws share the same effect hashes; archived cutscenes confirm the bloom+dirt variant. The 526-binary archive was scanned for similar contracts/math, with no additional matching DOF/shaft/dirt variant identified. This does not prove coverage of uncaptured cutscene-specific effects.

The game's Blur option is separate from Motion Blur (`AllowBlur` versus `AllowMotionBlur`). Sprint/dodge captures did not establish a Blur pass; Witcher Senses `0xDBABCC6C` also remains present with Blur off. Blur is intentionally deferred at the user's request and has no inactive slider. Live comparison captures and validation: `tmp/thewitcher3remastered/effect-controls/`.

### Original-mod comparison correction

`0x0C19D45C` (old depth blur) maps to `0x4B0ABFCA`. Blur now follows the old non-sky radius multiplier and restores its `saturate(sum_of_sample_alpha * 25)` output. Remaster native outputs zero alpha, so the captured source-alpha blend suppresses its RGB regardless of radius. Preparation `0x29754CAF` is no longer replaced. The earlier DOF-control description above records the superseded implementation. Lens dirt and sunshaft multiplication points match the old shaders; slider mapping is now 0/50/100 = 0×/1×/2×. A live execution check remains needed for the reported unresponsive shaft/dirt controls.


## Motion blur (2026-10-03)

Native Motion Blur controls a three-dispatch chain after depth blur and before
sharpening, lens-flare composition and LUT grading. Turning it off removes the
chain. The two observed final-resolve variants are both intercepted.

| Hash | Role | Thread group |
|---|---|---|
| `0x9F1C32F1` | Convert object motion; reconstruct camera motion from depth for sentinel pixels | 8x8 |
| `0x5388164E` | Reduced color/velocity preparation (native b0, 116 bytes) | 8x8 |
| `0x47C602BB` | Reduced-resolution line blur | 8x8 |
| `0x866E78BC` | Final resolve, observed at native intensity 1 | 16x16 |
| `0x2B7AF9F0` | Final resolve, observed at native intensity 10 | 16x16 |

Verified with DevKit after correcting extended root-signature tracking:

- Conversion t0 is 2560x1440 depth, t1 is object motion and u0 is converted
  motion. It runs twice, writing RGBA16F and RG16F resources respectively.
- Resolve t1 is full-resolution 3840x2160 linear HDR (RGBA16F); t2 references the
  RGBA16F conversion output. u0 is another full-resolution RGBA16F texture.
- `0x29754CAF` has the projection constants in graphics b12 (a descriptor-table
  CBV). Native depth linearization is
  `1 / ((rawDepth * c22.x + c22.y) * c21.x + c21.y)`.
- Conversion b10 contains dimensions and the current-to-previous clip transform.
  The camera branch computes a UV displacement; the output is negated for both
  camera and object branches. This is before the native blur intensity scaling.

Enhanced mode takes a private R32F depth snapshot at conversion, keyed to the
exact motion-output resource. It then bypasses the native resolve using the
following private shaders; their identifiers are excluded from the native hash
replacement map:

| Private identifier | Role |
|---|---|
| `0xF3B10003` | Copy depth while the native conversion already has it readable |
| `0xF3B10000` | Longest motion in each 32x32 output-pixel tile |
| `0xF3B10001` | Neighboring dominant motion for silhouette coverage |
| `0xF3B10002` | Full-resolution, depth-aware two-direction reconstruction |

The half-shutter radius is `motionUV * outputSize * shutterAngle / 720`, capped
at 32 output pixels. Thus frame-rate scaling comes from per-frame displacement;
no second delta-time multiplier or native intensity constant is used. Native
low-resolution blur is unused when the private reconstruction succeeds. The
original dispatch remains the fallback for incomplete bindings, Native mode or
Vanilla tone mapping. Both graphics and compute bindings are restored afterward.

Live checks confirmed loading, responsive 0/180-degree shutter control, Geralt
remaining clear during camera orbit, and identical Enhanced strength at native
intensity 1 and 10. A repeated live comparison confirmed less blur at higher FPS.
At a 30 FPS cap the user reported roughly unchanged GPU usage
versus Native; this is not an isolated GPU timestamp measurement. See
`tests/README.md` for numerical reference checks and remaining verification.
