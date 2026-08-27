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
  float _412;
  float _413;
  float _414;
  float _617;
  float _721;
  float _825;
  float _828;
  float _829;
  float _830;
  float _841;
  float _966;
  float _967;
  float _968;
  float _1015;
  float _1016;
  float _1017;
  float _1031;
  float _1032;
  float _1033;
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
  float _429 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _430 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _431 = _421.x * _430;
  float _432 = _431 * _415;
  float _433 = _432 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _434 = _433 * _429;
  float _435 = _431 * _416;
  float _436 = _435 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _437 = _436 * _429;
  float _438 = _431 * _417;
  float _439 = _438 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _440 = _439 * _429;
  float _441 = _434 + 1.0f;
  float _442 = _437 + 1.0f;
  float _443 = _440 + 1.0f;
  float _444 = log2(_441);
  float _445 = log2(_442);
  float _446 = log2(_443);
  float _449 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _450 = _449 * _444;
  float _451 = _449 * _445;
  float _452 = _449 * _446;
  float _454 = _450 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _455 = _451 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _456 = _452 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _459 = t3.Sample(s3, float3(_454, _455, _456));
  float _465 = _459.x * 13.450128555297852f;
  float _466 = _459.y * 13.450128555297852f;
  float _467 = _459.z * 13.450128555297852f;
  float _468 = exp2(_465);
  float _469 = exp2(_466);
  float _470 = exp2(_467);
  float _471 = _468 + -1.0f;
  float _472 = _469 + -1.0f;
  float _473 = _470 + -1.0f;
  float _474 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _475 = _474 * _471;
  float _476 = _474 * _472;
  float _477 = _474 * _473;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_434 * _474, _437 * _474, _440 * _474),
      float3(_475, _476, _477),
      1.f.xxx);
  _475 = apt_scaled_lut_output.x;
  _476 = apt_scaled_lut_output.y;
  _477 = apt_scaled_lut_output.z;
  bool _480 = ((User_000.UserConstant_Z_000[3].x) > 0.0f);
  if (_480) {
    float _482 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _483 = _475 * _482;
    float _484 = _476 * _482;
    float _485 = _477 * _482;
    float _486 = _483 + 1.0f;
    float _487 = _484 + 1.0f;
    float _488 = _485 + 1.0f;
    float _489 = log2(_486);
    float _490 = log2(_487);
    float _491 = log2(_488);
    float _492 = _489 * 0.07434873282909393f;
    float _493 = _490 * 0.07434873282909393f;
    float _494 = _491 * 0.07434873282909393f;
    int _496 = asint((User_000.UserConstant_Z_000[3].y));
    int _497 = _496 & 1;
    bool _498 = (_497 == 0);
    if (!_498) {
      bool _515 = !(_492 <= (User_000.UserConstant_Z_000[4].x));
      if (!_515) {
        float _517 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _518 = _492 / _517;
        float _519 = _518 * (User_000.UserConstant_Z_000[4].y);
        float _520 = _518 * _518;
        float _521 = _520 * _518;
        float _522 = _521 - _518;
        float _523 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _524 = _517 * _517;
        float _525 = _524 * _523;
        float _526 = _525 * _522;
        float _527 = _526 + _519;
        _617 = _527;
      } else {
        bool _529 = !(_492 <= (User_000.UserConstant_Z_000[4].z));
        if (!_529) {
          float _531 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _532 = max(9.999999974752427e-07f, _531);
          float _533 = _492 - (User_000.UserConstant_Z_000[4].x);
          float _534 = _533 / _532;
          float _535 = 1.0f - _534;
          float _536 = _535 * (User_000.UserConstant_Z_000[4].y);
          float _537 = _534 * (User_000.UserConstant_Z_000[4].w);
          float _538 = _536 + _537;
          float _539 = _535 * _535;
          float _540 = _539 * _535;
          float _541 = _540 - _535;
          float _542 = _541 * (User_000.UserConstant_Z_000[10].x);
          float _543 = _534 * _534;
          float _544 = _543 * _534;
          float _545 = _544 - _534;
          float _546 = _545 * (User_000.UserConstant_Z_000[10].y);
          float _547 = _542 + _546;
          float _548 = _532 * _532;
          float _549 = _548 * 0.1666666716337204f;
          float _550 = _549 * _547;
          float _551 = _538 + _550;
          _617 = _551;
        } else {
          bool _553 = !(_492 <= (User_000.UserConstant_Z_000[9].x));
          if (!_553) {
            float _555 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _556 = max(9.999999974752427e-07f, _555);
            float _557 = _492 - (User_000.UserConstant_Z_000[4].z);
            float _558 = _557 / _556;
            float _559 = 1.0f - _558;
            float _560 = _559 * (User_000.UserConstant_Z_000[4].w);
            float _561 = _558 * (User_000.UserConstant_Z_000[9].y);
            float _562 = _560 + _561;
            float _563 = _559 * _559;
            float _564 = _563 * _559;
            float _565 = _564 - _559;
            float _566 = _565 * (User_000.UserConstant_Z_000[10].y);
            float _567 = _558 * _558;
            float _568 = _567 * _558;
            float _569 = _568 - _558;
            float _570 = _569 * (User_000.UserConstant_Z_000[10].z);
            float _571 = _566 + _570;
            float _572 = _556 * _556;
            float _573 = _572 * 0.1666666716337204f;
            float _574 = _573 * _571;
            float _575 = _562 + _574;
            _617 = _575;
          } else {
            bool _577 = !(_492 <= (User_000.UserConstant_Z_000[9].z));
            if (!_577) {
              float _579 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _580 = max(9.999999974752427e-07f, _579);
              float _581 = _492 - (User_000.UserConstant_Z_000[9].x);
              float _582 = _581 / _580;
              float _583 = 1.0f - _582;
              float _584 = _583 * (User_000.UserConstant_Z_000[9].y);
              float _585 = _582 * (User_000.UserConstant_Z_000[9].w);
              float _586 = _584 + _585;
              float _587 = _583 * _583;
              float _588 = _587 * _583;
              float _589 = _588 - _583;
              float _590 = _589 * (User_000.UserConstant_Z_000[10].z);
              float _591 = _582 * _582;
              float _592 = _591 * _582;
              float _593 = _592 - _582;
              float _594 = _593 * (User_000.UserConstant_Z_000[10].w);
              float _595 = _590 + _594;
              float _596 = _580 * _580;
              float _597 = _596 * 0.1666666716337204f;
              float _598 = _597 * _595;
              float _599 = _586 + _598;
              _617 = _599;
            } else {
              float _601 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _602 = _492 - (User_000.UserConstant_Z_000[9].z);
              float _603 = max(9.999999974752427e-07f, _601);
              float _604 = _602 / _603;
              float _605 = 1.0f - _604;
              float _606 = _605 * (User_000.UserConstant_Z_000[9].w);
              float _607 = _606 + _604;
              float _608 = _605 * _605;
              float _609 = _608 * _605;
              float _610 = _609 - _605;
              float _611 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _612 = _601 * _601;
              float _613 = _612 * _611;
              float _614 = _613 * _610;
              float _615 = _607 + _614;
              _617 = _615;
            }
          }
        }
      }
      float _618 = saturate(_617);
      bool _619 = !(_493 <= (User_000.UserConstant_Z_000[4].x));
      if (!_619) {
        float _621 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _622 = _493 / _621;
        float _623 = _622 * (User_000.UserConstant_Z_000[4].y);
        float _624 = _622 * _622;
        float _625 = _624 * _622;
        float _626 = _625 - _622;
        float _627 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _628 = _621 * _621;
        float _629 = _628 * _627;
        float _630 = _629 * _626;
        float _631 = _630 + _623;
        _721 = _631;
      } else {
        bool _633 = !(_493 <= (User_000.UserConstant_Z_000[4].z));
        if (!_633) {
          float _635 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _636 = max(9.999999974752427e-07f, _635);
          float _637 = _493 - (User_000.UserConstant_Z_000[4].x);
          float _638 = _637 / _636;
          float _639 = 1.0f - _638;
          float _640 = _639 * (User_000.UserConstant_Z_000[4].y);
          float _641 = _638 * (User_000.UserConstant_Z_000[4].w);
          float _642 = _640 + _641;
          float _643 = _639 * _639;
          float _644 = _643 * _639;
          float _645 = _644 - _639;
          float _646 = _645 * (User_000.UserConstant_Z_000[10].x);
          float _647 = _638 * _638;
          float _648 = _647 * _638;
          float _649 = _648 - _638;
          float _650 = _649 * (User_000.UserConstant_Z_000[10].y);
          float _651 = _646 + _650;
          float _652 = _636 * _636;
          float _653 = _652 * 0.1666666716337204f;
          float _654 = _653 * _651;
          float _655 = _642 + _654;
          _721 = _655;
        } else {
          bool _657 = !(_493 <= (User_000.UserConstant_Z_000[9].x));
          if (!_657) {
            float _659 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _660 = max(9.999999974752427e-07f, _659);
            float _661 = _493 - (User_000.UserConstant_Z_000[4].z);
            float _662 = _661 / _660;
            float _663 = 1.0f - _662;
            float _664 = _663 * (User_000.UserConstant_Z_000[4].w);
            float _665 = _662 * (User_000.UserConstant_Z_000[9].y);
            float _666 = _664 + _665;
            float _667 = _663 * _663;
            float _668 = _667 * _663;
            float _669 = _668 - _663;
            float _670 = _669 * (User_000.UserConstant_Z_000[10].y);
            float _671 = _662 * _662;
            float _672 = _671 * _662;
            float _673 = _672 - _662;
            float _674 = _673 * (User_000.UserConstant_Z_000[10].z);
            float _675 = _670 + _674;
            float _676 = _660 * _660;
            float _677 = _676 * 0.1666666716337204f;
            float _678 = _677 * _675;
            float _679 = _666 + _678;
            _721 = _679;
          } else {
            bool _681 = !(_493 <= (User_000.UserConstant_Z_000[9].z));
            if (!_681) {
              float _683 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _684 = max(9.999999974752427e-07f, _683);
              float _685 = _493 - (User_000.UserConstant_Z_000[9].x);
              float _686 = _685 / _684;
              float _687 = 1.0f - _686;
              float _688 = _687 * (User_000.UserConstant_Z_000[9].y);
              float _689 = _686 * (User_000.UserConstant_Z_000[9].w);
              float _690 = _688 + _689;
              float _691 = _687 * _687;
              float _692 = _691 * _687;
              float _693 = _692 - _687;
              float _694 = _693 * (User_000.UserConstant_Z_000[10].z);
              float _695 = _686 * _686;
              float _696 = _695 * _686;
              float _697 = _696 - _686;
              float _698 = _697 * (User_000.UserConstant_Z_000[10].w);
              float _699 = _694 + _698;
              float _700 = _684 * _684;
              float _701 = _700 * 0.1666666716337204f;
              float _702 = _701 * _699;
              float _703 = _690 + _702;
              _721 = _703;
            } else {
              float _705 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _706 = _493 - (User_000.UserConstant_Z_000[9].z);
              float _707 = max(9.999999974752427e-07f, _705);
              float _708 = _706 / _707;
              float _709 = 1.0f - _708;
              float _710 = _709 * (User_000.UserConstant_Z_000[9].w);
              float _711 = _710 + _708;
              float _712 = _709 * _709;
              float _713 = _712 * _709;
              float _714 = _713 - _709;
              float _715 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _716 = _705 * _705;
              float _717 = _716 * _715;
              float _718 = _717 * _714;
              float _719 = _711 + _718;
              _721 = _719;
            }
          }
        }
      }
      float _722 = saturate(_721);
      bool _723 = !(_494 <= (User_000.UserConstant_Z_000[4].x));
      if (!_723) {
        float _725 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _726 = _494 / _725;
        float _727 = _726 * (User_000.UserConstant_Z_000[4].y);
        float _728 = _726 * _726;
        float _729 = _728 * _726;
        float _730 = _729 - _726;
        float _731 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _732 = _725 * _725;
        float _733 = _732 * _731;
        float _734 = _733 * _730;
        float _735 = _734 + _727;
        _825 = _735;
      } else {
        bool _737 = !(_494 <= (User_000.UserConstant_Z_000[4].z));
        if (!_737) {
          float _739 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _740 = max(9.999999974752427e-07f, _739);
          float _741 = _494 - (User_000.UserConstant_Z_000[4].x);
          float _742 = _741 / _740;
          float _743 = 1.0f - _742;
          float _744 = _743 * (User_000.UserConstant_Z_000[4].y);
          float _745 = _742 * (User_000.UserConstant_Z_000[4].w);
          float _746 = _744 + _745;
          float _747 = _743 * _743;
          float _748 = _747 * _743;
          float _749 = _748 - _743;
          float _750 = _749 * (User_000.UserConstant_Z_000[10].x);
          float _751 = _742 * _742;
          float _752 = _751 * _742;
          float _753 = _752 - _742;
          float _754 = _753 * (User_000.UserConstant_Z_000[10].y);
          float _755 = _750 + _754;
          float _756 = _740 * _740;
          float _757 = _756 * 0.1666666716337204f;
          float _758 = _757 * _755;
          float _759 = _746 + _758;
          _825 = _759;
        } else {
          bool _761 = !(_494 <= (User_000.UserConstant_Z_000[9].x));
          if (!_761) {
            float _763 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _764 = max(9.999999974752427e-07f, _763);
            float _765 = _494 - (User_000.UserConstant_Z_000[4].z);
            float _766 = _765 / _764;
            float _767 = 1.0f - _766;
            float _768 = _767 * (User_000.UserConstant_Z_000[4].w);
            float _769 = _766 * (User_000.UserConstant_Z_000[9].y);
            float _770 = _768 + _769;
            float _771 = _767 * _767;
            float _772 = _771 * _767;
            float _773 = _772 - _767;
            float _774 = _773 * (User_000.UserConstant_Z_000[10].y);
            float _775 = _766 * _766;
            float _776 = _775 * _766;
            float _777 = _776 - _766;
            float _778 = _777 * (User_000.UserConstant_Z_000[10].z);
            float _779 = _774 + _778;
            float _780 = _764 * _764;
            float _781 = _780 * 0.1666666716337204f;
            float _782 = _781 * _779;
            float _783 = _770 + _782;
            _825 = _783;
          } else {
            bool _785 = !(_494 <= (User_000.UserConstant_Z_000[9].z));
            if (!_785) {
              float _787 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _788 = max(9.999999974752427e-07f, _787);
              float _789 = _494 - (User_000.UserConstant_Z_000[9].x);
              float _790 = _789 / _788;
              float _791 = 1.0f - _790;
              float _792 = _791 * (User_000.UserConstant_Z_000[9].y);
              float _793 = _790 * (User_000.UserConstant_Z_000[9].w);
              float _794 = _792 + _793;
              float _795 = _791 * _791;
              float _796 = _795 * _791;
              float _797 = _796 - _791;
              float _798 = _797 * (User_000.UserConstant_Z_000[10].z);
              float _799 = _790 * _790;
              float _800 = _799 * _790;
              float _801 = _800 - _790;
              float _802 = _801 * (User_000.UserConstant_Z_000[10].w);
              float _803 = _798 + _802;
              float _804 = _788 * _788;
              float _805 = _804 * 0.1666666716337204f;
              float _806 = _805 * _803;
              float _807 = _794 + _806;
              _825 = _807;
            } else {
              float _809 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _810 = _494 - (User_000.UserConstant_Z_000[9].z);
              float _811 = max(9.999999974752427e-07f, _809);
              float _812 = _810 / _811;
              float _813 = 1.0f - _812;
              float _814 = _813 * (User_000.UserConstant_Z_000[9].w);
              float _815 = _814 + _812;
              float _816 = _813 * _813;
              float _817 = _816 * _813;
              float _818 = _817 - _813;
              float _819 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _820 = _809 * _809;
              float _821 = _820 * _819;
              float _822 = _821 * _818;
              float _823 = _815 + _822;
              _825 = _823;
            }
          }
        }
      }
      float _826 = saturate(_825);
      _828 = _618;
      _829 = _722;
      _830 = _826;
    } else {
      _828 = _492;
      _829 = _493;
      _830 = _494;
    }
    int _831 = _496 & 2;
    bool _832 = (_831 == 0);
    if (!_832) {
      float _834 = sqrt(_828);
      float _835 = sqrt(_829);
      float _836 = sqrt(_830);
      float _837 = dot(float3(_834, _835, _836), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _838 = 1.0f - _837;
      float _839 = saturate(_838);
      _841 = _839;
    } else {
      _841 = 1.0f;
    }
    int _842 = _496 & 8;
    bool _843 = (_842 == 0);
    if (_843) {
      int _845 = _496 & 4;
      bool _846 = (_845 == 0);
      if (!_846) {
        int _848 = _496 & 16;
        bool _849 = (_848 == 0);
        if (!_849) {
          float _853 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _854 = _853 + 0.5f;
          bool _855 = (_854 < 0.5f);
          float _856 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _857 = select(_855, (User_000.UserConstant_Z_000[5].x), _856);
          bool _858 = (_829 < _830);
          float _859 = select(_858, _830, _829);
          float _860 = select(_858, _829, _830);
          bool _861 = (_828 < _859);
          float _862 = select(_861, _859, _828);
          float _863 = select(_861, _828, _859);
          float _864 = min(_863, _860);
          float _865 = _862 - _864;
          float _866 = _862 + 1.000000013351432e-10f;
          float _867 = _865 / _866;
          float _869 = _867 - (User_000.UserConstant_Z_000[5].y);
          float _870 = saturate(_869);
          float _871 = max(_870, 9.999999974752427e-07f);
          float _872 = log2(_871);
          float _873 = _872 * _857;
          float _874 = exp2(_873);
          float _875 = 2.0f - _874;
          float _877 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _878 = saturate(_877);
          float _879 = max(_878, _875);
          float _880 = dot(float3(_828, _829, _830), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _881 = _828 - _880;
          float _882 = _829 - _880;
          float _883 = _830 - _880;
          float _884 = _881 * _879;
          float _885 = _882 * _879;
          float _886 = _883 * _879;
          float _887 = _880 - _828;
          float _888 = _887 + _884;
          float _889 = _880 - _829;
          float _890 = _889 + _885;
          float _891 = _880 - _830;
          float _892 = _891 + _886;
          float _893 = _888 * _841;
          float _894 = _890 * _841;
          float _895 = _892 * _841;
          float _896 = _893 + _828;
          float _897 = _894 + _829;
          float _898 = _895 + _830;
          _1015 = _896;
          _1016 = _897;
          _1017 = _898;
        } else {
          bool _900 = (_841 == 0.0f);
          if (!_900) {
            float _904 = abs(User_000.UserConstant_Z_000[5].x);
            float _905 = saturate(_904);
            uint4 _907 = 0u; t15.GetDimensions(0u, _907.x, _907.y, _907.w);
            float _910 = float((uint)_907.y);
            int _911 = _496 & 32;
            bool _912 = (_911 == 0);
            float _913 = _910 + -1.0f;
            if (!_912) {
              float _915 = 1.0f / _913;
              uint _916 = uint(SV_Position.x);
              uint _917 = uint(SV_Position.y);
              int _918 = _916 & 63;
              int _919 = _917 & 63;
              float4 _921 = t2.Load(int4(_918, _919, 0, 0));
              float _924 = _921.x + -0.5f;
              float _925 = _828 * 13.999999046325684f;
              float _926 = _829 * 13.999999046325684f;
              float _927 = _830 * 13.999999046325684f;
              float _928 = saturate(_925);
              float _929 = saturate(_926);
              float _930 = saturate(_927);
              float _931 = _828 + -0.9285714030265808f;
              float _932 = _829 + -0.9285714030265808f;
              float _933 = _830 + -0.9285714030265808f;
              float _934 = _931 * 13.999999046325684f;
              float _935 = _932 * 13.999999046325684f;
              float _936 = _933 * 13.999999046325684f;
              float _937 = saturate(_934);
              float _938 = saturate(_935);
              float _939 = saturate(_936);
              float _940 = 1.0f - _937;
              float _941 = 1.0f - _938;
              float _942 = 1.0f - _939;
              float _943 = min(_928, _940);
              float _944 = min(_929, _941);
              float _945 = min(_930, _942);
              float _946 = _921.y + -0.5f;
              float _947 = _943 * _946;
              float _948 = _944 * _946;
              float _949 = _945 * _946;
              float _950 = _947 + _924;
              float _951 = _948 + _924;
              float _952 = _949 + _924;
              float _953 = _950 * _915;
              float _954 = _951 * _915;
              float _955 = _952 * _915;
              float _956 = _953 + _828;
              float _957 = _954 + _829;
              float _958 = _955 + _830;
              float _959 = saturate(_956);
              float _960 = saturate(_957);
              float _961 = saturate(_958);
              float _962 = saturate(_959);
              float _963 = saturate(_960);
              float _964 = saturate(_961);
              _966 = _962;
              _967 = _963;
              _968 = _964;
            } else {
              _966 = _828;
              _967 = _829;
              _968 = _830;
            }
            float _969 = float((uint)_907.x);
            float _970 = _913 / _969;
            float _971 = _970 * _966;
            float _972 = 0.5f / _969;
            float _973 = _971 + _972;
            float _974 = _913 / _910;
            float _975 = _974 * _967;
            float _976 = 0.5f / _910;
            float _977 = _975 + _976;
            float _978 = _968 * _913;
            float _979 = floor(_978);
            float _980 = frac(_978);
            float _981 = _979 / _910;
            float _982 = _981 + _973;
            float _983 = _979 + 1.0f;
            float _984 = _983 / _910;
            float _985 = _984 + _973;
            float4 _987 = t15.Sample(s1, float2(_982, _977));
            float4 _991 = t15.Sample(s1, float2(_985, _977));
            float _995 = _991.x - _987.x;
            float _996 = _991.y - _987.y;
            float _997 = _991.z - _987.z;
            float _998 = _995 * _980;
            float _999 = _996 * _980;
            float _1000 = _997 * _980;
            float _1001 = _905 * _841;
            float _1002 = _987.x - _828;
            float _1003 = _1002 + _998;
            float _1004 = _987.y - _829;
            float _1005 = _1004 + _999;
            float _1006 = _987.z - _830;
            float _1007 = _1006 + _1000;
            float _1008 = _1003 * _1001;
            float _1009 = _1005 * _1001;
            float _1010 = _1007 * _1001;
            float _1011 = _1008 + _828;
            float _1012 = _1009 + _829;
            float _1013 = _1010 + _830;
            _1015 = _1011;
            _1016 = _1012;
            _1017 = _1013;
          } else {
            _1015 = _828;
            _1016 = _829;
            _1017 = _830;
          }
        }
      } else {
        _1015 = _828;
        _1016 = _829;
        _1017 = _830;
      }
    } else {
      _1015 = _841;
      _1016 = _841;
      _1017 = _841;
    }
    float _1018 = _1015 * 13.450128555297852f;
    float _1019 = _1016 * 13.450128555297852f;
    float _1020 = _1017 * 13.450128555297852f;
    float _1021 = exp2(_1018);
    float _1022 = exp2(_1019);
    float _1023 = exp2(_1020);
    float _1024 = _1021 + -1.0f;
    float _1025 = _1022 + -1.0f;
    float _1026 = _1023 + -1.0f;
    float _1027 = _1024 * _474;
    float _1028 = _1025 * _474;
    float _1029 = _1026 * _474;
    _1031 = _1027;
    _1032 = _1028;
    _1033 = _1029;
  } else {
    _1031 = _475;
    _1032 = _476;
    _1033 = _477;
  }
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1031, (User_000.UserConstant_Z_000[8].y) * _1032, (User_000.UserConstant_Z_000[8].z) * _1033),
      SV_Position.xy);
  float _1040 = apt_perceptual_film_grain.x;
  float _1041 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1042 = log2(_1040);
  float _1043 = _1041 * _1042;
  float _1044 = exp2(_1043);
  float _1045 = _1044 + -1.0f;
  float _1046 = _1040 + -1.0f;
  float _1047 = _1045 / _1046;
  bool _1048 = !(_1040 == 1.0f);
  float _1049 = _1047 + -1.0f;
  float _1050 = _1049 / _1047;
  float _1051 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1052 = _1051 / _1041;
  float _1053 = select(_1048, _1050, _1052);
  float _1054 = apt_perceptual_film_grain.y;
  float _1055 = log2(_1054);
  float _1056 = _1055 * _1041;
  float _1057 = exp2(_1056);
  float _1058 = _1057 + -1.0f;
  float _1059 = _1054 + -1.0f;
  float _1060 = _1058 / _1059;
  bool _1061 = !(_1054 == 1.0f);
  float _1062 = _1060 + -1.0f;
  float _1063 = _1062 / _1060;
  float _1064 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1065 = _1064 / _1041;
  float _1066 = select(_1061, _1063, _1065);
  float _1067 = apt_perceptual_film_grain.z;
  float _1068 = log2(_1067);
  float _1069 = _1068 * _1041;
  float _1070 = exp2(_1069);
  float _1071 = _1070 + -1.0f;
  float _1072 = _1067 + -1.0f;
  float _1073 = _1071 / _1072;
  bool _1074 = !(_1067 == 1.0f);
  float _1075 = _1073 + -1.0f;
  float _1076 = _1075 / _1073;
  float _1077 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1078 = _1077 / _1041;
  float _1079 = select(_1074, _1076, _1078);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1040, _1054, _1067),
      float3(_1053, _1066, _1079),
      true);
  float _1080 = apt_post_process_output.x;
  float _1081 = apt_post_process_output.y;
  float _1082 = apt_post_process_output.z;
  float _1083 = log2(_1080);
  float _1084 = log2(_1081);
  float _1085 = log2(_1082);
  float _1086 = _1083 * 0.4166666567325592f;
  float _1087 = _1084 * 0.4166666567325592f;
  float _1088 = _1085 * 0.4166666567325592f;
  float _1089 = exp2(_1086);
  float _1090 = exp2(_1087);
  float _1091 = exp2(_1088);
  float _1092 = _1089 * 1.0549999475479126f;
  float _1093 = _1090 * 1.0549999475479126f;
  float _1094 = _1091 * 1.0549999475479126f;
  float _1095 = _1092 + -0.054999999701976776f;
  float _1096 = _1093 + -0.054999999701976776f;
  float _1097 = _1094 + -0.054999999701976776f;
  float _1098 = _1080 * 12.920000076293945f;
  float _1099 = _1081 * 12.920000076293945f;
  float _1100 = _1082 * 12.920000076293945f;
  bool _1101 = (_1080 <= 0.0031308000907301903f);
  bool _1102 = (_1081 <= 0.0031308000907301903f);
  bool _1103 = (_1082 <= 0.0031308000907301903f);
  float _1104 = select(_1101, _1098, _1095);
  float _1105 = select(_1102, _1099, _1096);
  float _1106 = select(_1103, _1100, _1097);
  int _1109 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1110 = uint(SV_Position.x);
  uint _1111 = uint(SV_Position.y);
  int _1112 = _1110 & 63;
  int _1113 = _1111 & 63;
  float4 _1115 = t1.Load(int4(_1112, _1113, _1109, 0));
  float _1117 = _1115.x + -0.5f;
  float _1118 = _1117 * 0.003921568859368563f;
  float _1119 = _1118 + _1104;
  float _1120 = _1118 + _1105;
  float _1121 = _1118 + _1106;
  float _1122 = saturate(_1119);
  float _1123 = saturate(_1120);
  float _1124 = saturate(_1121);
  SV_Target.x = _1122;
  SV_Target.y = _1123;
  SV_Target.z = _1124;
  SV_Target.w = _370;
  return SV_Target;
}
