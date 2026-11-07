#include "../clouds/local_volume.hlsli"
#include "../clouds/shadow_inputs.hlsli"
// The optional material hook preserves the native lighting/fog colour while
// replacing sprite opacity with a depth-clipped, animated density integral.
#define WITCHER_CLOUD_MATERIAL_OUTPUT(value) LocalCloudVolume(value, \
    float4(TEXCOORD_6.xyz,HartapfelCloudData.Load(44)==asuint(1357.f)?TEXCOORD_3.w:0.f), \
    float4(TEXCOORD_7.xyz,TEXCOORD_1.w), \
    float4(cb1_036x,cb1_036y,cb1_036z, \
        _405.x*cb12_022x+cb12_022y>=.999999f ? 1.e9f : \
        rcp((_405.x*cb12_022x+cb12_022y)*cb12_021x+cb12_021y)), \
    float4(TEXCOORD_1.yz,TEXCOORD_1.x, \
        FrequentPixelConsts_032.w*TEXCOORD_4.w*cb4_015x*lerp(1.f,_387,cb4_013x) \
        *saturate((length(float3(_430,_431,_432))-cb4_011x)/max(cb4_012x-cb4_011x,1.e-5f))), \
    lerp(float3(_471,_472,_473)*night_cloud,TEXCOORD_2.rgb,TEXCOORD_2.w), \
    float3(TEXCOORD_5.w,TEXCOORD_6.w,TEXCOORD_7.w), \
    float4(cb4_003x,cb4_004x,cb4_007x,cb4_007y),GlobalShaderConsts_000.x,t0,s0)
#include "lighting/0x093DCC92.ps_6_6.hlsli"
