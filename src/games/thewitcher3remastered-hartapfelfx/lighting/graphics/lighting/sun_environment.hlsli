// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_REMASTERED_SUN_ENVIRONMENT
#define WITCHER_REMASTERED_SUN_ENVIRONMENT
#include "brdf.hlsli"

// The native sun diffuse response also weights authored ambient/shadow presets.
// Re-evaluate its original direction when the direct BRDF refracts underwater.
// Preserve the three native models and the current Improved PBR response.
float3 GraphicsSunEnvironmentWeight(float3 normal, float3 view, float3 sun,
    float3 albedo, float roughness, float direct_roughness, int model,
    float2 wrap, float transmission, float backlight_power, bool improved, float visibility) {
  float no_l = dot(sun, normal);
  if (visibility <= 0.f || (wrap.y + transmission) + saturate(no_l) <= 0.f) return 0.f;
  if (improved && model != 2) {
    return GraphicsDiffuseResponse(normal, view, sun, direct_roughness, albedo, model,
        saturate(saturate(no_l) * wrap.x + wrap.y)) * (model == 1 ? 3.141592653589793f : 1.f);
  }
  if (model == 0) return saturate(saturate(no_l) * wrap.x + wrap.y).xxx;
  if (model == 2) return albedo * (saturate(dot(sun, view) + .5f) * exp2(log2(abs(no_l)) * backlight_power));
  int _768 = ((int)(uint)((int)(normal.z > 0.0f))) << 1u;
  float _770 = float((int)(_768 + -1));
  float _772 = -1.0f / (_770 + normal.z);
  float _774 = (normal.y * normal.x) * _772;
  float _778 = (((normal.x * normal.x) * _770) * _772) + 1.0f;
  float _779 = _774 * _770;
  float _782 = float((int)(1 - _768)) * normal.x;
  float _785 = ((normal.y * normal.y) * _772) + _770;
  float _786 = -0.0f - normal.y;
  float _788 = rsqrt(dot(float3(sun.x, sun.y, sun.z), float3(sun.x, sun.y, sun.z)));
  float _789 = _788 * sun.x;
  float _790 = _788 * sun.y;
  float _791 = _788 * sun.z;
  float _794 = mad(_782, _791, mad(_779, _790, (_789 * _778)));
  float _797 = mad(_786, _791, mad(_785, _790, (_789 * _774)));
  float _800 = mad(normal.z, _791, mad(normal.y, _790, (_789 * normal.x)));
  float _802 = rsqrt(dot(float3(_794, _797, _800), float3(_794, _797, _800)));
  float _805 = _802 * _800;
  float _807 = rsqrt(dot(float3(view.x, view.y, view.z), float3(view.x, view.y, view.z)));
  float _808 = _807 * view.x;
  float _809 = _807 * view.y;
  float _810 = _807 * view.z;
  float _813 = mad(_782, _810, mad(_779, _809, (_808 * _778)));
  float _816 = mad(_786, _810, mad(_785, _809, (_808 * _774)));
  float _819 = mad(normal.z, _810, mad(normal.y, _809, (_808 * normal.x)));
  float _821 = rsqrt(dot(float3(_813, _816, _819), float3(_813, _816, _819)));
  float _824 = _821 * _819;
  float _825 = roughness * roughness;
  float _828 = dot(float3((_802 * _794), (_802 * _797), _805), float3((_821 * _813), (_821 * _816), _824)) - (_824 * _805);
  float _834;
  if (_828 > 0.0f) {
    _834 = (_828 / max(_805, _824));
  } else {
    _834 = _828;
  }
  float _836 = (_825 * 0.2877933979034424f) + 1.0f;
  float _837 = 1.0f / _836;
  float _841 = ((_834 * _825) + 1.0f) * (_837 * 0.31830987334251404f);
  float _845 = 1.0f - _824;
  float _856 = 1.0f - _805;
  float _869 = _837 * ((_825 * 0.07248824834823608f) + 1.0f);
  float _876 = 1.0f - _869;
  float _891 = max(1.0000000116860974e-07f, (1.0f - ((((_856 * _825) * ((((((_856 * 0.07144299894571304f) + -0.332181453704834f) * _856) + 0.4918818771839142f) * _856) + 0.05710852891206741f)) + 1.0f) / _836))) * (max(1.0000000116860974e-07f, (1.0f - ((((_845 * _825) * ((((((_845 * 0.07144299894571304f) + -0.332181453704834f) * _845) + 0.4918818771839142f) * _845) + 0.05710852891206741f)) + 1.0f) / _836))) * 0.31830987334251404f);
  float _895 = max(1.0000000116860974e-07f, _876);
  float _903 = saturate(dot(float3(normal.x, normal.y, normal.z), float3(sun.x, sun.y, sun.z)));
  float _904 = _903 * (((_891 * (((albedo.x * albedo.x) * _869) / (1.0f - (_876 * albedo.x)))) / _895) + (_841 * albedo.x));
  float _905 = _903 * (((_891 * (((albedo.y * albedo.y) * _869) / (1.0f - (_876 * albedo.y)))) / _895) + (_841 * albedo.y));
  float _906 = _903 * (((_891 * (((albedo.z * albedo.z) * _869) / (1.0f - (_876 * albedo.z)))) / _895) + (_841 * albedo.z));
  return float3(_904, _905, _906) * (model == 1 ? 3.1415927410125732f : 1.f);
}

// Generic forward materials use a bent-normal wrap and keep native environment
// weights even when Improved PBR replaces their direct diffuse response.
float3 GraphicsForwardSunEnvironment(float3 normal, float3 wrap_normal, float3 view,
    float3 sun, float3 albedo, float roughness, int model, float wrap_strength, float visibility) {
  if (visibility <= 0.f) return 0.f;
  float wrap = saturate((dot(wrap_normal, sun) + wrap_strength) / (wrap_strength + 1.f));
  float wrapped_no_l = saturate((dot(normal, sun) + wrap) / (wrap + 1.f));
  if (model != 1) return wrapped_no_l.xxx;
  return GraphicsSunEnvironmentWeight(normal, view, sun, albedo, roughness, roughness,
      1, float2(1, 0), 0.f, 0.f, false, visibility)
      + max(0.f, wrapped_no_l - saturate(dot(normal, sun))) * albedo;
}
// Eye materials use one iris wrap rather than the generic bent-normal wrap.
// Their authored corneal reflection shares this native environment weight.
float3 GraphicsEyeSunEnvironment(float3 normal, float3 view, float3 sun,
    float3 albedo, float roughness, int model, float wrap_strength, float visibility) {
  if (visibility <= 0.f) return 0.f;
  if (model != 1) return saturate((dot(normal, sun) + wrap_strength) / (wrap_strength + 1.f)).xxx;
  return GraphicsSunEnvironmentWeight(normal, view, sun, albedo, roughness, roughness,
      1, float2(1, 0), 0.f, 0.f, false, visibility);
}
// Skin's native ambient preset uses its original wavelength-dependent normal
// blur and wrap, including the separate subsurface-scattering output mode.
float3 GraphicsSkinSunEnvironment(float3 normal, float3 geometric_normal, float3 view,
    float3 sun, float3 albedo, float roughness, int model, float wrap,
    float3 normal_blend, float3 channel_blur, float3 channel_wrap,
    float wrap_scale, float wrap_power, bool split_scattering, float visibility) {
  if (visibility <= 0.f) return 0.f;
  float normal_weight = saturate(exp2(log2(saturate((dot(geometric_normal, sun) + wrap) / (wrap + 1.f)))
      * normal_blend.y) * (normal_blend.z - normal_blend.x) + normal_blend.x);
  float3 shading_normal = normalize(normal_weight * (normal - geometric_normal) + geometric_normal);
  float no_l = dot(shading_normal, sun);
  float wrapped_no_l = (no_l + wrap) / (wrap + 1.f);
  float3 response;
  [unroll]
  for (uint channel = 0; channel < 3; ++channel) {
    float3 channel_normal = normalize((shading_normal - geometric_normal) * (1.f - channel_blur[channel]) + geometric_normal);
    response[channel] = saturate(split_scattering ? no_l
        : (saturate(wrapped_no_l * wrap_scale) * (1.f - channel_wrap[channel]) + channel_wrap[channel])
            * exp2(log2(saturate(max((dot(channel_normal, sun) + wrap) / (wrap + 1.f), wrapped_no_l))) * wrap_power));
  }
  if (model != 1) return response;
  return GraphicsSunEnvironmentWeight(shading_normal, view, sun, albedo, roughness, roughness,
      1, float2(1, 0), 0.f, 0.f, false, visibility)
      + max(0.f, response.x - saturate(no_l)) * albedo;
}
#endif
