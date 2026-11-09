// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../clouds/motion.hlsli"
#include "../clouds/lighting.hlsli"
#include "../clouds/low_sun.hlsli"
cbuffer Probe : register(b0, space73) {
  float4 point_native;
  float4 native_motion;
  float4 pixel_depth_tau;
  float4 sky_probe_clock;
  float4 sky_probe_solar;
  float4 sky_probe_controls;
}
#define SKY_FRAME cloud_motion_frame
#define SKY_DATA HartapfelCloudData
#define SKY_MOON_MATERIAL native_motion
#define SKY_SOLAR_MATERIAL sky_probe_solar
#define SKY_SOLAR_GLOW_SIZE sky_probe_controls.x
#define SKY_GLOW_EXPOSURE asuint(sky_probe_controls.y)
#define SKY_CLOCK sky_probe_clock
#define SKY_NATIVE_RADIUS sky_probe_controls.zw
#include "../sky/celestial.hlsli"
RWStructuredBuffer<float4> output : register(u0, space73);
[numthreads(1, 1, 1)] void main() {
  output[0] = float4(HartapfelCloudShadow(point_native.xyz, point_native.w),
      CloudShadowMatches(cloud_motion_frame[0].xyz, asuint(cloud_motion_frame[286])) ? 1.f : 0.f, 0, 0);
  output[1] = CloudNativeMotion(native_motion, pixel_depth_tau.z, int2(pixel_depth_tau.xy));
  output[2] = float4(CloudDiffuseTransport(pixel_depth_tau.w), exp(-pixel_depth_tau.w), CloudOpticalExtinction);
  output[3] = float4(HartapfelCloudNeutralize(point_native.w),
      HartapfelCloudShadowMultiply(point_native.xyz, point_native.w),
      HartapfelCloudShadowMultiply(point_native.xyz, 0.f),
      HartapfelCloudEmitterVisibility(point_native.xyz,native_motion.xyz));
  float4 solar=CloudLowSunState(native_motion.xyz,native_motion.w);
  output[6]=asfloat(HartapfelCloudData.Load4(336));
  output[4]=solar;
  output[5]=float4(CloudLowSunOpening(point_native.xyz,solar,0.f),
      CloudLowSunOpening(point_native.xyz,solar,1.f),
      CloudLowSunOpening(-point_native.xyz,solar,.5f),0.f);
  if(point_native.w==-1234.f &&SkyReady()) {
    float3 ray=SkyDirection(point_native.xyz),sun,moon;float mask;
    float air=SkyFogTransmission(ray);
    SkyDiscs(ray,pixel_depth_tau.w,air,sun,moon,mask);
    output[7]=float4(sun,1);
    output[8]=float4(moon,mask);
    output[9]=float4(SkyStars(ray,pixel_depth_tau.w,air,mask),1);
    output[10]=float4(air,SkyMoonAlbedo(float3(0,0,1),pixel_depth_tau.w/.00452f),SkySize(false),SkySize(true));
    output[11]=float4(SkyGlow(ray,air),1);
    output[12]=float4(SkyAtmosphereLight(cloud_motion_frame[204].yzw,
        cloud_motion_frame[205].yzw,cloud_motion_frame[38].xyz),1);
    output[13]=float4(SkyRadius(false),SkyRadius(true),0,0);
    output[14]=float4(SkyMoonLight(),saturate((1.f-dot(SkyMoonLight(),SkyDirection(cloud_motion_frame[205].yzw)))*.5f));
    output[15]=float4(SkySolarColour(),SkySolarGlowSize());
  }
}
