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

Texture2DArray<float4> t6 : register(t6);

Texture2D<float4> t0 : register(t0);

Texture2D<float4> t2 : register(t2);

Texture3D<float4> t3 : register(t3);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t7 : register(t7);

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

SamplerState s2 : register(s2);

SamplerState s3 : register(s3);

SamplerState s4 : register(s4);

SamplerState s5 : register(s5);

SamplerState s7 : register(s7);

SamplerState s8 : register(s8);

SamplerState s9 : register(s9);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _39 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _45 = t16.Sample(s0, float2(TEXCOORD.z, TEXCOORD.w));
  float _48 = _45.y * 0.10000000149011612f;
  float _49 = _48 + _39.y;
  float _50 = _45.y * 0.5f;
  float _51 = _50 + _39.z;
  float _52 = exp2(_51);
  float _53 = _52 + -1.0f;
  float _56 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _53;
  float _57 = _56 + 1.0f;
  float _58 = log2(_57);
  float _59 = _39.x + TEXCOORD.z;
  float _60 = _49 + TEXCOORD.w;
  float _61 = _39.x + TEXCOORD.x;
  float _62 = _49 + TEXCOORD.y;
  float _63 = _58 + 1.0f;
  float _64 = log2(_63);
  float _68 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].x);
  float _69 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].y);
  float _70 = _68 + _59;
  float _71 = _69 + _60;
  float _72 = _70 * 2.0f;
  float _73 = _71 * 2.0f;
  float _74 = _72 + -1.0f;
  float _75 = _73 + -1.0f;
  float _79 = _75 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].y);
  float _80 = abs(_74);
  float _81 = abs(_75);
  float _83 = (PostProcess_000.PostProcessConstant_Z_000[19].z) * 2.0f;
  float _84 = _83 + -1.0f;
  float _85 = _80 - _84;
  float _86 = _81 - _84;
  float _87 = saturate(_85);
  float _88 = saturate(_86);
  float _89 = _87 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].x);
  float _90 = _89 * _74;
  float _91 = _79 * _88;
  float _92 = _90 * _90;
  float _93 = _91 * _91;
  float _94 = _92 + _93;
  float _95 = sqrt(_94);
  float _98 = _68 + _61;
  float _99 = _69 + _62;
  float _100 = _98 * 2.0f;
  float _101 = _100 + -1.0f;
  float _102 = _99 * 1.125f;
  float _103 = _102 + -0.5625f;
  float _104 = _101 * _101;
  float _105 = _103 * _103;
  float _106 = _104 + _105;
  float _107 = sqrt(_106);
  float _108 = _107 * 0.8715755343437195f;
  float _109 = _108 * _108;
  float _110 = _109 + -0.15000000596046448f;
  float _111 = _110 * 1.8181819915771484f;
  float _112 = saturate(_111);
  float _113 = _112 * 2.0f;
  float _114 = 3.0f - _113;
  float _115 = (PostProcess_000.PostProcessConstant_Z_000[2].w) * _95;
  float _116 = _112 * _112;
  float _117 = _116 * _115;
  float _118 = _117 * _109;
  float _119 = _118 * _114;
  float _121 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _90;
  float _122 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _91;
  float _123 = _122 + _60;
  float _124 = _59 - _121;
  float _125 = _45.x * 0.010840999893844128f;
  float _126 = _59 + _125;
  float _127 = _126 + _121;
  float _128 = _60 + _125;
  float _129 = _128 - _122;
  float _130 = max(_119, _64);
  float4 _133 = t0.SampleLevel(s0, float2(_127, _123), _130);
  float4 _135 = t0.SampleLevel(s0, float2(_124, _129), _130);
  float4 _137 = t0.SampleLevel(s0, float2(_59, _60), _130);
  float _140 = max(_133.x, 0.0f);
  float _141 = max(_135.y, 0.0f);
  float _142 = max(_137.z, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_140, _141, _142),
      max(_137.rgb, 0.f.xxx),
      float2(_59, _60),
      t0,
      s0,
      _130);
  _140 = renodx_chromatic_aberration_input.x;
  _141 = renodx_chromatic_aberration_input.y;
  _142 = renodx_chromatic_aberration_input.z;
  float4 _144 = t12.SampleLevel(s0, float2(_59, _60), 0.0f);
  float4 _150 = t8.Sample(s8, float2(_61, _62));
  int _156 = asint((User_000.UserConstant_Z_000[3].z));
  bool _157 = ((int)_156 > (int)0);
  float _186;
  float _187;
  float _188;
  float _193;
  float _194;
  float _195;
  float _224;
  float _309;
  float _346;
  float _536;
  float _575;
  float _576;
  float _577;
  float _606;
  float _607;
  float _608;
  float _613;
  float _614;
  float _615;
  float _723;
  if (!_157) {
    bool _161 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _165 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _150.x;
    float _166 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _150.y;
    float _167 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _150.z;
    float _168 = _165 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _169 = _166 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _170 = _167 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_161) {
      float _172 = _168 * _144.x;
      float _173 = _169 * _144.y;
      float _174 = _170 * _144.z;
      _186 = _172;
      _187 = _173;
      _188 = _174;
    } else {
      float _176 = saturate(_168);
      float _177 = saturate(_169);
      float _178 = saturate(_170);
      float _179 = _144.x - _140;
      float _180 = _144.y - _141;
      float _181 = _144.z - _142;
      float _182 = _176 * _179;
      float _183 = _177 * _180;
      float _184 = _178 * _181;
      _186 = _182;
      _187 = _183;
      _188 = _184;
    }
    float _189 = _186 + _140;
    float _190 = _187 + _141;
    float _191 = _188 + _142;
    _193 = _189;
    _194 = _190;
    _195 = _191;
  } else {
    _193 = _140;
    _194 = _141;
    _195 = _142;
  }
  [branch]
  if (_157) {
    bool _200 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_200) {
      float _202 = _39.x + TEXCOORD.x;
      float _203 = _49 + TEXCOORD.y;
      float4 _206 = t2.SampleLevel(s2, float2(_202, _203), 0.0f);
      bool _210 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_210) {
        float4 _213 = t7.Load(int3(0, 0, 0));
        float _218 = _213.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _219 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _218;
        _224 = _219;
      } else {
        _224 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _228 = _206.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _229 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _228;
      float _231 = _224 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _232 = _231 + _224;
      float _233 = _224 - _231;
      float _234 = max(_229, _233);
      float _235 = min(_234, _232);
      float _238 = _229 - _235;
      float _239 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _238;
      float _241 = _235 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _242 = _241 * _229;
      float _243 = _239 / _242;
      float _244 = min(_243, 0.0f);
      float _246 = _231 + 1.0f;
      float _247 = 1.0f / _246;
      float _248 = _244 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _249 = max(0.0f, _243);
      float _252 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _249;
      float _253 = _252 + _248;
      float _254 = _253 * _247;
      float _255 = max(_254, -1.0f);
      float _256 = min(_255, 1.0f);
      float _257 = max(_256, -0.30000001192092896f);
      float _258 = min(_257, 1.0f);
      float _260 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _261 = _258 * _260;
      float _262 = _202 + -0.5f;
      float _263 = _203 + -0.5f;
      float _264 = _262 * _262;
      float _265 = _263 * _263;
      float _266 = _265 + _264;
      float _267 = sqrt(_266);
      float _268 = log2(_267);
      float _269 = _268 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _270 = exp2(_269);
      float _271 = _270 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _272 = dot(float2(_262, _263), float2(_262, _263));
      float _273 = rsqrt(_272);
      float _274 = _273 * _262;
      float _275 = _273 * _263;
      float _276 = abs(_261);
      float _280 = _271 * _276;
      float _281 = -0.0f - _280;
      float _282 = (User_000.UserConstant_Z_000[2].x) * _274;
      float _283 = _282 * _281;
      float _284 = (User_000.UserConstant_Z_000[2].y) * _275;
      float _285 = _284 * _281;
      float _286 = _276 * _271;
      float _287 = _282 * _286;
      float _288 = _284 * _286;
      float _289 = _287 + _202;
      float _290 = _288 + _203;
      float _291 = _283 + _127;
      float _292 = _285 + _123;
      float _293 = max(_64, _130);
      float4 _294 = t0.SampleLevel(s0, float2(_291, _292), _293);
      float4 _296 = t0.SampleLevel(s0, float2(_289, _290), _293);
      float4 _298 = t2.SampleLevel(s2, float2(_291, _292), 0.0f);
      if (_210) {
        float4 _302 = t7.Load(int3(0, 0, 0));
        float _304 = _302.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _305 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _304;
        _309 = _305;
      } else {
        _309 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _310 = _298.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _311 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _310;
      float _312 = _309 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _313 = _312 + _309;
      float _314 = _309 - _312;
      float _315 = max(_311, _314);
      float _316 = min(_315, _313);
      float _317 = _311 - _316;
      float _318 = _317 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _319 = _316 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _320 = _319 * _311;
      float _321 = _318 / _320;
      float _322 = min(_321, 0.0f);
      float _323 = _312 + 1.0f;
      float _324 = 1.0f / _323;
      float _325 = _322 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _326 = max(0.0f, _321);
      float _327 = _326 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _328 = _327 + _325;
      float _329 = _328 * _324;
      float _330 = max(_329, -1.0f);
      float _331 = min(_330, 1.0f);
      float _332 = max(_331, -0.30000001192092896f);
      float _333 = min(_332, 1.0f);
      float _334 = _333 * _260;
      float4 _335 = t2.SampleLevel(s2, float2(_289, _290), 0.0f);
      if (_210) {
        float4 _339 = t7.Load(int3(0, 0, 0));
        float _341 = _339.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _342 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _341;
        _346 = _342;
      } else {
        _346 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _347 = _335.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _348 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _347;
      float _349 = _346 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _350 = _349 + _346;
      float _351 = _346 - _349;
      float _352 = max(_348, _351);
      float _353 = min(_352, _350);
      float _354 = _348 - _353;
      float _355 = _354 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _356 = _353 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _357 = _356 * _348;
      float _358 = _355 / _357;
      float _359 = min(_358, 0.0f);
      float _360 = _349 + 1.0f;
      float _361 = 1.0f / _360;
      float _362 = _359 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _363 = max(0.0f, _358);
      float _364 = _363 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _365 = _364 + _362;
      float _366 = _365 * _361;
      float _367 = max(_366, -1.0f);
      float _368 = min(_367, 1.0f);
      float _369 = max(_368, -0.30000001192092896f);
      float _370 = min(_369, 1.0f);
      float _371 = _370 * _260;
      float _372 = abs(_334);
      float _373 = _372 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _374 = ceil(_373);
      float _375 = saturate(_374);
      float _376 = _294.x - _193;
      float _377 = _375 * _376;
      float _378 = _377 + _193;
      float _379 = abs(_371);
      float _380 = _379 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _381 = ceil(_380);
      float _382 = saturate(_381);
      float _383 = _296.z - _195;
      float _384 = _382 * _383;
      float _385 = _384 + _195;
      _575 = _378;
      _576 = _194;
      _577 = _385;
    } else {
      _575 = _193;
      _576 = _194;
      _577 = _195;
    }
  } else {
    int _388 = asint((User_000.UserConstant_Z_000[3].y));
    bool _389 = ((int)_388 > (int)0);
    if (_389) {
      float _391 = _39.x + TEXCOORD.x;
      float _392 = _49 + TEXCOORD.y;
      float4 _395 = t4.Sample(s4, float2(_391, _392));
      float4 _402 = t5.Sample(s5, float2(_391, _392));
      float _406 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _402.x;
      float _410 = _406 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _411 = _406 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _412 = _410 + _391;
      float _413 = _411 + _392;
      float4 _414 = t4.Sample(s4, float2(_412, _413));
      float4 _416 = t5.Sample(s5, float2(_412, _413));
      float _418 = _416.x * (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _419 = abs(_418);
      float _421 = _419 / (PostProcess_000.PostProcessConstant_Z_000[7].w);
      float _422 = _414.z - _395.z;
      float _423 = _421 * _422;
      float _424 = _395.x - _193;
      float _425 = _395.y - _194;
      float _426 = _395.z - _195;
      float _427 = _426 + _423;
      float _428 = _424 * _395.w;
      float _429 = _425 * _395.w;
      float _430 = _427 * _395.w;
      float _431 = _428 + _193;
      float _432 = _429 + _194;
      float _433 = _430 + _195;
      _575 = _431;
      _576 = _432;
      _577 = _433;
    } else {
      int _436 = asint((User_000.UserConstant_Z_000[3].x));
      bool _437 = ((int)_436 > (int)0);
      [branch]
      if (_437) {
        float4 _441 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _443 = abs(_441.x);
        _536 = _443;
      } else {
        float4 _447 = t2.SampleLevel(s2, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _449 = TEXCOORD.x * 2.0f;
        float _450 = TEXCOORD.y * 2.0f;
        float _451 = _449 + -1.0f;
        float _452 = _450 + -1.0f;
        float _473 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _451;
        float _474 = mad(_452, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _473);
        float _475 = mad(_447.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _474);
        float _476 = _475 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _477 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _451;
        float _478 = mad(_452, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _477);
        float _479 = mad(_447.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _478);
        float _480 = _479 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _481 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _451;
        float _482 = mad(_452, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _481);
        float _483 = mad(_447.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _482);
        float _484 = _483 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _485 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _451;
        float _486 = mad(_452, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _485);
        float _487 = mad(_447.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _486);
        float _488 = _487 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
        float _489 = _476 / _488;
        float _490 = _480 / _488;
        float _491 = _484 / _488;
        float _492 = _489 * _489;
        float _493 = _490 * _490;
        float _494 = _493 + _492;
        float _495 = _491 * _491;
        float _496 = _494 + _495;
        float _497 = sqrt(_496);
        float4 _500 = t5.Sample(s5, float2(TEXCOORD.x, TEXCOORD.y));
        float _506 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _507 = _506 + (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _508 = (PostProcess_000.PostProcessConstant_Z_000[5].x) - _506;
        float _509 = max(_497, _508);
        float _510 = min(_509, _507);
        float _512 = _497 - _510;
        float _513 = _512 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
        float _515 = _510 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _516 = _515 * _497;
        float _517 = _513 / _516;
        float _518 = min(_517, 0.0f);
        float _521 = _506 + 1.0f;
        float _522 = 1.0f / _521;
        float _523 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _518;
        float _524 = max(0.0f, _517);
        float _527 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _524;
        float _528 = _527 + _523;
        float _529 = _528 * _522;
        float _530 = min(_500.x, _529);
        float _531 = abs(_530);
        float _532 = abs(_529);
        float _533 = max(_531, _532);
        float _534 = saturate(_533);
        _536 = _534;
      }
      float _539 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _536;
      float4 _542 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _549 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _539;
      float _550 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _539;
      float _551 = _549 + TEXCOORD.x;
      float _552 = _550 + TEXCOORD.y;
      float4 _553 = t4.Sample(s4, float2(_551, _552));
      float4 _557 = t5.Sample(s5, float2(_551, _552));
      float _559 = abs(_557.x);
      float _560 = _553.z - _542.z;
      float _561 = _559 * _560;
      float _562 = _539 + -1.0f;
      float _563 = saturate(_562);
      float _564 = _542.x - _193;
      float _565 = _542.y - _194;
      float _566 = _542.z - _195;
      float _567 = _566 + _561;
      float _568 = _563 * _564;
      float _569 = _563 * _565;
      float _570 = _567 * _563;
      float _571 = _568 + _193;
      float _572 = _569 + _194;
      float _573 = _570 + _195;
      _575 = _571;
      _576 = _572;
      _577 = _573;
    }
  }
  if (_157) {
    bool _581 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _585 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _150.x;
    float _586 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _150.y;
    float _587 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _150.z;
    float _588 = _585 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _589 = _586 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _590 = _587 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_581) {
      float _592 = _588 * _144.x;
      float _593 = _589 * _144.y;
      float _594 = _590 * _144.z;
      _606 = _592;
      _607 = _593;
      _608 = _594;
    } else {
      float _596 = saturate(_588);
      float _597 = saturate(_589);
      float _598 = saturate(_590);
      float _599 = _144.x - _575;
      float _600 = _144.y - _576;
      float _601 = _144.z - _577;
      float _602 = _596 * _599;
      float _603 = _597 * _600;
      float _604 = _598 * _601;
      _606 = _602;
      _607 = _603;
      _608 = _604;
    }
    float _609 = _606 + _575;
    float _610 = _607 + _576;
    float _611 = _608 + _577;
    _613 = _609;
    _614 = _610;
    _615 = _611;
  } else {
    _613 = _575;
    _614 = _576;
    _615 = _577;
  }
  float4 _619 = t17.Load(int3(0, 0, 0));
  float _628 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 335.718017578125f;
  float _629 = _619.x * _628;
  float _630 = _629 * _613;
  float _631 = _630 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _632 = _629 * _614;
  float _633 = _632 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _634 = _629 * _615;
  float _635 = _634 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _636 = _631 + 1.0f;
  float _637 = _633 + 1.0f;
  float _638 = _635 + 1.0f;
  float _639 = log2(_636);
  float _640 = log2(_637);
  float _641 = log2(_638);
  float _642 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _643 = _642 * _639;
  float _644 = _642 * _640;
  float _645 = _641 * _642;
  float _646 = _643 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _647 = _644 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _648 = _645 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _651 = t3.Sample(s3, float3(_646, _647, _648));
  float _655 = _651.x * 13.450128555297852f;
  float _656 = _651.y * 13.450128555297852f;
  float _657 = _651.z * 13.450128555297852f;
  float _658 = exp2(_655);
  float _659 = exp2(_656);
  float _660 = exp2(_657);
  float _661 = _658 + -1.0f;
  float _662 = _659 + -1.0f;
  float _663 = _660 + -1.0f;
  float _664 = _661 * 0.0029786902014166117f;
  float _665 = _662 * 0.0029786902014166117f;
  float _666 = _663 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_631 * 0.0029786902014166117f, _633 * 0.0029786902014166117f, _635 * 0.0029786902014166117f),
      float3(_664 * (User_000.UserConstant_Z_000[4].x), _665 * (User_000.UserConstant_Z_000[4].y), _666 * (User_000.UserConstant_Z_000[4].z)),
      User_000.UserConstant_Z_000[4].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(apt_scaled_lut_output, SV_Position.xy);
  float _671 = apt_scaled_lut_output.x;
  float _672 = apt_scaled_lut_output.y;
  float _673 = apt_scaled_lut_output.z;
  float _679 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _680 = _679 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _681 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _682 = _681 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _685 = _680 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _686 = _682 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _689 = t9.Sample(s9, float2(_685, _686));
  float _693 = dot(float3(_671, _672, _673), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _696 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _699 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _700 = select(_696, _699, 0);
  float _701 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _702 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _703 = uint(_701);
  uint _704 = uint(_702);
  int _705 = _703 & 63;
  int _706 = _704 & 63;
  float4 _708 = t6.Load(int4(_705, _706, _700, 0));
  bool _710 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_710) {
    float _712 = _701 * 0.015625f;
    float _713 = _702 * 0.015625f;
    float _714 = float((uint)_699);
    float _715 = select(_696, _714, 0.0f);
    float4 _717 = t6.SampleLevel(s1, float3(_712, _713, _715), 0.0f);
    float _719 = _708.y - _717.y;
    float _720 = _719 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _721 = _720 + _717.y;
    _723 = _721;
  } else {
    _723 = _708.y;
  }
  float _724 = _689.x * -2.0f;
  float _725 = _724 * _723;
  float _726 = _723 * 2.0f;
  float _727 = _726 * _689.y;
  float _728 = _726 * _689.z;
  float _729 = _725 + _689.x;
  float _730 = _727 - _689.y;
  float _731 = _728 - _689.z;
  float _732 = _729 * _689.x;
  float _733 = _730 * _689.y;
  float _734 = _731 * _689.z;
  float _735 = _693 + 1.0f;
  float _736 = _693 / _735;
  float _737 = _736 + -9.999999747378752e-05f;
  float _738 = _737 * 1111.111083984375f;
  float _739 = saturate(_738);
  float _740 = _739 * 2.0f;
  float _741 = 3.0f - _740;
  float _742 = _739 * _739;
  float _743 = _742 * _741;
  bool _745 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _746 = float((bool)_745);
  float _747 = dot(float3(_732, _733, _734), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _748 = _747 - _732;
  float _749 = _747 - _733;
  float _750 = _747 - _734;
  float _751 = _748 * _746;
  float _752 = _749 * _746;
  float _753 = _750 * _746;
  float _754 = _751 + _732;
  float _755 = _752 + _733;
  float _756 = _753 + _734;
  float _760 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _761 = _760 * _736;
  float _762 = _761 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _763 = _743 * _762;
  float _764 = _763 * _754;
  float _765 = _763 * _755;
  float _766 = _763 * _756;
  float _767 = _764 + _671;
  float _768 = _765 + _672;
  float _769 = _766 + _673;
  float _770 = max(0.0f, _767);
  float _771 = max(0.0f, _768);
  float _772 = max(0.0f, _769);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_770, _771, _772),
      apt_scaled_lut_output);
  _770 = apt_film_grain_output.x;
  _771 = apt_film_grain_output.y;
  _772 = apt_film_grain_output.z;
  float _775 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _776 = log2(_770);
  float _777 = _775 * _776;
  float _778 = exp2(_777);
  float _779 = _778 + -1.0f;
  float _780 = _770 + -1.0f;
  float _781 = _779 / _780;
  bool _782 = !(_770 == 1.0f);
  float _783 = _781 + -1.0f;
  float _784 = _783 / _781;
  float _785 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _786 = _785 / _775;
  float _787 = select(_782, _784, _786);
  float _788 = log2(_771);
  float _789 = _788 * _775;
  float _790 = exp2(_789);
  float _791 = _790 + -1.0f;
  float _792 = _771 + -1.0f;
  float _793 = _791 / _792;
  bool _794 = !(_771 == 1.0f);
  float _795 = _793 + -1.0f;
  float _796 = _795 / _793;
  float _797 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _798 = _797 / _775;
  float _799 = select(_794, _796, _798);
  float _800 = log2(_772);
  float _801 = _800 * _775;
  float _802 = exp2(_801);
  float _803 = _802 + -1.0f;
  float _804 = _772 + -1.0f;
  float _805 = _803 / _804;
  bool _806 = !(_772 == 1.0f);
  float _807 = _805 + -1.0f;
  float _808 = _807 / _805;
  float _809 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _810 = _809 / _775;
  float _811 = select(_806, _808, _810);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_770, _771, _772),
      float3(_787, _799, _811),
      true);
  float _812 = apt_post_process_output.x;
  float _813 = apt_post_process_output.y;
  float _814 = apt_post_process_output.z;
  float _815 = log2(_812);
  float _816 = log2(_813);
  float _817 = log2(_814);
  float _818 = _815 * 0.4166666567325592f;
  float _819 = _816 * 0.4166666567325592f;
  float _820 = _817 * 0.4166666567325592f;
  float _821 = exp2(_818);
  float _822 = exp2(_819);
  float _823 = exp2(_820);
  float _824 = _821 * 1.0549999475479126f;
  float _825 = _822 * 1.0549999475479126f;
  float _826 = _823 * 1.0549999475479126f;
  float _827 = _824 + -0.054999999701976776f;
  float _828 = _825 + -0.054999999701976776f;
  float _829 = _826 + -0.054999999701976776f;
  float _830 = _812 * 12.920000076293945f;
  float _831 = _813 * 12.920000076293945f;
  float _832 = _814 * 12.920000076293945f;
  bool _833 = (_812 <= 0.0031308000907301903f);
  bool _834 = (_813 <= 0.0031308000907301903f);
  bool _835 = (_814 <= 0.0031308000907301903f);
  float _836 = select(_833, _830, _827);
  float _837 = select(_834, _831, _828);
  float _838 = select(_835, _832, _829);
  float _839 = log2(_836);
  float _840 = log2(_837);
  float _841 = log2(_838);
  float _842 = floor(_839);
  float _843 = floor(_840);
  float _844 = floor(_841);
  float _845 = _842 + -6.0f;
  float _846 = _843 + -6.0f;
  float _847 = _844 + -5.0f;
  float _848 = exp2(_845);
  float _849 = exp2(_846);
  float _850 = exp2(_847);
  bool _851 = (_836 <= 0.0f);
  bool _852 = (_837 <= 0.0f);
  bool _853 = (_838 <= 0.0f);
  float _854 = select(_851, 0.0f, _848);
  float _855 = select(_852, 0.0f, _849);
  float _856 = select(_853, 0.0f, _850);
  uint _857 = uint(SV_Position.x);
  uint _858 = uint(SV_Position.y);
  int _859 = _857 & 63;
  int _860 = _858 & 63;
  float4 _862 = t1.Load(int4(_859, _860, _699, 0));
  float4 _864 = t6.Load(int4(_859, _860, _699, 0));
  float _867 = _862.x * _854;
  float _868 = _864.x * _855;
  float _869 = _864.y * _856;
  float _870 = _867 + _836;
  float _871 = _868 + _837;
  float _872 = _869 + _838;
  SV_Target.x = _870;
  SV_Target.y = _871;
  SV_Target.z = _872;
  SV_Target.w = _137.w;
  return SV_Target;
}
