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
  float _37 = _35.y * 0.10000000149011612f;
  float _38 = _37 + _31.y;
  float _39 = _35.y * 0.5f;
  float _40 = _39 + _31.z;
  float _41 = exp2(_40);
  float _42 = _41 + -1.0f;
  float _45 = (PostProcess.Settings[11].y) * _42;
  float _46 = _45 + 1.0f;
  float _47 = log2(_46);
  float _48 = _31.x + TEXCOORD.z;
  float _49 = _38 + TEXCOORD.w;
  float _50 = _31.x + TEXCOORD.x;
  float _51 = _38 + TEXCOORD.y;
  float4 _52 = s0.SampleLevel(s0Sampler, float2(_48, _49), _47);
  float _57 = max(_52.x, 0.0f);
  float _58 = max(_52.y, 0.0f);
  float _59 = max(_52.z, 0.0f);
  float _62 = (Global.c[32].w) * 11.0f;
  float _63 = _62 + -1.2000000476837158f;
  float _64 = saturate(_63);
  float _65 = (Global.c[32].w) * 1.7000000476837158f;
  float _66 = 1.340000033378601f - _65;
  float _67 = saturate(_66);
  float _68 = _67 * _67;
  float _69 = _68 * _68;
  float _70 = _69 * _64;
  bool _71 = ((Global.c[32].w) < 9.999999747378752e-06f);
  float _74 = max((Global.c[33].y), _70);
  float _75 = _48 * 2.0f;
  float _76 = _49 * 1.7999999523162842f;
  float _77 = _75 + -1.0f;
  float _78 = _76 + -1.100000023841858f;
  float _79 = abs(_77);
  float _80 = abs(_78);
  float _81 = dot(float2(_79, _80), float2(_79, _80));
  float _82 = sqrt(_81);
  float _83 = select(_71, 1.0f, 0.0f);
  float _84 = _83 * _74;
  float4 _85 = s0.SampleLevel(s0Sampler, float2(_48, _49), 1.0f);
  float4 _89 = s0.SampleLevel(s0Sampler, float2(_48, _49), 2.0f);
  float4 _93 = s0.SampleLevel(s0Sampler, float2(_48, _49), 3.0f);
  float _97 = _81 * 1.7000000476837158f;
  float _98 = _97 + -0.6000000238418579f;
  float _99 = saturate(_98);
  float _100 = _81 * 1.475000023841858f;
  float _101 = _100 + -0.375f;
  float _102 = saturate(_101);
  float _103 = _81 * 1.2999999523162842f;
  float _104 = _103 + -0.15000000596046448f;
  float _105 = saturate(_104);
  float _106 = _93.x - _89.x;
  float _107 = _93.y - _89.y;
  float _108 = _93.z - _89.z;
  float _109 = _106 * _99;
  float _110 = _107 * _99;
  float _111 = _108 * _99;
  float _112 = _89.x - _85.x;
  float _113 = _112 + _109;
  float _114 = _89.y - _85.y;
  float _115 = _114 + _110;
  float _116 = _89.z - _85.z;
  float _117 = _116 + _111;
  float _118 = _113 * _102;
  float _119 = _115 * _102;
  float _120 = _117 * _102;
  float _121 = _105 * _84;
  float _122 = _85.x - _57;
  float _123 = _122 + _118;
  float _124 = _85.y - _58;
  float _125 = _124 + _119;
  float _126 = _85.z - _59;
  float _127 = _126 + _120;
  float _128 = _123 * _121;
  float _129 = _125 * _121;
  float _130 = _127 * _121;
  float _131 = _128 + _57;
  float _132 = _129 + _58;
  float _133 = _130 + _59;
  float4 _134 = s12_bloom.Sample(s12_bloomSampler, float2(_48, _49));
  float4 _138 = s8.Sample(s8Sampler, float2(_50, _51));
  float _145 = (PostProcess.Settings[4].w) * _138.x;
  float _146 = (PostProcess.Settings[4].w) * _138.y;
  float _147 = (PostProcess.Settings[4].w) * _138.z;
  float _148 = _145 + (PostProcess.Settings[4].z);
  float _149 = _146 + (PostProcess.Settings[4].z);
  float _150 = _147 + (PostProcess.Settings[4].z);
  float _151 = saturate(_148);
  float _152 = saturate(_149);
  float _153 = saturate(_150);
  float _154 = _134.x - _131;
  float _155 = _134.y - _132;
  float _156 = _134.z - _133;
  float _157 = _151 * _154;
  float _158 = _152 * _155;
  float _159 = _153 * _156;
  float _160 = _157 + _131;
  float _161 = _158 + _132;
  float _162 = _159 + _133;
  float4 _163 = s6.Load(int3(0, 0, 0));
  float _165 = _163.x * _160;
  float _166 = _163.x * _161;
  float _167 = _163.x * _162;
  float _172 = _49 * 2.0f;
  float _173 = _172 + -1.0f;
  float _176 = (PostProcess.Settings[13].w) * _173;
  float _177 = _77 * _77;
  float _178 = _176 * _176;
  float _179 = _178 + _177;
  float _180 = sqrt(_179);
  float _182 = (PostProcess.Settings[13].x) * _180;
  float _184 = _182 + (PostProcess.Settings[13].y);
  float _185 = saturate(_184);
  float _187 = log2(_185);
  float _188 = _187 * (PostProcess.Settings[13].z);
  float _189 = exp2(_188);
  float _190 = _165 * (PostProcess.Settings[12].x);
  float _191 = _166 * (PostProcess.Settings[12].y);
  float _192 = _167 * (PostProcess.Settings[12].z);
  float _193 = _190 - _165;
  float _194 = _191 - _166;
  float _195 = _192 - _167;
  float _196 = _189 * _193;
  float _197 = _189 * _194;
  float _198 = _189 * _195;
  float _199 = _196 + _165;
  float _200 = _197 + _166;
  float _201 = _198 + _167;
  float _204 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _205 = _199 * 11190.6005859375f;
  float _206 = _205 * _204;
  float _207 = _200 * 11190.6005859375f;
  float _208 = _207 * _204;
  float _209 = _201 * 11190.6005859375f;
  float _210 = _209 * _204;
  float _211 = _206 + 1.0f;
  float _212 = _208 + 1.0f;
  float _213 = _210 + 1.0f;
  float _214 = log2(_211);
  float _215 = log2(_212);
  float _216 = log2(_213);
  float _217 = _214 * 0.07434873282909393f;
  float _218 = _215 * 0.07434873282909393f;
  float _219 = _216 * 0.07434873282909393f;
  float _222 = _217 * (PostProcess.OffsetWeight[0].x);
  float _223 = _218 * (PostProcess.OffsetWeight[0].x);
  float _224 = _219 * (PostProcess.OffsetWeight[0].x);
  float _226 = _222 + (PostProcess.OffsetWeight[0].y);
  float _227 = _223 + (PostProcess.OffsetWeight[0].y);
  float _228 = _224 + (PostProcess.OffsetWeight[0].y);
  float4 _229 = s3_3D.Sample(s3_3DSampler, float3(_226, _227, _228));
  float _235 = _229.x * 13.450128555297852f;
  float _236 = _229.y * 13.450128555297852f;
  float _237 = _229.z * 13.450128555297852f;
  float _238 = exp2(_235);
  float _239 = exp2(_236);
  float _240 = exp2(_237);
  float _241 = _238 + -1.0f;
  float _242 = _239 + -1.0f;
  float _243 = _240 + -1.0f;
  float _244 = _241 * 8.936070662457496e-05f;
  float _245 = _242 * 8.936070662457496e-05f;
  float _246 = _243 * 8.936070662457496e-05f;
  float _247 = 10000.0f / (PostProcess.Settings[10].w);
  float _248 = _244 * _247;
  float _249 = _245 * _247;
  float _250 = _246 * _247;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUTScaling(
      float3(_206, _208, _210) / apt_lut_input_encode_scale,
      float3(_248, _249, _250),
      s3_3D,
      s3_3DSampler,
      apt_lut_input_encode_scale,
      PostProcess.OffsetWeight[0].x,
      PostProcess.OffsetWeight[0].y,
      8.936070662457496e-05f * (10000.0f / PostProcess.Settings[10].w));
  _248 = apt_lut_output.x;
  _249 = apt_lut_output.y;
  _250 = apt_lut_output.z;
  float _251 = dot(float3(_248, _249, _250), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _255 = (PostProcess.Settings[9].x) * TEXCOORD.x;
  float _256 = (PostProcess.Settings[9].y) * TEXCOORD.y;
  float _259 = _255 + (PostProcess.Settings[9].z);
  float _260 = _256 + (PostProcess.Settings[9].w);
  float4 _261 = s9.Sample(s9Sampler, float2(_259, _260));
  bool _267 = ((PostProcess.Settings[10].y) > 0.0f);
  uint _268 = uint(SV_Position.x);
  uint _269 = uint(SV_Position.y);
  int _270 = _268 & 63;
  int _271 = _269 & 63;
  float _307;
  float _308;
  float _309;
  float _558;
  float _614;
  float _670;
  float _673;
  float _674;
  float _675;
  float _686;
  float _818;
  float _819;
  float _820;
  float _866;
  float _867;
  float _868;
  float _906;
  float _920;
  float _934;
  float _935;
  float _936;
  if (_267) {
    bool _274 = ((PostProcess.Settings[10].x) > 0.0f);
    int _277 = asint((Global.c[1].w));
    int _278 = select(_274, _277, 0);
    float4 _279 = sBlueNoiseR8G8.Load(int4(_270, _271, _278, 0));
    float _282 = _279.x * -2.0f;
    float _283 = _279.x * 2.0f;
    float _284 = _282 * _279.y;
    float _285 = _283 * _279.y;
    float _286 = _284 + _279.x;
    float _287 = _285 - _279.x;
    _307 = _286;
    _308 = _287;
    _309 = _287;
  } else {
    float4 _289 = sBlueNoiseR8.Load(int4(_270, _271, 0, 0));
    float _291 = _289.x - _261.x;
    float _292 = _289.x - _261.y;
    float _293 = _289.x - _261.z;
    float _294 = _291 * 0.5f;
    float _295 = _292 * 0.5f;
    float _296 = _293 * 0.5f;
    float _297 = _294 + _261.x;
    float _298 = _295 + _261.y;
    float _299 = _296 + _261.z;
    float _300 = _297 * 2.0f;
    float _301 = _298 * 2.0f;
    float _302 = _299 * 2.0f;
    float _303 = _300 + -1.0f;
    float _304 = _301 + -1.0f;
    float _305 = _302 + -1.0f;
    _307 = _303;
    _308 = _304;
    _309 = _305;
  }
  float _310 = _251 + 1.0f;
  float _311 = _251 / _310;
  float _312 = _311 + -9.999999747378752e-05f;
  float _313 = _312 * 1111.111083984375f;
  float _314 = saturate(_313);
  float _315 = _314 * 2.0f;
  float _316 = 3.0f - _315;
  float _317 = _314 * _314;
  float _318 = _317 * _316;
  float _322 = (PostProcess.Settings[2].y) - (PostProcess.Settings[2].x);
  float _323 = _322 * _311;
  float _324 = _323 + (PostProcess.Settings[2].x);
  float _325 = _318 * _307;
  float _326 = _325 * _324;
  float _327 = _318 * _308;
  float _328 = _327 * _324;
  float _329 = _318 * _309;
  float _330 = _329 * _324;
  float _331 = _326 + _248;
  float _332 = _328 + _249;
  float _333 = _330 + _250;
  float _334 = max(0.0f, _331);
  float _335 = max(0.0f, _332);
  float _336 = max(0.0f, _333);
  float _340 = (User.c[2].y) / (User.c[2].x);
  int _343 = asint((Global.c[1].w));
  uint _344 = _343 + 30u;
  int _345 = _344 & 63;
  float _346 = _48 * 8.0f;
  float _347 = _346 * _340;
  float _348 = _49 * 8.0f;
  float _349 = float((int)(_343));
  float4 _350 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_347, _348, _349), 0.0f);
  float _352 = _48 + 0.5f;
  float _353 = (User.c[2].x) * 0.5f;
  float _354 = _352 + _353;
  float _355 = _340 * 8.0f;
  float _356 = _355 * _354;
  float _357 = _49 + 0.5f;
  float _358 = (User.c[2].y) * 0.5f;
  float _359 = _357 + _358;
  float _360 = _359 * 8.0f;
  float _361 = float((int)(_345));
  float4 _362 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_356, _360, _361), 0.0f);
  float _364 = _362.x + _350.x;
  float _365 = _364 * 0.714285671710968f;
  float _366 = _365 + -0.2142857164144516f;
  float _367 = saturate(_366);
  float _368 = _367 * 2.0f;
  float _369 = 3.0f - _368;
  float _370 = _367 * _367;
  float _371 = _370 * _369;
  float _372 = _371 * 0.5f;
  float _373 = _371 * 0.4000000059604645f;
  float _374 = _371 * 0.05000000074505806f;
  float _375 = _372 + -0.5f;
  float _376 = _373 + -0.6000000238418579f;
  float _377 = _374 + -0.949999988079071f;
  float _378 = _375 * _84;
  float _379 = _376 * _84;
  float _380 = _377 * _84;
  float _381 = _378 + 1.0f;
  float _382 = _379 + 1.0f;
  float _383 = _380 + 1.0f;
  float _384 = _381 * _334;
  float _385 = _382 * _335;
  float _386 = _383 * _336;
  float4 _387 = s13.Sample(s13Sampler, float2(_48, _49));
  float _394 = _99 + 1.0f;
  float _395 = saturate(_394);
  float _396 = (User.c[2].x) * _395;
  float _397 = (User.c[2].y) * _395;
  float _398 = _396 + _48;
  float _399 = _397 + _49;
  float4 _400 = s13.Sample(s13Sampler, float2(_398, _399));
  float _404 = _400.x + _387.x;
  float _405 = _400.y + _387.y;
  float _406 = _400.z + _387.z;
  float _407 = _405 * 0.5f;
  float _408 = _406 * 0.5f;
  float _409 = _308 * 0.30000001192092896f;
  float _410 = _409 + 0.699999988079071f;
  float _411 = saturate(_410);
  float _412 = _411 * 0.5f;
  float _413 = _412 * _404;
  float _414 = _407 * _411;
  float _415 = _408 * _411;
  float _416 = _84 * 0.6000000238418579f;
  float _417 = _416 * _82;
  float _418 = _84 * 0.7300000190734863f;
  float _419 = _418 * _82;
  float _420 = _84 * 0.8799999952316284f;
  float _421 = _420 * _82;
  float _422 = 1.0f - _417;
  float _423 = 1.0f - _419;
  float _424 = 1.0f - _421;
  float _425 = saturate(_422);
  float _426 = saturate(_423);
  float _427 = saturate(_424);
  float _428 = _384 * _425;
  float _429 = _385 * _426;
  float _430 = _386 * _427;
  float _431 = _428 + _413;
  float _432 = _429 + _414;
  float _433 = _430 + _415;
  bool _436 = ((User.c[3].x) > 0.0f);
  if (_436) {
    float _438 = log2(_431);
    float _439 = _438 * 3.0f;
    float _440 = exp2(_439);
    float _441 = _440 + -1.0f;
    float _442 = _431 + -1.0f;
    float _443 = _441 / _442;
    float _444 = _443 + -1.0f;
    bool _445 = !(_431 == 1.0f);
    float _446 = _444 / _443;
    float _447 = select(_445, _446, 0.6666666865348816f);
    float _448 = log2(_432);
    float _449 = _448 * 3.0f;
    float _450 = exp2(_449);
    float _451 = _450 + -1.0f;
    float _452 = _432 + -1.0f;
    float _453 = _451 / _452;
    float _454 = _453 + -1.0f;
    bool _455 = !(_432 == 1.0f);
    float _456 = _454 / _453;
    float _457 = select(_455, _456, 0.6666666865348816f);
    float _458 = log2(_433);
    float _459 = _458 * 3.0f;
    float _460 = exp2(_459);
    float _461 = _460 + -1.0f;
    float _462 = _433 + -1.0f;
    float _463 = _461 / _462;
    float _464 = _463 + -1.0f;
    bool _465 = !(_433 == 1.0f);
    float _466 = _464 / _463;
    float _467 = select(_465, _466, 0.6666666865348816f);
    bool _468 = (_447 <= 0.0031308000907301903f);
    bool _469 = (_457 <= 0.0031308000907301903f);
    bool _470 = (_467 <= 0.0031308000907301903f);
    float _471 = _447 * 12.920000076293945f;
    float _472 = _457 * 12.920000076293945f;
    float _473 = _467 * 12.920000076293945f;
    float _474 = log2(_447);
    float _475 = log2(_457);
    float _476 = log2(_467);
    float _477 = _474 * 0.4166666567325592f;
    float _478 = _475 * 0.4166666567325592f;
    float _479 = _476 * 0.4166666567325592f;
    float _480 = exp2(_477);
    float _481 = exp2(_478);
    float _482 = exp2(_479);
    float _483 = _480 * 1.0549999475479126f;
    float _484 = _481 * 1.0549999475479126f;
    float _485 = _482 * 1.0549999475479126f;
    float _486 = _483 + -0.054999999701976776f;
    float _487 = _484 + -0.054999999701976776f;
    float _488 = _485 + -0.054999999701976776f;
    float _489 = select(_468, _471, _486);
    float _490 = select(_469, _472, _487);
    float _491 = select(_470, _473, _488);
    int _493 = asint((User.c[3].y));
    int _494 = _493 & 1;
    bool _495 = (_494 == 0);
    if (!_495) {
      bool _504 = !(_489 <= (User.c[4].x));
      if (!_504) {
        float _506 = max(9.999999974752427e-07f, (User.c[4].x));
        float _507 = _489 / _506;
        float _508 = _507 * (User.c[4].y);
        float _509 = _507 * _507;
        float _510 = _509 * _507;
        float _511 = _510 - _507;
        float _512 = (User.c[3].z) * 0.1666666716337204f;
        float _513 = _506 * _506;
        float _514 = _513 * _512;
        float _515 = _514 * _511;
        float _516 = _515 + _508;
        _558 = _516;
      } else {
        bool _518 = !(_489 <= (User.c[4].z));
        if (!_518) {
          float _520 = (User.c[4].z) - (User.c[4].x);
          float _521 = max(9.999999974752427e-07f, _520);
          float _522 = _489 - (User.c[4].x);
          float _523 = _522 / _521;
          float _524 = 1.0f - _523;
          float _525 = _524 * (User.c[4].y);
          float _526 = _523 * (User.c[4].w);
          float _527 = _525 + _526;
          float _528 = _524 * _524;
          float _529 = _528 * _524;
          float _530 = _529 - _524;
          float _531 = _530 * (User.c[3].z);
          float _532 = _523 * _523;
          float _533 = _532 * _523;
          float _534 = _533 - _523;
          float _535 = _534 * (User.c[3].w);
          float _536 = _531 + _535;
          float _537 = _521 * _521;
          float _538 = _537 * 0.1666666716337204f;
          float _539 = _538 * _536;
          float _540 = _527 + _539;
          _558 = _540;
        } else {
          float _542 = 1.0f - (User.c[4].z);
          float _543 = _489 - (User.c[4].z);
          float _544 = max(9.999999974752427e-07f, _542);
          float _545 = _543 / _544;
          float _546 = 1.0f - _545;
          float _547 = _546 * (User.c[4].w);
          float _548 = _547 + _545;
          float _549 = _546 * _546;
          float _550 = _549 * _546;
          float _551 = _550 - _546;
          float _552 = _542 * _542;
          float _553 = _552 * 0.1666666716337204f;
          float _554 = _553 * (User.c[3].w);
          float _555 = _554 * _551;
          float _556 = _548 + _555;
          _558 = _556;
        }
      }
      float _559 = saturate(_558);
      bool _560 = !(_490 <= (User.c[4].x));
      if (!_560) {
        float _562 = max(9.999999974752427e-07f, (User.c[4].x));
        float _563 = _490 / _562;
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
        bool _574 = !(_490 <= (User.c[4].z));
        if (!_574) {
          float _576 = (User.c[4].z) - (User.c[4].x);
          float _577 = max(9.999999974752427e-07f, _576);
          float _578 = _490 - (User.c[4].x);
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
          float _599 = _490 - (User.c[4].z);
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
      bool _616 = !(_491 <= (User.c[4].x));
      if (!_616) {
        float _618 = max(9.999999974752427e-07f, (User.c[4].x));
        float _619 = _491 / _618;
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
        bool _630 = !(_491 <= (User.c[4].z));
        if (!_630) {
          float _632 = (User.c[4].z) - (User.c[4].x);
          float _633 = max(9.999999974752427e-07f, _632);
          float _634 = _491 - (User.c[4].x);
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
          float _655 = _491 - (User.c[4].z);
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
      _673 = _559;
      _674 = _615;
      _675 = _671;
    } else {
      _673 = _489;
      _674 = _490;
      _675 = _491;
    }
    int _676 = _493 & 2;
    bool _677 = (_676 == 0);
    if (!_677) {
      float _679 = sqrt(_673);
      float _680 = sqrt(_674);
      float _681 = sqrt(_675);
      float _682 = dot(float3(_679, _680, _681), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _683 = 1.0f - _682;
      float _684 = saturate(_683);
      _686 = _684;
    } else {
      _686 = 1.0f;
    }
    int _687 = _493 & 8;
    bool _688 = (_687 == 0);
    if (!_688) {
      bool _690 = (_686 <= 0.0031308000907301903f);
      float _691 = _686 * 12.920000076293945f;
      float _692 = log2(_686);
      float _693 = _692 * 0.4166666567325592f;
      float _694 = exp2(_693);
      float _695 = _694 * 1.0549999475479126f;
      float _696 = _695 + -0.054999999701976776f;
      float _697 = select(_690, _691, _696);
      _934 = _697;
      _935 = _697;
      _936 = _697;
    } else {
      int _699 = _493 & 4;
      bool _700 = (_699 == 0);
      if (!_700) {
        int _702 = _493 & 16;
        bool _703 = (_702 == 0);
        if (!_703) {
          float _707 = (User.c[5].x) * 0.5f;
          float _708 = _707 + 0.5f;
          bool _709 = (_708 < 0.5f);
          float _710 = (User.c[5].x) * 5.0f;
          float _711 = select(_709, (User.c[5].x), _710);
          bool _712 = (_674 < _675);
          float _713 = select(_712, _675, _674);
          float _714 = select(_712, _674, _675);
          bool _715 = (_673 < _713);
          float _716 = select(_715, _713, _673);
          float _717 = select(_715, _673, _713);
          float _718 = min(_717, _714);
          float _719 = _716 - _718;
          float _720 = _716 + 1.000000013351432e-10f;
          float _721 = _719 / _720;
          float _723 = _721 - (User.c[5].y);
          float _724 = saturate(_723);
          float _725 = max(_724, 9.999999974752427e-07f);
          float _726 = log2(_725);
          float _727 = _726 * _711;
          float _728 = exp2(_727);
          float _729 = 2.0f - _728;
          float _731 = 1.0f - (User.c[5].z);
          float _732 = saturate(_731);
          float _733 = max(_732, _729);
          float _734 = dot(float3(_673, _674, _675), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _735 = _673 - _734;
          float _736 = _674 - _734;
          float _737 = _675 - _734;
          float _738 = _735 * _733;
          float _739 = _736 * _733;
          float _740 = _737 * _733;
          float _741 = _734 - _673;
          float _742 = _741 + _738;
          float _743 = _734 - _674;
          float _744 = _743 + _739;
          float _745 = _734 - _675;
          float _746 = _745 + _740;
          float _747 = _742 * _686;
          float _748 = _744 * _686;
          float _749 = _746 * _686;
          float _750 = _747 + _673;
          float _751 = _748 + _674;
          float _752 = _749 + _675;
          _866 = _750;
          _867 = _751;
          _868 = _752;
        } else {
          bool _754 = (_686 == 0.0f);
          if (!_754) {
            float _758 = abs(User.c[5].x);
            float _759 = saturate(_758);
            uint2 _760; s15.GetDimensions(_760.x, _760.y);
            float _763 = float((uint)_760.y);
            int _764 = _493 & 32;
            bool _765 = (_764 == 0);
            float _766 = _763 + -1.0f;
            if (!_765) {
              float _768 = 1.0f / _766;
              uint _769 = uint(SV_Position.x);
              uint _770 = uint(SV_Position.y);
              int _771 = _769 & 63;
              int _772 = _770 & 63;
              float4 _773 = sBlueNoiseR8G8.Load(int4(_771, _772, 0, 0));
              float _776 = _773.x + -0.5f;
              float _777 = _673 * 13.999999046325684f;
              float _778 = _674 * 13.999999046325684f;
              float _779 = _675 * 13.999999046325684f;
              float _780 = saturate(_777);
              float _781 = saturate(_778);
              float _782 = saturate(_779);
              float _783 = _673 + -0.9285714030265808f;
              float _784 = _674 + -0.9285714030265808f;
              float _785 = _675 + -0.9285714030265808f;
              float _786 = _783 * 13.999999046325684f;
              float _787 = _784 * 13.999999046325684f;
              float _788 = _785 * 13.999999046325684f;
              float _789 = saturate(_786);
              float _790 = saturate(_787);
              float _791 = saturate(_788);
              float _792 = 1.0f - _789;
              float _793 = 1.0f - _790;
              float _794 = 1.0f - _791;
              float _795 = min(_780, _792);
              float _796 = min(_781, _793);
              float _797 = min(_782, _794);
              float _798 = _773.y + -0.5f;
              float _799 = _795 * _798;
              float _800 = _796 * _798;
              float _801 = _797 * _798;
              float _802 = _799 + _776;
              float _803 = _800 + _776;
              float _804 = _801 + _776;
              float _805 = _802 * _768;
              float _806 = _803 * _768;
              float _807 = _804 * _768;
              float _808 = _805 + _673;
              float _809 = _806 + _674;
              float _810 = _807 + _675;
              float _811 = saturate(_808);
              float _812 = saturate(_809);
              float _813 = saturate(_810);
              float _814 = saturate(_811);
              float _815 = saturate(_812);
              float _816 = saturate(_813);
              _818 = _814;
              _819 = _815;
              _820 = _816;
            } else {
              _818 = _673;
              _819 = _674;
              _820 = _675;
            }
            float _821 = float((uint)_760.x);
            float _822 = _766 / _821;
            float _823 = _822 * _818;
            float _824 = 0.5f / _821;
            float _825 = _823 + _824;
            float _826 = _766 / _763;
            float _827 = _826 * _819;
            float _828 = 0.5f / _763;
            float _829 = _827 + _828;
            float _830 = _820 * _766;
            float _831 = floor(_830);
            float _832 = frac(_830);
            float _833 = _831 / _763;
            float _834 = _833 + _825;
            float _835 = _831 + 1.0f;
            float _836 = _835 / _763;
            float _837 = _836 + _825;
            float4 _838 = s15.Sample(s15Sampler, float2(_834, _829));
            float4 _842 = s15.Sample(s15Sampler, float2(_837, _829));
            float _846 = _842.x - _838.x;
            float _847 = _842.y - _838.y;
            float _848 = _842.z - _838.z;
            float _849 = _846 * _832;
            float _850 = _847 * _832;
            float _851 = _848 * _832;
            float _852 = _759 * _686;
            float _853 = _838.x - _673;
            float _854 = _853 + _849;
            float _855 = _838.y - _674;
            float _856 = _855 + _850;
            float _857 = _838.z - _675;
            float _858 = _857 + _851;
            float _859 = _854 * _852;
            float _860 = _856 * _852;
            float _861 = _858 * _852;
            float _862 = _859 + _673;
            float _863 = _860 + _674;
            float _864 = _861 + _675;
            _866 = _862;
            _867 = _863;
            _868 = _864;
          } else {
            _866 = _673;
            _867 = _674;
            _868 = _675;
          }
        }
      } else {
        _866 = _673;
        _867 = _674;
        _868 = _675;
      }
      bool _869 = (_866 <= 0.040449999272823334f);
      bool _870 = (_867 <= 0.040449999272823334f);
      bool _871 = (_868 <= 0.040449999272823334f);
      float _872 = _866 * 0.07739938050508499f;
      float _873 = _867 * 0.07739938050508499f;
      float _874 = _868 * 0.07739938050508499f;
      float _875 = _866 + 0.054999999701976776f;
      float _876 = _867 + 0.054999999701976776f;
      float _877 = _868 + 0.054999999701976776f;
      float _878 = _875 * 0.9478673338890076f;
      float _879 = _876 * 0.9478673338890076f;
      float _880 = _877 * 0.9478673338890076f;
      float _881 = log2(_878);
      float _882 = log2(_879);
      float _883 = log2(_880);
      float _884 = _881 * 2.4000000953674316f;
      float _885 = _882 * 2.4000000953674316f;
      float _886 = _883 * 2.4000000953674316f;
      float _887 = exp2(_884);
      float _888 = exp2(_885);
      float _889 = exp2(_886);
      float _890 = select(_869, _872, _887);
      float _891 = select(_870, _873, _888);
      float _892 = select(_871, _874, _889);
      bool _893 = (_890 == 1.0f);
      if (!_893) {
        float _895 = _890 * _890;
        float _896 = _895 * 3.0f;
        float _897 = _890 * 2.0f;
        float _898 = _897 + 1.0f;
        float _899 = _898 - _896;
        float _900 = sqrt(_899);
        float _901 = _890 + -1.0f;
        float _902 = _901 * 2.0f;
        float _903 = _900 / _902;
        float _904 = -0.5f - _903;
        _906 = _904;
      } else {
        _906 = 1e+06f;
      }
      bool _907 = (_891 == 1.0f);
      if (!_907) {
        float _909 = _891 * _891;
        float _910 = _909 * 3.0f;
        float _911 = _891 * 2.0f;
        float _912 = _911 + 1.0f;
        float _913 = _912 - _910;
        float _914 = sqrt(_913);
        float _915 = _891 + -1.0f;
        float _916 = _915 * 2.0f;
        float _917 = _914 / _916;
        float _918 = -0.5f - _917;
        _920 = _918;
      } else {
        _920 = 1e+06f;
      }
      bool _921 = (_892 == 1.0f);
      if (!_921) {
        float _923 = _892 * _892;
        float _924 = _923 * 3.0f;
        float _925 = _892 * 2.0f;
        float _926 = _925 + 1.0f;
        float _927 = _926 - _924;
        float _928 = sqrt(_927);
        float _929 = _892 + -1.0f;
        float _930 = _929 * 2.0f;
        float _931 = _928 / _930;
        float _932 = -0.5f - _931;
        _934 = _906;
        _935 = _920;
        _936 = _932;
      } else {
        _934 = _906;
        _935 = _920;
        _936 = 1e+06f;
      }
    }
  } else {
    _934 = _431;
    _935 = _432;
    _936 = _433;
  }
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_431, _432, _433),
      float3(_934, _935, _936),
      false);
  _934 = apt_tonemapped.x;
  _935 = apt_tonemapped.y;
  _936 = apt_tonemapped.z;
  bool _937 = (_934 <= 0.0031308000907301903f);
  bool _938 = (_935 <= 0.0031308000907301903f);
  bool _939 = (_936 <= 0.0031308000907301903f);
  float _940 = _934 * 12.920000076293945f;
  float _941 = _935 * 12.920000076293945f;
  float _942 = _936 * 12.920000076293945f;
  float _943 = log2(_934);
  float _944 = log2(_935);
  float _945 = log2(_936);
  float _946 = _943 * 0.4166666567325592f;
  float _947 = _944 * 0.4166666567325592f;
  float _948 = _945 * 0.4166666567325592f;
  float _949 = exp2(_946);
  float _950 = exp2(_947);
  float _951 = exp2(_948);
  float _952 = _949 * 1.0549999475479126f;
  float _953 = _950 * 1.0549999475479126f;
  float _954 = _951 * 1.0549999475479126f;
  float _955 = _952 + -0.054999999701976776f;
  float _956 = _953 + -0.054999999701976776f;
  float _957 = _954 + -0.054999999701976776f;
  float _958 = select(_937, _940, _955);
  float _959 = select(_938, _941, _956);
  float _960 = select(_939, _942, _957);
  float _961 = log2(_958);
  float _962 = log2(_959);
  float _963 = log2(_960);
  float _964 = floor(_961);
  float _965 = floor(_962);
  float _966 = floor(_963);
  float _967 = _964 + -6.0f;
  float _968 = _965 + -6.0f;
  float _969 = _966 + -5.0f;
  float _970 = exp2(_967);
  float _971 = exp2(_968);
  float _972 = exp2(_969);
  uint _973 = uint(SV_Position.x);
  uint _974 = uint(SV_Position.y);
  int _975 = _973 & 63;
  int _976 = _974 & 63;
  float4 _977 = sBlueNoiseR8.Load(int4(_975, _976, 0, 0));
  float _979 = _977.x + -0.5f;
  bool _980 = (_958 > 0.0f);
  bool _981 = (_959 > 0.0f);
  bool _982 = (_960 > 0.0f);
  float _983 = float((bool)_980);
  float _984 = float((bool)_981);
  float _985 = float((bool)_982);
  float _986 = _970 * _983;
  float _987 = _986 * _979;
  float _988 = _971 * _984;
  float _989 = _988 * _979;
  float _990 = _972 * _985;
  float _991 = _990 * _979;
  float _992 = _987 + _958;
  float _993 = _989 + _959;
  float _994 = _991 + _960;
  SV_Target.x = _992;
  SV_Target.y = _993;
  SV_Target.z = _994;
  SV_Target.w = _52.w;
  return SV_Target;
}
