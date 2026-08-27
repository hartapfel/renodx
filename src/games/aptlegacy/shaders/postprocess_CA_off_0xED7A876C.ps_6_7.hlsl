struct GlobalCB_Z__AnchorConstant_Z {
  float4 GlobalCB_Z__AnchorConstant_Z_000[7];
  float4 GlobalCB_Z__AnchorConstant_Z_112;
  float4 GlobalCB_Z__AnchorConstant_Z_128;
  float4 GlobalCB_Z__AnchorConstant_Z_144;
  float4 GlobalCB_Z__AnchorConstant_Z_160;
  float4 GlobalCB_Z__AnchorConstant_Z_176;
  float4 GlobalCB_Z__AnchorConstant_Z_192;
  float4 GlobalCB_Z__AnchorConstant_Z_208;
  float4 GlobalCB_Z__AnchorConstant_Z_224;
  float4 GlobalCB_Z__AnchorConstant_Z_240;
  float4 GlobalCB_Z__AnchorConstant_Z_256[4];
  float4 GlobalCB_Z__AnchorConstant_Z_320;
  float4 GlobalCB_Z__AnchorConstant_Z_336;
};

struct GlobalCB_Z__ProjConstant_Z {
  float4 GlobalCB_Z__ProjConstant_Z_000[4][32];
  float2 GlobalCB_Z__ProjConstant_Z_2048;
  float2 GlobalCB_Z__ProjConstant_Z_2056;
  int4 GlobalCB_Z__ProjConstant_Z_2064;
  float4 GlobalCB_Z__ProjConstant_Z_2080[4];
};

struct GlobalCB_Z__GlobalConstant_Z {
  float4 GlobalCB_Z__GlobalConstant_Z_000[104];
  int GlobalCB_Z__GlobalConstant_Z_1664;
  int3 GlobalCB_Z__GlobalConstant_Z_1668;
  float3 GlobalCB_Z__GlobalConstant_Z_1680;
  int GlobalCB_Z__GlobalConstant_Z_1692;
};

struct GlobalCB_Z__ViewConstant_Z {
  float4 GlobalCB_Z__ViewConstant_Z_000;
  float4 GlobalCB_Z__ViewConstant_Z_016;
  float4 GlobalCB_Z__ViewConstant_Z_032[32];
};

struct GlobalCB_Z__ViewportConstant_Z {
  float2 GlobalCB_Z__ViewportConstant_Z_000;
  float2 GlobalCB_Z__ViewportConstant_Z_008;
  float2 GlobalCB_Z__ViewportConstant_Z_016;
  float2 GlobalCB_Z__ViewportConstant_Z_024;
  float2 GlobalCB_Z__ViewportConstant_Z_032;
  int2 GlobalCB_Z__ViewportConstant_Z_040;
  float GlobalCB_Z__ViewportConstant_Z_048;
  int GlobalCB_Z__ViewportConstant_Z_052;
  float GlobalCB_Z__ViewportConstant_Z_056;
  int GlobalCB_Z__ViewportConstant_Z_060;
  float4 GlobalCB_Z__ViewportConstant_Z_064;
  float3 GlobalCB_Z__ViewportConstant_Z_080;
  float GlobalCB_Z__ViewportConstant_Z_092;
};

struct GlobalCB_Z {
  GlobalCB_Z__GlobalConstant_Z GlobalCB_Z_000;
  GlobalCB_Z__ViewportConstant_Z GlobalCB_Z_1696;
  GlobalCB_Z__AnchorConstant_Z GlobalCB_Z_1792;
  GlobalCB_Z__ViewConstant_Z GlobalCB_Z_2144;
  GlobalCB_Z__ProjConstant_Z GlobalCB_Z_2688;
};

struct PostProcessConstant_Z {
  float4 PostProcessConstant_Z_000[20];
  float4 PostProcessConstant_Z_320[32];
};

struct UserConstant_Z {
  float4 UserConstant_Z_000[84];
};


Texture2DArray<float4> t1 : register(t1);

Texture2DArray<float4> t6 : register(t6);

Texture2D<float4> t0 : register(t0);

Texture2D<float4> t2 : register(t2);

Texture3D<float4> t3 : register(t3);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t7 : register(t7);

Texture2D<float4> t8 : register(t8);

Texture2D<float4> t12 : register(t12);

Texture2D<float4> t14 : register(t14);

Texture2D<float4> t15 : register(t15);

Texture2D<float4> t16 : register(t16);

Texture2D<float4> t17 : register(t17);

#include "../common.hlsli"

cbuffer cb1 : register(b1) {
  GlobalCB_Z Global_000 : packoffset(c000.x);
  float4 cb1_raw[302] : packoffset(c0);
};

cbuffer cb0 : register(b0) {
  UserConstant_Z User_000 : packoffset(c000.x);
  float4 cb0_raw[84] : packoffset(c0);
};

cbuffer cb2 : register(b2) {
  PostProcessConstant_Z PostProcess_000 : packoffset(c000.x);
  float4 cb2_raw[52] : packoffset(c0);
};

SamplerState s1 : register(s1);

SamplerState s0 : register(s0);

SamplerState s2 : register(s2);

SamplerState s3 : register(s3);

SamplerState s4 : register(s4);

SamplerState s5 : register(s5);

SamplerState s7 : register(s7);

SamplerState s8 : register(s8);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _38 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _44 = t16.Sample(s1, float2(TEXCOORD.z, TEXCOORD.w));
  float _46 = _44.y * 0.10000000149011612f;
  float _47 = _46 + _38.y;
  float _48 = _44.y * 0.5f;
  float _49 = _48 + _38.z;
  float _50 = exp2(_49);
  float _51 = _50 + -1.0f;
  float _54 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _51;
  float _55 = _54 + 1.0f;
  float _56 = log2(_55);
  float _57 = _38.x + TEXCOORD.z;
  float _58 = _47 + TEXCOORD.w;
  float _59 = _38.x + TEXCOORD.x;
  float _60 = _47 + TEXCOORD.y;
  float _61 = _56 + 1.0f;
  float _62 = log2(_61);
  float4 _65 = t0.SampleLevel(s1, float2(_57, _58), _62);
  bool _70 = (_62 > 0.0f);
  float _375;
  float _376;
  float _377;
  float _378;
  float _414;
  float _498;
  float _535;
  float _725;
  float _764;
  float _765;
  float _766;
  float _805;
  float _806;
  float _807;
  float _1010;
  float _1114;
  float _1218;
  float _1221;
  float _1222;
  float _1223;
  float _1234;
  float _1359;
  float _1360;
  float _1361;
  float _1408;
  float _1409;
  float _1410;
  float _1424;
  float _1425;
  float _1426;
  [branch]
  if (_70) {
    float _72 = floor(_62);
    int _73 = int(_72);
    uint4 _74 = 0u; t0.GetDimensions(0u, _74.x, _74.y, _74.w);
    int _77 = _73 & 31;
    int _78 = (uint)(_74.x) >> _77;
    float _79 = float((uint)_78);
    int _80 = (uint)(_74.y) >> _77;
    float _81 = float((uint)_80);
    float _82 = 1.0f / _79;
    float _83 = 1.0f / _81;
    float _84 = _79 * _57;
    float _85 = _81 * _58;
    float _86 = _84 + -0.5f;
    float _87 = _85 + -0.5f;
    float _88 = frac(_86);
    float _89 = frac(_87);
    float _90 = floor(_86);
    float _91 = floor(_87);
    float _92 = 1.0f - _88;
    float _93 = 2.0f - _88;
    float _94 = 3.0f - _88;
    float _95 = _92 * _92;
    float _96 = _93 * _93;
    float _97 = _94 * _94;
    float _98 = _95 * _92;
    float _99 = _96 * _93;
    float _100 = _97 * _94;
    float _101 = _98 * 4.0f;
    float _102 = _99 - _101;
    float _103 = _99 * 4.0f;
    float _104 = _98 * 6.0f;
    float _105 = 6.0f - _98;
    float _106 = _105 - _102;
    float _107 = _103 - _100;
    float _108 = _107 - _104;
    float _109 = _108 + _106;
    float _110 = _102 * 0.1666666716337204f;
    float _111 = _109 * 0.1666666716337204f;
    float _112 = 1.0f - _89;
    float _113 = 2.0f - _89;
    float _114 = 3.0f - _89;
    float _115 = _112 * _112;
    float _116 = _113 * _113;
    float _117 = _114 * _114;
    float _118 = _115 * _112;
    float _119 = _116 * _113;
    float _120 = _117 * _114;
    float _121 = _118 * 4.0f;
    float _122 = _119 - _121;
    float _123 = _119 * 4.0f;
    float _124 = _118 * 6.0f;
    float _125 = 6.0f - _118;
    float _126 = _125 - _122;
    float _127 = _123 - _120;
    float _128 = _127 - _124;
    float _129 = _128 + _126;
    float _130 = _122 * 0.1666666716337204f;
    float _131 = _129 * 0.1666666716337204f;
    float _132 = _90 + -0.5f;
    float _133 = _90 + 1.5f;
    float _134 = _91 + -0.5f;
    float _135 = _91 + 1.5f;
    float _136 = _102 + _98;
    float _137 = _136 * 0.1666666716337204f;
    float _138 = _106 * 0.1666666716337204f;
    float _139 = _122 + _118;
    float _140 = _139 * 0.1666666716337204f;
    float _141 = _126 * 0.1666666716337204f;
    float _142 = _110 / _137;
    float _143 = _111 / _138;
    float _144 = _130 / _140;
    float _145 = _131 / _141;
    float _146 = _132 + _142;
    float _147 = _133 + _143;
    float _148 = _134 + _144;
    float _149 = _135 + _145;
    float _150 = _146 * _82;
    float _151 = _147 * _82;
    float _152 = _148 * _83;
    float _153 = _149 * _83;
    float _154 = float((int)(_73));
    float4 _156 = t0.SampleLevel(s0, float2(_150, _152), _154);
    float4 _161 = t0.SampleLevel(s0, float2(_151, _152), _154);
    float4 _166 = t0.SampleLevel(s0, float2(_150, _153), _154);
    float4 _171 = t0.SampleLevel(s0, float2(_151, _153), _154);
    float _176 = _156.x - _161.x;
    float _177 = _156.y - _161.y;
    float _178 = _156.z - _161.z;
    float _179 = _156.w - _161.w;
    float _180 = _176 * _137;
    float _181 = _177 * _137;
    float _182 = _178 * _137;
    float _183 = _179 * _137;
    float _184 = _180 + _161.x;
    float _185 = _181 + _161.y;
    float _186 = _182 + _161.z;
    float _187 = _183 + _161.w;
    float _188 = _166.x - _171.x;
    float _189 = _166.y - _171.y;
    float _190 = _166.z - _171.z;
    float _191 = _166.w - _171.w;
    float _192 = _188 * _137;
    float _193 = _189 * _137;
    float _194 = _190 * _137;
    float _195 = _191 * _137;
    float _196 = _192 + _171.x;
    float _197 = _193 + _171.y;
    float _198 = _194 + _171.z;
    float _199 = _195 + _171.w;
    float _200 = _184 - _196;
    float _201 = _185 - _197;
    float _202 = _186 - _198;
    float _203 = _187 - _199;
    float _204 = _200 * _140;
    float _205 = _201 * _140;
    float _206 = _202 * _140;
    float _207 = _203 * _140;
    float _208 = _204 + _196;
    float _209 = _205 + _197;
    float _210 = _206 + _198;
    float _211 = _207 + _199;
    float _212 = ceil(_62);
    int _213 = int(_212);
    int _214 = _213 & 31;
    int _215 = (uint)(_74.x) >> _214;
    float _216 = float((uint)_215);
    int _217 = (uint)(_74.y) >> _214;
    float _218 = float((uint)_217);
    float _219 = 1.0f / _216;
    float _220 = 1.0f / _218;
    float _221 = _216 * _57;
    float _222 = _218 * _58;
    float _223 = _221 + -0.5f;
    float _224 = _222 + -0.5f;
    float _225 = frac(_223);
    float _226 = frac(_224);
    float _227 = floor(_223);
    float _228 = floor(_224);
    float _229 = 1.0f - _225;
    float _230 = 2.0f - _225;
    float _231 = 3.0f - _225;
    float _232 = _229 * _229;
    float _233 = _230 * _230;
    float _234 = _231 * _231;
    float _235 = _232 * _229;
    float _236 = _233 * _230;
    float _237 = _234 * _231;
    float _238 = _235 * 4.0f;
    float _239 = _236 - _238;
    float _240 = _236 * 4.0f;
    float _241 = _235 * 6.0f;
    float _242 = 6.0f - _235;
    float _243 = _242 - _239;
    float _244 = _240 - _237;
    float _245 = _244 - _241;
    float _246 = _245 + _243;
    float _247 = _239 * 0.1666666716337204f;
    float _248 = _246 * 0.1666666716337204f;
    float _249 = 1.0f - _226;
    float _250 = 2.0f - _226;
    float _251 = 3.0f - _226;
    float _252 = _249 * _249;
    float _253 = _250 * _250;
    float _254 = _251 * _251;
    float _255 = _252 * _249;
    float _256 = _253 * _250;
    float _257 = _254 * _251;
    float _258 = _255 * 4.0f;
    float _259 = _256 - _258;
    float _260 = _256 * 4.0f;
    float _261 = _255 * 6.0f;
    float _262 = 6.0f - _255;
    float _263 = _262 - _259;
    float _264 = _260 - _257;
    float _265 = _264 - _261;
    float _266 = _265 + _263;
    float _267 = _259 * 0.1666666716337204f;
    float _268 = _266 * 0.1666666716337204f;
    float _269 = _227 + -0.5f;
    float _270 = _227 + 1.5f;
    float _271 = _228 + -0.5f;
    float _272 = _228 + 1.5f;
    float _273 = _239 + _235;
    float _274 = _273 * 0.1666666716337204f;
    float _275 = _243 * 0.1666666716337204f;
    float _276 = _259 + _255;
    float _277 = _276 * 0.1666666716337204f;
    float _278 = _263 * 0.1666666716337204f;
    float _279 = _247 / _274;
    float _280 = _248 / _275;
    float _281 = _267 / _277;
    float _282 = _268 / _278;
    float _283 = _269 + _279;
    float _284 = _270 + _280;
    float _285 = _271 + _281;
    float _286 = _272 + _282;
    float _287 = _283 * _219;
    float _288 = _284 * _219;
    float _289 = _285 * _220;
    float _290 = _286 * _220;
    float _291 = float((int)(_213));
    float4 _292 = t0.SampleLevel(s0, float2(_287, _289), _291);
    float4 _297 = t0.SampleLevel(s0, float2(_288, _289), _291);
    float4 _302 = t0.SampleLevel(s0, float2(_287, _290), _291);
    float4 _307 = t0.SampleLevel(s0, float2(_288, _290), _291);
    float _312 = _292.x - _297.x;
    float _313 = _292.y - _297.y;
    float _314 = _292.z - _297.z;
    float _315 = _292.w - _297.w;
    float _316 = _312 * _274;
    float _317 = _313 * _274;
    float _318 = _314 * _274;
    float _319 = _315 * _274;
    float _320 = _316 + _297.x;
    float _321 = _317 + _297.y;
    float _322 = _318 + _297.z;
    float _323 = _319 + _297.w;
    float _324 = _302.x - _307.x;
    float _325 = _302.y - _307.y;
    float _326 = _302.z - _307.z;
    float _327 = _302.w - _307.w;
    float _328 = _324 * _274;
    float _329 = _325 * _274;
    float _330 = _326 * _274;
    float _331 = _327 * _274;
    float _332 = _328 + _307.x;
    float _333 = _329 + _307.y;
    float _334 = _330 + _307.z;
    float _335 = _331 + _307.w;
    float _336 = _320 - _332;
    float _337 = _321 - _333;
    float _338 = _322 - _334;
    float _339 = _323 - _335;
    float _340 = _336 * _277;
    float _341 = _337 * _277;
    float _342 = _338 * _277;
    float _343 = _339 * _277;
    float _344 = frac(_62);
    float _345 = _332 - _208;
    float _346 = _345 + _340;
    float _347 = _333 - _209;
    float _348 = _347 + _341;
    float _349 = _334 - _210;
    float _350 = _349 + _342;
    float _351 = _335 - _211;
    float _352 = _351 + _343;
    float _353 = _346 * _344;
    float _354 = _348 * _344;
    float _355 = _350 * _344;
    float _356 = _352 * _344;
    float _357 = saturate(_62);
    float _358 = _208 - _65.x;
    float _359 = _358 + _353;
    float _360 = _209 - _65.y;
    float _361 = _360 + _354;
    float _362 = _210 - _65.z;
    float _363 = _362 + _355;
    float _364 = _211 - _65.w;
    float _365 = _364 + _356;
    float _366 = _359 * _357;
    float _367 = _361 * _357;
    float _368 = _363 * _357;
    float _369 = _365 * _357;
    float _370 = _366 + _65.x;
    float _371 = _367 + _65.y;
    float _372 = _368 + _65.z;
    float _373 = _369 + _65.w;
    _375 = _370;
    _376 = _371;
    _377 = _372;
    _378 = _373;
  } else {
    _375 = _65.x;
    _376 = _65.y;
    _377 = _65.z;
    _378 = _65.w;
  }
  float _379 = max(_375, 0.0f);
  float _380 = max(_376, 0.0f);
  float _381 = max(_377, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_379, _380, _381),
      float3(_379, _380, _381),
      float2(_57, _58),
      t0,
      s1,
      _62);
  _379 = renodx_chromatic_aberration_input.x;
  _380 = renodx_chromatic_aberration_input.y;
  _381 = renodx_chromatic_aberration_input.z;
  int _384 = asint((User_000.UserConstant_Z_000[7].z));
  bool _385 = ((int)_384 > (int)0);
  [branch]
  if (_385) {
    bool _390 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_390) {
      float _392 = _38.x + TEXCOORD.x;
      float _393 = _47 + TEXCOORD.y;
      float4 _396 = t2.SampleLevel(s2, float2(_392, _393), 0.0f);
      bool _400 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_400) {
        float4 _403 = t7.Load(int3(0, 0, 0));
        float _408 = _403.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _409 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _408;
        _414 = _409;
      } else {
        _414 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _418 = _396.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _419 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _418;
      float _421 = _414 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _422 = _421 + _414;
      float _423 = _414 - _421;
      float _424 = max(_419, _423);
      float _425 = min(_424, _422);
      float _428 = _419 - _425;
      float _429 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _428;
      float _431 = _425 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _432 = _431 * _419;
      float _433 = _429 / _432;
      float _434 = min(_433, 0.0f);
      float _436 = _421 + 1.0f;
      float _437 = 1.0f / _436;
      float _438 = _434 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _439 = max(0.0f, _433);
      float _442 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _439;
      float _443 = _442 + _438;
      float _444 = _443 * _437;
      float _445 = max(_444, -1.0f);
      float _446 = min(_445, 1.0f);
      float _447 = max(_446, -0.30000001192092896f);
      float _448 = min(_447, 1.0f);
      float _450 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _451 = _448 * _450;
      float _452 = _392 + -0.5f;
      float _453 = _393 + -0.5f;
      float _454 = _452 * _452;
      float _455 = _453 * _453;
      float _456 = _455 + _454;
      float _457 = sqrt(_456);
      float _458 = log2(_457);
      float _459 = _458 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _460 = exp2(_459);
      float _461 = _460 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _462 = dot(float2(_452, _453), float2(_452, _453));
      float _463 = rsqrt(_462);
      float _464 = _463 * _452;
      float _465 = _463 * _453;
      float _466 = abs(_451);
      float _470 = _461 * _466;
      float _471 = -0.0f - _470;
      float _472 = (User_000.UserConstant_Z_000[2].x) * _464;
      float _473 = _472 * _471;
      float _474 = (User_000.UserConstant_Z_000[2].y) * _465;
      float _475 = _474 * _471;
      float _476 = _466 * _461;
      float _477 = _472 * _476;
      float _478 = _474 * _476;
      float _479 = _473 + _392;
      float _480 = _475 + _393;
      float _481 = _477 + _392;
      float _482 = _478 + _393;
      float4 _483 = t0.SampleLevel(s1, float2(_479, _480), 0.0f);
      float4 _485 = t0.SampleLevel(s1, float2(_481, _482), 0.0f);
      float4 _487 = t2.SampleLevel(s2, float2(_479, _480), 0.0f);
      if (_400) {
        float4 _491 = t7.Load(int3(0, 0, 0));
        float _493 = _491.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _494 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _493;
        _498 = _494;
      } else {
        _498 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _499 = _487.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _500 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _499;
      float _501 = _498 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _502 = _501 + _498;
      float _503 = _498 - _501;
      float _504 = max(_500, _503);
      float _505 = min(_504, _502);
      float _506 = _500 - _505;
      float _507 = _506 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _508 = _505 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _509 = _508 * _500;
      float _510 = _507 / _509;
      float _511 = min(_510, 0.0f);
      float _512 = _501 + 1.0f;
      float _513 = 1.0f / _512;
      float _514 = _511 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _515 = max(0.0f, _510);
      float _516 = _515 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _517 = _516 + _514;
      float _518 = _517 * _513;
      float _519 = max(_518, -1.0f);
      float _520 = min(_519, 1.0f);
      float _521 = max(_520, -0.30000001192092896f);
      float _522 = min(_521, 1.0f);
      float _523 = _522 * _450;
      float4 _524 = t2.SampleLevel(s2, float2(_481, _482), 0.0f);
      if (_400) {
        float4 _528 = t7.Load(int3(0, 0, 0));
        float _530 = _528.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _531 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _530;
        _535 = _531;
      } else {
        _535 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _536 = _524.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _537 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _536;
      float _538 = _535 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _539 = _538 + _535;
      float _540 = _535 - _538;
      float _541 = max(_537, _540);
      float _542 = min(_541, _539);
      float _543 = _537 - _542;
      float _544 = _543 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _545 = _542 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _546 = _545 * _537;
      float _547 = _544 / _546;
      float _548 = min(_547, 0.0f);
      float _549 = _538 + 1.0f;
      float _550 = 1.0f / _549;
      float _551 = _548 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _552 = max(0.0f, _547);
      float _553 = _552 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _554 = _553 + _551;
      float _555 = _554 * _550;
      float _556 = max(_555, -1.0f);
      float _557 = min(_556, 1.0f);
      float _558 = max(_557, -0.30000001192092896f);
      float _559 = min(_558, 1.0f);
      float _560 = _559 * _450;
      float _561 = abs(_523);
      float _562 = _561 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _563 = ceil(_562);
      float _564 = saturate(_563);
      float _565 = _483.x - _379;
      float _566 = _564 * _565;
      float _567 = _566 + _379;
      float _568 = abs(_560);
      float _569 = _568 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _570 = ceil(_569);
      float _571 = saturate(_570);
      float _572 = _485.z - _381;
      float _573 = _571 * _572;
      float _574 = _573 + _381;
      _764 = _567;
      _765 = _380;
      _766 = _574;
    } else {
      _764 = _379;
      _765 = _380;
      _766 = _381;
    }
  } else {
    int _577 = asint((User_000.UserConstant_Z_000[7].y));
    bool _578 = ((int)_577 > (int)0);
    if (_578) {
      float _580 = _38.x + TEXCOORD.x;
      float _581 = _47 + TEXCOORD.y;
      float4 _584 = t4.Sample(s4, float2(_580, _581));
      float4 _591 = t5.Sample(s5, float2(_580, _581));
      float _595 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _591.x;
      float _599 = _595 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _600 = _595 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _601 = _599 + _580;
      float _602 = _600 + _581;
      float4 _603 = t4.Sample(s4, float2(_601, _602));
      float4 _605 = t5.Sample(s5, float2(_601, _602));
      float _607 = _605.x * (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _608 = abs(_607);
      float _610 = _608 / (PostProcess_000.PostProcessConstant_Z_000[7].w);
      float _611 = _603.z - _584.z;
      float _612 = _610 * _611;
      float _613 = _584.x - _379;
      float _614 = _584.y - _380;
      float _615 = _584.z - _381;
      float _616 = _615 + _612;
      float _617 = _613 * _584.w;
      float _618 = _614 * _584.w;
      float _619 = _616 * _584.w;
      float _620 = _617 + _379;
      float _621 = _618 + _380;
      float _622 = _619 + _381;
      _764 = _620;
      _765 = _621;
      _766 = _622;
    } else {
      int _625 = asint((User_000.UserConstant_Z_000[7].x));
      bool _626 = ((int)_625 > (int)0);
      [branch]
      if (_626) {
        float4 _630 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _632 = abs(_630.x);
        _725 = _632;
      } else {
        float4 _636 = t2.SampleLevel(s2, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _638 = TEXCOORD.x * 2.0f;
        float _639 = TEXCOORD.y * 2.0f;
        float _640 = _638 + -1.0f;
        float _641 = _639 + -1.0f;
        float _662 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _640;
        float _663 = mad(_641, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _662);
        float _664 = mad(_636.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _663);
        float _665 = _664 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _666 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _640;
        float _667 = mad(_641, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _666);
        float _668 = mad(_636.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _667);
        float _669 = _668 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _670 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _640;
        float _671 = mad(_641, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _670);
        float _672 = mad(_636.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _671);
        float _673 = _672 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _674 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _640;
        float _675 = mad(_641, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _674);
        float _676 = mad(_636.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _675);
        float _677 = _676 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
        float _678 = _665 / _677;
        float _679 = _669 / _677;
        float _680 = _673 / _677;
        float _681 = _678 * _678;
        float _682 = _679 * _679;
        float _683 = _682 + _681;
        float _684 = _680 * _680;
        float _685 = _683 + _684;
        float _686 = sqrt(_685);
        float4 _689 = t5.Sample(s5, float2(TEXCOORD.x, TEXCOORD.y));
        float _695 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _696 = _695 + (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _697 = (PostProcess_000.PostProcessConstant_Z_000[5].x) - _695;
        float _698 = max(_686, _697);
        float _699 = min(_698, _696);
        float _701 = _686 - _699;
        float _702 = _701 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
        float _704 = _699 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _705 = _704 * _686;
        float _706 = _702 / _705;
        float _707 = min(_706, 0.0f);
        float _710 = _695 + 1.0f;
        float _711 = 1.0f / _710;
        float _712 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _707;
        float _713 = max(0.0f, _706);
        float _716 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _713;
        float _717 = _716 + _712;
        float _718 = _717 * _711;
        float _719 = min(_689.x, _718);
        float _720 = abs(_719);
        float _721 = abs(_718);
        float _722 = max(_720, _721);
        float _723 = saturate(_722);
        _725 = _723;
      }
      float _728 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _725;
      float4 _731 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _738 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _728;
      float _739 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _728;
      float _740 = _738 + TEXCOORD.x;
      float _741 = _739 + TEXCOORD.y;
      float4 _742 = t4.Sample(s4, float2(_740, _741));
      float4 _746 = t5.Sample(s5, float2(_740, _741));
      float _748 = abs(_746.x);
      float _749 = _742.z - _731.z;
      float _750 = _748 * _749;
      float _751 = _728 + -1.0f;
      float _752 = saturate(_751);
      float _753 = _731.x - _379;
      float _754 = _731.y - _380;
      float _755 = _731.z - _381;
      float _756 = _755 + _750;
      float _757 = _752 * _753;
      float _758 = _752 * _754;
      float _759 = _756 * _752;
      float _760 = _757 + _379;
      float _761 = _758 + _380;
      float _762 = _759 + _381;
      _764 = _760;
      _765 = _761;
      _766 = _762;
    }
  }
  float4 _768 = t12.SampleLevel(s1, float2(_57, _58), 0.0f);
  float4 _774 = t8.Sample(s8, float2(_59, _60));
  bool _780 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
  float _784 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _774.x;
  float _785 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _774.y;
  float _786 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _774.z;
  float _787 = _784 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _788 = _785 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _789 = _786 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  if (!_780) {
    float _791 = _787 * _768.x;
    float _792 = _788 * _768.y;
    float _793 = _789 * _768.z;
    _805 = _791;
    _806 = _792;
    _807 = _793;
  } else {
    float _795 = saturate(_787);
    float _796 = saturate(_788);
    float _797 = saturate(_789);
    float _798 = _768.x - _764;
    float _799 = _768.y - _765;
    float _800 = _768.z - _766;
    float _801 = _795 * _798;
    float _802 = _796 * _799;
    float _803 = _797 * _800;
    _805 = _801;
    _806 = _802;
    _807 = _803;
  }
  float _808 = _805 + _764;
  float _809 = _806 + _765;
  float _810 = _807 + _766;
  float4 _814 = t17.Load(int3(0, 0, 0));
  float _822 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _823 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _824 = _814.x * _823;
  float _825 = _824 * _808;
  float _826 = _825 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _827 = _826 * _822;
  float _828 = _824 * _809;
  float _829 = _828 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _830 = _829 * _822;
  float _831 = _824 * _810;
  float _832 = _831 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _833 = _832 * _822;
  float _834 = _827 + 1.0f;
  float _835 = _830 + 1.0f;
  float _836 = _833 + 1.0f;
  float _837 = log2(_834);
  float _838 = log2(_835);
  float _839 = log2(_836);
  float _842 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _843 = _842 * _837;
  float _844 = _842 * _838;
  float _845 = _842 * _839;
  float _847 = _843 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _848 = _844 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _849 = _845 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _852 = t3.Sample(s3, float3(_847, _848, _849));
  float _858 = _852.x * 13.450128555297852f;
  float _859 = _852.y * 13.450128555297852f;
  float _860 = _852.z * 13.450128555297852f;
  float _861 = exp2(_858);
  float _862 = exp2(_859);
  float _863 = exp2(_860);
  float _864 = _861 + -1.0f;
  float _865 = _862 + -1.0f;
  float _866 = _863 + -1.0f;
  float _867 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _868 = _867 * _864;
  float _869 = _867 * _865;
  float _870 = _867 * _866;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_827 * _867, _830 * _867, _833 * _867),
      float3(_868, _869, _870),
      1.f.xxx);
  _868 = apt_scaled_lut_output.x;
  _869 = apt_scaled_lut_output.y;
  _870 = apt_scaled_lut_output.z;
  bool _873 = ((User_000.UserConstant_Z_000[3].x) > 0.0f);
  if (_873) {
    float _875 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _876 = _868 * _875;
    float _877 = _869 * _875;
    float _878 = _870 * _875;
    float _879 = _876 + 1.0f;
    float _880 = _877 + 1.0f;
    float _881 = _878 + 1.0f;
    float _882 = log2(_879);
    float _883 = log2(_880);
    float _884 = log2(_881);
    float _885 = _882 * 0.07434873282909393f;
    float _886 = _883 * 0.07434873282909393f;
    float _887 = _884 * 0.07434873282909393f;
    int _889 = asint((User_000.UserConstant_Z_000[3].y));
    int _890 = _889 & 1;
    bool _891 = (_890 == 0);
    if (!_891) {
      bool _908 = !(_885 <= (User_000.UserConstant_Z_000[4].x));
      if (!_908) {
        float _910 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _911 = _885 / _910;
        float _912 = _911 * (User_000.UserConstant_Z_000[4].y);
        float _913 = _911 * _911;
        float _914 = _913 * _911;
        float _915 = _914 - _911;
        float _916 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _917 = _910 * _910;
        float _918 = _917 * _916;
        float _919 = _918 * _915;
        float _920 = _919 + _912;
        _1010 = _920;
      } else {
        bool _922 = !(_885 <= (User_000.UserConstant_Z_000[4].z));
        if (!_922) {
          float _924 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _925 = max(9.999999974752427e-07f, _924);
          float _926 = _885 - (User_000.UserConstant_Z_000[4].x);
          float _927 = _926 / _925;
          float _928 = 1.0f - _927;
          float _929 = _928 * (User_000.UserConstant_Z_000[4].y);
          float _930 = _927 * (User_000.UserConstant_Z_000[4].w);
          float _931 = _929 + _930;
          float _932 = _928 * _928;
          float _933 = _932 * _928;
          float _934 = _933 - _928;
          float _935 = _934 * (User_000.UserConstant_Z_000[10].x);
          float _936 = _927 * _927;
          float _937 = _936 * _927;
          float _938 = _937 - _927;
          float _939 = _938 * (User_000.UserConstant_Z_000[10].y);
          float _940 = _935 + _939;
          float _941 = _925 * _925;
          float _942 = _941 * 0.1666666716337204f;
          float _943 = _942 * _940;
          float _944 = _931 + _943;
          _1010 = _944;
        } else {
          bool _946 = !(_885 <= (User_000.UserConstant_Z_000[9].x));
          if (!_946) {
            float _948 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _949 = max(9.999999974752427e-07f, _948);
            float _950 = _885 - (User_000.UserConstant_Z_000[4].z);
            float _951 = _950 / _949;
            float _952 = 1.0f - _951;
            float _953 = _952 * (User_000.UserConstant_Z_000[4].w);
            float _954 = _951 * (User_000.UserConstant_Z_000[9].y);
            float _955 = _953 + _954;
            float _956 = _952 * _952;
            float _957 = _956 * _952;
            float _958 = _957 - _952;
            float _959 = _958 * (User_000.UserConstant_Z_000[10].y);
            float _960 = _951 * _951;
            float _961 = _960 * _951;
            float _962 = _961 - _951;
            float _963 = _962 * (User_000.UserConstant_Z_000[10].z);
            float _964 = _959 + _963;
            float _965 = _949 * _949;
            float _966 = _965 * 0.1666666716337204f;
            float _967 = _966 * _964;
            float _968 = _955 + _967;
            _1010 = _968;
          } else {
            bool _970 = !(_885 <= (User_000.UserConstant_Z_000[9].z));
            if (!_970) {
              float _972 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _973 = max(9.999999974752427e-07f, _972);
              float _974 = _885 - (User_000.UserConstant_Z_000[9].x);
              float _975 = _974 / _973;
              float _976 = 1.0f - _975;
              float _977 = _976 * (User_000.UserConstant_Z_000[9].y);
              float _978 = _975 * (User_000.UserConstant_Z_000[9].w);
              float _979 = _977 + _978;
              float _980 = _976 * _976;
              float _981 = _980 * _976;
              float _982 = _981 - _976;
              float _983 = _982 * (User_000.UserConstant_Z_000[10].z);
              float _984 = _975 * _975;
              float _985 = _984 * _975;
              float _986 = _985 - _975;
              float _987 = _986 * (User_000.UserConstant_Z_000[10].w);
              float _988 = _983 + _987;
              float _989 = _973 * _973;
              float _990 = _989 * 0.1666666716337204f;
              float _991 = _990 * _988;
              float _992 = _979 + _991;
              _1010 = _992;
            } else {
              float _994 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _995 = _885 - (User_000.UserConstant_Z_000[9].z);
              float _996 = max(9.999999974752427e-07f, _994);
              float _997 = _995 / _996;
              float _998 = 1.0f - _997;
              float _999 = _998 * (User_000.UserConstant_Z_000[9].w);
              float _1000 = _999 + _997;
              float _1001 = _998 * _998;
              float _1002 = _1001 * _998;
              float _1003 = _1002 - _998;
              float _1004 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1005 = _994 * _994;
              float _1006 = _1005 * _1004;
              float _1007 = _1006 * _1003;
              float _1008 = _1000 + _1007;
              _1010 = _1008;
            }
          }
        }
      }
      float _1011 = saturate(_1010);
      bool _1012 = !(_886 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1012) {
        float _1014 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1015 = _886 / _1014;
        float _1016 = _1015 * (User_000.UserConstant_Z_000[4].y);
        float _1017 = _1015 * _1015;
        float _1018 = _1017 * _1015;
        float _1019 = _1018 - _1015;
        float _1020 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1021 = _1014 * _1014;
        float _1022 = _1021 * _1020;
        float _1023 = _1022 * _1019;
        float _1024 = _1023 + _1016;
        _1114 = _1024;
      } else {
        bool _1026 = !(_886 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1026) {
          float _1028 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1029 = max(9.999999974752427e-07f, _1028);
          float _1030 = _886 - (User_000.UserConstant_Z_000[4].x);
          float _1031 = _1030 / _1029;
          float _1032 = 1.0f - _1031;
          float _1033 = _1032 * (User_000.UserConstant_Z_000[4].y);
          float _1034 = _1031 * (User_000.UserConstant_Z_000[4].w);
          float _1035 = _1033 + _1034;
          float _1036 = _1032 * _1032;
          float _1037 = _1036 * _1032;
          float _1038 = _1037 - _1032;
          float _1039 = _1038 * (User_000.UserConstant_Z_000[10].x);
          float _1040 = _1031 * _1031;
          float _1041 = _1040 * _1031;
          float _1042 = _1041 - _1031;
          float _1043 = _1042 * (User_000.UserConstant_Z_000[10].y);
          float _1044 = _1039 + _1043;
          float _1045 = _1029 * _1029;
          float _1046 = _1045 * 0.1666666716337204f;
          float _1047 = _1046 * _1044;
          float _1048 = _1035 + _1047;
          _1114 = _1048;
        } else {
          bool _1050 = !(_886 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1050) {
            float _1052 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1053 = max(9.999999974752427e-07f, _1052);
            float _1054 = _886 - (User_000.UserConstant_Z_000[4].z);
            float _1055 = _1054 / _1053;
            float _1056 = 1.0f - _1055;
            float _1057 = _1056 * (User_000.UserConstant_Z_000[4].w);
            float _1058 = _1055 * (User_000.UserConstant_Z_000[9].y);
            float _1059 = _1057 + _1058;
            float _1060 = _1056 * _1056;
            float _1061 = _1060 * _1056;
            float _1062 = _1061 - _1056;
            float _1063 = _1062 * (User_000.UserConstant_Z_000[10].y);
            float _1064 = _1055 * _1055;
            float _1065 = _1064 * _1055;
            float _1066 = _1065 - _1055;
            float _1067 = _1066 * (User_000.UserConstant_Z_000[10].z);
            float _1068 = _1063 + _1067;
            float _1069 = _1053 * _1053;
            float _1070 = _1069 * 0.1666666716337204f;
            float _1071 = _1070 * _1068;
            float _1072 = _1059 + _1071;
            _1114 = _1072;
          } else {
            bool _1074 = !(_886 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1074) {
              float _1076 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1077 = max(9.999999974752427e-07f, _1076);
              float _1078 = _886 - (User_000.UserConstant_Z_000[9].x);
              float _1079 = _1078 / _1077;
              float _1080 = 1.0f - _1079;
              float _1081 = _1080 * (User_000.UserConstant_Z_000[9].y);
              float _1082 = _1079 * (User_000.UserConstant_Z_000[9].w);
              float _1083 = _1081 + _1082;
              float _1084 = _1080 * _1080;
              float _1085 = _1084 * _1080;
              float _1086 = _1085 - _1080;
              float _1087 = _1086 * (User_000.UserConstant_Z_000[10].z);
              float _1088 = _1079 * _1079;
              float _1089 = _1088 * _1079;
              float _1090 = _1089 - _1079;
              float _1091 = _1090 * (User_000.UserConstant_Z_000[10].w);
              float _1092 = _1087 + _1091;
              float _1093 = _1077 * _1077;
              float _1094 = _1093 * 0.1666666716337204f;
              float _1095 = _1094 * _1092;
              float _1096 = _1083 + _1095;
              _1114 = _1096;
            } else {
              float _1098 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1099 = _886 - (User_000.UserConstant_Z_000[9].z);
              float _1100 = max(9.999999974752427e-07f, _1098);
              float _1101 = _1099 / _1100;
              float _1102 = 1.0f - _1101;
              float _1103 = _1102 * (User_000.UserConstant_Z_000[9].w);
              float _1104 = _1103 + _1101;
              float _1105 = _1102 * _1102;
              float _1106 = _1105 * _1102;
              float _1107 = _1106 - _1102;
              float _1108 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1109 = _1098 * _1098;
              float _1110 = _1109 * _1108;
              float _1111 = _1110 * _1107;
              float _1112 = _1104 + _1111;
              _1114 = _1112;
            }
          }
        }
      }
      float _1115 = saturate(_1114);
      bool _1116 = !(_887 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1116) {
        float _1118 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1119 = _887 / _1118;
        float _1120 = _1119 * (User_000.UserConstant_Z_000[4].y);
        float _1121 = _1119 * _1119;
        float _1122 = _1121 * _1119;
        float _1123 = _1122 - _1119;
        float _1124 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1125 = _1118 * _1118;
        float _1126 = _1125 * _1124;
        float _1127 = _1126 * _1123;
        float _1128 = _1127 + _1120;
        _1218 = _1128;
      } else {
        bool _1130 = !(_887 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1130) {
          float _1132 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1133 = max(9.999999974752427e-07f, _1132);
          float _1134 = _887 - (User_000.UserConstant_Z_000[4].x);
          float _1135 = _1134 / _1133;
          float _1136 = 1.0f - _1135;
          float _1137 = _1136 * (User_000.UserConstant_Z_000[4].y);
          float _1138 = _1135 * (User_000.UserConstant_Z_000[4].w);
          float _1139 = _1137 + _1138;
          float _1140 = _1136 * _1136;
          float _1141 = _1140 * _1136;
          float _1142 = _1141 - _1136;
          float _1143 = _1142 * (User_000.UserConstant_Z_000[10].x);
          float _1144 = _1135 * _1135;
          float _1145 = _1144 * _1135;
          float _1146 = _1145 - _1135;
          float _1147 = _1146 * (User_000.UserConstant_Z_000[10].y);
          float _1148 = _1143 + _1147;
          float _1149 = _1133 * _1133;
          float _1150 = _1149 * 0.1666666716337204f;
          float _1151 = _1150 * _1148;
          float _1152 = _1139 + _1151;
          _1218 = _1152;
        } else {
          bool _1154 = !(_887 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1154) {
            float _1156 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1157 = max(9.999999974752427e-07f, _1156);
            float _1158 = _887 - (User_000.UserConstant_Z_000[4].z);
            float _1159 = _1158 / _1157;
            float _1160 = 1.0f - _1159;
            float _1161 = _1160 * (User_000.UserConstant_Z_000[4].w);
            float _1162 = _1159 * (User_000.UserConstant_Z_000[9].y);
            float _1163 = _1161 + _1162;
            float _1164 = _1160 * _1160;
            float _1165 = _1164 * _1160;
            float _1166 = _1165 - _1160;
            float _1167 = _1166 * (User_000.UserConstant_Z_000[10].y);
            float _1168 = _1159 * _1159;
            float _1169 = _1168 * _1159;
            float _1170 = _1169 - _1159;
            float _1171 = _1170 * (User_000.UserConstant_Z_000[10].z);
            float _1172 = _1167 + _1171;
            float _1173 = _1157 * _1157;
            float _1174 = _1173 * 0.1666666716337204f;
            float _1175 = _1174 * _1172;
            float _1176 = _1163 + _1175;
            _1218 = _1176;
          } else {
            bool _1178 = !(_887 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1178) {
              float _1180 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1181 = max(9.999999974752427e-07f, _1180);
              float _1182 = _887 - (User_000.UserConstant_Z_000[9].x);
              float _1183 = _1182 / _1181;
              float _1184 = 1.0f - _1183;
              float _1185 = _1184 * (User_000.UserConstant_Z_000[9].y);
              float _1186 = _1183 * (User_000.UserConstant_Z_000[9].w);
              float _1187 = _1185 + _1186;
              float _1188 = _1184 * _1184;
              float _1189 = _1188 * _1184;
              float _1190 = _1189 - _1184;
              float _1191 = _1190 * (User_000.UserConstant_Z_000[10].z);
              float _1192 = _1183 * _1183;
              float _1193 = _1192 * _1183;
              float _1194 = _1193 - _1183;
              float _1195 = _1194 * (User_000.UserConstant_Z_000[10].w);
              float _1196 = _1191 + _1195;
              float _1197 = _1181 * _1181;
              float _1198 = _1197 * 0.1666666716337204f;
              float _1199 = _1198 * _1196;
              float _1200 = _1187 + _1199;
              _1218 = _1200;
            } else {
              float _1202 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1203 = _887 - (User_000.UserConstant_Z_000[9].z);
              float _1204 = max(9.999999974752427e-07f, _1202);
              float _1205 = _1203 / _1204;
              float _1206 = 1.0f - _1205;
              float _1207 = _1206 * (User_000.UserConstant_Z_000[9].w);
              float _1208 = _1207 + _1205;
              float _1209 = _1206 * _1206;
              float _1210 = _1209 * _1206;
              float _1211 = _1210 - _1206;
              float _1212 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1213 = _1202 * _1202;
              float _1214 = _1213 * _1212;
              float _1215 = _1214 * _1211;
              float _1216 = _1208 + _1215;
              _1218 = _1216;
            }
          }
        }
      }
      float _1219 = saturate(_1218);
      _1221 = _1011;
      _1222 = _1115;
      _1223 = _1219;
    } else {
      _1221 = _885;
      _1222 = _886;
      _1223 = _887;
    }
    int _1224 = _889 & 2;
    bool _1225 = (_1224 == 0);
    if (!_1225) {
      float _1227 = sqrt(_1221);
      float _1228 = sqrt(_1222);
      float _1229 = sqrt(_1223);
      float _1230 = dot(float3(_1227, _1228, _1229), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1231 = 1.0f - _1230;
      float _1232 = saturate(_1231);
      _1234 = _1232;
    } else {
      _1234 = 1.0f;
    }
    int _1235 = _889 & 8;
    bool _1236 = (_1235 == 0);
    if (_1236) {
      int _1238 = _889 & 4;
      bool _1239 = (_1238 == 0);
      if (!_1239) {
        int _1241 = _889 & 16;
        bool _1242 = (_1241 == 0);
        if (!_1242) {
          float _1246 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1247 = _1246 + 0.5f;
          bool _1248 = (_1247 < 0.5f);
          float _1249 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1250 = select(_1248, (User_000.UserConstant_Z_000[5].x), _1249);
          bool _1251 = (_1222 < _1223);
          float _1252 = select(_1251, _1223, _1222);
          float _1253 = select(_1251, _1222, _1223);
          bool _1254 = (_1221 < _1252);
          float _1255 = select(_1254, _1252, _1221);
          float _1256 = select(_1254, _1221, _1252);
          float _1257 = min(_1256, _1253);
          float _1258 = _1255 - _1257;
          float _1259 = _1255 + 1.000000013351432e-10f;
          float _1260 = _1258 / _1259;
          float _1262 = _1260 - (User_000.UserConstant_Z_000[5].y);
          float _1263 = saturate(_1262);
          float _1264 = max(_1263, 9.999999974752427e-07f);
          float _1265 = log2(_1264);
          float _1266 = _1265 * _1250;
          float _1267 = exp2(_1266);
          float _1268 = 2.0f - _1267;
          float _1270 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1271 = saturate(_1270);
          float _1272 = max(_1271, _1268);
          float _1273 = dot(float3(_1221, _1222, _1223), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1274 = _1221 - _1273;
          float _1275 = _1222 - _1273;
          float _1276 = _1223 - _1273;
          float _1277 = _1274 * _1272;
          float _1278 = _1275 * _1272;
          float _1279 = _1276 * _1272;
          float _1280 = _1273 - _1221;
          float _1281 = _1280 + _1277;
          float _1282 = _1273 - _1222;
          float _1283 = _1282 + _1278;
          float _1284 = _1273 - _1223;
          float _1285 = _1284 + _1279;
          float _1286 = _1281 * _1234;
          float _1287 = _1283 * _1234;
          float _1288 = _1285 * _1234;
          float _1289 = _1286 + _1221;
          float _1290 = _1287 + _1222;
          float _1291 = _1288 + _1223;
          _1408 = _1289;
          _1409 = _1290;
          _1410 = _1291;
        } else {
          bool _1293 = (_1234 == 0.0f);
          if (!_1293) {
            float _1297 = abs(User_000.UserConstant_Z_000[5].x);
            float _1298 = saturate(_1297);
            uint4 _1300 = 0u; t15.GetDimensions(0u, _1300.x, _1300.y, _1300.w);
            float _1303 = float((uint)_1300.y);
            int _1304 = _889 & 32;
            bool _1305 = (_1304 == 0);
            float _1306 = _1303 + -1.0f;
            if (!_1305) {
              float _1308 = 1.0f / _1306;
              uint _1309 = uint(SV_Position.x);
              uint _1310 = uint(SV_Position.y);
              int _1311 = _1309 & 63;
              int _1312 = _1310 & 63;
              float4 _1314 = t6.Load(int4(_1311, _1312, 0, 0));
              float _1317 = _1314.x + -0.5f;
              float _1318 = _1221 * 13.999999046325684f;
              float _1319 = _1222 * 13.999999046325684f;
              float _1320 = _1223 * 13.999999046325684f;
              float _1321 = saturate(_1318);
              float _1322 = saturate(_1319);
              float _1323 = saturate(_1320);
              float _1324 = _1221 + -0.9285714030265808f;
              float _1325 = _1222 + -0.9285714030265808f;
              float _1326 = _1223 + -0.9285714030265808f;
              float _1327 = _1324 * 13.999999046325684f;
              float _1328 = _1325 * 13.999999046325684f;
              float _1329 = _1326 * 13.999999046325684f;
              float _1330 = saturate(_1327);
              float _1331 = saturate(_1328);
              float _1332 = saturate(_1329);
              float _1333 = 1.0f - _1330;
              float _1334 = 1.0f - _1331;
              float _1335 = 1.0f - _1332;
              float _1336 = min(_1321, _1333);
              float _1337 = min(_1322, _1334);
              float _1338 = min(_1323, _1335);
              float _1339 = _1314.y + -0.5f;
              float _1340 = _1336 * _1339;
              float _1341 = _1337 * _1339;
              float _1342 = _1338 * _1339;
              float _1343 = _1340 + _1317;
              float _1344 = _1341 + _1317;
              float _1345 = _1342 + _1317;
              float _1346 = _1343 * _1308;
              float _1347 = _1344 * _1308;
              float _1348 = _1345 * _1308;
              float _1349 = _1346 + _1221;
              float _1350 = _1347 + _1222;
              float _1351 = _1348 + _1223;
              float _1352 = saturate(_1349);
              float _1353 = saturate(_1350);
              float _1354 = saturate(_1351);
              float _1355 = saturate(_1352);
              float _1356 = saturate(_1353);
              float _1357 = saturate(_1354);
              _1359 = _1355;
              _1360 = _1356;
              _1361 = _1357;
            } else {
              _1359 = _1221;
              _1360 = _1222;
              _1361 = _1223;
            }
            float _1362 = float((uint)_1300.x);
            float _1363 = _1306 / _1362;
            float _1364 = _1363 * _1359;
            float _1365 = 0.5f / _1362;
            float _1366 = _1364 + _1365;
            float _1367 = _1306 / _1303;
            float _1368 = _1367 * _1360;
            float _1369 = 0.5f / _1303;
            float _1370 = _1368 + _1369;
            float _1371 = _1361 * _1306;
            float _1372 = floor(_1371);
            float _1373 = frac(_1371);
            float _1374 = _1372 / _1303;
            float _1375 = _1374 + _1366;
            float _1376 = _1372 + 1.0f;
            float _1377 = _1376 / _1303;
            float _1378 = _1377 + _1366;
            float4 _1380 = t15.Sample(s1, float2(_1375, _1370));
            float4 _1384 = t15.Sample(s1, float2(_1378, _1370));
            float _1388 = _1384.x - _1380.x;
            float _1389 = _1384.y - _1380.y;
            float _1390 = _1384.z - _1380.z;
            float _1391 = _1388 * _1373;
            float _1392 = _1389 * _1373;
            float _1393 = _1390 * _1373;
            float _1394 = _1298 * _1234;
            float _1395 = _1380.x - _1221;
            float _1396 = _1395 + _1391;
            float _1397 = _1380.y - _1222;
            float _1398 = _1397 + _1392;
            float _1399 = _1380.z - _1223;
            float _1400 = _1399 + _1393;
            float _1401 = _1396 * _1394;
            float _1402 = _1398 * _1394;
            float _1403 = _1400 * _1394;
            float _1404 = _1401 + _1221;
            float _1405 = _1402 + _1222;
            float _1406 = _1403 + _1223;
            _1408 = _1404;
            _1409 = _1405;
            _1410 = _1406;
          } else {
            _1408 = _1221;
            _1409 = _1222;
            _1410 = _1223;
          }
        }
      } else {
        _1408 = _1221;
        _1409 = _1222;
        _1410 = _1223;
      }
    } else {
      _1408 = _1234;
      _1409 = _1234;
      _1410 = _1234;
    }
    float _1411 = _1408 * 13.450128555297852f;
    float _1412 = _1409 * 13.450128555297852f;
    float _1413 = _1410 * 13.450128555297852f;
    float _1414 = exp2(_1411);
    float _1415 = exp2(_1412);
    float _1416 = exp2(_1413);
    float _1417 = _1414 + -1.0f;
    float _1418 = _1415 + -1.0f;
    float _1419 = _1416 + -1.0f;
    float _1420 = _1417 * _867;
    float _1421 = _1418 * _867;
    float _1422 = _1419 * _867;
    _1424 = _1420;
    _1425 = _1421;
    _1426 = _1422;
  } else {
    _1424 = _868;
    _1425 = _869;
    _1426 = _870;
  }
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1424, (User_000.UserConstant_Z_000[8].y) * _1425, (User_000.UserConstant_Z_000[8].z) * _1426),
      SV_Position.xy);
  float _1433 = apt_perceptual_film_grain.x;
  float _1434 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1435 = log2(_1433);
  float _1436 = _1434 * _1435;
  float _1437 = exp2(_1436);
  float _1438 = _1437 + -1.0f;
  float _1439 = _1433 + -1.0f;
  float _1440 = _1438 / _1439;
  bool _1441 = !(_1433 == 1.0f);
  float _1442 = _1440 + -1.0f;
  float _1443 = _1442 / _1440;
  float _1444 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1445 = _1444 / _1434;
  float _1446 = select(_1441, _1443, _1445);
  float _1447 = apt_perceptual_film_grain.y;
  float _1448 = log2(_1447);
  float _1449 = _1448 * _1434;
  float _1450 = exp2(_1449);
  float _1451 = _1450 + -1.0f;
  float _1452 = _1447 + -1.0f;
  float _1453 = _1451 / _1452;
  bool _1454 = !(_1447 == 1.0f);
  float _1455 = _1453 + -1.0f;
  float _1456 = _1455 / _1453;
  float _1457 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1458 = _1457 / _1434;
  float _1459 = select(_1454, _1456, _1458);
  float _1460 = apt_perceptual_film_grain.z;
  float _1461 = log2(_1460);
  float _1462 = _1461 * _1434;
  float _1463 = exp2(_1462);
  float _1464 = _1463 + -1.0f;
  float _1465 = _1460 + -1.0f;
  float _1466 = _1464 / _1465;
  bool _1467 = !(_1460 == 1.0f);
  float _1468 = _1466 + -1.0f;
  float _1469 = _1468 / _1466;
  float _1470 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1471 = _1470 / _1434;
  float _1472 = select(_1467, _1469, _1471);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1433, _1447, _1460),
      float3(_1446, _1459, _1472),
      true);
  float _1473 = apt_post_process_output.x;
  float _1474 = apt_post_process_output.y;
  float _1475 = apt_post_process_output.z;
  float _1476 = log2(_1473);
  float _1477 = log2(_1474);
  float _1478 = log2(_1475);
  float _1479 = _1476 * 0.4166666567325592f;
  float _1480 = _1477 * 0.4166666567325592f;
  float _1481 = _1478 * 0.4166666567325592f;
  float _1482 = exp2(_1479);
  float _1483 = exp2(_1480);
  float _1484 = exp2(_1481);
  float _1485 = _1482 * 1.0549999475479126f;
  float _1486 = _1483 * 1.0549999475479126f;
  float _1487 = _1484 * 1.0549999475479126f;
  float _1488 = _1485 + -0.054999999701976776f;
  float _1489 = _1486 + -0.054999999701976776f;
  float _1490 = _1487 + -0.054999999701976776f;
  float _1491 = _1473 * 12.920000076293945f;
  float _1492 = _1474 * 12.920000076293945f;
  float _1493 = _1475 * 12.920000076293945f;
  bool _1494 = (_1473 <= 0.0031308000907301903f);
  bool _1495 = (_1474 <= 0.0031308000907301903f);
  bool _1496 = (_1475 <= 0.0031308000907301903f);
  float _1497 = select(_1494, _1491, _1488);
  float _1498 = select(_1495, _1492, _1489);
  float _1499 = select(_1496, _1493, _1490);
  int _1502 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1503 = uint(SV_Position.x);
  uint _1504 = uint(SV_Position.y);
  int _1505 = _1503 & 63;
  int _1506 = _1504 & 63;
  float4 _1508 = t1.Load(int4(_1505, _1506, _1502, 0));
  float _1510 = _1508.x + -0.5f;
  float _1511 = _1510 * 0.003921568859368563f;
  float _1512 = _1511 + _1497;
  float _1513 = _1511 + _1498;
  float _1514 = _1511 + _1499;
  float _1515 = saturate(_1512);
  float _1516 = saturate(_1513);
  float _1517 = saturate(_1514);
  SV_Target.x = _1515;
  SV_Target.y = _1516;
  SV_Target.z = _1517;
  SV_Target.w = _378;
  return SV_Target;
}
