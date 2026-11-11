// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Called once by the existing weather-history publication, never a new pass.
// Header 320..351 follows the shadow's authored base height, before texture data.
void PublishCloudFamilies() {
  float4 recipe=lerp(family_from,family_to,saturate(family_transition.x));
  float4 low=float4(recipe.xy,lerp(family_appearance.xy,family_appearance.zw,saturate(family_transition.x)));
  float4 high=float4(recipe.zw,lerp(family_transition.y,family_transition.z,saturate(family_transition.x)),family_transition.w);
  high.w=smoothstep(0.f,.025f,high.w);
  float4 target_low=low,target_high=high;
  float elapsed=cloud_clock.x-asfloat(published.Load(5632));
  if(published.Load(6048)==0xF7CF0001u &&published.Load(5968)==CloudIdentity().x
      &&isfinite(elapsed) &&elapsed>=0.f &&elapsed<1.f) {
    float fade=SegmentOpacity(min(elapsed,.25f)/.8f);
    low=lerp(asfloat(published.Load4(6016)),low,fade);
    high=lerp(asfloat(published.Load4(6032)),high,fade);
    float previous_wet=asfloat(published.Load(6044));
    high.w=elapsed==0.f?max(previous_wet,target_high.w)
        :lerp(previous_wet,target_high.w,SegmentOpacity(min(elapsed,.25f)/.2f));
  }
  // Reach authored zero after the fade settles. An asymptotic positive weight
  // would otherwise keep empty 3D ray loops running throughout thin-only weather.
  low=select(abs(low-target_low)<1.e-6f,target_low,low);
  high=select(abs(high-target_high)<1.e-6f,target_high,high);
  // Wet weather can start raining before the cloud-family fade settles.
  // Suppress the opening on arrival; retain the filtered tail on departure.
  high.y=min(high.y,target_high.y);
  published.Store4(6016,asuint(low));
  published.Store4(6032,asuint(high));
  published.Store(6048,0xF7CF0001u);
  shared_data.Store4(320,asuint(low));
  shared_data.Store4(336,asuint(high));
}
