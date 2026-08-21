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
  float4 CBufferGlobalConstant_Z_raw[174] : packoffset(c0);
};

cbuffer CBufferUserConstant_Z : register(b0) {
  StructUserConstant_Z User : packoffset(c000.x);
  float4 CBufferUserConstant_Z_raw[183] : packoffset(c0);
};

cbuffer CBufferPostProcessConstant_Z : register(b2) {
  StructPostProcessConstant_Z PostProcess : packoffset(c000.x);
  float4 CBufferPostProcessConstant_Z_raw[48] : packoffset(c0);
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
  float _36 = _33.y * 0.10000000149011612f;
  float _37 = _36 + _29.y;
  float _38 = _33.y * 0.5f;
  float _39 = _38 + _29.z;
  float _40 = exp2(_39);
  float _41 = _40 + -1.0f;
  float _44 = (PostProcess.Settings[11].y) * _41;
  float _45 = _44 + 1.0f;
  float _46 = log2(_45);
  float _47 = _29.x + TEXCOORD.z;
  float _48 = _37 + TEXCOORD.w;
  float _49 = _29.x + TEXCOORD.x;
  float _50 = _37 + TEXCOORD.y;
  float _51 = _47 * 2.0f;
  float _52 = _48 * 2.0f;
  float _53 = _51 + -1.0f;
  float _54 = _52 + -1.0f;
  float _58 = (Global.c[37].x) * _53;
  float _59 = (Global.c[37].y) * _54;
  float _60 = _58 * _58;
  float _61 = _59 * _59;
  float _62 = _60 + _61;
  float _63 = sqrt(_62);
  float _66 = _49 * 2.0f;
  float _67 = _66 + -1.0f;
  float _68 = _50 * 1.125f;
  float _69 = _68 + -0.5625f;
  float _70 = _67 * _67;
  float _71 = _69 * _69;
  float _72 = _71 + _70;
  float _73 = sqrt(_72);
  float _74 = _73 * 0.8715755343437195f;
  float _75 = _74 * _74;
  float _76 = _75 + -0.15000000596046448f;
  float _77 = _76 * 1.8181819915771484f;
  float _78 = saturate(_77);
  float _79 = _78 * 2.0f;
  float _80 = 3.0f - _79;
  float _81 = (PostProcess.Settings[2].w) * _63;
  float _82 = _78 * _78;
  float _83 = _82 * _81;
  float _84 = _83 * _75;
  float _85 = _84 * _80;
  float _87 = (PostProcess.Settings[2].z) * _58;
  float _88 = (PostProcess.Settings[2].z) * _59;
  float _89 = _88 + _48;
  float _90 = _47 - _87;
  float _91 = _33.x * 0.010840999893844128f;
  float _92 = _47 + _91;
  float _93 = _92 + _87;
  float _94 = _48 + _91;
  float _95 = _94 - _88;
  float _96 = _85 + _46;
  float4 _97 = s0.SampleLevel(s0Sampler, float2(_93, _89), _96);
  float4 _99 = s0.SampleLevel(s0Sampler, float2(_90, _95), _96);
  float4 _101 = s0.SampleLevel(s0Sampler, float2(_47, _48), _96);
  float _104 = max(_97.x, 0.0f);
  float _105 = max(_99.y, 0.0f);
  float _106 = max(_101.z, 0.0f);
  float _109 = (Global.c[32].w) * 11.0f;
  float _110 = _109 + -1.2000000476837158f;
  float _111 = saturate(_110);
  float _112 = (Global.c[32].w) * 1.7000000476837158f;
  float _113 = 1.340000033378601f - _112;
  float _114 = saturate(_113);
  float _115 = _114 * _114;
  float _116 = _115 * _115;
  float _117 = _116 * _111;
  bool _118 = ((Global.c[32].w) < 9.999999747378752e-06f);
  float _121 = max((Global.c[33].y), _117);
  float _122 = _48 * 1.7999999523162842f;
  float _123 = _122 + -1.100000023841858f;
  float _124 = abs(_53);
  float _125 = abs(_123);
  float _126 = dot(float2(_124, _125), float2(_124, _125));
  float _127 = sqrt(_126);
  float _128 = select(_118, 1.0f, 0.0f);
  float _129 = _128 * _121;
  float4 _130 = s0.SampleLevel(s0Sampler, float2(_47, _48), 1.0f);
  float4 _134 = s0.SampleLevel(s0Sampler, float2(_47, _48), 2.0f);
  float4 _138 = s0.SampleLevel(s0Sampler, float2(_47, _48), 3.0f);
  float _142 = _126 * 1.7000000476837158f;
  float _143 = _142 + -0.6000000238418579f;
  float _144 = saturate(_143);
  float _145 = _126 * 1.475000023841858f;
  float _146 = _145 + -0.375f;
  float _147 = saturate(_146);
  float _148 = _126 * 1.2999999523162842f;
  float _149 = _148 + -0.15000000596046448f;
  float _150 = saturate(_149);
  float _151 = _138.x - _134.x;
  float _152 = _138.y - _134.y;
  float _153 = _138.z - _134.z;
  float _154 = _151 * _144;
  float _155 = _152 * _144;
  float _156 = _153 * _144;
  float _157 = _134.x - _130.x;
  float _158 = _157 + _154;
  float _159 = _134.y - _130.y;
  float _160 = _159 + _155;
  float _161 = _134.z - _130.z;
  float _162 = _161 + _156;
  float _163 = _158 * _147;
  float _164 = _160 * _147;
  float _165 = _162 * _147;
  float _166 = _150 * _129;
  float _167 = _130.x - _104;
  float _168 = _167 + _163;
  float _169 = _130.y - _105;
  float _170 = _169 + _164;
  float _171 = _130.z - _106;
  float _172 = _171 + _165;
  float _173 = _168 * _166;
  float _174 = _170 * _166;
  float _175 = _172 * _166;
  float _176 = _173 + _104;
  float _177 = _174 + _105;
  float _178 = _175 + _106;
  float4 _179 = s12_bloom.Sample(s12_bloomSampler, float2(_47, _48));
  float4 _183 = s8.Sample(s8Sampler, float2(_49, _50));
  float _190 = (PostProcess.Settings[4].w) * _183.x;
  float _191 = (PostProcess.Settings[4].w) * _183.y;
  float _192 = (PostProcess.Settings[4].w) * _183.z;
  float _193 = _190 + (PostProcess.Settings[4].z);
  float _194 = _191 + (PostProcess.Settings[4].z);
  float _195 = _192 + (PostProcess.Settings[4].z);
  float _196 = saturate(_193);
  float _197 = saturate(_194);
  float _198 = saturate(_195);
  float _199 = _179.x - _176;
  float _200 = _179.y - _177;
  float _201 = _179.z - _178;
  float _202 = _196 * _199;
  float _203 = _197 * _200;
  float _204 = _198 * _201;
  float _205 = _202 + _176;
  float _206 = _203 + _177;
  float _207 = _204 + _178;
  float4 _208 = s6.Load(int3(0, 0, 0));
  float _212 = (PostProcess.Settings[10].w) * 9.999999747378752e-05f;
  float _213 = _205 * 11190.6005859375f;
  float _214 = _213 * _208.x;
  float _215 = _214 * _212;
  float _216 = _206 * 11190.6005859375f;
  float _217 = _216 * _208.x;
  float _218 = _217 * _212;
  float _219 = _207 * 11190.6005859375f;
  float _220 = _219 * _208.x;
  float _221 = _220 * _212;
  float _222 = _215 + 1.0f;
  float _223 = _218 + 1.0f;
  float _224 = _221 + 1.0f;
  float _225 = log2(_222);
  float _226 = log2(_223);
  float _227 = log2(_224);
  float _228 = _225 * 0.07434873282909393f;
  float _229 = _226 * 0.07434873282909393f;
  float _230 = _227 * 0.07434873282909393f;
  float _233 = _228 * (PostProcess.OffsetWeight[0].x);
  float _234 = _229 * (PostProcess.OffsetWeight[0].x);
  float _235 = _230 * (PostProcess.OffsetWeight[0].x);
  float _237 = _233 + (PostProcess.OffsetWeight[0].y);
  float _238 = _234 + (PostProcess.OffsetWeight[0].y);
  float _239 = _235 + (PostProcess.OffsetWeight[0].y);
  float4 _240 = s3_3D.Sample(s3_3DSampler, float3(_237, _238, _239));
  float _246 = _240.x * 13.450128555297852f;
  float _247 = _240.y * 13.450128555297852f;
  float _248 = _240.z * 13.450128555297852f;
  float _249 = exp2(_246);
  float _250 = exp2(_247);
  float _251 = exp2(_248);
  float _252 = _249 + -1.0f;
  float _253 = _250 + -1.0f;
  float _254 = _251 + -1.0f;
  float _255 = _252 * 8.936070662457496e-05f;
  float _256 = _253 * 8.936070662457496e-05f;
  float _257 = _254 * 8.936070662457496e-05f;
  float _258 = 10000.0f / (PostProcess.Settings[10].w);
  float _259 = _255 * _258;
  float _260 = _256 * _258;
  float _261 = _257 * _258;
  const float apt_lut_input_encode_scale =
      11190.6005859375f * (PostProcess.Settings[10].w * 9.999999747378752e-05f);
  float3 apt_lut_output = APTApplyPostProcessLUTScaling(
      float3(_215, _218, _221) / apt_lut_input_encode_scale,
      float3(_259, _260, _261),
      s3_3D,
      s3_3DSampler,
      apt_lut_input_encode_scale,
      PostProcess.OffsetWeight[0].x,
      PostProcess.OffsetWeight[0].y,
      8.936070662457496e-05f * (10000.0f / PostProcess.Settings[10].w));
  _259 = apt_lut_output.x;
  _260 = apt_lut_output.y;
  _261 = apt_lut_output.z;
  float _265 = (User.c[2].y) / (User.c[2].x);
  int _268 = asint((Global.c[1].w));
  uint _269 = _268 + 30u;
  int _270 = _269 & 63;
  float _271 = _47 * 8.0f;
  float _272 = _271 * _265;
  float _273 = _48 * 8.0f;
  float _274 = float((int)(_268));
  float4 _275 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_272, _273, _274), 0.0f);
  float _277 = _47 + 0.5f;
  float _278 = (User.c[2].x) * 0.5f;
  float _279 = _277 + _278;
  float _280 = _265 * 8.0f;
  float _281 = _280 * _279;
  float _282 = _48 + 0.5f;
  float _283 = (User.c[2].y) * 0.5f;
  float _284 = _282 + _283;
  float _285 = _284 * 8.0f;
  float _286 = float((int)(_270));
  float4 _287 = sBlueNoiseR8G8.SampleLevel(sBlueNoiseR8G8Sampler, float3(_281, _285, _286), 0.0f);
  float _289 = _287.x + _275.x;
  float _290 = _289 * 0.714285671710968f;
  float _291 = _290 + -0.2142857164144516f;
  float _292 = saturate(_291);
  float _293 = _292 * 2.0f;
  float _294 = 3.0f - _293;
  float _295 = _292 * _292;
  float _296 = _295 * _294;
  float _297 = _296 * 0.5f;
  float _298 = _296 * 0.4000000059604645f;
  float _299 = _296 * 0.05000000074505806f;
  float _300 = _297 + -0.5f;
  float _301 = _298 + -0.6000000238418579f;
  float _302 = _299 + -0.949999988079071f;
  float _303 = _300 * _129;
  float _304 = _301 * _129;
  float _305 = _302 * _129;
  float _306 = _303 + 1.0f;
  float _307 = _304 + 1.0f;
  float _308 = _305 + 1.0f;
  float _309 = _259 * _306;
  float _310 = _260 * _307;
  float _311 = _261 * _308;
  float4 _312 = s13.Sample(s13Sampler, float2(_47, _48));
  float _319 = _144 + 1.0f;
  float _320 = saturate(_319);
  float _321 = (User.c[2].x) * _320;
  float _322 = (User.c[2].y) * _320;
  float _323 = _321 + _47;
  float _324 = _322 + _48;
  float4 _325 = s13.Sample(s13Sampler, float2(_323, _324));
  float _329 = _325.x + _312.x;
  float _330 = _325.y + _312.y;
  float _331 = _325.z + _312.z;
  float _332 = _329 * 0.5f;
  float _333 = _330 * 0.5f;
  float _334 = _331 * 0.5f;
  float _335 = _129 * 0.6000000238418579f;
  float _336 = _335 * _127;
  float _337 = _129 * 0.7300000190734863f;
  float _338 = _337 * _127;
  float _339 = _129 * 0.8799999952316284f;
  float _340 = _339 * _127;
  float _341 = 1.0f - _336;
  float _342 = 1.0f - _338;
  float _343 = 1.0f - _340;
  float _344 = saturate(_341);
  float _345 = saturate(_342);
  float _346 = saturate(_343);
  float _347 = _309 * _344;
  float _348 = _310 * _345;
  float _349 = _311 * _346;
  float _350 = _332 + _347;
  float _351 = _348 + _333;
  float _352 = _349 + _334;
  bool _355 = ((User.c[3].x) > 0.0f);
  float _477;
  float _533;
  float _589;
  float _592;
  float _593;
  float _594;
  float _605;
  float _737;
  float _738;
  float _739;
  float _785;
  float _786;
  float _787;
  float _825;
  float _839;
  float _853;
  float _854;
  float _855;
  if (_355) {
    float _357 = log2(_350);
    float _358 = _357 * 3.0f;
    float _359 = exp2(_358);
    float _360 = _359 + -1.0f;
    float _361 = _350 + -1.0f;
    float _362 = _360 / _361;
    float _363 = _362 + -1.0f;
    bool _364 = !(_350 == 1.0f);
    float _365 = _363 / _362;
    float _366 = select(_364, _365, 0.6666666865348816f);
    float _367 = log2(_351);
    float _368 = _367 * 3.0f;
    float _369 = exp2(_368);
    float _370 = _369 + -1.0f;
    float _371 = _351 + -1.0f;
    float _372 = _370 / _371;
    float _373 = _372 + -1.0f;
    bool _374 = !(_351 == 1.0f);
    float _375 = _373 / _372;
    float _376 = select(_374, _375, 0.6666666865348816f);
    float _377 = log2(_352);
    float _378 = _377 * 3.0f;
    float _379 = exp2(_378);
    float _380 = _379 + -1.0f;
    float _381 = _352 + -1.0f;
    float _382 = _380 / _381;
    float _383 = _382 + -1.0f;
    bool _384 = !(_352 == 1.0f);
    float _385 = _383 / _382;
    float _386 = select(_384, _385, 0.6666666865348816f);
    bool _387 = (_366 <= 0.0031308000907301903f);
    bool _388 = (_376 <= 0.0031308000907301903f);
    bool _389 = (_386 <= 0.0031308000907301903f);
    float _390 = _366 * 12.920000076293945f;
    float _391 = _376 * 12.920000076293945f;
    float _392 = _386 * 12.920000076293945f;
    float _393 = log2(_366);
    float _394 = log2(_376);
    float _395 = log2(_386);
    float _396 = _393 * 0.4166666567325592f;
    float _397 = _394 * 0.4166666567325592f;
    float _398 = _395 * 0.4166666567325592f;
    float _399 = exp2(_396);
    float _400 = exp2(_397);
    float _401 = exp2(_398);
    float _402 = _399 * 1.0549999475479126f;
    float _403 = _400 * 1.0549999475479126f;
    float _404 = _401 * 1.0549999475479126f;
    float _405 = _402 + -0.054999999701976776f;
    float _406 = _403 + -0.054999999701976776f;
    float _407 = _404 + -0.054999999701976776f;
    float _408 = select(_387, _390, _405);
    float _409 = select(_388, _391, _406);
    float _410 = select(_389, _392, _407);
    int _412 = asint((User.c[3].y));
    int _413 = _412 & 1;
    bool _414 = (_413 == 0);
    if (!_414) {
      bool _423 = !(_408 <= (User.c[4].x));
      if (!_423) {
        float _425 = max(9.999999974752427e-07f, (User.c[4].x));
        float _426 = _408 / _425;
        float _427 = _426 * (User.c[4].y);
        float _428 = _426 * _426;
        float _429 = _428 * _426;
        float _430 = _429 - _426;
        float _431 = (User.c[3].z) * 0.1666666716337204f;
        float _432 = _425 * _425;
        float _433 = _432 * _431;
        float _434 = _433 * _430;
        float _435 = _434 + _427;
        _477 = _435;
      } else {
        bool _437 = !(_408 <= (User.c[4].z));
        if (!_437) {
          float _439 = (User.c[4].z) - (User.c[4].x);
          float _440 = max(9.999999974752427e-07f, _439);
          float _441 = _408 - (User.c[4].x);
          float _442 = _441 / _440;
          float _443 = 1.0f - _442;
          float _444 = _443 * (User.c[4].y);
          float _445 = _442 * (User.c[4].w);
          float _446 = _444 + _445;
          float _447 = _443 * _443;
          float _448 = _447 * _443;
          float _449 = _448 - _443;
          float _450 = _449 * (User.c[3].z);
          float _451 = _442 * _442;
          float _452 = _451 * _442;
          float _453 = _452 - _442;
          float _454 = _453 * (User.c[3].w);
          float _455 = _450 + _454;
          float _456 = _440 * _440;
          float _457 = _456 * 0.1666666716337204f;
          float _458 = _457 * _455;
          float _459 = _446 + _458;
          _477 = _459;
        } else {
          float _461 = 1.0f - (User.c[4].z);
          float _462 = _408 - (User.c[4].z);
          float _463 = max(9.999999974752427e-07f, _461);
          float _464 = _462 / _463;
          float _465 = 1.0f - _464;
          float _466 = _465 * (User.c[4].w);
          float _467 = _466 + _464;
          float _468 = _465 * _465;
          float _469 = _468 * _465;
          float _470 = _469 - _465;
          float _471 = _461 * _461;
          float _472 = _471 * 0.1666666716337204f;
          float _473 = _472 * (User.c[3].w);
          float _474 = _473 * _470;
          float _475 = _467 + _474;
          _477 = _475;
        }
      }
      float _478 = saturate(_477);
      bool _479 = !(_409 <= (User.c[4].x));
      if (!_479) {
        float _481 = max(9.999999974752427e-07f, (User.c[4].x));
        float _482 = _409 / _481;
        float _483 = _482 * (User.c[4].y);
        float _484 = _482 * _482;
        float _485 = _484 * _482;
        float _486 = _485 - _482;
        float _487 = (User.c[3].z) * 0.1666666716337204f;
        float _488 = _481 * _481;
        float _489 = _488 * _487;
        float _490 = _489 * _486;
        float _491 = _490 + _483;
        _533 = _491;
      } else {
        bool _493 = !(_409 <= (User.c[4].z));
        if (!_493) {
          float _495 = (User.c[4].z) - (User.c[4].x);
          float _496 = max(9.999999974752427e-07f, _495);
          float _497 = _409 - (User.c[4].x);
          float _498 = _497 / _496;
          float _499 = 1.0f - _498;
          float _500 = _499 * (User.c[4].y);
          float _501 = _498 * (User.c[4].w);
          float _502 = _500 + _501;
          float _503 = _499 * _499;
          float _504 = _503 * _499;
          float _505 = _504 - _499;
          float _506 = _505 * (User.c[3].z);
          float _507 = _498 * _498;
          float _508 = _507 * _498;
          float _509 = _508 - _498;
          float _510 = _509 * (User.c[3].w);
          float _511 = _506 + _510;
          float _512 = _496 * _496;
          float _513 = _512 * 0.1666666716337204f;
          float _514 = _513 * _511;
          float _515 = _502 + _514;
          _533 = _515;
        } else {
          float _517 = 1.0f - (User.c[4].z);
          float _518 = _409 - (User.c[4].z);
          float _519 = max(9.999999974752427e-07f, _517);
          float _520 = _518 / _519;
          float _521 = 1.0f - _520;
          float _522 = _521 * (User.c[4].w);
          float _523 = _522 + _520;
          float _524 = _521 * _521;
          float _525 = _524 * _521;
          float _526 = _525 - _521;
          float _527 = _517 * _517;
          float _528 = _527 * 0.1666666716337204f;
          float _529 = _528 * (User.c[3].w);
          float _530 = _529 * _526;
          float _531 = _523 + _530;
          _533 = _531;
        }
      }
      float _534 = saturate(_533);
      bool _535 = !(_410 <= (User.c[4].x));
      if (!_535) {
        float _537 = max(9.999999974752427e-07f, (User.c[4].x));
        float _538 = _410 / _537;
        float _539 = _538 * (User.c[4].y);
        float _540 = _538 * _538;
        float _541 = _540 * _538;
        float _542 = _541 - _538;
        float _543 = (User.c[3].z) * 0.1666666716337204f;
        float _544 = _537 * _537;
        float _545 = _544 * _543;
        float _546 = _545 * _542;
        float _547 = _546 + _539;
        _589 = _547;
      } else {
        bool _549 = !(_410 <= (User.c[4].z));
        if (!_549) {
          float _551 = (User.c[4].z) - (User.c[4].x);
          float _552 = max(9.999999974752427e-07f, _551);
          float _553 = _410 - (User.c[4].x);
          float _554 = _553 / _552;
          float _555 = 1.0f - _554;
          float _556 = _555 * (User.c[4].y);
          float _557 = _554 * (User.c[4].w);
          float _558 = _556 + _557;
          float _559 = _555 * _555;
          float _560 = _559 * _555;
          float _561 = _560 - _555;
          float _562 = _561 * (User.c[3].z);
          float _563 = _554 * _554;
          float _564 = _563 * _554;
          float _565 = _564 - _554;
          float _566 = _565 * (User.c[3].w);
          float _567 = _562 + _566;
          float _568 = _552 * _552;
          float _569 = _568 * 0.1666666716337204f;
          float _570 = _569 * _567;
          float _571 = _558 + _570;
          _589 = _571;
        } else {
          float _573 = 1.0f - (User.c[4].z);
          float _574 = _410 - (User.c[4].z);
          float _575 = max(9.999999974752427e-07f, _573);
          float _576 = _574 / _575;
          float _577 = 1.0f - _576;
          float _578 = _577 * (User.c[4].w);
          float _579 = _578 + _576;
          float _580 = _577 * _577;
          float _581 = _580 * _577;
          float _582 = _581 - _577;
          float _583 = _573 * _573;
          float _584 = _583 * 0.1666666716337204f;
          float _585 = _584 * (User.c[3].w);
          float _586 = _585 * _582;
          float _587 = _579 + _586;
          _589 = _587;
        }
      }
      float _590 = saturate(_589);
      _592 = _478;
      _593 = _534;
      _594 = _590;
    } else {
      _592 = _408;
      _593 = _409;
      _594 = _410;
    }
    int _595 = _412 & 2;
    bool _596 = (_595 == 0);
    if (!_596) {
      float _598 = sqrt(_592);
      float _599 = sqrt(_593);
      float _600 = sqrt(_594);
      float _601 = dot(float3(_598, _599, _600), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _602 = 1.0f - _601;
      float _603 = saturate(_602);
      _605 = _603;
    } else {
      _605 = 1.0f;
    }
    int _606 = _412 & 8;
    bool _607 = (_606 == 0);
    if (!_607) {
      bool _609 = (_605 <= 0.0031308000907301903f);
      float _610 = _605 * 12.920000076293945f;
      float _611 = log2(_605);
      float _612 = _611 * 0.4166666567325592f;
      float _613 = exp2(_612);
      float _614 = _613 * 1.0549999475479126f;
      float _615 = _614 + -0.054999999701976776f;
      float _616 = select(_609, _610, _615);
      _853 = _616;
      _854 = _616;
      _855 = _616;
    } else {
      int _618 = _412 & 4;
      bool _619 = (_618 == 0);
      if (!_619) {
        int _621 = _412 & 16;
        bool _622 = (_621 == 0);
        if (!_622) {
          float _626 = (User.c[5].x) * 0.5f;
          float _627 = _626 + 0.5f;
          bool _628 = (_627 < 0.5f);
          float _629 = (User.c[5].x) * 5.0f;
          float _630 = select(_628, (User.c[5].x), _629);
          bool _631 = (_593 < _594);
          float _632 = select(_631, _594, _593);
          float _633 = select(_631, _593, _594);
          bool _634 = (_592 < _632);
          float _635 = select(_634, _632, _592);
          float _636 = select(_634, _592, _632);
          float _637 = min(_636, _633);
          float _638 = _635 - _637;
          float _639 = _635 + 1.000000013351432e-10f;
          float _640 = _638 / _639;
          float _642 = _640 - (User.c[5].y);
          float _643 = saturate(_642);
          float _644 = max(_643, 9.999999974752427e-07f);
          float _645 = log2(_644);
          float _646 = _645 * _630;
          float _647 = exp2(_646);
          float _648 = 2.0f - _647;
          float _650 = 1.0f - (User.c[5].z);
          float _651 = saturate(_650);
          float _652 = max(_651, _648);
          float _653 = dot(float3(_592, _593, _594), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _654 = _592 - _653;
          float _655 = _593 - _653;
          float _656 = _594 - _653;
          float _657 = _654 * _652;
          float _658 = _655 * _652;
          float _659 = _656 * _652;
          float _660 = _653 - _592;
          float _661 = _660 + _657;
          float _662 = _653 - _593;
          float _663 = _662 + _658;
          float _664 = _653 - _594;
          float _665 = _664 + _659;
          float _666 = _661 * _605;
          float _667 = _663 * _605;
          float _668 = _665 * _605;
          float _669 = _666 + _592;
          float _670 = _667 + _593;
          float _671 = _668 + _594;
          _785 = _669;
          _786 = _670;
          _787 = _671;
        } else {
          bool _673 = (_605 == 0.0f);
          if (!_673) {
            float _677 = abs(User.c[5].x);
            float _678 = saturate(_677);
            uint4 _679 = 0u; s15.GetDimensions(0u, _679.x, _679.y, _679.w);
            float _682 = float((uint)_679.y);
            int _683 = _412 & 32;
            bool _684 = (_683 == 0);
            float _685 = _682 + -1.0f;
            if (!_684) {
              float _687 = 1.0f / _685;
              uint _688 = uint(SV_Position.x);
              uint _689 = uint(SV_Position.y);
              int _690 = _688 & 63;
              int _691 = _689 & 63;
              float4 _692 = sBlueNoiseR8G8.Load(int4(_690, _691, 0, 0));
              float _695 = _692.x + -0.5f;
              float _696 = _592 * 13.999999046325684f;
              float _697 = _593 * 13.999999046325684f;
              float _698 = _594 * 13.999999046325684f;
              float _699 = saturate(_696);
              float _700 = saturate(_697);
              float _701 = saturate(_698);
              float _702 = _592 + -0.9285714030265808f;
              float _703 = _593 + -0.9285714030265808f;
              float _704 = _594 + -0.9285714030265808f;
              float _705 = _702 * 13.999999046325684f;
              float _706 = _703 * 13.999999046325684f;
              float _707 = _704 * 13.999999046325684f;
              float _708 = saturate(_705);
              float _709 = saturate(_706);
              float _710 = saturate(_707);
              float _711 = 1.0f - _708;
              float _712 = 1.0f - _709;
              float _713 = 1.0f - _710;
              float _714 = min(_699, _711);
              float _715 = min(_700, _712);
              float _716 = min(_701, _713);
              float _717 = _692.y + -0.5f;
              float _718 = _714 * _717;
              float _719 = _715 * _717;
              float _720 = _716 * _717;
              float _721 = _718 + _695;
              float _722 = _719 + _695;
              float _723 = _720 + _695;
              float _724 = _721 * _687;
              float _725 = _722 * _687;
              float _726 = _723 * _687;
              float _727 = _724 + _592;
              float _728 = _725 + _593;
              float _729 = _726 + _594;
              float _730 = saturate(_727);
              float _731 = saturate(_728);
              float _732 = saturate(_729);
              float _733 = saturate(_730);
              float _734 = saturate(_731);
              float _735 = saturate(_732);
              _737 = _733;
              _738 = _734;
              _739 = _735;
            } else {
              _737 = _592;
              _738 = _593;
              _739 = _594;
            }
            float _740 = float((uint)_679.x);
            float _741 = _685 / _740;
            float _742 = _741 * _737;
            float _743 = 0.5f / _740;
            float _744 = _742 + _743;
            float _745 = _685 / _682;
            float _746 = _745 * _738;
            float _747 = 0.5f / _682;
            float _748 = _746 + _747;
            float _749 = _739 * _685;
            float _750 = floor(_749);
            float _751 = frac(_749);
            float _752 = _750 / _682;
            float _753 = _752 + _744;
            float _754 = _750 + 1.0f;
            float _755 = _754 / _682;
            float _756 = _755 + _744;
            float4 _757 = s15.Sample(s15Sampler, float2(_753, _748));
            float4 _761 = s15.Sample(s15Sampler, float2(_756, _748));
            float _765 = _761.x - _757.x;
            float _766 = _761.y - _757.y;
            float _767 = _761.z - _757.z;
            float _768 = _765 * _751;
            float _769 = _766 * _751;
            float _770 = _767 * _751;
            float _771 = _678 * _605;
            float _772 = _757.x - _592;
            float _773 = _772 + _768;
            float _774 = _757.y - _593;
            float _775 = _774 + _769;
            float _776 = _757.z - _594;
            float _777 = _776 + _770;
            float _778 = _773 * _771;
            float _779 = _775 * _771;
            float _780 = _777 * _771;
            float _781 = _778 + _592;
            float _782 = _779 + _593;
            float _783 = _780 + _594;
            _785 = _781;
            _786 = _782;
            _787 = _783;
          } else {
            _785 = _592;
            _786 = _593;
            _787 = _594;
          }
        }
      } else {
        _785 = _592;
        _786 = _593;
        _787 = _594;
      }
      bool _788 = (_785 <= 0.040449999272823334f);
      bool _789 = (_786 <= 0.040449999272823334f);
      bool _790 = (_787 <= 0.040449999272823334f);
      float _791 = _785 * 0.07739938050508499f;
      float _792 = _786 * 0.07739938050508499f;
      float _793 = _787 * 0.07739938050508499f;
      float _794 = _785 + 0.054999999701976776f;
      float _795 = _786 + 0.054999999701976776f;
      float _796 = _787 + 0.054999999701976776f;
      float _797 = _794 * 0.9478673338890076f;
      float _798 = _795 * 0.9478673338890076f;
      float _799 = _796 * 0.9478673338890076f;
      float _800 = log2(_797);
      float _801 = log2(_798);
      float _802 = log2(_799);
      float _803 = _800 * 2.4000000953674316f;
      float _804 = _801 * 2.4000000953674316f;
      float _805 = _802 * 2.4000000953674316f;
      float _806 = exp2(_803);
      float _807 = exp2(_804);
      float _808 = exp2(_805);
      float _809 = select(_788, _791, _806);
      float _810 = select(_789, _792, _807);
      float _811 = select(_790, _793, _808);
      bool _812 = (_809 == 1.0f);
      if (!_812) {
        float _814 = _809 * _809;
        float _815 = _814 * 3.0f;
        float _816 = _809 * 2.0f;
        float _817 = _816 + 1.0f;
        float _818 = _817 - _815;
        float _819 = sqrt(_818);
        float _820 = _809 + -1.0f;
        float _821 = _820 * 2.0f;
        float _822 = _819 / _821;
        float _823 = -0.5f - _822;
        _825 = _823;
      } else {
        _825 = 1e+06f;
      }
      bool _826 = (_810 == 1.0f);
      if (!_826) {
        float _828 = _810 * _810;
        float _829 = _828 * 3.0f;
        float _830 = _810 * 2.0f;
        float _831 = _830 + 1.0f;
        float _832 = _831 - _829;
        float _833 = sqrt(_832);
        float _834 = _810 + -1.0f;
        float _835 = _834 * 2.0f;
        float _836 = _833 / _835;
        float _837 = -0.5f - _836;
        _839 = _837;
      } else {
        _839 = 1e+06f;
      }
      bool _840 = (_811 == 1.0f);
      if (!_840) {
        float _842 = _811 * _811;
        float _843 = _842 * 3.0f;
        float _844 = _811 * 2.0f;
        float _845 = _844 + 1.0f;
        float _846 = _845 - _843;
        float _847 = sqrt(_846);
        float _848 = _811 + -1.0f;
        float _849 = _848 * 2.0f;
        float _850 = _847 / _849;
        float _851 = -0.5f - _850;
        _853 = _825;
        _854 = _839;
        _855 = _851;
      } else {
        _853 = _825;
        _854 = _839;
        _855 = 1e+06f;
      }
    }
  } else {
    _853 = _350;
    _854 = _351;
    _855 = _352;
  }
  float3 apt_tonemapped = APTApplyPostProcessToneMap(
      float3(_350, _351, _352),
      float3(_853, _854, _855),
      false);
  _853 = apt_tonemapped.x;
  _854 = apt_tonemapped.y;
  _855 = apt_tonemapped.z;
  bool _856 = (_853 <= 0.0031308000907301903f);
  bool _857 = (_854 <= 0.0031308000907301903f);
  bool _858 = (_855 <= 0.0031308000907301903f);
  float _859 = _853 * 12.920000076293945f;
  float _860 = _854 * 12.920000076293945f;
  float _861 = _855 * 12.920000076293945f;
  float _862 = log2(_853);
  float _863 = log2(_854);
  float _864 = log2(_855);
  float _865 = _862 * 0.4166666567325592f;
  float _866 = _863 * 0.4166666567325592f;
  float _867 = _864 * 0.4166666567325592f;
  float _868 = exp2(_865);
  float _869 = exp2(_866);
  float _870 = exp2(_867);
  float _871 = _868 * 1.0549999475479126f;
  float _872 = _869 * 1.0549999475479126f;
  float _873 = _870 * 1.0549999475479126f;
  float _874 = _871 + -0.054999999701976776f;
  float _875 = _872 + -0.054999999701976776f;
  float _876 = _873 + -0.054999999701976776f;
  float _877 = select(_856, _859, _874);
  float _878 = select(_857, _860, _875);
  float _879 = select(_858, _861, _876);
  float _880 = log2(_877);
  float _881 = log2(_878);
  float _882 = log2(_879);
  float _883 = floor(_880);
  float _884 = floor(_881);
  float _885 = floor(_882);
  float _886 = _883 + -6.0f;
  float _887 = _884 + -6.0f;
  float _888 = _885 + -5.0f;
  float _889 = exp2(_886);
  float _890 = exp2(_887);
  float _891 = exp2(_888);
  uint _892 = uint(SV_Position.x);
  uint _893 = uint(SV_Position.y);
  int _894 = _892 & 63;
  int _895 = _893 & 63;
  float4 _896 = sBlueNoiseR8.Load(int4(_894, _895, 0, 0));
  float _898 = _896.x + -0.5f;
  bool _899 = (_877 > 0.0f);
  bool _900 = (_878 > 0.0f);
  bool _901 = (_879 > 0.0f);
  float _902 = float((bool)_899);
  float _903 = float((bool)_900);
  float _904 = float((bool)_901);
  float _905 = _889 * _902;
  float _906 = _905 * _898;
  float _907 = _890 * _903;
  float _908 = _907 * _898;
  float _909 = _891 * _904;
  float _910 = _909 * _898;
  float _911 = _906 + _877;
  float _912 = _908 + _878;
  float _913 = _910 + _879;
  SV_Target.x = _911;
  SV_Target.y = _912;
  SV_Target.z = _913;
  SV_Target.w = _101.w;
  return SV_Target;
}
