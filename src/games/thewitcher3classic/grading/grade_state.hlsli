#ifndef THEWITCHER3CLASSIC_GRADE_STATE_HLSLI_
#define THEWITCHER3CLASSIC_GRADE_STATE_HLSLI_
#include "../shared.h"

// Remastered's reversible grading proxy: fit signed BT.709 into the LUT domain,
// retain both scales locally, and undo them only after native grade blending.
struct ClassicGradeState {
  float3 neutral_sdr;
  float gamut_scale;
  float range_scale;
};
ClassicGradeState ClassicPrepareGrade(float3 color) {
  ClassicGradeState state;
  state.gamut_scale = max(renodx::color::correct::ComputeGamutCompressionScale(color), 1e-6f);
  state.neutral_sdr = max(renodx::color::correct::GamutCompress(
      color, renodx::color::y::from::BT709(color), state.gamut_scale), 0.f);
  state.range_scale = renodx::tonemap::neutwo::ComputeMaxChannelScale(state.neutral_sdr);
  state.neutral_sdr *= state.range_scale;
  return state;
}
float3 ClassicRestoreGrade(float3 color, ClassicGradeState state) {
  return renodx::color::correct::GamutDecompress(color / max(state.range_scale, 1e-6f), state.gamut_scale);
}
#endif
