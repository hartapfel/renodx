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

Texture2D<float4> t9 : register(t9);

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
  float4 SV_Target = 0;
  float4 _32 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _38 = t16.Sample(s1, float2(TEXCOORD.z, TEXCOORD.w));
  float _40 = _38.y * 0.10000000149011612f;
  float _41 = _40 + _32.y;
  float _42 = _38.y * 0.5f;
  float _43 = _42 + _32.z;
  float _44 = exp2(_43);
  float _45 = _44 + -1.0f;
  float _48 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _45;
  float _49 = _48 + 1.0f;
  float _50 = log2(_49);
  float _51 = _32.x + TEXCOORD.z;
  float _52 = _41 + TEXCOORD.w;
  float _53 = _32.x + TEXCOORD.x;
  float _54 = _41 + TEXCOORD.y;
  float _55 = _50 + 1.0f;
  float _56 = log2(_55);
  float4 _59 = t0.SampleLevel(s1, float2(_51, _52), _56);
  bool _64 = (_56 > 0.0f);
  float _369;
  float _370;
  float _371;
  float _372;
  float _419;
  float _420;
  float _421;
  float _426;
  float _427;
  float _428;
  float _457;
  float _458;
  float _459;
  float _464;
  float _465;
  float _466;
  float _574;
  float _646;
  float _655;
  float _664;
  float _712;
  float _713;
  float _714;
  [branch]
  if (_64) {
    float _66 = floor(_56);
    int _67 = int(_66);
    uint4 _68 = 0u; t0.GetDimensions(0u, _68.x, _68.y, _68.w);
    int _71 = _67 & 31;
    int _72 = (uint)(_68.x) >> _71;
    float _73 = float((uint)_72);
    int _74 = (uint)(_68.y) >> _71;
    float _75 = float((uint)_74);
    float _76 = 1.0f / _73;
    float _77 = 1.0f / _75;
    float _78 = _73 * _51;
    float _79 = _75 * _52;
    float _80 = _78 + -0.5f;
    float _81 = _79 + -0.5f;
    float _82 = frac(_80);
    float _83 = frac(_81);
    float _84 = floor(_80);
    float _85 = floor(_81);
    float _86 = 1.0f - _82;
    float _87 = 2.0f - _82;
    float _88 = 3.0f - _82;
    float _89 = _86 * _86;
    float _90 = _87 * _87;
    float _91 = _88 * _88;
    float _92 = _89 * _86;
    float _93 = _90 * _87;
    float _94 = _91 * _88;
    float _95 = _92 * 4.0f;
    float _96 = _93 - _95;
    float _97 = _93 * 4.0f;
    float _98 = _92 * 6.0f;
    float _99 = 6.0f - _92;
    float _100 = _99 - _96;
    float _101 = _97 - _94;
    float _102 = _101 - _98;
    float _103 = _102 + _100;
    float _104 = _96 * 0.1666666716337204f;
    float _105 = _103 * 0.1666666716337204f;
    float _106 = 1.0f - _83;
    float _107 = 2.0f - _83;
    float _108 = 3.0f - _83;
    float _109 = _106 * _106;
    float _110 = _107 * _107;
    float _111 = _108 * _108;
    float _112 = _109 * _106;
    float _113 = _110 * _107;
    float _114 = _111 * _108;
    float _115 = _112 * 4.0f;
    float _116 = _113 - _115;
    float _117 = _113 * 4.0f;
    float _118 = _112 * 6.0f;
    float _119 = 6.0f - _112;
    float _120 = _119 - _116;
    float _121 = _117 - _114;
    float _122 = _121 - _118;
    float _123 = _122 + _120;
    float _124 = _116 * 0.1666666716337204f;
    float _125 = _123 * 0.1666666716337204f;
    float _126 = _84 + -0.5f;
    float _127 = _84 + 1.5f;
    float _128 = _85 + -0.5f;
    float _129 = _85 + 1.5f;
    float _130 = _96 + _92;
    float _131 = _130 * 0.1666666716337204f;
    float _132 = _100 * 0.1666666716337204f;
    float _133 = _116 + _112;
    float _134 = _133 * 0.1666666716337204f;
    float _135 = _120 * 0.1666666716337204f;
    float _136 = _104 / _131;
    float _137 = _105 / _132;
    float _138 = _124 / _134;
    float _139 = _125 / _135;
    float _140 = _126 + _136;
    float _141 = _127 + _137;
    float _142 = _128 + _138;
    float _143 = _129 + _139;
    float _144 = _140 * _76;
    float _145 = _141 * _76;
    float _146 = _142 * _77;
    float _147 = _143 * _77;
    float _148 = float((int)(_67));
    float4 _150 = t0.SampleLevel(s0, float2(_144, _146), _148);
    float4 _155 = t0.SampleLevel(s0, float2(_145, _146), _148);
    float4 _160 = t0.SampleLevel(s0, float2(_144, _147), _148);
    float4 _165 = t0.SampleLevel(s0, float2(_145, _147), _148);
    float _170 = _150.x - _155.x;
    float _171 = _150.y - _155.y;
    float _172 = _150.z - _155.z;
    float _173 = _150.w - _155.w;
    float _174 = _170 * _131;
    float _175 = _171 * _131;
    float _176 = _172 * _131;
    float _177 = _173 * _131;
    float _178 = _174 + _155.x;
    float _179 = _175 + _155.y;
    float _180 = _176 + _155.z;
    float _181 = _177 + _155.w;
    float _182 = _160.x - _165.x;
    float _183 = _160.y - _165.y;
    float _184 = _160.z - _165.z;
    float _185 = _160.w - _165.w;
    float _186 = _182 * _131;
    float _187 = _183 * _131;
    float _188 = _184 * _131;
    float _189 = _185 * _131;
    float _190 = _186 + _165.x;
    float _191 = _187 + _165.y;
    float _192 = _188 + _165.z;
    float _193 = _189 + _165.w;
    float _194 = _178 - _190;
    float _195 = _179 - _191;
    float _196 = _180 - _192;
    float _197 = _181 - _193;
    float _198 = _194 * _134;
    float _199 = _195 * _134;
    float _200 = _196 * _134;
    float _201 = _197 * _134;
    float _202 = _198 + _190;
    float _203 = _199 + _191;
    float _204 = _200 + _192;
    float _205 = _201 + _193;
    float _206 = ceil(_56);
    int _207 = int(_206);
    int _208 = _207 & 31;
    int _209 = (uint)(_68.x) >> _208;
    float _210 = float((uint)_209);
    int _211 = (uint)(_68.y) >> _208;
    float _212 = float((uint)_211);
    float _213 = 1.0f / _210;
    float _214 = 1.0f / _212;
    float _215 = _210 * _51;
    float _216 = _212 * _52;
    float _217 = _215 + -0.5f;
    float _218 = _216 + -0.5f;
    float _219 = frac(_217);
    float _220 = frac(_218);
    float _221 = floor(_217);
    float _222 = floor(_218);
    float _223 = 1.0f - _219;
    float _224 = 2.0f - _219;
    float _225 = 3.0f - _219;
    float _226 = _223 * _223;
    float _227 = _224 * _224;
    float _228 = _225 * _225;
    float _229 = _226 * _223;
    float _230 = _227 * _224;
    float _231 = _228 * _225;
    float _232 = _229 * 4.0f;
    float _233 = _230 - _232;
    float _234 = _230 * 4.0f;
    float _235 = _229 * 6.0f;
    float _236 = 6.0f - _229;
    float _237 = _236 - _233;
    float _238 = _234 - _231;
    float _239 = _238 - _235;
    float _240 = _239 + _237;
    float _241 = _233 * 0.1666666716337204f;
    float _242 = _240 * 0.1666666716337204f;
    float _243 = 1.0f - _220;
    float _244 = 2.0f - _220;
    float _245 = 3.0f - _220;
    float _246 = _243 * _243;
    float _247 = _244 * _244;
    float _248 = _245 * _245;
    float _249 = _246 * _243;
    float _250 = _247 * _244;
    float _251 = _248 * _245;
    float _252 = _249 * 4.0f;
    float _253 = _250 - _252;
    float _254 = _250 * 4.0f;
    float _255 = _249 * 6.0f;
    float _256 = 6.0f - _249;
    float _257 = _256 - _253;
    float _258 = _254 - _251;
    float _259 = _258 - _255;
    float _260 = _259 + _257;
    float _261 = _253 * 0.1666666716337204f;
    float _262 = _260 * 0.1666666716337204f;
    float _263 = _221 + -0.5f;
    float _264 = _221 + 1.5f;
    float _265 = _222 + -0.5f;
    float _266 = _222 + 1.5f;
    float _267 = _233 + _229;
    float _268 = _267 * 0.1666666716337204f;
    float _269 = _237 * 0.1666666716337204f;
    float _270 = _253 + _249;
    float _271 = _270 * 0.1666666716337204f;
    float _272 = _257 * 0.1666666716337204f;
    float _273 = _241 / _268;
    float _274 = _242 / _269;
    float _275 = _261 / _271;
    float _276 = _262 / _272;
    float _277 = _263 + _273;
    float _278 = _264 + _274;
    float _279 = _265 + _275;
    float _280 = _266 + _276;
    float _281 = _277 * _213;
    float _282 = _278 * _213;
    float _283 = _279 * _214;
    float _284 = _280 * _214;
    float _285 = float((int)(_207));
    float4 _286 = t0.SampleLevel(s0, float2(_281, _283), _285);
    float4 _291 = t0.SampleLevel(s0, float2(_282, _283), _285);
    float4 _296 = t0.SampleLevel(s0, float2(_281, _284), _285);
    float4 _301 = t0.SampleLevel(s0, float2(_282, _284), _285);
    float _306 = _286.x - _291.x;
    float _307 = _286.y - _291.y;
    float _308 = _286.z - _291.z;
    float _309 = _286.w - _291.w;
    float _310 = _306 * _268;
    float _311 = _307 * _268;
    float _312 = _308 * _268;
    float _313 = _309 * _268;
    float _314 = _310 + _291.x;
    float _315 = _311 + _291.y;
    float _316 = _312 + _291.z;
    float _317 = _313 + _291.w;
    float _318 = _296.x - _301.x;
    float _319 = _296.y - _301.y;
    float _320 = _296.z - _301.z;
    float _321 = _296.w - _301.w;
    float _322 = _318 * _268;
    float _323 = _319 * _268;
    float _324 = _320 * _268;
    float _325 = _321 * _268;
    float _326 = _322 + _301.x;
    float _327 = _323 + _301.y;
    float _328 = _324 + _301.z;
    float _329 = _325 + _301.w;
    float _330 = _314 - _326;
    float _331 = _315 - _327;
    float _332 = _316 - _328;
    float _333 = _317 - _329;
    float _334 = _330 * _271;
    float _335 = _331 * _271;
    float _336 = _332 * _271;
    float _337 = _333 * _271;
    float _338 = frac(_56);
    float _339 = _326 - _202;
    float _340 = _339 + _334;
    float _341 = _327 - _203;
    float _342 = _341 + _335;
    float _343 = _328 - _204;
    float _344 = _343 + _336;
    float _345 = _329 - _205;
    float _346 = _345 + _337;
    float _347 = _340 * _338;
    float _348 = _342 * _338;
    float _349 = _344 * _338;
    float _350 = _346 * _338;
    float _351 = saturate(_56);
    float _352 = _202 - _59.x;
    float _353 = _352 + _347;
    float _354 = _203 - _59.y;
    float _355 = _354 + _348;
    float _356 = _204 - _59.z;
    float _357 = _356 + _349;
    float _358 = _205 - _59.w;
    float _359 = _358 + _350;
    float _360 = _353 * _351;
    float _361 = _355 * _351;
    float _362 = _357 * _351;
    float _363 = _359 * _351;
    float _364 = _360 + _59.x;
    float _365 = _361 + _59.y;
    float _366 = _362 + _59.z;
    float _367 = _363 + _59.w;
    _369 = _364;
    _370 = _365;
    _371 = _366;
    _372 = _367;
  } else {
    _369 = _59.x;
    _370 = _59.y;
    _371 = _59.z;
    _372 = _59.w;
  }
  float _373 = max(_369, 0.0f);
  float _374 = max(_370, 0.0f);
  float _375 = max(_371, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_373, _374, _375),
      float3(_373, _374, _375),
      float2(_51, _52),
      t0,
      s1,
      _56);
  _373 = renodx_chromatic_aberration_input.x;
  _374 = renodx_chromatic_aberration_input.y;
  _375 = renodx_chromatic_aberration_input.z;
  float4 _377 = t12.SampleLevel(s1, float2(_51, _52), 0.0f);
  float4 _383 = t8.Sample(s8, float2(_53, _54));
  int _389 = asint((User_000.UserConstant_Z_000[3].z));
  bool _390 = ((int)_389 > (int)0);
  if (!_390) {
    bool _394 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _398 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _383.x;
    float _399 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _383.y;
    float _400 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _383.z;
    float _401 = _398 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _402 = _399 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _403 = _400 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_394) {
      float _405 = _401 * _377.x;
      float _406 = _402 * _377.y;
      float _407 = _403 * _377.z;
      _419 = _405;
      _420 = _406;
      _421 = _407;
    } else {
      float _409 = saturate(_401);
      float _410 = saturate(_402);
      float _411 = saturate(_403);
      float _412 = _377.x - _373;
      float _413 = _377.y - _374;
      float _414 = _377.z - _375;
      float _415 = _409 * _412;
      float _416 = _410 * _413;
      float _417 = _411 * _414;
      _419 = _415;
      _420 = _416;
      _421 = _417;
    }
    float _422 = _419 + _373;
    float _423 = _420 + _374;
    float _424 = _421 + _375;
    _426 = _422;
    _427 = _423;
    _428 = _424;
  } else {
    _426 = _373;
    _427 = _374;
    _428 = _375;
  }
  if (_390) {
    bool _432 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _436 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _383.x;
    float _437 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _383.y;
    float _438 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _383.z;
    float _439 = _436 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _440 = _437 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _441 = _438 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_432) {
      float _443 = _439 * _377.x;
      float _444 = _440 * _377.y;
      float _445 = _441 * _377.z;
      _457 = _443;
      _458 = _444;
      _459 = _445;
    } else {
      float _447 = saturate(_439);
      float _448 = saturate(_440);
      float _449 = saturate(_441);
      float _450 = _377.x - _426;
      float _451 = _377.y - _427;
      float _452 = _377.z - _428;
      float _453 = _447 * _450;
      float _454 = _448 * _451;
      float _455 = _449 * _452;
      _457 = _453;
      _458 = _454;
      _459 = _455;
    }
    float _460 = _457 + _426;
    float _461 = _458 + _427;
    float _462 = _459 + _428;
    _464 = _460;
    _465 = _461;
    _466 = _462;
  } else {
    _464 = _426;
    _465 = _427;
    _466 = _428;
  }
  float4 _470 = t17.Load(int3(0, 0, 0));
  float _479 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 335.718017578125f;
  float _480 = _470.x * _479;
  float _481 = _480 * _464;
  float _482 = _481 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _483 = _480 * _465;
  float _484 = _483 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _485 = _480 * _466;
  float _486 = _485 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _487 = _482 + 1.0f;
  float _488 = _484 + 1.0f;
  float _489 = _486 + 1.0f;
  float _490 = log2(_487);
  float _491 = log2(_488);
  float _492 = log2(_489);
  float _493 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _494 = _493 * _490;
  float _495 = _493 * _491;
  float _496 = _492 * _493;
  float _497 = _494 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _498 = _495 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _499 = _496 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _502 = t3.Sample(s3, float3(_497, _498, _499));
  float _506 = _502.x * 13.450128555297852f;
  float _507 = _502.y * 13.450128555297852f;
  float _508 = _502.z * 13.450128555297852f;
  float _509 = exp2(_506);
  float _510 = exp2(_507);
  float _511 = exp2(_508);
  float _512 = _509 + -1.0f;
  float _513 = _510 + -1.0f;
  float _514 = _511 + -1.0f;
  float _515 = _512 * 0.0029786902014166117f;
  float _516 = _513 * 0.0029786902014166117f;
  float _517 = _514 * 0.0029786902014166117f;
  float _522 = _515 * (User_000.UserConstant_Z_000[4].x);
  float _523 = _516 * (User_000.UserConstant_Z_000[4].y);
  float _524 = _517 * (User_000.UserConstant_Z_000[4].z);
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_482, _484, _486) * 0.0029786902014166117f,
      float3(_522, _523, _524),
      User_000.UserConstant_Z_000[4].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(
      apt_scaled_lut_output,
      SV_Position.xy);
  _522 = apt_scaled_lut_output.x;
  _523 = apt_scaled_lut_output.y;
  _524 = apt_scaled_lut_output.z;
  float _530 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _531 = _530 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _532 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _533 = _532 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _536 = _531 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _537 = _533 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _540 = t9.Sample(s9, float2(_536, _537));
  float _544 = dot(float3(_522, _523, _524), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _547 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _550 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _551 = select(_547, _550, 0);
  float _552 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _553 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _554 = uint(_552);
  uint _555 = uint(_553);
  int _556 = _554 & 63;
  int _557 = _555 & 63;
  float4 _559 = t2.Load(int4(_556, _557, _551, 0));
  bool _561 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_561) {
    float _563 = _552 * 0.015625f;
    float _564 = _553 * 0.015625f;
    float _565 = float((uint)_550);
    float _566 = select(_547, _565, 0.0f);
    float4 _568 = t2.SampleLevel(s2, float3(_563, _564, _566), 0.0f);
    float _570 = _559.y - _568.y;
    float _571 = _570 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _572 = _571 + _568.y;
    _574 = _572;
  } else {
    _574 = _559.y;
  }
  float _575 = _540.x * -2.0f;
  float _576 = _575 * _574;
  float _577 = _574 * 2.0f;
  float _578 = _577 * _540.y;
  float _579 = _577 * _540.z;
  float _580 = _576 + _540.x;
  float _581 = _578 - _540.y;
  float _582 = _579 - _540.z;
  float _583 = _580 * _540.x;
  float _584 = _581 * _540.y;
  float _585 = _582 * _540.z;
  float _586 = _544 + 1.0f;
  float _587 = _544 / _586;
  float _588 = _587 + -9.999999747378752e-05f;
  float _589 = _588 * 1111.111083984375f;
  float _590 = saturate(_589);
  float _591 = _590 * 2.0f;
  float _592 = 3.0f - _591;
  float _593 = _590 * _590;
  float _594 = _593 * _592;
  bool _596 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _597 = float((bool)_596);
  float _598 = dot(float3(_583, _584, _585), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _599 = _598 - _583;
  float _600 = _598 - _584;
  float _601 = _598 - _585;
  float _602 = _599 * _597;
  float _603 = _600 * _597;
  float _604 = _601 * _597;
  float _605 = _602 + _583;
  float _606 = _603 + _584;
  float _607 = _604 + _585;
  float _611 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _612 = _611 * _587;
  float _613 = _612 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _614 = _594 * _613;
  float _615 = _614 * _605;
  float _616 = _614 * _606;
  float _617 = _614 * _607;
  float _618 = _615 + _522;
  float _619 = _616 + _523;
  float _620 = _617 + _524;
  float _621 = max(0.0f, _618);
  float _622 = max(0.0f, _619);
  float _623 = max(0.0f, _620);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_621, _622, _623),
      apt_scaled_lut_output);
  _621 = apt_film_grain_output.x;
  _622 = apt_film_grain_output.y;
  _623 = apt_film_grain_output.z;
  bool _626 = !((PostProcess_000.PostProcessConstant_Z_000[17].x) == 0.0f);
  if (_626) {
    float _635 = _621 * (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _636 = _622 * (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _637 = _623 * (PostProcess_000.PostProcessConstant_Z_000[10].w);
    bool _638 = (_635 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_638) {
      float _640 = _635 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _641 = 1.0f - _640;
      float _642 = _641 * _641;
      float _643 = _642 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _644 = _643 + _635;
      _646 = _644;
    } else {
      _646 = _635;
    }
    bool _647 = (_636 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_647) {
      float _649 = _636 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _650 = 1.0f - _649;
      float _651 = _650 * _650;
      float _652 = _651 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _653 = _652 + _636;
      _655 = _653;
    } else {
      _655 = _636;
    }
    bool _656 = (_637 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_656) {
      float _658 = _637 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _659 = 1.0f - _658;
      float _660 = _659 * _659;
      float _661 = _660 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _662 = _661 + _637;
      _664 = _662;
    } else {
      _664 = _637;
    }
    float _665 = _646 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _666 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
    float _667 = log2(_665);
    float _668 = _667 * _666;
    float _669 = exp2(_668);
    float _670 = _669 + -1.0f;
    float _671 = _665 + -1.0f;
    float _672 = _670 / _671;
    bool _673 = !(_665 == 1.0f);
    float _674 = _672 + -1.0f;
    float _675 = _674 / _672;
    float _676 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _677 = _676 / _666;
    float _678 = select(_673, _675, _677);
    float _679 = _678 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _680 = _655 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _681 = log2(_680);
    float _682 = _681 * _666;
    float _683 = exp2(_682);
    float _684 = _683 + -1.0f;
    float _685 = _680 + -1.0f;
    float _686 = _684 / _685;
    bool _687 = !(_680 == 1.0f);
    float _688 = _686 + -1.0f;
    float _689 = _688 / _686;
    float _690 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _691 = _690 / _666;
    float _692 = select(_687, _689, _691);
    float _693 = _692 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _694 = _664 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _695 = log2(_694);
    float _696 = _695 * _666;
    float _697 = exp2(_696);
    float _698 = _697 + -1.0f;
    float _699 = _694 + -1.0f;
    float _700 = _698 / _699;
    bool _701 = !(_694 == 1.0f);
    float _702 = _700 + -1.0f;
    float _703 = _702 / _700;
    float _704 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _705 = _704 / _666;
    float _706 = select(_701, _703, _705);
    float _707 = _706 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _708 = _679 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _709 = _693 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _710 = _707 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    _712 = _708;
    _713 = _709;
    _714 = _710;
  } else {
    _712 = _621;
    _713 = _622;
    _714 = _623;
  }
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_621, _622, _623),
      float3(_712, _713, _714),
      false);
  _712 = apt_post_process_output.x;
  _713 = apt_post_process_output.y;
  _714 = apt_post_process_output.z;
  float _715 = log2(_712);
  float _716 = log2(_713);
  float _717 = log2(_714);
  float _718 = _715 * 0.4166666567325592f;
  float _719 = _716 * 0.4166666567325592f;
  float _720 = _717 * 0.4166666567325592f;
  float _721 = exp2(_718);
  float _722 = exp2(_719);
  float _723 = exp2(_720);
  float _724 = _721 * 1.0549999475479126f;
  float _725 = _722 * 1.0549999475479126f;
  float _726 = _723 * 1.0549999475479126f;
  float _727 = _724 + -0.054999999701976776f;
  float _728 = _725 + -0.054999999701976776f;
  float _729 = _726 + -0.054999999701976776f;
  float _730 = _712 * 12.920000076293945f;
  float _731 = _713 * 12.920000076293945f;
  float _732 = _714 * 12.920000076293945f;
  bool _733 = (_712 <= 0.0031308000907301903f);
  bool _734 = (_713 <= 0.0031308000907301903f);
  bool _735 = (_714 <= 0.0031308000907301903f);
  float _736 = select(_733, _730, _727);
  float _737 = select(_734, _731, _728);
  float _738 = select(_735, _732, _729);
  float _739 = log2(_736);
  float _740 = log2(_737);
  float _741 = log2(_738);
  float _742 = floor(_739);
  float _743 = floor(_740);
  float _744 = floor(_741);
  float _745 = _742 + -6.0f;
  float _746 = _743 + -6.0f;
  float _747 = _744 + -5.0f;
  float _748 = exp2(_745);
  float _749 = exp2(_746);
  float _750 = exp2(_747);
  bool _751 = (_736 <= 0.0f);
  bool _752 = (_737 <= 0.0f);
  bool _753 = (_738 <= 0.0f);
  float _754 = select(_751, 0.0f, _748);
  float _755 = select(_752, 0.0f, _749);
  float _756 = select(_753, 0.0f, _750);
  uint _757 = uint(SV_Position.x);
  uint _758 = uint(SV_Position.y);
  int _759 = _757 & 63;
  int _760 = _758 & 63;
  float4 _762 = t1.Load(int4(_759, _760, _550, 0));
  float4 _764 = t2.Load(int4(_759, _760, _550, 0));
  float _767 = _762.x * _754;
  float _768 = _764.x * _755;
  float _769 = _764.y * _756;
  float _770 = _767 + _736;
  float _771 = _768 + _737;
  float _772 = _769 + _738;
  SV_Target.x = _770;
  SV_Target.y = _771;
  SV_Target.z = _772;
  SV_Target.w = _372;
  return SV_Target;
}
