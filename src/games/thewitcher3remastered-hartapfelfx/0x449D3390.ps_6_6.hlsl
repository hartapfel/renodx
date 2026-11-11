#define HARTAPFEL_SKY_VIEW
#include "shared.h"
#define FOG_RECEIVER_FRAME
cbuffer HartapfelReceiverFrame : register(b12) { float4 receiver_frame[341]; }
#include "fog/receivers.hlsli"
#include "clouds/shadow_inputs.hlsli"
#include "clouds/sky_glow.hlsli"
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


TextureCube<float4> t0 : register(t0);

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

#define cb12_000x receiver_frame[0].x
#define cb12_000y receiver_frame[0].y
#define cb12_000z receiver_frame[0].z
#define cb12_022z receiver_frame[22].z
#define cb12_038x receiver_frame[38].x
#define cb12_038y receiver_frame[38].y
#define cb12_038z receiver_frame[38].z
#define cb12_039x receiver_frame[39].x
#define cb12_039y receiver_frame[39].y
#define cb12_039z receiver_frame[39].z
#define cb12_040x receiver_frame[40].x
#define cb12_040y receiver_frame[40].y
#define cb12_040z receiver_frame[40].z
#define cb12_041x receiver_frame[41].x
#define cb12_041y receiver_frame[41].y
#define cb12_041z receiver_frame[41].z
#define cb12_042x receiver_frame[42].x
#define cb12_042y receiver_frame[42].y
#define cb12_042z receiver_frame[42].z
#define cb12_042w receiver_frame[42].w
#define cb12_044x receiver_frame[44].x
#define cb12_044y receiver_frame[44].y
#define cb12_044z receiver_frame[44].z
#define cb12_048y receiver_frame[48].y
#define cb12_048z receiver_frame[48].z
#define cb12_189x receiver_frame[189].x
#define cb12_189y receiver_frame[189].y
#define cb12_189z receiver_frame[189].z
#define cb12_189w receiver_frame[189].w
#define cb12_190x receiver_frame[190].x
#define cb12_190y receiver_frame[190].y
#define cb12_190z receiver_frame[190].z
#define cb12_190w receiver_frame[190].w
#define cb12_191x receiver_frame[191].x
#define cb12_191y receiver_frame[191].y
#define cb12_191z receiver_frame[191].z
#define cb12_191w receiver_frame[191].w
#define cb12_192x receiver_frame[192].x
#define cb12_192y receiver_frame[192].y
#define cb12_192z receiver_frame[192].z
#define cb12_192w receiver_frame[192].w
#define cb12_193x receiver_frame[193].x
#define cb12_195x receiver_frame[195].x
#define cb12_195y receiver_frame[195].y
#define cb12_195z receiver_frame[195].z
#define cb12_196x receiver_frame[196].x
#define cb12_196y receiver_frame[196].y
#define cb12_196z receiver_frame[196].z
#define cb12_197x receiver_frame[197].x
#define cb12_197y receiver_frame[197].y
#define cb12_197z receiver_frame[197].z
#define cb12_198x receiver_frame[198].x
#define cb12_198y receiver_frame[198].y
#define cb12_198z receiver_frame[198].z
#define cb12_199x receiver_frame[199].x
#define cb12_199y receiver_frame[199].y
#define cb12_199z receiver_frame[199].z
#define cb12_200x receiver_frame[200].x
#define cb12_200y receiver_frame[200].y
#define cb12_200z receiver_frame[200].z
#define cb12_201x receiver_frame[201].x
#define cb12_201y receiver_frame[201].y
#define cb12_201z receiver_frame[201].z
#define cb12_202x receiver_frame[202].x
#define cb12_202y receiver_frame[202].y
#define cb12_202z receiver_frame[202].z
#define cb12_203x receiver_frame[203].x
#define cb12_203y receiver_frame[203].y
#define cb12_203z receiver_frame[203].z
#define cb12_203w receiver_frame[203].w
#define cb12_204x receiver_frame[204].x
#define cb12_204y receiver_frame[204].y
#define cb12_204z receiver_frame[204].z
#define cb12_204w receiver_frame[204].w
#define cb12_205x receiver_frame[205].x
#define cb12_205y receiver_frame[205].y
#define cb12_205z receiver_frame[205].z
#define cb12_205w receiver_frame[205].w
#define cb12_206x receiver_frame[206].x
#define cb12_206y receiver_frame[206].y
#define cb12_227x receiver_frame[227].x
#define cb12_227y receiver_frame[227].y
#define cb12_227z receiver_frame[227].z
#define cb12_227w receiver_frame[227].w
#define cb12_228x receiver_frame[228].x
#define cb12_228y receiver_frame[228].y
#define cb12_228z receiver_frame[228].z
#define cb12_228w receiver_frame[228].w
#define cb12_287z asint(receiver_frame[287].z)
#define cb12_padding asuint(receiver_frame[340].w)

#define SKY_FRAME receiver_frame
#define SKY_DATA HartapfelCloudData
#define SKY_MOON_MATERIAL sky_moon_material
#define SKY_SOLAR_MATERIAL sky_sun_material
#define SKY_SOLAR_GLOW_SIZE sky_sun_glow_size
#define SKY_GLOW_EXPOSURE sky_glow_exposure
#define SKY_CLOCK GlobalShaderConsts_000
#define SKY_NATIVE_RADIUS sky_native_radius
#define SKY_SUN_EMISSION sky_sun_emission
#define SKY_MOON_EMISSION sky_moon_emission
#include "sky/celestial.hlsli"
SamplerState s0 : register(s0);

float4 main(
  linear float2 TEXCOORD : TEXCOORD,
  linear float3 TEXCOORD_1 : TEXCOORD1,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  bool enhanced_sky=SkyReady();
  float4 SV_Target = 0;
  float _29 = TEXCOORD_1.x - cb12_000x;
  float _30 = TEXCOORD_1.y - cb12_000y;
  float _31 = TEXCOORD_1.z - cb12_000z;
  float _32 = _29 * _29;
  float _33 = _30 * _30;
  float _34 = _32 + _33;
  float _35 = _31 * _31;
  float _36 = _34 + _35;
  float _37 = sqrt(_36);
  float _38 = _29 / _37;
  float _39 = _30 / _37;
  float _40 = _31 / _37;
  float _41 = _40 * cb12_022z;
  float _42 = cb12_042z * 0.0625f;
  float _43 = _40 * _42;
  float _44 = _42 * cb12_044x;
  float _49 = dot(enhanced_sky ? SkyAtmosphereLight(receiver_frame[204].yzw,receiver_frame[205].yzw,receiver_frame[38].xyz) : receiver_frame[38].xyz,float3(_38,_39,_40));
  float _51 = _49 + cb12_042x;
  float _52 = cb12_042x + 1.0f;
  float _53 = _51 / _52;
  float _54 = saturate(_53);
  float _55 = cb12_044y - cb12_044z;
  float _56 = _54 * _55;
  float _57 = _56 + cb12_044z;
  bool _60 = (cb12_287z == 0);
  bool _66;
  float _74;
  float _88;
  float _89;
  float _90;
  float _246;
  float _247;
  float _327;
  float _328;
  float _329;
  float _330;
  float _356;
  float _357;
  float _358;
  float _359;
  float _360;
  float _524;
  float _575;
  if (!_60) {
    bool _62 = (_49 > 0.0f);
    bool _63 = (cb12_287z != 2);
    bool _64 = _62 && _63;
    _66 = _64;
  } else {
    _66 = true;
  }
  float _67 = abs(_49);
  float _68 = _67 * _67;
  if (_66) {
    float _70 = cb12_042z * 0.0020000000949949026f;
    float _71 = _70 + -0.30000001192092896f;
    float _72 = saturate(_71);
    _74 = _72;
  } else {
    _74 = 1.0f;
  }
  float _75 = _68 * _74;
  bool _76 = (_49 > 0.0f);
  if (_76) {
    _88 = cb12_039x;
    _89 = cb12_039y;
    _90 = cb12_039z;
  } else {
    _88 = cb12_041x;
    _89 = cb12_041y;
    _90 = cb12_041z;
  }
  float _95 = _88 - cb12_040x;
  float _96 = _89 - cb12_040y;
  float _97 = _90 - cb12_040z;
  float _98 = _95 * _75;
  float _99 = _96 * _75;
  float _100 = _97 * _75;
  float _101 = _98 + cb12_040x;
  float _102 = _99 + cb12_040y;
  float _103 = _100 + cb12_040z;
  bool _106 = !(cb12_042z >= cb12_048y);
  [branch]
  if (!_106) {
    float _109 = cb12_042y + cb12_000z;
    float _110 = _109 + _41;
    float _111 = _57 * _110;
    float _112 = _57 * _43;
    float _113 = _112 * 16.0f;
    float _114 = _113 + _111;
    float _115 = max(0.0f, _114);
    float _116 = _115 + 1.0f;
    float _117 = _44 / _116;
    float _118 = saturate(_117);
    float _119 = 1.0f - _118;
    float _120 = _112 * 15.0f;
    float _121 = _120 + _111;
    float _122 = max(0.0f, _121);
    float _123 = _122 + 1.0f;
    float _124 = _44 / _123;
    float _125 = saturate(_124);
    float _126 = 1.0f - _125;
    float _127 = _126 * _119;
    float _128 = _112 * 14.0f;
    float _129 = _128 + _111;
    float _130 = max(0.0f, _129);
    float _131 = _130 + 1.0f;
    float _132 = _44 / _131;
    float _133 = saturate(_132);
    float _134 = 1.0f - _133;
    float _135 = _127 * _134;
    float _136 = _112 * 13.0f;
    float _137 = _136 + _111;
    float _138 = max(0.0f, _137);
    float _139 = _138 + 1.0f;
    float _140 = _44 / _139;
    float _141 = saturate(_140);
    float _142 = 1.0f - _141;
    float _143 = _135 * _142;
    float _144 = _112 * 12.0f;
    float _145 = _144 + _111;
    float _146 = max(0.0f, _145);
    float _147 = _146 + 1.0f;
    float _148 = _44 / _147;
    float _149 = saturate(_148);
    float _150 = 1.0f - _149;
    float _151 = _143 * _150;
    float _152 = _112 * 11.0f;
    float _153 = _152 + _111;
    float _154 = max(0.0f, _153);
    float _155 = _154 + 1.0f;
    float _156 = _44 / _155;
    float _157 = saturate(_156);
    float _158 = 1.0f - _157;
    float _159 = _151 * _158;
    float _160 = _112 * 10.0f;
    float _161 = _160 + _111;
    float _162 = max(0.0f, _161);
    float _163 = _162 + 1.0f;
    float _164 = _44 / _163;
    float _165 = saturate(_164);
    float _166 = 1.0f - _165;
    float _167 = _159 * _166;
    float _168 = _112 * 9.0f;
    float _169 = _168 + _111;
    float _170 = max(0.0f, _169);
    float _171 = _170 + 1.0f;
    float _172 = _44 / _171;
    float _173 = saturate(_172);
    float _174 = 1.0f - _173;
    float _175 = _167 * _174;
    float _176 = _112 * 8.0f;
    float _177 = _176 + _111;
    float _178 = max(0.0f, _177);
    float _179 = _178 + 1.0f;
    float _180 = _44 / _179;
    float _181 = saturate(_180);
    float _182 = 1.0f - _181;
    float _183 = _175 * _182;
    float _184 = _112 * 7.0f;
    float _185 = _184 + _111;
    float _186 = max(0.0f, _185);
    float _187 = _186 + 1.0f;
    float _188 = _44 / _187;
    float _189 = saturate(_188);
    float _190 = 1.0f - _189;
    float _191 = _183 * _190;
    float _192 = _112 * 6.0f;
    float _193 = _192 + _111;
    float _194 = max(0.0f, _193);
    float _195 = _194 + 1.0f;
    float _196 = _44 / _195;
    float _197 = saturate(_196);
    float _198 = 1.0f - _197;
    float _199 = _191 * _198;
    float _200 = _112 * 5.0f;
    float _201 = _200 + _111;
    float _202 = max(0.0f, _201);
    float _203 = _202 + 1.0f;
    float _204 = _44 / _203;
    float _205 = saturate(_204);
    float _206 = 1.0f - _205;
    float _207 = _199 * _206;
    float _208 = _112 * 4.0f;
    float _209 = _208 + _111;
    float _210 = max(0.0f, _209);
    float _211 = _210 + 1.0f;
    float _212 = _44 / _211;
    float _213 = saturate(_212);
    float _214 = 1.0f - _213;
    float _215 = _207 * _214;
    float _216 = _112 * 3.0f;
    float _217 = _216 + _111;
    float _218 = max(0.0f, _217);
    float _219 = _218 + 1.0f;
    float _220 = _44 / _219;
    float _221 = saturate(_220);
    float _222 = 1.0f - _221;
    float _223 = _215 * _222;
    float _224 = _112 * 2.0f;
    float _225 = _224 + _111;
    float _226 = max(0.0f, _225);
    float _227 = _226 + 1.0f;
    float _228 = _44 / _227;
    float _229 = saturate(_228);
    float _230 = 1.0f - _229;
    float _231 = _223 * _230;
    float _232 = _110 + _43;
    float _233 = _57 * _232;
    float _234 = max(0.0f, _233);
    float _235 = _234 + 1.0f;
    float _236 = _44 / _235;
    float _237 = saturate(_236);
    float _238 = 1.0f - _237;
    float _239 = _231 * _238;
    float _240 = 1.0f - _239;
    float _241 = cb12_042z - cb12_048y;
    float _243 = _241 * cb12_048z;
    float _244 = saturate(_243);
    _246 = _240;
    _247 = _244;
  } else {
    _246 = 1.0f;
    _247 = 0.0f;
  }
  if(ReceiverFrameMatches()) _246=1.f-pow(saturate(1.f-_246),max(fx.sky_density,0.f));
  float _248 = abs(_246);
  float _249 = log2(_248);
  float _250 = _249 * cb12_042w;
  float _251 = exp2(_250);
  float _252 = _251 * _247;
  float _255 = cb12_190x * _252;
  float _257 = _255 + cb12_190y;
  float _258 = saturate(_257);
  float _260 = cb12_190z * _252;
  float _262 = _260 + cb12_190w;
  float _263 = saturate(_262);
  float _268 = cb12_189x - _101;
  float _269 = cb12_189y - _102;
  float _270 = cb12_189z - _103;
  float _271 = _268 * _258;
  float _272 = _269 * _258;
  float _273 = _270 * _258;
  float _274 = _271 + _101;
  float _275 = _272 + _102;
  float _276 = _273 + _103;
  float _278 = cb12_189w + -1.0f;
  float _279 = _278 * _263;
  float _280 = _279 + 1.0f;
  float _281 = _280 * _252;
  float _282 = saturate(_281);
  bool _285 = (cb12_193x > 0.0f);
  [branch]
  if (_285) {
    float _289 = cb12_192x * _252;
    float _291 = _289 + cb12_192y;
    float _292 = saturate(_291);
    float _294 = cb12_192z * _252;
    float _296 = _294 + cb12_192w;
    float _297 = saturate(_296);
    float _302 = cb12_191x - _101;
    float _303 = cb12_191y - _102;
    float _304 = cb12_191z - _103;
    float _305 = _302 * _292;
    float _306 = _303 * _292;
    float _307 = _304 * _292;
    float _309 = cb12_191w + -1.0f;
    float _310 = _309 * _297;
    float _311 = _310 + 1.0f;
    float _312 = _311 * _252;
    float _313 = saturate(_312);
    float _314 = _305 - _271;
    float _315 = _306 - _272;
    float _316 = _307 - _273;
    float _317 = _313 - _282;
    float _318 = _314 * cb12_193x;
    float _319 = _315 * cb12_193x;
    float _320 = _316 * cb12_193x;
    float _321 = _317 * cb12_193x;
    float _322 = _318 + _274;
    float _323 = _319 + _275;
    float _324 = _320 + _276;
    float _325 = _321 + _282;
    _327 = _322;
    _328 = _323;
    _329 = _324;
    _330 = _325;
  } else {
    _327 = _274;
    _328 = _275;
    _329 = _276;
    _330 = _282;
  }
  float _334 = cb12_000x - TEXCOORD_1.x;
  float _335 = cb12_000y - TEXCOORD_1.y;
  float _336 = cb12_000z - TEXCOORD_1.z;
  float _337 = dot(float3(_334, _335, _336), float3(_334, _335, _336));
  float _338 = rsqrt(_337);
  bool _339 = (FrequentPixelConsts_000.y == 1.0f);
  bool _340 = (FrequentPixelConsts_000.x == 1.0f);
  float _341 = _334 * _338;
  float _342 = -0.0f - _341;
  float _343 = _335 * _338;
  float _344 = -0.0f - _343;
  float _345 = _336 * _338;
  float _346 = -0.0f - _345;
  if (_340) {
    _356 = cb12_227w;
    _357 = cb12_227y;
    _358 = cb12_227x;
    _359 = cb12_227z;
    _360 = cb12_228z;
  } else {
    _356 = 1.0f;
    _357 = 1.0f;
    _358 = 1.0f;
    _359 = 1.0f;
    _360 = 1.0f;
  }
  float _371 = saturate(cb12_206y);
  float _373 = saturate(cb12_206x);
  float _374 = dot(float3(_342, _344, _346), float3(_342, _344, _346));
  float _375 = rsqrt(_374);
  float _376 = _375 * _342;
  float _377 = _375 * _344;
  float _378 = _375 * _346;
  float _379 = dot(float2(_376, _377), float2(_376, _377));
  float _380 = rsqrt(_379);
  float _381 = _380 * _376;
  float _382 = _380 * _377;
  float _383 = dot(float2(cb12_205y, cb12_205z), float2(cb12_205y, cb12_205z));
  float _384 = rsqrt(_383);
  float _385 = _384 * cb12_205y;
  float _386 = _384 * cb12_205z;
  float _387 = dot(float2(_385, _386), float2(_381, _382));
  float _388 = dot(float3(cb12_205y, cb12_205z, cb12_205w), float3(_376, _377, _378));
  float _389 = dot(float2(cb12_204y, cb12_204z), float2(cb12_204y, cb12_204z));
  float _390 = rsqrt(_389);
  float _391 = _390 * cb12_204y;
  float _392 = _390 * cb12_204z;
  float _393 = dot(float2(_391, _392), float2(_381, _382));
  float _394 = dot(float3(cb12_204y, cb12_204z, cb12_204w), float3(_376, _377, _378));
  float _399 = _387 * 0.5f;
  // Remove the azimuth-only lunar hotspot on the horizon; the centered
  // phase-consistent aureole is composited with the actual Moon below.
  float _400 = enhanced_sky ? 0.f : _399 + 0.5f;
  float _409 = cb12_200x - cb12_201x;
  float _410 = cb12_200y - cb12_201y;
  float _411 = cb12_200z - cb12_201z;
  float _412 = _409 * _400;
  float _413 = _410 * _400;
  float _414 = _411 * _400;
  float _415 = _412 + cb12_201x;
  float _416 = _413 + cb12_201y;
  float _417 = _414 + cb12_201z;
  float _418 = max(1.0f, _356);
  float _419 = _415 * _418;
  float _420 = _416 * _418;
  float _421 = _417 * _418;
  float _422 = _393 * 0.5f;
  float _423 = _422 + 0.5f;
  float _432 = cb12_197x - cb12_198x;
  float _433 = cb12_197y - cb12_198y;
  float _434 = cb12_197z - cb12_198z;
  float _435 = _432 * _423;
  float _436 = _433 * _423;
  float _437 = _434 * _423;
  float _438 = _435 + cb12_198x;
  float _439 = _436 + cb12_198y;
  float _440 = _437 + cb12_198z;
  float _441 = max(1.0f, _357);
  float _442 = _438 * _441;
  float _443 = _439 * _441;
  float _444 = _440 * _441;
  float _449 = _378 * _378;
  float _450 = 1.0f - _449;
  float _451 = _450 * _371;
  float _452 = min(1.0f, _356);
  float _453 = _451 * _452;
  float _454 = _419 - cb12_196x;
  float _455 = _420 - cb12_196y;
  float _456 = _421 - cb12_196z;
  float _457 = _453 * _454;
  float _458 = _453 * _455;
  float _459 = _453 * _456;
  float _460 = _457 + cb12_196x;
  float _461 = _458 + cb12_196y;
  float _462 = _459 + cb12_196z;
  float _463 = _450 * _373;
  float _464 = min(1.0f, _357);
  float _465 = _463 * _464;
  float _466 = _442 - _460;
  float _467 = _443 - _461;
  float _468 = _444 - _462;
  float _469 = _466 * _465;
  float _470 = _467 * _465;
  float _471 = _468 * _465;
  float _472 = _469 + _460;
  float _473 = _470 + _461;
  float _474 = _471 + _462;
  float _475 = dot(float3(_29, _30, _31), float3(_29, _30, _31));
  float _476 = rsqrt(_475);
  float _477 = _31 * 1000.0f;
  float _478 = _477 * _476;
  float _479 = cb12_000z + 710.0f;
  float _480 = _479 + _478;
  float _483 = cb12_203z * 0.0010000000474974513f;
  float _484 = _483 * _480;
  float _485 = _484 + 0.10000000149011612f;
  float _486 = max(9.999999747378752e-05f, _485);
  float _487 = 1.0f / _486;
  float _488 = saturate(_487);
  float _489 = log2(_488);
  float _490 = _489 * 2.799999952316284f;
  float _491 = exp2(_490);
  float _492 = 1.0f - _491;
  float _493 = cb12_195x - _472;
  float _494 = cb12_195y - _473;
  float _495 = cb12_195z - _474;
  float _496 = _492 * _493;
  float _497 = _492 * _494;
  float _498 = _492 * _495;
  float _499 = _496 + _472;
  float _500 = _497 + _473;
  float _501 = _498 + _474;
  bool volumetric_sky = CloudShadowMatches(receiver_frame[0].xyz, asuint(receiver_frame[286]));
  float3 celestial_ray=SkyDirection(TEXCOORD_1.xyz-receiver_frame[0].xyz);
  float celestial_footprint=max(length(ddx(celestial_ray)),length(ddy(celestial_ray)));
  float _503 = cb12_205x / _360;
  float _504 = saturate(_388);
  float _505 = log2(_504);
  float _506 = _505 * _503;
  float _507 = exp2(_506);
  float _508 = _507 * _371;
  float _509 = min(1.0f, _359);
  float _510 = _508 * _509;
  if (_340) {
    float _515 = saturate(cb12_205w);
    float _516 = _515 - cb12_228y;
    float _517 = cb12_228x - cb12_228y;
    float _518 = max(_517, 9.999999747378752e-05f);
    float _519 = _516 / _518;
    float _520 = saturate(_519);
    float _521 = saturate(_510);
    float _522 = _521 * _520;
    _524 = _522;
  } else {
    _524 = _510;
  }
  if (volumetric_sky)
    _524 *= HartapfelCloudEmitterVisibility(receiver_frame[0].xyz, receiver_frame[205].yzw);
  if(enhanced_sky) _524=0.f;
  float _525 = max(1.0f, _359);
  float _530 = cb12_202x * _525;
  float _531 = cb12_202y * _525;
  float _532 = cb12_202z * _525;
  float _533 = _530 - _499;
  float _534 = _531 - _500;
  float _535 = _532 - _501;
  float _536 = _533 * _524;
  float _537 = _534 * _524;
  float _538 = _535 * _524;
  float _539 = _536 + _499;
  float _540 = _537 + _500;
  float _541 = _538 + _501;
  float _543 = cb12_204x / _360;
  float _544 = saturate(_394);
  float _545 = min(1.0f, _358);
  if (_340) {
    float _550 = saturate(cb12_204w);
    float _551 = _550 - cb12_228y;
    float _552 = cb12_228x - cb12_228y;
    float _553 = max(_552, 9.999999747378752e-05f);
    float _554 = _551 / _553;
    float _555 = saturate(_554);
    float _557 = cb12_228w + _544;
    float _558 = cb12_228w + 1.0f;
    float _559 = _557 / _558;
    float _560 = saturate(_559);
    float _561 = log2(_560);
    float _562 = _561 * _543;
    float _563 = exp2(_562);
    float _564 = _545 * _373;
    float _565 = _564 * _563;
    float _566 = saturate(_565);
    float _567 = _566 * _555;
    _575 = _567;
  } else {
    float _569 = log2(_544);
    float _570 = _569 * _543;
    float _571 = exp2(_570);
    float _572 = _545 * _373;
    float _573 = _572 * _571;
    _575 = _573;
  }
  if (volumetric_sky) {
    _575 *= CloudSolarGlowScale(_543, _340 ? cb12_228w : 0.f);
  }
  if(enhanced_sky) _575=0.f;
  float _576 = max(1.0f, _358);
  float _581 = cb12_199x * _576;
  float _582 = cb12_199y * _576;
  float _583 = cb12_199z * _576;
  float _584 = _581 - _539;
  float _585 = _582 - _540;
  float _586 = _583 - _541;
  float _587 = _584 * _575;
  float _588 = _585 * _575;
  float _589 = _586 * _575;
  float _590 = _587 + _539;
  float _591 = _588 + _540;
  float _592 = _589 + _541;
  float _596 = select(_339, cb12_203w, 1.0f);
  float _597 = cb12_203y * cb12_203x;
  float _598 = _596 * _597;
  float _599 = _598 * _590;
  float _600 = _598 * _591;
  float _601 = _598 * _592;
  float _606 = cb1_036x - TEXCOORD_1.x;
  float _607 = cb1_036y - TEXCOORD_1.y;
  float _608 = cb1_036z - TEXCOORD_1.z;
  float _609 = dot(float3(_606, _607, _608), float3(_606, _607, _608));
  float _610 = rsqrt(_609);
  float _611 = _606 * _610;
  float _612 = _607 * _610;
  float _613 = _608 * _610;
  float _614 = -0.0f - cb12_205y;
  float _615 = cb12_205w * _614;
  float _616 = cb12_205z * cb12_205w;
  float _617 = -0.0f - _616;
  float _618 = cb12_205z * cb12_205z;
  float _619 = cb12_205y * _614;
  float _620 = _618 - _619;
  float _621 = dot(float3(_611, _612, _613), float3(_615, _617, _620));
  float _622 = dot(float3(_611, _612, _613), float3(cb12_205z, _614, 0.0f));
  float _623 = dot(float3(_611, _612, _613), float3(cb12_205y, cb12_205z, cb12_205w));
  float _624 = dot(float3(_621, _622, _623), float3(_621, _622, _623));
  float _625 = rsqrt(_624);
  float _626 = _625 * _621;
  float _627 = _625 * _622;
  float _628 = _625 * _623;
  // The native cubemap carries painted cloud detail as well as broad sky
  // color. Keep its low-frequency color during lightning and weather shifts.
  float4 _631 = enhanced_sky ? float4(1.f,1.f,1.f,1.f) : (volumetric_sky ? t0.SampleLevel(s0, float3(_626, _627, _628), 9.f)
                               : t0.Sample(s0, float3(_626, _627, _628)));
  float _635 = TEXCOORD.x * 100.0f;
  float _636 = TEXCOORD.y * 50.0f;
  float _639 = GlobalShaderConsts_000.x + _636;
  float _640 = floor(_635);
  float _641 = floor(_639);
  int _642 = asint(_641);
  int _643 = asint(_640);
  int _644 = reversebits(_642);
  int _645 = _644 + _643;
  uint _646 = _645 >> 13;
  int _647 = _646 ^ _645;
  uint _648 = _647 * 60493;
  uint _649 = _648 * _647;
  int _650 = _649 + 19990303;
  int _651 = _650 * _647;
  int _652 = _651 + 1376312589;
  int _653 = _652 & 2147483647;
  float _654 = float((int)(_653));
  float _655 = _640 + -1.0f;
  int _656 = asint(_655);
  int _657 = _644 + _656;
  uint _658 = _657 >> 13;
  int _659 = _658 ^ _657;
  uint _660 = _659 * 60493;
  uint _661 = _660 * _659;
  int _662 = _661 + 19990303;
  int _663 = _662 * _659;
  int _664 = _663 + 1376312589;
  int _665 = _664 & 2147483647;
  float _666 = float((int)(_665));
  float _667 = _641 + -1.0f;
  int _668 = asint(_667);
  int _669 = reversebits(_668);
  int _670 = _669 + _643;
  uint _671 = _670 >> 13;
  int _672 = _671 ^ _670;
  uint _673 = _672 * 60493;
  uint _674 = _673 * _672;
  int _675 = _674 + 19990303;
  int _676 = _675 * _672;
  int _677 = _676 + 1376312589;
  int _678 = _677 & 2147483647;
  float _679 = float((int)(_678));
  int _680 = _669 + _656;
  uint _681 = _680 >> 13;
  int _682 = _681 ^ _680;
  uint _683 = _682 * 60493;
  uint _684 = _683 * _682;
  int _685 = _684 + 19990303;
  int _686 = _685 * _682;
  int _687 = _686 + 1376312589;
  int _688 = _687 & 2147483647;
  float _689 = float((int)(_688));
  float _690 = frac(_635);
  float _691 = 1.0f - _690;
  float _692 = _691 * 2.0f;
  float _693 = 3.0f - _692;
  float _694 = _691 * _691;
  float _695 = _694 * _693;
  float _696 = frac(_639);
  float _697 = 1.0f - _696;
  float _698 = _697 * 2.0f;
  float _699 = 3.0f - _698;
  float _700 = _666 - _654;
  float _701 = _700 * _695;
  float _702 = _701 + _654;
  float _703 = _689 - _679;
  float _704 = _703 * _695;
  float _705 = _704 + _679;
  float _706 = _705 - _702;
  float _707 = _697 * _697;
  float _708 = _707 * _699;
  float _709 = _708 * _706;
  float _710 = _709 + _702;
  float _711 = _710 * 2.328306547127318e-13f;
  float _712 = _711 + _626;
  float _713 = _711 + _627;
  float _714 = _711 + _628;
  float4 _717 = enhanced_sky ? float4(1.f,1.f,1.f,1.f) : (volumetric_sky ? t0.SampleLevel(s0, float3(_712, _713, _714), 9.f)
                               : t0.Sample(s0, float3(_712, _713, _714)));
  float _721 = log2(_631.x);
  float _722 = log2(_631.y);
  float _723 = log2(_631.z);
  float _724 = _721 * 2.200000047683716f;
  float _725 = _722 * 2.200000047683716f;
  float _726 = _723 * 2.200000047683716f;
  float _727 = exp2(_724);
  float _728 = exp2(_725);
  float _729 = exp2(_726);
  float _730 = log2(_717.x);
  float _731 = log2(_717.y);
  float _732 = log2(_717.z);
  float _733 = _730 * 2.200000047683716f;
  float _734 = _731 * 2.200000047683716f;
  float _735 = _732 * 2.200000047683716f;
  float _736 = exp2(_733);
  float _737 = exp2(_734);
  float _738 = exp2(_735);
  float _739 = _736 * _727;
  float _740 = _737 * _728;
  float _741 = _738 * _729;
  float _742 = -0.0f - cb12_205z;
  float _743 = -0.0f - cb12_205w;
  float _744 = dot(float3(_614, _742, _743), float3(_614, _742, _743));
  float _745 = rsqrt(_744);
  float _746 = _745 * _614;
  float _747 = _745 * _742;
  float _748 = _745 * _743;
  float _749 = dot(float3(_746, _747, _748), float3(_611, _612, _613));
  float _750 = saturate(_749);
  float _751 = log2(_750);
  float _752 = _751 * 50.0f;
  float _753 = exp2(_752);
  float _754 = saturate(_753);
  float _755 = 1.0f - _754;
  float _756 = _739 * _755;
  float _757 = _740 * _755;
  float _758 = _741 * _755;
  float _759 = log2(_756);
  float _760 = log2(_757);
  float _761 = log2(_758);
  float _762 = _759 * 2.5f;
  float _763 = _760 * 2.5f;
  float _764 = _761 * 2.5f;
  float _765 = exp2(_762);
  float _766 = exp2(_763);
  float _767 = exp2(_764);
  float _768 = saturate(_765);
  float _769 = saturate(_766);
  float _770 = saturate(_767);
  float _773 = 1.0f - GlobalShaderConsts_144.w;
  float _774 = _773 * 10.0f;
  float _775 = enhanced_sky ? 0.f : (_774 * _768);
  float _776 = enhanced_sky ? 0.f : (_774 * _769);
  float _777 = enhanced_sky ? 0.f : (_774 * _770);
  float _778 = _775 + _599;
  float _779 = _776 + _600;
  float _780 = _777 + _601;
  float _781 = _327 - _778;
  float _782 = _328 - _779;
  float _783 = _329 - _780;
  float _784 = _781 * _330;
  float _785 = _782 * _330;
  float _786 = _783 * _330;
  float _787 = _784 + _778;
  float _788 = _785 + _779;
  float _789 = _786 + _780;
  SV_Target.x = _787;
  SV_Target.y = _788;
  SV_Target.z = _789;
  SV_Target.w = 1.0f;
  if(enhanced_sky) {
    float3 solar,lunar;float moon_mask;
    float air=SkyFogTransmission(celestial_ray);
    SkyDiscs(celestial_ray,celestial_footprint,air,solar,lunar,moon_mask);
    SV_Target.rgb+=SkyStars(celestial_ray,celestial_footprint,air,moon_mask);
    if(fx.sky_deferred!=0x534B5943u)SV_Target.rgb+=solar+lunar+SkyGlow(celestial_ray,air);
  }
  if(ReceiverFrameMatches()) SV_Target.rgb += SampleFogVolume(SV_Position.xy,asfloat(FogVolume.Load(12))).rgb;
  return SV_Target;
}
