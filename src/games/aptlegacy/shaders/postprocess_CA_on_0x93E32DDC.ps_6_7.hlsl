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

#include "../common.hlsli"

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
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
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
  float _821;
  float _925;
  float _1029;
  float _1032;
  float _1033;
  float _1034;
  float _1045;
  float _1170;
  float _1171;
  float _1172;
  float _1219;
  float _1220;
  float _1221;
  float _1235;
  float _1236;
  float _1237;
  float _1293;
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
      _581 = _378;
      _582 = _195;
      _583 = _385;
    } else {
      _581 = _194;
      _582 = _195;
      _583 = _196;
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
      _581 = _431;
      _582 = _432;
      _583 = _433;
    } else {
      int _436 = asint((User_000.UserConstant_Z_000[7].x));
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
        float4 _502 = t7.Load(int3(0, 0, 0));
        float _507 = _502.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _508 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _507;
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
      float _570 = _548.x - _194;
      float _571 = _548.y - _195;
      float _572 = _548.z - _196;
      float _573 = _572 + _567;
      float _574 = _569 * _570;
      float _575 = _569 * _571;
      float _576 = _573 * _569;
      float _577 = _574 + _194;
      float _578 = _575 + _195;
      float _579 = _576 + _196;
      _581 = _577;
      _582 = _578;
      _583 = _579;
    }
  }
  if (_158) {
    bool _587 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _591 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _151.x;
    float _592 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _151.y;
    float _593 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _151.z;
    float _594 = _591 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _595 = _592 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _596 = _593 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_587) {
      float _598 = _594 * _145.x;
      float _599 = _595 * _145.y;
      float _600 = _596 * _145.z;
      _612 = _598;
      _613 = _599;
      _614 = _600;
    } else {
      float _602 = saturate(_594);
      float _603 = saturate(_595);
      float _604 = saturate(_596);
      float _605 = _145.x - _581;
      float _606 = _145.y - _582;
      float _607 = _145.z - _583;
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
  float _633 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _634 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _635 = _625.x * _634;
  float _636 = _635 * _619;
  float _637 = _636 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _638 = _637 * _633;
  float _639 = _635 * _620;
  float _640 = _639 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _641 = _640 * _633;
  float _642 = _635 * _621;
  float _643 = _642 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _644 = _643 * _633;
  float _645 = _638 + 1.0f;
  float _646 = _641 + 1.0f;
  float _647 = _644 + 1.0f;
  float _648 = log2(_645);
  float _649 = log2(_646);
  float _650 = log2(_647);
  float _653 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _654 = _653 * _648;
  float _655 = _653 * _649;
  float _656 = _653 * _650;
  float _658 = _654 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _659 = _655 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _660 = _656 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _663 = t3.Sample(s3, float3(_658, _659, _660));
  float _669 = _663.x * 13.450128555297852f;
  float _670 = _663.y * 13.450128555297852f;
  float _671 = _663.z * 13.450128555297852f;
  float _672 = exp2(_669);
  float _673 = exp2(_670);
  float _674 = exp2(_671);
  float _675 = _672 + -1.0f;
  float _676 = _673 + -1.0f;
  float _677 = _674 + -1.0f;
  float _678 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _679 = _678 * _675;
  float _680 = _678 * _676;
  float _681 = _678 * _677;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_638 * _678, _641 * _678, _644 * _678),
      float3(_679, _680, _681),
      1.f.xxx);
  _679 = apt_scaled_lut_output.x;
  _680 = apt_scaled_lut_output.y;
  _681 = apt_scaled_lut_output.z;
  bool _684 = ((User_000.UserConstant_Z_000[3].x) > 0.0f);
  if (_684) {
    float _686 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _687 = _679 * _686;
    float _688 = _680 * _686;
    float _689 = _681 * _686;
    float _690 = _687 + 1.0f;
    float _691 = _688 + 1.0f;
    float _692 = _689 + 1.0f;
    float _693 = log2(_690);
    float _694 = log2(_691);
    float _695 = log2(_692);
    float _696 = _693 * 0.07434873282909393f;
    float _697 = _694 * 0.07434873282909393f;
    float _698 = _695 * 0.07434873282909393f;
    int _700 = asint((User_000.UserConstant_Z_000[3].y));
    int _701 = _700 & 1;
    bool _702 = (_701 == 0);
    if (!_702) {
      bool _719 = !(_696 <= (User_000.UserConstant_Z_000[4].x));
      if (!_719) {
        float _721 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _722 = _696 / _721;
        float _723 = _722 * (User_000.UserConstant_Z_000[4].y);
        float _724 = _722 * _722;
        float _725 = _724 * _722;
        float _726 = _725 - _722;
        float _727 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _728 = _721 * _721;
        float _729 = _728 * _727;
        float _730 = _729 * _726;
        float _731 = _730 + _723;
        _821 = _731;
      } else {
        bool _733 = !(_696 <= (User_000.UserConstant_Z_000[4].z));
        if (!_733) {
          float _735 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _736 = max(9.999999974752427e-07f, _735);
          float _737 = _696 - (User_000.UserConstant_Z_000[4].x);
          float _738 = _737 / _736;
          float _739 = 1.0f - _738;
          float _740 = _739 * (User_000.UserConstant_Z_000[4].y);
          float _741 = _738 * (User_000.UserConstant_Z_000[4].w);
          float _742 = _740 + _741;
          float _743 = _739 * _739;
          float _744 = _743 * _739;
          float _745 = _744 - _739;
          float _746 = _745 * (User_000.UserConstant_Z_000[10].x);
          float _747 = _738 * _738;
          float _748 = _747 * _738;
          float _749 = _748 - _738;
          float _750 = _749 * (User_000.UserConstant_Z_000[10].y);
          float _751 = _746 + _750;
          float _752 = _736 * _736;
          float _753 = _752 * 0.1666666716337204f;
          float _754 = _753 * _751;
          float _755 = _742 + _754;
          _821 = _755;
        } else {
          bool _757 = !(_696 <= (User_000.UserConstant_Z_000[9].x));
          if (!_757) {
            float _759 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _760 = max(9.999999974752427e-07f, _759);
            float _761 = _696 - (User_000.UserConstant_Z_000[4].z);
            float _762 = _761 / _760;
            float _763 = 1.0f - _762;
            float _764 = _763 * (User_000.UserConstant_Z_000[4].w);
            float _765 = _762 * (User_000.UserConstant_Z_000[9].y);
            float _766 = _764 + _765;
            float _767 = _763 * _763;
            float _768 = _767 * _763;
            float _769 = _768 - _763;
            float _770 = _769 * (User_000.UserConstant_Z_000[10].y);
            float _771 = _762 * _762;
            float _772 = _771 * _762;
            float _773 = _772 - _762;
            float _774 = _773 * (User_000.UserConstant_Z_000[10].z);
            float _775 = _770 + _774;
            float _776 = _760 * _760;
            float _777 = _776 * 0.1666666716337204f;
            float _778 = _777 * _775;
            float _779 = _766 + _778;
            _821 = _779;
          } else {
            bool _781 = !(_696 <= (User_000.UserConstant_Z_000[9].z));
            if (!_781) {
              float _783 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _784 = max(9.999999974752427e-07f, _783);
              float _785 = _696 - (User_000.UserConstant_Z_000[9].x);
              float _786 = _785 / _784;
              float _787 = 1.0f - _786;
              float _788 = _787 * (User_000.UserConstant_Z_000[9].y);
              float _789 = _786 * (User_000.UserConstant_Z_000[9].w);
              float _790 = _788 + _789;
              float _791 = _787 * _787;
              float _792 = _791 * _787;
              float _793 = _792 - _787;
              float _794 = _793 * (User_000.UserConstant_Z_000[10].z);
              float _795 = _786 * _786;
              float _796 = _795 * _786;
              float _797 = _796 - _786;
              float _798 = _797 * (User_000.UserConstant_Z_000[10].w);
              float _799 = _794 + _798;
              float _800 = _784 * _784;
              float _801 = _800 * 0.1666666716337204f;
              float _802 = _801 * _799;
              float _803 = _790 + _802;
              _821 = _803;
            } else {
              float _805 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _806 = _696 - (User_000.UserConstant_Z_000[9].z);
              float _807 = max(9.999999974752427e-07f, _805);
              float _808 = _806 / _807;
              float _809 = 1.0f - _808;
              float _810 = _809 * (User_000.UserConstant_Z_000[9].w);
              float _811 = _810 + _808;
              float _812 = _809 * _809;
              float _813 = _812 * _809;
              float _814 = _813 - _809;
              float _815 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _816 = _805 * _805;
              float _817 = _816 * _815;
              float _818 = _817 * _814;
              float _819 = _811 + _818;
              _821 = _819;
            }
          }
        }
      }
      float _822 = saturate(_821);
      bool _823 = !(_697 <= (User_000.UserConstant_Z_000[4].x));
      if (!_823) {
        float _825 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _826 = _697 / _825;
        float _827 = _826 * (User_000.UserConstant_Z_000[4].y);
        float _828 = _826 * _826;
        float _829 = _828 * _826;
        float _830 = _829 - _826;
        float _831 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _832 = _825 * _825;
        float _833 = _832 * _831;
        float _834 = _833 * _830;
        float _835 = _834 + _827;
        _925 = _835;
      } else {
        bool _837 = !(_697 <= (User_000.UserConstant_Z_000[4].z));
        if (!_837) {
          float _839 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _840 = max(9.999999974752427e-07f, _839);
          float _841 = _697 - (User_000.UserConstant_Z_000[4].x);
          float _842 = _841 / _840;
          float _843 = 1.0f - _842;
          float _844 = _843 * (User_000.UserConstant_Z_000[4].y);
          float _845 = _842 * (User_000.UserConstant_Z_000[4].w);
          float _846 = _844 + _845;
          float _847 = _843 * _843;
          float _848 = _847 * _843;
          float _849 = _848 - _843;
          float _850 = _849 * (User_000.UserConstant_Z_000[10].x);
          float _851 = _842 * _842;
          float _852 = _851 * _842;
          float _853 = _852 - _842;
          float _854 = _853 * (User_000.UserConstant_Z_000[10].y);
          float _855 = _850 + _854;
          float _856 = _840 * _840;
          float _857 = _856 * 0.1666666716337204f;
          float _858 = _857 * _855;
          float _859 = _846 + _858;
          _925 = _859;
        } else {
          bool _861 = !(_697 <= (User_000.UserConstant_Z_000[9].x));
          if (!_861) {
            float _863 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _864 = max(9.999999974752427e-07f, _863);
            float _865 = _697 - (User_000.UserConstant_Z_000[4].z);
            float _866 = _865 / _864;
            float _867 = 1.0f - _866;
            float _868 = _867 * (User_000.UserConstant_Z_000[4].w);
            float _869 = _866 * (User_000.UserConstant_Z_000[9].y);
            float _870 = _868 + _869;
            float _871 = _867 * _867;
            float _872 = _871 * _867;
            float _873 = _872 - _867;
            float _874 = _873 * (User_000.UserConstant_Z_000[10].y);
            float _875 = _866 * _866;
            float _876 = _875 * _866;
            float _877 = _876 - _866;
            float _878 = _877 * (User_000.UserConstant_Z_000[10].z);
            float _879 = _874 + _878;
            float _880 = _864 * _864;
            float _881 = _880 * 0.1666666716337204f;
            float _882 = _881 * _879;
            float _883 = _870 + _882;
            _925 = _883;
          } else {
            bool _885 = !(_697 <= (User_000.UserConstant_Z_000[9].z));
            if (!_885) {
              float _887 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _888 = max(9.999999974752427e-07f, _887);
              float _889 = _697 - (User_000.UserConstant_Z_000[9].x);
              float _890 = _889 / _888;
              float _891 = 1.0f - _890;
              float _892 = _891 * (User_000.UserConstant_Z_000[9].y);
              float _893 = _890 * (User_000.UserConstant_Z_000[9].w);
              float _894 = _892 + _893;
              float _895 = _891 * _891;
              float _896 = _895 * _891;
              float _897 = _896 - _891;
              float _898 = _897 * (User_000.UserConstant_Z_000[10].z);
              float _899 = _890 * _890;
              float _900 = _899 * _890;
              float _901 = _900 - _890;
              float _902 = _901 * (User_000.UserConstant_Z_000[10].w);
              float _903 = _898 + _902;
              float _904 = _888 * _888;
              float _905 = _904 * 0.1666666716337204f;
              float _906 = _905 * _903;
              float _907 = _894 + _906;
              _925 = _907;
            } else {
              float _909 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _910 = _697 - (User_000.UserConstant_Z_000[9].z);
              float _911 = max(9.999999974752427e-07f, _909);
              float _912 = _910 / _911;
              float _913 = 1.0f - _912;
              float _914 = _913 * (User_000.UserConstant_Z_000[9].w);
              float _915 = _914 + _912;
              float _916 = _913 * _913;
              float _917 = _916 * _913;
              float _918 = _917 - _913;
              float _919 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _920 = _909 * _909;
              float _921 = _920 * _919;
              float _922 = _921 * _918;
              float _923 = _915 + _922;
              _925 = _923;
            }
          }
        }
      }
      float _926 = saturate(_925);
      bool _927 = !(_698 <= (User_000.UserConstant_Z_000[4].x));
      if (!_927) {
        float _929 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _930 = _698 / _929;
        float _931 = _930 * (User_000.UserConstant_Z_000[4].y);
        float _932 = _930 * _930;
        float _933 = _932 * _930;
        float _934 = _933 - _930;
        float _935 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _936 = _929 * _929;
        float _937 = _936 * _935;
        float _938 = _937 * _934;
        float _939 = _938 + _931;
        _1029 = _939;
      } else {
        bool _941 = !(_698 <= (User_000.UserConstant_Z_000[4].z));
        if (!_941) {
          float _943 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _944 = max(9.999999974752427e-07f, _943);
          float _945 = _698 - (User_000.UserConstant_Z_000[4].x);
          float _946 = _945 / _944;
          float _947 = 1.0f - _946;
          float _948 = _947 * (User_000.UserConstant_Z_000[4].y);
          float _949 = _946 * (User_000.UserConstant_Z_000[4].w);
          float _950 = _948 + _949;
          float _951 = _947 * _947;
          float _952 = _951 * _947;
          float _953 = _952 - _947;
          float _954 = _953 * (User_000.UserConstant_Z_000[10].x);
          float _955 = _946 * _946;
          float _956 = _955 * _946;
          float _957 = _956 - _946;
          float _958 = _957 * (User_000.UserConstant_Z_000[10].y);
          float _959 = _954 + _958;
          float _960 = _944 * _944;
          float _961 = _960 * 0.1666666716337204f;
          float _962 = _961 * _959;
          float _963 = _950 + _962;
          _1029 = _963;
        } else {
          bool _965 = !(_698 <= (User_000.UserConstant_Z_000[9].x));
          if (!_965) {
            float _967 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _968 = max(9.999999974752427e-07f, _967);
            float _969 = _698 - (User_000.UserConstant_Z_000[4].z);
            float _970 = _969 / _968;
            float _971 = 1.0f - _970;
            float _972 = _971 * (User_000.UserConstant_Z_000[4].w);
            float _973 = _970 * (User_000.UserConstant_Z_000[9].y);
            float _974 = _972 + _973;
            float _975 = _971 * _971;
            float _976 = _975 * _971;
            float _977 = _976 - _971;
            float _978 = _977 * (User_000.UserConstant_Z_000[10].y);
            float _979 = _970 * _970;
            float _980 = _979 * _970;
            float _981 = _980 - _970;
            float _982 = _981 * (User_000.UserConstant_Z_000[10].z);
            float _983 = _978 + _982;
            float _984 = _968 * _968;
            float _985 = _984 * 0.1666666716337204f;
            float _986 = _985 * _983;
            float _987 = _974 + _986;
            _1029 = _987;
          } else {
            bool _989 = !(_698 <= (User_000.UserConstant_Z_000[9].z));
            if (!_989) {
              float _991 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _992 = max(9.999999974752427e-07f, _991);
              float _993 = _698 - (User_000.UserConstant_Z_000[9].x);
              float _994 = _993 / _992;
              float _995 = 1.0f - _994;
              float _996 = _995 * (User_000.UserConstant_Z_000[9].y);
              float _997 = _994 * (User_000.UserConstant_Z_000[9].w);
              float _998 = _996 + _997;
              float _999 = _995 * _995;
              float _1000 = _999 * _995;
              float _1001 = _1000 - _995;
              float _1002 = _1001 * (User_000.UserConstant_Z_000[10].z);
              float _1003 = _994 * _994;
              float _1004 = _1003 * _994;
              float _1005 = _1004 - _994;
              float _1006 = _1005 * (User_000.UserConstant_Z_000[10].w);
              float _1007 = _1002 + _1006;
              float _1008 = _992 * _992;
              float _1009 = _1008 * 0.1666666716337204f;
              float _1010 = _1009 * _1007;
              float _1011 = _998 + _1010;
              _1029 = _1011;
            } else {
              float _1013 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1014 = _698 - (User_000.UserConstant_Z_000[9].z);
              float _1015 = max(9.999999974752427e-07f, _1013);
              float _1016 = _1014 / _1015;
              float _1017 = 1.0f - _1016;
              float _1018 = _1017 * (User_000.UserConstant_Z_000[9].w);
              float _1019 = _1018 + _1016;
              float _1020 = _1017 * _1017;
              float _1021 = _1020 * _1017;
              float _1022 = _1021 - _1017;
              float _1023 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1024 = _1013 * _1013;
              float _1025 = _1024 * _1023;
              float _1026 = _1025 * _1022;
              float _1027 = _1019 + _1026;
              _1029 = _1027;
            }
          }
        }
      }
      float _1030 = saturate(_1029);
      _1032 = _822;
      _1033 = _926;
      _1034 = _1030;
    } else {
      _1032 = _696;
      _1033 = _697;
      _1034 = _698;
    }
    int _1035 = _700 & 2;
    bool _1036 = (_1035 == 0);
    if (!_1036) {
      float _1038 = sqrt(_1032);
      float _1039 = sqrt(_1033);
      float _1040 = sqrt(_1034);
      float _1041 = dot(float3(_1038, _1039, _1040), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1042 = 1.0f - _1041;
      float _1043 = saturate(_1042);
      _1045 = _1043;
    } else {
      _1045 = 1.0f;
    }
    int _1046 = _700 & 8;
    bool _1047 = (_1046 == 0);
    if (_1047) {
      int _1049 = _700 & 4;
      bool _1050 = (_1049 == 0);
      if (!_1050) {
        int _1052 = _700 & 16;
        bool _1053 = (_1052 == 0);
        if (!_1053) {
          float _1057 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1058 = _1057 + 0.5f;
          bool _1059 = (_1058 < 0.5f);
          float _1060 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1061 = select(_1059, (User_000.UserConstant_Z_000[5].x), _1060);
          bool _1062 = (_1033 < _1034);
          float _1063 = select(_1062, _1034, _1033);
          float _1064 = select(_1062, _1033, _1034);
          bool _1065 = (_1032 < _1063);
          float _1066 = select(_1065, _1063, _1032);
          float _1067 = select(_1065, _1032, _1063);
          float _1068 = min(_1067, _1064);
          float _1069 = _1066 - _1068;
          float _1070 = _1066 + 1.000000013351432e-10f;
          float _1071 = _1069 / _1070;
          float _1073 = _1071 - (User_000.UserConstant_Z_000[5].y);
          float _1074 = saturate(_1073);
          float _1075 = max(_1074, 9.999999974752427e-07f);
          float _1076 = log2(_1075);
          float _1077 = _1076 * _1061;
          float _1078 = exp2(_1077);
          float _1079 = 2.0f - _1078;
          float _1081 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1082 = saturate(_1081);
          float _1083 = max(_1082, _1079);
          float _1084 = dot(float3(_1032, _1033, _1034), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1085 = _1032 - _1084;
          float _1086 = _1033 - _1084;
          float _1087 = _1034 - _1084;
          float _1088 = _1085 * _1083;
          float _1089 = _1086 * _1083;
          float _1090 = _1087 * _1083;
          float _1091 = _1084 - _1032;
          float _1092 = _1091 + _1088;
          float _1093 = _1084 - _1033;
          float _1094 = _1093 + _1089;
          float _1095 = _1084 - _1034;
          float _1096 = _1095 + _1090;
          float _1097 = _1092 * _1045;
          float _1098 = _1094 * _1045;
          float _1099 = _1096 * _1045;
          float _1100 = _1097 + _1032;
          float _1101 = _1098 + _1033;
          float _1102 = _1099 + _1034;
          _1219 = _1100;
          _1220 = _1101;
          _1221 = _1102;
        } else {
          bool _1104 = (_1045 == 0.0f);
          if (!_1104) {
            float _1108 = abs(User_000.UserConstant_Z_000[5].x);
            float _1109 = saturate(_1108);
            uint4 _1111 = 0u; t15.GetDimensions(0u, _1111.x, _1111.y, _1111.w);
            float _1114 = float((uint)_1111.y);
            int _1115 = _700 & 32;
            bool _1116 = (_1115 == 0);
            float _1117 = _1114 + -1.0f;
            if (!_1116) {
              float _1119 = 1.0f / _1117;
              uint _1120 = uint(SV_Position.x);
              uint _1121 = uint(SV_Position.y);
              int _1122 = _1120 & 63;
              int _1123 = _1121 & 63;
              float4 _1125 = t6.Load(int4(_1122, _1123, 0, 0));
              float _1128 = _1125.x + -0.5f;
              float _1129 = _1032 * 13.999999046325684f;
              float _1130 = _1033 * 13.999999046325684f;
              float _1131 = _1034 * 13.999999046325684f;
              float _1132 = saturate(_1129);
              float _1133 = saturate(_1130);
              float _1134 = saturate(_1131);
              float _1135 = _1032 + -0.9285714030265808f;
              float _1136 = _1033 + -0.9285714030265808f;
              float _1137 = _1034 + -0.9285714030265808f;
              float _1138 = _1135 * 13.999999046325684f;
              float _1139 = _1136 * 13.999999046325684f;
              float _1140 = _1137 * 13.999999046325684f;
              float _1141 = saturate(_1138);
              float _1142 = saturate(_1139);
              float _1143 = saturate(_1140);
              float _1144 = 1.0f - _1141;
              float _1145 = 1.0f - _1142;
              float _1146 = 1.0f - _1143;
              float _1147 = min(_1132, _1144);
              float _1148 = min(_1133, _1145);
              float _1149 = min(_1134, _1146);
              float _1150 = _1125.y + -0.5f;
              float _1151 = _1147 * _1150;
              float _1152 = _1148 * _1150;
              float _1153 = _1149 * _1150;
              float _1154 = _1151 + _1128;
              float _1155 = _1152 + _1128;
              float _1156 = _1153 + _1128;
              float _1157 = _1154 * _1119;
              float _1158 = _1155 * _1119;
              float _1159 = _1156 * _1119;
              float _1160 = _1157 + _1032;
              float _1161 = _1158 + _1033;
              float _1162 = _1159 + _1034;
              float _1163 = saturate(_1160);
              float _1164 = saturate(_1161);
              float _1165 = saturate(_1162);
              float _1166 = saturate(_1163);
              float _1167 = saturate(_1164);
              float _1168 = saturate(_1165);
              _1170 = _1166;
              _1171 = _1167;
              _1172 = _1168;
            } else {
              _1170 = _1032;
              _1171 = _1033;
              _1172 = _1034;
            }
            float _1173 = float((uint)_1111.x);
            float _1174 = _1117 / _1173;
            float _1175 = _1174 * _1170;
            float _1176 = 0.5f / _1173;
            float _1177 = _1175 + _1176;
            float _1178 = _1117 / _1114;
            float _1179 = _1178 * _1171;
            float _1180 = 0.5f / _1114;
            float _1181 = _1179 + _1180;
            float _1182 = _1172 * _1117;
            float _1183 = floor(_1182);
            float _1184 = frac(_1182);
            float _1185 = _1183 / _1114;
            float _1186 = _1185 + _1177;
            float _1187 = _1183 + 1.0f;
            float _1188 = _1187 / _1114;
            float _1189 = _1188 + _1177;
            float4 _1191 = t15.Sample(s0, float2(_1186, _1181));
            float4 _1195 = t15.Sample(s0, float2(_1189, _1181));
            float _1199 = _1195.x - _1191.x;
            float _1200 = _1195.y - _1191.y;
            float _1201 = _1195.z - _1191.z;
            float _1202 = _1199 * _1184;
            float _1203 = _1200 * _1184;
            float _1204 = _1201 * _1184;
            float _1205 = _1109 * _1045;
            float _1206 = _1191.x - _1032;
            float _1207 = _1206 + _1202;
            float _1208 = _1191.y - _1033;
            float _1209 = _1208 + _1203;
            float _1210 = _1191.z - _1034;
            float _1211 = _1210 + _1204;
            float _1212 = _1207 * _1205;
            float _1213 = _1209 * _1205;
            float _1214 = _1211 * _1205;
            float _1215 = _1212 + _1032;
            float _1216 = _1213 + _1033;
            float _1217 = _1214 + _1034;
            _1219 = _1215;
            _1220 = _1216;
            _1221 = _1217;
          } else {
            _1219 = _1032;
            _1220 = _1033;
            _1221 = _1034;
          }
        }
      } else {
        _1219 = _1032;
        _1220 = _1033;
        _1221 = _1034;
      }
    } else {
      _1219 = _1045;
      _1220 = _1045;
      _1221 = _1045;
    }
    float _1222 = _1219 * 13.450128555297852f;
    float _1223 = _1220 * 13.450128555297852f;
    float _1224 = _1221 * 13.450128555297852f;
    float _1225 = exp2(_1222);
    float _1226 = exp2(_1223);
    float _1227 = exp2(_1224);
    float _1228 = _1225 + -1.0f;
    float _1229 = _1226 + -1.0f;
    float _1230 = _1227 + -1.0f;
    float _1231 = _1228 * _678;
    float _1232 = _1229 * _678;
    float _1233 = _1230 * _678;
    _1235 = _1231;
    _1236 = _1232;
    _1237 = _1233;
  } else {
    _1235 = _679;
    _1236 = _680;
    _1237 = _681;
  }
  float _1242 = (User_000.UserConstant_Z_000[8].x) * _1235;
  float _1243 = (User_000.UserConstant_Z_000[8].y) * _1236;
  float _1244 = (User_000.UserConstant_Z_000[8].z) * _1237;
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3(_1242, _1243, _1244),
      SV_Position.xy);
  float _1249 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _1250 = _1249 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _1251 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _1252 = _1251 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _1255 = _1250 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _1256 = _1252 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _1259 = t9.Sample(s9, float2(_1255, _1256));
  float _1263 = dot(float3(_1242, _1243, _1244), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _1266 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _1269 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _1270 = select(_1266, _1269, 0);
  float _1271 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _1272 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _1273 = uint(_1271);
  uint _1274 = uint(_1272);
  int _1275 = _1273 & 63;
  int _1276 = _1274 & 63;
  float4 _1278 = t6.Load(int4(_1275, _1276, _1270, 0));
  bool _1280 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_1280) {
    float _1282 = _1271 * 0.015625f;
    float _1283 = _1272 * 0.015625f;
    float _1284 = float((uint)_1269);
    float _1285 = select(_1266, _1284, 0.0f);
    float4 _1287 = t6.SampleLevel(s1, float3(_1282, _1283, _1285), 0.0f);
    float _1289 = _1278.y - _1287.y;
    float _1290 = _1289 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _1291 = _1290 + _1287.y;
    _1293 = _1291;
  } else {
    _1293 = _1278.y;
  }
  float _1294 = _1259.x * -2.0f;
  float _1295 = _1294 * _1293;
  float _1296 = _1293 * 2.0f;
  float _1297 = _1296 * _1259.y;
  float _1298 = _1296 * _1259.z;
  float _1299 = _1295 + _1259.x;
  float _1300 = _1297 - _1259.y;
  float _1301 = _1298 - _1259.z;
  float _1302 = _1299 * _1259.x;
  float _1303 = _1300 * _1259.y;
  float _1304 = _1301 * _1259.z;
  float _1305 = _1263 + 1.0f;
  float _1306 = _1263 / _1305;
  float _1307 = _1306 + -9.999999747378752e-05f;
  float _1308 = _1307 * 1111.111083984375f;
  float _1309 = saturate(_1308);
  float _1310 = _1309 * 2.0f;
  float _1311 = 3.0f - _1310;
  float _1312 = _1309 * _1309;
  float _1313 = _1312 * _1311;
  bool _1315 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _1316 = float((bool)_1315);
  float _1317 = dot(float3(_1302, _1303, _1304), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1318 = _1317 - _1302;
  float _1319 = _1317 - _1303;
  float _1320 = _1317 - _1304;
  float _1321 = _1318 * _1316;
  float _1322 = _1319 * _1316;
  float _1323 = _1320 * _1316;
  float _1324 = _1321 + _1302;
  float _1325 = _1322 + _1303;
  float _1326 = _1323 + _1304;
  float _1330 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1331 = _1330 * _1306;
  float _1332 = _1331 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1333 = _1313 * _1332;
  float _1334 = _1333 * _1324;
  float _1335 = _1333 * _1325;
  float _1336 = _1333 * _1326;
  float _1337 = _1334 + _1242;
  float _1338 = _1335 + _1243;
  float _1339 = _1336 + _1244;
  float _1340 = max(0.0f, _1337);
  float _1341 = max(0.0f, _1338);
  float _1342 = max(0.0f, _1339);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_1340, _1341, _1342),
      apt_perceptual_film_grain);
  _1340 = apt_film_grain_output.x;
  _1341 = apt_film_grain_output.y;
  _1342 = apt_film_grain_output.z;
  float _1345 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1346 = log2(_1340);
  float _1347 = _1345 * _1346;
  float _1348 = exp2(_1347);
  float _1349 = _1348 + -1.0f;
  float _1350 = _1340 + -1.0f;
  float _1351 = _1349 / _1350;
  bool _1352 = !(_1340 == 1.0f);
  float _1353 = _1351 + -1.0f;
  float _1354 = _1353 / _1351;
  float _1355 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1356 = _1355 / _1345;
  float _1357 = select(_1352, _1354, _1356);
  float _1358 = log2(_1341);
  float _1359 = _1358 * _1345;
  float _1360 = exp2(_1359);
  float _1361 = _1360 + -1.0f;
  float _1362 = _1341 + -1.0f;
  float _1363 = _1361 / _1362;
  bool _1364 = !(_1341 == 1.0f);
  float _1365 = _1363 + -1.0f;
  float _1366 = _1365 / _1363;
  float _1367 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1368 = _1367 / _1345;
  float _1369 = select(_1364, _1366, _1368);
  float _1370 = log2(_1342);
  float _1371 = _1370 * _1345;
  float _1372 = exp2(_1371);
  float _1373 = _1372 + -1.0f;
  float _1374 = _1342 + -1.0f;
  float _1375 = _1373 / _1374;
  bool _1376 = !(_1342 == 1.0f);
  float _1377 = _1375 + -1.0f;
  float _1378 = _1377 / _1375;
  float _1379 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1380 = _1379 / _1345;
  float _1381 = select(_1376, _1378, _1380);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1340, _1341, _1342),
      float3(_1357, _1369, _1381),
      true);
  float _1382 = apt_post_process_output.x;
  float _1383 = apt_post_process_output.y;
  float _1384 = apt_post_process_output.z;
  float _1385 = log2(_1382);
  float _1386 = log2(_1383);
  float _1387 = log2(_1384);
  float _1388 = _1385 * 0.4166666567325592f;
  float _1389 = _1386 * 0.4166666567325592f;
  float _1390 = _1387 * 0.4166666567325592f;
  float _1391 = exp2(_1388);
  float _1392 = exp2(_1389);
  float _1393 = exp2(_1390);
  float _1394 = _1391 * 1.0549999475479126f;
  float _1395 = _1392 * 1.0549999475479126f;
  float _1396 = _1393 * 1.0549999475479126f;
  float _1397 = _1394 + -0.054999999701976776f;
  float _1398 = _1395 + -0.054999999701976776f;
  float _1399 = _1396 + -0.054999999701976776f;
  float _1400 = _1382 * 12.920000076293945f;
  float _1401 = _1383 * 12.920000076293945f;
  float _1402 = _1384 * 12.920000076293945f;
  bool _1403 = (_1382 <= 0.0031308000907301903f);
  bool _1404 = (_1383 <= 0.0031308000907301903f);
  bool _1405 = (_1384 <= 0.0031308000907301903f);
  float _1406 = select(_1403, _1400, _1397);
  float _1407 = select(_1404, _1401, _1398);
  float _1408 = select(_1405, _1402, _1399);
  uint _1409 = uint(SV_Position.x);
  uint _1410 = uint(SV_Position.y);
  int _1411 = _1409 & 63;
  int _1412 = _1410 & 63;
  float4 _1414 = t1.Load(int4(_1411, _1412, _1269, 0));
  float _1416 = _1414.x + -0.5f;
  float _1417 = _1416 * 0.003921568859368563f;
  float _1418 = _1417 + _1406;
  float _1419 = _1417 + _1407;
  float _1420 = _1417 + _1408;
  float _1421 = saturate(_1418);
  float _1422 = saturate(_1419);
  float _1423 = saturate(_1420);
  SV_Target.x = _1421;
  SV_Target.y = _1422;
  SV_Target.z = _1423;
  SV_Target.w = _138.w;
  return SV_Target;
}
