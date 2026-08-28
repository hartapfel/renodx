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

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _35 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _41 = t16.Sample(s1, float2(TEXCOORD.z, TEXCOORD.w));
  float _43 = _41.y * 0.10000000149011612f;
  float _44 = _43 + _35.y;
  float _45 = _41.y * 0.5f;
  float _46 = _45 + _35.z;
  float _47 = exp2(_46);
  float _48 = _47 + -1.0f;
  float _51 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _48;
  float _52 = _51 + 1.0f;
  float _53 = log2(_52);
  float _54 = _35.x + TEXCOORD.z;
  float _55 = _44 + TEXCOORD.w;
  float _56 = _53 + 1.0f;
  float _57 = log2(_56);
  float4 _60 = t0.SampleLevel(s1, float2(_54, _55), _57);
  bool _65 = (_57 > 0.0f);
  float _370;
  float _371;
  float _372;
  float _373;
  float _409;
  float _493;
  float _530;
  float _720;
  float _759;
  float _760;
  float _761;
  float _961;
  float _1065;
  float _1169;
  float _1172;
  float _1173;
  float _1174;
  float _1185;
  float _1310;
  float _1311;
  float _1312;
  float _1359;
  float _1360;
  float _1361;
  float _1375;
  float _1376;
  float _1377;
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
    float _79 = _74 * _54;
    float _80 = _76 * _55;
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
    float _216 = _211 * _54;
    float _217 = _213 * _55;
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
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
      float3(_374, _375, _376),
      float3(_374, _375, _376),
      float2(_54, _55),
      t0,
      s1,
      _57);
  _374 = renodx_chromatic_aberration_input.x;
  _375 = renodx_chromatic_aberration_input.y;
  _376 = renodx_chromatic_aberration_input.z;
  int _379 = asint((User_000.UserConstant_Z_000[7].z));
  bool _380 = ((int)_379 > (int)0);
  [branch]
  if (_380) {
    bool _385 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_385) {
      float _387 = _35.x + TEXCOORD.x;
      float _388 = _44 + TEXCOORD.y;
      float4 _391 = t2.SampleLevel(s2, float2(_387, _388), 0.0f);
      bool _395 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_395) {
        float4 _398 = t7.Load(int3(0, 0, 0));
        float _403 = _398.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _404 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _403;
        _409 = _404;
      } else {
        _409 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _413 = _391.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _414 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _413;
      float _416 = _409 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _417 = _416 + _409;
      float _418 = _409 - _416;
      float _419 = max(_414, _418);
      float _420 = min(_419, _417);
      float _423 = _414 - _420;
      float _424 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _423;
      float _426 = _420 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _427 = _426 * _414;
      float _428 = _424 / _427;
      float _429 = min(_428, 0.0f);
      float _431 = _416 + 1.0f;
      float _432 = 1.0f / _431;
      float _433 = _429 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _434 = max(0.0f, _428);
      float _437 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _434;
      float _438 = _437 + _433;
      float _439 = _438 * _432;
      float _440 = max(_439, -1.0f);
      float _441 = min(_440, 1.0f);
      float _442 = max(_441, -0.30000001192092896f);
      float _443 = min(_442, 1.0f);
      float _445 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _446 = _443 * _445;
      float _447 = _387 + -0.5f;
      float _448 = _388 + -0.5f;
      float _449 = _447 * _447;
      float _450 = _448 * _448;
      float _451 = _450 + _449;
      float _452 = sqrt(_451);
      float _453 = log2(_452);
      float _454 = _453 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _455 = exp2(_454);
      float _456 = _455 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _457 = dot(float2(_447, _448), float2(_447, _448));
      float _458 = rsqrt(_457);
      float _459 = _458 * _447;
      float _460 = _458 * _448;
      float _461 = abs(_446);
      float _465 = _456 * _461;
      float _466 = -0.0f - _465;
      float _467 = (User_000.UserConstant_Z_000[2].x) * _459;
      float _468 = _467 * _466;
      float _469 = (User_000.UserConstant_Z_000[2].y) * _460;
      float _470 = _469 * _466;
      float _471 = _461 * _456;
      float _472 = _467 * _471;
      float _473 = _469 * _471;
      float _474 = _468 + _387;
      float _475 = _470 + _388;
      float _476 = _472 + _387;
      float _477 = _473 + _388;
      float4 _478 = t0.SampleLevel(s1, float2(_474, _475), 0.0f);
      float4 _480 = t0.SampleLevel(s1, float2(_476, _477), 0.0f);
      float4 _482 = t2.SampleLevel(s2, float2(_474, _475), 0.0f);
      if (_395) {
        float4 _486 = t7.Load(int3(0, 0, 0));
        float _488 = _486.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _489 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _488;
        _493 = _489;
      } else {
        _493 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _494 = _482.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _495 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _494;
      float _496 = _493 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _497 = _496 + _493;
      float _498 = _493 - _496;
      float _499 = max(_495, _498);
      float _500 = min(_499, _497);
      float _501 = _495 - _500;
      float _502 = _501 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _503 = _500 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _504 = _503 * _495;
      float _505 = _502 / _504;
      float _506 = min(_505, 0.0f);
      float _507 = _496 + 1.0f;
      float _508 = 1.0f / _507;
      float _509 = _506 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _510 = max(0.0f, _505);
      float _511 = _510 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _512 = _511 + _509;
      float _513 = _512 * _508;
      float _514 = max(_513, -1.0f);
      float _515 = min(_514, 1.0f);
      float _516 = max(_515, -0.30000001192092896f);
      float _517 = min(_516, 1.0f);
      float _518 = _517 * _445;
      float4 _519 = t2.SampleLevel(s2, float2(_476, _477), 0.0f);
      if (_395) {
        float4 _523 = t7.Load(int3(0, 0, 0));
        float _525 = _523.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _526 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _525;
        _530 = _526;
      } else {
        _530 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _531 = _519.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _532 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _531;
      float _533 = _530 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _534 = _533 + _530;
      float _535 = _530 - _533;
      float _536 = max(_532, _535);
      float _537 = min(_536, _534);
      float _538 = _532 - _537;
      float _539 = _538 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _540 = _537 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _541 = _540 * _532;
      float _542 = _539 / _541;
      float _543 = min(_542, 0.0f);
      float _544 = _533 + 1.0f;
      float _545 = 1.0f / _544;
      float _546 = _543 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _547 = max(0.0f, _542);
      float _548 = _547 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _549 = _548 + _546;
      float _550 = _549 * _545;
      float _551 = max(_550, -1.0f);
      float _552 = min(_551, 1.0f);
      float _553 = max(_552, -0.30000001192092896f);
      float _554 = min(_553, 1.0f);
      float _555 = _554 * _445;
      float _556 = abs(_518);
      float _557 = _556 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _558 = ceil(_557);
      float _559 = saturate(_558);
      float _560 = _478.x - _374;
      float _561 = _559 * _560;
      float _562 = _561 + _374;
      float _563 = abs(_555);
      float _564 = _563 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _565 = ceil(_564);
      float _566 = saturate(_565);
      float _567 = _480.z - _376;
      float _568 = _566 * _567;
      float _569 = _568 + _376;
      _759 = _562;
      _760 = _375;
      _761 = _569;
    } else {
      _759 = _374;
      _760 = _375;
      _761 = _376;
    }
  } else {
    int _572 = asint((User_000.UserConstant_Z_000[7].y));
    bool _573 = ((int)_572 > (int)0);
    if (_573) {
      float _575 = _35.x + TEXCOORD.x;
      float _576 = _44 + TEXCOORD.y;
      float4 _579 = t4.Sample(s4, float2(_575, _576));
      float4 _586 = t5.Sample(s5, float2(_575, _576));
      float _590 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _586.x;
      float _594 = _590 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _595 = _590 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _596 = _594 + _575;
      float _597 = _595 + _576;
      float4 _598 = t4.Sample(s4, float2(_596, _597));
      float4 _600 = t5.Sample(s5, float2(_596, _597));
      float _602 = _600.x * (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _603 = abs(_602);
      float _605 = _603 / (PostProcess_000.PostProcessConstant_Z_000[7].w);
      float _606 = _598.z - _579.z;
      float _607 = _605 * _606;
      float _608 = _579.x - _374;
      float _609 = _579.y - _375;
      float _610 = _579.z - _376;
      float _611 = _610 + _607;
      float _612 = _608 * _579.w;
      float _613 = _609 * _579.w;
      float _614 = _611 * _579.w;
      float _615 = _612 + _374;
      float _616 = _613 + _375;
      float _617 = _614 + _376;
      _759 = _615;
      _760 = _616;
      _761 = _617;
    } else {
      int _620 = asint((User_000.UserConstant_Z_000[7].x));
      bool _621 = ((int)_620 > (int)0);
      [branch]
      if (_621) {
        float4 _625 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _627 = abs(_625.x);
        _720 = _627;
      } else {
        float4 _631 = t2.SampleLevel(s2, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _633 = TEXCOORD.x * 2.0f;
        float _634 = TEXCOORD.y * 2.0f;
        float _635 = _633 + -1.0f;
        float _636 = _634 + -1.0f;
        float _657 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _635;
        float _658 = mad(_636, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _657);
        float _659 = mad(_631.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _658);
        float _660 = _659 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _661 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _635;
        float _662 = mad(_636, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _661);
        float _663 = mad(_631.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _662);
        float _664 = _663 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _665 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _635;
        float _666 = mad(_636, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _665);
        float _667 = mad(_631.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _666);
        float _668 = _667 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _669 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _635;
        float _670 = mad(_636, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _669);
        float _671 = mad(_631.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _670);
        float _672 = _671 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
        float _673 = _660 / _672;
        float _674 = _664 / _672;
        float _675 = _668 / _672;
        float _676 = _673 * _673;
        float _677 = _674 * _674;
        float _678 = _677 + _676;
        float _679 = _675 * _675;
        float _680 = _678 + _679;
        float _681 = sqrt(_680);
        float4 _684 = t5.Sample(s5, float2(TEXCOORD.x, TEXCOORD.y));
        float _690 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _691 = _690 + (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _692 = (PostProcess_000.PostProcessConstant_Z_000[5].x) - _690;
        float _693 = max(_681, _692);
        float _694 = min(_693, _691);
        float _696 = _681 - _694;
        float _697 = _696 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
        float _699 = _694 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _700 = _699 * _681;
        float _701 = _697 / _700;
        float _702 = min(_701, 0.0f);
        float _705 = _690 + 1.0f;
        float _706 = 1.0f / _705;
        float _707 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _702;
        float _708 = max(0.0f, _701);
        float _711 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _708;
        float _712 = _711 + _707;
        float _713 = _712 * _706;
        float _714 = min(_684.x, _713);
        float _715 = abs(_714);
        float _716 = abs(_713);
        float _717 = max(_715, _716);
        float _718 = saturate(_717);
        _720 = _718;
      }
      float _723 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _720;
      float4 _726 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _733 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _723;
      float _734 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _723;
      float _735 = _733 + TEXCOORD.x;
      float _736 = _734 + TEXCOORD.y;
      float4 _737 = t4.Sample(s4, float2(_735, _736));
      float4 _741 = t5.Sample(s5, float2(_735, _736));
      float _743 = abs(_741.x);
      float _744 = _737.z - _726.z;
      float _745 = _743 * _744;
      float _746 = _723 + -1.0f;
      float _747 = saturate(_746);
      float _748 = _726.x - _374;
      float _749 = _726.y - _375;
      float _750 = _726.z - _376;
      float _751 = _750 + _745;
      float _752 = _747 * _748;
      float _753 = _747 * _749;
      float _754 = _751 * _747;
      float _755 = _752 + _374;
      float _756 = _753 + _375;
      float _757 = _754 + _376;
      _759 = _755;
      _760 = _756;
      _761 = _757;
    }
  }
  float4 _765 = t17.Load(int3(0, 0, 0));
  float _773 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _774 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _775 = _765.x * _774;
  float _776 = _775 * _759;
  float _777 = _776 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _778 = _777 * _773;
  float _779 = _775 * _760;
  float _780 = _779 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _781 = _780 * _773;
  float _782 = _775 * _761;
  float _783 = _782 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _784 = _783 * _773;
  float _785 = _778 + 1.0f;
  float _786 = _781 + 1.0f;
  float _787 = _784 + 1.0f;
  float _788 = log2(_785);
  float _789 = log2(_786);
  float _790 = log2(_787);
  float _793 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _794 = _793 * _788;
  float _795 = _793 * _789;
  float _796 = _793 * _790;
  float _798 = _794 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _799 = _795 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _800 = _796 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _803 = t3.Sample(s3, float3(_798, _799, _800));
  float _809 = _803.x * 13.450128555297852f;
  float _810 = _803.y * 13.450128555297852f;
  float _811 = _803.z * 13.450128555297852f;
  float _812 = exp2(_809);
  float _813 = exp2(_810);
  float _814 = exp2(_811);
  float _815 = _812 + -1.0f;
  float _816 = _813 + -1.0f;
  float _817 = _814 + -1.0f;
  float _818 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _819 = _818 * _815;
  float _820 = _818 * _816;
  float _821 = _818 * _817;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_778 * _818, _781 * _818, _784 * _818),
      float3(_819, _820, _821),
      1.f.xxx);
  _819 = resonance_scaled_lut_output.x;
  _820 = resonance_scaled_lut_output.y;
  _821 = resonance_scaled_lut_output.z;
  bool _824 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_824) {
    float _826 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _827 = _819 * _826;
    float _828 = _820 * _826;
    float _829 = _821 * _826;
    float _830 = _827 + 1.0f;
    float _831 = _828 + 1.0f;
    float _832 = _829 + 1.0f;
    float _833 = log2(_830);
    float _834 = log2(_831);
    float _835 = log2(_832);
    float _836 = _833 * 0.07434873282909393f;
    float _837 = _834 * 0.07434873282909393f;
    float _838 = _835 * 0.07434873282909393f;
    int _840 = asint((User_000.UserConstant_Z_000[3].y));
    int _841 = _840 & 1;
    bool _842 = (_841 == 0);
    if (!_842) {
      bool _859 = !(_836 <= (User_000.UserConstant_Z_000[4].x));
      if (!_859) {
        float _861 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _862 = _836 / _861;
        float _863 = _862 * (User_000.UserConstant_Z_000[4].y);
        float _864 = _862 * _862;
        float _865 = _864 * _862;
        float _866 = _865 - _862;
        float _867 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _868 = _861 * _861;
        float _869 = _868 * _867;
        float _870 = _869 * _866;
        float _871 = _870 + _863;
        _961 = _871;
      } else {
        bool _873 = !(_836 <= (User_000.UserConstant_Z_000[4].z));
        if (!_873) {
          float _875 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _876 = max(9.999999974752427e-07f, _875);
          float _877 = _836 - (User_000.UserConstant_Z_000[4].x);
          float _878 = _877 / _876;
          float _879 = 1.0f - _878;
          float _880 = _879 * (User_000.UserConstant_Z_000[4].y);
          float _881 = _878 * (User_000.UserConstant_Z_000[4].w);
          float _882 = _880 + _881;
          float _883 = _879 * _879;
          float _884 = _883 * _879;
          float _885 = _884 - _879;
          float _886 = _885 * (User_000.UserConstant_Z_000[10].x);
          float _887 = _878 * _878;
          float _888 = _887 * _878;
          float _889 = _888 - _878;
          float _890 = _889 * (User_000.UserConstant_Z_000[10].y);
          float _891 = _886 + _890;
          float _892 = _876 * _876;
          float _893 = _892 * 0.1666666716337204f;
          float _894 = _893 * _891;
          float _895 = _882 + _894;
          _961 = _895;
        } else {
          bool _897 = !(_836 <= (User_000.UserConstant_Z_000[9].x));
          if (!_897) {
            float _899 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _900 = max(9.999999974752427e-07f, _899);
            float _901 = _836 - (User_000.UserConstant_Z_000[4].z);
            float _902 = _901 / _900;
            float _903 = 1.0f - _902;
            float _904 = _903 * (User_000.UserConstant_Z_000[4].w);
            float _905 = _902 * (User_000.UserConstant_Z_000[9].y);
            float _906 = _904 + _905;
            float _907 = _903 * _903;
            float _908 = _907 * _903;
            float _909 = _908 - _903;
            float _910 = _909 * (User_000.UserConstant_Z_000[10].y);
            float _911 = _902 * _902;
            float _912 = _911 * _902;
            float _913 = _912 - _902;
            float _914 = _913 * (User_000.UserConstant_Z_000[10].z);
            float _915 = _910 + _914;
            float _916 = _900 * _900;
            float _917 = _916 * 0.1666666716337204f;
            float _918 = _917 * _915;
            float _919 = _906 + _918;
            _961 = _919;
          } else {
            bool _921 = !(_836 <= (User_000.UserConstant_Z_000[9].z));
            if (!_921) {
              float _923 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _924 = max(9.999999974752427e-07f, _923);
              float _925 = _836 - (User_000.UserConstant_Z_000[9].x);
              float _926 = _925 / _924;
              float _927 = 1.0f - _926;
              float _928 = _927 * (User_000.UserConstant_Z_000[9].y);
              float _929 = _926 * (User_000.UserConstant_Z_000[9].w);
              float _930 = _928 + _929;
              float _931 = _927 * _927;
              float _932 = _931 * _927;
              float _933 = _932 - _927;
              float _934 = _933 * (User_000.UserConstant_Z_000[10].z);
              float _935 = _926 * _926;
              float _936 = _935 * _926;
              float _937 = _936 - _926;
              float _938 = _937 * (User_000.UserConstant_Z_000[10].w);
              float _939 = _934 + _938;
              float _940 = _924 * _924;
              float _941 = _940 * 0.1666666716337204f;
              float _942 = _941 * _939;
              float _943 = _930 + _942;
              _961 = _943;
            } else {
              float _945 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _946 = _836 - (User_000.UserConstant_Z_000[9].z);
              float _947 = max(9.999999974752427e-07f, _945);
              float _948 = _946 / _947;
              float _949 = 1.0f - _948;
              float _950 = _949 * (User_000.UserConstant_Z_000[9].w);
              float _951 = _950 + _948;
              float _952 = _949 * _949;
              float _953 = _952 * _949;
              float _954 = _953 - _949;
              float _955 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _956 = _945 * _945;
              float _957 = _956 * _955;
              float _958 = _957 * _954;
              float _959 = _951 + _958;
              _961 = _959;
            }
          }
        }
      }
      float _962 = saturate(_961);
      bool _963 = !(_837 <= (User_000.UserConstant_Z_000[4].x));
      if (!_963) {
        float _965 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _966 = _837 / _965;
        float _967 = _966 * (User_000.UserConstant_Z_000[4].y);
        float _968 = _966 * _966;
        float _969 = _968 * _966;
        float _970 = _969 - _966;
        float _971 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _972 = _965 * _965;
        float _973 = _972 * _971;
        float _974 = _973 * _970;
        float _975 = _974 + _967;
        _1065 = _975;
      } else {
        bool _977 = !(_837 <= (User_000.UserConstant_Z_000[4].z));
        if (!_977) {
          float _979 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _980 = max(9.999999974752427e-07f, _979);
          float _981 = _837 - (User_000.UserConstant_Z_000[4].x);
          float _982 = _981 / _980;
          float _983 = 1.0f - _982;
          float _984 = _983 * (User_000.UserConstant_Z_000[4].y);
          float _985 = _982 * (User_000.UserConstant_Z_000[4].w);
          float _986 = _984 + _985;
          float _987 = _983 * _983;
          float _988 = _987 * _983;
          float _989 = _988 - _983;
          float _990 = _989 * (User_000.UserConstant_Z_000[10].x);
          float _991 = _982 * _982;
          float _992 = _991 * _982;
          float _993 = _992 - _982;
          float _994 = _993 * (User_000.UserConstant_Z_000[10].y);
          float _995 = _990 + _994;
          float _996 = _980 * _980;
          float _997 = _996 * 0.1666666716337204f;
          float _998 = _997 * _995;
          float _999 = _986 + _998;
          _1065 = _999;
        } else {
          bool _1001 = !(_837 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1001) {
            float _1003 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1004 = max(9.999999974752427e-07f, _1003);
            float _1005 = _837 - (User_000.UserConstant_Z_000[4].z);
            float _1006 = _1005 / _1004;
            float _1007 = 1.0f - _1006;
            float _1008 = _1007 * (User_000.UserConstant_Z_000[4].w);
            float _1009 = _1006 * (User_000.UserConstant_Z_000[9].y);
            float _1010 = _1008 + _1009;
            float _1011 = _1007 * _1007;
            float _1012 = _1011 * _1007;
            float _1013 = _1012 - _1007;
            float _1014 = _1013 * (User_000.UserConstant_Z_000[10].y);
            float _1015 = _1006 * _1006;
            float _1016 = _1015 * _1006;
            float _1017 = _1016 - _1006;
            float _1018 = _1017 * (User_000.UserConstant_Z_000[10].z);
            float _1019 = _1014 + _1018;
            float _1020 = _1004 * _1004;
            float _1021 = _1020 * 0.1666666716337204f;
            float _1022 = _1021 * _1019;
            float _1023 = _1010 + _1022;
            _1065 = _1023;
          } else {
            bool _1025 = !(_837 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1025) {
              float _1027 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1028 = max(9.999999974752427e-07f, _1027);
              float _1029 = _837 - (User_000.UserConstant_Z_000[9].x);
              float _1030 = _1029 / _1028;
              float _1031 = 1.0f - _1030;
              float _1032 = _1031 * (User_000.UserConstant_Z_000[9].y);
              float _1033 = _1030 * (User_000.UserConstant_Z_000[9].w);
              float _1034 = _1032 + _1033;
              float _1035 = _1031 * _1031;
              float _1036 = _1035 * _1031;
              float _1037 = _1036 - _1031;
              float _1038 = _1037 * (User_000.UserConstant_Z_000[10].z);
              float _1039 = _1030 * _1030;
              float _1040 = _1039 * _1030;
              float _1041 = _1040 - _1030;
              float _1042 = _1041 * (User_000.UserConstant_Z_000[10].w);
              float _1043 = _1038 + _1042;
              float _1044 = _1028 * _1028;
              float _1045 = _1044 * 0.1666666716337204f;
              float _1046 = _1045 * _1043;
              float _1047 = _1034 + _1046;
              _1065 = _1047;
            } else {
              float _1049 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1050 = _837 - (User_000.UserConstant_Z_000[9].z);
              float _1051 = max(9.999999974752427e-07f, _1049);
              float _1052 = _1050 / _1051;
              float _1053 = 1.0f - _1052;
              float _1054 = _1053 * (User_000.UserConstant_Z_000[9].w);
              float _1055 = _1054 + _1052;
              float _1056 = _1053 * _1053;
              float _1057 = _1056 * _1053;
              float _1058 = _1057 - _1053;
              float _1059 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1060 = _1049 * _1049;
              float _1061 = _1060 * _1059;
              float _1062 = _1061 * _1058;
              float _1063 = _1055 + _1062;
              _1065 = _1063;
            }
          }
        }
      }
      float _1066 = saturate(_1065);
      bool _1067 = !(_838 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1067) {
        float _1069 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1070 = _838 / _1069;
        float _1071 = _1070 * (User_000.UserConstant_Z_000[4].y);
        float _1072 = _1070 * _1070;
        float _1073 = _1072 * _1070;
        float _1074 = _1073 - _1070;
        float _1075 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1076 = _1069 * _1069;
        float _1077 = _1076 * _1075;
        float _1078 = _1077 * _1074;
        float _1079 = _1078 + _1071;
        _1169 = _1079;
      } else {
        bool _1081 = !(_838 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1081) {
          float _1083 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1084 = max(9.999999974752427e-07f, _1083);
          float _1085 = _838 - (User_000.UserConstant_Z_000[4].x);
          float _1086 = _1085 / _1084;
          float _1087 = 1.0f - _1086;
          float _1088 = _1087 * (User_000.UserConstant_Z_000[4].y);
          float _1089 = _1086 * (User_000.UserConstant_Z_000[4].w);
          float _1090 = _1088 + _1089;
          float _1091 = _1087 * _1087;
          float _1092 = _1091 * _1087;
          float _1093 = _1092 - _1087;
          float _1094 = _1093 * (User_000.UserConstant_Z_000[10].x);
          float _1095 = _1086 * _1086;
          float _1096 = _1095 * _1086;
          float _1097 = _1096 - _1086;
          float _1098 = _1097 * (User_000.UserConstant_Z_000[10].y);
          float _1099 = _1094 + _1098;
          float _1100 = _1084 * _1084;
          float _1101 = _1100 * 0.1666666716337204f;
          float _1102 = _1101 * _1099;
          float _1103 = _1090 + _1102;
          _1169 = _1103;
        } else {
          bool _1105 = !(_838 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1105) {
            float _1107 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1108 = max(9.999999974752427e-07f, _1107);
            float _1109 = _838 - (User_000.UserConstant_Z_000[4].z);
            float _1110 = _1109 / _1108;
            float _1111 = 1.0f - _1110;
            float _1112 = _1111 * (User_000.UserConstant_Z_000[4].w);
            float _1113 = _1110 * (User_000.UserConstant_Z_000[9].y);
            float _1114 = _1112 + _1113;
            float _1115 = _1111 * _1111;
            float _1116 = _1115 * _1111;
            float _1117 = _1116 - _1111;
            float _1118 = _1117 * (User_000.UserConstant_Z_000[10].y);
            float _1119 = _1110 * _1110;
            float _1120 = _1119 * _1110;
            float _1121 = _1120 - _1110;
            float _1122 = _1121 * (User_000.UserConstant_Z_000[10].z);
            float _1123 = _1118 + _1122;
            float _1124 = _1108 * _1108;
            float _1125 = _1124 * 0.1666666716337204f;
            float _1126 = _1125 * _1123;
            float _1127 = _1114 + _1126;
            _1169 = _1127;
          } else {
            bool _1129 = !(_838 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1129) {
              float _1131 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1132 = max(9.999999974752427e-07f, _1131);
              float _1133 = _838 - (User_000.UserConstant_Z_000[9].x);
              float _1134 = _1133 / _1132;
              float _1135 = 1.0f - _1134;
              float _1136 = _1135 * (User_000.UserConstant_Z_000[9].y);
              float _1137 = _1134 * (User_000.UserConstant_Z_000[9].w);
              float _1138 = _1136 + _1137;
              float _1139 = _1135 * _1135;
              float _1140 = _1139 * _1135;
              float _1141 = _1140 - _1135;
              float _1142 = _1141 * (User_000.UserConstant_Z_000[10].z);
              float _1143 = _1134 * _1134;
              float _1144 = _1143 * _1134;
              float _1145 = _1144 - _1134;
              float _1146 = _1145 * (User_000.UserConstant_Z_000[10].w);
              float _1147 = _1142 + _1146;
              float _1148 = _1132 * _1132;
              float _1149 = _1148 * 0.1666666716337204f;
              float _1150 = _1149 * _1147;
              float _1151 = _1138 + _1150;
              _1169 = _1151;
            } else {
              float _1153 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1154 = _838 - (User_000.UserConstant_Z_000[9].z);
              float _1155 = max(9.999999974752427e-07f, _1153);
              float _1156 = _1154 / _1155;
              float _1157 = 1.0f - _1156;
              float _1158 = _1157 * (User_000.UserConstant_Z_000[9].w);
              float _1159 = _1158 + _1156;
              float _1160 = _1157 * _1157;
              float _1161 = _1160 * _1157;
              float _1162 = _1161 - _1157;
              float _1163 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1164 = _1153 * _1153;
              float _1165 = _1164 * _1163;
              float _1166 = _1165 * _1162;
              float _1167 = _1159 + _1166;
              _1169 = _1167;
            }
          }
        }
      }
      float _1170 = saturate(_1169);
      _1172 = _962;
      _1173 = _1066;
      _1174 = _1170;
    } else {
      _1172 = _836;
      _1173 = _837;
      _1174 = _838;
    }
    int _1175 = _840 & 2;
    bool _1176 = (_1175 == 0);
    if (!_1176) {
      float _1178 = sqrt(_1172);
      float _1179 = sqrt(_1173);
      float _1180 = sqrt(_1174);
      float _1181 = dot(float3(_1178, _1179, _1180), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1182 = 1.0f - _1181;
      float _1183 = saturate(_1182);
      _1185 = _1183;
    } else {
      _1185 = 1.0f;
    }
    int _1186 = _840 & 8;
    bool _1187 = (_1186 == 0);
    if (_1187) {
      int _1189 = _840 & 4;
      bool _1190 = (_1189 == 0);
      if (!_1190) {
        int _1192 = _840 & 16;
        bool _1193 = (_1192 == 0);
        if (!_1193) {
          float _1197 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1198 = _1197 + 0.5f;
          bool _1199 = (_1198 < 0.5f);
          float _1200 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1201 = select(_1199, (User_000.UserConstant_Z_000[5].x), _1200);
          bool _1202 = (_1173 < _1174);
          float _1203 = select(_1202, _1174, _1173);
          float _1204 = select(_1202, _1173, _1174);
          bool _1205 = (_1172 < _1203);
          float _1206 = select(_1205, _1203, _1172);
          float _1207 = select(_1205, _1172, _1203);
          float _1208 = min(_1207, _1204);
          float _1209 = _1206 - _1208;
          float _1210 = _1206 + 1.000000013351432e-10f;
          float _1211 = _1209 / _1210;
          float _1213 = _1211 - (User_000.UserConstant_Z_000[5].y);
          float _1214 = saturate(_1213);
          float _1215 = max(_1214, 9.999999974752427e-07f);
          float _1216 = log2(_1215);
          float _1217 = _1216 * _1201;
          float _1218 = exp2(_1217);
          float _1219 = 2.0f - _1218;
          float _1221 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1222 = saturate(_1221);
          float _1223 = max(_1222, _1219);
          float _1224 = dot(float3(_1172, _1173, _1174), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1225 = _1172 - _1224;
          float _1226 = _1173 - _1224;
          float _1227 = _1174 - _1224;
          float _1228 = _1225 * _1223;
          float _1229 = _1226 * _1223;
          float _1230 = _1227 * _1223;
          float _1231 = _1224 - _1172;
          float _1232 = _1231 + _1228;
          float _1233 = _1224 - _1173;
          float _1234 = _1233 + _1229;
          float _1235 = _1224 - _1174;
          float _1236 = _1235 + _1230;
          float _1237 = _1232 * _1185;
          float _1238 = _1234 * _1185;
          float _1239 = _1236 * _1185;
          float _1240 = _1237 + _1172;
          float _1241 = _1238 + _1173;
          float _1242 = _1239 + _1174;
          _1359 = _1240;
          _1360 = _1241;
          _1361 = _1242;
        } else {
          bool _1244 = (_1185 == 0.0f);
          if (!_1244) {
            float _1248 = abs(User_000.UserConstant_Z_000[5].x);
            float _1249 = saturate(_1248);
            uint4 _1251 = 0u; t15.GetDimensions(0u, _1251.x, _1251.y, _1251.w);
            float _1254 = float((uint)_1251.y);
            int _1255 = _840 & 32;
            bool _1256 = (_1255 == 0);
            float _1257 = _1254 + -1.0f;
            if (!_1256) {
              float _1259 = 1.0f / _1257;
              uint _1260 = uint(SV_Position.x);
              uint _1261 = uint(SV_Position.y);
              int _1262 = _1260 & 63;
              int _1263 = _1261 & 63;
              float4 _1265 = t6.Load(int4(_1262, _1263, 0, 0));
              float _1268 = _1265.x + -0.5f;
              float _1269 = _1172 * 13.999999046325684f;
              float _1270 = _1173 * 13.999999046325684f;
              float _1271 = _1174 * 13.999999046325684f;
              float _1272 = saturate(_1269);
              float _1273 = saturate(_1270);
              float _1274 = saturate(_1271);
              float _1275 = _1172 + -0.9285714030265808f;
              float _1276 = _1173 + -0.9285714030265808f;
              float _1277 = _1174 + -0.9285714030265808f;
              float _1278 = _1275 * 13.999999046325684f;
              float _1279 = _1276 * 13.999999046325684f;
              float _1280 = _1277 * 13.999999046325684f;
              float _1281 = saturate(_1278);
              float _1282 = saturate(_1279);
              float _1283 = saturate(_1280);
              float _1284 = 1.0f - _1281;
              float _1285 = 1.0f - _1282;
              float _1286 = 1.0f - _1283;
              float _1287 = min(_1272, _1284);
              float _1288 = min(_1273, _1285);
              float _1289 = min(_1274, _1286);
              float _1290 = _1265.y + -0.5f;
              float _1291 = _1287 * _1290;
              float _1292 = _1288 * _1290;
              float _1293 = _1289 * _1290;
              float _1294 = _1291 + _1268;
              float _1295 = _1292 + _1268;
              float _1296 = _1293 + _1268;
              float _1297 = _1294 * _1259;
              float _1298 = _1295 * _1259;
              float _1299 = _1296 * _1259;
              float _1300 = _1297 + _1172;
              float _1301 = _1298 + _1173;
              float _1302 = _1299 + _1174;
              float _1303 = saturate(_1300);
              float _1304 = saturate(_1301);
              float _1305 = saturate(_1302);
              float _1306 = saturate(_1303);
              float _1307 = saturate(_1304);
              float _1308 = saturate(_1305);
              _1310 = _1306;
              _1311 = _1307;
              _1312 = _1308;
            } else {
              _1310 = _1172;
              _1311 = _1173;
              _1312 = _1174;
            }
            float _1313 = float((uint)_1251.x);
            float _1314 = _1257 / _1313;
            float _1315 = _1314 * _1310;
            float _1316 = 0.5f / _1313;
            float _1317 = _1315 + _1316;
            float _1318 = _1257 / _1254;
            float _1319 = _1318 * _1311;
            float _1320 = 0.5f / _1254;
            float _1321 = _1319 + _1320;
            float _1322 = _1312 * _1257;
            float _1323 = floor(_1322);
            float _1324 = frac(_1322);
            float _1325 = _1323 / _1254;
            float _1326 = _1325 + _1317;
            float _1327 = _1323 + 1.0f;
            float _1328 = _1327 / _1254;
            float _1329 = _1328 + _1317;
            float4 _1331 = t15.Sample(s1, float2(_1326, _1321));
            float4 _1335 = t15.Sample(s1, float2(_1329, _1321));
            float _1339 = _1335.x - _1331.x;
            float _1340 = _1335.y - _1331.y;
            float _1341 = _1335.z - _1331.z;
            float _1342 = _1339 * _1324;
            float _1343 = _1340 * _1324;
            float _1344 = _1341 * _1324;
            float _1345 = _1249 * _1185;
            float _1346 = _1331.x - _1172;
            float _1347 = _1346 + _1342;
            float _1348 = _1331.y - _1173;
            float _1349 = _1348 + _1343;
            float _1350 = _1331.z - _1174;
            float _1351 = _1350 + _1344;
            float _1352 = _1347 * _1345;
            float _1353 = _1349 * _1345;
            float _1354 = _1351 * _1345;
            float _1355 = _1352 + _1172;
            float _1356 = _1353 + _1173;
            float _1357 = _1354 + _1174;
            _1359 = _1355;
            _1360 = _1356;
            _1361 = _1357;
          } else {
            _1359 = _1172;
            _1360 = _1173;
            _1361 = _1174;
          }
        }
      } else {
        _1359 = _1172;
        _1360 = _1173;
        _1361 = _1174;
      }
    } else {
      _1359 = _1185;
      _1360 = _1185;
      _1361 = _1185;
    }
    float _1362 = _1359 * 13.450128555297852f;
    float _1363 = _1360 * 13.450128555297852f;
    float _1364 = _1361 * 13.450128555297852f;
    float _1365 = exp2(_1362);
    float _1366 = exp2(_1363);
    float _1367 = exp2(_1364);
    float _1368 = _1365 + -1.0f;
    float _1369 = _1366 + -1.0f;
    float _1370 = _1367 + -1.0f;
    float _1371 = _1368 * _818;
    float _1372 = _1369 * _818;
    float _1373 = _1370 * _818;
    _1375 = _1371;
    _1376 = _1372;
    _1377 = _1373;
  } else {
    _1375 = _819;
    _1376 = _820;
    _1377 = _821;
  }
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1375, (User_000.UserConstant_Z_000[8].y) * _1376, (User_000.UserConstant_Z_000[8].z) * _1377),
      SV_Position.xy);
  float _1384 = resonance_perceptual_film_grain.x;
  float _1385 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1386 = log2(_1384);
  float _1387 = _1385 * _1386;
  float _1388 = exp2(_1387);
  float _1389 = _1388 + -1.0f;
  float _1390 = _1384 + -1.0f;
  float _1391 = _1389 / _1390;
  bool _1392 = !(_1384 == 1.0f);
  float _1393 = _1391 + -1.0f;
  float _1394 = _1393 / _1391;
  float _1395 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1396 = _1395 / _1385;
  float _1397 = select(_1392, _1394, _1396);
  float _1398 = resonance_perceptual_film_grain.y;
  float _1399 = log2(_1398);
  float _1400 = _1399 * _1385;
  float _1401 = exp2(_1400);
  float _1402 = _1401 + -1.0f;
  float _1403 = _1398 + -1.0f;
  float _1404 = _1402 / _1403;
  bool _1405 = !(_1398 == 1.0f);
  float _1406 = _1404 + -1.0f;
  float _1407 = _1406 / _1404;
  float _1408 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1409 = _1408 / _1385;
  float _1410 = select(_1405, _1407, _1409);
  float _1411 = resonance_perceptual_film_grain.z;
  float _1412 = log2(_1411);
  float _1413 = _1412 * _1385;
  float _1414 = exp2(_1413);
  float _1415 = _1414 + -1.0f;
  float _1416 = _1411 + -1.0f;
  float _1417 = _1415 / _1416;
  bool _1418 = !(_1411 == 1.0f);
  float _1419 = _1417 + -1.0f;
  float _1420 = _1419 / _1417;
  float _1421 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1422 = _1421 / _1385;
  float _1423 = select(_1418, _1420, _1422);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1384, _1398, _1411),
      float3(_1397, _1410, _1423),
      true);
  float _1424 = resonance_post_process_output.x;
  float _1425 = resonance_post_process_output.y;
  float _1426 = resonance_post_process_output.z;
  float _1427 = log2(_1424);
  float _1428 = log2(_1425);
  float _1429 = log2(_1426);
  float _1430 = _1427 * 0.4166666567325592f;
  float _1431 = _1428 * 0.4166666567325592f;
  float _1432 = _1429 * 0.4166666567325592f;
  float _1433 = exp2(_1430);
  float _1434 = exp2(_1431);
  float _1435 = exp2(_1432);
  float _1436 = _1433 * 1.0549999475479126f;
  float _1437 = _1434 * 1.0549999475479126f;
  float _1438 = _1435 * 1.0549999475479126f;
  float _1439 = _1436 + -0.054999999701976776f;
  float _1440 = _1437 + -0.054999999701976776f;
  float _1441 = _1438 + -0.054999999701976776f;
  float _1442 = _1424 * 12.920000076293945f;
  float _1443 = _1425 * 12.920000076293945f;
  float _1444 = _1426 * 12.920000076293945f;
  bool _1445 = (_1424 <= 0.0031308000907301903f);
  bool _1446 = (_1425 <= 0.0031308000907301903f);
  bool _1447 = (_1426 <= 0.0031308000907301903f);
  float _1448 = select(_1445, _1442, _1439);
  float _1449 = select(_1446, _1443, _1440);
  float _1450 = select(_1447, _1444, _1441);
  int _1453 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1454 = uint(SV_Position.x);
  uint _1455 = uint(SV_Position.y);
  int _1456 = _1454 & 63;
  int _1457 = _1455 & 63;
  float4 _1459 = t1.Load(int4(_1456, _1457, _1453, 0));
  float _1461 = _1459.x + -0.5f;
  float _1462 = _1461 * 0.003921568859368563f;
  float _1463 = _1462 + _1448;
  float _1464 = _1462 + _1449;
  float _1465 = _1462 + _1450;
  float _1466 = saturate(_1463);
  float _1467 = saturate(_1464);
  float _1468 = saturate(_1465);
  SV_Target.x = _1466;
  SV_Target.y = _1467;
  SV_Target.z = _1468;
  SV_Target.w = _373;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}