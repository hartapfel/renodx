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
  struct StructGlobalConstant_Z {
    float4 c[174];
  } Global : packoffset(c000.x);
};

cbuffer CBufferUserConstant_Z : register(b0) {
  struct StructUserConstant_Z {
    float4 c[183];
  } User : packoffset(c000.x);
};

cbuffer CBufferPostProcessConstant_Z : register(b2) {
  struct StructPostProcessConstant_Z {
    float4 Settings[16];
    float4 OffsetWeight[32];
  } PostProcess : packoffset(c000.x);
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
  float4 SV_Target;
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
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_49, _50, _51),
      max(_44.rgb, 0.f.xxx),
      float2(_41, _43),
      s0,
      s0Sampler,
      _40);
  _49 = renodx_chromatic_aberration_input.x;
  _50 = renodx_chromatic_aberration_input.y;
  _51 = renodx_chromatic_aberration_input.z;
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
  float _130 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _131 = _126.x * 11190.6005859375f;
  float _132 = _131 * _123;
  float _133 = _132 * _130;
  float _134 = _131 * _124;
  float _135 = _134 * _130;
  float _136 = _131 * _125;
  float _137 = _136 * _130;
  float _138 = _133 + 1.0f;
  float _139 = _135 + 1.0f;
  float _140 = _137 + 1.0f;
  float _141 = log2(_138);
  float _142 = log2(_139);
  float _143 = log2(_140);
  float _144 = _141 * 0.07434873282909393f;
  float _145 = _142 * 0.07434873282909393f;
  float _146 = _143 * 0.07434873282909393f;
  float _149 = _144 * (PostProcess.OffsetWeight[0].x);
  float _150 = _145 * (PostProcess.OffsetWeight[0].x);
  float _151 = _146 * (PostProcess.OffsetWeight[0].x);
  float _153 = _149 + (PostProcess.OffsetWeight[0].y);
  float _154 = _150 + (PostProcess.OffsetWeight[0].y);
  float _155 = _151 + (PostProcess.OffsetWeight[0].y);
  float4 _156 = s3_3D.Sample(s3_3DSampler, float3(_153, _154, _155));
  float _162 = _156.x * 13.450128555297852f;
  float _163 = _156.y * 13.450128555297852f;
  float _164 = _156.z * 13.450128555297852f;
  float _165 = exp2(_162);
  float _166 = exp2(_163);
  float _167 = exp2(_164);
  float _168 = _165 + -1.0f;
  float _169 = _166 + -1.0f;
  float _170 = _167 + -1.0f;
  float _171 = _168 * 8.936070662457496e-05f;
  float _172 = _169 * 8.936070662457496e-05f;
  float _173 = _170 * 8.936070662457496e-05f;
  float _174 = 10000.0f / (PostProcess.Settings[10].w);
  float _175 = _171 * _174;
  float _176 = _172 * _174;
  float _177 = _173 * _174;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUT(
      float3(_133, _135, _137) / apt_lut_input_encode_scale,
      float3(_175, _176, _177));
  apt_lut_output = APTApplyPerceptualFilmGrain(apt_lut_output, SV_Position.xy);
  _175 = apt_lut_output.x;
  _176 = apt_lut_output.y;
  _177 = apt_lut_output.z;
  float _181 = (User.c[2].y) / (User.c[2].x);
  int _184 = asint((Global.c[1].w));
  uint _185 = _184 + 30u;
  int _186 = _185 & 63;
  float _187 = _41 * 8.0f;
  float _188 = _187 * _181;
  float _189 = _43 * 8.0f;
  float _190 = float((int)(_184));
  float4 _191 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_188, _189, _190), 0.0f);
  float _193 = _41 + 0.5f;
  float _194 = (User.c[2].x) * 0.5f;
  float _195 = _193 + _194;
  float _196 = _181 * 8.0f;
  float _197 = _196 * _195;
  float _198 = _43 + 0.5f;
  float _199 = (User.c[2].y) * 0.5f;
  float _200 = _198 + _199;
  float _201 = _200 * 8.0f;
  float _202 = float((int)(_186));
  float4 _203 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_197, _201, _202), 0.0f);
  float _205 = _203.x + _191.x;
  float _206 = _205 * 0.714285671710968f;
  float _207 = _206 + -0.2142857164144516f;
  float _208 = saturate(_207);
  float _209 = _208 * 2.0f;
  float _210 = 3.0f - _209;
  float _211 = _208 * _208;
  float _212 = _211 * _210;
  float _213 = _212 * 0.5f;
  float _214 = _212 * 0.4000000059604645f;
  float _215 = _212 * 0.05000000074505806f;
  float _216 = _213 + -0.5f;
  float _217 = _214 + -0.6000000238418579f;
  float _218 = _215 + -0.949999988079071f;
  float _219 = _216 * _76;
  float _220 = _217 * _76;
  float _221 = _218 * _76;
  float _222 = _219 + 1.0f;
  float _223 = _220 + 1.0f;
  float _224 = _221 + 1.0f;
  float _225 = _175 * _222;
  float _226 = _176 * _223;
  float _227 = _177 * _224;
  float4 _228 = s13.Sample(s13Sampler, float2(_41, _43));
  float _235 = _91 + 1.0f;
  float _236 = saturate(_235);
  float _237 = (User.c[2].x) * _236;
  float _238 = (User.c[2].y) * _236;
  float _239 = _237 + _41;
  float _240 = _238 + _43;
  float4 _241 = s13.Sample(s13Sampler, float2(_239, _240));
  float _245 = _241.x + _228.x;
  float _246 = _241.y + _228.y;
  float _247 = _241.z + _228.z;
  float _248 = _245 * 0.5f;
  float _249 = _246 * 0.5f;
  float _250 = _247 * 0.5f;
  float _251 = _76 * 0.6000000238418579f;
  float _252 = _251 * _74;
  float _253 = _76 * 0.7300000190734863f;
  float _254 = _253 * _74;
  float _255 = _76 * 0.8799999952316284f;
  float _256 = _255 * _74;
  float _257 = 1.0f - _252;
  float _258 = 1.0f - _254;
  float _259 = 1.0f - _256;
  float _260 = saturate(_257);
  float _261 = saturate(_258);
  float _262 = saturate(_259);
  float _263 = _225 * _260;
  float _264 = _226 * _261;
  float _265 = _227 * _262;
  float _266 = _248 + _263;
  float _267 = _264 + _249;
  float _268 = _265 + _250;
  bool _271 = ((User.c[3].x) > 0.0f);
  float _393;
  float _449;
  float _505;
  float _508;
  float _509;
  float _510;
  float _521;
  float _653;
  float _654;
  float _655;
  float _701;
  float _702;
  float _703;
  float _741;
  float _755;
  float _769;
  float _770;
  float _771;
  if (_271) {
    float _273 = log2(_266);
    float _274 = _273 * 3.0f;
    float _275 = exp2(_274);
    float _276 = _275 + -1.0f;
    float _277 = _266 + -1.0f;
    float _278 = _276 / _277;
    float _279 = _278 + -1.0f;
    bool _280 = !(_266 == 1.0f);
    float _281 = _279 / _278;
    float _282 = select(_280, _281, 0.6666666865348816f);
    float _283 = log2(_267);
    float _284 = _283 * 3.0f;
    float _285 = exp2(_284);
    float _286 = _285 + -1.0f;
    float _287 = _267 + -1.0f;
    float _288 = _286 / _287;
    float _289 = _288 + -1.0f;
    bool _290 = !(_267 == 1.0f);
    float _291 = _289 / _288;
    float _292 = select(_290, _291, 0.6666666865348816f);
    float _293 = log2(_268);
    float _294 = _293 * 3.0f;
    float _295 = exp2(_294);
    float _296 = _295 + -1.0f;
    float _297 = _268 + -1.0f;
    float _298 = _296 / _297;
    float _299 = _298 + -1.0f;
    bool _300 = !(_268 == 1.0f);
    float _301 = _299 / _298;
    float _302 = select(_300, _301, 0.6666666865348816f);
    bool _303 = (_282 <= 0.0031308000907301903f);
    bool _304 = (_292 <= 0.0031308000907301903f);
    bool _305 = (_302 <= 0.0031308000907301903f);
    float _306 = _282 * 12.920000076293945f;
    float _307 = _292 * 12.920000076293945f;
    float _308 = _302 * 12.920000076293945f;
    float _309 = log2(_282);
    float _310 = log2(_292);
    float _311 = log2(_302);
    float _312 = _309 * 0.4166666567325592f;
    float _313 = _310 * 0.4166666567325592f;
    float _314 = _311 * 0.4166666567325592f;
    float _315 = exp2(_312);
    float _316 = exp2(_313);
    float _317 = exp2(_314);
    float _318 = _315 * 1.0549999475479126f;
    float _319 = _316 * 1.0549999475479126f;
    float _320 = _317 * 1.0549999475479126f;
    float _321 = _318 + -0.054999999701976776f;
    float _322 = _319 + -0.054999999701976776f;
    float _323 = _320 + -0.054999999701976776f;
    float _324 = select(_303, _306, _321);
    float _325 = select(_304, _307, _322);
    float _326 = select(_305, _308, _323);
    int _328 = asint((User.c[3].y));
    int _329 = _328 & 1;
    bool _330 = (_329 == 0);
    if (!_330) {
      bool _339 = !(_324 <= (User.c[4].x));
      if (!_339) {
        float _341 = max(9.999999974752427e-07f, (User.c[4].x));
        float _342 = _324 / _341;
        float _343 = _342 * (User.c[4].y);
        float _344 = _342 * _342;
        float _345 = _344 * _342;
        float _346 = _345 - _342;
        float _347 = (User.c[3].z) * 0.1666666716337204f;
        float _348 = _341 * _341;
        float _349 = _348 * _347;
        float _350 = _349 * _346;
        float _351 = _350 + _343;
        _393 = _351;
      } else {
        bool _353 = !(_324 <= (User.c[4].z));
        if (!_353) {
          float _355 = (User.c[4].z) - (User.c[4].x);
          float _356 = max(9.999999974752427e-07f, _355);
          float _357 = _324 - (User.c[4].x);
          float _358 = _357 / _356;
          float _359 = 1.0f - _358;
          float _360 = _359 * (User.c[4].y);
          float _361 = _358 * (User.c[4].w);
          float _362 = _360 + _361;
          float _363 = _359 * _359;
          float _364 = _363 * _359;
          float _365 = _364 - _359;
          float _366 = _365 * (User.c[3].z);
          float _367 = _358 * _358;
          float _368 = _367 * _358;
          float _369 = _368 - _358;
          float _370 = _369 * (User.c[3].w);
          float _371 = _366 + _370;
          float _372 = _356 * _356;
          float _373 = _372 * 0.1666666716337204f;
          float _374 = _373 * _371;
          float _375 = _362 + _374;
          _393 = _375;
        } else {
          float _377 = 1.0f - (User.c[4].z);
          float _378 = _324 - (User.c[4].z);
          float _379 = max(9.999999974752427e-07f, _377);
          float _380 = _378 / _379;
          float _381 = 1.0f - _380;
          float _382 = _381 * (User.c[4].w);
          float _383 = _382 + _380;
          float _384 = _381 * _381;
          float _385 = _384 * _381;
          float _386 = _385 - _381;
          float _387 = _377 * _377;
          float _388 = _387 * 0.1666666716337204f;
          float _389 = _388 * (User.c[3].w);
          float _390 = _389 * _386;
          float _391 = _383 + _390;
          _393 = _391;
        }
      }
      float _394 = saturate(_393);
      bool _395 = !(_325 <= (User.c[4].x));
      if (!_395) {
        float _397 = max(9.999999974752427e-07f, (User.c[4].x));
        float _398 = _325 / _397;
        float _399 = _398 * (User.c[4].y);
        float _400 = _398 * _398;
        float _401 = _400 * _398;
        float _402 = _401 - _398;
        float _403 = (User.c[3].z) * 0.1666666716337204f;
        float _404 = _397 * _397;
        float _405 = _404 * _403;
        float _406 = _405 * _402;
        float _407 = _406 + _399;
        _449 = _407;
      } else {
        bool _409 = !(_325 <= (User.c[4].z));
        if (!_409) {
          float _411 = (User.c[4].z) - (User.c[4].x);
          float _412 = max(9.999999974752427e-07f, _411);
          float _413 = _325 - (User.c[4].x);
          float _414 = _413 / _412;
          float _415 = 1.0f - _414;
          float _416 = _415 * (User.c[4].y);
          float _417 = _414 * (User.c[4].w);
          float _418 = _416 + _417;
          float _419 = _415 * _415;
          float _420 = _419 * _415;
          float _421 = _420 - _415;
          float _422 = _421 * (User.c[3].z);
          float _423 = _414 * _414;
          float _424 = _423 * _414;
          float _425 = _424 - _414;
          float _426 = _425 * (User.c[3].w);
          float _427 = _422 + _426;
          float _428 = _412 * _412;
          float _429 = _428 * 0.1666666716337204f;
          float _430 = _429 * _427;
          float _431 = _418 + _430;
          _449 = _431;
        } else {
          float _433 = 1.0f - (User.c[4].z);
          float _434 = _325 - (User.c[4].z);
          float _435 = max(9.999999974752427e-07f, _433);
          float _436 = _434 / _435;
          float _437 = 1.0f - _436;
          float _438 = _437 * (User.c[4].w);
          float _439 = _438 + _436;
          float _440 = _437 * _437;
          float _441 = _440 * _437;
          float _442 = _441 - _437;
          float _443 = _433 * _433;
          float _444 = _443 * 0.1666666716337204f;
          float _445 = _444 * (User.c[3].w);
          float _446 = _445 * _442;
          float _447 = _439 + _446;
          _449 = _447;
        }
      }
      float _450 = saturate(_449);
      bool _451 = !(_326 <= (User.c[4].x));
      if (!_451) {
        float _453 = max(9.999999974752427e-07f, (User.c[4].x));
        float _454 = _326 / _453;
        float _455 = _454 * (User.c[4].y);
        float _456 = _454 * _454;
        float _457 = _456 * _454;
        float _458 = _457 - _454;
        float _459 = (User.c[3].z) * 0.1666666716337204f;
        float _460 = _453 * _453;
        float _461 = _460 * _459;
        float _462 = _461 * _458;
        float _463 = _462 + _455;
        _505 = _463;
      } else {
        bool _465 = !(_326 <= (User.c[4].z));
        if (!_465) {
          float _467 = (User.c[4].z) - (User.c[4].x);
          float _468 = max(9.999999974752427e-07f, _467);
          float _469 = _326 - (User.c[4].x);
          float _470 = _469 / _468;
          float _471 = 1.0f - _470;
          float _472 = _471 * (User.c[4].y);
          float _473 = _470 * (User.c[4].w);
          float _474 = _472 + _473;
          float _475 = _471 * _471;
          float _476 = _475 * _471;
          float _477 = _476 - _471;
          float _478 = _477 * (User.c[3].z);
          float _479 = _470 * _470;
          float _480 = _479 * _470;
          float _481 = _480 - _470;
          float _482 = _481 * (User.c[3].w);
          float _483 = _478 + _482;
          float _484 = _468 * _468;
          float _485 = _484 * 0.1666666716337204f;
          float _486 = _485 * _483;
          float _487 = _474 + _486;
          _505 = _487;
        } else {
          float _489 = 1.0f - (User.c[4].z);
          float _490 = _326 - (User.c[4].z);
          float _491 = max(9.999999974752427e-07f, _489);
          float _492 = _490 / _491;
          float _493 = 1.0f - _492;
          float _494 = _493 * (User.c[4].w);
          float _495 = _494 + _492;
          float _496 = _493 * _493;
          float _497 = _496 * _493;
          float _498 = _497 - _493;
          float _499 = _489 * _489;
          float _500 = _499 * 0.1666666716337204f;
          float _501 = _500 * (User.c[3].w);
          float _502 = _501 * _498;
          float _503 = _495 + _502;
          _505 = _503;
        }
      }
      float _506 = saturate(_505);
      _508 = _394;
      _509 = _450;
      _510 = _506;
    } else {
      _508 = _324;
      _509 = _325;
      _510 = _326;
    }
    int _511 = _328 & 2;
    bool _512 = (_511 == 0);
    if (!_512) {
      float _514 = sqrt(_508);
      float _515 = sqrt(_509);
      float _516 = sqrt(_510);
      float _517 = dot(float3(_514, _515, _516), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _518 = 1.0f - _517;
      float _519 = saturate(_518);
      _521 = _519;
    } else {
      _521 = 1.0f;
    }
    int _522 = _328 & 8;
    bool _523 = (_522 == 0);
    if (!_523) {
      bool _525 = (_521 <= 0.0031308000907301903f);
      float _526 = _521 * 12.920000076293945f;
      float _527 = log2(_521);
      float _528 = _527 * 0.4166666567325592f;
      float _529 = exp2(_528);
      float _530 = _529 * 1.0549999475479126f;
      float _531 = _530 + -0.054999999701976776f;
      float _532 = select(_525, _526, _531);
      _769 = _532;
      _770 = _532;
      _771 = _532;
    } else {
      int _534 = _328 & 4;
      bool _535 = (_534 == 0);
      if (!_535) {
        int _537 = _328 & 16;
        bool _538 = (_537 == 0);
        if (!_538) {
          float _542 = (User.c[5].x) * 0.5f;
          float _543 = _542 + 0.5f;
          bool _544 = (_543 < 0.5f);
          float _545 = (User.c[5].x) * 5.0f;
          float _546 = select(_544, (User.c[5].x), _545);
          bool _547 = (_509 < _510);
          float _548 = select(_547, _510, _509);
          float _549 = select(_547, _509, _510);
          bool _550 = (_508 < _548);
          float _551 = select(_550, _548, _508);
          float _552 = select(_550, _508, _548);
          float _553 = min(_552, _549);
          float _554 = _551 - _553;
          float _555 = _551 + 1.000000013351432e-10f;
          float _556 = _554 / _555;
          float _558 = _556 - (User.c[5].y);
          float _559 = saturate(_558);
          float _560 = max(_559, 9.999999974752427e-07f);
          float _561 = log2(_560);
          float _562 = _561 * _546;
          float _563 = exp2(_562);
          float _564 = 2.0f - _563;
          float _566 = 1.0f - (User.c[5].z);
          float _567 = saturate(_566);
          float _568 = max(_567, _564);
          float _569 = dot(float3(_508, _509, _510), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _570 = _508 - _569;
          float _571 = _509 - _569;
          float _572 = _510 - _569;
          float _573 = _570 * _568;
          float _574 = _571 * _568;
          float _575 = _572 * _568;
          float _576 = _569 - _508;
          float _577 = _576 + _573;
          float _578 = _569 - _509;
          float _579 = _578 + _574;
          float _580 = _569 - _510;
          float _581 = _580 + _575;
          float _582 = _577 * _521;
          float _583 = _579 * _521;
          float _584 = _581 * _521;
          float _585 = _582 + _508;
          float _586 = _583 + _509;
          float _587 = _584 + _510;
          _701 = _585;
          _702 = _586;
          _703 = _587;
        } else {
          bool _589 = (_521 == 0.0f);
          if (!_589) {
            float _593 = abs(User.c[5].x);
            float _594 = saturate(_593);
            uint2 _595; s15.GetDimensions(_595.x, _595.y);
            float _598 = float((uint)_595.y);
            int _599 = _328 & 32;
            bool _600 = (_599 == 0);
            float _601 = _598 + -1.0f;
            if (!_600) {
              float _603 = 1.0f / _601;
              uint _604 = uint(SV_Position.x);
              uint _605 = uint(SV_Position.y);
              int _606 = _604 & 63;
              int _607 = _605 & 63;
              float4 _608 = sBlueNoiseR8G8.Load(int4(_606, _607, 0, 0));
              float _611 = _608.x + -0.5f;
              float _612 = _508 * 13.999999046325684f;
              float _613 = _509 * 13.999999046325684f;
              float _614 = _510 * 13.999999046325684f;
              float _615 = saturate(_612);
              float _616 = saturate(_613);
              float _617 = saturate(_614);
              float _618 = _508 + -0.9285714030265808f;
              float _619 = _509 + -0.9285714030265808f;
              float _620 = _510 + -0.9285714030265808f;
              float _621 = _618 * 13.999999046325684f;
              float _622 = _619 * 13.999999046325684f;
              float _623 = _620 * 13.999999046325684f;
              float _624 = saturate(_621);
              float _625 = saturate(_622);
              float _626 = saturate(_623);
              float _627 = 1.0f - _624;
              float _628 = 1.0f - _625;
              float _629 = 1.0f - _626;
              float _630 = min(_615, _627);
              float _631 = min(_616, _628);
              float _632 = min(_617, _629);
              float _633 = _608.y + -0.5f;
              float _634 = _630 * _633;
              float _635 = _631 * _633;
              float _636 = _632 * _633;
              float _637 = _634 + _611;
              float _638 = _635 + _611;
              float _639 = _636 + _611;
              float _640 = _637 * _603;
              float _641 = _638 * _603;
              float _642 = _639 * _603;
              float _643 = _640 + _508;
              float _644 = _641 + _509;
              float _645 = _642 + _510;
              float _646 = saturate(_643);
              float _647 = saturate(_644);
              float _648 = saturate(_645);
              float _649 = saturate(_646);
              float _650 = saturate(_647);
              float _651 = saturate(_648);
              _653 = _649;
              _654 = _650;
              _655 = _651;
            } else {
              _653 = _508;
              _654 = _509;
              _655 = _510;
            }
            float _656 = float((uint)_595.x);
            float _657 = _601 / _656;
            float _658 = _657 * _653;
            float _659 = 0.5f / _656;
            float _660 = _658 + _659;
            float _661 = _601 / _598;
            float _662 = _661 * _654;
            float _663 = 0.5f / _598;
            float _664 = _662 + _663;
            float _665 = _655 * _601;
            float _666 = floor(_665);
            float _667 = frac(_665);
            float _668 = _666 / _598;
            float _669 = _668 + _660;
            float _670 = _666 + 1.0f;
            float _671 = _670 / _598;
            float _672 = _671 + _660;
            float4 _673 = s15.Sample(s15Sampler, float2(_669, _664));
            float4 _677 = s15.Sample(s15Sampler, float2(_672, _664));
            float _681 = _677.x - _673.x;
            float _682 = _677.y - _673.y;
            float _683 = _677.z - _673.z;
            float _684 = _681 * _667;
            float _685 = _682 * _667;
            float _686 = _683 * _667;
            float _687 = _594 * _521;
            float _688 = _673.x - _508;
            float _689 = _688 + _684;
            float _690 = _673.y - _509;
            float _691 = _690 + _685;
            float _692 = _673.z - _510;
            float _693 = _692 + _686;
            float _694 = _689 * _687;
            float _695 = _691 * _687;
            float _696 = _693 * _687;
            float _697 = _694 + _508;
            float _698 = _695 + _509;
            float _699 = _696 + _510;
            _701 = _697;
            _702 = _698;
            _703 = _699;
          } else {
            _701 = _508;
            _702 = _509;
            _703 = _510;
          }
        }
      } else {
        _701 = _508;
        _702 = _509;
        _703 = _510;
      }
      bool _704 = (_701 <= 0.040449999272823334f);
      bool _705 = (_702 <= 0.040449999272823334f);
      bool _706 = (_703 <= 0.040449999272823334f);
      float _707 = _701 * 0.07739938050508499f;
      float _708 = _702 * 0.07739938050508499f;
      float _709 = _703 * 0.07739938050508499f;
      float _710 = _701 + 0.054999999701976776f;
      float _711 = _702 + 0.054999999701976776f;
      float _712 = _703 + 0.054999999701976776f;
      float _713 = _710 * 0.9478673338890076f;
      float _714 = _711 * 0.9478673338890076f;
      float _715 = _712 * 0.9478673338890076f;
      float _716 = log2(_713);
      float _717 = log2(_714);
      float _718 = log2(_715);
      float _719 = _716 * 2.4000000953674316f;
      float _720 = _717 * 2.4000000953674316f;
      float _721 = _718 * 2.4000000953674316f;
      float _722 = exp2(_719);
      float _723 = exp2(_720);
      float _724 = exp2(_721);
      float _725 = select(_704, _707, _722);
      float _726 = select(_705, _708, _723);
      float _727 = select(_706, _709, _724);
      bool _728 = (_725 == 1.0f);
      if (!_728) {
        float _730 = _725 * _725;
        float _731 = _730 * 3.0f;
        float _732 = _725 * 2.0f;
        float _733 = _732 + 1.0f;
        float _734 = _733 - _731;
        float _735 = sqrt(_734);
        float _736 = _725 + -1.0f;
        float _737 = _736 * 2.0f;
        float _738 = _735 / _737;
        float _739 = -0.5f - _738;
        _741 = _739;
      } else {
        _741 = 1e+06f;
      }
      bool _742 = (_726 == 1.0f);
      if (!_742) {
        float _744 = _726 * _726;
        float _745 = _744 * 3.0f;
        float _746 = _726 * 2.0f;
        float _747 = _746 + 1.0f;
        float _748 = _747 - _745;
        float _749 = sqrt(_748);
        float _750 = _726 + -1.0f;
        float _751 = _750 * 2.0f;
        float _752 = _749 / _751;
        float _753 = -0.5f - _752;
        _755 = _753;
      } else {
        _755 = 1e+06f;
      }
      bool _756 = (_727 == 1.0f);
      if (!_756) {
        float _758 = _727 * _727;
        float _759 = _758 * 3.0f;
        float _760 = _727 * 2.0f;
        float _761 = _760 + 1.0f;
        float _762 = _761 - _759;
        float _763 = sqrt(_762);
        float _764 = _727 + -1.0f;
        float _765 = _764 * 2.0f;
        float _766 = _763 / _765;
        float _767 = -0.5f - _766;
        _769 = _741;
        _770 = _755;
        _771 = _767;
      } else {
        _769 = _741;
        _770 = _755;
        _771 = 1e+06f;
      }
    }
  } else {
    _769 = _266;
    _770 = _267;
    _771 = _268;
  }
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_266, _267, _268),
      float3(_769, _770, _771),
      false);
  _769 = apt_tonemapped.x;
  _770 = apt_tonemapped.y;
  _771 = apt_tonemapped.z;
  bool _772 = (_769 <= 0.0031308000907301903f);
  bool _773 = (_770 <= 0.0031308000907301903f);
  bool _774 = (_771 <= 0.0031308000907301903f);
  float _775 = _769 * 12.920000076293945f;
  float _776 = _770 * 12.920000076293945f;
  float _777 = _771 * 12.920000076293945f;
  float _778 = log2(_769);
  float _779 = log2(_770);
  float _780 = log2(_771);
  float _781 = _778 * 0.4166666567325592f;
  float _782 = _779 * 0.4166666567325592f;
  float _783 = _780 * 0.4166666567325592f;
  float _784 = exp2(_781);
  float _785 = exp2(_782);
  float _786 = exp2(_783);
  float _787 = _784 * 1.0549999475479126f;
  float _788 = _785 * 1.0549999475479126f;
  float _789 = _786 * 1.0549999475479126f;
  float _790 = _787 + -0.054999999701976776f;
  float _791 = _788 + -0.054999999701976776f;
  float _792 = _789 + -0.054999999701976776f;
  float _793 = select(_772, _775, _790);
  float _794 = select(_773, _776, _791);
  float _795 = select(_774, _777, _792);
  float _796 = log2(_793);
  float _797 = log2(_794);
  float _798 = log2(_795);
  float _799 = floor(_796);
  float _800 = floor(_797);
  float _801 = floor(_798);
  float _802 = _799 + -6.0f;
  float _803 = _800 + -6.0f;
  float _804 = _801 + -5.0f;
  float _805 = exp2(_802);
  float _806 = exp2(_803);
  float _807 = exp2(_804);
  uint _808 = uint(SV_Position.x);
  uint _809 = uint(SV_Position.y);
  int _810 = _808 & 63;
  int _811 = _809 & 63;
  float4 _812 = sBlueNoiseR8.Load(int4(_810, _811, 0, 0));
  float _814 = _812.x + -0.5f;
  bool _815 = (_793 > 0.0f);
  bool _816 = (_794 > 0.0f);
  bool _817 = (_795 > 0.0f);
  float _818 = float((bool)_815);
  float _819 = float((bool)_816);
  float _820 = float((bool)_817);
  float _821 = _805 * _818;
  float _822 = _821 * _814;
  float _823 = _806 * _819;
  float _824 = _823 * _814;
  float _825 = _807 * _820;
  float _826 = _825 * _814;
  float _827 = _822 + _793;
  float _828 = _824 + _794;
  float _829 = _826 + _795;
  SV_Target.x = _827;
  SV_Target.y = _828;
  SV_Target.z = _829;
  SV_Target.w = _44.w;
  return SV_Target;
}
