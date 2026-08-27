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
  float _423;
  float _527;
  float _631;
  float _634;
  float _635;
  float _636;
  float _647;
  float _772;
  float _773;
  float _774;
  float _821;
  float _822;
  float _823;
  float _837;
  float _838;
  float _839;
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
  float _235 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _236 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _237 = _227.x * _236;
  float _238 = _237 * _221;
  float _239 = _238 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _240 = _239 * _235;
  float _241 = _237 * _222;
  float _242 = _241 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _243 = _242 * _235;
  float _244 = _237 * _223;
  float _245 = _244 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _246 = _245 * _235;
  float _247 = _240 + 1.0f;
  float _248 = _243 + 1.0f;
  float _249 = _246 + 1.0f;
  float _250 = log2(_247);
  float _251 = log2(_248);
  float _252 = log2(_249);
  float _255 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _256 = _255 * _250;
  float _257 = _255 * _251;
  float _258 = _255 * _252;
  float _260 = _256 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _261 = _257 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _262 = _258 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _265 = t3.Sample(s3, float3(_260, _261, _262));
  float _271 = _265.x * 13.450128555297852f;
  float _272 = _265.y * 13.450128555297852f;
  float _273 = _265.z * 13.450128555297852f;
  float _274 = exp2(_271);
  float _275 = exp2(_272);
  float _276 = exp2(_273);
  float _277 = _274 + -1.0f;
  float _278 = _275 + -1.0f;
  float _279 = _276 + -1.0f;
  float _280 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _281 = _280 * _277;
  float _282 = _280 * _278;
  float _283 = _280 * _279;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_240 * _280, _243 * _280, _246 * _280),
      float3(_281, _282, _283),
      1.f.xxx);
  _281 = apt_scaled_lut_output.x;
  _282 = apt_scaled_lut_output.y;
  _283 = apt_scaled_lut_output.z;
  bool _286 = ((User_000.UserConstant_Z_000[3].x) > 0.0f);
  if (_286) {
    float _288 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _289 = _281 * _288;
    float _290 = _282 * _288;
    float _291 = _283 * _288;
    float _292 = _289 + 1.0f;
    float _293 = _290 + 1.0f;
    float _294 = _291 + 1.0f;
    float _295 = log2(_292);
    float _296 = log2(_293);
    float _297 = log2(_294);
    float _298 = _295 * 0.07434873282909393f;
    float _299 = _296 * 0.07434873282909393f;
    float _300 = _297 * 0.07434873282909393f;
    int _302 = asint((User_000.UserConstant_Z_000[3].y));
    int _303 = _302 & 1;
    bool _304 = (_303 == 0);
    if (!_304) {
      bool _321 = !(_298 <= (User_000.UserConstant_Z_000[4].x));
      if (!_321) {
        float _323 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _324 = _298 / _323;
        float _325 = _324 * (User_000.UserConstant_Z_000[4].y);
        float _326 = _324 * _324;
        float _327 = _326 * _324;
        float _328 = _327 - _324;
        float _329 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _330 = _323 * _323;
        float _331 = _330 * _329;
        float _332 = _331 * _328;
        float _333 = _332 + _325;
        _423 = _333;
      } else {
        bool _335 = !(_298 <= (User_000.UserConstant_Z_000[4].z));
        if (!_335) {
          float _337 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _338 = max(9.999999974752427e-07f, _337);
          float _339 = _298 - (User_000.UserConstant_Z_000[4].x);
          float _340 = _339 / _338;
          float _341 = 1.0f - _340;
          float _342 = _341 * (User_000.UserConstant_Z_000[4].y);
          float _343 = _340 * (User_000.UserConstant_Z_000[4].w);
          float _344 = _342 + _343;
          float _345 = _341 * _341;
          float _346 = _345 * _341;
          float _347 = _346 - _341;
          float _348 = _347 * (User_000.UserConstant_Z_000[10].x);
          float _349 = _340 * _340;
          float _350 = _349 * _340;
          float _351 = _350 - _340;
          float _352 = _351 * (User_000.UserConstant_Z_000[10].y);
          float _353 = _348 + _352;
          float _354 = _338 * _338;
          float _355 = _354 * 0.1666666716337204f;
          float _356 = _355 * _353;
          float _357 = _344 + _356;
          _423 = _357;
        } else {
          bool _359 = !(_298 <= (User_000.UserConstant_Z_000[9].x));
          if (!_359) {
            float _361 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _362 = max(9.999999974752427e-07f, _361);
            float _363 = _298 - (User_000.UserConstant_Z_000[4].z);
            float _364 = _363 / _362;
            float _365 = 1.0f - _364;
            float _366 = _365 * (User_000.UserConstant_Z_000[4].w);
            float _367 = _364 * (User_000.UserConstant_Z_000[9].y);
            float _368 = _366 + _367;
            float _369 = _365 * _365;
            float _370 = _369 * _365;
            float _371 = _370 - _365;
            float _372 = _371 * (User_000.UserConstant_Z_000[10].y);
            float _373 = _364 * _364;
            float _374 = _373 * _364;
            float _375 = _374 - _364;
            float _376 = _375 * (User_000.UserConstant_Z_000[10].z);
            float _377 = _372 + _376;
            float _378 = _362 * _362;
            float _379 = _378 * 0.1666666716337204f;
            float _380 = _379 * _377;
            float _381 = _368 + _380;
            _423 = _381;
          } else {
            bool _383 = !(_298 <= (User_000.UserConstant_Z_000[9].z));
            if (!_383) {
              float _385 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _386 = max(9.999999974752427e-07f, _385);
              float _387 = _298 - (User_000.UserConstant_Z_000[9].x);
              float _388 = _387 / _386;
              float _389 = 1.0f - _388;
              float _390 = _389 * (User_000.UserConstant_Z_000[9].y);
              float _391 = _388 * (User_000.UserConstant_Z_000[9].w);
              float _392 = _390 + _391;
              float _393 = _389 * _389;
              float _394 = _393 * _389;
              float _395 = _394 - _389;
              float _396 = _395 * (User_000.UserConstant_Z_000[10].z);
              float _397 = _388 * _388;
              float _398 = _397 * _388;
              float _399 = _398 - _388;
              float _400 = _399 * (User_000.UserConstant_Z_000[10].w);
              float _401 = _396 + _400;
              float _402 = _386 * _386;
              float _403 = _402 * 0.1666666716337204f;
              float _404 = _403 * _401;
              float _405 = _392 + _404;
              _423 = _405;
            } else {
              float _407 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _408 = _298 - (User_000.UserConstant_Z_000[9].z);
              float _409 = max(9.999999974752427e-07f, _407);
              float _410 = _408 / _409;
              float _411 = 1.0f - _410;
              float _412 = _411 * (User_000.UserConstant_Z_000[9].w);
              float _413 = _412 + _410;
              float _414 = _411 * _411;
              float _415 = _414 * _411;
              float _416 = _415 - _411;
              float _417 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _418 = _407 * _407;
              float _419 = _418 * _417;
              float _420 = _419 * _416;
              float _421 = _413 + _420;
              _423 = _421;
            }
          }
        }
      }
      float _424 = saturate(_423);
      bool _425 = !(_299 <= (User_000.UserConstant_Z_000[4].x));
      if (!_425) {
        float _427 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _428 = _299 / _427;
        float _429 = _428 * (User_000.UserConstant_Z_000[4].y);
        float _430 = _428 * _428;
        float _431 = _430 * _428;
        float _432 = _431 - _428;
        float _433 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _434 = _427 * _427;
        float _435 = _434 * _433;
        float _436 = _435 * _432;
        float _437 = _436 + _429;
        _527 = _437;
      } else {
        bool _439 = !(_299 <= (User_000.UserConstant_Z_000[4].z));
        if (!_439) {
          float _441 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _442 = max(9.999999974752427e-07f, _441);
          float _443 = _299 - (User_000.UserConstant_Z_000[4].x);
          float _444 = _443 / _442;
          float _445 = 1.0f - _444;
          float _446 = _445 * (User_000.UserConstant_Z_000[4].y);
          float _447 = _444 * (User_000.UserConstant_Z_000[4].w);
          float _448 = _446 + _447;
          float _449 = _445 * _445;
          float _450 = _449 * _445;
          float _451 = _450 - _445;
          float _452 = _451 * (User_000.UserConstant_Z_000[10].x);
          float _453 = _444 * _444;
          float _454 = _453 * _444;
          float _455 = _454 - _444;
          float _456 = _455 * (User_000.UserConstant_Z_000[10].y);
          float _457 = _452 + _456;
          float _458 = _442 * _442;
          float _459 = _458 * 0.1666666716337204f;
          float _460 = _459 * _457;
          float _461 = _448 + _460;
          _527 = _461;
        } else {
          bool _463 = !(_299 <= (User_000.UserConstant_Z_000[9].x));
          if (!_463) {
            float _465 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _466 = max(9.999999974752427e-07f, _465);
            float _467 = _299 - (User_000.UserConstant_Z_000[4].z);
            float _468 = _467 / _466;
            float _469 = 1.0f - _468;
            float _470 = _469 * (User_000.UserConstant_Z_000[4].w);
            float _471 = _468 * (User_000.UserConstant_Z_000[9].y);
            float _472 = _470 + _471;
            float _473 = _469 * _469;
            float _474 = _473 * _469;
            float _475 = _474 - _469;
            float _476 = _475 * (User_000.UserConstant_Z_000[10].y);
            float _477 = _468 * _468;
            float _478 = _477 * _468;
            float _479 = _478 - _468;
            float _480 = _479 * (User_000.UserConstant_Z_000[10].z);
            float _481 = _476 + _480;
            float _482 = _466 * _466;
            float _483 = _482 * 0.1666666716337204f;
            float _484 = _483 * _481;
            float _485 = _472 + _484;
            _527 = _485;
          } else {
            bool _487 = !(_299 <= (User_000.UserConstant_Z_000[9].z));
            if (!_487) {
              float _489 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _490 = max(9.999999974752427e-07f, _489);
              float _491 = _299 - (User_000.UserConstant_Z_000[9].x);
              float _492 = _491 / _490;
              float _493 = 1.0f - _492;
              float _494 = _493 * (User_000.UserConstant_Z_000[9].y);
              float _495 = _492 * (User_000.UserConstant_Z_000[9].w);
              float _496 = _494 + _495;
              float _497 = _493 * _493;
              float _498 = _497 * _493;
              float _499 = _498 - _493;
              float _500 = _499 * (User_000.UserConstant_Z_000[10].z);
              float _501 = _492 * _492;
              float _502 = _501 * _492;
              float _503 = _502 - _492;
              float _504 = _503 * (User_000.UserConstant_Z_000[10].w);
              float _505 = _500 + _504;
              float _506 = _490 * _490;
              float _507 = _506 * 0.1666666716337204f;
              float _508 = _507 * _505;
              float _509 = _496 + _508;
              _527 = _509;
            } else {
              float _511 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _512 = _299 - (User_000.UserConstant_Z_000[9].z);
              float _513 = max(9.999999974752427e-07f, _511);
              float _514 = _512 / _513;
              float _515 = 1.0f - _514;
              float _516 = _515 * (User_000.UserConstant_Z_000[9].w);
              float _517 = _516 + _514;
              float _518 = _515 * _515;
              float _519 = _518 * _515;
              float _520 = _519 - _515;
              float _521 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _522 = _511 * _511;
              float _523 = _522 * _521;
              float _524 = _523 * _520;
              float _525 = _517 + _524;
              _527 = _525;
            }
          }
        }
      }
      float _528 = saturate(_527);
      bool _529 = !(_300 <= (User_000.UserConstant_Z_000[4].x));
      if (!_529) {
        float _531 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _532 = _300 / _531;
        float _533 = _532 * (User_000.UserConstant_Z_000[4].y);
        float _534 = _532 * _532;
        float _535 = _534 * _532;
        float _536 = _535 - _532;
        float _537 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _538 = _531 * _531;
        float _539 = _538 * _537;
        float _540 = _539 * _536;
        float _541 = _540 + _533;
        _631 = _541;
      } else {
        bool _543 = !(_300 <= (User_000.UserConstant_Z_000[4].z));
        if (!_543) {
          float _545 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _546 = max(9.999999974752427e-07f, _545);
          float _547 = _300 - (User_000.UserConstant_Z_000[4].x);
          float _548 = _547 / _546;
          float _549 = 1.0f - _548;
          float _550 = _549 * (User_000.UserConstant_Z_000[4].y);
          float _551 = _548 * (User_000.UserConstant_Z_000[4].w);
          float _552 = _550 + _551;
          float _553 = _549 * _549;
          float _554 = _553 * _549;
          float _555 = _554 - _549;
          float _556 = _555 * (User_000.UserConstant_Z_000[10].x);
          float _557 = _548 * _548;
          float _558 = _557 * _548;
          float _559 = _558 - _548;
          float _560 = _559 * (User_000.UserConstant_Z_000[10].y);
          float _561 = _556 + _560;
          float _562 = _546 * _546;
          float _563 = _562 * 0.1666666716337204f;
          float _564 = _563 * _561;
          float _565 = _552 + _564;
          _631 = _565;
        } else {
          bool _567 = !(_300 <= (User_000.UserConstant_Z_000[9].x));
          if (!_567) {
            float _569 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _570 = max(9.999999974752427e-07f, _569);
            float _571 = _300 - (User_000.UserConstant_Z_000[4].z);
            float _572 = _571 / _570;
            float _573 = 1.0f - _572;
            float _574 = _573 * (User_000.UserConstant_Z_000[4].w);
            float _575 = _572 * (User_000.UserConstant_Z_000[9].y);
            float _576 = _574 + _575;
            float _577 = _573 * _573;
            float _578 = _577 * _573;
            float _579 = _578 - _573;
            float _580 = _579 * (User_000.UserConstant_Z_000[10].y);
            float _581 = _572 * _572;
            float _582 = _581 * _572;
            float _583 = _582 - _572;
            float _584 = _583 * (User_000.UserConstant_Z_000[10].z);
            float _585 = _580 + _584;
            float _586 = _570 * _570;
            float _587 = _586 * 0.1666666716337204f;
            float _588 = _587 * _585;
            float _589 = _576 + _588;
            _631 = _589;
          } else {
            bool _591 = !(_300 <= (User_000.UserConstant_Z_000[9].z));
            if (!_591) {
              float _593 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _594 = max(9.999999974752427e-07f, _593);
              float _595 = _300 - (User_000.UserConstant_Z_000[9].x);
              float _596 = _595 / _594;
              float _597 = 1.0f - _596;
              float _598 = _597 * (User_000.UserConstant_Z_000[9].y);
              float _599 = _596 * (User_000.UserConstant_Z_000[9].w);
              float _600 = _598 + _599;
              float _601 = _597 * _597;
              float _602 = _601 * _597;
              float _603 = _602 - _597;
              float _604 = _603 * (User_000.UserConstant_Z_000[10].z);
              float _605 = _596 * _596;
              float _606 = _605 * _596;
              float _607 = _606 - _596;
              float _608 = _607 * (User_000.UserConstant_Z_000[10].w);
              float _609 = _604 + _608;
              float _610 = _594 * _594;
              float _611 = _610 * 0.1666666716337204f;
              float _612 = _611 * _609;
              float _613 = _600 + _612;
              _631 = _613;
            } else {
              float _615 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _616 = _300 - (User_000.UserConstant_Z_000[9].z);
              float _617 = max(9.999999974752427e-07f, _615);
              float _618 = _616 / _617;
              float _619 = 1.0f - _618;
              float _620 = _619 * (User_000.UserConstant_Z_000[9].w);
              float _621 = _620 + _618;
              float _622 = _619 * _619;
              float _623 = _622 * _619;
              float _624 = _623 - _619;
              float _625 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _626 = _615 * _615;
              float _627 = _626 * _625;
              float _628 = _627 * _624;
              float _629 = _621 + _628;
              _631 = _629;
            }
          }
        }
      }
      float _632 = saturate(_631);
      _634 = _424;
      _635 = _528;
      _636 = _632;
    } else {
      _634 = _298;
      _635 = _299;
      _636 = _300;
    }
    int _637 = _302 & 2;
    bool _638 = (_637 == 0);
    if (!_638) {
      float _640 = sqrt(_634);
      float _641 = sqrt(_635);
      float _642 = sqrt(_636);
      float _643 = dot(float3(_640, _641, _642), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _644 = 1.0f - _643;
      float _645 = saturate(_644);
      _647 = _645;
    } else {
      _647 = 1.0f;
    }
    int _648 = _302 & 8;
    bool _649 = (_648 == 0);
    if (_649) {
      int _651 = _302 & 4;
      bool _652 = (_651 == 0);
      if (!_652) {
        int _654 = _302 & 16;
        bool _655 = (_654 == 0);
        if (!_655) {
          float _659 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _660 = _659 + 0.5f;
          bool _661 = (_660 < 0.5f);
          float _662 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _663 = select(_661, (User_000.UserConstant_Z_000[5].x), _662);
          bool _664 = (_635 < _636);
          float _665 = select(_664, _636, _635);
          float _666 = select(_664, _635, _636);
          bool _667 = (_634 < _665);
          float _668 = select(_667, _665, _634);
          float _669 = select(_667, _634, _665);
          float _670 = min(_669, _666);
          float _671 = _668 - _670;
          float _672 = _668 + 1.000000013351432e-10f;
          float _673 = _671 / _672;
          float _675 = _673 - (User_000.UserConstant_Z_000[5].y);
          float _676 = saturate(_675);
          float _677 = max(_676, 9.999999974752427e-07f);
          float _678 = log2(_677);
          float _679 = _678 * _663;
          float _680 = exp2(_679);
          float _681 = 2.0f - _680;
          float _683 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _684 = saturate(_683);
          float _685 = max(_684, _681);
          float _686 = dot(float3(_634, _635, _636), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _687 = _634 - _686;
          float _688 = _635 - _686;
          float _689 = _636 - _686;
          float _690 = _687 * _685;
          float _691 = _688 * _685;
          float _692 = _689 * _685;
          float _693 = _686 - _634;
          float _694 = _693 + _690;
          float _695 = _686 - _635;
          float _696 = _695 + _691;
          float _697 = _686 - _636;
          float _698 = _697 + _692;
          float _699 = _694 * _647;
          float _700 = _696 * _647;
          float _701 = _698 * _647;
          float _702 = _699 + _634;
          float _703 = _700 + _635;
          float _704 = _701 + _636;
          _821 = _702;
          _822 = _703;
          _823 = _704;
        } else {
          bool _706 = (_647 == 0.0f);
          if (!_706) {
            float _710 = abs(User_000.UserConstant_Z_000[5].x);
            float _711 = saturate(_710);
            uint4 _713 = 0u; t15.GetDimensions(0u, _713.x, _713.y, _713.w);
            float _716 = float((uint)_713.y);
            int _717 = _302 & 32;
            bool _718 = (_717 == 0);
            float _719 = _716 + -1.0f;
            if (!_718) {
              float _721 = 1.0f / _719;
              uint _722 = uint(SV_Position.x);
              uint _723 = uint(SV_Position.y);
              int _724 = _722 & 63;
              int _725 = _723 & 63;
              float4 _727 = t2.Load(int4(_724, _725, 0, 0));
              float _730 = _727.x + -0.5f;
              float _731 = _634 * 13.999999046325684f;
              float _732 = _635 * 13.999999046325684f;
              float _733 = _636 * 13.999999046325684f;
              float _734 = saturate(_731);
              float _735 = saturate(_732);
              float _736 = saturate(_733);
              float _737 = _634 + -0.9285714030265808f;
              float _738 = _635 + -0.9285714030265808f;
              float _739 = _636 + -0.9285714030265808f;
              float _740 = _737 * 13.999999046325684f;
              float _741 = _738 * 13.999999046325684f;
              float _742 = _739 * 13.999999046325684f;
              float _743 = saturate(_740);
              float _744 = saturate(_741);
              float _745 = saturate(_742);
              float _746 = 1.0f - _743;
              float _747 = 1.0f - _744;
              float _748 = 1.0f - _745;
              float _749 = min(_734, _746);
              float _750 = min(_735, _747);
              float _751 = min(_736, _748);
              float _752 = _727.y + -0.5f;
              float _753 = _749 * _752;
              float _754 = _750 * _752;
              float _755 = _751 * _752;
              float _756 = _753 + _730;
              float _757 = _754 + _730;
              float _758 = _755 + _730;
              float _759 = _756 * _721;
              float _760 = _757 * _721;
              float _761 = _758 * _721;
              float _762 = _759 + _634;
              float _763 = _760 + _635;
              float _764 = _761 + _636;
              float _765 = saturate(_762);
              float _766 = saturate(_763);
              float _767 = saturate(_764);
              float _768 = saturate(_765);
              float _769 = saturate(_766);
              float _770 = saturate(_767);
              _772 = _768;
              _773 = _769;
              _774 = _770;
            } else {
              _772 = _634;
              _773 = _635;
              _774 = _636;
            }
            float _775 = float((uint)_713.x);
            float _776 = _719 / _775;
            float _777 = _776 * _772;
            float _778 = 0.5f / _775;
            float _779 = _777 + _778;
            float _780 = _719 / _716;
            float _781 = _780 * _773;
            float _782 = 0.5f / _716;
            float _783 = _781 + _782;
            float _784 = _774 * _719;
            float _785 = floor(_784);
            float _786 = frac(_784);
            float _787 = _785 / _716;
            float _788 = _787 + _779;
            float _789 = _785 + 1.0f;
            float _790 = _789 / _716;
            float _791 = _790 + _779;
            float4 _793 = t15.Sample(s0, float2(_788, _783));
            float4 _797 = t15.Sample(s0, float2(_791, _783));
            float _801 = _797.x - _793.x;
            float _802 = _797.y - _793.y;
            float _803 = _797.z - _793.z;
            float _804 = _801 * _786;
            float _805 = _802 * _786;
            float _806 = _803 * _786;
            float _807 = _711 * _647;
            float _808 = _793.x - _634;
            float _809 = _808 + _804;
            float _810 = _793.y - _635;
            float _811 = _810 + _805;
            float _812 = _793.z - _636;
            float _813 = _812 + _806;
            float _814 = _809 * _807;
            float _815 = _811 * _807;
            float _816 = _813 * _807;
            float _817 = _814 + _634;
            float _818 = _815 + _635;
            float _819 = _816 + _636;
            _821 = _817;
            _822 = _818;
            _823 = _819;
          } else {
            _821 = _634;
            _822 = _635;
            _823 = _636;
          }
        }
      } else {
        _821 = _634;
        _822 = _635;
        _823 = _636;
      }
    } else {
      _821 = _647;
      _822 = _647;
      _823 = _647;
    }
    float _824 = _821 * 13.450128555297852f;
    float _825 = _822 * 13.450128555297852f;
    float _826 = _823 * 13.450128555297852f;
    float _827 = exp2(_824);
    float _828 = exp2(_825);
    float _829 = exp2(_826);
    float _830 = _827 + -1.0f;
    float _831 = _828 + -1.0f;
    float _832 = _829 + -1.0f;
    float _833 = _830 * _280;
    float _834 = _831 * _280;
    float _835 = _832 * _280;
    _837 = _833;
    _838 = _834;
    _839 = _835;
  } else {
    _837 = _281;
    _838 = _282;
    _839 = _283;
  }
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _837, (User_000.UserConstant_Z_000[8].y) * _838, (User_000.UserConstant_Z_000[8].z) * _839),
      SV_Position.xy);
  float _846 = apt_perceptual_film_grain.x;
  float _847 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _848 = log2(_846);
  float _849 = _847 * _848;
  float _850 = exp2(_849);
  float _851 = _850 + -1.0f;
  float _852 = _846 + -1.0f;
  float _853 = _851 / _852;
  bool _854 = !(_846 == 1.0f);
  float _855 = _853 + -1.0f;
  float _856 = _855 / _853;
  float _857 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _858 = _857 / _847;
  float _859 = select(_854, _856, _858);
  float _860 = apt_perceptual_film_grain.y;
  float _861 = log2(_860);
  float _862 = _861 * _847;
  float _863 = exp2(_862);
  float _864 = _863 + -1.0f;
  float _865 = _860 + -1.0f;
  float _866 = _864 / _865;
  bool _867 = !(_860 == 1.0f);
  float _868 = _866 + -1.0f;
  float _869 = _868 / _866;
  float _870 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _871 = _870 / _847;
  float _872 = select(_867, _869, _871);
  float _873 = apt_perceptual_film_grain.z;
  float _874 = log2(_873);
  float _875 = _874 * _847;
  float _876 = exp2(_875);
  float _877 = _876 + -1.0f;
  float _878 = _873 + -1.0f;
  float _879 = _877 / _878;
  bool _880 = !(_873 == 1.0f);
  float _881 = _879 + -1.0f;
  float _882 = _881 / _879;
  float _883 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _884 = _883 / _847;
  float _885 = select(_880, _882, _884);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_846, _860, _873),
      float3(_859, _872, _885),
      true);
  float _886 = apt_post_process_output.x;
  float _887 = apt_post_process_output.y;
  float _888 = apt_post_process_output.z;
  float _889 = log2(_886);
  float _890 = log2(_887);
  float _891 = log2(_888);
  float _892 = _889 * 0.4166666567325592f;
  float _893 = _890 * 0.4166666567325592f;
  float _894 = _891 * 0.4166666567325592f;
  float _895 = exp2(_892);
  float _896 = exp2(_893);
  float _897 = exp2(_894);
  float _898 = _895 * 1.0549999475479126f;
  float _899 = _896 * 1.0549999475479126f;
  float _900 = _897 * 1.0549999475479126f;
  float _901 = _898 + -0.054999999701976776f;
  float _902 = _899 + -0.054999999701976776f;
  float _903 = _900 + -0.054999999701976776f;
  float _904 = _886 * 12.920000076293945f;
  float _905 = _887 * 12.920000076293945f;
  float _906 = _888 * 12.920000076293945f;
  bool _907 = (_886 <= 0.0031308000907301903f);
  bool _908 = (_887 <= 0.0031308000907301903f);
  bool _909 = (_888 <= 0.0031308000907301903f);
  float _910 = select(_907, _904, _901);
  float _911 = select(_908, _905, _902);
  float _912 = select(_909, _906, _903);
  int _915 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _916 = uint(SV_Position.x);
  uint _917 = uint(SV_Position.y);
  int _918 = _916 & 63;
  int _919 = _917 & 63;
  float4 _921 = t1.Load(int4(_918, _919, _915, 0));
  float _923 = _921.x + -0.5f;
  float _924 = _923 * 0.003921568859368563f;
  float _925 = _924 + _910;
  float _926 = _924 + _911;
  float _927 = _924 + _912;
  float _928 = saturate(_925);
  float _929 = saturate(_926);
  float _930 = saturate(_927);
  SV_Target.x = _928;
  SV_Target.y = _929;
  SV_Target.z = _930;
  SV_Target.w = _127.w;
  return SV_Target;
}
