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
  float _761;
  float _833;
  float _842;
  float _851;
  float _899;
  float _900;
  float _901;
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
  float _625 = _619.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _626 = _625 * _613;
  float _627 = _626 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _628 = _625 * _614;
  float _629 = _628 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _630 = _625 * _615;
  float _631 = _630 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _636 = _59 * 2.0f;
  float _637 = _60 * 2.0f;
  float _638 = _636 + -1.0f;
  float _639 = _637 + -1.0f;
  float _642 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _639;
  float _643 = _638 * _638;
  float _644 = _642 * _642;
  float _645 = _644 + _643;
  float _646 = sqrt(_645);
  float _648 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _646;
  float _650 = _648 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _651 = saturate(_650);
  float _653 = log2(_651);
  float _654 = _653 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _655 = exp2(_654);
  float _656 = _627 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _657 = _629 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _658 = _631 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _659 = _656 - _627;
  float _660 = _657 - _629;
  float _661 = _658 - _631;
  float _662 = _655 * _659;
  float _663 = _655 * _660;
  float _664 = _655 * _661;
  float _665 = _662 + _627;
  float _666 = _663 + _629;
  float _667 = _664 + _631;
  float _671 = _665 * 335.718017578125f;
  float _672 = _666 * 335.718017578125f;
  float _673 = _667 * 335.718017578125f;
  float _674 = _671 + 1.0f;
  float _675 = _672 + 1.0f;
  float _676 = _673 + 1.0f;
  float _677 = log2(_674);
  float _678 = log2(_675);
  float _679 = log2(_676);
  float _680 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _681 = _680 * _677;
  float _682 = _680 * _678;
  float _683 = _679 * _680;
  float _684 = _681 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _685 = _682 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _686 = _683 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _689 = t3.Sample(s3, float3(_684, _685, _686));
  float _693 = _689.x * 13.450128555297852f;
  float _694 = _689.y * 13.450128555297852f;
  float _695 = _689.z * 13.450128555297852f;
  float _696 = exp2(_693);
  float _697 = exp2(_694);
  float _698 = exp2(_695);
  float _699 = _696 + -1.0f;
  float _700 = _697 + -1.0f;
  float _701 = _698 + -1.0f;
  float _702 = _699 * 0.0029786902014166117f;
  float _703 = _700 * 0.0029786902014166117f;
  float _704 = _701 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_671 * 0.0029786902014166117f, _672 * 0.0029786902014166117f, _673 * 0.0029786902014166117f),
      float3(_702 * (User_000.UserConstant_Z_000[4].x), _703 * (User_000.UserConstant_Z_000[4].y), _704 * (User_000.UserConstant_Z_000[4].z)),
      User_000.UserConstant_Z_000[4].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(apt_scaled_lut_output, SV_Position.xy);
  float _709 = apt_scaled_lut_output.x;
  float _710 = apt_scaled_lut_output.y;
  float _711 = apt_scaled_lut_output.z;
  float _717 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _718 = _717 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _719 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _720 = _719 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _723 = _718 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _724 = _720 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _727 = t9.Sample(s9, float2(_723, _724));
  float _731 = dot(float3(_709, _710, _711), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _734 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _737 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _738 = select(_734, _737, 0);
  float _739 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _740 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _741 = uint(_739);
  uint _742 = uint(_740);
  int _743 = _741 & 63;
  int _744 = _742 & 63;
  float4 _746 = t6.Load(int4(_743, _744, _738, 0));
  bool _748 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_748) {
    float _750 = _739 * 0.015625f;
    float _751 = _740 * 0.015625f;
    float _752 = float((uint)_737);
    float _753 = select(_734, _752, 0.0f);
    float4 _755 = t6.SampleLevel(s1, float3(_750, _751, _753), 0.0f);
    float _757 = _746.y - _755.y;
    float _758 = _757 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _759 = _758 + _755.y;
    _761 = _759;
  } else {
    _761 = _746.y;
  }
  float _762 = _727.x * -2.0f;
  float _763 = _762 * _761;
  float _764 = _761 * 2.0f;
  float _765 = _764 * _727.y;
  float _766 = _764 * _727.z;
  float _767 = _763 + _727.x;
  float _768 = _765 - _727.y;
  float _769 = _766 - _727.z;
  float _770 = _767 * _727.x;
  float _771 = _768 * _727.y;
  float _772 = _769 * _727.z;
  float _773 = _731 + 1.0f;
  float _774 = _731 / _773;
  float _775 = _774 + -9.999999747378752e-05f;
  float _776 = _775 * 1111.111083984375f;
  float _777 = saturate(_776);
  float _778 = _777 * 2.0f;
  float _779 = 3.0f - _778;
  float _780 = _777 * _777;
  float _781 = _780 * _779;
  bool _783 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _784 = float((bool)_783);
  float _785 = dot(float3(_770, _771, _772), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _786 = _785 - _770;
  float _787 = _785 - _771;
  float _788 = _785 - _772;
  float _789 = _786 * _784;
  float _790 = _787 * _784;
  float _791 = _788 * _784;
  float _792 = _789 + _770;
  float _793 = _790 + _771;
  float _794 = _791 + _772;
  float _798 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _799 = _798 * _774;
  float _800 = _799 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _801 = _781 * _800;
  float _802 = _801 * _792;
  float _803 = _801 * _793;
  float _804 = _801 * _794;
  float _805 = _802 + _709;
  float _806 = _803 + _710;
  float _807 = _804 + _711;
  float _808 = max(0.0f, _805);
  float _809 = max(0.0f, _806);
  float _810 = max(0.0f, _807);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_808, _809, _810),
      apt_scaled_lut_output);
  _808 = apt_film_grain_output.x;
  _809 = apt_film_grain_output.y;
  _810 = apt_film_grain_output.z;
  bool _813 = !((PostProcess_000.PostProcessConstant_Z_000[17].x) == 0.0f);
  if (_813) {
    float _822 = _808 * (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _823 = _809 * (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _824 = _810 * (PostProcess_000.PostProcessConstant_Z_000[10].w);
    bool _825 = (_822 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_825) {
      float _827 = _822 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _828 = 1.0f - _827;
      float _829 = _828 * _828;
      float _830 = _829 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _831 = _830 + _822;
      _833 = _831;
    } else {
      _833 = _822;
    }
    bool _834 = (_823 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_834) {
      float _836 = _823 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _837 = 1.0f - _836;
      float _838 = _837 * _837;
      float _839 = _838 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _840 = _839 + _823;
      _842 = _840;
    } else {
      _842 = _823;
    }
    bool _843 = (_824 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_843) {
      float _845 = _824 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _846 = 1.0f - _845;
      float _847 = _846 * _846;
      float _848 = _847 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _849 = _848 + _824;
      _851 = _849;
    } else {
      _851 = _824;
    }
    float _852 = _833 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _853 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
    float _854 = log2(_852);
    float _855 = _854 * _853;
    float _856 = exp2(_855);
    float _857 = _856 + -1.0f;
    float _858 = _852 + -1.0f;
    float _859 = _857 / _858;
    bool _860 = !(_852 == 1.0f);
    float _861 = _859 + -1.0f;
    float _862 = _861 / _859;
    float _863 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _864 = _863 / _853;
    float _865 = select(_860, _862, _864);
    float _866 = _865 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _867 = _842 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _868 = log2(_867);
    float _869 = _868 * _853;
    float _870 = exp2(_869);
    float _871 = _870 + -1.0f;
    float _872 = _867 + -1.0f;
    float _873 = _871 / _872;
    bool _874 = !(_867 == 1.0f);
    float _875 = _873 + -1.0f;
    float _876 = _875 / _873;
    float _877 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _878 = _877 / _853;
    float _879 = select(_874, _876, _878);
    float _880 = _879 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _881 = _851 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _882 = log2(_881);
    float _883 = _882 * _853;
    float _884 = exp2(_883);
    float _885 = _884 + -1.0f;
    float _886 = _881 + -1.0f;
    float _887 = _885 / _886;
    bool _888 = !(_881 == 1.0f);
    float _889 = _887 + -1.0f;
    float _890 = _889 / _887;
    float _891 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _892 = _891 / _853;
    float _893 = select(_888, _890, _892);
    float _894 = _893 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _895 = _866 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _896 = _880 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _897 = _894 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    _899 = _895;
    _900 = _896;
    _901 = _897;
  } else {
    _899 = _808;
    _900 = _809;
    _901 = _810;
  }
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_808, _809, _810),
      float3(_899, _900, _901),
      false);
  _899 = apt_post_process_output.x;
  _900 = apt_post_process_output.y;
  _901 = apt_post_process_output.z;
  float _902 = log2(_899);
  float _903 = log2(_900);
  float _904 = log2(_901);
  float _905 = _902 * 0.4166666567325592f;
  float _906 = _903 * 0.4166666567325592f;
  float _907 = _904 * 0.4166666567325592f;
  float _908 = exp2(_905);
  float _909 = exp2(_906);
  float _910 = exp2(_907);
  float _911 = _908 * 1.0549999475479126f;
  float _912 = _909 * 1.0549999475479126f;
  float _913 = _910 * 1.0549999475479126f;
  float _914 = _911 + -0.054999999701976776f;
  float _915 = _912 + -0.054999999701976776f;
  float _916 = _913 + -0.054999999701976776f;
  float _917 = _899 * 12.920000076293945f;
  float _918 = _900 * 12.920000076293945f;
  float _919 = _901 * 12.920000076293945f;
  bool _920 = (_899 <= 0.0031308000907301903f);
  bool _921 = (_900 <= 0.0031308000907301903f);
  bool _922 = (_901 <= 0.0031308000907301903f);
  float _923 = select(_920, _917, _914);
  float _924 = select(_921, _918, _915);
  float _925 = select(_922, _919, _916);
  float _926 = log2(_923);
  float _927 = log2(_924);
  float _928 = log2(_925);
  float _929 = floor(_926);
  float _930 = floor(_927);
  float _931 = floor(_928);
  float _932 = _929 + -6.0f;
  float _933 = _930 + -6.0f;
  float _934 = _931 + -5.0f;
  float _935 = exp2(_932);
  float _936 = exp2(_933);
  float _937 = exp2(_934);
  bool _938 = (_923 <= 0.0f);
  bool _939 = (_924 <= 0.0f);
  bool _940 = (_925 <= 0.0f);
  float _941 = select(_938, 0.0f, _935);
  float _942 = select(_939, 0.0f, _936);
  float _943 = select(_940, 0.0f, _937);
  uint _944 = uint(SV_Position.x);
  uint _945 = uint(SV_Position.y);
  int _946 = _944 & 63;
  int _947 = _945 & 63;
  float4 _949 = t1.Load(int4(_946, _947, _737, 0));
  float4 _951 = t6.Load(int4(_946, _947, _737, 0));
  float _954 = _949.x * _941;
  float _955 = _951.x * _942;
  float _956 = _951.y * _943;
  float _957 = _954 + _923;
  float _958 = _955 + _924;
  float _959 = _956 + _925;
  SV_Target.x = _957;
  SV_Target.y = _958;
  SV_Target.z = _959;
  SV_Target.w = _137.w;
  return SV_Target;
}
