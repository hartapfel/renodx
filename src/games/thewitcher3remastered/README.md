# The Witcher 3 Remastered

DX12 HDR and SDR addon. The existing Vanilla (AgX), Vanilla+ (AgX Extended),
and RenoDX (Prism) options retain their order and defaults. Prism remains the
default. PsychoV-31 (Custom) is the fourth and last option.

## PsychoV-31 (Custom)

The game-local tone mapper uses the supplied `customtest31.hlsli` entry
`custom_psychotm_test31`, with its matching Test 30 support from the PsychoV31
shader bundle. Only includes, guards and the namespace are adapted; shared
shader libraries are unchanged. Chromatic aberration is ported from Hartapfel's
Witcher 3 addon.
PsychoV keeps exposed scene HDR through grading and maps it once before UI
composition: in the last grading pass for SDR, or the HDR output pass for HDR.
SDR targets BT.709 at unit peak; HDR uses the selected peak, game brightness,
and BT.709/BT.2020/Display P3 target. UI composition, frame-generation outputs, PQ encoding,
and the existing effects stay in their original passes.

PsychoV always uses native AgX contrast and its unbounded highlight extension.
**Shoulder Blend** and **Black Floor** remain adjustable in **Tone Mapping**.
Black Floor 0 targets zero black; 100 retains the native toe, with intermediate
values blending the low shoulder. Inflection/highlights stay fixed. Saved values
of the removed Native Slope Matching toggle no longer affect the pipeline.
Hable retains mid-grey matching and bypass stays unshaped. Each environment is
handled before blending, and exposure runs once.

Advanced settings expose adaptation/background anchors, gamut
compression/target, response compression, and gamma in the
**PsychoV-31 (Custom)** section below **Color Grading**. The custom mapper
handles tonal and saturation grading directly. Highlight hue, source boundary,
source awareness and SDR EOTF emulation use the implementation defaults
internally (0, None, 1 and Off respectively). Display gamut mapping is handled
by the game-local wrapper described below. Response Compression defaults to
0 (Auto). The active custom entry point has no separate Cone Response Exponent parameter;
that control belongs to the unused standard PsychoV entry point in the supplied
file. It is not exposed for this custom curve. The former Hue Shift is removed.
The existing highlights, shadows, split contrast, saturation, flare, and
contribution controls are reused. The LUT and analytic grade bridges preserve
signed wide-gamut inputs with a reversible proxy when grading improvements
are enabled.

Gamut Compression uses a game-local constant-Oklab-hue mapping after the
supplied PsychoV response. It first compresses chroma smoothly toward the
selected target's zero-channel boundary, preserving linear luminance. It then
fits peak brightness with a common RGB scale and a soft shoulder, allowing
bright saturated colours to lose luminance instead of bleaching toward white.
This second step preserves hue and relative chroma (C/L). The in-range neutral
curve is retained. Compression 0 bypasses both steps exactly; 100 fits the
selected BT.709, Display P3 or BT.2020 volume, with SDR always targeting BT.709.
Intermediate strengths blend toward that result and can remain out of gamut.
Signed BT.709 remains the transport representation, so it is not clamped to
BT.709 when a wider target is selected. Black remains zero. There is no
fire-specific hue rotation, and intentional Blowout still runs afterwards.
The hue/brightness distinction follows the principles discussed in
[Oklab gamut projection](https://bottosson.github.io/posts/gamutclipping/);
the target-boundary search and peak shoulder here are game-local implementations.

Before the PsychoV response, a narrow soft compression keeps near-zero and
negative cone components inside its positive LMS domain. The supplied signed
fallback otherwise sends a negative cone toward negative peak as exposure
increases, producing a saturated yellow-green plateau and a white seam across
the zero-cone boundary. This input correction preserves CIE luminance and is
exposure-independent; colours with all cone components above 2% of their
luminance-matched neutral bypass it exactly. Signed BT.709 and wide-gamut
colours remain supported. It is separate from the display-gamut slider and
does not alter the supplied mapper sources, native slope or black-floor controls.
Negative-domain artefacts and soft source compression are also discussed in
the [ACES reference gamut-compression overview](https://docs.acescentral.com/rgc/overview/);
this correction uses PsychoV's cone basis, not the ACES AP1 algorithm.

PsychoV Blowout uses uniform chroma bleaching, closer to Prism's behavior,
with an exact grayscale endpoint at 100. Zero preserves the original response;
the control preserves mapped luminance and behaves consistently in SDR/HDR.

PsychoV's global Saturation is applied to signed colour before its magnitude/sign
fallback, using the supplied mapper's physiological Yf neutral axis. This avoids
restoring coloured channel signs after desaturation on extreme hue-shifted
colours. Saturation 0 has an exact grayscale endpoint; default saturation 50
(internal 1) keeps the supplied response unchanged. Highlight Saturation remains
inside the mapper and operates on the globally adjusted colour.

**Color Grading Strength** under **Scene Grading** restores the original
upstream control for native grading applied after LUTs: 0 bypasses that grade,
100 retains its full contribution (default). It blends the linear RGB input
and graded output together, with no separate luminance/chroma adjustment.
LUT Grading Strength remains independent. Both controls are available for all
custom tone mappers (Vanilla+, Prism and PsychoV), including photo mode.
The experimental luminance/chroma controls and shader fields are removed.

**Grading Hue Shift** under **Scene Grading** is available for all custom tone
mappers. It is applied before each stage's strength blend.
Zero preserves the existing output; 100 rotates selected grading-added
pink/red colours (including peach/coral highlights) up to 30 degrees toward warmer hues per grading stage.
The three LUT paths and shared native grading path (including photo mode)
compare their input and reconstructed HDR output before the existing strength
blend. Normalizing both by linear luminance makes the colour selection
independent of scalar exposure, apart from a smooth near-black safeguard.
Unchanged colours and scalar-only grades are untouched. The selection is
strongest from -35 to 35 degrees in Oklab, fades through orange, and is zero
outside -65 to 65 degrees. Yellow is excluded; peach/coral highlights near
35 degrees remain selected instead of falling at the cutoff.
A pink-directed grade delta prioritizes combined red gain and yellow loss
over red gain alone. The selection also fades near neutrals and never rotates past
its 90-degree warm-yellow target.

The hue rotation holds Oklab lightness and chroma constant, then restores the
grade's linear luminance with a scalar RGB gain. That gain scales Oklab
lightness and chroma equally, preserving their ratio C/L rather than absolute
chroma. This avoids deliberately reducing colourfulness as the former
Red Grading Reduction did. The thresholds/window are a creative selection,
not a standardized correction or an estimate of objectively correct colours.

The Grading Hue Shift control does not change LUT sampling, signed HDR
reconstruction, target primaries or PsychoV gamut mapping. It adds no RGB clamp
or Rec.709 gamut boundary.
Hue rotation can create out-of-display-gamut values; the selected tone mapper
still handles them and may alter final colourfulness. Preserving luminance and
C/L here is before display mapping and the existing grade-strength blends,
not a guarantee about final display brightness/saturation. Each stage can add
up to 30 degrees; their combined result is not one global 30-degree rotation.

There is no skin, material or flame detection. Colours already present before
a grade are protected from an unchanged/scalar-only grade; additional pink/red
colour introduced by grading can still be shifted, including on flame edges.
Photo-mode white balance before the reference sample is outside this control.

The approach uses [Oklab hue/chroma separation](https://bottosson.github.io/posts/oklab/)
and leaves [display gamut handling](https://docs.acescentral.com/system-components/output-transforms/technical-details/gamut-compression/)
to the existing mapper. Validate 0/50/100 in warm interiors, daylight, skin,
red fabrics/lights, foliage, near-black ramps and photo mode in SDR/HDR.
Setting a stage's grading strength to zero also removes its hue correction.
Preset Off resets the hue shift.

Black Floor is available for PsychoV alongside the other custom tone mappers.
Prism primaries and the AgX debug canvas remain exclusive to Prism's developer
menu; vanilla inverse tone mapping remains disabled outside Vanilla. Shared
grading and effects stay available, and HDR-only controls follow the output mode.

RenoFX adds optional RenoDX chromatic aberration with intensity and start-offset
controls. Native CA remains the default; selecting RenoDX replaces native CA
where present, including photo mode. Existing RCAS is still applied once.

Bloom scales the final additive RGB once in both native composite variants
(`0x7DC213EE` with lens effects, `0x5E320F6F` without). The shared extraction
keeps its existing HDR reference at unit strength, so the slider no longer
changes its threshold response or affects the shaft input there. Bloom 0/50/100
means zero/reference/twice the additive contribution before display mapping.

Sunshafts Strength scales the depth-masked sky source `0x1132ADF9`, as in
Hartapfel. The archived native Light Shafts toggle removes that pass and its
filters; it does not use `0xB281002E`, where the slider was previously applied.
The alternate radial shader no longer applies a second multiplier. The masked
source has no RGB metadata marker: no downstream shader decoded it, and it
could survive a zero setting as a red contribution. Sunshafts 0/50/100 means
zero/reference/twice the source input; downstream extraction remains nonlinear.
Keep native Bloom and Light Shafts enabled when testing these controls.

Photo mode uses the shared gameplay grading routine when Grading Improvements
is Upgraded, including PsychoV's HDR proxy/reconstruction and the pre-shaper
reference for native grading strength/hue. Native photo exposure, contrast, white
balance, saturation, grain, vignette and output encoding remain in their original
order. The Vanilla/Original grading path is preserved.

## Injection and compatibility

Settings use upstream root-CBV injection at `b13, space50`. The 260-byte payload
occupies a 512-byte aligned buffer and consumes two root-signature DWORDs.
The captured 33-DWORD game layout therefore uses 35 DWORDs; Dynamic Grass's
three additional root descriptors bring it to 41, below the 64-DWORD limit.
There is no packed-settings or root-constant fallback in this addon.

Descriptor-table history tracing remains disabled. The port uses the existing
bloom metadata path rather than adding a curve-capture UAV or movie-resource
redirection. Darker Nights remains a separate addon. Load only one Witcher HDR
addon at a time; the preserved Hartapfel HDR addon is an alternative build.

Retained OopyDoopy settings keep their identifiers, including the restored
ColorGradeStrength key. Hartapfel's
saved `ToneMapType=1` means Vanilla+ here, so select PsychoV-31 (Custom) explicitly after
switching from that addon. Its packed settings are not migrated automatically.

## Build and validation

From an x64 Visual Studio developer shell, with the game closed:

```powershell
cmake --build --preset clang-x64-release --target thewitcher3remastered --parallel 4
```

Inspect `build/Release/renodx-thewitcher3remastered.addon64` and the generated
shader headers under `build/thewitcher3remastered.include/embed` (or the preset's configured
build directory). Use a Release build with a compatible Release DevKit.

Software-GPU checks cover existing-mode parity across 15 production passes,
PsychoV HDR/SDR finite output, the real DLL's root-CBV allocation/upload and
D3D12 reads, and Darker Nights addon initialization/destruction in both load
orders. These checks do not establish live visual quality, timing, or
compatibility with every third-party addon.

Native slope matching is automatic; the full-grayscale Blowout endpoint is retained.
Software-GPU checks isolate shader behavior and are not captured full-frame A/B
comparisons. The custom implementation still requires in-game visual validation.

Before opening the PR, verify in game:

1. Compare all four tone mappers in SDR and HDR. Test SDR output encodings,
   peak/game/UI brightness, settings reset, and Preset Off. Confirm that
   PsychoV is last and has no brightness-compensation control.
2. Check Toussaint, interiors, night, weather transitions, saturated lights,
   and cutscenes. Compare PsychoV with Prism/Vanilla+ at neutral grading, then
   confirm PsychoV automatically follows native AgX contrast. Test Shoulder Blend
   0/20/100 and Black Floor 0/50/100 (corrected to native toe), including dark
   caves. Confirm old saved slope-toggle values cannot disable matching.
   Test the advanced PsychoV controls, LUT and grading
   contributions at 0/50/100, and all three HDR gamut targets.
   Compare sunset and fire highlights at Gamut Compression 0/50/100: colour
   should survive peak fitting, with lower highlight luminance where necessary.
   Check neutral ramps, Saturation 0 and Blowout 100, and measure frame times.
   Check bright cutscene flares/embers with response Compression 3.5 and Auto,
   including the yellow-green/white transition, and compare the previously
   validated sunset/fire scenes for retained warmth.
3. Compare native/custom CA, intensity zero, and start offset one in gameplay,
   cutscenes and photo mode. Check bloom, lens dirt, sunshafts, depth blur,
   vignette, RCAS and grain independently. Test Bloom and Sunshafts at 0/50/100
   outdoors with the sun visible/occluded, in HDR/SDR and both bloom orders.
   Repeat Bloom with Camera Lens Effects on/off; check that each slider controls
   its intended contribution without repeated scaling or a red corner artifact.
4. Check frame generation on/off, UI alpha/brightness, pause/map/photo menus,
   and video playback. Confirm no double tone mapping or sharpening. Compare
   gameplay and photo mode at the same camera/exposure with photo filters reset,
   then vary photo exposure/temperature/saturation and scene grading strength/hue.
   Test all custom mappers in HDR/SDR with Grading Improvements set to Upgraded.
   Native photo white balance is preserved, so deliberate photo adjustments
   should still affect colour.
5. Relaunch with the normal ReShade addon set and Dynamic Grass, then with
   Darker Nights enabled. Check loading, shader coverage, ReShade FX output,
   frame times, logs, and HDR/SDR transitions. Both addon load orders must work.

Live validation of this merged build is still pending.
