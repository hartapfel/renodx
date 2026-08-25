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
};

cbuffer CBufferUserConstant_Z : register(b0) {
  StructUserConstant_Z User : packoffset(c000.x);
};

cbuffer CBufferPostProcessConstant_Z : register(b2) {
  StructPostProcessConstant_Z PostProcess : packoffset(c000.x);
};

SamplerState sBlueNoiseR8G8Sampler : register(s1);

SamplerState s0Sampler : register(s0);

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
  float4 _29 = s14.Sample(s14Sampler, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _33 = sPlagueFX_MaskLayer.Sample(s13Sampler, float2(TEXCOORD.z, TEXCOORD.w));
  float _35 = _33.y * 0.10000000149011612f;
  float _36 = _35 + _29.y;
  float _37 = _33.y * 0.5f;
  float _38 = _37 + _29.z;
  float _39 = exp2(_38);
  float _40 = _39 + -1.0f;
  float _43 = (PostProcess.Settings[11].y) * _40;
  float _44 = _43 + 1.0f;
  float _45 = log2(_44);
  float _46 = _29.x + TEXCOORD.z;
  float _47 = _36 + TEXCOORD.w;
  float _48 = _29.x + TEXCOORD.x;
  float _49 = _36 + TEXCOORD.y;
  float4 _50 = s0.SampleLevel(s0Sampler, float2(_46, _47), _45);
  float _55 = max(_50.x, 0.0f);
  float _56 = max(_50.y, 0.0f);
  float _57 = max(_50.z, 0.0f);
  float _60 = (Global.c[32].w) * 11.0f;
  float _61 = _60 + -1.2000000476837158f;
  float _62 = saturate(_61);
  float _63 = (Global.c[32].w) * 1.7000000476837158f;
  float _64 = 1.340000033378601f - _63;
  float _65 = saturate(_64);
  float _66 = _65 * _65;
  float _67 = _66 * _66;
  float _68 = _67 * _62;
  bool _69 = ((Global.c[32].w) < 9.999999747378752e-06f);
  float _72 = max((Global.c[33].y), _68);
  float _73 = _46 * 2.0f;
  float _74 = _47 * 1.7999999523162842f;
  float _75 = _73 + -1.0f;
  float _76 = _74 + -1.100000023841858f;
  float _77 = abs(_75);
  float _78 = abs(_76);
  float _79 = dot(float2(_77, _78), float2(_77, _78));
  float _80 = sqrt(_79);
  float _81 = select(_69, 1.0f, 0.0f);
  float _82 = _81 * _72;
  float4 _83 = s0.SampleLevel(s0Sampler, float2(_46, _47), 1.0f);
  float4 _87 = s0.SampleLevel(s0Sampler, float2(_46, _47), 2.0f);
  float4 _91 = s0.SampleLevel(s0Sampler, float2(_46, _47), 3.0f);
  float _95 = _79 * 1.7000000476837158f;
  float _96 = _95 + -0.6000000238418579f;
  float _97 = saturate(_96);
  float _98 = _79 * 1.475000023841858f;
  float _99 = _98 + -0.375f;
  float _100 = saturate(_99);
  float _101 = _79 * 1.2999999523162842f;
  float _102 = _101 + -0.15000000596046448f;
  float _103 = saturate(_102);
  float _104 = _91.x - _87.x;
  float _105 = _91.y - _87.y;
  float _106 = _91.z - _87.z;
  float _107 = _104 * _97;
  float _108 = _105 * _97;
  float _109 = _106 * _97;
  float _110 = _87.x - _83.x;
  float _111 = _110 + _107;
  float _112 = _87.y - _83.y;
  float _113 = _112 + _108;
  float _114 = _87.z - _83.z;
  float _115 = _114 + _109;
  float _116 = _111 * _100;
  float _117 = _113 * _100;
  float _118 = _115 * _100;
  float _119 = _103 * _82;
  float _120 = _83.x - _55;
  float _121 = _120 + _116;
  float _122 = _83.y - _56;
  float _123 = _122 + _117;
  float _124 = _83.z - _57;
  float _125 = _124 + _118;
  float _126 = _121 * _119;
  float _127 = _123 * _119;
  float _128 = _125 * _119;
  float _129 = _126 + _55;
  float _130 = _127 + _56;
  float _131 = _128 + _57;
  float4 _132 = s12_bloom.Sample(s12_bloomSampler, float2(_46, _47));
  float4 _136 = s8.Sample(s8Sampler, float2(_48, _49));
  float _143 = (PostProcess.Settings[4].w) * _136.x;
  float _144 = (PostProcess.Settings[4].w) * _136.y;
  float _145 = (PostProcess.Settings[4].w) * _136.z;
  float _146 = _143 + (PostProcess.Settings[4].z);
  float _147 = _144 + (PostProcess.Settings[4].z);
  float _148 = _145 + (PostProcess.Settings[4].z);
  float _149 = saturate(_146);
  float _150 = saturate(_147);
  float _151 = saturate(_148);
  float _152 = _132.x - _129;
  float _153 = _132.y - _130;
  float _154 = _132.z - _131;
  float _155 = _149 * _152;
  float _156 = _150 * _153;
  float _157 = _151 * _154;
  float _158 = _155 + _129;
  float _159 = _156 + _130;
  float _160 = _157 + _131;
  float4 _161 = s6.Load(int3(0, 0, 0));
  float _163 = _161.x * _158;
  float _164 = _161.x * _159;
  float _165 = _161.x * _160;
  float _170 = _47 * 2.0f;
  float _171 = _170 + -1.0f;
  float _174 = (PostProcess.Settings[13].w) * _171;
  float _175 = _75 * _75;
  float _176 = _174 * _174;
  float _177 = _176 + _175;
  float _178 = sqrt(_177);
  float _180 = (PostProcess.Settings[13].x) * _178;
  float _182 = _180 + (PostProcess.Settings[13].y);
  float _183 = saturate(_182);
  float _185 = log2(_183);
  float _186 = _185 * (PostProcess.Settings[13].z);
  float _187 = exp2(_186);
  float _188 = _163 * (PostProcess.Settings[12].x);
  float _189 = _164 * (PostProcess.Settings[12].y);
  float _190 = _165 * (PostProcess.Settings[12].z);
  float _191 = _188 - _163;
  float _192 = _189 - _164;
  float _193 = _190 - _165;
  float _194 = _187 * _191;
  float _195 = _187 * _192;
  float _196 = _187 * _193;
  float _197 = _194 + _163;
  float _198 = _195 + _164;
  float _199 = _196 + _165;
  float _202 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _203 = _197 * 11190.6005859375f;
  float _204 = _203 * _202;
  float _205 = _198 * 11190.6005859375f;
  float _206 = _205 * _202;
  float _207 = _199 * 11190.6005859375f;
  float _208 = _207 * _202;
  float _209 = _204 + 1.0f;
  float _210 = _206 + 1.0f;
  float _211 = _208 + 1.0f;
  float _212 = log2(_209);
  float _213 = log2(_210);
  float _214 = log2(_211);
  float _215 = _212 * 0.07434873282909393f;
  float _216 = _213 * 0.07434873282909393f;
  float _217 = _214 * 0.07434873282909393f;
  float _220 = _215 * (PostProcess.OffsetWeight[0].x);
  float _221 = _216 * (PostProcess.OffsetWeight[0].x);
  float _222 = _217 * (PostProcess.OffsetWeight[0].x);
  float _224 = _220 + (PostProcess.OffsetWeight[0].y);
  float _225 = _221 + (PostProcess.OffsetWeight[0].y);
  float _226 = _222 + (PostProcess.OffsetWeight[0].y);
  float4 _227 = s3_3D.Sample(s3_3DSampler, float3(_224, _225, _226));
  float _233 = _227.x * 13.450128555297852f;
  float _234 = _227.y * 13.450128555297852f;
  float _235 = _227.z * 13.450128555297852f;
  float _236 = exp2(_233);
  float _237 = exp2(_234);
  float _238 = exp2(_235);
  float _239 = _236 + -1.0f;
  float _240 = _237 + -1.0f;
  float _241 = _238 + -1.0f;
  float _242 = _239 * 8.936070662457496e-05f;
  float _243 = _240 * 8.936070662457496e-05f;
  float _244 = _241 * 8.936070662457496e-05f;
  float _245 = 10000.0f / (PostProcess.Settings[10].w);
  float _246 = _242 * _245;
  float _247 = _243 * _245;
  float _248 = _244 * _245;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUTScaling(
      float3(_204, _206, _208) / apt_lut_input_encode_scale,
      float3(_246, _247, _248),
      s3_3D,
      s3_3DSampler,
      apt_lut_input_encode_scale,
      PostProcess.OffsetWeight[0].x,
      PostProcess.OffsetWeight[0].y,
      8.936070662457496e-05f * (10000.0f / PostProcess.Settings[10].w));
  _246 = apt_lut_output.x;
  _247 = apt_lut_output.y;
  _248 = apt_lut_output.z;
  float _252 = (User.c[2].y) / (User.c[2].x);
  int _255 = asint((Global.c[1].w));
  uint _256 = _255 + 30u;
  int _257 = _256 & 63;
  float _258 = _46 * 8.0f;
  float _259 = _258 * _252;
  float _260 = _47 * 8.0f;
  float _261 = float((int)(_255));
  float4 _262 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_259, _260, _261), 0.0f);
  float _264 = _46 + 0.5f;
  float _265 = (User.c[2].x) * 0.5f;
  float _266 = _264 + _265;
  float _267 = _252 * 8.0f;
  float _268 = _267 * _266;
  float _269 = _47 + 0.5f;
  float _270 = (User.c[2].y) * 0.5f;
  float _271 = _269 + _270;
  float _272 = _271 * 8.0f;
  float _273 = float((int)(_257));
  float4 _274 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_268, _272, _273), 0.0f);
  float _276 = _274.x + _262.x;
  float _277 = _276 * 0.714285671710968f;
  float _278 = _277 + -0.2142857164144516f;
  float _279 = saturate(_278);
  float _280 = _279 * 2.0f;
  float _281 = 3.0f - _280;
  float _282 = _279 * _279;
  float _283 = _282 * _281;
  float _284 = _283 * 0.5f;
  float _285 = _283 * 0.4000000059604645f;
  float _286 = _283 * 0.05000000074505806f;
  float _287 = _284 + -0.5f;
  float _288 = _285 + -0.6000000238418579f;
  float _289 = _286 + -0.949999988079071f;
  float _290 = _287 * _82;
  float _291 = _288 * _82;
  float _292 = _289 * _82;
  float _293 = _290 + 1.0f;
  float _294 = _291 + 1.0f;
  float _295 = _292 + 1.0f;
  float _296 = _246 * _293;
  float _297 = _247 * _294;
  float _298 = _248 * _295;
  float4 _299 = s13.Sample(s13Sampler, float2(_46, _47));
  float _306 = _97 + 1.0f;
  float _307 = saturate(_306);
  float _308 = (User.c[2].x) * _307;
  float _309 = (User.c[2].y) * _307;
  float _310 = _308 + _46;
  float _311 = _309 + _47;
  float4 _312 = s13.Sample(s13Sampler, float2(_310, _311));
  float _316 = _312.x + _299.x;
  float _317 = _312.y + _299.y;
  float _318 = _312.z + _299.z;
  float _319 = _316 * 0.5f;
  float _320 = _317 * 0.5f;
  float _321 = _318 * 0.5f;
  float _322 = _82 * 0.6000000238418579f;
  float _323 = _322 * _80;
  float _324 = _82 * 0.7300000190734863f;
  float _325 = _324 * _80;
  float _326 = _82 * 0.8799999952316284f;
  float _327 = _326 * _80;
  float _328 = 1.0f - _323;
  float _329 = 1.0f - _325;
  float _330 = 1.0f - _327;
  float _331 = saturate(_328);
  float _332 = saturate(_329);
  float _333 = saturate(_330);
  float _334 = _296 * _331;
  float _335 = _297 * _332;
  float _336 = _298 * _333;
  float _337 = _319 + _334;
  float _338 = _335 + _320;
  float _339 = _336 + _321;
  bool _342 = ((User.c[3].x) > 0.0f);
  float _464;
  float _520;
  float _576;
  float _579;
  float _580;
  float _581;
  float _592;
  float _724;
  float _725;
  float _726;
  float _772;
  float _773;
  float _774;
  float _812;
  float _826;
  float _840;
  float _841;
  float _842;
  if (_342) {
    float _344 = log2(_337);
    float _345 = _344 * 3.0f;
    float _346 = exp2(_345);
    float _347 = _346 + -1.0f;
    float _348 = _337 + -1.0f;
    float _349 = _347 / _348;
    float _350 = _349 + -1.0f;
    bool _351 = !(_337 == 1.0f);
    float _352 = _350 / _349;
    float _353 = select(_351, _352, 0.6666666865348816f);
    float _354 = log2(_338);
    float _355 = _354 * 3.0f;
    float _356 = exp2(_355);
    float _357 = _356 + -1.0f;
    float _358 = _338 + -1.0f;
    float _359 = _357 / _358;
    float _360 = _359 + -1.0f;
    bool _361 = !(_338 == 1.0f);
    float _362 = _360 / _359;
    float _363 = select(_361, _362, 0.6666666865348816f);
    float _364 = log2(_339);
    float _365 = _364 * 3.0f;
    float _366 = exp2(_365);
    float _367 = _366 + -1.0f;
    float _368 = _339 + -1.0f;
    float _369 = _367 / _368;
    float _370 = _369 + -1.0f;
    bool _371 = !(_339 == 1.0f);
    float _372 = _370 / _369;
    float _373 = select(_371, _372, 0.6666666865348816f);
    bool _374 = (_353 <= 0.0031308000907301903f);
    bool _375 = (_363 <= 0.0031308000907301903f);
    bool _376 = (_373 <= 0.0031308000907301903f);
    float _377 = _353 * 12.920000076293945f;
    float _378 = _363 * 12.920000076293945f;
    float _379 = _373 * 12.920000076293945f;
    float _380 = log2(_353);
    float _381 = log2(_363);
    float _382 = log2(_373);
    float _383 = _380 * 0.4166666567325592f;
    float _384 = _381 * 0.4166666567325592f;
    float _385 = _382 * 0.4166666567325592f;
    float _386 = exp2(_383);
    float _387 = exp2(_384);
    float _388 = exp2(_385);
    float _389 = _386 * 1.0549999475479126f;
    float _390 = _387 * 1.0549999475479126f;
    float _391 = _388 * 1.0549999475479126f;
    float _392 = _389 + -0.054999999701976776f;
    float _393 = _390 + -0.054999999701976776f;
    float _394 = _391 + -0.054999999701976776f;
    float _395 = select(_374, _377, _392);
    float _396 = select(_375, _378, _393);
    float _397 = select(_376, _379, _394);
    int _399 = asint((User.c[3].y));
    int _400 = _399 & 1;
    bool _401 = (_400 == 0);
    if (!_401) {
      bool _410 = !(_395 <= (User.c[4].x));
      if (!_410) {
        float _412 = max(9.999999974752427e-07f, (User.c[4].x));
        float _413 = _395 / _412;
        float _414 = _413 * (User.c[4].y);
        float _415 = _413 * _413;
        float _416 = _415 * _413;
        float _417 = _416 - _413;
        float _418 = (User.c[3].z) * 0.1666666716337204f;
        float _419 = _412 * _412;
        float _420 = _419 * _418;
        float _421 = _420 * _417;
        float _422 = _421 + _414;
        _464 = _422;
      } else {
        bool _424 = !(_395 <= (User.c[4].z));
        if (!_424) {
          float _426 = (User.c[4].z) - (User.c[4].x);
          float _427 = max(9.999999974752427e-07f, _426);
          float _428 = _395 - (User.c[4].x);
          float _429 = _428 / _427;
          float _430 = 1.0f - _429;
          float _431 = _430 * (User.c[4].y);
          float _432 = _429 * (User.c[4].w);
          float _433 = _431 + _432;
          float _434 = _430 * _430;
          float _435 = _434 * _430;
          float _436 = _435 - _430;
          float _437 = _436 * (User.c[3].z);
          float _438 = _429 * _429;
          float _439 = _438 * _429;
          float _440 = _439 - _429;
          float _441 = _440 * (User.c[3].w);
          float _442 = _437 + _441;
          float _443 = _427 * _427;
          float _444 = _443 * 0.1666666716337204f;
          float _445 = _444 * _442;
          float _446 = _433 + _445;
          _464 = _446;
        } else {
          float _448 = 1.0f - (User.c[4].z);
          float _449 = _395 - (User.c[4].z);
          float _450 = max(9.999999974752427e-07f, _448);
          float _451 = _449 / _450;
          float _452 = 1.0f - _451;
          float _453 = _452 * (User.c[4].w);
          float _454 = _453 + _451;
          float _455 = _452 * _452;
          float _456 = _455 * _452;
          float _457 = _456 - _452;
          float _458 = _448 * _448;
          float _459 = _458 * 0.1666666716337204f;
          float _460 = _459 * (User.c[3].w);
          float _461 = _460 * _457;
          float _462 = _454 + _461;
          _464 = _462;
        }
      }
      float _465 = saturate(_464);
      bool _466 = !(_396 <= (User.c[4].x));
      if (!_466) {
        float _468 = max(9.999999974752427e-07f, (User.c[4].x));
        float _469 = _396 / _468;
        float _470 = _469 * (User.c[4].y);
        float _471 = _469 * _469;
        float _472 = _471 * _469;
        float _473 = _472 - _469;
        float _474 = (User.c[3].z) * 0.1666666716337204f;
        float _475 = _468 * _468;
        float _476 = _475 * _474;
        float _477 = _476 * _473;
        float _478 = _477 + _470;
        _520 = _478;
      } else {
        bool _480 = !(_396 <= (User.c[4].z));
        if (!_480) {
          float _482 = (User.c[4].z) - (User.c[4].x);
          float _483 = max(9.999999974752427e-07f, _482);
          float _484 = _396 - (User.c[4].x);
          float _485 = _484 / _483;
          float _486 = 1.0f - _485;
          float _487 = _486 * (User.c[4].y);
          float _488 = _485 * (User.c[4].w);
          float _489 = _487 + _488;
          float _490 = _486 * _486;
          float _491 = _490 * _486;
          float _492 = _491 - _486;
          float _493 = _492 * (User.c[3].z);
          float _494 = _485 * _485;
          float _495 = _494 * _485;
          float _496 = _495 - _485;
          float _497 = _496 * (User.c[3].w);
          float _498 = _493 + _497;
          float _499 = _483 * _483;
          float _500 = _499 * 0.1666666716337204f;
          float _501 = _500 * _498;
          float _502 = _489 + _501;
          _520 = _502;
        } else {
          float _504 = 1.0f - (User.c[4].z);
          float _505 = _396 - (User.c[4].z);
          float _506 = max(9.999999974752427e-07f, _504);
          float _507 = _505 / _506;
          float _508 = 1.0f - _507;
          float _509 = _508 * (User.c[4].w);
          float _510 = _509 + _507;
          float _511 = _508 * _508;
          float _512 = _511 * _508;
          float _513 = _512 - _508;
          float _514 = _504 * _504;
          float _515 = _514 * 0.1666666716337204f;
          float _516 = _515 * (User.c[3].w);
          float _517 = _516 * _513;
          float _518 = _510 + _517;
          _520 = _518;
        }
      }
      float _521 = saturate(_520);
      bool _522 = !(_397 <= (User.c[4].x));
      if (!_522) {
        float _524 = max(9.999999974752427e-07f, (User.c[4].x));
        float _525 = _397 / _524;
        float _526 = _525 * (User.c[4].y);
        float _527 = _525 * _525;
        float _528 = _527 * _525;
        float _529 = _528 - _525;
        float _530 = (User.c[3].z) * 0.1666666716337204f;
        float _531 = _524 * _524;
        float _532 = _531 * _530;
        float _533 = _532 * _529;
        float _534 = _533 + _526;
        _576 = _534;
      } else {
        bool _536 = !(_397 <= (User.c[4].z));
        if (!_536) {
          float _538 = (User.c[4].z) - (User.c[4].x);
          float _539 = max(9.999999974752427e-07f, _538);
          float _540 = _397 - (User.c[4].x);
          float _541 = _540 / _539;
          float _542 = 1.0f - _541;
          float _543 = _542 * (User.c[4].y);
          float _544 = _541 * (User.c[4].w);
          float _545 = _543 + _544;
          float _546 = _542 * _542;
          float _547 = _546 * _542;
          float _548 = _547 - _542;
          float _549 = _548 * (User.c[3].z);
          float _550 = _541 * _541;
          float _551 = _550 * _541;
          float _552 = _551 - _541;
          float _553 = _552 * (User.c[3].w);
          float _554 = _549 + _553;
          float _555 = _539 * _539;
          float _556 = _555 * 0.1666666716337204f;
          float _557 = _556 * _554;
          float _558 = _545 + _557;
          _576 = _558;
        } else {
          float _560 = 1.0f - (User.c[4].z);
          float _561 = _397 - (User.c[4].z);
          float _562 = max(9.999999974752427e-07f, _560);
          float _563 = _561 / _562;
          float _564 = 1.0f - _563;
          float _565 = _564 * (User.c[4].w);
          float _566 = _565 + _563;
          float _567 = _564 * _564;
          float _568 = _567 * _564;
          float _569 = _568 - _564;
          float _570 = _560 * _560;
          float _571 = _570 * 0.1666666716337204f;
          float _572 = _571 * (User.c[3].w);
          float _573 = _572 * _569;
          float _574 = _566 + _573;
          _576 = _574;
        }
      }
      float _577 = saturate(_576);
      _579 = _465;
      _580 = _521;
      _581 = _577;
    } else {
      _579 = _395;
      _580 = _396;
      _581 = _397;
    }
    int _582 = _399 & 2;
    bool _583 = (_582 == 0);
    if (!_583) {
      float _585 = sqrt(_579);
      float _586 = sqrt(_580);
      float _587 = sqrt(_581);
      float _588 = dot(float3(_585, _586, _587), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _589 = 1.0f - _588;
      float _590 = saturate(_589);
      _592 = _590;
    } else {
      _592 = 1.0f;
    }
    int _593 = _399 & 8;
    bool _594 = (_593 == 0);
    if (!_594) {
      bool _596 = (_592 <= 0.0031308000907301903f);
      float _597 = _592 * 12.920000076293945f;
      float _598 = log2(_592);
      float _599 = _598 * 0.4166666567325592f;
      float _600 = exp2(_599);
      float _601 = _600 * 1.0549999475479126f;
      float _602 = _601 + -0.054999999701976776f;
      float _603 = select(_596, _597, _602);
      _840 = _603;
      _841 = _603;
      _842 = _603;
    } else {
      int _605 = _399 & 4;
      bool _606 = (_605 == 0);
      if (!_606) {
        int _608 = _399 & 16;
        bool _609 = (_608 == 0);
        if (!_609) {
          float _613 = (User.c[5].x) * 0.5f;
          float _614 = _613 + 0.5f;
          bool _615 = (_614 < 0.5f);
          float _616 = (User.c[5].x) * 5.0f;
          float _617 = select(_615, (User.c[5].x), _616);
          bool _618 = (_580 < _581);
          float _619 = select(_618, _581, _580);
          float _620 = select(_618, _580, _581);
          bool _621 = (_579 < _619);
          float _622 = select(_621, _619, _579);
          float _623 = select(_621, _579, _619);
          float _624 = min(_623, _620);
          float _625 = _622 - _624;
          float _626 = _622 + 1.000000013351432e-10f;
          float _627 = _625 / _626;
          float _629 = _627 - (User.c[5].y);
          float _630 = saturate(_629);
          float _631 = max(_630, 9.999999974752427e-07f);
          float _632 = log2(_631);
          float _633 = _632 * _617;
          float _634 = exp2(_633);
          float _635 = 2.0f - _634;
          float _637 = 1.0f - (User.c[5].z);
          float _638 = saturate(_637);
          float _639 = max(_638, _635);
          float _640 = dot(float3(_579, _580, _581), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _641 = _579 - _640;
          float _642 = _580 - _640;
          float _643 = _581 - _640;
          float _644 = _641 * _639;
          float _645 = _642 * _639;
          float _646 = _643 * _639;
          float _647 = _640 - _579;
          float _648 = _647 + _644;
          float _649 = _640 - _580;
          float _650 = _649 + _645;
          float _651 = _640 - _581;
          float _652 = _651 + _646;
          float _653 = _648 * _592;
          float _654 = _650 * _592;
          float _655 = _652 * _592;
          float _656 = _653 + _579;
          float _657 = _654 + _580;
          float _658 = _655 + _581;
          _772 = _656;
          _773 = _657;
          _774 = _658;
        } else {
          bool _660 = (_592 == 0.0f);
          if (!_660) {
            float _664 = abs(User.c[5].x);
            float _665 = saturate(_664);
            uint4 _666 = 0u; s15.GetDimensions(0u, _666.x, _666.y, _666.w);
            float _669 = float((uint)_666.y);
            int _670 = _399 & 32;
            bool _671 = (_670 == 0);
            float _672 = _669 + -1.0f;
            if (!_671) {
              float _674 = 1.0f / _672;
              uint _675 = uint(SV_Position.x);
              uint _676 = uint(SV_Position.y);
              int _677 = _675 & 63;
              int _678 = _676 & 63;
              float4 _679 = sBlueNoiseR8G8.Load(int4(_677, _678, 0, 0));
              float _682 = _679.x + -0.5f;
              float _683 = _579 * 13.999999046325684f;
              float _684 = _580 * 13.999999046325684f;
              float _685 = _581 * 13.999999046325684f;
              float _686 = saturate(_683);
              float _687 = saturate(_684);
              float _688 = saturate(_685);
              float _689 = _579 + -0.9285714030265808f;
              float _690 = _580 + -0.9285714030265808f;
              float _691 = _581 + -0.9285714030265808f;
              float _692 = _689 * 13.999999046325684f;
              float _693 = _690 * 13.999999046325684f;
              float _694 = _691 * 13.999999046325684f;
              float _695 = saturate(_692);
              float _696 = saturate(_693);
              float _697 = saturate(_694);
              float _698 = 1.0f - _695;
              float _699 = 1.0f - _696;
              float _700 = 1.0f - _697;
              float _701 = min(_686, _698);
              float _702 = min(_687, _699);
              float _703 = min(_688, _700);
              float _704 = _679.y + -0.5f;
              float _705 = _701 * _704;
              float _706 = _702 * _704;
              float _707 = _703 * _704;
              float _708 = _705 + _682;
              float _709 = _706 + _682;
              float _710 = _707 + _682;
              float _711 = _708 * _674;
              float _712 = _709 * _674;
              float _713 = _710 * _674;
              float _714 = _711 + _579;
              float _715 = _712 + _580;
              float _716 = _713 + _581;
              float _717 = saturate(_714);
              float _718 = saturate(_715);
              float _719 = saturate(_716);
              float _720 = saturate(_717);
              float _721 = saturate(_718);
              float _722 = saturate(_719);
              _724 = _720;
              _725 = _721;
              _726 = _722;
            } else {
              _724 = _579;
              _725 = _580;
              _726 = _581;
            }
            float _727 = float((uint)_666.x);
            float _728 = _672 / _727;
            float _729 = _728 * _724;
            float _730 = 0.5f / _727;
            float _731 = _729 + _730;
            float _732 = _672 / _669;
            float _733 = _732 * _725;
            float _734 = 0.5f / _669;
            float _735 = _733 + _734;
            float _736 = _726 * _672;
            float _737 = floor(_736);
            float _738 = frac(_736);
            float _739 = _737 / _669;
            float _740 = _739 + _731;
            float _741 = _737 + 1.0f;
            float _742 = _741 / _669;
            float _743 = _742 + _731;
            float4 _744 = s15.Sample(s15Sampler, float2(_740, _735));
            float4 _748 = s15.Sample(s15Sampler, float2(_743, _735));
            float _752 = _748.x - _744.x;
            float _753 = _748.y - _744.y;
            float _754 = _748.z - _744.z;
            float _755 = _752 * _738;
            float _756 = _753 * _738;
            float _757 = _754 * _738;
            float _758 = _665 * _592;
            float _759 = _744.x - _579;
            float _760 = _759 + _755;
            float _761 = _744.y - _580;
            float _762 = _761 + _756;
            float _763 = _744.z - _581;
            float _764 = _763 + _757;
            float _765 = _760 * _758;
            float _766 = _762 * _758;
            float _767 = _764 * _758;
            float _768 = _765 + _579;
            float _769 = _766 + _580;
            float _770 = _767 + _581;
            _772 = _768;
            _773 = _769;
            _774 = _770;
          } else {
            _772 = _579;
            _773 = _580;
            _774 = _581;
          }
        }
      } else {
        _772 = _579;
        _773 = _580;
        _774 = _581;
      }
      bool _775 = (_772 <= 0.040449999272823334f);
      bool _776 = (_773 <= 0.040449999272823334f);
      bool _777 = (_774 <= 0.040449999272823334f);
      float _778 = _772 * 0.07739938050508499f;
      float _779 = _773 * 0.07739938050508499f;
      float _780 = _774 * 0.07739938050508499f;
      float _781 = _772 + 0.054999999701976776f;
      float _782 = _773 + 0.054999999701976776f;
      float _783 = _774 + 0.054999999701976776f;
      float _784 = _781 * 0.9478673338890076f;
      float _785 = _782 * 0.9478673338890076f;
      float _786 = _783 * 0.9478673338890076f;
      float _787 = log2(_784);
      float _788 = log2(_785);
      float _789 = log2(_786);
      float _790 = _787 * 2.4000000953674316f;
      float _791 = _788 * 2.4000000953674316f;
      float _792 = _789 * 2.4000000953674316f;
      float _793 = exp2(_790);
      float _794 = exp2(_791);
      float _795 = exp2(_792);
      float _796 = select(_775, _778, _793);
      float _797 = select(_776, _779, _794);
      float _798 = select(_777, _780, _795);
      bool _799 = (_796 == 1.0f);
      if (!_799) {
        float _801 = _796 * _796;
        float _802 = _801 * 3.0f;
        float _803 = _796 * 2.0f;
        float _804 = _803 + 1.0f;
        float _805 = _804 - _802;
        float _806 = sqrt(_805);
        float _807 = _796 + -1.0f;
        float _808 = _807 * 2.0f;
        float _809 = _806 / _808;
        float _810 = -0.5f - _809;
        _812 = _810;
      } else {
        _812 = 1e+06f;
      }
      bool _813 = (_797 == 1.0f);
      if (!_813) {
        float _815 = _797 * _797;
        float _816 = _815 * 3.0f;
        float _817 = _797 * 2.0f;
        float _818 = _817 + 1.0f;
        float _819 = _818 - _816;
        float _820 = sqrt(_819);
        float _821 = _797 + -1.0f;
        float _822 = _821 * 2.0f;
        float _823 = _820 / _822;
        float _824 = -0.5f - _823;
        _826 = _824;
      } else {
        _826 = 1e+06f;
      }
      bool _827 = (_798 == 1.0f);
      if (!_827) {
        float _829 = _798 * _798;
        float _830 = _829 * 3.0f;
        float _831 = _798 * 2.0f;
        float _832 = _831 + 1.0f;
        float _833 = _832 - _830;
        float _834 = sqrt(_833);
        float _835 = _798 + -1.0f;
        float _836 = _835 * 2.0f;
        float _837 = _834 / _836;
        float _838 = -0.5f - _837;
        _840 = _812;
        _841 = _826;
        _842 = _838;
      } else {
        _840 = _812;
        _841 = _826;
        _842 = 1e+06f;
      }
    }
  } else {
    _840 = _337;
    _841 = _338;
    _842 = _339;
  }
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_337, _338, _339),
      float3(_840, _841, _842),
      false);
  _840 = apt_tonemapped.x;
  _841 = apt_tonemapped.y;
  _842 = apt_tonemapped.z;
  bool _843 = (_840 <= 0.0031308000907301903f);
  bool _844 = (_841 <= 0.0031308000907301903f);
  bool _845 = (_842 <= 0.0031308000907301903f);
  float _846 = _840 * 12.920000076293945f;
  float _847 = _841 * 12.920000076293945f;
  float _848 = _842 * 12.920000076293945f;
  float _849 = log2(_840);
  float _850 = log2(_841);
  float _851 = log2(_842);
  float _852 = _849 * 0.4166666567325592f;
  float _853 = _850 * 0.4166666567325592f;
  float _854 = _851 * 0.4166666567325592f;
  float _855 = exp2(_852);
  float _856 = exp2(_853);
  float _857 = exp2(_854);
  float _858 = _855 * 1.0549999475479126f;
  float _859 = _856 * 1.0549999475479126f;
  float _860 = _857 * 1.0549999475479126f;
  float _861 = _858 + -0.054999999701976776f;
  float _862 = _859 + -0.054999999701976776f;
  float _863 = _860 + -0.054999999701976776f;
  float _864 = select(_843, _846, _861);
  float _865 = select(_844, _847, _862);
  float _866 = select(_845, _848, _863);
  float _867 = log2(_864);
  float _868 = log2(_865);
  float _869 = log2(_866);
  float _870 = floor(_867);
  float _871 = floor(_868);
  float _872 = floor(_869);
  float _873 = _870 + -6.0f;
  float _874 = _871 + -6.0f;
  float _875 = _872 + -5.0f;
  float _876 = exp2(_873);
  float _877 = exp2(_874);
  float _878 = exp2(_875);
  uint _879 = uint(SV_Position.x);
  uint _880 = uint(SV_Position.y);
  int _881 = _879 & 63;
  int _882 = _880 & 63;
  float4 _883 = sBlueNoiseR8.Load(int4(_881, _882, 0, 0));
  float _885 = _883.x + -0.5f;
  bool _886 = (_864 > 0.0f);
  bool _887 = (_865 > 0.0f);
  bool _888 = (_866 > 0.0f);
  float _889 = float((bool)_886);
  float _890 = float((bool)_887);
  float _891 = float((bool)_888);
  float _892 = _876 * _889;
  float _893 = _892 * _885;
  float _894 = _877 * _890;
  float _895 = _894 * _885;
  float _896 = _878 * _891;
  float _897 = _896 * _885;
  float _898 = _893 + _864;
  float _899 = _895 + _865;
  float _900 = _897 + _866;
  SV_Target.x = _898;
  SV_Target.y = _899;
  SV_Target.z = _900;
  SV_Target.w = _50.w;
  return SV_Target;
}
