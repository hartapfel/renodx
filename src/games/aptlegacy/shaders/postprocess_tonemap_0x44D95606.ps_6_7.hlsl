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
  float GlobalCB_Z__GlobalConstant_Z_1696;
  float GlobalCB_Z__GlobalConstant_Z_1700;
  float GlobalCB_Z__GlobalConstant_Z_1704;
  float GlobalCB_Z__GlobalConstant_Z_1708;
  float GlobalCB_Z__GlobalConstant_Z_1712;
  float GlobalCB_Z__GlobalConstant_Z_1716;
  float GlobalCB_Z__GlobalConstant_Z_1720;
  float GlobalCB_Z__GlobalConstant_Z_1724;
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
  GlobalCB_Z__ViewportConstant_Z GlobalCB_Z_1728;
  GlobalCB_Z__AnchorConstant_Z GlobalCB_Z_1824;
  GlobalCB_Z__ViewConstant_Z GlobalCB_Z_2176;
  GlobalCB_Z__ProjConstant_Z GlobalCB_Z_2720;
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
};

cbuffer cb0 : register(b0) {
  UserConstant_Z User_000 : packoffset(c000.x);
};

cbuffer cb2 : register(b2) {
  PostProcessConstant_Z PostProcess_000 : packoffset(c000.x);
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
  float _780;
  float _819;
  float _820;
  float _821;
  float _850;
  float _851;
  float _852;
  float _857;
  float _858;
  float _859;
  float _1037;
  float _1141;
  float _1245;
  float _1248;
  float _1249;
  float _1250;
  float _1261;
  float _1386;
  float _1387;
  float _1388;
  float _1435;
  float _1436;
  float _1437;
  float _1445;
  float _1446;
  float _1447;
  [branch]
  if (_70) {
    float _72 = floor(_62);
    int _73 = int(_72);
    uint2 _74; t0.GetDimensions(_74.x, _74.y);
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
        float _457 = _452.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _458 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _457;
        _463 = _458;
      } else {
        _463 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _467 = _445.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _468 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _467;
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
        float _542 = _540.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _543 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _542;
        _547 = _543;
      } else {
        _547 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _548 = _536.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _549 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _548;
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
        float _579 = _577.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _580 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _579;
        _584 = _580;
      } else {
        _584 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _585 = _573.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _586 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _585;
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
      _819 = _616;
      _820 = _433;
      _821 = _623;
    } else {
      _819 = _432;
      _820 = _433;
      _821 = _434;
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
      _819 = _669;
      _820 = _670;
      _821 = _671;
    } else {
      int _674 = asint((User_000.UserConstant_Z_000[7].x));
      bool _675 = ((int)_674 > (int)0);
      [branch]
      if (_675) {
        float4 _679 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _681 = abs(_679.x);
        _780 = _681;
      } else {
        float4 _685 = t2.SampleLevel(s2, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _687 = TEXCOORD.x * 2.0f;
        float _688 = TEXCOORD.y * 2.0f;
        float _689 = _687 + -1.0f;
        float _690 = _688 + -1.0f;
        float _711 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _689;
        float _712 = mad(_690, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _711);
        float _713 = mad(_685.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _712);
        float _714 = _713 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _715 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _689;
        float _716 = mad(_690, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _715);
        float _717 = mad(_685.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _716);
        float _718 = _717 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _719 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _689;
        float _720 = mad(_690, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _719);
        float _721 = mad(_685.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _720);
        float _722 = _721 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _723 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _689;
        float _724 = mad(_690, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _723);
        float _725 = mad(_685.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _724);
        float _726 = _725 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
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
        float4 _740 = t7.Load(int3(0, 0, 0));
        float _745 = _740.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _746 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _745;
        float _749 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * _746;
        float _750 = _749 + _746;
        float _751 = _746 - _749;
        float _752 = max(_735, _751);
        float _753 = min(_752, _750);
        float _756 = _735 - _753;
        float _757 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _756;
        float _759 = _753 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _760 = _759 * _735;
        float _761 = _757 / _760;
        float _762 = min(_761, 0.0f);
        float _765 = _749 + 1.0f;
        float _766 = 1.0f / _765;
        float _767 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _762;
        float _768 = max(0.0f, _761);
        float _771 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _768;
        float _772 = _771 + _767;
        float _773 = _772 * _766;
        float _774 = min(_738.x, _773);
        float _775 = abs(_774);
        float _776 = abs(_773);
        float _777 = max(_775, _776);
        float _778 = saturate(_777);
        _780 = _778;
      }
      float _783 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _780;
      float4 _786 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _793 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _783;
      float _794 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _783;
      float _795 = _793 + TEXCOORD.x;
      float _796 = _794 + TEXCOORD.y;
      float4 _797 = t4.Sample(s4, float2(_795, _796));
      float4 _801 = t5.Sample(s5, float2(_795, _796));
      float _803 = abs(_801.x);
      float _804 = _797.z - _786.z;
      float _805 = _803 * _804;
      float _806 = _783 + -1.0f;
      float _807 = saturate(_806);
      float _808 = _786.x - _432;
      float _809 = _786.y - _433;
      float _810 = _786.z - _434;
      float _811 = _810 + _805;
      float _812 = _807 * _808;
      float _813 = _807 * _809;
      float _814 = _811 * _807;
      float _815 = _812 + _432;
      float _816 = _813 + _433;
      float _817 = _814 + _434;
      _819 = _815;
      _820 = _816;
      _821 = _817;
    }
  }
  if (_396) {
    bool _825 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _829 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _389.x;
    float _830 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _389.y;
    float _831 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _389.z;
    float _832 = _829 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _833 = _830 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _834 = _831 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_825) {
      float _836 = _832 * _383.x;
      float _837 = _833 * _383.y;
      float _838 = _834 * _383.z;
      _850 = _836;
      _851 = _837;
      _852 = _838;
    } else {
      float _840 = saturate(_832);
      float _841 = saturate(_833);
      float _842 = saturate(_834);
      float _843 = _383.x - _819;
      float _844 = _383.y - _820;
      float _845 = _383.z - _821;
      float _846 = _840 * _843;
      float _847 = _841 * _844;
      float _848 = _842 * _845;
      _850 = _846;
      _851 = _847;
      _852 = _848;
    }
    float _853 = _850 + _819;
    float _854 = _851 + _820;
    float _855 = _852 + _821;
    _857 = _853;
    _858 = _854;
    _859 = _855;
  } else {
    _857 = _819;
    _858 = _820;
    _859 = _821;
  }
  float4 _863 = t17.Load(int3(0, 0, 0));
  float _869 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 335.718017578125f;
  float _870 = _863.x * _869;
  float _871 = _870 * _857;
  float _872 = _871 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _873 = _870 * _858;
  float _874 = _873 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _875 = _870 * _859;
  float _876 = _875 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _877 = _872 + 1.0f;
  float _878 = _874 + 1.0f;
  float _879 = _876 + 1.0f;
  float _880 = log2(_877);
  float _881 = log2(_878);
  float _882 = log2(_879);
  float _885 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _886 = _885 * _880;
  float _887 = _885 * _881;
  float _888 = _885 * _882;
  float _890 = _886 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _891 = _887 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _892 = _888 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _895 = t3.Sample(s3, float3(_890, _891, _892));
  float _899 = _895.x * 13.450128555297852f;
  float _900 = _895.y * 13.450128555297852f;
  float _901 = _895.z * 13.450128555297852f;
  float _902 = exp2(_899);
  float _903 = exp2(_900);
  float _904 = exp2(_901);
  bool _907 = ((User_000.UserConstant_Z_000[3].x) > 0.0f);
  if (_907) {
    float _909 = log2(_902);
    float _910 = log2(_903);
    float _911 = log2(_904);
    float _912 = _909 * 0.07434873282909393f;
    float _913 = _910 * 0.07434873282909393f;
    float _914 = _911 * 0.07434873282909393f;
    int _916 = asint((User_000.UserConstant_Z_000[3].y));
    int _917 = _916 & 1;
    bool _918 = (_917 == 0);
    if (!_918) {
      bool _935 = !(_912 <= (User_000.UserConstant_Z_000[4].x));
      if (!_935) {
        float _937 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _938 = _912 / _937;
        float _939 = _938 * (User_000.UserConstant_Z_000[4].y);
        float _940 = _938 * _938;
        float _941 = _940 * _938;
        float _942 = _941 - _938;
        float _943 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _944 = _937 * _937;
        float _945 = _944 * _943;
        float _946 = _945 * _942;
        float _947 = _946 + _939;
        _1037 = _947;
      } else {
        bool _949 = !(_912 <= (User_000.UserConstant_Z_000[4].z));
        if (!_949) {
          float _951 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _952 = max(9.999999974752427e-07f, _951);
          float _953 = _912 - (User_000.UserConstant_Z_000[4].x);
          float _954 = _953 / _952;
          float _955 = 1.0f - _954;
          float _956 = _955 * (User_000.UserConstant_Z_000[4].y);
          float _957 = _954 * (User_000.UserConstant_Z_000[4].w);
          float _958 = _956 + _957;
          float _959 = _955 * _955;
          float _960 = _959 * _955;
          float _961 = _960 - _955;
          float _962 = _961 * (User_000.UserConstant_Z_000[10].x);
          float _963 = _954 * _954;
          float _964 = _963 * _954;
          float _965 = _964 - _954;
          float _966 = _965 * (User_000.UserConstant_Z_000[10].y);
          float _967 = _962 + _966;
          float _968 = _952 * _952;
          float _969 = _968 * 0.1666666716337204f;
          float _970 = _969 * _967;
          float _971 = _958 + _970;
          _1037 = _971;
        } else {
          bool _973 = !(_912 <= (User_000.UserConstant_Z_000[9].x));
          if (!_973) {
            float _975 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _976 = max(9.999999974752427e-07f, _975);
            float _977 = _912 - (User_000.UserConstant_Z_000[4].z);
            float _978 = _977 / _976;
            float _979 = 1.0f - _978;
            float _980 = _979 * (User_000.UserConstant_Z_000[4].w);
            float _981 = _978 * (User_000.UserConstant_Z_000[9].y);
            float _982 = _980 + _981;
            float _983 = _979 * _979;
            float _984 = _983 * _979;
            float _985 = _984 - _979;
            float _986 = _985 * (User_000.UserConstant_Z_000[10].y);
            float _987 = _978 * _978;
            float _988 = _987 * _978;
            float _989 = _988 - _978;
            float _990 = _989 * (User_000.UserConstant_Z_000[10].z);
            float _991 = _986 + _990;
            float _992 = _976 * _976;
            float _993 = _992 * 0.1666666716337204f;
            float _994 = _993 * _991;
            float _995 = _982 + _994;
            _1037 = _995;
          } else {
            bool _997 = !(_912 <= (User_000.UserConstant_Z_000[9].z));
            if (!_997) {
              float _999 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1000 = max(9.999999974752427e-07f, _999);
              float _1001 = _912 - (User_000.UserConstant_Z_000[9].x);
              float _1002 = _1001 / _1000;
              float _1003 = 1.0f - _1002;
              float _1004 = _1003 * (User_000.UserConstant_Z_000[9].y);
              float _1005 = _1002 * (User_000.UserConstant_Z_000[9].w);
              float _1006 = _1004 + _1005;
              float _1007 = _1003 * _1003;
              float _1008 = _1007 * _1003;
              float _1009 = _1008 - _1003;
              float _1010 = _1009 * (User_000.UserConstant_Z_000[10].z);
              float _1011 = _1002 * _1002;
              float _1012 = _1011 * _1002;
              float _1013 = _1012 - _1002;
              float _1014 = _1013 * (User_000.UserConstant_Z_000[10].w);
              float _1015 = _1010 + _1014;
              float _1016 = _1000 * _1000;
              float _1017 = _1016 * 0.1666666716337204f;
              float _1018 = _1017 * _1015;
              float _1019 = _1006 + _1018;
              _1037 = _1019;
            } else {
              float _1021 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1022 = _912 - (User_000.UserConstant_Z_000[9].z);
              float _1023 = max(9.999999974752427e-07f, _1021);
              float _1024 = _1022 / _1023;
              float _1025 = 1.0f - _1024;
              float _1026 = _1025 * (User_000.UserConstant_Z_000[9].w);
              float _1027 = _1026 + _1024;
              float _1028 = _1025 * _1025;
              float _1029 = _1028 * _1025;
              float _1030 = _1029 - _1025;
              float _1031 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1032 = _1021 * _1021;
              float _1033 = _1032 * _1031;
              float _1034 = _1033 * _1030;
              float _1035 = _1027 + _1034;
              _1037 = _1035;
            }
          }
        }
      }
      float _1038 = saturate(_1037);
      bool _1039 = !(_913 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1039) {
        float _1041 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1042 = _913 / _1041;
        float _1043 = _1042 * (User_000.UserConstant_Z_000[4].y);
        float _1044 = _1042 * _1042;
        float _1045 = _1044 * _1042;
        float _1046 = _1045 - _1042;
        float _1047 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1048 = _1041 * _1041;
        float _1049 = _1048 * _1047;
        float _1050 = _1049 * _1046;
        float _1051 = _1050 + _1043;
        _1141 = _1051;
      } else {
        bool _1053 = !(_913 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1053) {
          float _1055 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1056 = max(9.999999974752427e-07f, _1055);
          float _1057 = _913 - (User_000.UserConstant_Z_000[4].x);
          float _1058 = _1057 / _1056;
          float _1059 = 1.0f - _1058;
          float _1060 = _1059 * (User_000.UserConstant_Z_000[4].y);
          float _1061 = _1058 * (User_000.UserConstant_Z_000[4].w);
          float _1062 = _1060 + _1061;
          float _1063 = _1059 * _1059;
          float _1064 = _1063 * _1059;
          float _1065 = _1064 - _1059;
          float _1066 = _1065 * (User_000.UserConstant_Z_000[10].x);
          float _1067 = _1058 * _1058;
          float _1068 = _1067 * _1058;
          float _1069 = _1068 - _1058;
          float _1070 = _1069 * (User_000.UserConstant_Z_000[10].y);
          float _1071 = _1066 + _1070;
          float _1072 = _1056 * _1056;
          float _1073 = _1072 * 0.1666666716337204f;
          float _1074 = _1073 * _1071;
          float _1075 = _1062 + _1074;
          _1141 = _1075;
        } else {
          bool _1077 = !(_913 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1077) {
            float _1079 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1080 = max(9.999999974752427e-07f, _1079);
            float _1081 = _913 - (User_000.UserConstant_Z_000[4].z);
            float _1082 = _1081 / _1080;
            float _1083 = 1.0f - _1082;
            float _1084 = _1083 * (User_000.UserConstant_Z_000[4].w);
            float _1085 = _1082 * (User_000.UserConstant_Z_000[9].y);
            float _1086 = _1084 + _1085;
            float _1087 = _1083 * _1083;
            float _1088 = _1087 * _1083;
            float _1089 = _1088 - _1083;
            float _1090 = _1089 * (User_000.UserConstant_Z_000[10].y);
            float _1091 = _1082 * _1082;
            float _1092 = _1091 * _1082;
            float _1093 = _1092 - _1082;
            float _1094 = _1093 * (User_000.UserConstant_Z_000[10].z);
            float _1095 = _1090 + _1094;
            float _1096 = _1080 * _1080;
            float _1097 = _1096 * 0.1666666716337204f;
            float _1098 = _1097 * _1095;
            float _1099 = _1086 + _1098;
            _1141 = _1099;
          } else {
            bool _1101 = !(_913 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1101) {
              float _1103 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1104 = max(9.999999974752427e-07f, _1103);
              float _1105 = _913 - (User_000.UserConstant_Z_000[9].x);
              float _1106 = _1105 / _1104;
              float _1107 = 1.0f - _1106;
              float _1108 = _1107 * (User_000.UserConstant_Z_000[9].y);
              float _1109 = _1106 * (User_000.UserConstant_Z_000[9].w);
              float _1110 = _1108 + _1109;
              float _1111 = _1107 * _1107;
              float _1112 = _1111 * _1107;
              float _1113 = _1112 - _1107;
              float _1114 = _1113 * (User_000.UserConstant_Z_000[10].z);
              float _1115 = _1106 * _1106;
              float _1116 = _1115 * _1106;
              float _1117 = _1116 - _1106;
              float _1118 = _1117 * (User_000.UserConstant_Z_000[10].w);
              float _1119 = _1114 + _1118;
              float _1120 = _1104 * _1104;
              float _1121 = _1120 * 0.1666666716337204f;
              float _1122 = _1121 * _1119;
              float _1123 = _1110 + _1122;
              _1141 = _1123;
            } else {
              float _1125 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1126 = _913 - (User_000.UserConstant_Z_000[9].z);
              float _1127 = max(9.999999974752427e-07f, _1125);
              float _1128 = _1126 / _1127;
              float _1129 = 1.0f - _1128;
              float _1130 = _1129 * (User_000.UserConstant_Z_000[9].w);
              float _1131 = _1130 + _1128;
              float _1132 = _1129 * _1129;
              float _1133 = _1132 * _1129;
              float _1134 = _1133 - _1129;
              float _1135 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1136 = _1125 * _1125;
              float _1137 = _1136 * _1135;
              float _1138 = _1137 * _1134;
              float _1139 = _1131 + _1138;
              _1141 = _1139;
            }
          }
        }
      }
      float _1142 = saturate(_1141);
      bool _1143 = !(_914 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1143) {
        float _1145 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1146 = _914 / _1145;
        float _1147 = _1146 * (User_000.UserConstant_Z_000[4].y);
        float _1148 = _1146 * _1146;
        float _1149 = _1148 * _1146;
        float _1150 = _1149 - _1146;
        float _1151 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1152 = _1145 * _1145;
        float _1153 = _1152 * _1151;
        float _1154 = _1153 * _1150;
        float _1155 = _1154 + _1147;
        _1245 = _1155;
      } else {
        bool _1157 = !(_914 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1157) {
          float _1159 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1160 = max(9.999999974752427e-07f, _1159);
          float _1161 = _914 - (User_000.UserConstant_Z_000[4].x);
          float _1162 = _1161 / _1160;
          float _1163 = 1.0f - _1162;
          float _1164 = _1163 * (User_000.UserConstant_Z_000[4].y);
          float _1165 = _1162 * (User_000.UserConstant_Z_000[4].w);
          float _1166 = _1164 + _1165;
          float _1167 = _1163 * _1163;
          float _1168 = _1167 * _1163;
          float _1169 = _1168 - _1163;
          float _1170 = _1169 * (User_000.UserConstant_Z_000[10].x);
          float _1171 = _1162 * _1162;
          float _1172 = _1171 * _1162;
          float _1173 = _1172 - _1162;
          float _1174 = _1173 * (User_000.UserConstant_Z_000[10].y);
          float _1175 = _1170 + _1174;
          float _1176 = _1160 * _1160;
          float _1177 = _1176 * 0.1666666716337204f;
          float _1178 = _1177 * _1175;
          float _1179 = _1166 + _1178;
          _1245 = _1179;
        } else {
          bool _1181 = !(_914 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1181) {
            float _1183 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1184 = max(9.999999974752427e-07f, _1183);
            float _1185 = _914 - (User_000.UserConstant_Z_000[4].z);
            float _1186 = _1185 / _1184;
            float _1187 = 1.0f - _1186;
            float _1188 = _1187 * (User_000.UserConstant_Z_000[4].w);
            float _1189 = _1186 * (User_000.UserConstant_Z_000[9].y);
            float _1190 = _1188 + _1189;
            float _1191 = _1187 * _1187;
            float _1192 = _1191 * _1187;
            float _1193 = _1192 - _1187;
            float _1194 = _1193 * (User_000.UserConstant_Z_000[10].y);
            float _1195 = _1186 * _1186;
            float _1196 = _1195 * _1186;
            float _1197 = _1196 - _1186;
            float _1198 = _1197 * (User_000.UserConstant_Z_000[10].z);
            float _1199 = _1194 + _1198;
            float _1200 = _1184 * _1184;
            float _1201 = _1200 * 0.1666666716337204f;
            float _1202 = _1201 * _1199;
            float _1203 = _1190 + _1202;
            _1245 = _1203;
          } else {
            bool _1205 = !(_914 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1205) {
              float _1207 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1208 = max(9.999999974752427e-07f, _1207);
              float _1209 = _914 - (User_000.UserConstant_Z_000[9].x);
              float _1210 = _1209 / _1208;
              float _1211 = 1.0f - _1210;
              float _1212 = _1211 * (User_000.UserConstant_Z_000[9].y);
              float _1213 = _1210 * (User_000.UserConstant_Z_000[9].w);
              float _1214 = _1212 + _1213;
              float _1215 = _1211 * _1211;
              float _1216 = _1215 * _1211;
              float _1217 = _1216 - _1211;
              float _1218 = _1217 * (User_000.UserConstant_Z_000[10].z);
              float _1219 = _1210 * _1210;
              float _1220 = _1219 * _1210;
              float _1221 = _1220 - _1210;
              float _1222 = _1221 * (User_000.UserConstant_Z_000[10].w);
              float _1223 = _1218 + _1222;
              float _1224 = _1208 * _1208;
              float _1225 = _1224 * 0.1666666716337204f;
              float _1226 = _1225 * _1223;
              float _1227 = _1214 + _1226;
              _1245 = _1227;
            } else {
              float _1229 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1230 = _914 - (User_000.UserConstant_Z_000[9].z);
              float _1231 = max(9.999999974752427e-07f, _1229);
              float _1232 = _1230 / _1231;
              float _1233 = 1.0f - _1232;
              float _1234 = _1233 * (User_000.UserConstant_Z_000[9].w);
              float _1235 = _1234 + _1232;
              float _1236 = _1233 * _1233;
              float _1237 = _1236 * _1233;
              float _1238 = _1237 - _1233;
              float _1239 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1240 = _1229 * _1229;
              float _1241 = _1240 * _1239;
              float _1242 = _1241 * _1238;
              float _1243 = _1235 + _1242;
              _1245 = _1243;
            }
          }
        }
      }
      float _1246 = saturate(_1245);
      _1248 = _1038;
      _1249 = _1142;
      _1250 = _1246;
    } else {
      _1248 = _912;
      _1249 = _913;
      _1250 = _914;
    }
    int _1251 = _916 & 2;
    bool _1252 = (_1251 == 0);
    if (!_1252) {
      float _1254 = sqrt(_1248);
      float _1255 = sqrt(_1249);
      float _1256 = sqrt(_1250);
      float _1257 = dot(float3(_1254, _1255, _1256), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1258 = 1.0f - _1257;
      float _1259 = saturate(_1258);
      _1261 = _1259;
    } else {
      _1261 = 1.0f;
    }
    int _1262 = _916 & 8;
    bool _1263 = (_1262 == 0);
    if (_1263) {
      int _1265 = _916 & 4;
      bool _1266 = (_1265 == 0);
      if (!_1266) {
        int _1268 = _916 & 16;
        bool _1269 = (_1268 == 0);
        if (!_1269) {
          float _1273 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1274 = _1273 + 0.5f;
          bool _1275 = (_1274 < 0.5f);
          float _1276 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1277 = select(_1275, (User_000.UserConstant_Z_000[5].x), _1276);
          bool _1278 = (_1249 < _1250);
          float _1279 = select(_1278, _1250, _1249);
          float _1280 = select(_1278, _1249, _1250);
          bool _1281 = (_1248 < _1279);
          float _1282 = select(_1281, _1279, _1248);
          float _1283 = select(_1281, _1248, _1279);
          float _1284 = min(_1283, _1280);
          float _1285 = _1282 - _1284;
          float _1286 = _1282 + 1.000000013351432e-10f;
          float _1287 = _1285 / _1286;
          float _1289 = _1287 - (User_000.UserConstant_Z_000[5].y);
          float _1290 = saturate(_1289);
          float _1291 = max(_1290, 9.999999974752427e-07f);
          float _1292 = log2(_1291);
          float _1293 = _1292 * _1277;
          float _1294 = exp2(_1293);
          float _1295 = 2.0f - _1294;
          float _1297 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1298 = saturate(_1297);
          float _1299 = max(_1298, _1295);
          float _1300 = dot(float3(_1248, _1249, _1250), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1301 = _1248 - _1300;
          float _1302 = _1249 - _1300;
          float _1303 = _1250 - _1300;
          float _1304 = _1301 * _1299;
          float _1305 = _1302 * _1299;
          float _1306 = _1303 * _1299;
          float _1307 = _1300 - _1248;
          float _1308 = _1307 + _1304;
          float _1309 = _1300 - _1249;
          float _1310 = _1309 + _1305;
          float _1311 = _1300 - _1250;
          float _1312 = _1311 + _1306;
          float _1313 = _1308 * _1261;
          float _1314 = _1310 * _1261;
          float _1315 = _1312 * _1261;
          float _1316 = _1313 + _1248;
          float _1317 = _1314 + _1249;
          float _1318 = _1315 + _1250;
          _1435 = _1316;
          _1436 = _1317;
          _1437 = _1318;
        } else {
          bool _1320 = (_1261 == 0.0f);
          if (!_1320) {
            float _1324 = abs(User_000.UserConstant_Z_000[5].x);
            float _1325 = saturate(_1324);
            uint2 _1327; t15.GetDimensions(_1327.x, _1327.y);
            float _1330 = float((uint)_1327.y);
            int _1331 = _916 & 32;
            bool _1332 = (_1331 == 0);
            float _1333 = _1330 + -1.0f;
            if (!_1332) {
              float _1335 = 1.0f / _1333;
              uint _1336 = uint(SV_Position.x);
              uint _1337 = uint(SV_Position.y);
              int _1338 = _1336 & 63;
              int _1339 = _1337 & 63;
              float4 _1341 = t6.Load(int4(_1338, _1339, 0, 0));
              float _1344 = _1341.x + -0.5f;
              float _1345 = _1248 * 13.999999046325684f;
              float _1346 = _1249 * 13.999999046325684f;
              float _1347 = _1250 * 13.999999046325684f;
              float _1348 = saturate(_1345);
              float _1349 = saturate(_1346);
              float _1350 = saturate(_1347);
              float _1351 = _1248 + -0.9285714030265808f;
              float _1352 = _1249 + -0.9285714030265808f;
              float _1353 = _1250 + -0.9285714030265808f;
              float _1354 = _1351 * 13.999999046325684f;
              float _1355 = _1352 * 13.999999046325684f;
              float _1356 = _1353 * 13.999999046325684f;
              float _1357 = saturate(_1354);
              float _1358 = saturate(_1355);
              float _1359 = saturate(_1356);
              float _1360 = 1.0f - _1357;
              float _1361 = 1.0f - _1358;
              float _1362 = 1.0f - _1359;
              float _1363 = min(_1348, _1360);
              float _1364 = min(_1349, _1361);
              float _1365 = min(_1350, _1362);
              float _1366 = _1341.y + -0.5f;
              float _1367 = _1363 * _1366;
              float _1368 = _1364 * _1366;
              float _1369 = _1365 * _1366;
              float _1370 = _1367 + _1344;
              float _1371 = _1368 + _1344;
              float _1372 = _1369 + _1344;
              float _1373 = _1370 * _1335;
              float _1374 = _1371 * _1335;
              float _1375 = _1372 * _1335;
              float _1376 = _1373 + _1248;
              float _1377 = _1374 + _1249;
              float _1378 = _1375 + _1250;
              float _1379 = saturate(_1376);
              float _1380 = saturate(_1377);
              float _1381 = saturate(_1378);
              float _1382 = saturate(_1379);
              float _1383 = saturate(_1380);
              float _1384 = saturate(_1381);
              _1386 = _1382;
              _1387 = _1383;
              _1388 = _1384;
            } else {
              _1386 = _1248;
              _1387 = _1249;
              _1388 = _1250;
            }
            float _1389 = float((uint)_1327.x);
            float _1390 = _1333 / _1389;
            float _1391 = _1390 * _1386;
            float _1392 = 0.5f / _1389;
            float _1393 = _1391 + _1392;
            float _1394 = _1333 / _1330;
            float _1395 = _1394 * _1387;
            float _1396 = 0.5f / _1330;
            float _1397 = _1395 + _1396;
            float _1398 = _1388 * _1333;
            float _1399 = floor(_1398);
            float _1400 = frac(_1398);
            float _1401 = _1399 / _1330;
            float _1402 = _1401 + _1393;
            float _1403 = _1399 + 1.0f;
            float _1404 = _1403 / _1330;
            float _1405 = _1404 + _1393;
            float4 _1407 = t15.Sample(s1, float2(_1402, _1397));
            float4 _1411 = t15.Sample(s1, float2(_1405, _1397));
            float _1415 = _1411.x - _1407.x;
            float _1416 = _1411.y - _1407.y;
            float _1417 = _1411.z - _1407.z;
            float _1418 = _1415 * _1400;
            float _1419 = _1416 * _1400;
            float _1420 = _1417 * _1400;
            float _1421 = _1325 * _1261;
            float _1422 = _1407.x - _1248;
            float _1423 = _1422 + _1418;
            float _1424 = _1407.y - _1249;
            float _1425 = _1424 + _1419;
            float _1426 = _1407.z - _1250;
            float _1427 = _1426 + _1420;
            float _1428 = _1423 * _1421;
            float _1429 = _1425 * _1421;
            float _1430 = _1427 * _1421;
            float _1431 = _1428 + _1248;
            float _1432 = _1429 + _1249;
            float _1433 = _1430 + _1250;
            _1435 = _1431;
            _1436 = _1432;
            _1437 = _1433;
          } else {
            _1435 = _1248;
            _1436 = _1249;
            _1437 = _1250;
          }
        }
      } else {
        _1435 = _1248;
        _1436 = _1249;
        _1437 = _1250;
      }
    } else {
      _1435 = _1261;
      _1436 = _1261;
      _1437 = _1261;
    }
    float _1438 = _1435 * 13.450128555297852f;
    float _1439 = _1436 * 13.450128555297852f;
    float _1440 = _1437 * 13.450128555297852f;
    float _1441 = exp2(_1438);
    float _1442 = exp2(_1439);
    float _1443 = exp2(_1440);
    _1445 = _1441;
    _1446 = _1442;
    _1447 = _1443;
  } else {
    _1445 = _902;
    _1446 = _903;
    _1447 = _904;
  }
  float _1448 = _1447 + -1.0f;
  float _1449 = _1446 + -1.0f;
  float _1450 = _1445 + -1.0f;
  float _1451 = _1448 * 0.0029786902014166117f;
  float _1452 = _1449 * 0.0029786902014166117f;
  float _1453 = _1450 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_872, _874, _876) * 0.0029786902014166117f,
      float3(
          (User_000.UserConstant_Z_000[8].x) * _1453,
          (User_000.UserConstant_Z_000[8].y) * _1452,
          _1451 * (User_000.UserConstant_Z_000[8].z)),
      User_000.UserConstant_Z_000[8].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(apt_scaled_lut_output, SV_Position.xy);
  float _1460 = apt_scaled_lut_output.x;
  float _1461 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1462 = log2(_1460);
  float _1463 = _1461 * _1462;
  float _1464 = exp2(_1463);
  float _1465 = _1464 + -1.0f;
  float _1466 = _1460 + -1.0f;
  float _1467 = _1465 / _1466;
  bool _1468 = !(_1460 == 1.0f);
  float _1469 = _1467 + -1.0f;
  float _1470 = _1469 / _1467;
  float _1471 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1472 = _1471 / _1461;
  float _1473 = select(_1468, _1470, _1472);
  float _1474 = apt_scaled_lut_output.y;
  float _1475 = log2(_1474);
  float _1476 = _1475 * _1461;
  float _1477 = exp2(_1476);
  float _1478 = _1477 + -1.0f;
  float _1479 = _1474 + -1.0f;
  float _1480 = _1478 / _1479;
  bool _1481 = !(_1474 == 1.0f);
  float _1482 = _1480 + -1.0f;
  float _1483 = _1482 / _1480;
  float _1484 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1485 = _1484 / _1461;
  float _1486 = select(_1481, _1483, _1485);
  float _1487 = apt_scaled_lut_output.z;
  float _1488 = log2(_1487);
  float _1489 = _1488 * _1461;
  float _1490 = exp2(_1489);
  float _1491 = _1490 + -1.0f;
  float _1492 = _1487 + -1.0f;
  float _1493 = _1491 / _1492;
  bool _1494 = !(_1487 == 1.0f);
  float _1495 = _1493 + -1.0f;
  float _1496 = _1495 / _1493;
  float _1497 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1498 = _1497 / _1461;
  float _1499 = select(_1494, _1496, _1498);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1460, _1474, _1487),
      float3(_1473, _1486, _1499),
      true);
  float _1500 = apt_post_process_output.x;
  float _1501 = apt_post_process_output.y;
  float _1502 = apt_post_process_output.z;
  float _1503 = log2(_1500);
  float _1504 = log2(_1501);
  float _1505 = log2(_1502);
  float _1506 = _1503 * 0.4166666567325592f;
  float _1507 = _1504 * 0.4166666567325592f;
  float _1508 = _1505 * 0.4166666567325592f;
  float _1509 = exp2(_1506);
  float _1510 = exp2(_1507);
  float _1511 = exp2(_1508);
  float _1512 = _1509 * 1.0549999475479126f;
  float _1513 = _1510 * 1.0549999475479126f;
  float _1514 = _1511 * 1.0549999475479126f;
  float _1515 = _1512 + -0.054999999701976776f;
  float _1516 = _1513 + -0.054999999701976776f;
  float _1517 = _1514 + -0.054999999701976776f;
  float _1518 = _1500 * 12.920000076293945f;
  float _1519 = _1501 * 12.920000076293945f;
  float _1520 = _1502 * 12.920000076293945f;
  bool _1521 = (_1500 <= 0.0031308000907301903f);
  bool _1522 = (_1501 <= 0.0031308000907301903f);
  bool _1523 = (_1502 <= 0.0031308000907301903f);
  float _1524 = select(_1521, _1518, _1515);
  float _1525 = select(_1522, _1519, _1516);
  float _1526 = select(_1523, _1520, _1517);
  float _1527 = log2(_1524);
  float _1528 = log2(_1525);
  float _1529 = log2(_1526);
  float _1530 = floor(_1527);
  float _1531 = floor(_1528);
  float _1532 = floor(_1529);
  float _1533 = _1530 + -6.0f;
  float _1534 = _1531 + -6.0f;
  float _1535 = _1532 + -5.0f;
  float _1536 = exp2(_1533);
  float _1537 = exp2(_1534);
  float _1538 = exp2(_1535);
  bool _1539 = (_1524 <= 0.0f);
  bool _1540 = (_1525 <= 0.0f);
  bool _1541 = (_1526 <= 0.0f);
  float _1542 = select(_1539, 0.0f, _1536);
  float _1543 = select(_1540, 0.0f, _1537);
  float _1544 = select(_1541, 0.0f, _1538);
  int _1547 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1548 = uint(SV_Position.x);
  uint _1549 = uint(SV_Position.y);
  int _1550 = _1548 & 63;
  int _1551 = _1549 & 63;
  float4 _1553 = t1.Load(int4(_1550, _1551, _1547, 0));
  float4 _1556 = t6.Load(int4(_1550, _1551, _1547, 0));
  float _1559 = _1553.x * _1542;
  float _1560 = _1556.x * _1543;
  float _1561 = _1556.y * _1544;
  float _1562 = _1559 + _1524;
  float _1563 = _1560 + _1525;
  float _1564 = _1561 + _1526;
  SV_Target.x = _1562;
  SV_Target.y = _1563;
  SV_Target.z = _1564;
  SV_Target.w = _378;
  return SV_Target;
}
