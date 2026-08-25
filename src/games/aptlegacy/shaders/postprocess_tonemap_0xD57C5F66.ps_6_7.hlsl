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
  float4 SV_Target;
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
  float _371;
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
  float _235 = _229.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _236 = _235 * _223;
  float _237 = _236 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _238 = _235 * _224;
  float _239 = _238 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _240 = _235 * _225;
  float _241 = _240 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _246 = _51 * 2.0f;
  float _247 = _52 * 2.0f;
  float _248 = _246 + -1.0f;
  float _249 = _247 + -1.0f;
  float _252 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _249;
  float _253 = _248 * _248;
  float _254 = _252 * _252;
  float _255 = _254 + _253;
  float _256 = sqrt(_255);
  float _258 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _256;
  float _260 = _258 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _261 = saturate(_260);
  float _263 = log2(_261);
  float _264 = _263 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _265 = exp2(_264);
  float _266 = _237 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _267 = _239 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _268 = _241 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _269 = _266 - _237;
  float _270 = _267 - _239;
  float _271 = _268 - _241;
  float _272 = _265 * _269;
  float _273 = _265 * _270;
  float _274 = _265 * _271;
  float _275 = _272 + _237;
  float _276 = _273 + _239;
  float _277 = _274 + _241;
  float _281 = _275 * 335.718017578125f;
  float _282 = _276 * 335.718017578125f;
  float _283 = _277 * 335.718017578125f;
  float _284 = _281 + 1.0f;
  float _285 = _282 + 1.0f;
  float _286 = _283 + 1.0f;
  float _287 = log2(_284);
  float _288 = log2(_285);
  float _289 = log2(_286);
  float _290 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _291 = _290 * _287;
  float _292 = _290 * _288;
  float _293 = _289 * _290;
  float _294 = _291 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _295 = _292 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _296 = _293 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _299 = t3.Sample(s3, float3(_294, _295, _296));
  float _303 = _299.x * 13.450128555297852f;
  float _304 = _299.y * 13.450128555297852f;
  float _305 = _299.z * 13.450128555297852f;
  float _306 = exp2(_303);
  float _307 = exp2(_304);
  float _308 = exp2(_305);
  float _309 = _306 + -1.0f;
  float _310 = _307 + -1.0f;
  float _311 = _308 + -1.0f;
  float _312 = _309 * 0.0029786902014166117f;
  float _313 = _310 * 0.0029786902014166117f;
  float _314 = _311 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_281 * 0.0029786902014166117f, _282 * 0.0029786902014166117f, _283 * 0.0029786902014166117f),
      float3(_312 * (User_000.UserConstant_Z_000[4].x), _313 * (User_000.UserConstant_Z_000[4].y), _314 * (User_000.UserConstant_Z_000[4].z)),
      User_000.UserConstant_Z_000[4].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(apt_scaled_lut_output, SV_Position.xy);
  float _319 = apt_scaled_lut_output.x;
  float _320 = apt_scaled_lut_output.y;
  float _321 = apt_scaled_lut_output.z;
  float _327 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _328 = _327 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _329 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _330 = _329 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _333 = _328 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _334 = _330 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _337 = t9.Sample(s9, float2(_333, _334));
  float _341 = dot(float3(_319, _320, _321), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _344 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _347 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _348 = select(_344, _347, 0);
  float _349 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _350 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _351 = uint(_349);
  uint _352 = uint(_350);
  int _353 = _351 & 63;
  int _354 = _352 & 63;
  float4 _356 = t2.Load(int4(_353, _354, _348, 0));
  bool _358 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_358) {
    float _360 = _349 * 0.015625f;
    float _361 = _350 * 0.015625f;
    float _362 = float((uint)_347);
    float _363 = select(_344, _362, 0.0f);
    float4 _365 = t2.SampleLevel(s1, float3(_360, _361, _363), 0.0f);
    float _367 = _356.y - _365.y;
    float _368 = _367 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _369 = _368 + _365.y;
    _371 = _369;
  } else {
    _371 = _356.y;
  }
  float _372 = _337.x * -2.0f;
  float _373 = _372 * _371;
  float _374 = _371 * 2.0f;
  float _375 = _374 * _337.y;
  float _376 = _374 * _337.z;
  float _377 = _373 + _337.x;
  float _378 = _375 - _337.y;
  float _379 = _376 - _337.z;
  float _380 = _377 * _337.x;
  float _381 = _378 * _337.y;
  float _382 = _379 * _337.z;
  float _383 = _341 + 1.0f;
  float _384 = _341 / _383;
  float _385 = _384 + -9.999999747378752e-05f;
  float _386 = _385 * 1111.111083984375f;
  float _387 = saturate(_386);
  float _388 = _387 * 2.0f;
  float _389 = 3.0f - _388;
  float _390 = _387 * _387;
  float _391 = _390 * _389;
  bool _393 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _394 = float((bool)_393);
  float _395 = dot(float3(_380, _381, _382), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _396 = _395 - _380;
  float _397 = _395 - _381;
  float _398 = _395 - _382;
  float _399 = _396 * _394;
  float _400 = _397 * _394;
  float _401 = _398 * _394;
  float _402 = _399 + _380;
  float _403 = _400 + _381;
  float _404 = _401 + _382;
  float _408 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _409 = _408 * _384;
  float _410 = _409 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _411 = _391 * _410;
  float _412 = _411 * _402;
  float _413 = _411 * _403;
  float _414 = _411 * _404;
  float _415 = _412 + _319;
  float _416 = _413 + _320;
  float _417 = _414 + _321;
  float _418 = max(0.0f, _415);
  float _419 = max(0.0f, _416);
  float _420 = max(0.0f, _417);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_418, _419, _420),
      apt_scaled_lut_output);
  _418 = apt_film_grain_output.x;
  _419 = apt_film_grain_output.y;
  _420 = apt_film_grain_output.z;
  float _423 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _424 = log2(_418);
  float _425 = _423 * _424;
  float _426 = exp2(_425);
  float _427 = _426 + -1.0f;
  float _428 = _418 + -1.0f;
  float _429 = _427 / _428;
  bool _430 = !(_418 == 1.0f);
  float _431 = _429 + -1.0f;
  float _432 = _431 / _429;
  float _433 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _434 = _433 / _423;
  float _435 = select(_430, _432, _434);
  float _436 = log2(_419);
  float _437 = _436 * _423;
  float _438 = exp2(_437);
  float _439 = _438 + -1.0f;
  float _440 = _419 + -1.0f;
  float _441 = _439 / _440;
  bool _442 = !(_419 == 1.0f);
  float _443 = _441 + -1.0f;
  float _444 = _443 / _441;
  float _445 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _446 = _445 / _423;
  float _447 = select(_442, _444, _446);
  float _448 = log2(_420);
  float _449 = _448 * _423;
  float _450 = exp2(_449);
  float _451 = _450 + -1.0f;
  float _452 = _420 + -1.0f;
  float _453 = _451 / _452;
  bool _454 = !(_420 == 1.0f);
  float _455 = _453 + -1.0f;
  float _456 = _455 / _453;
  float _457 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _458 = _457 / _423;
  float _459 = select(_454, _456, _458);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_418, _419, _420),
      float3(_435, _447, _459),
      true);
  float _460 = apt_post_process_output.x;
  float _461 = apt_post_process_output.y;
  float _462 = apt_post_process_output.z;
  float _463 = log2(_460);
  float _464 = log2(_461);
  float _465 = log2(_462);
  float _466 = _463 * 0.4166666567325592f;
  float _467 = _464 * 0.4166666567325592f;
  float _468 = _465 * 0.4166666567325592f;
  float _469 = exp2(_466);
  float _470 = exp2(_467);
  float _471 = exp2(_468);
  float _472 = _469 * 1.0549999475479126f;
  float _473 = _470 * 1.0549999475479126f;
  float _474 = _471 * 1.0549999475479126f;
  float _475 = _472 + -0.054999999701976776f;
  float _476 = _473 + -0.054999999701976776f;
  float _477 = _474 + -0.054999999701976776f;
  float _478 = _460 * 12.920000076293945f;
  float _479 = _461 * 12.920000076293945f;
  float _480 = _462 * 12.920000076293945f;
  bool _481 = (_460 <= 0.0031308000907301903f);
  bool _482 = (_461 <= 0.0031308000907301903f);
  bool _483 = (_462 <= 0.0031308000907301903f);
  float _484 = select(_481, _478, _475);
  float _485 = select(_482, _479, _476);
  float _486 = select(_483, _480, _477);
  float _487 = log2(_484);
  float _488 = log2(_485);
  float _489 = log2(_486);
  float _490 = floor(_487);
  float _491 = floor(_488);
  float _492 = floor(_489);
  float _493 = _490 + -6.0f;
  float _494 = _491 + -6.0f;
  float _495 = _492 + -5.0f;
  float _496 = exp2(_493);
  float _497 = exp2(_494);
  float _498 = exp2(_495);
  bool _499 = (_484 <= 0.0f);
  bool _500 = (_485 <= 0.0f);
  bool _501 = (_486 <= 0.0f);
  float _502 = select(_499, 0.0f, _496);
  float _503 = select(_500, 0.0f, _497);
  float _504 = select(_501, 0.0f, _498);
  uint _505 = uint(SV_Position.x);
  uint _506 = uint(SV_Position.y);
  int _507 = _505 & 63;
  int _508 = _506 & 63;
  float4 _510 = t1.Load(int4(_507, _508, _347, 0));
  float4 _512 = t2.Load(int4(_507, _508, _347, 0));
  float _515 = _510.x * _502;
  float _516 = _512.x * _503;
  float _517 = _512.y * _504;
  float _518 = _515 + _484;
  float _519 = _516 + _485;
  float _520 = _517 + _486;
  SV_Target.x = _518;
  SV_Target.y = _519;
  SV_Target.z = _520;
  SV_Target.w = _129.w;
  return SV_Target;
}
