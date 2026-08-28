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
  float _539;
  float _578;
  float _579;
  float _580;
  float _609;
  float _610;
  float _611;
  float _616;
  float _617;
  float _618;
  float _818;
  float _922;
  float _1026;
  float _1029;
  float _1030;
  float _1031;
  float _1042;
  float _1167;
  float _1168;
  float _1169;
  float _1216;
  float _1217;
  float _1218;
  float _1232;
  float _1233;
  float _1234;
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
      _578 = _375;
      _579 = _192;
      _580 = _382;
    } else {
      _578 = _191;
      _579 = _192;
      _580 = _193;
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
      _578 = _428;
      _579 = _429;
      _580 = _430;
    } else {
      int _433 = asint((User_000.UserConstant_Z_000[7].x));
      bool _434 = ((int)_433 > (int)0);
      [branch]
      if (_434) {
        float4 _438 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _440 = abs(_438.x);
        _539 = _440;
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
        float4 _499 = t7.Load(int3(0, 0, 0));
        float _504 = _499.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _505 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _504;
        float _508 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * _505;
        float _509 = _508 + _505;
        float _510 = _505 - _508;
        float _511 = max(_494, _510);
        float _512 = min(_511, _509);
        float _515 = _494 - _512;
        float _516 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _515;
        float _518 = _512 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _519 = _518 * _494;
        float _520 = _516 / _519;
        float _521 = min(_520, 0.0f);
        float _524 = _508 + 1.0f;
        float _525 = 1.0f / _524;
        float _526 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _521;
        float _527 = max(0.0f, _520);
        float _530 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _527;
        float _531 = _530 + _526;
        float _532 = _531 * _525;
        float _533 = min(_497.x, _532);
        float _534 = abs(_533);
        float _535 = abs(_532);
        float _536 = max(_534, _535);
        float _537 = saturate(_536);
        _539 = _537;
      }
      float _542 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _539;
      float4 _545 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _552 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _542;
      float _553 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _542;
      float _554 = _552 + TEXCOORD.x;
      float _555 = _553 + TEXCOORD.y;
      float4 _556 = t4.Sample(s4, float2(_554, _555));
      float4 _560 = t5.Sample(s5, float2(_554, _555));
      float _562 = abs(_560.x);
      float _563 = _556.z - _545.z;
      float _564 = _562 * _563;
      float _565 = _542 + -1.0f;
      float _566 = saturate(_565);
      float _567 = _545.x - _191;
      float _568 = _545.y - _192;
      float _569 = _545.z - _193;
      float _570 = _569 + _564;
      float _571 = _566 * _567;
      float _572 = _566 * _568;
      float _573 = _570 * _566;
      float _574 = _571 + _191;
      float _575 = _572 + _192;
      float _576 = _573 + _193;
      _578 = _574;
      _579 = _575;
      _580 = _576;
    }
  }
  if (_155) {
    bool _584 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _588 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _148.x;
    float _589 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _148.y;
    float _590 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _148.z;
    float _591 = _588 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _592 = _589 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _593 = _590 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_584) {
      float _595 = _591 * _142.x;
      float _596 = _592 * _142.y;
      float _597 = _593 * _142.z;
      _609 = _595;
      _610 = _596;
      _611 = _597;
    } else {
      float _599 = saturate(_591);
      float _600 = saturate(_592);
      float _601 = saturate(_593);
      float _602 = _142.x - _578;
      float _603 = _142.y - _579;
      float _604 = _142.z - _580;
      float _605 = _599 * _602;
      float _606 = _600 * _603;
      float _607 = _601 * _604;
      _609 = _605;
      _610 = _606;
      _611 = _607;
    }
    float _612 = _609 + _578;
    float _613 = _610 + _579;
    float _614 = _611 + _580;
    _616 = _612;
    _617 = _613;
    _618 = _614;
  } else {
    _616 = _578;
    _617 = _579;
    _618 = _580;
  }
  float4 _622 = t17.Load(int3(0, 0, 0));
  float _630 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _631 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _632 = _622.x * _631;
  float _633 = _632 * _616;
  float _634 = _633 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _635 = _634 * _630;
  float _636 = _632 * _617;
  float _637 = _636 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _638 = _637 * _630;
  float _639 = _632 * _618;
  float _640 = _639 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _641 = _640 * _630;
  float _642 = _635 + 1.0f;
  float _643 = _638 + 1.0f;
  float _644 = _641 + 1.0f;
  float _645 = log2(_642);
  float _646 = log2(_643);
  float _647 = log2(_644);
  float _650 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _651 = _650 * _645;
  float _652 = _650 * _646;
  float _653 = _650 * _647;
  float _655 = _651 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _656 = _652 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _657 = _653 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _660 = t3.Sample(s3, float3(_655, _656, _657));
  float _666 = _660.x * 13.450128555297852f;
  float _667 = _660.y * 13.450128555297852f;
  float _668 = _660.z * 13.450128555297852f;
  float _669 = exp2(_666);
  float _670 = exp2(_667);
  float _671 = exp2(_668);
  float _672 = _669 + -1.0f;
  float _673 = _670 + -1.0f;
  float _674 = _671 + -1.0f;
  float _675 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _676 = _675 * _672;
  float _677 = _675 * _673;
  float _678 = _675 * _674;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_635 * _675, _638 * _675, _641 * _675),
      float3(_676, _677, _678),
      1.f.xxx);
  _676 = resonance_scaled_lut_output.x;
  _677 = resonance_scaled_lut_output.y;
  _678 = resonance_scaled_lut_output.z;
  bool _681 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_681) {
    float _683 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _684 = _676 * _683;
    float _685 = _677 * _683;
    float _686 = _678 * _683;
    float _687 = _684 + 1.0f;
    float _688 = _685 + 1.0f;
    float _689 = _686 + 1.0f;
    float _690 = log2(_687);
    float _691 = log2(_688);
    float _692 = log2(_689);
    float _693 = _690 * 0.07434873282909393f;
    float _694 = _691 * 0.07434873282909393f;
    float _695 = _692 * 0.07434873282909393f;
    int _697 = asint((User_000.UserConstant_Z_000[3].y));
    int _698 = _697 & 1;
    bool _699 = (_698 == 0);
    if (!_699) {
      bool _716 = !(_693 <= (User_000.UserConstant_Z_000[4].x));
      if (!_716) {
        float _718 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _719 = _693 / _718;
        float _720 = _719 * (User_000.UserConstant_Z_000[4].y);
        float _721 = _719 * _719;
        float _722 = _721 * _719;
        float _723 = _722 - _719;
        float _724 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _725 = _718 * _718;
        float _726 = _725 * _724;
        float _727 = _726 * _723;
        float _728 = _727 + _720;
        _818 = _728;
      } else {
        bool _730 = !(_693 <= (User_000.UserConstant_Z_000[4].z));
        if (!_730) {
          float _732 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _733 = max(9.999999974752427e-07f, _732);
          float _734 = _693 - (User_000.UserConstant_Z_000[4].x);
          float _735 = _734 / _733;
          float _736 = 1.0f - _735;
          float _737 = _736 * (User_000.UserConstant_Z_000[4].y);
          float _738 = _735 * (User_000.UserConstant_Z_000[4].w);
          float _739 = _737 + _738;
          float _740 = _736 * _736;
          float _741 = _740 * _736;
          float _742 = _741 - _736;
          float _743 = _742 * (User_000.UserConstant_Z_000[10].x);
          float _744 = _735 * _735;
          float _745 = _744 * _735;
          float _746 = _745 - _735;
          float _747 = _746 * (User_000.UserConstant_Z_000[10].y);
          float _748 = _743 + _747;
          float _749 = _733 * _733;
          float _750 = _749 * 0.1666666716337204f;
          float _751 = _750 * _748;
          float _752 = _739 + _751;
          _818 = _752;
        } else {
          bool _754 = !(_693 <= (User_000.UserConstant_Z_000[9].x));
          if (!_754) {
            float _756 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _757 = max(9.999999974752427e-07f, _756);
            float _758 = _693 - (User_000.UserConstant_Z_000[4].z);
            float _759 = _758 / _757;
            float _760 = 1.0f - _759;
            float _761 = _760 * (User_000.UserConstant_Z_000[4].w);
            float _762 = _759 * (User_000.UserConstant_Z_000[9].y);
            float _763 = _761 + _762;
            float _764 = _760 * _760;
            float _765 = _764 * _760;
            float _766 = _765 - _760;
            float _767 = _766 * (User_000.UserConstant_Z_000[10].y);
            float _768 = _759 * _759;
            float _769 = _768 * _759;
            float _770 = _769 - _759;
            float _771 = _770 * (User_000.UserConstant_Z_000[10].z);
            float _772 = _767 + _771;
            float _773 = _757 * _757;
            float _774 = _773 * 0.1666666716337204f;
            float _775 = _774 * _772;
            float _776 = _763 + _775;
            _818 = _776;
          } else {
            bool _778 = !(_693 <= (User_000.UserConstant_Z_000[9].z));
            if (!_778) {
              float _780 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _781 = max(9.999999974752427e-07f, _780);
              float _782 = _693 - (User_000.UserConstant_Z_000[9].x);
              float _783 = _782 / _781;
              float _784 = 1.0f - _783;
              float _785 = _784 * (User_000.UserConstant_Z_000[9].y);
              float _786 = _783 * (User_000.UserConstant_Z_000[9].w);
              float _787 = _785 + _786;
              float _788 = _784 * _784;
              float _789 = _788 * _784;
              float _790 = _789 - _784;
              float _791 = _790 * (User_000.UserConstant_Z_000[10].z);
              float _792 = _783 * _783;
              float _793 = _792 * _783;
              float _794 = _793 - _783;
              float _795 = _794 * (User_000.UserConstant_Z_000[10].w);
              float _796 = _791 + _795;
              float _797 = _781 * _781;
              float _798 = _797 * 0.1666666716337204f;
              float _799 = _798 * _796;
              float _800 = _787 + _799;
              _818 = _800;
            } else {
              float _802 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _803 = _693 - (User_000.UserConstant_Z_000[9].z);
              float _804 = max(9.999999974752427e-07f, _802);
              float _805 = _803 / _804;
              float _806 = 1.0f - _805;
              float _807 = _806 * (User_000.UserConstant_Z_000[9].w);
              float _808 = _807 + _805;
              float _809 = _806 * _806;
              float _810 = _809 * _806;
              float _811 = _810 - _806;
              float _812 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _813 = _802 * _802;
              float _814 = _813 * _812;
              float _815 = _814 * _811;
              float _816 = _808 + _815;
              _818 = _816;
            }
          }
        }
      }
      float _819 = saturate(_818);
      bool _820 = !(_694 <= (User_000.UserConstant_Z_000[4].x));
      if (!_820) {
        float _822 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _823 = _694 / _822;
        float _824 = _823 * (User_000.UserConstant_Z_000[4].y);
        float _825 = _823 * _823;
        float _826 = _825 * _823;
        float _827 = _826 - _823;
        float _828 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _829 = _822 * _822;
        float _830 = _829 * _828;
        float _831 = _830 * _827;
        float _832 = _831 + _824;
        _922 = _832;
      } else {
        bool _834 = !(_694 <= (User_000.UserConstant_Z_000[4].z));
        if (!_834) {
          float _836 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _837 = max(9.999999974752427e-07f, _836);
          float _838 = _694 - (User_000.UserConstant_Z_000[4].x);
          float _839 = _838 / _837;
          float _840 = 1.0f - _839;
          float _841 = _840 * (User_000.UserConstant_Z_000[4].y);
          float _842 = _839 * (User_000.UserConstant_Z_000[4].w);
          float _843 = _841 + _842;
          float _844 = _840 * _840;
          float _845 = _844 * _840;
          float _846 = _845 - _840;
          float _847 = _846 * (User_000.UserConstant_Z_000[10].x);
          float _848 = _839 * _839;
          float _849 = _848 * _839;
          float _850 = _849 - _839;
          float _851 = _850 * (User_000.UserConstant_Z_000[10].y);
          float _852 = _847 + _851;
          float _853 = _837 * _837;
          float _854 = _853 * 0.1666666716337204f;
          float _855 = _854 * _852;
          float _856 = _843 + _855;
          _922 = _856;
        } else {
          bool _858 = !(_694 <= (User_000.UserConstant_Z_000[9].x));
          if (!_858) {
            float _860 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _861 = max(9.999999974752427e-07f, _860);
            float _862 = _694 - (User_000.UserConstant_Z_000[4].z);
            float _863 = _862 / _861;
            float _864 = 1.0f - _863;
            float _865 = _864 * (User_000.UserConstant_Z_000[4].w);
            float _866 = _863 * (User_000.UserConstant_Z_000[9].y);
            float _867 = _865 + _866;
            float _868 = _864 * _864;
            float _869 = _868 * _864;
            float _870 = _869 - _864;
            float _871 = _870 * (User_000.UserConstant_Z_000[10].y);
            float _872 = _863 * _863;
            float _873 = _872 * _863;
            float _874 = _873 - _863;
            float _875 = _874 * (User_000.UserConstant_Z_000[10].z);
            float _876 = _871 + _875;
            float _877 = _861 * _861;
            float _878 = _877 * 0.1666666716337204f;
            float _879 = _878 * _876;
            float _880 = _867 + _879;
            _922 = _880;
          } else {
            bool _882 = !(_694 <= (User_000.UserConstant_Z_000[9].z));
            if (!_882) {
              float _884 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _885 = max(9.999999974752427e-07f, _884);
              float _886 = _694 - (User_000.UserConstant_Z_000[9].x);
              float _887 = _886 / _885;
              float _888 = 1.0f - _887;
              float _889 = _888 * (User_000.UserConstant_Z_000[9].y);
              float _890 = _887 * (User_000.UserConstant_Z_000[9].w);
              float _891 = _889 + _890;
              float _892 = _888 * _888;
              float _893 = _892 * _888;
              float _894 = _893 - _888;
              float _895 = _894 * (User_000.UserConstant_Z_000[10].z);
              float _896 = _887 * _887;
              float _897 = _896 * _887;
              float _898 = _897 - _887;
              float _899 = _898 * (User_000.UserConstant_Z_000[10].w);
              float _900 = _895 + _899;
              float _901 = _885 * _885;
              float _902 = _901 * 0.1666666716337204f;
              float _903 = _902 * _900;
              float _904 = _891 + _903;
              _922 = _904;
            } else {
              float _906 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _907 = _694 - (User_000.UserConstant_Z_000[9].z);
              float _908 = max(9.999999974752427e-07f, _906);
              float _909 = _907 / _908;
              float _910 = 1.0f - _909;
              float _911 = _910 * (User_000.UserConstant_Z_000[9].w);
              float _912 = _911 + _909;
              float _913 = _910 * _910;
              float _914 = _913 * _910;
              float _915 = _914 - _910;
              float _916 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _917 = _906 * _906;
              float _918 = _917 * _916;
              float _919 = _918 * _915;
              float _920 = _912 + _919;
              _922 = _920;
            }
          }
        }
      }
      float _923 = saturate(_922);
      bool _924 = !(_695 <= (User_000.UserConstant_Z_000[4].x));
      if (!_924) {
        float _926 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _927 = _695 / _926;
        float _928 = _927 * (User_000.UserConstant_Z_000[4].y);
        float _929 = _927 * _927;
        float _930 = _929 * _927;
        float _931 = _930 - _927;
        float _932 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _933 = _926 * _926;
        float _934 = _933 * _932;
        float _935 = _934 * _931;
        float _936 = _935 + _928;
        _1026 = _936;
      } else {
        bool _938 = !(_695 <= (User_000.UserConstant_Z_000[4].z));
        if (!_938) {
          float _940 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _941 = max(9.999999974752427e-07f, _940);
          float _942 = _695 - (User_000.UserConstant_Z_000[4].x);
          float _943 = _942 / _941;
          float _944 = 1.0f - _943;
          float _945 = _944 * (User_000.UserConstant_Z_000[4].y);
          float _946 = _943 * (User_000.UserConstant_Z_000[4].w);
          float _947 = _945 + _946;
          float _948 = _944 * _944;
          float _949 = _948 * _944;
          float _950 = _949 - _944;
          float _951 = _950 * (User_000.UserConstant_Z_000[10].x);
          float _952 = _943 * _943;
          float _953 = _952 * _943;
          float _954 = _953 - _943;
          float _955 = _954 * (User_000.UserConstant_Z_000[10].y);
          float _956 = _951 + _955;
          float _957 = _941 * _941;
          float _958 = _957 * 0.1666666716337204f;
          float _959 = _958 * _956;
          float _960 = _947 + _959;
          _1026 = _960;
        } else {
          bool _962 = !(_695 <= (User_000.UserConstant_Z_000[9].x));
          if (!_962) {
            float _964 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _965 = max(9.999999974752427e-07f, _964);
            float _966 = _695 - (User_000.UserConstant_Z_000[4].z);
            float _967 = _966 / _965;
            float _968 = 1.0f - _967;
            float _969 = _968 * (User_000.UserConstant_Z_000[4].w);
            float _970 = _967 * (User_000.UserConstant_Z_000[9].y);
            float _971 = _969 + _970;
            float _972 = _968 * _968;
            float _973 = _972 * _968;
            float _974 = _973 - _968;
            float _975 = _974 * (User_000.UserConstant_Z_000[10].y);
            float _976 = _967 * _967;
            float _977 = _976 * _967;
            float _978 = _977 - _967;
            float _979 = _978 * (User_000.UserConstant_Z_000[10].z);
            float _980 = _975 + _979;
            float _981 = _965 * _965;
            float _982 = _981 * 0.1666666716337204f;
            float _983 = _982 * _980;
            float _984 = _971 + _983;
            _1026 = _984;
          } else {
            bool _986 = !(_695 <= (User_000.UserConstant_Z_000[9].z));
            if (!_986) {
              float _988 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _989 = max(9.999999974752427e-07f, _988);
              float _990 = _695 - (User_000.UserConstant_Z_000[9].x);
              float _991 = _990 / _989;
              float _992 = 1.0f - _991;
              float _993 = _992 * (User_000.UserConstant_Z_000[9].y);
              float _994 = _991 * (User_000.UserConstant_Z_000[9].w);
              float _995 = _993 + _994;
              float _996 = _992 * _992;
              float _997 = _996 * _992;
              float _998 = _997 - _992;
              float _999 = _998 * (User_000.UserConstant_Z_000[10].z);
              float _1000 = _991 * _991;
              float _1001 = _1000 * _991;
              float _1002 = _1001 - _991;
              float _1003 = _1002 * (User_000.UserConstant_Z_000[10].w);
              float _1004 = _999 + _1003;
              float _1005 = _989 * _989;
              float _1006 = _1005 * 0.1666666716337204f;
              float _1007 = _1006 * _1004;
              float _1008 = _995 + _1007;
              _1026 = _1008;
            } else {
              float _1010 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _1011 = _695 - (User_000.UserConstant_Z_000[9].z);
              float _1012 = max(9.999999974752427e-07f, _1010);
              float _1013 = _1011 / _1012;
              float _1014 = 1.0f - _1013;
              float _1015 = _1014 * (User_000.UserConstant_Z_000[9].w);
              float _1016 = _1015 + _1013;
              float _1017 = _1014 * _1014;
              float _1018 = _1017 * _1014;
              float _1019 = _1018 - _1014;
              float _1020 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1021 = _1010 * _1010;
              float _1022 = _1021 * _1020;
              float _1023 = _1022 * _1019;
              float _1024 = _1016 + _1023;
              _1026 = _1024;
            }
          }
        }
      }
      float _1027 = saturate(_1026);
      _1029 = _819;
      _1030 = _923;
      _1031 = _1027;
    } else {
      _1029 = _693;
      _1030 = _694;
      _1031 = _695;
    }
    int _1032 = _697 & 2;
    bool _1033 = (_1032 == 0);
    if (!_1033) {
      float _1035 = sqrt(_1029);
      float _1036 = sqrt(_1030);
      float _1037 = sqrt(_1031);
      float _1038 = dot(float3(_1035, _1036, _1037), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1039 = 1.0f - _1038;
      float _1040 = saturate(_1039);
      _1042 = _1040;
    } else {
      _1042 = 1.0f;
    }
    int _1043 = _697 & 8;
    bool _1044 = (_1043 == 0);
    if (_1044) {
      int _1046 = _697 & 4;
      bool _1047 = (_1046 == 0);
      if (!_1047) {
        int _1049 = _697 & 16;
        bool _1050 = (_1049 == 0);
        if (!_1050) {
          float _1054 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1055 = _1054 + 0.5f;
          bool _1056 = (_1055 < 0.5f);
          float _1057 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1058 = select(_1056, (User_000.UserConstant_Z_000[5].x), _1057);
          bool _1059 = (_1030 < _1031);
          float _1060 = select(_1059, _1031, _1030);
          float _1061 = select(_1059, _1030, _1031);
          bool _1062 = (_1029 < _1060);
          float _1063 = select(_1062, _1060, _1029);
          float _1064 = select(_1062, _1029, _1060);
          float _1065 = min(_1064, _1061);
          float _1066 = _1063 - _1065;
          float _1067 = _1063 + 1.000000013351432e-10f;
          float _1068 = _1066 / _1067;
          float _1070 = _1068 - (User_000.UserConstant_Z_000[5].y);
          float _1071 = saturate(_1070);
          float _1072 = max(_1071, 9.999999974752427e-07f);
          float _1073 = log2(_1072);
          float _1074 = _1073 * _1058;
          float _1075 = exp2(_1074);
          float _1076 = 2.0f - _1075;
          float _1078 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1079 = saturate(_1078);
          float _1080 = max(_1079, _1076);
          float _1081 = dot(float3(_1029, _1030, _1031), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1082 = _1029 - _1081;
          float _1083 = _1030 - _1081;
          float _1084 = _1031 - _1081;
          float _1085 = _1082 * _1080;
          float _1086 = _1083 * _1080;
          float _1087 = _1084 * _1080;
          float _1088 = _1081 - _1029;
          float _1089 = _1088 + _1085;
          float _1090 = _1081 - _1030;
          float _1091 = _1090 + _1086;
          float _1092 = _1081 - _1031;
          float _1093 = _1092 + _1087;
          float _1094 = _1089 * _1042;
          float _1095 = _1091 * _1042;
          float _1096 = _1093 * _1042;
          float _1097 = _1094 + _1029;
          float _1098 = _1095 + _1030;
          float _1099 = _1096 + _1031;
          _1216 = _1097;
          _1217 = _1098;
          _1218 = _1099;
        } else {
          bool _1101 = (_1042 == 0.0f);
          if (!_1101) {
            float _1105 = abs(User_000.UserConstant_Z_000[5].x);
            float _1106 = saturate(_1105);
            uint4 _1108 = 0u; t15.GetDimensions(0u, _1108.x, _1108.y, _1108.w);
            float _1111 = float((uint)_1108.y);
            int _1112 = _697 & 32;
            bool _1113 = (_1112 == 0);
            float _1114 = _1111 + -1.0f;
            if (!_1113) {
              float _1116 = 1.0f / _1114;
              uint _1117 = uint(SV_Position.x);
              uint _1118 = uint(SV_Position.y);
              int _1119 = _1117 & 63;
              int _1120 = _1118 & 63;
              float4 _1122 = t6.Load(int4(_1119, _1120, 0, 0));
              float _1125 = _1122.x + -0.5f;
              float _1126 = _1029 * 13.999999046325684f;
              float _1127 = _1030 * 13.999999046325684f;
              float _1128 = _1031 * 13.999999046325684f;
              float _1129 = saturate(_1126);
              float _1130 = saturate(_1127);
              float _1131 = saturate(_1128);
              float _1132 = _1029 + -0.9285714030265808f;
              float _1133 = _1030 + -0.9285714030265808f;
              float _1134 = _1031 + -0.9285714030265808f;
              float _1135 = _1132 * 13.999999046325684f;
              float _1136 = _1133 * 13.999999046325684f;
              float _1137 = _1134 * 13.999999046325684f;
              float _1138 = saturate(_1135);
              float _1139 = saturate(_1136);
              float _1140 = saturate(_1137);
              float _1141 = 1.0f - _1138;
              float _1142 = 1.0f - _1139;
              float _1143 = 1.0f - _1140;
              float _1144 = min(_1129, _1141);
              float _1145 = min(_1130, _1142);
              float _1146 = min(_1131, _1143);
              float _1147 = _1122.y + -0.5f;
              float _1148 = _1144 * _1147;
              float _1149 = _1145 * _1147;
              float _1150 = _1146 * _1147;
              float _1151 = _1148 + _1125;
              float _1152 = _1149 + _1125;
              float _1153 = _1150 + _1125;
              float _1154 = _1151 * _1116;
              float _1155 = _1152 * _1116;
              float _1156 = _1153 * _1116;
              float _1157 = _1154 + _1029;
              float _1158 = _1155 + _1030;
              float _1159 = _1156 + _1031;
              float _1160 = saturate(_1157);
              float _1161 = saturate(_1158);
              float _1162 = saturate(_1159);
              float _1163 = saturate(_1160);
              float _1164 = saturate(_1161);
              float _1165 = saturate(_1162);
              _1167 = _1163;
              _1168 = _1164;
              _1169 = _1165;
            } else {
              _1167 = _1029;
              _1168 = _1030;
              _1169 = _1031;
            }
            float _1170 = float((uint)_1108.x);
            float _1171 = _1114 / _1170;
            float _1172 = _1171 * _1167;
            float _1173 = 0.5f / _1170;
            float _1174 = _1172 + _1173;
            float _1175 = _1114 / _1111;
            float _1176 = _1175 * _1168;
            float _1177 = 0.5f / _1111;
            float _1178 = _1176 + _1177;
            float _1179 = _1169 * _1114;
            float _1180 = floor(_1179);
            float _1181 = frac(_1179);
            float _1182 = _1180 / _1111;
            float _1183 = _1182 + _1174;
            float _1184 = _1180 + 1.0f;
            float _1185 = _1184 / _1111;
            float _1186 = _1185 + _1174;
            float4 _1188 = t15.Sample(s0, float2(_1183, _1178));
            float4 _1192 = t15.Sample(s0, float2(_1186, _1178));
            float _1196 = _1192.x - _1188.x;
            float _1197 = _1192.y - _1188.y;
            float _1198 = _1192.z - _1188.z;
            float _1199 = _1196 * _1181;
            float _1200 = _1197 * _1181;
            float _1201 = _1198 * _1181;
            float _1202 = _1106 * _1042;
            float _1203 = _1188.x - _1029;
            float _1204 = _1203 + _1199;
            float _1205 = _1188.y - _1030;
            float _1206 = _1205 + _1200;
            float _1207 = _1188.z - _1031;
            float _1208 = _1207 + _1201;
            float _1209 = _1204 * _1202;
            float _1210 = _1206 * _1202;
            float _1211 = _1208 * _1202;
            float _1212 = _1209 + _1029;
            float _1213 = _1210 + _1030;
            float _1214 = _1211 + _1031;
            _1216 = _1212;
            _1217 = _1213;
            _1218 = _1214;
          } else {
            _1216 = _1029;
            _1217 = _1030;
            _1218 = _1031;
          }
        }
      } else {
        _1216 = _1029;
        _1217 = _1030;
        _1218 = _1031;
      }
    } else {
      _1216 = _1042;
      _1217 = _1042;
      _1218 = _1042;
    }
    float _1219 = _1216 * 13.450128555297852f;
    float _1220 = _1217 * 13.450128555297852f;
    float _1221 = _1218 * 13.450128555297852f;
    float _1222 = exp2(_1219);
    float _1223 = exp2(_1220);
    float _1224 = exp2(_1221);
    float _1225 = _1222 + -1.0f;
    float _1226 = _1223 + -1.0f;
    float _1227 = _1224 + -1.0f;
    float _1228 = _1225 * _675;
    float _1229 = _1226 * _675;
    float _1230 = _1227 * _675;
    _1232 = _1228;
    _1233 = _1229;
    _1234 = _1230;
  } else {
    _1232 = _676;
    _1233 = _677;
    _1234 = _678;
  }
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1232, (User_000.UserConstant_Z_000[8].y) * _1233, (User_000.UserConstant_Z_000[8].z) * _1234),
      SV_Position.xy);
  float _1241 = resonance_perceptual_film_grain.x;
  float _1242 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1243 = log2(_1241);
  float _1244 = _1242 * _1243;
  float _1245 = exp2(_1244);
  float _1246 = _1245 + -1.0f;
  float _1247 = _1241 + -1.0f;
  float _1248 = _1246 / _1247;
  bool _1249 = !(_1241 == 1.0f);
  float _1250 = _1248 + -1.0f;
  float _1251 = _1250 / _1248;
  float _1252 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1253 = _1252 / _1242;
  float _1254 = select(_1249, _1251, _1253);
  float _1255 = resonance_perceptual_film_grain.y;
  float _1256 = log2(_1255);
  float _1257 = _1256 * _1242;
  float _1258 = exp2(_1257);
  float _1259 = _1258 + -1.0f;
  float _1260 = _1255 + -1.0f;
  float _1261 = _1259 / _1260;
  bool _1262 = !(_1255 == 1.0f);
  float _1263 = _1261 + -1.0f;
  float _1264 = _1263 / _1261;
  float _1265 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1266 = _1265 / _1242;
  float _1267 = select(_1262, _1264, _1266);
  float _1268 = resonance_perceptual_film_grain.z;
  float _1269 = log2(_1268);
  float _1270 = _1269 * _1242;
  float _1271 = exp2(_1270);
  float _1272 = _1271 + -1.0f;
  float _1273 = _1268 + -1.0f;
  float _1274 = _1272 / _1273;
  bool _1275 = !(_1268 == 1.0f);
  float _1276 = _1274 + -1.0f;
  float _1277 = _1276 / _1274;
  float _1278 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1279 = _1278 / _1242;
  float _1280 = select(_1275, _1277, _1279);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1241, _1255, _1268),
      float3(_1254, _1267, _1280),
      true);
  float _1281 = resonance_post_process_output.x;
  float _1282 = resonance_post_process_output.y;
  float _1283 = resonance_post_process_output.z;
  float _1284 = log2(_1281);
  float _1285 = log2(_1282);
  float _1286 = log2(_1283);
  float _1287 = _1284 * 0.4166666567325592f;
  float _1288 = _1285 * 0.4166666567325592f;
  float _1289 = _1286 * 0.4166666567325592f;
  float _1290 = exp2(_1287);
  float _1291 = exp2(_1288);
  float _1292 = exp2(_1289);
  float _1293 = _1290 * 1.0549999475479126f;
  float _1294 = _1291 * 1.0549999475479126f;
  float _1295 = _1292 * 1.0549999475479126f;
  float _1296 = _1293 + -0.054999999701976776f;
  float _1297 = _1294 + -0.054999999701976776f;
  float _1298 = _1295 + -0.054999999701976776f;
  float _1299 = _1281 * 12.920000076293945f;
  float _1300 = _1282 * 12.920000076293945f;
  float _1301 = _1283 * 12.920000076293945f;
  bool _1302 = (_1281 <= 0.0031308000907301903f);
  bool _1303 = (_1282 <= 0.0031308000907301903f);
  bool _1304 = (_1283 <= 0.0031308000907301903f);
  float _1305 = select(_1302, _1299, _1296);
  float _1306 = select(_1303, _1300, _1297);
  float _1307 = select(_1304, _1301, _1298);
  int _1310 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1311 = uint(SV_Position.x);
  uint _1312 = uint(SV_Position.y);
  int _1313 = _1311 & 63;
  int _1314 = _1312 & 63;
  float4 _1316 = t1.Load(int4(_1313, _1314, _1310, 0));
  float _1318 = _1316.x + -0.5f;
  float _1319 = _1318 * 0.003921568859368563f;
  float _1320 = _1319 + _1305;
  float _1321 = _1319 + _1306;
  float _1322 = _1319 + _1307;
  float _1323 = saturate(_1320);
  float _1324 = saturate(_1321);
  float _1325 = saturate(_1322);
  SV_Target.x = _1323;
  SV_Target.y = _1324;
  SV_Target.z = _1325;
  SV_Target.w = _135.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}