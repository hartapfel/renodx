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
  int _146 = asint((User_000.UserConstant_Z_000[7].z));
  bool _147 = ((int)_146 > (int)0);
  float _176;
  float _260;
  float _297;
  float _493;
  float _532;
  float _533;
  float _534;
  float _573;
  float _574;
  float _575;
  float _813;
  float _917;
  float _1021;
  float _1024;
  float _1025;
  float _1026;
  float _1037;
  float _1162;
  float _1163;
  float _1164;
  float _1211;
  float _1212;
  float _1213;
  float _1227;
  float _1228;
  float _1229;
  float _1285;
  [branch]
  if (_147) {
    bool _152 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_152) {
      float _154 = _40.x + TEXCOORD.x;
      float _155 = _50 + TEXCOORD.y;
      float4 _158 = t2.SampleLevel(s2, float2(_154, _155), 0.0f);
      bool _162 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_162) {
        float4 _165 = t7.Load(int3(0, 0, 0));
        float _170 = _165.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _171 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _170;
        _176 = _171;
      } else {
        _176 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _180 = _158.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _181 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _180;
      float _183 = _176 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _184 = _183 + _176;
      float _185 = _176 - _183;
      float _186 = max(_181, _185);
      float _187 = min(_186, _184);
      float _190 = _181 - _187;
      float _191 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _190;
      float _193 = _187 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _194 = _193 * _181;
      float _195 = _191 / _194;
      float _196 = min(_195, 0.0f);
      float _198 = _183 + 1.0f;
      float _199 = 1.0f / _198;
      float _200 = _196 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _201 = max(0.0f, _195);
      float _204 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _201;
      float _205 = _204 + _200;
      float _206 = _205 * _199;
      float _207 = max(_206, -1.0f);
      float _208 = min(_207, 1.0f);
      float _209 = max(_208, -0.30000001192092896f);
      float _210 = min(_209, 1.0f);
      float _212 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _213 = _210 * _212;
      float _214 = _154 + -0.5f;
      float _215 = _155 + -0.5f;
      float _216 = _214 * _214;
      float _217 = _215 * _215;
      float _218 = _217 + _216;
      float _219 = sqrt(_218);
      float _220 = log2(_219);
      float _221 = _220 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _222 = exp2(_221);
      float _223 = _222 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _224 = dot(float2(_214, _215), float2(_214, _215));
      float _225 = rsqrt(_224);
      float _226 = _225 * _214;
      float _227 = _225 * _215;
      float _228 = abs(_213);
      float _232 = _223 * _228;
      float _233 = -0.0f - _232;
      float _234 = (User_000.UserConstant_Z_000[2].x) * _226;
      float _235 = _234 * _233;
      float _236 = (User_000.UserConstant_Z_000[2].y) * _227;
      float _237 = _236 * _233;
      float _238 = _228 * _223;
      float _239 = _234 * _238;
      float _240 = _236 * _238;
      float _241 = _239 + _154;
      float _242 = _240 + _155;
      float _243 = _235 + _126;
      float _244 = _237 + _122;
      float4 _245 = t0.SampleLevel(s0, float2(_243, _244), _131);
      float4 _247 = t0.SampleLevel(s0, float2(_241, _242), _131);
      float4 _249 = t2.SampleLevel(s2, float2(_243, _244), 0.0f);
      if (_162) {
        float4 _253 = t7.Load(int3(0, 0, 0));
        float _255 = _253.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _256 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _255;
        _260 = _256;
      } else {
        _260 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _261 = _249.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _262 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _261;
      float _263 = _260 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _264 = _263 + _260;
      float _265 = _260 - _263;
      float _266 = max(_262, _265);
      float _267 = min(_266, _264);
      float _268 = _262 - _267;
      float _269 = _268 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _270 = _267 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _271 = _270 * _262;
      float _272 = _269 / _271;
      float _273 = min(_272, 0.0f);
      float _274 = _263 + 1.0f;
      float _275 = 1.0f / _274;
      float _276 = _273 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _277 = max(0.0f, _272);
      float _278 = _277 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _279 = _278 + _276;
      float _280 = _279 * _275;
      float _281 = max(_280, -1.0f);
      float _282 = min(_281, 1.0f);
      float _283 = max(_282, -0.30000001192092896f);
      float _284 = min(_283, 1.0f);
      float _285 = _284 * _212;
      float4 _286 = t2.SampleLevel(s2, float2(_241, _242), 0.0f);
      if (_162) {
        float4 _290 = t7.Load(int3(0, 0, 0));
        float _292 = _290.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _293 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _292;
        _297 = _293;
      } else {
        _297 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _298 = _286.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _299 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _298;
      float _300 = _297 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _301 = _300 + _297;
      float _302 = _297 - _300;
      float _303 = max(_299, _302);
      float _304 = min(_303, _301);
      float _305 = _299 - _304;
      float _306 = _305 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _307 = _304 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _308 = _307 * _299;
      float _309 = _306 / _308;
      float _310 = min(_309, 0.0f);
      float _311 = _300 + 1.0f;
      float _312 = 1.0f / _311;
      float _313 = _310 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _314 = max(0.0f, _309);
      float _315 = _314 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _316 = _315 + _313;
      float _317 = _316 * _312;
      float _318 = max(_317, -1.0f);
      float _319 = min(_318, 1.0f);
      float _320 = max(_319, -0.30000001192092896f);
      float _321 = min(_320, 1.0f);
      float _322 = _321 * _212;
      float _323 = abs(_285);
      float _324 = _323 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _325 = ceil(_324);
      float _326 = saturate(_325);
      float _327 = _245.x - _141;
      float _328 = _326 * _327;
      float _329 = _328 + _141;
      float _330 = abs(_322);
      float _331 = _330 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _332 = ceil(_331);
      float _333 = saturate(_332);
      float _334 = _247.z - _143;
      float _335 = _333 * _334;
      float _336 = _335 + _143;
      _532 = _329;
      _533 = _142;
      _534 = _336;
    } else {
      _532 = _141;
      _533 = _142;
      _534 = _143;
    }
  } else {
    int _339 = asint((User_000.UserConstant_Z_000[7].y));
    bool _340 = ((int)_339 > (int)0);
    if (_340) {
      float _342 = _40.x + TEXCOORD.x;
      float _343 = _50 + TEXCOORD.y;
      float4 _346 = t4.Sample(s4, float2(_342, _343));
      float4 _353 = t5.Sample(s5, float2(_342, _343));
      float _357 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _353.x;
      float _361 = _357 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _362 = _357 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _363 = _361 + _342;
      float _364 = _362 + _343;
      float4 _365 = t4.Sample(s4, float2(_363, _364));
      float4 _367 = t5.Sample(s5, float2(_363, _364));
      float _369 = _367.x * (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _370 = abs(_369);
      float _372 = _370 / (PostProcess_000.PostProcessConstant_Z_000[7].w);
      float _373 = _365.z - _346.z;
      float _374 = _372 * _373;
      float _375 = _346.x - _141;
      float _376 = _346.y - _142;
      float _377 = _346.z - _143;
      float _378 = _377 + _374;
      float _379 = _375 * _346.w;
      float _380 = _376 * _346.w;
      float _381 = _378 * _346.w;
      float _382 = _379 + _141;
      float _383 = _380 + _142;
      float _384 = _381 + _143;
      _532 = _382;
      _533 = _383;
      _534 = _384;
    } else {
      int _387 = asint((User_000.UserConstant_Z_000[7].x));
      bool _388 = ((int)_387 > (int)0);
      [branch]
      if (_388) {
        float4 _392 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _394 = abs(_392.x);
        _493 = _394;
      } else {
        float4 _398 = t2.SampleLevel(s2, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _400 = TEXCOORD.x * 2.0f;
        float _401 = TEXCOORD.y * 2.0f;
        float _402 = _400 + -1.0f;
        float _403 = _401 + -1.0f;
        float _424 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _402;
        float _425 = mad(_403, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _424);
        float _426 = mad(_398.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _425);
        float _427 = _426 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _428 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _402;
        float _429 = mad(_403, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _428);
        float _430 = mad(_398.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _429);
        float _431 = _430 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _432 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _402;
        float _433 = mad(_403, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _432);
        float _434 = mad(_398.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _433);
        float _435 = _434 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _436 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _402;
        float _437 = mad(_403, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _436);
        float _438 = mad(_398.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _437);
        float _439 = _438 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
        float _440 = _427 / _439;
        float _441 = _431 / _439;
        float _442 = _435 / _439;
        float _443 = _440 * _440;
        float _444 = _441 * _441;
        float _445 = _444 + _443;
        float _446 = _442 * _442;
        float _447 = _445 + _446;
        float _448 = sqrt(_447);
        float4 _451 = t5.Sample(s5, float2(TEXCOORD.x, TEXCOORD.y));
        float4 _453 = t7.Load(int3(0, 0, 0));
        float _458 = _453.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _459 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _458;
        float _462 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * _459;
        float _463 = _462 + _459;
        float _464 = _459 - _462;
        float _465 = max(_448, _464);
        float _466 = min(_465, _463);
        float _469 = _448 - _466;
        float _470 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _469;
        float _472 = _466 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _473 = _472 * _448;
        float _474 = _470 / _473;
        float _475 = min(_474, 0.0f);
        float _478 = _462 + 1.0f;
        float _479 = 1.0f / _478;
        float _480 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _475;
        float _481 = max(0.0f, _474);
        float _484 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _481;
        float _485 = _484 + _480;
        float _486 = _485 * _479;
        float _487 = min(_451.x, _486);
        float _488 = abs(_487);
        float _489 = abs(_486);
        float _490 = max(_488, _489);
        float _491 = saturate(_490);
        _493 = _491;
      }
      float _496 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _493;
      float4 _499 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _506 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _496;
      float _507 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _496;
      float _508 = _506 + TEXCOORD.x;
      float _509 = _507 + TEXCOORD.y;
      float4 _510 = t4.Sample(s4, float2(_508, _509));
      float4 _514 = t5.Sample(s5, float2(_508, _509));
      float _516 = abs(_514.x);
      float _517 = _510.z - _499.z;
      float _518 = _516 * _517;
      float _519 = _496 + -1.0f;
      float _520 = saturate(_519);
      float _521 = _499.x - _141;
      float _522 = _499.y - _142;
      float _523 = _499.z - _143;
      float _524 = _523 + _518;
      float _525 = _520 * _521;
      float _526 = _520 * _522;
      float _527 = _524 * _520;
      float _528 = _525 + _141;
      float _529 = _526 + _142;
      float _530 = _527 + _143;
      _532 = _528;
      _533 = _529;
      _534 = _530;
    }
  }
  float4 _536 = t12.SampleLevel(s0, float2(_60, _61), 0.0f);
  float4 _542 = t8.Sample(s8, float2(_62, _63));
  bool _548 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
  float _552 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _542.x;
  float _553 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _542.y;
  float _554 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _542.z;
  float _555 = _552 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _556 = _553 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _557 = _554 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  if (!_548) {
    float _559 = _555 * _536.x;
    float _560 = _556 * _536.y;
    float _561 = _557 * _536.z;
    _573 = _559;
    _574 = _560;
    _575 = _561;
  } else {
    float _563 = saturate(_555);
    float _564 = saturate(_556);
    float _565 = saturate(_557);
    float _566 = _536.x - _532;
    float _567 = _536.y - _533;
    float _568 = _536.z - _534;
    float _569 = _563 * _566;
    float _570 = _564 * _567;
    float _571 = _565 * _568;
    _573 = _569;
    _574 = _570;
    _575 = _571;
  }
  float _576 = _573 + _532;
  float _577 = _574 + _533;
  float _578 = _575 + _534;
  float4 _582 = t17.Load(int3(0, 0, 0));
  float _588 = _582.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _589 = _588 * _576;
  float _590 = _589 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _591 = _588 * _577;
  float _592 = _591 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _593 = _588 * _578;
  float _594 = _593 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _599 = _60 * 2.0f;
  float _600 = _61 * 2.0f;
  float _601 = _599 + -1.0f;
  float _602 = _600 + -1.0f;
  float _605 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _602;
  float _606 = _601 * _601;
  float _607 = _605 * _605;
  float _608 = _607 + _606;
  float _609 = sqrt(_608);
  float _611 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _609;
  float _613 = _611 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _614 = saturate(_613);
  float _616 = log2(_614);
  float _617 = _616 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _618 = exp2(_617);
  float _619 = _590 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _620 = _592 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _621 = _594 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _622 = _619 - _590;
  float _623 = _620 - _592;
  float _624 = _621 - _594;
  float _625 = _618 * _622;
  float _626 = _618 * _623;
  float _627 = _618 * _624;
  float _628 = _625 + _590;
  float _629 = _626 + _592;
  float _630 = _627 + _594;
  float _633 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _634 = _633 * _628;
  float _635 = _633 * _629;
  float _636 = _633 * _630;
  float _637 = _634 + 1.0f;
  float _638 = _635 + 1.0f;
  float _639 = _636 + 1.0f;
  float _640 = log2(_637);
  float _641 = log2(_638);
  float _642 = log2(_639);
  float _645 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _646 = _645 * _640;
  float _647 = _645 * _641;
  float _648 = _645 * _642;
  float _650 = _646 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _651 = _647 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _652 = _648 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _655 = t3.Sample(s3, float3(_650, _651, _652));
  float _661 = _655.x * 13.450128555297852f;
  float _662 = _655.y * 13.450128555297852f;
  float _663 = _655.z * 13.450128555297852f;
  float _664 = exp2(_661);
  float _665 = exp2(_662);
  float _666 = exp2(_663);
  float _667 = _664 + -1.0f;
  float _668 = _665 + -1.0f;
  float _669 = _666 + -1.0f;
  float _670 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _671 = _670 * _667;
  float _672 = _670 * _668;
  float _673 = _670 * _669;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_634 * _670, _635 * _670, _636 * _670),
      float3(_671, _672, _673),
      1.f.xxx);
  _671 = apt_scaled_lut_output.x;
  _672 = apt_scaled_lut_output.y;
  _673 = apt_scaled_lut_output.z;
  bool _676 = ((User_000.UserConstant_Z_000[3].x) > 0.0f);
  if (_676) {
    float _678 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _679 = _671 * _678;
    float _680 = _672 * _678;
    float _681 = _673 * _678;
    float _682 = _679 + 1.0f;
    float _683 = _680 + 1.0f;
    float _684 = _681 + 1.0f;
    float _685 = log2(_682);
    float _686 = log2(_683);
    float _687 = log2(_684);
    float _688 = _685 * 0.07434873282909393f;
    float _689 = _686 * 0.07434873282909393f;
    float _690 = _687 * 0.07434873282909393f;
    int _692 = asint((User_000.UserConstant_Z_000[3].y));
    int _693 = _692 & 1;
    bool _694 = (_693 == 0);
    if (!_694) {
      bool _711 = !(_688 <= (User_000.UserConstant_Z_000[4].x));
      if (!_711) {
        float _713 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _714 = _688 / _713;
        float _715 = _714 * (User_000.UserConstant_Z_000[4].y);
        float _716 = _714 * _714;
        float _717 = _716 * _714;
        float _718 = _717 - _714;
        float _719 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _720 = _713 * _713;
        float _721 = _720 * _719;
        float _722 = _721 * _718;
        float _723 = _722 + _715;
        _813 = _723;
      } else {
        bool _725 = !(_688 <= (User_000.UserConstant_Z_000[4].z));
        if (!_725) {
          float _727 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _728 = max(9.999999974752427e-07f, _727);
          float _729 = _688 - (User_000.UserConstant_Z_000[4].x);
          float _730 = _729 / _728;
          float _731 = 1.0f - _730;
          float _732 = _731 * (User_000.UserConstant_Z_000[4].y);
          float _733 = _730 * (User_000.UserConstant_Z_000[4].w);
          float _734 = _732 + _733;
          float _735 = _731 * _731;
          float _736 = _735 * _731;
          float _737 = _736 - _731;
          float _738 = _737 * (User_000.UserConstant_Z_000[10].x);
          float _739 = _730 * _730;
          float _740 = _739 * _730;
          float _741 = _740 - _730;
          float _742 = _741 * (User_000.UserConstant_Z_000[10].y);
          float _743 = _738 + _742;
          float _744 = _728 * _728;
          float _745 = _744 * 0.1666666716337204f;
          float _746 = _745 * _743;
          float _747 = _734 + _746;
          _813 = _747;
        } else {
          bool _749 = !(_688 <= (User_000.UserConstant_Z_000[9].x));
          if (!_749) {
            float _751 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _752 = max(9.999999974752427e-07f, _751);
            float _753 = _688 - (User_000.UserConstant_Z_000[4].z);
            float _754 = _753 / _752;
            float _755 = 1.0f - _754;
            float _756 = _755 * (User_000.UserConstant_Z_000[4].w);
            float _757 = _754 * (User_000.UserConstant_Z_000[9].y);
            float _758 = _756 + _757;
            float _759 = _755 * _755;
            float _760 = _759 * _755;
            float _761 = _760 - _755;
            float _762 = _761 * (User_000.UserConstant_Z_000[10].y);
            float _763 = _754 * _754;
            float _764 = _763 * _754;
            float _765 = _764 - _754;
            float _766 = _765 * (User_000.UserConstant_Z_000[10].z);
            float _767 = _762 + _766;
            float _768 = _752 * _752;
            float _769 = _768 * 0.1666666716337204f;
            float _770 = _769 * _767;
            float _771 = _758 + _770;
            _813 = _771;
          } else {
            bool _773 = !(_688 <= (User_000.UserConstant_Z_000[9].z));
            if (!_773) {
              float _775 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _776 = max(9.999999974752427e-07f, _775);
              float _777 = _688 - (User_000.UserConstant_Z_000[9].x);
              float _778 = _777 / _776;
              float _779 = 1.0f - _778;
              float _780 = _779 * (User_000.UserConstant_Z_000[9].y);
              float _781 = _778 * (User_000.UserConstant_Z_000[9].w);
              float _782 = _780 + _781;
              float _783 = _779 * _779;
              float _784 = _783 * _779;
              float _785 = _784 - _779;
              float _786 = _785 * (User_000.UserConstant_Z_000[10].z);
              float _787 = _778 * _778;
              float _788 = _787 * _778;
              float _789 = _788 - _778;
              float _790 = _789 * (User_000.UserConstant_Z_000[10].w);
              float _791 = _786 + _790;
              float _792 = _776 * _776;
              float _793 = _792 * 0.1666666716337204f;
              float _794 = _793 * _791;
              float _795 = _782 + _794;
              _813 = _795;
            } else {
              float _797 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _798 = _688 - (User_000.UserConstant_Z_000[9].z);
              float _799 = max(9.999999974752427e-07f, _797);
              float _800 = _798 / _799;
              float _801 = 1.0f - _800;
              float _802 = _801 * (User_000.UserConstant_Z_000[9].w);
              float _803 = _802 + _800;
              float _804 = _801 * _801;
              float _805 = _804 * _801;
              float _806 = _805 - _801;
              float _807 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _808 = _797 * _797;
              float _809 = _808 * _807;
              float _810 = _809 * _806;
              float _811 = _803 + _810;
              _813 = _811;
            }
          }
        }
      }
      float _814 = saturate(_813);
      bool _815 = !(_689 <= (User_000.UserConstant_Z_000[4].x));
      if (!_815) {
        float _817 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _818 = _689 / _817;
        float _819 = _818 * (User_000.UserConstant_Z_000[4].y);
        float _820 = _818 * _818;
        float _821 = _820 * _818;
        float _822 = _821 - _818;
        float _823 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _824 = _817 * _817;
        float _825 = _824 * _823;
        float _826 = _825 * _822;
        float _827 = _826 + _819;
        _917 = _827;
      } else {
        bool _829 = !(_689 <= (User_000.UserConstant_Z_000[4].z));
        if (!_829) {
          float _831 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _832 = max(9.999999974752427e-07f, _831);
          float _833 = _689 - (User_000.UserConstant_Z_000[4].x);
          float _834 = _833 / _832;
          float _835 = 1.0f - _834;
          float _836 = _835 * (User_000.UserConstant_Z_000[4].y);
          float _837 = _834 * (User_000.UserConstant_Z_000[4].w);
          float _838 = _836 + _837;
          float _839 = _835 * _835;
          float _840 = _839 * _835;
          float _841 = _840 - _835;
          float _842 = _841 * (User_000.UserConstant_Z_000[10].x);
          float _843 = _834 * _834;
          float _844 = _843 * _834;
          float _845 = _844 - _834;
          float _846 = _845 * (User_000.UserConstant_Z_000[10].y);
          float _847 = _842 + _846;
          float _848 = _832 * _832;
          float _849 = _848 * 0.1666666716337204f;
          float _850 = _849 * _847;
          float _851 = _838 + _850;
          _917 = _851;
        } else {
          bool _853 = !(_689 <= (User_000.UserConstant_Z_000[9].x));
          if (!_853) {
            float _855 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _856 = max(9.999999974752427e-07f, _855);
            float _857 = _689 - (User_000.UserConstant_Z_000[4].z);
            float _858 = _857 / _856;
            float _859 = 1.0f - _858;
            float _860 = _859 * (User_000.UserConstant_Z_000[4].w);
            float _861 = _858 * (User_000.UserConstant_Z_000[9].y);
            float _862 = _860 + _861;
            float _863 = _859 * _859;
            float _864 = _863 * _859;
            float _865 = _864 - _859;
            float _866 = _865 * (User_000.UserConstant_Z_000[10].y);
            float _867 = _858 * _858;
            float _868 = _867 * _858;
            float _869 = _868 - _858;
            float _870 = _869 * (User_000.UserConstant_Z_000[10].z);
            float _871 = _866 + _870;
            float _872 = _856 * _856;
            float _873 = _872 * 0.1666666716337204f;
            float _874 = _873 * _871;
            float _875 = _862 + _874;
            _917 = _875;
          } else {
            bool _877 = !(_689 <= (User_000.UserConstant_Z_000[9].z));
            if (!_877) {
              float _879 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _880 = max(9.999999974752427e-07f, _879);
              float _881 = _689 - (User_000.UserConstant_Z_000[9].x);
              float _882 = _881 / _880;
              float _883 = 1.0f - _882;
              float _884 = _883 * (User_000.UserConstant_Z_000[9].y);
              float _885 = _882 * (User_000.UserConstant_Z_000[9].w);
              float _886 = _884 + _885;
              float _887 = _883 * _883;
              float _888 = _887 * _883;
              float _889 = _888 - _883;
              float _890 = _889 * (User_000.UserConstant_Z_000[10].z);
              float _891 = _882 * _882;
              float _892 = _891 * _882;
              float _893 = _892 - _882;
              float _894 = _893 * (User_000.UserConstant_Z_000[10].w);
              float _895 = _890 + _894;
              float _896 = _880 * _880;
              float _897 = _896 * 0.1666666716337204f;
              float _898 = _897 * _895;
              float _899 = _886 + _898;
              _917 = _899;
            } else {
              float _901 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _902 = _689 - (User_000.UserConstant_Z_000[9].z);
              float _903 = max(9.999999974752427e-07f, _901);
              float _904 = _902 / _903;
              float _905 = 1.0f - _904;
              float _906 = _905 * (User_000.UserConstant_Z_000[9].w);
              float _907 = _906 + _904;
              float _908 = _905 * _905;
              float _909 = _908 * _905;
              float _910 = _909 - _905;
              float _911 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _912 = _901 * _901;
              float _913 = _912 * _911;
              float _914 = _913 * _910;
              float _915 = _907 + _914;
              _917 = _915;
            }
          }
        }
      }
      float _918 = saturate(_917);
      bool _919 = !(_690 <= (User_000.UserConstant_Z_000[4].x));
      if (!_919) {
        float _921 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _922 = _690 / _921;
        float _923 = _922 * (User_000.UserConstant_Z_000[4].y);
        float _924 = _922 * _922;
        float _925 = _924 * _922;
        float _926 = _925 - _922;
        float _927 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _928 = _921 * _921;
        float _929 = _928 * _927;
        float _930 = _929 * _926;
        float _931 = _930 + _923;
        _1021 = _931;
      } else {
        bool _933 = !(_690 <= (User_000.UserConstant_Z_000[4].z));
        if (!_933) {
          float _935 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _936 = max(9.999999974752427e-07f, _935);
          float _937 = _690 - (User_000.UserConstant_Z_000[4].x);
          float _938 = _937 / _936;
          float _939 = 1.0f - _938;
          float _940 = _939 * (User_000.UserConstant_Z_000[4].y);
          float _941 = _938 * (User_000.UserConstant_Z_000[4].w);
          float _942 = _940 + _941;
          float _943 = _939 * _939;
          float _944 = _943 * _939;
          float _945 = _944 - _939;
          float _946 = _945 * (User_000.UserConstant_Z_000[10].x);
          float _947 = _938 * _938;
          float _948 = _947 * _938;
          float _949 = _948 - _938;
          float _950 = _949 * (User_000.UserConstant_Z_000[10].y);
          float _951 = _946 + _950;
          float _952 = _936 * _936;
          float _953 = _952 * 0.1666666716337204f;
          float _954 = _953 * _951;
          float _955 = _942 + _954;
          _1021 = _955;
        } else {
          bool _957 = !(_690 <= (User_000.UserConstant_Z_000[9].x));
          if (!_957) {
            float _959 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _960 = max(9.999999974752427e-07f, _959);
            float _961 = _690 - (User_000.UserConstant_Z_000[4].z);
            float _962 = _961 / _960;
            float _963 = 1.0f - _962;
            float _964 = _963 * (User_000.UserConstant_Z_000[4].w);
            float _965 = _962 * (User_000.UserConstant_Z_000[9].y);
            float _966 = _964 + _965;
            float _967 = _963 * _963;
            float _968 = _967 * _963;
            float _969 = _968 - _963;
            float _970 = _969 * (User_000.UserConstant_Z_000[10].y);
            float _971 = _962 * _962;
            float _972 = _971 * _962;
            float _973 = _972 - _962;
            float _974 = _973 * (User_000.UserConstant_Z_000[10].z);
            float _975 = _970 + _974;
            float _976 = _960 * _960;
            float _977 = _976 * 0.1666666716337204f;
            float _978 = _977 * _975;
            float _979 = _966 + _978;
            _1021 = _979;
          } else {
            bool _981 = !(_690 <= (User_000.UserConstant_Z_000[9].z));
            if (!_981) {
              float _983 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _984 = max(9.999999974752427e-07f, _983);
              float _985 = _690 - (User_000.UserConstant_Z_000[9].x);
              float _986 = _985 / _984;
              float _987 = 1.0f - _986;
              float _988 = _987 * (User_000.UserConstant_Z_000[9].y);
              float _989 = _986 * (User_000.UserConstant_Z_000[9].w);
              float _990 = _988 + _989;
              float _991 = _987 * _987;
              float _992 = _991 * _987;
              float _993 = _992 - _987;
              float _994 = _993 * (User_000.UserConstant_Z_000[10].z);
              float _995 = _986 * _986;
              float _996 = _995 * _986;
              float _997 = _996 - _986;
              float _998 = _997 * (User_000.UserConstant_Z_000[10].w);
              float _999 = _994 + _998;
              float _1000 = _984 * _984;
              float _1001 = _1000 * 0.1666666716337204f;
              float _1002 = _1001 * _999;
              float _1003 = _990 + _1002;
              _1021 = _1003;
            } else {
              float _1005 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1006 = _690 - (User_000.UserConstant_Z_000[9].z);
              float _1007 = max(9.999999974752427e-07f, _1005);
              float _1008 = _1006 / _1007;
              float _1009 = 1.0f - _1008;
              float _1010 = _1009 * (User_000.UserConstant_Z_000[9].w);
              float _1011 = _1010 + _1008;
              float _1012 = _1009 * _1009;
              float _1013 = _1012 * _1009;
              float _1014 = _1013 - _1009;
              float _1015 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1016 = _1005 * _1005;
              float _1017 = _1016 * _1015;
              float _1018 = _1017 * _1014;
              float _1019 = _1011 + _1018;
              _1021 = _1019;
            }
          }
        }
      }
      float _1022 = saturate(_1021);
      _1024 = _814;
      _1025 = _918;
      _1026 = _1022;
    } else {
      _1024 = _688;
      _1025 = _689;
      _1026 = _690;
    }
    int _1027 = _692 & 2;
    bool _1028 = (_1027 == 0);
    if (!_1028) {
      float _1030 = sqrt(_1024);
      float _1031 = sqrt(_1025);
      float _1032 = sqrt(_1026);
      float _1033 = dot(float3(_1030, _1031, _1032), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1034 = 1.0f - _1033;
      float _1035 = saturate(_1034);
      _1037 = _1035;
    } else {
      _1037 = 1.0f;
    }
    int _1038 = _692 & 8;
    bool _1039 = (_1038 == 0);
    if (_1039) {
      int _1041 = _692 & 4;
      bool _1042 = (_1041 == 0);
      if (!_1042) {
        int _1044 = _692 & 16;
        bool _1045 = (_1044 == 0);
        if (!_1045) {
          float _1049 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1050 = _1049 + 0.5f;
          bool _1051 = (_1050 < 0.5f);
          float _1052 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1053 = select(_1051, (User_000.UserConstant_Z_000[5].x), _1052);
          bool _1054 = (_1025 < _1026);
          float _1055 = select(_1054, _1026, _1025);
          float _1056 = select(_1054, _1025, _1026);
          bool _1057 = (_1024 < _1055);
          float _1058 = select(_1057, _1055, _1024);
          float _1059 = select(_1057, _1024, _1055);
          float _1060 = min(_1059, _1056);
          float _1061 = _1058 - _1060;
          float _1062 = _1058 + 1.000000013351432e-10f;
          float _1063 = _1061 / _1062;
          float _1065 = _1063 - (User_000.UserConstant_Z_000[5].y);
          float _1066 = saturate(_1065);
          float _1067 = max(_1066, 9.999999974752427e-07f);
          float _1068 = log2(_1067);
          float _1069 = _1068 * _1053;
          float _1070 = exp2(_1069);
          float _1071 = 2.0f - _1070;
          float _1073 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1074 = saturate(_1073);
          float _1075 = max(_1074, _1071);
          float _1076 = dot(float3(_1024, _1025, _1026), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1077 = _1024 - _1076;
          float _1078 = _1025 - _1076;
          float _1079 = _1026 - _1076;
          float _1080 = _1077 * _1075;
          float _1081 = _1078 * _1075;
          float _1082 = _1079 * _1075;
          float _1083 = _1076 - _1024;
          float _1084 = _1083 + _1080;
          float _1085 = _1076 - _1025;
          float _1086 = _1085 + _1081;
          float _1087 = _1076 - _1026;
          float _1088 = _1087 + _1082;
          float _1089 = _1084 * _1037;
          float _1090 = _1086 * _1037;
          float _1091 = _1088 * _1037;
          float _1092 = _1089 + _1024;
          float _1093 = _1090 + _1025;
          float _1094 = _1091 + _1026;
          _1211 = _1092;
          _1212 = _1093;
          _1213 = _1094;
        } else {
          bool _1096 = (_1037 == 0.0f);
          if (!_1096) {
            float _1100 = abs(User_000.UserConstant_Z_000[5].x);
            float _1101 = saturate(_1100);
            uint4 _1103 = 0u; t15.GetDimensions(0u, _1103.x, _1103.y, _1103.w);
            float _1106 = float((uint)_1103.y);
            int _1107 = _692 & 32;
            bool _1108 = (_1107 == 0);
            float _1109 = _1106 + -1.0f;
            if (!_1108) {
              float _1111 = 1.0f / _1109;
              uint _1112 = uint(SV_Position.x);
              uint _1113 = uint(SV_Position.y);
              int _1114 = _1112 & 63;
              int _1115 = _1113 & 63;
              float4 _1117 = t6.Load(int4(_1114, _1115, 0, 0));
              float _1120 = _1117.x + -0.5f;
              float _1121 = _1024 * 13.999999046325684f;
              float _1122 = _1025 * 13.999999046325684f;
              float _1123 = _1026 * 13.999999046325684f;
              float _1124 = saturate(_1121);
              float _1125 = saturate(_1122);
              float _1126 = saturate(_1123);
              float _1127 = _1024 + -0.9285714030265808f;
              float _1128 = _1025 + -0.9285714030265808f;
              float _1129 = _1026 + -0.9285714030265808f;
              float _1130 = _1127 * 13.999999046325684f;
              float _1131 = _1128 * 13.999999046325684f;
              float _1132 = _1129 * 13.999999046325684f;
              float _1133 = saturate(_1130);
              float _1134 = saturate(_1131);
              float _1135 = saturate(_1132);
              float _1136 = 1.0f - _1133;
              float _1137 = 1.0f - _1134;
              float _1138 = 1.0f - _1135;
              float _1139 = min(_1124, _1136);
              float _1140 = min(_1125, _1137);
              float _1141 = min(_1126, _1138);
              float _1142 = _1117.y + -0.5f;
              float _1143 = _1139 * _1142;
              float _1144 = _1140 * _1142;
              float _1145 = _1141 * _1142;
              float _1146 = _1143 + _1120;
              float _1147 = _1144 + _1120;
              float _1148 = _1145 + _1120;
              float _1149 = _1146 * _1111;
              float _1150 = _1147 * _1111;
              float _1151 = _1148 * _1111;
              float _1152 = _1149 + _1024;
              float _1153 = _1150 + _1025;
              float _1154 = _1151 + _1026;
              float _1155 = saturate(_1152);
              float _1156 = saturate(_1153);
              float _1157 = saturate(_1154);
              float _1158 = saturate(_1155);
              float _1159 = saturate(_1156);
              float _1160 = saturate(_1157);
              _1162 = _1158;
              _1163 = _1159;
              _1164 = _1160;
            } else {
              _1162 = _1024;
              _1163 = _1025;
              _1164 = _1026;
            }
            float _1165 = float((uint)_1103.x);
            float _1166 = _1109 / _1165;
            float _1167 = _1166 * _1162;
            float _1168 = 0.5f / _1165;
            float _1169 = _1167 + _1168;
            float _1170 = _1109 / _1106;
            float _1171 = _1170 * _1163;
            float _1172 = 0.5f / _1106;
            float _1173 = _1171 + _1172;
            float _1174 = _1164 * _1109;
            float _1175 = floor(_1174);
            float _1176 = frac(_1174);
            float _1177 = _1175 / _1106;
            float _1178 = _1177 + _1169;
            float _1179 = _1175 + 1.0f;
            float _1180 = _1179 / _1106;
            float _1181 = _1180 + _1169;
            float4 _1183 = t15.Sample(s0, float2(_1178, _1173));
            float4 _1187 = t15.Sample(s0, float2(_1181, _1173));
            float _1191 = _1187.x - _1183.x;
            float _1192 = _1187.y - _1183.y;
            float _1193 = _1187.z - _1183.z;
            float _1194 = _1191 * _1176;
            float _1195 = _1192 * _1176;
            float _1196 = _1193 * _1176;
            float _1197 = _1101 * _1037;
            float _1198 = _1183.x - _1024;
            float _1199 = _1198 + _1194;
            float _1200 = _1183.y - _1025;
            float _1201 = _1200 + _1195;
            float _1202 = _1183.z - _1026;
            float _1203 = _1202 + _1196;
            float _1204 = _1199 * _1197;
            float _1205 = _1201 * _1197;
            float _1206 = _1203 * _1197;
            float _1207 = _1204 + _1024;
            float _1208 = _1205 + _1025;
            float _1209 = _1206 + _1026;
            _1211 = _1207;
            _1212 = _1208;
            _1213 = _1209;
          } else {
            _1211 = _1024;
            _1212 = _1025;
            _1213 = _1026;
          }
        }
      } else {
        _1211 = _1024;
        _1212 = _1025;
        _1213 = _1026;
      }
    } else {
      _1211 = _1037;
      _1212 = _1037;
      _1213 = _1037;
    }
    float _1214 = _1211 * 13.450128555297852f;
    float _1215 = _1212 * 13.450128555297852f;
    float _1216 = _1213 * 13.450128555297852f;
    float _1217 = exp2(_1214);
    float _1218 = exp2(_1215);
    float _1219 = exp2(_1216);
    float _1220 = _1217 + -1.0f;
    float _1221 = _1218 + -1.0f;
    float _1222 = _1219 + -1.0f;
    float _1223 = _1220 * _670;
    float _1224 = _1221 * _670;
    float _1225 = _1222 * _670;
    _1227 = _1223;
    _1228 = _1224;
    _1229 = _1225;
  } else {
    _1227 = _671;
    _1228 = _672;
    _1229 = _673;
  }
  float _1234 = (User_000.UserConstant_Z_000[8].x) * _1227;
  float _1235 = (User_000.UserConstant_Z_000[8].y) * _1228;
  float _1236 = (User_000.UserConstant_Z_000[8].z) * _1229;
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3(_1234, _1235, _1236),
      SV_Position.xy);
  float _1241 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _1242 = _1241 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _1243 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _1244 = _1243 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _1247 = _1242 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _1248 = _1244 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _1251 = t9.Sample(s9, float2(_1247, _1248));
  float _1255 = dot(float3(_1234, _1235, _1236), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _1258 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _1261 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _1262 = select(_1258, _1261, 0);
  float _1263 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _1264 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _1265 = uint(_1263);
  uint _1266 = uint(_1264);
  int _1267 = _1265 & 63;
  int _1268 = _1266 & 63;
  float4 _1270 = t6.Load(int4(_1267, _1268, _1262, 0));
  bool _1272 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_1272) {
    float _1274 = _1263 * 0.015625f;
    float _1275 = _1264 * 0.015625f;
    float _1276 = float((uint)_1261);
    float _1277 = select(_1258, _1276, 0.0f);
    float4 _1279 = t6.SampleLevel(s1, float3(_1274, _1275, _1277), 0.0f);
    float _1281 = _1270.y - _1279.y;
    float _1282 = _1281 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _1283 = _1282 + _1279.y;
    _1285 = _1283;
  } else {
    _1285 = _1270.y;
  }
  float _1286 = _1251.x * -2.0f;
  float _1287 = _1286 * _1285;
  float _1288 = _1285 * 2.0f;
  float _1289 = _1288 * _1251.y;
  float _1290 = _1288 * _1251.z;
  float _1291 = _1287 + _1251.x;
  float _1292 = _1289 - _1251.y;
  float _1293 = _1290 - _1251.z;
  float _1294 = _1291 * _1251.x;
  float _1295 = _1292 * _1251.y;
  float _1296 = _1293 * _1251.z;
  float _1297 = _1255 + 1.0f;
  float _1298 = _1255 / _1297;
  float _1299 = _1298 + -9.999999747378752e-05f;
  float _1300 = _1299 * 1111.111083984375f;
  float _1301 = saturate(_1300);
  float _1302 = _1301 * 2.0f;
  float _1303 = 3.0f - _1302;
  float _1304 = _1301 * _1301;
  float _1305 = _1304 * _1303;
  bool _1307 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _1308 = float((bool)_1307);
  float _1309 = dot(float3(_1294, _1295, _1296), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1310 = _1309 - _1294;
  float _1311 = _1309 - _1295;
  float _1312 = _1309 - _1296;
  float _1313 = _1310 * _1308;
  float _1314 = _1311 * _1308;
  float _1315 = _1312 * _1308;
  float _1316 = _1313 + _1294;
  float _1317 = _1314 + _1295;
  float _1318 = _1315 + _1296;
  float _1322 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1323 = _1322 * _1298;
  float _1324 = _1323 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1325 = _1305 * _1324;
  float _1326 = _1325 * _1316;
  float _1327 = _1325 * _1317;
  float _1328 = _1325 * _1318;
  float _1329 = _1326 + _1234;
  float _1330 = _1327 + _1235;
  float _1331 = _1328 + _1236;
  float _1332 = max(0.0f, _1329);
  float _1333 = max(0.0f, _1330);
  float _1334 = max(0.0f, _1331);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_1332, _1333, _1334),
      apt_perceptual_film_grain);
  _1332 = apt_film_grain_output.x;
  _1333 = apt_film_grain_output.y;
  _1334 = apt_film_grain_output.z;
  float _1337 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1338 = log2(_1332);
  float _1339 = _1337 * _1338;
  float _1340 = exp2(_1339);
  float _1341 = _1340 + -1.0f;
  float _1342 = _1332 + -1.0f;
  float _1343 = _1341 / _1342;
  bool _1344 = !(_1332 == 1.0f);
  float _1345 = _1343 + -1.0f;
  float _1346 = _1345 / _1343;
  float _1347 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1348 = _1347 / _1337;
  float _1349 = select(_1344, _1346, _1348);
  float _1350 = log2(_1333);
  float _1351 = _1350 * _1337;
  float _1352 = exp2(_1351);
  float _1353 = _1352 + -1.0f;
  float _1354 = _1333 + -1.0f;
  float _1355 = _1353 / _1354;
  bool _1356 = !(_1333 == 1.0f);
  float _1357 = _1355 + -1.0f;
  float _1358 = _1357 / _1355;
  float _1359 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1360 = _1359 / _1337;
  float _1361 = select(_1356, _1358, _1360);
  float _1362 = log2(_1334);
  float _1363 = _1362 * _1337;
  float _1364 = exp2(_1363);
  float _1365 = _1364 + -1.0f;
  float _1366 = _1334 + -1.0f;
  float _1367 = _1365 / _1366;
  bool _1368 = !(_1334 == 1.0f);
  float _1369 = _1367 + -1.0f;
  float _1370 = _1369 / _1367;
  float _1371 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1372 = _1371 / _1337;
  float _1373 = select(_1368, _1370, _1372);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1332, _1333, _1334),
      float3(_1349, _1361, _1373),
      true);
  float _1374 = apt_post_process_output.x;
  float _1375 = apt_post_process_output.y;
  float _1376 = apt_post_process_output.z;
  float _1377 = log2(_1374);
  float _1378 = log2(_1375);
  float _1379 = log2(_1376);
  float _1380 = _1377 * 0.4166666567325592f;
  float _1381 = _1378 * 0.4166666567325592f;
  float _1382 = _1379 * 0.4166666567325592f;
  float _1383 = exp2(_1380);
  float _1384 = exp2(_1381);
  float _1385 = exp2(_1382);
  float _1386 = _1383 * 1.0549999475479126f;
  float _1387 = _1384 * 1.0549999475479126f;
  float _1388 = _1385 * 1.0549999475479126f;
  float _1389 = _1386 + -0.054999999701976776f;
  float _1390 = _1387 + -0.054999999701976776f;
  float _1391 = _1388 + -0.054999999701976776f;
  float _1392 = _1374 * 12.920000076293945f;
  float _1393 = _1375 * 12.920000076293945f;
  float _1394 = _1376 * 12.920000076293945f;
  bool _1395 = (_1374 <= 0.0031308000907301903f);
  bool _1396 = (_1375 <= 0.0031308000907301903f);
  bool _1397 = (_1376 <= 0.0031308000907301903f);
  float _1398 = select(_1395, _1392, _1389);
  float _1399 = select(_1396, _1393, _1390);
  float _1400 = select(_1397, _1394, _1391);
  uint _1401 = uint(SV_Position.x);
  uint _1402 = uint(SV_Position.y);
  int _1403 = _1401 & 63;
  int _1404 = _1402 & 63;
  float4 _1406 = t1.Load(int4(_1403, _1404, _1261, 0));
  float _1408 = _1406.x + -0.5f;
  float _1409 = _1408 * 0.003921568859368563f;
  float _1410 = _1409 + _1398;
  float _1411 = _1409 + _1399;
  float _1412 = _1409 + _1400;
  float _1413 = saturate(_1410);
  float _1414 = saturate(_1411);
  float _1415 = saturate(_1412);
  SV_Target.x = _1413;
  SV_Target.y = _1414;
  SV_Target.z = _1415;
  SV_Target.w = _138.w;
  return SV_Target;
}
