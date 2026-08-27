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
  float _542;
  float _581;
  float _582;
  float _583;
  float _612;
  float _613;
  float _614;
  float _619;
  float _620;
  float _621;
  float _767;
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
      _581 = _378;
      _582 = _194;
      _583 = _385;
    } else {
      _581 = _193;
      _582 = _194;
      _583 = _195;
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
      _581 = _431;
      _582 = _432;
      _583 = _433;
    } else {
      int _436 = asint((User_000.UserConstant_Z_000[3].x));
      bool _437 = ((int)_436 > (int)0);
      [branch]
      if (_437) {
        float4 _441 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _443 = abs(_441.x);
        _542 = _443;
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
        float4 _502 = t7.Load(int3(0, 0, 0));
        float _507 = _502.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _508 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _507;
        float _511 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * _508;
        float _512 = _511 + _508;
        float _513 = _508 - _511;
        float _514 = max(_497, _513);
        float _515 = min(_514, _512);
        float _518 = _497 - _515;
        float _519 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _518;
        float _521 = _515 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _522 = _521 * _497;
        float _523 = _519 / _522;
        float _524 = min(_523, 0.0f);
        float _527 = _511 + 1.0f;
        float _528 = 1.0f / _527;
        float _529 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _524;
        float _530 = max(0.0f, _523);
        float _533 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _530;
        float _534 = _533 + _529;
        float _535 = _534 * _528;
        float _536 = min(_500.x, _535);
        float _537 = abs(_536);
        float _538 = abs(_535);
        float _539 = max(_537, _538);
        float _540 = saturate(_539);
        _542 = _540;
      }
      float _545 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _542;
      float4 _548 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _555 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _545;
      float _556 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _545;
      float _557 = _555 + TEXCOORD.x;
      float _558 = _556 + TEXCOORD.y;
      float4 _559 = t4.Sample(s4, float2(_557, _558));
      float4 _563 = t5.Sample(s5, float2(_557, _558));
      float _565 = abs(_563.x);
      float _566 = _559.z - _548.z;
      float _567 = _565 * _566;
      float _568 = _545 + -1.0f;
      float _569 = saturate(_568);
      float _570 = _548.x - _193;
      float _571 = _548.y - _194;
      float _572 = _548.z - _195;
      float _573 = _572 + _567;
      float _574 = _569 * _570;
      float _575 = _569 * _571;
      float _576 = _573 * _569;
      float _577 = _574 + _193;
      float _578 = _575 + _194;
      float _579 = _576 + _195;
      _581 = _577;
      _582 = _578;
      _583 = _579;
    }
  }
  if (_157) {
    bool _587 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _591 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _150.x;
    float _592 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _150.y;
    float _593 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _150.z;
    float _594 = _591 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _595 = _592 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _596 = _593 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_587) {
      float _598 = _594 * _144.x;
      float _599 = _595 * _144.y;
      float _600 = _596 * _144.z;
      _612 = _598;
      _613 = _599;
      _614 = _600;
    } else {
      float _602 = saturate(_594);
      float _603 = saturate(_595);
      float _604 = saturate(_596);
      float _605 = _144.x - _581;
      float _606 = _144.y - _582;
      float _607 = _144.z - _583;
      float _608 = _602 * _605;
      float _609 = _603 * _606;
      float _610 = _604 * _607;
      _612 = _608;
      _613 = _609;
      _614 = _610;
    }
    float _615 = _612 + _581;
    float _616 = _613 + _582;
    float _617 = _614 + _583;
    _619 = _615;
    _620 = _616;
    _621 = _617;
  } else {
    _619 = _581;
    _620 = _582;
    _621 = _583;
  }
  float4 _625 = t17.Load(int3(0, 0, 0));
  float _631 = _625.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _632 = _631 * _619;
  float _633 = _632 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _634 = _631 * _620;
  float _635 = _634 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _636 = _631 * _621;
  float _637 = _636 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _642 = _59 * 2.0f;
  float _643 = _60 * 2.0f;
  float _644 = _642 + -1.0f;
  float _645 = _643 + -1.0f;
  float _648 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _645;
  float _649 = _644 * _644;
  float _650 = _648 * _648;
  float _651 = _650 + _649;
  float _652 = sqrt(_651);
  float _654 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _652;
  float _656 = _654 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _657 = saturate(_656);
  float _659 = log2(_657);
  float _660 = _659 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _661 = exp2(_660);
  float _662 = _633 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _663 = _635 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _664 = _637 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _665 = _662 - _633;
  float _666 = _663 - _635;
  float _667 = _664 - _637;
  float _668 = _661 * _665;
  float _669 = _661 * _666;
  float _670 = _661 * _667;
  float _671 = _668 + _633;
  float _672 = _669 + _635;
  float _673 = _670 + _637;
  float _677 = _671 * 335.718017578125f;
  float _678 = _672 * 335.718017578125f;
  float _679 = _673 * 335.718017578125f;
  float _680 = _677 + 1.0f;
  float _681 = _678 + 1.0f;
  float _682 = _679 + 1.0f;
  float _683 = log2(_680);
  float _684 = log2(_681);
  float _685 = log2(_682);
  float _686 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _687 = _686 * _683;
  float _688 = _686 * _684;
  float _689 = _685 * _686;
  float _690 = _687 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _691 = _688 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _692 = _689 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _695 = t3.Sample(s3, float3(_690, _691, _692));
  float _699 = _695.x * 13.450128555297852f;
  float _700 = _695.y * 13.450128555297852f;
  float _701 = _695.z * 13.450128555297852f;
  float _702 = exp2(_699);
  float _703 = exp2(_700);
  float _704 = exp2(_701);
  float _705 = _702 + -1.0f;
  float _706 = _703 + -1.0f;
  float _707 = _704 + -1.0f;
  float _708 = _705 * 0.0029786902014166117f;
  float _709 = _706 * 0.0029786902014166117f;
  float _710 = _707 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_677 * 0.0029786902014166117f, _678 * 0.0029786902014166117f, _679 * 0.0029786902014166117f),
      float3(_708 * (User_000.UserConstant_Z_000[4].x), _709 * (User_000.UserConstant_Z_000[4].y), _710 * (User_000.UserConstant_Z_000[4].z)),
      User_000.UserConstant_Z_000[4].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(apt_scaled_lut_output, SV_Position.xy);
  float _715 = apt_scaled_lut_output.x;
  float _716 = apt_scaled_lut_output.y;
  float _717 = apt_scaled_lut_output.z;
  float _723 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _724 = _723 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _725 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _726 = _725 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _729 = _724 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _730 = _726 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _733 = t9.Sample(s9, float2(_729, _730));
  float _737 = dot(float3(_715, _716, _717), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _740 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _743 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _744 = select(_740, _743, 0);
  float _745 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _746 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _747 = uint(_745);
  uint _748 = uint(_746);
  int _749 = _747 & 63;
  int _750 = _748 & 63;
  float4 _752 = t6.Load(int4(_749, _750, _744, 0));
  bool _754 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_754) {
    float _756 = _745 * 0.015625f;
    float _757 = _746 * 0.015625f;
    float _758 = float((uint)_743);
    float _759 = select(_740, _758, 0.0f);
    float4 _761 = t6.SampleLevel(s1, float3(_756, _757, _759), 0.0f);
    float _763 = _752.y - _761.y;
    float _764 = _763 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _765 = _764 + _761.y;
    _767 = _765;
  } else {
    _767 = _752.y;
  }
  float _768 = _733.x * -2.0f;
  float _769 = _768 * _767;
  float _770 = _767 * 2.0f;
  float _771 = _770 * _733.y;
  float _772 = _770 * _733.z;
  float _773 = _769 + _733.x;
  float _774 = _771 - _733.y;
  float _775 = _772 - _733.z;
  float _776 = _773 * _733.x;
  float _777 = _774 * _733.y;
  float _778 = _775 * _733.z;
  float _779 = _737 + 1.0f;
  float _780 = _737 / _779;
  float _781 = _780 + -9.999999747378752e-05f;
  float _782 = _781 * 1111.111083984375f;
  float _783 = saturate(_782);
  float _784 = _783 * 2.0f;
  float _785 = 3.0f - _784;
  float _786 = _783 * _783;
  float _787 = _786 * _785;
  bool _789 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _790 = float((bool)_789);
  float _791 = dot(float3(_776, _777, _778), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _792 = _791 - _776;
  float _793 = _791 - _777;
  float _794 = _791 - _778;
  float _795 = _792 * _790;
  float _796 = _793 * _790;
  float _797 = _794 * _790;
  float _798 = _795 + _776;
  float _799 = _796 + _777;
  float _800 = _797 + _778;
  float _804 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _805 = _804 * _780;
  float _806 = _805 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _807 = _787 * _806;
  float _808 = _807 * _798;
  float _809 = _807 * _799;
  float _810 = _807 * _800;
  float _811 = _808 + _715;
  float _812 = _809 + _716;
  float _813 = _810 + _717;
  float _814 = max(0.0f, _811);
  float _815 = max(0.0f, _812);
  float _816 = max(0.0f, _813);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_814, _815, _816),
      apt_scaled_lut_output);
  float _831;
  float _843;
  float _855;
  [branch]
  if (!APTIsPsychoV()) {
    _814 = apt_film_grain_output.x;
    _815 = apt_film_grain_output.y;
    _816 = apt_film_grain_output.z;
    float _819 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
    float _820 = log2(_814);
    float _821 = _819 * _820;
    float _822 = exp2(_821);
    float _823 = _822 + -1.0f;
    float _824 = _814 + -1.0f;
    float _825 = _823 / _824;
    bool _826 = !(_814 == 1.0f);
    float _827 = _825 + -1.0f;
    float _828 = _827 / _825;
    float _829 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _830 = _829 / _819;
    _831 = select(_826, _828, _830);
    float _832 = log2(_815);
    float _833 = _832 * _819;
    float _834 = exp2(_833);
    float _835 = _834 + -1.0f;
    float _836 = _815 + -1.0f;
    float _837 = _835 / _836;
    bool _838 = !(_815 == 1.0f);
    float _839 = _837 + -1.0f;
    float _840 = _839 / _837;
    float _841 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _842 = _841 / _819;
    _843 = select(_838, _840, _842);
    float _844 = log2(_816);
    float _845 = _844 * _819;
    float _846 = exp2(_845);
    float _847 = _846 + -1.0f;
    float _848 = _816 + -1.0f;
    float _849 = _847 / _848;
    bool _850 = !(_816 == 1.0f);
    float _851 = _849 + -1.0f;
    float _852 = _851 / _849;
    float _853 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _854 = _853 / _819;
    _855 = select(_850, _852, _854);
  } else {
    _831 = 0.f;
    _843 = 0.f;
    _855 = 0.f;
  }
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      apt_film_grain_output,
      float3(_831, _843, _855),
      true);
  float _856 = apt_post_process_output.x;
  float _857 = apt_post_process_output.y;
  float _858 = apt_post_process_output.z;
  float _859 = log2(_856);
  float _860 = log2(_857);
  float _861 = log2(_858);
  float _862 = _859 * 0.4166666567325592f;
  float _863 = _860 * 0.4166666567325592f;
  float _864 = _861 * 0.4166666567325592f;
  float _865 = exp2(_862);
  float _866 = exp2(_863);
  float _867 = exp2(_864);
  float _868 = _865 * 1.0549999475479126f;
  float _869 = _866 * 1.0549999475479126f;
  float _870 = _867 * 1.0549999475479126f;
  float _871 = _868 + -0.054999999701976776f;
  float _872 = _869 + -0.054999999701976776f;
  float _873 = _870 + -0.054999999701976776f;
  float _874 = _856 * 12.920000076293945f;
  float _875 = _857 * 12.920000076293945f;
  float _876 = _858 * 12.920000076293945f;
  bool _877 = (_856 <= 0.0031308000907301903f);
  bool _878 = (_857 <= 0.0031308000907301903f);
  bool _879 = (_858 <= 0.0031308000907301903f);
  float _880 = select(_877, _874, _871);
  float _881 = select(_878, _875, _872);
  float _882 = select(_879, _876, _873);
  float _883 = log2(_880);
  float _884 = log2(_881);
  float _885 = log2(_882);
  float _886 = floor(_883);
  float _887 = floor(_884);
  float _888 = floor(_885);
  float _889 = _886 + -6.0f;
  float _890 = _887 + -6.0f;
  float _891 = _888 + -5.0f;
  float _892 = exp2(_889);
  float _893 = exp2(_890);
  float _894 = exp2(_891);
  bool _895 = (_880 <= 0.0f);
  bool _896 = (_881 <= 0.0f);
  bool _897 = (_882 <= 0.0f);
  float _898 = select(_895, 0.0f, _892);
  float _899 = select(_896, 0.0f, _893);
  float _900 = select(_897, 0.0f, _894);
  uint _901 = uint(SV_Position.x);
  uint _902 = uint(SV_Position.y);
  int _903 = _901 & 63;
  int _904 = _902 & 63;
  float4 _906 = t1.Load(int4(_903, _904, _743, 0));
  float4 _908 = t6.Load(int4(_903, _904, _743, 0));
  float _911 = _906.x * _898;
  float _912 = _908.x * _899;
  float _913 = _908.y * _900;
  float _914 = _911 + _880;
  float _915 = _912 + _881;
  float _916 = _913 + _882;
  SV_Target.x = _914;
  SV_Target.y = _915;
  SV_Target.z = _916;
  SV_Target.w = _137.w;
  return SV_Target;
}
