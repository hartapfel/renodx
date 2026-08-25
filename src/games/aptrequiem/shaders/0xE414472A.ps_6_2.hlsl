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
  float _167 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _168 = _160 * 11190.6005859375f;
  float _169 = _168 * _163.x;
  float _170 = _169 * _167;
  float _171 = _161 * 11190.6005859375f;
  float _172 = _171 * _163.x;
  float _173 = _172 * _167;
  float _174 = _162 * 11190.6005859375f;
  float _175 = _174 * _163.x;
  float _176 = _175 * _167;
  float _177 = _170 + 1.0f;
  float _178 = _173 + 1.0f;
  float _179 = _176 + 1.0f;
  float _180 = log2(_177);
  float _181 = log2(_178);
  float _182 = log2(_179);
  float _183 = _180 * 0.07434873282909393f;
  float _184 = _181 * 0.07434873282909393f;
  float _185 = _182 * 0.07434873282909393f;
  float _188 = _183 * (PostProcess.OffsetWeight[0].x);
  float _189 = _184 * (PostProcess.OffsetWeight[0].x);
  float _190 = _185 * (PostProcess.OffsetWeight[0].x);
  float _192 = _188 + (PostProcess.OffsetWeight[0].y);
  float _193 = _189 + (PostProcess.OffsetWeight[0].y);
  float _194 = _190 + (PostProcess.OffsetWeight[0].y);
  float4 _195 = s3_3D.Sample(s3_3DSampler, float3(_192, _193, _194));
  float _201 = _195.x * 13.450128555297852f;
  float _202 = _195.y * 13.450128555297852f;
  float _203 = _195.z * 13.450128555297852f;
  float _204 = exp2(_201);
  float _205 = exp2(_202);
  float _206 = exp2(_203);
  float _207 = _204 + -1.0f;
  float _208 = _205 + -1.0f;
  float _209 = _206 + -1.0f;
  float _210 = _207 * 8.936070662457496e-05f;
  float _211 = _208 * 8.936070662457496e-05f;
  float _212 = _209 * 8.936070662457496e-05f;
  float _213 = 10000.0f / (PostProcess.Settings[10].w);
  float _214 = _210 * _213;
  float _215 = _211 * _213;
  float _216 = _212 * _213;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUT(
      float3(_170, _173, _176) / apt_lut_input_encode_scale,
      float3(_214, _215, _216));
  apt_lut_output = APTApplyPerceptualFilmGrain(apt_lut_output, SV_Position.xy);
  _214 = apt_lut_output.x;
  _215 = apt_lut_output.y;
  _216 = apt_lut_output.z;
  float _217 = dot(float3(_214, _215, _216), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _221 = (PostProcess.Settings[9].x) * TEXCOORD.x;
  float _222 = (PostProcess.Settings[9].y) * TEXCOORD.y;
  float _225 = _221 + (PostProcess.Settings[9].z);
  float _226 = _222 + (PostProcess.Settings[9].w);
  float4 _227 = s9.Sample(s9Sampler, float2(_225, _226));
  bool _233 = ((PostProcess.Settings[10].y) > 0.0f);
  uint _234 = uint(SV_Position.x);
  uint _235 = uint(SV_Position.y);
  int _236 = _234 & 63;
  int _237 = _235 & 63;
  float _273;
  float _274;
  float _275;
  float _524;
  float _580;
  float _636;
  float _639;
  float _640;
  float _641;
  float _652;
  float _784;
  float _785;
  float _786;
  float _832;
  float _833;
  float _834;
  float _872;
  float _886;
  float _900;
  float _901;
  float _902;
  if (_233) {
    bool _240 = ((PostProcess.Settings[10].x) > 0.0f);
    int _243 = asint((Global.c[1].w));
    int _244 = select(_240, _243, 0);
    float4 _245 = sBlueNoiseR8G8.Load(int4(_236, _237, _244, 0));
    float _248 = _245.x * -2.0f;
    float _249 = _245.x * 2.0f;
    float _250 = _248 * _245.y;
    float _251 = _249 * _245.y;
    float _252 = _250 + _245.x;
    float _253 = _251 - _245.x;
    _273 = _252;
    _274 = _253;
    _275 = _253;
  } else {
    float4 _255 = sBlueNoiseR8.Load(int4(_236, _237, 0, 0));
    float _257 = _255.x - _227.x;
    float _258 = _255.x - _227.y;
    float _259 = _255.x - _227.z;
    float _260 = _257 * 0.5f;
    float _261 = _258 * 0.5f;
    float _262 = _259 * 0.5f;
    float _263 = _260 + _227.x;
    float _264 = _261 + _227.y;
    float _265 = _262 + _227.z;
    float _266 = _263 * 2.0f;
    float _267 = _264 * 2.0f;
    float _268 = _265 * 2.0f;
    float _269 = _266 + -1.0f;
    float _270 = _267 + -1.0f;
    float _271 = _268 + -1.0f;
    _273 = _269;
    _274 = _270;
    _275 = _271;
  }
  float _276 = _217 + 1.0f;
  float _277 = _217 / _276;
  float _278 = _277 + -9.999999747378752e-05f;
  float _279 = _278 * 1111.111083984375f;
  float _280 = saturate(_279);
  float _281 = _280 * 2.0f;
  float _282 = 3.0f - _281;
  float _283 = _280 * _280;
  float _284 = _283 * _282;
  float _288 = (PostProcess.Settings[2].y) - (PostProcess.Settings[2].x);
  float _289 = _288 * _277;
  float _290 = _289 + (PostProcess.Settings[2].x);
  float _291 = _284 * _273;
  float _292 = _291 * _290;
  float _293 = _284 * _274;
  float _294 = _293 * _290;
  float _295 = _284 * _275;
  float _296 = _295 * _290;
  float _297 = _292 + _214;
  float _298 = _294 + _215;
  float _299 = _296 + _216;
  float _300 = max(0.0f, _297);
  float _301 = max(0.0f, _298);
  float _302 = max(0.0f, _299);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_300, _301, _302),
      apt_lut_output);
  _300 = apt_film_grain_output.x;
  _301 = apt_film_grain_output.y;
  _302 = apt_film_grain_output.z;
  float _306 = (User.c[2].y) / (User.c[2].x);
  int _309 = asint((Global.c[1].w));
  uint _310 = _309 + 30u;
  int _311 = _310 & 63;
  float _312 = _48 * 8.0f;
  float _313 = _312 * _306;
  float _314 = _49 * 8.0f;
  float _315 = float((int)(_309));
  float4 _316 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_313, _314, _315), 0.0f);
  float _318 = _48 + 0.5f;
  float _319 = (User.c[2].x) * 0.5f;
  float _320 = _318 + _319;
  float _321 = _306 * 8.0f;
  float _322 = _321 * _320;
  float _323 = _49 + 0.5f;
  float _324 = (User.c[2].y) * 0.5f;
  float _325 = _323 + _324;
  float _326 = _325 * 8.0f;
  float _327 = float((int)(_311));
  float4 _328 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_322, _326, _327), 0.0f);
  float _330 = _328.x + _316.x;
  float _331 = _330 * 0.714285671710968f;
  float _332 = _331 + -0.2142857164144516f;
  float _333 = saturate(_332);
  float _334 = _333 * 2.0f;
  float _335 = 3.0f - _334;
  float _336 = _333 * _333;
  float _337 = _336 * _335;
  float _338 = _337 * 0.5f;
  float _339 = _337 * 0.4000000059604645f;
  float _340 = _337 * 0.05000000074505806f;
  float _341 = _338 + -0.5f;
  float _342 = _339 + -0.6000000238418579f;
  float _343 = _340 + -0.949999988079071f;
  float _344 = _341 * _84;
  float _345 = _342 * _84;
  float _346 = _343 * _84;
  float _347 = _344 + 1.0f;
  float _348 = _345 + 1.0f;
  float _349 = _346 + 1.0f;
  float _350 = _347 * _300;
  float _351 = _348 * _301;
  float _352 = _349 * _302;
  float4 _353 = s13.Sample(s13Sampler, float2(_48, _49));
  float _360 = _99 + 1.0f;
  float _361 = saturate(_360);
  float _362 = (User.c[2].x) * _361;
  float _363 = (User.c[2].y) * _361;
  float _364 = _362 + _48;
  float _365 = _363 + _49;
  float4 _366 = s13.Sample(s13Sampler, float2(_364, _365));
  float _370 = _366.x + _353.x;
  float _371 = _366.y + _353.y;
  float _372 = _366.z + _353.z;
  float _373 = _371 * 0.5f;
  float _374 = _372 * 0.5f;
  float _375 = _274 * 0.30000001192092896f;
  float _376 = _375 + 0.699999988079071f;
  float _377 = saturate(_376);
  float _378 = _377 * 0.5f;
  float _379 = _378 * _370;
  float _380 = _373 * _377;
  float _381 = _374 * _377;
  float _382 = _84 * 0.6000000238418579f;
  float _383 = _382 * _82;
  float _384 = _84 * 0.7300000190734863f;
  float _385 = _384 * _82;
  float _386 = _84 * 0.8799999952316284f;
  float _387 = _386 * _82;
  float _388 = 1.0f - _383;
  float _389 = 1.0f - _385;
  float _390 = 1.0f - _387;
  float _391 = saturate(_388);
  float _392 = saturate(_389);
  float _393 = saturate(_390);
  float _394 = _350 * _391;
  float _395 = _351 * _392;
  float _396 = _352 * _393;
  float _397 = _394 + _379;
  float _398 = _395 + _380;
  float _399 = _396 + _381;
  bool _402 = ((User.c[3].x) > 0.0f);
  if (_402) {
    float _404 = log2(_397);
    float _405 = _404 * 3.0f;
    float _406 = exp2(_405);
    float _407 = _406 + -1.0f;
    float _408 = _397 + -1.0f;
    float _409 = _407 / _408;
    float _410 = _409 + -1.0f;
    bool _411 = !(_397 == 1.0f);
    float _412 = _410 / _409;
    float _413 = select(_411, _412, 0.6666666865348816f);
    float _414 = log2(_398);
    float _415 = _414 * 3.0f;
    float _416 = exp2(_415);
    float _417 = _416 + -1.0f;
    float _418 = _398 + -1.0f;
    float _419 = _417 / _418;
    float _420 = _419 + -1.0f;
    bool _421 = !(_398 == 1.0f);
    float _422 = _420 / _419;
    float _423 = select(_421, _422, 0.6666666865348816f);
    float _424 = log2(_399);
    float _425 = _424 * 3.0f;
    float _426 = exp2(_425);
    float _427 = _426 + -1.0f;
    float _428 = _399 + -1.0f;
    float _429 = _427 / _428;
    float _430 = _429 + -1.0f;
    bool _431 = !(_399 == 1.0f);
    float _432 = _430 / _429;
    float _433 = select(_431, _432, 0.6666666865348816f);
    bool _434 = (_413 <= 0.0031308000907301903f);
    bool _435 = (_423 <= 0.0031308000907301903f);
    bool _436 = (_433 <= 0.0031308000907301903f);
    float _437 = _413 * 12.920000076293945f;
    float _438 = _423 * 12.920000076293945f;
    float _439 = _433 * 12.920000076293945f;
    float _440 = log2(_413);
    float _441 = log2(_423);
    float _442 = log2(_433);
    float _443 = _440 * 0.4166666567325592f;
    float _444 = _441 * 0.4166666567325592f;
    float _445 = _442 * 0.4166666567325592f;
    float _446 = exp2(_443);
    float _447 = exp2(_444);
    float _448 = exp2(_445);
    float _449 = _446 * 1.0549999475479126f;
    float _450 = _447 * 1.0549999475479126f;
    float _451 = _448 * 1.0549999475479126f;
    float _452 = _449 + -0.054999999701976776f;
    float _453 = _450 + -0.054999999701976776f;
    float _454 = _451 + -0.054999999701976776f;
    float _455 = select(_434, _437, _452);
    float _456 = select(_435, _438, _453);
    float _457 = select(_436, _439, _454);
    int _459 = asint((User.c[3].y));
    int _460 = _459 & 1;
    bool _461 = (_460 == 0);
    if (!_461) {
      bool _470 = !(_455 <= (User.c[4].x));
      if (!_470) {
        float _472 = max(9.999999974752427e-07f, (User.c[4].x));
        float _473 = _455 / _472;
        float _474 = _473 * (User.c[4].y);
        float _475 = _473 * _473;
        float _476 = _475 * _473;
        float _477 = _476 - _473;
        float _478 = (User.c[3].z) * 0.1666666716337204f;
        float _479 = _472 * _472;
        float _480 = _479 * _478;
        float _481 = _480 * _477;
        float _482 = _481 + _474;
        _524 = _482;
      } else {
        bool _484 = !(_455 <= (User.c[4].z));
        if (!_484) {
          float _486 = (User.c[4].z) - (User.c[4].x);
          float _487 = max(9.999999974752427e-07f, _486);
          float _488 = _455 - (User.c[4].x);
          float _489 = _488 / _487;
          float _490 = 1.0f - _489;
          float _491 = _490 * (User.c[4].y);
          float _492 = _489 * (User.c[4].w);
          float _493 = _491 + _492;
          float _494 = _490 * _490;
          float _495 = _494 * _490;
          float _496 = _495 - _490;
          float _497 = _496 * (User.c[3].z);
          float _498 = _489 * _489;
          float _499 = _498 * _489;
          float _500 = _499 - _489;
          float _501 = _500 * (User.c[3].w);
          float _502 = _497 + _501;
          float _503 = _487 * _487;
          float _504 = _503 * 0.1666666716337204f;
          float _505 = _504 * _502;
          float _506 = _493 + _505;
          _524 = _506;
        } else {
          float _508 = 1.0f - (User.c[4].z);
          float _509 = _455 - (User.c[4].z);
          float _510 = max(9.999999974752427e-07f, _508);
          float _511 = _509 / _510;
          float _512 = 1.0f - _511;
          float _513 = _512 * (User.c[4].w);
          float _514 = _513 + _511;
          float _515 = _512 * _512;
          float _516 = _515 * _512;
          float _517 = _516 - _512;
          float _518 = _508 * _508;
          float _519 = _518 * 0.1666666716337204f;
          float _520 = _519 * (User.c[3].w);
          float _521 = _520 * _517;
          float _522 = _514 + _521;
          _524 = _522;
        }
      }
      float _525 = saturate(_524);
      bool _526 = !(_456 <= (User.c[4].x));
      if (!_526) {
        float _528 = max(9.999999974752427e-07f, (User.c[4].x));
        float _529 = _456 / _528;
        float _530 = _529 * (User.c[4].y);
        float _531 = _529 * _529;
        float _532 = _531 * _529;
        float _533 = _532 - _529;
        float _534 = (User.c[3].z) * 0.1666666716337204f;
        float _535 = _528 * _528;
        float _536 = _535 * _534;
        float _537 = _536 * _533;
        float _538 = _537 + _530;
        _580 = _538;
      } else {
        bool _540 = !(_456 <= (User.c[4].z));
        if (!_540) {
          float _542 = (User.c[4].z) - (User.c[4].x);
          float _543 = max(9.999999974752427e-07f, _542);
          float _544 = _456 - (User.c[4].x);
          float _545 = _544 / _543;
          float _546 = 1.0f - _545;
          float _547 = _546 * (User.c[4].y);
          float _548 = _545 * (User.c[4].w);
          float _549 = _547 + _548;
          float _550 = _546 * _546;
          float _551 = _550 * _546;
          float _552 = _551 - _546;
          float _553 = _552 * (User.c[3].z);
          float _554 = _545 * _545;
          float _555 = _554 * _545;
          float _556 = _555 - _545;
          float _557 = _556 * (User.c[3].w);
          float _558 = _553 + _557;
          float _559 = _543 * _543;
          float _560 = _559 * 0.1666666716337204f;
          float _561 = _560 * _558;
          float _562 = _549 + _561;
          _580 = _562;
        } else {
          float _564 = 1.0f - (User.c[4].z);
          float _565 = _456 - (User.c[4].z);
          float _566 = max(9.999999974752427e-07f, _564);
          float _567 = _565 / _566;
          float _568 = 1.0f - _567;
          float _569 = _568 * (User.c[4].w);
          float _570 = _569 + _567;
          float _571 = _568 * _568;
          float _572 = _571 * _568;
          float _573 = _572 - _568;
          float _574 = _564 * _564;
          float _575 = _574 * 0.1666666716337204f;
          float _576 = _575 * (User.c[3].w);
          float _577 = _576 * _573;
          float _578 = _570 + _577;
          _580 = _578;
        }
      }
      float _581 = saturate(_580);
      bool _582 = !(_457 <= (User.c[4].x));
      if (!_582) {
        float _584 = max(9.999999974752427e-07f, (User.c[4].x));
        float _585 = _457 / _584;
        float _586 = _585 * (User.c[4].y);
        float _587 = _585 * _585;
        float _588 = _587 * _585;
        float _589 = _588 - _585;
        float _590 = (User.c[3].z) * 0.1666666716337204f;
        float _591 = _584 * _584;
        float _592 = _591 * _590;
        float _593 = _592 * _589;
        float _594 = _593 + _586;
        _636 = _594;
      } else {
        bool _596 = !(_457 <= (User.c[4].z));
        if (!_596) {
          float _598 = (User.c[4].z) - (User.c[4].x);
          float _599 = max(9.999999974752427e-07f, _598);
          float _600 = _457 - (User.c[4].x);
          float _601 = _600 / _599;
          float _602 = 1.0f - _601;
          float _603 = _602 * (User.c[4].y);
          float _604 = _601 * (User.c[4].w);
          float _605 = _603 + _604;
          float _606 = _602 * _602;
          float _607 = _606 * _602;
          float _608 = _607 - _602;
          float _609 = _608 * (User.c[3].z);
          float _610 = _601 * _601;
          float _611 = _610 * _601;
          float _612 = _611 - _601;
          float _613 = _612 * (User.c[3].w);
          float _614 = _609 + _613;
          float _615 = _599 * _599;
          float _616 = _615 * 0.1666666716337204f;
          float _617 = _616 * _614;
          float _618 = _605 + _617;
          _636 = _618;
        } else {
          float _620 = 1.0f - (User.c[4].z);
          float _621 = _457 - (User.c[4].z);
          float _622 = max(9.999999974752427e-07f, _620);
          float _623 = _621 / _622;
          float _624 = 1.0f - _623;
          float _625 = _624 * (User.c[4].w);
          float _626 = _625 + _623;
          float _627 = _624 * _624;
          float _628 = _627 * _624;
          float _629 = _628 - _624;
          float _630 = _620 * _620;
          float _631 = _630 * 0.1666666716337204f;
          float _632 = _631 * (User.c[3].w);
          float _633 = _632 * _629;
          float _634 = _626 + _633;
          _636 = _634;
        }
      }
      float _637 = saturate(_636);
      _639 = _525;
      _640 = _581;
      _641 = _637;
    } else {
      _639 = _455;
      _640 = _456;
      _641 = _457;
    }
    int _642 = _459 & 2;
    bool _643 = (_642 == 0);
    if (!_643) {
      float _645 = sqrt(_639);
      float _646 = sqrt(_640);
      float _647 = sqrt(_641);
      float _648 = dot(float3(_645, _646, _647), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _649 = 1.0f - _648;
      float _650 = saturate(_649);
      _652 = _650;
    } else {
      _652 = 1.0f;
    }
    int _653 = _459 & 8;
    bool _654 = (_653 == 0);
    if (!_654) {
      bool _656 = (_652 <= 0.0031308000907301903f);
      float _657 = _652 * 12.920000076293945f;
      float _658 = log2(_652);
      float _659 = _658 * 0.4166666567325592f;
      float _660 = exp2(_659);
      float _661 = _660 * 1.0549999475479126f;
      float _662 = _661 + -0.054999999701976776f;
      float _663 = select(_656, _657, _662);
      _900 = _663;
      _901 = _663;
      _902 = _663;
    } else {
      int _665 = _459 & 4;
      bool _666 = (_665 == 0);
      if (!_666) {
        int _668 = _459 & 16;
        bool _669 = (_668 == 0);
        if (!_669) {
          float _673 = (User.c[5].x) * 0.5f;
          float _674 = _673 + 0.5f;
          bool _675 = (_674 < 0.5f);
          float _676 = (User.c[5].x) * 5.0f;
          float _677 = select(_675, (User.c[5].x), _676);
          bool _678 = (_640 < _641);
          float _679 = select(_678, _641, _640);
          float _680 = select(_678, _640, _641);
          bool _681 = (_639 < _679);
          float _682 = select(_681, _679, _639);
          float _683 = select(_681, _639, _679);
          float _684 = min(_683, _680);
          float _685 = _682 - _684;
          float _686 = _682 + 1.000000013351432e-10f;
          float _687 = _685 / _686;
          float _689 = _687 - (User.c[5].y);
          float _690 = saturate(_689);
          float _691 = max(_690, 9.999999974752427e-07f);
          float _692 = log2(_691);
          float _693 = _692 * _677;
          float _694 = exp2(_693);
          float _695 = 2.0f - _694;
          float _697 = 1.0f - (User.c[5].z);
          float _698 = saturate(_697);
          float _699 = max(_698, _695);
          float _700 = dot(float3(_639, _640, _641), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _701 = _639 - _700;
          float _702 = _640 - _700;
          float _703 = _641 - _700;
          float _704 = _701 * _699;
          float _705 = _702 * _699;
          float _706 = _703 * _699;
          float _707 = _700 - _639;
          float _708 = _707 + _704;
          float _709 = _700 - _640;
          float _710 = _709 + _705;
          float _711 = _700 - _641;
          float _712 = _711 + _706;
          float _713 = _708 * _652;
          float _714 = _710 * _652;
          float _715 = _712 * _652;
          float _716 = _713 + _639;
          float _717 = _714 + _640;
          float _718 = _715 + _641;
          _832 = _716;
          _833 = _717;
          _834 = _718;
        } else {
          bool _720 = (_652 == 0.0f);
          if (!_720) {
            float _724 = abs(User.c[5].x);
            float _725 = saturate(_724);
            uint2 _726; s15.GetDimensions(_726.x, _726.y);
            float _729 = float((uint)_726.y);
            int _730 = _459 & 32;
            bool _731 = (_730 == 0);
            float _732 = _729 + -1.0f;
            if (!_731) {
              float _734 = 1.0f / _732;
              uint _735 = uint(SV_Position.x);
              uint _736 = uint(SV_Position.y);
              int _737 = _735 & 63;
              int _738 = _736 & 63;
              float4 _739 = sBlueNoiseR8G8.Load(int4(_737, _738, 0, 0));
              float _742 = _739.x + -0.5f;
              float _743 = _639 * 13.999999046325684f;
              float _744 = _640 * 13.999999046325684f;
              float _745 = _641 * 13.999999046325684f;
              float _746 = saturate(_743);
              float _747 = saturate(_744);
              float _748 = saturate(_745);
              float _749 = _639 + -0.9285714030265808f;
              float _750 = _640 + -0.9285714030265808f;
              float _751 = _641 + -0.9285714030265808f;
              float _752 = _749 * 13.999999046325684f;
              float _753 = _750 * 13.999999046325684f;
              float _754 = _751 * 13.999999046325684f;
              float _755 = saturate(_752);
              float _756 = saturate(_753);
              float _757 = saturate(_754);
              float _758 = 1.0f - _755;
              float _759 = 1.0f - _756;
              float _760 = 1.0f - _757;
              float _761 = min(_746, _758);
              float _762 = min(_747, _759);
              float _763 = min(_748, _760);
              float _764 = _739.y + -0.5f;
              float _765 = _761 * _764;
              float _766 = _762 * _764;
              float _767 = _763 * _764;
              float _768 = _765 + _742;
              float _769 = _766 + _742;
              float _770 = _767 + _742;
              float _771 = _768 * _734;
              float _772 = _769 * _734;
              float _773 = _770 * _734;
              float _774 = _771 + _639;
              float _775 = _772 + _640;
              float _776 = _773 + _641;
              float _777 = saturate(_774);
              float _778 = saturate(_775);
              float _779 = saturate(_776);
              float _780 = saturate(_777);
              float _781 = saturate(_778);
              float _782 = saturate(_779);
              _784 = _780;
              _785 = _781;
              _786 = _782;
            } else {
              _784 = _639;
              _785 = _640;
              _786 = _641;
            }
            float _787 = float((uint)_726.x);
            float _788 = _732 / _787;
            float _789 = _788 * _784;
            float _790 = 0.5f / _787;
            float _791 = _789 + _790;
            float _792 = _732 / _729;
            float _793 = _792 * _785;
            float _794 = 0.5f / _729;
            float _795 = _793 + _794;
            float _796 = _786 * _732;
            float _797 = floor(_796);
            float _798 = frac(_796);
            float _799 = _797 / _729;
            float _800 = _799 + _791;
            float _801 = _797 + 1.0f;
            float _802 = _801 / _729;
            float _803 = _802 + _791;
            float4 _804 = s15.Sample(s15Sampler, float2(_800, _795));
            float4 _808 = s15.Sample(s15Sampler, float2(_803, _795));
            float _812 = _808.x - _804.x;
            float _813 = _808.y - _804.y;
            float _814 = _808.z - _804.z;
            float _815 = _812 * _798;
            float _816 = _813 * _798;
            float _817 = _814 * _798;
            float _818 = _725 * _652;
            float _819 = _804.x - _639;
            float _820 = _819 + _815;
            float _821 = _804.y - _640;
            float _822 = _821 + _816;
            float _823 = _804.z - _641;
            float _824 = _823 + _817;
            float _825 = _820 * _818;
            float _826 = _822 * _818;
            float _827 = _824 * _818;
            float _828 = _825 + _639;
            float _829 = _826 + _640;
            float _830 = _827 + _641;
            _832 = _828;
            _833 = _829;
            _834 = _830;
          } else {
            _832 = _639;
            _833 = _640;
            _834 = _641;
          }
        }
      } else {
        _832 = _639;
        _833 = _640;
        _834 = _641;
      }
      bool _835 = (_832 <= 0.040449999272823334f);
      bool _836 = (_833 <= 0.040449999272823334f);
      bool _837 = (_834 <= 0.040449999272823334f);
      float _838 = _832 * 0.07739938050508499f;
      float _839 = _833 * 0.07739938050508499f;
      float _840 = _834 * 0.07739938050508499f;
      float _841 = _832 + 0.054999999701976776f;
      float _842 = _833 + 0.054999999701976776f;
      float _843 = _834 + 0.054999999701976776f;
      float _844 = _841 * 0.9478673338890076f;
      float _845 = _842 * 0.9478673338890076f;
      float _846 = _843 * 0.9478673338890076f;
      float _847 = log2(_844);
      float _848 = log2(_845);
      float _849 = log2(_846);
      float _850 = _847 * 2.4000000953674316f;
      float _851 = _848 * 2.4000000953674316f;
      float _852 = _849 * 2.4000000953674316f;
      float _853 = exp2(_850);
      float _854 = exp2(_851);
      float _855 = exp2(_852);
      float _856 = select(_835, _838, _853);
      float _857 = select(_836, _839, _854);
      float _858 = select(_837, _840, _855);
      bool _859 = (_856 == 1.0f);
      if (!_859) {
        float _861 = _856 * _856;
        float _862 = _861 * 3.0f;
        float _863 = _856 * 2.0f;
        float _864 = _863 + 1.0f;
        float _865 = _864 - _862;
        float _866 = sqrt(_865);
        float _867 = _856 + -1.0f;
        float _868 = _867 * 2.0f;
        float _869 = _866 / _868;
        float _870 = -0.5f - _869;
        _872 = _870;
      } else {
        _872 = 1e+06f;
      }
      bool _873 = (_857 == 1.0f);
      if (!_873) {
        float _875 = _857 * _857;
        float _876 = _875 * 3.0f;
        float _877 = _857 * 2.0f;
        float _878 = _877 + 1.0f;
        float _879 = _878 - _876;
        float _880 = sqrt(_879);
        float _881 = _857 + -1.0f;
        float _882 = _881 * 2.0f;
        float _883 = _880 / _882;
        float _884 = -0.5f - _883;
        _886 = _884;
      } else {
        _886 = 1e+06f;
      }
      bool _887 = (_858 == 1.0f);
      if (!_887) {
        float _889 = _858 * _858;
        float _890 = _889 * 3.0f;
        float _891 = _858 * 2.0f;
        float _892 = _891 + 1.0f;
        float _893 = _892 - _890;
        float _894 = sqrt(_893);
        float _895 = _858 + -1.0f;
        float _896 = _895 * 2.0f;
        float _897 = _894 / _896;
        float _898 = -0.5f - _897;
        _900 = _872;
        _901 = _886;
        _902 = _898;
      } else {
        _900 = _872;
        _901 = _886;
        _902 = 1e+06f;
      }
    }
  } else {
    _900 = _397;
    _901 = _398;
    _902 = _399;
  }
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_397, _398, _399),
      float3(_900, _901, _902),
      false);
  _900 = apt_tonemapped.x;
  _901 = apt_tonemapped.y;
  _902 = apt_tonemapped.z;
  bool _903 = (_900 <= 0.0031308000907301903f);
  bool _904 = (_901 <= 0.0031308000907301903f);
  bool _905 = (_902 <= 0.0031308000907301903f);
  float _906 = _900 * 12.920000076293945f;
  float _907 = _901 * 12.920000076293945f;
  float _908 = _902 * 12.920000076293945f;
  float _909 = log2(_900);
  float _910 = log2(_901);
  float _911 = log2(_902);
  float _912 = _909 * 0.4166666567325592f;
  float _913 = _910 * 0.4166666567325592f;
  float _914 = _911 * 0.4166666567325592f;
  float _915 = exp2(_912);
  float _916 = exp2(_913);
  float _917 = exp2(_914);
  float _918 = _915 * 1.0549999475479126f;
  float _919 = _916 * 1.0549999475479126f;
  float _920 = _917 * 1.0549999475479126f;
  float _921 = _918 + -0.054999999701976776f;
  float _922 = _919 + -0.054999999701976776f;
  float _923 = _920 + -0.054999999701976776f;
  float _924 = select(_903, _906, _921);
  float _925 = select(_904, _907, _922);
  float _926 = select(_905, _908, _923);
  float _927 = log2(_924);
  float _928 = log2(_925);
  float _929 = log2(_926);
  float _930 = floor(_927);
  float _931 = floor(_928);
  float _932 = floor(_929);
  float _933 = _930 + -6.0f;
  float _934 = _931 + -6.0f;
  float _935 = _932 + -5.0f;
  float _936 = exp2(_933);
  float _937 = exp2(_934);
  float _938 = exp2(_935);
  uint _939 = uint(SV_Position.x);
  uint _940 = uint(SV_Position.y);
  int _941 = _939 & 63;
  int _942 = _940 & 63;
  float4 _943 = sBlueNoiseR8.Load(int4(_941, _942, 0, 0));
  float _945 = _943.x + -0.5f;
  bool _946 = (_924 > 0.0f);
  bool _947 = (_925 > 0.0f);
  bool _948 = (_926 > 0.0f);
  float _949 = float((bool)_946);
  float _950 = float((bool)_947);
  float _951 = float((bool)_948);
  float _952 = _936 * _949;
  float _953 = _952 * _945;
  float _954 = _937 * _950;
  float _955 = _954 * _945;
  float _956 = _938 * _951;
  float _957 = _956 * _945;
  float _958 = _953 + _924;
  float _959 = _955 + _925;
  float _960 = _957 + _926;
  SV_Target.x = _958;
  SV_Target.y = _959;
  SV_Target.z = _960;
  SV_Target.w = _52.w;
  return SV_Target;
}
