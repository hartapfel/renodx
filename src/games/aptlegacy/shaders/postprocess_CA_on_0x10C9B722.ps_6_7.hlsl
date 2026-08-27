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
  float GlobalCB_Z__GlobalConstant_Z_1692;
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
  float _778;
  float _882;
  float _986;
  float _989;
  float _990;
  float _991;
  float _1002;
  float _1127;
  float _1128;
  float _1129;
  float _1176;
  float _1177;
  float _1178;
  float _1192;
  float _1193;
  float _1194;
  float _1250;
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
  float _590 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _591 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _592 = _582.x * _591;
  float _593 = _592 * _576;
  float _594 = _593 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _595 = _594 * _590;
  float _596 = _592 * _577;
  float _597 = _596 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _598 = _597 * _590;
  float _599 = _592 * _578;
  float _600 = _599 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _601 = _600 * _590;
  float _602 = _595 + 1.0f;
  float _603 = _598 + 1.0f;
  float _604 = _601 + 1.0f;
  float _605 = log2(_602);
  float _606 = log2(_603);
  float _607 = log2(_604);
  float _610 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _611 = _610 * _605;
  float _612 = _610 * _606;
  float _613 = _610 * _607;
  float _615 = _611 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _616 = _612 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _617 = _613 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _620 = t3.Sample(s3, float3(_615, _616, _617));
  float _626 = _620.x * 13.450128555297852f;
  float _627 = _620.y * 13.450128555297852f;
  float _628 = _620.z * 13.450128555297852f;
  float _629 = exp2(_626);
  float _630 = exp2(_627);
  float _631 = exp2(_628);
  float _632 = _629 + -1.0f;
  float _633 = _630 + -1.0f;
  float _634 = _631 + -1.0f;
  float _635 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _636 = _635 * _632;
  float _637 = _635 * _633;
  float _638 = _635 * _634;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_595 * _635, _598 * _635, _601 * _635),
      float3(_636, _637, _638),
      1.f.xxx);
  _636 = apt_scaled_lut_output.x;
  _637 = apt_scaled_lut_output.y;
  _638 = apt_scaled_lut_output.z;
  bool _641 = ((User_000.UserConstant_Z_000[3].x) > 0.0f);
  if (_641) {
    float _643 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _644 = _636 * _643;
    float _645 = _637 * _643;
    float _646 = _638 * _643;
    float _647 = _644 + 1.0f;
    float _648 = _645 + 1.0f;
    float _649 = _646 + 1.0f;
    float _650 = log2(_647);
    float _651 = log2(_648);
    float _652 = log2(_649);
    float _653 = _650 * 0.07434873282909393f;
    float _654 = _651 * 0.07434873282909393f;
    float _655 = _652 * 0.07434873282909393f;
    int _657 = asint((User_000.UserConstant_Z_000[3].y));
    int _658 = _657 & 1;
    bool _659 = (_658 == 0);
    if (!_659) {
      bool _676 = !(_653 <= (User_000.UserConstant_Z_000[4].x));
      if (!_676) {
        float _678 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _679 = _653 / _678;
        float _680 = _679 * (User_000.UserConstant_Z_000[4].y);
        float _681 = _679 * _679;
        float _682 = _681 * _679;
        float _683 = _682 - _679;
        float _684 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _685 = _678 * _678;
        float _686 = _685 * _684;
        float _687 = _686 * _683;
        float _688 = _687 + _680;
        _778 = _688;
      } else {
        bool _690 = !(_653 <= (User_000.UserConstant_Z_000[4].z));
        if (!_690) {
          float _692 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _693 = max(9.999999974752427e-07f, _692);
          float _694 = _653 - (User_000.UserConstant_Z_000[4].x);
          float _695 = _694 / _693;
          float _696 = 1.0f - _695;
          float _697 = _696 * (User_000.UserConstant_Z_000[4].y);
          float _698 = _695 * (User_000.UserConstant_Z_000[4].w);
          float _699 = _697 + _698;
          float _700 = _696 * _696;
          float _701 = _700 * _696;
          float _702 = _701 - _696;
          float _703 = _702 * (User_000.UserConstant_Z_000[10].x);
          float _704 = _695 * _695;
          float _705 = _704 * _695;
          float _706 = _705 - _695;
          float _707 = _706 * (User_000.UserConstant_Z_000[10].y);
          float _708 = _703 + _707;
          float _709 = _693 * _693;
          float _710 = _709 * 0.1666666716337204f;
          float _711 = _710 * _708;
          float _712 = _699 + _711;
          _778 = _712;
        } else {
          bool _714 = !(_653 <= (User_000.UserConstant_Z_000[9].x));
          if (!_714) {
            float _716 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _717 = max(9.999999974752427e-07f, _716);
            float _718 = _653 - (User_000.UserConstant_Z_000[4].z);
            float _719 = _718 / _717;
            float _720 = 1.0f - _719;
            float _721 = _720 * (User_000.UserConstant_Z_000[4].w);
            float _722 = _719 * (User_000.UserConstant_Z_000[9].y);
            float _723 = _721 + _722;
            float _724 = _720 * _720;
            float _725 = _724 * _720;
            float _726 = _725 - _720;
            float _727 = _726 * (User_000.UserConstant_Z_000[10].y);
            float _728 = _719 * _719;
            float _729 = _728 * _719;
            float _730 = _729 - _719;
            float _731 = _730 * (User_000.UserConstant_Z_000[10].z);
            float _732 = _727 + _731;
            float _733 = _717 * _717;
            float _734 = _733 * 0.1666666716337204f;
            float _735 = _734 * _732;
            float _736 = _723 + _735;
            _778 = _736;
          } else {
            bool _738 = !(_653 <= (User_000.UserConstant_Z_000[9].z));
            if (!_738) {
              float _740 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _741 = max(9.999999974752427e-07f, _740);
              float _742 = _653 - (User_000.UserConstant_Z_000[9].x);
              float _743 = _742 / _741;
              float _744 = 1.0f - _743;
              float _745 = _744 * (User_000.UserConstant_Z_000[9].y);
              float _746 = _743 * (User_000.UserConstant_Z_000[9].w);
              float _747 = _745 + _746;
              float _748 = _744 * _744;
              float _749 = _748 * _744;
              float _750 = _749 - _744;
              float _751 = _750 * (User_000.UserConstant_Z_000[10].z);
              float _752 = _743 * _743;
              float _753 = _752 * _743;
              float _754 = _753 - _743;
              float _755 = _754 * (User_000.UserConstant_Z_000[10].w);
              float _756 = _751 + _755;
              float _757 = _741 * _741;
              float _758 = _757 * 0.1666666716337204f;
              float _759 = _758 * _756;
              float _760 = _747 + _759;
              _778 = _760;
            } else {
              float _762 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _763 = _653 - (User_000.UserConstant_Z_000[9].z);
              float _764 = max(9.999999974752427e-07f, _762);
              float _765 = _763 / _764;
              float _766 = 1.0f - _765;
              float _767 = _766 * (User_000.UserConstant_Z_000[9].w);
              float _768 = _767 + _765;
              float _769 = _766 * _766;
              float _770 = _769 * _766;
              float _771 = _770 - _766;
              float _772 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _773 = _762 * _762;
              float _774 = _773 * _772;
              float _775 = _774 * _771;
              float _776 = _768 + _775;
              _778 = _776;
            }
          }
        }
      }
      float _779 = saturate(_778);
      bool _780 = !(_654 <= (User_000.UserConstant_Z_000[4].x));
      if (!_780) {
        float _782 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _783 = _654 / _782;
        float _784 = _783 * (User_000.UserConstant_Z_000[4].y);
        float _785 = _783 * _783;
        float _786 = _785 * _783;
        float _787 = _786 - _783;
        float _788 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _789 = _782 * _782;
        float _790 = _789 * _788;
        float _791 = _790 * _787;
        float _792 = _791 + _784;
        _882 = _792;
      } else {
        bool _794 = !(_654 <= (User_000.UserConstant_Z_000[4].z));
        if (!_794) {
          float _796 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _797 = max(9.999999974752427e-07f, _796);
          float _798 = _654 - (User_000.UserConstant_Z_000[4].x);
          float _799 = _798 / _797;
          float _800 = 1.0f - _799;
          float _801 = _800 * (User_000.UserConstant_Z_000[4].y);
          float _802 = _799 * (User_000.UserConstant_Z_000[4].w);
          float _803 = _801 + _802;
          float _804 = _800 * _800;
          float _805 = _804 * _800;
          float _806 = _805 - _800;
          float _807 = _806 * (User_000.UserConstant_Z_000[10].x);
          float _808 = _799 * _799;
          float _809 = _808 * _799;
          float _810 = _809 - _799;
          float _811 = _810 * (User_000.UserConstant_Z_000[10].y);
          float _812 = _807 + _811;
          float _813 = _797 * _797;
          float _814 = _813 * 0.1666666716337204f;
          float _815 = _814 * _812;
          float _816 = _803 + _815;
          _882 = _816;
        } else {
          bool _818 = !(_654 <= (User_000.UserConstant_Z_000[9].x));
          if (!_818) {
            float _820 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _821 = max(9.999999974752427e-07f, _820);
            float _822 = _654 - (User_000.UserConstant_Z_000[4].z);
            float _823 = _822 / _821;
            float _824 = 1.0f - _823;
            float _825 = _824 * (User_000.UserConstant_Z_000[4].w);
            float _826 = _823 * (User_000.UserConstant_Z_000[9].y);
            float _827 = _825 + _826;
            float _828 = _824 * _824;
            float _829 = _828 * _824;
            float _830 = _829 - _824;
            float _831 = _830 * (User_000.UserConstant_Z_000[10].y);
            float _832 = _823 * _823;
            float _833 = _832 * _823;
            float _834 = _833 - _823;
            float _835 = _834 * (User_000.UserConstant_Z_000[10].z);
            float _836 = _831 + _835;
            float _837 = _821 * _821;
            float _838 = _837 * 0.1666666716337204f;
            float _839 = _838 * _836;
            float _840 = _827 + _839;
            _882 = _840;
          } else {
            bool _842 = !(_654 <= (User_000.UserConstant_Z_000[9].z));
            if (!_842) {
              float _844 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _845 = max(9.999999974752427e-07f, _844);
              float _846 = _654 - (User_000.UserConstant_Z_000[9].x);
              float _847 = _846 / _845;
              float _848 = 1.0f - _847;
              float _849 = _848 * (User_000.UserConstant_Z_000[9].y);
              float _850 = _847 * (User_000.UserConstant_Z_000[9].w);
              float _851 = _849 + _850;
              float _852 = _848 * _848;
              float _853 = _852 * _848;
              float _854 = _853 - _848;
              float _855 = _854 * (User_000.UserConstant_Z_000[10].z);
              float _856 = _847 * _847;
              float _857 = _856 * _847;
              float _858 = _857 - _847;
              float _859 = _858 * (User_000.UserConstant_Z_000[10].w);
              float _860 = _855 + _859;
              float _861 = _845 * _845;
              float _862 = _861 * 0.1666666716337204f;
              float _863 = _862 * _860;
              float _864 = _851 + _863;
              _882 = _864;
            } else {
              float _866 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _867 = _654 - (User_000.UserConstant_Z_000[9].z);
              float _868 = max(9.999999974752427e-07f, _866);
              float _869 = _867 / _868;
              float _870 = 1.0f - _869;
              float _871 = _870 * (User_000.UserConstant_Z_000[9].w);
              float _872 = _871 + _869;
              float _873 = _870 * _870;
              float _874 = _873 * _870;
              float _875 = _874 - _870;
              float _876 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _877 = _866 * _866;
              float _878 = _877 * _876;
              float _879 = _878 * _875;
              float _880 = _872 + _879;
              _882 = _880;
            }
          }
        }
      }
      float _883 = saturate(_882);
      bool _884 = !(_655 <= (User_000.UserConstant_Z_000[4].x));
      if (!_884) {
        float _886 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _887 = _655 / _886;
        float _888 = _887 * (User_000.UserConstant_Z_000[4].y);
        float _889 = _887 * _887;
        float _890 = _889 * _887;
        float _891 = _890 - _887;
        float _892 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _893 = _886 * _886;
        float _894 = _893 * _892;
        float _895 = _894 * _891;
        float _896 = _895 + _888;
        _986 = _896;
      } else {
        bool _898 = !(_655 <= (User_000.UserConstant_Z_000[4].z));
        if (!_898) {
          float _900 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _901 = max(9.999999974752427e-07f, _900);
          float _902 = _655 - (User_000.UserConstant_Z_000[4].x);
          float _903 = _902 / _901;
          float _904 = 1.0f - _903;
          float _905 = _904 * (User_000.UserConstant_Z_000[4].y);
          float _906 = _903 * (User_000.UserConstant_Z_000[4].w);
          float _907 = _905 + _906;
          float _908 = _904 * _904;
          float _909 = _908 * _904;
          float _910 = _909 - _904;
          float _911 = _910 * (User_000.UserConstant_Z_000[10].x);
          float _912 = _903 * _903;
          float _913 = _912 * _903;
          float _914 = _913 - _903;
          float _915 = _914 * (User_000.UserConstant_Z_000[10].y);
          float _916 = _911 + _915;
          float _917 = _901 * _901;
          float _918 = _917 * 0.1666666716337204f;
          float _919 = _918 * _916;
          float _920 = _907 + _919;
          _986 = _920;
        } else {
          bool _922 = !(_655 <= (User_000.UserConstant_Z_000[9].x));
          if (!_922) {
            float _924 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _925 = max(9.999999974752427e-07f, _924);
            float _926 = _655 - (User_000.UserConstant_Z_000[4].z);
            float _927 = _926 / _925;
            float _928 = 1.0f - _927;
            float _929 = _928 * (User_000.UserConstant_Z_000[4].w);
            float _930 = _927 * (User_000.UserConstant_Z_000[9].y);
            float _931 = _929 + _930;
            float _932 = _928 * _928;
            float _933 = _932 * _928;
            float _934 = _933 - _928;
            float _935 = _934 * (User_000.UserConstant_Z_000[10].y);
            float _936 = _927 * _927;
            float _937 = _936 * _927;
            float _938 = _937 - _927;
            float _939 = _938 * (User_000.UserConstant_Z_000[10].z);
            float _940 = _935 + _939;
            float _941 = _925 * _925;
            float _942 = _941 * 0.1666666716337204f;
            float _943 = _942 * _940;
            float _944 = _931 + _943;
            _986 = _944;
          } else {
            bool _946 = !(_655 <= (User_000.UserConstant_Z_000[9].z));
            if (!_946) {
              float _948 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _949 = max(9.999999974752427e-07f, _948);
              float _950 = _655 - (User_000.UserConstant_Z_000[9].x);
              float _951 = _950 / _949;
              float _952 = 1.0f - _951;
              float _953 = _952 * (User_000.UserConstant_Z_000[9].y);
              float _954 = _951 * (User_000.UserConstant_Z_000[9].w);
              float _955 = _953 + _954;
              float _956 = _952 * _952;
              float _957 = _956 * _952;
              float _958 = _957 - _952;
              float _959 = _958 * (User_000.UserConstant_Z_000[10].z);
              float _960 = _951 * _951;
              float _961 = _960 * _951;
              float _962 = _961 - _951;
              float _963 = _962 * (User_000.UserConstant_Z_000[10].w);
              float _964 = _959 + _963;
              float _965 = _949 * _949;
              float _966 = _965 * 0.1666666716337204f;
              float _967 = _966 * _964;
              float _968 = _955 + _967;
              _986 = _968;
            } else {
              float _970 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _971 = _655 - (User_000.UserConstant_Z_000[9].z);
              float _972 = max(9.999999974752427e-07f, _970);
              float _973 = _971 / _972;
              float _974 = 1.0f - _973;
              float _975 = _974 * (User_000.UserConstant_Z_000[9].w);
              float _976 = _975 + _973;
              float _977 = _974 * _974;
              float _978 = _977 * _974;
              float _979 = _978 - _974;
              float _980 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _981 = _970 * _970;
              float _982 = _981 * _980;
              float _983 = _982 * _979;
              float _984 = _976 + _983;
              _986 = _984;
            }
          }
        }
      }
      float _987 = saturate(_986);
      _989 = _779;
      _990 = _883;
      _991 = _987;
    } else {
      _989 = _653;
      _990 = _654;
      _991 = _655;
    }
    int _992 = _657 & 2;
    bool _993 = (_992 == 0);
    if (!_993) {
      float _995 = sqrt(_989);
      float _996 = sqrt(_990);
      float _997 = sqrt(_991);
      float _998 = dot(float3(_995, _996, _997), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _999 = 1.0f - _998;
      float _1000 = saturate(_999);
      _1002 = _1000;
    } else {
      _1002 = 1.0f;
    }
    int _1003 = _657 & 8;
    bool _1004 = (_1003 == 0);
    if (_1004) {
      int _1006 = _657 & 4;
      bool _1007 = (_1006 == 0);
      if (!_1007) {
        int _1009 = _657 & 16;
        bool _1010 = (_1009 == 0);
        if (!_1010) {
          float _1014 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1015 = _1014 + 0.5f;
          bool _1016 = (_1015 < 0.5f);
          float _1017 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1018 = select(_1016, (User_000.UserConstant_Z_000[5].x), _1017);
          bool _1019 = (_990 < _991);
          float _1020 = select(_1019, _991, _990);
          float _1021 = select(_1019, _990, _991);
          bool _1022 = (_989 < _1020);
          float _1023 = select(_1022, _1020, _989);
          float _1024 = select(_1022, _989, _1020);
          float _1025 = min(_1024, _1021);
          float _1026 = _1023 - _1025;
          float _1027 = _1023 + 1.000000013351432e-10f;
          float _1028 = _1026 / _1027;
          float _1030 = _1028 - (User_000.UserConstant_Z_000[5].y);
          float _1031 = saturate(_1030);
          float _1032 = max(_1031, 9.999999974752427e-07f);
          float _1033 = log2(_1032);
          float _1034 = _1033 * _1018;
          float _1035 = exp2(_1034);
          float _1036 = 2.0f - _1035;
          float _1038 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1039 = saturate(_1038);
          float _1040 = max(_1039, _1036);
          float _1041 = dot(float3(_989, _990, _991), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1042 = _989 - _1041;
          float _1043 = _990 - _1041;
          float _1044 = _991 - _1041;
          float _1045 = _1042 * _1040;
          float _1046 = _1043 * _1040;
          float _1047 = _1044 * _1040;
          float _1048 = _1041 - _989;
          float _1049 = _1048 + _1045;
          float _1050 = _1041 - _990;
          float _1051 = _1050 + _1046;
          float _1052 = _1041 - _991;
          float _1053 = _1052 + _1047;
          float _1054 = _1049 * _1002;
          float _1055 = _1051 * _1002;
          float _1056 = _1053 * _1002;
          float _1057 = _1054 + _989;
          float _1058 = _1055 + _990;
          float _1059 = _1056 + _991;
          _1176 = _1057;
          _1177 = _1058;
          _1178 = _1059;
        } else {
          bool _1061 = (_1002 == 0.0f);
          if (!_1061) {
            float _1065 = abs(User_000.UserConstant_Z_000[5].x);
            float _1066 = saturate(_1065);
            uint4 _1068 = 0u; t15.GetDimensions(0u, _1068.x, _1068.y, _1068.w);
            float _1071 = float((uint)_1068.y);
            int _1072 = _657 & 32;
            bool _1073 = (_1072 == 0);
            float _1074 = _1071 + -1.0f;
            if (!_1073) {
              float _1076 = 1.0f / _1074;
              uint _1077 = uint(SV_Position.x);
              uint _1078 = uint(SV_Position.y);
              int _1079 = _1077 & 63;
              int _1080 = _1078 & 63;
              float4 _1082 = t6.Load(int4(_1079, _1080, 0, 0));
              float _1085 = _1082.x + -0.5f;
              float _1086 = _989 * 13.999999046325684f;
              float _1087 = _990 * 13.999999046325684f;
              float _1088 = _991 * 13.999999046325684f;
              float _1089 = saturate(_1086);
              float _1090 = saturate(_1087);
              float _1091 = saturate(_1088);
              float _1092 = _989 + -0.9285714030265808f;
              float _1093 = _990 + -0.9285714030265808f;
              float _1094 = _991 + -0.9285714030265808f;
              float _1095 = _1092 * 13.999999046325684f;
              float _1096 = _1093 * 13.999999046325684f;
              float _1097 = _1094 * 13.999999046325684f;
              float _1098 = saturate(_1095);
              float _1099 = saturate(_1096);
              float _1100 = saturate(_1097);
              float _1101 = 1.0f - _1098;
              float _1102 = 1.0f - _1099;
              float _1103 = 1.0f - _1100;
              float _1104 = min(_1089, _1101);
              float _1105 = min(_1090, _1102);
              float _1106 = min(_1091, _1103);
              float _1107 = _1082.y + -0.5f;
              float _1108 = _1104 * _1107;
              float _1109 = _1105 * _1107;
              float _1110 = _1106 * _1107;
              float _1111 = _1108 + _1085;
              float _1112 = _1109 + _1085;
              float _1113 = _1110 + _1085;
              float _1114 = _1111 * _1076;
              float _1115 = _1112 * _1076;
              float _1116 = _1113 * _1076;
              float _1117 = _1114 + _989;
              float _1118 = _1115 + _990;
              float _1119 = _1116 + _991;
              float _1120 = saturate(_1117);
              float _1121 = saturate(_1118);
              float _1122 = saturate(_1119);
              float _1123 = saturate(_1120);
              float _1124 = saturate(_1121);
              float _1125 = saturate(_1122);
              _1127 = _1123;
              _1128 = _1124;
              _1129 = _1125;
            } else {
              _1127 = _989;
              _1128 = _990;
              _1129 = _991;
            }
            float _1130 = float((uint)_1068.x);
            float _1131 = _1074 / _1130;
            float _1132 = _1131 * _1127;
            float _1133 = 0.5f / _1130;
            float _1134 = _1132 + _1133;
            float _1135 = _1074 / _1071;
            float _1136 = _1135 * _1128;
            float _1137 = 0.5f / _1071;
            float _1138 = _1136 + _1137;
            float _1139 = _1129 * _1074;
            float _1140 = floor(_1139);
            float _1141 = frac(_1139);
            float _1142 = _1140 / _1071;
            float _1143 = _1142 + _1134;
            float _1144 = _1140 + 1.0f;
            float _1145 = _1144 / _1071;
            float _1146 = _1145 + _1134;
            float4 _1148 = t15.Sample(s0, float2(_1143, _1138));
            float4 _1152 = t15.Sample(s0, float2(_1146, _1138));
            float _1156 = _1152.x - _1148.x;
            float _1157 = _1152.y - _1148.y;
            float _1158 = _1152.z - _1148.z;
            float _1159 = _1156 * _1141;
            float _1160 = _1157 * _1141;
            float _1161 = _1158 * _1141;
            float _1162 = _1066 * _1002;
            float _1163 = _1148.x - _989;
            float _1164 = _1163 + _1159;
            float _1165 = _1148.y - _990;
            float _1166 = _1165 + _1160;
            float _1167 = _1148.z - _991;
            float _1168 = _1167 + _1161;
            float _1169 = _1164 * _1162;
            float _1170 = _1166 * _1162;
            float _1171 = _1168 * _1162;
            float _1172 = _1169 + _989;
            float _1173 = _1170 + _990;
            float _1174 = _1171 + _991;
            _1176 = _1172;
            _1177 = _1173;
            _1178 = _1174;
          } else {
            _1176 = _989;
            _1177 = _990;
            _1178 = _991;
          }
        }
      } else {
        _1176 = _989;
        _1177 = _990;
        _1178 = _991;
      }
    } else {
      _1176 = _1002;
      _1177 = _1002;
      _1178 = _1002;
    }
    float _1179 = _1176 * 13.450128555297852f;
    float _1180 = _1177 * 13.450128555297852f;
    float _1181 = _1178 * 13.450128555297852f;
    float _1182 = exp2(_1179);
    float _1183 = exp2(_1180);
    float _1184 = exp2(_1181);
    float _1185 = _1182 + -1.0f;
    float _1186 = _1183 + -1.0f;
    float _1187 = _1184 + -1.0f;
    float _1188 = _1185 * _635;
    float _1189 = _1186 * _635;
    float _1190 = _1187 * _635;
    _1192 = _1188;
    _1193 = _1189;
    _1194 = _1190;
  } else {
    _1192 = _636;
    _1193 = _637;
    _1194 = _638;
  }
  float _1199 = (User_000.UserConstant_Z_000[8].x) * _1192;
  float _1200 = (User_000.UserConstant_Z_000[8].y) * _1193;
  float _1201 = (User_000.UserConstant_Z_000[8].z) * _1194;
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3(_1199, _1200, _1201),
      SV_Position.xy);
  float _1206 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _1207 = _1206 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _1208 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _1209 = _1208 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _1212 = _1207 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _1213 = _1209 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _1216 = t9.Sample(s9, float2(_1212, _1213));
  float _1220 = dot(float3(_1199, _1200, _1201), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _1223 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _1226 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _1227 = select(_1223, _1226, 0);
  float _1228 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _1229 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _1230 = uint(_1228);
  uint _1231 = uint(_1229);
  int _1232 = _1230 & 63;
  int _1233 = _1231 & 63;
  float4 _1235 = t6.Load(int4(_1232, _1233, _1227, 0));
  bool _1237 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_1237) {
    float _1239 = _1228 * 0.015625f;
    float _1240 = _1229 * 0.015625f;
    float _1241 = float((uint)_1226);
    float _1242 = select(_1223, _1241, 0.0f);
    float4 _1244 = t6.SampleLevel(s1, float3(_1239, _1240, _1242), 0.0f);
    float _1246 = _1235.y - _1244.y;
    float _1247 = _1246 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _1248 = _1247 + _1244.y;
    _1250 = _1248;
  } else {
    _1250 = _1235.y;
  }
  float _1251 = _1216.x * -2.0f;
  float _1252 = _1251 * _1250;
  float _1253 = _1250 * 2.0f;
  float _1254 = _1253 * _1216.y;
  float _1255 = _1253 * _1216.z;
  float _1256 = _1252 + _1216.x;
  float _1257 = _1254 - _1216.y;
  float _1258 = _1255 - _1216.z;
  float _1259 = _1256 * _1216.x;
  float _1260 = _1257 * _1216.y;
  float _1261 = _1258 * _1216.z;
  float _1262 = _1220 + 1.0f;
  float _1263 = _1220 / _1262;
  float _1264 = _1263 + -9.999999747378752e-05f;
  float _1265 = _1264 * 1111.111083984375f;
  float _1266 = saturate(_1265);
  float _1267 = _1266 * 2.0f;
  float _1268 = 3.0f - _1267;
  float _1269 = _1266 * _1266;
  float _1270 = _1269 * _1268;
  bool _1272 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _1273 = float((bool)_1272);
  float _1274 = dot(float3(_1259, _1260, _1261), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1275 = _1274 - _1259;
  float _1276 = _1274 - _1260;
  float _1277 = _1274 - _1261;
  float _1278 = _1275 * _1273;
  float _1279 = _1276 * _1273;
  float _1280 = _1277 * _1273;
  float _1281 = _1278 + _1259;
  float _1282 = _1279 + _1260;
  float _1283 = _1280 + _1261;
  float _1287 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1288 = _1287 * _1263;
  float _1289 = _1288 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1290 = _1270 * _1289;
  float _1291 = _1290 * _1281;
  float _1292 = _1290 * _1282;
  float _1293 = _1290 * _1283;
  float _1294 = _1291 + _1199;
  float _1295 = _1292 + _1200;
  float _1296 = _1293 + _1201;
  float _1297 = max(0.0f, _1294);
  float _1298 = max(0.0f, _1295);
  float _1299 = max(0.0f, _1296);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_1297, _1298, _1299),
      apt_perceptual_film_grain);
  _1297 = apt_film_grain_output.x;
  _1298 = apt_film_grain_output.y;
  _1299 = apt_film_grain_output.z;
  float _1302 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1303 = log2(_1297);
  float _1304 = _1302 * _1303;
  float _1305 = exp2(_1304);
  float _1306 = _1305 + -1.0f;
  float _1307 = _1297 + -1.0f;
  float _1308 = _1306 / _1307;
  bool _1309 = !(_1297 == 1.0f);
  float _1310 = _1308 + -1.0f;
  float _1311 = _1310 / _1308;
  float _1312 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1313 = _1312 / _1302;
  float _1314 = select(_1309, _1311, _1313);
  float _1315 = log2(_1298);
  float _1316 = _1315 * _1302;
  float _1317 = exp2(_1316);
  float _1318 = _1317 + -1.0f;
  float _1319 = _1298 + -1.0f;
  float _1320 = _1318 / _1319;
  bool _1321 = !(_1298 == 1.0f);
  float _1322 = _1320 + -1.0f;
  float _1323 = _1322 / _1320;
  float _1324 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1325 = _1324 / _1302;
  float _1326 = select(_1321, _1323, _1325);
  float _1327 = log2(_1299);
  float _1328 = _1327 * _1302;
  float _1329 = exp2(_1328);
  float _1330 = _1329 + -1.0f;
  float _1331 = _1299 + -1.0f;
  float _1332 = _1330 / _1331;
  bool _1333 = !(_1299 == 1.0f);
  float _1334 = _1332 + -1.0f;
  float _1335 = _1334 / _1332;
  float _1336 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1337 = _1336 / _1302;
  float _1338 = select(_1333, _1335, _1337);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1297, _1298, _1299),
      float3(_1314, _1326, _1338),
      true);
  float _1339 = apt_post_process_output.x;
  float _1340 = apt_post_process_output.y;
  float _1341 = apt_post_process_output.z;
  float _1342 = log2(_1339);
  float _1343 = log2(_1340);
  float _1344 = log2(_1341);
  float _1345 = _1342 * 0.4166666567325592f;
  float _1346 = _1343 * 0.4166666567325592f;
  float _1347 = _1344 * 0.4166666567325592f;
  float _1348 = exp2(_1345);
  float _1349 = exp2(_1346);
  float _1350 = exp2(_1347);
  float _1351 = _1348 * 1.0549999475479126f;
  float _1352 = _1349 * 1.0549999475479126f;
  float _1353 = _1350 * 1.0549999475479126f;
  float _1354 = _1351 + -0.054999999701976776f;
  float _1355 = _1352 + -0.054999999701976776f;
  float _1356 = _1353 + -0.054999999701976776f;
  float _1357 = _1339 * 12.920000076293945f;
  float _1358 = _1340 * 12.920000076293945f;
  float _1359 = _1341 * 12.920000076293945f;
  bool _1360 = (_1339 <= 0.0031308000907301903f);
  bool _1361 = (_1340 <= 0.0031308000907301903f);
  bool _1362 = (_1341 <= 0.0031308000907301903f);
  float _1363 = select(_1360, _1357, _1354);
  float _1364 = select(_1361, _1358, _1355);
  float _1365 = select(_1362, _1359, _1356);
  uint _1366 = uint(SV_Position.x);
  uint _1367 = uint(SV_Position.y);
  int _1368 = _1366 & 63;
  int _1369 = _1367 & 63;
  float4 _1371 = t1.Load(int4(_1368, _1369, _1226, 0));
  float _1373 = _1371.x + -0.5f;
  float _1374 = _1373 * 0.003921568859368563f;
  float _1375 = _1374 + _1363;
  float _1376 = _1374 + _1364;
  float _1377 = _1374 + _1365;
  float _1378 = saturate(_1375);
  float _1379 = saturate(_1376);
  float _1380 = saturate(_1377);
  SV_Target.x = _1378;
  SV_Target.y = _1379;
  SV_Target.z = _1380;
  SV_Target.w = _138.w;
  return SV_Target;
}
