// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "volume_sample.hlsli"
float4 FogSourceFrame(uint row) { return asfloat(FogVolume.Load4(64 + row * 16)); }
#ifdef FOG_RECEIVER_FRAME
bool ReceiverFrameMatches() {
  if (FogVolume.Load(1008) != FOG_HISTORY_VALID || any(FogVolume.Load4(912) != asuint(receiver_frame[286]))) return false;
  if (any(receiver_frame[0].xyz != FogSourceFrame(0).xyz)) return false;
  if (any(receiver_frame[17] != FogSourceFrame(17)) || any(receiver_frame[18] != FogSourceFrame(18))
      || any(receiver_frame[23] != FogSourceFrame(23))) return false;
  return true;
}
#endif
// Return premultiplied fog radiance and effective opacity at the receiver.
float4 ReceiverFog(float4 position, float distance, out float4 desaturation) {
  float4 integrated = SampleFogVolume(position.xy, distance);
  float opacity = saturate(integrated.a);
  float4 profile = FogSourceFrame(42);
  float4 curve = asfloat(FogVolume.Load4(32));
  float start = FogFadeStart(FogSourceFrame(22).z);
  float path = min(max(distance - start, 0.f), max(profile.z, 0.f));
  float fade = saturate((path - curve.y) * curve.z);
  float raw = fade > 1.e-7f ? pow(saturate(opacity / fade), rcp(max(profile.w, .0001f))) : 0.f;
  float2 ndc = position.xy * FogSourceFrame(23).zw * float2(2, -2) + float2(-1, 1);
  float4 homogeneous = ndc.x * FogSourceFrame(17) + ndc.y * FogSourceFrame(18) + .5f * FogSourceFrame(19) + FogSourceFrame(20);
  float3 ray = normalize(homogeneous.xyz / homogeneous.w - FogSourceFrame(0).xyz);
  float cosine = dot(ray, FogSourceFrame(38).xyz);
  int mode = asint(FogVolume.Load(872));
  float angular = cosine * cosine * ((mode == 0 || (cosine > 0.f && mode != 2)) ? saturate(path * .002f - .3f) : 1.f);
  float3 base = lerp(FogSourceFrame(40).rgb, cosine > 0.f ? FogSourceFrame(39).rgb : FogSourceFrame(41).rgb, angular);
  desaturation = float4(lerp(FogSourceFrame(46).rgb, cosine > 0.f ? FogSourceFrame(45).rgb : FogSourceFrame(47).rgb, angular), pow(max(raw, 0.f), max(curve.x, 0.f)) * fade);
  float4 first = asfloat(FogVolume.Load4(928)), weights = asfloat(FogVolume.Load4(944));
  float2 blend = saturate(opacity * weights.xz + weights.yw);
  float4 weather = float4(lerp(base, first.rgb, blend.x), saturate(opacity * lerp(1.f, first.a, blend.y)));
  float secondary = asfloat(FogVolume.Load(992));
  if (secondary > 0.f) {
    float4 second = asfloat(FogVolume.Load4(960));
    weights = asfloat(FogVolume.Load4(976));
    blend = saturate(opacity * weights.xz + weights.yw);
    weather = lerp(weather, float4(lerp(base, second.rgb, blend.x), saturate(opacity * lerp(1.f, second.a, blend.y))), secondary);
  }
  // Art direction changes the weather veil, not the independently shadowed
  // scattering field. Keep its medium and incoming-light extinction intact.
  desaturation.a*=FogAmount();
  return float4(weather.rgb * (weather.a*FogAmount())
      + integrated.rgb * (IndependentVolumeLight() ? 1.f : opacity > 1.e-7f ? weather.a / opacity : 0.f), weather.a*FogAmount());
}
float4 ReceiverFogVarying(float4 position, float distance, float4 native_fog) {
  if (fx.enabled <= .5f && IndependentVolumeLight()) {
    float3 radiance=SampleFogVolume(position.xy,distance).rgb;
    float coverage=max(native_fog.a,any(radiance>0.f)?1.e-4f:0.f);
    return float4(coverage>0.f?(native_fog.rgb*native_fog.a+radiance)/coverage:0.f,coverage);
  }
  float4 desaturation;
  float4 fog = ReceiverFog(position, distance, desaturation);
  // Native forward materials represent fog as colour/coverage. Preserve
  // additive beam radiance at zero veil with negligible residual coverage.
  float coverage=max(fog.a,any(fog.rgb>0.f)?1.e-4f:0.f);
  return float4(coverage>1.e-7f?fog.rgb/coverage:0.f,coverage);
}
