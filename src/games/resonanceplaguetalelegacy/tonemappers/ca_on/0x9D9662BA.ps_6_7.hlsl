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

Texture2D<float4> t15 : register(t15);

Texture2D<float4> t16 : register(t16);

Texture2D<float4> t17 : register(t17);

#include "../../common.hlsli"

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
  float4 _40 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _46 = t16.Sample(s0, float2(TEXCOORD.z, TEXCOORD.w));
  float _49 = _46.y * 0.10000000149011612f;
  float _50 = _49 + _40.y;
  float _51 = _46.y * 0.5f;
  float _52 = _51 + _40.z;
  float _53 = exp2(_52);
  float _54 = _53 + -1.0f;
  float _57 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _54;
  float _58 = _57 + 1.0f;
  float _59 = log2(_58);
  float _60 = _40.x + TEXCOORD.z;
  float _61 = _50 + TEXCOORD.w;
  float _62 = _40.x + TEXCOORD.x;
  float _63 = _50 + TEXCOORD.y;
  float _67 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].x);
  float _68 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].y);
  float _69 = _67 + _60;
  float _70 = _68 + _61;
  float _71 = _69 * 2.0f;
  float _72 = _70 * 2.0f;
  float _73 = _71 + -1.0f;
  float _74 = _72 + -1.0f;
  float _78 = _74 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].y);
  float _79 = abs(_73);
  float _80 = abs(_74);
  float _82 = (PostProcess_000.PostProcessConstant_Z_000[19].z) * 2.0f;
  float _83 = _82 + -1.0f;
  float _84 = _79 - _83;
  float _85 = _80 - _83;
  float _86 = saturate(_84);
  float _87 = saturate(_85);
  float _88 = _86 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].x);
  float _89 = _88 * _73;
  float _90 = _78 * _87;
  float _91 = _89 * _89;
  float _92 = _90 * _90;
  float _93 = _91 + _92;
  float _94 = sqrt(_93);
  float _97 = _67 + _62;
  float _98 = _68 + _63;
  float _99 = _97 * 2.0f;
  float _100 = _99 + -1.0f;
  float _101 = _98 * 1.125f;
  float _102 = _101 + -0.5625f;
  float _103 = _100 * _100;
  float _104 = _102 * _102;
  float _105 = _103 + _104;
  float _106 = sqrt(_105);
  float _107 = _106 * 0.8715755343437195f;
  float _108 = _107 * _107;
  float _109 = _108 + -0.15000000596046448f;
  float _110 = _109 * 1.8181819915771484f;
  float _111 = saturate(_110);
  float _112 = _111 * 2.0f;
  float _113 = 3.0f - _112;
  float _114 = (PostProcess_000.PostProcessConstant_Z_000[2].w) * _94;
  float _115 = _111 * _111;
  float _116 = _115 * _114;
  float _117 = _116 * _108;
  float _118 = _117 * _113;
  float _120 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _89;
  float _121 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _90;
  float _122 = _121 + _61;
  float _123 = _60 - _120;
  float _124 = _46.x * 0.010840999893844128f;
  float _125 = _60 + _124;
  float _126 = _125 + _120;
  float _127 = _61 + _124;
  float _128 = _127 - _121;
  float _129 = _59 + 1.0f;
  float _130 = log2(_129);
  float _131 = max(_118, _130);
  float4 _134 = t0.SampleLevel(s0, float2(_126, _122), _131);
  float4 _136 = t0.SampleLevel(s0, float2(_123, _128), _131);
  float4 _138 = t0.SampleLevel(s0, float2(_60, _61), _131);
  float _141 = max(_134.x, 0.0f);
  float _142 = max(_136.y, 0.0f);
  float _143 = max(_138.z, 0.0f);
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
      float3(_141, _142, _143),
      max(_138.rgb, 0.f.xxx),
      float2(_60, _61),
      t0,
      s0,
      _131);
  _141 = renodx_chromatic_aberration_input.x;
  _142 = renodx_chromatic_aberration_input.y;
  _143 = renodx_chromatic_aberration_input.z;
  float4 _145 = t12.SampleLevel(s0, float2(_60, _61), 0.0f);
  float4 _151 = t8.Sample(s8, float2(_62, _63));
  int _157 = asint((User_000.UserConstant_Z_000[7].z));
  bool _158 = ((int)_157 > (int)0);
  float _187;
  float _188;
  float _189;
  float _194;
  float _195;
  float _196;
  float _225;
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
  float _815;
  float _919;
  float _1023;
  float _1026;
  float _1027;
  float _1028;
  float _1039;
  float _1164;
  float _1165;
  float _1166;
  float _1213;
  float _1214;
  float _1215;
  float _1229;
  float _1230;
  float _1231;
  float _1287;
  if (!_158) {
    bool _162 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _166 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _151.x;
    float _167 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _151.y;
    float _168 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _151.z;
    float _169 = _166 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _170 = _167 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _171 = _168 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_162) {
      float _173 = _169 * _145.x;
      float _174 = _170 * _145.y;
      float _175 = _171 * _145.z;
      _187 = _173;
      _188 = _174;
      _189 = _175;
    } else {
      float _177 = saturate(_169);
      float _178 = saturate(_170);
      float _179 = saturate(_171);
      float _180 = _145.x - _141;
      float _181 = _145.y - _142;
      float _182 = _145.z - _143;
      float _183 = _177 * _180;
      float _184 = _178 * _181;
      float _185 = _179 * _182;
      _187 = _183;
      _188 = _184;
      _189 = _185;
    }
    float _190 = _187 + _141;
    float _191 = _188 + _142;
    float _192 = _189 + _143;
    _194 = _190;
    _195 = _191;
    _196 = _192;
  } else {
    _194 = _141;
    _195 = _142;
    _196 = _143;
  }
  [branch]
  if (_158) {
    bool _201 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_201) {
      float _203 = _40.x + TEXCOORD.x;
      float _204 = _50 + TEXCOORD.y;
      float4 _207 = t2.SampleLevel(s2, float2(_203, _204), 0.0f);
      bool _211 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_211) {
        float4 _214 = t7.Load(int3(0, 0, 0));
        float _219 = _214.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _220 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _219;
        _225 = _220;
      } else {
        _225 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _229 = _207.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _230 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _229;
      float _232 = _225 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _233 = _232 + _225;
      float _234 = _225 - _232;
      float _235 = max(_230, _234);
      float _236 = min(_235, _233);
      float _239 = _230 - _236;
      float _240 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _239;
      float _242 = _236 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _243 = _242 * _230;
      float _244 = _240 / _243;
      float _245 = min(_244, 0.0f);
      float _247 = _232 + 1.0f;
      float _248 = 1.0f / _247;
      float _249 = _245 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _250 = max(0.0f, _244);
      float _253 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _250;
      float _254 = _253 + _249;
      float _255 = _254 * _248;
      float _256 = max(_255, -1.0f);
      float _257 = min(_256, 1.0f);
      float _258 = max(_257, -0.30000001192092896f);
      float _259 = min(_258, 1.0f);
      float _261 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _262 = _259 * _261;
      float _263 = _203 + -0.5f;
      float _264 = _204 + -0.5f;
      float _265 = _263 * _263;
      float _266 = _264 * _264;
      float _267 = _266 + _265;
      float _268 = sqrt(_267);
      float _269 = log2(_268);
      float _270 = _269 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _271 = exp2(_270);
      float _272 = _271 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _273 = dot(float2(_263, _264), float2(_263, _264));
      float _274 = rsqrt(_273);
      float _275 = _274 * _263;
      float _276 = _274 * _264;
      float _277 = abs(_262);
      float _281 = _272 * _277;
      float _282 = -0.0f - _281;
      float _283 = (User_000.UserConstant_Z_000[2].x) * _275;
      float _284 = _283 * _282;
      float _285 = (User_000.UserConstant_Z_000[2].y) * _276;
      float _286 = _285 * _282;
      float _287 = _277 * _272;
      float _288 = _283 * _287;
      float _289 = _285 * _287;
      float _290 = _288 + _203;
      float _291 = _289 + _204;
      float _292 = _284 + _126;
      float _293 = _286 + _122;
      float4 _294 = t0.SampleLevel(s0, float2(_292, _293), _131);
      float4 _296 = t0.SampleLevel(s0, float2(_290, _291), _131);
      float4 _298 = t2.SampleLevel(s2, float2(_292, _293), 0.0f);
      if (_211) {
        float4 _302 = t7.Load(int3(0, 0, 0));
        float _304 = _302.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _305 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _304;
        _309 = _305;
      } else {
        _309 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _310 = _298.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _311 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _310;
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
      float _334 = _333 * _261;
      float4 _335 = t2.SampleLevel(s2, float2(_290, _291), 0.0f);
      if (_211) {
        float4 _339 = t7.Load(int3(0, 0, 0));
        float _341 = _339.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _342 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _341;
        _346 = _342;
      } else {
        _346 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _347 = _335.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _348 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _347;
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
      float _371 = _370 * _261;
      float _372 = abs(_334);
      float _373 = _372 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _374 = ceil(_373);
      float _375 = saturate(_374);
      float _376 = _294.x - _194;
      float _377 = _375 * _376;
      float _378 = _377 + _194;
      float _379 = abs(_371);
      float _380 = _379 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _381 = ceil(_380);
      float _382 = saturate(_381);
      float _383 = _296.z - _196;
      float _384 = _382 * _383;
      float _385 = _384 + _196;
      _575 = _378;
      _576 = _195;
      _577 = _385;
    } else {
      _575 = _194;
      _576 = _195;
      _577 = _196;
    }
  } else {
    int _388 = asint((User_000.UserConstant_Z_000[7].y));
    bool _389 = ((int)_388 > (int)0);
    if (_389) {
      float _391 = _40.x + TEXCOORD.x;
      float _392 = _50 + TEXCOORD.y;
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
      float _424 = _395.x - _194;
      float _425 = _395.y - _195;
      float _426 = _395.z - _196;
      float _427 = _426 + _423;
      float _428 = _424 * _395.w;
      float _429 = _425 * _395.w;
      float _430 = _427 * _395.w;
      float _431 = _428 + _194;
      float _432 = _429 + _195;
      float _433 = _430 + _196;
      _575 = _431;
      _576 = _432;
      _577 = _433;
    } else {
      int _436 = asint((User_000.UserConstant_Z_000[7].x));
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
        float _473 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _451;
        float _474 = mad(_452, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _473);
        float _475 = mad(_447.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _474);
        float _476 = _475 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _477 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _451;
        float _478 = mad(_452, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _477);
        float _479 = mad(_447.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _478);
        float _480 = _479 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _481 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _451;
        float _482 = mad(_452, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _481);
        float _483 = mad(_447.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _482);
        float _484 = _483 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _485 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _451;
        float _486 = mad(_452, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _485);
        float _487 = mad(_447.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _486);
        float _488 = _487 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
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
      float _564 = _542.x - _194;
      float _565 = _542.y - _195;
      float _566 = _542.z - _196;
      float _567 = _566 + _561;
      float _568 = _563 * _564;
      float _569 = _563 * _565;
      float _570 = _567 * _563;
      float _571 = _568 + _194;
      float _572 = _569 + _195;
      float _573 = _570 + _196;
      _575 = _571;
      _576 = _572;
      _577 = _573;
    }
  }
  if (_158) {
    bool _581 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _585 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _151.x;
    float _586 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _151.y;
    float _587 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _151.z;
    float _588 = _585 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _589 = _586 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _590 = _587 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_581) {
      float _592 = _588 * _145.x;
      float _593 = _589 * _145.y;
      float _594 = _590 * _145.z;
      _606 = _592;
      _607 = _593;
      _608 = _594;
    } else {
      float _596 = saturate(_588);
      float _597 = saturate(_589);
      float _598 = saturate(_590);
      float _599 = _145.x - _575;
      float _600 = _145.y - _576;
      float _601 = _145.z - _577;
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
  float _627 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _628 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _629 = _619.x * _628;
  float _630 = _629 * _613;
  float _631 = _630 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _632 = _631 * _627;
  float _633 = _629 * _614;
  float _634 = _633 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _635 = _634 * _627;
  float _636 = _629 * _615;
  float _637 = _636 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _638 = _637 * _627;
  float _639 = _632 + 1.0f;
  float _640 = _635 + 1.0f;
  float _641 = _638 + 1.0f;
  float _642 = log2(_639);
  float _643 = log2(_640);
  float _644 = log2(_641);
  float _647 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _648 = _647 * _642;
  float _649 = _647 * _643;
  float _650 = _647 * _644;
  float _652 = _648 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _653 = _649 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _654 = _650 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _657 = t3.Sample(s3, float3(_652, _653, _654));
  float _663 = _657.x * 13.450128555297852f;
  float _664 = _657.y * 13.450128555297852f;
  float _665 = _657.z * 13.450128555297852f;
  float _666 = exp2(_663);
  float _667 = exp2(_664);
  float _668 = exp2(_665);
  float _669 = _666 + -1.0f;
  float _670 = _667 + -1.0f;
  float _671 = _668 + -1.0f;
  float _672 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _673 = _672 * _669;
  float _674 = _672 * _670;
  float _675 = _672 * _671;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_632 * _672, _635 * _672, _638 * _672),
      float3(_673, _674, _675),
      1.f.xxx);
  _673 = resonance_scaled_lut_output.x;
  _674 = resonance_scaled_lut_output.y;
  _675 = resonance_scaled_lut_output.z;
  bool _678 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_678) {
    float _680 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _681 = _673 * _680;
    float _682 = _674 * _680;
    float _683 = _675 * _680;
    float _684 = _681 + 1.0f;
    float _685 = _682 + 1.0f;
    float _686 = _683 + 1.0f;
    float _687 = log2(_684);
    float _688 = log2(_685);
    float _689 = log2(_686);
    float _690 = _687 * 0.07434873282909393f;
    float _691 = _688 * 0.07434873282909393f;
    float _692 = _689 * 0.07434873282909393f;
    int _694 = asint((User_000.UserConstant_Z_000[3].y));
    int _695 = _694 & 1;
    bool _696 = (_695 == 0);
    if (!_696) {
      bool _713 = !(_690 <= (User_000.UserConstant_Z_000[4].x));
      if (!_713) {
        float _715 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _716 = _690 / _715;
        float _717 = _716 * (User_000.UserConstant_Z_000[4].y);
        float _718 = _716 * _716;
        float _719 = _718 * _716;
        float _720 = _719 - _716;
        float _721 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _722 = _715 * _715;
        float _723 = _722 * _721;
        float _724 = _723 * _720;
        float _725 = _724 + _717;
        _815 = _725;
      } else {
        bool _727 = !(_690 <= (User_000.UserConstant_Z_000[4].z));
        if (!_727) {
          float _729 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _730 = max(9.999999974752427e-07f, _729);
          float _731 = _690 - (User_000.UserConstant_Z_000[4].x);
          float _732 = _731 / _730;
          float _733 = 1.0f - _732;
          float _734 = _733 * (User_000.UserConstant_Z_000[4].y);
          float _735 = _732 * (User_000.UserConstant_Z_000[4].w);
          float _736 = _734 + _735;
          float _737 = _733 * _733;
          float _738 = _737 * _733;
          float _739 = _738 - _733;
          float _740 = _739 * (User_000.UserConstant_Z_000[10].x);
          float _741 = _732 * _732;
          float _742 = _741 * _732;
          float _743 = _742 - _732;
          float _744 = _743 * (User_000.UserConstant_Z_000[10].y);
          float _745 = _740 + _744;
          float _746 = _730 * _730;
          float _747 = _746 * 0.1666666716337204f;
          float _748 = _747 * _745;
          float _749 = _736 + _748;
          _815 = _749;
        } else {
          bool _751 = !(_690 <= (User_000.UserConstant_Z_000[9].x));
          if (!_751) {
            float _753 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _754 = max(9.999999974752427e-07f, _753);
            float _755 = _690 - (User_000.UserConstant_Z_000[4].z);
            float _756 = _755 / _754;
            float _757 = 1.0f - _756;
            float _758 = _757 * (User_000.UserConstant_Z_000[4].w);
            float _759 = _756 * (User_000.UserConstant_Z_000[9].y);
            float _760 = _758 + _759;
            float _761 = _757 * _757;
            float _762 = _761 * _757;
            float _763 = _762 - _757;
            float _764 = _763 * (User_000.UserConstant_Z_000[10].y);
            float _765 = _756 * _756;
            float _766 = _765 * _756;
            float _767 = _766 - _756;
            float _768 = _767 * (User_000.UserConstant_Z_000[10].z);
            float _769 = _764 + _768;
            float _770 = _754 * _754;
            float _771 = _770 * 0.1666666716337204f;
            float _772 = _771 * _769;
            float _773 = _760 + _772;
            _815 = _773;
          } else {
            bool _775 = !(_690 <= (User_000.UserConstant_Z_000[9].z));
            if (!_775) {
              float _777 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _778 = max(9.999999974752427e-07f, _777);
              float _779 = _690 - (User_000.UserConstant_Z_000[9].x);
              float _780 = _779 / _778;
              float _781 = 1.0f - _780;
              float _782 = _781 * (User_000.UserConstant_Z_000[9].y);
              float _783 = _780 * (User_000.UserConstant_Z_000[9].w);
              float _784 = _782 + _783;
              float _785 = _781 * _781;
              float _786 = _785 * _781;
              float _787 = _786 - _781;
              float _788 = _787 * (User_000.UserConstant_Z_000[10].z);
              float _789 = _780 * _780;
              float _790 = _789 * _780;
              float _791 = _790 - _780;
              float _792 = _791 * (User_000.UserConstant_Z_000[10].w);
              float _793 = _788 + _792;
              float _794 = _778 * _778;
              float _795 = _794 * 0.1666666716337204f;
              float _796 = _795 * _793;
              float _797 = _784 + _796;
              _815 = _797;
            } else {
              float _799 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _800 = _690 - (User_000.UserConstant_Z_000[9].z);
              float _801 = max(9.999999974752427e-07f, _799);
              float _802 = _800 / _801;
              float _803 = 1.0f - _802;
              float _804 = _803 * (User_000.UserConstant_Z_000[9].w);
              float _805 = _804 + _802;
              float _806 = _803 * _803;
              float _807 = _806 * _803;
              float _808 = _807 - _803;
              float _809 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _810 = _799 * _799;
              float _811 = _810 * _809;
              float _812 = _811 * _808;
              float _813 = _805 + _812;
              _815 = _813;
            }
          }
        }
      }
      float _816 = saturate(_815);
      bool _817 = !(_691 <= (User_000.UserConstant_Z_000[4].x));
      if (!_817) {
        float _819 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _820 = _691 / _819;
        float _821 = _820 * (User_000.UserConstant_Z_000[4].y);
        float _822 = _820 * _820;
        float _823 = _822 * _820;
        float _824 = _823 - _820;
        float _825 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _826 = _819 * _819;
        float _827 = _826 * _825;
        float _828 = _827 * _824;
        float _829 = _828 + _821;
        _919 = _829;
      } else {
        bool _831 = !(_691 <= (User_000.UserConstant_Z_000[4].z));
        if (!_831) {
          float _833 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _834 = max(9.999999974752427e-07f, _833);
          float _835 = _691 - (User_000.UserConstant_Z_000[4].x);
          float _836 = _835 / _834;
          float _837 = 1.0f - _836;
          float _838 = _837 * (User_000.UserConstant_Z_000[4].y);
          float _839 = _836 * (User_000.UserConstant_Z_000[4].w);
          float _840 = _838 + _839;
          float _841 = _837 * _837;
          float _842 = _841 * _837;
          float _843 = _842 - _837;
          float _844 = _843 * (User_000.UserConstant_Z_000[10].x);
          float _845 = _836 * _836;
          float _846 = _845 * _836;
          float _847 = _846 - _836;
          float _848 = _847 * (User_000.UserConstant_Z_000[10].y);
          float _849 = _844 + _848;
          float _850 = _834 * _834;
          float _851 = _850 * 0.1666666716337204f;
          float _852 = _851 * _849;
          float _853 = _840 + _852;
          _919 = _853;
        } else {
          bool _855 = !(_691 <= (User_000.UserConstant_Z_000[9].x));
          if (!_855) {
            float _857 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _858 = max(9.999999974752427e-07f, _857);
            float _859 = _691 - (User_000.UserConstant_Z_000[4].z);
            float _860 = _859 / _858;
            float _861 = 1.0f - _860;
            float _862 = _861 * (User_000.UserConstant_Z_000[4].w);
            float _863 = _860 * (User_000.UserConstant_Z_000[9].y);
            float _864 = _862 + _863;
            float _865 = _861 * _861;
            float _866 = _865 * _861;
            float _867 = _866 - _861;
            float _868 = _867 * (User_000.UserConstant_Z_000[10].y);
            float _869 = _860 * _860;
            float _870 = _869 * _860;
            float _871 = _870 - _860;
            float _872 = _871 * (User_000.UserConstant_Z_000[10].z);
            float _873 = _868 + _872;
            float _874 = _858 * _858;
            float _875 = _874 * 0.1666666716337204f;
            float _876 = _875 * _873;
            float _877 = _864 + _876;
            _919 = _877;
          } else {
            bool _879 = !(_691 <= (User_000.UserConstant_Z_000[9].z));
            if (!_879) {
              float _881 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _882 = max(9.999999974752427e-07f, _881);
              float _883 = _691 - (User_000.UserConstant_Z_000[9].x);
              float _884 = _883 / _882;
              float _885 = 1.0f - _884;
              float _886 = _885 * (User_000.UserConstant_Z_000[9].y);
              float _887 = _884 * (User_000.UserConstant_Z_000[9].w);
              float _888 = _886 + _887;
              float _889 = _885 * _885;
              float _890 = _889 * _885;
              float _891 = _890 - _885;
              float _892 = _891 * (User_000.UserConstant_Z_000[10].z);
              float _893 = _884 * _884;
              float _894 = _893 * _884;
              float _895 = _894 - _884;
              float _896 = _895 * (User_000.UserConstant_Z_000[10].w);
              float _897 = _892 + _896;
              float _898 = _882 * _882;
              float _899 = _898 * 0.1666666716337204f;
              float _900 = _899 * _897;
              float _901 = _888 + _900;
              _919 = _901;
            } else {
              float _903 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _904 = _691 - (User_000.UserConstant_Z_000[9].z);
              float _905 = max(9.999999974752427e-07f, _903);
              float _906 = _904 / _905;
              float _907 = 1.0f - _906;
              float _908 = _907 * (User_000.UserConstant_Z_000[9].w);
              float _909 = _908 + _906;
              float _910 = _907 * _907;
              float _911 = _910 * _907;
              float _912 = _911 - _907;
              float _913 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _914 = _903 * _903;
              float _915 = _914 * _913;
              float _916 = _915 * _912;
              float _917 = _909 + _916;
              _919 = _917;
            }
          }
        }
      }
      float _920 = saturate(_919);
      bool _921 = !(_692 <= (User_000.UserConstant_Z_000[4].x));
      if (!_921) {
        float _923 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _924 = _692 / _923;
        float _925 = _924 * (User_000.UserConstant_Z_000[4].y);
        float _926 = _924 * _924;
        float _927 = _926 * _924;
        float _928 = _927 - _924;
        float _929 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _930 = _923 * _923;
        float _931 = _930 * _929;
        float _932 = _931 * _928;
        float _933 = _932 + _925;
        _1023 = _933;
      } else {
        bool _935 = !(_692 <= (User_000.UserConstant_Z_000[4].z));
        if (!_935) {
          float _937 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _938 = max(9.999999974752427e-07f, _937);
          float _939 = _692 - (User_000.UserConstant_Z_000[4].x);
          float _940 = _939 / _938;
          float _941 = 1.0f - _940;
          float _942 = _941 * (User_000.UserConstant_Z_000[4].y);
          float _943 = _940 * (User_000.UserConstant_Z_000[4].w);
          float _944 = _942 + _943;
          float _945 = _941 * _941;
          float _946 = _945 * _941;
          float _947 = _946 - _941;
          float _948 = _947 * (User_000.UserConstant_Z_000[10].x);
          float _949 = _940 * _940;
          float _950 = _949 * _940;
          float _951 = _950 - _940;
          float _952 = _951 * (User_000.UserConstant_Z_000[10].y);
          float _953 = _948 + _952;
          float _954 = _938 * _938;
          float _955 = _954 * 0.1666666716337204f;
          float _956 = _955 * _953;
          float _957 = _944 + _956;
          _1023 = _957;
        } else {
          bool _959 = !(_692 <= (User_000.UserConstant_Z_000[9].x));
          if (!_959) {
            float _961 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _962 = max(9.999999974752427e-07f, _961);
            float _963 = _692 - (User_000.UserConstant_Z_000[4].z);
            float _964 = _963 / _962;
            float _965 = 1.0f - _964;
            float _966 = _965 * (User_000.UserConstant_Z_000[4].w);
            float _967 = _964 * (User_000.UserConstant_Z_000[9].y);
            float _968 = _966 + _967;
            float _969 = _965 * _965;
            float _970 = _969 * _965;
            float _971 = _970 - _965;
            float _972 = _971 * (User_000.UserConstant_Z_000[10].y);
            float _973 = _964 * _964;
            float _974 = _973 * _964;
            float _975 = _974 - _964;
            float _976 = _975 * (User_000.UserConstant_Z_000[10].z);
            float _977 = _972 + _976;
            float _978 = _962 * _962;
            float _979 = _978 * 0.1666666716337204f;
            float _980 = _979 * _977;
            float _981 = _968 + _980;
            _1023 = _981;
          } else {
            bool _983 = !(_692 <= (User_000.UserConstant_Z_000[9].z));
            if (!_983) {
              float _985 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _986 = max(9.999999974752427e-07f, _985);
              float _987 = _692 - (User_000.UserConstant_Z_000[9].x);
              float _988 = _987 / _986;
              float _989 = 1.0f - _988;
              float _990 = _989 * (User_000.UserConstant_Z_000[9].y);
              float _991 = _988 * (User_000.UserConstant_Z_000[9].w);
              float _992 = _990 + _991;
              float _993 = _989 * _989;
              float _994 = _993 * _989;
              float _995 = _994 - _989;
              float _996 = _995 * (User_000.UserConstant_Z_000[10].z);
              float _997 = _988 * _988;
              float _998 = _997 * _988;
              float _999 = _998 - _988;
              float _1000 = _999 * (User_000.UserConstant_Z_000[10].w);
              float _1001 = _996 + _1000;
              float _1002 = _986 * _986;
              float _1003 = _1002 * 0.1666666716337204f;
              float _1004 = _1003 * _1001;
              float _1005 = _992 + _1004;
              _1023 = _1005;
            } else {
              float _1007 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1008 = _692 - (User_000.UserConstant_Z_000[9].z);
              float _1009 = max(9.999999974752427e-07f, _1007);
              float _1010 = _1008 / _1009;
              float _1011 = 1.0f - _1010;
              float _1012 = _1011 * (User_000.UserConstant_Z_000[9].w);
              float _1013 = _1012 + _1010;
              float _1014 = _1011 * _1011;
              float _1015 = _1014 * _1011;
              float _1016 = _1015 - _1011;
              float _1017 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1018 = _1007 * _1007;
              float _1019 = _1018 * _1017;
              float _1020 = _1019 * _1016;
              float _1021 = _1013 + _1020;
              _1023 = _1021;
            }
          }
        }
      }
      float _1024 = saturate(_1023);
      _1026 = _816;
      _1027 = _920;
      _1028 = _1024;
    } else {
      _1026 = _690;
      _1027 = _691;
      _1028 = _692;
    }
    int _1029 = _694 & 2;
    bool _1030 = (_1029 == 0);
    if (!_1030) {
      float _1032 = sqrt(_1026);
      float _1033 = sqrt(_1027);
      float _1034 = sqrt(_1028);
      float _1035 = dot(float3(_1032, _1033, _1034), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1036 = 1.0f - _1035;
      float _1037 = saturate(_1036);
      _1039 = _1037;
    } else {
      _1039 = 1.0f;
    }
    int _1040 = _694 & 8;
    bool _1041 = (_1040 == 0);
    if (_1041) {
      int _1043 = _694 & 4;
      bool _1044 = (_1043 == 0);
      if (!_1044) {
        int _1046 = _694 & 16;
        bool _1047 = (_1046 == 0);
        if (!_1047) {
          float _1051 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1052 = _1051 + 0.5f;
          bool _1053 = (_1052 < 0.5f);
          float _1054 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1055 = select(_1053, (User_000.UserConstant_Z_000[5].x), _1054);
          bool _1056 = (_1027 < _1028);
          float _1057 = select(_1056, _1028, _1027);
          float _1058 = select(_1056, _1027, _1028);
          bool _1059 = (_1026 < _1057);
          float _1060 = select(_1059, _1057, _1026);
          float _1061 = select(_1059, _1026, _1057);
          float _1062 = min(_1061, _1058);
          float _1063 = _1060 - _1062;
          float _1064 = _1060 + 1.000000013351432e-10f;
          float _1065 = _1063 / _1064;
          float _1067 = _1065 - (User_000.UserConstant_Z_000[5].y);
          float _1068 = saturate(_1067);
          float _1069 = max(_1068, 9.999999974752427e-07f);
          float _1070 = log2(_1069);
          float _1071 = _1070 * _1055;
          float _1072 = exp2(_1071);
          float _1073 = 2.0f - _1072;
          float _1075 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1076 = saturate(_1075);
          float _1077 = max(_1076, _1073);
          float _1078 = dot(float3(_1026, _1027, _1028), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1079 = _1026 - _1078;
          float _1080 = _1027 - _1078;
          float _1081 = _1028 - _1078;
          float _1082 = _1079 * _1077;
          float _1083 = _1080 * _1077;
          float _1084 = _1081 * _1077;
          float _1085 = _1078 - _1026;
          float _1086 = _1085 + _1082;
          float _1087 = _1078 - _1027;
          float _1088 = _1087 + _1083;
          float _1089 = _1078 - _1028;
          float _1090 = _1089 + _1084;
          float _1091 = _1086 * _1039;
          float _1092 = _1088 * _1039;
          float _1093 = _1090 * _1039;
          float _1094 = _1091 + _1026;
          float _1095 = _1092 + _1027;
          float _1096 = _1093 + _1028;
          _1213 = _1094;
          _1214 = _1095;
          _1215 = _1096;
        } else {
          bool _1098 = (_1039 == 0.0f);
          if (!_1098) {
            float _1102 = abs(User_000.UserConstant_Z_000[5].x);
            float _1103 = saturate(_1102);
            uint4 _1105 = 0u; t15.GetDimensions(0u, _1105.x, _1105.y, _1105.w);
            float _1108 = float((uint)_1105.y);
            int _1109 = _694 & 32;
            bool _1110 = (_1109 == 0);
            float _1111 = _1108 + -1.0f;
            if (!_1110) {
              float _1113 = 1.0f / _1111;
              uint _1114 = uint(SV_Position.x);
              uint _1115 = uint(SV_Position.y);
              int _1116 = _1114 & 63;
              int _1117 = _1115 & 63;
              float4 _1119 = t6.Load(int4(_1116, _1117, 0, 0));
              float _1122 = _1119.x + -0.5f;
              float _1123 = _1026 * 13.999999046325684f;
              float _1124 = _1027 * 13.999999046325684f;
              float _1125 = _1028 * 13.999999046325684f;
              float _1126 = saturate(_1123);
              float _1127 = saturate(_1124);
              float _1128 = saturate(_1125);
              float _1129 = _1026 + -0.9285714030265808f;
              float _1130 = _1027 + -0.9285714030265808f;
              float _1131 = _1028 + -0.9285714030265808f;
              float _1132 = _1129 * 13.999999046325684f;
              float _1133 = _1130 * 13.999999046325684f;
              float _1134 = _1131 * 13.999999046325684f;
              float _1135 = saturate(_1132);
              float _1136 = saturate(_1133);
              float _1137 = saturate(_1134);
              float _1138 = 1.0f - _1135;
              float _1139 = 1.0f - _1136;
              float _1140 = 1.0f - _1137;
              float _1141 = min(_1126, _1138);
              float _1142 = min(_1127, _1139);
              float _1143 = min(_1128, _1140);
              float _1144 = _1119.y + -0.5f;
              float _1145 = _1141 * _1144;
              float _1146 = _1142 * _1144;
              float _1147 = _1143 * _1144;
              float _1148 = _1145 + _1122;
              float _1149 = _1146 + _1122;
              float _1150 = _1147 + _1122;
              float _1151 = _1148 * _1113;
              float _1152 = _1149 * _1113;
              float _1153 = _1150 * _1113;
              float _1154 = _1151 + _1026;
              float _1155 = _1152 + _1027;
              float _1156 = _1153 + _1028;
              float _1157 = saturate(_1154);
              float _1158 = saturate(_1155);
              float _1159 = saturate(_1156);
              float _1160 = saturate(_1157);
              float _1161 = saturate(_1158);
              float _1162 = saturate(_1159);
              _1164 = _1160;
              _1165 = _1161;
              _1166 = _1162;
            } else {
              _1164 = _1026;
              _1165 = _1027;
              _1166 = _1028;
            }
            float _1167 = float((uint)_1105.x);
            float _1168 = _1111 / _1167;
            float _1169 = _1168 * _1164;
            float _1170 = 0.5f / _1167;
            float _1171 = _1169 + _1170;
            float _1172 = _1111 / _1108;
            float _1173 = _1172 * _1165;
            float _1174 = 0.5f / _1108;
            float _1175 = _1173 + _1174;
            float _1176 = _1166 * _1111;
            float _1177 = floor(_1176);
            float _1178 = frac(_1176);
            float _1179 = _1177 / _1108;
            float _1180 = _1179 + _1171;
            float _1181 = _1177 + 1.0f;
            float _1182 = _1181 / _1108;
            float _1183 = _1182 + _1171;
            float4 _1185 = t15.Sample(s0, float2(_1180, _1175));
            float4 _1189 = t15.Sample(s0, float2(_1183, _1175));
            float _1193 = _1189.x - _1185.x;
            float _1194 = _1189.y - _1185.y;
            float _1195 = _1189.z - _1185.z;
            float _1196 = _1193 * _1178;
            float _1197 = _1194 * _1178;
            float _1198 = _1195 * _1178;
            float _1199 = _1103 * _1039;
            float _1200 = _1185.x - _1026;
            float _1201 = _1200 + _1196;
            float _1202 = _1185.y - _1027;
            float _1203 = _1202 + _1197;
            float _1204 = _1185.z - _1028;
            float _1205 = _1204 + _1198;
            float _1206 = _1201 * _1199;
            float _1207 = _1203 * _1199;
            float _1208 = _1205 * _1199;
            float _1209 = _1206 + _1026;
            float _1210 = _1207 + _1027;
            float _1211 = _1208 + _1028;
            _1213 = _1209;
            _1214 = _1210;
            _1215 = _1211;
          } else {
            _1213 = _1026;
            _1214 = _1027;
            _1215 = _1028;
          }
        }
      } else {
        _1213 = _1026;
        _1214 = _1027;
        _1215 = _1028;
      }
    } else {
      _1213 = _1039;
      _1214 = _1039;
      _1215 = _1039;
    }
    float _1216 = _1213 * 13.450128555297852f;
    float _1217 = _1214 * 13.450128555297852f;
    float _1218 = _1215 * 13.450128555297852f;
    float _1219 = exp2(_1216);
    float _1220 = exp2(_1217);
    float _1221 = exp2(_1218);
    float _1222 = _1219 + -1.0f;
    float _1223 = _1220 + -1.0f;
    float _1224 = _1221 + -1.0f;
    float _1225 = _1222 * _672;
    float _1226 = _1223 * _672;
    float _1227 = _1224 * _672;
    _1229 = _1225;
    _1230 = _1226;
    _1231 = _1227;
  } else {
    _1229 = _673;
    _1230 = _674;
    _1231 = _675;
  }
  float _1236 = (User_000.UserConstant_Z_000[8].x) * _1229;
  float _1237 = (User_000.UserConstant_Z_000[8].y) * _1230;
  float _1238 = (User_000.UserConstant_Z_000[8].z) * _1231;
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3(_1236, _1237, _1238),
      SV_Position.xy);
  float _1243 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _1244 = _1243 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _1245 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _1246 = _1245 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _1249 = _1244 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _1250 = _1246 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _1253 = t9.Sample(s9, float2(_1249, _1250));
  float _1257 = dot(float3(_1236, _1237, _1238), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _1260 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _1263 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _1264 = select(_1260, _1263, 0);
  float _1265 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _1266 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _1267 = uint(_1265);
  uint _1268 = uint(_1266);
  int _1269 = _1267 & 63;
  int _1270 = _1268 & 63;
  float4 _1272 = t6.Load(int4(_1269, _1270, _1264, 0));
  bool _1274 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_1274) {
    float _1276 = _1265 * 0.015625f;
    float _1277 = _1266 * 0.015625f;
    float _1278 = float((uint)_1263);
    float _1279 = select(_1260, _1278, 0.0f);
    float4 _1281 = t6.SampleLevel(s1, float3(_1276, _1277, _1279), 0.0f);
    float _1283 = _1272.y - _1281.y;
    float _1284 = _1283 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _1285 = _1284 + _1281.y;
    _1287 = _1285;
  } else {
    _1287 = _1272.y;
  }
  float _1288 = _1253.x * -2.0f;
  float _1289 = _1288 * _1287;
  float _1290 = _1287 * 2.0f;
  float _1291 = _1290 * _1253.y;
  float _1292 = _1290 * _1253.z;
  float _1293 = _1289 + _1253.x;
  float _1294 = _1291 - _1253.y;
  float _1295 = _1292 - _1253.z;
  float _1296 = _1293 * _1253.x;
  float _1297 = _1294 * _1253.y;
  float _1298 = _1295 * _1253.z;
  float _1299 = _1257 + 1.0f;
  float _1300 = _1257 / _1299;
  float _1301 = _1300 + -9.999999747378752e-05f;
  float _1302 = _1301 * 1111.111083984375f;
  float _1303 = saturate(_1302);
  float _1304 = _1303 * 2.0f;
  float _1305 = 3.0f - _1304;
  float _1306 = _1303 * _1303;
  float _1307 = _1306 * _1305;
  bool _1309 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _1310 = float((bool)_1309);
  float _1311 = dot(float3(_1296, _1297, _1298), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1312 = _1311 - _1296;
  float _1313 = _1311 - _1297;
  float _1314 = _1311 - _1298;
  float _1315 = _1312 * _1310;
  float _1316 = _1313 * _1310;
  float _1317 = _1314 * _1310;
  float _1318 = _1315 + _1296;
  float _1319 = _1316 + _1297;
  float _1320 = _1317 + _1298;
  float _1324 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1325 = _1324 * _1300;
  float _1326 = _1325 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1327 = _1307 * _1326;
  float _1328 = _1327 * _1318;
  float _1329 = _1327 * _1319;
  float _1330 = _1327 * _1320;
  float _1331 = _1328 + _1236;
  float _1332 = _1329 + _1237;
  float _1333 = _1330 + _1238;
  float _1334 = max(0.0f, _1331);
  float _1335 = max(0.0f, _1332);
  float _1336 = max(0.0f, _1333);
  float3 resonance_film_grain_output = ResonanceSelectFilmGrainOutput(
      float3(_1334, _1335, _1336),
      resonance_perceptual_film_grain);
  _1334 = resonance_film_grain_output.x;
  _1335 = resonance_film_grain_output.y;
  _1336 = resonance_film_grain_output.z;
  float _1339 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1340 = log2(_1334);
  float _1341 = _1339 * _1340;
  float _1342 = exp2(_1341);
  float _1343 = _1342 + -1.0f;
  float _1344 = _1334 + -1.0f;
  float _1345 = _1343 / _1344;
  bool _1346 = !(_1334 == 1.0f);
  float _1347 = _1345 + -1.0f;
  float _1348 = _1347 / _1345;
  float _1349 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1350 = _1349 / _1339;
  float _1351 = select(_1346, _1348, _1350);
  float _1352 = log2(_1335);
  float _1353 = _1352 * _1339;
  float _1354 = exp2(_1353);
  float _1355 = _1354 + -1.0f;
  float _1356 = _1335 + -1.0f;
  float _1357 = _1355 / _1356;
  bool _1358 = !(_1335 == 1.0f);
  float _1359 = _1357 + -1.0f;
  float _1360 = _1359 / _1357;
  float _1361 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1362 = _1361 / _1339;
  float _1363 = select(_1358, _1360, _1362);
  float _1364 = log2(_1336);
  float _1365 = _1364 * _1339;
  float _1366 = exp2(_1365);
  float _1367 = _1366 + -1.0f;
  float _1368 = _1336 + -1.0f;
  float _1369 = _1367 / _1368;
  bool _1370 = !(_1336 == 1.0f);
  float _1371 = _1369 + -1.0f;
  float _1372 = _1371 / _1369;
  float _1373 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1374 = _1373 / _1339;
  float _1375 = select(_1370, _1372, _1374);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1334, _1335, _1336),
      float3(_1351, _1363, _1375),
      true);
  float _1376 = resonance_post_process_output.x;
  float _1377 = resonance_post_process_output.y;
  float _1378 = resonance_post_process_output.z;
  float _1379 = log2(_1376);
  float _1380 = log2(_1377);
  float _1381 = log2(_1378);
  float _1382 = _1379 * 0.4166666567325592f;
  float _1383 = _1380 * 0.4166666567325592f;
  float _1384 = _1381 * 0.4166666567325592f;
  float _1385 = exp2(_1382);
  float _1386 = exp2(_1383);
  float _1387 = exp2(_1384);
  float _1388 = _1385 * 1.0549999475479126f;
  float _1389 = _1386 * 1.0549999475479126f;
  float _1390 = _1387 * 1.0549999475479126f;
  float _1391 = _1388 + -0.054999999701976776f;
  float _1392 = _1389 + -0.054999999701976776f;
  float _1393 = _1390 + -0.054999999701976776f;
  float _1394 = _1376 * 12.920000076293945f;
  float _1395 = _1377 * 12.920000076293945f;
  float _1396 = _1378 * 12.920000076293945f;
  bool _1397 = (_1376 <= 0.0031308000907301903f);
  bool _1398 = (_1377 <= 0.0031308000907301903f);
  bool _1399 = (_1378 <= 0.0031308000907301903f);
  float _1400 = select(_1397, _1394, _1391);
  float _1401 = select(_1398, _1395, _1392);
  float _1402 = select(_1399, _1396, _1393);
  uint _1403 = uint(SV_Position.x);
  uint _1404 = uint(SV_Position.y);
  int _1405 = _1403 & 63;
  int _1406 = _1404 & 63;
  float4 _1408 = t1.Load(int4(_1405, _1406, _1263, 0));
  float _1410 = _1408.x + -0.5f;
  float _1411 = _1410 * 0.003921568859368563f;
  float _1412 = _1411 + _1400;
  float _1413 = _1411 + _1401;
  float _1414 = _1411 + _1402;
  float _1415 = saturate(_1412);
  float _1416 = saturate(_1413);
  float _1417 = saturate(_1414);
  SV_Target.x = _1415;
  SV_Target.y = _1416;
  SV_Target.z = _1417;
  SV_Target.w = _138.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}