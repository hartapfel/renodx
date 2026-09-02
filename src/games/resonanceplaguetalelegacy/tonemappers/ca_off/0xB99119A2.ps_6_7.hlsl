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
  GlobalCB_Z__ViewportConstant_Z GlobalCB_Z_1680;
  GlobalCB_Z__AnchorConstant_Z GlobalCB_Z_1776;
  GlobalCB_Z__ViewConstant_Z GlobalCB_Z_2128;
  GlobalCB_Z__ProjConstant_Z GlobalCB_Z_2672;
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

Texture2D<float4> t15 : register(t15);

Texture2D<float4> t16 : register(t16);

Texture2D<float4> t17 : register(t17);

#include "../../common.hlsli"

cbuffer cb1 : register(b1) {
  GlobalCB_Z Global_000 : packoffset(c000.x);
  float4 cb1_raw[301] : packoffset(c0);
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

SamplerState s3 : register(s3);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _27 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _33 = t16.Sample(s1, float2(TEXCOORD.z, TEXCOORD.w));
  float _35 = _33.y * 0.10000000149011612f;
  float _36 = _33.y * 0.5f;
  float _37 = _36 + _27.z;
  float _38 = exp2(_37);
  float _39 = _38 + -1.0f;
  float _42 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _39;
  float _43 = _42 + 1.0f;
  float _44 = log2(_43);
  float _45 = _27.x + TEXCOORD.z;
  float _46 = _27.y + TEXCOORD.w;
  float _47 = _46 + _35;
  float _48 = _44 + 1.0f;
  float _49 = log2(_48);
  float4 _51 = t0.SampleLevel(s1, float2(_45, _47), _49);
  bool _56 = (_49 > 0.0f);
  float _361;
  float _362;
  float _363;
  float _364;
  float _602;
  float _706;
  float _810;
  float _813;
  float _814;
  float _815;
  float _826;
  float _951;
  float _952;
  float _953;
  float _1000;
  float _1001;
  float _1002;
  float _1016;
  float _1017;
  float _1018;
  [branch]
  if (_56) {
    float _58 = floor(_49);
    int _59 = int(_58);
    uint4 _60 = 0u; t0.GetDimensions(0u, _60.x, _60.y, _60.w);
    int _63 = _59 & 31;
    int _64 = (uint)(_60.x) >> _63;
    float _65 = float((uint)_64);
    int _66 = (uint)(_60.y) >> _63;
    float _67 = float((uint)_66);
    float _68 = 1.0f / _65;
    float _69 = 1.0f / _67;
    float _70 = _65 * _45;
    float _71 = _67 * _47;
    float _72 = _70 + -0.5f;
    float _73 = _71 + -0.5f;
    float _74 = frac(_72);
    float _75 = frac(_73);
    float _76 = floor(_72);
    float _77 = floor(_73);
    float _78 = 1.0f - _74;
    float _79 = 2.0f - _74;
    float _80 = 3.0f - _74;
    float _81 = _78 * _78;
    float _82 = _79 * _79;
    float _83 = _80 * _80;
    float _84 = _81 * _78;
    float _85 = _82 * _79;
    float _86 = _83 * _80;
    float _87 = _84 * 4.0f;
    float _88 = _85 - _87;
    float _89 = _85 * 4.0f;
    float _90 = _84 * 6.0f;
    float _91 = 6.0f - _84;
    float _92 = _91 - _88;
    float _93 = _89 - _86;
    float _94 = _93 - _90;
    float _95 = _94 + _92;
    float _96 = _88 * 0.1666666716337204f;
    float _97 = _95 * 0.1666666716337204f;
    float _98 = 1.0f - _75;
    float _99 = 2.0f - _75;
    float _100 = 3.0f - _75;
    float _101 = _98 * _98;
    float _102 = _99 * _99;
    float _103 = _100 * _100;
    float _104 = _101 * _98;
    float _105 = _102 * _99;
    float _106 = _103 * _100;
    float _107 = _104 * 4.0f;
    float _108 = _105 - _107;
    float _109 = _105 * 4.0f;
    float _110 = _104 * 6.0f;
    float _111 = 6.0f - _104;
    float _112 = _111 - _108;
    float _113 = _109 - _106;
    float _114 = _113 - _110;
    float _115 = _114 + _112;
    float _116 = _108 * 0.1666666716337204f;
    float _117 = _115 * 0.1666666716337204f;
    float _118 = _76 + -0.5f;
    float _119 = _76 + 1.5f;
    float _120 = _77 + -0.5f;
    float _121 = _77 + 1.5f;
    float _122 = _88 + _84;
    float _123 = _122 * 0.1666666716337204f;
    float _124 = _92 * 0.1666666716337204f;
    float _125 = _108 + _104;
    float _126 = _125 * 0.1666666716337204f;
    float _127 = _112 * 0.1666666716337204f;
    float _128 = _96 / _123;
    float _129 = _97 / _124;
    float _130 = _116 / _126;
    float _131 = _117 / _127;
    float _132 = _118 + _128;
    float _133 = _119 + _129;
    float _134 = _120 + _130;
    float _135 = _121 + _131;
    float _136 = _132 * _68;
    float _137 = _133 * _68;
    float _138 = _134 * _69;
    float _139 = _135 * _69;
    float _140 = float((int)(_59));
    float4 _142 = t0.SampleLevel(s0, float2(_136, _138), _140);
    float4 _147 = t0.SampleLevel(s0, float2(_137, _138), _140);
    float4 _152 = t0.SampleLevel(s0, float2(_136, _139), _140);
    float4 _157 = t0.SampleLevel(s0, float2(_137, _139), _140);
    float _162 = _142.x - _147.x;
    float _163 = _142.y - _147.y;
    float _164 = _142.z - _147.z;
    float _165 = _142.w - _147.w;
    float _166 = _162 * _123;
    float _167 = _163 * _123;
    float _168 = _164 * _123;
    float _169 = _165 * _123;
    float _170 = _166 + _147.x;
    float _171 = _167 + _147.y;
    float _172 = _168 + _147.z;
    float _173 = _169 + _147.w;
    float _174 = _152.x - _157.x;
    float _175 = _152.y - _157.y;
    float _176 = _152.z - _157.z;
    float _177 = _152.w - _157.w;
    float _178 = _174 * _123;
    float _179 = _175 * _123;
    float _180 = _176 * _123;
    float _181 = _177 * _123;
    float _182 = _178 + _157.x;
    float _183 = _179 + _157.y;
    float _184 = _180 + _157.z;
    float _185 = _181 + _157.w;
    float _186 = _170 - _182;
    float _187 = _171 - _183;
    float _188 = _172 - _184;
    float _189 = _173 - _185;
    float _190 = _186 * _126;
    float _191 = _187 * _126;
    float _192 = _188 * _126;
    float _193 = _189 * _126;
    float _194 = _190 + _182;
    float _195 = _191 + _183;
    float _196 = _192 + _184;
    float _197 = _193 + _185;
    float _198 = ceil(_49);
    int _199 = int(_198);
    int _200 = _199 & 31;
    int _201 = (uint)(_60.x) >> _200;
    float _202 = float((uint)_201);
    int _203 = (uint)(_60.y) >> _200;
    float _204 = float((uint)_203);
    float _205 = 1.0f / _202;
    float _206 = 1.0f / _204;
    float _207 = _202 * _45;
    float _208 = _204 * _47;
    float _209 = _207 + -0.5f;
    float _210 = _208 + -0.5f;
    float _211 = frac(_209);
    float _212 = frac(_210);
    float _213 = floor(_209);
    float _214 = floor(_210);
    float _215 = 1.0f - _211;
    float _216 = 2.0f - _211;
    float _217 = 3.0f - _211;
    float _218 = _215 * _215;
    float _219 = _216 * _216;
    float _220 = _217 * _217;
    float _221 = _218 * _215;
    float _222 = _219 * _216;
    float _223 = _220 * _217;
    float _224 = _221 * 4.0f;
    float _225 = _222 - _224;
    float _226 = _222 * 4.0f;
    float _227 = _221 * 6.0f;
    float _228 = 6.0f - _221;
    float _229 = _228 - _225;
    float _230 = _226 - _223;
    float _231 = _230 - _227;
    float _232 = _231 + _229;
    float _233 = _225 * 0.1666666716337204f;
    float _234 = _232 * 0.1666666716337204f;
    float _235 = 1.0f - _212;
    float _236 = 2.0f - _212;
    float _237 = 3.0f - _212;
    float _238 = _235 * _235;
    float _239 = _236 * _236;
    float _240 = _237 * _237;
    float _241 = _238 * _235;
    float _242 = _239 * _236;
    float _243 = _240 * _237;
    float _244 = _241 * 4.0f;
    float _245 = _242 - _244;
    float _246 = _242 * 4.0f;
    float _247 = _241 * 6.0f;
    float _248 = 6.0f - _241;
    float _249 = _248 - _245;
    float _250 = _246 - _243;
    float _251 = _250 - _247;
    float _252 = _251 + _249;
    float _253 = _245 * 0.1666666716337204f;
    float _254 = _252 * 0.1666666716337204f;
    float _255 = _213 + -0.5f;
    float _256 = _213 + 1.5f;
    float _257 = _214 + -0.5f;
    float _258 = _214 + 1.5f;
    float _259 = _225 + _221;
    float _260 = _259 * 0.1666666716337204f;
    float _261 = _229 * 0.1666666716337204f;
    float _262 = _245 + _241;
    float _263 = _262 * 0.1666666716337204f;
    float _264 = _249 * 0.1666666716337204f;
    float _265 = _233 / _260;
    float _266 = _234 / _261;
    float _267 = _253 / _263;
    float _268 = _254 / _264;
    float _269 = _255 + _265;
    float _270 = _256 + _266;
    float _271 = _257 + _267;
    float _272 = _258 + _268;
    float _273 = _269 * _205;
    float _274 = _270 * _205;
    float _275 = _271 * _206;
    float _276 = _272 * _206;
    float _277 = float((int)(_199));
    float4 _278 = t0.SampleLevel(s0, float2(_273, _275), _277);
    float4 _283 = t0.SampleLevel(s0, float2(_274, _275), _277);
    float4 _288 = t0.SampleLevel(s0, float2(_273, _276), _277);
    float4 _293 = t0.SampleLevel(s0, float2(_274, _276), _277);
    float _298 = _278.x - _283.x;
    float _299 = _278.y - _283.y;
    float _300 = _278.z - _283.z;
    float _301 = _278.w - _283.w;
    float _302 = _298 * _260;
    float _303 = _299 * _260;
    float _304 = _300 * _260;
    float _305 = _301 * _260;
    float _306 = _302 + _283.x;
    float _307 = _303 + _283.y;
    float _308 = _304 + _283.z;
    float _309 = _305 + _283.w;
    float _310 = _288.x - _293.x;
    float _311 = _288.y - _293.y;
    float _312 = _288.z - _293.z;
    float _313 = _288.w - _293.w;
    float _314 = _310 * _260;
    float _315 = _311 * _260;
    float _316 = _312 * _260;
    float _317 = _313 * _260;
    float _318 = _314 + _293.x;
    float _319 = _315 + _293.y;
    float _320 = _316 + _293.z;
    float _321 = _317 + _293.w;
    float _322 = _306 - _318;
    float _323 = _307 - _319;
    float _324 = _308 - _320;
    float _325 = _309 - _321;
    float _326 = _322 * _263;
    float _327 = _323 * _263;
    float _328 = _324 * _263;
    float _329 = _325 * _263;
    float _330 = frac(_49);
    float _331 = _318 - _194;
    float _332 = _331 + _326;
    float _333 = _319 - _195;
    float _334 = _333 + _327;
    float _335 = _320 - _196;
    float _336 = _335 + _328;
    float _337 = _321 - _197;
    float _338 = _337 + _329;
    float _339 = _332 * _330;
    float _340 = _334 * _330;
    float _341 = _336 * _330;
    float _342 = _338 * _330;
    float _343 = saturate(_49);
    float _344 = _194 - _51.x;
    float _345 = _344 + _339;
    float _346 = _195 - _51.y;
    float _347 = _346 + _340;
    float _348 = _196 - _51.z;
    float _349 = _348 + _341;
    float _350 = _197 - _51.w;
    float _351 = _350 + _342;
    float _352 = _345 * _343;
    float _353 = _347 * _343;
    float _354 = _349 * _343;
    float _355 = _351 * _343;
    float _356 = _352 + _51.x;
    float _357 = _353 + _51.y;
    float _358 = _354 + _51.z;
    float _359 = _355 + _51.w;
    _361 = _356;
    _362 = _357;
    _363 = _358;
    _364 = _359;
  } else {
    _361 = _51.x;
    _362 = _51.y;
    _363 = _51.z;
    _364 = _51.w;
  }
  float _365 = max(_361, 0.0f);
  float _366 = max(_362, 0.0f);
  float _367 = max(_363, 0.0f);
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
      float3(_365, _366, _367),
      float3(_365, _366, _367),
      float2(_45, _47),
      t0,
      s1,
      _49);
  _365 = renodx_chromatic_aberration_input.x;
  _366 = renodx_chromatic_aberration_input.y;
  _367 = renodx_chromatic_aberration_input.z;
  float4 _371 = t17.Load(int3(0, 0, 0));
  float _377 = _371.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _378 = _377 * _365;
  float _379 = _378 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _380 = _377 * _366;
  float _381 = _380 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _382 = _377 * _367;
  float _383 = _382 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _388 = _45 * 2.0f;
  float _389 = _47 * 2.0f;
  float _390 = _388 + -1.0f;
  float _391 = _389 + -1.0f;
  float _394 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _391;
  float _395 = _390 * _390;
  float _396 = _394 * _394;
  float _397 = _396 + _395;
  float _398 = sqrt(_397);
  float _400 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _398;
  float _402 = _400 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _403 = saturate(_402);
  float _405 = log2(_403);
  float _406 = _405 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _407 = ResonanceScaleVignetteMask(exp2(_406));
  float _408 = _379 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _409 = _381 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _410 = _383 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _411 = _408 - _379;
  float _412 = _409 - _381;
  float _413 = _410 - _383;
  float _414 = _407 * _411;
  float _415 = _407 * _412;
  float _416 = _407 * _413;
  float _417 = _414 + _379;
  float _418 = _415 + _381;
  float _419 = _416 + _383;
  float _422 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _423 = _422 * _417;
  float _424 = _422 * _418;
  float _425 = _422 * _419;
  float _426 = _423 + 1.0f;
  float _427 = _424 + 1.0f;
  float _428 = _425 + 1.0f;
  float _429 = log2(_426);
  float _430 = log2(_427);
  float _431 = log2(_428);
  float _434 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _435 = _434 * _429;
  float _436 = _434 * _430;
  float _437 = _434 * _431;
  float _439 = _435 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _440 = _436 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _441 = _437 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _444 = t3.Sample(s3, float3(_439, _440, _441));
  float _450 = _444.x * 13.450128555297852f;
  float _451 = _444.y * 13.450128555297852f;
  float _452 = _444.z * 13.450128555297852f;
  float _453 = exp2(_450);
  float _454 = exp2(_451);
  float _455 = exp2(_452);
  float _456 = _453 + -1.0f;
  float _457 = _454 + -1.0f;
  float _458 = _455 + -1.0f;
  float _459 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _460 = _459 * _456;
  float _461 = _459 * _457;
  float _462 = _459 * _458;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_423 * _459, _424 * _459, _425 * _459),
      float3(_460, _461, _462),
      1.f.xxx);
  _460 = resonance_scaled_lut_output.x;
  _461 = resonance_scaled_lut_output.y;
  _462 = resonance_scaled_lut_output.z;
  bool _465 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_465) {
    float _467 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _468 = _460 * _467;
    float _469 = _461 * _467;
    float _470 = _462 * _467;
    float _471 = _468 + 1.0f;
    float _472 = _469 + 1.0f;
    float _473 = _470 + 1.0f;
    float _474 = log2(_471);
    float _475 = log2(_472);
    float _476 = log2(_473);
    float _477 = _474 * 0.07434873282909393f;
    float _478 = _475 * 0.07434873282909393f;
    float _479 = _476 * 0.07434873282909393f;
    int _481 = asint((User_000.UserConstant_Z_000[3].y));
    int _482 = _481 & 1;
    bool _483 = (_482 == 0);
    if (!_483) {
      bool _500 = !(_477 <= (User_000.UserConstant_Z_000[4].x));
      if (!_500) {
        float _502 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _503 = _477 / _502;
        float _504 = _503 * (User_000.UserConstant_Z_000[4].y);
        float _505 = _503 * _503;
        float _506 = _505 * _503;
        float _507 = _506 - _503;
        float _508 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _509 = _502 * _502;
        float _510 = _509 * _508;
        float _511 = _510 * _507;
        float _512 = _511 + _504;
        _602 = _512;
      } else {
        bool _514 = !(_477 <= (User_000.UserConstant_Z_000[4].z));
        if (!_514) {
          float _516 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _517 = max(9.999999974752427e-07f, _516);
          float _518 = _477 - (User_000.UserConstant_Z_000[4].x);
          float _519 = _518 / _517;
          float _520 = 1.0f - _519;
          float _521 = _520 * (User_000.UserConstant_Z_000[4].y);
          float _522 = _519 * (User_000.UserConstant_Z_000[4].w);
          float _523 = _521 + _522;
          float _524 = _520 * _520;
          float _525 = _524 * _520;
          float _526 = _525 - _520;
          float _527 = _526 * (User_000.UserConstant_Z_000[10].x);
          float _528 = _519 * _519;
          float _529 = _528 * _519;
          float _530 = _529 - _519;
          float _531 = _530 * (User_000.UserConstant_Z_000[10].y);
          float _532 = _527 + _531;
          float _533 = _517 * _517;
          float _534 = _533 * 0.1666666716337204f;
          float _535 = _534 * _532;
          float _536 = _523 + _535;
          _602 = _536;
        } else {
          bool _538 = !(_477 <= (User_000.UserConstant_Z_000[9].x));
          if (!_538) {
            float _540 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _541 = max(9.999999974752427e-07f, _540);
            float _542 = _477 - (User_000.UserConstant_Z_000[4].z);
            float _543 = _542 / _541;
            float _544 = 1.0f - _543;
            float _545 = _544 * (User_000.UserConstant_Z_000[4].w);
            float _546 = _543 * (User_000.UserConstant_Z_000[9].y);
            float _547 = _545 + _546;
            float _548 = _544 * _544;
            float _549 = _548 * _544;
            float _550 = _549 - _544;
            float _551 = _550 * (User_000.UserConstant_Z_000[10].y);
            float _552 = _543 * _543;
            float _553 = _552 * _543;
            float _554 = _553 - _543;
            float _555 = _554 * (User_000.UserConstant_Z_000[10].z);
            float _556 = _551 + _555;
            float _557 = _541 * _541;
            float _558 = _557 * 0.1666666716337204f;
            float _559 = _558 * _556;
            float _560 = _547 + _559;
            _602 = _560;
          } else {
            bool _562 = !(_477 <= (User_000.UserConstant_Z_000[9].z));
            if (!_562) {
              float _564 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _565 = max(9.999999974752427e-07f, _564);
              float _566 = _477 - (User_000.UserConstant_Z_000[9].x);
              float _567 = _566 / _565;
              float _568 = 1.0f - _567;
              float _569 = _568 * (User_000.UserConstant_Z_000[9].y);
              float _570 = _567 * (User_000.UserConstant_Z_000[9].w);
              float _571 = _569 + _570;
              float _572 = _568 * _568;
              float _573 = _572 * _568;
              float _574 = _573 - _568;
              float _575 = _574 * (User_000.UserConstant_Z_000[10].z);
              float _576 = _567 * _567;
              float _577 = _576 * _567;
              float _578 = _577 - _567;
              float _579 = _578 * (User_000.UserConstant_Z_000[10].w);
              float _580 = _575 + _579;
              float _581 = _565 * _565;
              float _582 = _581 * 0.1666666716337204f;
              float _583 = _582 * _580;
              float _584 = _571 + _583;
              _602 = _584;
            } else {
              float _586 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _587 = _477 - (User_000.UserConstant_Z_000[9].z);
              float _588 = max(9.999999974752427e-07f, _586);
              float _589 = _587 / _588;
              float _590 = 1.0f - _589;
              float _591 = _590 * (User_000.UserConstant_Z_000[9].w);
              float _592 = _591 + _589;
              float _593 = _590 * _590;
              float _594 = _593 * _590;
              float _595 = _594 - _590;
              float _596 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _597 = _586 * _586;
              float _598 = _597 * _596;
              float _599 = _598 * _595;
              float _600 = _592 + _599;
              _602 = _600;
            }
          }
        }
      }
      float _603 = saturate(_602);
      bool _604 = !(_478 <= (User_000.UserConstant_Z_000[4].x));
      if (!_604) {
        float _606 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _607 = _478 / _606;
        float _608 = _607 * (User_000.UserConstant_Z_000[4].y);
        float _609 = _607 * _607;
        float _610 = _609 * _607;
        float _611 = _610 - _607;
        float _612 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _613 = _606 * _606;
        float _614 = _613 * _612;
        float _615 = _614 * _611;
        float _616 = _615 + _608;
        _706 = _616;
      } else {
        bool _618 = !(_478 <= (User_000.UserConstant_Z_000[4].z));
        if (!_618) {
          float _620 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _621 = max(9.999999974752427e-07f, _620);
          float _622 = _478 - (User_000.UserConstant_Z_000[4].x);
          float _623 = _622 / _621;
          float _624 = 1.0f - _623;
          float _625 = _624 * (User_000.UserConstant_Z_000[4].y);
          float _626 = _623 * (User_000.UserConstant_Z_000[4].w);
          float _627 = _625 + _626;
          float _628 = _624 * _624;
          float _629 = _628 * _624;
          float _630 = _629 - _624;
          float _631 = _630 * (User_000.UserConstant_Z_000[10].x);
          float _632 = _623 * _623;
          float _633 = _632 * _623;
          float _634 = _633 - _623;
          float _635 = _634 * (User_000.UserConstant_Z_000[10].y);
          float _636 = _631 + _635;
          float _637 = _621 * _621;
          float _638 = _637 * 0.1666666716337204f;
          float _639 = _638 * _636;
          float _640 = _627 + _639;
          _706 = _640;
        } else {
          bool _642 = !(_478 <= (User_000.UserConstant_Z_000[9].x));
          if (!_642) {
            float _644 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _645 = max(9.999999974752427e-07f, _644);
            float _646 = _478 - (User_000.UserConstant_Z_000[4].z);
            float _647 = _646 / _645;
            float _648 = 1.0f - _647;
            float _649 = _648 * (User_000.UserConstant_Z_000[4].w);
            float _650 = _647 * (User_000.UserConstant_Z_000[9].y);
            float _651 = _649 + _650;
            float _652 = _648 * _648;
            float _653 = _652 * _648;
            float _654 = _653 - _648;
            float _655 = _654 * (User_000.UserConstant_Z_000[10].y);
            float _656 = _647 * _647;
            float _657 = _656 * _647;
            float _658 = _657 - _647;
            float _659 = _658 * (User_000.UserConstant_Z_000[10].z);
            float _660 = _655 + _659;
            float _661 = _645 * _645;
            float _662 = _661 * 0.1666666716337204f;
            float _663 = _662 * _660;
            float _664 = _651 + _663;
            _706 = _664;
          } else {
            bool _666 = !(_478 <= (User_000.UserConstant_Z_000[9].z));
            if (!_666) {
              float _668 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _669 = max(9.999999974752427e-07f, _668);
              float _670 = _478 - (User_000.UserConstant_Z_000[9].x);
              float _671 = _670 / _669;
              float _672 = 1.0f - _671;
              float _673 = _672 * (User_000.UserConstant_Z_000[9].y);
              float _674 = _671 * (User_000.UserConstant_Z_000[9].w);
              float _675 = _673 + _674;
              float _676 = _672 * _672;
              float _677 = _676 * _672;
              float _678 = _677 - _672;
              float _679 = _678 * (User_000.UserConstant_Z_000[10].z);
              float _680 = _671 * _671;
              float _681 = _680 * _671;
              float _682 = _681 - _671;
              float _683 = _682 * (User_000.UserConstant_Z_000[10].w);
              float _684 = _679 + _683;
              float _685 = _669 * _669;
              float _686 = _685 * 0.1666666716337204f;
              float _687 = _686 * _684;
              float _688 = _675 + _687;
              _706 = _688;
            } else {
              float _690 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _691 = _478 - (User_000.UserConstant_Z_000[9].z);
              float _692 = max(9.999999974752427e-07f, _690);
              float _693 = _691 / _692;
              float _694 = 1.0f - _693;
              float _695 = _694 * (User_000.UserConstant_Z_000[9].w);
              float _696 = _695 + _693;
              float _697 = _694 * _694;
              float _698 = _697 * _694;
              float _699 = _698 - _694;
              float _700 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _701 = _690 * _690;
              float _702 = _701 * _700;
              float _703 = _702 * _699;
              float _704 = _696 + _703;
              _706 = _704;
            }
          }
        }
      }
      float _707 = saturate(_706);
      bool _708 = !(_479 <= (User_000.UserConstant_Z_000[4].x));
      if (!_708) {
        float _710 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _711 = _479 / _710;
        float _712 = _711 * (User_000.UserConstant_Z_000[4].y);
        float _713 = _711 * _711;
        float _714 = _713 * _711;
        float _715 = _714 - _711;
        float _716 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _717 = _710 * _710;
        float _718 = _717 * _716;
        float _719 = _718 * _715;
        float _720 = _719 + _712;
        _810 = _720;
      } else {
        bool _722 = !(_479 <= (User_000.UserConstant_Z_000[4].z));
        if (!_722) {
          float _724 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _725 = max(9.999999974752427e-07f, _724);
          float _726 = _479 - (User_000.UserConstant_Z_000[4].x);
          float _727 = _726 / _725;
          float _728 = 1.0f - _727;
          float _729 = _728 * (User_000.UserConstant_Z_000[4].y);
          float _730 = _727 * (User_000.UserConstant_Z_000[4].w);
          float _731 = _729 + _730;
          float _732 = _728 * _728;
          float _733 = _732 * _728;
          float _734 = _733 - _728;
          float _735 = _734 * (User_000.UserConstant_Z_000[10].x);
          float _736 = _727 * _727;
          float _737 = _736 * _727;
          float _738 = _737 - _727;
          float _739 = _738 * (User_000.UserConstant_Z_000[10].y);
          float _740 = _735 + _739;
          float _741 = _725 * _725;
          float _742 = _741 * 0.1666666716337204f;
          float _743 = _742 * _740;
          float _744 = _731 + _743;
          _810 = _744;
        } else {
          bool _746 = !(_479 <= (User_000.UserConstant_Z_000[9].x));
          if (!_746) {
            float _748 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _749 = max(9.999999974752427e-07f, _748);
            float _750 = _479 - (User_000.UserConstant_Z_000[4].z);
            float _751 = _750 / _749;
            float _752 = 1.0f - _751;
            float _753 = _752 * (User_000.UserConstant_Z_000[4].w);
            float _754 = _751 * (User_000.UserConstant_Z_000[9].y);
            float _755 = _753 + _754;
            float _756 = _752 * _752;
            float _757 = _756 * _752;
            float _758 = _757 - _752;
            float _759 = _758 * (User_000.UserConstant_Z_000[10].y);
            float _760 = _751 * _751;
            float _761 = _760 * _751;
            float _762 = _761 - _751;
            float _763 = _762 * (User_000.UserConstant_Z_000[10].z);
            float _764 = _759 + _763;
            float _765 = _749 * _749;
            float _766 = _765 * 0.1666666716337204f;
            float _767 = _766 * _764;
            float _768 = _755 + _767;
            _810 = _768;
          } else {
            bool _770 = !(_479 <= (User_000.UserConstant_Z_000[9].z));
            if (!_770) {
              float _772 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _773 = max(9.999999974752427e-07f, _772);
              float _774 = _479 - (User_000.UserConstant_Z_000[9].x);
              float _775 = _774 / _773;
              float _776 = 1.0f - _775;
              float _777 = _776 * (User_000.UserConstant_Z_000[9].y);
              float _778 = _775 * (User_000.UserConstant_Z_000[9].w);
              float _779 = _777 + _778;
              float _780 = _776 * _776;
              float _781 = _780 * _776;
              float _782 = _781 - _776;
              float _783 = _782 * (User_000.UserConstant_Z_000[10].z);
              float _784 = _775 * _775;
              float _785 = _784 * _775;
              float _786 = _785 - _775;
              float _787 = _786 * (User_000.UserConstant_Z_000[10].w);
              float _788 = _783 + _787;
              float _789 = _773 * _773;
              float _790 = _789 * 0.1666666716337204f;
              float _791 = _790 * _788;
              float _792 = _779 + _791;
              _810 = _792;
            } else {
              float _794 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _795 = _479 - (User_000.UserConstant_Z_000[9].z);
              float _796 = max(9.999999974752427e-07f, _794);
              float _797 = _795 / _796;
              float _798 = 1.0f - _797;
              float _799 = _798 * (User_000.UserConstant_Z_000[9].w);
              float _800 = _799 + _797;
              float _801 = _798 * _798;
              float _802 = _801 * _798;
              float _803 = _802 - _798;
              float _804 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _805 = _794 * _794;
              float _806 = _805 * _804;
              float _807 = _806 * _803;
              float _808 = _800 + _807;
              _810 = _808;
            }
          }
        }
      }
      float _811 = saturate(_810);
      _813 = _603;
      _814 = _707;
      _815 = _811;
    } else {
      _813 = _477;
      _814 = _478;
      _815 = _479;
    }
    int _816 = _481 & 2;
    bool _817 = (_816 == 0);
    if (!_817) {
      float _819 = sqrt(_813);
      float _820 = sqrt(_814);
      float _821 = sqrt(_815);
      float _822 = dot(float3(_819, _820, _821), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _823 = 1.0f - _822;
      float _824 = saturate(_823);
      _826 = _824;
    } else {
      _826 = 1.0f;
    }
    int _827 = _481 & 8;
    bool _828 = (_827 == 0);
    if (_828) {
      int _830 = _481 & 4;
      bool _831 = (_830 == 0);
      if (!_831) {
        int _833 = _481 & 16;
        bool _834 = (_833 == 0);
        if (!_834) {
          float _838 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _839 = _838 + 0.5f;
          bool _840 = (_839 < 0.5f);
          float _841 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _842 = select(_840, (User_000.UserConstant_Z_000[5].x), _841);
          bool _843 = (_814 < _815);
          float _844 = select(_843, _815, _814);
          float _845 = select(_843, _814, _815);
          bool _846 = (_813 < _844);
          float _847 = select(_846, _844, _813);
          float _848 = select(_846, _813, _844);
          float _849 = min(_848, _845);
          float _850 = _847 - _849;
          float _851 = _847 + 1.000000013351432e-10f;
          float _852 = _850 / _851;
          float _854 = _852 - (User_000.UserConstant_Z_000[5].y);
          float _855 = saturate(_854);
          float _856 = max(_855, 9.999999974752427e-07f);
          float _857 = log2(_856);
          float _858 = _857 * _842;
          float _859 = exp2(_858);
          float _860 = 2.0f - _859;
          float _862 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _863 = saturate(_862);
          float _864 = max(_863, _860);
          float _865 = dot(float3(_813, _814, _815), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _866 = _813 - _865;
          float _867 = _814 - _865;
          float _868 = _815 - _865;
          float _869 = _866 * _864;
          float _870 = _867 * _864;
          float _871 = _868 * _864;
          float _872 = _865 - _813;
          float _873 = _872 + _869;
          float _874 = _865 - _814;
          float _875 = _874 + _870;
          float _876 = _865 - _815;
          float _877 = _876 + _871;
          float _878 = _873 * _826;
          float _879 = _875 * _826;
          float _880 = _877 * _826;
          float _881 = _878 + _813;
          float _882 = _879 + _814;
          float _883 = _880 + _815;
          _1000 = _881;
          _1001 = _882;
          _1002 = _883;
        } else {
          bool _885 = (_826 == 0.0f);
          if (!_885) {
            float _889 = abs(User_000.UserConstant_Z_000[5].x);
            float _890 = saturate(_889);
            uint4 _892 = 0u; t15.GetDimensions(0u, _892.x, _892.y, _892.w);
            float _895 = float((uint)_892.y);
            int _896 = _481 & 32;
            bool _897 = (_896 == 0);
            float _898 = _895 + -1.0f;
            if (!_897) {
              float _900 = 1.0f / _898;
              uint _901 = uint(SV_Position.x);
              uint _902 = uint(SV_Position.y);
              int _903 = _901 & 63;
              int _904 = _902 & 63;
              float4 _906 = t2.Load(int4(_903, _904, 0, 0));
              float _909 = _906.x + -0.5f;
              float _910 = _813 * 13.999999046325684f;
              float _911 = _814 * 13.999999046325684f;
              float _912 = _815 * 13.999999046325684f;
              float _913 = saturate(_910);
              float _914 = saturate(_911);
              float _915 = saturate(_912);
              float _916 = _813 + -0.9285714030265808f;
              float _917 = _814 + -0.9285714030265808f;
              float _918 = _815 + -0.9285714030265808f;
              float _919 = _916 * 13.999999046325684f;
              float _920 = _917 * 13.999999046325684f;
              float _921 = _918 * 13.999999046325684f;
              float _922 = saturate(_919);
              float _923 = saturate(_920);
              float _924 = saturate(_921);
              float _925 = 1.0f - _922;
              float _926 = 1.0f - _923;
              float _927 = 1.0f - _924;
              float _928 = min(_913, _925);
              float _929 = min(_914, _926);
              float _930 = min(_915, _927);
              float _931 = _906.y + -0.5f;
              float _932 = _928 * _931;
              float _933 = _929 * _931;
              float _934 = _930 * _931;
              float _935 = _932 + _909;
              float _936 = _933 + _909;
              float _937 = _934 + _909;
              float _938 = _935 * _900;
              float _939 = _936 * _900;
              float _940 = _937 * _900;
              float _941 = _938 + _813;
              float _942 = _939 + _814;
              float _943 = _940 + _815;
              float _944 = saturate(_941);
              float _945 = saturate(_942);
              float _946 = saturate(_943);
              float _947 = saturate(_944);
              float _948 = saturate(_945);
              float _949 = saturate(_946);
              _951 = _947;
              _952 = _948;
              _953 = _949;
            } else {
              _951 = _813;
              _952 = _814;
              _953 = _815;
            }
            float _954 = float((uint)_892.x);
            float _955 = _898 / _954;
            float _956 = _955 * _951;
            float _957 = 0.5f / _954;
            float _958 = _956 + _957;
            float _959 = _898 / _895;
            float _960 = _959 * _952;
            float _961 = 0.5f / _895;
            float _962 = _960 + _961;
            float _963 = _953 * _898;
            float _964 = floor(_963);
            float _965 = frac(_963);
            float _966 = _964 / _895;
            float _967 = _966 + _958;
            float _968 = _964 + 1.0f;
            float _969 = _968 / _895;
            float _970 = _969 + _958;
            float4 _972 = t15.Sample(s1, float2(_967, _962));
            float4 _976 = t15.Sample(s1, float2(_970, _962));
            float _980 = _976.x - _972.x;
            float _981 = _976.y - _972.y;
            float _982 = _976.z - _972.z;
            float _983 = _980 * _965;
            float _984 = _981 * _965;
            float _985 = _982 * _965;
            float _986 = _890 * _826;
            float _987 = _972.x - _813;
            float _988 = _987 + _983;
            float _989 = _972.y - _814;
            float _990 = _989 + _984;
            float _991 = _972.z - _815;
            float _992 = _991 + _985;
            float _993 = _988 * _986;
            float _994 = _990 * _986;
            float _995 = _992 * _986;
            float _996 = _993 + _813;
            float _997 = _994 + _814;
            float _998 = _995 + _815;
            _1000 = _996;
            _1001 = _997;
            _1002 = _998;
          } else {
            _1000 = _813;
            _1001 = _814;
            _1002 = _815;
          }
        }
      } else {
        _1000 = _813;
        _1001 = _814;
        _1002 = _815;
      }
    } else {
      _1000 = _826;
      _1001 = _826;
      _1002 = _826;
    }
    float _1003 = _1000 * 13.450128555297852f;
    float _1004 = _1001 * 13.450128555297852f;
    float _1005 = _1002 * 13.450128555297852f;
    float _1006 = exp2(_1003);
    float _1007 = exp2(_1004);
    float _1008 = exp2(_1005);
    float _1009 = _1006 + -1.0f;
    float _1010 = _1007 + -1.0f;
    float _1011 = _1008 + -1.0f;
    float _1012 = _1009 * _459;
    float _1013 = _1010 * _459;
    float _1014 = _1011 * _459;
    _1016 = _1012;
    _1017 = _1013;
    _1018 = _1014;
  } else {
    _1016 = _460;
    _1017 = _461;
    _1018 = _462;
  }
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1016, (User_000.UserConstant_Z_000[8].y) * _1017, (User_000.UserConstant_Z_000[8].z) * _1018),
      SV_Position.xy);
  float _1025 = resonance_perceptual_film_grain.x;
  float _1026 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1027 = log2(_1025);
  float _1028 = _1026 * _1027;
  float _1029 = exp2(_1028);
  float _1030 = _1029 + -1.0f;
  float _1031 = _1025 + -1.0f;
  float _1032 = _1030 / _1031;
  bool _1033 = !(_1025 == 1.0f);
  float _1034 = _1032 + -1.0f;
  float _1035 = _1034 / _1032;
  float _1036 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1037 = _1036 / _1026;
  float _1038 = select(_1033, _1035, _1037);
  float _1039 = resonance_perceptual_film_grain.y;
  float _1040 = log2(_1039);
  float _1041 = _1040 * _1026;
  float _1042 = exp2(_1041);
  float _1043 = _1042 + -1.0f;
  float _1044 = _1039 + -1.0f;
  float _1045 = _1043 / _1044;
  bool _1046 = !(_1039 == 1.0f);
  float _1047 = _1045 + -1.0f;
  float _1048 = _1047 / _1045;
  float _1049 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1050 = _1049 / _1026;
  float _1051 = select(_1046, _1048, _1050);
  float _1052 = resonance_perceptual_film_grain.z;
  float _1053 = log2(_1052);
  float _1054 = _1053 * _1026;
  float _1055 = exp2(_1054);
  float _1056 = _1055 + -1.0f;
  float _1057 = _1052 + -1.0f;
  float _1058 = _1056 / _1057;
  bool _1059 = !(_1052 == 1.0f);
  float _1060 = _1058 + -1.0f;
  float _1061 = _1060 / _1058;
  float _1062 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1063 = _1062 / _1026;
  float _1064 = select(_1059, _1061, _1063);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1025, _1039, _1052),
      float3(_1038, _1051, _1064),
      true);
  float _1065 = resonance_post_process_output.x;
  float _1066 = resonance_post_process_output.y;
  float _1067 = resonance_post_process_output.z;
  float _1068 = log2(_1065);
  float _1069 = log2(_1066);
  float _1070 = log2(_1067);
  float _1071 = _1068 * 0.4166666567325592f;
  float _1072 = _1069 * 0.4166666567325592f;
  float _1073 = _1070 * 0.4166666567325592f;
  float _1074 = exp2(_1071);
  float _1075 = exp2(_1072);
  float _1076 = exp2(_1073);
  float _1077 = _1074 * 1.0549999475479126f;
  float _1078 = _1075 * 1.0549999475479126f;
  float _1079 = _1076 * 1.0549999475479126f;
  float _1080 = _1077 + -0.054999999701976776f;
  float _1081 = _1078 + -0.054999999701976776f;
  float _1082 = _1079 + -0.054999999701976776f;
  float _1083 = _1065 * 12.920000076293945f;
  float _1084 = _1066 * 12.920000076293945f;
  float _1085 = _1067 * 12.920000076293945f;
  bool _1086 = (_1065 <= 0.0031308000907301903f);
  bool _1087 = (_1066 <= 0.0031308000907301903f);
  bool _1088 = (_1067 <= 0.0031308000907301903f);
  float _1089 = select(_1086, _1083, _1080);
  float _1090 = select(_1087, _1084, _1081);
  float _1091 = select(_1088, _1085, _1082);
  int _1094 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1095 = uint(SV_Position.x);
  uint _1096 = uint(SV_Position.y);
  int _1097 = _1095 & 63;
  int _1098 = _1096 & 63;
  float4 _1100 = t1.Load(int4(_1097, _1098, _1094, 0));
  float _1102 = _1100.x + -0.5f;
  float _1103 = _1102 * 0.003921568859368563f;
  float _1104 = _1103 + _1089;
  float _1105 = _1103 + _1090;
  float _1106 = _1103 + _1091;
  float _1107 = saturate(_1104);
  float _1108 = saturate(_1105);
  float _1109 = saturate(_1106);
  SV_Target.x = _1107;
  SV_Target.y = _1108;
  SV_Target.z = _1109;
  SV_Target.w = _364;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}