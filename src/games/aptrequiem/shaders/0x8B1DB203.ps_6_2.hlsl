struct StructGlobalConstant_Z {
  float4 c[174];
};

struct StructPostProcessConstant_Z {
  float4 Settings[16];
  float4 OffsetWeight[32];
};

struct StructUserConstant_Z {
  float4 c[183];
};


Texture2DArray<float4> sBlueNoiseR8 : register(t1);

Texture2DArray<float4> sBlueNoiseR8G8 : register(t2);

Texture2D<float4> s0 : register(t0);

Texture2D<float4> s6 : register(t6);

Texture2D<float4> s13 : register(t13);

Texture2D<float4> s14 : register(t14);

Texture2D<float4> s15 : register(t15);

Texture2D<float4> sPlagueFX_MaskLayer : register(t16);

Texture3D<float4> s3_3D : register(t3);

#include "../common.hlsli"

cbuffer CBufferGlobalConstant_Z : register(b1) {
  StructGlobalConstant_Z Global : packoffset(c000.x);
};

cbuffer CBufferUserConstant_Z : register(b0) {
  StructUserConstant_Z User : packoffset(c000.x);
};

cbuffer CBufferPostProcessConstant_Z : register(b2) {
  StructPostProcessConstant_Z PostProcess : packoffset(c000.x);
};

SamplerState sBlueNoiseR8G8Sampler : register(s1);

SamplerState s0Sampler : register(s0);

SamplerState s13Sampler : register(s13);

SamplerState s14Sampler : register(s14);

SamplerState s15Sampler : register(s15);

SamplerState s3_3DSampler : register(s3);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target = 0;
  float4 _25 = s14.Sample(s14Sampler, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _29 = sPlagueFX_MaskLayer.Sample(s13Sampler, float2(TEXCOORD.z, TEXCOORD.w));
  float _31 = _29.y * 0.10000000149011612f;
  float _32 = _29.y * 0.5f;
  float _33 = _32 + _25.z;
  float _34 = exp2(_33);
  float _35 = _34 + -1.0f;
  float _38 = (PostProcess.Settings[11].y) * _35;
  float _39 = _38 + 1.0f;
  float _40 = log2(_39);
  float _41 = _25.x + TEXCOORD.z;
  float _42 = _25.y + TEXCOORD.w;
  float _43 = _42 + _31;
  float4 _44 = s0.SampleLevel(s0Sampler, float2(_41, _43), _40);
  float _49 = max(_44.x, 0.0f);
  float _50 = max(_44.y, 0.0f);
  float _51 = max(_44.z, 0.0f);
  float _54 = (Global.c[32].w) * 11.0f;
  float _55 = _54 + -1.2000000476837158f;
  float _56 = saturate(_55);
  float _57 = (Global.c[32].w) * 1.7000000476837158f;
  float _58 = 1.340000033378601f - _57;
  float _59 = saturate(_58);
  float _60 = _59 * _59;
  float _61 = _60 * _60;
  float _62 = _61 * _56;
  bool _63 = ((Global.c[32].w) < 9.999999747378752e-06f);
  float _66 = max((Global.c[33].y), _62);
  float _67 = _41 * 2.0f;
  float _68 = _43 * 1.7999999523162842f;
  float _69 = _67 + -1.0f;
  float _70 = _68 + -1.100000023841858f;
  float _71 = abs(_69);
  float _72 = abs(_70);
  float _73 = dot(float2(_71, _72), float2(_71, _72));
  float _74 = sqrt(_73);
  float _75 = select(_63, 1.0f, 0.0f);
  float _76 = _75 * _66;
  float4 _77 = s0.SampleLevel(s0Sampler, float2(_41, _43), 1.0f);
  float4 _81 = s0.SampleLevel(s0Sampler, float2(_41, _43), 2.0f);
  float4 _85 = s0.SampleLevel(s0Sampler, float2(_41, _43), 3.0f);
  float _89 = _73 * 1.7000000476837158f;
  float _90 = _89 + -0.6000000238418579f;
  float _91 = saturate(_90);
  float _92 = _73 * 1.475000023841858f;
  float _93 = _92 + -0.375f;
  float _94 = saturate(_93);
  float _95 = _73 * 1.2999999523162842f;
  float _96 = _95 + -0.15000000596046448f;
  float _97 = saturate(_96);
  float _98 = _85.x - _81.x;
  float _99 = _85.y - _81.y;
  float _100 = _85.z - _81.z;
  float _101 = _98 * _91;
  float _102 = _99 * _91;
  float _103 = _100 * _91;
  float _104 = _81.x - _77.x;
  float _105 = _104 + _101;
  float _106 = _81.y - _77.y;
  float _107 = _106 + _102;
  float _108 = _81.z - _77.z;
  float _109 = _108 + _103;
  float _110 = _105 * _94;
  float _111 = _107 * _94;
  float _112 = _109 * _94;
  float _113 = _97 * _76;
  float _114 = _77.x - _49;
  float _115 = _114 + _110;
  float _116 = _77.y - _50;
  float _117 = _116 + _111;
  float _118 = _77.z - _51;
  float _119 = _118 + _112;
  float _120 = _115 * _113;
  float _121 = _117 * _113;
  float _122 = _119 * _113;
  float _123 = _120 + _49;
  float _124 = _121 + _50;
  float _125 = _122 + _51;
  float4 _126 = s6.Load(int3(0, 0, 0));
  float _128 = _123 * _126.x;
  float _129 = _124 * _126.x;
  float _130 = _125 * _126.x;
  float _135 = _43 * 2.0f;
  float _136 = _135 + -1.0f;
  float _139 = (PostProcess.Settings[13].w) * _136;
  float _140 = _69 * _69;
  float _141 = _139 * _139;
  float _142 = _141 + _140;
  float _143 = sqrt(_142);
  float _145 = (PostProcess.Settings[13].x) * _143;
  float _147 = _145 + (PostProcess.Settings[13].y);
  float _148 = saturate(_147);
  float _150 = log2(_148);
  float _151 = _150 * (PostProcess.Settings[13].z);
  float _152 = exp2(_151);
  float _153 = _128 * (PostProcess.Settings[12].x);
  float _154 = _129 * (PostProcess.Settings[12].y);
  float _155 = _130 * (PostProcess.Settings[12].z);
  float _156 = _153 - _128;
  float _157 = _154 - _129;
  float _158 = _155 - _130;
  float _159 = _152 * _156;
  float _160 = _152 * _157;
  float _161 = _152 * _158;
  float _162 = _159 + _128;
  float _163 = _160 + _129;
  float _164 = _161 + _130;
  float _167 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _168 = _162 * 11190.6005859375f;
  float _169 = _168 * _167;
  float _170 = _163 * 11190.6005859375f;
  float _171 = _170 * _167;
  float _172 = _164 * 11190.6005859375f;
  float _173 = _172 * _167;
  float _174 = _169 + 1.0f;
  float _175 = _171 + 1.0f;
  float _176 = _173 + 1.0f;
  float _177 = log2(_174);
  float _178 = log2(_175);
  float _179 = log2(_176);
  float _180 = _177 * 0.07434873282909393f;
  float _181 = _178 * 0.07434873282909393f;
  float _182 = _179 * 0.07434873282909393f;
  float _185 = _180 * (PostProcess.OffsetWeight[0].x);
  float _186 = _181 * (PostProcess.OffsetWeight[0].x);
  float _187 = _182 * (PostProcess.OffsetWeight[0].x);
  float _189 = _185 + (PostProcess.OffsetWeight[0].y);
  float _190 = _186 + (PostProcess.OffsetWeight[0].y);
  float _191 = _187 + (PostProcess.OffsetWeight[0].y);
  float4 _192 = s3_3D.Sample(s3_3DSampler, float3(_189, _190, _191));
  float _198 = _192.x * 13.450128555297852f;
  float _199 = _192.y * 13.450128555297852f;
  float _200 = _192.z * 13.450128555297852f;
  float _201 = exp2(_198);
  float _202 = exp2(_199);
  float _203 = exp2(_200);
  float _204 = _201 + -1.0f;
  float _205 = _202 + -1.0f;
  float _206 = _203 + -1.0f;
  float _207 = _204 * 8.936070662457496e-05f;
  float _208 = _205 * 8.936070662457496e-05f;
  float _209 = _206 * 8.936070662457496e-05f;
  float _210 = 10000.0f / (PostProcess.Settings[10].w);
  float _211 = _207 * _210;
  float _212 = _208 * _210;
  float _213 = _209 * _210;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUTScaling(
      float3(_169, _171, _173) / apt_lut_input_encode_scale,
      float3(_211, _212, _213),
      s3_3D,
      s3_3DSampler,
      apt_lut_input_encode_scale,
      PostProcess.OffsetWeight[0].x,
      PostProcess.OffsetWeight[0].y,
      8.936070662457496e-05f * (10000.0f / PostProcess.Settings[10].w));
  _211 = apt_lut_output.x;
  _212 = apt_lut_output.y;
  _213 = apt_lut_output.z;
  float _217 = (User.c[2].y) / (User.c[2].x);
  int _220 = asint((Global.c[1].w));
  uint _221 = _220 + 30u;
  int _222 = _221 & 63;
  float _223 = _41 * 8.0f;
  float _224 = _223 * _217;
  float _225 = _43 * 8.0f;
  float _226 = float((int)(_220));
  float4 _227 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_224, _225, _226), 0.0f);
  float _229 = _41 + 0.5f;
  float _230 = (User.c[2].x) * 0.5f;
  float _231 = _229 + _230;
  float _232 = _217 * 8.0f;
  float _233 = _232 * _231;
  float _234 = _43 + 0.5f;
  float _235 = (User.c[2].y) * 0.5f;
  float _236 = _234 + _235;
  float _237 = _236 * 8.0f;
  float _238 = float((int)(_222));
  float4 _239 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_233, _237, _238), 0.0f);
  float _241 = _239.x + _227.x;
  float _242 = _241 * 0.714285671710968f;
  float _243 = _242 + -0.2142857164144516f;
  float _244 = saturate(_243);
  float _245 = _244 * 2.0f;
  float _246 = 3.0f - _245;
  float _247 = _244 * _244;
  float _248 = _247 * _246;
  float _249 = _248 * 0.5f;
  float _250 = _248 * 0.4000000059604645f;
  float _251 = _248 * 0.05000000074505806f;
  float _252 = _249 + -0.5f;
  float _253 = _250 + -0.6000000238418579f;
  float _254 = _251 + -0.949999988079071f;
  float _255 = _252 * _76;
  float _256 = _253 * _76;
  float _257 = _254 * _76;
  float _258 = _255 + 1.0f;
  float _259 = _256 + 1.0f;
  float _260 = _257 + 1.0f;
  float _261 = _211 * _258;
  float _262 = _212 * _259;
  float _263 = _213 * _260;
  float4 _264 = s13.Sample(s13Sampler, float2(_41, _43));
  float _271 = _91 + 1.0f;
  float _272 = saturate(_271);
  float _273 = (User.c[2].x) * _272;
  float _274 = (User.c[2].y) * _272;
  float _275 = _273 + _41;
  float _276 = _274 + _43;
  float4 _277 = s13.Sample(s13Sampler, float2(_275, _276));
  float _281 = _277.x + _264.x;
  float _282 = _277.y + _264.y;
  float _283 = _277.z + _264.z;
  float _284 = _281 * 0.5f;
  float _285 = _282 * 0.5f;
  float _286 = _283 * 0.5f;
  float _287 = _76 * 0.6000000238418579f;
  float _288 = _287 * _74;
  float _289 = _76 * 0.7300000190734863f;
  float _290 = _289 * _74;
  float _291 = _76 * 0.8799999952316284f;
  float _292 = _291 * _74;
  float _293 = 1.0f - _288;
  float _294 = 1.0f - _290;
  float _295 = 1.0f - _292;
  float _296 = saturate(_293);
  float _297 = saturate(_294);
  float _298 = saturate(_295);
  float _299 = _261 * _296;
  float _300 = _262 * _297;
  float _301 = _263 * _298;
  float _302 = _284 + _299;
  float _303 = _300 + _285;
  float _304 = _301 + _286;
  bool _307 = ((User.c[3].x) > 0.0f);
  float _429;
  float _485;
  float _541;
  float _544;
  float _545;
  float _546;
  float _557;
  float _689;
  float _690;
  float _691;
  float _737;
  float _738;
  float _739;
  float _777;
  float _791;
  float _805;
  float _806;
  float _807;
  if (_307) {
    float _309 = log2(_302);
    float _310 = _309 * 3.0f;
    float _311 = exp2(_310);
    float _312 = _311 + -1.0f;
    float _313 = _302 + -1.0f;
    float _314 = _312 / _313;
    float _315 = _314 + -1.0f;
    bool _316 = !(_302 == 1.0f);
    float _317 = _315 / _314;
    float _318 = select(_316, _317, 0.6666666865348816f);
    float _319 = log2(_303);
    float _320 = _319 * 3.0f;
    float _321 = exp2(_320);
    float _322 = _321 + -1.0f;
    float _323 = _303 + -1.0f;
    float _324 = _322 / _323;
    float _325 = _324 + -1.0f;
    bool _326 = !(_303 == 1.0f);
    float _327 = _325 / _324;
    float _328 = select(_326, _327, 0.6666666865348816f);
    float _329 = log2(_304);
    float _330 = _329 * 3.0f;
    float _331 = exp2(_330);
    float _332 = _331 + -1.0f;
    float _333 = _304 + -1.0f;
    float _334 = _332 / _333;
    float _335 = _334 + -1.0f;
    bool _336 = !(_304 == 1.0f);
    float _337 = _335 / _334;
    float _338 = select(_336, _337, 0.6666666865348816f);
    bool _339 = (_318 <= 0.0031308000907301903f);
    bool _340 = (_328 <= 0.0031308000907301903f);
    bool _341 = (_338 <= 0.0031308000907301903f);
    float _342 = _318 * 12.920000076293945f;
    float _343 = _328 * 12.920000076293945f;
    float _344 = _338 * 12.920000076293945f;
    float _345 = log2(_318);
    float _346 = log2(_328);
    float _347 = log2(_338);
    float _348 = _345 * 0.4166666567325592f;
    float _349 = _346 * 0.4166666567325592f;
    float _350 = _347 * 0.4166666567325592f;
    float _351 = exp2(_348);
    float _352 = exp2(_349);
    float _353 = exp2(_350);
    float _354 = _351 * 1.0549999475479126f;
    float _355 = _352 * 1.0549999475479126f;
    float _356 = _353 * 1.0549999475479126f;
    float _357 = _354 + -0.054999999701976776f;
    float _358 = _355 + -0.054999999701976776f;
    float _359 = _356 + -0.054999999701976776f;
    float _360 = select(_339, _342, _357);
    float _361 = select(_340, _343, _358);
    float _362 = select(_341, _344, _359);
    int _364 = asint((User.c[3].y));
    int _365 = _364 & 1;
    bool _366 = (_365 == 0);
    if (!_366) {
      bool _375 = !(_360 <= (User.c[4].x));
      if (!_375) {
        float _377 = max(9.999999974752427e-07f, (User.c[4].x));
        float _378 = _360 / _377;
        float _379 = _378 * (User.c[4].y);
        float _380 = _378 * _378;
        float _381 = _380 * _378;
        float _382 = _381 - _378;
        float _383 = (User.c[3].z) * 0.1666666716337204f;
        float _384 = _377 * _377;
        float _385 = _384 * _383;
        float _386 = _385 * _382;
        float _387 = _386 + _379;
        _429 = _387;
      } else {
        bool _389 = !(_360 <= (User.c[4].z));
        if (!_389) {
          float _391 = (User.c[4].z) - (User.c[4].x);
          float _392 = max(9.999999974752427e-07f, _391);
          float _393 = _360 - (User.c[4].x);
          float _394 = _393 / _392;
          float _395 = 1.0f - _394;
          float _396 = _395 * (User.c[4].y);
          float _397 = _394 * (User.c[4].w);
          float _398 = _396 + _397;
          float _399 = _395 * _395;
          float _400 = _399 * _395;
          float _401 = _400 - _395;
          float _402 = _401 * (User.c[3].z);
          float _403 = _394 * _394;
          float _404 = _403 * _394;
          float _405 = _404 - _394;
          float _406 = _405 * (User.c[3].w);
          float _407 = _402 + _406;
          float _408 = _392 * _392;
          float _409 = _408 * 0.1666666716337204f;
          float _410 = _409 * _407;
          float _411 = _398 + _410;
          _429 = _411;
        } else {
          float _413 = 1.0f - (User.c[4].z);
          float _414 = _360 - (User.c[4].z);
          float _415 = max(9.999999974752427e-07f, _413);
          float _416 = _414 / _415;
          float _417 = 1.0f - _416;
          float _418 = _417 * (User.c[4].w);
          float _419 = _418 + _416;
          float _420 = _417 * _417;
          float _421 = _420 * _417;
          float _422 = _421 - _417;
          float _423 = _413 * _413;
          float _424 = _423 * 0.1666666716337204f;
          float _425 = _424 * (User.c[3].w);
          float _426 = _425 * _422;
          float _427 = _419 + _426;
          _429 = _427;
        }
      }
      float _430 = saturate(_429);
      bool _431 = !(_361 <= (User.c[4].x));
      if (!_431) {
        float _433 = max(9.999999974752427e-07f, (User.c[4].x));
        float _434 = _361 / _433;
        float _435 = _434 * (User.c[4].y);
        float _436 = _434 * _434;
        float _437 = _436 * _434;
        float _438 = _437 - _434;
        float _439 = (User.c[3].z) * 0.1666666716337204f;
        float _440 = _433 * _433;
        float _441 = _440 * _439;
        float _442 = _441 * _438;
        float _443 = _442 + _435;
        _485 = _443;
      } else {
        bool _445 = !(_361 <= (User.c[4].z));
        if (!_445) {
          float _447 = (User.c[4].z) - (User.c[4].x);
          float _448 = max(9.999999974752427e-07f, _447);
          float _449 = _361 - (User.c[4].x);
          float _450 = _449 / _448;
          float _451 = 1.0f - _450;
          float _452 = _451 * (User.c[4].y);
          float _453 = _450 * (User.c[4].w);
          float _454 = _452 + _453;
          float _455 = _451 * _451;
          float _456 = _455 * _451;
          float _457 = _456 - _451;
          float _458 = _457 * (User.c[3].z);
          float _459 = _450 * _450;
          float _460 = _459 * _450;
          float _461 = _460 - _450;
          float _462 = _461 * (User.c[3].w);
          float _463 = _458 + _462;
          float _464 = _448 * _448;
          float _465 = _464 * 0.1666666716337204f;
          float _466 = _465 * _463;
          float _467 = _454 + _466;
          _485 = _467;
        } else {
          float _469 = 1.0f - (User.c[4].z);
          float _470 = _361 - (User.c[4].z);
          float _471 = max(9.999999974752427e-07f, _469);
          float _472 = _470 / _471;
          float _473 = 1.0f - _472;
          float _474 = _473 * (User.c[4].w);
          float _475 = _474 + _472;
          float _476 = _473 * _473;
          float _477 = _476 * _473;
          float _478 = _477 - _473;
          float _479 = _469 * _469;
          float _480 = _479 * 0.1666666716337204f;
          float _481 = _480 * (User.c[3].w);
          float _482 = _481 * _478;
          float _483 = _475 + _482;
          _485 = _483;
        }
      }
      float _486 = saturate(_485);
      bool _487 = !(_362 <= (User.c[4].x));
      if (!_487) {
        float _489 = max(9.999999974752427e-07f, (User.c[4].x));
        float _490 = _362 / _489;
        float _491 = _490 * (User.c[4].y);
        float _492 = _490 * _490;
        float _493 = _492 * _490;
        float _494 = _493 - _490;
        float _495 = (User.c[3].z) * 0.1666666716337204f;
        float _496 = _489 * _489;
        float _497 = _496 * _495;
        float _498 = _497 * _494;
        float _499 = _498 + _491;
        _541 = _499;
      } else {
        bool _501 = !(_362 <= (User.c[4].z));
        if (!_501) {
          float _503 = (User.c[4].z) - (User.c[4].x);
          float _504 = max(9.999999974752427e-07f, _503);
          float _505 = _362 - (User.c[4].x);
          float _506 = _505 / _504;
          float _507 = 1.0f - _506;
          float _508 = _507 * (User.c[4].y);
          float _509 = _506 * (User.c[4].w);
          float _510 = _508 + _509;
          float _511 = _507 * _507;
          float _512 = _511 * _507;
          float _513 = _512 - _507;
          float _514 = _513 * (User.c[3].z);
          float _515 = _506 * _506;
          float _516 = _515 * _506;
          float _517 = _516 - _506;
          float _518 = _517 * (User.c[3].w);
          float _519 = _514 + _518;
          float _520 = _504 * _504;
          float _521 = _520 * 0.1666666716337204f;
          float _522 = _521 * _519;
          float _523 = _510 + _522;
          _541 = _523;
        } else {
          float _525 = 1.0f - (User.c[4].z);
          float _526 = _362 - (User.c[4].z);
          float _527 = max(9.999999974752427e-07f, _525);
          float _528 = _526 / _527;
          float _529 = 1.0f - _528;
          float _530 = _529 * (User.c[4].w);
          float _531 = _530 + _528;
          float _532 = _529 * _529;
          float _533 = _532 * _529;
          float _534 = _533 - _529;
          float _535 = _525 * _525;
          float _536 = _535 * 0.1666666716337204f;
          float _537 = _536 * (User.c[3].w);
          float _538 = _537 * _534;
          float _539 = _531 + _538;
          _541 = _539;
        }
      }
      float _542 = saturate(_541);
      _544 = _430;
      _545 = _486;
      _546 = _542;
    } else {
      _544 = _360;
      _545 = _361;
      _546 = _362;
    }
    int _547 = _364 & 2;
    bool _548 = (_547 == 0);
    if (!_548) {
      float _550 = sqrt(_544);
      float _551 = sqrt(_545);
      float _552 = sqrt(_546);
      float _553 = dot(float3(_550, _551, _552), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _554 = 1.0f - _553;
      float _555 = saturate(_554);
      _557 = _555;
    } else {
      _557 = 1.0f;
    }
    int _558 = _364 & 8;
    bool _559 = (_558 == 0);
    if (!_559) {
      bool _561 = (_557 <= 0.0031308000907301903f);
      float _562 = _557 * 12.920000076293945f;
      float _563 = log2(_557);
      float _564 = _563 * 0.4166666567325592f;
      float _565 = exp2(_564);
      float _566 = _565 * 1.0549999475479126f;
      float _567 = _566 + -0.054999999701976776f;
      float _568 = select(_561, _562, _567);
      _805 = _568;
      _806 = _568;
      _807 = _568;
    } else {
      int _570 = _364 & 4;
      bool _571 = (_570 == 0);
      if (!_571) {
        int _573 = _364 & 16;
        bool _574 = (_573 == 0);
        if (!_574) {
          float _578 = (User.c[5].x) * 0.5f;
          float _579 = _578 + 0.5f;
          bool _580 = (_579 < 0.5f);
          float _581 = (User.c[5].x) * 5.0f;
          float _582 = select(_580, (User.c[5].x), _581);
          bool _583 = (_545 < _546);
          float _584 = select(_583, _546, _545);
          float _585 = select(_583, _545, _546);
          bool _586 = (_544 < _584);
          float _587 = select(_586, _584, _544);
          float _588 = select(_586, _544, _584);
          float _589 = min(_588, _585);
          float _590 = _587 - _589;
          float _591 = _587 + 1.000000013351432e-10f;
          float _592 = _590 / _591;
          float _594 = _592 - (User.c[5].y);
          float _595 = saturate(_594);
          float _596 = max(_595, 9.999999974752427e-07f);
          float _597 = log2(_596);
          float _598 = _597 * _582;
          float _599 = exp2(_598);
          float _600 = 2.0f - _599;
          float _602 = 1.0f - (User.c[5].z);
          float _603 = saturate(_602);
          float _604 = max(_603, _600);
          float _605 = dot(float3(_544, _545, _546), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _606 = _544 - _605;
          float _607 = _545 - _605;
          float _608 = _546 - _605;
          float _609 = _606 * _604;
          float _610 = _607 * _604;
          float _611 = _608 * _604;
          float _612 = _605 - _544;
          float _613 = _612 + _609;
          float _614 = _605 - _545;
          float _615 = _614 + _610;
          float _616 = _605 - _546;
          float _617 = _616 + _611;
          float _618 = _613 * _557;
          float _619 = _615 * _557;
          float _620 = _617 * _557;
          float _621 = _618 + _544;
          float _622 = _619 + _545;
          float _623 = _620 + _546;
          _737 = _621;
          _738 = _622;
          _739 = _623;
        } else {
          bool _625 = (_557 == 0.0f);
          if (!_625) {
            float _629 = abs(User.c[5].x);
            float _630 = saturate(_629);
            uint4 _631 = 0u; s15.GetDimensions(0u, _631.x, _631.y, _631.w);
            float _634 = float((uint)_631.y);
            int _635 = _364 & 32;
            bool _636 = (_635 == 0);
            float _637 = _634 + -1.0f;
            if (!_636) {
              float _639 = 1.0f / _637;
              uint _640 = uint(SV_Position.x);
              uint _641 = uint(SV_Position.y);
              int _642 = _640 & 63;
              int _643 = _641 & 63;
              float4 _644 = sBlueNoiseR8G8.Load(int4(_642, _643, 0, 0));
              float _647 = _644.x + -0.5f;
              float _648 = _544 * 13.999999046325684f;
              float _649 = _545 * 13.999999046325684f;
              float _650 = _546 * 13.999999046325684f;
              float _651 = saturate(_648);
              float _652 = saturate(_649);
              float _653 = saturate(_650);
              float _654 = _544 + -0.9285714030265808f;
              float _655 = _545 + -0.9285714030265808f;
              float _656 = _546 + -0.9285714030265808f;
              float _657 = _654 * 13.999999046325684f;
              float _658 = _655 * 13.999999046325684f;
              float _659 = _656 * 13.999999046325684f;
              float _660 = saturate(_657);
              float _661 = saturate(_658);
              float _662 = saturate(_659);
              float _663 = 1.0f - _660;
              float _664 = 1.0f - _661;
              float _665 = 1.0f - _662;
              float _666 = min(_651, _663);
              float _667 = min(_652, _664);
              float _668 = min(_653, _665);
              float _669 = _644.y + -0.5f;
              float _670 = _666 * _669;
              float _671 = _667 * _669;
              float _672 = _668 * _669;
              float _673 = _670 + _647;
              float _674 = _671 + _647;
              float _675 = _672 + _647;
              float _676 = _673 * _639;
              float _677 = _674 * _639;
              float _678 = _675 * _639;
              float _679 = _676 + _544;
              float _680 = _677 + _545;
              float _681 = _678 + _546;
              float _682 = saturate(_679);
              float _683 = saturate(_680);
              float _684 = saturate(_681);
              float _685 = saturate(_682);
              float _686 = saturate(_683);
              float _687 = saturate(_684);
              _689 = _685;
              _690 = _686;
              _691 = _687;
            } else {
              _689 = _544;
              _690 = _545;
              _691 = _546;
            }
            float _692 = float((uint)_631.x);
            float _693 = _637 / _692;
            float _694 = _693 * _689;
            float _695 = 0.5f / _692;
            float _696 = _694 + _695;
            float _697 = _637 / _634;
            float _698 = _697 * _690;
            float _699 = 0.5f / _634;
            float _700 = _698 + _699;
            float _701 = _691 * _637;
            float _702 = floor(_701);
            float _703 = frac(_701);
            float _704 = _702 / _634;
            float _705 = _704 + _696;
            float _706 = _702 + 1.0f;
            float _707 = _706 / _634;
            float _708 = _707 + _696;
            float4 _709 = s15.Sample(s15Sampler, float2(_705, _700));
            float4 _713 = s15.Sample(s15Sampler, float2(_708, _700));
            float _717 = _713.x - _709.x;
            float _718 = _713.y - _709.y;
            float _719 = _713.z - _709.z;
            float _720 = _717 * _703;
            float _721 = _718 * _703;
            float _722 = _719 * _703;
            float _723 = _630 * _557;
            float _724 = _709.x - _544;
            float _725 = _724 + _720;
            float _726 = _709.y - _545;
            float _727 = _726 + _721;
            float _728 = _709.z - _546;
            float _729 = _728 + _722;
            float _730 = _725 * _723;
            float _731 = _727 * _723;
            float _732 = _729 * _723;
            float _733 = _730 + _544;
            float _734 = _731 + _545;
            float _735 = _732 + _546;
            _737 = _733;
            _738 = _734;
            _739 = _735;
          } else {
            _737 = _544;
            _738 = _545;
            _739 = _546;
          }
        }
      } else {
        _737 = _544;
        _738 = _545;
        _739 = _546;
      }
      bool _740 = (_737 <= 0.040449999272823334f);
      bool _741 = (_738 <= 0.040449999272823334f);
      bool _742 = (_739 <= 0.040449999272823334f);
      float _743 = _737 * 0.07739938050508499f;
      float _744 = _738 * 0.07739938050508499f;
      float _745 = _739 * 0.07739938050508499f;
      float _746 = _737 + 0.054999999701976776f;
      float _747 = _738 + 0.054999999701976776f;
      float _748 = _739 + 0.054999999701976776f;
      float _749 = _746 * 0.9478673338890076f;
      float _750 = _747 * 0.9478673338890076f;
      float _751 = _748 * 0.9478673338890076f;
      float _752 = log2(_749);
      float _753 = log2(_750);
      float _754 = log2(_751);
      float _755 = _752 * 2.4000000953674316f;
      float _756 = _753 * 2.4000000953674316f;
      float _757 = _754 * 2.4000000953674316f;
      float _758 = exp2(_755);
      float _759 = exp2(_756);
      float _760 = exp2(_757);
      float _761 = select(_740, _743, _758);
      float _762 = select(_741, _744, _759);
      float _763 = select(_742, _745, _760);
      bool _764 = (_761 == 1.0f);
      if (!_764) {
        float _766 = _761 * _761;
        float _767 = _766 * 3.0f;
        float _768 = _761 * 2.0f;
        float _769 = _768 + 1.0f;
        float _770 = _769 - _767;
        float _771 = sqrt(_770);
        float _772 = _761 + -1.0f;
        float _773 = _772 * 2.0f;
        float _774 = _771 / _773;
        float _775 = -0.5f - _774;
        _777 = _775;
      } else {
        _777 = 1e+06f;
      }
      bool _778 = (_762 == 1.0f);
      if (!_778) {
        float _780 = _762 * _762;
        float _781 = _780 * 3.0f;
        float _782 = _762 * 2.0f;
        float _783 = _782 + 1.0f;
        float _784 = _783 - _781;
        float _785 = sqrt(_784);
        float _786 = _762 + -1.0f;
        float _787 = _786 * 2.0f;
        float _788 = _785 / _787;
        float _789 = -0.5f - _788;
        _791 = _789;
      } else {
        _791 = 1e+06f;
      }
      bool _792 = (_763 == 1.0f);
      if (!_792) {
        float _794 = _763 * _763;
        float _795 = _794 * 3.0f;
        float _796 = _763 * 2.0f;
        float _797 = _796 + 1.0f;
        float _798 = _797 - _795;
        float _799 = sqrt(_798);
        float _800 = _763 + -1.0f;
        float _801 = _800 * 2.0f;
        float _802 = _799 / _801;
        float _803 = -0.5f - _802;
        _805 = _777;
        _806 = _791;
        _807 = _803;
      } else {
        _805 = _777;
        _806 = _791;
        _807 = 1e+06f;
      }
    }
  } else {
    _805 = _302;
    _806 = _303;
    _807 = _304;
  }
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_302, _303, _304),
      float3(_805, _806, _807),
      false);
  _805 = apt_tonemapped.x;
  _806 = apt_tonemapped.y;
  _807 = apt_tonemapped.z;
  bool _808 = (_805 <= 0.0031308000907301903f);
  bool _809 = (_806 <= 0.0031308000907301903f);
  bool _810 = (_807 <= 0.0031308000907301903f);
  float _811 = _805 * 12.920000076293945f;
  float _812 = _806 * 12.920000076293945f;
  float _813 = _807 * 12.920000076293945f;
  float _814 = log2(_805);
  float _815 = log2(_806);
  float _816 = log2(_807);
  float _817 = _814 * 0.4166666567325592f;
  float _818 = _815 * 0.4166666567325592f;
  float _819 = _816 * 0.4166666567325592f;
  float _820 = exp2(_817);
  float _821 = exp2(_818);
  float _822 = exp2(_819);
  float _823 = _820 * 1.0549999475479126f;
  float _824 = _821 * 1.0549999475479126f;
  float _825 = _822 * 1.0549999475479126f;
  float _826 = _823 + -0.054999999701976776f;
  float _827 = _824 + -0.054999999701976776f;
  float _828 = _825 + -0.054999999701976776f;
  float _829 = select(_808, _811, _826);
  float _830 = select(_809, _812, _827);
  float _831 = select(_810, _813, _828);
  float _832 = log2(_829);
  float _833 = log2(_830);
  float _834 = log2(_831);
  float _835 = floor(_832);
  float _836 = floor(_833);
  float _837 = floor(_834);
  float _838 = _835 + -6.0f;
  float _839 = _836 + -6.0f;
  float _840 = _837 + -5.0f;
  float _841 = exp2(_838);
  float _842 = exp2(_839);
  float _843 = exp2(_840);
  uint _844 = uint(SV_Position.x);
  uint _845 = uint(SV_Position.y);
  int _846 = _844 & 63;
  int _847 = _845 & 63;
  float4 _848 = sBlueNoiseR8.Load(int4(_846, _847, 0, 0));
  float _850 = _848.x + -0.5f;
  bool _851 = (_829 > 0.0f);
  bool _852 = (_830 > 0.0f);
  bool _853 = (_831 > 0.0f);
  float _854 = float((bool)_851);
  float _855 = float((bool)_852);
  float _856 = float((bool)_853);
  float _857 = _841 * _854;
  float _858 = _857 * _850;
  float _859 = _842 * _855;
  float _860 = _859 * _850;
  float _861 = _843 * _856;
  float _862 = _861 * _850;
  float _863 = _858 + _829;
  float _864 = _860 + _830;
  float _865 = _862 + _831;
  SV_Target.x = _863;
  SV_Target.y = _864;
  SV_Target.z = _865;
  SV_Target.w = _44.w;
  return SV_Target;
}
