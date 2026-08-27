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
  float GlobalCB_Z__GlobalConstant_Z_1692;
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
  float _379;
  float _483;
  float _587;
  float _590;
  float _591;
  float _592;
  float _603;
  float _728;
  float _729;
  float _730;
  float _777;
  float _778;
  float _779;
  float _793;
  float _794;
  float _795;
  float _851;
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
  float _191 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _192 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _193 = _183.x * _192;
  float _194 = _193 * _177;
  float _195 = _194 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _196 = _195 * _191;
  float _197 = _193 * _178;
  float _198 = _197 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _199 = _198 * _191;
  float _200 = _193 * _179;
  float _201 = _200 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _202 = _201 * _191;
  float _203 = _196 + 1.0f;
  float _204 = _199 + 1.0f;
  float _205 = _202 + 1.0f;
  float _206 = log2(_203);
  float _207 = log2(_204);
  float _208 = log2(_205);
  float _211 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _212 = _211 * _206;
  float _213 = _211 * _207;
  float _214 = _211 * _208;
  float _216 = _212 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _217 = _213 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _218 = _214 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _221 = t3.Sample(s3, float3(_216, _217, _218));
  float _227 = _221.x * 13.450128555297852f;
  float _228 = _221.y * 13.450128555297852f;
  float _229 = _221.z * 13.450128555297852f;
  float _230 = exp2(_227);
  float _231 = exp2(_228);
  float _232 = exp2(_229);
  float _233 = _230 + -1.0f;
  float _234 = _231 + -1.0f;
  float _235 = _232 + -1.0f;
  float _236 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _237 = _236 * _233;
  float _238 = _236 * _234;
  float _239 = _236 * _235;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_196 * _236, _199 * _236, _202 * _236),
      float3(_237, _238, _239),
      1.f.xxx);
  _237 = apt_scaled_lut_output.x;
  _238 = apt_scaled_lut_output.y;
  _239 = apt_scaled_lut_output.z;
  bool _242 = ((User_000.UserConstant_Z_000[3].x) > 0.0f);
  if (_242) {
    float _244 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _245 = _237 * _244;
    float _246 = _238 * _244;
    float _247 = _239 * _244;
    float _248 = _245 + 1.0f;
    float _249 = _246 + 1.0f;
    float _250 = _247 + 1.0f;
    float _251 = log2(_248);
    float _252 = log2(_249);
    float _253 = log2(_250);
    float _254 = _251 * 0.07434873282909393f;
    float _255 = _252 * 0.07434873282909393f;
    float _256 = _253 * 0.07434873282909393f;
    int _258 = asint((User_000.UserConstant_Z_000[3].y));
    int _259 = _258 & 1;
    bool _260 = (_259 == 0);
    if (!_260) {
      bool _277 = !(_254 <= (User_000.UserConstant_Z_000[4].x));
      if (!_277) {
        float _279 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _280 = _254 / _279;
        float _281 = _280 * (User_000.UserConstant_Z_000[4].y);
        float _282 = _280 * _280;
        float _283 = _282 * _280;
        float _284 = _283 - _280;
        float _285 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _286 = _279 * _279;
        float _287 = _286 * _285;
        float _288 = _287 * _284;
        float _289 = _288 + _281;
        _379 = _289;
      } else {
        bool _291 = !(_254 <= (User_000.UserConstant_Z_000[4].z));
        if (!_291) {
          float _293 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _294 = max(9.999999974752427e-07f, _293);
          float _295 = _254 - (User_000.UserConstant_Z_000[4].x);
          float _296 = _295 / _294;
          float _297 = 1.0f - _296;
          float _298 = _297 * (User_000.UserConstant_Z_000[4].y);
          float _299 = _296 * (User_000.UserConstant_Z_000[4].w);
          float _300 = _298 + _299;
          float _301 = _297 * _297;
          float _302 = _301 * _297;
          float _303 = _302 - _297;
          float _304 = _303 * (User_000.UserConstant_Z_000[10].x);
          float _305 = _296 * _296;
          float _306 = _305 * _296;
          float _307 = _306 - _296;
          float _308 = _307 * (User_000.UserConstant_Z_000[10].y);
          float _309 = _304 + _308;
          float _310 = _294 * _294;
          float _311 = _310 * 0.1666666716337204f;
          float _312 = _311 * _309;
          float _313 = _300 + _312;
          _379 = _313;
        } else {
          bool _315 = !(_254 <= (User_000.UserConstant_Z_000[9].x));
          if (!_315) {
            float _317 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _318 = max(9.999999974752427e-07f, _317);
            float _319 = _254 - (User_000.UserConstant_Z_000[4].z);
            float _320 = _319 / _318;
            float _321 = 1.0f - _320;
            float _322 = _321 * (User_000.UserConstant_Z_000[4].w);
            float _323 = _320 * (User_000.UserConstant_Z_000[9].y);
            float _324 = _322 + _323;
            float _325 = _321 * _321;
            float _326 = _325 * _321;
            float _327 = _326 - _321;
            float _328 = _327 * (User_000.UserConstant_Z_000[10].y);
            float _329 = _320 * _320;
            float _330 = _329 * _320;
            float _331 = _330 - _320;
            float _332 = _331 * (User_000.UserConstant_Z_000[10].z);
            float _333 = _328 + _332;
            float _334 = _318 * _318;
            float _335 = _334 * 0.1666666716337204f;
            float _336 = _335 * _333;
            float _337 = _324 + _336;
            _379 = _337;
          } else {
            bool _339 = !(_254 <= (User_000.UserConstant_Z_000[9].z));
            if (!_339) {
              float _341 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _342 = max(9.999999974752427e-07f, _341);
              float _343 = _254 - (User_000.UserConstant_Z_000[9].x);
              float _344 = _343 / _342;
              float _345 = 1.0f - _344;
              float _346 = _345 * (User_000.UserConstant_Z_000[9].y);
              float _347 = _344 * (User_000.UserConstant_Z_000[9].w);
              float _348 = _346 + _347;
              float _349 = _345 * _345;
              float _350 = _349 * _345;
              float _351 = _350 - _345;
              float _352 = _351 * (User_000.UserConstant_Z_000[10].z);
              float _353 = _344 * _344;
              float _354 = _353 * _344;
              float _355 = _354 - _344;
              float _356 = _355 * (User_000.UserConstant_Z_000[10].w);
              float _357 = _352 + _356;
              float _358 = _342 * _342;
              float _359 = _358 * 0.1666666716337204f;
              float _360 = _359 * _357;
              float _361 = _348 + _360;
              _379 = _361;
            } else {
              float _363 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _364 = _254 - (User_000.UserConstant_Z_000[9].z);
              float _365 = max(9.999999974752427e-07f, _363);
              float _366 = _364 / _365;
              float _367 = 1.0f - _366;
              float _368 = _367 * (User_000.UserConstant_Z_000[9].w);
              float _369 = _368 + _366;
              float _370 = _367 * _367;
              float _371 = _370 * _367;
              float _372 = _371 - _367;
              float _373 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _374 = _363 * _363;
              float _375 = _374 * _373;
              float _376 = _375 * _372;
              float _377 = _369 + _376;
              _379 = _377;
            }
          }
        }
      }
      float _380 = saturate(_379);
      bool _381 = !(_255 <= (User_000.UserConstant_Z_000[4].x));
      if (!_381) {
        float _383 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _384 = _255 / _383;
        float _385 = _384 * (User_000.UserConstant_Z_000[4].y);
        float _386 = _384 * _384;
        float _387 = _386 * _384;
        float _388 = _387 - _384;
        float _389 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _390 = _383 * _383;
        float _391 = _390 * _389;
        float _392 = _391 * _388;
        float _393 = _392 + _385;
        _483 = _393;
      } else {
        bool _395 = !(_255 <= (User_000.UserConstant_Z_000[4].z));
        if (!_395) {
          float _397 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _398 = max(9.999999974752427e-07f, _397);
          float _399 = _255 - (User_000.UserConstant_Z_000[4].x);
          float _400 = _399 / _398;
          float _401 = 1.0f - _400;
          float _402 = _401 * (User_000.UserConstant_Z_000[4].y);
          float _403 = _400 * (User_000.UserConstant_Z_000[4].w);
          float _404 = _402 + _403;
          float _405 = _401 * _401;
          float _406 = _405 * _401;
          float _407 = _406 - _401;
          float _408 = _407 * (User_000.UserConstant_Z_000[10].x);
          float _409 = _400 * _400;
          float _410 = _409 * _400;
          float _411 = _410 - _400;
          float _412 = _411 * (User_000.UserConstant_Z_000[10].y);
          float _413 = _408 + _412;
          float _414 = _398 * _398;
          float _415 = _414 * 0.1666666716337204f;
          float _416 = _415 * _413;
          float _417 = _404 + _416;
          _483 = _417;
        } else {
          bool _419 = !(_255 <= (User_000.UserConstant_Z_000[9].x));
          if (!_419) {
            float _421 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _422 = max(9.999999974752427e-07f, _421);
            float _423 = _255 - (User_000.UserConstant_Z_000[4].z);
            float _424 = _423 / _422;
            float _425 = 1.0f - _424;
            float _426 = _425 * (User_000.UserConstant_Z_000[4].w);
            float _427 = _424 * (User_000.UserConstant_Z_000[9].y);
            float _428 = _426 + _427;
            float _429 = _425 * _425;
            float _430 = _429 * _425;
            float _431 = _430 - _425;
            float _432 = _431 * (User_000.UserConstant_Z_000[10].y);
            float _433 = _424 * _424;
            float _434 = _433 * _424;
            float _435 = _434 - _424;
            float _436 = _435 * (User_000.UserConstant_Z_000[10].z);
            float _437 = _432 + _436;
            float _438 = _422 * _422;
            float _439 = _438 * 0.1666666716337204f;
            float _440 = _439 * _437;
            float _441 = _428 + _440;
            _483 = _441;
          } else {
            bool _443 = !(_255 <= (User_000.UserConstant_Z_000[9].z));
            if (!_443) {
              float _445 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _446 = max(9.999999974752427e-07f, _445);
              float _447 = _255 - (User_000.UserConstant_Z_000[9].x);
              float _448 = _447 / _446;
              float _449 = 1.0f - _448;
              float _450 = _449 * (User_000.UserConstant_Z_000[9].y);
              float _451 = _448 * (User_000.UserConstant_Z_000[9].w);
              float _452 = _450 + _451;
              float _453 = _449 * _449;
              float _454 = _453 * _449;
              float _455 = _454 - _449;
              float _456 = _455 * (User_000.UserConstant_Z_000[10].z);
              float _457 = _448 * _448;
              float _458 = _457 * _448;
              float _459 = _458 - _448;
              float _460 = _459 * (User_000.UserConstant_Z_000[10].w);
              float _461 = _456 + _460;
              float _462 = _446 * _446;
              float _463 = _462 * 0.1666666716337204f;
              float _464 = _463 * _461;
              float _465 = _452 + _464;
              _483 = _465;
            } else {
              float _467 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _468 = _255 - (User_000.UserConstant_Z_000[9].z);
              float _469 = max(9.999999974752427e-07f, _467);
              float _470 = _468 / _469;
              float _471 = 1.0f - _470;
              float _472 = _471 * (User_000.UserConstant_Z_000[9].w);
              float _473 = _472 + _470;
              float _474 = _471 * _471;
              float _475 = _474 * _471;
              float _476 = _475 - _471;
              float _477 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _478 = _467 * _467;
              float _479 = _478 * _477;
              float _480 = _479 * _476;
              float _481 = _473 + _480;
              _483 = _481;
            }
          }
        }
      }
      float _484 = saturate(_483);
      bool _485 = !(_256 <= (User_000.UserConstant_Z_000[4].x));
      if (!_485) {
        float _487 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _488 = _256 / _487;
        float _489 = _488 * (User_000.UserConstant_Z_000[4].y);
        float _490 = _488 * _488;
        float _491 = _490 * _488;
        float _492 = _491 - _488;
        float _493 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _494 = _487 * _487;
        float _495 = _494 * _493;
        float _496 = _495 * _492;
        float _497 = _496 + _489;
        _587 = _497;
      } else {
        bool _499 = !(_256 <= (User_000.UserConstant_Z_000[4].z));
        if (!_499) {
          float _501 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _502 = max(9.999999974752427e-07f, _501);
          float _503 = _256 - (User_000.UserConstant_Z_000[4].x);
          float _504 = _503 / _502;
          float _505 = 1.0f - _504;
          float _506 = _505 * (User_000.UserConstant_Z_000[4].y);
          float _507 = _504 * (User_000.UserConstant_Z_000[4].w);
          float _508 = _506 + _507;
          float _509 = _505 * _505;
          float _510 = _509 * _505;
          float _511 = _510 - _505;
          float _512 = _511 * (User_000.UserConstant_Z_000[10].x);
          float _513 = _504 * _504;
          float _514 = _513 * _504;
          float _515 = _514 - _504;
          float _516 = _515 * (User_000.UserConstant_Z_000[10].y);
          float _517 = _512 + _516;
          float _518 = _502 * _502;
          float _519 = _518 * 0.1666666716337204f;
          float _520 = _519 * _517;
          float _521 = _508 + _520;
          _587 = _521;
        } else {
          bool _523 = !(_256 <= (User_000.UserConstant_Z_000[9].x));
          if (!_523) {
            float _525 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _526 = max(9.999999974752427e-07f, _525);
            float _527 = _256 - (User_000.UserConstant_Z_000[4].z);
            float _528 = _527 / _526;
            float _529 = 1.0f - _528;
            float _530 = _529 * (User_000.UserConstant_Z_000[4].w);
            float _531 = _528 * (User_000.UserConstant_Z_000[9].y);
            float _532 = _530 + _531;
            float _533 = _529 * _529;
            float _534 = _533 * _529;
            float _535 = _534 - _529;
            float _536 = _535 * (User_000.UserConstant_Z_000[10].y);
            float _537 = _528 * _528;
            float _538 = _537 * _528;
            float _539 = _538 - _528;
            float _540 = _539 * (User_000.UserConstant_Z_000[10].z);
            float _541 = _536 + _540;
            float _542 = _526 * _526;
            float _543 = _542 * 0.1666666716337204f;
            float _544 = _543 * _541;
            float _545 = _532 + _544;
            _587 = _545;
          } else {
            bool _547 = !(_256 <= (User_000.UserConstant_Z_000[9].z));
            if (!_547) {
              float _549 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _550 = max(9.999999974752427e-07f, _549);
              float _551 = _256 - (User_000.UserConstant_Z_000[9].x);
              float _552 = _551 / _550;
              float _553 = 1.0f - _552;
              float _554 = _553 * (User_000.UserConstant_Z_000[9].y);
              float _555 = _552 * (User_000.UserConstant_Z_000[9].w);
              float _556 = _554 + _555;
              float _557 = _553 * _553;
              float _558 = _557 * _553;
              float _559 = _558 - _553;
              float _560 = _559 * (User_000.UserConstant_Z_000[10].z);
              float _561 = _552 * _552;
              float _562 = _561 * _552;
              float _563 = _562 - _552;
              float _564 = _563 * (User_000.UserConstant_Z_000[10].w);
              float _565 = _560 + _564;
              float _566 = _550 * _550;
              float _567 = _566 * 0.1666666716337204f;
              float _568 = _567 * _565;
              float _569 = _556 + _568;
              _587 = _569;
            } else {
              float _571 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _572 = _256 - (User_000.UserConstant_Z_000[9].z);
              float _573 = max(9.999999974752427e-07f, _571);
              float _574 = _572 / _573;
              float _575 = 1.0f - _574;
              float _576 = _575 * (User_000.UserConstant_Z_000[9].w);
              float _577 = _576 + _574;
              float _578 = _575 * _575;
              float _579 = _578 * _575;
              float _580 = _579 - _575;
              float _581 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _582 = _571 * _571;
              float _583 = _582 * _581;
              float _584 = _583 * _580;
              float _585 = _577 + _584;
              _587 = _585;
            }
          }
        }
      }
      float _588 = saturate(_587);
      _590 = _380;
      _591 = _484;
      _592 = _588;
    } else {
      _590 = _254;
      _591 = _255;
      _592 = _256;
    }
    int _593 = _258 & 2;
    bool _594 = (_593 == 0);
    if (!_594) {
      float _596 = sqrt(_590);
      float _597 = sqrt(_591);
      float _598 = sqrt(_592);
      float _599 = dot(float3(_596, _597, _598), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _600 = 1.0f - _599;
      float _601 = saturate(_600);
      _603 = _601;
    } else {
      _603 = 1.0f;
    }
    int _604 = _258 & 8;
    bool _605 = (_604 == 0);
    if (_605) {
      int _607 = _258 & 4;
      bool _608 = (_607 == 0);
      if (!_608) {
        int _610 = _258 & 16;
        bool _611 = (_610 == 0);
        if (!_611) {
          float _615 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _616 = _615 + 0.5f;
          bool _617 = (_616 < 0.5f);
          float _618 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _619 = select(_617, (User_000.UserConstant_Z_000[5].x), _618);
          bool _620 = (_591 < _592);
          float _621 = select(_620, _592, _591);
          float _622 = select(_620, _591, _592);
          bool _623 = (_590 < _621);
          float _624 = select(_623, _621, _590);
          float _625 = select(_623, _590, _621);
          float _626 = min(_625, _622);
          float _627 = _624 - _626;
          float _628 = _624 + 1.000000013351432e-10f;
          float _629 = _627 / _628;
          float _631 = _629 - (User_000.UserConstant_Z_000[5].y);
          float _632 = saturate(_631);
          float _633 = max(_632, 9.999999974752427e-07f);
          float _634 = log2(_633);
          float _635 = _634 * _619;
          float _636 = exp2(_635);
          float _637 = 2.0f - _636;
          float _639 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _640 = saturate(_639);
          float _641 = max(_640, _637);
          float _642 = dot(float3(_590, _591, _592), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _643 = _590 - _642;
          float _644 = _591 - _642;
          float _645 = _592 - _642;
          float _646 = _643 * _641;
          float _647 = _644 * _641;
          float _648 = _645 * _641;
          float _649 = _642 - _590;
          float _650 = _649 + _646;
          float _651 = _642 - _591;
          float _652 = _651 + _647;
          float _653 = _642 - _592;
          float _654 = _653 + _648;
          float _655 = _650 * _603;
          float _656 = _652 * _603;
          float _657 = _654 * _603;
          float _658 = _655 + _590;
          float _659 = _656 + _591;
          float _660 = _657 + _592;
          _777 = _658;
          _778 = _659;
          _779 = _660;
        } else {
          bool _662 = (_603 == 0.0f);
          if (!_662) {
            float _666 = abs(User_000.UserConstant_Z_000[5].x);
            float _667 = saturate(_666);
            uint4 _669 = 0u; t15.GetDimensions(0u, _669.x, _669.y, _669.w);
            float _672 = float((uint)_669.y);
            int _673 = _258 & 32;
            bool _674 = (_673 == 0);
            float _675 = _672 + -1.0f;
            if (!_674) {
              float _677 = 1.0f / _675;
              uint _678 = uint(SV_Position.x);
              uint _679 = uint(SV_Position.y);
              int _680 = _678 & 63;
              int _681 = _679 & 63;
              float4 _683 = t2.Load(int4(_680, _681, 0, 0));
              float _686 = _683.x + -0.5f;
              float _687 = _590 * 13.999999046325684f;
              float _688 = _591 * 13.999999046325684f;
              float _689 = _592 * 13.999999046325684f;
              float _690 = saturate(_687);
              float _691 = saturate(_688);
              float _692 = saturate(_689);
              float _693 = _590 + -0.9285714030265808f;
              float _694 = _591 + -0.9285714030265808f;
              float _695 = _592 + -0.9285714030265808f;
              float _696 = _693 * 13.999999046325684f;
              float _697 = _694 * 13.999999046325684f;
              float _698 = _695 * 13.999999046325684f;
              float _699 = saturate(_696);
              float _700 = saturate(_697);
              float _701 = saturate(_698);
              float _702 = 1.0f - _699;
              float _703 = 1.0f - _700;
              float _704 = 1.0f - _701;
              float _705 = min(_690, _702);
              float _706 = min(_691, _703);
              float _707 = min(_692, _704);
              float _708 = _683.y + -0.5f;
              float _709 = _705 * _708;
              float _710 = _706 * _708;
              float _711 = _707 * _708;
              float _712 = _709 + _686;
              float _713 = _710 + _686;
              float _714 = _711 + _686;
              float _715 = _712 * _677;
              float _716 = _713 * _677;
              float _717 = _714 * _677;
              float _718 = _715 + _590;
              float _719 = _716 + _591;
              float _720 = _717 + _592;
              float _721 = saturate(_718);
              float _722 = saturate(_719);
              float _723 = saturate(_720);
              float _724 = saturate(_721);
              float _725 = saturate(_722);
              float _726 = saturate(_723);
              _728 = _724;
              _729 = _725;
              _730 = _726;
            } else {
              _728 = _590;
              _729 = _591;
              _730 = _592;
            }
            float _731 = float((uint)_669.x);
            float _732 = _675 / _731;
            float _733 = _732 * _728;
            float _734 = 0.5f / _731;
            float _735 = _733 + _734;
            float _736 = _675 / _672;
            float _737 = _736 * _729;
            float _738 = 0.5f / _672;
            float _739 = _737 + _738;
            float _740 = _730 * _675;
            float _741 = floor(_740);
            float _742 = frac(_740);
            float _743 = _741 / _672;
            float _744 = _743 + _735;
            float _745 = _741 + 1.0f;
            float _746 = _745 / _672;
            float _747 = _746 + _735;
            float4 _749 = t15.Sample(s0, float2(_744, _739));
            float4 _753 = t15.Sample(s0, float2(_747, _739));
            float _757 = _753.x - _749.x;
            float _758 = _753.y - _749.y;
            float _759 = _753.z - _749.z;
            float _760 = _757 * _742;
            float _761 = _758 * _742;
            float _762 = _759 * _742;
            float _763 = _667 * _603;
            float _764 = _749.x - _590;
            float _765 = _764 + _760;
            float _766 = _749.y - _591;
            float _767 = _766 + _761;
            float _768 = _749.z - _592;
            float _769 = _768 + _762;
            float _770 = _765 * _763;
            float _771 = _767 * _763;
            float _772 = _769 * _763;
            float _773 = _770 + _590;
            float _774 = _771 + _591;
            float _775 = _772 + _592;
            _777 = _773;
            _778 = _774;
            _779 = _775;
          } else {
            _777 = _590;
            _778 = _591;
            _779 = _592;
          }
        }
      } else {
        _777 = _590;
        _778 = _591;
        _779 = _592;
      }
    } else {
      _777 = _603;
      _778 = _603;
      _779 = _603;
    }
    float _780 = _777 * 13.450128555297852f;
    float _781 = _778 * 13.450128555297852f;
    float _782 = _779 * 13.450128555297852f;
    float _783 = exp2(_780);
    float _784 = exp2(_781);
    float _785 = exp2(_782);
    float _786 = _783 + -1.0f;
    float _787 = _784 + -1.0f;
    float _788 = _785 + -1.0f;
    float _789 = _786 * _236;
    float _790 = _787 * _236;
    float _791 = _788 * _236;
    _793 = _789;
    _794 = _790;
    _795 = _791;
  } else {
    _793 = _237;
    _794 = _238;
    _795 = _239;
  }
  float _800 = (User_000.UserConstant_Z_000[8].x) * _793;
  float _801 = (User_000.UserConstant_Z_000[8].y) * _794;
  float _802 = (User_000.UserConstant_Z_000[8].z) * _795;
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3(_800, _801, _802),
      SV_Position.xy);
  float _807 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _808 = _807 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _809 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _810 = _809 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _813 = _808 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _814 = _810 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _817 = t9.Sample(s9, float2(_813, _814));
  float _821 = dot(float3(_800, _801, _802), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _824 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _827 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _828 = select(_824, _827, 0);
  float _829 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _830 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _831 = uint(_829);
  uint _832 = uint(_830);
  int _833 = _831 & 63;
  int _834 = _832 & 63;
  float4 _836 = t2.Load(int4(_833, _834, _828, 0));
  bool _838 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_838) {
    float _840 = _829 * 0.015625f;
    float _841 = _830 * 0.015625f;
    float _842 = float((uint)_827);
    float _843 = select(_824, _842, 0.0f);
    float4 _845 = t2.SampleLevel(s1, float3(_840, _841, _843), 0.0f);
    float _847 = _836.y - _845.y;
    float _848 = _847 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _849 = _848 + _845.y;
    _851 = _849;
  } else {
    _851 = _836.y;
  }
  float _852 = _817.x * -2.0f;
  float _853 = _852 * _851;
  float _854 = _851 * 2.0f;
  float _855 = _854 * _817.y;
  float _856 = _854 * _817.z;
  float _857 = _853 + _817.x;
  float _858 = _855 - _817.y;
  float _859 = _856 - _817.z;
  float _860 = _857 * _817.x;
  float _861 = _858 * _817.y;
  float _862 = _859 * _817.z;
  float _863 = _821 + 1.0f;
  float _864 = _821 / _863;
  float _865 = _864 + -9.999999747378752e-05f;
  float _866 = _865 * 1111.111083984375f;
  float _867 = saturate(_866);
  float _868 = _867 * 2.0f;
  float _869 = 3.0f - _868;
  float _870 = _867 * _867;
  float _871 = _870 * _869;
  bool _873 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _874 = float((bool)_873);
  float _875 = dot(float3(_860, _861, _862), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _876 = _875 - _860;
  float _877 = _875 - _861;
  float _878 = _875 - _862;
  float _879 = _876 * _874;
  float _880 = _877 * _874;
  float _881 = _878 * _874;
  float _882 = _879 + _860;
  float _883 = _880 + _861;
  float _884 = _881 + _862;
  float _888 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _889 = _888 * _864;
  float _890 = _889 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _891 = _871 * _890;
  float _892 = _891 * _882;
  float _893 = _891 * _883;
  float _894 = _891 * _884;
  float _895 = _892 + _800;
  float _896 = _893 + _801;
  float _897 = _894 + _802;
  float _898 = max(0.0f, _895);
  float _899 = max(0.0f, _896);
  float _900 = max(0.0f, _897);
  float3 apt_film_grain_output = APTSelectFilmGrainOutput(
      float3(_898, _899, _900),
      apt_perceptual_film_grain);
  _898 = apt_film_grain_output.x;
  _899 = apt_film_grain_output.y;
  _900 = apt_film_grain_output.z;
  float _903 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _904 = log2(_898);
  float _905 = _903 * _904;
  float _906 = exp2(_905);
  float _907 = _906 + -1.0f;
  float _908 = _898 + -1.0f;
  float _909 = _907 / _908;
  bool _910 = !(_898 == 1.0f);
  float _911 = _909 + -1.0f;
  float _912 = _911 / _909;
  float _913 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _914 = _913 / _903;
  float _915 = select(_910, _912, _914);
  float _916 = log2(_899);
  float _917 = _916 * _903;
  float _918 = exp2(_917);
  float _919 = _918 + -1.0f;
  float _920 = _899 + -1.0f;
  float _921 = _919 / _920;
  bool _922 = !(_899 == 1.0f);
  float _923 = _921 + -1.0f;
  float _924 = _923 / _921;
  float _925 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _926 = _925 / _903;
  float _927 = select(_922, _924, _926);
  float _928 = log2(_900);
  float _929 = _928 * _903;
  float _930 = exp2(_929);
  float _931 = _930 + -1.0f;
  float _932 = _900 + -1.0f;
  float _933 = _931 / _932;
  bool _934 = !(_900 == 1.0f);
  float _935 = _933 + -1.0f;
  float _936 = _935 / _933;
  float _937 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _938 = _937 / _903;
  float _939 = select(_934, _936, _938);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_898, _899, _900),
      float3(_915, _927, _939),
      true);
  float _940 = apt_post_process_output.x;
  float _941 = apt_post_process_output.y;
  float _942 = apt_post_process_output.z;
  float _943 = log2(_940);
  float _944 = log2(_941);
  float _945 = log2(_942);
  float _946 = _943 * 0.4166666567325592f;
  float _947 = _944 * 0.4166666567325592f;
  float _948 = _945 * 0.4166666567325592f;
  float _949 = exp2(_946);
  float _950 = exp2(_947);
  float _951 = exp2(_948);
  float _952 = _949 * 1.0549999475479126f;
  float _953 = _950 * 1.0549999475479126f;
  float _954 = _951 * 1.0549999475479126f;
  float _955 = _952 + -0.054999999701976776f;
  float _956 = _953 + -0.054999999701976776f;
  float _957 = _954 + -0.054999999701976776f;
  float _958 = _940 * 12.920000076293945f;
  float _959 = _941 * 12.920000076293945f;
  float _960 = _942 * 12.920000076293945f;
  bool _961 = (_940 <= 0.0031308000907301903f);
  bool _962 = (_941 <= 0.0031308000907301903f);
  bool _963 = (_942 <= 0.0031308000907301903f);
  float _964 = select(_961, _958, _955);
  float _965 = select(_962, _959, _956);
  float _966 = select(_963, _960, _957);
  uint _967 = uint(SV_Position.x);
  uint _968 = uint(SV_Position.y);
  int _969 = _967 & 63;
  int _970 = _968 & 63;
  float4 _972 = t1.Load(int4(_969, _970, _827, 0));
  float _974 = _972.x + -0.5f;
  float _975 = _974 * 0.003921568859368563f;
  float _976 = _975 + _964;
  float _977 = _975 + _965;
  float _978 = _975 + _966;
  float _979 = saturate(_976);
  float _980 = saturate(_977);
  float _981 = saturate(_978);
  SV_Target.x = _979;
  SV_Target.y = _980;
  SV_Target.z = _981;
  SV_Target.w = _130.w;
  return SV_Target;
}
