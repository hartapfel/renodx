#include "../common.hlsli"

ByteAddressBuffer t1_space1 : register(t1, space1);

cbuffer cb14 : register(b14) {
  int RootSrtCbv_000 : packoffset(c000.x);
  int RootSrtCbv_004 : packoffset(c000.y);
};

SamplerState s12 : register(s12);

SamplerState s0 : register(s0);

SamplerState s1 : register(s1);

struct OutputSignature {
  float4 SV_Target : SV_Target;
  float SV_Target_1 : SV_Target1;
};

OutputSignature main(
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD
) {
  float4 SV_Target = 0;
  float SV_Target_1 = 0;
  SV_Target.x = 0.0f;
  SV_Target.y = 0.0f;
  SV_Target.z = 0.0f;
  SV_Target.w = 0.0f;
  SV_Target_1 = 0.0f;
  uint _12 = (uint)(RootSrtCbv_000) + 32u;
  uint _13 = (uint)(RootSrtCbv_000) + 64u;
  uint _14 = (uint)(RootSrtCbv_000) + 96u;
  uint _15 = (uint)(RootSrtCbv_000) + 128u;
  uint _16 = (uint)(RootSrtCbv_000) + 160u;
  uint _17 = (uint)(RootSrtCbv_000) + 192u;
  uint _18 = (uint)(RootSrtCbv_000) + 224u;
  uint _19 = (uint)(RootSrtCbv_000) + 256u;
  uint _20 = (uint)(RootSrtCbv_000) + 272u;
  float4 _21 = asfloat(t1_space1.Load4(_20));
  uint _26 = (uint)(RootSrtCbv_000) + 288u;
  float4 _27 = asfloat(t1_space1.Load4(_26));
  uint _32 = (uint)(RootSrtCbv_000) + 304u;
  float4 _33 = asfloat(t1_space1.Load4(_32));
  uint _35 = (uint)(RootSrtCbv_000) + 308u;
  float4 _36 = asfloat(t1_space1.Load4(_35));
  uint _41 = (uint)(RootSrtCbv_000) + 324u;
  float4 _42 = asfloat(t1_space1.Load4(_41));
  uint _47 = (uint)(RootSrtCbv_000) + 340u;
  float4 _48 = asfloat(t1_space1.Load4(_47));
  uint _50 = (uint)(RootSrtCbv_000) + 344u;
  uint _51 = (uint)(RootSrtCbv_000) + 368u;
  float4 _52 = asfloat(t1_space1.Load4(_51));
  uint _54 = (uint)(RootSrtCbv_000) + 376u;
  float4 _55 = asfloat(t1_space1.Load4(_54));
  uint _57 = (uint)(RootSrtCbv_000) + 380u;
  float4 _58 = asfloat(t1_space1.Load4(_57));
  uint _60 = (uint)(RootSrtCbv_000) + 384u;
  float4 _61 = asfloat(t1_space1.Load4(_60));
  uint _63 = (uint)(RootSrtCbv_000) + 388u;
  float4 _64 = asfloat(t1_space1.Load4(_63));
  uint _67 = (uint)(RootSrtCbv_000) + 396u;
  uint _68 = (uint)(RootSrtCbv_000) + 404u;
  float4 _69 = asfloat(t1_space1.Load4(_68));
  uint _71 = (uint)(RootSrtCbv_000) + 408u;
  float4 _72 = asfloat(t1_space1.Load4(_71));
  uint _74 = (uint)(RootSrtCbv_000) + 412u;
  int4 _75 = asint(t1_space1.Load4(_74));
  uint _77 = (uint)(RootSrtCbv_000) + 416u;
  float4 _78 = asfloat(t1_space1.Load4(_77));
  uint _80 = (uint)(RootSrtCbv_000) + 420u;
  float4 _81 = asfloat(t1_space1.Load4(_80));
  uint _83 = (uint)(RootSrtCbv_000) + 424u;
  float4 _84 = asfloat(t1_space1.Load4(_83));
  uint _86 = (uint)(RootSrtCbv_000) + 428u;
  float4 _87 = asfloat(t1_space1.Load4(_86));
  uint _88 = (uint)(RootSrtCbv_000) + 444u;
  float4 _89 = asfloat(t1_space1.Load4(_88));
  uint _90 = (uint)(RootSrtCbv_000) + 448u;
  float4 _91 = asfloat(t1_space1.Load4(_90));
  uint _92 = (uint)(RootSrtCbv_000) + 452u;
  float4 _93 = asfloat(t1_space1.Load4(_92));
  uint _94 = (uint)(RootSrtCbv_000) + 456u;
  int4 _95 = asint(t1_space1.Load4(_94));
  uint _97 = (uint)(RootSrtCbv_000) + 460u;
  float4 _98 = asfloat(t1_space1.Load4(_97));
  uint _100 = (uint)(RootSrtCbv_000) + 464u;
  float4 _101 = asfloat(t1_space1.Load4(_100));
  uint _103 = (uint)(RootSrtCbv_000) + 468u;
  float4 _104 = asfloat(t1_space1.Load4(_103));
  uint _106 = (uint)(RootSrtCbv_000) + 472u;
  float4 _107 = asfloat(t1_space1.Load4(_106));
  uint _112 = (uint)(RootSrtCbv_000) + 488u;
  float4 _113 = asfloat(t1_space1.Load4(_112));
  uint _118 = (uint)(RootSrtCbv_000) + 504u;
  float4 _119 = asfloat(t1_space1.Load4(_118));
  uint _121 = (uint)(RootSrtCbv_000) + 508u;
  float4 _122 = asfloat(t1_space1.Load4(_121));
  uint _124 = (uint)(RootSrtCbv_000) + 512u;
  float4 _125 = asfloat(t1_space1.Load4(_124));
  uint _127 = (uint)(RootSrtCbv_000) + 516u;
  float4 _128 = asfloat(t1_space1.Load4(_127));
  uint _130 = (uint)(RootSrtCbv_000) + 524u;
  float4 _131 = asfloat(t1_space1.Load4(_130));
  uint _133 = (uint)(RootSrtCbv_000) + 528u;
  float4 _134 = asfloat(t1_space1.Load4(_133));
  uint _136 = (uint)(RootSrtCbv_000) + 532u;
  float4 _137 = asfloat(t1_space1.Load4(_136));
  uint _139 = (uint)(RootSrtCbv_000) + 536u;
  float4 _140 = asfloat(t1_space1.Load4(_139));
  uint _142 = (uint)(RootSrtCbv_000) + 540u;
  float4 _143 = asfloat(t1_space1.Load4(_142));
  uint _145 = (uint)(RootSrtCbv_000) + 544u;
  float4 _146 = asfloat(t1_space1.Load4(_145));
  uint _148 = (uint)(RootSrtCbv_000) + 548u;
  float4 _149 = asfloat(t1_space1.Load4(_148));
  uint _152 = (uint)(RootSrtCbv_000) + 556u;
  float4 _153 = asfloat(t1_space1.Load4(_152));
  uint _156 = (uint)(RootSrtCbv_000) + 564u;
  float4 _157 = asfloat(t1_space1.Load4(_156));
  SV_Target_1 = 0.0f;
  int4 _160 = asint(t1_space1.Load4(_13));
  Texture2D<float4> _163 = ResourceDescriptorHeap[(uint)(_160.x)];
  float4 _165 = _163.Sample(s12, float2(TEXCOORD.x, TEXCOORD.y));
  float _168 = _165.x * _101.x;
  float _169 = _165.y * _101.x;
  float _170 = _168 + TEXCOORD.x;
  float _171 = _169 + TEXCOORD.y;
  int4 _172 = asint(t1_space1.Load4(RootSrtCbv_000));
  Texture2D<float4> _175 = ResourceDescriptorHeap[(uint)(_172.x)];
  float4 _177 = _175.Sample(s12, float2(_170, _171));
  if (GhostIsPsychoV()) {
    _177.rgb = GhostApplySceneLensEffects(_177.rgb, float2(_170, _171), TEXCOORD, _175, s12);
  }
  float _181 = max(0.0f, _177.x);
  float _182 = max(0.0f, _177.y);
  float _183 = max(0.0f, _177.z);
  bool _184 = (_95.x == 0);
  float _215;
  float _216;
  float _217;
  float _302;
  float _303;
  float _304;
  float _492;
  float _493;
  float _494;
  if (!_184) {
    uint _186 = (uint)(RootSrtCbv_000) + 436u;
    float _192 = TEXCOORD.x - _87.x;
    float _193 = TEXCOORD.y - _87.y;
    float _194 = _91.x * _192;
    float _195 = _194 * _194;
    float _196 = _193 * _193;
    float _197 = _195 + _196;
    float _198 = sqrt(_197);
    float4 _199 = asfloat(t1_space1.Load4(_186));
    float _201 = _199.x * _198;
    uint _202 = (uint)(RootSrtCbv_000) + 440u;
    float4 _203 = asfloat(t1_space1.Load4(_202));
    float _205 = _201 + _203.x;
    float _206 = saturate(_205);
    float _207 = log2(_206);
    float _208 = _207 * _93.x;
    float _209 = exp2(_208);
    float _210 = _209 * _89.x;
    float _211 = _210 + _181;
    float _212 = _210 + _182;
    float _213 = _210 + _183;
    _215 = _211;
    _216 = _212;
    _217 = _213;
  } else {
    _215 = _181;
    _216 = _182;
    _217 = _183;
  }
  float _218 = dot(float3(_215, _216, _217), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _219 = log2(_218);
  float _220 = _171 * _137.x;
  float _221 = _219 * _140.x;
  float _222 = _221 + _143.x;
  float _223 = saturate(_222);
  int4 _224 = asint(t1_space1.Load4(_17));
  Texture3D<float> _227 = ResourceDescriptorHeap[(uint)(_224.x)];
  float _228 = _227.SampleLevel(s12, float3(_170, _220, _223), 0.0f);
  int4 _230 = asint(t1_space1.Load4(_18));
  Texture2D<float> _233 = ResourceDescriptorHeap[(uint)(_230.x)];
  float _234 = _233.SampleLevel(s12, float2(_170, _220), 0.0f);
  float _236 = _228.x - _234.x;
  float _237 = _236 * _146.x;
  float _238 = _237 + _234.x;
  int4 _239 = asint(t1_space1.Load4(_19));
  ByteAddressBuffer _242 = ResourceDescriptorHeap[(uint)(_239.x)];
  float4 _243 = asfloat(_242.Load4((0 * 4 + 0)));
  float _245 = _238 + _243.x;
  float _246 = _245 * _122.x;
  float _247 = _245 * _119.x;
  float _248 = _243.x * _131.x;
  float _249 = _219 * _134.x;
  float _250 = exp2(_246);
  float _251 = _250 + 1.0f;
  float _252 = log2(_251);
  float _253 = _247 + _252;
  float _254 = _253 * _125.x;
  float _255 = _249 + _128.x;
  float _256 = _255 + _248;
  float _257 = _256 + _254;
  float _258 = exp2(_257);
  float _259 = _257 + _219;
  float _260 = _218 - _215;
  float _261 = _218 - _216;
  float _262 = _218 - _217;
  float _263 = _260 * _98.x;
  float _264 = _261 * _98.x;
  float _265 = _262 * _98.x;
  float _266 = _263 + _215;
  float _267 = _266 * _258;
  float _268 = _264 + _216;
  float _269 = _268 * _258;
  float _270 = _265 + _217;
  float _271 = _270 * _258;
  bool _272 = (_75.x == 0);
  if (!_272) {
    float _274 = TEXCOORD.x - _64.x;
    float _275 = TEXCOORD.y - _64.y;
    float _276 = _274 * _69.x;
    float _277 = _276 * _276;
    float _278 = _275 * _275;
    float _279 = _277 + _278;
    float _280 = sqrt(_279);
    float4 _281 = asfloat(t1_space1.Load4(_67));
    float _283 = _281.x * _280;
    uint _284 = (uint)(RootSrtCbv_000) + 400u;
    float4 _285 = asfloat(t1_space1.Load4(_284));
    float _287 = _283 + _285.x;
    float _288 = saturate(_287);
    float _289 = log2(_288);
    float _290 = _289 * _72.x;
    float _291 = exp2(_290);
    float _292 = _78.x - _55.x;
    float _293 = _291 * _292;
    float _294 = _293 + _55.x;
    float _295 = _81.x - _58.x;
    float _296 = _291 * _295;
    float _297 = _296 + _58.x;
    float _298 = _84.x - _61.x;
    float _299 = _291 * _298;
    float _300 = _299 + _61.x;
    _302 = _294;
    _303 = _297;
    _304 = _300;
  } else {
    _302 = _55.x;
    _303 = _58.x;
    _304 = _61.x;
  }
  float _305 = _259 - _302;
  bool _306 = (_305 < 0.0f);
  float _307 = select(_306, _303, _304);
  float _308 = _307 * _305;
  float _309 = exp2(_308);
  float _310 = _267 * _309;
  float _311 = _269 * _309;
  float _312 = _271 * _309;
  float _313 = TEXCOORD.x + -0.5f;
  float _314 = TEXCOORD.y + -0.5f;
  float _315 = _113.x * _313;
  float _316 = _113.y * _314;
  float _317 = _315 * _315;
  float _318 = _316 * _316;
  float _319 = _317 + _318;
  float _320 = sqrt(_319);
  float _321 = _320 * _113.z;
  float _322 = _321 + _113.w;
  float _323 = saturate(_322);
  float _324 = _323 * _323;
  float _325 = _323 - _324;
  float _326 = _325 * _323;
  float _327 = _326 + _323;
  float _328 = _310 * _327;
  float _329 = _311 * _327;
  float _330 = _312 * _327;
  float _331 = max(0.0f, _328);
  float _332 = max(0.0f, _329);
  float _333 = max(0.0f, _330);
  float _334 = _331 * _21.x;
  float _335 = mad(_332, _21.w, _334);
  float _336 = mad(_333, _27.z, _335);
  float _337 = _331 * _21.y;
  float _338 = mad(_332, _27.x, _337);
  float _339 = mad(_333, _27.w, _338);
  float _340 = _331 * _21.z;
  float _341 = mad(_332, _27.y, _340);
  float _342 = mad(_333, _33.x, _341);
  uint _343 = (uint)(RootSrtCbv_000) + 352u;
  float4 _344 = asfloat(t1_space1.Load4(_343));
  float _346 = _344.x * _336;
  float _347 = _344.x * _339;
  float _348 = _344.x * _342;
  uint _349 = (uint)(RootSrtCbv_000) + 348u;
  float4 _350 = asfloat(t1_space1.Load4(_349));
  float _352 = _346 + _350.x;
  float _353 = _347 + _350.x;
  float _354 = _348 + _350.x;
  float _355 = _352 * _336;
  float _356 = _353 * _339;
  float _357 = _354 * _342;
  float4 _358 = asfloat(t1_space1.Load4(_50));
  float _360 = _355 + _358.x;
  float _361 = _356 + _358.x;
  float _362 = _357 + _358.x;
  float _363 = _360 * _336;
  float _364 = _361 * _339;
  float _365 = _362 * _342;
  uint _366 = (uint)(RootSrtCbv_000) + 364u;
  float4 _367 = asfloat(t1_space1.Load4(_366));
  float _369 = _367.x * _336;
  float _370 = _367.x * _339;
  float _371 = _367.x * _342;
  uint _372 = (uint)(RootSrtCbv_000) + 360u;
  float4 _373 = asfloat(t1_space1.Load4(_372));
  float _375 = _369 + _373.x;
  float _376 = _370 + _373.x;
  float _377 = _371 + _373.x;
  float _378 = _375 * _336;
  float _379 = _376 * _339;
  float _380 = _377 * _342;
  uint _381 = (uint)(RootSrtCbv_000) + 356u;
  float4 _382 = asfloat(t1_space1.Load4(_381));
  float _384 = _378 + _382.x;
  float _385 = _379 + _382.x;
  float _386 = _380 + _382.x;
  float _387 = _384 * _336;
  float _388 = _385 * _339;
  float _389 = _386 * _342;
  float _390 = _387 + 1.0f;
  float _391 = _388 + 1.0f;
  float _392 = _389 + 1.0f;
  float _393 = _363 / _390;
  float _394 = _364 / _391;
  float _395 = _365 / _392;
  if (GhostIsSDRReference()) {
    float3 ghost_sdr_curve = GhostToneMapSDR(float3(_336, _339, _342));
    _393 = ghost_sdr_curve.x;
    _394 = ghost_sdr_curve.y;
    _395 = ghost_sdr_curve.z;
  }
  float _396 = _393 * _36.x;
  float _397 = mad(_394, _36.w, _396);
  float _398 = mad(_395, _42.z, _397);
  float _399 = _393 * _36.y;
  float _400 = mad(_394, _42.x, _399);
  float _401 = mad(_395, _42.w, _400);
  float _402 = _393 * _36.z;
  float _403 = mad(_394, _42.y, _402);
  float _404 = mad(_395, _48.x, _403);
  if (GhostIsPsychoV()) {
    // Feed the linear scene through the native color-space matrices and LUT,
    // but bypass the peak-dependent component-wise rational HDR curve between
    // the matrices. PsychoV is applied after decoding the LUT so the finite
    // cube retains the artistic grade without flattening mapped highlights.
    float3 ghost_pre_lut = float3(_331, _332, _333);
    ghost_pre_lut = GhostApplyPackedColorMatrix(
        ghost_pre_lut, _21, _27, _33);
    ghost_pre_lut = GhostApplyPackedColorMatrix(
        ghost_pre_lut, _36, _42, _48);
    ghost_pre_lut = max(ghost_pre_lut, 0.f.xxx);
    _398 = ghost_pre_lut.x;
    _401 = ghost_pre_lut.y;
    _404 = ghost_pre_lut.z;
  }
  float _405 = sqrt(_398);
  float _406 = sqrt(_401);
  float _407 = sqrt(_404);
  float ghost_lut_scale;
  if (GhostIsPsychoV()) {
    // Linear-light C-infinity shoulder replaces the entire native LUT curve.
    ghost_lut_scale = GhostGetLUTSamplingScale(float3(_398, _401, _404));
  } else if (GhostIsSDRReference()) {
    // Native SDR samples the bounded grade directly, without an HDR shoulder.
    ghost_lut_scale = 1.f;
  } else {
    // Preserve the original gamma-domain shoulder only for Vanilla.
    float _408 = max(_406, _407);
    float _409 = max(_405, _408);
    float _410 = max(_409, 9.999999974752427e-07f);
    float _411 = 1.0f - _410;
    float _412 = _411 * 0.9523810148239136f;
    float _413 = _412 + 0.5f;
    float _414 = saturate(_413);
    float _415 = _414 * _414;
    float _416 = _415 * 0.5249999761581421f;
    bool _417 = (_411 < 0.5249999761581421f);
    float _418 = select(_417, _416, _411);
    float _419 = 1.0f - _418;
    ghost_lut_scale = _419 / _410;
  }
  float _421 = ghost_lut_scale * _405;
  float _422 = ghost_lut_scale * _406;
  float _423 = ghost_lut_scale * _407;
  float _424 = _421 * _107.x;
  float _425 = _422 * _107.x;
  float _426 = _423 * _107.x;
  float _427 = _424 + _107.y;
  float _428 = _425 + _107.y;
  float _429 = _426 + _107.y;
  uint ghost_secondary_lut = 0u;
  float ghost_lut_blend = 0.f;
  int4 _430 = asint(t1_space1.Load4(_15));
  Texture3D<float4> _433 = ResourceDescriptorHeap[(uint)(_430.x)];
  float4 _435 = _433.Sample(s1, float3(_427, _428, _429));
  bool _439 = (_104.x > 0.0f);
  if (_439) {
    float _441 = _107.z * _421;
    float _442 = _107.z * _422;
    float _443 = _107.z * _423;
    float _444 = _441 + _107.w;
    float _445 = _442 + _107.w;
    float _446 = _443 + _107.w;
    int4 _447 = asint(t1_space1.Load4(_16));
    ghost_secondary_lut = (uint)(_447.x);
    Texture3D<float4> _450 = ResourceDescriptorHeap[(uint)(_447.x)];
    float4 _451 = _450.Sample(s1, float3(_444, _445, _446));
    int4 _455 = asint(t1_space1.Load4(_12));
    Texture2D<uint2> _458 = ResourceDescriptorHeap[(uint)(_455.x)];
    uint4 _459 = 0u; _458.GetDimensions(0u, _459.x, _459.y, _459.w);
    float _461 = float((int)((int)(_459.x)));
    float _463 = float((int)((int)(_459.y)));
    float _464 = _461 * _170;
    float _465 = _463 * _171;
    int _466 = int(_464);
    int _467 = int(_465);
    float _468 = _461 + -1.0f;
    int _469 = int(_468);
    float _470 = _463 + -1.0f;
    int _471 = int(_470);
    int _472 = max(_466, 0);
    int _473 = max(_467, 0);
    int _474 = min(_472, _469);
    int _475 = min(_473, _471);
    uint2 _476 = _458.Load(int3(_474, _475, 0));
    int _478 = _476.y & 1;
    bool _479 = (_478 != 0);
    float _480 = select(_479, 0.0f, 1.0f);
    float _481 = _480 * _104.x;
    ghost_lut_blend = _481;
    float _482 = _451.x - _435.x;
    float _483 = _451.y - _435.y;
    float _484 = _451.z - _435.z;
    float _485 = _481 * _482;
    float _486 = _481 * _483;
    float _487 = _481 * _484;
    float _488 = _485 + _435.x;
    float _489 = _486 + _435.y;
    float _490 = _487 + _435.z;
    _492 = _488;
    _493 = _489;
    _494 = _490;
  } else {
    _492 = _435.x;
    _493 = _435.y;
    _494 = _435.z;
  }
  float _495 = _492 / ghost_lut_scale;
  float _496 = _493 / ghost_lut_scale;
  float _497 = _494 / ghost_lut_scale;
  float _498 = _495 * _52.x;
  float _499 = _496 * _52.x;
  float _500 = _497 * _52.x;
  float _501 = _149.x * TEXCOORD.x;
  float _502 = _149.y * TEXCOORD.y;
  int4 _503 = asint(t1_space1.Load4(_14));
  Texture2D<float> _506 = ResourceDescriptorHeap[(uint)(_503.x)];
  float _508 = _506.Sample(s0, float2(_501, _502));
  float _510 = _508.x * 0.0009775171056389809f;
  float _511 = _510 + -0.0004887585528194904f;
  float _512 = _511 + _498;
  float _513 = _511 + _499;
  float _514 = _511 + _500;
  float _515 = dot(float3(_495, _496, _497), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _516 = _515 * _52.x;
  SV_Target_1 = _516;
  float _517 = max(_153.x, _157.x);
  float _518 = max(_153.y, _157.y);
  float _519 = min(_153.x, _157.x);
  float _520 = min(_153.y, _157.y);
  float _521 = max(TEXCOORD.x, _519);
  float _522 = max(TEXCOORD.y, _520);
  float _523 = min(_521, _517);
  float _524 = min(_522, _518);
  bool _525 = !(_523 == TEXCOORD.x);
  bool _526 = !(_524 == TEXCOORD.y);
  bool _527 = _525 || _526;
  if (GhostIsSDRReference()) {
    // Match the SDR shader's LUT output, 8-bit dither amplitude and viewport
    // mask. Keep the encoded SDR domain through upscaling and HUD blending.
    // The HDR-native scene brightness multiplier is deliberately bypassed.
    float3 ghost_sdr = saturate(float3(_492, _493, _494) + (_508.x - 0.5f) / 255.f);
    float ghost_luminance = dot(float3(_492, _493, _494), float3(0.2126f, 0.7152f, 0.0722f));
    SV_Target_1 = select(_527, 0.f, ghost_luminance);
    SV_Target = float4(select(_527, 0.f.xxx, ghost_sdr), SV_Target_1);
    OutputSignature output_signature = {SV_Target, SV_Target_1};
    return output_signature;
  }
  if (GhostIsPsychoV()) {
    GhostSceneGrade ghost_grade = {
        _21, _27, _33, _36, _42, _48,
        uint2((uint)(_430.x), ghost_secondary_lut), _107, ghost_lut_blend};
    const GhostSDRCalibration ghost_calibration = GhostCalibratePsychoV(ghost_grade, s1);
    const float3 ghost_linear_lut = GhostDecodeLUTOutput(
        float3(_495, _496, _497));
    const float3 ghost_psychov = GhostNormalizePsychoVEndpoint(
        GhostToneMapPsychoV30(ghost_linear_lut, ghost_calibration),
        GhostGetPsychoVEndpoint(ghost_calibration));
    float3 ghost_intermediate = GhostRenderIntermediate(ghost_psychov, TEXCOORD);
    ghost_intermediate += _511;
    const float ghost_luminance = dot(
        ghost_intermediate,
        float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
    SV_Target_1 = select(_527, 0.0f, ghost_luminance);
    SV_Target.rgb = select(_527, 0.0f.xxx, ghost_intermediate);
    SV_Target.w = SV_Target_1;
    OutputSignature output_signature = { SV_Target, SV_Target_1 };
    return output_signature;
  }
  float _528 = select(_527, 0.0f, _516);
  SV_Target_1 = _528;
  float _529 = select(_527, 0.0f, _512);
  float _530 = select(_527, 0.0f, _513);
  float _531 = select(_527, 0.0f, _514);
  SV_Target.x = _529;
  SV_Target.y = _530;
  SV_Target.z = _531;
  SV_Target.w = _528;
  OutputSignature output_signature = { SV_Target, SV_Target_1 };
  return output_signature;
}
