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

Texture2D<float4> t9 : register(t9);

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

SamplerState s2 : register(s2);

SamplerState s0 : register(s0);

SamplerState s3 : register(s3);

SamplerState s8 : register(s8);

SamplerState s9 : register(s9);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _33 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _39 = t16.Sample(s1, float2(TEXCOORD.z, TEXCOORD.w));
  float _41 = _39.y * 0.10000000149011612f;
  float _42 = _41 + _33.y;
  float _43 = _39.y * 0.5f;
  float _44 = _43 + _33.z;
  float _45 = exp2(_44);
  float _46 = _45 + -1.0f;
  float _49 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _46;
  float _50 = _49 + 1.0f;
  float _51 = log2(_50);
  float _52 = _33.x + TEXCOORD.z;
  float _53 = _42 + TEXCOORD.w;
  float _54 = _33.x + TEXCOORD.x;
  float _55 = _42 + TEXCOORD.y;
  float _56 = _51 + 1.0f;
  float _57 = log2(_56);
  float4 _60 = t0.SampleLevel(s1, float2(_52, _53), _57);
  bool _65 = (_57 > 0.0f);
  float _370;
  float _371;
  float _372;
  float _373;
  float _420;
  float _421;
  float _422;
  float _427;
  float _428;
  float _429;
  float _458;
  float _459;
  float _460;
  float _465;
  float _466;
  float _467;
  float _702;
  float _806;
  float _910;
  float _913;
  float _914;
  float _915;
  float _926;
  float _1051;
  float _1052;
  float _1053;
  float _1100;
  float _1101;
  float _1102;
  float _1116;
  float _1117;
  float _1118;
  float _1174;
  [branch]
  if (_65) {
    float _67 = floor(_57);
    int _68 = int(_67);
    uint4 _69 = 0u; t0.GetDimensions(0u, _69.x, _69.y, _69.w);
    int _72 = _68 & 31;
    int _73 = (uint)(_69.x) >> _72;
    float _74 = float((uint)_73);
    int _75 = (uint)(_69.y) >> _72;
    float _76 = float((uint)_75);
    float _77 = 1.0f / _74;
    float _78 = 1.0f / _76;
    float _79 = _74 * _52;
    float _80 = _76 * _53;
    float _81 = _79 + -0.5f;
    float _82 = _80 + -0.5f;
    float _83 = frac(_81);
    float _84 = frac(_82);
    float _85 = floor(_81);
    float _86 = floor(_82);
    float _87 = 1.0f - _83;
    float _88 = 2.0f - _83;
    float _89 = 3.0f - _83;
    float _90 = _87 * _87;
    float _91 = _88 * _88;
    float _92 = _89 * _89;
    float _93 = _90 * _87;
    float _94 = _91 * _88;
    float _95 = _92 * _89;
    float _96 = _93 * 4.0f;
    float _97 = _94 - _96;
    float _98 = _94 * 4.0f;
    float _99 = _93 * 6.0f;
    float _100 = 6.0f - _93;
    float _101 = _100 - _97;
    float _102 = _98 - _95;
    float _103 = _102 - _99;
    float _104 = _103 + _101;
    float _105 = _97 * 0.1666666716337204f;
    float _106 = _104 * 0.1666666716337204f;
    float _107 = 1.0f - _84;
    float _108 = 2.0f - _84;
    float _109 = 3.0f - _84;
    float _110 = _107 * _107;
    float _111 = _108 * _108;
    float _112 = _109 * _109;
    float _113 = _110 * _107;
    float _114 = _111 * _108;
    float _115 = _112 * _109;
    float _116 = _113 * 4.0f;
    float _117 = _114 - _116;
    float _118 = _114 * 4.0f;
    float _119 = _113 * 6.0f;
    float _120 = 6.0f - _113;
    float _121 = _120 - _117;
    float _122 = _118 - _115;
    float _123 = _122 - _119;
    float _124 = _123 + _121;
    float _125 = _117 * 0.1666666716337204f;
    float _126 = _124 * 0.1666666716337204f;
    float _127 = _85 + -0.5f;
    float _128 = _85 + 1.5f;
    float _129 = _86 + -0.5f;
    float _130 = _86 + 1.5f;
    float _131 = _97 + _93;
    float _132 = _131 * 0.1666666716337204f;
    float _133 = _101 * 0.1666666716337204f;
    float _134 = _117 + _113;
    float _135 = _134 * 0.1666666716337204f;
    float _136 = _121 * 0.1666666716337204f;
    float _137 = _105 / _132;
    float _138 = _106 / _133;
    float _139 = _125 / _135;
    float _140 = _126 / _136;
    float _141 = _127 + _137;
    float _142 = _128 + _138;
    float _143 = _129 + _139;
    float _144 = _130 + _140;
    float _145 = _141 * _77;
    float _146 = _142 * _77;
    float _147 = _143 * _78;
    float _148 = _144 * _78;
    float _149 = float((int)(_68));
    float4 _151 = t0.SampleLevel(s0, float2(_145, _147), _149);
    float4 _156 = t0.SampleLevel(s0, float2(_146, _147), _149);
    float4 _161 = t0.SampleLevel(s0, float2(_145, _148), _149);
    float4 _166 = t0.SampleLevel(s0, float2(_146, _148), _149);
    float _171 = _151.x - _156.x;
    float _172 = _151.y - _156.y;
    float _173 = _151.z - _156.z;
    float _174 = _151.w - _156.w;
    float _175 = _171 * _132;
    float _176 = _172 * _132;
    float _177 = _173 * _132;
    float _178 = _174 * _132;
    float _179 = _175 + _156.x;
    float _180 = _176 + _156.y;
    float _181 = _177 + _156.z;
    float _182 = _178 + _156.w;
    float _183 = _161.x - _166.x;
    float _184 = _161.y - _166.y;
    float _185 = _161.z - _166.z;
    float _186 = _161.w - _166.w;
    float _187 = _183 * _132;
    float _188 = _184 * _132;
    float _189 = _185 * _132;
    float _190 = _186 * _132;
    float _191 = _187 + _166.x;
    float _192 = _188 + _166.y;
    float _193 = _189 + _166.z;
    float _194 = _190 + _166.w;
    float _195 = _179 - _191;
    float _196 = _180 - _192;
    float _197 = _181 - _193;
    float _198 = _182 - _194;
    float _199 = _195 * _135;
    float _200 = _196 * _135;
    float _201 = _197 * _135;
    float _202 = _198 * _135;
    float _203 = _199 + _191;
    float _204 = _200 + _192;
    float _205 = _201 + _193;
    float _206 = _202 + _194;
    float _207 = ceil(_57);
    int _208 = int(_207);
    int _209 = _208 & 31;
    int _210 = (uint)(_69.x) >> _209;
    float _211 = float((uint)_210);
    int _212 = (uint)(_69.y) >> _209;
    float _213 = float((uint)_212);
    float _214 = 1.0f / _211;
    float _215 = 1.0f / _213;
    float _216 = _211 * _52;
    float _217 = _213 * _53;
    float _218 = _216 + -0.5f;
    float _219 = _217 + -0.5f;
    float _220 = frac(_218);
    float _221 = frac(_219);
    float _222 = floor(_218);
    float _223 = floor(_219);
    float _224 = 1.0f - _220;
    float _225 = 2.0f - _220;
    float _226 = 3.0f - _220;
    float _227 = _224 * _224;
    float _228 = _225 * _225;
    float _229 = _226 * _226;
    float _230 = _227 * _224;
    float _231 = _228 * _225;
    float _232 = _229 * _226;
    float _233 = _230 * 4.0f;
    float _234 = _231 - _233;
    float _235 = _231 * 4.0f;
    float _236 = _230 * 6.0f;
    float _237 = 6.0f - _230;
    float _238 = _237 - _234;
    float _239 = _235 - _232;
    float _240 = _239 - _236;
    float _241 = _240 + _238;
    float _242 = _234 * 0.1666666716337204f;
    float _243 = _241 * 0.1666666716337204f;
    float _244 = 1.0f - _221;
    float _245 = 2.0f - _221;
    float _246 = 3.0f - _221;
    float _247 = _244 * _244;
    float _248 = _245 * _245;
    float _249 = _246 * _246;
    float _250 = _247 * _244;
    float _251 = _248 * _245;
    float _252 = _249 * _246;
    float _253 = _250 * 4.0f;
    float _254 = _251 - _253;
    float _255 = _251 * 4.0f;
    float _256 = _250 * 6.0f;
    float _257 = 6.0f - _250;
    float _258 = _257 - _254;
    float _259 = _255 - _252;
    float _260 = _259 - _256;
    float _261 = _260 + _258;
    float _262 = _254 * 0.1666666716337204f;
    float _263 = _261 * 0.1666666716337204f;
    float _264 = _222 + -0.5f;
    float _265 = _222 + 1.5f;
    float _266 = _223 + -0.5f;
    float _267 = _223 + 1.5f;
    float _268 = _234 + _230;
    float _269 = _268 * 0.1666666716337204f;
    float _270 = _238 * 0.1666666716337204f;
    float _271 = _254 + _250;
    float _272 = _271 * 0.1666666716337204f;
    float _273 = _258 * 0.1666666716337204f;
    float _274 = _242 / _269;
    float _275 = _243 / _270;
    float _276 = _262 / _272;
    float _277 = _263 / _273;
    float _278 = _264 + _274;
    float _279 = _265 + _275;
    float _280 = _266 + _276;
    float _281 = _267 + _277;
    float _282 = _278 * _214;
    float _283 = _279 * _214;
    float _284 = _280 * _215;
    float _285 = _281 * _215;
    float _286 = float((int)(_208));
    float4 _287 = t0.SampleLevel(s0, float2(_282, _284), _286);
    float4 _292 = t0.SampleLevel(s0, float2(_283, _284), _286);
    float4 _297 = t0.SampleLevel(s0, float2(_282, _285), _286);
    float4 _302 = t0.SampleLevel(s0, float2(_283, _285), _286);
    float _307 = _287.x - _292.x;
    float _308 = _287.y - _292.y;
    float _309 = _287.z - _292.z;
    float _310 = _287.w - _292.w;
    float _311 = _307 * _269;
    float _312 = _308 * _269;
    float _313 = _309 * _269;
    float _314 = _310 * _269;
    float _315 = _311 + _292.x;
    float _316 = _312 + _292.y;
    float _317 = _313 + _292.z;
    float _318 = _314 + _292.w;
    float _319 = _297.x - _302.x;
    float _320 = _297.y - _302.y;
    float _321 = _297.z - _302.z;
    float _322 = _297.w - _302.w;
    float _323 = _319 * _269;
    float _324 = _320 * _269;
    float _325 = _321 * _269;
    float _326 = _322 * _269;
    float _327 = _323 + _302.x;
    float _328 = _324 + _302.y;
    float _329 = _325 + _302.z;
    float _330 = _326 + _302.w;
    float _331 = _315 - _327;
    float _332 = _316 - _328;
    float _333 = _317 - _329;
    float _334 = _318 - _330;
    float _335 = _331 * _272;
    float _336 = _332 * _272;
    float _337 = _333 * _272;
    float _338 = _334 * _272;
    float _339 = frac(_57);
    float _340 = _327 - _203;
    float _341 = _340 + _335;
    float _342 = _328 - _204;
    float _343 = _342 + _336;
    float _344 = _329 - _205;
    float _345 = _344 + _337;
    float _346 = _330 - _206;
    float _347 = _346 + _338;
    float _348 = _341 * _339;
    float _349 = _343 * _339;
    float _350 = _345 * _339;
    float _351 = _347 * _339;
    float _352 = saturate(_57);
    float _353 = _203 - _60.x;
    float _354 = _353 + _348;
    float _355 = _204 - _60.y;
    float _356 = _355 + _349;
    float _357 = _205 - _60.z;
    float _358 = _357 + _350;
    float _359 = _206 - _60.w;
    float _360 = _359 + _351;
    float _361 = _354 * _352;
    float _362 = _356 * _352;
    float _363 = _358 * _352;
    float _364 = _360 * _352;
    float _365 = _361 + _60.x;
    float _366 = _362 + _60.y;
    float _367 = _363 + _60.z;
    float _368 = _364 + _60.w;
    _370 = _365;
    _371 = _366;
    _372 = _367;
    _373 = _368;
  } else {
    _370 = _60.x;
    _371 = _60.y;
    _372 = _60.z;
    _373 = _60.w;
  }
  float _374 = max(_370, 0.0f);
  float _375 = max(_371, 0.0f);
  float _376 = max(_372, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_374, _375, _376),
      float3(_374, _375, _376),
      float2(_52, _53),
      t0,
      s1,
      _57);
  _374 = renodx_chromatic_aberration_input.x;
  _375 = renodx_chromatic_aberration_input.y;
  _376 = renodx_chromatic_aberration_input.z;
  float4 _378 = t12.SampleLevel(s1, float2(_52, _53), 0.0f);
  float4 _384 = t8.Sample(s8, float2(_54, _55));
  int _390 = asint((User_000.UserConstant_Z_000[7].z));
  bool _391 = ((int)_390 > (int)0);
  if (!_391) {
    bool _395 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _399 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _384.x;
    float _400 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _384.y;
    float _401 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _384.z;
    float _402 = _399 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _403 = _400 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _404 = _401 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_395) {
      float _406 = _402 * _378.x;
      float _407 = _403 * _378.y;
      float _408 = _404 * _378.z;
      _420 = _406;
      _421 = _407;
      _422 = _408;
    } else {
      float _410 = saturate(_402);
      float _411 = saturate(_403);
      float _412 = saturate(_404);
      float _413 = _378.x - _374;
      float _414 = _378.y - _375;
      float _415 = _378.z - _376;
      float _416 = _410 * _413;
      float _417 = _411 * _414;
      float _418 = _412 * _415;
      _420 = _416;
      _421 = _417;
      _422 = _418;
    }
    float _423 = _420 + _374;
    float _424 = _421 + _375;
    float _425 = _422 + _376;
    _427 = _423;
    _428 = _424;
    _429 = _425;
  } else {
    _427 = _374;
    _428 = _375;
    _429 = _376;
  }
  if (_391) {
    bool _433 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _437 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _384.x;
    float _438 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _384.y;
    float _439 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _384.z;
    float _440 = _437 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _441 = _438 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _442 = _439 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_433) {
      float _444 = _440 * _378.x;
      float _445 = _441 * _378.y;
      float _446 = _442 * _378.z;
      _458 = _444;
      _459 = _445;
      _460 = _446;
    } else {
      float _448 = saturate(_440);
      float _449 = saturate(_441);
      float _450 = saturate(_442);
      float _451 = _378.x - _427;
      float _452 = _378.y - _428;
      float _453 = _378.z - _429;
      float _454 = _448 * _451;
      float _455 = _449 * _452;
      float _456 = _450 * _453;
      _458 = _454;
      _459 = _455;
      _460 = _456;
    }
    float _461 = _458 + _427;
    float _462 = _459 + _428;
    float _463 = _460 + _429;
    _465 = _461;
    _466 = _462;
    _467 = _463;
  } else {
    _465 = _427;
    _466 = _428;
    _467 = _429;
  }
  float4 _471 = t17.Load(int3(0, 0, 0));
  float _477 = _471.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _478 = _477 * _465;
  float _479 = _478 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _480 = _477 * _466;
  float _481 = _480 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _482 = _477 * _467;
  float _483 = _482 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _488 = _52 * 2.0f;
  float _489 = _53 * 2.0f;
  float _490 = _488 + -1.0f;
  float _491 = _489 + -1.0f;
  float _494 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _491;
  float _495 = _490 * _490;
  float _496 = _494 * _494;
  float _497 = _496 + _495;
  float _498 = sqrt(_497);
  float _500 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _498;
  float _502 = _500 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _503 = saturate(_502);
  float _505 = log2(_503);
  float _506 = _505 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _507 = exp2(_506);
  float _508 = _479 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _509 = _481 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _510 = _483 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _511 = _508 - _479;
  float _512 = _509 - _481;
  float _513 = _510 - _483;
  float _514 = _507 * _511;
  float _515 = _507 * _512;
  float _516 = _507 * _513;
  float _517 = _514 + _479;
  float _518 = _515 + _481;
  float _519 = _516 + _483;
  float _522 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _523 = _522 * _517;
  float _524 = _522 * _518;
  float _525 = _522 * _519;
  float _526 = _523 + 1.0f;
  float _527 = _524 + 1.0f;
  float _528 = _525 + 1.0f;
  float _529 = log2(_526);
  float _530 = log2(_527);
  float _531 = log2(_528);
  float _534 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _535 = _534 * _529;
  float _536 = _534 * _530;
  float _537 = _534 * _531;
  float _539 = _535 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _540 = _536 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _541 = _537 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _544 = t3.Sample(s3, float3(_539, _540, _541));
  float _550 = _544.x * 13.450128555297852f;
  float _551 = _544.y * 13.450128555297852f;
  float _552 = _544.z * 13.450128555297852f;
  float _553 = exp2(_550);
  float _554 = exp2(_551);
  float _555 = exp2(_552);
  float _556 = _553 + -1.0f;
  float _557 = _554 + -1.0f;
  float _558 = _555 + -1.0f;
  float _559 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _560 = _559 * _556;
  float _561 = _559 * _557;
  float _562 = _559 * _558;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_523 * _559, _524 * _559, _525 * _559),
      float3(_560, _561, _562),
      1.f.xxx);
  _560 = apt_scaled_lut_output.x;
  _561 = apt_scaled_lut_output.y;
  _562 = apt_scaled_lut_output.z;
  bool _565 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !APTIsPsychoV();
  if (_565) {
    float _567 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _568 = _560 * _567;
    float _569 = _561 * _567;
    float _570 = _562 * _567;
    float _571 = _568 + 1.0f;
    float _572 = _569 + 1.0f;
    float _573 = _570 + 1.0f;
    float _574 = log2(_571);
    float _575 = log2(_572);
    float _576 = log2(_573);
    float _577 = _574 * 0.07434873282909393f;
    float _578 = _575 * 0.07434873282909393f;
    float _579 = _576 * 0.07434873282909393f;
    int _581 = asint((User_000.UserConstant_Z_000[3].y));
    int _582 = _581 & 1;
    bool _583 = (_582 == 0);
    if (!_583) {
      bool _600 = !(_577 <= (User_000.UserConstant_Z_000[4].x));
      if (!_600) {
        float _602 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _603 = _577 / _602;
        float _604 = _603 * (User_000.UserConstant_Z_000[4].y);
        float _605 = _603 * _603;
        float _606 = _605 * _603;
        float _607 = _606 - _603;
        float _608 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _609 = _602 * _602;
        float _610 = _609 * _608;
        float _611 = _610 * _607;
        float _612 = _611 + _604;
        _702 = _612;
      } else {
        bool _614 = !(_577 <= (User_000.UserConstant_Z_000[4].z));
        if (!_614) {
          float _616 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _617 = max(9.999999974752427e-07f, _616);
          float _618 = _577 - (User_000.UserConstant_Z_000[4].x);
          float _619 = _618 / _617;
          float _620 = 1.0f - _619;
          float _621 = _620 * (User_000.UserConstant_Z_000[4].y);
          float _622 = _619 * (User_000.UserConstant_Z_000[4].w);
          float _623 = _621 + _622;
          float _624 = _620 * _620;
          float _625 = _624 * _620;
          float _626 = _625 - _620;
          float _627 = _626 * (User_000.UserConstant_Z_000[10].x);
          float _628 = _619 * _619;
          float _629 = _628 * _619;
          float _630 = _629 - _619;
          float _631 = _630 * (User_000.UserConstant_Z_000[10].y);
          float _632 = _627 + _631;
          float _633 = _617 * _617;
          float _634 = _633 * 0.1666666716337204f;
          float _635 = _634 * _632;
          float _636 = _623 + _635;
          _702 = _636;
        } else {
          bool _638 = !(_577 <= (User_000.UserConstant_Z_000[9].x));
          if (!_638) {
            float _640 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _641 = max(9.999999974752427e-07f, _640);
            float _642 = _577 - (User_000.UserConstant_Z_000[4].z);
            float _643 = _642 / _641;
            float _644 = 1.0f - _643;
            float _645 = _644 * (User_000.UserConstant_Z_000[4].w);
            float _646 = _643 * (User_000.UserConstant_Z_000[9].y);
            float _647 = _645 + _646;
            float _648 = _644 * _644;
            float _649 = _648 * _644;
            float _650 = _649 - _644;
            float _651 = _650 * (User_000.UserConstant_Z_000[10].y);
            float _652 = _643 * _643;
            float _653 = _652 * _643;
            float _654 = _653 - _643;
            float _655 = _654 * (User_000.UserConstant_Z_000[10].z);
            float _656 = _651 + _655;
            float _657 = _641 * _641;
            float _658 = _657 * 0.1666666716337204f;
            float _659 = _658 * _656;
            float _660 = _647 + _659;
            _702 = _660;
          } else {
            bool _662 = !(_577 <= (User_000.UserConstant_Z_000[9].z));
            if (!_662) {
              float _664 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _665 = max(9.999999974752427e-07f, _664);
              float _666 = _577 - (User_000.UserConstant_Z_000[9].x);
              float _667 = _666 / _665;
              float _668 = 1.0f - _667;
              float _669 = _668 * (User_000.UserConstant_Z_000[9].y);
              float _670 = _667 * (User_000.UserConstant_Z_000[9].w);
              float _671 = _669 + _670;
              float _672 = _668 * _668;
              float _673 = _672 * _668;
              float _674 = _673 - _668;
              float _675 = _674 * (User_000.UserConstant_Z_000[10].z);
              float _676 = _667 * _667;
              float _677 = _676 * _667;
              float _678 = _677 - _667;
              float _679 = _678 * (User_000.UserConstant_Z_000[10].w);
              float _680 = _675 + _679;
              float _681 = _665 * _665;
              float _682 = _681 * 0.1666666716337204f;
              float _683 = _682 * _680;
              float _684 = _671 + _683;
              _702 = _684;
            } else {
              float _686 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _687 = _577 - (User_000.UserConstant_Z_000[9].z);
              float _688 = max(9.999999974752427e-07f, _686);
              float _689 = _687 / _688;
              float _690 = 1.0f - _689;
              float _691 = _690 * (User_000.UserConstant_Z_000[9].w);
              float _692 = _691 + _689;
              float _693 = _690 * _690;
              float _694 = _693 * _690;
              float _695 = _694 - _690;
              float _696 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _697 = _686 * _686;
              float _698 = _697 * _696;
              float _699 = _698 * _695;
              float _700 = _692 + _699;
              _702 = _700;
            }
          }
        }
      }
      float _703 = saturate(_702);
      bool _704 = !(_578 <= (User_000.UserConstant_Z_000[4].x));
      if (!_704) {
        float _706 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _707 = _578 / _706;
        float _708 = _707 * (User_000.UserConstant_Z_000[4].y);
        float _709 = _707 * _707;
        float _710 = _709 * _707;
        float _711 = _710 - _707;
        float _712 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _713 = _706 * _706;
        float _714 = _713 * _712;
        float _715 = _714 * _711;
        float _716 = _715 + _708;
        _806 = _716;
      } else {
        bool _718 = !(_578 <= (User_000.UserConstant_Z_000[4].z));
        if (!_718) {
          float _720 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _721 = max(9.999999974752427e-07f, _720);
          float _722 = _578 - (User_000.UserConstant_Z_000[4].x);
          float _723 = _722 / _721;
          float _724 = 1.0f - _723;
          float _725 = _724 * (User_000.UserConstant_Z_000[4].y);
          float _726 = _723 * (User_000.UserConstant_Z_000[4].w);
          float _727 = _725 + _726;
          float _728 = _724 * _724;
          float _729 = _728 * _724;
          float _730 = _729 - _724;
          float _731 = _730 * (User_000.UserConstant_Z_000[10].x);
          float _732 = _723 * _723;
          float _733 = _732 * _723;
          float _734 = _733 - _723;
          float _735 = _734 * (User_000.UserConstant_Z_000[10].y);
          float _736 = _731 + _735;
          float _737 = _721 * _721;
          float _738 = _737 * 0.1666666716337204f;
          float _739 = _738 * _736;
          float _740 = _727 + _739;
          _806 = _740;
        } else {
          bool _742 = !(_578 <= (User_000.UserConstant_Z_000[9].x));
          if (!_742) {
            float _744 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _745 = max(9.999999974752427e-07f, _744);
            float _746 = _578 - (User_000.UserConstant_Z_000[4].z);
            float _747 = _746 / _745;
            float _748 = 1.0f - _747;
            float _749 = _748 * (User_000.UserConstant_Z_000[4].w);
            float _750 = _747 * (User_000.UserConstant_Z_000[9].y);
            float _751 = _749 + _750;
            float _752 = _748 * _748;
            float _753 = _752 * _748;
            float _754 = _753 - _748;
            float _755 = _754 * (User_000.UserConstant_Z_000[10].y);
            float _756 = _747 * _747;
            float _757 = _756 * _747;
            float _758 = _757 - _747;
            float _759 = _758 * (User_000.UserConstant_Z_000[10].z);
            float _760 = _755 + _759;
            float _761 = _745 * _745;
            float _762 = _761 * 0.1666666716337204f;
            float _763 = _762 * _760;
            float _764 = _751 + _763;
            _806 = _764;
          } else {
            bool _766 = !(_578 <= (User_000.UserConstant_Z_000[9].z));
            if (!_766) {
              float _768 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _769 = max(9.999999974752427e-07f, _768);
              float _770 = _578 - (User_000.UserConstant_Z_000[9].x);
              float _771 = _770 / _769;
              float _772 = 1.0f - _771;
              float _773 = _772 * (User_000.UserConstant_Z_000[9].y);
              float _774 = _771 * (User_000.UserConstant_Z_000[9].w);
              float _775 = _773 + _774;
              float _776 = _772 * _772;
              float _777 = _776 * _772;
              float _778 = _777 - _772;
              float _779 = _778 * (User_000.UserConstant_Z_000[10].z);
              float _780 = _771 * _771;
              float _781 = _780 * _771;
              float _782 = _781 - _771;
              float _783 = _782 * (User_000.UserConstant_Z_000[10].w);
              float _784 = _779 + _783;
              float _785 = _769 * _769;
              float _786 = _785 * 0.1666666716337204f;
              float _787 = _786 * _784;
              float _788 = _775 + _787;
              _806 = _788;
            } else {
              float _790 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _791 = _578 - (User_000.UserConstant_Z_000[9].z);
              float _792 = max(9.999999974752427e-07f, _790);
              float _793 = _791 / _792;
              float _794 = 1.0f - _793;
              float _795 = _794 * (User_000.UserConstant_Z_000[9].w);
              float _796 = _795 + _793;
              float _797 = _794 * _794;
              float _798 = _797 * _794;
              float _799 = _798 - _794;
              float _800 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _801 = _790 * _790;
              float _802 = _801 * _800;
              float _803 = _802 * _799;
              float _804 = _796 + _803;
              _806 = _804;
            }
          }
        }
      }
      float _807 = saturate(_806);
      bool _808 = !(_579 <= (User_000.UserConstant_Z_000[4].x));
      if (!_808) {
        float _810 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _811 = _579 / _810;
        float _812 = _811 * (User_000.UserConstant_Z_000[4].y);
        float _813 = _811 * _811;
        float _814 = _813 * _811;
        float _815 = _814 - _811;
        float _816 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _817 = _810 * _810;
        float _818 = _817 * _816;
        float _819 = _818 * _815;
        float _820 = _819 + _812;
        _910 = _820;
      } else {
        bool _822 = !(_579 <= (User_000.UserConstant_Z_000[4].z));
        if (!_822) {
          float _824 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _825 = max(9.999999974752427e-07f, _824);
          float _826 = _579 - (User_000.UserConstant_Z_000[4].x);
          float _827 = _826 / _825;
          float _828 = 1.0f - _827;
          float _829 = _828 * (User_000.UserConstant_Z_000[4].y);
          float _830 = _827 * (User_000.UserConstant_Z_000[4].w);
          float _831 = _829 + _830;
          float _832 = _828 * _828;
          float _833 = _832 * _828;
          float _834 = _833 - _828;
          float _835 = _834 * (User_000.UserConstant_Z_000[10].x);
          float _836 = _827 * _827;
          float _837 = _836 * _827;
          float _838 = _837 - _827;
          float _839 = _838 * (User_000.UserConstant_Z_000[10].y);
          float _840 = _835 + _839;
          float _841 = _825 * _825;
          float _842 = _841 * 0.1666666716337204f;
          float _843 = _842 * _840;
          float _844 = _831 + _843;
          _910 = _844;
        } else {
          bool _846 = !(_579 <= (User_000.UserConstant_Z_000[9].x));
          if (!_846) {
            float _848 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _849 = max(9.999999974752427e-07f, _848);
            float _850 = _579 - (User_000.UserConstant_Z_000[4].z);
            float _851 = _850 / _849;
            float _852 = 1.0f - _851;
            float _853 = _852 * (User_000.UserConstant_Z_000[4].w);
            float _854 = _851 * (User_000.UserConstant_Z_000[9].y);
            float _855 = _853 + _854;
            float _856 = _852 * _852;
            float _857 = _856 * _852;
            float _858 = _857 - _852;
            float _859 = _858 * (User_000.UserConstant_Z_000[10].y);
            float _860 = _851 * _851;
            float _861 = _860 * _851;
            float _862 = _861 - _851;
            float _863 = _862 * (User_000.UserConstant_Z_000[10].z);
            float _864 = _859 + _863;
            float _865 = _849 * _849;
            float _866 = _865 * 0.1666666716337204f;
            float _867 = _866 * _864;
            float _868 = _855 + _867;
            _910 = _868;
          } else {
            bool _870 = !(_579 <= (User_000.UserConstant_Z_000[9].z));
            if (!_870) {
              float _872 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _873 = max(9.999999974752427e-07f, _872);
              float _874 = _579 - (User_000.UserConstant_Z_000[9].x);
              float _875 = _874 / _873;
              float _876 = 1.0f - _875;
              float _877 = _876 * (User_000.UserConstant_Z_000[9].y);
              float _878 = _875 * (User_000.UserConstant_Z_000[9].w);
              float _879 = _877 + _878;
              float _880 = _876 * _876;
              float _881 = _880 * _876;
              float _882 = _881 - _876;
              float _883 = _882 * (User_000.UserConstant_Z_000[10].z);
              float _884 = _875 * _875;
              float _885 = _884 * _875;
              float _886 = _885 - _875;
              float _887 = _886 * (User_000.UserConstant_Z_000[10].w);
              float _888 = _883 + _887;
              float _889 = _873 * _873;
              float _890 = _889 * 0.1666666716337204f;
              float _891 = _890 * _888;
              float _892 = _879 + _891;
              _910 = _892;
            } else {
              float _894 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _895 = _579 - (User_000.UserConstant_Z_000[9].z);
              float _896 = max(9.999999974752427e-07f, _894);
              float _897 = _895 / _896;
              float _898 = 1.0f - _897;
              float _899 = _898 * (User_000.UserConstant_Z_000[9].w);
              float _900 = _899 + _897;
              float _901 = _898 * _898;
              float _902 = _901 * _898;
              float _903 = _902 - _898;
              float _904 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _905 = _894 * _894;
              float _906 = _905 * _904;
              float _907 = _906 * _903;
              float _908 = _900 + _907;
              _910 = _908;
            }
          }
        }
      }
      float _911 = saturate(_910);
      _913 = _703;
      _914 = _807;
      _915 = _911;
    } else {
      _913 = _577;
      _914 = _578;
      _915 = _579;
    }
    int _916 = _581 & 2;
    bool _917 = (_916 == 0);
    if (!_917) {
      float _919 = sqrt(_913);
      float _920 = sqrt(_914);
      float _921 = sqrt(_915);
      float _922 = dot(float3(_919, _920, _921), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _923 = 1.0f - _922;
      float _924 = saturate(_923);
      _926 = _924;
    } else {
      _926 = 1.0f;
    }
    int _927 = _581 & 8;
    bool _928 = (_927 == 0);
    if (_928) {
      int _930 = _581 & 4;
      bool _931 = (_930 == 0);
      if (!_931) {
        int _933 = _581 & 16;
        bool _934 = (_933 == 0);
        if (!_934) {
          float _938 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _939 = _938 + 0.5f;
          bool _940 = (_939 < 0.5f);
          float _941 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _942 = select(_940, (User_000.UserConstant_Z_000[5].x), _941);
          bool _943 = (_914 < _915);
          float _944 = select(_943, _915, _914);
          float _945 = select(_943, _914, _915);
          bool _946 = (_913 < _944);
          float _947 = select(_946, _944, _913);
          float _948 = select(_946, _913, _944);
          float _949 = min(_948, _945);
          float _950 = _947 - _949;
          float _951 = _947 + 1.000000013351432e-10f;
          float _952 = _950 / _951;
          float _954 = _952 - (User_000.UserConstant_Z_000[5].y);
          float _955 = saturate(_954);
          float _956 = max(_955, 9.999999974752427e-07f);
          float _957 = log2(_956);
          float _958 = _957 * _942;
          float _959 = exp2(_958);
          float _960 = 2.0f - _959;
          float _962 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _963 = saturate(_962);
          float _964 = max(_963, _960);
          float _965 = dot(float3(_913, _914, _915), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _966 = _913 - _965;
          float _967 = _914 - _965;
          float _968 = _915 - _965;
          float _969 = _966 * _964;
          float _970 = _967 * _964;
          float _971 = _968 * _964;
          float _972 = _965 - _913;
          float _973 = _972 + _969;
          float _974 = _965 - _914;
          float _975 = _974 + _970;
          float _976 = _965 - _915;
          float _977 = _976 + _971;
          float _978 = _973 * _926;
          float _979 = _975 * _926;
          float _980 = _977 * _926;
          float _981 = _978 + _913;
          float _982 = _979 + _914;
          float _983 = _980 + _915;
          _1100 = _981;
          _1101 = _982;
          _1102 = _983;
        } else {
          bool _985 = (_926 == 0.0f);
          if (!_985) {
            float _989 = abs(User_000.UserConstant_Z_000[5].x);
            float _990 = saturate(_989);
            uint4 _992 = 0u; t15.GetDimensions(0u, _992.x, _992.y, _992.w);
            float _995 = float((uint)_992.y);
            int _996 = _581 & 32;
            bool _997 = (_996 == 0);
            float _998 = _995 + -1.0f;
            if (!_997) {
              float _1000 = 1.0f / _998;
              uint _1001 = uint(SV_Position.x);
              uint _1002 = uint(SV_Position.y);
              int _1003 = _1001 & 63;
              int _1004 = _1002 & 63;
              float4 _1006 = t2.Load(int4(_1003, _1004, 0, 0));
              float _1009 = _1006.x + -0.5f;
              float _1010 = _913 * 13.999999046325684f;
              float _1011 = _914 * 13.999999046325684f;
              float _1012 = _915 * 13.999999046325684f;
              float _1013 = saturate(_1010);
              float _1014 = saturate(_1011);
              float _1015 = saturate(_1012);
              float _1016 = _913 + -0.9285714030265808f;
              float _1017 = _914 + -0.9285714030265808f;
              float _1018 = _915 + -0.9285714030265808f;
              float _1019 = _1016 * 13.999999046325684f;
              float _1020 = _1017 * 13.999999046325684f;
              float _1021 = _1018 * 13.999999046325684f;
              float _1022 = saturate(_1019);
              float _1023 = saturate(_1020);
              float _1024 = saturate(_1021);
              float _1025 = 1.0f - _1022;
              float _1026 = 1.0f - _1023;
              float _1027 = 1.0f - _1024;
              float _1028 = min(_1013, _1025);
              float _1029 = min(_1014, _1026);
              float _1030 = min(_1015, _1027);
              float _1031 = _1006.y + -0.5f;
              float _1032 = _1028 * _1031;
              float _1033 = _1029 * _1031;
              float _1034 = _1030 * _1031;
              float _1035 = _1032 + _1009;
              float _1036 = _1033 + _1009;
              float _1037 = _1034 + _1009;
              float _1038 = _1035 * _1000;
              float _1039 = _1036 * _1000;
              float _1040 = _1037 * _1000;
              float _1041 = _1038 + _913;
              float _1042 = _1039 + _914;
              float _1043 = _1040 + _915;
              float _1044 = saturate(_1041);
              float _1045 = saturate(_1042);
              float _1046 = saturate(_1043);
              float _1047 = saturate(_1044);
              float _1048 = saturate(_1045);
              float _1049 = saturate(_1046);
              _1051 = _1047;
              _1052 = _1048;
              _1053 = _1049;
            } else {
              _1051 = _913;
              _1052 = _914;
              _1053 = _915;
            }
            float _1054 = float((uint)_992.x);
            float _1055 = _998 / _1054;
            float _1056 = _1055 * _1051;
            float _1057 = 0.5f / _1054;
            float _1058 = _1056 + _1057;
            float _1059 = _998 / _995;
            float _1060 = _1059 * _1052;
            float _1061 = 0.5f / _995;
            float _1062 = _1060 + _1061;
            float _1063 = _1053 * _998;
            float _1064 = floor(_1063);
            float _1065 = frac(_1063);
            float _1066 = _1064 / _995;
            float _1067 = _1066 + _1058;
            float _1068 = _1064 + 1.0f;
            float _1069 = _1068 / _995;
            float _1070 = _1069 + _1058;
            float4 _1072 = t15.Sample(s1, float2(_1067, _1062));
            float4 _1076 = t15.Sample(s1, float2(_1070, _1062));
            float _1080 = _1076.x - _1072.x;
            float _1081 = _1076.y - _1072.y;
            float _1082 = _1076.z - _1072.z;
            float _1083 = _1080 * _1065;
            float _1084 = _1081 * _1065;
            float _1085 = _1082 * _1065;
            float _1086 = _990 * _926;
            float _1087 = _1072.x - _913;
            float _1088 = _1087 + _1083;
            float _1089 = _1072.y - _914;
            float _1090 = _1089 + _1084;
            float _1091 = _1072.z - _915;
            float _1092 = _1091 + _1085;
            float _1093 = _1088 * _1086;
            float _1094 = _1090 * _1086;
            float _1095 = _1092 * _1086;
            float _1096 = _1093 + _913;
            float _1097 = _1094 + _914;
            float _1098 = _1095 + _915;
            _1100 = _1096;
            _1101 = _1097;
            _1102 = _1098;
          } else {
            _1100 = _913;
            _1101 = _914;
            _1102 = _915;
          }
        }
      } else {
        _1100 = _913;
        _1101 = _914;
        _1102 = _915;
      }
    } else {
      _1100 = _926;
      _1101 = _926;
      _1102 = _926;
    }
    float _1103 = _1100 * 13.450128555297852f;
    float _1104 = _1101 * 13.450128555297852f;
    float _1105 = _1102 * 13.450128555297852f;
    float _1106 = exp2(_1103);
    float _1107 = exp2(_1104);
    float _1108 = exp2(_1105);
    float _1109 = _1106 + -1.0f;
    float _1110 = _1107 + -1.0f;
    float _1111 = _1108 + -1.0f;
    float _1112 = _1109 * _559;
    float _1113 = _1110 * _559;
    float _1114 = _1111 * _559;
    _1116 = _1112;
    _1117 = _1113;
    _1118 = _1114;
  } else {
    _1116 = _560;
    _1117 = _561;
    _1118 = _562;
  }
  float _1123 = (User_000.UserConstant_Z_000[8].x) * _1116;
  float _1124 = (User_000.UserConstant_Z_000[8].y) * _1117;
  float _1125 = (User_000.UserConstant_Z_000[8].z) * _1118;
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3(_1123, _1124, _1125),
      SV_Position.xy);
  float _1130 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _1131 = _1130 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _1132 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _1133 = _1132 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _1136 = _1131 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _1137 = _1133 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _1140 = t9.Sample(s9, float2(_1136, _1137));
  float _1144 = dot(float3(_1123, _1124, _1125), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _1147 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _1150 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _1151 = select(_1147, _1150, 0);
  float _1152 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _1153 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _1154 = uint(_1152);
  uint _1155 = uint(_1153);
  int _1156 = _1154 & 63;
  int _1157 = _1155 & 63;
  float4 _1159 = t2.Load(int4(_1156, _1157, _1151, 0));
  bool _1161 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_1161) {
    float _1163 = _1152 * 0.015625f;
    float _1164 = _1153 * 0.015625f;
    float _1165 = float((uint)_1150);
    float _1166 = select(_1147, _1165, 0.0f);
    float4 _1168 = t2.SampleLevel(s2, float3(_1163, _1164, _1166), 0.0f);
    float _1170 = _1159.y - _1168.y;
    float _1171 = _1170 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _1172 = _1171 + _1168.y;
    _1174 = _1172;
  } else {
    _1174 = _1159.y;
  }
  float _1175 = _1140.x * -2.0f;
  float _1176 = _1175 * _1174;
  float _1177 = _1174 * 2.0f;
  float _1178 = _1177 * _1140.y;
  float _1179 = _1177 * _1140.z;
  float _1180 = _1176 + _1140.x;
  float _1181 = _1178 - _1140.y;
  float _1182 = _1179 - _1140.z;
  float _1183 = _1180 * _1140.x;
  float _1184 = _1181 * _1140.y;
  float _1185 = _1182 * _1140.z;
  float _1186 = _1144 + 1.0f;
  float _1187 = _1144 / _1186;
  float _1188 = _1187 + -9.999999747378752e-05f;
  float _1189 = _1188 * 1111.111083984375f;
  float _1190 = saturate(_1189);
  float _1191 = _1190 * 2.0f;
  float _1192 = 3.0f - _1191;
  float _1193 = _1190 * _1190;
  float _1194 = _1193 * _1192;
  bool _1196 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _1197 = float((bool)_1196);
  float _1198 = dot(float3(_1183, _1184, _1185), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1199 = _1198 - _1183;
  float _1200 = _1198 - _1184;
  float _1201 = _1198 - _1185;
  float _1202 = _1199 * _1197;
  float _1203 = _1200 * _1197;
  float _1204 = _1201 * _1197;
  float _1205 = _1202 + _1183;
  float _1206 = _1203 + _1184;
  float _1207 = _1204 + _1185;
  float _1211 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1212 = _1211 * _1187;
  float _1213 = _1212 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1214 = _1194 * _1213;
  float _1215 = _1214 * _1205;
  float _1216 = _1214 * _1206;
  float _1217 = _1214 * _1207;
  float _1218 = _1215 + _1123;
  float _1219 = _1216 + _1124;
  float _1220 = _1217 + _1125;
  float _1221 = max(0.0f, _1218);
  float _1222 = max(0.0f, _1219);
  float _1223 = max(0.0f, _1220);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_1221, _1222, _1223),
      apt_perceptual_film_grain);
  _1221 = apt_film_grain_output.x;
  _1222 = apt_film_grain_output.y;
  _1223 = apt_film_grain_output.z;
  float _1226 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1227 = log2(_1221);
  float _1228 = _1226 * _1227;
  float _1229 = exp2(_1228);
  float _1230 = _1229 + -1.0f;
  float _1231 = _1221 + -1.0f;
  float _1232 = _1230 / _1231;
  bool _1233 = !(_1221 == 1.0f);
  float _1234 = _1232 + -1.0f;
  float _1235 = _1234 / _1232;
  float _1236 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1237 = _1236 / _1226;
  float _1238 = select(_1233, _1235, _1237);
  float _1239 = log2(_1222);
  float _1240 = _1239 * _1226;
  float _1241 = exp2(_1240);
  float _1242 = _1241 + -1.0f;
  float _1243 = _1222 + -1.0f;
  float _1244 = _1242 / _1243;
  bool _1245 = !(_1222 == 1.0f);
  float _1246 = _1244 + -1.0f;
  float _1247 = _1246 / _1244;
  float _1248 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1249 = _1248 / _1226;
  float _1250 = select(_1245, _1247, _1249);
  float _1251 = log2(_1223);
  float _1252 = _1251 * _1226;
  float _1253 = exp2(_1252);
  float _1254 = _1253 + -1.0f;
  float _1255 = _1223 + -1.0f;
  float _1256 = _1254 / _1255;
  bool _1257 = !(_1223 == 1.0f);
  float _1258 = _1256 + -1.0f;
  float _1259 = _1258 / _1256;
  float _1260 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1261 = _1260 / _1226;
  float _1262 = select(_1257, _1259, _1261);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1221, _1222, _1223),
      float3(_1238, _1250, _1262),
      true);
  float _1263 = apt_post_process_output.x;
  float _1264 = apt_post_process_output.y;
  float _1265 = apt_post_process_output.z;
  float _1266 = log2(_1263);
  float _1267 = log2(_1264);
  float _1268 = log2(_1265);
  float _1269 = _1266 * 0.4166666567325592f;
  float _1270 = _1267 * 0.4166666567325592f;
  float _1271 = _1268 * 0.4166666567325592f;
  float _1272 = exp2(_1269);
  float _1273 = exp2(_1270);
  float _1274 = exp2(_1271);
  float _1275 = _1272 * 1.0549999475479126f;
  float _1276 = _1273 * 1.0549999475479126f;
  float _1277 = _1274 * 1.0549999475479126f;
  float _1278 = _1275 + -0.054999999701976776f;
  float _1279 = _1276 + -0.054999999701976776f;
  float _1280 = _1277 + -0.054999999701976776f;
  float _1281 = _1263 * 12.920000076293945f;
  float _1282 = _1264 * 12.920000076293945f;
  float _1283 = _1265 * 12.920000076293945f;
  bool _1284 = (_1263 <= 0.0031308000907301903f);
  bool _1285 = (_1264 <= 0.0031308000907301903f);
  bool _1286 = (_1265 <= 0.0031308000907301903f);
  float _1287 = select(_1284, _1281, _1278);
  float _1288 = select(_1285, _1282, _1279);
  float _1289 = select(_1286, _1283, _1280);
  uint _1290 = uint(SV_Position.x);
  uint _1291 = uint(SV_Position.y);
  int _1292 = _1290 & 63;
  int _1293 = _1291 & 63;
  float4 _1295 = t1.Load(int4(_1292, _1293, _1150, 0));
  float _1297 = _1295.x + -0.5f;
  float _1298 = _1297 * 0.003921568859368563f;
  float _1299 = _1298 + _1287;
  float _1300 = _1298 + _1288;
  float _1301 = _1298 + _1289;
  float _1302 = saturate(_1299);
  float _1303 = saturate(_1300);
  float _1304 = saturate(_1301);
  SV_Target.x = _1302;
  SV_Target.y = _1303;
  SV_Target.z = _1304;
  SV_Target.w = _373;
  return SV_Target;
}
