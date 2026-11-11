// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Validation invokes the production helpers with synthetic HDR/weather inputs.
#define FOG_INTEGRATE_ONLY
#include "../fog/grid.hlsli"
#define FOG_RECEIVER_FRAME
#define receiver_frame fog_frame
#include "../fog/receivers.hlsli"
cbuffer NativeLight : register(b13) { float4 fog_light[3589]; }
Texture2DArray<float> fog_cascades : register(t8);
Texture2DArray<float4> fog_clouds : register(t14);
Texture2DArray<float> fog_terrain : register(t19);
SamplerState fog_wrap_sampler : register(s14);
#define FOG_RASTER_LIGHTS
#include "../fog/local_lights.hlsli"
#define fog_clamp_sampler FogLocalSampler
#include "../fog/sun.hlsli"
#include "../water/caustics.hlsli"
[numthreads(1, 1, 1)] void main() {
  float test_distance=sampling.w!=0u?asfloat(sampling.w):1000.f;
  const float water_distance = test_distance * .01f;
  volume.Store4(176, asuint(float4(WaterTransmittance(water_distance, .075f, float3(.25f, .5f, 1.f)), WaterFresnel(1.f, WaterIor))));
  volume.Store4(192, asuint(float4(WaterFresnel(.5f, rcp(WaterIor)), WaterFresnel(.8f, rcp(WaterIor)),
                                      WaterFresnel(0.f, WaterIor), WaterFresnel(1.f, rcp(WaterIor)))));
  const float3 sun = normalize(float3(1.f, 0.f, 1.f));
  volume.Store4(208, asuint(float4(CausticFocus(0.f, 0.f), CausticFocus(float2(.5f, 0.f), 0.f),
                                      WaterLightSlope(sun, 1.331f).x < WaterLightSlope(sun, 1.337f).x,
                                      WaterLightSlope(float3(0.f, 0.f, 1.f), 1.331f).x)));
  const float3 caustic = WaterCaustics(0.f, 1.2f, 6.f, float3(0.f, 0.f, 1.f), 0.f);
  volume.Store4(224, asuint(float4(caustic.g > .4f && all(caustic == caustic.g),
                                      length(ResolvedWaterSlope(0.f, .2f, 0.f)) > .02f,
                                      length(ResolvedWaterSlope(0.f, .2f, 1.f)), WaterExitFresnel(.5f, .065f))));
  volume.Store4(240, asuint(float4(WaterExitFresnel(WaterCriticalCosine - .064f, .065f),
                                      WaterExitFresnel(WaterCriticalCosine, .065f),
                                      WaterExitFresnel(WaterCriticalCosine + .064f, .065f),
                                      WaterExitFresnel(.8f, .065f))));
  const float3 down = float3(0.f, 0.f, -1.f);
  const float column = WaterColumnLength(3.f, down, down, refract(down, -down, rcp(WaterIor)).z);
  volume.Store4(256, asuint(float4(WaterTransmittance(0.f, WaterMediumDensity(1.f, .85f), 1.f).g,
                                  WaterTransmittance(column, WaterMediumDensity(0.f, .85f), 1.f).g,
                                  WaterTransmittance(column, WaterMediumDensity(1.f, .85f), 1.f).g,
                                  WaterTransmittance(column, WaterMediumDensity(2.f, .85f), 1.f).g)));
  volume.Store4(144, asuint(float4(ReceiverFrameMatches() ? 1.f : 0.f, 0, 0, 0)));
  volume.Store4(160,asuint(ReceiverFogVarying(float4(960,540,0,1),test_distance,0.f)));
  FogLocalLight light = (FogLocalLight)0;
  light.data[0].w = 100;
  light.data[2] = float4(0, 0, 1, 0);
  light.data[4] = float4(0, 0, 1, 0);
  light.data[5] = float4(0, 1, 0, 1);
  light.data[9].x = asfloat(7u);
  volume.Store4(112, asuint(float4(LocalVisibility(light, float3(0, 0, 10), 10, false), 1)));
  light.data[9].x = asfloat(5u);
  float mono = LocalVisibility(light, float3(0, 0, 10), 10, false).x;
  light.data[9].z = asfloat(256u);
  float green = LocalVisibility(light, float3(0, 0, 10), 10, false).x;
  light.data[9].z = 0;
  light.data[9].x = asfloat(15u);
  light.data[9].y = .5f;
  float animated = LocalVisibility(light, float3(0, 0, 10), 10, false).x;
  light.data[9] = 0;
  light.data[6] = float4(1, 0, 0, 0);
  float cube = LocalVisibility(light, float3(0, 0, 10), 10, false).x;
  volume.Store4(128, asuint(float4(mono, green, animated, cube)));

  volume.Store4(96, asuint(float4(FogTerrainVisibility(float3(.5f, .5f, 0), 1), FogTerrainVisibility(float3(.5f, .5f, 20), 1), FogCloudVisibility(0, 20, 2), FogCloudVisibility(0, 20, 0))));
  volume.Store4(0, asuint(SampleFogVolume(float2(960, 540), test_distance)));
  volume.Store4(16, asuint(SampleFogVolume(float2(960, 540), .05f)));
  float4 desaturation;
  volume.Store4(32, asuint(ReceiverFog(float4(960, 540, 0, 1), test_distance, desaturation)));
  volume.Store4(48, asuint(float4(
                        FogExteriorFraction(float2(10, 20), 12, 18),
                        FogExteriorFraction(float2(10, 20), 0, 5),
                        FogExteriorFraction(float2(20, 10), 0, 5),
                        FogExteriorFraction(float2(20, 10), 12, 18))));
  volume.Store4(64, asuint(float4(
                        GridFastSample(uint2(1, 2), 0), GridFastSample(uint2(1, 2), 7),
                        GridFastSample(uint2(127, 127), 0), GridFastSample(uint2(128, 128), 0))));
  volume.Store4(80, asuint(float4(
                        FogLightTransmittance(0, 0, .001f, 0, 1000),
                        FogLightTransmittance(-100, 1, .001f, .1f, 50),
                        FogExteriorFraction(float2(10, 20), 7, 10),
                        FogExteriorFraction(float2(10, 20), 20, 23))));
}
