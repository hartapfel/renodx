#ifndef SRC_GAMES_GOTSUSHIMA_HUE_HLSLI_
#define SRC_GAMES_GOTSUSHIMA_HUE_HLSLI_

// Hue-only reference: retain the actual native HDR scene curve, both matrices,
// gamma-2 LUT addressing, native shoulder and per-pixel LUT blend. Decode the
// reconstructed grade in the same linear domain as PsychoV's input. This is
// the native scene grade, not a replay of the later rational display curve.
float3 GhostRestoreNativeHDRHue(
    float3 mapped_bt709,
    float3 native_pre_lut,
    GhostSceneGrade grade,
    SamplerState lut_sampler) {
  const float strength = saturate(RENODX_PSYCHOV_HUE_SHIFT * 0.5f);
  if (GHOST_SDR_OUTPUT != 0.f || strength == 0.f) return mapped_bt709;

  float3 coordinates = sqrt(max(native_pre_lut, 0.f.xxx));
  const float maximum = max(renodx::math::Max(coordinates), 1e-6f);
  const float distance_to_white = 1.f - maximum;
  const float shoulder = saturate(distance_to_white * 0.9523810148239136f + 0.5f);
  const float scale = (1.f - (distance_to_white < 0.5249999761581421f
                                 ? shoulder * shoulder * 0.5249999761581421f
                                 : distance_to_white)) / maximum;
  coordinates *= scale;
  Texture3D<float4> lut = ResourceDescriptorHeap[grade.lut_indices.x];
  float3 reference = lut.SampleLevel(
      lut_sampler, coordinates * grade.lut_coordinates.x + grade.lut_coordinates.y, 0.f).rgb;
  if (grade.lut_blend > 0.f) {
    Texture3D<float4> second_lut = ResourceDescriptorHeap[grade.lut_indices.y];
    reference = lerp(reference, second_lut.SampleLevel(
        lut_sampler, coordinates * grade.lut_coordinates.z + grade.lut_coordinates.w, 0.f).rgb,
        grade.lut_blend);
  }
  reference = GhostDecodeLUTOutput(reference / max(scale, 1e-6f));

  const float luminance = renodx::color::y::from::BT709(mapped_bt709);
  const float reference_luminance = renodx::color::y::from::BT709(reference);
  if (luminance <= 1e-6f || reference_luminance <= 1e-6f) return mapped_bt709;

  // Normalize luminance before measuring hue so bright flames and ordinary
  // surfaces receive the same strength. Only the angle changes, not C/L.
  float3 lab = renodx::color::oklab::from::BT709(mapped_bt709 / luminance);
  const float3 reference_lab = renodx::color::oklab::from::BT709(reference / reference_luminance);
  const float chroma = length(lab.yz);
  const float reference_chroma = length(reference_lab.yz);
  if (chroma <= 1e-6f || reference_chroma <= 1e-6f) return mapped_bt709;
  const float2 direction = lab.yz / chroma;
  const float2 reference_direction = reference_lab.yz / reference_chroma;
  // A neutral reference has no reliable hue. Fade restoration smoothly near
  // neutral instead of amplifying LUT precision noise into colored speckles.
  const float confidence = smoothstep(0.001f, 0.01f, reference_chroma / max(reference_lab.x, 1e-6f));
  const float angle = atan2(
      direction.x * reference_direction.y - direction.y * reference_direction.x,
      dot(direction, reference_direction)) * strength * confidence;
  float sine, cosine;
  sincos(angle, sine, cosine);
  lab.yz = float2(direction.x * cosine - direction.y * sine,
                  direction.x * sine + direction.y * cosine) * chroma;

  const float peak = RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f);
  float3 corrected = renodx::color::bt709::from::OkLab(lab);
  corrected *= luminance / max(renodx::color::y::from::BT709(corrected), 1e-6f);
  float3 target = RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
                      ? corrected : renodx::color::bt2020::from::BT709(corrected);
  if (all(target >= 0.f) && all(target <= peak)) return corrected;

  // Fit chroma at fixed hue and physical luminance. Clipping channels would
  // introduce another hue shift; scaling RGB down would change the curve.
  float low = 0.f;
  float high = 1.f;
  float3 fitted = luminance.xxx;
  [unroll]
  for (uint i = 0u; i < 10u; ++i) {
    const float candidate = (low + high) * 0.5f;
    corrected = renodx::color::bt709::from::OkLab(float3(lab.x, lab.yz * candidate));
    corrected *= luminance / max(renodx::color::y::from::BT709(corrected), 1e-6f);
    target = RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
                 ? corrected : renodx::color::bt2020::from::BT709(corrected);
    if (all(target >= 0.f) && all(target <= peak)) {
      low = candidate;
      fitted = corrected;
    } else {
      high = candidate;
    }
  }
  return fitted;
}

#endif  // SRC_GAMES_GOTSUSHIMA_HUE_HLSLI_
