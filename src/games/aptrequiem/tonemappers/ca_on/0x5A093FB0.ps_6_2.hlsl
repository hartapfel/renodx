Texture2DArray<float4> sBlueNoiseR8 : register(t1);

Texture2DArray<float4> sBlueNoiseR8G8 : register(t8);

Texture2D<float4> s0 : register(t0);

Texture2D<float4> s2 : register(t2);

Texture2D<float4> s4 : register(t4);

Texture2D<float4> s5 : register(t5);

Texture2D<float4> s6 : register(t6);

Texture2D<float4> s7 : register(t7);

Texture2D<float4> s9 : register(t9);

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

SamplerState s9Sampler : register(s9);

SamplerState s13Sampler : register(s13);

SamplerState s14Sampler : register(s14);

SamplerState s15Sampler : register(s15);

SamplerState s3_3DSampler : register(s3);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  int _37 = asint((Global.c[43].w));
  float4 _38 = s14.Sample(s14Sampler, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _42 = sPlagueFX_MaskLayer.Sample(s13Sampler, float2(TEXCOORD.z, TEXCOORD.w));
  float _45 = _42.y * 0.10000000149011612f;
  float _46 = _45 + _38.y;
  float _47 = _42.y * 0.5f;
  float _48 = _47 + _38.z;
  float _49 = exp2(_48);
  float _50 = _49 + -1.0f;
  float _53 = (PostProcess.Settings[11].y) * _50;
  float _54 = _53 + 1.0f;
  float _55 = log2(_54);
  float _56 = _38.x + TEXCOORD.z;
  float _57 = _46 + TEXCOORD.w;
  float _58 = _38.x + TEXCOORD.x;
  float _59 = _46 + TEXCOORD.y;
  float _60 = _56 * 2.0f;
  float _61 = _57 * 2.0f;
  float _62 = _60 + -1.0f;
  float _63 = _61 + -1.0f;
  float _67 = (Global.c[37].x) * _62;
  float _68 = _63 * (Global.c[37].y);
  float _69 = _67 * _67;
  float _70 = _68 * _68;
  float _71 = _70 + _69;
  float _72 = sqrt(_71);
  float _75 = _58 * 2.0f;
  float _76 = _75 + -1.0f;
  float _77 = _59 * 1.125f;
  float _78 = _77 + -0.5625f;
  float _79 = _76 * _76;
  float _80 = _78 * _78;
  float _81 = _80 + _79;
  float _82 = sqrt(_81);
  float _83 = _82 * 0.8715755343437195f;
  float _84 = _83 * _83;
  float _85 = _84 + -0.15000000596046448f;
  float _86 = _85 * 1.8181819915771484f;
  float _87 = saturate(_86);
  float _88 = _87 * 2.0f;
  float _89 = 3.0f - _88;
  float _90 = (PostProcess.Settings[2].w) * _72;
  float _91 = _87 * _87;
  float _92 = _91 * _90;
  float _93 = _92 * _84;
  float _94 = _93 * _89;
  float _96 = (PostProcess.Settings[2].z) * _67;
  float _97 = (PostProcess.Settings[2].z) * _68;
  float _98 = _97 + _57;
  float _99 = _56 - _96;
  float _100 = _42.x * 0.010840999893844128f;
  float _101 = _100 + _56;
  float _102 = _101 + _96;
  float _103 = _57 + _100;
  float _104 = _103 - _97;
  float _105 = _94 + _55;
  float4 _106 = s0.SampleLevel(s0Sampler, float2(_102, _98), _105);
  float4 _108 = s0.SampleLevel(s0Sampler, float2(_99, _104), _105);
  float4 _110 = s0.SampleLevel(s0Sampler, float2(_56, _57), _105);
  float _113 = max(_106.x, 0.0f);
  float _114 = max(_108.y, 0.0f);
  float _115 = max(_110.z, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_113, _114, _115),
      max(_110.rgb, 0.f.xxx),
      float2(_56, _57),
      s0,
      s0Sampler,
      _105);
  _113 = renodx_chromatic_aberration_input.x;
  _114 = renodx_chromatic_aberration_input.y;
  _115 = renodx_chromatic_aberration_input.z;
  float _118 = (Global.c[32].w) * 11.0f;
  float _119 = _118 + -1.2000000476837158f;
  float _120 = saturate(_119);
  float _121 = (Global.c[32].w) * 1.7000000476837158f;
  float _122 = 1.340000033378601f - _121;
  float _123 = saturate(_122);
  float _124 = _123 * _123;
  float _125 = _124 * _124;
  float _126 = _125 * _120;
  bool _127 = ((Global.c[32].w) < 9.999999747378752e-06f);
  float _130 = max((Global.c[33].y), _126);
  float _131 = _57 * 1.7999999523162842f;
  float _132 = _131 + -1.100000023841858f;
  float _133 = abs(_62);
  float _134 = abs(_132);
  float _135 = dot(float2(_133, _134), float2(_133, _134));
  float _136 = sqrt(_135);
  float _137 = select(_127, 1.0f, 0.0f);
  float _138 = _137 * _130;
  float4 _139 = s0.SampleLevel(s0Sampler, float2(_56, _57), 1.0f);
  float4 _143 = s0.SampleLevel(s0Sampler, float2(_56, _57), 2.0f);
  float4 _147 = s0.SampleLevel(s0Sampler, float2(_56, _57), 3.0f);
  float _151 = _135 * 1.7000000476837158f;
  float _152 = _151 + -0.6000000238418579f;
  float _153 = saturate(_152);
  float _154 = _135 * 1.475000023841858f;
  float _155 = _154 + -0.375f;
  float _156 = saturate(_155);
  float _157 = _135 * 1.2999999523162842f;
  float _158 = _157 + -0.15000000596046448f;
  float _159 = saturate(_158);
  float _160 = _147.x - _143.x;
  float _161 = _147.y - _143.y;
  float _162 = _147.z - _143.z;
  float _163 = _160 * _153;
  float _164 = _161 * _153;
  float _165 = _162 * _153;
  float _166 = _143.x - _139.x;
  float _167 = _166 + _163;
  float _168 = _143.y - _139.y;
  float _169 = _168 + _164;
  float _170 = _143.z - _139.z;
  float _171 = _170 + _165;
  float _172 = _167 * _156;
  float _173 = _169 * _156;
  float _174 = _171 * _156;
  float _175 = _159 * _138;
  float _176 = _139.x - _113;
  float _177 = _176 + _172;
  float _178 = _139.y - _114;
  float _179 = _178 + _173;
  float _180 = _139.z - _115;
  float _181 = _180 + _174;
  float _182 = _177 * _175;
  float _183 = _179 * _175;
  float _184 = _181 * _175;
  float _185 = _182 + _113;
  float _186 = _183 + _114;
  float _187 = _184 + _115;
  bool _190 = ((User.c[6].y) > 0.0f);
  float _323;
  float _355;
  float _356;
  float _357;
  float _503;
  float _504;
  float _505;
  float _754;
  float _810;
  float _866;
  float _869;
  float _870;
  float _871;
  float _882;
  float _1014;
  float _1015;
  float _1016;
  float _1062;
  float _1063;
  float _1064;
  float _1102;
  float _1116;
  float _1130;
  float _1131;
  float _1132;
  [branch]
  if (_190) {
    float4 _192 = s4.Sample(s4Sampler, float2(TEXCOORD.x, TEXCOORD.y));
    float4 _197 = s5.Sample(s5Sampler, float2(TEXCOORD.x, TEXCOORD.y));
    float _201 = (PostProcess.Settings[6].x) * _197.x;
    float _205 = _201 * (PostProcess.Settings[7].x);
    float _206 = _201 * (PostProcess.Settings[7].y);
    float _207 = _205 + TEXCOORD.x;
    float _208 = _206 + TEXCOORD.y;
    float4 _209 = s4.Sample(s4Sampler, float2(_207, _208));
    float4 _211 = s5.Sample(s5Sampler, float2(_207, _208));
    float _213 = (PostProcess.Settings[6].x) * _211.x;
    float _214 = abs(_213);
    float _216 = _214 / (PostProcess.Settings[7].w);
    float _217 = _209.z - _192.z;
    float _218 = _216 * _217;
    float _219 = _192.x - _185;
    float _220 = _192.y - _186;
    float _221 = _192.z - _187;
    float _222 = _221 + _218;
    float _223 = _219 * _192.w;
    float _224 = _220 * _192.w;
    float _225 = _222 * _192.w;
    _355 = _223;
    _356 = _224;
    _357 = _225;
  } else {
    bool _228 = ((User.c[6].x) > 0.0f);
    [branch]
    if (_228) {
      float4 _230 = s7.Sample(s7Sampler, float2(TEXCOORD.x, TEXCOORD.y));
      float _232 = abs(_230.x);
      _323 = _232;
    } else {
      float4 _234 = s2.SampleLevel(s2Sampler, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
      float _236 = TEXCOORD.x * 2.0f;
      float _237 = TEXCOORD.y * 2.0f;
      float _238 = _236 + -1.0f;
      float _239 = _237 + -1.0f;
      uint _240 = _37 << 5;
      uint _241 = _240 + 112u;
      uint _244 = _240 + 113u;
      uint _247 = _240 + 114u;
      uint _250 = _240 + 115u;
      float _265 = (Global.c[_241].x) * _238;
      float _266 = mad(_239, (Global.c[_241].y), _265);
      float _267 = mad(_234.x, (Global.c[_241].z), _266);
      float _268 = _267 + (Global.c[_241].w);
      float _269 = (Global.c[_244].x) * _238;
      float _270 = mad(_239, (Global.c[_244].y), _269);
      float _271 = mad(_234.x, (Global.c[_244].z), _270);
      float _272 = _271 + (Global.c[_244].w);
      float _273 = (Global.c[_247].x) * _238;
      float _274 = mad(_239, (Global.c[_247].y), _273);
      float _275 = mad(_234.x, (Global.c[_247].z), _274);
      float _276 = _275 + (Global.c[_247].w);
      float _277 = (Global.c[_250].x) * _238;
      float _278 = mad(_239, (Global.c[_250].y), _277);
      float _279 = mad(_234.x, (Global.c[_250].z), _278);
      float _280 = _279 + (Global.c[_250].w);
      float _281 = _268 / _280;
      float _282 = _272 / _280;
      float _283 = _276 / _280;
      float _284 = _281 * _281;
      float _285 = _282 * _282;
      float _286 = _285 + _284;
      float _287 = _283 * _283;
      float _288 = _286 + _287;
      float _289 = sqrt(_288);
      float4 _290 = s5.Sample(s5Sampler, float2(TEXCOORD.x, TEXCOORD.y));
      float _296 = (PostProcess.Settings[6].w) * (PostProcess.Settings[5].x);
      float _297 = _296 + (PostProcess.Settings[5].x);
      float _298 = (PostProcess.Settings[5].x) - _296;
      float _299 = max(_289, _298);
      float _300 = min(_299, _297);
      float _302 = _289 - _300;
      float _303 = (PostProcess.Settings[5].w) * _302;
      float _305 = _300 - (PostProcess.Settings[5].y);
      float _306 = _305 * _289;
      float _307 = _303 / _306;
      float _308 = min(_307, 0.0f);
      float _311 = (PostProcess.Settings[7].z) * _308;
      float _312 = _296 + 1.0f;
      float _313 = 1.0f / _312;
      float _314 = _311 * _313;
      float _315 = max(0.0f, _307);
      float _316 = _314 + _315;
      float _317 = min(_290.x, _316);
      float _318 = abs(_317);
      float _319 = abs(_316);
      float _320 = max(_318, _319);
      float _321 = saturate(_320);
      _323 = _321;
    }
    float _326 = (PostProcess.Settings[6].x) * _323;
    float4 _327 = s4.Sample(s4Sampler, float2(TEXCOORD.x, TEXCOORD.y));
    float _334 = (PostProcess.Settings[7].x) * _326;
    float _335 = (PostProcess.Settings[7].y) * _326;
    float _336 = _334 + TEXCOORD.x;
    float _337 = _335 + TEXCOORD.y;
    float4 _338 = s4.Sample(s4Sampler, float2(_336, _337));
    float4 _340 = s5.Sample(s5Sampler, float2(_336, _337));
    float _342 = abs(_340.x);
    float _343 = _338.z - _327.z;
    float _344 = _342 * _343;
    float _345 = _326 + -1.0f;
    float _346 = saturate(_345);
    float _347 = _327.x - _185;
    float _348 = _327.y - _186;
    float _349 = _327.z - _187;
    float _350 = _349 + _344;
    float _351 = _346 * _347;
    float _352 = _346 * _348;
    float _353 = _350 * _346;
    _355 = _351;
    _356 = _352;
    _357 = _353;
  }
  float _358 = _355 + _185;
  float _359 = _356 + _186;
  float _360 = _357 + _187;
  float4 _361 = s6.Load(int3(0, 0, 0));
  float _363 = _361.x * _358;
  float _364 = _361.x * _359;
  float _365 = _361.x * _360;
  float _372 = (PostProcess.Settings[13].w) * _63;
  float _373 = _62 * _62;
  float _374 = _372 * _372;
  float _375 = _374 + _373;
  float _376 = sqrt(_375);
  float _378 = (PostProcess.Settings[13].x) * _376;
  float _380 = _378 + (PostProcess.Settings[13].y);
  float _381 = saturate(_380);
  float _383 = log2(_381);
  float _384 = _383 * (PostProcess.Settings[13].z);
  float _385 = APTScaleVignetteMask(exp2(_384));
  float _386 = _363 * (PostProcess.Settings[12].x);
  float _387 = _364 * (PostProcess.Settings[12].y);
  float _388 = _365 * (PostProcess.Settings[12].z);
  float _389 = _386 - _363;
  float _390 = _387 - _364;
  float _391 = _388 - _365;
  float _392 = _385 * _389;
  float _393 = _385 * _390;
  float _394 = _385 * _391;
  float _395 = _392 + _363;
  float _396 = _393 + _364;
  float _397 = _394 + _365;
  float _400 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _401 = _395 * 11190.6005859375f;
  float _402 = _401 * _400;
  float _403 = _396 * 11190.6005859375f;
  float _404 = _403 * _400;
  float _405 = _397 * 11190.6005859375f;
  float _406 = _405 * _400;
  float _407 = _402 + 1.0f;
  float _408 = _404 + 1.0f;
  float _409 = _406 + 1.0f;
  float _410 = log2(_407);
  float _411 = log2(_408);
  float _412 = log2(_409);
  float _413 = _410 * 0.07434873282909393f;
  float _414 = _411 * 0.07434873282909393f;
  float _415 = _412 * 0.07434873282909393f;
  float _418 = _413 * (PostProcess.OffsetWeight[0].x);
  float _419 = _414 * (PostProcess.OffsetWeight[0].x);
  float _420 = _415 * (PostProcess.OffsetWeight[0].x);
  float _422 = _418 + (PostProcess.OffsetWeight[0].y);
  float _423 = _419 + (PostProcess.OffsetWeight[0].y);
  float _424 = _420 + (PostProcess.OffsetWeight[0].y);
  float4 _425 = s3_3D.Sample(s3_3DSampler, float3(_422, _423, _424));
  float _431 = _425.x * 13.450128555297852f;
  float _432 = _425.y * 13.450128555297852f;
  float _433 = _425.z * 13.450128555297852f;
  float _434 = exp2(_431);
  float _435 = exp2(_432);
  float _436 = exp2(_433);
  float _437 = _434 + -1.0f;
  float _438 = _435 + -1.0f;
  float _439 = _436 + -1.0f;
  float _440 = _437 * 8.936070662457496e-05f;
  float _441 = _438 * 8.936070662457496e-05f;
  float _442 = _439 * 8.936070662457496e-05f;
  float _443 = 10000.0f / (PostProcess.Settings[10].w);
  float _444 = _440 * _443;
  float _445 = _441 * _443;
  float _446 = _442 * _443;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUT(
      float3(_402, _404, _406) / apt_lut_input_encode_scale,
      float3(_444, _445, _446));
  apt_lut_output = APTApplyPerceptualFilmGrain(apt_lut_output, SV_Position.xy);
  _444 = apt_lut_output.x;
  _445 = apt_lut_output.y;
  _446 = apt_lut_output.z;
  float _447 = dot(float3(_444, _445, _446), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _451 = (PostProcess.Settings[9].x) * TEXCOORD.x;
  float _452 = (PostProcess.Settings[9].y) * TEXCOORD.y;
  float _455 = _451 + (PostProcess.Settings[9].z);
  float _456 = _452 + (PostProcess.Settings[9].w);
  float4 _457 = s9.Sample(s9Sampler, float2(_455, _456));
  bool _463 = ((PostProcess.Settings[10].y) > 0.0f);
  uint _464 = uint(SV_Position.x);
  uint _465 = uint(SV_Position.y);
  int _466 = _464 & 63;
  int _467 = _465 & 63;
  if (_463) {
    bool _470 = ((PostProcess.Settings[10].x) > 0.0f);
    int _473 = asint((Global.c[1].w));
    int _474 = select(_470, _473, 0);
    float4 _475 = sBlueNoiseR8G8.Load(int4(_466, _467, _474, 0));
    float _478 = _475.x * -2.0f;
    float _479 = _475.x * 2.0f;
    float _480 = _478 * _475.y;
    float _481 = _479 * _475.y;
    float _482 = _480 + _475.x;
    float _483 = _481 - _475.x;
    _503 = _482;
    _504 = _483;
    _505 = _483;
  } else {
    float4 _485 = sBlueNoiseR8.Load(int4(_466, _467, 0, 0));
    float _487 = _485.x - _457.x;
    float _488 = _485.x - _457.y;
    float _489 = _485.x - _457.z;
    float _490 = _487 * 0.5f;
    float _491 = _488 * 0.5f;
    float _492 = _489 * 0.5f;
    float _493 = _490 + _457.x;
    float _494 = _491 + _457.y;
    float _495 = _492 + _457.z;
    float _496 = _493 * 2.0f;
    float _497 = _494 * 2.0f;
    float _498 = _495 * 2.0f;
    float _499 = _496 + -1.0f;
    float _500 = _497 + -1.0f;
    float _501 = _498 + -1.0f;
    _503 = _499;
    _504 = _500;
    _505 = _501;
  }
  float _506 = _447 + 1.0f;
  float _507 = _447 / _506;
  float _508 = _507 + -9.999999747378752e-05f;
  float _509 = _508 * 1111.111083984375f;
  float _510 = saturate(_509);
  float _511 = _510 * 2.0f;
  float _512 = 3.0f - _511;
  float _513 = _510 * _510;
  float _514 = _513 * _512;
  float _518 = (PostProcess.Settings[2].y) - (PostProcess.Settings[2].x);
  float _519 = _518 * _507;
  float _520 = _519 + (PostProcess.Settings[2].x);
  float _521 = _514 * _503;
  float _522 = _521 * _520;
  float _523 = _514 * _504;
  float _524 = _523 * _520;
  float _525 = _514 * _505;
  float _526 = _525 * _520;
  float _527 = _522 + _444;
  float _528 = _524 + _445;
  float _529 = _526 + _446;
  float _530 = max(0.0f, _527);
  float _531 = max(0.0f, _528);
  float _532 = max(0.0f, _529);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_530, _531, _532),
      apt_lut_output);
  _530 = apt_film_grain_output.x;
  _531 = apt_film_grain_output.y;
  _532 = apt_film_grain_output.z;
  float _536 = (User.c[2].y) / (User.c[2].x);
  int _539 = asint((Global.c[1].w));
  uint _540 = _539 + 30u;
  int _541 = _540 & 63;
  float _542 = _56 * 8.0f;
  float _543 = _542 * _536;
  float _544 = _57 * 8.0f;
  float _545 = float((int)(_539));
  float4 _546 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_543, _544, _545), 0.0f);
  float _548 = _56 + 0.5f;
  float _549 = (User.c[2].x) * 0.5f;
  float _550 = _548 + _549;
  float _551 = _536 * 8.0f;
  float _552 = _551 * _550;
  float _553 = _57 + 0.5f;
  float _554 = (User.c[2].y) * 0.5f;
  float _555 = _553 + _554;
  float _556 = _555 * 8.0f;
  float _557 = float((int)(_541));
  float4 _558 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_552, _556, _557), 0.0f);
  float _560 = _558.x + _546.x;
  float _561 = _560 * 0.714285671710968f;
  float _562 = _561 + -0.2142857164144516f;
  float _563 = saturate(_562);
  float _564 = _563 * 2.0f;
  float _565 = 3.0f - _564;
  float _566 = _563 * _563;
  float _567 = _566 * _565;
  float _568 = _567 * 0.5f;
  float _569 = _567 * 0.4000000059604645f;
  float _570 = _567 * 0.05000000074505806f;
  float _571 = _568 + -0.5f;
  float _572 = _569 + -0.6000000238418579f;
  float _573 = _570 + -0.949999988079071f;
  float _574 = _571 * _138;
  float _575 = _572 * _138;
  float _576 = _573 * _138;
  float _577 = _574 + 1.0f;
  float _578 = _575 + 1.0f;
  float _579 = _576 + 1.0f;
  float _580 = _577 * _530;
  float _581 = _578 * _531;
  float _582 = _579 * _532;
  float4 _583 = s13.Sample(s13Sampler, float2(_56, _57));
  float _590 = _153 + 1.0f;
  float _591 = saturate(_590);
  float _592 = (User.c[2].x) * _591;
  float _593 = (User.c[2].y) * _591;
  float _594 = _592 + _56;
  float _595 = _593 + _57;
  float4 _596 = s13.Sample(s13Sampler, float2(_594, _595));
  float _600 = _596.x + _583.x;
  float _601 = _596.y + _583.y;
  float _602 = _596.z + _583.z;
  float _603 = _601 * 0.5f;
  float _604 = _602 * 0.5f;
  float _605 = _504 * 0.30000001192092896f;
  float _606 = _605 + 0.699999988079071f;
  float _607 = saturate(_606);
  float _608 = _607 * 0.5f;
  float _609 = _608 * _600;
  float _610 = _603 * _607;
  float _611 = _604 * _607;
  float _612 = _138 * 0.6000000238418579f;
  float _613 = _612 * _136;
  float _614 = _138 * 0.7300000190734863f;
  float _615 = _614 * _136;
  float _616 = _138 * 0.8799999952316284f;
  float _617 = _616 * _136;
  float _618 = 1.0f - _613;
  float _619 = 1.0f - _615;
  float _620 = 1.0f - _617;
  float _621 = saturate(_618);
  float _622 = saturate(_619);
  float _623 = saturate(_620);
  float _624 = _580 * _621;
  float _625 = _581 * _622;
  float _626 = _582 * _623;
  float _627 = _624 + _609;
  float _628 = _625 + _610;
  float _629 = _626 + _611;
  bool _632 = ((User.c[3].x) > 0.0f) && !APTIsPsychoV();
  if (_632) {
    float _634 = log2(_627);
    float _635 = _634 * 3.0f;
    float _636 = exp2(_635);
    float _637 = _636 + -1.0f;
    float _638 = _627 + -1.0f;
    float _639 = _637 / _638;
    float _640 = _639 + -1.0f;
    bool _641 = !(_627 == 1.0f);
    float _642 = _640 / _639;
    float _643 = select(_641, _642, 0.6666666865348816f);
    float _644 = log2(_628);
    float _645 = _644 * 3.0f;
    float _646 = exp2(_645);
    float _647 = _646 + -1.0f;
    float _648 = _628 + -1.0f;
    float _649 = _647 / _648;
    float _650 = _649 + -1.0f;
    bool _651 = !(_628 == 1.0f);
    float _652 = _650 / _649;
    float _653 = select(_651, _652, 0.6666666865348816f);
    float _654 = log2(_629);
    float _655 = _654 * 3.0f;
    float _656 = exp2(_655);
    float _657 = _656 + -1.0f;
    float _658 = _629 + -1.0f;
    float _659 = _657 / _658;
    float _660 = _659 + -1.0f;
    bool _661 = !(_629 == 1.0f);
    float _662 = _660 / _659;
    float _663 = select(_661, _662, 0.6666666865348816f);
    bool _664 = (_643 <= 0.0031308000907301903f);
    bool _665 = (_653 <= 0.0031308000907301903f);
    bool _666 = (_663 <= 0.0031308000907301903f);
    float _667 = _643 * 12.920000076293945f;
    float _668 = _653 * 12.920000076293945f;
    float _669 = _663 * 12.920000076293945f;
    float _670 = log2(_643);
    float _671 = log2(_653);
    float _672 = log2(_663);
    float _673 = _670 * 0.4166666567325592f;
    float _674 = _671 * 0.4166666567325592f;
    float _675 = _672 * 0.4166666567325592f;
    float _676 = exp2(_673);
    float _677 = exp2(_674);
    float _678 = exp2(_675);
    float _679 = _676 * 1.0549999475479126f;
    float _680 = _677 * 1.0549999475479126f;
    float _681 = _678 * 1.0549999475479126f;
    float _682 = _679 + -0.054999999701976776f;
    float _683 = _680 + -0.054999999701976776f;
    float _684 = _681 + -0.054999999701976776f;
    float _685 = select(_664, _667, _682);
    float _686 = select(_665, _668, _683);
    float _687 = select(_666, _669, _684);
    int _689 = asint((User.c[3].y));
    int _690 = _689 & 1;
    bool _691 = (_690 == 0);
    if (!_691) {
      bool _700 = !(_685 <= (User.c[4].x));
      if (!_700) {
        float _702 = max(9.999999974752427e-07f, (User.c[4].x));
        float _703 = _685 / _702;
        float _704 = _703 * (User.c[4].y);
        float _705 = _703 * _703;
        float _706 = _705 * _703;
        float _707 = _706 - _703;
        float _708 = (User.c[3].z) * 0.1666666716337204f;
        float _709 = _702 * _702;
        float _710 = _709 * _708;
        float _711 = _710 * _707;
        float _712 = _711 + _704;
        _754 = _712;
      } else {
        bool _714 = !(_685 <= (User.c[4].z));
        if (!_714) {
          float _716 = (User.c[4].z) - (User.c[4].x);
          float _717 = max(9.999999974752427e-07f, _716);
          float _718 = _685 - (User.c[4].x);
          float _719 = _718 / _717;
          float _720 = 1.0f - _719;
          float _721 = _720 * (User.c[4].y);
          float _722 = _719 * (User.c[4].w);
          float _723 = _721 + _722;
          float _724 = _720 * _720;
          float _725 = _724 * _720;
          float _726 = _725 - _720;
          float _727 = _726 * (User.c[3].z);
          float _728 = _719 * _719;
          float _729 = _728 * _719;
          float _730 = _729 - _719;
          float _731 = _730 * (User.c[3].w);
          float _732 = _727 + _731;
          float _733 = _717 * _717;
          float _734 = _733 * 0.1666666716337204f;
          float _735 = _734 * _732;
          float _736 = _723 + _735;
          _754 = _736;
        } else {
          float _738 = 1.0f - (User.c[4].z);
          float _739 = _685 - (User.c[4].z);
          float _740 = max(9.999999974752427e-07f, _738);
          float _741 = _739 / _740;
          float _742 = 1.0f - _741;
          float _743 = _742 * (User.c[4].w);
          float _744 = _743 + _741;
          float _745 = _742 * _742;
          float _746 = _745 * _742;
          float _747 = _746 - _742;
          float _748 = _738 * _738;
          float _749 = _748 * 0.1666666716337204f;
          float _750 = _749 * (User.c[3].w);
          float _751 = _750 * _747;
          float _752 = _744 + _751;
          _754 = _752;
        }
      }
      float _755 = saturate(_754);
      bool _756 = !(_686 <= (User.c[4].x));
      if (!_756) {
        float _758 = max(9.999999974752427e-07f, (User.c[4].x));
        float _759 = _686 / _758;
        float _760 = _759 * (User.c[4].y);
        float _761 = _759 * _759;
        float _762 = _761 * _759;
        float _763 = _762 - _759;
        float _764 = (User.c[3].z) * 0.1666666716337204f;
        float _765 = _758 * _758;
        float _766 = _765 * _764;
        float _767 = _766 * _763;
        float _768 = _767 + _760;
        _810 = _768;
      } else {
        bool _770 = !(_686 <= (User.c[4].z));
        if (!_770) {
          float _772 = (User.c[4].z) - (User.c[4].x);
          float _773 = max(9.999999974752427e-07f, _772);
          float _774 = _686 - (User.c[4].x);
          float _775 = _774 / _773;
          float _776 = 1.0f - _775;
          float _777 = _776 * (User.c[4].y);
          float _778 = _775 * (User.c[4].w);
          float _779 = _777 + _778;
          float _780 = _776 * _776;
          float _781 = _780 * _776;
          float _782 = _781 - _776;
          float _783 = _782 * (User.c[3].z);
          float _784 = _775 * _775;
          float _785 = _784 * _775;
          float _786 = _785 - _775;
          float _787 = _786 * (User.c[3].w);
          float _788 = _783 + _787;
          float _789 = _773 * _773;
          float _790 = _789 * 0.1666666716337204f;
          float _791 = _790 * _788;
          float _792 = _779 + _791;
          _810 = _792;
        } else {
          float _794 = 1.0f - (User.c[4].z);
          float _795 = _686 - (User.c[4].z);
          float _796 = max(9.999999974752427e-07f, _794);
          float _797 = _795 / _796;
          float _798 = 1.0f - _797;
          float _799 = _798 * (User.c[4].w);
          float _800 = _799 + _797;
          float _801 = _798 * _798;
          float _802 = _801 * _798;
          float _803 = _802 - _798;
          float _804 = _794 * _794;
          float _805 = _804 * 0.1666666716337204f;
          float _806 = _805 * (User.c[3].w);
          float _807 = _806 * _803;
          float _808 = _800 + _807;
          _810 = _808;
        }
      }
      float _811 = saturate(_810);
      bool _812 = !(_687 <= (User.c[4].x));
      if (!_812) {
        float _814 = max(9.999999974752427e-07f, (User.c[4].x));
        float _815 = _687 / _814;
        float _816 = _815 * (User.c[4].y);
        float _817 = _815 * _815;
        float _818 = _817 * _815;
        float _819 = _818 - _815;
        float _820 = (User.c[3].z) * 0.1666666716337204f;
        float _821 = _814 * _814;
        float _822 = _821 * _820;
        float _823 = _822 * _819;
        float _824 = _823 + _816;
        _866 = _824;
      } else {
        bool _826 = !(_687 <= (User.c[4].z));
        if (!_826) {
          float _828 = (User.c[4].z) - (User.c[4].x);
          float _829 = max(9.999999974752427e-07f, _828);
          float _830 = _687 - (User.c[4].x);
          float _831 = _830 / _829;
          float _832 = 1.0f - _831;
          float _833 = _832 * (User.c[4].y);
          float _834 = _831 * (User.c[4].w);
          float _835 = _833 + _834;
          float _836 = _832 * _832;
          float _837 = _836 * _832;
          float _838 = _837 - _832;
          float _839 = _838 * (User.c[3].z);
          float _840 = _831 * _831;
          float _841 = _840 * _831;
          float _842 = _841 - _831;
          float _843 = _842 * (User.c[3].w);
          float _844 = _839 + _843;
          float _845 = _829 * _829;
          float _846 = _845 * 0.1666666716337204f;
          float _847 = _846 * _844;
          float _848 = _835 + _847;
          _866 = _848;
        } else {
          float _850 = 1.0f - (User.c[4].z);
          float _851 = _687 - (User.c[4].z);
          float _852 = max(9.999999974752427e-07f, _850);
          float _853 = _851 / _852;
          float _854 = 1.0f - _853;
          float _855 = _854 * (User.c[4].w);
          float _856 = _855 + _853;
          float _857 = _854 * _854;
          float _858 = _857 * _854;
          float _859 = _858 - _854;
          float _860 = _850 * _850;
          float _861 = _860 * 0.1666666716337204f;
          float _862 = _861 * (User.c[3].w);
          float _863 = _862 * _859;
          float _864 = _856 + _863;
          _866 = _864;
        }
      }
      float _867 = saturate(_866);
      _869 = _755;
      _870 = _811;
      _871 = _867;
    } else {
      _869 = _685;
      _870 = _686;
      _871 = _687;
    }
    int _872 = _689 & 2;
    bool _873 = (_872 == 0);
    if (!_873) {
      float _875 = sqrt(_869);
      float _876 = sqrt(_870);
      float _877 = sqrt(_871);
      float _878 = dot(float3(_875, _876, _877), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _879 = 1.0f - _878;
      float _880 = saturate(_879);
      _882 = _880;
    } else {
      _882 = 1.0f;
    }
    int _883 = _689 & 8;
    bool _884 = (_883 == 0);
    if (!_884) {
      bool _886 = (_882 <= 0.0031308000907301903f);
      float _887 = _882 * 12.920000076293945f;
      float _888 = log2(_882);
      float _889 = _888 * 0.4166666567325592f;
      float _890 = exp2(_889);
      float _891 = _890 * 1.0549999475479126f;
      float _892 = _891 + -0.054999999701976776f;
      float _893 = select(_886, _887, _892);
      _1130 = _893;
      _1131 = _893;
      _1132 = _893;
    } else {
      int _895 = _689 & 4;
      bool _896 = (_895 == 0);
      if (!_896) {
        int _898 = _689 & 16;
        bool _899 = (_898 == 0);
        if (!_899) {
          float _903 = (User.c[5].x) * 0.5f;
          float _904 = _903 + 0.5f;
          bool _905 = (_904 < 0.5f);
          float _906 = (User.c[5].x) * 5.0f;
          float _907 = select(_905, (User.c[5].x), _906);
          bool _908 = (_870 < _871);
          float _909 = select(_908, _871, _870);
          float _910 = select(_908, _870, _871);
          bool _911 = (_869 < _909);
          float _912 = select(_911, _909, _869);
          float _913 = select(_911, _869, _909);
          float _914 = min(_913, _910);
          float _915 = _912 - _914;
          float _916 = _912 + 1.000000013351432e-10f;
          float _917 = _915 / _916;
          float _919 = _917 - (User.c[5].y);
          float _920 = saturate(_919);
          float _921 = max(_920, 9.999999974752427e-07f);
          float _922 = log2(_921);
          float _923 = _922 * _907;
          float _924 = exp2(_923);
          float _925 = 2.0f - _924;
          float _927 = 1.0f - (User.c[5].z);
          float _928 = saturate(_927);
          float _929 = max(_928, _925);
          float _930 = dot(float3(_869, _870, _871), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _931 = _869 - _930;
          float _932 = _870 - _930;
          float _933 = _871 - _930;
          float _934 = _931 * _929;
          float _935 = _932 * _929;
          float _936 = _933 * _929;
          float _937 = _930 - _869;
          float _938 = _937 + _934;
          float _939 = _930 - _870;
          float _940 = _939 + _935;
          float _941 = _930 - _871;
          float _942 = _941 + _936;
          float _943 = _938 * _882;
          float _944 = _940 * _882;
          float _945 = _942 * _882;
          float _946 = _943 + _869;
          float _947 = _944 + _870;
          float _948 = _945 + _871;
          _1062 = _946;
          _1063 = _947;
          _1064 = _948;
        } else {
          bool _950 = (_882 == 0.0f);
          if (!_950) {
            float _954 = abs(User.c[5].x);
            float _955 = saturate(_954);
            uint2 _956; s15.GetDimensions(_956.x, _956.y);
            float _959 = float((uint)_956.y);
            int _960 = _689 & 32;
            bool _961 = (_960 == 0);
            float _962 = _959 + -1.0f;
            if (!_961) {
              float _964 = 1.0f / _962;
              uint _965 = uint(SV_Position.x);
              uint _966 = uint(SV_Position.y);
              int _967 = _965 & 63;
              int _968 = _966 & 63;
              float4 _969 = sBlueNoiseR8G8.Load(int4(_967, _968, 0, 0));
              float _972 = _969.x + -0.5f;
              float _973 = _869 * 13.999999046325684f;
              float _974 = _870 * 13.999999046325684f;
              float _975 = _871 * 13.999999046325684f;
              float _976 = saturate(_973);
              float _977 = saturate(_974);
              float _978 = saturate(_975);
              float _979 = _869 + -0.9285714030265808f;
              float _980 = _870 + -0.9285714030265808f;
              float _981 = _871 + -0.9285714030265808f;
              float _982 = _979 * 13.999999046325684f;
              float _983 = _980 * 13.999999046325684f;
              float _984 = _981 * 13.999999046325684f;
              float _985 = saturate(_982);
              float _986 = saturate(_983);
              float _987 = saturate(_984);
              float _988 = 1.0f - _985;
              float _989 = 1.0f - _986;
              float _990 = 1.0f - _987;
              float _991 = min(_976, _988);
              float _992 = min(_977, _989);
              float _993 = min(_978, _990);
              float _994 = _969.y + -0.5f;
              float _995 = _991 * _994;
              float _996 = _992 * _994;
              float _997 = _993 * _994;
              float _998 = _995 + _972;
              float _999 = _996 + _972;
              float _1000 = _997 + _972;
              float _1001 = _998 * _964;
              float _1002 = _999 * _964;
              float _1003 = _1000 * _964;
              float _1004 = _1001 + _869;
              float _1005 = _1002 + _870;
              float _1006 = _1003 + _871;
              float _1007 = saturate(_1004);
              float _1008 = saturate(_1005);
              float _1009 = saturate(_1006);
              float _1010 = saturate(_1007);
              float _1011 = saturate(_1008);
              float _1012 = saturate(_1009);
              _1014 = _1010;
              _1015 = _1011;
              _1016 = _1012;
            } else {
              _1014 = _869;
              _1015 = _870;
              _1016 = _871;
            }
            float _1017 = float((uint)_956.x);
            float _1018 = _962 / _1017;
            float _1019 = _1018 * _1014;
            float _1020 = 0.5f / _1017;
            float _1021 = _1019 + _1020;
            float _1022 = _962 / _959;
            float _1023 = _1022 * _1015;
            float _1024 = 0.5f / _959;
            float _1025 = _1023 + _1024;
            float _1026 = _1016 * _962;
            float _1027 = floor(_1026);
            float _1028 = frac(_1026);
            float _1029 = _1027 / _959;
            float _1030 = _1029 + _1021;
            float _1031 = _1027 + 1.0f;
            float _1032 = _1031 / _959;
            float _1033 = _1032 + _1021;
            float4 _1034 = s15.Sample(s15Sampler, float2(_1030, _1025));
            float4 _1038 = s15.Sample(s15Sampler, float2(_1033, _1025));
            float _1042 = _1038.x - _1034.x;
            float _1043 = _1038.y - _1034.y;
            float _1044 = _1038.z - _1034.z;
            float _1045 = _1042 * _1028;
            float _1046 = _1043 * _1028;
            float _1047 = _1044 * _1028;
            float _1048 = _955 * _882;
            float _1049 = _1034.x - _869;
            float _1050 = _1049 + _1045;
            float _1051 = _1034.y - _870;
            float _1052 = _1051 + _1046;
            float _1053 = _1034.z - _871;
            float _1054 = _1053 + _1047;
            float _1055 = _1050 * _1048;
            float _1056 = _1052 * _1048;
            float _1057 = _1054 * _1048;
            float _1058 = _1055 + _869;
            float _1059 = _1056 + _870;
            float _1060 = _1057 + _871;
            _1062 = _1058;
            _1063 = _1059;
            _1064 = _1060;
          } else {
            _1062 = _869;
            _1063 = _870;
            _1064 = _871;
          }
        }
      } else {
        _1062 = _869;
        _1063 = _870;
        _1064 = _871;
      }
      bool _1065 = (_1062 <= 0.040449999272823334f);
      bool _1066 = (_1063 <= 0.040449999272823334f);
      bool _1067 = (_1064 <= 0.040449999272823334f);
      float _1068 = _1062 * 0.07739938050508499f;
      float _1069 = _1063 * 0.07739938050508499f;
      float _1070 = _1064 * 0.07739938050508499f;
      float _1071 = _1062 + 0.054999999701976776f;
      float _1072 = _1063 + 0.054999999701976776f;
      float _1073 = _1064 + 0.054999999701976776f;
      float _1074 = _1071 * 0.9478673338890076f;
      float _1075 = _1072 * 0.9478673338890076f;
      float _1076 = _1073 * 0.9478673338890076f;
      float _1077 = log2(_1074);
      float _1078 = log2(_1075);
      float _1079 = log2(_1076);
      float _1080 = _1077 * 2.4000000953674316f;
      float _1081 = _1078 * 2.4000000953674316f;
      float _1082 = _1079 * 2.4000000953674316f;
      float _1083 = exp2(_1080);
      float _1084 = exp2(_1081);
      float _1085 = exp2(_1082);
      float _1086 = select(_1065, _1068, _1083);
      float _1087 = select(_1066, _1069, _1084);
      float _1088 = select(_1067, _1070, _1085);
      bool _1089 = (_1086 == 1.0f);
      if (!_1089) {
        float _1091 = _1086 * _1086;
        float _1092 = _1091 * 3.0f;
        float _1093 = _1086 * 2.0f;
        float _1094 = _1093 + 1.0f;
        float _1095 = _1094 - _1092;
        float _1096 = sqrt(_1095);
        float _1097 = _1086 + -1.0f;
        float _1098 = _1097 * 2.0f;
        float _1099 = _1096 / _1098;
        float _1100 = -0.5f - _1099;
        _1102 = _1100;
      } else {
        _1102 = 1e+06f;
      }
      bool _1103 = (_1087 == 1.0f);
      if (!_1103) {
        float _1105 = _1087 * _1087;
        float _1106 = _1105 * 3.0f;
        float _1107 = _1087 * 2.0f;
        float _1108 = _1107 + 1.0f;
        float _1109 = _1108 - _1106;
        float _1110 = sqrt(_1109);
        float _1111 = _1087 + -1.0f;
        float _1112 = _1111 * 2.0f;
        float _1113 = _1110 / _1112;
        float _1114 = -0.5f - _1113;
        _1116 = _1114;
      } else {
        _1116 = 1e+06f;
      }
      bool _1117 = (_1088 == 1.0f);
      if (!_1117) {
        float _1119 = _1088 * _1088;
        float _1120 = _1119 * 3.0f;
        float _1121 = _1088 * 2.0f;
        float _1122 = _1121 + 1.0f;
        float _1123 = _1122 - _1120;
        float _1124 = sqrt(_1123);
        float _1125 = _1088 + -1.0f;
        float _1126 = _1125 * 2.0f;
        float _1127 = _1124 / _1126;
        float _1128 = -0.5f - _1127;
        _1130 = _1102;
        _1131 = _1116;
        _1132 = _1128;
      } else {
        _1130 = _1102;
        _1131 = _1116;
        _1132 = 1e+06f;
      }
    }
  } else {
    _1130 = _627;
    _1131 = _628;
    _1132 = _629;
  }
  float _1133 = log2(_1130);
  float _1134 = _1133 * 3.0f;
  float _1135 = exp2(_1134);
  float _1136 = _1135 + -1.0f;
  float _1137 = _1130 + -1.0f;
  float _1138 = _1136 / _1137;
  float _1139 = _1138 + -1.0f;
  bool _1140 = !(_1130 == 1.0f);
  float _1141 = _1139 / _1138;
  float _1142 = select(_1140, _1141, 0.6666666865348816f);
  float _1143 = log2(_1131);
  float _1144 = _1143 * 3.0f;
  float _1145 = exp2(_1144);
  float _1146 = _1145 + -1.0f;
  float _1147 = _1131 + -1.0f;
  float _1148 = _1146 / _1147;
  float _1149 = _1148 + -1.0f;
  bool _1150 = !(_1131 == 1.0f);
  float _1151 = _1149 / _1148;
  float _1152 = select(_1150, _1151, 0.6666666865348816f);
  float _1153 = log2(_1132);
  float _1154 = _1153 * 3.0f;
  float _1155 = exp2(_1154);
  float _1156 = _1155 + -1.0f;
  float _1157 = _1132 + -1.0f;
  float _1158 = _1156 / _1157;
  float _1159 = _1158 + -1.0f;
  bool _1160 = !(_1132 == 1.0f);
  float _1161 = _1159 / _1158;
  float _1162 = select(_1160, _1161, 0.6666666865348816f);
  float _1163 = saturate(_1142);
  float _1164 = saturate(_1152);
  float _1165 = saturate(_1162);
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_627, _628, _629),
      float3(_1163, _1164, _1165),
      false);
  _1163 = apt_tonemapped.x;
  _1164 = apt_tonemapped.y;
  _1165 = apt_tonemapped.z;
  bool _1166 = (_1163 <= 0.0031308000907301903f);
  bool _1167 = (_1164 <= 0.0031308000907301903f);
  bool _1168 = (_1165 <= 0.0031308000907301903f);
  float _1169 = _1163 * 12.920000076293945f;
  float _1170 = _1164 * 12.920000076293945f;
  float _1171 = _1165 * 12.920000076293945f;
  float _1172 = log2(_1163);
  float _1173 = log2(_1164);
  float _1174 = log2(_1165);
  float _1175 = _1172 * 0.4166666567325592f;
  float _1176 = _1173 * 0.4166666567325592f;
  float _1177 = _1174 * 0.4166666567325592f;
  float _1178 = exp2(_1175);
  float _1179 = exp2(_1176);
  float _1180 = exp2(_1177);
  float _1181 = _1178 * 1.0549999475479126f;
  float _1182 = _1179 * 1.0549999475479126f;
  float _1183 = _1180 * 1.0549999475479126f;
  float _1184 = _1181 + -0.054999999701976776f;
  float _1185 = _1182 + -0.054999999701976776f;
  float _1186 = _1183 + -0.054999999701976776f;
  float _1187 = select(_1166, _1169, _1184);
  float _1188 = select(_1167, _1170, _1185);
  float _1189 = select(_1168, _1171, _1186);
  int _1192 = asint((Global.c[1].w));
  uint _1193 = uint(SV_Position.x);
  uint _1194 = uint(SV_Position.y);
  int _1195 = _1193 & 63;
  int _1196 = _1194 & 63;
  float4 _1197 = sBlueNoiseR8.Load(int4(_1195, _1196, _1192, 0));
  float _1199 = _1197.x * 0.003921568859368563f;
  float _1200 = _1187 + 0.003921568859368563f;
  float _1201 = _1200 - _1199;
  float _1202 = _1199 + _1188;
  float _1203 = _1199 + _1189;
  SV_Target.x = _1201;
  SV_Target.y = _1202;
  SV_Target.z = _1203;
  SV_Target.w = _110.w;
  if (APTIsPsychoV()) {
    SV_Target.rgb = APTRenderIntermediatePassDithered(
        apt_tonemapped,
        SV_Position.xy);
  }
  return SV_Target;
}
