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
  float _428;
  float _429;
  float _430;
  float _435;
  float _436;
  float _437;
  float _466;
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
  float _1091;
  float _1195;
  float _1299;
  float _1302;
  float _1303;
  float _1304;
  float _1315;
  float _1440;
  float _1441;
  float _1442;
  float _1489;
  float _1490;
  float _1491;
  float _1505;
  float _1506;
  float _1507;
  float _1563;
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
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_382, _383, _384),
      float3(_382, _383, _384),
      float2(_60, _61),
      t0,
      s1,
      _65);
  _382 = renodx_chromatic_aberration_input.x;
  _383 = renodx_chromatic_aberration_input.y;
  _384 = renodx_chromatic_aberration_input.z;
  float4 _386 = t12.SampleLevel(s1, float2(_60, _61), 0.0f);
  float4 _392 = t8.Sample(s8, float2(_62, _63));
  int _398 = asint((User_000.UserConstant_Z_000[7].z));
  bool _399 = ((int)_398 > (int)0);
  if (!_399) {
    bool _403 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _407 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _392.x;
    float _408 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _392.y;
    float _409 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _392.z;
    float _410 = _407 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _411 = _408 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _412 = _409 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_403) {
      float _414 = _410 * _386.x;
      float _415 = _411 * _386.y;
      float _416 = _412 * _386.z;
      _428 = _414;
      _429 = _415;
      _430 = _416;
    } else {
      float _418 = saturate(_410);
      float _419 = saturate(_411);
      float _420 = saturate(_412);
      float _421 = _386.x - _382;
      float _422 = _386.y - _383;
      float _423 = _386.z - _384;
      float _424 = _418 * _421;
      float _425 = _419 * _422;
      float _426 = _420 * _423;
      _428 = _424;
      _429 = _425;
      _430 = _426;
    }
    float _431 = _428 + _382;
    float _432 = _429 + _383;
    float _433 = _430 + _384;
    _435 = _431;
    _436 = _432;
    _437 = _433;
  } else {
    _435 = _382;
    _436 = _383;
    _437 = _384;
  }
  [branch]
  if (_399) {
    bool _442 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_442) {
      float _444 = _41.x + TEXCOORD.x;
      float _445 = _50 + TEXCOORD.y;
      float4 _448 = t2.SampleLevel(s2, float2(_444, _445), 0.0f);
      bool _452 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_452) {
        float4 _455 = t7.Load(int3(0, 0, 0));
        float _460 = _455.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _461 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _460;
        _466 = _461;
      } else {
        _466 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _470 = _448.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _471 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _470;
      float _473 = _466 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _474 = _473 + _466;
      float _475 = _466 - _473;
      float _476 = max(_471, _475);
      float _477 = min(_476, _474);
      float _480 = _471 - _477;
      float _481 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _480;
      float _483 = _477 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _484 = _483 * _471;
      float _485 = _481 / _484;
      float _486 = min(_485, 0.0f);
      float _488 = _473 + 1.0f;
      float _489 = 1.0f / _488;
      float _490 = _486 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _491 = max(0.0f, _485);
      float _494 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _491;
      float _495 = _494 + _490;
      float _496 = _495 * _489;
      float _497 = max(_496, -1.0f);
      float _498 = min(_497, 1.0f);
      float _499 = max(_498, -0.30000001192092896f);
      float _500 = min(_499, 1.0f);
      float _502 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _503 = _500 * _502;
      float _504 = _444 + -0.5f;
      float _505 = _445 + -0.5f;
      float _506 = _504 * _504;
      float _507 = _505 * _505;
      float _508 = _507 + _506;
      float _509 = sqrt(_508);
      float _510 = log2(_509);
      float _511 = _510 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _512 = exp2(_511);
      float _513 = _512 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _514 = dot(float2(_504, _505), float2(_504, _505));
      float _515 = rsqrt(_514);
      float _516 = _515 * _504;
      float _517 = _515 * _505;
      float _518 = abs(_503);
      float _522 = _513 * _518;
      float _523 = -0.0f - _522;
      float _524 = (User_000.UserConstant_Z_000[2].x) * _516;
      float _525 = _524 * _523;
      float _526 = (User_000.UserConstant_Z_000[2].y) * _517;
      float _527 = _526 * _523;
      float _528 = _518 * _513;
      float _529 = _524 * _528;
      float _530 = _526 * _528;
      float _531 = _525 + _444;
      float _532 = _527 + _445;
      float _533 = _529 + _444;
      float _534 = _530 + _445;
      float4 _535 = t0.SampleLevel(s1, float2(_531, _532), 0.0f);
      float4 _537 = t0.SampleLevel(s1, float2(_533, _534), 0.0f);
      float4 _539 = t2.SampleLevel(s2, float2(_531, _532), 0.0f);
      if (_452) {
        float4 _543 = t7.Load(int3(0, 0, 0));
        float _545 = _543.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _546 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _545;
        _550 = _546;
      } else {
        _550 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _551 = _539.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _552 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _551;
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
      float _575 = _574 * _502;
      float4 _576 = t2.SampleLevel(s2, float2(_533, _534), 0.0f);
      if (_452) {
        float4 _580 = t7.Load(int3(0, 0, 0));
        float _582 = _580.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _583 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _582;
        _587 = _583;
      } else {
        _587 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _588 = _576.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _589 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _588;
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
      float _612 = _611 * _502;
      float _613 = abs(_575);
      float _614 = _613 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _615 = ceil(_614);
      float _616 = saturate(_615);
      float _617 = _535.x - _435;
      float _618 = _616 * _617;
      float _619 = _618 + _435;
      float _620 = abs(_612);
      float _621 = _620 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _622 = ceil(_621);
      float _623 = saturate(_622);
      float _624 = _537.z - _437;
      float _625 = _623 * _624;
      float _626 = _625 + _437;
      _816 = _619;
      _817 = _436;
      _818 = _626;
    } else {
      _816 = _435;
      _817 = _436;
      _818 = _437;
    }
  } else {
    int _629 = asint((User_000.UserConstant_Z_000[7].y));
    bool _630 = ((int)_629 > (int)0);
    if (_630) {
      float _632 = _41.x + TEXCOORD.x;
      float _633 = _50 + TEXCOORD.y;
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
      float _665 = _636.x - _435;
      float _666 = _636.y - _436;
      float _667 = _636.z - _437;
      float _668 = _667 + _664;
      float _669 = _665 * _636.w;
      float _670 = _666 * _636.w;
      float _671 = _668 * _636.w;
      float _672 = _669 + _435;
      float _673 = _670 + _436;
      float _674 = _671 + _437;
      _816 = _672;
      _817 = _673;
      _818 = _674;
    } else {
      int _677 = asint((User_000.UserConstant_Z_000[7].x));
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
        float _714 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _692;
        float _715 = mad(_693, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _714);
        float _716 = mad(_688.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _715);
        float _717 = _716 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _718 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _692;
        float _719 = mad(_693, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _718);
        float _720 = mad(_688.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _719);
        float _721 = _720 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _722 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _692;
        float _723 = mad(_693, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _722);
        float _724 = mad(_688.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _723);
        float _725 = _724 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _726 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _692;
        float _727 = mad(_693, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _726);
        float _728 = mad(_688.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _727);
        float _729 = _728 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
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
      float _805 = _783.x - _435;
      float _806 = _783.y - _436;
      float _807 = _783.z - _437;
      float _808 = _807 + _802;
      float _809 = _804 * _805;
      float _810 = _804 * _806;
      float _811 = _808 * _804;
      float _812 = _809 + _435;
      float _813 = _810 + _436;
      float _814 = _811 + _437;
      _816 = _812;
      _817 = _813;
      _818 = _814;
    }
  }
  if (_399) {
    bool _822 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _826 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _392.x;
    float _827 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _392.y;
    float _828 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _392.z;
    float _829 = _826 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _830 = _827 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _831 = _828 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_822) {
      float _833 = _829 * _386.x;
      float _834 = _830 * _386.y;
      float _835 = _831 * _386.z;
      _847 = _833;
      _848 = _834;
      _849 = _835;
    } else {
      float _837 = saturate(_829);
      float _838 = saturate(_830);
      float _839 = saturate(_831);
      float _840 = _386.x - _816;
      float _841 = _386.y - _817;
      float _842 = _386.z - _818;
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
  float _877 = _60 * 2.0f;
  float _878 = _61 * 2.0f;
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
  float _911 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _912 = _911 * _906;
  float _913 = _911 * _907;
  float _914 = _911 * _908;
  float _915 = _912 + 1.0f;
  float _916 = _913 + 1.0f;
  float _917 = _914 + 1.0f;
  float _918 = log2(_915);
  float _919 = log2(_916);
  float _920 = log2(_917);
  float _923 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _924 = _923 * _918;
  float _925 = _923 * _919;
  float _926 = _923 * _920;
  float _928 = _924 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _929 = _925 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _930 = _926 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _933 = t3.Sample(s3, float3(_928, _929, _930));
  float _939 = _933.x * 13.450128555297852f;
  float _940 = _933.y * 13.450128555297852f;
  float _941 = _933.z * 13.450128555297852f;
  float _942 = exp2(_939);
  float _943 = exp2(_940);
  float _944 = exp2(_941);
  float _945 = _942 + -1.0f;
  float _946 = _943 + -1.0f;
  float _947 = _944 + -1.0f;
  float _948 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _949 = _948 * _945;
  float _950 = _948 * _946;
  float _951 = _948 * _947;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_912 * _948, _913 * _948, _914 * _948),
      float3(_949, _950, _951),
      1.f.xxx);
  _949 = apt_scaled_lut_output.x;
  _950 = apt_scaled_lut_output.y;
  _951 = apt_scaled_lut_output.z;
  bool _954 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !APTIsPsychoV();
  if (_954) {
    float _956 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _957 = _949 * _956;
    float _958 = _950 * _956;
    float _959 = _951 * _956;
    float _960 = _957 + 1.0f;
    float _961 = _958 + 1.0f;
    float _962 = _959 + 1.0f;
    float _963 = log2(_960);
    float _964 = log2(_961);
    float _965 = log2(_962);
    float _966 = _963 * 0.07434873282909393f;
    float _967 = _964 * 0.07434873282909393f;
    float _968 = _965 * 0.07434873282909393f;
    int _970 = asint((User_000.UserConstant_Z_000[3].y));
    int _971 = _970 & 1;
    bool _972 = (_971 == 0);
    if (!_972) {
      bool _989 = !(_966 <= (User_000.UserConstant_Z_000[4].x));
      if (!_989) {
        float _991 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _992 = _966 / _991;
        float _993 = _992 * (User_000.UserConstant_Z_000[4].y);
        float _994 = _992 * _992;
        float _995 = _994 * _992;
        float _996 = _995 - _992;
        float _997 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _998 = _991 * _991;
        float _999 = _998 * _997;
        float _1000 = _999 * _996;
        float _1001 = _1000 + _993;
        _1091 = _1001;
      } else {
        bool _1003 = !(_966 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1003) {
          float _1005 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1006 = max(9.999999974752427e-07f, _1005);
          float _1007 = _966 - (User_000.UserConstant_Z_000[4].x);
          float _1008 = _1007 / _1006;
          float _1009 = 1.0f - _1008;
          float _1010 = _1009 * (User_000.UserConstant_Z_000[4].y);
          float _1011 = _1008 * (User_000.UserConstant_Z_000[4].w);
          float _1012 = _1010 + _1011;
          float _1013 = _1009 * _1009;
          float _1014 = _1013 * _1009;
          float _1015 = _1014 - _1009;
          float _1016 = _1015 * (User_000.UserConstant_Z_000[10].x);
          float _1017 = _1008 * _1008;
          float _1018 = _1017 * _1008;
          float _1019 = _1018 - _1008;
          float _1020 = _1019 * (User_000.UserConstant_Z_000[10].y);
          float _1021 = _1016 + _1020;
          float _1022 = _1006 * _1006;
          float _1023 = _1022 * 0.1666666716337204f;
          float _1024 = _1023 * _1021;
          float _1025 = _1012 + _1024;
          _1091 = _1025;
        } else {
          bool _1027 = !(_966 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1027) {
            float _1029 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1030 = max(9.999999974752427e-07f, _1029);
            float _1031 = _966 - (User_000.UserConstant_Z_000[4].z);
            float _1032 = _1031 / _1030;
            float _1033 = 1.0f - _1032;
            float _1034 = _1033 * (User_000.UserConstant_Z_000[4].w);
            float _1035 = _1032 * (User_000.UserConstant_Z_000[9].y);
            float _1036 = _1034 + _1035;
            float _1037 = _1033 * _1033;
            float _1038 = _1037 * _1033;
            float _1039 = _1038 - _1033;
            float _1040 = _1039 * (User_000.UserConstant_Z_000[10].y);
            float _1041 = _1032 * _1032;
            float _1042 = _1041 * _1032;
            float _1043 = _1042 - _1032;
            float _1044 = _1043 * (User_000.UserConstant_Z_000[10].z);
            float _1045 = _1040 + _1044;
            float _1046 = _1030 * _1030;
            float _1047 = _1046 * 0.1666666716337204f;
            float _1048 = _1047 * _1045;
            float _1049 = _1036 + _1048;
            _1091 = _1049;
          } else {
            bool _1051 = !(_966 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1051) {
              float _1053 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1054 = max(9.999999974752427e-07f, _1053);
              float _1055 = _966 - (User_000.UserConstant_Z_000[9].x);
              float _1056 = _1055 / _1054;
              float _1057 = 1.0f - _1056;
              float _1058 = _1057 * (User_000.UserConstant_Z_000[9].y);
              float _1059 = _1056 * (User_000.UserConstant_Z_000[9].w);
              float _1060 = _1058 + _1059;
              float _1061 = _1057 * _1057;
              float _1062 = _1061 * _1057;
              float _1063 = _1062 - _1057;
              float _1064 = _1063 * (User_000.UserConstant_Z_000[10].z);
              float _1065 = _1056 * _1056;
              float _1066 = _1065 * _1056;
              float _1067 = _1066 - _1056;
              float _1068 = _1067 * (User_000.UserConstant_Z_000[10].w);
              float _1069 = _1064 + _1068;
              float _1070 = _1054 * _1054;
              float _1071 = _1070 * 0.1666666716337204f;
              float _1072 = _1071 * _1069;
              float _1073 = _1060 + _1072;
              _1091 = _1073;
            } else {
              float _1075 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1076 = _966 - (User_000.UserConstant_Z_000[9].z);
              float _1077 = max(9.999999974752427e-07f, _1075);
              float _1078 = _1076 / _1077;
              float _1079 = 1.0f - _1078;
              float _1080 = _1079 * (User_000.UserConstant_Z_000[9].w);
              float _1081 = _1080 + _1078;
              float _1082 = _1079 * _1079;
              float _1083 = _1082 * _1079;
              float _1084 = _1083 - _1079;
              float _1085 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1086 = _1075 * _1075;
              float _1087 = _1086 * _1085;
              float _1088 = _1087 * _1084;
              float _1089 = _1081 + _1088;
              _1091 = _1089;
            }
          }
        }
      }
      float _1092 = saturate(_1091);
      bool _1093 = !(_967 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1093) {
        float _1095 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1096 = _967 / _1095;
        float _1097 = _1096 * (User_000.UserConstant_Z_000[4].y);
        float _1098 = _1096 * _1096;
        float _1099 = _1098 * _1096;
        float _1100 = _1099 - _1096;
        float _1101 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1102 = _1095 * _1095;
        float _1103 = _1102 * _1101;
        float _1104 = _1103 * _1100;
        float _1105 = _1104 + _1097;
        _1195 = _1105;
      } else {
        bool _1107 = !(_967 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1107) {
          float _1109 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1110 = max(9.999999974752427e-07f, _1109);
          float _1111 = _967 - (User_000.UserConstant_Z_000[4].x);
          float _1112 = _1111 / _1110;
          float _1113 = 1.0f - _1112;
          float _1114 = _1113 * (User_000.UserConstant_Z_000[4].y);
          float _1115 = _1112 * (User_000.UserConstant_Z_000[4].w);
          float _1116 = _1114 + _1115;
          float _1117 = _1113 * _1113;
          float _1118 = _1117 * _1113;
          float _1119 = _1118 - _1113;
          float _1120 = _1119 * (User_000.UserConstant_Z_000[10].x);
          float _1121 = _1112 * _1112;
          float _1122 = _1121 * _1112;
          float _1123 = _1122 - _1112;
          float _1124 = _1123 * (User_000.UserConstant_Z_000[10].y);
          float _1125 = _1120 + _1124;
          float _1126 = _1110 * _1110;
          float _1127 = _1126 * 0.1666666716337204f;
          float _1128 = _1127 * _1125;
          float _1129 = _1116 + _1128;
          _1195 = _1129;
        } else {
          bool _1131 = !(_967 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1131) {
            float _1133 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1134 = max(9.999999974752427e-07f, _1133);
            float _1135 = _967 - (User_000.UserConstant_Z_000[4].z);
            float _1136 = _1135 / _1134;
            float _1137 = 1.0f - _1136;
            float _1138 = _1137 * (User_000.UserConstant_Z_000[4].w);
            float _1139 = _1136 * (User_000.UserConstant_Z_000[9].y);
            float _1140 = _1138 + _1139;
            float _1141 = _1137 * _1137;
            float _1142 = _1141 * _1137;
            float _1143 = _1142 - _1137;
            float _1144 = _1143 * (User_000.UserConstant_Z_000[10].y);
            float _1145 = _1136 * _1136;
            float _1146 = _1145 * _1136;
            float _1147 = _1146 - _1136;
            float _1148 = _1147 * (User_000.UserConstant_Z_000[10].z);
            float _1149 = _1144 + _1148;
            float _1150 = _1134 * _1134;
            float _1151 = _1150 * 0.1666666716337204f;
            float _1152 = _1151 * _1149;
            float _1153 = _1140 + _1152;
            _1195 = _1153;
          } else {
            bool _1155 = !(_967 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1155) {
              float _1157 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1158 = max(9.999999974752427e-07f, _1157);
              float _1159 = _967 - (User_000.UserConstant_Z_000[9].x);
              float _1160 = _1159 / _1158;
              float _1161 = 1.0f - _1160;
              float _1162 = _1161 * (User_000.UserConstant_Z_000[9].y);
              float _1163 = _1160 * (User_000.UserConstant_Z_000[9].w);
              float _1164 = _1162 + _1163;
              float _1165 = _1161 * _1161;
              float _1166 = _1165 * _1161;
              float _1167 = _1166 - _1161;
              float _1168 = _1167 * (User_000.UserConstant_Z_000[10].z);
              float _1169 = _1160 * _1160;
              float _1170 = _1169 * _1160;
              float _1171 = _1170 - _1160;
              float _1172 = _1171 * (User_000.UserConstant_Z_000[10].w);
              float _1173 = _1168 + _1172;
              float _1174 = _1158 * _1158;
              float _1175 = _1174 * 0.1666666716337204f;
              float _1176 = _1175 * _1173;
              float _1177 = _1164 + _1176;
              _1195 = _1177;
            } else {
              float _1179 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1180 = _967 - (User_000.UserConstant_Z_000[9].z);
              float _1181 = max(9.999999974752427e-07f, _1179);
              float _1182 = _1180 / _1181;
              float _1183 = 1.0f - _1182;
              float _1184 = _1183 * (User_000.UserConstant_Z_000[9].w);
              float _1185 = _1184 + _1182;
              float _1186 = _1183 * _1183;
              float _1187 = _1186 * _1183;
              float _1188 = _1187 - _1183;
              float _1189 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1190 = _1179 * _1179;
              float _1191 = _1190 * _1189;
              float _1192 = _1191 * _1188;
              float _1193 = _1185 + _1192;
              _1195 = _1193;
            }
          }
        }
      }
      float _1196 = saturate(_1195);
      bool _1197 = !(_968 <= (User_000.UserConstant_Z_000[4].x));
      if (!_1197) {
        float _1199 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _1200 = _968 / _1199;
        float _1201 = _1200 * (User_000.UserConstant_Z_000[4].y);
        float _1202 = _1200 * _1200;
        float _1203 = _1202 * _1200;
        float _1204 = _1203 - _1200;
        float _1205 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _1206 = _1199 * _1199;
        float _1207 = _1206 * _1205;
        float _1208 = _1207 * _1204;
        float _1209 = _1208 + _1201;
        _1299 = _1209;
      } else {
        bool _1211 = !(_968 <= (User_000.UserConstant_Z_000[4].z));
        if (!_1211) {
          float _1213 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _1214 = max(9.999999974752427e-07f, _1213);
          float _1215 = _968 - (User_000.UserConstant_Z_000[4].x);
          float _1216 = _1215 / _1214;
          float _1217 = 1.0f - _1216;
          float _1218 = _1217 * (User_000.UserConstant_Z_000[4].y);
          float _1219 = _1216 * (User_000.UserConstant_Z_000[4].w);
          float _1220 = _1218 + _1219;
          float _1221 = _1217 * _1217;
          float _1222 = _1221 * _1217;
          float _1223 = _1222 - _1217;
          float _1224 = _1223 * (User_000.UserConstant_Z_000[10].x);
          float _1225 = _1216 * _1216;
          float _1226 = _1225 * _1216;
          float _1227 = _1226 - _1216;
          float _1228 = _1227 * (User_000.UserConstant_Z_000[10].y);
          float _1229 = _1224 + _1228;
          float _1230 = _1214 * _1214;
          float _1231 = _1230 * 0.1666666716337204f;
          float _1232 = _1231 * _1229;
          float _1233 = _1220 + _1232;
          _1299 = _1233;
        } else {
          bool _1235 = !(_968 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1235) {
            float _1237 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1238 = max(9.999999974752427e-07f, _1237);
            float _1239 = _968 - (User_000.UserConstant_Z_000[4].z);
            float _1240 = _1239 / _1238;
            float _1241 = 1.0f - _1240;
            float _1242 = _1241 * (User_000.UserConstant_Z_000[4].w);
            float _1243 = _1240 * (User_000.UserConstant_Z_000[9].y);
            float _1244 = _1242 + _1243;
            float _1245 = _1241 * _1241;
            float _1246 = _1245 * _1241;
            float _1247 = _1246 - _1241;
            float _1248 = _1247 * (User_000.UserConstant_Z_000[10].y);
            float _1249 = _1240 * _1240;
            float _1250 = _1249 * _1240;
            float _1251 = _1250 - _1240;
            float _1252 = _1251 * (User_000.UserConstant_Z_000[10].z);
            float _1253 = _1248 + _1252;
            float _1254 = _1238 * _1238;
            float _1255 = _1254 * 0.1666666716337204f;
            float _1256 = _1255 * _1253;
            float _1257 = _1244 + _1256;
            _1299 = _1257;
          } else {
            bool _1259 = !(_968 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1259) {
              float _1261 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1262 = max(9.999999974752427e-07f, _1261);
              float _1263 = _968 - (User_000.UserConstant_Z_000[9].x);
              float _1264 = _1263 / _1262;
              float _1265 = 1.0f - _1264;
              float _1266 = _1265 * (User_000.UserConstant_Z_000[9].y);
              float _1267 = _1264 * (User_000.UserConstant_Z_000[9].w);
              float _1268 = _1266 + _1267;
              float _1269 = _1265 * _1265;
              float _1270 = _1269 * _1265;
              float _1271 = _1270 - _1265;
              float _1272 = _1271 * (User_000.UserConstant_Z_000[10].z);
              float _1273 = _1264 * _1264;
              float _1274 = _1273 * _1264;
              float _1275 = _1274 - _1264;
              float _1276 = _1275 * (User_000.UserConstant_Z_000[10].w);
              float _1277 = _1272 + _1276;
              float _1278 = _1262 * _1262;
              float _1279 = _1278 * 0.1666666716337204f;
              float _1280 = _1279 * _1277;
              float _1281 = _1268 + _1280;
              _1299 = _1281;
            } else {
              float _1283 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1284 = _968 - (User_000.UserConstant_Z_000[9].z);
              float _1285 = max(9.999999974752427e-07f, _1283);
              float _1286 = _1284 / _1285;
              float _1287 = 1.0f - _1286;
              float _1288 = _1287 * (User_000.UserConstant_Z_000[9].w);
              float _1289 = _1288 + _1286;
              float _1290 = _1287 * _1287;
              float _1291 = _1290 * _1287;
              float _1292 = _1291 - _1287;
              float _1293 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1294 = _1283 * _1283;
              float _1295 = _1294 * _1293;
              float _1296 = _1295 * _1292;
              float _1297 = _1289 + _1296;
              _1299 = _1297;
            }
          }
        }
      }
      float _1300 = saturate(_1299);
      _1302 = _1092;
      _1303 = _1196;
      _1304 = _1300;
    } else {
      _1302 = _966;
      _1303 = _967;
      _1304 = _968;
    }
    int _1305 = _970 & 2;
    bool _1306 = (_1305 == 0);
    if (!_1306) {
      float _1308 = sqrt(_1302);
      float _1309 = sqrt(_1303);
      float _1310 = sqrt(_1304);
      float _1311 = dot(float3(_1308, _1309, _1310), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1312 = 1.0f - _1311;
      float _1313 = saturate(_1312);
      _1315 = _1313;
    } else {
      _1315 = 1.0f;
    }
    int _1316 = _970 & 8;
    bool _1317 = (_1316 == 0);
    if (_1317) {
      int _1319 = _970 & 4;
      bool _1320 = (_1319 == 0);
      if (!_1320) {
        int _1322 = _970 & 16;
        bool _1323 = (_1322 == 0);
        if (!_1323) {
          float _1327 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1328 = _1327 + 0.5f;
          bool _1329 = (_1328 < 0.5f);
          float _1330 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1331 = select(_1329, (User_000.UserConstant_Z_000[5].x), _1330);
          bool _1332 = (_1303 < _1304);
          float _1333 = select(_1332, _1304, _1303);
          float _1334 = select(_1332, _1303, _1304);
          bool _1335 = (_1302 < _1333);
          float _1336 = select(_1335, _1333, _1302);
          float _1337 = select(_1335, _1302, _1333);
          float _1338 = min(_1337, _1334);
          float _1339 = _1336 - _1338;
          float _1340 = _1336 + 1.000000013351432e-10f;
          float _1341 = _1339 / _1340;
          float _1343 = _1341 - (User_000.UserConstant_Z_000[5].y);
          float _1344 = saturate(_1343);
          float _1345 = max(_1344, 9.999999974752427e-07f);
          float _1346 = log2(_1345);
          float _1347 = _1346 * _1331;
          float _1348 = exp2(_1347);
          float _1349 = 2.0f - _1348;
          float _1351 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1352 = saturate(_1351);
          float _1353 = max(_1352, _1349);
          float _1354 = dot(float3(_1302, _1303, _1304), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1355 = _1302 - _1354;
          float _1356 = _1303 - _1354;
          float _1357 = _1304 - _1354;
          float _1358 = _1355 * _1353;
          float _1359 = _1356 * _1353;
          float _1360 = _1357 * _1353;
          float _1361 = _1354 - _1302;
          float _1362 = _1361 + _1358;
          float _1363 = _1354 - _1303;
          float _1364 = _1363 + _1359;
          float _1365 = _1354 - _1304;
          float _1366 = _1365 + _1360;
          float _1367 = _1362 * _1315;
          float _1368 = _1364 * _1315;
          float _1369 = _1366 * _1315;
          float _1370 = _1367 + _1302;
          float _1371 = _1368 + _1303;
          float _1372 = _1369 + _1304;
          _1489 = _1370;
          _1490 = _1371;
          _1491 = _1372;
        } else {
          bool _1374 = (_1315 == 0.0f);
          if (!_1374) {
            float _1378 = abs(User_000.UserConstant_Z_000[5].x);
            float _1379 = saturate(_1378);
            uint4 _1381 = 0u; t15.GetDimensions(0u, _1381.x, _1381.y, _1381.w);
            float _1384 = float((uint)_1381.y);
            int _1385 = _970 & 32;
            bool _1386 = (_1385 == 0);
            float _1387 = _1384 + -1.0f;
            if (!_1386) {
              float _1389 = 1.0f / _1387;
              uint _1390 = uint(SV_Position.x);
              uint _1391 = uint(SV_Position.y);
              int _1392 = _1390 & 63;
              int _1393 = _1391 & 63;
              float4 _1395 = t6.Load(int4(_1392, _1393, 0, 0));
              float _1398 = _1395.x + -0.5f;
              float _1399 = _1302 * 13.999999046325684f;
              float _1400 = _1303 * 13.999999046325684f;
              float _1401 = _1304 * 13.999999046325684f;
              float _1402 = saturate(_1399);
              float _1403 = saturate(_1400);
              float _1404 = saturate(_1401);
              float _1405 = _1302 + -0.9285714030265808f;
              float _1406 = _1303 + -0.9285714030265808f;
              float _1407 = _1304 + -0.9285714030265808f;
              float _1408 = _1405 * 13.999999046325684f;
              float _1409 = _1406 * 13.999999046325684f;
              float _1410 = _1407 * 13.999999046325684f;
              float _1411 = saturate(_1408);
              float _1412 = saturate(_1409);
              float _1413 = saturate(_1410);
              float _1414 = 1.0f - _1411;
              float _1415 = 1.0f - _1412;
              float _1416 = 1.0f - _1413;
              float _1417 = min(_1402, _1414);
              float _1418 = min(_1403, _1415);
              float _1419 = min(_1404, _1416);
              float _1420 = _1395.y + -0.5f;
              float _1421 = _1417 * _1420;
              float _1422 = _1418 * _1420;
              float _1423 = _1419 * _1420;
              float _1424 = _1421 + _1398;
              float _1425 = _1422 + _1398;
              float _1426 = _1423 + _1398;
              float _1427 = _1424 * _1389;
              float _1428 = _1425 * _1389;
              float _1429 = _1426 * _1389;
              float _1430 = _1427 + _1302;
              float _1431 = _1428 + _1303;
              float _1432 = _1429 + _1304;
              float _1433 = saturate(_1430);
              float _1434 = saturate(_1431);
              float _1435 = saturate(_1432);
              float _1436 = saturate(_1433);
              float _1437 = saturate(_1434);
              float _1438 = saturate(_1435);
              _1440 = _1436;
              _1441 = _1437;
              _1442 = _1438;
            } else {
              _1440 = _1302;
              _1441 = _1303;
              _1442 = _1304;
            }
            float _1443 = float((uint)_1381.x);
            float _1444 = _1387 / _1443;
            float _1445 = _1444 * _1440;
            float _1446 = 0.5f / _1443;
            float _1447 = _1445 + _1446;
            float _1448 = _1387 / _1384;
            float _1449 = _1448 * _1441;
            float _1450 = 0.5f / _1384;
            float _1451 = _1449 + _1450;
            float _1452 = _1442 * _1387;
            float _1453 = floor(_1452);
            float _1454 = frac(_1452);
            float _1455 = _1453 / _1384;
            float _1456 = _1455 + _1447;
            float _1457 = _1453 + 1.0f;
            float _1458 = _1457 / _1384;
            float _1459 = _1458 + _1447;
            float4 _1461 = t15.Sample(s1, float2(_1456, _1451));
            float4 _1465 = t15.Sample(s1, float2(_1459, _1451));
            float _1469 = _1465.x - _1461.x;
            float _1470 = _1465.y - _1461.y;
            float _1471 = _1465.z - _1461.z;
            float _1472 = _1469 * _1454;
            float _1473 = _1470 * _1454;
            float _1474 = _1471 * _1454;
            float _1475 = _1379 * _1315;
            float _1476 = _1461.x - _1302;
            float _1477 = _1476 + _1472;
            float _1478 = _1461.y - _1303;
            float _1479 = _1478 + _1473;
            float _1480 = _1461.z - _1304;
            float _1481 = _1480 + _1474;
            float _1482 = _1477 * _1475;
            float _1483 = _1479 * _1475;
            float _1484 = _1481 * _1475;
            float _1485 = _1482 + _1302;
            float _1486 = _1483 + _1303;
            float _1487 = _1484 + _1304;
            _1489 = _1485;
            _1490 = _1486;
            _1491 = _1487;
          } else {
            _1489 = _1302;
            _1490 = _1303;
            _1491 = _1304;
          }
        }
      } else {
        _1489 = _1302;
        _1490 = _1303;
        _1491 = _1304;
      }
    } else {
      _1489 = _1315;
      _1490 = _1315;
      _1491 = _1315;
    }
    float _1492 = _1489 * 13.450128555297852f;
    float _1493 = _1490 * 13.450128555297852f;
    float _1494 = _1491 * 13.450128555297852f;
    float _1495 = exp2(_1492);
    float _1496 = exp2(_1493);
    float _1497 = exp2(_1494);
    float _1498 = _1495 + -1.0f;
    float _1499 = _1496 + -1.0f;
    float _1500 = _1497 + -1.0f;
    float _1501 = _1498 * _948;
    float _1502 = _1499 * _948;
    float _1503 = _1500 * _948;
    _1505 = _1501;
    _1506 = _1502;
    _1507 = _1503;
  } else {
    _1505 = _949;
    _1506 = _950;
    _1507 = _951;
  }
  float _1512 = (User_000.UserConstant_Z_000[8].x) * _1505;
  float _1513 = (User_000.UserConstant_Z_000[8].y) * _1506;
  float _1514 = (User_000.UserConstant_Z_000[8].z) * _1507;
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3(_1512, _1513, _1514),
      SV_Position.xy);
  float _1519 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _1520 = _1519 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _1521 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _1522 = _1521 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _1525 = _1520 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _1526 = _1522 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _1529 = t9.Sample(s9, float2(_1525, _1526));
  float _1533 = dot(float3(_1512, _1513, _1514), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _1536 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _1539 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _1540 = select(_1536, _1539, 0);
  float _1541 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _1542 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _1543 = uint(_1541);
  uint _1544 = uint(_1542);
  int _1545 = _1543 & 63;
  int _1546 = _1544 & 63;
  float4 _1548 = t6.Load(int4(_1545, _1546, _1540, 0));
  bool _1550 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_1550) {
    float _1552 = _1541 * 0.015625f;
    float _1553 = _1542 * 0.015625f;
    float _1554 = float((uint)_1539);
    float _1555 = select(_1536, _1554, 0.0f);
    float4 _1557 = t6.SampleLevel(s6, float3(_1552, _1553, _1555), 0.0f);
    float _1559 = _1548.y - _1557.y;
    float _1560 = _1559 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _1561 = _1560 + _1557.y;
    _1563 = _1561;
  } else {
    _1563 = _1548.y;
  }
  float _1564 = _1529.x * -2.0f;
  float _1565 = _1564 * _1563;
  float _1566 = _1563 * 2.0f;
  float _1567 = _1566 * _1529.y;
  float _1568 = _1566 * _1529.z;
  float _1569 = _1565 + _1529.x;
  float _1570 = _1567 - _1529.y;
  float _1571 = _1568 - _1529.z;
  float _1572 = _1569 * _1529.x;
  float _1573 = _1570 * _1529.y;
  float _1574 = _1571 * _1529.z;
  float _1575 = _1533 + 1.0f;
  float _1576 = _1533 / _1575;
  float _1577 = _1576 + -9.999999747378752e-05f;
  float _1578 = _1577 * 1111.111083984375f;
  float _1579 = saturate(_1578);
  float _1580 = _1579 * 2.0f;
  float _1581 = 3.0f - _1580;
  float _1582 = _1579 * _1579;
  float _1583 = _1582 * _1581;
  bool _1585 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _1586 = float((bool)_1585);
  float _1587 = dot(float3(_1572, _1573, _1574), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1588 = _1587 - _1572;
  float _1589 = _1587 - _1573;
  float _1590 = _1587 - _1574;
  float _1591 = _1588 * _1586;
  float _1592 = _1589 * _1586;
  float _1593 = _1590 * _1586;
  float _1594 = _1591 + _1572;
  float _1595 = _1592 + _1573;
  float _1596 = _1593 + _1574;
  float _1600 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1601 = _1600 * _1576;
  float _1602 = _1601 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1603 = _1583 * _1602;
  float _1604 = _1603 * _1594;
  float _1605 = _1603 * _1595;
  float _1606 = _1603 * _1596;
  float _1607 = _1604 + _1512;
  float _1608 = _1605 + _1513;
  float _1609 = _1606 + _1514;
  float _1610 = max(0.0f, _1607);
  float _1611 = max(0.0f, _1608);
  float _1612 = max(0.0f, _1609);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_1610, _1611, _1612),
      apt_perceptual_film_grain);
  _1610 = apt_film_grain_output.x;
  _1611 = apt_film_grain_output.y;
  _1612 = apt_film_grain_output.z;
  float _1615 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1616 = log2(_1610);
  float _1617 = _1615 * _1616;
  float _1618 = exp2(_1617);
  float _1619 = _1618 + -1.0f;
  float _1620 = _1610 + -1.0f;
  float _1621 = _1619 / _1620;
  bool _1622 = !(_1610 == 1.0f);
  float _1623 = _1621 + -1.0f;
  float _1624 = _1623 / _1621;
  float _1625 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1626 = _1625 / _1615;
  float _1627 = select(_1622, _1624, _1626);
  float _1628 = log2(_1611);
  float _1629 = _1628 * _1615;
  float _1630 = exp2(_1629);
  float _1631 = _1630 + -1.0f;
  float _1632 = _1611 + -1.0f;
  float _1633 = _1631 / _1632;
  bool _1634 = !(_1611 == 1.0f);
  float _1635 = _1633 + -1.0f;
  float _1636 = _1635 / _1633;
  float _1637 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1638 = _1637 / _1615;
  float _1639 = select(_1634, _1636, _1638);
  float _1640 = log2(_1612);
  float _1641 = _1640 * _1615;
  float _1642 = exp2(_1641);
  float _1643 = _1642 + -1.0f;
  float _1644 = _1612 + -1.0f;
  float _1645 = _1643 / _1644;
  bool _1646 = !(_1612 == 1.0f);
  float _1647 = _1645 + -1.0f;
  float _1648 = _1647 / _1645;
  float _1649 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1650 = _1649 / _1615;
  float _1651 = select(_1646, _1648, _1650);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1610, _1611, _1612),
      float3(_1627, _1639, _1651),
      true);
  float _1652 = apt_post_process_output.x;
  float _1653 = apt_post_process_output.y;
  float _1654 = apt_post_process_output.z;
  float _1655 = log2(_1652);
  float _1656 = log2(_1653);
  float _1657 = log2(_1654);
  float _1658 = _1655 * 0.4166666567325592f;
  float _1659 = _1656 * 0.4166666567325592f;
  float _1660 = _1657 * 0.4166666567325592f;
  float _1661 = exp2(_1658);
  float _1662 = exp2(_1659);
  float _1663 = exp2(_1660);
  float _1664 = _1661 * 1.0549999475479126f;
  float _1665 = _1662 * 1.0549999475479126f;
  float _1666 = _1663 * 1.0549999475479126f;
  float _1667 = _1664 + -0.054999999701976776f;
  float _1668 = _1665 + -0.054999999701976776f;
  float _1669 = _1666 + -0.054999999701976776f;
  float _1670 = _1652 * 12.920000076293945f;
  float _1671 = _1653 * 12.920000076293945f;
  float _1672 = _1654 * 12.920000076293945f;
  bool _1673 = (_1652 <= 0.0031308000907301903f);
  bool _1674 = (_1653 <= 0.0031308000907301903f);
  bool _1675 = (_1654 <= 0.0031308000907301903f);
  float _1676 = select(_1673, _1670, _1667);
  float _1677 = select(_1674, _1671, _1668);
  float _1678 = select(_1675, _1672, _1669);
  uint _1679 = uint(SV_Position.x);
  uint _1680 = uint(SV_Position.y);
  int _1681 = _1679 & 63;
  int _1682 = _1680 & 63;
  float4 _1684 = t1.Load(int4(_1681, _1682, _1539, 0));
  float _1686 = _1684.x + -0.5f;
  float _1687 = _1686 * 0.003921568859368563f;
  float _1688 = _1687 + _1676;
  float _1689 = _1687 + _1677;
  float _1690 = _1687 + _1678;
  float _1691 = saturate(_1688);
  float _1692 = saturate(_1689);
  float _1693 = saturate(_1690);
  SV_Target.x = _1691;
  SV_Target.y = _1692;
  SV_Target.z = _1693;
  SV_Target.w = _381;
  return SV_Target;
}
