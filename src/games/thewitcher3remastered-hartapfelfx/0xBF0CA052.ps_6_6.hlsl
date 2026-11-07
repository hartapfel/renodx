#define FOG_RECEIVER_FRAME
cbuffer HartapfelReceiverFrame : register(b12) { float4 receiver_frame[341]; }
#include "fog/receivers.hlsli"
#include "clouds/shadow_inputs.hlsli"
struct ShaderCommonEnvProbeParams {
  float ShaderCommonEnvProbeParams_000;
  float3 ShaderCommonEnvProbeParams_004;
  float3 ShaderCommonEnvProbeParams_016;
  row_major float4x4 ShaderCommonEnvProbeParams_028;
  float4 ShaderCommonEnvProbeParams_092;
  row_major float4x4 ShaderCommonEnvProbeParams_108;
  int ShaderCommonEnvProbeParams_172;
};

struct ShaderCullingEnvProbeParams {
  row_major float4x3 ShaderCullingEnvProbeParams_000;
  float3 ShaderCullingEnvProbeParams_048;
  int ShaderCullingEnvProbeParams_060;
};

struct ShaderWorldTear {
  float4 ShaderWorldTear_000;
  float4 ShaderWorldTear_016;
  float ShaderWorldTear_032;
  float ShaderWorldTear_036;
  float ShaderWorldTear_040;
  float ShaderWorldTear_044;
};

struct ShaderWorldTearArray {
  int ShaderWorldTearArray_000;
  float ShaderWorldTearArray_004;
  float ShaderWorldTearArray_008;
  float ShaderWorldTearArray_012;
  ShaderWorldTear ShaderWorldTearArray_016[10];
};

struct ShaderWorldTearConstants {
  int4 ShaderWorldTearConstants_000[16];
};


Texture2D<float4> t15 : register(t15);

Texture2D<float4> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

cbuffer cb0 : register(b0) {
  float4 GlobalShaderConsts_000 : packoffset(c000.x);
  float4 GlobalShaderConsts_016 : packoffset(c001.x);
  float4 GlobalShaderConsts_032 : packoffset(c002.x);
  float4 GlobalShaderConsts_048 : packoffset(c003.x);
  float4 GlobalShaderConsts_064 : packoffset(c004.x);
  float4 GlobalShaderConsts_080 : packoffset(c005.x);
  float4 GlobalShaderConsts_096 : packoffset(c006.x);
  float4 GlobalShaderConsts_112 : packoffset(c007.x);
  float4 GlobalShaderConsts_128 : packoffset(c008.x);
  float4 GlobalShaderConsts_144 : packoffset(c009.x);
  float4 GlobalShaderConsts_160 : packoffset(c010.x);
  float4 GlobalShaderConsts_176 : packoffset(c011.x);
  float4 GlobalShaderConsts_192 : packoffset(c012.x);
  float4 GlobalShaderConsts_208 : packoffset(c013.x);
  float4 GlobalShaderConsts_224 : packoffset(c014.x);
  float4 GlobalShaderConsts_240 : packoffset(c015.x);
};

cbuffer cb1 : register(b1) {
  float cb1_036x : packoffset(c036.x);
  float cb1_036y : packoffset(c036.y);
  float cb1_036z : packoffset(c036.z);
  uint cb1_padding : packoffset(c53.w);
};

cbuffer cb2 : register(b2) {
  float4 FrequentPixelConsts_000 : packoffset(c000.x);
  float4 FrequentPixelConsts_016 : packoffset(c001.x);
  float4 FrequentPixelConsts_032 : packoffset(c002.x);
  float4 FrequentPixelConsts_048 : packoffset(c003.x);
  float4 FrequentPixelConsts_064 : packoffset(c004.x);
  float4 FrequentPixelConsts_080 : packoffset(c005.x);
  float4 FrequentPixelConsts_096 : packoffset(c006.x);
  row_major float4x4 FrequentPixelConsts_112 : packoffset(c007.x);
  row_major float4x4 FrequentPixelConsts_176 : packoffset(c011.x);
  float4 FrequentPixelConsts_240 : packoffset(c015.x);
  float4 FrequentPixelConsts_256 : packoffset(c016.x);
  float4 FrequentPixelConsts_272 : packoffset(c017.x);
  float4 FrequentPixelConsts_288 : packoffset(c018.x);
};

#define cb12_021x receiver_frame[21].x
#define cb12_021y receiver_frame[21].y
#define cb12_022x receiver_frame[22].x
#define cb12_022y receiver_frame[22].y
#define cb12_244x receiver_frame[244].x
#define cb12_244y receiver_frame[244].y
#define cb12_244z receiver_frame[244].z
#define cb12_248x receiver_frame[248].x
#define cb12_248y receiver_frame[248].y
#define cb12_248z receiver_frame[248].z
#define cb12_277x receiver_frame[277].x
#define cb12_277y receiver_frame[277].y
#define cb12_277z receiver_frame[277].z
#define cb12_278x receiver_frame[278].x
#define cb12_278y receiver_frame[278].y
#define cb12_278z receiver_frame[278].z
#define cb12_padding asuint(receiver_frame[340].w)

cbuffer cb4 : register(b4) {
  float cb4_000x : packoffset(c000.x);
  float cb4_001x : packoffset(c001.x);
  float cb4_002x : packoffset(c002.x);
  float cb4_002y : packoffset(c002.y);
  float cb4_003x : packoffset(c003.x);
  float cb4_003y : packoffset(c003.y);
  float cb4_004x : packoffset(c004.x);
  float cb4_004y : packoffset(c004.y);
  float cb4_004z : packoffset(c004.z);
  float cb4_005x : packoffset(c005.x);
  float cb4_006x : packoffset(c006.x);
  float cb4_007x : packoffset(c007.x);
  float cb4_008x : packoffset(c008.x);
  float cb4_009x : packoffset(c009.x);
  float cb4_010x : packoffset(c010.x);
  float cb4_011x : packoffset(c011.x);
  float cb4_012x : packoffset(c012.x);
  float cb4_013x : packoffset(c013.x);
  float cb4_014x : packoffset(c014.x);
  float cb4_015x : packoffset(c015.x);
  float cb4_016x : packoffset(c016.x);
  float cb4_016y : packoffset(c016.y);
  float cb4_017x : packoffset(c017.x);
  float cb4_017y : packoffset(c017.y);
  float cb4_018x : packoffset(c018.x);
  float cb4_019x : packoffset(c019.x);
  float cb4_020x : packoffset(c020.x);
};

SamplerState s15 : register(s15);

SamplerState s0 : register(s0);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float4 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2,
  linear float4 TEXCOORD_3 : TEXCOORD3,
  linear float4 TEXCOORD_4 : TEXCOORD4,
  linear float3 TEXCOORD_5 : TEXCOORD5,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  if (CloudVisibleMatches(receiver_frame[0].xyz, receiver_frame[17], receiver_frame[18], receiver_frame[23], asuint(receiver_frame[286]), GlobalShaderConsts_000.x)) discard;
  float4 SV_Target = 0;
  if(ReceiverFrameMatches()) TEXCOORD = ReceiverFogVarying(SV_Position,length(float3(TEXCOORD_1.w,TEXCOORD_3.w,TEXCOORD_4.w)-receiver_frame[0].xyz));
  float _42 = -0.0f - GlobalShaderConsts_144.z;
  float _43 = dot(float3(GlobalShaderConsts_144.x, GlobalShaderConsts_144.y, _42), float3(GlobalShaderConsts_144.x, GlobalShaderConsts_144.y, _42));
  float _44 = rsqrt(_43);
  float _45 = _44 * GlobalShaderConsts_144.x;
  float _46 = _44 * GlobalShaderConsts_144.y;
  float _47 = _44 * _42;
  float _51 = cb4_002x * TEXCOORD_1.x;
  float _52 = cb4_002y * TEXCOORD_1.y;
  float _58 = cb4_003x * GlobalShaderConsts_000.x;
  float _59 = cb4_003y * GlobalShaderConsts_000.x;
  float _60 = _58 + _51;
  float _61 = _59 + _52;
  float4 _64 = t0.Sample(s0, float2(_60, _61));
  float _68 = _64.x + -0.5f;
  float _69 = _64.y + -0.5f;
  float _70 = _64.z + -0.5f;
  float _71 = _68 * 2.0f;
  float _72 = _69 * 2.0f;
  float _73 = _70 * 2.0f;
  float _78 = _71 * cb4_004x;
  float _79 = _72 * cb4_004y;
  float _80 = _73 * cb4_004z;
  float _81 = dot(float3(_78, _79, _80), float3(_78, _79, _80));
  float _82 = rsqrt(_81);
  float _83 = _78 * _82;
  float _84 = _79 * _82;
  float _85 = _80 * _82;
  float _86 = _83 * TEXCOORD_5.x;
  float _87 = _83 * TEXCOORD_5.y;
  float _88 = _83 * TEXCOORD_5.z;
  float _89 = _84 * TEXCOORD_3.x;
  float _90 = _84 * TEXCOORD_3.y;
  float _91 = _84 * TEXCOORD_3.z;
  float _92 = _85 * TEXCOORD_4.x;
  float _93 = _85 * TEXCOORD_4.y;
  float _94 = _85 * TEXCOORD_4.z;
  float _95 = _86 + _89;
  float _96 = _87 + _90;
  float _97 = _88 + _91;
  float _98 = _95 + _92;
  float _99 = _96 + _93;
  float _100 = _97 + _94;
  float _101 = dot(float3(_45, _46, _47), float3(_98, _99, _100));
  float _102 = saturate(_101);
  float _107 = cb1_036x - TEXCOORD_1.w;
  float _108 = cb1_036y - TEXCOORD_3.w;
  float _109 = cb1_036z - TEXCOORD_4.w;
  float _110 = _107 * _107;
  float _111 = _108 * _108;
  float _112 = _110 + _111;
  float _113 = _109 * _109;
  float _114 = _112 + _113;
  float _115 = sqrt(_114);
  float _116 = _115 * 0.0006666666595265269f;
  float _117 = saturate(_116);
  float _122 = cb12_278x + -1.0f;
  float _123 = cb12_278y + -1.0f;
  float _124 = cb12_278z + -1.0f;
  float _125 = _122 * _117;
  float _126 = _123 * _117;
  float _127 = _124 * _117;
  float _128 = _125 + 1.0f;
  float _129 = _126 + 1.0f;
  float _130 = _127 + 1.0f;
  float _139 = cb12_244x - cb12_277x;
  float _140 = cb12_244y - cb12_277y;
  float _141 = cb12_244z - cb12_277z;
  float _142 = _139 * _102;
  float _143 = _140 * _102;
  float _144 = _141 * _102;
  float _145 = _142 + cb12_277x;
  float _146 = _143 + cb12_277y;
  float _147 = _144 + cb12_277z;
  float _148 = _145 * _128;
  float _149 = _146 * _129;
  float _150 = _147 * _130;
  float _154 = dot(float3(GlobalShaderConsts_144.x, GlobalShaderConsts_144.y, 0.0f), float3(GlobalShaderConsts_144.x, GlobalShaderConsts_144.y, 0.0f));
  float _155 = rsqrt(_154);
  float _156 = _155 * GlobalShaderConsts_144.x;
  float _157 = _155 * GlobalShaderConsts_144.y;
  float _158 = dot(float3(_107, _108, _109), float3(_107, _108, _109));
  float _159 = rsqrt(_158);
  float _160 = _159 * _107;
  float _161 = _159 * _108;
  float _162 = _159 * _109;
  float _163 = dot(float3(_156, _157, 0.0f), float3(_160, _161, _162));
  float _164 = saturate(_163);
  float _169 = cb4_007x - cb4_006x;
  float _170 = _169 * _102;
  float _171 = _170 + cb4_006x;
  float _172 = max(_171, 0.0f);
  float _173 = min(_172, 5.0f);
  float _175 = -0.0f - GlobalShaderConsts_144.x;
  float _176 = -0.0f - GlobalShaderConsts_144.y;
  float _177 = -0.0f - GlobalShaderConsts_144.z;
  float _178 = dot(float3(_175, _176, _177), float3(_175, _176, _177));
  float _179 = rsqrt(_178);
  float _180 = _179 * _175;
  float _181 = _179 * _176;
  float _182 = _179 * _177;
  float _183 = dot(float3(_180, _181, _182), float3(_160, _161, _162));
  float _184 = saturate(_183);
  float _185 = log2(_184);
  float _186 = exp2(_185);
  float _187 = saturate(_186);
  float _188 = GlobalShaderConsts_144.z * 4.0f;
  float _189 = _188 + -1.0f;
  float _190 = saturate(_189);
  float _195 = cb4_009x - cb4_008x;
  float _196 = _195 * _187;
  float _197 = _196 + cb4_008x;
  float _200 = _173 - cb4_005x;
  float _201 = _200 * _187;
  float _202 = _201 + cb4_005x;
  float _203 = _197 - _202;
  float _204 = _203 * _190;
  float _205 = _204 + _202;
  float _210 = cb4_011x - cb4_010x;
  float _211 = _210 * _102;
  float _212 = _211 + cb4_010x;
  float _213 = _205 * _212;
  float _214 = _148 - _145;
  float _215 = _149 - _146;
  float _216 = _150 - _147;
  float _217 = _164 * _214;
  float _218 = _164 * _215;
  float _219 = _164 * _216;
  float _220 = _217 + _145;
  float _221 = _218 + _146;
  float _222 = _219 + _147;
  float _223 = log2(_213);
  float _224 = _223 * 2.200000047683716f;
  float _225 = exp2(_224);
  float _226 = _225 * _220;
  float _227 = _225 * _221;
  float _228 = _225 * _222;
  float _233 = _226 * cb12_248x;
  float _234 = _227 * cb12_248y;
  float _235 = _228 * cb12_248z;
  float _238 = _115 - cb4_000x;
  float _241 = cb4_001x - cb4_000x;
  float _242 = _238 / _241;
  float _243 = saturate(_242);
  float _244 = TEXCOORD_1.x + -1.0f;
  float _245 = TEXCOORD_2.w * 2.0f;
  float _246 = _244 + _245;
  float _247 = saturate(_246);
  float _251 = cb4_016x * TEXCOORD_1.x;
  float _252 = cb4_016y * TEXCOORD_1.y;
  float _258 = cb4_017x * GlobalShaderConsts_000.x;
  float _259 = cb4_017y * GlobalShaderConsts_000.x;
  float _260 = _258 + _251;
  float _261 = _259 + _252;
  float4 _264 = t1.Sample(s0, float2(_260, _261));
  float _270 = cb4_015x - cb4_014x;
  float _271 = _270 * _264.x;
  float _272 = _271 + cb4_014x;
  float _273 = saturate(_272);
  float _274 = _273 * _247;
  float _277 = _115 - cb4_012x;
  float _280 = cb4_013x - cb4_012x;
  float _281 = _277 / _280;
  float _282 = saturate(_281);
  float4 _285 = t0.Sample(s0, float2(_60, _61));
  float _290 = GlobalShaderConsts_016.z * SV_Position.x;
  float _291 = GlobalShaderConsts_016.w * SV_Position.y;
  float4 _294 = t15.SampleLevel(s15, float2(_290, _291), 0.0f);
  float _298 = cb12_022x * _294.x;
  float _300 = _298 + cb12_022y;
  float _303 = _300 * cb12_021x;
  float _305 = _303 + cb12_021y;
  float _306 = 1.0f / _305;
  float _307 = max(_306, -3.4028234663852886e+38f);
  float _308 = min(_307, 3.4028234663852886e+38f);
  float _309 = _308 - TEXCOORD_1.z;
  float _312 = cb4_018x * _309;
  float _313 = saturate(_312);
  float _314 = _274 * _282;
  float _315 = _314 + -1.0f;
  float _316 = _285.w * _313;
  float _317 = _316 + _315;
  float _322 = cb4_020x - cb4_019x;
  float _323 = _322 * _187;
  float _324 = _323 + cb4_019x;
  float _325 = _324 * _317;
  float _326 = saturate(_325);
  float _329 = FrequentPixelConsts_032.w * _326;
  float _330 = saturate(_329);
  float _331 = TEXCOORD.x - _233;
  float _332 = TEXCOORD.y - _234;
  float _333 = TEXCOORD.z - _235;
  float _334 = _243 * TEXCOORD.w;
  float _335 = _334 * _331;
  float _336 = _334 * _332;
  float _337 = _334 * _333;
  float _338 = _335 + _233;
  float _339 = _336 + _234;
  float _340 = _337 + _235;
  float _344 = FrequentPixelConsts_032.x * _338;
  float _345 = FrequentPixelConsts_032.y * _339;
  float _346 = FrequentPixelConsts_032.z * _340;
  float _347 = _344 * _329;
  float _348 = _345 * _329;
  float _349 = _346 * _329;
  SV_Target.x = _347;
  SV_Target.y = _348;
  SV_Target.z = _349;
  SV_Target.w = _330;
  return SV_Target;
}
