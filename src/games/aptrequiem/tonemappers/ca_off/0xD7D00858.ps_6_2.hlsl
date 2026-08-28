Texture2DArray<float4> sBlueNoiseR8 : register(t1);

Texture2DArray<float4> sBlueNoiseR8G8 : register(t9);

Texture2D<float4> s0 : register(t0);

Texture2D<float4> s2 : register(t2);

Texture2D<float4> s4 : register(t4);

Texture2D<float4> s5 : register(t5);

Texture2D<float4> s6 : register(t6);

Texture2D<float4> s7 : register(t7);

Texture2D<float4> s8 : register(t8);

Texture2D<float4> s12_bloom : register(t12);

Texture2D<float4> s13 : register(t13);

Texture2D<float4> s14 : register(t14);

Texture2D<float4> s15 : register(t15);

Texture2D<float4> sPlagueFX_MaskLayer : register(t16);

Texture3D<float4> s3_3D : register(t3);

#include "../../common.hlsli"

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

SamplerState s2Sampler : register(s2);

SamplerState s4Sampler : register(s4);

SamplerState s5Sampler : register(s5);

SamplerState s7Sampler : register(s7);

SamplerState s8Sampler : register(s8);

SamplerState s12_bloomSampler : register(s12);

SamplerState s13Sampler : register(s13);

SamplerState s14Sampler : register(s14);

SamplerState s15Sampler : register(s15);

SamplerState s3_3DSampler : register(s3);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  int _39 = asint((Global.c[43].w));
  float4 _40 = s14.Sample(s14Sampler, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _44 = sPlagueFX_MaskLayer.Sample(s13Sampler, float2(TEXCOORD.z, TEXCOORD.w));
  float _46 = _44.y * 0.10000000149011612f;
  float _47 = _46 + _40.y;
  float _48 = _44.y * 0.5f;
  float _49 = _48 + _40.z;
  float _50 = exp2(_49);
  float _51 = _50 + -1.0f;
  float _54 = (PostProcess.Settings[11].y) * _51;
  float _55 = _54 + 1.0f;
  float _56 = log2(_55);
  float _57 = _40.x + TEXCOORD.z;
  float _58 = _47 + TEXCOORD.w;
  float _59 = _40.x + TEXCOORD.x;
  float _60 = _47 + TEXCOORD.y;
  float4 _61 = s0.SampleLevel(s0Sampler, float2(_57, _58), _56);
  float _66 = max(_61.x, 0.0f);
  float _67 = max(_61.y, 0.0f);
  float _68 = max(_61.z, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_66, _67, _68),
      max(_61.rgb, 0.f.xxx),
      float2(_57, _58),
      s0,
      s0Sampler,
      _56);
  _66 = renodx_chromatic_aberration_input.x;
  _67 = renodx_chromatic_aberration_input.y;
  _68 = renodx_chromatic_aberration_input.z;
  float _71 = (Global.c[32].w) * 11.0f;
  float _72 = _71 + -1.2000000476837158f;
  float _73 = saturate(_72);
  float _74 = (Global.c[32].w) * 1.7000000476837158f;
  float _75 = 1.340000033378601f - _74;
  float _76 = saturate(_75);
  float _77 = _76 * _76;
  float _78 = _77 * _77;
  float _79 = _78 * _73;
  bool _80 = ((Global.c[32].w) < 9.999999747378752e-06f);
  float _83 = max((Global.c[33].y), _79);
  float _84 = _57 * 2.0f;
  float _85 = _58 * 1.7999999523162842f;
  float _86 = _84 + -1.0f;
  float _87 = _85 + -1.100000023841858f;
  float _88 = abs(_86);
  float _89 = abs(_87);
  float _90 = dot(float2(_88, _89), float2(_88, _89));
  float _91 = sqrt(_90);
  float _92 = select(_80, 1.0f, 0.0f);
  float _93 = _92 * _83;
  float4 _94 = s0.SampleLevel(s0Sampler, float2(_57, _58), 1.0f);
  float4 _98 = s0.SampleLevel(s0Sampler, float2(_57, _58), 2.0f);
  float4 _102 = s0.SampleLevel(s0Sampler, float2(_57, _58), 3.0f);
  float _106 = _90 * 1.7000000476837158f;
  float _107 = _106 + -0.6000000238418579f;
  float _108 = saturate(_107);
  float _109 = _90 * 1.475000023841858f;
  float _110 = _109 + -0.375f;
  float _111 = saturate(_110);
  float _112 = _90 * 1.2999999523162842f;
  float _113 = _112 + -0.15000000596046448f;
  float _114 = saturate(_113);
  float _115 = _102.x - _98.x;
  float _116 = _102.y - _98.y;
  float _117 = _102.z - _98.z;
  float _118 = _115 * _108;
  float _119 = _116 * _108;
  float _120 = _117 * _108;
  float _121 = _98.x - _94.x;
  float _122 = _121 + _118;
  float _123 = _98.y - _94.y;
  float _124 = _123 + _119;
  float _125 = _98.z - _94.z;
  float _126 = _125 + _120;
  float _127 = _122 * _111;
  float _128 = _124 * _111;
  float _129 = _126 * _111;
  float _130 = _114 * _93;
  float _131 = _94.x - _66;
  float _132 = _131 + _127;
  float _133 = _94.y - _67;
  float _134 = _133 + _128;
  float _135 = _94.z - _68;
  float _136 = _135 + _129;
  float _137 = _132 * _130;
  float _138 = _134 * _130;
  float _139 = _136 * _130;
  float _140 = _137 + _66;
  float _141 = _138 + _67;
  float _142 = _139 + _68;
  float4 _143 = s12_bloom.Sample(s12_bloomSampler, float2(_57, _58));
  float4 _147 = s8.Sample(s8Sampler, float2(_59, _60));
  float _154 = (PostProcess.Settings[4].w) * _147.x;
  float _155 = (PostProcess.Settings[4].w) * _147.y;
  float _156 = (PostProcess.Settings[4].w) * _147.z;
  float _157 = _154 + (PostProcess.Settings[4].z);
  float _158 = _155 + (PostProcess.Settings[4].z);
  float _159 = _156 + (PostProcess.Settings[4].z);
  float _160 = saturate(_157);
  float _161 = saturate(_158);
  float _162 = saturate(_159);
  float _163 = _143.x - _140;
  float _164 = _143.y - _141;
  float _165 = _143.z - _142;
  float _166 = _160 * _163;
  float _167 = _161 * _164;
  float _168 = _162 * _165;
  float _169 = _166 + _140;
  float _170 = _167 + _141;
  float _171 = _168 + _142;
  bool _174 = ((User.c[6].y) > 0.0f);
  float _307;
  float _339;
  float _340;
  float _341;
  float _614;
  float _670;
  float _726;
  float _729;
  float _730;
  float _731;
  float _742;
  float _874;
  float _875;
  float _876;
  float _922;
  float _923;
  float _924;
  float _962;
  float _976;
  float _990;
  float _991;
  float _992;
  [branch]
  if (_174) {
    float4 _176 = s4.Sample(s4Sampler, float2(TEXCOORD.x, TEXCOORD.y));
    float4 _181 = s5.Sample(s5Sampler, float2(TEXCOORD.x, TEXCOORD.y));
    float _185 = (PostProcess.Settings[6].x) * _181.x;
    float _189 = _185 * (PostProcess.Settings[7].x);
    float _190 = _185 * (PostProcess.Settings[7].y);
    float _191 = _189 + TEXCOORD.x;
    float _192 = _190 + TEXCOORD.y;
    float4 _193 = s4.Sample(s4Sampler, float2(_191, _192));
    float4 _195 = s5.Sample(s5Sampler, float2(_191, _192));
    float _197 = (PostProcess.Settings[6].x) * _195.x;
    float _198 = abs(_197);
    float _200 = _198 / (PostProcess.Settings[7].w);
    float _201 = _193.z - _176.z;
    float _202 = _200 * _201;
    float _203 = _176.x - _169;
    float _204 = _176.y - _170;
    float _205 = _176.z - _171;
    float _206 = _205 + _202;
    float _207 = _203 * _176.w;
    float _208 = _204 * _176.w;
    float _209 = _206 * _176.w;
    _339 = _207;
    _340 = _208;
    _341 = _209;
  } else {
    bool _212 = ((User.c[6].x) > 0.0f);
    [branch]
    if (_212) {
      float4 _214 = s7.Sample(s7Sampler, float2(TEXCOORD.x, TEXCOORD.y));
      float _216 = abs(_214.x);
      _307 = _216;
    } else {
      float4 _218 = s2.SampleLevel(s2Sampler, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
      float _220 = TEXCOORD.x * 2.0f;
      float _221 = TEXCOORD.y * 2.0f;
      float _222 = _220 + -1.0f;
      float _223 = _221 + -1.0f;
      uint _224 = _39 << 5;
      uint _225 = _224 + 112u;
      uint _228 = _224 + 113u;
      uint _231 = _224 + 114u;
      uint _234 = _224 + 115u;
      float _249 = (Global.c[_225].x) * _222;
      float _250 = mad(_223, (Global.c[_225].y), _249);
      float _251 = mad(_218.x, (Global.c[_225].z), _250);
      float _252 = _251 + (Global.c[_225].w);
      float _253 = (Global.c[_228].x) * _222;
      float _254 = mad(_223, (Global.c[_228].y), _253);
      float _255 = mad(_218.x, (Global.c[_228].z), _254);
      float _256 = _255 + (Global.c[_228].w);
      float _257 = (Global.c[_231].x) * _222;
      float _258 = mad(_223, (Global.c[_231].y), _257);
      float _259 = mad(_218.x, (Global.c[_231].z), _258);
      float _260 = _259 + (Global.c[_231].w);
      float _261 = (Global.c[_234].x) * _222;
      float _262 = mad(_223, (Global.c[_234].y), _261);
      float _263 = mad(_218.x, (Global.c[_234].z), _262);
      float _264 = _263 + (Global.c[_234].w);
      float _265 = _252 / _264;
      float _266 = _256 / _264;
      float _267 = _260 / _264;
      float _268 = _265 * _265;
      float _269 = _266 * _266;
      float _270 = _269 + _268;
      float _271 = _267 * _267;
      float _272 = _270 + _271;
      float _273 = sqrt(_272);
      float4 _274 = s5.Sample(s5Sampler, float2(TEXCOORD.x, TEXCOORD.y));
      float _280 = (PostProcess.Settings[6].w) * (PostProcess.Settings[5].x);
      float _281 = _280 + (PostProcess.Settings[5].x);
      float _282 = (PostProcess.Settings[5].x) - _280;
      float _283 = max(_273, _282);
      float _284 = min(_283, _281);
      float _286 = _273 - _284;
      float _287 = (PostProcess.Settings[5].w) * _286;
      float _289 = _284 - (PostProcess.Settings[5].y);
      float _290 = _289 * _273;
      float _291 = _287 / _290;
      float _292 = min(_291, 0.0f);
      float _295 = (PostProcess.Settings[7].z) * _292;
      float _296 = _280 + 1.0f;
      float _297 = 1.0f / _296;
      float _298 = _295 * _297;
      float _299 = max(0.0f, _291);
      float _300 = _298 + _299;
      float _301 = min(_274.x, _300);
      float _302 = abs(_301);
      float _303 = abs(_300);
      float _304 = max(_302, _303);
      float _305 = saturate(_304);
      _307 = _305;
    }
    float _310 = (PostProcess.Settings[6].x) * _307;
    float4 _311 = s4.Sample(s4Sampler, float2(TEXCOORD.x, TEXCOORD.y));
    float _318 = (PostProcess.Settings[7].x) * _310;
    float _319 = (PostProcess.Settings[7].y) * _310;
    float _320 = _318 + TEXCOORD.x;
    float _321 = _319 + TEXCOORD.y;
    float4 _322 = s4.Sample(s4Sampler, float2(_320, _321));
    float4 _324 = s5.Sample(s5Sampler, float2(_320, _321));
    float _326 = abs(_324.x);
    float _327 = _322.z - _311.z;
    float _328 = _326 * _327;
    float _329 = _310 + -1.0f;
    float _330 = saturate(_329);
    float _331 = _311.x - _169;
    float _332 = _311.y - _170;
    float _333 = _311.z - _171;
    float _334 = _333 + _328;
    float _335 = _330 * _331;
    float _336 = _330 * _332;
    float _337 = _334 * _330;
    _339 = _335;
    _340 = _336;
    _341 = _337;
  }
  float _342 = _339 + _169;
  float _343 = _340 + _170;
  float _344 = _341 + _171;
  float4 _345 = s6.Load(int3(0, 0, 0));
  float _349 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _350 = _342 * 11190.6005859375f;
  float _351 = _350 * _345.x;
  float _352 = _351 * _349;
  float _353 = _343 * 11190.6005859375f;
  float _354 = _353 * _345.x;
  float _355 = _354 * _349;
  float _356 = _344 * 11190.6005859375f;
  float _357 = _356 * _345.x;
  float _358 = _357 * _349;
  float _359 = _352 + 1.0f;
  float _360 = _355 + 1.0f;
  float _361 = _358 + 1.0f;
  float _362 = log2(_359);
  float _363 = log2(_360);
  float _364 = log2(_361);
  float _365 = _362 * 0.07434873282909393f;
  float _366 = _363 * 0.07434873282909393f;
  float _367 = _364 * 0.07434873282909393f;
  float _370 = _365 * (PostProcess.OffsetWeight[0].x);
  float _371 = _366 * (PostProcess.OffsetWeight[0].x);
  float _372 = _367 * (PostProcess.OffsetWeight[0].x);
  float _374 = _370 + (PostProcess.OffsetWeight[0].y);
  float _375 = _371 + (PostProcess.OffsetWeight[0].y);
  float _376 = _372 + (PostProcess.OffsetWeight[0].y);
  float4 _377 = s3_3D.Sample(s3_3DSampler, float3(_374, _375, _376));
  float _383 = _377.x * 13.450128555297852f;
  float _384 = _377.y * 13.450128555297852f;
  float _385 = _377.z * 13.450128555297852f;
  float _386 = exp2(_383);
  float _387 = exp2(_384);
  float _388 = exp2(_385);
  float _389 = _386 + -1.0f;
  float _390 = _387 + -1.0f;
  float _391 = _388 + -1.0f;
  float _392 = _389 * 8.936070662457496e-05f;
  float _393 = _390 * 8.936070662457496e-05f;
  float _394 = _391 * 8.936070662457496e-05f;
  float _395 = 10000.0f / (PostProcess.Settings[10].w);
  float _396 = _392 * _395;
  float _397 = _393 * _395;
  float _398 = _394 * _395;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUT(
      float3(_352, _355, _358) / apt_lut_input_encode_scale,
      float3(_396, _397, _398));
  apt_lut_output = APTApplyPerceptualFilmGrain(apt_lut_output, SV_Position.xy);
  _396 = apt_lut_output.x;
  _397 = apt_lut_output.y;
  _398 = apt_lut_output.z;
  float _402 = (User.c[2].y) / (User.c[2].x);
  int _405 = asint((Global.c[1].w));
  uint _406 = _405 + 30u;
  int _407 = _406 & 63;
  float _408 = _57 * 8.0f;
  float _409 = _408 * _402;
  float _410 = _58 * 8.0f;
  float _411 = float((int)(_405));
  float4 _412 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_409, _410, _411), 0.0f);
  float _414 = _57 + 0.5f;
  float _415 = (User.c[2].x) * 0.5f;
  float _416 = _414 + _415;
  float _417 = _402 * 8.0f;
  float _418 = _417 * _416;
  float _419 = _58 + 0.5f;
  float _420 = (User.c[2].y) * 0.5f;
  float _421 = _419 + _420;
  float _422 = _421 * 8.0f;
  float _423 = float((int)(_407));
  float4 _424 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_418, _422, _423), 0.0f);
  float _426 = _424.x + _412.x;
  float _427 = _426 * 0.714285671710968f;
  float _428 = _427 + -0.2142857164144516f;
  float _429 = saturate(_428);
  float _430 = _429 * 2.0f;
  float _431 = 3.0f - _430;
  float _432 = _429 * _429;
  float _433 = _432 * _431;
  float _434 = _433 * 0.5f;
  float _435 = _433 * 0.4000000059604645f;
  float _436 = _433 * 0.05000000074505806f;
  float _437 = _434 + -0.5f;
  float _438 = _435 + -0.6000000238418579f;
  float _439 = _436 + -0.949999988079071f;
  float _440 = _437 * _93;
  float _441 = _438 * _93;
  float _442 = _439 * _93;
  float _443 = _440 + 1.0f;
  float _444 = _441 + 1.0f;
  float _445 = _442 + 1.0f;
  float _446 = _396 * _443;
  float _447 = _397 * _444;
  float _448 = _398 * _445;
  float4 _449 = s13.Sample(s13Sampler, float2(_57, _58));
  float _456 = _108 + 1.0f;
  float _457 = saturate(_456);
  float _458 = (User.c[2].x) * _457;
  float _459 = (User.c[2].y) * _457;
  float _460 = _458 + _57;
  float _461 = _459 + _58;
  float4 _462 = s13.Sample(s13Sampler, float2(_460, _461));
  float _466 = _462.x + _449.x;
  float _467 = _462.y + _449.y;
  float _468 = _462.z + _449.z;
  float _469 = _466 * 0.5f;
  float _470 = _467 * 0.5f;
  float _471 = _468 * 0.5f;
  float _472 = _93 * 0.6000000238418579f;
  float _473 = _472 * _91;
  float _474 = _93 * 0.7300000190734863f;
  float _475 = _474 * _91;
  float _476 = _93 * 0.8799999952316284f;
  float _477 = _476 * _91;
  float _478 = 1.0f - _473;
  float _479 = 1.0f - _475;
  float _480 = 1.0f - _477;
  float _481 = saturate(_478);
  float _482 = saturate(_479);
  float _483 = saturate(_480);
  float _484 = _446 * _481;
  float _485 = _447 * _482;
  float _486 = _448 * _483;
  float _487 = _469 + _484;
  float _488 = _485 + _470;
  float _489 = _486 + _471;
  bool _492 = ((User.c[3].x) > 0.0f) && !APTIsPsychoV();
  if (_492) {
    float _494 = log2(_487);
    float _495 = _494 * 3.0f;
    float _496 = exp2(_495);
    float _497 = _496 + -1.0f;
    float _498 = _487 + -1.0f;
    float _499 = _497 / _498;
    float _500 = _499 + -1.0f;
    bool _501 = !(_487 == 1.0f);
    float _502 = _500 / _499;
    float _503 = select(_501, _502, 0.6666666865348816f);
    float _504 = log2(_488);
    float _505 = _504 * 3.0f;
    float _506 = exp2(_505);
    float _507 = _506 + -1.0f;
    float _508 = _488 + -1.0f;
    float _509 = _507 / _508;
    float _510 = _509 + -1.0f;
    bool _511 = !(_488 == 1.0f);
    float _512 = _510 / _509;
    float _513 = select(_511, _512, 0.6666666865348816f);
    float _514 = log2(_489);
    float _515 = _514 * 3.0f;
    float _516 = exp2(_515);
    float _517 = _516 + -1.0f;
    float _518 = _489 + -1.0f;
    float _519 = _517 / _518;
    float _520 = _519 + -1.0f;
    bool _521 = !(_489 == 1.0f);
    float _522 = _520 / _519;
    float _523 = select(_521, _522, 0.6666666865348816f);
    bool _524 = (_503 <= 0.0031308000907301903f);
    bool _525 = (_513 <= 0.0031308000907301903f);
    bool _526 = (_523 <= 0.0031308000907301903f);
    float _527 = _503 * 12.920000076293945f;
    float _528 = _513 * 12.920000076293945f;
    float _529 = _523 * 12.920000076293945f;
    float _530 = log2(_503);
    float _531 = log2(_513);
    float _532 = log2(_523);
    float _533 = _530 * 0.4166666567325592f;
    float _534 = _531 * 0.4166666567325592f;
    float _535 = _532 * 0.4166666567325592f;
    float _536 = exp2(_533);
    float _537 = exp2(_534);
    float _538 = exp2(_535);
    float _539 = _536 * 1.0549999475479126f;
    float _540 = _537 * 1.0549999475479126f;
    float _541 = _538 * 1.0549999475479126f;
    float _542 = _539 + -0.054999999701976776f;
    float _543 = _540 + -0.054999999701976776f;
    float _544 = _541 + -0.054999999701976776f;
    float _545 = select(_524, _527, _542);
    float _546 = select(_525, _528, _543);
    float _547 = select(_526, _529, _544);
    int _549 = asint((User.c[3].y));
    int _550 = _549 & 1;
    bool _551 = (_550 == 0);
    if (!_551) {
      bool _560 = !(_545 <= (User.c[4].x));
      if (!_560) {
        float _562 = max(9.999999974752427e-07f, (User.c[4].x));
        float _563 = _545 / _562;
        float _564 = _563 * (User.c[4].y);
        float _565 = _563 * _563;
        float _566 = _565 * _563;
        float _567 = _566 - _563;
        float _568 = (User.c[3].z) * 0.1666666716337204f;
        float _569 = _562 * _562;
        float _570 = _569 * _568;
        float _571 = _570 * _567;
        float _572 = _571 + _564;
        _614 = _572;
      } else {
        bool _574 = !(_545 <= (User.c[4].z));
        if (!_574) {
          float _576 = (User.c[4].z) - (User.c[4].x);
          float _577 = max(9.999999974752427e-07f, _576);
          float _578 = _545 - (User.c[4].x);
          float _579 = _578 / _577;
          float _580 = 1.0f - _579;
          float _581 = _580 * (User.c[4].y);
          float _582 = _579 * (User.c[4].w);
          float _583 = _581 + _582;
          float _584 = _580 * _580;
          float _585 = _584 * _580;
          float _586 = _585 - _580;
          float _587 = _586 * (User.c[3].z);
          float _588 = _579 * _579;
          float _589 = _588 * _579;
          float _590 = _589 - _579;
          float _591 = _590 * (User.c[3].w);
          float _592 = _587 + _591;
          float _593 = _577 * _577;
          float _594 = _593 * 0.1666666716337204f;
          float _595 = _594 * _592;
          float _596 = _583 + _595;
          _614 = _596;
        } else {
          float _598 = 1.0f - (User.c[4].z);
          float _599 = _545 - (User.c[4].z);
          float _600 = max(9.999999974752427e-07f, _598);
          float _601 = _599 / _600;
          float _602 = 1.0f - _601;
          float _603 = _602 * (User.c[4].w);
          float _604 = _603 + _601;
          float _605 = _602 * _602;
          float _606 = _605 * _602;
          float _607 = _606 - _602;
          float _608 = _598 * _598;
          float _609 = _608 * 0.1666666716337204f;
          float _610 = _609 * (User.c[3].w);
          float _611 = _610 * _607;
          float _612 = _604 + _611;
          _614 = _612;
        }
      }
      float _615 = saturate(_614);
      bool _616 = !(_546 <= (User.c[4].x));
      if (!_616) {
        float _618 = max(9.999999974752427e-07f, (User.c[4].x));
        float _619 = _546 / _618;
        float _620 = _619 * (User.c[4].y);
        float _621 = _619 * _619;
        float _622 = _621 * _619;
        float _623 = _622 - _619;
        float _624 = (User.c[3].z) * 0.1666666716337204f;
        float _625 = _618 * _618;
        float _626 = _625 * _624;
        float _627 = _626 * _623;
        float _628 = _627 + _620;
        _670 = _628;
      } else {
        bool _630 = !(_546 <= (User.c[4].z));
        if (!_630) {
          float _632 = (User.c[4].z) - (User.c[4].x);
          float _633 = max(9.999999974752427e-07f, _632);
          float _634 = _546 - (User.c[4].x);
          float _635 = _634 / _633;
          float _636 = 1.0f - _635;
          float _637 = _636 * (User.c[4].y);
          float _638 = _635 * (User.c[4].w);
          float _639 = _637 + _638;
          float _640 = _636 * _636;
          float _641 = _640 * _636;
          float _642 = _641 - _636;
          float _643 = _642 * (User.c[3].z);
          float _644 = _635 * _635;
          float _645 = _644 * _635;
          float _646 = _645 - _635;
          float _647 = _646 * (User.c[3].w);
          float _648 = _643 + _647;
          float _649 = _633 * _633;
          float _650 = _649 * 0.1666666716337204f;
          float _651 = _650 * _648;
          float _652 = _639 + _651;
          _670 = _652;
        } else {
          float _654 = 1.0f - (User.c[4].z);
          float _655 = _546 - (User.c[4].z);
          float _656 = max(9.999999974752427e-07f, _654);
          float _657 = _655 / _656;
          float _658 = 1.0f - _657;
          float _659 = _658 * (User.c[4].w);
          float _660 = _659 + _657;
          float _661 = _658 * _658;
          float _662 = _661 * _658;
          float _663 = _662 - _658;
          float _664 = _654 * _654;
          float _665 = _664 * 0.1666666716337204f;
          float _666 = _665 * (User.c[3].w);
          float _667 = _666 * _663;
          float _668 = _660 + _667;
          _670 = _668;
        }
      }
      float _671 = saturate(_670);
      bool _672 = !(_547 <= (User.c[4].x));
      if (!_672) {
        float _674 = max(9.999999974752427e-07f, (User.c[4].x));
        float _675 = _547 / _674;
        float _676 = _675 * (User.c[4].y);
        float _677 = _675 * _675;
        float _678 = _677 * _675;
        float _679 = _678 - _675;
        float _680 = (User.c[3].z) * 0.1666666716337204f;
        float _681 = _674 * _674;
        float _682 = _681 * _680;
        float _683 = _682 * _679;
        float _684 = _683 + _676;
        _726 = _684;
      } else {
        bool _686 = !(_547 <= (User.c[4].z));
        if (!_686) {
          float _688 = (User.c[4].z) - (User.c[4].x);
          float _689 = max(9.999999974752427e-07f, _688);
          float _690 = _547 - (User.c[4].x);
          float _691 = _690 / _689;
          float _692 = 1.0f - _691;
          float _693 = _692 * (User.c[4].y);
          float _694 = _691 * (User.c[4].w);
          float _695 = _693 + _694;
          float _696 = _692 * _692;
          float _697 = _696 * _692;
          float _698 = _697 - _692;
          float _699 = _698 * (User.c[3].z);
          float _700 = _691 * _691;
          float _701 = _700 * _691;
          float _702 = _701 - _691;
          float _703 = _702 * (User.c[3].w);
          float _704 = _699 + _703;
          float _705 = _689 * _689;
          float _706 = _705 * 0.1666666716337204f;
          float _707 = _706 * _704;
          float _708 = _695 + _707;
          _726 = _708;
        } else {
          float _710 = 1.0f - (User.c[4].z);
          float _711 = _547 - (User.c[4].z);
          float _712 = max(9.999999974752427e-07f, _710);
          float _713 = _711 / _712;
          float _714 = 1.0f - _713;
          float _715 = _714 * (User.c[4].w);
          float _716 = _715 + _713;
          float _717 = _714 * _714;
          float _718 = _717 * _714;
          float _719 = _718 - _714;
          float _720 = _710 * _710;
          float _721 = _720 * 0.1666666716337204f;
          float _722 = _721 * (User.c[3].w);
          float _723 = _722 * _719;
          float _724 = _716 + _723;
          _726 = _724;
        }
      }
      float _727 = saturate(_726);
      _729 = _615;
      _730 = _671;
      _731 = _727;
    } else {
      _729 = _545;
      _730 = _546;
      _731 = _547;
    }
    int _732 = _549 & 2;
    bool _733 = (_732 == 0);
    if (!_733) {
      float _735 = sqrt(_729);
      float _736 = sqrt(_730);
      float _737 = sqrt(_731);
      float _738 = dot(float3(_735, _736, _737), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _739 = 1.0f - _738;
      float _740 = saturate(_739);
      _742 = _740;
    } else {
      _742 = 1.0f;
    }
    int _743 = _549 & 8;
    bool _744 = (_743 == 0);
    if (!_744) {
      bool _746 = (_742 <= 0.0031308000907301903f);
      float _747 = _742 * 12.920000076293945f;
      float _748 = log2(_742);
      float _749 = _748 * 0.4166666567325592f;
      float _750 = exp2(_749);
      float _751 = _750 * 1.0549999475479126f;
      float _752 = _751 + -0.054999999701976776f;
      float _753 = select(_746, _747, _752);
      _990 = _753;
      _991 = _753;
      _992 = _753;
    } else {
      int _755 = _549 & 4;
      bool _756 = (_755 == 0);
      if (!_756) {
        int _758 = _549 & 16;
        bool _759 = (_758 == 0);
        if (!_759) {
          float _763 = (User.c[5].x) * 0.5f;
          float _764 = _763 + 0.5f;
          bool _765 = (_764 < 0.5f);
          float _766 = (User.c[5].x) * 5.0f;
          float _767 = select(_765, (User.c[5].x), _766);
          bool _768 = (_730 < _731);
          float _769 = select(_768, _731, _730);
          float _770 = select(_768, _730, _731);
          bool _771 = (_729 < _769);
          float _772 = select(_771, _769, _729);
          float _773 = select(_771, _729, _769);
          float _774 = min(_773, _770);
          float _775 = _772 - _774;
          float _776 = _772 + 1.000000013351432e-10f;
          float _777 = _775 / _776;
          float _779 = _777 - (User.c[5].y);
          float _780 = saturate(_779);
          float _781 = max(_780, 9.999999974752427e-07f);
          float _782 = log2(_781);
          float _783 = _782 * _767;
          float _784 = exp2(_783);
          float _785 = 2.0f - _784;
          float _787 = 1.0f - (User.c[5].z);
          float _788 = saturate(_787);
          float _789 = max(_788, _785);
          float _790 = dot(float3(_729, _730, _731), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _791 = _729 - _790;
          float _792 = _730 - _790;
          float _793 = _731 - _790;
          float _794 = _791 * _789;
          float _795 = _792 * _789;
          float _796 = _793 * _789;
          float _797 = _790 - _729;
          float _798 = _797 + _794;
          float _799 = _790 - _730;
          float _800 = _799 + _795;
          float _801 = _790 - _731;
          float _802 = _801 + _796;
          float _803 = _798 * _742;
          float _804 = _800 * _742;
          float _805 = _802 * _742;
          float _806 = _803 + _729;
          float _807 = _804 + _730;
          float _808 = _805 + _731;
          _922 = _806;
          _923 = _807;
          _924 = _808;
        } else {
          bool _810 = (_742 == 0.0f);
          if (!_810) {
            float _814 = abs(User.c[5].x);
            float _815 = saturate(_814);
            uint2 _816; s15.GetDimensions(_816.x, _816.y);
            float _819 = float((uint)_816.y);
            int _820 = _549 & 32;
            bool _821 = (_820 == 0);
            float _822 = _819 + -1.0f;
            if (!_821) {
              float _824 = 1.0f / _822;
              uint _825 = uint(SV_Position.x);
              uint _826 = uint(SV_Position.y);
              int _827 = _825 & 63;
              int _828 = _826 & 63;
              float4 _829 = sBlueNoiseR8G8.Load(int4(_827, _828, 0, 0));
              float _832 = _829.x + -0.5f;
              float _833 = _729 * 13.999999046325684f;
              float _834 = _730 * 13.999999046325684f;
              float _835 = _731 * 13.999999046325684f;
              float _836 = saturate(_833);
              float _837 = saturate(_834);
              float _838 = saturate(_835);
              float _839 = _729 + -0.9285714030265808f;
              float _840 = _730 + -0.9285714030265808f;
              float _841 = _731 + -0.9285714030265808f;
              float _842 = _839 * 13.999999046325684f;
              float _843 = _840 * 13.999999046325684f;
              float _844 = _841 * 13.999999046325684f;
              float _845 = saturate(_842);
              float _846 = saturate(_843);
              float _847 = saturate(_844);
              float _848 = 1.0f - _845;
              float _849 = 1.0f - _846;
              float _850 = 1.0f - _847;
              float _851 = min(_836, _848);
              float _852 = min(_837, _849);
              float _853 = min(_838, _850);
              float _854 = _829.y + -0.5f;
              float _855 = _851 * _854;
              float _856 = _852 * _854;
              float _857 = _853 * _854;
              float _858 = _855 + _832;
              float _859 = _856 + _832;
              float _860 = _857 + _832;
              float _861 = _858 * _824;
              float _862 = _859 * _824;
              float _863 = _860 * _824;
              float _864 = _861 + _729;
              float _865 = _862 + _730;
              float _866 = _863 + _731;
              float _867 = saturate(_864);
              float _868 = saturate(_865);
              float _869 = saturate(_866);
              float _870 = saturate(_867);
              float _871 = saturate(_868);
              float _872 = saturate(_869);
              _874 = _870;
              _875 = _871;
              _876 = _872;
            } else {
              _874 = _729;
              _875 = _730;
              _876 = _731;
            }
            float _877 = float((uint)_816.x);
            float _878 = _822 / _877;
            float _879 = _878 * _874;
            float _880 = 0.5f / _877;
            float _881 = _879 + _880;
            float _882 = _822 / _819;
            float _883 = _882 * _875;
            float _884 = 0.5f / _819;
            float _885 = _883 + _884;
            float _886 = _876 * _822;
            float _887 = floor(_886);
            float _888 = frac(_886);
            float _889 = _887 / _819;
            float _890 = _889 + _881;
            float _891 = _887 + 1.0f;
            float _892 = _891 / _819;
            float _893 = _892 + _881;
            float4 _894 = s15.Sample(s15Sampler, float2(_890, _885));
            float4 _898 = s15.Sample(s15Sampler, float2(_893, _885));
            float _902 = _898.x - _894.x;
            float _903 = _898.y - _894.y;
            float _904 = _898.z - _894.z;
            float _905 = _902 * _888;
            float _906 = _903 * _888;
            float _907 = _904 * _888;
            float _908 = _815 * _742;
            float _909 = _894.x - _729;
            float _910 = _909 + _905;
            float _911 = _894.y - _730;
            float _912 = _911 + _906;
            float _913 = _894.z - _731;
            float _914 = _913 + _907;
            float _915 = _910 * _908;
            float _916 = _912 * _908;
            float _917 = _914 * _908;
            float _918 = _915 + _729;
            float _919 = _916 + _730;
            float _920 = _917 + _731;
            _922 = _918;
            _923 = _919;
            _924 = _920;
          } else {
            _922 = _729;
            _923 = _730;
            _924 = _731;
          }
        }
      } else {
        _922 = _729;
        _923 = _730;
        _924 = _731;
      }
      bool _925 = (_922 <= 0.040449999272823334f);
      bool _926 = (_923 <= 0.040449999272823334f);
      bool _927 = (_924 <= 0.040449999272823334f);
      float _928 = _922 * 0.07739938050508499f;
      float _929 = _923 * 0.07739938050508499f;
      float _930 = _924 * 0.07739938050508499f;
      float _931 = _922 + 0.054999999701976776f;
      float _932 = _923 + 0.054999999701976776f;
      float _933 = _924 + 0.054999999701976776f;
      float _934 = _931 * 0.9478673338890076f;
      float _935 = _932 * 0.9478673338890076f;
      float _936 = _933 * 0.9478673338890076f;
      float _937 = log2(_934);
      float _938 = log2(_935);
      float _939 = log2(_936);
      float _940 = _937 * 2.4000000953674316f;
      float _941 = _938 * 2.4000000953674316f;
      float _942 = _939 * 2.4000000953674316f;
      float _943 = exp2(_940);
      float _944 = exp2(_941);
      float _945 = exp2(_942);
      float _946 = select(_925, _928, _943);
      float _947 = select(_926, _929, _944);
      float _948 = select(_927, _930, _945);
      bool _949 = (_946 == 1.0f);
      if (!_949) {
        float _951 = _946 * _946;
        float _952 = _951 * 3.0f;
        float _953 = _946 * 2.0f;
        float _954 = _953 + 1.0f;
        float _955 = _954 - _952;
        float _956 = sqrt(_955);
        float _957 = _946 + -1.0f;
        float _958 = _957 * 2.0f;
        float _959 = _956 / _958;
        float _960 = -0.5f - _959;
        _962 = _960;
      } else {
        _962 = 1e+06f;
      }
      bool _963 = (_947 == 1.0f);
      if (!_963) {
        float _965 = _947 * _947;
        float _966 = _965 * 3.0f;
        float _967 = _947 * 2.0f;
        float _968 = _967 + 1.0f;
        float _969 = _968 - _966;
        float _970 = sqrt(_969);
        float _971 = _947 + -1.0f;
        float _972 = _971 * 2.0f;
        float _973 = _970 / _972;
        float _974 = -0.5f - _973;
        _976 = _974;
      } else {
        _976 = 1e+06f;
      }
      bool _977 = (_948 == 1.0f);
      if (!_977) {
        float _979 = _948 * _948;
        float _980 = _979 * 3.0f;
        float _981 = _948 * 2.0f;
        float _982 = _981 + 1.0f;
        float _983 = _982 - _980;
        float _984 = sqrt(_983);
        float _985 = _948 + -1.0f;
        float _986 = _985 * 2.0f;
        float _987 = _984 / _986;
        float _988 = -0.5f - _987;
        _990 = _962;
        _991 = _976;
        _992 = _988;
      } else {
        _990 = _962;
        _991 = _976;
        _992 = 1e+06f;
      }
    }
  } else {
    _990 = _487;
    _991 = _488;
    _992 = _489;
  }
  float _993 = log2(_990);
  float _994 = _993 * 3.0f;
  float _995 = exp2(_994);
  float _996 = _995 + -1.0f;
  float _997 = _990 + -1.0f;
  float _998 = _996 / _997;
  float _999 = _998 + -1.0f;
  bool _1000 = !(_990 == 1.0f);
  float _1001 = _999 / _998;
  float _1002 = select(_1000, _1001, 0.6666666865348816f);
  float _1003 = log2(_991);
  float _1004 = _1003 * 3.0f;
  float _1005 = exp2(_1004);
  float _1006 = _1005 + -1.0f;
  float _1007 = _991 + -1.0f;
  float _1008 = _1006 / _1007;
  float _1009 = _1008 + -1.0f;
  bool _1010 = !(_991 == 1.0f);
  float _1011 = _1009 / _1008;
  float _1012 = select(_1010, _1011, 0.6666666865348816f);
  float _1013 = log2(_992);
  float _1014 = _1013 * 3.0f;
  float _1015 = exp2(_1014);
  float _1016 = _1015 + -1.0f;
  float _1017 = _992 + -1.0f;
  float _1018 = _1016 / _1017;
  float _1019 = _1018 + -1.0f;
  bool _1020 = !(_992 == 1.0f);
  float _1021 = _1019 / _1018;
  float _1022 = select(_1020, _1021, 0.6666666865348816f);
  float _1023 = saturate(_1002);
  float _1024 = saturate(_1012);
  float _1025 = saturate(_1022);
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_487, _488, _489),
      float3(_1023, _1024, _1025),
      false);
  _1023 = apt_tonemapped.x;
  _1024 = apt_tonemapped.y;
  _1025 = apt_tonemapped.z;
  bool _1026 = (_1023 <= 0.0031308000907301903f);
  bool _1027 = (_1024 <= 0.0031308000907301903f);
  bool _1028 = (_1025 <= 0.0031308000907301903f);
  float _1029 = _1023 * 12.920000076293945f;
  float _1030 = _1024 * 12.920000076293945f;
  float _1031 = _1025 * 12.920000076293945f;
  float _1032 = log2(_1023);
  float _1033 = log2(_1024);
  float _1034 = log2(_1025);
  float _1035 = _1032 * 0.4166666567325592f;
  float _1036 = _1033 * 0.4166666567325592f;
  float _1037 = _1034 * 0.4166666567325592f;
  float _1038 = exp2(_1035);
  float _1039 = exp2(_1036);
  float _1040 = exp2(_1037);
  float _1041 = _1038 * 1.0549999475479126f;
  float _1042 = _1039 * 1.0549999475479126f;
  float _1043 = _1040 * 1.0549999475479126f;
  float _1044 = _1041 + -0.054999999701976776f;
  float _1045 = _1042 + -0.054999999701976776f;
  float _1046 = _1043 + -0.054999999701976776f;
  float _1047 = select(_1026, _1029, _1044);
  float _1048 = select(_1027, _1030, _1045);
  float _1049 = select(_1028, _1031, _1046);
  int _1052 = asint((Global.c[1].w));
  uint _1053 = uint(SV_Position.x);
  uint _1054 = uint(SV_Position.y);
  int _1055 = _1053 & 63;
  int _1056 = _1054 & 63;
  float4 _1057 = sBlueNoiseR8.Load(int4(_1055, _1056, _1052, 0));
  float _1059 = _1057.x * 0.003921568859368563f;
  float _1060 = _1047 + 0.003921568859368563f;
  float _1061 = _1060 - _1059;
  float _1062 = _1059 + _1048;
  float _1063 = _1059 + _1049;
  SV_Target.x = _1061;
  SV_Target.y = _1062;
  SV_Target.z = _1063;
  SV_Target.w = _61.w;
  if (APTIsPsychoV()) {
    SV_Target.rgb = APTRenderIntermediatePassDithered(
        apt_tonemapped,
        SV_Position.xy);
  }
  return SV_Target;
}
