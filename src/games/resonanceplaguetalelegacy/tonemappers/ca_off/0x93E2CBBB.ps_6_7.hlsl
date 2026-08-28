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

#include "../../common.hlsli"

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
  float _731;
  float _770;
  float _771;
  float _772;
  float _811;
  float _812;
  float _813;
  float _1016;
  float _1120;
  float _1224;
  float _1227;
  float _1228;
  float _1229;
  float _1240;
  float _1365;
  float _1366;
  float _1367;
  float _1414;
  float _1415;
  float _1416;
  float _1430;
  float _1431;
  float _1432;
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
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
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
      _770 = _567;
      _771 = _380;
      _772 = _574;
    } else {
      _770 = _379;
      _771 = _380;
      _772 = _381;
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
      _770 = _620;
      _771 = _621;
      _772 = _622;
    } else {
      int _625 = asint((User_000.UserConstant_Z_000[7].x));
      bool _626 = ((int)_625 > (int)0);
      [branch]
      if (_626) {
        float4 _630 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _632 = abs(_630.x);
        _731 = _632;
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
        float4 _691 = t7.Load(int3(0, 0, 0));
        float _696 = _691.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _697 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _696;
        float _700 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * _697;
        float _701 = _700 + _697;
        float _702 = _697 - _700;
        float _703 = max(_686, _702);
        float _704 = min(_703, _701);
        float _707 = _686 - _704;
        float _708 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _707;
        float _710 = _704 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _711 = _710 * _686;
        float _712 = _708 / _711;
        float _713 = min(_712, 0.0f);
        float _716 = _700 + 1.0f;
        float _717 = 1.0f / _716;
        float _718 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _713;
        float _719 = max(0.0f, _712);
        float _722 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _719;
        float _723 = _722 + _718;
        float _724 = _723 * _717;
        float _725 = min(_689.x, _724);
        float _726 = abs(_725);
        float _727 = abs(_724);
        float _728 = max(_726, _727);
        float _729 = saturate(_728);
        _731 = _729;
      }
      float _734 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _731;
      float4 _737 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _744 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _734;
      float _745 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _734;
      float _746 = _744 + TEXCOORD.x;
      float _747 = _745 + TEXCOORD.y;
      float4 _748 = t4.Sample(s4, float2(_746, _747));
      float4 _752 = t5.Sample(s5, float2(_746, _747));
      float _754 = abs(_752.x);
      float _755 = _748.z - _737.z;
      float _756 = _754 * _755;
      float _757 = _734 + -1.0f;
      float _758 = saturate(_757);
      float _759 = _737.x - _379;
      float _760 = _737.y - _380;
      float _761 = _737.z - _381;
      float _762 = _761 + _756;
      float _763 = _758 * _759;
      float _764 = _758 * _760;
      float _765 = _762 * _758;
      float _766 = _763 + _379;
      float _767 = _764 + _380;
      float _768 = _765 + _381;
      _770 = _766;
      _771 = _767;
      _772 = _768;
    }
  }
  float4 _774 = t12.SampleLevel(s1, float2(_57, _58), 0.0f);
  float4 _780 = t8.Sample(s8, float2(_59, _60));
  bool _786 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
  float _790 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _780.x;
  float _791 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _780.y;
  float _792 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _780.z;
  float _793 = _790 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _794 = _791 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _795 = _792 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  if (!_786) {
    float _797 = _793 * _774.x;
    float _798 = _794 * _774.y;
    float _799 = _795 * _774.z;
    _811 = _797;
    _812 = _798;
    _813 = _799;
  } else {
    float _801 = saturate(_793);
    float _802 = saturate(_794);
    float _803 = saturate(_795);
    float _804 = _774.x - _770;
    float _805 = _774.y - _771;
    float _806 = _774.z - _772;
    float _807 = _801 * _804;
    float _808 = _802 * _805;
    float _809 = _803 * _806;
    _811 = _807;
    _812 = _808;
    _813 = _809;
  }
  float _814 = _811 + _770;
  float _815 = _812 + _771;
  float _816 = _813 + _772;
  float4 _820 = t17.Load(int3(0, 0, 0));
  float _828 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _829 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _830 = _820.x * _829;
  float _831 = _830 * _814;
  float _832 = _831 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _833 = _832 * _828;
  float _834 = _830 * _815;
  float _835 = _834 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _836 = _835 * _828;
  float _837 = _830 * _816;
  float _838 = _837 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _839 = _838 * _828;
  float _840 = _833 + 1.0f;
  float _841 = _836 + 1.0f;
  float _842 = _839 + 1.0f;
  float _843 = log2(_840);
  float _844 = log2(_841);
  float _845 = log2(_842);
  float _848 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _849 = _848 * _843;
  float _850 = _848 * _844;
  float _851 = _848 * _845;
  float _853 = _849 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _854 = _850 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _855 = _851 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _858 = t3.Sample(s3, float3(_853, _854, _855));
  float _864 = _858.x * 13.450128555297852f;
  float _865 = _858.y * 13.450128555297852f;
  float _866 = _858.z * 13.450128555297852f;
  float _867 = exp2(_864);
  float _868 = exp2(_865);
  float _869 = exp2(_866);
  float _870 = _867 + -1.0f;
  float _871 = _868 + -1.0f;
  float _872 = _869 + -1.0f;
  float _873 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _874 = _873 * _870;
  float _875 = _873 * _871;
  float _876 = _873 * _872;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_833 * _873, _836 * _873, _839 * _873),
      float3(_874, _875, _876),
      1.f.xxx);
  _874 = resonance_scaled_lut_output.x;
  _875 = resonance_scaled_lut_output.y;
  _876 = resonance_scaled_lut_output.z;
  bool _879 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_879) {
    float _881 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _882 = _874 * _881;
    float _883 = _875 * _881;
    float _884 = _876 * _881;
    float _885 = _882 + 1.0f;
    float _886 = _883 + 1.0f;
    float _887 = _884 + 1.0f;
    float _888 = log2(_885);
    float _889 = log2(_886);
    float _890 = log2(_887);
    float _891 = _888 * 0.07434873282909393f;
    float _892 = _889 * 0.07434873282909393f;
    float _893 = _890 * 0.07434873282909393f;
    int _895 = asint((User_000.UserConstant_Z_000[3].y));
    int _896 = _895 & 1;
    bool _897 = (_896 == 0);
    if (!_897) {
      bool _914 = !(_891 <= (User_000.UserConstant_Z_000[4].x));
      if (!_914) {
        float _916 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _917 = _891 / _916;
        float _918 = _917 * (User_000.UserConstant_Z_000[4].y);
        float _919 = _917 * _917;
        float _920 = _919 * _917;
        float _921 = _920 - _917;
        float _922 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _923 = _916 * _916;
        float _924 = _923 * _922;
        float _925 = _924 * _921;
        float _926 = _925 + _918;
        _1016 = _926;
      } else {
        bool _928 = !(_891 <= (User_000.UserConstant_Z_000[4].z));
        if (!_928) {
          float _930 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _931 = max(9.999999974752427e-07f, _930);
          float _932 = _891 - (User_000.UserConstant_Z_000[4].x);
          float _933 = _932 / _931;
          float _934 = 1.0f - _933;
          float _935 = _934 * (User_000.UserConstant_Z_000[4].y);
          float _936 = _933 * (User_000.UserConstant_Z_000[4].w);
          float _937 = _935 + _936;
          float _938 = _934 * _934;
          float _939 = _938 * _934;
          float _940 = _939 - _934;
          float _941 = _940 * (User_000.UserConstant_Z_000[10].x);
          float _942 = _933 * _933;
          float _943 = _942 * _933;
          float _944 = _943 - _933;
          float _945 = _944 * (User_000.UserConstant_Z_000[10].y);
          float _946 = _941 + _945;
          float _947 = _931 * _931;
          float _948 = _947 * 0.1666666716337204f;
          float _949 = _948 * _946;
          float _950 = _937 + _949;
          _1016 = _950;
        } else {
          bool _952 = !(_891 <= (User_000.UserConstant_Z_000[9].x));
          if (!_952) {
            float _954 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _955 = max(9.999999974752427e-07f, _954);
            float _956 = _891 - (User_000.UserConstant_Z_000[4].z);
            float _957 = _956 / _955;
            float _958 = 1.0f - _957;
            float _959 = _958 * (User_000.UserConstant_Z_000[4].w);
            float _960 = _957 * (User_000.UserConstant_Z_000[9].y);
            float _961 = _959 + _960;
            float _962 = _958 * _958;
            float _963 = _962 * _958;
            float _964 = _963 - _958;
            float _965 = _964 * (User_000.UserConstant_Z_000[10].y);
            float _966 = _957 * _957;
            float _967 = _966 * _957;
            float _968 = _967 - _957;
            float _969 = _968 * (User_000.UserConstant_Z_000[10].z);
            float _970 = _965 + _969;
            float _971 = _955 * _955;
            float _972 = _971 * 0.1666666716337204f;
            float _973 = _972 * _970;
            float _974 = _961 + _973;
            _1016 = _974;
          } else {
            bool _976 = !(_891 <= (User_000.UserConstant_Z_000[9].z));
            if (!_976) {
              float _978 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _979 = max(9.999999974752427e-07f, _978);
              float _980 = _891 - (User_000.UserConstant_Z_000[9].x);
              float _981 = _980 / _979;
              float _982 = 1.0f - _981;
              float _983 = _982 * (User_000.UserConstant_Z_000[9].y);
              float _984 = _981 * (User_000.UserConstant_Z_000[9].w);
              float _985 = _983 + _984;
              float _986 = _982 * _982;
              float _987 = _986 * _982;
              float _988 = _987 - _982;
              float _989 = _988 * (User_000.UserConstant_Z_000[10].z);
              float _990 = _981 * _981;
              float _991 = _990 * _981;
              float _992 = _991 - _981;
              float _993 = _992 * (User_000.UserConstant_Z_000[10].w);
              float _994 = _989 + _993;
              float _995 = _979 * _979;
              float _996 = _995 * 0.1666666716337204f;
              float _997 = _996 * _994;
              float _998 = _985 + _997;
              _1016 = _998;
            } else {
              float _1000 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1001 = _891 - (User_000.UserConstant_Z_000[9].z);
              float _1002 = max(9.999999974752427e-07f, _1000);
              float _1003 = _1001 / _1002;
              float _1004 = 1.0f - _1003;
              float _1005 = _1004 * (User_000.UserConstant_Z_000[9].w);
              float _1006 = _1005 + _1003;
              float _1007 = _1004 * _1004;
              float _1008 = _1007 * _1004;
              float _1009 = _1008 - _1004;
              float _1010 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1011 = _1000 * _1000;
              float _1012 = _1011 * _1010;
              float _1013 = _1012 * _1009;
              float _1014 = _1006 + _1013;
              _1016 = _1014;
            }
          }
        }
      }
      float _1017 = saturate(_1016);
      bool _1018 = !(_892 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1018) {
        float _1020 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1021 = _892 / _1020;
        float _1022 = _1021 * (User_000.UserConstant_Z_000[4].y);
        float _1023 = _1021 * _1021;
        float _1024 = _1023 * _1021;
        float _1025 = _1024 - _1021;
        float _1026 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1027 = _1020 * _1020;
        float _1028 = _1027 * _1026;
        float _1029 = _1028 * _1025;
        float _1030 = _1029 + _1022;
        _1120 = _1030;
      } else {
        bool _1032 = !(_892 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1032) {
          float _1034 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1035 = max(9.999999974752427e-07f, _1034);
          float _1036 = _892 - (User_000.UserConstant_Z_000[4].x);
          float _1037 = _1036 / _1035;
          float _1038 = 1.0f - _1037;
          float _1039 = _1038 * (User_000.UserConstant_Z_000[4].y);
          float _1040 = _1037 * (User_000.UserConstant_Z_000[4].w);
          float _1041 = _1039 + _1040;
          float _1042 = _1038 * _1038;
          float _1043 = _1042 * _1038;
          float _1044 = _1043 - _1038;
          float _1045 = _1044 * (User_000.UserConstant_Z_000[10].x);
          float _1046 = _1037 * _1037;
          float _1047 = _1046 * _1037;
          float _1048 = _1047 - _1037;
          float _1049 = _1048 * (User_000.UserConstant_Z_000[10].y);
          float _1050 = _1045 + _1049;
          float _1051 = _1035 * _1035;
          float _1052 = _1051 * 0.1666666716337204f;
          float _1053 = _1052 * _1050;
          float _1054 = _1041 + _1053;
          _1120 = _1054;
        } else {
          bool _1056 = !(_892 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1056) {
            float _1058 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1059 = max(9.999999974752427e-07f, _1058);
            float _1060 = _892 - (User_000.UserConstant_Z_000[4].z);
            float _1061 = _1060 / _1059;
            float _1062 = 1.0f - _1061;
            float _1063 = _1062 * (User_000.UserConstant_Z_000[4].w);
            float _1064 = _1061 * (User_000.UserConstant_Z_000[9].y);
            float _1065 = _1063 + _1064;
            float _1066 = _1062 * _1062;
            float _1067 = _1066 * _1062;
            float _1068 = _1067 - _1062;
            float _1069 = _1068 * (User_000.UserConstant_Z_000[10].y);
            float _1070 = _1061 * _1061;
            float _1071 = _1070 * _1061;
            float _1072 = _1071 - _1061;
            float _1073 = _1072 * (User_000.UserConstant_Z_000[10].z);
            float _1074 = _1069 + _1073;
            float _1075 = _1059 * _1059;
            float _1076 = _1075 * 0.1666666716337204f;
            float _1077 = _1076 * _1074;
            float _1078 = _1065 + _1077;
            _1120 = _1078;
          } else {
            bool _1080 = !(_892 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1080) {
              float _1082 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1083 = max(9.999999974752427e-07f, _1082);
              float _1084 = _892 - (User_000.UserConstant_Z_000[9].x);
              float _1085 = _1084 / _1083;
              float _1086 = 1.0f - _1085;
              float _1087 = _1086 * (User_000.UserConstant_Z_000[9].y);
              float _1088 = _1085 * (User_000.UserConstant_Z_000[9].w);
              float _1089 = _1087 + _1088;
              float _1090 = _1086 * _1086;
              float _1091 = _1090 * _1086;
              float _1092 = _1091 - _1086;
              float _1093 = _1092 * (User_000.UserConstant_Z_000[10].z);
              float _1094 = _1085 * _1085;
              float _1095 = _1094 * _1085;
              float _1096 = _1095 - _1085;
              float _1097 = _1096 * (User_000.UserConstant_Z_000[10].w);
              float _1098 = _1093 + _1097;
              float _1099 = _1083 * _1083;
              float _1100 = _1099 * 0.1666666716337204f;
              float _1101 = _1100 * _1098;
              float _1102 = _1089 + _1101;
              _1120 = _1102;
            } else {
              float _1104 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1105 = _892 - (User_000.UserConstant_Z_000[9].z);
              float _1106 = max(9.999999974752427e-07f, _1104);
              float _1107 = _1105 / _1106;
              float _1108 = 1.0f - _1107;
              float _1109 = _1108 * (User_000.UserConstant_Z_000[9].w);
              float _1110 = _1109 + _1107;
              float _1111 = _1108 * _1108;
              float _1112 = _1111 * _1108;
              float _1113 = _1112 - _1108;
              float _1114 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1115 = _1104 * _1104;
              float _1116 = _1115 * _1114;
              float _1117 = _1116 * _1113;
              float _1118 = _1110 + _1117;
              _1120 = _1118;
            }
          }
        }
      }
      float _1121 = saturate(_1120);
      bool _1122 = !(_893 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1122) {
        float _1124 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1125 = _893 / _1124;
        float _1126 = _1125 * (User_000.UserConstant_Z_000[4].y);
        float _1127 = _1125 * _1125;
        float _1128 = _1127 * _1125;
        float _1129 = _1128 - _1125;
        float _1130 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1131 = _1124 * _1124;
        float _1132 = _1131 * _1130;
        float _1133 = _1132 * _1129;
        float _1134 = _1133 + _1126;
        _1224 = _1134;
      } else {
        bool _1136 = !(_893 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1136) {
          float _1138 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1139 = max(9.999999974752427e-07f, _1138);
          float _1140 = _893 - (User_000.UserConstant_Z_000[4].x);
          float _1141 = _1140 / _1139;
          float _1142 = 1.0f - _1141;
          float _1143 = _1142 * (User_000.UserConstant_Z_000[4].y);
          float _1144 = _1141 * (User_000.UserConstant_Z_000[4].w);
          float _1145 = _1143 + _1144;
          float _1146 = _1142 * _1142;
          float _1147 = _1146 * _1142;
          float _1148 = _1147 - _1142;
          float _1149 = _1148 * (User_000.UserConstant_Z_000[10].x);
          float _1150 = _1141 * _1141;
          float _1151 = _1150 * _1141;
          float _1152 = _1151 - _1141;
          float _1153 = _1152 * (User_000.UserConstant_Z_000[10].y);
          float _1154 = _1149 + _1153;
          float _1155 = _1139 * _1139;
          float _1156 = _1155 * 0.1666666716337204f;
          float _1157 = _1156 * _1154;
          float _1158 = _1145 + _1157;
          _1224 = _1158;
        } else {
          bool _1160 = !(_893 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1160) {
            float _1162 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1163 = max(9.999999974752427e-07f, _1162);
            float _1164 = _893 - (User_000.UserConstant_Z_000[4].z);
            float _1165 = _1164 / _1163;
            float _1166 = 1.0f - _1165;
            float _1167 = _1166 * (User_000.UserConstant_Z_000[4].w);
            float _1168 = _1165 * (User_000.UserConstant_Z_000[9].y);
            float _1169 = _1167 + _1168;
            float _1170 = _1166 * _1166;
            float _1171 = _1170 * _1166;
            float _1172 = _1171 - _1166;
            float _1173 = _1172 * (User_000.UserConstant_Z_000[10].y);
            float _1174 = _1165 * _1165;
            float _1175 = _1174 * _1165;
            float _1176 = _1175 - _1165;
            float _1177 = _1176 * (User_000.UserConstant_Z_000[10].z);
            float _1178 = _1173 + _1177;
            float _1179 = _1163 * _1163;
            float _1180 = _1179 * 0.1666666716337204f;
            float _1181 = _1180 * _1178;
            float _1182 = _1169 + _1181;
            _1224 = _1182;
          } else {
            bool _1184 = !(_893 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1184) {
              float _1186 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1187 = max(9.999999974752427e-07f, _1186);
              float _1188 = _893 - (User_000.UserConstant_Z_000[9].x);
              float _1189 = _1188 / _1187;
              float _1190 = 1.0f - _1189;
              float _1191 = _1190 * (User_000.UserConstant_Z_000[9].y);
              float _1192 = _1189 * (User_000.UserConstant_Z_000[9].w);
              float _1193 = _1191 + _1192;
              float _1194 = _1190 * _1190;
              float _1195 = _1194 * _1190;
              float _1196 = _1195 - _1190;
              float _1197 = _1196 * (User_000.UserConstant_Z_000[10].z);
              float _1198 = _1189 * _1189;
              float _1199 = _1198 * _1189;
              float _1200 = _1199 - _1189;
              float _1201 = _1200 * (User_000.UserConstant_Z_000[10].w);
              float _1202 = _1197 + _1201;
              float _1203 = _1187 * _1187;
              float _1204 = _1203 * 0.1666666716337204f;
              float _1205 = _1204 * _1202;
              float _1206 = _1193 + _1205;
              _1224 = _1206;
            } else {
              float _1208 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1209 = _893 - (User_000.UserConstant_Z_000[9].z);
              float _1210 = max(9.999999974752427e-07f, _1208);
              float _1211 = _1209 / _1210;
              float _1212 = 1.0f - _1211;
              float _1213 = _1212 * (User_000.UserConstant_Z_000[9].w);
              float _1214 = _1213 + _1211;
              float _1215 = _1212 * _1212;
              float _1216 = _1215 * _1212;
              float _1217 = _1216 - _1212;
              float _1218 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1219 = _1208 * _1208;
              float _1220 = _1219 * _1218;
              float _1221 = _1220 * _1217;
              float _1222 = _1214 + _1221;
              _1224 = _1222;
            }
          }
        }
      }
      float _1225 = saturate(_1224);
      _1227 = _1017;
      _1228 = _1121;
      _1229 = _1225;
    } else {
      _1227 = _891;
      _1228 = _892;
      _1229 = _893;
    }
    int _1230 = _895 & 2;
    bool _1231 = (_1230 == 0);
    if (!_1231) {
      float _1233 = sqrt(_1227);
      float _1234 = sqrt(_1228);
      float _1235 = sqrt(_1229);
      float _1236 = dot(float3(_1233, _1234, _1235), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1237 = 1.0f - _1236;
      float _1238 = saturate(_1237);
      _1240 = _1238;
    } else {
      _1240 = 1.0f;
    }
    int _1241 = _895 & 8;
    bool _1242 = (_1241 == 0);
    if (_1242) {
      int _1244 = _895 & 4;
      bool _1245 = (_1244 == 0);
      if (!_1245) {
        int _1247 = _895 & 16;
        bool _1248 = (_1247 == 0);
        if (!_1248) {
          float _1252 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1253 = _1252 + 0.5f;
          bool _1254 = (_1253 < 0.5f);
          float _1255 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1256 = select(_1254, (User_000.UserConstant_Z_000[5].x), _1255);
          bool _1257 = (_1228 < _1229);
          float _1258 = select(_1257, _1229, _1228);
          float _1259 = select(_1257, _1228, _1229);
          bool _1260 = (_1227 < _1258);
          float _1261 = select(_1260, _1258, _1227);
          float _1262 = select(_1260, _1227, _1258);
          float _1263 = min(_1262, _1259);
          float _1264 = _1261 - _1263;
          float _1265 = _1261 + 1.000000013351432e-10f;
          float _1266 = _1264 / _1265;
          float _1268 = _1266 - (User_000.UserConstant_Z_000[5].y);
          float _1269 = saturate(_1268);
          float _1270 = max(_1269, 9.999999974752427e-07f);
          float _1271 = log2(_1270);
          float _1272 = _1271 * _1256;
          float _1273 = exp2(_1272);
          float _1274 = 2.0f - _1273;
          float _1276 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1277 = saturate(_1276);
          float _1278 = max(_1277, _1274);
          float _1279 = dot(float3(_1227, _1228, _1229), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1280 = _1227 - _1279;
          float _1281 = _1228 - _1279;
          float _1282 = _1229 - _1279;
          float _1283 = _1280 * _1278;
          float _1284 = _1281 * _1278;
          float _1285 = _1282 * _1278;
          float _1286 = _1279 - _1227;
          float _1287 = _1286 + _1283;
          float _1288 = _1279 - _1228;
          float _1289 = _1288 + _1284;
          float _1290 = _1279 - _1229;
          float _1291 = _1290 + _1285;
          float _1292 = _1287 * _1240;
          float _1293 = _1289 * _1240;
          float _1294 = _1291 * _1240;
          float _1295 = _1292 + _1227;
          float _1296 = _1293 + _1228;
          float _1297 = _1294 + _1229;
          _1414 = _1295;
          _1415 = _1296;
          _1416 = _1297;
        } else {
          bool _1299 = (_1240 == 0.0f);
          if (!_1299) {
            float _1303 = abs(User_000.UserConstant_Z_000[5].x);
            float _1304 = saturate(_1303);
            uint4 _1306 = 0u; t15.GetDimensions(0u, _1306.x, _1306.y, _1306.w);
            float _1309 = float((uint)_1306.y);
            int _1310 = _895 & 32;
            bool _1311 = (_1310 == 0);
            float _1312 = _1309 + -1.0f;
            if (!_1311) {
              float _1314 = 1.0f / _1312;
              uint _1315 = uint(SV_Position.x);
              uint _1316 = uint(SV_Position.y);
              int _1317 = _1315 & 63;
              int _1318 = _1316 & 63;
              float4 _1320 = t6.Load(int4(_1317, _1318, 0, 0));
              float _1323 = _1320.x + -0.5f;
              float _1324 = _1227 * 13.999999046325684f;
              float _1325 = _1228 * 13.999999046325684f;
              float _1326 = _1229 * 13.999999046325684f;
              float _1327 = saturate(_1324);
              float _1328 = saturate(_1325);
              float _1329 = saturate(_1326);
              float _1330 = _1227 + -0.9285714030265808f;
              float _1331 = _1228 + -0.9285714030265808f;
              float _1332 = _1229 + -0.9285714030265808f;
              float _1333 = _1330 * 13.999999046325684f;
              float _1334 = _1331 * 13.999999046325684f;
              float _1335 = _1332 * 13.999999046325684f;
              float _1336 = saturate(_1333);
              float _1337 = saturate(_1334);
              float _1338 = saturate(_1335);
              float _1339 = 1.0f - _1336;
              float _1340 = 1.0f - _1337;
              float _1341 = 1.0f - _1338;
              float _1342 = min(_1327, _1339);
              float _1343 = min(_1328, _1340);
              float _1344 = min(_1329, _1341);
              float _1345 = _1320.y + -0.5f;
              float _1346 = _1342 * _1345;
              float _1347 = _1343 * _1345;
              float _1348 = _1344 * _1345;
              float _1349 = _1346 + _1323;
              float _1350 = _1347 + _1323;
              float _1351 = _1348 + _1323;
              float _1352 = _1349 * _1314;
              float _1353 = _1350 * _1314;
              float _1354 = _1351 * _1314;
              float _1355 = _1352 + _1227;
              float _1356 = _1353 + _1228;
              float _1357 = _1354 + _1229;
              float _1358 = saturate(_1355);
              float _1359 = saturate(_1356);
              float _1360 = saturate(_1357);
              float _1361 = saturate(_1358);
              float _1362 = saturate(_1359);
              float _1363 = saturate(_1360);
              _1365 = _1361;
              _1366 = _1362;
              _1367 = _1363;
            } else {
              _1365 = _1227;
              _1366 = _1228;
              _1367 = _1229;
            }
            float _1368 = float((uint)_1306.x);
            float _1369 = _1312 / _1368;
            float _1370 = _1369 * _1365;
            float _1371 = 0.5f / _1368;
            float _1372 = _1370 + _1371;
            float _1373 = _1312 / _1309;
            float _1374 = _1373 * _1366;
            float _1375 = 0.5f / _1309;
            float _1376 = _1374 + _1375;
            float _1377 = _1367 * _1312;
            float _1378 = floor(_1377);
            float _1379 = frac(_1377);
            float _1380 = _1378 / _1309;
            float _1381 = _1380 + _1372;
            float _1382 = _1378 + 1.0f;
            float _1383 = _1382 / _1309;
            float _1384 = _1383 + _1372;
            float4 _1386 = t15.Sample(s1, float2(_1381, _1376));
            float4 _1390 = t15.Sample(s1, float2(_1384, _1376));
            float _1394 = _1390.x - _1386.x;
            float _1395 = _1390.y - _1386.y;
            float _1396 = _1390.z - _1386.z;
            float _1397 = _1394 * _1379;
            float _1398 = _1395 * _1379;
            float _1399 = _1396 * _1379;
            float _1400 = _1304 * _1240;
            float _1401 = _1386.x - _1227;
            float _1402 = _1401 + _1397;
            float _1403 = _1386.y - _1228;
            float _1404 = _1403 + _1398;
            float _1405 = _1386.z - _1229;
            float _1406 = _1405 + _1399;
            float _1407 = _1402 * _1400;
            float _1408 = _1404 * _1400;
            float _1409 = _1406 * _1400;
            float _1410 = _1407 + _1227;
            float _1411 = _1408 + _1228;
            float _1412 = _1409 + _1229;
            _1414 = _1410;
            _1415 = _1411;
            _1416 = _1412;
          } else {
            _1414 = _1227;
            _1415 = _1228;
            _1416 = _1229;
          }
        }
      } else {
        _1414 = _1227;
        _1415 = _1228;
        _1416 = _1229;
      }
    } else {
      _1414 = _1240;
      _1415 = _1240;
      _1416 = _1240;
    }
    float _1417 = _1414 * 13.450128555297852f;
    float _1418 = _1415 * 13.450128555297852f;
    float _1419 = _1416 * 13.450128555297852f;
    float _1420 = exp2(_1417);
    float _1421 = exp2(_1418);
    float _1422 = exp2(_1419);
    float _1423 = _1420 + -1.0f;
    float _1424 = _1421 + -1.0f;
    float _1425 = _1422 + -1.0f;
    float _1426 = _1423 * _873;
    float _1427 = _1424 * _873;
    float _1428 = _1425 * _873;
    _1430 = _1426;
    _1431 = _1427;
    _1432 = _1428;
  } else {
    _1430 = _874;
    _1431 = _875;
    _1432 = _876;
  }
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1430, (User_000.UserConstant_Z_000[8].y) * _1431, (User_000.UserConstant_Z_000[8].z) * _1432),
      SV_Position.xy);
  float _1439 = resonance_perceptual_film_grain.x;
  float _1440 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1441 = log2(_1439);
  float _1442 = _1440 * _1441;
  float _1443 = exp2(_1442);
  float _1444 = _1443 + -1.0f;
  float _1445 = _1439 + -1.0f;
  float _1446 = _1444 / _1445;
  bool _1447 = !(_1439 == 1.0f);
  float _1448 = _1446 + -1.0f;
  float _1449 = _1448 / _1446;
  float _1450 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1451 = _1450 / _1440;
  float _1452 = select(_1447, _1449, _1451);
  float _1453 = resonance_perceptual_film_grain.y;
  float _1454 = log2(_1453);
  float _1455 = _1454 * _1440;
  float _1456 = exp2(_1455);
  float _1457 = _1456 + -1.0f;
  float _1458 = _1453 + -1.0f;
  float _1459 = _1457 / _1458;
  bool _1460 = !(_1453 == 1.0f);
  float _1461 = _1459 + -1.0f;
  float _1462 = _1461 / _1459;
  float _1463 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1464 = _1463 / _1440;
  float _1465 = select(_1460, _1462, _1464);
  float _1466 = resonance_perceptual_film_grain.z;
  float _1467 = log2(_1466);
  float _1468 = _1467 * _1440;
  float _1469 = exp2(_1468);
  float _1470 = _1469 + -1.0f;
  float _1471 = _1466 + -1.0f;
  float _1472 = _1470 / _1471;
  bool _1473 = !(_1466 == 1.0f);
  float _1474 = _1472 + -1.0f;
  float _1475 = _1474 / _1472;
  float _1476 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1477 = _1476 / _1440;
  float _1478 = select(_1473, _1475, _1477);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1439, _1453, _1466),
      float3(_1452, _1465, _1478),
      true);
  float _1479 = resonance_post_process_output.x;
  float _1480 = resonance_post_process_output.y;
  float _1481 = resonance_post_process_output.z;
  float _1482 = log2(_1479);
  float _1483 = log2(_1480);
  float _1484 = log2(_1481);
  float _1485 = _1482 * 0.4166666567325592f;
  float _1486 = _1483 * 0.4166666567325592f;
  float _1487 = _1484 * 0.4166666567325592f;
  float _1488 = exp2(_1485);
  float _1489 = exp2(_1486);
  float _1490 = exp2(_1487);
  float _1491 = _1488 * 1.0549999475479126f;
  float _1492 = _1489 * 1.0549999475479126f;
  float _1493 = _1490 * 1.0549999475479126f;
  float _1494 = _1491 + -0.054999999701976776f;
  float _1495 = _1492 + -0.054999999701976776f;
  float _1496 = _1493 + -0.054999999701976776f;
  float _1497 = _1479 * 12.920000076293945f;
  float _1498 = _1480 * 12.920000076293945f;
  float _1499 = _1481 * 12.920000076293945f;
  bool _1500 = (_1479 <= 0.0031308000907301903f);
  bool _1501 = (_1480 <= 0.0031308000907301903f);
  bool _1502 = (_1481 <= 0.0031308000907301903f);
  float _1503 = select(_1500, _1497, _1494);
  float _1504 = select(_1501, _1498, _1495);
  float _1505 = select(_1502, _1499, _1496);
  int _1508 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1509 = uint(SV_Position.x);
  uint _1510 = uint(SV_Position.y);
  int _1511 = _1509 & 63;
  int _1512 = _1510 & 63;
  float4 _1514 = t1.Load(int4(_1511, _1512, _1508, 0));
  float _1516 = _1514.x + -0.5f;
  float _1517 = _1516 * 0.003921568859368563f;
  float _1518 = _1517 + _1503;
  float _1519 = _1517 + _1504;
  float _1520 = _1517 + _1505;
  float _1521 = saturate(_1518);
  float _1522 = saturate(_1519);
  float _1523 = saturate(_1520);
  SV_Target.x = _1521;
  SV_Target.y = _1522;
  SV_Target.z = _1523;
  SV_Target.w = _378;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}