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
  float4 _41 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _47 = t16.Sample(s1, float2(TEXCOORD.z, TEXCOORD.w));
  float _49 = _47.y * 0.10000000149011612f;
  float _50 = _49 + _41.y;
  float _51 = _47.y * 0.5f;
  float _52 = _51 + _41.z;
  float _53 = exp2(_52);
  float _54 = _53 + -1.0f;
  float _57 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _54;
  float _58 = _57 + 1.0f;
  float _59 = log2(_58);
  float _60 = _41.x + TEXCOORD.z;
  float _61 = _50 + TEXCOORD.w;
  float _62 = _41.x + TEXCOORD.x;
  float _63 = _50 + TEXCOORD.y;
  float _64 = _59 + 1.0f;
  float _65 = log2(_64);
  float4 _68 = t0.SampleLevel(s1, float2(_60, _61), _65);
  bool _73 = (_65 > 0.0f);
  float _378;
  float _379;
  float _380;
  float _381;
  float _417;
  float _501;
  float _538;
  float _728;
  float _767;
  float _768;
  float _769;
  float _808;
  float _809;
  float _810;
  float _1048;
  float _1152;
  float _1256;
  float _1259;
  float _1260;
  float _1261;
  float _1272;
  float _1397;
  float _1398;
  float _1399;
  float _1446;
  float _1447;
  float _1448;
  float _1462;
  float _1463;
  float _1464;
  float _1520;
  [branch]
  if (_73) {
    float _75 = floor(_65);
    int _76 = int(_75);
    uint4 _77 = 0u; t0.GetDimensions(0u, _77.x, _77.y, _77.w);
    int _80 = _76 & 31;
    int _81 = (uint)(_77.x) >> _80;
    float _82 = float((uint)_81);
    int _83 = (uint)(_77.y) >> _80;
    float _84 = float((uint)_83);
    float _85 = 1.0f / _82;
    float _86 = 1.0f / _84;
    float _87 = _82 * _60;
    float _88 = _84 * _61;
    float _89 = _87 + -0.5f;
    float _90 = _88 + -0.5f;
    float _91 = frac(_89);
    float _92 = frac(_90);
    float _93 = floor(_89);
    float _94 = floor(_90);
    float _95 = 1.0f - _91;
    float _96 = 2.0f - _91;
    float _97 = 3.0f - _91;
    float _98 = _95 * _95;
    float _99 = _96 * _96;
    float _100 = _97 * _97;
    float _101 = _98 * _95;
    float _102 = _99 * _96;
    float _103 = _100 * _97;
    float _104 = _101 * 4.0f;
    float _105 = _102 - _104;
    float _106 = _102 * 4.0f;
    float _107 = _101 * 6.0f;
    float _108 = 6.0f - _101;
    float _109 = _108 - _105;
    float _110 = _106 - _103;
    float _111 = _110 - _107;
    float _112 = _111 + _109;
    float _113 = _105 * 0.1666666716337204f;
    float _114 = _112 * 0.1666666716337204f;
    float _115 = 1.0f - _92;
    float _116 = 2.0f - _92;
    float _117 = 3.0f - _92;
    float _118 = _115 * _115;
    float _119 = _116 * _116;
    float _120 = _117 * _117;
    float _121 = _118 * _115;
    float _122 = _119 * _116;
    float _123 = _120 * _117;
    float _124 = _121 * 4.0f;
    float _125 = _122 - _124;
    float _126 = _122 * 4.0f;
    float _127 = _121 * 6.0f;
    float _128 = 6.0f - _121;
    float _129 = _128 - _125;
    float _130 = _126 - _123;
    float _131 = _130 - _127;
    float _132 = _131 + _129;
    float _133 = _125 * 0.1666666716337204f;
    float _134 = _132 * 0.1666666716337204f;
    float _135 = _93 + -0.5f;
    float _136 = _93 + 1.5f;
    float _137 = _94 + -0.5f;
    float _138 = _94 + 1.5f;
    float _139 = _105 + _101;
    float _140 = _139 * 0.1666666716337204f;
    float _141 = _109 * 0.1666666716337204f;
    float _142 = _125 + _121;
    float _143 = _142 * 0.1666666716337204f;
    float _144 = _129 * 0.1666666716337204f;
    float _145 = _113 / _140;
    float _146 = _114 / _141;
    float _147 = _133 / _143;
    float _148 = _134 / _144;
    float _149 = _135 + _145;
    float _150 = _136 + _146;
    float _151 = _137 + _147;
    float _152 = _138 + _148;
    float _153 = _149 * _85;
    float _154 = _150 * _85;
    float _155 = _151 * _86;
    float _156 = _152 * _86;
    float _157 = float((int)(_76));
    float4 _159 = t0.SampleLevel(s0, float2(_153, _155), _157);
    float4 _164 = t0.SampleLevel(s0, float2(_154, _155), _157);
    float4 _169 = t0.SampleLevel(s0, float2(_153, _156), _157);
    float4 _174 = t0.SampleLevel(s0, float2(_154, _156), _157);
    float _179 = _159.x - _164.x;
    float _180 = _159.y - _164.y;
    float _181 = _159.z - _164.z;
    float _182 = _159.w - _164.w;
    float _183 = _179 * _140;
    float _184 = _180 * _140;
    float _185 = _181 * _140;
    float _186 = _182 * _140;
    float _187 = _183 + _164.x;
    float _188 = _184 + _164.y;
    float _189 = _185 + _164.z;
    float _190 = _186 + _164.w;
    float _191 = _169.x - _174.x;
    float _192 = _169.y - _174.y;
    float _193 = _169.z - _174.z;
    float _194 = _169.w - _174.w;
    float _195 = _191 * _140;
    float _196 = _192 * _140;
    float _197 = _193 * _140;
    float _198 = _194 * _140;
    float _199 = _195 + _174.x;
    float _200 = _196 + _174.y;
    float _201 = _197 + _174.z;
    float _202 = _198 + _174.w;
    float _203 = _187 - _199;
    float _204 = _188 - _200;
    float _205 = _189 - _201;
    float _206 = _190 - _202;
    float _207 = _203 * _143;
    float _208 = _204 * _143;
    float _209 = _205 * _143;
    float _210 = _206 * _143;
    float _211 = _207 + _199;
    float _212 = _208 + _200;
    float _213 = _209 + _201;
    float _214 = _210 + _202;
    float _215 = ceil(_65);
    int _216 = int(_215);
    int _217 = _216 & 31;
    int _218 = (uint)(_77.x) >> _217;
    float _219 = float((uint)_218);
    int _220 = (uint)(_77.y) >> _217;
    float _221 = float((uint)_220);
    float _222 = 1.0f / _219;
    float _223 = 1.0f / _221;
    float _224 = _219 * _60;
    float _225 = _221 * _61;
    float _226 = _224 + -0.5f;
    float _227 = _225 + -0.5f;
    float _228 = frac(_226);
    float _229 = frac(_227);
    float _230 = floor(_226);
    float _231 = floor(_227);
    float _232 = 1.0f - _228;
    float _233 = 2.0f - _228;
    float _234 = 3.0f - _228;
    float _235 = _232 * _232;
    float _236 = _233 * _233;
    float _237 = _234 * _234;
    float _238 = _235 * _232;
    float _239 = _236 * _233;
    float _240 = _237 * _234;
    float _241 = _238 * 4.0f;
    float _242 = _239 - _241;
    float _243 = _239 * 4.0f;
    float _244 = _238 * 6.0f;
    float _245 = 6.0f - _238;
    float _246 = _245 - _242;
    float _247 = _243 - _240;
    float _248 = _247 - _244;
    float _249 = _248 + _246;
    float _250 = _242 * 0.1666666716337204f;
    float _251 = _249 * 0.1666666716337204f;
    float _252 = 1.0f - _229;
    float _253 = 2.0f - _229;
    float _254 = 3.0f - _229;
    float _255 = _252 * _252;
    float _256 = _253 * _253;
    float _257 = _254 * _254;
    float _258 = _255 * _252;
    float _259 = _256 * _253;
    float _260 = _257 * _254;
    float _261 = _258 * 4.0f;
    float _262 = _259 - _261;
    float _263 = _259 * 4.0f;
    float _264 = _258 * 6.0f;
    float _265 = 6.0f - _258;
    float _266 = _265 - _262;
    float _267 = _263 - _260;
    float _268 = _267 - _264;
    float _269 = _268 + _266;
    float _270 = _262 * 0.1666666716337204f;
    float _271 = _269 * 0.1666666716337204f;
    float _272 = _230 + -0.5f;
    float _273 = _230 + 1.5f;
    float _274 = _231 + -0.5f;
    float _275 = _231 + 1.5f;
    float _276 = _242 + _238;
    float _277 = _276 * 0.1666666716337204f;
    float _278 = _246 * 0.1666666716337204f;
    float _279 = _262 + _258;
    float _280 = _279 * 0.1666666716337204f;
    float _281 = _266 * 0.1666666716337204f;
    float _282 = _250 / _277;
    float _283 = _251 / _278;
    float _284 = _270 / _280;
    float _285 = _271 / _281;
    float _286 = _272 + _282;
    float _287 = _273 + _283;
    float _288 = _274 + _284;
    float _289 = _275 + _285;
    float _290 = _286 * _222;
    float _291 = _287 * _222;
    float _292 = _288 * _223;
    float _293 = _289 * _223;
    float _294 = float((int)(_216));
    float4 _295 = t0.SampleLevel(s0, float2(_290, _292), _294);
    float4 _300 = t0.SampleLevel(s0, float2(_291, _292), _294);
    float4 _305 = t0.SampleLevel(s0, float2(_290, _293), _294);
    float4 _310 = t0.SampleLevel(s0, float2(_291, _293), _294);
    float _315 = _295.x - _300.x;
    float _316 = _295.y - _300.y;
    float _317 = _295.z - _300.z;
    float _318 = _295.w - _300.w;
    float _319 = _315 * _277;
    float _320 = _316 * _277;
    float _321 = _317 * _277;
    float _322 = _318 * _277;
    float _323 = _319 + _300.x;
    float _324 = _320 + _300.y;
    float _325 = _321 + _300.z;
    float _326 = _322 + _300.w;
    float _327 = _305.x - _310.x;
    float _328 = _305.y - _310.y;
    float _329 = _305.z - _310.z;
    float _330 = _305.w - _310.w;
    float _331 = _327 * _277;
    float _332 = _328 * _277;
    float _333 = _329 * _277;
    float _334 = _330 * _277;
    float _335 = _331 + _310.x;
    float _336 = _332 + _310.y;
    float _337 = _333 + _310.z;
    float _338 = _334 + _310.w;
    float _339 = _323 - _335;
    float _340 = _324 - _336;
    float _341 = _325 - _337;
    float _342 = _326 - _338;
    float _343 = _339 * _280;
    float _344 = _340 * _280;
    float _345 = _341 * _280;
    float _346 = _342 * _280;
    float _347 = frac(_65);
    float _348 = _335 - _211;
    float _349 = _348 + _343;
    float _350 = _336 - _212;
    float _351 = _350 + _344;
    float _352 = _337 - _213;
    float _353 = _352 + _345;
    float _354 = _338 - _214;
    float _355 = _354 + _346;
    float _356 = _349 * _347;
    float _357 = _351 * _347;
    float _358 = _353 * _347;
    float _359 = _355 * _347;
    float _360 = saturate(_65);
    float _361 = _211 - _68.x;
    float _362 = _361 + _356;
    float _363 = _212 - _68.y;
    float _364 = _363 + _357;
    float _365 = _213 - _68.z;
    float _366 = _365 + _358;
    float _367 = _214 - _68.w;
    float _368 = _367 + _359;
    float _369 = _362 * _360;
    float _370 = _364 * _360;
    float _371 = _366 * _360;
    float _372 = _368 * _360;
    float _373 = _369 + _68.x;
    float _374 = _370 + _68.y;
    float _375 = _371 + _68.z;
    float _376 = _372 + _68.w;
    _378 = _373;
    _379 = _374;
    _380 = _375;
    _381 = _376;
  } else {
    _378 = _68.x;
    _379 = _68.y;
    _380 = _68.z;
    _381 = _68.w;
  }
  float _382 = max(_378, 0.0f);
  float _383 = max(_379, 0.0f);
  float _384 = max(_380, 0.0f);
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
      float3(_382, _383, _384),
      float3(_382, _383, _384),
      float2(_60, _61),
      t0,
      s1,
      _65);
  _382 = renodx_chromatic_aberration_input.x;
  _383 = renodx_chromatic_aberration_input.y;
  _384 = renodx_chromatic_aberration_input.z;
  int _387 = asint((User_000.UserConstant_Z_000[7].z));
  bool _388 = ((int)_387 > (int)0);
  [branch]
  if (_388) {
    bool _393 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_393) {
      float _395 = _41.x + TEXCOORD.x;
      float _396 = _50 + TEXCOORD.y;
      float4 _399 = t2.SampleLevel(s2, float2(_395, _396), 0.0f);
      bool _403 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_403) {
        float4 _406 = t7.Load(int3(0, 0, 0));
        float _411 = _406.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _412 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _411;
        _417 = _412;
      } else {
        _417 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _421 = _399.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _422 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _421;
      float _424 = _417 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _425 = _424 + _417;
      float _426 = _417 - _424;
      float _427 = max(_422, _426);
      float _428 = min(_427, _425);
      float _431 = _422 - _428;
      float _432 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _431;
      float _434 = _428 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _435 = _434 * _422;
      float _436 = _432 / _435;
      float _437 = min(_436, 0.0f);
      float _439 = _424 + 1.0f;
      float _440 = 1.0f / _439;
      float _441 = _437 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _442 = max(0.0f, _436);
      float _445 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _442;
      float _446 = _445 + _441;
      float _447 = _446 * _440;
      float _448 = max(_447, -1.0f);
      float _449 = min(_448, 1.0f);
      float _450 = max(_449, -0.30000001192092896f);
      float _451 = min(_450, 1.0f);
      float _453 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _454 = _451 * _453;
      float _455 = _395 + -0.5f;
      float _456 = _396 + -0.5f;
      float _457 = _455 * _455;
      float _458 = _456 * _456;
      float _459 = _458 + _457;
      float _460 = sqrt(_459);
      float _461 = log2(_460);
      float _462 = _461 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _463 = exp2(_462);
      float _464 = _463 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _465 = dot(float2(_455, _456), float2(_455, _456));
      float _466 = rsqrt(_465);
      float _467 = _466 * _455;
      float _468 = _466 * _456;
      float _469 = abs(_454);
      float _473 = _464 * _469;
      float _474 = -0.0f - _473;
      float _475 = (User_000.UserConstant_Z_000[2].x) * _467;
      float _476 = _475 * _474;
      float _477 = (User_000.UserConstant_Z_000[2].y) * _468;
      float _478 = _477 * _474;
      float _479 = _469 * _464;
      float _480 = _475 * _479;
      float _481 = _477 * _479;
      float _482 = _476 + _395;
      float _483 = _478 + _396;
      float _484 = _480 + _395;
      float _485 = _481 + _396;
      float4 _486 = t0.SampleLevel(s1, float2(_482, _483), 0.0f);
      float4 _488 = t0.SampleLevel(s1, float2(_484, _485), 0.0f);
      float4 _490 = t2.SampleLevel(s2, float2(_482, _483), 0.0f);
      if (_403) {
        float4 _494 = t7.Load(int3(0, 0, 0));
        float _496 = _494.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _497 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _496;
        _501 = _497;
      } else {
        _501 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _502 = _490.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _503 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _502;
      float _504 = _501 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _505 = _504 + _501;
      float _506 = _501 - _504;
      float _507 = max(_503, _506);
      float _508 = min(_507, _505);
      float _509 = _503 - _508;
      float _510 = _509 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _511 = _508 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _512 = _511 * _503;
      float _513 = _510 / _512;
      float _514 = min(_513, 0.0f);
      float _515 = _504 + 1.0f;
      float _516 = 1.0f / _515;
      float _517 = _514 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _518 = max(0.0f, _513);
      float _519 = _518 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _520 = _519 + _517;
      float _521 = _520 * _516;
      float _522 = max(_521, -1.0f);
      float _523 = min(_522, 1.0f);
      float _524 = max(_523, -0.30000001192092896f);
      float _525 = min(_524, 1.0f);
      float _526 = _525 * _453;
      float4 _527 = t2.SampleLevel(s2, float2(_484, _485), 0.0f);
      if (_403) {
        float4 _531 = t7.Load(int3(0, 0, 0));
        float _533 = _531.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _534 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _533;
        _538 = _534;
      } else {
        _538 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _539 = _527.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _540 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _539;
      float _541 = _538 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _542 = _541 + _538;
      float _543 = _538 - _541;
      float _544 = max(_540, _543);
      float _545 = min(_544, _542);
      float _546 = _540 - _545;
      float _547 = _546 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _548 = _545 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _549 = _548 * _540;
      float _550 = _547 / _549;
      float _551 = min(_550, 0.0f);
      float _552 = _541 + 1.0f;
      float _553 = 1.0f / _552;
      float _554 = _551 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _555 = max(0.0f, _550);
      float _556 = _555 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _557 = _556 + _554;
      float _558 = _557 * _553;
      float _559 = max(_558, -1.0f);
      float _560 = min(_559, 1.0f);
      float _561 = max(_560, -0.30000001192092896f);
      float _562 = min(_561, 1.0f);
      float _563 = _562 * _453;
      float _564 = abs(_526);
      float _565 = _564 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _566 = ceil(_565);
      float _567 = saturate(_566);
      float _568 = _486.x - _382;
      float _569 = _567 * _568;
      float _570 = _569 + _382;
      float _571 = abs(_563);
      float _572 = _571 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _573 = ceil(_572);
      float _574 = saturate(_573);
      float _575 = _488.z - _384;
      float _576 = _574 * _575;
      float _577 = _576 + _384;
      _767 = _570;
      _768 = _383;
      _769 = _577;
    } else {
      _767 = _382;
      _768 = _383;
      _769 = _384;
    }
  } else {
    int _580 = asint((User_000.UserConstant_Z_000[7].y));
    bool _581 = ((int)_580 > (int)0);
    if (_581) {
      float _583 = _41.x + TEXCOORD.x;
      float _584 = _50 + TEXCOORD.y;
      float4 _587 = t4.Sample(s4, float2(_583, _584));
      float4 _594 = t5.Sample(s5, float2(_583, _584));
      float _598 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _594.x;
      float _602 = _598 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _603 = _598 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _604 = _602 + _583;
      float _605 = _603 + _584;
      float4 _606 = t4.Sample(s4, float2(_604, _605));
      float4 _608 = t5.Sample(s5, float2(_604, _605));
      float _610 = _608.x * (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _611 = abs(_610);
      float _613 = _611 / (PostProcess_000.PostProcessConstant_Z_000[7].w);
      float _614 = _606.z - _587.z;
      float _615 = _613 * _614;
      float _616 = _587.x - _382;
      float _617 = _587.y - _383;
      float _618 = _587.z - _384;
      float _619 = _618 + _615;
      float _620 = _616 * _587.w;
      float _621 = _617 * _587.w;
      float _622 = _619 * _587.w;
      float _623 = _620 + _382;
      float _624 = _621 + _383;
      float _625 = _622 + _384;
      _767 = _623;
      _768 = _624;
      _769 = _625;
    } else {
      int _628 = asint((User_000.UserConstant_Z_000[7].x));
      bool _629 = ((int)_628 > (int)0);
      [branch]
      if (_629) {
        float4 _633 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _635 = abs(_633.x);
        _728 = _635;
      } else {
        float4 _639 = t2.SampleLevel(s2, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _641 = TEXCOORD.x * 2.0f;
        float _642 = TEXCOORD.y * 2.0f;
        float _643 = _641 + -1.0f;
        float _644 = _642 + -1.0f;
        float _665 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _643;
        float _666 = mad(_644, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _665);
        float _667 = mad(_639.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _666);
        float _668 = _667 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _669 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _643;
        float _670 = mad(_644, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _669);
        float _671 = mad(_639.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _670);
        float _672 = _671 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _673 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _643;
        float _674 = mad(_644, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _673);
        float _675 = mad(_639.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _674);
        float _676 = _675 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _677 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _643;
        float _678 = mad(_644, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _677);
        float _679 = mad(_639.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _678);
        float _680 = _679 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
        float _681 = _668 / _680;
        float _682 = _672 / _680;
        float _683 = _676 / _680;
        float _684 = _681 * _681;
        float _685 = _682 * _682;
        float _686 = _685 + _684;
        float _687 = _683 * _683;
        float _688 = _686 + _687;
        float _689 = sqrt(_688);
        float4 _692 = t5.Sample(s5, float2(TEXCOORD.x, TEXCOORD.y));
        float _698 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _699 = _698 + (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _700 = (PostProcess_000.PostProcessConstant_Z_000[5].x) - _698;
        float _701 = max(_689, _700);
        float _702 = min(_701, _699);
        float _704 = _689 - _702;
        float _705 = _704 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
        float _707 = _702 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _708 = _707 * _689;
        float _709 = _705 / _708;
        float _710 = min(_709, 0.0f);
        float _713 = _698 + 1.0f;
        float _714 = 1.0f / _713;
        float _715 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _710;
        float _716 = max(0.0f, _709);
        float _719 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _716;
        float _720 = _719 + _715;
        float _721 = _720 * _714;
        float _722 = min(_692.x, _721);
        float _723 = abs(_722);
        float _724 = abs(_721);
        float _725 = max(_723, _724);
        float _726 = saturate(_725);
        _728 = _726;
      }
      float _731 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _728;
      float4 _734 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _741 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _731;
      float _742 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _731;
      float _743 = _741 + TEXCOORD.x;
      float _744 = _742 + TEXCOORD.y;
      float4 _745 = t4.Sample(s4, float2(_743, _744));
      float4 _749 = t5.Sample(s5, float2(_743, _744));
      float _751 = abs(_749.x);
      float _752 = _745.z - _734.z;
      float _753 = _751 * _752;
      float _754 = _731 + -1.0f;
      float _755 = saturate(_754);
      float _756 = _734.x - _382;
      float _757 = _734.y - _383;
      float _758 = _734.z - _384;
      float _759 = _758 + _753;
      float _760 = _755 * _756;
      float _761 = _755 * _757;
      float _762 = _759 * _755;
      float _763 = _760 + _382;
      float _764 = _761 + _383;
      float _765 = _762 + _384;
      _767 = _763;
      _768 = _764;
      _769 = _765;
    }
  }
  float4 _771 = t12.SampleLevel(s1, float2(_60, _61), 0.0f);
  float4 _777 = t8.Sample(s8, float2(_62, _63));
  bool _783 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
  float _787 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _777.x;
  float _788 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _777.y;
  float _789 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _777.z;
  float _790 = _787 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _791 = _788 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _792 = _789 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  if (!_783) {
    float _794 = _790 * _771.x;
    float _795 = _791 * _771.y;
    float _796 = _792 * _771.z;
    _808 = _794;
    _809 = _795;
    _810 = _796;
  } else {
    float _798 = saturate(_790);
    float _799 = saturate(_791);
    float _800 = saturate(_792);
    float _801 = _771.x - _767;
    float _802 = _771.y - _768;
    float _803 = _771.z - _769;
    float _804 = _798 * _801;
    float _805 = _799 * _802;
    float _806 = _800 * _803;
    _808 = _804;
    _809 = _805;
    _810 = _806;
  }
  float _811 = _808 + _767;
  float _812 = _809 + _768;
  float _813 = _810 + _769;
  float4 _817 = t17.Load(int3(0, 0, 0));
  float _823 = _817.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _824 = _823 * _811;
  float _825 = _824 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _826 = _823 * _812;
  float _827 = _826 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _828 = _823 * _813;
  float _829 = _828 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _834 = _60 * 2.0f;
  float _835 = _61 * 2.0f;
  float _836 = _834 + -1.0f;
  float _837 = _835 + -1.0f;
  float _840 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _837;
  float _841 = _836 * _836;
  float _842 = _840 * _840;
  float _843 = _842 + _841;
  float _844 = sqrt(_843);
  float _846 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _844;
  float _848 = _846 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _849 = saturate(_848);
  float _851 = log2(_849);
  float _852 = _851 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _853 = ResonanceScaleVignetteMask(exp2(_852));
  float _854 = _825 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _855 = _827 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _856 = _829 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _857 = _854 - _825;
  float _858 = _855 - _827;
  float _859 = _856 - _829;
  float _860 = _853 * _857;
  float _861 = _853 * _858;
  float _862 = _853 * _859;
  float _863 = _860 + _825;
  float _864 = _861 + _827;
  float _865 = _862 + _829;
  float _868 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _869 = _868 * _863;
  float _870 = _868 * _864;
  float _871 = _868 * _865;
  float _872 = _869 + 1.0f;
  float _873 = _870 + 1.0f;
  float _874 = _871 + 1.0f;
  float _875 = log2(_872);
  float _876 = log2(_873);
  float _877 = log2(_874);
  float _880 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _881 = _880 * _875;
  float _882 = _880 * _876;
  float _883 = _880 * _877;
  float _885 = _881 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _886 = _882 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _887 = _883 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _890 = t3.Sample(s3, float3(_885, _886, _887));
  float _896 = _890.x * 13.450128555297852f;
  float _897 = _890.y * 13.450128555297852f;
  float _898 = _890.z * 13.450128555297852f;
  float _899 = exp2(_896);
  float _900 = exp2(_897);
  float _901 = exp2(_898);
  float _902 = _899 + -1.0f;
  float _903 = _900 + -1.0f;
  float _904 = _901 + -1.0f;
  float _905 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _906 = _905 * _902;
  float _907 = _905 * _903;
  float _908 = _905 * _904;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_869 * _905, _870 * _905, _871 * _905),
      float3(_906, _907, _908),
      1.f.xxx);
  _906 = resonance_scaled_lut_output.x;
  _907 = resonance_scaled_lut_output.y;
  _908 = resonance_scaled_lut_output.z;
  bool _911 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_911) {
    float _913 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _914 = _906 * _913;
    float _915 = _907 * _913;
    float _916 = _908 * _913;
    float _917 = _914 + 1.0f;
    float _918 = _915 + 1.0f;
    float _919 = _916 + 1.0f;
    float _920 = log2(_917);
    float _921 = log2(_918);
    float _922 = log2(_919);
    float _923 = _920 * 0.07434873282909393f;
    float _924 = _921 * 0.07434873282909393f;
    float _925 = _922 * 0.07434873282909393f;
    int _927 = asint((User_000.UserConstant_Z_000[3].y));
    int _928 = _927 & 1;
    bool _929 = (_928 == 0);
    if (!_929) {
      bool _946 = !(_923 <= (User_000.UserConstant_Z_000[4].x));
      if (!_946) {
        float _948 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _949 = _923 / _948;
        float _950 = _949 * (User_000.UserConstant_Z_000[4].y);
        float _951 = _949 * _949;
        float _952 = _951 * _949;
        float _953 = _952 - _949;
        float _954 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _955 = _948 * _948;
        float _956 = _955 * _954;
        float _957 = _956 * _953;
        float _958 = _957 + _950;
        _1048 = _958;
      } else {
        bool _960 = !(_923 <= (User_000.UserConstant_Z_000[4].z));
        if (!_960) {
          float _962 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _963 = max(9.999999974752427e-07f, _962);
          float _964 = _923 - (User_000.UserConstant_Z_000[4].x);
          float _965 = _964 / _963;
          float _966 = 1.0f - _965;
          float _967 = _966 * (User_000.UserConstant_Z_000[4].y);
          float _968 = _965 * (User_000.UserConstant_Z_000[4].w);
          float _969 = _967 + _968;
          float _970 = _966 * _966;
          float _971 = _970 * _966;
          float _972 = _971 - _966;
          float _973 = _972 * (User_000.UserConstant_Z_000[10].x);
          float _974 = _965 * _965;
          float _975 = _974 * _965;
          float _976 = _975 - _965;
          float _977 = _976 * (User_000.UserConstant_Z_000[10].y);
          float _978 = _973 + _977;
          float _979 = _963 * _963;
          float _980 = _979 * 0.1666666716337204f;
          float _981 = _980 * _978;
          float _982 = _969 + _981;
          _1048 = _982;
        } else {
          bool _984 = !(_923 <= (User_000.UserConstant_Z_000[9].x));
          if (!_984) {
            float _986 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _987 = max(9.999999974752427e-07f, _986);
            float _988 = _923 - (User_000.UserConstant_Z_000[4].z);
            float _989 = _988 / _987;
            float _990 = 1.0f - _989;
            float _991 = _990 * (User_000.UserConstant_Z_000[4].w);
            float _992 = _989 * (User_000.UserConstant_Z_000[9].y);
            float _993 = _991 + _992;
            float _994 = _990 * _990;
            float _995 = _994 * _990;
            float _996 = _995 - _990;
            float _997 = _996 * (User_000.UserConstant_Z_000[10].y);
            float _998 = _989 * _989;
            float _999 = _998 * _989;
            float _1000 = _999 - _989;
            float _1001 = _1000 * (User_000.UserConstant_Z_000[10].z);
            float _1002 = _997 + _1001;
            float _1003 = _987 * _987;
            float _1004 = _1003 * 0.1666666716337204f;
            float _1005 = _1004 * _1002;
            float _1006 = _993 + _1005;
            _1048 = _1006;
          } else {
            bool _1008 = !(_923 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1008) {
              float _1010 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1011 = max(9.999999974752427e-07f, _1010);
              float _1012 = _923 - (User_000.UserConstant_Z_000[9].x);
              float _1013 = _1012 / _1011;
              float _1014 = 1.0f - _1013;
              float _1015 = _1014 * (User_000.UserConstant_Z_000[9].y);
              float _1016 = _1013 * (User_000.UserConstant_Z_000[9].w);
              float _1017 = _1015 + _1016;
              float _1018 = _1014 * _1014;
              float _1019 = _1018 * _1014;
              float _1020 = _1019 - _1014;
              float _1021 = _1020 * (User_000.UserConstant_Z_000[10].z);
              float _1022 = _1013 * _1013;
              float _1023 = _1022 * _1013;
              float _1024 = _1023 - _1013;
              float _1025 = _1024 * (User_000.UserConstant_Z_000[10].w);
              float _1026 = _1021 + _1025;
              float _1027 = _1011 * _1011;
              float _1028 = _1027 * 0.1666666716337204f;
              float _1029 = _1028 * _1026;
              float _1030 = _1017 + _1029;
              _1048 = _1030;
            } else {
              float _1032 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1033 = _923 - (User_000.UserConstant_Z_000[9].z);
              float _1034 = max(9.999999974752427e-07f, _1032);
              float _1035 = _1033 / _1034;
              float _1036 = 1.0f - _1035;
              float _1037 = _1036 * (User_000.UserConstant_Z_000[9].w);
              float _1038 = _1037 + _1035;
              float _1039 = _1036 * _1036;
              float _1040 = _1039 * _1036;
              float _1041 = _1040 - _1036;
              float _1042 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1043 = _1032 * _1032;
              float _1044 = _1043 * _1042;
              float _1045 = _1044 * _1041;
              float _1046 = _1038 + _1045;
              _1048 = _1046;
            }
          }
        }
      }
      float _1049 = saturate(_1048);
      bool _1050 = !(_924 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1050) {
        float _1052 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1053 = _924 / _1052;
        float _1054 = _1053 * (User_000.UserConstant_Z_000[4].y);
        float _1055 = _1053 * _1053;
        float _1056 = _1055 * _1053;
        float _1057 = _1056 - _1053;
        float _1058 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1059 = _1052 * _1052;
        float _1060 = _1059 * _1058;
        float _1061 = _1060 * _1057;
        float _1062 = _1061 + _1054;
        _1152 = _1062;
      } else {
        bool _1064 = !(_924 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1064) {
          float _1066 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1067 = max(9.999999974752427e-07f, _1066);
          float _1068 = _924 - (User_000.UserConstant_Z_000[4].x);
          float _1069 = _1068 / _1067;
          float _1070 = 1.0f - _1069;
          float _1071 = _1070 * (User_000.UserConstant_Z_000[4].y);
          float _1072 = _1069 * (User_000.UserConstant_Z_000[4].w);
          float _1073 = _1071 + _1072;
          float _1074 = _1070 * _1070;
          float _1075 = _1074 * _1070;
          float _1076 = _1075 - _1070;
          float _1077 = _1076 * (User_000.UserConstant_Z_000[10].x);
          float _1078 = _1069 * _1069;
          float _1079 = _1078 * _1069;
          float _1080 = _1079 - _1069;
          float _1081 = _1080 * (User_000.UserConstant_Z_000[10].y);
          float _1082 = _1077 + _1081;
          float _1083 = _1067 * _1067;
          float _1084 = _1083 * 0.1666666716337204f;
          float _1085 = _1084 * _1082;
          float _1086 = _1073 + _1085;
          _1152 = _1086;
        } else {
          bool _1088 = !(_924 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1088) {
            float _1090 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1091 = max(9.999999974752427e-07f, _1090);
            float _1092 = _924 - (User_000.UserConstant_Z_000[4].z);
            float _1093 = _1092 / _1091;
            float _1094 = 1.0f - _1093;
            float _1095 = _1094 * (User_000.UserConstant_Z_000[4].w);
            float _1096 = _1093 * (User_000.UserConstant_Z_000[9].y);
            float _1097 = _1095 + _1096;
            float _1098 = _1094 * _1094;
            float _1099 = _1098 * _1094;
            float _1100 = _1099 - _1094;
            float _1101 = _1100 * (User_000.UserConstant_Z_000[10].y);
            float _1102 = _1093 * _1093;
            float _1103 = _1102 * _1093;
            float _1104 = _1103 - _1093;
            float _1105 = _1104 * (User_000.UserConstant_Z_000[10].z);
            float _1106 = _1101 + _1105;
            float _1107 = _1091 * _1091;
            float _1108 = _1107 * 0.1666666716337204f;
            float _1109 = _1108 * _1106;
            float _1110 = _1097 + _1109;
            _1152 = _1110;
          } else {
            bool _1112 = !(_924 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1112) {
              float _1114 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1115 = max(9.999999974752427e-07f, _1114);
              float _1116 = _924 - (User_000.UserConstant_Z_000[9].x);
              float _1117 = _1116 / _1115;
              float _1118 = 1.0f - _1117;
              float _1119 = _1118 * (User_000.UserConstant_Z_000[9].y);
              float _1120 = _1117 * (User_000.UserConstant_Z_000[9].w);
              float _1121 = _1119 + _1120;
              float _1122 = _1118 * _1118;
              float _1123 = _1122 * _1118;
              float _1124 = _1123 - _1118;
              float _1125 = _1124 * (User_000.UserConstant_Z_000[10].z);
              float _1126 = _1117 * _1117;
              float _1127 = _1126 * _1117;
              float _1128 = _1127 - _1117;
              float _1129 = _1128 * (User_000.UserConstant_Z_000[10].w);
              float _1130 = _1125 + _1129;
              float _1131 = _1115 * _1115;
              float _1132 = _1131 * 0.1666666716337204f;
              float _1133 = _1132 * _1130;
              float _1134 = _1121 + _1133;
              _1152 = _1134;
            } else {
              float _1136 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1137 = _924 - (User_000.UserConstant_Z_000[9].z);
              float _1138 = max(9.999999974752427e-07f, _1136);
              float _1139 = _1137 / _1138;
              float _1140 = 1.0f - _1139;
              float _1141 = _1140 * (User_000.UserConstant_Z_000[9].w);
              float _1142 = _1141 + _1139;
              float _1143 = _1140 * _1140;
              float _1144 = _1143 * _1140;
              float _1145 = _1144 - _1140;
              float _1146 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1147 = _1136 * _1136;
              float _1148 = _1147 * _1146;
              float _1149 = _1148 * _1145;
              float _1150 = _1142 + _1149;
              _1152 = _1150;
            }
          }
        }
      }
      float _1153 = saturate(_1152);
      bool _1154 = !(_925 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1154) {
        float _1156 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1157 = _925 / _1156;
        float _1158 = _1157 * (User_000.UserConstant_Z_000[4].y);
        float _1159 = _1157 * _1157;
        float _1160 = _1159 * _1157;
        float _1161 = _1160 - _1157;
        float _1162 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1163 = _1156 * _1156;
        float _1164 = _1163 * _1162;
        float _1165 = _1164 * _1161;
        float _1166 = _1165 + _1158;
        _1256 = _1166;
      } else {
        bool _1168 = !(_925 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1168) {
          float _1170 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1171 = max(9.999999974752427e-07f, _1170);
          float _1172 = _925 - (User_000.UserConstant_Z_000[4].x);
          float _1173 = _1172 / _1171;
          float _1174 = 1.0f - _1173;
          float _1175 = _1174 * (User_000.UserConstant_Z_000[4].y);
          float _1176 = _1173 * (User_000.UserConstant_Z_000[4].w);
          float _1177 = _1175 + _1176;
          float _1178 = _1174 * _1174;
          float _1179 = _1178 * _1174;
          float _1180 = _1179 - _1174;
          float _1181 = _1180 * (User_000.UserConstant_Z_000[10].x);
          float _1182 = _1173 * _1173;
          float _1183 = _1182 * _1173;
          float _1184 = _1183 - _1173;
          float _1185 = _1184 * (User_000.UserConstant_Z_000[10].y);
          float _1186 = _1181 + _1185;
          float _1187 = _1171 * _1171;
          float _1188 = _1187 * 0.1666666716337204f;
          float _1189 = _1188 * _1186;
          float _1190 = _1177 + _1189;
          _1256 = _1190;
        } else {
          bool _1192 = !(_925 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1192) {
            float _1194 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1195 = max(9.999999974752427e-07f, _1194);
            float _1196 = _925 - (User_000.UserConstant_Z_000[4].z);
            float _1197 = _1196 / _1195;
            float _1198 = 1.0f - _1197;
            float _1199 = _1198 * (User_000.UserConstant_Z_000[4].w);
            float _1200 = _1197 * (User_000.UserConstant_Z_000[9].y);
            float _1201 = _1199 + _1200;
            float _1202 = _1198 * _1198;
            float _1203 = _1202 * _1198;
            float _1204 = _1203 - _1198;
            float _1205 = _1204 * (User_000.UserConstant_Z_000[10].y);
            float _1206 = _1197 * _1197;
            float _1207 = _1206 * _1197;
            float _1208 = _1207 - _1197;
            float _1209 = _1208 * (User_000.UserConstant_Z_000[10].z);
            float _1210 = _1205 + _1209;
            float _1211 = _1195 * _1195;
            float _1212 = _1211 * 0.1666666716337204f;
            float _1213 = _1212 * _1210;
            float _1214 = _1201 + _1213;
            _1256 = _1214;
          } else {
            bool _1216 = !(_925 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1216) {
              float _1218 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1219 = max(9.999999974752427e-07f, _1218);
              float _1220 = _925 - (User_000.UserConstant_Z_000[9].x);
              float _1221 = _1220 / _1219;
              float _1222 = 1.0f - _1221;
              float _1223 = _1222 * (User_000.UserConstant_Z_000[9].y);
              float _1224 = _1221 * (User_000.UserConstant_Z_000[9].w);
              float _1225 = _1223 + _1224;
              float _1226 = _1222 * _1222;
              float _1227 = _1226 * _1222;
              float _1228 = _1227 - _1222;
              float _1229 = _1228 * (User_000.UserConstant_Z_000[10].z);
              float _1230 = _1221 * _1221;
              float _1231 = _1230 * _1221;
              float _1232 = _1231 - _1221;
              float _1233 = _1232 * (User_000.UserConstant_Z_000[10].w);
              float _1234 = _1229 + _1233;
              float _1235 = _1219 * _1219;
              float _1236 = _1235 * 0.1666666716337204f;
              float _1237 = _1236 * _1234;
              float _1238 = _1225 + _1237;
              _1256 = _1238;
            } else {
              float _1240 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1241 = _925 - (User_000.UserConstant_Z_000[9].z);
              float _1242 = max(9.999999974752427e-07f, _1240);
              float _1243 = _1241 / _1242;
              float _1244 = 1.0f - _1243;
              float _1245 = _1244 * (User_000.UserConstant_Z_000[9].w);
              float _1246 = _1245 + _1243;
              float _1247 = _1244 * _1244;
              float _1248 = _1247 * _1244;
              float _1249 = _1248 - _1244;
              float _1250 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1251 = _1240 * _1240;
              float _1252 = _1251 * _1250;
              float _1253 = _1252 * _1249;
              float _1254 = _1246 + _1253;
              _1256 = _1254;
            }
          }
        }
      }
      float _1257 = saturate(_1256);
      _1259 = _1049;
      _1260 = _1153;
      _1261 = _1257;
    } else {
      _1259 = _923;
      _1260 = _924;
      _1261 = _925;
    }
    int _1262 = _927 & 2;
    bool _1263 = (_1262 == 0);
    if (!_1263) {
      float _1265 = sqrt(_1259);
      float _1266 = sqrt(_1260);
      float _1267 = sqrt(_1261);
      float _1268 = dot(float3(_1265, _1266, _1267), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1269 = 1.0f - _1268;
      float _1270 = saturate(_1269);
      _1272 = _1270;
    } else {
      _1272 = 1.0f;
    }
    int _1273 = _927 & 8;
    bool _1274 = (_1273 == 0);
    if (_1274) {
      int _1276 = _927 & 4;
      bool _1277 = (_1276 == 0);
      if (!_1277) {
        int _1279 = _927 & 16;
        bool _1280 = (_1279 == 0);
        if (!_1280) {
          float _1284 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1285 = _1284 + 0.5f;
          bool _1286 = (_1285 < 0.5f);
          float _1287 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1288 = select(_1286, (User_000.UserConstant_Z_000[5].x), _1287);
          bool _1289 = (_1260 < _1261);
          float _1290 = select(_1289, _1261, _1260);
          float _1291 = select(_1289, _1260, _1261);
          bool _1292 = (_1259 < _1290);
          float _1293 = select(_1292, _1290, _1259);
          float _1294 = select(_1292, _1259, _1290);
          float _1295 = min(_1294, _1291);
          float _1296 = _1293 - _1295;
          float _1297 = _1293 + 1.000000013351432e-10f;
          float _1298 = _1296 / _1297;
          float _1300 = _1298 - (User_000.UserConstant_Z_000[5].y);
          float _1301 = saturate(_1300);
          float _1302 = max(_1301, 9.999999974752427e-07f);
          float _1303 = log2(_1302);
          float _1304 = _1303 * _1288;
          float _1305 = exp2(_1304);
          float _1306 = 2.0f - _1305;
          float _1308 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1309 = saturate(_1308);
          float _1310 = max(_1309, _1306);
          float _1311 = dot(float3(_1259, _1260, _1261), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1312 = _1259 - _1311;
          float _1313 = _1260 - _1311;
          float _1314 = _1261 - _1311;
          float _1315 = _1312 * _1310;
          float _1316 = _1313 * _1310;
          float _1317 = _1314 * _1310;
          float _1318 = _1311 - _1259;
          float _1319 = _1318 + _1315;
          float _1320 = _1311 - _1260;
          float _1321 = _1320 + _1316;
          float _1322 = _1311 - _1261;
          float _1323 = _1322 + _1317;
          float _1324 = _1319 * _1272;
          float _1325 = _1321 * _1272;
          float _1326 = _1323 * _1272;
          float _1327 = _1324 + _1259;
          float _1328 = _1325 + _1260;
          float _1329 = _1326 + _1261;
          _1446 = _1327;
          _1447 = _1328;
          _1448 = _1329;
        } else {
          bool _1331 = (_1272 == 0.0f);
          if (!_1331) {
            float _1335 = abs(User_000.UserConstant_Z_000[5].x);
            float _1336 = saturate(_1335);
            uint4 _1338 = 0u; t15.GetDimensions(0u, _1338.x, _1338.y, _1338.w);
            float _1341 = float((uint)_1338.y);
            int _1342 = _927 & 32;
            bool _1343 = (_1342 == 0);
            float _1344 = _1341 + -1.0f;
            if (!_1343) {
              float _1346 = 1.0f / _1344;
              uint _1347 = uint(SV_Position.x);
              uint _1348 = uint(SV_Position.y);
              int _1349 = _1347 & 63;
              int _1350 = _1348 & 63;
              float4 _1352 = t6.Load(int4(_1349, _1350, 0, 0));
              float _1355 = _1352.x + -0.5f;
              float _1356 = _1259 * 13.999999046325684f;
              float _1357 = _1260 * 13.999999046325684f;
              float _1358 = _1261 * 13.999999046325684f;
              float _1359 = saturate(_1356);
              float _1360 = saturate(_1357);
              float _1361 = saturate(_1358);
              float _1362 = _1259 + -0.9285714030265808f;
              float _1363 = _1260 + -0.9285714030265808f;
              float _1364 = _1261 + -0.9285714030265808f;
              float _1365 = _1362 * 13.999999046325684f;
              float _1366 = _1363 * 13.999999046325684f;
              float _1367 = _1364 * 13.999999046325684f;
              float _1368 = saturate(_1365);
              float _1369 = saturate(_1366);
              float _1370 = saturate(_1367);
              float _1371 = 1.0f - _1368;
              float _1372 = 1.0f - _1369;
              float _1373 = 1.0f - _1370;
              float _1374 = min(_1359, _1371);
              float _1375 = min(_1360, _1372);
              float _1376 = min(_1361, _1373);
              float _1377 = _1352.y + -0.5f;
              float _1378 = _1374 * _1377;
              float _1379 = _1375 * _1377;
              float _1380 = _1376 * _1377;
              float _1381 = _1378 + _1355;
              float _1382 = _1379 + _1355;
              float _1383 = _1380 + _1355;
              float _1384 = _1381 * _1346;
              float _1385 = _1382 * _1346;
              float _1386 = _1383 * _1346;
              float _1387 = _1384 + _1259;
              float _1388 = _1385 + _1260;
              float _1389 = _1386 + _1261;
              float _1390 = saturate(_1387);
              float _1391 = saturate(_1388);
              float _1392 = saturate(_1389);
              float _1393 = saturate(_1390);
              float _1394 = saturate(_1391);
              float _1395 = saturate(_1392);
              _1397 = _1393;
              _1398 = _1394;
              _1399 = _1395;
            } else {
              _1397 = _1259;
              _1398 = _1260;
              _1399 = _1261;
            }
            float _1400 = float((uint)_1338.x);
            float _1401 = _1344 / _1400;
            float _1402 = _1401 * _1397;
            float _1403 = 0.5f / _1400;
            float _1404 = _1402 + _1403;
            float _1405 = _1344 / _1341;
            float _1406 = _1405 * _1398;
            float _1407 = 0.5f / _1341;
            float _1408 = _1406 + _1407;
            float _1409 = _1399 * _1344;
            float _1410 = floor(_1409);
            float _1411 = frac(_1409);
            float _1412 = _1410 / _1341;
            float _1413 = _1412 + _1404;
            float _1414 = _1410 + 1.0f;
            float _1415 = _1414 / _1341;
            float _1416 = _1415 + _1404;
            float4 _1418 = t15.Sample(s1, float2(_1413, _1408));
            float4 _1422 = t15.Sample(s1, float2(_1416, _1408));
            float _1426 = _1422.x - _1418.x;
            float _1427 = _1422.y - _1418.y;
            float _1428 = _1422.z - _1418.z;
            float _1429 = _1426 * _1411;
            float _1430 = _1427 * _1411;
            float _1431 = _1428 * _1411;
            float _1432 = _1336 * _1272;
            float _1433 = _1418.x - _1259;
            float _1434 = _1433 + _1429;
            float _1435 = _1418.y - _1260;
            float _1436 = _1435 + _1430;
            float _1437 = _1418.z - _1261;
            float _1438 = _1437 + _1431;
            float _1439 = _1434 * _1432;
            float _1440 = _1436 * _1432;
            float _1441 = _1438 * _1432;
            float _1442 = _1439 + _1259;
            float _1443 = _1440 + _1260;
            float _1444 = _1441 + _1261;
            _1446 = _1442;
            _1447 = _1443;
            _1448 = _1444;
          } else {
            _1446 = _1259;
            _1447 = _1260;
            _1448 = _1261;
          }
        }
      } else {
        _1446 = _1259;
        _1447 = _1260;
        _1448 = _1261;
      }
    } else {
      _1446 = _1272;
      _1447 = _1272;
      _1448 = _1272;
    }
    float _1449 = _1446 * 13.450128555297852f;
    float _1450 = _1447 * 13.450128555297852f;
    float _1451 = _1448 * 13.450128555297852f;
    float _1452 = exp2(_1449);
    float _1453 = exp2(_1450);
    float _1454 = exp2(_1451);
    float _1455 = _1452 + -1.0f;
    float _1456 = _1453 + -1.0f;
    float _1457 = _1454 + -1.0f;
    float _1458 = _1455 * _905;
    float _1459 = _1456 * _905;
    float _1460 = _1457 * _905;
    _1462 = _1458;
    _1463 = _1459;
    _1464 = _1460;
  } else {
    _1462 = _906;
    _1463 = _907;
    _1464 = _908;
  }
  float _1469 = (User_000.UserConstant_Z_000[8].x) * _1462;
  float _1470 = (User_000.UserConstant_Z_000[8].y) * _1463;
  float _1471 = (User_000.UserConstant_Z_000[8].z) * _1464;
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3(_1469, _1470, _1471),
      SV_Position.xy);
  float _1476 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _1477 = _1476 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _1478 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _1479 = _1478 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _1482 = _1477 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _1483 = _1479 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _1486 = t9.Sample(s9, float2(_1482, _1483));
  float _1490 = dot(float3(_1469, _1470, _1471), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _1493 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _1496 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _1497 = select(_1493, _1496, 0);
  float _1498 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _1499 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _1500 = uint(_1498);
  uint _1501 = uint(_1499);
  int _1502 = _1500 & 63;
  int _1503 = _1501 & 63;
  float4 _1505 = t6.Load(int4(_1502, _1503, _1497, 0));
  bool _1507 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_1507) {
    float _1509 = _1498 * 0.015625f;
    float _1510 = _1499 * 0.015625f;
    float _1511 = float((uint)_1496);
    float _1512 = select(_1493, _1511, 0.0f);
    float4 _1514 = t6.SampleLevel(s6, float3(_1509, _1510, _1512), 0.0f);
    float _1516 = _1505.y - _1514.y;
    float _1517 = _1516 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _1518 = _1517 + _1514.y;
    _1520 = _1518;
  } else {
    _1520 = _1505.y;
  }
  float _1521 = _1486.x * -2.0f;
  float _1522 = _1521 * _1520;
  float _1523 = _1520 * 2.0f;
  float _1524 = _1523 * _1486.y;
  float _1525 = _1523 * _1486.z;
  float _1526 = _1522 + _1486.x;
  float _1527 = _1524 - _1486.y;
  float _1528 = _1525 - _1486.z;
  float _1529 = _1526 * _1486.x;
  float _1530 = _1527 * _1486.y;
  float _1531 = _1528 * _1486.z;
  float _1532 = _1490 + 1.0f;
  float _1533 = _1490 / _1532;
  float _1534 = _1533 + -9.999999747378752e-05f;
  float _1535 = _1534 * 1111.111083984375f;
  float _1536 = saturate(_1535);
  float _1537 = _1536 * 2.0f;
  float _1538 = 3.0f - _1537;
  float _1539 = _1536 * _1536;
  float _1540 = _1539 * _1538;
  bool _1542 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _1543 = float((bool)_1542);
  float _1544 = dot(float3(_1529, _1530, _1531), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1545 = _1544 - _1529;
  float _1546 = _1544 - _1530;
  float _1547 = _1544 - _1531;
  float _1548 = _1545 * _1543;
  float _1549 = _1546 * _1543;
  float _1550 = _1547 * _1543;
  float _1551 = _1548 + _1529;
  float _1552 = _1549 + _1530;
  float _1553 = _1550 + _1531;
  float _1557 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1558 = _1557 * _1533;
  float _1559 = _1558 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1560 = _1540 * _1559;
  float _1561 = _1560 * _1551;
  float _1562 = _1560 * _1552;
  float _1563 = _1560 * _1553;
  float _1564 = _1561 + _1469;
  float _1565 = _1562 + _1470;
  float _1566 = _1563 + _1471;
  float _1567 = max(0.0f, _1564);
  float _1568 = max(0.0f, _1565);
  float _1569 = max(0.0f, _1566);
  float3 resonance_film_grain_output = ResonanceSelectFilmGrainOutput(
      float3(_1567, _1568, _1569),
      resonance_perceptual_film_grain);
  _1567 = resonance_film_grain_output.x;
  _1568 = resonance_film_grain_output.y;
  _1569 = resonance_film_grain_output.z;
  float _1572 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1573 = log2(_1567);
  float _1574 = _1572 * _1573;
  float _1575 = exp2(_1574);
  float _1576 = _1575 + -1.0f;
  float _1577 = _1567 + -1.0f;
  float _1578 = _1576 / _1577;
  bool _1579 = !(_1567 == 1.0f);
  float _1580 = _1578 + -1.0f;
  float _1581 = _1580 / _1578;
  float _1582 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1583 = _1582 / _1572;
  float _1584 = select(_1579, _1581, _1583);
  float _1585 = log2(_1568);
  float _1586 = _1585 * _1572;
  float _1587 = exp2(_1586);
  float _1588 = _1587 + -1.0f;
  float _1589 = _1568 + -1.0f;
  float _1590 = _1588 / _1589;
  bool _1591 = !(_1568 == 1.0f);
  float _1592 = _1590 + -1.0f;
  float _1593 = _1592 / _1590;
  float _1594 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1595 = _1594 / _1572;
  float _1596 = select(_1591, _1593, _1595);
  float _1597 = log2(_1569);
  float _1598 = _1597 * _1572;
  float _1599 = exp2(_1598);
  float _1600 = _1599 + -1.0f;
  float _1601 = _1569 + -1.0f;
  float _1602 = _1600 / _1601;
  bool _1603 = !(_1569 == 1.0f);
  float _1604 = _1602 + -1.0f;
  float _1605 = _1604 / _1602;
  float _1606 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1607 = _1606 / _1572;
  float _1608 = select(_1603, _1605, _1607);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1567, _1568, _1569),
      float3(_1584, _1596, _1608),
      true);
  float _1609 = resonance_post_process_output.x;
  float _1610 = resonance_post_process_output.y;
  float _1611 = resonance_post_process_output.z;
  float _1612 = log2(_1609);
  float _1613 = log2(_1610);
  float _1614 = log2(_1611);
  float _1615 = _1612 * 0.4166666567325592f;
  float _1616 = _1613 * 0.4166666567325592f;
  float _1617 = _1614 * 0.4166666567325592f;
  float _1618 = exp2(_1615);
  float _1619 = exp2(_1616);
  float _1620 = exp2(_1617);
  float _1621 = _1618 * 1.0549999475479126f;
  float _1622 = _1619 * 1.0549999475479126f;
  float _1623 = _1620 * 1.0549999475479126f;
  float _1624 = _1621 + -0.054999999701976776f;
  float _1625 = _1622 + -0.054999999701976776f;
  float _1626 = _1623 + -0.054999999701976776f;
  float _1627 = _1609 * 12.920000076293945f;
  float _1628 = _1610 * 12.920000076293945f;
  float _1629 = _1611 * 12.920000076293945f;
  bool _1630 = (_1609 <= 0.0031308000907301903f);
  bool _1631 = (_1610 <= 0.0031308000907301903f);
  bool _1632 = (_1611 <= 0.0031308000907301903f);
  float _1633 = select(_1630, _1627, _1624);
  float _1634 = select(_1631, _1628, _1625);
  float _1635 = select(_1632, _1629, _1626);
  uint _1636 = uint(SV_Position.x);
  uint _1637 = uint(SV_Position.y);
  int _1638 = _1636 & 63;
  int _1639 = _1637 & 63;
  float4 _1641 = t1.Load(int4(_1638, _1639, _1496, 0));
  float _1643 = _1641.x + -0.5f;
  float _1644 = _1643 * 0.003921568859368563f;
  float _1645 = _1644 + _1633;
  float _1646 = _1644 + _1634;
  float _1647 = _1644 + _1635;
  float _1648 = saturate(_1645);
  float _1649 = saturate(_1646);
  float _1650 = saturate(_1647);
  SV_Target.x = _1648;
  SV_Target.y = _1649;
  SV_Target.z = _1650;
  SV_Target.w = _381;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}