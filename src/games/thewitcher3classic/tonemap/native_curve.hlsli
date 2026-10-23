#ifndef THEWITCHER3CLASSIC_NATIVE_CURVE_HLSLI_
#define THEWITCHER3CLASSIC_NATIVE_CURVE_HLSLI_
#include "../shared.h"

// Native Hable shoulder extension, using the established Batman Arkham Knight
// implementation (tonemap/uncharted2extended.hlsli). The original toe remains;
// the shoulder continues at its inflection tangent instead of approaching SDR.
float ClassicDerivative(
    float x,
    float a, float b, float c,
    float d, float e, float f) {
  float num = -a * b * (c - 1.0) * x * x
              + 2.0 * a * d * (f - e) * x
              + b * d * (c * f - e);

  float den = x * (a * x + b) + d * f;
  den = den * den;

  return num / den;
}

float ClassicFindSecondDerivativeRoot(float a, float b, float c, float d, float e, float f) {
  // Coefficients of the numerator of f''(x):
  // num(x) = A3 x^3 + A2 x^2 + A1 x + A0

  float A3 = a * a * b * (c - 1.0f);
  float A2 = 3.0f * a * a * d * (e - f);
  float A1 = 3.0f * a * b * d * (e - c * f);
  float A0 = a * d * d * (f * f - e * f) + b * b * d * (e - c * f);

  // If A3 = 0, curve is degenerate → no inflection
  if (abs(A3) < 1e-12f)
    return 0.f;

  // Normalize to monic cubic: x^3 + ax^2 + bx + c = 0
  float invA3 = 1.0f / A3;
  float an = A2 * invA3;
  float bn = A1 * invA3;
  float cn = A0 * invA3;

  // Depressed cubic t^3 + p t + q = 0  with x = t - a/3
  float an_3 = an / 3.0f;
  float p = bn - an * an_3;
  float q = 2.0f * an * an * an / 27.0f - an * bn / 3.0f + cn;

  float half_q = 0.5f * q;
  float Delta = half_q * half_q + (p / 3.0f) * (p / 3.0f) * (p / 3.0f);

  // Real root output
  float t;

  if (Delta >= 0.f) {
    float sqrtD = sqrt(Delta);
    float u = (-half_q + sqrtD);
    float v = (-half_q - sqrtD);

    // Use signed cube root
    float u_c = renodx::math::SignPow(u, 1.0f / 3.0f);
    float v_c = renodx::math::SignPow(v, 1.0f / 3.0f);
    t = u_c + v_c;
  } else {
    // 3 real roots → trig branch
    float m = 2.0f * sqrt(-p / 3.0f);
    float angle = acos((-half_q) / sqrt(-(p * p * p) / 27.0f));
    t = m * cos(angle / 3.0f);
  }

  float x = t - an_3;

  // Only meaningful inflection is positive
  return max(x, 0.f);
}

float3 ClassicExtendNative(float3 color, float3 abc, float3 def, float native_scale) {
  const float pivot = ClassicFindSecondDerivativeRoot(abc.x, abc.y, abc.z, def.x, def.y, def.z);
  const float normalization = native_scale / max(1e-6f,
      renodx::tonemap::ApplyCurve(11.2f, abc.x, abc.y, abc.z, def.x, def.y, def.z));
  const float pivot_value = renodx::tonemap::ApplyCurve(pivot, abc.x, abc.y, abc.z, def.x, def.y, def.z);
  const float slope = ClassicDerivative(pivot, abc.x, abc.y, abc.z, def.x, def.y, def.z);
  const float3 native = renodx::tonemap::ApplyCurve(color, abc.x, abc.y, abc.z, def.x, def.y, def.z);
  return max(0.f, lerp(native, pivot_value + slope * (color - pivot), step(pivot, color)) * normalization);
}
#endif
