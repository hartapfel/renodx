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
  float _425;
  float _426;
  float _427;
  float _432;
  float _433;
  float _434;
  float _463;
  float _547;
  float _584;
  float _774;
  float _813;
  float _814;
  float _815;
  float _844;
  float _845;
  float _846;
  float _851;
  float _852;
  float _853;
  float _1088;
  float _1192;
  float _1296;
  float _1299;
  float _1300;
  float _1301;
  float _1312;
  float _1437;
  float _1438;
  float _1439;
  float _1486;
  float _1487;
  float _1488;
  float _1502;
  float _1503;
  float _1504;
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
  float4 _383 = t12.SampleLevel(s1, float2(_57, _58), 0.0f);
  float4 _389 = t8.Sample(s8, float2(_59, _60));
  int _395 = asint((User_000.UserConstant_Z_000[7].z));
  bool _396 = ((int)_395 > (int)0);
  if (!_396) {
    bool _400 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _404 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _389.x;
    float _405 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _389.y;
    float _406 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _389.z;
    float _407 = _404 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _408 = _405 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _409 = _406 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_400) {
      float _411 = _407 * _383.x;
      float _412 = _408 * _383.y;
      float _413 = _409 * _383.z;
      _425 = _411;
      _426 = _412;
      _427 = _413;
    } else {
      float _415 = saturate(_407);
      float _416 = saturate(_408);
      float _417 = saturate(_409);
      float _418 = _383.x - _379;
      float _419 = _383.y - _380;
      float _420 = _383.z - _381;
      float _421 = _415 * _418;
      float _422 = _416 * _419;
      float _423 = _417 * _420;
      _425 = _421;
      _426 = _422;
      _427 = _423;
    }
    float _428 = _425 + _379;
    float _429 = _426 + _380;
    float _430 = _427 + _381;
    _432 = _428;
    _433 = _429;
    _434 = _430;
  } else {
    _432 = _379;
    _433 = _380;
    _434 = _381;
  }
  [branch]
  if (_396) {
    bool _439 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_439) {
      float _441 = _38.x + TEXCOORD.x;
      float _442 = _47 + TEXCOORD.y;
      float4 _445 = t2.SampleLevel(s2, float2(_441, _442), 0.0f);
      bool _449 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_449) {
        float4 _452 = t7.Load(int3(0, 0, 0));
        float _457 = _452.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _458 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _457;
        _463 = _458;
      } else {
        _463 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _467 = _445.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _468 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _467;
      float _470 = _463 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _471 = _470 + _463;
      float _472 = _463 - _470;
      float _473 = max(_468, _472);
      float _474 = min(_473, _471);
      float _477 = _468 - _474;
      float _478 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _477;
      float _480 = _474 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _481 = _480 * _468;
      float _482 = _478 / _481;
      float _483 = min(_482, 0.0f);
      float _485 = _470 + 1.0f;
      float _486 = 1.0f / _485;
      float _487 = _483 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _488 = max(0.0f, _482);
      float _491 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _488;
      float _492 = _491 + _487;
      float _493 = _492 * _486;
      float _494 = max(_493, -1.0f);
      float _495 = min(_494, 1.0f);
      float _496 = max(_495, -0.30000001192092896f);
      float _497 = min(_496, 1.0f);
      float _499 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _500 = _497 * _499;
      float _501 = _441 + -0.5f;
      float _502 = _442 + -0.5f;
      float _503 = _501 * _501;
      float _504 = _502 * _502;
      float _505 = _504 + _503;
      float _506 = sqrt(_505);
      float _507 = log2(_506);
      float _508 = _507 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _509 = exp2(_508);
      float _510 = _509 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _511 = dot(float2(_501, _502), float2(_501, _502));
      float _512 = rsqrt(_511);
      float _513 = _512 * _501;
      float _514 = _512 * _502;
      float _515 = abs(_500);
      float _519 = _510 * _515;
      float _520 = -0.0f - _519;
      float _521 = (User_000.UserConstant_Z_000[2].x) * _513;
      float _522 = _521 * _520;
      float _523 = (User_000.UserConstant_Z_000[2].y) * _514;
      float _524 = _523 * _520;
      float _525 = _515 * _510;
      float _526 = _521 * _525;
      float _527 = _523 * _525;
      float _528 = _522 + _441;
      float _529 = _524 + _442;
      float _530 = _526 + _441;
      float _531 = _527 + _442;
      float4 _532 = t0.SampleLevel(s1, float2(_528, _529), 0.0f);
      float4 _534 = t0.SampleLevel(s1, float2(_530, _531), 0.0f);
      float4 _536 = t2.SampleLevel(s2, float2(_528, _529), 0.0f);
      if (_449) {
        float4 _540 = t7.Load(int3(0, 0, 0));
        float _542 = _540.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _543 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _542;
        _547 = _543;
      } else {
        _547 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _548 = _536.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _549 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _548;
      float _550 = _547 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _551 = _550 + _547;
      float _552 = _547 - _550;
      float _553 = max(_549, _552);
      float _554 = min(_553, _551);
      float _555 = _549 - _554;
      float _556 = _555 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _557 = _554 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _558 = _557 * _549;
      float _559 = _556 / _558;
      float _560 = min(_559, 0.0f);
      float _561 = _550 + 1.0f;
      float _562 = 1.0f / _561;
      float _563 = _560 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _564 = max(0.0f, _559);
      float _565 = _564 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _566 = _565 + _563;
      float _567 = _566 * _562;
      float _568 = max(_567, -1.0f);
      float _569 = min(_568, 1.0f);
      float _570 = max(_569, -0.30000001192092896f);
      float _571 = min(_570, 1.0f);
      float _572 = _571 * _499;
      float4 _573 = t2.SampleLevel(s2, float2(_530, _531), 0.0f);
      if (_449) {
        float4 _577 = t7.Load(int3(0, 0, 0));
        float _579 = _577.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _580 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _579;
        _584 = _580;
      } else {
        _584 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _585 = _573.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _586 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _585;
      float _587 = _584 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _588 = _587 + _584;
      float _589 = _584 - _587;
      float _590 = max(_586, _589);
      float _591 = min(_590, _588);
      float _592 = _586 - _591;
      float _593 = _592 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _594 = _591 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _595 = _594 * _586;
      float _596 = _593 / _595;
      float _597 = min(_596, 0.0f);
      float _598 = _587 + 1.0f;
      float _599 = 1.0f / _598;
      float _600 = _597 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _601 = max(0.0f, _596);
      float _602 = _601 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _603 = _602 + _600;
      float _604 = _603 * _599;
      float _605 = max(_604, -1.0f);
      float _606 = min(_605, 1.0f);
      float _607 = max(_606, -0.30000001192092896f);
      float _608 = min(_607, 1.0f);
      float _609 = _608 * _499;
      float _610 = abs(_572);
      float _611 = _610 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _612 = ceil(_611);
      float _613 = saturate(_612);
      float _614 = _532.x - _432;
      float _615 = _613 * _614;
      float _616 = _615 + _432;
      float _617 = abs(_609);
      float _618 = _617 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _619 = ceil(_618);
      float _620 = saturate(_619);
      float _621 = _534.z - _434;
      float _622 = _620 * _621;
      float _623 = _622 + _434;
      _813 = _616;
      _814 = _433;
      _815 = _623;
    } else {
      _813 = _432;
      _814 = _433;
      _815 = _434;
    }
  } else {
    int _626 = asint((User_000.UserConstant_Z_000[7].y));
    bool _627 = ((int)_626 > (int)0);
    if (_627) {
      float _629 = _38.x + TEXCOORD.x;
      float _630 = _47 + TEXCOORD.y;
      float4 _633 = t4.Sample(s4, float2(_629, _630));
      float4 _640 = t5.Sample(s5, float2(_629, _630));
      float _644 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _640.x;
      float _648 = _644 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _649 = _644 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _650 = _648 + _629;
      float _651 = _649 + _630;
      float4 _652 = t4.Sample(s4, float2(_650, _651));
      float4 _654 = t5.Sample(s5, float2(_650, _651));
      float _656 = _654.x * (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _657 = abs(_656);
      float _659 = _657 / (PostProcess_000.PostProcessConstant_Z_000[7].w);
      float _660 = _652.z - _633.z;
      float _661 = _659 * _660;
      float _662 = _633.x - _432;
      float _663 = _633.y - _433;
      float _664 = _633.z - _434;
      float _665 = _664 + _661;
      float _666 = _662 * _633.w;
      float _667 = _663 * _633.w;
      float _668 = _665 * _633.w;
      float _669 = _666 + _432;
      float _670 = _667 + _433;
      float _671 = _668 + _434;
      _813 = _669;
      _814 = _670;
      _815 = _671;
    } else {
      int _674 = asint((User_000.UserConstant_Z_000[7].x));
      bool _675 = ((int)_674 > (int)0);
      [branch]
      if (_675) {
        float4 _679 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _681 = abs(_679.x);
        _774 = _681;
      } else {
        float4 _685 = t2.SampleLevel(s2, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _687 = TEXCOORD.x * 2.0f;
        float _688 = TEXCOORD.y * 2.0f;
        float _689 = _687 + -1.0f;
        float _690 = _688 + -1.0f;
        float _711 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _689;
        float _712 = mad(_690, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _711);
        float _713 = mad(_685.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _712);
        float _714 = _713 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _715 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _689;
        float _716 = mad(_690, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _715);
        float _717 = mad(_685.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _716);
        float _718 = _717 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _719 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _689;
        float _720 = mad(_690, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _719);
        float _721 = mad(_685.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _720);
        float _722 = _721 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _723 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _689;
        float _724 = mad(_690, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _723);
        float _725 = mad(_685.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _724);
        float _726 = _725 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
        float _727 = _714 / _726;
        float _728 = _718 / _726;
        float _729 = _722 / _726;
        float _730 = _727 * _727;
        float _731 = _728 * _728;
        float _732 = _731 + _730;
        float _733 = _729 * _729;
        float _734 = _732 + _733;
        float _735 = sqrt(_734);
        float4 _738 = t5.Sample(s5, float2(TEXCOORD.x, TEXCOORD.y));
        float _744 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _745 = _744 + (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _746 = (PostProcess_000.PostProcessConstant_Z_000[5].x) - _744;
        float _747 = max(_735, _746);
        float _748 = min(_747, _745);
        float _750 = _735 - _748;
        float _751 = _750 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
        float _753 = _748 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _754 = _753 * _735;
        float _755 = _751 / _754;
        float _756 = min(_755, 0.0f);
        float _759 = _744 + 1.0f;
        float _760 = 1.0f / _759;
        float _761 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _756;
        float _762 = max(0.0f, _755);
        float _765 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _762;
        float _766 = _765 + _761;
        float _767 = _766 * _760;
        float _768 = min(_738.x, _767);
        float _769 = abs(_768);
        float _770 = abs(_767);
        float _771 = max(_769, _770);
        float _772 = saturate(_771);
        _774 = _772;
      }
      float _777 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _774;
      float4 _780 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _787 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _777;
      float _788 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _777;
      float _789 = _787 + TEXCOORD.x;
      float _790 = _788 + TEXCOORD.y;
      float4 _791 = t4.Sample(s4, float2(_789, _790));
      float4 _795 = t5.Sample(s5, float2(_789, _790));
      float _797 = abs(_795.x);
      float _798 = _791.z - _780.z;
      float _799 = _797 * _798;
      float _800 = _777 + -1.0f;
      float _801 = saturate(_800);
      float _802 = _780.x - _432;
      float _803 = _780.y - _433;
      float _804 = _780.z - _434;
      float _805 = _804 + _799;
      float _806 = _801 * _802;
      float _807 = _801 * _803;
      float _808 = _805 * _801;
      float _809 = _806 + _432;
      float _810 = _807 + _433;
      float _811 = _808 + _434;
      _813 = _809;
      _814 = _810;
      _815 = _811;
    }
  }
  if (_396) {
    bool _819 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _823 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _389.x;
    float _824 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _389.y;
    float _825 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _389.z;
    float _826 = _823 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _827 = _824 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _828 = _825 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_819) {
      float _830 = _826 * _383.x;
      float _831 = _827 * _383.y;
      float _832 = _828 * _383.z;
      _844 = _830;
      _845 = _831;
      _846 = _832;
    } else {
      float _834 = saturate(_826);
      float _835 = saturate(_827);
      float _836 = saturate(_828);
      float _837 = _383.x - _813;
      float _838 = _383.y - _814;
      float _839 = _383.z - _815;
      float _840 = _834 * _837;
      float _841 = _835 * _838;
      float _842 = _836 * _839;
      _844 = _840;
      _845 = _841;
      _846 = _842;
    }
    float _847 = _844 + _813;
    float _848 = _845 + _814;
    float _849 = _846 + _815;
    _851 = _847;
    _852 = _848;
    _853 = _849;
  } else {
    _851 = _813;
    _852 = _814;
    _853 = _815;
  }
  float4 _857 = t17.Load(int3(0, 0, 0));
  float _863 = _857.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _864 = _863 * _851;
  float _865 = _864 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _866 = _863 * _852;
  float _867 = _866 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _868 = _863 * _853;
  float _869 = _868 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _874 = _57 * 2.0f;
  float _875 = _58 * 2.0f;
  float _876 = _874 + -1.0f;
  float _877 = _875 + -1.0f;
  float _880 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _877;
  float _881 = _876 * _876;
  float _882 = _880 * _880;
  float _883 = _882 + _881;
  float _884 = sqrt(_883);
  float _886 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _884;
  float _888 = _886 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _889 = saturate(_888);
  float _891 = log2(_889);
  float _892 = _891 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _893 = exp2(_892);
  float _894 = _865 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _895 = _867 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _896 = _869 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _897 = _894 - _865;
  float _898 = _895 - _867;
  float _899 = _896 - _869;
  float _900 = _893 * _897;
  float _901 = _893 * _898;
  float _902 = _893 * _899;
  float _903 = _900 + _865;
  float _904 = _901 + _867;
  float _905 = _902 + _869;
  float _908 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _909 = _908 * _903;
  float _910 = _908 * _904;
  float _911 = _908 * _905;
  float _912 = _909 + 1.0f;
  float _913 = _910 + 1.0f;
  float _914 = _911 + 1.0f;
  float _915 = log2(_912);
  float _916 = log2(_913);
  float _917 = log2(_914);
  float _920 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _921 = _920 * _915;
  float _922 = _920 * _916;
  float _923 = _920 * _917;
  float _925 = _921 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _926 = _922 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _927 = _923 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _930 = t3.Sample(s3, float3(_925, _926, _927));
  float _936 = _930.x * 13.450128555297852f;
  float _937 = _930.y * 13.450128555297852f;
  float _938 = _930.z * 13.450128555297852f;
  float _939 = exp2(_936);
  float _940 = exp2(_937);
  float _941 = exp2(_938);
  float _942 = _939 + -1.0f;
  float _943 = _940 + -1.0f;
  float _944 = _941 + -1.0f;
  float _945 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _946 = _945 * _942;
  float _947 = _945 * _943;
  float _948 = _945 * _944;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_909 * _945, _910 * _945, _911 * _945),
      float3(_946, _947, _948),
      1.f.xxx);
  _946 = apt_scaled_lut_output.x;
  _947 = apt_scaled_lut_output.y;
  _948 = apt_scaled_lut_output.z;
  bool _951 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !APTIsPsychoV();
  if (_951) {
    float _953 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _954 = _946 * _953;
    float _955 = _947 * _953;
    float _956 = _948 * _953;
    float _957 = _954 + 1.0f;
    float _958 = _955 + 1.0f;
    float _959 = _956 + 1.0f;
    float _960 = log2(_957);
    float _961 = log2(_958);
    float _962 = log2(_959);
    float _963 = _960 * 0.07434873282909393f;
    float _964 = _961 * 0.07434873282909393f;
    float _965 = _962 * 0.07434873282909393f;
    int _967 = asint((User_000.UserConstant_Z_000[3].y));
    int _968 = _967 & 1;
    bool _969 = (_968 == 0);
    if (!_969) {
      bool _986 = !(_963 <= (User_000.UserConstant_Z_000[4].x));
      if (!_986) {
        float _988 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _989 = _963 / _988;
        float _990 = _989 * (User_000.UserConstant_Z_000[4].y);
        float _991 = _989 * _989;
        float _992 = _991 * _989;
        float _993 = _992 - _989;
        float _994 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _995 = _988 * _988;
        float _996 = _995 * _994;
        float _997 = _996 * _993;
        float _998 = _997 + _990;
        _1088 = _998;
      } else {
        bool _1000 = !(_963 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1000) {
          float _1002 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1003 = max(9.999999974752427e-07f, _1002);
          float _1004 = _963 - (User_000.UserConstant_Z_000[4].x);
          float _1005 = _1004 / _1003;
          float _1006 = 1.0f - _1005;
          float _1007 = _1006 * (User_000.UserConstant_Z_000[4].y);
          float _1008 = _1005 * (User_000.UserConstant_Z_000[4].w);
          float _1009 = _1007 + _1008;
          float _1010 = _1006 * _1006;
          float _1011 = _1010 * _1006;
          float _1012 = _1011 - _1006;
          float _1013 = _1012 * (User_000.UserConstant_Z_000[10].x);
          float _1014 = _1005 * _1005;
          float _1015 = _1014 * _1005;
          float _1016 = _1015 - _1005;
          float _1017 = _1016 * (User_000.UserConstant_Z_000[10].y);
          float _1018 = _1013 + _1017;
          float _1019 = _1003 * _1003;
          float _1020 = _1019 * 0.1666666716337204f;
          float _1021 = _1020 * _1018;
          float _1022 = _1009 + _1021;
          _1088 = _1022;
        } else {
          bool _1024 = !(_963 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1024) {
            float _1026 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1027 = max(9.999999974752427e-07f, _1026);
            float _1028 = _963 - (User_000.UserConstant_Z_000[4].z);
            float _1029 = _1028 / _1027;
            float _1030 = 1.0f - _1029;
            float _1031 = _1030 * (User_000.UserConstant_Z_000[4].w);
            float _1032 = _1029 * (User_000.UserConstant_Z_000[9].y);
            float _1033 = _1031 + _1032;
            float _1034 = _1030 * _1030;
            float _1035 = _1034 * _1030;
            float _1036 = _1035 - _1030;
            float _1037 = _1036 * (User_000.UserConstant_Z_000[10].y);
            float _1038 = _1029 * _1029;
            float _1039 = _1038 * _1029;
            float _1040 = _1039 - _1029;
            float _1041 = _1040 * (User_000.UserConstant_Z_000[10].z);
            float _1042 = _1037 + _1041;
            float _1043 = _1027 * _1027;
            float _1044 = _1043 * 0.1666666716337204f;
            float _1045 = _1044 * _1042;
            float _1046 = _1033 + _1045;
            _1088 = _1046;
          } else {
            bool _1048 = !(_963 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1048) {
              float _1050 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1051 = max(9.999999974752427e-07f, _1050);
              float _1052 = _963 - (User_000.UserConstant_Z_000[9].x);
              float _1053 = _1052 / _1051;
              float _1054 = 1.0f - _1053;
              float _1055 = _1054 * (User_000.UserConstant_Z_000[9].y);
              float _1056 = _1053 * (User_000.UserConstant_Z_000[9].w);
              float _1057 = _1055 + _1056;
              float _1058 = _1054 * _1054;
              float _1059 = _1058 * _1054;
              float _1060 = _1059 - _1054;
              float _1061 = _1060 * (User_000.UserConstant_Z_000[10].z);
              float _1062 = _1053 * _1053;
              float _1063 = _1062 * _1053;
              float _1064 = _1063 - _1053;
              float _1065 = _1064 * (User_000.UserConstant_Z_000[10].w);
              float _1066 = _1061 + _1065;
              float _1067 = _1051 * _1051;
              float _1068 = _1067 * 0.1666666716337204f;
              float _1069 = _1068 * _1066;
              float _1070 = _1057 + _1069;
              _1088 = _1070;
            } else {
              float _1072 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1073 = _963 - (User_000.UserConstant_Z_000[9].z);
              float _1074 = max(9.999999974752427e-07f, _1072);
              float _1075 = _1073 / _1074;
              float _1076 = 1.0f - _1075;
              float _1077 = _1076 * (User_000.UserConstant_Z_000[9].w);
              float _1078 = _1077 + _1075;
              float _1079 = _1076 * _1076;
              float _1080 = _1079 * _1076;
              float _1081 = _1080 - _1076;
              float _1082 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1083 = _1072 * _1072;
              float _1084 = _1083 * _1082;
              float _1085 = _1084 * _1081;
              float _1086 = _1078 + _1085;
              _1088 = _1086;
            }
          }
        }
      }
      float _1089 = saturate(_1088);
      bool _1090 = !(_964 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1090) {
        float _1092 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1093 = _964 / _1092;
        float _1094 = _1093 * (User_000.UserConstant_Z_000[4].y);
        float _1095 = _1093 * _1093;
        float _1096 = _1095 * _1093;
        float _1097 = _1096 - _1093;
        float _1098 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1099 = _1092 * _1092;
        float _1100 = _1099 * _1098;
        float _1101 = _1100 * _1097;
        float _1102 = _1101 + _1094;
        _1192 = _1102;
      } else {
        bool _1104 = !(_964 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1104) {
          float _1106 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1107 = max(9.999999974752427e-07f, _1106);
          float _1108 = _964 - (User_000.UserConstant_Z_000[4].x);
          float _1109 = _1108 / _1107;
          float _1110 = 1.0f - _1109;
          float _1111 = _1110 * (User_000.UserConstant_Z_000[4].y);
          float _1112 = _1109 * (User_000.UserConstant_Z_000[4].w);
          float _1113 = _1111 + _1112;
          float _1114 = _1110 * _1110;
          float _1115 = _1114 * _1110;
          float _1116 = _1115 - _1110;
          float _1117 = _1116 * (User_000.UserConstant_Z_000[10].x);
          float _1118 = _1109 * _1109;
          float _1119 = _1118 * _1109;
          float _1120 = _1119 - _1109;
          float _1121 = _1120 * (User_000.UserConstant_Z_000[10].y);
          float _1122 = _1117 + _1121;
          float _1123 = _1107 * _1107;
          float _1124 = _1123 * 0.1666666716337204f;
          float _1125 = _1124 * _1122;
          float _1126 = _1113 + _1125;
          _1192 = _1126;
        } else {
          bool _1128 = !(_964 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1128) {
            float _1130 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1131 = max(9.999999974752427e-07f, _1130);
            float _1132 = _964 - (User_000.UserConstant_Z_000[4].z);
            float _1133 = _1132 / _1131;
            float _1134 = 1.0f - _1133;
            float _1135 = _1134 * (User_000.UserConstant_Z_000[4].w);
            float _1136 = _1133 * (User_000.UserConstant_Z_000[9].y);
            float _1137 = _1135 + _1136;
            float _1138 = _1134 * _1134;
            float _1139 = _1138 * _1134;
            float _1140 = _1139 - _1134;
            float _1141 = _1140 * (User_000.UserConstant_Z_000[10].y);
            float _1142 = _1133 * _1133;
            float _1143 = _1142 * _1133;
            float _1144 = _1143 - _1133;
            float _1145 = _1144 * (User_000.UserConstant_Z_000[10].z);
            float _1146 = _1141 + _1145;
            float _1147 = _1131 * _1131;
            float _1148 = _1147 * 0.1666666716337204f;
            float _1149 = _1148 * _1146;
            float _1150 = _1137 + _1149;
            _1192 = _1150;
          } else {
            bool _1152 = !(_964 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1152) {
              float _1154 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1155 = max(9.999999974752427e-07f, _1154);
              float _1156 = _964 - (User_000.UserConstant_Z_000[9].x);
              float _1157 = _1156 / _1155;
              float _1158 = 1.0f - _1157;
              float _1159 = _1158 * (User_000.UserConstant_Z_000[9].y);
              float _1160 = _1157 * (User_000.UserConstant_Z_000[9].w);
              float _1161 = _1159 + _1160;
              float _1162 = _1158 * _1158;
              float _1163 = _1162 * _1158;
              float _1164 = _1163 - _1158;
              float _1165 = _1164 * (User_000.UserConstant_Z_000[10].z);
              float _1166 = _1157 * _1157;
              float _1167 = _1166 * _1157;
              float _1168 = _1167 - _1157;
              float _1169 = _1168 * (User_000.UserConstant_Z_000[10].w);
              float _1170 = _1165 + _1169;
              float _1171 = _1155 * _1155;
              float _1172 = _1171 * 0.1666666716337204f;
              float _1173 = _1172 * _1170;
              float _1174 = _1161 + _1173;
              _1192 = _1174;
            } else {
              float _1176 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1177 = _964 - (User_000.UserConstant_Z_000[9].z);
              float _1178 = max(9.999999974752427e-07f, _1176);
              float _1179 = _1177 / _1178;
              float _1180 = 1.0f - _1179;
              float _1181 = _1180 * (User_000.UserConstant_Z_000[9].w);
              float _1182 = _1181 + _1179;
              float _1183 = _1180 * _1180;
              float _1184 = _1183 * _1180;
              float _1185 = _1184 - _1180;
              float _1186 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1187 = _1176 * _1176;
              float _1188 = _1187 * _1186;
              float _1189 = _1188 * _1185;
              float _1190 = _1182 + _1189;
              _1192 = _1190;
            }
          }
        }
      }
      float _1193 = saturate(_1192);
      bool _1194 = !(_965 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1194) {
        float _1196 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1197 = _965 / _1196;
        float _1198 = _1197 * (User_000.UserConstant_Z_000[4].y);
        float _1199 = _1197 * _1197;
        float _1200 = _1199 * _1197;
        float _1201 = _1200 - _1197;
        float _1202 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1203 = _1196 * _1196;
        float _1204 = _1203 * _1202;
        float _1205 = _1204 * _1201;
        float _1206 = _1205 + _1198;
        _1296 = _1206;
      } else {
        bool _1208 = !(_965 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1208) {
          float _1210 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1211 = max(9.999999974752427e-07f, _1210);
          float _1212 = _965 - (User_000.UserConstant_Z_000[4].x);
          float _1213 = _1212 / _1211;
          float _1214 = 1.0f - _1213;
          float _1215 = _1214 * (User_000.UserConstant_Z_000[4].y);
          float _1216 = _1213 * (User_000.UserConstant_Z_000[4].w);
          float _1217 = _1215 + _1216;
          float _1218 = _1214 * _1214;
          float _1219 = _1218 * _1214;
          float _1220 = _1219 - _1214;
          float _1221 = _1220 * (User_000.UserConstant_Z_000[10].x);
          float _1222 = _1213 * _1213;
          float _1223 = _1222 * _1213;
          float _1224 = _1223 - _1213;
          float _1225 = _1224 * (User_000.UserConstant_Z_000[10].y);
          float _1226 = _1221 + _1225;
          float _1227 = _1211 * _1211;
          float _1228 = _1227 * 0.1666666716337204f;
          float _1229 = _1228 * _1226;
          float _1230 = _1217 + _1229;
          _1296 = _1230;
        } else {
          bool _1232 = !(_965 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1232) {
            float _1234 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1235 = max(9.999999974752427e-07f, _1234);
            float _1236 = _965 - (User_000.UserConstant_Z_000[4].z);
            float _1237 = _1236 / _1235;
            float _1238 = 1.0f - _1237;
            float _1239 = _1238 * (User_000.UserConstant_Z_000[4].w);
            float _1240 = _1237 * (User_000.UserConstant_Z_000[9].y);
            float _1241 = _1239 + _1240;
            float _1242 = _1238 * _1238;
            float _1243 = _1242 * _1238;
            float _1244 = _1243 - _1238;
            float _1245 = _1244 * (User_000.UserConstant_Z_000[10].y);
            float _1246 = _1237 * _1237;
            float _1247 = _1246 * _1237;
            float _1248 = _1247 - _1237;
            float _1249 = _1248 * (User_000.UserConstant_Z_000[10].z);
            float _1250 = _1245 + _1249;
            float _1251 = _1235 * _1235;
            float _1252 = _1251 * 0.1666666716337204f;
            float _1253 = _1252 * _1250;
            float _1254 = _1241 + _1253;
            _1296 = _1254;
          } else {
            bool _1256 = !(_965 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1256) {
              float _1258 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1259 = max(9.999999974752427e-07f, _1258);
              float _1260 = _965 - (User_000.UserConstant_Z_000[9].x);
              float _1261 = _1260 / _1259;
              float _1262 = 1.0f - _1261;
              float _1263 = _1262 * (User_000.UserConstant_Z_000[9].y);
              float _1264 = _1261 * (User_000.UserConstant_Z_000[9].w);
              float _1265 = _1263 + _1264;
              float _1266 = _1262 * _1262;
              float _1267 = _1266 * _1262;
              float _1268 = _1267 - _1262;
              float _1269 = _1268 * (User_000.UserConstant_Z_000[10].z);
              float _1270 = _1261 * _1261;
              float _1271 = _1270 * _1261;
              float _1272 = _1271 - _1261;
              float _1273 = _1272 * (User_000.UserConstant_Z_000[10].w);
              float _1274 = _1269 + _1273;
              float _1275 = _1259 * _1259;
              float _1276 = _1275 * 0.1666666716337204f;
              float _1277 = _1276 * _1274;
              float _1278 = _1265 + _1277;
              _1296 = _1278;
            } else {
              float _1280 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1281 = _965 - (User_000.UserConstant_Z_000[9].z);
              float _1282 = max(9.999999974752427e-07f, _1280);
              float _1283 = _1281 / _1282;
              float _1284 = 1.0f - _1283;
              float _1285 = _1284 * (User_000.UserConstant_Z_000[9].w);
              float _1286 = _1285 + _1283;
              float _1287 = _1284 * _1284;
              float _1288 = _1287 * _1284;
              float _1289 = _1288 - _1284;
              float _1290 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1291 = _1280 * _1280;
              float _1292 = _1291 * _1290;
              float _1293 = _1292 * _1289;
              float _1294 = _1286 + _1293;
              _1296 = _1294;
            }
          }
        }
      }
      float _1297 = saturate(_1296);
      _1299 = _1089;
      _1300 = _1193;
      _1301 = _1297;
    } else {
      _1299 = _963;
      _1300 = _964;
      _1301 = _965;
    }
    int _1302 = _967 & 2;
    bool _1303 = (_1302 == 0);
    if (!_1303) {
      float _1305 = sqrt(_1299);
      float _1306 = sqrt(_1300);
      float _1307 = sqrt(_1301);
      float _1308 = dot(float3(_1305, _1306, _1307), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1309 = 1.0f - _1308;
      float _1310 = saturate(_1309);
      _1312 = _1310;
    } else {
      _1312 = 1.0f;
    }
    int _1313 = _967 & 8;
    bool _1314 = (_1313 == 0);
    if (_1314) {
      int _1316 = _967 & 4;
      bool _1317 = (_1316 == 0);
      if (!_1317) {
        int _1319 = _967 & 16;
        bool _1320 = (_1319 == 0);
        if (!_1320) {
          float _1324 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1325 = _1324 + 0.5f;
          bool _1326 = (_1325 < 0.5f);
          float _1327 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1328 = select(_1326, (User_000.UserConstant_Z_000[5].x), _1327);
          bool _1329 = (_1300 < _1301);
          float _1330 = select(_1329, _1301, _1300);
          float _1331 = select(_1329, _1300, _1301);
          bool _1332 = (_1299 < _1330);
          float _1333 = select(_1332, _1330, _1299);
          float _1334 = select(_1332, _1299, _1330);
          float _1335 = min(_1334, _1331);
          float _1336 = _1333 - _1335;
          float _1337 = _1333 + 1.000000013351432e-10f;
          float _1338 = _1336 / _1337;
          float _1340 = _1338 - (User_000.UserConstant_Z_000[5].y);
          float _1341 = saturate(_1340);
          float _1342 = max(_1341, 9.999999974752427e-07f);
          float _1343 = log2(_1342);
          float _1344 = _1343 * _1328;
          float _1345 = exp2(_1344);
          float _1346 = 2.0f - _1345;
          float _1348 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1349 = saturate(_1348);
          float _1350 = max(_1349, _1346);
          float _1351 = dot(float3(_1299, _1300, _1301), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1352 = _1299 - _1351;
          float _1353 = _1300 - _1351;
          float _1354 = _1301 - _1351;
          float _1355 = _1352 * _1350;
          float _1356 = _1353 * _1350;
          float _1357 = _1354 * _1350;
          float _1358 = _1351 - _1299;
          float _1359 = _1358 + _1355;
          float _1360 = _1351 - _1300;
          float _1361 = _1360 + _1356;
          float _1362 = _1351 - _1301;
          float _1363 = _1362 + _1357;
          float _1364 = _1359 * _1312;
          float _1365 = _1361 * _1312;
          float _1366 = _1363 * _1312;
          float _1367 = _1364 + _1299;
          float _1368 = _1365 + _1300;
          float _1369 = _1366 + _1301;
          _1486 = _1367;
          _1487 = _1368;
          _1488 = _1369;
        } else {
          bool _1371 = (_1312 == 0.0f);
          if (!_1371) {
            float _1375 = abs(User_000.UserConstant_Z_000[5].x);
            float _1376 = saturate(_1375);
            uint4 _1378 = 0u; t15.GetDimensions(0u, _1378.x, _1378.y, _1378.w);
            float _1381 = float((uint)_1378.y);
            int _1382 = _967 & 32;
            bool _1383 = (_1382 == 0);
            float _1384 = _1381 + -1.0f;
            if (!_1383) {
              float _1386 = 1.0f / _1384;
              uint _1387 = uint(SV_Position.x);
              uint _1388 = uint(SV_Position.y);
              int _1389 = _1387 & 63;
              int _1390 = _1388 & 63;
              float4 _1392 = t6.Load(int4(_1389, _1390, 0, 0));
              float _1395 = _1392.x + -0.5f;
              float _1396 = _1299 * 13.999999046325684f;
              float _1397 = _1300 * 13.999999046325684f;
              float _1398 = _1301 * 13.999999046325684f;
              float _1399 = saturate(_1396);
              float _1400 = saturate(_1397);
              float _1401 = saturate(_1398);
              float _1402 = _1299 + -0.9285714030265808f;
              float _1403 = _1300 + -0.9285714030265808f;
              float _1404 = _1301 + -0.9285714030265808f;
              float _1405 = _1402 * 13.999999046325684f;
              float _1406 = _1403 * 13.999999046325684f;
              float _1407 = _1404 * 13.999999046325684f;
              float _1408 = saturate(_1405);
              float _1409 = saturate(_1406);
              float _1410 = saturate(_1407);
              float _1411 = 1.0f - _1408;
              float _1412 = 1.0f - _1409;
              float _1413 = 1.0f - _1410;
              float _1414 = min(_1399, _1411);
              float _1415 = min(_1400, _1412);
              float _1416 = min(_1401, _1413);
              float _1417 = _1392.y + -0.5f;
              float _1418 = _1414 * _1417;
              float _1419 = _1415 * _1417;
              float _1420 = _1416 * _1417;
              float _1421 = _1418 + _1395;
              float _1422 = _1419 + _1395;
              float _1423 = _1420 + _1395;
              float _1424 = _1421 * _1386;
              float _1425 = _1422 * _1386;
              float _1426 = _1423 * _1386;
              float _1427 = _1424 + _1299;
              float _1428 = _1425 + _1300;
              float _1429 = _1426 + _1301;
              float _1430 = saturate(_1427);
              float _1431 = saturate(_1428);
              float _1432 = saturate(_1429);
              float _1433 = saturate(_1430);
              float _1434 = saturate(_1431);
              float _1435 = saturate(_1432);
              _1437 = _1433;
              _1438 = _1434;
              _1439 = _1435;
            } else {
              _1437 = _1299;
              _1438 = _1300;
              _1439 = _1301;
            }
            float _1440 = float((uint)_1378.x);
            float _1441 = _1384 / _1440;
            float _1442 = _1441 * _1437;
            float _1443 = 0.5f / _1440;
            float _1444 = _1442 + _1443;
            float _1445 = _1384 / _1381;
            float _1446 = _1445 * _1438;
            float _1447 = 0.5f / _1381;
            float _1448 = _1446 + _1447;
            float _1449 = _1439 * _1384;
            float _1450 = floor(_1449);
            float _1451 = frac(_1449);
            float _1452 = _1450 / _1381;
            float _1453 = _1452 + _1444;
            float _1454 = _1450 + 1.0f;
            float _1455 = _1454 / _1381;
            float _1456 = _1455 + _1444;
            float4 _1458 = t15.Sample(s1, float2(_1453, _1448));
            float4 _1462 = t15.Sample(s1, float2(_1456, _1448));
            float _1466 = _1462.x - _1458.x;
            float _1467 = _1462.y - _1458.y;
            float _1468 = _1462.z - _1458.z;
            float _1469 = _1466 * _1451;
            float _1470 = _1467 * _1451;
            float _1471 = _1468 * _1451;
            float _1472 = _1376 * _1312;
            float _1473 = _1458.x - _1299;
            float _1474 = _1473 + _1469;
            float _1475 = _1458.y - _1300;
            float _1476 = _1475 + _1470;
            float _1477 = _1458.z - _1301;
            float _1478 = _1477 + _1471;
            float _1479 = _1474 * _1472;
            float _1480 = _1476 * _1472;
            float _1481 = _1478 * _1472;
            float _1482 = _1479 + _1299;
            float _1483 = _1480 + _1300;
            float _1484 = _1481 + _1301;
            _1486 = _1482;
            _1487 = _1483;
            _1488 = _1484;
          } else {
            _1486 = _1299;
            _1487 = _1300;
            _1488 = _1301;
          }
        }
      } else {
        _1486 = _1299;
        _1487 = _1300;
        _1488 = _1301;
      }
    } else {
      _1486 = _1312;
      _1487 = _1312;
      _1488 = _1312;
    }
    float _1489 = _1486 * 13.450128555297852f;
    float _1490 = _1487 * 13.450128555297852f;
    float _1491 = _1488 * 13.450128555297852f;
    float _1492 = exp2(_1489);
    float _1493 = exp2(_1490);
    float _1494 = exp2(_1491);
    float _1495 = _1492 + -1.0f;
    float _1496 = _1493 + -1.0f;
    float _1497 = _1494 + -1.0f;
    float _1498 = _1495 * _945;
    float _1499 = _1496 * _945;
    float _1500 = _1497 * _945;
    _1502 = _1498;
    _1503 = _1499;
    _1504 = _1500;
  } else {
    _1502 = _946;
    _1503 = _947;
    _1504 = _948;
  }
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1502, (User_000.UserConstant_Z_000[8].y) * _1503, (User_000.UserConstant_Z_000[8].z) * _1504),
      SV_Position.xy);
  float _1511 = apt_perceptual_film_grain.x;
  float _1512 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1513 = log2(_1511);
  float _1514 = _1512 * _1513;
  float _1515 = exp2(_1514);
  float _1516 = _1515 + -1.0f;
  float _1517 = _1511 + -1.0f;
  float _1518 = _1516 / _1517;
  bool _1519 = !(_1511 == 1.0f);
  float _1520 = _1518 + -1.0f;
  float _1521 = _1520 / _1518;
  float _1522 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1523 = _1522 / _1512;
  float _1524 = select(_1519, _1521, _1523);
  float _1525 = apt_perceptual_film_grain.y;
  float _1526 = log2(_1525);
  float _1527 = _1526 * _1512;
  float _1528 = exp2(_1527);
  float _1529 = _1528 + -1.0f;
  float _1530 = _1525 + -1.0f;
  float _1531 = _1529 / _1530;
  bool _1532 = !(_1525 == 1.0f);
  float _1533 = _1531 + -1.0f;
  float _1534 = _1533 / _1531;
  float _1535 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1536 = _1535 / _1512;
  float _1537 = select(_1532, _1534, _1536);
  float _1538 = apt_perceptual_film_grain.z;
  float _1539 = log2(_1538);
  float _1540 = _1539 * _1512;
  float _1541 = exp2(_1540);
  float _1542 = _1541 + -1.0f;
  float _1543 = _1538 + -1.0f;
  float _1544 = _1542 / _1543;
  bool _1545 = !(_1538 == 1.0f);
  float _1546 = _1544 + -1.0f;
  float _1547 = _1546 / _1544;
  float _1548 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1549 = _1548 / _1512;
  float _1550 = select(_1545, _1547, _1549);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1511, _1525, _1538),
      float3(_1524, _1537, _1550),
      true);
  float _1551 = apt_post_process_output.x;
  float _1552 = apt_post_process_output.y;
  float _1553 = apt_post_process_output.z;
  float _1554 = log2(_1551);
  float _1555 = log2(_1552);
  float _1556 = log2(_1553);
  float _1557 = _1554 * 0.4166666567325592f;
  float _1558 = _1555 * 0.4166666567325592f;
  float _1559 = _1556 * 0.4166666567325592f;
  float _1560 = exp2(_1557);
  float _1561 = exp2(_1558);
  float _1562 = exp2(_1559);
  float _1563 = _1560 * 1.0549999475479126f;
  float _1564 = _1561 * 1.0549999475479126f;
  float _1565 = _1562 * 1.0549999475479126f;
  float _1566 = _1563 + -0.054999999701976776f;
  float _1567 = _1564 + -0.054999999701976776f;
  float _1568 = _1565 + -0.054999999701976776f;
  float _1569 = _1551 * 12.920000076293945f;
  float _1570 = _1552 * 12.920000076293945f;
  float _1571 = _1553 * 12.920000076293945f;
  bool _1572 = (_1551 <= 0.0031308000907301903f);
  bool _1573 = (_1552 <= 0.0031308000907301903f);
  bool _1574 = (_1553 <= 0.0031308000907301903f);
  float _1575 = select(_1572, _1569, _1566);
  float _1576 = select(_1573, _1570, _1567);
  float _1577 = select(_1574, _1571, _1568);
  int _1580 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1581 = uint(SV_Position.x);
  uint _1582 = uint(SV_Position.y);
  int _1583 = _1581 & 63;
  int _1584 = _1582 & 63;
  float4 _1586 = t1.Load(int4(_1583, _1584, _1580, 0));
  float _1588 = _1586.x + -0.5f;
  float _1589 = _1588 * 0.003921568859368563f;
  float _1590 = _1589 + _1575;
  float _1591 = _1589 + _1576;
  float _1592 = _1589 + _1577;
  float _1593 = saturate(_1590);
  float _1594 = saturate(_1591);
  float _1595 = saturate(_1592);
  SV_Target.x = _1593;
  SV_Target.y = _1594;
  SV_Target.z = _1595;
  SV_Target.w = _378;
  return SV_Target;
}
