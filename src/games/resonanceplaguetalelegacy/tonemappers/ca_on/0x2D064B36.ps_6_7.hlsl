struct GlobalCB_Z__AnchorConstant_Z {
  float4 GlobalCB_Z__AnchorConstant_Z_000[7];
  float4 GlobalCB_Z__AnchorConstant_Z_112;
  float4 GlobalCB_Z__AnchorConstant_Z_128;
  float4 GlobalCB_Z__AnchorConstant_Z_144;
  float4 GlobalCB_Z__AnchorConstant_Z_160;
  float4 GlobalCB_Z__AnchorConstant_Z_176;
  float4 GlobalCB_Z__AnchorConstant_Z_192;
  float4 GlobalCB_Z__AnchorConstant_Z_208;
  float4 GlobalCB_Z__AnchorConstant_Z_224;
  float4 GlobalCB_Z__AnchorConstant_Z_240;
  float4 GlobalCB_Z__AnchorConstant_Z_256[4];
  float4 GlobalCB_Z__AnchorConstant_Z_320;
  float4 GlobalCB_Z__AnchorConstant_Z_336;
};

struct GlobalCB_Z__ProjConstant_Z {
  float4 GlobalCB_Z__ProjConstant_Z_000[4][32];
  float2 GlobalCB_Z__ProjConstant_Z_2048;
  float2 GlobalCB_Z__ProjConstant_Z_2056;
  int4 GlobalCB_Z__ProjConstant_Z_2064;
  float4 GlobalCB_Z__ProjConstant_Z_2080[4];
};

struct GlobalCB_Z__GlobalConstant_Z {
  float4 GlobalCB_Z__GlobalConstant_Z_000[104];
  int GlobalCB_Z__GlobalConstant_Z_1664;
  int3 GlobalCB_Z__GlobalConstant_Z_1668;
  float3 GlobalCB_Z__GlobalConstant_Z_1680;
  int GlobalCB_Z__GlobalConstant_Z_1692;
};

struct GlobalCB_Z__ViewConstant_Z {
  float4 GlobalCB_Z__ViewConstant_Z_000;
  float4 GlobalCB_Z__ViewConstant_Z_016;
  float4 GlobalCB_Z__ViewConstant_Z_032[32];
};

struct GlobalCB_Z__ViewportConstant_Z {
  float2 GlobalCB_Z__ViewportConstant_Z_000;
  float2 GlobalCB_Z__ViewportConstant_Z_008;
  float2 GlobalCB_Z__ViewportConstant_Z_016;
  float2 GlobalCB_Z__ViewportConstant_Z_024;
  float2 GlobalCB_Z__ViewportConstant_Z_032;
  int2 GlobalCB_Z__ViewportConstant_Z_040;
  float GlobalCB_Z__ViewportConstant_Z_048;
  int GlobalCB_Z__ViewportConstant_Z_052;
  float GlobalCB_Z__ViewportConstant_Z_056;
  int GlobalCB_Z__ViewportConstant_Z_060;
  float4 GlobalCB_Z__ViewportConstant_Z_064;
  float3 GlobalCB_Z__ViewportConstant_Z_080;
  float GlobalCB_Z__ViewportConstant_Z_092;
};

struct GlobalCB_Z {
  GlobalCB_Z__GlobalConstant_Z GlobalCB_Z_000;
  GlobalCB_Z__ViewportConstant_Z GlobalCB_Z_1696;
  GlobalCB_Z__AnchorConstant_Z GlobalCB_Z_1792;
  GlobalCB_Z__ViewConstant_Z GlobalCB_Z_2144;
  GlobalCB_Z__ProjConstant_Z GlobalCB_Z_2688;
};

struct PostProcessConstant_Z {
  float4 PostProcessConstant_Z_000[20];
  float4 PostProcessConstant_Z_320[32];
};

struct UserConstant_Z {
  float4 UserConstant_Z_000[84];
};


Texture2DArray<float4> t1 : register(t1);

Texture2DArray<float4> t2 : register(t2);

Texture2D<float4> t0 : register(t0);

Texture3D<float4> t3 : register(t3);

Texture2D<float4> t8 : register(t8);

Texture2D<float4> t12 : register(t12);

Texture2D<float4> t14 : register(t14);

Texture2D<float4> t15 : register(t15);

Texture2D<float4> t16 : register(t16);

Texture2D<float4> t17 : register(t17);

#include "../../common.hlsli"

cbuffer cb1 : register(b1) {
  GlobalCB_Z Global_000 : packoffset(c000.x);
  float4 cb1_raw[302] : packoffset(c0);
};

cbuffer cb0 : register(b0) {
  UserConstant_Z User_000 : packoffset(c000.x);
  float4 cb0_raw[84] : packoffset(c0);
};

cbuffer cb2 : register(b2) {
  PostProcessConstant_Z PostProcess_000 : packoffset(c000.x);
  float4 cb2_raw[52] : packoffset(c0);
};

SamplerState s0 : register(s0);

SamplerState s3 : register(s3);

SamplerState s8 : register(s8);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _29 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _35 = t16.Sample(s0, float2(TEXCOORD.z, TEXCOORD.w));
  float _38 = _35.y * 0.10000000149011612f;
  float _39 = _38 + _29.y;
  float _40 = _35.y * 0.5f;
  float _41 = _40 + _29.z;
  float _42 = exp2(_41);
  float _43 = _42 + -1.0f;
  float _46 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _43;
  float _47 = _46 + 1.0f;
  float _48 = log2(_47);
  float _49 = _29.x + TEXCOORD.z;
  float _50 = _39 + TEXCOORD.w;
  float _51 = _29.x + TEXCOORD.x;
  float _52 = _39 + TEXCOORD.y;
  float _56 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].x);
  float _57 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].y);
  float _58 = _56 + _49;
  float _59 = _57 + _50;
  float _60 = _58 * 2.0f;
  float _61 = _59 * 2.0f;
  float _62 = _60 + -1.0f;
  float _63 = _61 + -1.0f;
  float _67 = _63 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].y);
  float _68 = abs(_62);
  float _69 = abs(_63);
  float _71 = (PostProcess_000.PostProcessConstant_Z_000[19].z) * 2.0f;
  float _72 = _71 + -1.0f;
  float _73 = _68 - _72;
  float _74 = _69 - _72;
  float _75 = saturate(_73);
  float _76 = saturate(_74);
  float _77 = _75 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].x);
  float _78 = _77 * _62;
  float _79 = _67 * _76;
  float _80 = _78 * _78;
  float _81 = _79 * _79;
  float _82 = _80 + _81;
  float _83 = sqrt(_82);
  float _86 = _56 + _51;
  float _87 = _57 + _52;
  float _88 = _86 * 2.0f;
  float _89 = _88 + -1.0f;
  float _90 = _87 * 1.125f;
  float _91 = _90 + -0.5625f;
  float _92 = _89 * _89;
  float _93 = _91 * _91;
  float _94 = _92 + _93;
  float _95 = sqrt(_94);
  float _96 = _95 * 0.8715755343437195f;
  float _97 = _96 * _96;
  float _98 = _97 + -0.15000000596046448f;
  float _99 = _98 * 1.8181819915771484f;
  float _100 = saturate(_99);
  float _101 = _100 * 2.0f;
  float _102 = 3.0f - _101;
  float _103 = (PostProcess_000.PostProcessConstant_Z_000[2].w) * _83;
  float _104 = _100 * _100;
  float _105 = _104 * _103;
  float _106 = _105 * _97;
  float _107 = _106 * _102;
  float _109 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _78;
  float _110 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _79;
  float _111 = _110 + _50;
  float _112 = _49 - _109;
  float _113 = _35.x * 0.010840999893844128f;
  float _114 = _113 + _49;
  float _115 = _114 + _109;
  float _116 = _50 + _113;
  float _117 = _116 - _110;
  float _118 = _48 + 1.0f;
  float _119 = log2(_118);
  float _120 = max(_107, _119);
  float4 _123 = t0.SampleLevel(s0, float2(_115, _111), _120);
  float4 _125 = t0.SampleLevel(s0, float2(_112, _117), _120);
  float4 _127 = t0.SampleLevel(s0, float2(_49, _50), _120);
  float _130 = max(_123.x, 0.0f);
  float _131 = max(_125.y, 0.0f);
  float _132 = max(_127.z, 0.0f);
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
      float3(_130, _131, _132),
      max(_127.rgb, 0.f.xxx),
      float2(_49, _50),
      t0,
      s0,
      _120);
  _130 = renodx_chromatic_aberration_input.x;
  _131 = renodx_chromatic_aberration_input.y;
  _132 = renodx_chromatic_aberration_input.z;
  float4 _134 = t12.SampleLevel(s0, float2(_49, _50), 0.0f);
  float4 _140 = t8.Sample(s8, float2(_51, _52));
  bool _146 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
  float _150 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _140.x;
  float _151 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _140.y;
  float _152 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _140.z;
  float _153 = _150 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _154 = _151 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _155 = _152 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _171;
  float _172;
  float _173;
  float _411;
  float _515;
  float _619;
  float _622;
  float _623;
  float _624;
  float _635;
  float _760;
  float _761;
  float _762;
  float _809;
  float _810;
  float _811;
  float _825;
  float _826;
  float _827;
  if (!_146) {
    float _157 = _153 * _134.x;
    float _158 = _154 * _134.y;
    float _159 = _155 * _134.z;
    _171 = _157;
    _172 = _158;
    _173 = _159;
  } else {
    float _161 = saturate(_153);
    float _162 = saturate(_154);
    float _163 = saturate(_155);
    float _164 = _134.x - _130;
    float _165 = _134.y - _131;
    float _166 = _134.z - _132;
    float _167 = _161 * _164;
    float _168 = _162 * _165;
    float _169 = _163 * _166;
    _171 = _167;
    _172 = _168;
    _173 = _169;
  }
  float _174 = _171 + _130;
  float _175 = _172 + _131;
  float _176 = _173 + _132;
  float4 _180 = t17.Load(int3(0, 0, 0));
  float _186 = _180.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _187 = _186 * _174;
  float _188 = _187 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _189 = _186 * _175;
  float _190 = _189 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _191 = _186 * _176;
  float _192 = _191 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _197 = _49 * 2.0f;
  float _198 = _50 * 2.0f;
  float _199 = _197 + -1.0f;
  float _200 = _198 + -1.0f;
  float _203 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _200;
  float _204 = _199 * _199;
  float _205 = _203 * _203;
  float _206 = _205 + _204;
  float _207 = sqrt(_206);
  float _209 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _207;
  float _211 = _209 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _212 = saturate(_211);
  float _214 = log2(_212);
  float _215 = _214 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _216 = exp2(_215);
  float _217 = _188 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _218 = _190 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _219 = _192 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _220 = _217 - _188;
  float _221 = _218 - _190;
  float _222 = _219 - _192;
  float _223 = _216 * _220;
  float _224 = _216 * _221;
  float _225 = _216 * _222;
  float _226 = _223 + _188;
  float _227 = _224 + _190;
  float _228 = _225 + _192;
  float _231 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _232 = _231 * _226;
  float _233 = _231 * _227;
  float _234 = _231 * _228;
  float _235 = _232 + 1.0f;
  float _236 = _233 + 1.0f;
  float _237 = _234 + 1.0f;
  float _238 = log2(_235);
  float _239 = log2(_236);
  float _240 = log2(_237);
  float _243 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _244 = _243 * _238;
  float _245 = _243 * _239;
  float _246 = _243 * _240;
  float _248 = _244 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _249 = _245 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _250 = _246 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _253 = t3.Sample(s3, float3(_248, _249, _250));
  float _259 = _253.x * 13.450128555297852f;
  float _260 = _253.y * 13.450128555297852f;
  float _261 = _253.z * 13.450128555297852f;
  float _262 = exp2(_259);
  float _263 = exp2(_260);
  float _264 = exp2(_261);
  float _265 = _262 + -1.0f;
  float _266 = _263 + -1.0f;
  float _267 = _264 + -1.0f;
  float _268 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _269 = _268 * _265;
  float _270 = _268 * _266;
  float _271 = _268 * _267;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_232 * _268, _233 * _268, _234 * _268),
      float3(_269, _270, _271),
      1.f.xxx);
  _269 = resonance_scaled_lut_output.x;
  _270 = resonance_scaled_lut_output.y;
  _271 = resonance_scaled_lut_output.z;
  bool _274 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_274) {
    float _276 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _277 = _269 * _276;
    float _278 = _270 * _276;
    float _279 = _271 * _276;
    float _280 = _277 + 1.0f;
    float _281 = _278 + 1.0f;
    float _282 = _279 + 1.0f;
    float _283 = log2(_280);
    float _284 = log2(_281);
    float _285 = log2(_282);
    float _286 = _283 * 0.07434873282909393f;
    float _287 = _284 * 0.07434873282909393f;
    float _288 = _285 * 0.07434873282909393f;
    int _290 = asint((User_000.UserConstant_Z_000[3].y));
    int _291 = _290 & 1;
    bool _292 = (_291 == 0);
    if (!_292) {
      bool _309 = !(_286 <= (User_000.UserConstant_Z_000[4].x));
      if (!_309) {
        float _311 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _312 = _286 / _311;
        float _313 = _312 * (User_000.UserConstant_Z_000[4].y);
        float _314 = _312 * _312;
        float _315 = _314 * _312;
        float _316 = _315 - _312;
        float _317 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _318 = _311 * _311;
        float _319 = _318 * _317;
        float _320 = _319 * _316;
        float _321 = _320 + _313;
        _411 = _321;
      } else {
        bool _323 = !(_286 <= (User_000.UserConstant_Z_000[4].z));
        if (!_323) {
          float _325 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _326 = max(9.999999974752427e-07f, _325);
          float _327 = _286 - (User_000.UserConstant_Z_000[4].x);
          float _328 = _327 / _326;
          float _329 = 1.0f - _328;
          float _330 = _329 * (User_000.UserConstant_Z_000[4].y);
          float _331 = _328 * (User_000.UserConstant_Z_000[4].w);
          float _332 = _330 + _331;
          float _333 = _329 * _329;
          float _334 = _333 * _329;
          float _335 = _334 - _329;
          float _336 = _335 * (User_000.UserConstant_Z_000[10].x);
          float _337 = _328 * _328;
          float _338 = _337 * _328;
          float _339 = _338 - _328;
          float _340 = _339 * (User_000.UserConstant_Z_000[10].y);
          float _341 = _336 + _340;
          float _342 = _326 * _326;
          float _343 = _342 * 0.1666666716337204f;
          float _344 = _343 * _341;
          float _345 = _332 + _344;
          _411 = _345;
        } else {
          bool _347 = !(_286 <= (User_000.UserConstant_Z_000[9].x));
          if (!_347) {
            float _349 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _350 = max(9.999999974752427e-07f, _349);
            float _351 = _286 - (User_000.UserConstant_Z_000[4].z);
            float _352 = _351 / _350;
            float _353 = 1.0f - _352;
            float _354 = _353 * (User_000.UserConstant_Z_000[4].w);
            float _355 = _352 * (User_000.UserConstant_Z_000[9].y);
            float _356 = _354 + _355;
            float _357 = _353 * _353;
            float _358 = _357 * _353;
            float _359 = _358 - _353;
            float _360 = _359 * (User_000.UserConstant_Z_000[10].y);
            float _361 = _352 * _352;
            float _362 = _361 * _352;
            float _363 = _362 - _352;
            float _364 = _363 * (User_000.UserConstant_Z_000[10].z);
            float _365 = _360 + _364;
            float _366 = _350 * _350;
            float _367 = _366 * 0.1666666716337204f;
            float _368 = _367 * _365;
            float _369 = _356 + _368;
            _411 = _369;
          } else {
            bool _371 = !(_286 <= (User_000.UserConstant_Z_000[9].z));
            if (!_371) {
              float _373 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _374 = max(9.999999974752427e-07f, _373);
              float _375 = _286 - (User_000.UserConstant_Z_000[9].x);
              float _376 = _375 / _374;
              float _377 = 1.0f - _376;
              float _378 = _377 * (User_000.UserConstant_Z_000[9].y);
              float _379 = _376 * (User_000.UserConstant_Z_000[9].w);
              float _380 = _378 + _379;
              float _381 = _377 * _377;
              float _382 = _381 * _377;
              float _383 = _382 - _377;
              float _384 = _383 * (User_000.UserConstant_Z_000[10].z);
              float _385 = _376 * _376;
              float _386 = _385 * _376;
              float _387 = _386 - _376;
              float _388 = _387 * (User_000.UserConstant_Z_000[10].w);
              float _389 = _384 + _388;
              float _390 = _374 * _374;
              float _391 = _390 * 0.1666666716337204f;
              float _392 = _391 * _389;
              float _393 = _380 + _392;
              _411 = _393;
            } else {
              float _395 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _396 = _286 - (User_000.UserConstant_Z_000[9].z);
              float _397 = max(9.999999974752427e-07f, _395);
              float _398 = _396 / _397;
              float _399 = 1.0f - _398;
              float _400 = _399 * (User_000.UserConstant_Z_000[9].w);
              float _401 = _400 + _398;
              float _402 = _399 * _399;
              float _403 = _402 * _399;
              float _404 = _403 - _399;
              float _405 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _406 = _395 * _395;
              float _407 = _406 * _405;
              float _408 = _407 * _404;
              float _409 = _401 + _408;
              _411 = _409;
            }
          }
        }
      }
      float _412 = saturate(_411);
      bool _413 = !(_287 <= (User_000.UserConstant_Z_000[4].x));
      if (!_413) {
        float _415 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _416 = _287 / _415;
        float _417 = _416 * (User_000.UserConstant_Z_000[4].y);
        float _418 = _416 * _416;
        float _419 = _418 * _416;
        float _420 = _419 - _416;
        float _421 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _422 = _415 * _415;
        float _423 = _422 * _421;
        float _424 = _423 * _420;
        float _425 = _424 + _417;
        _515 = _425;
      } else {
        bool _427 = !(_287 <= (User_000.UserConstant_Z_000[4].z));
        if (!_427) {
          float _429 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _430 = max(9.999999974752427e-07f, _429);
          float _431 = _287 - (User_000.UserConstant_Z_000[4].x);
          float _432 = _431 / _430;
          float _433 = 1.0f - _432;
          float _434 = _433 * (User_000.UserConstant_Z_000[4].y);
          float _435 = _432 * (User_000.UserConstant_Z_000[4].w);
          float _436 = _434 + _435;
          float _437 = _433 * _433;
          float _438 = _437 * _433;
          float _439 = _438 - _433;
          float _440 = _439 * (User_000.UserConstant_Z_000[10].x);
          float _441 = _432 * _432;
          float _442 = _441 * _432;
          float _443 = _442 - _432;
          float _444 = _443 * (User_000.UserConstant_Z_000[10].y);
          float _445 = _440 + _444;
          float _446 = _430 * _430;
          float _447 = _446 * 0.1666666716337204f;
          float _448 = _447 * _445;
          float _449 = _436 + _448;
          _515 = _449;
        } else {
          bool _451 = !(_287 <= (User_000.UserConstant_Z_000[9].x));
          if (!_451) {
            float _453 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _454 = max(9.999999974752427e-07f, _453);
            float _455 = _287 - (User_000.UserConstant_Z_000[4].z);
            float _456 = _455 / _454;
            float _457 = 1.0f - _456;
            float _458 = _457 * (User_000.UserConstant_Z_000[4].w);
            float _459 = _456 * (User_000.UserConstant_Z_000[9].y);
            float _460 = _458 + _459;
            float _461 = _457 * _457;
            float _462 = _461 * _457;
            float _463 = _462 - _457;
            float _464 = _463 * (User_000.UserConstant_Z_000[10].y);
            float _465 = _456 * _456;
            float _466 = _465 * _456;
            float _467 = _466 - _456;
            float _468 = _467 * (User_000.UserConstant_Z_000[10].z);
            float _469 = _464 + _468;
            float _470 = _454 * _454;
            float _471 = _470 * 0.1666666716337204f;
            float _472 = _471 * _469;
            float _473 = _460 + _472;
            _515 = _473;
          } else {
            bool _475 = !(_287 <= (User_000.UserConstant_Z_000[9].z));
            if (!_475) {
              float _477 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _478 = max(9.999999974752427e-07f, _477);
              float _479 = _287 - (User_000.UserConstant_Z_000[9].x);
              float _480 = _479 / _478;
              float _481 = 1.0f - _480;
              float _482 = _481 * (User_000.UserConstant_Z_000[9].y);
              float _483 = _480 * (User_000.UserConstant_Z_000[9].w);
              float _484 = _482 + _483;
              float _485 = _481 * _481;
              float _486 = _485 * _481;
              float _487 = _486 - _481;
              float _488 = _487 * (User_000.UserConstant_Z_000[10].z);
              float _489 = _480 * _480;
              float _490 = _489 * _480;
              float _491 = _490 - _480;
              float _492 = _491 * (User_000.UserConstant_Z_000[10].w);
              float _493 = _488 + _492;
              float _494 = _478 * _478;
              float _495 = _494 * 0.1666666716337204f;
              float _496 = _495 * _493;
              float _497 = _484 + _496;
              _515 = _497;
            } else {
              float _499 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _500 = _287 - (User_000.UserConstant_Z_000[9].z);
              float _501 = max(9.999999974752427e-07f, _499);
              float _502 = _500 / _501;
              float _503 = 1.0f - _502;
              float _504 = _503 * (User_000.UserConstant_Z_000[9].w);
              float _505 = _504 + _502;
              float _506 = _503 * _503;
              float _507 = _506 * _503;
              float _508 = _507 - _503;
              float _509 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _510 = _499 * _499;
              float _511 = _510 * _509;
              float _512 = _511 * _508;
              float _513 = _505 + _512;
              _515 = _513;
            }
          }
        }
      }
      float _516 = saturate(_515);
      bool _517 = !(_288 <= (User_000.UserConstant_Z_000[4].x));
      if (!_517) {
        float _519 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _520 = _288 / _519;
        float _521 = _520 * (User_000.UserConstant_Z_000[4].y);
        float _522 = _520 * _520;
        float _523 = _522 * _520;
        float _524 = _523 - _520;
        float _525 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _526 = _519 * _519;
        float _527 = _526 * _525;
        float _528 = _527 * _524;
        float _529 = _528 + _521;
        _619 = _529;
      } else {
        bool _531 = !(_288 <= (User_000.UserConstant_Z_000[4].z));
        if (!_531) {
          float _533 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _534 = max(9.999999974752427e-07f, _533);
          float _535 = _288 - (User_000.UserConstant_Z_000[4].x);
          float _536 = _535 / _534;
          float _537 = 1.0f - _536;
          float _538 = _537 * (User_000.UserConstant_Z_000[4].y);
          float _539 = _536 * (User_000.UserConstant_Z_000[4].w);
          float _540 = _538 + _539;
          float _541 = _537 * _537;
          float _542 = _541 * _537;
          float _543 = _542 - _537;
          float _544 = _543 * (User_000.UserConstant_Z_000[10].x);
          float _545 = _536 * _536;
          float _546 = _545 * _536;
          float _547 = _546 - _536;
          float _548 = _547 * (User_000.UserConstant_Z_000[10].y);
          float _549 = _544 + _548;
          float _550 = _534 * _534;
          float _551 = _550 * 0.1666666716337204f;
          float _552 = _551 * _549;
          float _553 = _540 + _552;
          _619 = _553;
        } else {
          bool _555 = !(_288 <= (User_000.UserConstant_Z_000[9].x));
          if (!_555) {
            float _557 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _558 = max(9.999999974752427e-07f, _557);
            float _559 = _288 - (User_000.UserConstant_Z_000[4].z);
            float _560 = _559 / _558;
            float _561 = 1.0f - _560;
            float _562 = _561 * (User_000.UserConstant_Z_000[4].w);
            float _563 = _560 * (User_000.UserConstant_Z_000[9].y);
            float _564 = _562 + _563;
            float _565 = _561 * _561;
            float _566 = _565 * _561;
            float _567 = _566 - _561;
            float _568 = _567 * (User_000.UserConstant_Z_000[10].y);
            float _569 = _560 * _560;
            float _570 = _569 * _560;
            float _571 = _570 - _560;
            float _572 = _571 * (User_000.UserConstant_Z_000[10].z);
            float _573 = _568 + _572;
            float _574 = _558 * _558;
            float _575 = _574 * 0.1666666716337204f;
            float _576 = _575 * _573;
            float _577 = _564 + _576;
            _619 = _577;
          } else {
            bool _579 = !(_288 <= (User_000.UserConstant_Z_000[9].z));
            if (!_579) {
              float _581 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _582 = max(9.999999974752427e-07f, _581);
              float _583 = _288 - (User_000.UserConstant_Z_000[9].x);
              float _584 = _583 / _582;
              float _585 = 1.0f - _584;
              float _586 = _585 * (User_000.UserConstant_Z_000[9].y);
              float _587 = _584 * (User_000.UserConstant_Z_000[9].w);
              float _588 = _586 + _587;
              float _589 = _585 * _585;
              float _590 = _589 * _585;
              float _591 = _590 - _585;
              float _592 = _591 * (User_000.UserConstant_Z_000[10].z);
              float _593 = _584 * _584;
              float _594 = _593 * _584;
              float _595 = _594 - _584;
              float _596 = _595 * (User_000.UserConstant_Z_000[10].w);
              float _597 = _592 + _596;
              float _598 = _582 * _582;
              float _599 = _598 * 0.1666666716337204f;
              float _600 = _599 * _597;
              float _601 = _588 + _600;
              _619 = _601;
            } else {
              float _603 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _604 = _288 - (User_000.UserConstant_Z_000[9].z);
              float _605 = max(9.999999974752427e-07f, _603);
              float _606 = _604 / _605;
              float _607 = 1.0f - _606;
              float _608 = _607 * (User_000.UserConstant_Z_000[9].w);
              float _609 = _608 + _606;
              float _610 = _607 * _607;
              float _611 = _610 * _607;
              float _612 = _611 - _607;
              float _613 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _614 = _603 * _603;
              float _615 = _614 * _613;
              float _616 = _615 * _612;
              float _617 = _609 + _616;
              _619 = _617;
            }
          }
        }
      }
      float _620 = saturate(_619);
      _622 = _412;
      _623 = _516;
      _624 = _620;
    } else {
      _622 = _286;
      _623 = _287;
      _624 = _288;
    }
    int _625 = _290 & 2;
    bool _626 = (_625 == 0);
    if (!_626) {
      float _628 = sqrt(_622);
      float _629 = sqrt(_623);
      float _630 = sqrt(_624);
      float _631 = dot(float3(_628, _629, _630), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _632 = 1.0f - _631;
      float _633 = saturate(_632);
      _635 = _633;
    } else {
      _635 = 1.0f;
    }
    int _636 = _290 & 8;
    bool _637 = (_636 == 0);
    if (_637) {
      int _639 = _290 & 4;
      bool _640 = (_639 == 0);
      if (!_640) {
        int _642 = _290 & 16;
        bool _643 = (_642 == 0);
        if (!_643) {
          float _647 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _648 = _647 + 0.5f;
          bool _649 = (_648 < 0.5f);
          float _650 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _651 = select(_649, (User_000.UserConstant_Z_000[5].x), _650);
          bool _652 = (_623 < _624);
          float _653 = select(_652, _624, _623);
          float _654 = select(_652, _623, _624);
          bool _655 = (_622 < _653);
          float _656 = select(_655, _653, _622);
          float _657 = select(_655, _622, _653);
          float _658 = min(_657, _654);
          float _659 = _656 - _658;
          float _660 = _656 + 1.000000013351432e-10f;
          float _661 = _659 / _660;
          float _663 = _661 - (User_000.UserConstant_Z_000[5].y);
          float _664 = saturate(_663);
          float _665 = max(_664, 9.999999974752427e-07f);
          float _666 = log2(_665);
          float _667 = _666 * _651;
          float _668 = exp2(_667);
          float _669 = 2.0f - _668;
          float _671 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _672 = saturate(_671);
          float _673 = max(_672, _669);
          float _674 = dot(float3(_622, _623, _624), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _675 = _622 - _674;
          float _676 = _623 - _674;
          float _677 = _624 - _674;
          float _678 = _675 * _673;
          float _679 = _676 * _673;
          float _680 = _677 * _673;
          float _681 = _674 - _622;
          float _682 = _681 + _678;
          float _683 = _674 - _623;
          float _684 = _683 + _679;
          float _685 = _674 - _624;
          float _686 = _685 + _680;
          float _687 = _682 * _635;
          float _688 = _684 * _635;
          float _689 = _686 * _635;
          float _690 = _687 + _622;
          float _691 = _688 + _623;
          float _692 = _689 + _624;
          _809 = _690;
          _810 = _691;
          _811 = _692;
        } else {
          bool _694 = (_635 == 0.0f);
          if (!_694) {
            float _698 = abs(User_000.UserConstant_Z_000[5].x);
            float _699 = saturate(_698);
            uint4 _701 = 0u; t15.GetDimensions(0u, _701.x, _701.y, _701.w);
            float _704 = float((uint)_701.y);
            int _705 = _290 & 32;
            bool _706 = (_705 == 0);
            float _707 = _704 + -1.0f;
            if (!_706) {
              float _709 = 1.0f / _707;
              uint _710 = uint(SV_Position.x);
              uint _711 = uint(SV_Position.y);
              int _712 = _710 & 63;
              int _713 = _711 & 63;
              float4 _715 = t2.Load(int4(_712, _713, 0, 0));
              float _718 = _715.x + -0.5f;
              float _719 = _622 * 13.999999046325684f;
              float _720 = _623 * 13.999999046325684f;
              float _721 = _624 * 13.999999046325684f;
              float _722 = saturate(_719);
              float _723 = saturate(_720);
              float _724 = saturate(_721);
              float _725 = _622 + -0.9285714030265808f;
              float _726 = _623 + -0.9285714030265808f;
              float _727 = _624 + -0.9285714030265808f;
              float _728 = _725 * 13.999999046325684f;
              float _729 = _726 * 13.999999046325684f;
              float _730 = _727 * 13.999999046325684f;
              float _731 = saturate(_728);
              float _732 = saturate(_729);
              float _733 = saturate(_730);
              float _734 = 1.0f - _731;
              float _735 = 1.0f - _732;
              float _736 = 1.0f - _733;
              float _737 = min(_722, _734);
              float _738 = min(_723, _735);
              float _739 = min(_724, _736);
              float _740 = _715.y + -0.5f;
              float _741 = _737 * _740;
              float _742 = _738 * _740;
              float _743 = _739 * _740;
              float _744 = _741 + _718;
              float _745 = _742 + _718;
              float _746 = _743 + _718;
              float _747 = _744 * _709;
              float _748 = _745 * _709;
              float _749 = _746 * _709;
              float _750 = _747 + _622;
              float _751 = _748 + _623;
              float _752 = _749 + _624;
              float _753 = saturate(_750);
              float _754 = saturate(_751);
              float _755 = saturate(_752);
              float _756 = saturate(_753);
              float _757 = saturate(_754);
              float _758 = saturate(_755);
              _760 = _756;
              _761 = _757;
              _762 = _758;
            } else {
              _760 = _622;
              _761 = _623;
              _762 = _624;
            }
            float _763 = float((uint)_701.x);
            float _764 = _707 / _763;
            float _765 = _764 * _760;
            float _766 = 0.5f / _763;
            float _767 = _765 + _766;
            float _768 = _707 / _704;
            float _769 = _768 * _761;
            float _770 = 0.5f / _704;
            float _771 = _769 + _770;
            float _772 = _762 * _707;
            float _773 = floor(_772);
            float _774 = frac(_772);
            float _775 = _773 / _704;
            float _776 = _775 + _767;
            float _777 = _773 + 1.0f;
            float _778 = _777 / _704;
            float _779 = _778 + _767;
            float4 _781 = t15.Sample(s0, float2(_776, _771));
            float4 _785 = t15.Sample(s0, float2(_779, _771));
            float _789 = _785.x - _781.x;
            float _790 = _785.y - _781.y;
            float _791 = _785.z - _781.z;
            float _792 = _789 * _774;
            float _793 = _790 * _774;
            float _794 = _791 * _774;
            float _795 = _699 * _635;
            float _796 = _781.x - _622;
            float _797 = _796 + _792;
            float _798 = _781.y - _623;
            float _799 = _798 + _793;
            float _800 = _781.z - _624;
            float _801 = _800 + _794;
            float _802 = _797 * _795;
            float _803 = _799 * _795;
            float _804 = _801 * _795;
            float _805 = _802 + _622;
            float _806 = _803 + _623;
            float _807 = _804 + _624;
            _809 = _805;
            _810 = _806;
            _811 = _807;
          } else {
            _809 = _622;
            _810 = _623;
            _811 = _624;
          }
        }
      } else {
        _809 = _622;
        _810 = _623;
        _811 = _624;
      }
    } else {
      _809 = _635;
      _810 = _635;
      _811 = _635;
    }
    float _812 = _809 * 13.450128555297852f;
    float _813 = _810 * 13.450128555297852f;
    float _814 = _811 * 13.450128555297852f;
    float _815 = exp2(_812);
    float _816 = exp2(_813);
    float _817 = exp2(_814);
    float _818 = _815 + -1.0f;
    float _819 = _816 + -1.0f;
    float _820 = _817 + -1.0f;
    float _821 = _818 * _268;
    float _822 = _819 * _268;
    float _823 = _820 * _268;
    _825 = _821;
    _826 = _822;
    _827 = _823;
  } else {
    _825 = _269;
    _826 = _270;
    _827 = _271;
  }
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _825, (User_000.UserConstant_Z_000[8].y) * _826, (User_000.UserConstant_Z_000[8].z) * _827),
      SV_Position.xy);
  float _834 = resonance_perceptual_film_grain.x;
  float _835 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _836 = log2(_834);
  float _837 = _835 * _836;
  float _838 = exp2(_837);
  float _839 = _838 + -1.0f;
  float _840 = _834 + -1.0f;
  float _841 = _839 / _840;
  bool _842 = !(_834 == 1.0f);
  float _843 = _841 + -1.0f;
  float _844 = _843 / _841;
  float _845 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _846 = _845 / _835;
  float _847 = select(_842, _844, _846);
  float _848 = resonance_perceptual_film_grain.y;
  float _849 = log2(_848);
  float _850 = _849 * _835;
  float _851 = exp2(_850);
  float _852 = _851 + -1.0f;
  float _853 = _848 + -1.0f;
  float _854 = _852 / _853;
  bool _855 = !(_848 == 1.0f);
  float _856 = _854 + -1.0f;
  float _857 = _856 / _854;
  float _858 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _859 = _858 / _835;
  float _860 = select(_855, _857, _859);
  float _861 = resonance_perceptual_film_grain.z;
  float _862 = log2(_861);
  float _863 = _862 * _835;
  float _864 = exp2(_863);
  float _865 = _864 + -1.0f;
  float _866 = _861 + -1.0f;
  float _867 = _865 / _866;
  bool _868 = !(_861 == 1.0f);
  float _869 = _867 + -1.0f;
  float _870 = _869 / _867;
  float _871 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _872 = _871 / _835;
  float _873 = select(_868, _870, _872);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_834, _848, _861),
      float3(_847, _860, _873),
      true);
  float _874 = resonance_post_process_output.x;
  float _875 = resonance_post_process_output.y;
  float _876 = resonance_post_process_output.z;
  float _877 = log2(_874);
  float _878 = log2(_875);
  float _879 = log2(_876);
  float _880 = _877 * 0.4166666567325592f;
  float _881 = _878 * 0.4166666567325592f;
  float _882 = _879 * 0.4166666567325592f;
  float _883 = exp2(_880);
  float _884 = exp2(_881);
  float _885 = exp2(_882);
  float _886 = _883 * 1.0549999475479126f;
  float _887 = _884 * 1.0549999475479126f;
  float _888 = _885 * 1.0549999475479126f;
  float _889 = _886 + -0.054999999701976776f;
  float _890 = _887 + -0.054999999701976776f;
  float _891 = _888 + -0.054999999701976776f;
  float _892 = _874 * 12.920000076293945f;
  float _893 = _875 * 12.920000076293945f;
  float _894 = _876 * 12.920000076293945f;
  bool _895 = (_874 <= 0.0031308000907301903f);
  bool _896 = (_875 <= 0.0031308000907301903f);
  bool _897 = (_876 <= 0.0031308000907301903f);
  float _898 = select(_895, _892, _889);
  float _899 = select(_896, _893, _890);
  float _900 = select(_897, _894, _891);
  int _903 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _904 = uint(SV_Position.x);
  uint _905 = uint(SV_Position.y);
  int _906 = _904 & 63;
  int _907 = _905 & 63;
  float4 _909 = t1.Load(int4(_906, _907, _903, 0));
  float _911 = _909.x + -0.5f;
  float _912 = _911 * 0.003921568859368563f;
  float _913 = _912 + _898;
  float _914 = _912 + _899;
  float _915 = _912 + _900;
  float _916 = saturate(_913);
  float _917 = saturate(_914);
  float _918 = saturate(_915);
  SV_Target.x = _916;
  SV_Target.y = _917;
  SV_Target.z = _918;
  SV_Target.w = _127.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}