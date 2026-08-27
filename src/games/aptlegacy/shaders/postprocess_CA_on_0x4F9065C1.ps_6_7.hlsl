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
  float _856;
  float _960;
  float _1064;
  float _1067;
  float _1068;
  float _1069;
  float _1080;
  float _1205;
  float _1206;
  float _1207;
  float _1254;
  float _1255;
  float _1256;
  float _1270;
  float _1271;
  float _1272;
  float _1328;
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
  float _631 = _625.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _632 = _631 * _619;
  float _633 = _632 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _634 = _631 * _620;
  float _635 = _634 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _636 = _631 * _621;
  float _637 = _636 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _642 = _60 * 2.0f;
  float _643 = _61 * 2.0f;
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
  float _676 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _677 = _676 * _671;
  float _678 = _676 * _672;
  float _679 = _676 * _673;
  float _680 = _677 + 1.0f;
  float _681 = _678 + 1.0f;
  float _682 = _679 + 1.0f;
  float _683 = log2(_680);
  float _684 = log2(_681);
  float _685 = log2(_682);
  float _688 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _689 = _688 * _683;
  float _690 = _688 * _684;
  float _691 = _688 * _685;
  float _693 = _689 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _694 = _690 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _695 = _691 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _698 = t3.Sample(s3, float3(_693, _694, _695));
  float _704 = _698.x * 13.450128555297852f;
  float _705 = _698.y * 13.450128555297852f;
  float _706 = _698.z * 13.450128555297852f;
  float _707 = exp2(_704);
  float _708 = exp2(_705);
  float _709 = exp2(_706);
  float _710 = _707 + -1.0f;
  float _711 = _708 + -1.0f;
  float _712 = _709 + -1.0f;
  float _713 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _714 = _713 * _710;
  float _715 = _713 * _711;
  float _716 = _713 * _712;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_677 * _713, _678 * _713, _679 * _713),
      float3(_714, _715, _716),
      1.f.xxx);
  _714 = apt_scaled_lut_output.x;
  _715 = apt_scaled_lut_output.y;
  _716 = apt_scaled_lut_output.z;
  bool _719 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !APTIsPsychoV();
  if (_719) {
    float _721 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _722 = _714 * _721;
    float _723 = _715 * _721;
    float _724 = _716 * _721;
    float _725 = _722 + 1.0f;
    float _726 = _723 + 1.0f;
    float _727 = _724 + 1.0f;
    float _728 = log2(_725);
    float _729 = log2(_726);
    float _730 = log2(_727);
    float _731 = _728 * 0.07434873282909393f;
    float _732 = _729 * 0.07434873282909393f;
    float _733 = _730 * 0.07434873282909393f;
    int _735 = asint((User_000.UserConstant_Z_000[3].y));
    int _736 = _735 & 1;
    bool _737 = (_736 == 0);
    if (!_737) {
      bool _754 = !(_731 <= (User_000.UserConstant_Z_000[4].x));
      if (!_754) {
        float _756 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _757 = _731 / _756;
        float _758 = _757 * (User_000.UserConstant_Z_000[4].y);
        float _759 = _757 * _757;
        float _760 = _759 * _757;
        float _761 = _760 - _757;
        float _762 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _763 = _756 * _756;
        float _764 = _763 * _762;
        float _765 = _764 * _761;
        float _766 = _765 + _758;
        _856 = _766;
      } else {
        bool _768 = !(_731 <= (User_000.UserConstant_Z_000[4].z));
        if (!_768) {
          float _770 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _771 = max(9.999999974752427e-07f, _770);
          float _772 = _731 - (User_000.UserConstant_Z_000[4].x);
          float _773 = _772 / _771;
          float _774 = 1.0f - _773;
          float _775 = _774 * (User_000.UserConstant_Z_000[4].y);
          float _776 = _773 * (User_000.UserConstant_Z_000[4].w);
          float _777 = _775 + _776;
          float _778 = _774 * _774;
          float _779 = _778 * _774;
          float _780 = _779 - _774;
          float _781 = _780 * (User_000.UserConstant_Z_000[10].x);
          float _782 = _773 * _773;
          float _783 = _782 * _773;
          float _784 = _783 - _773;
          float _785 = _784 * (User_000.UserConstant_Z_000[10].y);
          float _786 = _781 + _785;
          float _787 = _771 * _771;
          float _788 = _787 * 0.1666666716337204f;
          float _789 = _788 * _786;
          float _790 = _777 + _789;
          _856 = _790;
        } else {
          bool _792 = !(_731 <= (User_000.UserConstant_Z_000[9].x));
          if (!_792) {
            float _794 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _795 = max(9.999999974752427e-07f, _794);
            float _796 = _731 - (User_000.UserConstant_Z_000[4].z);
            float _797 = _796 / _795;
            float _798 = 1.0f - _797;
            float _799 = _798 * (User_000.UserConstant_Z_000[4].w);
            float _800 = _797 * (User_000.UserConstant_Z_000[9].y);
            float _801 = _799 + _800;
            float _802 = _798 * _798;
            float _803 = _802 * _798;
            float _804 = _803 - _798;
            float _805 = _804 * (User_000.UserConstant_Z_000[10].y);
            float _806 = _797 * _797;
            float _807 = _806 * _797;
            float _808 = _807 - _797;
            float _809 = _808 * (User_000.UserConstant_Z_000[10].z);
            float _810 = _805 + _809;
            float _811 = _795 * _795;
            float _812 = _811 * 0.1666666716337204f;
            float _813 = _812 * _810;
            float _814 = _801 + _813;
            _856 = _814;
          } else {
            bool _816 = !(_731 <= (User_000.UserConstant_Z_000[9].z));
            if (!_816) {
              float _818 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _819 = max(9.999999974752427e-07f, _818);
              float _820 = _731 - (User_000.UserConstant_Z_000[9].x);
              float _821 = _820 / _819;
              float _822 = 1.0f - _821;
              float _823 = _822 * (User_000.UserConstant_Z_000[9].y);
              float _824 = _821 * (User_000.UserConstant_Z_000[9].w);
              float _825 = _823 + _824;
              float _826 = _822 * _822;
              float _827 = _826 * _822;
              float _828 = _827 - _822;
              float _829 = _828 * (User_000.UserConstant_Z_000[10].z);
              float _830 = _821 * _821;
              float _831 = _830 * _821;
              float _832 = _831 - _821;
              float _833 = _832 * (User_000.UserConstant_Z_000[10].w);
              float _834 = _829 + _833;
              float _835 = _819 * _819;
              float _836 = _835 * 0.1666666716337204f;
              float _837 = _836 * _834;
              float _838 = _825 + _837;
              _856 = _838;
            } else {
              float _840 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _841 = _731 - (User_000.UserConstant_Z_000[9].z);
              float _842 = max(9.999999974752427e-07f, _840);
              float _843 = _841 / _842;
              float _844 = 1.0f - _843;
              float _845 = _844 * (User_000.UserConstant_Z_000[9].w);
              float _846 = _845 + _843;
              float _847 = _844 * _844;
              float _848 = _847 * _844;
              float _849 = _848 - _844;
              float _850 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _851 = _840 * _840;
              float _852 = _851 * _850;
              float _853 = _852 * _849;
              float _854 = _846 + _853;
              _856 = _854;
            }
          }
        }
      }
      float _857 = saturate(_856);
      bool _858 = !(_732 <= (User_000.UserConstant_Z_000[4].x));
      if (!_858) {
        float _860 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _861 = _732 / _860;
        float _862 = _861 * (User_000.UserConstant_Z_000[4].y);
        float _863 = _861 * _861;
        float _864 = _863 * _861;
        float _865 = _864 - _861;
        float _866 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _867 = _860 * _860;
        float _868 = _867 * _866;
        float _869 = _868 * _865;
        float _870 = _869 + _862;
        _960 = _870;
      } else {
        bool _872 = !(_732 <= (User_000.UserConstant_Z_000[4].z));
        if (!_872) {
          float _874 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _875 = max(9.999999974752427e-07f, _874);
          float _876 = _732 - (User_000.UserConstant_Z_000[4].x);
          float _877 = _876 / _875;
          float _878 = 1.0f - _877;
          float _879 = _878 * (User_000.UserConstant_Z_000[4].y);
          float _880 = _877 * (User_000.UserConstant_Z_000[4].w);
          float _881 = _879 + _880;
          float _882 = _878 * _878;
          float _883 = _882 * _878;
          float _884 = _883 - _878;
          float _885 = _884 * (User_000.UserConstant_Z_000[10].x);
          float _886 = _877 * _877;
          float _887 = _886 * _877;
          float _888 = _887 - _877;
          float _889 = _888 * (User_000.UserConstant_Z_000[10].y);
          float _890 = _885 + _889;
          float _891 = _875 * _875;
          float _892 = _891 * 0.1666666716337204f;
          float _893 = _892 * _890;
          float _894 = _881 + _893;
          _960 = _894;
        } else {
          bool _896 = !(_732 <= (User_000.UserConstant_Z_000[9].x));
          if (!_896) {
            float _898 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _899 = max(9.999999974752427e-07f, _898);
            float _900 = _732 - (User_000.UserConstant_Z_000[4].z);
            float _901 = _900 / _899;
            float _902 = 1.0f - _901;
            float _903 = _902 * (User_000.UserConstant_Z_000[4].w);
            float _904 = _901 * (User_000.UserConstant_Z_000[9].y);
            float _905 = _903 + _904;
            float _906 = _902 * _902;
            float _907 = _906 * _902;
            float _908 = _907 - _902;
            float _909 = _908 * (User_000.UserConstant_Z_000[10].y);
            float _910 = _901 * _901;
            float _911 = _910 * _901;
            float _912 = _911 - _901;
            float _913 = _912 * (User_000.UserConstant_Z_000[10].z);
            float _914 = _909 + _913;
            float _915 = _899 * _899;
            float _916 = _915 * 0.1666666716337204f;
            float _917 = _916 * _914;
            float _918 = _905 + _917;
            _960 = _918;
          } else {
            bool _920 = !(_732 <= (User_000.UserConstant_Z_000[9].z));
            if (!_920) {
              float _922 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _923 = max(9.999999974752427e-07f, _922);
              float _924 = _732 - (User_000.UserConstant_Z_000[9].x);
              float _925 = _924 / _923;
              float _926 = 1.0f - _925;
              float _927 = _926 * (User_000.UserConstant_Z_000[9].y);
              float _928 = _925 * (User_000.UserConstant_Z_000[9].w);
              float _929 = _927 + _928;
              float _930 = _926 * _926;
              float _931 = _930 * _926;
              float _932 = _931 - _926;
              float _933 = _932 * (User_000.UserConstant_Z_000[10].z);
              float _934 = _925 * _925;
              float _935 = _934 * _925;
              float _936 = _935 - _925;
              float _937 = _936 * (User_000.UserConstant_Z_000[10].w);
              float _938 = _933 + _937;
              float _939 = _923 * _923;
              float _940 = _939 * 0.1666666716337204f;
              float _941 = _940 * _938;
              float _942 = _929 + _941;
              _960 = _942;
            } else {
              float _944 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _945 = _732 - (User_000.UserConstant_Z_000[9].z);
              float _946 = max(9.999999974752427e-07f, _944);
              float _947 = _945 / _946;
              float _948 = 1.0f - _947;
              float _949 = _948 * (User_000.UserConstant_Z_000[9].w);
              float _950 = _949 + _947;
              float _951 = _948 * _948;
              float _952 = _951 * _948;
              float _953 = _952 - _948;
              float _954 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _955 = _944 * _944;
              float _956 = _955 * _954;
              float _957 = _956 * _953;
              float _958 = _950 + _957;
              _960 = _958;
            }
          }
        }
      }
      float _961 = saturate(_960);
      bool _962 = !(_733 <= (User_000.UserConstant_Z_000[4].x));
      if (!_962) {
        float _964 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _965 = _733 / _964;
        float _966 = _965 * (User_000.UserConstant_Z_000[4].y);
        float _967 = _965 * _965;
        float _968 = _967 * _965;
        float _969 = _968 - _965;
        float _970 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _971 = _964 * _964;
        float _972 = _971 * _970;
        float _973 = _972 * _969;
        float _974 = _973 + _966;
        _1064 = _974;
      } else {
        bool _976 = !(_733 <= (User_000.UserConstant_Z_000[4].z));
        if (!_976) {
          float _978 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _979 = max(9.999999974752427e-07f, _978);
          float _980 = _733 - (User_000.UserConstant_Z_000[4].x);
          float _981 = _980 / _979;
          float _982 = 1.0f - _981;
          float _983 = _982 * (User_000.UserConstant_Z_000[4].y);
          float _984 = _981 * (User_000.UserConstant_Z_000[4].w);
          float _985 = _983 + _984;
          float _986 = _982 * _982;
          float _987 = _986 * _982;
          float _988 = _987 - _982;
          float _989 = _988 * (User_000.UserConstant_Z_000[10].x);
          float _990 = _981 * _981;
          float _991 = _990 * _981;
          float _992 = _991 - _981;
          float _993 = _992 * (User_000.UserConstant_Z_000[10].y);
          float _994 = _989 + _993;
          float _995 = _979 * _979;
          float _996 = _995 * 0.1666666716337204f;
          float _997 = _996 * _994;
          float _998 = _985 + _997;
          _1064 = _998;
        } else {
          bool _1000 = !(_733 <= (User_000.UserConstant_Z_000[9].x));
          if (!_1000) {
            float _1002 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _1003 = max(9.999999974752427e-07f, _1002);
            float _1004 = _733 - (User_000.UserConstant_Z_000[4].z);
            float _1005 = _1004 / _1003;
            float _1006 = 1.0f - _1005;
            float _1007 = _1006 * (User_000.UserConstant_Z_000[4].w);
            float _1008 = _1005 * (User_000.UserConstant_Z_000[9].y);
            float _1009 = _1007 + _1008;
            float _1010 = _1006 * _1006;
            float _1011 = _1010 * _1006;
            float _1012 = _1011 - _1006;
            float _1013 = _1012 * (User_000.UserConstant_Z_000[10].y);
            float _1014 = _1005 * _1005;
            float _1015 = _1014 * _1005;
            float _1016 = _1015 - _1005;
            float _1017 = _1016 * (User_000.UserConstant_Z_000[10].z);
            float _1018 = _1013 + _1017;
            float _1019 = _1003 * _1003;
            float _1020 = _1019 * 0.1666666716337204f;
            float _1021 = _1020 * _1018;
            float _1022 = _1009 + _1021;
            _1064 = _1022;
          } else {
            bool _1024 = !(_733 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1024) {
              float _1026 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1027 = max(9.999999974752427e-07f, _1026);
              float _1028 = _733 - (User_000.UserConstant_Z_000[9].x);
              float _1029 = _1028 / _1027;
              float _1030 = 1.0f - _1029;
              float _1031 = _1030 * (User_000.UserConstant_Z_000[9].y);
              float _1032 = _1029 * (User_000.UserConstant_Z_000[9].w);
              float _1033 = _1031 + _1032;
              float _1034 = _1030 * _1030;
              float _1035 = _1034 * _1030;
              float _1036 = _1035 - _1030;
              float _1037 = _1036 * (User_000.UserConstant_Z_000[10].z);
              float _1038 = _1029 * _1029;
              float _1039 = _1038 * _1029;
              float _1040 = _1039 - _1029;
              float _1041 = _1040 * (User_000.UserConstant_Z_000[10].w);
              float _1042 = _1037 + _1041;
              float _1043 = _1027 * _1027;
              float _1044 = _1043 * 0.1666666716337204f;
              float _1045 = _1044 * _1042;
              float _1046 = _1033 + _1045;
              _1064 = _1046;
            } else {
              float _1048 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1049 = _733 - (User_000.UserConstant_Z_000[9].z);
              float _1050 = max(9.999999974752427e-07f, _1048);
              float _1051 = _1049 / _1050;
              float _1052 = 1.0f - _1051;
              float _1053 = _1052 * (User_000.UserConstant_Z_000[9].w);
              float _1054 = _1053 + _1051;
              float _1055 = _1052 * _1052;
              float _1056 = _1055 * _1052;
              float _1057 = _1056 - _1052;
              float _1058 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1059 = _1048 * _1048;
              float _1060 = _1059 * _1058;
              float _1061 = _1060 * _1057;
              float _1062 = _1054 + _1061;
              _1064 = _1062;
            }
          }
        }
      }
      float _1065 = saturate(_1064);
      _1067 = _857;
      _1068 = _961;
      _1069 = _1065;
    } else {
      _1067 = _731;
      _1068 = _732;
      _1069 = _733;
    }
    int _1070 = _735 & 2;
    bool _1071 = (_1070 == 0);
    if (!_1071) {
      float _1073 = sqrt(_1067);
      float _1074 = sqrt(_1068);
      float _1075 = sqrt(_1069);
      float _1076 = dot(float3(_1073, _1074, _1075), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1077 = 1.0f - _1076;
      float _1078 = saturate(_1077);
      _1080 = _1078;
    } else {
      _1080 = 1.0f;
    }
    int _1081 = _735 & 8;
    bool _1082 = (_1081 == 0);
    if (_1082) {
      int _1084 = _735 & 4;
      bool _1085 = (_1084 == 0);
      if (!_1085) {
        int _1087 = _735 & 16;
        bool _1088 = (_1087 == 0);
        if (!_1088) {
          float _1092 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1093 = _1092 + 0.5f;
          bool _1094 = (_1093 < 0.5f);
          float _1095 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1096 = select(_1094, (User_000.UserConstant_Z_000[5].x), _1095);
          bool _1097 = (_1068 < _1069);
          float _1098 = select(_1097, _1069, _1068);
          float _1099 = select(_1097, _1068, _1069);
          bool _1100 = (_1067 < _1098);
          float _1101 = select(_1100, _1098, _1067);
          float _1102 = select(_1100, _1067, _1098);
          float _1103 = min(_1102, _1099);
          float _1104 = _1101 - _1103;
          float _1105 = _1101 + 1.000000013351432e-10f;
          float _1106 = _1104 / _1105;
          float _1108 = _1106 - (User_000.UserConstant_Z_000[5].y);
          float _1109 = saturate(_1108);
          float _1110 = max(_1109, 9.999999974752427e-07f);
          float _1111 = log2(_1110);
          float _1112 = _1111 * _1096;
          float _1113 = exp2(_1112);
          float _1114 = 2.0f - _1113;
          float _1116 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1117 = saturate(_1116);
          float _1118 = max(_1117, _1114);
          float _1119 = dot(float3(_1067, _1068, _1069), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1120 = _1067 - _1119;
          float _1121 = _1068 - _1119;
          float _1122 = _1069 - _1119;
          float _1123 = _1120 * _1118;
          float _1124 = _1121 * _1118;
          float _1125 = _1122 * _1118;
          float _1126 = _1119 - _1067;
          float _1127 = _1126 + _1123;
          float _1128 = _1119 - _1068;
          float _1129 = _1128 + _1124;
          float _1130 = _1119 - _1069;
          float _1131 = _1130 + _1125;
          float _1132 = _1127 * _1080;
          float _1133 = _1129 * _1080;
          float _1134 = _1131 * _1080;
          float _1135 = _1132 + _1067;
          float _1136 = _1133 + _1068;
          float _1137 = _1134 + _1069;
          _1254 = _1135;
          _1255 = _1136;
          _1256 = _1137;
        } else {
          bool _1139 = (_1080 == 0.0f);
          if (!_1139) {
            float _1143 = abs(User_000.UserConstant_Z_000[5].x);
            float _1144 = saturate(_1143);
            uint4 _1146 = 0u; t15.GetDimensions(0u, _1146.x, _1146.y, _1146.w);
            float _1149 = float((uint)_1146.y);
            int _1150 = _735 & 32;
            bool _1151 = (_1150 == 0);
            float _1152 = _1149 + -1.0f;
            if (!_1151) {
              float _1154 = 1.0f / _1152;
              uint _1155 = uint(SV_Position.x);
              uint _1156 = uint(SV_Position.y);
              int _1157 = _1155 & 63;
              int _1158 = _1156 & 63;
              float4 _1160 = t6.Load(int4(_1157, _1158, 0, 0));
              float _1163 = _1160.x + -0.5f;
              float _1164 = _1067 * 13.999999046325684f;
              float _1165 = _1068 * 13.999999046325684f;
              float _1166 = _1069 * 13.999999046325684f;
              float _1167 = saturate(_1164);
              float _1168 = saturate(_1165);
              float _1169 = saturate(_1166);
              float _1170 = _1067 + -0.9285714030265808f;
              float _1171 = _1068 + -0.9285714030265808f;
              float _1172 = _1069 + -0.9285714030265808f;
              float _1173 = _1170 * 13.999999046325684f;
              float _1174 = _1171 * 13.999999046325684f;
              float _1175 = _1172 * 13.999999046325684f;
              float _1176 = saturate(_1173);
              float _1177 = saturate(_1174);
              float _1178 = saturate(_1175);
              float _1179 = 1.0f - _1176;
              float _1180 = 1.0f - _1177;
              float _1181 = 1.0f - _1178;
              float _1182 = min(_1167, _1179);
              float _1183 = min(_1168, _1180);
              float _1184 = min(_1169, _1181);
              float _1185 = _1160.y + -0.5f;
              float _1186 = _1182 * _1185;
              float _1187 = _1183 * _1185;
              float _1188 = _1184 * _1185;
              float _1189 = _1186 + _1163;
              float _1190 = _1187 + _1163;
              float _1191 = _1188 + _1163;
              float _1192 = _1189 * _1154;
              float _1193 = _1190 * _1154;
              float _1194 = _1191 * _1154;
              float _1195 = _1192 + _1067;
              float _1196 = _1193 + _1068;
              float _1197 = _1194 + _1069;
              float _1198 = saturate(_1195);
              float _1199 = saturate(_1196);
              float _1200 = saturate(_1197);
              float _1201 = saturate(_1198);
              float _1202 = saturate(_1199);
              float _1203 = saturate(_1200);
              _1205 = _1201;
              _1206 = _1202;
              _1207 = _1203;
            } else {
              _1205 = _1067;
              _1206 = _1068;
              _1207 = _1069;
            }
            float _1208 = float((uint)_1146.x);
            float _1209 = _1152 / _1208;
            float _1210 = _1209 * _1205;
            float _1211 = 0.5f / _1208;
            float _1212 = _1210 + _1211;
            float _1213 = _1152 / _1149;
            float _1214 = _1213 * _1206;
            float _1215 = 0.5f / _1149;
            float _1216 = _1214 + _1215;
            float _1217 = _1207 * _1152;
            float _1218 = floor(_1217);
            float _1219 = frac(_1217);
            float _1220 = _1218 / _1149;
            float _1221 = _1220 + _1212;
            float _1222 = _1218 + 1.0f;
            float _1223 = _1222 / _1149;
            float _1224 = _1223 + _1212;
            float4 _1226 = t15.Sample(s0, float2(_1221, _1216));
            float4 _1230 = t15.Sample(s0, float2(_1224, _1216));
            float _1234 = _1230.x - _1226.x;
            float _1235 = _1230.y - _1226.y;
            float _1236 = _1230.z - _1226.z;
            float _1237 = _1234 * _1219;
            float _1238 = _1235 * _1219;
            float _1239 = _1236 * _1219;
            float _1240 = _1144 * _1080;
            float _1241 = _1226.x - _1067;
            float _1242 = _1241 + _1237;
            float _1243 = _1226.y - _1068;
            float _1244 = _1243 + _1238;
            float _1245 = _1226.z - _1069;
            float _1246 = _1245 + _1239;
            float _1247 = _1242 * _1240;
            float _1248 = _1244 * _1240;
            float _1249 = _1246 * _1240;
            float _1250 = _1247 + _1067;
            float _1251 = _1248 + _1068;
            float _1252 = _1249 + _1069;
            _1254 = _1250;
            _1255 = _1251;
            _1256 = _1252;
          } else {
            _1254 = _1067;
            _1255 = _1068;
            _1256 = _1069;
          }
        }
      } else {
        _1254 = _1067;
        _1255 = _1068;
        _1256 = _1069;
      }
    } else {
      _1254 = _1080;
      _1255 = _1080;
      _1256 = _1080;
    }
    float _1257 = _1254 * 13.450128555297852f;
    float _1258 = _1255 * 13.450128555297852f;
    float _1259 = _1256 * 13.450128555297852f;
    float _1260 = exp2(_1257);
    float _1261 = exp2(_1258);
    float _1262 = exp2(_1259);
    float _1263 = _1260 + -1.0f;
    float _1264 = _1261 + -1.0f;
    float _1265 = _1262 + -1.0f;
    float _1266 = _1263 * _713;
    float _1267 = _1264 * _713;
    float _1268 = _1265 * _713;
    _1270 = _1266;
    _1271 = _1267;
    _1272 = _1268;
  } else {
    _1270 = _714;
    _1271 = _715;
    _1272 = _716;
  }
  float _1277 = (User_000.UserConstant_Z_000[8].x) * _1270;
  float _1278 = (User_000.UserConstant_Z_000[8].y) * _1271;
  float _1279 = (User_000.UserConstant_Z_000[8].z) * _1272;
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3(_1277, _1278, _1279),
      SV_Position.xy);
  float _1284 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _1285 = _1284 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _1286 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _1287 = _1286 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _1290 = _1285 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _1291 = _1287 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _1294 = t9.Sample(s9, float2(_1290, _1291));
  float _1298 = dot(float3(_1277, _1278, _1279), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _1301 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _1304 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _1305 = select(_1301, _1304, 0);
  float _1306 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _1307 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _1308 = uint(_1306);
  uint _1309 = uint(_1307);
  int _1310 = _1308 & 63;
  int _1311 = _1309 & 63;
  float4 _1313 = t6.Load(int4(_1310, _1311, _1305, 0));
  bool _1315 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_1315) {
    float _1317 = _1306 * 0.015625f;
    float _1318 = _1307 * 0.015625f;
    float _1319 = float((uint)_1304);
    float _1320 = select(_1301, _1319, 0.0f);
    float4 _1322 = t6.SampleLevel(s1, float3(_1317, _1318, _1320), 0.0f);
    float _1324 = _1313.y - _1322.y;
    float _1325 = _1324 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _1326 = _1325 + _1322.y;
    _1328 = _1326;
  } else {
    _1328 = _1313.y;
  }
  float _1329 = _1294.x * -2.0f;
  float _1330 = _1329 * _1328;
  float _1331 = _1328 * 2.0f;
  float _1332 = _1331 * _1294.y;
  float _1333 = _1331 * _1294.z;
  float _1334 = _1330 + _1294.x;
  float _1335 = _1332 - _1294.y;
  float _1336 = _1333 - _1294.z;
  float _1337 = _1334 * _1294.x;
  float _1338 = _1335 * _1294.y;
  float _1339 = _1336 * _1294.z;
  float _1340 = _1298 + 1.0f;
  float _1341 = _1298 / _1340;
  float _1342 = _1341 + -9.999999747378752e-05f;
  float _1343 = _1342 * 1111.111083984375f;
  float _1344 = saturate(_1343);
  float _1345 = _1344 * 2.0f;
  float _1346 = 3.0f - _1345;
  float _1347 = _1344 * _1344;
  float _1348 = _1347 * _1346;
  bool _1350 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _1351 = float((bool)_1350);
  float _1352 = dot(float3(_1337, _1338, _1339), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1353 = _1352 - _1337;
  float _1354 = _1352 - _1338;
  float _1355 = _1352 - _1339;
  float _1356 = _1353 * _1351;
  float _1357 = _1354 * _1351;
  float _1358 = _1355 * _1351;
  float _1359 = _1356 + _1337;
  float _1360 = _1357 + _1338;
  float _1361 = _1358 + _1339;
  float _1365 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1366 = _1365 * _1341;
  float _1367 = _1366 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1368 = _1348 * _1367;
  float _1369 = _1368 * _1359;
  float _1370 = _1368 * _1360;
  float _1371 = _1368 * _1361;
  float _1372 = _1369 + _1277;
  float _1373 = _1370 + _1278;
  float _1374 = _1371 + _1279;
  float _1375 = max(0.0f, _1372);
  float _1376 = max(0.0f, _1373);
  float _1377 = max(0.0f, _1374);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_1375, _1376, _1377),
      apt_perceptual_film_grain);
  _1375 = apt_film_grain_output.x;
  _1376 = apt_film_grain_output.y;
  _1377 = apt_film_grain_output.z;
  float _1380 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1381 = log2(_1375);
  float _1382 = _1380 * _1381;
  float _1383 = exp2(_1382);
  float _1384 = _1383 + -1.0f;
  float _1385 = _1375 + -1.0f;
  float _1386 = _1384 / _1385;
  bool _1387 = !(_1375 == 1.0f);
  float _1388 = _1386 + -1.0f;
  float _1389 = _1388 / _1386;
  float _1390 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1391 = _1390 / _1380;
  float _1392 = select(_1387, _1389, _1391);
  float _1393 = log2(_1376);
  float _1394 = _1393 * _1380;
  float _1395 = exp2(_1394);
  float _1396 = _1395 + -1.0f;
  float _1397 = _1376 + -1.0f;
  float _1398 = _1396 / _1397;
  bool _1399 = !(_1376 == 1.0f);
  float _1400 = _1398 + -1.0f;
  float _1401 = _1400 / _1398;
  float _1402 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1403 = _1402 / _1380;
  float _1404 = select(_1399, _1401, _1403);
  float _1405 = log2(_1377);
  float _1406 = _1405 * _1380;
  float _1407 = exp2(_1406);
  float _1408 = _1407 + -1.0f;
  float _1409 = _1377 + -1.0f;
  float _1410 = _1408 / _1409;
  bool _1411 = !(_1377 == 1.0f);
  float _1412 = _1410 + -1.0f;
  float _1413 = _1412 / _1410;
  float _1414 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1415 = _1414 / _1380;
  float _1416 = select(_1411, _1413, _1415);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1375, _1376, _1377),
      float3(_1392, _1404, _1416),
      true);
  float _1417 = apt_post_process_output.x;
  float _1418 = apt_post_process_output.y;
  float _1419 = apt_post_process_output.z;
  float _1420 = log2(_1417);
  float _1421 = log2(_1418);
  float _1422 = log2(_1419);
  float _1423 = _1420 * 0.4166666567325592f;
  float _1424 = _1421 * 0.4166666567325592f;
  float _1425 = _1422 * 0.4166666567325592f;
  float _1426 = exp2(_1423);
  float _1427 = exp2(_1424);
  float _1428 = exp2(_1425);
  float _1429 = _1426 * 1.0549999475479126f;
  float _1430 = _1427 * 1.0549999475479126f;
  float _1431 = _1428 * 1.0549999475479126f;
  float _1432 = _1429 + -0.054999999701976776f;
  float _1433 = _1430 + -0.054999999701976776f;
  float _1434 = _1431 + -0.054999999701976776f;
  float _1435 = _1417 * 12.920000076293945f;
  float _1436 = _1418 * 12.920000076293945f;
  float _1437 = _1419 * 12.920000076293945f;
  bool _1438 = (_1417 <= 0.0031308000907301903f);
  bool _1439 = (_1418 <= 0.0031308000907301903f);
  bool _1440 = (_1419 <= 0.0031308000907301903f);
  float _1441 = select(_1438, _1435, _1432);
  float _1442 = select(_1439, _1436, _1433);
  float _1443 = select(_1440, _1437, _1434);
  uint _1444 = uint(SV_Position.x);
  uint _1445 = uint(SV_Position.y);
  int _1446 = _1444 & 63;
  int _1447 = _1445 & 63;
  float4 _1449 = t1.Load(int4(_1446, _1447, _1304, 0));
  float _1451 = _1449.x + -0.5f;
  float _1452 = _1451 * 0.003921568859368563f;
  float _1453 = _1452 + _1441;
  float _1454 = _1452 + _1442;
  float _1455 = _1452 + _1443;
  float _1456 = saturate(_1453);
  float _1457 = saturate(_1454);
  float _1458 = saturate(_1455);
  SV_Target.x = _1456;
  SV_Target.y = _1457;
  SV_Target.z = _1458;
  SV_Target.w = _138.w;
  return SV_Target;
}
