#include "../shadow_inputs.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 31 15:08:29 2026
Texture2D<float4> t42 : register(t42);

Texture2DArray<float4> t19 : register(t19);

Texture2DArray<float4> t15 : register(t15);

Texture2DArray<float4> t14 : register(t14);

Texture2D<float4> t0 : register(t0);

SamplerState s14_s : register(s14);

SamplerState s10_s : register(s10);

cbuffer cb12 : register(b12)
{
  float4 cb12[214];
}

cbuffer cb13 : register(b13)
{
  float4 cb13[3323];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[44];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[69];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = (uint2)v0.xy;
  r0.xy = (uint2)r0.xy;
  r1.xy = (int2)r0.xy;
  r1.zw = float2(0,0);
  r0.z = t0.Load(r1.xyz).x;
  r0.w = r0.z * cb12[22].x + cb12[22].y;
  r0.w = cmp(r0.w < 1);
  if (r0.w != 0) {
    r1.xyzw = cb12[211].xyzw * r0.yyyy;
    r1.xyzw = cb12[210].xyzw * r0.xxxx + r1.xyzw;
    r0.xyzw = cb12[212].xyzw * r0.zzzz + r1.xyzw;
    r0.xyzw = cb12[213].xyzw + r0.xyzw;
    r0.xyz = r0.xyz / r0.www;
    r0.w = cmp(0 < asint(cb13[35].x));
    if (r0.w != 0) {
      r0.w = cmp(0 < asint(cb13[35].y));
      if (r0.w != 0) {
        r1.xy = float2(0,0);
        r0.w = 0;
        r2.z = 0;
        while (true) {
          r1.z = (int)r2.z;
          r1.w = cmp((int)r1.z >= asint(cb13[35].y));
          if (r1.w != 0) {
            r0.w = 0;
            break;
          }
          r1.w = 39 + r2.z;
          r1.w = (uint)r1.w;
          r3.xy = -cb13[r1.w+0].xy + r0.xy;
          r3.xy = cb13[r1.w+0].zw * r3.xy;
          r3.zw = cmp(r3.xy >= float2(0,0));
          r1.w = r3.w ? r3.z : 0;
          r3.zw = cmp(float2(1,1) >= r3.xy);
          r1.w = r3.z ? r1.w : 0;
          r1.w = r3.w ? r1.w : 0;
          if (r1.w != 0) {
            r3.z = 44 + r2.z;
            r3.z = (uint)r3.z;
            r4.xy = cb13[r3.z+0].zw + -cb13[r3.z+0].xy;
            r3.xy = r3.xy * r4.xy + cb13[r3.z+0].xy;
            r2.xyw = float3(0.00048828125,-0.00048828125,0.00244140625) + r3.xyx;
            r3.z = t15.SampleLevel(s10_s, r2.xyz, 0).x;
            r1.x = cb13[38].x * r3.z + cb13[38].y;
            r2.w = t15.SampleLevel(s10_s, r2.wyz, 0).x;
            r2.w = cb13[38].x * r2.w + cb13[38].y;
            r4.xyzw = float4(0.00048828125,0.00146484375,-0.00146484375,-0.00048828125) + r3.xyxy;
            r2.xy = r4.xy;
            r3.z = t15.SampleLevel(s10_s, r2.xyz, 0).x;
            r3.z = cb13[38].x * r3.z + cb13[38].y;
            r2.xy = r4.zw;
            r3.w = t15.SampleLevel(s10_s, r2.xyz, 0).x;
            r3.w = cb13[38].x * r3.w + cb13[38].y;
            r2.xy = float2(0.00048828125,-0.00244140625) + r3.xy;
            r2.x = t15.SampleLevel(s10_s, r2.xyz, 0).x;
            r2.x = cb13[38].x * r2.x + cb13[38].y;
            r2.xy = r2.xw + -r1.xx;
            r2.w = r3.w + -r1.x;
            r2.y = max(abs(r2.w), abs(r2.y));
            r2.w = r3.z + -r1.x;
            r2.x = max(abs(r2.w), abs(r2.x));
            r1.y = max(r2.y, r2.x);
            r0.w = -1;
            break;
          }
          r0.w = (int)r1.w & 0xbf800000;
          r1.z = (int)r1.z + 1;
          r2.z = (int)r1.z;
          r1.xy = float2(0,0);
        }
      } else {
        r0.w = 0;
      }
      r1.zw = -cb0[0].xy + r0.xy;
      r1.z = dot(r1.zw, r1.zw);
      r1.z = sqrt(r1.z);
      r1.w = cmp(r1.z < cb1[36].y);
      if (r1.w != 0) {
        r0.w = cmp(0 != r0.w);
        r1.xy = r0.ww ? r1.xy : float2(-10000,0);
        r2.xyz = -cb0[0].xyz + r0.xyz;
        r0.w = dot(r2.xyz, r2.xyz);
        r0.w = sqrt(r0.w);
        r1.y = max(0.100000001, r1.y);
        r1.y = 1 / r1.y;
        r1.w = cb1[37].z * r1.z;
        r1.w = max(1, r1.w);
        r1.w = cb1[36].x / r1.w;
        r1.y = min(r1.y, r1.w);
        r0.w = r0.w * 0.0199999996 + 0.0500000007;
        r1.z = cb1[36].z + r1.z;
        r1.z = saturate(cb1[36].w * r1.z);
        r1.w = r1.x + -r0.z;
        r0.w = cmp(abs(r1.w) < r0.w);
        r0.w = r0.w ? r1.x : r0.z;
        r2.y = 0;
        r1.xw = float2(0,0);
        r2.z = 0;
        while (true) {
          r2.w = cmp((int)r1.w >= asint(cb1[35].x));
          r2.z = 0;
          if (r2.w != 0) break;
          r3.xy = -cb1[r1.w+39].xy + r0.xy;
          r4.xy = cb1[r1.w+39].zw * r3.xy;
          r3.xz = cmp(r4.xy >= float2(0,0));
          r5.xy = cmp(float2(1,1) >= r4.xy);
          r3.xz = r3.xz ? r5.xy : 0;
          r2.w = r3.z ? r3.x : 0;
          if (r2.w != 0) {
            r4.w = (int)r1.w;
            r4.z = -r3.y * cb1[r1.w+39].w + 1;
            r3.x = t19.SampleLevel(s10_s, r4.xzw, 0).x;
            r3.x = cb1[38].x * r3.x + cb1[38].y;
            r3.x = r3.x + -r0.w;
            r3.x = -0.100000001 + r3.x;
            r3.x = saturate(r3.x * r1.y);
            r3.x = 1 + -r3.x;
            r3.y = 1 + -r3.x;
            r1.x = r1.z * r3.y + r3.x;
            r2.z = -1;
            break;
          }
          r2.x = (int)r1.w + 1;
          r1.xw = r2.yx;
          r2.z = r2.w;
        }
      } else {
        r2.z = 0;
      }
      r0.w = r2.z ? r1.x : 1;
      r1.x = 1;
    } else {
      r1.x = 0;
    }
    r1.x = cmp(0 != r1.x);
    r0.w = r1.x ? r0.w : 1;
    r1.x = cmp(0 < r0.w);
    if (r1.x != 0) {
      float3 classic_cloud_world_0 = r0.xyz;
      r1.x = 20 * cb0[66].x;
      r2.zw = trunc(cb0[68].xy);
      r1.yzw = -cb0[0].xyz + r0.xyz;
      r1.y = dot(r1.yzw, r1.yzw);
      r1.y = sqrt(r1.y);
      r3.xy = cb0[67].xy;
      r3.z = 0;
      r3.xyz = r3.xyz + r0.xyz;
      r3.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r3.xyz;
      r3.xyz = r3.xyz / cb0[66].xxx;
      r4.xy = float2(20,20) * cb0[67].xy;
      r4.z = 0;
      r0.xyz = r4.xyz + r0.xyz;
      r0.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r0.xyz;
      r0.xyz = r0.xyz / r1.xxx;
      r1.xz = cb1[0].xy * r3.zz;
      r1.xz = r1.xz / cb1[0].zz;
      r2.xy = r3.xy + -r1.xz;
      r1.xz = cb1[0].xy * r0.zz;
      r1.xz = r1.xz / cb1[0].zz;
      r3.xy = -r1.xz + r0.xy;
      r0.x = t14.SampleLevel(s14_s, r2.xyz, 1).x;
      r0.y = t14.SampleLevel(s14_s, r2.xyw, 1).x;
      r0.y = r0.y + -r0.x;
      r0.x = cb0[66].w * r0.y + r0.x;
      r3.zw = r2.zw;
      r0.y = t14.SampleLevel(s14_s, r3.xyz, 1).x;
      r0.z = t14.SampleLevel(s14_s, r3.xyw, 1).x;
      r0.z = r0.z + -r0.y;
      r0.y = cb0[66].w * r0.z + r0.y;
      r0.z = -0.25 + cb1[0].z;
      r0.z = saturate(10 * r0.z);
      r1.x = -100 + r1.y;
      r1.x = saturate(0.00666666683 * r1.x);
      r0.y = r0.y + -r0.x;
      r0.x = r1.x * r0.y + r0.x;
      r0.x = -r0.z * r0.x + 1;
      r0.x = ClassicCloudShadow(classic_cloud_world_0, r0.x);
      r0.w = r0.w * r0.x;
    }
    r0.x = cmp(0 < r0.w);
    if (r0.x != 0) {
      r1.xy = (int2)v0.xy;
      r1.zw = float2(0,0);
      r0.x = t42.Load(r1.xyz).x;
      r0.w = r0.w * r0.x;
    }
  } else {
    r0.w = 1;
  }
  o0.xyzw = r0.wwww;
  return;
}
