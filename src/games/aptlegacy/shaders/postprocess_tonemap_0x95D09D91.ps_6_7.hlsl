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

Texture2DArray<float4> t2 : register(t2);

Texture2D<float4> t0 : register(t0);

Texture3D<float4> t3 : register(t3);

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

SamplerState s3 : register(s3);

SamplerState s8 : register(s8);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _29 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _35 = t16.Sample(s1, float2(TEXCOORD.z, TEXCOORD.w));
  float _37 = _35.y * 0.10000000149011612f;
  float _38 = _37 + _29.y;
  float _39 = _35.y * 0.5f;
  float _40 = _39 + _29.z;
  float _41 = exp2(_40);
  float _42 = _41 + -1.0f;
  float _45 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _42;
  float _46 = _45 + 1.0f;
  float _47 = log2(_46);
  float _48 = _29.x + TEXCOORD.z;
  float _49 = _38 + TEXCOORD.w;
  float _50 = _29.x + TEXCOORD.x;
  float _51 = _38 + TEXCOORD.y;
  float _52 = _47 + 1.0f;
  float _53 = log2(_52);
  float4 _56 = t0.SampleLevel(s1, float2(_48, _49), _53);
  bool _61 = (_53 > 0.0f);
  float _366;
  float _367;
  float _368;
  float _369;
  float _416;
  float _417;
  float _418;
  float _423;
  float _424;
  float _425;
  float _454;
  float _455;
  float _456;
  float _461;
  float _462;
  float _463;
  [branch]
  if (_61) {
    float _63 = floor(_53);
    int _64 = int(_63);
    uint2 _65; t0.GetDimensions(_65.x, _65.y);
    int _68 = _64 & 31;
    int _69 = (uint)(_65.x) >> _68;
    float _70 = float((uint)_69);
    int _71 = (uint)(_65.y) >> _68;
    float _72 = float((uint)_71);
    float _73 = 1.0f / _70;
    float _74 = 1.0f / _72;
    float _75 = _70 * _48;
    float _76 = _72 * _49;
    float _77 = _75 + -0.5f;
    float _78 = _76 + -0.5f;
    float _79 = frac(_77);
    float _80 = frac(_78);
    float _81 = floor(_77);
    float _82 = floor(_78);
    float _83 = 1.0f - _79;
    float _84 = 2.0f - _79;
    float _85 = 3.0f - _79;
    float _86 = _83 * _83;
    float _87 = _84 * _84;
    float _88 = _85 * _85;
    float _89 = _86 * _83;
    float _90 = _87 * _84;
    float _91 = _88 * _85;
    float _92 = _89 * 4.0f;
    float _93 = _90 - _92;
    float _94 = _90 * 4.0f;
    float _95 = _89 * 6.0f;
    float _96 = 6.0f - _89;
    float _97 = _96 - _93;
    float _98 = _94 - _91;
    float _99 = _98 - _95;
    float _100 = _99 + _97;
    float _101 = _93 * 0.1666666716337204f;
    float _102 = _100 * 0.1666666716337204f;
    float _103 = 1.0f - _80;
    float _104 = 2.0f - _80;
    float _105 = 3.0f - _80;
    float _106 = _103 * _103;
    float _107 = _104 * _104;
    float _108 = _105 * _105;
    float _109 = _106 * _103;
    float _110 = _107 * _104;
    float _111 = _108 * _105;
    float _112 = _109 * 4.0f;
    float _113 = _110 - _112;
    float _114 = _110 * 4.0f;
    float _115 = _109 * 6.0f;
    float _116 = 6.0f - _109;
    float _117 = _116 - _113;
    float _118 = _114 - _111;
    float _119 = _118 - _115;
    float _120 = _119 + _117;
    float _121 = _113 * 0.1666666716337204f;
    float _122 = _120 * 0.1666666716337204f;
    float _123 = _81 + -0.5f;
    float _124 = _81 + 1.5f;
    float _125 = _82 + -0.5f;
    float _126 = _82 + 1.5f;
    float _127 = _93 + _89;
    float _128 = _127 * 0.1666666716337204f;
    float _129 = _97 * 0.1666666716337204f;
    float _130 = _113 + _109;
    float _131 = _130 * 0.1666666716337204f;
    float _132 = _117 * 0.1666666716337204f;
    float _133 = _101 / _128;
    float _134 = _102 / _129;
    float _135 = _121 / _131;
    float _136 = _122 / _132;
    float _137 = _123 + _133;
    float _138 = _124 + _134;
    float _139 = _125 + _135;
    float _140 = _126 + _136;
    float _141 = _137 * _73;
    float _142 = _138 * _73;
    float _143 = _139 * _74;
    float _144 = _140 * _74;
    float _145 = float((int)(_64));
    float4 _147 = t0.SampleLevel(s0, float2(_141, _143), _145);
    float4 _152 = t0.SampleLevel(s0, float2(_142, _143), _145);
    float4 _157 = t0.SampleLevel(s0, float2(_141, _144), _145);
    float4 _162 = t0.SampleLevel(s0, float2(_142, _144), _145);
    float _167 = _147.x - _152.x;
    float _168 = _147.y - _152.y;
    float _169 = _147.z - _152.z;
    float _170 = _147.w - _152.w;
    float _171 = _167 * _128;
    float _172 = _168 * _128;
    float _173 = _169 * _128;
    float _174 = _170 * _128;
    float _175 = _171 + _152.x;
    float _176 = _172 + _152.y;
    float _177 = _173 + _152.z;
    float _178 = _174 + _152.w;
    float _179 = _157.x - _162.x;
    float _180 = _157.y - _162.y;
    float _181 = _157.z - _162.z;
    float _182 = _157.w - _162.w;
    float _183 = _179 * _128;
    float _184 = _180 * _128;
    float _185 = _181 * _128;
    float _186 = _182 * _128;
    float _187 = _183 + _162.x;
    float _188 = _184 + _162.y;
    float _189 = _185 + _162.z;
    float _190 = _186 + _162.w;
    float _191 = _175 - _187;
    float _192 = _176 - _188;
    float _193 = _177 - _189;
    float _194 = _178 - _190;
    float _195 = _191 * _131;
    float _196 = _192 * _131;
    float _197 = _193 * _131;
    float _198 = _194 * _131;
    float _199 = _195 + _187;
    float _200 = _196 + _188;
    float _201 = _197 + _189;
    float _202 = _198 + _190;
    float _203 = ceil(_53);
    int _204 = int(_203);
    int _205 = _204 & 31;
    int _206 = (uint)(_65.x) >> _205;
    float _207 = float((uint)_206);
    int _208 = (uint)(_65.y) >> _205;
    float _209 = float((uint)_208);
    float _210 = 1.0f / _207;
    float _211 = 1.0f / _209;
    float _212 = _207 * _48;
    float _213 = _209 * _49;
    float _214 = _212 + -0.5f;
    float _215 = _213 + -0.5f;
    float _216 = frac(_214);
    float _217 = frac(_215);
    float _218 = floor(_214);
    float _219 = floor(_215);
    float _220 = 1.0f - _216;
    float _221 = 2.0f - _216;
    float _222 = 3.0f - _216;
    float _223 = _220 * _220;
    float _224 = _221 * _221;
    float _225 = _222 * _222;
    float _226 = _223 * _220;
    float _227 = _224 * _221;
    float _228 = _225 * _222;
    float _229 = _226 * 4.0f;
    float _230 = _227 - _229;
    float _231 = _227 * 4.0f;
    float _232 = _226 * 6.0f;
    float _233 = 6.0f - _226;
    float _234 = _233 - _230;
    float _235 = _231 - _228;
    float _236 = _235 - _232;
    float _237 = _236 + _234;
    float _238 = _230 * 0.1666666716337204f;
    float _239 = _237 * 0.1666666716337204f;
    float _240 = 1.0f - _217;
    float _241 = 2.0f - _217;
    float _242 = 3.0f - _217;
    float _243 = _240 * _240;
    float _244 = _241 * _241;
    float _245 = _242 * _242;
    float _246 = _243 * _240;
    float _247 = _244 * _241;
    float _248 = _245 * _242;
    float _249 = _246 * 4.0f;
    float _250 = _247 - _249;
    float _251 = _247 * 4.0f;
    float _252 = _246 * 6.0f;
    float _253 = 6.0f - _246;
    float _254 = _253 - _250;
    float _255 = _251 - _248;
    float _256 = _255 - _252;
    float _257 = _256 + _254;
    float _258 = _250 * 0.1666666716337204f;
    float _259 = _257 * 0.1666666716337204f;
    float _260 = _218 + -0.5f;
    float _261 = _218 + 1.5f;
    float _262 = _219 + -0.5f;
    float _263 = _219 + 1.5f;
    float _264 = _230 + _226;
    float _265 = _264 * 0.1666666716337204f;
    float _266 = _234 * 0.1666666716337204f;
    float _267 = _250 + _246;
    float _268 = _267 * 0.1666666716337204f;
    float _269 = _254 * 0.1666666716337204f;
    float _270 = _238 / _265;
    float _271 = _239 / _266;
    float _272 = _258 / _268;
    float _273 = _259 / _269;
    float _274 = _260 + _270;
    float _275 = _261 + _271;
    float _276 = _262 + _272;
    float _277 = _263 + _273;
    float _278 = _274 * _210;
    float _279 = _275 * _210;
    float _280 = _276 * _211;
    float _281 = _277 * _211;
    float _282 = float((int)(_204));
    float4 _283 = t0.SampleLevel(s0, float2(_278, _280), _282);
    float4 _288 = t0.SampleLevel(s0, float2(_279, _280), _282);
    float4 _293 = t0.SampleLevel(s0, float2(_278, _281), _282);
    float4 _298 = t0.SampleLevel(s0, float2(_279, _281), _282);
    float _303 = _283.x - _288.x;
    float _304 = _283.y - _288.y;
    float _305 = _283.z - _288.z;
    float _306 = _283.w - _288.w;
    float _307 = _303 * _265;
    float _308 = _304 * _265;
    float _309 = _305 * _265;
    float _310 = _306 * _265;
    float _311 = _307 + _288.x;
    float _312 = _308 + _288.y;
    float _313 = _309 + _288.z;
    float _314 = _310 + _288.w;
    float _315 = _293.x - _298.x;
    float _316 = _293.y - _298.y;
    float _317 = _293.z - _298.z;
    float _318 = _293.w - _298.w;
    float _319 = _315 * _265;
    float _320 = _316 * _265;
    float _321 = _317 * _265;
    float _322 = _318 * _265;
    float _323 = _319 + _298.x;
    float _324 = _320 + _298.y;
    float _325 = _321 + _298.z;
    float _326 = _322 + _298.w;
    float _327 = _311 - _323;
    float _328 = _312 - _324;
    float _329 = _313 - _325;
    float _330 = _314 - _326;
    float _331 = _327 * _268;
    float _332 = _328 * _268;
    float _333 = _329 * _268;
    float _334 = _330 * _268;
    float _335 = frac(_53);
    float _336 = _323 - _199;
    float _337 = _336 + _331;
    float _338 = _324 - _200;
    float _339 = _338 + _332;
    float _340 = _325 - _201;
    float _341 = _340 + _333;
    float _342 = _326 - _202;
    float _343 = _342 + _334;
    float _344 = _337 * _335;
    float _345 = _339 * _335;
    float _346 = _341 * _335;
    float _347 = _343 * _335;
    float _348 = saturate(_53);
    float _349 = _199 - _56.x;
    float _350 = _349 + _344;
    float _351 = _200 - _56.y;
    float _352 = _351 + _345;
    float _353 = _201 - _56.z;
    float _354 = _353 + _346;
    float _355 = _202 - _56.w;
    float _356 = _355 + _347;
    float _357 = _350 * _348;
    float _358 = _352 * _348;
    float _359 = _354 * _348;
    float _360 = _356 * _348;
    float _361 = _357 + _56.x;
    float _362 = _358 + _56.y;
    float _363 = _359 + _56.z;
    float _364 = _360 + _56.w;
    _366 = _361;
    _367 = _362;
    _368 = _363;
    _369 = _364;
  } else {
    _366 = _56.x;
    _367 = _56.y;
    _368 = _56.z;
    _369 = _56.w;
  }
  float _370 = max(_366, 0.0f);
  float _371 = max(_367, 0.0f);
  float _372 = max(_368, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_370, _371, _372),
      float3(_370, _371, _372),
      float2(_48, _49),
      t0,
      s1,
      _53);
  _370 = renodx_chromatic_aberration_input.x;
  _371 = renodx_chromatic_aberration_input.y;
  _372 = renodx_chromatic_aberration_input.z;
  float4 _374 = t12.SampleLevel(s1, float2(_48, _49), 0.0f);
  float4 _380 = t8.Sample(s8, float2(_50, _51));
  int _386 = asint((User_000.UserConstant_Z_000[3].z));
  bool _387 = ((int)_386 > (int)0);
  if (!_387) {
    bool _391 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _395 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _380.x;
    float _396 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _380.y;
    float _397 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _380.z;
    float _398 = _395 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _399 = _396 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _400 = _397 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_391) {
      float _402 = _398 * _374.x;
      float _403 = _399 * _374.y;
      float _404 = _400 * _374.z;
      _416 = _402;
      _417 = _403;
      _418 = _404;
    } else {
      float _406 = saturate(_398);
      float _407 = saturate(_399);
      float _408 = saturate(_400);
      float _409 = _374.x - _370;
      float _410 = _374.y - _371;
      float _411 = _374.z - _372;
      float _412 = _406 * _409;
      float _413 = _407 * _410;
      float _414 = _408 * _411;
      _416 = _412;
      _417 = _413;
      _418 = _414;
    }
    float _419 = _416 + _370;
    float _420 = _417 + _371;
    float _421 = _418 + _372;
    _423 = _419;
    _424 = _420;
    _425 = _421;
  } else {
    _423 = _370;
    _424 = _371;
    _425 = _372;
  }
  if (_387) {
    bool _429 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _433 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _380.x;
    float _434 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _380.y;
    float _435 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _380.z;
    float _436 = _433 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _437 = _434 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _438 = _435 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_429) {
      float _440 = _436 * _374.x;
      float _441 = _437 * _374.y;
      float _442 = _438 * _374.z;
      _454 = _440;
      _455 = _441;
      _456 = _442;
    } else {
      float _444 = saturate(_436);
      float _445 = saturate(_437);
      float _446 = saturate(_438);
      float _447 = _374.x - _423;
      float _448 = _374.y - _424;
      float _449 = _374.z - _425;
      float _450 = _444 * _447;
      float _451 = _445 * _448;
      float _452 = _446 * _449;
      _454 = _450;
      _455 = _451;
      _456 = _452;
    }
    float _457 = _454 + _423;
    float _458 = _455 + _424;
    float _459 = _456 + _425;
    _461 = _457;
    _462 = _458;
    _463 = _459;
  } else {
    _461 = _423;
    _462 = _424;
    _463 = _425;
  }
  float4 _467 = t17.Load(int3(0, 0, 0));
  float _476 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 335.718017578125f;
  float _477 = _467.x * _476;
  float _478 = _477 * _461;
  float _479 = _478 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _480 = _477 * _462;
  float _481 = _480 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _482 = _477 * _463;
  float _483 = _482 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _484 = _479 + 1.0f;
  float _485 = _481 + 1.0f;
  float _486 = _483 + 1.0f;
  float _487 = log2(_484);
  float _488 = log2(_485);
  float _489 = log2(_486);
  float _490 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _491 = _490 * _487;
  float _492 = _490 * _488;
  float _493 = _489 * _490;
  float _494 = _491 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _495 = _492 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _496 = _493 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _499 = t3.Sample(s3, float3(_494, _495, _496));
  float _503 = _499.x * 13.450128555297852f;
  float _504 = _499.y * 13.450128555297852f;
  float _505 = _499.z * 13.450128555297852f;
  float _506 = exp2(_503);
  float _507 = exp2(_504);
  float _508 = exp2(_505);
  float _509 = _506 + -1.0f;
  float _510 = _507 + -1.0f;
  float _511 = _508 + -1.0f;
  float _512 = _509 * 0.0029786902014166117f;
  float _513 = _510 * 0.0029786902014166117f;
  float _514 = _511 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_479 * 0.0029786902014166117f, _481 * 0.0029786902014166117f, _483 * 0.0029786902014166117f),
      float3(_512 * (User_000.UserConstant_Z_000[4].x), _513 * (User_000.UserConstant_Z_000[4].y), _514 * (User_000.UserConstant_Z_000[4].z)),
      User_000.UserConstant_Z_000[4].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(apt_scaled_lut_output, SV_Position.xy);
  float _521 = apt_scaled_lut_output.x;
  float _522 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _523 = log2(_521);
  float _524 = _522 * _523;
  float _525 = exp2(_524);
  float _526 = _525 + -1.0f;
  float _527 = _521 + -1.0f;
  float _528 = _526 / _527;
  bool _529 = !(_521 == 1.0f);
  float _530 = _528 + -1.0f;
  float _531 = _530 / _528;
  float _532 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _533 = _532 / _522;
  float _534 = select(_529, _531, _533);
  float _535 = apt_scaled_lut_output.y;
  float _536 = log2(_535);
  float _537 = _536 * _522;
  float _538 = exp2(_537);
  float _539 = _538 + -1.0f;
  float _540 = _535 + -1.0f;
  float _541 = _539 / _540;
  bool _542 = !(_535 == 1.0f);
  float _543 = _541 + -1.0f;
  float _544 = _543 / _541;
  float _545 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _546 = _545 / _522;
  float _547 = select(_542, _544, _546);
  float _548 = apt_scaled_lut_output.z;
  float _549 = log2(_548);
  float _550 = _549 * _522;
  float _551 = exp2(_550);
  float _552 = _551 + -1.0f;
  float _553 = _548 + -1.0f;
  float _554 = _552 / _553;
  bool _555 = !(_548 == 1.0f);
  float _556 = _554 + -1.0f;
  float _557 = _556 / _554;
  float _558 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _559 = _558 / _522;
  float _560 = select(_555, _557, _559);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_521, _535, _548),
      float3(_534, _547, _560),
      true);
  float _561 = apt_post_process_output.x;
  float _562 = apt_post_process_output.y;
  float _563 = apt_post_process_output.z;
  float _564 = log2(_561);
  float _565 = log2(_562);
  float _566 = log2(_563);
  float _567 = _564 * 0.4166666567325592f;
  float _568 = _565 * 0.4166666567325592f;
  float _569 = _566 * 0.4166666567325592f;
  float _570 = exp2(_567);
  float _571 = exp2(_568);
  float _572 = exp2(_569);
  float _573 = _570 * 1.0549999475479126f;
  float _574 = _571 * 1.0549999475479126f;
  float _575 = _572 * 1.0549999475479126f;
  float _576 = _573 + -0.054999999701976776f;
  float _577 = _574 + -0.054999999701976776f;
  float _578 = _575 + -0.054999999701976776f;
  float _579 = _561 * 12.920000076293945f;
  float _580 = _562 * 12.920000076293945f;
  float _581 = _563 * 12.920000076293945f;
  bool _582 = (_561 <= 0.0031308000907301903f);
  bool _583 = (_562 <= 0.0031308000907301903f);
  bool _584 = (_563 <= 0.0031308000907301903f);
  float _585 = select(_582, _579, _576);
  float _586 = select(_583, _580, _577);
  float _587 = select(_584, _581, _578);
  float _588 = log2(_585);
  float _589 = log2(_586);
  float _590 = log2(_587);
  float _591 = floor(_588);
  float _592 = floor(_589);
  float _593 = floor(_590);
  float _594 = _591 + -6.0f;
  float _595 = _592 + -6.0f;
  float _596 = _593 + -5.0f;
  float _597 = exp2(_594);
  float _598 = exp2(_595);
  float _599 = exp2(_596);
  bool _600 = (_585 <= 0.0f);
  bool _601 = (_586 <= 0.0f);
  bool _602 = (_587 <= 0.0f);
  float _603 = select(_600, 0.0f, _597);
  float _604 = select(_601, 0.0f, _598);
  float _605 = select(_602, 0.0f, _599);
  int _608 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _609 = uint(SV_Position.x);
  uint _610 = uint(SV_Position.y);
  int _611 = _609 & 63;
  int _612 = _610 & 63;
  float4 _614 = t1.Load(int4(_611, _612, _608, 0));
  float4 _617 = t2.Load(int4(_611, _612, _608, 0));
  float _620 = _614.x * _603;
  float _621 = _617.x * _604;
  float _622 = _617.y * _605;
  float _623 = _620 + _585;
  float _624 = _621 + _586;
  float _625 = _622 + _587;
  SV_Target.x = _623;
  SV_Target.y = _624;
  SV_Target.z = _625;
  SV_Target.w = _369;
  return SV_Target;
}
