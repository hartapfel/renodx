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
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
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
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_278 * 0.0029786902014166117f, _279 * 0.0029786902014166117f, _280 * 0.0029786902014166117f),
      float3(_309 * (User_000.UserConstant_Z_000[4].x), _310 * (User_000.UserConstant_Z_000[4].y), _311 * (User_000.UserConstant_Z_000[4].z)),
      User_000.UserConstant_Z_000[4].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(apt_scaled_lut_output, SV_Position.xy);
  float _318 = apt_scaled_lut_output.x;
  float _319 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _320 = log2(_318);
  float _321 = _319 * _320;
  float _322 = exp2(_321);
  float _323 = _322 + -1.0f;
  float _324 = _318 + -1.0f;
  float _325 = _323 / _324;
  bool _326 = !(_318 == 1.0f);
  float _327 = _325 + -1.0f;
  float _328 = _327 / _325;
  float _329 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _330 = _329 / _319;
  float _331 = select(_326, _328, _330);
  float _332 = apt_scaled_lut_output.y;
  float _333 = log2(_332);
  float _334 = _333 * _319;
  float _335 = exp2(_334);
  float _336 = _335 + -1.0f;
  float _337 = _332 + -1.0f;
  float _338 = _336 / _337;
  bool _339 = !(_332 == 1.0f);
  float _340 = _338 + -1.0f;
  float _341 = _340 / _338;
  float _342 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _343 = _342 / _319;
  float _344 = select(_339, _341, _343);
  float _345 = apt_scaled_lut_output.z;
  float _346 = log2(_345);
  float _347 = _346 * _319;
  float _348 = exp2(_347);
  float _349 = _348 + -1.0f;
  float _350 = _345 + -1.0f;
  float _351 = _349 / _350;
  bool _352 = !(_345 == 1.0f);
  float _353 = _351 + -1.0f;
  float _354 = _353 / _351;
  float _355 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _356 = _355 / _319;
  float _357 = select(_352, _354, _356);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_318, _332, _345),
      float3(_331, _344, _357),
      true);
  float _358 = apt_post_process_output.x;
  float _359 = apt_post_process_output.y;
  float _360 = apt_post_process_output.z;
  float _361 = log2(_358);
  float _362 = log2(_359);
  float _363 = log2(_360);
  float _364 = _361 * 0.4166666567325592f;
  float _365 = _362 * 0.4166666567325592f;
  float _366 = _363 * 0.4166666567325592f;
  float _367 = exp2(_364);
  float _368 = exp2(_365);
  float _369 = exp2(_366);
  float _370 = _367 * 1.0549999475479126f;
  float _371 = _368 * 1.0549999475479126f;
  float _372 = _369 * 1.0549999475479126f;
  float _373 = _370 + -0.054999999701976776f;
  float _374 = _371 + -0.054999999701976776f;
  float _375 = _372 + -0.054999999701976776f;
  float _376 = _358 * 12.920000076293945f;
  float _377 = _359 * 12.920000076293945f;
  float _378 = _360 * 12.920000076293945f;
  bool _379 = (_358 <= 0.0031308000907301903f);
  bool _380 = (_359 <= 0.0031308000907301903f);
  bool _381 = (_360 <= 0.0031308000907301903f);
  float _382 = select(_379, _376, _373);
  float _383 = select(_380, _377, _374);
  float _384 = select(_381, _378, _375);
  float _385 = log2(_382);
  float _386 = log2(_383);
  float _387 = log2(_384);
  float _388 = floor(_385);
  float _389 = floor(_386);
  float _390 = floor(_387);
  float _391 = _388 + -6.0f;
  float _392 = _389 + -6.0f;
  float _393 = _390 + -5.0f;
  float _394 = exp2(_391);
  float _395 = exp2(_392);
  float _396 = exp2(_393);
  bool _397 = (_382 <= 0.0f);
  bool _398 = (_383 <= 0.0f);
  bool _399 = (_384 <= 0.0f);
  float _400 = select(_397, 0.0f, _394);
  float _401 = select(_398, 0.0f, _395);
  float _402 = select(_399, 0.0f, _396);
  int _405 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _406 = uint(SV_Position.x);
  uint _407 = uint(SV_Position.y);
  int _408 = _406 & 63;
  int _409 = _407 & 63;
  float4 _411 = t1.Load(int4(_408, _409, _405, 0));
  float4 _414 = t2.Load(int4(_408, _409, _405, 0));
  float _417 = _411.x * _400;
  float _418 = _414.x * _401;
  float _419 = _414.y * _402;
  float _420 = _417 + _382;
  float _421 = _418 + _383;
  float _422 = _419 + _384;
  SV_Target.x = _420;
  SV_Target.y = _421;
  SV_Target.z = _422;
  SV_Target.w = _126.w;
  return SV_Target;
}
