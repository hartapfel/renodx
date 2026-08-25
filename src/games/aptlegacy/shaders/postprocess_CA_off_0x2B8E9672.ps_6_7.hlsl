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

SamplerState s0 : register(s0);

SamplerState s2 : register(s2);

SamplerState s3 : register(s3);

SamplerState s4 : register(s4);

SamplerState s5 : register(s5);

SamplerState s7 : register(s7);

SamplerState s8 : register(s8);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _37 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _43 = t16.Sample(s1, float2(TEXCOORD.z, TEXCOORD.w));
  float _45 = _43.y * 0.10000000149011612f;
  float _46 = _45 + _37.y;
  float _47 = _43.y * 0.5f;
  float _48 = _47 + _37.z;
  float _49 = exp2(_48);
  float _50 = _49 + -1.0f;
  float _53 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _50;
  float _54 = _53 + 1.0f;
  float _55 = log2(_54);
  float _56 = _37.x + TEXCOORD.z;
  float _57 = _46 + TEXCOORD.w;
  float _58 = _37.x + TEXCOORD.x;
  float _59 = _46 + TEXCOORD.y;
  float _60 = _55 + 1.0f;
  float _61 = log2(_60);
  float4 _64 = t0.SampleLevel(s1, float2(_56, _57), _61);
  bool _69 = (_61 > 0.0f);
  float _374;
  float _375;
  float _376;
  float _377;
  float _424;
  float _425;
  float _426;
  float _431;
  float _432;
  float _433;
  float _462;
  float _547;
  float _584;
  float _774;
  float _813;
  float _814;
  float _815;
  float _844;
  float _845;
  float _846;
  float _851;
  float _852;
  float _853;
  float _973;
  float _982;
  float _991;
  float _1039;
  float _1040;
  float _1041;
  [branch]
  if (_69) {
    float _71 = floor(_61);
    int _72 = int(_71);
    uint2 _73; t0.GetDimensions(_73.x, _73.y);
    int _76 = _72 & 31;
    int _77 = (uint)(_73.x) >> _76;
    float _78 = float((uint)_77);
    int _79 = (uint)(_73.y) >> _76;
    float _80 = float((uint)_79);
    float _81 = 1.0f / _78;
    float _82 = 1.0f / _80;
    float _83 = _78 * _56;
    float _84 = _80 * _57;
    float _85 = _83 + -0.5f;
    float _86 = _84 + -0.5f;
    float _87 = frac(_85);
    float _88 = frac(_86);
    float _89 = floor(_85);
    float _90 = floor(_86);
    float _91 = 1.0f - _87;
    float _92 = 2.0f - _87;
    float _93 = 3.0f - _87;
    float _94 = _91 * _91;
    float _95 = _92 * _92;
    float _96 = _93 * _93;
    float _97 = _94 * _91;
    float _98 = _95 * _92;
    float _99 = _96 * _93;
    float _100 = _97 * 4.0f;
    float _101 = _98 - _100;
    float _102 = _98 * 4.0f;
    float _103 = _97 * 6.0f;
    float _104 = 6.0f - _97;
    float _105 = _104 - _101;
    float _106 = _102 - _99;
    float _107 = _106 - _103;
    float _108 = _107 + _105;
    float _109 = _101 * 0.1666666716337204f;
    float _110 = _108 * 0.1666666716337204f;
    float _111 = 1.0f - _88;
    float _112 = 2.0f - _88;
    float _113 = 3.0f - _88;
    float _114 = _111 * _111;
    float _115 = _112 * _112;
    float _116 = _113 * _113;
    float _117 = _114 * _111;
    float _118 = _115 * _112;
    float _119 = _116 * _113;
    float _120 = _117 * 4.0f;
    float _121 = _118 - _120;
    float _122 = _118 * 4.0f;
    float _123 = _117 * 6.0f;
    float _124 = 6.0f - _117;
    float _125 = _124 - _121;
    float _126 = _122 - _119;
    float _127 = _126 - _123;
    float _128 = _127 + _125;
    float _129 = _121 * 0.1666666716337204f;
    float _130 = _128 * 0.1666666716337204f;
    float _131 = _89 + -0.5f;
    float _132 = _89 + 1.5f;
    float _133 = _90 + -0.5f;
    float _134 = _90 + 1.5f;
    float _135 = _101 + _97;
    float _136 = _135 * 0.1666666716337204f;
    float _137 = _105 * 0.1666666716337204f;
    float _138 = _121 + _117;
    float _139 = _138 * 0.1666666716337204f;
    float _140 = _125 * 0.1666666716337204f;
    float _141 = _109 / _136;
    float _142 = _110 / _137;
    float _143 = _129 / _139;
    float _144 = _130 / _140;
    float _145 = _131 + _141;
    float _146 = _132 + _142;
    float _147 = _133 + _143;
    float _148 = _134 + _144;
    float _149 = _145 * _81;
    float _150 = _146 * _81;
    float _151 = _147 * _82;
    float _152 = _148 * _82;
    float _153 = float((int)(_72));
    float4 _155 = t0.SampleLevel(s0, float2(_149, _151), _153);
    float4 _160 = t0.SampleLevel(s0, float2(_150, _151), _153);
    float4 _165 = t0.SampleLevel(s0, float2(_149, _152), _153);
    float4 _170 = t0.SampleLevel(s0, float2(_150, _152), _153);
    float _175 = _155.x - _160.x;
    float _176 = _155.y - _160.y;
    float _177 = _155.z - _160.z;
    float _178 = _155.w - _160.w;
    float _179 = _175 * _136;
    float _180 = _176 * _136;
    float _181 = _177 * _136;
    float _182 = _178 * _136;
    float _183 = _179 + _160.x;
    float _184 = _180 + _160.y;
    float _185 = _181 + _160.z;
    float _186 = _182 + _160.w;
    float _187 = _165.x - _170.x;
    float _188 = _165.y - _170.y;
    float _189 = _165.z - _170.z;
    float _190 = _165.w - _170.w;
    float _191 = _187 * _136;
    float _192 = _188 * _136;
    float _193 = _189 * _136;
    float _194 = _190 * _136;
    float _195 = _191 + _170.x;
    float _196 = _192 + _170.y;
    float _197 = _193 + _170.z;
    float _198 = _194 + _170.w;
    float _199 = _183 - _195;
    float _200 = _184 - _196;
    float _201 = _185 - _197;
    float _202 = _186 - _198;
    float _203 = _199 * _139;
    float _204 = _200 * _139;
    float _205 = _201 * _139;
    float _206 = _202 * _139;
    float _207 = _203 + _195;
    float _208 = _204 + _196;
    float _209 = _205 + _197;
    float _210 = _206 + _198;
    float _211 = ceil(_61);
    int _212 = int(_211);
    int _213 = _212 & 31;
    int _214 = (uint)(_73.x) >> _213;
    float _215 = float((uint)_214);
    int _216 = (uint)(_73.y) >> _213;
    float _217 = float((uint)_216);
    float _218 = 1.0f / _215;
    float _219 = 1.0f / _217;
    float _220 = _215 * _56;
    float _221 = _217 * _57;
    float _222 = _220 + -0.5f;
    float _223 = _221 + -0.5f;
    float _224 = frac(_222);
    float _225 = frac(_223);
    float _226 = floor(_222);
    float _227 = floor(_223);
    float _228 = 1.0f - _224;
    float _229 = 2.0f - _224;
    float _230 = 3.0f - _224;
    float _231 = _228 * _228;
    float _232 = _229 * _229;
    float _233 = _230 * _230;
    float _234 = _231 * _228;
    float _235 = _232 * _229;
    float _236 = _233 * _230;
    float _237 = _234 * 4.0f;
    float _238 = _235 - _237;
    float _239 = _235 * 4.0f;
    float _240 = _234 * 6.0f;
    float _241 = 6.0f - _234;
    float _242 = _241 - _238;
    float _243 = _239 - _236;
    float _244 = _243 - _240;
    float _245 = _244 + _242;
    float _246 = _238 * 0.1666666716337204f;
    float _247 = _245 * 0.1666666716337204f;
    float _248 = 1.0f - _225;
    float _249 = 2.0f - _225;
    float _250 = 3.0f - _225;
    float _251 = _248 * _248;
    float _252 = _249 * _249;
    float _253 = _250 * _250;
    float _254 = _251 * _248;
    float _255 = _252 * _249;
    float _256 = _253 * _250;
    float _257 = _254 * 4.0f;
    float _258 = _255 - _257;
    float _259 = _255 * 4.0f;
    float _260 = _254 * 6.0f;
    float _261 = 6.0f - _254;
    float _262 = _261 - _258;
    float _263 = _259 - _256;
    float _264 = _263 - _260;
    float _265 = _264 + _262;
    float _266 = _258 * 0.1666666716337204f;
    float _267 = _265 * 0.1666666716337204f;
    float _268 = _226 + -0.5f;
    float _269 = _226 + 1.5f;
    float _270 = _227 + -0.5f;
    float _271 = _227 + 1.5f;
    float _272 = _238 + _234;
    float _273 = _272 * 0.1666666716337204f;
    float _274 = _242 * 0.1666666716337204f;
    float _275 = _258 + _254;
    float _276 = _275 * 0.1666666716337204f;
    float _277 = _262 * 0.1666666716337204f;
    float _278 = _246 / _273;
    float _279 = _247 / _274;
    float _280 = _266 / _276;
    float _281 = _267 / _277;
    float _282 = _268 + _278;
    float _283 = _269 + _279;
    float _284 = _270 + _280;
    float _285 = _271 + _281;
    float _286 = _282 * _218;
    float _287 = _283 * _218;
    float _288 = _284 * _219;
    float _289 = _285 * _219;
    float _290 = float((int)(_212));
    float4 _291 = t0.SampleLevel(s0, float2(_286, _288), _290);
    float4 _296 = t0.SampleLevel(s0, float2(_287, _288), _290);
    float4 _301 = t0.SampleLevel(s0, float2(_286, _289), _290);
    float4 _306 = t0.SampleLevel(s0, float2(_287, _289), _290);
    float _311 = _291.x - _296.x;
    float _312 = _291.y - _296.y;
    float _313 = _291.z - _296.z;
    float _314 = _291.w - _296.w;
    float _315 = _311 * _273;
    float _316 = _312 * _273;
    float _317 = _313 * _273;
    float _318 = _314 * _273;
    float _319 = _315 + _296.x;
    float _320 = _316 + _296.y;
    float _321 = _317 + _296.z;
    float _322 = _318 + _296.w;
    float _323 = _301.x - _306.x;
    float _324 = _301.y - _306.y;
    float _325 = _301.z - _306.z;
    float _326 = _301.w - _306.w;
    float _327 = _323 * _273;
    float _328 = _324 * _273;
    float _329 = _325 * _273;
    float _330 = _326 * _273;
    float _331 = _327 + _306.x;
    float _332 = _328 + _306.y;
    float _333 = _329 + _306.z;
    float _334 = _330 + _306.w;
    float _335 = _319 - _331;
    float _336 = _320 - _332;
    float _337 = _321 - _333;
    float _338 = _322 - _334;
    float _339 = _335 * _276;
    float _340 = _336 * _276;
    float _341 = _337 * _276;
    float _342 = _338 * _276;
    float _343 = frac(_61);
    float _344 = _331 - _207;
    float _345 = _344 + _339;
    float _346 = _332 - _208;
    float _347 = _346 + _340;
    float _348 = _333 - _209;
    float _349 = _348 + _341;
    float _350 = _334 - _210;
    float _351 = _350 + _342;
    float _352 = _345 * _343;
    float _353 = _347 * _343;
    float _354 = _349 * _343;
    float _355 = _351 * _343;
    float _356 = saturate(_61);
    float _357 = _207 - _64.x;
    float _358 = _357 + _352;
    float _359 = _208 - _64.y;
    float _360 = _359 + _353;
    float _361 = _209 - _64.z;
    float _362 = _361 + _354;
    float _363 = _210 - _64.w;
    float _364 = _363 + _355;
    float _365 = _358 * _356;
    float _366 = _360 * _356;
    float _367 = _362 * _356;
    float _368 = _364 * _356;
    float _369 = _365 + _64.x;
    float _370 = _366 + _64.y;
    float _371 = _367 + _64.z;
    float _372 = _368 + _64.w;
    _374 = _369;
    _375 = _370;
    _376 = _371;
    _377 = _372;
  } else {
    _374 = _64.x;
    _375 = _64.y;
    _376 = _64.z;
    _377 = _64.w;
  }
  float _378 = max(_374, 0.0f);
  float _379 = max(_375, 0.0f);
  float _380 = max(_376, 0.0f);
  float4 _382 = t12.SampleLevel(s1, float2(_56, _57), 0.0f);
  float4 _388 = t8.Sample(s8, float2(_58, _59));
  int _394 = asint((User_000.UserConstant_Z_000[3].z));
  bool _395 = ((int)_394 > (int)0);
  if (!_395) {
    bool _399 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _403 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _388.x;
    float _404 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _388.y;
    float _405 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _388.z;
    float _406 = _403 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _407 = _404 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _408 = _405 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_399) {
      float _410 = _406 * _382.x;
      float _411 = _407 * _382.y;
      float _412 = _408 * _382.z;
      _424 = _410;
      _425 = _411;
      _426 = _412;
    } else {
      float _414 = saturate(_406);
      float _415 = saturate(_407);
      float _416 = saturate(_408);
      float _417 = _382.x - _378;
      float _418 = _382.y - _379;
      float _419 = _382.z - _380;
      float _420 = _414 * _417;
      float _421 = _415 * _418;
      float _422 = _416 * _419;
      _424 = _420;
      _425 = _421;
      _426 = _422;
    }
    float _427 = _424 + _378;
    float _428 = _425 + _379;
    float _429 = _426 + _380;
    _431 = _427;
    _432 = _428;
    _433 = _429;
  } else {
    _431 = _378;
    _432 = _379;
    _433 = _380;
  }
  [branch]
  if (_395) {
    bool _438 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_438) {
      float _440 = _37.x + TEXCOORD.x;
      float _441 = _46 + TEXCOORD.y;
      float4 _444 = t2.SampleLevel(s2, float2(_440, _441), 0.0f);
      bool _448 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_448) {
        float4 _451 = t7.Load(int3(0, 0, 0));
        float _456 = _451.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _457 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _456;
        _462 = _457;
      } else {
        _462 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _466 = _444.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _467 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _466;
      float _469 = _462 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _470 = _469 + _462;
      float _471 = _462 - _469;
      float _472 = max(_467, _471);
      float _473 = min(_472, _470);
      float _476 = _467 - _473;
      float _477 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _476;
      float _479 = _473 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _480 = _479 * _467;
      float _481 = _477 / _480;
      float _482 = min(_481, 0.0f);
      float _484 = _469 + 1.0f;
      float _485 = 1.0f / _484;
      float _486 = _482 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _487 = max(0.0f, _481);
      float _490 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _487;
      float _491 = _490 + _486;
      float _492 = _491 * _485;
      float _493 = max(_492, -1.0f);
      float _494 = min(_493, 1.0f);
      float _495 = max(_494, -0.30000001192092896f);
      float _496 = min(_495, 1.0f);
      float _498 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _499 = _496 * _498;
      float _500 = _440 + -0.5f;
      float _501 = _441 + -0.5f;
      float _502 = _500 * _500;
      float _503 = _501 * _501;
      float _504 = _503 + _502;
      float _505 = sqrt(_504);
      float _506 = log2(_505);
      float _507 = _506 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _508 = exp2(_507);
      float _509 = _508 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _510 = dot(float2(_500, _501), float2(_500, _501));
      float _511 = rsqrt(_510);
      float _512 = _511 * _500;
      float _513 = _511 * _501;
      float _514 = abs(_499);
      float _518 = _509 * _514;
      float _519 = -0.0f - _518;
      float _520 = (User_000.UserConstant_Z_000[2].x) * _512;
      float _521 = _520 * _519;
      float _522 = (User_000.UserConstant_Z_000[2].y) * _513;
      float _523 = _522 * _519;
      float _524 = _514 * _509;
      float _525 = _520 * _524;
      float _526 = _522 * _524;
      float _527 = _521 + _440;
      float _528 = _523 + _441;
      float _529 = _525 + _440;
      float _530 = _526 + _441;
      float _531 = max(_61, 0.0f);
      float4 _532 = t0.SampleLevel(s1, float2(_527, _528), _531);
      float4 _534 = t0.SampleLevel(s1, float2(_529, _530), _531);
      float4 _536 = t2.SampleLevel(s2, float2(_527, _528), 0.0f);
      if (_448) {
        float4 _540 = t7.Load(int3(0, 0, 0));
        float _542 = _540.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _543 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _542;
        _547 = _543;
      } else {
        _547 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _548 = _536.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _549 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _548;
      float _550 = _547 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _551 = _550 + _547;
      float _552 = _547 - _550;
      float _553 = max(_549, _552);
      float _554 = min(_553, _551);
      float _555 = _549 - _554;
      float _556 = _555 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _557 = _554 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _558 = _557 * _549;
      float _559 = _556 / _558;
      float _560 = min(_559, 0.0f);
      float _561 = _550 + 1.0f;
      float _562 = 1.0f / _561;
      float _563 = _560 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _564 = max(0.0f, _559);
      float _565 = _564 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _566 = _565 + _563;
      float _567 = _566 * _562;
      float _568 = max(_567, -1.0f);
      float _569 = min(_568, 1.0f);
      float _570 = max(_569, -0.30000001192092896f);
      float _571 = min(_570, 1.0f);
      float _572 = _571 * _498;
      float4 _573 = t2.SampleLevel(s2, float2(_529, _530), 0.0f);
      if (_448) {
        float4 _577 = t7.Load(int3(0, 0, 0));
        float _579 = _577.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _580 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _579;
        _584 = _580;
      } else {
        _584 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _585 = _573.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _586 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _585;
      float _587 = _584 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _588 = _587 + _584;
      float _589 = _584 - _587;
      float _590 = max(_586, _589);
      float _591 = min(_590, _588);
      float _592 = _586 - _591;
      float _593 = _592 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _594 = _591 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _595 = _594 * _586;
      float _596 = _593 / _595;
      float _597 = min(_596, 0.0f);
      float _598 = _587 + 1.0f;
      float _599 = 1.0f / _598;
      float _600 = _597 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _601 = max(0.0f, _596);
      float _602 = _601 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _603 = _602 + _600;
      float _604 = _603 * _599;
      float _605 = max(_604, -1.0f);
      float _606 = min(_605, 1.0f);
      float _607 = max(_606, -0.30000001192092896f);
      float _608 = min(_607, 1.0f);
      float _609 = _608 * _498;
      float _610 = abs(_572);
      float _611 = _610 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _612 = ceil(_611);
      float _613 = saturate(_612);
      float _614 = _532.x - _431;
      float _615 = _613 * _614;
      float _616 = _615 + _431;
      float _617 = abs(_609);
      float _618 = _617 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _619 = ceil(_618);
      float _620 = saturate(_619);
      float _621 = _534.z - _433;
      float _622 = _620 * _621;
      float _623 = _622 + _433;
      _813 = _616;
      _814 = _432;
      _815 = _623;
    } else {
      _813 = _431;
      _814 = _432;
      _815 = _433;
    }
  } else {
    int _626 = asint((User_000.UserConstant_Z_000[3].y));
    bool _627 = ((int)_626 > (int)0);
    if (_627) {
      float _629 = _37.x + TEXCOORD.x;
      float _630 = _46 + TEXCOORD.y;
      float4 _633 = t4.Sample(s4, float2(_629, _630));
      float4 _640 = t5.Sample(s5, float2(_629, _630));
      float _644 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _640.x;
      float _648 = _644 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _649 = _644 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _650 = _648 + _629;
      float _651 = _649 + _630;
      float4 _652 = t4.Sample(s4, float2(_650, _651));
      float4 _654 = t5.Sample(s5, float2(_650, _651));
      float _656 = _654.x * (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _657 = abs(_656);
      float _659 = _657 / (PostProcess_000.PostProcessConstant_Z_000[7].w);
      float _660 = _652.z - _633.z;
      float _661 = _659 * _660;
      float _662 = _633.x - _431;
      float _663 = _633.y - _432;
      float _664 = _633.z - _433;
      float _665 = _664 + _661;
      float _666 = _662 * _633.w;
      float _667 = _663 * _633.w;
      float _668 = _665 * _633.w;
      float _669 = _666 + _431;
      float _670 = _667 + _432;
      float _671 = _668 + _433;
      _813 = _669;
      _814 = _670;
      _815 = _671;
    } else {
      int _674 = asint((User_000.UserConstant_Z_000[3].x));
      bool _675 = ((int)_674 > (int)0);
      [branch]
      if (_675) {
        float4 _679 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _681 = abs(_679.x);
        _774 = _681;
      } else {
        float4 _685 = t2.SampleLevel(s2, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _687 = TEXCOORD.x * 2.0f;
        float _688 = TEXCOORD.y * 2.0f;
        float _689 = _687 + -1.0f;
        float _690 = _688 + -1.0f;
        float _711 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _689;
        float _712 = mad(_690, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _711);
        float _713 = mad(_685.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _712);
        float _714 = _713 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _715 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _689;
        float _716 = mad(_690, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _715);
        float _717 = mad(_685.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _716);
        float _718 = _717 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _719 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _689;
        float _720 = mad(_690, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _719);
        float _721 = mad(_685.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _720);
        float _722 = _721 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _723 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _689;
        float _724 = mad(_690, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _723);
        float _725 = mad(_685.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _724);
        float _726 = _725 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
        float _727 = _714 / _726;
        float _728 = _718 / _726;
        float _729 = _722 / _726;
        float _730 = _727 * _727;
        float _731 = _728 * _728;
        float _732 = _731 + _730;
        float _733 = _729 * _729;
        float _734 = _732 + _733;
        float _735 = sqrt(_734);
        float4 _738 = t5.Sample(s5, float2(TEXCOORD.x, TEXCOORD.y));
        float _744 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _745 = _744 + (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _746 = (PostProcess_000.PostProcessConstant_Z_000[5].x) - _744;
        float _747 = max(_735, _746);
        float _748 = min(_747, _745);
        float _750 = _735 - _748;
        float _751 = _750 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
        float _753 = _748 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _754 = _753 * _735;
        float _755 = _751 / _754;
        float _756 = min(_755, 0.0f);
        float _759 = _744 + 1.0f;
        float _760 = 1.0f / _759;
        float _761 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _756;
        float _762 = max(0.0f, _755);
        float _765 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _762;
        float _766 = _765 + _761;
        float _767 = _766 * _760;
        float _768 = min(_738.x, _767);
        float _769 = abs(_768);
        float _770 = abs(_767);
        float _771 = max(_769, _770);
        float _772 = saturate(_771);
        _774 = _772;
      }
      float _777 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _774;
      float4 _780 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _787 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _777;
      float _788 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _777;
      float _789 = _787 + TEXCOORD.x;
      float _790 = _788 + TEXCOORD.y;
      float4 _791 = t4.Sample(s4, float2(_789, _790));
      float4 _795 = t5.Sample(s5, float2(_789, _790));
      float _797 = abs(_795.x);
      float _798 = _791.z - _780.z;
      float _799 = _797 * _798;
      float _800 = _777 + -1.0f;
      float _801 = saturate(_800);
      float _802 = _780.x - _431;
      float _803 = _780.y - _432;
      float _804 = _780.z - _433;
      float _805 = _804 + _799;
      float _806 = _801 * _802;
      float _807 = _801 * _803;
      float _808 = _805 * _801;
      float _809 = _806 + _431;
      float _810 = _807 + _432;
      float _811 = _808 + _433;
      _813 = _809;
      _814 = _810;
      _815 = _811;
    }
  }
  if (_395) {
    bool _819 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _823 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _388.x;
    float _824 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _388.y;
    float _825 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _388.z;
    float _826 = _823 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _827 = _824 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _828 = _825 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_819) {
      float _830 = _826 * _382.x;
      float _831 = _827 * _382.y;
      float _832 = _828 * _382.z;
      _844 = _830;
      _845 = _831;
      _846 = _832;
    } else {
      float _834 = saturate(_826);
      float _835 = saturate(_827);
      float _836 = saturate(_828);
      float _837 = _382.x - _813;
      float _838 = _382.y - _814;
      float _839 = _382.z - _815;
      float _840 = _834 * _837;
      float _841 = _835 * _838;
      float _842 = _836 * _839;
      _844 = _840;
      _845 = _841;
      _846 = _842;
    }
    float _847 = _844 + _813;
    float _848 = _845 + _814;
    float _849 = _846 + _815;
    _851 = _847;
    _852 = _848;
    _853 = _849;
  } else {
    _851 = _813;
    _852 = _814;
    _853 = _815;
  }
  float4 _857 = t17.Load(int3(0, 0, 0));
  float _863 = _857.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _864 = _863 * _851;
  float _865 = _864 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _866 = _863 * _852;
  float _867 = _866 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _868 = _863 * _853;
  float _869 = _868 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _874 = _56 * 2.0f;
  float _875 = _57 * 2.0f;
  float _876 = _874 + -1.0f;
  float _877 = _875 + -1.0f;
  float _880 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _877;
  float _881 = _876 * _876;
  float _882 = _880 * _880;
  float _883 = _882 + _881;
  float _884 = sqrt(_883);
  float _886 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _884;
  float _888 = _886 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _889 = saturate(_888);
  float _891 = log2(_889);
  float _892 = _891 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _893 = exp2(_892);
  float _894 = _865 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _895 = _867 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _896 = _869 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _897 = _894 - _865;
  float _898 = _895 - _867;
  float _899 = _896 - _869;
  float _900 = _893 * _897;
  float _901 = _893 * _898;
  float _902 = _893 * _899;
  float _903 = _900 + _865;
  float _904 = _901 + _867;
  float _905 = _902 + _869;
  float _909 = _903 * 335.718017578125f;
  float _910 = _904 * 335.718017578125f;
  float _911 = _905 * 335.718017578125f;
  float _912 = _909 + 1.0f;
  float _913 = _910 + 1.0f;
  float _914 = _911 + 1.0f;
  float _915 = log2(_912);
  float _916 = log2(_913);
  float _917 = log2(_914);
  float _918 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _919 = _918 * _915;
  float _920 = _918 * _916;
  float _921 = _917 * _918;
  float _922 = _919 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _923 = _920 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _924 = _921 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _927 = t3.Sample(s3, float3(_922, _923, _924));
  float _931 = _927.x * 13.450128555297852f;
  float _932 = _927.y * 13.450128555297852f;
  float _933 = _927.z * 13.450128555297852f;
  float _934 = exp2(_931);
  float _935 = exp2(_932);
  float _936 = exp2(_933);
  float _937 = _934 + -1.0f;
  float _938 = _935 + -1.0f;
  float _939 = _936 + -1.0f;
  float _940 = _937 * 0.0029786902014166117f;
  float _941 = _938 * 0.0029786902014166117f;
  float _942 = _939 * 0.0029786902014166117f;
  float _947 = _940 * (User_000.UserConstant_Z_000[4].x);
  float _948 = _941 * (User_000.UserConstant_Z_000[4].y);
  float _949 = _942 * (User_000.UserConstant_Z_000[4].z);
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_903, _904, _905),
      float3(_947, _948, _949),
      User_000.UserConstant_Z_000[4].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(apt_scaled_lut_output, SV_Position.xy);
  _947 = apt_scaled_lut_output.x;
  _948 = apt_scaled_lut_output.y;
  _949 = apt_scaled_lut_output.z;
  bool _952 = !((PostProcess_000.PostProcessConstant_Z_000[17].x) == 0.0f);
  if (_952) {
    float _962 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _947;
    float _963 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _948;
    float _964 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _949;
    bool _965 = (_962 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_965) {
      float _967 = _962 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _968 = 1.0f - _967;
      float _969 = _968 * _968;
      float _970 = _969 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _971 = _970 + _962;
      _973 = _971;
    } else {
      _973 = _962;
    }
    bool _974 = (_963 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_974) {
      float _976 = _963 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _977 = 1.0f - _976;
      float _978 = _977 * _977;
      float _979 = _978 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _980 = _979 + _963;
      _982 = _980;
    } else {
      _982 = _963;
    }
    bool _983 = (_964 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_983) {
      float _985 = _964 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _986 = 1.0f - _985;
      float _987 = _986 * _986;
      float _988 = _987 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _989 = _988 + _964;
      _991 = _989;
    } else {
      _991 = _964;
    }
    float _992 = _973 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _993 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
    float _994 = log2(_992);
    float _995 = _994 * _993;
    float _996 = exp2(_995);
    float _997 = _996 + -1.0f;
    float _998 = _992 + -1.0f;
    float _999 = _997 / _998;
    bool _1000 = !(_992 == 1.0f);
    float _1001 = _999 + -1.0f;
    float _1002 = _1001 / _999;
    float _1003 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _1004 = _1003 / _993;
    float _1005 = select(_1000, _1002, _1004);
    float _1006 = _1005 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _1007 = _982 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _1008 = log2(_1007);
    float _1009 = _1008 * _993;
    float _1010 = exp2(_1009);
    float _1011 = _1010 + -1.0f;
    float _1012 = _1007 + -1.0f;
    float _1013 = _1011 / _1012;
    bool _1014 = !(_1007 == 1.0f);
    float _1015 = _1013 + -1.0f;
    float _1016 = _1015 / _1013;
    float _1017 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _1018 = _1017 / _993;
    float _1019 = select(_1014, _1016, _1018);
    float _1020 = _1019 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _1021 = _991 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _1022 = log2(_1021);
    float _1023 = _1022 * _993;
    float _1024 = exp2(_1023);
    float _1025 = _1024 + -1.0f;
    float _1026 = _1021 + -1.0f;
    float _1027 = _1025 / _1026;
    bool _1028 = !(_1021 == 1.0f);
    float _1029 = _1027 + -1.0f;
    float _1030 = _1029 / _1027;
    float _1031 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _1032 = _1031 / _993;
    float _1033 = select(_1028, _1030, _1032);
    float _1034 = _1033 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _1035 = _1006 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _1036 = _1020 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _1037 = _1034 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    _1039 = _1035;
    _1040 = _1036;
    _1041 = _1037;
  } else {
    _1039 = _947;
    _1040 = _948;
    _1041 = _949;
  }
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_947, _948, _949),
      float3(_1039, _1040, _1041),
      false);
  _1039 = apt_post_process_output.x;
  _1040 = apt_post_process_output.y;
  _1041 = apt_post_process_output.z;
  float _1042 = log2(_1039);
  float _1043 = log2(_1040);
  float _1044 = log2(_1041);
  float _1045 = _1042 * 0.4166666567325592f;
  float _1046 = _1043 * 0.4166666567325592f;
  float _1047 = _1044 * 0.4166666567325592f;
  float _1048 = exp2(_1045);
  float _1049 = exp2(_1046);
  float _1050 = exp2(_1047);
  float _1051 = _1048 * 1.0549999475479126f;
  float _1052 = _1049 * 1.0549999475479126f;
  float _1053 = _1050 * 1.0549999475479126f;
  float _1054 = _1051 + -0.054999999701976776f;
  float _1055 = _1052 + -0.054999999701976776f;
  float _1056 = _1053 + -0.054999999701976776f;
  float _1057 = _1039 * 12.920000076293945f;
  float _1058 = _1040 * 12.920000076293945f;
  float _1059 = _1041 * 12.920000076293945f;
  bool _1060 = (_1039 <= 0.0031308000907301903f);
  bool _1061 = (_1040 <= 0.0031308000907301903f);
  bool _1062 = (_1041 <= 0.0031308000907301903f);
  float _1063 = select(_1060, _1057, _1054);
  float _1064 = select(_1061, _1058, _1055);
  float _1065 = select(_1062, _1059, _1056);
  float _1066 = log2(_1063);
  float _1067 = log2(_1064);
  float _1068 = log2(_1065);
  float _1069 = floor(_1066);
  float _1070 = floor(_1067);
  float _1071 = floor(_1068);
  float _1072 = _1069 + -6.0f;
  float _1073 = _1070 + -6.0f;
  float _1074 = _1071 + -5.0f;
  float _1075 = exp2(_1072);
  float _1076 = exp2(_1073);
  float _1077 = exp2(_1074);
  bool _1078 = (_1063 <= 0.0f);
  bool _1079 = (_1064 <= 0.0f);
  bool _1080 = (_1065 <= 0.0f);
  float _1081 = select(_1078, 0.0f, _1075);
  float _1082 = select(_1079, 0.0f, _1076);
  float _1083 = select(_1080, 0.0f, _1077);
  int _1086 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1087 = uint(SV_Position.x);
  uint _1088 = uint(SV_Position.y);
  int _1089 = _1087 & 63;
  int _1090 = _1088 & 63;
  float4 _1092 = t1.Load(int4(_1089, _1090, _1086, 0));
  float4 _1095 = t6.Load(int4(_1089, _1090, _1086, 0));
  float _1098 = _1092.x * _1081;
  float _1099 = _1095.x * _1082;
  float _1100 = _1095.y * _1083;
  float _1101 = _1098 + _1063;
  float _1102 = _1099 + _1064;
  float _1103 = _1100 + _1065;
  SV_Target.x = _1101;
  SV_Target.y = _1102;
  SV_Target.z = _1103;
  SV_Target.w = _377;
  return SV_Target;
}
