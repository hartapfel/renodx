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

Texture2DArray<float4> t2 : register(t2);

Texture2D<float4> t0 : register(t0);

Texture3D<float4> t3 : register(t3);

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

SamplerState s3 : register(s3);

SamplerState s8 : register(s8);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _30 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _36 = t16.Sample(s1, float2(TEXCOORD.z, TEXCOORD.w));
  float _38 = _36.y * 0.10000000149011612f;
  float _39 = _38 + _30.y;
  float _40 = _36.y * 0.5f;
  float _41 = _40 + _30.z;
  float _42 = exp2(_41);
  float _43 = _42 + -1.0f;
  float _46 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _43;
  float _47 = _46 + 1.0f;
  float _48 = log2(_47);
  float _49 = _30.x + TEXCOORD.z;
  float _50 = _39 + TEXCOORD.w;
  float _51 = _30.x + TEXCOORD.x;
  float _52 = _39 + TEXCOORD.y;
  float _53 = _48 + 1.0f;
  float _54 = log2(_53);
  float4 _57 = t0.SampleLevel(s1, float2(_49, _50), _54);
  bool _62 = (_54 > 0.0f);
  float _367;
  float _368;
  float _369;
  float _370;
  float _412;
  float _413;
  float _414;
  float _652;
  float _756;
  float _860;
  float _863;
  float _864;
  float _865;
  float _876;
  float _1001;
  float _1002;
  float _1003;
  float _1050;
  float _1051;
  float _1052;
  float _1066;
  float _1067;
  float _1068;
  [branch]
  if (_62) {
    float _64 = floor(_54);
    int _65 = int(_64);
    uint4 _66 = 0u; t0.GetDimensions(0u, _66.x, _66.y, _66.w);
    int _69 = _65 & 31;
    int _70 = (uint)(_66.x) >> _69;
    float _71 = float((uint)_70);
    int _72 = (uint)(_66.y) >> _69;
    float _73 = float((uint)_72);
    float _74 = 1.0f / _71;
    float _75 = 1.0f / _73;
    float _76 = _71 * _49;
    float _77 = _73 * _50;
    float _78 = _76 + -0.5f;
    float _79 = _77 + -0.5f;
    float _80 = frac(_78);
    float _81 = frac(_79);
    float _82 = floor(_78);
    float _83 = floor(_79);
    float _84 = 1.0f - _80;
    float _85 = 2.0f - _80;
    float _86 = 3.0f - _80;
    float _87 = _84 * _84;
    float _88 = _85 * _85;
    float _89 = _86 * _86;
    float _90 = _87 * _84;
    float _91 = _88 * _85;
    float _92 = _89 * _86;
    float _93 = _90 * 4.0f;
    float _94 = _91 - _93;
    float _95 = _91 * 4.0f;
    float _96 = _90 * 6.0f;
    float _97 = 6.0f - _90;
    float _98 = _97 - _94;
    float _99 = _95 - _92;
    float _100 = _99 - _96;
    float _101 = _100 + _98;
    float _102 = _94 * 0.1666666716337204f;
    float _103 = _101 * 0.1666666716337204f;
    float _104 = 1.0f - _81;
    float _105 = 2.0f - _81;
    float _106 = 3.0f - _81;
    float _107 = _104 * _104;
    float _108 = _105 * _105;
    float _109 = _106 * _106;
    float _110 = _107 * _104;
    float _111 = _108 * _105;
    float _112 = _109 * _106;
    float _113 = _110 * 4.0f;
    float _114 = _111 - _113;
    float _115 = _111 * 4.0f;
    float _116 = _110 * 6.0f;
    float _117 = 6.0f - _110;
    float _118 = _117 - _114;
    float _119 = _115 - _112;
    float _120 = _119 - _116;
    float _121 = _120 + _118;
    float _122 = _114 * 0.1666666716337204f;
    float _123 = _121 * 0.1666666716337204f;
    float _124 = _82 + -0.5f;
    float _125 = _82 + 1.5f;
    float _126 = _83 + -0.5f;
    float _127 = _83 + 1.5f;
    float _128 = _94 + _90;
    float _129 = _128 * 0.1666666716337204f;
    float _130 = _98 * 0.1666666716337204f;
    float _131 = _114 + _110;
    float _132 = _131 * 0.1666666716337204f;
    float _133 = _118 * 0.1666666716337204f;
    float _134 = _102 / _129;
    float _135 = _103 / _130;
    float _136 = _122 / _132;
    float _137 = _123 / _133;
    float _138 = _124 + _134;
    float _139 = _125 + _135;
    float _140 = _126 + _136;
    float _141 = _127 + _137;
    float _142 = _138 * _74;
    float _143 = _139 * _74;
    float _144 = _140 * _75;
    float _145 = _141 * _75;
    float _146 = float((int)(_65));
    float4 _148 = t0.SampleLevel(s0, float2(_142, _144), _146);
    float4 _153 = t0.SampleLevel(s0, float2(_143, _144), _146);
    float4 _158 = t0.SampleLevel(s0, float2(_142, _145), _146);
    float4 _163 = t0.SampleLevel(s0, float2(_143, _145), _146);
    float _168 = _148.x - _153.x;
    float _169 = _148.y - _153.y;
    float _170 = _148.z - _153.z;
    float _171 = _148.w - _153.w;
    float _172 = _168 * _129;
    float _173 = _169 * _129;
    float _174 = _170 * _129;
    float _175 = _171 * _129;
    float _176 = _172 + _153.x;
    float _177 = _173 + _153.y;
    float _178 = _174 + _153.z;
    float _179 = _175 + _153.w;
    float _180 = _158.x - _163.x;
    float _181 = _158.y - _163.y;
    float _182 = _158.z - _163.z;
    float _183 = _158.w - _163.w;
    float _184 = _180 * _129;
    float _185 = _181 * _129;
    float _186 = _182 * _129;
    float _187 = _183 * _129;
    float _188 = _184 + _163.x;
    float _189 = _185 + _163.y;
    float _190 = _186 + _163.z;
    float _191 = _187 + _163.w;
    float _192 = _176 - _188;
    float _193 = _177 - _189;
    float _194 = _178 - _190;
    float _195 = _179 - _191;
    float _196 = _192 * _132;
    float _197 = _193 * _132;
    float _198 = _194 * _132;
    float _199 = _195 * _132;
    float _200 = _196 + _188;
    float _201 = _197 + _189;
    float _202 = _198 + _190;
    float _203 = _199 + _191;
    float _204 = ceil(_54);
    int _205 = int(_204);
    int _206 = _205 & 31;
    int _207 = (uint)(_66.x) >> _206;
    float _208 = float((uint)_207);
    int _209 = (uint)(_66.y) >> _206;
    float _210 = float((uint)_209);
    float _211 = 1.0f / _208;
    float _212 = 1.0f / _210;
    float _213 = _208 * _49;
    float _214 = _210 * _50;
    float _215 = _213 + -0.5f;
    float _216 = _214 + -0.5f;
    float _217 = frac(_215);
    float _218 = frac(_216);
    float _219 = floor(_215);
    float _220 = floor(_216);
    float _221 = 1.0f - _217;
    float _222 = 2.0f - _217;
    float _223 = 3.0f - _217;
    float _224 = _221 * _221;
    float _225 = _222 * _222;
    float _226 = _223 * _223;
    float _227 = _224 * _221;
    float _228 = _225 * _222;
    float _229 = _226 * _223;
    float _230 = _227 * 4.0f;
    float _231 = _228 - _230;
    float _232 = _228 * 4.0f;
    float _233 = _227 * 6.0f;
    float _234 = 6.0f - _227;
    float _235 = _234 - _231;
    float _236 = _232 - _229;
    float _237 = _236 - _233;
    float _238 = _237 + _235;
    float _239 = _231 * 0.1666666716337204f;
    float _240 = _238 * 0.1666666716337204f;
    float _241 = 1.0f - _218;
    float _242 = 2.0f - _218;
    float _243 = 3.0f - _218;
    float _244 = _241 * _241;
    float _245 = _242 * _242;
    float _246 = _243 * _243;
    float _247 = _244 * _241;
    float _248 = _245 * _242;
    float _249 = _246 * _243;
    float _250 = _247 * 4.0f;
    float _251 = _248 - _250;
    float _252 = _248 * 4.0f;
    float _253 = _247 * 6.0f;
    float _254 = 6.0f - _247;
    float _255 = _254 - _251;
    float _256 = _252 - _249;
    float _257 = _256 - _253;
    float _258 = _257 + _255;
    float _259 = _251 * 0.1666666716337204f;
    float _260 = _258 * 0.1666666716337204f;
    float _261 = _219 + -0.5f;
    float _262 = _219 + 1.5f;
    float _263 = _220 + -0.5f;
    float _264 = _220 + 1.5f;
    float _265 = _231 + _227;
    float _266 = _265 * 0.1666666716337204f;
    float _267 = _235 * 0.1666666716337204f;
    float _268 = _251 + _247;
    float _269 = _268 * 0.1666666716337204f;
    float _270 = _255 * 0.1666666716337204f;
    float _271 = _239 / _266;
    float _272 = _240 / _267;
    float _273 = _259 / _269;
    float _274 = _260 / _270;
    float _275 = _261 + _271;
    float _276 = _262 + _272;
    float _277 = _263 + _273;
    float _278 = _264 + _274;
    float _279 = _275 * _211;
    float _280 = _276 * _211;
    float _281 = _277 * _212;
    float _282 = _278 * _212;
    float _283 = float((int)(_205));
    float4 _284 = t0.SampleLevel(s0, float2(_279, _281), _283);
    float4 _289 = t0.SampleLevel(s0, float2(_280, _281), _283);
    float4 _294 = t0.SampleLevel(s0, float2(_279, _282), _283);
    float4 _299 = t0.SampleLevel(s0, float2(_280, _282), _283);
    float _304 = _284.x - _289.x;
    float _305 = _284.y - _289.y;
    float _306 = _284.z - _289.z;
    float _307 = _284.w - _289.w;
    float _308 = _304 * _266;
    float _309 = _305 * _266;
    float _310 = _306 * _266;
    float _311 = _307 * _266;
    float _312 = _308 + _289.x;
    float _313 = _309 + _289.y;
    float _314 = _310 + _289.z;
    float _315 = _311 + _289.w;
    float _316 = _294.x - _299.x;
    float _317 = _294.y - _299.y;
    float _318 = _294.z - _299.z;
    float _319 = _294.w - _299.w;
    float _320 = _316 * _266;
    float _321 = _317 * _266;
    float _322 = _318 * _266;
    float _323 = _319 * _266;
    float _324 = _320 + _299.x;
    float _325 = _321 + _299.y;
    float _326 = _322 + _299.z;
    float _327 = _323 + _299.w;
    float _328 = _312 - _324;
    float _329 = _313 - _325;
    float _330 = _314 - _326;
    float _331 = _315 - _327;
    float _332 = _328 * _269;
    float _333 = _329 * _269;
    float _334 = _330 * _269;
    float _335 = _331 * _269;
    float _336 = frac(_54);
    float _337 = _324 - _200;
    float _338 = _337 + _332;
    float _339 = _325 - _201;
    float _340 = _339 + _333;
    float _341 = _326 - _202;
    float _342 = _341 + _334;
    float _343 = _327 - _203;
    float _344 = _343 + _335;
    float _345 = _338 * _336;
    float _346 = _340 * _336;
    float _347 = _342 * _336;
    float _348 = _344 * _336;
    float _349 = saturate(_54);
    float _350 = _200 - _57.x;
    float _351 = _350 + _345;
    float _352 = _201 - _57.y;
    float _353 = _352 + _346;
    float _354 = _202 - _57.z;
    float _355 = _354 + _347;
    float _356 = _203 - _57.w;
    float _357 = _356 + _348;
    float _358 = _351 * _349;
    float _359 = _353 * _349;
    float _360 = _355 * _349;
    float _361 = _357 * _349;
    float _362 = _358 + _57.x;
    float _363 = _359 + _57.y;
    float _364 = _360 + _57.z;
    float _365 = _361 + _57.w;
    _367 = _362;
    _368 = _363;
    _369 = _364;
    _370 = _365;
  } else {
    _367 = _57.x;
    _368 = _57.y;
    _369 = _57.z;
    _370 = _57.w;
  }
  float _371 = max(_367, 0.0f);
  float _372 = max(_368, 0.0f);
  float _373 = max(_369, 0.0f);
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
      float3(_371, _372, _373),
      float3(_371, _372, _373),
      float2(_49, _50),
      t0,
      s1,
      _54);
  _371 = renodx_chromatic_aberration_input.x;
  _372 = renodx_chromatic_aberration_input.y;
  _373 = renodx_chromatic_aberration_input.z;
  float4 _375 = t12.SampleLevel(s1, float2(_49, _50), 0.0f);
  float4 _381 = t8.Sample(s8, float2(_51, _52));
  bool _387 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
  float _391 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _381.x;
  float _392 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _381.y;
  float _393 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _381.z;
  float _394 = _391 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _395 = _392 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _396 = _393 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  if (!_387) {
    float _398 = _394 * _375.x;
    float _399 = _395 * _375.y;
    float _400 = _396 * _375.z;
    _412 = _398;
    _413 = _399;
    _414 = _400;
  } else {
    float _402 = saturate(_394);
    float _403 = saturate(_395);
    float _404 = saturate(_396);
    float _405 = _375.x - _371;
    float _406 = _375.y - _372;
    float _407 = _375.z - _373;
    float _408 = _402 * _405;
    float _409 = _403 * _406;
    float _410 = _404 * _407;
    _412 = _408;
    _413 = _409;
    _414 = _410;
  }
  float _415 = _412 + _371;
  float _416 = _413 + _372;
  float _417 = _414 + _373;
  float4 _421 = t17.Load(int3(0, 0, 0));
  float _427 = _421.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _428 = _427 * _415;
  float _429 = _428 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _430 = _427 * _416;
  float _431 = _430 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _432 = _427 * _417;
  float _433 = _432 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _438 = _49 * 2.0f;
  float _439 = _50 * 2.0f;
  float _440 = _438 + -1.0f;
  float _441 = _439 + -1.0f;
  float _444 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _441;
  float _445 = _440 * _440;
  float _446 = _444 * _444;
  float _447 = _446 + _445;
  float _448 = sqrt(_447);
  float _450 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _448;
  float _452 = _450 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _453 = saturate(_452);
  float _455 = log2(_453);
  float _456 = _455 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _457 = exp2(_456);
  float _458 = _429 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _459 = _431 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _460 = _433 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _461 = _458 - _429;
  float _462 = _459 - _431;
  float _463 = _460 - _433;
  float _464 = _457 * _461;
  float _465 = _457 * _462;
  float _466 = _457 * _463;
  float _467 = _464 + _429;
  float _468 = _465 + _431;
  float _469 = _466 + _433;
  float _472 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _473 = _472 * _467;
  float _474 = _472 * _468;
  float _475 = _472 * _469;
  float _476 = _473 + 1.0f;
  float _477 = _474 + 1.0f;
  float _478 = _475 + 1.0f;
  float _479 = log2(_476);
  float _480 = log2(_477);
  float _481 = log2(_478);
  float _484 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _485 = _484 * _479;
  float _486 = _484 * _480;
  float _487 = _484 * _481;
  float _489 = _485 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _490 = _486 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _491 = _487 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _494 = t3.Sample(s3, float3(_489, _490, _491));
  float _500 = _494.x * 13.450128555297852f;
  float _501 = _494.y * 13.450128555297852f;
  float _502 = _494.z * 13.450128555297852f;
  float _503 = exp2(_500);
  float _504 = exp2(_501);
  float _505 = exp2(_502);
  float _506 = _503 + -1.0f;
  float _507 = _504 + -1.0f;
  float _508 = _505 + -1.0f;
  float _509 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _510 = _509 * _506;
  float _511 = _509 * _507;
  float _512 = _509 * _508;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_473 * _509, _474 * _509, _475 * _509),
      float3(_510, _511, _512),
      1.f.xxx);
  _510 = resonance_scaled_lut_output.x;
  _511 = resonance_scaled_lut_output.y;
  _512 = resonance_scaled_lut_output.z;
  bool _515 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_515) {
    float _517 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _518 = _510 * _517;
    float _519 = _511 * _517;
    float _520 = _512 * _517;
    float _521 = _518 + 1.0f;
    float _522 = _519 + 1.0f;
    float _523 = _520 + 1.0f;
    float _524 = log2(_521);
    float _525 = log2(_522);
    float _526 = log2(_523);
    float _527 = _524 * 0.07434873282909393f;
    float _528 = _525 * 0.07434873282909393f;
    float _529 = _526 * 0.07434873282909393f;
    int _531 = asint((User_000.UserConstant_Z_000[3].y));
    int _532 = _531 & 1;
    bool _533 = (_532 == 0);
    if (!_533) {
      bool _550 = !(_527 <= (User_000.UserConstant_Z_000[4].x));
      if (!_550) {
        float _552 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _553 = _527 / _552;
        float _554 = _553 * (User_000.UserConstant_Z_000[4].y);
        float _555 = _553 * _553;
        float _556 = _555 * _553;
        float _557 = _556 - _553;
        float _558 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _559 = _552 * _552;
        float _560 = _559 * _558;
        float _561 = _560 * _557;
        float _562 = _561 + _554;
        _652 = _562;
      } else {
        bool _564 = !(_527 <= (User_000.UserConstant_Z_000[4].z));
        if (!_564) {
          float _566 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _567 = max(9.999999974752427e-07f, _566);
          float _568 = _527 - (User_000.UserConstant_Z_000[4].x);
          float _569 = _568 / _567;
          float _570 = 1.0f - _569;
          float _571 = _570 * (User_000.UserConstant_Z_000[4].y);
          float _572 = _569 * (User_000.UserConstant_Z_000[4].w);
          float _573 = _571 + _572;
          float _574 = _570 * _570;
          float _575 = _574 * _570;
          float _576 = _575 - _570;
          float _577 = _576 * (User_000.UserConstant_Z_000[10].x);
          float _578 = _569 * _569;
          float _579 = _578 * _569;
          float _580 = _579 - _569;
          float _581 = _580 * (User_000.UserConstant_Z_000[10].y);
          float _582 = _577 + _581;
          float _583 = _567 * _567;
          float _584 = _583 * 0.1666666716337204f;
          float _585 = _584 * _582;
          float _586 = _573 + _585;
          _652 = _586;
        } else {
          bool _588 = !(_527 <= (User_000.UserConstant_Z_000[9].x));
          if (!_588) {
            float _590 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _591 = max(9.999999974752427e-07f, _590);
            float _592 = _527 - (User_000.UserConstant_Z_000[4].z);
            float _593 = _592 / _591;
            float _594 = 1.0f - _593;
            float _595 = _594 * (User_000.UserConstant_Z_000[4].w);
            float _596 = _593 * (User_000.UserConstant_Z_000[9].y);
            float _597 = _595 + _596;
            float _598 = _594 * _594;
            float _599 = _598 * _594;
            float _600 = _599 - _594;
            float _601 = _600 * (User_000.UserConstant_Z_000[10].y);
            float _602 = _593 * _593;
            float _603 = _602 * _593;
            float _604 = _603 - _593;
            float _605 = _604 * (User_000.UserConstant_Z_000[10].z);
            float _606 = _601 + _605;
            float _607 = _591 * _591;
            float _608 = _607 * 0.1666666716337204f;
            float _609 = _608 * _606;
            float _610 = _597 + _609;
            _652 = _610;
          } else {
            bool _612 = !(_527 <= (User_000.UserConstant_Z_000[9].z));
            if (!_612) {
              float _614 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _615 = max(9.999999974752427e-07f, _614);
              float _616 = _527 - (User_000.UserConstant_Z_000[9].x);
              float _617 = _616 / _615;
              float _618 = 1.0f - _617;
              float _619 = _618 * (User_000.UserConstant_Z_000[9].y);
              float _620 = _617 * (User_000.UserConstant_Z_000[9].w);
              float _621 = _619 + _620;
              float _622 = _618 * _618;
              float _623 = _622 * _618;
              float _624 = _623 - _618;
              float _625 = _624 * (User_000.UserConstant_Z_000[10].z);
              float _626 = _617 * _617;
              float _627 = _626 * _617;
              float _628 = _627 - _617;
              float _629 = _628 * (User_000.UserConstant_Z_000[10].w);
              float _630 = _625 + _629;
              float _631 = _615 * _615;
              float _632 = _631 * 0.1666666716337204f;
              float _633 = _632 * _630;
              float _634 = _621 + _633;
              _652 = _634;
            } else {
              float _636 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _637 = _527 - (User_000.UserConstant_Z_000[9].z);
              float _638 = max(9.999999974752427e-07f, _636);
              float _639 = _637 / _638;
              float _640 = 1.0f - _639;
              float _641 = _640 * (User_000.UserConstant_Z_000[9].w);
              float _642 = _641 + _639;
              float _643 = _640 * _640;
              float _644 = _643 * _640;
              float _645 = _644 - _640;
              float _646 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _647 = _636 * _636;
              float _648 = _647 * _646;
              float _649 = _648 * _645;
              float _650 = _642 + _649;
              _652 = _650;
            }
          }
        }
      }
      float _653 = saturate(_652);
      bool _654 = !(_528 <= (User_000.UserConstant_Z_000[4].x));
      if (!_654) {
        float _656 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _657 = _528 / _656;
        float _658 = _657 * (User_000.UserConstant_Z_000[4].y);
        float _659 = _657 * _657;
        float _660 = _659 * _657;
        float _661 = _660 - _657;
        float _662 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _663 = _656 * _656;
        float _664 = _663 * _662;
        float _665 = _664 * _661;
        float _666 = _665 + _658;
        _756 = _666;
      } else {
        bool _668 = !(_528 <= (User_000.UserConstant_Z_000[4].z));
        if (!_668) {
          float _670 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _671 = max(9.999999974752427e-07f, _670);
          float _672 = _528 - (User_000.UserConstant_Z_000[4].x);
          float _673 = _672 / _671;
          float _674 = 1.0f - _673;
          float _675 = _674 * (User_000.UserConstant_Z_000[4].y);
          float _676 = _673 * (User_000.UserConstant_Z_000[4].w);
          float _677 = _675 + _676;
          float _678 = _674 * _674;
          float _679 = _678 * _674;
          float _680 = _679 - _674;
          float _681 = _680 * (User_000.UserConstant_Z_000[10].x);
          float _682 = _673 * _673;
          float _683 = _682 * _673;
          float _684 = _683 - _673;
          float _685 = _684 * (User_000.UserConstant_Z_000[10].y);
          float _686 = _681 + _685;
          float _687 = _671 * _671;
          float _688 = _687 * 0.1666666716337204f;
          float _689 = _688 * _686;
          float _690 = _677 + _689;
          _756 = _690;
        } else {
          bool _692 = !(_528 <= (User_000.UserConstant_Z_000[9].x));
          if (!_692) {
            float _694 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _695 = max(9.999999974752427e-07f, _694);
            float _696 = _528 - (User_000.UserConstant_Z_000[4].z);
            float _697 = _696 / _695;
            float _698 = 1.0f - _697;
            float _699 = _698 * (User_000.UserConstant_Z_000[4].w);
            float _700 = _697 * (User_000.UserConstant_Z_000[9].y);
            float _701 = _699 + _700;
            float _702 = _698 * _698;
            float _703 = _702 * _698;
            float _704 = _703 - _698;
            float _705 = _704 * (User_000.UserConstant_Z_000[10].y);
            float _706 = _697 * _697;
            float _707 = _706 * _697;
            float _708 = _707 - _697;
            float _709 = _708 * (User_000.UserConstant_Z_000[10].z);
            float _710 = _705 + _709;
            float _711 = _695 * _695;
            float _712 = _711 * 0.1666666716337204f;
            float _713 = _712 * _710;
            float _714 = _701 + _713;
            _756 = _714;
          } else {
            bool _716 = !(_528 <= (User_000.UserConstant_Z_000[9].z));
            if (!_716) {
              float _718 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _719 = max(9.999999974752427e-07f, _718);
              float _720 = _528 - (User_000.UserConstant_Z_000[9].x);
              float _721 = _720 / _719;
              float _722 = 1.0f - _721;
              float _723 = _722 * (User_000.UserConstant_Z_000[9].y);
              float _724 = _721 * (User_000.UserConstant_Z_000[9].w);
              float _725 = _723 + _724;
              float _726 = _722 * _722;
              float _727 = _726 * _722;
              float _728 = _727 - _722;
              float _729 = _728 * (User_000.UserConstant_Z_000[10].z);
              float _730 = _721 * _721;
              float _731 = _730 * _721;
              float _732 = _731 - _721;
              float _733 = _732 * (User_000.UserConstant_Z_000[10].w);
              float _734 = _729 + _733;
              float _735 = _719 * _719;
              float _736 = _735 * 0.1666666716337204f;
              float _737 = _736 * _734;
              float _738 = _725 + _737;
              _756 = _738;
            } else {
              float _740 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _741 = _528 - (User_000.UserConstant_Z_000[9].z);
              float _742 = max(9.999999974752427e-07f, _740);
              float _743 = _741 / _742;
              float _744 = 1.0f - _743;
              float _745 = _744 * (User_000.UserConstant_Z_000[9].w);
              float _746 = _745 + _743;
              float _747 = _744 * _744;
              float _748 = _747 * _744;
              float _749 = _748 - _744;
              float _750 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _751 = _740 * _740;
              float _752 = _751 * _750;
              float _753 = _752 * _749;
              float _754 = _746 + _753;
              _756 = _754;
            }
          }
        }
      }
      float _757 = saturate(_756);
      bool _758 = !(_529 <= (User_000.UserConstant_Z_000[4].x));
      if (!_758) {
        float _760 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _761 = _529 / _760;
        float _762 = _761 * (User_000.UserConstant_Z_000[4].y);
        float _763 = _761 * _761;
        float _764 = _763 * _761;
        float _765 = _764 - _761;
        float _766 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _767 = _760 * _760;
        float _768 = _767 * _766;
        float _769 = _768 * _765;
        float _770 = _769 + _762;
        _860 = _770;
      } else {
        bool _772 = !(_529 <= (User_000.UserConstant_Z_000[4].z));
        if (!_772) {
          float _774 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _775 = max(9.999999974752427e-07f, _774);
          float _776 = _529 - (User_000.UserConstant_Z_000[4].x);
          float _777 = _776 / _775;
          float _778 = 1.0f - _777;
          float _779 = _778 * (User_000.UserConstant_Z_000[4].y);
          float _780 = _777 * (User_000.UserConstant_Z_000[4].w);
          float _781 = _779 + _780;
          float _782 = _778 * _778;
          float _783 = _782 * _778;
          float _784 = _783 - _778;
          float _785 = _784 * (User_000.UserConstant_Z_000[10].x);
          float _786 = _777 * _777;
          float _787 = _786 * _777;
          float _788 = _787 - _777;
          float _789 = _788 * (User_000.UserConstant_Z_000[10].y);
          float _790 = _785 + _789;
          float _791 = _775 * _775;
          float _792 = _791 * 0.1666666716337204f;
          float _793 = _792 * _790;
          float _794 = _781 + _793;
          _860 = _794;
        } else {
          bool _796 = !(_529 <= (User_000.UserConstant_Z_000[9].x));
          if (!_796) {
            float _798 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _799 = max(9.999999974752427e-07f, _798);
            float _800 = _529 - (User_000.UserConstant_Z_000[4].z);
            float _801 = _800 / _799;
            float _802 = 1.0f - _801;
            float _803 = _802 * (User_000.UserConstant_Z_000[4].w);
            float _804 = _801 * (User_000.UserConstant_Z_000[9].y);
            float _805 = _803 + _804;
            float _806 = _802 * _802;
            float _807 = _806 * _802;
            float _808 = _807 - _802;
            float _809 = _808 * (User_000.UserConstant_Z_000[10].y);
            float _810 = _801 * _801;
            float _811 = _810 * _801;
            float _812 = _811 - _801;
            float _813 = _812 * (User_000.UserConstant_Z_000[10].z);
            float _814 = _809 + _813;
            float _815 = _799 * _799;
            float _816 = _815 * 0.1666666716337204f;
            float _817 = _816 * _814;
            float _818 = _805 + _817;
            _860 = _818;
          } else {
            bool _820 = !(_529 <= (User_000.UserConstant_Z_000[9].z));
            if (!_820) {
              float _822 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _823 = max(9.999999974752427e-07f, _822);
              float _824 = _529 - (User_000.UserConstant_Z_000[9].x);
              float _825 = _824 / _823;
              float _826 = 1.0f - _825;
              float _827 = _826 * (User_000.UserConstant_Z_000[9].y);
              float _828 = _825 * (User_000.UserConstant_Z_000[9].w);
              float _829 = _827 + _828;
              float _830 = _826 * _826;
              float _831 = _830 * _826;
              float _832 = _831 - _826;
              float _833 = _832 * (User_000.UserConstant_Z_000[10].z);
              float _834 = _825 * _825;
              float _835 = _834 * _825;
              float _836 = _835 - _825;
              float _837 = _836 * (User_000.UserConstant_Z_000[10].w);
              float _838 = _833 + _837;
              float _839 = _823 * _823;
              float _840 = _839 * 0.1666666716337204f;
              float _841 = _840 * _838;
              float _842 = _829 + _841;
              _860 = _842;
            } else {
              float _844 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _845 = _529 - (User_000.UserConstant_Z_000[9].z);
              float _846 = max(9.999999974752427e-07f, _844);
              float _847 = _845 / _846;
              float _848 = 1.0f - _847;
              float _849 = _848 * (User_000.UserConstant_Z_000[9].w);
              float _850 = _849 + _847;
              float _851 = _848 * _848;
              float _852 = _851 * _848;
              float _853 = _852 - _848;
              float _854 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _855 = _844 * _844;
              float _856 = _855 * _854;
              float _857 = _856 * _853;
              float _858 = _850 + _857;
              _860 = _858;
            }
          }
        }
      }
      float _861 = saturate(_860);
      _863 = _653;
      _864 = _757;
      _865 = _861;
    } else {
      _863 = _527;
      _864 = _528;
      _865 = _529;
    }
    int _866 = _531 & 2;
    bool _867 = (_866 == 0);
    if (!_867) {
      float _869 = sqrt(_863);
      float _870 = sqrt(_864);
      float _871 = sqrt(_865);
      float _872 = dot(float3(_869, _870, _871), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _873 = 1.0f - _872;
      float _874 = saturate(_873);
      _876 = _874;
    } else {
      _876 = 1.0f;
    }
    int _877 = _531 & 8;
    bool _878 = (_877 == 0);
    if (_878) {
      int _880 = _531 & 4;
      bool _881 = (_880 == 0);
      if (!_881) {
        int _883 = _531 & 16;
        bool _884 = (_883 == 0);
        if (!_884) {
          float _888 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _889 = _888 + 0.5f;
          bool _890 = (_889 < 0.5f);
          float _891 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _892 = select(_890, (User_000.UserConstant_Z_000[5].x), _891);
          bool _893 = (_864 < _865);
          float _894 = select(_893, _865, _864);
          float _895 = select(_893, _864, _865);
          bool _896 = (_863 < _894);
          float _897 = select(_896, _894, _863);
          float _898 = select(_896, _863, _894);
          float _899 = min(_898, _895);
          float _900 = _897 - _899;
          float _901 = _897 + 1.000000013351432e-10f;
          float _902 = _900 / _901;
          float _904 = _902 - (User_000.UserConstant_Z_000[5].y);
          float _905 = saturate(_904);
          float _906 = max(_905, 9.999999974752427e-07f);
          float _907 = log2(_906);
          float _908 = _907 * _892;
          float _909 = exp2(_908);
          float _910 = 2.0f - _909;
          float _912 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _913 = saturate(_912);
          float _914 = max(_913, _910);
          float _915 = dot(float3(_863, _864, _865), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _916 = _863 - _915;
          float _917 = _864 - _915;
          float _918 = _865 - _915;
          float _919 = _916 * _914;
          float _920 = _917 * _914;
          float _921 = _918 * _914;
          float _922 = _915 - _863;
          float _923 = _922 + _919;
          float _924 = _915 - _864;
          float _925 = _924 + _920;
          float _926 = _915 - _865;
          float _927 = _926 + _921;
          float _928 = _923 * _876;
          float _929 = _925 * _876;
          float _930 = _927 * _876;
          float _931 = _928 + _863;
          float _932 = _929 + _864;
          float _933 = _930 + _865;
          _1050 = _931;
          _1051 = _932;
          _1052 = _933;
        } else {
          bool _935 = (_876 == 0.0f);
          if (!_935) {
            float _939 = abs(User_000.UserConstant_Z_000[5].x);
            float _940 = saturate(_939);
            uint4 _942 = 0u; t15.GetDimensions(0u, _942.x, _942.y, _942.w);
            float _945 = float((uint)_942.y);
            int _946 = _531 & 32;
            bool _947 = (_946 == 0);
            float _948 = _945 + -1.0f;
            if (!_947) {
              float _950 = 1.0f / _948;
              uint _951 = uint(SV_Position.x);
              uint _952 = uint(SV_Position.y);
              int _953 = _951 & 63;
              int _954 = _952 & 63;
              float4 _956 = t2.Load(int4(_953, _954, 0, 0));
              float _959 = _956.x + -0.5f;
              float _960 = _863 * 13.999999046325684f;
              float _961 = _864 * 13.999999046325684f;
              float _962 = _865 * 13.999999046325684f;
              float _963 = saturate(_960);
              float _964 = saturate(_961);
              float _965 = saturate(_962);
              float _966 = _863 + -0.9285714030265808f;
              float _967 = _864 + -0.9285714030265808f;
              float _968 = _865 + -0.9285714030265808f;
              float _969 = _966 * 13.999999046325684f;
              float _970 = _967 * 13.999999046325684f;
              float _971 = _968 * 13.999999046325684f;
              float _972 = saturate(_969);
              float _973 = saturate(_970);
              float _974 = saturate(_971);
              float _975 = 1.0f - _972;
              float _976 = 1.0f - _973;
              float _977 = 1.0f - _974;
              float _978 = min(_963, _975);
              float _979 = min(_964, _976);
              float _980 = min(_965, _977);
              float _981 = _956.y + -0.5f;
              float _982 = _978 * _981;
              float _983 = _979 * _981;
              float _984 = _980 * _981;
              float _985 = _982 + _959;
              float _986 = _983 + _959;
              float _987 = _984 + _959;
              float _988 = _985 * _950;
              float _989 = _986 * _950;
              float _990 = _987 * _950;
              float _991 = _988 + _863;
              float _992 = _989 + _864;
              float _993 = _990 + _865;
              float _994 = saturate(_991);
              float _995 = saturate(_992);
              float _996 = saturate(_993);
              float _997 = saturate(_994);
              float _998 = saturate(_995);
              float _999 = saturate(_996);
              _1001 = _997;
              _1002 = _998;
              _1003 = _999;
            } else {
              _1001 = _863;
              _1002 = _864;
              _1003 = _865;
            }
            float _1004 = float((uint)_942.x);
            float _1005 = _948 / _1004;
            float _1006 = _1005 * _1001;
            float _1007 = 0.5f / _1004;
            float _1008 = _1006 + _1007;
            float _1009 = _948 / _945;
            float _1010 = _1009 * _1002;
            float _1011 = 0.5f / _945;
            float _1012 = _1010 + _1011;
            float _1013 = _1003 * _948;
            float _1014 = floor(_1013);
            float _1015 = frac(_1013);
            float _1016 = _1014 / _945;
            float _1017 = _1016 + _1008;
            float _1018 = _1014 + 1.0f;
            float _1019 = _1018 / _945;
            float _1020 = _1019 + _1008;
            float4 _1022 = t15.Sample(s1, float2(_1017, _1012));
            float4 _1026 = t15.Sample(s1, float2(_1020, _1012));
            float _1030 = _1026.x - _1022.x;
            float _1031 = _1026.y - _1022.y;
            float _1032 = _1026.z - _1022.z;
            float _1033 = _1030 * _1015;
            float _1034 = _1031 * _1015;
            float _1035 = _1032 * _1015;
            float _1036 = _940 * _876;
            float _1037 = _1022.x - _863;
            float _1038 = _1037 + _1033;
            float _1039 = _1022.y - _864;
            float _1040 = _1039 + _1034;
            float _1041 = _1022.z - _865;
            float _1042 = _1041 + _1035;
            float _1043 = _1038 * _1036;
            float _1044 = _1040 * _1036;
            float _1045 = _1042 * _1036;
            float _1046 = _1043 + _863;
            float _1047 = _1044 + _864;
            float _1048 = _1045 + _865;
            _1050 = _1046;
            _1051 = _1047;
            _1052 = _1048;
          } else {
            _1050 = _863;
            _1051 = _864;
            _1052 = _865;
          }
        }
      } else {
        _1050 = _863;
        _1051 = _864;
        _1052 = _865;
      }
    } else {
      _1050 = _876;
      _1051 = _876;
      _1052 = _876;
    }
    float _1053 = _1050 * 13.450128555297852f;
    float _1054 = _1051 * 13.450128555297852f;
    float _1055 = _1052 * 13.450128555297852f;
    float _1056 = exp2(_1053);
    float _1057 = exp2(_1054);
    float _1058 = exp2(_1055);
    float _1059 = _1056 + -1.0f;
    float _1060 = _1057 + -1.0f;
    float _1061 = _1058 + -1.0f;
    float _1062 = _1059 * _509;
    float _1063 = _1060 * _509;
    float _1064 = _1061 * _509;
    _1066 = _1062;
    _1067 = _1063;
    _1068 = _1064;
  } else {
    _1066 = _510;
    _1067 = _511;
    _1068 = _512;
  }
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1066, (User_000.UserConstant_Z_000[8].y) * _1067, (User_000.UserConstant_Z_000[8].z) * _1068),
      SV_Position.xy);
  float _1075 = resonance_perceptual_film_grain.x;
  float _1076 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1077 = log2(_1075);
  float _1078 = _1076 * _1077;
  float _1079 = exp2(_1078);
  float _1080 = _1079 + -1.0f;
  float _1081 = _1075 + -1.0f;
  float _1082 = _1080 / _1081;
  bool _1083 = !(_1075 == 1.0f);
  float _1084 = _1082 + -1.0f;
  float _1085 = _1084 / _1082;
  float _1086 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1087 = _1086 / _1076;
  float _1088 = select(_1083, _1085, _1087);
  float _1089 = resonance_perceptual_film_grain.y;
  float _1090 = log2(_1089);
  float _1091 = _1090 * _1076;
  float _1092 = exp2(_1091);
  float _1093 = _1092 + -1.0f;
  float _1094 = _1089 + -1.0f;
  float _1095 = _1093 / _1094;
  bool _1096 = !(_1089 == 1.0f);
  float _1097 = _1095 + -1.0f;
  float _1098 = _1097 / _1095;
  float _1099 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1100 = _1099 / _1076;
  float _1101 = select(_1096, _1098, _1100);
  float _1102 = resonance_perceptual_film_grain.z;
  float _1103 = log2(_1102);
  float _1104 = _1103 * _1076;
  float _1105 = exp2(_1104);
  float _1106 = _1105 + -1.0f;
  float _1107 = _1102 + -1.0f;
  float _1108 = _1106 / _1107;
  bool _1109 = !(_1102 == 1.0f);
  float _1110 = _1108 + -1.0f;
  float _1111 = _1110 / _1108;
  float _1112 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1113 = _1112 / _1076;
  float _1114 = select(_1109, _1111, _1113);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1075, _1089, _1102),
      float3(_1088, _1101, _1114),
      true);
  float _1115 = resonance_post_process_output.x;
  float _1116 = resonance_post_process_output.y;
  float _1117 = resonance_post_process_output.z;
  float _1118 = log2(_1115);
  float _1119 = log2(_1116);
  float _1120 = log2(_1117);
  float _1121 = _1118 * 0.4166666567325592f;
  float _1122 = _1119 * 0.4166666567325592f;
  float _1123 = _1120 * 0.4166666567325592f;
  float _1124 = exp2(_1121);
  float _1125 = exp2(_1122);
  float _1126 = exp2(_1123);
  float _1127 = _1124 * 1.0549999475479126f;
  float _1128 = _1125 * 1.0549999475479126f;
  float _1129 = _1126 * 1.0549999475479126f;
  float _1130 = _1127 + -0.054999999701976776f;
  float _1131 = _1128 + -0.054999999701976776f;
  float _1132 = _1129 + -0.054999999701976776f;
  float _1133 = _1115 * 12.920000076293945f;
  float _1134 = _1116 * 12.920000076293945f;
  float _1135 = _1117 * 12.920000076293945f;
  bool _1136 = (_1115 <= 0.0031308000907301903f);
  bool _1137 = (_1116 <= 0.0031308000907301903f);
  bool _1138 = (_1117 <= 0.0031308000907301903f);
  float _1139 = select(_1136, _1133, _1130);
  float _1140 = select(_1137, _1134, _1131);
  float _1141 = select(_1138, _1135, _1132);
  int _1144 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1145 = uint(SV_Position.x);
  uint _1146 = uint(SV_Position.y);
  int _1147 = _1145 & 63;
  int _1148 = _1146 & 63;
  float4 _1150 = t1.Load(int4(_1147, _1148, _1144, 0));
  float _1152 = _1150.x + -0.5f;
  float _1153 = _1152 * 0.003921568859368563f;
  float _1154 = _1153 + _1139;
  float _1155 = _1153 + _1140;
  float _1156 = _1153 + _1141;
  float _1157 = saturate(_1154);
  float _1158 = saturate(_1155);
  float _1159 = saturate(_1156);
  SV_Target.x = _1157;
  SV_Target.y = _1158;
  SV_Target.z = _1159;
  SV_Target.w = _370;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}