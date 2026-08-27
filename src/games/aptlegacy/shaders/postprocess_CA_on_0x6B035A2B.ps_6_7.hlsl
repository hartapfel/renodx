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
  GlobalCB_Z__ViewportConstant_Z GlobalCB_Z_1680;
  GlobalCB_Z__AnchorConstant_Z GlobalCB_Z_1776;
  GlobalCB_Z__ViewConstant_Z GlobalCB_Z_2128;
  GlobalCB_Z__ProjConstant_Z GlobalCB_Z_2672;
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

#include "../common.hlsli"

cbuffer cb1 : register(b1) {
  GlobalCB_Z Global_000 : packoffset(c000.x);
  float4 cb1_raw[301] : packoffset(c0);
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
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
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
  float _376;
  float _480;
  float _584;
  float _587;
  float _588;
  float _589;
  float _600;
  float _725;
  float _726;
  float _727;
  float _774;
  float _775;
  float _776;
  float _790;
  float _791;
  float _792;
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
  float _188 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _189 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _190 = _180.x * _189;
  float _191 = _190 * _174;
  float _192 = _191 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _193 = _192 * _188;
  float _194 = _190 * _175;
  float _195 = _194 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _196 = _195 * _188;
  float _197 = _190 * _176;
  float _198 = _197 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _199 = _198 * _188;
  float _200 = _193 + 1.0f;
  float _201 = _196 + 1.0f;
  float _202 = _199 + 1.0f;
  float _203 = log2(_200);
  float _204 = log2(_201);
  float _205 = log2(_202);
  float _208 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _209 = _208 * _203;
  float _210 = _208 * _204;
  float _211 = _208 * _205;
  float _213 = _209 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _214 = _210 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _215 = _211 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _218 = t3.Sample(s3, float3(_213, _214, _215));
  float _224 = _218.x * 13.450128555297852f;
  float _225 = _218.y * 13.450128555297852f;
  float _226 = _218.z * 13.450128555297852f;
  float _227 = exp2(_224);
  float _228 = exp2(_225);
  float _229 = exp2(_226);
  float _230 = _227 + -1.0f;
  float _231 = _228 + -1.0f;
  float _232 = _229 + -1.0f;
  float _233 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _234 = _233 * _230;
  float _235 = _233 * _231;
  float _236 = _233 * _232;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_193 * _233, _196 * _233, _199 * _233),
      float3(_234, _235, _236),
      1.f.xxx);
  _234 = apt_scaled_lut_output.x;
  _235 = apt_scaled_lut_output.y;
  _236 = apt_scaled_lut_output.z;
  bool _239 = ((User_000.UserConstant_Z_000[3].x) > 0.0f);
  if (_239) {
    float _241 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _242 = _234 * _241;
    float _243 = _235 * _241;
    float _244 = _236 * _241;
    float _245 = _242 + 1.0f;
    float _246 = _243 + 1.0f;
    float _247 = _244 + 1.0f;
    float _248 = log2(_245);
    float _249 = log2(_246);
    float _250 = log2(_247);
    float _251 = _248 * 0.07434873282909393f;
    float _252 = _249 * 0.07434873282909393f;
    float _253 = _250 * 0.07434873282909393f;
    int _255 = asint((User_000.UserConstant_Z_000[3].y));
    int _256 = _255 & 1;
    bool _257 = (_256 == 0);
    if (!_257) {
      bool _274 = !(_251 <= (User_000.UserConstant_Z_000[4].x));
      if (!_274) {
        float _276 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _277 = _251 / _276;
        float _278 = _277 * (User_000.UserConstant_Z_000[4].y);
        float _279 = _277 * _277;
        float _280 = _279 * _277;
        float _281 = _280 - _277;
        float _282 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _283 = _276 * _276;
        float _284 = _283 * _282;
        float _285 = _284 * _281;
        float _286 = _285 + _278;
        _376 = _286;
      } else {
        bool _288 = !(_251 <= (User_000.UserConstant_Z_000[4].z));
        if (!_288) {
          float _290 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _291 = max(9.999999974752427e-07f, _290);
          float _292 = _251 - (User_000.UserConstant_Z_000[4].x);
          float _293 = _292 / _291;
          float _294 = 1.0f - _293;
          float _295 = _294 * (User_000.UserConstant_Z_000[4].y);
          float _296 = _293 * (User_000.UserConstant_Z_000[4].w);
          float _297 = _295 + _296;
          float _298 = _294 * _294;
          float _299 = _298 * _294;
          float _300 = _299 - _294;
          float _301 = _300 * (User_000.UserConstant_Z_000[10].x);
          float _302 = _293 * _293;
          float _303 = _302 * _293;
          float _304 = _303 - _293;
          float _305 = _304 * (User_000.UserConstant_Z_000[10].y);
          float _306 = _301 + _305;
          float _307 = _291 * _291;
          float _308 = _307 * 0.1666666716337204f;
          float _309 = _308 * _306;
          float _310 = _297 + _309;
          _376 = _310;
        } else {
          bool _312 = !(_251 <= (User_000.UserConstant_Z_000[9].x));
          if (!_312) {
            float _314 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _315 = max(9.999999974752427e-07f, _314);
            float _316 = _251 - (User_000.UserConstant_Z_000[4].z);
            float _317 = _316 / _315;
            float _318 = 1.0f - _317;
            float _319 = _318 * (User_000.UserConstant_Z_000[4].w);
            float _320 = _317 * (User_000.UserConstant_Z_000[9].y);
            float _321 = _319 + _320;
            float _322 = _318 * _318;
            float _323 = _322 * _318;
            float _324 = _323 - _318;
            float _325 = _324 * (User_000.UserConstant_Z_000[10].y);
            float _326 = _317 * _317;
            float _327 = _326 * _317;
            float _328 = _327 - _317;
            float _329 = _328 * (User_000.UserConstant_Z_000[10].z);
            float _330 = _325 + _329;
            float _331 = _315 * _315;
            float _332 = _331 * 0.1666666716337204f;
            float _333 = _332 * _330;
            float _334 = _321 + _333;
            _376 = _334;
          } else {
            bool _336 = !(_251 <= (User_000.UserConstant_Z_000[9].z));
            if (!_336) {
              float _338 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _339 = max(9.999999974752427e-07f, _338);
              float _340 = _251 - (User_000.UserConstant_Z_000[9].x);
              float _341 = _340 / _339;
              float _342 = 1.0f - _341;
              float _343 = _342 * (User_000.UserConstant_Z_000[9].y);
              float _344 = _341 * (User_000.UserConstant_Z_000[9].w);
              float _345 = _343 + _344;
              float _346 = _342 * _342;
              float _347 = _346 * _342;
              float _348 = _347 - _342;
              float _349 = _348 * (User_000.UserConstant_Z_000[10].z);
              float _350 = _341 * _341;
              float _351 = _350 * _341;
              float _352 = _351 - _341;
              float _353 = _352 * (User_000.UserConstant_Z_000[10].w);
              float _354 = _349 + _353;
              float _355 = _339 * _339;
              float _356 = _355 * 0.1666666716337204f;
              float _357 = _356 * _354;
              float _358 = _345 + _357;
              _376 = _358;
            } else {
              float _360 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _361 = _251 - (User_000.UserConstant_Z_000[9].z);
              float _362 = max(9.999999974752427e-07f, _360);
              float _363 = _361 / _362;
              float _364 = 1.0f - _363;
              float _365 = _364 * (User_000.UserConstant_Z_000[9].w);
              float _366 = _365 + _363;
              float _367 = _364 * _364;
              float _368 = _367 * _364;
              float _369 = _368 - _364;
              float _370 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _371 = _360 * _360;
              float _372 = _371 * _370;
              float _373 = _372 * _369;
              float _374 = _366 + _373;
              _376 = _374;
            }
          }
        }
      }
      float _377 = saturate(_376);
      bool _378 = !(_252 <= (User_000.UserConstant_Z_000[4].x));
      if (!_378) {
        float _380 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _381 = _252 / _380;
        float _382 = _381 * (User_000.UserConstant_Z_000[4].y);
        float _383 = _381 * _381;
        float _384 = _383 * _381;
        float _385 = _384 - _381;
        float _386 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _387 = _380 * _380;
        float _388 = _387 * _386;
        float _389 = _388 * _385;
        float _390 = _389 + _382;
        _480 = _390;
      } else {
        bool _392 = !(_252 <= (User_000.UserConstant_Z_000[4].z));
        if (!_392) {
          float _394 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _395 = max(9.999999974752427e-07f, _394);
          float _396 = _252 - (User_000.UserConstant_Z_000[4].x);
          float _397 = _396 / _395;
          float _398 = 1.0f - _397;
          float _399 = _398 * (User_000.UserConstant_Z_000[4].y);
          float _400 = _397 * (User_000.UserConstant_Z_000[4].w);
          float _401 = _399 + _400;
          float _402 = _398 * _398;
          float _403 = _402 * _398;
          float _404 = _403 - _398;
          float _405 = _404 * (User_000.UserConstant_Z_000[10].x);
          float _406 = _397 * _397;
          float _407 = _406 * _397;
          float _408 = _407 - _397;
          float _409 = _408 * (User_000.UserConstant_Z_000[10].y);
          float _410 = _405 + _409;
          float _411 = _395 * _395;
          float _412 = _411 * 0.1666666716337204f;
          float _413 = _412 * _410;
          float _414 = _401 + _413;
          _480 = _414;
        } else {
          bool _416 = !(_252 <= (User_000.UserConstant_Z_000[9].x));
          if (!_416) {
            float _418 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _419 = max(9.999999974752427e-07f, _418);
            float _420 = _252 - (User_000.UserConstant_Z_000[4].z);
            float _421 = _420 / _419;
            float _422 = 1.0f - _421;
            float _423 = _422 * (User_000.UserConstant_Z_000[4].w);
            float _424 = _421 * (User_000.UserConstant_Z_000[9].y);
            float _425 = _423 + _424;
            float _426 = _422 * _422;
            float _427 = _426 * _422;
            float _428 = _427 - _422;
            float _429 = _428 * (User_000.UserConstant_Z_000[10].y);
            float _430 = _421 * _421;
            float _431 = _430 * _421;
            float _432 = _431 - _421;
            float _433 = _432 * (User_000.UserConstant_Z_000[10].z);
            float _434 = _429 + _433;
            float _435 = _419 * _419;
            float _436 = _435 * 0.1666666716337204f;
            float _437 = _436 * _434;
            float _438 = _425 + _437;
            _480 = _438;
          } else {
            bool _440 = !(_252 <= (User_000.UserConstant_Z_000[9].z));
            if (!_440) {
              float _442 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _443 = max(9.999999974752427e-07f, _442);
              float _444 = _252 - (User_000.UserConstant_Z_000[9].x);
              float _445 = _444 / _443;
              float _446 = 1.0f - _445;
              float _447 = _446 * (User_000.UserConstant_Z_000[9].y);
              float _448 = _445 * (User_000.UserConstant_Z_000[9].w);
              float _449 = _447 + _448;
              float _450 = _446 * _446;
              float _451 = _450 * _446;
              float _452 = _451 - _446;
              float _453 = _452 * (User_000.UserConstant_Z_000[10].z);
              float _454 = _445 * _445;
              float _455 = _454 * _445;
              float _456 = _455 - _445;
              float _457 = _456 * (User_000.UserConstant_Z_000[10].w);
              float _458 = _453 + _457;
              float _459 = _443 * _443;
              float _460 = _459 * 0.1666666716337204f;
              float _461 = _460 * _458;
              float _462 = _449 + _461;
              _480 = _462;
            } else {
              float _464 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _465 = _252 - (User_000.UserConstant_Z_000[9].z);
              float _466 = max(9.999999974752427e-07f, _464);
              float _467 = _465 / _466;
              float _468 = 1.0f - _467;
              float _469 = _468 * (User_000.UserConstant_Z_000[9].w);
              float _470 = _469 + _467;
              float _471 = _468 * _468;
              float _472 = _471 * _468;
              float _473 = _472 - _468;
              float _474 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _475 = _464 * _464;
              float _476 = _475 * _474;
              float _477 = _476 * _473;
              float _478 = _470 + _477;
              _480 = _478;
            }
          }
        }
      }
      float _481 = saturate(_480);
      bool _482 = !(_253 <= (User_000.UserConstant_Z_000[4].x));
      if (!_482) {
        float _484 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _485 = _253 / _484;
        float _486 = _485 * (User_000.UserConstant_Z_000[4].y);
        float _487 = _485 * _485;
        float _488 = _487 * _485;
        float _489 = _488 - _485;
        float _490 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _491 = _484 * _484;
        float _492 = _491 * _490;
        float _493 = _492 * _489;
        float _494 = _493 + _486;
        _584 = _494;
      } else {
        bool _496 = !(_253 <= (User_000.UserConstant_Z_000[4].z));
        if (!_496) {
          float _498 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _499 = max(9.999999974752427e-07f, _498);
          float _500 = _253 - (User_000.UserConstant_Z_000[4].x);
          float _501 = _500 / _499;
          float _502 = 1.0f - _501;
          float _503 = _502 * (User_000.UserConstant_Z_000[4].y);
          float _504 = _501 * (User_000.UserConstant_Z_000[4].w);
          float _505 = _503 + _504;
          float _506 = _502 * _502;
          float _507 = _506 * _502;
          float _508 = _507 - _502;
          float _509 = _508 * (User_000.UserConstant_Z_000[10].x);
          float _510 = _501 * _501;
          float _511 = _510 * _501;
          float _512 = _511 - _501;
          float _513 = _512 * (User_000.UserConstant_Z_000[10].y);
          float _514 = _509 + _513;
          float _515 = _499 * _499;
          float _516 = _515 * 0.1666666716337204f;
          float _517 = _516 * _514;
          float _518 = _505 + _517;
          _584 = _518;
        } else {
          bool _520 = !(_253 <= (User_000.UserConstant_Z_000[9].x));
          if (!_520) {
            float _522 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _523 = max(9.999999974752427e-07f, _522);
            float _524 = _253 - (User_000.UserConstant_Z_000[4].z);
            float _525 = _524 / _523;
            float _526 = 1.0f - _525;
            float _527 = _526 * (User_000.UserConstant_Z_000[4].w);
            float _528 = _525 * (User_000.UserConstant_Z_000[9].y);
            float _529 = _527 + _528;
            float _530 = _526 * _526;
            float _531 = _530 * _526;
            float _532 = _531 - _526;
            float _533 = _532 * (User_000.UserConstant_Z_000[10].y);
            float _534 = _525 * _525;
            float _535 = _534 * _525;
            float _536 = _535 - _525;
            float _537 = _536 * (User_000.UserConstant_Z_000[10].z);
            float _538 = _533 + _537;
            float _539 = _523 * _523;
            float _540 = _539 * 0.1666666716337204f;
            float _541 = _540 * _538;
            float _542 = _529 + _541;
            _584 = _542;
          } else {
            bool _544 = !(_253 <= (User_000.UserConstant_Z_000[9].z));
            if (!_544) {
              float _546 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _547 = max(9.999999974752427e-07f, _546);
              float _548 = _253 - (User_000.UserConstant_Z_000[9].x);
              float _549 = _548 / _547;
              float _550 = 1.0f - _549;
              float _551 = _550 * (User_000.UserConstant_Z_000[9].y);
              float _552 = _549 * (User_000.UserConstant_Z_000[9].w);
              float _553 = _551 + _552;
              float _554 = _550 * _550;
              float _555 = _554 * _550;
              float _556 = _555 - _550;
              float _557 = _556 * (User_000.UserConstant_Z_000[10].z);
              float _558 = _549 * _549;
              float _559 = _558 * _549;
              float _560 = _559 - _549;
              float _561 = _560 * (User_000.UserConstant_Z_000[10].w);
              float _562 = _557 + _561;
              float _563 = _547 * _547;
              float _564 = _563 * 0.1666666716337204f;
              float _565 = _564 * _562;
              float _566 = _553 + _565;
              _584 = _566;
            } else {
              float _568 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _569 = _253 - (User_000.UserConstant_Z_000[9].z);
              float _570 = max(9.999999974752427e-07f, _568);
              float _571 = _569 / _570;
              float _572 = 1.0f - _571;
              float _573 = _572 * (User_000.UserConstant_Z_000[9].w);
              float _574 = _573 + _571;
              float _575 = _572 * _572;
              float _576 = _575 * _572;
              float _577 = _576 - _572;
              float _578 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _579 = _568 * _568;
              float _580 = _579 * _578;
              float _581 = _580 * _577;
              float _582 = _574 + _581;
              _584 = _582;
            }
          }
        }
      }
      float _585 = saturate(_584);
      _587 = _377;
      _588 = _481;
      _589 = _585;
    } else {
      _587 = _251;
      _588 = _252;
      _589 = _253;
    }
    int _590 = _255 & 2;
    bool _591 = (_590 == 0);
    if (!_591) {
      float _593 = sqrt(_587);
      float _594 = sqrt(_588);
      float _595 = sqrt(_589);
      float _596 = dot(float3(_593, _594, _595), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _597 = 1.0f - _596;
      float _598 = saturate(_597);
      _600 = _598;
    } else {
      _600 = 1.0f;
    }
    int _601 = _255 & 8;
    bool _602 = (_601 == 0);
    if (_602) {
      int _604 = _255 & 4;
      bool _605 = (_604 == 0);
      if (!_605) {
        int _607 = _255 & 16;
        bool _608 = (_607 == 0);
        if (!_608) {
          float _612 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _613 = _612 + 0.5f;
          bool _614 = (_613 < 0.5f);
          float _615 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _616 = select(_614, (User_000.UserConstant_Z_000[5].x), _615);
          bool _617 = (_588 < _589);
          float _618 = select(_617, _589, _588);
          float _619 = select(_617, _588, _589);
          bool _620 = (_587 < _618);
          float _621 = select(_620, _618, _587);
          float _622 = select(_620, _587, _618);
          float _623 = min(_622, _619);
          float _624 = _621 - _623;
          float _625 = _621 + 1.000000013351432e-10f;
          float _626 = _624 / _625;
          float _628 = _626 - (User_000.UserConstant_Z_000[5].y);
          float _629 = saturate(_628);
          float _630 = max(_629, 9.999999974752427e-07f);
          float _631 = log2(_630);
          float _632 = _631 * _616;
          float _633 = exp2(_632);
          float _634 = 2.0f - _633;
          float _636 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _637 = saturate(_636);
          float _638 = max(_637, _634);
          float _639 = dot(float3(_587, _588, _589), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _640 = _587 - _639;
          float _641 = _588 - _639;
          float _642 = _589 - _639;
          float _643 = _640 * _638;
          float _644 = _641 * _638;
          float _645 = _642 * _638;
          float _646 = _639 - _587;
          float _647 = _646 + _643;
          float _648 = _639 - _588;
          float _649 = _648 + _644;
          float _650 = _639 - _589;
          float _651 = _650 + _645;
          float _652 = _647 * _600;
          float _653 = _649 * _600;
          float _654 = _651 * _600;
          float _655 = _652 + _587;
          float _656 = _653 + _588;
          float _657 = _654 + _589;
          _774 = _655;
          _775 = _656;
          _776 = _657;
        } else {
          bool _659 = (_600 == 0.0f);
          if (!_659) {
            float _663 = abs(User_000.UserConstant_Z_000[5].x);
            float _664 = saturate(_663);
            uint4 _666 = 0u; t15.GetDimensions(0u, _666.x, _666.y, _666.w);
            float _669 = float((uint)_666.y);
            int _670 = _255 & 32;
            bool _671 = (_670 == 0);
            float _672 = _669 + -1.0f;
            if (!_671) {
              float _674 = 1.0f / _672;
              uint _675 = uint(SV_Position.x);
              uint _676 = uint(SV_Position.y);
              int _677 = _675 & 63;
              int _678 = _676 & 63;
              float4 _680 = t2.Load(int4(_677, _678, 0, 0));
              float _683 = _680.x + -0.5f;
              float _684 = _587 * 13.999999046325684f;
              float _685 = _588 * 13.999999046325684f;
              float _686 = _589 * 13.999999046325684f;
              float _687 = saturate(_684);
              float _688 = saturate(_685);
              float _689 = saturate(_686);
              float _690 = _587 + -0.9285714030265808f;
              float _691 = _588 + -0.9285714030265808f;
              float _692 = _589 + -0.9285714030265808f;
              float _693 = _690 * 13.999999046325684f;
              float _694 = _691 * 13.999999046325684f;
              float _695 = _692 * 13.999999046325684f;
              float _696 = saturate(_693);
              float _697 = saturate(_694);
              float _698 = saturate(_695);
              float _699 = 1.0f - _696;
              float _700 = 1.0f - _697;
              float _701 = 1.0f - _698;
              float _702 = min(_687, _699);
              float _703 = min(_688, _700);
              float _704 = min(_689, _701);
              float _705 = _680.y + -0.5f;
              float _706 = _702 * _705;
              float _707 = _703 * _705;
              float _708 = _704 * _705;
              float _709 = _706 + _683;
              float _710 = _707 + _683;
              float _711 = _708 + _683;
              float _712 = _709 * _674;
              float _713 = _710 * _674;
              float _714 = _711 * _674;
              float _715 = _712 + _587;
              float _716 = _713 + _588;
              float _717 = _714 + _589;
              float _718 = saturate(_715);
              float _719 = saturate(_716);
              float _720 = saturate(_717);
              float _721 = saturate(_718);
              float _722 = saturate(_719);
              float _723 = saturate(_720);
              _725 = _721;
              _726 = _722;
              _727 = _723;
            } else {
              _725 = _587;
              _726 = _588;
              _727 = _589;
            }
            float _728 = float((uint)_666.x);
            float _729 = _672 / _728;
            float _730 = _729 * _725;
            float _731 = 0.5f / _728;
            float _732 = _730 + _731;
            float _733 = _672 / _669;
            float _734 = _733 * _726;
            float _735 = 0.5f / _669;
            float _736 = _734 + _735;
            float _737 = _727 * _672;
            float _738 = floor(_737);
            float _739 = frac(_737);
            float _740 = _738 / _669;
            float _741 = _740 + _732;
            float _742 = _738 + 1.0f;
            float _743 = _742 / _669;
            float _744 = _743 + _732;
            float4 _746 = t15.Sample(s0, float2(_741, _736));
            float4 _750 = t15.Sample(s0, float2(_744, _736));
            float _754 = _750.x - _746.x;
            float _755 = _750.y - _746.y;
            float _756 = _750.z - _746.z;
            float _757 = _754 * _739;
            float _758 = _755 * _739;
            float _759 = _756 * _739;
            float _760 = _664 * _600;
            float _761 = _746.x - _587;
            float _762 = _761 + _757;
            float _763 = _746.y - _588;
            float _764 = _763 + _758;
            float _765 = _746.z - _589;
            float _766 = _765 + _759;
            float _767 = _762 * _760;
            float _768 = _764 * _760;
            float _769 = _766 * _760;
            float _770 = _767 + _587;
            float _771 = _768 + _588;
            float _772 = _769 + _589;
            _774 = _770;
            _775 = _771;
            _776 = _772;
          } else {
            _774 = _587;
            _775 = _588;
            _776 = _589;
          }
        }
      } else {
        _774 = _587;
        _775 = _588;
        _776 = _589;
      }
    } else {
      _774 = _600;
      _775 = _600;
      _776 = _600;
    }
    float _777 = _774 * 13.450128555297852f;
    float _778 = _775 * 13.450128555297852f;
    float _779 = _776 * 13.450128555297852f;
    float _780 = exp2(_777);
    float _781 = exp2(_778);
    float _782 = exp2(_779);
    float _783 = _780 + -1.0f;
    float _784 = _781 + -1.0f;
    float _785 = _782 + -1.0f;
    float _786 = _783 * _233;
    float _787 = _784 * _233;
    float _788 = _785 * _233;
    _790 = _786;
    _791 = _787;
    _792 = _788;
  } else {
    _790 = _234;
    _791 = _235;
    _792 = _236;
  }
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _790, (User_000.UserConstant_Z_000[8].y) * _791, (User_000.UserConstant_Z_000[8].z) * _792),
      SV_Position.xy);
  float _799 = apt_perceptual_film_grain.x;
  float _800 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _801 = log2(_799);
  float _802 = _800 * _801;
  float _803 = exp2(_802);
  float _804 = _803 + -1.0f;
  float _805 = _799 + -1.0f;
  float _806 = _804 / _805;
  bool _807 = !(_799 == 1.0f);
  float _808 = _806 + -1.0f;
  float _809 = _808 / _806;
  float _810 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _811 = _810 / _800;
  float _812 = select(_807, _809, _811);
  float _813 = apt_perceptual_film_grain.y;
  float _814 = log2(_813);
  float _815 = _814 * _800;
  float _816 = exp2(_815);
  float _817 = _816 + -1.0f;
  float _818 = _813 + -1.0f;
  float _819 = _817 / _818;
  bool _820 = !(_813 == 1.0f);
  float _821 = _819 + -1.0f;
  float _822 = _821 / _819;
  float _823 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _824 = _823 / _800;
  float _825 = select(_820, _822, _824);
  float _826 = apt_perceptual_film_grain.z;
  float _827 = log2(_826);
  float _828 = _827 * _800;
  float _829 = exp2(_828);
  float _830 = _829 + -1.0f;
  float _831 = _826 + -1.0f;
  float _832 = _830 / _831;
  bool _833 = !(_826 == 1.0f);
  float _834 = _832 + -1.0f;
  float _835 = _834 / _832;
  float _836 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _837 = _836 / _800;
  float _838 = select(_833, _835, _837);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_799, _813, _826),
      float3(_812, _825, _838),
      true);
  float _839 = apt_post_process_output.x;
  float _840 = apt_post_process_output.y;
  float _841 = apt_post_process_output.z;
  float _842 = log2(_839);
  float _843 = log2(_840);
  float _844 = log2(_841);
  float _845 = _842 * 0.4166666567325592f;
  float _846 = _843 * 0.4166666567325592f;
  float _847 = _844 * 0.4166666567325592f;
  float _848 = exp2(_845);
  float _849 = exp2(_846);
  float _850 = exp2(_847);
  float _851 = _848 * 1.0549999475479126f;
  float _852 = _849 * 1.0549999475479126f;
  float _853 = _850 * 1.0549999475479126f;
  float _854 = _851 + -0.054999999701976776f;
  float _855 = _852 + -0.054999999701976776f;
  float _856 = _853 + -0.054999999701976776f;
  float _857 = _839 * 12.920000076293945f;
  float _858 = _840 * 12.920000076293945f;
  float _859 = _841 * 12.920000076293945f;
  bool _860 = (_839 <= 0.0031308000907301903f);
  bool _861 = (_840 <= 0.0031308000907301903f);
  bool _862 = (_841 <= 0.0031308000907301903f);
  float _863 = select(_860, _857, _854);
  float _864 = select(_861, _858, _855);
  float _865 = select(_862, _859, _856);
  int _868 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _869 = uint(SV_Position.x);
  uint _870 = uint(SV_Position.y);
  int _871 = _869 & 63;
  int _872 = _870 & 63;
  float4 _874 = t1.Load(int4(_871, _872, _868, 0));
  float _876 = _874.x + -0.5f;
  float _877 = _876 * 0.003921568859368563f;
  float _878 = _877 + _863;
  float _879 = _877 + _864;
  float _880 = _877 + _865;
  float _881 = saturate(_878);
  float _882 = saturate(_879);
  float _883 = saturate(_880);
  SV_Target.x = _881;
  SV_Target.y = _882;
  SV_Target.z = _883;
  SV_Target.w = _127.w;
  return SV_Target;
}
