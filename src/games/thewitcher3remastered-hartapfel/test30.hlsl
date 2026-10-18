#ifndef RENODX_SHADERS_TONEMAP_PSYCHOV_TEST30_HLSL_
#define RENODX_SHADERS_TONEMAP_PSYCHOV_TEST30_HLSL_

#include "../../shaders/color.hlsl"
#include "../../shaders/math.hlsl"

/*
 * Copyright (C) 2026 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

namespace renodx {
namespace tonemap {
namespace psychov {

// PsychoV30: selected Mean-A2 / physiological-Yf response
// =========================================================
//
// Signal contract
// ---------------
// Input and output are direct linear-light BT.709 RGB with D65 white.
// `peak_value` expresses display peak in reference-white-relative units.
// The target volume is the normalized linear BT.709 RGB cube for mode 0 or
// the normalized linear BT.2020 RGB cube for every other mode. Output remains
// represented as linear BT.709 even when the constrained target is BT.2020.
// The shader trusts the pixel signal and every uniform. NaN, infinity, and
// invalid parameter combinations are not sanitized, clamped into a valid
// configuration, or replaced with fallback colors.
//
// Scientific basis and engineering stages
// ---------------------------------------
// - RGB is transformed to the Stockman/CVRL two-degree LMS basis.
// - The achromatic coordinate is physiological Yf from the
//   Stockman-Sharpe LMS-to-XfYfZf transform:
//
//       Yf = cL * L + cM * M
//
//   Yf is the relative observer coordinate formed by weighted L and M cone
//   responses.
// - Purity is direct LMS interpolation toward the adapting neutral while
//   retaining the adaptation-relative Yf coordinate. It does not require
//   MacLeod-Boynton coordinates or short-wave weighting.
// - Adaptation-relative cone ratios are consistent with the early-cone
//   background-normalization framework discussed by Stockman and Brainard.
// - The finite endpoint, Mean-A2 direction, and locked-direction target-cube
//   projection are the rendering-response and device-mapping stages.
//
// Signed cone response
// --------------------
// Let q_i = LMS_i / anchor_in_i, P_i = peak_value * D65_LMS_i,
// p = contrast * cone_response_exponent, and
// k_i = pow(anchor_out_i / P_i, h). Test30 evaluates:
//
//   beta_i = p * h / (1 - k_i)
//   e_i    = k_i / (k_i + (1 - k_i) * pow(abs(q_i), -beta_i))
//   u_i    = sign(q_i) * pow(e_i, 1 / h)
//
// The conceptual response is P_i * u_i. The direct rational form remains finite
// when the corresponding positive power overflows. It preserves
// anchor_in -> anchor_out, has
// adaptation-point logarithmic slope p, approaches zero as q -> 0, and
// approaches selected peak white as q -> infinity.
//
// Mean-A2 direction
// -----------------
// A2 denotes the equivalent orthonormal cone-opponent geometry. Test30 carries
// radical-free scaled coordinates for normalized cone load u:
//
//   D = uL - uM
//   C = uL + uM + uS
//   T = 2 * uS - uL - uM
//
// The equivalent orthonormal coordinates are X=D/sqrt(2), C0=C/sqrt(3), and
// Z=T/sqrt(6), so 6*rho^2=3*D^2+T^2. Source A2 direction comes from
// adaptation-relative q; response A2 direction comes from peak-relative
// post-G u. Normalizing and adding the two directions in this explicit metric
// gives their exact angular bisector. Test30 retains the response A2 radius
// and C, replacing direction only.
//
// Exact target solve
// ------------------
// With D65 Yf fractions alphaL + alphaM = 1, the normalized physiological
// coordinate represented by (D, C, T) is:
//
//   A = [2*C + 3*(alphaL-alphaM)*D - T] / 6
//
// Target RGB is affine in A, D, and T. Locking the authored A2 direction and
// scaling (D, T) by s makes all lower/upper RGB-cube planes and the response
// Yf ceiling linear inequalities in (C, s). The feasible set is a convex
// polygon. Segment projection uses
//
//   6*distance^2 = 2*delta_C^2 + (3*D^2 + T^2)*delta_s^2
//
// which is exactly the equivalent orthonormal Euclidean distance under the
// locked direction. Full compression analytically finds the nearest point
// inside this fixed-direction model's four-edge feasible polygon.
//
// Zero and negative cone coordinates use the same response and target solve.
// The odd continuation preserves positive-cone contrast and is continuous at
// zero; it is an engineering extension for signed wide-gamut coordinates.
// Full target compression maps nonpositive response Yf to black.
//
// PsychoV research record
// =======================
//
// This record is carried forward through PsychoV tests so each successor keeps
// the scientific rationale, source attribution, selected implementation, and
// next research directions beside the shader that ships. Test30 extends the
// Test17-Test25 record with Mean-A2 response authoring and an exact
// fixed-direction device-cube projection.
//
// Research objective and system boundary
// --------------------------------------
// PsychoV studies two coupled systems:
//
// 1. Observer-side organization: receptor coordinates, adaptation-relative
//    cone state, achromatic and opponent coordinates, response shaping, and
//    visibility/gain mechanisms supported by vision research.
// 2. Device-hull mapping: a joint tone, direction, and target-volume solve
//    constrained by display primaries, white, reference-white scale, and peak.
//
// Test30's selected rendering pipeline is:
//
//   linear-light BT.709
//     -> Stockman/CVRL LMS
//     -> scalar physiological-Yf grading
//     -> adaptation-relative LMS purity
//     -> adaptation-relative common cone power
//     -> anchor-matched finite per-cone G
//     -> Mean-A2 direction with post-G radius and scaled C
//     -> exact fixed-direction target RGB-cube/Yf projection
//     -> linear-light BT.709 representation
//
// The caller supplies the current adaptation and desired output-background
// anchors. The runtime signal is reference-white-relative. Absolute retinal
// scale, local/temporal adaptation estimation, visibility thresholds, and
// cortical gain form explicit successor-test research directions below.
//
// 1) Receptor basis and observer coordinates
// ------------------------------------------
// Brainard's Colorimetry chapter supplies the cone-stage/color-match
// foundation. Stockman and Brainard build on that receptor basis for
// first-site and second-site adaptation. Test30 transforms linear-light
// BT.709 through XYZ to the Stockman/CVRL two-degree LMS fit.
//
// Sources:
//   https://color2.psych.upenn.edu/brainard/papers/Brainard_Stockman_Colorimetry.pdf
//   https://color2.psych.upenn.edu/brainard/papers/Stockman_Brainard_ColorVision.pdf
//
// The published Stockman-Sharpe fundamentals include standard prereceptoral
// lens and macular filtering for an average, mainly foveal two-degree observer.
// CVRL documents the ocular-media and macular-pigment filters, their strong
// short-wavelength absorption, and their observer variation. Successor tests
// can expose age, field size, eccentricity, lens, and macular assumptions when
// personalized observer transforms become an input.
//
// Sources:
//   http://www.cvrl.org/background.htm
//   http://www.cvrl.org/database/text/intros/intromaclens.htm
//
// Test30 carries physiological Yf:
//
//   physiological Yf = cL * L + cM * M
//
// where cL and cM come directly from the Yf row of the base
// Stockman-Sharpe LMS-to-XfYfZf transform. The selected purity and response
// stages operate directly in LMS and Yf and do not use an S-cone weight.
//
// 2) Early cone adaptation
// ------------------------
// Stockman and Brainard express first-site L-cone contrast as
//
//   C_L = delta_L / (L_b + L_0)
//
// with corresponding M- and S-cone forms. Equivalently, the background sets
// the cone gain:
//
//   g_L = 1 / (L_b + L_0)
//   g_L * (L - L_b) = delta_L / (L_b + L_0)
//
// Test30 receives caller-authored adaptation LMS as `anchor_in` and uses
// q_i = LMS_i / anchor_in_i as its static background-relative state. This
// preserves the architecture of cone-specific normalization while keeping
// adaptation policy in the caller. A successor with image/retinal context can
// estimate L_b, M_b, S_b and semi-saturation L_0, M_0, S_0 over space and time.
//
// Stockman et al. describe first-site regulation across light levels and the
// transition toward bleaching-supported high-light sensitivity regulation.
// Source: JOV 2006, doi:10.1167/6.11.5.
//
// Webster and Leonard distinguish a response norm, the adapting level that
// leaves white judgments unbiased, from a perceptual norm, the stimulus that
// appears white. Their experiments found close tracking between these norms.
// PsychoV uses adapted-background reference for the directly carried cone
// state and retains response/perceptual norms as higher-level interpretations
// of the current neutral coding state.
// Source: JOSA A 2008, doi:10.1364/JOSAA.25.002817.
//
// CVRL documents observing-condition and chromatic-adaptation dependence in
// physiological luminosity functions, while cone spectral sensitivities stay
// stable through ordinary adaptation levels. This supports carrying Yf with
// the current adapted observer state.
// Source: http://www.cvrl.org/database/text/intros/introvl.htm
//
// 2a) Dim cone-noise extension
// ----------------------------
// Cone-mediated detection reaches a quantal/transduction-noise regime before
// rod-dominated vision. Approximate De Vries-Rose behavior gives threshold
// cone contrast a log-log slope near -0.5 against retinal illuminance. Higher
// adaptation levels approach Weber-like behavior, where threshold contrast is
// approximately constant relative to background. A calibrated successor can
// use retinal illuminance and cone-specific noise to attenuate scene
// differences below this visibility floor before postreceptoral processing.
//
// Stockman and Brainard discuss the range where cone-contrast coordinates
// approach Weber behavior. Angueyra and Rieke measure primate-cone
// phototransduction noise and its contribution to the dim-light threshold.
// Sources:
//   https://color2.psych.upenn.edu/brainard/papers/Stockman_Brainard_ColorVision.pdf
//   Angueyra & Rieke, Nature Neuroscience 2013, doi:10.1038/nn.3534
//   https://pmc.ncbi.nlm.nih.gov/articles/PMC3815624/
//
// 2b) High-light bleaching extension
// -----------------------------------
// A retinal-illuminance-calibrated successor can represent steady-state cone
// pigment availability with the Rushton-Henry form
//
//   p_available(I) = 1 / (1 + I / I0)
//
// and the complementary bleached fraction
//
//   p_bleached(I) = I / (I + I0),  I0 approximately 10^4.3 Td.
//
// Physiological placement follows adaptation-state definition and precedes
// postreceptoral opponent response and pooled gain. A rendering realization
// can apply availability to cone excursions around the adapted-white anchor,
// approaching equal white at the carried achromatic level as availability
// approaches zero. Test30's selected highlight endpoint is the finite-G
// equation documented above; the bleaching equations remain a calibrated
// successor path tied to retinal units.
//
// Sources:
//   Stockman et al., JOV 2006, doi:10.1167/6.11.5
//   Stockman et al., JOV 2018, doi:10.1167/18.6.12
//   Rushton & Henry, Vision Research 1968,
//     doi:10.1016/0042-6989(68)90040-0
//   http://www.cvrl.org/database/text/intros/introbleaches.htm
//
// 3) Background-normalized opponent organization
// ------------------------------------------------
// Test30 applies adaptation-relative purity directly in LMS, then constructs
// A2 as a scaled decomposition of the three adaptation/peak-normalized cone
// loads. Its explicit weighted metric is exactly equivalent to orthonormal A2
// and supplies the same sixfold cone-axis geometry for Mean-A2 direction
// authoring and target projection in both positive and signed coordinates.
//
// 4) Saturating response research
// -------------------------------
// Michaelis-Menten/Naka-Rushton response families provide receptor and
// early-cortical contrast models; supersaturating forms capture additional
// cortical response shapes. Peirce analyzes how saturating and supersaturating
// contrast response functions affect visual-cortex interpretation.
// Source: Peirce, JOV 2007, doi:10.1167/7.6.13.
//
// Test30 selects the anchor-preserving finite per-cone G above. Its reciprocal
// parameterization fixes the caller's input/output anchor, logarithmic slope,
// and selected peak endpoint. This creates a controlled rendering response for
// direct comparison with future fitted receptor or cortical response models.
//
// 5) ON/OFF response research
// ---------------------------
// Retinal ON and OFF channels separate increments and decrements around an
// adapted background. Schiller reviews their parallel visual-system roles.
// Yu, Turner, Baudin, and Rieke show that cone adaptation and downstream
// nonlinearities can combine unexpectedly for natural-image structure,
// motivating natural-image validation of any explicit polarity split.
//
// Rahimi-Nasrabadi et al. validate an ONOFF image algorithm on calibrated
// grayscale images and propose color extension through a scalar lightness
// dimension. PsychoV's scalar-Yf highlight/shadow grade follows the analogous
// engineering principle of applying polarity-shaped grades to one achromatic
// coordinate while retaining cone ratios.
//
// Sources:
//   Schiller, Trends Neurosci 1992,
//     doi:10.1016/0166-2236(92)90017-3
//   Yu et al., eLife 2022, doi:10.7554/eLife.70611
//   Rahimi-Nasrabadi et al., Cell Reports 2021,
//     doi:10.1016/j.celrep.2021.108692
//
// Test30's automatic finite-G curve uses a centered static log-range prior.
// A successor ON/OFF stage can fit separate increment/decrement responses and
// preserve the same adaptation anchor and device-hull coupling.
//
// 6) Pooled divisive gain research
// --------------------------------
// Divisive normalization models pooled neural response as a channel drive
// divided by a semi-saturated measure of neighboring/population activity.
// This supplies a research path for coupled achromatic/opponent energy,
// spatial context, and contrast-dependent gain after polarity processing.
//
// Sources:
//   Heeger, Visual Neuroscience 1992,
//     doi:10.1017/S0952523800009640
//   Carandini & Heeger, Nature Reviews Neuroscience 2012,
//     doi:10.1038/nrn3136
//   Bun & Horwitz, Color Research & Application 2023,
//     doi:10.1002/col.22903
//
// A successor implementation can add fitted pooling neighborhoods and
// semi-saturation constants after a selected opponent/ON-OFF stage. Test30
// supplies a static per-pixel response baseline for that comparison.
//
// 7) Unified device-hull tone and gamut mapping
// ---------------------------------------------
// Display mapping is constrained by the complete target RGB volume. In
// normalized target coordinates this is
//
//   0 <= R,G,B <= 1.
//
// Lower and upper channel planes, faces, edges, corners, and neutral-axis
// capacity participate in one device-hull problem. High-purity directions can
// reach a target face at a lower achromatic level than D65, so a joint solve
// trades radial opponent distance and achromatic coordinate according to the
// selected metric. ITU-R BT.2408 supplies the practical HDR Reference White
// framing that keeps reference/diffuse white distinct from display peak.
// Source: https://www.itu.int/pub/R-REP-BT.2408
//
// Test30 fixes the Mean-A2 authored direction and projects exactly in the
// scaled (D,C,T) representation of the orthonormal A2 metric over the resulting
// convex target-cube/Yf polygon.
// This extends Test25's numerical ray support into an analytic nearest-point
// solve for the selected direction. BT.709 and BT.2020 modes share the same
// D65 cone normalization and use their respective complete RGB cubes.
//
// A successor sectional solve can search multiple directions within the
// active cone-axis sextant, include a fitted postreceptoral metric, and compare
// face/edge/interior candidates. Mean-A2 remains the preferred authored
// trajectory candidate and Test30 remains the exact fixed-direction baseline.
//
// 7a) Hue-objective research inside the hull solve
// ------------------------------------------------
// Mizokami et al. and O'Neil et al. study a functional account of the Abney
// effect based on an equivalent Gaussian spectral peak. For short and medium
// wavelengths, the equivalent-peak parameter can provide a hue objective as
// purity changes. A future spectral precomputation can map weighted-LMS/MB
// chromaticity to mu_eq and evaluate mu_eq alongside A2/ACC direction during
// target-hull optimization while carrying Yf separately.
//
// Sources:
//   Mizokami et al., JOV 2006, doi:10.1167/6.9.12
//   O'Neil et al., JOSA A 2012, doi:10.1364/JOSAA.29.00A165
//
// 7b) Simultaneous-range auto-compression
// ---------------------------------------
// `compression == 0` uses a static centered simultaneous-range reference:
//
//   side_range = reference_range_log10 / 2
//   h = max(side_range / log10(peak_Yf / anchor_Yf), 1)
//
// Kunkel and Reinhard report approximately 3.7 log10 units under their adapted
// test conditions. Jiang and Fairchild directly measured bright/dark
// simultaneous range on an Apple Pro Display XDR: approximately 3.3 log10 for
// the average observer and 3.47 for one observer at 1600 cd/m^2 with a
// 3.4-degree stimulus. Their fitted maxima were approximately 3.24 at
// 452 cd/m^2 and 3.40 at 1600 cd/m^2. These condition-dependent measurements
// motivate future display-, surround-, field-size-, and glare-aware range
// selection. Test30 keeps 3.7 as its static baseline for direct continuity
// with Test22-Test25.
//
// Sources:
//   Kunkel & Reinhard, APGV 2010, doi:10.1145/1836248.1836251
//   Jiang & Fairchild, JIST 2021,
//     doi:10.2352/J.ImagingSci.Technol.2021.65.5.050401
//
static const float PSYCHO30_EPSILON = 1e-6f;
static const float PSYCHO30_EPSILON2 = PSYCHO30_EPSILON * PSYCHO30_EPSILON;
static const float PSYCHO30_AUTO_COMPRESSION_SENTINEL = 0.f;
// Kunkel/Reinhard report approximately 3.7 log10 units under their adapted
// simultaneous-range test conditions. Test30 treats half that total range as
// the range above adaptation and half as the range below adaptation.
// Jiang/Fairchild report stimulus- and display-dependent simultaneous values.
static const float PSYCHO30_REFERENCE_SIMULTANEOUS_RANGE_LOG10 = 3.7f;
static const float PSYCHO30_HIGHLIGHT_GRADE_REFERENCE_WHITE = 1.f;
static const float PSYCHO30_SHADOW_GRADE_RANGE_STOPS = 4.f;

static const float3x3 PSYCHO30_BT709_TO_LMS_MAT = mul(
    renodx::color::STOCKMAN_CVRL_XYZ_TO_LMS_2DEG_FIT,
    renodx::color::BT709_TO_XYZ_MAT);
static const float3x3 PSYCHO30_LMS_TO_BT709_MAT = mul(
    renodx::color::XYZ_TO_BT709_MAT,
    renodx::color::STOCKMAN_CVRL_LMS_TO_XYZ_2DEG_FIT);
static const float3x3 PSYCHO30_LMS_TO_BT2020_MAT = mul(
    renodx::color::XYZ_TO_BT2020_MAT,
    renodx::color::STOCKMAN_CVRL_LMS_TO_XYZ_2DEG_FIT);

// BT.709 and BT.2020 share D65. These alpha values partition normalized Yf
// between the L and M cone loads and sum to one.
static const float3 PSYCHO30_D65_WHITE_LMS = mul(
    PSYCHO30_BT709_TO_LMS_MAT,
    float3(1.f, 1.f, 1.f));
static const float PSYCHO30_D65_WHITE_YF = dot(
    renodx::color::STOCKMAN_SHARP_LMS_TO_XFYFZF_MAT[1],
    PSYCHO30_D65_WHITE_LMS);
static const float PSYCHO30_D65_ALPHA_L =
    renodx::color::STOCKMAN_SHARP_LMS_TO_XFYFZF_MAT[1][0]
    * PSYCHO30_D65_WHITE_LMS.x
    / PSYCHO30_D65_WHITE_YF;
static const float PSYCHO30_D65_ALPHA_M =
    renodx::color::STOCKMAN_SHARP_LMS_TO_XFYFZF_MAT[1][1]
    * PSYCHO30_D65_WHITE_LMS.y
    / PSYCHO30_D65_WHITE_YF;
static const float PSYCHO30_D65_ALPHA_DELTA =
    PSYCHO30_D65_ALPHA_L - PSYCHO30_D65_ALPHA_M;
// Direct target basis at fixed normalized physiological coordinate A in the
// radical-free scaled-A2 coordinates D=L-M and T=2S-L-M:
//
//   target_rgb = A + D * D_RGB + T * T_RGB
//
// These are the symbolic inverse scaled-cone transform followed by the
// selected LMS-to-RGB matrix; they avoid reconstructing LMS per pixel.
static const float3 PSYCHO30_D_LMS = float3(
    PSYCHO30_D65_ALPHA_M * PSYCHO30_D65_WHITE_LMS.x,
    -PSYCHO30_D65_ALPHA_L* PSYCHO30_D65_WHITE_LMS.y,
    -0.5f * PSYCHO30_D65_ALPHA_DELTA * PSYCHO30_D65_WHITE_LMS.z);
static const float3 PSYCHO30_T_LMS = float3(
    0.f,
    0.f,
    0.5f * PSYCHO30_D65_WHITE_LMS.z);
static const float3 PSYCHO30_BT709_D_RGB = mul(
    PSYCHO30_LMS_TO_BT709_MAT,
    PSYCHO30_D_LMS);
static const float3 PSYCHO30_BT709_T_RGB = mul(
    PSYCHO30_LMS_TO_BT709_MAT,
    PSYCHO30_T_LMS);
static const float3 PSYCHO30_BT2020_D_RGB = mul(
    PSYCHO30_LMS_TO_BT2020_MAT,
    PSYCHO30_D_LMS);
static const float3 PSYCHO30_BT2020_T_RGB = mul(
    PSYCHO30_LMS_TO_BT2020_MAT,
    PSYCHO30_T_LMS);

// Automatic h centers the chosen simultaneous log10 range around adaptation:
//
//   h = max((reference_range / 2) / log10(peak_yf / anchor_yf), 1)
//
// Manual positive h is passed through unchanged by the public entry point.
float psycho30_AutoCompressionPower(float anchor_yf, float peak_yf) {
  float above_adaptation_range = log10(peak_yf / anchor_yf);
  return max(
      (PSYCHO30_REFERENCE_SIMULTANEOUS_RANGE_LOG10 * 0.5f)
          / above_adaptation_range,
      1.f);
}

float psycho30_GradeQuinticUnitRamp(float t) {
  t = saturate(t);
  return t * t * t * (t * (t * 6.f - 15.f) + 10.f);
}

float psycho30_HighlightsScalar(
    float x,
    float highlights,
    float adapted_anchor_yf) {
  [branch]
  if (highlights == 1.f) {
    return x;
  } else {
    float ratio = x / adapted_anchor_yf;
    float t;
    [branch]
    if (x > adapted_anchor_yf) {
      t = saturate(
          log2(ratio)
          / log2(
              PSYCHO30_HIGHLIGHT_GRADE_REFERENCE_WHITE
              / adapted_anchor_yf));
    } else {
      t = 0.f;
    }
    t = psycho30_GradeQuinticUnitRamp(t);

    [branch]
    if (highlights > 1.f) {
      float shaped = pow(ratio, highlights - 1.f);
      return x * lerp(1.f, shaped, t);
    } else {
      float shaped = pow(ratio, 1.f - highlights);
      return x / lerp(1.f, shaped, t);
    }
  }
}

float psycho30_ShadowsScalar(
    float x,
    float shadows,
    float adapted_anchor_yf) {
  [branch]
  if (shadows == 1.f) {
    return x;
  } else {
    float ratio = x / adapted_anchor_yf;
    float anchor_squared = adapted_anchor_yf * adapted_anchor_yf;
    float anchor_cubed = anchor_squared * adapted_anchor_yf;
    float shadow_floor = adapted_anchor_yf
                         * exp2(-PSYCHO30_SHADOW_GRADE_RANGE_STOPS);
    float t;
    [branch]
    if (x > shadow_floor) {
      t = saturate(
          log2(ratio)
          / log2(shadow_floor / adapted_anchor_yf));
    } else {
      t = 1.f;
    }
    t = psycho30_GradeQuinticUnitRamp(t);

    [branch]
    if (shadows > 1.f) {
      float shaped = pow(ratio, 2.f - shadows);
      float target = x * (1.f - anchor_squared)
                     + anchor_cubed * shaped;
      return lerp(x, target, t);
    } else {
      float shaped = pow(ratio, shadows);
      float target = x * (1.f + anchor_squared)
                     - anchor_cubed * shaped;
      return lerp(x, target, t);
    }
  }
}

// Direct adaptation-relative LMS interpolation toward neutral at fixed
// physiological Yf. The selected purity path does not
// require MacLeod-Boynton coordinates or an S-cone weight.
float3 psycho30_ApplyAdaptiveRelativePurity(
    float3 source_q,
    float purity_delta) {
  if (purity_delta == 1.f) return source_q;

  float relative_yf = renodx::color::yf::from::LMS(source_q);

  float neutral_scale = relative_yf
                        / renodx::color::yf::from::LMS(
                            1.f);
  return lerp(
      neutral_scale,
      source_q,
      purity_delta);
}

float3 psycho30_TargetRGBFromLMS(
    float3 lms,
    int target_gamut_mode) {
  float3 target_rgb;
  [branch]
  if (target_gamut_mode == 0) {
    target_rgb = mul(PSYCHO30_LMS_TO_BT709_MAT, lms);
  } else {
    target_rgb = mul(PSYCHO30_LMS_TO_BT2020_MAT, lms);
  }
  return target_rgb;
}

float psycho30_TargetNeutralYfLimit(
    float target_rgb_peak,
    float3 anchor_lms,
    int target_gamut_mode) {
  float anchor_yf = renodx::color::yf::from::LMS(anchor_lms);
  float3 anchor_target_rgb = psycho30_TargetRGBFromLMS(
      anchor_lms,
      target_gamut_mode);
  return target_rgb_peak * anchor_yf
         / renodx::math::Max(anchor_target_rgb);
}

float psycho30_ScaledA2Radius6(float2 dt) {
  return 3.f * dt.x * dt.x + dt.y * dt.y;
}

// Build the selected response coordinate directly from normalized response u:
// source q authors one scaled-A2 direction, finite-G u authors the other
// direction and supplies radius, C=L+M+S, and normalized physiological Yf.
// Equal normalized direction weights in the explicit A2 metric form the exact
// angular midpoint when both are defined.
// Signed coordinates use the odd continuation of the same finite response.
// A separate curve at zero would create visible bands in wide-gamut grades.
float3 psycho30_MeanA2ResponseFromQ(
    float3 source_q,
    float3 adaptation_peak_ratio,
    float response_power,
    float response_h,
    float hue_restore,
    out float normalized_response_yf) {
  bool uniform_response = response_h == 1.f;
  float3 anchor_power;
  [branch]
  if (uniform_response) {
    anchor_power = adaptation_peak_ratio;
  } else {
    anchor_power = pow(adaptation_peak_ratio, response_h);
  }
  float3 slope_normalization = 1.f - anchor_power;
  float3 input_exponent = response_power * response_h / slope_normalization;
  float3 response_drive = pow(abs(source_q), -input_exponent);
  float3 finite_encoded = anchor_power
                          / (anchor_power
                             + slope_normalization * response_drive);
  float3 response_u;
  [branch]
  if (uniform_response) {
    response_u = finite_encoded;
  } else {
    float inverse_response_h = 1.f / response_h;
    response_u = pow(finite_encoded, inverse_response_h);
  }
  response_u *= sign(source_q);
  float2 source_dt = float2(
      source_q.x - source_q.y,
      2.f * source_q.z - source_q.x - source_q.y);
  float response_lms_difference = response_u.x - response_u.y;
  float response_lms_sum = response_u.x + response_u.y;
  float2 response_dt = float2(
      response_lms_difference,
      2.f * response_u.z - response_lms_sum);
  float2 authored_dt = response_dt;
  float source_radius6 = psycho30_ScaledA2Radius6(source_dt);
  float response_radius6 = psycho30_ScaledA2Radius6(response_dt);

  if (source_radius6 > 6.f * PSYCHO30_EPSILON2
      && response_radius6 > 6.f * PSYCHO30_EPSILON2) {
    float inverse_response_radius = rsqrt(response_radius6);
    float response_radius = response_radius6 * inverse_response_radius;
    const float2 source_direction = source_dt * rsqrt(source_radius6);
    const float2 response_direction = response_dt * inverse_response_radius;
    float2 mean_direction = source_direction + response_direction;
    float mean_radius6 = psycho30_ScaledA2Radius6(mean_direction);
    if (mean_radius6 > PSYCHO30_EPSILON2) {
      float2 authored_direction = mean_direction * rsqrt(mean_radius6);
      if (hue_restore != 0.f) {
        // UI 0..100 blends toward the response direction with weight 0..1.
        // Keep the finite response radius and existing gamut solve.
        authored_direction = lerp(
            authored_direction,
            response_direction,
            clamp(hue_restore, 0.f, 10.f));
        authored_direction *= rsqrt(max(
            psycho30_ScaledA2Radius6(authored_direction),
            PSYCHO30_EPSILON2));
      }
      authored_dt = authored_direction * response_radius;
    }
  }

  normalized_response_yf = PSYCHO30_D65_ALPHA_L * response_u.x
                           + PSYCHO30_D65_ALPHA_M * response_u.y;
  return float3(
      authored_dt.x,
      response_lms_sum + response_u.z,
      authored_dt.y);
}

float2 psycho30_ClosestPointOnScaleSegment(
    float desired_c,
    float radial_metric,
    float2 segment_start,
    float2 segment_end) {
  float2 segment = segment_end - segment_start;
  float denominator = 2.f * segment.x * segment.x
                      + radial_metric * segment.y * segment.y;
  if (denominator <= PSYCHO30_EPSILON2) return segment_start;
  float numerator = 2.f * (desired_c - segment_start.x) * segment.x
                    + radial_metric
                          * (1.f - segment_start.y)
                          * segment.y;
  float t = saturate(numerator / denominator);
  return segment_start + segment * t;
}

// Exact nearest point for the fixed authored A2 direction. The RGB cube and
// A<=response_yf ceiling become a four-edge convex polygon in (C, radial
// scale). The explicit 2*dC^2 + (3*D^2+T^2)*ds^2 metric is six times ordinary
// Euclidean distance in the equivalent orthonormal (X,C0,Z) coordinates.
// For radial target RGB r, n=max(-r), and p=max(r), feasibility is exactly:
//
//   scale * n <= A <= 1 - scale * p
//   0 <= A <= response_yf
float3 psycho30_YfCeilingSolve(
    float3 desired_coord,
    float response_yf,
    int target_gamut_mode) {
  float max_a = response_yf;
  float radial_a_numerator =
      3.f * PSYCHO30_D65_ALPHA_DELTA * desired_coord.x - desired_coord.z;
  float desired_a = (2.f * desired_coord.y + radial_a_numerator) / 6.f;
  float3 radial_rgb;
  [branch]
  if (target_gamut_mode == 0) {
    radial_rgb = desired_coord.x * PSYCHO30_BT709_D_RGB
                 + desired_coord.z * PSYCHO30_BT709_T_RGB;
  } else {
    radial_rgb = desired_coord.x * PSYCHO30_BT2020_D_RGB
                 + desired_coord.z * PSYCHO30_BT2020_T_RGB;
  }
  float3 desired_target_rgb = desired_a + radial_rgb;
  if (desired_a >= 0.f
      && desired_a <= max_a
      && all(desired_target_rgb >= -PSYCHO30_EPSILON)
      && all(desired_target_rgb <= 1.f + PSYCHO30_EPSILON)) {
    return desired_coord;
  }

  float radial_metric = psycho30_ScaledA2Radius6(desired_coord.xz);
  if (radial_metric <= 6.f * PSYCHO30_EPSILON2) {
    return float3(
        0.f,
        clamp(desired_coord.y, 0.f, 3.f * max_a),
        0.f);
  }

  float positive_pressure = renodx::math::Max(radial_rgb);
  float negative_pressure = -renodx::math::Min(radial_rgb);

  // Build the same polygon from its triangle or quadrilateral pressure case.
  float total_pressure = positive_pressure + negative_pressure;
  bool is_triangle = max_a * total_pressure <= negative_pressure;
  float max_a_radial_scale;
  float upper_a;
  float upper_radial_scale;
  [branch]
  if (is_triangle) {
    max_a_radial_scale = max_a / negative_pressure;
    upper_a = max_a;
    upper_radial_scale = max_a_radial_scale;
  } else {
    max_a_radial_scale = (1.f - max_a) / positive_pressure;
    upper_radial_scale = 1.f / total_pressure;
    upper_a = negative_pressure * upper_radial_scale;
  }
  float2 vertex0 = 0.f;
  float2 vertex1 = float2(3.f * max_a, 0.f);
  float2 vertex2 = float2(
      3.f * max_a
          - 0.5f * radial_a_numerator * max_a_radial_scale,
      max_a_radial_scale);
  float2 vertex3 = float2(
      3.f * upper_a
          - 0.5f * radial_a_numerator * upper_radial_scale,
      upper_radial_scale);
  // The first edge has constant zero radial scale, so no projection divide.
  float2 best_c_scale = float2(
      clamp(desired_coord.y, vertex0.x, vertex1.x),
      0.f);
  float2 best_delta = best_c_scale - float2(desired_coord.y, 1.f);
  float best_cost = 2.f * best_delta.x * best_delta.x
                    + radial_metric * best_delta.y * best_delta.y;

  float2 edge_candidate = psycho30_ClosestPointOnScaleSegment(
      desired_coord.y,
      radial_metric,
      vertex1,
      vertex2);
  float2 edge_delta = edge_candidate - float2(desired_coord.y, 1.f);
  float edge_cost = 2.f * edge_delta.x * edge_delta.x
                    + radial_metric * edge_delta.y * edge_delta.y;
  if (edge_cost < best_cost) {
    best_c_scale = edge_candidate;
    best_cost = edge_cost;
  }

  if (!is_triangle) {
    edge_candidate = psycho30_ClosestPointOnScaleSegment(
        desired_coord.y,
        radial_metric,
        vertex2,
        vertex3);
    edge_delta = edge_candidate - float2(desired_coord.y, 1.f);
    edge_cost = 2.f * edge_delta.x * edge_delta.x
                + radial_metric * edge_delta.y * edge_delta.y;
    if (edge_cost < best_cost) {
      best_c_scale = edge_candidate;
      best_cost = edge_cost;
    }
  }

  edge_candidate = psycho30_ClosestPointOnScaleSegment(
      desired_coord.y,
      radial_metric,
      vertex0,
      vertex3);
  edge_delta = edge_candidate - float2(desired_coord.y, 1.f);
  edge_cost = 2.f * edge_delta.x * edge_delta.x
              + radial_metric * edge_delta.y * edge_delta.y;
  if (edge_cost < best_cost) {
    best_c_scale = edge_candidate;
  }

  float3 solved_coord = float3(
      desired_coord.x * best_c_scale.y,
      best_c_scale.x,
      desired_coord.z * best_c_scale.y);
  return solved_coord;
}

float3 psychotm_test30(
    // Direct linear-light BT.709 RGB.
    // The pixel signal and all configuration values are trusted.
    float3 bt709_linear_input,
    float peak_value = 1000.f / 203.f,              // display peak / reference white
    float exposure = 1.f,                           // linear-light multiplier
    float highlights = 1.f,                         // scalar-Yf highlight grade
    float shadows = 1.f,                            // scalar-Yf shadow grade
    float contrast = 1.f,                           // factor in common cone power p
    float purity_scale = 1.f,                       // adaptation-relative LMS purity
    float bleaching_intensity = 1.f,                // positional compatibility placeholder
    float clip_point = 100.f,                       // positional compatibility placeholder
    float hue_restore = 0.f,                        // response-side A2 hue shift, 0 to 10
    float encoded_response_power = 1.f,             // positional compatibility placeholder
    int white_curve_mode = 0,                       // positional compatibility placeholder
    float cone_response_exponent = 1.f,             // second factor in cone power p
    float3 current_adaptive_state_bt709 = 0.18f,    // input anchor
    float3 current_background_state_bt709 = 0.18f,  // output anchor
    float gamut_compression = 1.f,                  // target-projection strength
    int gamut_compression_mode = 1,                 // 0 = BT.709, nonzero = BT.2020
    float adaptive_normalization = 1.f,             // positional compatibility placeholder
    float compression = 1.f) {                      // positive manual h; 0 = auto
  // -------------------------------------------------------------------------
  // Source signal and signed-domain policy.
  // -------------------------------------------------------------------------
  float3 exposed_input = bt709_linear_input * exposure;
  // Finite all-nonpositive RGB contains no positive light and maps to black;
  // nonfinite input continues into the trusted-signal path and propagates.
  if (all(exposed_input <= 0.f)) {
    if (!any(isinf(exposed_input))) {
      return 0.f;
    }
  }

  // Signed BT.709 is a coordinate representation of the wide-gamut scene,
  // not a source RGB cube. Retain it until the selected target projection.
  float3 anchored_lms = mul(PSYCHO30_BT709_TO_LMS_MAT, exposed_input);

  float3 anchor_in_lms = mul(
      PSYCHO30_BT709_TO_LMS_MAT,
      current_adaptive_state_bt709);
  float3 anchor_out_lms;
  [branch]
  if (all(current_background_state_bt709
          == current_adaptive_state_bt709)) {
    anchor_out_lms = anchor_in_lms;
  } else {
    anchor_out_lms = mul(
        PSYCHO30_BT709_TO_LMS_MAT,
        current_background_state_bt709);
  }

  // -------------------------------------------------------------------------
  // Observer-basis controls: scalar physiological-Yf grading followed by
  // adaptation-relative LMS purity. These precede the finite cone response.
  // -------------------------------------------------------------------------
  float3 graded_lms;
  [branch]
  if (highlights != 1.f || shadows != 1.f) {
    graded_lms = abs(anchored_lms);
    float graded_yf = renodx::color::yf::from::LMS(graded_lms);
    float adapted_anchor_yf = renodx::color::yf::from::LMS(anchor_in_lms);
    float graded_yf_out = psycho30_HighlightsScalar(
        graded_yf,
        highlights,
        adapted_anchor_yf);
    graded_yf_out = psycho30_ShadowsScalar(
        graded_yf_out,
        shadows,
        adapted_anchor_yf);
    // Shadow darkening can cross zero. Stop at black before CopySign turns
    // a negative grade back into positive brightness and inverts the shadows.
    if (graded_yf_out <= 0.f) return 0.f;
    graded_lms *= graded_yf_out / graded_yf;
    graded_lms = renodx::math::CopySign(graded_lms, anchored_lms);
  } else {
    graded_lms = anchored_lms;
  }

  float response_power = contrast * cone_response_exponent;
  float purity_delta = purity_scale / contrast;
  float3 response_input_q = psycho30_ApplyAdaptiveRelativePurity(
      graded_lms / anchor_in_lms,
      purity_delta);

  // -------------------------------------------------------------------------
  // Continuous signed finite-G response and Mean-A2 direction authoring.
  // -------------------------------------------------------------------------
  float target_rgb_peak = peak_value;
  float response_h;
  [branch]
  if (compression == PSYCHO30_AUTO_COMPRESSION_SENTINEL) {
    response_h = psycho30_AutoCompressionPower(
        renodx::color::yf::from::LMS(anchor_out_lms),
        psycho30_TargetNeutralYfLimit(
            target_rgb_peak,
            anchor_in_lms,
            gamut_compression_mode));
  } else {
    response_h = compression;
  }

  float response_yf;
  float3 desired_coord = psycho30_MeanA2ResponseFromQ(
      response_input_q,
      anchor_out_lms / (PSYCHO30_D65_WHITE_LMS * target_rgb_peak),
      response_power,
      response_h,
      hue_restore,
      response_yf);

  // -------------------------------------------------------------------------
  // Device mapping: exact fixed-direction projection into the selected
  // normalized RGB cube with the post-response physiological-Yf ceiling.
  // -------------------------------------------------------------------------
  float target_compression_weight = gamut_compression;
  float3 selected_coord = desired_coord;
  if (target_compression_weight != 0.f) {
    float3 solved_coord = response_yf > 0.f
                              ? psycho30_YfCeilingSolve(
                                    desired_coord,
                                    response_yf,
                                    gamut_compression_mode)
                              : 0.f;
    selected_coord = target_compression_weight == 1.f
                         ? solved_coord
                         : lerp(
                               desired_coord,
                               solved_coord,
                               target_compression_weight);
  }

  // Direct inverse scaled-A2/Yf basis to linear BT.709.
  float output_a = (2.f * selected_coord.y
                    + 3.f * PSYCHO30_D65_ALPHA_DELTA * selected_coord.x
                    - selected_coord.z)
                   / 6.f;
  float3 output_bt709 = peak_value
                        * (output_a
                           + selected_coord.x * PSYCHO30_BT709_D_RGB
                           + selected_coord.z * PSYCHO30_BT709_T_RGB);
  return output_bt709;
}

}  // namespace psychov
}  // namespace tonemap
}  // namespace renodx

#endif  // RENODX_SHADERS_TONEMAP_PSYCHOV_TEST30_HLSL_
