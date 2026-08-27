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

Texture2DArray<float4> t6 : register(t6);

Texture2D<float4> t0 : register(t0);

Texture2D<float4> t2 : register(t2);

Texture3D<float4> t3 : register(t3);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t7 : register(t7);

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

SamplerState s2 : register(s2);

SamplerState s3 : register(s3);

SamplerState s4 : register(s4);

SamplerState s5 : register(s5);

SamplerState s7 : register(s7);

SamplerState s8 : register(s8);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _37 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _43 = t16.Sample(s0, float2(TEXCOORD.z, TEXCOORD.w));
  float _46 = _43.y * 0.10000000149011612f;
  float _47 = _46 + _37.y;
  float _48 = _43.y * 0.5f;
  float _49 = _48 + _37.z;
  float _50 = exp2(_49);
  float _51 = _50 + -1.0f;
  float _54 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _51;
  float _55 = _54 + 1.0f;
  float _56 = log2(_55);
  float _57 = _37.x + TEXCOORD.z;
  float _58 = _47 + TEXCOORD.w;
  float _59 = _37.x + TEXCOORD.x;
  float _60 = _47 + TEXCOORD.y;
  float _64 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].x);
  float _65 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].y);
  float _66 = _64 + _57;
  float _67 = _65 + _58;
  float _68 = _66 * 2.0f;
  float _69 = _67 * 2.0f;
  float _70 = _68 + -1.0f;
  float _71 = _69 + -1.0f;
  float _75 = _71 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].y);
  float _76 = abs(_70);
  float _77 = abs(_71);
  float _79 = (PostProcess_000.PostProcessConstant_Z_000[19].z) * 2.0f;
  float _80 = _79 + -1.0f;
  float _81 = _76 - _80;
  float _82 = _77 - _80;
  float _83 = saturate(_81);
  float _84 = saturate(_82);
  float _85 = _83 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].x);
  float _86 = _85 * _70;
  float _87 = _75 * _84;
  float _88 = _86 * _86;
  float _89 = _87 * _87;
  float _90 = _88 + _89;
  float _91 = sqrt(_90);
  float _94 = _64 + _59;
  float _95 = _65 + _60;
  float _96 = _94 * 2.0f;
  float _97 = _96 + -1.0f;
  float _98 = _95 * 1.125f;
  float _99 = _98 + -0.5625f;
  float _100 = _97 * _97;
  float _101 = _99 * _99;
  float _102 = _100 + _101;
  float _103 = sqrt(_102);
  float _104 = _103 * 0.8715755343437195f;
  float _105 = _104 * _104;
  float _106 = _105 + -0.15000000596046448f;
  float _107 = _106 * 1.8181819915771484f;
  float _108 = saturate(_107);
  float _109 = _108 * 2.0f;
  float _110 = 3.0f - _109;
  float _111 = (PostProcess_000.PostProcessConstant_Z_000[2].w) * _91;
  float _112 = _108 * _108;
  float _113 = _112 * _111;
  float _114 = _113 * _105;
  float _115 = _114 * _110;
  float _117 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _86;
  float _118 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _87;
  float _119 = _118 + _58;
  float _120 = _57 - _117;
  float _121 = _43.x * 0.010840999893844128f;
  float _122 = _57 + _121;
  float _123 = _122 + _117;
  float _124 = _58 + _121;
  float _125 = _124 - _118;
  float _126 = _56 + 1.0f;
  float _127 = log2(_126);
  float _128 = max(_115, _127);
  float4 _131 = t0.SampleLevel(s0, float2(_123, _119), _128);
  float4 _133 = t0.SampleLevel(s0, float2(_120, _125), _128);
  float4 _135 = t0.SampleLevel(s0, float2(_57, _58), _128);
  float _138 = max(_131.x, 0.0f);
  float _139 = max(_133.y, 0.0f);
  float _140 = max(_135.z, 0.0f);
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_138, _139, _140),
      max(_135.rgb, 0.f.xxx),
      float2(_57, _58),
      t0,
      s0,
      _128);
  _138 = renodx_chromatic_aberration_input.x;
  _139 = renodx_chromatic_aberration_input.y;
  _140 = renodx_chromatic_aberration_input.z;
  float4 _142 = t12.SampleLevel(s0, float2(_57, _58), 0.0f);
  float4 _148 = t8.Sample(s8, float2(_59, _60));
  int _154 = asint((User_000.UserConstant_Z_000[7].z));
  bool _155 = ((int)_154 > (int)0);
  float _184;
  float _185;
  float _186;
  float _191;
  float _192;
  float _193;
  float _222;
  float _306;
  float _343;
  float _533;
  float _572;
  float _573;
  float _574;
  float _603;
  float _604;
  float _605;
  float _610;
  float _611;
  float _612;
  float _812;
  float _916;
  float _1020;
  float _1023;
  float _1024;
  float _1025;
  float _1036;
  float _1161;
  float _1162;
  float _1163;
  float _1210;
  float _1211;
  float _1212;
  float _1226;
  float _1227;
  float _1228;
  if (!_155) {
    bool _159 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _163 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _148.x;
    float _164 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _148.y;
    float _165 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _148.z;
    float _166 = _163 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _167 = _164 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _168 = _165 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_159) {
      float _170 = _166 * _142.x;
      float _171 = _167 * _142.y;
      float _172 = _168 * _142.z;
      _184 = _170;
      _185 = _171;
      _186 = _172;
    } else {
      float _174 = saturate(_166);
      float _175 = saturate(_167);
      float _176 = saturate(_168);
      float _177 = _142.x - _138;
      float _178 = _142.y - _139;
      float _179 = _142.z - _140;
      float _180 = _174 * _177;
      float _181 = _175 * _178;
      float _182 = _176 * _179;
      _184 = _180;
      _185 = _181;
      _186 = _182;
    }
    float _187 = _184 + _138;
    float _188 = _185 + _139;
    float _189 = _186 + _140;
    _191 = _187;
    _192 = _188;
    _193 = _189;
  } else {
    _191 = _138;
    _192 = _139;
    _193 = _140;
  }
  [branch]
  if (_155) {
    bool _198 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_198) {
      float _200 = _37.x + TEXCOORD.x;
      float _201 = _47 + TEXCOORD.y;
      float4 _204 = t2.SampleLevel(s2, float2(_200, _201), 0.0f);
      bool _208 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_208) {
        float4 _211 = t7.Load(int3(0, 0, 0));
        float _216 = _211.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _217 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _216;
        _222 = _217;
      } else {
        _222 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _226 = _204.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _227 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _226;
      float _229 = _222 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _230 = _229 + _222;
      float _231 = _222 - _229;
      float _232 = max(_227, _231);
      float _233 = min(_232, _230);
      float _236 = _227 - _233;
      float _237 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _236;
      float _239 = _233 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _240 = _239 * _227;
      float _241 = _237 / _240;
      float _242 = min(_241, 0.0f);
      float _244 = _229 + 1.0f;
      float _245 = 1.0f / _244;
      float _246 = _242 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _247 = max(0.0f, _241);
      float _250 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _247;
      float _251 = _250 + _246;
      float _252 = _251 * _245;
      float _253 = max(_252, -1.0f);
      float _254 = min(_253, 1.0f);
      float _255 = max(_254, -0.30000001192092896f);
      float _256 = min(_255, 1.0f);
      float _258 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _259 = _256 * _258;
      float _260 = _200 + -0.5f;
      float _261 = _201 + -0.5f;
      float _262 = _260 * _260;
      float _263 = _261 * _261;
      float _264 = _263 + _262;
      float _265 = sqrt(_264);
      float _266 = log2(_265);
      float _267 = _266 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _268 = exp2(_267);
      float _269 = _268 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _270 = dot(float2(_260, _261), float2(_260, _261));
      float _271 = rsqrt(_270);
      float _272 = _271 * _260;
      float _273 = _271 * _261;
      float _274 = abs(_259);
      float _278 = _269 * _274;
      float _279 = -0.0f - _278;
      float _280 = (User_000.UserConstant_Z_000[2].x) * _272;
      float _281 = _280 * _279;
      float _282 = (User_000.UserConstant_Z_000[2].y) * _273;
      float _283 = _282 * _279;
      float _284 = _274 * _269;
      float _285 = _280 * _284;
      float _286 = _282 * _284;
      float _287 = _285 + _200;
      float _288 = _286 + _201;
      float _289 = _281 + _123;
      float _290 = _283 + _119;
      float4 _291 = t0.SampleLevel(s0, float2(_289, _290), _128);
      float4 _293 = t0.SampleLevel(s0, float2(_287, _288), _128);
      float4 _295 = t2.SampleLevel(s2, float2(_289, _290), 0.0f);
      if (_208) {
        float4 _299 = t7.Load(int3(0, 0, 0));
        float _301 = _299.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _302 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _301;
        _306 = _302;
      } else {
        _306 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _307 = _295.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _308 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _307;
      float _309 = _306 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _310 = _309 + _306;
      float _311 = _306 - _309;
      float _312 = max(_308, _311);
      float _313 = min(_312, _310);
      float _314 = _308 - _313;
      float _315 = _314 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _316 = _313 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _317 = _316 * _308;
      float _318 = _315 / _317;
      float _319 = min(_318, 0.0f);
      float _320 = _309 + 1.0f;
      float _321 = 1.0f / _320;
      float _322 = _319 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _323 = max(0.0f, _318);
      float _324 = _323 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _325 = _324 + _322;
      float _326 = _325 * _321;
      float _327 = max(_326, -1.0f);
      float _328 = min(_327, 1.0f);
      float _329 = max(_328, -0.30000001192092896f);
      float _330 = min(_329, 1.0f);
      float _331 = _330 * _258;
      float4 _332 = t2.SampleLevel(s2, float2(_287, _288), 0.0f);
      if (_208) {
        float4 _336 = t7.Load(int3(0, 0, 0));
        float _338 = _336.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _339 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _338;
        _343 = _339;
      } else {
        _343 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _344 = _332.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _345 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _344;
      float _346 = _343 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _347 = _346 + _343;
      float _348 = _343 - _346;
      float _349 = max(_345, _348);
      float _350 = min(_349, _347);
      float _351 = _345 - _350;
      float _352 = _351 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _353 = _350 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _354 = _353 * _345;
      float _355 = _352 / _354;
      float _356 = min(_355, 0.0f);
      float _357 = _346 + 1.0f;
      float _358 = 1.0f / _357;
      float _359 = _356 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _360 = max(0.0f, _355);
      float _361 = _360 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _362 = _361 + _359;
      float _363 = _362 * _358;
      float _364 = max(_363, -1.0f);
      float _365 = min(_364, 1.0f);
      float _366 = max(_365, -0.30000001192092896f);
      float _367 = min(_366, 1.0f);
      float _368 = _367 * _258;
      float _369 = abs(_331);
      float _370 = _369 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _371 = ceil(_370);
      float _372 = saturate(_371);
      float _373 = _291.x - _191;
      float _374 = _372 * _373;
      float _375 = _374 + _191;
      float _376 = abs(_368);
      float _377 = _376 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _378 = ceil(_377);
      float _379 = saturate(_378);
      float _380 = _293.z - _193;
      float _381 = _379 * _380;
      float _382 = _381 + _193;
      _572 = _375;
      _573 = _192;
      _574 = _382;
    } else {
      _572 = _191;
      _573 = _192;
      _574 = _193;
    }
  } else {
    int _385 = asint((User_000.UserConstant_Z_000[7].y));
    bool _386 = ((int)_385 > (int)0);
    if (_386) {
      float _388 = _37.x + TEXCOORD.x;
      float _389 = _47 + TEXCOORD.y;
      float4 _392 = t4.Sample(s4, float2(_388, _389));
      float4 _399 = t5.Sample(s5, float2(_388, _389));
      float _403 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _399.x;
      float _407 = _403 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _408 = _403 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _409 = _407 + _388;
      float _410 = _408 + _389;
      float4 _411 = t4.Sample(s4, float2(_409, _410));
      float4 _413 = t5.Sample(s5, float2(_409, _410));
      float _415 = _413.x * (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _416 = abs(_415);
      float _418 = _416 / (PostProcess_000.PostProcessConstant_Z_000[7].w);
      float _419 = _411.z - _392.z;
      float _420 = _418 * _419;
      float _421 = _392.x - _191;
      float _422 = _392.y - _192;
      float _423 = _392.z - _193;
      float _424 = _423 + _420;
      float _425 = _421 * _392.w;
      float _426 = _422 * _392.w;
      float _427 = _424 * _392.w;
      float _428 = _425 + _191;
      float _429 = _426 + _192;
      float _430 = _427 + _193;
      _572 = _428;
      _573 = _429;
      _574 = _430;
    } else {
      int _433 = asint((User_000.UserConstant_Z_000[7].x));
      bool _434 = ((int)_433 > (int)0);
      [branch]
      if (_434) {
        float4 _438 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _440 = abs(_438.x);
        _533 = _440;
      } else {
        float4 _444 = t2.SampleLevel(s2, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _446 = TEXCOORD.x * 2.0f;
        float _447 = TEXCOORD.y * 2.0f;
        float _448 = _446 + -1.0f;
        float _449 = _447 + -1.0f;
        float _470 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _448;
        float _471 = mad(_449, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _470);
        float _472 = mad(_444.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _471);
        float _473 = _472 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _474 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _448;
        float _475 = mad(_449, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _474);
        float _476 = mad(_444.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _475);
        float _477 = _476 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _478 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _448;
        float _479 = mad(_449, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _478);
        float _480 = mad(_444.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _479);
        float _481 = _480 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _482 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _448;
        float _483 = mad(_449, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _482);
        float _484 = mad(_444.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _483);
        float _485 = _484 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
        float _486 = _473 / _485;
        float _487 = _477 / _485;
        float _488 = _481 / _485;
        float _489 = _486 * _486;
        float _490 = _487 * _487;
        float _491 = _490 + _489;
        float _492 = _488 * _488;
        float _493 = _491 + _492;
        float _494 = sqrt(_493);
        float4 _497 = t5.Sample(s5, float2(TEXCOORD.x, TEXCOORD.y));
        float _503 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _504 = _503 + (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _505 = (PostProcess_000.PostProcessConstant_Z_000[5].x) - _503;
        float _506 = max(_494, _505);
        float _507 = min(_506, _504);
        float _509 = _494 - _507;
        float _510 = _509 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
        float _512 = _507 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _513 = _512 * _494;
        float _514 = _510 / _513;
        float _515 = min(_514, 0.0f);
        float _518 = _503 + 1.0f;
        float _519 = 1.0f / _518;
        float _520 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _515;
        float _521 = max(0.0f, _514);
        float _524 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _521;
        float _525 = _524 + _520;
        float _526 = _525 * _519;
        float _527 = min(_497.x, _526);
        float _528 = abs(_527);
        float _529 = abs(_526);
        float _530 = max(_528, _529);
        float _531 = saturate(_530);
        _533 = _531;
      }
      float _536 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _533;
      float4 _539 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _546 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _536;
      float _547 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _536;
      float _548 = _546 + TEXCOORD.x;
      float _549 = _547 + TEXCOORD.y;
      float4 _550 = t4.Sample(s4, float2(_548, _549));
      float4 _554 = t5.Sample(s5, float2(_548, _549));
      float _556 = abs(_554.x);
      float _557 = _550.z - _539.z;
      float _558 = _556 * _557;
      float _559 = _536 + -1.0f;
      float _560 = saturate(_559);
      float _561 = _539.x - _191;
      float _562 = _539.y - _192;
      float _563 = _539.z - _193;
      float _564 = _563 + _558;
      float _565 = _560 * _561;
      float _566 = _560 * _562;
      float _567 = _564 * _560;
      float _568 = _565 + _191;
      float _569 = _566 + _192;
      float _570 = _567 + _193;
      _572 = _568;
      _573 = _569;
      _574 = _570;
    }
  }
  if (_155) {
    bool _578 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _582 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _148.x;
    float _583 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _148.y;
    float _584 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _148.z;
    float _585 = _582 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _586 = _583 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _587 = _584 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_578) {
      float _589 = _585 * _142.x;
      float _590 = _586 * _142.y;
      float _591 = _587 * _142.z;
      _603 = _589;
      _604 = _590;
      _605 = _591;
    } else {
      float _593 = saturate(_585);
      float _594 = saturate(_586);
      float _595 = saturate(_587);
      float _596 = _142.x - _572;
      float _597 = _142.y - _573;
      float _598 = _142.z - _574;
      float _599 = _593 * _596;
      float _600 = _594 * _597;
      float _601 = _595 * _598;
      _603 = _599;
      _604 = _600;
      _605 = _601;
    }
    float _606 = _603 + _572;
    float _607 = _604 + _573;
    float _608 = _605 + _574;
    _610 = _606;
    _611 = _607;
    _612 = _608;
  } else {
    _610 = _572;
    _611 = _573;
    _612 = _574;
  }
  float4 _616 = t17.Load(int3(0, 0, 0));
  float _624 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _625 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _626 = _616.x * _625;
  float _627 = _626 * _610;
  float _628 = _627 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _629 = _628 * _624;
  float _630 = _626 * _611;
  float _631 = _630 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _632 = _631 * _624;
  float _633 = _626 * _612;
  float _634 = _633 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _635 = _634 * _624;
  float _636 = _629 + 1.0f;
  float _637 = _632 + 1.0f;
  float _638 = _635 + 1.0f;
  float _639 = log2(_636);
  float _640 = log2(_637);
  float _641 = log2(_638);
  float _644 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _645 = _644 * _639;
  float _646 = _644 * _640;
  float _647 = _644 * _641;
  float _649 = _645 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _650 = _646 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _651 = _647 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _654 = t3.Sample(s3, float3(_649, _650, _651));
  float _660 = _654.x * 13.450128555297852f;
  float _661 = _654.y * 13.450128555297852f;
  float _662 = _654.z * 13.450128555297852f;
  float _663 = exp2(_660);
  float _664 = exp2(_661);
  float _665 = exp2(_662);
  float _666 = _663 + -1.0f;
  float _667 = _664 + -1.0f;
  float _668 = _665 + -1.0f;
  float _669 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _670 = _669 * _666;
  float _671 = _669 * _667;
  float _672 = _669 * _668;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_629 * _669, _632 * _669, _635 * _669),
      float3(_670, _671, _672),
      1.f.xxx);
  _670 = apt_scaled_lut_output.x;
  _671 = apt_scaled_lut_output.y;
  _672 = apt_scaled_lut_output.z;
  bool _675 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !APTIsPsychoV();
  if (_675) {
    float _677 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _678 = _670 * _677;
    float _679 = _671 * _677;
    float _680 = _672 * _677;
    float _681 = _678 + 1.0f;
    float _682 = _679 + 1.0f;
    float _683 = _680 + 1.0f;
    float _684 = log2(_681);
    float _685 = log2(_682);
    float _686 = log2(_683);
    float _687 = _684 * 0.07434873282909393f;
    float _688 = _685 * 0.07434873282909393f;
    float _689 = _686 * 0.07434873282909393f;
    int _691 = asint((User_000.UserConstant_Z_000[3].y));
    int _692 = _691 & 1;
    bool _693 = (_692 == 0);
    if (!_693) {
      bool _710 = !(_687 <= (User_000.UserConstant_Z_000[4].x));
      if (!_710) {
        float _712 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _713 = _687 / _712;
        float _714 = _713 * (User_000.UserConstant_Z_000[4].y);
        float _715 = _713 * _713;
        float _716 = _715 * _713;
        float _717 = _716 - _713;
        float _718 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _719 = _712 * _712;
        float _720 = _719 * _718;
        float _721 = _720 * _717;
        float _722 = _721 + _714;
        _812 = _722;
      } else {
        bool _724 = !(_687 <= (User_000.UserConstant_Z_000[4].z));
        if (!_724) {
          float _726 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _727 = max(9.999999974752427e-07f, _726);
          float _728 = _687 - (User_000.UserConstant_Z_000[4].x);
          float _729 = _728 / _727;
          float _730 = 1.0f - _729;
          float _731 = _730 * (User_000.UserConstant_Z_000[4].y);
          float _732 = _729 * (User_000.UserConstant_Z_000[4].w);
          float _733 = _731 + _732;
          float _734 = _730 * _730;
          float _735 = _734 * _730;
          float _736 = _735 - _730;
          float _737 = _736 * (User_000.UserConstant_Z_000[10].x);
          float _738 = _729 * _729;
          float _739 = _738 * _729;
          float _740 = _739 - _729;
          float _741 = _740 * (User_000.UserConstant_Z_000[10].y);
          float _742 = _737 + _741;
          float _743 = _727 * _727;
          float _744 = _743 * 0.1666666716337204f;
          float _745 = _744 * _742;
          float _746 = _733 + _745;
          _812 = _746;
        } else {
          bool _748 = !(_687 <= (User_000.UserConstant_Z_000[9].x));
          if (!_748) {
            float _750 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _751 = max(9.999999974752427e-07f, _750);
            float _752 = _687 - (User_000.UserConstant_Z_000[4].z);
            float _753 = _752 / _751;
            float _754 = 1.0f - _753;
            float _755 = _754 * (User_000.UserConstant_Z_000[4].w);
            float _756 = _753 * (User_000.UserConstant_Z_000[9].y);
            float _757 = _755 + _756;
            float _758 = _754 * _754;
            float _759 = _758 * _754;
            float _760 = _759 - _754;
            float _761 = _760 * (User_000.UserConstant_Z_000[10].y);
            float _762 = _753 * _753;
            float _763 = _762 * _753;
            float _764 = _763 - _753;
            float _765 = _764 * (User_000.UserConstant_Z_000[10].z);
            float _766 = _761 + _765;
            float _767 = _751 * _751;
            float _768 = _767 * 0.1666666716337204f;
            float _769 = _768 * _766;
            float _770 = _757 + _769;
            _812 = _770;
          } else {
            bool _772 = !(_687 <= (User_000.UserConstant_Z_000[9].z));
            if (!_772) {
              float _774 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _775 = max(9.999999974752427e-07f, _774);
              float _776 = _687 - (User_000.UserConstant_Z_000[9].x);
              float _777 = _776 / _775;
              float _778 = 1.0f - _777;
              float _779 = _778 * (User_000.UserConstant_Z_000[9].y);
              float _780 = _777 * (User_000.UserConstant_Z_000[9].w);
              float _781 = _779 + _780;
              float _782 = _778 * _778;
              float _783 = _782 * _778;
              float _784 = _783 - _778;
              float _785 = _784 * (User_000.UserConstant_Z_000[10].z);
              float _786 = _777 * _777;
              float _787 = _786 * _777;
              float _788 = _787 - _777;
              float _789 = _788 * (User_000.UserConstant_Z_000[10].w);
              float _790 = _785 + _789;
              float _791 = _775 * _775;
              float _792 = _791 * 0.1666666716337204f;
              float _793 = _792 * _790;
              float _794 = _781 + _793;
              _812 = _794;
            } else {
              float _796 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _797 = _687 - (User_000.UserConstant_Z_000[9].z);
              float _798 = max(9.999999974752427e-07f, _796);
              float _799 = _797 / _798;
              float _800 = 1.0f - _799;
              float _801 = _800 * (User_000.UserConstant_Z_000[9].w);
              float _802 = _801 + _799;
              float _803 = _800 * _800;
              float _804 = _803 * _800;
              float _805 = _804 - _800;
              float _806 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _807 = _796 * _796;
              float _808 = _807 * _806;
              float _809 = _808 * _805;
              float _810 = _802 + _809;
              _812 = _810;
            }
          }
        }
      }
      float _813 = saturate(_812);
      bool _814 = !(_688 <= (User_000.UserConstant_Z_000[4].x));
      if (!_814) {
        float _816 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _817 = _688 / _816;
        float _818 = _817 * (User_000.UserConstant_Z_000[4].y);
        float _819 = _817 * _817;
        float _820 = _819 * _817;
        float _821 = _820 - _817;
        float _822 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _823 = _816 * _816;
        float _824 = _823 * _822;
        float _825 = _824 * _821;
        float _826 = _825 + _818;
        _916 = _826;
      } else {
        bool _828 = !(_688 <= (User_000.UserConstant_Z_000[4].z));
        if (!_828) {
          float _830 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _831 = max(9.999999974752427e-07f, _830);
          float _832 = _688 - (User_000.UserConstant_Z_000[4].x);
          float _833 = _832 / _831;
          float _834 = 1.0f - _833;
          float _835 = _834 * (User_000.UserConstant_Z_000[4].y);
          float _836 = _833 * (User_000.UserConstant_Z_000[4].w);
          float _837 = _835 + _836;
          float _838 = _834 * _834;
          float _839 = _838 * _834;
          float _840 = _839 - _834;
          float _841 = _840 * (User_000.UserConstant_Z_000[10].x);
          float _842 = _833 * _833;
          float _843 = _842 * _833;
          float _844 = _843 - _833;
          float _845 = _844 * (User_000.UserConstant_Z_000[10].y);
          float _846 = _841 + _845;
          float _847 = _831 * _831;
          float _848 = _847 * 0.1666666716337204f;
          float _849 = _848 * _846;
          float _850 = _837 + _849;
          _916 = _850;
        } else {
          bool _852 = !(_688 <= (User_000.UserConstant_Z_000[9].x));
          if (!_852) {
            float _854 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _855 = max(9.999999974752427e-07f, _854);
            float _856 = _688 - (User_000.UserConstant_Z_000[4].z);
            float _857 = _856 / _855;
            float _858 = 1.0f - _857;
            float _859 = _858 * (User_000.UserConstant_Z_000[4].w);
            float _860 = _857 * (User_000.UserConstant_Z_000[9].y);
            float _861 = _859 + _860;
            float _862 = _858 * _858;
            float _863 = _862 * _858;
            float _864 = _863 - _858;
            float _865 = _864 * (User_000.UserConstant_Z_000[10].y);
            float _866 = _857 * _857;
            float _867 = _866 * _857;
            float _868 = _867 - _857;
            float _869 = _868 * (User_000.UserConstant_Z_000[10].z);
            float _870 = _865 + _869;
            float _871 = _855 * _855;
            float _872 = _871 * 0.1666666716337204f;
            float _873 = _872 * _870;
            float _874 = _861 + _873;
            _916 = _874;
          } else {
            bool _876 = !(_688 <= (User_000.UserConstant_Z_000[9].z));
            if (!_876) {
              float _878 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _879 = max(9.999999974752427e-07f, _878);
              float _880 = _688 - (User_000.UserConstant_Z_000[9].x);
              float _881 = _880 / _879;
              float _882 = 1.0f - _881;
              float _883 = _882 * (User_000.UserConstant_Z_000[9].y);
              float _884 = _881 * (User_000.UserConstant_Z_000[9].w);
              float _885 = _883 + _884;
              float _886 = _882 * _882;
              float _887 = _886 * _882;
              float _888 = _887 - _882;
              float _889 = _888 * (User_000.UserConstant_Z_000[10].z);
              float _890 = _881 * _881;
              float _891 = _890 * _881;
              float _892 = _891 - _881;
              float _893 = _892 * (User_000.UserConstant_Z_000[10].w);
              float _894 = _889 + _893;
              float _895 = _879 * _879;
              float _896 = _895 * 0.1666666716337204f;
              float _897 = _896 * _894;
              float _898 = _885 + _897;
              _916 = _898;
            } else {
              float _900 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _901 = _688 - (User_000.UserConstant_Z_000[9].z);
              float _902 = max(9.999999974752427e-07f, _900);
              float _903 = _901 / _902;
              float _904 = 1.0f - _903;
              float _905 = _904 * (User_000.UserConstant_Z_000[9].w);
              float _906 = _905 + _903;
              float _907 = _904 * _904;
              float _908 = _907 * _904;
              float _909 = _908 - _904;
              float _910 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _911 = _900 * _900;
              float _912 = _911 * _910;
              float _913 = _912 * _909;
              float _914 = _906 + _913;
              _916 = _914;
            }
          }
        }
      }
      float _917 = saturate(_916);
      bool _918 = !(_689 <= (User_000.UserConstant_Z_000[4].x));
      if (!_918) {
        float _920 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _921 = _689 / _920;
        float _922 = _921 * (User_000.UserConstant_Z_000[4].y);
        float _923 = _921 * _921;
        float _924 = _923 * _921;
        float _925 = _924 - _921;
        float _926 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _927 = _920 * _920;
        float _928 = _927 * _926;
        float _929 = _928 * _925;
        float _930 = _929 + _922;
        _1020 = _930;
      } else {
        bool _932 = !(_689 <= (User_000.UserConstant_Z_000[4].z));
        if (!_932) {
          float _934 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _935 = max(9.999999974752427e-07f, _934);
          float _936 = _689 - (User_000.UserConstant_Z_000[4].x);
          float _937 = _936 / _935;
          float _938 = 1.0f - _937;
          float _939 = _938 * (User_000.UserConstant_Z_000[4].y);
          float _940 = _937 * (User_000.UserConstant_Z_000[4].w);
          float _941 = _939 + _940;
          float _942 = _938 * _938;
          float _943 = _942 * _938;
          float _944 = _943 - _938;
          float _945 = _944 * (User_000.UserConstant_Z_000[10].x);
          float _946 = _937 * _937;
          float _947 = _946 * _937;
          float _948 = _947 - _937;
          float _949 = _948 * (User_000.UserConstant_Z_000[10].y);
          float _950 = _945 + _949;
          float _951 = _935 * _935;
          float _952 = _951 * 0.1666666716337204f;
          float _953 = _952 * _950;
          float _954 = _941 + _953;
          _1020 = _954;
        } else {
          bool _956 = !(_689 <= (User_000.UserConstant_Z_000[9].x));
          if (!_956) {
            float _958 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _959 = max(9.999999974752427e-07f, _958);
            float _960 = _689 - (User_000.UserConstant_Z_000[4].z);
            float _961 = _960 / _959;
            float _962 = 1.0f - _961;
            float _963 = _962 * (User_000.UserConstant_Z_000[4].w);
            float _964 = _961 * (User_000.UserConstant_Z_000[9].y);
            float _965 = _963 + _964;
            float _966 = _962 * _962;
            float _967 = _966 * _962;
            float _968 = _967 - _962;
            float _969 = _968 * (User_000.UserConstant_Z_000[10].y);
            float _970 = _961 * _961;
            float _971 = _970 * _961;
            float _972 = _971 - _961;
            float _973 = _972 * (User_000.UserConstant_Z_000[10].z);
            float _974 = _969 + _973;
            float _975 = _959 * _959;
            float _976 = _975 * 0.1666666716337204f;
            float _977 = _976 * _974;
            float _978 = _965 + _977;
            _1020 = _978;
          } else {
            bool _980 = !(_689 <= (User_000.UserConstant_Z_000[9].z));
            if (!_980) {
              float _982 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _983 = max(9.999999974752427e-07f, _982);
              float _984 = _689 - (User_000.UserConstant_Z_000[9].x);
              float _985 = _984 / _983;
              float _986 = 1.0f - _985;
              float _987 = _986 * (User_000.UserConstant_Z_000[9].y);
              float _988 = _985 * (User_000.UserConstant_Z_000[9].w);
              float _989 = _987 + _988;
              float _990 = _986 * _986;
              float _991 = _990 * _986;
              float _992 = _991 - _986;
              float _993 = _992 * (User_000.UserConstant_Z_000[10].z);
              float _994 = _985 * _985;
              float _995 = _994 * _985;
              float _996 = _995 - _985;
              float _997 = _996 * (User_000.UserConstant_Z_000[10].w);
              float _998 = _993 + _997;
              float _999 = _983 * _983;
              float _1000 = _999 * 0.1666666716337204f;
              float _1001 = _1000 * _998;
              float _1002 = _989 + _1001;
              _1020 = _1002;
            } else {
              float _1004 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1005 = _689 - (User_000.UserConstant_Z_000[9].z);
              float _1006 = max(9.999999974752427e-07f, _1004);
              float _1007 = _1005 / _1006;
              float _1008 = 1.0f - _1007;
              float _1009 = _1008 * (User_000.UserConstant_Z_000[9].w);
              float _1010 = _1009 + _1007;
              float _1011 = _1008 * _1008;
              float _1012 = _1011 * _1008;
              float _1013 = _1012 - _1008;
              float _1014 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1015 = _1004 * _1004;
              float _1016 = _1015 * _1014;
              float _1017 = _1016 * _1013;
              float _1018 = _1010 + _1017;
              _1020 = _1018;
            }
          }
        }
      }
      float _1021 = saturate(_1020);
      _1023 = _813;
      _1024 = _917;
      _1025 = _1021;
    } else {
      _1023 = _687;
      _1024 = _688;
      _1025 = _689;
    }
    int _1026 = _691 & 2;
    bool _1027 = (_1026 == 0);
    if (!_1027) {
      float _1029 = sqrt(_1023);
      float _1030 = sqrt(_1024);
      float _1031 = sqrt(_1025);
      float _1032 = dot(float3(_1029, _1030, _1031), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1033 = 1.0f - _1032;
      float _1034 = saturate(_1033);
      _1036 = _1034;
    } else {
      _1036 = 1.0f;
    }
    int _1037 = _691 & 8;
    bool _1038 = (_1037 == 0);
    if (_1038) {
      int _1040 = _691 & 4;
      bool _1041 = (_1040 == 0);
      if (!_1041) {
        int _1043 = _691 & 16;
        bool _1044 = (_1043 == 0);
        if (!_1044) {
          float _1048 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1049 = _1048 + 0.5f;
          bool _1050 = (_1049 < 0.5f);
          float _1051 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1052 = select(_1050, (User_000.UserConstant_Z_000[5].x), _1051);
          bool _1053 = (_1024 < _1025);
          float _1054 = select(_1053, _1025, _1024);
          float _1055 = select(_1053, _1024, _1025);
          bool _1056 = (_1023 < _1054);
          float _1057 = select(_1056, _1054, _1023);
          float _1058 = select(_1056, _1023, _1054);
          float _1059 = min(_1058, _1055);
          float _1060 = _1057 - _1059;
          float _1061 = _1057 + 1.000000013351432e-10f;
          float _1062 = _1060 / _1061;
          float _1064 = _1062 - (User_000.UserConstant_Z_000[5].y);
          float _1065 = saturate(_1064);
          float _1066 = max(_1065, 9.999999974752427e-07f);
          float _1067 = log2(_1066);
          float _1068 = _1067 * _1052;
          float _1069 = exp2(_1068);
          float _1070 = 2.0f - _1069;
          float _1072 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1073 = saturate(_1072);
          float _1074 = max(_1073, _1070);
          float _1075 = dot(float3(_1023, _1024, _1025), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1076 = _1023 - _1075;
          float _1077 = _1024 - _1075;
          float _1078 = _1025 - _1075;
          float _1079 = _1076 * _1074;
          float _1080 = _1077 * _1074;
          float _1081 = _1078 * _1074;
          float _1082 = _1075 - _1023;
          float _1083 = _1082 + _1079;
          float _1084 = _1075 - _1024;
          float _1085 = _1084 + _1080;
          float _1086 = _1075 - _1025;
          float _1087 = _1086 + _1081;
          float _1088 = _1083 * _1036;
          float _1089 = _1085 * _1036;
          float _1090 = _1087 * _1036;
          float _1091 = _1088 + _1023;
          float _1092 = _1089 + _1024;
          float _1093 = _1090 + _1025;
          _1210 = _1091;
          _1211 = _1092;
          _1212 = _1093;
        } else {
          bool _1095 = (_1036 == 0.0f);
          if (!_1095) {
            float _1099 = abs(User_000.UserConstant_Z_000[5].x);
            float _1100 = saturate(_1099);
            uint4 _1102 = 0u; t15.GetDimensions(0u, _1102.x, _1102.y, _1102.w);
            float _1105 = float((uint)_1102.y);
            int _1106 = _691 & 32;
            bool _1107 = (_1106 == 0);
            float _1108 = _1105 + -1.0f;
            if (!_1107) {
              float _1110 = 1.0f / _1108;
              uint _1111 = uint(SV_Position.x);
              uint _1112 = uint(SV_Position.y);
              int _1113 = _1111 & 63;
              int _1114 = _1112 & 63;
              float4 _1116 = t6.Load(int4(_1113, _1114, 0, 0));
              float _1119 = _1116.x + -0.5f;
              float _1120 = _1023 * 13.999999046325684f;
              float _1121 = _1024 * 13.999999046325684f;
              float _1122 = _1025 * 13.999999046325684f;
              float _1123 = saturate(_1120);
              float _1124 = saturate(_1121);
              float _1125 = saturate(_1122);
              float _1126 = _1023 + -0.9285714030265808f;
              float _1127 = _1024 + -0.9285714030265808f;
              float _1128 = _1025 + -0.9285714030265808f;
              float _1129 = _1126 * 13.999999046325684f;
              float _1130 = _1127 * 13.999999046325684f;
              float _1131 = _1128 * 13.999999046325684f;
              float _1132 = saturate(_1129);
              float _1133 = saturate(_1130);
              float _1134 = saturate(_1131);
              float _1135 = 1.0f - _1132;
              float _1136 = 1.0f - _1133;
              float _1137 = 1.0f - _1134;
              float _1138 = min(_1123, _1135);
              float _1139 = min(_1124, _1136);
              float _1140 = min(_1125, _1137);
              float _1141 = _1116.y + -0.5f;
              float _1142 = _1138 * _1141;
              float _1143 = _1139 * _1141;
              float _1144 = _1140 * _1141;
              float _1145 = _1142 + _1119;
              float _1146 = _1143 + _1119;
              float _1147 = _1144 + _1119;
              float _1148 = _1145 * _1110;
              float _1149 = _1146 * _1110;
              float _1150 = _1147 * _1110;
              float _1151 = _1148 + _1023;
              float _1152 = _1149 + _1024;
              float _1153 = _1150 + _1025;
              float _1154 = saturate(_1151);
              float _1155 = saturate(_1152);
              float _1156 = saturate(_1153);
              float _1157 = saturate(_1154);
              float _1158 = saturate(_1155);
              float _1159 = saturate(_1156);
              _1161 = _1157;
              _1162 = _1158;
              _1163 = _1159;
            } else {
              _1161 = _1023;
              _1162 = _1024;
              _1163 = _1025;
            }
            float _1164 = float((uint)_1102.x);
            float _1165 = _1108 / _1164;
            float _1166 = _1165 * _1161;
            float _1167 = 0.5f / _1164;
            float _1168 = _1166 + _1167;
            float _1169 = _1108 / _1105;
            float _1170 = _1169 * _1162;
            float _1171 = 0.5f / _1105;
            float _1172 = _1170 + _1171;
            float _1173 = _1163 * _1108;
            float _1174 = floor(_1173);
            float _1175 = frac(_1173);
            float _1176 = _1174 / _1105;
            float _1177 = _1176 + _1168;
            float _1178 = _1174 + 1.0f;
            float _1179 = _1178 / _1105;
            float _1180 = _1179 + _1168;
            float4 _1182 = t15.Sample(s0, float2(_1177, _1172));
            float4 _1186 = t15.Sample(s0, float2(_1180, _1172));
            float _1190 = _1186.x - _1182.x;
            float _1191 = _1186.y - _1182.y;
            float _1192 = _1186.z - _1182.z;
            float _1193 = _1190 * _1175;
            float _1194 = _1191 * _1175;
            float _1195 = _1192 * _1175;
            float _1196 = _1100 * _1036;
            float _1197 = _1182.x - _1023;
            float _1198 = _1197 + _1193;
            float _1199 = _1182.y - _1024;
            float _1200 = _1199 + _1194;
            float _1201 = _1182.z - _1025;
            float _1202 = _1201 + _1195;
            float _1203 = _1198 * _1196;
            float _1204 = _1200 * _1196;
            float _1205 = _1202 * _1196;
            float _1206 = _1203 + _1023;
            float _1207 = _1204 + _1024;
            float _1208 = _1205 + _1025;
            _1210 = _1206;
            _1211 = _1207;
            _1212 = _1208;
          } else {
            _1210 = _1023;
            _1211 = _1024;
            _1212 = _1025;
          }
        }
      } else {
        _1210 = _1023;
        _1211 = _1024;
        _1212 = _1025;
      }
    } else {
      _1210 = _1036;
      _1211 = _1036;
      _1212 = _1036;
    }
    float _1213 = _1210 * 13.450128555297852f;
    float _1214 = _1211 * 13.450128555297852f;
    float _1215 = _1212 * 13.450128555297852f;
    float _1216 = exp2(_1213);
    float _1217 = exp2(_1214);
    float _1218 = exp2(_1215);
    float _1219 = _1216 + -1.0f;
    float _1220 = _1217 + -1.0f;
    float _1221 = _1218 + -1.0f;
    float _1222 = _1219 * _669;
    float _1223 = _1220 * _669;
    float _1224 = _1221 * _669;
    _1226 = _1222;
    _1227 = _1223;
    _1228 = _1224;
  } else {
    _1226 = _670;
    _1227 = _671;
    _1228 = _672;
  }
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1226, (User_000.UserConstant_Z_000[8].y) * _1227, (User_000.UserConstant_Z_000[8].z) * _1228),
      SV_Position.xy);
  float _1235 = apt_perceptual_film_grain.x;
  float _1236 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1237 = log2(_1235);
  float _1238 = _1236 * _1237;
  float _1239 = exp2(_1238);
  float _1240 = _1239 + -1.0f;
  float _1241 = _1235 + -1.0f;
  float _1242 = _1240 / _1241;
  bool _1243 = !(_1235 == 1.0f);
  float _1244 = _1242 + -1.0f;
  float _1245 = _1244 / _1242;
  float _1246 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1247 = _1246 / _1236;
  float _1248 = select(_1243, _1245, _1247);
  float _1249 = apt_perceptual_film_grain.y;
  float _1250 = log2(_1249);
  float _1251 = _1250 * _1236;
  float _1252 = exp2(_1251);
  float _1253 = _1252 + -1.0f;
  float _1254 = _1249 + -1.0f;
  float _1255 = _1253 / _1254;
  bool _1256 = !(_1249 == 1.0f);
  float _1257 = _1255 + -1.0f;
  float _1258 = _1257 / _1255;
  float _1259 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1260 = _1259 / _1236;
  float _1261 = select(_1256, _1258, _1260);
  float _1262 = apt_perceptual_film_grain.z;
  float _1263 = log2(_1262);
  float _1264 = _1263 * _1236;
  float _1265 = exp2(_1264);
  float _1266 = _1265 + -1.0f;
  float _1267 = _1262 + -1.0f;
  float _1268 = _1266 / _1267;
  bool _1269 = !(_1262 == 1.0f);
  float _1270 = _1268 + -1.0f;
  float _1271 = _1270 / _1268;
  float _1272 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1273 = _1272 / _1236;
  float _1274 = select(_1269, _1271, _1273);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1235, _1249, _1262),
      float3(_1248, _1261, _1274),
      true);
  float _1275 = apt_post_process_output.x;
  float _1276 = apt_post_process_output.y;
  float _1277 = apt_post_process_output.z;
  float _1278 = log2(_1275);
  float _1279 = log2(_1276);
  float _1280 = log2(_1277);
  float _1281 = _1278 * 0.4166666567325592f;
  float _1282 = _1279 * 0.4166666567325592f;
  float _1283 = _1280 * 0.4166666567325592f;
  float _1284 = exp2(_1281);
  float _1285 = exp2(_1282);
  float _1286 = exp2(_1283);
  float _1287 = _1284 * 1.0549999475479126f;
  float _1288 = _1285 * 1.0549999475479126f;
  float _1289 = _1286 * 1.0549999475479126f;
  float _1290 = _1287 + -0.054999999701976776f;
  float _1291 = _1288 + -0.054999999701976776f;
  float _1292 = _1289 + -0.054999999701976776f;
  float _1293 = _1275 * 12.920000076293945f;
  float _1294 = _1276 * 12.920000076293945f;
  float _1295 = _1277 * 12.920000076293945f;
  bool _1296 = (_1275 <= 0.0031308000907301903f);
  bool _1297 = (_1276 <= 0.0031308000907301903f);
  bool _1298 = (_1277 <= 0.0031308000907301903f);
  float _1299 = select(_1296, _1293, _1290);
  float _1300 = select(_1297, _1294, _1291);
  float _1301 = select(_1298, _1295, _1292);
  int _1304 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1305 = uint(SV_Position.x);
  uint _1306 = uint(SV_Position.y);
  int _1307 = _1305 & 63;
  int _1308 = _1306 & 63;
  float4 _1310 = t1.Load(int4(_1307, _1308, _1304, 0));
  float _1312 = _1310.x + -0.5f;
  float _1313 = _1312 * 0.003921568859368563f;
  float _1314 = _1313 + _1299;
  float _1315 = _1313 + _1300;
  float _1316 = _1313 + _1301;
  float _1317 = saturate(_1314);
  float _1318 = saturate(_1315);
  float _1319 = saturate(_1316);
  SV_Target.x = _1317;
  SV_Target.y = _1318;
  SV_Target.z = _1319;
  SV_Target.w = _135.w;
  return SV_Target;
}
