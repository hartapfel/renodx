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

#include "../common.hlsli"

cbuffer CBufferGlobalConstant_Z : register(b1) {
  StructGlobalConstant_Z Global : packoffset(c000.x);
  float4 CBufferGlobalConstant_Z_raw[174] : packoffset(c0);
};

cbuffer CBufferUserConstant_Z : register(b0) {
  StructUserConstant_Z User : packoffset(c000.x);
};

cbuffer CBufferPostProcessConstant_Z : register(b2) {
  StructPostProcessConstant_Z PostProcess : packoffset(c000.x);
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
  float4 SV_Target = 0;
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
  float _648;
  float _704;
  float _760;
  float _763;
  float _764;
  float _765;
  float _776;
  float _908;
  float _909;
  float _910;
  float _956;
  float _957;
  float _958;
  float _996;
  float _1010;
  float _1024;
  float _1025;
  float _1026;
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
      uint _224 = _39 << 5u;
      uint _225 = _224 + 112u;
      uint _228 = _224 + 113u;
      uint _231 = _224 + 114u;
      uint _234 = _224 + 115u;
      float _249 = (CBufferGlobalConstant_Z_raw[_225].x) * _222;
      float _250 = mad(_223, (CBufferGlobalConstant_Z_raw[_225].y), _249);
      float _251 = mad(_218.x, (CBufferGlobalConstant_Z_raw[_225].z), _250);
      float _252 = _251 + (CBufferGlobalConstant_Z_raw[_225].w);
      float _253 = (CBufferGlobalConstant_Z_raw[_228].x) * _222;
      float _254 = mad(_223, (CBufferGlobalConstant_Z_raw[_228].y), _253);
      float _255 = mad(_218.x, (CBufferGlobalConstant_Z_raw[_228].z), _254);
      float _256 = _255 + (CBufferGlobalConstant_Z_raw[_228].w);
      float _257 = (CBufferGlobalConstant_Z_raw[_231].x) * _222;
      float _258 = mad(_223, (CBufferGlobalConstant_Z_raw[_231].y), _257);
      float _259 = mad(_218.x, (CBufferGlobalConstant_Z_raw[_231].z), _258);
      float _260 = _259 + (CBufferGlobalConstant_Z_raw[_231].w);
      float _261 = (CBufferGlobalConstant_Z_raw[_234].x) * _222;
      float _262 = mad(_223, (CBufferGlobalConstant_Z_raw[_234].y), _261);
      float _263 = mad(_218.x, (CBufferGlobalConstant_Z_raw[_234].z), _262);
      float _264 = _263 + (CBufferGlobalConstant_Z_raw[_234].w);
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
  float _347 = _345.x * _342;
  float _348 = _345.x * _343;
  float _349 = _345.x * _344;
  float _354 = _58 * 2.0f;
  float _355 = _354 + -1.0f;
  float _358 = (PostProcess.Settings[13].w) * _355;
  float _359 = _86 * _86;
  float _360 = _358 * _358;
  float _361 = _360 + _359;
  float _362 = sqrt(_361);
  float _364 = (PostProcess.Settings[13].x) * _362;
  float _366 = _364 + (PostProcess.Settings[13].y);
  float _367 = saturate(_366);
  float _369 = log2(_367);
  float _370 = _369 * (PostProcess.Settings[13].z);
  float _371 = exp2(_370);
  float _372 = _347 * (PostProcess.Settings[12].x);
  float _373 = _348 * (PostProcess.Settings[12].y);
  float _374 = _349 * (PostProcess.Settings[12].z);
  float _375 = _372 - _347;
  float _376 = _373 - _348;
  float _377 = _374 - _349;
  float _378 = _371 * _375;
  float _379 = _371 * _376;
  float _380 = _371 * _377;
  float _381 = _378 + _347;
  float _382 = _379 + _348;
  float _383 = _380 + _349;
  float _386 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _387 = _381 * 11190.6005859375f;
  float _388 = _387 * _386;
  float _389 = _382 * 11190.6005859375f;
  float _390 = _389 * _386;
  float _391 = _383 * 11190.6005859375f;
  float _392 = _391 * _386;
  float _393 = _388 + 1.0f;
  float _394 = _390 + 1.0f;
  float _395 = _392 + 1.0f;
  float _396 = log2(_393);
  float _397 = log2(_394);
  float _398 = log2(_395);
  float _399 = _396 * 0.07434873282909393f;
  float _400 = _397 * 0.07434873282909393f;
  float _401 = _398 * 0.07434873282909393f;
  float _404 = _399 * (PostProcess.OffsetWeight[0].x);
  float _405 = _400 * (PostProcess.OffsetWeight[0].x);
  float _406 = _401 * (PostProcess.OffsetWeight[0].x);
  float _408 = _404 + (PostProcess.OffsetWeight[0].y);
  float _409 = _405 + (PostProcess.OffsetWeight[0].y);
  float _410 = _406 + (PostProcess.OffsetWeight[0].y);
  float4 _411 = s3_3D.Sample(s3_3DSampler, float3(_408, _409, _410));
  float _417 = _411.x * 13.450128555297852f;
  float _418 = _411.y * 13.450128555297852f;
  float _419 = _411.z * 13.450128555297852f;
  float _420 = exp2(_417);
  float _421 = exp2(_418);
  float _422 = exp2(_419);
  float _423 = _420 + -1.0f;
  float _424 = _421 + -1.0f;
  float _425 = _422 + -1.0f;
  float _426 = _423 * 8.936070662457496e-05f;
  float _427 = _424 * 8.936070662457496e-05f;
  float _428 = _425 * 8.936070662457496e-05f;
  float _429 = 10000.0f / (PostProcess.Settings[10].w);
  float _430 = _426 * _429;
  float _431 = _427 * _429;
  float _432 = _428 * _429;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUTScaling(
      float3(_388, _390, _392) / apt_lut_input_encode_scale,
      float3(_430, _431, _432),
      s3_3D,
      s3_3DSampler,
      apt_lut_input_encode_scale,
      PostProcess.OffsetWeight[0].x,
      PostProcess.OffsetWeight[0].y,
      8.936070662457496e-05f * (10000.0f / PostProcess.Settings[10].w));
  _430 = apt_lut_output.x;
  _431 = apt_lut_output.y;
  _432 = apt_lut_output.z;
  float _436 = (User.c[2].y) / (User.c[2].x);
  int _439 = asint((Global.c[1].w));
  uint _440 = _439 + 30u;
  int _441 = _440 & 63;
  float _442 = _57 * 8.0f;
  float _443 = _442 * _436;
  float _444 = _58 * 8.0f;
  float _445 = float((int)(_439));
  float4 _446 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_443, _444, _445), 0.0f);
  float _448 = _57 + 0.5f;
  float _449 = (User.c[2].x) * 0.5f;
  float _450 = _448 + _449;
  float _451 = _436 * 8.0f;
  float _452 = _451 * _450;
  float _453 = _58 + 0.5f;
  float _454 = (User.c[2].y) * 0.5f;
  float _455 = _453 + _454;
  float _456 = _455 * 8.0f;
  float _457 = float((int)(_441));
  float4 _458 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_452, _456, _457), 0.0f);
  float _460 = _458.x + _446.x;
  float _461 = _460 * 0.714285671710968f;
  float _462 = _461 + -0.2142857164144516f;
  float _463 = saturate(_462);
  float _464 = _463 * 2.0f;
  float _465 = 3.0f - _464;
  float _466 = _463 * _463;
  float _467 = _466 * _465;
  float _468 = _467 * 0.5f;
  float _469 = _467 * 0.4000000059604645f;
  float _470 = _467 * 0.05000000074505806f;
  float _471 = _468 + -0.5f;
  float _472 = _469 + -0.6000000238418579f;
  float _473 = _470 + -0.949999988079071f;
  float _474 = _471 * _93;
  float _475 = _472 * _93;
  float _476 = _473 * _93;
  float _477 = _474 + 1.0f;
  float _478 = _475 + 1.0f;
  float _479 = _476 + 1.0f;
  float _480 = _430 * _477;
  float _481 = _431 * _478;
  float _482 = _432 * _479;
  float4 _483 = s13.Sample(s13Sampler, float2(_57, _58));
  float _490 = _108 + 1.0f;
  float _491 = saturate(_490);
  float _492 = (User.c[2].x) * _491;
  float _493 = (User.c[2].y) * _491;
  float _494 = _492 + _57;
  float _495 = _493 + _58;
  float4 _496 = s13.Sample(s13Sampler, float2(_494, _495));
  float _500 = _496.x + _483.x;
  float _501 = _496.y + _483.y;
  float _502 = _496.z + _483.z;
  float _503 = _500 * 0.5f;
  float _504 = _501 * 0.5f;
  float _505 = _502 * 0.5f;
  float _506 = _93 * 0.6000000238418579f;
  float _507 = _506 * _91;
  float _508 = _93 * 0.7300000190734863f;
  float _509 = _508 * _91;
  float _510 = _93 * 0.8799999952316284f;
  float _511 = _510 * _91;
  float _512 = 1.0f - _507;
  float _513 = 1.0f - _509;
  float _514 = 1.0f - _511;
  float _515 = saturate(_512);
  float _516 = saturate(_513);
  float _517 = saturate(_514);
  float _518 = _480 * _515;
  float _519 = _481 * _516;
  float _520 = _482 * _517;
  float _521 = _503 + _518;
  float _522 = _519 + _504;
  float _523 = _520 + _505;
  bool _526 = ((User.c[3].x) > 0.0f);
  if (_526) {
    float _528 = log2(_521);
    float _529 = _528 * 3.0f;
    float _530 = exp2(_529);
    float _531 = _530 + -1.0f;
    float _532 = _521 + -1.0f;
    float _533 = _531 / _532;
    float _534 = _533 + -1.0f;
    bool _535 = !(_521 == 1.0f);
    float _536 = _534 / _533;
    float _537 = select(_535, _536, 0.6666666865348816f);
    float _538 = log2(_522);
    float _539 = _538 * 3.0f;
    float _540 = exp2(_539);
    float _541 = _540 + -1.0f;
    float _542 = _522 + -1.0f;
    float _543 = _541 / _542;
    float _544 = _543 + -1.0f;
    bool _545 = !(_522 == 1.0f);
    float _546 = _544 / _543;
    float _547 = select(_545, _546, 0.6666666865348816f);
    float _548 = log2(_523);
    float _549 = _548 * 3.0f;
    float _550 = exp2(_549);
    float _551 = _550 + -1.0f;
    float _552 = _523 + -1.0f;
    float _553 = _551 / _552;
    float _554 = _553 + -1.0f;
    bool _555 = !(_523 == 1.0f);
    float _556 = _554 / _553;
    float _557 = select(_555, _556, 0.6666666865348816f);
    bool _558 = (_537 <= 0.0031308000907301903f);
    bool _559 = (_547 <= 0.0031308000907301903f);
    bool _560 = (_557 <= 0.0031308000907301903f);
    float _561 = _537 * 12.920000076293945f;
    float _562 = _547 * 12.920000076293945f;
    float _563 = _557 * 12.920000076293945f;
    float _564 = log2(_537);
    float _565 = log2(_547);
    float _566 = log2(_557);
    float _567 = _564 * 0.4166666567325592f;
    float _568 = _565 * 0.4166666567325592f;
    float _569 = _566 * 0.4166666567325592f;
    float _570 = exp2(_567);
    float _571 = exp2(_568);
    float _572 = exp2(_569);
    float _573 = _570 * 1.0549999475479126f;
    float _574 = _571 * 1.0549999475479126f;
    float _575 = _572 * 1.0549999475479126f;
    float _576 = _573 + -0.054999999701976776f;
    float _577 = _574 + -0.054999999701976776f;
    float _578 = _575 + -0.054999999701976776f;
    float _579 = select(_558, _561, _576);
    float _580 = select(_559, _562, _577);
    float _581 = select(_560, _563, _578);
    int _583 = asint((User.c[3].y));
    int _584 = _583 & 1;
    bool _585 = (_584 == 0);
    if (!_585) {
      bool _594 = !(_579 <= (User.c[4].x));
      if (!_594) {
        float _596 = max(9.999999974752427e-07f, (User.c[4].x));
        float _597 = _579 / _596;
        float _598 = _597 * (User.c[4].y);
        float _599 = _597 * _597;
        float _600 = _599 * _597;
        float _601 = _600 - _597;
        float _602 = (User.c[3].z) * 0.1666666716337204f;
        float _603 = _596 * _596;
        float _604 = _603 * _602;
        float _605 = _604 * _601;
        float _606 = _605 + _598;
        _648 = _606;
      } else {
        bool _608 = !(_579 <= (User.c[4].z));
        if (!_608) {
          float _610 = (User.c[4].z) - (User.c[4].x);
          float _611 = max(9.999999974752427e-07f, _610);
          float _612 = _579 - (User.c[4].x);
          float _613 = _612 / _611;
          float _614 = 1.0f - _613;
          float _615 = _614 * (User.c[4].y);
          float _616 = _613 * (User.c[4].w);
          float _617 = _615 + _616;
          float _618 = _614 * _614;
          float _619 = _618 * _614;
          float _620 = _619 - _614;
          float _621 = _620 * (User.c[3].z);
          float _622 = _613 * _613;
          float _623 = _622 * _613;
          float _624 = _623 - _613;
          float _625 = _624 * (User.c[3].w);
          float _626 = _621 + _625;
          float _627 = _611 * _611;
          float _628 = _627 * 0.1666666716337204f;
          float _629 = _628 * _626;
          float _630 = _617 + _629;
          _648 = _630;
        } else {
          float _632 = 1.0f - (User.c[4].z);
          float _633 = _579 - (User.c[4].z);
          float _634 = max(9.999999974752427e-07f, _632);
          float _635 = _633 / _634;
          float _636 = 1.0f - _635;
          float _637 = _636 * (User.c[4].w);
          float _638 = _637 + _635;
          float _639 = _636 * _636;
          float _640 = _639 * _636;
          float _641 = _640 - _636;
          float _642 = _632 * _632;
          float _643 = _642 * 0.1666666716337204f;
          float _644 = _643 * (User.c[3].w);
          float _645 = _644 * _641;
          float _646 = _638 + _645;
          _648 = _646;
        }
      }
      float _649 = saturate(_648);
      bool _650 = !(_580 <= (User.c[4].x));
      if (!_650) {
        float _652 = max(9.999999974752427e-07f, (User.c[4].x));
        float _653 = _580 / _652;
        float _654 = _653 * (User.c[4].y);
        float _655 = _653 * _653;
        float _656 = _655 * _653;
        float _657 = _656 - _653;
        float _658 = (User.c[3].z) * 0.1666666716337204f;
        float _659 = _652 * _652;
        float _660 = _659 * _658;
        float _661 = _660 * _657;
        float _662 = _661 + _654;
        _704 = _662;
      } else {
        bool _664 = !(_580 <= (User.c[4].z));
        if (!_664) {
          float _666 = (User.c[4].z) - (User.c[4].x);
          float _667 = max(9.999999974752427e-07f, _666);
          float _668 = _580 - (User.c[4].x);
          float _669 = _668 / _667;
          float _670 = 1.0f - _669;
          float _671 = _670 * (User.c[4].y);
          float _672 = _669 * (User.c[4].w);
          float _673 = _671 + _672;
          float _674 = _670 * _670;
          float _675 = _674 * _670;
          float _676 = _675 - _670;
          float _677 = _676 * (User.c[3].z);
          float _678 = _669 * _669;
          float _679 = _678 * _669;
          float _680 = _679 - _669;
          float _681 = _680 * (User.c[3].w);
          float _682 = _677 + _681;
          float _683 = _667 * _667;
          float _684 = _683 * 0.1666666716337204f;
          float _685 = _684 * _682;
          float _686 = _673 + _685;
          _704 = _686;
        } else {
          float _688 = 1.0f - (User.c[4].z);
          float _689 = _580 - (User.c[4].z);
          float _690 = max(9.999999974752427e-07f, _688);
          float _691 = _689 / _690;
          float _692 = 1.0f - _691;
          float _693 = _692 * (User.c[4].w);
          float _694 = _693 + _691;
          float _695 = _692 * _692;
          float _696 = _695 * _692;
          float _697 = _696 - _692;
          float _698 = _688 * _688;
          float _699 = _698 * 0.1666666716337204f;
          float _700 = _699 * (User.c[3].w);
          float _701 = _700 * _697;
          float _702 = _694 + _701;
          _704 = _702;
        }
      }
      float _705 = saturate(_704);
      bool _706 = !(_581 <= (User.c[4].x));
      if (!_706) {
        float _708 = max(9.999999974752427e-07f, (User.c[4].x));
        float _709 = _581 / _708;
        float _710 = _709 * (User.c[4].y);
        float _711 = _709 * _709;
        float _712 = _711 * _709;
        float _713 = _712 - _709;
        float _714 = (User.c[3].z) * 0.1666666716337204f;
        float _715 = _708 * _708;
        float _716 = _715 * _714;
        float _717 = _716 * _713;
        float _718 = _717 + _710;
        _760 = _718;
      } else {
        bool _720 = !(_581 <= (User.c[4].z));
        if (!_720) {
          float _722 = (User.c[4].z) - (User.c[4].x);
          float _723 = max(9.999999974752427e-07f, _722);
          float _724 = _581 - (User.c[4].x);
          float _725 = _724 / _723;
          float _726 = 1.0f - _725;
          float _727 = _726 * (User.c[4].y);
          float _728 = _725 * (User.c[4].w);
          float _729 = _727 + _728;
          float _730 = _726 * _726;
          float _731 = _730 * _726;
          float _732 = _731 - _726;
          float _733 = _732 * (User.c[3].z);
          float _734 = _725 * _725;
          float _735 = _734 * _725;
          float _736 = _735 - _725;
          float _737 = _736 * (User.c[3].w);
          float _738 = _733 + _737;
          float _739 = _723 * _723;
          float _740 = _739 * 0.1666666716337204f;
          float _741 = _740 * _738;
          float _742 = _729 + _741;
          _760 = _742;
        } else {
          float _744 = 1.0f - (User.c[4].z);
          float _745 = _581 - (User.c[4].z);
          float _746 = max(9.999999974752427e-07f, _744);
          float _747 = _745 / _746;
          float _748 = 1.0f - _747;
          float _749 = _748 * (User.c[4].w);
          float _750 = _749 + _747;
          float _751 = _748 * _748;
          float _752 = _751 * _748;
          float _753 = _752 - _748;
          float _754 = _744 * _744;
          float _755 = _754 * 0.1666666716337204f;
          float _756 = _755 * (User.c[3].w);
          float _757 = _756 * _753;
          float _758 = _750 + _757;
          _760 = _758;
        }
      }
      float _761 = saturate(_760);
      _763 = _649;
      _764 = _705;
      _765 = _761;
    } else {
      _763 = _579;
      _764 = _580;
      _765 = _581;
    }
    int _766 = _583 & 2;
    bool _767 = (_766 == 0);
    if (!_767) {
      float _769 = sqrt(_763);
      float _770 = sqrt(_764);
      float _771 = sqrt(_765);
      float _772 = dot(float3(_769, _770, _771), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _773 = 1.0f - _772;
      float _774 = saturate(_773);
      _776 = _774;
    } else {
      _776 = 1.0f;
    }
    int _777 = _583 & 8;
    bool _778 = (_777 == 0);
    if (!_778) {
      bool _780 = (_776 <= 0.0031308000907301903f);
      float _781 = _776 * 12.920000076293945f;
      float _782 = log2(_776);
      float _783 = _782 * 0.4166666567325592f;
      float _784 = exp2(_783);
      float _785 = _784 * 1.0549999475479126f;
      float _786 = _785 + -0.054999999701976776f;
      float _787 = select(_780, _781, _786);
      _1024 = _787;
      _1025 = _787;
      _1026 = _787;
    } else {
      int _789 = _583 & 4;
      bool _790 = (_789 == 0);
      if (!_790) {
        int _792 = _583 & 16;
        bool _793 = (_792 == 0);
        if (!_793) {
          float _797 = (User.c[5].x) * 0.5f;
          float _798 = _797 + 0.5f;
          bool _799 = (_798 < 0.5f);
          float _800 = (User.c[5].x) * 5.0f;
          float _801 = select(_799, (User.c[5].x), _800);
          bool _802 = (_764 < _765);
          float _803 = select(_802, _765, _764);
          float _804 = select(_802, _764, _765);
          bool _805 = (_763 < _803);
          float _806 = select(_805, _803, _763);
          float _807 = select(_805, _763, _803);
          float _808 = min(_807, _804);
          float _809 = _806 - _808;
          float _810 = _806 + 1.000000013351432e-10f;
          float _811 = _809 / _810;
          float _813 = _811 - (User.c[5].y);
          float _814 = saturate(_813);
          float _815 = max(_814, 9.999999974752427e-07f);
          float _816 = log2(_815);
          float _817 = _816 * _801;
          float _818 = exp2(_817);
          float _819 = 2.0f - _818;
          float _821 = 1.0f - (User.c[5].z);
          float _822 = saturate(_821);
          float _823 = max(_822, _819);
          float _824 = dot(float3(_763, _764, _765), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _825 = _763 - _824;
          float _826 = _764 - _824;
          float _827 = _765 - _824;
          float _828 = _825 * _823;
          float _829 = _826 * _823;
          float _830 = _827 * _823;
          float _831 = _824 - _763;
          float _832 = _831 + _828;
          float _833 = _824 - _764;
          float _834 = _833 + _829;
          float _835 = _824 - _765;
          float _836 = _835 + _830;
          float _837 = _832 * _776;
          float _838 = _834 * _776;
          float _839 = _836 * _776;
          float _840 = _837 + _763;
          float _841 = _838 + _764;
          float _842 = _839 + _765;
          _956 = _840;
          _957 = _841;
          _958 = _842;
        } else {
          bool _844 = (_776 == 0.0f);
          if (!_844) {
            float _848 = abs(User.c[5].x);
            float _849 = saturate(_848);
            uint4 _850 = 0u; s15.GetDimensions(0u, _850.x, _850.y, _850.w);
            float _853 = float((uint)_850.y);
            int _854 = _583 & 32;
            bool _855 = (_854 == 0);
            float _856 = _853 + -1.0f;
            if (!_855) {
              float _858 = 1.0f / _856;
              uint _859 = uint(SV_Position.x);
              uint _860 = uint(SV_Position.y);
              int _861 = _859 & 63;
              int _862 = _860 & 63;
              float4 _863 = sBlueNoiseR8G8.Load(int4(_861, _862, 0, 0));
              float _866 = _863.x + -0.5f;
              float _867 = _763 * 13.999999046325684f;
              float _868 = _764 * 13.999999046325684f;
              float _869 = _765 * 13.999999046325684f;
              float _870 = saturate(_867);
              float _871 = saturate(_868);
              float _872 = saturate(_869);
              float _873 = _763 + -0.9285714030265808f;
              float _874 = _764 + -0.9285714030265808f;
              float _875 = _765 + -0.9285714030265808f;
              float _876 = _873 * 13.999999046325684f;
              float _877 = _874 * 13.999999046325684f;
              float _878 = _875 * 13.999999046325684f;
              float _879 = saturate(_876);
              float _880 = saturate(_877);
              float _881 = saturate(_878);
              float _882 = 1.0f - _879;
              float _883 = 1.0f - _880;
              float _884 = 1.0f - _881;
              float _885 = min(_870, _882);
              float _886 = min(_871, _883);
              float _887 = min(_872, _884);
              float _888 = _863.y + -0.5f;
              float _889 = _885 * _888;
              float _890 = _886 * _888;
              float _891 = _887 * _888;
              float _892 = _889 + _866;
              float _893 = _890 + _866;
              float _894 = _891 + _866;
              float _895 = _892 * _858;
              float _896 = _893 * _858;
              float _897 = _894 * _858;
              float _898 = _895 + _763;
              float _899 = _896 + _764;
              float _900 = _897 + _765;
              float _901 = saturate(_898);
              float _902 = saturate(_899);
              float _903 = saturate(_900);
              float _904 = saturate(_901);
              float _905 = saturate(_902);
              float _906 = saturate(_903);
              _908 = _904;
              _909 = _905;
              _910 = _906;
            } else {
              _908 = _763;
              _909 = _764;
              _910 = _765;
            }
            float _911 = float((uint)_850.x);
            float _912 = _856 / _911;
            float _913 = _912 * _908;
            float _914 = 0.5f / _911;
            float _915 = _913 + _914;
            float _916 = _856 / _853;
            float _917 = _916 * _909;
            float _918 = 0.5f / _853;
            float _919 = _917 + _918;
            float _920 = _910 * _856;
            float _921 = floor(_920);
            float _922 = frac(_920);
            float _923 = _921 / _853;
            float _924 = _923 + _915;
            float _925 = _921 + 1.0f;
            float _926 = _925 / _853;
            float _927 = _926 + _915;
            float4 _928 = s15.Sample(s15Sampler, float2(_924, _919));
            float4 _932 = s15.Sample(s15Sampler, float2(_927, _919));
            float _936 = _932.x - _928.x;
            float _937 = _932.y - _928.y;
            float _938 = _932.z - _928.z;
            float _939 = _936 * _922;
            float _940 = _937 * _922;
            float _941 = _938 * _922;
            float _942 = _849 * _776;
            float _943 = _928.x - _763;
            float _944 = _943 + _939;
            float _945 = _928.y - _764;
            float _946 = _945 + _940;
            float _947 = _928.z - _765;
            float _948 = _947 + _941;
            float _949 = _944 * _942;
            float _950 = _946 * _942;
            float _951 = _948 * _942;
            float _952 = _949 + _763;
            float _953 = _950 + _764;
            float _954 = _951 + _765;
            _956 = _952;
            _957 = _953;
            _958 = _954;
          } else {
            _956 = _763;
            _957 = _764;
            _958 = _765;
          }
        }
      } else {
        _956 = _763;
        _957 = _764;
        _958 = _765;
      }
      bool _959 = (_956 <= 0.040449999272823334f);
      bool _960 = (_957 <= 0.040449999272823334f);
      bool _961 = (_958 <= 0.040449999272823334f);
      float _962 = _956 * 0.07739938050508499f;
      float _963 = _957 * 0.07739938050508499f;
      float _964 = _958 * 0.07739938050508499f;
      float _965 = _956 + 0.054999999701976776f;
      float _966 = _957 + 0.054999999701976776f;
      float _967 = _958 + 0.054999999701976776f;
      float _968 = _965 * 0.9478673338890076f;
      float _969 = _966 * 0.9478673338890076f;
      float _970 = _967 * 0.9478673338890076f;
      float _971 = log2(_968);
      float _972 = log2(_969);
      float _973 = log2(_970);
      float _974 = _971 * 2.4000000953674316f;
      float _975 = _972 * 2.4000000953674316f;
      float _976 = _973 * 2.4000000953674316f;
      float _977 = exp2(_974);
      float _978 = exp2(_975);
      float _979 = exp2(_976);
      float _980 = select(_959, _962, _977);
      float _981 = select(_960, _963, _978);
      float _982 = select(_961, _964, _979);
      bool _983 = (_980 == 1.0f);
      if (!_983) {
        float _985 = _980 * _980;
        float _986 = _985 * 3.0f;
        float _987 = _980 * 2.0f;
        float _988 = _987 + 1.0f;
        float _989 = _988 - _986;
        float _990 = sqrt(_989);
        float _991 = _980 + -1.0f;
        float _992 = _991 * 2.0f;
        float _993 = _990 / _992;
        float _994 = -0.5f - _993;
        _996 = _994;
      } else {
        _996 = 1e+06f;
      }
      bool _997 = (_981 == 1.0f);
      if (!_997) {
        float _999 = _981 * _981;
        float _1000 = _999 * 3.0f;
        float _1001 = _981 * 2.0f;
        float _1002 = _1001 + 1.0f;
        float _1003 = _1002 - _1000;
        float _1004 = sqrt(_1003);
        float _1005 = _981 + -1.0f;
        float _1006 = _1005 * 2.0f;
        float _1007 = _1004 / _1006;
        float _1008 = -0.5f - _1007;
        _1010 = _1008;
      } else {
        _1010 = 1e+06f;
      }
      bool _1011 = (_982 == 1.0f);
      if (!_1011) {
        float _1013 = _982 * _982;
        float _1014 = _1013 * 3.0f;
        float _1015 = _982 * 2.0f;
        float _1016 = _1015 + 1.0f;
        float _1017 = _1016 - _1014;
        float _1018 = sqrt(_1017);
        float _1019 = _982 + -1.0f;
        float _1020 = _1019 * 2.0f;
        float _1021 = _1018 / _1020;
        float _1022 = -0.5f - _1021;
        _1024 = _996;
        _1025 = _1010;
        _1026 = _1022;
      } else {
        _1024 = _996;
        _1025 = _1010;
        _1026 = 1e+06f;
      }
    }
  } else {
    _1024 = _521;
    _1025 = _522;
    _1026 = _523;
  }
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_521, _522, _523),
      float3(_1024, _1025, _1026),
      false);
  _1024 = apt_tonemapped.x;
  _1025 = apt_tonemapped.y;
  _1026 = apt_tonemapped.z;
  bool _1027 = (_1024 <= 0.0031308000907301903f);
  bool _1028 = (_1025 <= 0.0031308000907301903f);
  bool _1029 = (_1026 <= 0.0031308000907301903f);
  float _1030 = _1024 * 12.920000076293945f;
  float _1031 = _1025 * 12.920000076293945f;
  float _1032 = _1026 * 12.920000076293945f;
  float _1033 = log2(_1024);
  float _1034 = log2(_1025);
  float _1035 = log2(_1026);
  float _1036 = _1033 * 0.4166666567325592f;
  float _1037 = _1034 * 0.4166666567325592f;
  float _1038 = _1035 * 0.4166666567325592f;
  float _1039 = exp2(_1036);
  float _1040 = exp2(_1037);
  float _1041 = exp2(_1038);
  float _1042 = _1039 * 1.0549999475479126f;
  float _1043 = _1040 * 1.0549999475479126f;
  float _1044 = _1041 * 1.0549999475479126f;
  float _1045 = _1042 + -0.054999999701976776f;
  float _1046 = _1043 + -0.054999999701976776f;
  float _1047 = _1044 + -0.054999999701976776f;
  float _1048 = select(_1027, _1030, _1045);
  float _1049 = select(_1028, _1031, _1046);
  float _1050 = select(_1029, _1032, _1047);
  float _1051 = log2(_1048);
  float _1052 = log2(_1049);
  float _1053 = log2(_1050);
  float _1054 = floor(_1051);
  float _1055 = floor(_1052);
  float _1056 = floor(_1053);
  float _1057 = _1054 + -6.0f;
  float _1058 = _1055 + -6.0f;
  float _1059 = _1056 + -5.0f;
  float _1060 = exp2(_1057);
  float _1061 = exp2(_1058);
  float _1062 = exp2(_1059);
  uint _1063 = uint(SV_Position.x);
  uint _1064 = uint(SV_Position.y);
  int _1065 = _1063 & 63;
  int _1066 = _1064 & 63;
  float4 _1067 = sBlueNoiseR8.Load(int4(_1065, _1066, 0, 0));
  float _1069 = _1067.x + -0.5f;
  bool _1070 = (_1048 > 0.0f);
  bool _1071 = (_1049 > 0.0f);
  bool _1072 = (_1050 > 0.0f);
  float _1073 = float((bool)_1070);
  float _1074 = float((bool)_1071);
  float _1075 = float((bool)_1072);
  float _1076 = _1060 * _1073;
  float _1077 = _1076 * _1069;
  float _1078 = _1061 * _1074;
  float _1079 = _1078 * _1069;
  float _1080 = _1062 * _1075;
  float _1081 = _1080 * _1069;
  float _1082 = _1077 + _1048;
  float _1083 = _1079 + _1049;
  float _1084 = _1081 + _1050;
  SV_Target.x = _1082;
  SV_Target.y = _1083;
  SV_Target.z = _1084;
  SV_Target.w = _61.w;
  return SV_Target;
}
