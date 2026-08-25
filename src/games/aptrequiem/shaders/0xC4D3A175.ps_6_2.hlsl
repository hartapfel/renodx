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
  float _47 = _44.y * 0.10000000149011612f;
  float _48 = _47 + _40.y;
  float _49 = _44.y * 0.5f;
  float _50 = _49 + _40.z;
  float _51 = exp2(_50);
  float _52 = _51 + -1.0f;
  float _55 = (PostProcess.Settings[11].y) * _52;
  float _56 = _55 + 1.0f;
  float _57 = log2(_56);
  float _58 = _40.x + TEXCOORD.z;
  float _59 = _48 + TEXCOORD.w;
  float _60 = _40.x + TEXCOORD.x;
  float _61 = _48 + TEXCOORD.y;
  float _62 = _58 * 2.0f;
  float _63 = _59 * 2.0f;
  float _64 = _62 + -1.0f;
  float _65 = _63 + -1.0f;
  float _69 = (Global.c[37].x) * _64;
  float _70 = (Global.c[37].y) * _65;
  float _71 = _69 * _69;
  float _72 = _70 * _70;
  float _73 = _71 + _72;
  float _74 = sqrt(_73);
  float _77 = _60 * 2.0f;
  float _78 = _77 + -1.0f;
  float _79 = _61 * 1.125f;
  float _80 = _79 + -0.5625f;
  float _81 = _78 * _78;
  float _82 = _80 * _80;
  float _83 = _82 + _81;
  float _84 = sqrt(_83);
  float _85 = _84 * 0.8715755343437195f;
  float _86 = _85 * _85;
  float _87 = _86 + -0.15000000596046448f;
  float _88 = _87 * 1.8181819915771484f;
  float _89 = saturate(_88);
  float _90 = _89 * 2.0f;
  float _91 = 3.0f - _90;
  float _92 = (PostProcess.Settings[2].w) * _74;
  float _93 = _89 * _89;
  float _94 = _93 * _92;
  float _95 = _94 * _86;
  float _96 = _95 * _91;
  float _98 = (PostProcess.Settings[2].z) * _69;
  float _99 = (PostProcess.Settings[2].z) * _70;
  float _100 = _99 + _59;
  float _101 = _58 - _98;
  float _102 = _44.x * 0.010840999893844128f;
  float _103 = _58 + _102;
  float _104 = _103 + _98;
  float _105 = _59 + _102;
  float _106 = _105 - _99;
  float _107 = _96 + _57;
  float4 _108 = s0.SampleLevel(s0Sampler, float2(_104, _100), _107);
  float4 _110 = s0.SampleLevel(s0Sampler, float2(_101, _106), _107);
  float4 _112 = s0.SampleLevel(s0Sampler, float2(_58, _59), _107);
  float _115 = max(_108.x, 0.0f);
  float _116 = max(_110.y, 0.0f);
  float _117 = max(_112.z, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_115, _116, _117),
      max(_112.rgb, 0.f.xxx),
      float2(_58, _59),
      s0,
      s0Sampler,
      _107);
  _115 = renodx_chromatic_aberration_input.x;
  _116 = renodx_chromatic_aberration_input.y;
  _117 = renodx_chromatic_aberration_input.z;
  float _120 = (Global.c[32].w) * 11.0f;
  float _121 = _120 + -1.2000000476837158f;
  float _122 = saturate(_121);
  float _123 = (Global.c[32].w) * 1.7000000476837158f;
  float _124 = 1.340000033378601f - _123;
  float _125 = saturate(_124);
  float _126 = _125 * _125;
  float _127 = _126 * _126;
  float _128 = _127 * _122;
  bool _129 = ((Global.c[32].w) < 9.999999747378752e-06f);
  float _132 = max((Global.c[33].y), _128);
  float _133 = _59 * 1.7999999523162842f;
  float _134 = _133 + -1.100000023841858f;
  float _135 = abs(_64);
  float _136 = abs(_134);
  float _137 = dot(float2(_135, _136), float2(_135, _136));
  float _138 = sqrt(_137);
  float _139 = select(_129, 1.0f, 0.0f);
  float _140 = _139 * _132;
  float4 _141 = s0.SampleLevel(s0Sampler, float2(_58, _59), 1.0f);
  float4 _145 = s0.SampleLevel(s0Sampler, float2(_58, _59), 2.0f);
  float4 _149 = s0.SampleLevel(s0Sampler, float2(_58, _59), 3.0f);
  float _153 = _137 * 1.7000000476837158f;
  float _154 = _153 + -0.6000000238418579f;
  float _155 = saturate(_154);
  float _156 = _137 * 1.475000023841858f;
  float _157 = _156 + -0.375f;
  float _158 = saturate(_157);
  float _159 = _137 * 1.2999999523162842f;
  float _160 = _159 + -0.15000000596046448f;
  float _161 = saturate(_160);
  float _162 = _149.x - _145.x;
  float _163 = _149.y - _145.y;
  float _164 = _149.z - _145.z;
  float _165 = _162 * _155;
  float _166 = _163 * _155;
  float _167 = _164 * _155;
  float _168 = _145.x - _141.x;
  float _169 = _168 + _165;
  float _170 = _145.y - _141.y;
  float _171 = _170 + _166;
  float _172 = _145.z - _141.z;
  float _173 = _172 + _167;
  float _174 = _169 * _158;
  float _175 = _171 * _158;
  float _176 = _173 * _158;
  float _177 = _161 * _140;
  float _178 = _141.x - _115;
  float _179 = _178 + _174;
  float _180 = _141.y - _116;
  float _181 = _180 + _175;
  float _182 = _141.z - _117;
  float _183 = _182 + _176;
  float _184 = _179 * _177;
  float _185 = _181 * _177;
  float _186 = _183 * _177;
  float _187 = _184 + _115;
  float _188 = _185 + _116;
  float _189 = _186 + _117;
  float4 _190 = s12_bloom.Sample(s12_bloomSampler, float2(_58, _59));
  float4 _194 = s8.Sample(s8Sampler, float2(_60, _61));
  float _201 = (PostProcess.Settings[4].w) * _194.x;
  float _202 = (PostProcess.Settings[4].w) * _194.y;
  float _203 = (PostProcess.Settings[4].w) * _194.z;
  float _204 = _201 + (PostProcess.Settings[4].z);
  float _205 = _202 + (PostProcess.Settings[4].z);
  float _206 = _203 + (PostProcess.Settings[4].z);
  float _207 = saturate(_204);
  float _208 = saturate(_205);
  float _209 = saturate(_206);
  float _210 = _190.x - _187;
  float _211 = _190.y - _188;
  float _212 = _190.z - _189;
  float _213 = _207 * _210;
  float _214 = _208 * _211;
  float _215 = _209 * _212;
  float _216 = _213 + _187;
  float _217 = _214 + _188;
  float _218 = _215 + _189;
  bool _221 = ((User.c[6].y) > 0.0f);
  float _354;
  float _386;
  float _387;
  float _388;
  float _661;
  float _717;
  float _773;
  float _776;
  float _777;
  float _778;
  float _789;
  float _921;
  float _922;
  float _923;
  float _969;
  float _970;
  float _971;
  float _1009;
  float _1023;
  float _1037;
  float _1038;
  float _1039;
  [branch]
  if (_221) {
    float4 _223 = s4.Sample(s4Sampler, float2(TEXCOORD.x, TEXCOORD.y));
    float4 _228 = s5.Sample(s5Sampler, float2(TEXCOORD.x, TEXCOORD.y));
    float _232 = (PostProcess.Settings[6].x) * _228.x;
    float _236 = _232 * (PostProcess.Settings[7].x);
    float _237 = _232 * (PostProcess.Settings[7].y);
    float _238 = _236 + TEXCOORD.x;
    float _239 = _237 + TEXCOORD.y;
    float4 _240 = s4.Sample(s4Sampler, float2(_238, _239));
    float4 _242 = s5.Sample(s5Sampler, float2(_238, _239));
    float _244 = (PostProcess.Settings[6].x) * _242.x;
    float _245 = abs(_244);
    float _247 = _245 / (PostProcess.Settings[7].w);
    float _248 = _240.z - _223.z;
    float _249 = _247 * _248;
    float _250 = _223.x - _216;
    float _251 = _223.y - _217;
    float _252 = _223.z - _218;
    float _253 = _252 + _249;
    float _254 = _250 * _223.w;
    float _255 = _251 * _223.w;
    float _256 = _253 * _223.w;
    _386 = _254;
    _387 = _255;
    _388 = _256;
  } else {
    bool _259 = ((User.c[6].x) > 0.0f);
    [branch]
    if (_259) {
      float4 _261 = s7.Sample(s7Sampler, float2(TEXCOORD.x, TEXCOORD.y));
      float _263 = abs(_261.x);
      _354 = _263;
    } else {
      float4 _265 = s2.SampleLevel(s2Sampler, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
      float _267 = TEXCOORD.x * 2.0f;
      float _268 = TEXCOORD.y * 2.0f;
      float _269 = _267 + -1.0f;
      float _270 = _268 + -1.0f;
      uint _271 = _39 << 5;
      uint _272 = _271 + 112u;
      uint _275 = _271 + 113u;
      uint _278 = _271 + 114u;
      uint _281 = _271 + 115u;
      float _296 = (Global.c[_272].x) * _269;
      float _297 = mad(_270, (Global.c[_272].y), _296);
      float _298 = mad(_265.x, (Global.c[_272].z), _297);
      float _299 = _298 + (Global.c[_272].w);
      float _300 = (Global.c[_275].x) * _269;
      float _301 = mad(_270, (Global.c[_275].y), _300);
      float _302 = mad(_265.x, (Global.c[_275].z), _301);
      float _303 = _302 + (Global.c[_275].w);
      float _304 = (Global.c[_278].x) * _269;
      float _305 = mad(_270, (Global.c[_278].y), _304);
      float _306 = mad(_265.x, (Global.c[_278].z), _305);
      float _307 = _306 + (Global.c[_278].w);
      float _308 = (Global.c[_281].x) * _269;
      float _309 = mad(_270, (Global.c[_281].y), _308);
      float _310 = mad(_265.x, (Global.c[_281].z), _309);
      float _311 = _310 + (Global.c[_281].w);
      float _312 = _299 / _311;
      float _313 = _303 / _311;
      float _314 = _307 / _311;
      float _315 = _312 * _312;
      float _316 = _313 * _313;
      float _317 = _316 + _315;
      float _318 = _314 * _314;
      float _319 = _317 + _318;
      float _320 = sqrt(_319);
      float4 _321 = s5.Sample(s5Sampler, float2(TEXCOORD.x, TEXCOORD.y));
      float _327 = (PostProcess.Settings[6].w) * (PostProcess.Settings[5].x);
      float _328 = _327 + (PostProcess.Settings[5].x);
      float _329 = (PostProcess.Settings[5].x) - _327;
      float _330 = max(_320, _329);
      float _331 = min(_330, _328);
      float _333 = _320 - _331;
      float _334 = (PostProcess.Settings[5].w) * _333;
      float _336 = _331 - (PostProcess.Settings[5].y);
      float _337 = _336 * _320;
      float _338 = _334 / _337;
      float _339 = min(_338, 0.0f);
      float _342 = (PostProcess.Settings[7].z) * _339;
      float _343 = _327 + 1.0f;
      float _344 = 1.0f / _343;
      float _345 = _342 * _344;
      float _346 = max(0.0f, _338);
      float _347 = _345 + _346;
      float _348 = min(_321.x, _347);
      float _349 = abs(_348);
      float _350 = abs(_347);
      float _351 = max(_349, _350);
      float _352 = saturate(_351);
      _354 = _352;
    }
    float _357 = (PostProcess.Settings[6].x) * _354;
    float4 _358 = s4.Sample(s4Sampler, float2(TEXCOORD.x, TEXCOORD.y));
    float _365 = (PostProcess.Settings[7].x) * _357;
    float _366 = (PostProcess.Settings[7].y) * _357;
    float _367 = _365 + TEXCOORD.x;
    float _368 = _366 + TEXCOORD.y;
    float4 _369 = s4.Sample(s4Sampler, float2(_367, _368));
    float4 _371 = s5.Sample(s5Sampler, float2(_367, _368));
    float _373 = abs(_371.x);
    float _374 = _369.z - _358.z;
    float _375 = _373 * _374;
    float _376 = _357 + -1.0f;
    float _377 = saturate(_376);
    float _378 = _358.x - _216;
    float _379 = _358.y - _217;
    float _380 = _358.z - _218;
    float _381 = _380 + _375;
    float _382 = _377 * _378;
    float _383 = _377 * _379;
    float _384 = _381 * _377;
    _386 = _382;
    _387 = _383;
    _388 = _384;
  }
  float _389 = _386 + _216;
  float _390 = _387 + _217;
  float _391 = _388 + _218;
  float4 _392 = s6.Load(int3(0, 0, 0));
  float _396 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _397 = _389 * 11190.6005859375f;
  float _398 = _397 * _392.x;
  float _399 = _398 * _396;
  float _400 = _390 * 11190.6005859375f;
  float _401 = _400 * _392.x;
  float _402 = _401 * _396;
  float _403 = _391 * 11190.6005859375f;
  float _404 = _403 * _392.x;
  float _405 = _404 * _396;
  float _406 = _399 + 1.0f;
  float _407 = _402 + 1.0f;
  float _408 = _405 + 1.0f;
  float _409 = log2(_406);
  float _410 = log2(_407);
  float _411 = log2(_408);
  float _412 = _409 * 0.07434873282909393f;
  float _413 = _410 * 0.07434873282909393f;
  float _414 = _411 * 0.07434873282909393f;
  float _417 = _412 * (PostProcess.OffsetWeight[0].x);
  float _418 = _413 * (PostProcess.OffsetWeight[0].x);
  float _419 = _414 * (PostProcess.OffsetWeight[0].x);
  float _421 = _417 + (PostProcess.OffsetWeight[0].y);
  float _422 = _418 + (PostProcess.OffsetWeight[0].y);
  float _423 = _419 + (PostProcess.OffsetWeight[0].y);
  float4 _424 = s3_3D.Sample(s3_3DSampler, float3(_421, _422, _423));
  float _430 = _424.x * 13.450128555297852f;
  float _431 = _424.y * 13.450128555297852f;
  float _432 = _424.z * 13.450128555297852f;
  float _433 = exp2(_430);
  float _434 = exp2(_431);
  float _435 = exp2(_432);
  float _436 = _433 + -1.0f;
  float _437 = _434 + -1.0f;
  float _438 = _435 + -1.0f;
  float _439 = _436 * 8.936070662457496e-05f;
  float _440 = _437 * 8.936070662457496e-05f;
  float _441 = _438 * 8.936070662457496e-05f;
  float _442 = 10000.0f / (PostProcess.Settings[10].w);
  float _443 = _439 * _442;
  float _444 = _440 * _442;
  float _445 = _441 * _442;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUT(
      float3(_399, _402, _405) / apt_lut_input_encode_scale,
      float3(_443, _444, _445));
  apt_lut_output = APTApplyPerceptualFilmGrain(apt_lut_output, SV_Position.xy);
  _443 = apt_lut_output.x;
  _444 = apt_lut_output.y;
  _445 = apt_lut_output.z;
  float _449 = (User.c[2].y) / (User.c[2].x);
  int _452 = asint((Global.c[1].w));
  uint _453 = _452 + 30u;
  int _454 = _453 & 63;
  float _455 = _58 * 8.0f;
  float _456 = _455 * _449;
  float _457 = _59 * 8.0f;
  float _458 = float((int)(_452));
  float4 _459 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_456, _457, _458), 0.0f);
  float _461 = _58 + 0.5f;
  float _462 = (User.c[2].x) * 0.5f;
  float _463 = _461 + _462;
  float _464 = _449 * 8.0f;
  float _465 = _464 * _463;
  float _466 = _59 + 0.5f;
  float _467 = (User.c[2].y) * 0.5f;
  float _468 = _466 + _467;
  float _469 = _468 * 8.0f;
  float _470 = float((int)(_454));
  float4 _471 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_465, _469, _470), 0.0f);
  float _473 = _471.x + _459.x;
  float _474 = _473 * 0.714285671710968f;
  float _475 = _474 + -0.2142857164144516f;
  float _476 = saturate(_475);
  float _477 = _476 * 2.0f;
  float _478 = 3.0f - _477;
  float _479 = _476 * _476;
  float _480 = _479 * _478;
  float _481 = _480 * 0.5f;
  float _482 = _480 * 0.4000000059604645f;
  float _483 = _480 * 0.05000000074505806f;
  float _484 = _481 + -0.5f;
  float _485 = _482 + -0.6000000238418579f;
  float _486 = _483 + -0.949999988079071f;
  float _487 = _484 * _140;
  float _488 = _485 * _140;
  float _489 = _486 * _140;
  float _490 = _487 + 1.0f;
  float _491 = _488 + 1.0f;
  float _492 = _489 + 1.0f;
  float _493 = _443 * _490;
  float _494 = _444 * _491;
  float _495 = _445 * _492;
  float4 _496 = s13.Sample(s13Sampler, float2(_58, _59));
  float _503 = _155 + 1.0f;
  float _504 = saturate(_503);
  float _505 = (User.c[2].x) * _504;
  float _506 = (User.c[2].y) * _504;
  float _507 = _505 + _58;
  float _508 = _506 + _59;
  float4 _509 = s13.Sample(s13Sampler, float2(_507, _508));
  float _513 = _509.x + _496.x;
  float _514 = _509.y + _496.y;
  float _515 = _509.z + _496.z;
  float _516 = _513 * 0.5f;
  float _517 = _514 * 0.5f;
  float _518 = _515 * 0.5f;
  float _519 = _140 * 0.6000000238418579f;
  float _520 = _519 * _138;
  float _521 = _140 * 0.7300000190734863f;
  float _522 = _521 * _138;
  float _523 = _140 * 0.8799999952316284f;
  float _524 = _523 * _138;
  float _525 = 1.0f - _520;
  float _526 = 1.0f - _522;
  float _527 = 1.0f - _524;
  float _528 = saturate(_525);
  float _529 = saturate(_526);
  float _530 = saturate(_527);
  float _531 = _493 * _528;
  float _532 = _494 * _529;
  float _533 = _495 * _530;
  float _534 = _516 + _531;
  float _535 = _532 + _517;
  float _536 = _533 + _518;
  bool _539 = ((User.c[3].x) > 0.0f);
  if (_539) {
    float _541 = log2(_534);
    float _542 = _541 * 3.0f;
    float _543 = exp2(_542);
    float _544 = _543 + -1.0f;
    float _545 = _534 + -1.0f;
    float _546 = _544 / _545;
    float _547 = _546 + -1.0f;
    bool _548 = !(_534 == 1.0f);
    float _549 = _547 / _546;
    float _550 = select(_548, _549, 0.6666666865348816f);
    float _551 = log2(_535);
    float _552 = _551 * 3.0f;
    float _553 = exp2(_552);
    float _554 = _553 + -1.0f;
    float _555 = _535 + -1.0f;
    float _556 = _554 / _555;
    float _557 = _556 + -1.0f;
    bool _558 = !(_535 == 1.0f);
    float _559 = _557 / _556;
    float _560 = select(_558, _559, 0.6666666865348816f);
    float _561 = log2(_536);
    float _562 = _561 * 3.0f;
    float _563 = exp2(_562);
    float _564 = _563 + -1.0f;
    float _565 = _536 + -1.0f;
    float _566 = _564 / _565;
    float _567 = _566 + -1.0f;
    bool _568 = !(_536 == 1.0f);
    float _569 = _567 / _566;
    float _570 = select(_568, _569, 0.6666666865348816f);
    bool _571 = (_550 <= 0.0031308000907301903f);
    bool _572 = (_560 <= 0.0031308000907301903f);
    bool _573 = (_570 <= 0.0031308000907301903f);
    float _574 = _550 * 12.920000076293945f;
    float _575 = _560 * 12.920000076293945f;
    float _576 = _570 * 12.920000076293945f;
    float _577 = log2(_550);
    float _578 = log2(_560);
    float _579 = log2(_570);
    float _580 = _577 * 0.4166666567325592f;
    float _581 = _578 * 0.4166666567325592f;
    float _582 = _579 * 0.4166666567325592f;
    float _583 = exp2(_580);
    float _584 = exp2(_581);
    float _585 = exp2(_582);
    float _586 = _583 * 1.0549999475479126f;
    float _587 = _584 * 1.0549999475479126f;
    float _588 = _585 * 1.0549999475479126f;
    float _589 = _586 + -0.054999999701976776f;
    float _590 = _587 + -0.054999999701976776f;
    float _591 = _588 + -0.054999999701976776f;
    float _592 = select(_571, _574, _589);
    float _593 = select(_572, _575, _590);
    float _594 = select(_573, _576, _591);
    int _596 = asint((User.c[3].y));
    int _597 = _596 & 1;
    bool _598 = (_597 == 0);
    if (!_598) {
      bool _607 = !(_592 <= (User.c[4].x));
      if (!_607) {
        float _609 = max(9.999999974752427e-07f, (User.c[4].x));
        float _610 = _592 / _609;
        float _611 = _610 * (User.c[4].y);
        float _612 = _610 * _610;
        float _613 = _612 * _610;
        float _614 = _613 - _610;
        float _615 = (User.c[3].z) * 0.1666666716337204f;
        float _616 = _609 * _609;
        float _617 = _616 * _615;
        float _618 = _617 * _614;
        float _619 = _618 + _611;
        _661 = _619;
      } else {
        bool _621 = !(_592 <= (User.c[4].z));
        if (!_621) {
          float _623 = (User.c[4].z) - (User.c[4].x);
          float _624 = max(9.999999974752427e-07f, _623);
          float _625 = _592 - (User.c[4].x);
          float _626 = _625 / _624;
          float _627 = 1.0f - _626;
          float _628 = _627 * (User.c[4].y);
          float _629 = _626 * (User.c[4].w);
          float _630 = _628 + _629;
          float _631 = _627 * _627;
          float _632 = _631 * _627;
          float _633 = _632 - _627;
          float _634 = _633 * (User.c[3].z);
          float _635 = _626 * _626;
          float _636 = _635 * _626;
          float _637 = _636 - _626;
          float _638 = _637 * (User.c[3].w);
          float _639 = _634 + _638;
          float _640 = _624 * _624;
          float _641 = _640 * 0.1666666716337204f;
          float _642 = _641 * _639;
          float _643 = _630 + _642;
          _661 = _643;
        } else {
          float _645 = 1.0f - (User.c[4].z);
          float _646 = _592 - (User.c[4].z);
          float _647 = max(9.999999974752427e-07f, _645);
          float _648 = _646 / _647;
          float _649 = 1.0f - _648;
          float _650 = _649 * (User.c[4].w);
          float _651 = _650 + _648;
          float _652 = _649 * _649;
          float _653 = _652 * _649;
          float _654 = _653 - _649;
          float _655 = _645 * _645;
          float _656 = _655 * 0.1666666716337204f;
          float _657 = _656 * (User.c[3].w);
          float _658 = _657 * _654;
          float _659 = _651 + _658;
          _661 = _659;
        }
      }
      float _662 = saturate(_661);
      bool _663 = !(_593 <= (User.c[4].x));
      if (!_663) {
        float _665 = max(9.999999974752427e-07f, (User.c[4].x));
        float _666 = _593 / _665;
        float _667 = _666 * (User.c[4].y);
        float _668 = _666 * _666;
        float _669 = _668 * _666;
        float _670 = _669 - _666;
        float _671 = (User.c[3].z) * 0.1666666716337204f;
        float _672 = _665 * _665;
        float _673 = _672 * _671;
        float _674 = _673 * _670;
        float _675 = _674 + _667;
        _717 = _675;
      } else {
        bool _677 = !(_593 <= (User.c[4].z));
        if (!_677) {
          float _679 = (User.c[4].z) - (User.c[4].x);
          float _680 = max(9.999999974752427e-07f, _679);
          float _681 = _593 - (User.c[4].x);
          float _682 = _681 / _680;
          float _683 = 1.0f - _682;
          float _684 = _683 * (User.c[4].y);
          float _685 = _682 * (User.c[4].w);
          float _686 = _684 + _685;
          float _687 = _683 * _683;
          float _688 = _687 * _683;
          float _689 = _688 - _683;
          float _690 = _689 * (User.c[3].z);
          float _691 = _682 * _682;
          float _692 = _691 * _682;
          float _693 = _692 - _682;
          float _694 = _693 * (User.c[3].w);
          float _695 = _690 + _694;
          float _696 = _680 * _680;
          float _697 = _696 * 0.1666666716337204f;
          float _698 = _697 * _695;
          float _699 = _686 + _698;
          _717 = _699;
        } else {
          float _701 = 1.0f - (User.c[4].z);
          float _702 = _593 - (User.c[4].z);
          float _703 = max(9.999999974752427e-07f, _701);
          float _704 = _702 / _703;
          float _705 = 1.0f - _704;
          float _706 = _705 * (User.c[4].w);
          float _707 = _706 + _704;
          float _708 = _705 * _705;
          float _709 = _708 * _705;
          float _710 = _709 - _705;
          float _711 = _701 * _701;
          float _712 = _711 * 0.1666666716337204f;
          float _713 = _712 * (User.c[3].w);
          float _714 = _713 * _710;
          float _715 = _707 + _714;
          _717 = _715;
        }
      }
      float _718 = saturate(_717);
      bool _719 = !(_594 <= (User.c[4].x));
      if (!_719) {
        float _721 = max(9.999999974752427e-07f, (User.c[4].x));
        float _722 = _594 / _721;
        float _723 = _722 * (User.c[4].y);
        float _724 = _722 * _722;
        float _725 = _724 * _722;
        float _726 = _725 - _722;
        float _727 = (User.c[3].z) * 0.1666666716337204f;
        float _728 = _721 * _721;
        float _729 = _728 * _727;
        float _730 = _729 * _726;
        float _731 = _730 + _723;
        _773 = _731;
      } else {
        bool _733 = !(_594 <= (User.c[4].z));
        if (!_733) {
          float _735 = (User.c[4].z) - (User.c[4].x);
          float _736 = max(9.999999974752427e-07f, _735);
          float _737 = _594 - (User.c[4].x);
          float _738 = _737 / _736;
          float _739 = 1.0f - _738;
          float _740 = _739 * (User.c[4].y);
          float _741 = _738 * (User.c[4].w);
          float _742 = _740 + _741;
          float _743 = _739 * _739;
          float _744 = _743 * _739;
          float _745 = _744 - _739;
          float _746 = _745 * (User.c[3].z);
          float _747 = _738 * _738;
          float _748 = _747 * _738;
          float _749 = _748 - _738;
          float _750 = _749 * (User.c[3].w);
          float _751 = _746 + _750;
          float _752 = _736 * _736;
          float _753 = _752 * 0.1666666716337204f;
          float _754 = _753 * _751;
          float _755 = _742 + _754;
          _773 = _755;
        } else {
          float _757 = 1.0f - (User.c[4].z);
          float _758 = _594 - (User.c[4].z);
          float _759 = max(9.999999974752427e-07f, _757);
          float _760 = _758 / _759;
          float _761 = 1.0f - _760;
          float _762 = _761 * (User.c[4].w);
          float _763 = _762 + _760;
          float _764 = _761 * _761;
          float _765 = _764 * _761;
          float _766 = _765 - _761;
          float _767 = _757 * _757;
          float _768 = _767 * 0.1666666716337204f;
          float _769 = _768 * (User.c[3].w);
          float _770 = _769 * _766;
          float _771 = _763 + _770;
          _773 = _771;
        }
      }
      float _774 = saturate(_773);
      _776 = _662;
      _777 = _718;
      _778 = _774;
    } else {
      _776 = _592;
      _777 = _593;
      _778 = _594;
    }
    int _779 = _596 & 2;
    bool _780 = (_779 == 0);
    if (!_780) {
      float _782 = sqrt(_776);
      float _783 = sqrt(_777);
      float _784 = sqrt(_778);
      float _785 = dot(float3(_782, _783, _784), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _786 = 1.0f - _785;
      float _787 = saturate(_786);
      _789 = _787;
    } else {
      _789 = 1.0f;
    }
    int _790 = _596 & 8;
    bool _791 = (_790 == 0);
    if (!_791) {
      bool _793 = (_789 <= 0.0031308000907301903f);
      float _794 = _789 * 12.920000076293945f;
      float _795 = log2(_789);
      float _796 = _795 * 0.4166666567325592f;
      float _797 = exp2(_796);
      float _798 = _797 * 1.0549999475479126f;
      float _799 = _798 + -0.054999999701976776f;
      float _800 = select(_793, _794, _799);
      _1037 = _800;
      _1038 = _800;
      _1039 = _800;
    } else {
      int _802 = _596 & 4;
      bool _803 = (_802 == 0);
      if (!_803) {
        int _805 = _596 & 16;
        bool _806 = (_805 == 0);
        if (!_806) {
          float _810 = (User.c[5].x) * 0.5f;
          float _811 = _810 + 0.5f;
          bool _812 = (_811 < 0.5f);
          float _813 = (User.c[5].x) * 5.0f;
          float _814 = select(_812, (User.c[5].x), _813);
          bool _815 = (_777 < _778);
          float _816 = select(_815, _778, _777);
          float _817 = select(_815, _777, _778);
          bool _818 = (_776 < _816);
          float _819 = select(_818, _816, _776);
          float _820 = select(_818, _776, _816);
          float _821 = min(_820, _817);
          float _822 = _819 - _821;
          float _823 = _819 + 1.000000013351432e-10f;
          float _824 = _822 / _823;
          float _826 = _824 - (User.c[5].y);
          float _827 = saturate(_826);
          float _828 = max(_827, 9.999999974752427e-07f);
          float _829 = log2(_828);
          float _830 = _829 * _814;
          float _831 = exp2(_830);
          float _832 = 2.0f - _831;
          float _834 = 1.0f - (User.c[5].z);
          float _835 = saturate(_834);
          float _836 = max(_835, _832);
          float _837 = dot(float3(_776, _777, _778), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _838 = _776 - _837;
          float _839 = _777 - _837;
          float _840 = _778 - _837;
          float _841 = _838 * _836;
          float _842 = _839 * _836;
          float _843 = _840 * _836;
          float _844 = _837 - _776;
          float _845 = _844 + _841;
          float _846 = _837 - _777;
          float _847 = _846 + _842;
          float _848 = _837 - _778;
          float _849 = _848 + _843;
          float _850 = _845 * _789;
          float _851 = _847 * _789;
          float _852 = _849 * _789;
          float _853 = _850 + _776;
          float _854 = _851 + _777;
          float _855 = _852 + _778;
          _969 = _853;
          _970 = _854;
          _971 = _855;
        } else {
          bool _857 = (_789 == 0.0f);
          if (!_857) {
            float _861 = abs(User.c[5].x);
            float _862 = saturate(_861);
            uint2 _863; s15.GetDimensions(_863.x, _863.y);
            float _866 = float((uint)_863.y);
            int _867 = _596 & 32;
            bool _868 = (_867 == 0);
            float _869 = _866 + -1.0f;
            if (!_868) {
              float _871 = 1.0f / _869;
              uint _872 = uint(SV_Position.x);
              uint _873 = uint(SV_Position.y);
              int _874 = _872 & 63;
              int _875 = _873 & 63;
              float4 _876 = sBlueNoiseR8G8.Load(int4(_874, _875, 0, 0));
              float _879 = _876.x + -0.5f;
              float _880 = _776 * 13.999999046325684f;
              float _881 = _777 * 13.999999046325684f;
              float _882 = _778 * 13.999999046325684f;
              float _883 = saturate(_880);
              float _884 = saturate(_881);
              float _885 = saturate(_882);
              float _886 = _776 + -0.9285714030265808f;
              float _887 = _777 + -0.9285714030265808f;
              float _888 = _778 + -0.9285714030265808f;
              float _889 = _886 * 13.999999046325684f;
              float _890 = _887 * 13.999999046325684f;
              float _891 = _888 * 13.999999046325684f;
              float _892 = saturate(_889);
              float _893 = saturate(_890);
              float _894 = saturate(_891);
              float _895 = 1.0f - _892;
              float _896 = 1.0f - _893;
              float _897 = 1.0f - _894;
              float _898 = min(_883, _895);
              float _899 = min(_884, _896);
              float _900 = min(_885, _897);
              float _901 = _876.y + -0.5f;
              float _902 = _898 * _901;
              float _903 = _899 * _901;
              float _904 = _900 * _901;
              float _905 = _902 + _879;
              float _906 = _903 + _879;
              float _907 = _904 + _879;
              float _908 = _905 * _871;
              float _909 = _906 * _871;
              float _910 = _907 * _871;
              float _911 = _908 + _776;
              float _912 = _909 + _777;
              float _913 = _910 + _778;
              float _914 = saturate(_911);
              float _915 = saturate(_912);
              float _916 = saturate(_913);
              float _917 = saturate(_914);
              float _918 = saturate(_915);
              float _919 = saturate(_916);
              _921 = _917;
              _922 = _918;
              _923 = _919;
            } else {
              _921 = _776;
              _922 = _777;
              _923 = _778;
            }
            float _924 = float((uint)_863.x);
            float _925 = _869 / _924;
            float _926 = _925 * _921;
            float _927 = 0.5f / _924;
            float _928 = _926 + _927;
            float _929 = _869 / _866;
            float _930 = _929 * _922;
            float _931 = 0.5f / _866;
            float _932 = _930 + _931;
            float _933 = _923 * _869;
            float _934 = floor(_933);
            float _935 = frac(_933);
            float _936 = _934 / _866;
            float _937 = _936 + _928;
            float _938 = _934 + 1.0f;
            float _939 = _938 / _866;
            float _940 = _939 + _928;
            float4 _941 = s15.Sample(s15Sampler, float2(_937, _932));
            float4 _945 = s15.Sample(s15Sampler, float2(_940, _932));
            float _949 = _945.x - _941.x;
            float _950 = _945.y - _941.y;
            float _951 = _945.z - _941.z;
            float _952 = _949 * _935;
            float _953 = _950 * _935;
            float _954 = _951 * _935;
            float _955 = _862 * _789;
            float _956 = _941.x - _776;
            float _957 = _956 + _952;
            float _958 = _941.y - _777;
            float _959 = _958 + _953;
            float _960 = _941.z - _778;
            float _961 = _960 + _954;
            float _962 = _957 * _955;
            float _963 = _959 * _955;
            float _964 = _961 * _955;
            float _965 = _962 + _776;
            float _966 = _963 + _777;
            float _967 = _964 + _778;
            _969 = _965;
            _970 = _966;
            _971 = _967;
          } else {
            _969 = _776;
            _970 = _777;
            _971 = _778;
          }
        }
      } else {
        _969 = _776;
        _970 = _777;
        _971 = _778;
      }
      bool _972 = (_969 <= 0.040449999272823334f);
      bool _973 = (_970 <= 0.040449999272823334f);
      bool _974 = (_971 <= 0.040449999272823334f);
      float _975 = _969 * 0.07739938050508499f;
      float _976 = _970 * 0.07739938050508499f;
      float _977 = _971 * 0.07739938050508499f;
      float _978 = _969 + 0.054999999701976776f;
      float _979 = _970 + 0.054999999701976776f;
      float _980 = _971 + 0.054999999701976776f;
      float _981 = _978 * 0.9478673338890076f;
      float _982 = _979 * 0.9478673338890076f;
      float _983 = _980 * 0.9478673338890076f;
      float _984 = log2(_981);
      float _985 = log2(_982);
      float _986 = log2(_983);
      float _987 = _984 * 2.4000000953674316f;
      float _988 = _985 * 2.4000000953674316f;
      float _989 = _986 * 2.4000000953674316f;
      float _990 = exp2(_987);
      float _991 = exp2(_988);
      float _992 = exp2(_989);
      float _993 = select(_972, _975, _990);
      float _994 = select(_973, _976, _991);
      float _995 = select(_974, _977, _992);
      bool _996 = (_993 == 1.0f);
      if (!_996) {
        float _998 = _993 * _993;
        float _999 = _998 * 3.0f;
        float _1000 = _993 * 2.0f;
        float _1001 = _1000 + 1.0f;
        float _1002 = _1001 - _999;
        float _1003 = sqrt(_1002);
        float _1004 = _993 + -1.0f;
        float _1005 = _1004 * 2.0f;
        float _1006 = _1003 / _1005;
        float _1007 = -0.5f - _1006;
        _1009 = _1007;
      } else {
        _1009 = 1e+06f;
      }
      bool _1010 = (_994 == 1.0f);
      if (!_1010) {
        float _1012 = _994 * _994;
        float _1013 = _1012 * 3.0f;
        float _1014 = _994 * 2.0f;
        float _1015 = _1014 + 1.0f;
        float _1016 = _1015 - _1013;
        float _1017 = sqrt(_1016);
        float _1018 = _994 + -1.0f;
        float _1019 = _1018 * 2.0f;
        float _1020 = _1017 / _1019;
        float _1021 = -0.5f - _1020;
        _1023 = _1021;
      } else {
        _1023 = 1e+06f;
      }
      bool _1024 = (_995 == 1.0f);
      if (!_1024) {
        float _1026 = _995 * _995;
        float _1027 = _1026 * 3.0f;
        float _1028 = _995 * 2.0f;
        float _1029 = _1028 + 1.0f;
        float _1030 = _1029 - _1027;
        float _1031 = sqrt(_1030);
        float _1032 = _995 + -1.0f;
        float _1033 = _1032 * 2.0f;
        float _1034 = _1031 / _1033;
        float _1035 = -0.5f - _1034;
        _1037 = _1009;
        _1038 = _1023;
        _1039 = _1035;
      } else {
        _1037 = _1009;
        _1038 = _1023;
        _1039 = 1e+06f;
      }
    }
  } else {
    _1037 = _534;
    _1038 = _535;
    _1039 = _536;
  }
  float _1040 = log2(_1037);
  float _1041 = _1040 * 3.0f;
  float _1042 = exp2(_1041);
  float _1043 = _1042 + -1.0f;
  float _1044 = _1037 + -1.0f;
  float _1045 = _1043 / _1044;
  float _1046 = _1045 + -1.0f;
  bool _1047 = !(_1037 == 1.0f);
  float _1048 = _1046 / _1045;
  float _1049 = select(_1047, _1048, 0.6666666865348816f);
  float _1050 = log2(_1038);
  float _1051 = _1050 * 3.0f;
  float _1052 = exp2(_1051);
  float _1053 = _1052 + -1.0f;
  float _1054 = _1038 + -1.0f;
  float _1055 = _1053 / _1054;
  float _1056 = _1055 + -1.0f;
  bool _1057 = !(_1038 == 1.0f);
  float _1058 = _1056 / _1055;
  float _1059 = select(_1057, _1058, 0.6666666865348816f);
  float _1060 = log2(_1039);
  float _1061 = _1060 * 3.0f;
  float _1062 = exp2(_1061);
  float _1063 = _1062 + -1.0f;
  float _1064 = _1039 + -1.0f;
  float _1065 = _1063 / _1064;
  float _1066 = _1065 + -1.0f;
  bool _1067 = !(_1039 == 1.0f);
  float _1068 = _1066 / _1065;
  float _1069 = select(_1067, _1068, 0.6666666865348816f);
  float _1070 = saturate(_1049);
  float _1071 = saturate(_1059);
  float _1072 = saturate(_1069);
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_534, _535, _536),
      float3(_1070, _1071, _1072),
      false);
  _1070 = apt_tonemapped.x;
  _1071 = apt_tonemapped.y;
  _1072 = apt_tonemapped.z;
  bool _1073 = (_1070 <= 0.0031308000907301903f);
  bool _1074 = (_1071 <= 0.0031308000907301903f);
  bool _1075 = (_1072 <= 0.0031308000907301903f);
  float _1076 = _1070 * 12.920000076293945f;
  float _1077 = _1071 * 12.920000076293945f;
  float _1078 = _1072 * 12.920000076293945f;
  float _1079 = log2(_1070);
  float _1080 = log2(_1071);
  float _1081 = log2(_1072);
  float _1082 = _1079 * 0.4166666567325592f;
  float _1083 = _1080 * 0.4166666567325592f;
  float _1084 = _1081 * 0.4166666567325592f;
  float _1085 = exp2(_1082);
  float _1086 = exp2(_1083);
  float _1087 = exp2(_1084);
  float _1088 = _1085 * 1.0549999475479126f;
  float _1089 = _1086 * 1.0549999475479126f;
  float _1090 = _1087 * 1.0549999475479126f;
  float _1091 = _1088 + -0.054999999701976776f;
  float _1092 = _1089 + -0.054999999701976776f;
  float _1093 = _1090 + -0.054999999701976776f;
  float _1094 = select(_1073, _1076, _1091);
  float _1095 = select(_1074, _1077, _1092);
  float _1096 = select(_1075, _1078, _1093);
  int _1099 = asint((Global.c[1].w));
  uint _1100 = uint(SV_Position.x);
  uint _1101 = uint(SV_Position.y);
  int _1102 = _1100 & 63;
  int _1103 = _1101 & 63;
  float4 _1104 = sBlueNoiseR8.Load(int4(_1102, _1103, _1099, 0));
  float _1106 = _1104.x * 0.003921568859368563f;
  float _1107 = _1094 + 0.003921568859368563f;
  float _1108 = _1107 - _1106;
  float _1109 = _1106 + _1095;
  float _1110 = _1106 + _1096;
  SV_Target.x = _1108;
  SV_Target.y = _1109;
  SV_Target.z = _1110;
  SV_Target.w = _112.w;
  return SV_Target;
}
