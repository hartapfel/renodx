struct GlobalCB_Z__AnchorConstant_Z {
  float4 m[7];
  float4 WorldPos_Delta;
  float4 Detail_Map_Near_Tiling;
  float4 Detail_Map_Near2_Tiling;
  float4 Detail_Map_Far_Tiling;
  float4 Ice_Noise_Far_Tiling;
  float4 TIN_Building_Lights_Tiling_0;
  float4 TIN_Building_Lights_Tiling_1;
  float4 TIN_Building_Lights_Tiling_2;
  float4 Detail_Map_Ice;
  float4 To_Fire_Grid[4];
  float4 Pos_Y_Detail_Map_Tilings;
  float4 Ground_Contact;
};

struct GlobalCB_Z__ProjConstant_Z {
  float4 m[4][32];
  float2 JitterOffsetNDC;
  float2 JitterOffsetUV;
  uint4 B;
  float4 FrustumPlane_FocusRect[4];
};

struct GlobalCB_Z__GlobalConstant_Z {
  float4 c[104];
  uint InnerFrameIndex;
  int3 ReGIRHashgridOffset;
  float3 ReGIROffsetInCellOffset;
  uint AllLightsCount;
};

struct GlobalCB_Z__ViewConstant_Z {
  float4 ViewTrans;
  float4 ViewTransPrev;
  float4 m[32];
};

struct GlobalCB_Z__ViewportConstant_Z {
  float2 HalfSize;
  float2 Center;
  float2 RenderTargetSize;
  float2 RenderTargetInvSize;
  float2 HalfResUpsampleScale;
  uint2 _pad0;
  float TAASampleIndex;
  uint SSREnabled;
  float SSRStep;
  uint UseHierarchicalSSR;
  float4 ScaleOffset;
  float3 ClearColor;
  float SSRIncrement;
};

struct GlobalCB_Z {
  GlobalCB_Z__GlobalConstant_Z Global;
  GlobalCB_Z__ViewportConstant_Z Viewport;
  GlobalCB_Z__AnchorConstant_Z Anchor;
  GlobalCB_Z__ViewConstant_Z View;
  GlobalCB_Z__ProjConstant_Z Proj;
};

struct PostProcessConstant_Z {
  float4 Settings[20];
  float4 OffsetWeight[32];
};

struct UserConstant_Z {
  float4 c[84];
};


Texture2DArray<float4> sBlueNoiseR8 : register(t1);

Texture2DArray<float4> sBlueNoiseR8G8 : register(t6);

Texture2D<float4> s0 : register(t0);

Texture2D<float4> s2 : register(t2);

Texture3D<float4> s3_3D : register(t3);

Texture2D<float4> s4 : register(t4);

Texture2D<float4> s5 : register(t5);

Texture2D<float4> s7 : register(t7);

Texture2D<float4> s8 : register(t8);

Texture2D<float4> s9 : register(t9);

Texture2D<float4> s12_bloom : register(t12);

Texture2D<float4> s14 : register(t14);

Texture2D<float4> sVibranceLUT : register(t15);

Texture2D<float4> sPostProcessFX_MaskLayer : register(t16);

Texture2D<float4> sExposureScale : register(t17);

#include "../common.hlsli"

cbuffer Global : register(b1) {
  GlobalCB_Z Global : packoffset(c000.x);
  float4 Global_raw[302] : packoffset(c0);
};

cbuffer User : register(b0) {
  UserConstant_Z User : packoffset(c000.x);
  float4 User_raw[84] : packoffset(c0);
};

cbuffer PostProcess : register(b2) {
  PostProcessConstant_Z PostProcess : packoffset(c000.x);
  float4 PostProcess_raw[52] : packoffset(c0);
};

SamplerState sLinearClampSampler : register(s0);

SamplerState sLinearWrapSampler : register(s1);

SamplerState s2Sampler : register(s2);

SamplerState s3_3DSampler : register(s3);

SamplerState s4Sampler : register(s4);

SamplerState s5Sampler : register(s5);

SamplerState s7Sampler : register(s7);

SamplerState s8Sampler : register(s8);

SamplerState s9Sampler : register(s9);

SamplerState s14Sampler : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _40 = s14.Sample(s14Sampler, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _46 = sPostProcessFX_MaskLayer.Sample(sLinearClampSampler, float2(TEXCOORD.z, TEXCOORD.w));
  float _49 = _46.y * 0.10000000149011612f;
  float _50 = _49 + _40.y;
  float _51 = _46.y * 0.5f;
  float _52 = _51 + _40.z;
  float _53 = exp2(_52);
  float _54 = _53 + -1.0f;
  float _57 = (PostProcess.Settings[11].y) * _54;
  float _58 = _57 + 1.0f;
  float _59 = log2(_58);
  float _60 = _40.x + TEXCOORD.z;
  float _61 = _50 + TEXCOORD.w;
  float _62 = _40.x + TEXCOORD.x;
  float _63 = _50 + TEXCOORD.y;
  float _67 = 0.5f - (PostProcess.Settings[19].x);
  float _68 = 0.5f - (PostProcess.Settings[19].y);
  float _69 = _67 + _60;
  float _70 = _68 + _61;
  float _71 = _69 * 2.0f;
  float _72 = _70 * 2.0f;
  float _73 = _71 + -1.0f;
  float _74 = _72 + -1.0f;
  float _78 = _74 * (Global.Global.c[51].y);
  float _79 = abs(_73);
  float _80 = abs(_74);
  float _82 = (PostProcess.Settings[19].z) * 2.0f;
  float _83 = _82 + -1.0f;
  float _84 = _79 - _83;
  float _85 = _80 - _83;
  float _86 = saturate(_84);
  float _87 = saturate(_85);
  float _88 = _86 * (Global.Global.c[51].x);
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
  float _114 = (PostProcess.Settings[2].w) * _94;
  float _115 = _111 * _111;
  float _116 = _115 * _114;
  float _117 = _116 * _108;
  float _118 = _117 * _113;
  float _120 = (PostProcess.Settings[2].z) * _89;
  float _121 = (PostProcess.Settings[2].z) * _90;
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
  float4 _134 = s0.SampleLevel(sLinearClampSampler, float2(_126, _122), _131);
  float4 _136 = s0.SampleLevel(sLinearClampSampler, float2(_123, _128), _131);
  float4 _138 = s0.SampleLevel(sLinearClampSampler, float2(_60, _61), _131);
  float _141 = max(_134.x, 0.0f);
  float _142 = max(_136.y, 0.0f);
  float _143 = max(_138.z, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_141, _142, _143),
      max(_138.rgb, 0.f.xxx),
      float2(_60, _61),
      s0,
      sLinearClampSampler,
      _131);
  _141 = renodx_chromatic_aberration_input.x;
  _142 = renodx_chromatic_aberration_input.y;
  _143 = renodx_chromatic_aberration_input.z;
  int _146 = asint((User.c[7].z));
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
  float _807;
  float _911;
  float _1015;
  float _1018;
  float _1019;
  float _1020;
  float _1031;
  float _1156;
  float _1157;
  float _1158;
  float _1205;
  float _1206;
  float _1207;
  float _1221;
  float _1222;
  float _1223;
  float _1279;
  [branch]
  if (_147) {
    bool _152 = ((PostProcess.Settings[7].x) > 0.0f);
    if (_152) {
      float _154 = _40.x + TEXCOORD.x;
      float _155 = _50 + TEXCOORD.y;
      float4 _158 = s2.SampleLevel(s2Sampler, float2(_154, _155), 0.0f);
      bool _162 = ((PostProcess.Settings[6].y) == 1.0f);
      if (_162) {
        float4 _165 = s7.Load(int3(0, 0, 0));
        float _170 = _165.x - (Global.Proj.m[0][2].z);
        float _171 = (Global.Proj.m[0][2].w) / _170;
        _176 = _171;
      } else {
        _176 = (PostProcess.Settings[5].x);
      }
      float _180 = _158.x - (Global.Proj.m[0][2].z);
      float _181 = (Global.Proj.m[0][2].w) / _180;
      float _183 = _176 * (PostProcess.Settings[6].w);
      float _184 = _183 + _176;
      float _185 = _176 - _183;
      float _186 = max(_181, _185);
      float _187 = min(_186, _184);
      float _190 = _181 - _187;
      float _191 = (PostProcess.Settings[5].w) * _190;
      float _193 = _187 - (PostProcess.Settings[5].y);
      float _194 = _193 * _181;
      float _195 = _191 / _194;
      float _196 = min(_195, 0.0f);
      float _198 = _183 + 1.0f;
      float _199 = 1.0f / _198;
      float _200 = _196 * (PostProcess.Settings[7].z);
      float _201 = max(0.0f, _195);
      float _204 = (PostProcess.Settings[18].x) * _201;
      float _205 = _204 + _200;
      float _206 = _205 * _199;
      float _207 = max(_206, -1.0f);
      float _208 = min(_207, 1.0f);
      float _209 = max(_208, -0.30000001192092896f);
      float _210 = min(_209, 1.0f);
      float _212 = -0.0f - (PostProcess.Settings[6].x);
      float _213 = _210 * _212;
      float _214 = _154 + -0.5f;
      float _215 = _155 + -0.5f;
      float _216 = _214 * _214;
      float _217 = _215 * _215;
      float _218 = _217 + _216;
      float _219 = sqrt(_218);
      float _220 = log2(_219);
      float _221 = _220 * (PostProcess.Settings[7].y);
      float _222 = exp2(_221);
      float _223 = _222 * (PostProcess.Settings[7].x);
      float _224 = dot(float2(_214, _215), float2(_214, _215));
      float _225 = rsqrt(_224);
      float _226 = _225 * _214;
      float _227 = _225 * _215;
      float _228 = abs(_213);
      float _232 = _223 * _228;
      float _233 = -0.0f - _232;
      float _234 = (User.c[2].x) * _226;
      float _235 = _234 * _233;
      float _236 = (User.c[2].y) * _227;
      float _237 = _236 * _233;
      float _238 = _228 * _223;
      float _239 = _234 * _238;
      float _240 = _236 * _238;
      float _241 = _239 + _154;
      float _242 = _240 + _155;
      float _243 = _235 + _126;
      float _244 = _237 + _122;
      float4 _245 = s0.SampleLevel(sLinearClampSampler, float2(_243, _244), _131);
      float4 _247 = s0.SampleLevel(sLinearClampSampler, float2(_241, _242), _131);
      float4 _249 = s2.SampleLevel(s2Sampler, float2(_243, _244), 0.0f);
      if (_162) {
        float4 _253 = s7.Load(int3(0, 0, 0));
        float _255 = _253.x - (Global.Proj.m[0][2].z);
        float _256 = (Global.Proj.m[0][2].w) / _255;
        _260 = _256;
      } else {
        _260 = (PostProcess.Settings[5].x);
      }
      float _261 = _249.x - (Global.Proj.m[0][2].z);
      float _262 = (Global.Proj.m[0][2].w) / _261;
      float _263 = _260 * (PostProcess.Settings[6].w);
      float _264 = _263 + _260;
      float _265 = _260 - _263;
      float _266 = max(_262, _265);
      float _267 = min(_266, _264);
      float _268 = _262 - _267;
      float _269 = _268 * (PostProcess.Settings[5].w);
      float _270 = _267 - (PostProcess.Settings[5].y);
      float _271 = _270 * _262;
      float _272 = _269 / _271;
      float _273 = min(_272, 0.0f);
      float _274 = _263 + 1.0f;
      float _275 = 1.0f / _274;
      float _276 = _273 * (PostProcess.Settings[7].z);
      float _277 = max(0.0f, _272);
      float _278 = _277 * (PostProcess.Settings[18].x);
      float _279 = _278 + _276;
      float _280 = _279 * _275;
      float _281 = max(_280, -1.0f);
      float _282 = min(_281, 1.0f);
      float _283 = max(_282, -0.30000001192092896f);
      float _284 = min(_283, 1.0f);
      float _285 = _284 * _212;
      float4 _286 = s2.SampleLevel(s2Sampler, float2(_241, _242), 0.0f);
      if (_162) {
        float4 _290 = s7.Load(int3(0, 0, 0));
        float _292 = _290.x - (Global.Proj.m[0][2].z);
        float _293 = (Global.Proj.m[0][2].w) / _292;
        _297 = _293;
      } else {
        _297 = (PostProcess.Settings[5].x);
      }
      float _298 = _286.x - (Global.Proj.m[0][2].z);
      float _299 = (Global.Proj.m[0][2].w) / _298;
      float _300 = _297 * (PostProcess.Settings[6].w);
      float _301 = _300 + _297;
      float _302 = _297 - _300;
      float _303 = max(_299, _302);
      float _304 = min(_303, _301);
      float _305 = _299 - _304;
      float _306 = _305 * (PostProcess.Settings[5].w);
      float _307 = _304 - (PostProcess.Settings[5].y);
      float _308 = _307 * _299;
      float _309 = _306 / _308;
      float _310 = min(_309, 0.0f);
      float _311 = _300 + 1.0f;
      float _312 = 1.0f / _311;
      float _313 = _310 * (PostProcess.Settings[7].z);
      float _314 = max(0.0f, _309);
      float _315 = _314 * (PostProcess.Settings[18].x);
      float _316 = _315 + _313;
      float _317 = _316 * _312;
      float _318 = max(_317, -1.0f);
      float _319 = min(_318, 1.0f);
      float _320 = max(_319, -0.30000001192092896f);
      float _321 = min(_320, 1.0f);
      float _322 = _321 * _212;
      float _323 = abs(_285);
      float _324 = _323 / (PostProcess.Settings[6].x);
      float _325 = ceil(_324);
      float _326 = saturate(_325);
      float _327 = _245.x - _141;
      float _328 = _326 * _327;
      float _329 = _328 + _141;
      float _330 = abs(_322);
      float _331 = _330 / (PostProcess.Settings[6].x);
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
    int _339 = asint((User.c[7].y));
    bool _340 = ((int)_339 > (int)0);
    if (_340) {
      float _342 = _40.x + TEXCOORD.x;
      float _343 = _50 + TEXCOORD.y;
      float4 _346 = s4.Sample(s4Sampler, float2(_342, _343));
      float4 _353 = s5.Sample(s5Sampler, float2(_342, _343));
      float _357 = (PostProcess.Settings[6].x) * _353.x;
      float _361 = _357 * (PostProcess.Settings[7].x);
      float _362 = _357 * (PostProcess.Settings[7].y);
      float _363 = _361 + _342;
      float _364 = _362 + _343;
      float4 _365 = s4.Sample(s4Sampler, float2(_363, _364));
      float4 _367 = s5.Sample(s5Sampler, float2(_363, _364));
      float _369 = _367.x * (PostProcess.Settings[6].x);
      float _370 = abs(_369);
      float _372 = _370 / (PostProcess.Settings[7].w);
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
      int _387 = asint((User.c[7].x));
      bool _388 = ((int)_387 > (int)0);
      [branch]
      if (_388) {
        float4 _392 = s7.Sample(s7Sampler, float2(TEXCOORD.x, TEXCOORD.y));
        float _394 = abs(_392.x);
        _487 = _394;
      } else {
        float4 _398 = s2.SampleLevel(s2Sampler, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _400 = TEXCOORD.x * 2.0f;
        float _401 = TEXCOORD.y * 2.0f;
        float _402 = _400 + -1.0f;
        float _403 = _401 + -1.0f;
        float _424 = (Global.Proj.m[0][8].x) * _402;
        float _425 = mad(_403, (Global.Proj.m[0][8].y), _424);
        float _426 = mad(_398.x, (Global.Proj.m[0][8].z), _425);
        float _427 = _426 + (Global.Proj.m[0][8].w);
        float _428 = (Global.Proj.m[0][9].x) * _402;
        float _429 = mad(_403, (Global.Proj.m[0][9].y), _428);
        float _430 = mad(_398.x, (Global.Proj.m[0][9].z), _429);
        float _431 = _430 + (Global.Proj.m[0][9].w);
        float _432 = (Global.Proj.m[0][10].x) * _402;
        float _433 = mad(_403, (Global.Proj.m[0][10].y), _432);
        float _434 = mad(_398.x, (Global.Proj.m[0][10].z), _433);
        float _435 = _434 + (Global.Proj.m[0][10].w);
        float _436 = (Global.Proj.m[0][11].x) * _402;
        float _437 = mad(_403, (Global.Proj.m[0][11].y), _436);
        float _438 = mad(_398.x, (Global.Proj.m[0][11].z), _437);
        float _439 = _438 + (Global.Proj.m[0][11].w);
        float _440 = _427 / _439;
        float _441 = _431 / _439;
        float _442 = _435 / _439;
        float _443 = _440 * _440;
        float _444 = _441 * _441;
        float _445 = _444 + _443;
        float _446 = _442 * _442;
        float _447 = _445 + _446;
        float _448 = sqrt(_447);
        float4 _451 = s5.Sample(s5Sampler, float2(TEXCOORD.x, TEXCOORD.y));
        float _457 = (PostProcess.Settings[6].w) * (PostProcess.Settings[5].x);
        float _458 = _457 + (PostProcess.Settings[5].x);
        float _459 = (PostProcess.Settings[5].x) - _457;
        float _460 = max(_448, _459);
        float _461 = min(_460, _458);
        float _463 = _448 - _461;
        float _464 = _463 * (PostProcess.Settings[5].w);
        float _466 = _461 - (PostProcess.Settings[5].y);
        float _467 = _466 * _448;
        float _468 = _464 / _467;
        float _469 = min(_468, 0.0f);
        float _472 = _457 + 1.0f;
        float _473 = 1.0f / _472;
        float _474 = (PostProcess.Settings[7].z) * _469;
        float _475 = max(0.0f, _468);
        float _478 = (PostProcess.Settings[18].x) * _475;
        float _479 = _478 + _474;
        float _480 = _479 * _473;
        float _481 = min(_451.x, _480);
        float _482 = abs(_481);
        float _483 = abs(_480);
        float _484 = max(_482, _483);
        float _485 = saturate(_484);
        _487 = _485;
      }
      float _490 = (PostProcess.Settings[6].x) * _487;
      float4 _493 = s4.Sample(s4Sampler, float2(TEXCOORD.x, TEXCOORD.y));
      float _500 = (PostProcess.Settings[7].x) * _490;
      float _501 = (PostProcess.Settings[7].y) * _490;
      float _502 = _500 + TEXCOORD.x;
      float _503 = _501 + TEXCOORD.y;
      float4 _504 = s4.Sample(s4Sampler, float2(_502, _503));
      float4 _508 = s5.Sample(s5Sampler, float2(_502, _503));
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
  float4 _530 = s12_bloom.SampleLevel(sLinearClampSampler, float2(_60, _61), 0.0f);
  float4 _536 = s8.Sample(s8Sampler, float2(_62, _63));
  bool _542 = !((PostProcess.Settings[17].z) >= -1.0f);
  float _546 = (PostProcess.Settings[4].w) * _536.x;
  float _547 = (PostProcess.Settings[4].w) * _536.y;
  float _548 = (PostProcess.Settings[4].w) * _536.z;
  float _549 = _546 + (PostProcess.Settings[4].z);
  float _550 = _547 + (PostProcess.Settings[4].z);
  float _551 = _548 + (PostProcess.Settings[4].z);
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
  float4 _576 = sExposureScale.Load(int3(0, 0, 0));
  float _582 = _576.x * (Global.Global.c[87].y);
  float _583 = _582 * _570;
  float _584 = _583 * (PostProcess.Settings[14].x);
  float _585 = _582 * _571;
  float _586 = _585 * (PostProcess.Settings[14].y);
  float _587 = _582 * _572;
  float _588 = _587 * (PostProcess.Settings[14].z);
  float _593 = _60 * 2.0f;
  float _594 = _61 * 2.0f;
  float _595 = _593 + -1.0f;
  float _596 = _594 + -1.0f;
  float _599 = (PostProcess.Settings[13].w) * _596;
  float _600 = _595 * _595;
  float _601 = _599 * _599;
  float _602 = _601 + _600;
  float _603 = sqrt(_602);
  float _605 = (PostProcess.Settings[13].x) * _603;
  float _607 = _605 + (PostProcess.Settings[13].y);
  float _608 = saturate(_607);
  float _610 = log2(_608);
  float _611 = _610 * (PostProcess.Settings[13].z);
  float _612 = exp2(_611);
  float _613 = _584 * (PostProcess.Settings[12].x);
  float _614 = _586 * (PostProcess.Settings[12].y);
  float _615 = _588 * (PostProcess.Settings[12].z);
  float _616 = _613 - _584;
  float _617 = _614 - _586;
  float _618 = _615 - _588;
  float _619 = _612 * _616;
  float _620 = _612 * _617;
  float _621 = _612 * _618;
  float _622 = _619 + _584;
  float _623 = _620 + _586;
  float _624 = _621 + _588;
  float _627 = (PostProcess.Settings[10].w) * 1.1190600395202637f;
  float _628 = _627 * _622;
  float _629 = _627 * _623;
  float _630 = _627 * _624;
  float _631 = _628 + 1.0f;
  float _632 = _629 + 1.0f;
  float _633 = _630 + 1.0f;
  float _634 = log2(_631);
  float _635 = log2(_632);
  float _636 = log2(_633);
  float _639 = (PostProcess.OffsetWeight[0].x) * 0.07434873282909393f;
  float _640 = _639 * _634;
  float _641 = _639 * _635;
  float _642 = _639 * _636;
  float _644 = _640 + (PostProcess.OffsetWeight[0].y);
  float _645 = _641 + (PostProcess.OffsetWeight[0].y);
  float _646 = _642 + (PostProcess.OffsetWeight[0].y);
  float4 _649 = s3_3D.Sample(s3_3DSampler, float3(_644, _645, _646));
  float _655 = _649.x * 13.450128555297852f;
  float _656 = _649.y * 13.450128555297852f;
  float _657 = _649.z * 13.450128555297852f;
  float _658 = exp2(_655);
  float _659 = exp2(_656);
  float _660 = exp2(_657);
  float _661 = _658 + -1.0f;
  float _662 = _659 + -1.0f;
  float _663 = _660 + -1.0f;
  float _664 = 0.8936070799827576f / (PostProcess.Settings[10].w);
  float _665 = _664 * _661;
  float _666 = _664 * _662;
  float _667 = _664 * _663;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_628 * _664, _629 * _664, _630 * _664),
      float3(_665, _666, _667),
      1.f.xxx);
  _665 = apt_scaled_lut_output.x;
  _666 = apt_scaled_lut_output.y;
  _667 = apt_scaled_lut_output.z;
  bool _670 = ((User.c[3].x) > 0.0f) && !APTIsPsychoV();
  if (_670) {
    float _672 = (PostProcess.Settings[10].w) * 1.1190600395202637f;
    float _673 = _665 * _672;
    float _674 = _666 * _672;
    float _675 = _667 * _672;
    float _676 = _673 + 1.0f;
    float _677 = _674 + 1.0f;
    float _678 = _675 + 1.0f;
    float _679 = log2(_676);
    float _680 = log2(_677);
    float _681 = log2(_678);
    float _682 = _679 * 0.07434873282909393f;
    float _683 = _680 * 0.07434873282909393f;
    float _684 = _681 * 0.07434873282909393f;
    int _686 = asint((User.c[3].y));
    int _687 = _686 & 1;
    bool _688 = (_687 == 0);
    if (!_688) {
      bool _705 = !(_682 <= (User.c[4].x));
      if (!_705) {
        float _707 = max(9.999999974752427e-07f, (User.c[4].x));
        float _708 = _682 / _707;
        float _709 = _708 * (User.c[4].y);
        float _710 = _708 * _708;
        float _711 = _710 * _708;
        float _712 = _711 - _708;
        float _713 = (User.c[10].x) * 0.1666666716337204f;
        float _714 = _707 * _707;
        float _715 = _714 * _713;
        float _716 = _715 * _712;
        float _717 = _716 + _709;
        _807 = _717;
      } else {
        bool _719 = !(_682 <= (User.c[4].z));
        if (!_719) {
          float _721 = (User.c[4].z) - (User.c[4].x);
          float _722 = max(9.999999974752427e-07f, _721);
          float _723 = _682 - (User.c[4].x);
          float _724 = _723 / _722;
          float _725 = 1.0f - _724;
          float _726 = _725 * (User.c[4].y);
          float _727 = _724 * (User.c[4].w);
          float _728 = _726 + _727;
          float _729 = _725 * _725;
          float _730 = _729 * _725;
          float _731 = _730 - _725;
          float _732 = _731 * (User.c[10].x);
          float _733 = _724 * _724;
          float _734 = _733 * _724;
          float _735 = _734 - _724;
          float _736 = _735 * (User.c[10].y);
          float _737 = _732 + _736;
          float _738 = _722 * _722;
          float _739 = _738 * 0.1666666716337204f;
          float _740 = _739 * _737;
          float _741 = _728 + _740;
          _807 = _741;
        } else {
          bool _743 = !(_682 <= (User.c[9].x));
          if (!_743) {
            float _745 = (User.c[9].x) - (User.c[4].z);
            float _746 = max(9.999999974752427e-07f, _745);
            float _747 = _682 - (User.c[4].z);
            float _748 = _747 / _746;
            float _749 = 1.0f - _748;
            float _750 = _749 * (User.c[4].w);
            float _751 = _748 * (User.c[9].y);
            float _752 = _750 + _751;
            float _753 = _749 * _749;
            float _754 = _753 * _749;
            float _755 = _754 - _749;
            float _756 = _755 * (User.c[10].y);
            float _757 = _748 * _748;
            float _758 = _757 * _748;
            float _759 = _758 - _748;
            float _760 = _759 * (User.c[10].z);
            float _761 = _756 + _760;
            float _762 = _746 * _746;
            float _763 = _762 * 0.1666666716337204f;
            float _764 = _763 * _761;
            float _765 = _752 + _764;
            _807 = _765;
          } else {
            bool _767 = !(_682 <= (User.c[9].z));
            if (!_767) {
              float _769 = (User.c[9].z) - (User.c[9].x);
              float _770 = max(9.999999974752427e-07f, _769);
              float _771 = _682 - (User.c[9].x);
              float _772 = _771 / _770;
              float _773 = 1.0f - _772;
              float _774 = _773 * (User.c[9].y);
              float _775 = _772 * (User.c[9].w);
              float _776 = _774 + _775;
              float _777 = _773 * _773;
              float _778 = _777 * _773;
              float _779 = _778 - _773;
              float _780 = _779 * (User.c[10].z);
              float _781 = _772 * _772;
              float _782 = _781 * _772;
              float _783 = _782 - _772;
              float _784 = _783 * (User.c[10].w);
              float _785 = _780 + _784;
              float _786 = _770 * _770;
              float _787 = _786 * 0.1666666716337204f;
              float _788 = _787 * _785;
              float _789 = _776 + _788;
              _807 = _789;
            } else {
              float _791 = 1.0f - (User.c[9].z);
              float _792 = _682 - (User.c[9].z);
              float _793 = max(9.999999974752427e-07f, _791);
              float _794 = _792 / _793;
              float _795 = 1.0f - _794;
              float _796 = _795 * (User.c[9].w);
              float _797 = _796 + _794;
              float _798 = _795 * _795;
              float _799 = _798 * _795;
              float _800 = _799 - _795;
              float _801 = (User.c[10].w) * 0.1666666716337204f;
              float _802 = _791 * _791;
              float _803 = _802 * _801;
              float _804 = _803 * _800;
              float _805 = _797 + _804;
              _807 = _805;
            }
          }
        }
      }
      float _808 = saturate(_807);
      bool _809 = !(_683 <= (User.c[4].x));
      if (!_809) {
        float _811 = max(9.999999974752427e-07f, (User.c[4].x));
        float _812 = _683 / _811;
        float _813 = _812 * (User.c[4].y);
        float _814 = _812 * _812;
        float _815 = _814 * _812;
        float _816 = _815 - _812;
        float _817 = (User.c[10].x) * 0.1666666716337204f;
        float _818 = _811 * _811;
        float _819 = _818 * _817;
        float _820 = _819 * _816;
        float _821 = _820 + _813;
        _911 = _821;
      } else {
        bool _823 = !(_683 <= (User.c[4].z));
        if (!_823) {
          float _825 = (User.c[4].z) - (User.c[4].x);
          float _826 = max(9.999999974752427e-07f, _825);
          float _827 = _683 - (User.c[4].x);
          float _828 = _827 / _826;
          float _829 = 1.0f - _828;
          float _830 = _829 * (User.c[4].y);
          float _831 = _828 * (User.c[4].w);
          float _832 = _830 + _831;
          float _833 = _829 * _829;
          float _834 = _833 * _829;
          float _835 = _834 - _829;
          float _836 = _835 * (User.c[10].x);
          float _837 = _828 * _828;
          float _838 = _837 * _828;
          float _839 = _838 - _828;
          float _840 = _839 * (User.c[10].y);
          float _841 = _836 + _840;
          float _842 = _826 * _826;
          float _843 = _842 * 0.1666666716337204f;
          float _844 = _843 * _841;
          float _845 = _832 + _844;
          _911 = _845;
        } else {
          bool _847 = !(_683 <= (User.c[9].x));
          if (!_847) {
            float _849 = (User.c[9].x) - (User.c[4].z);
            float _850 = max(9.999999974752427e-07f, _849);
            float _851 = _683 - (User.c[4].z);
            float _852 = _851 / _850;
            float _853 = 1.0f - _852;
            float _854 = _853 * (User.c[4].w);
            float _855 = _852 * (User.c[9].y);
            float _856 = _854 + _855;
            float _857 = _853 * _853;
            float _858 = _857 * _853;
            float _859 = _858 - _853;
            float _860 = _859 * (User.c[10].y);
            float _861 = _852 * _852;
            float _862 = _861 * _852;
            float _863 = _862 - _852;
            float _864 = _863 * (User.c[10].z);
            float _865 = _860 + _864;
            float _866 = _850 * _850;
            float _867 = _866 * 0.1666666716337204f;
            float _868 = _867 * _865;
            float _869 = _856 + _868;
            _911 = _869;
          } else {
            bool _871 = !(_683 <= (User.c[9].z));
            if (!_871) {
              float _873 = (User.c[9].z) - (User.c[9].x);
              float _874 = max(9.999999974752427e-07f, _873);
              float _875 = _683 - (User.c[9].x);
              float _876 = _875 / _874;
              float _877 = 1.0f - _876;
              float _878 = _877 * (User.c[9].y);
              float _879 = _876 * (User.c[9].w);
              float _880 = _878 + _879;
              float _881 = _877 * _877;
              float _882 = _881 * _877;
              float _883 = _882 - _877;
              float _884 = _883 * (User.c[10].z);
              float _885 = _876 * _876;
              float _886 = _885 * _876;
              float _887 = _886 - _876;
              float _888 = _887 * (User.c[10].w);
              float _889 = _884 + _888;
              float _890 = _874 * _874;
              float _891 = _890 * 0.1666666716337204f;
              float _892 = _891 * _889;
              float _893 = _880 + _892;
              _911 = _893;
            } else {
              float _895 = 1.0f - (User.c[9].z);
              float _896 = _683 - (User.c[9].z);
              float _897 = max(9.999999974752427e-07f, _895);
              float _898 = _896 / _897;
              float _899 = 1.0f - _898;
              float _900 = _899 * (User.c[9].w);
              float _901 = _900 + _898;
              float _902 = _899 * _899;
              float _903 = _902 * _899;
              float _904 = _903 - _899;
              float _905 = (User.c[10].w) * 0.1666666716337204f;
              float _906 = _895 * _895;
              float _907 = _906 * _905;
              float _908 = _907 * _904;
              float _909 = _901 + _908;
              _911 = _909;
            }
          }
        }
      }
      float _912 = saturate(_911);
      bool _913 = !(_684 <= (User.c[4].x));
      if (!_913) {
        float _915 = max(9.999999974752427e-07f, (User.c[4].x));
        float _916 = _684 / _915;
        float _917 = _916 * (User.c[4].y);
        float _918 = _916 * _916;
        float _919 = _918 * _916;
        float _920 = _919 - _916;
        float _921 = (User.c[10].x) * 0.1666666716337204f;
        float _922 = _915 * _915;
        float _923 = _922 * _921;
        float _924 = _923 * _920;
        float _925 = _924 + _917;
        _1015 = _925;
      } else {
        bool _927 = !(_684 <= (User.c[4].z));
        if (!_927) {
          float _929 = (User.c[4].z) - (User.c[4].x);
          float _930 = max(9.999999974752427e-07f, _929);
          float _931 = _684 - (User.c[4].x);
          float _932 = _931 / _930;
          float _933 = 1.0f - _932;
          float _934 = _933 * (User.c[4].y);
          float _935 = _932 * (User.c[4].w);
          float _936 = _934 + _935;
          float _937 = _933 * _933;
          float _938 = _937 * _933;
          float _939 = _938 - _933;
          float _940 = _939 * (User.c[10].x);
          float _941 = _932 * _932;
          float _942 = _941 * _932;
          float _943 = _942 - _932;
          float _944 = _943 * (User.c[10].y);
          float _945 = _940 + _944;
          float _946 = _930 * _930;
          float _947 = _946 * 0.1666666716337204f;
          float _948 = _947 * _945;
          float _949 = _936 + _948;
          _1015 = _949;
        } else {
          bool _951 = !(_684 <= (User.c[9].x));
          if (!_951) {
            float _953 = (User.c[9].x) - (User.c[4].z);
            float _954 = max(9.999999974752427e-07f, _953);
            float _955 = _684 - (User.c[4].z);
            float _956 = _955 / _954;
            float _957 = 1.0f - _956;
            float _958 = _957 * (User.c[4].w);
            float _959 = _956 * (User.c[9].y);
            float _960 = _958 + _959;
            float _961 = _957 * _957;
            float _962 = _961 * _957;
            float _963 = _962 - _957;
            float _964 = _963 * (User.c[10].y);
            float _965 = _956 * _956;
            float _966 = _965 * _956;
            float _967 = _966 - _956;
            float _968 = _967 * (User.c[10].z);
            float _969 = _964 + _968;
            float _970 = _954 * _954;
            float _971 = _970 * 0.1666666716337204f;
            float _972 = _971 * _969;
            float _973 = _960 + _972;
            _1015 = _973;
          } else {
            bool _975 = !(_684 <= (User.c[9].z));
            if (!_975) {
              float _977 = (User.c[9].z) - (User.c[9].x);
              float _978 = max(9.999999974752427e-07f, _977);
              float _979 = _684 - (User.c[9].x);
              float _980 = _979 / _978;
              float _981 = 1.0f - _980;
              float _982 = _981 * (User.c[9].y);
              float _983 = _980 * (User.c[9].w);
              float _984 = _982 + _983;
              float _985 = _981 * _981;
              float _986 = _985 * _981;
              float _987 = _986 - _981;
              float _988 = _987 * (User.c[10].z);
              float _989 = _980 * _980;
              float _990 = _989 * _980;
              float _991 = _990 - _980;
              float _992 = _991 * (User.c[10].w);
              float _993 = _988 + _992;
              float _994 = _978 * _978;
              float _995 = _994 * 0.1666666716337204f;
              float _996 = _995 * _993;
              float _997 = _984 + _996;
              _1015 = _997;
            } else {
              float _999 = 1.0f - (User.c[9].z);
              float _1000 = _684 - (User.c[9].z);
              float _1001 = max(9.999999974752427e-07f, _999);
              float _1002 = _1000 / _1001;
              float _1003 = 1.0f - _1002;
              float _1004 = _1003 * (User.c[9].w);
              float _1005 = _1004 + _1002;
              float _1006 = _1003 * _1003;
              float _1007 = _1006 * _1003;
              float _1008 = _1007 - _1003;
              float _1009 = (User.c[10].w) * 0.1666666716337204f;
              float _1010 = _999 * _999;
              float _1011 = _1010 * _1009;
              float _1012 = _1011 * _1008;
              float _1013 = _1005 + _1012;
              _1015 = _1013;
            }
          }
        }
      }
      float _1016 = saturate(_1015);
      _1018 = _808;
      _1019 = _912;
      _1020 = _1016;
    } else {
      _1018 = _682;
      _1019 = _683;
      _1020 = _684;
    }
    int _1021 = _686 & 2;
    bool _1022 = (_1021 == 0);
    if (!_1022) {
      float _1024 = sqrt(_1018);
      float _1025 = sqrt(_1019);
      float _1026 = sqrt(_1020);
      float _1027 = dot(float3(_1024, _1025, _1026), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1028 = 1.0f - _1027;
      float _1029 = saturate(_1028);
      _1031 = _1029;
    } else {
      _1031 = 1.0f;
    }
    int _1032 = _686 & 8;
    bool _1033 = (_1032 == 0);
    if (_1033) {
      int _1035 = _686 & 4;
      bool _1036 = (_1035 == 0);
      if (!_1036) {
        int _1038 = _686 & 16;
        bool _1039 = (_1038 == 0);
        if (!_1039) {
          float _1043 = (User.c[5].x) * 0.5f;
          float _1044 = _1043 + 0.5f;
          bool _1045 = (_1044 < 0.5f);
          float _1046 = (User.c[5].x) * 5.0f;
          float _1047 = select(_1045, (User.c[5].x), _1046);
          bool _1048 = (_1019 < _1020);
          float _1049 = select(_1048, _1020, _1019);
          float _1050 = select(_1048, _1019, _1020);
          bool _1051 = (_1018 < _1049);
          float _1052 = select(_1051, _1049, _1018);
          float _1053 = select(_1051, _1018, _1049);
          float _1054 = min(_1053, _1050);
          float _1055 = _1052 - _1054;
          float _1056 = _1052 + 1.000000013351432e-10f;
          float _1057 = _1055 / _1056;
          float _1059 = _1057 - (User.c[5].y);
          float _1060 = saturate(_1059);
          float _1061 = max(_1060, 9.999999974752427e-07f);
          float _1062 = log2(_1061);
          float _1063 = _1062 * _1047;
          float _1064 = exp2(_1063);
          float _1065 = 2.0f - _1064;
          float _1067 = 1.0f - (User.c[5].z);
          float _1068 = saturate(_1067);
          float _1069 = max(_1068, _1065);
          float _1070 = dot(float3(_1018, _1019, _1020), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1071 = _1018 - _1070;
          float _1072 = _1019 - _1070;
          float _1073 = _1020 - _1070;
          float _1074 = _1071 * _1069;
          float _1075 = _1072 * _1069;
          float _1076 = _1073 * _1069;
          float _1077 = _1070 - _1018;
          float _1078 = _1077 + _1074;
          float _1079 = _1070 - _1019;
          float _1080 = _1079 + _1075;
          float _1081 = _1070 - _1020;
          float _1082 = _1081 + _1076;
          float _1083 = _1078 * _1031;
          float _1084 = _1080 * _1031;
          float _1085 = _1082 * _1031;
          float _1086 = _1083 + _1018;
          float _1087 = _1084 + _1019;
          float _1088 = _1085 + _1020;
          _1205 = _1086;
          _1206 = _1087;
          _1207 = _1088;
        } else {
          bool _1090 = (_1031 == 0.0f);
          if (!_1090) {
            float _1094 = abs(User.c[5].x);
            float _1095 = saturate(_1094);
            uint4 _1097 = 0u; sVibranceLUT.GetDimensions(0u, _1097.x, _1097.y, _1097.w);
            float _1100 = float((uint)_1097.y);
            int _1101 = _686 & 32;
            bool _1102 = (_1101 == 0);
            float _1103 = _1100 + -1.0f;
            if (!_1102) {
              float _1105 = 1.0f / _1103;
              uint _1106 = uint(SV_Position.x);
              uint _1107 = uint(SV_Position.y);
              int _1108 = _1106 & 63;
              int _1109 = _1107 & 63;
              float4 _1111 = sBlueNoiseR8G8.Load(int4(_1108, _1109, 0, 0));
              float _1114 = _1111.x + -0.5f;
              float _1115 = _1018 * 13.999999046325684f;
              float _1116 = _1019 * 13.999999046325684f;
              float _1117 = _1020 * 13.999999046325684f;
              float _1118 = saturate(_1115);
              float _1119 = saturate(_1116);
              float _1120 = saturate(_1117);
              float _1121 = _1018 + -0.9285714030265808f;
              float _1122 = _1019 + -0.9285714030265808f;
              float _1123 = _1020 + -0.9285714030265808f;
              float _1124 = _1121 * 13.999999046325684f;
              float _1125 = _1122 * 13.999999046325684f;
              float _1126 = _1123 * 13.999999046325684f;
              float _1127 = saturate(_1124);
              float _1128 = saturate(_1125);
              float _1129 = saturate(_1126);
              float _1130 = 1.0f - _1127;
              float _1131 = 1.0f - _1128;
              float _1132 = 1.0f - _1129;
              float _1133 = min(_1118, _1130);
              float _1134 = min(_1119, _1131);
              float _1135 = min(_1120, _1132);
              float _1136 = _1111.y + -0.5f;
              float _1137 = _1133 * _1136;
              float _1138 = _1134 * _1136;
              float _1139 = _1135 * _1136;
              float _1140 = _1137 + _1114;
              float _1141 = _1138 + _1114;
              float _1142 = _1139 + _1114;
              float _1143 = _1140 * _1105;
              float _1144 = _1141 * _1105;
              float _1145 = _1142 * _1105;
              float _1146 = _1143 + _1018;
              float _1147 = _1144 + _1019;
              float _1148 = _1145 + _1020;
              float _1149 = saturate(_1146);
              float _1150 = saturate(_1147);
              float _1151 = saturate(_1148);
              float _1152 = saturate(_1149);
              float _1153 = saturate(_1150);
              float _1154 = saturate(_1151);
              _1156 = _1152;
              _1157 = _1153;
              _1158 = _1154;
            } else {
              _1156 = _1018;
              _1157 = _1019;
              _1158 = _1020;
            }
            float _1159 = float((uint)_1097.x);
            float _1160 = _1103 / _1159;
            float _1161 = _1160 * _1156;
            float _1162 = 0.5f / _1159;
            float _1163 = _1161 + _1162;
            float _1164 = _1103 / _1100;
            float _1165 = _1164 * _1157;
            float _1166 = 0.5f / _1100;
            float _1167 = _1165 + _1166;
            float _1168 = _1158 * _1103;
            float _1169 = floor(_1168);
            float _1170 = frac(_1168);
            float _1171 = _1169 / _1100;
            float _1172 = _1171 + _1163;
            float _1173 = _1169 + 1.0f;
            float _1174 = _1173 / _1100;
            float _1175 = _1174 + _1163;
            float4 _1177 = sVibranceLUT.Sample(sLinearClampSampler, float2(_1172, _1167));
            float4 _1181 = sVibranceLUT.Sample(sLinearClampSampler, float2(_1175, _1167));
            float _1185 = _1181.x - _1177.x;
            float _1186 = _1181.y - _1177.y;
            float _1187 = _1181.z - _1177.z;
            float _1188 = _1185 * _1170;
            float _1189 = _1186 * _1170;
            float _1190 = _1187 * _1170;
            float _1191 = _1095 * _1031;
            float _1192 = _1177.x - _1018;
            float _1193 = _1192 + _1188;
            float _1194 = _1177.y - _1019;
            float _1195 = _1194 + _1189;
            float _1196 = _1177.z - _1020;
            float _1197 = _1196 + _1190;
            float _1198 = _1193 * _1191;
            float _1199 = _1195 * _1191;
            float _1200 = _1197 * _1191;
            float _1201 = _1198 + _1018;
            float _1202 = _1199 + _1019;
            float _1203 = _1200 + _1020;
            _1205 = _1201;
            _1206 = _1202;
            _1207 = _1203;
          } else {
            _1205 = _1018;
            _1206 = _1019;
            _1207 = _1020;
          }
        }
      } else {
        _1205 = _1018;
        _1206 = _1019;
        _1207 = _1020;
      }
    } else {
      _1205 = _1031;
      _1206 = _1031;
      _1207 = _1031;
    }
    float _1208 = _1205 * 13.450128555297852f;
    float _1209 = _1206 * 13.450128555297852f;
    float _1210 = _1207 * 13.450128555297852f;
    float _1211 = exp2(_1208);
    float _1212 = exp2(_1209);
    float _1213 = exp2(_1210);
    float _1214 = _1211 + -1.0f;
    float _1215 = _1212 + -1.0f;
    float _1216 = _1213 + -1.0f;
    float _1217 = _1214 * _664;
    float _1218 = _1215 * _664;
    float _1219 = _1216 * _664;
    _1221 = _1217;
    _1222 = _1218;
    _1223 = _1219;
  } else {
    _1221 = _665;
    _1222 = _666;
    _1223 = _667;
  }
  float _1228 = (User.c[8].x) * _1221;
  float _1229 = (User.c[8].y) * _1222;
  float _1230 = (User.c[8].z) * _1223;
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3(_1228, _1229, _1230),
      SV_Position.xy);
  float _1235 = (PostProcess.Settings[10].z) * TEXCOORD.x;
  float _1236 = _1235 * (PostProcess.Settings[9].x);
  float _1237 = (PostProcess.Settings[10].z) * TEXCOORD.y;
  float _1238 = _1237 * (PostProcess.Settings[9].y);
  float _1241 = _1236 + (PostProcess.Settings[9].z);
  float _1242 = _1238 + (PostProcess.Settings[9].w);
  float4 _1245 = s9.Sample(s9Sampler, float2(_1241, _1242));
  float _1249 = dot(float3(_1228, _1229, _1230), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _1252 = ((PostProcess.Settings[10].x) > 0.0f);
  int _1255 = asint((Global.Global.c[1].w));
  int _1256 = select(_1252, _1255, 0);
  float _1257 = (PostProcess.Settings[10].z) * SV_Position.x;
  float _1258 = (PostProcess.Settings[10].z) * SV_Position.y;
  uint _1259 = uint(_1257);
  uint _1260 = uint(_1258);
  int _1261 = _1259 & 63;
  int _1262 = _1260 & 63;
  float4 _1264 = sBlueNoiseR8G8.Load(int4(_1261, _1262, _1256, 0));
  bool _1266 = ((PostProcess.Settings[10].z) < 1.0f);
  if (_1266) {
    float _1268 = _1257 * 0.015625f;
    float _1269 = _1258 * 0.015625f;
    float _1270 = float((uint)_1255);
    float _1271 = select(_1252, _1270, 0.0f);
    float4 _1273 = sBlueNoiseR8G8.SampleLevel(sLinearWrapSampler, float3(_1268, _1269, _1271), 0.0f);
    float _1275 = _1264.y - _1273.y;
    float _1276 = _1275 * (PostProcess.Settings[10].z);
    float _1277 = _1276 + _1273.y;
    _1279 = _1277;
  } else {
    _1279 = _1264.y;
  }
  float _1280 = _1245.x * -2.0f;
  float _1281 = _1280 * _1279;
  float _1282 = _1279 * 2.0f;
  float _1283 = _1282 * _1245.y;
  float _1284 = _1282 * _1245.z;
  float _1285 = _1281 + _1245.x;
  float _1286 = _1283 - _1245.y;
  float _1287 = _1284 - _1245.z;
  float _1288 = _1285 * _1245.x;
  float _1289 = _1286 * _1245.y;
  float _1290 = _1287 * _1245.z;
  float _1291 = _1249 + 1.0f;
  float _1292 = _1249 / _1291;
  float _1293 = _1292 + -9.999999747378752e-05f;
  float _1294 = _1293 * 1111.111083984375f;
  float _1295 = saturate(_1294);
  float _1296 = _1295 * 2.0f;
  float _1297 = 3.0f - _1296;
  float _1298 = _1295 * _1295;
  float _1299 = _1298 * _1297;
  bool _1301 = ((PostProcess.Settings[10].y) > 0.0f);
  float _1302 = float((bool)_1301);
  float _1303 = dot(float3(_1288, _1289, _1290), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1304 = _1303 - _1288;
  float _1305 = _1303 - _1289;
  float _1306 = _1303 - _1290;
  float _1307 = _1304 * _1302;
  float _1308 = _1305 * _1302;
  float _1309 = _1306 * _1302;
  float _1310 = _1307 + _1288;
  float _1311 = _1308 + _1289;
  float _1312 = _1309 + _1290;
  float _1316 = (PostProcess.Settings[2].y) - (PostProcess.Settings[2].x);
  float _1317 = _1316 * _1292;
  float _1318 = _1317 + (PostProcess.Settings[2].x);
  float _1319 = _1299 * _1318;
  float _1320 = _1319 * _1310;
  float _1321 = _1319 * _1311;
  float _1322 = _1319 * _1312;
  float _1323 = _1320 + _1228;
  float _1324 = _1321 + _1229;
  float _1325 = _1322 + _1230;
  float _1326 = max(0.0f, _1323);
  float _1327 = max(0.0f, _1324);
  float _1328 = max(0.0f, _1325);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_1326, _1327, _1328),
      apt_perceptual_film_grain);
  _1326 = apt_film_grain_output.x;
  _1327 = apt_film_grain_output.y;
  _1328 = apt_film_grain_output.z;
  float _1331 = (PostProcess.Settings[17].y) + 2.0f;
  float _1332 = log2(_1326);
  float _1333 = _1331 * _1332;
  float _1334 = exp2(_1333);
  float _1335 = _1334 + -1.0f;
  float _1336 = _1326 + -1.0f;
  float _1337 = _1335 / _1336;
  bool _1338 = !(_1326 == 1.0f);
  float _1339 = _1337 + -1.0f;
  float _1340 = _1339 / _1337;
  float _1341 = (PostProcess.Settings[17].y) + 1.0f;
  float _1342 = _1341 / _1331;
  float _1343 = select(_1338, _1340, _1342);
  float _1344 = log2(_1327);
  float _1345 = _1344 * _1331;
  float _1346 = exp2(_1345);
  float _1347 = _1346 + -1.0f;
  float _1348 = _1327 + -1.0f;
  float _1349 = _1347 / _1348;
  bool _1350 = !(_1327 == 1.0f);
  float _1351 = _1349 + -1.0f;
  float _1352 = _1351 / _1349;
  float _1353 = (PostProcess.Settings[17].y) + 1.0f;
  float _1354 = _1353 / _1331;
  float _1355 = select(_1350, _1352, _1354);
  float _1356 = log2(_1328);
  float _1357 = _1356 * _1331;
  float _1358 = exp2(_1357);
  float _1359 = _1358 + -1.0f;
  float _1360 = _1328 + -1.0f;
  float _1361 = _1359 / _1360;
  bool _1362 = !(_1328 == 1.0f);
  float _1363 = _1361 + -1.0f;
  float _1364 = _1363 / _1361;
  float _1365 = (PostProcess.Settings[17].y) + 1.0f;
  float _1366 = _1365 / _1331;
  float _1367 = select(_1362, _1364, _1366);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1326, _1327, _1328),
      float3(_1343, _1355, _1367),
      true);
  float _1368 = apt_post_process_output.x;
  float _1369 = apt_post_process_output.y;
  float _1370 = apt_post_process_output.z;
  float _1371 = log2(_1368);
  float _1372 = log2(_1369);
  float _1373 = log2(_1370);
  float _1374 = _1371 * 0.4166666567325592f;
  float _1375 = _1372 * 0.4166666567325592f;
  float _1376 = _1373 * 0.4166666567325592f;
  float _1377 = exp2(_1374);
  float _1378 = exp2(_1375);
  float _1379 = exp2(_1376);
  float _1380 = _1377 * 1.0549999475479126f;
  float _1381 = _1378 * 1.0549999475479126f;
  float _1382 = _1379 * 1.0549999475479126f;
  float _1383 = _1380 + -0.054999999701976776f;
  float _1384 = _1381 + -0.054999999701976776f;
  float _1385 = _1382 + -0.054999999701976776f;
  float _1386 = _1368 * 12.920000076293945f;
  float _1387 = _1369 * 12.920000076293945f;
  float _1388 = _1370 * 12.920000076293945f;
  bool _1389 = (_1368 <= 0.0031308000907301903f);
  bool _1390 = (_1369 <= 0.0031308000907301903f);
  bool _1391 = (_1370 <= 0.0031308000907301903f);
  float _1392 = select(_1389, _1386, _1383);
  float _1393 = select(_1390, _1387, _1384);
  float _1394 = select(_1391, _1388, _1385);
  uint _1395 = uint(SV_Position.x);
  uint _1396 = uint(SV_Position.y);
  int _1397 = _1395 & 63;
  int _1398 = _1396 & 63;
  float4 _1400 = sBlueNoiseR8.Load(int4(_1397, _1398, _1255, 0));
  float _1402 = _1400.x + -0.5f;
  float _1403 = _1402 * 0.003921568859368563f;
  float _1404 = _1403 + _1392;
  float _1405 = _1403 + _1393;
  float _1406 = _1403 + _1394;
  float _1407 = saturate(_1404);
  float _1408 = saturate(_1405);
  float _1409 = saturate(_1406);
  SV_Target.x = _1407;
  SV_Target.y = _1408;
  SV_Target.z = _1409;
  SV_Target.w = _138.w;
  return SV_Target;
}
