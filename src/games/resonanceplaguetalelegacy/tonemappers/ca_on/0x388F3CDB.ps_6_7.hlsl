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

Texture2DArray<float4> sBlueNoiseR8G8 : register(t2);

Texture2D<float4> s0 : register(t0);

Texture3D<float4> s3_3D : register(t3);

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

SamplerState s3_3DSampler : register(s3);

SamplerState s8Sampler : register(s8);

SamplerState s9Sampler : register(s9);

SamplerState s14Sampler : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _32 = s14.Sample(s14Sampler, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _38 = sPostProcessFX_MaskLayer.Sample(sLinearClampSampler, float2(TEXCOORD.z, TEXCOORD.w));
  float _41 = _38.y * 0.10000000149011612f;
  float _42 = _41 + _32.y;
  float _43 = _38.y * 0.5f;
  float _44 = _43 + _32.z;
  float _45 = exp2(_44);
  float _46 = _45 + -1.0f;
  float _49 = (PostProcess.Settings[11].y) * _46;
  float _50 = _49 + 1.0f;
  float _51 = log2(_50);
  float _52 = _32.x + TEXCOORD.z;
  float _53 = _42 + TEXCOORD.w;
  float _54 = _32.x + TEXCOORD.x;
  float _55 = _42 + TEXCOORD.y;
  float _59 = 0.5f - (PostProcess.Settings[19].x);
  float _60 = 0.5f - (PostProcess.Settings[19].y);
  float _61 = _59 + _52;
  float _62 = _60 + _53;
  float _63 = _61 * 2.0f;
  float _64 = _62 * 2.0f;
  float _65 = _63 + -1.0f;
  float _66 = _64 + -1.0f;
  float _70 = _66 * (Global.Global.c[51].y);
  float _71 = abs(_65);
  float _72 = abs(_66);
  float _74 = (PostProcess.Settings[19].z) * 2.0f;
  float _75 = _74 + -1.0f;
  float _76 = _71 - _75;
  float _77 = _72 - _75;
  float _78 = saturate(_76);
  float _79 = saturate(_77);
  float _80 = _78 * (Global.Global.c[51].x);
  float _81 = _80 * _65;
  float _82 = _70 * _79;
  float _83 = _81 * _81;
  float _84 = _82 * _82;
  float _85 = _83 + _84;
  float _86 = sqrt(_85);
  float _89 = _59 + _54;
  float _90 = _60 + _55;
  float _91 = _89 * 2.0f;
  float _92 = _91 + -1.0f;
  float _93 = _90 * 1.125f;
  float _94 = _93 + -0.5625f;
  float _95 = _92 * _92;
  float _96 = _94 * _94;
  float _97 = _95 + _96;
  float _98 = sqrt(_97);
  float _99 = _98 * 0.8715755343437195f;
  float _100 = _99 * _99;
  float _101 = _100 + -0.15000000596046448f;
  float _102 = _101 * 1.8181819915771484f;
  float _103 = saturate(_102);
  float _104 = _103 * 2.0f;
  float _105 = 3.0f - _104;
  float _106 = (PostProcess.Settings[2].w) * _86;
  float _107 = _103 * _103;
  float _108 = _107 * _106;
  float _109 = _108 * _100;
  float _110 = _109 * _105;
  float _112 = (PostProcess.Settings[2].z) * _81;
  float _113 = (PostProcess.Settings[2].z) * _82;
  float _114 = _113 + _53;
  float _115 = _52 - _112;
  float _116 = _38.x * 0.010840999893844128f;
  float _117 = _116 + _52;
  float _118 = _117 + _112;
  float _119 = _53 + _116;
  float _120 = _119 - _113;
  float _121 = _51 + 1.0f;
  float _122 = log2(_121);
  float _123 = max(_110, _122);
  float4 _126 = s0.SampleLevel(sLinearClampSampler, float2(_118, _114), _123);
  float4 _128 = s0.SampleLevel(sLinearClampSampler, float2(_115, _120), _123);
  float4 _130 = s0.SampleLevel(sLinearClampSampler, float2(_52, _53), _123);
  float _133 = max(_126.x, 0.0f);
  float _134 = max(_128.y, 0.0f);
  float _135 = max(_130.z, 0.0f);
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
      float3(_133, _134, _135),
      max(_130.rgb, 0.f.xxx),
      float2(_52, _53),
      s0,
      sLinearClampSampler,
      _123);
  _133 = renodx_chromatic_aberration_input.x;
  _134 = renodx_chromatic_aberration_input.y;
  _135 = renodx_chromatic_aberration_input.z;
  float4 _137 = s12_bloom.SampleLevel(sLinearClampSampler, float2(_52, _53), 0.0f);
  float4 _143 = s8.Sample(s8Sampler, float2(_54, _55));
  int _149 = asint((User.c[7].z));
  bool _150 = ((int)_149 > (int)0);
  float _179;
  float _180;
  float _181;
  float _186;
  float _187;
  float _188;
  float _217;
  float _218;
  float _219;
  float _224;
  float _225;
  float _226;
  float _461;
  float _565;
  float _669;
  float _672;
  float _673;
  float _674;
  float _685;
  float _810;
  float _811;
  float _812;
  float _859;
  float _860;
  float _861;
  float _875;
  float _876;
  float _877;
  float _933;
  if (!_150) {
    bool _154 = !((PostProcess.Settings[17].z) >= -1.0f);
    float _158 = (PostProcess.Settings[4].w) * _143.x;
    float _159 = (PostProcess.Settings[4].w) * _143.y;
    float _160 = (PostProcess.Settings[4].w) * _143.z;
    float _161 = _158 + (PostProcess.Settings[4].z);
    float _162 = _159 + (PostProcess.Settings[4].z);
    float _163 = _160 + (PostProcess.Settings[4].z);
    if (!_154) {
      float _165 = _161 * _137.x;
      float _166 = _162 * _137.y;
      float _167 = _163 * _137.z;
      _179 = _165;
      _180 = _166;
      _181 = _167;
    } else {
      float _169 = saturate(_161);
      float _170 = saturate(_162);
      float _171 = saturate(_163);
      float _172 = _137.x - _133;
      float _173 = _137.y - _134;
      float _174 = _137.z - _135;
      float _175 = _169 * _172;
      float _176 = _170 * _173;
      float _177 = _171 * _174;
      _179 = _175;
      _180 = _176;
      _181 = _177;
    }
    float _182 = _179 + _133;
    float _183 = _180 + _134;
    float _184 = _181 + _135;
    _186 = _182;
    _187 = _183;
    _188 = _184;
  } else {
    _186 = _133;
    _187 = _134;
    _188 = _135;
  }
  if (_150) {
    bool _192 = !((PostProcess.Settings[17].z) >= -1.0f);
    float _196 = (PostProcess.Settings[4].w) * _143.x;
    float _197 = (PostProcess.Settings[4].w) * _143.y;
    float _198 = (PostProcess.Settings[4].w) * _143.z;
    float _199 = _196 + (PostProcess.Settings[4].z);
    float _200 = _197 + (PostProcess.Settings[4].z);
    float _201 = _198 + (PostProcess.Settings[4].z);
    if (!_192) {
      float _203 = _199 * _137.x;
      float _204 = _200 * _137.y;
      float _205 = _201 * _137.z;
      _217 = _203;
      _218 = _204;
      _219 = _205;
    } else {
      float _207 = saturate(_199);
      float _208 = saturate(_200);
      float _209 = saturate(_201);
      float _210 = _137.x - _186;
      float _211 = _137.y - _187;
      float _212 = _137.z - _188;
      float _213 = _207 * _210;
      float _214 = _208 * _211;
      float _215 = _209 * _212;
      _217 = _213;
      _218 = _214;
      _219 = _215;
    }
    float _220 = _217 + _186;
    float _221 = _218 + _187;
    float _222 = _219 + _188;
    _224 = _220;
    _225 = _221;
    _226 = _222;
  } else {
    _224 = _186;
    _225 = _187;
    _226 = _188;
  }
  float4 _230 = sExposureScale.Load(int3(0, 0, 0));
  float _236 = _230.x * (Global.Global.c[87].y);
  float _237 = _236 * _224;
  float _238 = _237 * (PostProcess.Settings[14].x);
  float _239 = _236 * _225;
  float _240 = _239 * (PostProcess.Settings[14].y);
  float _241 = _236 * _226;
  float _242 = _241 * (PostProcess.Settings[14].z);
  float _247 = _52 * 2.0f;
  float _248 = _53 * 2.0f;
  float _249 = _247 + -1.0f;
  float _250 = _248 + -1.0f;
  float _253 = (PostProcess.Settings[13].w) * _250;
  float _254 = _249 * _249;
  float _255 = _253 * _253;
  float _256 = _255 + _254;
  float _257 = sqrt(_256);
  float _259 = (PostProcess.Settings[13].x) * _257;
  float _261 = _259 + (PostProcess.Settings[13].y);
  float _262 = saturate(_261);
  float _264 = log2(_262);
  float _265 = _264 * (PostProcess.Settings[13].z);
  float _266 = ResonanceScaleVignetteMask(exp2(_265));
  float _267 = _238 * (PostProcess.Settings[12].x);
  float _268 = _240 * (PostProcess.Settings[12].y);
  float _269 = _242 * (PostProcess.Settings[12].z);
  float _270 = _267 - _238;
  float _271 = _268 - _240;
  float _272 = _269 - _242;
  float _273 = _266 * _270;
  float _274 = _266 * _271;
  float _275 = _266 * _272;
  float _276 = _273 + _238;
  float _277 = _274 + _240;
  float _278 = _275 + _242;
  float _281 = (PostProcess.Settings[10].w) * 1.1190600395202637f;
  float _282 = _281 * _276;
  float _283 = _281 * _277;
  float _284 = _281 * _278;
  float _285 = _282 + 1.0f;
  float _286 = _283 + 1.0f;
  float _287 = _284 + 1.0f;
  float _288 = log2(_285);
  float _289 = log2(_286);
  float _290 = log2(_287);
  float _293 = (PostProcess.OffsetWeight[0].x) * 0.07434873282909393f;
  float _294 = _293 * _288;
  float _295 = _293 * _289;
  float _296 = _293 * _290;
  float _298 = _294 + (PostProcess.OffsetWeight[0].y);
  float _299 = _295 + (PostProcess.OffsetWeight[0].y);
  float _300 = _296 + (PostProcess.OffsetWeight[0].y);
  float4 _303 = s3_3D.Sample(s3_3DSampler, float3(_298, _299, _300));
  float _309 = _303.x * 13.450128555297852f;
  float _310 = _303.y * 13.450128555297852f;
  float _311 = _303.z * 13.450128555297852f;
  float _312 = exp2(_309);
  float _313 = exp2(_310);
  float _314 = exp2(_311);
  float _315 = _312 + -1.0f;
  float _316 = _313 + -1.0f;
  float _317 = _314 + -1.0f;
  float _318 = 0.8936070799827576f / (PostProcess.Settings[10].w);
  float _319 = _318 * _315;
  float _320 = _318 * _316;
  float _321 = _318 * _317;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_282 * _318, _283 * _318, _284 * _318),
      float3(_319, _320, _321),
      1.f.xxx);
  _319 = resonance_scaled_lut_output.x;
  _320 = resonance_scaled_lut_output.y;
  _321 = resonance_scaled_lut_output.z;
  bool _324 = ((User.c[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_324) {
    float _326 = (PostProcess.Settings[10].w) * 1.1190600395202637f;
    float _327 = _319 * _326;
    float _328 = _320 * _326;
    float _329 = _321 * _326;
    float _330 = _327 + 1.0f;
    float _331 = _328 + 1.0f;
    float _332 = _329 + 1.0f;
    float _333 = log2(_330);
    float _334 = log2(_331);
    float _335 = log2(_332);
    float _336 = _333 * 0.07434873282909393f;
    float _337 = _334 * 0.07434873282909393f;
    float _338 = _335 * 0.07434873282909393f;
    int _340 = asint((User.c[3].y));
    int _341 = _340 & 1;
    bool _342 = (_341 == 0);
    if (!_342) {
      bool _359 = !(_336 <= (User.c[4].x));
      if (!_359) {
        float _361 = max(9.999999974752427e-07f, (User.c[4].x));
        float _362 = _336 / _361;
        float _363 = _362 * (User.c[4].y);
        float _364 = _362 * _362;
        float _365 = _364 * _362;
        float _366 = _365 - _362;
        float _367 = (User.c[10].x) * 0.1666666716337204f;
        float _368 = _361 * _361;
        float _369 = _368 * _367;
        float _370 = _369 * _366;
        float _371 = _370 + _363;
        _461 = _371;
      } else {
        bool _373 = !(_336 <= (User.c[4].z));
        if (!_373) {
          float _375 = (User.c[4].z) - (User.c[4].x);
          float _376 = max(9.999999974752427e-07f, _375);
          float _377 = _336 - (User.c[4].x);
          float _378 = _377 / _376;
          float _379 = 1.0f - _378;
          float _380 = _379 * (User.c[4].y);
          float _381 = _378 * (User.c[4].w);
          float _382 = _380 + _381;
          float _383 = _379 * _379;
          float _384 = _383 * _379;
          float _385 = _384 - _379;
          float _386 = _385 * (User.c[10].x);
          float _387 = _378 * _378;
          float _388 = _387 * _378;
          float _389 = _388 - _378;
          float _390 = _389 * (User.c[10].y);
          float _391 = _386 + _390;
          float _392 = _376 * _376;
          float _393 = _392 * 0.1666666716337204f;
          float _394 = _393 * _391;
          float _395 = _382 + _394;
          _461 = _395;
        } else {
          bool _397 = !(_336 <= (User.c[9].x));
          if (!_397) {
            float _399 = (User.c[9].x) - (User.c[4].z);
            float _400 = max(9.999999974752427e-07f, _399);
            float _401 = _336 - (User.c[4].z);
            float _402 = _401 / _400;
            float _403 = 1.0f - _402;
            float _404 = _403 * (User.c[4].w);
            float _405 = _402 * (User.c[9].y);
            float _406 = _404 + _405;
            float _407 = _403 * _403;
            float _408 = _407 * _403;
            float _409 = _408 - _403;
            float _410 = _409 * (User.c[10].y);
            float _411 = _402 * _402;
            float _412 = _411 * _402;
            float _413 = _412 - _402;
            float _414 = _413 * (User.c[10].z);
            float _415 = _410 + _414;
            float _416 = _400 * _400;
            float _417 = _416 * 0.1666666716337204f;
            float _418 = _417 * _415;
            float _419 = _406 + _418;
            _461 = _419;
          } else {
            bool _421 = !(_336 <= (User.c[9].z));
            if (!_421) {
              float _423 = (User.c[9].z) - (User.c[9].x);
              float _424 = max(9.999999974752427e-07f, _423);
              float _425 = _336 - (User.c[9].x);
              float _426 = _425 / _424;
              float _427 = 1.0f - _426;
              float _428 = _427 * (User.c[9].y);
              float _429 = _426 * (User.c[9].w);
              float _430 = _428 + _429;
              float _431 = _427 * _427;
              float _432 = _431 * _427;
              float _433 = _432 - _427;
              float _434 = _433 * (User.c[10].z);
              float _435 = _426 * _426;
              float _436 = _435 * _426;
              float _437 = _436 - _426;
              float _438 = _437 * (User.c[10].w);
              float _439 = _434 + _438;
              float _440 = _424 * _424;
              float _441 = _440 * 0.1666666716337204f;
              float _442 = _441 * _439;
              float _443 = _430 + _442;
              _461 = _443;
            } else {
              float _445 = 1.0f - (User.c[9].z);
              float _446 = _336 - (User.c[9].z);
              float _447 = max(9.999999974752427e-07f, _445);
              float _448 = _446 / _447;
              float _449 = 1.0f - _448;
              float _450 = _449 * (User.c[9].w);
              float _451 = _450 + _448;
              float _452 = _449 * _449;
              float _453 = _452 * _449;
              float _454 = _453 - _449;
              float _455 = (User.c[10].w) * 0.1666666716337204f;
              float _456 = _445 * _445;
              float _457 = _456 * _455;
              float _458 = _457 * _454;
              float _459 = _451 + _458;
              _461 = _459;
            }
          }
        }
      }
      float _462 = saturate(_461);
      bool _463 = !(_337 <= (User.c[4].x));
      if (!_463) {
        float _465 = max(9.999999974752427e-07f, (User.c[4].x));
        float _466 = _337 / _465;
        float _467 = _466 * (User.c[4].y);
        float _468 = _466 * _466;
        float _469 = _468 * _466;
        float _470 = _469 - _466;
        float _471 = (User.c[10].x) * 0.1666666716337204f;
        float _472 = _465 * _465;
        float _473 = _472 * _471;
        float _474 = _473 * _470;
        float _475 = _474 + _467;
        _565 = _475;
      } else {
        bool _477 = !(_337 <= (User.c[4].z));
        if (!_477) {
          float _479 = (User.c[4].z) - (User.c[4].x);
          float _480 = max(9.999999974752427e-07f, _479);
          float _481 = _337 - (User.c[4].x);
          float _482 = _481 / _480;
          float _483 = 1.0f - _482;
          float _484 = _483 * (User.c[4].y);
          float _485 = _482 * (User.c[4].w);
          float _486 = _484 + _485;
          float _487 = _483 * _483;
          float _488 = _487 * _483;
          float _489 = _488 - _483;
          float _490 = _489 * (User.c[10].x);
          float _491 = _482 * _482;
          float _492 = _491 * _482;
          float _493 = _492 - _482;
          float _494 = _493 * (User.c[10].y);
          float _495 = _490 + _494;
          float _496 = _480 * _480;
          float _497 = _496 * 0.1666666716337204f;
          float _498 = _497 * _495;
          float _499 = _486 + _498;
          _565 = _499;
        } else {
          bool _501 = !(_337 <= (User.c[9].x));
          if (!_501) {
            float _503 = (User.c[9].x) - (User.c[4].z);
            float _504 = max(9.999999974752427e-07f, _503);
            float _505 = _337 - (User.c[4].z);
            float _506 = _505 / _504;
            float _507 = 1.0f - _506;
            float _508 = _507 * (User.c[4].w);
            float _509 = _506 * (User.c[9].y);
            float _510 = _508 + _509;
            float _511 = _507 * _507;
            float _512 = _511 * _507;
            float _513 = _512 - _507;
            float _514 = _513 * (User.c[10].y);
            float _515 = _506 * _506;
            float _516 = _515 * _506;
            float _517 = _516 - _506;
            float _518 = _517 * (User.c[10].z);
            float _519 = _514 + _518;
            float _520 = _504 * _504;
            float _521 = _520 * 0.1666666716337204f;
            float _522 = _521 * _519;
            float _523 = _510 + _522;
            _565 = _523;
          } else {
            bool _525 = !(_337 <= (User.c[9].z));
            if (!_525) {
              float _527 = (User.c[9].z) - (User.c[9].x);
              float _528 = max(9.999999974752427e-07f, _527);
              float _529 = _337 - (User.c[9].x);
              float _530 = _529 / _528;
              float _531 = 1.0f - _530;
              float _532 = _531 * (User.c[9].y);
              float _533 = _530 * (User.c[9].w);
              float _534 = _532 + _533;
              float _535 = _531 * _531;
              float _536 = _535 * _531;
              float _537 = _536 - _531;
              float _538 = _537 * (User.c[10].z);
              float _539 = _530 * _530;
              float _540 = _539 * _530;
              float _541 = _540 - _530;
              float _542 = _541 * (User.c[10].w);
              float _543 = _538 + _542;
              float _544 = _528 * _528;
              float _545 = _544 * 0.1666666716337204f;
              float _546 = _545 * _543;
              float _547 = _534 + _546;
              _565 = _547;
            } else {
              float _549 = 1.0f - (User.c[9].z);
              float _550 = _337 - (User.c[9].z);
              float _551 = max(9.999999974752427e-07f, _549);
              float _552 = _550 / _551;
              float _553 = 1.0f - _552;
              float _554 = _553 * (User.c[9].w);
              float _555 = _554 + _552;
              float _556 = _553 * _553;
              float _557 = _556 * _553;
              float _558 = _557 - _553;
              float _559 = (User.c[10].w) * 0.1666666716337204f;
              float _560 = _549 * _549;
              float _561 = _560 * _559;
              float _562 = _561 * _558;
              float _563 = _555 + _562;
              _565 = _563;
            }
          }
        }
      }
      float _566 = saturate(_565);
      bool _567 = !(_338 <= (User.c[4].x));
      if (!_567) {
        float _569 = max(9.999999974752427e-07f, (User.c[4].x));
        float _570 = _338 / _569;
        float _571 = _570 * (User.c[4].y);
        float _572 = _570 * _570;
        float _573 = _572 * _570;
        float _574 = _573 - _570;
        float _575 = (User.c[10].x) * 0.1666666716337204f;
        float _576 = _569 * _569;
        float _577 = _576 * _575;
        float _578 = _577 * _574;
        float _579 = _578 + _571;
        _669 = _579;
      } else {
        bool _581 = !(_338 <= (User.c[4].z));
        if (!_581) {
          float _583 = (User.c[4].z) - (User.c[4].x);
          float _584 = max(9.999999974752427e-07f, _583);
          float _585 = _338 - (User.c[4].x);
          float _586 = _585 / _584;
          float _587 = 1.0f - _586;
          float _588 = _587 * (User.c[4].y);
          float _589 = _586 * (User.c[4].w);
          float _590 = _588 + _589;
          float _591 = _587 * _587;
          float _592 = _591 * _587;
          float _593 = _592 - _587;
          float _594 = _593 * (User.c[10].x);
          float _595 = _586 * _586;
          float _596 = _595 * _586;
          float _597 = _596 - _586;
          float _598 = _597 * (User.c[10].y);
          float _599 = _594 + _598;
          float _600 = _584 * _584;
          float _601 = _600 * 0.1666666716337204f;
          float _602 = _601 * _599;
          float _603 = _590 + _602;
          _669 = _603;
        } else {
          bool _605 = !(_338 <= (User.c[9].x));
          if (!_605) {
            float _607 = (User.c[9].x) - (User.c[4].z);
            float _608 = max(9.999999974752427e-07f, _607);
            float _609 = _338 - (User.c[4].z);
            float _610 = _609 / _608;
            float _611 = 1.0f - _610;
            float _612 = _611 * (User.c[4].w);
            float _613 = _610 * (User.c[9].y);
            float _614 = _612 + _613;
            float _615 = _611 * _611;
            float _616 = _615 * _611;
            float _617 = _616 - _611;
            float _618 = _617 * (User.c[10].y);
            float _619 = _610 * _610;
            float _620 = _619 * _610;
            float _621 = _620 - _610;
            float _622 = _621 * (User.c[10].z);
            float _623 = _618 + _622;
            float _624 = _608 * _608;
            float _625 = _624 * 0.1666666716337204f;
            float _626 = _625 * _623;
            float _627 = _614 + _626;
            _669 = _627;
          } else {
            bool _629 = !(_338 <= (User.c[9].z));
            if (!_629) {
              float _631 = (User.c[9].z) - (User.c[9].x);
              float _632 = max(9.999999974752427e-07f, _631);
              float _633 = _338 - (User.c[9].x);
              float _634 = _633 / _632;
              float _635 = 1.0f - _634;
              float _636 = _635 * (User.c[9].y);
              float _637 = _634 * (User.c[9].w);
              float _638 = _636 + _637;
              float _639 = _635 * _635;
              float _640 = _639 * _635;
              float _641 = _640 - _635;
              float _642 = _641 * (User.c[10].z);
              float _643 = _634 * _634;
              float _644 = _643 * _634;
              float _645 = _644 - _634;
              float _646 = _645 * (User.c[10].w);
              float _647 = _642 + _646;
              float _648 = _632 * _632;
              float _649 = _648 * 0.1666666716337204f;
              float _650 = _649 * _647;
              float _651 = _638 + _650;
              _669 = _651;
            } else {
              float _653 = 1.0f - (User.c[9].z);
              float _654 = _338 - (User.c[9].z);
              float _655 = max(9.999999974752427e-07f, _653);
              float _656 = _654 / _655;
              float _657 = 1.0f - _656;
              float _658 = _657 * (User.c[9].w);
              float _659 = _658 + _656;
              float _660 = _657 * _657;
              float _661 = _660 * _657;
              float _662 = _661 - _657;
              float _663 = (User.c[10].w) * 0.1666666716337204f;
              float _664 = _653 * _653;
              float _665 = _664 * _663;
              float _666 = _665 * _662;
              float _667 = _659 + _666;
              _669 = _667;
            }
          }
        }
      }
      float _670 = saturate(_669);
      _672 = _462;
      _673 = _566;
      _674 = _670;
    } else {
      _672 = _336;
      _673 = _337;
      _674 = _338;
    }
    int _675 = _340 & 2;
    bool _676 = (_675 == 0);
    if (!_676) {
      float _678 = sqrt(_672);
      float _679 = sqrt(_673);
      float _680 = sqrt(_674);
      float _681 = dot(float3(_678, _679, _680), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _682 = 1.0f - _681;
      float _683 = saturate(_682);
      _685 = _683;
    } else {
      _685 = 1.0f;
    }
    int _686 = _340 & 8;
    bool _687 = (_686 == 0);
    if (_687) {
      int _689 = _340 & 4;
      bool _690 = (_689 == 0);
      if (!_690) {
        int _692 = _340 & 16;
        bool _693 = (_692 == 0);
        if (!_693) {
          float _697 = (User.c[5].x) * 0.5f;
          float _698 = _697 + 0.5f;
          bool _699 = (_698 < 0.5f);
          float _700 = (User.c[5].x) * 5.0f;
          float _701 = select(_699, (User.c[5].x), _700);
          bool _702 = (_673 < _674);
          float _703 = select(_702, _674, _673);
          float _704 = select(_702, _673, _674);
          bool _705 = (_672 < _703);
          float _706 = select(_705, _703, _672);
          float _707 = select(_705, _672, _703);
          float _708 = min(_707, _704);
          float _709 = _706 - _708;
          float _710 = _706 + 1.000000013351432e-10f;
          float _711 = _709 / _710;
          float _713 = _711 - (User.c[5].y);
          float _714 = saturate(_713);
          float _715 = max(_714, 9.999999974752427e-07f);
          float _716 = log2(_715);
          float _717 = _716 * _701;
          float _718 = exp2(_717);
          float _719 = 2.0f - _718;
          float _721 = 1.0f - (User.c[5].z);
          float _722 = saturate(_721);
          float _723 = max(_722, _719);
          float _724 = dot(float3(_672, _673, _674), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _725 = _672 - _724;
          float _726 = _673 - _724;
          float _727 = _674 - _724;
          float _728 = _725 * _723;
          float _729 = _726 * _723;
          float _730 = _727 * _723;
          float _731 = _724 - _672;
          float _732 = _731 + _728;
          float _733 = _724 - _673;
          float _734 = _733 + _729;
          float _735 = _724 - _674;
          float _736 = _735 + _730;
          float _737 = _732 * _685;
          float _738 = _734 * _685;
          float _739 = _736 * _685;
          float _740 = _737 + _672;
          float _741 = _738 + _673;
          float _742 = _739 + _674;
          _859 = _740;
          _860 = _741;
          _861 = _742;
        } else {
          bool _744 = (_685 == 0.0f);
          if (!_744) {
            float _748 = abs(User.c[5].x);
            float _749 = saturate(_748);
            uint4 _751 = 0u; sVibranceLUT.GetDimensions(0u, _751.x, _751.y, _751.w);
            float _754 = float((uint)_751.y);
            int _755 = _340 & 32;
            bool _756 = (_755 == 0);
            float _757 = _754 + -1.0f;
            if (!_756) {
              float _759 = 1.0f / _757;
              uint _760 = uint(SV_Position.x);
              uint _761 = uint(SV_Position.y);
              int _762 = _760 & 63;
              int _763 = _761 & 63;
              float4 _765 = sBlueNoiseR8G8.Load(int4(_762, _763, 0, 0));
              float _768 = _765.x + -0.5f;
              float _769 = _672 * 13.999999046325684f;
              float _770 = _673 * 13.999999046325684f;
              float _771 = _674 * 13.999999046325684f;
              float _772 = saturate(_769);
              float _773 = saturate(_770);
              float _774 = saturate(_771);
              float _775 = _672 + -0.9285714030265808f;
              float _776 = _673 + -0.9285714030265808f;
              float _777 = _674 + -0.9285714030265808f;
              float _778 = _775 * 13.999999046325684f;
              float _779 = _776 * 13.999999046325684f;
              float _780 = _777 * 13.999999046325684f;
              float _781 = saturate(_778);
              float _782 = saturate(_779);
              float _783 = saturate(_780);
              float _784 = 1.0f - _781;
              float _785 = 1.0f - _782;
              float _786 = 1.0f - _783;
              float _787 = min(_772, _784);
              float _788 = min(_773, _785);
              float _789 = min(_774, _786);
              float _790 = _765.y + -0.5f;
              float _791 = _787 * _790;
              float _792 = _788 * _790;
              float _793 = _789 * _790;
              float _794 = _791 + _768;
              float _795 = _792 + _768;
              float _796 = _793 + _768;
              float _797 = _794 * _759;
              float _798 = _795 * _759;
              float _799 = _796 * _759;
              float _800 = _797 + _672;
              float _801 = _798 + _673;
              float _802 = _799 + _674;
              float _803 = saturate(_800);
              float _804 = saturate(_801);
              float _805 = saturate(_802);
              float _806 = saturate(_803);
              float _807 = saturate(_804);
              float _808 = saturate(_805);
              _810 = _806;
              _811 = _807;
              _812 = _808;
            } else {
              _810 = _672;
              _811 = _673;
              _812 = _674;
            }
            float _813 = float((uint)_751.x);
            float _814 = _757 / _813;
            float _815 = _814 * _810;
            float _816 = 0.5f / _813;
            float _817 = _815 + _816;
            float _818 = _757 / _754;
            float _819 = _818 * _811;
            float _820 = 0.5f / _754;
            float _821 = _819 + _820;
            float _822 = _812 * _757;
            float _823 = floor(_822);
            float _824 = frac(_822);
            float _825 = _823 / _754;
            float _826 = _825 + _817;
            float _827 = _823 + 1.0f;
            float _828 = _827 / _754;
            float _829 = _828 + _817;
            float4 _831 = sVibranceLUT.Sample(sLinearClampSampler, float2(_826, _821));
            float4 _835 = sVibranceLUT.Sample(sLinearClampSampler, float2(_829, _821));
            float _839 = _835.x - _831.x;
            float _840 = _835.y - _831.y;
            float _841 = _835.z - _831.z;
            float _842 = _839 * _824;
            float _843 = _840 * _824;
            float _844 = _841 * _824;
            float _845 = _749 * _685;
            float _846 = _831.x - _672;
            float _847 = _846 + _842;
            float _848 = _831.y - _673;
            float _849 = _848 + _843;
            float _850 = _831.z - _674;
            float _851 = _850 + _844;
            float _852 = _847 * _845;
            float _853 = _849 * _845;
            float _854 = _851 * _845;
            float _855 = _852 + _672;
            float _856 = _853 + _673;
            float _857 = _854 + _674;
            _859 = _855;
            _860 = _856;
            _861 = _857;
          } else {
            _859 = _672;
            _860 = _673;
            _861 = _674;
          }
        }
      } else {
        _859 = _672;
        _860 = _673;
        _861 = _674;
      }
    } else {
      _859 = _685;
      _860 = _685;
      _861 = _685;
    }
    float _862 = _859 * 13.450128555297852f;
    float _863 = _860 * 13.450128555297852f;
    float _864 = _861 * 13.450128555297852f;
    float _865 = exp2(_862);
    float _866 = exp2(_863);
    float _867 = exp2(_864);
    float _868 = _865 + -1.0f;
    float _869 = _866 + -1.0f;
    float _870 = _867 + -1.0f;
    float _871 = _868 * _318;
    float _872 = _869 * _318;
    float _873 = _870 * _318;
    _875 = _871;
    _876 = _872;
    _877 = _873;
  } else {
    _875 = _319;
    _876 = _320;
    _877 = _321;
  }
  float _882 = (User.c[8].x) * _875;
  float _883 = (User.c[8].y) * _876;
  float _884 = (User.c[8].z) * _877;
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3(_882, _883, _884),
      SV_Position.xy);
  float _889 = (PostProcess.Settings[10].z) * TEXCOORD.x;
  float _890 = _889 * (PostProcess.Settings[9].x);
  float _891 = (PostProcess.Settings[10].z) * TEXCOORD.y;
  float _892 = _891 * (PostProcess.Settings[9].y);
  float _895 = _890 + (PostProcess.Settings[9].z);
  float _896 = _892 + (PostProcess.Settings[9].w);
  float4 _899 = s9.Sample(s9Sampler, float2(_895, _896));
  float _903 = dot(float3(_882, _883, _884), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _906 = ((PostProcess.Settings[10].x) > 0.0f);
  int _909 = asint((Global.Global.c[1].w));
  int _910 = select(_906, _909, 0);
  float _911 = (PostProcess.Settings[10].z) * SV_Position.x;
  float _912 = (PostProcess.Settings[10].z) * SV_Position.y;
  uint _913 = uint(_911);
  uint _914 = uint(_912);
  int _915 = _913 & 63;
  int _916 = _914 & 63;
  float4 _918 = sBlueNoiseR8G8.Load(int4(_915, _916, _910, 0));
  bool _920 = ((PostProcess.Settings[10].z) < 1.0f);
  if (_920) {
    float _922 = _911 * 0.015625f;
    float _923 = _912 * 0.015625f;
    float _924 = float((uint)_909);
    float _925 = select(_906, _924, 0.0f);
    float4 _927 = sBlueNoiseR8G8.SampleLevel(sLinearWrapSampler, float3(_922, _923, _925), 0.0f);
    float _929 = _918.y - _927.y;
    float _930 = _929 * (PostProcess.Settings[10].z);
    float _931 = _930 + _927.y;
    _933 = _931;
  } else {
    _933 = _918.y;
  }
  float _934 = _899.x * -2.0f;
  float _935 = _934 * _933;
  float _936 = _933 * 2.0f;
  float _937 = _936 * _899.y;
  float _938 = _936 * _899.z;
  float _939 = _935 + _899.x;
  float _940 = _937 - _899.y;
  float _941 = _938 - _899.z;
  float _942 = _939 * _899.x;
  float _943 = _940 * _899.y;
  float _944 = _941 * _899.z;
  float _945 = _903 + 1.0f;
  float _946 = _903 / _945;
  float _947 = _946 + -9.999999747378752e-05f;
  float _948 = _947 * 1111.111083984375f;
  float _949 = saturate(_948);
  float _950 = _949 * 2.0f;
  float _951 = 3.0f - _950;
  float _952 = _949 * _949;
  float _953 = _952 * _951;
  bool _955 = ((PostProcess.Settings[10].y) > 0.0f);
  float _956 = float((bool)_955);
  float _957 = dot(float3(_942, _943, _944), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _958 = _957 - _942;
  float _959 = _957 - _943;
  float _960 = _957 - _944;
  float _961 = _958 * _956;
  float _962 = _959 * _956;
  float _963 = _960 * _956;
  float _964 = _961 + _942;
  float _965 = _962 + _943;
  float _966 = _963 + _944;
  float _970 = (PostProcess.Settings[2].y) - (PostProcess.Settings[2].x);
  float _971 = _970 * _946;
  float _972 = _971 + (PostProcess.Settings[2].x);
  float _973 = _953 * _972;
  float _974 = _973 * _964;
  float _975 = _973 * _965;
  float _976 = _973 * _966;
  float _977 = _974 + _882;
  float _978 = _975 + _883;
  float _979 = _976 + _884;
  float _980 = max(0.0f, _977);
  float _981 = max(0.0f, _978);
  float _982 = max(0.0f, _979);
  float3 resonance_film_grain_output = ResonanceSelectFilmGrainOutput(
      float3(_980, _981, _982),
      resonance_perceptual_film_grain);
  _980 = resonance_film_grain_output.x;
  _981 = resonance_film_grain_output.y;
  _982 = resonance_film_grain_output.z;
  float _985 = (PostProcess.Settings[17].y) + 2.0f;
  float _986 = log2(_980);
  float _987 = _985 * _986;
  float _988 = exp2(_987);
  float _989 = _988 + -1.0f;
  float _990 = _980 + -1.0f;
  float _991 = _989 / _990;
  bool _992 = !(_980 == 1.0f);
  float _993 = _991 + -1.0f;
  float _994 = _993 / _991;
  float _995 = (PostProcess.Settings[17].y) + 1.0f;
  float _996 = _995 / _985;
  float _997 = select(_992, _994, _996);
  float _998 = log2(_981);
  float _999 = _998 * _985;
  float _1000 = exp2(_999);
  float _1001 = _1000 + -1.0f;
  float _1002 = _981 + -1.0f;
  float _1003 = _1001 / _1002;
  bool _1004 = !(_981 == 1.0f);
  float _1005 = _1003 + -1.0f;
  float _1006 = _1005 / _1003;
  float _1007 = (PostProcess.Settings[17].y) + 1.0f;
  float _1008 = _1007 / _985;
  float _1009 = select(_1004, _1006, _1008);
  float _1010 = log2(_982);
  float _1011 = _1010 * _985;
  float _1012 = exp2(_1011);
  float _1013 = _1012 + -1.0f;
  float _1014 = _982 + -1.0f;
  float _1015 = _1013 / _1014;
  bool _1016 = !(_982 == 1.0f);
  float _1017 = _1015 + -1.0f;
  float _1018 = _1017 / _1015;
  float _1019 = (PostProcess.Settings[17].y) + 1.0f;
  float _1020 = _1019 / _985;
  float _1021 = select(_1016, _1018, _1020);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_980, _981, _982),
      float3(_997, _1009, _1021),
      true);
  float _1022 = resonance_post_process_output.x;
  float _1023 = resonance_post_process_output.y;
  float _1024 = resonance_post_process_output.z;
  float _1025 = log2(_1022);
  float _1026 = log2(_1023);
  float _1027 = log2(_1024);
  float _1028 = _1025 * 0.4166666567325592f;
  float _1029 = _1026 * 0.4166666567325592f;
  float _1030 = _1027 * 0.4166666567325592f;
  float _1031 = exp2(_1028);
  float _1032 = exp2(_1029);
  float _1033 = exp2(_1030);
  float _1034 = _1031 * 1.0549999475479126f;
  float _1035 = _1032 * 1.0549999475479126f;
  float _1036 = _1033 * 1.0549999475479126f;
  float _1037 = _1034 + -0.054999999701976776f;
  float _1038 = _1035 + -0.054999999701976776f;
  float _1039 = _1036 + -0.054999999701976776f;
  float _1040 = _1022 * 12.920000076293945f;
  float _1041 = _1023 * 12.920000076293945f;
  float _1042 = _1024 * 12.920000076293945f;
  bool _1043 = (_1022 <= 0.0031308000907301903f);
  bool _1044 = (_1023 <= 0.0031308000907301903f);
  bool _1045 = (_1024 <= 0.0031308000907301903f);
  float _1046 = select(_1043, _1040, _1037);
  float _1047 = select(_1044, _1041, _1038);
  float _1048 = select(_1045, _1042, _1039);
  uint _1049 = uint(SV_Position.x);
  uint _1050 = uint(SV_Position.y);
  int _1051 = _1049 & 63;
  int _1052 = _1050 & 63;
  float4 _1054 = sBlueNoiseR8.Load(int4(_1051, _1052, _909, 0));
  float _1056 = _1054.x + -0.5f;
  float _1057 = _1056 * 0.003921568859368563f;
  float _1058 = _1057 + _1046;
  float _1059 = _1057 + _1047;
  float _1060 = _1057 + _1048;
  float _1061 = saturate(_1058);
  float _1062 = saturate(_1059);
  float _1063 = saturate(_1060);
  SV_Target.x = _1061;
  SV_Target.y = _1062;
  SV_Target.z = _1063;
  SV_Target.w = _130.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}