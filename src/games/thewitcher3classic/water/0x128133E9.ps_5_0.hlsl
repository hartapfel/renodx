#define CLASSIC_UNDERWATER_COMPOSITE
#include "underwater_inputs.hlsli"
#include "volume_sampling.hlsli"
#include "../../../shaders/random.hlsl"
// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 30 16:45:32 2026
Texture2D<float4> t15 : register(t15);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t0 : register(t0);

SamplerState s15_s : register(s15);

SamplerState s5_s : register(s5);

SamplerState s3_s : register(s3);

SamplerState s2_s : register(s2);

SamplerState s0_s : register(s0);

cbuffer cb12 : register(b12)
{
  float4 cb12[214];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[15];
}




// 3Dmigoto declarations
#define cmp -


void NativeUnderwater(
  float4 v0 : SV_Position0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy / cb0[2].zw;
  r0.xy = t2.Sample(s2_s, r0.xy).xy;
  r0.z = r0.y + r0.x;
  r0.z = cmp(r0.z < 0.00100000005);
  r0.w = saturate(r0.y);
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w;
  r1.xy = float2(0.150000006,0.150000006) * v1.xy;
  r1.xy = cb12[0].xy * float2(0.00200000009,0.00200000009) + r1.xy;
  r1.z = 0.0250000004 * r0.w;
  r1.xy = r0.ww * float2(0.100000001,0.100000001) + r1.xy;
  r1.xy = t5.Sample(s5_s, r1.xy).xy;
  r1.xy = r1.xy * r0.xx;
  r2.xy = float2(30,30) * r1.xy;
  r1.xy = -r1.xy * float2(30,30) + v1.xy;
  r0.w = t15.Sample(s15_s, r1.xy).x;
  r0.w = r0.w * cb12[22].x + cb12[22].y;
  r0.w = r0.w * cb12[21].x + cb12[21].y;
  r0.w = max(9.99999975e-005, r0.w);
  r0.w = 1 / r0.w;
  r1.x = t3.SampleLevel(s3_s, r1.xy, 0).x;
  r1.x = r1.x * cb12[22].x + cb12[22].y;
  r1.x = r1.x * cb12[21].x + cb12[21].y;
  r1.x = max(9.99999975e-005, r1.x);
  r1.x = 1 / r1.x;
  r0.w = -r1.x + r0.w;
  r0.w = r0.x * r0.w + r1.x;
  r0.w = saturate(0.0500000007 * r0.w);
  r0.w = max(0.200000003, r0.w);
  r1.xy = r2.xy * r0.ww + -r1.zz;
  r1.xy = v1.xy + -r1.xy;
  r0.w = t15.Sample(s15_s, r1.xy).x;
  r2.xyz = t0.Sample(s0_s, r1.xy).xyz;
  r1.zw = float2(0.00150000001,0.00150000001) / cb0[2].zw;
  r3.xyzw = r1.zwzw * float4(0,1,1,-1) + r1.xyxy;
  r2.w = t15.Sample(s15_s, r3.xy).x;
  r4.xyz = t0.Sample(s0_s, r3.xy).xyz;
  r3.xy = r1.xy + r1.zw;
  r4.w = t15.Sample(s15_s, r3.xy).x;
  r5.xyz = t0.Sample(s0_s, r3.xy).xyz;
  r3.x = t15.Sample(s15_s, r3.zw).x;
  r3.yzw = t0.Sample(s0_s, r3.zw).xyz;
  r6.xyzw = r1.zwzw * float4(0,-1,-1,1) + r1.xyxy;
  r5.w = t15.Sample(s15_s, r6.xy).x;
  r7.xyz = t0.Sample(s0_s, r6.xy).xyz;
  r6.xy = r1.xy + -r1.zw;
  r7.w = t15.Sample(s15_s, r6.xy).x;
  r8.xyz = t0.Sample(s0_s, r6.xy).xyz;
  r6.x = t15.Sample(s15_s, r6.zw).x;
  r6.yzw = t0.Sample(s0_s, r6.zw).xyz;
  r1.zw = r1.zw * float2(-1,0) + r1.xy;
  r8.w = t15.Sample(s15_s, r1.zw).x;
  r9.xyz = t0.Sample(s0_s, r1.zw).xyz;
  if (r0.z != 0) {
    o0.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
    return;
  }
  r0.z = r0.w * cb12[22].x + cb12[22].y;
  r0.z = r0.z * cb12[21].x + cb12[21].y;
  r0.z = max(9.99999975e-005, r0.z);
  r0.z = 1 / r0.z;
  r1.x = t3.SampleLevel(s3_s, r1.xy, 0).x;
  r1.x = r1.x * cb12[22].x + cb12[22].y;
  r1.x = r1.x * cb12[21].x + cb12[21].y;
  r1.x = max(9.99999975e-005, r1.x);
  r1.x = 1 / r1.x;
  r0.z = -r1.x + r0.z;
  r0.z = r0.x * r0.z + r1.x;
  r1.x = log2(r0.z);
  r1.x = 0.800000012 * r1.x;
  r1.x = exp2(r1.x);
  r1.x = 0.200000003 * r1.x;
  r1.x = min(1, r1.x);
  r0.z = saturate(0.0199999996 * r0.z);
  r1.yz = (uint2)v0.xy;
  r1.yz = (uint2)r1.yz;
  r1.zw = cb12[211].zw * r1.zz;
  r1.yz = cb12[210].zw * r1.yy + r1.zw;
  r1.yz = cb12[212].zw * r0.ww + r1.yz;
  r1.yz = cb12[213].zw + r1.yz;
  r0.w = r1.y / r1.z;
  r0.w = 0.100000001 * abs(r0.w);
  r0.w = log2(r0.w);
  r0.w = 1.60000002 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = min(1, r0.w);
  r1.y = saturate(cb0[14].y);
  r0.y = 0.150000006 * r0.y;
  r0.y = r1.x * r1.y + r0.y;
  r0.yw = max(float2(0.5,0.100000001), r0.yw);
  r0.y = min(0.899999976, r0.y);
  r0.y = r0.y * r1.y;
  r1.x = r2.w * cb12[22].x + cb12[22].y;
  r1.x = r1.x * cb12[21].x + cb12[21].y;
  r1.x = max(9.99999975e-005, r1.x);
  r1.x = 1 / r1.x;
  r1.x = 0.00999999978 * r1.x;
  r1.x = min(1, r1.x);
  r10.xyz = cb0[13].yzw + -r4.xyz;
  r1.xzw = r1.xxx * r10.xyz + r4.xyz;
  r2.w = r4.w * cb12[22].x + cb12[22].y;
  r2.w = r2.w * cb12[21].x + cb12[21].y;
  r2.w = max(9.99999975e-005, r2.w);
  r2.w = 1 / r2.w;
  r2.w = 0.00999999978 * r2.w;
  r2.w = min(1, r2.w);
  r4.xyz = cb0[13].yzw + -r5.xyz;
  r4.xyz = r2.www * r4.xyz + r5.xyz;
  r1.xzw = r4.xyz + r1.xzw;
  r2.w = r3.x * cb12[22].x + cb12[22].y;
  r2.w = r2.w * cb12[21].x + cb12[21].y;
  r2.w = max(9.99999975e-005, r2.w);
  r2.w = 1 / r2.w;
  r2.w = 0.00999999978 * r2.w;
  r2.w = min(1, r2.w);
  r4.xyz = cb0[13].yzw + -r3.yzw;
  r3.xyz = r2.www * r4.xyz + r3.yzw;
  r1.xzw = r3.xyz + r1.xzw;
  r2.w = r5.w * cb12[22].x + cb12[22].y;
  r2.w = r2.w * cb12[21].x + cb12[21].y;
  r2.w = max(9.99999975e-005, r2.w);
  r2.w = 1 / r2.w;
  r2.w = 0.00999999978 * r2.w;
  r2.w = min(1, r2.w);
  r3.xyz = cb0[13].yzw + -r7.xyz;
  r3.xyz = r2.www * r3.xyz + r7.xyz;
  r1.xzw = r3.xyz + r1.xzw;
  r2.w = r7.w * cb12[22].x + cb12[22].y;
  r2.w = r2.w * cb12[21].x + cb12[21].y;
  r2.w = max(9.99999975e-005, r2.w);
  r2.w = 1 / r2.w;
  r2.w = 0.00999999978 * r2.w;
  r2.w = min(1, r2.w);
  r3.xyz = cb0[13].yzw + -r8.xyz;
  r3.xyz = r2.www * r3.xyz + r8.xyz;
  r1.xzw = r3.xyz + r1.xzw;
  r2.w = r6.x * cb12[22].x + cb12[22].y;
  r2.w = r2.w * cb12[21].x + cb12[21].y;
  r2.w = max(9.99999975e-005, r2.w);
  r2.w = 1 / r2.w;
  r2.w = 0.00999999978 * r2.w;
  r2.w = min(1, r2.w);
  r3.xyz = cb0[13].yzw + -r6.yzw;
  r3.xyz = r2.www * r3.xyz + r6.yzw;
  r1.xzw = r3.xyz + r1.xzw;
  r2.w = r8.w * cb12[22].x + cb12[22].y;
  r2.w = r2.w * cb12[21].x + cb12[21].y;
  r2.w = max(9.99999975e-005, r2.w);
  r2.w = 1 / r2.w;
  r2.w = 0.00999999978 * r2.w;
  r2.w = min(1, r2.w);
  r4.xyz = cb0[13].yzw + -r9.xyz;
  r4.xyz = r2.www * r4.xyz + r9.xyz;
  r1.xzw = r4.xyz + r1.xzw;
  r1.xzw = r1.xzw + r3.xyz;
  r3.xyz = float3(0.125,0.125,0.125) * r1.xzw;
  r4.xyz = cb0[13].yzw + -r2.xyz;
  r4.xyz = r0.yyy * r4.xyz + r2.xyz;
  r1.xzw = -r1.xzw * float3(0.125,0.125,0.125) + cb0[13].yzw;
  r1.xzw = r0.yyy * r1.xzw + r3.xyz;
  r0.y = max(0.5, r0.z);
  r1.xzw = r1.xzw + -r4.xyz;
  r1.xzw = r0.yyy * r1.xzw + r4.xyz;
  r0.y = dot(cb0[13].yzw, cb0[13].yzw);
  r0.y = rsqrt(r0.y);
  r3.xyz = cb0[13].yzw * r0.yyy;
  r3.xyz = float3(0.699999988,0.699999988,0.699999988) * r3.xyz;
  r0.y = dot(r1.xzw, float3(0.577000022,0.577000022,0.577000022));
  r3.xyz = r3.xyz * r0.yyy;
  r3.xyz = r1.xzw * float3(0.300000012,0.300000012,0.300000012) + r3.xyz;
  r0.y = -0.00999999978 + r0.z;
  r0.y = saturate(4 * r0.y);
  r1.xzw = -r3.xyz + r1.xzw;
  r1.xzw = r0.yyy * r1.xzw + r3.xyz;
  r0.y = 1 + -r0.z;
  r0.y = 0.100000001 * r0.y;
  r3.xyz = float3(1.5,1.5,1.5) * r1.xzw;
  r3.xyz = r0.yyy * cb0[13].yzw + r3.xyz;
  r0.y = 1 + -r1.y;
  r0.y = r0.y * r0.w;
  r1.xyz = -r3.xyz + r1.xzw;
  r0.yzw = r0.yyy * r1.xyz + r3.xyz;
  r1.x = max(0, cb0[14].x);
  r1.x = min(10, r1.x);
  r0.x = saturate(r0.x);
  r0.yzw = r0.yzw * r1.xxx + -r2.xyz;
  o0.xyz = r0.xxx * r0.yzw + r2.xyz;
  o0.w = 0;
  return;
}

void main(float4 position:SV_Position0,float2 uv:TEXCOORD0,out float4 color:SV_Target0) {
  if(!UnderwaterReady()) {
    NativeUnderwater(position,uv,color);return;
  }
  float coverage=saturate(t2.SampleLevel(s2_s,uv/cb0[2].zw,0).x);
  float4 scene=t0.SampleLevel(s0_s,uv,0);
  if(coverage<=0.f) {color=scene;return;}
  int2 pixel=int2(position.xy);
  float depth=t15.Load(int3(pixel,0)).x;
  float4 world=cb12[210]*pixel.x+cb12[211]*pixel.y+cb12[212]*depth+cb12[213];
  float3 delta=world.xyz/max(world.w,1.e-7f)-cb12[0].xyz;
  float distance=length(delta);
  float3 view_ray=delta/max(distance,1.e-6f);
  float3 extinction=UnderwaterState[2].rgb;
  float max_path=9.21034f/max(.001f,min(extinction.r,min(extinction.g,extinction.b)));
  // The native depth includes the visible water surface. The regional mean
  // interface also bounds rays to sky where depth is empty. Integrate only the
  // water segment when the near plane straddles the surface; air contributes
  // neither water extinction nor scattering. Pixel coverage still comes from
  // the game's wave-aware meniscus, not a crossfade to native underwater fog.
  float camera_depth=UnderwaterState[1].w-cb12[0].z;
  float ray_start=0.f;
  if(camera_depth<0.f) {
    if(view_ray.z>=-1.e-5f) {color=scene;return;}
    ray_start=min(distance,camera_depth/view_ray.z);
  } else if(view_ray.z>1.e-5f)distance=min(distance,camera_depth/view_ray.z);
  distance=min(max(distance-ray_start,0.f),max_path);
  if(distance<=0.f) {color=scene;return;}
  camera_depth=max(0.f,camera_depth-view_ray.z*ray_start);
  float3 sun=UnderwaterState[1].xyz;
  float3 refracted=refract(-sun,float3(0,0,1),1.f/1.333f);
  float cosine=max(-refracted.z,.01f);
  float transmission=saturate(sun.z)*(1.f-WaterInterfaceFresnel(sun.z,1.f/1.333f))/cosine;
  float phase=WaterPhase(dot(refracted,-view_ray),UnderwaterState[2].w);
  float3 scattering=UnderwaterState[3].rgb;
  // Native water ambient is retained as an isotropic source approximation.
  // It is not atmospheric fog color and is never a replacement grading tint.
  float3 integrated=scattering*UnderwaterState[4].rgb*WaterSunCell(extinction,0.f,distance,
      camera_depth,max(0.f,camera_depth-view_ray.z*distance));
  uint quality=clamp((uint)round(UnderwaterState[7].z),1u,4u);
  uint samples=quality==1u?24u:quality==2u?32u:quality==3u?48u:72u;
  float start=0.f;
  // Resolve discontinuous visibility with independently stratified ray samples,
  // as in the per-pixel atmospheric fog. Fixed Gauss points shared by all pixels
  // replicate thin object silhouettes instead of integrating their shadow volume.
  // Allocate a bounded quality budget by two-leg optical contribution. The
  // partition is camera/interface anchored, independent of opaque receivers.
  float extent=view_ray.z>1.e-5f ? min(max_path,camera_depth/view_ray.z):max_path;
  float rate=dot(extinction,1.f.xxx/3.f)*(1.f-view_ray.z/cosine);
  float mass=1.f-exp(-abs(rate)*extent);
  float3 spectral_rate=extinction*(1.f-view_ray.z/cosine);
  float3 previous_transmittance=exp(-extinction*camera_depth/cosine);
  float jitter=renodx::random::Hash33(float3(pixel,0)).x;
  float3 source=scattering*max(UnderwaterLight[1].rgb,0.f)*transmission*phase;
  [loop] for(uint i=0;i<samples &&start<distance &&any(source>0.f);++i) {
    float boundary=WaterOpticalDistance(rate,extent,mass,float(i+1u)/float(samples));
    float end=min(distance,boundary);
    float phase_sample=frac(jitter+float(i)*.61803398875f);
    float along=end<boundary
        ? start+WaterOpticalDistance(rate,end-start,1.f-exp(-abs(rate)*(end-start)),phase_sample)
        : WaterOpticalDistance(rate,extent,mass,(float(i)+phase_sample)/float(samples));
    float3 sample_position=cb12[0].xyz+view_ray*(ray_start+along);
    float sun_path=max(0.f,camera_depth-view_ray.z*along)/cosine;
    float3 entry=sample_position-refracted*sun_path;
    // CSMs describe the AIR leg; test at the refracted surface entry. Reusing
    // their straight-air projection below water invents incorrect actor shadows.
    float visibility=UnderwaterVisibility(entry);
    // Reuse the preceding endpoint. This is the same analytic linear-optical-
    // depth integral, with half the exponential evaluations per cell. Near
    // cancellation use its trapezoidal limit (relative error < 1e-7).
    float3 next_transmittance=exp(-extinction*(end+max(0.f,camera_depth-view_ray.z*end)/cosine));
    float3 small=abs(spectral_rate*(end-start))<.001f;
    float3 integral=lerp((previous_transmittance-next_transmittance)
        /(abs(spectral_rate)<1.e-8f?1.f:spectral_rate),
        .5f*(previous_transmittance+next_transmittance)*(end-start),small);
    integrated+=source*visibility*integral;
    previous_transmittance=next_transmittance;
    start=end;
  }
  // Preserve the native material's linear underwater brightness/exposure gain;
  // removing its blur/tint must not discard the region/weather-authored level.
  color=float4(lerp(scene.rgb,
      (scene.rgb*WaterTransmittance(extinction,distance)+integrated)*clamp(cb0[14].x,0.f,10.f),coverage),0.f);
}
