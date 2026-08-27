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
  int _146 = asint((User_000.UserConstant_Z_000[7].z));
  bool _147 = ((int)_146 > (int)0);
  float _176;
  float _177;
  float _178;
  float _183;
  float _184;
  float _185;
  float _214;
  float _215;
  float _216;
  float _221;
  float _222;
  float _223;
  float _458;
  float _562;
  float _666;
  float _669;
  float _670;
  float _671;
  float _682;
  float _807;
  float _808;
  float _809;
  float _856;
  float _857;
  float _858;
  float _872;
  float _873;
  float _874;
  if (!_147) {
    bool _151 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _155 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _140.x;
    float _156 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _140.y;
    float _157 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _140.z;
    float _158 = _155 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _159 = _156 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _160 = _157 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_151) {
      float _162 = _158 * _134.x;
      float _163 = _159 * _134.y;
      float _164 = _160 * _134.z;
      _176 = _162;
      _177 = _163;
      _178 = _164;
    } else {
      float _166 = saturate(_158);
      float _167 = saturate(_159);
      float _168 = saturate(_160);
      float _169 = _134.x - _130;
      float _170 = _134.y - _131;
      float _171 = _134.z - _132;
      float _172 = _166 * _169;
      float _173 = _167 * _170;
      float _174 = _168 * _171;
      _176 = _172;
      _177 = _173;
      _178 = _174;
    }
    float _179 = _176 + _130;
    float _180 = _177 + _131;
    float _181 = _178 + _132;
    _183 = _179;
    _184 = _180;
    _185 = _181;
  } else {
    _183 = _130;
    _184 = _131;
    _185 = _132;
  }
  if (_147) {
    bool _189 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _193 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _140.x;
    float _194 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _140.y;
    float _195 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _140.z;
    float _196 = _193 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _197 = _194 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _198 = _195 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_189) {
      float _200 = _196 * _134.x;
      float _201 = _197 * _134.y;
      float _202 = _198 * _134.z;
      _214 = _200;
      _215 = _201;
      _216 = _202;
    } else {
      float _204 = saturate(_196);
      float _205 = saturate(_197);
      float _206 = saturate(_198);
      float _207 = _134.x - _183;
      float _208 = _134.y - _184;
      float _209 = _134.z - _185;
      float _210 = _204 * _207;
      float _211 = _205 * _208;
      float _212 = _206 * _209;
      _214 = _210;
      _215 = _211;
      _216 = _212;
    }
    float _217 = _214 + _183;
    float _218 = _215 + _184;
    float _219 = _216 + _185;
    _221 = _217;
    _222 = _218;
    _223 = _219;
  } else {
    _221 = _183;
    _222 = _184;
    _223 = _185;
  }
  float4 _227 = t17.Load(int3(0, 0, 0));
  float _233 = _227.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _234 = _233 * _221;
  float _235 = _234 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _236 = _233 * _222;
  float _237 = _236 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _238 = _233 * _223;
  float _239 = _238 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _244 = _49 * 2.0f;
  float _245 = _50 * 2.0f;
  float _246 = _244 + -1.0f;
  float _247 = _245 + -1.0f;
  float _250 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _247;
  float _251 = _246 * _246;
  float _252 = _250 * _250;
  float _253 = _252 + _251;
  float _254 = sqrt(_253);
  float _256 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _254;
  float _258 = _256 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _259 = saturate(_258);
  float _261 = log2(_259);
  float _262 = _261 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _263 = exp2(_262);
  float _264 = _235 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _265 = _237 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _266 = _239 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _267 = _264 - _235;
  float _268 = _265 - _237;
  float _269 = _266 - _239;
  float _270 = _263 * _267;
  float _271 = _263 * _268;
  float _272 = _263 * _269;
  float _273 = _270 + _235;
  float _274 = _271 + _237;
  float _275 = _272 + _239;
  float _278 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _279 = _278 * _273;
  float _280 = _278 * _274;
  float _281 = _278 * _275;
  float _282 = _279 + 1.0f;
  float _283 = _280 + 1.0f;
  float _284 = _281 + 1.0f;
  float _285 = log2(_282);
  float _286 = log2(_283);
  float _287 = log2(_284);
  float _290 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _291 = _290 * _285;
  float _292 = _290 * _286;
  float _293 = _290 * _287;
  float _295 = _291 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _296 = _292 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _297 = _293 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _300 = t3.Sample(s3, float3(_295, _296, _297));
  float _306 = _300.x * 13.450128555297852f;
  float _307 = _300.y * 13.450128555297852f;
  float _308 = _300.z * 13.450128555297852f;
  float _309 = exp2(_306);
  float _310 = exp2(_307);
  float _311 = exp2(_308);
  float _312 = _309 + -1.0f;
  float _313 = _310 + -1.0f;
  float _314 = _311 + -1.0f;
  float _315 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _316 = _315 * _312;
  float _317 = _315 * _313;
  float _318 = _315 * _314;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_279 * _315, _280 * _315, _281 * _315),
      float3(_316, _317, _318),
      1.f.xxx);
  _316 = apt_scaled_lut_output.x;
  _317 = apt_scaled_lut_output.y;
  _318 = apt_scaled_lut_output.z;
  bool _321 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !APTIsPsychoV();
  if (_321) {
    float _323 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _324 = _316 * _323;
    float _325 = _317 * _323;
    float _326 = _318 * _323;
    float _327 = _324 + 1.0f;
    float _328 = _325 + 1.0f;
    float _329 = _326 + 1.0f;
    float _330 = log2(_327);
    float _331 = log2(_328);
    float _332 = log2(_329);
    float _333 = _330 * 0.07434873282909393f;
    float _334 = _331 * 0.07434873282909393f;
    float _335 = _332 * 0.07434873282909393f;
    int _337 = asint((User_000.UserConstant_Z_000[3].y));
    int _338 = _337 & 1;
    bool _339 = (_338 == 0);
    if (!_339) {
      bool _356 = !(_333 <= (User_000.UserConstant_Z_000[4].x));
      if (!_356) {
        float _358 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _359 = _333 / _358;
        float _360 = _359 * (User_000.UserConstant_Z_000[4].y);
        float _361 = _359 * _359;
        float _362 = _361 * _359;
        float _363 = _362 - _359;
        float _364 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _365 = _358 * _358;
        float _366 = _365 * _364;
        float _367 = _366 * _363;
        float _368 = _367 + _360;
        _458 = _368;
      } else {
        bool _370 = !(_333 <= (User_000.UserConstant_Z_000[4].z));
        if (!_370) {
          float _372 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _373 = max(9.999999974752427e-07f, _372);
          float _374 = _333 - (User_000.UserConstant_Z_000[4].x);
          float _375 = _374 / _373;
          float _376 = 1.0f - _375;
          float _377 = _376 * (User_000.UserConstant_Z_000[4].y);
          float _378 = _375 * (User_000.UserConstant_Z_000[4].w);
          float _379 = _377 + _378;
          float _380 = _376 * _376;
          float _381 = _380 * _376;
          float _382 = _381 - _376;
          float _383 = _382 * (User_000.UserConstant_Z_000[10].x);
          float _384 = _375 * _375;
          float _385 = _384 * _375;
          float _386 = _385 - _375;
          float _387 = _386 * (User_000.UserConstant_Z_000[10].y);
          float _388 = _383 + _387;
          float _389 = _373 * _373;
          float _390 = _389 * 0.1666666716337204f;
          float _391 = _390 * _388;
          float _392 = _379 + _391;
          _458 = _392;
        } else {
          bool _394 = !(_333 <= (User_000.UserConstant_Z_000[9].x));
          if (!_394) {
            float _396 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _397 = max(9.999999974752427e-07f, _396);
            float _398 = _333 - (User_000.UserConstant_Z_000[4].z);
            float _399 = _398 / _397;
            float _400 = 1.0f - _399;
            float _401 = _400 * (User_000.UserConstant_Z_000[4].w);
            float _402 = _399 * (User_000.UserConstant_Z_000[9].y);
            float _403 = _401 + _402;
            float _404 = _400 * _400;
            float _405 = _404 * _400;
            float _406 = _405 - _400;
            float _407 = _406 * (User_000.UserConstant_Z_000[10].y);
            float _408 = _399 * _399;
            float _409 = _408 * _399;
            float _410 = _409 - _399;
            float _411 = _410 * (User_000.UserConstant_Z_000[10].z);
            float _412 = _407 + _411;
            float _413 = _397 * _397;
            float _414 = _413 * 0.1666666716337204f;
            float _415 = _414 * _412;
            float _416 = _403 + _415;
            _458 = _416;
          } else {
            bool _418 = !(_333 <= (User_000.UserConstant_Z_000[9].z));
            if (!_418) {
              float _420 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _421 = max(9.999999974752427e-07f, _420);
              float _422 = _333 - (User_000.UserConstant_Z_000[9].x);
              float _423 = _422 / _421;
              float _424 = 1.0f - _423;
              float _425 = _424 * (User_000.UserConstant_Z_000[9].y);
              float _426 = _423 * (User_000.UserConstant_Z_000[9].w);
              float _427 = _425 + _426;
              float _428 = _424 * _424;
              float _429 = _428 * _424;
              float _430 = _429 - _424;
              float _431 = _430 * (User_000.UserConstant_Z_000[10].z);
              float _432 = _423 * _423;
              float _433 = _432 * _423;
              float _434 = _433 - _423;
              float _435 = _434 * (User_000.UserConstant_Z_000[10].w);
              float _436 = _431 + _435;
              float _437 = _421 * _421;
              float _438 = _437 * 0.1666666716337204f;
              float _439 = _438 * _436;
              float _440 = _427 + _439;
              _458 = _440;
            } else {
              float _442 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _443 = _333 - (User_000.UserConstant_Z_000[9].z);
              float _444 = max(9.999999974752427e-07f, _442);
              float _445 = _443 / _444;
              float _446 = 1.0f - _445;
              float _447 = _446 * (User_000.UserConstant_Z_000[9].w);
              float _448 = _447 + _445;
              float _449 = _446 * _446;
              float _450 = _449 * _446;
              float _451 = _450 - _446;
              float _452 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _453 = _442 * _442;
              float _454 = _453 * _452;
              float _455 = _454 * _451;
              float _456 = _448 + _455;
              _458 = _456;
            }
          }
        }
      }
      float _459 = saturate(_458);
      bool _460 = !(_334 <= (User_000.UserConstant_Z_000[4].x));
      if (!_460) {
        float _462 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _463 = _334 / _462;
        float _464 = _463 * (User_000.UserConstant_Z_000[4].y);
        float _465 = _463 * _463;
        float _466 = _465 * _463;
        float _467 = _466 - _463;
        float _468 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _469 = _462 * _462;
        float _470 = _469 * _468;
        float _471 = _470 * _467;
        float _472 = _471 + _464;
        _562 = _472;
      } else {
        bool _474 = !(_334 <= (User_000.UserConstant_Z_000[4].z));
        if (!_474) {
          float _476 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _477 = max(9.999999974752427e-07f, _476);
          float _478 = _334 - (User_000.UserConstant_Z_000[4].x);
          float _479 = _478 / _477;
          float _480 = 1.0f - _479;
          float _481 = _480 * (User_000.UserConstant_Z_000[4].y);
          float _482 = _479 * (User_000.UserConstant_Z_000[4].w);
          float _483 = _481 + _482;
          float _484 = _480 * _480;
          float _485 = _484 * _480;
          float _486 = _485 - _480;
          float _487 = _486 * (User_000.UserConstant_Z_000[10].x);
          float _488 = _479 * _479;
          float _489 = _488 * _479;
          float _490 = _489 - _479;
          float _491 = _490 * (User_000.UserConstant_Z_000[10].y);
          float _492 = _487 + _491;
          float _493 = _477 * _477;
          float _494 = _493 * 0.1666666716337204f;
          float _495 = _494 * _492;
          float _496 = _483 + _495;
          _562 = _496;
        } else {
          bool _498 = !(_334 <= (User_000.UserConstant_Z_000[9].x));
          if (!_498) {
            float _500 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _501 = max(9.999999974752427e-07f, _500);
            float _502 = _334 - (User_000.UserConstant_Z_000[4].z);
            float _503 = _502 / _501;
            float _504 = 1.0f - _503;
            float _505 = _504 * (User_000.UserConstant_Z_000[4].w);
            float _506 = _503 * (User_000.UserConstant_Z_000[9].y);
            float _507 = _505 + _506;
            float _508 = _504 * _504;
            float _509 = _508 * _504;
            float _510 = _509 - _504;
            float _511 = _510 * (User_000.UserConstant_Z_000[10].y);
            float _512 = _503 * _503;
            float _513 = _512 * _503;
            float _514 = _513 - _503;
            float _515 = _514 * (User_000.UserConstant_Z_000[10].z);
            float _516 = _511 + _515;
            float _517 = _501 * _501;
            float _518 = _517 * 0.1666666716337204f;
            float _519 = _518 * _516;
            float _520 = _507 + _519;
            _562 = _520;
          } else {
            bool _522 = !(_334 <= (User_000.UserConstant_Z_000[9].z));
            if (!_522) {
              float _524 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _525 = max(9.999999974752427e-07f, _524);
              float _526 = _334 - (User_000.UserConstant_Z_000[9].x);
              float _527 = _526 / _525;
              float _528 = 1.0f - _527;
              float _529 = _528 * (User_000.UserConstant_Z_000[9].y);
              float _530 = _527 * (User_000.UserConstant_Z_000[9].w);
              float _531 = _529 + _530;
              float _532 = _528 * _528;
              float _533 = _532 * _528;
              float _534 = _533 - _528;
              float _535 = _534 * (User_000.UserConstant_Z_000[10].z);
              float _536 = _527 * _527;
              float _537 = _536 * _527;
              float _538 = _537 - _527;
              float _539 = _538 * (User_000.UserConstant_Z_000[10].w);
              float _540 = _535 + _539;
              float _541 = _525 * _525;
              float _542 = _541 * 0.1666666716337204f;
              float _543 = _542 * _540;
              float _544 = _531 + _543;
              _562 = _544;
            } else {
              float _546 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _547 = _334 - (User_000.UserConstant_Z_000[9].z);
              float _548 = max(9.999999974752427e-07f, _546);
              float _549 = _547 / _548;
              float _550 = 1.0f - _549;
              float _551 = _550 * (User_000.UserConstant_Z_000[9].w);
              float _552 = _551 + _549;
              float _553 = _550 * _550;
              float _554 = _553 * _550;
              float _555 = _554 - _550;
              float _556 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _557 = _546 * _546;
              float _558 = _557 * _556;
              float _559 = _558 * _555;
              float _560 = _552 + _559;
              _562 = _560;
            }
          }
        }
      }
      float _563 = saturate(_562);
      bool _564 = !(_335 <= (User_000.UserConstant_Z_000[4].x));
      if (!_564) {
        float _566 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _567 = _335 / _566;
        float _568 = _567 * (User_000.UserConstant_Z_000[4].y);
        float _569 = _567 * _567;
        float _570 = _569 * _567;
        float _571 = _570 - _567;
        float _572 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _573 = _566 * _566;
        float _574 = _573 * _572;
        float _575 = _574 * _571;
        float _576 = _575 + _568;
        _666 = _576;
      } else {
        bool _578 = !(_335 <= (User_000.UserConstant_Z_000[4].z));
        if (!_578) {
          float _580 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _581 = max(9.999999974752427e-07f, _580);
          float _582 = _335 - (User_000.UserConstant_Z_000[4].x);
          float _583 = _582 / _581;
          float _584 = 1.0f - _583;
          float _585 = _584 * (User_000.UserConstant_Z_000[4].y);
          float _586 = _583 * (User_000.UserConstant_Z_000[4].w);
          float _587 = _585 + _586;
          float _588 = _584 * _584;
          float _589 = _588 * _584;
          float _590 = _589 - _584;
          float _591 = _590 * (User_000.UserConstant_Z_000[10].x);
          float _592 = _583 * _583;
          float _593 = _592 * _583;
          float _594 = _593 - _583;
          float _595 = _594 * (User_000.UserConstant_Z_000[10].y);
          float _596 = _591 + _595;
          float _597 = _581 * _581;
          float _598 = _597 * 0.1666666716337204f;
          float _599 = _598 * _596;
          float _600 = _587 + _599;
          _666 = _600;
        } else {
          bool _602 = !(_335 <= (User_000.UserConstant_Z_000[9].x));
          if (!_602) {
            float _604 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _605 = max(9.999999974752427e-07f, _604);
            float _606 = _335 - (User_000.UserConstant_Z_000[4].z);
            float _607 = _606 / _605;
            float _608 = 1.0f - _607;
            float _609 = _608 * (User_000.UserConstant_Z_000[4].w);
            float _610 = _607 * (User_000.UserConstant_Z_000[9].y);
            float _611 = _609 + _610;
            float _612 = _608 * _608;
            float _613 = _612 * _608;
            float _614 = _613 - _608;
            float _615 = _614 * (User_000.UserConstant_Z_000[10].y);
            float _616 = _607 * _607;
            float _617 = _616 * _607;
            float _618 = _617 - _607;
            float _619 = _618 * (User_000.UserConstant_Z_000[10].z);
            float _620 = _615 + _619;
            float _621 = _605 * _605;
            float _622 = _621 * 0.1666666716337204f;
            float _623 = _622 * _620;
            float _624 = _611 + _623;
            _666 = _624;
          } else {
            bool _626 = !(_335 <= (User_000.UserConstant_Z_000[9].z));
            if (!_626) {
              float _628 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _629 = max(9.999999974752427e-07f, _628);
              float _630 = _335 - (User_000.UserConstant_Z_000[9].x);
              float _631 = _630 / _629;
              float _632 = 1.0f - _631;
              float _633 = _632 * (User_000.UserConstant_Z_000[9].y);
              float _634 = _631 * (User_000.UserConstant_Z_000[9].w);
              float _635 = _633 + _634;
              float _636 = _632 * _632;
              float _637 = _636 * _632;
              float _638 = _637 - _632;
              float _639 = _638 * (User_000.UserConstant_Z_000[10].z);
              float _640 = _631 * _631;
              float _641 = _640 * _631;
              float _642 = _641 - _631;
              float _643 = _642 * (User_000.UserConstant_Z_000[10].w);
              float _644 = _639 + _643;
              float _645 = _629 * _629;
              float _646 = _645 * 0.1666666716337204f;
              float _647 = _646 * _644;
              float _648 = _635 + _647;
              _666 = _648;
            } else {
              float _650 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _651 = _335 - (User_000.UserConstant_Z_000[9].z);
              float _652 = max(9.999999974752427e-07f, _650);
              float _653 = _651 / _652;
              float _654 = 1.0f - _653;
              float _655 = _654 * (User_000.UserConstant_Z_000[9].w);
              float _656 = _655 + _653;
              float _657 = _654 * _654;
              float _658 = _657 * _654;
              float _659 = _658 - _654;
              float _660 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _661 = _650 * _650;
              float _662 = _661 * _660;
              float _663 = _662 * _659;
              float _664 = _656 + _663;
              _666 = _664;
            }
          }
        }
      }
      float _667 = saturate(_666);
      _669 = _459;
      _670 = _563;
      _671 = _667;
    } else {
      _669 = _333;
      _670 = _334;
      _671 = _335;
    }
    int _672 = _337 & 2;
    bool _673 = (_672 == 0);
    if (!_673) {
      float _675 = sqrt(_669);
      float _676 = sqrt(_670);
      float _677 = sqrt(_671);
      float _678 = dot(float3(_675, _676, _677), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _679 = 1.0f - _678;
      float _680 = saturate(_679);
      _682 = _680;
    } else {
      _682 = 1.0f;
    }
    int _683 = _337 & 8;
    bool _684 = (_683 == 0);
    if (_684) {
      int _686 = _337 & 4;
      bool _687 = (_686 == 0);
      if (!_687) {
        int _689 = _337 & 16;
        bool _690 = (_689 == 0);
        if (!_690) {
          float _694 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _695 = _694 + 0.5f;
          bool _696 = (_695 < 0.5f);
          float _697 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _698 = select(_696, (User_000.UserConstant_Z_000[5].x), _697);
          bool _699 = (_670 < _671);
          float _700 = select(_699, _671, _670);
          float _701 = select(_699, _670, _671);
          bool _702 = (_669 < _700);
          float _703 = select(_702, _700, _669);
          float _704 = select(_702, _669, _700);
          float _705 = min(_704, _701);
          float _706 = _703 - _705;
          float _707 = _703 + 1.000000013351432e-10f;
          float _708 = _706 / _707;
          float _710 = _708 - (User_000.UserConstant_Z_000[5].y);
          float _711 = saturate(_710);
          float _712 = max(_711, 9.999999974752427e-07f);
          float _713 = log2(_712);
          float _714 = _713 * _698;
          float _715 = exp2(_714);
          float _716 = 2.0f - _715;
          float _718 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _719 = saturate(_718);
          float _720 = max(_719, _716);
          float _721 = dot(float3(_669, _670, _671), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _722 = _669 - _721;
          float _723 = _670 - _721;
          float _724 = _671 - _721;
          float _725 = _722 * _720;
          float _726 = _723 * _720;
          float _727 = _724 * _720;
          float _728 = _721 - _669;
          float _729 = _728 + _725;
          float _730 = _721 - _670;
          float _731 = _730 + _726;
          float _732 = _721 - _671;
          float _733 = _732 + _727;
          float _734 = _729 * _682;
          float _735 = _731 * _682;
          float _736 = _733 * _682;
          float _737 = _734 + _669;
          float _738 = _735 + _670;
          float _739 = _736 + _671;
          _856 = _737;
          _857 = _738;
          _858 = _739;
        } else {
          bool _741 = (_682 == 0.0f);
          if (!_741) {
            float _745 = abs(User_000.UserConstant_Z_000[5].x);
            float _746 = saturate(_745);
            uint4 _748 = 0u; t15.GetDimensions(0u, _748.x, _748.y, _748.w);
            float _751 = float((uint)_748.y);
            int _752 = _337 & 32;
            bool _753 = (_752 == 0);
            float _754 = _751 + -1.0f;
            if (!_753) {
              float _756 = 1.0f / _754;
              uint _757 = uint(SV_Position.x);
              uint _758 = uint(SV_Position.y);
              int _759 = _757 & 63;
              int _760 = _758 & 63;
              float4 _762 = t2.Load(int4(_759, _760, 0, 0));
              float _765 = _762.x + -0.5f;
              float _766 = _669 * 13.999999046325684f;
              float _767 = _670 * 13.999999046325684f;
              float _768 = _671 * 13.999999046325684f;
              float _769 = saturate(_766);
              float _770 = saturate(_767);
              float _771 = saturate(_768);
              float _772 = _669 + -0.9285714030265808f;
              float _773 = _670 + -0.9285714030265808f;
              float _774 = _671 + -0.9285714030265808f;
              float _775 = _772 * 13.999999046325684f;
              float _776 = _773 * 13.999999046325684f;
              float _777 = _774 * 13.999999046325684f;
              float _778 = saturate(_775);
              float _779 = saturate(_776);
              float _780 = saturate(_777);
              float _781 = 1.0f - _778;
              float _782 = 1.0f - _779;
              float _783 = 1.0f - _780;
              float _784 = min(_769, _781);
              float _785 = min(_770, _782);
              float _786 = min(_771, _783);
              float _787 = _762.y + -0.5f;
              float _788 = _784 * _787;
              float _789 = _785 * _787;
              float _790 = _786 * _787;
              float _791 = _788 + _765;
              float _792 = _789 + _765;
              float _793 = _790 + _765;
              float _794 = _791 * _756;
              float _795 = _792 * _756;
              float _796 = _793 * _756;
              float _797 = _794 + _669;
              float _798 = _795 + _670;
              float _799 = _796 + _671;
              float _800 = saturate(_797);
              float _801 = saturate(_798);
              float _802 = saturate(_799);
              float _803 = saturate(_800);
              float _804 = saturate(_801);
              float _805 = saturate(_802);
              _807 = _803;
              _808 = _804;
              _809 = _805;
            } else {
              _807 = _669;
              _808 = _670;
              _809 = _671;
            }
            float _810 = float((uint)_748.x);
            float _811 = _754 / _810;
            float _812 = _811 * _807;
            float _813 = 0.5f / _810;
            float _814 = _812 + _813;
            float _815 = _754 / _751;
            float _816 = _815 * _808;
            float _817 = 0.5f / _751;
            float _818 = _816 + _817;
            float _819 = _809 * _754;
            float _820 = floor(_819);
            float _821 = frac(_819);
            float _822 = _820 / _751;
            float _823 = _822 + _814;
            float _824 = _820 + 1.0f;
            float _825 = _824 / _751;
            float _826 = _825 + _814;
            float4 _828 = t15.Sample(s0, float2(_823, _818));
            float4 _832 = t15.Sample(s0, float2(_826, _818));
            float _836 = _832.x - _828.x;
            float _837 = _832.y - _828.y;
            float _838 = _832.z - _828.z;
            float _839 = _836 * _821;
            float _840 = _837 * _821;
            float _841 = _838 * _821;
            float _842 = _746 * _682;
            float _843 = _828.x - _669;
            float _844 = _843 + _839;
            float _845 = _828.y - _670;
            float _846 = _845 + _840;
            float _847 = _828.z - _671;
            float _848 = _847 + _841;
            float _849 = _844 * _842;
            float _850 = _846 * _842;
            float _851 = _848 * _842;
            float _852 = _849 + _669;
            float _853 = _850 + _670;
            float _854 = _851 + _671;
            _856 = _852;
            _857 = _853;
            _858 = _854;
          } else {
            _856 = _669;
            _857 = _670;
            _858 = _671;
          }
        }
      } else {
        _856 = _669;
        _857 = _670;
        _858 = _671;
      }
    } else {
      _856 = _682;
      _857 = _682;
      _858 = _682;
    }
    float _859 = _856 * 13.450128555297852f;
    float _860 = _857 * 13.450128555297852f;
    float _861 = _858 * 13.450128555297852f;
    float _862 = exp2(_859);
    float _863 = exp2(_860);
    float _864 = exp2(_861);
    float _865 = _862 + -1.0f;
    float _866 = _863 + -1.0f;
    float _867 = _864 + -1.0f;
    float _868 = _865 * _315;
    float _869 = _866 * _315;
    float _870 = _867 * _315;
    _872 = _868;
    _873 = _869;
    _874 = _870;
  } else {
    _872 = _316;
    _873 = _317;
    _874 = _318;
  }
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _872, (User_000.UserConstant_Z_000[8].y) * _873, (User_000.UserConstant_Z_000[8].z) * _874),
      SV_Position.xy);
  float _881 = apt_perceptual_film_grain.x;
  float _882 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _883 = log2(_881);
  float _884 = _882 * _883;
  float _885 = exp2(_884);
  float _886 = _885 + -1.0f;
  float _887 = _881 + -1.0f;
  float _888 = _886 / _887;
  bool _889 = !(_881 == 1.0f);
  float _890 = _888 + -1.0f;
  float _891 = _890 / _888;
  float _892 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _893 = _892 / _882;
  float _894 = select(_889, _891, _893);
  float _895 = apt_perceptual_film_grain.y;
  float _896 = log2(_895);
  float _897 = _896 * _882;
  float _898 = exp2(_897);
  float _899 = _898 + -1.0f;
  float _900 = _895 + -1.0f;
  float _901 = _899 / _900;
  bool _902 = !(_895 == 1.0f);
  float _903 = _901 + -1.0f;
  float _904 = _903 / _901;
  float _905 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _906 = _905 / _882;
  float _907 = select(_902, _904, _906);
  float _908 = apt_perceptual_film_grain.z;
  float _909 = log2(_908);
  float _910 = _909 * _882;
  float _911 = exp2(_910);
  float _912 = _911 + -1.0f;
  float _913 = _908 + -1.0f;
  float _914 = _912 / _913;
  bool _915 = !(_908 == 1.0f);
  float _916 = _914 + -1.0f;
  float _917 = _916 / _914;
  float _918 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _919 = _918 / _882;
  float _920 = select(_915, _917, _919);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_881, _895, _908),
      float3(_894, _907, _920),
      true);
  float _921 = apt_post_process_output.x;
  float _922 = apt_post_process_output.y;
  float _923 = apt_post_process_output.z;
  float _924 = log2(_921);
  float _925 = log2(_922);
  float _926 = log2(_923);
  float _927 = _924 * 0.4166666567325592f;
  float _928 = _925 * 0.4166666567325592f;
  float _929 = _926 * 0.4166666567325592f;
  float _930 = exp2(_927);
  float _931 = exp2(_928);
  float _932 = exp2(_929);
  float _933 = _930 * 1.0549999475479126f;
  float _934 = _931 * 1.0549999475479126f;
  float _935 = _932 * 1.0549999475479126f;
  float _936 = _933 + -0.054999999701976776f;
  float _937 = _934 + -0.054999999701976776f;
  float _938 = _935 + -0.054999999701976776f;
  float _939 = _921 * 12.920000076293945f;
  float _940 = _922 * 12.920000076293945f;
  float _941 = _923 * 12.920000076293945f;
  bool _942 = (_921 <= 0.0031308000907301903f);
  bool _943 = (_922 <= 0.0031308000907301903f);
  bool _944 = (_923 <= 0.0031308000907301903f);
  float _945 = select(_942, _939, _936);
  float _946 = select(_943, _940, _937);
  float _947 = select(_944, _941, _938);
  int _950 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _951 = uint(SV_Position.x);
  uint _952 = uint(SV_Position.y);
  int _953 = _951 & 63;
  int _954 = _952 & 63;
  float4 _956 = t1.Load(int4(_953, _954, _950, 0));
  float _958 = _956.x + -0.5f;
  float _959 = _958 * 0.003921568859368563f;
  float _960 = _959 + _945;
  float _961 = _959 + _946;
  float _962 = _959 + _947;
  float _963 = saturate(_960);
  float _964 = saturate(_961);
  float _965 = saturate(_962);
  SV_Target.x = _963;
  SV_Target.y = _964;
  SV_Target.z = _965;
  SV_Target.w = _127.w;
  return SV_Target;
}
