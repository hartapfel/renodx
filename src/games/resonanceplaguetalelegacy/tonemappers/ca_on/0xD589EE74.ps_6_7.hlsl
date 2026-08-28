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
  int _146 = asint((User_000.UserConstant_Z_000[7].z));
  bool _147 = ((int)_146 > (int)0);
  float _176;
  float _260;
  float _297;
  float _487;
  float _526;
  float _527;
  float _528;
  float _567;
  float _568;
  float _569;
  float _772;
  float _876;
  float _980;
  float _983;
  float _984;
  float _985;
  float _996;
  float _1121;
  float _1122;
  float _1123;
  float _1170;
  float _1171;
  float _1172;
  float _1186;
  float _1187;
  float _1188;
  float _1244;
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
      _526 = _329;
      _527 = _142;
      _528 = _336;
    } else {
      _526 = _141;
      _527 = _142;
      _528 = _143;
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
      _526 = _382;
      _527 = _383;
      _528 = _384;
    } else {
      int _387 = asint((User_000.UserConstant_Z_000[7].x));
      bool _388 = ((int)_387 > (int)0);
      [branch]
      if (_388) {
        float4 _392 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _394 = abs(_392.x);
        _487 = _394;
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
        float _457 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _458 = _457 + (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _459 = (PostProcess_000.PostProcessConstant_Z_000[5].x) - _457;
        float _460 = max(_448, _459);
        float _461 = min(_460, _458);
        float _463 = _448 - _461;
        float _464 = _463 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
        float _466 = _461 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _467 = _466 * _448;
        float _468 = _464 / _467;
        float _469 = min(_468, 0.0f);
        float _472 = _457 + 1.0f;
        float _473 = 1.0f / _472;
        float _474 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _469;
        float _475 = max(0.0f, _468);
        float _478 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _475;
        float _479 = _478 + _474;
        float _480 = _479 * _473;
        float _481 = min(_451.x, _480);
        float _482 = abs(_481);
        float _483 = abs(_480);
        float _484 = max(_482, _483);
        float _485 = saturate(_484);
        _487 = _485;
      }
      float _490 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _487;
      float4 _493 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _500 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _490;
      float _501 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _490;
      float _502 = _500 + TEXCOORD.x;
      float _503 = _501 + TEXCOORD.y;
      float4 _504 = t4.Sample(s4, float2(_502, _503));
      float4 _508 = t5.Sample(s5, float2(_502, _503));
      float _510 = abs(_508.x);
      float _511 = _504.z - _493.z;
      float _512 = _510 * _511;
      float _513 = _490 + -1.0f;
      float _514 = saturate(_513);
      float _515 = _493.x - _141;
      float _516 = _493.y - _142;
      float _517 = _493.z - _143;
      float _518 = _517 + _512;
      float _519 = _514 * _515;
      float _520 = _514 * _516;
      float _521 = _518 * _514;
      float _522 = _519 + _141;
      float _523 = _520 + _142;
      float _524 = _521 + _143;
      _526 = _522;
      _527 = _523;
      _528 = _524;
    }
  }
  float4 _530 = t12.SampleLevel(s0, float2(_60, _61), 0.0f);
  float4 _536 = t8.Sample(s8, float2(_62, _63));
  bool _542 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
  float _546 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _536.x;
  float _547 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _536.y;
  float _548 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _536.z;
  float _549 = _546 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _550 = _547 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _551 = _548 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  if (!_542) {
    float _553 = _549 * _530.x;
    float _554 = _550 * _530.y;
    float _555 = _551 * _530.z;
    _567 = _553;
    _568 = _554;
    _569 = _555;
  } else {
    float _557 = saturate(_549);
    float _558 = saturate(_550);
    float _559 = saturate(_551);
    float _560 = _530.x - _526;
    float _561 = _530.y - _527;
    float _562 = _530.z - _528;
    float _563 = _557 * _560;
    float _564 = _558 * _561;
    float _565 = _559 * _562;
    _567 = _563;
    _568 = _564;
    _569 = _565;
  }
  float _570 = _567 + _526;
  float _571 = _568 + _527;
  float _572 = _569 + _528;
  float4 _576 = t17.Load(int3(0, 0, 0));
  float _584 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _585 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _586 = _576.x * _585;
  float _587 = _586 * _570;
  float _588 = _587 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _589 = _588 * _584;
  float _590 = _586 * _571;
  float _591 = _590 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _592 = _591 * _584;
  float _593 = _586 * _572;
  float _594 = _593 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _595 = _594 * _584;
  float _596 = _589 + 1.0f;
  float _597 = _592 + 1.0f;
  float _598 = _595 + 1.0f;
  float _599 = log2(_596);
  float _600 = log2(_597);
  float _601 = log2(_598);
  float _604 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _605 = _604 * _599;
  float _606 = _604 * _600;
  float _607 = _604 * _601;
  float _609 = _605 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _610 = _606 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _611 = _607 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _614 = t3.Sample(s3, float3(_609, _610, _611));
  float _620 = _614.x * 13.450128555297852f;
  float _621 = _614.y * 13.450128555297852f;
  float _622 = _614.z * 13.450128555297852f;
  float _623 = exp2(_620);
  float _624 = exp2(_621);
  float _625 = exp2(_622);
  float _626 = _623 + -1.0f;
  float _627 = _624 + -1.0f;
  float _628 = _625 + -1.0f;
  float _629 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _630 = _629 * _626;
  float _631 = _629 * _627;
  float _632 = _629 * _628;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_589 * _629, _592 * _629, _595 * _629),
      float3(_630, _631, _632),
      1.f.xxx);
  _630 = resonance_scaled_lut_output.x;
  _631 = resonance_scaled_lut_output.y;
  _632 = resonance_scaled_lut_output.z;
  bool _635 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_635) {
    float _637 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _638 = _630 * _637;
    float _639 = _631 * _637;
    float _640 = _632 * _637;
    float _641 = _638 + 1.0f;
    float _642 = _639 + 1.0f;
    float _643 = _640 + 1.0f;
    float _644 = log2(_641);
    float _645 = log2(_642);
    float _646 = log2(_643);
    float _647 = _644 * 0.07434873282909393f;
    float _648 = _645 * 0.07434873282909393f;
    float _649 = _646 * 0.07434873282909393f;
    int _651 = asint((User_000.UserConstant_Z_000[3].y));
    int _652 = _651 & 1;
    bool _653 = (_652 == 0);
    if (!_653) {
      bool _670 = !(_647 <= (User_000.UserConstant_Z_000[4].x));
      if (!_670) {
        float _672 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _673 = _647 / _672;
        float _674 = _673 * (User_000.UserConstant_Z_000[4].y);
        float _675 = _673 * _673;
        float _676 = _675 * _673;
        float _677 = _676 - _673;
        float _678 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _679 = _672 * _672;
        float _680 = _679 * _678;
        float _681 = _680 * _677;
        float _682 = _681 + _674;
        _772 = _682;
      } else {
        bool _684 = !(_647 <= (User_000.UserConstant_Z_000[4].z));
        if (!_684) {
          float _686 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _687 = max(9.999999974752427e-07f, _686);
          float _688 = _647 - (User_000.UserConstant_Z_000[4].x);
          float _689 = _688 / _687;
          float _690 = 1.0f - _689;
          float _691 = _690 * (User_000.UserConstant_Z_000[4].y);
          float _692 = _689 * (User_000.UserConstant_Z_000[4].w);
          float _693 = _691 + _692;
          float _694 = _690 * _690;
          float _695 = _694 * _690;
          float _696 = _695 - _690;
          float _697 = _696 * (User_000.UserConstant_Z_000[10].x);
          float _698 = _689 * _689;
          float _699 = _698 * _689;
          float _700 = _699 - _689;
          float _701 = _700 * (User_000.UserConstant_Z_000[10].y);
          float _702 = _697 + _701;
          float _703 = _687 * _687;
          float _704 = _703 * 0.1666666716337204f;
          float _705 = _704 * _702;
          float _706 = _693 + _705;
          _772 = _706;
        } else {
          bool _708 = !(_647 <= (User_000.UserConstant_Z_000[9].x));
          if (!_708) {
            float _710 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _711 = max(9.999999974752427e-07f, _710);
            float _712 = _647 - (User_000.UserConstant_Z_000[4].z);
            float _713 = _712 / _711;
            float _714 = 1.0f - _713;
            float _715 = _714 * (User_000.UserConstant_Z_000[4].w);
            float _716 = _713 * (User_000.UserConstant_Z_000[9].y);
            float _717 = _715 + _716;
            float _718 = _714 * _714;
            float _719 = _718 * _714;
            float _720 = _719 - _714;
            float _721 = _720 * (User_000.UserConstant_Z_000[10].y);
            float _722 = _713 * _713;
            float _723 = _722 * _713;
            float _724 = _723 - _713;
            float _725 = _724 * (User_000.UserConstant_Z_000[10].z);
            float _726 = _721 + _725;
            float _727 = _711 * _711;
            float _728 = _727 * 0.1666666716337204f;
            float _729 = _728 * _726;
            float _730 = _717 + _729;
            _772 = _730;
          } else {
            bool _732 = !(_647 <= (User_000.UserConstant_Z_000[9].z));
            if (!_732) {
              float _734 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _735 = max(9.999999974752427e-07f, _734);
              float _736 = _647 - (User_000.UserConstant_Z_000[9].x);
              float _737 = _736 / _735;
              float _738 = 1.0f - _737;
              float _739 = _738 * (User_000.UserConstant_Z_000[9].y);
              float _740 = _737 * (User_000.UserConstant_Z_000[9].w);
              float _741 = _739 + _740;
              float _742 = _738 * _738;
              float _743 = _742 * _738;
              float _744 = _743 - _738;
              float _745 = _744 * (User_000.UserConstant_Z_000[10].z);
              float _746 = _737 * _737;
              float _747 = _746 * _737;
              float _748 = _747 - _737;
              float _749 = _748 * (User_000.UserConstant_Z_000[10].w);
              float _750 = _745 + _749;
              float _751 = _735 * _735;
              float _752 = _751 * 0.1666666716337204f;
              float _753 = _752 * _750;
              float _754 = _741 + _753;
              _772 = _754;
            } else {
              float _756 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _757 = _647 - (User_000.UserConstant_Z_000[9].z);
              float _758 = max(9.999999974752427e-07f, _756);
              float _759 = _757 / _758;
              float _760 = 1.0f - _759;
              float _761 = _760 * (User_000.UserConstant_Z_000[9].w);
              float _762 = _761 + _759;
              float _763 = _760 * _760;
              float _764 = _763 * _760;
              float _765 = _764 - _760;
              float _766 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _767 = _756 * _756;
              float _768 = _767 * _766;
              float _769 = _768 * _765;
              float _770 = _762 + _769;
              _772 = _770;
            }
          }
        }
      }
      float _773 = saturate(_772);
      bool _774 = !(_648 <= (User_000.UserConstant_Z_000[4].x));
      if (!_774) {
        float _776 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _777 = _648 / _776;
        float _778 = _777 * (User_000.UserConstant_Z_000[4].y);
        float _779 = _777 * _777;
        float _780 = _779 * _777;
        float _781 = _780 - _777;
        float _782 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _783 = _776 * _776;
        float _784 = _783 * _782;
        float _785 = _784 * _781;
        float _786 = _785 + _778;
        _876 = _786;
      } else {
        bool _788 = !(_648 <= (User_000.UserConstant_Z_000[4].z));
        if (!_788) {
          float _790 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _791 = max(9.999999974752427e-07f, _790);
          float _792 = _648 - (User_000.UserConstant_Z_000[4].x);
          float _793 = _792 / _791;
          float _794 = 1.0f - _793;
          float _795 = _794 * (User_000.UserConstant_Z_000[4].y);
          float _796 = _793 * (User_000.UserConstant_Z_000[4].w);
          float _797 = _795 + _796;
          float _798 = _794 * _794;
          float _799 = _798 * _794;
          float _800 = _799 - _794;
          float _801 = _800 * (User_000.UserConstant_Z_000[10].x);
          float _802 = _793 * _793;
          float _803 = _802 * _793;
          float _804 = _803 - _793;
          float _805 = _804 * (User_000.UserConstant_Z_000[10].y);
          float _806 = _801 + _805;
          float _807 = _791 * _791;
          float _808 = _807 * 0.1666666716337204f;
          float _809 = _808 * _806;
          float _810 = _797 + _809;
          _876 = _810;
        } else {
          bool _812 = !(_648 <= (User_000.UserConstant_Z_000[9].x));
          if (!_812) {
            float _814 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _815 = max(9.999999974752427e-07f, _814);
            float _816 = _648 - (User_000.UserConstant_Z_000[4].z);
            float _817 = _816 / _815;
            float _818 = 1.0f - _817;
            float _819 = _818 * (User_000.UserConstant_Z_000[4].w);
            float _820 = _817 * (User_000.UserConstant_Z_000[9].y);
            float _821 = _819 + _820;
            float _822 = _818 * _818;
            float _823 = _822 * _818;
            float _824 = _823 - _818;
            float _825 = _824 * (User_000.UserConstant_Z_000[10].y);
            float _826 = _817 * _817;
            float _827 = _826 * _817;
            float _828 = _827 - _817;
            float _829 = _828 * (User_000.UserConstant_Z_000[10].z);
            float _830 = _825 + _829;
            float _831 = _815 * _815;
            float _832 = _831 * 0.1666666716337204f;
            float _833 = _832 * _830;
            float _834 = _821 + _833;
            _876 = _834;
          } else {
            bool _836 = !(_648 <= (User_000.UserConstant_Z_000[9].z));
            if (!_836) {
              float _838 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _839 = max(9.999999974752427e-07f, _838);
              float _840 = _648 - (User_000.UserConstant_Z_000[9].x);
              float _841 = _840 / _839;
              float _842 = 1.0f - _841;
              float _843 = _842 * (User_000.UserConstant_Z_000[9].y);
              float _844 = _841 * (User_000.UserConstant_Z_000[9].w);
              float _845 = _843 + _844;
              float _846 = _842 * _842;
              float _847 = _846 * _842;
              float _848 = _847 - _842;
              float _849 = _848 * (User_000.UserConstant_Z_000[10].z);
              float _850 = _841 * _841;
              float _851 = _850 * _841;
              float _852 = _851 - _841;
              float _853 = _852 * (User_000.UserConstant_Z_000[10].w);
              float _854 = _849 + _853;
              float _855 = _839 * _839;
              float _856 = _855 * 0.1666666716337204f;
              float _857 = _856 * _854;
              float _858 = _845 + _857;
              _876 = _858;
            } else {
              float _860 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _861 = _648 - (User_000.UserConstant_Z_000[9].z);
              float _862 = max(9.999999974752427e-07f, _860);
              float _863 = _861 / _862;
              float _864 = 1.0f - _863;
              float _865 = _864 * (User_000.UserConstant_Z_000[9].w);
              float _866 = _865 + _863;
              float _867 = _864 * _864;
              float _868 = _867 * _864;
              float _869 = _868 - _864;
              float _870 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _871 = _860 * _860;
              float _872 = _871 * _870;
              float _873 = _872 * _869;
              float _874 = _866 + _873;
              _876 = _874;
            }
          }
        }
      }
      float _877 = saturate(_876);
      bool _878 = !(_649 <= (User_000.UserConstant_Z_000[4].x));
      if (!_878) {
        float _880 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _881 = _649 / _880;
        float _882 = _881 * (User_000.UserConstant_Z_000[4].y);
        float _883 = _881 * _881;
        float _884 = _883 * _881;
        float _885 = _884 - _881;
        float _886 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _887 = _880 * _880;
        float _888 = _887 * _886;
        float _889 = _888 * _885;
        float _890 = _889 + _882;
        _980 = _890;
      } else {
        bool _892 = !(_649 <= (User_000.UserConstant_Z_000[4].z));
        if (!_892) {
          float _894 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _895 = max(9.999999974752427e-07f, _894);
          float _896 = _649 - (User_000.UserConstant_Z_000[4].x);
          float _897 = _896 / _895;
          float _898 = 1.0f - _897;
          float _899 = _898 * (User_000.UserConstant_Z_000[4].y);
          float _900 = _897 * (User_000.UserConstant_Z_000[4].w);
          float _901 = _899 + _900;
          float _902 = _898 * _898;
          float _903 = _902 * _898;
          float _904 = _903 - _898;
          float _905 = _904 * (User_000.UserConstant_Z_000[10].x);
          float _906 = _897 * _897;
          float _907 = _906 * _897;
          float _908 = _907 - _897;
          float _909 = _908 * (User_000.UserConstant_Z_000[10].y);
          float _910 = _905 + _909;
          float _911 = _895 * _895;
          float _912 = _911 * 0.1666666716337204f;
          float _913 = _912 * _910;
          float _914 = _901 + _913;
          _980 = _914;
        } else {
          bool _916 = !(_649 <= (User_000.UserConstant_Z_000[9].x));
          if (!_916) {
            float _918 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _919 = max(9.999999974752427e-07f, _918);
            float _920 = _649 - (User_000.UserConstant_Z_000[4].z);
            float _921 = _920 / _919;
            float _922 = 1.0f - _921;
            float _923 = _922 * (User_000.UserConstant_Z_000[4].w);
            float _924 = _921 * (User_000.UserConstant_Z_000[9].y);
            float _925 = _923 + _924;
            float _926 = _922 * _922;
            float _927 = _926 * _922;
            float _928 = _927 - _922;
            float _929 = _928 * (User_000.UserConstant_Z_000[10].y);
            float _930 = _921 * _921;
            float _931 = _930 * _921;
            float _932 = _931 - _921;
            float _933 = _932 * (User_000.UserConstant_Z_000[10].z);
            float _934 = _929 + _933;
            float _935 = _919 * _919;
            float _936 = _935 * 0.1666666716337204f;
            float _937 = _936 * _934;
            float _938 = _925 + _937;
            _980 = _938;
          } else {
            bool _940 = !(_649 <= (User_000.UserConstant_Z_000[9].z));
            if (!_940) {
              float _942 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _943 = max(9.999999974752427e-07f, _942);
              float _944 = _649 - (User_000.UserConstant_Z_000[9].x);
              float _945 = _944 / _943;
              float _946 = 1.0f - _945;
              float _947 = _946 * (User_000.UserConstant_Z_000[9].y);
              float _948 = _945 * (User_000.UserConstant_Z_000[9].w);
              float _949 = _947 + _948;
              float _950 = _946 * _946;
              float _951 = _950 * _946;
              float _952 = _951 - _946;
              float _953 = _952 * (User_000.UserConstant_Z_000[10].z);
              float _954 = _945 * _945;
              float _955 = _954 * _945;
              float _956 = _955 - _945;
              float _957 = _956 * (User_000.UserConstant_Z_000[10].w);
              float _958 = _953 + _957;
              float _959 = _943 * _943;
              float _960 = _959 * 0.1666666716337204f;
              float _961 = _960 * _958;
              float _962 = _949 + _961;
              _980 = _962;
            } else {
              float _964 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _965 = _649 - (User_000.UserConstant_Z_000[9].z);
              float _966 = max(9.999999974752427e-07f, _964);
              float _967 = _965 / _966;
              float _968 = 1.0f - _967;
              float _969 = _968 * (User_000.UserConstant_Z_000[9].w);
              float _970 = _969 + _967;
              float _971 = _968 * _968;
              float _972 = _971 * _968;
              float _973 = _972 - _968;
              float _974 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _975 = _964 * _964;
              float _976 = _975 * _974;
              float _977 = _976 * _973;
              float _978 = _970 + _977;
              _980 = _978;
            }
          }
        }
      }
      float _981 = saturate(_980);
      _983 = _773;
      _984 = _877;
      _985 = _981;
    } else {
      _983 = _647;
      _984 = _648;
      _985 = _649;
    }
    int _986 = _651 & 2;
    bool _987 = (_986 == 0);
    if (!_987) {
      float _989 = sqrt(_983);
      float _990 = sqrt(_984);
      float _991 = sqrt(_985);
      float _992 = dot(float3(_989, _990, _991), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _993 = 1.0f - _992;
      float _994 = saturate(_993);
      _996 = _994;
    } else {
      _996 = 1.0f;
    }
    int _997 = _651 & 8;
    bool _998 = (_997 == 0);
    if (_998) {
      int _1000 = _651 & 4;
      bool _1001 = (_1000 == 0);
      if (!_1001) {
        int _1003 = _651 & 16;
        bool _1004 = (_1003 == 0);
        if (!_1004) {
          float _1008 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1009 = _1008 + 0.5f;
          bool _1010 = (_1009 < 0.5f);
          float _1011 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1012 = select(_1010, (User_000.UserConstant_Z_000[5].x), _1011);
          bool _1013 = (_984 < _985);
          float _1014 = select(_1013, _985, _984);
          float _1015 = select(_1013, _984, _985);
          bool _1016 = (_983 < _1014);
          float _1017 = select(_1016, _1014, _983);
          float _1018 = select(_1016, _983, _1014);
          float _1019 = min(_1018, _1015);
          float _1020 = _1017 - _1019;
          float _1021 = _1017 + 1.000000013351432e-10f;
          float _1022 = _1020 / _1021;
          float _1024 = _1022 - (User_000.UserConstant_Z_000[5].y);
          float _1025 = saturate(_1024);
          float _1026 = max(_1025, 9.999999974752427e-07f);
          float _1027 = log2(_1026);
          float _1028 = _1027 * _1012;
          float _1029 = exp2(_1028);
          float _1030 = 2.0f - _1029;
          float _1032 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1033 = saturate(_1032);
          float _1034 = max(_1033, _1030);
          float _1035 = dot(float3(_983, _984, _985), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1036 = _983 - _1035;
          float _1037 = _984 - _1035;
          float _1038 = _985 - _1035;
          float _1039 = _1036 * _1034;
          float _1040 = _1037 * _1034;
          float _1041 = _1038 * _1034;
          float _1042 = _1035 - _983;
          float _1043 = _1042 + _1039;
          float _1044 = _1035 - _984;
          float _1045 = _1044 + _1040;
          float _1046 = _1035 - _985;
          float _1047 = _1046 + _1041;
          float _1048 = _1043 * _996;
          float _1049 = _1045 * _996;
          float _1050 = _1047 * _996;
          float _1051 = _1048 + _983;
          float _1052 = _1049 + _984;
          float _1053 = _1050 + _985;
          _1170 = _1051;
          _1171 = _1052;
          _1172 = _1053;
        } else {
          bool _1055 = (_996 == 0.0f);
          if (!_1055) {
            float _1059 = abs(User_000.UserConstant_Z_000[5].x);
            float _1060 = saturate(_1059);
            uint4 _1062 = 0u; t15.GetDimensions(0u, _1062.x, _1062.y, _1062.w);
            float _1065 = float((uint)_1062.y);
            int _1066 = _651 & 32;
            bool _1067 = (_1066 == 0);
            float _1068 = _1065 + -1.0f;
            if (!_1067) {
              float _1070 = 1.0f / _1068;
              uint _1071 = uint(SV_Position.x);
              uint _1072 = uint(SV_Position.y);
              int _1073 = _1071 & 63;
              int _1074 = _1072 & 63;
              float4 _1076 = t6.Load(int4(_1073, _1074, 0, 0));
              float _1079 = _1076.x + -0.5f;
              float _1080 = _983 * 13.999999046325684f;
              float _1081 = _984 * 13.999999046325684f;
              float _1082 = _985 * 13.999999046325684f;
              float _1083 = saturate(_1080);
              float _1084 = saturate(_1081);
              float _1085 = saturate(_1082);
              float _1086 = _983 + -0.9285714030265808f;
              float _1087 = _984 + -0.9285714030265808f;
              float _1088 = _985 + -0.9285714030265808f;
              float _1089 = _1086 * 13.999999046325684f;
              float _1090 = _1087 * 13.999999046325684f;
              float _1091 = _1088 * 13.999999046325684f;
              float _1092 = saturate(_1089);
              float _1093 = saturate(_1090);
              float _1094 = saturate(_1091);
              float _1095 = 1.0f - _1092;
              float _1096 = 1.0f - _1093;
              float _1097 = 1.0f - _1094;
              float _1098 = min(_1083, _1095);
              float _1099 = min(_1084, _1096);
              float _1100 = min(_1085, _1097);
              float _1101 = _1076.y + -0.5f;
              float _1102 = _1098 * _1101;
              float _1103 = _1099 * _1101;
              float _1104 = _1100 * _1101;
              float _1105 = _1102 + _1079;
              float _1106 = _1103 + _1079;
              float _1107 = _1104 + _1079;
              float _1108 = _1105 * _1070;
              float _1109 = _1106 * _1070;
              float _1110 = _1107 * _1070;
              float _1111 = _1108 + _983;
              float _1112 = _1109 + _984;
              float _1113 = _1110 + _985;
              float _1114 = saturate(_1111);
              float _1115 = saturate(_1112);
              float _1116 = saturate(_1113);
              float _1117 = saturate(_1114);
              float _1118 = saturate(_1115);
              float _1119 = saturate(_1116);
              _1121 = _1117;
              _1122 = _1118;
              _1123 = _1119;
            } else {
              _1121 = _983;
              _1122 = _984;
              _1123 = _985;
            }
            float _1124 = float((uint)_1062.x);
            float _1125 = _1068 / _1124;
            float _1126 = _1125 * _1121;
            float _1127 = 0.5f / _1124;
            float _1128 = _1126 + _1127;
            float _1129 = _1068 / _1065;
            float _1130 = _1129 * _1122;
            float _1131 = 0.5f / _1065;
            float _1132 = _1130 + _1131;
            float _1133 = _1123 * _1068;
            float _1134 = floor(_1133);
            float _1135 = frac(_1133);
            float _1136 = _1134 / _1065;
            float _1137 = _1136 + _1128;
            float _1138 = _1134 + 1.0f;
            float _1139 = _1138 / _1065;
            float _1140 = _1139 + _1128;
            float4 _1142 = t15.Sample(s0, float2(_1137, _1132));
            float4 _1146 = t15.Sample(s0, float2(_1140, _1132));
            float _1150 = _1146.x - _1142.x;
            float _1151 = _1146.y - _1142.y;
            float _1152 = _1146.z - _1142.z;
            float _1153 = _1150 * _1135;
            float _1154 = _1151 * _1135;
            float _1155 = _1152 * _1135;
            float _1156 = _1060 * _996;
            float _1157 = _1142.x - _983;
            float _1158 = _1157 + _1153;
            float _1159 = _1142.y - _984;
            float _1160 = _1159 + _1154;
            float _1161 = _1142.z - _985;
            float _1162 = _1161 + _1155;
            float _1163 = _1158 * _1156;
            float _1164 = _1160 * _1156;
            float _1165 = _1162 * _1156;
            float _1166 = _1163 + _983;
            float _1167 = _1164 + _984;
            float _1168 = _1165 + _985;
            _1170 = _1166;
            _1171 = _1167;
            _1172 = _1168;
          } else {
            _1170 = _983;
            _1171 = _984;
            _1172 = _985;
          }
        }
      } else {
        _1170 = _983;
        _1171 = _984;
        _1172 = _985;
      }
    } else {
      _1170 = _996;
      _1171 = _996;
      _1172 = _996;
    }
    float _1173 = _1170 * 13.450128555297852f;
    float _1174 = _1171 * 13.450128555297852f;
    float _1175 = _1172 * 13.450128555297852f;
    float _1176 = exp2(_1173);
    float _1177 = exp2(_1174);
    float _1178 = exp2(_1175);
    float _1179 = _1176 + -1.0f;
    float _1180 = _1177 + -1.0f;
    float _1181 = _1178 + -1.0f;
    float _1182 = _1179 * _629;
    float _1183 = _1180 * _629;
    float _1184 = _1181 * _629;
    _1186 = _1182;
    _1187 = _1183;
    _1188 = _1184;
  } else {
    _1186 = _630;
    _1187 = _631;
    _1188 = _632;
  }
  float _1193 = (User_000.UserConstant_Z_000[8].x) * _1186;
  float _1194 = (User_000.UserConstant_Z_000[8].y) * _1187;
  float _1195 = (User_000.UserConstant_Z_000[8].z) * _1188;
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3(_1193, _1194, _1195),
      SV_Position.xy);
  float _1200 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _1201 = _1200 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _1202 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _1203 = _1202 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _1206 = _1201 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _1207 = _1203 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _1210 = t9.Sample(s9, float2(_1206, _1207));
  float _1214 = dot(float3(_1193, _1194, _1195), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _1217 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _1220 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _1221 = select(_1217, _1220, 0);
  float _1222 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _1223 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _1224 = uint(_1222);
  uint _1225 = uint(_1223);
  int _1226 = _1224 & 63;
  int _1227 = _1225 & 63;
  float4 _1229 = t6.Load(int4(_1226, _1227, _1221, 0));
  bool _1231 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_1231) {
    float _1233 = _1222 * 0.015625f;
    float _1234 = _1223 * 0.015625f;
    float _1235 = float((uint)_1220);
    float _1236 = select(_1217, _1235, 0.0f);
    float4 _1238 = t6.SampleLevel(s1, float3(_1233, _1234, _1236), 0.0f);
    float _1240 = _1229.y - _1238.y;
    float _1241 = _1240 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _1242 = _1241 + _1238.y;
    _1244 = _1242;
  } else {
    _1244 = _1229.y;
  }
  float _1245 = _1210.x * -2.0f;
  float _1246 = _1245 * _1244;
  float _1247 = _1244 * 2.0f;
  float _1248 = _1247 * _1210.y;
  float _1249 = _1247 * _1210.z;
  float _1250 = _1246 + _1210.x;
  float _1251 = _1248 - _1210.y;
  float _1252 = _1249 - _1210.z;
  float _1253 = _1250 * _1210.x;
  float _1254 = _1251 * _1210.y;
  float _1255 = _1252 * _1210.z;
  float _1256 = _1214 + 1.0f;
  float _1257 = _1214 / _1256;
  float _1258 = _1257 + -9.999999747378752e-05f;
  float _1259 = _1258 * 1111.111083984375f;
  float _1260 = saturate(_1259);
  float _1261 = _1260 * 2.0f;
  float _1262 = 3.0f - _1261;
  float _1263 = _1260 * _1260;
  float _1264 = _1263 * _1262;
  bool _1266 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _1267 = float((bool)_1266);
  float _1268 = dot(float3(_1253, _1254, _1255), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1269 = _1268 - _1253;
  float _1270 = _1268 - _1254;
  float _1271 = _1268 - _1255;
  float _1272 = _1269 * _1267;
  float _1273 = _1270 * _1267;
  float _1274 = _1271 * _1267;
  float _1275 = _1272 + _1253;
  float _1276 = _1273 + _1254;
  float _1277 = _1274 + _1255;
  float _1281 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1282 = _1281 * _1257;
  float _1283 = _1282 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1284 = _1264 * _1283;
  float _1285 = _1284 * _1275;
  float _1286 = _1284 * _1276;
  float _1287 = _1284 * _1277;
  float _1288 = _1285 + _1193;
  float _1289 = _1286 + _1194;
  float _1290 = _1287 + _1195;
  float _1291 = max(0.0f, _1288);
  float _1292 = max(0.0f, _1289);
  float _1293 = max(0.0f, _1290);
  float3 resonance_film_grain_output = ResonanceSelectFilmGrainOutput(
      float3(_1291, _1292, _1293),
      resonance_perceptual_film_grain);
  _1291 = resonance_film_grain_output.x;
  _1292 = resonance_film_grain_output.y;
  _1293 = resonance_film_grain_output.z;
  float _1296 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1297 = log2(_1291);
  float _1298 = _1296 * _1297;
  float _1299 = exp2(_1298);
  float _1300 = _1299 + -1.0f;
  float _1301 = _1291 + -1.0f;
  float _1302 = _1300 / _1301;
  bool _1303 = !(_1291 == 1.0f);
  float _1304 = _1302 + -1.0f;
  float _1305 = _1304 / _1302;
  float _1306 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1307 = _1306 / _1296;
  float _1308 = select(_1303, _1305, _1307);
  float _1309 = log2(_1292);
  float _1310 = _1309 * _1296;
  float _1311 = exp2(_1310);
  float _1312 = _1311 + -1.0f;
  float _1313 = _1292 + -1.0f;
  float _1314 = _1312 / _1313;
  bool _1315 = !(_1292 == 1.0f);
  float _1316 = _1314 + -1.0f;
  float _1317 = _1316 / _1314;
  float _1318 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1319 = _1318 / _1296;
  float _1320 = select(_1315, _1317, _1319);
  float _1321 = log2(_1293);
  float _1322 = _1321 * _1296;
  float _1323 = exp2(_1322);
  float _1324 = _1323 + -1.0f;
  float _1325 = _1293 + -1.0f;
  float _1326 = _1324 / _1325;
  bool _1327 = !(_1293 == 1.0f);
  float _1328 = _1326 + -1.0f;
  float _1329 = _1328 / _1326;
  float _1330 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1331 = _1330 / _1296;
  float _1332 = select(_1327, _1329, _1331);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1291, _1292, _1293),
      float3(_1308, _1320, _1332),
      true);
  float _1333 = resonance_post_process_output.x;
  float _1334 = resonance_post_process_output.y;
  float _1335 = resonance_post_process_output.z;
  float _1336 = log2(_1333);
  float _1337 = log2(_1334);
  float _1338 = log2(_1335);
  float _1339 = _1336 * 0.4166666567325592f;
  float _1340 = _1337 * 0.4166666567325592f;
  float _1341 = _1338 * 0.4166666567325592f;
  float _1342 = exp2(_1339);
  float _1343 = exp2(_1340);
  float _1344 = exp2(_1341);
  float _1345 = _1342 * 1.0549999475479126f;
  float _1346 = _1343 * 1.0549999475479126f;
  float _1347 = _1344 * 1.0549999475479126f;
  float _1348 = _1345 + -0.054999999701976776f;
  float _1349 = _1346 + -0.054999999701976776f;
  float _1350 = _1347 + -0.054999999701976776f;
  float _1351 = _1333 * 12.920000076293945f;
  float _1352 = _1334 * 12.920000076293945f;
  float _1353 = _1335 * 12.920000076293945f;
  bool _1354 = (_1333 <= 0.0031308000907301903f);
  bool _1355 = (_1334 <= 0.0031308000907301903f);
  bool _1356 = (_1335 <= 0.0031308000907301903f);
  float _1357 = select(_1354, _1351, _1348);
  float _1358 = select(_1355, _1352, _1349);
  float _1359 = select(_1356, _1353, _1350);
  uint _1360 = uint(SV_Position.x);
  uint _1361 = uint(SV_Position.y);
  int _1362 = _1360 & 63;
  int _1363 = _1361 & 63;
  float4 _1365 = t1.Load(int4(_1362, _1363, _1220, 0));
  float _1367 = _1365.x + -0.5f;
  float _1368 = _1367 * 0.003921568859368563f;
  float _1369 = _1368 + _1357;
  float _1370 = _1368 + _1358;
  float _1371 = _1368 + _1359;
  float _1372 = saturate(_1369);
  float _1373 = saturate(_1370);
  float _1374 = saturate(_1371);
  SV_Target.x = _1372;
  SV_Target.y = _1373;
  SV_Target.z = _1374;
  SV_Target.w = _138.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}