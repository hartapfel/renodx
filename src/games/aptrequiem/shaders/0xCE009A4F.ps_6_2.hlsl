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
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_55, _56, _57),
      max(_50.rgb, 0.f.xxx),
      float2(_46, _47),
      s0,
      s0Sampler,
      _45);
  _55 = renodx_chromatic_aberration_input.x;
  _56 = renodx_chromatic_aberration_input.y;
  _57 = renodx_chromatic_aberration_input.z;
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
  float _165 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _166 = _158 * 11190.6005859375f;
  float _167 = _166 * _161.x;
  float _168 = _167 * _165;
  float _169 = _159 * 11190.6005859375f;
  float _170 = _169 * _161.x;
  float _171 = _170 * _165;
  float _172 = _160 * 11190.6005859375f;
  float _173 = _172 * _161.x;
  float _174 = _173 * _165;
  float _175 = _168 + 1.0f;
  float _176 = _171 + 1.0f;
  float _177 = _174 + 1.0f;
  float _178 = log2(_175);
  float _179 = log2(_176);
  float _180 = log2(_177);
  float _181 = _178 * 0.07434873282909393f;
  float _182 = _179 * 0.07434873282909393f;
  float _183 = _180 * 0.07434873282909393f;
  float _186 = _181 * (PostProcess.OffsetWeight[0].x);
  float _187 = _182 * (PostProcess.OffsetWeight[0].x);
  float _188 = _183 * (PostProcess.OffsetWeight[0].x);
  float _190 = _186 + (PostProcess.OffsetWeight[0].y);
  float _191 = _187 + (PostProcess.OffsetWeight[0].y);
  float _192 = _188 + (PostProcess.OffsetWeight[0].y);
  float4 _193 = s3_3D.Sample(s3_3DSampler, float3(_190, _191, _192));
  float _199 = _193.x * 13.450128555297852f;
  float _200 = _193.y * 13.450128555297852f;
  float _201 = _193.z * 13.450128555297852f;
  float _202 = exp2(_199);
  float _203 = exp2(_200);
  float _204 = exp2(_201);
  float _205 = _202 + -1.0f;
  float _206 = _203 + -1.0f;
  float _207 = _204 + -1.0f;
  float _208 = _205 * 8.936070662457496e-05f;
  float _209 = _206 * 8.936070662457496e-05f;
  float _210 = _207 * 8.936070662457496e-05f;
  float _211 = 10000.0f / (PostProcess.Settings[10].w);
  float _212 = _208 * _211;
  float _213 = _209 * _211;
  float _214 = _210 * _211;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUT(
      float3(_168, _171, _174) / apt_lut_input_encode_scale,
      float3(_212, _213, _214));
  apt_lut_output = APTApplyPerceptualFilmGrain(apt_lut_output, SV_Position.xy);
  _212 = apt_lut_output.x;
  _213 = apt_lut_output.y;
  _214 = apt_lut_output.z;
  float _218 = (User.c[2].y) / (User.c[2].x);
  int _221 = asint((Global.c[1].w));
  uint _222 = _221 + 30u;
  int _223 = _222 & 63;
  float _224 = _46 * 8.0f;
  float _225 = _224 * _218;
  float _226 = _47 * 8.0f;
  float _227 = float((int)(_221));
  float4 _228 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_225, _226, _227), 0.0f);
  float _230 = _46 + 0.5f;
  float _231 = (User.c[2].x) * 0.5f;
  float _232 = _230 + _231;
  float _233 = _218 * 8.0f;
  float _234 = _233 * _232;
  float _235 = _47 + 0.5f;
  float _236 = (User.c[2].y) * 0.5f;
  float _237 = _235 + _236;
  float _238 = _237 * 8.0f;
  float _239 = float((int)(_223));
  float4 _240 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_234, _238, _239), 0.0f);
  float _242 = _240.x + _228.x;
  float _243 = _242 * 0.714285671710968f;
  float _244 = _243 + -0.2142857164144516f;
  float _245 = saturate(_244);
  float _246 = _245 * 2.0f;
  float _247 = 3.0f - _246;
  float _248 = _245 * _245;
  float _249 = _248 * _247;
  float _250 = _249 * 0.5f;
  float _251 = _249 * 0.4000000059604645f;
  float _252 = _249 * 0.05000000074505806f;
  float _253 = _250 + -0.5f;
  float _254 = _251 + -0.6000000238418579f;
  float _255 = _252 + -0.949999988079071f;
  float _256 = _253 * _82;
  float _257 = _254 * _82;
  float _258 = _255 * _82;
  float _259 = _256 + 1.0f;
  float _260 = _257 + 1.0f;
  float _261 = _258 + 1.0f;
  float _262 = _212 * _259;
  float _263 = _213 * _260;
  float _264 = _214 * _261;
  float4 _265 = s13.Sample(s13Sampler, float2(_46, _47));
  float _272 = _97 + 1.0f;
  float _273 = saturate(_272);
  float _274 = (User.c[2].x) * _273;
  float _275 = (User.c[2].y) * _273;
  float _276 = _274 + _46;
  float _277 = _275 + _47;
  float4 _278 = s13.Sample(s13Sampler, float2(_276, _277));
  float _282 = _278.x + _265.x;
  float _283 = _278.y + _265.y;
  float _284 = _278.z + _265.z;
  float _285 = _282 * 0.5f;
  float _286 = _283 * 0.5f;
  float _287 = _284 * 0.5f;
  float _288 = _82 * 0.6000000238418579f;
  float _289 = _288 * _80;
  float _290 = _82 * 0.7300000190734863f;
  float _291 = _290 * _80;
  float _292 = _82 * 0.8799999952316284f;
  float _293 = _292 * _80;
  float _294 = 1.0f - _289;
  float _295 = 1.0f - _291;
  float _296 = 1.0f - _293;
  float _297 = saturate(_294);
  float _298 = saturate(_295);
  float _299 = saturate(_296);
  float _300 = _262 * _297;
  float _301 = _263 * _298;
  float _302 = _264 * _299;
  float _303 = _285 + _300;
  float _304 = _301 + _286;
  float _305 = _302 + _287;
  bool _308 = ((User.c[3].x) > 0.0f);
  float _430;
  float _486;
  float _542;
  float _545;
  float _546;
  float _547;
  float _558;
  float _690;
  float _691;
  float _692;
  float _738;
  float _739;
  float _740;
  float _778;
  float _792;
  float _806;
  float _807;
  float _808;
  if (_308) {
    float _310 = log2(_303);
    float _311 = _310 * 3.0f;
    float _312 = exp2(_311);
    float _313 = _312 + -1.0f;
    float _314 = _303 + -1.0f;
    float _315 = _313 / _314;
    float _316 = _315 + -1.0f;
    bool _317 = !(_303 == 1.0f);
    float _318 = _316 / _315;
    float _319 = select(_317, _318, 0.6666666865348816f);
    float _320 = log2(_304);
    float _321 = _320 * 3.0f;
    float _322 = exp2(_321);
    float _323 = _322 + -1.0f;
    float _324 = _304 + -1.0f;
    float _325 = _323 / _324;
    float _326 = _325 + -1.0f;
    bool _327 = !(_304 == 1.0f);
    float _328 = _326 / _325;
    float _329 = select(_327, _328, 0.6666666865348816f);
    float _330 = log2(_305);
    float _331 = _330 * 3.0f;
    float _332 = exp2(_331);
    float _333 = _332 + -1.0f;
    float _334 = _305 + -1.0f;
    float _335 = _333 / _334;
    float _336 = _335 + -1.0f;
    bool _337 = !(_305 == 1.0f);
    float _338 = _336 / _335;
    float _339 = select(_337, _338, 0.6666666865348816f);
    bool _340 = (_319 <= 0.0031308000907301903f);
    bool _341 = (_329 <= 0.0031308000907301903f);
    bool _342 = (_339 <= 0.0031308000907301903f);
    float _343 = _319 * 12.920000076293945f;
    float _344 = _329 * 12.920000076293945f;
    float _345 = _339 * 12.920000076293945f;
    float _346 = log2(_319);
    float _347 = log2(_329);
    float _348 = log2(_339);
    float _349 = _346 * 0.4166666567325592f;
    float _350 = _347 * 0.4166666567325592f;
    float _351 = _348 * 0.4166666567325592f;
    float _352 = exp2(_349);
    float _353 = exp2(_350);
    float _354 = exp2(_351);
    float _355 = _352 * 1.0549999475479126f;
    float _356 = _353 * 1.0549999475479126f;
    float _357 = _354 * 1.0549999475479126f;
    float _358 = _355 + -0.054999999701976776f;
    float _359 = _356 + -0.054999999701976776f;
    float _360 = _357 + -0.054999999701976776f;
    float _361 = select(_340, _343, _358);
    float _362 = select(_341, _344, _359);
    float _363 = select(_342, _345, _360);
    int _365 = asint((User.c[3].y));
    int _366 = _365 & 1;
    bool _367 = (_366 == 0);
    if (!_367) {
      bool _376 = !(_361 <= (User.c[4].x));
      if (!_376) {
        float _378 = max(9.999999974752427e-07f, (User.c[4].x));
        float _379 = _361 / _378;
        float _380 = _379 * (User.c[4].y);
        float _381 = _379 * _379;
        float _382 = _381 * _379;
        float _383 = _382 - _379;
        float _384 = (User.c[3].z) * 0.1666666716337204f;
        float _385 = _378 * _378;
        float _386 = _385 * _384;
        float _387 = _386 * _383;
        float _388 = _387 + _380;
        _430 = _388;
      } else {
        bool _390 = !(_361 <= (User.c[4].z));
        if (!_390) {
          float _392 = (User.c[4].z) - (User.c[4].x);
          float _393 = max(9.999999974752427e-07f, _392);
          float _394 = _361 - (User.c[4].x);
          float _395 = _394 / _393;
          float _396 = 1.0f - _395;
          float _397 = _396 * (User.c[4].y);
          float _398 = _395 * (User.c[4].w);
          float _399 = _397 + _398;
          float _400 = _396 * _396;
          float _401 = _400 * _396;
          float _402 = _401 - _396;
          float _403 = _402 * (User.c[3].z);
          float _404 = _395 * _395;
          float _405 = _404 * _395;
          float _406 = _405 - _395;
          float _407 = _406 * (User.c[3].w);
          float _408 = _403 + _407;
          float _409 = _393 * _393;
          float _410 = _409 * 0.1666666716337204f;
          float _411 = _410 * _408;
          float _412 = _399 + _411;
          _430 = _412;
        } else {
          float _414 = 1.0f - (User.c[4].z);
          float _415 = _361 - (User.c[4].z);
          float _416 = max(9.999999974752427e-07f, _414);
          float _417 = _415 / _416;
          float _418 = 1.0f - _417;
          float _419 = _418 * (User.c[4].w);
          float _420 = _419 + _417;
          float _421 = _418 * _418;
          float _422 = _421 * _418;
          float _423 = _422 - _418;
          float _424 = _414 * _414;
          float _425 = _424 * 0.1666666716337204f;
          float _426 = _425 * (User.c[3].w);
          float _427 = _426 * _423;
          float _428 = _420 + _427;
          _430 = _428;
        }
      }
      float _431 = saturate(_430);
      bool _432 = !(_362 <= (User.c[4].x));
      if (!_432) {
        float _434 = max(9.999999974752427e-07f, (User.c[4].x));
        float _435 = _362 / _434;
        float _436 = _435 * (User.c[4].y);
        float _437 = _435 * _435;
        float _438 = _437 * _435;
        float _439 = _438 - _435;
        float _440 = (User.c[3].z) * 0.1666666716337204f;
        float _441 = _434 * _434;
        float _442 = _441 * _440;
        float _443 = _442 * _439;
        float _444 = _443 + _436;
        _486 = _444;
      } else {
        bool _446 = !(_362 <= (User.c[4].z));
        if (!_446) {
          float _448 = (User.c[4].z) - (User.c[4].x);
          float _449 = max(9.999999974752427e-07f, _448);
          float _450 = _362 - (User.c[4].x);
          float _451 = _450 / _449;
          float _452 = 1.0f - _451;
          float _453 = _452 * (User.c[4].y);
          float _454 = _451 * (User.c[4].w);
          float _455 = _453 + _454;
          float _456 = _452 * _452;
          float _457 = _456 * _452;
          float _458 = _457 - _452;
          float _459 = _458 * (User.c[3].z);
          float _460 = _451 * _451;
          float _461 = _460 * _451;
          float _462 = _461 - _451;
          float _463 = _462 * (User.c[3].w);
          float _464 = _459 + _463;
          float _465 = _449 * _449;
          float _466 = _465 * 0.1666666716337204f;
          float _467 = _466 * _464;
          float _468 = _455 + _467;
          _486 = _468;
        } else {
          float _470 = 1.0f - (User.c[4].z);
          float _471 = _362 - (User.c[4].z);
          float _472 = max(9.999999974752427e-07f, _470);
          float _473 = _471 / _472;
          float _474 = 1.0f - _473;
          float _475 = _474 * (User.c[4].w);
          float _476 = _475 + _473;
          float _477 = _474 * _474;
          float _478 = _477 * _474;
          float _479 = _478 - _474;
          float _480 = _470 * _470;
          float _481 = _480 * 0.1666666716337204f;
          float _482 = _481 * (User.c[3].w);
          float _483 = _482 * _479;
          float _484 = _476 + _483;
          _486 = _484;
        }
      }
      float _487 = saturate(_486);
      bool _488 = !(_363 <= (User.c[4].x));
      if (!_488) {
        float _490 = max(9.999999974752427e-07f, (User.c[4].x));
        float _491 = _363 / _490;
        float _492 = _491 * (User.c[4].y);
        float _493 = _491 * _491;
        float _494 = _493 * _491;
        float _495 = _494 - _491;
        float _496 = (User.c[3].z) * 0.1666666716337204f;
        float _497 = _490 * _490;
        float _498 = _497 * _496;
        float _499 = _498 * _495;
        float _500 = _499 + _492;
        _542 = _500;
      } else {
        bool _502 = !(_363 <= (User.c[4].z));
        if (!_502) {
          float _504 = (User.c[4].z) - (User.c[4].x);
          float _505 = max(9.999999974752427e-07f, _504);
          float _506 = _363 - (User.c[4].x);
          float _507 = _506 / _505;
          float _508 = 1.0f - _507;
          float _509 = _508 * (User.c[4].y);
          float _510 = _507 * (User.c[4].w);
          float _511 = _509 + _510;
          float _512 = _508 * _508;
          float _513 = _512 * _508;
          float _514 = _513 - _508;
          float _515 = _514 * (User.c[3].z);
          float _516 = _507 * _507;
          float _517 = _516 * _507;
          float _518 = _517 - _507;
          float _519 = _518 * (User.c[3].w);
          float _520 = _515 + _519;
          float _521 = _505 * _505;
          float _522 = _521 * 0.1666666716337204f;
          float _523 = _522 * _520;
          float _524 = _511 + _523;
          _542 = _524;
        } else {
          float _526 = 1.0f - (User.c[4].z);
          float _527 = _363 - (User.c[4].z);
          float _528 = max(9.999999974752427e-07f, _526);
          float _529 = _527 / _528;
          float _530 = 1.0f - _529;
          float _531 = _530 * (User.c[4].w);
          float _532 = _531 + _529;
          float _533 = _530 * _530;
          float _534 = _533 * _530;
          float _535 = _534 - _530;
          float _536 = _526 * _526;
          float _537 = _536 * 0.1666666716337204f;
          float _538 = _537 * (User.c[3].w);
          float _539 = _538 * _535;
          float _540 = _532 + _539;
          _542 = _540;
        }
      }
      float _543 = saturate(_542);
      _545 = _431;
      _546 = _487;
      _547 = _543;
    } else {
      _545 = _361;
      _546 = _362;
      _547 = _363;
    }
    int _548 = _365 & 2;
    bool _549 = (_548 == 0);
    if (!_549) {
      float _551 = sqrt(_545);
      float _552 = sqrt(_546);
      float _553 = sqrt(_547);
      float _554 = dot(float3(_551, _552, _553), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _555 = 1.0f - _554;
      float _556 = saturate(_555);
      _558 = _556;
    } else {
      _558 = 1.0f;
    }
    int _559 = _365 & 8;
    bool _560 = (_559 == 0);
    if (!_560) {
      bool _562 = (_558 <= 0.0031308000907301903f);
      float _563 = _558 * 12.920000076293945f;
      float _564 = log2(_558);
      float _565 = _564 * 0.4166666567325592f;
      float _566 = exp2(_565);
      float _567 = _566 * 1.0549999475479126f;
      float _568 = _567 + -0.054999999701976776f;
      float _569 = select(_562, _563, _568);
      _806 = _569;
      _807 = _569;
      _808 = _569;
    } else {
      int _571 = _365 & 4;
      bool _572 = (_571 == 0);
      if (!_572) {
        int _574 = _365 & 16;
        bool _575 = (_574 == 0);
        if (!_575) {
          float _579 = (User.c[5].x) * 0.5f;
          float _580 = _579 + 0.5f;
          bool _581 = (_580 < 0.5f);
          float _582 = (User.c[5].x) * 5.0f;
          float _583 = select(_581, (User.c[5].x), _582);
          bool _584 = (_546 < _547);
          float _585 = select(_584, _547, _546);
          float _586 = select(_584, _546, _547);
          bool _587 = (_545 < _585);
          float _588 = select(_587, _585, _545);
          float _589 = select(_587, _545, _585);
          float _590 = min(_589, _586);
          float _591 = _588 - _590;
          float _592 = _588 + 1.000000013351432e-10f;
          float _593 = _591 / _592;
          float _595 = _593 - (User.c[5].y);
          float _596 = saturate(_595);
          float _597 = max(_596, 9.999999974752427e-07f);
          float _598 = log2(_597);
          float _599 = _598 * _583;
          float _600 = exp2(_599);
          float _601 = 2.0f - _600;
          float _603 = 1.0f - (User.c[5].z);
          float _604 = saturate(_603);
          float _605 = max(_604, _601);
          float _606 = dot(float3(_545, _546, _547), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _607 = _545 - _606;
          float _608 = _546 - _606;
          float _609 = _547 - _606;
          float _610 = _607 * _605;
          float _611 = _608 * _605;
          float _612 = _609 * _605;
          float _613 = _606 - _545;
          float _614 = _613 + _610;
          float _615 = _606 - _546;
          float _616 = _615 + _611;
          float _617 = _606 - _547;
          float _618 = _617 + _612;
          float _619 = _614 * _558;
          float _620 = _616 * _558;
          float _621 = _618 * _558;
          float _622 = _619 + _545;
          float _623 = _620 + _546;
          float _624 = _621 + _547;
          _738 = _622;
          _739 = _623;
          _740 = _624;
        } else {
          bool _626 = (_558 == 0.0f);
          if (!_626) {
            float _630 = abs(User.c[5].x);
            float _631 = saturate(_630);
            uint4 _632 = 0u; s15.GetDimensions(0u, _632.x, _632.y, _632.w);
            float _635 = float((uint)_632.y);
            int _636 = _365 & 32;
            bool _637 = (_636 == 0);
            float _638 = _635 + -1.0f;
            if (!_637) {
              float _640 = 1.0f / _638;
              uint _641 = uint(SV_Position.x);
              uint _642 = uint(SV_Position.y);
              int _643 = _641 & 63;
              int _644 = _642 & 63;
              float4 _645 = sBlueNoiseR8G8.Load(int4(_643, _644, 0, 0));
              float _648 = _645.x + -0.5f;
              float _649 = _545 * 13.999999046325684f;
              float _650 = _546 * 13.999999046325684f;
              float _651 = _547 * 13.999999046325684f;
              float _652 = saturate(_649);
              float _653 = saturate(_650);
              float _654 = saturate(_651);
              float _655 = _545 + -0.9285714030265808f;
              float _656 = _546 + -0.9285714030265808f;
              float _657 = _547 + -0.9285714030265808f;
              float _658 = _655 * 13.999999046325684f;
              float _659 = _656 * 13.999999046325684f;
              float _660 = _657 * 13.999999046325684f;
              float _661 = saturate(_658);
              float _662 = saturate(_659);
              float _663 = saturate(_660);
              float _664 = 1.0f - _661;
              float _665 = 1.0f - _662;
              float _666 = 1.0f - _663;
              float _667 = min(_652, _664);
              float _668 = min(_653, _665);
              float _669 = min(_654, _666);
              float _670 = _645.y + -0.5f;
              float _671 = _667 * _670;
              float _672 = _668 * _670;
              float _673 = _669 * _670;
              float _674 = _671 + _648;
              float _675 = _672 + _648;
              float _676 = _673 + _648;
              float _677 = _674 * _640;
              float _678 = _675 * _640;
              float _679 = _676 * _640;
              float _680 = _677 + _545;
              float _681 = _678 + _546;
              float _682 = _679 + _547;
              float _683 = saturate(_680);
              float _684 = saturate(_681);
              float _685 = saturate(_682);
              float _686 = saturate(_683);
              float _687 = saturate(_684);
              float _688 = saturate(_685);
              _690 = _686;
              _691 = _687;
              _692 = _688;
            } else {
              _690 = _545;
              _691 = _546;
              _692 = _547;
            }
            float _693 = float((uint)_632.x);
            float _694 = _638 / _693;
            float _695 = _694 * _690;
            float _696 = 0.5f / _693;
            float _697 = _695 + _696;
            float _698 = _638 / _635;
            float _699 = _698 * _691;
            float _700 = 0.5f / _635;
            float _701 = _699 + _700;
            float _702 = _692 * _638;
            float _703 = floor(_702);
            float _704 = frac(_702);
            float _705 = _703 / _635;
            float _706 = _705 + _697;
            float _707 = _703 + 1.0f;
            float _708 = _707 / _635;
            float _709 = _708 + _697;
            float4 _710 = s15.Sample(s15Sampler, float2(_706, _701));
            float4 _714 = s15.Sample(s15Sampler, float2(_709, _701));
            float _718 = _714.x - _710.x;
            float _719 = _714.y - _710.y;
            float _720 = _714.z - _710.z;
            float _721 = _718 * _704;
            float _722 = _719 * _704;
            float _723 = _720 * _704;
            float _724 = _631 * _558;
            float _725 = _710.x - _545;
            float _726 = _725 + _721;
            float _727 = _710.y - _546;
            float _728 = _727 + _722;
            float _729 = _710.z - _547;
            float _730 = _729 + _723;
            float _731 = _726 * _724;
            float _732 = _728 * _724;
            float _733 = _730 * _724;
            float _734 = _731 + _545;
            float _735 = _732 + _546;
            float _736 = _733 + _547;
            _738 = _734;
            _739 = _735;
            _740 = _736;
          } else {
            _738 = _545;
            _739 = _546;
            _740 = _547;
          }
        }
      } else {
        _738 = _545;
        _739 = _546;
        _740 = _547;
      }
      bool _741 = (_738 <= 0.040449999272823334f);
      bool _742 = (_739 <= 0.040449999272823334f);
      bool _743 = (_740 <= 0.040449999272823334f);
      float _744 = _738 * 0.07739938050508499f;
      float _745 = _739 * 0.07739938050508499f;
      float _746 = _740 * 0.07739938050508499f;
      float _747 = _738 + 0.054999999701976776f;
      float _748 = _739 + 0.054999999701976776f;
      float _749 = _740 + 0.054999999701976776f;
      float _750 = _747 * 0.9478673338890076f;
      float _751 = _748 * 0.9478673338890076f;
      float _752 = _749 * 0.9478673338890076f;
      float _753 = log2(_750);
      float _754 = log2(_751);
      float _755 = log2(_752);
      float _756 = _753 * 2.4000000953674316f;
      float _757 = _754 * 2.4000000953674316f;
      float _758 = _755 * 2.4000000953674316f;
      float _759 = exp2(_756);
      float _760 = exp2(_757);
      float _761 = exp2(_758);
      float _762 = select(_741, _744, _759);
      float _763 = select(_742, _745, _760);
      float _764 = select(_743, _746, _761);
      bool _765 = (_762 == 1.0f);
      if (!_765) {
        float _767 = _762 * _762;
        float _768 = _767 * 3.0f;
        float _769 = _762 * 2.0f;
        float _770 = _769 + 1.0f;
        float _771 = _770 - _768;
        float _772 = sqrt(_771);
        float _773 = _762 + -1.0f;
        float _774 = _773 * 2.0f;
        float _775 = _772 / _774;
        float _776 = -0.5f - _775;
        _778 = _776;
      } else {
        _778 = 1e+06f;
      }
      bool _779 = (_763 == 1.0f);
      if (!_779) {
        float _781 = _763 * _763;
        float _782 = _781 * 3.0f;
        float _783 = _763 * 2.0f;
        float _784 = _783 + 1.0f;
        float _785 = _784 - _782;
        float _786 = sqrt(_785);
        float _787 = _763 + -1.0f;
        float _788 = _787 * 2.0f;
        float _789 = _786 / _788;
        float _790 = -0.5f - _789;
        _792 = _790;
      } else {
        _792 = 1e+06f;
      }
      bool _793 = (_764 == 1.0f);
      if (!_793) {
        float _795 = _764 * _764;
        float _796 = _795 * 3.0f;
        float _797 = _764 * 2.0f;
        float _798 = _797 + 1.0f;
        float _799 = _798 - _796;
        float _800 = sqrt(_799);
        float _801 = _764 + -1.0f;
        float _802 = _801 * 2.0f;
        float _803 = _800 / _802;
        float _804 = -0.5f - _803;
        _806 = _778;
        _807 = _792;
        _808 = _804;
      } else {
        _806 = _778;
        _807 = _792;
        _808 = 1e+06f;
      }
    }
  } else {
    _806 = _303;
    _807 = _304;
    _808 = _305;
  }
  float _809 = log2(_806);
  float _810 = _809 * 3.0f;
  float _811 = exp2(_810);
  float _812 = _811 + -1.0f;
  float _813 = _806 + -1.0f;
  float _814 = _812 / _813;
  float _815 = _814 + -1.0f;
  bool _816 = !(_806 == 1.0f);
  float _817 = _815 / _814;
  float _818 = select(_816, _817, 0.6666666865348816f);
  float _819 = log2(_807);
  float _820 = _819 * 3.0f;
  float _821 = exp2(_820);
  float _822 = _821 + -1.0f;
  float _823 = _807 + -1.0f;
  float _824 = _822 / _823;
  float _825 = _824 + -1.0f;
  bool _826 = !(_807 == 1.0f);
  float _827 = _825 / _824;
  float _828 = select(_826, _827, 0.6666666865348816f);
  float _829 = log2(_808);
  float _830 = _829 * 3.0f;
  float _831 = exp2(_830);
  float _832 = _831 + -1.0f;
  float _833 = _808 + -1.0f;
  float _834 = _832 / _833;
  float _835 = _834 + -1.0f;
  bool _836 = !(_808 == 1.0f);
  float _837 = _835 / _834;
  float _838 = select(_836, _837, 0.6666666865348816f);
  float _839 = saturate(_818);
  float _840 = saturate(_828);
  float _841 = saturate(_838);
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_303, _304, _305),
      float3(_839, _840, _841),
      false);
  _839 = apt_tonemapped.x;
  _840 = apt_tonemapped.y;
  _841 = apt_tonemapped.z;
  bool _842 = (_839 <= 0.0031308000907301903f);
  bool _843 = (_840 <= 0.0031308000907301903f);
  bool _844 = (_841 <= 0.0031308000907301903f);
  float _845 = _839 * 12.920000076293945f;
  float _846 = _840 * 12.920000076293945f;
  float _847 = _841 * 12.920000076293945f;
  float _848 = log2(_839);
  float _849 = log2(_840);
  float _850 = log2(_841);
  float _851 = _848 * 0.4166666567325592f;
  float _852 = _849 * 0.4166666567325592f;
  float _853 = _850 * 0.4166666567325592f;
  float _854 = exp2(_851);
  float _855 = exp2(_852);
  float _856 = exp2(_853);
  float _857 = _854 * 1.0549999475479126f;
  float _858 = _855 * 1.0549999475479126f;
  float _859 = _856 * 1.0549999475479126f;
  float _860 = _857 + -0.054999999701976776f;
  float _861 = _858 + -0.054999999701976776f;
  float _862 = _859 + -0.054999999701976776f;
  float _863 = select(_842, _845, _860);
  float _864 = select(_843, _846, _861);
  float _865 = select(_844, _847, _862);
  int _868 = asint((Global.c[1].w));
  uint _869 = uint(SV_Position.x);
  uint _870 = uint(SV_Position.y);
  int _871 = _869 & 63;
  int _872 = _870 & 63;
  float4 _873 = sBlueNoiseR8.Load(int4(_871, _872, _868, 0));
  float _875 = _873.x * 0.003921568859368563f;
  float _876 = _863 + 0.003921568859368563f;
  float _877 = _876 - _875;
  float _878 = _875 + _864;
  float _879 = _875 + _865;
  SV_Target.x = _877;
  SV_Target.y = _878;
  SV_Target.z = _879;
  SV_Target.w = _50.w;
  return SV_Target;
}
