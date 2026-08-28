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

SamplerState sLinearClampSampler : register(s1);

SamplerState s0Sampler : register(s0);

SamplerState s2Sampler : register(s2);

SamplerState s3_3DSampler : register(s3);

SamplerState s4Sampler : register(s4);

SamplerState s5Sampler : register(s5);

SamplerState s7Sampler : register(s7);

SamplerState s14Sampler : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _35 = s14.Sample(s14Sampler, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _41 = sPostProcessFX_MaskLayer.Sample(sLinearClampSampler, float2(TEXCOORD.z, TEXCOORD.w));
  float _43 = _41.y * 0.10000000149011612f;
  float _44 = _43 + _35.y;
  float _45 = _41.y * 0.5f;
  float _46 = _45 + _35.z;
  float _47 = exp2(_46);
  float _48 = _47 + -1.0f;
  float _51 = (PostProcess.Settings[11].y) * _48;
  float _52 = _51 + 1.0f;
  float _53 = log2(_52);
  float _54 = _35.x + TEXCOORD.z;
  float _55 = _44 + TEXCOORD.w;
  float _56 = _53 + 1.0f;
  float _57 = log2(_56);
  float4 _60 = s0.SampleLevel(sLinearClampSampler, float2(_54, _55), _57);
  bool _65 = (_57 > 0.0f);
  float _370;
  float _371;
  float _372;
  float _373;
  float _409;
  float _493;
  float _530;
  float _720;
  float _759;
  float _760;
  float _761;
  float _996;
  float _1100;
  float _1204;
  float _1207;
  float _1208;
  float _1209;
  float _1220;
  float _1345;
  float _1346;
  float _1347;
  float _1394;
  float _1395;
  float _1396;
  float _1410;
  float _1411;
  float _1412;
  [branch]
  if (_65) {
    float _67 = floor(_57);
    int _68 = int(_67);
    uint4 _69 = 0u; s0.GetDimensions(0u, _69.x, _69.y, _69.w);
    int _72 = _68 & 31;
    int _73 = (uint)(_69.x) >> _72;
    float _74 = float((uint)_73);
    int _75 = (uint)(_69.y) >> _72;
    float _76 = float((uint)_75);
    float _77 = 1.0f / _74;
    float _78 = 1.0f / _76;
    float _79 = _74 * _54;
    float _80 = _76 * _55;
    float _81 = _79 + -0.5f;
    float _82 = _80 + -0.5f;
    float _83 = frac(_81);
    float _84 = frac(_82);
    float _85 = floor(_81);
    float _86 = floor(_82);
    float _87 = 1.0f - _83;
    float _88 = 2.0f - _83;
    float _89 = 3.0f - _83;
    float _90 = _87 * _87;
    float _91 = _88 * _88;
    float _92 = _89 * _89;
    float _93 = _90 * _87;
    float _94 = _91 * _88;
    float _95 = _92 * _89;
    float _96 = _93 * 4.0f;
    float _97 = _94 - _96;
    float _98 = _94 * 4.0f;
    float _99 = _93 * 6.0f;
    float _100 = 6.0f - _93;
    float _101 = _100 - _97;
    float _102 = _98 - _95;
    float _103 = _102 - _99;
    float _104 = _103 + _101;
    float _105 = _97 * 0.1666666716337204f;
    float _106 = _104 * 0.1666666716337204f;
    float _107 = 1.0f - _84;
    float _108 = 2.0f - _84;
    float _109 = 3.0f - _84;
    float _110 = _107 * _107;
    float _111 = _108 * _108;
    float _112 = _109 * _109;
    float _113 = _110 * _107;
    float _114 = _111 * _108;
    float _115 = _112 * _109;
    float _116 = _113 * 4.0f;
    float _117 = _114 - _116;
    float _118 = _114 * 4.0f;
    float _119 = _113 * 6.0f;
    float _120 = 6.0f - _113;
    float _121 = _120 - _117;
    float _122 = _118 - _115;
    float _123 = _122 - _119;
    float _124 = _123 + _121;
    float _125 = _117 * 0.1666666716337204f;
    float _126 = _124 * 0.1666666716337204f;
    float _127 = _85 + -0.5f;
    float _128 = _85 + 1.5f;
    float _129 = _86 + -0.5f;
    float _130 = _86 + 1.5f;
    float _131 = _97 + _93;
    float _132 = _131 * 0.1666666716337204f;
    float _133 = _101 * 0.1666666716337204f;
    float _134 = _117 + _113;
    float _135 = _134 * 0.1666666716337204f;
    float _136 = _121 * 0.1666666716337204f;
    float _137 = _105 / _132;
    float _138 = _106 / _133;
    float _139 = _125 / _135;
    float _140 = _126 / _136;
    float _141 = _127 + _137;
    float _142 = _128 + _138;
    float _143 = _129 + _139;
    float _144 = _130 + _140;
    float _145 = _141 * _77;
    float _146 = _142 * _77;
    float _147 = _143 * _78;
    float _148 = _144 * _78;
    float _149 = float((int)(_68));
    float4 _151 = s0.SampleLevel(s0Sampler, float2(_145, _147), _149);
    float4 _156 = s0.SampleLevel(s0Sampler, float2(_146, _147), _149);
    float4 _161 = s0.SampleLevel(s0Sampler, float2(_145, _148), _149);
    float4 _166 = s0.SampleLevel(s0Sampler, float2(_146, _148), _149);
    float _171 = _151.x - _156.x;
    float _172 = _151.y - _156.y;
    float _173 = _151.z - _156.z;
    float _174 = _151.w - _156.w;
    float _175 = _171 * _132;
    float _176 = _172 * _132;
    float _177 = _173 * _132;
    float _178 = _174 * _132;
    float _179 = _175 + _156.x;
    float _180 = _176 + _156.y;
    float _181 = _177 + _156.z;
    float _182 = _178 + _156.w;
    float _183 = _161.x - _166.x;
    float _184 = _161.y - _166.y;
    float _185 = _161.z - _166.z;
    float _186 = _161.w - _166.w;
    float _187 = _183 * _132;
    float _188 = _184 * _132;
    float _189 = _185 * _132;
    float _190 = _186 * _132;
    float _191 = _187 + _166.x;
    float _192 = _188 + _166.y;
    float _193 = _189 + _166.z;
    float _194 = _190 + _166.w;
    float _195 = _179 - _191;
    float _196 = _180 - _192;
    float _197 = _181 - _193;
    float _198 = _182 - _194;
    float _199 = _195 * _135;
    float _200 = _196 * _135;
    float _201 = _197 * _135;
    float _202 = _198 * _135;
    float _203 = _199 + _191;
    float _204 = _200 + _192;
    float _205 = _201 + _193;
    float _206 = _202 + _194;
    float _207 = ceil(_57);
    int _208 = int(_207);
    int _209 = _208 & 31;
    int _210 = (uint)(_69.x) >> _209;
    float _211 = float((uint)_210);
    int _212 = (uint)(_69.y) >> _209;
    float _213 = float((uint)_212);
    float _214 = 1.0f / _211;
    float _215 = 1.0f / _213;
    float _216 = _211 * _54;
    float _217 = _213 * _55;
    float _218 = _216 + -0.5f;
    float _219 = _217 + -0.5f;
    float _220 = frac(_218);
    float _221 = frac(_219);
    float _222 = floor(_218);
    float _223 = floor(_219);
    float _224 = 1.0f - _220;
    float _225 = 2.0f - _220;
    float _226 = 3.0f - _220;
    float _227 = _224 * _224;
    float _228 = _225 * _225;
    float _229 = _226 * _226;
    float _230 = _227 * _224;
    float _231 = _228 * _225;
    float _232 = _229 * _226;
    float _233 = _230 * 4.0f;
    float _234 = _231 - _233;
    float _235 = _231 * 4.0f;
    float _236 = _230 * 6.0f;
    float _237 = 6.0f - _230;
    float _238 = _237 - _234;
    float _239 = _235 - _232;
    float _240 = _239 - _236;
    float _241 = _240 + _238;
    float _242 = _234 * 0.1666666716337204f;
    float _243 = _241 * 0.1666666716337204f;
    float _244 = 1.0f - _221;
    float _245 = 2.0f - _221;
    float _246 = 3.0f - _221;
    float _247 = _244 * _244;
    float _248 = _245 * _245;
    float _249 = _246 * _246;
    float _250 = _247 * _244;
    float _251 = _248 * _245;
    float _252 = _249 * _246;
    float _253 = _250 * 4.0f;
    float _254 = _251 - _253;
    float _255 = _251 * 4.0f;
    float _256 = _250 * 6.0f;
    float _257 = 6.0f - _250;
    float _258 = _257 - _254;
    float _259 = _255 - _252;
    float _260 = _259 - _256;
    float _261 = _260 + _258;
    float _262 = _254 * 0.1666666716337204f;
    float _263 = _261 * 0.1666666716337204f;
    float _264 = _222 + -0.5f;
    float _265 = _222 + 1.5f;
    float _266 = _223 + -0.5f;
    float _267 = _223 + 1.5f;
    float _268 = _234 + _230;
    float _269 = _268 * 0.1666666716337204f;
    float _270 = _238 * 0.1666666716337204f;
    float _271 = _254 + _250;
    float _272 = _271 * 0.1666666716337204f;
    float _273 = _258 * 0.1666666716337204f;
    float _274 = _242 / _269;
    float _275 = _243 / _270;
    float _276 = _262 / _272;
    float _277 = _263 / _273;
    float _278 = _264 + _274;
    float _279 = _265 + _275;
    float _280 = _266 + _276;
    float _281 = _267 + _277;
    float _282 = _278 * _214;
    float _283 = _279 * _214;
    float _284 = _280 * _215;
    float _285 = _281 * _215;
    float _286 = float((int)(_208));
    float4 _287 = s0.SampleLevel(s0Sampler, float2(_282, _284), _286);
    float4 _292 = s0.SampleLevel(s0Sampler, float2(_283, _284), _286);
    float4 _297 = s0.SampleLevel(s0Sampler, float2(_282, _285), _286);
    float4 _302 = s0.SampleLevel(s0Sampler, float2(_283, _285), _286);
    float _307 = _287.x - _292.x;
    float _308 = _287.y - _292.y;
    float _309 = _287.z - _292.z;
    float _310 = _287.w - _292.w;
    float _311 = _307 * _269;
    float _312 = _308 * _269;
    float _313 = _309 * _269;
    float _314 = _310 * _269;
    float _315 = _311 + _292.x;
    float _316 = _312 + _292.y;
    float _317 = _313 + _292.z;
    float _318 = _314 + _292.w;
    float _319 = _297.x - _302.x;
    float _320 = _297.y - _302.y;
    float _321 = _297.z - _302.z;
    float _322 = _297.w - _302.w;
    float _323 = _319 * _269;
    float _324 = _320 * _269;
    float _325 = _321 * _269;
    float _326 = _322 * _269;
    float _327 = _323 + _302.x;
    float _328 = _324 + _302.y;
    float _329 = _325 + _302.z;
    float _330 = _326 + _302.w;
    float _331 = _315 - _327;
    float _332 = _316 - _328;
    float _333 = _317 - _329;
    float _334 = _318 - _330;
    float _335 = _331 * _272;
    float _336 = _332 * _272;
    float _337 = _333 * _272;
    float _338 = _334 * _272;
    float _339 = frac(_57);
    float _340 = _327 - _203;
    float _341 = _340 + _335;
    float _342 = _328 - _204;
    float _343 = _342 + _336;
    float _344 = _329 - _205;
    float _345 = _344 + _337;
    float _346 = _330 - _206;
    float _347 = _346 + _338;
    float _348 = _341 * _339;
    float _349 = _343 * _339;
    float _350 = _345 * _339;
    float _351 = _347 * _339;
    float _352 = saturate(_57);
    float _353 = _203 - _60.x;
    float _354 = _353 + _348;
    float _355 = _204 - _60.y;
    float _356 = _355 + _349;
    float _357 = _205 - _60.z;
    float _358 = _357 + _350;
    float _359 = _206 - _60.w;
    float _360 = _359 + _351;
    float _361 = _354 * _352;
    float _362 = _356 * _352;
    float _363 = _358 * _352;
    float _364 = _360 * _352;
    float _365 = _361 + _60.x;
    float _366 = _362 + _60.y;
    float _367 = _363 + _60.z;
    float _368 = _364 + _60.w;
    _370 = _365;
    _371 = _366;
    _372 = _367;
    _373 = _368;
  } else {
    _370 = _60.x;
    _371 = _60.y;
    _372 = _60.z;
    _373 = _60.w;
  }
  float _374 = max(_370, 0.0f);
  float _375 = max(_371, 0.0f);
  float _376 = max(_372, 0.0f);
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
      float3(_374, _375, _376),
      float3(_374, _375, _376),
      float2(_54, _55),
      s0,
      sLinearClampSampler,
      _57);
  _374 = renodx_chromatic_aberration_input.x;
  _375 = renodx_chromatic_aberration_input.y;
  _376 = renodx_chromatic_aberration_input.z;
  int _379 = asint((User.c[7].z));
  bool _380 = ((int)_379 > (int)0);
  [branch]
  if (_380) {
    bool _385 = ((PostProcess.Settings[7].x) > 0.0f);
    if (_385) {
      float _387 = _35.x + TEXCOORD.x;
      float _388 = _44 + TEXCOORD.y;
      float4 _391 = s2.SampleLevel(s2Sampler, float2(_387, _388), 0.0f);
      bool _395 = ((PostProcess.Settings[6].y) == 1.0f);
      if (_395) {
        float4 _398 = s7.Load(int3(0, 0, 0));
        float _403 = _398.x - (Global.Proj.m[0][2].z);
        float _404 = (Global.Proj.m[0][2].w) / _403;
        _409 = _404;
      } else {
        _409 = (PostProcess.Settings[5].x);
      }
      float _413 = _391.x - (Global.Proj.m[0][2].z);
      float _414 = (Global.Proj.m[0][2].w) / _413;
      float _416 = _409 * (PostProcess.Settings[6].w);
      float _417 = _416 + _409;
      float _418 = _409 - _416;
      float _419 = max(_414, _418);
      float _420 = min(_419, _417);
      float _423 = _414 - _420;
      float _424 = (PostProcess.Settings[5].w) * _423;
      float _426 = _420 - (PostProcess.Settings[5].y);
      float _427 = _426 * _414;
      float _428 = _424 / _427;
      float _429 = min(_428, 0.0f);
      float _431 = _416 + 1.0f;
      float _432 = 1.0f / _431;
      float _433 = _429 * (PostProcess.Settings[7].z);
      float _434 = max(0.0f, _428);
      float _437 = (PostProcess.Settings[18].x) * _434;
      float _438 = _437 + _433;
      float _439 = _438 * _432;
      float _440 = max(_439, -1.0f);
      float _441 = min(_440, 1.0f);
      float _442 = max(_441, -0.30000001192092896f);
      float _443 = min(_442, 1.0f);
      float _445 = -0.0f - (PostProcess.Settings[6].x);
      float _446 = _443 * _445;
      float _447 = _387 + -0.5f;
      float _448 = _388 + -0.5f;
      float _449 = _447 * _447;
      float _450 = _448 * _448;
      float _451 = _450 + _449;
      float _452 = sqrt(_451);
      float _453 = log2(_452);
      float _454 = _453 * (PostProcess.Settings[7].y);
      float _455 = exp2(_454);
      float _456 = _455 * (PostProcess.Settings[7].x);
      float _457 = dot(float2(_447, _448), float2(_447, _448));
      float _458 = rsqrt(_457);
      float _459 = _458 * _447;
      float _460 = _458 * _448;
      float _461 = abs(_446);
      float _465 = _456 * _461;
      float _466 = -0.0f - _465;
      float _467 = (User.c[2].x) * _459;
      float _468 = _467 * _466;
      float _469 = (User.c[2].y) * _460;
      float _470 = _469 * _466;
      float _471 = _461 * _456;
      float _472 = _467 * _471;
      float _473 = _469 * _471;
      float _474 = _468 + _387;
      float _475 = _470 + _388;
      float _476 = _472 + _387;
      float _477 = _473 + _388;
      float4 _478 = s0.SampleLevel(sLinearClampSampler, float2(_474, _475), 0.0f);
      float4 _480 = s0.SampleLevel(sLinearClampSampler, float2(_476, _477), 0.0f);
      float4 _482 = s2.SampleLevel(s2Sampler, float2(_474, _475), 0.0f);
      if (_395) {
        float4 _486 = s7.Load(int3(0, 0, 0));
        float _488 = _486.x - (Global.Proj.m[0][2].z);
        float _489 = (Global.Proj.m[0][2].w) / _488;
        _493 = _489;
      } else {
        _493 = (PostProcess.Settings[5].x);
      }
      float _494 = _482.x - (Global.Proj.m[0][2].z);
      float _495 = (Global.Proj.m[0][2].w) / _494;
      float _496 = _493 * (PostProcess.Settings[6].w);
      float _497 = _496 + _493;
      float _498 = _493 - _496;
      float _499 = max(_495, _498);
      float _500 = min(_499, _497);
      float _501 = _495 - _500;
      float _502 = _501 * (PostProcess.Settings[5].w);
      float _503 = _500 - (PostProcess.Settings[5].y);
      float _504 = _503 * _495;
      float _505 = _502 / _504;
      float _506 = min(_505, 0.0f);
      float _507 = _496 + 1.0f;
      float _508 = 1.0f / _507;
      float _509 = _506 * (PostProcess.Settings[7].z);
      float _510 = max(0.0f, _505);
      float _511 = _510 * (PostProcess.Settings[18].x);
      float _512 = _511 + _509;
      float _513 = _512 * _508;
      float _514 = max(_513, -1.0f);
      float _515 = min(_514, 1.0f);
      float _516 = max(_515, -0.30000001192092896f);
      float _517 = min(_516, 1.0f);
      float _518 = _517 * _445;
      float4 _519 = s2.SampleLevel(s2Sampler, float2(_476, _477), 0.0f);
      if (_395) {
        float4 _523 = s7.Load(int3(0, 0, 0));
        float _525 = _523.x - (Global.Proj.m[0][2].z);
        float _526 = (Global.Proj.m[0][2].w) / _525;
        _530 = _526;
      } else {
        _530 = (PostProcess.Settings[5].x);
      }
      float _531 = _519.x - (Global.Proj.m[0][2].z);
      float _532 = (Global.Proj.m[0][2].w) / _531;
      float _533 = _530 * (PostProcess.Settings[6].w);
      float _534 = _533 + _530;
      float _535 = _530 - _533;
      float _536 = max(_532, _535);
      float _537 = min(_536, _534);
      float _538 = _532 - _537;
      float _539 = _538 * (PostProcess.Settings[5].w);
      float _540 = _537 - (PostProcess.Settings[5].y);
      float _541 = _540 * _532;
      float _542 = _539 / _541;
      float _543 = min(_542, 0.0f);
      float _544 = _533 + 1.0f;
      float _545 = 1.0f / _544;
      float _546 = _543 * (PostProcess.Settings[7].z);
      float _547 = max(0.0f, _542);
      float _548 = _547 * (PostProcess.Settings[18].x);
      float _549 = _548 + _546;
      float _550 = _549 * _545;
      float _551 = max(_550, -1.0f);
      float _552 = min(_551, 1.0f);
      float _553 = max(_552, -0.30000001192092896f);
      float _554 = min(_553, 1.0f);
      float _555 = _554 * _445;
      float _556 = abs(_518);
      float _557 = _556 / (PostProcess.Settings[6].x);
      float _558 = ceil(_557);
      float _559 = saturate(_558);
      float _560 = _478.x - _374;
      float _561 = _559 * _560;
      float _562 = _561 + _374;
      float _563 = abs(_555);
      float _564 = _563 / (PostProcess.Settings[6].x);
      float _565 = ceil(_564);
      float _566 = saturate(_565);
      float _567 = _480.z - _376;
      float _568 = _566 * _567;
      float _569 = _568 + _376;
      _759 = _562;
      _760 = _375;
      _761 = _569;
    } else {
      _759 = _374;
      _760 = _375;
      _761 = _376;
    }
  } else {
    int _572 = asint((User.c[7].y));
    bool _573 = ((int)_572 > (int)0);
    if (_573) {
      float _575 = _35.x + TEXCOORD.x;
      float _576 = _44 + TEXCOORD.y;
      float4 _579 = s4.Sample(s4Sampler, float2(_575, _576));
      float4 _586 = s5.Sample(s5Sampler, float2(_575, _576));
      float _590 = (PostProcess.Settings[6].x) * _586.x;
      float _594 = _590 * (PostProcess.Settings[7].x);
      float _595 = _590 * (PostProcess.Settings[7].y);
      float _596 = _594 + _575;
      float _597 = _595 + _576;
      float4 _598 = s4.Sample(s4Sampler, float2(_596, _597));
      float4 _600 = s5.Sample(s5Sampler, float2(_596, _597));
      float _602 = _600.x * (PostProcess.Settings[6].x);
      float _603 = abs(_602);
      float _605 = _603 / (PostProcess.Settings[7].w);
      float _606 = _598.z - _579.z;
      float _607 = _605 * _606;
      float _608 = _579.x - _374;
      float _609 = _579.y - _375;
      float _610 = _579.z - _376;
      float _611 = _610 + _607;
      float _612 = _608 * _579.w;
      float _613 = _609 * _579.w;
      float _614 = _611 * _579.w;
      float _615 = _612 + _374;
      float _616 = _613 + _375;
      float _617 = _614 + _376;
      _759 = _615;
      _760 = _616;
      _761 = _617;
    } else {
      int _620 = asint((User.c[7].x));
      bool _621 = ((int)_620 > (int)0);
      [branch]
      if (_621) {
        float4 _625 = s7.Sample(s7Sampler, float2(TEXCOORD.x, TEXCOORD.y));
        float _627 = abs(_625.x);
        _720 = _627;
      } else {
        float4 _631 = s2.SampleLevel(s2Sampler, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _633 = TEXCOORD.x * 2.0f;
        float _634 = TEXCOORD.y * 2.0f;
        float _635 = _633 + -1.0f;
        float _636 = _634 + -1.0f;
        float _657 = (Global.Proj.m[0][8].x) * _635;
        float _658 = mad(_636, (Global.Proj.m[0][8].y), _657);
        float _659 = mad(_631.x, (Global.Proj.m[0][8].z), _658);
        float _660 = _659 + (Global.Proj.m[0][8].w);
        float _661 = (Global.Proj.m[0][9].x) * _635;
        float _662 = mad(_636, (Global.Proj.m[0][9].y), _661);
        float _663 = mad(_631.x, (Global.Proj.m[0][9].z), _662);
        float _664 = _663 + (Global.Proj.m[0][9].w);
        float _665 = (Global.Proj.m[0][10].x) * _635;
        float _666 = mad(_636, (Global.Proj.m[0][10].y), _665);
        float _667 = mad(_631.x, (Global.Proj.m[0][10].z), _666);
        float _668 = _667 + (Global.Proj.m[0][10].w);
        float _669 = (Global.Proj.m[0][11].x) * _635;
        float _670 = mad(_636, (Global.Proj.m[0][11].y), _669);
        float _671 = mad(_631.x, (Global.Proj.m[0][11].z), _670);
        float _672 = _671 + (Global.Proj.m[0][11].w);
        float _673 = _660 / _672;
        float _674 = _664 / _672;
        float _675 = _668 / _672;
        float _676 = _673 * _673;
        float _677 = _674 * _674;
        float _678 = _677 + _676;
        float _679 = _675 * _675;
        float _680 = _678 + _679;
        float _681 = sqrt(_680);
        float4 _684 = s5.Sample(s5Sampler, float2(TEXCOORD.x, TEXCOORD.y));
        float _690 = (PostProcess.Settings[6].w) * (PostProcess.Settings[5].x);
        float _691 = _690 + (PostProcess.Settings[5].x);
        float _692 = (PostProcess.Settings[5].x) - _690;
        float _693 = max(_681, _692);
        float _694 = min(_693, _691);
        float _696 = _681 - _694;
        float _697 = _696 * (PostProcess.Settings[5].w);
        float _699 = _694 - (PostProcess.Settings[5].y);
        float _700 = _699 * _681;
        float _701 = _697 / _700;
        float _702 = min(_701, 0.0f);
        float _705 = _690 + 1.0f;
        float _706 = 1.0f / _705;
        float _707 = (PostProcess.Settings[7].z) * _702;
        float _708 = max(0.0f, _701);
        float _711 = (PostProcess.Settings[18].x) * _708;
        float _712 = _711 + _707;
        float _713 = _712 * _706;
        float _714 = min(_684.x, _713);
        float _715 = abs(_714);
        float _716 = abs(_713);
        float _717 = max(_715, _716);
        float _718 = saturate(_717);
        _720 = _718;
      }
      float _723 = (PostProcess.Settings[6].x) * _720;
      float4 _726 = s4.Sample(s4Sampler, float2(TEXCOORD.x, TEXCOORD.y));
      float _733 = (PostProcess.Settings[7].x) * _723;
      float _734 = (PostProcess.Settings[7].y) * _723;
      float _735 = _733 + TEXCOORD.x;
      float _736 = _734 + TEXCOORD.y;
      float4 _737 = s4.Sample(s4Sampler, float2(_735, _736));
      float4 _741 = s5.Sample(s5Sampler, float2(_735, _736));
      float _743 = abs(_741.x);
      float _744 = _737.z - _726.z;
      float _745 = _743 * _744;
      float _746 = _723 + -1.0f;
      float _747 = saturate(_746);
      float _748 = _726.x - _374;
      float _749 = _726.y - _375;
      float _750 = _726.z - _376;
      float _751 = _750 + _745;
      float _752 = _747 * _748;
      float _753 = _747 * _749;
      float _754 = _751 * _747;
      float _755 = _752 + _374;
      float _756 = _753 + _375;
      float _757 = _754 + _376;
      _759 = _755;
      _760 = _756;
      _761 = _757;
    }
  }
  float4 _765 = sExposureScale.Load(int3(0, 0, 0));
  float _771 = _765.x * (Global.Global.c[87].y);
  float _772 = _771 * _759;
  float _773 = _772 * (PostProcess.Settings[14].x);
  float _774 = _771 * _760;
  float _775 = _774 * (PostProcess.Settings[14].y);
  float _776 = _771 * _761;
  float _777 = _776 * (PostProcess.Settings[14].z);
  float _782 = _54 * 2.0f;
  float _783 = _55 * 2.0f;
  float _784 = _782 + -1.0f;
  float _785 = _783 + -1.0f;
  float _788 = (PostProcess.Settings[13].w) * _785;
  float _789 = _784 * _784;
  float _790 = _788 * _788;
  float _791 = _790 + _789;
  float _792 = sqrt(_791);
  float _794 = (PostProcess.Settings[13].x) * _792;
  float _796 = _794 + (PostProcess.Settings[13].y);
  float _797 = saturate(_796);
  float _799 = log2(_797);
  float _800 = _799 * (PostProcess.Settings[13].z);
  float _801 = exp2(_800);
  float _802 = _773 * (PostProcess.Settings[12].x);
  float _803 = _775 * (PostProcess.Settings[12].y);
  float _804 = _777 * (PostProcess.Settings[12].z);
  float _805 = _802 - _773;
  float _806 = _803 - _775;
  float _807 = _804 - _777;
  float _808 = _801 * _805;
  float _809 = _801 * _806;
  float _810 = _801 * _807;
  float _811 = _808 + _773;
  float _812 = _809 + _775;
  float _813 = _810 + _777;
  float _816 = (PostProcess.Settings[10].w) * 1.1190600395202637f;
  float _817 = _816 * _811;
  float _818 = _816 * _812;
  float _819 = _816 * _813;
  float _820 = _817 + 1.0f;
  float _821 = _818 + 1.0f;
  float _822 = _819 + 1.0f;
  float _823 = log2(_820);
  float _824 = log2(_821);
  float _825 = log2(_822);
  float _828 = (PostProcess.OffsetWeight[0].x) * 0.07434873282909393f;
  float _829 = _828 * _823;
  float _830 = _828 * _824;
  float _831 = _828 * _825;
  float _833 = _829 + (PostProcess.OffsetWeight[0].y);
  float _834 = _830 + (PostProcess.OffsetWeight[0].y);
  float _835 = _831 + (PostProcess.OffsetWeight[0].y);
  float4 _838 = s3_3D.Sample(s3_3DSampler, float3(_833, _834, _835));
  float _844 = _838.x * 13.450128555297852f;
  float _845 = _838.y * 13.450128555297852f;
  float _846 = _838.z * 13.450128555297852f;
  float _847 = exp2(_844);
  float _848 = exp2(_845);
  float _849 = exp2(_846);
  float _850 = _847 + -1.0f;
  float _851 = _848 + -1.0f;
  float _852 = _849 + -1.0f;
  float _853 = 0.8936070799827576f / (PostProcess.Settings[10].w);
  float _854 = _853 * _850;
  float _855 = _853 * _851;
  float _856 = _853 * _852;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_817 * _853, _818 * _853, _819 * _853),
      float3(_854, _855, _856),
      1.f.xxx);
  _854 = resonance_scaled_lut_output.x;
  _855 = resonance_scaled_lut_output.y;
  _856 = resonance_scaled_lut_output.z;
  bool _859 = ((User.c[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_859) {
    float _861 = (PostProcess.Settings[10].w) * 1.1190600395202637f;
    float _862 = _854 * _861;
    float _863 = _855 * _861;
    float _864 = _856 * _861;
    float _865 = _862 + 1.0f;
    float _866 = _863 + 1.0f;
    float _867 = _864 + 1.0f;
    float _868 = log2(_865);
    float _869 = log2(_866);
    float _870 = log2(_867);
    float _871 = _868 * 0.07434873282909393f;
    float _872 = _869 * 0.07434873282909393f;
    float _873 = _870 * 0.07434873282909393f;
    int _875 = asint((User.c[3].y));
    int _876 = _875 & 1;
    bool _877 = (_876 == 0);
    if (!_877) {
      bool _894 = !(_871 <= (User.c[4].x));
      if (!_894) {
        float _896 = max(9.999999974752427e-07f, (User.c[4].x));
        float _897 = _871 / _896;
        float _898 = _897 * (User.c[4].y);
        float _899 = _897 * _897;
        float _900 = _899 * _897;
        float _901 = _900 - _897;
        float _902 = (User.c[10].x) * 0.1666666716337204f;
        float _903 = _896 * _896;
        float _904 = _903 * _902;
        float _905 = _904 * _901;
        float _906 = _905 + _898;
        _996 = _906;
      } else {
        bool _908 = !(_871 <= (User.c[4].z));
        if (!_908) {
          float _910 = (User.c[4].z) - (User.c[4].x);
          float _911 = max(9.999999974752427e-07f, _910);
          float _912 = _871 - (User.c[4].x);
          float _913 = _912 / _911;
          float _914 = 1.0f - _913;
          float _915 = _914 * (User.c[4].y);
          float _916 = _913 * (User.c[4].w);
          float _917 = _915 + _916;
          float _918 = _914 * _914;
          float _919 = _918 * _914;
          float _920 = _919 - _914;
          float _921 = _920 * (User.c[10].x);
          float _922 = _913 * _913;
          float _923 = _922 * _913;
          float _924 = _923 - _913;
          float _925 = _924 * (User.c[10].y);
          float _926 = _921 + _925;
          float _927 = _911 * _911;
          float _928 = _927 * 0.1666666716337204f;
          float _929 = _928 * _926;
          float _930 = _917 + _929;
          _996 = _930;
        } else {
          bool _932 = !(_871 <= (User.c[9].x));
          if (!_932) {
            float _934 = (User.c[9].x) - (User.c[4].z);
            float _935 = max(9.999999974752427e-07f, _934);
            float _936 = _871 - (User.c[4].z);
            float _937 = _936 / _935;
            float _938 = 1.0f - _937;
            float _939 = _938 * (User.c[4].w);
            float _940 = _937 * (User.c[9].y);
            float _941 = _939 + _940;
            float _942 = _938 * _938;
            float _943 = _942 * _938;
            float _944 = _943 - _938;
            float _945 = _944 * (User.c[10].y);
            float _946 = _937 * _937;
            float _947 = _946 * _937;
            float _948 = _947 - _937;
            float _949 = _948 * (User.c[10].z);
            float _950 = _945 + _949;
            float _951 = _935 * _935;
            float _952 = _951 * 0.1666666716337204f;
            float _953 = _952 * _950;
            float _954 = _941 + _953;
            _996 = _954;
          } else {
            bool _956 = !(_871 <= (User.c[9].z));
            if (!_956) {
              float _958 = (User.c[9].z) - (User.c[9].x);
              float _959 = max(9.999999974752427e-07f, _958);
              float _960 = _871 - (User.c[9].x);
              float _961 = _960 / _959;
              float _962 = 1.0f - _961;
              float _963 = _962 * (User.c[9].y);
              float _964 = _961 * (User.c[9].w);
              float _965 = _963 + _964;
              float _966 = _962 * _962;
              float _967 = _966 * _962;
              float _968 = _967 - _962;
              float _969 = _968 * (User.c[10].z);
              float _970 = _961 * _961;
              float _971 = _970 * _961;
              float _972 = _971 - _961;
              float _973 = _972 * (User.c[10].w);
              float _974 = _969 + _973;
              float _975 = _959 * _959;
              float _976 = _975 * 0.1666666716337204f;
              float _977 = _976 * _974;
              float _978 = _965 + _977;
              _996 = _978;
            } else {
              float _980 = 1.0f - (User.c[9].z);
              float _981 = _871 - (User.c[9].z);
              float _982 = max(9.999999974752427e-07f, _980);
              float _983 = _981 / _982;
              float _984 = 1.0f - _983;
              float _985 = _984 * (User.c[9].w);
              float _986 = _985 + _983;
              float _987 = _984 * _984;
              float _988 = _987 * _984;
              float _989 = _988 - _984;
              float _990 = (User.c[10].w) * 0.1666666716337204f;
              float _991 = _980 * _980;
              float _992 = _991 * _990;
              float _993 = _992 * _989;
              float _994 = _986 + _993;
              _996 = _994;
            }
          }
        }
      }
      float _997 = saturate(_996);
      bool _998 = !(_872 <= (User.c[4].x));
      if (!_998) {
        float _1000 = max(9.999999974752427e-07f, (User.c[4].x));
        float _1001 = _872 / _1000;
        float _1002 = _1001 * (User.c[4].y);
        float _1003 = _1001 * _1001;
        float _1004 = _1003 * _1001;
        float _1005 = _1004 - _1001;
        float _1006 = (User.c[10].x) * 0.1666666716337204f;
        float _1007 = _1000 * _1000;
        float _1008 = _1007 * _1006;
        float _1009 = _1008 * _1005;
        float _1010 = _1009 + _1002;
        _1100 = _1010;
      } else {
        bool _1012 = !(_872 <= (User.c[4].z));
        if (!_1012) {
          float _1014 = (User.c[4].z) - (User.c[4].x);
          float _1015 = max(9.999999974752427e-07f, _1014);
          float _1016 = _872 - (User.c[4].x);
          float _1017 = _1016 / _1015;
          float _1018 = 1.0f - _1017;
          float _1019 = _1018 * (User.c[4].y);
          float _1020 = _1017 * (User.c[4].w);
          float _1021 = _1019 + _1020;
          float _1022 = _1018 * _1018;
          float _1023 = _1022 * _1018;
          float _1024 = _1023 - _1018;
          float _1025 = _1024 * (User.c[10].x);
          float _1026 = _1017 * _1017;
          float _1027 = _1026 * _1017;
          float _1028 = _1027 - _1017;
          float _1029 = _1028 * (User.c[10].y);
          float _1030 = _1025 + _1029;
          float _1031 = _1015 * _1015;
          float _1032 = _1031 * 0.1666666716337204f;
          float _1033 = _1032 * _1030;
          float _1034 = _1021 + _1033;
          _1100 = _1034;
        } else {
          bool _1036 = !(_872 <= (User.c[9].x));
          if (!_1036) {
            float _1038 = (User.c[9].x) - (User.c[4].z);
            float _1039 = max(9.999999974752427e-07f, _1038);
            float _1040 = _872 - (User.c[4].z);
            float _1041 = _1040 / _1039;
            float _1042 = 1.0f - _1041;
            float _1043 = _1042 * (User.c[4].w);
            float _1044 = _1041 * (User.c[9].y);
            float _1045 = _1043 + _1044;
            float _1046 = _1042 * _1042;
            float _1047 = _1046 * _1042;
            float _1048 = _1047 - _1042;
            float _1049 = _1048 * (User.c[10].y);
            float _1050 = _1041 * _1041;
            float _1051 = _1050 * _1041;
            float _1052 = _1051 - _1041;
            float _1053 = _1052 * (User.c[10].z);
            float _1054 = _1049 + _1053;
            float _1055 = _1039 * _1039;
            float _1056 = _1055 * 0.1666666716337204f;
            float _1057 = _1056 * _1054;
            float _1058 = _1045 + _1057;
            _1100 = _1058;
          } else {
            bool _1060 = !(_872 <= (User.c[9].z));
            if (!_1060) {
              float _1062 = (User.c[9].z) - (User.c[9].x);
              float _1063 = max(9.999999974752427e-07f, _1062);
              float _1064 = _872 - (User.c[9].x);
              float _1065 = _1064 / _1063;
              float _1066 = 1.0f - _1065;
              float _1067 = _1066 * (User.c[9].y);
              float _1068 = _1065 * (User.c[9].w);
              float _1069 = _1067 + _1068;
              float _1070 = _1066 * _1066;
              float _1071 = _1070 * _1066;
              float _1072 = _1071 - _1066;
              float _1073 = _1072 * (User.c[10].z);
              float _1074 = _1065 * _1065;
              float _1075 = _1074 * _1065;
              float _1076 = _1075 - _1065;
              float _1077 = _1076 * (User.c[10].w);
              float _1078 = _1073 + _1077;
              float _1079 = _1063 * _1063;
              float _1080 = _1079 * 0.1666666716337204f;
              float _1081 = _1080 * _1078;
              float _1082 = _1069 + _1081;
              _1100 = _1082;
            } else {
              float _1084 = 1.0f - (User.c[9].z);
              float _1085 = _872 - (User.c[9].z);
              float _1086 = max(9.999999974752427e-07f, _1084);
              float _1087 = _1085 / _1086;
              float _1088 = 1.0f - _1087;
              float _1089 = _1088 * (User.c[9].w);
              float _1090 = _1089 + _1087;
              float _1091 = _1088 * _1088;
              float _1092 = _1091 * _1088;
              float _1093 = _1092 - _1088;
              float _1094 = (User.c[10].w) * 0.1666666716337204f;
              float _1095 = _1084 * _1084;
              float _1096 = _1095 * _1094;
              float _1097 = _1096 * _1093;
              float _1098 = _1090 + _1097;
              _1100 = _1098;
            }
          }
        }
      }
      float _1101 = saturate(_1100);
      bool _1102 = !(_873 <= (User.c[4].x));
      if (!_1102) {
        float _1104 = max(9.999999974752427e-07f, (User.c[4].x));
        float _1105 = _873 / _1104;
        float _1106 = _1105 * (User.c[4].y);
        float _1107 = _1105 * _1105;
        float _1108 = _1107 * _1105;
        float _1109 = _1108 - _1105;
        float _1110 = (User.c[10].x) * 0.1666666716337204f;
        float _1111 = _1104 * _1104;
        float _1112 = _1111 * _1110;
        float _1113 = _1112 * _1109;
        float _1114 = _1113 + _1106;
        _1204 = _1114;
      } else {
        bool _1116 = !(_873 <= (User.c[4].z));
        if (!_1116) {
          float _1118 = (User.c[4].z) - (User.c[4].x);
          float _1119 = max(9.999999974752427e-07f, _1118);
          float _1120 = _873 - (User.c[4].x);
          float _1121 = _1120 / _1119;
          float _1122 = 1.0f - _1121;
          float _1123 = _1122 * (User.c[4].y);
          float _1124 = _1121 * (User.c[4].w);
          float _1125 = _1123 + _1124;
          float _1126 = _1122 * _1122;
          float _1127 = _1126 * _1122;
          float _1128 = _1127 - _1122;
          float _1129 = _1128 * (User.c[10].x);
          float _1130 = _1121 * _1121;
          float _1131 = _1130 * _1121;
          float _1132 = _1131 - _1121;
          float _1133 = _1132 * (User.c[10].y);
          float _1134 = _1129 + _1133;
          float _1135 = _1119 * _1119;
          float _1136 = _1135 * 0.1666666716337204f;
          float _1137 = _1136 * _1134;
          float _1138 = _1125 + _1137;
          _1204 = _1138;
        } else {
          bool _1140 = !(_873 <= (User.c[9].x));
          if (!_1140) {
            float _1142 = (User.c[9].x) - (User.c[4].z);
            float _1143 = max(9.999999974752427e-07f, _1142);
            float _1144 = _873 - (User.c[4].z);
            float _1145 = _1144 / _1143;
            float _1146 = 1.0f - _1145;
            float _1147 = _1146 * (User.c[4].w);
            float _1148 = _1145 * (User.c[9].y);
            float _1149 = _1147 + _1148;
            float _1150 = _1146 * _1146;
            float _1151 = _1150 * _1146;
            float _1152 = _1151 - _1146;
            float _1153 = _1152 * (User.c[10].y);
            float _1154 = _1145 * _1145;
            float _1155 = _1154 * _1145;
            float _1156 = _1155 - _1145;
            float _1157 = _1156 * (User.c[10].z);
            float _1158 = _1153 + _1157;
            float _1159 = _1143 * _1143;
            float _1160 = _1159 * 0.1666666716337204f;
            float _1161 = _1160 * _1158;
            float _1162 = _1149 + _1161;
            _1204 = _1162;
          } else {
            bool _1164 = !(_873 <= (User.c[9].z));
            if (!_1164) {
              float _1166 = (User.c[9].z) - (User.c[9].x);
              float _1167 = max(9.999999974752427e-07f, _1166);
              float _1168 = _873 - (User.c[9].x);
              float _1169 = _1168 / _1167;
              float _1170 = 1.0f - _1169;
              float _1171 = _1170 * (User.c[9].y);
              float _1172 = _1169 * (User.c[9].w);
              float _1173 = _1171 + _1172;
              float _1174 = _1170 * _1170;
              float _1175 = _1174 * _1170;
              float _1176 = _1175 - _1170;
              float _1177 = _1176 * (User.c[10].z);
              float _1178 = _1169 * _1169;
              float _1179 = _1178 * _1169;
              float _1180 = _1179 - _1169;
              float _1181 = _1180 * (User.c[10].w);
              float _1182 = _1177 + _1181;
              float _1183 = _1167 * _1167;
              float _1184 = _1183 * 0.1666666716337204f;
              float _1185 = _1184 * _1182;
              float _1186 = _1173 + _1185;
              _1204 = _1186;
            } else {
              float _1188 = 1.0f - (User.c[9].z);
              float _1189 = _873 - (User.c[9].z);
              float _1190 = max(9.999999974752427e-07f, _1188);
              float _1191 = _1189 / _1190;
              float _1192 = 1.0f - _1191;
              float _1193 = _1192 * (User.c[9].w);
              float _1194 = _1193 + _1191;
              float _1195 = _1192 * _1192;
              float _1196 = _1195 * _1192;
              float _1197 = _1196 - _1192;
              float _1198 = (User.c[10].w) * 0.1666666716337204f;
              float _1199 = _1188 * _1188;
              float _1200 = _1199 * _1198;
              float _1201 = _1200 * _1197;
              float _1202 = _1194 + _1201;
              _1204 = _1202;
            }
          }
        }
      }
      float _1205 = saturate(_1204);
      _1207 = _997;
      _1208 = _1101;
      _1209 = _1205;
    } else {
      _1207 = _871;
      _1208 = _872;
      _1209 = _873;
    }
    int _1210 = _875 & 2;
    bool _1211 = (_1210 == 0);
    if (!_1211) {
      float _1213 = sqrt(_1207);
      float _1214 = sqrt(_1208);
      float _1215 = sqrt(_1209);
      float _1216 = dot(float3(_1213, _1214, _1215), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1217 = 1.0f - _1216;
      float _1218 = saturate(_1217);
      _1220 = _1218;
    } else {
      _1220 = 1.0f;
    }
    int _1221 = _875 & 8;
    bool _1222 = (_1221 == 0);
    if (_1222) {
      int _1224 = _875 & 4;
      bool _1225 = (_1224 == 0);
      if (!_1225) {
        int _1227 = _875 & 16;
        bool _1228 = (_1227 == 0);
        if (!_1228) {
          float _1232 = (User.c[5].x) * 0.5f;
          float _1233 = _1232 + 0.5f;
          bool _1234 = (_1233 < 0.5f);
          float _1235 = (User.c[5].x) * 5.0f;
          float _1236 = select(_1234, (User.c[5].x), _1235);
          bool _1237 = (_1208 < _1209);
          float _1238 = select(_1237, _1209, _1208);
          float _1239 = select(_1237, _1208, _1209);
          bool _1240 = (_1207 < _1238);
          float _1241 = select(_1240, _1238, _1207);
          float _1242 = select(_1240, _1207, _1238);
          float _1243 = min(_1242, _1239);
          float _1244 = _1241 - _1243;
          float _1245 = _1241 + 1.000000013351432e-10f;
          float _1246 = _1244 / _1245;
          float _1248 = _1246 - (User.c[5].y);
          float _1249 = saturate(_1248);
          float _1250 = max(_1249, 9.999999974752427e-07f);
          float _1251 = log2(_1250);
          float _1252 = _1251 * _1236;
          float _1253 = exp2(_1252);
          float _1254 = 2.0f - _1253;
          float _1256 = 1.0f - (User.c[5].z);
          float _1257 = saturate(_1256);
          float _1258 = max(_1257, _1254);
          float _1259 = dot(float3(_1207, _1208, _1209), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1260 = _1207 - _1259;
          float _1261 = _1208 - _1259;
          float _1262 = _1209 - _1259;
          float _1263 = _1260 * _1258;
          float _1264 = _1261 * _1258;
          float _1265 = _1262 * _1258;
          float _1266 = _1259 - _1207;
          float _1267 = _1266 + _1263;
          float _1268 = _1259 - _1208;
          float _1269 = _1268 + _1264;
          float _1270 = _1259 - _1209;
          float _1271 = _1270 + _1265;
          float _1272 = _1267 * _1220;
          float _1273 = _1269 * _1220;
          float _1274 = _1271 * _1220;
          float _1275 = _1272 + _1207;
          float _1276 = _1273 + _1208;
          float _1277 = _1274 + _1209;
          _1394 = _1275;
          _1395 = _1276;
          _1396 = _1277;
        } else {
          bool _1279 = (_1220 == 0.0f);
          if (!_1279) {
            float _1283 = abs(User.c[5].x);
            float _1284 = saturate(_1283);
            uint4 _1286 = 0u; sVibranceLUT.GetDimensions(0u, _1286.x, _1286.y, _1286.w);
            float _1289 = float((uint)_1286.y);
            int _1290 = _875 & 32;
            bool _1291 = (_1290 == 0);
            float _1292 = _1289 + -1.0f;
            if (!_1291) {
              float _1294 = 1.0f / _1292;
              uint _1295 = uint(SV_Position.x);
              uint _1296 = uint(SV_Position.y);
              int _1297 = _1295 & 63;
              int _1298 = _1296 & 63;
              float4 _1300 = sBlueNoiseR8G8.Load(int4(_1297, _1298, 0, 0));
              float _1303 = _1300.x + -0.5f;
              float _1304 = _1207 * 13.999999046325684f;
              float _1305 = _1208 * 13.999999046325684f;
              float _1306 = _1209 * 13.999999046325684f;
              float _1307 = saturate(_1304);
              float _1308 = saturate(_1305);
              float _1309 = saturate(_1306);
              float _1310 = _1207 + -0.9285714030265808f;
              float _1311 = _1208 + -0.9285714030265808f;
              float _1312 = _1209 + -0.9285714030265808f;
              float _1313 = _1310 * 13.999999046325684f;
              float _1314 = _1311 * 13.999999046325684f;
              float _1315 = _1312 * 13.999999046325684f;
              float _1316 = saturate(_1313);
              float _1317 = saturate(_1314);
              float _1318 = saturate(_1315);
              float _1319 = 1.0f - _1316;
              float _1320 = 1.0f - _1317;
              float _1321 = 1.0f - _1318;
              float _1322 = min(_1307, _1319);
              float _1323 = min(_1308, _1320);
              float _1324 = min(_1309, _1321);
              float _1325 = _1300.y + -0.5f;
              float _1326 = _1322 * _1325;
              float _1327 = _1323 * _1325;
              float _1328 = _1324 * _1325;
              float _1329 = _1326 + _1303;
              float _1330 = _1327 + _1303;
              float _1331 = _1328 + _1303;
              float _1332 = _1329 * _1294;
              float _1333 = _1330 * _1294;
              float _1334 = _1331 * _1294;
              float _1335 = _1332 + _1207;
              float _1336 = _1333 + _1208;
              float _1337 = _1334 + _1209;
              float _1338 = saturate(_1335);
              float _1339 = saturate(_1336);
              float _1340 = saturate(_1337);
              float _1341 = saturate(_1338);
              float _1342 = saturate(_1339);
              float _1343 = saturate(_1340);
              _1345 = _1341;
              _1346 = _1342;
              _1347 = _1343;
            } else {
              _1345 = _1207;
              _1346 = _1208;
              _1347 = _1209;
            }
            float _1348 = float((uint)_1286.x);
            float _1349 = _1292 / _1348;
            float _1350 = _1349 * _1345;
            float _1351 = 0.5f / _1348;
            float _1352 = _1350 + _1351;
            float _1353 = _1292 / _1289;
            float _1354 = _1353 * _1346;
            float _1355 = 0.5f / _1289;
            float _1356 = _1354 + _1355;
            float _1357 = _1347 * _1292;
            float _1358 = floor(_1357);
            float _1359 = frac(_1357);
            float _1360 = _1358 / _1289;
            float _1361 = _1360 + _1352;
            float _1362 = _1358 + 1.0f;
            float _1363 = _1362 / _1289;
            float _1364 = _1363 + _1352;
            float4 _1366 = sVibranceLUT.Sample(sLinearClampSampler, float2(_1361, _1356));
            float4 _1370 = sVibranceLUT.Sample(sLinearClampSampler, float2(_1364, _1356));
            float _1374 = _1370.x - _1366.x;
            float _1375 = _1370.y - _1366.y;
            float _1376 = _1370.z - _1366.z;
            float _1377 = _1374 * _1359;
            float _1378 = _1375 * _1359;
            float _1379 = _1376 * _1359;
            float _1380 = _1284 * _1220;
            float _1381 = _1366.x - _1207;
            float _1382 = _1381 + _1377;
            float _1383 = _1366.y - _1208;
            float _1384 = _1383 + _1378;
            float _1385 = _1366.z - _1209;
            float _1386 = _1385 + _1379;
            float _1387 = _1382 * _1380;
            float _1388 = _1384 * _1380;
            float _1389 = _1386 * _1380;
            float _1390 = _1387 + _1207;
            float _1391 = _1388 + _1208;
            float _1392 = _1389 + _1209;
            _1394 = _1390;
            _1395 = _1391;
            _1396 = _1392;
          } else {
            _1394 = _1207;
            _1395 = _1208;
            _1396 = _1209;
          }
        }
      } else {
        _1394 = _1207;
        _1395 = _1208;
        _1396 = _1209;
      }
    } else {
      _1394 = _1220;
      _1395 = _1220;
      _1396 = _1220;
    }
    float _1397 = _1394 * 13.450128555297852f;
    float _1398 = _1395 * 13.450128555297852f;
    float _1399 = _1396 * 13.450128555297852f;
    float _1400 = exp2(_1397);
    float _1401 = exp2(_1398);
    float _1402 = exp2(_1399);
    float _1403 = _1400 + -1.0f;
    float _1404 = _1401 + -1.0f;
    float _1405 = _1402 + -1.0f;
    float _1406 = _1403 * _853;
    float _1407 = _1404 * _853;
    float _1408 = _1405 * _853;
    _1410 = _1406;
    _1411 = _1407;
    _1412 = _1408;
  } else {
    _1410 = _854;
    _1411 = _855;
    _1412 = _856;
  }
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3((User.c[8].x) * _1410, (User.c[8].y) * _1411, (User.c[8].z) * _1412),
      SV_Position.xy);
  float _1419 = resonance_perceptual_film_grain.x;
  float _1420 = (PostProcess.Settings[17].y) + 2.0f;
  float _1421 = log2(_1419);
  float _1422 = _1420 * _1421;
  float _1423 = exp2(_1422);
  float _1424 = _1423 + -1.0f;
  float _1425 = _1419 + -1.0f;
  float _1426 = _1424 / _1425;
  bool _1427 = !(_1419 == 1.0f);
  float _1428 = _1426 + -1.0f;
  float _1429 = _1428 / _1426;
  float _1430 = (PostProcess.Settings[17].y) + 1.0f;
  float _1431 = _1430 / _1420;
  float _1432 = select(_1427, _1429, _1431);
  float _1433 = resonance_perceptual_film_grain.y;
  float _1434 = log2(_1433);
  float _1435 = _1434 * _1420;
  float _1436 = exp2(_1435);
  float _1437 = _1436 + -1.0f;
  float _1438 = _1433 + -1.0f;
  float _1439 = _1437 / _1438;
  bool _1440 = !(_1433 == 1.0f);
  float _1441 = _1439 + -1.0f;
  float _1442 = _1441 / _1439;
  float _1443 = (PostProcess.Settings[17].y) + 1.0f;
  float _1444 = _1443 / _1420;
  float _1445 = select(_1440, _1442, _1444);
  float _1446 = resonance_perceptual_film_grain.z;
  float _1447 = log2(_1446);
  float _1448 = _1447 * _1420;
  float _1449 = exp2(_1448);
  float _1450 = _1449 + -1.0f;
  float _1451 = _1446 + -1.0f;
  float _1452 = _1450 / _1451;
  bool _1453 = !(_1446 == 1.0f);
  float _1454 = _1452 + -1.0f;
  float _1455 = _1454 / _1452;
  float _1456 = (PostProcess.Settings[17].y) + 1.0f;
  float _1457 = _1456 / _1420;
  float _1458 = select(_1453, _1455, _1457);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1419, _1433, _1446),
      float3(_1432, _1445, _1458),
      true);
  float _1459 = resonance_post_process_output.x;
  float _1460 = resonance_post_process_output.y;
  float _1461 = resonance_post_process_output.z;
  float _1462 = log2(_1459);
  float _1463 = log2(_1460);
  float _1464 = log2(_1461);
  float _1465 = _1462 * 0.4166666567325592f;
  float _1466 = _1463 * 0.4166666567325592f;
  float _1467 = _1464 * 0.4166666567325592f;
  float _1468 = exp2(_1465);
  float _1469 = exp2(_1466);
  float _1470 = exp2(_1467);
  float _1471 = _1468 * 1.0549999475479126f;
  float _1472 = _1469 * 1.0549999475479126f;
  float _1473 = _1470 * 1.0549999475479126f;
  float _1474 = _1471 + -0.054999999701976776f;
  float _1475 = _1472 + -0.054999999701976776f;
  float _1476 = _1473 + -0.054999999701976776f;
  float _1477 = _1459 * 12.920000076293945f;
  float _1478 = _1460 * 12.920000076293945f;
  float _1479 = _1461 * 12.920000076293945f;
  bool _1480 = (_1459 <= 0.0031308000907301903f);
  bool _1481 = (_1460 <= 0.0031308000907301903f);
  bool _1482 = (_1461 <= 0.0031308000907301903f);
  float _1483 = select(_1480, _1477, _1474);
  float _1484 = select(_1481, _1478, _1475);
  float _1485 = select(_1482, _1479, _1476);
  int _1488 = asint((Global.Global.c[1].w));
  uint _1489 = uint(SV_Position.x);
  uint _1490 = uint(SV_Position.y);
  int _1491 = _1489 & 63;
  int _1492 = _1490 & 63;
  float4 _1494 = sBlueNoiseR8.Load(int4(_1491, _1492, _1488, 0));
  float _1496 = _1494.x + -0.5f;
  float _1497 = _1496 * 0.003921568859368563f;
  float _1498 = _1497 + _1483;
  float _1499 = _1497 + _1484;
  float _1500 = _1497 + _1485;
  float _1501 = saturate(_1498);
  float _1502 = saturate(_1499);
  float _1503 = saturate(_1500);
  SV_Target.x = _1501;
  SV_Target.y = _1502;
  SV_Target.z = _1503;
  SV_Target.w = _373;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}