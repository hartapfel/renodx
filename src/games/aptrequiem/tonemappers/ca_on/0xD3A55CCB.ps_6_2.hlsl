Texture2DArray<float4> sBlueNoiseR8 : register(t1);

Texture2DArray<float4> sBlueNoiseR8G8 : register(t2);

Texture2D<float4> s0 : register(t0);

Texture2D<float4> s6 : register(t6);

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
  float4 _31 = s14.Sample(s14Sampler, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _35 = sPlagueFX_MaskLayer.Sample(s13Sampler, float2(TEXCOORD.z, TEXCOORD.w));
  float _38 = _35.y * 0.10000000149011612f;
  float _39 = _38 + _31.y;
  float _40 = _35.y * 0.5f;
  float _41 = _40 + _31.z;
  float _42 = exp2(_41);
  float _43 = _42 + -1.0f;
  float _46 = (PostProcess.Settings[11].y) * _43;
  float _47 = _46 + 1.0f;
  float _48 = log2(_47);
  float _49 = _31.x + TEXCOORD.z;
  float _50 = _39 + TEXCOORD.w;
  float _51 = _31.x + TEXCOORD.x;
  float _52 = _39 + TEXCOORD.y;
  float _53 = _49 * 2.0f;
  float _54 = _50 * 2.0f;
  float _55 = _53 + -1.0f;
  float _56 = _54 + -1.0f;
  float _60 = (Global.c[37].x) * _55;
  float _61 = (Global.c[37].y) * _56;
  float _62 = _60 * _60;
  float _63 = _61 * _61;
  float _64 = _62 + _63;
  float _65 = sqrt(_64);
  float _68 = _51 * 2.0f;
  float _69 = _68 + -1.0f;
  float _70 = _52 * 1.125f;
  float _71 = _70 + -0.5625f;
  float _72 = _69 * _69;
  float _73 = _71 * _71;
  float _74 = _73 + _72;
  float _75 = sqrt(_74);
  float _76 = _75 * 0.8715755343437195f;
  float _77 = _76 * _76;
  float _78 = _77 + -0.15000000596046448f;
  float _79 = _78 * 1.8181819915771484f;
  float _80 = saturate(_79);
  float _81 = _80 * 2.0f;
  float _82 = 3.0f - _81;
  float _83 = (PostProcess.Settings[2].w) * _65;
  float _84 = _80 * _80;
  float _85 = _84 * _83;
  float _86 = _85 * _77;
  float _87 = _86 * _82;
  float _89 = (PostProcess.Settings[2].z) * _60;
  float _90 = (PostProcess.Settings[2].z) * _61;
  float _91 = _90 + _50;
  float _92 = _49 - _89;
  float _93 = _35.x * 0.010840999893844128f;
  float _94 = _49 + _93;
  float _95 = _94 + _89;
  float _96 = _50 + _93;
  float _97 = _96 - _90;
  float _98 = _87 + _48;
  float4 _99 = s0.SampleLevel(s0Sampler, float2(_95, _91), _98);
  float4 _101 = s0.SampleLevel(s0Sampler, float2(_92, _97), _98);
  float4 _103 = s0.SampleLevel(s0Sampler, float2(_49, _50), _98);
  float _106 = max(_99.x, 0.0f);
  float _107 = max(_101.y, 0.0f);
  float _108 = max(_103.z, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_106, _107, _108),
      max(_103.rgb, 0.f.xxx),
      float2(_49, _50),
      s0,
      s0Sampler,
      _98);
  _106 = renodx_chromatic_aberration_input.x;
  _107 = renodx_chromatic_aberration_input.y;
  _108 = renodx_chromatic_aberration_input.z;
  float _111 = (Global.c[32].w) * 11.0f;
  float _112 = _111 + -1.2000000476837158f;
  float _113 = saturate(_112);
  float _114 = (Global.c[32].w) * 1.7000000476837158f;
  float _115 = 1.340000033378601f - _114;
  float _116 = saturate(_115);
  float _117 = _116 * _116;
  float _118 = _117 * _117;
  float _119 = _118 * _113;
  bool _120 = ((Global.c[32].w) < 9.999999747378752e-06f);
  float _123 = max((Global.c[33].y), _119);
  float _124 = _50 * 1.7999999523162842f;
  float _125 = _124 + -1.100000023841858f;
  float _126 = abs(_55);
  float _127 = abs(_125);
  float _128 = dot(float2(_126, _127), float2(_126, _127));
  float _129 = sqrt(_128);
  float _130 = select(_120, 1.0f, 0.0f);
  float _131 = _130 * _123;
  float4 _132 = s0.SampleLevel(s0Sampler, float2(_49, _50), 1.0f);
  float4 _136 = s0.SampleLevel(s0Sampler, float2(_49, _50), 2.0f);
  float4 _140 = s0.SampleLevel(s0Sampler, float2(_49, _50), 3.0f);
  float _144 = _128 * 1.7000000476837158f;
  float _145 = _144 + -0.6000000238418579f;
  float _146 = saturate(_145);
  float _147 = _128 * 1.475000023841858f;
  float _148 = _147 + -0.375f;
  float _149 = saturate(_148);
  float _150 = _128 * 1.2999999523162842f;
  float _151 = _150 + -0.15000000596046448f;
  float _152 = saturate(_151);
  float _153 = _140.x - _136.x;
  float _154 = _140.y - _136.y;
  float _155 = _140.z - _136.z;
  float _156 = _153 * _146;
  float _157 = _154 * _146;
  float _158 = _155 * _146;
  float _159 = _136.x - _132.x;
  float _160 = _159 + _156;
  float _161 = _136.y - _132.y;
  float _162 = _161 + _157;
  float _163 = _136.z - _132.z;
  float _164 = _163 + _158;
  float _165 = _160 * _149;
  float _166 = _162 * _149;
  float _167 = _164 * _149;
  float _168 = _152 * _131;
  float _169 = _132.x - _106;
  float _170 = _169 + _165;
  float _171 = _132.y - _107;
  float _172 = _171 + _166;
  float _173 = _132.z - _108;
  float _174 = _173 + _167;
  float _175 = _170 * _168;
  float _176 = _172 * _168;
  float _177 = _174 * _168;
  float _178 = _175 + _106;
  float _179 = _176 + _107;
  float _180 = _177 + _108;
  float4 _181 = s12_bloom.Sample(s12_bloomSampler, float2(_49, _50));
  float4 _185 = s8.Sample(s8Sampler, float2(_51, _52));
  float _192 = (PostProcess.Settings[4].w) * _185.x;
  float _193 = (PostProcess.Settings[4].w) * _185.y;
  float _194 = (PostProcess.Settings[4].w) * _185.z;
  float _195 = _192 + (PostProcess.Settings[4].z);
  float _196 = _193 + (PostProcess.Settings[4].z);
  float _197 = _194 + (PostProcess.Settings[4].z);
  float _198 = saturate(_195);
  float _199 = saturate(_196);
  float _200 = saturate(_197);
  float _201 = _181.x - _178;
  float _202 = _181.y - _179;
  float _203 = _181.z - _180;
  float _204 = _198 * _201;
  float _205 = _199 * _202;
  float _206 = _200 * _203;
  float _207 = _204 + _178;
  float _208 = _205 + _179;
  float _209 = _206 + _180;
  float4 _210 = s6.Load(int3(0, 0, 0));
  float _212 = _210.x * _207;
  float _213 = _210.x * _208;
  float _214 = _210.x * _209;
  float _221 = (PostProcess.Settings[13].w) * _56;
  float _222 = _55 * _55;
  float _223 = _221 * _221;
  float _224 = _223 + _222;
  float _225 = sqrt(_224);
  float _227 = (PostProcess.Settings[13].x) * _225;
  float _229 = _227 + (PostProcess.Settings[13].y);
  float _230 = saturate(_229);
  float _232 = log2(_230);
  float _233 = _232 * (PostProcess.Settings[13].z);
  float _234 = exp2(_233);
  float _235 = _212 * (PostProcess.Settings[12].x);
  float _236 = _213 * (PostProcess.Settings[12].y);
  float _237 = _214 * (PostProcess.Settings[12].z);
  float _238 = _235 - _212;
  float _239 = _236 - _213;
  float _240 = _237 - _214;
  float _241 = _234 * _238;
  float _242 = _234 * _239;
  float _243 = _234 * _240;
  float _244 = _241 + _212;
  float _245 = _242 + _213;
  float _246 = _243 + _214;
  float _249 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _250 = _244 * 11190.6005859375f;
  float _251 = _250 * _249;
  float _252 = _245 * 11190.6005859375f;
  float _253 = _252 * _249;
  float _254 = _246 * 11190.6005859375f;
  float _255 = _254 * _249;
  float _256 = _251 + 1.0f;
  float _257 = _253 + 1.0f;
  float _258 = _255 + 1.0f;
  float _259 = log2(_256);
  float _260 = log2(_257);
  float _261 = log2(_258);
  float _262 = _259 * 0.07434873282909393f;
  float _263 = _260 * 0.07434873282909393f;
  float _264 = _261 * 0.07434873282909393f;
  float _267 = _262 * (PostProcess.OffsetWeight[0].x);
  float _268 = _263 * (PostProcess.OffsetWeight[0].x);
  float _269 = _264 * (PostProcess.OffsetWeight[0].x);
  float _271 = _267 + (PostProcess.OffsetWeight[0].y);
  float _272 = _268 + (PostProcess.OffsetWeight[0].y);
  float _273 = _269 + (PostProcess.OffsetWeight[0].y);
  float4 _274 = s3_3D.Sample(s3_3DSampler, float3(_271, _272, _273));
  float _280 = _274.x * 13.450128555297852f;
  float _281 = _274.y * 13.450128555297852f;
  float _282 = _274.z * 13.450128555297852f;
  float _283 = exp2(_280);
  float _284 = exp2(_281);
  float _285 = exp2(_282);
  float _286 = _283 + -1.0f;
  float _287 = _284 + -1.0f;
  float _288 = _285 + -1.0f;
  float _289 = _286 * 8.936070662457496e-05f;
  float _290 = _287 * 8.936070662457496e-05f;
  float _291 = _288 * 8.936070662457496e-05f;
  float _292 = 10000.0f / (PostProcess.Settings[10].w);
  float _293 = _289 * _292;
  float _294 = _290 * _292;
  float _295 = _291 * _292;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUT(
      float3(_251, _253, _255) / apt_lut_input_encode_scale,
      float3(_293, _294, _295));
  apt_lut_output = APTApplyPerceptualFilmGrain(apt_lut_output, SV_Position.xy);
  _293 = apt_lut_output.x;
  _294 = apt_lut_output.y;
  _295 = apt_lut_output.z;
  float _296 = dot(float3(_293, _294, _295), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _300 = (PostProcess.Settings[9].x) * TEXCOORD.x;
  float _301 = (PostProcess.Settings[9].y) * TEXCOORD.y;
  float _304 = _300 + (PostProcess.Settings[9].z);
  float _305 = _301 + (PostProcess.Settings[9].w);
  float4 _306 = s9.Sample(s9Sampler, float2(_304, _305));
  bool _312 = ((PostProcess.Settings[10].y) > 0.0f);
  uint _313 = uint(SV_Position.x);
  uint _314 = uint(SV_Position.y);
  int _315 = _313 & 63;
  int _316 = _314 & 63;
  float _352;
  float _353;
  float _354;
  float _603;
  float _659;
  float _715;
  float _718;
  float _719;
  float _720;
  float _731;
  float _863;
  float _864;
  float _865;
  float _911;
  float _912;
  float _913;
  float _951;
  float _965;
  float _979;
  float _980;
  float _981;
  if (_312) {
    bool _319 = ((PostProcess.Settings[10].x) > 0.0f);
    int _322 = asint((Global.c[1].w));
    int _323 = select(_319, _322, 0);
    float4 _324 = sBlueNoiseR8G8.Load(int4(_315, _316, _323, 0));
    float _327 = _324.x * -2.0f;
    float _328 = _324.x * 2.0f;
    float _329 = _327 * _324.y;
    float _330 = _328 * _324.y;
    float _331 = _329 + _324.x;
    float _332 = _330 - _324.x;
    _352 = _331;
    _353 = _332;
    _354 = _332;
  } else {
    float4 _334 = sBlueNoiseR8.Load(int4(_315, _316, 0, 0));
    float _336 = _334.x - _306.x;
    float _337 = _334.x - _306.y;
    float _338 = _334.x - _306.z;
    float _339 = _336 * 0.5f;
    float _340 = _337 * 0.5f;
    float _341 = _338 * 0.5f;
    float _342 = _339 + _306.x;
    float _343 = _340 + _306.y;
    float _344 = _341 + _306.z;
    float _345 = _342 * 2.0f;
    float _346 = _343 * 2.0f;
    float _347 = _344 * 2.0f;
    float _348 = _345 + -1.0f;
    float _349 = _346 + -1.0f;
    float _350 = _347 + -1.0f;
    _352 = _348;
    _353 = _349;
    _354 = _350;
  }
  float _355 = _296 + 1.0f;
  float _356 = _296 / _355;
  float _357 = _356 + -9.999999747378752e-05f;
  float _358 = _357 * 1111.111083984375f;
  float _359 = saturate(_358);
  float _360 = _359 * 2.0f;
  float _361 = 3.0f - _360;
  float _362 = _359 * _359;
  float _363 = _362 * _361;
  float _367 = (PostProcess.Settings[2].y) - (PostProcess.Settings[2].x);
  float _368 = _367 * _356;
  float _369 = _368 + (PostProcess.Settings[2].x);
  float _370 = _363 * _352;
  float _371 = _370 * _369;
  float _372 = _363 * _353;
  float _373 = _372 * _369;
  float _374 = _363 * _354;
  float _375 = _374 * _369;
  float _376 = _371 + _293;
  float _377 = _373 + _294;
  float _378 = _375 + _295;
  float _379 = max(0.0f, _376);
  float _380 = max(0.0f, _377);
  float _381 = max(0.0f, _378);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_379, _380, _381),
      apt_lut_output);
  _379 = apt_film_grain_output.x;
  _380 = apt_film_grain_output.y;
  _381 = apt_film_grain_output.z;
  float _385 = (User.c[2].y) / (User.c[2].x);
  int _388 = asint((Global.c[1].w));
  uint _389 = _388 + 30u;
  int _390 = _389 & 63;
  float _391 = _49 * 8.0f;
  float _392 = _391 * _385;
  float _393 = _50 * 8.0f;
  float _394 = float((int)(_388));
  float4 _395 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_392, _393, _394), 0.0f);
  float _397 = _49 + 0.5f;
  float _398 = (User.c[2].x) * 0.5f;
  float _399 = _397 + _398;
  float _400 = _385 * 8.0f;
  float _401 = _400 * _399;
  float _402 = _50 + 0.5f;
  float _403 = (User.c[2].y) * 0.5f;
  float _404 = _402 + _403;
  float _405 = _404 * 8.0f;
  float _406 = float((int)(_390));
  float4 _407 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_401, _405, _406), 0.0f);
  float _409 = _407.x + _395.x;
  float _410 = _409 * 0.714285671710968f;
  float _411 = _410 + -0.2142857164144516f;
  float _412 = saturate(_411);
  float _413 = _412 * 2.0f;
  float _414 = 3.0f - _413;
  float _415 = _412 * _412;
  float _416 = _415 * _414;
  float _417 = _416 * 0.5f;
  float _418 = _416 * 0.4000000059604645f;
  float _419 = _416 * 0.05000000074505806f;
  float _420 = _417 + -0.5f;
  float _421 = _418 + -0.6000000238418579f;
  float _422 = _419 + -0.949999988079071f;
  float _423 = _420 * _131;
  float _424 = _421 * _131;
  float _425 = _422 * _131;
  float _426 = _423 + 1.0f;
  float _427 = _424 + 1.0f;
  float _428 = _425 + 1.0f;
  float _429 = _426 * _379;
  float _430 = _427 * _380;
  float _431 = _428 * _381;
  float4 _432 = s13.Sample(s13Sampler, float2(_49, _50));
  float _439 = _146 + 1.0f;
  float _440 = saturate(_439);
  float _441 = (User.c[2].x) * _440;
  float _442 = (User.c[2].y) * _440;
  float _443 = _441 + _49;
  float _444 = _442 + _50;
  float4 _445 = s13.Sample(s13Sampler, float2(_443, _444));
  float _449 = _445.x + _432.x;
  float _450 = _445.y + _432.y;
  float _451 = _445.z + _432.z;
  float _452 = _450 * 0.5f;
  float _453 = _451 * 0.5f;
  float _454 = _353 * 0.30000001192092896f;
  float _455 = _454 + 0.699999988079071f;
  float _456 = saturate(_455);
  float _457 = _456 * 0.5f;
  float _458 = _457 * _449;
  float _459 = _452 * _456;
  float _460 = _453 * _456;
  float _461 = _131 * 0.6000000238418579f;
  float _462 = _461 * _129;
  float _463 = _131 * 0.7300000190734863f;
  float _464 = _463 * _129;
  float _465 = _131 * 0.8799999952316284f;
  float _466 = _465 * _129;
  float _467 = 1.0f - _462;
  float _468 = 1.0f - _464;
  float _469 = 1.0f - _466;
  float _470 = saturate(_467);
  float _471 = saturate(_468);
  float _472 = saturate(_469);
  float _473 = _429 * _470;
  float _474 = _430 * _471;
  float _475 = _431 * _472;
  float _476 = _473 + _458;
  float _477 = _474 + _459;
  float _478 = _475 + _460;
  bool _481 = ((User.c[3].x) > 0.0f) && !APTIsPsychoV();
  if (_481) {
    float _483 = log2(_476);
    float _484 = _483 * 3.0f;
    float _485 = exp2(_484);
    float _486 = _485 + -1.0f;
    float _487 = _476 + -1.0f;
    float _488 = _486 / _487;
    float _489 = _488 + -1.0f;
    bool _490 = !(_476 == 1.0f);
    float _491 = _489 / _488;
    float _492 = select(_490, _491, 0.6666666865348816f);
    float _493 = log2(_477);
    float _494 = _493 * 3.0f;
    float _495 = exp2(_494);
    float _496 = _495 + -1.0f;
    float _497 = _477 + -1.0f;
    float _498 = _496 / _497;
    float _499 = _498 + -1.0f;
    bool _500 = !(_477 == 1.0f);
    float _501 = _499 / _498;
    float _502 = select(_500, _501, 0.6666666865348816f);
    float _503 = log2(_478);
    float _504 = _503 * 3.0f;
    float _505 = exp2(_504);
    float _506 = _505 + -1.0f;
    float _507 = _478 + -1.0f;
    float _508 = _506 / _507;
    float _509 = _508 + -1.0f;
    bool _510 = !(_478 == 1.0f);
    float _511 = _509 / _508;
    float _512 = select(_510, _511, 0.6666666865348816f);
    bool _513 = (_492 <= 0.0031308000907301903f);
    bool _514 = (_502 <= 0.0031308000907301903f);
    bool _515 = (_512 <= 0.0031308000907301903f);
    float _516 = _492 * 12.920000076293945f;
    float _517 = _502 * 12.920000076293945f;
    float _518 = _512 * 12.920000076293945f;
    float _519 = log2(_492);
    float _520 = log2(_502);
    float _521 = log2(_512);
    float _522 = _519 * 0.4166666567325592f;
    float _523 = _520 * 0.4166666567325592f;
    float _524 = _521 * 0.4166666567325592f;
    float _525 = exp2(_522);
    float _526 = exp2(_523);
    float _527 = exp2(_524);
    float _528 = _525 * 1.0549999475479126f;
    float _529 = _526 * 1.0549999475479126f;
    float _530 = _527 * 1.0549999475479126f;
    float _531 = _528 + -0.054999999701976776f;
    float _532 = _529 + -0.054999999701976776f;
    float _533 = _530 + -0.054999999701976776f;
    float _534 = select(_513, _516, _531);
    float _535 = select(_514, _517, _532);
    float _536 = select(_515, _518, _533);
    int _538 = asint((User.c[3].y));
    int _539 = _538 & 1;
    bool _540 = (_539 == 0);
    if (!_540) {
      bool _549 = !(_534 <= (User.c[4].x));
      if (!_549) {
        float _551 = max(9.999999974752427e-07f, (User.c[4].x));
        float _552 = _534 / _551;
        float _553 = _552 * (User.c[4].y);
        float _554 = _552 * _552;
        float _555 = _554 * _552;
        float _556 = _555 - _552;
        float _557 = (User.c[3].z) * 0.1666666716337204f;
        float _558 = _551 * _551;
        float _559 = _558 * _557;
        float _560 = _559 * _556;
        float _561 = _560 + _553;
        _603 = _561;
      } else {
        bool _563 = !(_534 <= (User.c[4].z));
        if (!_563) {
          float _565 = (User.c[4].z) - (User.c[4].x);
          float _566 = max(9.999999974752427e-07f, _565);
          float _567 = _534 - (User.c[4].x);
          float _568 = _567 / _566;
          float _569 = 1.0f - _568;
          float _570 = _569 * (User.c[4].y);
          float _571 = _568 * (User.c[4].w);
          float _572 = _570 + _571;
          float _573 = _569 * _569;
          float _574 = _573 * _569;
          float _575 = _574 - _569;
          float _576 = _575 * (User.c[3].z);
          float _577 = _568 * _568;
          float _578 = _577 * _568;
          float _579 = _578 - _568;
          float _580 = _579 * (User.c[3].w);
          float _581 = _576 + _580;
          float _582 = _566 * _566;
          float _583 = _582 * 0.1666666716337204f;
          float _584 = _583 * _581;
          float _585 = _572 + _584;
          _603 = _585;
        } else {
          float _587 = 1.0f - (User.c[4].z);
          float _588 = _534 - (User.c[4].z);
          float _589 = max(9.999999974752427e-07f, _587);
          float _590 = _588 / _589;
          float _591 = 1.0f - _590;
          float _592 = _591 * (User.c[4].w);
          float _593 = _592 + _590;
          float _594 = _591 * _591;
          float _595 = _594 * _591;
          float _596 = _595 - _591;
          float _597 = _587 * _587;
          float _598 = _597 * 0.1666666716337204f;
          float _599 = _598 * (User.c[3].w);
          float _600 = _599 * _596;
          float _601 = _593 + _600;
          _603 = _601;
        }
      }
      float _604 = saturate(_603);
      bool _605 = !(_535 <= (User.c[4].x));
      if (!_605) {
        float _607 = max(9.999999974752427e-07f, (User.c[4].x));
        float _608 = _535 / _607;
        float _609 = _608 * (User.c[4].y);
        float _610 = _608 * _608;
        float _611 = _610 * _608;
        float _612 = _611 - _608;
        float _613 = (User.c[3].z) * 0.1666666716337204f;
        float _614 = _607 * _607;
        float _615 = _614 * _613;
        float _616 = _615 * _612;
        float _617 = _616 + _609;
        _659 = _617;
      } else {
        bool _619 = !(_535 <= (User.c[4].z));
        if (!_619) {
          float _621 = (User.c[4].z) - (User.c[4].x);
          float _622 = max(9.999999974752427e-07f, _621);
          float _623 = _535 - (User.c[4].x);
          float _624 = _623 / _622;
          float _625 = 1.0f - _624;
          float _626 = _625 * (User.c[4].y);
          float _627 = _624 * (User.c[4].w);
          float _628 = _626 + _627;
          float _629 = _625 * _625;
          float _630 = _629 * _625;
          float _631 = _630 - _625;
          float _632 = _631 * (User.c[3].z);
          float _633 = _624 * _624;
          float _634 = _633 * _624;
          float _635 = _634 - _624;
          float _636 = _635 * (User.c[3].w);
          float _637 = _632 + _636;
          float _638 = _622 * _622;
          float _639 = _638 * 0.1666666716337204f;
          float _640 = _639 * _637;
          float _641 = _628 + _640;
          _659 = _641;
        } else {
          float _643 = 1.0f - (User.c[4].z);
          float _644 = _535 - (User.c[4].z);
          float _645 = max(9.999999974752427e-07f, _643);
          float _646 = _644 / _645;
          float _647 = 1.0f - _646;
          float _648 = _647 * (User.c[4].w);
          float _649 = _648 + _646;
          float _650 = _647 * _647;
          float _651 = _650 * _647;
          float _652 = _651 - _647;
          float _653 = _643 * _643;
          float _654 = _653 * 0.1666666716337204f;
          float _655 = _654 * (User.c[3].w);
          float _656 = _655 * _652;
          float _657 = _649 + _656;
          _659 = _657;
        }
      }
      float _660 = saturate(_659);
      bool _661 = !(_536 <= (User.c[4].x));
      if (!_661) {
        float _663 = max(9.999999974752427e-07f, (User.c[4].x));
        float _664 = _536 / _663;
        float _665 = _664 * (User.c[4].y);
        float _666 = _664 * _664;
        float _667 = _666 * _664;
        float _668 = _667 - _664;
        float _669 = (User.c[3].z) * 0.1666666716337204f;
        float _670 = _663 * _663;
        float _671 = _670 * _669;
        float _672 = _671 * _668;
        float _673 = _672 + _665;
        _715 = _673;
      } else {
        bool _675 = !(_536 <= (User.c[4].z));
        if (!_675) {
          float _677 = (User.c[4].z) - (User.c[4].x);
          float _678 = max(9.999999974752427e-07f, _677);
          float _679 = _536 - (User.c[4].x);
          float _680 = _679 / _678;
          float _681 = 1.0f - _680;
          float _682 = _681 * (User.c[4].y);
          float _683 = _680 * (User.c[4].w);
          float _684 = _682 + _683;
          float _685 = _681 * _681;
          float _686 = _685 * _681;
          float _687 = _686 - _681;
          float _688 = _687 * (User.c[3].z);
          float _689 = _680 * _680;
          float _690 = _689 * _680;
          float _691 = _690 - _680;
          float _692 = _691 * (User.c[3].w);
          float _693 = _688 + _692;
          float _694 = _678 * _678;
          float _695 = _694 * 0.1666666716337204f;
          float _696 = _695 * _693;
          float _697 = _684 + _696;
          _715 = _697;
        } else {
          float _699 = 1.0f - (User.c[4].z);
          float _700 = _536 - (User.c[4].z);
          float _701 = max(9.999999974752427e-07f, _699);
          float _702 = _700 / _701;
          float _703 = 1.0f - _702;
          float _704 = _703 * (User.c[4].w);
          float _705 = _704 + _702;
          float _706 = _703 * _703;
          float _707 = _706 * _703;
          float _708 = _707 - _703;
          float _709 = _699 * _699;
          float _710 = _709 * 0.1666666716337204f;
          float _711 = _710 * (User.c[3].w);
          float _712 = _711 * _708;
          float _713 = _705 + _712;
          _715 = _713;
        }
      }
      float _716 = saturate(_715);
      _718 = _604;
      _719 = _660;
      _720 = _716;
    } else {
      _718 = _534;
      _719 = _535;
      _720 = _536;
    }
    int _721 = _538 & 2;
    bool _722 = (_721 == 0);
    if (!_722) {
      float _724 = sqrt(_718);
      float _725 = sqrt(_719);
      float _726 = sqrt(_720);
      float _727 = dot(float3(_724, _725, _726), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _728 = 1.0f - _727;
      float _729 = saturate(_728);
      _731 = _729;
    } else {
      _731 = 1.0f;
    }
    int _732 = _538 & 8;
    bool _733 = (_732 == 0);
    if (!_733) {
      bool _735 = (_731 <= 0.0031308000907301903f);
      float _736 = _731 * 12.920000076293945f;
      float _737 = log2(_731);
      float _738 = _737 * 0.4166666567325592f;
      float _739 = exp2(_738);
      float _740 = _739 * 1.0549999475479126f;
      float _741 = _740 + -0.054999999701976776f;
      float _742 = select(_735, _736, _741);
      _979 = _742;
      _980 = _742;
      _981 = _742;
    } else {
      int _744 = _538 & 4;
      bool _745 = (_744 == 0);
      if (!_745) {
        int _747 = _538 & 16;
        bool _748 = (_747 == 0);
        if (!_748) {
          float _752 = (User.c[5].x) * 0.5f;
          float _753 = _752 + 0.5f;
          bool _754 = (_753 < 0.5f);
          float _755 = (User.c[5].x) * 5.0f;
          float _756 = select(_754, (User.c[5].x), _755);
          bool _757 = (_719 < _720);
          float _758 = select(_757, _720, _719);
          float _759 = select(_757, _719, _720);
          bool _760 = (_718 < _758);
          float _761 = select(_760, _758, _718);
          float _762 = select(_760, _718, _758);
          float _763 = min(_762, _759);
          float _764 = _761 - _763;
          float _765 = _761 + 1.000000013351432e-10f;
          float _766 = _764 / _765;
          float _768 = _766 - (User.c[5].y);
          float _769 = saturate(_768);
          float _770 = max(_769, 9.999999974752427e-07f);
          float _771 = log2(_770);
          float _772 = _771 * _756;
          float _773 = exp2(_772);
          float _774 = 2.0f - _773;
          float _776 = 1.0f - (User.c[5].z);
          float _777 = saturate(_776);
          float _778 = max(_777, _774);
          float _779 = dot(float3(_718, _719, _720), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _780 = _718 - _779;
          float _781 = _719 - _779;
          float _782 = _720 - _779;
          float _783 = _780 * _778;
          float _784 = _781 * _778;
          float _785 = _782 * _778;
          float _786 = _779 - _718;
          float _787 = _786 + _783;
          float _788 = _779 - _719;
          float _789 = _788 + _784;
          float _790 = _779 - _720;
          float _791 = _790 + _785;
          float _792 = _787 * _731;
          float _793 = _789 * _731;
          float _794 = _791 * _731;
          float _795 = _792 + _718;
          float _796 = _793 + _719;
          float _797 = _794 + _720;
          _911 = _795;
          _912 = _796;
          _913 = _797;
        } else {
          bool _799 = (_731 == 0.0f);
          if (!_799) {
            float _803 = abs(User.c[5].x);
            float _804 = saturate(_803);
            uint2 _805; s15.GetDimensions(_805.x, _805.y);
            float _808 = float((uint)_805.y);
            int _809 = _538 & 32;
            bool _810 = (_809 == 0);
            float _811 = _808 + -1.0f;
            if (!_810) {
              float _813 = 1.0f / _811;
              uint _814 = uint(SV_Position.x);
              uint _815 = uint(SV_Position.y);
              int _816 = _814 & 63;
              int _817 = _815 & 63;
              float4 _818 = sBlueNoiseR8G8.Load(int4(_816, _817, 0, 0));
              float _821 = _818.x + -0.5f;
              float _822 = _718 * 13.999999046325684f;
              float _823 = _719 * 13.999999046325684f;
              float _824 = _720 * 13.999999046325684f;
              float _825 = saturate(_822);
              float _826 = saturate(_823);
              float _827 = saturate(_824);
              float _828 = _718 + -0.9285714030265808f;
              float _829 = _719 + -0.9285714030265808f;
              float _830 = _720 + -0.9285714030265808f;
              float _831 = _828 * 13.999999046325684f;
              float _832 = _829 * 13.999999046325684f;
              float _833 = _830 * 13.999999046325684f;
              float _834 = saturate(_831);
              float _835 = saturate(_832);
              float _836 = saturate(_833);
              float _837 = 1.0f - _834;
              float _838 = 1.0f - _835;
              float _839 = 1.0f - _836;
              float _840 = min(_825, _837);
              float _841 = min(_826, _838);
              float _842 = min(_827, _839);
              float _843 = _818.y + -0.5f;
              float _844 = _840 * _843;
              float _845 = _841 * _843;
              float _846 = _842 * _843;
              float _847 = _844 + _821;
              float _848 = _845 + _821;
              float _849 = _846 + _821;
              float _850 = _847 * _813;
              float _851 = _848 * _813;
              float _852 = _849 * _813;
              float _853 = _850 + _718;
              float _854 = _851 + _719;
              float _855 = _852 + _720;
              float _856 = saturate(_853);
              float _857 = saturate(_854);
              float _858 = saturate(_855);
              float _859 = saturate(_856);
              float _860 = saturate(_857);
              float _861 = saturate(_858);
              _863 = _859;
              _864 = _860;
              _865 = _861;
            } else {
              _863 = _718;
              _864 = _719;
              _865 = _720;
            }
            float _866 = float((uint)_805.x);
            float _867 = _811 / _866;
            float _868 = _867 * _863;
            float _869 = 0.5f / _866;
            float _870 = _868 + _869;
            float _871 = _811 / _808;
            float _872 = _871 * _864;
            float _873 = 0.5f / _808;
            float _874 = _872 + _873;
            float _875 = _865 * _811;
            float _876 = floor(_875);
            float _877 = frac(_875);
            float _878 = _876 / _808;
            float _879 = _878 + _870;
            float _880 = _876 + 1.0f;
            float _881 = _880 / _808;
            float _882 = _881 + _870;
            float4 _883 = s15.Sample(s15Sampler, float2(_879, _874));
            float4 _887 = s15.Sample(s15Sampler, float2(_882, _874));
            float _891 = _887.x - _883.x;
            float _892 = _887.y - _883.y;
            float _893 = _887.z - _883.z;
            float _894 = _891 * _877;
            float _895 = _892 * _877;
            float _896 = _893 * _877;
            float _897 = _804 * _731;
            float _898 = _883.x - _718;
            float _899 = _898 + _894;
            float _900 = _883.y - _719;
            float _901 = _900 + _895;
            float _902 = _883.z - _720;
            float _903 = _902 + _896;
            float _904 = _899 * _897;
            float _905 = _901 * _897;
            float _906 = _903 * _897;
            float _907 = _904 + _718;
            float _908 = _905 + _719;
            float _909 = _906 + _720;
            _911 = _907;
            _912 = _908;
            _913 = _909;
          } else {
            _911 = _718;
            _912 = _719;
            _913 = _720;
          }
        }
      } else {
        _911 = _718;
        _912 = _719;
        _913 = _720;
      }
      bool _914 = (_911 <= 0.040449999272823334f);
      bool _915 = (_912 <= 0.040449999272823334f);
      bool _916 = (_913 <= 0.040449999272823334f);
      float _917 = _911 * 0.07739938050508499f;
      float _918 = _912 * 0.07739938050508499f;
      float _919 = _913 * 0.07739938050508499f;
      float _920 = _911 + 0.054999999701976776f;
      float _921 = _912 + 0.054999999701976776f;
      float _922 = _913 + 0.054999999701976776f;
      float _923 = _920 * 0.9478673338890076f;
      float _924 = _921 * 0.9478673338890076f;
      float _925 = _922 * 0.9478673338890076f;
      float _926 = log2(_923);
      float _927 = log2(_924);
      float _928 = log2(_925);
      float _929 = _926 * 2.4000000953674316f;
      float _930 = _927 * 2.4000000953674316f;
      float _931 = _928 * 2.4000000953674316f;
      float _932 = exp2(_929);
      float _933 = exp2(_930);
      float _934 = exp2(_931);
      float _935 = select(_914, _917, _932);
      float _936 = select(_915, _918, _933);
      float _937 = select(_916, _919, _934);
      bool _938 = (_935 == 1.0f);
      if (!_938) {
        float _940 = _935 * _935;
        float _941 = _940 * 3.0f;
        float _942 = _935 * 2.0f;
        float _943 = _942 + 1.0f;
        float _944 = _943 - _941;
        float _945 = sqrt(_944);
        float _946 = _935 + -1.0f;
        float _947 = _946 * 2.0f;
        float _948 = _945 / _947;
        float _949 = -0.5f - _948;
        _951 = _949;
      } else {
        _951 = 1e+06f;
      }
      bool _952 = (_936 == 1.0f);
      if (!_952) {
        float _954 = _936 * _936;
        float _955 = _954 * 3.0f;
        float _956 = _936 * 2.0f;
        float _957 = _956 + 1.0f;
        float _958 = _957 - _955;
        float _959 = sqrt(_958);
        float _960 = _936 + -1.0f;
        float _961 = _960 * 2.0f;
        float _962 = _959 / _961;
        float _963 = -0.5f - _962;
        _965 = _963;
      } else {
        _965 = 1e+06f;
      }
      bool _966 = (_937 == 1.0f);
      if (!_966) {
        float _968 = _937 * _937;
        float _969 = _968 * 3.0f;
        float _970 = _937 * 2.0f;
        float _971 = _970 + 1.0f;
        float _972 = _971 - _969;
        float _973 = sqrt(_972);
        float _974 = _937 + -1.0f;
        float _975 = _974 * 2.0f;
        float _976 = _973 / _975;
        float _977 = -0.5f - _976;
        _979 = _951;
        _980 = _965;
        _981 = _977;
      } else {
        _979 = _951;
        _980 = _965;
        _981 = 1e+06f;
      }
    }
  } else {
    _979 = _476;
    _980 = _477;
    _981 = _478;
  }
  float _982 = log2(_979);
  float _983 = _982 * 3.0f;
  float _984 = exp2(_983);
  float _985 = _984 + -1.0f;
  float _986 = _979 + -1.0f;
  float _987 = _985 / _986;
  float _988 = _987 + -1.0f;
  bool _989 = !(_979 == 1.0f);
  float _990 = _988 / _987;
  float _991 = select(_989, _990, 0.6666666865348816f);
  float _992 = log2(_980);
  float _993 = _992 * 3.0f;
  float _994 = exp2(_993);
  float _995 = _994 + -1.0f;
  float _996 = _980 + -1.0f;
  float _997 = _995 / _996;
  float _998 = _997 + -1.0f;
  bool _999 = !(_980 == 1.0f);
  float _1000 = _998 / _997;
  float _1001 = select(_999, _1000, 0.6666666865348816f);
  float _1002 = log2(_981);
  float _1003 = _1002 * 3.0f;
  float _1004 = exp2(_1003);
  float _1005 = _1004 + -1.0f;
  float _1006 = _981 + -1.0f;
  float _1007 = _1005 / _1006;
  float _1008 = _1007 + -1.0f;
  bool _1009 = !(_981 == 1.0f);
  float _1010 = _1008 / _1007;
  float _1011 = select(_1009, _1010, 0.6666666865348816f);
  float _1012 = saturate(_991);
  float _1013 = saturate(_1001);
  float _1014 = saturate(_1011);
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_476, _477, _478),
      float3(_1012, _1013, _1014),
      false);
  _1012 = apt_tonemapped.x;
  _1013 = apt_tonemapped.y;
  _1014 = apt_tonemapped.z;
  bool _1015 = (_1012 <= 0.0031308000907301903f);
  bool _1016 = (_1013 <= 0.0031308000907301903f);
  bool _1017 = (_1014 <= 0.0031308000907301903f);
  float _1018 = _1012 * 12.920000076293945f;
  float _1019 = _1013 * 12.920000076293945f;
  float _1020 = _1014 * 12.920000076293945f;
  float _1021 = log2(_1012);
  float _1022 = log2(_1013);
  float _1023 = log2(_1014);
  float _1024 = _1021 * 0.4166666567325592f;
  float _1025 = _1022 * 0.4166666567325592f;
  float _1026 = _1023 * 0.4166666567325592f;
  float _1027 = exp2(_1024);
  float _1028 = exp2(_1025);
  float _1029 = exp2(_1026);
  float _1030 = _1027 * 1.0549999475479126f;
  float _1031 = _1028 * 1.0549999475479126f;
  float _1032 = _1029 * 1.0549999475479126f;
  float _1033 = _1030 + -0.054999999701976776f;
  float _1034 = _1031 + -0.054999999701976776f;
  float _1035 = _1032 + -0.054999999701976776f;
  float _1036 = select(_1015, _1018, _1033);
  float _1037 = select(_1016, _1019, _1034);
  float _1038 = select(_1017, _1020, _1035);
  int _1041 = asint((Global.c[1].w));
  uint _1042 = uint(SV_Position.x);
  uint _1043 = uint(SV_Position.y);
  int _1044 = _1042 & 63;
  int _1045 = _1043 & 63;
  float4 _1046 = sBlueNoiseR8.Load(int4(_1044, _1045, _1041, 0));
  float _1048 = _1046.x * 0.003921568859368563f;
  float _1049 = _1036 + 0.003921568859368563f;
  float _1050 = _1049 - _1048;
  float _1051 = _1048 + _1037;
  float _1052 = _1048 + _1038;
  SV_Target.x = _1050;
  SV_Target.y = _1051;
  SV_Target.z = _1052;
  SV_Target.w = _103.w;
  if (APTIsPsychoV()) {
    SV_Target.rgb = APTRenderIntermediatePassDithered(
        apt_tonemapped,
        SV_Position.xy);
  }
  return SV_Target;
}
