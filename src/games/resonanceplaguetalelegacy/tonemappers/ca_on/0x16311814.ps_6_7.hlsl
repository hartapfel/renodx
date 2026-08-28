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

#include "../../common.hlsli"

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
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
      float3(_141, _142, _143),
      max(_138.rgb, 0.f.xxx),
      float2(_60, _61),
      s0,
      sLinearClampSampler,
      _131);
  _141 = renodx_chromatic_aberration_input.x;
  _142 = renodx_chromatic_aberration_input.y;
  _143 = renodx_chromatic_aberration_input.z;
  float4 _145 = s12_bloom.SampleLevel(sLinearClampSampler, float2(_60, _61), 0.0f);
  float4 _151 = s8.Sample(s8Sampler, float2(_62, _63));
  int _157 = asint((User.c[7].z));
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
  float _850;
  float _954;
  float _1058;
  float _1061;
  float _1062;
  float _1063;
  float _1074;
  float _1199;
  float _1200;
  float _1201;
  float _1248;
  float _1249;
  float _1250;
  float _1264;
  float _1265;
  float _1266;
  float _1322;
  if (!_158) {
    bool _162 = !((PostProcess.Settings[17].z) >= -1.0f);
    float _166 = (PostProcess.Settings[4].w) * _151.x;
    float _167 = (PostProcess.Settings[4].w) * _151.y;
    float _168 = (PostProcess.Settings[4].w) * _151.z;
    float _169 = _166 + (PostProcess.Settings[4].z);
    float _170 = _167 + (PostProcess.Settings[4].z);
    float _171 = _168 + (PostProcess.Settings[4].z);
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
    bool _201 = ((PostProcess.Settings[7].x) > 0.0f);
    if (_201) {
      float _203 = _40.x + TEXCOORD.x;
      float _204 = _50 + TEXCOORD.y;
      float4 _207 = s2.SampleLevel(s2Sampler, float2(_203, _204), 0.0f);
      bool _211 = ((PostProcess.Settings[6].y) == 1.0f);
      if (_211) {
        float4 _214 = s7.Load(int3(0, 0, 0));
        float _219 = _214.x - (Global.Proj.m[0][2].z);
        float _220 = (Global.Proj.m[0][2].w) / _219;
        _225 = _220;
      } else {
        _225 = (PostProcess.Settings[5].x);
      }
      float _229 = _207.x - (Global.Proj.m[0][2].z);
      float _230 = (Global.Proj.m[0][2].w) / _229;
      float _232 = _225 * (PostProcess.Settings[6].w);
      float _233 = _232 + _225;
      float _234 = _225 - _232;
      float _235 = max(_230, _234);
      float _236 = min(_235, _233);
      float _239 = _230 - _236;
      float _240 = (PostProcess.Settings[5].w) * _239;
      float _242 = _236 - (PostProcess.Settings[5].y);
      float _243 = _242 * _230;
      float _244 = _240 / _243;
      float _245 = min(_244, 0.0f);
      float _247 = _232 + 1.0f;
      float _248 = 1.0f / _247;
      float _249 = _245 * (PostProcess.Settings[7].z);
      float _250 = max(0.0f, _244);
      float _253 = (PostProcess.Settings[18].x) * _250;
      float _254 = _253 + _249;
      float _255 = _254 * _248;
      float _256 = max(_255, -1.0f);
      float _257 = min(_256, 1.0f);
      float _258 = max(_257, -0.30000001192092896f);
      float _259 = min(_258, 1.0f);
      float _261 = -0.0f - (PostProcess.Settings[6].x);
      float _262 = _259 * _261;
      float _263 = _203 + -0.5f;
      float _264 = _204 + -0.5f;
      float _265 = _263 * _263;
      float _266 = _264 * _264;
      float _267 = _266 + _265;
      float _268 = sqrt(_267);
      float _269 = log2(_268);
      float _270 = _269 * (PostProcess.Settings[7].y);
      float _271 = exp2(_270);
      float _272 = _271 * (PostProcess.Settings[7].x);
      float _273 = dot(float2(_263, _264), float2(_263, _264));
      float _274 = rsqrt(_273);
      float _275 = _274 * _263;
      float _276 = _274 * _264;
      float _277 = abs(_262);
      float _281 = _272 * _277;
      float _282 = -0.0f - _281;
      float _283 = (User.c[2].x) * _275;
      float _284 = _283 * _282;
      float _285 = (User.c[2].y) * _276;
      float _286 = _285 * _282;
      float _287 = _277 * _272;
      float _288 = _283 * _287;
      float _289 = _285 * _287;
      float _290 = _288 + _203;
      float _291 = _289 + _204;
      float _292 = _284 + _126;
      float _293 = _286 + _122;
      float4 _294 = s0.SampleLevel(sLinearClampSampler, float2(_292, _293), _131);
      float4 _296 = s0.SampleLevel(sLinearClampSampler, float2(_290, _291), _131);
      float4 _298 = s2.SampleLevel(s2Sampler, float2(_292, _293), 0.0f);
      if (_211) {
        float4 _302 = s7.Load(int3(0, 0, 0));
        float _304 = _302.x - (Global.Proj.m[0][2].z);
        float _305 = (Global.Proj.m[0][2].w) / _304;
        _309 = _305;
      } else {
        _309 = (PostProcess.Settings[5].x);
      }
      float _310 = _298.x - (Global.Proj.m[0][2].z);
      float _311 = (Global.Proj.m[0][2].w) / _310;
      float _312 = _309 * (PostProcess.Settings[6].w);
      float _313 = _312 + _309;
      float _314 = _309 - _312;
      float _315 = max(_311, _314);
      float _316 = min(_315, _313);
      float _317 = _311 - _316;
      float _318 = _317 * (PostProcess.Settings[5].w);
      float _319 = _316 - (PostProcess.Settings[5].y);
      float _320 = _319 * _311;
      float _321 = _318 / _320;
      float _322 = min(_321, 0.0f);
      float _323 = _312 + 1.0f;
      float _324 = 1.0f / _323;
      float _325 = _322 * (PostProcess.Settings[7].z);
      float _326 = max(0.0f, _321);
      float _327 = _326 * (PostProcess.Settings[18].x);
      float _328 = _327 + _325;
      float _329 = _328 * _324;
      float _330 = max(_329, -1.0f);
      float _331 = min(_330, 1.0f);
      float _332 = max(_331, -0.30000001192092896f);
      float _333 = min(_332, 1.0f);
      float _334 = _333 * _261;
      float4 _335 = s2.SampleLevel(s2Sampler, float2(_290, _291), 0.0f);
      if (_211) {
        float4 _339 = s7.Load(int3(0, 0, 0));
        float _341 = _339.x - (Global.Proj.m[0][2].z);
        float _342 = (Global.Proj.m[0][2].w) / _341;
        _346 = _342;
      } else {
        _346 = (PostProcess.Settings[5].x);
      }
      float _347 = _335.x - (Global.Proj.m[0][2].z);
      float _348 = (Global.Proj.m[0][2].w) / _347;
      float _349 = _346 * (PostProcess.Settings[6].w);
      float _350 = _349 + _346;
      float _351 = _346 - _349;
      float _352 = max(_348, _351);
      float _353 = min(_352, _350);
      float _354 = _348 - _353;
      float _355 = _354 * (PostProcess.Settings[5].w);
      float _356 = _353 - (PostProcess.Settings[5].y);
      float _357 = _356 * _348;
      float _358 = _355 / _357;
      float _359 = min(_358, 0.0f);
      float _360 = _349 + 1.0f;
      float _361 = 1.0f / _360;
      float _362 = _359 * (PostProcess.Settings[7].z);
      float _363 = max(0.0f, _358);
      float _364 = _363 * (PostProcess.Settings[18].x);
      float _365 = _364 + _362;
      float _366 = _365 * _361;
      float _367 = max(_366, -1.0f);
      float _368 = min(_367, 1.0f);
      float _369 = max(_368, -0.30000001192092896f);
      float _370 = min(_369, 1.0f);
      float _371 = _370 * _261;
      float _372 = abs(_334);
      float _373 = _372 / (PostProcess.Settings[6].x);
      float _374 = ceil(_373);
      float _375 = saturate(_374);
      float _376 = _294.x - _194;
      float _377 = _375 * _376;
      float _378 = _377 + _194;
      float _379 = abs(_371);
      float _380 = _379 / (PostProcess.Settings[6].x);
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
    int _388 = asint((User.c[7].y));
    bool _389 = ((int)_388 > (int)0);
    if (_389) {
      float _391 = _40.x + TEXCOORD.x;
      float _392 = _50 + TEXCOORD.y;
      float4 _395 = s4.Sample(s4Sampler, float2(_391, _392));
      float4 _402 = s5.Sample(s5Sampler, float2(_391, _392));
      float _406 = (PostProcess.Settings[6].x) * _402.x;
      float _410 = _406 * (PostProcess.Settings[7].x);
      float _411 = _406 * (PostProcess.Settings[7].y);
      float _412 = _410 + _391;
      float _413 = _411 + _392;
      float4 _414 = s4.Sample(s4Sampler, float2(_412, _413));
      float4 _416 = s5.Sample(s5Sampler, float2(_412, _413));
      float _418 = _416.x * (PostProcess.Settings[6].x);
      float _419 = abs(_418);
      float _421 = _419 / (PostProcess.Settings[7].w);
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
      int _436 = asint((User.c[7].x));
      bool _437 = ((int)_436 > (int)0);
      [branch]
      if (_437) {
        float4 _441 = s7.Sample(s7Sampler, float2(TEXCOORD.x, TEXCOORD.y));
        float _443 = abs(_441.x);
        _536 = _443;
      } else {
        float4 _447 = s2.SampleLevel(s2Sampler, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _449 = TEXCOORD.x * 2.0f;
        float _450 = TEXCOORD.y * 2.0f;
        float _451 = _449 + -1.0f;
        float _452 = _450 + -1.0f;
        float _473 = (Global.Proj.m[0][8].x) * _451;
        float _474 = mad(_452, (Global.Proj.m[0][8].y), _473);
        float _475 = mad(_447.x, (Global.Proj.m[0][8].z), _474);
        float _476 = _475 + (Global.Proj.m[0][8].w);
        float _477 = (Global.Proj.m[0][9].x) * _451;
        float _478 = mad(_452, (Global.Proj.m[0][9].y), _477);
        float _479 = mad(_447.x, (Global.Proj.m[0][9].z), _478);
        float _480 = _479 + (Global.Proj.m[0][9].w);
        float _481 = (Global.Proj.m[0][10].x) * _451;
        float _482 = mad(_452, (Global.Proj.m[0][10].y), _481);
        float _483 = mad(_447.x, (Global.Proj.m[0][10].z), _482);
        float _484 = _483 + (Global.Proj.m[0][10].w);
        float _485 = (Global.Proj.m[0][11].x) * _451;
        float _486 = mad(_452, (Global.Proj.m[0][11].y), _485);
        float _487 = mad(_447.x, (Global.Proj.m[0][11].z), _486);
        float _488 = _487 + (Global.Proj.m[0][11].w);
        float _489 = _476 / _488;
        float _490 = _480 / _488;
        float _491 = _484 / _488;
        float _492 = _489 * _489;
        float _493 = _490 * _490;
        float _494 = _493 + _492;
        float _495 = _491 * _491;
        float _496 = _494 + _495;
        float _497 = sqrt(_496);
        float4 _500 = s5.Sample(s5Sampler, float2(TEXCOORD.x, TEXCOORD.y));
        float _506 = (PostProcess.Settings[6].w) * (PostProcess.Settings[5].x);
        float _507 = _506 + (PostProcess.Settings[5].x);
        float _508 = (PostProcess.Settings[5].x) - _506;
        float _509 = max(_497, _508);
        float _510 = min(_509, _507);
        float _512 = _497 - _510;
        float _513 = _512 * (PostProcess.Settings[5].w);
        float _515 = _510 - (PostProcess.Settings[5].y);
        float _516 = _515 * _497;
        float _517 = _513 / _516;
        float _518 = min(_517, 0.0f);
        float _521 = _506 + 1.0f;
        float _522 = 1.0f / _521;
        float _523 = (PostProcess.Settings[7].z) * _518;
        float _524 = max(0.0f, _517);
        float _527 = (PostProcess.Settings[18].x) * _524;
        float _528 = _527 + _523;
        float _529 = _528 * _522;
        float _530 = min(_500.x, _529);
        float _531 = abs(_530);
        float _532 = abs(_529);
        float _533 = max(_531, _532);
        float _534 = saturate(_533);
        _536 = _534;
      }
      float _539 = (PostProcess.Settings[6].x) * _536;
      float4 _542 = s4.Sample(s4Sampler, float2(TEXCOORD.x, TEXCOORD.y));
      float _549 = (PostProcess.Settings[7].x) * _539;
      float _550 = (PostProcess.Settings[7].y) * _539;
      float _551 = _549 + TEXCOORD.x;
      float _552 = _550 + TEXCOORD.y;
      float4 _553 = s4.Sample(s4Sampler, float2(_551, _552));
      float4 _557 = s5.Sample(s5Sampler, float2(_551, _552));
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
    bool _581 = !((PostProcess.Settings[17].z) >= -1.0f);
    float _585 = (PostProcess.Settings[4].w) * _151.x;
    float _586 = (PostProcess.Settings[4].w) * _151.y;
    float _587 = (PostProcess.Settings[4].w) * _151.z;
    float _588 = _585 + (PostProcess.Settings[4].z);
    float _589 = _586 + (PostProcess.Settings[4].z);
    float _590 = _587 + (PostProcess.Settings[4].z);
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
  float4 _619 = sExposureScale.Load(int3(0, 0, 0));
  float _625 = _619.x * (Global.Global.c[87].y);
  float _626 = _625 * _613;
  float _627 = _626 * (PostProcess.Settings[14].x);
  float _628 = _625 * _614;
  float _629 = _628 * (PostProcess.Settings[14].y);
  float _630 = _625 * _615;
  float _631 = _630 * (PostProcess.Settings[14].z);
  float _636 = _60 * 2.0f;
  float _637 = _61 * 2.0f;
  float _638 = _636 + -1.0f;
  float _639 = _637 + -1.0f;
  float _642 = (PostProcess.Settings[13].w) * _639;
  float _643 = _638 * _638;
  float _644 = _642 * _642;
  float _645 = _644 + _643;
  float _646 = sqrt(_645);
  float _648 = (PostProcess.Settings[13].x) * _646;
  float _650 = _648 + (PostProcess.Settings[13].y);
  float _651 = saturate(_650);
  float _653 = log2(_651);
  float _654 = _653 * (PostProcess.Settings[13].z);
  float _655 = exp2(_654);
  float _656 = _627 * (PostProcess.Settings[12].x);
  float _657 = _629 * (PostProcess.Settings[12].y);
  float _658 = _631 * (PostProcess.Settings[12].z);
  float _659 = _656 - _627;
  float _660 = _657 - _629;
  float _661 = _658 - _631;
  float _662 = _655 * _659;
  float _663 = _655 * _660;
  float _664 = _655 * _661;
  float _665 = _662 + _627;
  float _666 = _663 + _629;
  float _667 = _664 + _631;
  float _670 = (PostProcess.Settings[10].w) * 1.1190600395202637f;
  float _671 = _670 * _665;
  float _672 = _670 * _666;
  float _673 = _670 * _667;
  float _674 = _671 + 1.0f;
  float _675 = _672 + 1.0f;
  float _676 = _673 + 1.0f;
  float _677 = log2(_674);
  float _678 = log2(_675);
  float _679 = log2(_676);
  float _682 = (PostProcess.OffsetWeight[0].x) * 0.07434873282909393f;
  float _683 = _682 * _677;
  float _684 = _682 * _678;
  float _685 = _682 * _679;
  float _687 = _683 + (PostProcess.OffsetWeight[0].y);
  float _688 = _684 + (PostProcess.OffsetWeight[0].y);
  float _689 = _685 + (PostProcess.OffsetWeight[0].y);
  float4 _692 = s3_3D.Sample(s3_3DSampler, float3(_687, _688, _689));
  float _698 = _692.x * 13.450128555297852f;
  float _699 = _692.y * 13.450128555297852f;
  float _700 = _692.z * 13.450128555297852f;
  float _701 = exp2(_698);
  float _702 = exp2(_699);
  float _703 = exp2(_700);
  float _704 = _701 + -1.0f;
  float _705 = _702 + -1.0f;
  float _706 = _703 + -1.0f;
  float _707 = 0.8936070799827576f / (PostProcess.Settings[10].w);
  float _708 = _707 * _704;
  float _709 = _707 * _705;
  float _710 = _707 * _706;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_671 * _707, _672 * _707, _673 * _707),
      float3(_708, _709, _710),
      1.f.xxx);
  _708 = resonance_scaled_lut_output.x;
  _709 = resonance_scaled_lut_output.y;
  _710 = resonance_scaled_lut_output.z;
  bool _713 = ((User.c[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_713) {
    float _715 = (PostProcess.Settings[10].w) * 1.1190600395202637f;
    float _716 = _708 * _715;
    float _717 = _709 * _715;
    float _718 = _710 * _715;
    float _719 = _716 + 1.0f;
    float _720 = _717 + 1.0f;
    float _721 = _718 + 1.0f;
    float _722 = log2(_719);
    float _723 = log2(_720);
    float _724 = log2(_721);
    float _725 = _722 * 0.07434873282909393f;
    float _726 = _723 * 0.07434873282909393f;
    float _727 = _724 * 0.07434873282909393f;
    int _729 = asint((User.c[3].y));
    int _730 = _729 & 1;
    bool _731 = (_730 == 0);
    if (!_731) {
      bool _748 = !(_725 <= (User.c[4].x));
      if (!_748) {
        float _750 = max(9.999999974752427e-07f, (User.c[4].x));
        float _751 = _725 / _750;
        float _752 = _751 * (User.c[4].y);
        float _753 = _751 * _751;
        float _754 = _753 * _751;
        float _755 = _754 - _751;
        float _756 = (User.c[10].x) * 0.1666666716337204f;
        float _757 = _750 * _750;
        float _758 = _757 * _756;
        float _759 = _758 * _755;
        float _760 = _759 + _752;
        _850 = _760;
      } else {
        bool _762 = !(_725 <= (User.c[4].z));
        if (!_762) {
          float _764 = (User.c[4].z) - (User.c[4].x);
          float _765 = max(9.999999974752427e-07f, _764);
          float _766 = _725 - (User.c[4].x);
          float _767 = _766 / _765;
          float _768 = 1.0f - _767;
          float _769 = _768 * (User.c[4].y);
          float _770 = _767 * (User.c[4].w);
          float _771 = _769 + _770;
          float _772 = _768 * _768;
          float _773 = _772 * _768;
          float _774 = _773 - _768;
          float _775 = _774 * (User.c[10].x);
          float _776 = _767 * _767;
          float _777 = _776 * _767;
          float _778 = _777 - _767;
          float _779 = _778 * (User.c[10].y);
          float _780 = _775 + _779;
          float _781 = _765 * _765;
          float _782 = _781 * 0.1666666716337204f;
          float _783 = _782 * _780;
          float _784 = _771 + _783;
          _850 = _784;
        } else {
          bool _786 = !(_725 <= (User.c[9].x));
          if (!_786) {
            float _788 = (User.c[9].x) - (User.c[4].z);
            float _789 = max(9.999999974752427e-07f, _788);
            float _790 = _725 - (User.c[4].z);
            float _791 = _790 / _789;
            float _792 = 1.0f - _791;
            float _793 = _792 * (User.c[4].w);
            float _794 = _791 * (User.c[9].y);
            float _795 = _793 + _794;
            float _796 = _792 * _792;
            float _797 = _796 * _792;
            float _798 = _797 - _792;
            float _799 = _798 * (User.c[10].y);
            float _800 = _791 * _791;
            float _801 = _800 * _791;
            float _802 = _801 - _791;
            float _803 = _802 * (User.c[10].z);
            float _804 = _799 + _803;
            float _805 = _789 * _789;
            float _806 = _805 * 0.1666666716337204f;
            float _807 = _806 * _804;
            float _808 = _795 + _807;
            _850 = _808;
          } else {
            bool _810 = !(_725 <= (User.c[9].z));
            if (!_810) {
              float _812 = (User.c[9].z) - (User.c[9].x);
              float _813 = max(9.999999974752427e-07f, _812);
              float _814 = _725 - (User.c[9].x);
              float _815 = _814 / _813;
              float _816 = 1.0f - _815;
              float _817 = _816 * (User.c[9].y);
              float _818 = _815 * (User.c[9].w);
              float _819 = _817 + _818;
              float _820 = _816 * _816;
              float _821 = _820 * _816;
              float _822 = _821 - _816;
              float _823 = _822 * (User.c[10].z);
              float _824 = _815 * _815;
              float _825 = _824 * _815;
              float _826 = _825 - _815;
              float _827 = _826 * (User.c[10].w);
              float _828 = _823 + _827;
              float _829 = _813 * _813;
              float _830 = _829 * 0.1666666716337204f;
              float _831 = _830 * _828;
              float _832 = _819 + _831;
              _850 = _832;
            } else {
              float _834 = 1.0f - (User.c[9].z);
              float _835 = _725 - (User.c[9].z);
              float _836 = max(9.999999974752427e-07f, _834);
              float _837 = _835 / _836;
              float _838 = 1.0f - _837;
              float _839 = _838 * (User.c[9].w);
              float _840 = _839 + _837;
              float _841 = _838 * _838;
              float _842 = _841 * _838;
              float _843 = _842 - _838;
              float _844 = (User.c[10].w) * 0.1666666716337204f;
              float _845 = _834 * _834;
              float _846 = _845 * _844;
              float _847 = _846 * _843;
              float _848 = _840 + _847;
              _850 = _848;
            }
          }
        }
      }
      float _851 = saturate(_850);
      bool _852 = !(_726 <= (User.c[4].x));
      if (!_852) {
        float _854 = max(9.999999974752427e-07f, (User.c[4].x));
        float _855 = _726 / _854;
        float _856 = _855 * (User.c[4].y);
        float _857 = _855 * _855;
        float _858 = _857 * _855;
        float _859 = _858 - _855;
        float _860 = (User.c[10].x) * 0.1666666716337204f;
        float _861 = _854 * _854;
        float _862 = _861 * _860;
        float _863 = _862 * _859;
        float _864 = _863 + _856;
        _954 = _864;
      } else {
        bool _866 = !(_726 <= (User.c[4].z));
        if (!_866) {
          float _868 = (User.c[4].z) - (User.c[4].x);
          float _869 = max(9.999999974752427e-07f, _868);
          float _870 = _726 - (User.c[4].x);
          float _871 = _870 / _869;
          float _872 = 1.0f - _871;
          float _873 = _872 * (User.c[4].y);
          float _874 = _871 * (User.c[4].w);
          float _875 = _873 + _874;
          float _876 = _872 * _872;
          float _877 = _876 * _872;
          float _878 = _877 - _872;
          float _879 = _878 * (User.c[10].x);
          float _880 = _871 * _871;
          float _881 = _880 * _871;
          float _882 = _881 - _871;
          float _883 = _882 * (User.c[10].y);
          float _884 = _879 + _883;
          float _885 = _869 * _869;
          float _886 = _885 * 0.1666666716337204f;
          float _887 = _886 * _884;
          float _888 = _875 + _887;
          _954 = _888;
        } else {
          bool _890 = !(_726 <= (User.c[9].x));
          if (!_890) {
            float _892 = (User.c[9].x) - (User.c[4].z);
            float _893 = max(9.999999974752427e-07f, _892);
            float _894 = _726 - (User.c[4].z);
            float _895 = _894 / _893;
            float _896 = 1.0f - _895;
            float _897 = _896 * (User.c[4].w);
            float _898 = _895 * (User.c[9].y);
            float _899 = _897 + _898;
            float _900 = _896 * _896;
            float _901 = _900 * _896;
            float _902 = _901 - _896;
            float _903 = _902 * (User.c[10].y);
            float _904 = _895 * _895;
            float _905 = _904 * _895;
            float _906 = _905 - _895;
            float _907 = _906 * (User.c[10].z);
            float _908 = _903 + _907;
            float _909 = _893 * _893;
            float _910 = _909 * 0.1666666716337204f;
            float _911 = _910 * _908;
            float _912 = _899 + _911;
            _954 = _912;
          } else {
            bool _914 = !(_726 <= (User.c[9].z));
            if (!_914) {
              float _916 = (User.c[9].z) - (User.c[9].x);
              float _917 = max(9.999999974752427e-07f, _916);
              float _918 = _726 - (User.c[9].x);
              float _919 = _918 / _917;
              float _920 = 1.0f - _919;
              float _921 = _920 * (User.c[9].y);
              float _922 = _919 * (User.c[9].w);
              float _923 = _921 + _922;
              float _924 = _920 * _920;
              float _925 = _924 * _920;
              float _926 = _925 - _920;
              float _927 = _926 * (User.c[10].z);
              float _928 = _919 * _919;
              float _929 = _928 * _919;
              float _930 = _929 - _919;
              float _931 = _930 * (User.c[10].w);
              float _932 = _927 + _931;
              float _933 = _917 * _917;
              float _934 = _933 * 0.1666666716337204f;
              float _935 = _934 * _932;
              float _936 = _923 + _935;
              _954 = _936;
            } else {
              float _938 = 1.0f - (User.c[9].z);
              float _939 = _726 - (User.c[9].z);
              float _940 = max(9.999999974752427e-07f, _938);
              float _941 = _939 / _940;
              float _942 = 1.0f - _941;
              float _943 = _942 * (User.c[9].w);
              float _944 = _943 + _941;
              float _945 = _942 * _942;
              float _946 = _945 * _942;
              float _947 = _946 - _942;
              float _948 = (User.c[10].w) * 0.1666666716337204f;
              float _949 = _938 * _938;
              float _950 = _949 * _948;
              float _951 = _950 * _947;
              float _952 = _944 + _951;
              _954 = _952;
            }
          }
        }
      }
      float _955 = saturate(_954);
      bool _956 = !(_727 <= (User.c[4].x));
      if (!_956) {
        float _958 = max(9.999999974752427e-07f, (User.c[4].x));
        float _959 = _727 / _958;
        float _960 = _959 * (User.c[4].y);
        float _961 = _959 * _959;
        float _962 = _961 * _959;
        float _963 = _962 - _959;
        float _964 = (User.c[10].x) * 0.1666666716337204f;
        float _965 = _958 * _958;
        float _966 = _965 * _964;
        float _967 = _966 * _963;
        float _968 = _967 + _960;
        _1058 = _968;
      } else {
        bool _970 = !(_727 <= (User.c[4].z));
        if (!_970) {
          float _972 = (User.c[4].z) - (User.c[4].x);
          float _973 = max(9.999999974752427e-07f, _972);
          float _974 = _727 - (User.c[4].x);
          float _975 = _974 / _973;
          float _976 = 1.0f - _975;
          float _977 = _976 * (User.c[4].y);
          float _978 = _975 * (User.c[4].w);
          float _979 = _977 + _978;
          float _980 = _976 * _976;
          float _981 = _980 * _976;
          float _982 = _981 - _976;
          float _983 = _982 * (User.c[10].x);
          float _984 = _975 * _975;
          float _985 = _984 * _975;
          float _986 = _985 - _975;
          float _987 = _986 * (User.c[10].y);
          float _988 = _983 + _987;
          float _989 = _973 * _973;
          float _990 = _989 * 0.1666666716337204f;
          float _991 = _990 * _988;
          float _992 = _979 + _991;
          _1058 = _992;
        } else {
          bool _994 = !(_727 <= (User.c[9].x));
          if (!_994) {
            float _996 = (User.c[9].x) - (User.c[4].z);
            float _997 = max(9.999999974752427e-07f, _996);
            float _998 = _727 - (User.c[4].z);
            float _999 = _998 / _997;
            float _1000 = 1.0f - _999;
            float _1001 = _1000 * (User.c[4].w);
            float _1002 = _999 * (User.c[9].y);
            float _1003 = _1001 + _1002;
            float _1004 = _1000 * _1000;
            float _1005 = _1004 * _1000;
            float _1006 = _1005 - _1000;
            float _1007 = _1006 * (User.c[10].y);
            float _1008 = _999 * _999;
            float _1009 = _1008 * _999;
            float _1010 = _1009 - _999;
            float _1011 = _1010 * (User.c[10].z);
            float _1012 = _1007 + _1011;
            float _1013 = _997 * _997;
            float _1014 = _1013 * 0.1666666716337204f;
            float _1015 = _1014 * _1012;
            float _1016 = _1003 + _1015;
            _1058 = _1016;
          } else {
            bool _1018 = !(_727 <= (User.c[9].z));
            if (!_1018) {
              float _1020 = (User.c[9].z) - (User.c[9].x);
              float _1021 = max(9.999999974752427e-07f, _1020);
              float _1022 = _727 - (User.c[9].x);
              float _1023 = _1022 / _1021;
              float _1024 = 1.0f - _1023;
              float _1025 = _1024 * (User.c[9].y);
              float _1026 = _1023 * (User.c[9].w);
              float _1027 = _1025 + _1026;
              float _1028 = _1024 * _1024;
              float _1029 = _1028 * _1024;
              float _1030 = _1029 - _1024;
              float _1031 = _1030 * (User.c[10].z);
              float _1032 = _1023 * _1023;
              float _1033 = _1032 * _1023;
              float _1034 = _1033 - _1023;
              float _1035 = _1034 * (User.c[10].w);
              float _1036 = _1031 + _1035;
              float _1037 = _1021 * _1021;
              float _1038 = _1037 * 0.1666666716337204f;
              float _1039 = _1038 * _1036;
              float _1040 = _1027 + _1039;
              _1058 = _1040;
            } else {
              float _1042 = 1.0f - (User.c[9].z);
              float _1043 = _727 - (User.c[9].z);
              float _1044 = max(9.999999974752427e-07f, _1042);
              float _1045 = _1043 / _1044;
              float _1046 = 1.0f - _1045;
              float _1047 = _1046 * (User.c[9].w);
              float _1048 = _1047 + _1045;
              float _1049 = _1046 * _1046;
              float _1050 = _1049 * _1046;
              float _1051 = _1050 - _1046;
              float _1052 = (User.c[10].w) * 0.1666666716337204f;
              float _1053 = _1042 * _1042;
              float _1054 = _1053 * _1052;
              float _1055 = _1054 * _1051;
              float _1056 = _1048 + _1055;
              _1058 = _1056;
            }
          }
        }
      }
      float _1059 = saturate(_1058);
      _1061 = _851;
      _1062 = _955;
      _1063 = _1059;
    } else {
      _1061 = _725;
      _1062 = _726;
      _1063 = _727;
    }
    int _1064 = _729 & 2;
    bool _1065 = (_1064 == 0);
    if (!_1065) {
      float _1067 = sqrt(_1061);
      float _1068 = sqrt(_1062);
      float _1069 = sqrt(_1063);
      float _1070 = dot(float3(_1067, _1068, _1069), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1071 = 1.0f - _1070;
      float _1072 = saturate(_1071);
      _1074 = _1072;
    } else {
      _1074 = 1.0f;
    }
    int _1075 = _729 & 8;
    bool _1076 = (_1075 == 0);
    if (_1076) {
      int _1078 = _729 & 4;
      bool _1079 = (_1078 == 0);
      if (!_1079) {
        int _1081 = _729 & 16;
        bool _1082 = (_1081 == 0);
        if (!_1082) {
          float _1086 = (User.c[5].x) * 0.5f;
          float _1087 = _1086 + 0.5f;
          bool _1088 = (_1087 < 0.5f);
          float _1089 = (User.c[5].x) * 5.0f;
          float _1090 = select(_1088, (User.c[5].x), _1089);
          bool _1091 = (_1062 < _1063);
          float _1092 = select(_1091, _1063, _1062);
          float _1093 = select(_1091, _1062, _1063);
          bool _1094 = (_1061 < _1092);
          float _1095 = select(_1094, _1092, _1061);
          float _1096 = select(_1094, _1061, _1092);
          float _1097 = min(_1096, _1093);
          float _1098 = _1095 - _1097;
          float _1099 = _1095 + 1.000000013351432e-10f;
          float _1100 = _1098 / _1099;
          float _1102 = _1100 - (User.c[5].y);
          float _1103 = saturate(_1102);
          float _1104 = max(_1103, 9.999999974752427e-07f);
          float _1105 = log2(_1104);
          float _1106 = _1105 * _1090;
          float _1107 = exp2(_1106);
          float _1108 = 2.0f - _1107;
          float _1110 = 1.0f - (User.c[5].z);
          float _1111 = saturate(_1110);
          float _1112 = max(_1111, _1108);
          float _1113 = dot(float3(_1061, _1062, _1063), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1114 = _1061 - _1113;
          float _1115 = _1062 - _1113;
          float _1116 = _1063 - _1113;
          float _1117 = _1114 * _1112;
          float _1118 = _1115 * _1112;
          float _1119 = _1116 * _1112;
          float _1120 = _1113 - _1061;
          float _1121 = _1120 + _1117;
          float _1122 = _1113 - _1062;
          float _1123 = _1122 + _1118;
          float _1124 = _1113 - _1063;
          float _1125 = _1124 + _1119;
          float _1126 = _1121 * _1074;
          float _1127 = _1123 * _1074;
          float _1128 = _1125 * _1074;
          float _1129 = _1126 + _1061;
          float _1130 = _1127 + _1062;
          float _1131 = _1128 + _1063;
          _1248 = _1129;
          _1249 = _1130;
          _1250 = _1131;
        } else {
          bool _1133 = (_1074 == 0.0f);
          if (!_1133) {
            float _1137 = abs(User.c[5].x);
            float _1138 = saturate(_1137);
            uint4 _1140 = 0u; sVibranceLUT.GetDimensions(0u, _1140.x, _1140.y, _1140.w);
            float _1143 = float((uint)_1140.y);
            int _1144 = _729 & 32;
            bool _1145 = (_1144 == 0);
            float _1146 = _1143 + -1.0f;
            if (!_1145) {
              float _1148 = 1.0f / _1146;
              uint _1149 = uint(SV_Position.x);
              uint _1150 = uint(SV_Position.y);
              int _1151 = _1149 & 63;
              int _1152 = _1150 & 63;
              float4 _1154 = sBlueNoiseR8G8.Load(int4(_1151, _1152, 0, 0));
              float _1157 = _1154.x + -0.5f;
              float _1158 = _1061 * 13.999999046325684f;
              float _1159 = _1062 * 13.999999046325684f;
              float _1160 = _1063 * 13.999999046325684f;
              float _1161 = saturate(_1158);
              float _1162 = saturate(_1159);
              float _1163 = saturate(_1160);
              float _1164 = _1061 + -0.9285714030265808f;
              float _1165 = _1062 + -0.9285714030265808f;
              float _1166 = _1063 + -0.9285714030265808f;
              float _1167 = _1164 * 13.999999046325684f;
              float _1168 = _1165 * 13.999999046325684f;
              float _1169 = _1166 * 13.999999046325684f;
              float _1170 = saturate(_1167);
              float _1171 = saturate(_1168);
              float _1172 = saturate(_1169);
              float _1173 = 1.0f - _1170;
              float _1174 = 1.0f - _1171;
              float _1175 = 1.0f - _1172;
              float _1176 = min(_1161, _1173);
              float _1177 = min(_1162, _1174);
              float _1178 = min(_1163, _1175);
              float _1179 = _1154.y + -0.5f;
              float _1180 = _1176 * _1179;
              float _1181 = _1177 * _1179;
              float _1182 = _1178 * _1179;
              float _1183 = _1180 + _1157;
              float _1184 = _1181 + _1157;
              float _1185 = _1182 + _1157;
              float _1186 = _1183 * _1148;
              float _1187 = _1184 * _1148;
              float _1188 = _1185 * _1148;
              float _1189 = _1186 + _1061;
              float _1190 = _1187 + _1062;
              float _1191 = _1188 + _1063;
              float _1192 = saturate(_1189);
              float _1193 = saturate(_1190);
              float _1194 = saturate(_1191);
              float _1195 = saturate(_1192);
              float _1196 = saturate(_1193);
              float _1197 = saturate(_1194);
              _1199 = _1195;
              _1200 = _1196;
              _1201 = _1197;
            } else {
              _1199 = _1061;
              _1200 = _1062;
              _1201 = _1063;
            }
            float _1202 = float((uint)_1140.x);
            float _1203 = _1146 / _1202;
            float _1204 = _1203 * _1199;
            float _1205 = 0.5f / _1202;
            float _1206 = _1204 + _1205;
            float _1207 = _1146 / _1143;
            float _1208 = _1207 * _1200;
            float _1209 = 0.5f / _1143;
            float _1210 = _1208 + _1209;
            float _1211 = _1201 * _1146;
            float _1212 = floor(_1211);
            float _1213 = frac(_1211);
            float _1214 = _1212 / _1143;
            float _1215 = _1214 + _1206;
            float _1216 = _1212 + 1.0f;
            float _1217 = _1216 / _1143;
            float _1218 = _1217 + _1206;
            float4 _1220 = sVibranceLUT.Sample(sLinearClampSampler, float2(_1215, _1210));
            float4 _1224 = sVibranceLUT.Sample(sLinearClampSampler, float2(_1218, _1210));
            float _1228 = _1224.x - _1220.x;
            float _1229 = _1224.y - _1220.y;
            float _1230 = _1224.z - _1220.z;
            float _1231 = _1228 * _1213;
            float _1232 = _1229 * _1213;
            float _1233 = _1230 * _1213;
            float _1234 = _1138 * _1074;
            float _1235 = _1220.x - _1061;
            float _1236 = _1235 + _1231;
            float _1237 = _1220.y - _1062;
            float _1238 = _1237 + _1232;
            float _1239 = _1220.z - _1063;
            float _1240 = _1239 + _1233;
            float _1241 = _1236 * _1234;
            float _1242 = _1238 * _1234;
            float _1243 = _1240 * _1234;
            float _1244 = _1241 + _1061;
            float _1245 = _1242 + _1062;
            float _1246 = _1243 + _1063;
            _1248 = _1244;
            _1249 = _1245;
            _1250 = _1246;
          } else {
            _1248 = _1061;
            _1249 = _1062;
            _1250 = _1063;
          }
        }
      } else {
        _1248 = _1061;
        _1249 = _1062;
        _1250 = _1063;
      }
    } else {
      _1248 = _1074;
      _1249 = _1074;
      _1250 = _1074;
    }
    float _1251 = _1248 * 13.450128555297852f;
    float _1252 = _1249 * 13.450128555297852f;
    float _1253 = _1250 * 13.450128555297852f;
    float _1254 = exp2(_1251);
    float _1255 = exp2(_1252);
    float _1256 = exp2(_1253);
    float _1257 = _1254 + -1.0f;
    float _1258 = _1255 + -1.0f;
    float _1259 = _1256 + -1.0f;
    float _1260 = _1257 * _707;
    float _1261 = _1258 * _707;
    float _1262 = _1259 * _707;
    _1264 = _1260;
    _1265 = _1261;
    _1266 = _1262;
  } else {
    _1264 = _708;
    _1265 = _709;
    _1266 = _710;
  }
  float _1271 = (User.c[8].x) * _1264;
  float _1272 = (User.c[8].y) * _1265;
  float _1273 = (User.c[8].z) * _1266;
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3(_1271, _1272, _1273),
      SV_Position.xy);
  float _1278 = (PostProcess.Settings[10].z) * TEXCOORD.x;
  float _1279 = _1278 * (PostProcess.Settings[9].x);
  float _1280 = (PostProcess.Settings[10].z) * TEXCOORD.y;
  float _1281 = _1280 * (PostProcess.Settings[9].y);
  float _1284 = _1279 + (PostProcess.Settings[9].z);
  float _1285 = _1281 + (PostProcess.Settings[9].w);
  float4 _1288 = s9.Sample(s9Sampler, float2(_1284, _1285));
  float _1292 = dot(float3(_1271, _1272, _1273), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _1295 = ((PostProcess.Settings[10].x) > 0.0f);
  int _1298 = asint((Global.Global.c[1].w));
  int _1299 = select(_1295, _1298, 0);
  float _1300 = (PostProcess.Settings[10].z) * SV_Position.x;
  float _1301 = (PostProcess.Settings[10].z) * SV_Position.y;
  uint _1302 = uint(_1300);
  uint _1303 = uint(_1301);
  int _1304 = _1302 & 63;
  int _1305 = _1303 & 63;
  float4 _1307 = sBlueNoiseR8G8.Load(int4(_1304, _1305, _1299, 0));
  bool _1309 = ((PostProcess.Settings[10].z) < 1.0f);
  if (_1309) {
    float _1311 = _1300 * 0.015625f;
    float _1312 = _1301 * 0.015625f;
    float _1313 = float((uint)_1298);
    float _1314 = select(_1295, _1313, 0.0f);
    float4 _1316 = sBlueNoiseR8G8.SampleLevel(sLinearWrapSampler, float3(_1311, _1312, _1314), 0.0f);
    float _1318 = _1307.y - _1316.y;
    float _1319 = _1318 * (PostProcess.Settings[10].z);
    float _1320 = _1319 + _1316.y;
    _1322 = _1320;
  } else {
    _1322 = _1307.y;
  }
  float _1323 = _1288.x * -2.0f;
  float _1324 = _1323 * _1322;
  float _1325 = _1322 * 2.0f;
  float _1326 = _1325 * _1288.y;
  float _1327 = _1325 * _1288.z;
  float _1328 = _1324 + _1288.x;
  float _1329 = _1326 - _1288.y;
  float _1330 = _1327 - _1288.z;
  float _1331 = _1328 * _1288.x;
  float _1332 = _1329 * _1288.y;
  float _1333 = _1330 * _1288.z;
  float _1334 = _1292 + 1.0f;
  float _1335 = _1292 / _1334;
  float _1336 = _1335 + -9.999999747378752e-05f;
  float _1337 = _1336 * 1111.111083984375f;
  float _1338 = saturate(_1337);
  float _1339 = _1338 * 2.0f;
  float _1340 = 3.0f - _1339;
  float _1341 = _1338 * _1338;
  float _1342 = _1341 * _1340;
  bool _1344 = ((PostProcess.Settings[10].y) > 0.0f);
  float _1345 = float((bool)_1344);
  float _1346 = dot(float3(_1331, _1332, _1333), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1347 = _1346 - _1331;
  float _1348 = _1346 - _1332;
  float _1349 = _1346 - _1333;
  float _1350 = _1347 * _1345;
  float _1351 = _1348 * _1345;
  float _1352 = _1349 * _1345;
  float _1353 = _1350 + _1331;
  float _1354 = _1351 + _1332;
  float _1355 = _1352 + _1333;
  float _1359 = (PostProcess.Settings[2].y) - (PostProcess.Settings[2].x);
  float _1360 = _1359 * _1335;
  float _1361 = _1360 + (PostProcess.Settings[2].x);
  float _1362 = _1342 * _1361;
  float _1363 = _1362 * _1353;
  float _1364 = _1362 * _1354;
  float _1365 = _1362 * _1355;
  float _1366 = _1363 + _1271;
  float _1367 = _1364 + _1272;
  float _1368 = _1365 + _1273;
  float _1369 = max(0.0f, _1366);
  float _1370 = max(0.0f, _1367);
  float _1371 = max(0.0f, _1368);
  float3 resonance_film_grain_output = ResonanceSelectFilmGrainOutput(
      float3(_1369, _1370, _1371),
      resonance_perceptual_film_grain);
  _1369 = resonance_film_grain_output.x;
  _1370 = resonance_film_grain_output.y;
  _1371 = resonance_film_grain_output.z;
  float _1374 = (PostProcess.Settings[17].y) + 2.0f;
  float _1375 = log2(_1369);
  float _1376 = _1374 * _1375;
  float _1377 = exp2(_1376);
  float _1378 = _1377 + -1.0f;
  float _1379 = _1369 + -1.0f;
  float _1380 = _1378 / _1379;
  bool _1381 = !(_1369 == 1.0f);
  float _1382 = _1380 + -1.0f;
  float _1383 = _1382 / _1380;
  float _1384 = (PostProcess.Settings[17].y) + 1.0f;
  float _1385 = _1384 / _1374;
  float _1386 = select(_1381, _1383, _1385);
  float _1387 = log2(_1370);
  float _1388 = _1387 * _1374;
  float _1389 = exp2(_1388);
  float _1390 = _1389 + -1.0f;
  float _1391 = _1370 + -1.0f;
  float _1392 = _1390 / _1391;
  bool _1393 = !(_1370 == 1.0f);
  float _1394 = _1392 + -1.0f;
  float _1395 = _1394 / _1392;
  float _1396 = (PostProcess.Settings[17].y) + 1.0f;
  float _1397 = _1396 / _1374;
  float _1398 = select(_1393, _1395, _1397);
  float _1399 = log2(_1371);
  float _1400 = _1399 * _1374;
  float _1401 = exp2(_1400);
  float _1402 = _1401 + -1.0f;
  float _1403 = _1371 + -1.0f;
  float _1404 = _1402 / _1403;
  bool _1405 = !(_1371 == 1.0f);
  float _1406 = _1404 + -1.0f;
  float _1407 = _1406 / _1404;
  float _1408 = (PostProcess.Settings[17].y) + 1.0f;
  float _1409 = _1408 / _1374;
  float _1410 = select(_1405, _1407, _1409);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1369, _1370, _1371),
      float3(_1386, _1398, _1410),
      true);
  float _1411 = resonance_post_process_output.x;
  float _1412 = resonance_post_process_output.y;
  float _1413 = resonance_post_process_output.z;
  float _1414 = log2(_1411);
  float _1415 = log2(_1412);
  float _1416 = log2(_1413);
  float _1417 = _1414 * 0.4166666567325592f;
  float _1418 = _1415 * 0.4166666567325592f;
  float _1419 = _1416 * 0.4166666567325592f;
  float _1420 = exp2(_1417);
  float _1421 = exp2(_1418);
  float _1422 = exp2(_1419);
  float _1423 = _1420 * 1.0549999475479126f;
  float _1424 = _1421 * 1.0549999475479126f;
  float _1425 = _1422 * 1.0549999475479126f;
  float _1426 = _1423 + -0.054999999701976776f;
  float _1427 = _1424 + -0.054999999701976776f;
  float _1428 = _1425 + -0.054999999701976776f;
  float _1429 = _1411 * 12.920000076293945f;
  float _1430 = _1412 * 12.920000076293945f;
  float _1431 = _1413 * 12.920000076293945f;
  bool _1432 = (_1411 <= 0.0031308000907301903f);
  bool _1433 = (_1412 <= 0.0031308000907301903f);
  bool _1434 = (_1413 <= 0.0031308000907301903f);
  float _1435 = select(_1432, _1429, _1426);
  float _1436 = select(_1433, _1430, _1427);
  float _1437 = select(_1434, _1431, _1428);
  uint _1438 = uint(SV_Position.x);
  uint _1439 = uint(SV_Position.y);
  int _1440 = _1438 & 63;
  int _1441 = _1439 & 63;
  float4 _1443 = sBlueNoiseR8.Load(int4(_1440, _1441, _1298, 0));
  float _1445 = _1443.x + -0.5f;
  float _1446 = _1445 * 0.003921568859368563f;
  float _1447 = _1446 + _1435;
  float _1448 = _1446 + _1436;
  float _1449 = _1446 + _1437;
  float _1450 = saturate(_1447);
  float _1451 = saturate(_1448);
  float _1452 = saturate(_1449);
  SV_Target.x = _1450;
  SV_Target.y = _1451;
  SV_Target.z = _1452;
  SV_Target.w = _138.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}