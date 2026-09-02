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

Texture2D<float4> t9 : register(t9);

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

SamplerState s1 : register(s1);

SamplerState s3 : register(s3);

SamplerState s8 : register(s8);

SamplerState s9 : register(s9);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _32 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _38 = t16.Sample(s0, float2(TEXCOORD.z, TEXCOORD.w));
  float _41 = _38.y * 0.10000000149011612f;
  float _42 = _41 + _32.y;
  float _43 = _38.y * 0.5f;
  float _44 = _43 + _32.z;
  float _45 = exp2(_44);
  float _46 = _45 + -1.0f;
  float _49 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _46;
  float _50 = _49 + 1.0f;
  float _51 = log2(_50);
  float _52 = _32.x + TEXCOORD.z;
  float _53 = _42 + TEXCOORD.w;
  float _54 = _32.x + TEXCOORD.x;
  float _55 = _42 + TEXCOORD.y;
  float _59 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].x);
  float _60 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].y);
  float _61 = _59 + _52;
  float _62 = _60 + _53;
  float _63 = _61 * 2.0f;
  float _64 = _62 * 2.0f;
  float _65 = _63 + -1.0f;
  float _66 = _64 + -1.0f;
  float _70 = _66 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].y);
  float _71 = abs(_65);
  float _72 = abs(_66);
  float _74 = (PostProcess_000.PostProcessConstant_Z_000[19].z) * 2.0f;
  float _75 = _74 + -1.0f;
  float _76 = _71 - _75;
  float _77 = _72 - _75;
  float _78 = saturate(_76);
  float _79 = saturate(_77);
  float _80 = _78 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].x);
  float _81 = _80 * _65;
  float _82 = _70 * _79;
  float _83 = _81 * _81;
  float _84 = _82 * _82;
  float _85 = _83 + _84;
  float _86 = sqrt(_85);
  float _89 = _59 + _54;
  float _90 = _60 + _55;
  float _91 = _89 * 2.0f;
  float _92 = _91 + -1.0f;
  float _93 = _90 * 1.125f;
  float _94 = _93 + -0.5625f;
  float _95 = _92 * _92;
  float _96 = _94 * _94;
  float _97 = _95 + _96;
  float _98 = sqrt(_97);
  float _99 = _98 * 0.8715755343437195f;
  float _100 = _99 * _99;
  float _101 = _100 + -0.15000000596046448f;
  float _102 = _101 * 1.8181819915771484f;
  float _103 = saturate(_102);
  float _104 = _103 * 2.0f;
  float _105 = 3.0f - _104;
  float _106 = (PostProcess_000.PostProcessConstant_Z_000[2].w) * _86;
  float _107 = _103 * _103;
  float _108 = _107 * _106;
  float _109 = _108 * _100;
  float _110 = _109 * _105;
  float _112 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _81;
  float _113 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _82;
  float _114 = _113 + _53;
  float _115 = _52 - _112;
  float _116 = _38.x * 0.010840999893844128f;
  float _117 = _116 + _52;
  float _118 = _117 + _112;
  float _119 = _53 + _116;
  float _120 = _119 - _113;
  float _121 = _51 + 1.0f;
  float _122 = log2(_121);
  float _123 = max(_110, _122);
  float4 _126 = t0.SampleLevel(s0, float2(_118, _114), _123);
  float4 _128 = t0.SampleLevel(s0, float2(_115, _120), _123);
  float4 _130 = t0.SampleLevel(s0, float2(_52, _53), _123);
  float _133 = max(_126.x, 0.0f);
  float _134 = max(_128.y, 0.0f);
  float _135 = max(_130.z, 0.0f);
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
      float3(_133, _134, _135),
      max(_130.rgb, 0.f.xxx),
      float2(_52, _53),
      t0,
      s0,
      _123);
  _133 = renodx_chromatic_aberration_input.x;
  _134 = renodx_chromatic_aberration_input.y;
  _135 = renodx_chromatic_aberration_input.z;
  float4 _137 = t12.SampleLevel(s0, float2(_52, _53), 0.0f);
  float4 _143 = t8.Sample(s8, float2(_54, _55));
  bool _149 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
  float _153 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _143.x;
  float _154 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _143.y;
  float _155 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _143.z;
  float _156 = _153 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _157 = _154 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _158 = _155 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _174;
  float _175;
  float _176;
  float _414;
  float _518;
  float _622;
  float _625;
  float _626;
  float _627;
  float _638;
  float _763;
  float _764;
  float _765;
  float _812;
  float _813;
  float _814;
  float _828;
  float _829;
  float _830;
  float _886;
  if (!_149) {
    float _160 = _156 * _137.x;
    float _161 = _157 * _137.y;
    float _162 = _158 * _137.z;
    _174 = _160;
    _175 = _161;
    _176 = _162;
  } else {
    float _164 = saturate(_156);
    float _165 = saturate(_157);
    float _166 = saturate(_158);
    float _167 = _137.x - _133;
    float _168 = _137.y - _134;
    float _169 = _137.z - _135;
    float _170 = _164 * _167;
    float _171 = _165 * _168;
    float _172 = _166 * _169;
    _174 = _170;
    _175 = _171;
    _176 = _172;
  }
  float _177 = _174 + _133;
  float _178 = _175 + _134;
  float _179 = _176 + _135;
  float4 _183 = t17.Load(int3(0, 0, 0));
  float _189 = _183.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _190 = _189 * _177;
  float _191 = _190 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _192 = _189 * _178;
  float _193 = _192 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _194 = _189 * _179;
  float _195 = _194 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _200 = _52 * 2.0f;
  float _201 = _53 * 2.0f;
  float _202 = _200 + -1.0f;
  float _203 = _201 + -1.0f;
  float _206 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _203;
  float _207 = _202 * _202;
  float _208 = _206 * _206;
  float _209 = _208 + _207;
  float _210 = sqrt(_209);
  float _212 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _210;
  float _214 = _212 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _215 = saturate(_214);
  float _217 = log2(_215);
  float _218 = _217 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _219 = ResonanceScaleVignetteMask(exp2(_218));
  float _220 = _191 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _221 = _193 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _222 = _195 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _223 = _220 - _191;
  float _224 = _221 - _193;
  float _225 = _222 - _195;
  float _226 = _219 * _223;
  float _227 = _219 * _224;
  float _228 = _219 * _225;
  float _229 = _226 + _191;
  float _230 = _227 + _193;
  float _231 = _228 + _195;
  float _234 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _235 = _234 * _229;
  float _236 = _234 * _230;
  float _237 = _234 * _231;
  float _238 = _235 + 1.0f;
  float _239 = _236 + 1.0f;
  float _240 = _237 + 1.0f;
  float _241 = log2(_238);
  float _242 = log2(_239);
  float _243 = log2(_240);
  float _246 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _247 = _246 * _241;
  float _248 = _246 * _242;
  float _249 = _246 * _243;
  float _251 = _247 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _252 = _248 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _253 = _249 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _256 = t3.Sample(s3, float3(_251, _252, _253));
  float _262 = _256.x * 13.450128555297852f;
  float _263 = _256.y * 13.450128555297852f;
  float _264 = _256.z * 13.450128555297852f;
  float _265 = exp2(_262);
  float _266 = exp2(_263);
  float _267 = exp2(_264);
  float _268 = _265 + -1.0f;
  float _269 = _266 + -1.0f;
  float _270 = _267 + -1.0f;
  float _271 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _272 = _271 * _268;
  float _273 = _271 * _269;
  float _274 = _271 * _270;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_235 * _271, _236 * _271, _237 * _271),
      float3(_272, _273, _274),
      1.f.xxx);
  _272 = resonance_scaled_lut_output.x;
  _273 = resonance_scaled_lut_output.y;
  _274 = resonance_scaled_lut_output.z;
  bool _277 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_277) {
    float _279 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _280 = _272 * _279;
    float _281 = _273 * _279;
    float _282 = _274 * _279;
    float _283 = _280 + 1.0f;
    float _284 = _281 + 1.0f;
    float _285 = _282 + 1.0f;
    float _286 = log2(_283);
    float _287 = log2(_284);
    float _288 = log2(_285);
    float _289 = _286 * 0.07434873282909393f;
    float _290 = _287 * 0.07434873282909393f;
    float _291 = _288 * 0.07434873282909393f;
    int _293 = asint((User_000.UserConstant_Z_000[3].y));
    int _294 = _293 & 1;
    bool _295 = (_294 == 0);
    if (!_295) {
      bool _312 = !(_289 <= (User_000.UserConstant_Z_000[4].x));
      if (!_312) {
        float _314 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _315 = _289 / _314;
        float _316 = _315 * (User_000.UserConstant_Z_000[4].y);
        float _317 = _315 * _315;
        float _318 = _317 * _315;
        float _319 = _318 - _315;
        float _320 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _321 = _314 * _314;
        float _322 = _321 * _320;
        float _323 = _322 * _319;
        float _324 = _323 + _316;
        _414 = _324;
      } else {
        bool _326 = !(_289 <= (User_000.UserConstant_Z_000[4].z));
        if (!_326) {
          float _328 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _329 = max(9.999999974752427e-07f, _328);
          float _330 = _289 - (User_000.UserConstant_Z_000[4].x);
          float _331 = _330 / _329;
          float _332 = 1.0f - _331;
          float _333 = _332 * (User_000.UserConstant_Z_000[4].y);
          float _334 = _331 * (User_000.UserConstant_Z_000[4].w);
          float _335 = _333 + _334;
          float _336 = _332 * _332;
          float _337 = _336 * _332;
          float _338 = _337 - _332;
          float _339 = _338 * (User_000.UserConstant_Z_000[10].x);
          float _340 = _331 * _331;
          float _341 = _340 * _331;
          float _342 = _341 - _331;
          float _343 = _342 * (User_000.UserConstant_Z_000[10].y);
          float _344 = _339 + _343;
          float _345 = _329 * _329;
          float _346 = _345 * 0.1666666716337204f;
          float _347 = _346 * _344;
          float _348 = _335 + _347;
          _414 = _348;
        } else {
          bool _350 = !(_289 <= (User_000.UserConstant_Z_000[9].x));
          if (!_350) {
            float _352 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _353 = max(9.999999974752427e-07f, _352);
            float _354 = _289 - (User_000.UserConstant_Z_000[4].z);
            float _355 = _354 / _353;
            float _356 = 1.0f - _355;
            float _357 = _356 * (User_000.UserConstant_Z_000[4].w);
            float _358 = _355 * (User_000.UserConstant_Z_000[9].y);
            float _359 = _357 + _358;
            float _360 = _356 * _356;
            float _361 = _360 * _356;
            float _362 = _361 - _356;
            float _363 = _362 * (User_000.UserConstant_Z_000[10].y);
            float _364 = _355 * _355;
            float _365 = _364 * _355;
            float _366 = _365 - _355;
            float _367 = _366 * (User_000.UserConstant_Z_000[10].z);
            float _368 = _363 + _367;
            float _369 = _353 * _353;
            float _370 = _369 * 0.1666666716337204f;
            float _371 = _370 * _368;
            float _372 = _359 + _371;
            _414 = _372;
          } else {
            bool _374 = !(_289 <= (User_000.UserConstant_Z_000[9].z));
            if (!_374) {
              float _376 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _377 = max(9.999999974752427e-07f, _376);
              float _378 = _289 - (User_000.UserConstant_Z_000[9].x);
              float _379 = _378 / _377;
              float _380 = 1.0f - _379;
              float _381 = _380 * (User_000.UserConstant_Z_000[9].y);
              float _382 = _379 * (User_000.UserConstant_Z_000[9].w);
              float _383 = _381 + _382;
              float _384 = _380 * _380;
              float _385 = _384 * _380;
              float _386 = _385 - _380;
              float _387 = _386 * (User_000.UserConstant_Z_000[10].z);
              float _388 = _379 * _379;
              float _389 = _388 * _379;
              float _390 = _389 - _379;
              float _391 = _390 * (User_000.UserConstant_Z_000[10].w);
              float _392 = _387 + _391;
              float _393 = _377 * _377;
              float _394 = _393 * 0.1666666716337204f;
              float _395 = _394 * _392;
              float _396 = _383 + _395;
              _414 = _396;
            } else {
              float _398 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _399 = _289 - (User_000.UserConstant_Z_000[9].z);
              float _400 = max(9.999999974752427e-07f, _398);
              float _401 = _399 / _400;
              float _402 = 1.0f - _401;
              float _403 = _402 * (User_000.UserConstant_Z_000[9].w);
              float _404 = _403 + _401;
              float _405 = _402 * _402;
              float _406 = _405 * _402;
              float _407 = _406 - _402;
              float _408 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _409 = _398 * _398;
              float _410 = _409 * _408;
              float _411 = _410 * _407;
              float _412 = _404 + _411;
              _414 = _412;
            }
          }
        }
      }
      float _415 = saturate(_414);
      bool _416 = !(_290 <= (User_000.UserConstant_Z_000[4].x));
      if (!_416) {
        float _418 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _419 = _290 / _418;
        float _420 = _419 * (User_000.UserConstant_Z_000[4].y);
        float _421 = _419 * _419;
        float _422 = _421 * _419;
        float _423 = _422 - _419;
        float _424 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _425 = _418 * _418;
        float _426 = _425 * _424;
        float _427 = _426 * _423;
        float _428 = _427 + _420;
        _518 = _428;
      } else {
        bool _430 = !(_290 <= (User_000.UserConstant_Z_000[4].z));
        if (!_430) {
          float _432 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _433 = max(9.999999974752427e-07f, _432);
          float _434 = _290 - (User_000.UserConstant_Z_000[4].x);
          float _435 = _434 / _433;
          float _436 = 1.0f - _435;
          float _437 = _436 * (User_000.UserConstant_Z_000[4].y);
          float _438 = _435 * (User_000.UserConstant_Z_000[4].w);
          float _439 = _437 + _438;
          float _440 = _436 * _436;
          float _441 = _440 * _436;
          float _442 = _441 - _436;
          float _443 = _442 * (User_000.UserConstant_Z_000[10].x);
          float _444 = _435 * _435;
          float _445 = _444 * _435;
          float _446 = _445 - _435;
          float _447 = _446 * (User_000.UserConstant_Z_000[10].y);
          float _448 = _443 + _447;
          float _449 = _433 * _433;
          float _450 = _449 * 0.1666666716337204f;
          float _451 = _450 * _448;
          float _452 = _439 + _451;
          _518 = _452;
        } else {
          bool _454 = !(_290 <= (User_000.UserConstant_Z_000[9].x));
          if (!_454) {
            float _456 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _457 = max(9.999999974752427e-07f, _456);
            float _458 = _290 - (User_000.UserConstant_Z_000[4].z);
            float _459 = _458 / _457;
            float _460 = 1.0f - _459;
            float _461 = _460 * (User_000.UserConstant_Z_000[4].w);
            float _462 = _459 * (User_000.UserConstant_Z_000[9].y);
            float _463 = _461 + _462;
            float _464 = _460 * _460;
            float _465 = _464 * _460;
            float _466 = _465 - _460;
            float _467 = _466 * (User_000.UserConstant_Z_000[10].y);
            float _468 = _459 * _459;
            float _469 = _468 * _459;
            float _470 = _469 - _459;
            float _471 = _470 * (User_000.UserConstant_Z_000[10].z);
            float _472 = _467 + _471;
            float _473 = _457 * _457;
            float _474 = _473 * 0.1666666716337204f;
            float _475 = _474 * _472;
            float _476 = _463 + _475;
            _518 = _476;
          } else {
            bool _478 = !(_290 <= (User_000.UserConstant_Z_000[9].z));
            if (!_478) {
              float _480 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _481 = max(9.999999974752427e-07f, _480);
              float _482 = _290 - (User_000.UserConstant_Z_000[9].x);
              float _483 = _482 / _481;
              float _484 = 1.0f - _483;
              float _485 = _484 * (User_000.UserConstant_Z_000[9].y);
              float _486 = _483 * (User_000.UserConstant_Z_000[9].w);
              float _487 = _485 + _486;
              float _488 = _484 * _484;
              float _489 = _488 * _484;
              float _490 = _489 - _484;
              float _491 = _490 * (User_000.UserConstant_Z_000[10].z);
              float _492 = _483 * _483;
              float _493 = _492 * _483;
              float _494 = _493 - _483;
              float _495 = _494 * (User_000.UserConstant_Z_000[10].w);
              float _496 = _491 + _495;
              float _497 = _481 * _481;
              float _498 = _497 * 0.1666666716337204f;
              float _499 = _498 * _496;
              float _500 = _487 + _499;
              _518 = _500;
            } else {
              float _502 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _503 = _290 - (User_000.UserConstant_Z_000[9].z);
              float _504 = max(9.999999974752427e-07f, _502);
              float _505 = _503 / _504;
              float _506 = 1.0f - _505;
              float _507 = _506 * (User_000.UserConstant_Z_000[9].w);
              float _508 = _507 + _505;
              float _509 = _506 * _506;
              float _510 = _509 * _506;
              float _511 = _510 - _506;
              float _512 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _513 = _502 * _502;
              float _514 = _513 * _512;
              float _515 = _514 * _511;
              float _516 = _508 + _515;
              _518 = _516;
            }
          }
        }
      }
      float _519 = saturate(_518);
      bool _520 = !(_291 <= (User_000.UserConstant_Z_000[4].x));
      if (!_520) {
        float _522 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _523 = _291 / _522;
        float _524 = _523 * (User_000.UserConstant_Z_000[4].y);
        float _525 = _523 * _523;
        float _526 = _525 * _523;
        float _527 = _526 - _523;
        float _528 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _529 = _522 * _522;
        float _530 = _529 * _528;
        float _531 = _530 * _527;
        float _532 = _531 + _524;
        _622 = _532;
      } else {
        bool _534 = !(_291 <= (User_000.UserConstant_Z_000[4].z));
        if (!_534) {
          float _536 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _537 = max(9.999999974752427e-07f, _536);
          float _538 = _291 - (User_000.UserConstant_Z_000[4].x);
          float _539 = _538 / _537;
          float _540 = 1.0f - _539;
          float _541 = _540 * (User_000.UserConstant_Z_000[4].y);
          float _542 = _539 * (User_000.UserConstant_Z_000[4].w);
          float _543 = _541 + _542;
          float _544 = _540 * _540;
          float _545 = _544 * _540;
          float _546 = _545 - _540;
          float _547 = _546 * (User_000.UserConstant_Z_000[10].x);
          float _548 = _539 * _539;
          float _549 = _548 * _539;
          float _550 = _549 - _539;
          float _551 = _550 * (User_000.UserConstant_Z_000[10].y);
          float _552 = _547 + _551;
          float _553 = _537 * _537;
          float _554 = _553 * 0.1666666716337204f;
          float _555 = _554 * _552;
          float _556 = _543 + _555;
          _622 = _556;
        } else {
          bool _558 = !(_291 <= (User_000.UserConstant_Z_000[9].x));
          if (!_558) {
            float _560 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _561 = max(9.999999974752427e-07f, _560);
            float _562 = _291 - (User_000.UserConstant_Z_000[4].z);
            float _563 = _562 / _561;
            float _564 = 1.0f - _563;
            float _565 = _564 * (User_000.UserConstant_Z_000[4].w);
            float _566 = _563 * (User_000.UserConstant_Z_000[9].y);
            float _567 = _565 + _566;
            float _568 = _564 * _564;
            float _569 = _568 * _564;
            float _570 = _569 - _564;
            float _571 = _570 * (User_000.UserConstant_Z_000[10].y);
            float _572 = _563 * _563;
            float _573 = _572 * _563;
            float _574 = _573 - _563;
            float _575 = _574 * (User_000.UserConstant_Z_000[10].z);
            float _576 = _571 + _575;
            float _577 = _561 * _561;
            float _578 = _577 * 0.1666666716337204f;
            float _579 = _578 * _576;
            float _580 = _567 + _579;
            _622 = _580;
          } else {
            bool _582 = !(_291 <= (User_000.UserConstant_Z_000[9].z));
            if (!_582) {
              float _584 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _585 = max(9.999999974752427e-07f, _584);
              float _586 = _291 - (User_000.UserConstant_Z_000[9].x);
              float _587 = _586 / _585;
              float _588 = 1.0f - _587;
              float _589 = _588 * (User_000.UserConstant_Z_000[9].y);
              float _590 = _587 * (User_000.UserConstant_Z_000[9].w);
              float _591 = _589 + _590;
              float _592 = _588 * _588;
              float _593 = _592 * _588;
              float _594 = _593 - _588;
              float _595 = _594 * (User_000.UserConstant_Z_000[10].z);
              float _596 = _587 * _587;
              float _597 = _596 * _587;
              float _598 = _597 - _587;
              float _599 = _598 * (User_000.UserConstant_Z_000[10].w);
              float _600 = _595 + _599;
              float _601 = _585 * _585;
              float _602 = _601 * 0.1666666716337204f;
              float _603 = _602 * _600;
              float _604 = _591 + _603;
              _622 = _604;
            } else {
              float _606 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _607 = _291 - (User_000.UserConstant_Z_000[9].z);
              float _608 = max(9.999999974752427e-07f, _606);
              float _609 = _607 / _608;
              float _610 = 1.0f - _609;
              float _611 = _610 * (User_000.UserConstant_Z_000[9].w);
              float _612 = _611 + _609;
              float _613 = _610 * _610;
              float _614 = _613 * _610;
              float _615 = _614 - _610;
              float _616 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _617 = _606 * _606;
              float _618 = _617 * _616;
              float _619 = _618 * _615;
              float _620 = _612 + _619;
              _622 = _620;
            }
          }
        }
      }
      float _623 = saturate(_622);
      _625 = _415;
      _626 = _519;
      _627 = _623;
    } else {
      _625 = _289;
      _626 = _290;
      _627 = _291;
    }
    int _628 = _293 & 2;
    bool _629 = (_628 == 0);
    if (!_629) {
      float _631 = sqrt(_625);
      float _632 = sqrt(_626);
      float _633 = sqrt(_627);
      float _634 = dot(float3(_631, _632, _633), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _635 = 1.0f - _634;
      float _636 = saturate(_635);
      _638 = _636;
    } else {
      _638 = 1.0f;
    }
    int _639 = _293 & 8;
    bool _640 = (_639 == 0);
    if (_640) {
      int _642 = _293 & 4;
      bool _643 = (_642 == 0);
      if (!_643) {
        int _645 = _293 & 16;
        bool _646 = (_645 == 0);
        if (!_646) {
          float _650 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _651 = _650 + 0.5f;
          bool _652 = (_651 < 0.5f);
          float _653 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _654 = select(_652, (User_000.UserConstant_Z_000[5].x), _653);
          bool _655 = (_626 < _627);
          float _656 = select(_655, _627, _626);
          float _657 = select(_655, _626, _627);
          bool _658 = (_625 < _656);
          float _659 = select(_658, _656, _625);
          float _660 = select(_658, _625, _656);
          float _661 = min(_660, _657);
          float _662 = _659 - _661;
          float _663 = _659 + 1.000000013351432e-10f;
          float _664 = _662 / _663;
          float _666 = _664 - (User_000.UserConstant_Z_000[5].y);
          float _667 = saturate(_666);
          float _668 = max(_667, 9.999999974752427e-07f);
          float _669 = log2(_668);
          float _670 = _669 * _654;
          float _671 = exp2(_670);
          float _672 = 2.0f - _671;
          float _674 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _675 = saturate(_674);
          float _676 = max(_675, _672);
          float _677 = dot(float3(_625, _626, _627), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _678 = _625 - _677;
          float _679 = _626 - _677;
          float _680 = _627 - _677;
          float _681 = _678 * _676;
          float _682 = _679 * _676;
          float _683 = _680 * _676;
          float _684 = _677 - _625;
          float _685 = _684 + _681;
          float _686 = _677 - _626;
          float _687 = _686 + _682;
          float _688 = _677 - _627;
          float _689 = _688 + _683;
          float _690 = _685 * _638;
          float _691 = _687 * _638;
          float _692 = _689 * _638;
          float _693 = _690 + _625;
          float _694 = _691 + _626;
          float _695 = _692 + _627;
          _812 = _693;
          _813 = _694;
          _814 = _695;
        } else {
          bool _697 = (_638 == 0.0f);
          if (!_697) {
            float _701 = abs(User_000.UserConstant_Z_000[5].x);
            float _702 = saturate(_701);
            uint4 _704 = 0u; t15.GetDimensions(0u, _704.x, _704.y, _704.w);
            float _707 = float((uint)_704.y);
            int _708 = _293 & 32;
            bool _709 = (_708 == 0);
            float _710 = _707 + -1.0f;
            if (!_709) {
              float _712 = 1.0f / _710;
              uint _713 = uint(SV_Position.x);
              uint _714 = uint(SV_Position.y);
              int _715 = _713 & 63;
              int _716 = _714 & 63;
              float4 _718 = t2.Load(int4(_715, _716, 0, 0));
              float _721 = _718.x + -0.5f;
              float _722 = _625 * 13.999999046325684f;
              float _723 = _626 * 13.999999046325684f;
              float _724 = _627 * 13.999999046325684f;
              float _725 = saturate(_722);
              float _726 = saturate(_723);
              float _727 = saturate(_724);
              float _728 = _625 + -0.9285714030265808f;
              float _729 = _626 + -0.9285714030265808f;
              float _730 = _627 + -0.9285714030265808f;
              float _731 = _728 * 13.999999046325684f;
              float _732 = _729 * 13.999999046325684f;
              float _733 = _730 * 13.999999046325684f;
              float _734 = saturate(_731);
              float _735 = saturate(_732);
              float _736 = saturate(_733);
              float _737 = 1.0f - _734;
              float _738 = 1.0f - _735;
              float _739 = 1.0f - _736;
              float _740 = min(_725, _737);
              float _741 = min(_726, _738);
              float _742 = min(_727, _739);
              float _743 = _718.y + -0.5f;
              float _744 = _740 * _743;
              float _745 = _741 * _743;
              float _746 = _742 * _743;
              float _747 = _744 + _721;
              float _748 = _745 + _721;
              float _749 = _746 + _721;
              float _750 = _747 * _712;
              float _751 = _748 * _712;
              float _752 = _749 * _712;
              float _753 = _750 + _625;
              float _754 = _751 + _626;
              float _755 = _752 + _627;
              float _756 = saturate(_753);
              float _757 = saturate(_754);
              float _758 = saturate(_755);
              float _759 = saturate(_756);
              float _760 = saturate(_757);
              float _761 = saturate(_758);
              _763 = _759;
              _764 = _760;
              _765 = _761;
            } else {
              _763 = _625;
              _764 = _626;
              _765 = _627;
            }
            float _766 = float((uint)_704.x);
            float _767 = _710 / _766;
            float _768 = _767 * _763;
            float _769 = 0.5f / _766;
            float _770 = _768 + _769;
            float _771 = _710 / _707;
            float _772 = _771 * _764;
            float _773 = 0.5f / _707;
            float _774 = _772 + _773;
            float _775 = _765 * _710;
            float _776 = floor(_775);
            float _777 = frac(_775);
            float _778 = _776 / _707;
            float _779 = _778 + _770;
            float _780 = _776 + 1.0f;
            float _781 = _780 / _707;
            float _782 = _781 + _770;
            float4 _784 = t15.Sample(s0, float2(_779, _774));
            float4 _788 = t15.Sample(s0, float2(_782, _774));
            float _792 = _788.x - _784.x;
            float _793 = _788.y - _784.y;
            float _794 = _788.z - _784.z;
            float _795 = _792 * _777;
            float _796 = _793 * _777;
            float _797 = _794 * _777;
            float _798 = _702 * _638;
            float _799 = _784.x - _625;
            float _800 = _799 + _795;
            float _801 = _784.y - _626;
            float _802 = _801 + _796;
            float _803 = _784.z - _627;
            float _804 = _803 + _797;
            float _805 = _800 * _798;
            float _806 = _802 * _798;
            float _807 = _804 * _798;
            float _808 = _805 + _625;
            float _809 = _806 + _626;
            float _810 = _807 + _627;
            _812 = _808;
            _813 = _809;
            _814 = _810;
          } else {
            _812 = _625;
            _813 = _626;
            _814 = _627;
          }
        }
      } else {
        _812 = _625;
        _813 = _626;
        _814 = _627;
      }
    } else {
      _812 = _638;
      _813 = _638;
      _814 = _638;
    }
    float _815 = _812 * 13.450128555297852f;
    float _816 = _813 * 13.450128555297852f;
    float _817 = _814 * 13.450128555297852f;
    float _818 = exp2(_815);
    float _819 = exp2(_816);
    float _820 = exp2(_817);
    float _821 = _818 + -1.0f;
    float _822 = _819 + -1.0f;
    float _823 = _820 + -1.0f;
    float _824 = _821 * _271;
    float _825 = _822 * _271;
    float _826 = _823 * _271;
    _828 = _824;
    _829 = _825;
    _830 = _826;
  } else {
    _828 = _272;
    _829 = _273;
    _830 = _274;
  }
  float _835 = (User_000.UserConstant_Z_000[8].x) * _828;
  float _836 = (User_000.UserConstant_Z_000[8].y) * _829;
  float _837 = (User_000.UserConstant_Z_000[8].z) * _830;
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3(_835, _836, _837),
      SV_Position.xy);
  float _842 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _843 = _842 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _844 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _845 = _844 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _848 = _843 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _849 = _845 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _852 = t9.Sample(s9, float2(_848, _849));
  float _856 = dot(float3(_835, _836, _837), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _859 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _862 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _863 = select(_859, _862, 0);
  float _864 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _865 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _866 = uint(_864);
  uint _867 = uint(_865);
  int _868 = _866 & 63;
  int _869 = _867 & 63;
  float4 _871 = t2.Load(int4(_868, _869, _863, 0));
  bool _873 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_873) {
    float _875 = _864 * 0.015625f;
    float _876 = _865 * 0.015625f;
    float _877 = float((uint)_862);
    float _878 = select(_859, _877, 0.0f);
    float4 _880 = t2.SampleLevel(s1, float3(_875, _876, _878), 0.0f);
    float _882 = _871.y - _880.y;
    float _883 = _882 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _884 = _883 + _880.y;
    _886 = _884;
  } else {
    _886 = _871.y;
  }
  float _887 = _852.x * -2.0f;
  float _888 = _887 * _886;
  float _889 = _886 * 2.0f;
  float _890 = _889 * _852.y;
  float _891 = _889 * _852.z;
  float _892 = _888 + _852.x;
  float _893 = _890 - _852.y;
  float _894 = _891 - _852.z;
  float _895 = _892 * _852.x;
  float _896 = _893 * _852.y;
  float _897 = _894 * _852.z;
  float _898 = _856 + 1.0f;
  float _899 = _856 / _898;
  float _900 = _899 + -9.999999747378752e-05f;
  float _901 = _900 * 1111.111083984375f;
  float _902 = saturate(_901);
  float _903 = _902 * 2.0f;
  float _904 = 3.0f - _903;
  float _905 = _902 * _902;
  float _906 = _905 * _904;
  bool _908 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _909 = float((bool)_908);
  float _910 = dot(float3(_895, _896, _897), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _911 = _910 - _895;
  float _912 = _910 - _896;
  float _913 = _910 - _897;
  float _914 = _911 * _909;
  float _915 = _912 * _909;
  float _916 = _913 * _909;
  float _917 = _914 + _895;
  float _918 = _915 + _896;
  float _919 = _916 + _897;
  float _923 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _924 = _923 * _899;
  float _925 = _924 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _926 = _906 * _925;
  float _927 = _926 * _917;
  float _928 = _926 * _918;
  float _929 = _926 * _919;
  float _930 = _927 + _835;
  float _931 = _928 + _836;
  float _932 = _929 + _837;
  float _933 = max(0.0f, _930);
  float _934 = max(0.0f, _931);
  float _935 = max(0.0f, _932);
  float3 resonance_film_grain_output = ResonanceSelectFilmGrainOutput(
      float3(_933, _934, _935),
      resonance_perceptual_film_grain);
  _933 = resonance_film_grain_output.x;
  _934 = resonance_film_grain_output.y;
  _935 = resonance_film_grain_output.z;
  float _938 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _939 = log2(_933);
  float _940 = _938 * _939;
  float _941 = exp2(_940);
  float _942 = _941 + -1.0f;
  float _943 = _933 + -1.0f;
  float _944 = _942 / _943;
  bool _945 = !(_933 == 1.0f);
  float _946 = _944 + -1.0f;
  float _947 = _946 / _944;
  float _948 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _949 = _948 / _938;
  float _950 = select(_945, _947, _949);
  float _951 = log2(_934);
  float _952 = _951 * _938;
  float _953 = exp2(_952);
  float _954 = _953 + -1.0f;
  float _955 = _934 + -1.0f;
  float _956 = _954 / _955;
  bool _957 = !(_934 == 1.0f);
  float _958 = _956 + -1.0f;
  float _959 = _958 / _956;
  float _960 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _961 = _960 / _938;
  float _962 = select(_957, _959, _961);
  float _963 = log2(_935);
  float _964 = _963 * _938;
  float _965 = exp2(_964);
  float _966 = _965 + -1.0f;
  float _967 = _935 + -1.0f;
  float _968 = _966 / _967;
  bool _969 = !(_935 == 1.0f);
  float _970 = _968 + -1.0f;
  float _971 = _970 / _968;
  float _972 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _973 = _972 / _938;
  float _974 = select(_969, _971, _973);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_933, _934, _935),
      float3(_950, _962, _974),
      true);
  float _975 = resonance_post_process_output.x;
  float _976 = resonance_post_process_output.y;
  float _977 = resonance_post_process_output.z;
  float _978 = log2(_975);
  float _979 = log2(_976);
  float _980 = log2(_977);
  float _981 = _978 * 0.4166666567325592f;
  float _982 = _979 * 0.4166666567325592f;
  float _983 = _980 * 0.4166666567325592f;
  float _984 = exp2(_981);
  float _985 = exp2(_982);
  float _986 = exp2(_983);
  float _987 = _984 * 1.0549999475479126f;
  float _988 = _985 * 1.0549999475479126f;
  float _989 = _986 * 1.0549999475479126f;
  float _990 = _987 + -0.054999999701976776f;
  float _991 = _988 + -0.054999999701976776f;
  float _992 = _989 + -0.054999999701976776f;
  float _993 = _975 * 12.920000076293945f;
  float _994 = _976 * 12.920000076293945f;
  float _995 = _977 * 12.920000076293945f;
  bool _996 = (_975 <= 0.0031308000907301903f);
  bool _997 = (_976 <= 0.0031308000907301903f);
  bool _998 = (_977 <= 0.0031308000907301903f);
  float _999 = select(_996, _993, _990);
  float _1000 = select(_997, _994, _991);
  float _1001 = select(_998, _995, _992);
  uint _1002 = uint(SV_Position.x);
  uint _1003 = uint(SV_Position.y);
  int _1004 = _1002 & 63;
  int _1005 = _1003 & 63;
  float4 _1007 = t1.Load(int4(_1004, _1005, _862, 0));
  float _1009 = _1007.x + -0.5f;
  float _1010 = _1009 * 0.003921568859368563f;
  float _1011 = _1010 + _999;
  float _1012 = _1010 + _1000;
  float _1013 = _1010 + _1001;
  float _1014 = saturate(_1011);
  float _1015 = saturate(_1012);
  float _1016 = saturate(_1013);
  SV_Target.x = _1014;
  SV_Target.y = _1015;
  SV_Target.z = _1016;
  SV_Target.w = _130.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}