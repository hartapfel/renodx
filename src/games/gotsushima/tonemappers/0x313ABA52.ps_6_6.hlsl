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
  uint _12 = (uint)(RootSrtCbv_000) + 64u;
  uint _13 = (uint)(RootSrtCbv_000) + 96u;
  uint _14 = (uint)(RootSrtCbv_000) + 128u;
  uint _15 = (uint)(RootSrtCbv_000) + 160u;
  uint _16 = (uint)(RootSrtCbv_000) + 192u;
  uint _17 = (uint)(RootSrtCbv_000) + 224u;
  uint _18 = (uint)(RootSrtCbv_000) + 256u;
  uint _19 = (uint)(RootSrtCbv_000) + 272u;
  float4 _20 = asfloat(t1_space1.Load4(_19));
  uint _25 = (uint)(RootSrtCbv_000) + 288u;
  float4 _26 = asfloat(t1_space1.Load4(_25));
  uint _31 = (uint)(RootSrtCbv_000) + 304u;
  float4 _32 = asfloat(t1_space1.Load4(_31));
  uint _34 = (uint)(RootSrtCbv_000) + 308u;
  float4 _35 = asfloat(t1_space1.Load4(_34));
  uint _40 = (uint)(RootSrtCbv_000) + 324u;
  float4 _41 = asfloat(t1_space1.Load4(_40));
  uint _46 = (uint)(RootSrtCbv_000) + 340u;
  float4 _47 = asfloat(t1_space1.Load4(_46));
  uint _49 = (uint)(RootSrtCbv_000) + 344u;
  uint _50 = (uint)(RootSrtCbv_000) + 368u;
  float4 _51 = asfloat(t1_space1.Load4(_50));
  uint _53 = (uint)(RootSrtCbv_000) + 376u;
  float4 _54 = asfloat(t1_space1.Load4(_53));
  uint _56 = (uint)(RootSrtCbv_000) + 380u;
  float4 _57 = asfloat(t1_space1.Load4(_56));
  uint _59 = (uint)(RootSrtCbv_000) + 384u;
  float4 _60 = asfloat(t1_space1.Load4(_59));
  uint _62 = (uint)(RootSrtCbv_000) + 388u;
  float4 _63 = asfloat(t1_space1.Load4(_62));
  uint _66 = (uint)(RootSrtCbv_000) + 396u;
  uint _67 = (uint)(RootSrtCbv_000) + 404u;
  float4 _68 = asfloat(t1_space1.Load4(_67));
  uint _70 = (uint)(RootSrtCbv_000) + 408u;
  float4 _71 = asfloat(t1_space1.Load4(_70));
  uint _73 = (uint)(RootSrtCbv_000) + 412u;
  int4 _74 = asint(t1_space1.Load4(_73));
  uint _76 = (uint)(RootSrtCbv_000) + 416u;
  float4 _77 = asfloat(t1_space1.Load4(_76));
  uint _79 = (uint)(RootSrtCbv_000) + 420u;
  float4 _80 = asfloat(t1_space1.Load4(_79));
  uint _82 = (uint)(RootSrtCbv_000) + 424u;
  float4 _83 = asfloat(t1_space1.Load4(_82));
  uint _85 = (uint)(RootSrtCbv_000) + 428u;
  float4 _86 = asfloat(t1_space1.Load4(_85));
  uint _87 = (uint)(RootSrtCbv_000) + 444u;
  float4 _88 = asfloat(t1_space1.Load4(_87));
  uint _89 = (uint)(RootSrtCbv_000) + 448u;
  float4 _90 = asfloat(t1_space1.Load4(_89));
  uint _91 = (uint)(RootSrtCbv_000) + 452u;
  float4 _92 = asfloat(t1_space1.Load4(_91));
  uint _93 = (uint)(RootSrtCbv_000) + 456u;
  int4 _94 = asint(t1_space1.Load4(_93));
  uint _96 = (uint)(RootSrtCbv_000) + 460u;
  float4 _97 = asfloat(t1_space1.Load4(_96));
  uint _99 = (uint)(RootSrtCbv_000) + 464u;
  float4 _100 = asfloat(t1_space1.Load4(_99));
  uint _102 = (uint)(RootSrtCbv_000) + 468u;
  float4 _103 = asfloat(t1_space1.Load4(_102));
  uint _105 = (uint)(RootSrtCbv_000) + 472u;
  float4 _106 = asfloat(t1_space1.Load4(_105));
  uint _111 = (uint)(RootSrtCbv_000) + 488u;
  float4 _112 = asfloat(t1_space1.Load4(_111));
  uint _117 = (uint)(RootSrtCbv_000) + 504u;
  float4 _118 = asfloat(t1_space1.Load4(_117));
  uint _120 = (uint)(RootSrtCbv_000) + 508u;
  float4 _121 = asfloat(t1_space1.Load4(_120));
  uint _123 = (uint)(RootSrtCbv_000) + 512u;
  float4 _124 = asfloat(t1_space1.Load4(_123));
  uint _126 = (uint)(RootSrtCbv_000) + 516u;
  float4 _127 = asfloat(t1_space1.Load4(_126));
  uint _129 = (uint)(RootSrtCbv_000) + 524u;
  float4 _130 = asfloat(t1_space1.Load4(_129));
  uint _132 = (uint)(RootSrtCbv_000) + 528u;
  float4 _133 = asfloat(t1_space1.Load4(_132));
  uint _135 = (uint)(RootSrtCbv_000) + 532u;
  float4 _136 = asfloat(t1_space1.Load4(_135));
  uint _138 = (uint)(RootSrtCbv_000) + 536u;
  float4 _139 = asfloat(t1_space1.Load4(_138));
  uint _141 = (uint)(RootSrtCbv_000) + 540u;
  float4 _142 = asfloat(t1_space1.Load4(_141));
  uint _144 = (uint)(RootSrtCbv_000) + 544u;
  float4 _145 = asfloat(t1_space1.Load4(_144));
  uint _147 = (uint)(RootSrtCbv_000) + 548u;
  float4 _148 = asfloat(t1_space1.Load4(_147));
  uint _151 = (uint)(RootSrtCbv_000) + 556u;
  float4 _152 = asfloat(t1_space1.Load4(_151));
  uint _155 = (uint)(RootSrtCbv_000) + 564u;
  float4 _156 = asfloat(t1_space1.Load4(_155));
  SV_Target_1 = 0.0f;
  int4 _159 = asint(t1_space1.Load4(_12));
  Texture2D<float4> _162 = ResourceDescriptorHeap[(uint)(_159.x)];
  float4 _164 = _162.Sample(s12, float2(TEXCOORD.x, TEXCOORD.y));
  float _167 = _164.x * _100.x;
  float _168 = _164.y * _100.x;
  float _169 = _167 + TEXCOORD.x;
  float _170 = _168 + TEXCOORD.y;
  int4 _171 = asint(t1_space1.Load4(RootSrtCbv_000));
  Texture2D<float4> _174 = ResourceDescriptorHeap[(uint)(_171.x)];
  float4 _176 = _174.Sample(s12, float2(_169, _170));
  if (GhostIsPsychoV()) {
    _176.rgb = GhostApplyRCAS(_176.rgb, float2(_169, _170), _174, s12);
  }
  float _180 = max(0.0f, _176.x);
  float _181 = max(0.0f, _176.y);
  float _182 = max(0.0f, _176.z);
  bool _183 = (_94.x == 0);
  float _214;
  float _215;
  float _216;
  float _301;
  float _302;
  float _303;
  float _464;
  float _465;
  float _466;
  if (!_183) {
    uint _185 = (uint)(RootSrtCbv_000) + 436u;
    float _191 = TEXCOORD.x - _86.x;
    float _192 = TEXCOORD.y - _86.y;
    float _193 = _90.x * _191;
    float _194 = _193 * _193;
    float _195 = _192 * _192;
    float _196 = _194 + _195;
    float _197 = sqrt(_196);
    float4 _198 = asfloat(t1_space1.Load4(_185));
    float _200 = _198.x * _197;
    uint _201 = (uint)(RootSrtCbv_000) + 440u;
    float4 _202 = asfloat(t1_space1.Load4(_201));
    float _204 = _200 + _202.x;
    float _205 = saturate(_204);
    float _206 = log2(_205);
    float _207 = _206 * _92.x;
    float _208 = exp2(_207);
    float _209 = _208 * _88.x;
    float _210 = _209 + _180;
    float _211 = _209 + _181;
    float _212 = _209 + _182;
    _214 = _210;
    _215 = _211;
    _216 = _212;
  } else {
    _214 = _180;
    _215 = _181;
    _216 = _182;
  }
  float _217 = dot(float3(_214, _215, _216), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _218 = log2(_217);
  float _219 = _170 * _136.x;
  float _220 = _218 * _139.x;
  float _221 = _220 + _142.x;
  float _222 = saturate(_221);
  int4 _223 = asint(t1_space1.Load4(_16));
  Texture3D<float> _226 = ResourceDescriptorHeap[(uint)(_223.x)];
  float _227 = _226.SampleLevel(s12, float3(_169, _219, _222), 0.0f);
  int4 _229 = asint(t1_space1.Load4(_17));
  Texture2D<float> _232 = ResourceDescriptorHeap[(uint)(_229.x)];
  float _233 = _232.SampleLevel(s12, float2(_169, _219), 0.0f);
  float _235 = _227.x - _233.x;
  float _236 = _235 * _145.x;
  float _237 = _236 + _233.x;
  int4 _238 = asint(t1_space1.Load4(_18));
  ByteAddressBuffer _241 = ResourceDescriptorHeap[(uint)(_238.x)];
  float4 _242 = asfloat(_241.Load4((0 * 4 + 0)));
  float _244 = _237 + _242.x;
  float _245 = _244 * _121.x;
  float _246 = _244 * _118.x;
  float _247 = _242.x * _130.x;
  float _248 = _218 * _133.x;
  float _249 = exp2(_245);
  float _250 = _249 + 1.0f;
  float _251 = log2(_250);
  float _252 = _246 + _251;
  float _253 = _252 * _124.x;
  float _254 = _248 + _127.x;
  float _255 = _254 + _247;
  float _256 = _255 + _253;
  float _257 = exp2(_256);
  float _258 = _256 + _218;
  float _259 = _217 - _214;
  float _260 = _217 - _215;
  float _261 = _217 - _216;
  float _262 = _259 * _97.x;
  float _263 = _260 * _97.x;
  float _264 = _261 * _97.x;
  float _265 = _262 + _214;
  float _266 = _265 * _257;
  float _267 = _263 + _215;
  float _268 = _267 * _257;
  float _269 = _264 + _216;
  float _270 = _269 * _257;
  bool _271 = (_74.x == 0);
  if (!_271) {
    float _273 = TEXCOORD.x - _63.x;
    float _274 = TEXCOORD.y - _63.y;
    float _275 = _273 * _68.x;
    float _276 = _275 * _275;
    float _277 = _274 * _274;
    float _278 = _276 + _277;
    float _279 = sqrt(_278);
    float4 _280 = asfloat(t1_space1.Load4(_66));
    float _282 = _280.x * _279;
    uint _283 = (uint)(RootSrtCbv_000) + 400u;
    float4 _284 = asfloat(t1_space1.Load4(_283));
    float _286 = _282 + _284.x;
    float _287 = saturate(_286);
    float _288 = log2(_287);
    float _289 = _288 * _71.x;
    float _290 = exp2(_289);
    float _291 = _77.x - _54.x;
    float _292 = _290 * _291;
    float _293 = _292 + _54.x;
    float _294 = _80.x - _57.x;
    float _295 = _290 * _294;
    float _296 = _295 + _57.x;
    float _297 = _83.x - _60.x;
    float _298 = _290 * _297;
    float _299 = _298 + _60.x;
    _301 = _293;
    _302 = _296;
    _303 = _299;
  } else {
    _301 = _54.x;
    _302 = _57.x;
    _303 = _60.x;
  }
  float _304 = _258 - _301;
  bool _305 = (_304 < 0.0f);
  float _306 = select(_305, _302, _303);
  float _307 = _306 * _304;
  float _308 = exp2(_307);
  float _309 = _266 * _308;
  float _310 = _268 * _308;
  float _311 = _270 * _308;
  float _312 = TEXCOORD.x + -0.5f;
  float _313 = TEXCOORD.y + -0.5f;
  float _314 = _112.x * _312;
  float _315 = _112.y * _313;
  float _316 = _314 * _314;
  float _317 = _315 * _315;
  float _318 = _316 + _317;
  float _319 = sqrt(_318);
  float _320 = _319 * _112.z;
  float _321 = _320 + _112.w;
  float _322 = saturate(_321);
  float _323 = _322 * _322;
  float _324 = _322 - _323;
  float _325 = _324 * _322;
  float _326 = _325 + _322;
  float _327 = _309 * _326;
  float _328 = _310 * _326;
  float _329 = _311 * _326;
  float _330 = max(0.0f, _327);
  float _331 = max(0.0f, _328);
  float _332 = max(0.0f, _329);
  float _333 = _330 * _20.x;
  float _334 = mad(_331, _20.w, _333);
  float _335 = mad(_332, _26.z, _334);
  float _336 = _330 * _20.y;
  float _337 = mad(_331, _26.x, _336);
  float _338 = mad(_332, _26.w, _337);
  float _339 = _330 * _20.z;
  float _340 = mad(_331, _26.y, _339);
  float _341 = mad(_332, _32.x, _340);
  uint _342 = (uint)(RootSrtCbv_000) + 352u;
  float4 _343 = asfloat(t1_space1.Load4(_342));
  float _345 = _343.x * _335;
  float _346 = _343.x * _338;
  float _347 = _343.x * _341;
  uint _348 = (uint)(RootSrtCbv_000) + 348u;
  float4 _349 = asfloat(t1_space1.Load4(_348));
  float _351 = _345 + _349.x;
  float _352 = _346 + _349.x;
  float _353 = _347 + _349.x;
  float _354 = _351 * _335;
  float _355 = _352 * _338;
  float _356 = _353 * _341;
  float4 _357 = asfloat(t1_space1.Load4(_49));
  float _359 = _354 + _357.x;
  float _360 = _355 + _357.x;
  float _361 = _356 + _357.x;
  float _362 = _359 * _335;
  float _363 = _360 * _338;
  float _364 = _361 * _341;
  uint _365 = (uint)(RootSrtCbv_000) + 364u;
  float4 _366 = asfloat(t1_space1.Load4(_365));
  float _368 = _366.x * _335;
  float _369 = _366.x * _338;
  float _370 = _366.x * _341;
  uint _371 = (uint)(RootSrtCbv_000) + 360u;
  float4 _372 = asfloat(t1_space1.Load4(_371));
  float _374 = _368 + _372.x;
  float _375 = _369 + _372.x;
  float _376 = _370 + _372.x;
  float _377 = _374 * _335;
  float _378 = _375 * _338;
  float _379 = _376 * _341;
  uint _380 = (uint)(RootSrtCbv_000) + 356u;
  float4 _381 = asfloat(t1_space1.Load4(_380));
  float _383 = _377 + _381.x;
  float _384 = _378 + _381.x;
  float _385 = _379 + _381.x;
  float _386 = _383 * _335;
  float _387 = _384 * _338;
  float _388 = _385 * _341;
  float _389 = _386 + 1.0f;
  float _390 = _387 + 1.0f;
  float _391 = _388 + 1.0f;
  float _392 = _362 / _389;
  float _393 = _363 / _390;
  float _394 = _364 / _391;
  if (GhostIsSDRReference()) {
    float3 ghost_sdr_curve = GhostToneMapSDR(float3(_335, _338, _341));
    _392 = ghost_sdr_curve.x;
    _393 = ghost_sdr_curve.y;
    _394 = ghost_sdr_curve.z;
  }
  float _395 = _392 * _35.x;
  float _396 = mad(_393, _35.w, _395);
  float _397 = mad(_394, _41.z, _396);
  float _398 = _392 * _35.y;
  float _399 = mad(_393, _41.x, _398);
  float _400 = mad(_394, _41.w, _399);
  float _401 = _392 * _35.z;
  float _402 = mad(_393, _41.y, _401);
  float _403 = mad(_394, _47.x, _402);
  if (GhostIsPsychoV()) {
    // Feed the linear scene through the native color-space matrices and LUT,
    // but bypass the peak-dependent component-wise rational HDR curve between
    // the matrices. PsychoV is applied after decoding the LUT so the finite
    // cube retains the artistic grade without flattening mapped highlights.
    float3 ghost_pre_lut = float3(_330, _331, _332);
    ghost_pre_lut = GhostApplyPackedColorMatrix(
        ghost_pre_lut, _20, _26, _32);
    ghost_pre_lut = GhostApplyPackedColorMatrix(
        ghost_pre_lut, _35, _41, _47);
    ghost_pre_lut = max(ghost_pre_lut, 0.f.xxx);
    _397 = ghost_pre_lut.x;
    _400 = ghost_pre_lut.y;
    _403 = ghost_pre_lut.z;
  }
  float _404 = sqrt(_397);
  float _405 = sqrt(_400);
  float _406 = sqrt(_403);
  float ghost_lut_scale;
  if (GhostIsPsychoV()) {
    // Linear-light C-infinity shoulder replaces the entire native LUT curve.
    ghost_lut_scale = GhostGetLUTSamplingScale(float3(_397, _400, _403));
  } else if (GhostIsSDRReference()) {
    // Native SDR samples the bounded grade directly, without an HDR shoulder.
    ghost_lut_scale = 1.f;
  } else {
    // Preserve the original gamma-domain shoulder only for Vanilla.
    float _407 = max(_405, _406);
    float _408 = max(_404, _407);
    float _409 = max(_408, 9.999999974752427e-07f);
    float _410 = 1.0f - _409;
    float _411 = _410 * 0.9523810148239136f;
    float _412 = _411 + 0.5f;
    float _413 = saturate(_412);
    float _414 = _413 * _413;
    float _415 = _414 * 0.5249999761581421f;
    bool _416 = (_410 < 0.5249999761581421f);
    float _417 = select(_416, _415, _410);
    float _418 = 1.0f - _417;
    ghost_lut_scale = _418 / _409;
  }
  float _420 = ghost_lut_scale * _404;
  float _421 = ghost_lut_scale * _405;
  float _422 = ghost_lut_scale * _406;
  float _423 = _420 * _106.x;
  float _424 = _421 * _106.x;
  float _425 = _422 * _106.x;
  float _426 = _423 + _106.y;
  float _427 = _424 + _106.y;
  float _428 = _425 + _106.y;
  uint ghost_secondary_lut = 0u;
  float ghost_lut_blend = 0.f;
  int4 _429 = asint(t1_space1.Load4(_14));
  Texture3D<float4> _432 = ResourceDescriptorHeap[(uint)(_429.x)];
  float4 _434 = _432.Sample(s1, float3(_426, _427, _428));
  bool _438 = (_103.x > 0.0f);
  if (_438) {
    float _440 = _106.z * _420;
    float _441 = _106.z * _421;
    float _442 = _106.z * _422;
    float _443 = _440 + _106.w;
    float _444 = _441 + _106.w;
    float _445 = _442 + _106.w;
    int4 _446 = asint(t1_space1.Load4(_15));
    ghost_secondary_lut = (uint)(_446.x);
    Texture3D<float4> _449 = ResourceDescriptorHeap[(uint)(_446.x)];
    float4 _450 = _449.Sample(s1, float3(_443, _444, _445));
    ghost_lut_blend = _103.x;
    float _454 = _450.x - _434.x;
    float _455 = _450.y - _434.y;
    float _456 = _450.z - _434.z;
    float _457 = _454 * _103.x;
    float _458 = _455 * _103.x;
    float _459 = _456 * _103.x;
    float _460 = _457 + _434.x;
    float _461 = _458 + _434.y;
    float _462 = _459 + _434.z;
    _464 = _460;
    _465 = _461;
    _466 = _462;
  } else {
    _464 = _434.x;
    _465 = _434.y;
    _466 = _434.z;
  }
  float _467 = _464 / ghost_lut_scale;
  float _468 = _465 / ghost_lut_scale;
  float _469 = _466 / ghost_lut_scale;
  float _470 = _467 * _51.x;
  float _471 = _468 * _51.x;
  float _472 = _469 * _51.x;
  float _473 = _148.x * TEXCOORD.x;
  float _474 = _148.y * TEXCOORD.y;
  int4 _475 = asint(t1_space1.Load4(_13));
  Texture2D<float> _478 = ResourceDescriptorHeap[(uint)(_475.x)];
  float _480 = _478.Sample(s0, float2(_473, _474));
  float _482 = _480.x * 0.0009775171056389809f;
  float _483 = _482 + -0.0004887585528194904f;
  float _484 = _483 + _470;
  float _485 = _483 + _471;
  float _486 = _483 + _472;
  float _487 = dot(float3(_467, _468, _469), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _488 = _487 * _51.x;
  SV_Target_1 = _488;
  float _489 = max(_152.x, _156.x);
  float _490 = max(_152.y, _156.y);
  float _491 = min(_152.x, _156.x);
  float _492 = min(_152.y, _156.y);
  float _493 = max(TEXCOORD.x, _491);
  float _494 = max(TEXCOORD.y, _492);
  float _495 = min(_493, _489);
  float _496 = min(_494, _490);
  bool _497 = !(_495 == TEXCOORD.x);
  bool _498 = !(_496 == TEXCOORD.y);
  bool _499 = _497 || _498;
  if (GhostIsSDRReference()) {
    // Match the SDR shader's LUT output, 8-bit dither amplitude and viewport
    // mask. Keep the encoded SDR domain through upscaling and HUD blending.
    // The HDR-native scene brightness multiplier is deliberately bypassed.
    float3 ghost_sdr = saturate(float3(_464, _465, _466) + (_480.x - 0.5f) / 255.f);
    float ghost_luminance = dot(float3(_464, _465, _466), float3(0.2126f, 0.7152f, 0.0722f));
    SV_Target_1 = select(_499, 0.f, ghost_luminance);
    SV_Target = float4(select(_499, 0.f.xxx, ghost_sdr), SV_Target_1);
    OutputSignature output_signature = {SV_Target, SV_Target_1};
    return output_signature;
  }
  if (GhostIsPsychoV()) {
    GhostSceneGrade ghost_grade = {
        _20, _26, _32, _35, _41, _47,
        uint2((uint)(_429.x), ghost_secondary_lut), _106, ghost_lut_blend};
    const GhostSDRCalibration ghost_calibration = GhostCalibratePsychoV(ghost_grade, s1);
    const float3 ghost_linear_lut = GhostDecodeLUTOutput(
        float3(_467, _468, _469));
    const float3 ghost_psychov = GhostNormalizePsychoVEndpoint(
        GhostToneMapPsychoV30(ghost_linear_lut, ghost_calibration),
        GhostGetPsychoVEndpoint(ghost_calibration));
    float3 ghost_intermediate = GhostRenderIntermediate(ghost_psychov, TEXCOORD);
    ghost_intermediate += _483;
    const float ghost_luminance = dot(
        ghost_intermediate,
        float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
    SV_Target_1 = select(_499, 0.0f, ghost_luminance);
    SV_Target.rgb = select(_499, 0.0f.xxx, ghost_intermediate);
    SV_Target.w = SV_Target_1;
    OutputSignature output_signature = { SV_Target, SV_Target_1 };
    return output_signature;
  }
  float _500 = select(_499, 0.0f, _488);
  SV_Target_1 = _500;
  float _501 = select(_499, 0.0f, _484);
  float _502 = select(_499, 0.0f, _485);
  float _503 = select(_499, 0.0f, _486);
  SV_Target.x = _501;
  SV_Target.y = _502;
  SV_Target.z = _503;
  SV_Target.w = _500;
  OutputSignature output_signature = { SV_Target, SV_Target_1 };
  return output_signature;
}
