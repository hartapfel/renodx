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
  float _693;
  float _749;
  float _805;
  float _808;
  float _809;
  float _810;
  float _821;
  float _953;
  float _954;
  float _955;
  float _1001;
  float _1002;
  float _1003;
  float _1041;
  float _1055;
  float _1069;
  float _1070;
  float _1071;
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
  float _394 = _392.x * _389;
  float _395 = _392.x * _390;
  float _396 = _392.x * _391;
  float _403 = (PostProcess.Settings[13].w) * _65;
  float _404 = _64 * _64;
  float _405 = _403 * _403;
  float _406 = _405 + _404;
  float _407 = sqrt(_406);
  float _409 = (PostProcess.Settings[13].x) * _407;
  float _411 = _409 + (PostProcess.Settings[13].y);
  float _412 = saturate(_411);
  float _414 = log2(_412);
  float _415 = _414 * (PostProcess.Settings[13].z);
  float _416 = exp2(_415);
  float _417 = _394 * (PostProcess.Settings[12].x);
  float _418 = _395 * (PostProcess.Settings[12].y);
  float _419 = _396 * (PostProcess.Settings[12].z);
  float _420 = _417 - _394;
  float _421 = _418 - _395;
  float _422 = _419 - _396;
  float _423 = _416 * _420;
  float _424 = _416 * _421;
  float _425 = _416 * _422;
  float _426 = _423 + _394;
  float _427 = _424 + _395;
  float _428 = _425 + _396;
  float _431 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _432 = _426 * 11190.6005859375f;
  float _433 = _432 * _431;
  float _434 = _427 * 11190.6005859375f;
  float _435 = _434 * _431;
  float _436 = _428 * 11190.6005859375f;
  float _437 = _436 * _431;
  float _438 = _433 + 1.0f;
  float _439 = _435 + 1.0f;
  float _440 = _437 + 1.0f;
  float _441 = log2(_438);
  float _442 = log2(_439);
  float _443 = log2(_440);
  float _444 = _441 * 0.07434873282909393f;
  float _445 = _442 * 0.07434873282909393f;
  float _446 = _443 * 0.07434873282909393f;
  float _449 = _444 * (PostProcess.OffsetWeight[0].x);
  float _450 = _445 * (PostProcess.OffsetWeight[0].x);
  float _451 = _446 * (PostProcess.OffsetWeight[0].x);
  float _453 = _449 + (PostProcess.OffsetWeight[0].y);
  float _454 = _450 + (PostProcess.OffsetWeight[0].y);
  float _455 = _451 + (PostProcess.OffsetWeight[0].y);
  float4 _456 = s3_3D.Sample(s3_3DSampler, float3(_453, _454, _455));
  float _462 = _456.x * 13.450128555297852f;
  float _463 = _456.y * 13.450128555297852f;
  float _464 = _456.z * 13.450128555297852f;
  float _465 = exp2(_462);
  float _466 = exp2(_463);
  float _467 = exp2(_464);
  float _468 = _465 + -1.0f;
  float _469 = _466 + -1.0f;
  float _470 = _467 + -1.0f;
  float _471 = _468 * 8.936070662457496e-05f;
  float _472 = _469 * 8.936070662457496e-05f;
  float _473 = _470 * 8.936070662457496e-05f;
  float _474 = 10000.0f / (PostProcess.Settings[10].w);
  float _475 = _471 * _474;
  float _476 = _472 * _474;
  float _477 = _473 * _474;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUT(
      float3(_433, _435, _437) / apt_lut_input_encode_scale,
      float3(_475, _476, _477));
  apt_lut_output = APTApplyPerceptualFilmGrain(apt_lut_output, SV_Position.xy);
  _475 = apt_lut_output.x;
  _476 = apt_lut_output.y;
  _477 = apt_lut_output.z;
  float _481 = (User.c[2].y) / (User.c[2].x);
  int _484 = asint((Global.c[1].w));
  uint _485 = _484 + 30u;
  int _486 = _485 & 63;
  float _487 = _58 * 8.0f;
  float _488 = _487 * _481;
  float _489 = _59 * 8.0f;
  float _490 = float((int)(_484));
  float4 _491 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_488, _489, _490), 0.0f);
  float _493 = _58 + 0.5f;
  float _494 = (User.c[2].x) * 0.5f;
  float _495 = _493 + _494;
  float _496 = _481 * 8.0f;
  float _497 = _496 * _495;
  float _498 = _59 + 0.5f;
  float _499 = (User.c[2].y) * 0.5f;
  float _500 = _498 + _499;
  float _501 = _500 * 8.0f;
  float _502 = float((int)(_486));
  float4 _503 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_497, _501, _502), 0.0f);
  float _505 = _503.x + _491.x;
  float _506 = _505 * 0.714285671710968f;
  float _507 = _506 + -0.2142857164144516f;
  float _508 = saturate(_507);
  float _509 = _508 * 2.0f;
  float _510 = 3.0f - _509;
  float _511 = _508 * _508;
  float _512 = _511 * _510;
  float _513 = _512 * 0.5f;
  float _514 = _512 * 0.4000000059604645f;
  float _515 = _512 * 0.05000000074505806f;
  float _516 = _513 + -0.5f;
  float _517 = _514 + -0.6000000238418579f;
  float _518 = _515 + -0.949999988079071f;
  float _519 = _516 * _140;
  float _520 = _517 * _140;
  float _521 = _518 * _140;
  float _522 = _519 + 1.0f;
  float _523 = _520 + 1.0f;
  float _524 = _521 + 1.0f;
  float _525 = _475 * _522;
  float _526 = _476 * _523;
  float _527 = _477 * _524;
  float4 _528 = s13.Sample(s13Sampler, float2(_58, _59));
  float _535 = _155 + 1.0f;
  float _536 = saturate(_535);
  float _537 = (User.c[2].x) * _536;
  float _538 = (User.c[2].y) * _536;
  float _539 = _537 + _58;
  float _540 = _538 + _59;
  float4 _541 = s13.Sample(s13Sampler, float2(_539, _540));
  float _545 = _541.x + _528.x;
  float _546 = _541.y + _528.y;
  float _547 = _541.z + _528.z;
  float _548 = _545 * 0.5f;
  float _549 = _546 * 0.5f;
  float _550 = _547 * 0.5f;
  float _551 = _140 * 0.6000000238418579f;
  float _552 = _551 * _138;
  float _553 = _140 * 0.7300000190734863f;
  float _554 = _553 * _138;
  float _555 = _140 * 0.8799999952316284f;
  float _556 = _555 * _138;
  float _557 = 1.0f - _552;
  float _558 = 1.0f - _554;
  float _559 = 1.0f - _556;
  float _560 = saturate(_557);
  float _561 = saturate(_558);
  float _562 = saturate(_559);
  float _563 = _525 * _560;
  float _564 = _526 * _561;
  float _565 = _527 * _562;
  float _566 = _548 + _563;
  float _567 = _564 + _549;
  float _568 = _565 + _550;
  bool _571 = ((User.c[3].x) > 0.0f) && !APTIsPsychoV();
  if (_571) {
    float _573 = log2(_566);
    float _574 = _573 * 3.0f;
    float _575 = exp2(_574);
    float _576 = _575 + -1.0f;
    float _577 = _566 + -1.0f;
    float _578 = _576 / _577;
    float _579 = _578 + -1.0f;
    bool _580 = !(_566 == 1.0f);
    float _581 = _579 / _578;
    float _582 = select(_580, _581, 0.6666666865348816f);
    float _583 = log2(_567);
    float _584 = _583 * 3.0f;
    float _585 = exp2(_584);
    float _586 = _585 + -1.0f;
    float _587 = _567 + -1.0f;
    float _588 = _586 / _587;
    float _589 = _588 + -1.0f;
    bool _590 = !(_567 == 1.0f);
    float _591 = _589 / _588;
    float _592 = select(_590, _591, 0.6666666865348816f);
    float _593 = log2(_568);
    float _594 = _593 * 3.0f;
    float _595 = exp2(_594);
    float _596 = _595 + -1.0f;
    float _597 = _568 + -1.0f;
    float _598 = _596 / _597;
    float _599 = _598 + -1.0f;
    bool _600 = !(_568 == 1.0f);
    float _601 = _599 / _598;
    float _602 = select(_600, _601, 0.6666666865348816f);
    bool _603 = (_582 <= 0.0031308000907301903f);
    bool _604 = (_592 <= 0.0031308000907301903f);
    bool _605 = (_602 <= 0.0031308000907301903f);
    float _606 = _582 * 12.920000076293945f;
    float _607 = _592 * 12.920000076293945f;
    float _608 = _602 * 12.920000076293945f;
    float _609 = log2(_582);
    float _610 = log2(_592);
    float _611 = log2(_602);
    float _612 = _609 * 0.4166666567325592f;
    float _613 = _610 * 0.4166666567325592f;
    float _614 = _611 * 0.4166666567325592f;
    float _615 = exp2(_612);
    float _616 = exp2(_613);
    float _617 = exp2(_614);
    float _618 = _615 * 1.0549999475479126f;
    float _619 = _616 * 1.0549999475479126f;
    float _620 = _617 * 1.0549999475479126f;
    float _621 = _618 + -0.054999999701976776f;
    float _622 = _619 + -0.054999999701976776f;
    float _623 = _620 + -0.054999999701976776f;
    float _624 = select(_603, _606, _621);
    float _625 = select(_604, _607, _622);
    float _626 = select(_605, _608, _623);
    int _628 = asint((User.c[3].y));
    int _629 = _628 & 1;
    bool _630 = (_629 == 0);
    if (!_630) {
      bool _639 = !(_624 <= (User.c[4].x));
      if (!_639) {
        float _641 = max(9.999999974752427e-07f, (User.c[4].x));
        float _642 = _624 / _641;
        float _643 = _642 * (User.c[4].y);
        float _644 = _642 * _642;
        float _645 = _644 * _642;
        float _646 = _645 - _642;
        float _647 = (User.c[3].z) * 0.1666666716337204f;
        float _648 = _641 * _641;
        float _649 = _648 * _647;
        float _650 = _649 * _646;
        float _651 = _650 + _643;
        _693 = _651;
      } else {
        bool _653 = !(_624 <= (User.c[4].z));
        if (!_653) {
          float _655 = (User.c[4].z) - (User.c[4].x);
          float _656 = max(9.999999974752427e-07f, _655);
          float _657 = _624 - (User.c[4].x);
          float _658 = _657 / _656;
          float _659 = 1.0f - _658;
          float _660 = _659 * (User.c[4].y);
          float _661 = _658 * (User.c[4].w);
          float _662 = _660 + _661;
          float _663 = _659 * _659;
          float _664 = _663 * _659;
          float _665 = _664 - _659;
          float _666 = _665 * (User.c[3].z);
          float _667 = _658 * _658;
          float _668 = _667 * _658;
          float _669 = _668 - _658;
          float _670 = _669 * (User.c[3].w);
          float _671 = _666 + _670;
          float _672 = _656 * _656;
          float _673 = _672 * 0.1666666716337204f;
          float _674 = _673 * _671;
          float _675 = _662 + _674;
          _693 = _675;
        } else {
          float _677 = 1.0f - (User.c[4].z);
          float _678 = _624 - (User.c[4].z);
          float _679 = max(9.999999974752427e-07f, _677);
          float _680 = _678 / _679;
          float _681 = 1.0f - _680;
          float _682 = _681 * (User.c[4].w);
          float _683 = _682 + _680;
          float _684 = _681 * _681;
          float _685 = _684 * _681;
          float _686 = _685 - _681;
          float _687 = _677 * _677;
          float _688 = _687 * 0.1666666716337204f;
          float _689 = _688 * (User.c[3].w);
          float _690 = _689 * _686;
          float _691 = _683 + _690;
          _693 = _691;
        }
      }
      float _694 = saturate(_693);
      bool _695 = !(_625 <= (User.c[4].x));
      if (!_695) {
        float _697 = max(9.999999974752427e-07f, (User.c[4].x));
        float _698 = _625 / _697;
        float _699 = _698 * (User.c[4].y);
        float _700 = _698 * _698;
        float _701 = _700 * _698;
        float _702 = _701 - _698;
        float _703 = (User.c[3].z) * 0.1666666716337204f;
        float _704 = _697 * _697;
        float _705 = _704 * _703;
        float _706 = _705 * _702;
        float _707 = _706 + _699;
        _749 = _707;
      } else {
        bool _709 = !(_625 <= (User.c[4].z));
        if (!_709) {
          float _711 = (User.c[4].z) - (User.c[4].x);
          float _712 = max(9.999999974752427e-07f, _711);
          float _713 = _625 - (User.c[4].x);
          float _714 = _713 / _712;
          float _715 = 1.0f - _714;
          float _716 = _715 * (User.c[4].y);
          float _717 = _714 * (User.c[4].w);
          float _718 = _716 + _717;
          float _719 = _715 * _715;
          float _720 = _719 * _715;
          float _721 = _720 - _715;
          float _722 = _721 * (User.c[3].z);
          float _723 = _714 * _714;
          float _724 = _723 * _714;
          float _725 = _724 - _714;
          float _726 = _725 * (User.c[3].w);
          float _727 = _722 + _726;
          float _728 = _712 * _712;
          float _729 = _728 * 0.1666666716337204f;
          float _730 = _729 * _727;
          float _731 = _718 + _730;
          _749 = _731;
        } else {
          float _733 = 1.0f - (User.c[4].z);
          float _734 = _625 - (User.c[4].z);
          float _735 = max(9.999999974752427e-07f, _733);
          float _736 = _734 / _735;
          float _737 = 1.0f - _736;
          float _738 = _737 * (User.c[4].w);
          float _739 = _738 + _736;
          float _740 = _737 * _737;
          float _741 = _740 * _737;
          float _742 = _741 - _737;
          float _743 = _733 * _733;
          float _744 = _743 * 0.1666666716337204f;
          float _745 = _744 * (User.c[3].w);
          float _746 = _745 * _742;
          float _747 = _739 + _746;
          _749 = _747;
        }
      }
      float _750 = saturate(_749);
      bool _751 = !(_626 <= (User.c[4].x));
      if (!_751) {
        float _753 = max(9.999999974752427e-07f, (User.c[4].x));
        float _754 = _626 / _753;
        float _755 = _754 * (User.c[4].y);
        float _756 = _754 * _754;
        float _757 = _756 * _754;
        float _758 = _757 - _754;
        float _759 = (User.c[3].z) * 0.1666666716337204f;
        float _760 = _753 * _753;
        float _761 = _760 * _759;
        float _762 = _761 * _758;
        float _763 = _762 + _755;
        _805 = _763;
      } else {
        bool _765 = !(_626 <= (User.c[4].z));
        if (!_765) {
          float _767 = (User.c[4].z) - (User.c[4].x);
          float _768 = max(9.999999974752427e-07f, _767);
          float _769 = _626 - (User.c[4].x);
          float _770 = _769 / _768;
          float _771 = 1.0f - _770;
          float _772 = _771 * (User.c[4].y);
          float _773 = _770 * (User.c[4].w);
          float _774 = _772 + _773;
          float _775 = _771 * _771;
          float _776 = _775 * _771;
          float _777 = _776 - _771;
          float _778 = _777 * (User.c[3].z);
          float _779 = _770 * _770;
          float _780 = _779 * _770;
          float _781 = _780 - _770;
          float _782 = _781 * (User.c[3].w);
          float _783 = _778 + _782;
          float _784 = _768 * _768;
          float _785 = _784 * 0.1666666716337204f;
          float _786 = _785 * _783;
          float _787 = _774 + _786;
          _805 = _787;
        } else {
          float _789 = 1.0f - (User.c[4].z);
          float _790 = _626 - (User.c[4].z);
          float _791 = max(9.999999974752427e-07f, _789);
          float _792 = _790 / _791;
          float _793 = 1.0f - _792;
          float _794 = _793 * (User.c[4].w);
          float _795 = _794 + _792;
          float _796 = _793 * _793;
          float _797 = _796 * _793;
          float _798 = _797 - _793;
          float _799 = _789 * _789;
          float _800 = _799 * 0.1666666716337204f;
          float _801 = _800 * (User.c[3].w);
          float _802 = _801 * _798;
          float _803 = _795 + _802;
          _805 = _803;
        }
      }
      float _806 = saturate(_805);
      _808 = _694;
      _809 = _750;
      _810 = _806;
    } else {
      _808 = _624;
      _809 = _625;
      _810 = _626;
    }
    int _811 = _628 & 2;
    bool _812 = (_811 == 0);
    if (!_812) {
      float _814 = sqrt(_808);
      float _815 = sqrt(_809);
      float _816 = sqrt(_810);
      float _817 = dot(float3(_814, _815, _816), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _818 = 1.0f - _817;
      float _819 = saturate(_818);
      _821 = _819;
    } else {
      _821 = 1.0f;
    }
    int _822 = _628 & 8;
    bool _823 = (_822 == 0);
    if (!_823) {
      bool _825 = (_821 <= 0.0031308000907301903f);
      float _826 = _821 * 12.920000076293945f;
      float _827 = log2(_821);
      float _828 = _827 * 0.4166666567325592f;
      float _829 = exp2(_828);
      float _830 = _829 * 1.0549999475479126f;
      float _831 = _830 + -0.054999999701976776f;
      float _832 = select(_825, _826, _831);
      _1069 = _832;
      _1070 = _832;
      _1071 = _832;
    } else {
      int _834 = _628 & 4;
      bool _835 = (_834 == 0);
      if (!_835) {
        int _837 = _628 & 16;
        bool _838 = (_837 == 0);
        if (!_838) {
          float _842 = (User.c[5].x) * 0.5f;
          float _843 = _842 + 0.5f;
          bool _844 = (_843 < 0.5f);
          float _845 = (User.c[5].x) * 5.0f;
          float _846 = select(_844, (User.c[5].x), _845);
          bool _847 = (_809 < _810);
          float _848 = select(_847, _810, _809);
          float _849 = select(_847, _809, _810);
          bool _850 = (_808 < _848);
          float _851 = select(_850, _848, _808);
          float _852 = select(_850, _808, _848);
          float _853 = min(_852, _849);
          float _854 = _851 - _853;
          float _855 = _851 + 1.000000013351432e-10f;
          float _856 = _854 / _855;
          float _858 = _856 - (User.c[5].y);
          float _859 = saturate(_858);
          float _860 = max(_859, 9.999999974752427e-07f);
          float _861 = log2(_860);
          float _862 = _861 * _846;
          float _863 = exp2(_862);
          float _864 = 2.0f - _863;
          float _866 = 1.0f - (User.c[5].z);
          float _867 = saturate(_866);
          float _868 = max(_867, _864);
          float _869 = dot(float3(_808, _809, _810), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _870 = _808 - _869;
          float _871 = _809 - _869;
          float _872 = _810 - _869;
          float _873 = _870 * _868;
          float _874 = _871 * _868;
          float _875 = _872 * _868;
          float _876 = _869 - _808;
          float _877 = _876 + _873;
          float _878 = _869 - _809;
          float _879 = _878 + _874;
          float _880 = _869 - _810;
          float _881 = _880 + _875;
          float _882 = _877 * _821;
          float _883 = _879 * _821;
          float _884 = _881 * _821;
          float _885 = _882 + _808;
          float _886 = _883 + _809;
          float _887 = _884 + _810;
          _1001 = _885;
          _1002 = _886;
          _1003 = _887;
        } else {
          bool _889 = (_821 == 0.0f);
          if (!_889) {
            float _893 = abs(User.c[5].x);
            float _894 = saturate(_893);
            uint2 _895; s15.GetDimensions(_895.x, _895.y);
            float _898 = float((uint)_895.y);
            int _899 = _628 & 32;
            bool _900 = (_899 == 0);
            float _901 = _898 + -1.0f;
            if (!_900) {
              float _903 = 1.0f / _901;
              uint _904 = uint(SV_Position.x);
              uint _905 = uint(SV_Position.y);
              int _906 = _904 & 63;
              int _907 = _905 & 63;
              float4 _908 = sBlueNoiseR8G8.Load(int4(_906, _907, 0, 0));
              float _911 = _908.x + -0.5f;
              float _912 = _808 * 13.999999046325684f;
              float _913 = _809 * 13.999999046325684f;
              float _914 = _810 * 13.999999046325684f;
              float _915 = saturate(_912);
              float _916 = saturate(_913);
              float _917 = saturate(_914);
              float _918 = _808 + -0.9285714030265808f;
              float _919 = _809 + -0.9285714030265808f;
              float _920 = _810 + -0.9285714030265808f;
              float _921 = _918 * 13.999999046325684f;
              float _922 = _919 * 13.999999046325684f;
              float _923 = _920 * 13.999999046325684f;
              float _924 = saturate(_921);
              float _925 = saturate(_922);
              float _926 = saturate(_923);
              float _927 = 1.0f - _924;
              float _928 = 1.0f - _925;
              float _929 = 1.0f - _926;
              float _930 = min(_915, _927);
              float _931 = min(_916, _928);
              float _932 = min(_917, _929);
              float _933 = _908.y + -0.5f;
              float _934 = _930 * _933;
              float _935 = _931 * _933;
              float _936 = _932 * _933;
              float _937 = _934 + _911;
              float _938 = _935 + _911;
              float _939 = _936 + _911;
              float _940 = _937 * _903;
              float _941 = _938 * _903;
              float _942 = _939 * _903;
              float _943 = _940 + _808;
              float _944 = _941 + _809;
              float _945 = _942 + _810;
              float _946 = saturate(_943);
              float _947 = saturate(_944);
              float _948 = saturate(_945);
              float _949 = saturate(_946);
              float _950 = saturate(_947);
              float _951 = saturate(_948);
              _953 = _949;
              _954 = _950;
              _955 = _951;
            } else {
              _953 = _808;
              _954 = _809;
              _955 = _810;
            }
            float _956 = float((uint)_895.x);
            float _957 = _901 / _956;
            float _958 = _957 * _953;
            float _959 = 0.5f / _956;
            float _960 = _958 + _959;
            float _961 = _901 / _898;
            float _962 = _961 * _954;
            float _963 = 0.5f / _898;
            float _964 = _962 + _963;
            float _965 = _955 * _901;
            float _966 = floor(_965);
            float _967 = frac(_965);
            float _968 = _966 / _898;
            float _969 = _968 + _960;
            float _970 = _966 + 1.0f;
            float _971 = _970 / _898;
            float _972 = _971 + _960;
            float4 _973 = s15.Sample(s15Sampler, float2(_969, _964));
            float4 _977 = s15.Sample(s15Sampler, float2(_972, _964));
            float _981 = _977.x - _973.x;
            float _982 = _977.y - _973.y;
            float _983 = _977.z - _973.z;
            float _984 = _981 * _967;
            float _985 = _982 * _967;
            float _986 = _983 * _967;
            float _987 = _894 * _821;
            float _988 = _973.x - _808;
            float _989 = _988 + _984;
            float _990 = _973.y - _809;
            float _991 = _990 + _985;
            float _992 = _973.z - _810;
            float _993 = _992 + _986;
            float _994 = _989 * _987;
            float _995 = _991 * _987;
            float _996 = _993 * _987;
            float _997 = _994 + _808;
            float _998 = _995 + _809;
            float _999 = _996 + _810;
            _1001 = _997;
            _1002 = _998;
            _1003 = _999;
          } else {
            _1001 = _808;
            _1002 = _809;
            _1003 = _810;
          }
        }
      } else {
        _1001 = _808;
        _1002 = _809;
        _1003 = _810;
      }
      bool _1004 = (_1001 <= 0.040449999272823334f);
      bool _1005 = (_1002 <= 0.040449999272823334f);
      bool _1006 = (_1003 <= 0.040449999272823334f);
      float _1007 = _1001 * 0.07739938050508499f;
      float _1008 = _1002 * 0.07739938050508499f;
      float _1009 = _1003 * 0.07739938050508499f;
      float _1010 = _1001 + 0.054999999701976776f;
      float _1011 = _1002 + 0.054999999701976776f;
      float _1012 = _1003 + 0.054999999701976776f;
      float _1013 = _1010 * 0.9478673338890076f;
      float _1014 = _1011 * 0.9478673338890076f;
      float _1015 = _1012 * 0.9478673338890076f;
      float _1016 = log2(_1013);
      float _1017 = log2(_1014);
      float _1018 = log2(_1015);
      float _1019 = _1016 * 2.4000000953674316f;
      float _1020 = _1017 * 2.4000000953674316f;
      float _1021 = _1018 * 2.4000000953674316f;
      float _1022 = exp2(_1019);
      float _1023 = exp2(_1020);
      float _1024 = exp2(_1021);
      float _1025 = select(_1004, _1007, _1022);
      float _1026 = select(_1005, _1008, _1023);
      float _1027 = select(_1006, _1009, _1024);
      bool _1028 = (_1025 == 1.0f);
      if (!_1028) {
        float _1030 = _1025 * _1025;
        float _1031 = _1030 * 3.0f;
        float _1032 = _1025 * 2.0f;
        float _1033 = _1032 + 1.0f;
        float _1034 = _1033 - _1031;
        float _1035 = sqrt(_1034);
        float _1036 = _1025 + -1.0f;
        float _1037 = _1036 * 2.0f;
        float _1038 = _1035 / _1037;
        float _1039 = -0.5f - _1038;
        _1041 = _1039;
      } else {
        _1041 = 1e+06f;
      }
      bool _1042 = (_1026 == 1.0f);
      if (!_1042) {
        float _1044 = _1026 * _1026;
        float _1045 = _1044 * 3.0f;
        float _1046 = _1026 * 2.0f;
        float _1047 = _1046 + 1.0f;
        float _1048 = _1047 - _1045;
        float _1049 = sqrt(_1048);
        float _1050 = _1026 + -1.0f;
        float _1051 = _1050 * 2.0f;
        float _1052 = _1049 / _1051;
        float _1053 = -0.5f - _1052;
        _1055 = _1053;
      } else {
        _1055 = 1e+06f;
      }
      bool _1056 = (_1027 == 1.0f);
      if (!_1056) {
        float _1058 = _1027 * _1027;
        float _1059 = _1058 * 3.0f;
        float _1060 = _1027 * 2.0f;
        float _1061 = _1060 + 1.0f;
        float _1062 = _1061 - _1059;
        float _1063 = sqrt(_1062);
        float _1064 = _1027 + -1.0f;
        float _1065 = _1064 * 2.0f;
        float _1066 = _1063 / _1065;
        float _1067 = -0.5f - _1066;
        _1069 = _1041;
        _1070 = _1055;
        _1071 = _1067;
      } else {
        _1069 = _1041;
        _1070 = _1055;
        _1071 = 1e+06f;
      }
    }
  } else {
    _1069 = _566;
    _1070 = _567;
    _1071 = _568;
  }
  float _1072 = log2(_1069);
  float _1073 = _1072 * 3.0f;
  float _1074 = exp2(_1073);
  float _1075 = _1074 + -1.0f;
  float _1076 = _1069 + -1.0f;
  float _1077 = _1075 / _1076;
  float _1078 = _1077 + -1.0f;
  bool _1079 = !(_1069 == 1.0f);
  float _1080 = _1078 / _1077;
  float _1081 = select(_1079, _1080, 0.6666666865348816f);
  float _1082 = log2(_1070);
  float _1083 = _1082 * 3.0f;
  float _1084 = exp2(_1083);
  float _1085 = _1084 + -1.0f;
  float _1086 = _1070 + -1.0f;
  float _1087 = _1085 / _1086;
  float _1088 = _1087 + -1.0f;
  bool _1089 = !(_1070 == 1.0f);
  float _1090 = _1088 / _1087;
  float _1091 = select(_1089, _1090, 0.6666666865348816f);
  float _1092 = log2(_1071);
  float _1093 = _1092 * 3.0f;
  float _1094 = exp2(_1093);
  float _1095 = _1094 + -1.0f;
  float _1096 = _1071 + -1.0f;
  float _1097 = _1095 / _1096;
  float _1098 = _1097 + -1.0f;
  bool _1099 = !(_1071 == 1.0f);
  float _1100 = _1098 / _1097;
  float _1101 = select(_1099, _1100, 0.6666666865348816f);
  float _1102 = saturate(_1081);
  float _1103 = saturate(_1091);
  float _1104 = saturate(_1101);
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_566, _567, _568),
      float3(_1102, _1103, _1104),
      false);
  _1102 = apt_tonemapped.x;
  _1103 = apt_tonemapped.y;
  _1104 = apt_tonemapped.z;
  bool _1105 = (_1102 <= 0.0031308000907301903f);
  bool _1106 = (_1103 <= 0.0031308000907301903f);
  bool _1107 = (_1104 <= 0.0031308000907301903f);
  float _1108 = _1102 * 12.920000076293945f;
  float _1109 = _1103 * 12.920000076293945f;
  float _1110 = _1104 * 12.920000076293945f;
  float _1111 = log2(_1102);
  float _1112 = log2(_1103);
  float _1113 = log2(_1104);
  float _1114 = _1111 * 0.4166666567325592f;
  float _1115 = _1112 * 0.4166666567325592f;
  float _1116 = _1113 * 0.4166666567325592f;
  float _1117 = exp2(_1114);
  float _1118 = exp2(_1115);
  float _1119 = exp2(_1116);
  float _1120 = _1117 * 1.0549999475479126f;
  float _1121 = _1118 * 1.0549999475479126f;
  float _1122 = _1119 * 1.0549999475479126f;
  float _1123 = _1120 + -0.054999999701976776f;
  float _1124 = _1121 + -0.054999999701976776f;
  float _1125 = _1122 + -0.054999999701976776f;
  float _1126 = select(_1105, _1108, _1123);
  float _1127 = select(_1106, _1109, _1124);
  float _1128 = select(_1107, _1110, _1125);
  int _1131 = asint((Global.c[1].w));
  uint _1132 = uint(SV_Position.x);
  uint _1133 = uint(SV_Position.y);
  int _1134 = _1132 & 63;
  int _1135 = _1133 & 63;
  float4 _1136 = sBlueNoiseR8.Load(int4(_1134, _1135, _1131, 0));
  float _1138 = _1136.x * 0.003921568859368563f;
  float _1139 = _1126 + 0.003921568859368563f;
  float _1140 = _1139 - _1138;
  float _1141 = _1138 + _1127;
  float _1142 = _1138 + _1128;
  SV_Target.x = _1140;
  SV_Target.y = _1141;
  SV_Target.z = _1142;
  SV_Target.w = _112.w;
  if (APTIsPsychoV()) {
    SV_Target.rgb = APTRenderIntermediatePassDithered(
        apt_tonemapped,
        SV_Position.xy);
  }
  return SV_Target;
}
