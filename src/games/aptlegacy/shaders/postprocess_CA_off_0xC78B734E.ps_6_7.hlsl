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
  float _664;
  float _768;
  float _872;
  float _875;
  float _876;
  float _877;
  float _888;
  float _1013;
  float _1014;
  float _1015;
  float _1062;
  float _1063;
  float _1064;
  float _1078;
  float _1079;
  float _1080;
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
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
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
  float _476 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _477 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _478 = _468.x * _477;
  float _479 = _478 * _462;
  float _480 = _479 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _481 = _480 * _476;
  float _482 = _478 * _463;
  float _483 = _482 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _484 = _483 * _476;
  float _485 = _478 * _464;
  float _486 = _485 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _487 = _486 * _476;
  float _488 = _481 + 1.0f;
  float _489 = _484 + 1.0f;
  float _490 = _487 + 1.0f;
  float _491 = log2(_488);
  float _492 = log2(_489);
  float _493 = log2(_490);
  float _496 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _497 = _496 * _491;
  float _498 = _496 * _492;
  float _499 = _496 * _493;
  float _501 = _497 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _502 = _498 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _503 = _499 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _506 = t3.Sample(s3, float3(_501, _502, _503));
  float _512 = _506.x * 13.450128555297852f;
  float _513 = _506.y * 13.450128555297852f;
  float _514 = _506.z * 13.450128555297852f;
  float _515 = exp2(_512);
  float _516 = exp2(_513);
  float _517 = exp2(_514);
  float _518 = _515 + -1.0f;
  float _519 = _516 + -1.0f;
  float _520 = _517 + -1.0f;
  float _521 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _522 = _521 * _518;
  float _523 = _521 * _519;
  float _524 = _521 * _520;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_481 * _521, _484 * _521, _487 * _521),
      float3(_522, _523, _524),
      1.f.xxx);
  _522 = apt_scaled_lut_output.x;
  _523 = apt_scaled_lut_output.y;
  _524 = apt_scaled_lut_output.z;
  bool _527 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !APTIsPsychoV();
  if (_527) {
    float _529 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _530 = _522 * _529;
    float _531 = _523 * _529;
    float _532 = _524 * _529;
    float _533 = _530 + 1.0f;
    float _534 = _531 + 1.0f;
    float _535 = _532 + 1.0f;
    float _536 = log2(_533);
    float _537 = log2(_534);
    float _538 = log2(_535);
    float _539 = _536 * 0.07434873282909393f;
    float _540 = _537 * 0.07434873282909393f;
    float _541 = _538 * 0.07434873282909393f;
    int _543 = asint((User_000.UserConstant_Z_000[3].y));
    int _544 = _543 & 1;
    bool _545 = (_544 == 0);
    if (!_545) {
      bool _562 = !(_539 <= (User_000.UserConstant_Z_000[4].x));
      if (!_562) {
        float _564 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _565 = _539 / _564;
        float _566 = _565 * (User_000.UserConstant_Z_000[4].y);
        float _567 = _565 * _565;
        float _568 = _567 * _565;
        float _569 = _568 - _565;
        float _570 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _571 = _564 * _564;
        float _572 = _571 * _570;
        float _573 = _572 * _569;
        float _574 = _573 + _566;
        _664 = _574;
      } else {
        bool _576 = !(_539 <= (User_000.UserConstant_Z_000[4].z));
        if (!_576) {
          float _578 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _579 = max(9.999999974752427e-07f, _578);
          float _580 = _539 - (User_000.UserConstant_Z_000[4].x);
          float _581 = _580 / _579;
          float _582 = 1.0f - _581;
          float _583 = _582 * (User_000.UserConstant_Z_000[4].y);
          float _584 = _581 * (User_000.UserConstant_Z_000[4].w);
          float _585 = _583 + _584;
          float _586 = _582 * _582;
          float _587 = _586 * _582;
          float _588 = _587 - _582;
          float _589 = _588 * (User_000.UserConstant_Z_000[10].x);
          float _590 = _581 * _581;
          float _591 = _590 * _581;
          float _592 = _591 - _581;
          float _593 = _592 * (User_000.UserConstant_Z_000[10].y);
          float _594 = _589 + _593;
          float _595 = _579 * _579;
          float _596 = _595 * 0.1666666716337204f;
          float _597 = _596 * _594;
          float _598 = _585 + _597;
          _664 = _598;
        } else {
          bool _600 = !(_539 <= (User_000.UserConstant_Z_000[9].x));
          if (!_600) {
            float _602 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _603 = max(9.999999974752427e-07f, _602);
            float _604 = _539 - (User_000.UserConstant_Z_000[4].z);
            float _605 = _604 / _603;
            float _606 = 1.0f - _605;
            float _607 = _606 * (User_000.UserConstant_Z_000[4].w);
            float _608 = _605 * (User_000.UserConstant_Z_000[9].y);
            float _609 = _607 + _608;
            float _610 = _606 * _606;
            float _611 = _610 * _606;
            float _612 = _611 - _606;
            float _613 = _612 * (User_000.UserConstant_Z_000[10].y);
            float _614 = _605 * _605;
            float _615 = _614 * _605;
            float _616 = _615 - _605;
            float _617 = _616 * (User_000.UserConstant_Z_000[10].z);
            float _618 = _613 + _617;
            float _619 = _603 * _603;
            float _620 = _619 * 0.1666666716337204f;
            float _621 = _620 * _618;
            float _622 = _609 + _621;
            _664 = _622;
          } else {
            bool _624 = !(_539 <= (User_000.UserConstant_Z_000[9].z));
            if (!_624) {
              float _626 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _627 = max(9.999999974752427e-07f, _626);
              float _628 = _539 - (User_000.UserConstant_Z_000[9].x);
              float _629 = _628 / _627;
              float _630 = 1.0f - _629;
              float _631 = _630 * (User_000.UserConstant_Z_000[9].y);
              float _632 = _629 * (User_000.UserConstant_Z_000[9].w);
              float _633 = _631 + _632;
              float _634 = _630 * _630;
              float _635 = _634 * _630;
              float _636 = _635 - _630;
              float _637 = _636 * (User_000.UserConstant_Z_000[10].z);
              float _638 = _629 * _629;
              float _639 = _638 * _629;
              float _640 = _639 - _629;
              float _641 = _640 * (User_000.UserConstant_Z_000[10].w);
              float _642 = _637 + _641;
              float _643 = _627 * _627;
              float _644 = _643 * 0.1666666716337204f;
              float _645 = _644 * _642;
              float _646 = _633 + _645;
              _664 = _646;
            } else {
              float _648 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _649 = _539 - (User_000.UserConstant_Z_000[9].z);
              float _650 = max(9.999999974752427e-07f, _648);
              float _651 = _649 / _650;
              float _652 = 1.0f - _651;
              float _653 = _652 * (User_000.UserConstant_Z_000[9].w);
              float _654 = _653 + _651;
              float _655 = _652 * _652;
              float _656 = _655 * _652;
              float _657 = _656 - _652;
              float _658 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _659 = _648 * _648;
              float _660 = _659 * _658;
              float _661 = _660 * _657;
              float _662 = _654 + _661;
              _664 = _662;
            }
          }
        }
      }
      float _665 = saturate(_664);
      bool _666 = !(_540 <= (User_000.UserConstant_Z_000[4].x));
      if (!_666) {
        float _668 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _669 = _540 / _668;
        float _670 = _669 * (User_000.UserConstant_Z_000[4].y);
        float _671 = _669 * _669;
        float _672 = _671 * _669;
        float _673 = _672 - _669;
        float _674 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _675 = _668 * _668;
        float _676 = _675 * _674;
        float _677 = _676 * _673;
        float _678 = _677 + _670;
        _768 = _678;
      } else {
        bool _680 = !(_540 <= (User_000.UserConstant_Z_000[4].z));
        if (!_680) {
          float _682 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _683 = max(9.999999974752427e-07f, _682);
          float _684 = _540 - (User_000.UserConstant_Z_000[4].x);
          float _685 = _684 / _683;
          float _686 = 1.0f - _685;
          float _687 = _686 * (User_000.UserConstant_Z_000[4].y);
          float _688 = _685 * (User_000.UserConstant_Z_000[4].w);
          float _689 = _687 + _688;
          float _690 = _686 * _686;
          float _691 = _690 * _686;
          float _692 = _691 - _686;
          float _693 = _692 * (User_000.UserConstant_Z_000[10].x);
          float _694 = _685 * _685;
          float _695 = _694 * _685;
          float _696 = _695 - _685;
          float _697 = _696 * (User_000.UserConstant_Z_000[10].y);
          float _698 = _693 + _697;
          float _699 = _683 * _683;
          float _700 = _699 * 0.1666666716337204f;
          float _701 = _700 * _698;
          float _702 = _689 + _701;
          _768 = _702;
        } else {
          bool _704 = !(_540 <= (User_000.UserConstant_Z_000[9].x));
          if (!_704) {
            float _706 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _707 = max(9.999999974752427e-07f, _706);
            float _708 = _540 - (User_000.UserConstant_Z_000[4].z);
            float _709 = _708 / _707;
            float _710 = 1.0f - _709;
            float _711 = _710 * (User_000.UserConstant_Z_000[4].w);
            float _712 = _709 * (User_000.UserConstant_Z_000[9].y);
            float _713 = _711 + _712;
            float _714 = _710 * _710;
            float _715 = _714 * _710;
            float _716 = _715 - _710;
            float _717 = _716 * (User_000.UserConstant_Z_000[10].y);
            float _718 = _709 * _709;
            float _719 = _718 * _709;
            float _720 = _719 - _709;
            float _721 = _720 * (User_000.UserConstant_Z_000[10].z);
            float _722 = _717 + _721;
            float _723 = _707 * _707;
            float _724 = _723 * 0.1666666716337204f;
            float _725 = _724 * _722;
            float _726 = _713 + _725;
            _768 = _726;
          } else {
            bool _728 = !(_540 <= (User_000.UserConstant_Z_000[9].z));
            if (!_728) {
              float _730 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _731 = max(9.999999974752427e-07f, _730);
              float _732 = _540 - (User_000.UserConstant_Z_000[9].x);
              float _733 = _732 / _731;
              float _734 = 1.0f - _733;
              float _735 = _734 * (User_000.UserConstant_Z_000[9].y);
              float _736 = _733 * (User_000.UserConstant_Z_000[9].w);
              float _737 = _735 + _736;
              float _738 = _734 * _734;
              float _739 = _738 * _734;
              float _740 = _739 - _734;
              float _741 = _740 * (User_000.UserConstant_Z_000[10].z);
              float _742 = _733 * _733;
              float _743 = _742 * _733;
              float _744 = _743 - _733;
              float _745 = _744 * (User_000.UserConstant_Z_000[10].w);
              float _746 = _741 + _745;
              float _747 = _731 * _731;
              float _748 = _747 * 0.1666666716337204f;
              float _749 = _748 * _746;
              float _750 = _737 + _749;
              _768 = _750;
            } else {
              float _752 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _753 = _540 - (User_000.UserConstant_Z_000[9].z);
              float _754 = max(9.999999974752427e-07f, _752);
              float _755 = _753 / _754;
              float _756 = 1.0f - _755;
              float _757 = _756 * (User_000.UserConstant_Z_000[9].w);
              float _758 = _757 + _755;
              float _759 = _756 * _756;
              float _760 = _759 * _756;
              float _761 = _760 - _756;
              float _762 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _763 = _752 * _752;
              float _764 = _763 * _762;
              float _765 = _764 * _761;
              float _766 = _758 + _765;
              _768 = _766;
            }
          }
        }
      }
      float _769 = saturate(_768);
      bool _770 = !(_541 <= (User_000.UserConstant_Z_000[4].x));
      if (!_770) {
        float _772 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _773 = _541 / _772;
        float _774 = _773 * (User_000.UserConstant_Z_000[4].y);
        float _775 = _773 * _773;
        float _776 = _775 * _773;
        float _777 = _776 - _773;
        float _778 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _779 = _772 * _772;
        float _780 = _779 * _778;
        float _781 = _780 * _777;
        float _782 = _781 + _774;
        _872 = _782;
      } else {
        bool _784 = !(_541 <= (User_000.UserConstant_Z_000[4].z));
        if (!_784) {
          float _786 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _787 = max(9.999999974752427e-07f, _786);
          float _788 = _541 - (User_000.UserConstant_Z_000[4].x);
          float _789 = _788 / _787;
          float _790 = 1.0f - _789;
          float _791 = _790 * (User_000.UserConstant_Z_000[4].y);
          float _792 = _789 * (User_000.UserConstant_Z_000[4].w);
          float _793 = _791 + _792;
          float _794 = _790 * _790;
          float _795 = _794 * _790;
          float _796 = _795 - _790;
          float _797 = _796 * (User_000.UserConstant_Z_000[10].x);
          float _798 = _789 * _789;
          float _799 = _798 * _789;
          float _800 = _799 - _789;
          float _801 = _800 * (User_000.UserConstant_Z_000[10].y);
          float _802 = _797 + _801;
          float _803 = _787 * _787;
          float _804 = _803 * 0.1666666716337204f;
          float _805 = _804 * _802;
          float _806 = _793 + _805;
          _872 = _806;
        } else {
          bool _808 = !(_541 <= (User_000.UserConstant_Z_000[9].x));
          if (!_808) {
            float _810 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _811 = max(9.999999974752427e-07f, _810);
            float _812 = _541 - (User_000.UserConstant_Z_000[4].z);
            float _813 = _812 / _811;
            float _814 = 1.0f - _813;
            float _815 = _814 * (User_000.UserConstant_Z_000[4].w);
            float _816 = _813 * (User_000.UserConstant_Z_000[9].y);
            float _817 = _815 + _816;
            float _818 = _814 * _814;
            float _819 = _818 * _814;
            float _820 = _819 - _814;
            float _821 = _820 * (User_000.UserConstant_Z_000[10].y);
            float _822 = _813 * _813;
            float _823 = _822 * _813;
            float _824 = _823 - _813;
            float _825 = _824 * (User_000.UserConstant_Z_000[10].z);
            float _826 = _821 + _825;
            float _827 = _811 * _811;
            float _828 = _827 * 0.1666666716337204f;
            float _829 = _828 * _826;
            float _830 = _817 + _829;
            _872 = _830;
          } else {
            bool _832 = !(_541 <= (User_000.UserConstant_Z_000[9].z));
            if (!_832) {
              float _834 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _835 = max(9.999999974752427e-07f, _834);
              float _836 = _541 - (User_000.UserConstant_Z_000[9].x);
              float _837 = _836 / _835;
              float _838 = 1.0f - _837;
              float _839 = _838 * (User_000.UserConstant_Z_000[9].y);
              float _840 = _837 * (User_000.UserConstant_Z_000[9].w);
              float _841 = _839 + _840;
              float _842 = _838 * _838;
              float _843 = _842 * _838;
              float _844 = _843 - _838;
              float _845 = _844 * (User_000.UserConstant_Z_000[10].z);
              float _846 = _837 * _837;
              float _847 = _846 * _837;
              float _848 = _847 - _837;
              float _849 = _848 * (User_000.UserConstant_Z_000[10].w);
              float _850 = _845 + _849;
              float _851 = _835 * _835;
              float _852 = _851 * 0.1666666716337204f;
              float _853 = _852 * _850;
              float _854 = _841 + _853;
              _872 = _854;
            } else {
              float _856 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _857 = _541 - (User_000.UserConstant_Z_000[9].z);
              float _858 = max(9.999999974752427e-07f, _856);
              float _859 = _857 / _858;
              float _860 = 1.0f - _859;
              float _861 = _860 * (User_000.UserConstant_Z_000[9].w);
              float _862 = _861 + _859;
              float _863 = _860 * _860;
              float _864 = _863 * _860;
              float _865 = _864 - _860;
              float _866 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _867 = _856 * _856;
              float _868 = _867 * _866;
              float _869 = _868 * _865;
              float _870 = _862 + _869;
              _872 = _870;
            }
          }
        }
      }
      float _873 = saturate(_872);
      _875 = _665;
      _876 = _769;
      _877 = _873;
    } else {
      _875 = _539;
      _876 = _540;
      _877 = _541;
    }
    int _878 = _543 & 2;
    bool _879 = (_878 == 0);
    if (!_879) {
      float _881 = sqrt(_875);
      float _882 = sqrt(_876);
      float _883 = sqrt(_877);
      float _884 = dot(float3(_881, _882, _883), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _885 = 1.0f - _884;
      float _886 = saturate(_885);
      _888 = _886;
    } else {
      _888 = 1.0f;
    }
    int _889 = _543 & 8;
    bool _890 = (_889 == 0);
    if (_890) {
      int _892 = _543 & 4;
      bool _893 = (_892 == 0);
      if (!_893) {
        int _895 = _543 & 16;
        bool _896 = (_895 == 0);
        if (!_896) {
          float _900 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _901 = _900 + 0.5f;
          bool _902 = (_901 < 0.5f);
          float _903 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _904 = select(_902, (User_000.UserConstant_Z_000[5].x), _903);
          bool _905 = (_876 < _877);
          float _906 = select(_905, _877, _876);
          float _907 = select(_905, _876, _877);
          bool _908 = (_875 < _906);
          float _909 = select(_908, _906, _875);
          float _910 = select(_908, _875, _906);
          float _911 = min(_910, _907);
          float _912 = _909 - _911;
          float _913 = _909 + 1.000000013351432e-10f;
          float _914 = _912 / _913;
          float _916 = _914 - (User_000.UserConstant_Z_000[5].y);
          float _917 = saturate(_916);
          float _918 = max(_917, 9.999999974752427e-07f);
          float _919 = log2(_918);
          float _920 = _919 * _904;
          float _921 = exp2(_920);
          float _922 = 2.0f - _921;
          float _924 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _925 = saturate(_924);
          float _926 = max(_925, _922);
          float _927 = dot(float3(_875, _876, _877), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _928 = _875 - _927;
          float _929 = _876 - _927;
          float _930 = _877 - _927;
          float _931 = _928 * _926;
          float _932 = _929 * _926;
          float _933 = _930 * _926;
          float _934 = _927 - _875;
          float _935 = _934 + _931;
          float _936 = _927 - _876;
          float _937 = _936 + _932;
          float _938 = _927 - _877;
          float _939 = _938 + _933;
          float _940 = _935 * _888;
          float _941 = _937 * _888;
          float _942 = _939 * _888;
          float _943 = _940 + _875;
          float _944 = _941 + _876;
          float _945 = _942 + _877;
          _1062 = _943;
          _1063 = _944;
          _1064 = _945;
        } else {
          bool _947 = (_888 == 0.0f);
          if (!_947) {
            float _951 = abs(User_000.UserConstant_Z_000[5].x);
            float _952 = saturate(_951);
            uint4 _954 = 0u; t15.GetDimensions(0u, _954.x, _954.y, _954.w);
            float _957 = float((uint)_954.y);
            int _958 = _543 & 32;
            bool _959 = (_958 == 0);
            float _960 = _957 + -1.0f;
            if (!_959) {
              float _962 = 1.0f / _960;
              uint _963 = uint(SV_Position.x);
              uint _964 = uint(SV_Position.y);
              int _965 = _963 & 63;
              int _966 = _964 & 63;
              float4 _968 = t2.Load(int4(_965, _966, 0, 0));
              float _971 = _968.x + -0.5f;
              float _972 = _875 * 13.999999046325684f;
              float _973 = _876 * 13.999999046325684f;
              float _974 = _877 * 13.999999046325684f;
              float _975 = saturate(_972);
              float _976 = saturate(_973);
              float _977 = saturate(_974);
              float _978 = _875 + -0.9285714030265808f;
              float _979 = _876 + -0.9285714030265808f;
              float _980 = _877 + -0.9285714030265808f;
              float _981 = _978 * 13.999999046325684f;
              float _982 = _979 * 13.999999046325684f;
              float _983 = _980 * 13.999999046325684f;
              float _984 = saturate(_981);
              float _985 = saturate(_982);
              float _986 = saturate(_983);
              float _987 = 1.0f - _984;
              float _988 = 1.0f - _985;
              float _989 = 1.0f - _986;
              float _990 = min(_975, _987);
              float _991 = min(_976, _988);
              float _992 = min(_977, _989);
              float _993 = _968.y + -0.5f;
              float _994 = _990 * _993;
              float _995 = _991 * _993;
              float _996 = _992 * _993;
              float _997 = _994 + _971;
              float _998 = _995 + _971;
              float _999 = _996 + _971;
              float _1000 = _997 * _962;
              float _1001 = _998 * _962;
              float _1002 = _999 * _962;
              float _1003 = _1000 + _875;
              float _1004 = _1001 + _876;
              float _1005 = _1002 + _877;
              float _1006 = saturate(_1003);
              float _1007 = saturate(_1004);
              float _1008 = saturate(_1005);
              float _1009 = saturate(_1006);
              float _1010 = saturate(_1007);
              float _1011 = saturate(_1008);
              _1013 = _1009;
              _1014 = _1010;
              _1015 = _1011;
            } else {
              _1013 = _875;
              _1014 = _876;
              _1015 = _877;
            }
            float _1016 = float((uint)_954.x);
            float _1017 = _960 / _1016;
            float _1018 = _1017 * _1013;
            float _1019 = 0.5f / _1016;
            float _1020 = _1018 + _1019;
            float _1021 = _960 / _957;
            float _1022 = _1021 * _1014;
            float _1023 = 0.5f / _957;
            float _1024 = _1022 + _1023;
            float _1025 = _1015 * _960;
            float _1026 = floor(_1025);
            float _1027 = frac(_1025);
            float _1028 = _1026 / _957;
            float _1029 = _1028 + _1020;
            float _1030 = _1026 + 1.0f;
            float _1031 = _1030 / _957;
            float _1032 = _1031 + _1020;
            float4 _1034 = t15.Sample(s1, float2(_1029, _1024));
            float4 _1038 = t15.Sample(s1, float2(_1032, _1024));
            float _1042 = _1038.x - _1034.x;
            float _1043 = _1038.y - _1034.y;
            float _1044 = _1038.z - _1034.z;
            float _1045 = _1042 * _1027;
            float _1046 = _1043 * _1027;
            float _1047 = _1044 * _1027;
            float _1048 = _952 * _888;
            float _1049 = _1034.x - _875;
            float _1050 = _1049 + _1045;
            float _1051 = _1034.y - _876;
            float _1052 = _1051 + _1046;
            float _1053 = _1034.z - _877;
            float _1054 = _1053 + _1047;
            float _1055 = _1050 * _1048;
            float _1056 = _1052 * _1048;
            float _1057 = _1054 * _1048;
            float _1058 = _1055 + _875;
            float _1059 = _1056 + _876;
            float _1060 = _1057 + _877;
            _1062 = _1058;
            _1063 = _1059;
            _1064 = _1060;
          } else {
            _1062 = _875;
            _1063 = _876;
            _1064 = _877;
          }
        }
      } else {
        _1062 = _875;
        _1063 = _876;
        _1064 = _877;
      }
    } else {
      _1062 = _888;
      _1063 = _888;
      _1064 = _888;
    }
    float _1065 = _1062 * 13.450128555297852f;
    float _1066 = _1063 * 13.450128555297852f;
    float _1067 = _1064 * 13.450128555297852f;
    float _1068 = exp2(_1065);
    float _1069 = exp2(_1066);
    float _1070 = exp2(_1067);
    float _1071 = _1068 + -1.0f;
    float _1072 = _1069 + -1.0f;
    float _1073 = _1070 + -1.0f;
    float _1074 = _1071 * _521;
    float _1075 = _1072 * _521;
    float _1076 = _1073 * _521;
    _1078 = _1074;
    _1079 = _1075;
    _1080 = _1076;
  } else {
    _1078 = _522;
    _1079 = _523;
    _1080 = _524;
  }
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1078, (User_000.UserConstant_Z_000[8].y) * _1079, (User_000.UserConstant_Z_000[8].z) * _1080),
      SV_Position.xy);
  float _1087 = apt_perceptual_film_grain.x;
  float _1088 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1089 = log2(_1087);
  float _1090 = _1088 * _1089;
  float _1091 = exp2(_1090);
  float _1092 = _1091 + -1.0f;
  float _1093 = _1087 + -1.0f;
  float _1094 = _1092 / _1093;
  bool _1095 = !(_1087 == 1.0f);
  float _1096 = _1094 + -1.0f;
  float _1097 = _1096 / _1094;
  float _1098 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1099 = _1098 / _1088;
  float _1100 = select(_1095, _1097, _1099);
  float _1101 = apt_perceptual_film_grain.y;
  float _1102 = log2(_1101);
  float _1103 = _1102 * _1088;
  float _1104 = exp2(_1103);
  float _1105 = _1104 + -1.0f;
  float _1106 = _1101 + -1.0f;
  float _1107 = _1105 / _1106;
  bool _1108 = !(_1101 == 1.0f);
  float _1109 = _1107 + -1.0f;
  float _1110 = _1109 / _1107;
  float _1111 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1112 = _1111 / _1088;
  float _1113 = select(_1108, _1110, _1112);
  float _1114 = apt_perceptual_film_grain.z;
  float _1115 = log2(_1114);
  float _1116 = _1115 * _1088;
  float _1117 = exp2(_1116);
  float _1118 = _1117 + -1.0f;
  float _1119 = _1114 + -1.0f;
  float _1120 = _1118 / _1119;
  bool _1121 = !(_1114 == 1.0f);
  float _1122 = _1120 + -1.0f;
  float _1123 = _1122 / _1120;
  float _1124 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1125 = _1124 / _1088;
  float _1126 = select(_1121, _1123, _1125);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1087, _1101, _1114),
      float3(_1100, _1113, _1126),
      true);
  float _1127 = apt_post_process_output.x;
  float _1128 = apt_post_process_output.y;
  float _1129 = apt_post_process_output.z;
  float _1130 = log2(_1127);
  float _1131 = log2(_1128);
  float _1132 = log2(_1129);
  float _1133 = _1130 * 0.4166666567325592f;
  float _1134 = _1131 * 0.4166666567325592f;
  float _1135 = _1132 * 0.4166666567325592f;
  float _1136 = exp2(_1133);
  float _1137 = exp2(_1134);
  float _1138 = exp2(_1135);
  float _1139 = _1136 * 1.0549999475479126f;
  float _1140 = _1137 * 1.0549999475479126f;
  float _1141 = _1138 * 1.0549999475479126f;
  float _1142 = _1139 + -0.054999999701976776f;
  float _1143 = _1140 + -0.054999999701976776f;
  float _1144 = _1141 + -0.054999999701976776f;
  float _1145 = _1127 * 12.920000076293945f;
  float _1146 = _1128 * 12.920000076293945f;
  float _1147 = _1129 * 12.920000076293945f;
  bool _1148 = (_1127 <= 0.0031308000907301903f);
  bool _1149 = (_1128 <= 0.0031308000907301903f);
  bool _1150 = (_1129 <= 0.0031308000907301903f);
  float _1151 = select(_1148, _1145, _1142);
  float _1152 = select(_1149, _1146, _1143);
  float _1153 = select(_1150, _1147, _1144);
  int _1156 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1157 = uint(SV_Position.x);
  uint _1158 = uint(SV_Position.y);
  int _1159 = _1157 & 63;
  int _1160 = _1158 & 63;
  float4 _1162 = t1.Load(int4(_1159, _1160, _1156, 0));
  float _1164 = _1162.x + -0.5f;
  float _1165 = _1164 * 0.003921568859368563f;
  float _1166 = _1165 + _1151;
  float _1167 = _1165 + _1152;
  float _1168 = _1165 + _1153;
  float _1169 = saturate(_1166);
  float _1170 = saturate(_1167);
  float _1171 = saturate(_1168);
  SV_Target.x = _1169;
  SV_Target.y = _1170;
  SV_Target.z = _1171;
  SV_Target.w = _370;
  return SV_Target;
}
