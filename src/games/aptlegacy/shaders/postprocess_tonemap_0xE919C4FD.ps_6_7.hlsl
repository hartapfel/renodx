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
  float _583;
  float _592;
  float _601;
  float _649;
  float _650;
  float _651;
  [branch]
  if (_61) {
    float _63 = floor(_53);
    int _64 = int(_63);
    uint4 _65 = 0u; t0.GetDimensions(0u, _65.x, _65.y, _65.w);
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
  float _473 = _467.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _474 = _473 * _461;
  float _475 = _474 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _476 = _473 * _462;
  float _477 = _476 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _478 = _473 * _463;
  float _479 = _478 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _484 = _48 * 2.0f;
  float _485 = _49 * 2.0f;
  float _486 = _484 + -1.0f;
  float _487 = _485 + -1.0f;
  float _490 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _487;
  float _491 = _486 * _486;
  float _492 = _490 * _490;
  float _493 = _492 + _491;
  float _494 = sqrt(_493);
  float _496 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _494;
  float _498 = _496 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _499 = saturate(_498);
  float _501 = log2(_499);
  float _502 = _501 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _503 = exp2(_502);
  float _504 = _475 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _505 = _477 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _506 = _479 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _507 = _504 - _475;
  float _508 = _505 - _477;
  float _509 = _506 - _479;
  float _510 = _503 * _507;
  float _511 = _503 * _508;
  float _512 = _503 * _509;
  float _513 = _510 + _475;
  float _514 = _511 + _477;
  float _515 = _512 + _479;
  float _519 = _513 * 335.718017578125f;
  float _520 = _514 * 335.718017578125f;
  float _521 = _515 * 335.718017578125f;
  float _522 = _519 + 1.0f;
  float _523 = _520 + 1.0f;
  float _524 = _521 + 1.0f;
  float _525 = log2(_522);
  float _526 = log2(_523);
  float _527 = log2(_524);
  float _528 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _529 = _528 * _525;
  float _530 = _528 * _526;
  float _531 = _527 * _528;
  float _532 = _529 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _533 = _530 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _534 = _531 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _537 = t3.Sample(s3, float3(_532, _533, _534));
  float _541 = _537.x * 13.450128555297852f;
  float _542 = _537.y * 13.450128555297852f;
  float _543 = _537.z * 13.450128555297852f;
  float _544 = exp2(_541);
  float _545 = exp2(_542);
  float _546 = exp2(_543);
  float _547 = _544 + -1.0f;
  float _548 = _545 + -1.0f;
  float _549 = _546 + -1.0f;
  float _550 = _547 * 0.0029786902014166117f;
  float _551 = _548 * 0.0029786902014166117f;
  float _552 = _549 * 0.0029786902014166117f;
  float _557 = _550 * (User_000.UserConstant_Z_000[4].x);
  float _558 = _551 * (User_000.UserConstant_Z_000[4].y);
  float _559 = _552 * (User_000.UserConstant_Z_000[4].z);
  float3 apt_scaled_lut_output = APTApplyPostProcessLUTScaling(
      float3(_519 * 0.0029786902014166117f, _520 * 0.0029786902014166117f, _521 * 0.0029786902014166117f),
      float3(_557, _558, _559),
      t3,
      s3,
      PostProcess_000.PostProcessConstant_Z_320[0].x,
      PostProcess_000.PostProcessConstant_Z_320[0].y,
      User_000.UserConstant_Z_000[4].rgb);
  _557 = apt_scaled_lut_output.x;
  _558 = apt_scaled_lut_output.y;
  _559 = apt_scaled_lut_output.z;
  bool _562 = !((PostProcess_000.PostProcessConstant_Z_000[17].x) == 0.0f);
  if (_562) {
    float _572 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _557;
    float _573 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _558;
    float _574 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _559;
    bool _575 = (_572 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_575) {
      float _577 = _572 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _578 = 1.0f - _577;
      float _579 = _578 * _578;
      float _580 = _579 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _581 = _580 + _572;
      _583 = _581;
    } else {
      _583 = _572;
    }
    bool _584 = (_573 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_584) {
      float _586 = _573 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _587 = 1.0f - _586;
      float _588 = _587 * _587;
      float _589 = _588 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _590 = _589 + _573;
      _592 = _590;
    } else {
      _592 = _573;
    }
    bool _593 = (_574 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_593) {
      float _595 = _574 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _596 = 1.0f - _595;
      float _597 = _596 * _596;
      float _598 = _597 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _599 = _598 + _574;
      _601 = _599;
    } else {
      _601 = _574;
    }
    float _602 = _583 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _603 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
    float _604 = log2(_602);
    float _605 = _604 * _603;
    float _606 = exp2(_605);
    float _607 = _606 + -1.0f;
    float _608 = _602 + -1.0f;
    float _609 = _607 / _608;
    bool _610 = !(_602 == 1.0f);
    float _611 = _609 + -1.0f;
    float _612 = _611 / _609;
    float _613 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _614 = _613 / _603;
    float _615 = select(_610, _612, _614);
    float _616 = _615 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _617 = _592 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _618 = log2(_617);
    float _619 = _618 * _603;
    float _620 = exp2(_619);
    float _621 = _620 + -1.0f;
    float _622 = _617 + -1.0f;
    float _623 = _621 / _622;
    bool _624 = !(_617 == 1.0f);
    float _625 = _623 + -1.0f;
    float _626 = _625 / _623;
    float _627 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _628 = _627 / _603;
    float _629 = select(_624, _626, _628);
    float _630 = _629 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _631 = _601 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _632 = log2(_631);
    float _633 = _632 * _603;
    float _634 = exp2(_633);
    float _635 = _634 + -1.0f;
    float _636 = _631 + -1.0f;
    float _637 = _635 / _636;
    bool _638 = !(_631 == 1.0f);
    float _639 = _637 + -1.0f;
    float _640 = _639 / _637;
    float _641 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _642 = _641 / _603;
    float _643 = select(_638, _640, _642);
    float _644 = _643 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _645 = _616 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _646 = _630 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _647 = _644 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    _649 = _645;
    _650 = _646;
    _651 = _647;
  } else {
    _649 = _557;
    _650 = _558;
    _651 = _559;
  }
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_557, _558, _559),
      float3(_649, _650, _651),
      false);
  _649 = apt_post_process_output.x;
  _650 = apt_post_process_output.y;
  _651 = apt_post_process_output.z;
  float _652 = log2(_649);
  float _653 = log2(_650);
  float _654 = log2(_651);
  float _655 = _652 * 0.4166666567325592f;
  float _656 = _653 * 0.4166666567325592f;
  float _657 = _654 * 0.4166666567325592f;
  float _658 = exp2(_655);
  float _659 = exp2(_656);
  float _660 = exp2(_657);
  float _661 = _658 * 1.0549999475479126f;
  float _662 = _659 * 1.0549999475479126f;
  float _663 = _660 * 1.0549999475479126f;
  float _664 = _661 + -0.054999999701976776f;
  float _665 = _662 + -0.054999999701976776f;
  float _666 = _663 + -0.054999999701976776f;
  float _667 = _649 * 12.920000076293945f;
  float _668 = _650 * 12.920000076293945f;
  float _669 = _651 * 12.920000076293945f;
  bool _670 = (_649 <= 0.0031308000907301903f);
  bool _671 = (_650 <= 0.0031308000907301903f);
  bool _672 = (_651 <= 0.0031308000907301903f);
  float _673 = select(_670, _667, _664);
  float _674 = select(_671, _668, _665);
  float _675 = select(_672, _669, _666);
  float _676 = log2(_673);
  float _677 = log2(_674);
  float _678 = log2(_675);
  float _679 = floor(_676);
  float _680 = floor(_677);
  float _681 = floor(_678);
  float _682 = _679 + -6.0f;
  float _683 = _680 + -6.0f;
  float _684 = _681 + -5.0f;
  float _685 = exp2(_682);
  float _686 = exp2(_683);
  float _687 = exp2(_684);
  bool _688 = (_673 <= 0.0f);
  bool _689 = (_674 <= 0.0f);
  bool _690 = (_675 <= 0.0f);
  float _691 = select(_688, 0.0f, _685);
  float _692 = select(_689, 0.0f, _686);
  float _693 = select(_690, 0.0f, _687);
  int _696 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _697 = uint(SV_Position.x);
  uint _698 = uint(SV_Position.y);
  int _699 = _697 & 63;
  int _700 = _698 & 63;
  float4 _702 = t1.Load(int4(_699, _700, _696, 0));
  float4 _705 = t2.Load(int4(_699, _700, _696, 0));
  float _708 = _702.x * _691;
  float _709 = _705.x * _692;
  float _710 = _705.y * _693;
  float _711 = _708 + _673;
  float _712 = _709 + _674;
  float _713 = _710 + _675;
  SV_Target.x = _711;
  SV_Target.y = _712;
  SV_Target.z = _713;
  SV_Target.w = _369;
  return SV_Target;
}
