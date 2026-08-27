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

#include "../common.hlsli"

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
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
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
  int _149 = asint((User_000.UserConstant_Z_000[7].z));
  bool _150 = ((int)_149 > (int)0);
  float _179;
  float _180;
  float _181;
  float _186;
  float _187;
  float _188;
  float _217;
  float _218;
  float _219;
  float _224;
  float _225;
  float _226;
  float _426;
  float _530;
  float _634;
  float _637;
  float _638;
  float _639;
  float _650;
  float _775;
  float _776;
  float _777;
  float _824;
  float _825;
  float _826;
  float _840;
  float _841;
  float _842;
  float _898;
  if (!_150) {
    bool _154 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _158 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _143.x;
    float _159 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _143.y;
    float _160 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _143.z;
    float _161 = _158 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _162 = _159 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _163 = _160 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_154) {
      float _165 = _161 * _137.x;
      float _166 = _162 * _137.y;
      float _167 = _163 * _137.z;
      _179 = _165;
      _180 = _166;
      _181 = _167;
    } else {
      float _169 = saturate(_161);
      float _170 = saturate(_162);
      float _171 = saturate(_163);
      float _172 = _137.x - _133;
      float _173 = _137.y - _134;
      float _174 = _137.z - _135;
      float _175 = _169 * _172;
      float _176 = _170 * _173;
      float _177 = _171 * _174;
      _179 = _175;
      _180 = _176;
      _181 = _177;
    }
    float _182 = _179 + _133;
    float _183 = _180 + _134;
    float _184 = _181 + _135;
    _186 = _182;
    _187 = _183;
    _188 = _184;
  } else {
    _186 = _133;
    _187 = _134;
    _188 = _135;
  }
  if (_150) {
    bool _192 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _196 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _143.x;
    float _197 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _143.y;
    float _198 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _143.z;
    float _199 = _196 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _200 = _197 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _201 = _198 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_192) {
      float _203 = _199 * _137.x;
      float _204 = _200 * _137.y;
      float _205 = _201 * _137.z;
      _217 = _203;
      _218 = _204;
      _219 = _205;
    } else {
      float _207 = saturate(_199);
      float _208 = saturate(_200);
      float _209 = saturate(_201);
      float _210 = _137.x - _186;
      float _211 = _137.y - _187;
      float _212 = _137.z - _188;
      float _213 = _207 * _210;
      float _214 = _208 * _211;
      float _215 = _209 * _212;
      _217 = _213;
      _218 = _214;
      _219 = _215;
    }
    float _220 = _217 + _186;
    float _221 = _218 + _187;
    float _222 = _219 + _188;
    _224 = _220;
    _225 = _221;
    _226 = _222;
  } else {
    _224 = _186;
    _225 = _187;
    _226 = _188;
  }
  float4 _230 = t17.Load(int3(0, 0, 0));
  float _238 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _239 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _240 = _230.x * _239;
  float _241 = _240 * _224;
  float _242 = _241 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _243 = _242 * _238;
  float _244 = _240 * _225;
  float _245 = _244 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _246 = _245 * _238;
  float _247 = _240 * _226;
  float _248 = _247 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _249 = _248 * _238;
  float _250 = _243 + 1.0f;
  float _251 = _246 + 1.0f;
  float _252 = _249 + 1.0f;
  float _253 = log2(_250);
  float _254 = log2(_251);
  float _255 = log2(_252);
  float _258 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _259 = _258 * _253;
  float _260 = _258 * _254;
  float _261 = _258 * _255;
  float _263 = _259 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _264 = _260 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _265 = _261 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _268 = t3.Sample(s3, float3(_263, _264, _265));
  float _274 = _268.x * 13.450128555297852f;
  float _275 = _268.y * 13.450128555297852f;
  float _276 = _268.z * 13.450128555297852f;
  float _277 = exp2(_274);
  float _278 = exp2(_275);
  float _279 = exp2(_276);
  float _280 = _277 + -1.0f;
  float _281 = _278 + -1.0f;
  float _282 = _279 + -1.0f;
  float _283 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _284 = _283 * _280;
  float _285 = _283 * _281;
  float _286 = _283 * _282;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_243 * _283, _246 * _283, _249 * _283),
      float3(_284, _285, _286),
      1.f.xxx);
  _284 = apt_scaled_lut_output.x;
  _285 = apt_scaled_lut_output.y;
  _286 = apt_scaled_lut_output.z;
  bool _289 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !APTIsPsychoV();
  if (_289) {
    float _291 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _292 = _284 * _291;
    float _293 = _285 * _291;
    float _294 = _286 * _291;
    float _295 = _292 + 1.0f;
    float _296 = _293 + 1.0f;
    float _297 = _294 + 1.0f;
    float _298 = log2(_295);
    float _299 = log2(_296);
    float _300 = log2(_297);
    float _301 = _298 * 0.07434873282909393f;
    float _302 = _299 * 0.07434873282909393f;
    float _303 = _300 * 0.07434873282909393f;
    int _305 = asint((User_000.UserConstant_Z_000[3].y));
    int _306 = _305 & 1;
    bool _307 = (_306 == 0);
    if (!_307) {
      bool _324 = !(_301 <= (User_000.UserConstant_Z_000[4].x));
      if (!_324) {
        float _326 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _327 = _301 / _326;
        float _328 = _327 * (User_000.UserConstant_Z_000[4].y);
        float _329 = _327 * _327;
        float _330 = _329 * _327;
        float _331 = _330 - _327;
        float _332 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _333 = _326 * _326;
        float _334 = _333 * _332;
        float _335 = _334 * _331;
        float _336 = _335 + _328;
        _426 = _336;
      } else {
        bool _338 = !(_301 <= (User_000.UserConstant_Z_000[4].z));
        if (!_338) {
          float _340 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _341 = max(9.999999974752427e-07f, _340);
          float _342 = _301 - (User_000.UserConstant_Z_000[4].x);
          float _343 = _342 / _341;
          float _344 = 1.0f - _343;
          float _345 = _344 * (User_000.UserConstant_Z_000[4].y);
          float _346 = _343 * (User_000.UserConstant_Z_000[4].w);
          float _347 = _345 + _346;
          float _348 = _344 * _344;
          float _349 = _348 * _344;
          float _350 = _349 - _344;
          float _351 = _350 * (User_000.UserConstant_Z_000[10].x);
          float _352 = _343 * _343;
          float _353 = _352 * _343;
          float _354 = _353 - _343;
          float _355 = _354 * (User_000.UserConstant_Z_000[10].y);
          float _356 = _351 + _355;
          float _357 = _341 * _341;
          float _358 = _357 * 0.1666666716337204f;
          float _359 = _358 * _356;
          float _360 = _347 + _359;
          _426 = _360;
        } else {
          bool _362 = !(_301 <= (User_000.UserConstant_Z_000[9].x));
          if (!_362) {
            float _364 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _365 = max(9.999999974752427e-07f, _364);
            float _366 = _301 - (User_000.UserConstant_Z_000[4].z);
            float _367 = _366 / _365;
            float _368 = 1.0f - _367;
            float _369 = _368 * (User_000.UserConstant_Z_000[4].w);
            float _370 = _367 * (User_000.UserConstant_Z_000[9].y);
            float _371 = _369 + _370;
            float _372 = _368 * _368;
            float _373 = _372 * _368;
            float _374 = _373 - _368;
            float _375 = _374 * (User_000.UserConstant_Z_000[10].y);
            float _376 = _367 * _367;
            float _377 = _376 * _367;
            float _378 = _377 - _367;
            float _379 = _378 * (User_000.UserConstant_Z_000[10].z);
            float _380 = _375 + _379;
            float _381 = _365 * _365;
            float _382 = _381 * 0.1666666716337204f;
            float _383 = _382 * _380;
            float _384 = _371 + _383;
            _426 = _384;
          } else {
            bool _386 = !(_301 <= (User_000.UserConstant_Z_000[9].z));
            if (!_386) {
              float _388 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _389 = max(9.999999974752427e-07f, _388);
              float _390 = _301 - (User_000.UserConstant_Z_000[9].x);
              float _391 = _390 / _389;
              float _392 = 1.0f - _391;
              float _393 = _392 * (User_000.UserConstant_Z_000[9].y);
              float _394 = _391 * (User_000.UserConstant_Z_000[9].w);
              float _395 = _393 + _394;
              float _396 = _392 * _392;
              float _397 = _396 * _392;
              float _398 = _397 - _392;
              float _399 = _398 * (User_000.UserConstant_Z_000[10].z);
              float _400 = _391 * _391;
              float _401 = _400 * _391;
              float _402 = _401 - _391;
              float _403 = _402 * (User_000.UserConstant_Z_000[10].w);
              float _404 = _399 + _403;
              float _405 = _389 * _389;
              float _406 = _405 * 0.1666666716337204f;
              float _407 = _406 * _404;
              float _408 = _395 + _407;
              _426 = _408;
            } else {
              float _410 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _411 = _301 - (User_000.UserConstant_Z_000[9].z);
              float _412 = max(9.999999974752427e-07f, _410);
              float _413 = _411 / _412;
              float _414 = 1.0f - _413;
              float _415 = _414 * (User_000.UserConstant_Z_000[9].w);
              float _416 = _415 + _413;
              float _417 = _414 * _414;
              float _418 = _417 * _414;
              float _419 = _418 - _414;
              float _420 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _421 = _410 * _410;
              float _422 = _421 * _420;
              float _423 = _422 * _419;
              float _424 = _416 + _423;
              _426 = _424;
            }
          }
        }
      }
      float _427 = saturate(_426);
      bool _428 = !(_302 <= (User_000.UserConstant_Z_000[4].x));
      if (!_428) {
        float _430 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _431 = _302 / _430;
        float _432 = _431 * (User_000.UserConstant_Z_000[4].y);
        float _433 = _431 * _431;
        float _434 = _433 * _431;
        float _435 = _434 - _431;
        float _436 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _437 = _430 * _430;
        float _438 = _437 * _436;
        float _439 = _438 * _435;
        float _440 = _439 + _432;
        _530 = _440;
      } else {
        bool _442 = !(_302 <= (User_000.UserConstant_Z_000[4].z));
        if (!_442) {
          float _444 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _445 = max(9.999999974752427e-07f, _444);
          float _446 = _302 - (User_000.UserConstant_Z_000[4].x);
          float _447 = _446 / _445;
          float _448 = 1.0f - _447;
          float _449 = _448 * (User_000.UserConstant_Z_000[4].y);
          float _450 = _447 * (User_000.UserConstant_Z_000[4].w);
          float _451 = _449 + _450;
          float _452 = _448 * _448;
          float _453 = _452 * _448;
          float _454 = _453 - _448;
          float _455 = _454 * (User_000.UserConstant_Z_000[10].x);
          float _456 = _447 * _447;
          float _457 = _456 * _447;
          float _458 = _457 - _447;
          float _459 = _458 * (User_000.UserConstant_Z_000[10].y);
          float _460 = _455 + _459;
          float _461 = _445 * _445;
          float _462 = _461 * 0.1666666716337204f;
          float _463 = _462 * _460;
          float _464 = _451 + _463;
          _530 = _464;
        } else {
          bool _466 = !(_302 <= (User_000.UserConstant_Z_000[9].x));
          if (!_466) {
            float _468 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _469 = max(9.999999974752427e-07f, _468);
            float _470 = _302 - (User_000.UserConstant_Z_000[4].z);
            float _471 = _470 / _469;
            float _472 = 1.0f - _471;
            float _473 = _472 * (User_000.UserConstant_Z_000[4].w);
            float _474 = _471 * (User_000.UserConstant_Z_000[9].y);
            float _475 = _473 + _474;
            float _476 = _472 * _472;
            float _477 = _476 * _472;
            float _478 = _477 - _472;
            float _479 = _478 * (User_000.UserConstant_Z_000[10].y);
            float _480 = _471 * _471;
            float _481 = _480 * _471;
            float _482 = _481 - _471;
            float _483 = _482 * (User_000.UserConstant_Z_000[10].z);
            float _484 = _479 + _483;
            float _485 = _469 * _469;
            float _486 = _485 * 0.1666666716337204f;
            float _487 = _486 * _484;
            float _488 = _475 + _487;
            _530 = _488;
          } else {
            bool _490 = !(_302 <= (User_000.UserConstant_Z_000[9].z));
            if (!_490) {
              float _492 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _493 = max(9.999999974752427e-07f, _492);
              float _494 = _302 - (User_000.UserConstant_Z_000[9].x);
              float _495 = _494 / _493;
              float _496 = 1.0f - _495;
              float _497 = _496 * (User_000.UserConstant_Z_000[9].y);
              float _498 = _495 * (User_000.UserConstant_Z_000[9].w);
              float _499 = _497 + _498;
              float _500 = _496 * _496;
              float _501 = _500 * _496;
              float _502 = _501 - _496;
              float _503 = _502 * (User_000.UserConstant_Z_000[10].z);
              float _504 = _495 * _495;
              float _505 = _504 * _495;
              float _506 = _505 - _495;
              float _507 = _506 * (User_000.UserConstant_Z_000[10].w);
              float _508 = _503 + _507;
              float _509 = _493 * _493;
              float _510 = _509 * 0.1666666716337204f;
              float _511 = _510 * _508;
              float _512 = _499 + _511;
              _530 = _512;
            } else {
              float _514 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _515 = _302 - (User_000.UserConstant_Z_000[9].z);
              float _516 = max(9.999999974752427e-07f, _514);
              float _517 = _515 / _516;
              float _518 = 1.0f - _517;
              float _519 = _518 * (User_000.UserConstant_Z_000[9].w);
              float _520 = _519 + _517;
              float _521 = _518 * _518;
              float _522 = _521 * _518;
              float _523 = _522 - _518;
              float _524 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _525 = _514 * _514;
              float _526 = _525 * _524;
              float _527 = _526 * _523;
              float _528 = _520 + _527;
              _530 = _528;
            }
          }
        }
      }
      float _531 = saturate(_530);
      bool _532 = !(_303 <= (User_000.UserConstant_Z_000[4].x));
      if (!_532) {
        float _534 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _535 = _303 / _534;
        float _536 = _535 * (User_000.UserConstant_Z_000[4].y);
        float _537 = _535 * _535;
        float _538 = _537 * _535;
        float _539 = _538 - _535;
        float _540 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _541 = _534 * _534;
        float _542 = _541 * _540;
        float _543 = _542 * _539;
        float _544 = _543 + _536;
        _634 = _544;
      } else {
        bool _546 = !(_303 <= (User_000.UserConstant_Z_000[4].z));
        if (!_546) {
          float _548 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _549 = max(9.999999974752427e-07f, _548);
          float _550 = _303 - (User_000.UserConstant_Z_000[4].x);
          float _551 = _550 / _549;
          float _552 = 1.0f - _551;
          float _553 = _552 * (User_000.UserConstant_Z_000[4].y);
          float _554 = _551 * (User_000.UserConstant_Z_000[4].w);
          float _555 = _553 + _554;
          float _556 = _552 * _552;
          float _557 = _556 * _552;
          float _558 = _557 - _552;
          float _559 = _558 * (User_000.UserConstant_Z_000[10].x);
          float _560 = _551 * _551;
          float _561 = _560 * _551;
          float _562 = _561 - _551;
          float _563 = _562 * (User_000.UserConstant_Z_000[10].y);
          float _564 = _559 + _563;
          float _565 = _549 * _549;
          float _566 = _565 * 0.1666666716337204f;
          float _567 = _566 * _564;
          float _568 = _555 + _567;
          _634 = _568;
        } else {
          bool _570 = !(_303 <= (User_000.UserConstant_Z_000[9].x));
          if (!_570) {
            float _572 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _573 = max(9.999999974752427e-07f, _572);
            float _574 = _303 - (User_000.UserConstant_Z_000[4].z);
            float _575 = _574 / _573;
            float _576 = 1.0f - _575;
            float _577 = _576 * (User_000.UserConstant_Z_000[4].w);
            float _578 = _575 * (User_000.UserConstant_Z_000[9].y);
            float _579 = _577 + _578;
            float _580 = _576 * _576;
            float _581 = _580 * _576;
            float _582 = _581 - _576;
            float _583 = _582 * (User_000.UserConstant_Z_000[10].y);
            float _584 = _575 * _575;
            float _585 = _584 * _575;
            float _586 = _585 - _575;
            float _587 = _586 * (User_000.UserConstant_Z_000[10].z);
            float _588 = _583 + _587;
            float _589 = _573 * _573;
            float _590 = _589 * 0.1666666716337204f;
            float _591 = _590 * _588;
            float _592 = _579 + _591;
            _634 = _592;
          } else {
            bool _594 = !(_303 <= (User_000.UserConstant_Z_000[9].z));
            if (!_594) {
              float _596 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _597 = max(9.999999974752427e-07f, _596);
              float _598 = _303 - (User_000.UserConstant_Z_000[9].x);
              float _599 = _598 / _597;
              float _600 = 1.0f - _599;
              float _601 = _600 * (User_000.UserConstant_Z_000[9].y);
              float _602 = _599 * (User_000.UserConstant_Z_000[9].w);
              float _603 = _601 + _602;
              float _604 = _600 * _600;
              float _605 = _604 * _600;
              float _606 = _605 - _600;
              float _607 = _606 * (User_000.UserConstant_Z_000[10].z);
              float _608 = _599 * _599;
              float _609 = _608 * _599;
              float _610 = _609 - _599;
              float _611 = _610 * (User_000.UserConstant_Z_000[10].w);
              float _612 = _607 + _611;
              float _613 = _597 * _597;
              float _614 = _613 * 0.1666666716337204f;
              float _615 = _614 * _612;
              float _616 = _603 + _615;
              _634 = _616;
            } else {
              float _618 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _619 = _303 - (User_000.UserConstant_Z_000[9].z);
              float _620 = max(9.999999974752427e-07f, _618);
              float _621 = _619 / _620;
              float _622 = 1.0f - _621;
              float _623 = _622 * (User_000.UserConstant_Z_000[9].w);
              float _624 = _623 + _621;
              float _625 = _622 * _622;
              float _626 = _625 * _622;
              float _627 = _626 - _622;
              float _628 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _629 = _618 * _618;
              float _630 = _629 * _628;
              float _631 = _630 * _627;
              float _632 = _624 + _631;
              _634 = _632;
            }
          }
        }
      }
      float _635 = saturate(_634);
      _637 = _427;
      _638 = _531;
      _639 = _635;
    } else {
      _637 = _301;
      _638 = _302;
      _639 = _303;
    }
    int _640 = _305 & 2;
    bool _641 = (_640 == 0);
    if (!_641) {
      float _643 = sqrt(_637);
      float _644 = sqrt(_638);
      float _645 = sqrt(_639);
      float _646 = dot(float3(_643, _644, _645), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _647 = 1.0f - _646;
      float _648 = saturate(_647);
      _650 = _648;
    } else {
      _650 = 1.0f;
    }
    int _651 = _305 & 8;
    bool _652 = (_651 == 0);
    if (_652) {
      int _654 = _305 & 4;
      bool _655 = (_654 == 0);
      if (!_655) {
        int _657 = _305 & 16;
        bool _658 = (_657 == 0);
        if (!_658) {
          float _662 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _663 = _662 + 0.5f;
          bool _664 = (_663 < 0.5f);
          float _665 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _666 = select(_664, (User_000.UserConstant_Z_000[5].x), _665);
          bool _667 = (_638 < _639);
          float _668 = select(_667, _639, _638);
          float _669 = select(_667, _638, _639);
          bool _670 = (_637 < _668);
          float _671 = select(_670, _668, _637);
          float _672 = select(_670, _637, _668);
          float _673 = min(_672, _669);
          float _674 = _671 - _673;
          float _675 = _671 + 1.000000013351432e-10f;
          float _676 = _674 / _675;
          float _678 = _676 - (User_000.UserConstant_Z_000[5].y);
          float _679 = saturate(_678);
          float _680 = max(_679, 9.999999974752427e-07f);
          float _681 = log2(_680);
          float _682 = _681 * _666;
          float _683 = exp2(_682);
          float _684 = 2.0f - _683;
          float _686 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _687 = saturate(_686);
          float _688 = max(_687, _684);
          float _689 = dot(float3(_637, _638, _639), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _690 = _637 - _689;
          float _691 = _638 - _689;
          float _692 = _639 - _689;
          float _693 = _690 * _688;
          float _694 = _691 * _688;
          float _695 = _692 * _688;
          float _696 = _689 - _637;
          float _697 = _696 + _693;
          float _698 = _689 - _638;
          float _699 = _698 + _694;
          float _700 = _689 - _639;
          float _701 = _700 + _695;
          float _702 = _697 * _650;
          float _703 = _699 * _650;
          float _704 = _701 * _650;
          float _705 = _702 + _637;
          float _706 = _703 + _638;
          float _707 = _704 + _639;
          _824 = _705;
          _825 = _706;
          _826 = _707;
        } else {
          bool _709 = (_650 == 0.0f);
          if (!_709) {
            float _713 = abs(User_000.UserConstant_Z_000[5].x);
            float _714 = saturate(_713);
            uint4 _716 = 0u; t15.GetDimensions(0u, _716.x, _716.y, _716.w);
            float _719 = float((uint)_716.y);
            int _720 = _305 & 32;
            bool _721 = (_720 == 0);
            float _722 = _719 + -1.0f;
            if (!_721) {
              float _724 = 1.0f / _722;
              uint _725 = uint(SV_Position.x);
              uint _726 = uint(SV_Position.y);
              int _727 = _725 & 63;
              int _728 = _726 & 63;
              float4 _730 = t2.Load(int4(_727, _728, 0, 0));
              float _733 = _730.x + -0.5f;
              float _734 = _637 * 13.999999046325684f;
              float _735 = _638 * 13.999999046325684f;
              float _736 = _639 * 13.999999046325684f;
              float _737 = saturate(_734);
              float _738 = saturate(_735);
              float _739 = saturate(_736);
              float _740 = _637 + -0.9285714030265808f;
              float _741 = _638 + -0.9285714030265808f;
              float _742 = _639 + -0.9285714030265808f;
              float _743 = _740 * 13.999999046325684f;
              float _744 = _741 * 13.999999046325684f;
              float _745 = _742 * 13.999999046325684f;
              float _746 = saturate(_743);
              float _747 = saturate(_744);
              float _748 = saturate(_745);
              float _749 = 1.0f - _746;
              float _750 = 1.0f - _747;
              float _751 = 1.0f - _748;
              float _752 = min(_737, _749);
              float _753 = min(_738, _750);
              float _754 = min(_739, _751);
              float _755 = _730.y + -0.5f;
              float _756 = _752 * _755;
              float _757 = _753 * _755;
              float _758 = _754 * _755;
              float _759 = _756 + _733;
              float _760 = _757 + _733;
              float _761 = _758 + _733;
              float _762 = _759 * _724;
              float _763 = _760 * _724;
              float _764 = _761 * _724;
              float _765 = _762 + _637;
              float _766 = _763 + _638;
              float _767 = _764 + _639;
              float _768 = saturate(_765);
              float _769 = saturate(_766);
              float _770 = saturate(_767);
              float _771 = saturate(_768);
              float _772 = saturate(_769);
              float _773 = saturate(_770);
              _775 = _771;
              _776 = _772;
              _777 = _773;
            } else {
              _775 = _637;
              _776 = _638;
              _777 = _639;
            }
            float _778 = float((uint)_716.x);
            float _779 = _722 / _778;
            float _780 = _779 * _775;
            float _781 = 0.5f / _778;
            float _782 = _780 + _781;
            float _783 = _722 / _719;
            float _784 = _783 * _776;
            float _785 = 0.5f / _719;
            float _786 = _784 + _785;
            float _787 = _777 * _722;
            float _788 = floor(_787);
            float _789 = frac(_787);
            float _790 = _788 / _719;
            float _791 = _790 + _782;
            float _792 = _788 + 1.0f;
            float _793 = _792 / _719;
            float _794 = _793 + _782;
            float4 _796 = t15.Sample(s0, float2(_791, _786));
            float4 _800 = t15.Sample(s0, float2(_794, _786));
            float _804 = _800.x - _796.x;
            float _805 = _800.y - _796.y;
            float _806 = _800.z - _796.z;
            float _807 = _804 * _789;
            float _808 = _805 * _789;
            float _809 = _806 * _789;
            float _810 = _714 * _650;
            float _811 = _796.x - _637;
            float _812 = _811 + _807;
            float _813 = _796.y - _638;
            float _814 = _813 + _808;
            float _815 = _796.z - _639;
            float _816 = _815 + _809;
            float _817 = _812 * _810;
            float _818 = _814 * _810;
            float _819 = _816 * _810;
            float _820 = _817 + _637;
            float _821 = _818 + _638;
            float _822 = _819 + _639;
            _824 = _820;
            _825 = _821;
            _826 = _822;
          } else {
            _824 = _637;
            _825 = _638;
            _826 = _639;
          }
        }
      } else {
        _824 = _637;
        _825 = _638;
        _826 = _639;
      }
    } else {
      _824 = _650;
      _825 = _650;
      _826 = _650;
    }
    float _827 = _824 * 13.450128555297852f;
    float _828 = _825 * 13.450128555297852f;
    float _829 = _826 * 13.450128555297852f;
    float _830 = exp2(_827);
    float _831 = exp2(_828);
    float _832 = exp2(_829);
    float _833 = _830 + -1.0f;
    float _834 = _831 + -1.0f;
    float _835 = _832 + -1.0f;
    float _836 = _833 * _283;
    float _837 = _834 * _283;
    float _838 = _835 * _283;
    _840 = _836;
    _841 = _837;
    _842 = _838;
  } else {
    _840 = _284;
    _841 = _285;
    _842 = _286;
  }
  float _847 = (User_000.UserConstant_Z_000[8].x) * _840;
  float _848 = (User_000.UserConstant_Z_000[8].y) * _841;
  float _849 = (User_000.UserConstant_Z_000[8].z) * _842;
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3(_847, _848, _849),
      SV_Position.xy);
  float _854 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _855 = _854 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _856 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _857 = _856 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _860 = _855 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _861 = _857 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _864 = t9.Sample(s9, float2(_860, _861));
  float _868 = dot(float3(_847, _848, _849), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _871 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _874 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _875 = select(_871, _874, 0);
  float _876 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _877 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _878 = uint(_876);
  uint _879 = uint(_877);
  int _880 = _878 & 63;
  int _881 = _879 & 63;
  float4 _883 = t2.Load(int4(_880, _881, _875, 0));
  bool _885 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_885) {
    float _887 = _876 * 0.015625f;
    float _888 = _877 * 0.015625f;
    float _889 = float((uint)_874);
    float _890 = select(_871, _889, 0.0f);
    float4 _892 = t2.SampleLevel(s1, float3(_887, _888, _890), 0.0f);
    float _894 = _883.y - _892.y;
    float _895 = _894 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _896 = _895 + _892.y;
    _898 = _896;
  } else {
    _898 = _883.y;
  }
  float _899 = _864.x * -2.0f;
  float _900 = _899 * _898;
  float _901 = _898 * 2.0f;
  float _902 = _901 * _864.y;
  float _903 = _901 * _864.z;
  float _904 = _900 + _864.x;
  float _905 = _902 - _864.y;
  float _906 = _903 - _864.z;
  float _907 = _904 * _864.x;
  float _908 = _905 * _864.y;
  float _909 = _906 * _864.z;
  float _910 = _868 + 1.0f;
  float _911 = _868 / _910;
  float _912 = _911 + -9.999999747378752e-05f;
  float _913 = _912 * 1111.111083984375f;
  float _914 = saturate(_913);
  float _915 = _914 * 2.0f;
  float _916 = 3.0f - _915;
  float _917 = _914 * _914;
  float _918 = _917 * _916;
  bool _920 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _921 = float((bool)_920);
  float _922 = dot(float3(_907, _908, _909), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _923 = _922 - _907;
  float _924 = _922 - _908;
  float _925 = _922 - _909;
  float _926 = _923 * _921;
  float _927 = _924 * _921;
  float _928 = _925 * _921;
  float _929 = _926 + _907;
  float _930 = _927 + _908;
  float _931 = _928 + _909;
  float _935 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _936 = _935 * _911;
  float _937 = _936 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _938 = _918 * _937;
  float _939 = _938 * _929;
  float _940 = _938 * _930;
  float _941 = _938 * _931;
  float _942 = _939 + _847;
  float _943 = _940 + _848;
  float _944 = _941 + _849;
  float _945 = max(0.0f, _942);
  float _946 = max(0.0f, _943);
  float _947 = max(0.0f, _944);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_945, _946, _947),
      apt_perceptual_film_grain);
  _945 = apt_film_grain_output.x;
  _946 = apt_film_grain_output.y;
  _947 = apt_film_grain_output.z;
  float _950 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _951 = log2(_945);
  float _952 = _950 * _951;
  float _953 = exp2(_952);
  float _954 = _953 + -1.0f;
  float _955 = _945 + -1.0f;
  float _956 = _954 / _955;
  bool _957 = !(_945 == 1.0f);
  float _958 = _956 + -1.0f;
  float _959 = _958 / _956;
  float _960 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _961 = _960 / _950;
  float _962 = select(_957, _959, _961);
  float _963 = log2(_946);
  float _964 = _963 * _950;
  float _965 = exp2(_964);
  float _966 = _965 + -1.0f;
  float _967 = _946 + -1.0f;
  float _968 = _966 / _967;
  bool _969 = !(_946 == 1.0f);
  float _970 = _968 + -1.0f;
  float _971 = _970 / _968;
  float _972 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _973 = _972 / _950;
  float _974 = select(_969, _971, _973);
  float _975 = log2(_947);
  float _976 = _975 * _950;
  float _977 = exp2(_976);
  float _978 = _977 + -1.0f;
  float _979 = _947 + -1.0f;
  float _980 = _978 / _979;
  bool _981 = !(_947 == 1.0f);
  float _982 = _980 + -1.0f;
  float _983 = _982 / _980;
  float _984 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _985 = _984 / _950;
  float _986 = select(_981, _983, _985);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_945, _946, _947),
      float3(_962, _974, _986),
      true);
  float _987 = apt_post_process_output.x;
  float _988 = apt_post_process_output.y;
  float _989 = apt_post_process_output.z;
  float _990 = log2(_987);
  float _991 = log2(_988);
  float _992 = log2(_989);
  float _993 = _990 * 0.4166666567325592f;
  float _994 = _991 * 0.4166666567325592f;
  float _995 = _992 * 0.4166666567325592f;
  float _996 = exp2(_993);
  float _997 = exp2(_994);
  float _998 = exp2(_995);
  float _999 = _996 * 1.0549999475479126f;
  float _1000 = _997 * 1.0549999475479126f;
  float _1001 = _998 * 1.0549999475479126f;
  float _1002 = _999 + -0.054999999701976776f;
  float _1003 = _1000 + -0.054999999701976776f;
  float _1004 = _1001 + -0.054999999701976776f;
  float _1005 = _987 * 12.920000076293945f;
  float _1006 = _988 * 12.920000076293945f;
  float _1007 = _989 * 12.920000076293945f;
  bool _1008 = (_987 <= 0.0031308000907301903f);
  bool _1009 = (_988 <= 0.0031308000907301903f);
  bool _1010 = (_989 <= 0.0031308000907301903f);
  float _1011 = select(_1008, _1005, _1002);
  float _1012 = select(_1009, _1006, _1003);
  float _1013 = select(_1010, _1007, _1004);
  uint _1014 = uint(SV_Position.x);
  uint _1015 = uint(SV_Position.y);
  int _1016 = _1014 & 63;
  int _1017 = _1015 & 63;
  float4 _1019 = t1.Load(int4(_1016, _1017, _874, 0));
  float _1021 = _1019.x + -0.5f;
  float _1022 = _1021 * 0.003921568859368563f;
  float _1023 = _1022 + _1011;
  float _1024 = _1022 + _1012;
  float _1025 = _1022 + _1013;
  float _1026 = saturate(_1023);
  float _1027 = saturate(_1024);
  float _1028 = saturate(_1025);
  SV_Target.x = _1026;
  SV_Target.y = _1027;
  SV_Target.z = _1028;
  SV_Target.w = _130.w;
  return SV_Target;
}
