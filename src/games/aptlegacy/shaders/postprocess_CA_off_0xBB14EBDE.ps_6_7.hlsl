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
  float GlobalCB_Z__GlobalConstant_Z_1692;
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
  float _567;
  float _671;
  float _775;
  float _778;
  float _779;
  float _780;
  float _791;
  float _916;
  float _917;
  float _918;
  float _965;
  float _966;
  float _967;
  float _981;
  float _982;
  float _983;
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
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
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
  float _379 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _380 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _381 = _371.x * _380;
  float _382 = _381 * _365;
  float _383 = _382 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _384 = _383 * _379;
  float _385 = _381 * _366;
  float _386 = _385 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _387 = _386 * _379;
  float _388 = _381 * _367;
  float _389 = _388 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _390 = _389 * _379;
  float _391 = _384 + 1.0f;
  float _392 = _387 + 1.0f;
  float _393 = _390 + 1.0f;
  float _394 = log2(_391);
  float _395 = log2(_392);
  float _396 = log2(_393);
  float _399 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _400 = _399 * _394;
  float _401 = _399 * _395;
  float _402 = _399 * _396;
  float _404 = _400 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _405 = _401 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _406 = _402 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _409 = t3.Sample(s3, float3(_404, _405, _406));
  float _415 = _409.x * 13.450128555297852f;
  float _416 = _409.y * 13.450128555297852f;
  float _417 = _409.z * 13.450128555297852f;
  float _418 = exp2(_415);
  float _419 = exp2(_416);
  float _420 = exp2(_417);
  float _421 = _418 + -1.0f;
  float _422 = _419 + -1.0f;
  float _423 = _420 + -1.0f;
  float _424 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _425 = _424 * _421;
  float _426 = _424 * _422;
  float _427 = _424 * _423;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_384 * _424, _387 * _424, _390 * _424),
      float3(_425, _426, _427),
      1.f.xxx);
  _425 = apt_scaled_lut_output.x;
  _426 = apt_scaled_lut_output.y;
  _427 = apt_scaled_lut_output.z;
  bool _430 = ((User_000.UserConstant_Z_000[3].x) > 0.0f);
  if (_430) {
    float _432 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _433 = _425 * _432;
    float _434 = _426 * _432;
    float _435 = _427 * _432;
    float _436 = _433 + 1.0f;
    float _437 = _434 + 1.0f;
    float _438 = _435 + 1.0f;
    float _439 = log2(_436);
    float _440 = log2(_437);
    float _441 = log2(_438);
    float _442 = _439 * 0.07434873282909393f;
    float _443 = _440 * 0.07434873282909393f;
    float _444 = _441 * 0.07434873282909393f;
    int _446 = asint((User_000.UserConstant_Z_000[3].y));
    int _447 = _446 & 1;
    bool _448 = (_447 == 0);
    if (!_448) {
      bool _465 = !(_442 <= (User_000.UserConstant_Z_000[4].x));
      if (!_465) {
        float _467 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _468 = _442 / _467;
        float _469 = _468 * (User_000.UserConstant_Z_000[4].y);
        float _470 = _468 * _468;
        float _471 = _470 * _468;
        float _472 = _471 - _468;
        float _473 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _474 = _467 * _467;
        float _475 = _474 * _473;
        float _476 = _475 * _472;
        float _477 = _476 + _469;
        _567 = _477;
      } else {
        bool _479 = !(_442 <= (User_000.UserConstant_Z_000[4].z));
        if (!_479) {
          float _481 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _482 = max(9.999999974752427e-07f, _481);
          float _483 = _442 - (User_000.UserConstant_Z_000[4].x);
          float _484 = _483 / _482;
          float _485 = 1.0f - _484;
          float _486 = _485 * (User_000.UserConstant_Z_000[4].y);
          float _487 = _484 * (User_000.UserConstant_Z_000[4].w);
          float _488 = _486 + _487;
          float _489 = _485 * _485;
          float _490 = _489 * _485;
          float _491 = _490 - _485;
          float _492 = _491 * (User_000.UserConstant_Z_000[10].x);
          float _493 = _484 * _484;
          float _494 = _493 * _484;
          float _495 = _494 - _484;
          float _496 = _495 * (User_000.UserConstant_Z_000[10].y);
          float _497 = _492 + _496;
          float _498 = _482 * _482;
          float _499 = _498 * 0.1666666716337204f;
          float _500 = _499 * _497;
          float _501 = _488 + _500;
          _567 = _501;
        } else {
          bool _503 = !(_442 <= (User_000.UserConstant_Z_000[9].x));
          if (!_503) {
            float _505 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _506 = max(9.999999974752427e-07f, _505);
            float _507 = _442 - (User_000.UserConstant_Z_000[4].z);
            float _508 = _507 / _506;
            float _509 = 1.0f - _508;
            float _510 = _509 * (User_000.UserConstant_Z_000[4].w);
            float _511 = _508 * (User_000.UserConstant_Z_000[9].y);
            float _512 = _510 + _511;
            float _513 = _509 * _509;
            float _514 = _513 * _509;
            float _515 = _514 - _509;
            float _516 = _515 * (User_000.UserConstant_Z_000[10].y);
            float _517 = _508 * _508;
            float _518 = _517 * _508;
            float _519 = _518 - _508;
            float _520 = _519 * (User_000.UserConstant_Z_000[10].z);
            float _521 = _516 + _520;
            float _522 = _506 * _506;
            float _523 = _522 * 0.1666666716337204f;
            float _524 = _523 * _521;
            float _525 = _512 + _524;
            _567 = _525;
          } else {
            bool _527 = !(_442 <= (User_000.UserConstant_Z_000[9].z));
            if (!_527) {
              float _529 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _530 = max(9.999999974752427e-07f, _529);
              float _531 = _442 - (User_000.UserConstant_Z_000[9].x);
              float _532 = _531 / _530;
              float _533 = 1.0f - _532;
              float _534 = _533 * (User_000.UserConstant_Z_000[9].y);
              float _535 = _532 * (User_000.UserConstant_Z_000[9].w);
              float _536 = _534 + _535;
              float _537 = _533 * _533;
              float _538 = _537 * _533;
              float _539 = _538 - _533;
              float _540 = _539 * (User_000.UserConstant_Z_000[10].z);
              float _541 = _532 * _532;
              float _542 = _541 * _532;
              float _543 = _542 - _532;
              float _544 = _543 * (User_000.UserConstant_Z_000[10].w);
              float _545 = _540 + _544;
              float _546 = _530 * _530;
              float _547 = _546 * 0.1666666716337204f;
              float _548 = _547 * _545;
              float _549 = _536 + _548;
              _567 = _549;
            } else {
              float _551 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _552 = _442 - (User_000.UserConstant_Z_000[9].z);
              float _553 = max(9.999999974752427e-07f, _551);
              float _554 = _552 / _553;
              float _555 = 1.0f - _554;
              float _556 = _555 * (User_000.UserConstant_Z_000[9].w);
              float _557 = _556 + _554;
              float _558 = _555 * _555;
              float _559 = _558 * _555;
              float _560 = _559 - _555;
              float _561 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _562 = _551 * _551;
              float _563 = _562 * _561;
              float _564 = _563 * _560;
              float _565 = _557 + _564;
              _567 = _565;
            }
          }
        }
      }
      float _568 = saturate(_567);
      bool _569 = !(_443 <= (User_000.UserConstant_Z_000[4].x));
      if (!_569) {
        float _571 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _572 = _443 / _571;
        float _573 = _572 * (User_000.UserConstant_Z_000[4].y);
        float _574 = _572 * _572;
        float _575 = _574 * _572;
        float _576 = _575 - _572;
        float _577 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _578 = _571 * _571;
        float _579 = _578 * _577;
        float _580 = _579 * _576;
        float _581 = _580 + _573;
        _671 = _581;
      } else {
        bool _583 = !(_443 <= (User_000.UserConstant_Z_000[4].z));
        if (!_583) {
          float _585 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _586 = max(9.999999974752427e-07f, _585);
          float _587 = _443 - (User_000.UserConstant_Z_000[4].x);
          float _588 = _587 / _586;
          float _589 = 1.0f - _588;
          float _590 = _589 * (User_000.UserConstant_Z_000[4].y);
          float _591 = _588 * (User_000.UserConstant_Z_000[4].w);
          float _592 = _590 + _591;
          float _593 = _589 * _589;
          float _594 = _593 * _589;
          float _595 = _594 - _589;
          float _596 = _595 * (User_000.UserConstant_Z_000[10].x);
          float _597 = _588 * _588;
          float _598 = _597 * _588;
          float _599 = _598 - _588;
          float _600 = _599 * (User_000.UserConstant_Z_000[10].y);
          float _601 = _596 + _600;
          float _602 = _586 * _586;
          float _603 = _602 * 0.1666666716337204f;
          float _604 = _603 * _601;
          float _605 = _592 + _604;
          _671 = _605;
        } else {
          bool _607 = !(_443 <= (User_000.UserConstant_Z_000[9].x));
          if (!_607) {
            float _609 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _610 = max(9.999999974752427e-07f, _609);
            float _611 = _443 - (User_000.UserConstant_Z_000[4].z);
            float _612 = _611 / _610;
            float _613 = 1.0f - _612;
            float _614 = _613 * (User_000.UserConstant_Z_000[4].w);
            float _615 = _612 * (User_000.UserConstant_Z_000[9].y);
            float _616 = _614 + _615;
            float _617 = _613 * _613;
            float _618 = _617 * _613;
            float _619 = _618 - _613;
            float _620 = _619 * (User_000.UserConstant_Z_000[10].y);
            float _621 = _612 * _612;
            float _622 = _621 * _612;
            float _623 = _622 - _612;
            float _624 = _623 * (User_000.UserConstant_Z_000[10].z);
            float _625 = _620 + _624;
            float _626 = _610 * _610;
            float _627 = _626 * 0.1666666716337204f;
            float _628 = _627 * _625;
            float _629 = _616 + _628;
            _671 = _629;
          } else {
            bool _631 = !(_443 <= (User_000.UserConstant_Z_000[9].z));
            if (!_631) {
              float _633 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _634 = max(9.999999974752427e-07f, _633);
              float _635 = _443 - (User_000.UserConstant_Z_000[9].x);
              float _636 = _635 / _634;
              float _637 = 1.0f - _636;
              float _638 = _637 * (User_000.UserConstant_Z_000[9].y);
              float _639 = _636 * (User_000.UserConstant_Z_000[9].w);
              float _640 = _638 + _639;
              float _641 = _637 * _637;
              float _642 = _641 * _637;
              float _643 = _642 - _637;
              float _644 = _643 * (User_000.UserConstant_Z_000[10].z);
              float _645 = _636 * _636;
              float _646 = _645 * _636;
              float _647 = _646 - _636;
              float _648 = _647 * (User_000.UserConstant_Z_000[10].w);
              float _649 = _644 + _648;
              float _650 = _634 * _634;
              float _651 = _650 * 0.1666666716337204f;
              float _652 = _651 * _649;
              float _653 = _640 + _652;
              _671 = _653;
            } else {
              float _655 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _656 = _443 - (User_000.UserConstant_Z_000[9].z);
              float _657 = max(9.999999974752427e-07f, _655);
              float _658 = _656 / _657;
              float _659 = 1.0f - _658;
              float _660 = _659 * (User_000.UserConstant_Z_000[9].w);
              float _661 = _660 + _658;
              float _662 = _659 * _659;
              float _663 = _662 * _659;
              float _664 = _663 - _659;
              float _665 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _666 = _655 * _655;
              float _667 = _666 * _665;
              float _668 = _667 * _664;
              float _669 = _661 + _668;
              _671 = _669;
            }
          }
        }
      }
      float _672 = saturate(_671);
      bool _673 = !(_444 <= (User_000.UserConstant_Z_000[4].x));
      if (!_673) {
        float _675 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _676 = _444 / _675;
        float _677 = _676 * (User_000.UserConstant_Z_000[4].y);
        float _678 = _676 * _676;
        float _679 = _678 * _676;
        float _680 = _679 - _676;
        float _681 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _682 = _675 * _675;
        float _683 = _682 * _681;
        float _684 = _683 * _680;
        float _685 = _684 + _677;
        _775 = _685;
      } else {
        bool _687 = !(_444 <= (User_000.UserConstant_Z_000[4].z));
        if (!_687) {
          float _689 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _690 = max(9.999999974752427e-07f, _689);
          float _691 = _444 - (User_000.UserConstant_Z_000[4].x);
          float _692 = _691 / _690;
          float _693 = 1.0f - _692;
          float _694 = _693 * (User_000.UserConstant_Z_000[4].y);
          float _695 = _692 * (User_000.UserConstant_Z_000[4].w);
          float _696 = _694 + _695;
          float _697 = _693 * _693;
          float _698 = _697 * _693;
          float _699 = _698 - _693;
          float _700 = _699 * (User_000.UserConstant_Z_000[10].x);
          float _701 = _692 * _692;
          float _702 = _701 * _692;
          float _703 = _702 - _692;
          float _704 = _703 * (User_000.UserConstant_Z_000[10].y);
          float _705 = _700 + _704;
          float _706 = _690 * _690;
          float _707 = _706 * 0.1666666716337204f;
          float _708 = _707 * _705;
          float _709 = _696 + _708;
          _775 = _709;
        } else {
          bool _711 = !(_444 <= (User_000.UserConstant_Z_000[9].x));
          if (!_711) {
            float _713 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _714 = max(9.999999974752427e-07f, _713);
            float _715 = _444 - (User_000.UserConstant_Z_000[4].z);
            float _716 = _715 / _714;
            float _717 = 1.0f - _716;
            float _718 = _717 * (User_000.UserConstant_Z_000[4].w);
            float _719 = _716 * (User_000.UserConstant_Z_000[9].y);
            float _720 = _718 + _719;
            float _721 = _717 * _717;
            float _722 = _721 * _717;
            float _723 = _722 - _717;
            float _724 = _723 * (User_000.UserConstant_Z_000[10].y);
            float _725 = _716 * _716;
            float _726 = _725 * _716;
            float _727 = _726 - _716;
            float _728 = _727 * (User_000.UserConstant_Z_000[10].z);
            float _729 = _724 + _728;
            float _730 = _714 * _714;
            float _731 = _730 * 0.1666666716337204f;
            float _732 = _731 * _729;
            float _733 = _720 + _732;
            _775 = _733;
          } else {
            bool _735 = !(_444 <= (User_000.UserConstant_Z_000[9].z));
            if (!_735) {
              float _737 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _738 = max(9.999999974752427e-07f, _737);
              float _739 = _444 - (User_000.UserConstant_Z_000[9].x);
              float _740 = _739 / _738;
              float _741 = 1.0f - _740;
              float _742 = _741 * (User_000.UserConstant_Z_000[9].y);
              float _743 = _740 * (User_000.UserConstant_Z_000[9].w);
              float _744 = _742 + _743;
              float _745 = _741 * _741;
              float _746 = _745 * _741;
              float _747 = _746 - _741;
              float _748 = _747 * (User_000.UserConstant_Z_000[10].z);
              float _749 = _740 * _740;
              float _750 = _749 * _740;
              float _751 = _750 - _740;
              float _752 = _751 * (User_000.UserConstant_Z_000[10].w);
              float _753 = _748 + _752;
              float _754 = _738 * _738;
              float _755 = _754 * 0.1666666716337204f;
              float _756 = _755 * _753;
              float _757 = _744 + _756;
              _775 = _757;
            } else {
              float _759 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _760 = _444 - (User_000.UserConstant_Z_000[9].z);
              float _761 = max(9.999999974752427e-07f, _759);
              float _762 = _760 / _761;
              float _763 = 1.0f - _762;
              float _764 = _763 * (User_000.UserConstant_Z_000[9].w);
              float _765 = _764 + _762;
              float _766 = _763 * _763;
              float _767 = _766 * _763;
              float _768 = _767 - _763;
              float _769 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _770 = _759 * _759;
              float _771 = _770 * _769;
              float _772 = _771 * _768;
              float _773 = _765 + _772;
              _775 = _773;
            }
          }
        }
      }
      float _776 = saturate(_775);
      _778 = _568;
      _779 = _672;
      _780 = _776;
    } else {
      _778 = _442;
      _779 = _443;
      _780 = _444;
    }
    int _781 = _446 & 2;
    bool _782 = (_781 == 0);
    if (!_782) {
      float _784 = sqrt(_778);
      float _785 = sqrt(_779);
      float _786 = sqrt(_780);
      float _787 = dot(float3(_784, _785, _786), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _788 = 1.0f - _787;
      float _789 = saturate(_788);
      _791 = _789;
    } else {
      _791 = 1.0f;
    }
    int _792 = _446 & 8;
    bool _793 = (_792 == 0);
    if (_793) {
      int _795 = _446 & 4;
      bool _796 = (_795 == 0);
      if (!_796) {
        int _798 = _446 & 16;
        bool _799 = (_798 == 0);
        if (!_799) {
          float _803 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _804 = _803 + 0.5f;
          bool _805 = (_804 < 0.5f);
          float _806 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _807 = select(_805, (User_000.UserConstant_Z_000[5].x), _806);
          bool _808 = (_779 < _780);
          float _809 = select(_808, _780, _779);
          float _810 = select(_808, _779, _780);
          bool _811 = (_778 < _809);
          float _812 = select(_811, _809, _778);
          float _813 = select(_811, _778, _809);
          float _814 = min(_813, _810);
          float _815 = _812 - _814;
          float _816 = _812 + 1.000000013351432e-10f;
          float _817 = _815 / _816;
          float _819 = _817 - (User_000.UserConstant_Z_000[5].y);
          float _820 = saturate(_819);
          float _821 = max(_820, 9.999999974752427e-07f);
          float _822 = log2(_821);
          float _823 = _822 * _807;
          float _824 = exp2(_823);
          float _825 = 2.0f - _824;
          float _827 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _828 = saturate(_827);
          float _829 = max(_828, _825);
          float _830 = dot(float3(_778, _779, _780), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _831 = _778 - _830;
          float _832 = _779 - _830;
          float _833 = _780 - _830;
          float _834 = _831 * _829;
          float _835 = _832 * _829;
          float _836 = _833 * _829;
          float _837 = _830 - _778;
          float _838 = _837 + _834;
          float _839 = _830 - _779;
          float _840 = _839 + _835;
          float _841 = _830 - _780;
          float _842 = _841 + _836;
          float _843 = _838 * _791;
          float _844 = _840 * _791;
          float _845 = _842 * _791;
          float _846 = _843 + _778;
          float _847 = _844 + _779;
          float _848 = _845 + _780;
          _965 = _846;
          _966 = _847;
          _967 = _848;
        } else {
          bool _850 = (_791 == 0.0f);
          if (!_850) {
            float _854 = abs(User_000.UserConstant_Z_000[5].x);
            float _855 = saturate(_854);
            uint4 _857 = 0u; t15.GetDimensions(0u, _857.x, _857.y, _857.w);
            float _860 = float((uint)_857.y);
            int _861 = _446 & 32;
            bool _862 = (_861 == 0);
            float _863 = _860 + -1.0f;
            if (!_862) {
              float _865 = 1.0f / _863;
              uint _866 = uint(SV_Position.x);
              uint _867 = uint(SV_Position.y);
              int _868 = _866 & 63;
              int _869 = _867 & 63;
              float4 _871 = t2.Load(int4(_868, _869, 0, 0));
              float _874 = _871.x + -0.5f;
              float _875 = _778 * 13.999999046325684f;
              float _876 = _779 * 13.999999046325684f;
              float _877 = _780 * 13.999999046325684f;
              float _878 = saturate(_875);
              float _879 = saturate(_876);
              float _880 = saturate(_877);
              float _881 = _778 + -0.9285714030265808f;
              float _882 = _779 + -0.9285714030265808f;
              float _883 = _780 + -0.9285714030265808f;
              float _884 = _881 * 13.999999046325684f;
              float _885 = _882 * 13.999999046325684f;
              float _886 = _883 * 13.999999046325684f;
              float _887 = saturate(_884);
              float _888 = saturate(_885);
              float _889 = saturate(_886);
              float _890 = 1.0f - _887;
              float _891 = 1.0f - _888;
              float _892 = 1.0f - _889;
              float _893 = min(_878, _890);
              float _894 = min(_879, _891);
              float _895 = min(_880, _892);
              float _896 = _871.y + -0.5f;
              float _897 = _893 * _896;
              float _898 = _894 * _896;
              float _899 = _895 * _896;
              float _900 = _897 + _874;
              float _901 = _898 + _874;
              float _902 = _899 + _874;
              float _903 = _900 * _865;
              float _904 = _901 * _865;
              float _905 = _902 * _865;
              float _906 = _903 + _778;
              float _907 = _904 + _779;
              float _908 = _905 + _780;
              float _909 = saturate(_906);
              float _910 = saturate(_907);
              float _911 = saturate(_908);
              float _912 = saturate(_909);
              float _913 = saturate(_910);
              float _914 = saturate(_911);
              _916 = _912;
              _917 = _913;
              _918 = _914;
            } else {
              _916 = _778;
              _917 = _779;
              _918 = _780;
            }
            float _919 = float((uint)_857.x);
            float _920 = _863 / _919;
            float _921 = _920 * _916;
            float _922 = 0.5f / _919;
            float _923 = _921 + _922;
            float _924 = _863 / _860;
            float _925 = _924 * _917;
            float _926 = 0.5f / _860;
            float _927 = _925 + _926;
            float _928 = _918 * _863;
            float _929 = floor(_928);
            float _930 = frac(_928);
            float _931 = _929 / _860;
            float _932 = _931 + _923;
            float _933 = _929 + 1.0f;
            float _934 = _933 / _860;
            float _935 = _934 + _923;
            float4 _937 = t15.Sample(s1, float2(_932, _927));
            float4 _941 = t15.Sample(s1, float2(_935, _927));
            float _945 = _941.x - _937.x;
            float _946 = _941.y - _937.y;
            float _947 = _941.z - _937.z;
            float _948 = _945 * _930;
            float _949 = _946 * _930;
            float _950 = _947 * _930;
            float _951 = _855 * _791;
            float _952 = _937.x - _778;
            float _953 = _952 + _948;
            float _954 = _937.y - _779;
            float _955 = _954 + _949;
            float _956 = _937.z - _780;
            float _957 = _956 + _950;
            float _958 = _953 * _951;
            float _959 = _955 * _951;
            float _960 = _957 * _951;
            float _961 = _958 + _778;
            float _962 = _959 + _779;
            float _963 = _960 + _780;
            _965 = _961;
            _966 = _962;
            _967 = _963;
          } else {
            _965 = _778;
            _966 = _779;
            _967 = _780;
          }
        }
      } else {
        _965 = _778;
        _966 = _779;
        _967 = _780;
      }
    } else {
      _965 = _791;
      _966 = _791;
      _967 = _791;
    }
    float _968 = _965 * 13.450128555297852f;
    float _969 = _966 * 13.450128555297852f;
    float _970 = _967 * 13.450128555297852f;
    float _971 = exp2(_968);
    float _972 = exp2(_969);
    float _973 = exp2(_970);
    float _974 = _971 + -1.0f;
    float _975 = _972 + -1.0f;
    float _976 = _973 + -1.0f;
    float _977 = _974 * _424;
    float _978 = _975 * _424;
    float _979 = _976 * _424;
    _981 = _977;
    _982 = _978;
    _983 = _979;
  } else {
    _981 = _425;
    _982 = _426;
    _983 = _427;
  }
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _981, (User_000.UserConstant_Z_000[8].y) * _982, (User_000.UserConstant_Z_000[8].z) * _983),
      SV_Position.xy);
  float _990 = apt_perceptual_film_grain.x;
  float _991 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _992 = log2(_990);
  float _993 = _991 * _992;
  float _994 = exp2(_993);
  float _995 = _994 + -1.0f;
  float _996 = _990 + -1.0f;
  float _997 = _995 / _996;
  bool _998 = !(_990 == 1.0f);
  float _999 = _997 + -1.0f;
  float _1000 = _999 / _997;
  float _1001 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1002 = _1001 / _991;
  float _1003 = select(_998, _1000, _1002);
  float _1004 = apt_perceptual_film_grain.y;
  float _1005 = log2(_1004);
  float _1006 = _1005 * _991;
  float _1007 = exp2(_1006);
  float _1008 = _1007 + -1.0f;
  float _1009 = _1004 + -1.0f;
  float _1010 = _1008 / _1009;
  bool _1011 = !(_1004 == 1.0f);
  float _1012 = _1010 + -1.0f;
  float _1013 = _1012 / _1010;
  float _1014 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1015 = _1014 / _991;
  float _1016 = select(_1011, _1013, _1015);
  float _1017 = apt_perceptual_film_grain.z;
  float _1018 = log2(_1017);
  float _1019 = _1018 * _991;
  float _1020 = exp2(_1019);
  float _1021 = _1020 + -1.0f;
  float _1022 = _1017 + -1.0f;
  float _1023 = _1021 / _1022;
  bool _1024 = !(_1017 == 1.0f);
  float _1025 = _1023 + -1.0f;
  float _1026 = _1025 / _1023;
  float _1027 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1028 = _1027 / _991;
  float _1029 = select(_1024, _1026, _1028);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_990, _1004, _1017),
      float3(_1003, _1016, _1029),
      true);
  float _1030 = apt_post_process_output.x;
  float _1031 = apt_post_process_output.y;
  float _1032 = apt_post_process_output.z;
  float _1033 = log2(_1030);
  float _1034 = log2(_1031);
  float _1035 = log2(_1032);
  float _1036 = _1033 * 0.4166666567325592f;
  float _1037 = _1034 * 0.4166666567325592f;
  float _1038 = _1035 * 0.4166666567325592f;
  float _1039 = exp2(_1036);
  float _1040 = exp2(_1037);
  float _1041 = exp2(_1038);
  float _1042 = _1039 * 1.0549999475479126f;
  float _1043 = _1040 * 1.0549999475479126f;
  float _1044 = _1041 * 1.0549999475479126f;
  float _1045 = _1042 + -0.054999999701976776f;
  float _1046 = _1043 + -0.054999999701976776f;
  float _1047 = _1044 + -0.054999999701976776f;
  float _1048 = _1030 * 12.920000076293945f;
  float _1049 = _1031 * 12.920000076293945f;
  float _1050 = _1032 * 12.920000076293945f;
  bool _1051 = (_1030 <= 0.0031308000907301903f);
  bool _1052 = (_1031 <= 0.0031308000907301903f);
  bool _1053 = (_1032 <= 0.0031308000907301903f);
  float _1054 = select(_1051, _1048, _1045);
  float _1055 = select(_1052, _1049, _1046);
  float _1056 = select(_1053, _1050, _1047);
  int _1059 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1060 = uint(SV_Position.x);
  uint _1061 = uint(SV_Position.y);
  int _1062 = _1060 & 63;
  int _1063 = _1061 & 63;
  float4 _1065 = t1.Load(int4(_1062, _1063, _1059, 0));
  float _1067 = _1065.x + -0.5f;
  float _1068 = _1067 * 0.003921568859368563f;
  float _1069 = _1068 + _1054;
  float _1070 = _1068 + _1055;
  float _1071 = _1068 + _1056;
  float _1072 = saturate(_1069);
  float _1073 = saturate(_1070);
  float _1074 = saturate(_1071);
  SV_Target.x = _1072;
  SV_Target.y = _1073;
  SV_Target.z = _1074;
  SV_Target.w = _364;
  return SV_Target;
}
