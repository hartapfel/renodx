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
  float4 SV_Target;
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
  float _304;
  float _313;
  float _322;
  float _370;
  float _371;
  float _372;
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
  float _235 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 335.718017578125f;
  float _236 = _226.x * _235;
  float _237 = _236 * _220;
  float _238 = _237 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _239 = _236 * _221;
  float _240 = _239 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _241 = _236 * _222;
  float _242 = _241 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _243 = _238 + 1.0f;
  float _244 = _240 + 1.0f;
  float _245 = _242 + 1.0f;
  float _246 = log2(_243);
  float _247 = log2(_244);
  float _248 = log2(_245);
  float _249 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _250 = _249 * _246;
  float _251 = _249 * _247;
  float _252 = _248 * _249;
  float _253 = _250 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _254 = _251 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _255 = _252 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _258 = t3.Sample(s3, float3(_253, _254, _255));
  float _262 = _258.x * 13.450128555297852f;
  float _263 = _258.y * 13.450128555297852f;
  float _264 = _258.z * 13.450128555297852f;
  float _265 = exp2(_262);
  float _266 = exp2(_263);
  float _267 = exp2(_264);
  float _268 = _265 + -1.0f;
  float _269 = _266 + -1.0f;
  float _270 = _267 + -1.0f;
  float _271 = _268 * 0.0029786902014166117f;
  float _272 = _269 * 0.0029786902014166117f;
  float _273 = _270 * 0.0029786902014166117f;
  float _278 = _271 * (User_000.UserConstant_Z_000[4].x);
  float _279 = _272 * (User_000.UserConstant_Z_000[4].y);
  float _280 = _273 * (User_000.UserConstant_Z_000[4].z);
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_238, _240, _242) * 0.0029786902014166117f,
      float3(_278, _279, _280),
      User_000.UserConstant_Z_000[4].rgb);
  resonance_scaled_lut_output = ResonanceApplyPerceptualFilmGrain(resonance_scaled_lut_output, SV_Position.xy);
  _278 = resonance_scaled_lut_output.x;
  _279 = resonance_scaled_lut_output.y;
  _280 = resonance_scaled_lut_output.z;
  bool _283 = !((PostProcess_000.PostProcessConstant_Z_000[17].x) == 0.0f) && !ResonanceIsPsychoV();
  if (_283) {
    float _293 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _278;
    float _294 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _279;
    float _295 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _280;
    bool _296 = (_293 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_296) {
      float _298 = _293 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _299 = 1.0f - _298;
      float _300 = _299 * _299;
      float _301 = _300 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _302 = _301 + _293;
      _304 = _302;
    } else {
      _304 = _293;
    }
    bool _305 = (_294 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_305) {
      float _307 = _294 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _308 = 1.0f - _307;
      float _309 = _308 * _308;
      float _310 = _309 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _311 = _310 + _294;
      _313 = _311;
    } else {
      _313 = _294;
    }
    bool _314 = (_295 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_314) {
      float _316 = _295 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _317 = 1.0f - _316;
      float _318 = _317 * _317;
      float _319 = _318 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _320 = _319 + _295;
      _322 = _320;
    } else {
      _322 = _295;
    }
    float _323 = _304 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _324 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
    float _325 = log2(_323);
    float _326 = _325 * _324;
    float _327 = exp2(_326);
    float _328 = _327 + -1.0f;
    float _329 = _323 + -1.0f;
    float _330 = _328 / _329;
    bool _331 = !(_323 == 1.0f);
    float _332 = _330 + -1.0f;
    float _333 = _332 / _330;
    float _334 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _335 = _334 / _324;
    float _336 = select(_331, _333, _335);
    float _337 = _336 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _338 = _313 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _339 = log2(_338);
    float _340 = _339 * _324;
    float _341 = exp2(_340);
    float _342 = _341 + -1.0f;
    float _343 = _338 + -1.0f;
    float _344 = _342 / _343;
    bool _345 = !(_338 == 1.0f);
    float _346 = _344 + -1.0f;
    float _347 = _346 / _344;
    float _348 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _349 = _348 / _324;
    float _350 = select(_345, _347, _349);
    float _351 = _350 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _352 = _322 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _353 = log2(_352);
    float _354 = _353 * _324;
    float _355 = exp2(_354);
    float _356 = _355 + -1.0f;
    float _357 = _352 + -1.0f;
    float _358 = _356 / _357;
    bool _359 = !(_352 == 1.0f);
    float _360 = _358 + -1.0f;
    float _361 = _360 / _358;
    float _362 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _363 = _362 / _324;
    float _364 = select(_359, _361, _363);
    float _365 = _364 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _366 = _337 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _367 = _351 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _368 = _365 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    _370 = _366;
    _371 = _367;
    _372 = _368;
  } else {
    _370 = _278;
    _371 = _279;
    _372 = _280;
  }
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_278, _279, _280),
      float3(_370, _371, _372),
      false);
  _370 = resonance_post_process_output.x;
  _371 = resonance_post_process_output.y;
  _372 = resonance_post_process_output.z;
  float _373 = log2(_370);
  float _374 = log2(_371);
  float _375 = log2(_372);
  float _376 = _373 * 0.4166666567325592f;
  float _377 = _374 * 0.4166666567325592f;
  float _378 = _375 * 0.4166666567325592f;
  float _379 = exp2(_376);
  float _380 = exp2(_377);
  float _381 = exp2(_378);
  float _382 = _379 * 1.0549999475479126f;
  float _383 = _380 * 1.0549999475479126f;
  float _384 = _381 * 1.0549999475479126f;
  float _385 = _382 + -0.054999999701976776f;
  float _386 = _383 + -0.054999999701976776f;
  float _387 = _384 + -0.054999999701976776f;
  float _388 = _370 * 12.920000076293945f;
  float _389 = _371 * 12.920000076293945f;
  float _390 = _372 * 12.920000076293945f;
  bool _391 = (_370 <= 0.0031308000907301903f);
  bool _392 = (_371 <= 0.0031308000907301903f);
  bool _393 = (_372 <= 0.0031308000907301903f);
  float _394 = select(_391, _388, _385);
  float _395 = select(_392, _389, _386);
  float _396 = select(_393, _390, _387);
  float _397 = log2(_394);
  float _398 = log2(_395);
  float _399 = log2(_396);
  float _400 = floor(_397);
  float _401 = floor(_398);
  float _402 = floor(_399);
  float _403 = _400 + -6.0f;
  float _404 = _401 + -6.0f;
  float _405 = _402 + -5.0f;
  float _406 = exp2(_403);
  float _407 = exp2(_404);
  float _408 = exp2(_405);
  bool _409 = (_394 <= 0.0f);
  bool _410 = (_395 <= 0.0f);
  bool _411 = (_396 <= 0.0f);
  float _412 = select(_409, 0.0f, _406);
  float _413 = select(_410, 0.0f, _407);
  float _414 = select(_411, 0.0f, _408);
  int _417 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _418 = uint(SV_Position.x);
  uint _419 = uint(SV_Position.y);
  int _420 = _418 & 63;
  int _421 = _419 & 63;
  float4 _423 = t1.Load(int4(_420, _421, _417, 0));
  float4 _426 = t2.Load(int4(_420, _421, _417, 0));
  float _429 = _423.x * _412;
  float _430 = _426.x * _413;
  float _431 = _426.y * _414;
  float _432 = _429 + _394;
  float _433 = _430 + _395;
  float _434 = _431 + _396;
  SV_Target.x = _432;
  SV_Target.y = _433;
  SV_Target.z = _434;
  SV_Target.w = _126.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}