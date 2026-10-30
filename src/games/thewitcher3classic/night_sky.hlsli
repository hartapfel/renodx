// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_CLASSIC_NIGHT_SKY
#define WITCHER_CLASSIC_NIGHT_SKY
// c184.w is native zero. A validated native upload publishes the two gains;
// absent tags preserve the original shader, including DevKit-only loading.
float ClassicCloudBrightness(uint bits) {
  if ((bits & 0xff000000u) == 0xd7000000u) return float((bits >> 12) & 4095u) / 511.f;
  return (bits & 0xff000000u) == 0xd6000000u ? float((bits >> 12) & 4095u) / 2047.f : 1.f;
}
float ClassicStarBrightness(uint bits) {
  return ((bits & 0xff000000u) == 0xd6000000u || (bits & 0xff000000u) == 0xd7000000u)
      ? float(bits & 4095u) / 2047.f : 1.f;
}
// The native builder clears c37.zw. c37.z is unused by the dumped shaders;
// keep the background-haze gain separate from cloud colour and moon size.
float ClassicSkyHazeBrightness(uint bits) {
  return (bits & 0xff000000u) == 0xd8000000u ? float(bits & 0xffffffu) / 1048575.f : 1.f;
}
float ClassicWaterAmbient(uint bits) {
  return (bits & 0xff000000u) == 0xd9000000u ? float(bits & 0xffffffu) / 1048575.f : 1.f;
}
#endif
