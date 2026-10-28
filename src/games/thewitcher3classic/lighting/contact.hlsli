// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_CONTACT_SHADOWS
#define CLASSIC_CONTACT_SHADOWS
#include "parameters.hlsli"
float ContactSceneDepth(float raw) {
  return rcp(max(1.e-7f,(raw*cb12[22].x+cb12[22].y)*cb12[21].x+cb12[21].y));
}
// Match the engine's material contract: high-resolution leaves and alpha hair
// are not opaque receivers. Billboard trees ARE receivers, as are grass and
// characters, even when their shading normal faces away from the light.
bool ContactReceiver(uint material) {
  return material!=128u && material!=255u && (material&6u)==0u;
}
float ContactOpacity(uint material,uint stencil,float depth,float translucency) {
  if(material==128u || material==255u)return 0.f;
  if(material==1u)return .75f;
  if((stencil&64u)!=0u)return saturate((depth-160.f)/10.f);
  if((stencil&128u)!=0u || material==8u)return 1.f;
  return translucency>.25f ? 1.f-saturate(translucency) : 1.f;
}
#endif
