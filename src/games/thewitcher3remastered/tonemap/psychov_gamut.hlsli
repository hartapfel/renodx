#ifndef THEWITCHER3REMASTERED_PSYCHOV_GAMUT_HLSLI_
#define THEWITCHER3REMASTERED_PSYCHOV_GAMUT_HLSLI_

// Keep the observer response inside its positive cone domain. Signed RGB is
// valid wide-gamut transport, but a negative LMS component never approaches
// positive peak white through the supplied mapper's abs/sign fallback. This
// produces a flat yellow/green highlight with a white seam where S crosses zero.
float3 WitcherCompressPsychoVConeInput(float3 rgb) {
  const float luminance = renodx::color::y::from::BT709(rgb);
  if (!(luminance > 0.f)) return rgb;
  const float3 relative_lms = mul(
      renodx::tonemap::witcher_psychov_custom31::PSYCHO30_BT709_TO_LMS_MAT, rgb)
      / renodx::tonemap::witcher_psychov_custom31::PSYCHO30_D65_WHITE_LMS;
  const float distance = 1.f - renodx::math::Min(relative_lms) / luminance;
  // A narrow, exposure-invariant knee starts before the cone boundary to avoid
  // a seam at zero. Ordinary colours bypass exactly; no BT.709 RGB clamp or
  // display-gamut restriction is introduced. The RGB blend preserves CIE Y.
  const float knee = 0.98f;
  if (distance <= knee) return rgb;
  const float excess = distance - knee;
  const float headroom = 1.f - knee;
  const float compressed = knee + excess * headroom / (excess + headroom);
  return lerp(luminance.xxx, rgb, compressed / distance);
}

// A constant Oklab hue ray, rescaled to keep display-linear luminance.
// This scalar rescaling preserves hue and C/L; signed BT.709 is transport,
// not a clipping boundary. The caller tests the selected display RGB volume.
float3 WitcherPsychoVGamutCandidate(float3 lab, float chroma_scale, float luminance) {
  float3 rgb = renodx::color::bt709::from::OkLab(
      float3(lab.x, lab.yz * chroma_scale));
  const float candidate_y = renodx::color::y::from::BT709(rgb);
  if (!(candidate_y > 0.f)) return -1.f.xxx;
  return rgb * (luminance / candidate_y);
}

float3 WitcherCompressPsychoVGamut(float3 rgb, float peak, int target, float strength) {
  if (strength <= 0.f) return rgb;
  const float3 normalized = rgb / max(peak, 1e-6f);
  const float luminance = renodx::color::y::from::BT709(normalized);
  if (!(luminance > 0.f)) {
    return lerp(rgb, 0.f.xxx, saturate(strength));
  }
  const float3 lab = renodx::color::oklab::from::BT709(normalized);
  if (!(lab.x > 0.f) || any(isnan(lab)) || any(isinf(lab))) {
    return lerp(rgb, saturate(luminance).xxx * peak, saturate(strength));
  }
  const float3x3 to_target = target == 3
      ? mul(renodx::color::XYZ_TO_DISPLAYP3_MAT, renodx::color::BT709_TO_XYZ_MAT)
      : (target == 1 ? renodx::color::BT709_TO_BT2020_MAT
                     : float3x3(1, 0, 0, 0, 1, 0, 0, 0, 1));
  // Compress chromaticity against the target's lower (zero-channel) boundary
  // only. Holding Y while also fitting the peak boundary bleaches bright
  // yellows/reds to white, even when the perceptual hue itself is preserved.
  // Start the chroma knee at 80% of that boundary; interior colours bypass it.
  float lower = 0.f;
  float upper = 1.25f;
  float3 probe = mul(to_target, WitcherPsychoVGamutCandidate(lab, upper, luminance));
  float3 compressed = normalized;
  if (any(probe < 0.f)) {
    [loop]
    for (int iteration = 0; iteration < 16; ++iteration) {
      const float middle = (lower + upper) * 0.5f;
      probe = mul(to_target, WitcherPsychoVGamutCandidate(lab, middle, luminance));
      if (all(probe >= 0.f)) lower = middle;
      else upper = middle;
    }
    // The inside endpoint plus a numerical margin keeps target RGB nonnegative.
    // A rational shoulder joins the identity at the knee with unit slope.
    const float boundary = lower * 0.99999f;
    const float knee = boundary * 0.8f;
    const float distance = 1.f - knee;
    const float headroom = boundary - knee;
    const float scale = knee + distance * headroom / (distance + headroom);
    compressed = boundary > 0.f
        ? WitcherPsychoVGamutCandidate(lab, scale, luminance) : luminance.xxx;
  }
  // Fit peak with one RGB scale, preserving the mapped hue and C/L. Allowing
  // highlight luminance to fall retains colour instead of adding white.
  // Raising the knee to Y leaves the mapper's in-range neutral curve intact.
  const float maximum = renodx::math::Max(mul(to_target, compressed));
  const float peak_knee = max(0.8f, saturate(luminance));
  if (maximum > peak_knee) {
    const float headroom = 1.f - peak_knee;
    const float distance = maximum - peak_knee;
    const float mapped_maximum = peak_knee + distance * headroom / (distance + headroom);
    compressed *= mapped_maximum / maximum;
  }
  return lerp(rgb, compressed * peak, saturate(strength));
}

#endif
