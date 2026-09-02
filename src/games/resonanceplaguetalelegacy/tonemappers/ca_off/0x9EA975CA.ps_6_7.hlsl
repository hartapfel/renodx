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
  float _415;
  float _416;
  float _417;
  float _655;
  float _759;
  float _863;
  float _866;
  float _867;
  float _868;
  float _879;
  float _1004;
  float _1005;
  float _1006;
  float _1053;
  float _1054;
  float _1055;
  float _1069;
  float _1070;
  float _1071;
  float _1127;
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
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
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
  bool _390 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
  float _394 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _384.x;
  float _395 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _384.y;
  float _396 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _384.z;
  float _397 = _394 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _398 = _395 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _399 = _396 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  if (!_390) {
    float _401 = _397 * _378.x;
    float _402 = _398 * _378.y;
    float _403 = _399 * _378.z;
    _415 = _401;
    _416 = _402;
    _417 = _403;
  } else {
    float _405 = saturate(_397);
    float _406 = saturate(_398);
    float _407 = saturate(_399);
    float _408 = _378.x - _374;
    float _409 = _378.y - _375;
    float _410 = _378.z - _376;
    float _411 = _405 * _408;
    float _412 = _406 * _409;
    float _413 = _407 * _410;
    _415 = _411;
    _416 = _412;
    _417 = _413;
  }
  float _418 = _415 + _374;
  float _419 = _416 + _375;
  float _420 = _417 + _376;
  float4 _424 = t17.Load(int3(0, 0, 0));
  float _430 = _424.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _431 = _430 * _418;
  float _432 = _431 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _433 = _430 * _419;
  float _434 = _433 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _435 = _430 * _420;
  float _436 = _435 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _441 = _52 * 2.0f;
  float _442 = _53 * 2.0f;
  float _443 = _441 + -1.0f;
  float _444 = _442 + -1.0f;
  float _447 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _444;
  float _448 = _443 * _443;
  float _449 = _447 * _447;
  float _450 = _449 + _448;
  float _451 = sqrt(_450);
  float _453 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _451;
  float _455 = _453 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _456 = saturate(_455);
  float _458 = log2(_456);
  float _459 = _458 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _460 = ResonanceScaleVignetteMask(exp2(_459));
  float _461 = _432 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _462 = _434 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _463 = _436 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _464 = _461 - _432;
  float _465 = _462 - _434;
  float _466 = _463 - _436;
  float _467 = _460 * _464;
  float _468 = _460 * _465;
  float _469 = _460 * _466;
  float _470 = _467 + _432;
  float _471 = _468 + _434;
  float _472 = _469 + _436;
  float _475 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _476 = _475 * _470;
  float _477 = _475 * _471;
  float _478 = _475 * _472;
  float _479 = _476 + 1.0f;
  float _480 = _477 + 1.0f;
  float _481 = _478 + 1.0f;
  float _482 = log2(_479);
  float _483 = log2(_480);
  float _484 = log2(_481);
  float _487 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _488 = _487 * _482;
  float _489 = _487 * _483;
  float _490 = _487 * _484;
  float _492 = _488 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _493 = _489 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _494 = _490 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _497 = t3.Sample(s3, float3(_492, _493, _494));
  float _503 = _497.x * 13.450128555297852f;
  float _504 = _497.y * 13.450128555297852f;
  float _505 = _497.z * 13.450128555297852f;
  float _506 = exp2(_503);
  float _507 = exp2(_504);
  float _508 = exp2(_505);
  float _509 = _506 + -1.0f;
  float _510 = _507 + -1.0f;
  float _511 = _508 + -1.0f;
  float _512 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _513 = _512 * _509;
  float _514 = _512 * _510;
  float _515 = _512 * _511;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_476 * _512, _477 * _512, _478 * _512),
      float3(_513, _514, _515),
      1.f.xxx);
  _513 = resonance_scaled_lut_output.x;
  _514 = resonance_scaled_lut_output.y;
  _515 = resonance_scaled_lut_output.z;
  bool _518 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_518) {
    float _520 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _521 = _513 * _520;
    float _522 = _514 * _520;
    float _523 = _515 * _520;
    float _524 = _521 + 1.0f;
    float _525 = _522 + 1.0f;
    float _526 = _523 + 1.0f;
    float _527 = log2(_524);
    float _528 = log2(_525);
    float _529 = log2(_526);
    float _530 = _527 * 0.07434873282909393f;
    float _531 = _528 * 0.07434873282909393f;
    float _532 = _529 * 0.07434873282909393f;
    int _534 = asint((User_000.UserConstant_Z_000[3].y));
    int _535 = _534 & 1;
    bool _536 = (_535 == 0);
    if (!_536) {
      bool _553 = !(_530 <= (User_000.UserConstant_Z_000[4].x));
      if (!_553) {
        float _555 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _556 = _530 / _555;
        float _557 = _556 * (User_000.UserConstant_Z_000[4].y);
        float _558 = _556 * _556;
        float _559 = _558 * _556;
        float _560 = _559 - _556;
        float _561 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _562 = _555 * _555;
        float _563 = _562 * _561;
        float _564 = _563 * _560;
        float _565 = _564 + _557;
        _655 = _565;
      } else {
        bool _567 = !(_530 <= (User_000.UserConstant_Z_000[4].z));
        if (!_567) {
          float _569 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _570 = max(9.999999974752427e-07f, _569);
          float _571 = _530 - (User_000.UserConstant_Z_000[4].x);
          float _572 = _571 / _570;
          float _573 = 1.0f - _572;
          float _574 = _573 * (User_000.UserConstant_Z_000[4].y);
          float _575 = _572 * (User_000.UserConstant_Z_000[4].w);
          float _576 = _574 + _575;
          float _577 = _573 * _573;
          float _578 = _577 * _573;
          float _579 = _578 - _573;
          float _580 = _579 * (User_000.UserConstant_Z_000[10].x);
          float _581 = _572 * _572;
          float _582 = _581 * _572;
          float _583 = _582 - _572;
          float _584 = _583 * (User_000.UserConstant_Z_000[10].y);
          float _585 = _580 + _584;
          float _586 = _570 * _570;
          float _587 = _586 * 0.1666666716337204f;
          float _588 = _587 * _585;
          float _589 = _576 + _588;
          _655 = _589;
        } else {
          bool _591 = !(_530 <= (User_000.UserConstant_Z_000[9].x));
          if (!_591) {
            float _593 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _594 = max(9.999999974752427e-07f, _593);
            float _595 = _530 - (User_000.UserConstant_Z_000[4].z);
            float _596 = _595 / _594;
            float _597 = 1.0f - _596;
            float _598 = _597 * (User_000.UserConstant_Z_000[4].w);
            float _599 = _596 * (User_000.UserConstant_Z_000[9].y);
            float _600 = _598 + _599;
            float _601 = _597 * _597;
            float _602 = _601 * _597;
            float _603 = _602 - _597;
            float _604 = _603 * (User_000.UserConstant_Z_000[10].y);
            float _605 = _596 * _596;
            float _606 = _605 * _596;
            float _607 = _606 - _596;
            float _608 = _607 * (User_000.UserConstant_Z_000[10].z);
            float _609 = _604 + _608;
            float _610 = _594 * _594;
            float _611 = _610 * 0.1666666716337204f;
            float _612 = _611 * _609;
            float _613 = _600 + _612;
            _655 = _613;
          } else {
            bool _615 = !(_530 <= (User_000.UserConstant_Z_000[9].z));
            if (!_615) {
              float _617 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _618 = max(9.999999974752427e-07f, _617);
              float _619 = _530 - (User_000.UserConstant_Z_000[9].x);
              float _620 = _619 / _618;
              float _621 = 1.0f - _620;
              float _622 = _621 * (User_000.UserConstant_Z_000[9].y);
              float _623 = _620 * (User_000.UserConstant_Z_000[9].w);
              float _624 = _622 + _623;
              float _625 = _621 * _621;
              float _626 = _625 * _621;
              float _627 = _626 - _621;
              float _628 = _627 * (User_000.UserConstant_Z_000[10].z);
              float _629 = _620 * _620;
              float _630 = _629 * _620;
              float _631 = _630 - _620;
              float _632 = _631 * (User_000.UserConstant_Z_000[10].w);
              float _633 = _628 + _632;
              float _634 = _618 * _618;
              float _635 = _634 * 0.1666666716337204f;
              float _636 = _635 * _633;
              float _637 = _624 + _636;
              _655 = _637;
            } else {
              float _639 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _640 = _530 - (User_000.UserConstant_Z_000[9].z);
              float _641 = max(9.999999974752427e-07f, _639);
              float _642 = _640 / _641;
              float _643 = 1.0f - _642;
              float _644 = _643 * (User_000.UserConstant_Z_000[9].w);
              float _645 = _644 + _642;
              float _646 = _643 * _643;
              float _647 = _646 * _643;
              float _648 = _647 - _643;
              float _649 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _650 = _639 * _639;
              float _651 = _650 * _649;
              float _652 = _651 * _648;
              float _653 = _645 + _652;
              _655 = _653;
            }
          }
        }
      }
      float _656 = saturate(_655);
      bool _657 = !(_531 <= (User_000.UserConstant_Z_000[4].x));
      if (!_657) {
        float _659 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _660 = _531 / _659;
        float _661 = _660 * (User_000.UserConstant_Z_000[4].y);
        float _662 = _660 * _660;
        float _663 = _662 * _660;
        float _664 = _663 - _660;
        float _665 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _666 = _659 * _659;
        float _667 = _666 * _665;
        float _668 = _667 * _664;
        float _669 = _668 + _661;
        _759 = _669;
      } else {
        bool _671 = !(_531 <= (User_000.UserConstant_Z_000[4].z));
        if (!_671) {
          float _673 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _674 = max(9.999999974752427e-07f, _673);
          float _675 = _531 - (User_000.UserConstant_Z_000[4].x);
          float _676 = _675 / _674;
          float _677 = 1.0f - _676;
          float _678 = _677 * (User_000.UserConstant_Z_000[4].y);
          float _679 = _676 * (User_000.UserConstant_Z_000[4].w);
          float _680 = _678 + _679;
          float _681 = _677 * _677;
          float _682 = _681 * _677;
          float _683 = _682 - _677;
          float _684 = _683 * (User_000.UserConstant_Z_000[10].x);
          float _685 = _676 * _676;
          float _686 = _685 * _676;
          float _687 = _686 - _676;
          float _688 = _687 * (User_000.UserConstant_Z_000[10].y);
          float _689 = _684 + _688;
          float _690 = _674 * _674;
          float _691 = _690 * 0.1666666716337204f;
          float _692 = _691 * _689;
          float _693 = _680 + _692;
          _759 = _693;
        } else {
          bool _695 = !(_531 <= (User_000.UserConstant_Z_000[9].x));
          if (!_695) {
            float _697 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _698 = max(9.999999974752427e-07f, _697);
            float _699 = _531 - (User_000.UserConstant_Z_000[4].z);
            float _700 = _699 / _698;
            float _701 = 1.0f - _700;
            float _702 = _701 * (User_000.UserConstant_Z_000[4].w);
            float _703 = _700 * (User_000.UserConstant_Z_000[9].y);
            float _704 = _702 + _703;
            float _705 = _701 * _701;
            float _706 = _705 * _701;
            float _707 = _706 - _701;
            float _708 = _707 * (User_000.UserConstant_Z_000[10].y);
            float _709 = _700 * _700;
            float _710 = _709 * _700;
            float _711 = _710 - _700;
            float _712 = _711 * (User_000.UserConstant_Z_000[10].z);
            float _713 = _708 + _712;
            float _714 = _698 * _698;
            float _715 = _714 * 0.1666666716337204f;
            float _716 = _715 * _713;
            float _717 = _704 + _716;
            _759 = _717;
          } else {
            bool _719 = !(_531 <= (User_000.UserConstant_Z_000[9].z));
            if (!_719) {
              float _721 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _722 = max(9.999999974752427e-07f, _721);
              float _723 = _531 - (User_000.UserConstant_Z_000[9].x);
              float _724 = _723 / _722;
              float _725 = 1.0f - _724;
              float _726 = _725 * (User_000.UserConstant_Z_000[9].y);
              float _727 = _724 * (User_000.UserConstant_Z_000[9].w);
              float _728 = _726 + _727;
              float _729 = _725 * _725;
              float _730 = _729 * _725;
              float _731 = _730 - _725;
              float _732 = _731 * (User_000.UserConstant_Z_000[10].z);
              float _733 = _724 * _724;
              float _734 = _733 * _724;
              float _735 = _734 - _724;
              float _736 = _735 * (User_000.UserConstant_Z_000[10].w);
              float _737 = _732 + _736;
              float _738 = _722 * _722;
              float _739 = _738 * 0.1666666716337204f;
              float _740 = _739 * _737;
              float _741 = _728 + _740;
              _759 = _741;
            } else {
              float _743 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _744 = _531 - (User_000.UserConstant_Z_000[9].z);
              float _745 = max(9.999999974752427e-07f, _743);
              float _746 = _744 / _745;
              float _747 = 1.0f - _746;
              float _748 = _747 * (User_000.UserConstant_Z_000[9].w);
              float _749 = _748 + _746;
              float _750 = _747 * _747;
              float _751 = _750 * _747;
              float _752 = _751 - _747;
              float _753 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _754 = _743 * _743;
              float _755 = _754 * _753;
              float _756 = _755 * _752;
              float _757 = _749 + _756;
              _759 = _757;
            }
          }
        }
      }
      float _760 = saturate(_759);
      bool _761 = !(_532 <= (User_000.UserConstant_Z_000[4].x));
      if (!_761) {
        float _763 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _764 = _532 / _763;
        float _765 = _764 * (User_000.UserConstant_Z_000[4].y);
        float _766 = _764 * _764;
        float _767 = _766 * _764;
        float _768 = _767 - _764;
        float _769 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _770 = _763 * _763;
        float _771 = _770 * _769;
        float _772 = _771 * _768;
        float _773 = _772 + _765;
        _863 = _773;
      } else {
        bool _775 = !(_532 <= (User_000.UserConstant_Z_000[4].z));
        if (!_775) {
          float _777 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _778 = max(9.999999974752427e-07f, _777);
          float _779 = _532 - (User_000.UserConstant_Z_000[4].x);
          float _780 = _779 / _778;
          float _781 = 1.0f - _780;
          float _782 = _781 * (User_000.UserConstant_Z_000[4].y);
          float _783 = _780 * (User_000.UserConstant_Z_000[4].w);
          float _784 = _782 + _783;
          float _785 = _781 * _781;
          float _786 = _785 * _781;
          float _787 = _786 - _781;
          float _788 = _787 * (User_000.UserConstant_Z_000[10].x);
          float _789 = _780 * _780;
          float _790 = _789 * _780;
          float _791 = _790 - _780;
          float _792 = _791 * (User_000.UserConstant_Z_000[10].y);
          float _793 = _788 + _792;
          float _794 = _778 * _778;
          float _795 = _794 * 0.1666666716337204f;
          float _796 = _795 * _793;
          float _797 = _784 + _796;
          _863 = _797;
        } else {
          bool _799 = !(_532 <= (User_000.UserConstant_Z_000[9].x));
          if (!_799) {
            float _801 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _802 = max(9.999999974752427e-07f, _801);
            float _803 = _532 - (User_000.UserConstant_Z_000[4].z);
            float _804 = _803 / _802;
            float _805 = 1.0f - _804;
            float _806 = _805 * (User_000.UserConstant_Z_000[4].w);
            float _807 = _804 * (User_000.UserConstant_Z_000[9].y);
            float _808 = _806 + _807;
            float _809 = _805 * _805;
            float _810 = _809 * _805;
            float _811 = _810 - _805;
            float _812 = _811 * (User_000.UserConstant_Z_000[10].y);
            float _813 = _804 * _804;
            float _814 = _813 * _804;
            float _815 = _814 - _804;
            float _816 = _815 * (User_000.UserConstant_Z_000[10].z);
            float _817 = _812 + _816;
            float _818 = _802 * _802;
            float _819 = _818 * 0.1666666716337204f;
            float _820 = _819 * _817;
            float _821 = _808 + _820;
            _863 = _821;
          } else {
            bool _823 = !(_532 <= (User_000.UserConstant_Z_000[9].z));
            if (!_823) {
              float _825 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _826 = max(9.999999974752427e-07f, _825);
              float _827 = _532 - (User_000.UserConstant_Z_000[9].x);
              float _828 = _827 / _826;
              float _829 = 1.0f - _828;
              float _830 = _829 * (User_000.UserConstant_Z_000[9].y);
              float _831 = _828 * (User_000.UserConstant_Z_000[9].w);
              float _832 = _830 + _831;
              float _833 = _829 * _829;
              float _834 = _833 * _829;
              float _835 = _834 - _829;
              float _836 = _835 * (User_000.UserConstant_Z_000[10].z);
              float _837 = _828 * _828;
              float _838 = _837 * _828;
              float _839 = _838 - _828;
              float _840 = _839 * (User_000.UserConstant_Z_000[10].w);
              float _841 = _836 + _840;
              float _842 = _826 * _826;
              float _843 = _842 * 0.1666666716337204f;
              float _844 = _843 * _841;
              float _845 = _832 + _844;
              _863 = _845;
            } else {
              float _847 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _848 = _532 - (User_000.UserConstant_Z_000[9].z);
              float _849 = max(9.999999974752427e-07f, _847);
              float _850 = _848 / _849;
              float _851 = 1.0f - _850;
              float _852 = _851 * (User_000.UserConstant_Z_000[9].w);
              float _853 = _852 + _850;
              float _854 = _851 * _851;
              float _855 = _854 * _851;
              float _856 = _855 - _851;
              float _857 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _858 = _847 * _847;
              float _859 = _858 * _857;
              float _860 = _859 * _856;
              float _861 = _853 + _860;
              _863 = _861;
            }
          }
        }
      }
      float _864 = saturate(_863);
      _866 = _656;
      _867 = _760;
      _868 = _864;
    } else {
      _866 = _530;
      _867 = _531;
      _868 = _532;
    }
    int _869 = _534 & 2;
    bool _870 = (_869 == 0);
    if (!_870) {
      float _872 = sqrt(_866);
      float _873 = sqrt(_867);
      float _874 = sqrt(_868);
      float _875 = dot(float3(_872, _873, _874), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _876 = 1.0f - _875;
      float _877 = saturate(_876);
      _879 = _877;
    } else {
      _879 = 1.0f;
    }
    int _880 = _534 & 8;
    bool _881 = (_880 == 0);
    if (_881) {
      int _883 = _534 & 4;
      bool _884 = (_883 == 0);
      if (!_884) {
        int _886 = _534 & 16;
        bool _887 = (_886 == 0);
        if (!_887) {
          float _891 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _892 = _891 + 0.5f;
          bool _893 = (_892 < 0.5f);
          float _894 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _895 = select(_893, (User_000.UserConstant_Z_000[5].x), _894);
          bool _896 = (_867 < _868);
          float _897 = select(_896, _868, _867);
          float _898 = select(_896, _867, _868);
          bool _899 = (_866 < _897);
          float _900 = select(_899, _897, _866);
          float _901 = select(_899, _866, _897);
          float _902 = min(_901, _898);
          float _903 = _900 - _902;
          float _904 = _900 + 1.000000013351432e-10f;
          float _905 = _903 / _904;
          float _907 = _905 - (User_000.UserConstant_Z_000[5].y);
          float _908 = saturate(_907);
          float _909 = max(_908, 9.999999974752427e-07f);
          float _910 = log2(_909);
          float _911 = _910 * _895;
          float _912 = exp2(_911);
          float _913 = 2.0f - _912;
          float _915 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _916 = saturate(_915);
          float _917 = max(_916, _913);
          float _918 = dot(float3(_866, _867, _868), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _919 = _866 - _918;
          float _920 = _867 - _918;
          float _921 = _868 - _918;
          float _922 = _919 * _917;
          float _923 = _920 * _917;
          float _924 = _921 * _917;
          float _925 = _918 - _866;
          float _926 = _925 + _922;
          float _927 = _918 - _867;
          float _928 = _927 + _923;
          float _929 = _918 - _868;
          float _930 = _929 + _924;
          float _931 = _926 * _879;
          float _932 = _928 * _879;
          float _933 = _930 * _879;
          float _934 = _931 + _866;
          float _935 = _932 + _867;
          float _936 = _933 + _868;
          _1053 = _934;
          _1054 = _935;
          _1055 = _936;
        } else {
          bool _938 = (_879 == 0.0f);
          if (!_938) {
            float _942 = abs(User_000.UserConstant_Z_000[5].x);
            float _943 = saturate(_942);
            uint4 _945 = 0u; t15.GetDimensions(0u, _945.x, _945.y, _945.w);
            float _948 = float((uint)_945.y);
            int _949 = _534 & 32;
            bool _950 = (_949 == 0);
            float _951 = _948 + -1.0f;
            if (!_950) {
              float _953 = 1.0f / _951;
              uint _954 = uint(SV_Position.x);
              uint _955 = uint(SV_Position.y);
              int _956 = _954 & 63;
              int _957 = _955 & 63;
              float4 _959 = t2.Load(int4(_956, _957, 0, 0));
              float _962 = _959.x + -0.5f;
              float _963 = _866 * 13.999999046325684f;
              float _964 = _867 * 13.999999046325684f;
              float _965 = _868 * 13.999999046325684f;
              float _966 = saturate(_963);
              float _967 = saturate(_964);
              float _968 = saturate(_965);
              float _969 = _866 + -0.9285714030265808f;
              float _970 = _867 + -0.9285714030265808f;
              float _971 = _868 + -0.9285714030265808f;
              float _972 = _969 * 13.999999046325684f;
              float _973 = _970 * 13.999999046325684f;
              float _974 = _971 * 13.999999046325684f;
              float _975 = saturate(_972);
              float _976 = saturate(_973);
              float _977 = saturate(_974);
              float _978 = 1.0f - _975;
              float _979 = 1.0f - _976;
              float _980 = 1.0f - _977;
              float _981 = min(_966, _978);
              float _982 = min(_967, _979);
              float _983 = min(_968, _980);
              float _984 = _959.y + -0.5f;
              float _985 = _981 * _984;
              float _986 = _982 * _984;
              float _987 = _983 * _984;
              float _988 = _985 + _962;
              float _989 = _986 + _962;
              float _990 = _987 + _962;
              float _991 = _988 * _953;
              float _992 = _989 * _953;
              float _993 = _990 * _953;
              float _994 = _991 + _866;
              float _995 = _992 + _867;
              float _996 = _993 + _868;
              float _997 = saturate(_994);
              float _998 = saturate(_995);
              float _999 = saturate(_996);
              float _1000 = saturate(_997);
              float _1001 = saturate(_998);
              float _1002 = saturate(_999);
              _1004 = _1000;
              _1005 = _1001;
              _1006 = _1002;
            } else {
              _1004 = _866;
              _1005 = _867;
              _1006 = _868;
            }
            float _1007 = float((uint)_945.x);
            float _1008 = _951 / _1007;
            float _1009 = _1008 * _1004;
            float _1010 = 0.5f / _1007;
            float _1011 = _1009 + _1010;
            float _1012 = _951 / _948;
            float _1013 = _1012 * _1005;
            float _1014 = 0.5f / _948;
            float _1015 = _1013 + _1014;
            float _1016 = _1006 * _951;
            float _1017 = floor(_1016);
            float _1018 = frac(_1016);
            float _1019 = _1017 / _948;
            float _1020 = _1019 + _1011;
            float _1021 = _1017 + 1.0f;
            float _1022 = _1021 / _948;
            float _1023 = _1022 + _1011;
            float4 _1025 = t15.Sample(s1, float2(_1020, _1015));
            float4 _1029 = t15.Sample(s1, float2(_1023, _1015));
            float _1033 = _1029.x - _1025.x;
            float _1034 = _1029.y - _1025.y;
            float _1035 = _1029.z - _1025.z;
            float _1036 = _1033 * _1018;
            float _1037 = _1034 * _1018;
            float _1038 = _1035 * _1018;
            float _1039 = _943 * _879;
            float _1040 = _1025.x - _866;
            float _1041 = _1040 + _1036;
            float _1042 = _1025.y - _867;
            float _1043 = _1042 + _1037;
            float _1044 = _1025.z - _868;
            float _1045 = _1044 + _1038;
            float _1046 = _1041 * _1039;
            float _1047 = _1043 * _1039;
            float _1048 = _1045 * _1039;
            float _1049 = _1046 + _866;
            float _1050 = _1047 + _867;
            float _1051 = _1048 + _868;
            _1053 = _1049;
            _1054 = _1050;
            _1055 = _1051;
          } else {
            _1053 = _866;
            _1054 = _867;
            _1055 = _868;
          }
        }
      } else {
        _1053 = _866;
        _1054 = _867;
        _1055 = _868;
      }
    } else {
      _1053 = _879;
      _1054 = _879;
      _1055 = _879;
    }
    float _1056 = _1053 * 13.450128555297852f;
    float _1057 = _1054 * 13.450128555297852f;
    float _1058 = _1055 * 13.450128555297852f;
    float _1059 = exp2(_1056);
    float _1060 = exp2(_1057);
    float _1061 = exp2(_1058);
    float _1062 = _1059 + -1.0f;
    float _1063 = _1060 + -1.0f;
    float _1064 = _1061 + -1.0f;
    float _1065 = _1062 * _512;
    float _1066 = _1063 * _512;
    float _1067 = _1064 * _512;
    _1069 = _1065;
    _1070 = _1066;
    _1071 = _1067;
  } else {
    _1069 = _513;
    _1070 = _514;
    _1071 = _515;
  }
  float _1076 = (User_000.UserConstant_Z_000[8].x) * _1069;
  float _1077 = (User_000.UserConstant_Z_000[8].y) * _1070;
  float _1078 = (User_000.UserConstant_Z_000[8].z) * _1071;
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3(_1076, _1077, _1078),
      SV_Position.xy);
  float _1083 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _1084 = _1083 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _1085 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _1086 = _1085 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _1089 = _1084 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _1090 = _1086 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _1093 = t9.Sample(s9, float2(_1089, _1090));
  float _1097 = dot(float3(_1076, _1077, _1078), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _1100 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _1103 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _1104 = select(_1100, _1103, 0);
  float _1105 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _1106 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _1107 = uint(_1105);
  uint _1108 = uint(_1106);
  int _1109 = _1107 & 63;
  int _1110 = _1108 & 63;
  float4 _1112 = t2.Load(int4(_1109, _1110, _1104, 0));
  bool _1114 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_1114) {
    float _1116 = _1105 * 0.015625f;
    float _1117 = _1106 * 0.015625f;
    float _1118 = float((uint)_1103);
    float _1119 = select(_1100, _1118, 0.0f);
    float4 _1121 = t2.SampleLevel(s2, float3(_1116, _1117, _1119), 0.0f);
    float _1123 = _1112.y - _1121.y;
    float _1124 = _1123 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _1125 = _1124 + _1121.y;
    _1127 = _1125;
  } else {
    _1127 = _1112.y;
  }
  float _1128 = _1093.x * -2.0f;
  float _1129 = _1128 * _1127;
  float _1130 = _1127 * 2.0f;
  float _1131 = _1130 * _1093.y;
  float _1132 = _1130 * _1093.z;
  float _1133 = _1129 + _1093.x;
  float _1134 = _1131 - _1093.y;
  float _1135 = _1132 - _1093.z;
  float _1136 = _1133 * _1093.x;
  float _1137 = _1134 * _1093.y;
  float _1138 = _1135 * _1093.z;
  float _1139 = _1097 + 1.0f;
  float _1140 = _1097 / _1139;
  float _1141 = _1140 + -9.999999747378752e-05f;
  float _1142 = _1141 * 1111.111083984375f;
  float _1143 = saturate(_1142);
  float _1144 = _1143 * 2.0f;
  float _1145 = 3.0f - _1144;
  float _1146 = _1143 * _1143;
  float _1147 = _1146 * _1145;
  bool _1149 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _1150 = float((bool)_1149);
  float _1151 = dot(float3(_1136, _1137, _1138), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1152 = _1151 - _1136;
  float _1153 = _1151 - _1137;
  float _1154 = _1151 - _1138;
  float _1155 = _1152 * _1150;
  float _1156 = _1153 * _1150;
  float _1157 = _1154 * _1150;
  float _1158 = _1155 + _1136;
  float _1159 = _1156 + _1137;
  float _1160 = _1157 + _1138;
  float _1164 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1165 = _1164 * _1140;
  float _1166 = _1165 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1167 = _1147 * _1166;
  float _1168 = _1167 * _1158;
  float _1169 = _1167 * _1159;
  float _1170 = _1167 * _1160;
  float _1171 = _1168 + _1076;
  float _1172 = _1169 + _1077;
  float _1173 = _1170 + _1078;
  float _1174 = max(0.0f, _1171);
  float _1175 = max(0.0f, _1172);
  float _1176 = max(0.0f, _1173);
  float3 resonance_film_grain_output = ResonanceSelectFilmGrainOutput(
      float3(_1174, _1175, _1176),
      resonance_perceptual_film_grain);
  _1174 = resonance_film_grain_output.x;
  _1175 = resonance_film_grain_output.y;
  _1176 = resonance_film_grain_output.z;
  float _1179 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1180 = log2(_1174);
  float _1181 = _1179 * _1180;
  float _1182 = exp2(_1181);
  float _1183 = _1182 + -1.0f;
  float _1184 = _1174 + -1.0f;
  float _1185 = _1183 / _1184;
  bool _1186 = !(_1174 == 1.0f);
  float _1187 = _1185 + -1.0f;
  float _1188 = _1187 / _1185;
  float _1189 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1190 = _1189 / _1179;
  float _1191 = select(_1186, _1188, _1190);
  float _1192 = log2(_1175);
  float _1193 = _1192 * _1179;
  float _1194 = exp2(_1193);
  float _1195 = _1194 + -1.0f;
  float _1196 = _1175 + -1.0f;
  float _1197 = _1195 / _1196;
  bool _1198 = !(_1175 == 1.0f);
  float _1199 = _1197 + -1.0f;
  float _1200 = _1199 / _1197;
  float _1201 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1202 = _1201 / _1179;
  float _1203 = select(_1198, _1200, _1202);
  float _1204 = log2(_1176);
  float _1205 = _1204 * _1179;
  float _1206 = exp2(_1205);
  float _1207 = _1206 + -1.0f;
  float _1208 = _1176 + -1.0f;
  float _1209 = _1207 / _1208;
  bool _1210 = !(_1176 == 1.0f);
  float _1211 = _1209 + -1.0f;
  float _1212 = _1211 / _1209;
  float _1213 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1214 = _1213 / _1179;
  float _1215 = select(_1210, _1212, _1214);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1174, _1175, _1176),
      float3(_1191, _1203, _1215),
      true);
  float _1216 = resonance_post_process_output.x;
  float _1217 = resonance_post_process_output.y;
  float _1218 = resonance_post_process_output.z;
  float _1219 = log2(_1216);
  float _1220 = log2(_1217);
  float _1221 = log2(_1218);
  float _1222 = _1219 * 0.4166666567325592f;
  float _1223 = _1220 * 0.4166666567325592f;
  float _1224 = _1221 * 0.4166666567325592f;
  float _1225 = exp2(_1222);
  float _1226 = exp2(_1223);
  float _1227 = exp2(_1224);
  float _1228 = _1225 * 1.0549999475479126f;
  float _1229 = _1226 * 1.0549999475479126f;
  float _1230 = _1227 * 1.0549999475479126f;
  float _1231 = _1228 + -0.054999999701976776f;
  float _1232 = _1229 + -0.054999999701976776f;
  float _1233 = _1230 + -0.054999999701976776f;
  float _1234 = _1216 * 12.920000076293945f;
  float _1235 = _1217 * 12.920000076293945f;
  float _1236 = _1218 * 12.920000076293945f;
  bool _1237 = (_1216 <= 0.0031308000907301903f);
  bool _1238 = (_1217 <= 0.0031308000907301903f);
  bool _1239 = (_1218 <= 0.0031308000907301903f);
  float _1240 = select(_1237, _1234, _1231);
  float _1241 = select(_1238, _1235, _1232);
  float _1242 = select(_1239, _1236, _1233);
  uint _1243 = uint(SV_Position.x);
  uint _1244 = uint(SV_Position.y);
  int _1245 = _1243 & 63;
  int _1246 = _1244 & 63;
  float4 _1248 = t1.Load(int4(_1245, _1246, _1103, 0));
  float _1250 = _1248.x + -0.5f;
  float _1251 = _1250 * 0.003921568859368563f;
  float _1252 = _1251 + _1240;
  float _1253 = _1251 + _1241;
  float _1254 = _1251 + _1242;
  float _1255 = saturate(_1252);
  float _1256 = saturate(_1253);
  float _1257 = saturate(_1254);
  SV_Target.x = _1255;
  SV_Target.y = _1256;
  SV_Target.z = _1257;
  SV_Target.w = _373;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}