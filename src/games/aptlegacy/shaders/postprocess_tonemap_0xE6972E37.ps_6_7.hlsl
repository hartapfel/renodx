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

Texture2D<float4> t9 : register(t9);

Texture2D<float4> t12 : register(t12);

Texture2D<float4> t14 : register(t14);

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

SamplerState s6 : register(s6);

SamplerState s0 : register(s0);

SamplerState s2 : register(s2);

SamplerState s3 : register(s3);

SamplerState s4 : register(s4);

SamplerState s5 : register(s5);

SamplerState s7 : register(s7);

SamplerState s8 : register(s8);

SamplerState s9 : register(s9);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _40 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _46 = t16.Sample(s1, float2(TEXCOORD.z, TEXCOORD.w));
  float _48 = _46.y * 0.10000000149011612f;
  float _49 = _48 + _40.y;
  float _50 = _46.y * 0.5f;
  float _51 = _50 + _40.z;
  float _52 = exp2(_51);
  float _53 = _52 + -1.0f;
  float _56 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _53;
  float _57 = _56 + 1.0f;
  float _58 = log2(_57);
  float _59 = _40.x + TEXCOORD.z;
  float _60 = _49 + TEXCOORD.w;
  float _61 = _40.x + TEXCOORD.x;
  float _62 = _49 + TEXCOORD.y;
  float _63 = _58 + 1.0f;
  float _64 = log2(_63);
  float4 _67 = t0.SampleLevel(s1, float2(_59, _60), _64);
  bool _72 = (_64 > 0.0f);
  float _377;
  float _378;
  float _379;
  float _380;
  float _427;
  float _428;
  float _429;
  float _434;
  float _435;
  float _436;
  float _465;
  float _550;
  float _587;
  float _777;
  float _816;
  float _817;
  float _818;
  float _847;
  float _848;
  float _849;
  float _854;
  float _855;
  float _856;
  float _1002;
  float _1074;
  float _1083;
  float _1092;
  float _1140;
  float _1141;
  float _1142;
  [branch]
  if (_72) {
    float _74 = floor(_64);
    int _75 = int(_74);
    uint2 _76; t0.GetDimensions(_76.x, _76.y);
    int _79 = _75 & 31;
    int _80 = (uint)(_76.x) >> _79;
    float _81 = float((uint)_80);
    int _82 = (uint)(_76.y) >> _79;
    float _83 = float((uint)_82);
    float _84 = 1.0f / _81;
    float _85 = 1.0f / _83;
    float _86 = _81 * _59;
    float _87 = _83 * _60;
    float _88 = _86 + -0.5f;
    float _89 = _87 + -0.5f;
    float _90 = frac(_88);
    float _91 = frac(_89);
    float _92 = floor(_88);
    float _93 = floor(_89);
    float _94 = 1.0f - _90;
    float _95 = 2.0f - _90;
    float _96 = 3.0f - _90;
    float _97 = _94 * _94;
    float _98 = _95 * _95;
    float _99 = _96 * _96;
    float _100 = _97 * _94;
    float _101 = _98 * _95;
    float _102 = _99 * _96;
    float _103 = _100 * 4.0f;
    float _104 = _101 - _103;
    float _105 = _101 * 4.0f;
    float _106 = _100 * 6.0f;
    float _107 = 6.0f - _100;
    float _108 = _107 - _104;
    float _109 = _105 - _102;
    float _110 = _109 - _106;
    float _111 = _110 + _108;
    float _112 = _104 * 0.1666666716337204f;
    float _113 = _111 * 0.1666666716337204f;
    float _114 = 1.0f - _91;
    float _115 = 2.0f - _91;
    float _116 = 3.0f - _91;
    float _117 = _114 * _114;
    float _118 = _115 * _115;
    float _119 = _116 * _116;
    float _120 = _117 * _114;
    float _121 = _118 * _115;
    float _122 = _119 * _116;
    float _123 = _120 * 4.0f;
    float _124 = _121 - _123;
    float _125 = _121 * 4.0f;
    float _126 = _120 * 6.0f;
    float _127 = 6.0f - _120;
    float _128 = _127 - _124;
    float _129 = _125 - _122;
    float _130 = _129 - _126;
    float _131 = _130 + _128;
    float _132 = _124 * 0.1666666716337204f;
    float _133 = _131 * 0.1666666716337204f;
    float _134 = _92 + -0.5f;
    float _135 = _92 + 1.5f;
    float _136 = _93 + -0.5f;
    float _137 = _93 + 1.5f;
    float _138 = _104 + _100;
    float _139 = _138 * 0.1666666716337204f;
    float _140 = _108 * 0.1666666716337204f;
    float _141 = _124 + _120;
    float _142 = _141 * 0.1666666716337204f;
    float _143 = _128 * 0.1666666716337204f;
    float _144 = _112 / _139;
    float _145 = _113 / _140;
    float _146 = _132 / _142;
    float _147 = _133 / _143;
    float _148 = _134 + _144;
    float _149 = _135 + _145;
    float _150 = _136 + _146;
    float _151 = _137 + _147;
    float _152 = _148 * _84;
    float _153 = _149 * _84;
    float _154 = _150 * _85;
    float _155 = _151 * _85;
    float _156 = float((int)(_75));
    float4 _158 = t0.SampleLevel(s0, float2(_152, _154), _156);
    float4 _163 = t0.SampleLevel(s0, float2(_153, _154), _156);
    float4 _168 = t0.SampleLevel(s0, float2(_152, _155), _156);
    float4 _173 = t0.SampleLevel(s0, float2(_153, _155), _156);
    float _178 = _158.x - _163.x;
    float _179 = _158.y - _163.y;
    float _180 = _158.z - _163.z;
    float _181 = _158.w - _163.w;
    float _182 = _178 * _139;
    float _183 = _179 * _139;
    float _184 = _180 * _139;
    float _185 = _181 * _139;
    float _186 = _182 + _163.x;
    float _187 = _183 + _163.y;
    float _188 = _184 + _163.z;
    float _189 = _185 + _163.w;
    float _190 = _168.x - _173.x;
    float _191 = _168.y - _173.y;
    float _192 = _168.z - _173.z;
    float _193 = _168.w - _173.w;
    float _194 = _190 * _139;
    float _195 = _191 * _139;
    float _196 = _192 * _139;
    float _197 = _193 * _139;
    float _198 = _194 + _173.x;
    float _199 = _195 + _173.y;
    float _200 = _196 + _173.z;
    float _201 = _197 + _173.w;
    float _202 = _186 - _198;
    float _203 = _187 - _199;
    float _204 = _188 - _200;
    float _205 = _189 - _201;
    float _206 = _202 * _142;
    float _207 = _203 * _142;
    float _208 = _204 * _142;
    float _209 = _205 * _142;
    float _210 = _206 + _198;
    float _211 = _207 + _199;
    float _212 = _208 + _200;
    float _213 = _209 + _201;
    float _214 = ceil(_64);
    int _215 = int(_214);
    int _216 = _215 & 31;
    int _217 = (uint)(_76.x) >> _216;
    float _218 = float((uint)_217);
    int _219 = (uint)(_76.y) >> _216;
    float _220 = float((uint)_219);
    float _221 = 1.0f / _218;
    float _222 = 1.0f / _220;
    float _223 = _218 * _59;
    float _224 = _220 * _60;
    float _225 = _223 + -0.5f;
    float _226 = _224 + -0.5f;
    float _227 = frac(_225);
    float _228 = frac(_226);
    float _229 = floor(_225);
    float _230 = floor(_226);
    float _231 = 1.0f - _227;
    float _232 = 2.0f - _227;
    float _233 = 3.0f - _227;
    float _234 = _231 * _231;
    float _235 = _232 * _232;
    float _236 = _233 * _233;
    float _237 = _234 * _231;
    float _238 = _235 * _232;
    float _239 = _236 * _233;
    float _240 = _237 * 4.0f;
    float _241 = _238 - _240;
    float _242 = _238 * 4.0f;
    float _243 = _237 * 6.0f;
    float _244 = 6.0f - _237;
    float _245 = _244 - _241;
    float _246 = _242 - _239;
    float _247 = _246 - _243;
    float _248 = _247 + _245;
    float _249 = _241 * 0.1666666716337204f;
    float _250 = _248 * 0.1666666716337204f;
    float _251 = 1.0f - _228;
    float _252 = 2.0f - _228;
    float _253 = 3.0f - _228;
    float _254 = _251 * _251;
    float _255 = _252 * _252;
    float _256 = _253 * _253;
    float _257 = _254 * _251;
    float _258 = _255 * _252;
    float _259 = _256 * _253;
    float _260 = _257 * 4.0f;
    float _261 = _258 - _260;
    float _262 = _258 * 4.0f;
    float _263 = _257 * 6.0f;
    float _264 = 6.0f - _257;
    float _265 = _264 - _261;
    float _266 = _262 - _259;
    float _267 = _266 - _263;
    float _268 = _267 + _265;
    float _269 = _261 * 0.1666666716337204f;
    float _270 = _268 * 0.1666666716337204f;
    float _271 = _229 + -0.5f;
    float _272 = _229 + 1.5f;
    float _273 = _230 + -0.5f;
    float _274 = _230 + 1.5f;
    float _275 = _241 + _237;
    float _276 = _275 * 0.1666666716337204f;
    float _277 = _245 * 0.1666666716337204f;
    float _278 = _261 + _257;
    float _279 = _278 * 0.1666666716337204f;
    float _280 = _265 * 0.1666666716337204f;
    float _281 = _249 / _276;
    float _282 = _250 / _277;
    float _283 = _269 / _279;
    float _284 = _270 / _280;
    float _285 = _271 + _281;
    float _286 = _272 + _282;
    float _287 = _273 + _283;
    float _288 = _274 + _284;
    float _289 = _285 * _221;
    float _290 = _286 * _221;
    float _291 = _287 * _222;
    float _292 = _288 * _222;
    float _293 = float((int)(_215));
    float4 _294 = t0.SampleLevel(s0, float2(_289, _291), _293);
    float4 _299 = t0.SampleLevel(s0, float2(_290, _291), _293);
    float4 _304 = t0.SampleLevel(s0, float2(_289, _292), _293);
    float4 _309 = t0.SampleLevel(s0, float2(_290, _292), _293);
    float _314 = _294.x - _299.x;
    float _315 = _294.y - _299.y;
    float _316 = _294.z - _299.z;
    float _317 = _294.w - _299.w;
    float _318 = _314 * _276;
    float _319 = _315 * _276;
    float _320 = _316 * _276;
    float _321 = _317 * _276;
    float _322 = _318 + _299.x;
    float _323 = _319 + _299.y;
    float _324 = _320 + _299.z;
    float _325 = _321 + _299.w;
    float _326 = _304.x - _309.x;
    float _327 = _304.y - _309.y;
    float _328 = _304.z - _309.z;
    float _329 = _304.w - _309.w;
    float _330 = _326 * _276;
    float _331 = _327 * _276;
    float _332 = _328 * _276;
    float _333 = _329 * _276;
    float _334 = _330 + _309.x;
    float _335 = _331 + _309.y;
    float _336 = _332 + _309.z;
    float _337 = _333 + _309.w;
    float _338 = _322 - _334;
    float _339 = _323 - _335;
    float _340 = _324 - _336;
    float _341 = _325 - _337;
    float _342 = _338 * _279;
    float _343 = _339 * _279;
    float _344 = _340 * _279;
    float _345 = _341 * _279;
    float _346 = frac(_64);
    float _347 = _334 - _210;
    float _348 = _347 + _342;
    float _349 = _335 - _211;
    float _350 = _349 + _343;
    float _351 = _336 - _212;
    float _352 = _351 + _344;
    float _353 = _337 - _213;
    float _354 = _353 + _345;
    float _355 = _348 * _346;
    float _356 = _350 * _346;
    float _357 = _352 * _346;
    float _358 = _354 * _346;
    float _359 = saturate(_64);
    float _360 = _210 - _67.x;
    float _361 = _360 + _355;
    float _362 = _211 - _67.y;
    float _363 = _362 + _356;
    float _364 = _212 - _67.z;
    float _365 = _364 + _357;
    float _366 = _213 - _67.w;
    float _367 = _366 + _358;
    float _368 = _361 * _359;
    float _369 = _363 * _359;
    float _370 = _365 * _359;
    float _371 = _367 * _359;
    float _372 = _368 + _67.x;
    float _373 = _369 + _67.y;
    float _374 = _370 + _67.z;
    float _375 = _371 + _67.w;
    _377 = _372;
    _378 = _373;
    _379 = _374;
    _380 = _375;
  } else {
    _377 = _67.x;
    _378 = _67.y;
    _379 = _67.z;
    _380 = _67.w;
  }
  float _381 = max(_377, 0.0f);
  float _382 = max(_378, 0.0f);
  float _383 = max(_379, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_381, _382, _383),
      float3(_381, _382, _383),
      float2(_59, _60),
      t0,
      s1,
      _64);
  _381 = renodx_chromatic_aberration_input.x;
  _382 = renodx_chromatic_aberration_input.y;
  _383 = renodx_chromatic_aberration_input.z;
  float4 _385 = t12.SampleLevel(s1, float2(_59, _60), 0.0f);
  float4 _391 = t8.Sample(s8, float2(_61, _62));
  int _397 = asint((User_000.UserConstant_Z_000[3].z));
  bool _398 = ((int)_397 > (int)0);
  if (!_398) {
    bool _402 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _406 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _391.x;
    float _407 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _391.y;
    float _408 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _391.z;
    float _409 = _406 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _410 = _407 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _411 = _408 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_402) {
      float _413 = _409 * _385.x;
      float _414 = _410 * _385.y;
      float _415 = _411 * _385.z;
      _427 = _413;
      _428 = _414;
      _429 = _415;
    } else {
      float _417 = saturate(_409);
      float _418 = saturate(_410);
      float _419 = saturate(_411);
      float _420 = _385.x - _381;
      float _421 = _385.y - _382;
      float _422 = _385.z - _383;
      float _423 = _417 * _420;
      float _424 = _418 * _421;
      float _425 = _419 * _422;
      _427 = _423;
      _428 = _424;
      _429 = _425;
    }
    float _430 = _427 + _381;
    float _431 = _428 + _382;
    float _432 = _429 + _383;
    _434 = _430;
    _435 = _431;
    _436 = _432;
  } else {
    _434 = _381;
    _435 = _382;
    _436 = _383;
  }
  [branch]
  if (_398) {
    bool _441 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_441) {
      float _443 = _40.x + TEXCOORD.x;
      float _444 = _49 + TEXCOORD.y;
      float4 _447 = t2.SampleLevel(s2, float2(_443, _444), 0.0f);
      bool _451 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_451) {
        float4 _454 = t7.Load(int3(0, 0, 0));
        float _459 = _454.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _460 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _459;
        _465 = _460;
      } else {
        _465 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _469 = _447.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _470 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _469;
      float _472 = _465 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _473 = _472 + _465;
      float _474 = _465 - _472;
      float _475 = max(_470, _474);
      float _476 = min(_475, _473);
      float _479 = _470 - _476;
      float _480 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _479;
      float _482 = _476 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _483 = _482 * _470;
      float _484 = _480 / _483;
      float _485 = min(_484, 0.0f);
      float _487 = _472 + 1.0f;
      float _488 = 1.0f / _487;
      float _489 = _485 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _490 = max(0.0f, _484);
      float _493 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _490;
      float _494 = _493 + _489;
      float _495 = _494 * _488;
      float _496 = max(_495, -1.0f);
      float _497 = min(_496, 1.0f);
      float _498 = max(_497, -0.30000001192092896f);
      float _499 = min(_498, 1.0f);
      float _501 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _502 = _499 * _501;
      float _503 = _443 + -0.5f;
      float _504 = _444 + -0.5f;
      float _505 = _503 * _503;
      float _506 = _504 * _504;
      float _507 = _506 + _505;
      float _508 = sqrt(_507);
      float _509 = log2(_508);
      float _510 = _509 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _511 = exp2(_510);
      float _512 = _511 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _513 = dot(float2(_503, _504), float2(_503, _504));
      float _514 = rsqrt(_513);
      float _515 = _514 * _503;
      float _516 = _514 * _504;
      float _517 = abs(_502);
      float _521 = _512 * _517;
      float _522 = -0.0f - _521;
      float _523 = (User_000.UserConstant_Z_000[2].x) * _515;
      float _524 = _523 * _522;
      float _525 = (User_000.UserConstant_Z_000[2].y) * _516;
      float _526 = _525 * _522;
      float _527 = _517 * _512;
      float _528 = _523 * _527;
      float _529 = _525 * _527;
      float _530 = _524 + _443;
      float _531 = _526 + _444;
      float _532 = _528 + _443;
      float _533 = _529 + _444;
      float _534 = max(_64, 0.0f);
      float4 _535 = t0.SampleLevel(s1, float2(_530, _531), _534);
      float4 _537 = t0.SampleLevel(s1, float2(_532, _533), _534);
      float4 _539 = t2.SampleLevel(s2, float2(_530, _531), 0.0f);
      if (_451) {
        float4 _543 = t7.Load(int3(0, 0, 0));
        float _545 = _543.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _546 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _545;
        _550 = _546;
      } else {
        _550 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _551 = _539.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _552 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _551;
      float _553 = _550 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _554 = _553 + _550;
      float _555 = _550 - _553;
      float _556 = max(_552, _555);
      float _557 = min(_556, _554);
      float _558 = _552 - _557;
      float _559 = _558 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _560 = _557 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _561 = _560 * _552;
      float _562 = _559 / _561;
      float _563 = min(_562, 0.0f);
      float _564 = _553 + 1.0f;
      float _565 = 1.0f / _564;
      float _566 = _563 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _567 = max(0.0f, _562);
      float _568 = _567 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _569 = _568 + _566;
      float _570 = _569 * _565;
      float _571 = max(_570, -1.0f);
      float _572 = min(_571, 1.0f);
      float _573 = max(_572, -0.30000001192092896f);
      float _574 = min(_573, 1.0f);
      float _575 = _574 * _501;
      float4 _576 = t2.SampleLevel(s2, float2(_532, _533), 0.0f);
      if (_451) {
        float4 _580 = t7.Load(int3(0, 0, 0));
        float _582 = _580.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _583 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _582;
        _587 = _583;
      } else {
        _587 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _588 = _576.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _589 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _588;
      float _590 = _587 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _591 = _590 + _587;
      float _592 = _587 - _590;
      float _593 = max(_589, _592);
      float _594 = min(_593, _591);
      float _595 = _589 - _594;
      float _596 = _595 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _597 = _594 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _598 = _597 * _589;
      float _599 = _596 / _598;
      float _600 = min(_599, 0.0f);
      float _601 = _590 + 1.0f;
      float _602 = 1.0f / _601;
      float _603 = _600 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _604 = max(0.0f, _599);
      float _605 = _604 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _606 = _605 + _603;
      float _607 = _606 * _602;
      float _608 = max(_607, -1.0f);
      float _609 = min(_608, 1.0f);
      float _610 = max(_609, -0.30000001192092896f);
      float _611 = min(_610, 1.0f);
      float _612 = _611 * _501;
      float _613 = abs(_575);
      float _614 = _613 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _615 = ceil(_614);
      float _616 = saturate(_615);
      float _617 = _535.x - _434;
      float _618 = _616 * _617;
      float _619 = _618 + _434;
      float _620 = abs(_612);
      float _621 = _620 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _622 = ceil(_621);
      float _623 = saturate(_622);
      float _624 = _537.z - _436;
      float _625 = _623 * _624;
      float _626 = _625 + _436;
      _816 = _619;
      _817 = _435;
      _818 = _626;
    } else {
      _816 = _434;
      _817 = _435;
      _818 = _436;
    }
  } else {
    int _629 = asint((User_000.UserConstant_Z_000[3].y));
    bool _630 = ((int)_629 > (int)0);
    if (_630) {
      float _632 = _40.x + TEXCOORD.x;
      float _633 = _49 + TEXCOORD.y;
      float4 _636 = t4.Sample(s4, float2(_632, _633));
      float4 _643 = t5.Sample(s5, float2(_632, _633));
      float _647 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _643.x;
      float _651 = _647 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _652 = _647 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _653 = _651 + _632;
      float _654 = _652 + _633;
      float4 _655 = t4.Sample(s4, float2(_653, _654));
      float4 _657 = t5.Sample(s5, float2(_653, _654));
      float _659 = _657.x * (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _660 = abs(_659);
      float _662 = _660 / (PostProcess_000.PostProcessConstant_Z_000[7].w);
      float _663 = _655.z - _636.z;
      float _664 = _662 * _663;
      float _665 = _636.x - _434;
      float _666 = _636.y - _435;
      float _667 = _636.z - _436;
      float _668 = _667 + _664;
      float _669 = _665 * _636.w;
      float _670 = _666 * _636.w;
      float _671 = _668 * _636.w;
      float _672 = _669 + _434;
      float _673 = _670 + _435;
      float _674 = _671 + _436;
      _816 = _672;
      _817 = _673;
      _818 = _674;
    } else {
      int _677 = asint((User_000.UserConstant_Z_000[3].x));
      bool _678 = ((int)_677 > (int)0);
      [branch]
      if (_678) {
        float4 _682 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _684 = abs(_682.x);
        _777 = _684;
      } else {
        float4 _688 = t2.SampleLevel(s2, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _690 = TEXCOORD.x * 2.0f;
        float _691 = TEXCOORD.y * 2.0f;
        float _692 = _690 + -1.0f;
        float _693 = _691 + -1.0f;
        float _714 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _692;
        float _715 = mad(_693, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _714);
        float _716 = mad(_688.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _715);
        float _717 = _716 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _718 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _692;
        float _719 = mad(_693, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _718);
        float _720 = mad(_688.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _719);
        float _721 = _720 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _722 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _692;
        float _723 = mad(_693, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _722);
        float _724 = mad(_688.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _723);
        float _725 = _724 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _726 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _692;
        float _727 = mad(_693, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _726);
        float _728 = mad(_688.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _727);
        float _729 = _728 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
        float _730 = _717 / _729;
        float _731 = _721 / _729;
        float _732 = _725 / _729;
        float _733 = _730 * _730;
        float _734 = _731 * _731;
        float _735 = _734 + _733;
        float _736 = _732 * _732;
        float _737 = _735 + _736;
        float _738 = sqrt(_737);
        float4 _741 = t5.Sample(s5, float2(TEXCOORD.x, TEXCOORD.y));
        float _747 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _748 = _747 + (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _749 = (PostProcess_000.PostProcessConstant_Z_000[5].x) - _747;
        float _750 = max(_738, _749);
        float _751 = min(_750, _748);
        float _753 = _738 - _751;
        float _754 = _753 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
        float _756 = _751 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _757 = _756 * _738;
        float _758 = _754 / _757;
        float _759 = min(_758, 0.0f);
        float _762 = _747 + 1.0f;
        float _763 = 1.0f / _762;
        float _764 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _759;
        float _765 = max(0.0f, _758);
        float _768 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _765;
        float _769 = _768 + _764;
        float _770 = _769 * _763;
        float _771 = min(_741.x, _770);
        float _772 = abs(_771);
        float _773 = abs(_770);
        float _774 = max(_772, _773);
        float _775 = saturate(_774);
        _777 = _775;
      }
      float _780 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _777;
      float4 _783 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _790 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _780;
      float _791 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _780;
      float _792 = _790 + TEXCOORD.x;
      float _793 = _791 + TEXCOORD.y;
      float4 _794 = t4.Sample(s4, float2(_792, _793));
      float4 _798 = t5.Sample(s5, float2(_792, _793));
      float _800 = abs(_798.x);
      float _801 = _794.z - _783.z;
      float _802 = _800 * _801;
      float _803 = _780 + -1.0f;
      float _804 = saturate(_803);
      float _805 = _783.x - _434;
      float _806 = _783.y - _435;
      float _807 = _783.z - _436;
      float _808 = _807 + _802;
      float _809 = _804 * _805;
      float _810 = _804 * _806;
      float _811 = _808 * _804;
      float _812 = _809 + _434;
      float _813 = _810 + _435;
      float _814 = _811 + _436;
      _816 = _812;
      _817 = _813;
      _818 = _814;
    }
  }
  if (_398) {
    bool _822 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _826 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _391.x;
    float _827 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _391.y;
    float _828 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _391.z;
    float _829 = _826 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _830 = _827 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _831 = _828 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_822) {
      float _833 = _829 * _385.x;
      float _834 = _830 * _385.y;
      float _835 = _831 * _385.z;
      _847 = _833;
      _848 = _834;
      _849 = _835;
    } else {
      float _837 = saturate(_829);
      float _838 = saturate(_830);
      float _839 = saturate(_831);
      float _840 = _385.x - _816;
      float _841 = _385.y - _817;
      float _842 = _385.z - _818;
      float _843 = _837 * _840;
      float _844 = _838 * _841;
      float _845 = _839 * _842;
      _847 = _843;
      _848 = _844;
      _849 = _845;
    }
    float _850 = _847 + _816;
    float _851 = _848 + _817;
    float _852 = _849 + _818;
    _854 = _850;
    _855 = _851;
    _856 = _852;
  } else {
    _854 = _816;
    _855 = _817;
    _856 = _818;
  }
  float4 _860 = t17.Load(int3(0, 0, 0));
  float _866 = _860.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _867 = _866 * _854;
  float _868 = _867 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _869 = _866 * _855;
  float _870 = _869 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _871 = _866 * _856;
  float _872 = _871 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _877 = _59 * 2.0f;
  float _878 = _60 * 2.0f;
  float _879 = _877 + -1.0f;
  float _880 = _878 + -1.0f;
  float _883 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _880;
  float _884 = _879 * _879;
  float _885 = _883 * _883;
  float _886 = _885 + _884;
  float _887 = sqrt(_886);
  float _889 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _887;
  float _891 = _889 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _892 = saturate(_891);
  float _894 = log2(_892);
  float _895 = _894 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _896 = exp2(_895);
  float _897 = _868 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _898 = _870 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _899 = _872 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _900 = _897 - _868;
  float _901 = _898 - _870;
  float _902 = _899 - _872;
  float _903 = _896 * _900;
  float _904 = _896 * _901;
  float _905 = _896 * _902;
  float _906 = _903 + _868;
  float _907 = _904 + _870;
  float _908 = _905 + _872;
  float _912 = _906 * 335.718017578125f;
  float _913 = _907 * 335.718017578125f;
  float _914 = _908 * 335.718017578125f;
  float _915 = _912 + 1.0f;
  float _916 = _913 + 1.0f;
  float _917 = _914 + 1.0f;
  float _918 = log2(_915);
  float _919 = log2(_916);
  float _920 = log2(_917);
  float _921 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _922 = _921 * _918;
  float _923 = _921 * _919;
  float _924 = _920 * _921;
  float _925 = _922 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _926 = _923 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _927 = _924 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _930 = t3.Sample(s3, float3(_925, _926, _927));
  float _934 = _930.x * 13.450128555297852f;
  float _935 = _930.y * 13.450128555297852f;
  float _936 = _930.z * 13.450128555297852f;
  float _937 = exp2(_934);
  float _938 = exp2(_935);
  float _939 = exp2(_936);
  float _940 = _937 + -1.0f;
  float _941 = _938 + -1.0f;
  float _942 = _939 + -1.0f;
  float _943 = _940 * 0.0029786902014166117f;
  float _944 = _941 * 0.0029786902014166117f;
  float _945 = _942 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_912 * 0.0029786902014166117f, _913 * 0.0029786902014166117f, _914 * 0.0029786902014166117f),
      float3(_943 * (User_000.UserConstant_Z_000[4].x), _944 * (User_000.UserConstant_Z_000[4].y), _945 * (User_000.UserConstant_Z_000[4].z)),
      User_000.UserConstant_Z_000[4].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(apt_scaled_lut_output, SV_Position.xy);
  float _950 = apt_scaled_lut_output.x;
  float _951 = apt_scaled_lut_output.y;
  float _952 = apt_scaled_lut_output.z;
  float _958 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _959 = _958 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _960 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _961 = _960 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _964 = _959 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _965 = _961 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _968 = t9.Sample(s9, float2(_964, _965));
  float _972 = dot(float3(_950, _951, _952), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _975 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _978 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _979 = select(_975, _978, 0);
  float _980 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _981 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _982 = uint(_980);
  uint _983 = uint(_981);
  int _984 = _982 & 63;
  int _985 = _983 & 63;
  float4 _987 = t6.Load(int4(_984, _985, _979, 0));
  bool _989 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_989) {
    float _991 = _980 * 0.015625f;
    float _992 = _981 * 0.015625f;
    float _993 = float((uint)_978);
    float _994 = select(_975, _993, 0.0f);
    float4 _996 = t6.SampleLevel(s6, float3(_991, _992, _994), 0.0f);
    float _998 = _987.y - _996.y;
    float _999 = _998 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _1000 = _999 + _996.y;
    _1002 = _1000;
  } else {
    _1002 = _987.y;
  }
  float _1003 = _968.x * -2.0f;
  float _1004 = _1003 * _1002;
  float _1005 = _1002 * 2.0f;
  float _1006 = _1005 * _968.y;
  float _1007 = _1005 * _968.z;
  float _1008 = _1004 + _968.x;
  float _1009 = _1006 - _968.y;
  float _1010 = _1007 - _968.z;
  float _1011 = _1008 * _968.x;
  float _1012 = _1009 * _968.y;
  float _1013 = _1010 * _968.z;
  float _1014 = _972 + 1.0f;
  float _1015 = _972 / _1014;
  float _1016 = _1015 + -9.999999747378752e-05f;
  float _1017 = _1016 * 1111.111083984375f;
  float _1018 = saturate(_1017);
  float _1019 = _1018 * 2.0f;
  float _1020 = 3.0f - _1019;
  float _1021 = _1018 * _1018;
  float _1022 = _1021 * _1020;
  bool _1024 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _1025 = float((bool)_1024);
  float _1026 = dot(float3(_1011, _1012, _1013), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1027 = _1026 - _1011;
  float _1028 = _1026 - _1012;
  float _1029 = _1026 - _1013;
  float _1030 = _1027 * _1025;
  float _1031 = _1028 * _1025;
  float _1032 = _1029 * _1025;
  float _1033 = _1030 + _1011;
  float _1034 = _1031 + _1012;
  float _1035 = _1032 + _1013;
  float _1039 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1040 = _1039 * _1015;
  float _1041 = _1040 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1042 = _1022 * _1041;
  float _1043 = _1042 * _1033;
  float _1044 = _1042 * _1034;
  float _1045 = _1042 * _1035;
  float _1046 = _1043 + _950;
  float _1047 = _1044 + _951;
  float _1048 = _1045 + _952;
  float _1049 = max(0.0f, _1046);
  float _1050 = max(0.0f, _1047);
  float _1051 = max(0.0f, _1048);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_1049, _1050, _1051),
      apt_scaled_lut_output);
  _1049 = apt_film_grain_output.x;
  _1050 = apt_film_grain_output.y;
  _1051 = apt_film_grain_output.z;
  bool _1054 = !((PostProcess_000.PostProcessConstant_Z_000[17].x) == 0.0f) && !APTIsPsychoV();
  if (_1054) {
    float _1063 = _1049 * (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _1064 = _1050 * (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _1065 = _1051 * (PostProcess_000.PostProcessConstant_Z_000[10].w);
    bool _1066 = (_1063 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_1066) {
      float _1068 = _1063 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _1069 = 1.0f - _1068;
      float _1070 = _1069 * _1069;
      float _1071 = _1070 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _1072 = _1071 + _1063;
      _1074 = _1072;
    } else {
      _1074 = _1063;
    }
    bool _1075 = (_1064 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_1075) {
      float _1077 = _1064 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _1078 = 1.0f - _1077;
      float _1079 = _1078 * _1078;
      float _1080 = _1079 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _1081 = _1080 + _1064;
      _1083 = _1081;
    } else {
      _1083 = _1064;
    }
    bool _1084 = (_1065 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_1084) {
      float _1086 = _1065 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _1087 = 1.0f - _1086;
      float _1088 = _1087 * _1087;
      float _1089 = _1088 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _1090 = _1089 + _1065;
      _1092 = _1090;
    } else {
      _1092 = _1065;
    }
    float _1093 = _1074 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _1094 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
    float _1095 = log2(_1093);
    float _1096 = _1095 * _1094;
    float _1097 = exp2(_1096);
    float _1098 = _1097 + -1.0f;
    float _1099 = _1093 + -1.0f;
    float _1100 = _1098 / _1099;
    bool _1101 = !(_1093 == 1.0f);
    float _1102 = _1100 + -1.0f;
    float _1103 = _1102 / _1100;
    float _1104 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _1105 = _1104 / _1094;
    float _1106 = select(_1101, _1103, _1105);
    float _1107 = _1106 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _1108 = _1083 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _1109 = log2(_1108);
    float _1110 = _1109 * _1094;
    float _1111 = exp2(_1110);
    float _1112 = _1111 + -1.0f;
    float _1113 = _1108 + -1.0f;
    float _1114 = _1112 / _1113;
    bool _1115 = !(_1108 == 1.0f);
    float _1116 = _1114 + -1.0f;
    float _1117 = _1116 / _1114;
    float _1118 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _1119 = _1118 / _1094;
    float _1120 = select(_1115, _1117, _1119);
    float _1121 = _1120 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _1122 = _1092 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _1123 = log2(_1122);
    float _1124 = _1123 * _1094;
    float _1125 = exp2(_1124);
    float _1126 = _1125 + -1.0f;
    float _1127 = _1122 + -1.0f;
    float _1128 = _1126 / _1127;
    bool _1129 = !(_1122 == 1.0f);
    float _1130 = _1128 + -1.0f;
    float _1131 = _1130 / _1128;
    float _1132 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _1133 = _1132 / _1094;
    float _1134 = select(_1129, _1131, _1133);
    float _1135 = _1134 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _1136 = _1107 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _1137 = _1121 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _1138 = _1135 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    _1140 = _1136;
    _1141 = _1137;
    _1142 = _1138;
  } else {
    _1140 = _1049;
    _1141 = _1050;
    _1142 = _1051;
  }
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1049, _1050, _1051),
      float3(_1140, _1141, _1142),
      false);
  _1140 = apt_post_process_output.x;
  _1141 = apt_post_process_output.y;
  _1142 = apt_post_process_output.z;
  float _1143 = log2(_1140);
  float _1144 = log2(_1141);
  float _1145 = log2(_1142);
  float _1146 = _1143 * 0.4166666567325592f;
  float _1147 = _1144 * 0.4166666567325592f;
  float _1148 = _1145 * 0.4166666567325592f;
  float _1149 = exp2(_1146);
  float _1150 = exp2(_1147);
  float _1151 = exp2(_1148);
  float _1152 = _1149 * 1.0549999475479126f;
  float _1153 = _1150 * 1.0549999475479126f;
  float _1154 = _1151 * 1.0549999475479126f;
  float _1155 = _1152 + -0.054999999701976776f;
  float _1156 = _1153 + -0.054999999701976776f;
  float _1157 = _1154 + -0.054999999701976776f;
  float _1158 = _1140 * 12.920000076293945f;
  float _1159 = _1141 * 12.920000076293945f;
  float _1160 = _1142 * 12.920000076293945f;
  bool _1161 = (_1140 <= 0.0031308000907301903f);
  bool _1162 = (_1141 <= 0.0031308000907301903f);
  bool _1163 = (_1142 <= 0.0031308000907301903f);
  float _1164 = select(_1161, _1158, _1155);
  float _1165 = select(_1162, _1159, _1156);
  float _1166 = select(_1163, _1160, _1157);
  float _1167 = log2(_1164);
  float _1168 = log2(_1165);
  float _1169 = log2(_1166);
  float _1170 = floor(_1167);
  float _1171 = floor(_1168);
  float _1172 = floor(_1169);
  float _1173 = _1170 + -6.0f;
  float _1174 = _1171 + -6.0f;
  float _1175 = _1172 + -5.0f;
  float _1176 = exp2(_1173);
  float _1177 = exp2(_1174);
  float _1178 = exp2(_1175);
  bool _1179 = (_1164 <= 0.0f);
  bool _1180 = (_1165 <= 0.0f);
  bool _1181 = (_1166 <= 0.0f);
  float _1182 = select(_1179, 0.0f, _1176);
  float _1183 = select(_1180, 0.0f, _1177);
  float _1184 = select(_1181, 0.0f, _1178);
  uint _1185 = uint(SV_Position.x);
  uint _1186 = uint(SV_Position.y);
  int _1187 = _1185 & 63;
  int _1188 = _1186 & 63;
  float4 _1190 = t1.Load(int4(_1187, _1188, _978, 0));
  float4 _1192 = t6.Load(int4(_1187, _1188, _978, 0));
  float _1195 = _1190.x * _1182;
  float _1196 = _1192.x * _1183;
  float _1197 = _1192.y * _1184;
  float _1198 = _1195 + _1164;
  float _1199 = _1196 + _1165;
  float _1200 = _1197 + _1166;
  SV_Target.x = _1198;
  SV_Target.y = _1199;
  SV_Target.z = _1200;
  SV_Target.w = _380;
  return SV_Target;
}
