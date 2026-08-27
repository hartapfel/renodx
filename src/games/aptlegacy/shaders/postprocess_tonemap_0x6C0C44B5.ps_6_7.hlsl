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

SamplerState s0 : register(s0);

SamplerState s1 : register(s1);

SamplerState s3 : register(s3);

SamplerState s8 : register(s8);

SamplerState s9 : register(s9);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target = 0;
  float4 _31 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _37 = t16.Sample(s0, float2(TEXCOORD.z, TEXCOORD.w));
  float _40 = _37.y * 0.10000000149011612f;
  float _41 = _40 + _31.y;
  float _42 = _37.y * 0.5f;
  float _43 = _42 + _31.z;
  float _44 = exp2(_43);
  float _45 = _44 + -1.0f;
  float _48 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _45;
  float _49 = _48 + 1.0f;
  float _50 = log2(_49);
  float _51 = _31.x + TEXCOORD.z;
  float _52 = _41 + TEXCOORD.w;
  float _53 = _31.x + TEXCOORD.x;
  float _54 = _41 + TEXCOORD.y;
  float _55 = _50 + 1.0f;
  float _56 = log2(_55);
  float _60 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].x);
  float _61 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].y);
  float _62 = _60 + _51;
  float _63 = _61 + _52;
  float _64 = _62 * 2.0f;
  float _65 = _63 * 2.0f;
  float _66 = _64 + -1.0f;
  float _67 = _65 + -1.0f;
  float _71 = _67 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].y);
  float _72 = abs(_66);
  float _73 = abs(_67);
  float _75 = (PostProcess_000.PostProcessConstant_Z_000[19].z) * 2.0f;
  float _76 = _75 + -1.0f;
  float _77 = _72 - _76;
  float _78 = _73 - _76;
  float _79 = saturate(_77);
  float _80 = saturate(_78);
  float _81 = _79 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].x);
  float _82 = _81 * _66;
  float _83 = _71 * _80;
  float _84 = _82 * _82;
  float _85 = _83 * _83;
  float _86 = _84 + _85;
  float _87 = sqrt(_86);
  float _90 = _60 + _53;
  float _91 = _61 + _54;
  float _92 = _90 * 2.0f;
  float _93 = _92 + -1.0f;
  float _94 = _91 * 1.125f;
  float _95 = _94 + -0.5625f;
  float _96 = _93 * _93;
  float _97 = _95 * _95;
  float _98 = _96 + _97;
  float _99 = sqrt(_98);
  float _100 = _99 * 0.8715755343437195f;
  float _101 = _100 * _100;
  float _102 = _101 + -0.15000000596046448f;
  float _103 = _102 * 1.8181819915771484f;
  float _104 = saturate(_103);
  float _105 = _104 * 2.0f;
  float _106 = 3.0f - _105;
  float _107 = (PostProcess_000.PostProcessConstant_Z_000[2].w) * _87;
  float _108 = _104 * _104;
  float _109 = _108 * _107;
  float _110 = _109 * _101;
  float _111 = _110 * _106;
  float _113 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _82;
  float _114 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _83;
  float _115 = _114 + _52;
  float _116 = _51 - _113;
  float _117 = _37.x * 0.010840999893844128f;
  float _118 = _117 + _51;
  float _119 = _118 + _113;
  float _120 = _52 + _117;
  float _121 = _120 - _114;
  float _122 = max(_111, _56);
  float4 _125 = t0.SampleLevel(s0, float2(_119, _115), _122);
  float4 _127 = t0.SampleLevel(s0, float2(_116, _121), _122);
  float4 _129 = t0.SampleLevel(s0, float2(_51, _52), _122);
  float _132 = max(_125.x, 0.0f);
  float _133 = max(_127.y, 0.0f);
  float _134 = max(_129.z, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_132, _133, _134),
      max(_129.rgb, 0.f.xxx),
      float2(_51, _52),
      t0,
      s0,
      _122);
  _132 = renodx_chromatic_aberration_input.x;
  _133 = renodx_chromatic_aberration_input.y;
  _134 = renodx_chromatic_aberration_input.z;
  float4 _136 = t12.SampleLevel(s0, float2(_51, _52), 0.0f);
  float4 _142 = t8.Sample(s8, float2(_53, _54));
  int _148 = asint((User_000.UserConstant_Z_000[3].z));
  bool _149 = ((int)_148 > (int)0);
  float _178;
  float _179;
  float _180;
  float _185;
  float _186;
  float _187;
  float _216;
  float _217;
  float _218;
  float _223;
  float _224;
  float _225;
  float _333;
  float _405;
  float _414;
  float _423;
  float _471;
  float _472;
  float _473;
  if (!_149) {
    bool _153 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _157 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _142.x;
    float _158 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _142.y;
    float _159 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _142.z;
    float _160 = _157 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _161 = _158 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _162 = _159 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_153) {
      float _164 = _160 * _136.x;
      float _165 = _161 * _136.y;
      float _166 = _162 * _136.z;
      _178 = _164;
      _179 = _165;
      _180 = _166;
    } else {
      float _168 = saturate(_160);
      float _169 = saturate(_161);
      float _170 = saturate(_162);
      float _171 = _136.x - _132;
      float _172 = _136.y - _133;
      float _173 = _136.z - _134;
      float _174 = _168 * _171;
      float _175 = _169 * _172;
      float _176 = _170 * _173;
      _178 = _174;
      _179 = _175;
      _180 = _176;
    }
    float _181 = _178 + _132;
    float _182 = _179 + _133;
    float _183 = _180 + _134;
    _185 = _181;
    _186 = _182;
    _187 = _183;
  } else {
    _185 = _132;
    _186 = _133;
    _187 = _134;
  }
  if (_149) {
    bool _191 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _195 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _142.x;
    float _196 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _142.y;
    float _197 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _142.z;
    float _198 = _195 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _199 = _196 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _200 = _197 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_191) {
      float _202 = _198 * _136.x;
      float _203 = _199 * _136.y;
      float _204 = _200 * _136.z;
      _216 = _202;
      _217 = _203;
      _218 = _204;
    } else {
      float _206 = saturate(_198);
      float _207 = saturate(_199);
      float _208 = saturate(_200);
      float _209 = _136.x - _185;
      float _210 = _136.y - _186;
      float _211 = _136.z - _187;
      float _212 = _206 * _209;
      float _213 = _207 * _210;
      float _214 = _208 * _211;
      _216 = _212;
      _217 = _213;
      _218 = _214;
    }
    float _219 = _216 + _185;
    float _220 = _217 + _186;
    float _221 = _218 + _187;
    _223 = _219;
    _224 = _220;
    _225 = _221;
  } else {
    _223 = _185;
    _224 = _186;
    _225 = _187;
  }
  float4 _229 = t17.Load(int3(0, 0, 0));
  float _238 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 335.718017578125f;
  float _239 = _229.x * _238;
  float _240 = _239 * _223;
  float _241 = _240 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _242 = _239 * _224;
  float _243 = _242 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _244 = _239 * _225;
  float _245 = _244 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _246 = _241 + 1.0f;
  float _247 = _243 + 1.0f;
  float _248 = _245 + 1.0f;
  float _249 = log2(_246);
  float _250 = log2(_247);
  float _251 = log2(_248);
  float _252 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _253 = _252 * _249;
  float _254 = _252 * _250;
  float _255 = _251 * _252;
  float _256 = _253 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _257 = _254 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _258 = _255 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _261 = t3.Sample(s3, float3(_256, _257, _258));
  float _265 = _261.x * 13.450128555297852f;
  float _266 = _261.y * 13.450128555297852f;
  float _267 = _261.z * 13.450128555297852f;
  float _268 = exp2(_265);
  float _269 = exp2(_266);
  float _270 = exp2(_267);
  float _271 = _268 + -1.0f;
  float _272 = _269 + -1.0f;
  float _273 = _270 + -1.0f;
  float _274 = _271 * 0.0029786902014166117f;
  float _275 = _272 * 0.0029786902014166117f;
  float _276 = _273 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_241 * 0.0029786902014166117f, _243 * 0.0029786902014166117f, _245 * 0.0029786902014166117f),
      float3(_274 * (User_000.UserConstant_Z_000[4].x), _275 * (User_000.UserConstant_Z_000[4].y), _276 * (User_000.UserConstant_Z_000[4].z)),
      User_000.UserConstant_Z_000[4].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(apt_scaled_lut_output, SV_Position.xy);
  float _281 = apt_scaled_lut_output.x;
  float _282 = apt_scaled_lut_output.y;
  float _283 = apt_scaled_lut_output.z;
  float _289 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _290 = _289 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _291 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _292 = _291 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _295 = _290 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _296 = _292 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _299 = t9.Sample(s9, float2(_295, _296));
  float _303 = dot(float3(_281, _282, _283), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _306 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _309 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _310 = select(_306, _309, 0);
  float _311 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _312 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _313 = uint(_311);
  uint _314 = uint(_312);
  int _315 = _313 & 63;
  int _316 = _314 & 63;
  float4 _318 = t2.Load(int4(_315, _316, _310, 0));
  bool _320 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_320) {
    float _322 = _311 * 0.015625f;
    float _323 = _312 * 0.015625f;
    float _324 = float((uint)_309);
    float _325 = select(_306, _324, 0.0f);
    float4 _327 = t2.SampleLevel(s1, float3(_322, _323, _325), 0.0f);
    float _329 = _318.y - _327.y;
    float _330 = _329 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _331 = _330 + _327.y;
    _333 = _331;
  } else {
    _333 = _318.y;
  }
  float _334 = _299.x * -2.0f;
  float _335 = _334 * _333;
  float _336 = _333 * 2.0f;
  float _337 = _336 * _299.y;
  float _338 = _336 * _299.z;
  float _339 = _335 + _299.x;
  float _340 = _337 - _299.y;
  float _341 = _338 - _299.z;
  float _342 = _339 * _299.x;
  float _343 = _340 * _299.y;
  float _344 = _341 * _299.z;
  float _345 = _303 + 1.0f;
  float _346 = _303 / _345;
  float _347 = _346 + -9.999999747378752e-05f;
  float _348 = _347 * 1111.111083984375f;
  float _349 = saturate(_348);
  float _350 = _349 * 2.0f;
  float _351 = 3.0f - _350;
  float _352 = _349 * _349;
  float _353 = _352 * _351;
  bool _355 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _356 = float((bool)_355);
  float _357 = dot(float3(_342, _343, _344), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _358 = _357 - _342;
  float _359 = _357 - _343;
  float _360 = _357 - _344;
  float _361 = _358 * _356;
  float _362 = _359 * _356;
  float _363 = _360 * _356;
  float _364 = _361 + _342;
  float _365 = _362 + _343;
  float _366 = _363 + _344;
  float _370 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _371 = _370 * _346;
  float _372 = _371 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _373 = _353 * _372;
  float _374 = _373 * _364;
  float _375 = _373 * _365;
  float _376 = _373 * _366;
  float _377 = _374 + _281;
  float _378 = _375 + _282;
  float _379 = _376 + _283;
  float _380 = max(0.0f, _377);
  float _381 = max(0.0f, _378);
  float _382 = max(0.0f, _379);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_380, _381, _382),
      apt_scaled_lut_output);
  _380 = apt_film_grain_output.x;
  _381 = apt_film_grain_output.y;
  _382 = apt_film_grain_output.z;
  bool _385 = !((PostProcess_000.PostProcessConstant_Z_000[17].x) == 0.0f) && !APTIsPsychoV();
  if (_385) {
    float _394 = _380 * (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _395 = _381 * (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _396 = _382 * (PostProcess_000.PostProcessConstant_Z_000[10].w);
    bool _397 = (_394 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_397) {
      float _399 = _394 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _400 = 1.0f - _399;
      float _401 = _400 * _400;
      float _402 = _401 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _403 = _402 + _394;
      _405 = _403;
    } else {
      _405 = _394;
    }
    bool _406 = (_395 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_406) {
      float _408 = _395 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _409 = 1.0f - _408;
      float _410 = _409 * _409;
      float _411 = _410 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _412 = _411 + _395;
      _414 = _412;
    } else {
      _414 = _395;
    }
    bool _415 = (_396 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_415) {
      float _417 = _396 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _418 = 1.0f - _417;
      float _419 = _418 * _418;
      float _420 = _419 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _421 = _420 + _396;
      _423 = _421;
    } else {
      _423 = _396;
    }
    float _424 = _405 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _425 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
    float _426 = log2(_424);
    float _427 = _426 * _425;
    float _428 = exp2(_427);
    float _429 = _428 + -1.0f;
    float _430 = _424 + -1.0f;
    float _431 = _429 / _430;
    bool _432 = !(_424 == 1.0f);
    float _433 = _431 + -1.0f;
    float _434 = _433 / _431;
    float _435 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _436 = _435 / _425;
    float _437 = select(_432, _434, _436);
    float _438 = _437 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _439 = _414 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _440 = log2(_439);
    float _441 = _440 * _425;
    float _442 = exp2(_441);
    float _443 = _442 + -1.0f;
    float _444 = _439 + -1.0f;
    float _445 = _443 / _444;
    bool _446 = !(_439 == 1.0f);
    float _447 = _445 + -1.0f;
    float _448 = _447 / _445;
    float _449 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _450 = _449 / _425;
    float _451 = select(_446, _448, _450);
    float _452 = _451 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _453 = _423 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _454 = log2(_453);
    float _455 = _454 * _425;
    float _456 = exp2(_455);
    float _457 = _456 + -1.0f;
    float _458 = _453 + -1.0f;
    float _459 = _457 / _458;
    bool _460 = !(_453 == 1.0f);
    float _461 = _459 + -1.0f;
    float _462 = _461 / _459;
    float _463 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _464 = _463 / _425;
    float _465 = select(_460, _462, _464);
    float _466 = _465 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _467 = _438 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _468 = _452 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _469 = _466 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    _471 = _467;
    _472 = _468;
    _473 = _469;
  } else {
    _471 = _380;
    _472 = _381;
    _473 = _382;
  }
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_380, _381, _382),
      float3(_471, _472, _473),
      false);
  _471 = apt_post_process_output.x;
  _472 = apt_post_process_output.y;
  _473 = apt_post_process_output.z;
  float _474 = log2(_471);
  float _475 = log2(_472);
  float _476 = log2(_473);
  float _477 = _474 * 0.4166666567325592f;
  float _478 = _475 * 0.4166666567325592f;
  float _479 = _476 * 0.4166666567325592f;
  float _480 = exp2(_477);
  float _481 = exp2(_478);
  float _482 = exp2(_479);
  float _483 = _480 * 1.0549999475479126f;
  float _484 = _481 * 1.0549999475479126f;
  float _485 = _482 * 1.0549999475479126f;
  float _486 = _483 + -0.054999999701976776f;
  float _487 = _484 + -0.054999999701976776f;
  float _488 = _485 + -0.054999999701976776f;
  float _489 = _471 * 12.920000076293945f;
  float _490 = _472 * 12.920000076293945f;
  float _491 = _473 * 12.920000076293945f;
  bool _492 = (_471 <= 0.0031308000907301903f);
  bool _493 = (_472 <= 0.0031308000907301903f);
  bool _494 = (_473 <= 0.0031308000907301903f);
  float _495 = select(_492, _489, _486);
  float _496 = select(_493, _490, _487);
  float _497 = select(_494, _491, _488);
  float _498 = log2(_495);
  float _499 = log2(_496);
  float _500 = log2(_497);
  float _501 = floor(_498);
  float _502 = floor(_499);
  float _503 = floor(_500);
  float _504 = _501 + -6.0f;
  float _505 = _502 + -6.0f;
  float _506 = _503 + -5.0f;
  float _507 = exp2(_504);
  float _508 = exp2(_505);
  float _509 = exp2(_506);
  bool _510 = (_495 <= 0.0f);
  bool _511 = (_496 <= 0.0f);
  bool _512 = (_497 <= 0.0f);
  float _513 = select(_510, 0.0f, _507);
  float _514 = select(_511, 0.0f, _508);
  float _515 = select(_512, 0.0f, _509);
  uint _516 = uint(SV_Position.x);
  uint _517 = uint(SV_Position.y);
  int _518 = _516 & 63;
  int _519 = _517 & 63;
  float4 _521 = t1.Load(int4(_518, _519, _309, 0));
  float4 _523 = t2.Load(int4(_518, _519, _309, 0));
  float _526 = _521.x * _513;
  float _527 = _523.x * _514;
  float _528 = _523.y * _515;
  float _529 = _526 + _495;
  float _530 = _527 + _496;
  float _531 = _528 + _497;
  SV_Target.x = _529;
  SV_Target.y = _530;
  SV_Target.z = _531;
  SV_Target.w = _129.w;
  return SV_Target;
}
