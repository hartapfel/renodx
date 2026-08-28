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

#include "../../common.hlsli"

cbuffer cb1 : register(b1) {
  GlobalCB_Z Global_000 : packoffset(c000.x);
};

cbuffer cb0 : register(b0) {
  UserConstant_Z User_000 : packoffset(c000.x);
};

cbuffer cb2 : register(b2) {
  PostProcessConstant_Z PostProcess_000 : packoffset(c000.x);
};

SamplerState s0 : register(s0);

SamplerState s3 : register(s3);

SamplerState s8 : register(s8);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target = 0;
  float4 _28 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _34 = t16.Sample(s0, float2(TEXCOORD.z, TEXCOORD.w));
  float _37 = _34.y * 0.10000000149011612f;
  float _38 = _37 + _28.y;
  float _39 = _34.y * 0.5f;
  float _40 = _39 + _28.z;
  float _41 = exp2(_40);
  float _42 = _41 + -1.0f;
  float _45 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _42;
  float _46 = _45 + 1.0f;
  float _47 = log2(_46);
  float _48 = _28.x + TEXCOORD.z;
  float _49 = _38 + TEXCOORD.w;
  float _50 = _28.x + TEXCOORD.x;
  float _51 = _38 + TEXCOORD.y;
  float _52 = _47 + 1.0f;
  float _53 = log2(_52);
  float _57 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].x);
  float _58 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].y);
  float _59 = _57 + _48;
  float _60 = _58 + _49;
  float _61 = _59 * 2.0f;
  float _62 = _60 * 2.0f;
  float _63 = _61 + -1.0f;
  float _64 = _62 + -1.0f;
  float _68 = _64 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].y);
  float _69 = abs(_63);
  float _70 = abs(_64);
  float _72 = (PostProcess_000.PostProcessConstant_Z_000[19].z) * 2.0f;
  float _73 = _72 + -1.0f;
  float _74 = _69 - _73;
  float _75 = _70 - _73;
  float _76 = saturate(_74);
  float _77 = saturate(_75);
  float _78 = _76 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].x);
  float _79 = _78 * _63;
  float _80 = _68 * _77;
  float _81 = _79 * _79;
  float _82 = _80 * _80;
  float _83 = _81 + _82;
  float _84 = sqrt(_83);
  float _87 = _57 + _50;
  float _88 = _58 + _51;
  float _89 = _87 * 2.0f;
  float _90 = _89 + -1.0f;
  float _91 = _88 * 1.125f;
  float _92 = _91 + -0.5625f;
  float _93 = _90 * _90;
  float _94 = _92 * _92;
  float _95 = _93 + _94;
  float _96 = sqrt(_95);
  float _97 = _96 * 0.8715755343437195f;
  float _98 = _97 * _97;
  float _99 = _98 + -0.15000000596046448f;
  float _100 = _99 * 1.8181819915771484f;
  float _101 = saturate(_100);
  float _102 = _101 * 2.0f;
  float _103 = 3.0f - _102;
  float _104 = (PostProcess_000.PostProcessConstant_Z_000[2].w) * _84;
  float _105 = _101 * _101;
  float _106 = _105 * _104;
  float _107 = _106 * _98;
  float _108 = _107 * _103;
  float _110 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _79;
  float _111 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _80;
  float _112 = _111 + _49;
  float _113 = _48 - _110;
  float _114 = _34.x * 0.010840999893844128f;
  float _115 = _114 + _48;
  float _116 = _115 + _110;
  float _117 = _49 + _114;
  float _118 = _117 - _111;
  float _119 = max(_108, _53);
  float4 _122 = t0.SampleLevel(s0, float2(_116, _112), _119);
  float4 _124 = t0.SampleLevel(s0, float2(_113, _118), _119);
  float4 _126 = t0.SampleLevel(s0, float2(_48, _49), _119);
  float _129 = max(_122.x, 0.0f);
  float _130 = max(_124.y, 0.0f);
  float _131 = max(_126.z, 0.0f);
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
      float3(_129, _130, _131),
      max(_126.rgb, 0.f.xxx),
      float2(_48, _49),
      t0,
      s0,
      _119);
  _129 = renodx_chromatic_aberration_input.x;
  _130 = renodx_chromatic_aberration_input.y;
  _131 = renodx_chromatic_aberration_input.z;
  float4 _133 = t12.SampleLevel(s0, float2(_48, _49), 0.0f);
  float4 _139 = t8.Sample(s8, float2(_50, _51));
  int _145 = asint((User_000.UserConstant_Z_000[3].z));
  bool _146 = ((int)_145 > (int)0);
  float _175;
  float _176;
  float _177;
  float _182;
  float _183;
  float _184;
  float _213;
  float _214;
  float _215;
  float _220;
  float _221;
  float _222;
  float _342;
  float _351;
  float _360;
  float _408;
  float _409;
  float _410;
  if (!_146) {
    bool _150 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _154 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _139.x;
    float _155 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _139.y;
    float _156 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _139.z;
    float _157 = _154 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _158 = _155 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _159 = _156 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_150) {
      float _161 = _157 * _133.x;
      float _162 = _158 * _133.y;
      float _163 = _159 * _133.z;
      _175 = _161;
      _176 = _162;
      _177 = _163;
    } else {
      float _165 = saturate(_157);
      float _166 = saturate(_158);
      float _167 = saturate(_159);
      float _168 = _133.x - _129;
      float _169 = _133.y - _130;
      float _170 = _133.z - _131;
      float _171 = _165 * _168;
      float _172 = _166 * _169;
      float _173 = _167 * _170;
      _175 = _171;
      _176 = _172;
      _177 = _173;
    }
    float _178 = _175 + _129;
    float _179 = _176 + _130;
    float _180 = _177 + _131;
    _182 = _178;
    _183 = _179;
    _184 = _180;
  } else {
    _182 = _129;
    _183 = _130;
    _184 = _131;
  }
  if (_146) {
    bool _188 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _192 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _139.x;
    float _193 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _139.y;
    float _194 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _139.z;
    float _195 = _192 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _196 = _193 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _197 = _194 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_188) {
      float _199 = _195 * _133.x;
      float _200 = _196 * _133.y;
      float _201 = _197 * _133.z;
      _213 = _199;
      _214 = _200;
      _215 = _201;
    } else {
      float _203 = saturate(_195);
      float _204 = saturate(_196);
      float _205 = saturate(_197);
      float _206 = _133.x - _182;
      float _207 = _133.y - _183;
      float _208 = _133.z - _184;
      float _209 = _203 * _206;
      float _210 = _204 * _207;
      float _211 = _205 * _208;
      _213 = _209;
      _214 = _210;
      _215 = _211;
    }
    float _216 = _213 + _182;
    float _217 = _214 + _183;
    float _218 = _215 + _184;
    _220 = _216;
    _221 = _217;
    _222 = _218;
  } else {
    _220 = _182;
    _221 = _183;
    _222 = _184;
  }
  float4 _226 = t17.Load(int3(0, 0, 0));
  float _232 = _226.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _233 = _232 * _220;
  float _234 = _233 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _235 = _232 * _221;
  float _236 = _235 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _237 = _232 * _222;
  float _238 = _237 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _243 = _48 * 2.0f;
  float _244 = _49 * 2.0f;
  float _245 = _243 + -1.0f;
  float _246 = _244 + -1.0f;
  float _249 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _246;
  float _250 = _245 * _245;
  float _251 = _249 * _249;
  float _252 = _251 + _250;
  float _253 = sqrt(_252);
  float _255 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _253;
  float _257 = _255 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _258 = saturate(_257);
  float _260 = log2(_258);
  float _261 = _260 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _262 = exp2(_261);
  float _263 = _234 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _264 = _236 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _265 = _238 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _266 = _263 - _234;
  float _267 = _264 - _236;
  float _268 = _265 - _238;
  float _269 = _262 * _266;
  float _270 = _262 * _267;
  float _271 = _262 * _268;
  float _272 = _269 + _234;
  float _273 = _270 + _236;
  float _274 = _271 + _238;
  float _278 = _272 * 335.718017578125f;
  float _279 = _273 * 335.718017578125f;
  float _280 = _274 * 335.718017578125f;
  float _281 = _278 + 1.0f;
  float _282 = _279 + 1.0f;
  float _283 = _280 + 1.0f;
  float _284 = log2(_281);
  float _285 = log2(_282);
  float _286 = log2(_283);
  float _287 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _288 = _287 * _284;
  float _289 = _287 * _285;
  float _290 = _286 * _287;
  float _291 = _288 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _292 = _289 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _293 = _290 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _296 = t3.Sample(s3, float3(_291, _292, _293));
  float _300 = _296.x * 13.450128555297852f;
  float _301 = _296.y * 13.450128555297852f;
  float _302 = _296.z * 13.450128555297852f;
  float _303 = exp2(_300);
  float _304 = exp2(_301);
  float _305 = exp2(_302);
  float _306 = _303 + -1.0f;
  float _307 = _304 + -1.0f;
  float _308 = _305 + -1.0f;
  float _309 = _306 * 0.0029786902014166117f;
  float _310 = _307 * 0.0029786902014166117f;
  float _311 = _308 * 0.0029786902014166117f;
  float _316 = _309 * (User_000.UserConstant_Z_000[4].x);
  float _317 = _310 * (User_000.UserConstant_Z_000[4].y);
  float _318 = _311 * (User_000.UserConstant_Z_000[4].z);
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_309, _310, _311),
      float3(_316, _317, _318),
      User_000.UserConstant_Z_000[4].rgb);
  resonance_scaled_lut_output = ResonanceApplyPerceptualFilmGrain(resonance_scaled_lut_output, SV_Position.xy);
  _316 = resonance_scaled_lut_output.x;
  _317 = resonance_scaled_lut_output.y;
  _318 = resonance_scaled_lut_output.z;
  bool _321 = !((PostProcess_000.PostProcessConstant_Z_000[17].x) == 0.0f) && !ResonanceIsPsychoV();
  if (_321) {
    float _331 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _316;
    float _332 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _317;
    float _333 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _318;
    bool _334 = (_331 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_334) {
      float _336 = _331 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _337 = 1.0f - _336;
      float _338 = _337 * _337;
      float _339 = _338 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _340 = _339 + _331;
      _342 = _340;
    } else {
      _342 = _331;
    }
    bool _343 = (_332 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_343) {
      float _345 = _332 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _346 = 1.0f - _345;
      float _347 = _346 * _346;
      float _348 = _347 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _349 = _348 + _332;
      _351 = _349;
    } else {
      _351 = _332;
    }
    bool _352 = (_333 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_352) {
      float _354 = _333 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _355 = 1.0f - _354;
      float _356 = _355 * _355;
      float _357 = _356 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _358 = _357 + _333;
      _360 = _358;
    } else {
      _360 = _333;
    }
    float _361 = _342 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _362 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
    float _363 = log2(_361);
    float _364 = _363 * _362;
    float _365 = exp2(_364);
    float _366 = _365 + -1.0f;
    float _367 = _361 + -1.0f;
    float _368 = _366 / _367;
    bool _369 = !(_361 == 1.0f);
    float _370 = _368 + -1.0f;
    float _371 = _370 / _368;
    float _372 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _373 = _372 / _362;
    float _374 = select(_369, _371, _373);
    float _375 = _374 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _376 = _351 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _377 = log2(_376);
    float _378 = _377 * _362;
    float _379 = exp2(_378);
    float _380 = _379 + -1.0f;
    float _381 = _376 + -1.0f;
    float _382 = _380 / _381;
    bool _383 = !(_376 == 1.0f);
    float _384 = _382 + -1.0f;
    float _385 = _384 / _382;
    float _386 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _387 = _386 / _362;
    float _388 = select(_383, _385, _387);
    float _389 = _388 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _390 = _360 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _391 = log2(_390);
    float _392 = _391 * _362;
    float _393 = exp2(_392);
    float _394 = _393 + -1.0f;
    float _395 = _390 + -1.0f;
    float _396 = _394 / _395;
    bool _397 = !(_390 == 1.0f);
    float _398 = _396 + -1.0f;
    float _399 = _398 / _396;
    float _400 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _401 = _400 / _362;
    float _402 = select(_397, _399, _401);
    float _403 = _402 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _404 = _375 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _405 = _389 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _406 = _403 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    _408 = _404;
    _409 = _405;
    _410 = _406;
  } else {
    _408 = _316;
    _409 = _317;
    _410 = _318;
  }
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_316, _317, _318),
      float3(_408, _409, _410),
      false);
  _408 = resonance_post_process_output.x;
  _409 = resonance_post_process_output.y;
  _410 = resonance_post_process_output.z;
  float _411 = log2(_408);
  float _412 = log2(_409);
  float _413 = log2(_410);
  float _414 = _411 * 0.4166666567325592f;
  float _415 = _412 * 0.4166666567325592f;
  float _416 = _413 * 0.4166666567325592f;
  float _417 = exp2(_414);
  float _418 = exp2(_415);
  float _419 = exp2(_416);
  float _420 = _417 * 1.0549999475479126f;
  float _421 = _418 * 1.0549999475479126f;
  float _422 = _419 * 1.0549999475479126f;
  float _423 = _420 + -0.054999999701976776f;
  float _424 = _421 + -0.054999999701976776f;
  float _425 = _422 + -0.054999999701976776f;
  float _426 = _408 * 12.920000076293945f;
  float _427 = _409 * 12.920000076293945f;
  float _428 = _410 * 12.920000076293945f;
  bool _429 = (_408 <= 0.0031308000907301903f);
  bool _430 = (_409 <= 0.0031308000907301903f);
  bool _431 = (_410 <= 0.0031308000907301903f);
  float _432 = select(_429, _426, _423);
  float _433 = select(_430, _427, _424);
  float _434 = select(_431, _428, _425);
  float _435 = log2(_432);
  float _436 = log2(_433);
  float _437 = log2(_434);
  float _438 = floor(_435);
  float _439 = floor(_436);
  float _440 = floor(_437);
  float _441 = _438 + -6.0f;
  float _442 = _439 + -6.0f;
  float _443 = _440 + -5.0f;
  float _444 = exp2(_441);
  float _445 = exp2(_442);
  float _446 = exp2(_443);
  bool _447 = (_432 <= 0.0f);
  bool _448 = (_433 <= 0.0f);
  bool _449 = (_434 <= 0.0f);
  float _450 = select(_447, 0.0f, _444);
  float _451 = select(_448, 0.0f, _445);
  float _452 = select(_449, 0.0f, _446);
  int _455 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _456 = uint(SV_Position.x);
  uint _457 = uint(SV_Position.y);
  int _458 = _456 & 63;
  int _459 = _457 & 63;
  float4 _461 = t1.Load(int4(_458, _459, _455, 0));
  float4 _464 = t2.Load(int4(_458, _459, _455, 0));
  float _467 = _461.x * _450;
  float _468 = _464.x * _451;
  float _469 = _464.y * _452;
  float _470 = _467 + _432;
  float _471 = _468 + _433;
  float _472 = _469 + _434;
  SV_Target.x = _470;
  SV_Target.y = _471;
  SV_Target.z = _472;
  SV_Target.w = _126.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}