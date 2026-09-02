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
  float _725;
  float _764;
  float _765;
  float _766;
  float _805;
  float _806;
  float _807;
  float _1045;
  float _1149;
  float _1253;
  float _1256;
  float _1257;
  float _1258;
  float _1269;
  float _1394;
  float _1395;
  float _1396;
  float _1443;
  float _1444;
  float _1445;
  float _1459;
  float _1460;
  float _1461;
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
  float _820 = _814.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _821 = _820 * _808;
  float _822 = _821 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _823 = _820 * _809;
  float _824 = _823 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _825 = _820 * _810;
  float _826 = _825 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _831 = _57 * 2.0f;
  float _832 = _58 * 2.0f;
  float _833 = _831 + -1.0f;
  float _834 = _832 + -1.0f;
  float _837 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _834;
  float _838 = _833 * _833;
  float _839 = _837 * _837;
  float _840 = _839 + _838;
  float _841 = sqrt(_840);
  float _843 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _841;
  float _845 = _843 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _846 = saturate(_845);
  float _848 = log2(_846);
  float _849 = _848 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _850 = ResonanceScaleVignetteMask(exp2(_849));
  float _851 = _822 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _852 = _824 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _853 = _826 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _854 = _851 - _822;
  float _855 = _852 - _824;
  float _856 = _853 - _826;
  float _857 = _850 * _854;
  float _858 = _850 * _855;
  float _859 = _850 * _856;
  float _860 = _857 + _822;
  float _861 = _858 + _824;
  float _862 = _859 + _826;
  float _865 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _866 = _865 * _860;
  float _867 = _865 * _861;
  float _868 = _865 * _862;
  float _869 = _866 + 1.0f;
  float _870 = _867 + 1.0f;
  float _871 = _868 + 1.0f;
  float _872 = log2(_869);
  float _873 = log2(_870);
  float _874 = log2(_871);
  float _877 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _878 = _877 * _872;
  float _879 = _877 * _873;
  float _880 = _877 * _874;
  float _882 = _878 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _883 = _879 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _884 = _880 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _887 = t3.Sample(s3, float3(_882, _883, _884));
  float _893 = _887.x * 13.450128555297852f;
  float _894 = _887.y * 13.450128555297852f;
  float _895 = _887.z * 13.450128555297852f;
  float _896 = exp2(_893);
  float _897 = exp2(_894);
  float _898 = exp2(_895);
  float _899 = _896 + -1.0f;
  float _900 = _897 + -1.0f;
  float _901 = _898 + -1.0f;
  float _902 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _903 = _902 * _899;
  float _904 = _902 * _900;
  float _905 = _902 * _901;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_866 * _902, _867 * _902, _868 * _902),
      float3(_903, _904, _905),
      1.f.xxx);
  _903 = resonance_scaled_lut_output.x;
  _904 = resonance_scaled_lut_output.y;
  _905 = resonance_scaled_lut_output.z;
  bool _908 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_908) {
    float _910 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _911 = _903 * _910;
    float _912 = _904 * _910;
    float _913 = _905 * _910;
    float _914 = _911 + 1.0f;
    float _915 = _912 + 1.0f;
    float _916 = _913 + 1.0f;
    float _917 = log2(_914);
    float _918 = log2(_915);
    float _919 = log2(_916);
    float _920 = _917 * 0.07434873282909393f;
    float _921 = _918 * 0.07434873282909393f;
    float _922 = _919 * 0.07434873282909393f;
    int _924 = asint((User_000.UserConstant_Z_000[3].y));
    int _925 = _924 & 1;
    bool _926 = (_925 == 0);
    if (!_926) {
      bool _943 = !(_920 <= (User_000.UserConstant_Z_000[4].x));
      if (!_943) {
        float _945 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _946 = _920 / _945;
        float _947 = _946 * (User_000.UserConstant_Z_000[4].y);
        float _948 = _946 * _946;
        float _949 = _948 * _946;
        float _950 = _949 - _946;
        float _951 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _952 = _945 * _945;
        float _953 = _952 * _951;
        float _954 = _953 * _950;
        float _955 = _954 + _947;
        _1045 = _955;
      } else {
        bool _957 = !(_920 <= (User_000.UserConstant_Z_000[4].z));
        if (!_957) {
          float _959 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _960 = max(9.999999974752427e-07f, _959);
          float _961 = _920 - (User_000.UserConstant_Z_000[4].x);
          float _962 = _961 / _960;
          float _963 = 1.0f - _962;
          float _964 = _963 * (User_000.UserConstant_Z_000[4].y);
          float _965 = _962 * (User_000.UserConstant_Z_000[4].w);
          float _966 = _964 + _965;
          float _967 = _963 * _963;
          float _968 = _967 * _963;
          float _969 = _968 - _963;
          float _970 = _969 * (User_000.UserConstant_Z_000[10].x);
          float _971 = _962 * _962;
          float _972 = _971 * _962;
          float _973 = _972 - _962;
          float _974 = _973 * (User_000.UserConstant_Z_000[10].y);
          float _975 = _970 + _974;
          float _976 = _960 * _960;
          float _977 = _976 * 0.1666666716337204f;
          float _978 = _977 * _975;
          float _979 = _966 + _978;
          _1045 = _979;
        } else {
          bool _981 = !(_920 <= (User_000.UserConstant_Z_000[9].x));
          if (!_981) {
            float _983 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _984 = max(9.999999974752427e-07f, _983);
            float _985 = _920 - (User_000.UserConstant_Z_000[4].z);
            float _986 = _985 / _984;
            float _987 = 1.0f - _986;
            float _988 = _987 * (User_000.UserConstant_Z_000[4].w);
            float _989 = _986 * (User_000.UserConstant_Z_000[9].y);
            float _990 = _988 + _989;
            float _991 = _987 * _987;
            float _992 = _991 * _987;
            float _993 = _992 - _987;
            float _994 = _993 * (User_000.UserConstant_Z_000[10].y);
            float _995 = _986 * _986;
            float _996 = _995 * _986;
            float _997 = _996 - _986;
            float _998 = _997 * (User_000.UserConstant_Z_000[10].z);
            float _999 = _994 + _998;
            float _1000 = _984 * _984;
            float _1001 = _1000 * 0.1666666716337204f;
            float _1002 = _1001 * _999;
            float _1003 = _990 + _1002;
            _1045 = _1003;
          } else {
            bool _1005 = !(_920 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1005) {
              float _1007 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1008 = max(9.999999974752427e-07f, _1007);
              float _1009 = _920 - (User_000.UserConstant_Z_000[9].x);
              float _1010 = _1009 / _1008;
              float _1011 = 1.0f - _1010;
              float _1012 = _1011 * (User_000.UserConstant_Z_000[9].y);
              float _1013 = _1010 * (User_000.UserConstant_Z_000[9].w);
              float _1014 = _1012 + _1013;
              float _1015 = _1011 * _1011;
              float _1016 = _1015 * _1011;
              float _1017 = _1016 - _1011;
              float _1018 = _1017 * (User_000.UserConstant_Z_000[10].z);
              float _1019 = _1010 * _1010;
              float _1020 = _1019 * _1010;
              float _1021 = _1020 - _1010;
              float _1022 = _1021 * (User_000.UserConstant_Z_000[10].w);
              float _1023 = _1018 + _1022;
              float _1024 = _1008 * _1008;
              float _1025 = _1024 * 0.1666666716337204f;
              float _1026 = _1025 * _1023;
              float _1027 = _1014 + _1026;
              _1045 = _1027;
            } else {
              float _1029 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1030 = _920 - (User_000.UserConstant_Z_000[9].z);
              float _1031 = max(9.999999974752427e-07f, _1029);
              float _1032 = _1030 / _1031;
              float _1033 = 1.0f - _1032;
              float _1034 = _1033 * (User_000.UserConstant_Z_000[9].w);
              float _1035 = _1034 + _1032;
              float _1036 = _1033 * _1033;
              float _1037 = _1036 * _1033;
              float _1038 = _1037 - _1033;
              float _1039 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1040 = _1029 * _1029;
              float _1041 = _1040 * _1039;
              float _1042 = _1041 * _1038;
              float _1043 = _1035 + _1042;
              _1045 = _1043;
            }
          }
        }
      }
      float _1046 = saturate(_1045);
      bool _1047 = !(_921 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1047) {
        float _1049 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1050 = _921 / _1049;
        float _1051 = _1050 * (User_000.UserConstant_Z_000[4].y);
        float _1052 = _1050 * _1050;
        float _1053 = _1052 * _1050;
        float _1054 = _1053 - _1050;
        float _1055 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1056 = _1049 * _1049;
        float _1057 = _1056 * _1055;
        float _1058 = _1057 * _1054;
        float _1059 = _1058 + _1051;
        _1149 = _1059;
      } else {
        bool _1061 = !(_921 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1061) {
          float _1063 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1064 = max(9.999999974752427e-07f, _1063);
          float _1065 = _921 - (User_000.UserConstant_Z_000[4].x);
          float _1066 = _1065 / _1064;
          float _1067 = 1.0f - _1066;
          float _1068 = _1067 * (User_000.UserConstant_Z_000[4].y);
          float _1069 = _1066 * (User_000.UserConstant_Z_000[4].w);
          float _1070 = _1068 + _1069;
          float _1071 = _1067 * _1067;
          float _1072 = _1071 * _1067;
          float _1073 = _1072 - _1067;
          float _1074 = _1073 * (User_000.UserConstant_Z_000[10].x);
          float _1075 = _1066 * _1066;
          float _1076 = _1075 * _1066;
          float _1077 = _1076 - _1066;
          float _1078 = _1077 * (User_000.UserConstant_Z_000[10].y);
          float _1079 = _1074 + _1078;
          float _1080 = _1064 * _1064;
          float _1081 = _1080 * 0.1666666716337204f;
          float _1082 = _1081 * _1079;
          float _1083 = _1070 + _1082;
          _1149 = _1083;
        } else {
          bool _1085 = !(_921 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1085) {
            float _1087 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1088 = max(9.999999974752427e-07f, _1087);
            float _1089 = _921 - (User_000.UserConstant_Z_000[4].z);
            float _1090 = _1089 / _1088;
            float _1091 = 1.0f - _1090;
            float _1092 = _1091 * (User_000.UserConstant_Z_000[4].w);
            float _1093 = _1090 * (User_000.UserConstant_Z_000[9].y);
            float _1094 = _1092 + _1093;
            float _1095 = _1091 * _1091;
            float _1096 = _1095 * _1091;
            float _1097 = _1096 - _1091;
            float _1098 = _1097 * (User_000.UserConstant_Z_000[10].y);
            float _1099 = _1090 * _1090;
            float _1100 = _1099 * _1090;
            float _1101 = _1100 - _1090;
            float _1102 = _1101 * (User_000.UserConstant_Z_000[10].z);
            float _1103 = _1098 + _1102;
            float _1104 = _1088 * _1088;
            float _1105 = _1104 * 0.1666666716337204f;
            float _1106 = _1105 * _1103;
            float _1107 = _1094 + _1106;
            _1149 = _1107;
          } else {
            bool _1109 = !(_921 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1109) {
              float _1111 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1112 = max(9.999999974752427e-07f, _1111);
              float _1113 = _921 - (User_000.UserConstant_Z_000[9].x);
              float _1114 = _1113 / _1112;
              float _1115 = 1.0f - _1114;
              float _1116 = _1115 * (User_000.UserConstant_Z_000[9].y);
              float _1117 = _1114 * (User_000.UserConstant_Z_000[9].w);
              float _1118 = _1116 + _1117;
              float _1119 = _1115 * _1115;
              float _1120 = _1119 * _1115;
              float _1121 = _1120 - _1115;
              float _1122 = _1121 * (User_000.UserConstant_Z_000[10].z);
              float _1123 = _1114 * _1114;
              float _1124 = _1123 * _1114;
              float _1125 = _1124 - _1114;
              float _1126 = _1125 * (User_000.UserConstant_Z_000[10].w);
              float _1127 = _1122 + _1126;
              float _1128 = _1112 * _1112;
              float _1129 = _1128 * 0.1666666716337204f;
              float _1130 = _1129 * _1127;
              float _1131 = _1118 + _1130;
              _1149 = _1131;
            } else {
              float _1133 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1134 = _921 - (User_000.UserConstant_Z_000[9].z);
              float _1135 = max(9.999999974752427e-07f, _1133);
              float _1136 = _1134 / _1135;
              float _1137 = 1.0f - _1136;
              float _1138 = _1137 * (User_000.UserConstant_Z_000[9].w);
              float _1139 = _1138 + _1136;
              float _1140 = _1137 * _1137;
              float _1141 = _1140 * _1137;
              float _1142 = _1141 - _1137;
              float _1143 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1144 = _1133 * _1133;
              float _1145 = _1144 * _1143;
              float _1146 = _1145 * _1142;
              float _1147 = _1139 + _1146;
              _1149 = _1147;
            }
          }
        }
      }
      float _1150 = saturate(_1149);
      bool _1151 = !(_922 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1151) {
        float _1153 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1154 = _922 / _1153;
        float _1155 = _1154 * (User_000.UserConstant_Z_000[4].y);
        float _1156 = _1154 * _1154;
        float _1157 = _1156 * _1154;
        float _1158 = _1157 - _1154;
        float _1159 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1160 = _1153 * _1153;
        float _1161 = _1160 * _1159;
        float _1162 = _1161 * _1158;
        float _1163 = _1162 + _1155;
        _1253 = _1163;
      } else {
        bool _1165 = !(_922 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1165) {
          float _1167 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1168 = max(9.999999974752427e-07f, _1167);
          float _1169 = _922 - (User_000.UserConstant_Z_000[4].x);
          float _1170 = _1169 / _1168;
          float _1171 = 1.0f - _1170;
          float _1172 = _1171 * (User_000.UserConstant_Z_000[4].y);
          float _1173 = _1170 * (User_000.UserConstant_Z_000[4].w);
          float _1174 = _1172 + _1173;
          float _1175 = _1171 * _1171;
          float _1176 = _1175 * _1171;
          float _1177 = _1176 - _1171;
          float _1178 = _1177 * (User_000.UserConstant_Z_000[10].x);
          float _1179 = _1170 * _1170;
          float _1180 = _1179 * _1170;
          float _1181 = _1180 - _1170;
          float _1182 = _1181 * (User_000.UserConstant_Z_000[10].y);
          float _1183 = _1178 + _1182;
          float _1184 = _1168 * _1168;
          float _1185 = _1184 * 0.1666666716337204f;
          float _1186 = _1185 * _1183;
          float _1187 = _1174 + _1186;
          _1253 = _1187;
        } else {
          bool _1189 = !(_922 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1189) {
            float _1191 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1192 = max(9.999999974752427e-07f, _1191);
            float _1193 = _922 - (User_000.UserConstant_Z_000[4].z);
            float _1194 = _1193 / _1192;
            float _1195 = 1.0f - _1194;
            float _1196 = _1195 * (User_000.UserConstant_Z_000[4].w);
            float _1197 = _1194 * (User_000.UserConstant_Z_000[9].y);
            float _1198 = _1196 + _1197;
            float _1199 = _1195 * _1195;
            float _1200 = _1199 * _1195;
            float _1201 = _1200 - _1195;
            float _1202 = _1201 * (User_000.UserConstant_Z_000[10].y);
            float _1203 = _1194 * _1194;
            float _1204 = _1203 * _1194;
            float _1205 = _1204 - _1194;
            float _1206 = _1205 * (User_000.UserConstant_Z_000[10].z);
            float _1207 = _1202 + _1206;
            float _1208 = _1192 * _1192;
            float _1209 = _1208 * 0.1666666716337204f;
            float _1210 = _1209 * _1207;
            float _1211 = _1198 + _1210;
            _1253 = _1211;
          } else {
            bool _1213 = !(_922 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1213) {
              float _1215 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1216 = max(9.999999974752427e-07f, _1215);
              float _1217 = _922 - (User_000.UserConstant_Z_000[9].x);
              float _1218 = _1217 / _1216;
              float _1219 = 1.0f - _1218;
              float _1220 = _1219 * (User_000.UserConstant_Z_000[9].y);
              float _1221 = _1218 * (User_000.UserConstant_Z_000[9].w);
              float _1222 = _1220 + _1221;
              float _1223 = _1219 * _1219;
              float _1224 = _1223 * _1219;
              float _1225 = _1224 - _1219;
              float _1226 = _1225 * (User_000.UserConstant_Z_000[10].z);
              float _1227 = _1218 * _1218;
              float _1228 = _1227 * _1218;
              float _1229 = _1228 - _1218;
              float _1230 = _1229 * (User_000.UserConstant_Z_000[10].w);
              float _1231 = _1226 + _1230;
              float _1232 = _1216 * _1216;
              float _1233 = _1232 * 0.1666666716337204f;
              float _1234 = _1233 * _1231;
              float _1235 = _1222 + _1234;
              _1253 = _1235;
            } else {
              float _1237 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1238 = _922 - (User_000.UserConstant_Z_000[9].z);
              float _1239 = max(9.999999974752427e-07f, _1237);
              float _1240 = _1238 / _1239;
              float _1241 = 1.0f - _1240;
              float _1242 = _1241 * (User_000.UserConstant_Z_000[9].w);
              float _1243 = _1242 + _1240;
              float _1244 = _1241 * _1241;
              float _1245 = _1244 * _1241;
              float _1246 = _1245 - _1241;
              float _1247 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1248 = _1237 * _1237;
              float _1249 = _1248 * _1247;
              float _1250 = _1249 * _1246;
              float _1251 = _1243 + _1250;
              _1253 = _1251;
            }
          }
        }
      }
      float _1254 = saturate(_1253);
      _1256 = _1046;
      _1257 = _1150;
      _1258 = _1254;
    } else {
      _1256 = _920;
      _1257 = _921;
      _1258 = _922;
    }
    int _1259 = _924 & 2;
    bool _1260 = (_1259 == 0);
    if (!_1260) {
      float _1262 = sqrt(_1256);
      float _1263 = sqrt(_1257);
      float _1264 = sqrt(_1258);
      float _1265 = dot(float3(_1262, _1263, _1264), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1266 = 1.0f - _1265;
      float _1267 = saturate(_1266);
      _1269 = _1267;
    } else {
      _1269 = 1.0f;
    }
    int _1270 = _924 & 8;
    bool _1271 = (_1270 == 0);
    if (_1271) {
      int _1273 = _924 & 4;
      bool _1274 = (_1273 == 0);
      if (!_1274) {
        int _1276 = _924 & 16;
        bool _1277 = (_1276 == 0);
        if (!_1277) {
          float _1281 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1282 = _1281 + 0.5f;
          bool _1283 = (_1282 < 0.5f);
          float _1284 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1285 = select(_1283, (User_000.UserConstant_Z_000[5].x), _1284);
          bool _1286 = (_1257 < _1258);
          float _1287 = select(_1286, _1258, _1257);
          float _1288 = select(_1286, _1257, _1258);
          bool _1289 = (_1256 < _1287);
          float _1290 = select(_1289, _1287, _1256);
          float _1291 = select(_1289, _1256, _1287);
          float _1292 = min(_1291, _1288);
          float _1293 = _1290 - _1292;
          float _1294 = _1290 + 1.000000013351432e-10f;
          float _1295 = _1293 / _1294;
          float _1297 = _1295 - (User_000.UserConstant_Z_000[5].y);
          float _1298 = saturate(_1297);
          float _1299 = max(_1298, 9.999999974752427e-07f);
          float _1300 = log2(_1299);
          float _1301 = _1300 * _1285;
          float _1302 = exp2(_1301);
          float _1303 = 2.0f - _1302;
          float _1305 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1306 = saturate(_1305);
          float _1307 = max(_1306, _1303);
          float _1308 = dot(float3(_1256, _1257, _1258), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1309 = _1256 - _1308;
          float _1310 = _1257 - _1308;
          float _1311 = _1258 - _1308;
          float _1312 = _1309 * _1307;
          float _1313 = _1310 * _1307;
          float _1314 = _1311 * _1307;
          float _1315 = _1308 - _1256;
          float _1316 = _1315 + _1312;
          float _1317 = _1308 - _1257;
          float _1318 = _1317 + _1313;
          float _1319 = _1308 - _1258;
          float _1320 = _1319 + _1314;
          float _1321 = _1316 * _1269;
          float _1322 = _1318 * _1269;
          float _1323 = _1320 * _1269;
          float _1324 = _1321 + _1256;
          float _1325 = _1322 + _1257;
          float _1326 = _1323 + _1258;
          _1443 = _1324;
          _1444 = _1325;
          _1445 = _1326;
        } else {
          bool _1328 = (_1269 == 0.0f);
          if (!_1328) {
            float _1332 = abs(User_000.UserConstant_Z_000[5].x);
            float _1333 = saturate(_1332);
            uint4 _1335 = 0u; t15.GetDimensions(0u, _1335.x, _1335.y, _1335.w);
            float _1338 = float((uint)_1335.y);
            int _1339 = _924 & 32;
            bool _1340 = (_1339 == 0);
            float _1341 = _1338 + -1.0f;
            if (!_1340) {
              float _1343 = 1.0f / _1341;
              uint _1344 = uint(SV_Position.x);
              uint _1345 = uint(SV_Position.y);
              int _1346 = _1344 & 63;
              int _1347 = _1345 & 63;
              float4 _1349 = t6.Load(int4(_1346, _1347, 0, 0));
              float _1352 = _1349.x + -0.5f;
              float _1353 = _1256 * 13.999999046325684f;
              float _1354 = _1257 * 13.999999046325684f;
              float _1355 = _1258 * 13.999999046325684f;
              float _1356 = saturate(_1353);
              float _1357 = saturate(_1354);
              float _1358 = saturate(_1355);
              float _1359 = _1256 + -0.9285714030265808f;
              float _1360 = _1257 + -0.9285714030265808f;
              float _1361 = _1258 + -0.9285714030265808f;
              float _1362 = _1359 * 13.999999046325684f;
              float _1363 = _1360 * 13.999999046325684f;
              float _1364 = _1361 * 13.999999046325684f;
              float _1365 = saturate(_1362);
              float _1366 = saturate(_1363);
              float _1367 = saturate(_1364);
              float _1368 = 1.0f - _1365;
              float _1369 = 1.0f - _1366;
              float _1370 = 1.0f - _1367;
              float _1371 = min(_1356, _1368);
              float _1372 = min(_1357, _1369);
              float _1373 = min(_1358, _1370);
              float _1374 = _1349.y + -0.5f;
              float _1375 = _1371 * _1374;
              float _1376 = _1372 * _1374;
              float _1377 = _1373 * _1374;
              float _1378 = _1375 + _1352;
              float _1379 = _1376 + _1352;
              float _1380 = _1377 + _1352;
              float _1381 = _1378 * _1343;
              float _1382 = _1379 * _1343;
              float _1383 = _1380 * _1343;
              float _1384 = _1381 + _1256;
              float _1385 = _1382 + _1257;
              float _1386 = _1383 + _1258;
              float _1387 = saturate(_1384);
              float _1388 = saturate(_1385);
              float _1389 = saturate(_1386);
              float _1390 = saturate(_1387);
              float _1391 = saturate(_1388);
              float _1392 = saturate(_1389);
              _1394 = _1390;
              _1395 = _1391;
              _1396 = _1392;
            } else {
              _1394 = _1256;
              _1395 = _1257;
              _1396 = _1258;
            }
            float _1397 = float((uint)_1335.x);
            float _1398 = _1341 / _1397;
            float _1399 = _1398 * _1394;
            float _1400 = 0.5f / _1397;
            float _1401 = _1399 + _1400;
            float _1402 = _1341 / _1338;
            float _1403 = _1402 * _1395;
            float _1404 = 0.5f / _1338;
            float _1405 = _1403 + _1404;
            float _1406 = _1396 * _1341;
            float _1407 = floor(_1406);
            float _1408 = frac(_1406);
            float _1409 = _1407 / _1338;
            float _1410 = _1409 + _1401;
            float _1411 = _1407 + 1.0f;
            float _1412 = _1411 / _1338;
            float _1413 = _1412 + _1401;
            float4 _1415 = t15.Sample(s1, float2(_1410, _1405));
            float4 _1419 = t15.Sample(s1, float2(_1413, _1405));
            float _1423 = _1419.x - _1415.x;
            float _1424 = _1419.y - _1415.y;
            float _1425 = _1419.z - _1415.z;
            float _1426 = _1423 * _1408;
            float _1427 = _1424 * _1408;
            float _1428 = _1425 * _1408;
            float _1429 = _1333 * _1269;
            float _1430 = _1415.x - _1256;
            float _1431 = _1430 + _1426;
            float _1432 = _1415.y - _1257;
            float _1433 = _1432 + _1427;
            float _1434 = _1415.z - _1258;
            float _1435 = _1434 + _1428;
            float _1436 = _1431 * _1429;
            float _1437 = _1433 * _1429;
            float _1438 = _1435 * _1429;
            float _1439 = _1436 + _1256;
            float _1440 = _1437 + _1257;
            float _1441 = _1438 + _1258;
            _1443 = _1439;
            _1444 = _1440;
            _1445 = _1441;
          } else {
            _1443 = _1256;
            _1444 = _1257;
            _1445 = _1258;
          }
        }
      } else {
        _1443 = _1256;
        _1444 = _1257;
        _1445 = _1258;
      }
    } else {
      _1443 = _1269;
      _1444 = _1269;
      _1445 = _1269;
    }
    float _1446 = _1443 * 13.450128555297852f;
    float _1447 = _1444 * 13.450128555297852f;
    float _1448 = _1445 * 13.450128555297852f;
    float _1449 = exp2(_1446);
    float _1450 = exp2(_1447);
    float _1451 = exp2(_1448);
    float _1452 = _1449 + -1.0f;
    float _1453 = _1450 + -1.0f;
    float _1454 = _1451 + -1.0f;
    float _1455 = _1452 * _902;
    float _1456 = _1453 * _902;
    float _1457 = _1454 * _902;
    _1459 = _1455;
    _1460 = _1456;
    _1461 = _1457;
  } else {
    _1459 = _903;
    _1460 = _904;
    _1461 = _905;
  }
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1459, (User_000.UserConstant_Z_000[8].y) * _1460, (User_000.UserConstant_Z_000[8].z) * _1461),
      SV_Position.xy);
  float _1468 = resonance_perceptual_film_grain.x;
  float _1469 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1470 = log2(_1468);
  float _1471 = _1469 * _1470;
  float _1472 = exp2(_1471);
  float _1473 = _1472 + -1.0f;
  float _1474 = _1468 + -1.0f;
  float _1475 = _1473 / _1474;
  bool _1476 = !(_1468 == 1.0f);
  float _1477 = _1475 + -1.0f;
  float _1478 = _1477 / _1475;
  float _1479 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1480 = _1479 / _1469;
  float _1481 = select(_1476, _1478, _1480);
  float _1482 = resonance_perceptual_film_grain.y;
  float _1483 = log2(_1482);
  float _1484 = _1483 * _1469;
  float _1485 = exp2(_1484);
  float _1486 = _1485 + -1.0f;
  float _1487 = _1482 + -1.0f;
  float _1488 = _1486 / _1487;
  bool _1489 = !(_1482 == 1.0f);
  float _1490 = _1488 + -1.0f;
  float _1491 = _1490 / _1488;
  float _1492 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1493 = _1492 / _1469;
  float _1494 = select(_1489, _1491, _1493);
  float _1495 = resonance_perceptual_film_grain.z;
  float _1496 = log2(_1495);
  float _1497 = _1496 * _1469;
  float _1498 = exp2(_1497);
  float _1499 = _1498 + -1.0f;
  float _1500 = _1495 + -1.0f;
  float _1501 = _1499 / _1500;
  bool _1502 = !(_1495 == 1.0f);
  float _1503 = _1501 + -1.0f;
  float _1504 = _1503 / _1501;
  float _1505 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1506 = _1505 / _1469;
  float _1507 = select(_1502, _1504, _1506);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1468, _1482, _1495),
      float3(_1481, _1494, _1507),
      true);
  float _1508 = resonance_post_process_output.x;
  float _1509 = resonance_post_process_output.y;
  float _1510 = resonance_post_process_output.z;
  float _1511 = log2(_1508);
  float _1512 = log2(_1509);
  float _1513 = log2(_1510);
  float _1514 = _1511 * 0.4166666567325592f;
  float _1515 = _1512 * 0.4166666567325592f;
  float _1516 = _1513 * 0.4166666567325592f;
  float _1517 = exp2(_1514);
  float _1518 = exp2(_1515);
  float _1519 = exp2(_1516);
  float _1520 = _1517 * 1.0549999475479126f;
  float _1521 = _1518 * 1.0549999475479126f;
  float _1522 = _1519 * 1.0549999475479126f;
  float _1523 = _1520 + -0.054999999701976776f;
  float _1524 = _1521 + -0.054999999701976776f;
  float _1525 = _1522 + -0.054999999701976776f;
  float _1526 = _1508 * 12.920000076293945f;
  float _1527 = _1509 * 12.920000076293945f;
  float _1528 = _1510 * 12.920000076293945f;
  bool _1529 = (_1508 <= 0.0031308000907301903f);
  bool _1530 = (_1509 <= 0.0031308000907301903f);
  bool _1531 = (_1510 <= 0.0031308000907301903f);
  float _1532 = select(_1529, _1526, _1523);
  float _1533 = select(_1530, _1527, _1524);
  float _1534 = select(_1531, _1528, _1525);
  int _1537 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1538 = uint(SV_Position.x);
  uint _1539 = uint(SV_Position.y);
  int _1540 = _1538 & 63;
  int _1541 = _1539 & 63;
  float4 _1543 = t1.Load(int4(_1540, _1541, _1537, 0));
  float _1545 = _1543.x + -0.5f;
  float _1546 = _1545 * 0.003921568859368563f;
  float _1547 = _1546 + _1532;
  float _1548 = _1546 + _1533;
  float _1549 = _1546 + _1534;
  float _1550 = saturate(_1547);
  float _1551 = saturate(_1548);
  float _1552 = saturate(_1549);
  SV_Target.x = _1550;
  SV_Target.y = _1551;
  SV_Target.z = _1552;
  SV_Target.w = _378;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}