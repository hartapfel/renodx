Texture2DArray<float4> sBlueNoiseR8 : register(t1);

Texture2DArray<float4> sBlueNoiseR8G8 : register(t10);

Texture2D<float4> s0 : register(t0);

Texture2D<float4> s2 : register(t2);

Texture2D<float4> s4 : register(t4);

Texture2D<float4> s5 : register(t5);

Texture2D<float4> s6 : register(t6);

Texture2D<float4> s7 : register(t7);

Texture2D<float4> s8 : register(t8);

Texture2D<float4> s9 : register(t9);

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

SamplerState s9Sampler : register(s9);

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
  int _41 = asint((Global.c[43].w));
  float4 _42 = s14.Sample(s14Sampler, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _46 = sPlagueFX_MaskLayer.Sample(s13Sampler, float2(TEXCOORD.z, TEXCOORD.w));
  float _48 = _46.y * 0.10000000149011612f;
  float _49 = _48 + _42.y;
  float _50 = _46.y * 0.5f;
  float _51 = _50 + _42.z;
  float _52 = exp2(_51);
  float _53 = _52 + -1.0f;
  float _56 = (PostProcess.Settings[11].y) * _53;
  float _57 = _56 + 1.0f;
  float _58 = log2(_57);
  float _59 = _42.x + TEXCOORD.z;
  float _60 = _49 + TEXCOORD.w;
  float _61 = _42.x + TEXCOORD.x;
  float _62 = _49 + TEXCOORD.y;
  float4 _63 = s0.SampleLevel(s0Sampler, float2(_59, _60), _58);
  float _68 = max(_63.x, 0.0f);
  float _69 = max(_63.y, 0.0f);
  float _70 = max(_63.z, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_68, _69, _70),
      max(_63.rgb, 0.f.xxx),
      float2(_59, _60),
      s0,
      s0Sampler,
      _58);
  _68 = renodx_chromatic_aberration_input.x;
  _69 = renodx_chromatic_aberration_input.y;
  _70 = renodx_chromatic_aberration_input.z;
  float _73 = (Global.c[32].w) * 11.0f;
  float _74 = _73 + -1.2000000476837158f;
  float _75 = saturate(_74);
  float _76 = (Global.c[32].w) * 1.7000000476837158f;
  float _77 = 1.340000033378601f - _76;
  float _78 = saturate(_77);
  float _79 = _78 * _78;
  float _80 = _79 * _79;
  float _81 = _80 * _75;
  bool _82 = ((Global.c[32].w) < 9.999999747378752e-06f);
  float _85 = max((Global.c[33].y), _81);
  float _86 = _59 * 2.0f;
  float _87 = _60 * 1.7999999523162842f;
  float _88 = _86 + -1.0f;
  float _89 = _87 + -1.100000023841858f;
  float _90 = abs(_88);
  float _91 = abs(_89);
  float _92 = dot(float2(_90, _91), float2(_90, _91));
  float _93 = sqrt(_92);
  float _94 = select(_82, 1.0f, 0.0f);
  float _95 = _94 * _85;
  float4 _96 = s0.SampleLevel(s0Sampler, float2(_59, _60), 1.0f);
  float4 _100 = s0.SampleLevel(s0Sampler, float2(_59, _60), 2.0f);
  float4 _104 = s0.SampleLevel(s0Sampler, float2(_59, _60), 3.0f);
  float _108 = _92 * 1.7000000476837158f;
  float _109 = _108 + -0.6000000238418579f;
  float _110 = saturate(_109);
  float _111 = _92 * 1.475000023841858f;
  float _112 = _111 + -0.375f;
  float _113 = saturate(_112);
  float _114 = _92 * 1.2999999523162842f;
  float _115 = _114 + -0.15000000596046448f;
  float _116 = saturate(_115);
  float _117 = _104.x - _100.x;
  float _118 = _104.y - _100.y;
  float _119 = _104.z - _100.z;
  float _120 = _117 * _110;
  float _121 = _118 * _110;
  float _122 = _119 * _110;
  float _123 = _100.x - _96.x;
  float _124 = _123 + _120;
  float _125 = _100.y - _96.y;
  float _126 = _125 + _121;
  float _127 = _100.z - _96.z;
  float _128 = _127 + _122;
  float _129 = _124 * _113;
  float _130 = _126 * _113;
  float _131 = _128 * _113;
  float _132 = _116 * _95;
  float _133 = _96.x - _68;
  float _134 = _133 + _129;
  float _135 = _96.y - _69;
  float _136 = _135 + _130;
  float _137 = _96.z - _70;
  float _138 = _137 + _131;
  float _139 = _134 * _132;
  float _140 = _136 * _132;
  float _141 = _138 * _132;
  float _142 = _139 + _68;
  float _143 = _140 + _69;
  float _144 = _141 + _70;
  float4 _145 = s12_bloom.Sample(s12_bloomSampler, float2(_59, _60));
  float4 _149 = s8.Sample(s8Sampler, float2(_61, _62));
  float _156 = (PostProcess.Settings[4].w) * _149.x;
  float _157 = (PostProcess.Settings[4].w) * _149.y;
  float _158 = (PostProcess.Settings[4].w) * _149.z;
  float _159 = _156 + (PostProcess.Settings[4].z);
  float _160 = _157 + (PostProcess.Settings[4].z);
  float _161 = _158 + (PostProcess.Settings[4].z);
  float _162 = saturate(_159);
  float _163 = saturate(_160);
  float _164 = saturate(_161);
  float _165 = _145.x - _142;
  float _166 = _145.y - _143;
  float _167 = _145.z - _144;
  float _168 = _162 * _165;
  float _169 = _163 * _166;
  float _170 = _164 * _167;
  float _171 = _168 + _142;
  float _172 = _169 + _143;
  float _173 = _170 + _144;
  bool _176 = ((User.c[6].y) > 0.0f);
  float _309;
  float _341;
  float _342;
  float _343;
  float _457;
  float _458;
  float _459;
  float _708;
  float _764;
  float _820;
  float _823;
  float _824;
  float _825;
  float _836;
  float _968;
  float _969;
  float _970;
  float _1016;
  float _1017;
  float _1018;
  float _1056;
  float _1070;
  float _1084;
  float _1085;
  float _1086;
  [branch]
  if (_176) {
    float4 _178 = s4.Sample(s4Sampler, float2(TEXCOORD.x, TEXCOORD.y));
    float4 _183 = s5.Sample(s5Sampler, float2(TEXCOORD.x, TEXCOORD.y));
    float _187 = (PostProcess.Settings[6].x) * _183.x;
    float _191 = _187 * (PostProcess.Settings[7].x);
    float _192 = _187 * (PostProcess.Settings[7].y);
    float _193 = _191 + TEXCOORD.x;
    float _194 = _192 + TEXCOORD.y;
    float4 _195 = s4.Sample(s4Sampler, float2(_193, _194));
    float4 _197 = s5.Sample(s5Sampler, float2(_193, _194));
    float _199 = (PostProcess.Settings[6].x) * _197.x;
    float _200 = abs(_199);
    float _202 = _200 / (PostProcess.Settings[7].w);
    float _203 = _195.z - _178.z;
    float _204 = _202 * _203;
    float _205 = _178.x - _171;
    float _206 = _178.y - _172;
    float _207 = _178.z - _173;
    float _208 = _207 + _204;
    float _209 = _205 * _178.w;
    float _210 = _206 * _178.w;
    float _211 = _208 * _178.w;
    _341 = _209;
    _342 = _210;
    _343 = _211;
  } else {
    bool _214 = ((User.c[6].x) > 0.0f);
    [branch]
    if (_214) {
      float4 _216 = s7.Sample(s7Sampler, float2(TEXCOORD.x, TEXCOORD.y));
      float _218 = abs(_216.x);
      _309 = _218;
    } else {
      float4 _220 = s2.SampleLevel(s2Sampler, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
      float _222 = TEXCOORD.x * 2.0f;
      float _223 = TEXCOORD.y * 2.0f;
      float _224 = _222 + -1.0f;
      float _225 = _223 + -1.0f;
      uint _226 = _41 << 5;
      uint _227 = _226 + 112u;
      uint _230 = _226 + 113u;
      uint _233 = _226 + 114u;
      uint _236 = _226 + 115u;
      float _251 = (Global.c[_227].x) * _224;
      float _252 = mad(_225, (Global.c[_227].y), _251);
      float _253 = mad(_220.x, (Global.c[_227].z), _252);
      float _254 = _253 + (Global.c[_227].w);
      float _255 = (Global.c[_230].x) * _224;
      float _256 = mad(_225, (Global.c[_230].y), _255);
      float _257 = mad(_220.x, (Global.c[_230].z), _256);
      float _258 = _257 + (Global.c[_230].w);
      float _259 = (Global.c[_233].x) * _224;
      float _260 = mad(_225, (Global.c[_233].y), _259);
      float _261 = mad(_220.x, (Global.c[_233].z), _260);
      float _262 = _261 + (Global.c[_233].w);
      float _263 = (Global.c[_236].x) * _224;
      float _264 = mad(_225, (Global.c[_236].y), _263);
      float _265 = mad(_220.x, (Global.c[_236].z), _264);
      float _266 = _265 + (Global.c[_236].w);
      float _267 = _254 / _266;
      float _268 = _258 / _266;
      float _269 = _262 / _266;
      float _270 = _267 * _267;
      float _271 = _268 * _268;
      float _272 = _271 + _270;
      float _273 = _269 * _269;
      float _274 = _272 + _273;
      float _275 = sqrt(_274);
      float4 _276 = s5.Sample(s5Sampler, float2(TEXCOORD.x, TEXCOORD.y));
      float _282 = (PostProcess.Settings[6].w) * (PostProcess.Settings[5].x);
      float _283 = _282 + (PostProcess.Settings[5].x);
      float _284 = (PostProcess.Settings[5].x) - _282;
      float _285 = max(_275, _284);
      float _286 = min(_285, _283);
      float _288 = _275 - _286;
      float _289 = (PostProcess.Settings[5].w) * _288;
      float _291 = _286 - (PostProcess.Settings[5].y);
      float _292 = _291 * _275;
      float _293 = _289 / _292;
      float _294 = min(_293, 0.0f);
      float _297 = (PostProcess.Settings[7].z) * _294;
      float _298 = _282 + 1.0f;
      float _299 = 1.0f / _298;
      float _300 = _297 * _299;
      float _301 = max(0.0f, _293);
      float _302 = _300 + _301;
      float _303 = min(_276.x, _302);
      float _304 = abs(_303);
      float _305 = abs(_302);
      float _306 = max(_304, _305);
      float _307 = saturate(_306);
      _309 = _307;
    }
    float _312 = (PostProcess.Settings[6].x) * _309;
    float4 _313 = s4.Sample(s4Sampler, float2(TEXCOORD.x, TEXCOORD.y));
    float _320 = (PostProcess.Settings[7].x) * _312;
    float _321 = (PostProcess.Settings[7].y) * _312;
    float _322 = _320 + TEXCOORD.x;
    float _323 = _321 + TEXCOORD.y;
    float4 _324 = s4.Sample(s4Sampler, float2(_322, _323));
    float4 _326 = s5.Sample(s5Sampler, float2(_322, _323));
    float _328 = abs(_326.x);
    float _329 = _324.z - _313.z;
    float _330 = _328 * _329;
    float _331 = _312 + -1.0f;
    float _332 = saturate(_331);
    float _333 = _313.x - _171;
    float _334 = _313.y - _172;
    float _335 = _313.z - _173;
    float _336 = _335 + _330;
    float _337 = _332 * _333;
    float _338 = _332 * _334;
    float _339 = _336 * _332;
    _341 = _337;
    _342 = _338;
    _343 = _339;
  }
  float _344 = _341 + _171;
  float _345 = _342 + _172;
  float _346 = _343 + _173;
  float4 _347 = s6.Load(int3(0, 0, 0));
  float _351 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _352 = _344 * 11190.6005859375f;
  float _353 = _352 * _347.x;
  float _354 = _353 * _351;
  float _355 = _345 * 11190.6005859375f;
  float _356 = _355 * _347.x;
  float _357 = _356 * _351;
  float _358 = _346 * 11190.6005859375f;
  float _359 = _358 * _347.x;
  float _360 = _359 * _351;
  float _361 = _354 + 1.0f;
  float _362 = _357 + 1.0f;
  float _363 = _360 + 1.0f;
  float _364 = log2(_361);
  float _365 = log2(_362);
  float _366 = log2(_363);
  float _367 = _364 * 0.07434873282909393f;
  float _368 = _365 * 0.07434873282909393f;
  float _369 = _366 * 0.07434873282909393f;
  float _372 = _367 * (PostProcess.OffsetWeight[0].x);
  float _373 = _368 * (PostProcess.OffsetWeight[0].x);
  float _374 = _369 * (PostProcess.OffsetWeight[0].x);
  float _376 = _372 + (PostProcess.OffsetWeight[0].y);
  float _377 = _373 + (PostProcess.OffsetWeight[0].y);
  float _378 = _374 + (PostProcess.OffsetWeight[0].y);
  float4 _379 = s3_3D.Sample(s3_3DSampler, float3(_376, _377, _378));
  float _385 = _379.x * 13.450128555297852f;
  float _386 = _379.y * 13.450128555297852f;
  float _387 = _379.z * 13.450128555297852f;
  float _388 = exp2(_385);
  float _389 = exp2(_386);
  float _390 = exp2(_387);
  float _391 = _388 + -1.0f;
  float _392 = _389 + -1.0f;
  float _393 = _390 + -1.0f;
  float _394 = _391 * 8.936070662457496e-05f;
  float _395 = _392 * 8.936070662457496e-05f;
  float _396 = _393 * 8.936070662457496e-05f;
  float _397 = 10000.0f / (PostProcess.Settings[10].w);
  float _398 = _394 * _397;
  float _399 = _395 * _397;
  float _400 = _396 * _397;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUT(
      float3(_354, _357, _360) / apt_lut_input_encode_scale,
      float3(_398, _399, _400));
  apt_lut_output = APTApplyPerceptualFilmGrain(apt_lut_output, SV_Position.xy);
  _398 = apt_lut_output.x;
  _399 = apt_lut_output.y;
  _400 = apt_lut_output.z;
  float _401 = dot(float3(_398, _399, _400), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _405 = (PostProcess.Settings[9].x) * TEXCOORD.x;
  float _406 = (PostProcess.Settings[9].y) * TEXCOORD.y;
  float _409 = _405 + (PostProcess.Settings[9].z);
  float _410 = _406 + (PostProcess.Settings[9].w);
  float4 _411 = s9.Sample(s9Sampler, float2(_409, _410));
  bool _417 = ((PostProcess.Settings[10].y) > 0.0f);
  uint _418 = uint(SV_Position.x);
  uint _419 = uint(SV_Position.y);
  int _420 = _418 & 63;
  int _421 = _419 & 63;
  if (_417) {
    bool _424 = ((PostProcess.Settings[10].x) > 0.0f);
    int _427 = asint((Global.c[1].w));
    int _428 = select(_424, _427, 0);
    float4 _429 = sBlueNoiseR8G8.Load(int4(_420, _421, _428, 0));
    float _432 = _429.x * -2.0f;
    float _433 = _429.x * 2.0f;
    float _434 = _432 * _429.y;
    float _435 = _433 * _429.y;
    float _436 = _434 + _429.x;
    float _437 = _435 - _429.x;
    _457 = _436;
    _458 = _437;
    _459 = _437;
  } else {
    float4 _439 = sBlueNoiseR8.Load(int4(_420, _421, 0, 0));
    float _441 = _439.x - _411.x;
    float _442 = _439.x - _411.y;
    float _443 = _439.x - _411.z;
    float _444 = _441 * 0.5f;
    float _445 = _442 * 0.5f;
    float _446 = _443 * 0.5f;
    float _447 = _444 + _411.x;
    float _448 = _445 + _411.y;
    float _449 = _446 + _411.z;
    float _450 = _447 * 2.0f;
    float _451 = _448 * 2.0f;
    float _452 = _449 * 2.0f;
    float _453 = _450 + -1.0f;
    float _454 = _451 + -1.0f;
    float _455 = _452 + -1.0f;
    _457 = _453;
    _458 = _454;
    _459 = _455;
  }
  float _460 = _401 + 1.0f;
  float _461 = _401 / _460;
  float _462 = _461 + -9.999999747378752e-05f;
  float _463 = _462 * 1111.111083984375f;
  float _464 = saturate(_463);
  float _465 = _464 * 2.0f;
  float _466 = 3.0f - _465;
  float _467 = _464 * _464;
  float _468 = _467 * _466;
  float _472 = (PostProcess.Settings[2].y) - (PostProcess.Settings[2].x);
  float _473 = _472 * _461;
  float _474 = _473 + (PostProcess.Settings[2].x);
  float _475 = _468 * _457;
  float _476 = _475 * _474;
  float _477 = _468 * _458;
  float _478 = _477 * _474;
  float _479 = _468 * _459;
  float _480 = _479 * _474;
  float _481 = _476 + _398;
  float _482 = _478 + _399;
  float _483 = _480 + _400;
  float _484 = max(0.0f, _481);
  float _485 = max(0.0f, _482);
  float _486 = max(0.0f, _483);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_484, _485, _486),
      apt_lut_output);
  _484 = apt_film_grain_output.x;
  _485 = apt_film_grain_output.y;
  _486 = apt_film_grain_output.z;
  float _490 = (User.c[2].y) / (User.c[2].x);
  int _493 = asint((Global.c[1].w));
  uint _494 = _493 + 30u;
  int _495 = _494 & 63;
  float _496 = _59 * 8.0f;
  float _497 = _496 * _490;
  float _498 = _60 * 8.0f;
  float _499 = float((int)(_493));
  float4 _500 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_497, _498, _499), 0.0f);
  float _502 = _59 + 0.5f;
  float _503 = (User.c[2].x) * 0.5f;
  float _504 = _502 + _503;
  float _505 = _490 * 8.0f;
  float _506 = _505 * _504;
  float _507 = _60 + 0.5f;
  float _508 = (User.c[2].y) * 0.5f;
  float _509 = _507 + _508;
  float _510 = _509 * 8.0f;
  float _511 = float((int)(_495));
  float4 _512 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_506, _510, _511), 0.0f);
  float _514 = _512.x + _500.x;
  float _515 = _514 * 0.714285671710968f;
  float _516 = _515 + -0.2142857164144516f;
  float _517 = saturate(_516);
  float _518 = _517 * 2.0f;
  float _519 = 3.0f - _518;
  float _520 = _517 * _517;
  float _521 = _520 * _519;
  float _522 = _521 * 0.5f;
  float _523 = _521 * 0.4000000059604645f;
  float _524 = _521 * 0.05000000074505806f;
  float _525 = _522 + -0.5f;
  float _526 = _523 + -0.6000000238418579f;
  float _527 = _524 + -0.949999988079071f;
  float _528 = _525 * _95;
  float _529 = _526 * _95;
  float _530 = _527 * _95;
  float _531 = _528 + 1.0f;
  float _532 = _529 + 1.0f;
  float _533 = _530 + 1.0f;
  float _534 = _531 * _484;
  float _535 = _532 * _485;
  float _536 = _533 * _486;
  float4 _537 = s13.Sample(s13Sampler, float2(_59, _60));
  float _544 = _110 + 1.0f;
  float _545 = saturate(_544);
  float _546 = (User.c[2].x) * _545;
  float _547 = (User.c[2].y) * _545;
  float _548 = _546 + _59;
  float _549 = _547 + _60;
  float4 _550 = s13.Sample(s13Sampler, float2(_548, _549));
  float _554 = _550.x + _537.x;
  float _555 = _550.y + _537.y;
  float _556 = _550.z + _537.z;
  float _557 = _555 * 0.5f;
  float _558 = _556 * 0.5f;
  float _559 = _458 * 0.30000001192092896f;
  float _560 = _559 + 0.699999988079071f;
  float _561 = saturate(_560);
  float _562 = _561 * 0.5f;
  float _563 = _562 * _554;
  float _564 = _557 * _561;
  float _565 = _558 * _561;
  float _566 = _95 * 0.6000000238418579f;
  float _567 = _566 * _93;
  float _568 = _95 * 0.7300000190734863f;
  float _569 = _568 * _93;
  float _570 = _95 * 0.8799999952316284f;
  float _571 = _570 * _93;
  float _572 = 1.0f - _567;
  float _573 = 1.0f - _569;
  float _574 = 1.0f - _571;
  float _575 = saturate(_572);
  float _576 = saturate(_573);
  float _577 = saturate(_574);
  float _578 = _534 * _575;
  float _579 = _535 * _576;
  float _580 = _536 * _577;
  float _581 = _578 + _563;
  float _582 = _579 + _564;
  float _583 = _580 + _565;
  bool _586 = ((User.c[3].x) > 0.0f) && !APTIsPsychoV();
  if (_586) {
    float _588 = log2(_581);
    float _589 = _588 * 3.0f;
    float _590 = exp2(_589);
    float _591 = _590 + -1.0f;
    float _592 = _581 + -1.0f;
    float _593 = _591 / _592;
    float _594 = _593 + -1.0f;
    bool _595 = !(_581 == 1.0f);
    float _596 = _594 / _593;
    float _597 = select(_595, _596, 0.6666666865348816f);
    float _598 = log2(_582);
    float _599 = _598 * 3.0f;
    float _600 = exp2(_599);
    float _601 = _600 + -1.0f;
    float _602 = _582 + -1.0f;
    float _603 = _601 / _602;
    float _604 = _603 + -1.0f;
    bool _605 = !(_582 == 1.0f);
    float _606 = _604 / _603;
    float _607 = select(_605, _606, 0.6666666865348816f);
    float _608 = log2(_583);
    float _609 = _608 * 3.0f;
    float _610 = exp2(_609);
    float _611 = _610 + -1.0f;
    float _612 = _583 + -1.0f;
    float _613 = _611 / _612;
    float _614 = _613 + -1.0f;
    bool _615 = !(_583 == 1.0f);
    float _616 = _614 / _613;
    float _617 = select(_615, _616, 0.6666666865348816f);
    bool _618 = (_597 <= 0.0031308000907301903f);
    bool _619 = (_607 <= 0.0031308000907301903f);
    bool _620 = (_617 <= 0.0031308000907301903f);
    float _621 = _597 * 12.920000076293945f;
    float _622 = _607 * 12.920000076293945f;
    float _623 = _617 * 12.920000076293945f;
    float _624 = log2(_597);
    float _625 = log2(_607);
    float _626 = log2(_617);
    float _627 = _624 * 0.4166666567325592f;
    float _628 = _625 * 0.4166666567325592f;
    float _629 = _626 * 0.4166666567325592f;
    float _630 = exp2(_627);
    float _631 = exp2(_628);
    float _632 = exp2(_629);
    float _633 = _630 * 1.0549999475479126f;
    float _634 = _631 * 1.0549999475479126f;
    float _635 = _632 * 1.0549999475479126f;
    float _636 = _633 + -0.054999999701976776f;
    float _637 = _634 + -0.054999999701976776f;
    float _638 = _635 + -0.054999999701976776f;
    float _639 = select(_618, _621, _636);
    float _640 = select(_619, _622, _637);
    float _641 = select(_620, _623, _638);
    int _643 = asint((User.c[3].y));
    int _644 = _643 & 1;
    bool _645 = (_644 == 0);
    if (!_645) {
      bool _654 = !(_639 <= (User.c[4].x));
      if (!_654) {
        float _656 = max(9.999999974752427e-07f, (User.c[4].x));
        float _657 = _639 / _656;
        float _658 = _657 * (User.c[4].y);
        float _659 = _657 * _657;
        float _660 = _659 * _657;
        float _661 = _660 - _657;
        float _662 = (User.c[3].z) * 0.1666666716337204f;
        float _663 = _656 * _656;
        float _664 = _663 * _662;
        float _665 = _664 * _661;
        float _666 = _665 + _658;
        _708 = _666;
      } else {
        bool _668 = !(_639 <= (User.c[4].z));
        if (!_668) {
          float _670 = (User.c[4].z) - (User.c[4].x);
          float _671 = max(9.999999974752427e-07f, _670);
          float _672 = _639 - (User.c[4].x);
          float _673 = _672 / _671;
          float _674 = 1.0f - _673;
          float _675 = _674 * (User.c[4].y);
          float _676 = _673 * (User.c[4].w);
          float _677 = _675 + _676;
          float _678 = _674 * _674;
          float _679 = _678 * _674;
          float _680 = _679 - _674;
          float _681 = _680 * (User.c[3].z);
          float _682 = _673 * _673;
          float _683 = _682 * _673;
          float _684 = _683 - _673;
          float _685 = _684 * (User.c[3].w);
          float _686 = _681 + _685;
          float _687 = _671 * _671;
          float _688 = _687 * 0.1666666716337204f;
          float _689 = _688 * _686;
          float _690 = _677 + _689;
          _708 = _690;
        } else {
          float _692 = 1.0f - (User.c[4].z);
          float _693 = _639 - (User.c[4].z);
          float _694 = max(9.999999974752427e-07f, _692);
          float _695 = _693 / _694;
          float _696 = 1.0f - _695;
          float _697 = _696 * (User.c[4].w);
          float _698 = _697 + _695;
          float _699 = _696 * _696;
          float _700 = _699 * _696;
          float _701 = _700 - _696;
          float _702 = _692 * _692;
          float _703 = _702 * 0.1666666716337204f;
          float _704 = _703 * (User.c[3].w);
          float _705 = _704 * _701;
          float _706 = _698 + _705;
          _708 = _706;
        }
      }
      float _709 = saturate(_708);
      bool _710 = !(_640 <= (User.c[4].x));
      if (!_710) {
        float _712 = max(9.999999974752427e-07f, (User.c[4].x));
        float _713 = _640 / _712;
        float _714 = _713 * (User.c[4].y);
        float _715 = _713 * _713;
        float _716 = _715 * _713;
        float _717 = _716 - _713;
        float _718 = (User.c[3].z) * 0.1666666716337204f;
        float _719 = _712 * _712;
        float _720 = _719 * _718;
        float _721 = _720 * _717;
        float _722 = _721 + _714;
        _764 = _722;
      } else {
        bool _724 = !(_640 <= (User.c[4].z));
        if (!_724) {
          float _726 = (User.c[4].z) - (User.c[4].x);
          float _727 = max(9.999999974752427e-07f, _726);
          float _728 = _640 - (User.c[4].x);
          float _729 = _728 / _727;
          float _730 = 1.0f - _729;
          float _731 = _730 * (User.c[4].y);
          float _732 = _729 * (User.c[4].w);
          float _733 = _731 + _732;
          float _734 = _730 * _730;
          float _735 = _734 * _730;
          float _736 = _735 - _730;
          float _737 = _736 * (User.c[3].z);
          float _738 = _729 * _729;
          float _739 = _738 * _729;
          float _740 = _739 - _729;
          float _741 = _740 * (User.c[3].w);
          float _742 = _737 + _741;
          float _743 = _727 * _727;
          float _744 = _743 * 0.1666666716337204f;
          float _745 = _744 * _742;
          float _746 = _733 + _745;
          _764 = _746;
        } else {
          float _748 = 1.0f - (User.c[4].z);
          float _749 = _640 - (User.c[4].z);
          float _750 = max(9.999999974752427e-07f, _748);
          float _751 = _749 / _750;
          float _752 = 1.0f - _751;
          float _753 = _752 * (User.c[4].w);
          float _754 = _753 + _751;
          float _755 = _752 * _752;
          float _756 = _755 * _752;
          float _757 = _756 - _752;
          float _758 = _748 * _748;
          float _759 = _758 * 0.1666666716337204f;
          float _760 = _759 * (User.c[3].w);
          float _761 = _760 * _757;
          float _762 = _754 + _761;
          _764 = _762;
        }
      }
      float _765 = saturate(_764);
      bool _766 = !(_641 <= (User.c[4].x));
      if (!_766) {
        float _768 = max(9.999999974752427e-07f, (User.c[4].x));
        float _769 = _641 / _768;
        float _770 = _769 * (User.c[4].y);
        float _771 = _769 * _769;
        float _772 = _771 * _769;
        float _773 = _772 - _769;
        float _774 = (User.c[3].z) * 0.1666666716337204f;
        float _775 = _768 * _768;
        float _776 = _775 * _774;
        float _777 = _776 * _773;
        float _778 = _777 + _770;
        _820 = _778;
      } else {
        bool _780 = !(_641 <= (User.c[4].z));
        if (!_780) {
          float _782 = (User.c[4].z) - (User.c[4].x);
          float _783 = max(9.999999974752427e-07f, _782);
          float _784 = _641 - (User.c[4].x);
          float _785 = _784 / _783;
          float _786 = 1.0f - _785;
          float _787 = _786 * (User.c[4].y);
          float _788 = _785 * (User.c[4].w);
          float _789 = _787 + _788;
          float _790 = _786 * _786;
          float _791 = _790 * _786;
          float _792 = _791 - _786;
          float _793 = _792 * (User.c[3].z);
          float _794 = _785 * _785;
          float _795 = _794 * _785;
          float _796 = _795 - _785;
          float _797 = _796 * (User.c[3].w);
          float _798 = _793 + _797;
          float _799 = _783 * _783;
          float _800 = _799 * 0.1666666716337204f;
          float _801 = _800 * _798;
          float _802 = _789 + _801;
          _820 = _802;
        } else {
          float _804 = 1.0f - (User.c[4].z);
          float _805 = _641 - (User.c[4].z);
          float _806 = max(9.999999974752427e-07f, _804);
          float _807 = _805 / _806;
          float _808 = 1.0f - _807;
          float _809 = _808 * (User.c[4].w);
          float _810 = _809 + _807;
          float _811 = _808 * _808;
          float _812 = _811 * _808;
          float _813 = _812 - _808;
          float _814 = _804 * _804;
          float _815 = _814 * 0.1666666716337204f;
          float _816 = _815 * (User.c[3].w);
          float _817 = _816 * _813;
          float _818 = _810 + _817;
          _820 = _818;
        }
      }
      float _821 = saturate(_820);
      _823 = _709;
      _824 = _765;
      _825 = _821;
    } else {
      _823 = _639;
      _824 = _640;
      _825 = _641;
    }
    int _826 = _643 & 2;
    bool _827 = (_826 == 0);
    if (!_827) {
      float _829 = sqrt(_823);
      float _830 = sqrt(_824);
      float _831 = sqrt(_825);
      float _832 = dot(float3(_829, _830, _831), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _833 = 1.0f - _832;
      float _834 = saturate(_833);
      _836 = _834;
    } else {
      _836 = 1.0f;
    }
    int _837 = _643 & 8;
    bool _838 = (_837 == 0);
    if (!_838) {
      bool _840 = (_836 <= 0.0031308000907301903f);
      float _841 = _836 * 12.920000076293945f;
      float _842 = log2(_836);
      float _843 = _842 * 0.4166666567325592f;
      float _844 = exp2(_843);
      float _845 = _844 * 1.0549999475479126f;
      float _846 = _845 + -0.054999999701976776f;
      float _847 = select(_840, _841, _846);
      _1084 = _847;
      _1085 = _847;
      _1086 = _847;
    } else {
      int _849 = _643 & 4;
      bool _850 = (_849 == 0);
      if (!_850) {
        int _852 = _643 & 16;
        bool _853 = (_852 == 0);
        if (!_853) {
          float _857 = (User.c[5].x) * 0.5f;
          float _858 = _857 + 0.5f;
          bool _859 = (_858 < 0.5f);
          float _860 = (User.c[5].x) * 5.0f;
          float _861 = select(_859, (User.c[5].x), _860);
          bool _862 = (_824 < _825);
          float _863 = select(_862, _825, _824);
          float _864 = select(_862, _824, _825);
          bool _865 = (_823 < _863);
          float _866 = select(_865, _863, _823);
          float _867 = select(_865, _823, _863);
          float _868 = min(_867, _864);
          float _869 = _866 - _868;
          float _870 = _866 + 1.000000013351432e-10f;
          float _871 = _869 / _870;
          float _873 = _871 - (User.c[5].y);
          float _874 = saturate(_873);
          float _875 = max(_874, 9.999999974752427e-07f);
          float _876 = log2(_875);
          float _877 = _876 * _861;
          float _878 = exp2(_877);
          float _879 = 2.0f - _878;
          float _881 = 1.0f - (User.c[5].z);
          float _882 = saturate(_881);
          float _883 = max(_882, _879);
          float _884 = dot(float3(_823, _824, _825), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _885 = _823 - _884;
          float _886 = _824 - _884;
          float _887 = _825 - _884;
          float _888 = _885 * _883;
          float _889 = _886 * _883;
          float _890 = _887 * _883;
          float _891 = _884 - _823;
          float _892 = _891 + _888;
          float _893 = _884 - _824;
          float _894 = _893 + _889;
          float _895 = _884 - _825;
          float _896 = _895 + _890;
          float _897 = _892 * _836;
          float _898 = _894 * _836;
          float _899 = _896 * _836;
          float _900 = _897 + _823;
          float _901 = _898 + _824;
          float _902 = _899 + _825;
          _1016 = _900;
          _1017 = _901;
          _1018 = _902;
        } else {
          bool _904 = (_836 == 0.0f);
          if (!_904) {
            float _908 = abs(User.c[5].x);
            float _909 = saturate(_908);
            uint2 _910; s15.GetDimensions(_910.x, _910.y);
            float _913 = float((uint)_910.y);
            int _914 = _643 & 32;
            bool _915 = (_914 == 0);
            float _916 = _913 + -1.0f;
            if (!_915) {
              float _918 = 1.0f / _916;
              uint _919 = uint(SV_Position.x);
              uint _920 = uint(SV_Position.y);
              int _921 = _919 & 63;
              int _922 = _920 & 63;
              float4 _923 = sBlueNoiseR8G8.Load(int4(_921, _922, 0, 0));
              float _926 = _923.x + -0.5f;
              float _927 = _823 * 13.999999046325684f;
              float _928 = _824 * 13.999999046325684f;
              float _929 = _825 * 13.999999046325684f;
              float _930 = saturate(_927);
              float _931 = saturate(_928);
              float _932 = saturate(_929);
              float _933 = _823 + -0.9285714030265808f;
              float _934 = _824 + -0.9285714030265808f;
              float _935 = _825 + -0.9285714030265808f;
              float _936 = _933 * 13.999999046325684f;
              float _937 = _934 * 13.999999046325684f;
              float _938 = _935 * 13.999999046325684f;
              float _939 = saturate(_936);
              float _940 = saturate(_937);
              float _941 = saturate(_938);
              float _942 = 1.0f - _939;
              float _943 = 1.0f - _940;
              float _944 = 1.0f - _941;
              float _945 = min(_930, _942);
              float _946 = min(_931, _943);
              float _947 = min(_932, _944);
              float _948 = _923.y + -0.5f;
              float _949 = _945 * _948;
              float _950 = _946 * _948;
              float _951 = _947 * _948;
              float _952 = _949 + _926;
              float _953 = _950 + _926;
              float _954 = _951 + _926;
              float _955 = _952 * _918;
              float _956 = _953 * _918;
              float _957 = _954 * _918;
              float _958 = _955 + _823;
              float _959 = _956 + _824;
              float _960 = _957 + _825;
              float _961 = saturate(_958);
              float _962 = saturate(_959);
              float _963 = saturate(_960);
              float _964 = saturate(_961);
              float _965 = saturate(_962);
              float _966 = saturate(_963);
              _968 = _964;
              _969 = _965;
              _970 = _966;
            } else {
              _968 = _823;
              _969 = _824;
              _970 = _825;
            }
            float _971 = float((uint)_910.x);
            float _972 = _916 / _971;
            float _973 = _972 * _968;
            float _974 = 0.5f / _971;
            float _975 = _973 + _974;
            float _976 = _916 / _913;
            float _977 = _976 * _969;
            float _978 = 0.5f / _913;
            float _979 = _977 + _978;
            float _980 = _970 * _916;
            float _981 = floor(_980);
            float _982 = frac(_980);
            float _983 = _981 / _913;
            float _984 = _983 + _975;
            float _985 = _981 + 1.0f;
            float _986 = _985 / _913;
            float _987 = _986 + _975;
            float4 _988 = s15.Sample(s15Sampler, float2(_984, _979));
            float4 _992 = s15.Sample(s15Sampler, float2(_987, _979));
            float _996 = _992.x - _988.x;
            float _997 = _992.y - _988.y;
            float _998 = _992.z - _988.z;
            float _999 = _996 * _982;
            float _1000 = _997 * _982;
            float _1001 = _998 * _982;
            float _1002 = _909 * _836;
            float _1003 = _988.x - _823;
            float _1004 = _1003 + _999;
            float _1005 = _988.y - _824;
            float _1006 = _1005 + _1000;
            float _1007 = _988.z - _825;
            float _1008 = _1007 + _1001;
            float _1009 = _1004 * _1002;
            float _1010 = _1006 * _1002;
            float _1011 = _1008 * _1002;
            float _1012 = _1009 + _823;
            float _1013 = _1010 + _824;
            float _1014 = _1011 + _825;
            _1016 = _1012;
            _1017 = _1013;
            _1018 = _1014;
          } else {
            _1016 = _823;
            _1017 = _824;
            _1018 = _825;
          }
        }
      } else {
        _1016 = _823;
        _1017 = _824;
        _1018 = _825;
      }
      bool _1019 = (_1016 <= 0.040449999272823334f);
      bool _1020 = (_1017 <= 0.040449999272823334f);
      bool _1021 = (_1018 <= 0.040449999272823334f);
      float _1022 = _1016 * 0.07739938050508499f;
      float _1023 = _1017 * 0.07739938050508499f;
      float _1024 = _1018 * 0.07739938050508499f;
      float _1025 = _1016 + 0.054999999701976776f;
      float _1026 = _1017 + 0.054999999701976776f;
      float _1027 = _1018 + 0.054999999701976776f;
      float _1028 = _1025 * 0.9478673338890076f;
      float _1029 = _1026 * 0.9478673338890076f;
      float _1030 = _1027 * 0.9478673338890076f;
      float _1031 = log2(_1028);
      float _1032 = log2(_1029);
      float _1033 = log2(_1030);
      float _1034 = _1031 * 2.4000000953674316f;
      float _1035 = _1032 * 2.4000000953674316f;
      float _1036 = _1033 * 2.4000000953674316f;
      float _1037 = exp2(_1034);
      float _1038 = exp2(_1035);
      float _1039 = exp2(_1036);
      float _1040 = select(_1019, _1022, _1037);
      float _1041 = select(_1020, _1023, _1038);
      float _1042 = select(_1021, _1024, _1039);
      bool _1043 = (_1040 == 1.0f);
      if (!_1043) {
        float _1045 = _1040 * _1040;
        float _1046 = _1045 * 3.0f;
        float _1047 = _1040 * 2.0f;
        float _1048 = _1047 + 1.0f;
        float _1049 = _1048 - _1046;
        float _1050 = sqrt(_1049);
        float _1051 = _1040 + -1.0f;
        float _1052 = _1051 * 2.0f;
        float _1053 = _1050 / _1052;
        float _1054 = -0.5f - _1053;
        _1056 = _1054;
      } else {
        _1056 = 1e+06f;
      }
      bool _1057 = (_1041 == 1.0f);
      if (!_1057) {
        float _1059 = _1041 * _1041;
        float _1060 = _1059 * 3.0f;
        float _1061 = _1041 * 2.0f;
        float _1062 = _1061 + 1.0f;
        float _1063 = _1062 - _1060;
        float _1064 = sqrt(_1063);
        float _1065 = _1041 + -1.0f;
        float _1066 = _1065 * 2.0f;
        float _1067 = _1064 / _1066;
        float _1068 = -0.5f - _1067;
        _1070 = _1068;
      } else {
        _1070 = 1e+06f;
      }
      bool _1071 = (_1042 == 1.0f);
      if (!_1071) {
        float _1073 = _1042 * _1042;
        float _1074 = _1073 * 3.0f;
        float _1075 = _1042 * 2.0f;
        float _1076 = _1075 + 1.0f;
        float _1077 = _1076 - _1074;
        float _1078 = sqrt(_1077);
        float _1079 = _1042 + -1.0f;
        float _1080 = _1079 * 2.0f;
        float _1081 = _1078 / _1080;
        float _1082 = -0.5f - _1081;
        _1084 = _1056;
        _1085 = _1070;
        _1086 = _1082;
      } else {
        _1084 = _1056;
        _1085 = _1070;
        _1086 = 1e+06f;
      }
    }
  } else {
    _1084 = _581;
    _1085 = _582;
    _1086 = _583;
  }
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_581, _582, _583),
      float3(_1084, _1085, _1086),
      false);
  _1084 = apt_tonemapped.x;
  _1085 = apt_tonemapped.y;
  _1086 = apt_tonemapped.z;
  bool _1087 = (_1084 <= 0.0031308000907301903f);
  bool _1088 = (_1085 <= 0.0031308000907301903f);
  bool _1089 = (_1086 <= 0.0031308000907301903f);
  float _1090 = _1084 * 12.920000076293945f;
  float _1091 = _1085 * 12.920000076293945f;
  float _1092 = _1086 * 12.920000076293945f;
  float _1093 = log2(_1084);
  float _1094 = log2(_1085);
  float _1095 = log2(_1086);
  float _1096 = _1093 * 0.4166666567325592f;
  float _1097 = _1094 * 0.4166666567325592f;
  float _1098 = _1095 * 0.4166666567325592f;
  float _1099 = exp2(_1096);
  float _1100 = exp2(_1097);
  float _1101 = exp2(_1098);
  float _1102 = _1099 * 1.0549999475479126f;
  float _1103 = _1100 * 1.0549999475479126f;
  float _1104 = _1101 * 1.0549999475479126f;
  float _1105 = _1102 + -0.054999999701976776f;
  float _1106 = _1103 + -0.054999999701976776f;
  float _1107 = _1104 + -0.054999999701976776f;
  float _1108 = select(_1087, _1090, _1105);
  float _1109 = select(_1088, _1091, _1106);
  float _1110 = select(_1089, _1092, _1107);
  float _1111 = log2(_1108);
  float _1112 = log2(_1109);
  float _1113 = log2(_1110);
  float _1114 = floor(_1111);
  float _1115 = floor(_1112);
  float _1116 = floor(_1113);
  float _1117 = _1114 + -6.0f;
  float _1118 = _1115 + -6.0f;
  float _1119 = _1116 + -5.0f;
  float _1120 = exp2(_1117);
  float _1121 = exp2(_1118);
  float _1122 = exp2(_1119);
  uint _1123 = uint(SV_Position.x);
  uint _1124 = uint(SV_Position.y);
  int _1125 = _1123 & 63;
  int _1126 = _1124 & 63;
  float4 _1127 = sBlueNoiseR8.Load(int4(_1125, _1126, 0, 0));
  float _1129 = _1127.x + -0.5f;
  bool _1130 = (_1108 > 0.0f);
  bool _1131 = (_1109 > 0.0f);
  bool _1132 = (_1110 > 0.0f);
  float _1133 = float((bool)_1130);
  float _1134 = float((bool)_1131);
  float _1135 = float((bool)_1132);
  float _1136 = _1120 * _1133;
  float _1137 = _1136 * _1129;
  float _1138 = _1121 * _1134;
  float _1139 = _1138 * _1129;
  float _1140 = _1122 * _1135;
  float _1141 = _1140 * _1129;
  float _1142 = _1137 + _1108;
  float _1143 = _1139 + _1109;
  float _1144 = _1141 + _1110;
  SV_Target.x = _1142;
  SV_Target.y = _1143;
  SV_Target.z = _1144;
  SV_Target.w = _63.w;
  if (APTIsPsychoV()) {
    SV_Target.rgb = APTRenderIntermediatePassDithered(
        apt_tonemapped,
        SV_Position.xy);
  }
  return SV_Target;
}
