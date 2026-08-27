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

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _26 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _32 = t16.Sample(s1, float2(TEXCOORD.z, TEXCOORD.w));
  float _34 = _32.y * 0.10000000149011612f;
  float _35 = _32.y * 0.5f;
  float _36 = _35 + _26.z;
  float _37 = exp2(_36);
  float _38 = _37 + -1.0f;
  float _41 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _38;
  float _42 = _41 + 1.0f;
  float _43 = log2(_42);
  float _44 = _26.x + TEXCOORD.z;
  float _45 = _26.y + TEXCOORD.w;
  float _46 = _45 + _34;
  float _47 = _43 + 1.0f;
  float _48 = log2(_47);
  float4 _50 = t0.SampleLevel(s1, float2(_44, _46), _48);
  bool _55 = (_48 > 0.0f);
  float _360;
  float _361;
  float _362;
  float _363;
  [branch]
  if (_55) {
    float _57 = floor(_48);
    int _58 = int(_57);
    uint2 _59; t0.GetDimensions(_59.x, _59.y);
    int _62 = _58 & 31;
    int _63 = (uint)(_59.x) >> _62;
    float _64 = float((uint)_63);
    int _65 = (uint)(_59.y) >> _62;
    float _66 = float((uint)_65);
    float _67 = 1.0f / _64;
    float _68 = 1.0f / _66;
    float _69 = _64 * _44;
    float _70 = _66 * _46;
    float _71 = _69 + -0.5f;
    float _72 = _70 + -0.5f;
    float _73 = frac(_71);
    float _74 = frac(_72);
    float _75 = floor(_71);
    float _76 = floor(_72);
    float _77 = 1.0f - _73;
    float _78 = 2.0f - _73;
    float _79 = 3.0f - _73;
    float _80 = _77 * _77;
    float _81 = _78 * _78;
    float _82 = _79 * _79;
    float _83 = _80 * _77;
    float _84 = _81 * _78;
    float _85 = _82 * _79;
    float _86 = _83 * 4.0f;
    float _87 = _84 - _86;
    float _88 = _84 * 4.0f;
    float _89 = _83 * 6.0f;
    float _90 = 6.0f - _83;
    float _91 = _90 - _87;
    float _92 = _88 - _85;
    float _93 = _92 - _89;
    float _94 = _93 + _91;
    float _95 = _87 * 0.1666666716337204f;
    float _96 = _94 * 0.1666666716337204f;
    float _97 = 1.0f - _74;
    float _98 = 2.0f - _74;
    float _99 = 3.0f - _74;
    float _100 = _97 * _97;
    float _101 = _98 * _98;
    float _102 = _99 * _99;
    float _103 = _100 * _97;
    float _104 = _101 * _98;
    float _105 = _102 * _99;
    float _106 = _103 * 4.0f;
    float _107 = _104 - _106;
    float _108 = _104 * 4.0f;
    float _109 = _103 * 6.0f;
    float _110 = 6.0f - _103;
    float _111 = _110 - _107;
    float _112 = _108 - _105;
    float _113 = _112 - _109;
    float _114 = _113 + _111;
    float _115 = _107 * 0.1666666716337204f;
    float _116 = _114 * 0.1666666716337204f;
    float _117 = _75 + -0.5f;
    float _118 = _75 + 1.5f;
    float _119 = _76 + -0.5f;
    float _120 = _76 + 1.5f;
    float _121 = _87 + _83;
    float _122 = _121 * 0.1666666716337204f;
    float _123 = _91 * 0.1666666716337204f;
    float _124 = _107 + _103;
    float _125 = _124 * 0.1666666716337204f;
    float _126 = _111 * 0.1666666716337204f;
    float _127 = _95 / _122;
    float _128 = _96 / _123;
    float _129 = _115 / _125;
    float _130 = _116 / _126;
    float _131 = _117 + _127;
    float _132 = _118 + _128;
    float _133 = _119 + _129;
    float _134 = _120 + _130;
    float _135 = _131 * _67;
    float _136 = _132 * _67;
    float _137 = _133 * _68;
    float _138 = _134 * _68;
    float _139 = float((int)(_58));
    float4 _141 = t0.SampleLevel(s0, float2(_135, _137), _139);
    float4 _146 = t0.SampleLevel(s0, float2(_136, _137), _139);
    float4 _151 = t0.SampleLevel(s0, float2(_135, _138), _139);
    float4 _156 = t0.SampleLevel(s0, float2(_136, _138), _139);
    float _161 = _141.x - _146.x;
    float _162 = _141.y - _146.y;
    float _163 = _141.z - _146.z;
    float _164 = _141.w - _146.w;
    float _165 = _161 * _122;
    float _166 = _162 * _122;
    float _167 = _163 * _122;
    float _168 = _164 * _122;
    float _169 = _165 + _146.x;
    float _170 = _166 + _146.y;
    float _171 = _167 + _146.z;
    float _172 = _168 + _146.w;
    float _173 = _151.x - _156.x;
    float _174 = _151.y - _156.y;
    float _175 = _151.z - _156.z;
    float _176 = _151.w - _156.w;
    float _177 = _173 * _122;
    float _178 = _174 * _122;
    float _179 = _175 * _122;
    float _180 = _176 * _122;
    float _181 = _177 + _156.x;
    float _182 = _178 + _156.y;
    float _183 = _179 + _156.z;
    float _184 = _180 + _156.w;
    float _185 = _169 - _181;
    float _186 = _170 - _182;
    float _187 = _171 - _183;
    float _188 = _172 - _184;
    float _189 = _185 * _125;
    float _190 = _186 * _125;
    float _191 = _187 * _125;
    float _192 = _188 * _125;
    float _193 = _189 + _181;
    float _194 = _190 + _182;
    float _195 = _191 + _183;
    float _196 = _192 + _184;
    float _197 = ceil(_48);
    int _198 = int(_197);
    int _199 = _198 & 31;
    int _200 = (uint)(_59.x) >> _199;
    float _201 = float((uint)_200);
    int _202 = (uint)(_59.y) >> _199;
    float _203 = float((uint)_202);
    float _204 = 1.0f / _201;
    float _205 = 1.0f / _203;
    float _206 = _201 * _44;
    float _207 = _203 * _46;
    float _208 = _206 + -0.5f;
    float _209 = _207 + -0.5f;
    float _210 = frac(_208);
    float _211 = frac(_209);
    float _212 = floor(_208);
    float _213 = floor(_209);
    float _214 = 1.0f - _210;
    float _215 = 2.0f - _210;
    float _216 = 3.0f - _210;
    float _217 = _214 * _214;
    float _218 = _215 * _215;
    float _219 = _216 * _216;
    float _220 = _217 * _214;
    float _221 = _218 * _215;
    float _222 = _219 * _216;
    float _223 = _220 * 4.0f;
    float _224 = _221 - _223;
    float _225 = _221 * 4.0f;
    float _226 = _220 * 6.0f;
    float _227 = 6.0f - _220;
    float _228 = _227 - _224;
    float _229 = _225 - _222;
    float _230 = _229 - _226;
    float _231 = _230 + _228;
    float _232 = _224 * 0.1666666716337204f;
    float _233 = _231 * 0.1666666716337204f;
    float _234 = 1.0f - _211;
    float _235 = 2.0f - _211;
    float _236 = 3.0f - _211;
    float _237 = _234 * _234;
    float _238 = _235 * _235;
    float _239 = _236 * _236;
    float _240 = _237 * _234;
    float _241 = _238 * _235;
    float _242 = _239 * _236;
    float _243 = _240 * 4.0f;
    float _244 = _241 - _243;
    float _245 = _241 * 4.0f;
    float _246 = _240 * 6.0f;
    float _247 = 6.0f - _240;
    float _248 = _247 - _244;
    float _249 = _245 - _242;
    float _250 = _249 - _246;
    float _251 = _250 + _248;
    float _252 = _244 * 0.1666666716337204f;
    float _253 = _251 * 0.1666666716337204f;
    float _254 = _212 + -0.5f;
    float _255 = _212 + 1.5f;
    float _256 = _213 + -0.5f;
    float _257 = _213 + 1.5f;
    float _258 = _224 + _220;
    float _259 = _258 * 0.1666666716337204f;
    float _260 = _228 * 0.1666666716337204f;
    float _261 = _244 + _240;
    float _262 = _261 * 0.1666666716337204f;
    float _263 = _248 * 0.1666666716337204f;
    float _264 = _232 / _259;
    float _265 = _233 / _260;
    float _266 = _252 / _262;
    float _267 = _253 / _263;
    float _268 = _254 + _264;
    float _269 = _255 + _265;
    float _270 = _256 + _266;
    float _271 = _257 + _267;
    float _272 = _268 * _204;
    float _273 = _269 * _204;
    float _274 = _270 * _205;
    float _275 = _271 * _205;
    float _276 = float((int)(_198));
    float4 _277 = t0.SampleLevel(s0, float2(_272, _274), _276);
    float4 _282 = t0.SampleLevel(s0, float2(_273, _274), _276);
    float4 _287 = t0.SampleLevel(s0, float2(_272, _275), _276);
    float4 _292 = t0.SampleLevel(s0, float2(_273, _275), _276);
    float _297 = _277.x - _282.x;
    float _298 = _277.y - _282.y;
    float _299 = _277.z - _282.z;
    float _300 = _277.w - _282.w;
    float _301 = _297 * _259;
    float _302 = _298 * _259;
    float _303 = _299 * _259;
    float _304 = _300 * _259;
    float _305 = _301 + _282.x;
    float _306 = _302 + _282.y;
    float _307 = _303 + _282.z;
    float _308 = _304 + _282.w;
    float _309 = _287.x - _292.x;
    float _310 = _287.y - _292.y;
    float _311 = _287.z - _292.z;
    float _312 = _287.w - _292.w;
    float _313 = _309 * _259;
    float _314 = _310 * _259;
    float _315 = _311 * _259;
    float _316 = _312 * _259;
    float _317 = _313 + _292.x;
    float _318 = _314 + _292.y;
    float _319 = _315 + _292.z;
    float _320 = _316 + _292.w;
    float _321 = _305 - _317;
    float _322 = _306 - _318;
    float _323 = _307 - _319;
    float _324 = _308 - _320;
    float _325 = _321 * _262;
    float _326 = _322 * _262;
    float _327 = _323 * _262;
    float _328 = _324 * _262;
    float _329 = frac(_48);
    float _330 = _317 - _193;
    float _331 = _330 + _325;
    float _332 = _318 - _194;
    float _333 = _332 + _326;
    float _334 = _319 - _195;
    float _335 = _334 + _327;
    float _336 = _320 - _196;
    float _337 = _336 + _328;
    float _338 = _331 * _329;
    float _339 = _333 * _329;
    float _340 = _335 * _329;
    float _341 = _337 * _329;
    float _342 = saturate(_48);
    float _343 = _193 - _50.x;
    float _344 = _343 + _338;
    float _345 = _194 - _50.y;
    float _346 = _345 + _339;
    float _347 = _195 - _50.z;
    float _348 = _347 + _340;
    float _349 = _196 - _50.w;
    float _350 = _349 + _341;
    float _351 = _344 * _342;
    float _352 = _346 * _342;
    float _353 = _348 * _342;
    float _354 = _350 * _342;
    float _355 = _351 + _50.x;
    float _356 = _352 + _50.y;
    float _357 = _353 + _50.z;
    float _358 = _354 + _50.w;
    _360 = _355;
    _361 = _356;
    _362 = _357;
    _363 = _358;
  } else {
    _360 = _50.x;
    _361 = _50.y;
    _362 = _50.z;
    _363 = _50.w;
  }
  float _364 = max(_360, 0.0f);
  float _365 = max(_361, 0.0f);
  float _366 = max(_362, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_364, _365, _366),
      float3(_364, _365, _366),
      float2(_44, _46),
      t0,
      s1,
      _48);
  _364 = renodx_chromatic_aberration_input.x;
  _365 = renodx_chromatic_aberration_input.y;
  _366 = renodx_chromatic_aberration_input.z;
  float4 _370 = t17.Load(int3(0, 0, 0));
  float _379 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 335.718017578125f;
  float _380 = _370.x * _379;
  float _381 = _380 * _364;
  float _382 = _381 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _383 = _380 * _365;
  float _384 = _383 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _385 = _380 * _366;
  float _386 = _385 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _387 = _382 + 1.0f;
  float _388 = _384 + 1.0f;
  float _389 = _386 + 1.0f;
  float _390 = log2(_387);
  float _391 = log2(_388);
  float _392 = log2(_389);
  float _393 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _394 = _393 * _390;
  float _395 = _393 * _391;
  float _396 = _392 * _393;
  float _397 = _394 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _398 = _395 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _399 = _396 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _402 = t3.Sample(s3, float3(_397, _398, _399));
  float _406 = _402.x * 13.450128555297852f;
  float _407 = _402.y * 13.450128555297852f;
  float _408 = _402.z * 13.450128555297852f;
  float _409 = exp2(_406);
  float _410 = exp2(_407);
  float _411 = exp2(_408);
  float _412 = _409 + -1.0f;
  float _413 = _410 + -1.0f;
  float _414 = _411 + -1.0f;
  float _415 = _412 * 0.0029786902014166117f;
  float _416 = _413 * 0.0029786902014166117f;
  float _417 = _414 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_382 * 0.0029786902014166117f, _384 * 0.0029786902014166117f, _386 * 0.0029786902014166117f),
      float3(_415 * (User_000.UserConstant_Z_000[4].x), _416 * (User_000.UserConstant_Z_000[4].y), _417 * (User_000.UserConstant_Z_000[4].z)),
      User_000.UserConstant_Z_000[4].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(apt_scaled_lut_output, SV_Position.xy);
  float _437;
  float _450;
  float _463;
  [branch]
  if (!APTIsPsychoV()) {
    float _424 = apt_scaled_lut_output.x;
    float _425 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
    float _426 = log2(_424);
    float _427 = _425 * _426;
    float _428 = exp2(_427);
    float _429 = _428 + -1.0f;
    float _430 = _424 + -1.0f;
    float _431 = _429 / _430;
    bool _432 = !(_424 == 1.0f);
    float _433 = _431 + -1.0f;
    float _434 = _433 / _431;
    float _435 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _436 = _435 / _425;
    _437 = select(_432, _434, _436);
    float _438 = apt_scaled_lut_output.y;
    float _439 = log2(_438);
    float _440 = _439 * _425;
    float _441 = exp2(_440);
    float _442 = _441 + -1.0f;
    float _443 = _438 + -1.0f;
    float _444 = _442 / _443;
    bool _445 = !(_438 == 1.0f);
    float _446 = _444 + -1.0f;
    float _447 = _446 / _444;
    float _448 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _449 = _448 / _425;
    _450 = select(_445, _447, _449);
    float _451 = apt_scaled_lut_output.z;
    float _452 = log2(_451);
    float _453 = _452 * _425;
    float _454 = exp2(_453);
    float _455 = _454 + -1.0f;
    float _456 = _451 + -1.0f;
    float _457 = _455 / _456;
    bool _458 = !(_451 == 1.0f);
    float _459 = _457 + -1.0f;
    float _460 = _459 / _457;
    float _461 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _462 = _461 / _425;
    _463 = select(_458, _460, _462);
  } else {
    _437 = 0.f;
    _450 = 0.f;
    _463 = 0.f;
  }
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      apt_scaled_lut_output,
      float3(_437, _450, _463),
      true);
  float _464 = apt_post_process_output.x;
  float _465 = apt_post_process_output.y;
  float _466 = apt_post_process_output.z;
  float _467 = log2(_464);
  float _468 = log2(_465);
  float _469 = log2(_466);
  float _470 = _467 * 0.4166666567325592f;
  float _471 = _468 * 0.4166666567325592f;
  float _472 = _469 * 0.4166666567325592f;
  float _473 = exp2(_470);
  float _474 = exp2(_471);
  float _475 = exp2(_472);
  float _476 = _473 * 1.0549999475479126f;
  float _477 = _474 * 1.0549999475479126f;
  float _478 = _475 * 1.0549999475479126f;
  float _479 = _476 + -0.054999999701976776f;
  float _480 = _477 + -0.054999999701976776f;
  float _481 = _478 + -0.054999999701976776f;
  float _482 = _464 * 12.920000076293945f;
  float _483 = _465 * 12.920000076293945f;
  float _484 = _466 * 12.920000076293945f;
  bool _485 = (_464 <= 0.0031308000907301903f);
  bool _486 = (_465 <= 0.0031308000907301903f);
  bool _487 = (_466 <= 0.0031308000907301903f);
  float _488 = select(_485, _482, _479);
  float _489 = select(_486, _483, _480);
  float _490 = select(_487, _484, _481);
  float _491 = log2(_488);
  float _492 = log2(_489);
  float _493 = log2(_490);
  float _494 = floor(_491);
  float _495 = floor(_492);
  float _496 = floor(_493);
  float _497 = _494 + -6.0f;
  float _498 = _495 + -6.0f;
  float _499 = _496 + -5.0f;
  float _500 = exp2(_497);
  float _501 = exp2(_498);
  float _502 = exp2(_499);
  bool _503 = (_488 <= 0.0f);
  bool _504 = (_489 <= 0.0f);
  bool _505 = (_490 <= 0.0f);
  float _506 = select(_503, 0.0f, _500);
  float _507 = select(_504, 0.0f, _501);
  float _508 = select(_505, 0.0f, _502);
  int _511 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _512 = uint(SV_Position.x);
  uint _513 = uint(SV_Position.y);
  int _514 = _512 & 63;
  int _515 = _513 & 63;
  float4 _517 = t1.Load(int4(_514, _515, _511, 0));
  float4 _520 = t2.Load(int4(_514, _515, _511, 0));
  float _523 = _517.x * _506;
  float _524 = _520.x * _507;
  float _525 = _520.y * _508;
  float _526 = _523 + _488;
  float _527 = _524 + _489;
  float _528 = _525 + _490;
  SV_Target.x = _526;
  SV_Target.y = _527;
  SV_Target.z = _528;
  SV_Target.w = _363;
  return SV_Target;
}
