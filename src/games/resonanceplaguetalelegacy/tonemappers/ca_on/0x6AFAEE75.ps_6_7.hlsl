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
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
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
  float _847;
  float _951;
  float _1055;
  float _1058;
  float _1059;
  float _1060;
  float _1071;
  float _1196;
  float _1197;
  float _1198;
  float _1245;
  float _1246;
  float _1247;
  float _1261;
  float _1262;
  float _1263;
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
  float _622 = _616.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _623 = _622 * _610;
  float _624 = _623 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _625 = _622 * _611;
  float _626 = _625 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _627 = _622 * _612;
  float _628 = _627 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _633 = _57 * 2.0f;
  float _634 = _58 * 2.0f;
  float _635 = _633 + -1.0f;
  float _636 = _634 + -1.0f;
  float _639 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _636;
  float _640 = _635 * _635;
  float _641 = _639 * _639;
  float _642 = _641 + _640;
  float _643 = sqrt(_642);
  float _645 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _643;
  float _647 = _645 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _648 = saturate(_647);
  float _650 = log2(_648);
  float _651 = _650 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _652 = ResonanceScaleVignetteMask(exp2(_651));
  float _653 = _624 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _654 = _626 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _655 = _628 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _656 = _653 - _624;
  float _657 = _654 - _626;
  float _658 = _655 - _628;
  float _659 = _652 * _656;
  float _660 = _652 * _657;
  float _661 = _652 * _658;
  float _662 = _659 + _624;
  float _663 = _660 + _626;
  float _664 = _661 + _628;
  float _667 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _668 = _667 * _662;
  float _669 = _667 * _663;
  float _670 = _667 * _664;
  float _671 = _668 + 1.0f;
  float _672 = _669 + 1.0f;
  float _673 = _670 + 1.0f;
  float _674 = log2(_671);
  float _675 = log2(_672);
  float _676 = log2(_673);
  float _679 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _680 = _679 * _674;
  float _681 = _679 * _675;
  float _682 = _679 * _676;
  float _684 = _680 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _685 = _681 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _686 = _682 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _689 = t3.Sample(s3, float3(_684, _685, _686));
  float _695 = _689.x * 13.450128555297852f;
  float _696 = _689.y * 13.450128555297852f;
  float _697 = _689.z * 13.450128555297852f;
  float _698 = exp2(_695);
  float _699 = exp2(_696);
  float _700 = exp2(_697);
  float _701 = _698 + -1.0f;
  float _702 = _699 + -1.0f;
  float _703 = _700 + -1.0f;
  float _704 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _705 = _704 * _701;
  float _706 = _704 * _702;
  float _707 = _704 * _703;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_668 * _704, _669 * _704, _670 * _704),
      float3(_705, _706, _707),
      1.f.xxx);
  _705 = resonance_scaled_lut_output.x;
  _706 = resonance_scaled_lut_output.y;
  _707 = resonance_scaled_lut_output.z;
  bool _710 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_710) {
    float _712 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _713 = _705 * _712;
    float _714 = _706 * _712;
    float _715 = _707 * _712;
    float _716 = _713 + 1.0f;
    float _717 = _714 + 1.0f;
    float _718 = _715 + 1.0f;
    float _719 = log2(_716);
    float _720 = log2(_717);
    float _721 = log2(_718);
    float _722 = _719 * 0.07434873282909393f;
    float _723 = _720 * 0.07434873282909393f;
    float _724 = _721 * 0.07434873282909393f;
    int _726 = asint((User_000.UserConstant_Z_000[3].y));
    int _727 = _726 & 1;
    bool _728 = (_727 == 0);
    if (!_728) {
      bool _745 = !(_722 <= (User_000.UserConstant_Z_000[4].x));
      if (!_745) {
        float _747 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _748 = _722 / _747;
        float _749 = _748 * (User_000.UserConstant_Z_000[4].y);
        float _750 = _748 * _748;
        float _751 = _750 * _748;
        float _752 = _751 - _748;
        float _753 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _754 = _747 * _747;
        float _755 = _754 * _753;
        float _756 = _755 * _752;
        float _757 = _756 + _749;
        _847 = _757;
      } else {
        bool _759 = !(_722 <= (User_000.UserConstant_Z_000[4].z));
        if (!_759) {
          float _761 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _762 = max(9.999999974752427e-07f, _761);
          float _763 = _722 - (User_000.UserConstant_Z_000[4].x);
          float _764 = _763 / _762;
          float _765 = 1.0f - _764;
          float _766 = _765 * (User_000.UserConstant_Z_000[4].y);
          float _767 = _764 * (User_000.UserConstant_Z_000[4].w);
          float _768 = _766 + _767;
          float _769 = _765 * _765;
          float _770 = _769 * _765;
          float _771 = _770 - _765;
          float _772 = _771 * (User_000.UserConstant_Z_000[10].x);
          float _773 = _764 * _764;
          float _774 = _773 * _764;
          float _775 = _774 - _764;
          float _776 = _775 * (User_000.UserConstant_Z_000[10].y);
          float _777 = _772 + _776;
          float _778 = _762 * _762;
          float _779 = _778 * 0.1666666716337204f;
          float _780 = _779 * _777;
          float _781 = _768 + _780;
          _847 = _781;
        } else {
          bool _783 = !(_722 <= (User_000.UserConstant_Z_000[9].x));
          if (!_783) {
            float _785 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _786 = max(9.999999974752427e-07f, _785);
            float _787 = _722 - (User_000.UserConstant_Z_000[4].z);
            float _788 = _787 / _786;
            float _789 = 1.0f - _788;
            float _790 = _789 * (User_000.UserConstant_Z_000[4].w);
            float _791 = _788 * (User_000.UserConstant_Z_000[9].y);
            float _792 = _790 + _791;
            float _793 = _789 * _789;
            float _794 = _793 * _789;
            float _795 = _794 - _789;
            float _796 = _795 * (User_000.UserConstant_Z_000[10].y);
            float _797 = _788 * _788;
            float _798 = _797 * _788;
            float _799 = _798 - _788;
            float _800 = _799 * (User_000.UserConstant_Z_000[10].z);
            float _801 = _796 + _800;
            float _802 = _786 * _786;
            float _803 = _802 * 0.1666666716337204f;
            float _804 = _803 * _801;
            float _805 = _792 + _804;
            _847 = _805;
          } else {
            bool _807 = !(_722 <= (User_000.UserConstant_Z_000[9].z));
            if (!_807) {
              float _809 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _810 = max(9.999999974752427e-07f, _809);
              float _811 = _722 - (User_000.UserConstant_Z_000[9].x);
              float _812 = _811 / _810;
              float _813 = 1.0f - _812;
              float _814 = _813 * (User_000.UserConstant_Z_000[9].y);
              float _815 = _812 * (User_000.UserConstant_Z_000[9].w);
              float _816 = _814 + _815;
              float _817 = _813 * _813;
              float _818 = _817 * _813;
              float _819 = _818 - _813;
              float _820 = _819 * (User_000.UserConstant_Z_000[10].z);
              float _821 = _812 * _812;
              float _822 = _821 * _812;
              float _823 = _822 - _812;
              float _824 = _823 * (User_000.UserConstant_Z_000[10].w);
              float _825 = _820 + _824;
              float _826 = _810 * _810;
              float _827 = _826 * 0.1666666716337204f;
              float _828 = _827 * _825;
              float _829 = _816 + _828;
              _847 = _829;
            } else {
              float _831 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _832 = _722 - (User_000.UserConstant_Z_000[9].z);
              float _833 = max(9.999999974752427e-07f, _831);
              float _834 = _832 / _833;
              float _835 = 1.0f - _834;
              float _836 = _835 * (User_000.UserConstant_Z_000[9].w);
              float _837 = _836 + _834;
              float _838 = _835 * _835;
              float _839 = _838 * _835;
              float _840 = _839 - _835;
              float _841 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _842 = _831 * _831;
              float _843 = _842 * _841;
              float _844 = _843 * _840;
              float _845 = _837 + _844;
              _847 = _845;
            }
          }
        }
      }
      float _848 = saturate(_847);
      bool _849 = !(_723 <= (User_000.UserConstant_Z_000[4].x));
      if (!_849) {
        float _851 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _852 = _723 / _851;
        float _853 = _852 * (User_000.UserConstant_Z_000[4].y);
        float _854 = _852 * _852;
        float _855 = _854 * _852;
        float _856 = _855 - _852;
        float _857 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _858 = _851 * _851;
        float _859 = _858 * _857;
        float _860 = _859 * _856;
        float _861 = _860 + _853;
        _951 = _861;
      } else {
        bool _863 = !(_723 <= (User_000.UserConstant_Z_000[4].z));
        if (!_863) {
          float _865 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _866 = max(9.999999974752427e-07f, _865);
          float _867 = _723 - (User_000.UserConstant_Z_000[4].x);
          float _868 = _867 / _866;
          float _869 = 1.0f - _868;
          float _870 = _869 * (User_000.UserConstant_Z_000[4].y);
          float _871 = _868 * (User_000.UserConstant_Z_000[4].w);
          float _872 = _870 + _871;
          float _873 = _869 * _869;
          float _874 = _873 * _869;
          float _875 = _874 - _869;
          float _876 = _875 * (User_000.UserConstant_Z_000[10].x);
          float _877 = _868 * _868;
          float _878 = _877 * _868;
          float _879 = _878 - _868;
          float _880 = _879 * (User_000.UserConstant_Z_000[10].y);
          float _881 = _876 + _880;
          float _882 = _866 * _866;
          float _883 = _882 * 0.1666666716337204f;
          float _884 = _883 * _881;
          float _885 = _872 + _884;
          _951 = _885;
        } else {
          bool _887 = !(_723 <= (User_000.UserConstant_Z_000[9].x));
          if (!_887) {
            float _889 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _890 = max(9.999999974752427e-07f, _889);
            float _891 = _723 - (User_000.UserConstant_Z_000[4].z);
            float _892 = _891 / _890;
            float _893 = 1.0f - _892;
            float _894 = _893 * (User_000.UserConstant_Z_000[4].w);
            float _895 = _892 * (User_000.UserConstant_Z_000[9].y);
            float _896 = _894 + _895;
            float _897 = _893 * _893;
            float _898 = _897 * _893;
            float _899 = _898 - _893;
            float _900 = _899 * (User_000.UserConstant_Z_000[10].y);
            float _901 = _892 * _892;
            float _902 = _901 * _892;
            float _903 = _902 - _892;
            float _904 = _903 * (User_000.UserConstant_Z_000[10].z);
            float _905 = _900 + _904;
            float _906 = _890 * _890;
            float _907 = _906 * 0.1666666716337204f;
            float _908 = _907 * _905;
            float _909 = _896 + _908;
            _951 = _909;
          } else {
            bool _911 = !(_723 <= (User_000.UserConstant_Z_000[9].z));
            if (!_911) {
              float _913 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _914 = max(9.999999974752427e-07f, _913);
              float _915 = _723 - (User_000.UserConstant_Z_000[9].x);
              float _916 = _915 / _914;
              float _917 = 1.0f - _916;
              float _918 = _917 * (User_000.UserConstant_Z_000[9].y);
              float _919 = _916 * (User_000.UserConstant_Z_000[9].w);
              float _920 = _918 + _919;
              float _921 = _917 * _917;
              float _922 = _921 * _917;
              float _923 = _922 - _917;
              float _924 = _923 * (User_000.UserConstant_Z_000[10].z);
              float _925 = _916 * _916;
              float _926 = _925 * _916;
              float _927 = _926 - _916;
              float _928 = _927 * (User_000.UserConstant_Z_000[10].w);
              float _929 = _924 + _928;
              float _930 = _914 * _914;
              float _931 = _930 * 0.1666666716337204f;
              float _932 = _931 * _929;
              float _933 = _920 + _932;
              _951 = _933;
            } else {
              float _935 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _936 = _723 - (User_000.UserConstant_Z_000[9].z);
              float _937 = max(9.999999974752427e-07f, _935);
              float _938 = _936 / _937;
              float _939 = 1.0f - _938;
              float _940 = _939 * (User_000.UserConstant_Z_000[9].w);
              float _941 = _940 + _938;
              float _942 = _939 * _939;
              float _943 = _942 * _939;
              float _944 = _943 - _939;
              float _945 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _946 = _935 * _935;
              float _947 = _946 * _945;
              float _948 = _947 * _944;
              float _949 = _941 + _948;
              _951 = _949;
            }
          }
        }
      }
      float _952 = saturate(_951);
      bool _953 = !(_724 <= (User_000.UserConstant_Z_000[4].x));
      if (!_953) {
        float _955 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _956 = _724 / _955;
        float _957 = _956 * (User_000.UserConstant_Z_000[4].y);
        float _958 = _956 * _956;
        float _959 = _958 * _956;
        float _960 = _959 - _956;
        float _961 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _962 = _955 * _955;
        float _963 = _962 * _961;
        float _964 = _963 * _960;
        float _965 = _964 + _957;
        _1055 = _965;
      } else {
        bool _967 = !(_724 <= (User_000.UserConstant_Z_000[4].z));
        if (!_967) {
          float _969 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _970 = max(9.999999974752427e-07f, _969);
          float _971 = _724 - (User_000.UserConstant_Z_000[4].x);
          float _972 = _971 / _970;
          float _973 = 1.0f - _972;
          float _974 = _973 * (User_000.UserConstant_Z_000[4].y);
          float _975 = _972 * (User_000.UserConstant_Z_000[4].w);
          float _976 = _974 + _975;
          float _977 = _973 * _973;
          float _978 = _977 * _973;
          float _979 = _978 - _973;
          float _980 = _979 * (User_000.UserConstant_Z_000[10].x);
          float _981 = _972 * _972;
          float _982 = _981 * _972;
          float _983 = _982 - _972;
          float _984 = _983 * (User_000.UserConstant_Z_000[10].y);
          float _985 = _980 + _984;
          float _986 = _970 * _970;
          float _987 = _986 * 0.1666666716337204f;
          float _988 = _987 * _985;
          float _989 = _976 + _988;
          _1055 = _989;
        } else {
          bool _991 = !(_724 <= (User_000.UserConstant_Z_000[9].x));
          if (!_991) {
            float _993 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _994 = max(9.999999974752427e-07f, _993);
            float _995 = _724 - (User_000.UserConstant_Z_000[4].z);
            float _996 = _995 / _994;
            float _997 = 1.0f - _996;
            float _998 = _997 * (User_000.UserConstant_Z_000[4].w);
            float _999 = _996 * (User_000.UserConstant_Z_000[9].y);
            float _1000 = _998 + _999;
            float _1001 = _997 * _997;
            float _1002 = _1001 * _997;
            float _1003 = _1002 - _997;
            float _1004 = _1003 * (User_000.UserConstant_Z_000[10].y);
            float _1005 = _996 * _996;
            float _1006 = _1005 * _996;
            float _1007 = _1006 - _996;
            float _1008 = _1007 * (User_000.UserConstant_Z_000[10].z);
            float _1009 = _1004 + _1008;
            float _1010 = _994 * _994;
            float _1011 = _1010 * 0.1666666716337204f;
            float _1012 = _1011 * _1009;
            float _1013 = _1000 + _1012;
            _1055 = _1013;
          } else {
            bool _1015 = !(_724 <= (User_000.UserConstant_Z_000[9].z));
            if (!_1015) {
              float _1017 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _1018 = max(9.999999974752427e-07f, _1017);
              float _1019 = _724 - (User_000.UserConstant_Z_000[9].x);
              float _1020 = _1019 / _1018;
              float _1021 = 1.0f - _1020;
              float _1022 = _1021 * (User_000.UserConstant_Z_000[9].y);
              float _1023 = _1020 * (User_000.UserConstant_Z_000[9].w);
              float _1024 = _1022 + _1023;
              float _1025 = _1021 * _1021;
              float _1026 = _1025 * _1021;
              float _1027 = _1026 - _1021;
              float _1028 = _1027 * (User_000.UserConstant_Z_000[10].z);
              float _1029 = _1020 * _1020;
              float _1030 = _1029 * _1020;
              float _1031 = _1030 - _1020;
              float _1032 = _1031 * (User_000.UserConstant_Z_000[10].w);
              float _1033 = _1028 + _1032;
              float _1034 = _1018 * _1018;
              float _1035 = _1034 * 0.1666666716337204f;
              float _1036 = _1035 * _1033;
              float _1037 = _1024 + _1036;
              _1055 = _1037;
            } else {
              float _1039 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1040 = _724 - (User_000.UserConstant_Z_000[9].z);
              float _1041 = max(9.999999974752427e-07f, _1039);
              float _1042 = _1040 / _1041;
              float _1043 = 1.0f - _1042;
              float _1044 = _1043 * (User_000.UserConstant_Z_000[9].w);
              float _1045 = _1044 + _1042;
              float _1046 = _1043 * _1043;
              float _1047 = _1046 * _1043;
              float _1048 = _1047 - _1043;
              float _1049 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1050 = _1039 * _1039;
              float _1051 = _1050 * _1049;
              float _1052 = _1051 * _1048;
              float _1053 = _1045 + _1052;
              _1055 = _1053;
            }
          }
        }
      }
      float _1056 = saturate(_1055);
      _1058 = _848;
      _1059 = _952;
      _1060 = _1056;
    } else {
      _1058 = _722;
      _1059 = _723;
      _1060 = _724;
    }
    int _1061 = _726 & 2;
    bool _1062 = (_1061 == 0);
    if (!_1062) {
      float _1064 = sqrt(_1058);
      float _1065 = sqrt(_1059);
      float _1066 = sqrt(_1060);
      float _1067 = dot(float3(_1064, _1065, _1066), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1068 = 1.0f - _1067;
      float _1069 = saturate(_1068);
      _1071 = _1069;
    } else {
      _1071 = 1.0f;
    }
    int _1072 = _726 & 8;
    bool _1073 = (_1072 == 0);
    if (_1073) {
      int _1075 = _726 & 4;
      bool _1076 = (_1075 == 0);
      if (!_1076) {
        int _1078 = _726 & 16;
        bool _1079 = (_1078 == 0);
        if (!_1079) {
          float _1083 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1084 = _1083 + 0.5f;
          bool _1085 = (_1084 < 0.5f);
          float _1086 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1087 = select(_1085, (User_000.UserConstant_Z_000[5].x), _1086);
          bool _1088 = (_1059 < _1060);
          float _1089 = select(_1088, _1060, _1059);
          float _1090 = select(_1088, _1059, _1060);
          bool _1091 = (_1058 < _1089);
          float _1092 = select(_1091, _1089, _1058);
          float _1093 = select(_1091, _1058, _1089);
          float _1094 = min(_1093, _1090);
          float _1095 = _1092 - _1094;
          float _1096 = _1092 + 1.000000013351432e-10f;
          float _1097 = _1095 / _1096;
          float _1099 = _1097 - (User_000.UserConstant_Z_000[5].y);
          float _1100 = saturate(_1099);
          float _1101 = max(_1100, 9.999999974752427e-07f);
          float _1102 = log2(_1101);
          float _1103 = _1102 * _1087;
          float _1104 = exp2(_1103);
          float _1105 = 2.0f - _1104;
          float _1107 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1108 = saturate(_1107);
          float _1109 = max(_1108, _1105);
          float _1110 = dot(float3(_1058, _1059, _1060), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1111 = _1058 - _1110;
          float _1112 = _1059 - _1110;
          float _1113 = _1060 - _1110;
          float _1114 = _1111 * _1109;
          float _1115 = _1112 * _1109;
          float _1116 = _1113 * _1109;
          float _1117 = _1110 - _1058;
          float _1118 = _1117 + _1114;
          float _1119 = _1110 - _1059;
          float _1120 = _1119 + _1115;
          float _1121 = _1110 - _1060;
          float _1122 = _1121 + _1116;
          float _1123 = _1118 * _1071;
          float _1124 = _1120 * _1071;
          float _1125 = _1122 * _1071;
          float _1126 = _1123 + _1058;
          float _1127 = _1124 + _1059;
          float _1128 = _1125 + _1060;
          _1245 = _1126;
          _1246 = _1127;
          _1247 = _1128;
        } else {
          bool _1130 = (_1071 == 0.0f);
          if (!_1130) {
            float _1134 = abs(User_000.UserConstant_Z_000[5].x);
            float _1135 = saturate(_1134);
            uint4 _1137 = 0u; t15.GetDimensions(0u, _1137.x, _1137.y, _1137.w);
            float _1140 = float((uint)_1137.y);
            int _1141 = _726 & 32;
            bool _1142 = (_1141 == 0);
            float _1143 = _1140 + -1.0f;
            if (!_1142) {
              float _1145 = 1.0f / _1143;
              uint _1146 = uint(SV_Position.x);
              uint _1147 = uint(SV_Position.y);
              int _1148 = _1146 & 63;
              int _1149 = _1147 & 63;
              float4 _1151 = t6.Load(int4(_1148, _1149, 0, 0));
              float _1154 = _1151.x + -0.5f;
              float _1155 = _1058 * 13.999999046325684f;
              float _1156 = _1059 * 13.999999046325684f;
              float _1157 = _1060 * 13.999999046325684f;
              float _1158 = saturate(_1155);
              float _1159 = saturate(_1156);
              float _1160 = saturate(_1157);
              float _1161 = _1058 + -0.9285714030265808f;
              float _1162 = _1059 + -0.9285714030265808f;
              float _1163 = _1060 + -0.9285714030265808f;
              float _1164 = _1161 * 13.999999046325684f;
              float _1165 = _1162 * 13.999999046325684f;
              float _1166 = _1163 * 13.999999046325684f;
              float _1167 = saturate(_1164);
              float _1168 = saturate(_1165);
              float _1169 = saturate(_1166);
              float _1170 = 1.0f - _1167;
              float _1171 = 1.0f - _1168;
              float _1172 = 1.0f - _1169;
              float _1173 = min(_1158, _1170);
              float _1174 = min(_1159, _1171);
              float _1175 = min(_1160, _1172);
              float _1176 = _1151.y + -0.5f;
              float _1177 = _1173 * _1176;
              float _1178 = _1174 * _1176;
              float _1179 = _1175 * _1176;
              float _1180 = _1177 + _1154;
              float _1181 = _1178 + _1154;
              float _1182 = _1179 + _1154;
              float _1183 = _1180 * _1145;
              float _1184 = _1181 * _1145;
              float _1185 = _1182 * _1145;
              float _1186 = _1183 + _1058;
              float _1187 = _1184 + _1059;
              float _1188 = _1185 + _1060;
              float _1189 = saturate(_1186);
              float _1190 = saturate(_1187);
              float _1191 = saturate(_1188);
              float _1192 = saturate(_1189);
              float _1193 = saturate(_1190);
              float _1194 = saturate(_1191);
              _1196 = _1192;
              _1197 = _1193;
              _1198 = _1194;
            } else {
              _1196 = _1058;
              _1197 = _1059;
              _1198 = _1060;
            }
            float _1199 = float((uint)_1137.x);
            float _1200 = _1143 / _1199;
            float _1201 = _1200 * _1196;
            float _1202 = 0.5f / _1199;
            float _1203 = _1201 + _1202;
            float _1204 = _1143 / _1140;
            float _1205 = _1204 * _1197;
            float _1206 = 0.5f / _1140;
            float _1207 = _1205 + _1206;
            float _1208 = _1198 * _1143;
            float _1209 = floor(_1208);
            float _1210 = frac(_1208);
            float _1211 = _1209 / _1140;
            float _1212 = _1211 + _1203;
            float _1213 = _1209 + 1.0f;
            float _1214 = _1213 / _1140;
            float _1215 = _1214 + _1203;
            float4 _1217 = t15.Sample(s0, float2(_1212, _1207));
            float4 _1221 = t15.Sample(s0, float2(_1215, _1207));
            float _1225 = _1221.x - _1217.x;
            float _1226 = _1221.y - _1217.y;
            float _1227 = _1221.z - _1217.z;
            float _1228 = _1225 * _1210;
            float _1229 = _1226 * _1210;
            float _1230 = _1227 * _1210;
            float _1231 = _1135 * _1071;
            float _1232 = _1217.x - _1058;
            float _1233 = _1232 + _1228;
            float _1234 = _1217.y - _1059;
            float _1235 = _1234 + _1229;
            float _1236 = _1217.z - _1060;
            float _1237 = _1236 + _1230;
            float _1238 = _1233 * _1231;
            float _1239 = _1235 * _1231;
            float _1240 = _1237 * _1231;
            float _1241 = _1238 + _1058;
            float _1242 = _1239 + _1059;
            float _1243 = _1240 + _1060;
            _1245 = _1241;
            _1246 = _1242;
            _1247 = _1243;
          } else {
            _1245 = _1058;
            _1246 = _1059;
            _1247 = _1060;
          }
        }
      } else {
        _1245 = _1058;
        _1246 = _1059;
        _1247 = _1060;
      }
    } else {
      _1245 = _1071;
      _1246 = _1071;
      _1247 = _1071;
    }
    float _1248 = _1245 * 13.450128555297852f;
    float _1249 = _1246 * 13.450128555297852f;
    float _1250 = _1247 * 13.450128555297852f;
    float _1251 = exp2(_1248);
    float _1252 = exp2(_1249);
    float _1253 = exp2(_1250);
    float _1254 = _1251 + -1.0f;
    float _1255 = _1252 + -1.0f;
    float _1256 = _1253 + -1.0f;
    float _1257 = _1254 * _704;
    float _1258 = _1255 * _704;
    float _1259 = _1256 * _704;
    _1261 = _1257;
    _1262 = _1258;
    _1263 = _1259;
  } else {
    _1261 = _705;
    _1262 = _706;
    _1263 = _707;
  }
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1261, (User_000.UserConstant_Z_000[8].y) * _1262, (User_000.UserConstant_Z_000[8].z) * _1263),
      SV_Position.xy);
  float _1270 = resonance_perceptual_film_grain.x;
  float _1271 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1272 = log2(_1270);
  float _1273 = _1271 * _1272;
  float _1274 = exp2(_1273);
  float _1275 = _1274 + -1.0f;
  float _1276 = _1270 + -1.0f;
  float _1277 = _1275 / _1276;
  bool _1278 = !(_1270 == 1.0f);
  float _1279 = _1277 + -1.0f;
  float _1280 = _1279 / _1277;
  float _1281 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1282 = _1281 / _1271;
  float _1283 = select(_1278, _1280, _1282);
  float _1284 = resonance_perceptual_film_grain.y;
  float _1285 = log2(_1284);
  float _1286 = _1285 * _1271;
  float _1287 = exp2(_1286);
  float _1288 = _1287 + -1.0f;
  float _1289 = _1284 + -1.0f;
  float _1290 = _1288 / _1289;
  bool _1291 = !(_1284 == 1.0f);
  float _1292 = _1290 + -1.0f;
  float _1293 = _1292 / _1290;
  float _1294 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1295 = _1294 / _1271;
  float _1296 = select(_1291, _1293, _1295);
  float _1297 = resonance_perceptual_film_grain.z;
  float _1298 = log2(_1297);
  float _1299 = _1298 * _1271;
  float _1300 = exp2(_1299);
  float _1301 = _1300 + -1.0f;
  float _1302 = _1297 + -1.0f;
  float _1303 = _1301 / _1302;
  bool _1304 = !(_1297 == 1.0f);
  float _1305 = _1303 + -1.0f;
  float _1306 = _1305 / _1303;
  float _1307 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1308 = _1307 / _1271;
  float _1309 = select(_1304, _1306, _1308);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1270, _1284, _1297),
      float3(_1283, _1296, _1309),
      true);
  float _1310 = resonance_post_process_output.x;
  float _1311 = resonance_post_process_output.y;
  float _1312 = resonance_post_process_output.z;
  float _1313 = log2(_1310);
  float _1314 = log2(_1311);
  float _1315 = log2(_1312);
  float _1316 = _1313 * 0.4166666567325592f;
  float _1317 = _1314 * 0.4166666567325592f;
  float _1318 = _1315 * 0.4166666567325592f;
  float _1319 = exp2(_1316);
  float _1320 = exp2(_1317);
  float _1321 = exp2(_1318);
  float _1322 = _1319 * 1.0549999475479126f;
  float _1323 = _1320 * 1.0549999475479126f;
  float _1324 = _1321 * 1.0549999475479126f;
  float _1325 = _1322 + -0.054999999701976776f;
  float _1326 = _1323 + -0.054999999701976776f;
  float _1327 = _1324 + -0.054999999701976776f;
  float _1328 = _1310 * 12.920000076293945f;
  float _1329 = _1311 * 12.920000076293945f;
  float _1330 = _1312 * 12.920000076293945f;
  bool _1331 = (_1310 <= 0.0031308000907301903f);
  bool _1332 = (_1311 <= 0.0031308000907301903f);
  bool _1333 = (_1312 <= 0.0031308000907301903f);
  float _1334 = select(_1331, _1328, _1325);
  float _1335 = select(_1332, _1329, _1326);
  float _1336 = select(_1333, _1330, _1327);
  int _1339 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1340 = uint(SV_Position.x);
  uint _1341 = uint(SV_Position.y);
  int _1342 = _1340 & 63;
  int _1343 = _1341 & 63;
  float4 _1345 = t1.Load(int4(_1342, _1343, _1339, 0));
  float _1347 = _1345.x + -0.5f;
  float _1348 = _1347 * 0.003921568859368563f;
  float _1349 = _1348 + _1334;
  float _1350 = _1348 + _1335;
  float _1351 = _1348 + _1336;
  float _1352 = saturate(_1349);
  float _1353 = saturate(_1350);
  float _1354 = saturate(_1351);
  SV_Target.x = _1352;
  SV_Target.y = _1353;
  SV_Target.z = _1354;
  SV_Target.w = _135.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}