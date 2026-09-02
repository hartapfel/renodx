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
  float _417;
  float _418;
  float _419;
  float _424;
  float _425;
  float _426;
  float _455;
  float _456;
  float _457;
  float _462;
  float _463;
  float _464;
  float _699;
  float _803;
  float _907;
  float _910;
  float _911;
  float _912;
  float _923;
  float _1048;
  float _1049;
  float _1050;
  float _1097;
  float _1098;
  float _1099;
  float _1113;
  float _1114;
  float _1115;
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
  int _387 = asint((User_000.UserConstant_Z_000[7].z));
  bool _388 = ((int)_387 > (int)0);
  if (!_388) {
    bool _392 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _396 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _381.x;
    float _397 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _381.y;
    float _398 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _381.z;
    float _399 = _396 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _400 = _397 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _401 = _398 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_392) {
      float _403 = _399 * _375.x;
      float _404 = _400 * _375.y;
      float _405 = _401 * _375.z;
      _417 = _403;
      _418 = _404;
      _419 = _405;
    } else {
      float _407 = saturate(_399);
      float _408 = saturate(_400);
      float _409 = saturate(_401);
      float _410 = _375.x - _371;
      float _411 = _375.y - _372;
      float _412 = _375.z - _373;
      float _413 = _407 * _410;
      float _414 = _408 * _411;
      float _415 = _409 * _412;
      _417 = _413;
      _418 = _414;
      _419 = _415;
    }
    float _420 = _417 + _371;
    float _421 = _418 + _372;
    float _422 = _419 + _373;
    _424 = _420;
    _425 = _421;
    _426 = _422;
  } else {
    _424 = _371;
    _425 = _372;
    _426 = _373;
  }
  if (_388) {
    bool _430 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _434 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _381.x;
    float _435 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _381.y;
    float _436 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _381.z;
    float _437 = _434 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _438 = _435 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _439 = _436 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_430) {
      float _441 = _437 * _375.x;
      float _442 = _438 * _375.y;
      float _443 = _439 * _375.z;
      _455 = _441;
      _456 = _442;
      _457 = _443;
    } else {
      float _445 = saturate(_437);
      float _446 = saturate(_438);
      float _447 = saturate(_439);
      float _448 = _375.x - _424;
      float _449 = _375.y - _425;
      float _450 = _375.z - _426;
      float _451 = _445 * _448;
      float _452 = _446 * _449;
      float _453 = _447 * _450;
      _455 = _451;
      _456 = _452;
      _457 = _453;
    }
    float _458 = _455 + _424;
    float _459 = _456 + _425;
    float _460 = _457 + _426;
    _462 = _458;
    _463 = _459;
    _464 = _460;
  } else {
    _462 = _424;
    _463 = _425;
    _464 = _426;
  }
  float4 _468 = t17.Load(int3(0, 0, 0));
  float _474 = _468.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _475 = _474 * _462;
  float _476 = _475 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _477 = _474 * _463;
  float _478 = _477 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _479 = _474 * _464;
  float _480 = _479 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _485 = _49 * 2.0f;
  float _486 = _50 * 2.0f;
  float _487 = _485 + -1.0f;
  float _488 = _486 + -1.0f;
  float _491 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _488;
  float _492 = _487 * _487;
  float _493 = _491 * _491;
  float _494 = _493 + _492;
  float _495 = sqrt(_494);
  float _497 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _495;
  float _499 = _497 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _500 = saturate(_499);
  float _502 = log2(_500);
  float _503 = _502 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _504 = ResonanceScaleVignetteMask(exp2(_503));
  float _505 = _476 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _506 = _478 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _507 = _480 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _508 = _505 - _476;
  float _509 = _506 - _478;
  float _510 = _507 - _480;
  float _511 = _504 * _508;
  float _512 = _504 * _509;
  float _513 = _504 * _510;
  float _514 = _511 + _476;
  float _515 = _512 + _478;
  float _516 = _513 + _480;
  float _519 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _520 = _519 * _514;
  float _521 = _519 * _515;
  float _522 = _519 * _516;
  float _523 = _520 + 1.0f;
  float _524 = _521 + 1.0f;
  float _525 = _522 + 1.0f;
  float _526 = log2(_523);
  float _527 = log2(_524);
  float _528 = log2(_525);
  float _531 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _532 = _531 * _526;
  float _533 = _531 * _527;
  float _534 = _531 * _528;
  float _536 = _532 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _537 = _533 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _538 = _534 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _541 = t3.Sample(s3, float3(_536, _537, _538));
  float _547 = _541.x * 13.450128555297852f;
  float _548 = _541.y * 13.450128555297852f;
  float _549 = _541.z * 13.450128555297852f;
  float _550 = exp2(_547);
  float _551 = exp2(_548);
  float _552 = exp2(_549);
  float _553 = _550 + -1.0f;
  float _554 = _551 + -1.0f;
  float _555 = _552 + -1.0f;
  float _556 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _557 = _556 * _553;
  float _558 = _556 * _554;
  float _559 = _556 * _555;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_520 * _556, _521 * _556, _522 * _556),
      float3(_557, _558, _559),
      1.f.xxx);
  _557 = resonance_scaled_lut_output.x;
  _558 = resonance_scaled_lut_output.y;
  _559 = resonance_scaled_lut_output.z;
  bool _562 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_562) {
    float _564 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _565 = _557 * _564;
    float _566 = _558 * _564;
    float _567 = _559 * _564;
    float _568 = _565 + 1.0f;
    float _569 = _566 + 1.0f;
    float _570 = _567 + 1.0f;
    float _571 = log2(_568);
    float _572 = log2(_569);
    float _573 = log2(_570);
    float _574 = _571 * 0.07434873282909393f;
    float _575 = _572 * 0.07434873282909393f;
    float _576 = _573 * 0.07434873282909393f;
    int _578 = asint((User_000.UserConstant_Z_000[3].y));
    int _579 = _578 & 1;
    bool _580 = (_579 == 0);
    if (!_580) {
      bool _597 = !(_574 <= (User_000.UserConstant_Z_000[4].x));
      if (!_597) {
        float _599 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _600 = _574 / _599;
        float _601 = _600 * (User_000.UserConstant_Z_000[4].y);
        float _602 = _600 * _600;
        float _603 = _602 * _600;
        float _604 = _603 - _600;
        float _605 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _606 = _599 * _599;
        float _607 = _606 * _605;
        float _608 = _607 * _604;
        float _609 = _608 + _601;
        _699 = _609;
      } else {
        bool _611 = !(_574 <= (User_000.UserConstant_Z_000[4].z));
        if (!_611) {
          float _613 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _614 = max(9.999999974752427e-07f, _613);
          float _615 = _574 - (User_000.UserConstant_Z_000[4].x);
          float _616 = _615 / _614;
          float _617 = 1.0f - _616;
          float _618 = _617 * (User_000.UserConstant_Z_000[4].y);
          float _619 = _616 * (User_000.UserConstant_Z_000[4].w);
          float _620 = _618 + _619;
          float _621 = _617 * _617;
          float _622 = _621 * _617;
          float _623 = _622 - _617;
          float _624 = _623 * (User_000.UserConstant_Z_000[10].x);
          float _625 = _616 * _616;
          float _626 = _625 * _616;
          float _627 = _626 - _616;
          float _628 = _627 * (User_000.UserConstant_Z_000[10].y);
          float _629 = _624 + _628;
          float _630 = _614 * _614;
          float _631 = _630 * 0.1666666716337204f;
          float _632 = _631 * _629;
          float _633 = _620 + _632;
          _699 = _633;
        } else {
          bool _635 = !(_574 <= (User_000.UserConstant_Z_000[9].x));
          if (!_635) {
            float _637 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _638 = max(9.999999974752427e-07f, _637);
            float _639 = _574 - (User_000.UserConstant_Z_000[4].z);
            float _640 = _639 / _638;
            float _641 = 1.0f - _640;
            float _642 = _641 * (User_000.UserConstant_Z_000[4].w);
            float _643 = _640 * (User_000.UserConstant_Z_000[9].y);
            float _644 = _642 + _643;
            float _645 = _641 * _641;
            float _646 = _645 * _641;
            float _647 = _646 - _641;
            float _648 = _647 * (User_000.UserConstant_Z_000[10].y);
            float _649 = _640 * _640;
            float _650 = _649 * _640;
            float _651 = _650 - _640;
            float _652 = _651 * (User_000.UserConstant_Z_000[10].z);
            float _653 = _648 + _652;
            float _654 = _638 * _638;
            float _655 = _654 * 0.1666666716337204f;
            float _656 = _655 * _653;
            float _657 = _644 + _656;
            _699 = _657;
          } else {
            bool _659 = !(_574 <= (User_000.UserConstant_Z_000[9].z));
            if (!_659) {
              float _661 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _662 = max(9.999999974752427e-07f, _661);
              float _663 = _574 - (User_000.UserConstant_Z_000[9].x);
              float _664 = _663 / _662;
              float _665 = 1.0f - _664;
              float _666 = _665 * (User_000.UserConstant_Z_000[9].y);
              float _667 = _664 * (User_000.UserConstant_Z_000[9].w);
              float _668 = _666 + _667;
              float _669 = _665 * _665;
              float _670 = _669 * _665;
              float _671 = _670 - _665;
              float _672 = _671 * (User_000.UserConstant_Z_000[10].z);
              float _673 = _664 * _664;
              float _674 = _673 * _664;
              float _675 = _674 - _664;
              float _676 = _675 * (User_000.UserConstant_Z_000[10].w);
              float _677 = _672 + _676;
              float _678 = _662 * _662;
              float _679 = _678 * 0.1666666716337204f;
              float _680 = _679 * _677;
              float _681 = _668 + _680;
              _699 = _681;
            } else {
              float _683 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _684 = _574 - (User_000.UserConstant_Z_000[9].z);
              float _685 = max(9.999999974752427e-07f, _683);
              float _686 = _684 / _685;
              float _687 = 1.0f - _686;
              float _688 = _687 * (User_000.UserConstant_Z_000[9].w);
              float _689 = _688 + _686;
              float _690 = _687 * _687;
              float _691 = _690 * _687;
              float _692 = _691 - _687;
              float _693 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _694 = _683 * _683;
              float _695 = _694 * _693;
              float _696 = _695 * _692;
              float _697 = _689 + _696;
              _699 = _697;
            }
          }
        }
      }
      float _700 = saturate(_699);
      bool _701 = !(_575 <= (User_000.UserConstant_Z_000[4].x));
      if (!_701) {
        float _703 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _704 = _575 / _703;
        float _705 = _704 * (User_000.UserConstant_Z_000[4].y);
        float _706 = _704 * _704;
        float _707 = _706 * _704;
        float _708 = _707 - _704;
        float _709 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _710 = _703 * _703;
        float _711 = _710 * _709;
        float _712 = _711 * _708;
        float _713 = _712 + _705;
        _803 = _713;
      } else {
        bool _715 = !(_575 <= (User_000.UserConstant_Z_000[4].z));
        if (!_715) {
          float _717 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _718 = max(9.999999974752427e-07f, _717);
          float _719 = _575 - (User_000.UserConstant_Z_000[4].x);
          float _720 = _719 / _718;
          float _721 = 1.0f - _720;
          float _722 = _721 * (User_000.UserConstant_Z_000[4].y);
          float _723 = _720 * (User_000.UserConstant_Z_000[4].w);
          float _724 = _722 + _723;
          float _725 = _721 * _721;
          float _726 = _725 * _721;
          float _727 = _726 - _721;
          float _728 = _727 * (User_000.UserConstant_Z_000[10].x);
          float _729 = _720 * _720;
          float _730 = _729 * _720;
          float _731 = _730 - _720;
          float _732 = _731 * (User_000.UserConstant_Z_000[10].y);
          float _733 = _728 + _732;
          float _734 = _718 * _718;
          float _735 = _734 * 0.1666666716337204f;
          float _736 = _735 * _733;
          float _737 = _724 + _736;
          _803 = _737;
        } else {
          bool _739 = !(_575 <= (User_000.UserConstant_Z_000[9].x));
          if (!_739) {
            float _741 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _742 = max(9.999999974752427e-07f, _741);
            float _743 = _575 - (User_000.UserConstant_Z_000[4].z);
            float _744 = _743 / _742;
            float _745 = 1.0f - _744;
            float _746 = _745 * (User_000.UserConstant_Z_000[4].w);
            float _747 = _744 * (User_000.UserConstant_Z_000[9].y);
            float _748 = _746 + _747;
            float _749 = _745 * _745;
            float _750 = _749 * _745;
            float _751 = _750 - _745;
            float _752 = _751 * (User_000.UserConstant_Z_000[10].y);
            float _753 = _744 * _744;
            float _754 = _753 * _744;
            float _755 = _754 - _744;
            float _756 = _755 * (User_000.UserConstant_Z_000[10].z);
            float _757 = _752 + _756;
            float _758 = _742 * _742;
            float _759 = _758 * 0.1666666716337204f;
            float _760 = _759 * _757;
            float _761 = _748 + _760;
            _803 = _761;
          } else {
            bool _763 = !(_575 <= (User_000.UserConstant_Z_000[9].z));
            if (!_763) {
              float _765 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _766 = max(9.999999974752427e-07f, _765);
              float _767 = _575 - (User_000.UserConstant_Z_000[9].x);
              float _768 = _767 / _766;
              float _769 = 1.0f - _768;
              float _770 = _769 * (User_000.UserConstant_Z_000[9].y);
              float _771 = _768 * (User_000.UserConstant_Z_000[9].w);
              float _772 = _770 + _771;
              float _773 = _769 * _769;
              float _774 = _773 * _769;
              float _775 = _774 - _769;
              float _776 = _775 * (User_000.UserConstant_Z_000[10].z);
              float _777 = _768 * _768;
              float _778 = _777 * _768;
              float _779 = _778 - _768;
              float _780 = _779 * (User_000.UserConstant_Z_000[10].w);
              float _781 = _776 + _780;
              float _782 = _766 * _766;
              float _783 = _782 * 0.1666666716337204f;
              float _784 = _783 * _781;
              float _785 = _772 + _784;
              _803 = _785;
            } else {
              float _787 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _788 = _575 - (User_000.UserConstant_Z_000[9].z);
              float _789 = max(9.999999974752427e-07f, _787);
              float _790 = _788 / _789;
              float _791 = 1.0f - _790;
              float _792 = _791 * (User_000.UserConstant_Z_000[9].w);
              float _793 = _792 + _790;
              float _794 = _791 * _791;
              float _795 = _794 * _791;
              float _796 = _795 - _791;
              float _797 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _798 = _787 * _787;
              float _799 = _798 * _797;
              float _800 = _799 * _796;
              float _801 = _793 + _800;
              _803 = _801;
            }
          }
        }
      }
      float _804 = saturate(_803);
      bool _805 = !(_576 <= (User_000.UserConstant_Z_000[4].x));
      if (!_805) {
        float _807 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _808 = _576 / _807;
        float _809 = _808 * (User_000.UserConstant_Z_000[4].y);
        float _810 = _808 * _808;
        float _811 = _810 * _808;
        float _812 = _811 - _808;
        float _813 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _814 = _807 * _807;
        float _815 = _814 * _813;
        float _816 = _815 * _812;
        float _817 = _816 + _809;
        _907 = _817;
      } else {
        bool _819 = !(_576 <= (User_000.UserConstant_Z_000[4].z));
        if (!_819) {
          float _821 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _822 = max(9.999999974752427e-07f, _821);
          float _823 = _576 - (User_000.UserConstant_Z_000[4].x);
          float _824 = _823 / _822;
          float _825 = 1.0f - _824;
          float _826 = _825 * (User_000.UserConstant_Z_000[4].y);
          float _827 = _824 * (User_000.UserConstant_Z_000[4].w);
          float _828 = _826 + _827;
          float _829 = _825 * _825;
          float _830 = _829 * _825;
          float _831 = _830 - _825;
          float _832 = _831 * (User_000.UserConstant_Z_000[10].x);
          float _833 = _824 * _824;
          float _834 = _833 * _824;
          float _835 = _834 - _824;
          float _836 = _835 * (User_000.UserConstant_Z_000[10].y);
          float _837 = _832 + _836;
          float _838 = _822 * _822;
          float _839 = _838 * 0.1666666716337204f;
          float _840 = _839 * _837;
          float _841 = _828 + _840;
          _907 = _841;
        } else {
          bool _843 = !(_576 <= (User_000.UserConstant_Z_000[9].x));
          if (!_843) {
            float _845 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _846 = max(9.999999974752427e-07f, _845);
            float _847 = _576 - (User_000.UserConstant_Z_000[4].z);
            float _848 = _847 / _846;
            float _849 = 1.0f - _848;
            float _850 = _849 * (User_000.UserConstant_Z_000[4].w);
            float _851 = _848 * (User_000.UserConstant_Z_000[9].y);
            float _852 = _850 + _851;
            float _853 = _849 * _849;
            float _854 = _853 * _849;
            float _855 = _854 - _849;
            float _856 = _855 * (User_000.UserConstant_Z_000[10].y);
            float _857 = _848 * _848;
            float _858 = _857 * _848;
            float _859 = _858 - _848;
            float _860 = _859 * (User_000.UserConstant_Z_000[10].z);
            float _861 = _856 + _860;
            float _862 = _846 * _846;
            float _863 = _862 * 0.1666666716337204f;
            float _864 = _863 * _861;
            float _865 = _852 + _864;
            _907 = _865;
          } else {
            bool _867 = !(_576 <= (User_000.UserConstant_Z_000[9].z));
            if (!_867) {
              float _869 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _870 = max(9.999999974752427e-07f, _869);
              float _871 = _576 - (User_000.UserConstant_Z_000[9].x);
              float _872 = _871 / _870;
              float _873 = 1.0f - _872;
              float _874 = _873 * (User_000.UserConstant_Z_000[9].y);
              float _875 = _872 * (User_000.UserConstant_Z_000[9].w);
              float _876 = _874 + _875;
              float _877 = _873 * _873;
              float _878 = _877 * _873;
              float _879 = _878 - _873;
              float _880 = _879 * (User_000.UserConstant_Z_000[10].z);
              float _881 = _872 * _872;
              float _882 = _881 * _872;
              float _883 = _882 - _872;
              float _884 = _883 * (User_000.UserConstant_Z_000[10].w);
              float _885 = _880 + _884;
              float _886 = _870 * _870;
              float _887 = _886 * 0.1666666716337204f;
              float _888 = _887 * _885;
              float _889 = _876 + _888;
              _907 = _889;
            } else {
              float _891 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _892 = _576 - (User_000.UserConstant_Z_000[9].z);
              float _893 = max(9.999999974752427e-07f, _891);
              float _894 = _892 / _893;
              float _895 = 1.0f - _894;
              float _896 = _895 * (User_000.UserConstant_Z_000[9].w);
              float _897 = _896 + _894;
              float _898 = _895 * _895;
              float _899 = _898 * _895;
              float _900 = _899 - _895;
              float _901 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _902 = _891 * _891;
              float _903 = _902 * _901;
              float _904 = _903 * _900;
              float _905 = _897 + _904;
              _907 = _905;
            }
          }
        }
      }
      float _908 = saturate(_907);
      _910 = _700;
      _911 = _804;
      _912 = _908;
    } else {
      _910 = _574;
      _911 = _575;
      _912 = _576;
    }
    int _913 = _578 & 2;
    bool _914 = (_913 == 0);
    if (!_914) {
      float _916 = sqrt(_910);
      float _917 = sqrt(_911);
      float _918 = sqrt(_912);
      float _919 = dot(float3(_916, _917, _918), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _920 = 1.0f - _919;
      float _921 = saturate(_920);
      _923 = _921;
    } else {
      _923 = 1.0f;
    }
    int _924 = _578 & 8;
    bool _925 = (_924 == 0);
    if (_925) {
      int _927 = _578 & 4;
      bool _928 = (_927 == 0);
      if (!_928) {
        int _930 = _578 & 16;
        bool _931 = (_930 == 0);
        if (!_931) {
          float _935 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _936 = _935 + 0.5f;
          bool _937 = (_936 < 0.5f);
          float _938 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _939 = select(_937, (User_000.UserConstant_Z_000[5].x), _938);
          bool _940 = (_911 < _912);
          float _941 = select(_940, _912, _911);
          float _942 = select(_940, _911, _912);
          bool _943 = (_910 < _941);
          float _944 = select(_943, _941, _910);
          float _945 = select(_943, _910, _941);
          float _946 = min(_945, _942);
          float _947 = _944 - _946;
          float _948 = _944 + 1.000000013351432e-10f;
          float _949 = _947 / _948;
          float _951 = _949 - (User_000.UserConstant_Z_000[5].y);
          float _952 = saturate(_951);
          float _953 = max(_952, 9.999999974752427e-07f);
          float _954 = log2(_953);
          float _955 = _954 * _939;
          float _956 = exp2(_955);
          float _957 = 2.0f - _956;
          float _959 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _960 = saturate(_959);
          float _961 = max(_960, _957);
          float _962 = dot(float3(_910, _911, _912), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _963 = _910 - _962;
          float _964 = _911 - _962;
          float _965 = _912 - _962;
          float _966 = _963 * _961;
          float _967 = _964 * _961;
          float _968 = _965 * _961;
          float _969 = _962 - _910;
          float _970 = _969 + _966;
          float _971 = _962 - _911;
          float _972 = _971 + _967;
          float _973 = _962 - _912;
          float _974 = _973 + _968;
          float _975 = _970 * _923;
          float _976 = _972 * _923;
          float _977 = _974 * _923;
          float _978 = _975 + _910;
          float _979 = _976 + _911;
          float _980 = _977 + _912;
          _1097 = _978;
          _1098 = _979;
          _1099 = _980;
        } else {
          bool _982 = (_923 == 0.0f);
          if (!_982) {
            float _986 = abs(User_000.UserConstant_Z_000[5].x);
            float _987 = saturate(_986);
            uint4 _989 = 0u; t15.GetDimensions(0u, _989.x, _989.y, _989.w);
            float _992 = float((uint)_989.y);
            int _993 = _578 & 32;
            bool _994 = (_993 == 0);
            float _995 = _992 + -1.0f;
            if (!_994) {
              float _997 = 1.0f / _995;
              uint _998 = uint(SV_Position.x);
              uint _999 = uint(SV_Position.y);
              int _1000 = _998 & 63;
              int _1001 = _999 & 63;
              float4 _1003 = t2.Load(int4(_1000, _1001, 0, 0));
              float _1006 = _1003.x + -0.5f;
              float _1007 = _910 * 13.999999046325684f;
              float _1008 = _911 * 13.999999046325684f;
              float _1009 = _912 * 13.999999046325684f;
              float _1010 = saturate(_1007);
              float _1011 = saturate(_1008);
              float _1012 = saturate(_1009);
              float _1013 = _910 + -0.9285714030265808f;
              float _1014 = _911 + -0.9285714030265808f;
              float _1015 = _912 + -0.9285714030265808f;
              float _1016 = _1013 * 13.999999046325684f;
              float _1017 = _1014 * 13.999999046325684f;
              float _1018 = _1015 * 13.999999046325684f;
              float _1019 = saturate(_1016);
              float _1020 = saturate(_1017);
              float _1021 = saturate(_1018);
              float _1022 = 1.0f - _1019;
              float _1023 = 1.0f - _1020;
              float _1024 = 1.0f - _1021;
              float _1025 = min(_1010, _1022);
              float _1026 = min(_1011, _1023);
              float _1027 = min(_1012, _1024);
              float _1028 = _1003.y + -0.5f;
              float _1029 = _1025 * _1028;
              float _1030 = _1026 * _1028;
              float _1031 = _1027 * _1028;
              float _1032 = _1029 + _1006;
              float _1033 = _1030 + _1006;
              float _1034 = _1031 + _1006;
              float _1035 = _1032 * _997;
              float _1036 = _1033 * _997;
              float _1037 = _1034 * _997;
              float _1038 = _1035 + _910;
              float _1039 = _1036 + _911;
              float _1040 = _1037 + _912;
              float _1041 = saturate(_1038);
              float _1042 = saturate(_1039);
              float _1043 = saturate(_1040);
              float _1044 = saturate(_1041);
              float _1045 = saturate(_1042);
              float _1046 = saturate(_1043);
              _1048 = _1044;
              _1049 = _1045;
              _1050 = _1046;
            } else {
              _1048 = _910;
              _1049 = _911;
              _1050 = _912;
            }
            float _1051 = float((uint)_989.x);
            float _1052 = _995 / _1051;
            float _1053 = _1052 * _1048;
            float _1054 = 0.5f / _1051;
            float _1055 = _1053 + _1054;
            float _1056 = _995 / _992;
            float _1057 = _1056 * _1049;
            float _1058 = 0.5f / _992;
            float _1059 = _1057 + _1058;
            float _1060 = _1050 * _995;
            float _1061 = floor(_1060);
            float _1062 = frac(_1060);
            float _1063 = _1061 / _992;
            float _1064 = _1063 + _1055;
            float _1065 = _1061 + 1.0f;
            float _1066 = _1065 / _992;
            float _1067 = _1066 + _1055;
            float4 _1069 = t15.Sample(s1, float2(_1064, _1059));
            float4 _1073 = t15.Sample(s1, float2(_1067, _1059));
            float _1077 = _1073.x - _1069.x;
            float _1078 = _1073.y - _1069.y;
            float _1079 = _1073.z - _1069.z;
            float _1080 = _1077 * _1062;
            float _1081 = _1078 * _1062;
            float _1082 = _1079 * _1062;
            float _1083 = _987 * _923;
            float _1084 = _1069.x - _910;
            float _1085 = _1084 + _1080;
            float _1086 = _1069.y - _911;
            float _1087 = _1086 + _1081;
            float _1088 = _1069.z - _912;
            float _1089 = _1088 + _1082;
            float _1090 = _1085 * _1083;
            float _1091 = _1087 * _1083;
            float _1092 = _1089 * _1083;
            float _1093 = _1090 + _910;
            float _1094 = _1091 + _911;
            float _1095 = _1092 + _912;
            _1097 = _1093;
            _1098 = _1094;
            _1099 = _1095;
          } else {
            _1097 = _910;
            _1098 = _911;
            _1099 = _912;
          }
        }
      } else {
        _1097 = _910;
        _1098 = _911;
        _1099 = _912;
      }
    } else {
      _1097 = _923;
      _1098 = _923;
      _1099 = _923;
    }
    float _1100 = _1097 * 13.450128555297852f;
    float _1101 = _1098 * 13.450128555297852f;
    float _1102 = _1099 * 13.450128555297852f;
    float _1103 = exp2(_1100);
    float _1104 = exp2(_1101);
    float _1105 = exp2(_1102);
    float _1106 = _1103 + -1.0f;
    float _1107 = _1104 + -1.0f;
    float _1108 = _1105 + -1.0f;
    float _1109 = _1106 * _556;
    float _1110 = _1107 * _556;
    float _1111 = _1108 * _556;
    _1113 = _1109;
    _1114 = _1110;
    _1115 = _1111;
  } else {
    _1113 = _557;
    _1114 = _558;
    _1115 = _559;
  }
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1113, (User_000.UserConstant_Z_000[8].y) * _1114, (User_000.UserConstant_Z_000[8].z) * _1115),
      SV_Position.xy);
  float _1122 = resonance_perceptual_film_grain.x;
  float _1123 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1124 = log2(_1122);
  float _1125 = _1123 * _1124;
  float _1126 = exp2(_1125);
  float _1127 = _1126 + -1.0f;
  float _1128 = _1122 + -1.0f;
  float _1129 = _1127 / _1128;
  bool _1130 = !(_1122 == 1.0f);
  float _1131 = _1129 + -1.0f;
  float _1132 = _1131 / _1129;
  float _1133 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1134 = _1133 / _1123;
  float _1135 = select(_1130, _1132, _1134);
  float _1136 = resonance_perceptual_film_grain.y;
  float _1137 = log2(_1136);
  float _1138 = _1137 * _1123;
  float _1139 = exp2(_1138);
  float _1140 = _1139 + -1.0f;
  float _1141 = _1136 + -1.0f;
  float _1142 = _1140 / _1141;
  bool _1143 = !(_1136 == 1.0f);
  float _1144 = _1142 + -1.0f;
  float _1145 = _1144 / _1142;
  float _1146 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1147 = _1146 / _1123;
  float _1148 = select(_1143, _1145, _1147);
  float _1149 = resonance_perceptual_film_grain.z;
  float _1150 = log2(_1149);
  float _1151 = _1150 * _1123;
  float _1152 = exp2(_1151);
  float _1153 = _1152 + -1.0f;
  float _1154 = _1149 + -1.0f;
  float _1155 = _1153 / _1154;
  bool _1156 = !(_1149 == 1.0f);
  float _1157 = _1155 + -1.0f;
  float _1158 = _1157 / _1155;
  float _1159 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1160 = _1159 / _1123;
  float _1161 = select(_1156, _1158, _1160);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1122, _1136, _1149),
      float3(_1135, _1148, _1161),
      true);
  float _1162 = resonance_post_process_output.x;
  float _1163 = resonance_post_process_output.y;
  float _1164 = resonance_post_process_output.z;
  float _1165 = log2(_1162);
  float _1166 = log2(_1163);
  float _1167 = log2(_1164);
  float _1168 = _1165 * 0.4166666567325592f;
  float _1169 = _1166 * 0.4166666567325592f;
  float _1170 = _1167 * 0.4166666567325592f;
  float _1171 = exp2(_1168);
  float _1172 = exp2(_1169);
  float _1173 = exp2(_1170);
  float _1174 = _1171 * 1.0549999475479126f;
  float _1175 = _1172 * 1.0549999475479126f;
  float _1176 = _1173 * 1.0549999475479126f;
  float _1177 = _1174 + -0.054999999701976776f;
  float _1178 = _1175 + -0.054999999701976776f;
  float _1179 = _1176 + -0.054999999701976776f;
  float _1180 = _1162 * 12.920000076293945f;
  float _1181 = _1163 * 12.920000076293945f;
  float _1182 = _1164 * 12.920000076293945f;
  bool _1183 = (_1162 <= 0.0031308000907301903f);
  bool _1184 = (_1163 <= 0.0031308000907301903f);
  bool _1185 = (_1164 <= 0.0031308000907301903f);
  float _1186 = select(_1183, _1180, _1177);
  float _1187 = select(_1184, _1181, _1178);
  float _1188 = select(_1185, _1182, _1179);
  int _1191 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1192 = uint(SV_Position.x);
  uint _1193 = uint(SV_Position.y);
  int _1194 = _1192 & 63;
  int _1195 = _1193 & 63;
  float4 _1197 = t1.Load(int4(_1194, _1195, _1191, 0));
  float _1199 = _1197.x + -0.5f;
  float _1200 = _1199 * 0.003921568859368563f;
  float _1201 = _1200 + _1186;
  float _1202 = _1200 + _1187;
  float _1203 = _1200 + _1188;
  float _1204 = saturate(_1201);
  float _1205 = saturate(_1202);
  float _1206 = saturate(_1203);
  SV_Target.x = _1204;
  SV_Target.y = _1205;
  SV_Target.z = _1206;
  SV_Target.w = _370;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}