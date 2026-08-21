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
  float _729;
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
  float _634 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 335.718017578125f;
  float _635 = _625.x * _634;
  float _636 = _635 * _619;
  float _637 = _636 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _638 = _635 * _620;
  float _639 = _638 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _640 = _635 * _621;
  float _641 = _640 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _642 = _637 + 1.0f;
  float _643 = _639 + 1.0f;
  float _644 = _641 + 1.0f;
  float _645 = log2(_642);
  float _646 = log2(_643);
  float _647 = log2(_644);
  float _648 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _649 = _648 * _645;
  float _650 = _648 * _646;
  float _651 = _647 * _648;
  float _652 = _649 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _653 = _650 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _654 = _651 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _657 = t3.Sample(s3, float3(_652, _653, _654));
  float _661 = _657.x * 13.450128555297852f;
  float _662 = _657.y * 13.450128555297852f;
  float _663 = _657.z * 13.450128555297852f;
  float _664 = exp2(_661);
  float _665 = exp2(_662);
  float _666 = exp2(_663);
  float _667 = _664 + -1.0f;
  float _668 = _665 + -1.0f;
  float _669 = _666 + -1.0f;
  float _670 = _667 * 0.0029786902014166117f;
  float _671 = _668 * 0.0029786902014166117f;
  float _672 = _669 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUTScaling(
      float3(_637 * 0.0029786902014166117f, _639 * 0.0029786902014166117f, _641 * 0.0029786902014166117f),
      float3(_670 * (User_000.UserConstant_Z_000[4].x), _671 * (User_000.UserConstant_Z_000[4].y), _672 * (User_000.UserConstant_Z_000[4].z)),
      t3,
      s3,
      PostProcess_000.PostProcessConstant_Z_320[0].x,
      PostProcess_000.PostProcessConstant_Z_320[0].y,
      User_000.UserConstant_Z_000[4].rgb);
  float _677 = apt_scaled_lut_output.x;
  float _678 = apt_scaled_lut_output.y;
  float _679 = apt_scaled_lut_output.z;
  float _685 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _686 = _685 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _687 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _688 = _687 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _691 = _686 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _692 = _688 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _695 = t9.Sample(s9, float2(_691, _692));
  float _699 = dot(float3(_677, _678, _679), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _702 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _705 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _706 = select(_702, _705, 0);
  float _707 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _708 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _709 = uint(_707);
  uint _710 = uint(_708);
  int _711 = _709 & 63;
  int _712 = _710 & 63;
  float4 _714 = t6.Load(int4(_711, _712, _706, 0));
  bool _716 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_716) {
    float _718 = _707 * 0.015625f;
    float _719 = _708 * 0.015625f;
    float _720 = float((uint)_705);
    float _721 = select(_702, _720, 0.0f);
    float4 _723 = t6.SampleLevel(s1, float3(_718, _719, _721), 0.0f);
    float _725 = _714.y - _723.y;
    float _726 = _725 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _727 = _726 + _723.y;
    _729 = _727;
  } else {
    _729 = _714.y;
  }
  float _730 = _695.x * -2.0f;
  float _731 = _730 * _729;
  float _732 = _729 * 2.0f;
  float _733 = _732 * _695.y;
  float _734 = _732 * _695.z;
  float _735 = _731 + _695.x;
  float _736 = _733 - _695.y;
  float _737 = _734 - _695.z;
  float _738 = _735 * _695.x;
  float _739 = _736 * _695.y;
  float _740 = _737 * _695.z;
  float _741 = _699 + 1.0f;
  float _742 = _699 / _741;
  float _743 = _742 + -9.999999747378752e-05f;
  float _744 = _743 * 1111.111083984375f;
  float _745 = saturate(_744);
  float _746 = _745 * 2.0f;
  float _747 = 3.0f - _746;
  float _748 = _745 * _745;
  float _749 = _748 * _747;
  bool _751 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _752 = float((bool)_751);
  float _753 = dot(float3(_738, _739, _740), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _754 = _753 - _738;
  float _755 = _753 - _739;
  float _756 = _753 - _740;
  float _757 = _754 * _752;
  float _758 = _755 * _752;
  float _759 = _756 * _752;
  float _760 = _757 + _738;
  float _761 = _758 + _739;
  float _762 = _759 + _740;
  float _766 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _767 = _766 * _742;
  float _768 = _767 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _769 = _749 * _768;
  float _770 = _769 * _760;
  float _771 = _769 * _761;
  float _772 = _769 * _762;
  float _773 = _770 + _677;
  float _774 = _771 + _678;
  float _775 = _772 + _679;
  float _776 = max(0.0f, _773);
  float _777 = max(0.0f, _774);
  float _778 = max(0.0f, _775);
  float _781 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _782 = log2(_776);
  float _783 = _781 * _782;
  float _784 = exp2(_783);
  float _785 = _784 + -1.0f;
  float _786 = _776 + -1.0f;
  float _787 = _785 / _786;
  bool _788 = !(_776 == 1.0f);
  float _789 = _787 + -1.0f;
  float _790 = _789 / _787;
  float _791 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _792 = _791 / _781;
  float _793 = select(_788, _790, _792);
  float _794 = log2(_777);
  float _795 = _794 * _781;
  float _796 = exp2(_795);
  float _797 = _796 + -1.0f;
  float _798 = _777 + -1.0f;
  float _799 = _797 / _798;
  bool _800 = !(_777 == 1.0f);
  float _801 = _799 + -1.0f;
  float _802 = _801 / _799;
  float _803 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _804 = _803 / _781;
  float _805 = select(_800, _802, _804);
  float _806 = log2(_778);
  float _807 = _806 * _781;
  float _808 = exp2(_807);
  float _809 = _808 + -1.0f;
  float _810 = _778 + -1.0f;
  float _811 = _809 / _810;
  bool _812 = !(_778 == 1.0f);
  float _813 = _811 + -1.0f;
  float _814 = _813 / _811;
  float _815 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _816 = _815 / _781;
  float _817 = select(_812, _814, _816);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_776, _777, _778),
      float3(_793, _805, _817),
      true);
  float _818 = apt_post_process_output.x;
  float _819 = apt_post_process_output.y;
  float _820 = apt_post_process_output.z;
  float _821 = log2(_818);
  float _822 = log2(_819);
  float _823 = log2(_820);
  float _824 = _821 * 0.4166666567325592f;
  float _825 = _822 * 0.4166666567325592f;
  float _826 = _823 * 0.4166666567325592f;
  float _827 = exp2(_824);
  float _828 = exp2(_825);
  float _829 = exp2(_826);
  float _830 = _827 * 1.0549999475479126f;
  float _831 = _828 * 1.0549999475479126f;
  float _832 = _829 * 1.0549999475479126f;
  float _833 = _830 + -0.054999999701976776f;
  float _834 = _831 + -0.054999999701976776f;
  float _835 = _832 + -0.054999999701976776f;
  float _836 = _818 * 12.920000076293945f;
  float _837 = _819 * 12.920000076293945f;
  float _838 = _820 * 12.920000076293945f;
  bool _839 = (_818 <= 0.0031308000907301903f);
  bool _840 = (_819 <= 0.0031308000907301903f);
  bool _841 = (_820 <= 0.0031308000907301903f);
  float _842 = select(_839, _836, _833);
  float _843 = select(_840, _837, _834);
  float _844 = select(_841, _838, _835);
  float _845 = log2(_842);
  float _846 = log2(_843);
  float _847 = log2(_844);
  float _848 = floor(_845);
  float _849 = floor(_846);
  float _850 = floor(_847);
  float _851 = _848 + -6.0f;
  float _852 = _849 + -6.0f;
  float _853 = _850 + -5.0f;
  float _854 = exp2(_851);
  float _855 = exp2(_852);
  float _856 = exp2(_853);
  bool _857 = (_842 <= 0.0f);
  bool _858 = (_843 <= 0.0f);
  bool _859 = (_844 <= 0.0f);
  float _860 = select(_857, 0.0f, _854);
  float _861 = select(_858, 0.0f, _855);
  float _862 = select(_859, 0.0f, _856);
  uint _863 = uint(SV_Position.x);
  uint _864 = uint(SV_Position.y);
  int _865 = _863 & 63;
  int _866 = _864 & 63;
  float4 _868 = t1.Load(int4(_865, _866, _705, 0));
  float4 _870 = t6.Load(int4(_865, _866, _705, 0));
  float _873 = _868.x * _860;
  float _874 = _870.x * _861;
  float _875 = _870.y * _862;
  float _876 = _873 + _842;
  float _877 = _874 + _843;
  float _878 = _875 + _844;
  SV_Target.x = _876;
  SV_Target.y = _877;
  SV_Target.z = _878;
  SV_Target.w = _137.w;
  return SV_Target;
}
